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

__device__ float importance(LightNode node_0, float3  p_8, float3  normal_0)
{
    float3  _S215 = (node_0.low + node_0.high) * make_float3 (0.5f);
    float3  _S216 = node_0.high - node_0.low;
    float3  _S217 = p_8 - _S215;
    float3  _S218 = ((((_S217)) * make_float3(rnorm3df(((_S217)).x, ((_S217)).y, ((_S217)).z))));
    float _S219 = dot_0(_S217, _S217);
    float _S220 = dot_0(_S216, _S216) / 4.0f;
    float _S221 = (F32_abs((dot_0(node_0.w, _S218))));
    float _S222 = sine(node_0.cos_theta_o);
    float _S223 = (F32_sqrt(((F32_max((1.0f - _S220 / _S219), (0.0f))))));
    bool _S224 = _S219 < _S220;
    float _S225 = _slang_select(_S224, -1.0f,_S223);
    float _S226 = sine(_S225);
    float _S227 = sine(_S221);
    float _S228 = cosSubClamped(_S227, _S221, _S222, node_0.cos_theta_o);
    float _S229 = sine(_S221);
    float _S230 = _S229 * node_0.cos_theta_o - _S221 * _S222;
    bool _S231 = _S221 > (node_0.cos_theta_o);
    float _S232 = _slang_select(_S231, 0.0f,_S230);
    float _S233 = cosSubClamped(_S232, _S228, _S226, _S225);
    bool _S234 = _S233 <= 0.0f;
    if(_S234)
    {
        return 0.0f;
    }
    float _S235 = - dot_0(_S218, normal_0);
    float _S236 = node_0.phi * _S233 / (F32_max((_S219), (length_0(_S216) / 2.0f)));
    float _S237 = sine(_S235);
    float _S238 = cosSubClamped(_S237, _S235, _S226, _S225);
    bool _S239 = (dot_0(normal_0, normal_0)) == 0.0f;
    float _S240 = _slang_select(_S239, 1.0f,_S238);
    return (F32_max((_S236 * _S240), (0.0f)));
}

__device__ __forceinline__ float childShare(LightNode first_0, LightNode second_0, float3  p_9, float3  normal_1, uint child_0)
{
    float _S241 = importance(first_0, p_9, normal_1);
    float _S242 = importance(second_0, p_9, normal_1);
    float2  _S243 = make_float2 (_S241, _S242);
    float _S244 = _slang_vector_get_element(_S243, child_0) / (_S241 + _S242);
    bool _S245 = _slang_vector_get_element(_S243, child_0) > 0.0f;
    float _S246 = _slang_select(_S245, _S244,0.0f);
    return _S246;
}

__device__ float sphereDensity(float3  center_0, float radius_0, float3  p_10)
{
    float3  _S247 = center_0 - p_10;
    float _S248 = radius_0 * radius_0 / dot_0(_S247, _S247);
    bool _S249 = _S248 >= 1.0f;
    if(_S249)
    {
        return 0.07957746833562851f;
    }
    return (1.0f + (F32_sqrt((1.0f - _S248)))) / (6.28318548202514648f * _S248);
}

static __device__ float3  cross_0(float3  left_0, float3  right_0)
{
    float _S250 = left_0.y;
    float _S251 = right_0.z;
    float _S252 = left_0.z;
    float _S253 = right_0.y;
    float _S254 = right_0.x;
    float _S255 = left_0.x;
    return make_float3 (_S250 * _S251 - _S252 * _S253, _S252 * _S254 - _S255 * _S251, _S255 * _S253 - _S250 * _S254);
}

__device__ float solidAngle(float probability_0, float3  normal_2, float3  toward_0)
{
    return 2.0f * probability_0 * (F32_pow((length_0(toward_0)), (3.0f))) / (F32_abs((dot_0(normal_2, toward_0))));
}

static __device__ float lightPdf_0(float3  origin_3, float3  smooth_n_1, float3  start_5, uint j_0, float3  light_point_0)
{
    bool _S256 = j_0 == 4294967295U;
    if(_S256)
    {
        return 0.0f;
    }
    uint4  _S257 = (fcptLightTrail((j_0)));
    uint2  _S258 = uint2 {_S257.x, _S257.y};
    uint n_0 = 0U;
    uint2  trail_0 = _S258;
    float probability_1 = 1.0f;
    for(;;)
    {
        uint4  _S259 = (fcptLightNode((n_0)));
        if((_S259.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S260 = (fcptLightSecond((n_0)));
        uint _S261 = n_0 + 1U;
        LightNode _S262 = (fcptLightBounds((_S261)));
        LightNode _S263 = (fcptLightBounds((_S260)));
        uint _S264 = trail_0.x;
        uint _S265 = _S264 & 1U;
        float _S266 = childShare(_S262, _S263, origin_3, smooth_n_1, _S265);
        float probability_2 = probability_1 * _S266;
        bool _S267 = _S265 == 1U;
        uint _S268 = _slang_select(_S267, _S260,_S261);
        uint _S269 = trail_0.y;
        uint2  _S270 = make_uint2 ((_S264 >> 1U) | (_S269 << 31U), _S269 >> 1U);
        n_0 = _S268;
        trail_0 = _S270;
        probability_1 = probability_2;
    }
    bool _S271 = (fcptSlotLeaf((n_0), (j_0)));
    bool _S272 = !_S271;
    bool _S273;
    if(_S272)
    {
        _S273 = true;
    }
    else
    {
        LightNode _S274 = (fcptLightBounds((n_0)));
        float _S275 = importance(_S274, origin_3, smooth_n_1);
        _S273 = !(_S275 > 0.0f);
    }
    if(_S273)
    {
        _S273 = true;
    }
    else
    {
        bool _S276 = (dot_0(smooth_n_1, smooth_n_1)) > 0.0f;
        if(_S276)
        {
            _S273 = !((dot_0(smooth_n_1, light_point_0 - origin_3)) > 0.0f);
        }
        else
        {
            _S273 = false;
        }
    }
    if(_S273)
    {
        return 0.0f;
    }
    uint4  _S277 = (fcptLightNode((n_0)));
    bool _S278 = (_S277.x) == 2U;
    if(_S278)
    {
        uint _S279 = _S277.y;
        FKLight _S280 = (fcptLight((_S279)));
        FKLight _S281 = (fcptLight((_S279)));
        float _S282 = sphereDensity(_S280.position, _S281.variance, start_5);
        return probability_1 * _S282;
    }
    uint _S283 = _S277.y;
    uint _S284 = (fcptTriangleOffset((_S283)));
    Matrix<float, 3, 3>  _S285 = (fcptWorldTriangle((_S283), (_S284 + _S277.z)));
    float _S286 = solidAngle(probability_1, cross_0(_S285.rows[int(1)] - _S285.rows[int(0)], _S285.rows[int(2)] - _S285.rows[int(0)]), light_point_0 - start_5);
    return _S286;
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
    Random _S287;
    (&_S287)->state = state_0;
    (&_S287)->value = value_0;
    return _S287;
}

__device__ Random pcg(uint state_1)
{
    uint _S288 = hash(state_1);
    float value_1 = float(_S288 >> int(8)) * 5.9604644775390625e-08f;
    return Random_x24init_0(_S288, value_1);
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
    uint2  _S289 = (fcptEnvironmentCdfSize());
    uint2  _S290 = _S289 - make_uint2 (1U, 0U);
    float2  _S291 = make_float2 ((F32_atan2((- dir_2.y), (dir_2.x))) / 6.28318548202514648f + 0.5f, (F32_acos((clamp_1(dir_2.z, -1.0f, 1.0f)))) / 3.14159274101257324f);
    float2  _S292 = make_float2 ((float)_S290.x, (float)_S290.y);
    float2  _S293 = _S291 * _S292;
    uint2  _S294 = make_uint2 ((uint)_S293.x, (uint)_S293.y);
    uint2  _S295 = min_0(_S294, _S290 - make_uint2 (1U));
    float4  _S296 = (fcptEnvironmentCdf((_S295)));
    float _S297 = _S296.y;
    uint _S298 = _S290.x;
    float4  _S299 = (fcptEnvironmentCdf((make_uint2 (_S298, _S295.y))));
    float _S300 = _S297 * _S299.y;
    return _S300 * float(_S298 * _S290.y) / (19.73921012878417969f * length_1(float2 {dir_2.x, dir_2.y}));
}

static __device__ float3  negate_0(float3  x_13)
{
    return - x_13;
}

static __device__ float sign_0(float e_1)
{
    float _S301;
    if(e_1 > 0.0f)
    {
        _S301 = 1.0f;
    }
    else
    {
        if(e_1 < 0.0f)
        {
            _S301 = -1.0f;
        }
        else
        {
            _S301 = 0.0f;
        }
    }
    return _S301;
}

struct AnisotropicFrame
{
    float3  tangent;
    float2  alphas;
};

static __device__ AnisotropicFrame AnisotropicFrame_x24init_0(float3  tangent_0, float2  alphas_0)
{
    AnisotropicFrame _S302;
    (&_S302)->tangent = tangent_0;
    (&_S302)->alphas = alphas_0;
    return _S302;
}

__device__ float3  tangentToWorld(float3  v_0, float3  n_1)
{
    float3  a_1 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S303 = (F32_abs((dot_0(n_1, a_1)))) > 0.9999847412109375f;
    float3  a_2;
    if(_S303)
    {
        float3  _S304 = make_float3 (1.0f, 0.0f, 0.0f);
        a_2 = _S304;
    }
    else
    {
        a_2 = a_1;
    }
    float3  _S305 = cross_0(n_1, a_2);
    float3  _S306 = ((((_S305)) * make_float3(rnorm3df(((_S305)).x, ((_S305)).y, ((_S305)).z))));
    float3  _S307 = cross_0(n_1, _S306);
    return make_float3 (v_0.x) * _S306 + make_float3 (v_0.y) * n_1 + make_float3 (v_0.z) * _S307;
}

__device__ AnisotropicFrame anisotropicFrame(BSDFMaterial material_0, float3  n_i_0)
{
    float _S308 = material_0.roughness;
    float _S309 = _S308 * _S308;
    bool _S310 = (material_0.anisotropy) == 0.0f;
    bool _S311;
    if(_S310)
    {
        _S311 = true;
    }
    else
    {
        _S311 = !(_S309 > 0.0f);
    }
    if(_S311)
    {
        return AnisotropicFrame_x24init_0(make_float3 (0.0f), make_float2 (0.0f));
    }
    float3  _S312 = material_0.tangent - n_i_0 * make_float3 (dot_0(n_i_0, material_0.tangent));
    float3  _S313 = tangentToWorld(make_float3 (1.0f, 0.0f, 0.0f), n_i_0);
    bool _S314 = (dot_0(_S312, _S312)) > 0.0f;
    float3  _S315 = _slang_select(_S314, _S312,_S313);
    float3  _S316 = ((((_S315)) * make_float3(rnorm3df(((_S315)).x, ((_S315)).y, ((_S315)).z))));
    float _S317 = 6.28318548202514648f * material_0.anisotropic_rotation;
    float _S318 = (F32_sqrt((1.0f - 0.89999997615814209f * (F32_abs((material_0.anisotropy))))));
    float _S319 = 1.0f / _S318;
    bool _S320 = (material_0.anisotropy) < 0.0f;
    float _S321 = _slang_select(_S320, _S319,_S318);
    return AnisotropicFrame_x24init_0(_S316 * make_float3 ((F32_cos((_S317)))) + cross_0(n_i_0, _S316) * make_float3 ((F32_sin((_S317)))), make_float2 (_S309 / _S321, _S309 * _S321));
}

struct SheenProfile
{
    bool on;
    float albedo;
};

static __device__ SheenProfile SheenProfile_x24init_0(bool on_0, float albedo_0)
{
    SheenProfile _S322;
    (&_S322)->on = on_0;
    (&_S322)->albedo = albedo_0;
    return _S322;
}

__device__ float rgb_to_greyscale(float3  rgb_0)
{
    return dot_0(rgb_0, make_float3 (0.29899999499320984f, 0.58700001239776611f, 0.11400000005960464f));
}

__device__ static const FixedArray<float, 576>  VELVET_ALBEDO_0 = { {
    1.00383996963500977f, 1.00428998470306396f, 1.00356996059417725f, 1.00303995609283447f, 1.00261998176574707f, 1.00229001045227051f, 1.00198996067047119f, 1.00171005725860596f, 1.00144004821777344f, 1.00120997428894043f, 1.00102996826171875f, 1.00092005729675293f, 1.00088000297546387f, 1.0009000301361084f, 1.00095999240875244f, 1.00106000900268555f, 1.00115001201629639f, 1.00124001502990723f, 1.001289963722229f, 1.0013200044631958f, 1.00133001804351807f, 1.00133001804351807f, 1.0013200044631958f, 1.00129997730255127f, 0.99086397886276245f, 0.9934689998626709f, 0.99439799785614014f, 0.99513500928878784f, 0.99574202299118042f, 0.9962649941444397f, 0.99671798944473267f, 0.99709898233413696f, 0.997406005859375f, 0.99764800071716309f, 0.99783498048782349f, 0.99798601865768433f, 0.99811899662017822f, 0.99825501441955566f, 0.99840497970581055f, 0.99857097864151001f, 0.99874699115753174f, 0.99892902374267578f, 0.9990919828414917f, 0.99923902750015259f, 0.99936902523040771f, 0.99948000907897949f, 0.99957501888275146f, 0.99965798854827881f, 0.94088798761367798f, 0.95128101110458374f, 0.95866602659225464f, 0.96450901031494141f, 0.96921002864837646f, 0.973052978515625f, 0.97623497247695923f, 0.97890102863311768f, 0.98115700483322144f, 0.98308497667312622f, 0.98474901914596558f, 0.98619699478149414f, 0.98746699094772339f, 0.98858797550201416f, 0.98958402872085571f, 0.99047297239303589f, 0.99127000570297241f, 0.99198299646377563f, 0.99262100458145142f, 0.99318897724151611f, 0.99372398853302002f, 0.99426800012588501f, 0.99475300312042236f, 0.99514400959014893f, 0.86131101846694946f, 0.88463401794433594f, 0.90212702751159668f, 0.91595500707626343f, 0.92708200216293335f, 0.93617302179336548f, 0.94370102882385254f, 0.95000702142715454f, 0.95534700155258179f, 0.9599120020866394f, 0.96384698152542114f, 0.96726799011230469f, 0.97026199102401733f, 0.97289901971817017f, 0.97523599863052368f, 0.97731602191925049f, 0.97917401790618896f, 0.98083901405334473f, 0.98233497142791748f, 0.98368102312088013f, 0.98489302396774292f, 0.98598498106002808f, 0.98697298765182495f, 0.98787301778793335f, 0.75306302309036255f, 0.79328000545501709f, 0.82418698072433472f, 0.84881901741027832f, 0.86874997615814209f, 0.88506197929382324f, 0.89858502149581909f, 0.9099239706993103f, 0.91952997446060181f, 0.9277459979057312f, 0.93483197689056396f, 0.94099199771881104f, 0.9463840126991272f, 0.95113497972488403f, 0.95534402132034302f, 0.95908999443054199f, 0.9624369740486145f, 0.96543699502944946f, 0.96813201904296875f, 0.97055697441101074f, 0.97274202108383179f, 0.97471201419830322f, 0.97649002075195312f, 0.97809398174285889f, 0.62183499336242676f, 0.68052101135253906f, 0.72705197334289551f, 0.76452702283859253f, 0.79505598545074463f, 0.82021200656890869f, 0.84120297431945801f, 0.85885602235794067f, 0.87384098768234253f, 0.88667500019073486f, 0.89775800704956055f, 0.90739899873733521f, 0.91584599018096924f, 0.92329102754592896f, 0.929889976978302f, 0.93576502799987793f, 0.94101500511169434f, 0.94572198390960693f, 0.94994997978210449f, 0.95375597476959229f, 0.95718497037887573f, 0.9602770209312439f, 0.96306699514389038f, 0.96558600664138794f, 0.47742500901222229f, 0.5522189736366272f, 0.61415499448776245f, 0.66520899534225464f, 0.70744901895523071f, 0.74262100458145142f, 0.77213901281356812f, 0.7971159815788269f, 0.81841897964477539f, 0.83673000335693359f, 0.85258400440216064f, 0.86640900373458862f, 0.87854301929473877f, 0.88924998044967651f, 0.89874798059463501f, 0.90721100568771362f, 0.91477799415588379f, 0.92156499624252319f, 0.92766499519348145f, 0.93315702676773071f, 0.9381060004234314f, 0.94257098436355591f, 0.94660097360610962f, 0.95023900270462036f, 0.33539599180221558f, 0.41908100247383118f, 0.49247598648071289f, 0.55531197786331177f, 0.60879099369049072f, 0.65415602922439575f, 0.69274699687957764f, 0.72571200132369995f, 0.75402498245239258f, 0.77849102020263672f, 0.79976201057434082f, 0.81836599111557007f, 0.83474302291870117f, 0.84922301769256592f, 0.86208897829055786f, 0.87356698513031006f, 0.88384199142456055f, 0.89306402206420898f, 0.90135800838470459f, 0.9088289737701416f, 0.91556602716445923f, 0.92164498567581177f, 0.92713397741317749f, 0.93208998441696167f, 0.21194499731063843f, 0.29365798830986023f, 0.37110498547554016f, 0.44143900275230408f, 0.5036969780921936f, 0.55801302194595337f, 0.60521197319030762f, 0.64614301919937134f, 0.68169897794723511f, 0.71268302202224731f, 0.73979401588439941f, 0.76362699270248413f, 0.78467601537704468f, 0.80335497856140137f, 0.82000100612640381f, 0.83488202095031738f, 0.8482239842414856f, 0.86021500825881958f, 0.87101101875305176f, 0.88074499368667603f, 0.88952797651290894f, 0.89745801687240601f, 0.90461999177932739f, 0.91109001636505127f, 0.11949499696493149f, 0.18745699524879456f, 0.25997200608253479f, 0.33120998740196228f, 0.39773499965667725f, 0.45832300186157227f, 0.51248997449874878f, 0.56048798561096191f, 0.6028980016708374f, 0.64032697677612305f, 0.67339599132537842f, 0.70268499851226807f, 0.72870397567749023f, 0.75189602375030518f, 0.77263599634170532f, 0.7912449836730957f, 0.80796998739242554f, 0.82303100824356079f, 0.8366129994392395f, 0.84887397289276123f, 0.85994899272918701f, 0.86995697021484375f, 0.87900298833847046f, 0.88717901706695557f, 0.05942929908633232f, 0.10839699953794479f, 0.16785700619220734f, 0.23236599564552307f, 0.29767501354217529f, 0.36022999882698059f, 0.41842898726463318f, 0.47170799970626831f, 0.5198180079460144f, 0.56301301717758179f, 0.60171198844909668f, 0.63635998964309692f, 0.66739702224731445f, 0.69524997472763062f, 0.720287024974823f, 0.74283498525619507f, 0.76317602396011353f, 0.78155702352523804f, 0.79817098379135132f, 0.81319701671600342f, 0.8267899751663208f, 0.83908802270889282f, 0.85021400451660156f, 0.86027902364730835f, 0.02584660053253174f, 0.05619670078158379f, 0.09917669743299484f, 0.15162299573421478f, 0.20941600203514099f, 0.26902499794960022f, 0.32757499814033508f, 0.38318398594856262f, 0.43501600623130798f, 0.48271399736404419f, 0.52620798349380493f, 0.56570100784301758f, 0.60149699449539185f, 0.63392102718353271f, 0.66328197717666626f, 0.68988502025604248f, 0.7139970064163208f, 0.7358660101890564f, 0.75570398569107056f, 0.77369099855422974f, 0.78999698162078857f, 0.80477499961853027f, 0.81816202402114868f, 0.83028298616409302f, 0.00968609005212784f, 0.02591750025749207f, 0.05318830162286758f, 0.09121809899806976f, 0.13777700066566467f, 0.18976299464702606f, 0.244159996509552f, 0.29880800843238831f, 0.35169300436973572f, 0.40180501341819763f, 0.44872200489044189f, 0.49213200807571411f, 0.53206497430801392f, 0.5686650276184082f, 0.60214298963546753f, 0.63272500038146973f, 0.66062301397323608f, 0.68605399131774902f, 0.70922297239303589f, 0.73031198978424072f, 0.74948400259017944f, 0.76689702272415161f, 0.78270000219345093f, 0.79702901840209961f, 0.00303822988644242f, 0.01048239972442389f, 0.02568300068378448f, 0.05025380104780197f, 0.08408640325069427f, 0.12561400234699249f, 0.17249999940395355f, 0.22232000529766083f, 0.27309399843215942f, 0.32321798801422119f, 0.37149098515510559f, 0.4173240065574646f, 0.4603630006313324f, 0.50043797492980957f, 0.53755801916122437f, 0.57181298732757568f, 0.60333001613616943f, 0.63226902484893799f, 0.65877401828765869f, 0.68301999568939209f, 0.70514601469039917f, 0.7253040075302124f, 0.74363899230957031f, 0.76029098033905029f, 0.00076204299693927f, 0.00361976004205644f, 0.0110037000849843f, 0.02512970007956028f, 0.04727460071444511f, 0.07745999842882156f, 0.11460299789905548f, 0.1569570004940033f, 0.20258499681949615f, 0.24971699714660645f, 0.29707801342010498f, 0.34340900182723999f, 0.38799500465393066f, 0.43043500185012817f, 0.47039699554443359f, 0.50777101516723633f, 0.54253697395324707f, 0.57473397254943848f, 0.60444700717926025f, 0.63179397583007812f, 0.65686798095703125f, 0.67979699373245239f, 0.70071202516555786f, 0.71974599361419678f, 0.00014345299859997f, 0.00102306995540857f, 0.00407376000657678f, 0.01122699957340956f, 0.02423799969255924f, 0.04415180161595345f, 0.07109060138463974f, 0.10433399677276611f, 0.14259399473667145f, 0.184347003698349f, 0.2281080037355423f, 0.27265200018882751f, 0.31696400046348572f, 0.36016398668289185f, 0.40178799629211426f, 0.44139501452445984f, 0.47875601053237915f, 0.51375597715377808f, 0.54635101556777954f, 0.57658302783966064f, 0.60447400808334351f, 0.63009101152420044f, 0.65352898836135864f, 0.67488902807235718f, 0.00001858420000644f, 0.0002227969962405f, 0.00124967005103827f, 0.00435766018927097f, 0.01113030035048723f, 0.0229835007339716f, 0.04079980030655861f, 0.06477940082550049f, 0.09447769820690155f, 0.12897300720214844f, 0.16708999872207642f, 0.20760199427604675f, 0.24936899542808533f, 0.29154899716377258f, 0.3332040011882782f, 0.37377101182937622f, 0.41274300217628479f, 0.44977998733520508f, 0.4846780002117157f, 0.51733100414276123f, 0.54769200086593628f, 0.57572799921035767f, 0.6014779806137085f, 0.62501102685928345f, 1.46482000218384201e-06f, 0.00003429050047998f, 0.0002985020109918f, 0.00140504003502429f, 0.00443577999249101f, 0.01069260016083717f, 0.02133879996836185f, 0.0371410995721817f, 0.05836030095815659f, 0.08476380258798599f, 0.11572299897670746f, 0.1503559947013855f, 0.18766500055789948f, 0.22665500640869141f, 0.26647698879241943f, 0.30632400512695312f, 0.34550899267196655f, 0.38344401121139526f, 0.41970700025558472f, 0.45401400327682495f, 0.48618701100349426f, 0.51614201068878174f, 0.54384201765060425f, 0.56930899620056152f, 5.83937982412408019e-08f, 3.2765999549155822e-06f, 0.00005055400106357f, 0.00035111699253321f, 0.00145683996379375f, 0.00427943980321288f, 0.0098936902359128f, 0.01927389949560165f, 0.03310279920697212f, 0.05168719962239265f, 0.07495570182800293f, 0.10250899940729141f, 0.13370099663734436f, 0.1677280068397522f, 0.20372100174427032f, 0.24084299802780151f, 0.27840098738670349f, 0.31564199924468994f, 0.35190799832344055f, 0.38674798607826233f, 0.41985601186752319f, 0.45104199647903442f, 0.48021000623703003f, 0.50734001398086548f, 8.73966010672688753e-10f, 1.57741993689342053e-07f, 5.21975016454234719e-06f, 0.00006079579907237f, 0.00036219600588083f, 0.00138045998755842f, 0.00386844994500279f, 0.00871635042130947f, 0.01675550080835819f, 0.02860799990594387f, 0.04461279883980751f, 0.06480839848518372f, 0.08895269781351089f, 0.11656700074672699f, 0.1470009982585907f, 0.17950700223445892f, 0.21331800520420074f, 0.24785000085830688f, 0.28237700462341309f, 0.31631898880004883f, 0.34923198819160461f, 0.38083100318908691f, 0.41094100475311279f, 0.43946701288223267f, 2.8866399288257627e-12f, 2.63671995348602195e-09f, 2.51094007808205788e-07f, 5.97520011069718748e-06f, 0.00005859580051037f, 0.0003192939911969f, 0.00116373994387686f, 0.00319523992948234f, 0.00714873988181353f, 0.0137449000030756f, 0.0235638003796339f, 0.03696820139884949f, 0.05407309904694557f, 0.0747511014342308f, 0.09866459667682648f, 0.12531900405883789f, 0.15412400662899017f, 0.18446199595928192f, 0.21573600172996521f, 0.24741099774837494f, 0.27903899550437927f, 0.310263991355896f, 0.34082499146461487f, 0.37054198980331421f, 6.94488983838260476e-16f, 7.04290011727115584e-12f, 3.21448001550095341e-09f, 2.20180993437679717e-07f, 4.50593006462440826e-06f, 0.00004154839916737f, 0.00022262999846134f, 0.00081575999502093f, 0.00227530999109149f, 0.00519366981461644f, 0.01020010001957417f, 0.0178545992821455f, 0.02856850065290928f, 0.04256030172109604f, 0.05984469875693321f, 0.08025020360946655f, 0.10345599800348282f, 0.12904399633407593f, 0.15654699504375458f, 0.1854960024356842f, 0.21545499563217163f, 0.24603499472141266f, 0.27690801024436951f, 0.3078019917011261f, 5.46278023199234311e-22f, 3.43167987041791307e-16f, 2.29294990113093622e-12f, 9.57796952860689998e-10f, 6.87986982939037262e-08f, 1.5533599935224629e-06f, 0.00001600819996384f, 0.00009555240103509f, 0.00038631301140413f, 0.00117554003372788f, 0.00289549003355205f, 0.00607588002458215f, 0.01126710046082735f, 0.01896269991993904f, 0.02954130060970783f, 0.04323289915919304f, 0.06011129915714264f, 0.0801049992442131f, 0.10301999747753143f, 0.12857000529766083f, 0.15640300512313843f, 0.18612800538539886f, 0.21734000742435455f, 0.24963200092315674f, 0.0f, 0.0f, 3.09890004335006815e-24f, 2.21276004416278673e-18f, 2.67358004631774657e-14f, 2.24439997836833882e-11f, 3.13075010360819306e-09f, 1.26480998119404831e-07f, 2.12951999856159091e-06f, 0.00001907769910758f, 0.00010753999958979f, 0.00042892698547803f, 0.00131604995112866f, 0.00330013991333544f, 0.00707077002152801f, 0.01337909977883101f, 0.02291939966380596f, 0.03622379899024963f, 0.05359359830617905f, 0.07507230341434479f, 0.10045900195837021f, 0.12935000658035278f, 0.16119599342346191f, 0.19536399841308594f
} };
__device__ static const FixedArray<float, 576>  SHEEN_ALBEDO_0 = { {
    0.62089997529983521f, 0.49450001120567322f, 0.38080000877380371f, 0.28439998626708984f, 0.20010000467300415f, 0.1257999986410141f, 0.05990000069141388f, 0.00109999999403954f, -0.05160000175237656f, -0.09889999777078629f, -0.14159999787807465f, -0.18009999394416809f, -0.2151000052690506f, -0.24690000712871552f, -0.27590000629425049f, -0.30230000615119934f, -0.32649999856948853f, -0.34860000014305115f, -0.36890000104904175f, -0.38760000467300415f, -0.40479999780654907f, -0.42070001363754272f, -0.43439999222755432f, -0.44929999113082886f, 0.59240001440048218f, 0.47049999237060547f, 0.35899999737739563f, 0.26440000534057617f, 0.18150000274181366f, 0.10830000042915344f, 0.04329999908804893f, -0.01470000017434359f, -0.066600002348423f, -0.11339999735355377f, -0.15549999475479126f, -0.19370000064373016f, -0.22820000350475311f, -0.25970000028610229f, -0.28830000758171082f, -0.31450000405311584f, -0.33840000629425049f, -0.36039999127388f, -0.38049998879432678f, -0.39899998903274536f, -0.41609999537467957f, -0.43180000782012939f, -0.44539999961853027f, -0.46070000529289246f, 0.5228000283241272f, 0.40599998831748962f, 0.30259999632835388f, 0.21250000596046448f, 0.13330000638961792f, 0.06319999694824219f, 0.00069999997504056f, -0.05510000139474869f, -0.10520000010728836f, -0.15039999783039093f, -0.19120000302791595f, -0.2281000018119812f, -0.26170000433921814f, -0.2921999990940094f, -0.31999999284744263f, -0.34549999237060547f, -0.36869999766349792f, -0.39010000228881836f, -0.40970000624656677f, -0.42770001292228699f, -0.44440001249313354f, -0.45969998836517334f, -0.47389999032020569f, -0.48800000548362732f, 0.43569999933242798f, 0.32769998908042908f, 0.23160000145435333f, 0.14730000495910645f, 0.07280000299215317f, 0.00659999996423721f, -0.05260000005364418f, -0.10559999942779541f, -0.1534000039100647f, -0.19650000333786011f, -0.23549999296665192f, -0.27090001106262207f, -0.30309998989105225f, -0.33239999413490295f, -0.35920000076293945f, -0.38359999656677246f, -0.40599998831748962f, -0.42660000920295715f, -0.44549998641014099f, -0.46290001273155212f, -0.47900000214576721f, -0.49380001425743103f, -0.50749999284744263f, -0.52090001106262207f, 0.33129999041557312f, 0.23459999263286591f, 0.14740000665187836f, 0.07010000199079514f, 0.00139999995008111f, -0.0601000003516674f, -0.11519999802112579f, -0.16490000486373901f, -0.20970000326633453f, -0.25029999017715454f, -0.28720000386238098f, -0.3206000030040741f, -0.35109999775886536f, -0.37900000810623169f, -0.40439999103546143f, -0.42770001292228699f, -0.44900000095367432f, -0.46869999170303345f, -0.48669999837875366f, -0.5033000111579895f, -0.5187000036239624f, -0.53289997577667236f, -0.54600000381469727f, -0.55860000848770142f, 0.21109999716281891f, 0.12790000438690186f, 0.0511000007390976f, -0.01769999973475933f, -0.07970000058412552f, -0.13549999892711639f, -0.18600000441074371f, -0.23160000145435333f, -0.27300000190734863f, -0.31069999933242798f, -0.34490001201629639f, -0.37619999051094055f, -0.40470001101493835f, -0.43070000410079956f, -0.4546000063419342f, -0.476500004529953f, -0.49660000205039978f, -0.51510000228881836f, -0.53210002183914185f, -0.54780000448226929f, -0.56230002641677856f, -0.57580000162124634f, -0.58819997310638428f, -0.60009998083114624f, 0.0754999965429306f, 0.00800000037997961f, -0.05649999901652336f, -0.11569999903440475f, -0.16979999840259552f, -0.21920000016689301f, -0.26420000195503235f, -0.3052000105381012f, -0.34270000457763672f, -0.37689998745918274f, -0.40819999575614929f, -0.43680000305175781f, -0.46299999952316284f, -0.48710000514984131f, -0.50910001993179321f, -0.52939999103546143f, -0.54809999465942383f, -0.56529998779296875f, -0.5810999870300293f, -0.59570002555847168f, -0.60930001735687256f, -0.6218000054359436f, -0.63340002298355103f, -0.6445000171661377f, -0.07569999992847443f, -0.12489999830722809f, -0.17569999396800995f, -0.22380000352859497f, -0.26890000700950623f, -0.3107999861240387f, -0.34959998726844788f, -0.38539999723434448f, -0.41839998960494995f, -0.44870001077651978f, -0.47659999132156372f, -0.50230002403259277f, -0.52590000629425049f, -0.54759997129440308f, -0.56760001182556152f, -0.58600002527236938f, -0.6029999852180481f, -0.61870002746582031f, -0.63330000638961792f, -0.64670002460479736f, -0.6590999960899353f, -0.67059999704360962f, -0.68129998445510864f, -0.69160002470016479f, -0.24320000410079956f, -0.27120000123977661f, -0.30640000104904175f, -0.34209999442100525f, -0.37700000405311584f, -0.41060000658035278f, -0.44229999184608459f, -0.47220000624656677f, -0.50010001659393311f, -0.52600002288818359f, -0.55010002851486206f, -0.57239997386932373f, -0.59310001134872437f, -0.61220002174377441f, -0.62989997863769531f, -0.64620000123977661f, -0.66140002012252808f, -0.6754000186920166f, -0.68839997053146362f, -0.70039999485015869f, -0.71160000562667847f, -0.72200000286102295f, -0.73159998655319214f, -0.74089998006820679f, -0.42809998989105225f, -0.43149998784065247f, -0.44920000433921814f, -0.47099998593330383f, -0.49459999799728394f, -0.51880002021789551f, -0.54269999265670776f, -0.5658000111579895f, -0.58799999952316284f, -0.60900002717971802f, -0.62870001792907715f, -0.64730000495910645f, -0.6646999716758728f, -0.68080002069473267f, -0.69590002298355103f, -0.70999997854232788f, -0.72299998998641968f, -0.73509997129440308f, -0.74639999866485596f, -0.75690001249313354f, -0.76670002937316895f, -0.77579998970031738f, -0.78430002927780151f, -0.79250001907348633f, -0.63230001926422119f, -0.60759997367858887f, -0.60519999265670776f, -0.61119997501373291f, -0.62209999561309814f, -0.63580000400543213f, -0.65090000629425049f, -0.66659998893737793f, -0.68239998817443848f, -0.69789999723434448f, -0.71289998292922974f, -0.7271999716758728f, -0.74089998006820679f, -0.75379997491836548f, -0.76590001583099365f, -0.77740001678466797f, -0.78810000419616699f, -0.79809999465942383f, -0.80750000476837158f, -0.81629997491836548f, -0.82450002431869507f, -0.83209997415542603f, -0.83929997682571411f, -0.84630000591278076f, -0.85790002346038818f, -0.80119997262954712f, -0.77600002288818359f, -0.76410001516342163f, -0.76059997081756592f, -0.76239997148513794f, -0.76770001649856567f, -0.7750999927520752f, -0.78380000591278076f, -0.79309999942779541f, -0.80279999971389771f, -0.8125f, -0.82200002670288086f, -0.8312000036239624f, -0.8400999903678894f, -0.84859997034072876f, -0.85670000314712524f, -0.86440002918243408f, -0.8716999888420105f, -0.87849998474121094f, -0.88499999046325684f, -0.89099997282028198f, -0.89670002460479736f, -0.90240001678466797f, -1.10769999027252197f, -1.01429998874664307f, -0.96329998970031738f, -0.93110001087188721f, -0.91140002012252808f, -0.89990001916885376f, -0.89410001039505005f, -0.89219999313354492f, -0.89289999008178711f, -0.89539998769760132f, -0.89910000562667847f, -0.9035000205039978f, -0.90850001573562622f, -0.91360002756118774f, -0.9189000129699707f, -0.92419999837875366f, -0.92940002679824829f, -0.93440002202987671f, -0.93930000066757202f, -0.9440000057220459f, -0.94849997758865356f, -0.95270001888275146f, -0.95679998397827148f, -0.96100002527236938f, -1.38499999046325684f, -1.24950003623962402f, -1.16919994354248047f, -1.11409997940063477f, -1.07599997520446777f, -1.0494999885559082f, -1.03129994869232178f, -1.01880002021789551f, -1.01059997081756592f, -1.00539994239807129f, -1.00240004062652588f, -1.00109994411468506f, -1.0009000301361084f, -1.00150001049041748f, -1.00279998779296875f, -1.00440001487731934f, -1.00639998912811279f, -1.00849997997283936f, -1.01069998741149902f, -1.0130000114440918f, -1.01530003547668457f, -1.01750004291534424f, -1.01979994773864746f, -1.02230000495910645f, -1.69420003890991211f, -1.51020002365112305f, -1.39649999141693115f, -1.31540000438690186f, -1.2565000057220459f, -1.21309995651245117f, -1.18079996109008789f, -1.15649998188018799f, -1.13820004463195801f, -1.12440001964569092f, -1.11389994621276855f, -1.10599994659423828f, -1.10010004043579102f, -1.09560000896453857f, -1.09230005741119385f, -1.09000003337860107f, -1.08829998970031738f, -1.08710002899169922f, -1.08640003204345703f, -1.08599996566772461f, -1.08580005168914795f, -1.08580005168914795f, -1.08599996566772461f, -1.0866999626159668f, -2.04089999198913574f, -1.80079996585845947f, -1.64869999885559082f, -1.53789997100830078f, -1.45539999008178711f, -1.392799973487854f, -1.34459996223449707f, -1.30700004100799561f, -1.27730000019073486f, -1.25380003452301025f, -1.23489999771118164f, -1.21959996223449707f, -1.20720005035400391f, -1.19700002670288086f, -1.18859994411468506f, -1.18169999122619629f, -1.17589998245239258f, -1.17100000381469727f, -1.16690003871917725f, -1.16349995136260986f, -1.16059994697570801f, -1.15810000896453857f, -1.15600001811981201f, -1.15470004081726074f, -2.43269991874694824f, -2.12700009346008301f, -1.93060004711151123f, -1.78569996356964111f, -1.67610001564025879f, -1.59159994125366211f, -1.52530002593994141f, -1.47249996662139893f, -1.4299999475479126f, -1.39540004730224609f, -1.36689996719360352f, -1.3432999849319458f, -1.32350003719329834f, -1.30680000782012939f, -1.29270005226135254f, -1.28059995174407959f, -1.27009999752044678f, -1.26110005378723145f, -1.25329995155334473f, -1.24639999866485596f, -1.24039995670318604f, -1.23500001430511475f, -1.23029994964599609f, -1.22669994831085205f, -2.87989997863769531f, -2.49659991264343262f, -2.24860000610351562f, -2.06410002708435059f, -1.92330002784729004f, -1.8135000467300415f, -1.72640001773834229f, -1.65620005130767822f, -1.59899997711181641f, -1.55169999599456787f, -1.51230001449584961f, -1.47909998893737793f, -1.45099997520446777f, -1.42690002918243408f, -1.40610003471374512f, -1.3881000280380249f, -1.37240004539489746f, -1.35860002040863037f, -1.34640002250671387f, -1.33570003509521484f, -1.32609999179840088f, -1.31749999523162842f, -1.30980002880096436f, -1.30359995365142822f, -3.39750003814697266f, -2.92090010643005371f, -2.6119999885559082f, -2.38100004196166992f, -2.20359992980957031f, -2.0643000602722168f, -1.95290005207061768f, -1.86249995231628418f, -1.7882000207901001f, -1.72619998455047607f, -1.67410004138946533f, -1.62989997863769531f, -1.59200000762939453f, -1.55929994583129883f, -1.53090000152587891f, -1.50610005855560303f, -1.48430001735687256f, -1.46500003337860107f, -1.44790005683898926f, -1.43260002136230469f, -1.4189000129699707f, -1.40649998188018799f, -1.39540004730224609f, -1.38629996776580811f, -4.00810003280639648f, -3.41639995574951172f, -3.03419995307922363f, -2.74749994277954102f, -2.52649998664855957f, -2.35209989547729492f, -2.21210002899169922f, -2.09780001640319824f, -2.00309991836547852f, -1.92390000820159912f, -1.85679996013641357f, -1.7994999885559082f, -1.75020003318786621f, -1.70739996433258057f, -1.66999995708465576f, -1.6371999979019165f, -1.60819995403289795f, -1.58239996433258057f, -1.55949997901916504f, -1.53890001773834229f, -1.52040004730224609f, -1.50370001792907715f, -1.48860001564025879f, -1.47609996795654297f, -4.7491002082824707f, -4.00920009613037109f, -3.53640007972717285f, -3.18140006065368652f, -2.90700006484985352f, -2.69000005722045898f, -2.5150001049041748f, -2.37150001525878906f, -2.25230002403259277f, -2.15199995040893555f, -2.06680011749267578f, -1.99370002746582031f, -1.93060004711151123f, -1.87559998035430908f, -1.82739996910095215f, -1.78489995002746582f, -1.74730002880096436f, -1.71379995346069336f, -1.68389999866485596f, -1.65699994564056396f, -1.63279998302459717f, -1.6109999418258667f, -1.59109997749328613f, -1.5746999979019165f, -5.68760013580322266f, -4.74030017852783203f, -4.15259981155395508f, -3.71110010147094727f, -3.36949992179870605f, -3.09859991073608398f, -2.87960004806518555f, -2.69939994812011719f, -2.54920005798339844f, -2.42239999771118164f, -2.31439995765686035f, -2.22140002250671387f, -2.1408998966217041f, -2.07069993019104004f, -2.00900006294250488f, -1.95459997653961182f, -1.90629994869232178f, -1.86329996585845947f, -1.82480001449584961f, -1.79030001163482666f, -1.75919997692108154f, -1.73099994659423828f, -1.70550000667572021f, -1.68429994583129883f, -6.68940019607543945f, -5.34350013732910156f, -4.86259984970092773f, -4.34409999847412109f, -3.93390011787414551f, -3.60269999504089355f, -3.33100008964538574f, -3.10509991645812988f, -2.91510009765625f, -2.75390005111694336f, -2.61590003967285156f, -2.49690008163452148f, -2.3935999870300293f, -2.30340003967285156f, -2.22420001029968262f, -2.15440011024475098f, -2.09240007400512695f, -2.03730010986328125f, -1.98800003528594971f, -1.94369995594024658f, -1.90390002727508545f, -1.86790001392364502f, -1.83480000495910645f, -1.8078000545501709f, -9.69550037384033203f, -7.62489986419677734f, -6.61070013046264648f, -5.72329998016357422f, -5.04829978942871094f, -4.52129983901977539f, -4.10120010375976562f, -3.76049995422363281f, -3.48009991645812988f, -3.24640011787414551f, -3.04959988594055176f, -2.88229990005493164f, -2.738800048828125f, -2.61479997634887695f, -2.50699996948242188f, -2.41269993782043457f, -2.32960009574890137f, -2.25620007514953613f, -2.19090008735656738f, -2.13269996643066406f, -2.08049988746643066f, -2.03349995613098145f, -1.99049997329711914f, -1.95369994640350342f
} };
__device__ __forceinline__ SheenProfile sheenProfile(float3  v_1, float3  n_i_1, BSDFMaterial material_1)
{
    SheenProfile _S323 = SheenProfile_x24init_0(false, 0.0f);
    float _S324 = rgb_to_greyscale(material_1.sheen);
    bool _S325 = _S324 > 0.0f;
    SheenProfile profile_0;
    if(_S325)
    {
        float _S326 = clamp_1((F32_sqrt(((F32_max((dot_0(n_i_1, v_1)), (0.0f)))))), 0.0f, 1.0f) * 23.0f;
        uint _S327 = (U32_min((uint(_S326)), (22U)));
        float _S328 = (F32_sqrt((0.05000000074505806f)));
        float _S329 = (F32_sqrt((0.10000000149011612f)));
        bool _S330 = (material_1.velvet) > 0.0f;
        float _S331 = _slang_select(_S330, _S329,_S328);
        float _S332 = (clamp_1((F32_sqrt(((F32_max((material_1.sheen_roughness), (0.0f)))))), _S331, 1.0f) - _S331) / (1.0f - _S331) * 23.0f;
        uint _S333 = (U32_min((uint(_S332)), (22U)));
        uint _S334 = _S327 * 24U + _S333;
        float _S335 = _S326 - float(_S327);
        float _S336 = _S332 - float(_S333);
        if(_S330)
        {
            uint _S337 = _S334 + 24U;
            float _S338 = VELVET_ALBEDO_0[_S334] + (VELVET_ALBEDO_0[_S337] - VELVET_ALBEDO_0[_S334]) * _S335;
            uint _S339 = _S334 + 1U;
            float _S340 = VELVET_ALBEDO_0[_S339] + (VELVET_ALBEDO_0[_S337 + 1U] - VELVET_ALBEDO_0[_S339]) * _S335;
            SheenProfile _S341 = SheenProfile_x24init_0(true, _S338 + (_S340 - _S338) * _S336);
            profile_0 = _S341;
        }
        else
        {
            uint _S342 = _S334 + 24U;
            float _S343 = SHEEN_ALBEDO_0[_S334] + (SHEEN_ALBEDO_0[_S342] - SHEEN_ALBEDO_0[_S334]) * _S335;
            uint _S344 = _S334 + 1U;
            float _S345 = SHEEN_ALBEDO_0[_S344] + (SHEEN_ALBEDO_0[_S342 + 1U] - SHEEN_ALBEDO_0[_S344]) * _S335;
            SheenProfile _S346 = SheenProfile_x24init_0(true, (F32_exp((_S343 + (_S345 - _S343) * _S336))));
            profile_0 = _S346;
        }
    }
    else
    {
        profile_0 = _S323;
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
    BSDFLobes _S347;
    (&_S347)->v_dot_h = v_dot_h_0;
    (&_S347)->n_dot_h = n_dot_h_0;
    (&_S347)->refracted = refracted_1;
    (&_S347)->F = F_0;
    (&_S347)->F_greyscale = F_greyscale_0;
    (&_S347)->reflect_weight = reflect_weight_0;
    (&_S347)->diffuse_weight = diffuse_weight_0;
    (&_S347)->refract_weight = refract_weight_0;
    (&_S347)->p_diffuse = p_diffuse_0;
    (&_S347)->p_reflect = p_reflect_0;
    (&_S347)->p_refract = p_refract_0;
    (&_S347)->translucent_share = translucent_share_0;
    (&_S347)->sheen = sheen_0;
    (&_S347)->p_sheen_velvet = p_sheen_velvet_0;
    (&_S347)->view = view_0;
    (&_S347)->tangent = tangent_1;
    (&_S347)->alphas = alphas_1;
    (&_S347)->visible = visible_0;
    (&_S347)->p_toon = p_toon_0;
    (&_S347)->toon = toon_0;
    (&_S347)->toon_a = toon_a_0;
    (&_S347)->toon_s = toon_s_0;
    (&_S347)->toon_b = toon_b_0;
    (&_S347)->toon_glossy = toon_glossy_0;
    (&_S347)->toon_norm = toon_norm_0;
    (&_S347)->toon_view = toon_view_0;
    (&_S347)->toon_axis = toon_axis_0;
    return _S347;
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
    float3  _S348 = make_float3 (alpha_0 * Ve_0.x, alpha_0 * Ve_0.y, Ve_0.z);
    float3  _S349 = ((((_S348)) * make_float3(rnorm3df(((_S348)).x, ((_S348)).y, ((_S348)).z))));
    float _S350 = _S349.x;
    float _S351 = _S349.y;
    float _S352 = _S350 * _S350 + _S351 * _S351;
    float3  _S353;
    if(_S352 > 0.0f)
    {
        float3  _S354 = make_float3 (- _S351, _S350, 0.0f);
        float _S355 = (rsqrtf((_S352)));
        _S353 = _S354 * make_float3 (_S355);
    }
    else
    {
        _S353 = make_float3 (1.0f, 0.0f, 0.0f);
    }
    float3  _S356 = cross_0(_S349, _S353);
    float _S357 = (F32_sqrt((U1_0)));
    float _S358 = 6.28318548202514648f * U2_0;
    float _S359 = _S357 * (F32_cos((_S358)));
    float t2_0 = _S357 * (F32_sin((_S358)));
    float _S360 = 0.5f * (1.0f + _S349.z);
    float t2_1 = (1.0f - _S360) * (F32_sqrt(((F32_max((0.0f), (1.0f - _S359 * _S359)))))) + _S360 * t2_0;
    float3  _S361 = make_float3 (_S359) * _S353 + make_float3 (t2_1) * _S356;
    float _S362 = unshared_0(_S359);
    float _S363 = unshared_0(_S359);
    float3  _S364 = _S361 + make_float3 ((F32_sqrt(((F32_max((0.0f), (1.0f - _S362 * _S363 - t2_1 * t2_1))))))) * _S349;
    float3  _S365 = make_float3 (alpha_0 * _S364.x, alpha_0 * _S364.y, (F32_max((0.0f), (_S364.z))));
    float3  _S366 = ((((_S365)) * make_float3(rnorm3df(((_S365)).x, ((_S365)).y, ((_S365)).z))));
    return _S366;
}

__device__ float3  worldToTangent(float3  v_2, float3  n_3)
{
    float3  a_3 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S367 = (F32_abs((dot_0(n_3, a_3)))) > 0.9999847412109375f;
    float3  a_4;
    if(_S367)
    {
        float3  _S368 = make_float3 (1.0f, 0.0f, 0.0f);
        a_4 = _S368;
    }
    else
    {
        a_4 = a_3;
    }
    float3  _S369 = cross_0(n_3, a_4);
    float3  _S370 = ((((_S369)) * make_float3(rnorm3df(((_S369)).x, ((_S369)).y, ((_S369)).z))));
    float3  _S371 = cross_0(n_3, _S370);
    return make_float3 (dot_0(v_2, _S370), dot_0(v_2, n_3), dot_0(v_2, _S371));
}

__device__ __forceinline__ float3  sampleHalfVector(float3  v_3, float3  n_i_2, float alpha_1, AnisotropicFrame frame_0, uint * random_state_2)
{
    Random _S372 = pcg(*random_state_2);
    Random _S373 = pcg(_S372.state);
    *random_state_2 = _S373.state;
    float _S374 = frame_0.alphas.x;
    bool _S375 = _S374 > 0.0f;
    if(_S375)
    {
        float3  _S376 = anisotropicLocal(v_3, frame_0.tangent, n_i_2);
        float _S377 = frame_0.alphas.y;
        float3  _S378 = make_float3 (_S374 * _S376.x, _S377 * _S376.y, _S376.z);
        float3  _S379 = ((((_S378)) * make_float3(rnorm3df(((_S378)).x, ((_S378)).y, ((_S378)).z))));
        float3  _S380 = sampleGGXVNDF(_S379, 1.0f, _S372.value, _S373.value);
        float3  _S381 = make_float3 (_S374 * _S380.x, _S377 * _S380.y, _S380.z);
        float3  _S382 = ((((_S381)) * make_float3(rnorm3df(((_S381)).x, ((_S381)).y, ((_S381)).z))));
        return make_float3 (_S382.x) * frame_0.tangent + make_float3 (_S382.y) * cross_0(n_i_2, frame_0.tangent) + make_float3 (_S382.z) * n_i_2;
    }
    float3  _S383 = worldToTangent(v_3, n_i_2);
    float3  _S384 = sampleGGXVNDF(float3 {_S383.x, _S383.z, _S383.y}, alpha_1, _S372.value, _S373.value);
    float3  _S385 = float3 {_S384.x, _S384.z, _S384.y};
    float3  _S386 = tangentToWorld(_S385, n_i_2);
    return _S386;
}

__device__ float3  sampledHalf(float3  in_dir_0, float3  n_4, BSDFMaterial material_2, uint random_state_3, AnisotropicFrame frame_1)
{
    uint state_2 = random_state_3;
    float3  _S387 = negate_0(in_dir_0);
    float _S388 = sign_0(dot_0(n_4, _S387));
    float _S389 = material_2.roughness;
    float3  _S390 = sampleHalfVector(_S387, n_4 * make_float3 (_S388), _S389 * _S389, frame_1, &state_2);
    return _S390;
}

__device__ float3  refractedHalf(float3  in_dir_1, float3  out_dir_0, float3  n_5, float eta_i_0, float eta_o_0)
{
    float3  _S391 = negate_0(in_dir_1);
    float3  _S392 = negate_0(make_float3 (eta_i_0) * _S391 + make_float3 (eta_o_0) * out_dir_0);
    float3  _S393 = ((((_S392)) * make_float3(rnorm3df(((_S392)).x, ((_S392)).y, ((_S392)).z))));
    float _S394 = sign_0(dot_0(n_5, _S391));
    float _S395 = sign_0(dot_0(_S392, n_5 * make_float3 (_S394)));
    return _S393 * make_float3 (_S395);
}

__device__ float3  reflectedHalf(float3  in_dir_2, float3  out_dir_1)
{
    float3  _S396 = negate_0(in_dir_2);
    float3  _S397 = _S396 + out_dir_1;
    float3  _S398 = ((((_S397)) * make_float3(rnorm3df(((_S397)).x, ((_S397)).y, ((_S397)).z))));
    return _S398;
}

static __device__ float3  refract_0(float3  i_5, float3  n_6, float eta_0)
{
    float _S399 = dot_0(n_6, i_5);
    float _S400 = 1.0f - eta_0 * eta_0 * (1.0f - _S399 * _S399);
    if(_S400 < 0.0f)
    {
        return make_float3 (0.0f);
    }
    return make_float3 (eta_0) * i_5 - make_float3 (eta_0 * _S399 + (F32_sqrt((_S400)))) * n_6;
}

__device__ float fresnel(float cos_theta_0, float eta_i_1, float eta_o_1)
{
    float _S401 = (F32_sqrt(((F32_max((0.0f), (1.0f - cos_theta_0 * cos_theta_0))))));
    float _S402 = eta_i_1 / eta_o_1 * _S401;
    bool _S403 = _S402 < 1.0f;
    float kr_0;
    if(_S403)
    {
        float _S404 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S402 * _S402))))));
        bool _S405 = eta_i_1 == eta_o_1;
        float _S406 = _slang_select(_S405, cos_theta_0,_S404);
        float _S407 = eta_o_1 * cos_theta_0;
        float _S408 = eta_i_1 * _S406;
        float _S409 = (_S407 - _S408) / (_S407 + _S408);
        float _S410 = eta_i_1 * cos_theta_0;
        float _S411 = eta_o_1 * _S406;
        float _S412 = (_S410 - _S411) / (_S410 + _S411);
        float _S413 = (_S409 * _S409 + _S412 * _S412) / 2.0f;
        kr_0 = _S413;
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
    float _S414 = (F32_max((w_1.z), (0.0f)));
    return 2.0f * _S414 / (_S414 + length_0(make_float3 (alphas_2.x * w_1.x, alphas_2.y * w_1.y, _S414)));
}

__device__ float anisotropicD(float3  h_0, float2  alphas_3)
{
    float _S415 = alphas_3.x;
    float _S416 = h_0.x / _S415;
    float _S417 = alphas_3.y;
    float _S418 = h_0.y / _S417;
    float _S419 = h_0.z;
    float _S420 = _S416 * _S416 + _S418 * _S418 + _S419 * _S419;
    return 1.0f / (F32_max((3.14159274101257324f * _S415 * _S417 * _S420 * _S420), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ BSDFLobes bsdfLobes(float3  in_dir_3, float3  v_4, float3  n_i_3, float3  ggx_n_0, BSDFMaterial material_3, float eta_i_2, float eta_o_2, AnisotropicFrame frame_2, SheenProfile sheen_profile_0)
{
    float _S421 = dot_0(ggx_n_0, v_4);
    float _S422 = dot_0(n_i_3, ggx_n_0);
    float _S423 = eta_i_2 / eta_o_2;
    float3  _S424 = refract_0(in_dir_3, ggx_n_0, _S423);
    float3  _S425 = ((((_S424)) * make_float3(rnorm3df(((_S424)).x, ((_S424)).y, ((_S424)).z))));
    float _S426 = (F32_min(((F32_sqrt((material_3.specular_level))) * (F32_abs((eta_i_2 - eta_o_2))) / (eta_i_2 + eta_o_2)), (0.9999847412109375f)));
    float _S427 = _S426 * _S426;
    float _S428 = (1.0f + _S426) / (1.0f - _S426);
    float _S429 = (F32_abs((_S421)));
    bool _S430 = eta_i_2 > eta_o_2;
    float sheen_component_0;
    if(_S430)
    {
        sheen_component_0 = _S428;
    }
    else
    {
        sheen_component_0 = 1.0f;
    }
    float toon_component_0;
    if(_S430)
    {
        toon_component_0 = 1.0f;
    }
    else
    {
        toon_component_0 = _S428;
    }
    float _S431 = fresnel(_S429, sheen_component_0, toon_component_0);
    bool _S432 = (eta_i_2 * eta_i_2 * (1.0f - _S421 * _S421)) >= (eta_o_2 * eta_o_2);
    float3  _S433;
    if(_S432)
    {
        _S433 = make_float3 (1.0f);
    }
    else
    {
        float3  _S434 = material_3.specular_tint * make_float3 (_S427);
        _S433 = _S434 + (make_float3 (1.0f) - _S434) * make_float3 (_S431 - _S427) / make_float3 (1.0f - _S427);
    }
    float3  _S435 = make_float3 (1.0f);
    float3  _S436 = make_float3 (0.0f);
    float3  sheen_1;
    float3  view_1;
    float3  scale_1;
    if(sheen_profile_0.on)
    {
        float _S437 = (F32_min((sheen_profile_0.albedo), (1.0f)));
        float3  _S438 = make_float3 (1.0f) - material_3.sheen * make_float3 (_S437);
        float _S439 = rgb_to_greyscale(material_3.sheen);
        float _S440 = _S439 * _S437;
        float3  _S441 = material_3.sheen / make_float3 ((F32_max((sheen_profile_0.albedo), (1.0f))));
        sheen_component_0 = _S440;
        sheen_1 = _S441;
        view_1 = v_4;
        scale_1 = _S438;
    }
    else
    {
        sheen_component_0 = 0.0f;
        sheen_1 = _S436;
        view_1 = _S436;
        scale_1 = _S435;
    }
    float _S442 = material_3.toon.x;
    bool _S443 = _S442 < 0.0f;
    float _S444 = (F32_abs((_S442)));
    bool _S445 = _S444 > 0.0f;
    float toon_a_1;
    float toon_s_1;
    float toon_b_1;
    float toon_norm_1;
    float toon_view_1;
    float3  toon_1;
    float3  toon_axis_1;
    bool _S446;
    if(_S445)
    {
        float _S447 = (F32_min((_S444), (1.0f)));
        float3  scale_2 = scale_1 * make_float3 (1.0f - _S447);
        float _S448 = rgb_to_greyscale(material_3.albedo);
        float _S449 = _S447 * _S448;
        float3  _S450 = make_float3 (_S447) * material_3.albedo;
        float toon_a_2 = clamp_1(material_3.toon.y / _S442, 0.00000999999974738f, 1.0f) * 3.14159274101257324f / 2.0f;
        float toon_s_2 = clamp_1(material_3.toon.z / _S442, 0.0f, 1.0f) * 3.14159274101257324f / 2.0f;
        float _S451 = (F32_min((toon_a_2 + toon_s_2), (1.57079637050628662f)));
        if(_S443)
        {
            toon_component_0 = 1.0f - (F32_cos(((F32_min((_S451), (toon_a_2))))));
        }
        else
        {
            float _S452 = (F32_sin(((F32_min((_S451), (toon_a_2))))));
            toon_component_0 = _S452 * _S452 / 2.0f;
        }
        bool _S453 = _S451 > toon_a_2;
        if(_S453)
        {
            _S446 = toon_s_2 > 0.0f;
        }
        else
        {
            _S446 = false;
        }
        if(_S446)
        {
            if(_S443)
            {
                float _S454 = (F32_cos((toon_a_2)));
                float _S455 = (F32_cos((_S451)));
                toon_a_1 = (1.0f + toon_a_2 / toon_s_2) * (_S454 - _S455) - ((F32_sin((_S451))) - _S451 * _S455 - ((F32_sin((toon_a_2))) - toon_a_2 * _S454)) / toon_s_2;
            }
            else
            {
                float _S456 = 2.0f * toon_a_2;
                float _S457 = (F32_cos((_S456)));
                float _S458 = 2.0f * _S451;
                float _S459 = (F32_cos((_S458)));
                toon_a_1 = (1.0f + toon_a_2 / toon_s_2) * (_S457 - _S459) / 4.0f - ((F32_sin((_S458))) / 8.0f - _S451 * _S459 / 4.0f - ((F32_sin((_S456))) / 8.0f - toon_a_2 * _S457 / 4.0f)) / toon_s_2;
            }
            float integral_0 = toon_component_0 + toon_a_1;
            toon_component_0 = integral_0;
        }
        float _S460 = 6.28318548202514648f * toon_component_0;
        float _S461 = dot_0(n_i_3, v_4);
        float _S462 = (F32_acos(((F32_min((_S461), (1.0f))))));
        if(_S462 < toon_a_2)
        {
            toon_component_0 = 1.0f;
        }
        else
        {
            toon_component_0 = (F32_max((1.0f - (_S462 - toon_a_2) / (F32_max((toon_s_2), (0.0000152587890625f)))), (0.0f)));
        }
        if(_S443)
        {
            float3  _S463 = make_float3 (2.0f * _S461) * n_i_3 - v_4;
            float3  _S464 = ((((_S463)) * make_float3(rnorm3df(((_S463)).x, ((_S463)).y, ((_S463)).z))));
            scale_1 = _S464;
        }
        else
        {
            scale_1 = n_i_3;
        }
        float _S465 = toon_component_0;
        toon_component_0 = _S449;
        toon_1 = _S450;
        toon_a_1 = toon_a_2;
        toon_s_1 = toon_s_2;
        toon_b_1 = _S451;
        toon_norm_1 = _S460;
        toon_view_1 = _S465;
        toon_axis_1 = scale_1;
        scale_1 = scale_2;
    }
    else
    {
        toon_component_0 = 0.0f;
        toon_1 = _S436;
        toon_a_1 = 0.0f;
        toon_s_1 = 0.0f;
        toon_b_1 = 0.0f;
        toon_norm_1 = 1.0f;
        toon_view_1 = 0.0f;
        toon_axis_1 = n_i_3;
    }
    float3  _S466 = mix_0(_S433, material_3.albedo, material_3.metallic);
    float3  F_1 = _S466 * scale_1;
    float _S467 = rgb_to_greyscale(F_1);
    float _S468 = 1.0f - material_3.metallic;
    float3  _S469 = make_float3 (1.0f) - _S433;
    float3  _S470 = make_float3 ((1.0f - material_3.transmission) * _S468) * _S469 * scale_1;
    float3  _S471 = make_float3 (material_3.transmission * _S468) * _S469 * scale_1;
    float _S472 = (F32_max((_S467), (0.0f)));
    float _S473 = rgb_to_greyscale(_S470);
    float _S474 = (F32_max((_S473), (0.0f)));
    float _S475 = rgb_to_greyscale(_S471);
    float _S476 = sign_0(length_0(_S425));
    float _S477 = (F32_max((_S475 * _S476), (0.0f)));
    float _S478 = _S472 + _S474 + _S477 + toon_component_0;
    float _S479 = (F32_min((sheen_component_0), (1.0f)));
    bool _S480 = sheen_component_0 > 0.0f;
    if(_S480)
    {
        _S446 = !(_S478 > 0.0f);
    }
    else
    {
        _S446 = false;
    }
    float _S481 = _slang_select(_S446, 1.0f,_S479);
    float _S482 = (1.0f - _S481) / (F32_max((_S478), (0.0000152587890625f)));
    float _S483 = _S474 * _S482;
    float _S484 = _S472 * _S482;
    float _S485 = _S477 * _S482;
    bool _S486 = (frame_2.alphas.x) > 0.0f;
    float visible_1;
    if(_S486)
    {
        float3  _S487 = anisotropicLocal(v_4, frame_2.tangent, n_i_3);
        float _S488 = anisotropicG1(_S487, frame_2.alphas);
        float3  _S489 = anisotropicLocal(ggx_n_0, frame_2.tangent, n_i_3);
        float _S490 = anisotropicD(_S489, frame_2.alphas);
        float _S491 = _S488 * _S490;
        visible_1 = _S491;
    }
    else
    {
        visible_1 = 0.0f;
    }
    return BSDFLobes_x24init_0(_S421, _S422, _S425, F_1, _S467, 1.0f, _S470, _S471, _S483, _S484, _S485, 0.0f, sheen_1, _S481, view_1, frame_2.tangent, frame_2.alphas, visible_1, toon_component_0 * _S482, toon_1, toon_a_1, toon_s_1, toon_b_1, _S443, toon_norm_1, toon_view_1, toon_axis_1);
}

__device__ float translucentShare(BSDFMaterial material_4)
{
    float _S492 = rgb_to_greyscale(material_4.translucent);
    float _S493 = rgb_to_greyscale(material_4.albedo);
    float _S494 = _S492 / (_S493 + _S492);
    bool _S495 = _S492 > 0.0f;
    float _S496 = _slang_select(_S495, _S494,0.0f);
    return _S496;
}

__device__ __forceinline__ float diffusePDF(float n_i_dot_l_0, float l_dot_h_0, float n_i_dot_v_0, float alpha_2, BSDFLobes lobes_0, float eta_i_3, float eta_o_3)
{
    float _S497 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    float _S498 = lobes_0.p_diffuse * (F32_abs((n_i_dot_l_0))) * 0.31830987334251404f;
    float _S499 = 1.0f - lobes_0.translucent_share;
    bool _S500 = n_i_dot_l_0 < 0.0f;
    float _S501 = _slang_select(_S500, lobes_0.translucent_share,_S499);
    float _S502 = _S498 * _S501;
    bool _S503 = (lobes_0.translucent_share) > 0.0f;
    float _S504 = _slang_select(_S503, _S502,_S497);
    bool _S505 = n_i_dot_v_0 > 0.0f;
    float _S506 = _slang_select(_S505, _S504,0.0f);
    return _S506;
}

__device__ __forceinline__ float3  diffuseBSDF(float3  l_0, float3  n_i_4, float alpha_3, BSDFMaterial material_5, BSDFLobes lobes_1)
{
    bool _S507 = (dot_0(n_i_4, l_0)) < 0.0f;
    float3  _S508 = _slang_select(_S507, material_5.translucent,material_5.albedo);
    float _S509 = 1.0f - lobes_1.translucent_share;
    float _S510 = _slang_select(_S507, lobes_1.translucent_share,_S509);
    float3  _S511 = _S508 / make_float3 (_S510);
    bool _S512 = (lobes_1.translucent_share) > 0.0f;
    float3  _S513 = _slang_select(_S512, _S511,material_5.albedo);
    return lobes_1.diffuse_weight * _S513 / make_float3 (lobes_1.p_diffuse);
}

__device__ float smithG1(float alpha_4, float n_dot_x_0)
{
    float _S514 = alpha_4 * alpha_4;
    float _S515 = 2.0f * n_dot_x_0 / (n_dot_x_0 + (F32_sqrt((_S514 + (1.0f - _S514) * n_dot_x_0 * n_dot_x_0))));
    bool _S516 = alpha_4 > 0.0f;
    float _S517 = _slang_select(_S516, _S515,1.0f);
    return _S517;
}

__device__ float trowbridgeReitz(float alpha_5, float n_dot_h_1)
{
    float _S518 = alpha_5 * alpha_5;
    float _S519 = (1.0f - n_dot_h_1) * (1.0f + n_dot_h_1) + _S518 * n_dot_h_1 * n_dot_h_1;
    return _S518 / (F32_max((3.14159274101257324f * _S519 * _S519), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ float vndfPDF(float n_i_dot_v_1, float alpha_6, BSDFLobes lobes_2)
{
    float _S520 = smithG1(alpha_6, n_i_dot_v_1);
    float _S521 = _S520 * lobes_2.v_dot_h;
    float _S522 = trowbridgeReitz(alpha_6, lobes_2.n_dot_h);
    float _S523 = _S521 * _S522 / n_i_dot_v_1;
    bool _S524 = alpha_6 > 0.0f;
    bool _S525;
    if(_S524)
    {
        _S525 = (lobes_2.v_dot_h) > 0.0f;
    }
    else
    {
        _S525 = false;
    }
    if(_S525)
    {
        _S525 = (lobes_2.n_dot_h) > 0.0f;
    }
    else
    {
        _S525 = false;
    }
    if(_S525)
    {
        _S525 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S525 = false;
    }
    float _S526 = _slang_select(_S525, _S523,0.0f);
    bool _S527 = (lobes_2.alphas.x) > 0.0f;
    float pdf_h_0;
    if(_S527)
    {
        float _S528 = lobes_2.visible * lobes_2.v_dot_h / n_i_dot_v_1;
        bool _S529 = (lobes_2.v_dot_h) > 0.0f;
        if(_S529)
        {
            _S525 = (lobes_2.n_dot_h) > 0.0f;
        }
        else
        {
            _S525 = false;
        }
        if(_S525)
        {
            _S525 = n_i_dot_v_1 > 0.0f;
        }
        else
        {
            _S525 = false;
        }
        float _S530 = _slang_select(_S525, _S528,0.0f);
        pdf_h_0 = _S530;
    }
    else
    {
        pdf_h_0 = _S526;
    }
    return pdf_h_0;
}

__device__ __forceinline__ float refractPDF(float n_i_dot_l_1, float l_dot_h_1, float n_i_dot_v_2, float alpha_7, BSDFLobes lobes_3, float eta_i_4, float eta_o_4)
{
    float _S531 = vndfPDF(n_i_dot_v_2, alpha_7, lobes_3);
    float _S532 = eta_i_4 * lobes_3.v_dot_h + eta_o_4 * l_dot_h_1;
    float _S533 = lobes_3.p_refract * _S531 * eta_o_4 * eta_o_4 * (F32_abs((l_dot_h_1))) / (_S532 * _S532);
    bool _S534 = eta_i_4 != eta_o_4;
    bool _S535;
    if(_S534)
    {
        _S535 = l_dot_h_1 < 0.0f;
    }
    else
    {
        _S535 = false;
    }
    float _S536 = _slang_select(_S535, _S533,0.0f);
    return _S536;
}

__device__ __forceinline__ float3  refractBSDF(float3  l_1, float3  n_i_5, float alpha_8, BSDFMaterial material_6, BSDFLobes lobes_4)
{
    float _S537 = - dot_0(n_i_5, l_1);
    float _S538 = smithG1(alpha_8, (F32_max((_S537), (0.0f))));
    bool _S539 = (lobes_4.alphas.x) > 0.0f;
    float G1_l_0;
    if(_S539)
    {
        float3  _S540 = negate_0(n_i_5);
        float3  _S541 = anisotropicLocal(l_1, lobes_4.tangent, _S540);
        float _S542 = anisotropicG1(_S541, lobes_4.alphas);
        G1_l_0 = _S542;
    }
    else
    {
        G1_l_0 = _S538;
    }
    return lobes_4.refract_weight * make_float3 (G1_l_0) * material_6.albedo / make_float3 (lobes_4.p_refract);
}

__device__ __forceinline__ float sheenVelvetPDF(float n_i_dot_l_2, float l_dot_h_2, float n_i_dot_v_3, float alpha_9, BSDFLobes lobes_5, float eta_i_5, float eta_o_5)
{
    float _S543 = lobes_5.p_sheen_velvet * 0.5f * 0.31830987334251404f;
    bool _S544 = n_i_dot_l_2 > 0.0f;
    bool _S545;
    if(_S544)
    {
        _S545 = n_i_dot_v_3 > 0.0f;
    }
    else
    {
        _S545 = false;
    }
    float _S546 = _slang_select(_S545, _S543,0.0f);
    return _S546;
}

__device__ __forceinline__ float3  sheenVelvetBSDF(float3  l_2, float3  n_i_6, float alpha_10, BSDFMaterial material_7, BSDFLobes lobes_6)
{
    float3  _S547 = l_2 + lobes_6.view;
    float3  _S548 = ((((_S547)) * make_float3(rnorm3df(((_S547)).x, ((_S547)).y, ((_S547)).z))));
    float _S549 = dot_0(n_i_6, _S548);
    float _S550 = (F32_max((dot_0(n_i_6, l_2)), (0.0f)));
    float _S551 = (F32_max((dot_0(n_i_6, lobes_6.view)), (0.0f)));
    float _S552 = 1.0f / (F32_max((material_7.sheen_roughness), (0.05000000074505806f)));
    float _S553 = 1.0f - _S549 * _S549;
    float _S554 = (2.0f + _S552) * (F32_pow(((F32_max((_S553), (0.0f)))), (0.5f * _S552))) * 0.5f * 0.31830987334251404f / (F32_max((4.0f * (_S550 + _S551 - _S550 * _S551)), (0.0000152587890625f)));
    bool _S555 = (material_7.velvet) > 0.0f;
    float f_1;
    if(_S555)
    {
        float _S556 = (F32_max((material_7.sheen_roughness), (0.00999999977648258f)));
        float _S557 = _S556 * _S556;
        float _S558 = (F32_max((_S553), (0.0000152587890625f)));
        float _S559 = (F32_exp((- _S549 * _S549 / (_S558 * _S557)))) / (3.14159274101257324f * _S557 * _S558 * _S558) * (F32_min((1.0f), (2.0f * _S549 * (F32_min((_S550), (_S551))) / (F32_max(((F32_abs((dot_0(_S548, lobes_6.view))))), (0.0000152587890625f)))))) / (F32_max((4.0f * _S550 * _S551), (0.0000152587890625f)));
        f_1 = _S559;
    }
    else
    {
        f_1 = _S554;
    }
    return lobes_6.sheen * make_float3 (f_1 * _S550 * 2.0f * 3.14159274101257324f / lobes_6.p_sheen_velvet);
}

__device__ __forceinline__ float toonPDF(float n_i_dot_l_3, float l_dot_h_3, float n_i_dot_v_4, float alpha_11, BSDFLobes lobes_7, float eta_i_6, float eta_o_6)
{
    float _S560 = _slang_select(lobes_7.toon_glossy, l_dot_h_3,n_i_dot_l_3);
    float _S561 = (F32_acos((clamp_1(_S560, -1.0f, 1.0f))));
    float _S562;
    if(_S561 < (lobes_7.toon_a))
    {
        _S562 = 1.0f;
    }
    else
    {
        _S562 = (F32_max((1.0f - (_S561 - lobes_7.toon_a) / (F32_max((lobes_7.toon_s), (0.0000152587890625f)))), (0.0f)));
    }
    float _S563 = lobes_7.p_toon * _S562;
    float _S564 = _slang_select(lobes_7.toon_glossy, 1.0f,n_i_dot_l_3);
    float _S565 = _S563 * _S564 / lobes_7.toon_norm;
    bool _S566;
    if(lobes_7.toon_glossy)
    {
        _S566 = true;
    }
    else
    {
        _S566 = n_i_dot_l_3 > 0.0f;
    }
    float _S567 = _slang_select(_S566, _S565,0.0f);
    return _S567;
}

__device__ __forceinline__ float3  toonBSDF(float3  l_3, float3  n_i_7, float alpha_12, BSDFMaterial material_8, BSDFLobes lobes_8)
{
    float _S568 = (F32_max((dot_0(n_i_7, l_3)), (0.0f)));
    float _S569 = _slang_select(lobes_8.toon_glossy, _S568,lobes_8.toon_view);
    return lobes_8.toon * make_float3 (_S569) / make_float3 (lobes_8.p_toon);
}

__device__ __forceinline__ float reflectPDF(float n_i_dot_l_4, float l_dot_h_4, float n_i_dot_v_5, float alpha_13, BSDFLobes lobes_9, float eta_i_7, float eta_o_7)
{
    float _S570 = vndfPDF(n_i_dot_v_5, alpha_13, lobes_9);
    float _S571 = lobes_9.p_reflect * _S570 / (4.0f * lobes_9.v_dot_h);
    bool _S572 = _S570 > 0.0f;
    float _S573 = _slang_select(_S572, _S571,0.0f);
    return _S573;
}

__device__ __forceinline__ float3  reflectBSDF(float3  l_4, float3  n_i_8, float alpha_14, BSDFMaterial material_9, BSDFLobes lobes_10)
{
    float _S574 = dot_0(n_i_8, l_4);
    float _S575 = smithG1(alpha_14, (F32_max((_S574), (0.0f))));
    bool _S576 = (lobes_10.alphas.x) > 0.0f;
    float G1_l_1;
    if(_S576)
    {
        float3  _S577 = anisotropicLocal(l_4, lobes_10.tangent, n_i_8);
        float _S578 = anisotropicG1(_S577, lobes_10.alphas);
        G1_l_1 = _S578;
    }
    else
    {
        G1_l_1 = _S575;
    }
    return make_float3 (lobes_10.reflect_weight * G1_l_1) * lobes_10.F / make_float3 (lobes_10.p_reflect);
}

__device__ __forceinline__ float3  BSDF(float3  in_dir_4, float3  out_dir_2, float3  n_7, BSDFMaterial material_10, float eta_i_8, float eta_o_8, bool refracted_2, uint random_state_4, FixedArray<float3 , 5>  * throughputs_0, FixedArray<float, 5>  * pdfs_0)
{
    float3  ggx_n_1;
    float3  _S579 = negate_0(in_dir_4);
    float _S580 = dot_0(n_7, _S579);
    float _S581 = sign_0(_S580);
    float3  _S582 = n_7 * make_float3 (_S581);
    AnisotropicFrame _S583 = anisotropicFrame(material_10, _S582);
    float _S584 = dot_0(_S582, out_dir_2);
    float _S585 = material_10.roughness;
    float _S586 = _S585 * _S585;
    SheenProfile _S587 = sheenProfile(_S579, _S582, material_10);
    float _S588 = rgb_to_greyscale(material_10.translucent);
    bool _S589 = _S588 > 0.0f;
    bool _S590 = (dot_0(n_7, out_dir_2) * _S580) < 0.0f;
    uint _S591;
    if((F32_abs((material_10.toon.x))) > 0.0f)
    {
        _S591 = 5U;
    }
    else
    {
        _S591 = 4U;
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
        float3  _S592 = make_float3 (0.0f);
        (*throughputs_0)[i_6] = _S592;
        (*pdfs_0)[i_6] = 0.0f;
        uint i_7 = i_6 + 1U;
        i_6 = i_7;
    }
    float3  _S593 = make_float3 (0.0f);
    BSDFLobes _S594 = BSDFLobes_x24init_0(0.0f, 0.0f, _S593, _S593, 0.0f, 0.0f, _S593, _S593, 0.0f, 0.0f, 0.0f, 0.0f, _S593, 0.0f, _S593, _S593, make_float2 (0.0f), 0.0f, 0.0f, _S593, 0.0f, 0.0f, 0.0f, false, 1.0f, 0.0f, _S593);
    BSDFLobes lobe_terms_0 = _S594;
    uint half_of_0 = 4294967295U;
    float3  ggx_n_2 = _S593;
    i_6 = 0U;
    for(;;)
    {
        if(i_6 < _S591)
        {
        }
        else
        {
            break;
        }
        uint _S595;
        if(i_6 == 3U)
        {
            _S595 = 4U;
        }
        else
        {
            if(i_6 == 4U)
            {
                _S595 = 6U;
            }
            else
            {
                _S595 = i_6;
            }
        }
        bool _S596 = _S595 == 0U;
        bool _S597;
        if(_S596)
        {
            _S597 = _S589;
        }
        else
        {
            _S597 = false;
        }
        bool _S598;
        if(_S597)
        {
            _S598 = _S590;
        }
        else
        {
            _S598 = _S595 == 1U;
        }
        bool _S599 = _S598 != refracted_2;
        if(_S599)
        {
            ggx_n_1 = ggx_n_2;
            uint i_8 = i_6 + 1U;
            ggx_n_2 = ggx_n_1;
            i_6 = i_8;
            continue;
        }
        uint _S600;
        if(_S595 == 6U)
        {
            _S600 = 0U;
        }
        else
        {
            if(_S595 == 4U)
            {
                _S600 = 2U;
            }
            else
            {
                _S600 = _S595;
            }
        }
        bool _S601 = _S600 != half_of_0;
        uint half_of_1;
        if(_S601)
        {
            bool _S602 = _S600 == 0U;
            if(_S602)
            {
                float3  _S603 = sampledHalf(in_dir_4, n_7, material_10, random_state_4, _S583);
                ggx_n_1 = _S603;
            }
            else
            {
                bool _S604 = _S600 == 1U;
                if(_S604)
                {
                    float3  _S605 = refractedHalf(in_dir_4, out_dir_2, n_7, eta_i_8, eta_o_8);
                    ggx_n_1 = _S605;
                }
                else
                {
                    float3  _S606 = reflectedHalf(in_dir_4, out_dir_2);
                    ggx_n_1 = _S606;
                }
            }
            float3  _S607 = negate_0(in_dir_4);
            BSDFLobes _S608 = bsdfLobes(in_dir_4, _S607, _S582, ggx_n_1, material_10, eta_i_8, eta_o_8, _S583, _S587);
            lobe_terms_0 = _S608;
            float _S609 = translucentShare(material_10);
            (&lobe_terms_0)->translucent_share = _S609;
            half_of_1 = _S600;
        }
        else
        {
            ggx_n_1 = ggx_n_2;
            half_of_1 = half_of_0;
        }
        switch(_S595)
        {
        case 0U:
            {
                float _S610 = diffusePDF(_S584, 0.0f, (F32_abs((_S580))), _S586, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(0)] = _S610;
                float3  _S611 = diffuseBSDF(out_dir_2, _S582, _S586, material_10, lobe_terms_0);
                (*throughputs_0)[int(0)] = _S611;
                break;
            }
        case 1U:
            {
                float _S612 = refractPDF(_S584, dot_0(out_dir_2, ggx_n_1), (F32_abs((_S580))), _S586, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(1)] = _S612;
                float3  _S613 = refractBSDF(out_dir_2, _S582, _S586, material_10, lobe_terms_0);
                (*throughputs_0)[int(1)] = _S613;
                break;
            }
        case 4U:
            {
                float _S614 = sheenVelvetPDF(_S584, 0.0f, (F32_abs((_S580))), _S586, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(3)] = _S614;
                float3  _S615 = sheenVelvetBSDF(out_dir_2, _S582, _S586, material_10, lobe_terms_0);
                (*throughputs_0)[int(3)] = _S615;
                break;
            }
        case 6U:
            {
                float _S616 = toonPDF(_S584, dot_0(out_dir_2, (&lobe_terms_0)->toon_axis), (F32_abs((_S580))), _S586, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(4)] = _S616;
                float3  _S617 = toonBSDF(out_dir_2, _S582, _S586, material_10, lobe_terms_0);
                (*throughputs_0)[int(4)] = _S617;
                break;
            }
        default:
            {
                float _S618 = reflectPDF(_S584, 0.0f, (F32_abs((_S580))), _S586, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(2)] = _S618;
                float3  _S619 = reflectBSDF(out_dir_2, _S582, _S586, material_10, lobe_terms_0);
                (*throughputs_0)[int(2)] = _S619;
                break;
            }
        }
        half_of_0 = half_of_1;
        uint i_8 = i_6 + 1U;
        ggx_n_2 = ggx_n_1;
        i_6 = i_8;
    }
    i_6 = 0U;
    ggx_n_1 = _S593;
    for(;;)
    {
        if(i_6 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S620 = ((*pdfs_0)[i_6]) > 0.0f;
        if(_S620)
        {
            float3  f_2 = ggx_n_1 + (*throughputs_0)[i_6] * make_float3 ((*pdfs_0)[i_6]);
            ggx_n_1 = f_2;
        }
        uint i_9 = i_6 + 1U;
        i_6 = i_9;
    }
    return ggx_n_1;
}

static __device__ __forceinline__ float3  skyLobes_0(float3  in_dir_5, float3  dir_3, FKSurface * surface_1, float2  eta_1, bool is_inside_2, float pdf_0, uint random_state_5, FixedArray<float3 , 5>  * terms_0, FixedArray<float, 5>  * pdfs_1)
{
    bool _S621 = wrongSide_0(is_inside_2, false, dir_3, surface_1->geometry_n);
    float3  _S622 = BSDF(in_dir_5, dir_3, surface_1->smooth_n, surface_1->material, eta_1.x, eta_1.y, _S621, random_state_5, terms_0, pdfs_1);
    float3  _S623 = make_float3 (0.0f);
    uint i_10 = 0U;
    float3  f_3 = _S623;
    for(;;)
    {
        if(i_10 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S624 = ((*pdfs_1)[i_10]) > 0.0f;
        if(_S624)
        {
            float3  _S625 = (*terms_0)[i_10] * make_float3 ((*pdfs_1)[i_10]) / make_float3 ((*pdfs_1)[i_10] + pdf_0);
            (*terms_0)[i_10] = _S625;
            float3  f_4 = f_3 + (*terms_0)[i_10];
            f_3 = f_4;
        }
        uint i_11 = i_10 + 1U;
        i_10 = i_11;
    }
    return f_3;
}

__device__ float3  skyBSDF(float3  in_dir_6, float3  dir_4, FKSurface surface_2, float2  eta_2, bool is_inside_3, float pdf_1, uint random_state_6)
{
    FKSurface _S626 = surface_2;
    FixedArray<float3 , 5>  terms_1;
    FixedArray<float, 5>  pdfs_2;
    float3  _S627 = skyLobes_0(in_dir_6, dir_4, &_S626, eta_2, is_inside_3, pdf_1, random_state_6, &terms_1, &pdfs_2);
    return _S627;
}

static __device__ SkySample SkySample_x24init_0(float3  dir_5, float3  radiance_0, float3  color_0, uint random_state_7)
{
    SkySample _S628;
    (&_S628)->dir = dir_5;
    (&_S628)->radiance = radiance_0;
    (&_S628)->color = color_0;
    (&_S628)->random_state = random_state_7;
    return _S628;
}

static __device__ SkySample sampleSky_0(FKRay * ray_0, FKSurface * surface_3, float2  eta_3, bool is_inside_4, uint init_random_state_0, uint lobe_state_0, ShadowContext * context_2)
{
    uint2  _S629 = (fcptEnvironmentCdfSize());
    uint2  _S630 = make_uint2 (1U, 0U);
    uint2  _S631 = _S629 - _S630;
    Random _S632 = pcg(init_random_state_0);
    Random _S633 = pcg(_S632.state);
    Random _S634 = pcg(_S633.state);
    Random _S635 = pcg(_S634.state);
    uint _S636 = _S631.x;
    uint _S637 = searchCDF_0(make_uint2 (_S636, 0U), make_uint2 (0U, 1U), _S631.y, _S632.value);
    uint _S638 = searchCDF_0(make_uint2 (0U, _S637), _S630, _S636, _S633.value);
    float2  _S639 = make_float2 ((float)_S631.x, (float)_S631.y);
    float2  _S640 = (make_float2 (float(_S638), float(_S637)) + make_float2 (_S634.value, _S635.value)) / _S639 * make_float2 (6.28318548202514648f, 3.14159274101257324f);
    float _S641 = _S640.y;
    float _S642 = (F32_sin((_S641)));
    float _S643 = _S640.x;
    float3  _S644 = make_float3 (- _S642 * (F32_cos((_S643))), _S642 * (F32_sin((_S643))), (F32_cos((_S641))));
    float _S645 = environmentPdf_0(_S644);
    float3  _S646 = skyBSDF(ray_0->unit_direction, _S644, *surface_3, eta_3, is_inside_4, _S645, lobe_state_0);
    bool _S647 = !(_S645 > 0.0f);
    bool _S648;
    if(_S647)
    {
        _S648 = true;
    }
    else
    {
        _S648 = all_1(_S646 == make_float3 (0.0f));
    }
    if(_S648)
    {
        float3  _S649 = make_float3 (0.0f);
        return SkySample_x24init_0(_S644, _S649, _S649, _S635.state);
    }
    float3  _S650 = skyRadiance_0(ray_0->origin, surface_3, is_inside_4, _S644, context_2, _S635.state);
    return SkySample_x24init_0(_S644, _S650, _S646 * _S650, _S635.state);
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
    SampleBSDF _S651 = (fcptConnectHair((surface_4->hair), ((&surface_4->material)->albedo), ((&surface_4->material)->specular_tint), (in_dir_7), (light_1->dir)));
    float3  _S652 = _S651.throughput * make_float3 (_S651.pdf);
    float _S653 = light_1->density;
    float _S654 = 1.0f + _S651.pdf * _S651.pdf / (light_1->density * light_1->density);
    bool _S655;
    if(competing_0)
    {
        _S655 = _S653 > 0.0f;
    }
    else
    {
        _S655 = false;
    }
    float _S656 = _slang_select(_S655, _S654,1.0f);
    return _S652 / make_float3 (_S656) * light_1->radiance;
}

static __device__ TreeSample TreeSample_x24init_0(float3  dir_6, float3  radiance_1, float density_0, uint random_state_8)
{
    TreeSample _S657;
    (&_S657)->dir = dir_6;
    (&_S657)->radiance = radiance_1;
    (&_S657)->density = density_0;
    (&_S657)->random_state = random_state_8;
    return _S657;
}

__device__ uint pickChild(LightNode first_1, LightNode second_1, float3  p_11, float3  normal_3, float * pick_0, float * probability_3)
{
    float _S658 = importance(first_1, p_11, normal_3);
    float _S659 = importance(second_1, p_11, normal_3);
    float2  _S660 = make_float2 (_S658, _S659);
    bool _S661 = _S658 == 0.0f;
    bool _S662;
    if(_S661)
    {
        _S662 = _S659 == 0.0f;
    }
    else
    {
        _S662 = false;
    }
    if(_S662)
    {
        return 2U;
    }
    float _S663 = _S658 + _S659;
    bool _S664 = _S659 > 0.0f;
    if(_S664)
    {
        _S662 = (*pick_0 * _S663) >= _S658;
    }
    else
    {
        _S662 = false;
    }
    uint _S665 = uint(_S662);
    float _S666 = (F32_min(((*pick_0 * _S663 - float(_S665) * _S658) / _slang_vector_get_element(_S660, _S665)), (0.99999994039535522f)));
    *pick_0 = _S666;
    float _S667 = *probability_3 * (_slang_vector_get_element(_S660, _S665) / _S663);
    *probability_3 = _S667;
    return _S665;
}

__device__ float3  sampleSphere(float3  center_1, float radius_1, float3  p_12, float u1_0, float u2_0)
{
    float3  _S668 = center_1 - p_12;
    float _S669 = radius_1 * radius_1 / dot_0(_S668, _S668);
    float _S670 = u1_0 * _S669 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S669), (0.0f)))))));
    float _S671 = 2.0f * u1_0;
    bool _S672 = _S669 >= 1.0f;
    float _S673 = _slang_select(_S672, _S671,_S670);
    float _S674 = (F32_sqrt(((F32_max((_S673 * (2.0f - _S673)), (0.0f))))));
    float _S675 = 6.28318548202514648f * u2_0;
    float3  _S676 = make_float3 (_S674 * (F32_cos((_S675))), 1.0f - _S673, _S674 * (F32_sin((_S675))));
    float3  _S677 = ((((_S668)) * make_float3(rnorm3df(((_S668)).x, ((_S668)).y, ((_S668)).z))));
    float3  _S678 = tangentToWorld(_S676, _S677);
    return _S678;
}

__device__ float3  pointLightRadiance(float3  color_1, float intensity_0, float radius_2)
{
    return color_1 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_2 * radius_2);
}

static __device__ float raySphere_0(float3  center_2, float radius_3, FKRay * ray_1, float max_len_0)
{
    float3  _S679 = center_2 - ray_1->origin;
    float _S680 = dot_0(_S679, ray_1->unit_direction);
    float _S681 = dot_0(_S679, _S679) - _S680 * _S680;
    float _S682 = radius_3 * radius_3;
    bool _S683 = _S681 > _S682;
    if(_S683)
    {
        return 4.294967296e+09f;
    }
    float _S684 = (F32_sqrt((_S682 - _S681)));
    float _S685 = _S680 - _S684;
    float _S686 = _S680 + _S684;
    bool _S687 = _S685 > 0.0000152587890625f;
    bool _S688;
    if(_S687)
    {
        _S688 = _S685 < max_len_0;
    }
    else
    {
        _S688 = false;
    }
    if(_S688)
    {
        return _S685;
    }
    bool _S689 = _S686 > 0.0000152587890625f;
    if(_S689)
    {
        _S688 = _S686 < max_len_0;
    }
    else
    {
        _S688 = false;
    }
    if(_S688)
    {
        return _S686;
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

static __device__ __forceinline__ TreeSample sampleLightTree_0(float3  origin_4, float3  smooth_n_2, float3  geometry_n_1, float geometry_offset_1, bool sided_0, uint init_random_state_1, ShadowContext * context_3)
{
    Random _S690 = pcg(init_random_state_1);
    Random _S691 = pcg(_S690.state);
    Random _S692 = pcg(_S691.state);
    float3  _S693 = make_float3 (0.0f);
    TreeSample _S694 = TreeSample_x24init_0(_S693, _S693, 0.0f, _S692.state);
    TreeSample sample_0 = _S694;
    float3  _S695 = _slang_select(sided_0, _S693,smooth_n_2);
    float3  _S696 = origin_4 + make_float3 (geometry_offset_1) * smooth_n_2;
    float pick_1 = _S690.value;
    float probability_4 = 1.0f;
    uint n_8 = 0U;
    for(;;)
    {
        uint4  _S697 = (fcptLightNode((n_8)));
        if((_S697.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S698 = (fcptLightSecond((n_8)));
        uint _S699 = n_8 + 1U;
        LightNode _S700 = (fcptLightBounds((_S699)));
        LightNode _S701 = (fcptLightBounds((_S698)));
        uint _S702 = pickChild(_S700, _S701, origin_4, _S695, &pick_1, &probability_4);
        bool _S703 = _S702 > 1U;
        if(_S703)
        {
            return sample_0;
        }
        bool _S704 = _S702 == 1U;
        uint _S705 = _slang_select(_S704, _S698,_S699);
        n_8 = _S705;
    }
    bool _S706 = n_8 == 0U;
    bool _S707;
    if(_S706)
    {
        LightNode _S708 = (fcptLightBounds((0U)));
        float _S709 = importance(_S708, origin_4, _S695);
        _S707 = !(_S709 > 0.0f);
    }
    else
    {
        _S707 = false;
    }
    if(_S707)
    {
        return sample_0;
    }
    uint4  _S710 = (fcptLightNode((n_8)));
    FKHit _S711 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    bool _S712 = (_S710.x) == 2U;
    float3  emitter_point_0;
    float3  lift_n_0;
    float3  shadow_1;
    FKHit emitter_0;
    if(_S712)
    {
        FKLight _S713 = (fcptLight((_S710.y)));
        if(sided_0)
        {
            float _S714 = sign_0(dot_0(geometry_n_1, _S713.position - origin_4));
            float3  lift_n_1 = smooth_n_2 * make_float3 (_S714);
            float3  _S715 = origin_4 + make_float3 (geometry_offset_1) * lift_n_1;
            emitter_point_0 = _S715;
            lift_n_0 = lift_n_1;
        }
        else
        {
            emitter_point_0 = _S696;
            lift_n_0 = smooth_n_2;
        }
        bool _S716 = (_S713.variance) == 0.0f;
        if(_S716)
        {
            float3  _S717 = _S713.position - emitter_point_0;
            float3  _S718 = ((((_S717)) * make_float3(rnorm3df(((_S717)).x, ((_S717)).y, ((_S717)).z))));
            (&sample_0)->dir = _S718;
            float3  _S719 = _S713.color * make_float3 (_S713.intensity) / make_float3 (dot_0(_S717, _S717) * probability_4);
            (&sample_0)->radiance = _S719;
            shadow_1 = _S717;
        }
        else
        {
            float3  _S720 = sampleSphere(_S713.position, _S713.variance, emitter_point_0, _S691.value, _S692.value);
            (&sample_0)->dir = _S720;
            float _S721 = sphereDensity(_S713.position, _S713.variance, emitter_point_0);
            float _S722 = probability_4 * _S721;
            (&sample_0)->density = _S722;
            float3  _S723 = pointLightRadiance(_S713.color, _S713.intensity, _S713.variance);
            float3  _S724 = _S723 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S724;
            FKRay _S725 = Ray_x24init_0(emitter_point_0, (&sample_0)->dir);
            float _S726 = raySphere_0(_S713.position, _S713.variance, &_S725, 4.294967296e+09f);
            float3  _S727 = (&sample_0)->dir * make_float3 (_S726);
            shadow_1 = _S727;
        }
        emitter_0 = _S711;
        emitter_point_0 = _S693;
    }
    else
    {
        uint _S728 = _S710.y;
        uint _S729 = (fcptTriangleOffset((_S728)));
        uint _S730 = _S729 + _S710.z;
        Matrix<float, 3, 3>  _S731 = (fcptWorldTriangle((_S728), (_S730)));
        float _S732 = (F32_sqrt((_S691.value)));
        float2  _S733 = make_float2 (_S732 * (1.0f - _S692.value), _S732 * _S692.value);
        float3  _S734 = mul_0(make_float3 (1.0f - _S732, _S733.x, _S733.y), _S731);
        if(sided_0)
        {
            float _S735 = sign_0(dot_0(geometry_n_1, _S734 - origin_4));
            float3  lift_n_2 = smooth_n_2 * make_float3 (_S735);
            float3  _S736 = origin_4 + make_float3 (geometry_offset_1) * lift_n_2;
            emitter_point_0 = _S736;
            lift_n_0 = lift_n_2;
        }
        else
        {
            bool _S737 = !((dot_0(smooth_n_2, _S734 - origin_4)) > 0.0f);
            if(_S737)
            {
                return sample_0;
            }
            emitter_point_0 = _S696;
            lift_n_0 = smooth_n_2;
        }
        FKHit emitter_1 = Hit_x24init_0(_S733, _S728, _S730, 0U, 0.0f);
        float3  _S738 = _S734 - emitter_point_0;
        float3  _S739 = ((((_S738)) * make_float3(rnorm3df(((_S738)).x, ((_S738)).y, ((_S738)).z))));
        (&sample_0)->dir = _S739;
        float _S740 = solidAngle(probability_4, cross_0(_S731.rows[int(1)] - _S731.rows[int(0)], _S731.rows[int(2)] - _S731.rows[int(0)]), _S738);
        (&sample_0)->density = _S740;
        bool _S741 = (fcptShadowFirst());
        bool _S742 = !_S741;
        if(_S742)
        {
            FKSurface _S743 = (fcptLightSurfaceAt((emitter_1), (_S734), (_S692.state), ((&sample_0)->dir), (context_3->depth), (length_0(_S734 - origin_4))));
            (&sample_0)->random_state = _S743.random_state;
            float3  _S744 = _slang_select(_S743.skip, _S693,_S743.material.emissive);
            float3  _S745 = _S744 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S745;
        }
        shadow_1 = _S738;
        emitter_0 = emitter_1;
        emitter_point_0 = _S734;
    }
    FKHit _S746 = emitter_0;
    float3  _S747 = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, context_3, _S692.state, &_S746);
    bool _S748 = (fcptShadowFirst());
    if(_S748)
    {
        _S707 = (emitter_0.instance_index) != 4294967295U;
    }
    else
    {
        _S707 = false;
    }
    if(_S707)
    {
        _S707 = !all_1(_S747 == _S693);
    }
    else
    {
        _S707 = false;
    }
    if(_S707)
    {
        FKSurface _S749 = (fcptLightSurfaceAt((emitter_0), (emitter_point_0), (_S692.state), ((&sample_0)->dir), (context_3->depth), (length_0(emitter_point_0 - origin_4))));
        (&sample_0)->random_state = _S749.random_state;
        float3  _S750 = _slang_select(_S749.skip, _S693,_S749.material.emissive);
        float3  _S751 = _S750 / make_float3 ((&sample_0)->density);
        (&sample_0)->radiance = _S751;
    }
    float3  _S752 = (&sample_0)->radiance * _S747;
    bool _S753 = all_1(_S747 == _S693);
    float3  _S754 = _slang_select(_S753, _S693,_S752);
    (&sample_0)->radiance = _S754;
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
    float _S755 = 1.0f / (1.0f + b_1 / a_5 * (b_1 / a_5));
    bool _S756 = b_1 > 0.0f;
    float _S757 = _slang_select(_S756, _S755,1.0f);
    return _S757;
}

static __device__ float emissionWeight_0(NEEVertex * vertex_0, FKHit * hit_1, float3  light_point_1)
{
    bool _S758 = vertex_0->none;
    if(_S758)
    {
        return 1.0f;
    }
    uint _S759 = (fcptLightSlot((*hit_1)));
    float _S760 = lightPdf_0(vertex_0->origin, vertex_0->smooth_n, vertex_0->start, _S759, light_point_1);
    float _S761 = powerHeuristic(vertex_0->pdf, _S760);
    return _S761;
}

static __device__ float3  environment_0(float3  dir_7, uint depth_0, uint lobe_0)
{
    uint2  _S762 = (fcptEnvironmentMapSize());
    bool _S763 = (_S762.x) > 1U;
    bool _S764;
    if(_S763)
    {
        uint2  _S765 = (fcptEnvironmentMapSize());
        _S764 = (_S765.y) > 1U;
    }
    else
    {
        _S764 = false;
    }
    if(_S764)
    {
        float3  _S766 = (fcptEnvMapSample((dir_7), (depth_0), (lobe_0)));
        return _S766;
    }
    float3  _S767 = (fcptAmbient());
    return _S767;
}

static __device__ bool environmentMapped_0()
{
    uint2  _S768 = (fcptEnvironmentCdfSize());
    bool _S769 = (_S768.x) > 1U;
    bool _S770;
    if(_S769)
    {
        uint2  _S771 = (fcptEnvironmentCdfSize());
        _S770 = (_S771.y) > 1U;
    }
    else
    {
        _S770 = false;
    }
    bool _S772 = !_S770;
    if(_S772)
    {
        return false;
    }
    uint2  _S773 = (fcptEnvironmentMapSize());
    bool _S774 = (_S773.x) > 1U;
    if(_S774)
    {
        uint2  _S775 = (fcptEnvironmentMapSize());
        _S770 = (_S775.y) > 1U;
    }
    else
    {
        _S770 = false;
    }
    return _S770;
}

static __device__ float escapeWeight_0(float pdf_2, float3  dir_8)
{
    bool _S776 = pdf_2 <= 0.0f;
    bool _S777;
    if(_S776)
    {
        _S777 = true;
    }
    else
    {
        bool _S778 = environmentMapped_0();
        _S777 = !_S778;
    }
    if(_S777)
    {
        return 1.0f;
    }
    float _S779 = environmentPdf_0(dir_8);
    return pdf_2 / (pdf_2 + _S779);
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
    uint2  _S780 = uint2 {global_invocation_id_1.x, global_invocation_id_1.y};
    int2  _S781 = make_int2 ((int)_S780.x, (int)_S780.y);
    uint _S782 = previousSeed_0(_S781);
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
            uint _S783 = previousSeed_0(_S781 + make_int2 (x_16, y_5));
            bool _S784 = _S783 == _S782;
            uint _S785 = _slang_select(_S784, 1U,0U);
            uint count_3 = count_2 + _S785;
            int x_17 = x_16 + int(1);
            x_16 = x_17;
            count_2 = count_3;
        }
        int y_6 = y_5 + int(1);
        y_5 = y_6;
    }
    float _S786 = float(count_2 - 1U) / 288.0f;
    bool _S787 = _S782 != 0U;
    float _S788 = _slang_select(_S787, _S786,0.0f);
    fcptStoreDuplication((_S781), (make_uint4 ((F32_asuint((_S788))), 0U, 0U, 0U)));
    return;
}

__device__ uint stream(uint seed_3, uint index_0)
{
    uint _S789 = hash(index_0);
    uint _S790 = hash(seed_3 ^ _S789);
    return _S790;
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
    float _S791 = rgb_to_greyscale(weight_0);
    bool _S792 = _S791 > 0.0f;
    bool _S793;
    if(_S792)
    {
        _S793 = _S791 < 3.00000000549775576e+38f;
    }
    else
    {
        _S793 = false;
    }
    bool _S794 = !_S793;
    if(_S794)
    {
        return;
    }
    bool _S795 = sel_2->sums;
    if(_S795)
    {
        float3  _S796 = sel_2->color + weight_0;
        sel_2->color = _S796;
        return;
    }
    float _S797 = sel_2->w_sum + _S791;
    sel_2->w_sum = _S797;
    float3  _S798 = sel_2->color + weight_0;
    sel_2->color = _S798;
    Random _S799 = pcg(sel_2->random_state);
    sel_2->random_state = _S799.state;
    bool _S800 = (_S799.value * sel_2->w_sum) <= _S791;
    if(_S800)
    {
        sel_2->r = candidate_0;
    }
    return;
}

__device__ void offerShifted(Selection * sel_3, Reservoir r_3, Shift shifted_0, float mis_0)
{
    Reservoir candidate_1 = r_3;
    float3  _S801 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_1)->f = _S801;
    float _S802 = r_3.jac * shifted_0.jac;
    (&candidate_1)->jac = _S802;
    offer(sel_3, candidate_1, make_float3 (mis_0) * shifted_0.f * make_float3 (r_3.w));
    return;
}

__device__ Reservoir finalize(Selection sel_4, float c_1)
{
    Reservoir r_4 = sel_4.r;
    float _S803 = rgb_to_greyscale((&r_4)->f);
    float _S804 = sel_4.w_sum / _S803;
    bool _S805 = _S803 > 0.0f;
    float _S806 = _slang_select(_S805, _S804,0.0f);
    (&r_4)->w = _S806;
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
    uint2  _S807 = uint2 {global_invocation_id_2.x, global_invocation_id_2.y};
    int2  _S808 = make_int2 ((int)_S807.x, (int)_S807.y);
    float3  _S809 = make_float3 (0.0f);
    FKHit _S810 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S811 = Domain_x24init_0(_S809, _S809, &_S810, 0.0f, 0.0f);
    Domain dom_4 = _S811;
    bool _S812 = (fcptCurrentDomain((_S808), (&dom_4)));
    bool _S813 = !_S812;
    if(_S813)
    {
        Reservoir _S814 = (Reservoir{});
        fcptStoreReservoirPrevious((_S808), (_S814), ((&dom_4)->hit));
        return;
    }
    Reservoir _S815 = (fcptLoadReservoirTemporal((_S808)));
    uint t_12 = 0U;
    float count_4 = 0.0f;
    float c_sum_0 = _S815.c;
    for(;;)
    {
        uint _S816 = (fcptRestirNeighbours());
        if(t_12 < _S816)
        {
        }
        else
        {
            break;
        }
        int2  _S817 = partner_0(_S808, t_12);
        Domain neighbor_0 = _S811;
        bool _S818 = (fcptCurrentDomain((_S817), (&neighbor_0)));
        if(_S818)
        {
            float count_5 = count_4 + 1.0f;
            uint4  _S819 = (fcptReservoirTemporal((_S817), (0U)));
            float c_sum_1 = c_sum_0 + (U32_asfloat((_S819.w)));
            count_4 = count_5;
            c_sum_0 = c_sum_1;
        }
        uint t_13 = t_12 + 1U;
        t_12 = t_13;
    }
    float _S820 = _S815.c / (F32_max((count_4), (1.0f)));
    float _S821 = rgb_to_greyscale(_S815.f);
    bool _S822 = count_4 == 0.0f;
    float _S823 = _slang_select(_S822, 1.0f,0.0f);
    Selection _S824 = (Selection{});
    Selection sel_5 = _S824;
    uint _S825 = (fcptFrame());
    uint _S826 = hash(_S825);
    uint _S827 = global_invocation_id_2.x;
    uint2  _S828 = (fcptRenderSize());
    uint _S829 = stream(_S826, _S827 + _S828.x * global_invocation_id_2.y);
    uint _S830 = stream(_S829, 195U);
    (&sel_5)->random_state = _S830;
    t_12 = 0U;
    float canonical_mis_0 = _S823;
    for(;;)
    {
        uint _S831 = (fcptRestirNeighbours());
        if(t_12 < _S831)
        {
        }
        else
        {
            break;
        }
        int2  _S832 = partner_0(_S808, t_12);
        Domain neighbor_dom_0 = _S811;
        bool _S833 = (fcptCurrentDomain((_S832), (&neighbor_dom_0)));
        if(_S833)
        {
            Reservoir _S834 = (fcptLoadReservoirTemporal((_S832)));
            uint4  _S835 = (fcptShiftData((_S832), (t_12)));
            float4  _S836 = asfloat_0(_S835);
            uint4  _S837 = (fcptShiftData((_S808), (t_12)));
            float4  _S838 = asfloat_0(_S837);
            float _S839 = (_S834.c + _S820) / c_sum_0;
            bool _S840 = _S821 > 0.0f;
            float canonical_mis_1;
            if(_S840)
            {
                float _S841 = _S839 * _S820 * _S821;
                float _S842 = _S820 * _S821;
                float _S843 = rgb_to_greyscale(float3 {_S838.x, _S838.y, _S838.z});
                float canonical_mis_2 = canonical_mis_0 + _S841 / (_S842 + _S834.c * _S843);
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            float _S844 = rgb_to_greyscale(_S834.f);
            float3  _S845 = float3 {_S836.x, _S836.y, _S836.z};
            Shift _S846 = Shift_x24init_0(_S845, _S836.w);
            float _S847 = _S839 * _S834.c * _S844;
            float _S848 = _S834.c * _S844;
            float _S849 = rgb_to_greyscale(_S845);
            offerShifted(&sel_5, _S834, _S846, _S847 / (_S848 + _S820 * _S849));
            canonical_mis_0 = canonical_mis_1;
        }
        uint t_14 = t_12 + 1U;
        t_12 = t_14;
    }
    offerShifted(&sel_5, _S815, Shift_x24init_0(_S815.f, 1.0f), canonical_mis_0);
    Reservoir _S850 = finalize(sel_5, c_sum_0);
    fcptStoreReservoirPrevious((_S808), (_S850), ((&dom_4)->hit));
    fcptStorePreviousLayer((_S808), (5U), (make_uint4 (asuint_0((&(&dom_4)->hit)->uv).x, asuint_0((&(&dom_4)->hit)->uv).y, 0U, 0U)));
    fcptAddColor((_S808), (make_float4 ((&sel_5)->color.x, (&sel_5)->color.y, (&sel_5)->color.z, 0.0f)));
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
    uint _S851 = queuedShift_0(workgroup_id_1, local_invocation_index_4);
    bool _S852 = _S851 != 4294967295U;
    if(_S852)
    {
        uint2  _S853 = make_uint2 (_S851, _S851 >> 14U) & make_uint2 (16383U);
        int2  _S854 = make_int2 ((int)_S853.x, (int)_S853.y);
        ShiftJob _S855 = (ShiftJob{});
        ShiftJob shift_job_0 = _S855;
        Shift _S856 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
        uint _S857 = _S851 >> 28U;
        bool _S858 = spatialJob_0(_S854, _S857, &shift_job_0, true);
        Shift shifted_1;
        if(_S858)
        {
            Domain _S859 = (&shift_job_0)->dom;
            Reservoir _S860 = (&shift_job_0)->r;
            Shift _S861 = passShift_0(&_S859, &_S860);
            shifted_1 = _S861;
        }
        else
        {
            shifted_1 = _S856;
        }
        fcptStoreShiftData((_S854), (_S857), (make_uint4 (asuint_1(shifted_1.f).x, asuint_1(shifted_1.f).y, asuint_1(shifted_1.f).z, (F32_asuint((shifted_1.jac))))));
    }
    return;
}

static __device__ void restir_prepass_0(uint3  global_invocation_id_3, uint local_invocation_index_5)
{
    uint2  _S862 = uint2 {global_invocation_id_3.x, global_invocation_id_3.y};
    int2  _S863 = make_int2 ((int)_S862.x, (int)_S862.y);
    FixedArray<uint, 3>  _S864;
    spatialBins_0(_S863, &_S864);
    FixedArray<uint, 3>  _S865 = _S864;
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
        bool _S866 = (_S865[t_15]) == 40U;
        if(_S866)
        {
            fcptStoreShiftData((_S863), (t_15), (make_uint4 (0U)));
        }
        uint t_16 = t_15 + 1U;
        t_15 = t_16;
    }
    FixedArray<uint, 3>  _S867 = _S865;
    queueShifts_0(_S863, &_S867, global_invocation_id_3, local_invocation_index_5);
    return;
}

static __device__ void restir_count_0(uint3  global_invocation_id_4, uint local_invocation_index_6)
{
    uint2  _S868 = uint2 {global_invocation_id_4.x, global_invocation_id_4.y};
    int2  _S869 = make_int2 ((int)_S868.x, (int)_S868.y);
    FixedArray<uint, 3>  _S870;
    spatialBins_0(_S869, &_S870);
    FixedArray<uint, 3>  _S871 = _S870;
    countShifts_0(&_S871, local_invocation_index_6);
    return;
}

static __device__ void restir_temporal_shift_0(uint3  workgroup_id_2, uint local_invocation_index_7)
{
    uint _S872 = queuedShift_0(workgroup_id_2, local_invocation_index_7);
    bool _S873 = _S872 != 4294967295U;
    if(_S873)
    {
        uint2  _S874 = make_uint2 (_S872, _S872 >> 14U) & make_uint2 (16383U);
        int2  _S875 = make_int2 ((int)_S874.x, (int)_S874.y);
        ShiftJob _S876 = (ShiftJob{});
        ShiftJob shift_job_1 = _S876;
        Shift _S877 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
        uint _S878 = _S872 >> 28U;
        bool _S879 = temporalJob_0(_S875, _S878, &shift_job_1, true);
        Shift shifted_2;
        if(_S879)
        {
            if(_S878 == 1U)
            {
                Shift _S880 = (fcptShiftPrevious(((&shift_job_1)->dom), ((&shift_job_1)->r)));
                shifted_2 = _S880;
            }
            else
            {
                Domain _S881 = (&shift_job_1)->dom;
                Reservoir _S882 = (&shift_job_1)->r;
                Shift _S883 = passShift_0(&_S881, &_S882);
                shifted_2 = _S883;
            }
        }
        else
        {
            shifted_2 = _S877;
        }
        fcptStoreTemporalShift((_S875), (_S878), (make_uint4 (asuint_1(shifted_2.f).x, asuint_1(shifted_2.f).y, asuint_1(shifted_2.f).z, (F32_asuint((shifted_2.jac))))));
    }
    return;
}

static __device__ void restir_temporal_prepass_0(uint3  global_invocation_id_5, uint local_invocation_index_8)
{
    uint2  _S884 = uint2 {global_invocation_id_5.x, global_invocation_id_5.y};
    int2  _S885 = make_int2 ((int)_S884.x, (int)_S884.y);
    FixedArray<uint, 3>  _S886;
    temporalBins_0(_S885, &_S886);
    FixedArray<uint, 3>  _S887 = _S886;
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
        bool _S888 = (_S887[t_17]) == 40U;
        if(_S888)
        {
            fcptStoreTemporalShift((_S885), (t_17), (make_uint4 (0U)));
        }
        uint t_18 = t_17 + 1U;
        t_17 = t_18;
    }
    FixedArray<uint, 3>  _S889 = _S887;
    queueShifts_0(_S885, &_S889, global_invocation_id_5, local_invocation_index_8);
    return;
}

static __device__ void restir_temporal_count_0(uint3  global_invocation_id_6, uint local_invocation_index_9)
{
    uint2  _S890 = uint2 {global_invocation_id_6.x, global_invocation_id_6.y};
    int2  _S891 = make_int2 ((int)_S890.x, (int)_S890.y);
    bool _S892 = (fcptSceneUnchanged());
    bool _S893 = !_S892;
    bool _S894;
    if(_S893)
    {
        uint2  _S895 = (fcptRenderSize());
        int2  _S896 = make_int2 ((int)_S895.x, (int)_S895.y);
        _S894 = all_0(_S891 < _S896);
    }
    else
    {
        _S894 = false;
    }
    if(_S894)
    {
        Reservoir _S897 = (fcptLoadReservoirInitial((_S891)));
        int2  _S898 = sampleNeighbor_0(_S891, _S897.seed);
        fcptStoreTemporalNeighbor((_S891), (_S898));
    }
    FixedArray<uint, 3>  _S899;
    temporalBins_0(_S891, &_S899);
    FixedArray<uint, 3>  _S900 = _S899;
    countShifts_0(&_S900, local_invocation_index_9);
    return;
}

static __device__ float interpolate_0(float a_6, float b_2, float t_19)
{
    return a_6 + (b_2 - a_6) * t_19;
}

static __device__ void restir_temporal_0(uint3  global_invocation_id_7)
{
    uint2  _S901 = uint2 {global_invocation_id_7.x, global_invocation_id_7.y};
    int2  _S902 = make_int2 ((int)_S901.x, (int)_S901.y);
    float3  _S903 = make_float3 (0.0f);
    FKHit _S904 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S905 = Domain_x24init_0(_S903, _S903, &_S904, 0.0f, 0.0f);
    Domain dom_5 = _S905;
    bool _S906 = (fcptCurrentDomain((_S902), (&dom_5)));
    bool _S907 = !_S906;
    if(_S907)
    {
        Reservoir _S908 = (Reservoir{});
        fcptStoreReservoirTemporal((_S902), (_S908), ((&dom_5)->hit));
        return;
    }
    Reservoir _S909 = (fcptLoadReservoirInitial((_S902)));
    bool _S910 = (fcptSceneUnchanged());
    int2  _S911;
    if(_S910)
    {
        int2  _S912 = sampleNeighbor_0(_S902, _S909.seed);
        _S911 = _S912;
    }
    else
    {
        int2  _S913 = (fcptLoadTemporalNeighbor((_S902)));
        _S911 = _S913;
    }
    bool _S914 = (_S911.x) >= int(0);
    Reservoir r_5;
    if(_S914)
    {
        Reservoir _S915 = (fcptLoadReservoirPrevious((_S911)));
        uint4  _S916 = (fcptDuplication((_S911)));
        float _S917 = (U32_asfloat((_S916.x)));
        uint _S918 = (fcptRestirDecorrelation());
        bool _S919 = _S918 == 1U;
        float _S920 = _slang_select(_S919, _S917,0.0f);
        float _S921 = interpolate_0(20.0f, 1.0f, (F32_pow((_S920), (0.10000000149011612f))));
        float _S922 = (F32_min((_S915.c), (_S921)));
        bool _S923 = (fcptSceneUnchanged());
        float4  _S924;
        if(_S923)
        {
            _S924 = make_float4 (_S915.f.x, _S915.f.y, _S915.f.z, 1.0f);
        }
        else
        {
            uint4  _S925 = (fcptTemporalShift((_S902), (0U)));
            _S924 = asfloat_0(_S925);
        }
        Domain own_1 = _S905;
        bool _S926;
        if(_S923)
        {
            _S926 = true;
        }
        else
        {
            bool _S927 = (fcptPreviousScenes());
            bool _S928 = !_S927;
            if(_S928)
            {
                _S926 = (_S909.w) > 0.0f;
            }
            else
            {
                _S926 = false;
            }
            if(_S926)
            {
                bool _S929 = (fcptStoredDomainInitial((_S902), (_S909.seed), (&own_1)));
                _S926 = _S929;
            }
            else
            {
                _S926 = false;
            }
            if(_S926)
            {
                Domain _S930 = (fcptPreviousDomain((_S911), (_S909.seed)));
                Domain _S931 = _S930;
                Domain _S932 = own_1;
                bool _S933 = sameDomain_0(&_S931, &_S932);
                _S926 = _S933;
            }
            else
            {
                _S926 = false;
            }
        }
        float4  _S934;
        if(_S926)
        {
            _S934 = make_float4 (_S909.f.x, _S909.f.y, _S909.f.z, 1.0f);
        }
        else
        {
            uint4  _S935 = (fcptTemporalShift((_S902), (1U)));
            _S934 = asfloat_0(_S935);
        }
        float _S936 = rgb_to_greyscale(_S909.f);
        float _S937 = rgb_to_greyscale(_S915.f);
        Selection _S938 = (Selection{});
        Selection sel_6 = _S938;
        uint _S939 = (fcptFrame());
        uint _S940 = hash(_S939);
        uint _S941 = global_invocation_id_7.x;
        uint2  _S942 = (fcptRenderSize());
        uint _S943 = stream(_S940, _S941 + _S942.x * global_invocation_id_7.y);
        uint _S944 = stream(_S943, 194U);
        (&sel_6)->random_state = _S944;
        float _S945 = _S909.c * _S936;
        float4  _S946 = _S934;
        float _S947 = rgb_to_greyscale(float3 {_S946.x, _S946.y, _S946.z});
        float _S948 = _S945 / (_S945 + _S922 * _S947);
        float _S949 = _S922 * _S937;
        float4  _S950 = _S924;
        float3  _S951 = float3 {_S950.x, _S950.y, _S950.z};
        float _S952 = rgb_to_greyscale(_S951);
        float _S953 = _S949 / (_S949 + _S909.c * _S952);
        float2  _S954 = make_float2 (_S948, _S953);
        offerShifted(&sel_6, _S909, Shift_x24init_0(_S909.f, 1.0f), _S948);
        offerShifted(&sel_6, _S915, Shift_x24init_0(_S951, _S924.w), _S953);
        Reservoir _S955 = finalize(sel_6, _S909.c + _S922);
        r_5 = _S955;
    }
    else
    {
        r_5 = _S909;
    }
    fcptStoreReservoirTemporal((_S902), (r_5), ((&dom_5)->hit));
    return;
}

static __device__ void restir_initial_0(uint3  global_invocation_id_8)
{
    uint2  _S956 = uint2 {global_invocation_id_8.x, global_invocation_id_8.y};
    int2  _S957 = make_int2 ((int)_S956.x, (int)_S956.y);
    float3  _S958 = make_float3 (0.0f);
    float2  _S959 = make_float2 (0.0f);
    FKHit _S960 = Hit_x24init_0(_S959, 0U, 0U, 0U, 0.0f);
    Domain _S961 = Domain_x24init_0(_S958, _S958, &_S960, 0.0f, 0.0f);
    Domain dom_6 = _S961;
    bool _S962 = (fcptCurrentDomain((_S957), (&dom_6)));
    bool _S963 = !_S962;
    if(_S963)
    {
        Reservoir _S964 = (Reservoir{});
        fcptStoreReservoirInitial((_S957), (_S964), ((&dom_6)->hit));
        return;
    }
    uint _S965 = (fcptFrame());
    uint _S966 = hash(_S965);
    uint _S967 = global_invocation_id_8.x;
    uint2  _S968 = (fcptRenderSize());
    uint _S969 = stream(_S966, _S967 + _S968.x * global_invocation_id_8.y);
    Selection _S970 = (Selection{});
    Selection initial_0 = _S970;
    uint _S971 = stream(_S969, 193U);
    (&initial_0)->random_state = _S971;
    bool _S972 = (fcptRestirUsed());
    bool _S973 = !_S972;
    (&initial_0)->sums = _S973;
    uint _S974 = stream(_S969, 0U);
    (&(&initial_0)->r)->seed = _S974;
    FKHit _S975 = Hit_x24init_0(_S959, 4294967295U, 0U, 0U, 0.0f);
    uint _S976 = (fcptSamples());
    float _S977 = 1.0f / float(_S976);
    FKHit hit_2 = _S975;
    uint i_17 = 0U;
    for(;;)
    {
        uint _S978 = (fcptSamples());
        if(i_17 < _S978)
        {
        }
        else
        {
            break;
        }
        Reservoir _S979 = (Reservoir{});
        Reservoir r_6 = _S979;
        uint _S980 = stream(_S969, i_17);
        (&r_6)->seed = _S980;
        Domain path_0 = _S961;
        bool _S981 = (fcptStoredDomainInitial((_S957), ((&r_6)->seed), (&path_0)));
        bool _S982 = !_S981;
        if(_S982)
        {
            fcptMissed((_S957), (path_0), (_S977));
            uint i_18 = i_17 + 1U;
            i_17 = i_18;
            continue;
        }
        Domain _S983 = path_0;
        Reservoir _S984 = r_6;
        Shift _S985 = passWalk_0(&_S983, &_S984, false, _S977, &initial_0);
        bool _S986 = ((&(&initial_0)->r)->seed) == ((&r_6)->seed);
        FKHit hit_3;
        if(_S986)
        {
            FKHit _S987 = (&path_0)->hit;
            hit_3 = _S987;
        }
        else
        {
            hit_3 = hit_2;
        }
        hit_2 = hit_3;
        uint i_18 = i_17 + 1U;
        i_17 = i_18;
    }
    float3  _S988 = (&initial_0)->glow;
    float3  _S989 = (&initial_0)->color;
    bool _S990 = (&initial_0)->sums;
    float3  _S991 = _slang_select(_S990, _S989,_S958);
    fcptAddColor((_S957), (make_float4 ((_S988 + _S991).x, (_S988 + _S991).y, (_S988 + _S991).z, 1.0f)));
    Reservoir _S992 = finalize(initial_0, 1.0f);
    fcptStoreReservoirInitial((_S957), (_S992), (hit_2));
    return;
}

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_3, float3  origin_5, float3  smooth_n_3, float3  start_6)
{
    NEEVertex _S993;
    (&_S993)->none = none_0;
    (&_S993)->pdf = pdf_3;
    (&_S993)->origin = origin_5;
    (&_S993)->smooth_n = smooth_n_3;
    (&_S993)->start = start_6;
    return _S993;
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
    Vertex _S994;
    (&_S994)->rough = rough_0;
    (&_S994)->lobe = lobe_1;
    (&_S994)->pdf = pdf_4;
    (&_S994)->cos = cos_0;
    (&_S994)->inside = inside_0;
    return _S994;
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
    float3  _S995 = exp_0((make_float3 (sigma_0) - extinction_0) * make_float3 (distance_2));
    float3  _S996 = scatter_0 * _S995 / make_float3 (sigma_0);
    float3  _S997 = _slang_select(scatters_0, _S996,_S995);
    return _S997;
}

static __device__ uint arrivalLobe_0(uint b_3, uint prev_lobe_0)
{
    bool _S998 = b_3 > 0U;
    uint _S999 = _slang_select(_S998, prev_lobe_0,3U);
    return _S999;
}

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_0, uint depth_1, uint lobe_2, bool surface_5, float length_2, float width_1, FKHit * own_2, bool fiber_0)
{
    ShadowContext _S1000;
    (&_S1000)->extinction_behind = extinction_behind_0;
    (&_S1000)->extinction_front = extinction_front_0;
    (&_S1000)->fillings = fillings_0;
    (&_S1000)->side = side_0;
    (&_S1000)->depth = depth_1;
    (&_S1000)->lobe = lobe_2;
    (&_S1000)->surface = surface_5;
    (&_S1000)->length = length_2;
    (&_S1000)->width = width_1;
    (&_S1000)->own = *own_2;
    (&_S1000)->fiber = fiber_0;
    return _S1000;
}

static __device__ float phaseHG_0(float g_0, float mu_0)
{
    bool _S1001 = (F32_abs((g_0))) < 0.00100000004749745f;
    if(_S1001)
    {
        return 0.07957746833562851f;
    }
    float _S1002 = g_0 * g_0;
    return (1.0f - _S1002) * 0.25f * 0.31830987334251404f / (F32_pow((1.0f + _S1002 - 2.0f * g_0 * mu_0), (1.5f)));
}

__device__ float3  safeDivide(float3  a_7, float3  b_4)
{
    float3  _S1003 = a_7 / b_4;
    float3  _S1004 = make_float3 (0.0f);
    bool3  _S1005 = b_4 == _S1004;
    float3  _S1006 = _slang_select(_S1005, _S1004,_S1003);
    return _S1006;
}

static __device__ uint insertBits_0(uint e_2, uint newbits_0, uint offset_1, uint count_6)
{
    uint _S1007 = (1U << count_6) - 1U;
    return (e_2 & (~(_S1007 << offset_1))) | ((newbits_0 & _S1007) << offset_1);
}

__device__ Reservoir withEnd(Reservoir r_7, uint end_type_0, uint end_0, float3  f_5)
{
    Reservoir candidate_2 = r_7;
    uint _S1008 = insertBits_0(r_7.path, end_0, 0U, 5U);
    uint _S1009 = insertBits_0(_S1008, end_type_0, 12U, 3U);
    (&candidate_2)->path = _S1009;
    (&candidate_2)->f = f_5;
    return candidate_2;
}

__device__ float survivalProbability(float3  throughput_0, float density_1)
{
    return (F32_min(((F32_max(((F32_max((throughput_0.x), ((F32_max((throughput_0.y), (throughput_0.z)))))) / density_1), (0.0f)))), (1.0f)));
}

static __device__ float3  isotropic_0(uint random_state_9)
{
    Random _S1010 = pcg(random_state_9);
    Random _S1011 = pcg(_S1010.state);
    float _S1012 = 1.0f - 2.0f * _S1010.value;
    float _S1013 = (F32_sqrt(((F32_max((1.0f - _S1012 * _S1012), (0.0f))))));
    float _S1014 = 6.28318548202514648f * _S1011.value;
    return make_float3 (_S1013 * (F32_cos((_S1014))), _S1013 * (F32_sin((_S1014))), _S1012);
}

static __device__ float3  samplePhase_0(float g_1, float3  dir_9, uint random_state_10, float * pdf_5)
{
    bool _S1015 = (F32_abs((g_1))) < 0.00100000004749745f;
    if(_S1015)
    {
        *pdf_5 = 0.07957746833562851f;
        float3  _S1016 = isotropic_0(random_state_10);
        return _S1016;
    }
    Random _S1017 = pcg(random_state_10);
    Random _S1018 = pcg(_S1017.state);
    float _S1019 = g_1 * g_1;
    float _S1020 = 2.0f * g_1;
    float _S1021 = (1.0f - _S1019) / (1.0f - g_1 + _S1020 * _S1017.value);
    float _S1022 = clamp_1((1.0f + _S1019 - _S1021 * _S1021) / _S1020, -1.0f, 1.0f);
    float _S1023 = (F32_sqrt(((F32_max((1.0f - _S1022 * _S1022), (0.0f))))));
    float _S1024 = 6.28318548202514648f * _S1018.value;
    float _S1025 = phaseHG_0(g_1, _S1022);
    *pdf_5 = _S1025;
    float3  _S1026 = tangentToWorld(make_float3 (_S1023 * (F32_cos((_S1024))), _S1022, _S1023 * (F32_sin((_S1024)))), dir_9);
    float3  _S1027 = ((((_S1026)) * make_float3(rnorm3df(((_S1026)).x, ((_S1026)).y, ((_S1026)).z))));
    return _S1027;
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_1, float3  emissive_0, float roughness_0, float metallic_0, float transmission_0, float ior_0, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_2, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_2, float velvet_0, float3  toon_2)
{
    BSDFMaterial _S1028;
    (&_S1028)->albedo = albedo_1;
    (&_S1028)->emissive = emissive_0;
    (&_S1028)->roughness = roughness_0;
    (&_S1028)->metallic = metallic_0;
    (&_S1028)->transmission = transmission_0;
    (&_S1028)->ior = ior_0;
    (&_S1028)->absorption = absorption_0;
    (&_S1028)->specular_tint = specular_tint_0;
    (&_S1028)->specular_level = specular_level_0;
    (&_S1028)->translucent = translucent_0;
    (&_S1028)->sheen = sheen_2;
    (&_S1028)->sheen_roughness = sheen_roughness_0;
    (&_S1028)->anisotropy = anisotropy_0;
    (&_S1028)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S1028)->tangent = tangent_2;
    (&_S1028)->velvet = velvet_0;
    (&_S1028)->toon = toon_2;
    return _S1028;
}

static __device__ FKMedium Medium_x24init_0(float3  scatter_1, float3  extinction_1, float g_2)
{
    FKMedium _S1029;
    (&_S1029)->scatter = scatter_1;
    (&_S1029)->extinction = extinction_1;
    (&_S1029)->g = g_2;
    return _S1029;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_11, bool skip_0, uint random_state_11, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S1030;
    (&_S1030)->smooth_n = smooth_n_4;
    (&_S1030)->geometry_n = geometry_n_2;
    (&_S1030)->geometry_offset = geometry_offset_2;
    (&_S1030)->material = *material_11;
    (&_S1030)->skip = skip_0;
    (&_S1030)->random_state = random_state_11;
    (&_S1030)->coverage = coverage_0;
    (&_S1030)->encloses = encloses_0;
    (&_S1030)->volume = *volume_0;
    (&_S1030)->fills = fills_0;
    (&_S1030)->hair = hair_0;
    return _S1030;
}

static __device__ FKSurface emitting_0(FKSurface * surface_6, bool top_0)
{
    FKSurface lower_0 = *surface_6;
    float3  _S1031 = (&surface_6->material)->emissive;
    float3  _S1032 = make_float3 (0.0f);
    bool _S1033 = !top_0;
    float3  _S1034 = _slang_select(_S1033, _S1032,_S1031);
    (&(&lower_0)->material)->emissive = _S1034;
    return lower_0;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_7, float u_1)
{
    float _S1035 = surface_7->coverage;
    bool _S1036 = u_1 < _S1035;
    if(_S1036)
    {
        return *surface_7;
    }
    float3  _S1037 = make_float3 (0.0f);
    float3  _S1038 = make_float3 (1.0f);
    BSDFMaterial _S1039 = Material_x24init_0(_S1037, _S1037, 0.0f, 0.0f, 0.0f, 0.0f, _S1037, _S1038, 1.0f, _S1037, _S1037, 0.5f, 0.0f, 0.0f, _S1037, 0.0f, _S1037);
    BSDFMaterial material_12 = _S1039;
    (&material_12)->albedo = _S1038;
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
    bool _S1040 = transmission_1 > 0.0f;
    bool _S1041;
    if(_S1040)
    {
        _S1041 = true;
    }
    else
    {
        _S1041 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S1042;
    if(_S1041)
    {
        _S1042 = 1.0f;
    }
    else
    {
        _S1042 = -1.0f;
    }
    return _S1042;
}

static __device__ bool arrivesBehind_0(float3  dir_10, float3  n_9)
{
    return (dot_0(dir_10, n_9)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_8, float3  dir_11)
{
    float3  _S1043 = surface_8->geometry_n;
    float _S1044 = facingSign((&surface_8->material)->transmission, surface_8->geometry_n, dir_11);
    FKSurface faced_0 = *surface_8;
    float3  _S1045 = surface_8->smooth_n * make_float3 (_S1044);
    (&faced_0)->smooth_n = _S1045;
    float3  _S1046 = _S1043 * make_float3 (_S1044);
    (&faced_0)->geometry_n = _S1046;
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
    float3  _S1047 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_3) * log_0(_S1047));
}

__device__ float2  vertexEta(BSDFMaterial material_13, float n_dot_v_0)
{
    bool _S1048 = n_dot_v_0 < 0.0f;
    float _S1049 = _slang_select(_S1048, material_13.ior,1.0f);
    float _S1050 = _slang_select(_S1048, 1.0f,material_13.ior);
    return make_float2 (_S1049, _S1050);
}

__device__ bool neeDecision(BSDFMaterial material_14, float n_dot_v_1, float eta_i_9, float eta_o_9)
{
    float _S1051 = fresnel((F32_abs((n_dot_v_1))), eta_i_9, eta_o_9);
    float3  _S1052 = mix_0(make_float3 (_S1051), material_14.albedo, material_14.metallic);
    float _S1053 = rgb_to_greyscale(_S1052);
    float _S1054 = (F32_max(((1.0f - _S1053) * (1.0f - material_14.metallic) * (1.0f - material_14.transmission)), (0.0f)));
    bool _S1055 = _S1054 > 0.03999999910593033f;
    bool _S1056;
    if(_S1055)
    {
        _S1056 = true;
    }
    else
    {
        _S1056 = (material_14.roughness) > 0.20000000298023224f;
    }
    return _S1056;
}

static __device__ bool isTranslucent_0(BSDFMaterial * material_15)
{
    float _S1057 = rgb_to_greyscale(material_15->translucent);
    return _S1057 > 0.0f;
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
    MediumSides _S1058;
    (&_S1058)->behind = *behind_0;
    (&_S1058)->front = *front_0;
    (&_S1058)->fillings = fillings_1;
    (&_S1058)->face = face_1;
    return _S1058;
}

static __device__ MediumSides mediumSides_0(FKSurface * surface_9, FKMedium * medium_0, uint filling_0, float3  dir_12, FKMedium * outside_0)
{
    float3  _S1059 = surface_9->geometry_n;
    MediumSides _S1060 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_9->geometry_n);
    MediumSides sides_0 = _S1060;
    bool _S1061 = surface_9->encloses;
    if(_S1061)
    {
        (&sides_0)->behind = surface_9->volume;
        *&((&(&sides_0)->fillings)->x) = surface_9->fills;
        bool _S1062 = (dot_0(dir_12, _S1059)) > 0.0f;
        if(_S1062)
        {
            (&sides_0)->front = *outside_0;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_10, bool turned_0, float3  extinction_2, uint filling_1, float3  dir_13, uint depth_2, uint lobe_3, float length_3, float width_2, FKHit * own_3, bool fiber_1, FKMedium * outside_1)
{
    float3  _S1063 = surface_10->geometry_n;
    ShadowContext _S1064 = ShadowContext_x24init_0(extinction_2, extinction_2, make_uint2 (filling_1), surface_10->geometry_n, depth_2, lobe_3, true, length_3, width_2, own_3, fiber_1);
    bool _S1065 = surface_10->encloses;
    ShadowContext context_4;
    if(_S1065)
    {
        FKSurface faced_1 = *surface_10;
        float3  _S1066 = - _S1063;
        float3  _S1067 = _slang_select(turned_0, _S1066,_S1063);
        (&faced_1)->geometry_n = _S1067;
        FKMedium _S1068 = Medium_x24init_0(make_float3 (0.0f), extinction_2, 0.0f);
        FKSurface _S1069 = faced_1;
        FKMedium _S1070 = _S1068;
        MediumSides _S1071 = mediumSides_0(&_S1069, &_S1070, filling_1, dir_13, outside_1);
        ShadowContext _S1072 = ShadowContext_x24init_0(_S1071.behind.extinction, _S1071.front.extinction, _S1071.fillings, _S1063, depth_2, lobe_3, true, length_3, width_2, own_3, fiber_1);
        if(turned_0)
        {
            uint2  _S1073 = _S1071.fillings;
            ShadowContext _S1074 = ShadowContext_x24init_0(_S1071.front.extinction, _S1071.behind.extinction, uint2 {_S1073.y, _S1073.x}, _S1063, depth_2, lobe_3, true, length_3, width_2, own_3, fiber_1);
            context_4 = _S1074;
        }
        else
        {
            context_4 = _S1072;
        }
    }
    else
    {
        context_4 = _S1064;
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
    float3  _S1075 = light_2->dir;
    bool _S1076 = (dot_0(geometry_n_3, - in_dir_8) * dot_0(geometry_n_3, light_2->dir)) <= 0.0f;
    FixedArray<float3 , 5>  throughputs_1;
    FixedArray<float, 5>  pdfs_3;
    float3  _S1077 = BSDF(in_dir_8, _S1075, smooth_n_5, *material_16, eta_i_10, eta_o_10, _S1076, random_state_12, &throughputs_1, &pdfs_3);
    bool _S1078 = !competing_1;
    bool _S1079;
    if(_S1078)
    {
        _S1079 = true;
    }
    else
    {
        _S1079 = (light_2->density) == 0.0f;
    }
    if(_S1079)
    {
        return _S1077 * light_2->radiance;
    }
    float3  _S1080 = make_float3 (0.0f);
    uint i_23 = 0U;
    float3  weighted_0 = _S1080;
    for(;;)
    {
        if(i_23 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S1081 = (pdfs_3[i_23]) > 0.0f;
        if(_S1081)
        {
            float _S1082 = light_2->density;
            float _S1083 = pdfs_3[i_23] / light_2->density;
            float3  weighted_1 = weighted_0 + throughputs_1[i_23] * make_float3 (pdfs_3[i_23]) / make_float3 (_S1082 * (1.0f + _S1083 * _S1083));
            weighted_0 = weighted_1;
        }
        uint i_24 = i_23 + 1U;
        i_23 = i_24;
    }
    return weighted_0 * light_2->radiance * make_float3 (light_2->density);
}

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_1, uint random_state_13, bool refracted_3, uint lobe_4, float pdf_6)
{
    SampleBSDF _S1084;
    (&_S1084)->unit_direction = unit_direction_1;
    (&_S1084)->throughput = throughput_1;
    (&_S1084)->random_state = random_state_13;
    (&_S1084)->refracted = refracted_3;
    (&_S1084)->lobe = lobe_4;
    (&_S1084)->pdf = pdf_6;
    return _S1084;
}

__device__ __forceinline__ SampleBSDF sheenVelvetSample(float3  n_i_9, float n_i_dot_v_6, float alpha_15, BSDFMaterial material_17, BSDFLobes lobes_11, float eta_i_11, float eta_o_11, uint random_state_14)
{
    float3  _S1085 = make_float3 (1.0f);
    SampleBSDF _S1086 = SampleBSDF_x24init_0(_S1085, _S1085, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S1086;
    Random _S1087 = pcg(random_state_14);
    Random _S1088 = pcg(_S1087.state);
    (&sample_1)->random_state = _S1088.state;
    float _S1089 = _S1087.value;
    float _S1090 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1089 * _S1089))))));
    float _S1091 = 6.28318548202514648f * _S1088.value;
    float3  _S1092 = tangentToWorld(make_float3 (_S1090 * (F32_cos((_S1091))), _S1087.value, _S1090 * (F32_sin((_S1091)))), n_i_9);
    (&sample_1)->unit_direction = _S1092;
    (&sample_1)->lobe = 4U;
    float3  _S1093 = sheenVelvetBSDF((&sample_1)->unit_direction, n_i_9, alpha_15, material_17, lobes_11);
    (&sample_1)->throughput = _S1093;
    float _S1094 = sheenVelvetPDF(_S1087.value, 0.0f, n_i_dot_v_6, alpha_15, lobes_11, eta_i_11, eta_o_11);
    (&sample_1)->pdf = _S1094;
    return sample_1;
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S1095 = (F32_sqrt((random_1_0)));
    float _S1096 = 6.28318548202514648f * random_2_0;
    float _S1097 = _S1095 * (F32_cos((_S1096)));
    float _S1098 = _S1095 * (F32_sin((_S1096)));
    float _S1099 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1097 * _S1097 - _S1098 * _S1098))))));
    return make_float3 (_S1097, _S1099, _S1098);
}

__device__ __forceinline__ SampleBSDF diffuseSample(float u_2, float3  n_i_10, float n_i_dot_v_7, float alpha_16, BSDFMaterial material_18, BSDFLobes lobes_12, float eta_i_12, float eta_o_12, uint random_state_15)
{
    float3  _S1100 = make_float3 (1.0f);
    SampleBSDF _S1101 = SampleBSDF_x24init_0(_S1100, _S1100, 0U, false, 0U, 0.0f);
    SampleBSDF sample_2 = _S1101;
    Random _S1102 = pcg(random_state_15);
    Random _S1103 = pcg(_S1102.state);
    (&sample_2)->random_state = _S1103.state;
    float3  _S1104 = sampleCosWeightedHemisphere(_S1102.value, _S1103.value);
    bool _S1105 = u_2 < (lobes_12.p_diffuse * lobes_12.translucent_share);
    float _S1106 = _S1104.y;
    float _S1107 = - _S1106;
    float _S1108 = _slang_select(_S1105, _S1107,_S1106);
    float3  _S1109 = tangentToWorld(make_float3 (_S1104.x, _S1108, _S1104.z), n_i_10);
    (&sample_2)->unit_direction = _S1109;
    (&sample_2)->refracted = _S1105;
    (&sample_2)->lobe = 0U;
    float3  _S1110 = diffuseBSDF((&sample_2)->unit_direction, n_i_10, alpha_16, material_18, lobes_12);
    (&sample_2)->throughput = _S1110;
    float _S1111 = diffusePDF(_S1108, 0.0f, n_i_dot_v_7, alpha_16, lobes_12, eta_i_12, eta_o_12);
    (&sample_2)->pdf = _S1111;
    return sample_2;
}

__device__ __forceinline__ SampleBSDF toonSample(float3  n_i_11, float n_i_dot_v_8, float alpha_17, BSDFMaterial material_19, BSDFLobes lobes_13, float eta_i_13, float eta_o_13, uint random_state_16)
{
    float3  _S1112 = make_float3 (1.0f);
    SampleBSDF _S1113 = SampleBSDF_x24init_0(_S1112, _S1112, 0U, false, 0U, 0.0f);
    SampleBSDF sample_3 = _S1113;
    Random _S1114 = pcg(random_state_16);
    Random _S1115 = pcg(_S1114.state);
    (&sample_3)->random_state = _S1115.state;
    float _S1116 = _S1114.value * lobes_13.toon_norm / 6.28318548202514648f;
    float t_20;
    if(lobes_13.toon_glossy)
    {
        t_20 = (F32_acos((clamp_1(1.0f - _S1116, -1.0f, 1.0f))));
    }
    else
    {
        t_20 = (F32_asin(((F32_min(((F32_sqrt((2.0f * _S1116)))), (1.0f))))));
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
        float _S1117;
        if(t_20 < (lobes_13.toon_a))
        {
            _S1117 = 1.0f;
        }
        else
        {
            _S1117 = (F32_max((1.0f - (t_20 - lobes_13.toon_a) / (F32_max((lobes_13.toon_s), (0.0000152587890625f)))), (0.0f)));
        }
        float integral_1;
        if(lobes_13.toon_glossy)
        {
            integral_1 = 1.0f - (F32_cos(((F32_min((t_20), (lobes_13.toon_a))))));
        }
        else
        {
            float _S1118 = (F32_sin(((F32_min((t_20), (lobes_13.toon_a))))));
            integral_1 = _S1118 * _S1118 / 2.0f;
        }
        bool _S1119 = t_20 > (lobes_13.toon_a);
        bool _S1120;
        if(_S1119)
        {
            _S1120 = (lobes_13.toon_s) > 0.0f;
        }
        else
        {
            _S1120 = false;
        }
        float integral_2;
        if(_S1120)
        {
            if(lobes_13.toon_glossy)
            {
                float _S1121 = (F32_cos((lobes_13.toon_a)));
                float _S1122 = (F32_cos((t_20)));
                integral_2 = (1.0f + lobes_13.toon_a / lobes_13.toon_s) * (_S1121 - _S1122) - ((F32_sin((t_20))) - t_20 * _S1122 - ((F32_sin((lobes_13.toon_a))) - lobes_13.toon_a * _S1121)) / lobes_13.toon_s;
            }
            else
            {
                float _S1123 = 2.0f * lobes_13.toon_a;
                float _S1124 = (F32_cos((_S1123)));
                float _S1125 = 2.0f * t_20;
                float _S1126 = (F32_cos((_S1125)));
                integral_2 = (1.0f + lobes_13.toon_a / lobes_13.toon_s) * (_S1124 - _S1126) / 4.0f - ((F32_sin((_S1125))) / 8.0f - t_20 * _S1126 / 4.0f - ((F32_sin((_S1123))) / 8.0f - lobes_13.toon_a * _S1124 / 4.0f)) / lobes_13.toon_s;
            }
            float integral_3 = integral_1 + integral_2;
            integral_2 = integral_3;
        }
        else
        {
            integral_2 = integral_1;
        }
        float _S1127 = _S1117 * (F32_sin((t_20)));
        float _S1128;
        if(lobes_13.toon_glossy)
        {
            _S1128 = 1.0f;
        }
        else
        {
            _S1128 = (F32_cos((t_20)));
        }
        float _S1129 = _S1127 * _S1128;
        float _S1130 = (integral_2 - _S1116) / _S1129;
        bool _S1131 = _S1129 > 0.0f;
        float _S1132 = _slang_select(_S1131, _S1130,0.0f);
        float _S1133 = clamp_1(t_20 - _S1132, 0.0f, lobes_13.toon_b);
        int k_1 = k_0 + int(1);
        t_20 = _S1133;
        k_0 = k_1;
    }
    float _S1134 = 6.28318548202514648f * _S1115.value;
    float _S1135 = (F32_sin((t_20)));
    float3  _S1136 = tangentToWorld(make_float3 (_S1135 * (F32_cos((_S1134))), (F32_cos((t_20))), _S1135 * (F32_sin((_S1134)))), lobes_13.toon_axis);
    (&sample_3)->unit_direction = _S1136;
    bool _S1137 = (dot_0(n_i_11, (&sample_3)->unit_direction)) < 0.0f;
    (&sample_3)->refracted = _S1137;
    (&sample_3)->lobe = 6U;
    float3  _S1138 = toonBSDF((&sample_3)->unit_direction, n_i_11, alpha_17, material_19, lobes_13);
    (&sample_3)->throughput = _S1138;
    float _S1139 = toonPDF(dot_0(n_i_11, (&sample_3)->unit_direction), dot_0((&sample_3)->unit_direction, lobes_13.toon_axis), n_i_dot_v_8, alpha_17, lobes_13, eta_i_13, eta_o_13);
    (&sample_3)->pdf = _S1139;
    return sample_3;
}

__device__ __forceinline__ SampleBSDF refractSample(float3  ggx_n_3, float3  n_i_12, float n_i_dot_v_9, float alpha_18, BSDFMaterial material_20, BSDFLobes lobes_14, float eta_i_14, float eta_o_14, uint random_state_17)
{
    float3  _S1140 = make_float3 (1.0f);
    SampleBSDF _S1141 = SampleBSDF_x24init_0(_S1140, _S1140, 0U, false, 0U, 0.0f);
    SampleBSDF sample_4 = _S1141;
    (&sample_4)->unit_direction = lobes_14.refracted;
    (&sample_4)->random_state = random_state_17;
    (&sample_4)->refracted = true;
    (&sample_4)->lobe = 1U;
    float3  _S1142 = refractBSDF((&sample_4)->unit_direction, n_i_12, alpha_18, material_20, lobes_14);
    (&sample_4)->throughput = _S1142;
    float _S1143 = refractPDF(0.0f, dot_0((&sample_4)->unit_direction, ggx_n_3), n_i_dot_v_9, alpha_18, lobes_14, eta_i_14, eta_o_14);
    (&sample_4)->pdf = _S1143;
    return sample_4;
}

static __device__ float3  reflect_0(float3  i_25, float3  n_10)
{
    return i_25 - make_float3 (2.0f * dot_0(n_10, i_25)) * n_10;
}

__device__ __forceinline__ SampleBSDF reflectSample(float3  in_dir_9, float3  ggx_n_4, float3  n_i_13, float n_i_dot_v_10, float alpha_19, BSDFMaterial material_21, BSDFLobes lobes_15, float eta_i_15, float eta_o_15, uint random_state_18)
{
    float3  _S1144 = make_float3 (1.0f);
    SampleBSDF _S1145 = SampleBSDF_x24init_0(_S1144, _S1144, 0U, false, 0U, 0.0f);
    SampleBSDF sample_5 = _S1145;
    float3  _S1146 = reflect_0(in_dir_9, ggx_n_4);
    float3  _S1147 = ((((_S1146)) * make_float3(rnorm3df(((_S1146)).x, ((_S1146)).y, ((_S1146)).z))));
    (&sample_5)->unit_direction = _S1147;
    (&sample_5)->random_state = random_state_18;
    (&sample_5)->lobe = 2U;
    float3  _S1148 = reflectBSDF((&sample_5)->unit_direction, n_i_13, alpha_19, material_21, lobes_15);
    (&sample_5)->throughput = _S1148;
    float _S1149 = reflectPDF(0.0f, 0.0f, n_i_dot_v_10, alpha_19, lobes_15, eta_i_15, eta_o_15);
    (&sample_5)->pdf = _S1149;
    return sample_5;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_10, float3  n_11, BSDFMaterial material_22, float eta_i_16, float eta_o_16, uint random_init_0, float2  screen_space_0)
{
    uint random_state_19 = random_init_0;
    float3  _S1150 = negate_0(in_dir_10);
    float _S1151 = dot_0(n_11, _S1150);
    float _S1152 = sign_0(_S1151);
    float3  n_i_14 = n_11 * make_float3 (_S1152);
    float _S1153 = (F32_abs((_S1151)));
    float _S1154 = material_22.roughness;
    float _S1155 = _S1154 * _S1154;
    AnisotropicFrame _S1156 = anisotropicFrame(material_22, n_i_14);
    SheenProfile _S1157 = sheenProfile(_S1150, n_i_14, material_22);
    float3  _S1158 = sampleHalfVector(_S1150, n_i_14, _S1155, _S1156, &random_state_19);
    BSDFLobes _S1159 = bsdfLobes(in_dir_10, _S1150, n_i_14, _S1158, material_22, eta_i_16, eta_o_16, _S1156, _S1157);
    BSDFLobes lobes_16 = _S1159;
    float _S1160 = translucentShare(material_22);
    (&lobes_16)->translucent_share = _S1160;
    Random _S1161 = pcg(random_state_19);
    random_state_19 = _S1161.state;
    bool _S1162 = (_S1161.value) < ((&lobes_16)->p_sheen_velvet);
    if(_S1162)
    {
        SampleBSDF _S1163 = sheenVelvetSample(n_i_14, _S1153, _S1155, material_22, lobes_16, eta_i_16, eta_o_16, random_state_19);
        return _S1163;
    }
    float _S1164 = _S1161.value - (&lobes_16)->p_sheen_velvet;
    bool _S1165 = _S1164 < ((&lobes_16)->p_diffuse);
    if(_S1165)
    {
        SampleBSDF _S1166 = diffuseSample(_S1164, n_i_14, _S1153, _S1155, material_22, lobes_16, eta_i_16, eta_o_16, random_state_19);
        return _S1166;
    }
    bool _S1167 = _S1164 < ((&lobes_16)->p_diffuse + (&lobes_16)->p_toon);
    if(_S1167)
    {
        SampleBSDF _S1168 = toonSample(n_i_14, _S1153, _S1155, material_22, lobes_16, eta_i_16, eta_o_16, random_state_19);
        return _S1168;
    }
    float _S1169 = (&lobes_16)->p_toon;
    bool _S1170 = (_S1164 - _S1169) < ((&lobes_16)->p_diffuse + (&lobes_16)->p_refract);
    if(_S1170)
    {
        SampleBSDF _S1171 = refractSample(_S1158, n_i_14, _S1153, _S1155, material_22, lobes_16, eta_i_16, eta_o_16, random_state_19);
        return _S1171;
    }
    SampleBSDF _S1172 = reflectSample(in_dir_10, _S1158, n_i_14, _S1153, _S1155, material_22, lobes_16, eta_i_16, eta_o_16, random_state_19);
    return _S1172;
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
    bool _S1173;
    bool _S1174;
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
    int _S1175;
    Shift ended_0;
    float density_3;
    float spread_2;
    float width_4;
    float sky_pdf_1;
    float spread_3;
    float width_5;
    uint b_6;
    float3  _S1176 = make_float3 (0.0f);
    Shift _S1177 = Shift_x24init_0(_S1176, 0.0f);
    uint _S1178 = r_8->path;
    uint _S1179 = extractBits_0(r_8->path, 0U, 5U);
    uint _S1180 = extractBits_0(_S1178, 5U, 5U);
    uint _S1181 = extractBits_0(_S1178, 10U, 2U);
    uint _S1182 = extractBits_0(_S1178, 12U, 3U);
    bool passes_0;
    if(replay_1)
    {
        bool _S1183 = _S1182 >= 3U;
        uint _S1184 = _slang_select(_S1183, 1U,0U);
        uint _S1185 = _S1179 + _S1184;
        uint _S1186 = (fcptMaxBounces());
        passes_0 = _S1185 > _S1186;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S1177;
    }
    uint _S1187 = _S1180 - 1U;
    bool _S1188 = _S1182 == 3U;
    uint _S1189 = _slang_select(_S1188, 1U,0U);
    uint _S1190 = _S1179 + _S1189;
    bool _S1191 = _S1181 == 0U;
    uint _S1192 = _slang_select(_S1191, _S1190,_S1187);
    FKHit _S1193 = (fcptReservoirHit((*r_8)));
    float3  _S1194 = dom_7->x0;
    float3  _S1195 = dom_7->x1 - dom_7->x0;
    float3  _S1196 = ((((_S1195)) * make_float3(rnorm3df(((_S1195)).x, ((_S1195)).y, ((_S1195)).z))));
    FKRay _S1197 = Ray_x24init_0(dom_7->x1, _S1196);
    FKRay ray_2 = _S1197;
    FKHit hit_4 = dom_7->hit;
    float3  scatter_in_0 = _S1176;
    float3  throughput_3 = make_float3 (1.0f);
    float3  weight_1 = throughput_3;
    float3  glowed_0 = _S1176;
    float3  extinction_in_0 = _S1176;
    float g_in_0 = 0.0f;
    uint filling_2 = 4294967295U;
    float _S1198 = dom_7->spread;
    float _S1199 = dom_7->width;
    float _S1200 = length_0(_S1195);
    NEEVertex _S1201 = NEEVertex_x24init_0(true, 0.0f, _S1176, _S1176, _S1176);
    NEEVertex nee_vertex_0 = _S1201;
    Vertex _S1202 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_0 = _S1202;
    Reservoir _S1203 = (Reservoir{});
    Reservoir chain_0 = _S1203;
    uint _S1204 = r_8->seed;
    (&chain_0)->seed = r_8->seed;
    (&ray_2)->origin = _S1194;
    (&hit_4)->distance = _S1200;
    FKMedium _S1205 = (fcptCameraMedium(((&ray_2)->unit_direction), ((&hit_4)->distance), (&filling_2)));
    uint _S1206 = filling_2;
    bool _S1207 = (fcptVaryingUsed());
    uint _S1208 = _slang_select(_S1207, _S1206,4294967295U);
    filling_2 = _S1208;
    scatter_in_0 = _S1205.scatter;
    extinction_in_0 = _S1205.extinction;
    g_in_0 = _S1205.g;
    Reservoir _S1209 = chain_0;
    uint _S1210 = filling_2;
    for(;;)
    {
        bool _S1211 = (fcptVaryingUsed());
        if(_S1211)
        {
            passes_0 = _S1210 != 4294967295U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            float _S1212 = (fcptMajorant((_S1210)));
            spread_1 = _S1212;
        }
        else
        {
            spread_1 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
        }
        if(replay_1)
        {
            turned_1 = 4294967295U == _S1192;
        }
        else
        {
            turned_1 = false;
        }
        if(turned_1)
        {
            turned_1 = _S1181 == 1U;
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
            ended_0 = _S1177;
            sky_pdf_0 = 0.0f;
            spread_1 = _S1198;
            width_3 = _S1199;
            density_2 = 1.0f;
            throughput_2 = throughput_3;
            b_5 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S1213 = (&prev_0)->rough;
        if(_S1213)
        {
            turned_1 = !(spread_1 > 0.0f);
        }
        else
        {
            turned_1 = false;
        }
        (&prev_0)->rough = turned_1;
        uint _S1214 = stream(_S1204, 384U);
        uint tracking_0 = _S1214;
        weight_1 = throughput_3;
        glowed_0 = _S1176;
        b_5 = 4294967295U;
        throughput_2 = throughput_3;
        density_2 = 1.0f;
        threshold_0 = _S1198;
        width_3 = _S1199;
        sky_pdf_0 = 0.0f;
        for(;;)
        {
            if(((&hit_4)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S1175 = int(1);
                break;
            }
            uint _S1215 = b_5 + 320U;
            bool _S1216 = b_5 == 4294967295U;
            uint _S1217 = _slang_select(_S1216, 384U,_S1215);
            uint _S1218 = stream(_S1204, _S1217);
            Random _S1219 = pcg(_S1218);
            float _S1220 = - (F32_log((1.0f - _S1219.value))) / spread_1;
            if(passes_0)
            {
                float3  _S1221 = (&ray_2)->origin;
                float3  _S1222 = (&ray_2)->unit_direction;
                float _S1223 = (&hit_4)->distance;
                uint _S1224 = _slang_select(_S1216, 0U,b_5);
                uint _S1225 = (&prev_0)->lobe;
                uint _S1226 = _slang_select(_S1216, 3U,_S1225);
                float _S1227 = (fcptTrackMedium((_S1210), (_S1221), (_S1222), (_S1223), (&tracking_0), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1224), (_S1226), (_S1216)));
                geometry_density_0 = _S1227;
            }
            else
            {
                geometry_density_0 = _S1220;
            }
            bool _S1228 = !(geometry_density_0 < ((&hit_4)->distance));
            if(_S1228)
            {
                _S1175 = int(1);
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
                float3  _S1229 = throughput_2 * glowed_0 / make_float3 (density_2);
                float3  _S1230 = sel_7->glow + _S1229;
                sel_7->glow = _S1230;
            }
            else
            {
            }
            glowed_0 = _S1176;
            uint b_7 = b_5 + 1U;
            float3  _S1231 = (&ray_2)->origin + make_float3 (geometry_density_0) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S1231;
            float3  _S1232 = flightWeight_0(scatter_in_0, extinction_in_0, spread_1, geometry_density_0, true);
            float3  _S1233 = weight_1;
            float3  _S1234 = _slang_select(passes_0, _S1233,_S1232);
            float3  throughput_4 = throughput_2 * _S1234;
            uint _S1235 = stream(_S1204, b_7 + 320U);
            tracking_0 = _S1235;
            weight_1 = throughput_3;
            float width_6 = width_3 + threshold_0 * geometry_density_0;
            float _S1236 = threshold_0 + 3.14159274101257324f;
            bool _S1237 = !replay_1;
            if(_S1237)
            {
                is_inside_5 = true;
            }
            else
            {
                bool _S1238 = b_7 == _S1192;
                if(_S1238)
                {
                    is_inside_5 = !passes_0;
                }
                else
                {
                    is_inside_5 = false;
                }
            }
            TreeSample _S1239 = TreeSample_x24init_0(_S1176, _S1176, 0.0f, 0U);
            if(is_inside_5)
            {
                float3  _S1240 = (&ray_2)->origin;
                float3  _S1241 = (&ray_2)->unit_direction;
                float3  _S1242 = (&ray_2)->unit_direction;
                uint _S1243 = stream(_S1204, b_7 + 64U);
                float3  _S1244 = extinction_in_0;
                float3  _S1245 = extinction_in_0;
                uint2  _S1246 = make_uint2 (_S1210);
                float3  _S1247 = (&ray_2)->unit_direction;
                uint _S1248 = arrivalLobe_0(b_7, (&prev_0)->lobe);
                FKHit _S1249 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S1250 = _S1249;
                ShadowContext _S1251 = ShadowContext_x24init_0(_S1244, _S1245, _S1246, _S1247, b_7, _S1248, false, geometry_density_0, width_6, &_S1250, false);
                ShadowContext _S1252 = _S1251;
                TreeSample _S1253 = sampleLightTree_0(_S1240, _S1241, _S1242, 0.0f, true, _S1243, &_S1252);
                light_3 = _S1253;
            }
            else
            {
                light_3 = _S1239;
            }
            float _S1254 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_3.dir));
            uint _S1255 = (fcptMaxBounces());
            bool _S1256 = b_7 < _S1255;
            if(_S1256)
            {
                viewed_0 = (light_3.density) > 0.0f;
            }
            else
            {
                viewed_0 = false;
            }
            float _S1257 = _slang_select(viewed_0, _S1254,0.0f);
            float3  _S1258 = throughput_4 * light_3.radiance;
            float _S1259 = powerHeuristic(light_3.density, _S1257);
            float3  _S1260 = _S1258 * make_float3 (_S1254 * _S1259);
            float3  _S1261 = _slang_select(is_inside_5, _S1260,_S1176);
            if(replay_1)
            {
                _S1173 = b_7 == _S1192;
            }
            else
            {
                _S1173 = false;
            }
            if(_S1173)
            {
                bool _S1262 = _S1181 == 2U;
                if(_S1262)
                {
                    float _S1263 = rgb_to_greyscale(_S1261);
                    passes_0 = _S1263 > 0.0f;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S1264 = Shift_x24init_0(_S1261, 1.0f);
                    _S1175 = int(0);
                    ended_0 = _S1264;
                    spread_1 = _S1236;
                    geometry_density_0 = width_6;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_7;
                    break;
                }
                _S1175 = int(0);
                ended_0 = _S1177;
                spread_1 = _S1236;
                geometry_density_0 = width_6;
                chain_throughput_0 = throughput_4;
                layer_0 = b_7;
                break;
            }
            if(_S1237)
            {
                Reservoir candidate_3 = _S1209;
                uint _S1265 = extractBits_0(_S1209.path, 10U, 2U);
                bool _S1266 = _S1265 == 1U;
                if(_S1266)
                {
                    float3  _S1267 = safeDivide(_S1261, _S1176);
                    (&candidate_3)->radiance = _S1267;
                }
                else
                {
                    uint _S1268 = insertBits_0(0U, b_7 + 1U, 5U, 5U);
                    uint _S1269 = insertBits_0(_S1268, 2U, 10U, 2U);
                    (&candidate_3)->path = _S1269;
                }
                Reservoir _S1270 = withEnd(candidate_3, 0U, b_7, _S1261);
                offer(sel_7, _S1270, _S1261 * make_float3 (scale_3) / make_float3 (density_2));
                float _S1271 = survivalProbability(throughput_4, density_2);
                uint _S1272 = stream(_S1204, b_7 + 128U);
                Random _S1273 = pcg(_S1272);
                bool _S1274 = _S1271 < (_S1273.value);
                if(_S1274)
                {
                    _S1174 = true;
                }
                else
                {
                    uint _S1275 = (fcptMaxBounces());
                    _S1174 = b_7 >= _S1275;
                }
                if(_S1174)
                {
                    _S1175 = int(0);
                    ended_0 = _S1177;
                    spread_1 = _S1236;
                    geometry_density_0 = width_6;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_7;
                    break;
                }
                float _S1276 = density_2 * _S1271;
                density_2 = _S1276;
            }
            else
            {
            }
            float phase_pdf_0 = 0.0f;
            uint _S1277 = stream(_S1204, b_7);
            float3  _S1278 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1277, &phase_pdf_0);
            (&ray_2)->unit_direction = _S1278;
            NEEVertex _S1279 = NEEVertex_x24init_0(false, phase_pdf_0, (&ray_2)->origin, _S1176, (&ray_2)->origin);
            nee_vertex_0 = _S1279;
            Vertex _S1280 = Vertex_x24init_0(false, 0U, 0.0f, 1.0f, false);
            prev_0 = _S1280;
            float _S1281 = (&prev_0)->pdf;
            FKRay _S1282 = ray_2;
            FKHit _S1283 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S1284 = (fcptTraverseInstanceBVH((_S1282), (true), (4.294967296e+09f), (false), (_S1283), (false)));
            hit_4 = _S1284;
            b_5 = b_7;
            throughput_2 = throughput_4;
            threshold_0 = _S1236;
            width_3 = width_6;
            sky_pdf_0 = _S1281;
        }
        if(_S1175 != int(1))
        {
            width_3 = geometry_density_0;
            throughput_2 = chain_throughput_0;
            b_5 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S1177;
        spread_1 = threshold_0;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    bool _S1285 = b_5 == 4294967295U;
    bool _S1286 = ((&hit_4)->instance_index) == 4294967295U;
    if(_S1286)
    {
        bool _S1287 = !(&nee_vertex_0)->none;
        float _S1288 = _slang_select(_S1287, sky_pdf_0,0.0f);
        float _S1289 = escapeWeight_0(_S1288, (&ray_2)->unit_direction);
        float3  _S1290 = environment_0((&ray_2)->unit_direction, b_5, (&prev_0)->lobe);
        float3  _S1291 = throughput_2 * _S1290;
        if(replay_1)
        {
            bool _S1292 = b_5 == _S1192;
            if(_S1292)
            {
                passes_0 = _S1181 == 3U;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                return Shift_x24init_0(_S1291 * make_float3 (_S1289) / make_float3 (r_8->jac), density_2 / r_8->jac);
            }
            if(_S1191)
            {
                passes_0 = _S1188;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                passes_0 = b_5 == _S1179;
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
                return Shift_x24init_0(_S1291 * make_float3 (_S1289), 1.0f);
            }
            return _S1177;
        }
        Reservoir candidate_4 = chain_0;
        uint _S1293 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1294 = _S1293 == 1U;
        if(_S1294)
        {
            uint _S1295 = extractBits_0((&chain_0)->path, 5U, 5U);
            bool _S1296 = _S1295 == b_5;
            float _S1297 = _slang_select(_S1296, 1.0f,_S1289);
            float3  _S1298 = safeDivide(_S1291 * make_float3 (_S1297), _S1176);
            (&candidate_4)->radiance = _S1298;
        }
        else
        {
            bool _S1299 = (&prev_0)->rough;
            if(_S1299)
            {
                uint _S1300 = insertBits_0(0U, b_5 + 1U, 5U, 5U);
                uint _S1301 = insertBits_0(_S1300, 3U, 10U, 2U);
                uint _S1302 = insertBits_0(_S1301, (&prev_0)->lobe, 15U, 3U);
                bool _S1303 = (&prev_0)->inside;
                uint _S1304 = _slang_select(_S1303, 1U,0U);
                uint _S1305 = insertBits_0(_S1302, _S1304, 22U, 1U);
                (&candidate_4)->path = _S1305;
                (&candidate_4)->jac = (&prev_0)->pdf;
                (&candidate_4)->dir = (&ray_2)->unit_direction;
            }
        }
        float3  _S1306 = _S1291 * make_float3 (_S1289);
        Reservoir _S1307 = withEnd(candidate_4, 3U, b_5, _S1306);
        offer(sel_7, _S1307, _S1306 * make_float3 (scale_3) / make_float3 (density_2));
        return _S1177;
    }
    float3  _S1308 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
    (&ray_2)->origin = _S1308;
    bool _S1309 = (fcptVaryingUsed());
    if(_S1309)
    {
        passes_0 = filling_2 != 4294967295U;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        bool _S1310 = !replay_1;
        if(_S1310)
        {
            float3  _S1311 = throughput_2 * glowed_0 / make_float3 (density_2);
            float3  _S1312 = sel_7->glow + _S1311;
            sel_7->glow = _S1312;
        }
        float3  _S1313 = throughput_2 * weight_1;
        throughput_2 = _S1313;
    }
    else
    {
        float3  _S1314 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
        float3  _S1315 = throughput_2 * _S1314;
        throughput_2 = _S1315;
    }
    float _S1316 = width_3 + spread_1 * (&hit_4)->distance;
    uint _S1317 = b_5 + 1U;
    b_5 = _S1317;
    layer_0 = 0U;
    width_3 = _S1316;
    passes_0 = false;
    threshold_0 = 0.0f;
    turned_1 = false;
    is_inside_5 = false;
    chain_throughput_0 = _S1176;
    float3  reconnection_0 = _S1176;
    viewed_0 = _S1285;
    for(;;)
    {
        bool _S1318 = ((&hit_4)->is_point_light) == 1U;
        if(replay_1)
        {
            _S1173 = _S1181 == 1U;
        }
        else
        {
            _S1173 = false;
        }
        if(_S1173)
        {
            _S1174 = b_5 == _S1180;
        }
        else
        {
            _S1174 = false;
        }
        bool _S1319;
        if(_S1174)
        {
            bool _S1320 = ((&hit_4)->instance_index) != (_S1193.instance_index);
            if(_S1320)
            {
                _S1319 = true;
            }
            else
            {
                _S1319 = ((&hit_4)->triangle_index) != (_S1193.triangle_index);
            }
        }
        else
        {
            _S1319 = false;
        }
        if(_S1319)
        {
            return _S1177;
        }
        FKMedium _S1321 = Medium_x24init_0(_S1176, _S1176, 0.0f);
        BSDFMaterial _S1322 = Material_x24init_0(_S1176, _S1176, 0.0f, 0.0f, 0.0f, 0.0f, _S1176, throughput_3, 1.0f, _S1176, _S1176, 0.5f, 0.0f, 0.0f, _S1176, 0.0f, _S1176);
        FKMedium _S1323 = _S1321;
        FKSurface _S1324 = Surface_x24init_0(_S1176, _S1176, 0.0f, &_S1322, false, 0U, 1.0f, false, &_S1323, 4294967295U, _S1176);
        bool _S1325 = !_S1318;
        bool scatter_2;
        bool is_inside_6;
        float3  throughput_5;
        FKSurface surface_12;
        if(_S1325)
        {
            uint _S1326 = stream(_S1204, b_5);
            uint _S1327 = arrivalLobe_0(b_5, (&prev_0)->lobe);
            FKSurface _S1328 = (fcptSurfaceAtPath((hit_4), ((&ray_2)->origin), (_S1326), (width_3), (layer_0), (b_5), (_S1327), ((&ray_2)->unit_direction)));
            bool _S1329 = !passes_0;
            FKSurface _S1330 = _S1328;
            FKSurface _S1331 = emitting_0(&_S1330, _S1329);
            uint _S1332 = stream(_S1204, b_5 + 256U);
            Random _S1333 = pcg(_S1332);
            FKSurface _S1334 = _S1331;
            FKSurface _S1335 = uncovered_0(&_S1334, _S1333.value);
            float _S1336 = facingSign(_S1335.material.transmission, _S1335.geometry_n, (&ray_2)->unit_direction);
            bool _S1337 = _S1336 < 0.0f;
            bool _S1338 = (_S1335.material.transmission) > 0.0f;
            if(_S1338)
            {
                bool _S1339 = arrivesBehind_0((&ray_2)->unit_direction, _S1335.geometry_n);
                scatter_2 = _S1339;
            }
            else
            {
                scatter_2 = false;
            }
            FKSurface _S1340 = _S1335;
            FKSurface _S1341 = facingRay_0(&_S1340, (&ray_2)->unit_direction);
            if(passes_0)
            {
                bool _S1342 = arrivesBehind_0((&ray_2)->unit_direction, _S1341.geometry_n);
                is_inside_6 = _S1342;
            }
            else
            {
                is_inside_6 = scatter_2;
            }
            if(is_inside_6)
            {
                float3  _S1343 = beerLambert((&hit_4)->distance, _S1341.material.absorption);
                float3  _S1344 = throughput_2 * _S1343;
                throughput_5 = _S1344;
            }
            else
            {
                throughput_5 = throughput_2;
            }
            bool _S1345 = !_S1341.skip;
            float geometry_density_1 = (F32_abs((dot_0(_S1341.geometry_n, (&ray_2)->unit_direction)))) / ((&hit_4)->distance * (&hit_4)->distance);
            bool _S1346 = b_5 == _S1317;
            if(_S1346)
            {
                float _S1347 = 0.00251327408477664f / geometry_density_1;
                geometry_density_0 = _S1347;
            }
            else
            {
                geometry_density_0 = threshold_0;
            }
            float _S1348 = geometry_density_0;
            scatter_2 = _S1345;
            geometry_density_0 = geometry_density_1;
            threshold_0 = _S1348;
            surface_12 = _S1341;
            turned_1 = _S1337;
        }
        else
        {
            scatter_2 = false;
            geometry_density_0 = 0.0f;
            surface_12 = _S1324;
            throughput_5 = throughput_2;
            is_inside_6 = is_inside_5;
        }
        bool _S1349;
        if(scatter_2)
        {
            _S1349 = (&prev_0)->rough;
        }
        else
        {
            _S1349 = false;
        }
        bool _S1350;
        if(_S1349)
        {
            _S1350 = ((&prev_0)->pdf * geometry_density_0 * threshold_0) <= 1.0f;
        }
        else
        {
            _S1350 = false;
        }
        FKSurface _S1351 = surface_12;
        FKSurface _S1352 = surface_12;
        float _S1353 = dot_0(surface_12.smooth_n, - (&ray_2)->unit_direction);
        float2  _S1354 = vertexEta(_S1351.material, _S1353);
        bool _S1355;
        if(scatter_2)
        {
            bool _S1356 = neeDecision(_S1351.material, _S1353, _S1354.x, _S1354.y);
            _S1355 = _S1356;
        }
        else
        {
            _S1355 = false;
        }
        bool _S1357;
        if(passes_0)
        {
            _S1357 = true;
        }
        else
        {
            _S1357 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S1357)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S1355;
        }
        bool _S1358 = (fcptHairUsed());
        bool _S1359;
        if(_S1358)
        {
            float3  _S1360 = surface_12.hair;
            _S1359 = (dot_0(_S1360, _S1360)) > 0.0f;
        }
        else
        {
            _S1359 = false;
        }
        bool _S1361;
        if(_S1359)
        {
            _S1361 = true;
        }
        else
        {
            BSDFMaterial _S1362 = _S1351.material;
            bool _S1363 = isTranslucent_0(&_S1362);
            _S1361 = _S1363;
        }
        bool _S1364;
        if(_S1361)
        {
            _S1364 = true;
        }
        else
        {
            bool _S1365 = (_S1351.material.transmission) > 0.0f;
            if(_S1365)
            {
                uint _S1366 = (fcptLayers((hit_4)));
                _S1364 = _S1366 == 1U;
            }
            else
            {
                _S1364 = false;
            }
        }
        float3  emission_0;
        if(_S1318)
        {
            float3  _S1367 = (fcptCalculatePointLightContrib(((&hit_4)->instance_index)));
            emission_0 = _S1367;
        }
        else
        {
            emission_0 = _S1351.material.emissive;
        }
        bool _S1368 = !replay_1;
        bool _S1369;
        if(_S1368)
        {
            _S1369 = true;
        }
        else
        {
            _S1369 = b_5 >= _S1192;
        }
        bool _S1370;
        if(_S1369)
        {
            float _S1371 = rgb_to_greyscale(emission_0);
            _S1370 = _S1371 > 0.0f;
        }
        else
        {
            _S1370 = false;
        }
        float3  emission_1;
        if(_S1370)
        {
            NEEVertex _S1372 = nee_vertex_0;
            FKHit _S1373 = hit_4;
            float _S1374 = emissionWeight_0(&_S1372, &_S1373, (&ray_2)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S1374);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S1375;
        if(replay_1)
        {
            _S1375 = _S1181 == 1U;
        }
        else
        {
            _S1375 = false;
        }
        bool _S1376;
        if(_S1375)
        {
            _S1376 = b_5 > _S1180;
        }
        else
        {
            _S1376 = false;
        }
        bool _S1377;
        if(_S1376)
        {
            _S1377 = b_5 == _S1179;
        }
        else
        {
            _S1377 = false;
        }
        bool _S1378;
        if(_S1377)
        {
            bool _S1379 = _S1182 == 1U;
            if(_S1379)
            {
                _S1378 = true;
            }
            else
            {
                _S1378 = _S1182 == 2U;
            }
        }
        else
        {
            _S1378 = false;
        }
        if(_S1378)
        {
            bool _S1380 = _S1318 != (_S1182 == 2U);
            if(_S1380)
            {
                return _S1177;
            }
            return Shift_x24init_0(throughput_5 * emission_1 / make_float3 (r_8->jac), density_2 / r_8->jac);
        }
        uint _S1381 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1382 = _S1381 == 1U;
        Reservoir here_0 = chain_0;
        uint _S1383 = insertBits_0(0U, b_5, 5U, 5U);
        uint _S1384 = insertBits_0(_S1383, 1U, 10U, 2U);
        uint _S1385 = insertBits_0(_S1384, (&prev_0)->lobe, 15U, 3U);
        bool _S1386 = (&prev_0)->inside;
        uint _S1387 = _slang_select(_S1386, 1U,0U);
        uint _S1388 = insertBits_0(_S1385, _S1387, 22U, 1U);
        (&here_0)->path = _S1388;
        float _S1389 = (&prev_0)->pdf * geometry_density_0;
        (&here_0)->jac = _S1389;
        fcptWithReservoirHit((&here_0), (&hit_4));
        bool _S1390;
        if(replay_1)
        {
            _S1390 = _S1181 == 1U;
        }
        else
        {
            _S1390 = false;
        }
        bool _S1391;
        if(_S1390)
        {
            _S1391 = b_5 == _S1180;
        }
        else
        {
            _S1391 = false;
        }
        bool _S1392 = b_5 == _S1192;
        bool _S1393;
        if(_S1392)
        {
            bool _S1394 = !scatter_2;
            if(_S1394)
            {
                _S1393 = true;
            }
            else
            {
                bool _S1395 = _S1181 != 1U;
                if(_S1395)
                {
                    _S1393 = _S1181 != 3U;
                }
                else
                {
                    _S1393 = false;
                }
            }
        }
        else
        {
            _S1393 = false;
        }
        bool _S1396;
        if(_S1393)
        {
            _S1396 = _S1181 == 2U;
        }
        else
        {
            _S1396 = false;
        }
        bool _S1397;
        if(_S1396)
        {
            _S1397 = !_S1350;
        }
        else
        {
            _S1397 = false;
        }
        bool _S1398;
        if(_S1397)
        {
            _S1398 = _S1182 != 4U;
        }
        else
        {
            _S1398 = false;
        }
        bool _S1399 = _S1180 == _S1179;
        bool _S1400;
        if(_S1399)
        {
            _S1400 = _S1182 == 0U;
        }
        else
        {
            _S1400 = false;
        }
        bool _S1401;
        if(_S1400)
        {
            _S1401 = ((&hit_4)->instance_index) == (_S1193.instance_index);
        }
        else
        {
            _S1401 = false;
        }
        bool _S1402;
        if(_S1401)
        {
            _S1402 = ((&hit_4)->triangle_index) == (_S1193.triangle_index);
        }
        else
        {
            _S1402 = false;
        }
        bool _S1403;
        if(_S1402)
        {
            _S1403 = _S1350;
        }
        else
        {
            _S1403 = false;
        }
        bool _S1404 = _slang_select(_S1391, _S1403,_S1398);
        bool _S1405;
        if(nee_0)
        {
            _S1405 = _slang_select(replay_1, _S1404,scatter_2);
        }
        else
        {
            _S1405 = false;
        }
        TreeSample _S1406 = TreeSample_x24init_0(_S1176, _S1176, 0.0f, 0U);
        uint2  _S1407 = make_uint2 (0U);
        float2  _S1408 = make_float2 (0.0f);
        FKHit _S1409 = Hit_x24init_0(_S1408, 4294967295U, 0U, 0U, 0.0f);
        FKHit _S1410 = _S1409;
        ShadowContext _S1411 = ShadowContext_x24init_0(_S1176, _S1176, _S1407, _S1176, 0U, 0U, false, 0.0f, 0.0f, &_S1410, false);
        bool _S1412;
        if(nee_0)
        {
            _S1412 = _S1369;
        }
        else
        {
            _S1412 = false;
        }
        ShadowContext context_5;
        if(_S1412)
        {
            uint _S1413 = arrivalLobe_0(b_5, (&prev_0)->lobe);
            FKMedium _S1414 = (fcptOutsideMedium((hit_4)));
            FKSurface _S1415 = surface_12;
            FKHit _S1416 = hit_4;
            FKMedium _S1417 = _S1414;
            ShadowContext _S1418 = shadowContext_0(&_S1415, turned_1, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_5, _S1413, (&hit_4)->distance, width_3, &_S1416, _S1359, &_S1417);
            context_5 = _S1418;
        }
        else
        {
            context_5 = _S1411;
        }
        float3  throughput_6;
        float3  lit_0;
        if(_S1405)
        {
            float3  _S1419 = (&ray_2)->origin;
            if(_S1359)
            {
                throughput_6 = _S1176;
            }
            else
            {
                throughput_6 = _S1352.smooth_n;
            }
            FKSurface _S1420 = surface_12;
            uint _S1421 = stream(_S1204, b_5 + 64U);
            ShadowContext _S1422 = context_5;
            TreeSample _S1423 = sampleLightTree_0(_S1419, throughput_6, surface_12.geometry_n, surface_12.geometry_offset, _S1364, _S1421, &_S1422);
            bool _S1424 = any_1((_S1423.radiance) != _S1176);
            if(_S1424)
            {
                if(_S1359)
                {
                    uint _S1425 = (fcptMaxBounces());
                    bool _S1426 = b_5 < _S1425;
                    FKSurface _S1427 = surface_12;
                    TreeSample _S1428 = _S1423;
                    float3  _S1429 = hairLight_0(&_S1427, (&ray_2)->unit_direction, &_S1428, _S1426);
                    lit_0 = _S1429;
                }
                else
                {
                    float _S1430 = _S1354.x;
                    float _S1431 = _S1354.y;
                    uint _S1432 = (fcptMaxBounces());
                    bool _S1433 = b_5 < _S1432;
                    TreeSample _S1434 = _S1423;
                    BSDFMaterial _S1435 = _S1351.material;
                    float3  _S1436 = lightBSDF_0((&ray_2)->unit_direction, &_S1434, _S1352.smooth_n, _S1420.geometry_n, &_S1435, _S1430, _S1431, _S1433, surface_12.random_state);
                    lit_0 = _S1436;
                }
            }
            else
            {
                lit_0 = _S1176;
            }
            light_3 = _S1423;
        }
        else
        {
            light_3 = _S1406;
            lit_0 = _S1176;
        }
        bool viewed_1;
        bool refracted_4;
        bool wrong_side_0;
        bool _S1437;
        bool _S1438;
        float density_4;
        if(_S1391)
        {
            bool _S1439 = !_S1350;
            if(_S1439)
            {
                return _S1177;
            }
            float3  throughput_7 = throughput_5 * make_float3 (geometry_density_0);
            float density_5 = density_2 * geometry_density_0;
            if(_S1399)
            {
                viewed_1 = _S1182 == 1U;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                return Shift_x24init_0(throughput_7 * emission_1 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1399)
            {
                refracted_4 = _S1182 == 0U;
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
            {
                bool _S1440 = !nee_0;
                if(_S1440)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S1441 = rgb_to_greyscale(light_3.radiance);
                    passes_0 = !(_S1441 > 0.0f);
                }
                if(passes_0)
                {
                    return _S1177;
                }
                return Shift_x24init_0(throughput_7 * lit_0 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1399)
            {
                wrong_side_0 = _S1182 == 4U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                bool _S1442 = !nee_0;
                if(_S1442)
                {
                    return _S1177;
                }
                float _S1443 = environmentPdf_0(r_8->dir);
                float3  _S1444 = skyBSDF((&ray_2)->unit_direction, r_8->dir, surface_12, _S1354, is_inside_6, _S1443, surface_12.random_state);
                return Shift_x24init_0(throughput_7 * _S1444 * r_8->radiance / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            uint _S1445 = extractBits_0(_S1178, 21U, 1U);
            bool _S1446 = nee_0 != (_S1445 == 1U);
            if(_S1446)
            {
                return _S1177;
            }
            throughput_6 = throughput_7;
            density_4 = density_5;
        }
        else
        {
            if(replay_1)
            {
                viewed_1 = _S1392;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                bool _S1447 = !scatter_2;
                if(_S1447)
                {
                    refracted_4 = true;
                }
                else
                {
                    bool _S1448 = _S1181 != 1U;
                    if(_S1448)
                    {
                        refracted_4 = _S1181 != 3U;
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
                bool _S1449 = _S1181 == 2U;
                if(_S1449)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1350;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1182 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    if(_S1359)
                    {
                        return _S1177;
                    }
                    uint _S1450 = stream(_S1204, b_5 + 448U);
                    FKRay _S1451 = ray_2;
                    FKSurface _S1452 = surface_12;
                    ShadowContext _S1453 = context_5;
                    SkySample _S1454 = sampleSky_0(&_S1451, &_S1452, _S1354, is_inside_6, _S1450, surface_12.random_state, &_S1453);
                    return Shift_x24init_0(throughput_5 * _S1454.color, 1.0f);
                }
                if(_S1449)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1350;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float _S1455 = rgb_to_greyscale(light_3.radiance);
                    bool _S1456 = !(_S1455 > 0.0f);
                    if(_S1456)
                    {
                        return _S1177;
                    }
                    return Shift_x24init_0(throughput_5 * lit_0, 1.0f);
                }
                if(_S1191)
                {
                    passes_0 = _S1182 == 2U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1318;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_5 * emission_1, 1.0f);
                }
                if(_S1191)
                {
                    passes_0 = _S1182 == 1U;
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
                    passes_0 = !_S1350;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_5 * emission_1, 1.0f);
                }
                return _S1177;
            }
            else
            {
                if(_S1368)
                {
                    wrong_side_0 = scatter_2;
                }
                else
                {
                    wrong_side_0 = false;
                }
                if(wrong_side_0)
                {
                    bool _S1457 = b_5 > 0U;
                    if(_S1457)
                    {
                        Reservoir candidate_5 = chain_0;
                        if(_S1382)
                        {
                            float3  _S1458 = safeDivide(throughput_5 * emission_1, chain_throughput_0);
                            (&candidate_5)->radiance = _S1458;
                        }
                        else
                        {
                            if(_S1350)
                            {
                                candidate_5 = here_0;
                            }
                        }
                        float3  _S1459 = throughput_5 * emission_1;
                        Reservoir _S1460 = withEnd(candidate_5, 1U, b_5, _S1459);
                        offer(sel_7, _S1460, _S1459 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    else
                    {
                        float3  _S1461 = throughput_5 * emission_1;
                        float3  _S1462 = sel_7->glow + _S1461;
                        sel_7->glow = _S1462;
                    }
                    if(nee_0)
                    {
                        float3  _S1463 = throughput_5 * lit_0;
                        Reservoir candidate_6 = chain_0;
                        if(_S1382)
                        {
                            float3  _S1464 = safeDivide(_S1463, chain_throughput_0);
                            (&candidate_6)->radiance = _S1464;
                        }
                        else
                        {
                            if(_S1350)
                            {
                                candidate_6 = here_0;
                                uint _S1465 = insertBits_0((&candidate_6)->path, 1U, 21U, 1U);
                                (&candidate_6)->path = _S1465;
                                (&candidate_6)->dir = light_3.dir;
                                (&candidate_6)->radiance = light_3.radiance;
                            }
                            else
                            {
                                uint _S1466 = insertBits_0(0U, b_5 + 1U, 5U, 5U);
                                uint _S1467 = insertBits_0(_S1466, 2U, 10U, 2U);
                                (&candidate_6)->path = _S1467;
                            }
                        }
                        Reservoir _S1468 = withEnd(candidate_6, 0U, b_5, _S1463);
                        offer(sel_7, _S1468, _S1463 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    if(nee_0)
                    {
                        if(_S1359)
                        {
                            _S1437 = false;
                        }
                        else
                        {
                            bool _S1469 = environmentMapped_0();
                            _S1437 = _S1469;
                        }
                    }
                    else
                    {
                        _S1437 = false;
                    }
                    if(_S1437)
                    {
                        uint _S1470 = (fcptMaxBounces());
                        _S1438 = b_5 < _S1470;
                    }
                    else
                    {
                        _S1438 = false;
                    }
                    if(_S1438)
                    {
                        uint _S1471 = stream(_S1204, b_5 + 448U);
                        FKRay _S1472 = ray_2;
                        FKSurface _S1473 = surface_12;
                        ShadowContext _S1474 = context_5;
                        SkySample _S1475 = sampleSky_0(&_S1472, &_S1473, _S1354, is_inside_6, _S1471, surface_12.random_state, &_S1474);
                        float3  _S1476 = throughput_5 * _S1475.color;
                        Reservoir candidate_7 = chain_0;
                        if(_S1382)
                        {
                            float3  _S1477 = safeDivide(_S1476, chain_throughput_0);
                            (&candidate_7)->radiance = _S1477;
                        }
                        else
                        {
                            if(_S1350)
                            {
                                candidate_7 = here_0;
                                uint _S1478 = insertBits_0((&candidate_7)->path, 1U, 21U, 1U);
                                (&candidate_7)->path = _S1478;
                                (&candidate_7)->dir = _S1475.dir;
                                (&candidate_7)->radiance = _S1475.radiance;
                            }
                            else
                            {
                                uint _S1479 = insertBits_0(0U, b_5 + 1U, 5U, 5U);
                                uint _S1480 = insertBits_0(_S1479, 2U, 10U, 2U);
                                (&candidate_7)->path = _S1480;
                            }
                        }
                        Reservoir _S1481 = withEnd(candidate_7, 4U, b_5, _S1476);
                        offer(sel_7, _S1481, _S1476 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                }
            }
            throughput_6 = throughput_5;
            density_4 = density_2;
        }
        bool _S1482;
        bool _S1483;
        bool _S1484;
        bool straight_0;
        bool _S1485;
        bool _S1486;
        bool _S1487;
        bool _S1488;
        bool _S1489;
        bool _S1490;
        bool _S1491;
        bool _S1492;
        bool _S1493;
        bool _S1494;
        bool _S1495;
        bool _S1496;
        bool _S1497;
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
                viewed_1 = _S1392;
            }
            else
            {
                viewed_1 = false;
            }
            uint _S1498 = extractBits_0(_S1178, 15U, 3U);
            uint _S1499 = extractBits_0(_S1178, 18U, 3U);
            uint _S1500 = _slang_select(_S1391, _S1499,_S1498);
            float3  _S1501 = r_8->dir;
            bool refracted_5 = _S1500 == 1U;
            SampleBSDF _S1502 = SampleBSDF_x24init_0(_S1176, _S1176, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_5 = _S1502;
            float3  reconnection_1;
            if(viewed_1)
            {
                uint _S1503 = extractBits_0(_S1178, 22U, 1U);
                bool _S1504 = is_inside_6 != (_S1503 == 1U);
                if(_S1504)
                {
                    return _S1177;
                }
                bool _S1505 = _S1181 == 1U;
                if(_S1505)
                {
                    float3  _S1506 = (fcptHitPosition((_S1193)));
                    throughput_8 = _S1506;
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
                    BSDFMaterial _S1507 = _S1351.material;
                    bool _S1508 = isTranslucent_0(&_S1507);
                    if(_S1508)
                    {
                        refracted_4 = _S1500 == 0U;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                    if(refracted_4)
                    {
                        float3  _S1509 = throughput_8 - (&ray_2)->origin;
                        float3  _S1510 = _slang_select(_S1505, _S1509,_S1501);
                        wrong_side_0 = (dot_0(_S1352.smooth_n, _S1510) * _S1353) < 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    refracted_4 = wrong_side_0;
                }
                if(_S1505)
                {
                    float3  _S1511 = (&ray_2)->origin;
                    FKSurface _S1512 = surface_12;
                    float3  _S1513 = - _S1352.smooth_n;
                    bool _S1514 = is_inside_6 != refracted_4;
                    float3  _S1515 = _slang_select(_S1514, _S1513,_S1352.smooth_n);
                    float3  _S1516 = throughput_8 - (_S1511 + make_float3 (_S1512.geometry_offset) * _S1515);
                    float3  _S1517 = ((((_S1516)) * make_float3(rnorm3df(((_S1516)).x, ((_S1516)).y, ((_S1516)).z))));
                    reconnection_1 = _S1517;
                }
                else
                {
                    reconnection_1 = _S1501;
                }
                if(_S1359)
                {
                    wrong_side_0 = false;
                }
                else
                {
                    bool _S1518 = wrongSide_0(is_inside_6, refracted_4, reconnection_1, surface_12.geometry_n);
                    wrong_side_0 = _S1518;
                }
                if(wrong_side_0)
                {
                    return _S1177;
                }
                float3  _S1519 = throughput_8;
                throughput_8 = reconnection_1;
                b_8 = _S1500;
                wrong_side_0 = false;
                reconnection_1 = _S1519;
            }
            else
            {
                bool _S1520 = !_S1391;
                if(_S1520)
                {
                    SampleBSDF bsdf_sampled_0;
                    SampleBSDF _S1521;
                    if(_S1359)
                    {
                        SampleBSDF _S1522 = (fcptSampleHair((surface_12.hair), (_S1351.material.albedo), (_S1351.material.specular_tint), ((&ray_2)->unit_direction), (surface_12.random_state)));
                        _S1521 = _S1522;
                    }
                    else
                    {
                        SampleBSDF _S1523 = sampleBSDF((&ray_2)->unit_direction, _S1352.smooth_n, _S1351.material, _S1354.x, _S1354.y, surface_12.random_state, _S1408);
                        _S1521 = _S1523;
                    }
                    bsdf_sampled_0 = _S1521;
                    if(_S1359)
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
                            return _S1177;
                        }
                        break;
                    }
                    if(_S1359)
                    {
                        wrong_side_0 = false;
                    }
                    else
                    {
                        bool _S1524 = wrongSide_0(is_inside_6, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, surface_12.geometry_n);
                        wrong_side_0 = _S1524;
                    }
                    if(wrong_side_0)
                    {
                        _S1437 = (_S1351.material.transmission) > 0.0f;
                    }
                    else
                    {
                        _S1437 = false;
                    }
                    if(_S1437)
                    {
                        SampleBSDF _S1525 = sampleBSDF((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n, _S1351.material, _S1354.x, _S1354.y, (&bsdf_sampled_0)->random_state, _S1408);
                        (&bsdf_sampled_0)->unit_direction = _S1525.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1525.refracted;
                        (&bsdf_sampled_0)->throughput = _S1525.throughput;
                    }
                    else
                    {
                        if(wrong_side_0)
                        {
                            float3  _S1526 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n)) * surface_12.geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1526;
                        }
                    }
                    uint _S1527 = (&bsdf_sampled_0)->lobe;
                    float3  _S1528 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1529 = (&bsdf_sampled_0)->refracted;
                    lobe_5 = bsdf_sampled_0;
                    float _S1530 = (&bsdf_sampled_0)->pdf;
                    float _S1531 = _slang_select(wrong_side_0, 0.0f,_S1530);
                    (&lobe_5)->pdf = _S1531;
                    throughput_8 = _S1528;
                    b_8 = _S1527;
                    refracted_4 = _S1529;
                }
                else
                {
                    throughput_8 = _S1501;
                    b_8 = _S1500;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(viewed_1)
            {
                _S1437 = true;
            }
            else
            {
                _S1437 = _S1391;
            }
            float3  chain_throughput_1;
            if(_S1437)
            {
                if(_S1359)
                {
                    SampleBSDF _S1532 = (fcptConnectHair((surface_12.hair), (_S1351.material.albedo), (_S1351.material.specular_tint), ((&ray_2)->unit_direction), (throughput_8)));
                    lobe_5 = _S1532;
                }
                else
                {
                    float3  _S1533 = (&ray_2)->unit_direction;
                    float _S1534 = sign_0(_S1353);
                    float3  _S1535 = _S1352.smooth_n * make_float3 (_S1534);
                    float _S1536 = dot_0(_S1535, throughput_8);
                    float _S1537 = _S1351.material.roughness;
                    float _S1538 = _S1537 * _S1537;
                    AnisotropicFrame _S1539 = anisotropicFrame(_S1351.material, _S1535);
                    float3  _S1540 = negate_0(_S1533);
                    SheenProfile _S1541 = sheenProfile(_S1540, _S1535, _S1351.material);
                    float3  _S1542 = reflectedHalf(_S1533, throughput_8);
                    bool _S1543 = b_8 == 1U;
                    if(_S1543)
                    {
                        float3  _S1544 = refractedHalf(_S1533, throughput_8, _S1352.smooth_n, _S1354.x, _S1354.y);
                        throughput_9 = _S1544;
                    }
                    else
                    {
                        throughput_9 = _S1542;
                    }
                    bool _S1545 = b_8 == 0U;
                    if(_S1545)
                    {
                        _S1438 = true;
                    }
                    else
                    {
                        _S1438 = b_8 == 6U;
                    }
                    if(_S1438)
                    {
                        float3  _S1546 = sampledHalf(_S1533, _S1352.smooth_n, _S1351.material, surface_12.random_state, _S1539);
                        throughput_10 = _S1546;
                    }
                    else
                    {
                        throughput_10 = throughput_9;
                    }
                    float3  _S1547 = negate_0(_S1533);
                    float _S1548 = _S1354.x;
                    float _S1549 = _S1354.y;
                    BSDFLobes _S1550 = bsdfLobes(_S1533, _S1547, _S1535, throughput_10, _S1351.material, _S1548, _S1549, _S1539, _S1541);
                    BSDFLobes lobe_terms_1 = _S1550;
                    float _S1551 = translucentShare(_S1351.material);
                    (&lobe_terms_1)->translucent_share = _S1551;
                    switch(b_8)
                    {
                    case 0U:
                        {
                            float _S1552 = diffusePDF(_S1536, 0.0f, (F32_abs((_S1353))), _S1538, lobe_terms_1, _S1548, _S1549);
                            float3  _S1553 = diffuseBSDF(throughput_8, _S1535, _S1538, _S1351.material, lobe_terms_1);
                            density_6 = _S1552;
                            chain_throughput_1 = _S1553;
                            break;
                        }
                    case 1U:
                        {
                            float _S1554 = refractPDF(_S1536, dot_0(throughput_8, throughput_10), (F32_abs((_S1353))), _S1538, lobe_terms_1, _S1548, _S1549);
                            float3  _S1555 = refractBSDF(throughput_8, _S1535, _S1538, _S1351.material, lobe_terms_1);
                            density_6 = _S1554;
                            chain_throughput_1 = _S1555;
                            break;
                        }
                    case 4U:
                        {
                            float _S1556 = sheenVelvetPDF(_S1536, 0.0f, (F32_abs((_S1353))), _S1538, lobe_terms_1, _S1548, _S1549);
                            float3  _S1557 = sheenVelvetBSDF(throughput_8, _S1535, _S1538, _S1351.material, lobe_terms_1);
                            density_6 = _S1556;
                            chain_throughput_1 = _S1557;
                            break;
                        }
                    case 6U:
                        {
                            float _S1558 = toonPDF(_S1536, dot_0(throughput_8, (&lobe_terms_1)->toon_axis), (F32_abs((_S1353))), _S1538, lobe_terms_1, _S1548, _S1549);
                            float3  _S1559 = toonBSDF(throughput_8, _S1535, _S1538, _S1351.material, lobe_terms_1);
                            density_6 = _S1558;
                            chain_throughput_1 = _S1559;
                            break;
                        }
                    default:
                        {
                            float _S1560 = reflectPDF(_S1536, 0.0f, (F32_abs((_S1353))), _S1538, lobe_terms_1, _S1548, _S1549);
                            float3  _S1561 = reflectBSDF(throughput_8, _S1535, _S1538, _S1351.material, lobe_terms_1);
                            density_6 = _S1560;
                            chain_throughput_1 = _S1561;
                            break;
                        }
                    }
                    bool _S1562 = density_6 > 0.0f;
                    if(_S1562)
                    {
                        SampleBSDF _S1563 = SampleBSDF_x24init_0(throughput_8, chain_throughput_1, surface_12.random_state, _S1543, b_8, density_6);
                        lobe_5 = _S1563;
                    }
                }
            }
            bool _S1564 = b_8 == 0U;
            if(_S1564)
            {
                _S1438 = true;
            }
            else
            {
                _S1438 = b_8 == 4U;
            }
            if(_S1438)
            {
                _S1482 = true;
            }
            else
            {
                _S1482 = b_8 == 6U;
            }
            if(_S1359)
            {
                _S1483 = false;
            }
            else
            {
                bool _S1565 = !_S1482;
                if(_S1565)
                {
                    bool _S1566 = (_S1351.material.roughness) == 0.0f;
                    if(_S1566)
                    {
                        _S1483 = true;
                    }
                    else
                    {
                        bool _S1567 = b_8 == 1U;
                        if(_S1567)
                        {
                            _S1483 = (_S1354.x) == (_S1354.y);
                        }
                        else
                        {
                            _S1483 = false;
                        }
                    }
                }
                else
                {
                    _S1483 = false;
                }
            }
            bool _S1568 = !_S1359;
            if(_S1568)
            {
                _S1484 = b_8 == 1U;
            }
            else
            {
                _S1484 = false;
            }
            if(_S1484)
            {
                straight_0 = (_S1351.material.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S1485 = _S1568;
            }
            else
            {
                _S1485 = false;
            }
            if(_S1485)
            {
                _S1486 = b_8 == 1U;
            }
            else
            {
                _S1486 = false;
            }
            if(_S1486)
            {
                _S1487 = (_S1354.x) == (_S1354.y);
            }
            else
            {
                _S1487 = false;
            }
            BSDFMaterial _S1569 = _S1351.material;
            bool _S1570 = isTranslucent_0(&_S1569);
            if(_S1570)
            {
                _S1488 = _S1564;
            }
            else
            {
                _S1488 = false;
            }
            if(_S1488)
            {
                _S1489 = (dot_0(throughput_8, surface_12.geometry_n)) < 0.0f;
            }
            else
            {
                _S1489 = false;
            }
            if(nee_0)
            {
                _S1490 = !_S1483;
            }
            else
            {
                _S1490 = false;
            }
            if(_S1490)
            {
                _S1491 = !wrong_side_0;
            }
            else
            {
                _S1491 = false;
            }
            if(_S1491)
            {
                float _S1571 = (&lobe_5)->pdf;
                float3  _S1572 = (&ray_2)->origin;
                float3  _S1573 = _slang_select(_S1364, _S1176,_S1352.smooth_n);
                float3  _S1574 = (&ray_2)->origin;
                FKSurface _S1575 = surface_12;
                float3  _S1576 = - _S1352.smooth_n;
                float3  _S1577 = _slang_select(_S1489, _S1576,_S1352.smooth_n);
                NEEVertex _S1578 = NEEVertex_x24init_0(false, _S1571, _S1572, _S1573, _S1574 + make_float3 (_S1575.geometry_offset) * _S1577);
                nee_vertex_0 = _S1578;
            }
            else
            {
                if(_S1359)
                {
                    _S1492 = true;
                }
                else
                {
                    bool _S1579 = b_8 != 1U;
                    if(_S1579)
                    {
                        _S1492 = true;
                    }
                    else
                    {
                        _S1492 = (_S1354.x) != (_S1354.y);
                    }
                }
                if(_S1492)
                {
                    (&nee_vertex_0)->none = true;
                }
            }
            bool _S1580 = ((&lobe_5)->pdf) > 0.0f;
            if(_S1580)
            {
                if(_S1482)
                {
                    _S1492 = true;
                }
                else
                {
                    _S1492 = ((&lobe_5)->pdf * (&prev_0)->cos / ((&hit_4)->distance * (&hit_4)->distance) * threshold_0) <= 1.0f;
                }
            }
            else
            {
                _S1492 = false;
            }
            bool _S1581 = ((&lobe_5)->pdf) > 0.0f;
            if(_S1581)
            {
                if(_S1482)
                {
                    _S1493 = true;
                }
                else
                {
                    _S1493 = (_S1351.material.roughness) >= 0.20000000298023224f;
                }
            }
            else
            {
                _S1493 = false;
            }
            if(_S1391)
            {
                bool _S1582 = !_S1492;
                if(_S1582)
                {
                    return _S1177;
                }
                bool _S1583 = _S1182 != 1U;
                if(_S1583)
                {
                    _S1494 = _S1182 != 2U;
                }
                else
                {
                    _S1494 = false;
                }
                if(_S1494)
                {
                    float _S1584 = (&lobe_5)->pdf;
                    float _S1585 = _slang_select(nee_0, _S1584,0.0f);
                    float _S1586 = escapeWeight_0(_S1585, _S1501);
                    if(_S1399)
                    {
                        passes_0 = _S1188;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1587 = _slang_select(passes_0, _S1586,1.0f);
                    return Shift_x24init_0(throughput_6 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf)) * r_8->radiance * make_float3 (_S1587) / make_float3 (r_8->jac), density_4 * (&lobe_5)->pdf / r_8->jac);
                }
                float3  _S1588 = throughput_6 * make_float3 ((&lobe_5)->pdf);
                float _S1589 = density_4 * (&lobe_5)->pdf;
                throughput_9 = _S1588;
                density_6 = _S1589;
            }
            else
            {
                throughput_9 = throughput_6;
                density_6 = density_4;
            }
            uint _S1590 = (fcptLayers((hit_4)));
            bool _S1591 = _S1590 > 1U;
            if(_S1591)
            {
                _S1494 = (b_8 == 1U) != passes_0;
            }
            else
            {
                _S1494 = false;
            }
            if(viewed_1)
            {
                _S1495 = _S1494;
            }
            else
            {
                _S1495 = false;
            }
            if(_S1495)
            {
                return _S1177;
            }
            if(replay_1)
            {
                _S1496 = b_5 <= _S1192;
            }
            else
            {
                _S1496 = false;
            }
            if(_S1496)
            {
                _S1497 = _S1350;
            }
            else
            {
                _S1497 = false;
            }
            bool _S1592;
            if(_S1497)
            {
                _S1592 = _S1492;
            }
            else
            {
                _S1592 = false;
            }
            bool _S1593;
            if(_S1592)
            {
                _S1593 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S1593 = !_S1493;
                }
                else
                {
                    _S1593 = false;
                }
            }
            if(_S1593)
            {
                return _S1177;
            }
            if(viewed_1)
            {
                float3  _S1594 = throughput_9 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf));
                float _S1595 = (&lobe_5)->pdf;
                throughput_10 = _S1594;
                sky_pdf_2 = _S1595;
            }
            else
            {
                float3  _S1596 = throughput_9 * max_0((&lobe_5)->throughput, _S1176);
                throughput_10 = _S1596;
                sky_pdf_2 = density_6;
            }
            bool _S1597;
            if(_S1368)
            {
                _S1597 = !_S1382;
            }
            else
            {
                _S1597 = false;
            }
            bool _S1598;
            if(_S1597)
            {
                _S1598 = _S1350;
            }
            else
            {
                _S1598 = false;
            }
            bool _S1599;
            if(_S1598)
            {
                _S1599 = _S1492;
            }
            else
            {
                _S1599 = false;
            }
            if(_S1599)
            {
                chain_0 = here_0;
                uint _S1600 = insertBits_0((&chain_0)->path, b_8, 18U, 3U);
                uint _S1601 = _slang_select(nee_0, 1U,0U);
                uint _S1602 = insertBits_0(_S1600, _S1601, 21U, 1U);
                (&chain_0)->path = _S1602;
                float _S1603 = (&chain_0)->jac * (&lobe_5)->pdf;
                (&chain_0)->jac = _S1603;
                (&chain_0)->dir = throughput_8;
                chain_throughput_1 = throughput_10;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            FKSurface _S1604 = surface_12;
            Vertex _S1605 = Vertex_x24init_0(_S1493, b_8, (&lobe_5)->pdf, (F32_abs((dot_0(surface_12.geometry_n, throughput_8)))), is_inside_6);
            prev_0 = _S1605;
            float _S1606 = (&lobe_5)->pdf;
            bool _S1607 = b_8 == 1U;
            bool _S1608;
            if(_S1607)
            {
                _S1608 = (_S1354.x) == (_S1354.y);
            }
            else
            {
                _S1608 = false;
            }
            float sky_pdf_3 = _slang_select(_S1608, sky_pdf_0,_S1606);
            float _S1609 = _slang_select(_S1359, 0.0f,sky_pdf_3);
            float _S1610 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * (&lobe_5)->pdf))))), (3.14159274101257324f)));
            bool _S1611 = !_S1483;
            float _S1612 = _slang_select(_S1611, _S1610,0.0f);
            float _S1613 = spread_1 + _S1612;
            bool _S1614;
            if(refracted_4)
            {
                _S1614 = !_S1489;
            }
            else
            {
                _S1614 = false;
            }
            bool is_inside_7;
            if(_S1614)
            {
                bool _S1615 = !is_inside_6;
                is_inside_7 = _S1615;
            }
            else
            {
                is_inside_7 = is_inside_6;
            }
            FKSurface _S1616 = surface_12;
            bool _S1617 = boundsVolume_0(&_S1616);
            bool _S1618;
            if(_S1617)
            {
                _S1618 = !_S1494;
            }
            else
            {
                _S1618 = false;
            }
            if(_S1618)
            {
                FKSurface faced_2 = surface_12;
                float3  _S1619 = - _S1604.geometry_n;
                float3  _S1620 = _slang_select(turned_1, _S1619,_S1604.geometry_n);
                (&faced_2)->geometry_n = _S1620;
                FKMedium _S1621 = Medium_x24init_0(scatter_in_0, extinction_in_0, g_in_0);
                FKMedium _S1622 = (fcptOutsideMedium((hit_4)));
                FKSurface _S1623 = faced_2;
                FKMedium _S1624 = _S1621;
                FKMedium _S1625 = _S1622;
                MediumSides _S1626 = mediumSides_0(&_S1623, &_S1624, filling_2, (&ray_2)->unit_direction, &_S1625);
                bool _S1627 = ((dot_0(throughput_8, _S1604.geometry_n)) > 0.0f) == ((dot_0(_S1604.geometry_n, (&faced_2)->geometry_n)) > 0.0f);
                float3  _S1628 = _slang_select(_S1627, _S1626.front.scatter,_S1626.behind.scatter);
                scatter_in_0 = _S1628;
                float3  _S1629 = _slang_select(_S1627, _S1626.front.extinction,_S1626.behind.extinction);
                extinction_in_0 = _S1629;
                float _S1630 = _slang_select(_S1627, _S1626.front.g,_S1626.behind.g);
                g_in_0 = _S1630;
                uint _S1631 = _S1626.fillings.x;
                uint _S1632 = _S1626.fillings.y;
                uint _S1633 = _slang_select(_S1627, _S1632,_S1631);
                bool _S1634 = (fcptVaryingUsed());
                uint _S1635 = _slang_select(_S1634, _S1633,4294967295U);
                filling_2 = _S1635;
            }
            (&ray_2)->unit_direction = throughput_8;
            bool _S1636 = !_S1494;
            if(_S1636)
            {
                FKSurface _S1637 = surface_12;
                float _S1638 = _slang_select(straight_0, 0.0f,_S1637.geometry_offset);
                float3  _S1639 = - _S1352.smooth_n;
                bool _S1640 = is_inside_7 != _S1489;
                float3  _S1641 = _slang_select(_S1640, _S1639,_S1352.smooth_n);
                float3  _S1642 = (&ray_2)->origin + make_float3 (_S1638) * _S1641;
                (&ray_2)->origin = _S1642;
            }
            throughput_9 = throughput_10;
            chain_throughput_0 = chain_throughput_1;
            density_6 = sky_pdf_2;
            passes_0 = _S1494;
            viewed_1 = _S1487;
            sky_pdf_2 = _S1609;
            spread_4 = _S1613;
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
        if(_S1368)
        {
            if(_S1318)
            {
                float3  _S1643 = throughput_9 * emission_1;
                Reservoir candidate_8 = chain_0;
                uint _S1644 = extractBits_0((&chain_0)->path, 10U, 2U);
                bool _S1645 = _S1644 == 1U;
                if(_S1645)
                {
                    float3  _S1646 = safeDivide(_S1643, chain_throughput_0);
                    (&candidate_8)->radiance = _S1646;
                }
                Reservoir _S1647 = withEnd(candidate_8, 2U, b_5, _S1643);
                offer(sel_7, _S1647, _S1643 * make_float3 (scale_3) / make_float3 (density_6));
            }
            if(_S1318)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = scatter_2;
            }
            if(refracted_4)
            {
                float _S1648 = survivalProbability(throughput_9, density_6);
                density_7 = _S1648;
            }
            else
            {
                density_7 = 1.0f;
            }
            uint _S1649 = stream(_S1204, b_5 + 128U);
            Random _S1650 = pcg(_S1649);
            bool _S1651 = density_7 < (_S1650.value);
            if(_S1651)
            {
                wrong_side_0 = true;
            }
            else
            {
                uint _S1652 = (fcptMaxBounces());
                wrong_side_0 = b_5 >= _S1652;
            }
            if(wrong_side_0)
            {
                break;
            }
            float _S1653 = density_6 * density_7;
            density_7 = _S1653;
        }
        else
        {
            density_7 = density_6;
        }
        uint _S1654 = layer_0 ^ 1U;
        uint _S1655 = _slang_select(passes_0, _S1654,0U);
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
            uint _S1656 = b_8 + 1U;
            b_5 = _S1656;
            layer_0 = _S1655;
            continue;
        }
        FKRay _S1657 = ray_2;
        float _S1658 = distance_1(reconnection_0, (&ray_2)->origin) * 1.0010000467300415f;
        if(replay_1)
        {
            refracted_4 = _S1392;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            wrong_side_0 = _S1181 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S1659 = _slang_select(wrong_side_0, _S1658,4.294967296e+09f);
        bool _S1660 = !_S1359;
        if(straight_0)
        {
            _S1437 = true;
        }
        else
        {
            _S1437 = _S1359;
        }
        FKHit _S1661;
        if(_S1437)
        {
            _S1661 = hit_4;
        }
        else
        {
            _S1661 = _S1409;
        }
        FKHit _S1662 = (fcptTraverseInstanceBVH((_S1657), (_S1325), (_S1659), (_S1660), (_S1661), (viewed_1)));
        hit_4 = _S1662;
        if(replay_1)
        {
            _S1438 = _S1392;
        }
        else
        {
            _S1438 = false;
        }
        if(_S1438)
        {
            _S1482 = _S1181 == 1U;
        }
        else
        {
            _S1482 = false;
        }
        if(_S1482)
        {
            _S1483 = ((&hit_4)->instance_index) == (_S1193.instance_index);
        }
        else
        {
            _S1483 = false;
        }
        if(_S1483)
        {
            _S1484 = ((&hit_4)->triangle_index) == (_S1193.triangle_index);
        }
        else
        {
            _S1484 = false;
        }
        if(_S1484)
        {
            (&hit_4)->uv = _S1193.uv;
            float _S1663 = distance_1(reconnection_0, (&ray_2)->origin);
            (&hit_4)->distance = _S1663;
        }
        if(replay_1)
        {
            _S1485 = _S1392;
        }
        else
        {
            _S1485 = false;
        }
        if(_S1485)
        {
            _S1486 = _S1181 == 3U;
        }
        else
        {
            _S1486 = false;
        }
        if(_S1486)
        {
            _S1487 = ((&hit_4)->instance_index) != 4294967295U;
        }
        else
        {
            _S1487 = false;
        }
        if(_S1487)
        {
            return _S1177;
        }
        Reservoir _S1664 = chain_0;
        uint _S1665 = filling_2;
        for(;;)
        {
            bool _S1666 = (fcptVaryingUsed());
            if(_S1666)
            {
                _S1488 = _S1665 != 4294967295U;
            }
            else
            {
                _S1488 = false;
            }
            float _S1667;
            if(_S1488)
            {
                float _S1668 = (fcptMajorant((_S1665)));
                _S1667 = _S1668;
            }
            else
            {
                _S1667 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
            }
            if(replay_1)
            {
                _S1489 = _S1392;
            }
            else
            {
                _S1489 = false;
            }
            if(_S1489)
            {
                _S1490 = _S1181 == 1U;
            }
            else
            {
                _S1490 = false;
            }
            if(_S1490)
            {
                _S1491 = _S1667 > 0.0f;
            }
            else
            {
                _S1491 = false;
            }
            if(_S1491)
            {
                ended_0 = _S1177;
                sky_pdf_1 = sky_pdf_2;
                spread_2 = spread_4;
                width_4 = width_3;
                density_3 = density_7;
                throughput_10 = throughput_9;
                b_8 = b_5;
                _S1492 = true;
                break;
            }
            bool _S1669 = (&prev_0)->rough;
            if(_S1669)
            {
                _S1492 = !(_S1667 > 0.0f);
            }
            else
            {
                _S1492 = false;
            }
            (&prev_0)->rough = _S1492;
            uint _S1670 = b_5 + 320U;
            bool _S1671 = b_5 == 4294967295U;
            uint _S1672 = _slang_select(_S1671, 384U,_S1670);
            uint _S1673 = stream(_S1204, _S1672);
            uint tracking_1 = _S1673;
            weight_1 = throughput_3;
            glowed_0 = _S1176;
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
                    _S1175 = int(2);
                    break;
                }
                uint _S1674 = b_8 + 320U;
                bool _S1675 = b_8 == 4294967295U;
                uint _S1676 = _slang_select(_S1675, 384U,_S1674);
                uint _S1677 = stream(_S1204, _S1676);
                Random _S1678 = pcg(_S1677);
                float _S1679 = - (F32_log((1.0f - _S1678.value))) / _S1667;
                if(_S1488)
                {
                    float3  _S1680 = (&ray_2)->origin;
                    float3  _S1681 = (&ray_2)->unit_direction;
                    float _S1682 = (&hit_4)->distance;
                    uint _S1683 = _slang_select(_S1675, 0U,b_8);
                    uint _S1684 = (&prev_0)->lobe;
                    uint _S1685 = _slang_select(_S1675, 3U,_S1684);
                    float _S1686 = (fcptTrackMedium((_S1665), (_S1680), (_S1681), (_S1682), (&tracking_1), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1683), (_S1685), (_S1675)));
                    spread_3 = _S1686;
                }
                else
                {
                    spread_3 = _S1679;
                }
                bool _S1687 = !(spread_3 < ((&hit_4)->distance));
                if(_S1687)
                {
                    _S1175 = int(2);
                    break;
                }
                if(_S1488)
                {
                    _S1493 = _S1368;
                }
                else
                {
                    _S1493 = false;
                }
                if(_S1493)
                {
                    float3  _S1688 = throughput_10 * glowed_0 / make_float3 (density_3);
                    float3  _S1689 = sel_7->glow + _S1688;
                    sel_7->glow = _S1689;
                }
                else
                {
                }
                glowed_0 = _S1176;
                uint b_9 = b_8 + 1U;
                float3  _S1690 = (&ray_2)->origin + make_float3 (spread_3) * (&ray_2)->unit_direction;
                (&ray_2)->origin = _S1690;
                float3  _S1691 = flightWeight_0(scatter_in_0, extinction_in_0, _S1667, spread_3, true);
                float3  _S1692 = weight_1;
                float3  _S1693 = _slang_select(_S1488, _S1692,_S1691);
                float3  throughput_11 = throughput_10 * _S1693;
                uint _S1694 = stream(_S1204, b_9 + 320U);
                tracking_1 = _S1694;
                weight_1 = throughput_3;
                float width_7 = width_4 + spread_2 * spread_3;
                float _S1695 = spread_2 + 3.14159274101257324f;
                if(_S1368)
                {
                    _S1494 = true;
                }
                else
                {
                    bool _S1696 = b_9 == _S1192;
                    if(_S1696)
                    {
                        _S1494 = !_S1488;
                    }
                    else
                    {
                        _S1494 = false;
                    }
                }
                TreeSample light_4;
                if(_S1494)
                {
                    float3  _S1697 = (&ray_2)->origin;
                    float3  _S1698 = (&ray_2)->unit_direction;
                    float3  _S1699 = (&ray_2)->unit_direction;
                    uint _S1700 = stream(_S1204, b_9 + 64U);
                    float3  _S1701 = extinction_in_0;
                    float3  _S1702 = extinction_in_0;
                    uint2  _S1703 = make_uint2 (_S1665);
                    float3  _S1704 = (&ray_2)->unit_direction;
                    uint _S1705 = arrivalLobe_0(b_9, (&prev_0)->lobe);
                    FKHit _S1706 = _S1409;
                    ShadowContext _S1707 = ShadowContext_x24init_0(_S1701, _S1702, _S1703, _S1704, b_9, _S1705, false, spread_3, width_7, &_S1706, false);
                    ShadowContext _S1708 = _S1707;
                    TreeSample _S1709 = sampleLightTree_0(_S1697, _S1698, _S1699, 0.0f, true, _S1700, &_S1708);
                    light_4 = _S1709;
                }
                else
                {
                    light_4 = _S1406;
                }
                float _S1710 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_4.dir));
                uint _S1711 = (fcptMaxBounces());
                bool _S1712 = b_9 < _S1711;
                if(_S1712)
                {
                    _S1495 = (light_4.density) > 0.0f;
                }
                else
                {
                    _S1495 = false;
                }
                float _S1713 = _slang_select(_S1495, _S1710,0.0f);
                float3  _S1714 = throughput_11 * light_4.radiance;
                float _S1715 = powerHeuristic(light_4.density, _S1713);
                float3  _S1716 = _S1714 * make_float3 (_S1710 * _S1715);
                float3  _S1717 = _slang_select(_S1494, _S1716,_S1176);
                if(replay_1)
                {
                    _S1496 = b_9 == _S1192;
                }
                else
                {
                    _S1496 = false;
                }
                if(_S1496)
                {
                    bool _S1718 = _S1181 == 2U;
                    if(_S1718)
                    {
                        float _S1719 = rgb_to_greyscale(_S1717);
                        _S1497 = _S1719 > 0.0f;
                    }
                    else
                    {
                        _S1497 = false;
                    }
                    if(_S1497)
                    {
                        Shift _S1720 = Shift_x24init_0(_S1717, 1.0f);
                        _S1175 = int(1);
                        ended_0 = _S1720;
                        spread_3 = _S1695;
                        width_5 = width_7;
                        throughput_8 = throughput_11;
                        b_6 = b_9;
                        break;
                    }
                    _S1175 = int(1);
                    ended_0 = _S1177;
                    spread_3 = _S1695;
                    width_5 = width_7;
                    throughput_8 = throughput_11;
                    b_6 = b_9;
                    break;
                }
                if(_S1368)
                {
                    Reservoir candidate_9 = _S1664;
                    uint _S1721 = extractBits_0(_S1664.path, 10U, 2U);
                    bool _S1722 = _S1721 == 1U;
                    if(_S1722)
                    {
                        float3  _S1723 = safeDivide(_S1717, chain_throughput_0);
                        (&candidate_9)->radiance = _S1723;
                    }
                    else
                    {
                        uint _S1724 = insertBits_0(0U, b_9 + 1U, 5U, 5U);
                        uint _S1725 = insertBits_0(_S1724, 2U, 10U, 2U);
                        (&candidate_9)->path = _S1725;
                    }
                    Reservoir _S1726 = withEnd(candidate_9, 0U, b_9, _S1717);
                    offer(sel_7, _S1726, _S1717 * make_float3 (scale_3) / make_float3 (density_3));
                    float _S1727 = survivalProbability(throughput_11, density_3);
                    uint _S1728 = stream(_S1204, b_9 + 128U);
                    Random _S1729 = pcg(_S1728);
                    bool _S1730 = _S1727 < (_S1729.value);
                    if(_S1730)
                    {
                        _S1497 = true;
                    }
                    else
                    {
                        uint _S1731 = (fcptMaxBounces());
                        _S1497 = b_9 >= _S1731;
                    }
                    if(_S1497)
                    {
                        _S1175 = int(1);
                        ended_0 = _S1177;
                        spread_3 = _S1695;
                        width_5 = width_7;
                        throughput_8 = throughput_11;
                        b_6 = b_9;
                        break;
                    }
                    float _S1732 = density_3 * _S1727;
                    density_3 = _S1732;
                }
                else
                {
                }
                float phase_pdf_1 = 0.0f;
                uint _S1733 = stream(_S1204, b_9);
                float3  _S1734 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1733, &phase_pdf_1);
                (&ray_2)->unit_direction = _S1734;
                NEEVertex _S1735 = NEEVertex_x24init_0(false, phase_pdf_1, (&ray_2)->origin, _S1176, (&ray_2)->origin);
                nee_vertex_0 = _S1735;
                Vertex _S1736 = Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_5);
                prev_0 = _S1736;
                float _S1737 = (&prev_0)->pdf;
                FKRay _S1738 = ray_2;
                FKHit _S1739 = (fcptTraverseInstanceBVH((_S1738), (true), (4.294967296e+09f), (false), (_S1409), (false)));
                hit_4 = _S1739;
                b_8 = b_9;
                throughput_10 = throughput_11;
                spread_2 = _S1695;
                width_4 = width_7;
                sky_pdf_1 = _S1737;
            }
            if(_S1175 != int(2))
            {
                spread_2 = spread_3;
                width_4 = width_5;
                throughput_10 = throughput_8;
                b_8 = b_6;
                _S1492 = true;
                break;
            }
            ended_0 = _S1177;
            _S1492 = false;
            break;
        }
        if(_S1492)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S1493 = b_8 == b_5;
        }
        else
        {
            _S1493 = false;
        }
        bool _S1740 = ((&hit_4)->instance_index) == 4294967295U;
        if(_S1740)
        {
            bool _S1741 = !(&nee_vertex_0)->none;
            float _S1742 = _slang_select(_S1741, sky_pdf_1,0.0f);
            float _S1743 = escapeWeight_0(_S1742, (&ray_2)->unit_direction);
            float3  _S1744 = environment_0((&ray_2)->unit_direction, b_8, (&prev_0)->lobe);
            float3  _S1745 = throughput_10 * _S1744;
            if(replay_1)
            {
                bool _S1746 = b_8 == _S1192;
                if(_S1746)
                {
                    passes_0 = _S1181 == 3U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(_S1745 * make_float3 (_S1743) / make_float3 (r_8->jac), density_3 / r_8->jac);
                }
                if(_S1191)
                {
                    passes_0 = _S1188;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = b_8 == _S1179;
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
                    return Shift_x24init_0(_S1745 * make_float3 (_S1743), 1.0f);
                }
                return _S1177;
            }
            Reservoir candidate_10 = chain_0;
            uint _S1747 = extractBits_0((&chain_0)->path, 10U, 2U);
            bool _S1748 = _S1747 == 1U;
            if(_S1748)
            {
                uint _S1749 = extractBits_0((&chain_0)->path, 5U, 5U);
                bool _S1750 = _S1749 == b_8;
                float _S1751 = _slang_select(_S1750, 1.0f,_S1743);
                float3  _S1752 = safeDivide(_S1745 * make_float3 (_S1751), chain_throughput_0);
                (&candidate_10)->radiance = _S1752;
            }
            else
            {
                bool _S1753 = (&prev_0)->rough;
                if(_S1753)
                {
                    uint _S1754 = insertBits_0(0U, b_8 + 1U, 5U, 5U);
                    uint _S1755 = insertBits_0(_S1754, 3U, 10U, 2U);
                    uint _S1756 = insertBits_0(_S1755, (&prev_0)->lobe, 15U, 3U);
                    bool _S1757 = (&prev_0)->inside;
                    uint _S1758 = _slang_select(_S1757, 1U,0U);
                    uint _S1759 = insertBits_0(_S1756, _S1758, 22U, 1U);
                    (&candidate_10)->path = _S1759;
                    (&candidate_10)->jac = (&prev_0)->pdf;
                    (&candidate_10)->dir = (&ray_2)->unit_direction;
                }
            }
            float3  _S1760 = _S1745 * make_float3 (_S1743);
            Reservoir _S1761 = withEnd(candidate_10, 3U, b_8, _S1760);
            offer(sel_7, _S1761, _S1760 * make_float3 (scale_3) / make_float3 (density_3));
            break;
        }
        float3  _S1762 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
        (&ray_2)->origin = _S1762;
        bool _S1763 = (fcptVaryingUsed());
        if(_S1763)
        {
            _S1494 = filling_2 != 4294967295U;
        }
        else
        {
            _S1494 = false;
        }
        if(_S1494)
        {
            if(_S1368)
            {
                float3  _S1764 = throughput_10 * glowed_0 / make_float3 (density_3);
                float3  _S1765 = sel_7->glow + _S1764;
                sel_7->glow = _S1765;
            }
            float3  _S1766 = throughput_10 * weight_1;
            throughput_8 = _S1766;
        }
        else
        {
            float3  _S1767 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
            float3  _S1768 = throughput_10 * _S1767;
            throughput_8 = _S1768;
        }
        float _S1769 = width_4 + spread_2 * (&hit_4)->distance;
        viewed_0 = _S1493;
        width_3 = _S1769;
        throughput_2 = throughput_8;
        density_2 = density_3;
        sky_pdf_0 = sky_pdf_1;
        spread_1 = spread_2;
        uint _S1656 = b_8 + 1U;
        b_5 = _S1656;
        layer_0 = _S1655;
    }
    return _S1177;
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
    Random _S1770 = pcg(state_3);
    Random _S1771 = pcg(_S1770.state);
    float _S1772 = 6.28318548202514648f * _S1770.value;
    float _S1773 = (F32_sqrt((-2.0f * clamp_1((F32_log((_S1771.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S1771.state, _S1773 * (F32_cos((_S1772))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_4, float3  value_2)
{
    RandomSphere _S1774;
    (&_S1774)->state = state_4;
    (&_S1774)->value = value_2;
    return _S1774;
}

__device__ RandomSphere random_sphere(uint state_5)
{
    Random _S1775 = normal_distribution(state_5);
    Random _S1776 = normal_distribution(_S1775.state);
    Random _S1777 = normal_distribution(_S1776.state);
    float3  _S1778 = make_float3 (_S1775.value, _S1776.value, _S1777.value);
    float3  _S1779 = ((((_S1778)) * make_float3(rnorm3df(((_S1778)).x, ((_S1778)).y, ((_S1778)).z))));
    return RandomSphere_x24init_0(_S1777.state, _S1779);
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_12)
{
    float3  _S1780 = p1_0 - p0_0;
    float3  _S1781 = p2_0 - p0_0;
    float2  _S1782 = uv1_0 - uv0_0;
    float2  _S1783 = uv2_0 - uv0_0;
    float _S1784 = _S1782.x;
    float _S1785 = _S1783.y;
    float _S1786 = _S1782.y;
    float _S1787 = _S1783.x;
    float _S1788 = _S1784 * _S1785 - _S1786 * _S1787;
    float _S1789 = 1.0f / _S1788;
    float3  t_21 = (_S1780 * make_float3 (_S1785) - _S1781 * make_float3 (_S1786)) * make_float3 (_S1789);
    float3  _S1790 = (_S1781 * make_float3 (_S1784) - _S1780 * make_float3 (_S1787)) * make_float3 (_S1789);
    float3  _S1791 = t_21 - n_12 * make_float3 (dot_0(n_12, t_21));
    float3  t_22 = ((((_S1791)) * make_float3(rnorm3df(((_S1791)).x, ((_S1791)).y, ((_S1791)).z))));
    bool _S1792 = (dot_0(cross_0(n_12, t_22), _S1790)) > 0.0f;
    float3  t_23;
    if(_S1792)
    {
        float3  _S1793 = negate_0(t_22);
        t_23 = _S1793;
    }
    else
    {
        t_23 = t_22;
    }
    float3  _S1794 = cross_0(n_12, t_23);
    return makeMatrix<float, 3, 3> (t_23, _S1794, n_12);
}

__device__ float3  tangentToWorldNormalMap(float3  v_5, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_5, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_4, float3  uvw_0, float3  position_0)
{
    float3  _S1795 = t1_0 - t0_0;
    float3  _S1796 = t2_2 - t0_0;
    float3  _S1797 = t2_2 - t1_0;
    float _S1798 = (F32_min((length_0(_S1795)), ((F32_min((length_0(_S1796)), (length_0(_S1797)))))));
    float3  _S1799 = make_float3 (distance_1(position_0, t0_0), distance_1(position_0, t1_0), distance_1(position_0, t2_2));
    float3  _S1800 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S1801 = dot_0(geometry_n_4, _S1800);
    float3  _S1802 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S1803 = dot_0(geometry_n_4, _S1802);
    float3  _S1804 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S1805 = acos_0(abs_0(make_float3 (_S1801, _S1803, dot_0(geometry_n_4, _S1804))));
    float3  _S1806 = clamp_2(tan_0(_S1805), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_1(dot_0(_S1799 * _S1806, uvw_0), 0.0f, _S1798 * 0.125f);
}

__device__ float3  straightThrough(float3  dir_14, float3  n_13, BSDFMaterial material_23)
{
    float3  _S1807 = negate_0(dir_14);
    float _S1808 = sign_0(dot_0(n_13, _S1807));
    float3  _S1809 = n_13 * make_float3 (_S1808);
    AnisotropicFrame _S1810 = anisotropicFrame(material_23, _S1809);
    bool _S1811 = (_S1810.alphas.x) > 0.0f;
    if(_S1811)
    {
        float _S1812 = material_23.transmission * (1.0f - material_23.metallic);
        float3  _S1813 = negate_0(_S1809);
        float3  _S1814 = anisotropicLocal(dir_14, _S1810.tangent, _S1813);
        float _S1815 = anisotropicG1(_S1814, _S1810.alphas);
        return make_float3 (_S1812 * _S1815) * material_23.albedo;
    }
    float _S1816 = material_23.transmission * (1.0f - material_23.metallic);
    float _S1817 = material_23.roughness;
    float _S1818 = smithG1(_S1817 * _S1817, (F32_abs((dot_0(n_13, dir_14)))));
    return make_float3 (_S1816 * _S1818) * material_23.albedo;
}

__device__ float hairRow(float3  in_dir_11, float3  t_24, float3  out_dir_3, uint p_13, float w_2, float alpha_20, uint nt_0)
{
    uint _S1819 = p_13 % 4U;
    float _S1820 = w_2 * HAIR_WIDTHS_0[_S1819];
    float _S1821 = (F32_asin((clamp_1(dot_0(out_dir_3, t_24), -1.0f, 1.0f)))) - (F32_asin((clamp_1(dot_0(in_dir_11, t_24), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S1819] * alpha_20;
    return ((F32_asinh((_S1821 / _S1820))) / (F32_asinh((3.14159274101257324f / _S1820))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_12, float3  t_25, float3  out_dir_4, uint np_0)
{
    float3  _S1822 = worldToTangent(out_dir_4, t_25);
    float3  _S1823 = worldToTangent(in_dir_12, t_25);
    return (F32_frac((((F32_atan2((_S1822.z), (_S1822.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S1823.z), (1.17549435082228751e-38f - _S1823.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_13, float3  t_26, uint p_14, float row_0, float column_0, float w_3, float alpha_21, uint nt_1, uint np_1)
{
    float3  _S1824 = worldToTangent(in_dir_13, t_26);
    uint _S1825 = p_14 % 4U;
    float _S1826 = w_3 * HAIR_WIDTHS_0[_S1825];
    float _S1827 = (F32_asin((clamp_1(dot_0(in_dir_13, t_26), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S1825] * alpha_21 + _S1826 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S1826))))));
    float _S1828 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S1824.z), (1.17549435082228751e-38f - _S1824.x)));
    float _S1829 = (F32_cos((_S1827)));
    float3  _S1830 = tangentToWorld(make_float3 (_S1829 * (F32_cos((_S1828))), (F32_sin((_S1827))), _S1829 * (F32_sin((_S1828)))), t_26);
    return _S1830;
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_14, BSDFMaterial material_24, float coverage_1)
{
    float3  _S1831;
    if((material_24.ior) == 1.0f)
    {
        float3  _S1832 = straightThrough(toward_1, n_14, material_24);
        _S1831 = _S1832;
    }
    else
    {
        _S1831 = make_float3 (0.0f);
    }
    return _S1831 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ Shift walk_hook(Domain dom_8, Reservoir r_9, bool replay_2, float scale_4, Selection * sel_8)
{
    Domain _S1833 = dom_8;
    Reservoir _S1834 = r_9;
    Shift _S1835 = walk_0(&_S1833, &_S1834, replay_2, scale_4, sel_8);
    return _S1835;
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
