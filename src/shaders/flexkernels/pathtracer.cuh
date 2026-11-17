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
        int2  _S150 = make_int2 (int(-1));
        bool _S151 = previousValid_0(p_7);
        int2  _S152 = _slang_select(_S151, p_7,_S150);
        return _S152;
    }
    float3  _S153 = make_float3 (0.0f);
    FKHit _S154 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S155 = Domain_x24init_0(_S153, _S153, &_S154, 0.0f, 0.0f);
    Domain dom_3 = _S155;
    uint2  _S156 = (fcptRenderSize());
    int2  _S157 = make_int2 ((int)_S156.x, (int)_S156.y);
    bool _S158 = any_0(p_7 >= _S157);
    bool _S159;
    if(_S158)
    {
        _S159 = true;
    }
    else
    {
        bool _S160 = (fcptStoredDomainInitial((p_7), (seed_2), (&dom_3)));
        _S159 = !_S160;
    }
    if(_S159)
    {
        return make_int2 (int(-1));
    }
    Domain _S161 = dom_3;
    int2  _S162 = temporalNeighbor_0(p_7, &_S161, seed_2);
    return _S162;
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
    FKRay _S163;
    (&_S163)->origin = origin_0;
    (&_S163)->unit_direction = unit_direction_0;
    return _S163;
}

static __device__ float3  skyRadiance_0(float3  origin_1, FKSurface * surface_0, bool is_inside_1, float3  dir_1, ShadowContext * context_0, uint random_state_0)
{
    bool _S164 = wrongSide_0(is_inside_1, false, dir_1, surface_0->geometry_n);
    bool _S165 = is_inside_1 != _S164;
    float _S166 = surface_0->geometry_offset;
    float3  _S167 = surface_0->smooth_n;
    float3  _S168 = - surface_0->smooth_n;
    float3  _S169 = _slang_select(_S165, _S168,_S167);
    FKRay _S170 = Ray_x24init_0(origin_1 + make_float3 (_S166) * _S169, dir_1);
    bool _S171 = (dot_0(context_0->side, dir_1)) > 0.0f;
    float3  _S172 = (fcptEnvMapSample((dir_1), (0U), (3U)));
    float3  _S173 = context_0->extinction_behind;
    float3  _S174 = context_0->extinction_front;
    float3  _S175 = _slang_select(_S171, _S174,_S173);
    uint _S176 = context_0->fillings.x;
    uint _S177 = context_0->fillings.y;
    uint _S178 = _slang_select(_S171, _S177,_S176);
    uint _S179 = context_0->depth;
    uint _S180 = context_0->lobe;
    bool _S181 = context_0->surface;
    bool _S182;
    if(_S181)
    {
        _S182 = !context_0->fiber;
    }
    else
    {
        _S182 = false;
    }
    float _S183 = context_0->length;
    float _S184 = context_0->width;
    FKHit _S185 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    float3  _S186 = (fcptShadowTransmittanceIn((_S170), (4.294967296e+09f), (_S175), (_S178), (random_state_0), (_S179), (_S180), (_S182), (_S183), (_S184), (_S185), (_S185)));
    return _S172 * _S186;
}

static __device__ uint searchCDF_0(uint2  start_4, uint2  step_0, uint count_1, float u_0)
{
    uint _S187 = count_1 - 1U;
    uint low_0 = 0U;
    uint high_0 = _S187;
    for(;;)
    {
        if(low_0 < high_0)
        {
        }
        else
        {
            break;
        }
        uint _S188 = (low_0 + high_0) / 2U;
        float4  _S189 = (fcptEnvironmentCdf((start_4 + step_0 * make_uint2 (_S188))));
        bool _S190 = (_S189.x) > u_0;
        if(_S190)
        {
            high_0 = _S188;
        }
        else
        {
            uint _S191 = _S188 + 1U;
            low_0 = _S191;
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
    float3  _S192 = ((((light_dir_0)) * make_float3(rnorm3df(((light_dir_0)).x, ((light_dir_0)).y, ((light_dir_0)).z))));
    bool _S193 = (dot_0(smooth_n_0, _S192)) < 0.0f;
    if(_S193)
    {
        return make_float3 (0.0f);
    }
    float3  _S194 = make_float3 (geometry_offset_0) * smooth_n_0;
    float3  _S195 = origin_2 + _S194;
    FKRay _S196 = Ray_x24init_0(_S195, _S192);
    bool _S197 = (dot_0(context_1->side, light_dir_0 + _S194)) > 0.0f;
    float _S198 = shadowLength(light_dir_0);
    float3  _S199 = context_1->extinction_behind;
    float3  _S200 = context_1->extinction_front;
    float3  _S201 = _slang_select(_S197, _S200,_S199);
    uint _S202 = context_1->fillings.x;
    uint _S203 = context_1->fillings.y;
    uint _S204 = _slang_select(_S197, _S203,_S202);
    uint _S205 = context_1->depth;
    uint _S206 = context_1->lobe;
    bool _S207 = context_1->surface;
    bool _S208;
    if(_S207)
    {
        _S208 = !context_1->fiber;
    }
    else
    {
        _S208 = false;
    }
    float _S209 = context_1->length;
    float _S210 = context_1->width;
    FKHit _S211;
    if(context_1->fiber)
    {
        _S211 = context_1->own;
    }
    else
    {
        _S211 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    }
    float3  _S212 = (fcptShadowTransmittanceIn((_S196), (_S198), (_S201), (_S204), (random_state_1), (_S205), (_S206), (_S208), (_S209), (_S210), (_S211), (*light_0)));
    return _S212;
}

__device__ float sine(float c_0)
{
    return (F32_sqrt(((F32_max((1.0f - c_0 * c_0), (0.0f))))));
}

__device__ float cosSubClamped(float sin_a_0, float cos_a_0, float sin_b_0, float cos_b_0)
{
    float _S213 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    bool _S214 = cos_a_0 > cos_b_0;
    float _S215 = _slang_select(_S214, 1.0f,_S213);
    return _S215;
}

__device__ float importance(LightNode node_0, float3  p_8, float3  normal_0)
{
    float3  _S216 = (node_0.low + node_0.high) * make_float3 (0.5f);
    float3  _S217 = node_0.high - node_0.low;
    float3  _S218 = p_8 - _S216;
    float3  _S219 = ((((_S218)) * make_float3(rnorm3df(((_S218)).x, ((_S218)).y, ((_S218)).z))));
    float _S220 = dot_0(_S218, _S218);
    float _S221 = dot_0(_S217, _S217) / 4.0f;
    float _S222 = (F32_abs((dot_0(node_0.w, _S219))));
    float _S223 = sine(node_0.cos_theta_o);
    float _S224 = (F32_sqrt(((F32_max((1.0f - _S221 / _S220), (0.0f))))));
    bool _S225 = _S220 < _S221;
    float _S226 = _slang_select(_S225, -1.0f,_S224);
    float _S227 = sine(_S226);
    float _S228 = sine(_S222);
    float _S229 = cosSubClamped(_S228, _S222, _S223, node_0.cos_theta_o);
    float _S230 = sine(_S222);
    float _S231 = _S230 * node_0.cos_theta_o - _S222 * _S223;
    bool _S232 = _S222 > (node_0.cos_theta_o);
    float _S233 = _slang_select(_S232, 0.0f,_S231);
    float _S234 = cosSubClamped(_S233, _S229, _S227, _S226);
    bool _S235 = _S234 <= 0.0f;
    if(_S235)
    {
        return 0.0f;
    }
    float _S236 = - dot_0(_S219, normal_0);
    float _S237 = node_0.phi * _S234 / (F32_max((_S220), (length_0(_S217) / 2.0f)));
    float _S238 = sine(_S236);
    float _S239 = cosSubClamped(_S238, _S236, _S227, _S226);
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
        FKLight _S280 = (fcptLight((_S278.y)));
        float _S281 = sphereDensity(_S280.position, _S280.variance, start_5);
        return probability_1 * _S281;
    }
    uint _S282 = _S278.y;
    uint _S283 = (fcptTriangleOffset((_S282)));
    Matrix<float, 3, 3>  _S284 = (fcptWorldTriangle((_S282), (_S283 + _S278.z)));
    float _S285 = solidAngle(probability_1, cross_0(_S284.rows[int(1)] - _S284.rows[int(0)], _S284.rows[int(2)] - _S284.rows[int(0)]), light_point_0 - start_5);
    return _S285;
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
    Random _S286;
    (&_S286)->state = state_0;
    (&_S286)->value = value_0;
    return _S286;
}

__device__ Random pcg(uint state_1)
{
    uint _S287 = hash(state_1);
    float value_1 = float(_S287 >> int(8)) * 5.9604644775390625e-08f;
    return Random_x24init_0(_S287, value_1);
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
    uint2  _S288 = (fcptEnvironmentCdfSize());
    uint2  _S289 = _S288 - make_uint2 (1U, 0U);
    float2  _S290 = make_float2 ((F32_atan2((- dir_2.y), (dir_2.x))) / 6.28318548202514648f + 0.5f, (F32_acos((clamp_1(dir_2.z, -1.0f, 1.0f)))) / 3.14159274101257324f);
    float2  _S291 = make_float2 ((float)_S289.x, (float)_S289.y);
    float2  _S292 = _S290 * _S291;
    uint2  _S293 = make_uint2 ((uint)_S292.x, (uint)_S292.y);
    uint2  _S294 = min_0(_S293, _S289 - make_uint2 (1U));
    float4  _S295 = (fcptEnvironmentCdf((_S294)));
    float _S296 = _S295.y;
    uint _S297 = _S289.x;
    float4  _S298 = (fcptEnvironmentCdf((make_uint2 (_S297, _S294.y))));
    float _S299 = _S296 * _S298.y;
    return _S299 * float(_S297 * _S289.y) / (19.73921012878417969f * length_1(float2 {dir_2.x, dir_2.y}));
}

static __device__ float3  negate_0(float3  x_13)
{
    return - x_13;
}

static __device__ float sign_0(float e_1)
{
    bool _S300 = e_1 < 0.0f;
    float _S301 = _slang_select(_S300, -1.0f,0.0f);
    bool _S302 = e_1 > 0.0f;
    float _S303 = _slang_select(_S302, 1.0f,_S301);
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

struct SheenProfile
{
    bool on;
    float albedo;
};

static __device__ SheenProfile SheenProfile_x24init_0(bool on_0, float albedo_0)
{
    SheenProfile _S324;
    (&_S324)->on = on_0;
    (&_S324)->albedo = albedo_0;
    return _S324;
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
    SheenProfile _S325 = SheenProfile_x24init_0(false, 0.0f);
    float _S326 = rgb_to_greyscale(material_1.sheen);
    bool _S327 = _S326 > 0.0f;
    SheenProfile profile_0;
    if(_S327)
    {
        float _S328 = clamp_1((F32_sqrt(((F32_max((dot_0(n_i_1, v_1)), (0.0f)))))), 0.0f, 1.0f) * 23.0f;
        uint _S329 = (U32_min((uint(_S328)), (22U)));
        float _S330 = (F32_sqrt((0.05000000074505806f)));
        float _S331 = (F32_sqrt((0.00999999977648258f)));
        bool _S332 = (material_1.velvet) > 0.0f;
        float _S333 = _slang_select(_S332, _S331,_S330);
        float _S334 = (clamp_1((F32_sqrt(((F32_max((material_1.sheen_roughness), (0.0f)))))), _S333, 1.0f) - _S333) / (1.0f - _S333) * 23.0f;
        uint _S335 = (U32_min((uint(_S334)), (22U)));
        uint _S336 = _S329 * 24U + _S335;
        float _S337 = _S328 - float(_S329);
        float _S338 = _S334 - float(_S335);
        if(_S332)
        {
            uint _S339 = _S336 + 24U;
            float _S340 = VELVET_ALBEDO_0[_S336] + (VELVET_ALBEDO_0[_S339] - VELVET_ALBEDO_0[_S336]) * _S337;
            uint _S341 = _S336 + 1U;
            float _S342 = VELVET_ALBEDO_0[_S341] + (VELVET_ALBEDO_0[_S339 + 1U] - VELVET_ALBEDO_0[_S341]) * _S337;
            SheenProfile _S343 = SheenProfile_x24init_0(true, _S340 + (_S342 - _S340) * _S338);
            profile_0 = _S343;
        }
        else
        {
            uint _S344 = _S336 + 24U;
            float _S345 = SHEEN_ALBEDO_0[_S336] + (SHEEN_ALBEDO_0[_S344] - SHEEN_ALBEDO_0[_S336]) * _S337;
            uint _S346 = _S336 + 1U;
            float _S347 = SHEEN_ALBEDO_0[_S346] + (SHEEN_ALBEDO_0[_S344 + 1U] - SHEEN_ALBEDO_0[_S346]) * _S337;
            SheenProfile _S348 = SheenProfile_x24init_0(true, (F32_exp((_S345 + (_S347 - _S345) * _S338))));
            profile_0 = _S348;
        }
    }
    else
    {
        profile_0 = _S325;
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
    BSDFLobes _S349;
    (&_S349)->v_dot_h = v_dot_h_0;
    (&_S349)->n_dot_h = n_dot_h_0;
    (&_S349)->refracted = refracted_1;
    (&_S349)->F = F_0;
    (&_S349)->F_greyscale = F_greyscale_0;
    (&_S349)->reflect_weight = reflect_weight_0;
    (&_S349)->diffuse_weight = diffuse_weight_0;
    (&_S349)->refract_weight = refract_weight_0;
    (&_S349)->p_diffuse = p_diffuse_0;
    (&_S349)->p_reflect = p_reflect_0;
    (&_S349)->p_refract = p_refract_0;
    (&_S349)->translucent_share = translucent_share_0;
    (&_S349)->sheen = sheen_0;
    (&_S349)->p_sheen_velvet = p_sheen_velvet_0;
    (&_S349)->view = view_0;
    (&_S349)->tangent = tangent_1;
    (&_S349)->alphas = alphas_1;
    (&_S349)->visible = visible_0;
    (&_S349)->p_toon = p_toon_0;
    (&_S349)->toon = toon_0;
    (&_S349)->toon_a = toon_a_0;
    (&_S349)->toon_s = toon_s_0;
    (&_S349)->toon_b = toon_b_0;
    (&_S349)->toon_glossy = toon_glossy_0;
    (&_S349)->toon_norm = toon_norm_0;
    (&_S349)->toon_view = toon_view_0;
    (&_S349)->toon_axis = toon_axis_0;
    return _S349;
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
    float3  _S350 = make_float3 (alpha_0 * Ve_0.x, alpha_0 * Ve_0.y, Ve_0.z);
    float3  _S351 = ((((_S350)) * make_float3(rnorm3df(((_S350)).x, ((_S350)).y, ((_S350)).z))));
    float _S352 = _S351.x;
    float _S353 = _S351.y;
    float _S354 = _S352 * _S352 + _S353 * _S353;
    float3  _S355 = make_float3 (1.0f, 0.0f, 0.0f);
    float3  _S356 = make_float3 (- _S353, _S352, 0.0f);
    float _S357 = (rsqrtf((_S354)));
    float3  _S358 = _S356 * make_float3 (_S357);
    bool _S359 = _S354 > 0.0f;
    float3  _S360 = _slang_select(_S359, _S358,_S355);
    float3  _S361 = cross_0(_S351, _S360);
    float _S362 = (F32_sqrt((U1_0)));
    float _S363 = 6.28318548202514648f * U2_0;
    float _S364 = _S362 * (F32_cos((_S363)));
    float t2_0 = _S362 * (F32_sin((_S363)));
    float _S365 = 0.5f * (1.0f + _S351.z);
    float t2_1 = (1.0f - _S365) * (F32_sqrt(((F32_max((0.0f), (1.0f - _S364 * _S364)))))) + _S365 * t2_0;
    float3  _S366 = make_float3 (_S364) * _S360 + make_float3 (t2_1) * _S361;
    float _S367 = unshared_0(_S364);
    float _S368 = unshared_0(_S364);
    float3  _S369 = _S366 + make_float3 ((F32_sqrt(((F32_max((0.0f), (1.0f - _S367 * _S368 - t2_1 * t2_1))))))) * _S351;
    float3  _S370 = make_float3 (alpha_0 * _S369.x, alpha_0 * _S369.y, (F32_max((0.0f), (_S369.z))));
    float3  _S371 = ((((_S370)) * make_float3(rnorm3df(((_S370)).x, ((_S370)).y, ((_S370)).z))));
    return _S371;
}

__device__ float3  worldToTangent(float3  v_2, float3  n_3)
{
    float3  a_3 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S372 = (F32_abs((dot_0(n_3, a_3)))) > 0.9999847412109375f;
    float3  a_4;
    if(_S372)
    {
        float3  _S373 = make_float3 (1.0f, 0.0f, 0.0f);
        a_4 = _S373;
    }
    else
    {
        a_4 = a_3;
    }
    float3  _S374 = cross_0(n_3, a_4);
    float3  _S375 = ((((_S374)) * make_float3(rnorm3df(((_S374)).x, ((_S374)).y, ((_S374)).z))));
    float3  _S376 = cross_0(n_3, _S375);
    return make_float3 (dot_0(v_2, _S375), dot_0(v_2, n_3), dot_0(v_2, _S376));
}

__device__ __forceinline__ float3  sampleHalfVector(float3  v_3, float3  n_i_2, float alpha_1, AnisotropicFrame frame_0, uint * random_state_2)
{
    Random _S377 = pcg(*random_state_2);
    Random _S378 = pcg(_S377.state);
    *random_state_2 = _S378.state;
    float _S379 = frame_0.alphas.x;
    bool _S380 = _S379 > 0.0f;
    if(_S380)
    {
        float3  _S381 = anisotropicLocal(v_3, frame_0.tangent, n_i_2);
        float _S382 = frame_0.alphas.y;
        float3  _S383 = make_float3 (_S379 * _S381.x, _S382 * _S381.y, _S381.z);
        float3  _S384 = ((((_S383)) * make_float3(rnorm3df(((_S383)).x, ((_S383)).y, ((_S383)).z))));
        float3  _S385 = sampleGGXVNDF(_S384, 1.0f, _S377.value, _S378.value);
        float3  _S386 = make_float3 (_S379 * _S385.x, _S382 * _S385.y, _S385.z);
        float3  _S387 = ((((_S386)) * make_float3(rnorm3df(((_S386)).x, ((_S386)).y, ((_S386)).z))));
        return make_float3 (_S387.x) * frame_0.tangent + make_float3 (_S387.y) * cross_0(n_i_2, frame_0.tangent) + make_float3 (_S387.z) * n_i_2;
    }
    float3  _S388 = worldToTangent(v_3, n_i_2);
    float3  _S389 = sampleGGXVNDF(float3 {_S388.x, _S388.z, _S388.y}, alpha_1, _S377.value, _S378.value);
    float3  _S390 = float3 {_S389.x, _S389.z, _S389.y};
    float3  _S391 = tangentToWorld(_S390, n_i_2);
    return _S391;
}

__device__ float3  sampledHalf(float3  in_dir_0, float3  n_4, BSDFMaterial material_2, uint random_state_3, AnisotropicFrame frame_1)
{
    uint state_2 = random_state_3;
    float3  _S392 = negate_0(in_dir_0);
    float _S393 = sign_0(dot_0(n_4, _S392));
    float _S394 = material_2.roughness;
    float3  _S395 = sampleHalfVector(_S392, n_4 * make_float3 (_S393), _S394 * _S394, frame_1, &state_2);
    return _S395;
}

__device__ float3  refractedHalf(float3  in_dir_1, float3  out_dir_0, float3  n_5, float eta_i_0, float eta_o_0)
{
    float3  _S396 = negate_0(in_dir_1);
    float3  _S397 = negate_0(make_float3 (eta_i_0) * _S396 + make_float3 (eta_o_0) * out_dir_0);
    float3  _S398 = ((((_S397)) * make_float3(rnorm3df(((_S397)).x, ((_S397)).y, ((_S397)).z))));
    float _S399 = sign_0(dot_0(n_5, _S396));
    float _S400 = sign_0(dot_0(_S397, n_5 * make_float3 (_S399)));
    return _S398 * make_float3 (_S400);
}

__device__ float3  reflectedHalf(float3  in_dir_2, float3  out_dir_1)
{
    float3  _S401 = negate_0(in_dir_2);
    float3  _S402 = _S401 + out_dir_1;
    float3  _S403 = ((((_S402)) * make_float3(rnorm3df(((_S402)).x, ((_S402)).y, ((_S402)).z))));
    return _S403;
}

static __device__ float3  refract_0(float3  i_5, float3  n_6, float eta_0)
{
    float _S404 = dot_0(n_6, i_5);
    float _S405 = 1.0f - eta_0 * eta_0 * (1.0f - _S404 * _S404);
    if(_S405 < 0.0f)
    {
        return make_float3 (0.0f);
    }
    return make_float3 (eta_0) * i_5 - make_float3 (eta_0 * _S404 + (F32_sqrt((_S405)))) * n_6;
}

__device__ float fresnel(float cos_theta_0, float eta_i_1, float eta_o_1)
{
    float _S406 = (F32_sqrt(((F32_max((0.0f), (1.0f - cos_theta_0 * cos_theta_0))))));
    float _S407 = eta_i_1 / eta_o_1 * _S406;
    bool _S408 = _S407 < 1.0f;
    float kr_0;
    if(_S408)
    {
        float _S409 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S407 * _S407))))));
        bool _S410 = eta_i_1 == eta_o_1;
        float _S411 = _slang_select(_S410, cos_theta_0,_S409);
        float _S412 = eta_o_1 * cos_theta_0;
        float _S413 = eta_i_1 * _S411;
        float _S414 = (_S412 - _S413) / (_S412 + _S413);
        float _S415 = eta_i_1 * cos_theta_0;
        float _S416 = eta_o_1 * _S411;
        float _S417 = (_S415 - _S416) / (_S415 + _S416);
        float _S418 = (_S414 * _S414 + _S417 * _S417) / 2.0f;
        kr_0 = _S418;
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
    float _S419 = (F32_max((w_1.z), (0.0f)));
    return 2.0f * _S419 / (_S419 + length_0(make_float3 (alphas_2.x * w_1.x, alphas_2.y * w_1.y, _S419)));
}

__device__ float anisotropicD(float3  h_0, float2  alphas_3)
{
    float _S420 = alphas_3.x;
    float _S421 = h_0.x / _S420;
    float _S422 = alphas_3.y;
    float _S423 = h_0.y / _S422;
    float _S424 = h_0.z;
    float _S425 = _S421 * _S421 + _S423 * _S423 + _S424 * _S424;
    return 1.0f / (F32_max((3.14159274101257324f * _S420 * _S422 * _S425 * _S425), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ BSDFLobes bsdfLobes(float3  in_dir_3, float3  v_4, float3  n_i_3, float3  ggx_n_0, BSDFMaterial material_3, float eta_i_2, float eta_o_2, AnisotropicFrame frame_2, SheenProfile sheen_profile_0)
{
    float _S426 = dot_0(ggx_n_0, v_4);
    float _S427 = dot_0(n_i_3, ggx_n_0);
    float _S428 = eta_i_2 / eta_o_2;
    float3  _S429 = refract_0(in_dir_3, ggx_n_0, _S428);
    float3  _S430 = ((((_S429)) * make_float3(rnorm3df(((_S429)).x, ((_S429)).y, ((_S429)).z))));
    float _S431 = (F32_min(((F32_sqrt((material_3.specular_level))) * (F32_abs((eta_i_2 - eta_o_2))) / (eta_i_2 + eta_o_2)), (0.9999847412109375f)));
    float _S432 = _S431 * _S431;
    float _S433 = (1.0f + _S431) / (1.0f - _S431);
    float _S434 = (F32_abs((_S426)));
    bool _S435 = eta_i_2 > eta_o_2;
    float _S436 = _slang_select(_S435, _S433,1.0f);
    float _S437 = _slang_select(_S435, 1.0f,_S433);
    float _S438 = fresnel(_S434, _S436, _S437);
    bool _S439 = (eta_i_2 * eta_i_2 * (1.0f - _S426 * _S426)) >= (eta_o_2 * eta_o_2);
    float3  _S440 = material_3.specular_tint * make_float3 (_S432);
    float3  _S441 = _S440 + (make_float3 (1.0f) - _S440) * make_float3 (_S438 - _S432) / make_float3 (1.0f - _S432);
    float3  _S442 = make_float3 (1.0f);
    float3  _S443 = _slang_select(_S439, _S442,_S441);
    float3  _S444 = make_float3 (0.0f);
    float sheen_component_0;
    float3  sheen_1;
    float3  view_1;
    float3  scale_1;
    if(sheen_profile_0.on)
    {
        float _S445 = (F32_min((sheen_profile_0.albedo), (1.0f)));
        float3  _S446 = make_float3 (1.0f) - material_3.sheen * make_float3 (_S445);
        float _S447 = rgb_to_greyscale(material_3.sheen);
        float _S448 = _S447 * _S445;
        float3  _S449 = material_3.sheen / make_float3 ((F32_max((sheen_profile_0.albedo), (1.0f))));
        sheen_component_0 = _S448;
        sheen_1 = _S449;
        view_1 = v_4;
        scale_1 = _S446;
    }
    else
    {
        sheen_component_0 = 0.0f;
        sheen_1 = _S444;
        view_1 = _S444;
        scale_1 = _S442;
    }
    float _S450 = material_3.toon.x;
    bool _S451 = _S450 < 0.0f;
    float _S452 = (F32_abs((_S450)));
    bool _S453 = _S452 > 0.0f;
    float toon_component_0;
    float toon_a_1;
    float toon_s_1;
    float toon_b_1;
    float toon_norm_1;
    float toon_view_1;
    float3  toon_1;
    float3  toon_axis_1;
    bool _S454;
    if(_S453)
    {
        float _S455 = (F32_min((_S452), (1.0f)));
        float3  scale_2 = scale_1 * make_float3 (1.0f - _S455);
        float _S456 = rgb_to_greyscale(material_3.albedo);
        float _S457 = _S455 * _S456;
        float3  _S458 = make_float3 (_S455) * material_3.albedo;
        float toon_a_2 = clamp_1(material_3.toon.y / _S450, 0.00000999999974738f, 1.0f) * 3.14159274101257324f / 2.0f;
        float toon_s_2 = clamp_1(material_3.toon.z / _S450, 0.0f, 1.0f) * 3.14159274101257324f / 2.0f;
        float _S459 = (F32_min((toon_a_2 + toon_s_2), (1.57079637050628662f)));
        if(_S451)
        {
            toon_component_0 = 1.0f - (F32_cos(((F32_min((_S459), (toon_a_2))))));
        }
        else
        {
            float _S460 = (F32_sin(((F32_min((_S459), (toon_a_2))))));
            toon_component_0 = _S460 * _S460 / 2.0f;
        }
        bool _S461 = _S459 > toon_a_2;
        if(_S461)
        {
            _S454 = toon_s_2 > 0.0f;
        }
        else
        {
            _S454 = false;
        }
        if(_S454)
        {
            if(_S451)
            {
                float _S462 = (F32_cos((toon_a_2)));
                float _S463 = (F32_cos((_S459)));
                toon_a_1 = (1.0f + toon_a_2 / toon_s_2) * (_S462 - _S463) - ((F32_sin((_S459))) - _S459 * _S463 - ((F32_sin((toon_a_2))) - toon_a_2 * _S462)) / toon_s_2;
            }
            else
            {
                float _S464 = 2.0f * toon_a_2;
                float _S465 = (F32_cos((_S464)));
                float _S466 = 2.0f * _S459;
                float _S467 = (F32_cos((_S466)));
                toon_a_1 = (1.0f + toon_a_2 / toon_s_2) * (_S465 - _S467) / 4.0f - ((F32_sin((_S466))) / 8.0f - _S459 * _S467 / 4.0f - ((F32_sin((_S464))) / 8.0f - toon_a_2 * _S465 / 4.0f)) / toon_s_2;
            }
            float integral_0 = toon_component_0 + toon_a_1;
            toon_component_0 = integral_0;
        }
        float _S468 = 6.28318548202514648f * toon_component_0;
        float _S469 = dot_0(n_i_3, v_4);
        float _S470 = (F32_acos(((F32_min((_S469), (1.0f))))));
        if(_S470 < toon_a_2)
        {
            toon_component_0 = 1.0f;
        }
        else
        {
            toon_component_0 = (F32_max((1.0f - (_S470 - toon_a_2) / (F32_max((toon_s_2), (0.0000152587890625f)))), (0.0f)));
        }
        if(_S451)
        {
            float3  _S471 = make_float3 (2.0f * _S469) * n_i_3 - v_4;
            float3  _S472 = ((((_S471)) * make_float3(rnorm3df(((_S471)).x, ((_S471)).y, ((_S471)).z))));
            scale_1 = _S472;
        }
        else
        {
            scale_1 = n_i_3;
        }
        float _S473 = toon_component_0;
        toon_component_0 = _S457;
        toon_1 = _S458;
        toon_a_1 = toon_a_2;
        toon_s_1 = toon_s_2;
        toon_b_1 = _S459;
        toon_norm_1 = _S468;
        toon_view_1 = _S473;
        toon_axis_1 = scale_1;
        scale_1 = scale_2;
    }
    else
    {
        toon_component_0 = 0.0f;
        toon_1 = _S444;
        toon_a_1 = 0.0f;
        toon_s_1 = 0.0f;
        toon_b_1 = 0.0f;
        toon_norm_1 = 1.0f;
        toon_view_1 = 0.0f;
        toon_axis_1 = n_i_3;
    }
    float3  _S474 = mix_0(_S443, material_3.albedo, material_3.metallic);
    float3  F_1 = _S474 * scale_1;
    float _S475 = rgb_to_greyscale(F_1);
    float _S476 = 1.0f - material_3.metallic;
    float3  _S477 = make_float3 (1.0f) - _S443;
    float3  _S478 = make_float3 ((1.0f - material_3.transmission) * _S476) * _S477 * scale_1;
    float3  _S479 = make_float3 (material_3.transmission * _S476) * _S477 * scale_1;
    float _S480 = (F32_max((_S475), (0.0f)));
    float _S481 = rgb_to_greyscale(_S478);
    float _S482 = (F32_max((_S481), (0.0f)));
    float _S483 = rgb_to_greyscale(_S479);
    float _S484 = sign_0(length_0(_S430));
    float _S485 = (F32_max((_S483 * _S484), (0.0f)));
    float _S486 = _S480 + _S482 + _S485 + toon_component_0;
    float _S487 = (F32_min((sheen_component_0), (1.0f)));
    bool _S488 = sheen_component_0 > 0.0f;
    if(_S488)
    {
        _S454 = !(_S486 > 0.0f);
    }
    else
    {
        _S454 = false;
    }
    float _S489 = _slang_select(_S454, 1.0f,_S487);
    float _S490 = (1.0f - _S489) / (F32_max((_S486), (0.0000152587890625f)));
    float _S491 = _S482 * _S490;
    float _S492 = _S480 * _S490;
    float _S493 = _S485 * _S490;
    bool _S494 = (frame_2.alphas.x) > 0.0f;
    float visible_1;
    if(_S494)
    {
        float3  _S495 = anisotropicLocal(v_4, frame_2.tangent, n_i_3);
        float _S496 = anisotropicG1(_S495, frame_2.alphas);
        float3  _S497 = anisotropicLocal(ggx_n_0, frame_2.tangent, n_i_3);
        float _S498 = anisotropicD(_S497, frame_2.alphas);
        float _S499 = _S496 * _S498;
        visible_1 = _S499;
    }
    else
    {
        visible_1 = 0.0f;
    }
    return BSDFLobes_x24init_0(_S426, _S427, _S430, F_1, _S475, 1.0f, _S478, _S479, _S491, _S492, _S493, 0.0f, sheen_1, _S489, view_1, frame_2.tangent, frame_2.alphas, visible_1, toon_component_0 * _S490, toon_1, toon_a_1, toon_s_1, toon_b_1, _S451, toon_norm_1, toon_view_1, toon_axis_1);
}

__device__ float translucentShare(BSDFMaterial material_4)
{
    float _S500 = rgb_to_greyscale(material_4.translucent);
    float _S501 = rgb_to_greyscale(material_4.albedo);
    float _S502 = _S500 / (_S501 + _S500);
    bool _S503 = _S500 > 0.0f;
    float _S504 = _slang_select(_S503, _S502,0.0f);
    return _S504;
}

__device__ __forceinline__ float diffusePDF(float n_i_dot_l_0, float l_dot_h_0, float n_i_dot_v_0, float alpha_2, BSDFLobes lobes_0, float eta_i_3, float eta_o_3)
{
    float _S505 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    float _S506 = lobes_0.p_diffuse * (F32_abs((n_i_dot_l_0))) * 0.31830987334251404f;
    float _S507 = 1.0f - lobes_0.translucent_share;
    bool _S508 = n_i_dot_l_0 < 0.0f;
    float _S509 = _slang_select(_S508, lobes_0.translucent_share,_S507);
    float _S510 = _S506 * _S509;
    bool _S511 = (lobes_0.translucent_share) > 0.0f;
    float _S512 = _slang_select(_S511, _S510,_S505);
    bool _S513 = n_i_dot_v_0 > 0.0f;
    float _S514 = _slang_select(_S513, _S512,0.0f);
    return _S514;
}

__device__ __forceinline__ float3  diffuseBSDF(float3  l_0, float3  n_i_4, float alpha_3, BSDFMaterial material_5, BSDFLobes lobes_1)
{
    bool _S515 = (dot_0(n_i_4, l_0)) < 0.0f;
    float3  _S516 = _slang_select(_S515, material_5.translucent,material_5.albedo);
    float _S517 = 1.0f - lobes_1.translucent_share;
    float _S518 = _slang_select(_S515, lobes_1.translucent_share,_S517);
    float3  _S519 = _S516 / make_float3 (_S518);
    bool _S520 = (lobes_1.translucent_share) > 0.0f;
    float3  _S521 = _slang_select(_S520, _S519,material_5.albedo);
    return lobes_1.diffuse_weight * _S521 / make_float3 (lobes_1.p_diffuse);
}

__device__ float smithG1(float alpha_4, float n_dot_x_0)
{
    float _S522 = alpha_4 * alpha_4;
    float _S523 = 2.0f * n_dot_x_0 / (n_dot_x_0 + (F32_sqrt((_S522 + (1.0f - _S522) * n_dot_x_0 * n_dot_x_0))));
    bool _S524 = alpha_4 > 0.0f;
    float _S525 = _slang_select(_S524, _S523,1.0f);
    return _S525;
}

__device__ float trowbridgeReitz(float alpha_5, float n_dot_h_1)
{
    float _S526 = alpha_5 * alpha_5;
    float _S527 = (1.0f - n_dot_h_1) * (1.0f + n_dot_h_1) + _S526 * n_dot_h_1 * n_dot_h_1;
    return _S526 / (F32_max((3.14159274101257324f * _S527 * _S527), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ float vndfPDF(float n_i_dot_v_1, float alpha_6, BSDFLobes lobes_2)
{
    float _S528 = smithG1(alpha_6, n_i_dot_v_1);
    float _S529 = _S528 * lobes_2.v_dot_h;
    float _S530 = trowbridgeReitz(alpha_6, lobes_2.n_dot_h);
    float _S531 = _S529 * _S530 / n_i_dot_v_1;
    bool _S532 = alpha_6 > 0.0f;
    bool _S533;
    if(_S532)
    {
        _S533 = (lobes_2.v_dot_h) > 0.0f;
    }
    else
    {
        _S533 = false;
    }
    if(_S533)
    {
        _S533 = (lobes_2.n_dot_h) > 0.0f;
    }
    else
    {
        _S533 = false;
    }
    if(_S533)
    {
        _S533 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S533 = false;
    }
    float _S534 = _slang_select(_S533, _S531,0.0f);
    bool _S535 = (lobes_2.alphas.x) > 0.0f;
    float pdf_h_0;
    if(_S535)
    {
        float _S536 = lobes_2.visible * lobes_2.v_dot_h / n_i_dot_v_1;
        bool _S537 = (lobes_2.v_dot_h) > 0.0f;
        if(_S537)
        {
            _S533 = (lobes_2.n_dot_h) > 0.0f;
        }
        else
        {
            _S533 = false;
        }
        if(_S533)
        {
            _S533 = n_i_dot_v_1 > 0.0f;
        }
        else
        {
            _S533 = false;
        }
        float _S538 = _slang_select(_S533, _S536,0.0f);
        pdf_h_0 = _S538;
    }
    else
    {
        pdf_h_0 = _S534;
    }
    return pdf_h_0;
}

__device__ __forceinline__ float refractPDF(float n_i_dot_l_1, float l_dot_h_1, float n_i_dot_v_2, float alpha_7, BSDFLobes lobes_3, float eta_i_4, float eta_o_4)
{
    float _S539 = vndfPDF(n_i_dot_v_2, alpha_7, lobes_3);
    float _S540 = eta_i_4 * lobes_3.v_dot_h + eta_o_4 * l_dot_h_1;
    float _S541 = lobes_3.p_refract * _S539 * eta_o_4 * eta_o_4 * (F32_abs((l_dot_h_1))) / (_S540 * _S540);
    bool _S542 = eta_i_4 != eta_o_4;
    bool _S543;
    if(_S542)
    {
        _S543 = l_dot_h_1 < 0.0f;
    }
    else
    {
        _S543 = false;
    }
    float _S544 = _slang_select(_S543, _S541,0.0f);
    return _S544;
}

__device__ __forceinline__ float3  refractBSDF(float3  l_1, float3  n_i_5, float alpha_8, BSDFMaterial material_6, BSDFLobes lobes_4)
{
    float _S545 = - dot_0(n_i_5, l_1);
    float _S546 = smithG1(alpha_8, (F32_max((_S545), (0.0f))));
    bool _S547 = (lobes_4.alphas.x) > 0.0f;
    float G1_l_0;
    if(_S547)
    {
        float3  _S548 = negate_0(n_i_5);
        float3  _S549 = anisotropicLocal(l_1, lobes_4.tangent, _S548);
        float _S550 = anisotropicG1(_S549, lobes_4.alphas);
        G1_l_0 = _S550;
    }
    else
    {
        G1_l_0 = _S546;
    }
    return lobes_4.refract_weight * make_float3 (G1_l_0) * material_6.albedo / make_float3 (lobes_4.p_refract);
}

__device__ __forceinline__ float sheenVelvetPDF(float n_i_dot_l_2, float l_dot_h_2, float n_i_dot_v_3, float alpha_9, BSDFLobes lobes_5, float eta_i_5, float eta_o_5)
{
    float _S551 = lobes_5.p_sheen_velvet * 0.5f * 0.31830987334251404f;
    bool _S552 = n_i_dot_l_2 > 0.0f;
    bool _S553;
    if(_S552)
    {
        _S553 = n_i_dot_v_3 > 0.0f;
    }
    else
    {
        _S553 = false;
    }
    float _S554 = _slang_select(_S553, _S551,0.0f);
    return _S554;
}

__device__ __forceinline__ float3  sheenVelvetBSDF(float3  l_2, float3  n_i_6, float alpha_10, BSDFMaterial material_7, BSDFLobes lobes_6)
{
    float3  _S555 = l_2 + lobes_6.view;
    float3  _S556 = ((((_S555)) * make_float3(rnorm3df(((_S555)).x, ((_S555)).y, ((_S555)).z))));
    float _S557 = dot_0(n_i_6, _S556);
    float _S558 = (F32_max((dot_0(n_i_6, l_2)), (0.0f)));
    float _S559 = (F32_max((dot_0(n_i_6, lobes_6.view)), (0.0f)));
    float _S560 = 1.0f / (F32_max((material_7.sheen_roughness), (0.05000000074505806f)));
    float _S561 = 1.0f - _S557 * _S557;
    float _S562 = (2.0f + _S560) * (F32_pow(((F32_max((_S561), (0.0f)))), (0.5f * _S560))) * 0.5f * 0.31830987334251404f / (F32_max((4.0f * (_S558 + _S559 - _S558 * _S559)), (0.0000152587890625f)));
    bool _S563 = (material_7.velvet) > 0.0f;
    float f_1;
    if(_S563)
    {
        float _S564 = (F32_max((material_7.sheen_roughness), (0.00999999977648258f)));
        float _S565 = _S564 * _S564;
        float _S566 = (F32_max((_S561), (0.0000152587890625f)));
        float _S567 = (F32_exp((- _S557 * _S557 / (_S566 * _S565)))) / (3.14159274101257324f * _S565 * _S566 * _S566) * (F32_min((1.0f), (2.0f * _S557 * (F32_min((_S558), (_S559))) / (F32_max(((F32_abs((dot_0(_S556, lobes_6.view))))), (0.0000152587890625f)))))) / (F32_max((4.0f * _S558 * _S559), (0.0000152587890625f)));
        f_1 = _S567;
    }
    else
    {
        f_1 = _S562;
    }
    return lobes_6.sheen * make_float3 (f_1 * _S558 * 2.0f * 3.14159274101257324f / lobes_6.p_sheen_velvet);
}

__device__ __forceinline__ float toonPDF(float n_i_dot_l_3, float l_dot_h_3, float n_i_dot_v_4, float alpha_11, BSDFLobes lobes_7, float eta_i_6, float eta_o_6)
{
    float _S568 = _slang_select(lobes_7.toon_glossy, l_dot_h_3,n_i_dot_l_3);
    float _S569 = (F32_acos((clamp_1(_S568, -1.0f, 1.0f))));
    float _S570;
    if(_S569 < (lobes_7.toon_a))
    {
        _S570 = 1.0f;
    }
    else
    {
        _S570 = (F32_max((1.0f - (_S569 - lobes_7.toon_a) / (F32_max((lobes_7.toon_s), (0.0000152587890625f)))), (0.0f)));
    }
    float _S571 = lobes_7.p_toon * _S570;
    float _S572 = _slang_select(lobes_7.toon_glossy, 1.0f,n_i_dot_l_3);
    float _S573 = _S571 * _S572 / lobes_7.toon_norm;
    bool _S574;
    if(lobes_7.toon_glossy)
    {
        _S574 = true;
    }
    else
    {
        _S574 = n_i_dot_l_3 > 0.0f;
    }
    float _S575 = _slang_select(_S574, _S573,0.0f);
    return _S575;
}

__device__ __forceinline__ float3  toonBSDF(float3  l_3, float3  n_i_7, float alpha_12, BSDFMaterial material_8, BSDFLobes lobes_8)
{
    float _S576 = (F32_max((dot_0(n_i_7, l_3)), (0.0f)));
    float _S577 = _slang_select(lobes_8.toon_glossy, _S576,lobes_8.toon_view);
    return lobes_8.toon * make_float3 (_S577) / make_float3 (lobes_8.p_toon);
}

__device__ __forceinline__ float reflectPDF(float n_i_dot_l_4, float l_dot_h_4, float n_i_dot_v_5, float alpha_13, BSDFLobes lobes_9, float eta_i_7, float eta_o_7)
{
    float _S578 = vndfPDF(n_i_dot_v_5, alpha_13, lobes_9);
    float _S579 = lobes_9.p_reflect * _S578 / (4.0f * lobes_9.v_dot_h);
    bool _S580 = _S578 > 0.0f;
    float _S581 = _slang_select(_S580, _S579,0.0f);
    return _S581;
}

__device__ __forceinline__ float3  reflectBSDF(float3  l_4, float3  n_i_8, float alpha_14, BSDFMaterial material_9, BSDFLobes lobes_10)
{
    float _S582 = dot_0(n_i_8, l_4);
    float _S583 = smithG1(alpha_14, (F32_max((_S582), (0.0f))));
    bool _S584 = (lobes_10.alphas.x) > 0.0f;
    float G1_l_1;
    if(_S584)
    {
        float3  _S585 = anisotropicLocal(l_4, lobes_10.tangent, n_i_8);
        float _S586 = anisotropicG1(_S585, lobes_10.alphas);
        G1_l_1 = _S586;
    }
    else
    {
        G1_l_1 = _S583;
    }
    return make_float3 (lobes_10.reflect_weight * G1_l_1) * lobes_10.F / make_float3 (lobes_10.p_reflect);
}

__device__ __forceinline__ float3  BSDF(float3  in_dir_4, float3  out_dir_2, float3  n_7, BSDFMaterial material_10, float eta_i_8, float eta_o_8, bool refracted_2, uint random_state_4, FixedArray<float3 , 5>  * throughputs_0, FixedArray<float, 5>  * pdfs_0)
{
    float3  ggx_n_1;
    float3  _S587 = negate_0(in_dir_4);
    float _S588 = dot_0(n_7, _S587);
    float _S589 = sign_0(_S588);
    float3  _S590 = n_7 * make_float3 (_S589);
    AnisotropicFrame _S591 = anisotropicFrame(material_10, _S590);
    float _S592 = dot_0(_S590, out_dir_2);
    float _S593 = material_10.roughness;
    float _S594 = _S593 * _S593;
    SheenProfile _S595 = sheenProfile(_S587, _S590, material_10);
    float _S596 = rgb_to_greyscale(material_10.translucent);
    bool _S597 = _S596 > 0.0f;
    bool _S598 = (dot_0(n_7, out_dir_2) * _S588) < 0.0f;
    uint _S599;
    if((F32_abs((material_10.toon.x))) > 0.0f)
    {
        _S599 = 5U;
    }
    else
    {
        _S599 = 4U;
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
        float3  _S600 = make_float3 (0.0f);
        (*throughputs_0)[i_6] = _S600;
        (*pdfs_0)[i_6] = 0.0f;
        uint i_7 = i_6 + 1U;
        i_6 = i_7;
    }
    float3  _S601 = make_float3 (0.0f);
    BSDFLobes _S602 = BSDFLobes_x24init_0(0.0f, 0.0f, _S601, _S601, 0.0f, 0.0f, _S601, _S601, 0.0f, 0.0f, 0.0f, 0.0f, _S601, 0.0f, _S601, _S601, make_float2 (0.0f), 0.0f, 0.0f, _S601, 0.0f, 0.0f, 0.0f, false, 1.0f, 0.0f, _S601);
    BSDFLobes lobe_terms_0 = _S602;
    uint half_of_0 = 4294967295U;
    float3  ggx_n_2 = _S601;
    i_6 = 0U;
    for(;;)
    {
        if(i_6 < _S599)
        {
        }
        else
        {
            break;
        }
        uint _S603;
        if(i_6 == 3U)
        {
            _S603 = 4U;
        }
        else
        {
            if(i_6 == 4U)
            {
                _S603 = 6U;
            }
            else
            {
                _S603 = i_6;
            }
        }
        bool _S604 = _S603 == 0U;
        bool _S605;
        if(_S604)
        {
            _S605 = _S597;
        }
        else
        {
            _S605 = false;
        }
        bool _S606;
        if(_S605)
        {
            _S606 = _S598;
        }
        else
        {
            _S606 = _S603 == 1U;
        }
        bool _S607 = _S606 != refracted_2;
        if(_S607)
        {
            ggx_n_1 = ggx_n_2;
            uint i_8 = i_6 + 1U;
            ggx_n_2 = ggx_n_1;
            i_6 = i_8;
            continue;
        }
        uint _S608;
        if(_S603 == 6U)
        {
            _S608 = 0U;
        }
        else
        {
            if(_S603 == 4U)
            {
                _S608 = 2U;
            }
            else
            {
                _S608 = _S603;
            }
        }
        bool _S609 = _S608 != half_of_0;
        uint half_of_1;
        if(_S609)
        {
            bool _S610 = _S608 == 0U;
            if(_S610)
            {
                float3  _S611 = sampledHalf(in_dir_4, n_7, material_10, random_state_4, _S591);
                ggx_n_1 = _S611;
            }
            else
            {
                bool _S612 = _S608 == 1U;
                if(_S612)
                {
                    float3  _S613 = refractedHalf(in_dir_4, out_dir_2, n_7, eta_i_8, eta_o_8);
                    ggx_n_1 = _S613;
                }
                else
                {
                    float3  _S614 = reflectedHalf(in_dir_4, out_dir_2);
                    ggx_n_1 = _S614;
                }
            }
            float3  _S615 = negate_0(in_dir_4);
            BSDFLobes _S616 = bsdfLobes(in_dir_4, _S615, _S590, ggx_n_1, material_10, eta_i_8, eta_o_8, _S591, _S595);
            lobe_terms_0 = _S616;
            float _S617 = translucentShare(material_10);
            (&lobe_terms_0)->translucent_share = _S617;
            half_of_1 = _S608;
        }
        else
        {
            ggx_n_1 = ggx_n_2;
            half_of_1 = half_of_0;
        }
        switch(_S603)
        {
        case 0U:
            {
                float _S618 = diffusePDF(_S592, 0.0f, (F32_abs((_S588))), _S594, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(0)] = _S618;
                float3  _S619 = diffuseBSDF(out_dir_2, _S590, _S594, material_10, lobe_terms_0);
                (*throughputs_0)[int(0)] = _S619;
                break;
            }
        case 1U:
            {
                float _S620 = refractPDF(_S592, dot_0(out_dir_2, ggx_n_1), (F32_abs((_S588))), _S594, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(1)] = _S620;
                float3  _S621 = refractBSDF(out_dir_2, _S590, _S594, material_10, lobe_terms_0);
                (*throughputs_0)[int(1)] = _S621;
                break;
            }
        case 4U:
            {
                float _S622 = sheenVelvetPDF(_S592, 0.0f, (F32_abs((_S588))), _S594, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(3)] = _S622;
                float3  _S623 = sheenVelvetBSDF(out_dir_2, _S590, _S594, material_10, lobe_terms_0);
                (*throughputs_0)[int(3)] = _S623;
                break;
            }
        case 6U:
            {
                float _S624 = toonPDF(_S592, dot_0(out_dir_2, (&lobe_terms_0)->toon_axis), (F32_abs((_S588))), _S594, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(4)] = _S624;
                float3  _S625 = toonBSDF(out_dir_2, _S590, _S594, material_10, lobe_terms_0);
                (*throughputs_0)[int(4)] = _S625;
                break;
            }
        default:
            {
                float _S626 = reflectPDF(_S592, 0.0f, (F32_abs((_S588))), _S594, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(2)] = _S626;
                float3  _S627 = reflectBSDF(out_dir_2, _S590, _S594, material_10, lobe_terms_0);
                (*throughputs_0)[int(2)] = _S627;
                break;
            }
        }
        half_of_0 = half_of_1;
        uint i_8 = i_6 + 1U;
        ggx_n_2 = ggx_n_1;
        i_6 = i_8;
    }
    i_6 = 0U;
    ggx_n_1 = _S601;
    for(;;)
    {
        if(i_6 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S628 = ((*pdfs_0)[i_6]) > 0.0f;
        if(_S628)
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
    bool _S629 = wrongSide_0(is_inside_2, false, dir_3, surface_1->geometry_n);
    float3  _S630 = BSDF(in_dir_5, dir_3, surface_1->smooth_n, surface_1->material, eta_1.x, eta_1.y, _S629, random_state_5, terms_0, pdfs_1);
    float3  _S631 = make_float3 (0.0f);
    uint i_10 = 0U;
    float3  f_3 = _S631;
    for(;;)
    {
        if(i_10 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S632 = ((*pdfs_1)[i_10]) > 0.0f;
        if(_S632)
        {
            float3  _S633 = (*terms_0)[i_10] * make_float3 ((*pdfs_1)[i_10]) / make_float3 ((*pdfs_1)[i_10] + pdf_0);
            (*terms_0)[i_10] = _S633;
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
    FKSurface _S634 = surface_2;
    FixedArray<float3 , 5>  terms_1;
    FixedArray<float, 5>  pdfs_2;
    float3  _S635 = skyLobes_0(in_dir_6, dir_4, &_S634, eta_2, is_inside_3, pdf_1, random_state_6, &terms_1, &pdfs_2);
    return _S635;
}

static __device__ SkySample SkySample_x24init_0(float3  dir_5, float3  radiance_0, float3  color_0, uint random_state_7)
{
    SkySample _S636;
    (&_S636)->dir = dir_5;
    (&_S636)->radiance = radiance_0;
    (&_S636)->color = color_0;
    (&_S636)->random_state = random_state_7;
    return _S636;
}

static __device__ SkySample sampleSky_0(FKRay * ray_0, FKSurface * surface_3, float2  eta_3, bool is_inside_4, uint init_random_state_0, uint lobe_state_0, ShadowContext * context_2)
{
    uint2  _S637 = (fcptEnvironmentCdfSize());
    uint2  _S638 = make_uint2 (1U, 0U);
    uint2  _S639 = _S637 - _S638;
    Random _S640 = pcg(init_random_state_0);
    Random _S641 = pcg(_S640.state);
    Random _S642 = pcg(_S641.state);
    Random _S643 = pcg(_S642.state);
    uint _S644 = _S639.x;
    uint _S645 = searchCDF_0(make_uint2 (_S644, 0U), make_uint2 (0U, 1U), _S639.y, _S640.value);
    uint _S646 = searchCDF_0(make_uint2 (0U, _S645), _S638, _S644, _S641.value);
    float2  _S647 = make_float2 ((float)_S639.x, (float)_S639.y);
    float2  _S648 = (make_float2 (float(_S646), float(_S645)) + make_float2 (_S642.value, _S643.value)) / _S647 * make_float2 (6.28318548202514648f, 3.14159274101257324f);
    float _S649 = _S648.y;
    float _S650 = (F32_sin((_S649)));
    float _S651 = _S648.x;
    float3  _S652 = make_float3 (- _S650 * (F32_cos((_S651))), _S650 * (F32_sin((_S651))), (F32_cos((_S649))));
    float _S653 = environmentPdf_0(_S652);
    float3  _S654 = skyBSDF(ray_0->unit_direction, _S652, *surface_3, eta_3, is_inside_4, _S653, lobe_state_0);
    bool _S655 = !(_S653 > 0.0f);
    bool _S656;
    if(_S655)
    {
        _S656 = true;
    }
    else
    {
        _S656 = all_1(_S654 == make_float3 (0.0f));
    }
    if(_S656)
    {
        float3  _S657 = make_float3 (0.0f);
        return SkySample_x24init_0(_S652, _S657, _S657, _S643.state);
    }
    float3  _S658 = skyRadiance_0(ray_0->origin, surface_3, is_inside_4, _S652, context_2, _S643.state);
    return SkySample_x24init_0(_S652, _S658, _S654 * _S658, _S643.state);
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
    SampleBSDF _S659 = (fcptConnectHair((surface_4->hair), ((&surface_4->material)->albedo), ((&surface_4->material)->specular_tint), (in_dir_7), (light_1->dir)));
    float3  _S660 = _S659.throughput * make_float3 (_S659.pdf);
    float _S661 = light_1->density;
    float _S662 = 1.0f + _S659.pdf * _S659.pdf / (light_1->density * light_1->density);
    bool _S663;
    if(competing_0)
    {
        _S663 = _S661 > 0.0f;
    }
    else
    {
        _S663 = false;
    }
    float _S664 = _slang_select(_S663, _S662,1.0f);
    return _S660 / make_float3 (_S664) * light_1->radiance;
}

static __device__ TreeSample TreeSample_x24init_0(float3  dir_6, float3  radiance_1, float density_0, uint random_state_8)
{
    TreeSample _S665;
    (&_S665)->dir = dir_6;
    (&_S665)->radiance = radiance_1;
    (&_S665)->density = density_0;
    (&_S665)->random_state = random_state_8;
    return _S665;
}

__device__ uint pickChild(LightNode first_1, LightNode second_1, float3  p_11, float3  normal_3, float * pick_0, float * probability_3)
{
    float _S666 = importance(first_1, p_11, normal_3);
    float _S667 = importance(second_1, p_11, normal_3);
    float2  _S668 = make_float2 (_S666, _S667);
    bool _S669 = _S666 == 0.0f;
    bool _S670;
    if(_S669)
    {
        _S670 = _S667 == 0.0f;
    }
    else
    {
        _S670 = false;
    }
    if(_S670)
    {
        return 2U;
    }
    float _S671 = _S666 + _S667;
    bool _S672 = _S667 > 0.0f;
    if(_S672)
    {
        _S670 = (*pick_0 * _S671) >= _S666;
    }
    else
    {
        _S670 = false;
    }
    uint _S673 = uint(_S670);
    float _S674 = (F32_min(((*pick_0 * _S671 - float(_S673) * _S666) / _slang_vector_get_element(_S668, _S673)), (0.99999994039535522f)));
    *pick_0 = _S674;
    float _S675 = *probability_3 * (_slang_vector_get_element(_S668, _S673) / _S671);
    *probability_3 = _S675;
    return _S673;
}

__device__ float3  sampleSphere(float3  center_1, float radius_1, float3  p_12, float u1_0, float u2_0)
{
    float3  _S676 = center_1 - p_12;
    float _S677 = radius_1 * radius_1 / dot_0(_S676, _S676);
    float _S678 = u1_0 * _S677 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S677), (0.0f)))))));
    float _S679 = 2.0f * u1_0;
    bool _S680 = _S677 >= 1.0f;
    float _S681 = _slang_select(_S680, _S679,_S678);
    float _S682 = (F32_sqrt(((F32_max((_S681 * (2.0f - _S681)), (0.0f))))));
    float _S683 = 6.28318548202514648f * u2_0;
    float3  _S684 = make_float3 (_S682 * (F32_cos((_S683))), 1.0f - _S681, _S682 * (F32_sin((_S683))));
    float3  _S685 = ((((_S676)) * make_float3(rnorm3df(((_S676)).x, ((_S676)).y, ((_S676)).z))));
    float3  _S686 = tangentToWorld(_S684, _S685);
    return _S686;
}

__device__ float3  pointLightRadiance(float3  color_1, float intensity_0, float radius_2)
{
    return color_1 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_2 * radius_2);
}

static __device__ float raySphere_0(float3  center_2, float radius_3, FKRay * ray_1, float max_len_0)
{
    float3  _S687 = center_2 - ray_1->origin;
    float _S688 = dot_0(_S687, ray_1->unit_direction);
    float _S689 = dot_0(_S687, _S687) - _S688 * _S688;
    float _S690 = radius_3 * radius_3;
    bool _S691 = _S689 > _S690;
    if(_S691)
    {
        return 4.294967296e+09f;
    }
    float _S692 = (F32_sqrt((_S690 - _S689)));
    float _S693 = _S688 - _S692;
    float _S694 = _S688 + _S692;
    bool _S695 = _S693 > 0.0000152587890625f;
    bool _S696;
    if(_S695)
    {
        _S696 = _S693 < max_len_0;
    }
    else
    {
        _S696 = false;
    }
    if(_S696)
    {
        return _S693;
    }
    bool _S697 = _S694 > 0.0000152587890625f;
    if(_S697)
    {
        _S696 = _S694 < max_len_0;
    }
    else
    {
        _S696 = false;
    }
    if(_S696)
    {
        return _S694;
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
    Random _S698 = pcg(init_random_state_1);
    Random _S699 = pcg(_S698.state);
    Random _S700 = pcg(_S699.state);
    float3  _S701 = make_float3 (0.0f);
    TreeSample _S702 = TreeSample_x24init_0(_S701, _S701, 0.0f, _S700.state);
    TreeSample sample_0 = _S702;
    float3  _S703 = _slang_select(sided_0, _S701,smooth_n_2);
    float3  _S704 = origin_4 + make_float3 (geometry_offset_1) * smooth_n_2;
    float pick_1 = _S698.value;
    float probability_4 = 1.0f;
    uint n_8 = 0U;
    for(;;)
    {
        uint4  _S705 = (fcptLightNode((n_8)));
        if((_S705.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S706 = (fcptLightSecond((n_8)));
        uint _S707 = n_8 + 1U;
        LightNode _S708 = (fcptLightBounds((_S707)));
        LightNode _S709 = (fcptLightBounds((_S706)));
        uint _S710 = pickChild(_S708, _S709, origin_4, _S703, &pick_1, &probability_4);
        bool _S711 = _S710 > 1U;
        if(_S711)
        {
            return sample_0;
        }
        bool _S712 = _S710 == 1U;
        uint _S713 = _slang_select(_S712, _S706,_S707);
        n_8 = _S713;
    }
    bool _S714 = n_8 == 0U;
    bool _S715;
    if(_S714)
    {
        LightNode _S716 = (fcptLightBounds((0U)));
        float _S717 = importance(_S716, origin_4, _S703);
        _S715 = !(_S717 > 0.0f);
    }
    else
    {
        _S715 = false;
    }
    if(_S715)
    {
        return sample_0;
    }
    uint4  _S718 = (fcptLightNode((n_8)));
    FKHit _S719 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    bool _S720 = (_S718.x) == 2U;
    float3  emitter_point_0;
    float3  lift_n_0;
    float3  shadow_1;
    FKHit emitter_0;
    if(_S720)
    {
        FKLight _S721 = (fcptLight((_S718.y)));
        if(sided_0)
        {
            float _S722 = sign_0(dot_0(geometry_n_1, _S721.position - origin_4));
            float3  lift_n_1 = smooth_n_2 * make_float3 (_S722);
            float3  _S723 = origin_4 + make_float3 (geometry_offset_1) * lift_n_1;
            emitter_point_0 = _S723;
            lift_n_0 = lift_n_1;
        }
        else
        {
            emitter_point_0 = _S704;
            lift_n_0 = smooth_n_2;
        }
        bool _S724 = (_S721.variance) == 0.0f;
        if(_S724)
        {
            float3  _S725 = _S721.position - emitter_point_0;
            float3  _S726 = ((((_S725)) * make_float3(rnorm3df(((_S725)).x, ((_S725)).y, ((_S725)).z))));
            (&sample_0)->dir = _S726;
            float3  _S727 = _S721.color * make_float3 (_S721.intensity) / make_float3 (dot_0(_S725, _S725) * probability_4);
            (&sample_0)->radiance = _S727;
            shadow_1 = _S725;
        }
        else
        {
            float3  _S728 = sampleSphere(_S721.position, _S721.variance, emitter_point_0, _S699.value, _S700.value);
            (&sample_0)->dir = _S728;
            float _S729 = sphereDensity(_S721.position, _S721.variance, emitter_point_0);
            float _S730 = probability_4 * _S729;
            (&sample_0)->density = _S730;
            float3  _S731 = pointLightRadiance(_S721.color, _S721.intensity, _S721.variance);
            float3  _S732 = _S731 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S732;
            FKRay _S733 = Ray_x24init_0(emitter_point_0, (&sample_0)->dir);
            float _S734 = raySphere_0(_S721.position, _S721.variance, &_S733, 4.294967296e+09f);
            float3  _S735 = (&sample_0)->dir * make_float3 (_S734);
            shadow_1 = _S735;
        }
        emitter_0 = _S719;
        emitter_point_0 = _S701;
    }
    else
    {
        uint _S736 = _S718.y;
        uint _S737 = (fcptTriangleOffset((_S736)));
        uint _S738 = _S737 + _S718.z;
        Matrix<float, 3, 3>  _S739 = (fcptWorldTriangle((_S736), (_S738)));
        float _S740 = (F32_sqrt((_S699.value)));
        float2  _S741 = make_float2 (_S740 * (1.0f - _S700.value), _S740 * _S700.value);
        float3  _S742 = mul_0(make_float3 (1.0f - _S740, _S741.x, _S741.y), _S739);
        if(sided_0)
        {
            float _S743 = sign_0(dot_0(geometry_n_1, _S742 - origin_4));
            float3  lift_n_2 = smooth_n_2 * make_float3 (_S743);
            float3  _S744 = origin_4 + make_float3 (geometry_offset_1) * lift_n_2;
            emitter_point_0 = _S744;
            lift_n_0 = lift_n_2;
        }
        else
        {
            bool _S745 = !((dot_0(smooth_n_2, _S742 - origin_4)) > 0.0f);
            if(_S745)
            {
                return sample_0;
            }
            emitter_point_0 = _S704;
            lift_n_0 = smooth_n_2;
        }
        FKHit emitter_1 = Hit_x24init_0(_S741, _S736, _S738, 0U, 0.0f);
        float3  _S746 = _S742 - emitter_point_0;
        float3  _S747 = ((((_S746)) * make_float3(rnorm3df(((_S746)).x, ((_S746)).y, ((_S746)).z))));
        (&sample_0)->dir = _S747;
        float _S748 = solidAngle(probability_4, cross_0(_S739.rows[int(1)] - _S739.rows[int(0)], _S739.rows[int(2)] - _S739.rows[int(0)]), _S746);
        (&sample_0)->density = _S748;
        bool _S749 = (fcptShadowFirst());
        bool _S750 = !_S749;
        if(_S750)
        {
            FKSurface _S751 = (fcptLightSurfaceAt((emitter_1), (_S742), (_S700.state), ((&sample_0)->dir), (context_3->depth), (length_0(_S742 - origin_4))));
            (&sample_0)->random_state = _S751.random_state;
            float3  _S752 = _slang_select(_S751.skip, _S701,_S751.material.emissive);
            float3  _S753 = _S752 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S753;
        }
        shadow_1 = _S746;
        emitter_0 = emitter_1;
        emitter_point_0 = _S742;
    }
    FKHit _S754 = emitter_0;
    float3  _S755 = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, context_3, _S700.state, &_S754);
    bool _S756 = (fcptShadowFirst());
    if(_S756)
    {
        _S715 = (emitter_0.instance_index) != 4294967295U;
    }
    else
    {
        _S715 = false;
    }
    if(_S715)
    {
        _S715 = !all_1(_S755 == _S701);
    }
    else
    {
        _S715 = false;
    }
    if(_S715)
    {
        FKSurface _S757 = (fcptLightSurfaceAt((emitter_0), (emitter_point_0), (_S700.state), ((&sample_0)->dir), (context_3->depth), (length_0(emitter_point_0 - origin_4))));
        (&sample_0)->random_state = _S757.random_state;
        float3  _S758 = _slang_select(_S757.skip, _S701,_S757.material.emissive);
        float3  _S759 = _S758 / make_float3 ((&sample_0)->density);
        (&sample_0)->radiance = _S759;
    }
    float3  _S760 = (&sample_0)->radiance * _S755;
    bool _S761 = all_1(_S755 == _S701);
    float3  _S762 = _slang_select(_S761, _S701,_S760);
    (&sample_0)->radiance = _S762;
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
    float _S763 = 1.0f / (1.0f + b_1 / a_5 * (b_1 / a_5));
    bool _S764 = b_1 > 0.0f;
    float _S765 = _slang_select(_S764, _S763,1.0f);
    return _S765;
}

static __device__ float emissionWeight_0(NEEVertex * vertex_0, FKHit * hit_1, float3  light_point_1)
{
    bool _S766 = vertex_0->none;
    if(_S766)
    {
        return 1.0f;
    }
    uint _S767 = (fcptLightSlot((*hit_1)));
    float _S768 = lightPdf_0(vertex_0->origin, vertex_0->smooth_n, vertex_0->start, _S767, light_point_1);
    float _S769 = powerHeuristic(vertex_0->pdf, _S768);
    return _S769;
}

static __device__ float3  environment_0(float3  dir_7, uint depth_0, uint lobe_0)
{
    uint2  _S770 = (fcptEnvironmentMapSize());
    bool _S771 = all_0(_S770 > make_uint2 (1U));
    if(_S771)
    {
        float3  _S772 = (fcptEnvMapSample((dir_7), (depth_0), (lobe_0)));
        return _S772;
    }
    float3  _S773 = (fcptAmbient());
    return _S773;
}

static __device__ bool environmentMapped_0()
{
    uint2  _S774 = (fcptEnvironmentCdfSize());
    bool _S775 = !all_0(_S774 > make_uint2 (1U));
    if(_S775)
    {
        return false;
    }
    uint2  _S776 = (fcptEnvironmentMapSize());
    return all_0(_S776 > make_uint2 (1U));
}

static __device__ float escapeWeight_0(float pdf_2, float3  dir_8)
{
    bool _S777 = pdf_2 <= 0.0f;
    bool _S778;
    if(_S777)
    {
        _S778 = true;
    }
    else
    {
        bool _S779 = environmentMapped_0();
        _S778 = !_S779;
    }
    if(_S778)
    {
        return 1.0f;
    }
    float _S780 = environmentPdf_0(dir_8);
    return pdf_2 / (pdf_2 + _S780);
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
    uint2  _S781 = uint2 {global_invocation_id_1.x, global_invocation_id_1.y};
    int2  _S782 = make_int2 ((int)_S781.x, (int)_S781.y);
    uint _S783 = previousSeed_0(_S782);
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
            uint _S784 = previousSeed_0(_S782 + make_int2 (x_16, y_5));
            bool _S785 = _S784 == _S783;
            uint _S786 = _slang_select(_S785, 1U,0U);
            uint count_3 = count_2 + _S786;
            int x_17 = x_16 + int(1);
            x_16 = x_17;
            count_2 = count_3;
        }
        int y_6 = y_5 + int(1);
        y_5 = y_6;
    }
    float _S787 = float(count_2 - 1U) / 288.0f;
    bool _S788 = _S783 != 0U;
    float _S789 = _slang_select(_S788, _S787,0.0f);
    fcptStoreDuplication((_S782), (make_uint4 ((F32_asuint((_S789))), 0U, 0U, 0U)));
    return;
}

__device__ uint stream(uint seed_3, uint index_0)
{
    uint _S790 = hash(index_0);
    uint _S791 = hash(seed_3 ^ _S790);
    return _S791;
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
    float _S792 = rgb_to_greyscale(weight_0);
    bool _S793 = _S792 > 0.0f;
    bool _S794;
    if(_S793)
    {
        _S794 = _S792 < 3.00000000549775576e+38f;
    }
    else
    {
        _S794 = false;
    }
    bool _S795 = !_S794;
    if(_S795)
    {
        return;
    }
    bool _S796 = sel_2->sums;
    if(_S796)
    {
        float3  _S797 = sel_2->color + weight_0;
        sel_2->color = _S797;
        return;
    }
    float _S798 = sel_2->w_sum + _S792;
    sel_2->w_sum = _S798;
    float3  _S799 = sel_2->color + weight_0;
    sel_2->color = _S799;
    Random _S800 = pcg(sel_2->random_state);
    sel_2->random_state = _S800.state;
    bool _S801 = (_S800.value * sel_2->w_sum) <= _S792;
    if(_S801)
    {
        sel_2->r = candidate_0;
    }
    return;
}

__device__ void offerShifted(Selection * sel_3, Reservoir r_3, Shift shifted_0, float mis_0)
{
    Reservoir candidate_1 = r_3;
    float3  _S802 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_1)->f = _S802;
    float _S803 = r_3.jac * shifted_0.jac;
    (&candidate_1)->jac = _S803;
    offer(sel_3, candidate_1, make_float3 (mis_0) * shifted_0.f * make_float3 (r_3.w));
    return;
}

__device__ Reservoir finalize(Selection sel_4, float c_1)
{
    Reservoir r_4 = sel_4.r;
    float _S804 = rgb_to_greyscale((&r_4)->f);
    float _S805 = sel_4.w_sum / _S804;
    bool _S806 = _S804 > 0.0f;
    float _S807 = _slang_select(_S806, _S805,0.0f);
    (&r_4)->w = _S807;
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
    uint2  _S808 = uint2 {global_invocation_id_2.x, global_invocation_id_2.y};
    int2  _S809 = make_int2 ((int)_S808.x, (int)_S808.y);
    float3  _S810 = make_float3 (0.0f);
    FKHit _S811 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S812 = Domain_x24init_0(_S810, _S810, &_S811, 0.0f, 0.0f);
    Domain dom_4 = _S812;
    bool _S813 = (fcptCurrentDomain((_S809), (&dom_4)));
    bool _S814 = !_S813;
    if(_S814)
    {
        Reservoir _S815 = (Reservoir{});
        fcptStoreReservoirPrevious((_S809), (_S815), ((&dom_4)->hit));
        return;
    }
    Reservoir _S816 = (fcptLoadReservoirTemporal((_S809)));
    uint t_12 = 0U;
    float count_4 = 0.0f;
    float c_sum_0 = _S816.c;
    for(;;)
    {
        uint _S817 = (fcptRestirNeighbours());
        if(t_12 < _S817)
        {
        }
        else
        {
            break;
        }
        int2  _S818 = partner_0(_S809, t_12);
        Domain neighbor_0 = _S812;
        bool _S819 = (fcptCurrentDomain((_S818), (&neighbor_0)));
        if(_S819)
        {
            float count_5 = count_4 + 1.0f;
            uint4  _S820 = (fcptReservoirTemporal((_S818), (0U)));
            float c_sum_1 = c_sum_0 + (U32_asfloat((_S820.w)));
            count_4 = count_5;
            c_sum_0 = c_sum_1;
        }
        uint t_13 = t_12 + 1U;
        t_12 = t_13;
    }
    float _S821 = _S816.c / (F32_max((count_4), (1.0f)));
    float _S822 = rgb_to_greyscale(_S816.f);
    bool _S823 = count_4 == 0.0f;
    float _S824 = _slang_select(_S823, 1.0f,0.0f);
    Selection _S825 = (Selection{});
    Selection sel_5 = _S825;
    uint _S826 = (fcptFrame());
    uint _S827 = hash(_S826);
    uint _S828 = global_invocation_id_2.x;
    uint2  _S829 = (fcptRenderSize());
    uint _S830 = stream(_S827, _S828 + _S829.x * global_invocation_id_2.y);
    uint _S831 = stream(_S830, 195U);
    (&sel_5)->random_state = _S831;
    t_12 = 0U;
    float canonical_mis_0 = _S824;
    for(;;)
    {
        uint _S832 = (fcptRestirNeighbours());
        if(t_12 < _S832)
        {
        }
        else
        {
            break;
        }
        int2  _S833 = partner_0(_S809, t_12);
        Domain neighbor_dom_0 = _S812;
        bool _S834 = (fcptCurrentDomain((_S833), (&neighbor_dom_0)));
        if(_S834)
        {
            Reservoir _S835 = (fcptLoadReservoirTemporal((_S833)));
            uint4  _S836 = (fcptShiftData((_S833), (t_12)));
            float4  _S837 = asfloat_0(_S836);
            uint4  _S838 = (fcptShiftData((_S809), (t_12)));
            float4  _S839 = asfloat_0(_S838);
            float _S840 = (_S835.c + _S821) / c_sum_0;
            bool _S841 = _S822 > 0.0f;
            float canonical_mis_1;
            if(_S841)
            {
                float _S842 = _S840 * _S821 * _S822;
                float _S843 = _S821 * _S822;
                float _S844 = rgb_to_greyscale(float3 {_S839.x, _S839.y, _S839.z});
                float canonical_mis_2 = canonical_mis_0 + _S842 / (_S843 + _S835.c * _S844);
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            float _S845 = rgb_to_greyscale(_S835.f);
            float3  _S846 = float3 {_S837.x, _S837.y, _S837.z};
            Shift _S847 = Shift_x24init_0(_S846, _S837.w);
            float _S848 = _S840 * _S835.c * _S845;
            float _S849 = _S835.c * _S845;
            float _S850 = rgb_to_greyscale(_S846);
            offerShifted(&sel_5, _S835, _S847, _S848 / (_S849 + _S821 * _S850));
            canonical_mis_0 = canonical_mis_1;
        }
        uint t_14 = t_12 + 1U;
        t_12 = t_14;
    }
    offerShifted(&sel_5, _S816, Shift_x24init_0(_S816.f, 1.0f), canonical_mis_0);
    Reservoir _S851 = finalize(sel_5, c_sum_0);
    fcptStoreReservoirPrevious((_S809), (_S851), ((&dom_4)->hit));
    fcptStorePreviousLayer((_S809), (5U), (make_uint4 (asuint_0((&(&dom_4)->hit)->uv).x, asuint_0((&(&dom_4)->hit)->uv).y, 0U, 0U)));
    fcptAddColor((_S809), (make_float4 ((&sel_5)->color.x, (&sel_5)->color.y, (&sel_5)->color.z, 0.0f)));
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
    uint _S852 = queuedShift_0(workgroup_id_1, local_invocation_index_4);
    bool _S853 = _S852 != 4294967295U;
    if(_S853)
    {
        uint2  _S854 = make_uint2 (_S852, _S852 >> 14U) & make_uint2 (16383U);
        int2  _S855 = make_int2 ((int)_S854.x, (int)_S854.y);
        ShiftJob _S856 = (ShiftJob{});
        ShiftJob shift_job_0 = _S856;
        Shift _S857 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
        uint _S858 = _S852 >> 28U;
        bool _S859 = spatialJob_0(_S855, _S858, &shift_job_0, true);
        Shift shifted_1;
        if(_S859)
        {
            Domain _S860 = (&shift_job_0)->dom;
            Reservoir _S861 = (&shift_job_0)->r;
            Shift _S862 = passShift_0(&_S860, &_S861);
            shifted_1 = _S862;
        }
        else
        {
            shifted_1 = _S857;
        }
        fcptStoreShiftData((_S855), (_S858), (make_uint4 (asuint_1(shifted_1.f).x, asuint_1(shifted_1.f).y, asuint_1(shifted_1.f).z, (F32_asuint((shifted_1.jac))))));
    }
    return;
}

static __device__ void restir_prepass_0(uint3  global_invocation_id_3, uint local_invocation_index_5)
{
    uint2  _S863 = uint2 {global_invocation_id_3.x, global_invocation_id_3.y};
    int2  _S864 = make_int2 ((int)_S863.x, (int)_S863.y);
    FixedArray<uint, 3>  _S865;
    spatialBins_0(_S864, &_S865);
    FixedArray<uint, 3>  _S866 = _S865;
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
        bool _S867 = (_S866[t_15]) == 40U;
        if(_S867)
        {
            fcptStoreShiftData((_S864), (t_15), (make_uint4 (0U)));
        }
        uint t_16 = t_15 + 1U;
        t_15 = t_16;
    }
    FixedArray<uint, 3>  _S868 = _S866;
    queueShifts_0(_S864, &_S868, global_invocation_id_3, local_invocation_index_5);
    return;
}

static __device__ void restir_count_0(uint3  global_invocation_id_4, uint local_invocation_index_6)
{
    uint2  _S869 = uint2 {global_invocation_id_4.x, global_invocation_id_4.y};
    int2  _S870 = make_int2 ((int)_S869.x, (int)_S869.y);
    FixedArray<uint, 3>  _S871;
    spatialBins_0(_S870, &_S871);
    FixedArray<uint, 3>  _S872 = _S871;
    countShifts_0(&_S872, local_invocation_index_6);
    return;
}

static __device__ void restir_temporal_shift_0(uint3  workgroup_id_2, uint local_invocation_index_7)
{
    uint _S873 = queuedShift_0(workgroup_id_2, local_invocation_index_7);
    bool _S874 = _S873 != 4294967295U;
    if(_S874)
    {
        uint2  _S875 = make_uint2 (_S873, _S873 >> 14U) & make_uint2 (16383U);
        int2  _S876 = make_int2 ((int)_S875.x, (int)_S875.y);
        ShiftJob _S877 = (ShiftJob{});
        ShiftJob shift_job_1 = _S877;
        Shift _S878 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
        uint _S879 = _S873 >> 28U;
        bool _S880 = temporalJob_0(_S876, _S879, &shift_job_1, true);
        Shift shifted_2;
        if(_S880)
        {
            if(_S879 == 1U)
            {
                Shift _S881 = (fcptShiftPrevious(((&shift_job_1)->dom), ((&shift_job_1)->r)));
                shifted_2 = _S881;
            }
            else
            {
                Domain _S882 = (&shift_job_1)->dom;
                Reservoir _S883 = (&shift_job_1)->r;
                Shift _S884 = passShift_0(&_S882, &_S883);
                shifted_2 = _S884;
            }
        }
        else
        {
            shifted_2 = _S878;
        }
        fcptStoreTemporalShift((_S876), (_S879), (make_uint4 (asuint_1(shifted_2.f).x, asuint_1(shifted_2.f).y, asuint_1(shifted_2.f).z, (F32_asuint((shifted_2.jac))))));
    }
    return;
}

static __device__ void restir_temporal_prepass_0(uint3  global_invocation_id_5, uint local_invocation_index_8)
{
    uint2  _S885 = uint2 {global_invocation_id_5.x, global_invocation_id_5.y};
    int2  _S886 = make_int2 ((int)_S885.x, (int)_S885.y);
    FixedArray<uint, 3>  _S887;
    temporalBins_0(_S886, &_S887);
    FixedArray<uint, 3>  _S888 = _S887;
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
        bool _S889 = (_S888[t_17]) == 40U;
        if(_S889)
        {
            fcptStoreTemporalShift((_S886), (t_17), (make_uint4 (0U)));
        }
        uint t_18 = t_17 + 1U;
        t_17 = t_18;
    }
    FixedArray<uint, 3>  _S890 = _S888;
    queueShifts_0(_S886, &_S890, global_invocation_id_5, local_invocation_index_8);
    return;
}

static __device__ void restir_temporal_count_0(uint3  global_invocation_id_6, uint local_invocation_index_9)
{
    uint2  _S891 = uint2 {global_invocation_id_6.x, global_invocation_id_6.y};
    int2  _S892 = make_int2 ((int)_S891.x, (int)_S891.y);
    bool _S893 = (fcptSceneUnchanged());
    bool _S894 = !_S893;
    bool _S895;
    if(_S894)
    {
        uint2  _S896 = (fcptRenderSize());
        int2  _S897 = make_int2 ((int)_S896.x, (int)_S896.y);
        _S895 = all_0(_S892 < _S897);
    }
    else
    {
        _S895 = false;
    }
    if(_S895)
    {
        Reservoir _S898 = (fcptLoadReservoirInitial((_S892)));
        int2  _S899 = sampleNeighbor_0(_S892, _S898.seed);
        fcptStoreTemporalNeighbor((_S892), (_S899));
    }
    FixedArray<uint, 3>  _S900;
    temporalBins_0(_S892, &_S900);
    FixedArray<uint, 3>  _S901 = _S900;
    countShifts_0(&_S901, local_invocation_index_9);
    return;
}

static __device__ float interpolate_0(float a_6, float b_2, float t_19)
{
    return a_6 + (b_2 - a_6) * t_19;
}

static __device__ void restir_temporal_0(uint3  global_invocation_id_7)
{
    uint2  _S902 = uint2 {global_invocation_id_7.x, global_invocation_id_7.y};
    int2  _S903 = make_int2 ((int)_S902.x, (int)_S902.y);
    float3  _S904 = make_float3 (0.0f);
    FKHit _S905 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S906 = Domain_x24init_0(_S904, _S904, &_S905, 0.0f, 0.0f);
    Domain dom_5 = _S906;
    bool _S907 = (fcptCurrentDomain((_S903), (&dom_5)));
    bool _S908 = !_S907;
    if(_S908)
    {
        Reservoir _S909 = (Reservoir{});
        fcptStoreReservoirTemporal((_S903), (_S909), ((&dom_5)->hit));
        return;
    }
    Reservoir _S910 = (fcptLoadReservoirInitial((_S903)));
    bool _S911 = (fcptSceneUnchanged());
    int2  _S912;
    if(_S911)
    {
        int2  _S913 = sampleNeighbor_0(_S903, _S910.seed);
        _S912 = _S913;
    }
    else
    {
        int2  _S914 = (fcptLoadTemporalNeighbor((_S903)));
        _S912 = _S914;
    }
    bool _S915 = (_S912.x) >= int(0);
    Reservoir r_5;
    if(_S915)
    {
        Reservoir _S916 = (fcptLoadReservoirPrevious((_S912)));
        uint4  _S917 = (fcptDuplication((_S912)));
        float _S918 = (U32_asfloat((_S917.x)));
        uint _S919 = (fcptRestirDecorrelation());
        bool _S920 = _S919 == 1U;
        float _S921 = _slang_select(_S920, _S918,0.0f);
        float _S922 = interpolate_0(20.0f, 1.0f, (F32_pow((_S921), (0.10000000149011612f))));
        float _S923 = (F32_min((_S916.c), (_S922)));
        bool _S924 = (fcptSceneUnchanged());
        float4  _S925;
        if(_S924)
        {
            _S925 = make_float4 (_S916.f.x, _S916.f.y, _S916.f.z, 1.0f);
        }
        else
        {
            uint4  _S926 = (fcptTemporalShift((_S903), (0U)));
            _S925 = asfloat_0(_S926);
        }
        Domain own_1 = _S906;
        bool _S927;
        if(_S924)
        {
            _S927 = true;
        }
        else
        {
            bool _S928 = (fcptPreviousScenes());
            bool _S929 = !_S928;
            if(_S929)
            {
                _S927 = (_S910.w) > 0.0f;
            }
            else
            {
                _S927 = false;
            }
            if(_S927)
            {
                bool _S930 = (fcptStoredDomainInitial((_S903), (_S910.seed), (&own_1)));
                _S927 = _S930;
            }
            else
            {
                _S927 = false;
            }
            if(_S927)
            {
                Domain _S931 = (fcptPreviousDomain((_S912), (_S910.seed)));
                Domain _S932 = _S931;
                Domain _S933 = own_1;
                bool _S934 = sameDomain_0(&_S932, &_S933);
                _S927 = _S934;
            }
            else
            {
                _S927 = false;
            }
        }
        float4  _S935;
        if(_S927)
        {
            _S935 = make_float4 (_S910.f.x, _S910.f.y, _S910.f.z, 1.0f);
        }
        else
        {
            uint4  _S936 = (fcptTemporalShift((_S903), (1U)));
            _S935 = asfloat_0(_S936);
        }
        float _S937 = rgb_to_greyscale(_S910.f);
        float _S938 = rgb_to_greyscale(_S916.f);
        Selection _S939 = (Selection{});
        Selection sel_6 = _S939;
        uint _S940 = (fcptFrame());
        uint _S941 = hash(_S940);
        uint _S942 = global_invocation_id_7.x;
        uint2  _S943 = (fcptRenderSize());
        uint _S944 = stream(_S941, _S942 + _S943.x * global_invocation_id_7.y);
        uint _S945 = stream(_S944, 194U);
        (&sel_6)->random_state = _S945;
        float _S946 = _S910.c * _S937;
        float4  _S947 = _S935;
        float _S948 = rgb_to_greyscale(float3 {_S947.x, _S947.y, _S947.z});
        float _S949 = _S946 / (_S946 + _S923 * _S948);
        float _S950 = _S923 * _S938;
        float4  _S951 = _S925;
        float3  _S952 = float3 {_S951.x, _S951.y, _S951.z};
        float _S953 = rgb_to_greyscale(_S952);
        float _S954 = _S950 / (_S950 + _S910.c * _S953);
        float2  _S955 = make_float2 (_S949, _S954);
        offerShifted(&sel_6, _S910, Shift_x24init_0(_S910.f, 1.0f), _S949);
        offerShifted(&sel_6, _S916, Shift_x24init_0(_S952, _S925.w), _S954);
        Reservoir _S956 = finalize(sel_6, _S910.c + _S923);
        r_5 = _S956;
    }
    else
    {
        r_5 = _S910;
    }
    fcptStoreReservoirTemporal((_S903), (r_5), ((&dom_5)->hit));
    return;
}

static __device__ void restir_initial_0(uint3  global_invocation_id_8)
{
    uint2  _S957 = uint2 {global_invocation_id_8.x, global_invocation_id_8.y};
    int2  _S958 = make_int2 ((int)_S957.x, (int)_S957.y);
    float3  _S959 = make_float3 (0.0f);
    float2  _S960 = make_float2 (0.0f);
    FKHit _S961 = Hit_x24init_0(_S960, 0U, 0U, 0U, 0.0f);
    Domain _S962 = Domain_x24init_0(_S959, _S959, &_S961, 0.0f, 0.0f);
    Domain dom_6 = _S962;
    bool _S963 = (fcptCurrentDomain((_S958), (&dom_6)));
    bool _S964 = !_S963;
    if(_S964)
    {
        Reservoir _S965 = (Reservoir{});
        fcptStoreReservoirInitial((_S958), (_S965), ((&dom_6)->hit));
        return;
    }
    uint _S966 = (fcptFrame());
    uint _S967 = hash(_S966);
    uint _S968 = global_invocation_id_8.x;
    uint2  _S969 = (fcptRenderSize());
    uint _S970 = stream(_S967, _S968 + _S969.x * global_invocation_id_8.y);
    Selection _S971 = (Selection{});
    Selection initial_0 = _S971;
    uint _S972 = stream(_S970, 193U);
    (&initial_0)->random_state = _S972;
    bool _S973 = (fcptRestirUsed());
    bool _S974 = !_S973;
    (&initial_0)->sums = _S974;
    uint _S975 = stream(_S970, 0U);
    (&(&initial_0)->r)->seed = _S975;
    FKHit _S976 = Hit_x24init_0(_S960, 4294967295U, 0U, 0U, 0.0f);
    uint _S977 = (fcptSamples());
    float _S978 = 1.0f / float(_S977);
    FKHit hit_2 = _S976;
    uint i_17 = 0U;
    for(;;)
    {
        uint _S979 = (fcptSamples());
        if(i_17 < _S979)
        {
        }
        else
        {
            break;
        }
        Reservoir _S980 = (Reservoir{});
        Reservoir r_6 = _S980;
        uint _S981 = stream(_S970, i_17);
        (&r_6)->seed = _S981;
        Domain path_0 = _S962;
        bool _S982 = (fcptStoredDomainInitial((_S958), ((&r_6)->seed), (&path_0)));
        bool _S983 = !_S982;
        if(_S983)
        {
            fcptMissed((_S958), (path_0), (_S978));
            uint i_18 = i_17 + 1U;
            i_17 = i_18;
            continue;
        }
        Domain _S984 = path_0;
        Reservoir _S985 = r_6;
        Shift _S986 = passWalk_0(&_S984, &_S985, false, _S978, &initial_0);
        bool _S987 = ((&(&initial_0)->r)->seed) == ((&r_6)->seed);
        FKHit hit_3;
        if(_S987)
        {
            FKHit _S988 = (&path_0)->hit;
            hit_3 = _S988;
        }
        else
        {
            hit_3 = hit_2;
        }
        hit_2 = hit_3;
        uint i_18 = i_17 + 1U;
        i_17 = i_18;
    }
    float3  _S989 = (&initial_0)->glow;
    float3  _S990 = (&initial_0)->color;
    bool _S991 = (&initial_0)->sums;
    float3  _S992 = _slang_select(_S991, _S990,_S959);
    fcptAddColor((_S958), (make_float4 ((_S989 + _S992).x, (_S989 + _S992).y, (_S989 + _S992).z, 1.0f)));
    Reservoir _S993 = finalize(initial_0, 1.0f);
    fcptStoreReservoirInitial((_S958), (_S993), (hit_2));
    return;
}

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_3, float3  origin_5, float3  smooth_n_3, float3  start_6)
{
    NEEVertex _S994;
    (&_S994)->none = none_0;
    (&_S994)->pdf = pdf_3;
    (&_S994)->origin = origin_5;
    (&_S994)->smooth_n = smooth_n_3;
    (&_S994)->start = start_6;
    return _S994;
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
    Vertex _S995;
    (&_S995)->rough = rough_0;
    (&_S995)->lobe = lobe_1;
    (&_S995)->pdf = pdf_4;
    (&_S995)->cos = cos_0;
    (&_S995)->inside = inside_0;
    return _S995;
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
    float3  _S996 = exp_0((make_float3 (sigma_0) - extinction_0) * make_float3 (distance_2));
    float3  _S997 = scatter_0 * _S996 / make_float3 (sigma_0);
    float3  _S998 = _slang_select(scatters_0, _S997,_S996);
    return _S998;
}

static __device__ uint arrivalLobe_0(uint b_3, uint prev_lobe_0)
{
    bool _S999 = b_3 > 0U;
    uint _S1000 = _slang_select(_S999, prev_lobe_0,3U);
    return _S1000;
}

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_0, uint depth_1, uint lobe_2, bool surface_5, float length_2, float width_1, FKHit * own_2, bool fiber_0)
{
    ShadowContext _S1001;
    (&_S1001)->extinction_behind = extinction_behind_0;
    (&_S1001)->extinction_front = extinction_front_0;
    (&_S1001)->fillings = fillings_0;
    (&_S1001)->side = side_0;
    (&_S1001)->depth = depth_1;
    (&_S1001)->lobe = lobe_2;
    (&_S1001)->surface = surface_5;
    (&_S1001)->length = length_2;
    (&_S1001)->width = width_1;
    (&_S1001)->own = *own_2;
    (&_S1001)->fiber = fiber_0;
    return _S1001;
}

static __device__ float phaseHG_0(float g_0, float mu_0)
{
    bool _S1002 = (F32_abs((g_0))) < 0.00100000004749745f;
    if(_S1002)
    {
        return 0.07957746833562851f;
    }
    float _S1003 = g_0 * g_0;
    return (1.0f - _S1003) * 0.25f * 0.31830987334251404f / (F32_pow((1.0f + _S1003 - 2.0f * g_0 * mu_0), (1.5f)));
}

__device__ float3  safeDivide(float3  a_7, float3  b_4)
{
    float3  _S1004 = a_7 / b_4;
    float3  _S1005 = make_float3 (0.0f);
    bool3  _S1006 = b_4 == _S1005;
    float3  _S1007 = _slang_select(_S1006, _S1005,_S1004);
    return _S1007;
}

static __device__ uint insertBits_0(uint e_2, uint newbits_0, uint offset_1, uint count_6)
{
    uint _S1008 = (1U << count_6) - 1U;
    return (e_2 & (~(_S1008 << offset_1))) | ((newbits_0 & _S1008) << offset_1);
}

__device__ Reservoir withEnd(Reservoir r_7, uint end_type_0, uint end_0, float3  f_5)
{
    Reservoir candidate_2 = r_7;
    uint _S1009 = insertBits_0(r_7.path, end_0, 0U, 5U);
    uint _S1010 = insertBits_0(_S1009, end_type_0, 12U, 3U);
    (&candidate_2)->path = _S1010;
    (&candidate_2)->f = f_5;
    return candidate_2;
}

__device__ float survivalProbability(float3  throughput_0, float density_1)
{
    return (F32_min(((F32_max(((F32_max((throughput_0.x), ((F32_max((throughput_0.y), (throughput_0.z)))))) / density_1), (0.0f)))), (1.0f)));
}

static __device__ float3  isotropic_0(uint random_state_9)
{
    Random _S1011 = pcg(random_state_9);
    Random _S1012 = pcg(_S1011.state);
    float _S1013 = 1.0f - 2.0f * _S1011.value;
    float _S1014 = (F32_sqrt(((F32_max((1.0f - _S1013 * _S1013), (0.0f))))));
    float _S1015 = 6.28318548202514648f * _S1012.value;
    return make_float3 (_S1014 * (F32_cos((_S1015))), _S1014 * (F32_sin((_S1015))), _S1013);
}

static __device__ float3  samplePhase_0(float g_1, float3  dir_9, uint random_state_10, float * pdf_5)
{
    bool _S1016 = (F32_abs((g_1))) < 0.00100000004749745f;
    if(_S1016)
    {
        *pdf_5 = 0.07957746833562851f;
        float3  _S1017 = isotropic_0(random_state_10);
        return _S1017;
    }
    Random _S1018 = pcg(random_state_10);
    Random _S1019 = pcg(_S1018.state);
    float _S1020 = g_1 * g_1;
    float _S1021 = 2.0f * g_1;
    float _S1022 = (1.0f - _S1020) / (1.0f - g_1 + _S1021 * _S1018.value);
    float _S1023 = clamp_1((1.0f + _S1020 - _S1022 * _S1022) / _S1021, -1.0f, 1.0f);
    float _S1024 = (F32_sqrt(((F32_max((1.0f - _S1023 * _S1023), (0.0f))))));
    float _S1025 = 6.28318548202514648f * _S1019.value;
    float _S1026 = phaseHG_0(g_1, _S1023);
    *pdf_5 = _S1026;
    float3  _S1027 = tangentToWorld(make_float3 (_S1024 * (F32_cos((_S1025))), _S1023, _S1024 * (F32_sin((_S1025)))), dir_9);
    float3  _S1028 = ((((_S1027)) * make_float3(rnorm3df(((_S1027)).x, ((_S1027)).y, ((_S1027)).z))));
    return _S1028;
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_1, float3  emissive_0, float roughness_0, float metallic_0, float transmission_0, float ior_0, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_2, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_2, float velvet_0, float3  toon_2)
{
    BSDFMaterial _S1029;
    (&_S1029)->albedo = albedo_1;
    (&_S1029)->emissive = emissive_0;
    (&_S1029)->roughness = roughness_0;
    (&_S1029)->metallic = metallic_0;
    (&_S1029)->transmission = transmission_0;
    (&_S1029)->ior = ior_0;
    (&_S1029)->absorption = absorption_0;
    (&_S1029)->specular_tint = specular_tint_0;
    (&_S1029)->specular_level = specular_level_0;
    (&_S1029)->translucent = translucent_0;
    (&_S1029)->sheen = sheen_2;
    (&_S1029)->sheen_roughness = sheen_roughness_0;
    (&_S1029)->anisotropy = anisotropy_0;
    (&_S1029)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S1029)->tangent = tangent_2;
    (&_S1029)->velvet = velvet_0;
    (&_S1029)->toon = toon_2;
    return _S1029;
}

static __device__ FKMedium Medium_x24init_0(float3  scatter_1, float3  extinction_1, float g_2)
{
    FKMedium _S1030;
    (&_S1030)->scatter = scatter_1;
    (&_S1030)->extinction = extinction_1;
    (&_S1030)->g = g_2;
    return _S1030;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_11, bool skip_0, uint random_state_11, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S1031;
    (&_S1031)->smooth_n = smooth_n_4;
    (&_S1031)->geometry_n = geometry_n_2;
    (&_S1031)->geometry_offset = geometry_offset_2;
    (&_S1031)->material = *material_11;
    (&_S1031)->skip = skip_0;
    (&_S1031)->random_state = random_state_11;
    (&_S1031)->coverage = coverage_0;
    (&_S1031)->encloses = encloses_0;
    (&_S1031)->volume = *volume_0;
    (&_S1031)->fills = fills_0;
    (&_S1031)->hair = hair_0;
    return _S1031;
}

static __device__ FKSurface emitting_0(FKSurface * surface_6, bool top_0)
{
    FKSurface lower_0 = *surface_6;
    float3  _S1032 = (&surface_6->material)->emissive;
    float3  _S1033 = make_float3 (0.0f);
    bool _S1034 = !top_0;
    float3  _S1035 = _slang_select(_S1034, _S1033,_S1032);
    (&(&lower_0)->material)->emissive = _S1035;
    return lower_0;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_7, float u_1)
{
    float _S1036 = surface_7->coverage;
    bool _S1037 = u_1 < _S1036;
    if(_S1037)
    {
        return *surface_7;
    }
    float3  _S1038 = make_float3 (0.0f);
    float3  _S1039 = make_float3 (1.0f);
    BSDFMaterial _S1040 = Material_x24init_0(_S1038, _S1038, 0.0f, 0.0f, 0.0f, 0.0f, _S1038, _S1039, 1.0f, _S1038, _S1038, 0.5f, 0.0f, 0.0f, _S1038, 0.0f, _S1038);
    BSDFMaterial material_12 = _S1040;
    (&material_12)->albedo = _S1039;
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
    bool _S1041 = transmission_1 > 0.0f;
    bool _S1042;
    if(_S1041)
    {
        _S1042 = true;
    }
    else
    {
        _S1042 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S1043 = _slang_select(_S1042, 1.0f,-1.0f);
    return _S1043;
}

static __device__ bool arrivesBehind_0(float3  dir_10, float3  n_9)
{
    return (dot_0(dir_10, n_9)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_8, float3  dir_11)
{
    float3  _S1044 = surface_8->geometry_n;
    float _S1045 = facingSign((&surface_8->material)->transmission, surface_8->geometry_n, dir_11);
    FKSurface faced_0 = *surface_8;
    float3  _S1046 = surface_8->smooth_n * make_float3 (_S1045);
    (&faced_0)->smooth_n = _S1046;
    float3  _S1047 = _S1044 * make_float3 (_S1045);
    (&faced_0)->geometry_n = _S1047;
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
    float3  _S1048 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_3) * log_0(_S1048));
}

__device__ float2  vertexEta(BSDFMaterial material_13, float n_dot_v_0)
{
    bool _S1049 = n_dot_v_0 < 0.0f;
    float _S1050 = _slang_select(_S1049, material_13.ior,1.0f);
    float _S1051 = _slang_select(_S1049, 1.0f,material_13.ior);
    return make_float2 (_S1050, _S1051);
}

__device__ bool neeDecision(BSDFMaterial material_14, float n_dot_v_1, float eta_i_9, float eta_o_9)
{
    float _S1052 = fresnel((F32_abs((n_dot_v_1))), eta_i_9, eta_o_9);
    float3  _S1053 = mix_0(make_float3 (_S1052), material_14.albedo, material_14.metallic);
    float _S1054 = rgb_to_greyscale(_S1053);
    float _S1055 = (F32_max(((1.0f - _S1054) * (1.0f - material_14.metallic) * (1.0f - material_14.transmission)), (0.0f)));
    bool _S1056 = _S1055 > 0.03999999910593033f;
    bool _S1057;
    if(_S1056)
    {
        _S1057 = true;
    }
    else
    {
        _S1057 = (material_14.roughness) > 0.20000000298023224f;
    }
    return _S1057;
}

static __device__ bool isTranslucent_0(BSDFMaterial * material_15)
{
    float _S1058 = rgb_to_greyscale(material_15->translucent);
    return _S1058 > 0.0f;
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
    MediumSides _S1059;
    (&_S1059)->behind = *behind_0;
    (&_S1059)->front = *front_0;
    (&_S1059)->fillings = fillings_1;
    (&_S1059)->face = face_1;
    return _S1059;
}

static __device__ MediumSides mediumSides_0(FKSurface * surface_9, FKMedium * medium_0, uint filling_0, float3  dir_12, FKMedium * outside_0)
{
    float3  _S1060 = surface_9->geometry_n;
    MediumSides _S1061 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_9->geometry_n);
    MediumSides sides_0 = _S1061;
    bool _S1062 = surface_9->encloses;
    if(_S1062)
    {
        (&sides_0)->behind = surface_9->volume;
        *&((&(&sides_0)->fillings)->x) = surface_9->fills;
        bool _S1063 = (dot_0(dir_12, _S1060)) > 0.0f;
        if(_S1063)
        {
            (&sides_0)->front = *outside_0;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_10, bool turned_0, float3  extinction_2, uint filling_1, float3  dir_13, uint depth_2, uint lobe_3, float length_3, float width_2, FKHit * own_3, bool fiber_1, FKMedium * outside_1)
{
    float3  _S1064 = surface_10->geometry_n;
    ShadowContext _S1065 = ShadowContext_x24init_0(extinction_2, extinction_2, make_uint2 (filling_1), surface_10->geometry_n, depth_2, lobe_3, true, length_3, width_2, own_3, fiber_1);
    bool _S1066 = surface_10->encloses;
    ShadowContext context_4;
    if(_S1066)
    {
        FKSurface faced_1 = *surface_10;
        float3  _S1067 = - _S1064;
        float3  _S1068 = _slang_select(turned_0, _S1067,_S1064);
        (&faced_1)->geometry_n = _S1068;
        FKMedium _S1069 = Medium_x24init_0(make_float3 (0.0f), extinction_2, 0.0f);
        FKSurface _S1070 = faced_1;
        FKMedium _S1071 = _S1069;
        MediumSides _S1072 = mediumSides_0(&_S1070, &_S1071, filling_1, dir_13, outside_1);
        ShadowContext _S1073 = ShadowContext_x24init_0(_S1072.behind.extinction, _S1072.front.extinction, _S1072.fillings, _S1064, depth_2, lobe_3, true, length_3, width_2, own_3, fiber_1);
        if(turned_0)
        {
            uint2  _S1074 = _S1072.fillings;
            ShadowContext _S1075 = ShadowContext_x24init_0(_S1072.front.extinction, _S1072.behind.extinction, uint2 {_S1074.y, _S1074.x}, _S1064, depth_2, lobe_3, true, length_3, width_2, own_3, fiber_1);
            context_4 = _S1075;
        }
        else
        {
            context_4 = _S1073;
        }
    }
    else
    {
        context_4 = _S1065;
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
    float3  _S1076 = light_2->dir;
    bool _S1077 = (dot_0(geometry_n_3, - in_dir_8) * dot_0(geometry_n_3, light_2->dir)) <= 0.0f;
    FixedArray<float3 , 5>  throughputs_1;
    FixedArray<float, 5>  pdfs_3;
    float3  _S1078 = BSDF(in_dir_8, _S1076, smooth_n_5, *material_16, eta_i_10, eta_o_10, _S1077, random_state_12, &throughputs_1, &pdfs_3);
    bool _S1079 = !competing_1;
    bool _S1080;
    if(_S1079)
    {
        _S1080 = true;
    }
    else
    {
        _S1080 = (light_2->density) == 0.0f;
    }
    if(_S1080)
    {
        return _S1078 * light_2->radiance;
    }
    float3  _S1081 = make_float3 (0.0f);
    uint i_23 = 0U;
    float3  weighted_0 = _S1081;
    for(;;)
    {
        if(i_23 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S1082 = (pdfs_3[i_23]) > 0.0f;
        if(_S1082)
        {
            float _S1083 = light_2->density;
            float _S1084 = pdfs_3[i_23] / light_2->density;
            float3  weighted_1 = weighted_0 + throughputs_1[i_23] * make_float3 (pdfs_3[i_23]) / make_float3 (_S1083 * (1.0f + _S1084 * _S1084));
            weighted_0 = weighted_1;
        }
        uint i_24 = i_23 + 1U;
        i_23 = i_24;
    }
    return weighted_0 * light_2->radiance * make_float3 (light_2->density);
}

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_1, uint random_state_13, bool refracted_3, uint lobe_4, float pdf_6)
{
    SampleBSDF _S1085;
    (&_S1085)->unit_direction = unit_direction_1;
    (&_S1085)->throughput = throughput_1;
    (&_S1085)->random_state = random_state_13;
    (&_S1085)->refracted = refracted_3;
    (&_S1085)->lobe = lobe_4;
    (&_S1085)->pdf = pdf_6;
    return _S1085;
}

__device__ __forceinline__ SampleBSDF sheenVelvetSample(float3  n_i_9, float n_i_dot_v_6, float alpha_15, BSDFMaterial material_17, BSDFLobes lobes_11, float eta_i_11, float eta_o_11, uint random_state_14)
{
    float3  _S1086 = make_float3 (1.0f);
    SampleBSDF _S1087 = SampleBSDF_x24init_0(_S1086, _S1086, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S1087;
    Random _S1088 = pcg(random_state_14);
    Random _S1089 = pcg(_S1088.state);
    (&sample_1)->random_state = _S1089.state;
    float _S1090 = _S1088.value;
    float _S1091 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1090 * _S1090))))));
    float _S1092 = 6.28318548202514648f * _S1089.value;
    float3  _S1093 = tangentToWorld(make_float3 (_S1091 * (F32_cos((_S1092))), _S1088.value, _S1091 * (F32_sin((_S1092)))), n_i_9);
    (&sample_1)->unit_direction = _S1093;
    (&sample_1)->lobe = 4U;
    float3  _S1094 = sheenVelvetBSDF((&sample_1)->unit_direction, n_i_9, alpha_15, material_17, lobes_11);
    (&sample_1)->throughput = _S1094;
    float _S1095 = sheenVelvetPDF(_S1088.value, 0.0f, n_i_dot_v_6, alpha_15, lobes_11, eta_i_11, eta_o_11);
    (&sample_1)->pdf = _S1095;
    return sample_1;
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S1096 = (F32_sqrt((random_1_0)));
    float _S1097 = 6.28318548202514648f * random_2_0;
    float _S1098 = _S1096 * (F32_cos((_S1097)));
    float _S1099 = _S1096 * (F32_sin((_S1097)));
    float _S1100 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1098 * _S1098 - _S1099 * _S1099))))));
    return make_float3 (_S1098, _S1100, _S1099);
}

__device__ __forceinline__ SampleBSDF diffuseSample(float u_2, float3  n_i_10, float n_i_dot_v_7, float alpha_16, BSDFMaterial material_18, BSDFLobes lobes_12, float eta_i_12, float eta_o_12, uint random_state_15)
{
    float3  _S1101 = make_float3 (1.0f);
    SampleBSDF _S1102 = SampleBSDF_x24init_0(_S1101, _S1101, 0U, false, 0U, 0.0f);
    SampleBSDF sample_2 = _S1102;
    Random _S1103 = pcg(random_state_15);
    Random _S1104 = pcg(_S1103.state);
    (&sample_2)->random_state = _S1104.state;
    float3  _S1105 = sampleCosWeightedHemisphere(_S1103.value, _S1104.value);
    bool _S1106 = u_2 < (lobes_12.p_diffuse * lobes_12.translucent_share);
    float _S1107 = _S1105.y;
    float _S1108 = - _S1107;
    float _S1109 = _slang_select(_S1106, _S1108,_S1107);
    float3  _S1110 = tangentToWorld(make_float3 (_S1105.x, _S1109, _S1105.z), n_i_10);
    (&sample_2)->unit_direction = _S1110;
    (&sample_2)->refracted = _S1106;
    (&sample_2)->lobe = 0U;
    float3  _S1111 = diffuseBSDF((&sample_2)->unit_direction, n_i_10, alpha_16, material_18, lobes_12);
    (&sample_2)->throughput = _S1111;
    float _S1112 = diffusePDF(_S1109, 0.0f, n_i_dot_v_7, alpha_16, lobes_12, eta_i_12, eta_o_12);
    (&sample_2)->pdf = _S1112;
    return sample_2;
}

__device__ __forceinline__ SampleBSDF toonSample(float3  n_i_11, float n_i_dot_v_8, float alpha_17, BSDFMaterial material_19, BSDFLobes lobes_13, float eta_i_13, float eta_o_13, uint random_state_16)
{
    float3  _S1113 = make_float3 (1.0f);
    SampleBSDF _S1114 = SampleBSDF_x24init_0(_S1113, _S1113, 0U, false, 0U, 0.0f);
    SampleBSDF sample_3 = _S1114;
    Random _S1115 = pcg(random_state_16);
    Random _S1116 = pcg(_S1115.state);
    (&sample_3)->random_state = _S1116.state;
    float _S1117 = _S1115.value * lobes_13.toon_norm / 6.28318548202514648f;
    float t_20;
    if(lobes_13.toon_glossy)
    {
        t_20 = (F32_acos((clamp_1(1.0f - _S1117, -1.0f, 1.0f))));
    }
    else
    {
        t_20 = (F32_asin(((F32_min(((F32_sqrt((2.0f * _S1117)))), (1.0f))))));
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
        float _S1118;
        if(t_20 < (lobes_13.toon_a))
        {
            _S1118 = 1.0f;
        }
        else
        {
            _S1118 = (F32_max((1.0f - (t_20 - lobes_13.toon_a) / (F32_max((lobes_13.toon_s), (0.0000152587890625f)))), (0.0f)));
        }
        float integral_1;
        if(lobes_13.toon_glossy)
        {
            integral_1 = 1.0f - (F32_cos(((F32_min((t_20), (lobes_13.toon_a))))));
        }
        else
        {
            float _S1119 = (F32_sin(((F32_min((t_20), (lobes_13.toon_a))))));
            integral_1 = _S1119 * _S1119 / 2.0f;
        }
        bool _S1120 = t_20 > (lobes_13.toon_a);
        bool _S1121;
        if(_S1120)
        {
            _S1121 = (lobes_13.toon_s) > 0.0f;
        }
        else
        {
            _S1121 = false;
        }
        float integral_2;
        if(_S1121)
        {
            if(lobes_13.toon_glossy)
            {
                float _S1122 = (F32_cos((lobes_13.toon_a)));
                float _S1123 = (F32_cos((t_20)));
                integral_2 = (1.0f + lobes_13.toon_a / lobes_13.toon_s) * (_S1122 - _S1123) - ((F32_sin((t_20))) - t_20 * _S1123 - ((F32_sin((lobes_13.toon_a))) - lobes_13.toon_a * _S1122)) / lobes_13.toon_s;
            }
            else
            {
                float _S1124 = 2.0f * lobes_13.toon_a;
                float _S1125 = (F32_cos((_S1124)));
                float _S1126 = 2.0f * t_20;
                float _S1127 = (F32_cos((_S1126)));
                integral_2 = (1.0f + lobes_13.toon_a / lobes_13.toon_s) * (_S1125 - _S1127) / 4.0f - ((F32_sin((_S1126))) / 8.0f - t_20 * _S1127 / 4.0f - ((F32_sin((_S1124))) / 8.0f - lobes_13.toon_a * _S1125 / 4.0f)) / lobes_13.toon_s;
            }
            float integral_3 = integral_1 + integral_2;
            integral_2 = integral_3;
        }
        else
        {
            integral_2 = integral_1;
        }
        float _S1128 = _S1118 * (F32_sin((t_20)));
        float _S1129;
        if(lobes_13.toon_glossy)
        {
            _S1129 = 1.0f;
        }
        else
        {
            _S1129 = (F32_cos((t_20)));
        }
        float _S1130 = _S1128 * _S1129;
        float _S1131 = (integral_2 - _S1117) / _S1130;
        bool _S1132 = _S1130 > 0.0f;
        float _S1133 = _slang_select(_S1132, _S1131,0.0f);
        float _S1134 = clamp_1(t_20 - _S1133, 0.0f, lobes_13.toon_b);
        int k_1 = k_0 + int(1);
        t_20 = _S1134;
        k_0 = k_1;
    }
    float _S1135 = 6.28318548202514648f * _S1116.value;
    float _S1136 = (F32_sin((t_20)));
    float3  _S1137 = tangentToWorld(make_float3 (_S1136 * (F32_cos((_S1135))), (F32_cos((t_20))), _S1136 * (F32_sin((_S1135)))), lobes_13.toon_axis);
    (&sample_3)->unit_direction = _S1137;
    bool _S1138 = (dot_0(n_i_11, (&sample_3)->unit_direction)) < 0.0f;
    (&sample_3)->refracted = _S1138;
    (&sample_3)->lobe = 6U;
    float3  _S1139 = toonBSDF((&sample_3)->unit_direction, n_i_11, alpha_17, material_19, lobes_13);
    (&sample_3)->throughput = _S1139;
    float _S1140 = toonPDF(dot_0(n_i_11, (&sample_3)->unit_direction), dot_0((&sample_3)->unit_direction, lobes_13.toon_axis), n_i_dot_v_8, alpha_17, lobes_13, eta_i_13, eta_o_13);
    (&sample_3)->pdf = _S1140;
    return sample_3;
}

__device__ __forceinline__ SampleBSDF refractSample(float3  ggx_n_3, float3  n_i_12, float n_i_dot_v_9, float alpha_18, BSDFMaterial material_20, BSDFLobes lobes_14, float eta_i_14, float eta_o_14, uint random_state_17)
{
    float3  _S1141 = make_float3 (1.0f);
    SampleBSDF _S1142 = SampleBSDF_x24init_0(_S1141, _S1141, 0U, false, 0U, 0.0f);
    SampleBSDF sample_4 = _S1142;
    (&sample_4)->unit_direction = lobes_14.refracted;
    (&sample_4)->random_state = random_state_17;
    (&sample_4)->refracted = true;
    (&sample_4)->lobe = 1U;
    float3  _S1143 = refractBSDF((&sample_4)->unit_direction, n_i_12, alpha_18, material_20, lobes_14);
    (&sample_4)->throughput = _S1143;
    float _S1144 = refractPDF(0.0f, dot_0((&sample_4)->unit_direction, ggx_n_3), n_i_dot_v_9, alpha_18, lobes_14, eta_i_14, eta_o_14);
    (&sample_4)->pdf = _S1144;
    return sample_4;
}

static __device__ float3  reflect_0(float3  i_25, float3  n_10)
{
    return i_25 - make_float3 (2.0f * dot_0(n_10, i_25)) * n_10;
}

__device__ __forceinline__ SampleBSDF reflectSample(float3  in_dir_9, float3  ggx_n_4, float3  n_i_13, float n_i_dot_v_10, float alpha_19, BSDFMaterial material_21, BSDFLobes lobes_15, float eta_i_15, float eta_o_15, uint random_state_18)
{
    float3  _S1145 = make_float3 (1.0f);
    SampleBSDF _S1146 = SampleBSDF_x24init_0(_S1145, _S1145, 0U, false, 0U, 0.0f);
    SampleBSDF sample_5 = _S1146;
    float3  _S1147 = reflect_0(in_dir_9, ggx_n_4);
    float3  _S1148 = ((((_S1147)) * make_float3(rnorm3df(((_S1147)).x, ((_S1147)).y, ((_S1147)).z))));
    (&sample_5)->unit_direction = _S1148;
    (&sample_5)->random_state = random_state_18;
    (&sample_5)->lobe = 2U;
    float3  _S1149 = reflectBSDF((&sample_5)->unit_direction, n_i_13, alpha_19, material_21, lobes_15);
    (&sample_5)->throughput = _S1149;
    float _S1150 = reflectPDF(0.0f, 0.0f, n_i_dot_v_10, alpha_19, lobes_15, eta_i_15, eta_o_15);
    (&sample_5)->pdf = _S1150;
    return sample_5;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_10, float3  n_11, BSDFMaterial material_22, float eta_i_16, float eta_o_16, uint random_init_0, float2  screen_space_0)
{
    uint random_state_19 = random_init_0;
    float3  _S1151 = negate_0(in_dir_10);
    float _S1152 = dot_0(n_11, _S1151);
    float _S1153 = sign_0(_S1152);
    float3  n_i_14 = n_11 * make_float3 (_S1153);
    float _S1154 = (F32_abs((_S1152)));
    float _S1155 = material_22.roughness;
    float _S1156 = _S1155 * _S1155;
    AnisotropicFrame _S1157 = anisotropicFrame(material_22, n_i_14);
    SheenProfile _S1158 = sheenProfile(_S1151, n_i_14, material_22);
    float3  _S1159 = sampleHalfVector(_S1151, n_i_14, _S1156, _S1157, &random_state_19);
    BSDFLobes _S1160 = bsdfLobes(in_dir_10, _S1151, n_i_14, _S1159, material_22, eta_i_16, eta_o_16, _S1157, _S1158);
    BSDFLobes lobes_16 = _S1160;
    float _S1161 = translucentShare(material_22);
    (&lobes_16)->translucent_share = _S1161;
    Random _S1162 = pcg(random_state_19);
    random_state_19 = _S1162.state;
    bool _S1163 = (_S1162.value) < ((&lobes_16)->p_sheen_velvet);
    if(_S1163)
    {
        SampleBSDF _S1164 = sheenVelvetSample(n_i_14, _S1154, _S1156, material_22, lobes_16, eta_i_16, eta_o_16, random_state_19);
        return _S1164;
    }
    float _S1165 = _S1162.value - (&lobes_16)->p_sheen_velvet;
    bool _S1166 = _S1165 < ((&lobes_16)->p_diffuse);
    if(_S1166)
    {
        SampleBSDF _S1167 = diffuseSample(_S1165, n_i_14, _S1154, _S1156, material_22, lobes_16, eta_i_16, eta_o_16, random_state_19);
        return _S1167;
    }
    bool _S1168 = _S1165 < ((&lobes_16)->p_diffuse + (&lobes_16)->p_toon);
    if(_S1168)
    {
        SampleBSDF _S1169 = toonSample(n_i_14, _S1154, _S1156, material_22, lobes_16, eta_i_16, eta_o_16, random_state_19);
        return _S1169;
    }
    float _S1170 = (&lobes_16)->p_toon;
    bool _S1171 = (_S1165 - _S1170) < ((&lobes_16)->p_diffuse + (&lobes_16)->p_refract);
    if(_S1171)
    {
        SampleBSDF _S1172 = refractSample(_S1159, n_i_14, _S1154, _S1156, material_22, lobes_16, eta_i_16, eta_o_16, random_state_19);
        return _S1172;
    }
    SampleBSDF _S1173 = reflectSample(in_dir_10, _S1159, n_i_14, _S1154, _S1156, material_22, lobes_16, eta_i_16, eta_o_16, random_state_19);
    return _S1173;
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
    bool _S1174;
    bool _S1175;
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
    int _S1176;
    Shift ended_0;
    float density_3;
    float spread_2;
    float width_4;
    float sky_pdf_1;
    float spread_3;
    float width_5;
    uint b_6;
    float3  _S1177 = make_float3 (0.0f);
    Shift _S1178 = Shift_x24init_0(_S1177, 0.0f);
    uint _S1179 = r_8->path;
    uint _S1180 = extractBits_0(r_8->path, 0U, 5U);
    uint _S1181 = extractBits_0(_S1179, 5U, 5U);
    uint _S1182 = extractBits_0(_S1179, 10U, 2U);
    uint _S1183 = extractBits_0(_S1179, 12U, 3U);
    bool passes_0;
    if(replay_1)
    {
        bool _S1184 = _S1183 >= 3U;
        uint _S1185 = _slang_select(_S1184, 1U,0U);
        uint _S1186 = _S1180 + _S1185;
        uint _S1187 = (fcptMaxBounces());
        passes_0 = _S1186 > _S1187;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S1178;
    }
    uint _S1188 = _S1181 - 1U;
    bool _S1189 = _S1183 == 3U;
    uint _S1190 = _slang_select(_S1189, 1U,0U);
    uint _S1191 = _S1180 + _S1190;
    bool _S1192 = _S1182 == 0U;
    uint _S1193 = _slang_select(_S1192, _S1191,_S1188);
    FKHit _S1194 = (fcptReservoirHit((*r_8)));
    float3  _S1195 = dom_7->x0;
    float3  _S1196 = dom_7->x1 - dom_7->x0;
    float3  _S1197 = ((((_S1196)) * make_float3(rnorm3df(((_S1196)).x, ((_S1196)).y, ((_S1196)).z))));
    FKRay _S1198 = Ray_x24init_0(dom_7->x1, _S1197);
    FKRay ray_2 = _S1198;
    FKHit hit_4 = dom_7->hit;
    float3  scatter_in_0 = _S1177;
    float3  throughput_3 = make_float3 (1.0f);
    float3  weight_1 = throughput_3;
    float3  glowed_0 = _S1177;
    float3  extinction_in_0 = _S1177;
    float g_in_0 = 0.0f;
    uint filling_2 = 4294967295U;
    float _S1199 = dom_7->spread;
    float _S1200 = dom_7->width;
    float _S1201 = length_0(_S1196);
    NEEVertex _S1202 = NEEVertex_x24init_0(true, 0.0f, _S1177, _S1177, _S1177);
    NEEVertex nee_vertex_0 = _S1202;
    Vertex _S1203 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_0 = _S1203;
    Reservoir _S1204 = (Reservoir{});
    Reservoir chain_0 = _S1204;
    uint _S1205 = r_8->seed;
    (&chain_0)->seed = r_8->seed;
    (&ray_2)->origin = _S1195;
    (&hit_4)->distance = _S1201;
    FKMedium _S1206 = (fcptCameraMedium(((&ray_2)->unit_direction), ((&hit_4)->distance), (&filling_2)));
    uint _S1207 = filling_2;
    bool _S1208 = (fcptVaryingUsed());
    uint _S1209 = _slang_select(_S1208, _S1207,4294967295U);
    filling_2 = _S1209;
    scatter_in_0 = _S1206.scatter;
    extinction_in_0 = _S1206.extinction;
    g_in_0 = _S1206.g;
    Reservoir _S1210 = chain_0;
    uint _S1211 = filling_2;
    for(;;)
    {
        bool _S1212 = (fcptVaryingUsed());
        if(_S1212)
        {
            passes_0 = _S1211 != 4294967295U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            float _S1213 = (fcptMajorant((_S1211)));
            spread_1 = _S1213;
        }
        else
        {
            spread_1 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
        }
        if(replay_1)
        {
            turned_1 = 4294967295U == _S1193;
        }
        else
        {
            turned_1 = false;
        }
        if(turned_1)
        {
            turned_1 = _S1182 == 1U;
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
            ended_0 = _S1178;
            sky_pdf_0 = 0.0f;
            spread_1 = _S1199;
            width_3 = _S1200;
            density_2 = 1.0f;
            throughput_2 = throughput_3;
            b_5 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S1214 = (&prev_0)->rough;
        if(_S1214)
        {
            turned_1 = !(spread_1 > 0.0f);
        }
        else
        {
            turned_1 = false;
        }
        (&prev_0)->rough = turned_1;
        uint _S1215 = stream(_S1205, 384U);
        uint tracking_0 = _S1215;
        weight_1 = throughput_3;
        glowed_0 = _S1177;
        b_5 = 4294967295U;
        throughput_2 = throughput_3;
        density_2 = 1.0f;
        threshold_0 = _S1199;
        width_3 = _S1200;
        sky_pdf_0 = 0.0f;
        for(;;)
        {
            if(((&hit_4)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S1176 = int(1);
                break;
            }
            uint _S1216 = b_5 + 320U;
            bool _S1217 = b_5 == 4294967295U;
            uint _S1218 = _slang_select(_S1217, 384U,_S1216);
            uint _S1219 = stream(_S1205, _S1218);
            Random _S1220 = pcg(_S1219);
            float _S1221 = - (F32_log((1.0f - _S1220.value))) / spread_1;
            if(passes_0)
            {
                float3  _S1222 = (&ray_2)->origin;
                float3  _S1223 = (&ray_2)->unit_direction;
                float _S1224 = (&hit_4)->distance;
                uint _S1225 = _slang_select(_S1217, 0U,b_5);
                uint _S1226 = (&prev_0)->lobe;
                uint _S1227 = _slang_select(_S1217, 3U,_S1226);
                float _S1228 = (fcptTrackMedium((_S1211), (_S1222), (_S1223), (_S1224), (&tracking_0), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1225), (_S1227), (_S1217)));
                geometry_density_0 = _S1228;
            }
            else
            {
                geometry_density_0 = _S1221;
            }
            bool _S1229 = !(geometry_density_0 < ((&hit_4)->distance));
            if(_S1229)
            {
                _S1176 = int(1);
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
                float3  _S1230 = throughput_2 * glowed_0 / make_float3 (density_2);
                float3  _S1231 = sel_7->glow + _S1230;
                sel_7->glow = _S1231;
            }
            else
            {
            }
            glowed_0 = _S1177;
            uint b_7 = b_5 + 1U;
            float3  _S1232 = (&ray_2)->origin + make_float3 (geometry_density_0) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S1232;
            float3  _S1233 = flightWeight_0(scatter_in_0, extinction_in_0, spread_1, geometry_density_0, true);
            float3  _S1234 = weight_1;
            float3  _S1235 = _slang_select(passes_0, _S1234,_S1233);
            float3  throughput_4 = throughput_2 * _S1235;
            uint _S1236 = stream(_S1205, b_7 + 320U);
            tracking_0 = _S1236;
            weight_1 = throughput_3;
            float width_6 = width_3 + threshold_0 * geometry_density_0;
            float _S1237 = threshold_0 + 3.14159274101257324f;
            bool _S1238 = !replay_1;
            if(_S1238)
            {
                is_inside_5 = true;
            }
            else
            {
                bool _S1239 = b_7 == _S1193;
                if(_S1239)
                {
                    is_inside_5 = !passes_0;
                }
                else
                {
                    is_inside_5 = false;
                }
            }
            TreeSample _S1240 = TreeSample_x24init_0(_S1177, _S1177, 0.0f, 0U);
            if(is_inside_5)
            {
                float3  _S1241 = (&ray_2)->origin;
                float3  _S1242 = (&ray_2)->unit_direction;
                float3  _S1243 = (&ray_2)->unit_direction;
                uint _S1244 = stream(_S1205, b_7 + 64U);
                float3  _S1245 = extinction_in_0;
                float3  _S1246 = extinction_in_0;
                uint2  _S1247 = make_uint2 (_S1211);
                float3  _S1248 = (&ray_2)->unit_direction;
                uint _S1249 = arrivalLobe_0(b_7, (&prev_0)->lobe);
                FKHit _S1250 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S1251 = _S1250;
                ShadowContext _S1252 = ShadowContext_x24init_0(_S1245, _S1246, _S1247, _S1248, b_7, _S1249, false, geometry_density_0, width_6, &_S1251, false);
                ShadowContext _S1253 = _S1252;
                TreeSample _S1254 = sampleLightTree_0(_S1241, _S1242, _S1243, 0.0f, true, _S1244, &_S1253);
                light_3 = _S1254;
            }
            else
            {
                light_3 = _S1240;
            }
            float _S1255 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_3.dir));
            uint _S1256 = (fcptMaxBounces());
            bool _S1257 = b_7 < _S1256;
            if(_S1257)
            {
                viewed_0 = (light_3.density) > 0.0f;
            }
            else
            {
                viewed_0 = false;
            }
            float _S1258 = _slang_select(viewed_0, _S1255,0.0f);
            float3  _S1259 = throughput_4 * light_3.radiance;
            float _S1260 = powerHeuristic(light_3.density, _S1258);
            float3  _S1261 = _S1259 * make_float3 (_S1255 * _S1260);
            float3  _S1262 = _slang_select(is_inside_5, _S1261,_S1177);
            if(replay_1)
            {
                _S1174 = b_7 == _S1193;
            }
            else
            {
                _S1174 = false;
            }
            if(_S1174)
            {
                bool _S1263 = _S1182 == 2U;
                if(_S1263)
                {
                    float _S1264 = rgb_to_greyscale(_S1262);
                    passes_0 = _S1264 > 0.0f;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S1265 = Shift_x24init_0(_S1262, 1.0f);
                    _S1176 = int(0);
                    ended_0 = _S1265;
                    spread_1 = _S1237;
                    geometry_density_0 = width_6;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_7;
                    break;
                }
                _S1176 = int(0);
                ended_0 = _S1178;
                spread_1 = _S1237;
                geometry_density_0 = width_6;
                chain_throughput_0 = throughput_4;
                layer_0 = b_7;
                break;
            }
            if(_S1238)
            {
                Reservoir candidate_3 = _S1210;
                uint _S1266 = extractBits_0(_S1210.path, 10U, 2U);
                bool _S1267 = _S1266 == 1U;
                if(_S1267)
                {
                    float3  _S1268 = safeDivide(_S1262, _S1177);
                    (&candidate_3)->radiance = _S1268;
                }
                else
                {
                    uint _S1269 = insertBits_0(0U, b_7 + 1U, 5U, 5U);
                    uint _S1270 = insertBits_0(_S1269, 2U, 10U, 2U);
                    (&candidate_3)->path = _S1270;
                }
                Reservoir _S1271 = withEnd(candidate_3, 0U, b_7, _S1262);
                offer(sel_7, _S1271, _S1262 * make_float3 (scale_3) / make_float3 (density_2));
                float _S1272 = survivalProbability(throughput_4, density_2);
                uint _S1273 = stream(_S1205, b_7 + 128U);
                Random _S1274 = pcg(_S1273);
                bool _S1275 = _S1272 < (_S1274.value);
                if(_S1275)
                {
                    _S1175 = true;
                }
                else
                {
                    uint _S1276 = (fcptMaxBounces());
                    _S1175 = b_7 >= _S1276;
                }
                if(_S1175)
                {
                    _S1176 = int(0);
                    ended_0 = _S1178;
                    spread_1 = _S1237;
                    geometry_density_0 = width_6;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_7;
                    break;
                }
                float _S1277 = density_2 * _S1272;
                density_2 = _S1277;
            }
            else
            {
            }
            float phase_pdf_0 = 0.0f;
            uint _S1278 = stream(_S1205, b_7);
            float3  _S1279 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1278, &phase_pdf_0);
            (&ray_2)->unit_direction = _S1279;
            NEEVertex _S1280 = NEEVertex_x24init_0(false, phase_pdf_0, (&ray_2)->origin, _S1177, (&ray_2)->origin);
            nee_vertex_0 = _S1280;
            Vertex _S1281 = Vertex_x24init_0(false, 0U, 0.0f, 1.0f, false);
            prev_0 = _S1281;
            float _S1282 = (&prev_0)->pdf;
            FKRay _S1283 = ray_2;
            FKHit _S1284 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S1285 = (fcptTraverseInstanceBVH((_S1283), (true), (4.294967296e+09f), (false), (_S1284), (false)));
            hit_4 = _S1285;
            b_5 = b_7;
            throughput_2 = throughput_4;
            threshold_0 = _S1237;
            width_3 = width_6;
            sky_pdf_0 = _S1282;
        }
        if(_S1176 != int(1))
        {
            width_3 = geometry_density_0;
            throughput_2 = chain_throughput_0;
            b_5 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S1178;
        spread_1 = threshold_0;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    bool _S1286 = b_5 == 4294967295U;
    bool _S1287 = ((&hit_4)->instance_index) == 4294967295U;
    if(_S1287)
    {
        bool _S1288 = !(&nee_vertex_0)->none;
        float _S1289 = _slang_select(_S1288, sky_pdf_0,0.0f);
        float _S1290 = escapeWeight_0(_S1289, (&ray_2)->unit_direction);
        float3  _S1291 = environment_0((&ray_2)->unit_direction, b_5, (&prev_0)->lobe);
        float3  _S1292 = throughput_2 * _S1291;
        if(replay_1)
        {
            bool _S1293 = b_5 == _S1193;
            if(_S1293)
            {
                passes_0 = _S1182 == 3U;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                return Shift_x24init_0(_S1292 * make_float3 (_S1290) / make_float3 (r_8->jac), density_2 / r_8->jac);
            }
            if(_S1192)
            {
                passes_0 = _S1189;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                passes_0 = b_5 == _S1180;
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
                return Shift_x24init_0(_S1292 * make_float3 (_S1290), 1.0f);
            }
            return _S1178;
        }
        Reservoir candidate_4 = chain_0;
        uint _S1294 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1295 = _S1294 == 1U;
        if(_S1295)
        {
            uint _S1296 = extractBits_0((&chain_0)->path, 5U, 5U);
            bool _S1297 = _S1296 == b_5;
            float _S1298 = _slang_select(_S1297, 1.0f,_S1290);
            float3  _S1299 = safeDivide(_S1292 * make_float3 (_S1298), _S1177);
            (&candidate_4)->radiance = _S1299;
        }
        else
        {
            bool _S1300 = (&prev_0)->rough;
            if(_S1300)
            {
                uint _S1301 = insertBits_0(0U, b_5 + 1U, 5U, 5U);
                uint _S1302 = insertBits_0(_S1301, 3U, 10U, 2U);
                uint _S1303 = insertBits_0(_S1302, (&prev_0)->lobe, 15U, 3U);
                bool _S1304 = (&prev_0)->inside;
                uint _S1305 = _slang_select(_S1304, 1U,0U);
                uint _S1306 = insertBits_0(_S1303, _S1305, 22U, 1U);
                (&candidate_4)->path = _S1306;
                (&candidate_4)->jac = (&prev_0)->pdf;
                (&candidate_4)->dir = (&ray_2)->unit_direction;
            }
        }
        float3  _S1307 = _S1292 * make_float3 (_S1290);
        Reservoir _S1308 = withEnd(candidate_4, 3U, b_5, _S1307);
        offer(sel_7, _S1308, _S1307 * make_float3 (scale_3) / make_float3 (density_2));
        return _S1178;
    }
    float3  _S1309 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
    (&ray_2)->origin = _S1309;
    bool _S1310 = (fcptVaryingUsed());
    if(_S1310)
    {
        passes_0 = filling_2 != 4294967295U;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        bool _S1311 = !replay_1;
        if(_S1311)
        {
            float3  _S1312 = throughput_2 * glowed_0 / make_float3 (density_2);
            float3  _S1313 = sel_7->glow + _S1312;
            sel_7->glow = _S1313;
        }
        float3  _S1314 = throughput_2 * weight_1;
        throughput_2 = _S1314;
    }
    else
    {
        float3  _S1315 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
        float3  _S1316 = throughput_2 * _S1315;
        throughput_2 = _S1316;
    }
    float _S1317 = width_3 + spread_1 * (&hit_4)->distance;
    uint _S1318 = b_5 + 1U;
    b_5 = _S1318;
    layer_0 = 0U;
    width_3 = _S1317;
    passes_0 = false;
    threshold_0 = 0.0f;
    turned_1 = false;
    is_inside_5 = false;
    chain_throughput_0 = _S1177;
    float3  reconnection_0 = _S1177;
    viewed_0 = _S1286;
    for(;;)
    {
        bool _S1319 = ((&hit_4)->is_point_light) == 1U;
        if(replay_1)
        {
            _S1174 = _S1182 == 1U;
        }
        else
        {
            _S1174 = false;
        }
        if(_S1174)
        {
            _S1175 = b_5 == _S1181;
        }
        else
        {
            _S1175 = false;
        }
        bool _S1320;
        if(_S1175)
        {
            bool _S1321 = ((&hit_4)->instance_index) != (_S1194.instance_index);
            if(_S1321)
            {
                _S1320 = true;
            }
            else
            {
                _S1320 = ((&hit_4)->triangle_index) != (_S1194.triangle_index);
            }
        }
        else
        {
            _S1320 = false;
        }
        if(_S1320)
        {
            return _S1178;
        }
        FKMedium _S1322 = Medium_x24init_0(_S1177, _S1177, 0.0f);
        BSDFMaterial _S1323 = Material_x24init_0(_S1177, _S1177, 0.0f, 0.0f, 0.0f, 0.0f, _S1177, throughput_3, 1.0f, _S1177, _S1177, 0.5f, 0.0f, 0.0f, _S1177, 0.0f, _S1177);
        FKMedium _S1324 = _S1322;
        FKSurface _S1325 = Surface_x24init_0(_S1177, _S1177, 0.0f, &_S1323, false, 0U, 1.0f, false, &_S1324, 4294967295U, _S1177);
        bool _S1326 = !_S1319;
        bool scatter_2;
        bool is_inside_6;
        float3  throughput_5;
        FKSurface surface_12;
        if(_S1326)
        {
            uint _S1327 = stream(_S1205, b_5);
            uint _S1328 = arrivalLobe_0(b_5, (&prev_0)->lobe);
            FKSurface _S1329 = (fcptSurfaceAtPath((hit_4), ((&ray_2)->origin), (_S1327), (width_3), (layer_0), (b_5), (_S1328), ((&ray_2)->unit_direction)));
            bool _S1330 = !passes_0;
            FKSurface _S1331 = _S1329;
            FKSurface _S1332 = emitting_0(&_S1331, _S1330);
            uint _S1333 = stream(_S1205, b_5 + 256U);
            Random _S1334 = pcg(_S1333);
            FKSurface _S1335 = _S1332;
            FKSurface _S1336 = uncovered_0(&_S1335, _S1334.value);
            float _S1337 = facingSign(_S1336.material.transmission, _S1336.geometry_n, (&ray_2)->unit_direction);
            bool _S1338 = _S1337 < 0.0f;
            bool _S1339 = (_S1336.material.transmission) > 0.0f;
            if(_S1339)
            {
                bool _S1340 = arrivesBehind_0((&ray_2)->unit_direction, _S1336.geometry_n);
                scatter_2 = _S1340;
            }
            else
            {
                scatter_2 = false;
            }
            FKSurface _S1341 = _S1336;
            FKSurface _S1342 = facingRay_0(&_S1341, (&ray_2)->unit_direction);
            if(passes_0)
            {
                bool _S1343 = arrivesBehind_0((&ray_2)->unit_direction, _S1342.geometry_n);
                is_inside_6 = _S1343;
            }
            else
            {
                is_inside_6 = scatter_2;
            }
            if(is_inside_6)
            {
                float3  _S1344 = beerLambert((&hit_4)->distance, _S1342.material.absorption);
                float3  _S1345 = throughput_2 * _S1344;
                throughput_5 = _S1345;
            }
            else
            {
                throughput_5 = throughput_2;
            }
            bool _S1346 = !_S1342.skip;
            float geometry_density_1 = (F32_abs((dot_0(_S1342.geometry_n, (&ray_2)->unit_direction)))) / ((&hit_4)->distance * (&hit_4)->distance);
            bool _S1347 = b_5 == _S1318;
            if(_S1347)
            {
                float _S1348 = 0.00251327408477664f / geometry_density_1;
                geometry_density_0 = _S1348;
            }
            else
            {
                geometry_density_0 = threshold_0;
            }
            float _S1349 = geometry_density_0;
            scatter_2 = _S1346;
            geometry_density_0 = geometry_density_1;
            threshold_0 = _S1349;
            surface_12 = _S1342;
            turned_1 = _S1338;
        }
        else
        {
            scatter_2 = false;
            geometry_density_0 = 0.0f;
            surface_12 = _S1325;
            throughput_5 = throughput_2;
            is_inside_6 = is_inside_5;
        }
        bool _S1350;
        if(scatter_2)
        {
            _S1350 = (&prev_0)->rough;
        }
        else
        {
            _S1350 = false;
        }
        bool _S1351;
        if(_S1350)
        {
            _S1351 = ((&prev_0)->pdf * geometry_density_0 * threshold_0) <= 1.0f;
        }
        else
        {
            _S1351 = false;
        }
        FKSurface _S1352 = surface_12;
        FKSurface _S1353 = surface_12;
        float _S1354 = dot_0(surface_12.smooth_n, - (&ray_2)->unit_direction);
        float2  _S1355 = vertexEta(_S1352.material, _S1354);
        bool _S1356;
        if(scatter_2)
        {
            uint _S1357 = (fcptMaxBounces());
            bool _S1358 = b_5 >= _S1357;
            if(_S1358)
            {
                _S1356 = true;
            }
            else
            {
                bool _S1359 = neeDecision(_S1352.material, _S1354, _S1355.x, _S1355.y);
                _S1356 = _S1359;
            }
        }
        else
        {
            _S1356 = false;
        }
        bool _S1360;
        if(passes_0)
        {
            _S1360 = true;
        }
        else
        {
            _S1360 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S1360)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S1356;
        }
        bool _S1361 = (fcptHairUsed());
        bool _S1362;
        if(_S1361)
        {
            float3  _S1363 = surface_12.hair;
            _S1362 = (dot_0(_S1363, _S1363)) > 0.0f;
        }
        else
        {
            _S1362 = false;
        }
        bool _S1364;
        if(_S1362)
        {
            _S1364 = true;
        }
        else
        {
            BSDFMaterial _S1365 = _S1352.material;
            bool _S1366 = isTranslucent_0(&_S1365);
            _S1364 = _S1366;
        }
        bool _S1367;
        if(_S1364)
        {
            _S1367 = true;
        }
        else
        {
            bool _S1368 = (_S1352.material.transmission) > 0.0f;
            if(_S1368)
            {
                uint _S1369 = (fcptLayers((hit_4)));
                _S1367 = _S1369 == 1U;
            }
            else
            {
                _S1367 = false;
            }
        }
        float3  emission_0;
        if(_S1319)
        {
            float3  _S1370 = (fcptCalculatePointLightContrib(((&hit_4)->instance_index)));
            emission_0 = _S1370;
        }
        else
        {
            emission_0 = _S1352.material.emissive;
        }
        bool _S1371 = !replay_1;
        bool _S1372;
        if(_S1371)
        {
            _S1372 = true;
        }
        else
        {
            _S1372 = b_5 >= _S1193;
        }
        bool _S1373;
        if(_S1372)
        {
            float _S1374 = rgb_to_greyscale(emission_0);
            _S1373 = _S1374 > 0.0f;
        }
        else
        {
            _S1373 = false;
        }
        float3  emission_1;
        if(_S1373)
        {
            NEEVertex _S1375 = nee_vertex_0;
            FKHit _S1376 = hit_4;
            float _S1377 = emissionWeight_0(&_S1375, &_S1376, (&ray_2)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S1377);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S1378;
        if(replay_1)
        {
            _S1378 = _S1182 == 1U;
        }
        else
        {
            _S1378 = false;
        }
        bool _S1379;
        if(_S1378)
        {
            _S1379 = b_5 > _S1181;
        }
        else
        {
            _S1379 = false;
        }
        bool _S1380;
        if(_S1379)
        {
            _S1380 = b_5 == _S1180;
        }
        else
        {
            _S1380 = false;
        }
        bool _S1381;
        if(_S1380)
        {
            bool _S1382 = _S1183 == 1U;
            if(_S1382)
            {
                _S1381 = true;
            }
            else
            {
                _S1381 = _S1183 == 2U;
            }
        }
        else
        {
            _S1381 = false;
        }
        if(_S1381)
        {
            bool _S1383 = _S1319 != (_S1183 == 2U);
            if(_S1383)
            {
                return _S1178;
            }
            return Shift_x24init_0(throughput_5 * emission_1 / make_float3 (r_8->jac), density_2 / r_8->jac);
        }
        uint _S1384 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1385 = _S1384 == 1U;
        Reservoir here_0 = chain_0;
        uint _S1386 = insertBits_0(0U, b_5, 5U, 5U);
        uint _S1387 = insertBits_0(_S1386, 1U, 10U, 2U);
        uint _S1388 = insertBits_0(_S1387, (&prev_0)->lobe, 15U, 3U);
        bool _S1389 = (&prev_0)->inside;
        uint _S1390 = _slang_select(_S1389, 1U,0U);
        uint _S1391 = insertBits_0(_S1388, _S1390, 22U, 1U);
        (&here_0)->path = _S1391;
        float _S1392 = (&prev_0)->pdf * geometry_density_0;
        (&here_0)->jac = _S1392;
        fcptWithReservoirHit((&here_0), (&hit_4));
        bool _S1393;
        if(replay_1)
        {
            _S1393 = _S1182 == 1U;
        }
        else
        {
            _S1393 = false;
        }
        bool _S1394;
        if(_S1393)
        {
            _S1394 = b_5 == _S1181;
        }
        else
        {
            _S1394 = false;
        }
        bool _S1395 = b_5 == _S1193;
        bool _S1396;
        if(_S1395)
        {
            bool _S1397 = !scatter_2;
            if(_S1397)
            {
                _S1396 = true;
            }
            else
            {
                bool _S1398 = _S1182 != 1U;
                if(_S1398)
                {
                    _S1396 = _S1182 != 3U;
                }
                else
                {
                    _S1396 = false;
                }
            }
        }
        else
        {
            _S1396 = false;
        }
        bool _S1399;
        if(_S1396)
        {
            _S1399 = _S1182 == 2U;
        }
        else
        {
            _S1399 = false;
        }
        bool _S1400;
        if(_S1399)
        {
            _S1400 = !_S1351;
        }
        else
        {
            _S1400 = false;
        }
        bool _S1401;
        if(_S1400)
        {
            _S1401 = _S1183 != 4U;
        }
        else
        {
            _S1401 = false;
        }
        bool _S1402 = _S1181 == _S1180;
        bool _S1403;
        if(_S1402)
        {
            _S1403 = _S1183 == 0U;
        }
        else
        {
            _S1403 = false;
        }
        bool _S1404;
        if(_S1403)
        {
            _S1404 = ((&hit_4)->instance_index) == (_S1194.instance_index);
        }
        else
        {
            _S1404 = false;
        }
        bool _S1405;
        if(_S1404)
        {
            _S1405 = ((&hit_4)->triangle_index) == (_S1194.triangle_index);
        }
        else
        {
            _S1405 = false;
        }
        bool _S1406;
        if(_S1405)
        {
            _S1406 = _S1351;
        }
        else
        {
            _S1406 = false;
        }
        bool _S1407 = _slang_select(_S1394, _S1406,_S1401);
        bool _S1408;
        if(nee_0)
        {
            _S1408 = _slang_select(replay_1, _S1407,scatter_2);
        }
        else
        {
            _S1408 = false;
        }
        TreeSample _S1409 = TreeSample_x24init_0(_S1177, _S1177, 0.0f, 0U);
        uint2  _S1410 = make_uint2 (0U);
        float2  _S1411 = make_float2 (0.0f);
        FKHit _S1412 = Hit_x24init_0(_S1411, 4294967295U, 0U, 0U, 0.0f);
        FKHit _S1413 = _S1412;
        ShadowContext _S1414 = ShadowContext_x24init_0(_S1177, _S1177, _S1410, _S1177, 0U, 0U, false, 0.0f, 0.0f, &_S1413, false);
        bool _S1415;
        if(nee_0)
        {
            _S1415 = _S1372;
        }
        else
        {
            _S1415 = false;
        }
        ShadowContext context_5;
        if(_S1415)
        {
            uint _S1416 = arrivalLobe_0(b_5, (&prev_0)->lobe);
            FKMedium _S1417 = (fcptOutsideMedium((hit_4)));
            FKSurface _S1418 = surface_12;
            FKHit _S1419 = hit_4;
            FKMedium _S1420 = _S1417;
            ShadowContext _S1421 = shadowContext_0(&_S1418, turned_1, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_5, _S1416, (&hit_4)->distance, width_3, &_S1419, _S1362, &_S1420);
            context_5 = _S1421;
        }
        else
        {
            context_5 = _S1414;
        }
        float3  throughput_6;
        float3  lit_0;
        if(_S1408)
        {
            float3  _S1422 = (&ray_2)->origin;
            if(_S1362)
            {
                throughput_6 = _S1177;
            }
            else
            {
                throughput_6 = _S1353.smooth_n;
            }
            FKSurface _S1423 = surface_12;
            uint _S1424 = stream(_S1205, b_5 + 64U);
            ShadowContext _S1425 = context_5;
            TreeSample _S1426 = sampleLightTree_0(_S1422, throughput_6, surface_12.geometry_n, surface_12.geometry_offset, _S1367, _S1424, &_S1425);
            bool _S1427 = any_1((_S1426.radiance) != _S1177);
            if(_S1427)
            {
                if(_S1362)
                {
                    uint _S1428 = (fcptMaxBounces());
                    bool _S1429 = b_5 < _S1428;
                    FKSurface _S1430 = surface_12;
                    TreeSample _S1431 = _S1426;
                    float3  _S1432 = hairLight_0(&_S1430, (&ray_2)->unit_direction, &_S1431, _S1429);
                    lit_0 = _S1432;
                }
                else
                {
                    float _S1433 = _S1355.x;
                    float _S1434 = _S1355.y;
                    uint _S1435 = (fcptMaxBounces());
                    bool _S1436 = b_5 < _S1435;
                    TreeSample _S1437 = _S1426;
                    BSDFMaterial _S1438 = _S1352.material;
                    float3  _S1439 = lightBSDF_0((&ray_2)->unit_direction, &_S1437, _S1353.smooth_n, _S1423.geometry_n, &_S1438, _S1433, _S1434, _S1436, surface_12.random_state);
                    lit_0 = _S1439;
                }
            }
            else
            {
                lit_0 = _S1177;
            }
            light_3 = _S1426;
        }
        else
        {
            light_3 = _S1409;
            lit_0 = _S1177;
        }
        bool viewed_1;
        bool refracted_4;
        bool wrong_side_0;
        bool _S1440;
        bool _S1441;
        float density_4;
        if(_S1394)
        {
            bool _S1442 = !_S1351;
            if(_S1442)
            {
                return _S1178;
            }
            float3  throughput_7 = throughput_5 * make_float3 (geometry_density_0);
            float density_5 = density_2 * geometry_density_0;
            if(_S1402)
            {
                viewed_1 = _S1183 == 1U;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                return Shift_x24init_0(throughput_7 * emission_1 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1402)
            {
                refracted_4 = _S1183 == 0U;
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
            {
                bool _S1443 = !nee_0;
                if(_S1443)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S1444 = rgb_to_greyscale(light_3.radiance);
                    passes_0 = !(_S1444 > 0.0f);
                }
                if(passes_0)
                {
                    return _S1178;
                }
                return Shift_x24init_0(throughput_7 * lit_0 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1402)
            {
                wrong_side_0 = _S1183 == 4U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                bool _S1445 = !nee_0;
                if(_S1445)
                {
                    return _S1178;
                }
                float _S1446 = environmentPdf_0(r_8->dir);
                float3  _S1447 = skyBSDF((&ray_2)->unit_direction, r_8->dir, surface_12, _S1355, is_inside_6, _S1446, surface_12.random_state);
                return Shift_x24init_0(throughput_7 * _S1447 * r_8->radiance / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            uint _S1448 = extractBits_0(_S1179, 21U, 1U);
            bool _S1449 = nee_0 != (_S1448 == 1U);
            if(_S1449)
            {
                return _S1178;
            }
            throughput_6 = throughput_7;
            density_4 = density_5;
        }
        else
        {
            if(replay_1)
            {
                viewed_1 = _S1395;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                bool _S1450 = !scatter_2;
                if(_S1450)
                {
                    refracted_4 = true;
                }
                else
                {
                    bool _S1451 = _S1182 != 1U;
                    if(_S1451)
                    {
                        refracted_4 = _S1182 != 3U;
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
                bool _S1452 = _S1182 == 2U;
                if(_S1452)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1351;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1183 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    if(_S1362)
                    {
                        return _S1178;
                    }
                    uint _S1453 = stream(_S1205, b_5 + 448U);
                    FKRay _S1454 = ray_2;
                    FKSurface _S1455 = surface_12;
                    ShadowContext _S1456 = context_5;
                    SkySample _S1457 = sampleSky_0(&_S1454, &_S1455, _S1355, is_inside_6, _S1453, surface_12.random_state, &_S1456);
                    return Shift_x24init_0(throughput_5 * _S1457.color, 1.0f);
                }
                if(_S1452)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1351;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float _S1458 = rgb_to_greyscale(light_3.radiance);
                    bool _S1459 = !(_S1458 > 0.0f);
                    if(_S1459)
                    {
                        return _S1178;
                    }
                    return Shift_x24init_0(throughput_5 * lit_0, 1.0f);
                }
                if(_S1192)
                {
                    passes_0 = _S1183 == 2U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1319;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_5 * emission_1, 1.0f);
                }
                if(_S1192)
                {
                    passes_0 = _S1183 == 1U;
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
                    passes_0 = !_S1351;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_5 * emission_1, 1.0f);
                }
                return _S1178;
            }
            else
            {
                if(_S1371)
                {
                    wrong_side_0 = scatter_2;
                }
                else
                {
                    wrong_side_0 = false;
                }
                if(wrong_side_0)
                {
                    bool _S1460 = b_5 > 0U;
                    if(_S1460)
                    {
                        Reservoir candidate_5 = chain_0;
                        if(_S1385)
                        {
                            float3  _S1461 = safeDivide(throughput_5 * emission_1, chain_throughput_0);
                            (&candidate_5)->radiance = _S1461;
                        }
                        else
                        {
                            if(_S1351)
                            {
                                candidate_5 = here_0;
                            }
                        }
                        float3  _S1462 = throughput_5 * emission_1;
                        Reservoir _S1463 = withEnd(candidate_5, 1U, b_5, _S1462);
                        offer(sel_7, _S1463, _S1462 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    else
                    {
                        float3  _S1464 = throughput_5 * emission_1;
                        float3  _S1465 = sel_7->glow + _S1464;
                        sel_7->glow = _S1465;
                    }
                    if(nee_0)
                    {
                        float3  _S1466 = throughput_5 * lit_0;
                        Reservoir candidate_6 = chain_0;
                        if(_S1385)
                        {
                            float3  _S1467 = safeDivide(_S1466, chain_throughput_0);
                            (&candidate_6)->radiance = _S1467;
                        }
                        else
                        {
                            if(_S1351)
                            {
                                candidate_6 = here_0;
                                uint _S1468 = insertBits_0((&candidate_6)->path, 1U, 21U, 1U);
                                (&candidate_6)->path = _S1468;
                                (&candidate_6)->dir = light_3.dir;
                                (&candidate_6)->radiance = light_3.radiance;
                            }
                            else
                            {
                                uint _S1469 = insertBits_0(0U, b_5 + 1U, 5U, 5U);
                                uint _S1470 = insertBits_0(_S1469, 2U, 10U, 2U);
                                (&candidate_6)->path = _S1470;
                            }
                        }
                        Reservoir _S1471 = withEnd(candidate_6, 0U, b_5, _S1466);
                        offer(sel_7, _S1471, _S1466 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    if(nee_0)
                    {
                        if(_S1362)
                        {
                            _S1440 = false;
                        }
                        else
                        {
                            bool _S1472 = environmentMapped_0();
                            _S1440 = _S1472;
                        }
                    }
                    else
                    {
                        _S1440 = false;
                    }
                    if(_S1440)
                    {
                        uint _S1473 = (fcptMaxBounces());
                        _S1441 = b_5 < _S1473;
                    }
                    else
                    {
                        _S1441 = false;
                    }
                    if(_S1441)
                    {
                        uint _S1474 = stream(_S1205, b_5 + 448U);
                        FKRay _S1475 = ray_2;
                        FKSurface _S1476 = surface_12;
                        ShadowContext _S1477 = context_5;
                        SkySample _S1478 = sampleSky_0(&_S1475, &_S1476, _S1355, is_inside_6, _S1474, surface_12.random_state, &_S1477);
                        float3  _S1479 = throughput_5 * _S1478.color;
                        Reservoir candidate_7 = chain_0;
                        if(_S1385)
                        {
                            float3  _S1480 = safeDivide(_S1479, chain_throughput_0);
                            (&candidate_7)->radiance = _S1480;
                        }
                        else
                        {
                            if(_S1351)
                            {
                                candidate_7 = here_0;
                                uint _S1481 = insertBits_0((&candidate_7)->path, 1U, 21U, 1U);
                                (&candidate_7)->path = _S1481;
                                (&candidate_7)->dir = _S1478.dir;
                                (&candidate_7)->radiance = _S1478.radiance;
                            }
                            else
                            {
                                uint _S1482 = insertBits_0(0U, b_5 + 1U, 5U, 5U);
                                uint _S1483 = insertBits_0(_S1482, 2U, 10U, 2U);
                                (&candidate_7)->path = _S1483;
                            }
                        }
                        Reservoir _S1484 = withEnd(candidate_7, 4U, b_5, _S1479);
                        offer(sel_7, _S1484, _S1479 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                }
            }
            throughput_6 = throughput_5;
            density_4 = density_2;
        }
        bool _S1485;
        bool _S1486;
        bool _S1487;
        bool straight_0;
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
        bool _S1498;
        bool _S1499;
        bool _S1500;
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
                viewed_1 = _S1395;
            }
            else
            {
                viewed_1 = false;
            }
            uint _S1501 = extractBits_0(_S1179, 15U, 3U);
            uint _S1502 = extractBits_0(_S1179, 18U, 3U);
            uint _S1503 = _slang_select(_S1394, _S1502,_S1501);
            float3  _S1504 = r_8->dir;
            bool refracted_5 = _S1503 == 1U;
            SampleBSDF _S1505 = SampleBSDF_x24init_0(_S1177, _S1177, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_5 = _S1505;
            float3  reconnection_1;
            if(viewed_1)
            {
                uint _S1506 = extractBits_0(_S1179, 22U, 1U);
                bool _S1507 = is_inside_6 != (_S1506 == 1U);
                if(_S1507)
                {
                    return _S1178;
                }
                bool _S1508 = _S1182 == 1U;
                if(_S1508)
                {
                    float3  _S1509 = (fcptHitPosition((_S1194)));
                    throughput_8 = _S1509;
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
                    BSDFMaterial _S1510 = _S1352.material;
                    bool _S1511 = isTranslucent_0(&_S1510);
                    if(_S1511)
                    {
                        refracted_4 = _S1503 == 0U;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                    if(refracted_4)
                    {
                        float3  _S1512 = throughput_8 - (&ray_2)->origin;
                        float3  _S1513 = _slang_select(_S1508, _S1512,_S1504);
                        wrong_side_0 = (dot_0(_S1353.smooth_n, _S1513) * _S1354) < 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    refracted_4 = wrong_side_0;
                }
                if(_S1508)
                {
                    float3  _S1514 = (&ray_2)->origin;
                    FKSurface _S1515 = surface_12;
                    float3  _S1516 = - _S1353.smooth_n;
                    bool _S1517 = is_inside_6 != refracted_4;
                    float3  _S1518 = _slang_select(_S1517, _S1516,_S1353.smooth_n);
                    float3  _S1519 = throughput_8 - (_S1514 + make_float3 (_S1515.geometry_offset) * _S1518);
                    float3  _S1520 = ((((_S1519)) * make_float3(rnorm3df(((_S1519)).x, ((_S1519)).y, ((_S1519)).z))));
                    reconnection_1 = _S1520;
                }
                else
                {
                    reconnection_1 = _S1504;
                }
                if(_S1362)
                {
                    wrong_side_0 = false;
                }
                else
                {
                    bool _S1521 = wrongSide_0(is_inside_6, refracted_4, reconnection_1, surface_12.geometry_n);
                    wrong_side_0 = _S1521;
                }
                if(wrong_side_0)
                {
                    return _S1178;
                }
                float3  _S1522 = throughput_8;
                throughput_8 = reconnection_1;
                b_8 = _S1503;
                wrong_side_0 = false;
                reconnection_1 = _S1522;
            }
            else
            {
                bool _S1523 = !_S1394;
                if(_S1523)
                {
                    SampleBSDF bsdf_sampled_0;
                    SampleBSDF _S1524;
                    if(_S1362)
                    {
                        SampleBSDF _S1525 = (fcptSampleHair((surface_12.hair), (_S1352.material.albedo), (_S1352.material.specular_tint), ((&ray_2)->unit_direction), (surface_12.random_state)));
                        _S1524 = _S1525;
                    }
                    else
                    {
                        SampleBSDF _S1526 = sampleBSDF((&ray_2)->unit_direction, _S1353.smooth_n, _S1352.material, _S1355.x, _S1355.y, surface_12.random_state, _S1411);
                        _S1524 = _S1526;
                    }
                    bsdf_sampled_0 = _S1524;
                    if(_S1362)
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
                            return _S1178;
                        }
                        break;
                    }
                    if(_S1362)
                    {
                        wrong_side_0 = false;
                    }
                    else
                    {
                        bool _S1527 = wrongSide_0(is_inside_6, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, surface_12.geometry_n);
                        wrong_side_0 = _S1527;
                    }
                    if(wrong_side_0)
                    {
                        _S1440 = (_S1352.material.transmission) > 0.0f;
                    }
                    else
                    {
                        _S1440 = false;
                    }
                    if(_S1440)
                    {
                        SampleBSDF _S1528 = sampleBSDF((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n, _S1352.material, _S1355.x, _S1355.y, (&bsdf_sampled_0)->random_state, _S1411);
                        (&bsdf_sampled_0)->unit_direction = _S1528.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1528.refracted;
                        (&bsdf_sampled_0)->throughput = _S1528.throughput;
                        (&bsdf_sampled_0)->lobe = _S1528.lobe;
                    }
                    else
                    {
                        if(wrong_side_0)
                        {
                            float3  _S1529 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n)) * surface_12.geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1529;
                        }
                    }
                    uint _S1530 = (&bsdf_sampled_0)->lobe;
                    float3  _S1531 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1532 = (&bsdf_sampled_0)->refracted;
                    lobe_5 = bsdf_sampled_0;
                    float _S1533 = (&bsdf_sampled_0)->pdf;
                    float _S1534 = _slang_select(wrong_side_0, 0.0f,_S1533);
                    (&lobe_5)->pdf = _S1534;
                    throughput_8 = _S1531;
                    b_8 = _S1530;
                    refracted_4 = _S1532;
                }
                else
                {
                    throughput_8 = _S1504;
                    b_8 = _S1503;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(viewed_1)
            {
                _S1440 = true;
            }
            else
            {
                _S1440 = _S1394;
            }
            float3  chain_throughput_1;
            if(_S1440)
            {
                if(_S1362)
                {
                    SampleBSDF _S1535 = (fcptConnectHair((surface_12.hair), (_S1352.material.albedo), (_S1352.material.specular_tint), ((&ray_2)->unit_direction), (throughput_8)));
                    lobe_5 = _S1535;
                }
                else
                {
                    float3  _S1536 = (&ray_2)->unit_direction;
                    float _S1537 = sign_0(_S1354);
                    float3  _S1538 = _S1353.smooth_n * make_float3 (_S1537);
                    float _S1539 = dot_0(_S1538, throughput_8);
                    float _S1540 = _S1352.material.roughness;
                    float _S1541 = _S1540 * _S1540;
                    AnisotropicFrame _S1542 = anisotropicFrame(_S1352.material, _S1538);
                    float3  _S1543 = negate_0(_S1536);
                    SheenProfile _S1544 = sheenProfile(_S1543, _S1538, _S1352.material);
                    float3  _S1545 = reflectedHalf(_S1536, throughput_8);
                    bool _S1546 = b_8 == 1U;
                    if(_S1546)
                    {
                        float3  _S1547 = refractedHalf(_S1536, throughput_8, _S1353.smooth_n, _S1355.x, _S1355.y);
                        throughput_9 = _S1547;
                    }
                    else
                    {
                        throughput_9 = _S1545;
                    }
                    bool _S1548 = b_8 == 0U;
                    if(_S1548)
                    {
                        _S1441 = true;
                    }
                    else
                    {
                        _S1441 = b_8 == 6U;
                    }
                    if(_S1441)
                    {
                        float3  _S1549 = sampledHalf(_S1536, _S1353.smooth_n, _S1352.material, surface_12.random_state, _S1542);
                        throughput_10 = _S1549;
                    }
                    else
                    {
                        throughput_10 = throughput_9;
                    }
                    float3  _S1550 = negate_0(_S1536);
                    float _S1551 = _S1355.x;
                    float _S1552 = _S1355.y;
                    BSDFLobes _S1553 = bsdfLobes(_S1536, _S1550, _S1538, throughput_10, _S1352.material, _S1551, _S1552, _S1542, _S1544);
                    BSDFLobes lobe_terms_1 = _S1553;
                    float _S1554 = translucentShare(_S1352.material);
                    (&lobe_terms_1)->translucent_share = _S1554;
                    switch(b_8)
                    {
                    case 0U:
                        {
                            float _S1555 = diffusePDF(_S1539, 0.0f, (F32_abs((_S1354))), _S1541, lobe_terms_1, _S1551, _S1552);
                            float3  _S1556 = diffuseBSDF(throughput_8, _S1538, _S1541, _S1352.material, lobe_terms_1);
                            density_6 = _S1555;
                            chain_throughput_1 = _S1556;
                            break;
                        }
                    case 1U:
                        {
                            float _S1557 = refractPDF(_S1539, dot_0(throughput_8, throughput_10), (F32_abs((_S1354))), _S1541, lobe_terms_1, _S1551, _S1552);
                            float3  _S1558 = refractBSDF(throughput_8, _S1538, _S1541, _S1352.material, lobe_terms_1);
                            density_6 = _S1557;
                            chain_throughput_1 = _S1558;
                            break;
                        }
                    case 4U:
                        {
                            float _S1559 = sheenVelvetPDF(_S1539, 0.0f, (F32_abs((_S1354))), _S1541, lobe_terms_1, _S1551, _S1552);
                            float3  _S1560 = sheenVelvetBSDF(throughput_8, _S1538, _S1541, _S1352.material, lobe_terms_1);
                            density_6 = _S1559;
                            chain_throughput_1 = _S1560;
                            break;
                        }
                    case 6U:
                        {
                            float _S1561 = toonPDF(_S1539, dot_0(throughput_8, (&lobe_terms_1)->toon_axis), (F32_abs((_S1354))), _S1541, lobe_terms_1, _S1551, _S1552);
                            float3  _S1562 = toonBSDF(throughput_8, _S1538, _S1541, _S1352.material, lobe_terms_1);
                            density_6 = _S1561;
                            chain_throughput_1 = _S1562;
                            break;
                        }
                    default:
                        {
                            float _S1563 = reflectPDF(_S1539, 0.0f, (F32_abs((_S1354))), _S1541, lobe_terms_1, _S1551, _S1552);
                            float3  _S1564 = reflectBSDF(throughput_8, _S1538, _S1541, _S1352.material, lobe_terms_1);
                            density_6 = _S1563;
                            chain_throughput_1 = _S1564;
                            break;
                        }
                    }
                    bool _S1565 = density_6 > 0.0f;
                    if(_S1565)
                    {
                        SampleBSDF _S1566 = SampleBSDF_x24init_0(throughput_8, chain_throughput_1, surface_12.random_state, _S1546, b_8, density_6);
                        lobe_5 = _S1566;
                    }
                }
            }
            bool _S1567 = b_8 == 0U;
            if(_S1567)
            {
                _S1441 = true;
            }
            else
            {
                _S1441 = b_8 == 4U;
            }
            if(_S1441)
            {
                _S1485 = true;
            }
            else
            {
                _S1485 = b_8 == 6U;
            }
            if(_S1362)
            {
                _S1486 = false;
            }
            else
            {
                bool _S1568 = !_S1485;
                if(_S1568)
                {
                    bool _S1569 = (_S1352.material.roughness) == 0.0f;
                    if(_S1569)
                    {
                        _S1486 = true;
                    }
                    else
                    {
                        bool _S1570 = b_8 == 1U;
                        if(_S1570)
                        {
                            _S1486 = (_S1355.x) == (_S1355.y);
                        }
                        else
                        {
                            _S1486 = false;
                        }
                    }
                }
                else
                {
                    _S1486 = false;
                }
            }
            bool _S1571 = !_S1362;
            if(_S1571)
            {
                _S1487 = b_8 == 1U;
            }
            else
            {
                _S1487 = false;
            }
            if(_S1487)
            {
                straight_0 = (_S1352.material.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S1488 = _S1571;
            }
            else
            {
                _S1488 = false;
            }
            if(_S1488)
            {
                _S1489 = b_8 == 1U;
            }
            else
            {
                _S1489 = false;
            }
            if(_S1489)
            {
                _S1490 = (_S1355.x) == (_S1355.y);
            }
            else
            {
                _S1490 = false;
            }
            BSDFMaterial _S1572 = _S1352.material;
            bool _S1573 = isTranslucent_0(&_S1572);
            if(_S1573)
            {
                _S1491 = _S1567;
            }
            else
            {
                _S1491 = false;
            }
            if(_S1491)
            {
                _S1492 = (dot_0(throughput_8, surface_12.geometry_n)) < 0.0f;
            }
            else
            {
                _S1492 = false;
            }
            if(nee_0)
            {
                _S1493 = !_S1486;
            }
            else
            {
                _S1493 = false;
            }
            if(_S1493)
            {
                _S1494 = !wrong_side_0;
            }
            else
            {
                _S1494 = false;
            }
            if(_S1494)
            {
                float _S1574 = (&lobe_5)->pdf;
                float3  _S1575 = (&ray_2)->origin;
                float3  _S1576 = _slang_select(_S1367, _S1177,_S1353.smooth_n);
                float3  _S1577 = (&ray_2)->origin;
                FKSurface _S1578 = surface_12;
                float3  _S1579 = - _S1353.smooth_n;
                float3  _S1580 = _slang_select(_S1492, _S1579,_S1353.smooth_n);
                NEEVertex _S1581 = NEEVertex_x24init_0(false, _S1574, _S1575, _S1576, _S1577 + make_float3 (_S1578.geometry_offset) * _S1580);
                nee_vertex_0 = _S1581;
            }
            else
            {
                if(_S1362)
                {
                    _S1495 = true;
                }
                else
                {
                    bool _S1582 = b_8 != 1U;
                    if(_S1582)
                    {
                        _S1495 = true;
                    }
                    else
                    {
                        _S1495 = (_S1355.x) != (_S1355.y);
                    }
                }
                if(_S1495)
                {
                    (&nee_vertex_0)->none = true;
                }
            }
            bool _S1583 = ((&lobe_5)->pdf) > 0.0f;
            if(_S1583)
            {
                if(_S1485)
                {
                    _S1495 = true;
                }
                else
                {
                    _S1495 = ((&lobe_5)->pdf * (&prev_0)->cos / ((&hit_4)->distance * (&hit_4)->distance) * threshold_0) <= 1.0f;
                }
            }
            else
            {
                _S1495 = false;
            }
            bool _S1584 = ((&lobe_5)->pdf) > 0.0f;
            if(_S1584)
            {
                if(_S1485)
                {
                    _S1496 = true;
                }
                else
                {
                    _S1496 = (_S1352.material.roughness) >= 0.20000000298023224f;
                }
            }
            else
            {
                _S1496 = false;
            }
            if(_S1394)
            {
                bool _S1585 = !_S1495;
                if(_S1585)
                {
                    return _S1178;
                }
                bool _S1586 = _S1183 != 1U;
                if(_S1586)
                {
                    _S1497 = _S1183 != 2U;
                }
                else
                {
                    _S1497 = false;
                }
                if(_S1497)
                {
                    float _S1587 = (&lobe_5)->pdf;
                    float _S1588 = _slang_select(nee_0, _S1587,0.0f);
                    float _S1589 = escapeWeight_0(_S1588, _S1504);
                    if(_S1402)
                    {
                        passes_0 = _S1189;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1590 = _slang_select(passes_0, _S1589,1.0f);
                    return Shift_x24init_0(throughput_6 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf)) * r_8->radiance * make_float3 (_S1590) / make_float3 (r_8->jac), density_4 * (&lobe_5)->pdf / r_8->jac);
                }
                float3  _S1591 = throughput_6 * make_float3 ((&lobe_5)->pdf);
                float _S1592 = density_4 * (&lobe_5)->pdf;
                throughput_9 = _S1591;
                density_6 = _S1592;
            }
            else
            {
                throughput_9 = throughput_6;
                density_6 = density_4;
            }
            uint _S1593 = (fcptLayers((hit_4)));
            bool _S1594 = _S1593 > 1U;
            if(_S1594)
            {
                _S1497 = (b_8 == 1U) != passes_0;
            }
            else
            {
                _S1497 = false;
            }
            if(viewed_1)
            {
                _S1498 = _S1497;
            }
            else
            {
                _S1498 = false;
            }
            if(_S1498)
            {
                return _S1178;
            }
            if(replay_1)
            {
                _S1499 = b_5 <= _S1193;
            }
            else
            {
                _S1499 = false;
            }
            if(_S1499)
            {
                _S1500 = _S1351;
            }
            else
            {
                _S1500 = false;
            }
            bool _S1595;
            if(_S1500)
            {
                _S1595 = _S1495;
            }
            else
            {
                _S1595 = false;
            }
            bool _S1596;
            if(_S1595)
            {
                _S1596 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S1596 = !_S1496;
                }
                else
                {
                    _S1596 = false;
                }
            }
            if(_S1596)
            {
                return _S1178;
            }
            if(viewed_1)
            {
                float3  _S1597 = throughput_9 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf));
                float _S1598 = (&lobe_5)->pdf;
                throughput_10 = _S1597;
                sky_pdf_2 = _S1598;
            }
            else
            {
                float3  _S1599 = throughput_9 * max_0((&lobe_5)->throughput, _S1177);
                throughput_10 = _S1599;
                sky_pdf_2 = density_6;
            }
            bool _S1600;
            if(_S1371)
            {
                _S1600 = !_S1385;
            }
            else
            {
                _S1600 = false;
            }
            bool _S1601;
            if(_S1600)
            {
                _S1601 = _S1351;
            }
            else
            {
                _S1601 = false;
            }
            bool _S1602;
            if(_S1601)
            {
                _S1602 = _S1495;
            }
            else
            {
                _S1602 = false;
            }
            if(_S1602)
            {
                chain_0 = here_0;
                uint _S1603 = insertBits_0((&chain_0)->path, b_8, 18U, 3U);
                uint _S1604 = _slang_select(nee_0, 1U,0U);
                uint _S1605 = insertBits_0(_S1603, _S1604, 21U, 1U);
                (&chain_0)->path = _S1605;
                float _S1606 = (&chain_0)->jac * (&lobe_5)->pdf;
                (&chain_0)->jac = _S1606;
                (&chain_0)->dir = throughput_8;
                chain_throughput_1 = throughput_10;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            FKSurface _S1607 = surface_12;
            Vertex _S1608 = Vertex_x24init_0(_S1496, b_8, (&lobe_5)->pdf, (F32_abs((dot_0(surface_12.geometry_n, throughput_8)))), is_inside_6);
            prev_0 = _S1608;
            float _S1609 = (&lobe_5)->pdf;
            bool _S1610 = b_8 == 1U;
            bool _S1611;
            if(_S1610)
            {
                _S1611 = (_S1355.x) == (_S1355.y);
            }
            else
            {
                _S1611 = false;
            }
            float sky_pdf_3 = _slang_select(_S1611, sky_pdf_0,_S1609);
            float _S1612 = _slang_select(_S1362, 0.0f,sky_pdf_3);
            float _S1613 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * (&lobe_5)->pdf))))), (3.14159274101257324f)));
            bool _S1614 = !_S1486;
            float _S1615 = _slang_select(_S1614, _S1613,0.0f);
            float _S1616 = spread_1 + _S1615;
            bool _S1617;
            if(refracted_4)
            {
                _S1617 = !_S1492;
            }
            else
            {
                _S1617 = false;
            }
            bool is_inside_7;
            if(_S1617)
            {
                bool _S1618 = !is_inside_6;
                is_inside_7 = _S1618;
            }
            else
            {
                is_inside_7 = is_inside_6;
            }
            FKSurface _S1619 = surface_12;
            bool _S1620 = boundsVolume_0(&_S1619);
            bool _S1621;
            if(_S1620)
            {
                _S1621 = !_S1497;
            }
            else
            {
                _S1621 = false;
            }
            if(_S1621)
            {
                FKSurface faced_2 = surface_12;
                float3  _S1622 = - _S1607.geometry_n;
                float3  _S1623 = _slang_select(turned_1, _S1622,_S1607.geometry_n);
                (&faced_2)->geometry_n = _S1623;
                FKMedium _S1624 = Medium_x24init_0(scatter_in_0, extinction_in_0, g_in_0);
                FKMedium _S1625 = (fcptOutsideMedium((hit_4)));
                FKSurface _S1626 = faced_2;
                FKMedium _S1627 = _S1624;
                FKMedium _S1628 = _S1625;
                MediumSides _S1629 = mediumSides_0(&_S1626, &_S1627, filling_2, (&ray_2)->unit_direction, &_S1628);
                bool _S1630 = ((dot_0(throughput_8, _S1607.geometry_n)) > 0.0f) == ((dot_0(_S1607.geometry_n, (&faced_2)->geometry_n)) > 0.0f);
                float3  _S1631 = _slang_select(_S1630, _S1629.front.scatter,_S1629.behind.scatter);
                scatter_in_0 = _S1631;
                float3  _S1632 = _slang_select(_S1630, _S1629.front.extinction,_S1629.behind.extinction);
                extinction_in_0 = _S1632;
                float _S1633 = _slang_select(_S1630, _S1629.front.g,_S1629.behind.g);
                g_in_0 = _S1633;
                uint _S1634 = _S1629.fillings.x;
                uint _S1635 = _S1629.fillings.y;
                uint _S1636 = _slang_select(_S1630, _S1635,_S1634);
                bool _S1637 = (fcptVaryingUsed());
                uint _S1638 = _slang_select(_S1637, _S1636,4294967295U);
                filling_2 = _S1638;
            }
            (&ray_2)->unit_direction = throughput_8;
            bool _S1639 = !_S1497;
            if(_S1639)
            {
                FKSurface _S1640 = surface_12;
                float _S1641 = _slang_select(straight_0, 0.0f,_S1640.geometry_offset);
                float3  _S1642 = - _S1353.smooth_n;
                bool _S1643 = is_inside_7 != _S1492;
                float3  _S1644 = _slang_select(_S1643, _S1642,_S1353.smooth_n);
                float3  _S1645 = (&ray_2)->origin + make_float3 (_S1641) * _S1644;
                (&ray_2)->origin = _S1645;
            }
            throughput_9 = throughput_10;
            chain_throughput_0 = chain_throughput_1;
            density_6 = sky_pdf_2;
            passes_0 = _S1497;
            viewed_1 = _S1490;
            sky_pdf_2 = _S1612;
            spread_4 = _S1616;
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
        if(_S1371)
        {
            if(_S1319)
            {
                float3  _S1646 = throughput_9 * emission_1;
                Reservoir candidate_8 = chain_0;
                uint _S1647 = extractBits_0((&chain_0)->path, 10U, 2U);
                bool _S1648 = _S1647 == 1U;
                if(_S1648)
                {
                    float3  _S1649 = safeDivide(_S1646, chain_throughput_0);
                    (&candidate_8)->radiance = _S1649;
                }
                Reservoir _S1650 = withEnd(candidate_8, 2U, b_5, _S1646);
                offer(sel_7, _S1650, _S1646 * make_float3 (scale_3) / make_float3 (density_6));
            }
            if(_S1319)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = scatter_2;
            }
            if(refracted_4)
            {
                float _S1651 = survivalProbability(throughput_9, density_6);
                density_7 = _S1651;
            }
            else
            {
                density_7 = 1.0f;
            }
            uint _S1652 = stream(_S1205, b_5 + 128U);
            Random _S1653 = pcg(_S1652);
            bool _S1654 = density_7 < (_S1653.value);
            if(_S1654)
            {
                wrong_side_0 = true;
            }
            else
            {
                uint _S1655 = (fcptMaxBounces());
                wrong_side_0 = b_5 >= _S1655;
            }
            if(wrong_side_0)
            {
                break;
            }
            float _S1656 = density_6 * density_7;
            density_7 = _S1656;
        }
        else
        {
            density_7 = density_6;
        }
        uint _S1657 = layer_0 ^ 1U;
        uint _S1658 = _slang_select(passes_0, _S1657,0U);
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
            uint _S1659 = b_8 + 1U;
            b_5 = _S1659;
            layer_0 = _S1658;
            continue;
        }
        FKRay _S1660 = ray_2;
        float _S1661 = distance_1(reconnection_0, (&ray_2)->origin) * 1.0010000467300415f;
        if(replay_1)
        {
            refracted_4 = _S1395;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            wrong_side_0 = _S1182 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S1662 = _slang_select(wrong_side_0, _S1661,4.294967296e+09f);
        bool _S1663 = !_S1362;
        if(straight_0)
        {
            _S1440 = true;
        }
        else
        {
            _S1440 = _S1362;
        }
        FKHit _S1664;
        if(_S1440)
        {
            _S1664 = hit_4;
        }
        else
        {
            _S1664 = _S1412;
        }
        FKHit _S1665 = (fcptTraverseInstanceBVH((_S1660), (_S1326), (_S1662), (_S1663), (_S1664), (viewed_1)));
        hit_4 = _S1665;
        if(replay_1)
        {
            _S1441 = _S1395;
        }
        else
        {
            _S1441 = false;
        }
        if(_S1441)
        {
            _S1485 = _S1182 == 1U;
        }
        else
        {
            _S1485 = false;
        }
        if(_S1485)
        {
            _S1486 = ((&hit_4)->instance_index) == (_S1194.instance_index);
        }
        else
        {
            _S1486 = false;
        }
        if(_S1486)
        {
            _S1487 = ((&hit_4)->triangle_index) == (_S1194.triangle_index);
        }
        else
        {
            _S1487 = false;
        }
        if(_S1487)
        {
            (&hit_4)->uv = _S1194.uv;
            float _S1666 = distance_1(reconnection_0, (&ray_2)->origin);
            (&hit_4)->distance = _S1666;
        }
        if(replay_1)
        {
            _S1488 = _S1395;
        }
        else
        {
            _S1488 = false;
        }
        if(_S1488)
        {
            _S1489 = _S1182 == 3U;
        }
        else
        {
            _S1489 = false;
        }
        if(_S1489)
        {
            _S1490 = ((&hit_4)->instance_index) != 4294967295U;
        }
        else
        {
            _S1490 = false;
        }
        if(_S1490)
        {
            return _S1178;
        }
        Reservoir _S1667 = chain_0;
        uint _S1668 = filling_2;
        for(;;)
        {
            bool _S1669 = (fcptVaryingUsed());
            if(_S1669)
            {
                _S1491 = _S1668 != 4294967295U;
            }
            else
            {
                _S1491 = false;
            }
            float _S1670;
            if(_S1491)
            {
                float _S1671 = (fcptMajorant((_S1668)));
                _S1670 = _S1671;
            }
            else
            {
                _S1670 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
            }
            if(replay_1)
            {
                _S1492 = _S1395;
            }
            else
            {
                _S1492 = false;
            }
            if(_S1492)
            {
                _S1493 = _S1182 == 1U;
            }
            else
            {
                _S1493 = false;
            }
            if(_S1493)
            {
                _S1494 = _S1670 > 0.0f;
            }
            else
            {
                _S1494 = false;
            }
            if(_S1494)
            {
                ended_0 = _S1178;
                sky_pdf_1 = sky_pdf_2;
                spread_2 = spread_4;
                width_4 = width_3;
                density_3 = density_7;
                throughput_10 = throughput_9;
                b_8 = b_5;
                _S1495 = true;
                break;
            }
            bool _S1672 = (&prev_0)->rough;
            if(_S1672)
            {
                _S1495 = !(_S1670 > 0.0f);
            }
            else
            {
                _S1495 = false;
            }
            (&prev_0)->rough = _S1495;
            uint _S1673 = b_5 + 320U;
            bool _S1674 = b_5 == 4294967295U;
            uint _S1675 = _slang_select(_S1674, 384U,_S1673);
            uint _S1676 = stream(_S1205, _S1675);
            uint tracking_1 = _S1676;
            weight_1 = throughput_3;
            glowed_0 = _S1177;
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
                    _S1176 = int(2);
                    break;
                }
                uint _S1677 = b_8 + 320U;
                bool _S1678 = b_8 == 4294967295U;
                uint _S1679 = _slang_select(_S1678, 384U,_S1677);
                uint _S1680 = stream(_S1205, _S1679);
                Random _S1681 = pcg(_S1680);
                float _S1682 = - (F32_log((1.0f - _S1681.value))) / _S1670;
                if(_S1491)
                {
                    float3  _S1683 = (&ray_2)->origin;
                    float3  _S1684 = (&ray_2)->unit_direction;
                    float _S1685 = (&hit_4)->distance;
                    uint _S1686 = _slang_select(_S1678, 0U,b_8);
                    uint _S1687 = (&prev_0)->lobe;
                    uint _S1688 = _slang_select(_S1678, 3U,_S1687);
                    float _S1689 = (fcptTrackMedium((_S1668), (_S1683), (_S1684), (_S1685), (&tracking_1), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1686), (_S1688), (_S1678)));
                    spread_3 = _S1689;
                }
                else
                {
                    spread_3 = _S1682;
                }
                bool _S1690 = !(spread_3 < ((&hit_4)->distance));
                if(_S1690)
                {
                    _S1176 = int(2);
                    break;
                }
                if(_S1491)
                {
                    _S1496 = _S1371;
                }
                else
                {
                    _S1496 = false;
                }
                if(_S1496)
                {
                    float3  _S1691 = throughput_10 * glowed_0 / make_float3 (density_3);
                    float3  _S1692 = sel_7->glow + _S1691;
                    sel_7->glow = _S1692;
                }
                else
                {
                }
                glowed_0 = _S1177;
                uint b_9 = b_8 + 1U;
                float3  _S1693 = (&ray_2)->origin + make_float3 (spread_3) * (&ray_2)->unit_direction;
                (&ray_2)->origin = _S1693;
                float3  _S1694 = flightWeight_0(scatter_in_0, extinction_in_0, _S1670, spread_3, true);
                float3  _S1695 = weight_1;
                float3  _S1696 = _slang_select(_S1491, _S1695,_S1694);
                float3  throughput_11 = throughput_10 * _S1696;
                uint _S1697 = stream(_S1205, b_9 + 320U);
                tracking_1 = _S1697;
                weight_1 = throughput_3;
                float width_7 = width_4 + spread_2 * spread_3;
                float _S1698 = spread_2 + 3.14159274101257324f;
                if(_S1371)
                {
                    _S1497 = true;
                }
                else
                {
                    bool _S1699 = b_9 == _S1193;
                    if(_S1699)
                    {
                        _S1497 = !_S1491;
                    }
                    else
                    {
                        _S1497 = false;
                    }
                }
                TreeSample light_4;
                if(_S1497)
                {
                    float3  _S1700 = (&ray_2)->origin;
                    float3  _S1701 = (&ray_2)->unit_direction;
                    float3  _S1702 = (&ray_2)->unit_direction;
                    uint _S1703 = stream(_S1205, b_9 + 64U);
                    float3  _S1704 = extinction_in_0;
                    float3  _S1705 = extinction_in_0;
                    uint2  _S1706 = make_uint2 (_S1668);
                    float3  _S1707 = (&ray_2)->unit_direction;
                    uint _S1708 = arrivalLobe_0(b_9, (&prev_0)->lobe);
                    FKHit _S1709 = _S1412;
                    ShadowContext _S1710 = ShadowContext_x24init_0(_S1704, _S1705, _S1706, _S1707, b_9, _S1708, false, spread_3, width_7, &_S1709, false);
                    ShadowContext _S1711 = _S1710;
                    TreeSample _S1712 = sampleLightTree_0(_S1700, _S1701, _S1702, 0.0f, true, _S1703, &_S1711);
                    light_4 = _S1712;
                }
                else
                {
                    light_4 = _S1409;
                }
                float _S1713 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_4.dir));
                uint _S1714 = (fcptMaxBounces());
                bool _S1715 = b_9 < _S1714;
                if(_S1715)
                {
                    _S1498 = (light_4.density) > 0.0f;
                }
                else
                {
                    _S1498 = false;
                }
                float _S1716 = _slang_select(_S1498, _S1713,0.0f);
                float3  _S1717 = throughput_11 * light_4.radiance;
                float _S1718 = powerHeuristic(light_4.density, _S1716);
                float3  _S1719 = _S1717 * make_float3 (_S1713 * _S1718);
                float3  _S1720 = _slang_select(_S1497, _S1719,_S1177);
                if(replay_1)
                {
                    _S1499 = b_9 == _S1193;
                }
                else
                {
                    _S1499 = false;
                }
                if(_S1499)
                {
                    bool _S1721 = _S1182 == 2U;
                    if(_S1721)
                    {
                        float _S1722 = rgb_to_greyscale(_S1720);
                        _S1500 = _S1722 > 0.0f;
                    }
                    else
                    {
                        _S1500 = false;
                    }
                    if(_S1500)
                    {
                        Shift _S1723 = Shift_x24init_0(_S1720, 1.0f);
                        _S1176 = int(1);
                        ended_0 = _S1723;
                        spread_3 = _S1698;
                        width_5 = width_7;
                        throughput_8 = throughput_11;
                        b_6 = b_9;
                        break;
                    }
                    _S1176 = int(1);
                    ended_0 = _S1178;
                    spread_3 = _S1698;
                    width_5 = width_7;
                    throughput_8 = throughput_11;
                    b_6 = b_9;
                    break;
                }
                if(_S1371)
                {
                    Reservoir candidate_9 = _S1667;
                    uint _S1724 = extractBits_0(_S1667.path, 10U, 2U);
                    bool _S1725 = _S1724 == 1U;
                    if(_S1725)
                    {
                        float3  _S1726 = safeDivide(_S1720, chain_throughput_0);
                        (&candidate_9)->radiance = _S1726;
                    }
                    else
                    {
                        uint _S1727 = insertBits_0(0U, b_9 + 1U, 5U, 5U);
                        uint _S1728 = insertBits_0(_S1727, 2U, 10U, 2U);
                        (&candidate_9)->path = _S1728;
                    }
                    Reservoir _S1729 = withEnd(candidate_9, 0U, b_9, _S1720);
                    offer(sel_7, _S1729, _S1720 * make_float3 (scale_3) / make_float3 (density_3));
                    float _S1730 = survivalProbability(throughput_11, density_3);
                    uint _S1731 = stream(_S1205, b_9 + 128U);
                    Random _S1732 = pcg(_S1731);
                    bool _S1733 = _S1730 < (_S1732.value);
                    if(_S1733)
                    {
                        _S1500 = true;
                    }
                    else
                    {
                        uint _S1734 = (fcptMaxBounces());
                        _S1500 = b_9 >= _S1734;
                    }
                    if(_S1500)
                    {
                        _S1176 = int(1);
                        ended_0 = _S1178;
                        spread_3 = _S1698;
                        width_5 = width_7;
                        throughput_8 = throughput_11;
                        b_6 = b_9;
                        break;
                    }
                    float _S1735 = density_3 * _S1730;
                    density_3 = _S1735;
                }
                else
                {
                }
                float phase_pdf_1 = 0.0f;
                uint _S1736 = stream(_S1205, b_9);
                float3  _S1737 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1736, &phase_pdf_1);
                (&ray_2)->unit_direction = _S1737;
                NEEVertex _S1738 = NEEVertex_x24init_0(false, phase_pdf_1, (&ray_2)->origin, _S1177, (&ray_2)->origin);
                nee_vertex_0 = _S1738;
                Vertex _S1739 = Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_5);
                prev_0 = _S1739;
                float _S1740 = (&prev_0)->pdf;
                FKRay _S1741 = ray_2;
                FKHit _S1742 = (fcptTraverseInstanceBVH((_S1741), (true), (4.294967296e+09f), (false), (_S1412), (false)));
                hit_4 = _S1742;
                b_8 = b_9;
                throughput_10 = throughput_11;
                spread_2 = _S1698;
                width_4 = width_7;
                sky_pdf_1 = _S1740;
            }
            if(_S1176 != int(2))
            {
                spread_2 = spread_3;
                width_4 = width_5;
                throughput_10 = throughput_8;
                b_8 = b_6;
                _S1495 = true;
                break;
            }
            ended_0 = _S1178;
            _S1495 = false;
            break;
        }
        if(_S1495)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S1496 = b_8 == b_5;
        }
        else
        {
            _S1496 = false;
        }
        bool _S1743 = ((&hit_4)->instance_index) == 4294967295U;
        if(_S1743)
        {
            bool _S1744 = !(&nee_vertex_0)->none;
            float _S1745 = _slang_select(_S1744, sky_pdf_1,0.0f);
            float _S1746 = escapeWeight_0(_S1745, (&ray_2)->unit_direction);
            float3  _S1747 = environment_0((&ray_2)->unit_direction, b_8, (&prev_0)->lobe);
            float3  _S1748 = throughput_10 * _S1747;
            if(replay_1)
            {
                bool _S1749 = b_8 == _S1193;
                if(_S1749)
                {
                    passes_0 = _S1182 == 3U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(_S1748 * make_float3 (_S1746) / make_float3 (r_8->jac), density_3 / r_8->jac);
                }
                if(_S1192)
                {
                    passes_0 = _S1189;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = b_8 == _S1180;
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
                    return Shift_x24init_0(_S1748 * make_float3 (_S1746), 1.0f);
                }
                return _S1178;
            }
            Reservoir candidate_10 = chain_0;
            uint _S1750 = extractBits_0((&chain_0)->path, 10U, 2U);
            bool _S1751 = _S1750 == 1U;
            if(_S1751)
            {
                uint _S1752 = extractBits_0((&chain_0)->path, 5U, 5U);
                bool _S1753 = _S1752 == b_8;
                float _S1754 = _slang_select(_S1753, 1.0f,_S1746);
                float3  _S1755 = safeDivide(_S1748 * make_float3 (_S1754), chain_throughput_0);
                (&candidate_10)->radiance = _S1755;
            }
            else
            {
                bool _S1756 = (&prev_0)->rough;
                if(_S1756)
                {
                    uint _S1757 = insertBits_0(0U, b_8 + 1U, 5U, 5U);
                    uint _S1758 = insertBits_0(_S1757, 3U, 10U, 2U);
                    uint _S1759 = insertBits_0(_S1758, (&prev_0)->lobe, 15U, 3U);
                    bool _S1760 = (&prev_0)->inside;
                    uint _S1761 = _slang_select(_S1760, 1U,0U);
                    uint _S1762 = insertBits_0(_S1759, _S1761, 22U, 1U);
                    (&candidate_10)->path = _S1762;
                    (&candidate_10)->jac = (&prev_0)->pdf;
                    (&candidate_10)->dir = (&ray_2)->unit_direction;
                }
            }
            float3  _S1763 = _S1748 * make_float3 (_S1746);
            Reservoir _S1764 = withEnd(candidate_10, 3U, b_8, _S1763);
            offer(sel_7, _S1764, _S1763 * make_float3 (scale_3) / make_float3 (density_3));
            break;
        }
        float3  _S1765 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
        (&ray_2)->origin = _S1765;
        bool _S1766 = (fcptVaryingUsed());
        if(_S1766)
        {
            _S1497 = filling_2 != 4294967295U;
        }
        else
        {
            _S1497 = false;
        }
        if(_S1497)
        {
            if(_S1371)
            {
                float3  _S1767 = throughput_10 * glowed_0 / make_float3 (density_3);
                float3  _S1768 = sel_7->glow + _S1767;
                sel_7->glow = _S1768;
            }
            float3  _S1769 = throughput_10 * weight_1;
            throughput_8 = _S1769;
        }
        else
        {
            float3  _S1770 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
            float3  _S1771 = throughput_10 * _S1770;
            throughput_8 = _S1771;
        }
        float _S1772 = width_4 + spread_2 * (&hit_4)->distance;
        viewed_0 = _S1496;
        width_3 = _S1772;
        throughput_2 = throughput_8;
        density_2 = density_3;
        sky_pdf_0 = sky_pdf_1;
        spread_1 = spread_2;
        uint _S1659 = b_8 + 1U;
        b_5 = _S1659;
        layer_0 = _S1658;
    }
    return _S1178;
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
    Random _S1773 = pcg(state_3);
    Random _S1774 = pcg(_S1773.state);
    float _S1775 = 6.28318548202514648f * _S1773.value;
    float _S1776 = (F32_sqrt((-2.0f * clamp_1((F32_log((_S1774.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S1774.state, _S1776 * (F32_cos((_S1775))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_4, float3  value_2)
{
    RandomSphere _S1777;
    (&_S1777)->state = state_4;
    (&_S1777)->value = value_2;
    return _S1777;
}

__device__ RandomSphere random_sphere(uint state_5)
{
    Random _S1778 = normal_distribution(state_5);
    Random _S1779 = normal_distribution(_S1778.state);
    Random _S1780 = normal_distribution(_S1779.state);
    float3  _S1781 = make_float3 (_S1778.value, _S1779.value, _S1780.value);
    float3  _S1782 = ((((_S1781)) * make_float3(rnorm3df(((_S1781)).x, ((_S1781)).y, ((_S1781)).z))));
    return RandomSphere_x24init_0(_S1780.state, _S1782);
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_12)
{
    float3  _S1783 = p1_0 - p0_0;
    float3  _S1784 = p2_0 - p0_0;
    float2  _S1785 = uv1_0 - uv0_0;
    float2  _S1786 = uv2_0 - uv0_0;
    float _S1787 = _S1785.x;
    float _S1788 = _S1786.y;
    float _S1789 = _S1785.y;
    float _S1790 = _S1786.x;
    float _S1791 = _S1787 * _S1788 - _S1789 * _S1790;
    float _S1792 = 1.0f / _S1791;
    float3  t_21 = (_S1783 * make_float3 (_S1788) - _S1784 * make_float3 (_S1789)) * make_float3 (_S1792);
    float3  _S1793 = (_S1784 * make_float3 (_S1787) - _S1783 * make_float3 (_S1790)) * make_float3 (_S1792);
    float3  _S1794 = t_21 - n_12 * make_float3 (dot_0(n_12, t_21));
    float3  _S1795 = tangentToWorld(make_float3 (1.0f, 0.0f, 0.0f), n_12);
    bool _S1796 = (dot_0(_S1794, _S1794)) > 0.0f;
    float3  _S1797 = _slang_select(_S1796, _S1794,_S1795);
    float3  _S1798 = ((((_S1797)) * make_float3(rnorm3df(((_S1797)).x, ((_S1797)).y, ((_S1797)).z))));
    bool _S1799 = (dot_0(cross_0(n_12, _S1798), _S1793)) > 0.0f;
    float3  t_22;
    if(_S1799)
    {
        float3  _S1800 = negate_0(_S1798);
        t_22 = _S1800;
    }
    else
    {
        t_22 = _S1798;
    }
    float3  _S1801 = cross_0(n_12, t_22);
    return makeMatrix<float, 3, 3> (t_22, _S1801, n_12);
}

__device__ float3  tangentToWorldNormalMap(float3  v_5, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_5, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_4, float3  uvw_0, float3  position_0)
{
    float3  _S1802 = t1_0 - t0_0;
    float3  _S1803 = t2_2 - t0_0;
    float3  _S1804 = t2_2 - t1_0;
    float _S1805 = (F32_min((length_0(_S1802)), ((F32_min((length_0(_S1803)), (length_0(_S1804)))))));
    float3  _S1806 = make_float3 (distance_1(position_0, t0_0), distance_1(position_0, t1_0), distance_1(position_0, t2_2));
    float3  _S1807 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S1808 = dot_0(geometry_n_4, _S1807);
    float3  _S1809 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S1810 = dot_0(geometry_n_4, _S1809);
    float3  _S1811 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S1812 = acos_0(abs_0(make_float3 (_S1808, _S1810, dot_0(geometry_n_4, _S1811))));
    float3  _S1813 = clamp_2(tan_0(_S1812), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_1(dot_0(_S1806 * _S1813, uvw_0), 0.0f, _S1805 * 0.125f);
}

__device__ float3  straightThrough(BSDFMaterial material_23)
{
    return make_float3 (material_23.transmission * (1.0f - material_23.metallic)) * material_23.albedo;
}

__device__ float hairRow(float3  in_dir_11, float3  t_23, float3  out_dir_3, uint p_13, float w_2, float alpha_20, uint nt_0)
{
    uint _S1814 = p_13 % 4U;
    float _S1815 = w_2 * HAIR_WIDTHS_0[_S1814];
    float _S1816 = (F32_asin((clamp_1(dot_0(out_dir_3, t_23), -1.0f, 1.0f)))) - (F32_asin((clamp_1(dot_0(in_dir_11, t_23), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S1814] * alpha_20;
    return ((F32_asinh((_S1816 / _S1815))) / (F32_asinh((3.14159274101257324f / _S1815))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_12, float3  t_24, float3  out_dir_4, uint np_0)
{
    float3  _S1817 = worldToTangent(out_dir_4, t_24);
    float3  _S1818 = worldToTangent(in_dir_12, t_24);
    return (F32_frac((((F32_atan2((_S1817.z), (_S1817.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S1818.z), (1.17549435082228751e-38f - _S1818.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_13, float3  t_25, uint p_14, float row_0, float column_0, float w_3, float alpha_21, uint nt_1, uint np_1)
{
    float3  _S1819 = worldToTangent(in_dir_13, t_25);
    uint _S1820 = p_14 % 4U;
    float _S1821 = w_3 * HAIR_WIDTHS_0[_S1820];
    float _S1822 = (F32_asin((clamp_1(dot_0(in_dir_13, t_25), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S1820] * alpha_21 + _S1821 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S1821))))));
    float _S1823 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S1819.z), (1.17549435082228751e-38f - _S1819.x)));
    float _S1824 = (F32_cos((_S1822)));
    float3  _S1825 = tangentToWorld(make_float3 (_S1824 * (F32_cos((_S1823))), (F32_sin((_S1822))), _S1824 * (F32_sin((_S1823)))), t_25);
    return _S1825;
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_13, BSDFMaterial material_24, float coverage_1)
{
    float3  _S1826;
    if((material_24.ior) == 1.0f)
    {
        float3  _S1827 = straightThrough(material_24);
        _S1826 = _S1827;
    }
    else
    {
        _S1826 = make_float3 (0.0f);
    }
    return _S1826 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ Shift walk_hook(Domain dom_8, Reservoir r_9, bool replay_2, float scale_4, Selection * sel_8)
{
    Domain _S1828 = dom_8;
    Reservoir _S1829 = r_9;
    Shift _S1830 = walk_0(&_S1828, &_S1829, replay_2, scale_4, sel_8);
    return _S1830;
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
