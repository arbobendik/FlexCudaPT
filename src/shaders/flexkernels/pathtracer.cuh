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

__device__ float rgb_to_greyscale(float3  rgb_0)
{
    return dot_0(rgb_0, make_float3 (0.29899999499320984f, 0.58700001239776611f, 0.11400000005960464f));
}

static __device__ float3  negate_0(float3  x_13)
{
    return - x_13;
}

struct SampleBSDF
{
    float3  unit_direction;
    float3  throughput;
    uint random_state;
    bool refracted;
    uint lobe;
    float pdf;
};

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
    float3  _S324 = make_float3 (alpha_0 * Ve_0.x, alpha_0 * Ve_0.y, Ve_0.z);
    float3  _S325 = ((((_S324)) * make_float3(rnorm3df(((_S324)).x, ((_S324)).y, ((_S324)).z))));
    float _S326 = _S325.x;
    float _S327 = _S325.y;
    float _S328 = _S326 * _S326 + _S327 * _S327;
    float3  _S329;
    if(_S328 > 0.0f)
    {
        float3  _S330 = make_float3 (- _S327, _S326, 0.0f);
        float _S331 = (rsqrtf((_S328)));
        _S329 = _S330 * make_float3 (_S331);
    }
    else
    {
        _S329 = make_float3 (1.0f, 0.0f, 0.0f);
    }
    float3  _S332 = cross_0(_S325, _S329);
    float _S333 = (F32_sqrt((U1_0)));
    float _S334 = 6.28318548202514648f * U2_0;
    float _S335 = _S333 * (F32_cos((_S334)));
    float t2_0 = _S333 * (F32_sin((_S334)));
    float _S336 = 0.5f * (1.0f + _S325.z);
    float t2_1 = (1.0f - _S336) * (F32_sqrt(((F32_max((0.0f), (1.0f - _S335 * _S335)))))) + _S336 * t2_0;
    float3  _S337 = make_float3 (_S335) * _S329 + make_float3 (t2_1) * _S332;
    float _S338 = unshared_0(_S335);
    float _S339 = unshared_0(_S335);
    float3  _S340 = _S337 + make_float3 ((F32_sqrt(((F32_max((0.0f), (1.0f - _S338 * _S339 - t2_1 * t2_1))))))) * _S325;
    float3  _S341 = make_float3 (alpha_0 * _S340.x, alpha_0 * _S340.y, (F32_max((0.0f), (_S340.z))));
    float3  _S342 = ((((_S341)) * make_float3(rnorm3df(((_S341)).x, ((_S341)).y, ((_S341)).z))));
    return _S342;
}

__device__ float3  worldToTangent(float3  v_1, float3  n_3)
{
    float3  a_3 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S343 = (F32_abs((dot_0(n_3, a_3)))) > 0.9999847412109375f;
    float3  a_4;
    if(_S343)
    {
        float3  _S344 = make_float3 (1.0f, 0.0f, 0.0f);
        a_4 = _S344;
    }
    else
    {
        a_4 = a_3;
    }
    float3  _S345 = cross_0(n_3, a_4);
    float3  _S346 = ((((_S345)) * make_float3(rnorm3df(((_S345)).x, ((_S345)).y, ((_S345)).z))));
    float3  _S347 = cross_0(n_3, _S346);
    return make_float3 (dot_0(v_1, _S346), dot_0(v_1, n_3), dot_0(v_1, _S347));
}

__device__ __forceinline__ float3  sampleHalfVector(float3  v_2, float3  n_i_1, float alpha_1, AnisotropicFrame frame_0, uint * random_state_2)
{
    Random _S348 = pcg(*random_state_2);
    Random _S349 = pcg(_S348.state);
    *random_state_2 = _S349.state;
    float _S350 = frame_0.alphas.x;
    bool _S351 = _S350 > 0.0f;
    if(_S351)
    {
        float3  _S352 = anisotropicLocal(v_2, frame_0.tangent, n_i_1);
        float _S353 = frame_0.alphas.y;
        float3  _S354 = make_float3 (_S350 * _S352.x, _S353 * _S352.y, _S352.z);
        float3  _S355 = ((((_S354)) * make_float3(rnorm3df(((_S354)).x, ((_S354)).y, ((_S354)).z))));
        float3  _S356 = sampleGGXVNDF(_S355, 1.0f, _S348.value, _S349.value);
        float3  _S357 = make_float3 (_S350 * _S356.x, _S353 * _S356.y, _S356.z);
        float3  _S358 = ((((_S357)) * make_float3(rnorm3df(((_S357)).x, ((_S357)).y, ((_S357)).z))));
        return make_float3 (_S358.x) * frame_0.tangent + make_float3 (_S358.y) * cross_0(n_i_1, frame_0.tangent) + make_float3 (_S358.z) * n_i_1;
    }
    float3  _S359 = worldToTangent(v_2, n_i_1);
    float3  _S360 = sampleGGXVNDF(float3 {_S359.x, _S359.z, _S359.y}, alpha_1, _S348.value, _S349.value);
    float3  _S361 = float3 {_S360.x, _S360.z, _S360.y};
    float3  _S362 = tangentToWorld(_S361, n_i_1);
    return _S362;
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
    float3  view;
    float3  tangent;
    float2  alphas;
    float visible;
    float toon_share;
};

static __device__ float3  refract_0(float3  i_5, float3  n_4, float eta_0)
{
    float _S363 = dot_0(n_4, i_5);
    float _S364 = 1.0f - eta_0 * eta_0 * (1.0f - _S363 * _S363);
    if(_S364 < 0.0f)
    {
        return make_float3 (0.0f);
    }
    return make_float3 (eta_0) * i_5 - make_float3 (eta_0 * _S363 + (F32_sqrt((_S364)))) * n_4;
}

__device__ float fresnel(float cos_theta_0, float eta_i_0, float eta_o_0)
{
    float _S365 = (F32_sqrt(((F32_max((0.0f), (1.0f - cos_theta_0 * cos_theta_0))))));
    float _S366 = eta_i_0 / eta_o_0 * _S365;
    bool _S367 = _S366 < 1.0f;
    float kr_0;
    if(_S367)
    {
        float _S368 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S366 * _S366))))));
        float _S369 = eta_o_0 * cos_theta_0;
        float _S370 = eta_i_0 * _S368;
        float _S371 = (_S369 - _S370) / (_S369 + _S370);
        float _S372 = eta_i_0 * cos_theta_0;
        float _S373 = eta_o_0 * _S368;
        float _S374 = (_S372 - _S373) / (_S372 + _S373);
        float _S375 = (_S371 * _S371 + _S374 * _S374) / 2.0f;
        kr_0 = _S375;
    }
    else
    {
        kr_0 = 1.0f;
    }
    return kr_0;
}

__device__ static const FixedArray<float, 576>  VELVET_ALBEDO_0 = { {
    1.00383996963500977f, 1.00428998470306396f, 1.00356996059417725f, 1.00303995609283447f, 1.00261998176574707f, 1.00229001045227051f, 1.00198996067047119f, 1.00171005725860596f, 1.00144004821777344f, 1.00120997428894043f, 1.00102996826171875f, 1.00092005729675293f, 1.00088000297546387f, 1.0009000301361084f, 1.00095999240875244f, 1.00106000900268555f, 1.00115001201629639f, 1.00124001502990723f, 1.001289963722229f, 1.0013200044631958f, 1.00133001804351807f, 1.00133001804351807f, 1.0013200044631958f, 1.00129997730255127f, 0.99086397886276245f, 0.9934689998626709f, 0.99439799785614014f, 0.99513500928878784f, 0.99574202299118042f, 0.9962649941444397f, 0.99671798944473267f, 0.99709898233413696f, 0.997406005859375f, 0.99764800071716309f, 0.99783498048782349f, 0.99798601865768433f, 0.99811899662017822f, 0.99825501441955566f, 0.99840497970581055f, 0.99857097864151001f, 0.99874699115753174f, 0.99892902374267578f, 0.9990919828414917f, 0.99923902750015259f, 0.99936902523040771f, 0.99948000907897949f, 0.99957501888275146f, 0.99965798854827881f, 0.94088798761367798f, 0.95128101110458374f, 0.95866602659225464f, 0.96450901031494141f, 0.96921002864837646f, 0.973052978515625f, 0.97623497247695923f, 0.97890102863311768f, 0.98115700483322144f, 0.98308497667312622f, 0.98474901914596558f, 0.98619699478149414f, 0.98746699094772339f, 0.98858797550201416f, 0.98958402872085571f, 0.99047297239303589f, 0.99127000570297241f, 0.99198299646377563f, 0.99262100458145142f, 0.99318897724151611f, 0.99372398853302002f, 0.99426800012588501f, 0.99475300312042236f, 0.99514400959014893f, 0.86131101846694946f, 0.88463401794433594f, 0.90212702751159668f, 0.91595500707626343f, 0.92708200216293335f, 0.93617302179336548f, 0.94370102882385254f, 0.95000702142715454f, 0.95534700155258179f, 0.9599120020866394f, 0.96384698152542114f, 0.96726799011230469f, 0.97026199102401733f, 0.97289901971817017f, 0.97523599863052368f, 0.97731602191925049f, 0.97917401790618896f, 0.98083901405334473f, 0.98233497142791748f, 0.98368102312088013f, 0.98489302396774292f, 0.98598498106002808f, 0.98697298765182495f, 0.98787301778793335f, 0.75306302309036255f, 0.79328000545501709f, 0.82418698072433472f, 0.84881901741027832f, 0.86874997615814209f, 0.88506197929382324f, 0.89858502149581909f, 0.9099239706993103f, 0.91952997446060181f, 0.9277459979057312f, 0.93483197689056396f, 0.94099199771881104f, 0.9463840126991272f, 0.95113497972488403f, 0.95534402132034302f, 0.95908999443054199f, 0.9624369740486145f, 0.96543699502944946f, 0.96813201904296875f, 0.97055697441101074f, 0.97274202108383179f, 0.97471201419830322f, 0.97649002075195312f, 0.97809398174285889f, 0.62183499336242676f, 0.68052101135253906f, 0.72705197334289551f, 0.76452702283859253f, 0.79505598545074463f, 0.82021200656890869f, 0.84120297431945801f, 0.85885602235794067f, 0.87384098768234253f, 0.88667500019073486f, 0.89775800704956055f, 0.90739899873733521f, 0.91584599018096924f, 0.92329102754592896f, 0.929889976978302f, 0.93576502799987793f, 0.94101500511169434f, 0.94572198390960693f, 0.94994997978210449f, 0.95375597476959229f, 0.95718497037887573f, 0.9602770209312439f, 0.96306699514389038f, 0.96558600664138794f, 0.47742500901222229f, 0.5522189736366272f, 0.61415499448776245f, 0.66520899534225464f, 0.70744901895523071f, 0.74262100458145142f, 0.77213901281356812f, 0.7971159815788269f, 0.81841897964477539f, 0.83673000335693359f, 0.85258400440216064f, 0.86640900373458862f, 0.87854301929473877f, 0.88924998044967651f, 0.89874798059463501f, 0.90721100568771362f, 0.91477799415588379f, 0.92156499624252319f, 0.92766499519348145f, 0.93315702676773071f, 0.9381060004234314f, 0.94257098436355591f, 0.94660097360610962f, 0.95023900270462036f, 0.33539599180221558f, 0.41908100247383118f, 0.49247598648071289f, 0.55531197786331177f, 0.60879099369049072f, 0.65415602922439575f, 0.69274699687957764f, 0.72571200132369995f, 0.75402498245239258f, 0.77849102020263672f, 0.79976201057434082f, 0.81836599111557007f, 0.83474302291870117f, 0.84922301769256592f, 0.86208897829055786f, 0.87356698513031006f, 0.88384199142456055f, 0.89306402206420898f, 0.90135800838470459f, 0.9088289737701416f, 0.91556602716445923f, 0.92164498567581177f, 0.92713397741317749f, 0.93208998441696167f, 0.21194499731063843f, 0.29365798830986023f, 0.37110498547554016f, 0.44143900275230408f, 0.5036969780921936f, 0.55801302194595337f, 0.60521197319030762f, 0.64614301919937134f, 0.68169897794723511f, 0.71268302202224731f, 0.73979401588439941f, 0.76362699270248413f, 0.78467601537704468f, 0.80335497856140137f, 0.82000100612640381f, 0.83488202095031738f, 0.8482239842414856f, 0.86021500825881958f, 0.87101101875305176f, 0.88074499368667603f, 0.88952797651290894f, 0.89745801687240601f, 0.90461999177932739f, 0.91109001636505127f, 0.11949499696493149f, 0.18745699524879456f, 0.25997200608253479f, 0.33120998740196228f, 0.39773499965667725f, 0.45832300186157227f, 0.51248997449874878f, 0.56048798561096191f, 0.6028980016708374f, 0.64032697677612305f, 0.67339599132537842f, 0.70268499851226807f, 0.72870397567749023f, 0.75189602375030518f, 0.77263599634170532f, 0.7912449836730957f, 0.80796998739242554f, 0.82303100824356079f, 0.8366129994392395f, 0.84887397289276123f, 0.85994899272918701f, 0.86995697021484375f, 0.87900298833847046f, 0.88717901706695557f, 0.05942929908633232f, 0.10839699953794479f, 0.16785700619220734f, 0.23236599564552307f, 0.29767501354217529f, 0.36022999882698059f, 0.41842898726463318f, 0.47170799970626831f, 0.5198180079460144f, 0.56301301717758179f, 0.60171198844909668f, 0.63635998964309692f, 0.66739702224731445f, 0.69524997472763062f, 0.720287024974823f, 0.74283498525619507f, 0.76317602396011353f, 0.78155702352523804f, 0.79817098379135132f, 0.81319701671600342f, 0.8267899751663208f, 0.83908802270889282f, 0.85021400451660156f, 0.86027902364730835f, 0.02584660053253174f, 0.05619670078158379f, 0.09917669743299484f, 0.15162299573421478f, 0.20941600203514099f, 0.26902499794960022f, 0.32757499814033508f, 0.38318398594856262f, 0.43501600623130798f, 0.48271399736404419f, 0.52620798349380493f, 0.56570100784301758f, 0.60149699449539185f, 0.63392102718353271f, 0.66328197717666626f, 0.68988502025604248f, 0.7139970064163208f, 0.7358660101890564f, 0.75570398569107056f, 0.77369099855422974f, 0.78999698162078857f, 0.80477499961853027f, 0.81816202402114868f, 0.83028298616409302f, 0.00968609005212784f, 0.02591750025749207f, 0.05318830162286758f, 0.09121809899806976f, 0.13777700066566467f, 0.18976299464702606f, 0.244159996509552f, 0.29880800843238831f, 0.35169300436973572f, 0.40180501341819763f, 0.44872200489044189f, 0.49213200807571411f, 0.53206497430801392f, 0.5686650276184082f, 0.60214298963546753f, 0.63272500038146973f, 0.66062301397323608f, 0.68605399131774902f, 0.70922297239303589f, 0.73031198978424072f, 0.74948400259017944f, 0.76689702272415161f, 0.78270000219345093f, 0.79702901840209961f, 0.00303822988644242f, 0.01048239972442389f, 0.02568300068378448f, 0.05025380104780197f, 0.08408640325069427f, 0.12561400234699249f, 0.17249999940395355f, 0.22232000529766083f, 0.27309399843215942f, 0.32321798801422119f, 0.37149098515510559f, 0.4173240065574646f, 0.4603630006313324f, 0.50043797492980957f, 0.53755801916122437f, 0.57181298732757568f, 0.60333001613616943f, 0.63226902484893799f, 0.65877401828765869f, 0.68301999568939209f, 0.70514601469039917f, 0.7253040075302124f, 0.74363899230957031f, 0.76029098033905029f, 0.00076204299693927f, 0.00361976004205644f, 0.0110037000849843f, 0.02512970007956028f, 0.04727460071444511f, 0.07745999842882156f, 0.11460299789905548f, 0.1569570004940033f, 0.20258499681949615f, 0.24971699714660645f, 0.29707801342010498f, 0.34340900182723999f, 0.38799500465393066f, 0.43043500185012817f, 0.47039699554443359f, 0.50777101516723633f, 0.54253697395324707f, 0.57473397254943848f, 0.60444700717926025f, 0.63179397583007812f, 0.65686798095703125f, 0.67979699373245239f, 0.70071202516555786f, 0.71974599361419678f, 0.00014345299859997f, 0.00102306995540857f, 0.00407376000657678f, 0.01122699957340956f, 0.02423799969255924f, 0.04415180161595345f, 0.07109060138463974f, 0.10433399677276611f, 0.14259399473667145f, 0.184347003698349f, 0.2281080037355423f, 0.27265200018882751f, 0.31696400046348572f, 0.36016398668289185f, 0.40178799629211426f, 0.44139501452445984f, 0.47875601053237915f, 0.51375597715377808f, 0.54635101556777954f, 0.57658302783966064f, 0.60447400808334351f, 0.63009101152420044f, 0.65352898836135864f, 0.67488902807235718f, 0.00001858420000644f, 0.0002227969962405f, 0.00124967005103827f, 0.00435766018927097f, 0.01113030035048723f, 0.0229835007339716f, 0.04079980030655861f, 0.06477940082550049f, 0.09447769820690155f, 0.12897300720214844f, 0.16708999872207642f, 0.20760199427604675f, 0.24936899542808533f, 0.29154899716377258f, 0.3332040011882782f, 0.37377101182937622f, 0.41274300217628479f, 0.44977998733520508f, 0.4846780002117157f, 0.51733100414276123f, 0.54769200086593628f, 0.57572799921035767f, 0.6014779806137085f, 0.62501102685928345f, 1.46482000218384201e-06f, 0.00003429050047998f, 0.0002985020109918f, 0.00140504003502429f, 0.00443577999249101f, 0.01069260016083717f, 0.02133879996836185f, 0.0371410995721817f, 0.05836030095815659f, 0.08476380258798599f, 0.11572299897670746f, 0.1503559947013855f, 0.18766500055789948f, 0.22665500640869141f, 0.26647698879241943f, 0.30632400512695312f, 0.34550899267196655f, 0.38344401121139526f, 0.41970700025558472f, 0.45401400327682495f, 0.48618701100349426f, 0.51614201068878174f, 0.54384201765060425f, 0.56930899620056152f, 5.83937982412408019e-08f, 3.2765999549155822e-06f, 0.00005055400106357f, 0.00035111699253321f, 0.00145683996379375f, 0.00427943980321288f, 0.0098936902359128f, 0.01927389949560165f, 0.03310279920697212f, 0.05168719962239265f, 0.07495570182800293f, 0.10250899940729141f, 0.13370099663734436f, 0.1677280068397522f, 0.20372100174427032f, 0.24084299802780151f, 0.27840098738670349f, 0.31564199924468994f, 0.35190799832344055f, 0.38674798607826233f, 0.41985601186752319f, 0.45104199647903442f, 0.48021000623703003f, 0.50734001398086548f, 8.73966010672688753e-10f, 1.57741993689342053e-07f, 5.21975016454234719e-06f, 0.00006079579907237f, 0.00036219600588083f, 0.00138045998755842f, 0.00386844994500279f, 0.00871635042130947f, 0.01675550080835819f, 0.02860799990594387f, 0.04461279883980751f, 0.06480839848518372f, 0.08895269781351089f, 0.11656700074672699f, 0.1470009982585907f, 0.17950700223445892f, 0.21331800520420074f, 0.24785000085830688f, 0.28237700462341309f, 0.31631898880004883f, 0.34923198819160461f, 0.38083100318908691f, 0.41094100475311279f, 0.43946701288223267f, 2.8866399288257627e-12f, 2.63671995348602195e-09f, 2.51094007808205788e-07f, 5.97520011069718748e-06f, 0.00005859580051037f, 0.0003192939911969f, 0.00116373994387686f, 0.00319523992948234f, 0.00714873988181353f, 0.0137449000030756f, 0.0235638003796339f, 0.03696820139884949f, 0.05407309904694557f, 0.0747511014342308f, 0.09866459667682648f, 0.12531900405883789f, 0.15412400662899017f, 0.18446199595928192f, 0.21573600172996521f, 0.24741099774837494f, 0.27903899550437927f, 0.310263991355896f, 0.34082499146461487f, 0.37054198980331421f, 6.94488983838260476e-16f, 7.04290011727115584e-12f, 3.21448001550095341e-09f, 2.20180993437679717e-07f, 4.50593006462440826e-06f, 0.00004154839916737f, 0.00022262999846134f, 0.00081575999502093f, 0.00227530999109149f, 0.00519366981461644f, 0.01020010001957417f, 0.0178545992821455f, 0.02856850065290928f, 0.04256030172109604f, 0.05984469875693321f, 0.08025020360946655f, 0.10345599800348282f, 0.12904399633407593f, 0.15654699504375458f, 0.1854960024356842f, 0.21545499563217163f, 0.24603499472141266f, 0.27690801024436951f, 0.3078019917011261f, 5.46278023199234311e-22f, 3.43167987041791307e-16f, 2.29294990113093622e-12f, 9.57796952860689998e-10f, 6.87986982939037262e-08f, 1.5533599935224629e-06f, 0.00001600819996384f, 0.00009555240103509f, 0.00038631301140413f, 0.00117554003372788f, 0.00289549003355205f, 0.00607588002458215f, 0.01126710046082735f, 0.01896269991993904f, 0.02954130060970783f, 0.04323289915919304f, 0.06011129915714264f, 0.0801049992442131f, 0.10301999747753143f, 0.12857000529766083f, 0.15640300512313843f, 0.18612800538539886f, 0.21734000742435455f, 0.24963200092315674f, 0.0f, 0.0f, 3.09890004335006815e-24f, 2.21276004416278673e-18f, 2.67358004631774657e-14f, 2.24439997836833882e-11f, 3.13075010360819306e-09f, 1.26480998119404831e-07f, 2.12951999856159091e-06f, 0.00001907769910758f, 0.00010753999958979f, 0.00042892698547803f, 0.00131604995112866f, 0.00330013991333544f, 0.00707077002152801f, 0.01337909977883101f, 0.02291939966380596f, 0.03622379899024963f, 0.05359359830617905f, 0.07507230341434479f, 0.10045900195837021f, 0.12935000658035278f, 0.16119599342346191f, 0.19536399841308594f
} };
__device__ float velvetAlbedo(float mu_0, float r_3)
{
    float _S376 = (F32_sqrt((0.10000000149011612f)));
    float _S377 = clamp_1((F32_sqrt(((F32_max((mu_0), (0.0f)))))), 0.0f, 1.0f) * 23.0f;
    float _S378 = (clamp_1((F32_sqrt(((F32_max((r_3), (0.0f)))))), _S376, 1.0f) - _S376) / (1.0f - _S376) * 23.0f;
    uint _S379 = (U32_min((uint(_S377)), (22U)));
    uint _S380 = (U32_min((uint(_S378)), (22U)));
    float _S381 = _S377 - float(_S379);
    float _S382 = _S378 - float(_S380);
    uint _S383 = _S379 * 24U + _S380;
    uint _S384 = _S383 + 24U;
    float _S385 = VELVET_ALBEDO_0[_S383] + (VELVET_ALBEDO_0[_S384] - VELVET_ALBEDO_0[_S383]) * _S381;
    uint _S386 = _S383 + 1U;
    float _S387 = VELVET_ALBEDO_0[_S386] + (VELVET_ALBEDO_0[_S384 + 1U] - VELVET_ALBEDO_0[_S386]) * _S381;
    return _S385 + (_S387 - _S385) * _S382;
}

__device__ static const FixedArray<float, 576>  SHEEN_ALBEDO_0 = { {
    0.62089997529983521f, 0.49450001120567322f, 0.38080000877380371f, 0.28439998626708984f, 0.20010000467300415f, 0.1257999986410141f, 0.05990000069141388f, 0.00109999999403954f, -0.05160000175237656f, -0.09889999777078629f, -0.14159999787807465f, -0.18009999394416809f, -0.2151000052690506f, -0.24690000712871552f, -0.27590000629425049f, -0.30230000615119934f, -0.32649999856948853f, -0.34860000014305115f, -0.36890000104904175f, -0.38760000467300415f, -0.40479999780654907f, -0.42070001363754272f, -0.43439999222755432f, -0.44929999113082886f, 0.59240001440048218f, 0.47049999237060547f, 0.35899999737739563f, 0.26440000534057617f, 0.18150000274181366f, 0.10830000042915344f, 0.04329999908804893f, -0.01470000017434359f, -0.066600002348423f, -0.11339999735355377f, -0.15549999475479126f, -0.19370000064373016f, -0.22820000350475311f, -0.25970000028610229f, -0.28830000758171082f, -0.31450000405311584f, -0.33840000629425049f, -0.36039999127388f, -0.38049998879432678f, -0.39899998903274536f, -0.41609999537467957f, -0.43180000782012939f, -0.44539999961853027f, -0.46070000529289246f, 0.5228000283241272f, 0.40599998831748962f, 0.30259999632835388f, 0.21250000596046448f, 0.13330000638961792f, 0.06319999694824219f, 0.00069999997504056f, -0.05510000139474869f, -0.10520000010728836f, -0.15039999783039093f, -0.19120000302791595f, -0.2281000018119812f, -0.26170000433921814f, -0.2921999990940094f, -0.31999999284744263f, -0.34549999237060547f, -0.36869999766349792f, -0.39010000228881836f, -0.40970000624656677f, -0.42770001292228699f, -0.44440001249313354f, -0.45969998836517334f, -0.47389999032020569f, -0.48800000548362732f, 0.43569999933242798f, 0.32769998908042908f, 0.23160000145435333f, 0.14730000495910645f, 0.07280000299215317f, 0.00659999996423721f, -0.05260000005364418f, -0.10559999942779541f, -0.1534000039100647f, -0.19650000333786011f, -0.23549999296665192f, -0.27090001106262207f, -0.30309998989105225f, -0.33239999413490295f, -0.35920000076293945f, -0.38359999656677246f, -0.40599998831748962f, -0.42660000920295715f, -0.44549998641014099f, -0.46290001273155212f, -0.47900000214576721f, -0.49380001425743103f, -0.50749999284744263f, -0.52090001106262207f, 0.33129999041557312f, 0.23459999263286591f, 0.14740000665187836f, 0.07010000199079514f, 0.00139999995008111f, -0.0601000003516674f, -0.11519999802112579f, -0.16490000486373901f, -0.20970000326633453f, -0.25029999017715454f, -0.28720000386238098f, -0.3206000030040741f, -0.35109999775886536f, -0.37900000810623169f, -0.40439999103546143f, -0.42770001292228699f, -0.44900000095367432f, -0.46869999170303345f, -0.48669999837875366f, -0.5033000111579895f, -0.5187000036239624f, -0.53289997577667236f, -0.54600000381469727f, -0.55860000848770142f, 0.21109999716281891f, 0.12790000438690186f, 0.0511000007390976f, -0.01769999973475933f, -0.07970000058412552f, -0.13549999892711639f, -0.18600000441074371f, -0.23160000145435333f, -0.27300000190734863f, -0.31069999933242798f, -0.34490001201629639f, -0.37619999051094055f, -0.40470001101493835f, -0.43070000410079956f, -0.4546000063419342f, -0.476500004529953f, -0.49660000205039978f, -0.51510000228881836f, -0.53210002183914185f, -0.54780000448226929f, -0.56230002641677856f, -0.57580000162124634f, -0.58819997310638428f, -0.60009998083114624f, 0.0754999965429306f, 0.00800000037997961f, -0.05649999901652336f, -0.11569999903440475f, -0.16979999840259552f, -0.21920000016689301f, -0.26420000195503235f, -0.3052000105381012f, -0.34270000457763672f, -0.37689998745918274f, -0.40819999575614929f, -0.43680000305175781f, -0.46299999952316284f, -0.48710000514984131f, -0.50910001993179321f, -0.52939999103546143f, -0.54809999465942383f, -0.56529998779296875f, -0.5810999870300293f, -0.59570002555847168f, -0.60930001735687256f, -0.6218000054359436f, -0.63340002298355103f, -0.6445000171661377f, -0.07569999992847443f, -0.12489999830722809f, -0.17569999396800995f, -0.22380000352859497f, -0.26890000700950623f, -0.3107999861240387f, -0.34959998726844788f, -0.38539999723434448f, -0.41839998960494995f, -0.44870001077651978f, -0.47659999132156372f, -0.50230002403259277f, -0.52590000629425049f, -0.54759997129440308f, -0.56760001182556152f, -0.58600002527236938f, -0.6029999852180481f, -0.61870002746582031f, -0.63330000638961792f, -0.64670002460479736f, -0.6590999960899353f, -0.67059999704360962f, -0.68129998445510864f, -0.69160002470016479f, -0.24320000410079956f, -0.27120000123977661f, -0.30640000104904175f, -0.34209999442100525f, -0.37700000405311584f, -0.41060000658035278f, -0.44229999184608459f, -0.47220000624656677f, -0.50010001659393311f, -0.52600002288818359f, -0.55010002851486206f, -0.57239997386932373f, -0.59310001134872437f, -0.61220002174377441f, -0.62989997863769531f, -0.64620000123977661f, -0.66140002012252808f, -0.6754000186920166f, -0.68839997053146362f, -0.70039999485015869f, -0.71160000562667847f, -0.72200000286102295f, -0.73159998655319214f, -0.74089998006820679f, -0.42809998989105225f, -0.43149998784065247f, -0.44920000433921814f, -0.47099998593330383f, -0.49459999799728394f, -0.51880002021789551f, -0.54269999265670776f, -0.5658000111579895f, -0.58799999952316284f, -0.60900002717971802f, -0.62870001792907715f, -0.64730000495910645f, -0.6646999716758728f, -0.68080002069473267f, -0.69590002298355103f, -0.70999997854232788f, -0.72299998998641968f, -0.73509997129440308f, -0.74639999866485596f, -0.75690001249313354f, -0.76670002937316895f, -0.77579998970031738f, -0.78430002927780151f, -0.79250001907348633f, -0.63230001926422119f, -0.60759997367858887f, -0.60519999265670776f, -0.61119997501373291f, -0.62209999561309814f, -0.63580000400543213f, -0.65090000629425049f, -0.66659998893737793f, -0.68239998817443848f, -0.69789999723434448f, -0.71289998292922974f, -0.7271999716758728f, -0.74089998006820679f, -0.75379997491836548f, -0.76590001583099365f, -0.77740001678466797f, -0.78810000419616699f, -0.79809999465942383f, -0.80750000476837158f, -0.81629997491836548f, -0.82450002431869507f, -0.83209997415542603f, -0.83929997682571411f, -0.84630000591278076f, -0.85790002346038818f, -0.80119997262954712f, -0.77600002288818359f, -0.76410001516342163f, -0.76059997081756592f, -0.76239997148513794f, -0.76770001649856567f, -0.7750999927520752f, -0.78380000591278076f, -0.79309999942779541f, -0.80279999971389771f, -0.8125f, -0.82200002670288086f, -0.8312000036239624f, -0.8400999903678894f, -0.84859997034072876f, -0.85670000314712524f, -0.86440002918243408f, -0.8716999888420105f, -0.87849998474121094f, -0.88499999046325684f, -0.89099997282028198f, -0.89670002460479736f, -0.90240001678466797f, -1.10769999027252197f, -1.01429998874664307f, -0.96329998970031738f, -0.93110001087188721f, -0.91140002012252808f, -0.89990001916885376f, -0.89410001039505005f, -0.89219999313354492f, -0.89289999008178711f, -0.89539998769760132f, -0.89910000562667847f, -0.9035000205039978f, -0.90850001573562622f, -0.91360002756118774f, -0.9189000129699707f, -0.92419999837875366f, -0.92940002679824829f, -0.93440002202987671f, -0.93930000066757202f, -0.9440000057220459f, -0.94849997758865356f, -0.95270001888275146f, -0.95679998397827148f, -0.96100002527236938f, -1.38499999046325684f, -1.24950003623962402f, -1.16919994354248047f, -1.11409997940063477f, -1.07599997520446777f, -1.0494999885559082f, -1.03129994869232178f, -1.01880002021789551f, -1.01059997081756592f, -1.00539994239807129f, -1.00240004062652588f, -1.00109994411468506f, -1.0009000301361084f, -1.00150001049041748f, -1.00279998779296875f, -1.00440001487731934f, -1.00639998912811279f, -1.00849997997283936f, -1.01069998741149902f, -1.0130000114440918f, -1.01530003547668457f, -1.01750004291534424f, -1.01979994773864746f, -1.02230000495910645f, -1.69420003890991211f, -1.51020002365112305f, -1.39649999141693115f, -1.31540000438690186f, -1.2565000057220459f, -1.21309995651245117f, -1.18079996109008789f, -1.15649998188018799f, -1.13820004463195801f, -1.12440001964569092f, -1.11389994621276855f, -1.10599994659423828f, -1.10010004043579102f, -1.09560000896453857f, -1.09230005741119385f, -1.09000003337860107f, -1.08829998970031738f, -1.08710002899169922f, -1.08640003204345703f, -1.08599996566772461f, -1.08580005168914795f, -1.08580005168914795f, -1.08599996566772461f, -1.0866999626159668f, -2.04089999198913574f, -1.80079996585845947f, -1.64869999885559082f, -1.53789997100830078f, -1.45539999008178711f, -1.392799973487854f, -1.34459996223449707f, -1.30700004100799561f, -1.27730000019073486f, -1.25380003452301025f, -1.23489999771118164f, -1.21959996223449707f, -1.20720005035400391f, -1.19700002670288086f, -1.18859994411468506f, -1.18169999122619629f, -1.17589998245239258f, -1.17100000381469727f, -1.16690003871917725f, -1.16349995136260986f, -1.16059994697570801f, -1.15810000896453857f, -1.15600001811981201f, -1.15470004081726074f, -2.43269991874694824f, -2.12700009346008301f, -1.93060004711151123f, -1.78569996356964111f, -1.67610001564025879f, -1.59159994125366211f, -1.52530002593994141f, -1.47249996662139893f, -1.4299999475479126f, -1.39540004730224609f, -1.36689996719360352f, -1.3432999849319458f, -1.32350003719329834f, -1.30680000782012939f, -1.29270005226135254f, -1.28059995174407959f, -1.27009999752044678f, -1.26110005378723145f, -1.25329995155334473f, -1.24639999866485596f, -1.24039995670318604f, -1.23500001430511475f, -1.23029994964599609f, -1.22669994831085205f, -2.87989997863769531f, -2.49659991264343262f, -2.24860000610351562f, -2.06410002708435059f, -1.92330002784729004f, -1.8135000467300415f, -1.72640001773834229f, -1.65620005130767822f, -1.59899997711181641f, -1.55169999599456787f, -1.51230001449584961f, -1.47909998893737793f, -1.45099997520446777f, -1.42690002918243408f, -1.40610003471374512f, -1.3881000280380249f, -1.37240004539489746f, -1.35860002040863037f, -1.34640002250671387f, -1.33570003509521484f, -1.32609999179840088f, -1.31749999523162842f, -1.30980002880096436f, -1.30359995365142822f, -3.39750003814697266f, -2.92090010643005371f, -2.6119999885559082f, -2.38100004196166992f, -2.20359992980957031f, -2.0643000602722168f, -1.95290005207061768f, -1.86249995231628418f, -1.7882000207901001f, -1.72619998455047607f, -1.67410004138946533f, -1.62989997863769531f, -1.59200000762939453f, -1.55929994583129883f, -1.53090000152587891f, -1.50610005855560303f, -1.48430001735687256f, -1.46500003337860107f, -1.44790005683898926f, -1.43260002136230469f, -1.4189000129699707f, -1.40649998188018799f, -1.39540004730224609f, -1.38629996776580811f, -4.00810003280639648f, -3.41639995574951172f, -3.03419995307922363f, -2.74749994277954102f, -2.52649998664855957f, -2.35209989547729492f, -2.21210002899169922f, -2.09780001640319824f, -2.00309991836547852f, -1.92390000820159912f, -1.85679996013641357f, -1.7994999885559082f, -1.75020003318786621f, -1.70739996433258057f, -1.66999995708465576f, -1.6371999979019165f, -1.60819995403289795f, -1.58239996433258057f, -1.55949997901916504f, -1.53890001773834229f, -1.52040004730224609f, -1.50370001792907715f, -1.48860001564025879f, -1.47609996795654297f, -4.7491002082824707f, -4.00920009613037109f, -3.53640007972717285f, -3.18140006065368652f, -2.90700006484985352f, -2.69000005722045898f, -2.5150001049041748f, -2.37150001525878906f, -2.25230002403259277f, -2.15199995040893555f, -2.06680011749267578f, -1.99370002746582031f, -1.93060004711151123f, -1.87559998035430908f, -1.82739996910095215f, -1.78489995002746582f, -1.74730002880096436f, -1.71379995346069336f, -1.68389999866485596f, -1.65699994564056396f, -1.63279998302459717f, -1.6109999418258667f, -1.59109997749328613f, -1.5746999979019165f, -5.68760013580322266f, -4.74030017852783203f, -4.15259981155395508f, -3.71110010147094727f, -3.36949992179870605f, -3.09859991073608398f, -2.87960004806518555f, -2.69939994812011719f, -2.54920005798339844f, -2.42239999771118164f, -2.31439995765686035f, -2.22140002250671387f, -2.1408998966217041f, -2.07069993019104004f, -2.00900006294250488f, -1.95459997653961182f, -1.90629994869232178f, -1.86329996585845947f, -1.82480001449584961f, -1.79030001163482666f, -1.75919997692108154f, -1.73099994659423828f, -1.70550000667572021f, -1.68429994583129883f, -6.68940019607543945f, -5.34350013732910156f, -4.86259984970092773f, -4.34409999847412109f, -3.93390011787414551f, -3.60269999504089355f, -3.33100008964538574f, -3.10509991645812988f, -2.91510009765625f, -2.75390005111694336f, -2.61590003967285156f, -2.49690008163452148f, -2.3935999870300293f, -2.30340003967285156f, -2.22420001029968262f, -2.15440011024475098f, -2.09240007400512695f, -2.03730010986328125f, -1.98800003528594971f, -1.94369995594024658f, -1.90390002727508545f, -1.86790001392364502f, -1.83480000495910645f, -1.8078000545501709f, -9.69550037384033203f, -7.62489986419677734f, -6.61070013046264648f, -5.72329998016357422f, -5.04829978942871094f, -4.52129983901977539f, -4.10120010375976562f, -3.76049995422363281f, -3.48009991645812988f, -3.24640011787414551f, -3.04959988594055176f, -2.88229990005493164f, -2.738800048828125f, -2.61479997634887695f, -2.50699996948242188f, -2.41269993782043457f, -2.32960009574890137f, -2.25620007514953613f, -2.19090008735656738f, -2.13269996643066406f, -2.08049988746643066f, -2.03349995613098145f, -1.99049997329711914f, -1.95369994640350342f
} };
__device__ float sheenAlbedo(float mu_1, float r_4)
{
    float _S388 = (F32_sqrt((0.05000000074505806f)));
    float _S389 = clamp_1((F32_sqrt(((F32_max((mu_1), (0.0f)))))), 0.0f, 1.0f) * 23.0f;
    float _S390 = (clamp_1((F32_sqrt(((F32_max((r_4), (0.0f)))))), _S388, 1.0f) - _S388) / (1.0f - _S388) * 23.0f;
    uint _S391 = (U32_min((uint(_S389)), (22U)));
    uint _S392 = (U32_min((uint(_S390)), (22U)));
    float _S393 = _S389 - float(_S391);
    float _S394 = _S390 - float(_S392);
    uint _S395 = _S391 * 24U + _S392;
    uint _S396 = _S395 + 24U;
    float _S397 = SHEEN_ALBEDO_0[_S395] + (SHEEN_ALBEDO_0[_S396] - SHEEN_ALBEDO_0[_S395]) * _S393;
    uint _S398 = _S395 + 1U;
    float _S399 = SHEEN_ALBEDO_0[_S398] + (SHEEN_ALBEDO_0[_S396 + 1U] - SHEEN_ALBEDO_0[_S398]) * _S393;
    return (F32_exp((_S397 + (_S399 - _S397) * _S394)));
}

static __device__ float3  mix_0(float3  e1_0, float3  e2_0, float e3_0)
{
    return e1_0 * make_float3 (1.0f - e3_0) + e2_0 * make_float3 (e3_0);
}

__device__ float anisotropicG1(float3  w_1, float2  alphas_1)
{
    float _S400 = (F32_max((w_1.z), (0.0f)));
    return 2.0f * _S400 / (_S400 + length_0(make_float3 (alphas_1.x * w_1.x, alphas_1.y * w_1.y, _S400)));
}

__device__ float anisotropicD(float3  h_0, float2  alphas_2)
{
    float _S401 = alphas_2.x;
    float _S402 = h_0.x / _S401;
    float _S403 = alphas_2.y;
    float _S404 = h_0.y / _S403;
    float _S405 = h_0.z;
    float _S406 = _S402 * _S402 + _S404 * _S404 + _S405 * _S405;
    return 1.0f / (F32_max((3.14159274101257324f * _S401 * _S403 * _S406 * _S406), (1.17549435082228751e-38f)));
}

static __device__ BSDFLobes BSDFLobes_x24init_0(float v_dot_h_0, float n_dot_h_0, float3  refracted_1, float3  F_0, float F_greyscale_0, float reflect_weight_0, float3  diffuse_weight_0, float3  refract_weight_0, float p_diffuse_0, float p_reflect_0, float p_refract_0, float translucent_share_0, float3  sheen_0, float3  view_0, float3  tangent_1, float2  alphas_3, float visible_0, float toon_share_0)
{
    BSDFLobes _S407;
    (&_S407)->v_dot_h = v_dot_h_0;
    (&_S407)->n_dot_h = n_dot_h_0;
    (&_S407)->refracted = refracted_1;
    (&_S407)->F = F_0;
    (&_S407)->F_greyscale = F_greyscale_0;
    (&_S407)->reflect_weight = reflect_weight_0;
    (&_S407)->diffuse_weight = diffuse_weight_0;
    (&_S407)->refract_weight = refract_weight_0;
    (&_S407)->p_diffuse = p_diffuse_0;
    (&_S407)->p_reflect = p_reflect_0;
    (&_S407)->p_refract = p_refract_0;
    (&_S407)->translucent_share = translucent_share_0;
    (&_S407)->sheen = sheen_0;
    (&_S407)->view = view_0;
    (&_S407)->tangent = tangent_1;
    (&_S407)->alphas = alphas_3;
    (&_S407)->visible = visible_0;
    (&_S407)->toon_share = toon_share_0;
    return _S407;
}

__device__ __forceinline__ BSDFLobes bsdfLobes(float3  in_dir_0, float3  v_3, float3  n_i_2, float3  ggx_n_0, BSDFMaterial material_1, float eta_i_1, float eta_o_1, AnisotropicFrame frame_1)
{
    float _S408 = dot_0(ggx_n_0, v_3);
    float _S409 = dot_0(n_i_2, ggx_n_0);
    float _S410 = eta_i_1 / eta_o_1;
    float3  _S411 = refract_0(in_dir_0, ggx_n_0, _S410);
    float3  _S412 = ((((_S411)) * make_float3(rnorm3df(((_S411)).x, ((_S411)).y, ((_S411)).z))));
    float _S413 = (F32_min(((F32_sqrt((material_1.specular_level))) * (F32_abs((eta_i_1 - eta_o_1))) / (eta_i_1 + eta_o_1)), (0.9999847412109375f)));
    float _S414 = _S413 * _S413;
    float _S415 = (1.0f + _S413) / (1.0f - _S413);
    float _S416 = (F32_abs((_S408)));
    bool _S417 = eta_i_1 > eta_o_1;
    float sheen_component_0;
    if(_S417)
    {
        sheen_component_0 = _S415;
    }
    else
    {
        sheen_component_0 = 1.0f;
    }
    float toon_component_0;
    if(_S417)
    {
        toon_component_0 = 1.0f;
    }
    else
    {
        toon_component_0 = _S415;
    }
    float _S418 = fresnel(_S416, sheen_component_0, toon_component_0);
    bool _S419 = (eta_i_1 * eta_i_1 * (1.0f - _S408 * _S408)) >= (eta_o_1 * eta_o_1);
    float3  _S420;
    if(_S419)
    {
        _S420 = make_float3 (1.0f);
    }
    else
    {
        float3  _S421 = material_1.specular_tint * make_float3 (_S414);
        _S420 = _S421 + (make_float3 (1.0f) - _S421) * make_float3 (_S418 - _S414) / make_float3 (1.0f - _S414);
    }
    float3  _S422 = make_float3 (1.0f);
    float3  _S423 = make_float3 (0.0f);
    float _S424 = rgb_to_greyscale(material_1.sheen);
    bool _S425 = _S424 > 0.0f;
    float3  sheen_1;
    float3  view_1;
    float3  scale_1;
    if(_S425)
    {
        if((material_1.velvet) > 0.0f)
        {
            float _S426 = velvetAlbedo(dot_0(n_i_2, v_3), material_1.sheen_roughness);
            sheen_component_0 = _S426;
        }
        else
        {
            float _S427 = sheenAlbedo(dot_0(n_i_2, v_3), material_1.sheen_roughness);
            sheen_component_0 = _S427;
        }
        float _S428 = (F32_min((sheen_component_0), (1.0f)));
        float3  _S429 = make_float3 (1.0f) - material_1.sheen * make_float3 (_S428);
        float _S430 = rgb_to_greyscale(material_1.sheen);
        float _S431 = _S430 * _S428;
        float3  _S432 = material_1.sheen / make_float3 ((F32_max((sheen_component_0), (1.0f))));
        sheen_component_0 = _S431;
        sheen_1 = _S432;
        view_1 = v_3;
        scale_1 = _S429;
    }
    else
    {
        sheen_component_0 = 0.0f;
        sheen_1 = _S423;
        view_1 = _S423;
        scale_1 = _S422;
    }
    float _S433 = (F32_abs((material_1.toon.x)));
    bool _S434 = _S433 > 0.0f;
    if(_S434)
    {
        float _S435 = (F32_min((_S433), (1.0f)));
        float3  scale_2 = scale_1 * make_float3 (1.0f - _S435);
        float _S436 = rgb_to_greyscale(material_1.albedo);
        float _S437 = _S435 * _S436;
        toon_component_0 = _S437;
        scale_1 = scale_2;
    }
    else
    {
        toon_component_0 = 0.0f;
    }
    float3  _S438 = mix_0(_S420, material_1.albedo, material_1.metallic);
    float3  F_1 = _S438 * scale_1;
    float _S439 = rgb_to_greyscale(F_1);
    float _S440 = 1.0f - material_1.metallic;
    float3  _S441 = make_float3 (1.0f) - _S420;
    float3  _S442 = make_float3 ((1.0f - material_1.transmission) * _S440) * _S441 * scale_1;
    float3  _S443 = make_float3 (material_1.transmission * _S440) * _S441 * scale_1;
    float _S444 = (F32_max((_S439), (0.0f)));
    float _S445 = rgb_to_greyscale(_S442);
    float _S446 = (F32_max((_S445), (0.0f)));
    float _S447 = rgb_to_greyscale(_S443);
    float _S448 = sign_0(length_0(_S412));
    float _S449 = (F32_max((_S447 * _S448), (0.0f)));
    float _S450 = _S444 + _S446 + _S449 + sheen_component_0 + toon_component_0;
    float _S451 = 1.0f / (F32_max((_S450), (0.0000152587890625f)));
    float _S452 = _S446 + sheen_component_0 + toon_component_0;
    float _S453 = _S452 * _S451;
    float _S454 = _S444 * _S451;
    float _S455 = _S449 * _S451;
    bool _S456 = (frame_1.alphas.x) > 0.0f;
    float visible_1;
    if(_S456)
    {
        float3  _S457 = anisotropicLocal(v_3, frame_1.tangent, n_i_2);
        float _S458 = anisotropicG1(_S457, frame_1.alphas);
        float3  _S459 = anisotropicLocal(ggx_n_0, frame_1.tangent, n_i_2);
        float _S460 = anisotropicD(_S459, frame_1.alphas);
        float _S461 = _S458 * _S460;
        visible_1 = _S461;
    }
    else
    {
        visible_1 = 0.0f;
    }
    return BSDFLobes_x24init_0(_S408, _S409, _S412, F_1, _S439, 1.0f, _S442, _S443, _S453, _S454, _S455, 0.0f, sheen_1, view_1, frame_1.tangent, frame_1.alphas, visible_1, toon_component_0 / (F32_max((_S452), (0.0000152587890625f))));
}

__device__ float translucentShare(BSDFMaterial material_2)
{
    float _S462 = rgb_to_greyscale(material_2.translucent);
    float _S463 = rgb_to_greyscale(material_2.albedo);
    float _S464 = _S462 / (_S463 + _S462);
    bool _S465 = _S462 > 0.0f;
    float _S466 = _slang_select(_S465, _S464,0.0f);
    return _S466;
}

__device__ float smithG1(float alpha_2, float n_dot_x_0)
{
    float _S467 = alpha_2 * alpha_2;
    float _S468 = 2.0f * n_dot_x_0 / (n_dot_x_0 + (F32_sqrt((_S467 + (1.0f - _S467) * n_dot_x_0 * n_dot_x_0))));
    bool _S469 = alpha_2 > 0.0f;
    float _S470 = _slang_select(_S469, _S468,1.0f);
    return _S470;
}

__device__ float trowbridgeReitz(float alpha_3, float n_dot_h_1)
{
    float _S471 = alpha_3 * alpha_3;
    float _S472 = (1.0f - n_dot_h_1) * (1.0f + n_dot_h_1) + _S471 * n_dot_h_1 * n_dot_h_1;
    return _S471 / (F32_max((3.14159274101257324f * _S472 * _S472), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ float lobeDensity(float n_i_dot_l_0, float l_dot_h_0, float n_i_dot_v_0, float alpha_4, BSDFLobes lobes_0, float eta_i_2, float eta_o_2, uint lobe_0)
{
    bool _S473 = lobe_0 == 0U;
    if(_S473)
    {
        float _S474 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
        float _S475 = lobes_0.p_diffuse * (F32_abs((n_i_dot_l_0))) * 0.31830987334251404f;
        float _S476 = 1.0f - lobes_0.translucent_share;
        bool _S477 = n_i_dot_l_0 < 0.0f;
        float _S478 = _slang_select(_S477, lobes_0.translucent_share,_S476);
        float _S479 = _S475 * _S478;
        bool _S480 = (lobes_0.translucent_share) > 0.0f;
        float _S481 = _slang_select(_S480, _S479,_S474);
        bool _S482 = n_i_dot_v_0 > 0.0f;
        float _S483 = _slang_select(_S482, _S481,0.0f);
        return _S483;
    }
    float _S484 = smithG1(alpha_4, n_i_dot_v_0);
    float _S485 = _S484 * lobes_0.v_dot_h;
    float _S486 = trowbridgeReitz(alpha_4, lobes_0.n_dot_h);
    float _S487 = _S485 * _S486 / n_i_dot_v_0;
    bool _S488 = alpha_4 > 0.0f;
    bool _S489;
    if(_S488)
    {
        _S489 = (lobes_0.v_dot_h) > 0.0f;
    }
    else
    {
        _S489 = false;
    }
    if(_S489)
    {
        _S489 = (lobes_0.n_dot_h) > 0.0f;
    }
    else
    {
        _S489 = false;
    }
    if(_S489)
    {
        _S489 = n_i_dot_v_0 > 0.0f;
    }
    else
    {
        _S489 = false;
    }
    float _S490 = _slang_select(_S489, _S487,0.0f);
    bool _S491 = (lobes_0.alphas.x) > 0.0f;
    float pdf_h_0;
    if(_S491)
    {
        float _S492 = lobes_0.visible * lobes_0.v_dot_h / n_i_dot_v_0;
        bool _S493 = (lobes_0.v_dot_h) > 0.0f;
        if(_S493)
        {
            _S489 = (lobes_0.n_dot_h) > 0.0f;
        }
        else
        {
            _S489 = false;
        }
        if(_S489)
        {
            _S489 = n_i_dot_v_0 > 0.0f;
        }
        else
        {
            _S489 = false;
        }
        float _S494 = _slang_select(_S489, _S492,0.0f);
        pdf_h_0 = _S494;
    }
    else
    {
        pdf_h_0 = _S490;
    }
    bool _S495 = lobe_0 == 1U;
    if(_S495)
    {
        float _S496 = eta_i_2 * lobes_0.v_dot_h + eta_o_2 * l_dot_h_0;
        float _S497 = lobes_0.p_refract * pdf_h_0 * eta_o_2 * eta_o_2 * (F32_abs((l_dot_h_0))) / (_S496 * _S496);
        bool _S498 = eta_i_2 != eta_o_2;
        if(_S498)
        {
            _S489 = l_dot_h_0 < 0.0f;
        }
        else
        {
            _S489 = false;
        }
        float _S499 = _slang_select(_S489, _S497,0.0f);
        return _S499;
    }
    float _S500 = lobes_0.p_reflect * pdf_h_0 / (4.0f * lobes_0.v_dot_h);
    bool _S501 = pdf_h_0 > 0.0f;
    float _S502 = _slang_select(_S501, _S500,0.0f);
    return _S502;
}

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_0, uint random_state_3, bool refracted_2, uint lobe_1, float pdf_0)
{
    SampleBSDF _S503;
    (&_S503)->unit_direction = unit_direction_1;
    (&_S503)->throughput = throughput_0;
    (&_S503)->random_state = random_state_3;
    (&_S503)->refracted = refracted_2;
    (&_S503)->lobe = lobe_1;
    (&_S503)->pdf = pdf_0;
    return _S503;
}

__device__ float velvetBRDF(float3  l_0, float3  v_4, float3  n_5, float r_5)
{
    float _S504 = (F32_max((r_5), (0.00999999977648258f)));
    float _S505 = _S504 * _S504;
    float3  _S506 = l_0 + v_4;
    float3  _S507 = ((((_S506)) * make_float3(rnorm3df(((_S506)).x, ((_S506)).y, ((_S506)).z))));
    float _S508 = dot_0(n_5, _S507);
    float _S509 = (F32_max((dot_0(n_5, l_0)), (0.0f)));
    float _S510 = (F32_max((dot_0(n_5, v_4)), (0.0f)));
    float _S511 = (F32_max((1.0f - _S508 * _S508), (0.0000152587890625f)));
    float _S512 = (F32_exp((- _S508 * _S508 / (_S511 * _S505)))) / (3.14159274101257324f * _S505 * _S511 * _S511);
    float _S513 = (F32_min((1.0f), (2.0f * _S508 * (F32_min((_S509), (_S510))) / (F32_max(((F32_abs((dot_0(_S507, v_4))))), (0.0000152587890625f))))));
    return _S512 * _S513 / (F32_max((4.0f * _S509 * _S510), (0.0000152587890625f)));
}

__device__ float sheenBRDF(float3  l_1, float3  v_5, float3  n_6, float r_6)
{
    float _S514 = 1.0f / (F32_max((r_6), (0.05000000074505806f)));
    float3  _S515 = l_1 + v_5;
    float3  _S516 = ((((_S515)) * make_float3(rnorm3df(((_S515)).x, ((_S515)).y, ((_S515)).z))));
    float _S517 = dot_0(n_6, _S516);
    float _S518 = (F32_max((dot_0(n_6, l_1)), (0.0f)));
    float _S519 = (F32_max((dot_0(n_6, v_5)), (0.0f)));
    return (2.0f + _S514) * (F32_pow(((F32_max((1.0f - _S517 * _S517), (0.0f)))), (0.5f * _S514))) * 0.5f * 0.31830987334251404f / (F32_max((4.0f * (_S518 + _S519 - _S518 * _S519)), (0.0000152587890625f)));
}

__device__ __forceinline__ float3  lobeThroughput(float3  l_2, float3  n_i_3, float alpha_5, BSDFMaterial material_3, BSDFLobes lobes_1, uint lobe_2)
{
    bool _S520 = lobe_2 == 0U;
    float G1_l_0;
    if(_S520)
    {
        bool _S521 = (dot_0(n_i_3, l_2)) < 0.0f;
        float3  _S522 = _slang_select(_S521, material_3.translucent,material_3.albedo);
        float _S523 = 1.0f - lobes_1.translucent_share;
        float _S524 = _slang_select(_S521, lobes_1.translucent_share,_S523);
        float3  _S525 = _S522 / make_float3 (_S524);
        bool _S526 = (lobes_1.translucent_share) > 0.0f;
        float3  _S527 = _slang_select(_S526, _S525,material_3.albedo);
        float _S528 = rgb_to_greyscale(material_3.sheen);
        bool _S529 = _S528 > 0.0f;
        bool _S530;
        if(_S529)
        {
            _S530 = !_S521;
        }
        else
        {
            _S530 = false;
        }
        if(_S530)
        {
            if((material_3.velvet) > 0.0f)
            {
                float _S531 = velvetBRDF(l_2, lobes_1.view, n_i_3, material_3.sheen_roughness);
                G1_l_0 = _S531;
            }
            else
            {
                float _S532 = sheenBRDF(l_2, lobes_1.view, n_i_3, material_3.sheen_roughness);
                G1_l_0 = _S532;
            }
            float3  _S533 = lobes_1.diffuse_weight * _S527;
            float3  _S534 = lobes_1.sheen * make_float3 (3.14159274101257324f) * make_float3 (G1_l_0);
            float _S535 = _slang_select(_S526, _S523,1.0f);
            return (_S533 + _S534 / make_float3 (_S535)) / make_float3 (lobes_1.p_diffuse);
        }
        return lobes_1.diffuse_weight * _S527 / make_float3 (lobes_1.p_diffuse);
    }
    bool _S536 = lobe_2 == 1U;
    if(_S536)
    {
        float _S537 = - dot_0(n_i_3, l_2);
        float _S538 = smithG1(alpha_5, (F32_max((_S537), (0.0f))));
        bool _S539 = (lobes_1.alphas.x) > 0.0f;
        if(_S539)
        {
            float3  _S540 = negate_0(n_i_3);
            float3  _S541 = anisotropicLocal(l_2, lobes_1.tangent, _S540);
            float _S542 = anisotropicG1(_S541, lobes_1.alphas);
            G1_l_0 = _S542;
        }
        else
        {
            G1_l_0 = _S538;
        }
        return lobes_1.refract_weight * make_float3 (G1_l_0) * material_3.albedo / make_float3 (lobes_1.p_refract);
    }
    float _S543 = dot_0(n_i_3, l_2);
    float _S544 = smithG1(alpha_5, (F32_max((_S543), (0.0f))));
    bool _S545 = (lobes_1.alphas.x) > 0.0f;
    if(_S545)
    {
        float3  _S546 = anisotropicLocal(l_2, lobes_1.tangent, n_i_3);
        float _S547 = anisotropicG1(_S546, lobes_1.alphas);
        G1_l_0 = _S547;
    }
    else
    {
        G1_l_0 = _S544;
    }
    return make_float3 (lobes_1.reflect_weight * G1_l_0) * lobes_1.F / make_float3 (lobes_1.p_reflect);
}

struct ToonLobe_0
{
    float a_5;
    float s_0;
    float b_1;
    bool glossy_0;
};

static __device__ ToonLobe_0 ToonLobe_x24init_0(float a_6, float s_1, float b_2, bool glossy_1)
{
    ToonLobe_0 _S548;
    (&_S548)->a_5 = a_6;
    (&_S548)->s_0 = s_1;
    (&_S548)->b_1 = b_2;
    (&_S548)->glossy_0 = glossy_1;
    return _S548;
}

static __device__ ToonLobe_0 toonLobe_0(float3  toon_0)
{
    float _S549 = toon_0.x;
    bool _S550 = (F32_abs((_S549))) > 0.0f;
    float _S551 = _slang_select(_S550, _S549,1.0f);
    float _S552 = clamp_1(toon_0.y / _S551, 0.00000999999974738f, 1.0f) * 3.14159274101257324f / 2.0f;
    float _S553 = clamp_1(toon_0.z / _S551, 0.0f, 1.0f) * 3.14159274101257324f / 2.0f;
    return ToonLobe_x24init_0(_S552, _S553, (F32_min((_S552 + _S553), (1.57079637050628662f))), _S549 < 0.0f);
}

static __device__ float toonProfile_0(float t_12, ToonLobe_0 * lobe_3)
{
    float _S554 = lobe_3->a_5;
    float _S555;
    if(t_12 < (lobe_3->a_5))
    {
        _S555 = 1.0f;
    }
    else
    {
        _S555 = (F32_max((1.0f - (t_12 - _S554) / (F32_max((lobe_3->s_0), (0.0000152587890625f)))), (0.0f)));
    }
    return _S555;
}

static __device__ float toonIntegral_0(float t_13, ToonLobe_0 * lobe_4)
{
    float _S556 = lobe_4->a_5;
    bool _S557 = lobe_4->glossy_0;
    float _S558;
    if(lobe_4->glossy_0)
    {
        _S558 = 1.0f - (F32_cos(((F32_min((t_13), (_S556))))));
    }
    else
    {
        float _S559 = (F32_sin(((F32_min((t_13), (_S556))))));
        _S558 = _S559 * _S559 / 2.0f;
    }
    bool _S560 = t_13 > _S556;
    bool _S561;
    if(_S560)
    {
        _S561 = (lobe_4->s_0) > 0.0f;
    }
    else
    {
        _S561 = false;
    }
    bool _S562 = !_S561;
    if(_S562)
    {
        return _S558;
    }
    if(_S557)
    {
        float _S563 = (F32_cos((_S556)));
        float _S564 = (F32_cos((t_13)));
        return _S558 + (1.0f + _S556 / lobe_4->s_0) * (_S563 - _S564) - ((F32_sin((t_13))) - t_13 * _S564 - ((F32_sin((_S556))) - _S556 * _S563)) / lobe_4->s_0;
    }
    float _S565 = 2.0f * _S556;
    float _S566 = (F32_cos((_S565)));
    float _S567 = 2.0f * t_13;
    float _S568 = (F32_cos((_S567)));
    return _S558 + (1.0f + _S556 / lobe_4->s_0) * (_S566 - _S568) / 4.0f - ((F32_sin((_S567))) / 8.0f - t_13 * _S568 / 4.0f - ((F32_sin((_S565))) / 8.0f - _S556 * _S566 / 4.0f)) / lobe_4->s_0;
}

__device__ float toonDensity(float3  v_6, float3  l_3, float3  n_7, float3  toon_1)
{
    ToonLobe_0 _S569 = toonLobe_0(toon_1);
    float _S570 = dot_0(n_7, l_3);
    if(_S569.glossy_0)
    {
        float _S571 = (F32_acos((clamp_1(dot_0(make_float3 (2.0f * dot_0(n_7, v_6)) * n_7 - v_6, l_3), -1.0f, 1.0f))));
        ToonLobe_0 _S572 = _S569;
        float _S573 = toonProfile_0(_S571, &_S572);
        ToonLobe_0 _S574 = _S569;
        float _S575 = toonIntegral_0(_S569.b_1, &_S574);
        return _S573 / (6.28318548202514648f * _S575);
    }
    float _S576 = (F32_acos(((F32_min((_S570), (1.0f))))));
    ToonLobe_0 _S577 = _S569;
    float _S578 = toonProfile_0(_S576, &_S577);
    float _S579 = _S578 * _S570;
    ToonLobe_0 _S580 = _S569;
    float _S581 = toonIntegral_0(_S569.b_1, &_S580);
    float _S582 = _S579 / (6.28318548202514648f * _S581);
    bool _S583 = _S570 > 0.0f;
    float _S584 = _slang_select(_S583, _S582,0.0f);
    return _S584;
}

__device__ float toonBSDF(float3  v_7, float3  l_4, float3  n_8, float3  toon_2)
{
    ToonLobe_0 _S585 = toonLobe_0(toon_2);
    float _S586 = dot_0(n_8, v_7);
    float _S587 = dot_0(n_8, l_4);
    bool _S588 = _S586 > 0.0f;
    bool _S589;
    if(_S588)
    {
        _S589 = _S587 > 0.0f;
    }
    else
    {
        _S589 = false;
    }
    bool _S590 = !_S589;
    if(_S590)
    {
        return 0.0f;
    }
    if(_S585.glossy_0)
    {
        float _S591 = (F32_acos((clamp_1(dot_0(make_float3 (2.0f * _S586) * n_8 - v_7, l_4), -1.0f, 1.0f))));
        ToonLobe_0 _S592 = _S585;
        float _S593 = toonProfile_0(_S591, &_S592);
        ToonLobe_0 _S594 = _S585;
        float _S595 = toonIntegral_0(_S585.b_1, &_S594);
        return _S593 / (6.28318548202514648f * _S595);
    }
    float _S596 = (F32_acos(((F32_min((_S586), (1.0f))))));
    ToonLobe_0 _S597 = _S585;
    float _S598 = toonProfile_0(_S596, &_S597);
    float _S599 = (F32_acos(((F32_min((_S587), (1.0f))))));
    ToonLobe_0 _S600 = _S585;
    float _S601 = toonProfile_0(_S599, &_S600);
    float _S602 = _S598 * _S601;
    ToonLobe_0 _S603 = _S585;
    float _S604 = toonIntegral_0(_S585.b_1, &_S603);
    return _S602 / (6.28318548202514648f * _S604);
}

static __device__ void toonMix_0(SampleBSDF * drawn_0, float3  v_8, float3  n_i_4, BSDFMaterial * material_4, BSDFLobes * lobes_2)
{
    float3  _S605 = drawn_0->unit_direction;
    float _S606 = (F32_max((drawn_0->pdf), (0.0f)));
    float _S607 = (1.0f - lobes_2->toon_share) * _S606;
    float _S608 = lobes_2->toon_share * lobes_2->p_diffuse;
    float3  _S609 = material_4->toon;
    float _S610 = toonDensity(v_8, _S605, n_i_4, material_4->toon);
    float _S611 = _S607 + _S608 * _S610;
    float3  _S612 = make_float3 ((F32_min(((F32_abs((_S609.x)))), (1.0f)))) * material_4->albedo;
    float _S613 = toonBSDF(v_8, _S605, n_i_4, _S609);
    float3  _S614 = _S612 * make_float3 (_S613) * make_float3 ((F32_max((dot_0(n_i_4, _S605)), (0.0f))));
    float3  _S615 = make_float3 (0.0f);
    float3  _S616 = (drawn_0->throughput * make_float3 (_S606) + _S614) / make_float3 (_S611);
    bool _S617 = _S611 > 0.0f;
    float3  _S618 = _slang_select(_S617, _S616,_S615);
    drawn_0->throughput = _S618;
    drawn_0->pdf = _S611;
    return;
}

__device__ __forceinline__ SampleBSDF connectBSDF(float3  in_dir_1, float3  out_dir_0, float3  n_9, BSDFMaterial material_5, float eta_i_3, float eta_o_3, uint lobe_5, uint random_init_0)
{
    uint random_state_4 = random_init_0;
    float3  _S619 = negate_0(in_dir_1);
    float _S620 = dot_0(n_9, _S619);
    float _S621 = sign_0(_S620);
    float3  _S622 = n_9 * make_float3 (_S621);
    float _S623 = material_5.roughness;
    float _S624 = _S623 * _S623;
    AnisotropicFrame _S625 = anisotropicFrame(material_5, _S622);
    float3  _S626 = _S619 + out_dir_0;
    float3  _S627 = ((((_S626)) * make_float3(rnorm3df(((_S626)).x, ((_S626)).y, ((_S626)).z))));
    bool _S628 = lobe_5 == 0U;
    float3  ggx_n_1;
    if(_S628)
    {
        float3  _S629 = sampleHalfVector(_S619, _S622, _S624, _S625, &random_state_4);
        ggx_n_1 = _S629;
    }
    else
    {
        bool _S630 = lobe_5 == 1U;
        if(_S630)
        {
            float3  _S631 = negate_0(make_float3 (eta_i_3) * _S619 + make_float3 (eta_o_3) * out_dir_0);
            float3  _S632 = ((((_S631)) * make_float3(rnorm3df(((_S631)).x, ((_S631)).y, ((_S631)).z))));
            float _S633 = sign_0(dot_0(_S631, _S622));
            float3  _S634 = _S632 * make_float3 (_S633);
            ggx_n_1 = _S634;
        }
        else
        {
            ggx_n_1 = _S627;
        }
    }
    BSDFLobes _S635 = bsdfLobes(in_dir_1, _S619, _S622, ggx_n_1, material_5, eta_i_3, eta_o_3, _S625);
    BSDFLobes lobes_3 = _S635;
    float _S636 = translucentShare(material_5);
    (&lobes_3)->translucent_share = _S636;
    float _S637 = lobeDensity(dot_0(_S622, out_dir_0), dot_0(out_dir_0, ggx_n_1), (F32_abs((_S620))), _S624, lobes_3, eta_i_3, eta_o_3, lobe_5);
    bool _S638 = !(_S637 > 0.0f);
    if(_S638)
    {
        float3  _S639 = make_float3 (0.0f);
        return SampleBSDF_x24init_0(_S639, _S639, 0U, false, 0U, 0.0f);
    }
    float3  _S640 = lobeThroughput(out_dir_0, _S622, _S624, material_5, lobes_3, lobe_5);
    SampleBSDF _S641 = SampleBSDF_x24init_0(out_dir_0, _S640, random_state_4, lobe_5 == 1U, lobe_5, _S637);
    SampleBSDF sample_0 = _S641;
    bool _S642;
    if(_S628)
    {
        _S642 = ((&lobes_3)->toon_share) > 0.0f;
    }
    else
    {
        _S642 = false;
    }
    if(_S642)
    {
        BSDFMaterial _S643 = material_5;
        BSDFLobes _S644 = lobes_3;
        toonMix_0(&sample_0, _S619, _S622, &_S643, &_S644);
    }
    return sample_0;
}

__device__ __forceinline__ float3  neeBSDF(float3  in_dir_2, float3  dir_3, float3  n_10, BSDFMaterial material_6, float eta_i_4, float eta_o_4, bool refracted_3, float pdf_1, bool power_0, uint random_state_5)
{
    float3  _S645 = make_float3 (0.0f);
    uint lobe_6 = 0U;
    float3  f_1 = _S645;
    for(;;)
    {
        if(lobe_6 < 3U)
        {
        }
        else
        {
            break;
        }
        bool _S646 = lobe_6 == 0U;
        if(_S646)
        {
        }
        bool _S647;
        if(_S646)
        {
            float _S648 = rgb_to_greyscale(material_6.translucent);
            _S647 = _S648 > 0.0f;
        }
        else
        {
            _S647 = false;
        }
        bool _S649;
        if(_S647)
        {
            float _S650 = dot_0(n_10, dir_3);
            float3  _S651 = negate_0(in_dir_2);
            _S649 = ((_S650 * dot_0(n_10, _S651)) < 0.0f) == refracted_3;
        }
        else
        {
            _S649 = (lobe_6 == 1U) == refracted_3;
        }
        float3  f_2;
        if(_S649)
        {
            SampleBSDF _S652 = connectBSDF(in_dir_2, dir_3, n_10, material_6, eta_i_4, eta_o_4, lobe_6, random_state_5);
            bool _S653 = (_S652.pdf) > 0.0f;
            if(_S653)
            {
                if(power_0)
                {
                    float _S654 = _S652.pdf / pdf_1;
                    float3  f_3 = f_1 + _S652.throughput * make_float3 (_S652.pdf) / make_float3 (pdf_1 * (1.0f + _S654 * _S654));
                    f_2 = f_3;
                }
                else
                {
                    float3  f_4 = f_1 + _S652.throughput * make_float3 (_S652.pdf) / make_float3 (_S652.pdf + pdf_1);
                    f_2 = f_4;
                }
            }
            else
            {
                f_2 = f_1;
            }
        }
        else
        {
            f_2 = f_1;
        }
        uint lobe_7 = lobe_6 + 1U;
        lobe_6 = lobe_7;
        f_1 = f_2;
    }
    return f_1;
}

__device__ float3  skyBSDF(float3  in_dir_3, float3  dir_4, FKSurface surface_1, float2  eta_1, bool is_inside_2, float pdf_2, uint random_state_6)
{
    bool _S655 = wrongSide_0(is_inside_2, false, dir_4, surface_1.geometry_n);
    float3  _S656 = neeBSDF(in_dir_3, dir_4, surface_1.smooth_n, surface_1.material, eta_1.x, eta_1.y, _S655, pdf_2, false, random_state_6);
    return _S656;
}

static __device__ SkySample SkySample_x24init_0(float3  dir_5, float3  radiance_0, float3  color_0, uint random_state_7)
{
    SkySample _S657;
    (&_S657)->dir = dir_5;
    (&_S657)->radiance = radiance_0;
    (&_S657)->color = color_0;
    (&_S657)->random_state = random_state_7;
    return _S657;
}

static __device__ SkySample sampleSky_0(FKRay * ray_0, FKSurface * surface_2, float2  eta_2, bool is_inside_3, uint init_random_state_0, uint lobe_state_0, ShadowContext * context_2)
{
    uint2  _S658 = (fcptEnvironmentCdfSize());
    uint2  _S659 = make_uint2 (1U, 0U);
    uint2  _S660 = _S658 - _S659;
    Random _S661 = pcg(init_random_state_0);
    Random _S662 = pcg(_S661.state);
    Random _S663 = pcg(_S662.state);
    Random _S664 = pcg(_S663.state);
    uint _S665 = _S660.x;
    uint _S666 = searchCDF_0(make_uint2 (_S665, 0U), make_uint2 (0U, 1U), _S660.y, _S661.value);
    uint _S667 = searchCDF_0(make_uint2 (0U, _S666), _S659, _S665, _S662.value);
    float2  _S668 = make_float2 ((float)_S660.x, (float)_S660.y);
    float2  _S669 = (make_float2 (float(_S667), float(_S666)) + make_float2 (_S663.value, _S664.value)) / _S668 * make_float2 (6.28318548202514648f, 3.14159274101257324f);
    float _S670 = _S669.y;
    float _S671 = (F32_sin((_S670)));
    float _S672 = _S669.x;
    float3  _S673 = make_float3 (- _S671 * (F32_cos((_S672))), _S671 * (F32_sin((_S672))), (F32_cos((_S670))));
    float _S674 = environmentPdf_0(_S673);
    float3  _S675 = skyBSDF(ray_0->unit_direction, _S673, *surface_2, eta_2, is_inside_3, _S674, lobe_state_0);
    bool _S676 = !(_S674 > 0.0f);
    bool _S677;
    if(_S676)
    {
        _S677 = true;
    }
    else
    {
        _S677 = all_1(_S675 == make_float3 (0.0f));
    }
    if(_S677)
    {
        float3  _S678 = make_float3 (0.0f);
        return SkySample_x24init_0(_S673, _S678, _S678, _S664.state);
    }
    float3  _S679 = skyRadiance_0(ray_0->origin, surface_2, is_inside_3, _S673, context_2, _S664.state);
    return SkySample_x24init_0(_S673, _S679, _S675 * _S679, _S664.state);
}

struct TreeSample
{
    float3  dir;
    float3  radiance;
    float density;
    uint random_state;
};

static __device__ float3  hairLight_0(FKSurface * surface_3, float3  in_dir_4, TreeSample * light_1, bool competing_0)
{
    SampleBSDF _S680 = (fcptConnectHair((surface_3->hair), ((&surface_3->material)->albedo), ((&surface_3->material)->specular_tint), (in_dir_4), (light_1->dir)));
    float3  _S681 = _S680.throughput * make_float3 (_S680.pdf);
    float _S682 = light_1->density;
    float _S683 = 1.0f + _S680.pdf * _S680.pdf / (light_1->density * light_1->density);
    bool _S684;
    if(competing_0)
    {
        _S684 = _S682 > 0.0f;
    }
    else
    {
        _S684 = false;
    }
    float _S685 = _slang_select(_S684, _S683,1.0f);
    return _S681 / make_float3 (_S685) * light_1->radiance;
}

static __device__ TreeSample TreeSample_x24init_0(float3  dir_6, float3  radiance_1, float density_0, uint random_state_8)
{
    TreeSample _S686;
    (&_S686)->dir = dir_6;
    (&_S686)->radiance = radiance_1;
    (&_S686)->density = density_0;
    (&_S686)->random_state = random_state_8;
    return _S686;
}

__device__ uint pickChild(LightNode first_1, LightNode second_1, float3  p_11, float3  normal_3, float * pick_0, float * probability_3)
{
    float _S687 = importance(first_1, p_11, normal_3);
    float _S688 = importance(second_1, p_11, normal_3);
    float2  _S689 = make_float2 (_S687, _S688);
    bool _S690 = _S687 == 0.0f;
    bool _S691;
    if(_S690)
    {
        _S691 = _S688 == 0.0f;
    }
    else
    {
        _S691 = false;
    }
    if(_S691)
    {
        return 2U;
    }
    float _S692 = _S687 + _S688;
    bool _S693 = _S688 > 0.0f;
    if(_S693)
    {
        _S691 = (*pick_0 * _S692) >= _S687;
    }
    else
    {
        _S691 = false;
    }
    uint _S694 = uint(_S691);
    float _S695 = (F32_min(((*pick_0 * _S692 - float(_S694) * _S687) / _slang_vector_get_element(_S689, _S694)), (0.99999994039535522f)));
    *pick_0 = _S695;
    float _S696 = *probability_3 * (_slang_vector_get_element(_S689, _S694) / _S692);
    *probability_3 = _S696;
    return _S694;
}

__device__ float3  sampleSphere(float3  center_1, float radius_1, float3  p_12, float u1_0, float u2_0)
{
    float3  _S697 = center_1 - p_12;
    float _S698 = radius_1 * radius_1 / dot_0(_S697, _S697);
    float _S699 = u1_0 * _S698 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S698), (0.0f)))))));
    float _S700 = 2.0f * u1_0;
    bool _S701 = _S698 >= 1.0f;
    float _S702 = _slang_select(_S701, _S700,_S699);
    float _S703 = (F32_sqrt(((F32_max((_S702 * (2.0f - _S702)), (0.0f))))));
    float _S704 = 6.28318548202514648f * u2_0;
    float3  _S705 = make_float3 (_S703 * (F32_cos((_S704))), 1.0f - _S702, _S703 * (F32_sin((_S704))));
    float3  _S706 = ((((_S697)) * make_float3(rnorm3df(((_S697)).x, ((_S697)).y, ((_S697)).z))));
    float3  _S707 = tangentToWorld(_S705, _S706);
    return _S707;
}

__device__ float3  pointLightRadiance(float3  color_1, float intensity_0, float radius_2)
{
    return color_1 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_2 * radius_2);
}

static __device__ float raySphere_0(float3  center_2, float radius_3, FKRay * ray_1, float max_len_0)
{
    float3  _S708 = center_2 - ray_1->origin;
    float _S709 = dot_0(_S708, ray_1->unit_direction);
    float _S710 = dot_0(_S708, _S708) - _S709 * _S709;
    float _S711 = radius_3 * radius_3;
    bool _S712 = _S710 > _S711;
    if(_S712)
    {
        return 4.294967296e+09f;
    }
    float _S713 = (F32_sqrt((_S711 - _S710)));
    float _S714 = _S709 - _S713;
    float _S715 = _S709 + _S713;
    bool _S716 = _S714 > 0.0000152587890625f;
    bool _S717;
    if(_S716)
    {
        _S717 = _S714 < max_len_0;
    }
    else
    {
        _S717 = false;
    }
    if(_S717)
    {
        return _S714;
    }
    bool _S718 = _S715 > 0.0000152587890625f;
    if(_S718)
    {
        _S717 = _S715 < max_len_0;
    }
    else
    {
        _S717 = false;
    }
    if(_S717)
    {
        return _S715;
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
        int i_6 = int(0);
        float sum_0 = 0.0f;
        for(;;)
        {
            if(i_6 < int(3))
            {
            }
            else
            {
                break;
            }
            float sum_1 = sum_0 + _slang_vector_get_element(left_1, i_6) * _slang_vector_get_element(right_1.rows[i_6], j_1);
            i_6 = i_6 + int(1);
            sum_0 = sum_1;
        }
        *_slang_vector_get_element_ptr(&result_5, j_1) = sum_0;
        j_1 = j_1 + int(1);
    }
    return result_5;
}

static __device__ __forceinline__ TreeSample sampleLightTree_0(float3  origin_4, float3  smooth_n_2, float3  geometry_n_1, float geometry_offset_1, bool sided_0, uint init_random_state_1, ShadowContext * context_3)
{
    Random _S719 = pcg(init_random_state_1);
    Random _S720 = pcg(_S719.state);
    Random _S721 = pcg(_S720.state);
    float3  _S722 = make_float3 (0.0f);
    TreeSample _S723 = TreeSample_x24init_0(_S722, _S722, 0.0f, _S721.state);
    TreeSample sample_1 = _S723;
    float3  _S724 = _slang_select(sided_0, _S722,smooth_n_2);
    float3  _S725 = origin_4 + make_float3 (geometry_offset_1) * smooth_n_2;
    float pick_1 = _S719.value;
    float probability_4 = 1.0f;
    uint n_11 = 0U;
    for(;;)
    {
        uint4  _S726 = (fcptLightNode((n_11)));
        if((_S726.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S727 = (fcptLightSecond((n_11)));
        uint _S728 = n_11 + 1U;
        LightNode _S729 = (fcptLightBounds((_S728)));
        LightNode _S730 = (fcptLightBounds((_S727)));
        uint _S731 = pickChild(_S729, _S730, origin_4, _S724, &pick_1, &probability_4);
        bool _S732 = _S731 > 1U;
        if(_S732)
        {
            return sample_1;
        }
        bool _S733 = _S731 == 1U;
        uint _S734 = _slang_select(_S733, _S727,_S728);
        n_11 = _S734;
    }
    bool _S735 = n_11 == 0U;
    bool _S736;
    if(_S735)
    {
        LightNode _S737 = (fcptLightBounds((0U)));
        float _S738 = importance(_S737, origin_4, _S724);
        _S736 = !(_S738 > 0.0f);
    }
    else
    {
        _S736 = false;
    }
    if(_S736)
    {
        return sample_1;
    }
    uint4  _S739 = (fcptLightNode((n_11)));
    FKHit _S740 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    bool _S741 = (_S739.x) == 2U;
    float3  emitter_point_0;
    float3  lift_n_0;
    float3  shadow_1;
    FKHit emitter_0;
    if(_S741)
    {
        FKLight _S742 = (fcptLight((_S739.y)));
        if(sided_0)
        {
            float _S743 = sign_0(dot_0(geometry_n_1, _S742.position - origin_4));
            float3  lift_n_1 = smooth_n_2 * make_float3 (_S743);
            float3  _S744 = origin_4 + make_float3 (geometry_offset_1) * lift_n_1;
            emitter_point_0 = _S744;
            lift_n_0 = lift_n_1;
        }
        else
        {
            emitter_point_0 = _S725;
            lift_n_0 = smooth_n_2;
        }
        bool _S745 = (_S742.variance) == 0.0f;
        if(_S745)
        {
            float3  _S746 = _S742.position - emitter_point_0;
            float3  _S747 = ((((_S746)) * make_float3(rnorm3df(((_S746)).x, ((_S746)).y, ((_S746)).z))));
            (&sample_1)->dir = _S747;
            float3  _S748 = _S742.color * make_float3 (_S742.intensity) / make_float3 (dot_0(_S746, _S746) * probability_4);
            (&sample_1)->radiance = _S748;
            shadow_1 = _S746;
        }
        else
        {
            float3  _S749 = sampleSphere(_S742.position, _S742.variance, emitter_point_0, _S720.value, _S721.value);
            (&sample_1)->dir = _S749;
            float _S750 = sphereDensity(_S742.position, _S742.variance, emitter_point_0);
            float _S751 = probability_4 * _S750;
            (&sample_1)->density = _S751;
            float3  _S752 = pointLightRadiance(_S742.color, _S742.intensity, _S742.variance);
            float3  _S753 = _S752 / make_float3 ((&sample_1)->density);
            (&sample_1)->radiance = _S753;
            FKRay _S754 = Ray_x24init_0(emitter_point_0, (&sample_1)->dir);
            float _S755 = raySphere_0(_S742.position, _S742.variance, &_S754, 4.294967296e+09f);
            float3  _S756 = (&sample_1)->dir * make_float3 (_S755);
            shadow_1 = _S756;
        }
        emitter_0 = _S740;
        emitter_point_0 = _S722;
    }
    else
    {
        uint _S757 = _S739.y;
        uint _S758 = (fcptTriangleOffset((_S757)));
        uint _S759 = _S758 + _S739.z;
        Matrix<float, 3, 3>  _S760 = (fcptWorldTriangle((_S757), (_S759)));
        float _S761 = (F32_sqrt((_S720.value)));
        float2  _S762 = make_float2 (_S761 * (1.0f - _S721.value), _S761 * _S721.value);
        float3  _S763 = mul_0(make_float3 (1.0f - _S761, _S762.x, _S762.y), _S760);
        if(sided_0)
        {
            float _S764 = sign_0(dot_0(geometry_n_1, _S763 - origin_4));
            float3  lift_n_2 = smooth_n_2 * make_float3 (_S764);
            float3  _S765 = origin_4 + make_float3 (geometry_offset_1) * lift_n_2;
            emitter_point_0 = _S765;
            lift_n_0 = lift_n_2;
        }
        else
        {
            bool _S766 = !((dot_0(smooth_n_2, _S763 - origin_4)) > 0.0f);
            if(_S766)
            {
                return sample_1;
            }
            emitter_point_0 = _S725;
            lift_n_0 = smooth_n_2;
        }
        FKHit emitter_1 = Hit_x24init_0(_S762, _S757, _S759, 0U, 0.0f);
        float3  _S767 = _S763 - emitter_point_0;
        float3  _S768 = ((((_S767)) * make_float3(rnorm3df(((_S767)).x, ((_S767)).y, ((_S767)).z))));
        (&sample_1)->dir = _S768;
        float _S769 = solidAngle(probability_4, cross_0(_S760.rows[int(1)] - _S760.rows[int(0)], _S760.rows[int(2)] - _S760.rows[int(0)]), _S767);
        (&sample_1)->density = _S769;
        bool _S770 = (fcptShadowFirst());
        bool _S771 = !_S770;
        if(_S771)
        {
            FKSurface _S772 = (fcptLightSurfaceAt((emitter_1), (_S763), (_S721.state), ((&sample_1)->dir), (context_3->depth), (length_0(_S763 - origin_4))));
            (&sample_1)->random_state = _S772.random_state;
            float3  _S773 = _slang_select(_S772.skip, _S722,_S772.material.emissive);
            float3  _S774 = _S773 / make_float3 ((&sample_1)->density);
            (&sample_1)->radiance = _S774;
        }
        shadow_1 = _S767;
        emitter_0 = emitter_1;
        emitter_point_0 = _S763;
    }
    FKHit _S775 = emitter_0;
    float3  _S776 = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, context_3, _S721.state, &_S775);
    bool _S777 = (fcptShadowFirst());
    if(_S777)
    {
        _S736 = (emitter_0.instance_index) != 4294967295U;
    }
    else
    {
        _S736 = false;
    }
    if(_S736)
    {
        _S736 = !all_1(_S776 == _S722);
    }
    else
    {
        _S736 = false;
    }
    if(_S736)
    {
        FKSurface _S778 = (fcptLightSurfaceAt((emitter_0), (emitter_point_0), (_S721.state), ((&sample_1)->dir), (context_3->depth), (length_0(emitter_point_0 - origin_4))));
        (&sample_1)->random_state = _S778.random_state;
        float3  _S779 = _slang_select(_S778.skip, _S722,_S778.material.emissive);
        float3  _S780 = _S779 / make_float3 ((&sample_1)->density);
        (&sample_1)->radiance = _S780;
    }
    float3  _S781 = (&sample_1)->radiance * _S776;
    bool _S782 = all_1(_S776 == _S722);
    float3  _S783 = _slang_select(_S782, _S722,_S781);
    (&sample_1)->radiance = _S783;
    return sample_1;
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
    float _S784 = 1.0f / (1.0f + b_3 / a_7 * (b_3 / a_7));
    bool _S785 = b_3 > 0.0f;
    float _S786 = _slang_select(_S785, _S784,1.0f);
    return _S786;
}

static __device__ float emissionWeight_0(NEEVertex * vertex_0, FKHit * hit_1, float3  light_point_1)
{
    bool _S787 = vertex_0->none;
    if(_S787)
    {
        return 1.0f;
    }
    uint _S788 = (fcptLightSlot((*hit_1)));
    float _S789 = lightPdf_0(vertex_0->origin, vertex_0->smooth_n, vertex_0->start, _S788, light_point_1);
    float _S790 = powerHeuristic(vertex_0->pdf, _S789);
    return _S790;
}

static __device__ float3  environment_0(float3  dir_7, uint depth_0, uint lobe_8)
{
    uint2  _S791 = (fcptEnvironmentMapSize());
    bool _S792 = (_S791.x) > 1U;
    bool _S793;
    if(_S792)
    {
        uint2  _S794 = (fcptEnvironmentMapSize());
        _S793 = (_S794.y) > 1U;
    }
    else
    {
        _S793 = false;
    }
    if(_S793)
    {
        float3  _S795 = (fcptEnvMapSample((dir_7), (depth_0), (lobe_8)));
        return _S795;
    }
    float3  _S796 = (fcptAmbient());
    return _S796;
}

static __device__ bool environmentMapped_0()
{
    uint2  _S797 = (fcptEnvironmentCdfSize());
    bool _S798 = (_S797.x) > 1U;
    bool _S799;
    if(_S798)
    {
        uint2  _S800 = (fcptEnvironmentCdfSize());
        _S799 = (_S800.y) > 1U;
    }
    else
    {
        _S799 = false;
    }
    bool _S801 = !_S799;
    if(_S801)
    {
        return false;
    }
    uint2  _S802 = (fcptEnvironmentMapSize());
    bool _S803 = (_S802.x) > 1U;
    if(_S803)
    {
        uint2  _S804 = (fcptEnvironmentMapSize());
        _S799 = (_S804.y) > 1U;
    }
    else
    {
        _S799 = false;
    }
    return _S799;
}

static __device__ float escapeWeight_0(float pdf_3, float3  dir_8)
{
    bool _S805 = pdf_3 <= 0.0f;
    bool _S806;
    if(_S805)
    {
        _S806 = true;
    }
    else
    {
        bool _S807 = environmentMapped_0();
        _S806 = !_S807;
    }
    if(_S806)
    {
        return 1.0f;
    }
    float _S808 = environmentPdf_0(dir_8);
    return pdf_3 / (pdf_3 + _S808);
}

static __device__ float3  min_1(float3  x_15, float3  y_4)
{
    float3  result_6;
    int i_7 = int(0);
    for(;;)
    {
        if(i_7 < int(3))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_6, i_7) = (F32_min((_slang_vector_get_element(x_15, i_7)), (_slang_vector_get_element(y_4, i_7))));
        i_7 = i_7 + int(1);
    }
    return result_6;
}

static __device__ void restir_duplicates_0(uint3  global_invocation_id_1, uint3  local_invocation_id_0, uint local_invocation_index_3)
{
    uint2  _S809 = uint2 {global_invocation_id_1.x, global_invocation_id_1.y};
    int2  _S810 = make_int2 ((int)_S809.x, (int)_S809.y);
    uint _S811 = previousSeed_0(_S810);
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
            uint _S812 = previousSeed_0(_S810 + make_int2 (x_16, y_5));
            bool _S813 = _S812 == _S811;
            uint _S814 = _slang_select(_S813, 1U,0U);
            uint count_3 = count_2 + _S814;
            int x_17 = x_16 + int(1);
            x_16 = x_17;
            count_2 = count_3;
        }
        int y_6 = y_5 + int(1);
        y_5 = y_6;
    }
    float _S815 = float(count_2 - 1U) / 288.0f;
    bool _S816 = _S811 != 0U;
    float _S817 = _slang_select(_S816, _S815,0.0f);
    fcptStoreDuplication((_S810), (make_uint4 ((F32_asuint((_S817))), 0U, 0U, 0U)));
    return;
}

__device__ uint stream(uint seed_3, uint index_0)
{
    uint _S818 = hash(index_0);
    uint _S819 = hash(seed_3 ^ _S818);
    return _S819;
}

static __device__ float4  asfloat_0(uint4  x_18)
{
    float4  result_7;
    int i_8 = int(0);
    for(;;)
    {
        if(i_8 < int(4))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_7, i_8) = (U32_asfloat((_slang_vector_get_element(x_18, i_8))));
        i_8 = i_8 + int(1);
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
    float _S820 = rgb_to_greyscale(weight_0);
    bool _S821 = _S820 > 0.0f;
    bool _S822;
    if(_S821)
    {
        _S822 = _S820 < 3.00000000549775576e+38f;
    }
    else
    {
        _S822 = false;
    }
    bool _S823 = !_S822;
    if(_S823)
    {
        return;
    }
    bool _S824 = sel_2->sums;
    if(_S824)
    {
        float3  _S825 = sel_2->color + weight_0;
        sel_2->color = _S825;
        return;
    }
    float _S826 = sel_2->w_sum + _S820;
    sel_2->w_sum = _S826;
    float3  _S827 = sel_2->color + weight_0;
    sel_2->color = _S827;
    Random _S828 = pcg(sel_2->random_state);
    sel_2->random_state = _S828.state;
    bool _S829 = (_S828.value * sel_2->w_sum) <= _S820;
    if(_S829)
    {
        sel_2->r = candidate_0;
    }
    return;
}

__device__ void offerShifted(Selection * sel_3, Reservoir r_7, Shift shifted_0, float mis_0)
{
    Reservoir candidate_1 = r_7;
    float3  _S830 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_1)->f = _S830;
    float _S831 = r_7.jac * shifted_0.jac;
    (&candidate_1)->jac = _S831;
    offer(sel_3, candidate_1, make_float3 (mis_0) * shifted_0.f * make_float3 (r_7.w));
    return;
}

__device__ Reservoir finalize(Selection sel_4, float c_1)
{
    Reservoir r_8 = sel_4.r;
    float _S832 = rgb_to_greyscale((&r_8)->f);
    float _S833 = sel_4.w_sum / _S832;
    bool _S834 = _S832 > 0.0f;
    float _S835 = _slang_select(_S834, _S833,0.0f);
    (&r_8)->w = _S835;
    (&r_8)->c = c_1;
    return r_8;
}

static __device__ uint2  asuint_0(float2  x_19)
{
    uint2  result_8;
    int i_9 = int(0);
    for(;;)
    {
        if(i_9 < int(2))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_8, i_9) = (F32_asuint((_slang_vector_get_element(x_19, i_9))));
        i_9 = i_9 + int(1);
    }
    return result_8;
}

static __device__ void restir_spatial_0(uint3  global_invocation_id_2)
{
    uint2  _S836 = uint2 {global_invocation_id_2.x, global_invocation_id_2.y};
    int2  _S837 = make_int2 ((int)_S836.x, (int)_S836.y);
    float3  _S838 = make_float3 (0.0f);
    FKHit _S839 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S840 = Domain_x24init_0(_S838, _S838, &_S839, 0.0f, 0.0f);
    Domain dom_4 = _S840;
    bool _S841 = (fcptCurrentDomain((_S837), (&dom_4)));
    bool _S842 = !_S841;
    if(_S842)
    {
        Reservoir _S843 = (Reservoir{});
        fcptStoreReservoirPrevious((_S837), (_S843), ((&dom_4)->hit));
        return;
    }
    Reservoir _S844 = (fcptLoadReservoirTemporal((_S837)));
    uint t_14 = 0U;
    float count_4 = 0.0f;
    float c_sum_1 = _S844.c;
    for(;;)
    {
        uint _S845 = (fcptRestirNeighbours());
        if(t_14 < _S845)
        {
        }
        else
        {
            break;
        }
        int2  _S846 = partner_0(_S837, t_14);
        Domain neighbor_0 = _S840;
        bool _S847 = (fcptCurrentDomain((_S846), (&neighbor_0)));
        if(_S847)
        {
            float count_5 = count_4 + 1.0f;
            uint4  _S848 = (fcptReservoirTemporal((_S846), (0U)));
            float c_sum_2 = c_sum_1 + (U32_asfloat((_S848.w)));
            count_4 = count_5;
            c_sum_1 = c_sum_2;
        }
        uint t_15 = t_14 + 1U;
        t_14 = t_15;
    }
    float _S849 = _S844.c / (F32_max((count_4), (1.0f)));
    float _S850 = rgb_to_greyscale(_S844.f);
    bool _S851 = count_4 == 0.0f;
    float _S852 = _slang_select(_S851, 1.0f,0.0f);
    Selection _S853 = (Selection{});
    Selection sel_5 = _S853;
    uint _S854 = (fcptFrame());
    uint _S855 = hash(_S854);
    uint _S856 = global_invocation_id_2.x;
    uint2  _S857 = (fcptRenderSize());
    uint _S858 = stream(_S855, _S856 + _S857.x * global_invocation_id_2.y);
    uint _S859 = stream(_S858, 195U);
    (&sel_5)->random_state = _S859;
    t_14 = 0U;
    float canonical_mis_0 = _S852;
    for(;;)
    {
        uint _S860 = (fcptRestirNeighbours());
        if(t_14 < _S860)
        {
        }
        else
        {
            break;
        }
        int2  _S861 = partner_0(_S837, t_14);
        Domain neighbor_dom_0 = _S840;
        bool _S862 = (fcptCurrentDomain((_S861), (&neighbor_dom_0)));
        if(_S862)
        {
            Reservoir _S863 = (fcptLoadReservoirTemporal((_S861)));
            uint4  _S864 = (fcptShiftData((_S861), (t_14)));
            float4  _S865 = asfloat_0(_S864);
            uint4  _S866 = (fcptShiftData((_S837), (t_14)));
            float4  _S867 = asfloat_0(_S866);
            float _S868 = pairShare(_S863.c, _S849, c_sum_1);
            bool _S869 = _S850 > 0.0f;
            float canonical_mis_1;
            if(_S869)
            {
                float _S870 = rgb_to_greyscale(float3 {_S867.x, _S867.y, _S867.z});
                float _S871 = canonicalWeight(_S868, _S849, _S850, _S863.c, _S870);
                float canonical_mis_2 = canonical_mis_0 + _S871;
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            float3  _S872 = float3 {_S865.x, _S865.y, _S865.z};
            Shift _S873 = Shift_x24init_0(_S872, _S865.w);
            float _S874 = rgb_to_greyscale(_S863.f);
            float _S875 = rgb_to_greyscale(_S872);
            float _S876 = neighborWeight(_S868, _S863.c, _S874, _S849, _S875);
            offerShifted(&sel_5, _S863, _S873, _S876);
            canonical_mis_0 = canonical_mis_1;
        }
        uint t_16 = t_14 + 1U;
        t_14 = t_16;
    }
    offerShifted(&sel_5, _S844, Shift_x24init_0(_S844.f, 1.0f), canonical_mis_0);
    Reservoir _S877 = finalize(sel_5, c_sum_1);
    fcptStoreReservoirPrevious((_S837), (_S877), ((&dom_4)->hit));
    fcptStorePreviousLayer((_S837), (5U), (make_uint4 (asuint_0((&(&dom_4)->hit)->uv).x, asuint_0((&(&dom_4)->hit)->uv).y, 0U, 0U)));
    fcptAddColor((_S837), (make_float4 ((&sel_5)->color.x, (&sel_5)->color.y, (&sel_5)->color.z, 0.0f)));
    return;
}

static __device__ uint3  asuint_1(float3  x_20)
{
    uint3  result_9;
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
        *_slang_vector_get_element_ptr(&result_9, i_10) = (F32_asuint((_slang_vector_get_element(x_20, i_10))));
        i_10 = i_10 + int(1);
    }
    return result_9;
}

static __device__ void restir_shift_0(uint3  workgroup_id_1, uint local_invocation_index_4)
{
    uint _S878 = queuedShift_0(workgroup_id_1, local_invocation_index_4);
    bool _S879 = _S878 != 4294967295U;
    if(_S879)
    {
        uint2  _S880 = make_uint2 (_S878, _S878 >> 14U) & make_uint2 (16383U);
        int2  _S881 = make_int2 ((int)_S880.x, (int)_S880.y);
        ShiftJob _S882 = (ShiftJob{});
        ShiftJob shift_job_0 = _S882;
        Shift _S883 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
        uint _S884 = _S878 >> 28U;
        bool _S885 = spatialJob_0(_S881, _S884, &shift_job_0, true);
        Shift shifted_1;
        if(_S885)
        {
            Domain _S886 = (&shift_job_0)->dom;
            Reservoir _S887 = (&shift_job_0)->r;
            Shift _S888 = passShift_0(&_S886, &_S887);
            shifted_1 = _S888;
        }
        else
        {
            shifted_1 = _S883;
        }
        fcptStoreShiftData((_S881), (_S884), (make_uint4 (asuint_1(shifted_1.f).x, asuint_1(shifted_1.f).y, asuint_1(shifted_1.f).z, (F32_asuint((shifted_1.jac))))));
    }
    return;
}

static __device__ void restir_prepass_0(uint3  global_invocation_id_3, uint local_invocation_index_5)
{
    uint2  _S889 = uint2 {global_invocation_id_3.x, global_invocation_id_3.y};
    int2  _S890 = make_int2 ((int)_S889.x, (int)_S889.y);
    FixedArray<uint, 3>  _S891;
    spatialBins_0(_S890, &_S891);
    FixedArray<uint, 3>  _S892 = _S891;
    uint t_17 = 0U;
    for(;;)
    {
        if(t_17 < 3U)
        {
        }
        else
        {
            break;
        }
        bool _S893 = (_S892[t_17]) == 40U;
        if(_S893)
        {
            fcptStoreShiftData((_S890), (t_17), (make_uint4 (0U)));
        }
        uint t_18 = t_17 + 1U;
        t_17 = t_18;
    }
    FixedArray<uint, 3>  _S894 = _S892;
    queueShifts_0(_S890, &_S894, global_invocation_id_3, local_invocation_index_5);
    return;
}

static __device__ void restir_count_0(uint3  global_invocation_id_4, uint local_invocation_index_6)
{
    uint2  _S895 = uint2 {global_invocation_id_4.x, global_invocation_id_4.y};
    int2  _S896 = make_int2 ((int)_S895.x, (int)_S895.y);
    FixedArray<uint, 3>  _S897;
    spatialBins_0(_S896, &_S897);
    FixedArray<uint, 3>  _S898 = _S897;
    countShifts_0(&_S898, local_invocation_index_6);
    return;
}

static __device__ void restir_temporal_shift_0(uint3  workgroup_id_2, uint local_invocation_index_7)
{
    uint _S899 = queuedShift_0(workgroup_id_2, local_invocation_index_7);
    bool _S900 = _S899 != 4294967295U;
    if(_S900)
    {
        uint2  _S901 = make_uint2 (_S899, _S899 >> 14U) & make_uint2 (16383U);
        int2  _S902 = make_int2 ((int)_S901.x, (int)_S901.y);
        ShiftJob _S903 = (ShiftJob{});
        ShiftJob shift_job_1 = _S903;
        Shift _S904 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
        uint _S905 = _S899 >> 28U;
        bool _S906 = temporalJob_0(_S902, _S905, &shift_job_1, true);
        Shift shifted_2;
        if(_S906)
        {
            if(_S905 == 1U)
            {
                Shift _S907 = (fcptShiftPrevious(((&shift_job_1)->dom), ((&shift_job_1)->r)));
                shifted_2 = _S907;
            }
            else
            {
                Domain _S908 = (&shift_job_1)->dom;
                Reservoir _S909 = (&shift_job_1)->r;
                Shift _S910 = passShift_0(&_S908, &_S909);
                shifted_2 = _S910;
            }
        }
        else
        {
            shifted_2 = _S904;
        }
        fcptStoreTemporalShift((_S902), (_S905), (make_uint4 (asuint_1(shifted_2.f).x, asuint_1(shifted_2.f).y, asuint_1(shifted_2.f).z, (F32_asuint((shifted_2.jac))))));
    }
    return;
}

static __device__ void restir_temporal_prepass_0(uint3  global_invocation_id_5, uint local_invocation_index_8)
{
    uint2  _S911 = uint2 {global_invocation_id_5.x, global_invocation_id_5.y};
    int2  _S912 = make_int2 ((int)_S911.x, (int)_S911.y);
    FixedArray<uint, 3>  _S913;
    temporalBins_0(_S912, &_S913);
    FixedArray<uint, 3>  _S914 = _S913;
    uint t_19 = 0U;
    for(;;)
    {
        if(t_19 < 2U)
        {
        }
        else
        {
            break;
        }
        bool _S915 = (_S914[t_19]) == 40U;
        if(_S915)
        {
            fcptStoreTemporalShift((_S912), (t_19), (make_uint4 (0U)));
        }
        uint t_20 = t_19 + 1U;
        t_19 = t_20;
    }
    FixedArray<uint, 3>  _S916 = _S914;
    queueShifts_0(_S912, &_S916, global_invocation_id_5, local_invocation_index_8);
    return;
}

static __device__ void restir_temporal_count_0(uint3  global_invocation_id_6, uint local_invocation_index_9)
{
    uint2  _S917 = uint2 {global_invocation_id_6.x, global_invocation_id_6.y};
    int2  _S918 = make_int2 ((int)_S917.x, (int)_S917.y);
    bool _S919 = (fcptSceneUnchanged());
    bool _S920 = !_S919;
    bool _S921;
    if(_S920)
    {
        uint2  _S922 = (fcptRenderSize());
        int2  _S923 = make_int2 ((int)_S922.x, (int)_S922.y);
        _S921 = all_0(_S918 < _S923);
    }
    else
    {
        _S921 = false;
    }
    if(_S921)
    {
        Reservoir _S924 = (fcptLoadReservoirInitial((_S918)));
        int2  _S925 = sampleNeighbor_0(_S918, _S924.seed);
        fcptStoreTemporalNeighbor((_S918), (_S925));
    }
    FixedArray<uint, 3>  _S926;
    temporalBins_0(_S918, &_S926);
    FixedArray<uint, 3>  _S927 = _S926;
    countShifts_0(&_S927, local_invocation_index_9);
    return;
}

static __device__ float interpolate_0(float a_8, float b_4, float t_21)
{
    return a_8 + (b_4 - a_8) * t_21;
}

__device__ float confidenceCap(float duplicated_0)
{
    float _S928 = interpolate_0(20.0f, 1.0f, (F32_pow((duplicated_0), (0.10000000149011612f))));
    return _S928;
}

__device__ float2  temporalWeights(float c_2, float p_c_1, float c_t_0, float p_t_0, float g_previous_0, float g_current_0)
{
    float _S929 = c_2 * p_c_1;
    float _S930 = c_t_0 * p_t_0;
    return make_float2 (_S929 / (_S929 + c_t_0 * g_previous_0), _S930 / (_S930 + c_2 * g_current_0));
}

static __device__ void restir_temporal_0(uint3  global_invocation_id_7)
{
    uint2  _S931 = uint2 {global_invocation_id_7.x, global_invocation_id_7.y};
    int2  _S932 = make_int2 ((int)_S931.x, (int)_S931.y);
    float3  _S933 = make_float3 (0.0f);
    FKHit _S934 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S935 = Domain_x24init_0(_S933, _S933, &_S934, 0.0f, 0.0f);
    Domain dom_5 = _S935;
    bool _S936 = (fcptCurrentDomain((_S932), (&dom_5)));
    bool _S937 = !_S936;
    if(_S937)
    {
        Reservoir _S938 = (Reservoir{});
        fcptStoreReservoirTemporal((_S932), (_S938), ((&dom_5)->hit));
        return;
    }
    Reservoir _S939 = (fcptLoadReservoirInitial((_S932)));
    bool _S940 = (fcptSceneUnchanged());
    int2  _S941;
    if(_S940)
    {
        int2  _S942 = sampleNeighbor_0(_S932, _S939.seed);
        _S941 = _S942;
    }
    else
    {
        int2  _S943 = (fcptLoadTemporalNeighbor((_S932)));
        _S941 = _S943;
    }
    bool _S944 = (_S941.x) >= int(0);
    Reservoir r_9;
    if(_S944)
    {
        Reservoir _S945 = (fcptLoadReservoirPrevious((_S941)));
        uint4  _S946 = (fcptDuplication((_S941)));
        float _S947 = (U32_asfloat((_S946.x)));
        uint _S948 = (fcptRestirDecorrelation());
        bool _S949 = _S948 == 1U;
        float _S950 = _slang_select(_S949, _S947,0.0f);
        float _S951 = confidenceCap(_S950);
        float _S952 = (F32_min((_S945.c), (_S951)));
        bool _S953 = (fcptSceneUnchanged());
        float4  _S954;
        if(_S953)
        {
            _S954 = make_float4 (_S945.f.x, _S945.f.y, _S945.f.z, 1.0f);
        }
        else
        {
            uint4  _S955 = (fcptTemporalShift((_S932), (0U)));
            _S954 = asfloat_0(_S955);
        }
        Domain own_1 = _S935;
        bool _S956;
        if(_S953)
        {
            _S956 = true;
        }
        else
        {
            bool _S957 = (fcptPreviousScenes());
            bool _S958 = !_S957;
            if(_S958)
            {
                _S956 = (_S939.w) > 0.0f;
            }
            else
            {
                _S956 = false;
            }
            if(_S956)
            {
                bool _S959 = (fcptStoredDomainInitial((_S932), (_S939.seed), (&own_1)));
                _S956 = _S959;
            }
            else
            {
                _S956 = false;
            }
            if(_S956)
            {
                Domain _S960 = (fcptPreviousDomain((_S941), (_S939.seed)));
                Domain _S961 = _S960;
                Domain _S962 = own_1;
                bool _S963 = sameDomain_0(&_S961, &_S962);
                _S956 = _S963;
            }
            else
            {
                _S956 = false;
            }
        }
        float4  _S964;
        if(_S956)
        {
            _S964 = make_float4 (_S939.f.x, _S939.f.y, _S939.f.z, 1.0f);
        }
        else
        {
            uint4  _S965 = (fcptTemporalShift((_S932), (1U)));
            _S964 = asfloat_0(_S965);
        }
        float _S966 = rgb_to_greyscale(_S939.f);
        float _S967 = rgb_to_greyscale(_S945.f);
        Selection _S968 = (Selection{});
        Selection sel_6 = _S968;
        uint _S969 = (fcptFrame());
        uint _S970 = hash(_S969);
        uint _S971 = global_invocation_id_7.x;
        uint2  _S972 = (fcptRenderSize());
        uint _S973 = stream(_S970, _S971 + _S972.x * global_invocation_id_7.y);
        uint _S974 = stream(_S973, 194U);
        (&sel_6)->random_state = _S974;
        float4  _S975 = _S964;
        float _S976 = rgb_to_greyscale(float3 {_S975.x, _S975.y, _S975.z});
        float4  _S977 = _S954;
        float3  _S978 = float3 {_S977.x, _S977.y, _S977.z};
        float _S979 = rgb_to_greyscale(_S978);
        float2  _S980 = temporalWeights(_S939.c, _S966, _S952, _S967, _S976, _S979);
        offerShifted(&sel_6, _S939, Shift_x24init_0(_S939.f, 1.0f), _S980.x);
        offerShifted(&sel_6, _S945, Shift_x24init_0(_S978, _S954.w), _S980.y);
        Reservoir _S981 = finalize(sel_6, _S939.c + _S952);
        r_9 = _S981;
    }
    else
    {
        r_9 = _S939;
    }
    fcptStoreReservoirTemporal((_S932), (r_9), ((&dom_5)->hit));
    return;
}

static __device__ void restir_initial_0(uint3  global_invocation_id_8)
{
    uint2  _S982 = uint2 {global_invocation_id_8.x, global_invocation_id_8.y};
    int2  _S983 = make_int2 ((int)_S982.x, (int)_S982.y);
    float3  _S984 = make_float3 (0.0f);
    float2  _S985 = make_float2 (0.0f);
    FKHit _S986 = Hit_x24init_0(_S985, 0U, 0U, 0U, 0.0f);
    Domain _S987 = Domain_x24init_0(_S984, _S984, &_S986, 0.0f, 0.0f);
    Domain dom_6 = _S987;
    bool _S988 = (fcptCurrentDomain((_S983), (&dom_6)));
    bool _S989 = !_S988;
    if(_S989)
    {
        Reservoir _S990 = (Reservoir{});
        fcptStoreReservoirInitial((_S983), (_S990), ((&dom_6)->hit));
        return;
    }
    uint _S991 = (fcptFrame());
    uint _S992 = hash(_S991);
    uint _S993 = global_invocation_id_8.x;
    uint2  _S994 = (fcptRenderSize());
    uint _S995 = stream(_S992, _S993 + _S994.x * global_invocation_id_8.y);
    Selection _S996 = (Selection{});
    Selection initial_0 = _S996;
    uint _S997 = stream(_S995, 193U);
    (&initial_0)->random_state = _S997;
    bool _S998 = (fcptRestirUsed());
    bool _S999 = !_S998;
    (&initial_0)->sums = _S999;
    uint _S1000 = stream(_S995, 0U);
    (&(&initial_0)->r)->seed = _S1000;
    FKHit _S1001 = Hit_x24init_0(_S985, 4294967295U, 0U, 0U, 0.0f);
    uint _S1002 = (fcptSamples());
    float _S1003 = 1.0f / float(_S1002);
    FKHit hit_2 = _S1001;
    uint i_11 = 0U;
    for(;;)
    {
        uint _S1004 = (fcptSamples());
        if(i_11 < _S1004)
        {
        }
        else
        {
            break;
        }
        Reservoir _S1005 = (Reservoir{});
        Reservoir r_10 = _S1005;
        uint _S1006 = stream(_S995, i_11);
        (&r_10)->seed = _S1006;
        Domain path_0 = _S987;
        bool _S1007 = (fcptStoredDomainInitial((_S983), ((&r_10)->seed), (&path_0)));
        bool _S1008 = !_S1007;
        if(_S1008)
        {
            fcptMissed((_S983), (path_0), (_S1003));
            uint i_12 = i_11 + 1U;
            i_11 = i_12;
            continue;
        }
        Domain _S1009 = path_0;
        Reservoir _S1010 = r_10;
        Shift _S1011 = passWalk_0(&_S1009, &_S1010, false, _S1003, &initial_0);
        bool _S1012 = ((&(&initial_0)->r)->seed) == ((&r_10)->seed);
        FKHit hit_3;
        if(_S1012)
        {
            FKHit _S1013 = (&path_0)->hit;
            hit_3 = _S1013;
        }
        else
        {
            hit_3 = hit_2;
        }
        hit_2 = hit_3;
        uint i_12 = i_11 + 1U;
        i_11 = i_12;
    }
    float3  _S1014 = (&initial_0)->glow;
    float3  _S1015 = (&initial_0)->color;
    bool _S1016 = (&initial_0)->sums;
    float3  _S1017 = _slang_select(_S1016, _S1015,_S984);
    fcptAddColor((_S983), (make_float4 ((_S1014 + _S1017).x, (_S1014 + _S1017).y, (_S1014 + _S1017).z, 1.0f)));
    Reservoir _S1018 = finalize(initial_0, 1.0f);
    fcptStoreReservoirInitial((_S983), (_S1018), (hit_2));
    return;
}

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_4, float3  origin_5, float3  smooth_n_3, float3  start_6)
{
    NEEVertex _S1019;
    (&_S1019)->none = none_0;
    (&_S1019)->pdf = pdf_4;
    (&_S1019)->origin = origin_5;
    (&_S1019)->smooth_n = smooth_n_3;
    (&_S1019)->start = start_6;
    return _S1019;
}

struct Vertex
{
    bool rough;
    uint lobe;
    float pdf;
    float cos;
    bool inside;
};

static __device__ Vertex Vertex_x24init_0(bool rough_0, uint lobe_9, float pdf_5, float cos_0, bool inside_0)
{
    Vertex _S1020;
    (&_S1020)->rough = rough_0;
    (&_S1020)->lobe = lobe_9;
    (&_S1020)->pdf = pdf_5;
    (&_S1020)->cos = cos_0;
    (&_S1020)->inside = inside_0;
    return _S1020;
}

static __device__ float freeFlight_0(float u_1, float sigma_0)
{
    return - (F32_log((1.0f - u_1))) / sigma_0;
}

static __device__ float3  exp_0(float3  x_21)
{
    float3  result_10;
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
        *_slang_vector_get_element_ptr(&result_10, i_13) = (F32_exp((_slang_vector_get_element(x_21, i_13))));
        i_13 = i_13 + int(1);
    }
    return result_10;
}

static __device__ float3  flightWeight_0(float3  scatter_0, float3  extinction_0, float sigma_1, float distance_2, bool scatters_0)
{
    float3  _S1021 = exp_0((make_float3 (sigma_1) - extinction_0) * make_float3 (distance_2));
    float3  _S1022 = scatter_0 * _S1021 / make_float3 (sigma_1);
    float3  _S1023 = _slang_select(scatters_0, _S1022,_S1021);
    return _S1023;
}

static __device__ bool scatterSampled_0(bool replay_1, uint b_5, uint stop_0, bool varying_0)
{
    bool _S1024 = !replay_1;
    bool _S1025;
    if(_S1024)
    {
        _S1025 = true;
    }
    else
    {
        bool _S1026 = b_5 == stop_0;
        if(_S1026)
        {
            _S1025 = !varying_0;
        }
        else
        {
            _S1025 = false;
        }
    }
    return _S1025;
}

static __device__ uint arrivalLobe_0(uint b_6, uint prev_lobe_0)
{
    bool _S1027 = b_6 > 0U;
    uint _S1028 = _slang_select(_S1027, prev_lobe_0,3U);
    return _S1028;
}

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_0, uint depth_1, uint lobe_10, bool surface_4, float length_2, float width_1, FKHit * own_2, bool fiber_0)
{
    ShadowContext _S1029;
    (&_S1029)->extinction_behind = extinction_behind_0;
    (&_S1029)->extinction_front = extinction_front_0;
    (&_S1029)->fillings = fillings_0;
    (&_S1029)->side = side_0;
    (&_S1029)->depth = depth_1;
    (&_S1029)->lobe = lobe_10;
    (&_S1029)->surface = surface_4;
    (&_S1029)->length = length_2;
    (&_S1029)->width = width_1;
    (&_S1029)->own = *own_2;
    (&_S1029)->fiber = fiber_0;
    return _S1029;
}

static __device__ float phaseHG_0(float g_0, float mu_2)
{
    bool _S1030 = (F32_abs((g_0))) < 0.00100000004749745f;
    if(_S1030)
    {
        return 0.07957746833562851f;
    }
    float _S1031 = g_0 * g_0;
    return (1.0f - _S1031) * 0.25f * 0.31830987334251404f / (F32_pow((1.0f + _S1031 - 2.0f * g_0 * mu_2), (1.5f)));
}

__device__ float3  safeDivide(float3  a_9, float3  b_7)
{
    float3  _S1032 = a_9 / b_7;
    float3  _S1033 = make_float3 (0.0f);
    bool3  _S1034 = b_7 == _S1033;
    float3  _S1035 = _slang_select(_S1034, _S1033,_S1032);
    return _S1035;
}

static __device__ uint insertBits_0(uint e_2, uint newbits_0, uint offset_1, uint count_6)
{
    uint _S1036 = (1U << count_6) - 1U;
    return (e_2 & (~(_S1036 << offset_1))) | ((newbits_0 & _S1036) << offset_1);
}

__device__ Reservoir withEnd(Reservoir r_11, uint end_type_0, uint end_0, float3  f_5)
{
    Reservoir candidate_2 = r_11;
    uint _S1037 = insertBits_0(r_11.path, end_0, 0U, 5U);
    uint _S1038 = insertBits_0(_S1037, end_type_0, 12U, 3U);
    (&candidate_2)->path = _S1038;
    (&candidate_2)->f = f_5;
    return candidate_2;
}

__device__ float survivalProbability(float3  throughput_1, float density_1)
{
    return (F32_min(((F32_max(((F32_max((throughput_1.x), ((F32_max((throughput_1.y), (throughput_1.z)))))) / density_1), (0.0f)))), (1.0f)));
}

static __device__ float3  isotropic_0(uint random_state_9)
{
    Random _S1039 = pcg(random_state_9);
    Random _S1040 = pcg(_S1039.state);
    float _S1041 = 1.0f - 2.0f * _S1039.value;
    float _S1042 = (F32_sqrt(((F32_max((1.0f - _S1041 * _S1041), (0.0f))))));
    float _S1043 = 6.28318548202514648f * _S1040.value;
    return make_float3 (_S1042 * (F32_cos((_S1043))), _S1042 * (F32_sin((_S1043))), _S1041);
}

static __device__ float3  samplePhase_0(float g_1, float3  dir_9, uint random_state_10, float * pdf_6)
{
    bool _S1044 = (F32_abs((g_1))) < 0.00100000004749745f;
    if(_S1044)
    {
        *pdf_6 = 0.07957746833562851f;
        float3  _S1045 = isotropic_0(random_state_10);
        return _S1045;
    }
    Random _S1046 = pcg(random_state_10);
    Random _S1047 = pcg(_S1046.state);
    float _S1048 = g_1 * g_1;
    float _S1049 = 2.0f * g_1;
    float _S1050 = (1.0f - _S1048) / (1.0f - g_1 + _S1049 * _S1046.value);
    float _S1051 = clamp_1((1.0f + _S1048 - _S1050 * _S1050) / _S1049, -1.0f, 1.0f);
    float _S1052 = (F32_sqrt(((F32_max((1.0f - _S1051 * _S1051), (0.0f))))));
    float _S1053 = 6.28318548202514648f * _S1047.value;
    float _S1054 = phaseHG_0(g_1, _S1051);
    *pdf_6 = _S1054;
    float3  _S1055 = tangentToWorld(make_float3 (_S1052 * (F32_cos((_S1053))), _S1051, _S1052 * (F32_sin((_S1053)))), dir_9);
    float3  _S1056 = ((((_S1055)) * make_float3(rnorm3df(((_S1055)).x, ((_S1055)).y, ((_S1055)).z))));
    return _S1056;
}

static __device__ Vertex scatteredVertex_0(bool is_inside_4)
{
    return Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_4);
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_0, float3  emissive_0, float roughness_0, float metallic_0, float transmission_0, float ior_0, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_2, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_2, float velvet_0, float3  toon_3)
{
    BSDFMaterial _S1057;
    (&_S1057)->albedo = albedo_0;
    (&_S1057)->emissive = emissive_0;
    (&_S1057)->roughness = roughness_0;
    (&_S1057)->metallic = metallic_0;
    (&_S1057)->transmission = transmission_0;
    (&_S1057)->ior = ior_0;
    (&_S1057)->absorption = absorption_0;
    (&_S1057)->specular_tint = specular_tint_0;
    (&_S1057)->specular_level = specular_level_0;
    (&_S1057)->translucent = translucent_0;
    (&_S1057)->sheen = sheen_2;
    (&_S1057)->sheen_roughness = sheen_roughness_0;
    (&_S1057)->anisotropy = anisotropy_0;
    (&_S1057)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S1057)->tangent = tangent_2;
    (&_S1057)->velvet = velvet_0;
    (&_S1057)->toon = toon_3;
    return _S1057;
}

static __device__ FKMedium Medium_x24init_0(float3  scatter_1, float3  extinction_1, float g_2)
{
    FKMedium _S1058;
    (&_S1058)->scatter = scatter_1;
    (&_S1058)->extinction = extinction_1;
    (&_S1058)->g = g_2;
    return _S1058;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_7, bool skip_0, uint random_state_11, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S1059;
    (&_S1059)->smooth_n = smooth_n_4;
    (&_S1059)->geometry_n = geometry_n_2;
    (&_S1059)->geometry_offset = geometry_offset_2;
    (&_S1059)->material = *material_7;
    (&_S1059)->skip = skip_0;
    (&_S1059)->random_state = random_state_11;
    (&_S1059)->coverage = coverage_0;
    (&_S1059)->encloses = encloses_0;
    (&_S1059)->volume = *volume_0;
    (&_S1059)->fills = fills_0;
    (&_S1059)->hair = hair_0;
    return _S1059;
}

static __device__ FKSurface emitting_0(FKSurface * surface_5, bool top_0)
{
    FKSurface lower_0 = *surface_5;
    float3  _S1060 = (&surface_5->material)->emissive;
    float3  _S1061 = make_float3 (0.0f);
    bool _S1062 = !top_0;
    float3  _S1063 = _slang_select(_S1062, _S1061,_S1060);
    (&(&lower_0)->material)->emissive = _S1063;
    return lower_0;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_6, float u_2)
{
    float _S1064 = surface_6->coverage;
    bool _S1065 = u_2 < _S1064;
    if(_S1065)
    {
        return *surface_6;
    }
    float3  _S1066 = make_float3 (0.0f);
    float3  _S1067 = make_float3 (1.0f);
    BSDFMaterial _S1068 = Material_x24init_0(_S1066, _S1066, 0.0f, 0.0f, 0.0f, 0.0f, _S1066, _S1067, 1.0f, _S1066, _S1066, 0.5f, 0.0f, 0.0f, _S1066, 0.0f, _S1066);
    BSDFMaterial material_8 = _S1068;
    (&material_8)->albedo = _S1067;
    (&material_8)->emissive = (&surface_6->material)->emissive;
    (&material_8)->transmission = 1.0f;
    (&material_8)->ior = 1.0f;
    (&material_8)->absorption = (&surface_6->material)->absorption;
    FKSurface through_0 = *surface_6;
    (&through_0)->material = material_8;
    return through_0;
}

__device__ float facingSign(float transmission_1, float3  face_0, float3  direction_0)
{
    bool _S1069 = transmission_1 > 0.0f;
    bool _S1070;
    if(_S1069)
    {
        _S1070 = true;
    }
    else
    {
        _S1070 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S1071;
    if(_S1070)
    {
        _S1071 = 1.0f;
    }
    else
    {
        _S1071 = -1.0f;
    }
    return _S1071;
}

static __device__ bool arrivesBehind_0(float3  dir_10, float3  n_12)
{
    return (dot_0(dir_10, n_12)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_7, float3  dir_11)
{
    float3  _S1072 = surface_7->geometry_n;
    float _S1073 = facingSign((&surface_7->material)->transmission, surface_7->geometry_n, dir_11);
    FKSurface faced_0 = *surface_7;
    float3  _S1074 = surface_7->smooth_n * make_float3 (_S1073);
    (&faced_0)->smooth_n = _S1074;
    float3  _S1075 = _S1072 * make_float3 (_S1073);
    (&faced_0)->geometry_n = _S1075;
    return faced_0;
}

static __device__ float3  max_0(float3  x_22, float3  y_7)
{
    float3  result_11;
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
        *_slang_vector_get_element_ptr(&result_11, i_14) = (F32_max((_slang_vector_get_element(x_22, i_14)), (_slang_vector_get_element(y_7, i_14))));
        i_14 = i_14 + int(1);
    }
    return result_11;
}

static __device__ float3  log_0(float3  x_23)
{
    float3  result_12;
    int i_15 = int(0);
    for(;;)
    {
        if(i_15 < int(3))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_12, i_15) = (F32_log((_slang_vector_get_element(x_23, i_15))));
        i_15 = i_15 + int(1);
    }
    return result_12;
}

__device__ float3  beerLambert(float distance_3, float3  absorption_1)
{
    float3  _S1076 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_3) * log_0(_S1076));
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
    bool _S1077;
    if(open_0)
    {
        _S1077 = prev_rough_0;
    }
    else
    {
        _S1077 = false;
    }
    if(_S1077)
    {
        _S1077 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S1077 = false;
    }
    return _S1077;
}

static __device__ float2  vertexEta_0(BSDFMaterial * material_9, float n_dot_v_0)
{
    bool _S1078 = n_dot_v_0 < 0.0f;
    float _S1079 = material_9->ior;
    float _S1080 = _slang_select(_S1078, _S1079,1.0f);
    float _S1081 = _slang_select(_S1078, 1.0f,_S1079);
    return make_float2 (_S1080, _S1081);
}

__device__ bool samplesLights(BSDFMaterial material_10)
{
    bool _S1082 = (material_10.roughness) > 0.0f;
    bool _S1083;
    if(_S1082)
    {
        _S1083 = true;
    }
    else
    {
        bool _S1084 = (material_10.metallic) < 1.0f;
        if(_S1084)
        {
            _S1083 = (material_10.transmission) < 1.0f;
        }
        else
        {
            _S1083 = false;
        }
    }
    return _S1083;
}

static __device__ bool isTranslucent_0(BSDFMaterial * material_11)
{
    float _S1085 = rgb_to_greyscale(material_11->translucent);
    return _S1085 > 0.0f;
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
    MediumSides _S1086;
    (&_S1086)->behind = *behind_0;
    (&_S1086)->front = *front_0;
    (&_S1086)->fillings = fillings_1;
    (&_S1086)->face = face_1;
    return _S1086;
}

static __device__ MediumSides mediumSides_0(FKSurface * surface_8, FKMedium * medium_0, uint filling_0, float3  dir_12, FKMedium * outside_0)
{
    float3  _S1087 = surface_8->geometry_n;
    MediumSides _S1088 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_8->geometry_n);
    MediumSides sides_0 = _S1088;
    bool _S1089 = surface_8->encloses;
    if(_S1089)
    {
        (&sides_0)->behind = surface_8->volume;
        *&((&(&sides_0)->fillings)->x) = surface_8->fills;
        bool _S1090 = (dot_0(dir_12, _S1087)) > 0.0f;
        if(_S1090)
        {
            (&sides_0)->front = *outside_0;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_9, bool turned_0, float3  extinction_2, uint filling_1, float3  dir_13, uint depth_2, uint lobe_11, float length_3, float width_2, FKHit * own_3, bool fiber_1, FKMedium * outside_1)
{
    float3  _S1091 = surface_9->geometry_n;
    ShadowContext _S1092 = ShadowContext_x24init_0(extinction_2, extinction_2, make_uint2 (filling_1), surface_9->geometry_n, depth_2, lobe_11, true, length_3, width_2, own_3, fiber_1);
    bool _S1093 = surface_9->encloses;
    ShadowContext context_4;
    if(_S1093)
    {
        FKSurface faced_1 = *surface_9;
        float3  _S1094 = - _S1091;
        float3  _S1095 = _slang_select(turned_0, _S1094,_S1091);
        (&faced_1)->geometry_n = _S1095;
        FKMedium _S1096 = Medium_x24init_0(make_float3 (0.0f), extinction_2, 0.0f);
        FKSurface _S1097 = faced_1;
        FKMedium _S1098 = _S1096;
        MediumSides _S1099 = mediumSides_0(&_S1097, &_S1098, filling_1, dir_13, outside_1);
        ShadowContext _S1100 = ShadowContext_x24init_0(_S1099.behind.extinction, _S1099.front.extinction, _S1099.fillings, _S1091, depth_2, lobe_11, true, length_3, width_2, own_3, fiber_1);
        if(turned_0)
        {
            uint2  _S1101 = _S1099.fillings;
            ShadowContext _S1102 = ShadowContext_x24init_0(_S1099.front.extinction, _S1099.behind.extinction, uint2 {_S1101.y, _S1101.x}, _S1091, depth_2, lobe_11, true, length_3, width_2, own_3, fiber_1);
            context_4 = _S1102;
        }
        else
        {
            context_4 = _S1100;
        }
    }
    else
    {
        context_4 = _S1092;
    }
    return context_4;
}

static __device__ bool any_1(bool3  x_24)
{
    bool result_13 = false;
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
        if(result_13)
        {
            result_13 = true;
        }
        else
        {
            result_13 = (bool((_slang_vector_get_element(x_24, i_16))));
        }
        i_16 = i_16 + int(1);
    }
    return result_13;
}

__device__ __forceinline__ float3  BSDF(float3  in_dir_5, float3  out_dir_1, float3  n_13, float3  g_n_0, BSDFMaterial material_12, float eta_i_5, float eta_o_5, uint random_state_12)
{
    float3  _S1103 = negate_0(in_dir_5);
    bool _S1104 = (dot_0(g_n_0, _S1103) * dot_0(g_n_0, out_dir_1)) > 0.0f;
    if(_S1104)
    {
        SampleBSDF _S1105 = connectBSDF(in_dir_5, out_dir_1, n_13, material_12, eta_i_5, eta_o_5, 0U, random_state_12);
        SampleBSDF _S1106 = connectBSDF(in_dir_5, out_dir_1, n_13, material_12, eta_i_5, eta_o_5, 2U, random_state_12);
        return _S1105.throughput * make_float3 (_S1105.pdf) + _S1106.throughput * make_float3 (_S1106.pdf);
    }
    SampleBSDF _S1107 = connectBSDF(in_dir_5, out_dir_1, n_13, material_12, eta_i_5, eta_o_5, 1U, random_state_12);
    return _S1107.throughput * make_float3 (_S1107.pdf);
}

__device__ float3  translucentCorrection(float3  in_dir_6, float3  out_dir_2, float3  n_14, float3  g_n_1, BSDFMaterial material_13, float eta_i_6, float eta_o_6, uint random_state_13)
{
    float _S1108 = dot_0(n_14, out_dir_2);
    float3  _S1109 = negate_0(in_dir_6);
    bool _S1110 = (_S1108 * dot_0(n_14, _S1109)) < 0.0f;
    SampleBSDF _S1111 = connectBSDF(in_dir_6, out_dir_2, n_14, material_13, eta_i_6, eta_o_6, 0U, random_state_13);
    float3  _S1112 = negate_0(in_dir_6);
    bool _S1113 = (dot_0(g_n_1, _S1112) * dot_0(g_n_1, out_dir_2)) > 0.0f;
    float3  _S1114 = make_float3 (0.0f);
    float3  _S1115 = _S1111.throughput * make_float3 (_S1111.pdf);
    float _S1116 = _slang_select(_S1113, -1.0f,1.0f);
    float3  _S1117 = _S1115 * make_float3 (_S1116);
    float3  _S1118 = _slang_select(_S1110, _S1117,_S1114);
    return _S1118;
}

__device__ float3  translucentBSDF(float3  in_dir_7, float3  out_dir_3, float3  n_15, float3  g_n_2, BSDFMaterial material_14, float eta_i_7, float eta_o_7, uint random_state_14)
{
    float3  _S1119 = BSDF(in_dir_7, out_dir_3, n_15, g_n_2, material_14, eta_i_7, eta_o_7, random_state_14);
    float3  _S1120 = translucentCorrection(in_dir_7, out_dir_3, n_15, g_n_2, material_14, eta_i_7, eta_o_7, random_state_14);
    return _S1119 + _S1120;
}

static __device__ __forceinline__ float3  lightBSDF_0(float3  in_dir_8, TreeSample * light_2, float3  smooth_n_5, float3  geometry_n_4, BSDFMaterial * material_15, float eta_i_8, float eta_o_8, bool competing_1, uint random_state_15)
{
    bool _S1121 = !competing_1;
    bool _S1122;
    if(_S1121)
    {
        _S1122 = true;
    }
    else
    {
        _S1122 = (light_2->density) == 0.0f;
    }
    if(_S1122)
    {
        bool _S1123 = isTranslucent_0(material_15);
        if(_S1123)
        {
            float3  _S1124 = translucentBSDF(in_dir_8, light_2->dir, smooth_n_5, geometry_n_4, *material_15, eta_i_8, eta_o_8, random_state_15);
            return _S1124 * light_2->radiance;
        }
        float3  _S1125 = BSDF(in_dir_8, light_2->dir, smooth_n_5, geometry_n_4, *material_15, eta_i_8, eta_o_8, random_state_15);
        return _S1125 * light_2->radiance;
    }
    float3  _S1126 = light_2->dir;
    bool _S1127 = (dot_0(geometry_n_4, - in_dir_8) * dot_0(geometry_n_4, light_2->dir)) <= 0.0f;
    float3  _S1128 = neeBSDF(in_dir_8, _S1126, smooth_n_5, *material_15, eta_i_8, eta_o_8, _S1127, light_2->density, true, random_state_15);
    return _S1128 * light_2->radiance * make_float3 (light_2->density);
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S1129 = (F32_sqrt((random_1_0)));
    float _S1130 = 6.28318548202514648f * random_2_0;
    float _S1131 = _S1129 * (F32_cos((_S1130)));
    float _S1132 = _S1129 * (F32_sin((_S1130)));
    float _S1133 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1131 * _S1131 - _S1132 * _S1132))))));
    return make_float3 (_S1131, _S1133, _S1132);
}

static __device__ float toonInvert_0(float target_2, ToonLobe_0 * lobe_12)
{
    bool _S1134 = lobe_12->glossy_0;
    float t_22;
    if(lobe_12->glossy_0)
    {
        t_22 = (F32_acos((clamp_1(1.0f - target_2, -1.0f, 1.0f))));
    }
    else
    {
        t_22 = (F32_asin(((F32_min(((F32_sqrt((2.0f * target_2)))), (1.0f))))));
    }
    float _S1135 = lobe_12->a_5;
    if(t_22 < (lobe_12->a_5))
    {
    }
    else
    {
        t_22 = (_S1135 + lobe_12->b_1) / 2.0f;
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
        float _S1136 = toonProfile_0(t_22, lobe_12);
        float _S1137 = _S1136 * (F32_sin((t_22)));
        float _S1138;
        if(_S1134)
        {
            _S1138 = 1.0f;
        }
        else
        {
            _S1138 = (F32_cos((t_22)));
        }
        float _S1139 = _S1137 * _S1138;
        float _S1140 = toonIntegral_0(t_22, lobe_12);
        float _S1141 = (_S1140 - target_2) / _S1139;
        bool _S1142 = _S1139 > 0.0f;
        float _S1143 = _slang_select(_S1142, _S1141,0.0f);
        float _S1144 = clamp_1(t_22 - _S1143, 0.0f, lobe_12->b_1);
        int k_1 = k_0 + int(1);
        t_22 = _S1144;
        k_0 = k_1;
    }
    return t_22;
}

__device__ float3  sampleToon(float3  v_9, float3  n_16, float3  toon_4, float u_1_0, float u_2_0)
{
    ToonLobe_0 _S1145 = toonLobe_0(toon_4);
    ToonLobe_0 _S1146 = _S1145;
    float _S1147 = toonIntegral_0(_S1145.b_1, &_S1146);
    float _S1148 = u_1_0 * _S1147;
    ToonLobe_0 _S1149 = _S1145;
    float _S1150 = toonInvert_0(_S1148, &_S1149);
    float _S1151 = 6.28318548202514648f * u_2_0;
    float3  _S1152;
    if(_S1145.glossy_0)
    {
        float3  _S1153 = make_float3 (2.0f * dot_0(n_16, v_9)) * n_16 - v_9;
        float3  _S1154 = ((((_S1153)) * make_float3(rnorm3df(((_S1153)).x, ((_S1153)).y, ((_S1153)).z))));
        _S1152 = _S1154;
    }
    else
    {
        _S1152 = n_16;
    }
    float _S1155 = (F32_sin((_S1150)));
    float3  _S1156 = tangentToWorld(make_float3 (_S1155 * (F32_cos((_S1151))), (F32_cos((_S1150))), _S1155 * (F32_sin((_S1151)))), _S1152);
    return _S1156;
}

static __device__ float3  reflect_0(float3  i_17, float3  n_17)
{
    return i_17 - make_float3 (2.0f * dot_0(n_17, i_17)) * n_17;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_9, float3  n_18, BSDFMaterial material_16, float eta_i_9, float eta_o_9, uint random_init_1, float2  screen_space_0)
{
    uint random_state_16 = random_init_1;
    float3  _S1157 = negate_0(in_dir_9);
    float _S1158 = dot_0(n_18, _S1157);
    float _S1159 = sign_0(_S1158);
    float3  n_i_5 = n_18 * make_float3 (_S1159);
    float _S1160 = (F32_abs((_S1158)));
    float _S1161 = material_16.roughness;
    float _S1162 = _S1161 * _S1161;
    AnisotropicFrame _S1163 = anisotropicFrame(material_16, n_i_5);
    float3  _S1164 = sampleHalfVector(_S1157, n_i_5, _S1162, _S1163, &random_state_16);
    BSDFLobes _S1165 = bsdfLobes(in_dir_9, _S1157, n_i_5, _S1164, material_16, eta_i_9, eta_o_9, _S1163);
    BSDFLobes lobes_4 = _S1165;
    float _S1166 = translucentShare(material_16);
    (&lobes_4)->translucent_share = _S1166;
    float3  _S1167 = make_float3 (1.0f);
    SampleBSDF _S1168 = SampleBSDF_x24init_0(_S1167, _S1167, 0U, false, 0U, 0.0f);
    SampleBSDF sample_2 = _S1168;
    Random _S1169 = pcg(random_state_16);
    random_state_16 = _S1169.state;
    bool _S1170 = (_S1169.value) < ((&lobes_4)->p_diffuse);
    if(_S1170)
    {
        Random _S1171 = pcg(random_state_16);
        Random _S1172 = pcg(_S1171.state);
        (&sample_2)->random_state = _S1172.state;
        float3  _S1173 = sampleCosWeightedHemisphere(_S1171.value, _S1172.value);
        bool _S1174 = ((&lobes_4)->toon_share) > 0.0f;
        if(_S1174)
        {
            bool _S1175 = (_S1169.value) >= ((&lobes_4)->p_diffuse * (1.0f - (&lobes_4)->toon_share));
            bool _S1176 = (_S1169.value) < ((&lobes_4)->p_diffuse * (1.0f - (&lobes_4)->toon_share) * (&lobes_4)->translucent_share);
            float _S1177 = _S1173.y;
            float _S1178 = - _S1177;
            float _S1179 = _slang_select(_S1176, _S1178,_S1177);
            float3  _S1180;
            if(_S1175)
            {
                float3  _S1181 = sampleToon(_S1157, n_i_5, material_16.toon, _S1171.value, _S1172.value);
                _S1180 = _S1181;
            }
            else
            {
                float3  _S1182 = tangentToWorld(make_float3 (_S1173.x, _S1179, _S1173.z), n_i_5);
                _S1180 = _S1182;
            }
            (&sample_2)->unit_direction = _S1180;
            float3  _S1183 = lobeThroughput((&sample_2)->unit_direction, n_i_5, _S1162, material_16, lobes_4, 0U);
            (&sample_2)->throughput = _S1183;
            float _S1184 = lobeDensity(dot_0(n_i_5, (&sample_2)->unit_direction), 0.0f, _S1160, _S1162, lobes_4, eta_i_9, eta_o_9, 0U);
            (&sample_2)->pdf = _S1184;
            bool _S1185 = (dot_0(n_i_5, (&sample_2)->unit_direction)) < 0.0f;
            (&sample_2)->refracted = _S1185;
            BSDFMaterial _S1186 = material_16;
            BSDFLobes _S1187 = lobes_4;
            toonMix_0(&sample_2, _S1157, n_i_5, &_S1186, &_S1187);
            return sample_2;
        }
        bool _S1188 = (_S1169.value) < ((&lobes_4)->p_diffuse * (&lobes_4)->translucent_share);
        float _S1189 = _S1173.y;
        float _S1190 = - _S1189;
        float _S1191 = _slang_select(_S1188, _S1190,_S1189);
        float3  _S1192 = tangentToWorld(make_float3 (_S1173.x, _S1191, _S1173.z), n_i_5);
        (&sample_2)->unit_direction = _S1192;
        float3  _S1193 = lobeThroughput((&sample_2)->unit_direction, n_i_5, _S1162, material_16, lobes_4, 0U);
        (&sample_2)->throughput = _S1193;
        float _S1194 = lobeDensity(_S1191, 0.0f, _S1160, _S1162, lobes_4, eta_i_9, eta_o_9, 0U);
        (&sample_2)->pdf = _S1194;
        (&sample_2)->refracted = _S1188;
        return sample_2;
    }
    bool _S1195 = (_S1169.value) < ((&lobes_4)->p_diffuse + (&lobes_4)->p_refract);
    if(_S1195)
    {
        (&sample_2)->unit_direction = (&lobes_4)->refracted;
        float _S1196 = lobeDensity(0.0f, dot_0((&sample_2)->unit_direction, _S1164), _S1160, _S1162, lobes_4, eta_i_9, eta_o_9, 1U);
        (&sample_2)->pdf = _S1196;
        float3  _S1197 = lobeThroughput((&sample_2)->unit_direction, n_i_5, _S1162, material_16, lobes_4, 1U);
        (&sample_2)->throughput = _S1197;
        (&sample_2)->random_state = random_state_16;
        (&sample_2)->refracted = true;
        (&sample_2)->lobe = 1U;
        return sample_2;
    }
    float3  _S1198 = reflect_0(in_dir_9, _S1164);
    float3  _S1199 = ((((_S1198)) * make_float3(rnorm3df(((_S1198)).x, ((_S1198)).y, ((_S1198)).z))));
    (&sample_2)->unit_direction = _S1199;
    float3  _S1200 = lobeThroughput((&sample_2)->unit_direction, n_i_5, _S1162, material_16, lobes_4, 2U);
    (&sample_2)->throughput = _S1200;
    (&sample_2)->random_state = random_state_16;
    (&sample_2)->lobe = 2U;
    float _S1201 = lobeDensity(0.0f, 0.0f, _S1160, _S1162, lobes_4, eta_i_9, eta_o_9, 2U);
    (&sample_2)->pdf = _S1201;
    return sample_2;
}

__device__ bool withinInverseFootprint(float pdf_7, bool diffuse_0, float prev_cos_0, float distance_5, float threshold_1)
{
    bool _S1202 = pdf_7 > 0.0f;
    bool _S1203;
    if(_S1202)
    {
        if(diffuse_0)
        {
            _S1203 = true;
        }
        else
        {
            _S1203 = (pdf_7 * prev_cos_0 / (distance_5 * distance_5) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S1203 = false;
    }
    return _S1203;
}

__device__ bool roughLobe(float pdf_8, bool diffuse_1, float roughness_1)
{
    bool _S1204 = pdf_8 > 0.0f;
    bool _S1205;
    if(_S1204)
    {
        if(diffuse_1)
        {
            _S1205 = true;
        }
        else
        {
            _S1205 = roughness_1 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S1205 = false;
    }
    return _S1205;
}

static __device__ bool passesLayer_0(uint layers_0, bool refracting_0, bool passed_0)
{
    bool _S1206 = layers_0 > 1U;
    bool _S1207;
    if(_S1206)
    {
        _S1207 = refracting_0 != passed_0;
    }
    else
    {
        _S1207 = false;
    }
    return _S1207;
}

static __device__ float widened_0(float spread_1, float pdf_9, bool delta_0)
{
    float _S1208 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * pdf_9))))), (3.14159274101257324f)));
    bool _S1209 = !delta_0;
    float _S1210 = _slang_select(_S1209, _S1208,0.0f);
    return spread_1 + _S1210;
}

static __device__ bool boundsVolume_0(FKSurface * surface_10)
{
    return surface_10->encloses;
}

static __device__ bool leavesInFront_0(float3  face_2, float3  dir_14, float3  g_3)
{
    return ((dot_0(dir_14, g_3)) > 0.0f) == ((dot_0(g_3, face_2)) > 0.0f);
}

static __device__ Shift walk_0(Domain * dom_7, Reservoir * r_12, bool replay_2, float scale_3, Selection * sel_7)
{
    float spread_2;
    bool turned_1;
    bool is_inside_5;
    bool viewed_0;
    bool scatter_2;
    float density_2;
    float threshold_2;
    float width_3;
    float sky_pdf_0;
    float geometry_density_2;
    uint b_8;
    uint layer_0;
    float3  throughput_2;
    float3  chain_throughput_0;
    TreeSample light_3;
    int _S1211;
    Shift ended_0;
    float density_3;
    float spread_3;
    float width_4;
    float sky_pdf_1;
    float spread_4;
    float width_5;
    uint b_9;
    float3  _S1212 = make_float3 (0.0f);
    Shift _S1213 = Shift_x24init_0(_S1212, 0.0f);
    uint _S1214 = r_12->path;
    uint _S1215 = extractBits_0(r_12->path, 0U, 5U);
    uint _S1216 = extractBits_0(_S1214, 5U, 5U);
    uint _S1217 = extractBits_0(_S1214, 10U, 2U);
    uint _S1218 = extractBits_0(_S1214, 12U, 3U);
    bool passes_0;
    if(replay_2)
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
    FKHit _S1229 = (fcptReservoirHit((*r_12)));
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
    uint _S1240 = r_12->seed;
    (&chain_0)->seed = r_12->seed;
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
            spread_2 = _S1248;
        }
        else
        {
            spread_2 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
        }
        if(replay_2)
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
            turned_1 = spread_2 > 0.0f;
        }
        else
        {
            turned_1 = false;
        }
        if(turned_1)
        {
            ended_0 = _S1213;
            sky_pdf_0 = 0.0f;
            spread_2 = _S1234;
            width_3 = _S1235;
            density_2 = 1.0f;
            throughput_2 = throughput_3;
            b_8 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S1249 = (&prev_0)->rough;
        if(_S1249)
        {
            turned_1 = !(spread_2 > 0.0f);
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
        b_8 = 4294967295U;
        throughput_2 = throughput_3;
        density_2 = 1.0f;
        threshold_2 = _S1234;
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
            uint _S1251 = b_8 + 320U;
            bool _S1252 = b_8 == 4294967295U;
            uint _S1253 = _slang_select(_S1252, 384U,_S1251);
            uint _S1254 = stream(_S1240, _S1253);
            Random _S1255 = pcg(_S1254);
            float _S1256 = freeFlight_0(_S1255.value, spread_2);
            if(passes_0)
            {
                float3  _S1257 = (&ray_2)->origin;
                float3  _S1258 = (&ray_2)->unit_direction;
                float _S1259 = (&hit_4)->distance;
                uint _S1260 = _slang_select(_S1252, 0U,b_8);
                uint _S1261 = (&prev_0)->lobe;
                uint _S1262 = _slang_select(_S1252, 3U,_S1261);
                float _S1263 = (fcptTrackMedium((_S1246), (_S1257), (_S1258), (_S1259), (&tracking_0), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1260), (_S1262), (_S1252)));
                geometry_density_2 = _S1263;
            }
            else
            {
                geometry_density_2 = _S1256;
            }
            bool _S1264 = !(geometry_density_2 < ((&hit_4)->distance));
            if(_S1264)
            {
                _S1211 = int(1);
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
                float3  _S1265 = throughput_2 * glowed_0 / make_float3 (density_2);
                float3  _S1266 = sel_7->glow + _S1265;
                sel_7->glow = _S1266;
            }
            else
            {
            }
            glowed_0 = _S1212;
            uint b_10 = b_8 + 1U;
            float3  _S1267 = (&ray_2)->origin + make_float3 (geometry_density_2) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S1267;
            float3  _S1268 = flightWeight_0(scatter_in_0, extinction_in_0, spread_2, geometry_density_2, true);
            float3  _S1269 = weight_1;
            float3  _S1270 = _slang_select(passes_0, _S1269,_S1268);
            float3  throughput_4 = throughput_2 * _S1270;
            uint _S1271 = stream(_S1240, b_10 + 320U);
            tracking_0 = _S1271;
            weight_1 = throughput_3;
            float width_6 = width_3 + threshold_2 * geometry_density_2;
            float _S1272 = threshold_2 + 3.14159274101257324f;
            bool _S1273 = scatterSampled_0(replay_2, b_10, _S1228, passes_0);
            TreeSample _S1274 = TreeSample_x24init_0(_S1212, _S1212, 0.0f, 0U);
            if(_S1273)
            {
                float3  _S1275 = (&ray_2)->origin;
                float3  _S1276 = (&ray_2)->unit_direction;
                float3  _S1277 = (&ray_2)->unit_direction;
                uint _S1278 = stream(_S1240, b_10 + 64U);
                float3  _S1279 = extinction_in_0;
                float3  _S1280 = extinction_in_0;
                uint2  _S1281 = make_uint2 (_S1246);
                float3  _S1282 = (&ray_2)->unit_direction;
                uint _S1283 = arrivalLobe_0(b_10, (&prev_0)->lobe);
                FKHit _S1284 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S1285 = _S1284;
                ShadowContext _S1286 = ShadowContext_x24init_0(_S1279, _S1280, _S1281, _S1282, b_10, _S1283, false, geometry_density_2, width_6, &_S1285, false);
                ShadowContext _S1287 = _S1286;
                TreeSample _S1288 = sampleLightTree_0(_S1275, _S1276, _S1277, 0.0f, true, _S1278, &_S1287);
                light_3 = _S1288;
            }
            else
            {
                light_3 = _S1274;
            }
            float _S1289 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_3.dir));
            uint _S1290 = (fcptMaxBounces());
            bool _S1291 = b_10 < _S1290;
            if(_S1291)
            {
                is_inside_5 = (light_3.density) > 0.0f;
            }
            else
            {
                is_inside_5 = false;
            }
            float _S1292 = _slang_select(is_inside_5, _S1289,0.0f);
            float3  _S1293 = throughput_4 * light_3.radiance;
            float _S1294 = powerHeuristic(light_3.density, _S1292);
            float3  _S1295 = _S1293 * make_float3 (_S1289 * _S1294);
            float3  _S1296 = _slang_select(_S1273, _S1295,_S1212);
            if(replay_2)
            {
                viewed_0 = b_10 == _S1228;
            }
            else
            {
                viewed_0 = false;
            }
            if(viewed_0)
            {
                bool _S1297 = _S1217 == 2U;
                if(_S1297)
                {
                    float _S1298 = rgb_to_greyscale(_S1296);
                    passes_0 = _S1298 > 0.0f;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S1299 = Shift_x24init_0(_S1296, 1.0f);
                    _S1211 = int(0);
                    ended_0 = _S1299;
                    spread_2 = _S1272;
                    geometry_density_2 = width_6;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_10;
                    break;
                }
                _S1211 = int(0);
                ended_0 = _S1213;
                spread_2 = _S1272;
                geometry_density_2 = width_6;
                chain_throughput_0 = throughput_4;
                layer_0 = b_10;
                break;
            }
            bool _S1300 = !replay_2;
            if(_S1300)
            {
                Reservoir candidate_3 = _S1245;
                uint _S1301 = extractBits_0(_S1245.path, 10U, 2U);
                bool _S1302 = _S1301 == 1U;
                if(_S1302)
                {
                    float3  _S1303 = safeDivide(_S1296, _S1212);
                    (&candidate_3)->radiance = _S1303;
                }
                else
                {
                    uint _S1304 = insertBits_0(0U, b_10 + 1U, 5U, 5U);
                    uint _S1305 = insertBits_0(_S1304, 2U, 10U, 2U);
                    (&candidate_3)->path = _S1305;
                }
                Reservoir _S1306 = withEnd(candidate_3, 0U, b_10, _S1296);
                offer(sel_7, _S1306, _S1296 * make_float3 (scale_3) / make_float3 (density_2));
                float _S1307 = survivalProbability(throughput_4, density_2);
                uint _S1308 = stream(_S1240, b_10 + 128U);
                Random _S1309 = pcg(_S1308);
                bool _S1310 = _S1307 < (_S1309.value);
                if(_S1310)
                {
                    scatter_2 = true;
                }
                else
                {
                    uint _S1311 = (fcptMaxBounces());
                    scatter_2 = b_10 >= _S1311;
                }
                if(scatter_2)
                {
                    _S1211 = int(0);
                    ended_0 = _S1213;
                    spread_2 = _S1272;
                    geometry_density_2 = width_6;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_10;
                    break;
                }
                float _S1312 = density_2 * _S1307;
                density_2 = _S1312;
            }
            else
            {
            }
            float phase_pdf_0 = 0.0f;
            uint _S1313 = stream(_S1240, b_10);
            float3  _S1314 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1313, &phase_pdf_0);
            (&ray_2)->unit_direction = _S1314;
            NEEVertex _S1315 = NEEVertex_x24init_0(false, phase_pdf_0, (&ray_2)->origin, _S1212, (&ray_2)->origin);
            nee_vertex_0 = _S1315;
            Vertex _S1316 = scatteredVertex_0(false);
            prev_0 = _S1316;
            float _S1317 = (&prev_0)->pdf;
            FKRay _S1318 = ray_2;
            FKHit _S1319 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S1320 = (fcptTraverseInstanceBVH((_S1318), (true), (4.294967296e+09f), (false), (_S1319), (false)));
            hit_4 = _S1320;
            b_8 = b_10;
            throughput_2 = throughput_4;
            threshold_2 = _S1272;
            width_3 = width_6;
            sky_pdf_0 = _S1317;
        }
        if(_S1211 != int(1))
        {
            width_3 = geometry_density_2;
            throughput_2 = chain_throughput_0;
            b_8 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S1213;
        spread_2 = threshold_2;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    bool _S1321 = b_8 == 4294967295U;
    bool _S1322 = ((&hit_4)->instance_index) == 4294967295U;
    if(_S1322)
    {
        bool _S1323 = !(&nee_vertex_0)->none;
        float _S1324 = _slang_select(_S1323, sky_pdf_0,0.0f);
        float _S1325 = escapeWeight_0(_S1324, (&ray_2)->unit_direction);
        float3  _S1326 = environment_0((&ray_2)->unit_direction, b_8, (&prev_0)->lobe);
        float3  _S1327 = throughput_2 * _S1326;
        if(replay_2)
        {
            bool _S1328 = b_8 == _S1228;
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
                return Shift_x24init_0(_S1327 * make_float3 (_S1325) / make_float3 (r_12->jac), density_2 / r_12->jac);
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
            bool _S1332 = _S1331 == b_8;
            float _S1333 = _slang_select(_S1332, 1.0f,_S1325);
            float3  _S1334 = safeDivide(_S1327 * make_float3 (_S1333), _S1212);
            (&candidate_4)->radiance = _S1334;
        }
        else
        {
            bool _S1335 = (&prev_0)->rough;
            if(_S1335)
            {
                uint _S1336 = insertBits_0(0U, b_8 + 1U, 5U, 5U);
                uint _S1337 = insertBits_0(_S1336, 3U, 10U, 2U);
                uint _S1338 = insertBits_0(_S1337, (&prev_0)->lobe, 15U, 2U);
                bool _S1339 = (&prev_0)->inside;
                uint _S1340 = _slang_select(_S1339, 1U,0U);
                uint _S1341 = insertBits_0(_S1338, _S1340, 20U, 1U);
                (&candidate_4)->path = _S1341;
                (&candidate_4)->jac = (&prev_0)->pdf;
                (&candidate_4)->dir = (&ray_2)->unit_direction;
            }
        }
        float3  _S1342 = _S1327 * make_float3 (_S1325);
        Reservoir _S1343 = withEnd(candidate_4, 3U, b_8, _S1342);
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
        bool _S1346 = !replay_2;
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
    float _S1352 = width_3 + spread_2 * (&hit_4)->distance;
    uint _S1353 = b_8 + 1U;
    b_8 = _S1353;
    layer_0 = 0U;
    width_3 = _S1352;
    passes_0 = false;
    threshold_2 = 0.0f;
    turned_1 = false;
    is_inside_5 = false;
    chain_throughput_0 = _S1212;
    float3  reconnection_0 = _S1212;
    viewed_0 = _S1321;
    for(;;)
    {
        bool _S1354 = ((&hit_4)->is_point_light) == 1U;
        FKMedium _S1355 = Medium_x24init_0(_S1212, _S1212, 0.0f);
        BSDFMaterial _S1356 = Material_x24init_0(_S1212, _S1212, 0.0f, 0.0f, 0.0f, 0.0f, _S1212, throughput_3, 1.0f, _S1212, _S1212, 0.5f, 0.0f, 0.0f, _S1212, 0.0f, _S1212);
        FKMedium _S1357 = _S1355;
        FKSurface _S1358 = Surface_x24init_0(_S1212, _S1212, 0.0f, &_S1356, false, 0U, 1.0f, false, &_S1357, 4294967295U, _S1212);
        bool _S1359 = !_S1354;
        bool is_inside_6;
        float3  throughput_5;
        FKSurface surface_11;
        if(_S1359)
        {
            uint _S1360 = stream(_S1240, b_8);
            uint _S1361 = arrivalLobe_0(b_8, (&prev_0)->lobe);
            FKSurface _S1362 = (fcptSurfaceAtPath((hit_4), ((&ray_2)->origin), (_S1360), (width_3), (layer_0), (b_8), (_S1361), ((&ray_2)->unit_direction)));
            bool _S1363 = !passes_0;
            FKSurface _S1364 = _S1362;
            FKSurface _S1365 = emitting_0(&_S1364, _S1363);
            uint _S1366 = stream(_S1240, b_8 + 256U);
            Random _S1367 = pcg(_S1366);
            FKSurface _S1368 = _S1365;
            FKSurface _S1369 = uncovered_0(&_S1368, _S1367.value);
            float _S1370 = facingSign(_S1369.material.transmission, _S1369.geometry_n, (&ray_2)->unit_direction);
            bool _S1371 = _S1370 < 0.0f;
            bool _S1372 = (_S1369.material.transmission) > 0.0f;
            if(_S1372)
            {
                bool _S1373 = arrivesBehind_0((&ray_2)->unit_direction, _S1369.geometry_n);
                scatter_2 = _S1373;
            }
            else
            {
                scatter_2 = false;
            }
            FKSurface _S1374 = _S1369;
            FKSurface _S1375 = facingRay_0(&_S1374, (&ray_2)->unit_direction);
            if(passes_0)
            {
                bool _S1376 = arrivesBehind_0((&ray_2)->unit_direction, _S1375.geometry_n);
                is_inside_6 = _S1376;
            }
            else
            {
                is_inside_6 = scatter_2;
            }
            if(is_inside_6)
            {
                float3  _S1377 = beerLambert((&hit_4)->distance, _S1375.material.absorption);
                float3  _S1378 = throughput_2 * _S1377;
                throughput_5 = _S1378;
            }
            else
            {
                throughput_5 = throughput_2;
            }
            bool _S1379 = !_S1375.skip;
            float geometry_density_3 = geometryDensity(_S1375.geometry_n, (&ray_2)->unit_direction, (&hit_4)->distance);
            bool _S1380 = b_8 == _S1353;
            if(_S1380)
            {
                float _S1381 = footprintThreshold(geometry_density_3);
                geometry_density_2 = _S1381;
            }
            else
            {
                geometry_density_2 = threshold_2;
            }
            float _S1382 = geometry_density_2;
            scatter_2 = _S1379;
            geometry_density_2 = geometry_density_3;
            threshold_2 = _S1382;
            surface_11 = _S1375;
            turned_1 = _S1371;
        }
        else
        {
            scatter_2 = false;
            geometry_density_2 = 0.0f;
            surface_11 = _S1358;
            throughput_5 = throughput_2;
            is_inside_6 = is_inside_5;
        }
        bool _S1383 = withinFootprint(scatter_2, (&prev_0)->rough, (&prev_0)->pdf, geometry_density_2, threshold_2);
        FKSurface _S1384 = surface_11;
        FKSurface _S1385 = surface_11;
        float _S1386 = dot_0(surface_11.smooth_n, - (&ray_2)->unit_direction);
        BSDFMaterial _S1387 = _S1384.material;
        float2  _S1388 = vertexEta_0(&_S1387, _S1386);
        bool _S1389;
        if(scatter_2)
        {
            bool _S1390 = samplesLights(_S1384.material);
            _S1389 = _S1390;
        }
        else
        {
            _S1389 = false;
        }
        bool _S1391;
        if(passes_0)
        {
            _S1391 = true;
        }
        else
        {
            _S1391 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S1391)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S1389;
        }
        bool _S1392 = (fcptHairUsed());
        bool _S1393;
        if(_S1392)
        {
            float3  _S1394 = surface_11.hair;
            _S1393 = (dot_0(_S1394, _S1394)) > 0.0f;
        }
        else
        {
            _S1393 = false;
        }
        bool _S1395;
        if(_S1393)
        {
            _S1395 = true;
        }
        else
        {
            BSDFMaterial _S1396 = _S1384.material;
            bool _S1397 = isTranslucent_0(&_S1396);
            _S1395 = _S1397;
        }
        bool _S1398;
        if(_S1395)
        {
            _S1398 = true;
        }
        else
        {
            bool _S1399 = (_S1384.material.transmission) > 0.0f;
            if(_S1399)
            {
                uint _S1400 = (fcptLayers((hit_4)));
                _S1398 = _S1400 == 1U;
            }
            else
            {
                _S1398 = false;
            }
        }
        float3  emission_0;
        if(_S1354)
        {
            float3  _S1401 = (fcptCalculatePointLightContrib(((&hit_4)->instance_index)));
            emission_0 = _S1401;
        }
        else
        {
            emission_0 = _S1384.material.emissive;
        }
        float _S1402 = rgb_to_greyscale(emission_0);
        bool _S1403 = _S1402 > 0.0f;
        float3  emission_1;
        if(_S1403)
        {
            NEEVertex _S1404 = nee_vertex_0;
            FKHit _S1405 = hit_4;
            float _S1406 = emissionWeight_0(&_S1404, &_S1405, (&ray_2)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S1406);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S1407;
        if(replay_2)
        {
            _S1407 = _S1217 == 1U;
        }
        else
        {
            _S1407 = false;
        }
        bool _S1408;
        if(_S1407)
        {
            _S1408 = b_8 > _S1216;
        }
        else
        {
            _S1408 = false;
        }
        bool _S1409;
        if(_S1408)
        {
            _S1409 = b_8 == _S1215;
        }
        else
        {
            _S1409 = false;
        }
        bool _S1410;
        if(_S1409)
        {
            bool _S1411 = _S1218 == 1U;
            if(_S1411)
            {
                _S1410 = true;
            }
            else
            {
                _S1410 = _S1218 == 2U;
            }
        }
        else
        {
            _S1410 = false;
        }
        if(_S1410)
        {
            bool _S1412 = _S1354 != (_S1218 == 2U);
            if(_S1412)
            {
                return _S1213;
            }
            return Shift_x24init_0(throughput_5 * emission_1 / make_float3 (r_12->jac), density_2 / r_12->jac);
        }
        uint _S1413 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1414 = _S1413 == 1U;
        Reservoir here_0 = chain_0;
        uint _S1415 = insertBits_0(0U, b_8, 5U, 5U);
        uint _S1416 = insertBits_0(_S1415, 1U, 10U, 2U);
        uint _S1417 = insertBits_0(_S1416, (&prev_0)->lobe, 15U, 2U);
        bool _S1418 = (&prev_0)->inside;
        uint _S1419 = _slang_select(_S1418, 1U,0U);
        uint _S1420 = insertBits_0(_S1417, _S1419, 20U, 1U);
        (&here_0)->path = _S1420;
        float _S1421 = (&prev_0)->pdf * geometry_density_2;
        (&here_0)->jac = _S1421;
        fcptWithReservoirHit((&here_0), (&hit_4));
        bool _S1422;
        if(replay_2)
        {
            _S1422 = _S1217 == 1U;
        }
        else
        {
            _S1422 = false;
        }
        bool _S1423;
        if(_S1422)
        {
            _S1423 = b_8 == _S1216;
        }
        else
        {
            _S1423 = false;
        }
        bool _S1424 = b_8 == _S1228;
        bool _S1425;
        if(_S1424)
        {
            bool _S1426 = !scatter_2;
            if(_S1426)
            {
                _S1425 = true;
            }
            else
            {
                bool _S1427 = _S1217 != 1U;
                if(_S1427)
                {
                    _S1425 = _S1217 != 3U;
                }
                else
                {
                    _S1425 = false;
                }
            }
        }
        else
        {
            _S1425 = false;
        }
        bool _S1428;
        if(_S1425)
        {
            _S1428 = _S1217 == 2U;
        }
        else
        {
            _S1428 = false;
        }
        bool _S1429;
        if(_S1428)
        {
            _S1429 = !_S1383;
        }
        else
        {
            _S1429 = false;
        }
        bool _S1430;
        if(_S1429)
        {
            _S1430 = _S1218 != 4U;
        }
        else
        {
            _S1430 = false;
        }
        bool _S1431 = _S1216 == _S1215;
        bool _S1432;
        if(_S1431)
        {
            _S1432 = _S1218 == 0U;
        }
        else
        {
            _S1432 = false;
        }
        bool _S1433;
        if(_S1432)
        {
            _S1433 = ((&hit_4)->instance_index) == (_S1229.instance_index);
        }
        else
        {
            _S1433 = false;
        }
        bool _S1434;
        if(_S1433)
        {
            _S1434 = ((&hit_4)->triangle_index) == (_S1229.triangle_index);
        }
        else
        {
            _S1434 = false;
        }
        bool _S1435;
        if(_S1434)
        {
            _S1435 = _S1383;
        }
        else
        {
            _S1435 = false;
        }
        bool _S1436 = _slang_select(_S1423, _S1435,_S1430);
        bool _S1437;
        if(nee_0)
        {
            _S1437 = _slang_select(replay_2, _S1436,scatter_2);
        }
        else
        {
            _S1437 = false;
        }
        TreeSample _S1438 = TreeSample_x24init_0(_S1212, _S1212, 0.0f, 0U);
        uint2  _S1439 = make_uint2 (0U);
        float2  _S1440 = make_float2 (0.0f);
        FKHit _S1441 = Hit_x24init_0(_S1440, 4294967295U, 0U, 0U, 0.0f);
        FKHit _S1442 = _S1441;
        ShadowContext _S1443 = ShadowContext_x24init_0(_S1212, _S1212, _S1439, _S1212, 0U, 0U, false, 0.0f, 0.0f, &_S1442, false);
        ShadowContext context_5;
        if(nee_0)
        {
            uint _S1444 = arrivalLobe_0(b_8, (&prev_0)->lobe);
            FKMedium _S1445 = (fcptOutsideMedium((hit_4)));
            FKSurface _S1446 = surface_11;
            FKHit _S1447 = hit_4;
            FKMedium _S1448 = _S1445;
            ShadowContext _S1449 = shadowContext_0(&_S1446, turned_1, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_8, _S1444, (&hit_4)->distance, width_3, &_S1447, _S1393, &_S1448);
            context_5 = _S1449;
        }
        else
        {
            context_5 = _S1443;
        }
        float3  throughput_6;
        float3  lit_0;
        if(_S1437)
        {
            float3  _S1450 = (&ray_2)->origin;
            if(_S1393)
            {
                throughput_6 = _S1212;
            }
            else
            {
                throughput_6 = _S1385.smooth_n;
            }
            FKSurface _S1451 = surface_11;
            uint _S1452 = stream(_S1240, b_8 + 64U);
            ShadowContext _S1453 = context_5;
            TreeSample _S1454 = sampleLightTree_0(_S1450, throughput_6, surface_11.geometry_n, surface_11.geometry_offset, _S1398, _S1452, &_S1453);
            bool _S1455 = any_1((_S1454.radiance) != _S1212);
            if(_S1455)
            {
                if(_S1393)
                {
                    uint _S1456 = (fcptMaxBounces());
                    bool _S1457 = b_8 < _S1456;
                    FKSurface _S1458 = surface_11;
                    TreeSample _S1459 = _S1454;
                    float3  _S1460 = hairLight_0(&_S1458, (&ray_2)->unit_direction, &_S1459, _S1457);
                    lit_0 = _S1460;
                }
                else
                {
                    float _S1461 = _S1388.x;
                    float _S1462 = _S1388.y;
                    uint _S1463 = (fcptMaxBounces());
                    bool _S1464 = b_8 < _S1463;
                    TreeSample _S1465 = _S1454;
                    BSDFMaterial _S1466 = _S1384.material;
                    float3  _S1467 = lightBSDF_0((&ray_2)->unit_direction, &_S1465, _S1385.smooth_n, _S1451.geometry_n, &_S1466, _S1461, _S1462, _S1464, surface_11.random_state);
                    lit_0 = _S1467;
                }
            }
            else
            {
                lit_0 = _S1212;
            }
            light_3 = _S1454;
        }
        else
        {
            light_3 = _S1438;
            lit_0 = _S1212;
        }
        bool viewed_1;
        bool refracted_4;
        bool wrong_side_0;
        bool _S1468;
        bool _S1469;
        float density_4;
        if(_S1423)
        {
            bool _S1470 = ((&hit_4)->instance_index) != (_S1229.instance_index);
            if(_S1470)
            {
                viewed_1 = true;
            }
            else
            {
                viewed_1 = ((&hit_4)->triangle_index) != (_S1229.triangle_index);
            }
            if(viewed_1)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = !_S1383;
            }
            if(refracted_4)
            {
                return _S1213;
            }
            float3  throughput_7 = throughput_5 * make_float3 (geometry_density_2);
            float density_5 = density_2 * geometry_density_2;
            if(_S1431)
            {
                wrong_side_0 = _S1218 == 1U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                return Shift_x24init_0(throughput_7 * emission_1 / make_float3 (r_12->jac), density_5 / r_12->jac);
            }
            if(_S1431)
            {
                _S1468 = _S1218 == 0U;
            }
            else
            {
                _S1468 = false;
            }
            if(_S1468)
            {
                bool _S1471 = !nee_0;
                if(_S1471)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S1472 = rgb_to_greyscale(light_3.radiance);
                    passes_0 = !(_S1472 > 0.0f);
                }
                if(passes_0)
                {
                    return _S1213;
                }
                return Shift_x24init_0(throughput_7 * lit_0 / make_float3 (r_12->jac), density_5 / r_12->jac);
            }
            if(_S1431)
            {
                _S1469 = _S1218 == 4U;
            }
            else
            {
                _S1469 = false;
            }
            if(_S1469)
            {
                bool _S1473 = !nee_0;
                if(_S1473)
                {
                    return _S1213;
                }
                float _S1474 = environmentPdf_0(r_12->dir);
                float3  _S1475 = skyBSDF((&ray_2)->unit_direction, r_12->dir, surface_11, _S1388, is_inside_6, _S1474, surface_11.random_state);
                return Shift_x24init_0(throughput_7 * _S1475 * r_12->radiance / make_float3 (r_12->jac), density_5 / r_12->jac);
            }
            uint _S1476 = extractBits_0(_S1214, 19U, 1U);
            bool _S1477 = nee_0 != (_S1476 == 1U);
            if(_S1477)
            {
                return _S1213;
            }
            throughput_6 = throughput_7;
            density_4 = density_5;
        }
        else
        {
            if(replay_2)
            {
                viewed_1 = _S1424;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                bool _S1478 = !scatter_2;
                if(_S1478)
                {
                    refracted_4 = true;
                }
                else
                {
                    bool _S1479 = _S1217 != 1U;
                    if(_S1479)
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
                bool _S1480 = _S1217 == 2U;
                if(_S1480)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1383;
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
                    if(_S1393)
                    {
                        return _S1213;
                    }
                    uint _S1481 = stream(_S1240, b_8 + 448U);
                    FKRay _S1482 = ray_2;
                    FKSurface _S1483 = surface_11;
                    ShadowContext _S1484 = context_5;
                    SkySample _S1485 = sampleSky_0(&_S1482, &_S1483, _S1388, is_inside_6, _S1481, surface_11.random_state, &_S1484);
                    return Shift_x24init_0(throughput_5 * _S1485.color, 1.0f);
                }
                if(_S1480)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1383;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float _S1486 = rgb_to_greyscale(light_3.radiance);
                    bool _S1487 = !(_S1486 > 0.0f);
                    if(_S1487)
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
                    passes_0 = !_S1383;
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
                bool _S1488 = !replay_2;
                if(_S1488)
                {
                    wrong_side_0 = scatter_2;
                }
                else
                {
                    wrong_side_0 = false;
                }
                if(wrong_side_0)
                {
                    bool _S1489 = b_8 > 0U;
                    if(_S1489)
                    {
                        Reservoir candidate_5 = chain_0;
                        if(_S1414)
                        {
                            float3  _S1490 = safeDivide(throughput_5 * emission_1, chain_throughput_0);
                            (&candidate_5)->radiance = _S1490;
                        }
                        else
                        {
                            if(_S1383)
                            {
                                candidate_5 = here_0;
                            }
                        }
                        float3  _S1491 = throughput_5 * emission_1;
                        Reservoir _S1492 = withEnd(candidate_5, 1U, b_8, _S1491);
                        offer(sel_7, _S1492, _S1491 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    else
                    {
                        float3  _S1493 = throughput_5 * emission_1;
                        float3  _S1494 = sel_7->glow + _S1493;
                        sel_7->glow = _S1494;
                    }
                    if(nee_0)
                    {
                        float3  _S1495 = throughput_5 * lit_0;
                        Reservoir candidate_6 = chain_0;
                        if(_S1414)
                        {
                            float3  _S1496 = safeDivide(_S1495, chain_throughput_0);
                            (&candidate_6)->radiance = _S1496;
                        }
                        else
                        {
                            if(_S1383)
                            {
                                candidate_6 = here_0;
                                uint _S1497 = insertBits_0((&candidate_6)->path, 1U, 19U, 1U);
                                (&candidate_6)->path = _S1497;
                                (&candidate_6)->dir = light_3.dir;
                                (&candidate_6)->radiance = light_3.radiance;
                            }
                            else
                            {
                                uint _S1498 = insertBits_0(0U, b_8 + 1U, 5U, 5U);
                                uint _S1499 = insertBits_0(_S1498, 2U, 10U, 2U);
                                (&candidate_6)->path = _S1499;
                            }
                        }
                        Reservoir _S1500 = withEnd(candidate_6, 0U, b_8, _S1495);
                        offer(sel_7, _S1500, _S1495 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    if(nee_0)
                    {
                        if(_S1393)
                        {
                            _S1468 = false;
                        }
                        else
                        {
                            bool _S1501 = environmentMapped_0();
                            _S1468 = _S1501;
                        }
                    }
                    else
                    {
                        _S1468 = false;
                    }
                    if(_S1468)
                    {
                        uint _S1502 = (fcptMaxBounces());
                        _S1469 = b_8 < _S1502;
                    }
                    else
                    {
                        _S1469 = false;
                    }
                    if(_S1469)
                    {
                        uint _S1503 = stream(_S1240, b_8 + 448U);
                        FKRay _S1504 = ray_2;
                        FKSurface _S1505 = surface_11;
                        ShadowContext _S1506 = context_5;
                        SkySample _S1507 = sampleSky_0(&_S1504, &_S1505, _S1388, is_inside_6, _S1503, surface_11.random_state, &_S1506);
                        float3  _S1508 = throughput_5 * _S1507.color;
                        Reservoir candidate_7 = chain_0;
                        if(_S1414)
                        {
                            float3  _S1509 = safeDivide(_S1508, chain_throughput_0);
                            (&candidate_7)->radiance = _S1509;
                        }
                        else
                        {
                            if(_S1383)
                            {
                                candidate_7 = here_0;
                                uint _S1510 = insertBits_0((&candidate_7)->path, 1U, 19U, 1U);
                                (&candidate_7)->path = _S1510;
                                (&candidate_7)->dir = _S1507.dir;
                                (&candidate_7)->radiance = _S1507.radiance;
                            }
                            else
                            {
                                uint _S1511 = insertBits_0(0U, b_8 + 1U, 5U, 5U);
                                uint _S1512 = insertBits_0(_S1511, 2U, 10U, 2U);
                                (&candidate_7)->path = _S1512;
                            }
                        }
                        Reservoir _S1513 = withEnd(candidate_7, 4U, b_8, _S1508);
                        offer(sel_7, _S1513, _S1508 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                }
            }
            throughput_6 = throughput_5;
            density_4 = density_2;
        }
        bool _S1514;
        bool straight_0;
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
        bool _S1527;
        bool _S1528;
        float density_6;
        float sky_pdf_2;
        float spread_5;
        uint b_11;
        float3  throughput_8;
        float3  throughput_9;
        float3  throughput_10;
        if(scatter_2)
        {
            if(replay_2)
            {
                viewed_1 = _S1424;
            }
            else
            {
                viewed_1 = false;
            }
            uint _S1529 = extractBits_0(_S1214, 15U, 2U);
            uint _S1530 = extractBits_0(_S1214, 17U, 2U);
            uint _S1531 = _slang_select(_S1423, _S1530,_S1529);
            float3  _S1532 = r_12->dir;
            bool refracted_5 = _S1531 == 1U;
            SampleBSDF _S1533 = SampleBSDF_x24init_0(_S1212, _S1212, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_13 = _S1533;
            float3  reconnection_1;
            SampleBSDF _S1534;
            if(viewed_1)
            {
                uint _S1535 = extractBits_0(_S1214, 20U, 1U);
                bool _S1536 = is_inside_6 != (_S1535 == 1U);
                if(_S1536)
                {
                    return _S1213;
                }
                bool _S1537 = _S1217 == 1U;
                if(_S1537)
                {
                    float3  _S1538 = (fcptHitPosition((_S1229)));
                    throughput_8 = _S1538;
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
                    BSDFMaterial _S1539 = _S1384.material;
                    bool _S1540 = isTranslucent_0(&_S1539);
                    if(_S1540)
                    {
                        refracted_4 = _S1531 == 0U;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                    if(refracted_4)
                    {
                        float3  _S1541 = throughput_8 - (&ray_2)->origin;
                        float3  _S1542 = _slang_select(_S1537, _S1541,_S1532);
                        wrong_side_0 = (dot_0(_S1385.smooth_n, _S1542) * _S1386) < 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    refracted_4 = wrong_side_0;
                }
                if(_S1537)
                {
                    float3  _S1543 = (&ray_2)->origin;
                    FKSurface _S1544 = surface_11;
                    float3  _S1545 = - _S1385.smooth_n;
                    bool _S1546 = is_inside_6 != refracted_4;
                    float3  _S1547 = _slang_select(_S1546, _S1545,_S1385.smooth_n);
                    float3  _S1548 = throughput_8 - (_S1543 + make_float3 (_S1544.geometry_offset) * _S1547);
                    float3  _S1549 = ((((_S1548)) * make_float3(rnorm3df(((_S1548)).x, ((_S1548)).y, ((_S1548)).z))));
                    reconnection_1 = _S1549;
                }
                else
                {
                    reconnection_1 = _S1532;
                }
                if(_S1393)
                {
                    wrong_side_0 = false;
                }
                else
                {
                    bool _S1550 = wrongSide_0(is_inside_6, refracted_4, reconnection_1, surface_11.geometry_n);
                    wrong_side_0 = _S1550;
                }
                if(wrong_side_0)
                {
                    return _S1213;
                }
                float3  _S1551 = throughput_8;
                throughput_8 = reconnection_1;
                b_11 = _S1531;
                wrong_side_0 = false;
                reconnection_1 = _S1551;
            }
            else
            {
                bool _S1552 = !_S1423;
                if(_S1552)
                {
                    SampleBSDF bsdf_sampled_0;
                    if(_S1393)
                    {
                        SampleBSDF _S1553 = (fcptSampleHair((surface_11.hair), (_S1384.material.albedo), (_S1384.material.specular_tint), ((&ray_2)->unit_direction), (surface_11.random_state)));
                        _S1534 = _S1553;
                    }
                    else
                    {
                        SampleBSDF _S1554 = sampleBSDF((&ray_2)->unit_direction, _S1385.smooth_n, _S1384.material, _S1388.x, _S1388.y, surface_11.random_state, _S1440);
                        _S1534 = _S1554;
                    }
                    bsdf_sampled_0 = _S1534;
                    if(_S1393)
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
                            return _S1213;
                        }
                        break;
                    }
                    if(_S1393)
                    {
                        wrong_side_0 = false;
                    }
                    else
                    {
                        bool _S1555 = wrongSide_0(is_inside_6, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, surface_11.geometry_n);
                        wrong_side_0 = _S1555;
                    }
                    if(wrong_side_0)
                    {
                        _S1468 = (_S1384.material.transmission) > 0.0f;
                    }
                    else
                    {
                        _S1468 = false;
                    }
                    if(_S1468)
                    {
                        SampleBSDF _S1556 = sampleBSDF((&bsdf_sampled_0)->unit_direction, surface_11.geometry_n, _S1384.material, _S1388.x, _S1388.y, (&bsdf_sampled_0)->random_state, _S1440);
                        (&bsdf_sampled_0)->unit_direction = _S1556.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1556.refracted;
                        (&bsdf_sampled_0)->throughput = _S1556.throughput;
                    }
                    else
                    {
                        if(wrong_side_0)
                        {
                            float3  _S1557 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, surface_11.geometry_n)) * surface_11.geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1557;
                        }
                    }
                    uint _S1558 = (&bsdf_sampled_0)->lobe;
                    float3  _S1559 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1560 = (&bsdf_sampled_0)->refracted;
                    lobe_13 = bsdf_sampled_0;
                    float _S1561 = (&bsdf_sampled_0)->pdf;
                    float _S1562 = _slang_select(wrong_side_0, 0.0f,_S1561);
                    (&lobe_13)->pdf = _S1562;
                    throughput_8 = _S1559;
                    b_11 = _S1558;
                    refracted_4 = _S1560;
                }
                else
                {
                    throughput_8 = _S1532;
                    b_11 = _S1531;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(viewed_1)
            {
                _S1468 = true;
            }
            else
            {
                _S1468 = _S1423;
            }
            if(_S1468)
            {
                if(_S1393)
                {
                    SampleBSDF _S1563 = (fcptConnectHair((surface_11.hair), (_S1384.material.albedo), (_S1384.material.specular_tint), ((&ray_2)->unit_direction), (throughput_8)));
                    _S1534 = _S1563;
                }
                else
                {
                    SampleBSDF _S1564 = connectBSDF((&ray_2)->unit_direction, throughput_8, _S1385.smooth_n, _S1384.material, _S1388.x, _S1388.y, b_11, surface_11.random_state);
                    _S1534 = _S1564;
                }
                lobe_13 = _S1534;
            }
            if(_S1393)
            {
                _S1469 = false;
            }
            else
            {
                bool _S1565 = b_11 != 0U;
                if(_S1565)
                {
                    bool _S1566 = (_S1384.material.roughness) == 0.0f;
                    if(_S1566)
                    {
                        _S1469 = true;
                    }
                    else
                    {
                        bool _S1567 = b_11 == 1U;
                        if(_S1567)
                        {
                            _S1469 = (_S1388.x) == (_S1388.y);
                        }
                        else
                        {
                            _S1469 = false;
                        }
                    }
                }
                else
                {
                    _S1469 = false;
                }
            }
            bool _S1568 = !_S1393;
            if(_S1568)
            {
                _S1514 = b_11 == 1U;
            }
            else
            {
                _S1514 = false;
            }
            if(_S1514)
            {
                straight_0 = (_S1384.material.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S1515 = _S1568;
            }
            else
            {
                _S1515 = false;
            }
            if(_S1515)
            {
                _S1516 = b_11 == 1U;
            }
            else
            {
                _S1516 = false;
            }
            if(_S1516)
            {
                _S1517 = (_S1388.x) == (_S1388.y);
            }
            else
            {
                _S1517 = false;
            }
            BSDFMaterial _S1569 = _S1384.material;
            bool _S1570 = isTranslucent_0(&_S1569);
            if(_S1570)
            {
                _S1518 = b_11 == 0U;
            }
            else
            {
                _S1518 = false;
            }
            if(_S1518)
            {
                _S1519 = (dot_0(throughput_8, surface_11.geometry_n)) < 0.0f;
            }
            else
            {
                _S1519 = false;
            }
            if(nee_0)
            {
                _S1520 = !_S1469;
            }
            else
            {
                _S1520 = false;
            }
            if(_S1520)
            {
                _S1521 = !wrong_side_0;
            }
            else
            {
                _S1521 = false;
            }
            if(_S1521)
            {
                float _S1571 = (&lobe_13)->pdf;
                float3  _S1572 = (&ray_2)->origin;
                float3  _S1573 = _slang_select(_S1398, _S1212,_S1385.smooth_n);
                float3  _S1574 = (&ray_2)->origin;
                FKSurface _S1575 = surface_11;
                float3  _S1576 = - _S1385.smooth_n;
                float3  _S1577 = _slang_select(_S1519, _S1576,_S1385.smooth_n);
                NEEVertex _S1578 = NEEVertex_x24init_0(false, _S1571, _S1572, _S1573, _S1574 + make_float3 (_S1575.geometry_offset) * _S1577);
                nee_vertex_0 = _S1578;
            }
            else
            {
                if(_S1393)
                {
                    _S1522 = true;
                }
                else
                {
                    bool _S1579 = b_11 != 1U;
                    if(_S1579)
                    {
                        _S1522 = true;
                    }
                    else
                    {
                        _S1522 = (_S1388.x) != (_S1388.y);
                    }
                }
                if(_S1522)
                {
                    (&nee_vertex_0)->none = true;
                }
            }
            bool _S1580 = b_11 == 0U;
            bool _S1581 = withinInverseFootprint((&lobe_13)->pdf, _S1580, (&prev_0)->cos, (&hit_4)->distance, threshold_2);
            bool _S1582 = roughLobe((&lobe_13)->pdf, _S1580, _S1384.material.roughness);
            if(_S1423)
            {
                bool _S1583 = !_S1581;
                if(_S1583)
                {
                    return _S1213;
                }
                bool _S1584 = _S1218 != 1U;
                if(_S1584)
                {
                    _S1522 = _S1218 != 2U;
                }
                else
                {
                    _S1522 = false;
                }
                if(_S1522)
                {
                    float _S1585 = (&lobe_13)->pdf;
                    float _S1586 = _slang_select(nee_0, _S1585,0.0f);
                    float _S1587 = escapeWeight_0(_S1586, _S1532);
                    if(_S1431)
                    {
                        passes_0 = _S1224;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1588 = _slang_select(passes_0, _S1587,1.0f);
                    return Shift_x24init_0(throughput_6 * ((&lobe_13)->throughput * make_float3 ((&lobe_13)->pdf)) * r_12->radiance * make_float3 (_S1588) / make_float3 (r_12->jac), density_4 * (&lobe_13)->pdf / r_12->jac);
                }
                float3  _S1589 = throughput_6 * make_float3 ((&lobe_13)->pdf);
                float _S1590 = density_4 * (&lobe_13)->pdf;
                throughput_9 = _S1589;
                density_6 = _S1590;
            }
            else
            {
                throughput_9 = throughput_6;
                density_6 = density_4;
            }
            uint _S1591 = (fcptLayers((hit_4)));
            bool _S1592 = b_11 == 1U;
            bool _S1593 = passesLayer_0(_S1591, _S1592, passes_0);
            if(viewed_1)
            {
                _S1522 = _S1593;
            }
            else
            {
                _S1522 = false;
            }
            if(_S1522)
            {
                return _S1213;
            }
            if(replay_2)
            {
                _S1523 = b_8 <= _S1228;
            }
            else
            {
                _S1523 = false;
            }
            if(_S1523)
            {
                _S1524 = _S1383;
            }
            else
            {
                _S1524 = false;
            }
            if(_S1524)
            {
                _S1525 = _S1581;
            }
            else
            {
                _S1525 = false;
            }
            if(_S1525)
            {
                _S1526 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S1526 = !_S1582;
                }
                else
                {
                    _S1526 = false;
                }
            }
            if(_S1526)
            {
                return _S1213;
            }
            if(viewed_1)
            {
                float3  _S1594 = throughput_9 * ((&lobe_13)->throughput * make_float3 ((&lobe_13)->pdf));
                float _S1595 = (&lobe_13)->pdf;
                throughput_10 = _S1594;
                sky_pdf_2 = _S1595;
            }
            else
            {
                float3  _S1596 = throughput_9 * max_0((&lobe_13)->throughput, _S1212);
                throughput_10 = _S1596;
                sky_pdf_2 = density_6;
            }
            bool _S1597 = !replay_2;
            if(_S1597)
            {
                _S1527 = !_S1414;
            }
            else
            {
                _S1527 = false;
            }
            if(_S1527)
            {
                _S1528 = _S1383;
            }
            else
            {
                _S1528 = false;
            }
            bool _S1598;
            if(_S1528)
            {
                _S1598 = _S1581;
            }
            else
            {
                _S1598 = false;
            }
            float3  chain_throughput_1;
            if(_S1598)
            {
                chain_0 = here_0;
                uint _S1599 = insertBits_0((&chain_0)->path, b_11, 17U, 2U);
                uint _S1600 = _slang_select(nee_0, 1U,0U);
                uint _S1601 = insertBits_0(_S1599, _S1600, 19U, 1U);
                (&chain_0)->path = _S1601;
                float _S1602 = (&chain_0)->jac * (&lobe_13)->pdf;
                (&chain_0)->jac = _S1602;
                (&chain_0)->dir = throughput_8;
                chain_throughput_1 = throughput_10;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            FKSurface _S1603 = surface_11;
            Vertex _S1604 = Vertex_x24init_0(_S1582, b_11, (&lobe_13)->pdf, (F32_abs((dot_0(surface_11.geometry_n, throughput_8)))), is_inside_6);
            prev_0 = _S1604;
            float _S1605 = (&lobe_13)->pdf;
            bool _S1606;
            if(_S1592)
            {
                _S1606 = (_S1388.x) == (_S1388.y);
            }
            else
            {
                _S1606 = false;
            }
            float sky_pdf_3 = _slang_select(_S1606, sky_pdf_0,_S1605);
            float _S1607 = _slang_select(_S1393, 0.0f,sky_pdf_3);
            float _S1608 = widened_0(spread_2, (&lobe_13)->pdf, _S1469);
            bool _S1609;
            if(refracted_4)
            {
                _S1609 = !_S1519;
            }
            else
            {
                _S1609 = false;
            }
            bool is_inside_7;
            if(_S1609)
            {
                bool _S1610 = !is_inside_6;
                is_inside_7 = _S1610;
            }
            else
            {
                is_inside_7 = is_inside_6;
            }
            FKSurface _S1611 = surface_11;
            bool _S1612 = boundsVolume_0(&_S1611);
            bool _S1613;
            if(_S1612)
            {
                _S1613 = !_S1593;
            }
            else
            {
                _S1613 = false;
            }
            if(_S1613)
            {
                FKSurface faced_2 = surface_11;
                float3  _S1614 = - _S1603.geometry_n;
                float3  _S1615 = _slang_select(turned_1, _S1614,_S1603.geometry_n);
                (&faced_2)->geometry_n = _S1615;
                FKMedium _S1616 = Medium_x24init_0(scatter_in_0, extinction_in_0, g_in_0);
                FKMedium _S1617 = (fcptOutsideMedium((hit_4)));
                FKSurface _S1618 = faced_2;
                FKMedium _S1619 = _S1616;
                FKMedium _S1620 = _S1617;
                MediumSides _S1621 = mediumSides_0(&_S1618, &_S1619, filling_2, (&ray_2)->unit_direction, &_S1620);
                bool _S1622 = leavesInFront_0((&faced_2)->geometry_n, throughput_8, _S1603.geometry_n);
                float3  _S1623 = _slang_select(_S1622, _S1621.front.scatter,_S1621.behind.scatter);
                scatter_in_0 = _S1623;
                float3  _S1624 = _slang_select(_S1622, _S1621.front.extinction,_S1621.behind.extinction);
                extinction_in_0 = _S1624;
                float _S1625 = _slang_select(_S1622, _S1621.front.g,_S1621.behind.g);
                g_in_0 = _S1625;
                uint _S1626 = _S1621.fillings.x;
                uint _S1627 = _S1621.fillings.y;
                uint _S1628 = _slang_select(_S1622, _S1627,_S1626);
                bool _S1629 = (fcptVaryingUsed());
                uint _S1630 = _slang_select(_S1629, _S1628,4294967295U);
                filling_2 = _S1630;
            }
            (&ray_2)->unit_direction = throughput_8;
            bool _S1631 = !_S1593;
            if(_S1631)
            {
                FKSurface _S1632 = surface_11;
                float _S1633 = _slang_select(straight_0, 0.0f,_S1632.geometry_offset);
                float3  _S1634 = - _S1385.smooth_n;
                bool _S1635 = is_inside_7 != _S1519;
                float3  _S1636 = _slang_select(_S1635, _S1634,_S1385.smooth_n);
                float3  _S1637 = (&ray_2)->origin + make_float3 (_S1633) * _S1636;
                (&ray_2)->origin = _S1637;
            }
            throughput_9 = throughput_10;
            chain_throughput_0 = chain_throughput_1;
            density_6 = sky_pdf_2;
            passes_0 = _S1593;
            viewed_1 = _S1517;
            sky_pdf_2 = _S1607;
            spread_5 = _S1608;
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
            spread_5 = spread_2;
            straight_0 = false;
            is_inside_5 = is_inside_6;
        }
        bool _S1638 = !replay_2;
        float density_7;
        if(_S1638)
        {
            if(_S1354)
            {
                float3  _S1639 = throughput_9 * emission_1;
                Reservoir candidate_8 = chain_0;
                uint _S1640 = extractBits_0((&chain_0)->path, 10U, 2U);
                bool _S1641 = _S1640 == 1U;
                if(_S1641)
                {
                    float3  _S1642 = safeDivide(_S1639, chain_throughput_0);
                    (&candidate_8)->radiance = _S1642;
                }
                Reservoir _S1643 = withEnd(candidate_8, 2U, b_8, _S1639);
                offer(sel_7, _S1643, _S1639 * make_float3 (scale_3) / make_float3 (density_6));
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
                float _S1644 = survivalProbability(throughput_9, density_6);
                density_7 = _S1644;
            }
            else
            {
                density_7 = 1.0f;
            }
            uint _S1645 = stream(_S1240, b_8 + 128U);
            Random _S1646 = pcg(_S1645);
            bool _S1647 = density_7 < (_S1646.value);
            if(_S1647)
            {
                wrong_side_0 = true;
            }
            else
            {
                uint _S1648 = (fcptMaxBounces());
                wrong_side_0 = b_8 >= _S1648;
            }
            if(wrong_side_0)
            {
                break;
            }
            float _S1649 = density_6 * density_7;
            density_7 = _S1649;
        }
        else
        {
            density_7 = density_6;
        }
        uint _S1650 = layer_0 ^ 1U;
        uint _S1651 = _slang_select(passes_0, _S1650,0U);
        if(passes_0)
        {
            (&prev_0)->rough = false;
            (&hit_4)->distance = 0.0f;
            b_11 = b_8;
            viewed_0 = viewed_1;
            throughput_2 = throughput_9;
            density_2 = density_7;
            sky_pdf_0 = sky_pdf_2;
            spread_2 = spread_5;
            uint _S1652 = b_11 + 1U;
            b_8 = _S1652;
            layer_0 = _S1651;
            continue;
        }
        FKRay _S1653 = ray_2;
        float _S1654 = distance_1(reconnection_0, (&ray_2)->origin) * 1.0010000467300415f;
        if(replay_2)
        {
            refracted_4 = _S1424;
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
        float _S1655 = _slang_select(wrong_side_0, _S1654,4.294967296e+09f);
        bool _S1656 = !_S1393;
        if(straight_0)
        {
            _S1468 = true;
        }
        else
        {
            _S1468 = _S1393;
        }
        FKHit _S1657;
        if(_S1468)
        {
            _S1657 = hit_4;
        }
        else
        {
            _S1657 = _S1441;
        }
        FKHit _S1658 = (fcptTraverseInstanceBVH((_S1653), (_S1359), (_S1655), (_S1656), (_S1657), (viewed_1)));
        hit_4 = _S1658;
        if(replay_2)
        {
            _S1469 = _S1424;
        }
        else
        {
            _S1469 = false;
        }
        if(_S1469)
        {
            _S1514 = _S1217 == 1U;
        }
        else
        {
            _S1514 = false;
        }
        if(_S1514)
        {
            _S1515 = ((&hit_4)->instance_index) == (_S1229.instance_index);
        }
        else
        {
            _S1515 = false;
        }
        if(_S1515)
        {
            _S1516 = ((&hit_4)->triangle_index) == (_S1229.triangle_index);
        }
        else
        {
            _S1516 = false;
        }
        if(_S1516)
        {
            (&hit_4)->uv = _S1229.uv;
            float _S1659 = distance_1(reconnection_0, (&ray_2)->origin);
            (&hit_4)->distance = _S1659;
        }
        if(replay_2)
        {
            _S1517 = _S1424;
        }
        else
        {
            _S1517 = false;
        }
        if(_S1517)
        {
            _S1518 = _S1217 == 3U;
        }
        else
        {
            _S1518 = false;
        }
        if(_S1518)
        {
            _S1519 = ((&hit_4)->instance_index) != 4294967295U;
        }
        else
        {
            _S1519 = false;
        }
        if(_S1519)
        {
            return _S1213;
        }
        Reservoir _S1660 = chain_0;
        uint _S1661 = filling_2;
        for(;;)
        {
            bool _S1662 = (fcptVaryingUsed());
            if(_S1662)
            {
                _S1520 = _S1661 != 4294967295U;
            }
            else
            {
                _S1520 = false;
            }
            float _S1663;
            if(_S1520)
            {
                float _S1664 = (fcptMajorant((_S1661)));
                _S1663 = _S1664;
            }
            else
            {
                _S1663 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
            }
            if(replay_2)
            {
                _S1521 = _S1424;
            }
            else
            {
                _S1521 = false;
            }
            if(_S1521)
            {
                _S1522 = _S1217 == 1U;
            }
            else
            {
                _S1522 = false;
            }
            if(_S1522)
            {
                _S1523 = _S1663 > 0.0f;
            }
            else
            {
                _S1523 = false;
            }
            if(_S1523)
            {
                ended_0 = _S1213;
                sky_pdf_1 = sky_pdf_2;
                spread_3 = spread_5;
                width_4 = width_3;
                density_3 = density_7;
                throughput_10 = throughput_9;
                b_11 = b_8;
                _S1524 = true;
                break;
            }
            bool _S1665 = (&prev_0)->rough;
            if(_S1665)
            {
                _S1524 = !(_S1663 > 0.0f);
            }
            else
            {
                _S1524 = false;
            }
            (&prev_0)->rough = _S1524;
            uint _S1666 = b_8 + 320U;
            bool _S1667 = b_8 == 4294967295U;
            uint _S1668 = _slang_select(_S1667, 384U,_S1666);
            uint _S1669 = stream(_S1240, _S1668);
            uint tracking_1 = _S1669;
            weight_1 = throughput_3;
            glowed_0 = _S1212;
            b_11 = b_8;
            throughput_10 = throughput_9;
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
                    _S1211 = int(2);
                    break;
                }
                uint _S1670 = b_11 + 320U;
                bool _S1671 = b_11 == 4294967295U;
                uint _S1672 = _slang_select(_S1671, 384U,_S1670);
                uint _S1673 = stream(_S1240, _S1672);
                Random _S1674 = pcg(_S1673);
                float _S1675 = freeFlight_0(_S1674.value, _S1663);
                if(_S1520)
                {
                    float3  _S1676 = (&ray_2)->origin;
                    float3  _S1677 = (&ray_2)->unit_direction;
                    float _S1678 = (&hit_4)->distance;
                    uint _S1679 = _slang_select(_S1671, 0U,b_11);
                    uint _S1680 = (&prev_0)->lobe;
                    uint _S1681 = _slang_select(_S1671, 3U,_S1680);
                    float _S1682 = (fcptTrackMedium((_S1661), (_S1676), (_S1677), (_S1678), (&tracking_1), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1679), (_S1681), (_S1671)));
                    spread_4 = _S1682;
                }
                else
                {
                    spread_4 = _S1675;
                }
                bool _S1683 = !(spread_4 < ((&hit_4)->distance));
                if(_S1683)
                {
                    _S1211 = int(2);
                    break;
                }
                if(_S1520)
                {
                    _S1525 = _S1638;
                }
                else
                {
                    _S1525 = false;
                }
                if(_S1525)
                {
                    float3  _S1684 = throughput_10 * glowed_0 / make_float3 (density_3);
                    float3  _S1685 = sel_7->glow + _S1684;
                    sel_7->glow = _S1685;
                }
                else
                {
                }
                glowed_0 = _S1212;
                uint b_12 = b_11 + 1U;
                float3  _S1686 = (&ray_2)->origin + make_float3 (spread_4) * (&ray_2)->unit_direction;
                (&ray_2)->origin = _S1686;
                float3  _S1687 = flightWeight_0(scatter_in_0, extinction_in_0, _S1663, spread_4, true);
                float3  _S1688 = weight_1;
                float3  _S1689 = _slang_select(_S1520, _S1688,_S1687);
                float3  throughput_11 = throughput_10 * _S1689;
                uint _S1690 = stream(_S1240, b_12 + 320U);
                tracking_1 = _S1690;
                weight_1 = throughput_3;
                float width_7 = width_4 + spread_3 * spread_4;
                float _S1691 = spread_3 + 3.14159274101257324f;
                bool _S1692 = scatterSampled_0(replay_2, b_12, _S1228, _S1520);
                TreeSample light_4;
                if(_S1692)
                {
                    float3  _S1693 = (&ray_2)->origin;
                    float3  _S1694 = (&ray_2)->unit_direction;
                    float3  _S1695 = (&ray_2)->unit_direction;
                    uint _S1696 = stream(_S1240, b_12 + 64U);
                    float3  _S1697 = extinction_in_0;
                    float3  _S1698 = extinction_in_0;
                    uint2  _S1699 = make_uint2 (_S1661);
                    float3  _S1700 = (&ray_2)->unit_direction;
                    uint _S1701 = arrivalLobe_0(b_12, (&prev_0)->lobe);
                    FKHit _S1702 = _S1441;
                    ShadowContext _S1703 = ShadowContext_x24init_0(_S1697, _S1698, _S1699, _S1700, b_12, _S1701, false, spread_4, width_7, &_S1702, false);
                    ShadowContext _S1704 = _S1703;
                    TreeSample _S1705 = sampleLightTree_0(_S1693, _S1694, _S1695, 0.0f, true, _S1696, &_S1704);
                    light_4 = _S1705;
                }
                else
                {
                    light_4 = _S1438;
                }
                float _S1706 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_4.dir));
                uint _S1707 = (fcptMaxBounces());
                bool _S1708 = b_12 < _S1707;
                if(_S1708)
                {
                    _S1526 = (light_4.density) > 0.0f;
                }
                else
                {
                    _S1526 = false;
                }
                float _S1709 = _slang_select(_S1526, _S1706,0.0f);
                float3  _S1710 = throughput_11 * light_4.radiance;
                float _S1711 = powerHeuristic(light_4.density, _S1709);
                float3  _S1712 = _S1710 * make_float3 (_S1706 * _S1711);
                float3  _S1713 = _slang_select(_S1692, _S1712,_S1212);
                if(replay_2)
                {
                    _S1527 = b_12 == _S1228;
                }
                else
                {
                    _S1527 = false;
                }
                if(_S1527)
                {
                    bool _S1714 = _S1217 == 2U;
                    if(_S1714)
                    {
                        float _S1715 = rgb_to_greyscale(_S1713);
                        _S1528 = _S1715 > 0.0f;
                    }
                    else
                    {
                        _S1528 = false;
                    }
                    if(_S1528)
                    {
                        Shift _S1716 = Shift_x24init_0(_S1713, 1.0f);
                        _S1211 = int(1);
                        ended_0 = _S1716;
                        spread_4 = _S1691;
                        width_5 = width_7;
                        throughput_8 = throughput_11;
                        b_9 = b_12;
                        break;
                    }
                    _S1211 = int(1);
                    ended_0 = _S1213;
                    spread_4 = _S1691;
                    width_5 = width_7;
                    throughput_8 = throughput_11;
                    b_9 = b_12;
                    break;
                }
                if(_S1638)
                {
                    Reservoir candidate_9 = _S1660;
                    uint _S1717 = extractBits_0(_S1660.path, 10U, 2U);
                    bool _S1718 = _S1717 == 1U;
                    if(_S1718)
                    {
                        float3  _S1719 = safeDivide(_S1713, chain_throughput_0);
                        (&candidate_9)->radiance = _S1719;
                    }
                    else
                    {
                        uint _S1720 = insertBits_0(0U, b_12 + 1U, 5U, 5U);
                        uint _S1721 = insertBits_0(_S1720, 2U, 10U, 2U);
                        (&candidate_9)->path = _S1721;
                    }
                    Reservoir _S1722 = withEnd(candidate_9, 0U, b_12, _S1713);
                    offer(sel_7, _S1722, _S1713 * make_float3 (scale_3) / make_float3 (density_3));
                    float _S1723 = survivalProbability(throughput_11, density_3);
                    uint _S1724 = stream(_S1240, b_12 + 128U);
                    Random _S1725 = pcg(_S1724);
                    bool _S1726 = _S1723 < (_S1725.value);
                    if(_S1726)
                    {
                        _S1528 = true;
                    }
                    else
                    {
                        uint _S1727 = (fcptMaxBounces());
                        _S1528 = b_12 >= _S1727;
                    }
                    if(_S1528)
                    {
                        _S1211 = int(1);
                        ended_0 = _S1213;
                        spread_4 = _S1691;
                        width_5 = width_7;
                        throughput_8 = throughput_11;
                        b_9 = b_12;
                        break;
                    }
                    float _S1728 = density_3 * _S1723;
                    density_3 = _S1728;
                }
                else
                {
                }
                float phase_pdf_1 = 0.0f;
                uint _S1729 = stream(_S1240, b_12);
                float3  _S1730 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1729, &phase_pdf_1);
                (&ray_2)->unit_direction = _S1730;
                NEEVertex _S1731 = NEEVertex_x24init_0(false, phase_pdf_1, (&ray_2)->origin, _S1212, (&ray_2)->origin);
                nee_vertex_0 = _S1731;
                Vertex _S1732 = scatteredVertex_0(is_inside_5);
                prev_0 = _S1732;
                float _S1733 = (&prev_0)->pdf;
                FKRay _S1734 = ray_2;
                FKHit _S1735 = (fcptTraverseInstanceBVH((_S1734), (true), (4.294967296e+09f), (false), (_S1441), (false)));
                hit_4 = _S1735;
                b_11 = b_12;
                throughput_10 = throughput_11;
                spread_3 = _S1691;
                width_4 = width_7;
                sky_pdf_1 = _S1733;
            }
            if(_S1211 != int(2))
            {
                spread_3 = spread_4;
                width_4 = width_5;
                throughput_10 = throughput_8;
                b_11 = b_9;
                _S1524 = true;
                break;
            }
            ended_0 = _S1213;
            _S1524 = false;
            break;
        }
        if(_S1524)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S1525 = b_11 == b_8;
        }
        else
        {
            _S1525 = false;
        }
        bool _S1736 = ((&hit_4)->instance_index) == 4294967295U;
        if(_S1736)
        {
            bool _S1737 = !(&nee_vertex_0)->none;
            float _S1738 = _slang_select(_S1737, sky_pdf_1,0.0f);
            float _S1739 = escapeWeight_0(_S1738, (&ray_2)->unit_direction);
            float3  _S1740 = environment_0((&ray_2)->unit_direction, b_11, (&prev_0)->lobe);
            float3  _S1741 = throughput_10 * _S1740;
            if(replay_2)
            {
                bool _S1742 = b_11 == _S1228;
                if(_S1742)
                {
                    passes_0 = _S1217 == 3U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(_S1741 * make_float3 (_S1739) / make_float3 (r_12->jac), density_3 / r_12->jac);
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
                    passes_0 = b_11 == _S1215;
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
                    return Shift_x24init_0(_S1741 * make_float3 (_S1739), 1.0f);
                }
                return _S1213;
            }
            Reservoir candidate_10 = chain_0;
            uint _S1743 = extractBits_0((&chain_0)->path, 10U, 2U);
            bool _S1744 = _S1743 == 1U;
            if(_S1744)
            {
                uint _S1745 = extractBits_0((&chain_0)->path, 5U, 5U);
                bool _S1746 = _S1745 == b_11;
                float _S1747 = _slang_select(_S1746, 1.0f,_S1739);
                float3  _S1748 = safeDivide(_S1741 * make_float3 (_S1747), chain_throughput_0);
                (&candidate_10)->radiance = _S1748;
            }
            else
            {
                bool _S1749 = (&prev_0)->rough;
                if(_S1749)
                {
                    uint _S1750 = insertBits_0(0U, b_11 + 1U, 5U, 5U);
                    uint _S1751 = insertBits_0(_S1750, 3U, 10U, 2U);
                    uint _S1752 = insertBits_0(_S1751, (&prev_0)->lobe, 15U, 2U);
                    bool _S1753 = (&prev_0)->inside;
                    uint _S1754 = _slang_select(_S1753, 1U,0U);
                    uint _S1755 = insertBits_0(_S1752, _S1754, 20U, 1U);
                    (&candidate_10)->path = _S1755;
                    (&candidate_10)->jac = (&prev_0)->pdf;
                    (&candidate_10)->dir = (&ray_2)->unit_direction;
                }
            }
            float3  _S1756 = _S1741 * make_float3 (_S1739);
            Reservoir _S1757 = withEnd(candidate_10, 3U, b_11, _S1756);
            offer(sel_7, _S1757, _S1756 * make_float3 (scale_3) / make_float3 (density_3));
            break;
        }
        float3  _S1758 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
        (&ray_2)->origin = _S1758;
        bool _S1759 = (fcptVaryingUsed());
        if(_S1759)
        {
            _S1526 = filling_2 != 4294967295U;
        }
        else
        {
            _S1526 = false;
        }
        if(_S1526)
        {
            if(_S1638)
            {
                float3  _S1760 = throughput_10 * glowed_0 / make_float3 (density_3);
                float3  _S1761 = sel_7->glow + _S1760;
                sel_7->glow = _S1761;
            }
            float3  _S1762 = throughput_10 * weight_1;
            throughput_8 = _S1762;
        }
        else
        {
            float3  _S1763 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
            float3  _S1764 = throughput_10 * _S1763;
            throughput_8 = _S1764;
        }
        float _S1765 = width_4 + spread_3 * (&hit_4)->distance;
        viewed_0 = _S1525;
        width_3 = _S1765;
        throughput_2 = throughput_8;
        density_2 = density_3;
        sky_pdf_0 = sky_pdf_1;
        spread_2 = spread_3;
        uint _S1652 = b_11 + 1U;
        b_8 = _S1652;
        layer_0 = _S1651;
    }
    return _S1213;
}

static __device__ Shift shift_0(Domain * dom_8, Reservoir * r_13)
{
    Selection _S1766 = (Selection{});
    Selection sel_8 = _S1766;
    bool _S1767 = (r_13->w) <= 0.0f;
    if(_S1767)
    {
        return Shift_x24init_0(make_float3 (0.0f), 0.0f);
    }
    Shift _S1768 = walk_0(dom_8, r_13, true, 0.0f, &sel_8);
    return _S1768;
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
        *_slang_vector_get_element_ptr(&result_14, i_18) = (F32_tan((_slang_vector_get_element(x_26, i_18))));
        i_18 = i_18 + int(1);
    }
    return result_14;
}

static __device__ float3  acos_0(float3  x_27)
{
    float3  result_15;
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
        *_slang_vector_get_element_ptr(&result_15, i_19) = (F32_acos((_slang_vector_get_element(x_27, i_19))));
        i_19 = i_19 + int(1);
    }
    return result_15;
}

static __device__ float3  abs_0(float3  x_28)
{
    float3  result_16;
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
        *_slang_vector_get_element_ptr(&result_16, i_20) = (F32_abs((_slang_vector_get_element(x_28, i_20))));
        i_20 = i_20 + int(1);
    }
    return result_16;
}

__device__ Random normal_distribution(uint state_3)
{
    Random _S1769 = pcg(state_3);
    Random _S1770 = pcg(_S1769.state);
    float _S1771 = 6.28318548202514648f * _S1769.value;
    float _S1772 = (F32_sqrt((-2.0f * clamp_1((F32_log((_S1770.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S1770.state, _S1772 * (F32_cos((_S1771))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_4, float3  value_2)
{
    RandomSphere _S1773;
    (&_S1773)->state = state_4;
    (&_S1773)->value = value_2;
    return _S1773;
}

__device__ RandomSphere random_sphere(uint state_5)
{
    Random _S1774 = normal_distribution(state_5);
    Random _S1775 = normal_distribution(_S1774.state);
    Random _S1776 = normal_distribution(_S1775.state);
    float3  _S1777 = make_float3 (_S1774.value, _S1775.value, _S1776.value);
    float3  _S1778 = ((((_S1777)) * make_float3(rnorm3df(((_S1777)).x, ((_S1777)).y, ((_S1777)).z))));
    return RandomSphere_x24init_0(_S1776.state, _S1778);
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_19)
{
    float3  _S1779 = p1_0 - p0_0;
    float3  _S1780 = p2_0 - p0_0;
    float2  _S1781 = uv1_0 - uv0_0;
    float2  _S1782 = uv2_0 - uv0_0;
    float _S1783 = _S1781.x;
    float _S1784 = _S1782.y;
    float _S1785 = _S1781.y;
    float _S1786 = _S1782.x;
    float _S1787 = _S1783 * _S1784 - _S1785 * _S1786;
    float _S1788 = 1.0f / _S1787;
    float3  t_23 = (_S1779 * make_float3 (_S1784) - _S1780 * make_float3 (_S1785)) * make_float3 (_S1788);
    float3  _S1789 = (_S1780 * make_float3 (_S1783) - _S1779 * make_float3 (_S1786)) * make_float3 (_S1788);
    float3  _S1790 = t_23 - n_19 * make_float3 (dot_0(n_19, t_23));
    float3  t_24 = ((((_S1790)) * make_float3(rnorm3df(((_S1790)).x, ((_S1790)).y, ((_S1790)).z))));
    bool _S1791 = (dot_0(cross_0(n_19, t_24), _S1789)) > 0.0f;
    float3  t_25;
    if(_S1791)
    {
        float3  _S1792 = negate_0(t_24);
        t_25 = _S1792;
    }
    else
    {
        t_25 = t_24;
    }
    float3  _S1793 = cross_0(n_19, t_25);
    return makeMatrix<float, 3, 3> (t_25, _S1793, n_19);
}

__device__ float3  tangentToWorldNormalMap(float3  v_10, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_10, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_5, float3  uvw_0, float3  position_0)
{
    float3  _S1794 = t1_0 - t0_0;
    float3  _S1795 = t2_2 - t0_0;
    float3  _S1796 = t2_2 - t1_0;
    float _S1797 = (F32_min((length_0(_S1794)), ((F32_min((length_0(_S1795)), (length_0(_S1796)))))));
    float3  _S1798 = make_float3 (distance_1(position_0, t0_0), distance_1(position_0, t1_0), distance_1(position_0, t2_2));
    float3  _S1799 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S1800 = dot_0(geometry_n_5, _S1799);
    float3  _S1801 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S1802 = dot_0(geometry_n_5, _S1801);
    float3  _S1803 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S1804 = acos_0(abs_0(make_float3 (_S1800, _S1802, dot_0(geometry_n_5, _S1803))));
    float3  _S1805 = clamp_2(tan_0(_S1804), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_1(dot_0(_S1798 * _S1805, uvw_0), 0.0f, _S1797 * 0.125f);
}

__device__ float3  straightThrough(float3  dir_15, float3  n_20, BSDFMaterial material_17)
{
    float3  _S1806 = negate_0(dir_15);
    float _S1807 = sign_0(dot_0(n_20, _S1806));
    float3  _S1808 = n_20 * make_float3 (_S1807);
    AnisotropicFrame _S1809 = anisotropicFrame(material_17, _S1808);
    bool _S1810 = (_S1809.alphas.x) > 0.0f;
    if(_S1810)
    {
        float _S1811 = material_17.transmission * (1.0f - material_17.metallic);
        float3  _S1812 = negate_0(_S1808);
        float3  _S1813 = anisotropicLocal(dir_15, _S1809.tangent, _S1812);
        float _S1814 = anisotropicG1(_S1813, _S1809.alphas);
        return make_float3 (_S1811 * _S1814) * material_17.albedo;
    }
    float _S1815 = material_17.transmission * (1.0f - material_17.metallic);
    float _S1816 = material_17.roughness;
    float _S1817 = smithG1(_S1816 * _S1816, (F32_abs((dot_0(n_20, dir_15)))));
    return make_float3 (_S1815 * _S1817) * material_17.albedo;
}

__device__ float hairRow(float3  in_dir_10, float3  t_26, float3  out_dir_4, uint p_13, float w_2, float alpha_6, uint nt_0)
{
    uint _S1818 = p_13 % 4U;
    float _S1819 = w_2 * HAIR_WIDTHS_0[_S1818];
    float _S1820 = (F32_asin((clamp_1(dot_0(out_dir_4, t_26), -1.0f, 1.0f)))) - (F32_asin((clamp_1(dot_0(in_dir_10, t_26), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S1818] * alpha_6;
    return ((F32_asinh((_S1820 / _S1819))) / (F32_asinh((3.14159274101257324f / _S1819))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_11, float3  t_27, float3  out_dir_5, uint np_0)
{
    float3  _S1821 = worldToTangent(out_dir_5, t_27);
    float3  _S1822 = worldToTangent(in_dir_11, t_27);
    return (F32_frac((((F32_atan2((_S1821.z), (_S1821.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S1822.z), (1.17549435082228751e-38f - _S1822.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_12, float3  t_28, uint p_14, float row_0, float column_0, float w_3, float alpha_7, uint nt_1, uint np_1)
{
    float3  _S1823 = worldToTangent(in_dir_12, t_28);
    uint _S1824 = p_14 % 4U;
    float _S1825 = w_3 * HAIR_WIDTHS_0[_S1824];
    float _S1826 = (F32_asin((clamp_1(dot_0(in_dir_12, t_28), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S1824] * alpha_7 + _S1825 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S1825))))));
    float _S1827 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S1823.z), (1.17549435082228751e-38f - _S1823.x)));
    float _S1828 = (F32_cos((_S1826)));
    float3  _S1829 = tangentToWorld(make_float3 (_S1828 * (F32_cos((_S1827))), (F32_sin((_S1826))), _S1828 * (F32_sin((_S1827)))), t_28);
    return _S1829;
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_21, BSDFMaterial material_18, float coverage_1)
{
    float3  _S1830;
    if((material_18.ior) == 1.0f)
    {
        float3  _S1831 = straightThrough(toward_1, n_21, material_18);
        _S1830 = _S1831;
    }
    else
    {
        _S1830 = make_float3 (0.0f);
    }
    return _S1830 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ Shift walk_hook(Domain dom_9, Reservoir r_14, bool replay_3, float scale_4, Selection * sel_9)
{
    Domain _S1832 = dom_9;
    Reservoir _S1833 = r_14;
    Shift _S1834 = walk_0(&_S1832, &_S1833, replay_3, scale_4, sel_9);
    return _S1834;
}

__device__ Shift shift_hook(Domain dom_10, Reservoir r_15)
{
    Domain _S1835 = dom_10;
    Reservoir _S1836 = r_15;
    Shift _S1837 = shift_0(&_S1835, &_S1836);
    return _S1837;
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
