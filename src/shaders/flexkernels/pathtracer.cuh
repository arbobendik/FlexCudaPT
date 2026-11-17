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

static __device__ bool previousValid_0(int2  q_1)
{
    bool _S116 = all_0(q_1 >= make_int2 (int(0)));
    bool _S117;
    if(_S116)
    {
        uint2  _S118 = (fcptRenderSize());
        int2  _S119 = make_int2 ((int)_S118.x, (int)_S118.y);
        _S117 = all_0(q_1 < _S119);
    }
    else
    {
        _S117 = false;
    }
    if(_S117)
    {
        uint4  _S120 = (fcptReservoirPrevious((q_1), (0U)));
        _S117 = (U32_asfloat((_S120.w))) > 0.0f;
    }
    else
    {
        _S117 = false;
    }
    return _S117;
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
    bool _S121 = previousValid_0(p_6);
    bool _S122;
    if(_S121)
    {
        Domain _S123 = (fcptPreviousDomain((p_6), (seed_1)));
        Domain _S124 = _S123;
        bool _S125 = sameDomain_0(&_S124, dom_2);
        _S122 = _S125;
    }
    else
    {
        _S122 = false;
    }
    if(_S122)
    {
        return p_6;
    }
    uint _S126 = (&dom_2->hit)->instance_index;
    bool _S127 = ((&dom_2->hit)->instance_index) == 4294967295U;
    if(_S127)
    {
        return make_int2 (int(-1));
    }
    float3  _S128 = dom_2->x1;
    float2  _S129 = (fcptPixelOf((dom_2->x1), (true)));
    float2  _S130 = floor_0(_S129);
    int2  _S131 = make_int2 ((int)_S130.x, (int)_S130.y);
    bool _S132 = previousValid_0(_S131);
    bool _S133 = !_S132;
    if(_S133)
    {
        return make_int2 (int(-1));
    }
    uint4  _S134 = (fcptReservoirPrevious((_S131), (0U)));
    Domain _S135 = (fcptPreviousDomain((_S131), (_S134.x)));
    bool _S136 = (_S135.hit.instance_index) == _S126;
    if(_S136)
    {
        float _S137 = distance_1(_S135.x1, _S128);
        float _S138 = (&dom_2->hit)->distance * 8.0f;
        uint2  _S139 = (fcptRenderSize());
        _S122 = _S137 <= (_S138 / float(_S139.x));
    }
    else
    {
        _S122 = false;
    }
    if(_S122)
    {
        return _S131;
    }
    int2  _S140 = p_6 + _S131;
    float2  _S141 = make_float2 ((float)_S140.x, (float)_S140.y);
    float2  _S142 = _S141 + make_float2 (1.0f);
    float2  _S143 = (fcptPixelOf((_S135.x1), (false)));
    float2  _S144 = floor_0(_S142 - _S143);
    int2  _S145 = make_int2 ((int)_S144.x, (int)_S144.y);
    int2  _S146 = make_int2 (int(-1));
    bool _S147 = previousValid_0(_S145);
    int2  _S148 = _slang_select(_S147, _S145,_S146);
    return _S148;
}

static __device__ int2  sampleNeighbor_0(int2  p_7, uint seed_2)
{
    bool _S149 = (fcptSceneUnchanged());
    if(_S149)
    {
        bool _S150 = previousValid_0(p_7);
        int2  _S151;
        if(_S150)
        {
            _S151 = p_7;
        }
        else
        {
            _S151 = make_int2 (int(-1));
        }
        return _S151;
    }
    float3  _S152 = make_float3 (0.0f);
    FKHit _S153 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S154 = Domain_x24init_0(_S152, _S152, &_S153, 0.0f, 0.0f);
    Domain dom_3 = _S154;
    uint2  _S155 = (fcptRenderSize());
    int2  _S156 = make_int2 ((int)_S155.x, (int)_S155.y);
    bool _S157 = any_0(p_7 >= _S156);
    bool _S158;
    if(_S157)
    {
        _S158 = true;
    }
    else
    {
        bool _S159 = (fcptStoredDomainInitial((p_7), (seed_2), (&dom_3)));
        _S158 = !_S159;
    }
    if(_S158)
    {
        return make_int2 (int(-1));
    }
    Domain _S160 = dom_3;
    int2  _S161 = temporalNeighbor_0(p_7, &_S160, seed_2);
    return _S161;
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
    FKRay _S162;
    (&_S162)->origin = origin_0;
    (&_S162)->unit_direction = unit_direction_0;
    return _S162;
}

static __device__ float3  skyRadiance_0(float3  origin_1, FKSurface * surface_0, bool is_inside_1, float3  dir_1, ShadowContext * context_0, uint random_state_0)
{
    bool _S163 = wrongSide_0(is_inside_1, false, dir_1, surface_0->geometry_n);
    bool _S164 = is_inside_1 != _S163;
    float _S165 = surface_0->geometry_offset;
    float3  _S166 = surface_0->smooth_n;
    float3  _S167 = - surface_0->smooth_n;
    float3  _S168 = _slang_select(_S164, _S167,_S166);
    FKRay _S169 = Ray_x24init_0(origin_1 + make_float3 (_S165) * _S168, dir_1);
    bool _S170 = (dot_0(context_0->side, dir_1)) > 0.0f;
    float3  _S171 = (fcptEnvMapSample((dir_1), (0U), (3U)));
    float3  _S172 = context_0->extinction_behind;
    float3  _S173 = context_0->extinction_front;
    float3  _S174 = _slang_select(_S170, _S173,_S172);
    uint _S175 = context_0->fillings.x;
    uint _S176 = context_0->fillings.y;
    uint _S177 = _slang_select(_S170, _S176,_S175);
    uint _S178 = context_0->depth;
    uint _S179 = context_0->lobe;
    bool _S180 = context_0->surface;
    bool _S181;
    if(_S180)
    {
        _S181 = !context_0->fiber;
    }
    else
    {
        _S181 = false;
    }
    float _S182 = context_0->length;
    float _S183 = context_0->width;
    FKHit _S184 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    float3  _S185 = (fcptShadowTransmittanceIn((_S169), (4.294967296e+09f), (_S174), (_S177), (random_state_0), (_S178), (_S179), (_S181), (_S182), (_S183), (_S184), (_S184)));
    return _S171 * _S185;
}

static __device__ uint searchCDF_0(uint2  start_4, uint2  step_0, uint count_1, float u_0)
{
    uint _S186 = count_1 - 1U;
    uint low_0 = 0U;
    uint high_0 = _S186;
    for(;;)
    {
        if(low_0 < high_0)
        {
        }
        else
        {
            break;
        }
        uint _S187 = (low_0 + high_0) / 2U;
        float4  _S188 = (fcptEnvironmentCdf((start_4 + step_0 * make_uint2 (_S187))));
        bool _S189 = (_S188.x) > u_0;
        if(_S189)
        {
            high_0 = _S187;
        }
        else
        {
            uint _S190 = _S187 + 1U;
            low_0 = _S190;
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
    float3  _S191 = ((((light_dir_0)) * make_float3(rnorm3df(((light_dir_0)).x, ((light_dir_0)).y, ((light_dir_0)).z))));
    bool _S192 = (dot_0(smooth_n_0, _S191)) < 0.0f;
    if(_S192)
    {
        return make_float3 (0.0f);
    }
    float3  _S193 = make_float3 (geometry_offset_0) * smooth_n_0;
    float3  _S194 = origin_2 + _S193;
    FKRay _S195 = Ray_x24init_0(_S194, _S191);
    bool _S196 = (dot_0(context_1->side, light_dir_0 + _S193)) > 0.0f;
    float _S197 = shadowLength(light_dir_0);
    float3  _S198 = context_1->extinction_behind;
    float3  _S199 = context_1->extinction_front;
    float3  _S200 = _slang_select(_S196, _S199,_S198);
    uint _S201 = context_1->fillings.x;
    uint _S202 = context_1->fillings.y;
    uint _S203 = _slang_select(_S196, _S202,_S201);
    uint _S204 = context_1->depth;
    uint _S205 = context_1->lobe;
    bool _S206 = context_1->surface;
    bool _S207;
    if(_S206)
    {
        _S207 = !context_1->fiber;
    }
    else
    {
        _S207 = false;
    }
    float _S208 = context_1->length;
    float _S209 = context_1->width;
    FKHit _S210;
    if(context_1->fiber)
    {
        _S210 = context_1->own;
    }
    else
    {
        _S210 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    }
    float3  _S211 = (fcptShadowTransmittanceIn((_S195), (_S197), (_S200), (_S203), (random_state_1), (_S204), (_S205), (_S207), (_S208), (_S209), (_S210), (*light_0)));
    return _S211;
}

__device__ float sine(float c_0)
{
    return (F32_sqrt(((F32_max((1.0f - c_0 * c_0), (0.0f))))));
}

__device__ float cosSubClamped(float sin_a_0, float cos_a_0, float sin_b_0, float cos_b_0)
{
    float _S212 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    bool _S213 = cos_a_0 > cos_b_0;
    float _S214 = _slang_select(_S213, 1.0f,_S212);
    return _S214;
}

__device__ float sinSubClamped(float sin_a_1, float cos_a_1, float sin_b_1, float cos_b_1)
{
    float _S215 = sin_a_1 * cos_b_1 - cos_a_1 * sin_b_1;
    bool _S216 = cos_a_1 > cos_b_1;
    float _S217 = _slang_select(_S216, 0.0f,_S215);
    return _S217;
}

__device__ float importance(LightNode node_0, float3  p_8, float3  normal_0)
{
    float3  _S218 = (node_0.low + node_0.high) * make_float3 (0.5f);
    float3  _S219 = node_0.high - node_0.low;
    float3  _S220 = p_8 - _S218;
    float3  _S221 = ((((_S220)) * make_float3(rnorm3df(((_S220)).x, ((_S220)).y, ((_S220)).z))));
    float _S222 = dot_0(_S220, _S220);
    float _S223 = dot_0(_S219, _S219) / 4.0f;
    float _S224 = (F32_abs((dot_0(node_0.w, _S221))));
    float _S225 = sine(node_0.cos_theta_o);
    float _S226 = (F32_sqrt(((F32_max((1.0f - _S223 / _S222), (0.0f))))));
    bool _S227 = _S222 < _S223;
    float _S228 = _slang_select(_S227, -1.0f,_S226);
    float _S229 = sine(_S228);
    float _S230 = sine(_S224);
    float _S231 = cosSubClamped(_S230, _S224, _S225, node_0.cos_theta_o);
    float _S232 = sine(_S224);
    float _S233 = sinSubClamped(_S232, _S224, _S225, node_0.cos_theta_o);
    float _S234 = cosSubClamped(_S233, _S231, _S229, _S228);
    bool _S235 = _S234 <= 0.0f;
    if(_S235)
    {
        return 0.0f;
    }
    float _S236 = - dot_0(_S221, normal_0);
    float _S237 = node_0.phi * _S234 / (F32_max((_S222), (length_0(_S219) / 2.0f)));
    float _S238 = sine(_S236);
    float _S239 = cosSubClamped(_S238, _S236, _S229, _S228);
    bool _S240 = (dot_0(normal_0, normal_0)) == 0.0f;
    float _S241 = _slang_select(_S240, 1.0f,_S239);
    return (F32_max((_S237 * _S241), (0.0f)));
}

__device__ __forceinline__ float childShare(LightNode first_0, LightNode second_0, float3  p_9, float3  normal_1, uint child_0)
{
    float _S242 = importance(first_0, p_9, normal_1);
    float _S243 = importance(second_0, p_9, normal_1);
    float2  _S244 = make_float2 (_S242, _S243);
    float _S245 = _slang_vector_get_element(_S244, child_0) / (_S242 + _S243);
    bool _S246 = _slang_vector_get_element(_S244, child_0) > 0.0f;
    float _S247 = _slang_select(_S246, _S245,0.0f);
    return _S247;
}

__device__ float sphereDensity(float3  center_0, float radius_0, float3  p_10)
{
    float3  _S248 = center_0 - p_10;
    float _S249 = radius_0 * radius_0 / dot_0(_S248, _S248);
    bool _S250 = _S249 >= 1.0f;
    if(_S250)
    {
        return 0.07957746833562851f;
    }
    return (1.0f + (F32_sqrt((1.0f - _S249)))) / (6.28318548202514648f * _S249);
}

static __device__ float3  cross_0(float3  left_0, float3  right_0)
{
    float _S251 = left_0.y;
    float _S252 = right_0.z;
    float _S253 = left_0.z;
    float _S254 = right_0.y;
    float _S255 = right_0.x;
    float _S256 = left_0.x;
    return make_float3 (_S251 * _S252 - _S253 * _S254, _S253 * _S255 - _S256 * _S252, _S256 * _S254 - _S251 * _S255);
}

__device__ float solidAngle(float probability_0, float3  normal_2, float3  toward_0)
{
    return 2.0f * probability_0 * (F32_pow((length_0(toward_0)), (3.0f))) / (F32_abs((dot_0(normal_2, toward_0))));
}

static __device__ float lightPdf_0(float3  origin_3, float3  smooth_n_1, float3  start_5, uint j_0, float3  light_point_0)
{
    bool _S257 = j_0 == 4294967295U;
    if(_S257)
    {
        return 0.0f;
    }
    uint4  _S258 = (fcptLightTrail((j_0)));
    uint2  _S259 = uint2 {_S258.x, _S258.y};
    uint n_0 = 0U;
    uint2  trail_0 = _S259;
    float probability_1 = 1.0f;
    for(;;)
    {
        uint4  _S260 = (fcptLightNode((n_0)));
        if((_S260.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S261 = (fcptLightSecond((n_0)));
        uint _S262 = n_0 + 1U;
        LightNode _S263 = (fcptLightBounds((_S262)));
        LightNode _S264 = (fcptLightBounds((_S261)));
        uint _S265 = trail_0.x;
        uint _S266 = _S265 & 1U;
        float _S267 = childShare(_S263, _S264, origin_3, smooth_n_1, _S266);
        float probability_2 = probability_1 * _S267;
        bool _S268 = _S266 == 1U;
        uint _S269 = _slang_select(_S268, _S261,_S262);
        uint _S270 = trail_0.y;
        uint2  _S271 = make_uint2 ((_S265 >> 1U) | (_S270 << 31U), _S270 >> 1U);
        n_0 = _S269;
        trail_0 = _S271;
        probability_1 = probability_2;
    }
    bool _S272 = (fcptSlotLeaf((n_0), (j_0)));
    bool _S273 = !_S272;
    bool _S274;
    if(_S273)
    {
        _S274 = true;
    }
    else
    {
        LightNode _S275 = (fcptLightBounds((n_0)));
        float _S276 = importance(_S275, origin_3, smooth_n_1);
        _S274 = !(_S276 > 0.0f);
    }
    if(_S274)
    {
        _S274 = true;
    }
    else
    {
        bool _S277 = (dot_0(smooth_n_1, smooth_n_1)) > 0.0f;
        if(_S277)
        {
            _S274 = !((dot_0(smooth_n_1, light_point_0 - origin_3)) > 0.0f);
        }
        else
        {
            _S274 = false;
        }
    }
    if(_S274)
    {
        return 0.0f;
    }
    uint4  _S278 = (fcptLightNode((n_0)));
    bool _S279 = (_S278.x) == 2U;
    if(_S279)
    {
        uint _S280 = _S278.y;
        FKLight _S281 = (fcptLight((_S280)));
        FKLight _S282 = (fcptLight((_S280)));
        float _S283 = sphereDensity(_S281.position, _S282.variance, start_5);
        return probability_1 * _S283;
    }
    uint _S284 = _S278.y;
    uint _S285 = (fcptTriangleOffset((_S284)));
    Matrix<float, 3, 3>  _S286 = (fcptWorldTriangle((_S284), (_S285 + _S278.z)));
    float _S287 = solidAngle(probability_1, cross_0(_S286.rows[int(1)] - _S286.rows[int(0)], _S286.rows[int(2)] - _S286.rows[int(0)]), light_point_0 - start_5);
    return _S287;
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

static __device__ float random_0(uint * state_0)
{
    uint _S288 = hash(*state_0);
    *state_0 = _S288;
    return float((*state_0) >> int(8)) * 5.9604644775390625e-08f;
}

static __device__ Random Random_x24init_0(uint state_1, float value_0)
{
    Random _S289;
    (&_S289)->state = state_1;
    (&_S289)->value = value_0;
    return _S289;
}

__device__ Random pcg(uint state_2)
{
    uint _S290 = state_2;
    float value_1 = random_0(&_S290);
    return Random_x24init_0(_S290, value_1);
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
    uint2  _S291 = (fcptEnvironmentCdfSize());
    uint2  _S292 = _S291 - make_uint2 (1U, 0U);
    float2  _S293 = make_float2 ((F32_atan2((- dir_2.y), (dir_2.x))) / 6.28318548202514648f + 0.5f, (F32_acos((clamp_1(dir_2.z, -1.0f, 1.0f)))) / 3.14159274101257324f);
    float2  _S294 = make_float2 ((float)_S292.x, (float)_S292.y);
    float2  _S295 = _S293 * _S294;
    uint2  _S296 = make_uint2 ((uint)_S295.x, (uint)_S295.y);
    uint2  _S297 = min_0(_S296, _S292 - make_uint2 (1U));
    float4  _S298 = (fcptEnvironmentCdf((_S297)));
    float _S299 = _S298.y;
    uint _S300 = _S292.x;
    float4  _S301 = (fcptEnvironmentCdf((make_uint2 (_S300, _S297.y))));
    float _S302 = _S299 * _S301.y;
    return _S302 * float(_S300 * _S292.y) / (19.73921012878417969f * length_1(float2 {dir_2.x, dir_2.y}));
}

static __device__ float3  negate_0(float3  x_13)
{
    return - x_13;
}

static __device__ float sign_0(float e_1)
{
    float _S303;
    if(e_1 > 0.0f)
    {
        _S303 = 1.0f;
    }
    else
    {
        if(e_1 < 0.0f)
        {
            _S303 = -1.0f;
        }
        else
        {
            _S303 = 0.0f;
        }
    }
    return _S303;
}

struct AnisotropicFrame
{
    float3  tangent;
    float2  alphas;
};

static __device__ AnisotropicFrame AnisotropicFrame_x24init_0(float3  tangent_0, float2  alphas_0)
{
    AnisotropicFrame _S304;
    (&_S304)->tangent = tangent_0;
    (&_S304)->alphas = alphas_0;
    return _S304;
}

__device__ float3  tangentToWorld(float3  v_0, float3  n_1)
{
    float3  a_1 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S305 = (F32_abs((dot_0(n_1, a_1)))) > 0.9999847412109375f;
    float3  a_2;
    if(_S305)
    {
        float3  _S306 = make_float3 (1.0f, 0.0f, 0.0f);
        a_2 = _S306;
    }
    else
    {
        a_2 = a_1;
    }
    float3  _S307 = cross_0(n_1, a_2);
    float3  _S308 = ((((_S307)) * make_float3(rnorm3df(((_S307)).x, ((_S307)).y, ((_S307)).z))));
    float3  _S309 = cross_0(n_1, _S308);
    return make_float3 (v_0.x) * _S308 + make_float3 (v_0.y) * n_1 + make_float3 (v_0.z) * _S309;
}

__device__ AnisotropicFrame anisotropicFrame(BSDFMaterial material_0, float3  n_i_0)
{
    float _S310 = material_0.roughness;
    float _S311 = _S310 * _S310;
    bool _S312 = (material_0.anisotropy) == 0.0f;
    bool _S313;
    if(_S312)
    {
        _S313 = true;
    }
    else
    {
        _S313 = !(_S311 > 0.0f);
    }
    if(_S313)
    {
        return AnisotropicFrame_x24init_0(make_float3 (0.0f), make_float2 (0.0f));
    }
    float3  _S314 = material_0.tangent - n_i_0 * make_float3 (dot_0(n_i_0, material_0.tangent));
    float3  _S315 = tangentToWorld(make_float3 (1.0f, 0.0f, 0.0f), n_i_0);
    bool _S316 = (dot_0(_S314, _S314)) > 0.0f;
    float3  _S317 = _slang_select(_S316, _S314,_S315);
    float3  _S318 = ((((_S317)) * make_float3(rnorm3df(((_S317)).x, ((_S317)).y, ((_S317)).z))));
    float _S319 = 6.28318548202514648f * material_0.anisotropic_rotation;
    float _S320 = (F32_sqrt((1.0f - 0.89999997615814209f * (F32_abs((material_0.anisotropy))))));
    float _S321 = 1.0f / _S320;
    bool _S322 = (material_0.anisotropy) < 0.0f;
    float _S323 = _slang_select(_S322, _S321,_S320);
    return AnisotropicFrame_x24init_0(_S318 * make_float3 ((F32_cos((_S319)))) + cross_0(n_i_0, _S318) * make_float3 ((F32_sin((_S319)))), make_float2 (_S311 / _S323, _S311 * _S323));
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
    BSDFLobes _S324;
    (&_S324)->v_dot_h = v_dot_h_0;
    (&_S324)->n_dot_h = n_dot_h_0;
    (&_S324)->refracted = refracted_1;
    (&_S324)->F = F_0;
    (&_S324)->F_greyscale = F_greyscale_0;
    (&_S324)->reflect_weight = reflect_weight_0;
    (&_S324)->diffuse_weight = diffuse_weight_0;
    (&_S324)->refract_weight = refract_weight_0;
    (&_S324)->p_diffuse = p_diffuse_0;
    (&_S324)->p_reflect = p_reflect_0;
    (&_S324)->p_refract = p_refract_0;
    (&_S324)->translucent_share = translucent_share_0;
    (&_S324)->sheen = sheen_0;
    (&_S324)->p_sheen_velvet = p_sheen_velvet_0;
    (&_S324)->view = view_0;
    (&_S324)->tangent = tangent_1;
    (&_S324)->alphas = alphas_1;
    (&_S324)->visible = visible_0;
    (&_S324)->p_toon = p_toon_0;
    (&_S324)->toon = toon_0;
    (&_S324)->toon_a = toon_a_0;
    (&_S324)->toon_s = toon_s_0;
    (&_S324)->toon_b = toon_b_0;
    (&_S324)->toon_glossy = toon_glossy_0;
    (&_S324)->toon_norm = toon_norm_0;
    (&_S324)->toon_view = toon_view_0;
    (&_S324)->toon_axis = toon_axis_0;
    return _S324;
}

__device__ float rgb_to_greyscale(float3  rgb_0)
{
    return dot_0(rgb_0, make_float3 (0.29899999499320984f, 0.58700001239776611f, 0.11400000005960464f));
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
    float3  _S325 = make_float3 (alpha_0 * Ve_0.x, alpha_0 * Ve_0.y, Ve_0.z);
    float3  _S326 = ((((_S325)) * make_float3(rnorm3df(((_S325)).x, ((_S325)).y, ((_S325)).z))));
    float _S327 = _S326.x;
    float _S328 = _S326.y;
    float _S329 = _S327 * _S327 + _S328 * _S328;
    float3  _S330;
    if(_S329 > 0.0f)
    {
        float3  _S331 = make_float3 (- _S328, _S327, 0.0f);
        float _S332 = (rsqrtf((_S329)));
        _S330 = _S331 * make_float3 (_S332);
    }
    else
    {
        _S330 = make_float3 (1.0f, 0.0f, 0.0f);
    }
    float3  _S333 = cross_0(_S326, _S330);
    float _S334 = (F32_sqrt((U1_0)));
    float _S335 = 6.28318548202514648f * U2_0;
    float _S336 = _S334 * (F32_cos((_S335)));
    float t2_0 = _S334 * (F32_sin((_S335)));
    float _S337 = 0.5f * (1.0f + _S326.z);
    float t2_1 = (1.0f - _S337) * (F32_sqrt(((F32_max((0.0f), (1.0f - _S336 * _S336)))))) + _S337 * t2_0;
    float3  _S338 = make_float3 (_S336) * _S330 + make_float3 (t2_1) * _S333;
    float _S339 = unshared_0(_S336);
    float _S340 = unshared_0(_S336);
    float3  _S341 = _S338 + make_float3 ((F32_sqrt(((F32_max((0.0f), (1.0f - _S339 * _S340 - t2_1 * t2_1))))))) * _S326;
    float3  _S342 = make_float3 (alpha_0 * _S341.x, alpha_0 * _S341.y, (F32_max((0.0f), (_S341.z))));
    float3  _S343 = ((((_S342)) * make_float3(rnorm3df(((_S342)).x, ((_S342)).y, ((_S342)).z))));
    return _S343;
}

__device__ float3  worldToTangent(float3  v_1, float3  n_3)
{
    float3  a_3 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S344 = (F32_abs((dot_0(n_3, a_3)))) > 0.9999847412109375f;
    float3  a_4;
    if(_S344)
    {
        float3  _S345 = make_float3 (1.0f, 0.0f, 0.0f);
        a_4 = _S345;
    }
    else
    {
        a_4 = a_3;
    }
    float3  _S346 = cross_0(n_3, a_4);
    float3  _S347 = ((((_S346)) * make_float3(rnorm3df(((_S346)).x, ((_S346)).y, ((_S346)).z))));
    float3  _S348 = cross_0(n_3, _S347);
    return make_float3 (dot_0(v_1, _S347), dot_0(v_1, n_3), dot_0(v_1, _S348));
}

__device__ __forceinline__ float3  sampleHalfVector(float3  v_2, float3  n_i_1, float alpha_1, AnisotropicFrame frame_0, uint * random_state_2)
{
    Random _S349 = pcg(*random_state_2);
    Random _S350 = pcg(_S349.state);
    *random_state_2 = _S350.state;
    float _S351 = frame_0.alphas.x;
    bool _S352 = _S351 > 0.0f;
    if(_S352)
    {
        float3  _S353 = anisotropicLocal(v_2, frame_0.tangent, n_i_1);
        float _S354 = frame_0.alphas.y;
        float3  _S355 = make_float3 (_S351 * _S353.x, _S354 * _S353.y, _S353.z);
        float3  _S356 = ((((_S355)) * make_float3(rnorm3df(((_S355)).x, ((_S355)).y, ((_S355)).z))));
        float3  _S357 = sampleGGXVNDF(_S356, 1.0f, _S349.value, _S350.value);
        float3  _S358 = make_float3 (_S351 * _S357.x, _S354 * _S357.y, _S357.z);
        float3  _S359 = ((((_S358)) * make_float3(rnorm3df(((_S358)).x, ((_S358)).y, ((_S358)).z))));
        return make_float3 (_S359.x) * frame_0.tangent + make_float3 (_S359.y) * cross_0(n_i_1, frame_0.tangent) + make_float3 (_S359.z) * n_i_1;
    }
    float3  _S360 = worldToTangent(v_2, n_i_1);
    float3  _S361 = sampleGGXVNDF(float3 {_S360.x, _S360.z, _S360.y}, alpha_1, _S349.value, _S350.value);
    float3  _S362 = float3 {_S361.x, _S361.z, _S361.y};
    float3  _S363 = tangentToWorld(_S362, n_i_1);
    return _S363;
}

__device__ float3  sampledHalf(float3  in_dir_0, float3  n_4, BSDFMaterial material_1, uint random_state_3, AnisotropicFrame frame_1)
{
    uint state_3 = random_state_3;
    float3  _S364 = negate_0(in_dir_0);
    float _S365 = sign_0(dot_0(n_4, _S364));
    float _S366 = material_1.roughness;
    float3  _S367 = sampleHalfVector(_S364, n_4 * make_float3 (_S365), _S366 * _S366, frame_1, &state_3);
    return _S367;
}

__device__ float3  refractedHalf(float3  in_dir_1, float3  out_dir_0, float3  n_5, float eta_i_0, float eta_o_0)
{
    float3  _S368 = negate_0(in_dir_1);
    float3  _S369 = negate_0(make_float3 (eta_i_0) * _S368 + make_float3 (eta_o_0) * out_dir_0);
    float3  _S370 = ((((_S369)) * make_float3(rnorm3df(((_S369)).x, ((_S369)).y, ((_S369)).z))));
    float _S371 = sign_0(dot_0(n_5, _S368));
    float _S372 = sign_0(dot_0(_S369, n_5 * make_float3 (_S371)));
    return _S370 * make_float3 (_S372);
}

__device__ float3  reflectedHalf(float3  in_dir_2, float3  out_dir_1)
{
    float3  _S373 = negate_0(in_dir_2);
    float3  _S374 = _S373 + out_dir_1;
    float3  _S375 = ((((_S374)) * make_float3(rnorm3df(((_S374)).x, ((_S374)).y, ((_S374)).z))));
    return _S375;
}

static __device__ float3  refract_0(float3  i_5, float3  n_6, float eta_0)
{
    float _S376 = dot_0(n_6, i_5);
    float _S377 = 1.0f - eta_0 * eta_0 * (1.0f - _S376 * _S376);
    if(_S377 < 0.0f)
    {
        return make_float3 (0.0f);
    }
    return make_float3 (eta_0) * i_5 - make_float3 (eta_0 * _S376 + (F32_sqrt((_S377)))) * n_6;
}

__device__ float fresnel(float cos_theta_0, float eta_i_1, float eta_o_1)
{
    float _S378 = (F32_sqrt(((F32_max((0.0f), (1.0f - cos_theta_0 * cos_theta_0))))));
    float _S379 = eta_i_1 / eta_o_1 * _S378;
    bool _S380 = _S379 < 1.0f;
    float kr_0;
    if(_S380)
    {
        float _S381 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S379 * _S379))))));
        float _S382 = eta_o_1 * cos_theta_0;
        float _S383 = eta_i_1 * _S381;
        float _S384 = (_S382 - _S383) / (_S382 + _S383);
        float _S385 = eta_i_1 * cos_theta_0;
        float _S386 = eta_o_1 * _S381;
        float _S387 = (_S385 - _S386) / (_S385 + _S386);
        float _S388 = (_S384 * _S384 + _S387 * _S387) / 2.0f;
        kr_0 = _S388;
    }
    else
    {
        kr_0 = 1.0f;
    }
    return kr_0;
}

__device__ static const FixedArray<float, 576>  SHEEN_ALBEDO_0 = { {
    0.62089997529983521f, 0.49450001120567322f, 0.38080000877380371f, 0.28439998626708984f, 0.20010000467300415f, 0.1257999986410141f, 0.05990000069141388f, 0.00109999999403954f, -0.05160000175237656f, -0.09889999777078629f, -0.14159999787807465f, -0.18009999394416809f, -0.2151000052690506f, -0.24690000712871552f, -0.27590000629425049f, -0.30230000615119934f, -0.32649999856948853f, -0.34860000014305115f, -0.36890000104904175f, -0.38760000467300415f, -0.40479999780654907f, -0.42070001363754272f, -0.43439999222755432f, -0.44929999113082886f, 0.59240001440048218f, 0.47049999237060547f, 0.35899999737739563f, 0.26440000534057617f, 0.18150000274181366f, 0.10830000042915344f, 0.04329999908804893f, -0.01470000017434359f, -0.066600002348423f, -0.11339999735355377f, -0.15549999475479126f, -0.19370000064373016f, -0.22820000350475311f, -0.25970000028610229f, -0.28830000758171082f, -0.31450000405311584f, -0.33840000629425049f, -0.36039999127388f, -0.38049998879432678f, -0.39899998903274536f, -0.41609999537467957f, -0.43180000782012939f, -0.44539999961853027f, -0.46070000529289246f, 0.5228000283241272f, 0.40599998831748962f, 0.30259999632835388f, 0.21250000596046448f, 0.13330000638961792f, 0.06319999694824219f, 0.00069999997504056f, -0.05510000139474869f, -0.10520000010728836f, -0.15039999783039093f, -0.19120000302791595f, -0.2281000018119812f, -0.26170000433921814f, -0.2921999990940094f, -0.31999999284744263f, -0.34549999237060547f, -0.36869999766349792f, -0.39010000228881836f, -0.40970000624656677f, -0.42770001292228699f, -0.44440001249313354f, -0.45969998836517334f, -0.47389999032020569f, -0.48800000548362732f, 0.43569999933242798f, 0.32769998908042908f, 0.23160000145435333f, 0.14730000495910645f, 0.07280000299215317f, 0.00659999996423721f, -0.05260000005364418f, -0.10559999942779541f, -0.1534000039100647f, -0.19650000333786011f, -0.23549999296665192f, -0.27090001106262207f, -0.30309998989105225f, -0.33239999413490295f, -0.35920000076293945f, -0.38359999656677246f, -0.40599998831748962f, -0.42660000920295715f, -0.44549998641014099f, -0.46290001273155212f, -0.47900000214576721f, -0.49380001425743103f, -0.50749999284744263f, -0.52090001106262207f, 0.33129999041557312f, 0.23459999263286591f, 0.14740000665187836f, 0.07010000199079514f, 0.00139999995008111f, -0.0601000003516674f, -0.11519999802112579f, -0.16490000486373901f, -0.20970000326633453f, -0.25029999017715454f, -0.28720000386238098f, -0.3206000030040741f, -0.35109999775886536f, -0.37900000810623169f, -0.40439999103546143f, -0.42770001292228699f, -0.44900000095367432f, -0.46869999170303345f, -0.48669999837875366f, -0.5033000111579895f, -0.5187000036239624f, -0.53289997577667236f, -0.54600000381469727f, -0.55860000848770142f, 0.21109999716281891f, 0.12790000438690186f, 0.0511000007390976f, -0.01769999973475933f, -0.07970000058412552f, -0.13549999892711639f, -0.18600000441074371f, -0.23160000145435333f, -0.27300000190734863f, -0.31069999933242798f, -0.34490001201629639f, -0.37619999051094055f, -0.40470001101493835f, -0.43070000410079956f, -0.4546000063419342f, -0.476500004529953f, -0.49660000205039978f, -0.51510000228881836f, -0.53210002183914185f, -0.54780000448226929f, -0.56230002641677856f, -0.57580000162124634f, -0.58819997310638428f, -0.60009998083114624f, 0.0754999965429306f, 0.00800000037997961f, -0.05649999901652336f, -0.11569999903440475f, -0.16979999840259552f, -0.21920000016689301f, -0.26420000195503235f, -0.3052000105381012f, -0.34270000457763672f, -0.37689998745918274f, -0.40819999575614929f, -0.43680000305175781f, -0.46299999952316284f, -0.48710000514984131f, -0.50910001993179321f, -0.52939999103546143f, -0.54809999465942383f, -0.56529998779296875f, -0.5810999870300293f, -0.59570002555847168f, -0.60930001735687256f, -0.6218000054359436f, -0.63340002298355103f, -0.6445000171661377f, -0.07569999992847443f, -0.12489999830722809f, -0.17569999396800995f, -0.22380000352859497f, -0.26890000700950623f, -0.3107999861240387f, -0.34959998726844788f, -0.38539999723434448f, -0.41839998960494995f, -0.44870001077651978f, -0.47659999132156372f, -0.50230002403259277f, -0.52590000629425049f, -0.54759997129440308f, -0.56760001182556152f, -0.58600002527236938f, -0.6029999852180481f, -0.61870002746582031f, -0.63330000638961792f, -0.64670002460479736f, -0.6590999960899353f, -0.67059999704360962f, -0.68129998445510864f, -0.69160002470016479f, -0.24320000410079956f, -0.27120000123977661f, -0.30640000104904175f, -0.34209999442100525f, -0.37700000405311584f, -0.41060000658035278f, -0.44229999184608459f, -0.47220000624656677f, -0.50010001659393311f, -0.52600002288818359f, -0.55010002851486206f, -0.57239997386932373f, -0.59310001134872437f, -0.61220002174377441f, -0.62989997863769531f, -0.64620000123977661f, -0.66140002012252808f, -0.6754000186920166f, -0.68839997053146362f, -0.70039999485015869f, -0.71160000562667847f, -0.72200000286102295f, -0.73159998655319214f, -0.74089998006820679f, -0.42809998989105225f, -0.43149998784065247f, -0.44920000433921814f, -0.47099998593330383f, -0.49459999799728394f, -0.51880002021789551f, -0.54269999265670776f, -0.5658000111579895f, -0.58799999952316284f, -0.60900002717971802f, -0.62870001792907715f, -0.64730000495910645f, -0.6646999716758728f, -0.68080002069473267f, -0.69590002298355103f, -0.70999997854232788f, -0.72299998998641968f, -0.73509997129440308f, -0.74639999866485596f, -0.75690001249313354f, -0.76670002937316895f, -0.77579998970031738f, -0.78430002927780151f, -0.79250001907348633f, -0.63230001926422119f, -0.60759997367858887f, -0.60519999265670776f, -0.61119997501373291f, -0.62209999561309814f, -0.63580000400543213f, -0.65090000629425049f, -0.66659998893737793f, -0.68239998817443848f, -0.69789999723434448f, -0.71289998292922974f, -0.7271999716758728f, -0.74089998006820679f, -0.75379997491836548f, -0.76590001583099365f, -0.77740001678466797f, -0.78810000419616699f, -0.79809999465942383f, -0.80750000476837158f, -0.81629997491836548f, -0.82450002431869507f, -0.83209997415542603f, -0.83929997682571411f, -0.84630000591278076f, -0.85790002346038818f, -0.80119997262954712f, -0.77600002288818359f, -0.76410001516342163f, -0.76059997081756592f, -0.76239997148513794f, -0.76770001649856567f, -0.7750999927520752f, -0.78380000591278076f, -0.79309999942779541f, -0.80279999971389771f, -0.8125f, -0.82200002670288086f, -0.8312000036239624f, -0.8400999903678894f, -0.84859997034072876f, -0.85670000314712524f, -0.86440002918243408f, -0.8716999888420105f, -0.87849998474121094f, -0.88499999046325684f, -0.89099997282028198f, -0.89670002460479736f, -0.90240001678466797f, -1.10769999027252197f, -1.01429998874664307f, -0.96329998970031738f, -0.93110001087188721f, -0.91140002012252808f, -0.89990001916885376f, -0.89410001039505005f, -0.89219999313354492f, -0.89289999008178711f, -0.89539998769760132f, -0.89910000562667847f, -0.9035000205039978f, -0.90850001573562622f, -0.91360002756118774f, -0.9189000129699707f, -0.92419999837875366f, -0.92940002679824829f, -0.93440002202987671f, -0.93930000066757202f, -0.9440000057220459f, -0.94849997758865356f, -0.95270001888275146f, -0.95679998397827148f, -0.96100002527236938f, -1.38499999046325684f, -1.24950003623962402f, -1.16919994354248047f, -1.11409997940063477f, -1.07599997520446777f, -1.0494999885559082f, -1.03129994869232178f, -1.01880002021789551f, -1.01059997081756592f, -1.00539994239807129f, -1.00240004062652588f, -1.00109994411468506f, -1.0009000301361084f, -1.00150001049041748f, -1.00279998779296875f, -1.00440001487731934f, -1.00639998912811279f, -1.00849997997283936f, -1.01069998741149902f, -1.0130000114440918f, -1.01530003547668457f, -1.01750004291534424f, -1.01979994773864746f, -1.02230000495910645f, -1.69420003890991211f, -1.51020002365112305f, -1.39649999141693115f, -1.31540000438690186f, -1.2565000057220459f, -1.21309995651245117f, -1.18079996109008789f, -1.15649998188018799f, -1.13820004463195801f, -1.12440001964569092f, -1.11389994621276855f, -1.10599994659423828f, -1.10010004043579102f, -1.09560000896453857f, -1.09230005741119385f, -1.09000003337860107f, -1.08829998970031738f, -1.08710002899169922f, -1.08640003204345703f, -1.08599996566772461f, -1.08580005168914795f, -1.08580005168914795f, -1.08599996566772461f, -1.0866999626159668f, -2.04089999198913574f, -1.80079996585845947f, -1.64869999885559082f, -1.53789997100830078f, -1.45539999008178711f, -1.392799973487854f, -1.34459996223449707f, -1.30700004100799561f, -1.27730000019073486f, -1.25380003452301025f, -1.23489999771118164f, -1.21959996223449707f, -1.20720005035400391f, -1.19700002670288086f, -1.18859994411468506f, -1.18169999122619629f, -1.17589998245239258f, -1.17100000381469727f, -1.16690003871917725f, -1.16349995136260986f, -1.16059994697570801f, -1.15810000896453857f, -1.15600001811981201f, -1.15470004081726074f, -2.43269991874694824f, -2.12700009346008301f, -1.93060004711151123f, -1.78569996356964111f, -1.67610001564025879f, -1.59159994125366211f, -1.52530002593994141f, -1.47249996662139893f, -1.4299999475479126f, -1.39540004730224609f, -1.36689996719360352f, -1.3432999849319458f, -1.32350003719329834f, -1.30680000782012939f, -1.29270005226135254f, -1.28059995174407959f, -1.27009999752044678f, -1.26110005378723145f, -1.25329995155334473f, -1.24639999866485596f, -1.24039995670318604f, -1.23500001430511475f, -1.23029994964599609f, -1.22669994831085205f, -2.87989997863769531f, -2.49659991264343262f, -2.24860000610351562f, -2.06410002708435059f, -1.92330002784729004f, -1.8135000467300415f, -1.72640001773834229f, -1.65620005130767822f, -1.59899997711181641f, -1.55169999599456787f, -1.51230001449584961f, -1.47909998893737793f, -1.45099997520446777f, -1.42690002918243408f, -1.40610003471374512f, -1.3881000280380249f, -1.37240004539489746f, -1.35860002040863037f, -1.34640002250671387f, -1.33570003509521484f, -1.32609999179840088f, -1.31749999523162842f, -1.30980002880096436f, -1.30359995365142822f, -3.39750003814697266f, -2.92090010643005371f, -2.6119999885559082f, -2.38100004196166992f, -2.20359992980957031f, -2.0643000602722168f, -1.95290005207061768f, -1.86249995231628418f, -1.7882000207901001f, -1.72619998455047607f, -1.67410004138946533f, -1.62989997863769531f, -1.59200000762939453f, -1.55929994583129883f, -1.53090000152587891f, -1.50610005855560303f, -1.48430001735687256f, -1.46500003337860107f, -1.44790005683898926f, -1.43260002136230469f, -1.4189000129699707f, -1.40649998188018799f, -1.39540004730224609f, -1.38629996776580811f, -4.00810003280639648f, -3.41639995574951172f, -3.03419995307922363f, -2.74749994277954102f, -2.52649998664855957f, -2.35209989547729492f, -2.21210002899169922f, -2.09780001640319824f, -2.00309991836547852f, -1.92390000820159912f, -1.85679996013641357f, -1.7994999885559082f, -1.75020003318786621f, -1.70739996433258057f, -1.66999995708465576f, -1.6371999979019165f, -1.60819995403289795f, -1.58239996433258057f, -1.55949997901916504f, -1.53890001773834229f, -1.52040004730224609f, -1.50370001792907715f, -1.48860001564025879f, -1.47609996795654297f, -4.7491002082824707f, -4.00920009613037109f, -3.53640007972717285f, -3.18140006065368652f, -2.90700006484985352f, -2.69000005722045898f, -2.5150001049041748f, -2.37150001525878906f, -2.25230002403259277f, -2.15199995040893555f, -2.06680011749267578f, -1.99370002746582031f, -1.93060004711151123f, -1.87559998035430908f, -1.82739996910095215f, -1.78489995002746582f, -1.74730002880096436f, -1.71379995346069336f, -1.68389999866485596f, -1.65699994564056396f, -1.63279998302459717f, -1.6109999418258667f, -1.59109997749328613f, -1.5746999979019165f, -5.68760013580322266f, -4.74030017852783203f, -4.15259981155395508f, -3.71110010147094727f, -3.36949992179870605f, -3.09859991073608398f, -2.87960004806518555f, -2.69939994812011719f, -2.54920005798339844f, -2.42239999771118164f, -2.31439995765686035f, -2.22140002250671387f, -2.1408998966217041f, -2.07069993019104004f, -2.00900006294250488f, -1.95459997653961182f, -1.90629994869232178f, -1.86329996585845947f, -1.82480001449584961f, -1.79030001163482666f, -1.75919997692108154f, -1.73099994659423828f, -1.70550000667572021f, -1.68429994583129883f, -6.68940019607543945f, -5.34350013732910156f, -4.86259984970092773f, -4.34409999847412109f, -3.93390011787414551f, -3.60269999504089355f, -3.33100008964538574f, -3.10509991645812988f, -2.91510009765625f, -2.75390005111694336f, -2.61590003967285156f, -2.49690008163452148f, -2.3935999870300293f, -2.30340003967285156f, -2.22420001029968262f, -2.15440011024475098f, -2.09240007400512695f, -2.03730010986328125f, -1.98800003528594971f, -1.94369995594024658f, -1.90390002727508545f, -1.86790001392364502f, -1.83480000495910645f, -1.8078000545501709f, -9.69550037384033203f, -7.62489986419677734f, -6.61070013046264648f, -5.72329998016357422f, -5.04829978942871094f, -4.52129983901977539f, -4.10120010375976562f, -3.76049995422363281f, -3.48009991645812988f, -3.24640011787414551f, -3.04959988594055176f, -2.88229990005493164f, -2.738800048828125f, -2.61479997634887695f, -2.50699996948242188f, -2.41269993782043457f, -2.32960009574890137f, -2.25620007514953613f, -2.19090008735656738f, -2.13269996643066406f, -2.08049988746643066f, -2.03349995613098145f, -1.99049997329711914f, -1.95369994640350342f
} };
__device__ static const FixedArray<float, 576>  VELVET_ALBEDO_0 = { {
    1.00383996963500977f, 1.00428998470306396f, 1.00356996059417725f, 1.00303995609283447f, 1.00261998176574707f, 1.00229001045227051f, 1.00198996067047119f, 1.00171005725860596f, 1.00144004821777344f, 1.00120997428894043f, 1.00102996826171875f, 1.00092005729675293f, 1.00088000297546387f, 1.0009000301361084f, 1.00095999240875244f, 1.00106000900268555f, 1.00115001201629639f, 1.00124001502990723f, 1.001289963722229f, 1.0013200044631958f, 1.00133001804351807f, 1.00133001804351807f, 1.0013200044631958f, 1.00129997730255127f, 0.99086397886276245f, 0.9934689998626709f, 0.99439799785614014f, 0.99513500928878784f, 0.99574202299118042f, 0.9962649941444397f, 0.99671798944473267f, 0.99709898233413696f, 0.997406005859375f, 0.99764800071716309f, 0.99783498048782349f, 0.99798601865768433f, 0.99811899662017822f, 0.99825501441955566f, 0.99840497970581055f, 0.99857097864151001f, 0.99874699115753174f, 0.99892902374267578f, 0.9990919828414917f, 0.99923902750015259f, 0.99936902523040771f, 0.99948000907897949f, 0.99957501888275146f, 0.99965798854827881f, 0.94088798761367798f, 0.95128101110458374f, 0.95866602659225464f, 0.96450901031494141f, 0.96921002864837646f, 0.973052978515625f, 0.97623497247695923f, 0.97890102863311768f, 0.98115700483322144f, 0.98308497667312622f, 0.98474901914596558f, 0.98619699478149414f, 0.98746699094772339f, 0.98858797550201416f, 0.98958402872085571f, 0.99047297239303589f, 0.99127000570297241f, 0.99198299646377563f, 0.99262100458145142f, 0.99318897724151611f, 0.99372398853302002f, 0.99426800012588501f, 0.99475300312042236f, 0.99514400959014893f, 0.86131101846694946f, 0.88463401794433594f, 0.90212702751159668f, 0.91595500707626343f, 0.92708200216293335f, 0.93617302179336548f, 0.94370102882385254f, 0.95000702142715454f, 0.95534700155258179f, 0.9599120020866394f, 0.96384698152542114f, 0.96726799011230469f, 0.97026199102401733f, 0.97289901971817017f, 0.97523599863052368f, 0.97731602191925049f, 0.97917401790618896f, 0.98083901405334473f, 0.98233497142791748f, 0.98368102312088013f, 0.98489302396774292f, 0.98598498106002808f, 0.98697298765182495f, 0.98787301778793335f, 0.75306302309036255f, 0.79328000545501709f, 0.82418698072433472f, 0.84881901741027832f, 0.86874997615814209f, 0.88506197929382324f, 0.89858502149581909f, 0.9099239706993103f, 0.91952997446060181f, 0.9277459979057312f, 0.93483197689056396f, 0.94099199771881104f, 0.9463840126991272f, 0.95113497972488403f, 0.95534402132034302f, 0.95908999443054199f, 0.9624369740486145f, 0.96543699502944946f, 0.96813201904296875f, 0.97055697441101074f, 0.97274202108383179f, 0.97471201419830322f, 0.97649002075195312f, 0.97809398174285889f, 0.62183499336242676f, 0.68052101135253906f, 0.72705197334289551f, 0.76452702283859253f, 0.79505598545074463f, 0.82021200656890869f, 0.84120297431945801f, 0.85885602235794067f, 0.87384098768234253f, 0.88667500019073486f, 0.89775800704956055f, 0.90739899873733521f, 0.91584599018096924f, 0.92329102754592896f, 0.929889976978302f, 0.93576502799987793f, 0.94101500511169434f, 0.94572198390960693f, 0.94994997978210449f, 0.95375597476959229f, 0.95718497037887573f, 0.9602770209312439f, 0.96306699514389038f, 0.96558600664138794f, 0.47742500901222229f, 0.5522189736366272f, 0.61415499448776245f, 0.66520899534225464f, 0.70744901895523071f, 0.74262100458145142f, 0.77213901281356812f, 0.7971159815788269f, 0.81841897964477539f, 0.83673000335693359f, 0.85258400440216064f, 0.86640900373458862f, 0.87854301929473877f, 0.88924998044967651f, 0.89874798059463501f, 0.90721100568771362f, 0.91477799415588379f, 0.92156499624252319f, 0.92766499519348145f, 0.93315702676773071f, 0.9381060004234314f, 0.94257098436355591f, 0.94660097360610962f, 0.95023900270462036f, 0.33539599180221558f, 0.41908100247383118f, 0.49247598648071289f, 0.55531197786331177f, 0.60879099369049072f, 0.65415602922439575f, 0.69274699687957764f, 0.72571200132369995f, 0.75402498245239258f, 0.77849102020263672f, 0.79976201057434082f, 0.81836599111557007f, 0.83474302291870117f, 0.84922301769256592f, 0.86208897829055786f, 0.87356698513031006f, 0.88384199142456055f, 0.89306402206420898f, 0.90135800838470459f, 0.9088289737701416f, 0.91556602716445923f, 0.92164498567581177f, 0.92713397741317749f, 0.93208998441696167f, 0.21194499731063843f, 0.29365798830986023f, 0.37110498547554016f, 0.44143900275230408f, 0.5036969780921936f, 0.55801302194595337f, 0.60521197319030762f, 0.64614301919937134f, 0.68169897794723511f, 0.71268302202224731f, 0.73979401588439941f, 0.76362699270248413f, 0.78467601537704468f, 0.80335497856140137f, 0.82000100612640381f, 0.83488202095031738f, 0.8482239842414856f, 0.86021500825881958f, 0.87101101875305176f, 0.88074499368667603f, 0.88952797651290894f, 0.89745801687240601f, 0.90461999177932739f, 0.91109001636505127f, 0.11949499696493149f, 0.18745699524879456f, 0.25997200608253479f, 0.33120998740196228f, 0.39773499965667725f, 0.45832300186157227f, 0.51248997449874878f, 0.56048798561096191f, 0.6028980016708374f, 0.64032697677612305f, 0.67339599132537842f, 0.70268499851226807f, 0.72870397567749023f, 0.75189602375030518f, 0.77263599634170532f, 0.7912449836730957f, 0.80796998739242554f, 0.82303100824356079f, 0.8366129994392395f, 0.84887397289276123f, 0.85994899272918701f, 0.86995697021484375f, 0.87900298833847046f, 0.88717901706695557f, 0.05942929908633232f, 0.10839699953794479f, 0.16785700619220734f, 0.23236599564552307f, 0.29767501354217529f, 0.36022999882698059f, 0.41842898726463318f, 0.47170799970626831f, 0.5198180079460144f, 0.56301301717758179f, 0.60171198844909668f, 0.63635998964309692f, 0.66739702224731445f, 0.69524997472763062f, 0.720287024974823f, 0.74283498525619507f, 0.76317602396011353f, 0.78155702352523804f, 0.79817098379135132f, 0.81319701671600342f, 0.8267899751663208f, 0.83908802270889282f, 0.85021400451660156f, 0.86027902364730835f, 0.02584660053253174f, 0.05619670078158379f, 0.09917669743299484f, 0.15162299573421478f, 0.20941600203514099f, 0.26902499794960022f, 0.32757499814033508f, 0.38318398594856262f, 0.43501600623130798f, 0.48271399736404419f, 0.52620798349380493f, 0.56570100784301758f, 0.60149699449539185f, 0.63392102718353271f, 0.66328197717666626f, 0.68988502025604248f, 0.7139970064163208f, 0.7358660101890564f, 0.75570398569107056f, 0.77369099855422974f, 0.78999698162078857f, 0.80477499961853027f, 0.81816202402114868f, 0.83028298616409302f, 0.00968609005212784f, 0.02591750025749207f, 0.05318830162286758f, 0.09121809899806976f, 0.13777700066566467f, 0.18976299464702606f, 0.244159996509552f, 0.29880800843238831f, 0.35169300436973572f, 0.40180501341819763f, 0.44872200489044189f, 0.49213200807571411f, 0.53206497430801392f, 0.5686650276184082f, 0.60214298963546753f, 0.63272500038146973f, 0.66062301397323608f, 0.68605399131774902f, 0.70922297239303589f, 0.73031198978424072f, 0.74948400259017944f, 0.76689702272415161f, 0.78270000219345093f, 0.79702901840209961f, 0.00303822988644242f, 0.01048239972442389f, 0.02568300068378448f, 0.05025380104780197f, 0.08408640325069427f, 0.12561400234699249f, 0.17249999940395355f, 0.22232000529766083f, 0.27309399843215942f, 0.32321798801422119f, 0.37149098515510559f, 0.4173240065574646f, 0.4603630006313324f, 0.50043797492980957f, 0.53755801916122437f, 0.57181298732757568f, 0.60333001613616943f, 0.63226902484893799f, 0.65877401828765869f, 0.68301999568939209f, 0.70514601469039917f, 0.7253040075302124f, 0.74363899230957031f, 0.76029098033905029f, 0.00076204299693927f, 0.00361976004205644f, 0.0110037000849843f, 0.02512970007956028f, 0.04727460071444511f, 0.07745999842882156f, 0.11460299789905548f, 0.1569570004940033f, 0.20258499681949615f, 0.24971699714660645f, 0.29707801342010498f, 0.34340900182723999f, 0.38799500465393066f, 0.43043500185012817f, 0.47039699554443359f, 0.50777101516723633f, 0.54253697395324707f, 0.57473397254943848f, 0.60444700717926025f, 0.63179397583007812f, 0.65686798095703125f, 0.67979699373245239f, 0.70071202516555786f, 0.71974599361419678f, 0.00014345299859997f, 0.00102306995540857f, 0.00407376000657678f, 0.01122699957340956f, 0.02423799969255924f, 0.04415180161595345f, 0.07109060138463974f, 0.10433399677276611f, 0.14259399473667145f, 0.184347003698349f, 0.2281080037355423f, 0.27265200018882751f, 0.31696400046348572f, 0.36016398668289185f, 0.40178799629211426f, 0.44139501452445984f, 0.47875601053237915f, 0.51375597715377808f, 0.54635101556777954f, 0.57658302783966064f, 0.60447400808334351f, 0.63009101152420044f, 0.65352898836135864f, 0.67488902807235718f, 0.00001858420000644f, 0.0002227969962405f, 0.00124967005103827f, 0.00435766018927097f, 0.01113030035048723f, 0.0229835007339716f, 0.04079980030655861f, 0.06477940082550049f, 0.09447769820690155f, 0.12897300720214844f, 0.16708999872207642f, 0.20760199427604675f, 0.24936899542808533f, 0.29154899716377258f, 0.3332040011882782f, 0.37377101182937622f, 0.41274300217628479f, 0.44977998733520508f, 0.4846780002117157f, 0.51733100414276123f, 0.54769200086593628f, 0.57572799921035767f, 0.6014779806137085f, 0.62501102685928345f, 1.46482000218384201e-06f, 0.00003429050047998f, 0.0002985020109918f, 0.00140504003502429f, 0.00443577999249101f, 0.01069260016083717f, 0.02133879996836185f, 0.0371410995721817f, 0.05836030095815659f, 0.08476380258798599f, 0.11572299897670746f, 0.1503559947013855f, 0.18766500055789948f, 0.22665500640869141f, 0.26647698879241943f, 0.30632400512695312f, 0.34550899267196655f, 0.38344401121139526f, 0.41970700025558472f, 0.45401400327682495f, 0.48618701100349426f, 0.51614201068878174f, 0.54384201765060425f, 0.56930899620056152f, 5.83937982412408019e-08f, 3.2765999549155822e-06f, 0.00005055400106357f, 0.00035111699253321f, 0.00145683996379375f, 0.00427943980321288f, 0.0098936902359128f, 0.01927389949560165f, 0.03310279920697212f, 0.05168719962239265f, 0.07495570182800293f, 0.10250899940729141f, 0.13370099663734436f, 0.1677280068397522f, 0.20372100174427032f, 0.24084299802780151f, 0.27840098738670349f, 0.31564199924468994f, 0.35190799832344055f, 0.38674798607826233f, 0.41985601186752319f, 0.45104199647903442f, 0.48021000623703003f, 0.50734001398086548f, 8.73966010672688753e-10f, 1.57741993689342053e-07f, 5.21975016454234719e-06f, 0.00006079579907237f, 0.00036219600588083f, 0.00138045998755842f, 0.00386844994500279f, 0.00871635042130947f, 0.01675550080835819f, 0.02860799990594387f, 0.04461279883980751f, 0.06480839848518372f, 0.08895269781351089f, 0.11656700074672699f, 0.1470009982585907f, 0.17950700223445892f, 0.21331800520420074f, 0.24785000085830688f, 0.28237700462341309f, 0.31631898880004883f, 0.34923198819160461f, 0.38083100318908691f, 0.41094100475311279f, 0.43946701288223267f, 2.8866399288257627e-12f, 2.63671995348602195e-09f, 2.51094007808205788e-07f, 5.97520011069718748e-06f, 0.00005859580051037f, 0.0003192939911969f, 0.00116373994387686f, 0.00319523992948234f, 0.00714873988181353f, 0.0137449000030756f, 0.0235638003796339f, 0.03696820139884949f, 0.05407309904694557f, 0.0747511014342308f, 0.09866459667682648f, 0.12531900405883789f, 0.15412400662899017f, 0.18446199595928192f, 0.21573600172996521f, 0.24741099774837494f, 0.27903899550437927f, 0.310263991355896f, 0.34082499146461487f, 0.37054198980331421f, 6.94488983838260476e-16f, 7.04290011727115584e-12f, 3.21448001550095341e-09f, 2.20180993437679717e-07f, 4.50593006462440826e-06f, 0.00004154839916737f, 0.00022262999846134f, 0.00081575999502093f, 0.00227530999109149f, 0.00519366981461644f, 0.01020010001957417f, 0.0178545992821455f, 0.02856850065290928f, 0.04256030172109604f, 0.05984469875693321f, 0.08025020360946655f, 0.10345599800348282f, 0.12904399633407593f, 0.15654699504375458f, 0.1854960024356842f, 0.21545499563217163f, 0.24603499472141266f, 0.27690801024436951f, 0.3078019917011261f, 5.46278023199234311e-22f, 3.43167987041791307e-16f, 2.29294990113093622e-12f, 9.57796952860689998e-10f, 6.87986982939037262e-08f, 1.5533599935224629e-06f, 0.00001600819996384f, 0.00009555240103509f, 0.00038631301140413f, 0.00117554003372788f, 0.00289549003355205f, 0.00607588002458215f, 0.01126710046082735f, 0.01896269991993904f, 0.02954130060970783f, 0.04323289915919304f, 0.06011129915714264f, 0.0801049992442131f, 0.10301999747753143f, 0.12857000529766083f, 0.15640300512313843f, 0.18612800538539886f, 0.21734000742435455f, 0.24963200092315674f, 0.0f, 0.0f, 3.09890004335006815e-24f, 2.21276004416278673e-18f, 2.67358004631774657e-14f, 2.24439997836833882e-11f, 3.13075010360819306e-09f, 1.26480998119404831e-07f, 2.12951999856159091e-06f, 0.00001907769910758f, 0.00010753999958979f, 0.00042892698547803f, 0.00131604995112866f, 0.00330013991333544f, 0.00707077002152801f, 0.01337909977883101f, 0.02291939966380596f, 0.03622379899024963f, 0.05359359830617905f, 0.07507230341434479f, 0.10045900195837021f, 0.12935000658035278f, 0.16119599342346191f, 0.19536399841308594f
} };
static __device__ float3  mix_0(float3  e1_0, float3  e2_0, float e3_0)
{
    return e1_0 * make_float3 (1.0f - e3_0) + e2_0 * make_float3 (e3_0);
}

__device__ float anisotropicG1(float3  w_1, float2  alphas_2)
{
    float _S389 = (F32_max((w_1.z), (0.0f)));
    return 2.0f * _S389 / (_S389 + length_0(make_float3 (alphas_2.x * w_1.x, alphas_2.y * w_1.y, _S389)));
}

__device__ float anisotropicD(float3  h_0, float2  alphas_3)
{
    float _S390 = alphas_3.x;
    float _S391 = h_0.x / _S390;
    float _S392 = alphas_3.y;
    float _S393 = h_0.y / _S392;
    float _S394 = h_0.z;
    float _S395 = _S391 * _S391 + _S393 * _S393 + _S394 * _S394;
    return 1.0f / (F32_max((3.14159274101257324f * _S390 * _S392 * _S395 * _S395), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ BSDFLobes bsdfLobes(float3  in_dir_3, float3  v_3, float3  n_i_2, float3  ggx_n_0, BSDFMaterial material_2, float eta_i_2, float eta_o_2, AnisotropicFrame frame_2)
{
    float _S396 = dot_0(ggx_n_0, v_3);
    float _S397 = dot_0(n_i_2, ggx_n_0);
    float _S398 = eta_i_2 / eta_o_2;
    float3  _S399 = refract_0(in_dir_3, ggx_n_0, _S398);
    float3  _S400 = ((((_S399)) * make_float3(rnorm3df(((_S399)).x, ((_S399)).y, ((_S399)).z))));
    float _S401 = (F32_min(((F32_sqrt((material_2.specular_level))) * (F32_abs((eta_i_2 - eta_o_2))) / (eta_i_2 + eta_o_2)), (0.9999847412109375f)));
    float _S402 = _S401 * _S401;
    float _S403 = (1.0f + _S401) / (1.0f - _S401);
    float _S404 = (F32_abs((_S396)));
    bool _S405 = eta_i_2 > eta_o_2;
    float sheen_component_0;
    if(_S405)
    {
        sheen_component_0 = _S403;
    }
    else
    {
        sheen_component_0 = 1.0f;
    }
    float toon_component_0;
    if(_S405)
    {
        toon_component_0 = 1.0f;
    }
    else
    {
        toon_component_0 = _S403;
    }
    float _S406 = fresnel(_S404, sheen_component_0, toon_component_0);
    bool _S407 = (eta_i_2 * eta_i_2 * (1.0f - _S396 * _S396)) >= (eta_o_2 * eta_o_2);
    float3  _S408;
    if(_S407)
    {
        _S408 = make_float3 (1.0f);
    }
    else
    {
        float3  _S409 = material_2.specular_tint * make_float3 (_S402);
        _S408 = _S409 + (make_float3 (1.0f) - _S409) * make_float3 (_S406 - _S402) / make_float3 (1.0f - _S402);
    }
    float3  _S410 = make_float3 (1.0f);
    float3  _S411 = make_float3 (0.0f);
    float _S412 = rgb_to_greyscale(material_2.sheen);
    bool _S413 = _S412 > 0.0f;
    float3  sheen_1;
    float3  view_1;
    float3  scale_1;
    if(_S413)
    {
        float _S414 = clamp_1((F32_sqrt(((F32_max((dot_0(n_i_2, v_3)), (0.0f)))))), 0.0f, 1.0f) * 23.0f;
        uint _S415 = (U32_min((uint(_S414)), (22U)));
        float least_0 = (F32_sqrt((0.05000000074505806f)));
        float _S416 = (F32_sqrt((0.10000000149011612f)));
        bool _S417 = (material_2.velvet) > 0.0f;
        float _S418 = _slang_select(_S417, _S416,least_0);
        float _S419 = (clamp_1((F32_sqrt(((F32_max((material_2.sheen_roughness), (0.0f)))))), _S418, 1.0f) - _S418) / (1.0f - _S418) * 23.0f;
        uint _S420 = (U32_min((uint(_S419)), (22U)));
        uint _S421 = _S415 * 24U + _S420;
        float _S422 = _S414 - float(_S415);
        float _S423 = _S419 - float(_S420);
        uint _S424 = _S421 + 24U;
        float a_5 = SHEEN_ALBEDO_0[_S421] + (SHEEN_ALBEDO_0[_S424] - SHEEN_ALBEDO_0[_S421]) * _S422;
        uint _S425 = _S421 + 1U;
        uint _S426 = _S424 + 1U;
        float b_1 = SHEEN_ALBEDO_0[_S425] + (SHEEN_ALBEDO_0[_S426] - SHEEN_ALBEDO_0[_S425]) * _S422;
        float _S427 = (F32_exp((a_5 + (b_1 - a_5) * _S423)));
        if(_S417)
        {
            float a_6 = VELVET_ALBEDO_0[_S421] + (VELVET_ALBEDO_0[_S424] - VELVET_ALBEDO_0[_S421]) * _S422;
            float b_2 = VELVET_ALBEDO_0[_S425] + (VELVET_ALBEDO_0[_S426] - VELVET_ALBEDO_0[_S425]) * _S422;
            float _S428 = a_6 + (b_2 - a_6) * _S423;
            sheen_component_0 = _S428;
        }
        else
        {
            sheen_component_0 = _S427;
        }
        float _S429 = (F32_min((sheen_component_0), (1.0f)));
        float3  _S430 = make_float3 (1.0f) - material_2.sheen * make_float3 (_S429);
        float _S431 = rgb_to_greyscale(material_2.sheen);
        float _S432 = _S431 * _S429;
        float3  _S433 = material_2.sheen / make_float3 ((F32_max((sheen_component_0), (1.0f))));
        sheen_component_0 = _S432;
        sheen_1 = _S433;
        view_1 = v_3;
        scale_1 = _S430;
    }
    else
    {
        sheen_component_0 = 0.0f;
        sheen_1 = _S411;
        view_1 = _S411;
        scale_1 = _S410;
    }
    float _S434 = material_2.toon.x;
    bool _S435 = _S434 < 0.0f;
    float _S436 = (F32_abs((_S434)));
    bool _S437 = _S436 > 0.0f;
    float toon_a_1;
    float toon_s_1;
    float toon_b_1;
    float toon_norm_1;
    float toon_view_1;
    float3  toon_1;
    float3  toon_axis_1;
    bool _S438;
    if(_S437)
    {
        float _S439 = (F32_min((_S436), (1.0f)));
        float3  scale_2 = scale_1 * make_float3 (1.0f - _S439);
        float _S440 = rgb_to_greyscale(material_2.albedo);
        float _S441 = _S439 * _S440;
        float3  _S442 = make_float3 (_S439) * material_2.albedo;
        float toon_a_2 = clamp_1(material_2.toon.y / _S434, 0.00000999999974738f, 1.0f) * 3.14159274101257324f / 2.0f;
        float toon_s_2 = clamp_1(material_2.toon.z / _S434, 0.0f, 1.0f) * 3.14159274101257324f / 2.0f;
        float _S443 = (F32_min((toon_a_2 + toon_s_2), (1.57079637050628662f)));
        if(_S435)
        {
            toon_component_0 = 1.0f - (F32_cos(((F32_min((_S443), (toon_a_2))))));
        }
        else
        {
            float _S444 = (F32_sin(((F32_min((_S443), (toon_a_2))))));
            toon_component_0 = _S444 * _S444 / 2.0f;
        }
        bool _S445 = _S443 > toon_a_2;
        if(_S445)
        {
            _S438 = toon_s_2 > 0.0f;
        }
        else
        {
            _S438 = false;
        }
        if(_S438)
        {
            if(_S435)
            {
                float _S446 = (F32_cos((toon_a_2)));
                float _S447 = (F32_cos((_S443)));
                toon_a_1 = (1.0f + toon_a_2 / toon_s_2) * (_S446 - _S447) - ((F32_sin((_S443))) - _S443 * _S447 - ((F32_sin((toon_a_2))) - toon_a_2 * _S446)) / toon_s_2;
            }
            else
            {
                float _S448 = 2.0f * toon_a_2;
                float _S449 = (F32_cos((_S448)));
                float _S450 = 2.0f * _S443;
                float _S451 = (F32_cos((_S450)));
                toon_a_1 = (1.0f + toon_a_2 / toon_s_2) * (_S449 - _S451) / 4.0f - ((F32_sin((_S450))) / 8.0f - _S443 * _S451 / 4.0f - ((F32_sin((_S448))) / 8.0f - toon_a_2 * _S449 / 4.0f)) / toon_s_2;
            }
            float integral_0 = toon_component_0 + toon_a_1;
            toon_component_0 = integral_0;
        }
        float _S452 = 6.28318548202514648f * toon_component_0;
        float _S453 = dot_0(n_i_2, v_3);
        float _S454 = (F32_acos(((F32_min((_S453), (1.0f))))));
        if(_S454 < toon_a_2)
        {
            toon_component_0 = 1.0f;
        }
        else
        {
            toon_component_0 = (F32_max((1.0f - (_S454 - toon_a_2) / (F32_max((toon_s_2), (0.0000152587890625f)))), (0.0f)));
        }
        if(_S435)
        {
            float3  _S455 = make_float3 (2.0f * _S453) * n_i_2 - v_3;
            float3  _S456 = ((((_S455)) * make_float3(rnorm3df(((_S455)).x, ((_S455)).y, ((_S455)).z))));
            scale_1 = _S456;
        }
        else
        {
            scale_1 = n_i_2;
        }
        float _S457 = toon_component_0;
        toon_component_0 = _S441;
        toon_1 = _S442;
        toon_a_1 = toon_a_2;
        toon_s_1 = toon_s_2;
        toon_b_1 = _S443;
        toon_norm_1 = _S452;
        toon_view_1 = _S457;
        toon_axis_1 = scale_1;
        scale_1 = scale_2;
    }
    else
    {
        toon_component_0 = 0.0f;
        toon_1 = _S411;
        toon_a_1 = 0.0f;
        toon_s_1 = 0.0f;
        toon_b_1 = 0.0f;
        toon_norm_1 = 1.0f;
        toon_view_1 = 0.0f;
        toon_axis_1 = n_i_2;
    }
    float3  _S458 = mix_0(_S408, material_2.albedo, material_2.metallic);
    float3  F_1 = _S458 * scale_1;
    float _S459 = rgb_to_greyscale(F_1);
    float _S460 = 1.0f - material_2.metallic;
    float3  _S461 = make_float3 (1.0f) - _S408;
    float3  _S462 = make_float3 ((1.0f - material_2.transmission) * _S460) * _S461 * scale_1;
    float3  _S463 = make_float3 (material_2.transmission * _S460) * _S461 * scale_1;
    float _S464 = (F32_max((_S459), (0.0f)));
    float _S465 = rgb_to_greyscale(_S462);
    float _S466 = (F32_max((_S465), (0.0f)));
    float _S467 = rgb_to_greyscale(_S463);
    float _S468 = sign_0(length_0(_S400));
    float _S469 = (F32_max((_S467 * _S468), (0.0f)));
    float _S470 = _S464 + _S466 + _S469 + toon_component_0;
    float _S471 = (F32_min((sheen_component_0), (1.0f)));
    bool _S472 = sheen_component_0 > 0.0f;
    if(_S472)
    {
        _S438 = !(_S470 > 0.0f);
    }
    else
    {
        _S438 = false;
    }
    float _S473 = _slang_select(_S438, 1.0f,_S471);
    float _S474 = (1.0f - _S473) / (F32_max((_S470), (0.0000152587890625f)));
    float _S475 = _S466 * _S474;
    float _S476 = _S464 * _S474;
    float _S477 = _S469 * _S474;
    bool _S478 = (frame_2.alphas.x) > 0.0f;
    float visible_1;
    if(_S478)
    {
        float3  _S479 = anisotropicLocal(v_3, frame_2.tangent, n_i_2);
        float _S480 = anisotropicG1(_S479, frame_2.alphas);
        float3  _S481 = anisotropicLocal(ggx_n_0, frame_2.tangent, n_i_2);
        float _S482 = anisotropicD(_S481, frame_2.alphas);
        float _S483 = _S480 * _S482;
        visible_1 = _S483;
    }
    else
    {
        visible_1 = 0.0f;
    }
    return BSDFLobes_x24init_0(_S396, _S397, _S400, F_1, _S459, 1.0f, _S462, _S463, _S475, _S476, _S477, 0.0f, sheen_1, _S473, view_1, frame_2.tangent, frame_2.alphas, visible_1, toon_component_0 * _S474, toon_1, toon_a_1, toon_s_1, toon_b_1, _S435, toon_norm_1, toon_view_1, toon_axis_1);
}

__device__ float translucentShare(BSDFMaterial material_3)
{
    float _S484 = rgb_to_greyscale(material_3.translucent);
    float _S485 = rgb_to_greyscale(material_3.albedo);
    float _S486 = _S484 / (_S485 + _S484);
    bool _S487 = _S484 > 0.0f;
    float _S488 = _slang_select(_S487, _S486,0.0f);
    return _S488;
}

__device__ __forceinline__ float diffusePDF(float n_i_dot_l_0, float l_dot_h_0, float n_i_dot_v_0, float alpha_2, BSDFLobes lobes_0, float eta_i_3, float eta_o_3)
{
    float _S489 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    float _S490 = lobes_0.p_diffuse * (F32_abs((n_i_dot_l_0))) * 0.31830987334251404f;
    float _S491 = 1.0f - lobes_0.translucent_share;
    bool _S492 = n_i_dot_l_0 < 0.0f;
    float _S493 = _slang_select(_S492, lobes_0.translucent_share,_S491);
    float _S494 = _S490 * _S493;
    bool _S495 = (lobes_0.translucent_share) > 0.0f;
    float _S496 = _slang_select(_S495, _S494,_S489);
    bool _S497 = n_i_dot_v_0 > 0.0f;
    float _S498 = _slang_select(_S497, _S496,0.0f);
    return _S498;
}

__device__ __forceinline__ float3  diffuseBSDF(float3  l_0, float3  n_i_3, float alpha_3, BSDFMaterial material_4, BSDFLobes lobes_1)
{
    bool _S499 = (dot_0(n_i_3, l_0)) < 0.0f;
    float3  _S500 = _slang_select(_S499, material_4.translucent,material_4.albedo);
    float _S501 = 1.0f - lobes_1.translucent_share;
    float _S502 = _slang_select(_S499, lobes_1.translucent_share,_S501);
    float3  _S503 = _S500 / make_float3 (_S502);
    bool _S504 = (lobes_1.translucent_share) > 0.0f;
    float3  _S505 = _slang_select(_S504, _S503,material_4.albedo);
    return lobes_1.diffuse_weight * _S505 / make_float3 (lobes_1.p_diffuse);
}

__device__ float smithG1(float alpha_4, float n_dot_x_0)
{
    float _S506 = alpha_4 * alpha_4;
    float _S507 = 2.0f * n_dot_x_0 / (n_dot_x_0 + (F32_sqrt((_S506 + (1.0f - _S506) * n_dot_x_0 * n_dot_x_0))));
    bool _S508 = alpha_4 > 0.0f;
    float _S509 = _slang_select(_S508, _S507,1.0f);
    return _S509;
}

__device__ float trowbridgeReitz(float alpha_5, float n_dot_h_1)
{
    float _S510 = alpha_5 * alpha_5;
    float _S511 = (1.0f - n_dot_h_1) * (1.0f + n_dot_h_1) + _S510 * n_dot_h_1 * n_dot_h_1;
    return _S510 / (F32_max((3.14159274101257324f * _S511 * _S511), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ float vndfPDF(float n_i_dot_v_1, float alpha_6, BSDFLobes lobes_2)
{
    float _S512 = smithG1(alpha_6, n_i_dot_v_1);
    float _S513 = _S512 * lobes_2.v_dot_h;
    float _S514 = trowbridgeReitz(alpha_6, lobes_2.n_dot_h);
    float _S515 = _S513 * _S514 / n_i_dot_v_1;
    bool _S516 = alpha_6 > 0.0f;
    bool _S517;
    if(_S516)
    {
        _S517 = (lobes_2.v_dot_h) > 0.0f;
    }
    else
    {
        _S517 = false;
    }
    if(_S517)
    {
        _S517 = (lobes_2.n_dot_h) > 0.0f;
    }
    else
    {
        _S517 = false;
    }
    if(_S517)
    {
        _S517 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S517 = false;
    }
    float _S518 = _slang_select(_S517, _S515,0.0f);
    bool _S519 = (lobes_2.alphas.x) > 0.0f;
    float pdf_h_0;
    if(_S519)
    {
        float _S520 = lobes_2.visible * lobes_2.v_dot_h / n_i_dot_v_1;
        bool _S521 = (lobes_2.v_dot_h) > 0.0f;
        if(_S521)
        {
            _S517 = (lobes_2.n_dot_h) > 0.0f;
        }
        else
        {
            _S517 = false;
        }
        if(_S517)
        {
            _S517 = n_i_dot_v_1 > 0.0f;
        }
        else
        {
            _S517 = false;
        }
        float _S522 = _slang_select(_S517, _S520,0.0f);
        pdf_h_0 = _S522;
    }
    else
    {
        pdf_h_0 = _S518;
    }
    return pdf_h_0;
}

__device__ __forceinline__ float refractPDF(float n_i_dot_l_1, float l_dot_h_1, float n_i_dot_v_2, float alpha_7, BSDFLobes lobes_3, float eta_i_4, float eta_o_4)
{
    float _S523 = vndfPDF(n_i_dot_v_2, alpha_7, lobes_3);
    float _S524 = eta_i_4 * lobes_3.v_dot_h + eta_o_4 * l_dot_h_1;
    float _S525 = lobes_3.p_refract * _S523 * eta_o_4 * eta_o_4 * (F32_abs((l_dot_h_1))) / (_S524 * _S524);
    bool _S526 = eta_i_4 != eta_o_4;
    bool _S527;
    if(_S526)
    {
        _S527 = l_dot_h_1 < 0.0f;
    }
    else
    {
        _S527 = false;
    }
    float _S528 = _slang_select(_S527, _S525,0.0f);
    return _S528;
}

__device__ __forceinline__ float3  refractBSDF(float3  l_1, float3  n_i_4, float alpha_8, BSDFMaterial material_5, BSDFLobes lobes_4)
{
    float _S529 = - dot_0(n_i_4, l_1);
    float _S530 = smithG1(alpha_8, (F32_max((_S529), (0.0f))));
    bool _S531 = (lobes_4.alphas.x) > 0.0f;
    float G1_l_0;
    if(_S531)
    {
        float3  _S532 = negate_0(n_i_4);
        float3  _S533 = anisotropicLocal(l_1, lobes_4.tangent, _S532);
        float _S534 = anisotropicG1(_S533, lobes_4.alphas);
        G1_l_0 = _S534;
    }
    else
    {
        G1_l_0 = _S530;
    }
    return lobes_4.refract_weight * make_float3 (G1_l_0) * material_5.albedo / make_float3 (lobes_4.p_refract);
}

__device__ __forceinline__ float sheenVelvetPDF(float n_i_dot_l_2, float l_dot_h_2, float n_i_dot_v_3, float alpha_9, BSDFLobes lobes_5, float eta_i_5, float eta_o_5)
{
    float _S535 = lobes_5.p_sheen_velvet * 0.5f * 0.31830987334251404f;
    bool _S536 = n_i_dot_l_2 > 0.0f;
    bool _S537;
    if(_S536)
    {
        _S537 = n_i_dot_v_3 > 0.0f;
    }
    else
    {
        _S537 = false;
    }
    float _S538 = _slang_select(_S537, _S535,0.0f);
    return _S538;
}

__device__ __forceinline__ float3  sheenVelvetBSDF(float3  l_2, float3  n_i_5, float alpha_10, BSDFMaterial material_6, BSDFLobes lobes_6)
{
    float3  _S539 = l_2 + lobes_6.view;
    float3  _S540 = ((((_S539)) * make_float3(rnorm3df(((_S539)).x, ((_S539)).y, ((_S539)).z))));
    float _S541 = dot_0(n_i_5, _S540);
    float _S542 = (F32_max((dot_0(n_i_5, l_2)), (0.0f)));
    float _S543 = (F32_max((dot_0(n_i_5, lobes_6.view)), (0.0f)));
    float _S544 = 1.0f / (F32_max((material_6.sheen_roughness), (0.05000000074505806f)));
    float _S545 = 1.0f - _S541 * _S541;
    float _S546 = (2.0f + _S544) * (F32_pow(((F32_max((_S545), (0.0f)))), (0.5f * _S544))) * 0.5f * 0.31830987334251404f / (F32_max((4.0f * (_S542 + _S543 - _S542 * _S543)), (0.0000152587890625f)));
    bool _S547 = (material_6.velvet) > 0.0f;
    float f_1;
    if(_S547)
    {
        float _S548 = (F32_max((material_6.sheen_roughness), (0.00999999977648258f)));
        float _S549 = _S548 * _S548;
        float _S550 = (F32_max((_S545), (0.0000152587890625f)));
        float _S551 = (F32_exp((- _S541 * _S541 / (_S550 * _S549)))) / (3.14159274101257324f * _S549 * _S550 * _S550) * (F32_min((1.0f), (2.0f * _S541 * (F32_min((_S542), (_S543))) / (F32_max(((F32_abs((dot_0(_S540, lobes_6.view))))), (0.0000152587890625f)))))) / (F32_max((4.0f * _S542 * _S543), (0.0000152587890625f)));
        f_1 = _S551;
    }
    else
    {
        f_1 = _S546;
    }
    return lobes_6.sheen * make_float3 (f_1 * _S542 * 2.0f * 3.14159274101257324f / lobes_6.p_sheen_velvet);
}

__device__ __forceinline__ float toonPDF(float n_i_dot_l_3, float l_dot_h_3, float n_i_dot_v_4, float alpha_11, BSDFLobes lobes_7, float eta_i_6, float eta_o_6)
{
    float _S552 = _slang_select(lobes_7.toon_glossy, l_dot_h_3,n_i_dot_l_3);
    float _S553 = (F32_acos((clamp_1(_S552, -1.0f, 1.0f))));
    float _S554;
    if(_S553 < (lobes_7.toon_a))
    {
        _S554 = 1.0f;
    }
    else
    {
        _S554 = (F32_max((1.0f - (_S553 - lobes_7.toon_a) / (F32_max((lobes_7.toon_s), (0.0000152587890625f)))), (0.0f)));
    }
    float _S555 = lobes_7.p_toon * _S554;
    float _S556 = _slang_select(lobes_7.toon_glossy, 1.0f,n_i_dot_l_3);
    float _S557 = _S555 * _S556 / lobes_7.toon_norm;
    bool _S558;
    if(lobes_7.toon_glossy)
    {
        _S558 = true;
    }
    else
    {
        _S558 = n_i_dot_l_3 > 0.0f;
    }
    float _S559 = _slang_select(_S558, _S557,0.0f);
    return _S559;
}

__device__ __forceinline__ float3  toonBSDF(float3  l_3, float3  n_i_6, float alpha_12, BSDFMaterial material_7, BSDFLobes lobes_8)
{
    float _S560 = (F32_max((dot_0(n_i_6, l_3)), (0.0f)));
    float _S561 = _slang_select(lobes_8.toon_glossy, _S560,lobes_8.toon_view);
    return lobes_8.toon * make_float3 (_S561) / make_float3 (lobes_8.p_toon);
}

__device__ __forceinline__ float reflectPDF(float n_i_dot_l_4, float l_dot_h_4, float n_i_dot_v_5, float alpha_13, BSDFLobes lobes_9, float eta_i_7, float eta_o_7)
{
    float _S562 = vndfPDF(n_i_dot_v_5, alpha_13, lobes_9);
    float _S563 = lobes_9.p_reflect * _S562 / (4.0f * lobes_9.v_dot_h);
    bool _S564 = _S562 > 0.0f;
    float _S565 = _slang_select(_S564, _S563,0.0f);
    return _S565;
}

__device__ __forceinline__ float3  reflectBSDF(float3  l_4, float3  n_i_7, float alpha_14, BSDFMaterial material_8, BSDFLobes lobes_10)
{
    float _S566 = dot_0(n_i_7, l_4);
    float _S567 = smithG1(alpha_14, (F32_max((_S566), (0.0f))));
    bool _S568 = (lobes_10.alphas.x) > 0.0f;
    float G1_l_1;
    if(_S568)
    {
        float3  _S569 = anisotropicLocal(l_4, lobes_10.tangent, n_i_7);
        float _S570 = anisotropicG1(_S569, lobes_10.alphas);
        G1_l_1 = _S570;
    }
    else
    {
        G1_l_1 = _S567;
    }
    return make_float3 (lobes_10.reflect_weight * G1_l_1) * lobes_10.F / make_float3 (lobes_10.p_reflect);
}

__device__ __forceinline__ float3  misWeighted(float3  throughput_0, float lobe_pdf_0, float pdf_0, bool power_0)
{
    if(power_0)
    {
        float _S571 = lobe_pdf_0 / pdf_0;
        return throughput_0 * make_float3 (lobe_pdf_0) / make_float3 (pdf_0 * (1.0f + _S571 * _S571));
    }
    return throughput_0 * make_float3 (lobe_pdf_0) / make_float3 (lobe_pdf_0 + pdf_0);
}

static __device__ float3  neeLobes_0(float3  in_dir_4, float3  dir_3, float3  n_7, BSDFMaterial * material_9, float eta_i_8, float eta_o_8, bool refracted_2, float pdf_1, bool power_1, uint random_state_4, FixedArray<float3 , 5>  * each_0, uint * reached_0)
{
    float3  _S572 = negate_0(in_dir_4);
    float _S573 = dot_0(n_7, _S572);
    float _S574 = sign_0(_S573);
    float3  _S575 = n_7 * make_float3 (_S574);
    AnisotropicFrame _S576 = anisotropicFrame(*material_9, _S575);
    float _S577 = dot_0(_S575, dir_3);
    float _S578 = material_9->roughness * material_9->roughness;
    float3  _S579 = make_float3 (0.0f);
    *reached_0 = 0U;
    BSDFLobes _S580 = BSDFLobes_x24init_0(0.0f, 0.0f, _S579, _S579, 0.0f, 0.0f, _S579, _S579, 0.0f, 0.0f, 0.0f, 0.0f, _S579, 0.0f, _S579, _S579, make_float2 (0.0f), 0.0f, 0.0f, _S579, 0.0f, 0.0f, 0.0f, false, 1.0f, 0.0f, _S579);
    BSDFLobes lobe_terms_0 = _S580;
    uint _S581;
    if((F32_abs((material_9->toon.x))) > 0.0f)
    {
        _S581 = 5U;
    }
    else
    {
        _S581 = 4U;
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
        (*each_0)[i_6] = _S579;
        uint i_7 = i_6 + 1U;
        i_6 = i_7;
    }
    uint half_of_0 = 4294967295U;
    float3  ggx_n_1 = _S579;
    i_6 = 0U;
    float3  f_2 = _S579;
    for(;;)
    {
        if(i_6 < _S581)
        {
        }
        else
        {
            break;
        }
        uint _S582;
        if(i_6 == 3U)
        {
            _S582 = 4U;
        }
        else
        {
            if(i_6 == 4U)
            {
                _S582 = 6U;
            }
            else
            {
                _S582 = i_6;
            }
        }
        bool _S583 = _S582 == 0U;
        if(_S583)
        {
        }
        bool _S584;
        if(_S583)
        {
            float _S585 = rgb_to_greyscale(material_9->translucent);
            _S584 = _S585 > 0.0f;
        }
        else
        {
            _S584 = false;
        }
        bool _S586;
        if(_S584)
        {
            float _S587 = dot_0(n_7, dir_3);
            float3  _S588 = negate_0(in_dir_4);
            _S586 = ((_S587 * dot_0(n_7, _S588)) < 0.0f) == refracted_2;
        }
        else
        {
            _S586 = (_S582 == 1U) == refracted_2;
        }
        float3  ggx_n_2;
        if(_S586)
        {
            uint _S589;
            if(_S582 == 6U)
            {
                _S589 = 0U;
            }
            else
            {
                if(_S582 == 4U)
                {
                    _S589 = 2U;
                }
                else
                {
                    _S589 = _S582;
                }
            }
            bool _S590 = _S589 != half_of_0;
            uint half_of_1;
            if(_S590)
            {
                bool _S591 = _S589 == 0U;
                if(_S591)
                {
                    float3  _S592 = sampledHalf(in_dir_4, n_7, *material_9, random_state_4, _S576);
                    ggx_n_2 = _S592;
                }
                else
                {
                    bool _S593 = _S589 == 1U;
                    if(_S593)
                    {
                        float3  _S594 = refractedHalf(in_dir_4, dir_3, n_7, eta_i_8, eta_o_8);
                        ggx_n_2 = _S594;
                    }
                    else
                    {
                        float3  _S595 = reflectedHalf(in_dir_4, dir_3);
                        ggx_n_2 = _S595;
                    }
                }
                float3  _S596 = negate_0(in_dir_4);
                BSDFLobes _S597 = bsdfLobes(in_dir_4, _S596, _S575, ggx_n_2, *material_9, eta_i_8, eta_o_8, _S576);
                lobe_terms_0 = _S597;
                float _S598 = translucentShare(*material_9);
                (&lobe_terms_0)->translucent_share = _S598;
                half_of_1 = _S589;
            }
            else
            {
                ggx_n_2 = ggx_n_1;
                half_of_1 = half_of_0;
            }
            float3  throughput_1;
            float lobe_pdf_1;
            switch(_S582)
            {
            case 0U:
                {
                    float _S599 = diffusePDF(_S577, 0.0f, (F32_abs((_S573))), _S578, lobe_terms_0, eta_i_8, eta_o_8);
                    float3  _S600 = diffuseBSDF(dir_3, _S575, _S578, *material_9, lobe_terms_0);
                    lobe_pdf_1 = _S599;
                    throughput_1 = _S600;
                    break;
                }
            case 1U:
                {
                    float _S601 = refractPDF(_S577, dot_0(dir_3, ggx_n_2), (F32_abs((_S573))), _S578, lobe_terms_0, eta_i_8, eta_o_8);
                    float3  _S602 = refractBSDF(dir_3, _S575, _S578, *material_9, lobe_terms_0);
                    lobe_pdf_1 = _S601;
                    throughput_1 = _S602;
                    break;
                }
            case 4U:
                {
                    float _S603 = sheenVelvetPDF(_S577, 0.0f, (F32_abs((_S573))), _S578, lobe_terms_0, eta_i_8, eta_o_8);
                    float3  _S604 = sheenVelvetBSDF(dir_3, _S575, _S578, *material_9, lobe_terms_0);
                    lobe_pdf_1 = _S603;
                    throughput_1 = _S604;
                    break;
                }
            case 6U:
                {
                    float _S605 = toonPDF(_S577, dot_0(dir_3, (&lobe_terms_0)->toon_axis), (F32_abs((_S573))), _S578, lobe_terms_0, eta_i_8, eta_o_8);
                    float3  _S606 = toonBSDF(dir_3, _S575, _S578, *material_9, lobe_terms_0);
                    lobe_pdf_1 = _S605;
                    throughput_1 = _S606;
                    break;
                }
            default:
                {
                    float _S607 = reflectPDF(_S577, 0.0f, (F32_abs((_S573))), _S578, lobe_terms_0, eta_i_8, eta_o_8);
                    float3  _S608 = reflectBSDF(dir_3, _S575, _S578, *material_9, lobe_terms_0);
                    lobe_pdf_1 = _S607;
                    throughput_1 = _S608;
                    break;
                }
            }
            bool _S609 = lobe_pdf_1 > 0.0f;
            float3  f_3;
            if(_S609)
            {
                float3  _S610 = misWeighted(throughput_1, lobe_pdf_1, pdf_1, power_1);
                (*each_0)[i_6] = _S610;
                uint _S611 = (*reached_0) | (1U << i_6);
                *reached_0 = _S611;
                float3  f_4 = f_2 + (*each_0)[i_6];
                f_3 = f_4;
            }
            else
            {
                f_3 = f_2;
            }
            half_of_0 = half_of_1;
            f_2 = f_3;
        }
        else
        {
            ggx_n_2 = ggx_n_1;
        }
        uint i_8 = i_6 + 1U;
        ggx_n_1 = ggx_n_2;
        i_6 = i_8;
    }
    return f_2;
}

__device__ __forceinline__ float3  neeBSDF(float3  in_dir_5, float3  dir_4, float3  n_8, BSDFMaterial material_10, float eta_i_9, float eta_o_9, bool refracted_3, float pdf_2, bool power_2, uint random_state_5)
{
    uint reached_1 = 0U;
    BSDFMaterial _S612 = material_10;
    FixedArray<float3 , 5>  each_1;
    float3  _S613 = neeLobes_0(in_dir_5, dir_4, n_8, &_S612, eta_i_9, eta_o_9, refracted_3, pdf_2, power_2, random_state_5, &each_1, &reached_1);
    return _S613;
}

__device__ float3  skyBSDF(float3  in_dir_6, float3  dir_5, FKSurface surface_1, float2  eta_1, bool is_inside_2, float pdf_3, uint random_state_6)
{
    bool _S614 = wrongSide_0(is_inside_2, false, dir_5, surface_1.geometry_n);
    float3  _S615 = neeBSDF(in_dir_6, dir_5, surface_1.smooth_n, surface_1.material, eta_1.x, eta_1.y, _S614, pdf_3, false, random_state_6);
    return _S615;
}

static __device__ SkySample SkySample_x24init_0(float3  dir_6, float3  radiance_0, float3  color_0, uint random_state_7)
{
    SkySample _S616;
    (&_S616)->dir = dir_6;
    (&_S616)->radiance = radiance_0;
    (&_S616)->color = color_0;
    (&_S616)->random_state = random_state_7;
    return _S616;
}

static __device__ SkySample sampleSky_0(FKRay * ray_0, FKSurface * surface_2, float2  eta_2, bool is_inside_3, uint init_random_state_0, uint lobe_state_0, ShadowContext * context_2)
{
    uint2  _S617 = (fcptEnvironmentCdfSize());
    uint2  _S618 = make_uint2 (1U, 0U);
    uint2  _S619 = _S617 - _S618;
    Random _S620 = pcg(init_random_state_0);
    Random _S621 = pcg(_S620.state);
    Random _S622 = pcg(_S621.state);
    Random _S623 = pcg(_S622.state);
    uint _S624 = _S619.x;
    uint _S625 = searchCDF_0(make_uint2 (_S624, 0U), make_uint2 (0U, 1U), _S619.y, _S620.value);
    uint _S626 = searchCDF_0(make_uint2 (0U, _S625), _S618, _S624, _S621.value);
    float2  _S627 = make_float2 ((float)_S619.x, (float)_S619.y);
    float2  _S628 = (make_float2 (float(_S626), float(_S625)) + make_float2 (_S622.value, _S623.value)) / _S627 * make_float2 (6.28318548202514648f, 3.14159274101257324f);
    float _S629 = _S628.y;
    float _S630 = (F32_sin((_S629)));
    float _S631 = _S628.x;
    float3  _S632 = make_float3 (- _S630 * (F32_cos((_S631))), _S630 * (F32_sin((_S631))), (F32_cos((_S629))));
    float _S633 = environmentPdf_0(_S632);
    float3  _S634 = skyBSDF(ray_0->unit_direction, _S632, *surface_2, eta_2, is_inside_3, _S633, lobe_state_0);
    bool _S635 = !(_S633 > 0.0f);
    bool _S636;
    if(_S635)
    {
        _S636 = true;
    }
    else
    {
        _S636 = all_1(_S634 == make_float3 (0.0f));
    }
    if(_S636)
    {
        float3  _S637 = make_float3 (0.0f);
        return SkySample_x24init_0(_S632, _S637, _S637, _S623.state);
    }
    float3  _S638 = skyRadiance_0(ray_0->origin, surface_2, is_inside_3, _S632, context_2, _S623.state);
    return SkySample_x24init_0(_S632, _S638, _S634 * _S638, _S623.state);
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

static __device__ float3  hairLight_0(FKSurface * surface_3, float3  in_dir_7, TreeSample * light_1, bool competing_0)
{
    SampleBSDF _S639 = (fcptConnectHair((surface_3->hair), ((&surface_3->material)->albedo), ((&surface_3->material)->specular_tint), (in_dir_7), (light_1->dir)));
    float3  _S640 = _S639.throughput * make_float3 (_S639.pdf);
    float _S641 = light_1->density;
    float _S642 = 1.0f + _S639.pdf * _S639.pdf / (light_1->density * light_1->density);
    bool _S643;
    if(competing_0)
    {
        _S643 = _S641 > 0.0f;
    }
    else
    {
        _S643 = false;
    }
    float _S644 = _slang_select(_S643, _S642,1.0f);
    return _S640 / make_float3 (_S644) * light_1->radiance;
}

static __device__ TreeSample TreeSample_x24init_0(float3  dir_7, float3  radiance_1, float density_0, uint random_state_8)
{
    TreeSample _S645;
    (&_S645)->dir = dir_7;
    (&_S645)->radiance = radiance_1;
    (&_S645)->density = density_0;
    (&_S645)->random_state = random_state_8;
    return _S645;
}

__device__ uint pickChild(LightNode first_1, LightNode second_1, float3  p_11, float3  normal_3, float * pick_0, float * probability_3)
{
    float _S646 = importance(first_1, p_11, normal_3);
    float _S647 = importance(second_1, p_11, normal_3);
    float2  _S648 = make_float2 (_S646, _S647);
    bool _S649 = _S646 == 0.0f;
    bool _S650;
    if(_S649)
    {
        _S650 = _S647 == 0.0f;
    }
    else
    {
        _S650 = false;
    }
    if(_S650)
    {
        return 2U;
    }
    float _S651 = _S646 + _S647;
    bool _S652 = _S647 > 0.0f;
    if(_S652)
    {
        _S650 = (*pick_0 * _S651) >= _S646;
    }
    else
    {
        _S650 = false;
    }
    uint _S653 = uint(_S650);
    float _S654 = (F32_min(((*pick_0 * _S651 - float(_S653) * _S646) / _slang_vector_get_element(_S648, _S653)), (0.99999994039535522f)));
    *pick_0 = _S654;
    float _S655 = *probability_3 * (_slang_vector_get_element(_S648, _S653) / _S651);
    *probability_3 = _S655;
    return _S653;
}

__device__ float3  sampleSphere(float3  center_1, float radius_1, float3  p_12, float u1_0, float u2_0)
{
    float3  _S656 = center_1 - p_12;
    float _S657 = radius_1 * radius_1 / dot_0(_S656, _S656);
    float _S658 = u1_0 * _S657 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S657), (0.0f)))))));
    float _S659 = 2.0f * u1_0;
    bool _S660 = _S657 >= 1.0f;
    float _S661 = _slang_select(_S660, _S659,_S658);
    float _S662 = (F32_sqrt(((F32_max((_S661 * (2.0f - _S661)), (0.0f))))));
    float _S663 = 6.28318548202514648f * u2_0;
    float3  _S664 = make_float3 (_S662 * (F32_cos((_S663))), 1.0f - _S661, _S662 * (F32_sin((_S663))));
    float3  _S665 = ((((_S656)) * make_float3(rnorm3df(((_S656)).x, ((_S656)).y, ((_S656)).z))));
    float3  _S666 = tangentToWorld(_S664, _S665);
    return _S666;
}

__device__ float3  pointLightRadiance(float3  color_1, float intensity_0, float radius_2)
{
    return color_1 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_2 * radius_2);
}

static __device__ float raySphere_0(float3  center_2, float radius_3, FKRay * ray_1, float max_len_0)
{
    float3  _S667 = center_2 - ray_1->origin;
    float _S668 = dot_0(_S667, ray_1->unit_direction);
    float _S669 = dot_0(_S667, _S667) - _S668 * _S668;
    float _S670 = radius_3 * radius_3;
    bool _S671 = _S669 > _S670;
    if(_S671)
    {
        return 4.294967296e+09f;
    }
    float _S672 = (F32_sqrt((_S670 - _S669)));
    float _S673 = _S668 - _S672;
    float _S674 = _S668 + _S672;
    bool _S675 = _S673 > 0.0000152587890625f;
    bool _S676;
    if(_S675)
    {
        _S676 = _S673 < max_len_0;
    }
    else
    {
        _S676 = false;
    }
    if(_S676)
    {
        return _S673;
    }
    bool _S677 = _S674 > 0.0000152587890625f;
    if(_S677)
    {
        _S676 = _S674 < max_len_0;
    }
    else
    {
        _S676 = false;
    }
    if(_S676)
    {
        return _S674;
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
        int i_9 = int(0);
        float sum_0 = 0.0f;
        for(;;)
        {
            if(i_9 < int(3))
            {
            }
            else
            {
                break;
            }
            float sum_1 = sum_0 + _slang_vector_get_element(left_1, i_9) * _slang_vector_get_element(right_1.rows[i_9], j_1);
            i_9 = i_9 + int(1);
            sum_0 = sum_1;
        }
        *_slang_vector_get_element_ptr(&result_5, j_1) = sum_0;
        j_1 = j_1 + int(1);
    }
    return result_5;
}

static __device__ __forceinline__ TreeSample sampleLightTree_0(float3  origin_4, float3  smooth_n_2, float3  geometry_n_1, float geometry_offset_1, bool sided_0, uint init_random_state_1, ShadowContext * context_3)
{
    Random _S678 = pcg(init_random_state_1);
    Random _S679 = pcg(_S678.state);
    Random _S680 = pcg(_S679.state);
    float3  _S681 = make_float3 (0.0f);
    TreeSample _S682 = TreeSample_x24init_0(_S681, _S681, 0.0f, _S680.state);
    TreeSample sample_0 = _S682;
    float3  _S683 = _slang_select(sided_0, _S681,smooth_n_2);
    float3  _S684 = origin_4 + make_float3 (geometry_offset_1) * smooth_n_2;
    float pick_1 = _S678.value;
    float probability_4 = 1.0f;
    uint n_9 = 0U;
    for(;;)
    {
        uint4  _S685 = (fcptLightNode((n_9)));
        if((_S685.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S686 = (fcptLightSecond((n_9)));
        uint _S687 = n_9 + 1U;
        LightNode _S688 = (fcptLightBounds((_S687)));
        LightNode _S689 = (fcptLightBounds((_S686)));
        uint _S690 = pickChild(_S688, _S689, origin_4, _S683, &pick_1, &probability_4);
        bool _S691 = _S690 > 1U;
        if(_S691)
        {
            return sample_0;
        }
        bool _S692 = _S690 == 1U;
        uint _S693 = _slang_select(_S692, _S686,_S687);
        n_9 = _S693;
    }
    bool _S694 = n_9 == 0U;
    bool _S695;
    if(_S694)
    {
        LightNode _S696 = (fcptLightBounds((0U)));
        float _S697 = importance(_S696, origin_4, _S683);
        _S695 = !(_S697 > 0.0f);
    }
    else
    {
        _S695 = false;
    }
    if(_S695)
    {
        return sample_0;
    }
    uint4  _S698 = (fcptLightNode((n_9)));
    FKHit _S699 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    bool _S700 = (_S698.x) == 2U;
    float3  emitter_point_0;
    float3  lift_n_0;
    float3  shadow_1;
    FKHit emitter_0;
    if(_S700)
    {
        FKLight _S701 = (fcptLight((_S698.y)));
        if(sided_0)
        {
            float _S702 = sign_0(dot_0(geometry_n_1, _S701.position - origin_4));
            float3  lift_n_1 = smooth_n_2 * make_float3 (_S702);
            float3  _S703 = origin_4 + make_float3 (geometry_offset_1) * lift_n_1;
            emitter_point_0 = _S703;
            lift_n_0 = lift_n_1;
        }
        else
        {
            emitter_point_0 = _S684;
            lift_n_0 = smooth_n_2;
        }
        bool _S704 = (_S701.variance) == 0.0f;
        if(_S704)
        {
            float3  _S705 = _S701.position - emitter_point_0;
            float3  _S706 = ((((_S705)) * make_float3(rnorm3df(((_S705)).x, ((_S705)).y, ((_S705)).z))));
            (&sample_0)->dir = _S706;
            float3  _S707 = _S701.color * make_float3 (_S701.intensity) / make_float3 (dot_0(_S705, _S705) * probability_4);
            (&sample_0)->radiance = _S707;
            shadow_1 = _S705;
        }
        else
        {
            float3  _S708 = sampleSphere(_S701.position, _S701.variance, emitter_point_0, _S679.value, _S680.value);
            (&sample_0)->dir = _S708;
            float _S709 = sphereDensity(_S701.position, _S701.variance, emitter_point_0);
            float _S710 = probability_4 * _S709;
            (&sample_0)->density = _S710;
            float3  _S711 = pointLightRadiance(_S701.color, _S701.intensity, _S701.variance);
            float3  _S712 = _S711 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S712;
            FKRay _S713 = Ray_x24init_0(emitter_point_0, (&sample_0)->dir);
            float _S714 = raySphere_0(_S701.position, _S701.variance, &_S713, 4.294967296e+09f);
            float3  _S715 = (&sample_0)->dir * make_float3 (_S714);
            shadow_1 = _S715;
        }
        emitter_0 = _S699;
        emitter_point_0 = _S681;
    }
    else
    {
        uint _S716 = _S698.y;
        uint _S717 = (fcptTriangleOffset((_S716)));
        uint _S718 = _S717 + _S698.z;
        Matrix<float, 3, 3>  _S719 = (fcptWorldTriangle((_S716), (_S718)));
        float _S720 = (F32_sqrt((_S679.value)));
        float2  _S721 = make_float2 (_S720 * (1.0f - _S680.value), _S720 * _S680.value);
        float3  _S722 = mul_0(make_float3 (1.0f - _S720, _S721.x, _S721.y), _S719);
        if(sided_0)
        {
            float _S723 = sign_0(dot_0(geometry_n_1, _S722 - origin_4));
            float3  lift_n_2 = smooth_n_2 * make_float3 (_S723);
            float3  _S724 = origin_4 + make_float3 (geometry_offset_1) * lift_n_2;
            emitter_point_0 = _S724;
            lift_n_0 = lift_n_2;
        }
        else
        {
            bool _S725 = !((dot_0(smooth_n_2, _S722 - origin_4)) > 0.0f);
            if(_S725)
            {
                return sample_0;
            }
            emitter_point_0 = _S684;
            lift_n_0 = smooth_n_2;
        }
        FKHit emitter_1 = Hit_x24init_0(_S721, _S716, _S718, 0U, 0.0f);
        float3  _S726 = _S722 - emitter_point_0;
        float3  _S727 = ((((_S726)) * make_float3(rnorm3df(((_S726)).x, ((_S726)).y, ((_S726)).z))));
        (&sample_0)->dir = _S727;
        float _S728 = solidAngle(probability_4, cross_0(_S719.rows[int(1)] - _S719.rows[int(0)], _S719.rows[int(2)] - _S719.rows[int(0)]), _S726);
        (&sample_0)->density = _S728;
        bool _S729 = (fcptShadowFirst());
        bool _S730 = !_S729;
        if(_S730)
        {
            FKSurface _S731 = (fcptLightSurfaceAt((emitter_1), (_S722), (_S680.state), ((&sample_0)->dir), (context_3->depth), (length_0(_S722 - origin_4))));
            (&sample_0)->random_state = _S731.random_state;
            float3  _S732 = _slang_select(_S731.skip, _S681,_S731.material.emissive);
            float3  _S733 = _S732 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S733;
        }
        shadow_1 = _S726;
        emitter_0 = emitter_1;
        emitter_point_0 = _S722;
    }
    FKHit _S734 = emitter_0;
    float3  _S735 = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, context_3, _S680.state, &_S734);
    bool _S736 = (fcptShadowFirst());
    if(_S736)
    {
        _S695 = (emitter_0.instance_index) != 4294967295U;
    }
    else
    {
        _S695 = false;
    }
    if(_S695)
    {
        _S695 = !all_1(_S735 == _S681);
    }
    else
    {
        _S695 = false;
    }
    if(_S695)
    {
        FKSurface _S737 = (fcptLightSurfaceAt((emitter_0), (emitter_point_0), (_S680.state), ((&sample_0)->dir), (context_3->depth), (length_0(emitter_point_0 - origin_4))));
        (&sample_0)->random_state = _S737.random_state;
        float3  _S738 = _slang_select(_S737.skip, _S681,_S737.material.emissive);
        float3  _S739 = _S738 / make_float3 ((&sample_0)->density);
        (&sample_0)->radiance = _S739;
    }
    float3  _S740 = (&sample_0)->radiance * _S735;
    bool _S741 = all_1(_S735 == _S681);
    float3  _S742 = _slang_select(_S741, _S681,_S740);
    (&sample_0)->radiance = _S742;
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

__device__ float powerHeuristic(float a_7, float b_3)
{
    float _S743 = 1.0f / (1.0f + b_3 / a_7 * (b_3 / a_7));
    bool _S744 = b_3 > 0.0f;
    float _S745 = _slang_select(_S744, _S743,1.0f);
    return _S745;
}

static __device__ float emissionWeight_0(NEEVertex * vertex_0, FKHit * hit_1, float3  light_point_1)
{
    bool _S746 = vertex_0->none;
    if(_S746)
    {
        return 1.0f;
    }
    uint _S747 = (fcptLightSlot((*hit_1)));
    float _S748 = lightPdf_0(vertex_0->origin, vertex_0->smooth_n, vertex_0->start, _S747, light_point_1);
    float _S749 = powerHeuristic(vertex_0->pdf, _S748);
    return _S749;
}

static __device__ float3  environment_0(float3  dir_8, uint depth_0, uint lobe_0)
{
    uint2  _S750 = (fcptEnvironmentMapSize());
    bool _S751 = (_S750.x) > 1U;
    bool _S752;
    if(_S751)
    {
        uint2  _S753 = (fcptEnvironmentMapSize());
        _S752 = (_S753.y) > 1U;
    }
    else
    {
        _S752 = false;
    }
    if(_S752)
    {
        float3  _S754 = (fcptEnvMapSample((dir_8), (depth_0), (lobe_0)));
        return _S754;
    }
    float3  _S755 = (fcptAmbient());
    return _S755;
}

static __device__ bool environmentMapped_0()
{
    uint2  _S756 = (fcptEnvironmentCdfSize());
    bool _S757 = (_S756.x) > 1U;
    bool _S758;
    if(_S757)
    {
        uint2  _S759 = (fcptEnvironmentCdfSize());
        _S758 = (_S759.y) > 1U;
    }
    else
    {
        _S758 = false;
    }
    bool _S760 = !_S758;
    if(_S760)
    {
        return false;
    }
    uint2  _S761 = (fcptEnvironmentMapSize());
    bool _S762 = (_S761.x) > 1U;
    if(_S762)
    {
        uint2  _S763 = (fcptEnvironmentMapSize());
        _S758 = (_S763.y) > 1U;
    }
    else
    {
        _S758 = false;
    }
    return _S758;
}

static __device__ float escapeWeight_0(float pdf_4, float3  dir_9)
{
    bool _S764 = pdf_4 <= 0.0f;
    bool _S765;
    if(_S764)
    {
        _S765 = true;
    }
    else
    {
        bool _S766 = environmentMapped_0();
        _S765 = !_S766;
    }
    if(_S765)
    {
        return 1.0f;
    }
    float _S767 = environmentPdf_0(dir_9);
    return pdf_4 / (pdf_4 + _S767);
}

static __device__ float3  min_1(float3  x_15, float3  y_4)
{
    float3  result_6;
    int i_10 = int(0);
    for(;;)
    {
        if(i_10 < int(3))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_6, i_10) = (F32_min((_slang_vector_get_element(x_15, i_10)), (_slang_vector_get_element(y_4, i_10))));
        i_10 = i_10 + int(1);
    }
    return result_6;
}

static __device__ void restir_duplicates_0(uint3  global_invocation_id_1, uint3  local_invocation_id_0, uint local_invocation_index_3)
{
    uint2  _S768 = uint2 {global_invocation_id_1.x, global_invocation_id_1.y};
    int2  _S769 = make_int2 ((int)_S768.x, (int)_S768.y);
    uint _S770 = previousSeed_0(_S769);
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
            uint _S771 = previousSeed_0(_S769 + make_int2 (x_16, y_5));
            bool _S772 = _S771 == _S770;
            uint _S773 = _slang_select(_S772, 1U,0U);
            uint count_3 = count_2 + _S773;
            int x_17 = x_16 + int(1);
            x_16 = x_17;
            count_2 = count_3;
        }
        int y_6 = y_5 + int(1);
        y_5 = y_6;
    }
    float _S774 = float(count_2 - 1U) / 288.0f;
    bool _S775 = _S770 != 0U;
    float _S776 = _slang_select(_S775, _S774,0.0f);
    fcptStoreDuplication((_S769), (make_uint4 ((F32_asuint((_S776))), 0U, 0U, 0U)));
    return;
}

__device__ uint stream(uint seed_3, uint index_0)
{
    uint _S777 = hash(index_0);
    uint _S778 = hash(seed_3 ^ _S777);
    return _S778;
}

static __device__ float4  asfloat_0(uint4  x_18)
{
    float4  result_7;
    int i_11 = int(0);
    for(;;)
    {
        if(i_11 < int(4))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_7, i_11) = (U32_asfloat((_slang_vector_get_element(x_18, i_11))));
        i_11 = i_11 + int(1);
    }
    return result_7;
}

__device__ float pairShare(float c_n_0, float c_pair_0, float c_sum_0)
{
    return (c_n_0 + c_pair_0) / c_sum_0;
}

__device__ float canonicalWeight(float share_0, float c_pair_1, float p_c_0, float c_n_1, float g_there_0)
{
    return share_0 * c_pair_1 * p_c_0 / (c_pair_1 * p_c_0 + c_n_1 * g_there_0);
}

__device__ float neighborWeight(float share_1, float c_n_2, float p_n_0, float c_pair_2, float g_here_0)
{
    return share_1 * c_n_2 * p_n_0 / (c_n_2 * p_n_0 + c_pair_2 * g_here_0);
}

__device__ void offer(Selection * sel_2, Reservoir candidate_0, float3  weight_0)
{
    float _S779 = rgb_to_greyscale(weight_0);
    bool _S780 = _S779 > 0.0f;
    bool _S781;
    if(_S780)
    {
        _S781 = _S779 < 3.00000000549775576e+38f;
    }
    else
    {
        _S781 = false;
    }
    bool _S782 = !_S781;
    if(_S782)
    {
        return;
    }
    bool _S783 = sel_2->sums;
    if(_S783)
    {
        float3  _S784 = sel_2->color + weight_0;
        sel_2->color = _S784;
        return;
    }
    float _S785 = sel_2->w_sum + _S779;
    sel_2->w_sum = _S785;
    float3  _S786 = sel_2->color + weight_0;
    sel_2->color = _S786;
    Random _S787 = pcg(sel_2->random_state);
    sel_2->random_state = _S787.state;
    bool _S788 = (_S787.value * sel_2->w_sum) <= _S779;
    if(_S788)
    {
        sel_2->r = candidate_0;
    }
    return;
}

__device__ void offerShifted(Selection * sel_3, Reservoir r_3, Shift shifted_0, float mis_0)
{
    Reservoir candidate_1 = r_3;
    float3  _S789 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_1)->f = _S789;
    float _S790 = r_3.jac * shifted_0.jac;
    (&candidate_1)->jac = _S790;
    offer(sel_3, candidate_1, make_float3 (mis_0) * shifted_0.f * make_float3 (r_3.w));
    return;
}

__device__ Reservoir finalize(Selection sel_4, float c_1)
{
    Reservoir r_4 = sel_4.r;
    float _S791 = rgb_to_greyscale((&r_4)->f);
    float _S792 = sel_4.w_sum / _S791;
    bool _S793 = _S791 > 0.0f;
    float _S794 = _slang_select(_S793, _S792,0.0f);
    (&r_4)->w = _S794;
    (&r_4)->c = c_1;
    return r_4;
}

static __device__ uint2  asuint_0(float2  x_19)
{
    uint2  result_8;
    int i_12 = int(0);
    for(;;)
    {
        if(i_12 < int(2))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_8, i_12) = (F32_asuint((_slang_vector_get_element(x_19, i_12))));
        i_12 = i_12 + int(1);
    }
    return result_8;
}

static __device__ void restir_spatial_0(uint3  global_invocation_id_2)
{
    uint2  _S795 = uint2 {global_invocation_id_2.x, global_invocation_id_2.y};
    int2  _S796 = make_int2 ((int)_S795.x, (int)_S795.y);
    float3  _S797 = make_float3 (0.0f);
    FKHit _S798 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S799 = Domain_x24init_0(_S797, _S797, &_S798, 0.0f, 0.0f);
    Domain dom_4 = _S799;
    bool _S800 = (fcptCurrentDomain((_S796), (&dom_4)));
    bool _S801 = !_S800;
    if(_S801)
    {
        Reservoir _S802 = (Reservoir{});
        fcptStoreReservoirPrevious((_S796), (_S802), ((&dom_4)->hit));
        return;
    }
    Reservoir _S803 = (fcptLoadReservoirTemporal((_S796)));
    uint t_12 = 0U;
    float count_4 = 0.0f;
    float c_sum_1 = _S803.c;
    for(;;)
    {
        uint _S804 = (fcptRestirNeighbours());
        if(t_12 < _S804)
        {
        }
        else
        {
            break;
        }
        int2  _S805 = partner_0(_S796, t_12);
        Domain neighbor_0 = _S799;
        bool _S806 = (fcptCurrentDomain((_S805), (&neighbor_0)));
        if(_S806)
        {
            float count_5 = count_4 + 1.0f;
            uint4  _S807 = (fcptReservoirTemporal((_S805), (0U)));
            float c_sum_2 = c_sum_1 + (U32_asfloat((_S807.w)));
            count_4 = count_5;
            c_sum_1 = c_sum_2;
        }
        uint t_13 = t_12 + 1U;
        t_12 = t_13;
    }
    float _S808 = _S803.c / (F32_max((count_4), (1.0f)));
    float _S809 = rgb_to_greyscale(_S803.f);
    bool _S810 = count_4 == 0.0f;
    float _S811 = _slang_select(_S810, 1.0f,0.0f);
    Selection _S812 = (Selection{});
    Selection sel_5 = _S812;
    uint _S813 = (fcptFrame());
    uint _S814 = hash(_S813);
    uint _S815 = global_invocation_id_2.x;
    uint2  _S816 = (fcptRenderSize());
    uint _S817 = stream(_S814, _S815 + _S816.x * global_invocation_id_2.y);
    uint _S818 = stream(_S817, 195U);
    (&sel_5)->random_state = _S818;
    t_12 = 0U;
    float canonical_mis_0 = _S811;
    for(;;)
    {
        uint _S819 = (fcptRestirNeighbours());
        if(t_12 < _S819)
        {
        }
        else
        {
            break;
        }
        int2  _S820 = partner_0(_S796, t_12);
        Domain neighbor_dom_0 = _S799;
        bool _S821 = (fcptCurrentDomain((_S820), (&neighbor_dom_0)));
        if(_S821)
        {
            Reservoir _S822 = (fcptLoadReservoirTemporal((_S820)));
            uint4  _S823 = (fcptShiftData((_S820), (t_12)));
            float4  _S824 = asfloat_0(_S823);
            uint4  _S825 = (fcptShiftData((_S796), (t_12)));
            float4  _S826 = asfloat_0(_S825);
            float _S827 = pairShare(_S822.c, _S808, c_sum_1);
            bool _S828 = _S809 > 0.0f;
            float canonical_mis_1;
            if(_S828)
            {
                float _S829 = rgb_to_greyscale(float3 {_S826.x, _S826.y, _S826.z});
                float _S830 = canonicalWeight(_S827, _S808, _S809, _S822.c, _S829);
                float canonical_mis_2 = canonical_mis_0 + _S830;
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            float3  _S831 = float3 {_S824.x, _S824.y, _S824.z};
            Shift _S832 = Shift_x24init_0(_S831, _S824.w);
            float _S833 = rgb_to_greyscale(_S822.f);
            float _S834 = rgb_to_greyscale(_S831);
            float _S835 = neighborWeight(_S827, _S822.c, _S833, _S808, _S834);
            offerShifted(&sel_5, _S822, _S832, _S835);
            canonical_mis_0 = canonical_mis_1;
        }
        uint t_14 = t_12 + 1U;
        t_12 = t_14;
    }
    offerShifted(&sel_5, _S803, Shift_x24init_0(_S803.f, 1.0f), canonical_mis_0);
    Reservoir _S836 = finalize(sel_5, c_sum_1);
    fcptStoreReservoirPrevious((_S796), (_S836), ((&dom_4)->hit));
    fcptStorePreviousLayer((_S796), (5U), (make_uint4 (asuint_0((&(&dom_4)->hit)->uv).x, asuint_0((&(&dom_4)->hit)->uv).y, 0U, 0U)));
    fcptAddColor((_S796), (make_float4 ((&sel_5)->color.x, (&sel_5)->color.y, (&sel_5)->color.z, 0.0f)));
    return;
}

static __device__ uint3  asuint_1(float3  x_20)
{
    uint3  result_9;
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
        *_slang_vector_get_element_ptr(&result_9, i_13) = (F32_asuint((_slang_vector_get_element(x_20, i_13))));
        i_13 = i_13 + int(1);
    }
    return result_9;
}

static __device__ void restir_shift_0(uint3  workgroup_id_1, uint local_invocation_index_4)
{
    uint _S837 = queuedShift_0(workgroup_id_1, local_invocation_index_4);
    bool _S838 = _S837 != 4294967295U;
    if(_S838)
    {
        uint2  _S839 = make_uint2 (_S837, _S837 >> 14U) & make_uint2 (16383U);
        int2  _S840 = make_int2 ((int)_S839.x, (int)_S839.y);
        ShiftJob _S841 = (ShiftJob{});
        ShiftJob shift_job_0 = _S841;
        Shift _S842 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
        uint _S843 = _S837 >> 28U;
        bool _S844 = spatialJob_0(_S840, _S843, &shift_job_0, true);
        Shift shifted_1;
        if(_S844)
        {
            Domain _S845 = (&shift_job_0)->dom;
            Reservoir _S846 = (&shift_job_0)->r;
            Shift _S847 = passShift_0(&_S845, &_S846);
            shifted_1 = _S847;
        }
        else
        {
            shifted_1 = _S842;
        }
        fcptStoreShiftData((_S840), (_S843), (make_uint4 (asuint_1(shifted_1.f).x, asuint_1(shifted_1.f).y, asuint_1(shifted_1.f).z, (F32_asuint((shifted_1.jac))))));
    }
    return;
}

static __device__ void restir_prepass_0(uint3  global_invocation_id_3, uint local_invocation_index_5)
{
    uint2  _S848 = uint2 {global_invocation_id_3.x, global_invocation_id_3.y};
    int2  _S849 = make_int2 ((int)_S848.x, (int)_S848.y);
    FixedArray<uint, 3>  _S850;
    spatialBins_0(_S849, &_S850);
    FixedArray<uint, 3>  _S851 = _S850;
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
        bool _S852 = (_S851[t_15]) == 40U;
        if(_S852)
        {
            fcptStoreShiftData((_S849), (t_15), (make_uint4 (0U)));
        }
        uint t_16 = t_15 + 1U;
        t_15 = t_16;
    }
    FixedArray<uint, 3>  _S853 = _S851;
    queueShifts_0(_S849, &_S853, global_invocation_id_3, local_invocation_index_5);
    return;
}

static __device__ void restir_count_0(uint3  global_invocation_id_4, uint local_invocation_index_6)
{
    uint2  _S854 = uint2 {global_invocation_id_4.x, global_invocation_id_4.y};
    int2  _S855 = make_int2 ((int)_S854.x, (int)_S854.y);
    FixedArray<uint, 3>  _S856;
    spatialBins_0(_S855, &_S856);
    FixedArray<uint, 3>  _S857 = _S856;
    countShifts_0(&_S857, local_invocation_index_6);
    return;
}

static __device__ void restir_temporal_shift_0(uint3  workgroup_id_2, uint local_invocation_index_7)
{
    uint _S858 = queuedShift_0(workgroup_id_2, local_invocation_index_7);
    bool _S859 = _S858 != 4294967295U;
    if(_S859)
    {
        uint2  _S860 = make_uint2 (_S858, _S858 >> 14U) & make_uint2 (16383U);
        int2  _S861 = make_int2 ((int)_S860.x, (int)_S860.y);
        ShiftJob _S862 = (ShiftJob{});
        ShiftJob shift_job_1 = _S862;
        Shift _S863 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
        uint _S864 = _S858 >> 28U;
        bool _S865 = temporalJob_0(_S861, _S864, &shift_job_1, true);
        Shift shifted_2;
        if(_S865)
        {
            if(_S864 == 1U)
            {
                Shift _S866 = (fcptShiftPrevious(((&shift_job_1)->dom), ((&shift_job_1)->r)));
                shifted_2 = _S866;
            }
            else
            {
                Domain _S867 = (&shift_job_1)->dom;
                Reservoir _S868 = (&shift_job_1)->r;
                Shift _S869 = passShift_0(&_S867, &_S868);
                shifted_2 = _S869;
            }
        }
        else
        {
            shifted_2 = _S863;
        }
        fcptStoreTemporalShift((_S861), (_S864), (make_uint4 (asuint_1(shifted_2.f).x, asuint_1(shifted_2.f).y, asuint_1(shifted_2.f).z, (F32_asuint((shifted_2.jac))))));
    }
    return;
}

static __device__ void restir_temporal_prepass_0(uint3  global_invocation_id_5, uint local_invocation_index_8)
{
    uint2  _S870 = uint2 {global_invocation_id_5.x, global_invocation_id_5.y};
    int2  _S871 = make_int2 ((int)_S870.x, (int)_S870.y);
    FixedArray<uint, 3>  _S872;
    temporalBins_0(_S871, &_S872);
    FixedArray<uint, 3>  _S873 = _S872;
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
        bool _S874 = (_S873[t_17]) == 40U;
        if(_S874)
        {
            fcptStoreTemporalShift((_S871), (t_17), (make_uint4 (0U)));
        }
        uint t_18 = t_17 + 1U;
        t_17 = t_18;
    }
    FixedArray<uint, 3>  _S875 = _S873;
    queueShifts_0(_S871, &_S875, global_invocation_id_5, local_invocation_index_8);
    return;
}

static __device__ void restir_temporal_count_0(uint3  global_invocation_id_6, uint local_invocation_index_9)
{
    uint2  _S876 = uint2 {global_invocation_id_6.x, global_invocation_id_6.y};
    int2  _S877 = make_int2 ((int)_S876.x, (int)_S876.y);
    bool _S878 = (fcptSceneUnchanged());
    bool _S879 = !_S878;
    bool _S880;
    if(_S879)
    {
        uint2  _S881 = (fcptRenderSize());
        int2  _S882 = make_int2 ((int)_S881.x, (int)_S881.y);
        _S880 = all_0(_S877 < _S882);
    }
    else
    {
        _S880 = false;
    }
    if(_S880)
    {
        Reservoir _S883 = (fcptLoadReservoirInitial((_S877)));
        int2  _S884 = sampleNeighbor_0(_S877, _S883.seed);
        fcptStoreTemporalNeighbor((_S877), (_S884));
    }
    FixedArray<uint, 3>  _S885;
    temporalBins_0(_S877, &_S885);
    FixedArray<uint, 3>  _S886 = _S885;
    countShifts_0(&_S886, local_invocation_index_9);
    return;
}

static __device__ float interpolate_0(float a_8, float b_4, float t_19)
{
    return a_8 + (b_4 - a_8) * t_19;
}

__device__ float confidenceCap(float duplicated_0)
{
    float _S887 = interpolate_0(20.0f, 1.0f, (F32_pow((duplicated_0), (0.10000000149011612f))));
    return _S887;
}

__device__ float2  temporalWeights(float c_2, float p_c_1, float c_t_0, float p_t_0, float g_previous_0, float g_current_0)
{
    float _S888 = c_2 * p_c_1;
    float _S889 = c_t_0 * p_t_0;
    return make_float2 (_S888 / (_S888 + c_t_0 * g_previous_0), _S889 / (_S889 + c_2 * g_current_0));
}

static __device__ void restir_temporal_0(uint3  global_invocation_id_7)
{
    uint2  _S890 = uint2 {global_invocation_id_7.x, global_invocation_id_7.y};
    int2  _S891 = make_int2 ((int)_S890.x, (int)_S890.y);
    float3  _S892 = make_float3 (0.0f);
    FKHit _S893 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S894 = Domain_x24init_0(_S892, _S892, &_S893, 0.0f, 0.0f);
    Domain dom_5 = _S894;
    bool _S895 = (fcptCurrentDomain((_S891), (&dom_5)));
    bool _S896 = !_S895;
    if(_S896)
    {
        Reservoir _S897 = (Reservoir{});
        fcptStoreReservoirTemporal((_S891), (_S897), ((&dom_5)->hit));
        return;
    }
    Reservoir _S898 = (fcptLoadReservoirInitial((_S891)));
    bool _S899 = (fcptSceneUnchanged());
    int2  _S900;
    if(_S899)
    {
        int2  _S901 = sampleNeighbor_0(_S891, _S898.seed);
        _S900 = _S901;
    }
    else
    {
        int2  _S902 = (fcptLoadTemporalNeighbor((_S891)));
        _S900 = _S902;
    }
    bool _S903 = (_S900.x) >= int(0);
    Reservoir r_5;
    if(_S903)
    {
        Reservoir _S904 = (fcptLoadReservoirPrevious((_S900)));
        uint4  _S905 = (fcptDuplication((_S900)));
        float _S906 = (U32_asfloat((_S905.x)));
        uint _S907 = (fcptRestirDecorrelation());
        bool _S908 = _S907 == 1U;
        float _S909 = _slang_select(_S908, _S906,0.0f);
        float _S910 = confidenceCap(_S909);
        float _S911 = (F32_min((_S904.c), (_S910)));
        bool _S912 = (fcptSceneUnchanged());
        float4  _S913;
        if(_S912)
        {
            _S913 = make_float4 (_S904.f.x, _S904.f.y, _S904.f.z, 1.0f);
        }
        else
        {
            uint4  _S914 = (fcptTemporalShift((_S891), (0U)));
            _S913 = asfloat_0(_S914);
        }
        Domain own_1 = _S894;
        bool _S915;
        if(_S912)
        {
            _S915 = true;
        }
        else
        {
            bool _S916 = (fcptPreviousScenes());
            bool _S917 = !_S916;
            if(_S917)
            {
                _S915 = (_S898.w) > 0.0f;
            }
            else
            {
                _S915 = false;
            }
            if(_S915)
            {
                bool _S918 = (fcptStoredDomainInitial((_S891), (_S898.seed), (&own_1)));
                _S915 = _S918;
            }
            else
            {
                _S915 = false;
            }
            if(_S915)
            {
                Domain _S919 = (fcptPreviousDomain((_S900), (_S898.seed)));
                Domain _S920 = _S919;
                Domain _S921 = own_1;
                bool _S922 = sameDomain_0(&_S920, &_S921);
                _S915 = _S922;
            }
            else
            {
                _S915 = false;
            }
        }
        float4  _S923;
        if(_S915)
        {
            _S923 = make_float4 (_S898.f.x, _S898.f.y, _S898.f.z, 1.0f);
        }
        else
        {
            uint4  _S924 = (fcptTemporalShift((_S891), (1U)));
            _S923 = asfloat_0(_S924);
        }
        float _S925 = rgb_to_greyscale(_S898.f);
        float _S926 = rgb_to_greyscale(_S904.f);
        Selection _S927 = (Selection{});
        Selection sel_6 = _S927;
        uint _S928 = (fcptFrame());
        uint _S929 = hash(_S928);
        uint _S930 = global_invocation_id_7.x;
        uint2  _S931 = (fcptRenderSize());
        uint _S932 = stream(_S929, _S930 + _S931.x * global_invocation_id_7.y);
        uint _S933 = stream(_S932, 194U);
        (&sel_6)->random_state = _S933;
        float4  _S934 = _S923;
        float _S935 = rgb_to_greyscale(float3 {_S934.x, _S934.y, _S934.z});
        float4  _S936 = _S913;
        float3  _S937 = float3 {_S936.x, _S936.y, _S936.z};
        float _S938 = rgb_to_greyscale(_S937);
        float2  _S939 = temporalWeights(_S898.c, _S925, _S911, _S926, _S935, _S938);
        offerShifted(&sel_6, _S898, Shift_x24init_0(_S898.f, 1.0f), _S939.x);
        offerShifted(&sel_6, _S904, Shift_x24init_0(_S937, _S913.w), _S939.y);
        Reservoir _S940 = finalize(sel_6, _S898.c + _S911);
        r_5 = _S940;
    }
    else
    {
        r_5 = _S898;
    }
    fcptStoreReservoirTemporal((_S891), (r_5), ((&dom_5)->hit));
    return;
}

static __device__ void restir_initial_0(uint3  global_invocation_id_8)
{
    uint2  _S941 = uint2 {global_invocation_id_8.x, global_invocation_id_8.y};
    int2  _S942 = make_int2 ((int)_S941.x, (int)_S941.y);
    float3  _S943 = make_float3 (0.0f);
    float2  _S944 = make_float2 (0.0f);
    FKHit _S945 = Hit_x24init_0(_S944, 0U, 0U, 0U, 0.0f);
    Domain _S946 = Domain_x24init_0(_S943, _S943, &_S945, 0.0f, 0.0f);
    Domain dom_6 = _S946;
    bool _S947 = (fcptCurrentDomain((_S942), (&dom_6)));
    bool _S948 = !_S947;
    if(_S948)
    {
        Reservoir _S949 = (Reservoir{});
        fcptStoreReservoirInitial((_S942), (_S949), ((&dom_6)->hit));
        return;
    }
    uint _S950 = (fcptFrame());
    uint _S951 = hash(_S950);
    uint _S952 = global_invocation_id_8.x;
    uint2  _S953 = (fcptRenderSize());
    uint _S954 = stream(_S951, _S952 + _S953.x * global_invocation_id_8.y);
    Selection _S955 = (Selection{});
    Selection initial_0 = _S955;
    uint _S956 = stream(_S954, 193U);
    (&initial_0)->random_state = _S956;
    bool _S957 = (fcptRestirUsed());
    bool _S958 = !_S957;
    (&initial_0)->sums = _S958;
    uint _S959 = stream(_S954, 0U);
    (&(&initial_0)->r)->seed = _S959;
    FKHit _S960 = Hit_x24init_0(_S944, 4294967295U, 0U, 0U, 0.0f);
    uint _S961 = (fcptSamples());
    float _S962 = 1.0f / float(_S961);
    FKHit hit_2 = _S960;
    uint i_14 = 0U;
    for(;;)
    {
        uint _S963 = (fcptSamples());
        if(i_14 < _S963)
        {
        }
        else
        {
            break;
        }
        Reservoir _S964 = (Reservoir{});
        Reservoir r_6 = _S964;
        uint _S965 = stream(_S954, i_14);
        (&r_6)->seed = _S965;
        Domain path_0 = _S946;
        bool _S966 = (fcptStoredDomainInitial((_S942), ((&r_6)->seed), (&path_0)));
        bool _S967 = !_S966;
        if(_S967)
        {
            fcptMissed((_S942), (path_0), (_S962));
            uint i_15 = i_14 + 1U;
            i_14 = i_15;
            continue;
        }
        Domain _S968 = path_0;
        Reservoir _S969 = r_6;
        Shift _S970 = passWalk_0(&_S968, &_S969, false, _S962, &initial_0);
        bool _S971 = ((&(&initial_0)->r)->seed) == ((&r_6)->seed);
        FKHit hit_3;
        if(_S971)
        {
            FKHit _S972 = (&path_0)->hit;
            hit_3 = _S972;
        }
        else
        {
            hit_3 = hit_2;
        }
        hit_2 = hit_3;
        uint i_15 = i_14 + 1U;
        i_14 = i_15;
    }
    float3  _S973 = (&initial_0)->glow;
    float3  _S974 = (&initial_0)->color;
    bool _S975 = (&initial_0)->sums;
    float3  _S976 = _slang_select(_S975, _S974,_S943);
    fcptAddColor((_S942), (make_float4 ((_S973 + _S976).x, (_S973 + _S976).y, (_S973 + _S976).z, 1.0f)));
    Reservoir _S977 = finalize(initial_0, 1.0f);
    fcptStoreReservoirInitial((_S942), (_S977), (hit_2));
    return;
}

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_5, float3  origin_5, float3  smooth_n_3, float3  start_6)
{
    NEEVertex _S978;
    (&_S978)->none = none_0;
    (&_S978)->pdf = pdf_5;
    (&_S978)->origin = origin_5;
    (&_S978)->smooth_n = smooth_n_3;
    (&_S978)->start = start_6;
    return _S978;
}

struct Vertex
{
    bool rough;
    uint lobe;
    float pdf;
    float cos;
    bool inside;
};

static __device__ Vertex Vertex_x24init_0(bool rough_0, uint lobe_1, float pdf_6, float cos_0, bool inside_0)
{
    Vertex _S979;
    (&_S979)->rough = rough_0;
    (&_S979)->lobe = lobe_1;
    (&_S979)->pdf = pdf_6;
    (&_S979)->cos = cos_0;
    (&_S979)->inside = inside_0;
    return _S979;
}

static __device__ float freeFlight_0(float u_1, float sigma_0)
{
    return - (F32_log((1.0f - u_1))) / sigma_0;
}

static __device__ float3  exp_0(float3  x_21)
{
    float3  result_10;
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
        *_slang_vector_get_element_ptr(&result_10, i_16) = (F32_exp((_slang_vector_get_element(x_21, i_16))));
        i_16 = i_16 + int(1);
    }
    return result_10;
}

static __device__ float3  flightWeight_0(float3  scatter_0, float3  extinction_0, float sigma_1, float distance_2, bool scatters_0)
{
    float3  _S980 = exp_0((make_float3 (sigma_1) - extinction_0) * make_float3 (distance_2));
    float3  _S981 = scatter_0 * _S980 / make_float3 (sigma_1);
    float3  _S982 = _slang_select(scatters_0, _S981,_S980);
    return _S982;
}

static __device__ bool scatterSampled_0(bool replay_1, uint b_5, uint stop_0, bool varying_0)
{
    bool _S983 = !replay_1;
    bool _S984;
    if(_S983)
    {
        _S984 = true;
    }
    else
    {
        bool _S985 = b_5 == stop_0;
        if(_S985)
        {
            _S984 = !varying_0;
        }
        else
        {
            _S984 = false;
        }
    }
    return _S984;
}

static __device__ uint arrivalLobe_0(uint b_6, uint prev_lobe_0)
{
    bool _S986 = b_6 > 0U;
    uint _S987 = _slang_select(_S986, prev_lobe_0,3U);
    return _S987;
}

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_0, uint depth_1, uint lobe_2, bool surface_4, float length_2, float width_1, FKHit * own_2, bool fiber_0)
{
    ShadowContext _S988;
    (&_S988)->extinction_behind = extinction_behind_0;
    (&_S988)->extinction_front = extinction_front_0;
    (&_S988)->fillings = fillings_0;
    (&_S988)->side = side_0;
    (&_S988)->depth = depth_1;
    (&_S988)->lobe = lobe_2;
    (&_S988)->surface = surface_4;
    (&_S988)->length = length_2;
    (&_S988)->width = width_1;
    (&_S988)->own = *own_2;
    (&_S988)->fiber = fiber_0;
    return _S988;
}

static __device__ float phaseHG_0(float g_0, float mu_0)
{
    bool _S989 = (F32_abs((g_0))) < 0.00100000004749745f;
    if(_S989)
    {
        return 0.07957746833562851f;
    }
    float _S990 = g_0 * g_0;
    return (1.0f - _S990) * 0.25f * 0.31830987334251404f / (F32_pow((1.0f + _S990 - 2.0f * g_0 * mu_0), (1.5f)));
}

__device__ float3  safeDivide(float3  a_9, float3  b_7)
{
    float3  _S991 = a_9 / b_7;
    float3  _S992 = make_float3 (0.0f);
    bool3  _S993 = b_7 == _S992;
    float3  _S994 = _slang_select(_S993, _S992,_S991);
    return _S994;
}

static __device__ uint insertBits_0(uint e_2, uint newbits_0, uint offset_1, uint count_6)
{
    uint _S995 = (1U << count_6) - 1U;
    return (e_2 & (~(_S995 << offset_1))) | ((newbits_0 & _S995) << offset_1);
}

__device__ Reservoir withEnd(Reservoir r_7, uint end_type_0, uint end_0, float3  f_5)
{
    Reservoir candidate_2 = r_7;
    uint _S996 = insertBits_0(r_7.path, end_0, 0U, 5U);
    uint _S997 = insertBits_0(_S996, end_type_0, 12U, 3U);
    (&candidate_2)->path = _S997;
    (&candidate_2)->f = f_5;
    return candidate_2;
}

__device__ float survivalProbability(float3  throughput_2, float density_1)
{
    return (F32_min(((F32_max(((F32_max((throughput_2.x), ((F32_max((throughput_2.y), (throughput_2.z)))))) / density_1), (0.0f)))), (1.0f)));
}

static __device__ float3  isotropic_0(uint random_state_9)
{
    Random _S998 = pcg(random_state_9);
    Random _S999 = pcg(_S998.state);
    float _S1000 = 1.0f - 2.0f * _S998.value;
    float _S1001 = (F32_sqrt(((F32_max((1.0f - _S1000 * _S1000), (0.0f))))));
    float _S1002 = 6.28318548202514648f * _S999.value;
    return make_float3 (_S1001 * (F32_cos((_S1002))), _S1001 * (F32_sin((_S1002))), _S1000);
}

static __device__ float3  samplePhase_0(float g_1, float3  dir_10, uint random_state_10, float * pdf_7)
{
    bool _S1003 = (F32_abs((g_1))) < 0.00100000004749745f;
    if(_S1003)
    {
        *pdf_7 = 0.07957746833562851f;
        float3  _S1004 = isotropic_0(random_state_10);
        return _S1004;
    }
    Random _S1005 = pcg(random_state_10);
    Random _S1006 = pcg(_S1005.state);
    float _S1007 = g_1 * g_1;
    float _S1008 = 2.0f * g_1;
    float _S1009 = (1.0f - _S1007) / (1.0f - g_1 + _S1008 * _S1005.value);
    float _S1010 = clamp_1((1.0f + _S1007 - _S1009 * _S1009) / _S1008, -1.0f, 1.0f);
    float _S1011 = (F32_sqrt(((F32_max((1.0f - _S1010 * _S1010), (0.0f))))));
    float _S1012 = 6.28318548202514648f * _S1006.value;
    float _S1013 = phaseHG_0(g_1, _S1010);
    *pdf_7 = _S1013;
    float3  _S1014 = tangentToWorld(make_float3 (_S1011 * (F32_cos((_S1012))), _S1010, _S1011 * (F32_sin((_S1012)))), dir_10);
    float3  _S1015 = ((((_S1014)) * make_float3(rnorm3df(((_S1014)).x, ((_S1014)).y, ((_S1014)).z))));
    return _S1015;
}

static __device__ Vertex scatteredVertex_0(bool is_inside_4)
{
    return Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_4);
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_0, float3  emissive_0, float roughness_0, float metallic_0, float transmission_0, float ior_0, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_2, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_2, float velvet_0, float3  toon_2)
{
    BSDFMaterial _S1016;
    (&_S1016)->albedo = albedo_0;
    (&_S1016)->emissive = emissive_0;
    (&_S1016)->roughness = roughness_0;
    (&_S1016)->metallic = metallic_0;
    (&_S1016)->transmission = transmission_0;
    (&_S1016)->ior = ior_0;
    (&_S1016)->absorption = absorption_0;
    (&_S1016)->specular_tint = specular_tint_0;
    (&_S1016)->specular_level = specular_level_0;
    (&_S1016)->translucent = translucent_0;
    (&_S1016)->sheen = sheen_2;
    (&_S1016)->sheen_roughness = sheen_roughness_0;
    (&_S1016)->anisotropy = anisotropy_0;
    (&_S1016)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S1016)->tangent = tangent_2;
    (&_S1016)->velvet = velvet_0;
    (&_S1016)->toon = toon_2;
    return _S1016;
}

static __device__ FKMedium Medium_x24init_0(float3  scatter_1, float3  extinction_1, float g_2)
{
    FKMedium _S1017;
    (&_S1017)->scatter = scatter_1;
    (&_S1017)->extinction = extinction_1;
    (&_S1017)->g = g_2;
    return _S1017;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_11, bool skip_0, uint random_state_11, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S1018;
    (&_S1018)->smooth_n = smooth_n_4;
    (&_S1018)->geometry_n = geometry_n_2;
    (&_S1018)->geometry_offset = geometry_offset_2;
    (&_S1018)->material = *material_11;
    (&_S1018)->skip = skip_0;
    (&_S1018)->random_state = random_state_11;
    (&_S1018)->coverage = coverage_0;
    (&_S1018)->encloses = encloses_0;
    (&_S1018)->volume = *volume_0;
    (&_S1018)->fills = fills_0;
    (&_S1018)->hair = hair_0;
    return _S1018;
}

static __device__ FKSurface emitting_0(FKSurface * surface_5, bool top_0)
{
    FKSurface lower_0 = *surface_5;
    float3  _S1019 = (&surface_5->material)->emissive;
    float3  _S1020 = make_float3 (0.0f);
    bool _S1021 = !top_0;
    float3  _S1022 = _slang_select(_S1021, _S1020,_S1019);
    (&(&lower_0)->material)->emissive = _S1022;
    return lower_0;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_6, float u_2)
{
    float _S1023 = surface_6->coverage;
    bool _S1024 = u_2 < _S1023;
    if(_S1024)
    {
        return *surface_6;
    }
    float3  _S1025 = make_float3 (0.0f);
    float3  _S1026 = make_float3 (1.0f);
    BSDFMaterial _S1027 = Material_x24init_0(_S1025, _S1025, 0.0f, 0.0f, 0.0f, 0.0f, _S1025, _S1026, 1.0f, _S1025, _S1025, 0.5f, 0.0f, 0.0f, _S1025, 0.0f, _S1025);
    BSDFMaterial material_12 = _S1027;
    (&material_12)->albedo = _S1026;
    (&material_12)->emissive = (&surface_6->material)->emissive;
    (&material_12)->transmission = 1.0f;
    (&material_12)->ior = 1.0f;
    (&material_12)->absorption = (&surface_6->material)->absorption;
    FKSurface through_0 = *surface_6;
    (&through_0)->material = material_12;
    return through_0;
}

__device__ float facingSign(float transmission_1, float3  face_0, float3  direction_0)
{
    bool _S1028 = transmission_1 > 0.0f;
    bool _S1029;
    if(_S1028)
    {
        _S1029 = true;
    }
    else
    {
        _S1029 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S1030;
    if(_S1029)
    {
        _S1030 = 1.0f;
    }
    else
    {
        _S1030 = -1.0f;
    }
    return _S1030;
}

static __device__ bool arrivesBehind_0(float3  dir_11, float3  n_10)
{
    return (dot_0(dir_11, n_10)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_7, float3  dir_12)
{
    float3  _S1031 = surface_7->geometry_n;
    float _S1032 = facingSign((&surface_7->material)->transmission, surface_7->geometry_n, dir_12);
    FKSurface faced_0 = *surface_7;
    float3  _S1033 = surface_7->smooth_n * make_float3 (_S1032);
    (&faced_0)->smooth_n = _S1033;
    float3  _S1034 = _S1031 * make_float3 (_S1032);
    (&faced_0)->geometry_n = _S1034;
    return faced_0;
}

static __device__ float3  max_0(float3  x_22, float3  y_7)
{
    float3  result_11;
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
        *_slang_vector_get_element_ptr(&result_11, i_17) = (F32_max((_slang_vector_get_element(x_22, i_17)), (_slang_vector_get_element(y_7, i_17))));
        i_17 = i_17 + int(1);
    }
    return result_11;
}

static __device__ float3  log_0(float3  x_23)
{
    float3  result_12;
    int i_18 = int(0);
    for(;;)
    {
        if(i_18 < int(3))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_12, i_18) = (F32_log((_slang_vector_get_element(x_23, i_18))));
        i_18 = i_18 + int(1);
    }
    return result_12;
}

__device__ float3  beerLambert(float distance_3, float3  absorption_1)
{
    float3  _S1035 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_3) * log_0(_S1035));
}

__device__ float geometryDensity(float3  geometry_n_3, float3  direction_1, float distance_4)
{
    return (F32_abs((dot_0(geometry_n_3, direction_1)))) / (distance_4 * distance_4);
}

__device__ float footprintThreshold(float geometry_density_0)
{
    return 0.00251327408477664f / geometry_density_0;
}

__device__ bool withinFootprint(bool open_0, bool prev_rough_0, float prev_pdf_0, float geometry_density_1, float threshold_0)
{
    bool _S1036;
    if(open_0)
    {
        _S1036 = prev_rough_0;
    }
    else
    {
        _S1036 = false;
    }
    if(_S1036)
    {
        _S1036 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S1036 = false;
    }
    return _S1036;
}

__device__ float2  vertexEta(BSDFMaterial material_13, float n_dot_v_0)
{
    bool _S1037 = n_dot_v_0 < 0.0f;
    float _S1038 = _slang_select(_S1037, material_13.ior,1.0f);
    float _S1039 = _slang_select(_S1037, 1.0f,material_13.ior);
    return make_float2 (_S1038, _S1039);
}

__device__ bool neeDecision(BSDFMaterial material_14, float n_dot_v_1, float eta_i_10, float eta_o_10)
{
    float _S1040 = fresnel((F32_abs((n_dot_v_1))), eta_i_10, eta_o_10);
    float3  _S1041 = mix_0(make_float3 (_S1040), material_14.albedo, material_14.metallic);
    float _S1042 = rgb_to_greyscale(_S1041);
    float _S1043 = (F32_max(((1.0f - _S1042) * (1.0f - material_14.metallic) * (1.0f - material_14.transmission)), (0.0f)));
    bool _S1044 = _S1043 > 0.03999999910593033f;
    bool _S1045;
    if(_S1044)
    {
        _S1045 = true;
    }
    else
    {
        _S1045 = (material_14.roughness) > 0.20000000298023224f;
    }
    return _S1045;
}

static __device__ bool isTranslucent_0(BSDFMaterial * material_15)
{
    float _S1046 = rgb_to_greyscale(material_15->translucent);
    return _S1046 > 0.0f;
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
    MediumSides _S1047;
    (&_S1047)->behind = *behind_0;
    (&_S1047)->front = *front_0;
    (&_S1047)->fillings = fillings_1;
    (&_S1047)->face = face_1;
    return _S1047;
}

static __device__ MediumSides mediumSides_0(FKSurface * surface_8, FKMedium * medium_0, uint filling_0, float3  dir_13, FKMedium * outside_0)
{
    float3  _S1048 = surface_8->geometry_n;
    MediumSides _S1049 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_8->geometry_n);
    MediumSides sides_0 = _S1049;
    bool _S1050 = surface_8->encloses;
    if(_S1050)
    {
        (&sides_0)->behind = surface_8->volume;
        *&((&(&sides_0)->fillings)->x) = surface_8->fills;
        bool _S1051 = (dot_0(dir_13, _S1048)) > 0.0f;
        if(_S1051)
        {
            (&sides_0)->front = *outside_0;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_9, bool turned_0, float3  extinction_2, uint filling_1, float3  dir_14, uint depth_2, uint lobe_3, float length_3, float width_2, FKHit * own_3, bool fiber_1, FKMedium * outside_1)
{
    float3  _S1052 = surface_9->geometry_n;
    ShadowContext _S1053 = ShadowContext_x24init_0(extinction_2, extinction_2, make_uint2 (filling_1), surface_9->geometry_n, depth_2, lobe_3, true, length_3, width_2, own_3, fiber_1);
    bool _S1054 = surface_9->encloses;
    ShadowContext context_4;
    if(_S1054)
    {
        FKSurface faced_1 = *surface_9;
        float3  _S1055 = - _S1052;
        float3  _S1056 = _slang_select(turned_0, _S1055,_S1052);
        (&faced_1)->geometry_n = _S1056;
        FKMedium _S1057 = Medium_x24init_0(make_float3 (0.0f), extinction_2, 0.0f);
        FKSurface _S1058 = faced_1;
        FKMedium _S1059 = _S1057;
        MediumSides _S1060 = mediumSides_0(&_S1058, &_S1059, filling_1, dir_14, outside_1);
        ShadowContext _S1061 = ShadowContext_x24init_0(_S1060.behind.extinction, _S1060.front.extinction, _S1060.fillings, _S1052, depth_2, lobe_3, true, length_3, width_2, own_3, fiber_1);
        if(turned_0)
        {
            uint2  _S1062 = _S1060.fillings;
            ShadowContext _S1063 = ShadowContext_x24init_0(_S1060.front.extinction, _S1060.behind.extinction, uint2 {_S1062.y, _S1062.x}, _S1052, depth_2, lobe_3, true, length_3, width_2, own_3, fiber_1);
            context_4 = _S1063;
        }
        else
        {
            context_4 = _S1061;
        }
    }
    else
    {
        context_4 = _S1053;
    }
    return context_4;
}

static __device__ bool any_1(bool3  x_24)
{
    bool result_13 = false;
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
        if(result_13)
        {
            result_13 = true;
        }
        else
        {
            result_13 = (bool((_slang_vector_get_element(x_24, i_19))));
        }
        i_19 = i_19 + int(1);
    }
    return result_13;
}

__device__ __forceinline__ float3  BSDF(float3  in_dir_8, float3  out_dir_2, float3  n_11, float3  g_n_0, BSDFMaterial material_16, float eta_i_11, float eta_o_11, uint random_state_12)
{
    float3  _S1064 = negate_0(in_dir_8);
    float _S1065 = dot_0(n_11, _S1064);
    float _S1066 = sign_0(_S1065);
    float3  _S1067 = n_11 * make_float3 (_S1066);
    AnisotropicFrame _S1068 = anisotropicFrame(material_16, _S1067);
    float _S1069 = dot_0(_S1067, out_dir_2);
    float _S1070 = material_16.roughness;
    float _S1071 = _S1070 * _S1070;
    bool _S1072 = (dot_0(g_n_0, _S1064) * dot_0(g_n_0, out_dir_2)) > 0.0f;
    uint _S1073;
    if((F32_abs((material_16.toon.x))) > 0.0f)
    {
        _S1073 = 1U;
    }
    else
    {
        _S1073 = 0U;
    }
    if(_S1072)
    {
        _S1073 = 3U + _S1073;
    }
    else
    {
        _S1073 = 1U;
    }
    float3  _S1074 = make_float3 (0.0f);
    BSDFLobes _S1075 = BSDFLobes_x24init_0(0.0f, 0.0f, _S1074, _S1074, 0.0f, 0.0f, _S1074, _S1074, 0.0f, 0.0f, 0.0f, 0.0f, _S1074, 0.0f, _S1074, _S1074, make_float2 (0.0f), 0.0f, 0.0f, _S1074, 0.0f, 0.0f, 0.0f, false, 1.0f, 0.0f, _S1074);
    BSDFLobes lobe_terms_1 = _S1075;
    uint half_of_2 = 4294967295U;
    float3  ggx_n_3 = _S1074;
    float3  f_6 = _S1074;
    uint i_20 = 0U;
    for(;;)
    {
        if(i_20 < _S1073)
        {
        }
        else
        {
            break;
        }
        uint _S1076;
        if(!_S1072)
        {
            _S1076 = 1U;
        }
        else
        {
            if(i_20 == 0U)
            {
                _S1076 = 0U;
            }
            else
            {
                if(i_20 == 1U)
                {
                    _S1076 = 2U;
                }
                else
                {
                    if(i_20 == 2U)
                    {
                        _S1076 = 4U;
                    }
                    else
                    {
                        _S1076 = 6U;
                    }
                }
            }
        }
        uint _S1077;
        if(_S1076 == 6U)
        {
            _S1077 = 0U;
        }
        else
        {
            if(_S1076 == 4U)
            {
                _S1077 = 2U;
            }
            else
            {
                _S1077 = _S1076;
            }
        }
        bool _S1078 = _S1077 != half_of_2;
        float3  ggx_n_4;
        if(_S1078)
        {
            bool _S1079 = _S1077 == 0U;
            if(_S1079)
            {
                float3  _S1080 = sampledHalf(in_dir_8, n_11, material_16, random_state_12, _S1068);
                ggx_n_4 = _S1080;
            }
            else
            {
                bool _S1081 = _S1077 == 1U;
                if(_S1081)
                {
                    float3  _S1082 = refractedHalf(in_dir_8, out_dir_2, n_11, eta_i_11, eta_o_11);
                    ggx_n_4 = _S1082;
                }
                else
                {
                    float3  _S1083 = reflectedHalf(in_dir_8, out_dir_2);
                    ggx_n_4 = _S1083;
                }
            }
            float3  _S1084 = negate_0(in_dir_8);
            BSDFLobes _S1085 = bsdfLobes(in_dir_8, _S1084, _S1067, ggx_n_4, material_16, eta_i_11, eta_o_11, _S1068);
            lobe_terms_1 = _S1085;
            float _S1086 = translucentShare(material_16);
            (&lobe_terms_1)->translucent_share = _S1086;
            half_of_2 = _S1077;
        }
        else
        {
            ggx_n_4 = ggx_n_3;
        }
        float3  throughput_3;
        float pdf_8;
        switch(_S1076)
        {
        case 0U:
            {
                float _S1087 = diffusePDF(_S1069, 0.0f, (F32_abs((_S1065))), _S1071, lobe_terms_1, eta_i_11, eta_o_11);
                float3  _S1088 = diffuseBSDF(out_dir_2, _S1067, _S1071, material_16, lobe_terms_1);
                pdf_8 = _S1087;
                throughput_3 = _S1088;
                break;
            }
        case 1U:
            {
                float _S1089 = refractPDF(_S1069, dot_0(out_dir_2, ggx_n_4), (F32_abs((_S1065))), _S1071, lobe_terms_1, eta_i_11, eta_o_11);
                float3  _S1090 = refractBSDF(out_dir_2, _S1067, _S1071, material_16, lobe_terms_1);
                pdf_8 = _S1089;
                throughput_3 = _S1090;
                break;
            }
        case 4U:
            {
                float _S1091 = sheenVelvetPDF(_S1069, 0.0f, (F32_abs((_S1065))), _S1071, lobe_terms_1, eta_i_11, eta_o_11);
                float3  _S1092 = sheenVelvetBSDF(out_dir_2, _S1067, _S1071, material_16, lobe_terms_1);
                pdf_8 = _S1091;
                throughput_3 = _S1092;
                break;
            }
        case 6U:
            {
                float _S1093 = toonPDF(_S1069, dot_0(out_dir_2, (&lobe_terms_1)->toon_axis), (F32_abs((_S1065))), _S1071, lobe_terms_1, eta_i_11, eta_o_11);
                float3  _S1094 = toonBSDF(out_dir_2, _S1067, _S1071, material_16, lobe_terms_1);
                pdf_8 = _S1093;
                throughput_3 = _S1094;
                break;
            }
        default:
            {
                float _S1095 = reflectPDF(_S1069, 0.0f, (F32_abs((_S1065))), _S1071, lobe_terms_1, eta_i_11, eta_o_11);
                float3  _S1096 = reflectBSDF(out_dir_2, _S1067, _S1071, material_16, lobe_terms_1);
                pdf_8 = _S1095;
                throughput_3 = _S1096;
                break;
            }
        }
        float3  _S1097;
        if(pdf_8 > 0.0f)
        {
            _S1097 = throughput_3 * make_float3 (pdf_8);
        }
        else
        {
            _S1097 = _S1074;
        }
        if(i_20 == 0U)
        {
            f_6 = _S1097;
        }
        else
        {
            f_6 = f_6 + _S1097;
        }
        uint i_21 = i_20 + 1U;
        ggx_n_3 = ggx_n_4;
        i_20 = i_21;
    }
    return f_6;
}

__device__ float3  translucentCorrection(float3  in_dir_9, float3  out_dir_3, float3  n_12, float3  g_n_1, BSDFMaterial material_17, float eta_i_12, float eta_o_12, uint random_state_13)
{
    float _S1098 = dot_0(n_12, out_dir_3);
    float3  _S1099 = negate_0(in_dir_9);
    bool _S1100 = (_S1098 * dot_0(n_12, _S1099)) < 0.0f;
    float3  _S1101 = negate_0(in_dir_9);
    float _S1102 = dot_0(n_12, _S1101);
    float _S1103 = sign_0(_S1102);
    float3  _S1104 = n_12 * make_float3 (_S1103);
    AnisotropicFrame _S1105 = anisotropicFrame(material_17, _S1104);
    float _S1106 = material_17.roughness;
    float _S1107 = _S1106 * _S1106;
    float3  _S1108 = negate_0(in_dir_9);
    float3  _S1109 = sampledHalf(in_dir_9, n_12, material_17, random_state_13, _S1105);
    BSDFLobes _S1110 = bsdfLobes(in_dir_9, _S1108, _S1104, _S1109, material_17, eta_i_12, eta_o_12, _S1105);
    BSDFLobes sampled_0 = _S1110;
    float _S1111 = translucentShare(material_17);
    (&sampled_0)->translucent_share = _S1111;
    float _S1112 = diffusePDF(dot_0(_S1104, out_dir_3), 0.0f, (F32_abs((_S1102))), _S1107, sampled_0, eta_i_12, eta_o_12);
    float3  _S1113;
    if(_S1112 > 0.0f)
    {
        float3  _S1114 = diffuseBSDF(out_dir_3, _S1104, _S1107, material_17, sampled_0);
        _S1113 = _S1114 * make_float3 (_S1112);
    }
    else
    {
        _S1113 = make_float3 (0.0f);
    }
    float3  _S1115 = negate_0(in_dir_9);
    bool _S1116 = (dot_0(g_n_1, _S1115) * dot_0(g_n_1, out_dir_3)) > 0.0f;
    float3  _S1117 = make_float3 (0.0f);
    float _S1118 = _slang_select(_S1116, -1.0f,1.0f);
    float3  _S1119 = _S1113 * make_float3 (_S1118);
    float3  _S1120 = _slang_select(_S1100, _S1119,_S1117);
    return _S1120;
}

__device__ float3  translucentBSDF(float3  in_dir_10, float3  out_dir_4, float3  n_13, float3  g_n_2, BSDFMaterial material_18, float eta_i_13, float eta_o_13, uint random_state_14)
{
    float3  _S1121 = BSDF(in_dir_10, out_dir_4, n_13, g_n_2, material_18, eta_i_13, eta_o_13, random_state_14);
    float3  _S1122 = translucentCorrection(in_dir_10, out_dir_4, n_13, g_n_2, material_18, eta_i_13, eta_o_13, random_state_14);
    return _S1121 + _S1122;
}

static __device__ __forceinline__ float3  lightBSDF_0(float3  in_dir_11, TreeSample * light_2, float3  smooth_n_5, float3  geometry_n_4, BSDFMaterial * material_19, float eta_i_14, float eta_o_14, bool competing_1, uint random_state_15)
{
    bool _S1123 = !competing_1;
    bool _S1124;
    if(_S1123)
    {
        _S1124 = true;
    }
    else
    {
        _S1124 = (light_2->density) == 0.0f;
    }
    if(_S1124)
    {
        bool _S1125 = isTranslucent_0(material_19);
        if(_S1125)
        {
            float3  _S1126 = translucentBSDF(in_dir_11, light_2->dir, smooth_n_5, geometry_n_4, *material_19, eta_i_14, eta_o_14, random_state_15);
            return _S1126 * light_2->radiance;
        }
        float3  _S1127 = BSDF(in_dir_11, light_2->dir, smooth_n_5, geometry_n_4, *material_19, eta_i_14, eta_o_14, random_state_15);
        return _S1127 * light_2->radiance;
    }
    float3  _S1128 = light_2->dir;
    bool _S1129 = (dot_0(geometry_n_4, - in_dir_11) * dot_0(geometry_n_4, light_2->dir)) <= 0.0f;
    float3  _S1130 = neeBSDF(in_dir_11, _S1128, smooth_n_5, *material_19, eta_i_14, eta_o_14, _S1129, light_2->density, true, random_state_15);
    return _S1130 * light_2->radiance * make_float3 (light_2->density);
}

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_4, uint random_state_16, bool refracted_4, uint lobe_4, float pdf_9)
{
    SampleBSDF _S1131;
    (&_S1131)->unit_direction = unit_direction_1;
    (&_S1131)->throughput = throughput_4;
    (&_S1131)->random_state = random_state_16;
    (&_S1131)->refracted = refracted_4;
    (&_S1131)->lobe = lobe_4;
    (&_S1131)->pdf = pdf_9;
    return _S1131;
}

__device__ __forceinline__ SampleBSDF sheenVelvetSample(float3  n_i_8, float n_i_dot_v_6, float alpha_15, BSDFMaterial material_20, BSDFLobes lobes_11, float eta_i_15, float eta_o_15, uint random_state_17)
{
    float3  _S1132 = make_float3 (1.0f);
    SampleBSDF _S1133 = SampleBSDF_x24init_0(_S1132, _S1132, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S1133;
    Random _S1134 = pcg(random_state_17);
    Random _S1135 = pcg(_S1134.state);
    (&sample_1)->random_state = _S1135.state;
    float _S1136 = _S1134.value;
    float _S1137 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1136 * _S1136))))));
    float _S1138 = 6.28318548202514648f * _S1135.value;
    float3  _S1139 = tangentToWorld(make_float3 (_S1137 * (F32_cos((_S1138))), _S1134.value, _S1137 * (F32_sin((_S1138)))), n_i_8);
    (&sample_1)->unit_direction = _S1139;
    (&sample_1)->lobe = 4U;
    float3  _S1140 = sheenVelvetBSDF((&sample_1)->unit_direction, n_i_8, alpha_15, material_20, lobes_11);
    (&sample_1)->throughput = _S1140;
    float _S1141 = sheenVelvetPDF(_S1134.value, 0.0f, n_i_dot_v_6, alpha_15, lobes_11, eta_i_15, eta_o_15);
    (&sample_1)->pdf = _S1141;
    return sample_1;
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S1142 = (F32_sqrt((random_1_0)));
    float _S1143 = 6.28318548202514648f * random_2_0;
    float _S1144 = _S1142 * (F32_cos((_S1143)));
    float _S1145 = _S1142 * (F32_sin((_S1143)));
    float _S1146 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1144 * _S1144 - _S1145 * _S1145))))));
    return make_float3 (_S1144, _S1146, _S1145);
}

__device__ __forceinline__ SampleBSDF diffuseSample(float u_3, float3  n_i_9, float n_i_dot_v_7, float alpha_16, BSDFMaterial material_21, BSDFLobes lobes_12, float eta_i_16, float eta_o_16, uint random_state_18)
{
    float3  _S1147 = make_float3 (1.0f);
    SampleBSDF _S1148 = SampleBSDF_x24init_0(_S1147, _S1147, 0U, false, 0U, 0.0f);
    SampleBSDF sample_2 = _S1148;
    Random _S1149 = pcg(random_state_18);
    Random _S1150 = pcg(_S1149.state);
    (&sample_2)->random_state = _S1150.state;
    float3  _S1151 = sampleCosWeightedHemisphere(_S1149.value, _S1150.value);
    bool _S1152 = u_3 < (lobes_12.p_diffuse * lobes_12.translucent_share);
    float _S1153 = _S1151.y;
    float _S1154 = - _S1153;
    float _S1155 = _slang_select(_S1152, _S1154,_S1153);
    float3  _S1156 = tangentToWorld(make_float3 (_S1151.x, _S1155, _S1151.z), n_i_9);
    (&sample_2)->unit_direction = _S1156;
    (&sample_2)->refracted = _S1152;
    (&sample_2)->lobe = 0U;
    float3  _S1157 = diffuseBSDF((&sample_2)->unit_direction, n_i_9, alpha_16, material_21, lobes_12);
    (&sample_2)->throughput = _S1157;
    float _S1158 = diffusePDF(_S1155, 0.0f, n_i_dot_v_7, alpha_16, lobes_12, eta_i_16, eta_o_16);
    (&sample_2)->pdf = _S1158;
    return sample_2;
}

__device__ __forceinline__ SampleBSDF toonSample(float3  n_i_10, float n_i_dot_v_8, float alpha_17, BSDFMaterial material_22, BSDFLobes lobes_13, float eta_i_17, float eta_o_17, uint random_state_19)
{
    float3  _S1159 = make_float3 (1.0f);
    SampleBSDF _S1160 = SampleBSDF_x24init_0(_S1159, _S1159, 0U, false, 0U, 0.0f);
    SampleBSDF sample_3 = _S1160;
    Random _S1161 = pcg(random_state_19);
    Random _S1162 = pcg(_S1161.state);
    (&sample_3)->random_state = _S1162.state;
    float _S1163 = _S1161.value * lobes_13.toon_norm / 6.28318548202514648f;
    float t_20;
    if(lobes_13.toon_glossy)
    {
        t_20 = (F32_acos((clamp_1(1.0f - _S1163, -1.0f, 1.0f))));
    }
    else
    {
        t_20 = (F32_asin(((F32_min(((F32_sqrt((2.0f * _S1163)))), (1.0f))))));
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
        float _S1164;
        if(t_20 < (lobes_13.toon_a))
        {
            _S1164 = 1.0f;
        }
        else
        {
            _S1164 = (F32_max((1.0f - (t_20 - lobes_13.toon_a) / (F32_max((lobes_13.toon_s), (0.0000152587890625f)))), (0.0f)));
        }
        float integral_1;
        if(lobes_13.toon_glossy)
        {
            integral_1 = 1.0f - (F32_cos(((F32_min((t_20), (lobes_13.toon_a))))));
        }
        else
        {
            float _S1165 = (F32_sin(((F32_min((t_20), (lobes_13.toon_a))))));
            integral_1 = _S1165 * _S1165 / 2.0f;
        }
        bool _S1166 = t_20 > (lobes_13.toon_a);
        bool _S1167;
        if(_S1166)
        {
            _S1167 = (lobes_13.toon_s) > 0.0f;
        }
        else
        {
            _S1167 = false;
        }
        float integral_2;
        if(_S1167)
        {
            if(lobes_13.toon_glossy)
            {
                float _S1168 = (F32_cos((lobes_13.toon_a)));
                float _S1169 = (F32_cos((t_20)));
                integral_2 = (1.0f + lobes_13.toon_a / lobes_13.toon_s) * (_S1168 - _S1169) - ((F32_sin((t_20))) - t_20 * _S1169 - ((F32_sin((lobes_13.toon_a))) - lobes_13.toon_a * _S1168)) / lobes_13.toon_s;
            }
            else
            {
                float _S1170 = 2.0f * lobes_13.toon_a;
                float _S1171 = (F32_cos((_S1170)));
                float _S1172 = 2.0f * t_20;
                float _S1173 = (F32_cos((_S1172)));
                integral_2 = (1.0f + lobes_13.toon_a / lobes_13.toon_s) * (_S1171 - _S1173) / 4.0f - ((F32_sin((_S1172))) / 8.0f - t_20 * _S1173 / 4.0f - ((F32_sin((_S1170))) / 8.0f - lobes_13.toon_a * _S1171 / 4.0f)) / lobes_13.toon_s;
            }
            float integral_3 = integral_1 + integral_2;
            integral_2 = integral_3;
        }
        else
        {
            integral_2 = integral_1;
        }
        float _S1174 = _S1164 * (F32_sin((t_20)));
        float _S1175;
        if(lobes_13.toon_glossy)
        {
            _S1175 = 1.0f;
        }
        else
        {
            _S1175 = (F32_cos((t_20)));
        }
        float _S1176 = _S1174 * _S1175;
        float _S1177 = (integral_2 - _S1163) / _S1176;
        bool _S1178 = _S1176 > 0.0f;
        float _S1179 = _slang_select(_S1178, _S1177,0.0f);
        float _S1180 = clamp_1(t_20 - _S1179, 0.0f, lobes_13.toon_b);
        int k_1 = k_0 + int(1);
        t_20 = _S1180;
        k_0 = k_1;
    }
    float _S1181 = 6.28318548202514648f * _S1162.value;
    float _S1182 = (F32_sin((t_20)));
    float3  _S1183 = tangentToWorld(make_float3 (_S1182 * (F32_cos((_S1181))), (F32_cos((t_20))), _S1182 * (F32_sin((_S1181)))), lobes_13.toon_axis);
    (&sample_3)->unit_direction = _S1183;
    bool _S1184 = (dot_0(n_i_10, (&sample_3)->unit_direction)) < 0.0f;
    (&sample_3)->refracted = _S1184;
    (&sample_3)->lobe = 6U;
    float3  _S1185 = toonBSDF((&sample_3)->unit_direction, n_i_10, alpha_17, material_22, lobes_13);
    (&sample_3)->throughput = _S1185;
    float _S1186 = toonPDF(dot_0(n_i_10, (&sample_3)->unit_direction), dot_0((&sample_3)->unit_direction, lobes_13.toon_axis), n_i_dot_v_8, alpha_17, lobes_13, eta_i_17, eta_o_17);
    (&sample_3)->pdf = _S1186;
    return sample_3;
}

__device__ __forceinline__ SampleBSDF refractSample(float3  ggx_n_5, float3  n_i_11, float n_i_dot_v_9, float alpha_18, BSDFMaterial material_23, BSDFLobes lobes_14, float eta_i_18, float eta_o_18, uint random_state_20)
{
    float3  _S1187 = make_float3 (1.0f);
    SampleBSDF _S1188 = SampleBSDF_x24init_0(_S1187, _S1187, 0U, false, 0U, 0.0f);
    SampleBSDF sample_4 = _S1188;
    (&sample_4)->unit_direction = lobes_14.refracted;
    (&sample_4)->random_state = random_state_20;
    (&sample_4)->refracted = true;
    (&sample_4)->lobe = 1U;
    float3  _S1189 = refractBSDF((&sample_4)->unit_direction, n_i_11, alpha_18, material_23, lobes_14);
    (&sample_4)->throughput = _S1189;
    float _S1190 = refractPDF(0.0f, dot_0((&sample_4)->unit_direction, ggx_n_5), n_i_dot_v_9, alpha_18, lobes_14, eta_i_18, eta_o_18);
    (&sample_4)->pdf = _S1190;
    return sample_4;
}

static __device__ float3  reflect_0(float3  i_22, float3  n_14)
{
    return i_22 - make_float3 (2.0f * dot_0(n_14, i_22)) * n_14;
}

__device__ __forceinline__ SampleBSDF reflectSample(float3  in_dir_12, float3  ggx_n_6, float3  n_i_12, float n_i_dot_v_10, float alpha_19, BSDFMaterial material_24, BSDFLobes lobes_15, float eta_i_19, float eta_o_19, uint random_state_21)
{
    float3  _S1191 = make_float3 (1.0f);
    SampleBSDF _S1192 = SampleBSDF_x24init_0(_S1191, _S1191, 0U, false, 0U, 0.0f);
    SampleBSDF sample_5 = _S1192;
    float3  _S1193 = reflect_0(in_dir_12, ggx_n_6);
    float3  _S1194 = ((((_S1193)) * make_float3(rnorm3df(((_S1193)).x, ((_S1193)).y, ((_S1193)).z))));
    (&sample_5)->unit_direction = _S1194;
    (&sample_5)->random_state = random_state_21;
    (&sample_5)->lobe = 2U;
    float3  _S1195 = reflectBSDF((&sample_5)->unit_direction, n_i_12, alpha_19, material_24, lobes_15);
    (&sample_5)->throughput = _S1195;
    float _S1196 = reflectPDF(0.0f, 0.0f, n_i_dot_v_10, alpha_19, lobes_15, eta_i_19, eta_o_19);
    (&sample_5)->pdf = _S1196;
    return sample_5;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_13, float3  n_15, BSDFMaterial material_25, float eta_i_20, float eta_o_20, uint random_init_0, float2  screen_space_0)
{
    uint random_state_22 = random_init_0;
    float3  _S1197 = negate_0(in_dir_13);
    float _S1198 = dot_0(n_15, _S1197);
    float _S1199 = sign_0(_S1198);
    float3  n_i_13 = n_15 * make_float3 (_S1199);
    float _S1200 = (F32_abs((_S1198)));
    float _S1201 = material_25.roughness;
    float _S1202 = _S1201 * _S1201;
    AnisotropicFrame _S1203 = anisotropicFrame(material_25, n_i_13);
    float3  _S1204 = sampleHalfVector(_S1197, n_i_13, _S1202, _S1203, &random_state_22);
    BSDFLobes _S1205 = bsdfLobes(in_dir_13, _S1197, n_i_13, _S1204, material_25, eta_i_20, eta_o_20, _S1203);
    BSDFLobes lobes_16 = _S1205;
    float _S1206 = translucentShare(material_25);
    (&lobes_16)->translucent_share = _S1206;
    Random _S1207 = pcg(random_state_22);
    random_state_22 = _S1207.state;
    bool _S1208 = (_S1207.value) < ((&lobes_16)->p_sheen_velvet);
    if(_S1208)
    {
        SampleBSDF _S1209 = sheenVelvetSample(n_i_13, _S1200, _S1202, material_25, lobes_16, eta_i_20, eta_o_20, random_state_22);
        return _S1209;
    }
    float _S1210 = _S1207.value - (&lobes_16)->p_sheen_velvet;
    bool _S1211 = _S1210 < ((&lobes_16)->p_diffuse);
    if(_S1211)
    {
        SampleBSDF _S1212 = diffuseSample(_S1210, n_i_13, _S1200, _S1202, material_25, lobes_16, eta_i_20, eta_o_20, random_state_22);
        return _S1212;
    }
    bool _S1213 = _S1210 < ((&lobes_16)->p_diffuse + (&lobes_16)->p_toon);
    if(_S1213)
    {
        SampleBSDF _S1214 = toonSample(n_i_13, _S1200, _S1202, material_25, lobes_16, eta_i_20, eta_o_20, random_state_22);
        return _S1214;
    }
    float _S1215 = (&lobes_16)->p_toon;
    bool _S1216 = (_S1210 - _S1215) < ((&lobes_16)->p_diffuse + (&lobes_16)->p_refract);
    if(_S1216)
    {
        SampleBSDF _S1217 = refractSample(_S1204, n_i_13, _S1200, _S1202, material_25, lobes_16, eta_i_20, eta_o_20, random_state_22);
        return _S1217;
    }
    SampleBSDF _S1218 = reflectSample(in_dir_13, _S1204, n_i_13, _S1200, _S1202, material_25, lobes_16, eta_i_20, eta_o_20, random_state_22);
    return _S1218;
}

__device__ bool withinInverseFootprint(float pdf_10, bool diffuse_0, float prev_cos_0, float distance_5, float threshold_1)
{
    bool _S1219 = pdf_10 > 0.0f;
    bool _S1220;
    if(_S1219)
    {
        if(diffuse_0)
        {
            _S1220 = true;
        }
        else
        {
            _S1220 = (pdf_10 * prev_cos_0 / (distance_5 * distance_5) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S1220 = false;
    }
    return _S1220;
}

__device__ bool roughLobe(float pdf_11, bool diffuse_1, float roughness_1)
{
    bool _S1221 = pdf_11 > 0.0f;
    bool _S1222;
    if(_S1221)
    {
        if(diffuse_1)
        {
            _S1222 = true;
        }
        else
        {
            _S1222 = roughness_1 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S1222 = false;
    }
    return _S1222;
}

static __device__ bool passesLayer_0(uint layers_0, bool refracting_0, bool passed_0)
{
    bool _S1223 = layers_0 > 1U;
    bool _S1224;
    if(_S1223)
    {
        _S1224 = refracting_0 != passed_0;
    }
    else
    {
        _S1224 = false;
    }
    return _S1224;
}

static __device__ float widened_0(float spread_1, float pdf_12, bool delta_0)
{
    float _S1225 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * pdf_12))))), (3.14159274101257324f)));
    bool _S1226 = !delta_0;
    float _S1227 = _slang_select(_S1226, _S1225,0.0f);
    return spread_1 + _S1227;
}

static __device__ bool boundsVolume_0(FKSurface * surface_10)
{
    return surface_10->encloses;
}

static __device__ bool leavesInFront_0(float3  face_2, float3  dir_15, float3  g_3)
{
    return ((dot_0(dir_15, g_3)) > 0.0f) == ((dot_0(g_3, face_2)) > 0.0f);
}

static __device__ Shift walk_0(Domain * dom_7, Reservoir * r_8, bool replay_2, float scale_3, Selection * sel_7)
{
    float spread_2;
    bool turned_1;
    bool is_inside_5;
    bool viewed_0;
    bool _S1228;
    float density_2;
    float threshold_2;
    float width_3;
    float sky_pdf_0;
    float geometry_density_2;
    uint b_8;
    uint layer_0;
    float3  throughput_5;
    float3  chain_throughput_0;
    TreeSample light_3;
    int _S1229;
    Shift ended_0;
    float density_3;
    float spread_3;
    float width_4;
    float sky_pdf_1;
    float spread_4;
    float width_5;
    uint b_9;
    float3  _S1230 = make_float3 (0.0f);
    Shift _S1231 = Shift_x24init_0(_S1230, 0.0f);
    uint _S1232 = r_8->path;
    uint _S1233 = extractBits_0(r_8->path, 0U, 5U);
    uint _S1234 = extractBits_0(_S1232, 5U, 5U);
    uint _S1235 = extractBits_0(_S1232, 10U, 2U);
    uint _S1236 = extractBits_0(_S1232, 12U, 3U);
    bool passes_0;
    if(replay_2)
    {
        bool _S1237 = _S1236 >= 3U;
        uint _S1238 = _slang_select(_S1237, 1U,0U);
        uint _S1239 = _S1233 + _S1238;
        uint _S1240 = (fcptMaxBounces());
        passes_0 = _S1239 > _S1240;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S1231;
    }
    uint _S1241 = _S1234 - 1U;
    bool _S1242 = _S1236 == 3U;
    uint _S1243 = _slang_select(_S1242, 1U,0U);
    uint _S1244 = _S1233 + _S1243;
    bool _S1245 = _S1235 == 0U;
    uint _S1246 = _slang_select(_S1245, _S1244,_S1241);
    FKHit _S1247 = (fcptReservoirHit((*r_8)));
    float3  _S1248 = dom_7->x0;
    float3  _S1249 = dom_7->x1 - dom_7->x0;
    float3  _S1250 = ((((_S1249)) * make_float3(rnorm3df(((_S1249)).x, ((_S1249)).y, ((_S1249)).z))));
    FKRay _S1251 = Ray_x24init_0(dom_7->x1, _S1250);
    FKRay ray_2 = _S1251;
    FKHit hit_4 = dom_7->hit;
    float3  scatter_in_0 = _S1230;
    float3  throughput_6 = make_float3 (1.0f);
    float3  weight_1 = throughput_6;
    float3  glowed_0 = _S1230;
    float3  extinction_in_0 = _S1230;
    float g_in_0 = 0.0f;
    uint filling_2 = 4294967295U;
    float _S1252 = dom_7->spread;
    float _S1253 = dom_7->width;
    float _S1254 = length_0(_S1249);
    NEEVertex _S1255 = NEEVertex_x24init_0(true, 0.0f, _S1230, _S1230, _S1230);
    NEEVertex nee_vertex_0 = _S1255;
    Vertex _S1256 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_0 = _S1256;
    Reservoir _S1257 = (Reservoir{});
    Reservoir chain_0 = _S1257;
    uint _S1258 = r_8->seed;
    (&chain_0)->seed = r_8->seed;
    (&ray_2)->origin = _S1248;
    (&hit_4)->distance = _S1254;
    FKMedium _S1259 = (fcptCameraMedium(((&ray_2)->unit_direction), ((&hit_4)->distance), (&filling_2)));
    uint _S1260 = filling_2;
    bool _S1261 = (fcptVaryingUsed());
    uint _S1262 = _slang_select(_S1261, _S1260,4294967295U);
    filling_2 = _S1262;
    scatter_in_0 = _S1259.scatter;
    extinction_in_0 = _S1259.extinction;
    g_in_0 = _S1259.g;
    Reservoir _S1263 = chain_0;
    uint _S1264 = filling_2;
    for(;;)
    {
        bool _S1265 = (fcptVaryingUsed());
        if(_S1265)
        {
            passes_0 = _S1264 != 4294967295U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            float _S1266 = (fcptMajorant((_S1264)));
            spread_2 = _S1266;
        }
        else
        {
            spread_2 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
        }
        if(replay_2)
        {
            turned_1 = 4294967295U == _S1246;
        }
        else
        {
            turned_1 = false;
        }
        if(turned_1)
        {
            turned_1 = _S1235 == 1U;
        }
        else
        {
            turned_1 = false;
        }
        if(turned_1)
        {
            turned_1 = spread_2 > 0.0f;
        }
        else
        {
            turned_1 = false;
        }
        if(turned_1)
        {
            ended_0 = _S1231;
            sky_pdf_0 = 0.0f;
            spread_2 = _S1252;
            width_3 = _S1253;
            density_2 = 1.0f;
            throughput_5 = throughput_6;
            b_8 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S1267 = (&prev_0)->rough;
        if(_S1267)
        {
            turned_1 = !(spread_2 > 0.0f);
        }
        else
        {
            turned_1 = false;
        }
        (&prev_0)->rough = turned_1;
        uint _S1268 = stream(_S1258, 384U);
        uint tracking_0 = _S1268;
        weight_1 = throughput_6;
        glowed_0 = _S1230;
        b_8 = 4294967295U;
        throughput_5 = throughput_6;
        density_2 = 1.0f;
        threshold_2 = _S1252;
        width_3 = _S1253;
        sky_pdf_0 = 0.0f;
        for(;;)
        {
            if(((&hit_4)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S1229 = int(1);
                break;
            }
            uint _S1269 = b_8 + 320U;
            bool _S1270 = b_8 == 4294967295U;
            uint _S1271 = _slang_select(_S1270, 384U,_S1269);
            uint _S1272 = stream(_S1258, _S1271);
            Random _S1273 = pcg(_S1272);
            float _S1274 = freeFlight_0(_S1273.value, spread_2);
            if(passes_0)
            {
                float3  _S1275 = (&ray_2)->origin;
                float3  _S1276 = (&ray_2)->unit_direction;
                float _S1277 = (&hit_4)->distance;
                uint _S1278 = _slang_select(_S1270, 0U,b_8);
                uint _S1279 = (&prev_0)->lobe;
                uint _S1280 = _slang_select(_S1270, 3U,_S1279);
                float _S1281 = (fcptTrackMedium((_S1264), (_S1275), (_S1276), (_S1277), (&tracking_0), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1278), (_S1280), (_S1270)));
                geometry_density_2 = _S1281;
            }
            else
            {
                geometry_density_2 = _S1274;
            }
            bool _S1282 = !(geometry_density_2 < ((&hit_4)->distance));
            if(_S1282)
            {
                _S1229 = int(1);
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
                float3  _S1283 = throughput_5 * glowed_0 / make_float3 (density_2);
                float3  _S1284 = sel_7->glow + _S1283;
                sel_7->glow = _S1284;
            }
            else
            {
            }
            glowed_0 = _S1230;
            uint b_10 = b_8 + 1U;
            float3  _S1285 = (&ray_2)->origin + make_float3 (geometry_density_2) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S1285;
            float3  _S1286 = flightWeight_0(scatter_in_0, extinction_in_0, spread_2, geometry_density_2, true);
            float3  _S1287 = weight_1;
            float3  _S1288 = _slang_select(passes_0, _S1287,_S1286);
            float3  throughput_7 = throughput_5 * _S1288;
            uint _S1289 = stream(_S1258, b_10 + 320U);
            tracking_0 = _S1289;
            weight_1 = throughput_6;
            float width_6 = width_3 + threshold_2 * geometry_density_2;
            float _S1290 = threshold_2 + 3.14159274101257324f;
            bool _S1291 = scatterSampled_0(replay_2, b_10, _S1246, passes_0);
            TreeSample _S1292 = TreeSample_x24init_0(_S1230, _S1230, 0.0f, 0U);
            if(_S1291)
            {
                float3  _S1293 = (&ray_2)->origin;
                float3  _S1294 = (&ray_2)->unit_direction;
                float3  _S1295 = (&ray_2)->unit_direction;
                uint _S1296 = stream(_S1258, b_10 + 64U);
                float3  _S1297 = extinction_in_0;
                float3  _S1298 = extinction_in_0;
                uint2  _S1299 = make_uint2 (_S1264);
                float3  _S1300 = (&ray_2)->unit_direction;
                uint _S1301 = arrivalLobe_0(b_10, (&prev_0)->lobe);
                FKHit _S1302 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S1303 = _S1302;
                ShadowContext _S1304 = ShadowContext_x24init_0(_S1297, _S1298, _S1299, _S1300, b_10, _S1301, false, geometry_density_2, width_6, &_S1303, false);
                ShadowContext _S1305 = _S1304;
                TreeSample _S1306 = sampleLightTree_0(_S1293, _S1294, _S1295, 0.0f, true, _S1296, &_S1305);
                light_3 = _S1306;
            }
            else
            {
                light_3 = _S1292;
            }
            float _S1307 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_3.dir));
            uint _S1308 = (fcptMaxBounces());
            bool _S1309 = b_10 < _S1308;
            if(_S1309)
            {
                is_inside_5 = (light_3.density) > 0.0f;
            }
            else
            {
                is_inside_5 = false;
            }
            float _S1310 = _slang_select(is_inside_5, _S1307,0.0f);
            float3  _S1311 = throughput_7 * light_3.radiance;
            float _S1312 = powerHeuristic(light_3.density, _S1310);
            float3  _S1313 = _S1311 * make_float3 (_S1307 * _S1312);
            float3  _S1314 = _slang_select(_S1291, _S1313,_S1230);
            if(replay_2)
            {
                viewed_0 = b_10 == _S1246;
            }
            else
            {
                viewed_0 = false;
            }
            if(viewed_0)
            {
                bool _S1315 = _S1235 == 2U;
                if(_S1315)
                {
                    float _S1316 = rgb_to_greyscale(_S1314);
                    passes_0 = _S1316 > 0.0f;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S1317 = Shift_x24init_0(_S1314, 1.0f);
                    _S1229 = int(0);
                    ended_0 = _S1317;
                    spread_2 = _S1290;
                    geometry_density_2 = width_6;
                    chain_throughput_0 = throughput_7;
                    layer_0 = b_10;
                    break;
                }
                _S1229 = int(0);
                ended_0 = _S1231;
                spread_2 = _S1290;
                geometry_density_2 = width_6;
                chain_throughput_0 = throughput_7;
                layer_0 = b_10;
                break;
            }
            bool _S1318 = !replay_2;
            if(_S1318)
            {
                Reservoir candidate_3 = _S1263;
                uint _S1319 = extractBits_0(_S1263.path, 10U, 2U);
                bool _S1320 = _S1319 == 1U;
                if(_S1320)
                {
                    float3  _S1321 = safeDivide(_S1314, _S1230);
                    (&candidate_3)->radiance = _S1321;
                }
                else
                {
                    uint _S1322 = insertBits_0(0U, b_10 + 1U, 5U, 5U);
                    uint _S1323 = insertBits_0(_S1322, 2U, 10U, 2U);
                    (&candidate_3)->path = _S1323;
                }
                Reservoir _S1324 = withEnd(candidate_3, 0U, b_10, _S1314);
                offer(sel_7, _S1324, _S1314 * make_float3 (scale_3) / make_float3 (density_2));
                float _S1325 = survivalProbability(throughput_7, density_2);
                uint _S1326 = stream(_S1258, b_10 + 128U);
                Random _S1327 = pcg(_S1326);
                bool _S1328 = _S1325 < (_S1327.value);
                if(_S1328)
                {
                    _S1228 = true;
                }
                else
                {
                    uint _S1329 = (fcptMaxBounces());
                    _S1228 = b_10 >= _S1329;
                }
                if(_S1228)
                {
                    _S1229 = int(0);
                    ended_0 = _S1231;
                    spread_2 = _S1290;
                    geometry_density_2 = width_6;
                    chain_throughput_0 = throughput_7;
                    layer_0 = b_10;
                    break;
                }
                float _S1330 = density_2 * _S1325;
                density_2 = _S1330;
            }
            else
            {
            }
            float phase_pdf_0 = 0.0f;
            uint _S1331 = stream(_S1258, b_10);
            float3  _S1332 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1331, &phase_pdf_0);
            (&ray_2)->unit_direction = _S1332;
            NEEVertex _S1333 = NEEVertex_x24init_0(false, phase_pdf_0, (&ray_2)->origin, _S1230, (&ray_2)->origin);
            nee_vertex_0 = _S1333;
            Vertex _S1334 = scatteredVertex_0(false);
            prev_0 = _S1334;
            float _S1335 = (&prev_0)->pdf;
            FKRay _S1336 = ray_2;
            FKHit _S1337 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S1338 = (fcptTraverseInstanceBVH((_S1336), (true), (4.294967296e+09f), (false), (_S1337), (false)));
            hit_4 = _S1338;
            b_8 = b_10;
            throughput_5 = throughput_7;
            threshold_2 = _S1290;
            width_3 = width_6;
            sky_pdf_0 = _S1335;
        }
        if(_S1229 != int(1))
        {
            width_3 = geometry_density_2;
            throughput_5 = chain_throughput_0;
            b_8 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S1231;
        spread_2 = threshold_2;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    bool _S1339 = b_8 == 4294967295U;
    bool _S1340 = ((&hit_4)->instance_index) == 4294967295U;
    if(_S1340)
    {
        bool _S1341 = !(&nee_vertex_0)->none;
        float _S1342 = _slang_select(_S1341, sky_pdf_0,0.0f);
        float _S1343 = escapeWeight_0(_S1342, (&ray_2)->unit_direction);
        float3  _S1344 = environment_0((&ray_2)->unit_direction, b_8, (&prev_0)->lobe);
        float3  _S1345 = throughput_5 * _S1344;
        if(replay_2)
        {
            bool _S1346 = b_8 == _S1246;
            if(_S1346)
            {
                passes_0 = _S1235 == 3U;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                return Shift_x24init_0(_S1345 * make_float3 (_S1343) / make_float3 (r_8->jac), density_2 / r_8->jac);
            }
            if(_S1245)
            {
                passes_0 = _S1242;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                passes_0 = b_8 == _S1233;
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
                return Shift_x24init_0(_S1345 * make_float3 (_S1343), 1.0f);
            }
            return _S1231;
        }
        Reservoir candidate_4 = chain_0;
        uint _S1347 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1348 = _S1347 == 1U;
        if(_S1348)
        {
            uint _S1349 = extractBits_0((&chain_0)->path, 5U, 5U);
            bool _S1350 = _S1349 == b_8;
            float _S1351 = _slang_select(_S1350, 1.0f,_S1343);
            float3  _S1352 = safeDivide(_S1345 * make_float3 (_S1351), _S1230);
            (&candidate_4)->radiance = _S1352;
        }
        else
        {
            bool _S1353 = (&prev_0)->rough;
            if(_S1353)
            {
                uint _S1354 = insertBits_0(0U, b_8 + 1U, 5U, 5U);
                uint _S1355 = insertBits_0(_S1354, 3U, 10U, 2U);
                uint _S1356 = insertBits_0(_S1355, (&prev_0)->lobe, 15U, 3U);
                bool _S1357 = (&prev_0)->inside;
                uint _S1358 = _slang_select(_S1357, 1U,0U);
                uint _S1359 = insertBits_0(_S1356, _S1358, 22U, 1U);
                (&candidate_4)->path = _S1359;
                (&candidate_4)->jac = (&prev_0)->pdf;
                (&candidate_4)->dir = (&ray_2)->unit_direction;
            }
        }
        float3  _S1360 = _S1345 * make_float3 (_S1343);
        Reservoir _S1361 = withEnd(candidate_4, 3U, b_8, _S1360);
        offer(sel_7, _S1361, _S1360 * make_float3 (scale_3) / make_float3 (density_2));
        return _S1231;
    }
    float3  _S1362 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
    (&ray_2)->origin = _S1362;
    bool _S1363 = (fcptVaryingUsed());
    if(_S1363)
    {
        passes_0 = filling_2 != 4294967295U;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        bool _S1364 = !replay_2;
        if(_S1364)
        {
            float3  _S1365 = throughput_5 * glowed_0 / make_float3 (density_2);
            float3  _S1366 = sel_7->glow + _S1365;
            sel_7->glow = _S1366;
        }
        float3  _S1367 = throughput_5 * weight_1;
        throughput_5 = _S1367;
    }
    else
    {
        float3  _S1368 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
        float3  _S1369 = throughput_5 * _S1368;
        throughput_5 = _S1369;
    }
    float _S1370 = width_3 + spread_2 * (&hit_4)->distance;
    uint _S1371 = b_8 + 1U;
    b_8 = _S1371;
    layer_0 = 0U;
    width_3 = _S1370;
    passes_0 = false;
    threshold_2 = 0.0f;
    turned_1 = false;
    is_inside_5 = false;
    chain_throughput_0 = _S1230;
    float3  reconnection_0 = _S1230;
    viewed_0 = _S1339;
    for(;;)
    {
        bool _S1372 = ((&hit_4)->is_point_light) == 1U;
        if(replay_2)
        {
            _S1228 = _S1235 == 1U;
        }
        else
        {
            _S1228 = false;
        }
        bool _S1373;
        if(_S1228)
        {
            _S1373 = b_8 == _S1234;
        }
        else
        {
            _S1373 = false;
        }
        bool _S1374;
        if(_S1373)
        {
            bool _S1375 = ((&hit_4)->instance_index) != (_S1247.instance_index);
            if(_S1375)
            {
                _S1374 = true;
            }
            else
            {
                _S1374 = ((&hit_4)->triangle_index) != (_S1247.triangle_index);
            }
        }
        else
        {
            _S1374 = false;
        }
        if(_S1374)
        {
            return _S1231;
        }
        FKMedium _S1376 = Medium_x24init_0(_S1230, _S1230, 0.0f);
        BSDFMaterial _S1377 = Material_x24init_0(_S1230, _S1230, 0.0f, 0.0f, 0.0f, 0.0f, _S1230, throughput_6, 1.0f, _S1230, _S1230, 0.5f, 0.0f, 0.0f, _S1230, 0.0f, _S1230);
        FKMedium _S1378 = _S1376;
        FKSurface _S1379 = Surface_x24init_0(_S1230, _S1230, 0.0f, &_S1377, false, 0U, 1.0f, false, &_S1378, 4294967295U, _S1230);
        bool _S1380 = !_S1372;
        bool scatter_2;
        bool is_inside_6;
        float3  throughput_8;
        FKSurface surface_11;
        if(_S1380)
        {
            uint _S1381 = stream(_S1258, b_8);
            uint _S1382 = arrivalLobe_0(b_8, (&prev_0)->lobe);
            FKSurface _S1383 = (fcptSurfaceAtPath((hit_4), ((&ray_2)->origin), (_S1381), (width_3), (layer_0), (b_8), (_S1382), ((&ray_2)->unit_direction)));
            bool _S1384 = !passes_0;
            FKSurface _S1385 = _S1383;
            FKSurface _S1386 = emitting_0(&_S1385, _S1384);
            uint _S1387 = stream(_S1258, b_8 + 256U);
            Random _S1388 = pcg(_S1387);
            FKSurface _S1389 = _S1386;
            FKSurface _S1390 = uncovered_0(&_S1389, _S1388.value);
            float _S1391 = facingSign(_S1390.material.transmission, _S1390.geometry_n, (&ray_2)->unit_direction);
            bool _S1392 = _S1391 < 0.0f;
            bool _S1393 = (_S1390.material.transmission) > 0.0f;
            if(_S1393)
            {
                bool _S1394 = arrivesBehind_0((&ray_2)->unit_direction, _S1390.geometry_n);
                scatter_2 = _S1394;
            }
            else
            {
                scatter_2 = false;
            }
            FKSurface _S1395 = _S1390;
            FKSurface _S1396 = facingRay_0(&_S1395, (&ray_2)->unit_direction);
            if(passes_0)
            {
                bool _S1397 = arrivesBehind_0((&ray_2)->unit_direction, _S1396.geometry_n);
                is_inside_6 = _S1397;
            }
            else
            {
                is_inside_6 = scatter_2;
            }
            if(is_inside_6)
            {
                float3  _S1398 = beerLambert((&hit_4)->distance, _S1396.material.absorption);
                float3  _S1399 = throughput_5 * _S1398;
                throughput_8 = _S1399;
            }
            else
            {
                throughput_8 = throughput_5;
            }
            bool _S1400 = !_S1396.skip;
            float geometry_density_3 = geometryDensity(_S1396.geometry_n, (&ray_2)->unit_direction, (&hit_4)->distance);
            bool _S1401 = b_8 == _S1371;
            if(_S1401)
            {
                float _S1402 = footprintThreshold(geometry_density_3);
                geometry_density_2 = _S1402;
            }
            else
            {
                geometry_density_2 = threshold_2;
            }
            float _S1403 = geometry_density_2;
            scatter_2 = _S1400;
            geometry_density_2 = geometry_density_3;
            threshold_2 = _S1403;
            surface_11 = _S1396;
            turned_1 = _S1392;
        }
        else
        {
            scatter_2 = false;
            geometry_density_2 = 0.0f;
            surface_11 = _S1379;
            throughput_8 = throughput_5;
            is_inside_6 = is_inside_5;
        }
        bool _S1404 = withinFootprint(scatter_2, (&prev_0)->rough, (&prev_0)->pdf, geometry_density_2, threshold_2);
        FKSurface _S1405 = surface_11;
        FKSurface _S1406 = surface_11;
        float _S1407 = dot_0(surface_11.smooth_n, - (&ray_2)->unit_direction);
        float2  _S1408 = vertexEta(_S1405.material, _S1407);
        bool _S1409;
        if(scatter_2)
        {
            bool _S1410 = neeDecision(_S1405.material, _S1407, _S1408.x, _S1408.y);
            _S1409 = _S1410;
        }
        else
        {
            _S1409 = false;
        }
        bool _S1411;
        if(passes_0)
        {
            _S1411 = true;
        }
        else
        {
            _S1411 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S1411)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S1409;
        }
        bool _S1412 = (fcptHairUsed());
        bool _S1413;
        if(_S1412)
        {
            float3  _S1414 = surface_11.hair;
            _S1413 = (dot_0(_S1414, _S1414)) > 0.0f;
        }
        else
        {
            _S1413 = false;
        }
        bool _S1415;
        if(_S1413)
        {
            _S1415 = true;
        }
        else
        {
            BSDFMaterial _S1416 = _S1405.material;
            bool _S1417 = isTranslucent_0(&_S1416);
            _S1415 = _S1417;
        }
        bool _S1418;
        if(_S1415)
        {
            _S1418 = true;
        }
        else
        {
            bool _S1419 = (_S1405.material.transmission) > 0.0f;
            if(_S1419)
            {
                uint _S1420 = (fcptLayers((hit_4)));
                _S1418 = _S1420 == 1U;
            }
            else
            {
                _S1418 = false;
            }
        }
        float3  emission_0;
        if(_S1372)
        {
            float3  _S1421 = (fcptCalculatePointLightContrib(((&hit_4)->instance_index)));
            emission_0 = _S1421;
        }
        else
        {
            emission_0 = _S1405.material.emissive;
        }
        float _S1422 = rgb_to_greyscale(emission_0);
        bool _S1423 = _S1422 > 0.0f;
        float3  emission_1;
        if(_S1423)
        {
            NEEVertex _S1424 = nee_vertex_0;
            FKHit _S1425 = hit_4;
            float _S1426 = emissionWeight_0(&_S1424, &_S1425, (&ray_2)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S1426);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S1427;
        if(replay_2)
        {
            _S1427 = _S1235 == 1U;
        }
        else
        {
            _S1427 = false;
        }
        bool _S1428;
        if(_S1427)
        {
            _S1428 = b_8 > _S1234;
        }
        else
        {
            _S1428 = false;
        }
        bool _S1429;
        if(_S1428)
        {
            _S1429 = b_8 == _S1233;
        }
        else
        {
            _S1429 = false;
        }
        bool _S1430;
        if(_S1429)
        {
            bool _S1431 = _S1236 == 1U;
            if(_S1431)
            {
                _S1430 = true;
            }
            else
            {
                _S1430 = _S1236 == 2U;
            }
        }
        else
        {
            _S1430 = false;
        }
        if(_S1430)
        {
            bool _S1432 = _S1372 != (_S1236 == 2U);
            if(_S1432)
            {
                return _S1231;
            }
            return Shift_x24init_0(throughput_8 * emission_1 / make_float3 (r_8->jac), density_2 / r_8->jac);
        }
        uint _S1433 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1434 = _S1433 == 1U;
        Reservoir here_0 = chain_0;
        uint _S1435 = insertBits_0(0U, b_8, 5U, 5U);
        uint _S1436 = insertBits_0(_S1435, 1U, 10U, 2U);
        uint _S1437 = insertBits_0(_S1436, (&prev_0)->lobe, 15U, 3U);
        bool _S1438 = (&prev_0)->inside;
        uint _S1439 = _slang_select(_S1438, 1U,0U);
        uint _S1440 = insertBits_0(_S1437, _S1439, 22U, 1U);
        (&here_0)->path = _S1440;
        float _S1441 = (&prev_0)->pdf * geometry_density_2;
        (&here_0)->jac = _S1441;
        fcptWithReservoirHit((&here_0), (&hit_4));
        bool _S1442;
        if(replay_2)
        {
            _S1442 = _S1235 == 1U;
        }
        else
        {
            _S1442 = false;
        }
        bool _S1443;
        if(_S1442)
        {
            _S1443 = b_8 == _S1234;
        }
        else
        {
            _S1443 = false;
        }
        bool _S1444 = b_8 == _S1246;
        bool _S1445;
        if(_S1444)
        {
            bool _S1446 = !scatter_2;
            if(_S1446)
            {
                _S1445 = true;
            }
            else
            {
                bool _S1447 = _S1235 != 1U;
                if(_S1447)
                {
                    _S1445 = _S1235 != 3U;
                }
                else
                {
                    _S1445 = false;
                }
            }
        }
        else
        {
            _S1445 = false;
        }
        bool _S1448;
        if(_S1445)
        {
            _S1448 = _S1235 == 2U;
        }
        else
        {
            _S1448 = false;
        }
        bool _S1449;
        if(_S1448)
        {
            _S1449 = !_S1404;
        }
        else
        {
            _S1449 = false;
        }
        bool _S1450;
        if(_S1449)
        {
            _S1450 = _S1236 != 4U;
        }
        else
        {
            _S1450 = false;
        }
        bool _S1451 = _S1234 == _S1233;
        bool _S1452;
        if(_S1451)
        {
            _S1452 = _S1236 == 0U;
        }
        else
        {
            _S1452 = false;
        }
        bool _S1453;
        if(_S1452)
        {
            _S1453 = ((&hit_4)->instance_index) == (_S1247.instance_index);
        }
        else
        {
            _S1453 = false;
        }
        bool _S1454;
        if(_S1453)
        {
            _S1454 = ((&hit_4)->triangle_index) == (_S1247.triangle_index);
        }
        else
        {
            _S1454 = false;
        }
        bool _S1455;
        if(_S1454)
        {
            _S1455 = _S1404;
        }
        else
        {
            _S1455 = false;
        }
        bool _S1456 = _slang_select(_S1443, _S1455,_S1450);
        bool _S1457;
        if(nee_0)
        {
            _S1457 = _slang_select(replay_2, _S1456,scatter_2);
        }
        else
        {
            _S1457 = false;
        }
        TreeSample _S1458 = TreeSample_x24init_0(_S1230, _S1230, 0.0f, 0U);
        uint2  _S1459 = make_uint2 (0U);
        float2  _S1460 = make_float2 (0.0f);
        FKHit _S1461 = Hit_x24init_0(_S1460, 4294967295U, 0U, 0U, 0.0f);
        FKHit _S1462 = _S1461;
        ShadowContext _S1463 = ShadowContext_x24init_0(_S1230, _S1230, _S1459, _S1230, 0U, 0U, false, 0.0f, 0.0f, &_S1462, false);
        ShadowContext context_5;
        if(nee_0)
        {
            uint _S1464 = arrivalLobe_0(b_8, (&prev_0)->lobe);
            FKMedium _S1465 = (fcptOutsideMedium((hit_4)));
            FKSurface _S1466 = surface_11;
            FKHit _S1467 = hit_4;
            FKMedium _S1468 = _S1465;
            ShadowContext _S1469 = shadowContext_0(&_S1466, turned_1, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_8, _S1464, (&hit_4)->distance, width_3, &_S1467, _S1413, &_S1468);
            context_5 = _S1469;
        }
        else
        {
            context_5 = _S1463;
        }
        float3  throughput_9;
        float3  lit_0;
        if(_S1457)
        {
            float3  _S1470 = (&ray_2)->origin;
            if(_S1413)
            {
                throughput_9 = _S1230;
            }
            else
            {
                throughput_9 = _S1406.smooth_n;
            }
            FKSurface _S1471 = surface_11;
            uint _S1472 = stream(_S1258, b_8 + 64U);
            ShadowContext _S1473 = context_5;
            TreeSample _S1474 = sampleLightTree_0(_S1470, throughput_9, surface_11.geometry_n, surface_11.geometry_offset, _S1418, _S1472, &_S1473);
            bool _S1475 = any_1((_S1474.radiance) != _S1230);
            if(_S1475)
            {
                if(_S1413)
                {
                    uint _S1476 = (fcptMaxBounces());
                    bool _S1477 = b_8 < _S1476;
                    FKSurface _S1478 = surface_11;
                    TreeSample _S1479 = _S1474;
                    float3  _S1480 = hairLight_0(&_S1478, (&ray_2)->unit_direction, &_S1479, _S1477);
                    lit_0 = _S1480;
                }
                else
                {
                    float _S1481 = _S1408.x;
                    float _S1482 = _S1408.y;
                    uint _S1483 = (fcptMaxBounces());
                    bool _S1484 = b_8 < _S1483;
                    TreeSample _S1485 = _S1474;
                    BSDFMaterial _S1486 = _S1405.material;
                    float3  _S1487 = lightBSDF_0((&ray_2)->unit_direction, &_S1485, _S1406.smooth_n, _S1471.geometry_n, &_S1486, _S1481, _S1482, _S1484, surface_11.random_state);
                    lit_0 = _S1487;
                }
            }
            else
            {
                lit_0 = _S1230;
            }
            light_3 = _S1474;
        }
        else
        {
            light_3 = _S1458;
            lit_0 = _S1230;
        }
        bool viewed_1;
        bool refracted_5;
        bool wrong_side_0;
        bool _S1488;
        bool _S1489;
        float density_4;
        if(_S1443)
        {
            bool _S1490 = !_S1404;
            if(_S1490)
            {
                return _S1231;
            }
            float3  throughput_10 = throughput_8 * make_float3 (geometry_density_2);
            float density_5 = density_2 * geometry_density_2;
            if(_S1451)
            {
                viewed_1 = _S1236 == 1U;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                return Shift_x24init_0(throughput_10 * emission_1 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1451)
            {
                refracted_5 = _S1236 == 0U;
            }
            else
            {
                refracted_5 = false;
            }
            if(refracted_5)
            {
                bool _S1491 = !nee_0;
                if(_S1491)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S1492 = rgb_to_greyscale(light_3.radiance);
                    passes_0 = !(_S1492 > 0.0f);
                }
                if(passes_0)
                {
                    return _S1231;
                }
                return Shift_x24init_0(throughput_10 * lit_0 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1451)
            {
                wrong_side_0 = _S1236 == 4U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                bool _S1493 = !nee_0;
                if(_S1493)
                {
                    return _S1231;
                }
                float _S1494 = environmentPdf_0(r_8->dir);
                float3  _S1495 = skyBSDF((&ray_2)->unit_direction, r_8->dir, surface_11, _S1408, is_inside_6, _S1494, surface_11.random_state);
                return Shift_x24init_0(throughput_10 * _S1495 * r_8->radiance / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            uint _S1496 = extractBits_0(_S1232, 21U, 1U);
            bool _S1497 = nee_0 != (_S1496 == 1U);
            if(_S1497)
            {
                return _S1231;
            }
            throughput_9 = throughput_10;
            density_4 = density_5;
        }
        else
        {
            if(replay_2)
            {
                viewed_1 = _S1444;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                bool _S1498 = !scatter_2;
                if(_S1498)
                {
                    refracted_5 = true;
                }
                else
                {
                    bool _S1499 = _S1235 != 1U;
                    if(_S1499)
                    {
                        refracted_5 = _S1235 != 3U;
                    }
                    else
                    {
                        refracted_5 = false;
                    }
                }
            }
            else
            {
                refracted_5 = false;
            }
            if(refracted_5)
            {
                bool _S1500 = _S1235 == 2U;
                if(_S1500)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1404;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1236 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    if(_S1413)
                    {
                        return _S1231;
                    }
                    uint _S1501 = stream(_S1258, b_8 + 448U);
                    FKRay _S1502 = ray_2;
                    FKSurface _S1503 = surface_11;
                    ShadowContext _S1504 = context_5;
                    SkySample _S1505 = sampleSky_0(&_S1502, &_S1503, _S1408, is_inside_6, _S1501, surface_11.random_state, &_S1504);
                    return Shift_x24init_0(throughput_8 * _S1505.color, 1.0f);
                }
                if(_S1500)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1404;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float _S1506 = rgb_to_greyscale(light_3.radiance);
                    bool _S1507 = !(_S1506 > 0.0f);
                    if(_S1507)
                    {
                        return _S1231;
                    }
                    return Shift_x24init_0(throughput_8 * lit_0, 1.0f);
                }
                if(_S1245)
                {
                    passes_0 = _S1236 == 2U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1372;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_8 * emission_1, 1.0f);
                }
                if(_S1245)
                {
                    passes_0 = _S1236 == 1U;
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
                    passes_0 = !_S1404;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_8 * emission_1, 1.0f);
                }
                return _S1231;
            }
            else
            {
                bool _S1508 = !replay_2;
                if(_S1508)
                {
                    wrong_side_0 = scatter_2;
                }
                else
                {
                    wrong_side_0 = false;
                }
                if(wrong_side_0)
                {
                    bool _S1509 = b_8 > 0U;
                    if(_S1509)
                    {
                        Reservoir candidate_5 = chain_0;
                        if(_S1434)
                        {
                            float3  _S1510 = safeDivide(throughput_8 * emission_1, chain_throughput_0);
                            (&candidate_5)->radiance = _S1510;
                        }
                        else
                        {
                            if(_S1404)
                            {
                                candidate_5 = here_0;
                            }
                        }
                        float3  _S1511 = throughput_8 * emission_1;
                        Reservoir _S1512 = withEnd(candidate_5, 1U, b_8, _S1511);
                        offer(sel_7, _S1512, _S1511 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    else
                    {
                        float3  _S1513 = throughput_8 * emission_1;
                        float3  _S1514 = sel_7->glow + _S1513;
                        sel_7->glow = _S1514;
                    }
                    if(nee_0)
                    {
                        float3  _S1515 = throughput_8 * lit_0;
                        Reservoir candidate_6 = chain_0;
                        if(_S1434)
                        {
                            float3  _S1516 = safeDivide(_S1515, chain_throughput_0);
                            (&candidate_6)->radiance = _S1516;
                        }
                        else
                        {
                            if(_S1404)
                            {
                                candidate_6 = here_0;
                                uint _S1517 = insertBits_0((&candidate_6)->path, 1U, 21U, 1U);
                                (&candidate_6)->path = _S1517;
                                (&candidate_6)->dir = light_3.dir;
                                (&candidate_6)->radiance = light_3.radiance;
                            }
                            else
                            {
                                uint _S1518 = insertBits_0(0U, b_8 + 1U, 5U, 5U);
                                uint _S1519 = insertBits_0(_S1518, 2U, 10U, 2U);
                                (&candidate_6)->path = _S1519;
                            }
                        }
                        Reservoir _S1520 = withEnd(candidate_6, 0U, b_8, _S1515);
                        offer(sel_7, _S1520, _S1515 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    if(nee_0)
                    {
                        if(_S1413)
                        {
                            _S1488 = false;
                        }
                        else
                        {
                            bool _S1521 = environmentMapped_0();
                            _S1488 = _S1521;
                        }
                    }
                    else
                    {
                        _S1488 = false;
                    }
                    if(_S1488)
                    {
                        uint _S1522 = (fcptMaxBounces());
                        _S1489 = b_8 < _S1522;
                    }
                    else
                    {
                        _S1489 = false;
                    }
                    if(_S1489)
                    {
                        uint _S1523 = stream(_S1258, b_8 + 448U);
                        FKRay _S1524 = ray_2;
                        FKSurface _S1525 = surface_11;
                        ShadowContext _S1526 = context_5;
                        SkySample _S1527 = sampleSky_0(&_S1524, &_S1525, _S1408, is_inside_6, _S1523, surface_11.random_state, &_S1526);
                        float3  _S1528 = throughput_8 * _S1527.color;
                        Reservoir candidate_7 = chain_0;
                        if(_S1434)
                        {
                            float3  _S1529 = safeDivide(_S1528, chain_throughput_0);
                            (&candidate_7)->radiance = _S1529;
                        }
                        else
                        {
                            if(_S1404)
                            {
                                candidate_7 = here_0;
                                uint _S1530 = insertBits_0((&candidate_7)->path, 1U, 21U, 1U);
                                (&candidate_7)->path = _S1530;
                                (&candidate_7)->dir = _S1527.dir;
                                (&candidate_7)->radiance = _S1527.radiance;
                            }
                            else
                            {
                                uint _S1531 = insertBits_0(0U, b_8 + 1U, 5U, 5U);
                                uint _S1532 = insertBits_0(_S1531, 2U, 10U, 2U);
                                (&candidate_7)->path = _S1532;
                            }
                        }
                        Reservoir _S1533 = withEnd(candidate_7, 4U, b_8, _S1528);
                        offer(sel_7, _S1533, _S1528 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                }
            }
            throughput_9 = throughput_8;
            density_4 = density_2;
        }
        bool _S1534;
        bool _S1535;
        bool _S1536;
        bool straight_0;
        bool _S1537;
        bool _S1538;
        bool _S1539;
        bool _S1540;
        bool _S1541;
        bool _S1542;
        bool _S1543;
        bool _S1544;
        bool _S1545;
        bool _S1546;
        bool _S1547;
        bool _S1548;
        float density_6;
        float sky_pdf_2;
        float spread_5;
        uint b_11;
        float3  throughput_11;
        float3  throughput_12;
        float3  throughput_13;
        if(scatter_2)
        {
            if(replay_2)
            {
                viewed_1 = _S1444;
            }
            else
            {
                viewed_1 = false;
            }
            uint _S1549 = extractBits_0(_S1232, 15U, 3U);
            uint _S1550 = extractBits_0(_S1232, 18U, 3U);
            uint _S1551 = _slang_select(_S1443, _S1550,_S1549);
            float3  _S1552 = r_8->dir;
            bool refracted_6 = _S1551 == 1U;
            SampleBSDF _S1553 = SampleBSDF_x24init_0(_S1230, _S1230, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_5 = _S1553;
            float3  reconnection_1;
            if(viewed_1)
            {
                uint _S1554 = extractBits_0(_S1232, 22U, 1U);
                bool _S1555 = is_inside_6 != (_S1554 == 1U);
                if(_S1555)
                {
                    return _S1231;
                }
                bool _S1556 = _S1235 == 1U;
                if(_S1556)
                {
                    float3  _S1557 = (fcptHitPosition((_S1247)));
                    throughput_11 = _S1557;
                }
                else
                {
                    throughput_11 = reconnection_0;
                }
                if(refracted_6)
                {
                    refracted_5 = true;
                }
                else
                {
                    BSDFMaterial _S1558 = _S1405.material;
                    bool _S1559 = isTranslucent_0(&_S1558);
                    if(_S1559)
                    {
                        refracted_5 = _S1551 == 0U;
                    }
                    else
                    {
                        refracted_5 = false;
                    }
                    if(refracted_5)
                    {
                        float3  _S1560 = throughput_11 - (&ray_2)->origin;
                        float3  _S1561 = _slang_select(_S1556, _S1560,_S1552);
                        wrong_side_0 = (dot_0(_S1406.smooth_n, _S1561) * _S1407) < 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    refracted_5 = wrong_side_0;
                }
                if(_S1556)
                {
                    float3  _S1562 = (&ray_2)->origin;
                    FKSurface _S1563 = surface_11;
                    float3  _S1564 = - _S1406.smooth_n;
                    bool _S1565 = is_inside_6 != refracted_5;
                    float3  _S1566 = _slang_select(_S1565, _S1564,_S1406.smooth_n);
                    float3  _S1567 = throughput_11 - (_S1562 + make_float3 (_S1563.geometry_offset) * _S1566);
                    float3  _S1568 = ((((_S1567)) * make_float3(rnorm3df(((_S1567)).x, ((_S1567)).y, ((_S1567)).z))));
                    reconnection_1 = _S1568;
                }
                else
                {
                    reconnection_1 = _S1552;
                }
                if(_S1413)
                {
                    wrong_side_0 = false;
                }
                else
                {
                    bool _S1569 = wrongSide_0(is_inside_6, refracted_5, reconnection_1, surface_11.geometry_n);
                    wrong_side_0 = _S1569;
                }
                if(wrong_side_0)
                {
                    return _S1231;
                }
                float3  _S1570 = throughput_11;
                throughput_11 = reconnection_1;
                b_11 = _S1551;
                wrong_side_0 = false;
                reconnection_1 = _S1570;
            }
            else
            {
                bool _S1571 = !_S1443;
                if(_S1571)
                {
                    SampleBSDF bsdf_sampled_0;
                    SampleBSDF _S1572;
                    if(_S1413)
                    {
                        SampleBSDF _S1573 = (fcptSampleHair((surface_11.hair), (_S1405.material.albedo), (_S1405.material.specular_tint), ((&ray_2)->unit_direction), (surface_11.random_state)));
                        _S1572 = _S1573;
                    }
                    else
                    {
                        SampleBSDF _S1574 = sampleBSDF((&ray_2)->unit_direction, _S1406.smooth_n, _S1405.material, _S1408.x, _S1408.y, surface_11.random_state, _S1460);
                        _S1572 = _S1574;
                    }
                    bsdf_sampled_0 = _S1572;
                    if(_S1413)
                    {
                        refracted_5 = !(((&bsdf_sampled_0)->pdf) > 0.0f);
                    }
                    else
                    {
                        refracted_5 = false;
                    }
                    if(refracted_5)
                    {
                        if(replay_2)
                        {
                            return _S1231;
                        }
                        break;
                    }
                    if(_S1413)
                    {
                        wrong_side_0 = false;
                    }
                    else
                    {
                        bool _S1575 = wrongSide_0(is_inside_6, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, surface_11.geometry_n);
                        wrong_side_0 = _S1575;
                    }
                    if(wrong_side_0)
                    {
                        _S1488 = (_S1405.material.transmission) > 0.0f;
                    }
                    else
                    {
                        _S1488 = false;
                    }
                    if(_S1488)
                    {
                        SampleBSDF _S1576 = sampleBSDF((&bsdf_sampled_0)->unit_direction, surface_11.geometry_n, _S1405.material, _S1408.x, _S1408.y, (&bsdf_sampled_0)->random_state, _S1460);
                        (&bsdf_sampled_0)->unit_direction = _S1576.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1576.refracted;
                        (&bsdf_sampled_0)->throughput = _S1576.throughput;
                    }
                    else
                    {
                        if(wrong_side_0)
                        {
                            float3  _S1577 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, surface_11.geometry_n)) * surface_11.geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1577;
                        }
                    }
                    uint _S1578 = (&bsdf_sampled_0)->lobe;
                    float3  _S1579 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1580 = (&bsdf_sampled_0)->refracted;
                    lobe_5 = bsdf_sampled_0;
                    float _S1581 = (&bsdf_sampled_0)->pdf;
                    float _S1582 = _slang_select(wrong_side_0, 0.0f,_S1581);
                    (&lobe_5)->pdf = _S1582;
                    throughput_11 = _S1579;
                    b_11 = _S1578;
                    refracted_5 = _S1580;
                }
                else
                {
                    throughput_11 = _S1552;
                    b_11 = _S1551;
                    wrong_side_0 = false;
                    refracted_5 = refracted_6;
                }
                reconnection_1 = reconnection_0;
            }
            if(viewed_1)
            {
                _S1488 = true;
            }
            else
            {
                _S1488 = _S1443;
            }
            float3  chain_throughput_1;
            if(_S1488)
            {
                if(_S1413)
                {
                    SampleBSDF _S1583 = (fcptConnectHair((surface_11.hair), (_S1405.material.albedo), (_S1405.material.specular_tint), ((&ray_2)->unit_direction), (throughput_11)));
                    lobe_5 = _S1583;
                }
                else
                {
                    float3  _S1584 = (&ray_2)->unit_direction;
                    float _S1585 = sign_0(_S1407);
                    float3  _S1586 = _S1406.smooth_n * make_float3 (_S1585);
                    float _S1587 = dot_0(_S1586, throughput_11);
                    float _S1588 = _S1405.material.roughness;
                    float _S1589 = _S1588 * _S1588;
                    AnisotropicFrame _S1590 = anisotropicFrame(_S1405.material, _S1586);
                    float3  _S1591 = reflectedHalf(_S1584, throughput_11);
                    bool _S1592 = b_11 == 1U;
                    if(_S1592)
                    {
                        float3  _S1593 = refractedHalf(_S1584, throughput_11, _S1406.smooth_n, _S1408.x, _S1408.y);
                        throughput_12 = _S1593;
                    }
                    else
                    {
                        throughput_12 = _S1591;
                    }
                    bool _S1594 = b_11 == 0U;
                    if(_S1594)
                    {
                        _S1489 = true;
                    }
                    else
                    {
                        _S1489 = b_11 == 6U;
                    }
                    if(_S1489)
                    {
                        float3  _S1595 = sampledHalf(_S1584, _S1406.smooth_n, _S1405.material, surface_11.random_state, _S1590);
                        throughput_13 = _S1595;
                    }
                    else
                    {
                        throughput_13 = throughput_12;
                    }
                    float3  _S1596 = negate_0(_S1584);
                    float _S1597 = _S1408.x;
                    float _S1598 = _S1408.y;
                    BSDFLobes _S1599 = bsdfLobes(_S1584, _S1596, _S1586, throughput_13, _S1405.material, _S1597, _S1598, _S1590);
                    BSDFLobes lobe_terms_2 = _S1599;
                    float _S1600 = translucentShare(_S1405.material);
                    (&lobe_terms_2)->translucent_share = _S1600;
                    switch(b_11)
                    {
                    case 0U:
                        {
                            float _S1601 = diffusePDF(_S1587, 0.0f, (F32_abs((_S1407))), _S1589, lobe_terms_2, _S1597, _S1598);
                            float3  _S1602 = diffuseBSDF(throughput_11, _S1586, _S1589, _S1405.material, lobe_terms_2);
                            density_6 = _S1601;
                            chain_throughput_1 = _S1602;
                            break;
                        }
                    case 1U:
                        {
                            float _S1603 = refractPDF(_S1587, dot_0(throughput_11, throughput_13), (F32_abs((_S1407))), _S1589, lobe_terms_2, _S1597, _S1598);
                            float3  _S1604 = refractBSDF(throughput_11, _S1586, _S1589, _S1405.material, lobe_terms_2);
                            density_6 = _S1603;
                            chain_throughput_1 = _S1604;
                            break;
                        }
                    case 4U:
                        {
                            float _S1605 = sheenVelvetPDF(_S1587, 0.0f, (F32_abs((_S1407))), _S1589, lobe_terms_2, _S1597, _S1598);
                            float3  _S1606 = sheenVelvetBSDF(throughput_11, _S1586, _S1589, _S1405.material, lobe_terms_2);
                            density_6 = _S1605;
                            chain_throughput_1 = _S1606;
                            break;
                        }
                    case 6U:
                        {
                            float _S1607 = toonPDF(_S1587, dot_0(throughput_11, (&lobe_terms_2)->toon_axis), (F32_abs((_S1407))), _S1589, lobe_terms_2, _S1597, _S1598);
                            float3  _S1608 = toonBSDF(throughput_11, _S1586, _S1589, _S1405.material, lobe_terms_2);
                            density_6 = _S1607;
                            chain_throughput_1 = _S1608;
                            break;
                        }
                    default:
                        {
                            float _S1609 = reflectPDF(_S1587, 0.0f, (F32_abs((_S1407))), _S1589, lobe_terms_2, _S1597, _S1598);
                            float3  _S1610 = reflectBSDF(throughput_11, _S1586, _S1589, _S1405.material, lobe_terms_2);
                            density_6 = _S1609;
                            chain_throughput_1 = _S1610;
                            break;
                        }
                    }
                    bool _S1611 = density_6 > 0.0f;
                    if(_S1611)
                    {
                        SampleBSDF _S1612 = SampleBSDF_x24init_0(throughput_11, chain_throughput_1, surface_11.random_state, _S1592, b_11, density_6);
                        lobe_5 = _S1612;
                    }
                }
            }
            bool _S1613 = b_11 == 0U;
            if(_S1613)
            {
                _S1489 = true;
            }
            else
            {
                _S1489 = b_11 == 4U;
            }
            if(_S1489)
            {
                _S1534 = true;
            }
            else
            {
                _S1534 = b_11 == 6U;
            }
            if(_S1413)
            {
                _S1535 = false;
            }
            else
            {
                bool _S1614 = !_S1534;
                if(_S1614)
                {
                    bool _S1615 = (_S1405.material.roughness) == 0.0f;
                    if(_S1615)
                    {
                        _S1535 = true;
                    }
                    else
                    {
                        bool _S1616 = b_11 == 1U;
                        if(_S1616)
                        {
                            _S1535 = (_S1408.x) == (_S1408.y);
                        }
                        else
                        {
                            _S1535 = false;
                        }
                    }
                }
                else
                {
                    _S1535 = false;
                }
            }
            bool _S1617 = !_S1413;
            if(_S1617)
            {
                _S1536 = b_11 == 1U;
            }
            else
            {
                _S1536 = false;
            }
            if(_S1536)
            {
                straight_0 = (_S1405.material.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S1537 = _S1617;
            }
            else
            {
                _S1537 = false;
            }
            if(_S1537)
            {
                _S1538 = b_11 == 1U;
            }
            else
            {
                _S1538 = false;
            }
            if(_S1538)
            {
                _S1539 = (_S1408.x) == (_S1408.y);
            }
            else
            {
                _S1539 = false;
            }
            BSDFMaterial _S1618 = _S1405.material;
            bool _S1619 = isTranslucent_0(&_S1618);
            if(_S1619)
            {
                _S1540 = _S1613;
            }
            else
            {
                _S1540 = false;
            }
            if(_S1540)
            {
                _S1541 = (dot_0(throughput_11, surface_11.geometry_n)) < 0.0f;
            }
            else
            {
                _S1541 = false;
            }
            if(nee_0)
            {
                _S1542 = !_S1535;
            }
            else
            {
                _S1542 = false;
            }
            if(_S1542)
            {
                _S1543 = !wrong_side_0;
            }
            else
            {
                _S1543 = false;
            }
            if(_S1543)
            {
                float _S1620 = (&lobe_5)->pdf;
                float3  _S1621 = (&ray_2)->origin;
                float3  _S1622 = _slang_select(_S1418, _S1230,_S1406.smooth_n);
                float3  _S1623 = (&ray_2)->origin;
                FKSurface _S1624 = surface_11;
                float3  _S1625 = - _S1406.smooth_n;
                float3  _S1626 = _slang_select(_S1541, _S1625,_S1406.smooth_n);
                NEEVertex _S1627 = NEEVertex_x24init_0(false, _S1620, _S1621, _S1622, _S1623 + make_float3 (_S1624.geometry_offset) * _S1626);
                nee_vertex_0 = _S1627;
            }
            else
            {
                if(_S1413)
                {
                    _S1544 = true;
                }
                else
                {
                    bool _S1628 = b_11 != 1U;
                    if(_S1628)
                    {
                        _S1544 = true;
                    }
                    else
                    {
                        _S1544 = (_S1408.x) != (_S1408.y);
                    }
                }
                if(_S1544)
                {
                    (&nee_vertex_0)->none = true;
                }
            }
            bool _S1629 = withinInverseFootprint((&lobe_5)->pdf, _S1534, (&prev_0)->cos, (&hit_4)->distance, threshold_2);
            bool _S1630 = roughLobe((&lobe_5)->pdf, _S1534, _S1405.material.roughness);
            if(_S1443)
            {
                bool _S1631 = !_S1629;
                if(_S1631)
                {
                    return _S1231;
                }
                bool _S1632 = _S1236 != 1U;
                if(_S1632)
                {
                    _S1544 = _S1236 != 2U;
                }
                else
                {
                    _S1544 = false;
                }
                if(_S1544)
                {
                    float _S1633 = (&lobe_5)->pdf;
                    float _S1634 = _slang_select(nee_0, _S1633,0.0f);
                    float _S1635 = escapeWeight_0(_S1634, _S1552);
                    if(_S1451)
                    {
                        passes_0 = _S1242;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1636 = _slang_select(passes_0, _S1635,1.0f);
                    return Shift_x24init_0(throughput_9 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf)) * r_8->radiance * make_float3 (_S1636) / make_float3 (r_8->jac), density_4 * (&lobe_5)->pdf / r_8->jac);
                }
                float3  _S1637 = throughput_9 * make_float3 ((&lobe_5)->pdf);
                float _S1638 = density_4 * (&lobe_5)->pdf;
                throughput_12 = _S1637;
                density_6 = _S1638;
            }
            else
            {
                throughput_12 = throughput_9;
                density_6 = density_4;
            }
            uint _S1639 = (fcptLayers((hit_4)));
            bool _S1640 = b_11 == 1U;
            bool _S1641 = passesLayer_0(_S1639, _S1640, passes_0);
            if(viewed_1)
            {
                _S1544 = _S1641;
            }
            else
            {
                _S1544 = false;
            }
            if(_S1544)
            {
                return _S1231;
            }
            if(replay_2)
            {
                _S1545 = b_8 <= _S1246;
            }
            else
            {
                _S1545 = false;
            }
            if(_S1545)
            {
                _S1546 = _S1404;
            }
            else
            {
                _S1546 = false;
            }
            if(_S1546)
            {
                _S1547 = _S1629;
            }
            else
            {
                _S1547 = false;
            }
            if(_S1547)
            {
                _S1548 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S1548 = !_S1630;
                }
                else
                {
                    _S1548 = false;
                }
            }
            if(_S1548)
            {
                return _S1231;
            }
            if(viewed_1)
            {
                float3  _S1642 = throughput_12 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf));
                float _S1643 = (&lobe_5)->pdf;
                throughput_13 = _S1642;
                sky_pdf_2 = _S1643;
            }
            else
            {
                float3  _S1644 = throughput_12 * max_0((&lobe_5)->throughput, _S1230);
                throughput_13 = _S1644;
                sky_pdf_2 = density_6;
            }
            bool _S1645 = !replay_2;
            bool _S1646;
            if(_S1645)
            {
                _S1646 = !_S1434;
            }
            else
            {
                _S1646 = false;
            }
            bool _S1647;
            if(_S1646)
            {
                _S1647 = _S1404;
            }
            else
            {
                _S1647 = false;
            }
            bool _S1648;
            if(_S1647)
            {
                _S1648 = _S1629;
            }
            else
            {
                _S1648 = false;
            }
            if(_S1648)
            {
                chain_0 = here_0;
                uint _S1649 = insertBits_0((&chain_0)->path, b_11, 18U, 3U);
                uint _S1650 = _slang_select(nee_0, 1U,0U);
                uint _S1651 = insertBits_0(_S1649, _S1650, 21U, 1U);
                (&chain_0)->path = _S1651;
                float _S1652 = (&chain_0)->jac * (&lobe_5)->pdf;
                (&chain_0)->jac = _S1652;
                (&chain_0)->dir = throughput_11;
                chain_throughput_1 = throughput_13;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            FKSurface _S1653 = surface_11;
            Vertex _S1654 = Vertex_x24init_0(_S1630, b_11, (&lobe_5)->pdf, (F32_abs((dot_0(surface_11.geometry_n, throughput_11)))), is_inside_6);
            prev_0 = _S1654;
            float _S1655 = (&lobe_5)->pdf;
            bool _S1656;
            if(_S1640)
            {
                _S1656 = (_S1408.x) == (_S1408.y);
            }
            else
            {
                _S1656 = false;
            }
            float sky_pdf_3 = _slang_select(_S1656, sky_pdf_0,_S1655);
            float _S1657 = _slang_select(_S1413, 0.0f,sky_pdf_3);
            float _S1658 = widened_0(spread_2, (&lobe_5)->pdf, _S1535);
            bool _S1659;
            if(refracted_5)
            {
                _S1659 = !_S1541;
            }
            else
            {
                _S1659 = false;
            }
            bool is_inside_7;
            if(_S1659)
            {
                bool _S1660 = !is_inside_6;
                is_inside_7 = _S1660;
            }
            else
            {
                is_inside_7 = is_inside_6;
            }
            FKSurface _S1661 = surface_11;
            bool _S1662 = boundsVolume_0(&_S1661);
            bool _S1663;
            if(_S1662)
            {
                _S1663 = !_S1641;
            }
            else
            {
                _S1663 = false;
            }
            if(_S1663)
            {
                FKSurface faced_2 = surface_11;
                float3  _S1664 = - _S1653.geometry_n;
                float3  _S1665 = _slang_select(turned_1, _S1664,_S1653.geometry_n);
                (&faced_2)->geometry_n = _S1665;
                FKMedium _S1666 = Medium_x24init_0(scatter_in_0, extinction_in_0, g_in_0);
                FKMedium _S1667 = (fcptOutsideMedium((hit_4)));
                FKSurface _S1668 = faced_2;
                FKMedium _S1669 = _S1666;
                FKMedium _S1670 = _S1667;
                MediumSides _S1671 = mediumSides_0(&_S1668, &_S1669, filling_2, (&ray_2)->unit_direction, &_S1670);
                bool _S1672 = leavesInFront_0((&faced_2)->geometry_n, throughput_11, _S1653.geometry_n);
                float3  _S1673 = _slang_select(_S1672, _S1671.front.scatter,_S1671.behind.scatter);
                scatter_in_0 = _S1673;
                float3  _S1674 = _slang_select(_S1672, _S1671.front.extinction,_S1671.behind.extinction);
                extinction_in_0 = _S1674;
                float _S1675 = _slang_select(_S1672, _S1671.front.g,_S1671.behind.g);
                g_in_0 = _S1675;
                uint _S1676 = _S1671.fillings.x;
                uint _S1677 = _S1671.fillings.y;
                uint _S1678 = _slang_select(_S1672, _S1677,_S1676);
                bool _S1679 = (fcptVaryingUsed());
                uint _S1680 = _slang_select(_S1679, _S1678,4294967295U);
                filling_2 = _S1680;
            }
            (&ray_2)->unit_direction = throughput_11;
            bool _S1681 = !_S1641;
            if(_S1681)
            {
                FKSurface _S1682 = surface_11;
                float _S1683 = _slang_select(straight_0, 0.0f,_S1682.geometry_offset);
                float3  _S1684 = - _S1406.smooth_n;
                bool _S1685 = is_inside_7 != _S1541;
                float3  _S1686 = _slang_select(_S1685, _S1684,_S1406.smooth_n);
                float3  _S1687 = (&ray_2)->origin + make_float3 (_S1683) * _S1686;
                (&ray_2)->origin = _S1687;
            }
            throughput_12 = throughput_13;
            chain_throughput_0 = chain_throughput_1;
            density_6 = sky_pdf_2;
            passes_0 = _S1641;
            viewed_1 = _S1539;
            sky_pdf_2 = _S1657;
            spread_5 = _S1658;
            reconnection_0 = reconnection_1;
            is_inside_5 = is_inside_7;
        }
        else
        {
            (&prev_0)->rough = false;
            (&prev_0)->pdf = 0.0f;
            throughput_12 = throughput_9;
            density_6 = density_4;
            passes_0 = false;
            viewed_1 = viewed_0;
            sky_pdf_2 = 0.0f;
            spread_5 = spread_2;
            straight_0 = false;
            is_inside_5 = is_inside_6;
        }
        bool _S1688 = !replay_2;
        float density_7;
        if(_S1688)
        {
            if(_S1372)
            {
                float3  _S1689 = throughput_12 * emission_1;
                Reservoir candidate_8 = chain_0;
                uint _S1690 = extractBits_0((&chain_0)->path, 10U, 2U);
                bool _S1691 = _S1690 == 1U;
                if(_S1691)
                {
                    float3  _S1692 = safeDivide(_S1689, chain_throughput_0);
                    (&candidate_8)->radiance = _S1692;
                }
                Reservoir _S1693 = withEnd(candidate_8, 2U, b_8, _S1689);
                offer(sel_7, _S1693, _S1689 * make_float3 (scale_3) / make_float3 (density_6));
            }
            if(_S1372)
            {
                refracted_5 = true;
            }
            else
            {
                refracted_5 = scatter_2;
            }
            if(refracted_5)
            {
                float _S1694 = survivalProbability(throughput_12, density_6);
                density_7 = _S1694;
            }
            else
            {
                density_7 = 1.0f;
            }
            uint _S1695 = stream(_S1258, b_8 + 128U);
            Random _S1696 = pcg(_S1695);
            bool _S1697 = density_7 < (_S1696.value);
            if(_S1697)
            {
                wrong_side_0 = true;
            }
            else
            {
                uint _S1698 = (fcptMaxBounces());
                wrong_side_0 = b_8 >= _S1698;
            }
            if(wrong_side_0)
            {
                break;
            }
            float _S1699 = density_6 * density_7;
            density_7 = _S1699;
        }
        else
        {
            density_7 = density_6;
        }
        uint _S1700 = layer_0 ^ 1U;
        uint _S1701 = _slang_select(passes_0, _S1700,0U);
        if(passes_0)
        {
            (&prev_0)->rough = false;
            (&hit_4)->distance = 0.0f;
            b_11 = b_8;
            viewed_0 = viewed_1;
            throughput_5 = throughput_12;
            density_2 = density_7;
            sky_pdf_0 = sky_pdf_2;
            spread_2 = spread_5;
            uint _S1702 = b_11 + 1U;
            b_8 = _S1702;
            layer_0 = _S1701;
            continue;
        }
        FKRay _S1703 = ray_2;
        float _S1704 = distance_1(reconnection_0, (&ray_2)->origin) * 1.0010000467300415f;
        if(replay_2)
        {
            refracted_5 = _S1444;
        }
        else
        {
            refracted_5 = false;
        }
        if(refracted_5)
        {
            wrong_side_0 = _S1235 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S1705 = _slang_select(wrong_side_0, _S1704,4.294967296e+09f);
        bool _S1706 = !_S1413;
        if(straight_0)
        {
            _S1488 = true;
        }
        else
        {
            _S1488 = _S1413;
        }
        FKHit _S1707;
        if(_S1488)
        {
            _S1707 = hit_4;
        }
        else
        {
            _S1707 = _S1461;
        }
        FKHit _S1708 = (fcptTraverseInstanceBVH((_S1703), (_S1380), (_S1705), (_S1706), (_S1707), (viewed_1)));
        hit_4 = _S1708;
        if(replay_2)
        {
            _S1489 = _S1444;
        }
        else
        {
            _S1489 = false;
        }
        if(_S1489)
        {
            _S1534 = _S1235 == 1U;
        }
        else
        {
            _S1534 = false;
        }
        if(_S1534)
        {
            _S1535 = ((&hit_4)->instance_index) == (_S1247.instance_index);
        }
        else
        {
            _S1535 = false;
        }
        if(_S1535)
        {
            _S1536 = ((&hit_4)->triangle_index) == (_S1247.triangle_index);
        }
        else
        {
            _S1536 = false;
        }
        if(_S1536)
        {
            (&hit_4)->uv = _S1247.uv;
            float _S1709 = distance_1(reconnection_0, (&ray_2)->origin);
            (&hit_4)->distance = _S1709;
        }
        if(replay_2)
        {
            _S1537 = _S1444;
        }
        else
        {
            _S1537 = false;
        }
        if(_S1537)
        {
            _S1538 = _S1235 == 3U;
        }
        else
        {
            _S1538 = false;
        }
        if(_S1538)
        {
            _S1539 = ((&hit_4)->instance_index) != 4294967295U;
        }
        else
        {
            _S1539 = false;
        }
        if(_S1539)
        {
            return _S1231;
        }
        Reservoir _S1710 = chain_0;
        uint _S1711 = filling_2;
        for(;;)
        {
            bool _S1712 = (fcptVaryingUsed());
            if(_S1712)
            {
                _S1540 = _S1711 != 4294967295U;
            }
            else
            {
                _S1540 = false;
            }
            float _S1713;
            if(_S1540)
            {
                float _S1714 = (fcptMajorant((_S1711)));
                _S1713 = _S1714;
            }
            else
            {
                _S1713 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
            }
            if(replay_2)
            {
                _S1541 = _S1444;
            }
            else
            {
                _S1541 = false;
            }
            if(_S1541)
            {
                _S1542 = _S1235 == 1U;
            }
            else
            {
                _S1542 = false;
            }
            if(_S1542)
            {
                _S1543 = _S1713 > 0.0f;
            }
            else
            {
                _S1543 = false;
            }
            if(_S1543)
            {
                ended_0 = _S1231;
                sky_pdf_1 = sky_pdf_2;
                spread_3 = spread_5;
                width_4 = width_3;
                density_3 = density_7;
                throughput_13 = throughput_12;
                b_11 = b_8;
                _S1544 = true;
                break;
            }
            bool _S1715 = (&prev_0)->rough;
            if(_S1715)
            {
                _S1544 = !(_S1713 > 0.0f);
            }
            else
            {
                _S1544 = false;
            }
            (&prev_0)->rough = _S1544;
            uint _S1716 = b_8 + 320U;
            bool _S1717 = b_8 == 4294967295U;
            uint _S1718 = _slang_select(_S1717, 384U,_S1716);
            uint _S1719 = stream(_S1258, _S1718);
            uint tracking_1 = _S1719;
            weight_1 = throughput_6;
            glowed_0 = _S1230;
            b_11 = b_8;
            throughput_13 = throughput_12;
            density_3 = density_7;
            spread_3 = spread_5;
            width_4 = width_3;
            sky_pdf_1 = sky_pdf_2;
            for(;;)
            {
                if(((&hit_4)->instance_index) != 4294967295U)
                {
                }
                else
                {
                    _S1229 = int(2);
                    break;
                }
                uint _S1720 = b_11 + 320U;
                bool _S1721 = b_11 == 4294967295U;
                uint _S1722 = _slang_select(_S1721, 384U,_S1720);
                uint _S1723 = stream(_S1258, _S1722);
                Random _S1724 = pcg(_S1723);
                float _S1725 = freeFlight_0(_S1724.value, _S1713);
                if(_S1540)
                {
                    float3  _S1726 = (&ray_2)->origin;
                    float3  _S1727 = (&ray_2)->unit_direction;
                    float _S1728 = (&hit_4)->distance;
                    uint _S1729 = _slang_select(_S1721, 0U,b_11);
                    uint _S1730 = (&prev_0)->lobe;
                    uint _S1731 = _slang_select(_S1721, 3U,_S1730);
                    float _S1732 = (fcptTrackMedium((_S1711), (_S1726), (_S1727), (_S1728), (&tracking_1), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1729), (_S1731), (_S1721)));
                    spread_4 = _S1732;
                }
                else
                {
                    spread_4 = _S1725;
                }
                bool _S1733 = !(spread_4 < ((&hit_4)->distance));
                if(_S1733)
                {
                    _S1229 = int(2);
                    break;
                }
                if(_S1540)
                {
                    _S1545 = _S1688;
                }
                else
                {
                    _S1545 = false;
                }
                if(_S1545)
                {
                    float3  _S1734 = throughput_13 * glowed_0 / make_float3 (density_3);
                    float3  _S1735 = sel_7->glow + _S1734;
                    sel_7->glow = _S1735;
                }
                else
                {
                }
                glowed_0 = _S1230;
                uint b_12 = b_11 + 1U;
                float3  _S1736 = (&ray_2)->origin + make_float3 (spread_4) * (&ray_2)->unit_direction;
                (&ray_2)->origin = _S1736;
                float3  _S1737 = flightWeight_0(scatter_in_0, extinction_in_0, _S1713, spread_4, true);
                float3  _S1738 = weight_1;
                float3  _S1739 = _slang_select(_S1540, _S1738,_S1737);
                float3  throughput_14 = throughput_13 * _S1739;
                uint _S1740 = stream(_S1258, b_12 + 320U);
                tracking_1 = _S1740;
                weight_1 = throughput_6;
                float width_7 = width_4 + spread_3 * spread_4;
                float _S1741 = spread_3 + 3.14159274101257324f;
                bool _S1742 = scatterSampled_0(replay_2, b_12, _S1246, _S1540);
                TreeSample light_4;
                if(_S1742)
                {
                    float3  _S1743 = (&ray_2)->origin;
                    float3  _S1744 = (&ray_2)->unit_direction;
                    float3  _S1745 = (&ray_2)->unit_direction;
                    uint _S1746 = stream(_S1258, b_12 + 64U);
                    float3  _S1747 = extinction_in_0;
                    float3  _S1748 = extinction_in_0;
                    uint2  _S1749 = make_uint2 (_S1711);
                    float3  _S1750 = (&ray_2)->unit_direction;
                    uint _S1751 = arrivalLobe_0(b_12, (&prev_0)->lobe);
                    FKHit _S1752 = _S1461;
                    ShadowContext _S1753 = ShadowContext_x24init_0(_S1747, _S1748, _S1749, _S1750, b_12, _S1751, false, spread_4, width_7, &_S1752, false);
                    ShadowContext _S1754 = _S1753;
                    TreeSample _S1755 = sampleLightTree_0(_S1743, _S1744, _S1745, 0.0f, true, _S1746, &_S1754);
                    light_4 = _S1755;
                }
                else
                {
                    light_4 = _S1458;
                }
                float _S1756 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_4.dir));
                uint _S1757 = (fcptMaxBounces());
                bool _S1758 = b_12 < _S1757;
                if(_S1758)
                {
                    _S1546 = (light_4.density) > 0.0f;
                }
                else
                {
                    _S1546 = false;
                }
                float _S1759 = _slang_select(_S1546, _S1756,0.0f);
                float3  _S1760 = throughput_14 * light_4.radiance;
                float _S1761 = powerHeuristic(light_4.density, _S1759);
                float3  _S1762 = _S1760 * make_float3 (_S1756 * _S1761);
                float3  _S1763 = _slang_select(_S1742, _S1762,_S1230);
                if(replay_2)
                {
                    _S1547 = b_12 == _S1246;
                }
                else
                {
                    _S1547 = false;
                }
                if(_S1547)
                {
                    bool _S1764 = _S1235 == 2U;
                    if(_S1764)
                    {
                        float _S1765 = rgb_to_greyscale(_S1763);
                        _S1548 = _S1765 > 0.0f;
                    }
                    else
                    {
                        _S1548 = false;
                    }
                    if(_S1548)
                    {
                        Shift _S1766 = Shift_x24init_0(_S1763, 1.0f);
                        _S1229 = int(1);
                        ended_0 = _S1766;
                        spread_4 = _S1741;
                        width_5 = width_7;
                        throughput_11 = throughput_14;
                        b_9 = b_12;
                        break;
                    }
                    _S1229 = int(1);
                    ended_0 = _S1231;
                    spread_4 = _S1741;
                    width_5 = width_7;
                    throughput_11 = throughput_14;
                    b_9 = b_12;
                    break;
                }
                if(_S1688)
                {
                    Reservoir candidate_9 = _S1710;
                    uint _S1767 = extractBits_0(_S1710.path, 10U, 2U);
                    bool _S1768 = _S1767 == 1U;
                    if(_S1768)
                    {
                        float3  _S1769 = safeDivide(_S1763, chain_throughput_0);
                        (&candidate_9)->radiance = _S1769;
                    }
                    else
                    {
                        uint _S1770 = insertBits_0(0U, b_12 + 1U, 5U, 5U);
                        uint _S1771 = insertBits_0(_S1770, 2U, 10U, 2U);
                        (&candidate_9)->path = _S1771;
                    }
                    Reservoir _S1772 = withEnd(candidate_9, 0U, b_12, _S1763);
                    offer(sel_7, _S1772, _S1763 * make_float3 (scale_3) / make_float3 (density_3));
                    float _S1773 = survivalProbability(throughput_14, density_3);
                    uint _S1774 = stream(_S1258, b_12 + 128U);
                    Random _S1775 = pcg(_S1774);
                    bool _S1776 = _S1773 < (_S1775.value);
                    if(_S1776)
                    {
                        _S1548 = true;
                    }
                    else
                    {
                        uint _S1777 = (fcptMaxBounces());
                        _S1548 = b_12 >= _S1777;
                    }
                    if(_S1548)
                    {
                        _S1229 = int(1);
                        ended_0 = _S1231;
                        spread_4 = _S1741;
                        width_5 = width_7;
                        throughput_11 = throughput_14;
                        b_9 = b_12;
                        break;
                    }
                    float _S1778 = density_3 * _S1773;
                    density_3 = _S1778;
                }
                else
                {
                }
                float phase_pdf_1 = 0.0f;
                uint _S1779 = stream(_S1258, b_12);
                float3  _S1780 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1779, &phase_pdf_1);
                (&ray_2)->unit_direction = _S1780;
                NEEVertex _S1781 = NEEVertex_x24init_0(false, phase_pdf_1, (&ray_2)->origin, _S1230, (&ray_2)->origin);
                nee_vertex_0 = _S1781;
                Vertex _S1782 = scatteredVertex_0(is_inside_5);
                prev_0 = _S1782;
                float _S1783 = (&prev_0)->pdf;
                FKRay _S1784 = ray_2;
                FKHit _S1785 = (fcptTraverseInstanceBVH((_S1784), (true), (4.294967296e+09f), (false), (_S1461), (false)));
                hit_4 = _S1785;
                b_11 = b_12;
                throughput_13 = throughput_14;
                spread_3 = _S1741;
                width_4 = width_7;
                sky_pdf_1 = _S1783;
            }
            if(_S1229 != int(2))
            {
                spread_3 = spread_4;
                width_4 = width_5;
                throughput_13 = throughput_11;
                b_11 = b_9;
                _S1544 = true;
                break;
            }
            ended_0 = _S1231;
            _S1544 = false;
            break;
        }
        if(_S1544)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S1545 = b_11 == b_8;
        }
        else
        {
            _S1545 = false;
        }
        bool _S1786 = ((&hit_4)->instance_index) == 4294967295U;
        if(_S1786)
        {
            bool _S1787 = !(&nee_vertex_0)->none;
            float _S1788 = _slang_select(_S1787, sky_pdf_1,0.0f);
            float _S1789 = escapeWeight_0(_S1788, (&ray_2)->unit_direction);
            float3  _S1790 = environment_0((&ray_2)->unit_direction, b_11, (&prev_0)->lobe);
            float3  _S1791 = throughput_13 * _S1790;
            if(replay_2)
            {
                bool _S1792 = b_11 == _S1246;
                if(_S1792)
                {
                    passes_0 = _S1235 == 3U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(_S1791 * make_float3 (_S1789) / make_float3 (r_8->jac), density_3 / r_8->jac);
                }
                if(_S1245)
                {
                    passes_0 = _S1242;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = b_11 == _S1233;
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
                    return Shift_x24init_0(_S1791 * make_float3 (_S1789), 1.0f);
                }
                return _S1231;
            }
            Reservoir candidate_10 = chain_0;
            uint _S1793 = extractBits_0((&chain_0)->path, 10U, 2U);
            bool _S1794 = _S1793 == 1U;
            if(_S1794)
            {
                uint _S1795 = extractBits_0((&chain_0)->path, 5U, 5U);
                bool _S1796 = _S1795 == b_11;
                float _S1797 = _slang_select(_S1796, 1.0f,_S1789);
                float3  _S1798 = safeDivide(_S1791 * make_float3 (_S1797), chain_throughput_0);
                (&candidate_10)->radiance = _S1798;
            }
            else
            {
                bool _S1799 = (&prev_0)->rough;
                if(_S1799)
                {
                    uint _S1800 = insertBits_0(0U, b_11 + 1U, 5U, 5U);
                    uint _S1801 = insertBits_0(_S1800, 3U, 10U, 2U);
                    uint _S1802 = insertBits_0(_S1801, (&prev_0)->lobe, 15U, 3U);
                    bool _S1803 = (&prev_0)->inside;
                    uint _S1804 = _slang_select(_S1803, 1U,0U);
                    uint _S1805 = insertBits_0(_S1802, _S1804, 22U, 1U);
                    (&candidate_10)->path = _S1805;
                    (&candidate_10)->jac = (&prev_0)->pdf;
                    (&candidate_10)->dir = (&ray_2)->unit_direction;
                }
            }
            float3  _S1806 = _S1791 * make_float3 (_S1789);
            Reservoir _S1807 = withEnd(candidate_10, 3U, b_11, _S1806);
            offer(sel_7, _S1807, _S1806 * make_float3 (scale_3) / make_float3 (density_3));
            break;
        }
        float3  _S1808 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
        (&ray_2)->origin = _S1808;
        bool _S1809 = (fcptVaryingUsed());
        if(_S1809)
        {
            _S1546 = filling_2 != 4294967295U;
        }
        else
        {
            _S1546 = false;
        }
        if(_S1546)
        {
            if(_S1688)
            {
                float3  _S1810 = throughput_13 * glowed_0 / make_float3 (density_3);
                float3  _S1811 = sel_7->glow + _S1810;
                sel_7->glow = _S1811;
            }
            float3  _S1812 = throughput_13 * weight_1;
            throughput_11 = _S1812;
        }
        else
        {
            float3  _S1813 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
            float3  _S1814 = throughput_13 * _S1813;
            throughput_11 = _S1814;
        }
        float _S1815 = width_4 + spread_3 * (&hit_4)->distance;
        viewed_0 = _S1545;
        width_3 = _S1815;
        throughput_5 = throughput_11;
        density_2 = density_3;
        sky_pdf_0 = sky_pdf_1;
        spread_2 = spread_3;
        uint _S1702 = b_11 + 1U;
        b_8 = _S1702;
        layer_0 = _S1701;
    }
    return _S1231;
}

static __device__ Shift shift_0(Domain * dom_8, Reservoir * r_9)
{
    Selection _S1816 = (Selection{});
    Selection sel_8 = _S1816;
    bool _S1817 = (r_9->w) <= 0.0f;
    if(_S1817)
    {
        return Shift_x24init_0(make_float3 (0.0f), 0.0f);
    }
    Shift _S1818 = walk_0(dom_8, r_9, true, 0.0f, &sel_8);
    return _S1818;
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
        *_slang_vector_get_element_ptr(&result_14, i_23) = (F32_tan((_slang_vector_get_element(x_26, i_23))));
        i_23 = i_23 + int(1);
    }
    return result_14;
}

static __device__ float3  acos_0(float3  x_27)
{
    float3  result_15;
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
        *_slang_vector_get_element_ptr(&result_15, i_24) = (F32_acos((_slang_vector_get_element(x_27, i_24))));
        i_24 = i_24 + int(1);
    }
    return result_15;
}

static __device__ float3  abs_0(float3  x_28)
{
    float3  result_16;
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
        *_slang_vector_get_element_ptr(&result_16, i_25) = (F32_abs((_slang_vector_get_element(x_28, i_25))));
        i_25 = i_25 + int(1);
    }
    return result_16;
}

__device__ Random normal_distribution(uint state_4)
{
    Random _S1819 = pcg(state_4);
    Random _S1820 = pcg(_S1819.state);
    float _S1821 = 6.28318548202514648f * _S1819.value;
    float _S1822 = (F32_sqrt((-2.0f * clamp_1((F32_log((_S1820.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S1820.state, _S1822 * (F32_cos((_S1821))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_5, float3  value_2)
{
    RandomSphere _S1823;
    (&_S1823)->state = state_5;
    (&_S1823)->value = value_2;
    return _S1823;
}

__device__ RandomSphere random_sphere(uint state_6)
{
    Random _S1824 = normal_distribution(state_6);
    Random _S1825 = normal_distribution(_S1824.state);
    Random _S1826 = normal_distribution(_S1825.state);
    float3  _S1827 = make_float3 (_S1824.value, _S1825.value, _S1826.value);
    float3  _S1828 = ((((_S1827)) * make_float3(rnorm3df(((_S1827)).x, ((_S1827)).y, ((_S1827)).z))));
    return RandomSphere_x24init_0(_S1826.state, _S1828);
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_16)
{
    float3  _S1829 = p1_0 - p0_0;
    float3  _S1830 = p2_0 - p0_0;
    float2  _S1831 = uv1_0 - uv0_0;
    float2  _S1832 = uv2_0 - uv0_0;
    float _S1833 = _S1831.x;
    float _S1834 = _S1832.y;
    float _S1835 = _S1831.y;
    float _S1836 = _S1832.x;
    float _S1837 = _S1833 * _S1834 - _S1835 * _S1836;
    float _S1838 = 1.0f / _S1837;
    float3  t_21 = (_S1829 * make_float3 (_S1834) - _S1830 * make_float3 (_S1835)) * make_float3 (_S1838);
    float3  _S1839 = (_S1830 * make_float3 (_S1833) - _S1829 * make_float3 (_S1836)) * make_float3 (_S1838);
    float3  _S1840 = t_21 - n_16 * make_float3 (dot_0(n_16, t_21));
    float3  t_22 = ((((_S1840)) * make_float3(rnorm3df(((_S1840)).x, ((_S1840)).y, ((_S1840)).z))));
    bool _S1841 = (dot_0(cross_0(n_16, t_22), _S1839)) > 0.0f;
    float3  t_23;
    if(_S1841)
    {
        float3  _S1842 = negate_0(t_22);
        t_23 = _S1842;
    }
    else
    {
        t_23 = t_22;
    }
    float3  _S1843 = cross_0(n_16, t_23);
    return makeMatrix<float, 3, 3> (t_23, _S1843, n_16);
}

__device__ float3  tangentToWorldNormalMap(float3  v_4, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_4, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_5, float3  uvw_0, float3  position_0)
{
    float3  _S1844 = t1_0 - t0_0;
    float3  _S1845 = t2_2 - t0_0;
    float3  _S1846 = t2_2 - t1_0;
    float _S1847 = (F32_min((length_0(_S1844)), ((F32_min((length_0(_S1845)), (length_0(_S1846)))))));
    float3  _S1848 = make_float3 (distance_1(position_0, t0_0), distance_1(position_0, t1_0), distance_1(position_0, t2_2));
    float3  _S1849 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S1850 = dot_0(geometry_n_5, _S1849);
    float3  _S1851 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S1852 = dot_0(geometry_n_5, _S1851);
    float3  _S1853 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S1854 = acos_0(abs_0(make_float3 (_S1850, _S1852, dot_0(geometry_n_5, _S1853))));
    float3  _S1855 = clamp_2(tan_0(_S1854), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_1(dot_0(_S1848 * _S1855, uvw_0), 0.0f, _S1847 * 0.125f);
}

__device__ float3  straightThrough(float3  dir_16, float3  n_17, BSDFMaterial material_26)
{
    float3  _S1856 = negate_0(dir_16);
    float _S1857 = sign_0(dot_0(n_17, _S1856));
    float3  _S1858 = n_17 * make_float3 (_S1857);
    AnisotropicFrame _S1859 = anisotropicFrame(material_26, _S1858);
    bool _S1860 = (_S1859.alphas.x) > 0.0f;
    if(_S1860)
    {
        float _S1861 = material_26.transmission * (1.0f - material_26.metallic);
        float3  _S1862 = negate_0(_S1858);
        float3  _S1863 = anisotropicLocal(dir_16, _S1859.tangent, _S1862);
        float _S1864 = anisotropicG1(_S1863, _S1859.alphas);
        return make_float3 (_S1861 * _S1864) * material_26.albedo;
    }
    float _S1865 = material_26.transmission * (1.0f - material_26.metallic);
    float _S1866 = material_26.roughness;
    float _S1867 = smithG1(_S1866 * _S1866, (F32_abs((dot_0(n_17, dir_16)))));
    return make_float3 (_S1865 * _S1867) * material_26.albedo;
}

__device__ float hairRow(float3  in_dir_14, float3  t_24, float3  out_dir_5, uint p_13, float w_2, float alpha_20, uint nt_0)
{
    uint _S1868 = p_13 % 4U;
    float _S1869 = w_2 * HAIR_WIDTHS_0[_S1868];
    float _S1870 = (F32_asin((clamp_1(dot_0(out_dir_5, t_24), -1.0f, 1.0f)))) - (F32_asin((clamp_1(dot_0(in_dir_14, t_24), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S1868] * alpha_20;
    return ((F32_asinh((_S1870 / _S1869))) / (F32_asinh((3.14159274101257324f / _S1869))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_15, float3  t_25, float3  out_dir_6, uint np_0)
{
    float3  _S1871 = worldToTangent(out_dir_6, t_25);
    float3  _S1872 = worldToTangent(in_dir_15, t_25);
    return (F32_frac((((F32_atan2((_S1871.z), (_S1871.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S1872.z), (1.17549435082228751e-38f - _S1872.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_16, float3  t_26, uint p_14, float row_0, float column_0, float w_3, float alpha_21, uint nt_1, uint np_1)
{
    float3  _S1873 = worldToTangent(in_dir_16, t_26);
    uint _S1874 = p_14 % 4U;
    float _S1875 = w_3 * HAIR_WIDTHS_0[_S1874];
    float _S1876 = (F32_asin((clamp_1(dot_0(in_dir_16, t_26), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S1874] * alpha_21 + _S1875 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S1875))))));
    float _S1877 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S1873.z), (1.17549435082228751e-38f - _S1873.x)));
    float _S1878 = (F32_cos((_S1876)));
    float3  _S1879 = tangentToWorld(make_float3 (_S1878 * (F32_cos((_S1877))), (F32_sin((_S1876))), _S1878 * (F32_sin((_S1877)))), t_26);
    return _S1879;
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_18, BSDFMaterial material_27, float coverage_1)
{
    float3  _S1880;
    if((material_27.ior) == 1.0f)
    {
        float3  _S1881 = straightThrough(toward_1, n_18, material_27);
        _S1880 = _S1881;
    }
    else
    {
        _S1880 = make_float3 (0.0f);
    }
    return _S1880 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ Shift walk_hook(Domain dom_9, Reservoir r_10, bool replay_3, float scale_4, Selection * sel_9)
{
    Domain _S1882 = dom_9;
    Reservoir _S1883 = r_10;
    Shift _S1884 = walk_0(&_S1882, &_S1883, replay_3, scale_4, sel_9);
    return _S1884;
}

__device__ Shift shift_hook(Domain dom_10, Reservoir r_11)
{
    Domain _S1885 = dom_10;
    Reservoir _S1886 = r_11;
    Shift _S1887 = shift_0(&_S1885, &_S1886);
    return _S1887;
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
