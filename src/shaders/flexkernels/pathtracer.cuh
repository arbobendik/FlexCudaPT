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

__device__ float rgb_to_greyscale(float3  rgb_0)
{
    return dot_0(rgb_0, make_float3 (0.29899999499320984f, 0.58700001239776611f, 0.11400000005960464f));
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

__device__ __forceinline__ float3  BSDF(float3  in_dir_4, float3  out_dir_2, float3  n_7, BSDFMaterial material_9, float eta_i_8, float eta_o_8, bool refracted_2, uint random_state_4, FixedArray<float3 , 5>  * throughputs_0, FixedArray<float, 5>  * pdfs_0)
{
    float3  ggx_n_1;
    float3  _S571 = negate_0(in_dir_4);
    float _S572 = dot_0(n_7, _S571);
    float _S573 = sign_0(_S572);
    float3  _S574 = n_7 * make_float3 (_S573);
    AnisotropicFrame _S575 = anisotropicFrame(material_9, _S574);
    float _S576 = dot_0(_S574, out_dir_2);
    float _S577 = material_9.roughness;
    float _S578 = _S577 * _S577;
    float _S579 = rgb_to_greyscale(material_9.translucent);
    bool _S580 = _S579 > 0.0f;
    bool _S581 = (dot_0(n_7, out_dir_2) * _S572) < 0.0f;
    uint _S582;
    if((F32_abs((material_9.toon.x))) > 0.0f)
    {
        _S582 = 5U;
    }
    else
    {
        _S582 = 4U;
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
        float3  _S583 = make_float3 (0.0f);
        (*throughputs_0)[i_6] = _S583;
        (*pdfs_0)[i_6] = 0.0f;
        uint i_7 = i_6 + 1U;
        i_6 = i_7;
    }
    float3  _S584 = make_float3 (0.0f);
    BSDFLobes _S585 = BSDFLobes_x24init_0(0.0f, 0.0f, _S584, _S584, 0.0f, 0.0f, _S584, _S584, 0.0f, 0.0f, 0.0f, 0.0f, _S584, 0.0f, _S584, _S584, make_float2 (0.0f), 0.0f, 0.0f, _S584, 0.0f, 0.0f, 0.0f, false, 1.0f, 0.0f, _S584);
    BSDFLobes lobe_terms_0 = _S585;
    uint half_of_0 = 4294967295U;
    float3  ggx_n_2 = _S584;
    i_6 = 0U;
    for(;;)
    {
        if(i_6 < _S582)
        {
        }
        else
        {
            break;
        }
        uint _S586;
        if(i_6 == 3U)
        {
            _S586 = 4U;
        }
        else
        {
            if(i_6 == 4U)
            {
                _S586 = 6U;
            }
            else
            {
                _S586 = i_6;
            }
        }
        bool _S587 = _S586 == 0U;
        bool _S588;
        if(_S587)
        {
            _S588 = _S580;
        }
        else
        {
            _S588 = false;
        }
        bool _S589;
        if(_S588)
        {
            _S589 = _S581;
        }
        else
        {
            _S589 = _S586 == 1U;
        }
        bool _S590 = _S589 != refracted_2;
        if(_S590)
        {
            ggx_n_1 = ggx_n_2;
            uint i_8 = i_6 + 1U;
            ggx_n_2 = ggx_n_1;
            i_6 = i_8;
            continue;
        }
        uint _S591;
        if(_S586 == 6U)
        {
            _S591 = 0U;
        }
        else
        {
            if(_S586 == 4U)
            {
                _S591 = 2U;
            }
            else
            {
                _S591 = _S586;
            }
        }
        bool _S592 = _S591 != half_of_0;
        uint half_of_1;
        if(_S592)
        {
            bool _S593 = _S591 == 0U;
            if(_S593)
            {
                float3  _S594 = sampledHalf(in_dir_4, n_7, material_9, random_state_4, _S575);
                ggx_n_1 = _S594;
            }
            else
            {
                bool _S595 = _S591 == 1U;
                if(_S595)
                {
                    float3  _S596 = refractedHalf(in_dir_4, out_dir_2, n_7, eta_i_8, eta_o_8);
                    ggx_n_1 = _S596;
                }
                else
                {
                    float3  _S597 = reflectedHalf(in_dir_4, out_dir_2);
                    ggx_n_1 = _S597;
                }
            }
            float3  _S598 = negate_0(in_dir_4);
            BSDFLobes _S599 = bsdfLobes(in_dir_4, _S598, _S574, ggx_n_1, material_9, eta_i_8, eta_o_8, _S575);
            lobe_terms_0 = _S599;
            float _S600 = translucentShare(material_9);
            (&lobe_terms_0)->translucent_share = _S600;
            half_of_1 = _S591;
        }
        else
        {
            ggx_n_1 = ggx_n_2;
            half_of_1 = half_of_0;
        }
        switch(_S586)
        {
        case 0U:
            {
                float _S601 = diffusePDF(_S576, 0.0f, (F32_abs((_S572))), _S578, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(0)] = _S601;
                float3  _S602 = diffuseBSDF(out_dir_2, _S574, _S578, material_9, lobe_terms_0);
                (*throughputs_0)[int(0)] = _S602;
                break;
            }
        case 1U:
            {
                float _S603 = refractPDF(_S576, dot_0(out_dir_2, ggx_n_1), (F32_abs((_S572))), _S578, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(1)] = _S603;
                float3  _S604 = refractBSDF(out_dir_2, _S574, _S578, material_9, lobe_terms_0);
                (*throughputs_0)[int(1)] = _S604;
                break;
            }
        case 4U:
            {
                float _S605 = sheenVelvetPDF(_S576, 0.0f, (F32_abs((_S572))), _S578, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(3)] = _S605;
                float3  _S606 = sheenVelvetBSDF(out_dir_2, _S574, _S578, material_9, lobe_terms_0);
                (*throughputs_0)[int(3)] = _S606;
                break;
            }
        case 6U:
            {
                float _S607 = toonPDF(_S576, dot_0(out_dir_2, (&lobe_terms_0)->toon_axis), (F32_abs((_S572))), _S578, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(4)] = _S607;
                float3  _S608 = toonBSDF(out_dir_2, _S574, _S578, material_9, lobe_terms_0);
                (*throughputs_0)[int(4)] = _S608;
                break;
            }
        default:
            {
                float _S609 = reflectPDF(_S576, 0.0f, (F32_abs((_S572))), _S578, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(2)] = _S609;
                float3  _S610 = reflectBSDF(out_dir_2, _S574, _S578, material_9, lobe_terms_0);
                (*throughputs_0)[int(2)] = _S610;
                break;
            }
        }
        half_of_0 = half_of_1;
        uint i_8 = i_6 + 1U;
        ggx_n_2 = ggx_n_1;
        i_6 = i_8;
    }
    i_6 = 0U;
    ggx_n_1 = _S584;
    for(;;)
    {
        if(i_6 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S611 = ((*pdfs_0)[i_6]) > 0.0f;
        if(_S611)
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
    bool _S612 = wrongSide_0(is_inside_2, false, dir_3, surface_1->geometry_n);
    float3  _S613 = BSDF(in_dir_5, dir_3, surface_1->smooth_n, surface_1->material, eta_1.x, eta_1.y, _S612, random_state_5, terms_0, pdfs_1);
    float3  _S614 = make_float3 (0.0f);
    uint i_10 = 0U;
    float3  f_3 = _S614;
    for(;;)
    {
        if(i_10 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S615 = ((*pdfs_1)[i_10]) > 0.0f;
        if(_S615)
        {
            float3  _S616 = (*terms_0)[i_10] * make_float3 ((*pdfs_1)[i_10]) / make_float3 ((*pdfs_1)[i_10] + pdf_0);
            (*terms_0)[i_10] = _S616;
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
    FKSurface _S617 = surface_2;
    FixedArray<float3 , 5>  terms_1;
    FixedArray<float, 5>  pdfs_2;
    float3  _S618 = skyLobes_0(in_dir_6, dir_4, &_S617, eta_2, is_inside_3, pdf_1, random_state_6, &terms_1, &pdfs_2);
    return _S618;
}

static __device__ SkySample SkySample_x24init_0(float3  dir_5, float3  radiance_0, float3  color_0, uint random_state_7)
{
    SkySample _S619;
    (&_S619)->dir = dir_5;
    (&_S619)->radiance = radiance_0;
    (&_S619)->color = color_0;
    (&_S619)->random_state = random_state_7;
    return _S619;
}

static __device__ SkySample sampleSky_0(FKRay * ray_0, FKSurface * surface_3, float2  eta_3, bool is_inside_4, uint init_random_state_0, uint lobe_state_0, ShadowContext * context_2)
{
    uint2  _S620 = (fcptEnvironmentCdfSize());
    uint2  _S621 = make_uint2 (1U, 0U);
    uint2  _S622 = _S620 - _S621;
    Random _S623 = pcg(init_random_state_0);
    Random _S624 = pcg(_S623.state);
    Random _S625 = pcg(_S624.state);
    Random _S626 = pcg(_S625.state);
    uint _S627 = _S622.x;
    uint _S628 = searchCDF_0(make_uint2 (_S627, 0U), make_uint2 (0U, 1U), _S622.y, _S623.value);
    uint _S629 = searchCDF_0(make_uint2 (0U, _S628), _S621, _S627, _S624.value);
    float2  _S630 = make_float2 ((float)_S622.x, (float)_S622.y);
    float2  _S631 = (make_float2 (float(_S629), float(_S628)) + make_float2 (_S625.value, _S626.value)) / _S630 * make_float2 (6.28318548202514648f, 3.14159274101257324f);
    float _S632 = _S631.y;
    float _S633 = (F32_sin((_S632)));
    float _S634 = _S631.x;
    float3  _S635 = make_float3 (- _S633 * (F32_cos((_S634))), _S633 * (F32_sin((_S634))), (F32_cos((_S632))));
    float _S636 = environmentPdf_0(_S635);
    float3  _S637 = skyBSDF(ray_0->unit_direction, _S635, *surface_3, eta_3, is_inside_4, _S636, lobe_state_0);
    bool _S638 = !(_S636 > 0.0f);
    bool _S639;
    if(_S638)
    {
        _S639 = true;
    }
    else
    {
        _S639 = all_1(_S637 == make_float3 (0.0f));
    }
    if(_S639)
    {
        float3  _S640 = make_float3 (0.0f);
        return SkySample_x24init_0(_S635, _S640, _S640, _S626.state);
    }
    float3  _S641 = skyRadiance_0(ray_0->origin, surface_3, is_inside_4, _S635, context_2, _S626.state);
    return SkySample_x24init_0(_S635, _S641, _S637 * _S641, _S626.state);
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
    SampleBSDF _S642 = (fcptConnectHair((surface_4->hair), ((&surface_4->material)->albedo), ((&surface_4->material)->specular_tint), (in_dir_7), (light_1->dir)));
    float3  _S643 = _S642.throughput * make_float3 (_S642.pdf);
    float _S644 = light_1->density;
    float _S645 = 1.0f + _S642.pdf * _S642.pdf / (light_1->density * light_1->density);
    bool _S646;
    if(competing_0)
    {
        _S646 = _S644 > 0.0f;
    }
    else
    {
        _S646 = false;
    }
    float _S647 = _slang_select(_S646, _S645,1.0f);
    return _S643 / make_float3 (_S647) * light_1->radiance;
}

static __device__ TreeSample TreeSample_x24init_0(float3  dir_6, float3  radiance_1, float density_0, uint random_state_8)
{
    TreeSample _S648;
    (&_S648)->dir = dir_6;
    (&_S648)->radiance = radiance_1;
    (&_S648)->density = density_0;
    (&_S648)->random_state = random_state_8;
    return _S648;
}

__device__ uint pickChild(LightNode first_1, LightNode second_1, float3  p_11, float3  normal_3, float * pick_0, float * probability_3)
{
    float _S649 = importance(first_1, p_11, normal_3);
    float _S650 = importance(second_1, p_11, normal_3);
    float2  _S651 = make_float2 (_S649, _S650);
    bool _S652 = _S649 == 0.0f;
    bool _S653;
    if(_S652)
    {
        _S653 = _S650 == 0.0f;
    }
    else
    {
        _S653 = false;
    }
    if(_S653)
    {
        return 2U;
    }
    float _S654 = _S649 + _S650;
    bool _S655 = _S650 > 0.0f;
    if(_S655)
    {
        _S653 = (*pick_0 * _S654) >= _S649;
    }
    else
    {
        _S653 = false;
    }
    uint _S656 = uint(_S653);
    float _S657 = (F32_min(((*pick_0 * _S654 - float(_S656) * _S649) / _slang_vector_get_element(_S651, _S656)), (0.99999994039535522f)));
    *pick_0 = _S657;
    float _S658 = *probability_3 * (_slang_vector_get_element(_S651, _S656) / _S654);
    *probability_3 = _S658;
    return _S656;
}

__device__ float3  sampleSphere(float3  center_1, float radius_1, float3  p_12, float u1_0, float u2_0)
{
    float3  _S659 = center_1 - p_12;
    float _S660 = radius_1 * radius_1 / dot_0(_S659, _S659);
    float _S661 = u1_0 * _S660 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S660), (0.0f)))))));
    float _S662 = 2.0f * u1_0;
    bool _S663 = _S660 >= 1.0f;
    float _S664 = _slang_select(_S663, _S662,_S661);
    float _S665 = (F32_sqrt(((F32_max((_S664 * (2.0f - _S664)), (0.0f))))));
    float _S666 = 6.28318548202514648f * u2_0;
    float3  _S667 = make_float3 (_S665 * (F32_cos((_S666))), 1.0f - _S664, _S665 * (F32_sin((_S666))));
    float3  _S668 = ((((_S659)) * make_float3(rnorm3df(((_S659)).x, ((_S659)).y, ((_S659)).z))));
    float3  _S669 = tangentToWorld(_S667, _S668);
    return _S669;
}

__device__ float3  pointLightRadiance(float3  color_1, float intensity_0, float radius_2)
{
    return color_1 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_2 * radius_2);
}

static __device__ float raySphere_0(float3  center_2, float radius_3, FKRay * ray_1, float max_len_0)
{
    float3  _S670 = center_2 - ray_1->origin;
    float _S671 = dot_0(_S670, ray_1->unit_direction);
    float _S672 = dot_0(_S670, _S670) - _S671 * _S671;
    float _S673 = radius_3 * radius_3;
    bool _S674 = _S672 > _S673;
    if(_S674)
    {
        return 4.294967296e+09f;
    }
    float _S675 = (F32_sqrt((_S673 - _S672)));
    float _S676 = _S671 - _S675;
    float _S677 = _S671 + _S675;
    bool _S678 = _S676 > 0.0000152587890625f;
    bool _S679;
    if(_S678)
    {
        _S679 = _S676 < max_len_0;
    }
    else
    {
        _S679 = false;
    }
    if(_S679)
    {
        return _S676;
    }
    bool _S680 = _S677 > 0.0000152587890625f;
    if(_S680)
    {
        _S679 = _S677 < max_len_0;
    }
    else
    {
        _S679 = false;
    }
    if(_S679)
    {
        return _S677;
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
    Random _S681 = pcg(init_random_state_1);
    Random _S682 = pcg(_S681.state);
    Random _S683 = pcg(_S682.state);
    float3  _S684 = make_float3 (0.0f);
    TreeSample _S685 = TreeSample_x24init_0(_S684, _S684, 0.0f, _S683.state);
    TreeSample sample_0 = _S685;
    float3  _S686 = _slang_select(sided_0, _S684,smooth_n_2);
    float3  _S687 = origin_4 + make_float3 (geometry_offset_1) * smooth_n_2;
    float pick_1 = _S681.value;
    float probability_4 = 1.0f;
    uint n_8 = 0U;
    for(;;)
    {
        uint4  _S688 = (fcptLightNode((n_8)));
        if((_S688.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S689 = (fcptLightSecond((n_8)));
        uint _S690 = n_8 + 1U;
        LightNode _S691 = (fcptLightBounds((_S690)));
        LightNode _S692 = (fcptLightBounds((_S689)));
        uint _S693 = pickChild(_S691, _S692, origin_4, _S686, &pick_1, &probability_4);
        bool _S694 = _S693 > 1U;
        if(_S694)
        {
            return sample_0;
        }
        bool _S695 = _S693 == 1U;
        uint _S696 = _slang_select(_S695, _S689,_S690);
        n_8 = _S696;
    }
    bool _S697 = n_8 == 0U;
    bool _S698;
    if(_S697)
    {
        LightNode _S699 = (fcptLightBounds((0U)));
        float _S700 = importance(_S699, origin_4, _S686);
        _S698 = !(_S700 > 0.0f);
    }
    else
    {
        _S698 = false;
    }
    if(_S698)
    {
        return sample_0;
    }
    uint4  _S701 = (fcptLightNode((n_8)));
    FKHit _S702 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    bool _S703 = (_S701.x) == 2U;
    float3  emitter_point_0;
    float3  lift_n_0;
    float3  shadow_1;
    FKHit emitter_0;
    if(_S703)
    {
        FKLight _S704 = (fcptLight((_S701.y)));
        if(sided_0)
        {
            float _S705 = sign_0(dot_0(geometry_n_1, _S704.position - origin_4));
            float3  lift_n_1 = smooth_n_2 * make_float3 (_S705);
            float3  _S706 = origin_4 + make_float3 (geometry_offset_1) * lift_n_1;
            emitter_point_0 = _S706;
            lift_n_0 = lift_n_1;
        }
        else
        {
            emitter_point_0 = _S687;
            lift_n_0 = smooth_n_2;
        }
        bool _S707 = (_S704.variance) == 0.0f;
        if(_S707)
        {
            float3  _S708 = _S704.position - emitter_point_0;
            float3  _S709 = ((((_S708)) * make_float3(rnorm3df(((_S708)).x, ((_S708)).y, ((_S708)).z))));
            (&sample_0)->dir = _S709;
            float3  _S710 = _S704.color * make_float3 (_S704.intensity) / make_float3 (dot_0(_S708, _S708) * probability_4);
            (&sample_0)->radiance = _S710;
            shadow_1 = _S708;
        }
        else
        {
            float3  _S711 = sampleSphere(_S704.position, _S704.variance, emitter_point_0, _S682.value, _S683.value);
            (&sample_0)->dir = _S711;
            float _S712 = sphereDensity(_S704.position, _S704.variance, emitter_point_0);
            float _S713 = probability_4 * _S712;
            (&sample_0)->density = _S713;
            float3  _S714 = pointLightRadiance(_S704.color, _S704.intensity, _S704.variance);
            float3  _S715 = _S714 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S715;
            FKRay _S716 = Ray_x24init_0(emitter_point_0, (&sample_0)->dir);
            float _S717 = raySphere_0(_S704.position, _S704.variance, &_S716, 4.294967296e+09f);
            float3  _S718 = (&sample_0)->dir * make_float3 (_S717);
            shadow_1 = _S718;
        }
        emitter_0 = _S702;
        emitter_point_0 = _S684;
    }
    else
    {
        uint _S719 = _S701.y;
        uint _S720 = (fcptTriangleOffset((_S719)));
        uint _S721 = _S720 + _S701.z;
        Matrix<float, 3, 3>  _S722 = (fcptWorldTriangle((_S719), (_S721)));
        float _S723 = (F32_sqrt((_S682.value)));
        float2  _S724 = make_float2 (_S723 * (1.0f - _S683.value), _S723 * _S683.value);
        float3  _S725 = mul_0(make_float3 (1.0f - _S723, _S724.x, _S724.y), _S722);
        if(sided_0)
        {
            float _S726 = sign_0(dot_0(geometry_n_1, _S725 - origin_4));
            float3  lift_n_2 = smooth_n_2 * make_float3 (_S726);
            float3  _S727 = origin_4 + make_float3 (geometry_offset_1) * lift_n_2;
            emitter_point_0 = _S727;
            lift_n_0 = lift_n_2;
        }
        else
        {
            bool _S728 = !((dot_0(smooth_n_2, _S725 - origin_4)) > 0.0f);
            if(_S728)
            {
                return sample_0;
            }
            emitter_point_0 = _S687;
            lift_n_0 = smooth_n_2;
        }
        FKHit emitter_1 = Hit_x24init_0(_S724, _S719, _S721, 0U, 0.0f);
        float3  _S729 = _S725 - emitter_point_0;
        float3  _S730 = ((((_S729)) * make_float3(rnorm3df(((_S729)).x, ((_S729)).y, ((_S729)).z))));
        (&sample_0)->dir = _S730;
        float _S731 = solidAngle(probability_4, cross_0(_S722.rows[int(1)] - _S722.rows[int(0)], _S722.rows[int(2)] - _S722.rows[int(0)]), _S729);
        (&sample_0)->density = _S731;
        bool _S732 = (fcptShadowFirst());
        bool _S733 = !_S732;
        if(_S733)
        {
            FKSurface _S734 = (fcptLightSurfaceAt((emitter_1), (_S725), (_S683.state), ((&sample_0)->dir), (context_3->depth), (length_0(_S725 - origin_4))));
            (&sample_0)->random_state = _S734.random_state;
            float3  _S735 = _slang_select(_S734.skip, _S684,_S734.material.emissive);
            float3  _S736 = _S735 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S736;
        }
        shadow_1 = _S729;
        emitter_0 = emitter_1;
        emitter_point_0 = _S725;
    }
    FKHit _S737 = emitter_0;
    float3  _S738 = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, context_3, _S683.state, &_S737);
    bool _S739 = (fcptShadowFirst());
    if(_S739)
    {
        _S698 = (emitter_0.instance_index) != 4294967295U;
    }
    else
    {
        _S698 = false;
    }
    if(_S698)
    {
        _S698 = !all_1(_S738 == _S684);
    }
    else
    {
        _S698 = false;
    }
    if(_S698)
    {
        FKSurface _S740 = (fcptLightSurfaceAt((emitter_0), (emitter_point_0), (_S683.state), ((&sample_0)->dir), (context_3->depth), (length_0(emitter_point_0 - origin_4))));
        (&sample_0)->random_state = _S740.random_state;
        float3  _S741 = _slang_select(_S740.skip, _S684,_S740.material.emissive);
        float3  _S742 = _S741 / make_float3 ((&sample_0)->density);
        (&sample_0)->radiance = _S742;
    }
    float3  _S743 = (&sample_0)->radiance * _S738;
    bool _S744 = all_1(_S738 == _S684);
    float3  _S745 = _slang_select(_S744, _S684,_S743);
    (&sample_0)->radiance = _S745;
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
    float _S746 = 1.0f / (1.0f + b_3 / a_7 * (b_3 / a_7));
    bool _S747 = b_3 > 0.0f;
    float _S748 = _slang_select(_S747, _S746,1.0f);
    return _S748;
}

static __device__ float emissionWeight_0(NEEVertex * vertex_0, FKHit * hit_1, float3  light_point_1)
{
    bool _S749 = vertex_0->none;
    if(_S749)
    {
        return 1.0f;
    }
    uint _S750 = (fcptLightSlot((*hit_1)));
    float _S751 = lightPdf_0(vertex_0->origin, vertex_0->smooth_n, vertex_0->start, _S750, light_point_1);
    float _S752 = powerHeuristic(vertex_0->pdf, _S751);
    return _S752;
}

static __device__ float3  environment_0(float3  dir_7, uint depth_0, uint lobe_0)
{
    uint2  _S753 = (fcptEnvironmentMapSize());
    bool _S754 = (_S753.x) > 1U;
    bool _S755;
    if(_S754)
    {
        uint2  _S756 = (fcptEnvironmentMapSize());
        _S755 = (_S756.y) > 1U;
    }
    else
    {
        _S755 = false;
    }
    if(_S755)
    {
        float3  _S757 = (fcptEnvMapSample((dir_7), (depth_0), (lobe_0)));
        return _S757;
    }
    float3  _S758 = (fcptAmbient());
    return _S758;
}

static __device__ bool environmentMapped_0()
{
    uint2  _S759 = (fcptEnvironmentCdfSize());
    bool _S760 = (_S759.x) > 1U;
    bool _S761;
    if(_S760)
    {
        uint2  _S762 = (fcptEnvironmentCdfSize());
        _S761 = (_S762.y) > 1U;
    }
    else
    {
        _S761 = false;
    }
    bool _S763 = !_S761;
    if(_S763)
    {
        return false;
    }
    uint2  _S764 = (fcptEnvironmentMapSize());
    bool _S765 = (_S764.x) > 1U;
    if(_S765)
    {
        uint2  _S766 = (fcptEnvironmentMapSize());
        _S761 = (_S766.y) > 1U;
    }
    else
    {
        _S761 = false;
    }
    return _S761;
}

static __device__ float escapeWeight_0(float pdf_2, float3  dir_8)
{
    bool _S767 = pdf_2 <= 0.0f;
    bool _S768;
    if(_S767)
    {
        _S768 = true;
    }
    else
    {
        bool _S769 = environmentMapped_0();
        _S768 = !_S769;
    }
    if(_S768)
    {
        return 1.0f;
    }
    float _S770 = environmentPdf_0(dir_8);
    return pdf_2 / (pdf_2 + _S770);
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
    uint2  _S771 = uint2 {global_invocation_id_1.x, global_invocation_id_1.y};
    int2  _S772 = make_int2 ((int)_S771.x, (int)_S771.y);
    uint _S773 = previousSeed_0(_S772);
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
            uint _S774 = previousSeed_0(_S772 + make_int2 (x_16, y_5));
            bool _S775 = _S774 == _S773;
            uint _S776 = _slang_select(_S775, 1U,0U);
            uint count_3 = count_2 + _S776;
            int x_17 = x_16 + int(1);
            x_16 = x_17;
            count_2 = count_3;
        }
        int y_6 = y_5 + int(1);
        y_5 = y_6;
    }
    float _S777 = float(count_2 - 1U) / 288.0f;
    bool _S778 = _S773 != 0U;
    float _S779 = _slang_select(_S778, _S777,0.0f);
    fcptStoreDuplication((_S772), (make_uint4 ((F32_asuint((_S779))), 0U, 0U, 0U)));
    return;
}

__device__ uint stream(uint seed_3, uint index_0)
{
    uint _S780 = hash(index_0);
    uint _S781 = hash(seed_3 ^ _S780);
    return _S781;
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
    float _S782 = rgb_to_greyscale(weight_0);
    bool _S783 = _S782 > 0.0f;
    bool _S784;
    if(_S783)
    {
        _S784 = _S782 < 3.00000000549775576e+38f;
    }
    else
    {
        _S784 = false;
    }
    bool _S785 = !_S784;
    if(_S785)
    {
        return;
    }
    bool _S786 = sel_2->sums;
    if(_S786)
    {
        float3  _S787 = sel_2->color + weight_0;
        sel_2->color = _S787;
        return;
    }
    float _S788 = sel_2->w_sum + _S782;
    sel_2->w_sum = _S788;
    float3  _S789 = sel_2->color + weight_0;
    sel_2->color = _S789;
    Random _S790 = pcg(sel_2->random_state);
    sel_2->random_state = _S790.state;
    bool _S791 = (_S790.value * sel_2->w_sum) <= _S782;
    if(_S791)
    {
        sel_2->r = candidate_0;
    }
    return;
}

__device__ void offerShifted(Selection * sel_3, Reservoir r_3, Shift shifted_0, float mis_0)
{
    Reservoir candidate_1 = r_3;
    float3  _S792 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_1)->f = _S792;
    float _S793 = r_3.jac * shifted_0.jac;
    (&candidate_1)->jac = _S793;
    offer(sel_3, candidate_1, make_float3 (mis_0) * shifted_0.f * make_float3 (r_3.w));
    return;
}

__device__ Reservoir finalize(Selection sel_4, float c_1)
{
    Reservoir r_4 = sel_4.r;
    float _S794 = rgb_to_greyscale((&r_4)->f);
    float _S795 = sel_4.w_sum / _S794;
    bool _S796 = _S794 > 0.0f;
    float _S797 = _slang_select(_S796, _S795,0.0f);
    (&r_4)->w = _S797;
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
    uint2  _S798 = uint2 {global_invocation_id_2.x, global_invocation_id_2.y};
    int2  _S799 = make_int2 ((int)_S798.x, (int)_S798.y);
    float3  _S800 = make_float3 (0.0f);
    FKHit _S801 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S802 = Domain_x24init_0(_S800, _S800, &_S801, 0.0f, 0.0f);
    Domain dom_4 = _S802;
    bool _S803 = (fcptCurrentDomain((_S799), (&dom_4)));
    bool _S804 = !_S803;
    if(_S804)
    {
        Reservoir _S805 = (Reservoir{});
        fcptStoreReservoirPrevious((_S799), (_S805), ((&dom_4)->hit));
        return;
    }
    Reservoir _S806 = (fcptLoadReservoirTemporal((_S799)));
    uint t_12 = 0U;
    float count_4 = 0.0f;
    float c_sum_1 = _S806.c;
    for(;;)
    {
        uint _S807 = (fcptRestirNeighbours());
        if(t_12 < _S807)
        {
        }
        else
        {
            break;
        }
        int2  _S808 = partner_0(_S799, t_12);
        Domain neighbor_0 = _S802;
        bool _S809 = (fcptCurrentDomain((_S808), (&neighbor_0)));
        if(_S809)
        {
            float count_5 = count_4 + 1.0f;
            uint4  _S810 = (fcptReservoirTemporal((_S808), (0U)));
            float c_sum_2 = c_sum_1 + (U32_asfloat((_S810.w)));
            count_4 = count_5;
            c_sum_1 = c_sum_2;
        }
        uint t_13 = t_12 + 1U;
        t_12 = t_13;
    }
    float _S811 = _S806.c / (F32_max((count_4), (1.0f)));
    float _S812 = rgb_to_greyscale(_S806.f);
    bool _S813 = count_4 == 0.0f;
    float _S814 = _slang_select(_S813, 1.0f,0.0f);
    Selection _S815 = (Selection{});
    Selection sel_5 = _S815;
    uint _S816 = (fcptFrame());
    uint _S817 = hash(_S816);
    uint _S818 = global_invocation_id_2.x;
    uint2  _S819 = (fcptRenderSize());
    uint _S820 = stream(_S817, _S818 + _S819.x * global_invocation_id_2.y);
    uint _S821 = stream(_S820, 195U);
    (&sel_5)->random_state = _S821;
    t_12 = 0U;
    float canonical_mis_0 = _S814;
    for(;;)
    {
        uint _S822 = (fcptRestirNeighbours());
        if(t_12 < _S822)
        {
        }
        else
        {
            break;
        }
        int2  _S823 = partner_0(_S799, t_12);
        Domain neighbor_dom_0 = _S802;
        bool _S824 = (fcptCurrentDomain((_S823), (&neighbor_dom_0)));
        if(_S824)
        {
            Reservoir _S825 = (fcptLoadReservoirTemporal((_S823)));
            uint4  _S826 = (fcptShiftData((_S823), (t_12)));
            float4  _S827 = asfloat_0(_S826);
            uint4  _S828 = (fcptShiftData((_S799), (t_12)));
            float4  _S829 = asfloat_0(_S828);
            float _S830 = pairShare(_S825.c, _S811, c_sum_1);
            bool _S831 = _S812 > 0.0f;
            float canonical_mis_1;
            if(_S831)
            {
                float _S832 = rgb_to_greyscale(float3 {_S829.x, _S829.y, _S829.z});
                float _S833 = canonicalWeight(_S830, _S811, _S812, _S825.c, _S832);
                float canonical_mis_2 = canonical_mis_0 + _S833;
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            float3  _S834 = float3 {_S827.x, _S827.y, _S827.z};
            Shift _S835 = Shift_x24init_0(_S834, _S827.w);
            float _S836 = rgb_to_greyscale(_S825.f);
            float _S837 = rgb_to_greyscale(_S834);
            float _S838 = neighborWeight(_S830, _S825.c, _S836, _S811, _S837);
            offerShifted(&sel_5, _S825, _S835, _S838);
            canonical_mis_0 = canonical_mis_1;
        }
        uint t_14 = t_12 + 1U;
        t_12 = t_14;
    }
    offerShifted(&sel_5, _S806, Shift_x24init_0(_S806.f, 1.0f), canonical_mis_0);
    Reservoir _S839 = finalize(sel_5, c_sum_1);
    fcptStoreReservoirPrevious((_S799), (_S839), ((&dom_4)->hit));
    fcptStorePreviousLayer((_S799), (5U), (make_uint4 (asuint_0((&(&dom_4)->hit)->uv).x, asuint_0((&(&dom_4)->hit)->uv).y, 0U, 0U)));
    fcptAddColor((_S799), (make_float4 ((&sel_5)->color.x, (&sel_5)->color.y, (&sel_5)->color.z, 0.0f)));
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
    uint _S840 = queuedShift_0(workgroup_id_1, local_invocation_index_4);
    bool _S841 = _S840 != 4294967295U;
    if(_S841)
    {
        uint2  _S842 = make_uint2 (_S840, _S840 >> 14U) & make_uint2 (16383U);
        int2  _S843 = make_int2 ((int)_S842.x, (int)_S842.y);
        ShiftJob _S844 = (ShiftJob{});
        ShiftJob shift_job_0 = _S844;
        Shift _S845 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
        uint _S846 = _S840 >> 28U;
        bool _S847 = spatialJob_0(_S843, _S846, &shift_job_0, true);
        Shift shifted_1;
        if(_S847)
        {
            Domain _S848 = (&shift_job_0)->dom;
            Reservoir _S849 = (&shift_job_0)->r;
            Shift _S850 = passShift_0(&_S848, &_S849);
            shifted_1 = _S850;
        }
        else
        {
            shifted_1 = _S845;
        }
        fcptStoreShiftData((_S843), (_S846), (make_uint4 (asuint_1(shifted_1.f).x, asuint_1(shifted_1.f).y, asuint_1(shifted_1.f).z, (F32_asuint((shifted_1.jac))))));
    }
    return;
}

static __device__ void restir_prepass_0(uint3  global_invocation_id_3, uint local_invocation_index_5)
{
    uint2  _S851 = uint2 {global_invocation_id_3.x, global_invocation_id_3.y};
    int2  _S852 = make_int2 ((int)_S851.x, (int)_S851.y);
    FixedArray<uint, 3>  _S853;
    spatialBins_0(_S852, &_S853);
    FixedArray<uint, 3>  _S854 = _S853;
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
        bool _S855 = (_S854[t_15]) == 40U;
        if(_S855)
        {
            fcptStoreShiftData((_S852), (t_15), (make_uint4 (0U)));
        }
        uint t_16 = t_15 + 1U;
        t_15 = t_16;
    }
    FixedArray<uint, 3>  _S856 = _S854;
    queueShifts_0(_S852, &_S856, global_invocation_id_3, local_invocation_index_5);
    return;
}

static __device__ void restir_count_0(uint3  global_invocation_id_4, uint local_invocation_index_6)
{
    uint2  _S857 = uint2 {global_invocation_id_4.x, global_invocation_id_4.y};
    int2  _S858 = make_int2 ((int)_S857.x, (int)_S857.y);
    FixedArray<uint, 3>  _S859;
    spatialBins_0(_S858, &_S859);
    FixedArray<uint, 3>  _S860 = _S859;
    countShifts_0(&_S860, local_invocation_index_6);
    return;
}

static __device__ void restir_temporal_shift_0(uint3  workgroup_id_2, uint local_invocation_index_7)
{
    uint _S861 = queuedShift_0(workgroup_id_2, local_invocation_index_7);
    bool _S862 = _S861 != 4294967295U;
    if(_S862)
    {
        uint2  _S863 = make_uint2 (_S861, _S861 >> 14U) & make_uint2 (16383U);
        int2  _S864 = make_int2 ((int)_S863.x, (int)_S863.y);
        ShiftJob _S865 = (ShiftJob{});
        ShiftJob shift_job_1 = _S865;
        Shift _S866 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
        uint _S867 = _S861 >> 28U;
        bool _S868 = temporalJob_0(_S864, _S867, &shift_job_1, true);
        Shift shifted_2;
        if(_S868)
        {
            if(_S867 == 1U)
            {
                Shift _S869 = (fcptShiftPrevious(((&shift_job_1)->dom), ((&shift_job_1)->r)));
                shifted_2 = _S869;
            }
            else
            {
                Domain _S870 = (&shift_job_1)->dom;
                Reservoir _S871 = (&shift_job_1)->r;
                Shift _S872 = passShift_0(&_S870, &_S871);
                shifted_2 = _S872;
            }
        }
        else
        {
            shifted_2 = _S866;
        }
        fcptStoreTemporalShift((_S864), (_S867), (make_uint4 (asuint_1(shifted_2.f).x, asuint_1(shifted_2.f).y, asuint_1(shifted_2.f).z, (F32_asuint((shifted_2.jac))))));
    }
    return;
}

static __device__ void restir_temporal_prepass_0(uint3  global_invocation_id_5, uint local_invocation_index_8)
{
    uint2  _S873 = uint2 {global_invocation_id_5.x, global_invocation_id_5.y};
    int2  _S874 = make_int2 ((int)_S873.x, (int)_S873.y);
    FixedArray<uint, 3>  _S875;
    temporalBins_0(_S874, &_S875);
    FixedArray<uint, 3>  _S876 = _S875;
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
        bool _S877 = (_S876[t_17]) == 40U;
        if(_S877)
        {
            fcptStoreTemporalShift((_S874), (t_17), (make_uint4 (0U)));
        }
        uint t_18 = t_17 + 1U;
        t_17 = t_18;
    }
    FixedArray<uint, 3>  _S878 = _S876;
    queueShifts_0(_S874, &_S878, global_invocation_id_5, local_invocation_index_8);
    return;
}

static __device__ void restir_temporal_count_0(uint3  global_invocation_id_6, uint local_invocation_index_9)
{
    uint2  _S879 = uint2 {global_invocation_id_6.x, global_invocation_id_6.y};
    int2  _S880 = make_int2 ((int)_S879.x, (int)_S879.y);
    bool _S881 = (fcptSceneUnchanged());
    bool _S882 = !_S881;
    bool _S883;
    if(_S882)
    {
        uint2  _S884 = (fcptRenderSize());
        int2  _S885 = make_int2 ((int)_S884.x, (int)_S884.y);
        _S883 = all_0(_S880 < _S885);
    }
    else
    {
        _S883 = false;
    }
    if(_S883)
    {
        Reservoir _S886 = (fcptLoadReservoirInitial((_S880)));
        int2  _S887 = sampleNeighbor_0(_S880, _S886.seed);
        fcptStoreTemporalNeighbor((_S880), (_S887));
    }
    FixedArray<uint, 3>  _S888;
    temporalBins_0(_S880, &_S888);
    FixedArray<uint, 3>  _S889 = _S888;
    countShifts_0(&_S889, local_invocation_index_9);
    return;
}

static __device__ float interpolate_0(float a_8, float b_4, float t_19)
{
    return a_8 + (b_4 - a_8) * t_19;
}

__device__ float confidenceCap(float duplicated_0)
{
    float _S890 = interpolate_0(20.0f, 1.0f, (F32_pow((duplicated_0), (0.10000000149011612f))));
    return _S890;
}

__device__ float2  temporalWeights(float c_2, float p_c_1, float c_t_0, float p_t_0, float g_previous_0, float g_current_0)
{
    float _S891 = c_2 * p_c_1;
    float _S892 = c_t_0 * p_t_0;
    return make_float2 (_S891 / (_S891 + c_t_0 * g_previous_0), _S892 / (_S892 + c_2 * g_current_0));
}

static __device__ void restir_temporal_0(uint3  global_invocation_id_7)
{
    uint2  _S893 = uint2 {global_invocation_id_7.x, global_invocation_id_7.y};
    int2  _S894 = make_int2 ((int)_S893.x, (int)_S893.y);
    float3  _S895 = make_float3 (0.0f);
    FKHit _S896 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S897 = Domain_x24init_0(_S895, _S895, &_S896, 0.0f, 0.0f);
    Domain dom_5 = _S897;
    bool _S898 = (fcptCurrentDomain((_S894), (&dom_5)));
    bool _S899 = !_S898;
    if(_S899)
    {
        Reservoir _S900 = (Reservoir{});
        fcptStoreReservoirTemporal((_S894), (_S900), ((&dom_5)->hit));
        return;
    }
    Reservoir _S901 = (fcptLoadReservoirInitial((_S894)));
    bool _S902 = (fcptSceneUnchanged());
    int2  _S903;
    if(_S902)
    {
        int2  _S904 = sampleNeighbor_0(_S894, _S901.seed);
        _S903 = _S904;
    }
    else
    {
        int2  _S905 = (fcptLoadTemporalNeighbor((_S894)));
        _S903 = _S905;
    }
    bool _S906 = (_S903.x) >= int(0);
    Reservoir r_5;
    if(_S906)
    {
        Reservoir _S907 = (fcptLoadReservoirPrevious((_S903)));
        uint4  _S908 = (fcptDuplication((_S903)));
        float _S909 = (U32_asfloat((_S908.x)));
        uint _S910 = (fcptRestirDecorrelation());
        bool _S911 = _S910 == 1U;
        float _S912 = _slang_select(_S911, _S909,0.0f);
        float _S913 = confidenceCap(_S912);
        float _S914 = (F32_min((_S907.c), (_S913)));
        bool _S915 = (fcptSceneUnchanged());
        float4  _S916;
        if(_S915)
        {
            _S916 = make_float4 (_S907.f.x, _S907.f.y, _S907.f.z, 1.0f);
        }
        else
        {
            uint4  _S917 = (fcptTemporalShift((_S894), (0U)));
            _S916 = asfloat_0(_S917);
        }
        Domain own_1 = _S897;
        bool _S918;
        if(_S915)
        {
            _S918 = true;
        }
        else
        {
            bool _S919 = (fcptPreviousScenes());
            bool _S920 = !_S919;
            if(_S920)
            {
                _S918 = (_S901.w) > 0.0f;
            }
            else
            {
                _S918 = false;
            }
            if(_S918)
            {
                bool _S921 = (fcptStoredDomainInitial((_S894), (_S901.seed), (&own_1)));
                _S918 = _S921;
            }
            else
            {
                _S918 = false;
            }
            if(_S918)
            {
                Domain _S922 = (fcptPreviousDomain((_S903), (_S901.seed)));
                Domain _S923 = _S922;
                Domain _S924 = own_1;
                bool _S925 = sameDomain_0(&_S923, &_S924);
                _S918 = _S925;
            }
            else
            {
                _S918 = false;
            }
        }
        float4  _S926;
        if(_S918)
        {
            _S926 = make_float4 (_S901.f.x, _S901.f.y, _S901.f.z, 1.0f);
        }
        else
        {
            uint4  _S927 = (fcptTemporalShift((_S894), (1U)));
            _S926 = asfloat_0(_S927);
        }
        float _S928 = rgb_to_greyscale(_S901.f);
        float _S929 = rgb_to_greyscale(_S907.f);
        Selection _S930 = (Selection{});
        Selection sel_6 = _S930;
        uint _S931 = (fcptFrame());
        uint _S932 = hash(_S931);
        uint _S933 = global_invocation_id_7.x;
        uint2  _S934 = (fcptRenderSize());
        uint _S935 = stream(_S932, _S933 + _S934.x * global_invocation_id_7.y);
        uint _S936 = stream(_S935, 194U);
        (&sel_6)->random_state = _S936;
        float4  _S937 = _S926;
        float _S938 = rgb_to_greyscale(float3 {_S937.x, _S937.y, _S937.z});
        float4  _S939 = _S916;
        float3  _S940 = float3 {_S939.x, _S939.y, _S939.z};
        float _S941 = rgb_to_greyscale(_S940);
        float2  _S942 = temporalWeights(_S901.c, _S928, _S914, _S929, _S938, _S941);
        offerShifted(&sel_6, _S901, Shift_x24init_0(_S901.f, 1.0f), _S942.x);
        offerShifted(&sel_6, _S907, Shift_x24init_0(_S940, _S916.w), _S942.y);
        Reservoir _S943 = finalize(sel_6, _S901.c + _S914);
        r_5 = _S943;
    }
    else
    {
        r_5 = _S901;
    }
    fcptStoreReservoirTemporal((_S894), (r_5), ((&dom_5)->hit));
    return;
}

static __device__ void restir_initial_0(uint3  global_invocation_id_8)
{
    uint2  _S944 = uint2 {global_invocation_id_8.x, global_invocation_id_8.y};
    int2  _S945 = make_int2 ((int)_S944.x, (int)_S944.y);
    float3  _S946 = make_float3 (0.0f);
    float2  _S947 = make_float2 (0.0f);
    FKHit _S948 = Hit_x24init_0(_S947, 0U, 0U, 0U, 0.0f);
    Domain _S949 = Domain_x24init_0(_S946, _S946, &_S948, 0.0f, 0.0f);
    Domain dom_6 = _S949;
    bool _S950 = (fcptCurrentDomain((_S945), (&dom_6)));
    bool _S951 = !_S950;
    if(_S951)
    {
        Reservoir _S952 = (Reservoir{});
        fcptStoreReservoirInitial((_S945), (_S952), ((&dom_6)->hit));
        return;
    }
    uint _S953 = (fcptFrame());
    uint _S954 = hash(_S953);
    uint _S955 = global_invocation_id_8.x;
    uint2  _S956 = (fcptRenderSize());
    uint _S957 = stream(_S954, _S955 + _S956.x * global_invocation_id_8.y);
    Selection _S958 = (Selection{});
    Selection initial_0 = _S958;
    uint _S959 = stream(_S957, 193U);
    (&initial_0)->random_state = _S959;
    bool _S960 = (fcptRestirUsed());
    bool _S961 = !_S960;
    (&initial_0)->sums = _S961;
    uint _S962 = stream(_S957, 0U);
    (&(&initial_0)->r)->seed = _S962;
    FKHit _S963 = Hit_x24init_0(_S947, 4294967295U, 0U, 0U, 0.0f);
    uint _S964 = (fcptSamples());
    float _S965 = 1.0f / float(_S964);
    FKHit hit_2 = _S963;
    uint i_17 = 0U;
    for(;;)
    {
        uint _S966 = (fcptSamples());
        if(i_17 < _S966)
        {
        }
        else
        {
            break;
        }
        Reservoir _S967 = (Reservoir{});
        Reservoir r_6 = _S967;
        uint _S968 = stream(_S957, i_17);
        (&r_6)->seed = _S968;
        Domain path_0 = _S949;
        bool _S969 = (fcptStoredDomainInitial((_S945), ((&r_6)->seed), (&path_0)));
        bool _S970 = !_S969;
        if(_S970)
        {
            fcptMissed((_S945), (path_0), (_S965));
            uint i_18 = i_17 + 1U;
            i_17 = i_18;
            continue;
        }
        Domain _S971 = path_0;
        Reservoir _S972 = r_6;
        Shift _S973 = passWalk_0(&_S971, &_S972, false, _S965, &initial_0);
        bool _S974 = ((&(&initial_0)->r)->seed) == ((&r_6)->seed);
        FKHit hit_3;
        if(_S974)
        {
            FKHit _S975 = (&path_0)->hit;
            hit_3 = _S975;
        }
        else
        {
            hit_3 = hit_2;
        }
        hit_2 = hit_3;
        uint i_18 = i_17 + 1U;
        i_17 = i_18;
    }
    float3  _S976 = (&initial_0)->glow;
    float3  _S977 = (&initial_0)->color;
    bool _S978 = (&initial_0)->sums;
    float3  _S979 = _slang_select(_S978, _S977,_S946);
    fcptAddColor((_S945), (make_float4 ((_S976 + _S979).x, (_S976 + _S979).y, (_S976 + _S979).z, 1.0f)));
    Reservoir _S980 = finalize(initial_0, 1.0f);
    fcptStoreReservoirInitial((_S945), (_S980), (hit_2));
    return;
}

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_3, float3  origin_5, float3  smooth_n_3, float3  start_6)
{
    NEEVertex _S981;
    (&_S981)->none = none_0;
    (&_S981)->pdf = pdf_3;
    (&_S981)->origin = origin_5;
    (&_S981)->smooth_n = smooth_n_3;
    (&_S981)->start = start_6;
    return _S981;
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
    Vertex _S982;
    (&_S982)->rough = rough_0;
    (&_S982)->lobe = lobe_1;
    (&_S982)->pdf = pdf_4;
    (&_S982)->cos = cos_0;
    (&_S982)->inside = inside_0;
    return _S982;
}

static __device__ float freeFlight_0(float u_1, float sigma_0)
{
    return - (F32_log((1.0f - u_1))) / sigma_0;
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

static __device__ float3  flightWeight_0(float3  scatter_0, float3  extinction_0, float sigma_1, float distance_2, bool scatters_0)
{
    float3  _S983 = exp_0((make_float3 (sigma_1) - extinction_0) * make_float3 (distance_2));
    float3  _S984 = scatter_0 * _S983 / make_float3 (sigma_1);
    float3  _S985 = _slang_select(scatters_0, _S984,_S983);
    return _S985;
}

static __device__ bool scatterSampled_0(bool replay_1, uint b_5, uint stop_0, bool varying_0)
{
    bool _S986 = !replay_1;
    bool _S987;
    if(_S986)
    {
        _S987 = true;
    }
    else
    {
        bool _S988 = b_5 == stop_0;
        if(_S988)
        {
            _S987 = !varying_0;
        }
        else
        {
            _S987 = false;
        }
    }
    return _S987;
}

static __device__ uint arrivalLobe_0(uint b_6, uint prev_lobe_0)
{
    bool _S989 = b_6 > 0U;
    uint _S990 = _slang_select(_S989, prev_lobe_0,3U);
    return _S990;
}

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_0, uint depth_1, uint lobe_2, bool surface_5, float length_2, float width_1, FKHit * own_2, bool fiber_0)
{
    ShadowContext _S991;
    (&_S991)->extinction_behind = extinction_behind_0;
    (&_S991)->extinction_front = extinction_front_0;
    (&_S991)->fillings = fillings_0;
    (&_S991)->side = side_0;
    (&_S991)->depth = depth_1;
    (&_S991)->lobe = lobe_2;
    (&_S991)->surface = surface_5;
    (&_S991)->length = length_2;
    (&_S991)->width = width_1;
    (&_S991)->own = *own_2;
    (&_S991)->fiber = fiber_0;
    return _S991;
}

static __device__ float phaseHG_0(float g_0, float mu_0)
{
    bool _S992 = (F32_abs((g_0))) < 0.00100000004749745f;
    if(_S992)
    {
        return 0.07957746833562851f;
    }
    float _S993 = g_0 * g_0;
    return (1.0f - _S993) * 0.25f * 0.31830987334251404f / (F32_pow((1.0f + _S993 - 2.0f * g_0 * mu_0), (1.5f)));
}

__device__ float3  safeDivide(float3  a_9, float3  b_7)
{
    float3  _S994 = a_9 / b_7;
    float3  _S995 = make_float3 (0.0f);
    bool3  _S996 = b_7 == _S995;
    float3  _S997 = _slang_select(_S996, _S995,_S994);
    return _S997;
}

static __device__ uint insertBits_0(uint e_2, uint newbits_0, uint offset_1, uint count_6)
{
    uint _S998 = (1U << count_6) - 1U;
    return (e_2 & (~(_S998 << offset_1))) | ((newbits_0 & _S998) << offset_1);
}

__device__ Reservoir withEnd(Reservoir r_7, uint end_type_0, uint end_0, float3  f_5)
{
    Reservoir candidate_2 = r_7;
    uint _S999 = insertBits_0(r_7.path, end_0, 0U, 5U);
    uint _S1000 = insertBits_0(_S999, end_type_0, 12U, 3U);
    (&candidate_2)->path = _S1000;
    (&candidate_2)->f = f_5;
    return candidate_2;
}

__device__ float survivalProbability(float3  throughput_0, float density_1)
{
    return (F32_min(((F32_max(((F32_max((throughput_0.x), ((F32_max((throughput_0.y), (throughput_0.z)))))) / density_1), (0.0f)))), (1.0f)));
}

static __device__ float3  isotropic_0(uint random_state_9)
{
    Random _S1001 = pcg(random_state_9);
    Random _S1002 = pcg(_S1001.state);
    float _S1003 = 1.0f - 2.0f * _S1001.value;
    float _S1004 = (F32_sqrt(((F32_max((1.0f - _S1003 * _S1003), (0.0f))))));
    float _S1005 = 6.28318548202514648f * _S1002.value;
    return make_float3 (_S1004 * (F32_cos((_S1005))), _S1004 * (F32_sin((_S1005))), _S1003);
}

static __device__ float3  samplePhase_0(float g_1, float3  dir_9, uint random_state_10, float * pdf_5)
{
    bool _S1006 = (F32_abs((g_1))) < 0.00100000004749745f;
    if(_S1006)
    {
        *pdf_5 = 0.07957746833562851f;
        float3  _S1007 = isotropic_0(random_state_10);
        return _S1007;
    }
    Random _S1008 = pcg(random_state_10);
    Random _S1009 = pcg(_S1008.state);
    float _S1010 = g_1 * g_1;
    float _S1011 = 2.0f * g_1;
    float _S1012 = (1.0f - _S1010) / (1.0f - g_1 + _S1011 * _S1008.value);
    float _S1013 = clamp_1((1.0f + _S1010 - _S1012 * _S1012) / _S1011, -1.0f, 1.0f);
    float _S1014 = (F32_sqrt(((F32_max((1.0f - _S1013 * _S1013), (0.0f))))));
    float _S1015 = 6.28318548202514648f * _S1009.value;
    float _S1016 = phaseHG_0(g_1, _S1013);
    *pdf_5 = _S1016;
    float3  _S1017 = tangentToWorld(make_float3 (_S1014 * (F32_cos((_S1015))), _S1013, _S1014 * (F32_sin((_S1015)))), dir_9);
    float3  _S1018 = ((((_S1017)) * make_float3(rnorm3df(((_S1017)).x, ((_S1017)).y, ((_S1017)).z))));
    return _S1018;
}

static __device__ Vertex scatteredVertex_0(bool is_inside_5)
{
    return Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_5);
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_0, float3  emissive_0, float roughness_0, float metallic_0, float transmission_0, float ior_0, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_2, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_2, float velvet_0, float3  toon_2)
{
    BSDFMaterial _S1019;
    (&_S1019)->albedo = albedo_0;
    (&_S1019)->emissive = emissive_0;
    (&_S1019)->roughness = roughness_0;
    (&_S1019)->metallic = metallic_0;
    (&_S1019)->transmission = transmission_0;
    (&_S1019)->ior = ior_0;
    (&_S1019)->absorption = absorption_0;
    (&_S1019)->specular_tint = specular_tint_0;
    (&_S1019)->specular_level = specular_level_0;
    (&_S1019)->translucent = translucent_0;
    (&_S1019)->sheen = sheen_2;
    (&_S1019)->sheen_roughness = sheen_roughness_0;
    (&_S1019)->anisotropy = anisotropy_0;
    (&_S1019)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S1019)->tangent = tangent_2;
    (&_S1019)->velvet = velvet_0;
    (&_S1019)->toon = toon_2;
    return _S1019;
}

static __device__ FKMedium Medium_x24init_0(float3  scatter_1, float3  extinction_1, float g_2)
{
    FKMedium _S1020;
    (&_S1020)->scatter = scatter_1;
    (&_S1020)->extinction = extinction_1;
    (&_S1020)->g = g_2;
    return _S1020;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_10, bool skip_0, uint random_state_11, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S1021;
    (&_S1021)->smooth_n = smooth_n_4;
    (&_S1021)->geometry_n = geometry_n_2;
    (&_S1021)->geometry_offset = geometry_offset_2;
    (&_S1021)->material = *material_10;
    (&_S1021)->skip = skip_0;
    (&_S1021)->random_state = random_state_11;
    (&_S1021)->coverage = coverage_0;
    (&_S1021)->encloses = encloses_0;
    (&_S1021)->volume = *volume_0;
    (&_S1021)->fills = fills_0;
    (&_S1021)->hair = hair_0;
    return _S1021;
}

static __device__ FKSurface emitting_0(FKSurface * surface_6, bool top_0)
{
    FKSurface lower_0 = *surface_6;
    float3  _S1022 = (&surface_6->material)->emissive;
    float3  _S1023 = make_float3 (0.0f);
    bool _S1024 = !top_0;
    float3  _S1025 = _slang_select(_S1024, _S1023,_S1022);
    (&(&lower_0)->material)->emissive = _S1025;
    return lower_0;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_7, float u_2)
{
    float _S1026 = surface_7->coverage;
    bool _S1027 = u_2 < _S1026;
    if(_S1027)
    {
        return *surface_7;
    }
    float3  _S1028 = make_float3 (0.0f);
    float3  _S1029 = make_float3 (1.0f);
    BSDFMaterial _S1030 = Material_x24init_0(_S1028, _S1028, 0.0f, 0.0f, 0.0f, 0.0f, _S1028, _S1029, 1.0f, _S1028, _S1028, 0.5f, 0.0f, 0.0f, _S1028, 0.0f, _S1028);
    BSDFMaterial material_11 = _S1030;
    (&material_11)->albedo = _S1029;
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
    bool _S1031 = transmission_1 > 0.0f;
    bool _S1032;
    if(_S1031)
    {
        _S1032 = true;
    }
    else
    {
        _S1032 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S1033;
    if(_S1032)
    {
        _S1033 = 1.0f;
    }
    else
    {
        _S1033 = -1.0f;
    }
    return _S1033;
}

static __device__ bool arrivesBehind_0(float3  dir_10, float3  n_9)
{
    return (dot_0(dir_10, n_9)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_8, float3  dir_11)
{
    float3  _S1034 = surface_8->geometry_n;
    float _S1035 = facingSign((&surface_8->material)->transmission, surface_8->geometry_n, dir_11);
    FKSurface faced_0 = *surface_8;
    float3  _S1036 = surface_8->smooth_n * make_float3 (_S1035);
    (&faced_0)->smooth_n = _S1036;
    float3  _S1037 = _S1034 * make_float3 (_S1035);
    (&faced_0)->geometry_n = _S1037;
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
    float3  _S1038 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_3) * log_0(_S1038));
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
    bool _S1039;
    if(open_0)
    {
        _S1039 = prev_rough_0;
    }
    else
    {
        _S1039 = false;
    }
    if(_S1039)
    {
        _S1039 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S1039 = false;
    }
    return _S1039;
}

__device__ float2  vertexEta(BSDFMaterial material_12, float n_dot_v_0)
{
    bool _S1040 = n_dot_v_0 < 0.0f;
    float _S1041 = _slang_select(_S1040, material_12.ior,1.0f);
    float _S1042 = _slang_select(_S1040, 1.0f,material_12.ior);
    return make_float2 (_S1041, _S1042);
}

__device__ bool neeDecision(BSDFMaterial material_13, float n_dot_v_1, float eta_i_9, float eta_o_9)
{
    float _S1043 = fresnel((F32_abs((n_dot_v_1))), eta_i_9, eta_o_9);
    float3  _S1044 = mix_0(make_float3 (_S1043), material_13.albedo, material_13.metallic);
    float _S1045 = rgb_to_greyscale(_S1044);
    float _S1046 = (F32_max(((1.0f - _S1045) * (1.0f - material_13.metallic) * (1.0f - material_13.transmission)), (0.0f)));
    bool _S1047 = _S1046 > 0.03999999910593033f;
    bool _S1048;
    if(_S1047)
    {
        _S1048 = true;
    }
    else
    {
        _S1048 = (material_13.roughness) > 0.20000000298023224f;
    }
    return _S1048;
}

static __device__ bool isTranslucent_0(BSDFMaterial * material_14)
{
    float _S1049 = rgb_to_greyscale(material_14->translucent);
    return _S1049 > 0.0f;
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
    MediumSides _S1050;
    (&_S1050)->behind = *behind_0;
    (&_S1050)->front = *front_0;
    (&_S1050)->fillings = fillings_1;
    (&_S1050)->face = face_1;
    return _S1050;
}

static __device__ MediumSides mediumSides_0(FKSurface * surface_9, FKMedium * medium_0, uint filling_0, float3  dir_12, FKMedium * outside_0)
{
    float3  _S1051 = surface_9->geometry_n;
    MediumSides _S1052 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_9->geometry_n);
    MediumSides sides_0 = _S1052;
    bool _S1053 = surface_9->encloses;
    if(_S1053)
    {
        (&sides_0)->behind = surface_9->volume;
        *&((&(&sides_0)->fillings)->x) = surface_9->fills;
        bool _S1054 = (dot_0(dir_12, _S1051)) > 0.0f;
        if(_S1054)
        {
            (&sides_0)->front = *outside_0;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_10, bool turned_0, float3  extinction_2, uint filling_1, float3  dir_13, uint depth_2, uint lobe_3, float length_3, float width_2, FKHit * own_3, bool fiber_1, FKMedium * outside_1)
{
    float3  _S1055 = surface_10->geometry_n;
    ShadowContext _S1056 = ShadowContext_x24init_0(extinction_2, extinction_2, make_uint2 (filling_1), surface_10->geometry_n, depth_2, lobe_3, true, length_3, width_2, own_3, fiber_1);
    bool _S1057 = surface_10->encloses;
    ShadowContext context_4;
    if(_S1057)
    {
        FKSurface faced_1 = *surface_10;
        float3  _S1058 = - _S1055;
        float3  _S1059 = _slang_select(turned_0, _S1058,_S1055);
        (&faced_1)->geometry_n = _S1059;
        FKMedium _S1060 = Medium_x24init_0(make_float3 (0.0f), extinction_2, 0.0f);
        FKSurface _S1061 = faced_1;
        FKMedium _S1062 = _S1060;
        MediumSides _S1063 = mediumSides_0(&_S1061, &_S1062, filling_1, dir_13, outside_1);
        ShadowContext _S1064 = ShadowContext_x24init_0(_S1063.behind.extinction, _S1063.front.extinction, _S1063.fillings, _S1055, depth_2, lobe_3, true, length_3, width_2, own_3, fiber_1);
        if(turned_0)
        {
            uint2  _S1065 = _S1063.fillings;
            ShadowContext _S1066 = ShadowContext_x24init_0(_S1063.front.extinction, _S1063.behind.extinction, uint2 {_S1065.y, _S1065.x}, _S1055, depth_2, lobe_3, true, length_3, width_2, own_3, fiber_1);
            context_4 = _S1066;
        }
        else
        {
            context_4 = _S1064;
        }
    }
    else
    {
        context_4 = _S1056;
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

static __device__ __forceinline__ float3  lightBSDF_0(float3  in_dir_8, TreeSample * light_2, float3  smooth_n_5, float3  geometry_n_4, BSDFMaterial * material_15, float eta_i_10, float eta_o_10, bool competing_1, uint random_state_12)
{
    float3  _S1067 = light_2->dir;
    bool _S1068 = (dot_0(geometry_n_4, - in_dir_8) * dot_0(geometry_n_4, light_2->dir)) <= 0.0f;
    FixedArray<float3 , 5>  throughputs_1;
    FixedArray<float, 5>  pdfs_3;
    float3  _S1069 = BSDF(in_dir_8, _S1067, smooth_n_5, *material_15, eta_i_10, eta_o_10, _S1068, random_state_12, &throughputs_1, &pdfs_3);
    bool _S1070 = !competing_1;
    bool _S1071;
    if(_S1070)
    {
        _S1071 = true;
    }
    else
    {
        _S1071 = (light_2->density) == 0.0f;
    }
    if(_S1071)
    {
        return _S1069 * light_2->radiance;
    }
    float3  _S1072 = make_float3 (0.0f);
    uint i_23 = 0U;
    float3  weighted_0 = _S1072;
    for(;;)
    {
        if(i_23 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S1073 = (pdfs_3[i_23]) > 0.0f;
        if(_S1073)
        {
            float _S1074 = light_2->density;
            float _S1075 = pdfs_3[i_23] / light_2->density;
            float3  weighted_1 = weighted_0 + throughputs_1[i_23] * make_float3 (pdfs_3[i_23]) / make_float3 (_S1074 * (1.0f + _S1075 * _S1075));
            weighted_0 = weighted_1;
        }
        uint i_24 = i_23 + 1U;
        i_23 = i_24;
    }
    return weighted_0 * light_2->radiance * make_float3 (light_2->density);
}

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_1, uint random_state_13, bool refracted_3, uint lobe_4, float pdf_6)
{
    SampleBSDF _S1076;
    (&_S1076)->unit_direction = unit_direction_1;
    (&_S1076)->throughput = throughput_1;
    (&_S1076)->random_state = random_state_13;
    (&_S1076)->refracted = refracted_3;
    (&_S1076)->lobe = lobe_4;
    (&_S1076)->pdf = pdf_6;
    return _S1076;
}

__device__ __forceinline__ SampleBSDF sheenVelvetSample(float3  n_i_8, float n_i_dot_v_6, float alpha_15, BSDFMaterial material_16, BSDFLobes lobes_11, float eta_i_11, float eta_o_11, uint random_state_14)
{
    float3  _S1077 = make_float3 (1.0f);
    SampleBSDF _S1078 = SampleBSDF_x24init_0(_S1077, _S1077, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S1078;
    Random _S1079 = pcg(random_state_14);
    Random _S1080 = pcg(_S1079.state);
    (&sample_1)->random_state = _S1080.state;
    float _S1081 = _S1079.value;
    float _S1082 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1081 * _S1081))))));
    float _S1083 = 6.28318548202514648f * _S1080.value;
    float3  _S1084 = tangentToWorld(make_float3 (_S1082 * (F32_cos((_S1083))), _S1079.value, _S1082 * (F32_sin((_S1083)))), n_i_8);
    (&sample_1)->unit_direction = _S1084;
    (&sample_1)->lobe = 4U;
    float3  _S1085 = sheenVelvetBSDF((&sample_1)->unit_direction, n_i_8, alpha_15, material_16, lobes_11);
    (&sample_1)->throughput = _S1085;
    float _S1086 = sheenVelvetPDF(_S1079.value, 0.0f, n_i_dot_v_6, alpha_15, lobes_11, eta_i_11, eta_o_11);
    (&sample_1)->pdf = _S1086;
    return sample_1;
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S1087 = (F32_sqrt((random_1_0)));
    float _S1088 = 6.28318548202514648f * random_2_0;
    float _S1089 = _S1087 * (F32_cos((_S1088)));
    float _S1090 = _S1087 * (F32_sin((_S1088)));
    float _S1091 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1089 * _S1089 - _S1090 * _S1090))))));
    return make_float3 (_S1089, _S1091, _S1090);
}

__device__ __forceinline__ SampleBSDF diffuseSample(float u_3, float3  n_i_9, float n_i_dot_v_7, float alpha_16, BSDFMaterial material_17, BSDFLobes lobes_12, float eta_i_12, float eta_o_12, uint random_state_15)
{
    float3  _S1092 = make_float3 (1.0f);
    SampleBSDF _S1093 = SampleBSDF_x24init_0(_S1092, _S1092, 0U, false, 0U, 0.0f);
    SampleBSDF sample_2 = _S1093;
    Random _S1094 = pcg(random_state_15);
    Random _S1095 = pcg(_S1094.state);
    (&sample_2)->random_state = _S1095.state;
    float3  _S1096 = sampleCosWeightedHemisphere(_S1094.value, _S1095.value);
    bool _S1097 = u_3 < (lobes_12.p_diffuse * lobes_12.translucent_share);
    float _S1098 = _S1096.y;
    float _S1099 = - _S1098;
    float _S1100 = _slang_select(_S1097, _S1099,_S1098);
    float3  _S1101 = tangentToWorld(make_float3 (_S1096.x, _S1100, _S1096.z), n_i_9);
    (&sample_2)->unit_direction = _S1101;
    (&sample_2)->refracted = _S1097;
    (&sample_2)->lobe = 0U;
    float3  _S1102 = diffuseBSDF((&sample_2)->unit_direction, n_i_9, alpha_16, material_17, lobes_12);
    (&sample_2)->throughput = _S1102;
    float _S1103 = diffusePDF(_S1100, 0.0f, n_i_dot_v_7, alpha_16, lobes_12, eta_i_12, eta_o_12);
    (&sample_2)->pdf = _S1103;
    return sample_2;
}

__device__ __forceinline__ SampleBSDF toonSample(float3  n_i_10, float n_i_dot_v_8, float alpha_17, BSDFMaterial material_18, BSDFLobes lobes_13, float eta_i_13, float eta_o_13, uint random_state_16)
{
    float3  _S1104 = make_float3 (1.0f);
    SampleBSDF _S1105 = SampleBSDF_x24init_0(_S1104, _S1104, 0U, false, 0U, 0.0f);
    SampleBSDF sample_3 = _S1105;
    Random _S1106 = pcg(random_state_16);
    Random _S1107 = pcg(_S1106.state);
    (&sample_3)->random_state = _S1107.state;
    float _S1108 = _S1106.value * lobes_13.toon_norm / 6.28318548202514648f;
    float t_20;
    if(lobes_13.toon_glossy)
    {
        t_20 = (F32_acos((clamp_1(1.0f - _S1108, -1.0f, 1.0f))));
    }
    else
    {
        t_20 = (F32_asin(((F32_min(((F32_sqrt((2.0f * _S1108)))), (1.0f))))));
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
        float _S1109;
        if(t_20 < (lobes_13.toon_a))
        {
            _S1109 = 1.0f;
        }
        else
        {
            _S1109 = (F32_max((1.0f - (t_20 - lobes_13.toon_a) / (F32_max((lobes_13.toon_s), (0.0000152587890625f)))), (0.0f)));
        }
        float integral_1;
        if(lobes_13.toon_glossy)
        {
            integral_1 = 1.0f - (F32_cos(((F32_min((t_20), (lobes_13.toon_a))))));
        }
        else
        {
            float _S1110 = (F32_sin(((F32_min((t_20), (lobes_13.toon_a))))));
            integral_1 = _S1110 * _S1110 / 2.0f;
        }
        bool _S1111 = t_20 > (lobes_13.toon_a);
        bool _S1112;
        if(_S1111)
        {
            _S1112 = (lobes_13.toon_s) > 0.0f;
        }
        else
        {
            _S1112 = false;
        }
        float integral_2;
        if(_S1112)
        {
            if(lobes_13.toon_glossy)
            {
                float _S1113 = (F32_cos((lobes_13.toon_a)));
                float _S1114 = (F32_cos((t_20)));
                integral_2 = (1.0f + lobes_13.toon_a / lobes_13.toon_s) * (_S1113 - _S1114) - ((F32_sin((t_20))) - t_20 * _S1114 - ((F32_sin((lobes_13.toon_a))) - lobes_13.toon_a * _S1113)) / lobes_13.toon_s;
            }
            else
            {
                float _S1115 = 2.0f * lobes_13.toon_a;
                float _S1116 = (F32_cos((_S1115)));
                float _S1117 = 2.0f * t_20;
                float _S1118 = (F32_cos((_S1117)));
                integral_2 = (1.0f + lobes_13.toon_a / lobes_13.toon_s) * (_S1116 - _S1118) / 4.0f - ((F32_sin((_S1117))) / 8.0f - t_20 * _S1118 / 4.0f - ((F32_sin((_S1115))) / 8.0f - lobes_13.toon_a * _S1116 / 4.0f)) / lobes_13.toon_s;
            }
            float integral_3 = integral_1 + integral_2;
            integral_2 = integral_3;
        }
        else
        {
            integral_2 = integral_1;
        }
        float _S1119 = _S1109 * (F32_sin((t_20)));
        float _S1120;
        if(lobes_13.toon_glossy)
        {
            _S1120 = 1.0f;
        }
        else
        {
            _S1120 = (F32_cos((t_20)));
        }
        float _S1121 = _S1119 * _S1120;
        float _S1122 = (integral_2 - _S1108) / _S1121;
        bool _S1123 = _S1121 > 0.0f;
        float _S1124 = _slang_select(_S1123, _S1122,0.0f);
        float _S1125 = clamp_1(t_20 - _S1124, 0.0f, lobes_13.toon_b);
        int k_1 = k_0 + int(1);
        t_20 = _S1125;
        k_0 = k_1;
    }
    float _S1126 = 6.28318548202514648f * _S1107.value;
    float _S1127 = (F32_sin((t_20)));
    float3  _S1128 = tangentToWorld(make_float3 (_S1127 * (F32_cos((_S1126))), (F32_cos((t_20))), _S1127 * (F32_sin((_S1126)))), lobes_13.toon_axis);
    (&sample_3)->unit_direction = _S1128;
    bool _S1129 = (dot_0(n_i_10, (&sample_3)->unit_direction)) < 0.0f;
    (&sample_3)->refracted = _S1129;
    (&sample_3)->lobe = 6U;
    float3  _S1130 = toonBSDF((&sample_3)->unit_direction, n_i_10, alpha_17, material_18, lobes_13);
    (&sample_3)->throughput = _S1130;
    float _S1131 = toonPDF(dot_0(n_i_10, (&sample_3)->unit_direction), dot_0((&sample_3)->unit_direction, lobes_13.toon_axis), n_i_dot_v_8, alpha_17, lobes_13, eta_i_13, eta_o_13);
    (&sample_3)->pdf = _S1131;
    return sample_3;
}

__device__ __forceinline__ SampleBSDF refractSample(float3  ggx_n_3, float3  n_i_11, float n_i_dot_v_9, float alpha_18, BSDFMaterial material_19, BSDFLobes lobes_14, float eta_i_14, float eta_o_14, uint random_state_17)
{
    float3  _S1132 = make_float3 (1.0f);
    SampleBSDF _S1133 = SampleBSDF_x24init_0(_S1132, _S1132, 0U, false, 0U, 0.0f);
    SampleBSDF sample_4 = _S1133;
    (&sample_4)->unit_direction = lobes_14.refracted;
    (&sample_4)->random_state = random_state_17;
    (&sample_4)->refracted = true;
    (&sample_4)->lobe = 1U;
    float3  _S1134 = refractBSDF((&sample_4)->unit_direction, n_i_11, alpha_18, material_19, lobes_14);
    (&sample_4)->throughput = _S1134;
    float _S1135 = refractPDF(0.0f, dot_0((&sample_4)->unit_direction, ggx_n_3), n_i_dot_v_9, alpha_18, lobes_14, eta_i_14, eta_o_14);
    (&sample_4)->pdf = _S1135;
    return sample_4;
}

static __device__ float3  reflect_0(float3  i_25, float3  n_10)
{
    return i_25 - make_float3 (2.0f * dot_0(n_10, i_25)) * n_10;
}

__device__ __forceinline__ SampleBSDF reflectSample(float3  in_dir_9, float3  ggx_n_4, float3  n_i_12, float n_i_dot_v_10, float alpha_19, BSDFMaterial material_20, BSDFLobes lobes_15, float eta_i_15, float eta_o_15, uint random_state_18)
{
    float3  _S1136 = make_float3 (1.0f);
    SampleBSDF _S1137 = SampleBSDF_x24init_0(_S1136, _S1136, 0U, false, 0U, 0.0f);
    SampleBSDF sample_5 = _S1137;
    float3  _S1138 = reflect_0(in_dir_9, ggx_n_4);
    float3  _S1139 = ((((_S1138)) * make_float3(rnorm3df(((_S1138)).x, ((_S1138)).y, ((_S1138)).z))));
    (&sample_5)->unit_direction = _S1139;
    (&sample_5)->random_state = random_state_18;
    (&sample_5)->lobe = 2U;
    float3  _S1140 = reflectBSDF((&sample_5)->unit_direction, n_i_12, alpha_19, material_20, lobes_15);
    (&sample_5)->throughput = _S1140;
    float _S1141 = reflectPDF(0.0f, 0.0f, n_i_dot_v_10, alpha_19, lobes_15, eta_i_15, eta_o_15);
    (&sample_5)->pdf = _S1141;
    return sample_5;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_10, float3  n_11, BSDFMaterial material_21, float eta_i_16, float eta_o_16, uint random_init_0, float2  screen_space_0)
{
    uint random_state_19 = random_init_0;
    float3  _S1142 = negate_0(in_dir_10);
    float _S1143 = dot_0(n_11, _S1142);
    float _S1144 = sign_0(_S1143);
    float3  n_i_13 = n_11 * make_float3 (_S1144);
    float _S1145 = (F32_abs((_S1143)));
    float _S1146 = material_21.roughness;
    float _S1147 = _S1146 * _S1146;
    AnisotropicFrame _S1148 = anisotropicFrame(material_21, n_i_13);
    float3  _S1149 = sampleHalfVector(_S1142, n_i_13, _S1147, _S1148, &random_state_19);
    BSDFLobes _S1150 = bsdfLobes(in_dir_10, _S1142, n_i_13, _S1149, material_21, eta_i_16, eta_o_16, _S1148);
    BSDFLobes lobes_16 = _S1150;
    float _S1151 = translucentShare(material_21);
    (&lobes_16)->translucent_share = _S1151;
    Random _S1152 = pcg(random_state_19);
    random_state_19 = _S1152.state;
    bool _S1153 = (_S1152.value) < ((&lobes_16)->p_sheen_velvet);
    if(_S1153)
    {
        SampleBSDF _S1154 = sheenVelvetSample(n_i_13, _S1145, _S1147, material_21, lobes_16, eta_i_16, eta_o_16, random_state_19);
        return _S1154;
    }
    float _S1155 = _S1152.value - (&lobes_16)->p_sheen_velvet;
    bool _S1156 = _S1155 < ((&lobes_16)->p_diffuse);
    if(_S1156)
    {
        SampleBSDF _S1157 = diffuseSample(_S1155, n_i_13, _S1145, _S1147, material_21, lobes_16, eta_i_16, eta_o_16, random_state_19);
        return _S1157;
    }
    bool _S1158 = _S1155 < ((&lobes_16)->p_diffuse + (&lobes_16)->p_toon);
    if(_S1158)
    {
        SampleBSDF _S1159 = toonSample(n_i_13, _S1145, _S1147, material_21, lobes_16, eta_i_16, eta_o_16, random_state_19);
        return _S1159;
    }
    float _S1160 = (&lobes_16)->p_toon;
    bool _S1161 = (_S1155 - _S1160) < ((&lobes_16)->p_diffuse + (&lobes_16)->p_refract);
    if(_S1161)
    {
        SampleBSDF _S1162 = refractSample(_S1149, n_i_13, _S1145, _S1147, material_21, lobes_16, eta_i_16, eta_o_16, random_state_19);
        return _S1162;
    }
    SampleBSDF _S1163 = reflectSample(in_dir_10, _S1149, n_i_13, _S1145, _S1147, material_21, lobes_16, eta_i_16, eta_o_16, random_state_19);
    return _S1163;
}

__device__ bool withinInverseFootprint(float pdf_7, bool diffuse_0, float prev_cos_0, float distance_5, float threshold_1)
{
    bool _S1164 = pdf_7 > 0.0f;
    bool _S1165;
    if(_S1164)
    {
        if(diffuse_0)
        {
            _S1165 = true;
        }
        else
        {
            _S1165 = (pdf_7 * prev_cos_0 / (distance_5 * distance_5) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S1165 = false;
    }
    return _S1165;
}

__device__ bool roughLobe(float pdf_8, bool diffuse_1, float roughness_1)
{
    bool _S1166 = pdf_8 > 0.0f;
    bool _S1167;
    if(_S1166)
    {
        if(diffuse_1)
        {
            _S1167 = true;
        }
        else
        {
            _S1167 = roughness_1 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S1167 = false;
    }
    return _S1167;
}

static __device__ bool passesLayer_0(uint layers_0, bool refracting_0, bool passed_0)
{
    bool _S1168 = layers_0 > 1U;
    bool _S1169;
    if(_S1168)
    {
        _S1169 = refracting_0 != passed_0;
    }
    else
    {
        _S1169 = false;
    }
    return _S1169;
}

static __device__ float widened_0(float spread_1, float pdf_9, bool delta_0)
{
    float _S1170 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * pdf_9))))), (3.14159274101257324f)));
    bool _S1171 = !delta_0;
    float _S1172 = _slang_select(_S1171, _S1170,0.0f);
    return spread_1 + _S1172;
}

static __device__ bool boundsVolume_0(FKSurface * surface_11)
{
    return surface_11->encloses;
}

static __device__ bool leavesInFront_0(float3  face_2, float3  dir_14, float3  g_3)
{
    return ((dot_0(dir_14, g_3)) > 0.0f) == ((dot_0(g_3, face_2)) > 0.0f);
}

static __device__ Shift walk_0(Domain * dom_7, Reservoir * r_8, bool replay_2, float scale_3, Selection * sel_7)
{
    float spread_2;
    bool turned_1;
    bool is_inside_6;
    bool viewed_0;
    bool _S1173;
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
    int _S1174;
    Shift ended_0;
    float density_3;
    float spread_3;
    float width_4;
    float sky_pdf_1;
    float spread_4;
    float width_5;
    uint b_9;
    float3  _S1175 = make_float3 (0.0f);
    Shift _S1176 = Shift_x24init_0(_S1175, 0.0f);
    uint _S1177 = r_8->path;
    uint _S1178 = extractBits_0(r_8->path, 0U, 5U);
    uint _S1179 = extractBits_0(_S1177, 5U, 5U);
    uint _S1180 = extractBits_0(_S1177, 10U, 2U);
    uint _S1181 = extractBits_0(_S1177, 12U, 3U);
    bool passes_0;
    if(replay_2)
    {
        bool _S1182 = _S1181 >= 3U;
        uint _S1183 = _slang_select(_S1182, 1U,0U);
        uint _S1184 = _S1178 + _S1183;
        uint _S1185 = (fcptMaxBounces());
        passes_0 = _S1184 > _S1185;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S1176;
    }
    uint _S1186 = _S1179 - 1U;
    bool _S1187 = _S1181 == 3U;
    uint _S1188 = _slang_select(_S1187, 1U,0U);
    uint _S1189 = _S1178 + _S1188;
    bool _S1190 = _S1180 == 0U;
    uint _S1191 = _slang_select(_S1190, _S1189,_S1186);
    FKHit _S1192 = (fcptReservoirHit((*r_8)));
    float3  _S1193 = dom_7->x0;
    float3  _S1194 = dom_7->x1 - dom_7->x0;
    float3  _S1195 = ((((_S1194)) * make_float3(rnorm3df(((_S1194)).x, ((_S1194)).y, ((_S1194)).z))));
    FKRay _S1196 = Ray_x24init_0(dom_7->x1, _S1195);
    FKRay ray_2 = _S1196;
    FKHit hit_4 = dom_7->hit;
    float3  scatter_in_0 = _S1175;
    float3  throughput_3 = make_float3 (1.0f);
    float3  weight_1 = throughput_3;
    float3  glowed_0 = _S1175;
    float3  extinction_in_0 = _S1175;
    float g_in_0 = 0.0f;
    uint filling_2 = 4294967295U;
    float _S1197 = dom_7->spread;
    float _S1198 = dom_7->width;
    float _S1199 = length_0(_S1194);
    NEEVertex _S1200 = NEEVertex_x24init_0(true, 0.0f, _S1175, _S1175, _S1175);
    NEEVertex nee_vertex_0 = _S1200;
    Vertex _S1201 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_0 = _S1201;
    Reservoir _S1202 = (Reservoir{});
    Reservoir chain_0 = _S1202;
    uint _S1203 = r_8->seed;
    (&chain_0)->seed = r_8->seed;
    (&ray_2)->origin = _S1193;
    (&hit_4)->distance = _S1199;
    FKMedium _S1204 = (fcptCameraMedium(((&ray_2)->unit_direction), ((&hit_4)->distance), (&filling_2)));
    uint _S1205 = filling_2;
    bool _S1206 = (fcptVaryingUsed());
    uint _S1207 = _slang_select(_S1206, _S1205,4294967295U);
    filling_2 = _S1207;
    scatter_in_0 = _S1204.scatter;
    extinction_in_0 = _S1204.extinction;
    g_in_0 = _S1204.g;
    Reservoir _S1208 = chain_0;
    uint _S1209 = filling_2;
    for(;;)
    {
        bool _S1210 = (fcptVaryingUsed());
        if(_S1210)
        {
            passes_0 = _S1209 != 4294967295U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            float _S1211 = (fcptMajorant((_S1209)));
            spread_2 = _S1211;
        }
        else
        {
            spread_2 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
        }
        if(replay_2)
        {
            turned_1 = 4294967295U == _S1191;
        }
        else
        {
            turned_1 = false;
        }
        if(turned_1)
        {
            turned_1 = _S1180 == 1U;
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
            ended_0 = _S1176;
            sky_pdf_0 = 0.0f;
            spread_2 = _S1197;
            width_3 = _S1198;
            density_2 = 1.0f;
            throughput_2 = throughput_3;
            b_8 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S1212 = (&prev_0)->rough;
        if(_S1212)
        {
            turned_1 = !(spread_2 > 0.0f);
        }
        else
        {
            turned_1 = false;
        }
        (&prev_0)->rough = turned_1;
        uint _S1213 = stream(_S1203, 384U);
        uint tracking_0 = _S1213;
        weight_1 = throughput_3;
        glowed_0 = _S1175;
        b_8 = 4294967295U;
        throughput_2 = throughput_3;
        density_2 = 1.0f;
        threshold_2 = _S1197;
        width_3 = _S1198;
        sky_pdf_0 = 0.0f;
        for(;;)
        {
            if(((&hit_4)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S1174 = int(1);
                break;
            }
            uint _S1214 = b_8 + 320U;
            bool _S1215 = b_8 == 4294967295U;
            uint _S1216 = _slang_select(_S1215, 384U,_S1214);
            uint _S1217 = stream(_S1203, _S1216);
            Random _S1218 = pcg(_S1217);
            float _S1219 = freeFlight_0(_S1218.value, spread_2);
            if(passes_0)
            {
                float3  _S1220 = (&ray_2)->origin;
                float3  _S1221 = (&ray_2)->unit_direction;
                float _S1222 = (&hit_4)->distance;
                uint _S1223 = _slang_select(_S1215, 0U,b_8);
                uint _S1224 = (&prev_0)->lobe;
                uint _S1225 = _slang_select(_S1215, 3U,_S1224);
                float _S1226 = (fcptTrackMedium((_S1209), (_S1220), (_S1221), (_S1222), (&tracking_0), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1223), (_S1225), (_S1215)));
                geometry_density_2 = _S1226;
            }
            else
            {
                geometry_density_2 = _S1219;
            }
            bool _S1227 = !(geometry_density_2 < ((&hit_4)->distance));
            if(_S1227)
            {
                _S1174 = int(1);
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
                float3  _S1228 = throughput_2 * glowed_0 / make_float3 (density_2);
                float3  _S1229 = sel_7->glow + _S1228;
                sel_7->glow = _S1229;
            }
            else
            {
            }
            glowed_0 = _S1175;
            uint b_10 = b_8 + 1U;
            float3  _S1230 = (&ray_2)->origin + make_float3 (geometry_density_2) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S1230;
            float3  _S1231 = flightWeight_0(scatter_in_0, extinction_in_0, spread_2, geometry_density_2, true);
            float3  _S1232 = weight_1;
            float3  _S1233 = _slang_select(passes_0, _S1232,_S1231);
            float3  throughput_4 = throughput_2 * _S1233;
            uint _S1234 = stream(_S1203, b_10 + 320U);
            tracking_0 = _S1234;
            weight_1 = throughput_3;
            float width_6 = width_3 + threshold_2 * geometry_density_2;
            float _S1235 = threshold_2 + 3.14159274101257324f;
            bool _S1236 = scatterSampled_0(replay_2, b_10, _S1191, passes_0);
            TreeSample _S1237 = TreeSample_x24init_0(_S1175, _S1175, 0.0f, 0U);
            if(_S1236)
            {
                float3  _S1238 = (&ray_2)->origin;
                float3  _S1239 = (&ray_2)->unit_direction;
                float3  _S1240 = (&ray_2)->unit_direction;
                uint _S1241 = stream(_S1203, b_10 + 64U);
                float3  _S1242 = extinction_in_0;
                float3  _S1243 = extinction_in_0;
                uint2  _S1244 = make_uint2 (_S1209);
                float3  _S1245 = (&ray_2)->unit_direction;
                uint _S1246 = arrivalLobe_0(b_10, (&prev_0)->lobe);
                FKHit _S1247 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S1248 = _S1247;
                ShadowContext _S1249 = ShadowContext_x24init_0(_S1242, _S1243, _S1244, _S1245, b_10, _S1246, false, geometry_density_2, width_6, &_S1248, false);
                ShadowContext _S1250 = _S1249;
                TreeSample _S1251 = sampleLightTree_0(_S1238, _S1239, _S1240, 0.0f, true, _S1241, &_S1250);
                light_3 = _S1251;
            }
            else
            {
                light_3 = _S1237;
            }
            float _S1252 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_3.dir));
            uint _S1253 = (fcptMaxBounces());
            bool _S1254 = b_10 < _S1253;
            if(_S1254)
            {
                is_inside_6 = (light_3.density) > 0.0f;
            }
            else
            {
                is_inside_6 = false;
            }
            float _S1255 = _slang_select(is_inside_6, _S1252,0.0f);
            float3  _S1256 = throughput_4 * light_3.radiance;
            float _S1257 = powerHeuristic(light_3.density, _S1255);
            float3  _S1258 = _S1256 * make_float3 (_S1252 * _S1257);
            float3  _S1259 = _slang_select(_S1236, _S1258,_S1175);
            if(replay_2)
            {
                viewed_0 = b_10 == _S1191;
            }
            else
            {
                viewed_0 = false;
            }
            if(viewed_0)
            {
                bool _S1260 = _S1180 == 2U;
                if(_S1260)
                {
                    float _S1261 = rgb_to_greyscale(_S1259);
                    passes_0 = _S1261 > 0.0f;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S1262 = Shift_x24init_0(_S1259, 1.0f);
                    _S1174 = int(0);
                    ended_0 = _S1262;
                    spread_2 = _S1235;
                    geometry_density_2 = width_6;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_10;
                    break;
                }
                _S1174 = int(0);
                ended_0 = _S1176;
                spread_2 = _S1235;
                geometry_density_2 = width_6;
                chain_throughput_0 = throughput_4;
                layer_0 = b_10;
                break;
            }
            bool _S1263 = !replay_2;
            if(_S1263)
            {
                Reservoir candidate_3 = _S1208;
                uint _S1264 = extractBits_0(_S1208.path, 10U, 2U);
                bool _S1265 = _S1264 == 1U;
                if(_S1265)
                {
                    float3  _S1266 = safeDivide(_S1259, _S1175);
                    (&candidate_3)->radiance = _S1266;
                }
                else
                {
                    uint _S1267 = insertBits_0(0U, b_10 + 1U, 5U, 5U);
                    uint _S1268 = insertBits_0(_S1267, 2U, 10U, 2U);
                    (&candidate_3)->path = _S1268;
                }
                Reservoir _S1269 = withEnd(candidate_3, 0U, b_10, _S1259);
                offer(sel_7, _S1269, _S1259 * make_float3 (scale_3) / make_float3 (density_2));
                float _S1270 = survivalProbability(throughput_4, density_2);
                uint _S1271 = stream(_S1203, b_10 + 128U);
                Random _S1272 = pcg(_S1271);
                bool _S1273 = _S1270 < (_S1272.value);
                if(_S1273)
                {
                    _S1173 = true;
                }
                else
                {
                    uint _S1274 = (fcptMaxBounces());
                    _S1173 = b_10 >= _S1274;
                }
                if(_S1173)
                {
                    _S1174 = int(0);
                    ended_0 = _S1176;
                    spread_2 = _S1235;
                    geometry_density_2 = width_6;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_10;
                    break;
                }
                float _S1275 = density_2 * _S1270;
                density_2 = _S1275;
            }
            else
            {
            }
            float phase_pdf_0 = 0.0f;
            uint _S1276 = stream(_S1203, b_10);
            float3  _S1277 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1276, &phase_pdf_0);
            (&ray_2)->unit_direction = _S1277;
            NEEVertex _S1278 = NEEVertex_x24init_0(false, phase_pdf_0, (&ray_2)->origin, _S1175, (&ray_2)->origin);
            nee_vertex_0 = _S1278;
            Vertex _S1279 = scatteredVertex_0(false);
            prev_0 = _S1279;
            float _S1280 = (&prev_0)->pdf;
            FKRay _S1281 = ray_2;
            FKHit _S1282 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S1283 = (fcptTraverseInstanceBVH((_S1281), (true), (4.294967296e+09f), (false), (_S1282), (false)));
            hit_4 = _S1283;
            b_8 = b_10;
            throughput_2 = throughput_4;
            threshold_2 = _S1235;
            width_3 = width_6;
            sky_pdf_0 = _S1280;
        }
        if(_S1174 != int(1))
        {
            width_3 = geometry_density_2;
            throughput_2 = chain_throughput_0;
            b_8 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S1176;
        spread_2 = threshold_2;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    bool _S1284 = b_8 == 4294967295U;
    bool _S1285 = ((&hit_4)->instance_index) == 4294967295U;
    if(_S1285)
    {
        bool _S1286 = !(&nee_vertex_0)->none;
        float _S1287 = _slang_select(_S1286, sky_pdf_0,0.0f);
        float _S1288 = escapeWeight_0(_S1287, (&ray_2)->unit_direction);
        float3  _S1289 = environment_0((&ray_2)->unit_direction, b_8, (&prev_0)->lobe);
        float3  _S1290 = throughput_2 * _S1289;
        if(replay_2)
        {
            bool _S1291 = b_8 == _S1191;
            if(_S1291)
            {
                passes_0 = _S1180 == 3U;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                return Shift_x24init_0(_S1290 * make_float3 (_S1288) / make_float3 (r_8->jac), density_2 / r_8->jac);
            }
            if(_S1190)
            {
                passes_0 = _S1187;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                passes_0 = b_8 == _S1178;
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
                return Shift_x24init_0(_S1290 * make_float3 (_S1288), 1.0f);
            }
            return _S1176;
        }
        Reservoir candidate_4 = chain_0;
        uint _S1292 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1293 = _S1292 == 1U;
        if(_S1293)
        {
            uint _S1294 = extractBits_0((&chain_0)->path, 5U, 5U);
            bool _S1295 = _S1294 == b_8;
            float _S1296 = _slang_select(_S1295, 1.0f,_S1288);
            float3  _S1297 = safeDivide(_S1290 * make_float3 (_S1296), _S1175);
            (&candidate_4)->radiance = _S1297;
        }
        else
        {
            bool _S1298 = (&prev_0)->rough;
            if(_S1298)
            {
                uint _S1299 = insertBits_0(0U, b_8 + 1U, 5U, 5U);
                uint _S1300 = insertBits_0(_S1299, 3U, 10U, 2U);
                uint _S1301 = insertBits_0(_S1300, (&prev_0)->lobe, 15U, 3U);
                bool _S1302 = (&prev_0)->inside;
                uint _S1303 = _slang_select(_S1302, 1U,0U);
                uint _S1304 = insertBits_0(_S1301, _S1303, 22U, 1U);
                (&candidate_4)->path = _S1304;
                (&candidate_4)->jac = (&prev_0)->pdf;
                (&candidate_4)->dir = (&ray_2)->unit_direction;
            }
        }
        float3  _S1305 = _S1290 * make_float3 (_S1288);
        Reservoir _S1306 = withEnd(candidate_4, 3U, b_8, _S1305);
        offer(sel_7, _S1306, _S1305 * make_float3 (scale_3) / make_float3 (density_2));
        return _S1176;
    }
    float3  _S1307 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
    (&ray_2)->origin = _S1307;
    bool _S1308 = (fcptVaryingUsed());
    if(_S1308)
    {
        passes_0 = filling_2 != 4294967295U;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        bool _S1309 = !replay_2;
        if(_S1309)
        {
            float3  _S1310 = throughput_2 * glowed_0 / make_float3 (density_2);
            float3  _S1311 = sel_7->glow + _S1310;
            sel_7->glow = _S1311;
        }
        float3  _S1312 = throughput_2 * weight_1;
        throughput_2 = _S1312;
    }
    else
    {
        float3  _S1313 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
        float3  _S1314 = throughput_2 * _S1313;
        throughput_2 = _S1314;
    }
    float _S1315 = width_3 + spread_2 * (&hit_4)->distance;
    uint _S1316 = b_8 + 1U;
    b_8 = _S1316;
    layer_0 = 0U;
    width_3 = _S1315;
    passes_0 = false;
    threshold_2 = 0.0f;
    turned_1 = false;
    is_inside_6 = false;
    chain_throughput_0 = _S1175;
    float3  reconnection_0 = _S1175;
    viewed_0 = _S1284;
    for(;;)
    {
        bool _S1317 = ((&hit_4)->is_point_light) == 1U;
        if(replay_2)
        {
            _S1173 = _S1180 == 1U;
        }
        else
        {
            _S1173 = false;
        }
        bool _S1318;
        if(_S1173)
        {
            _S1318 = b_8 == _S1179;
        }
        else
        {
            _S1318 = false;
        }
        bool _S1319;
        if(_S1318)
        {
            bool _S1320 = ((&hit_4)->instance_index) != (_S1192.instance_index);
            if(_S1320)
            {
                _S1319 = true;
            }
            else
            {
                _S1319 = ((&hit_4)->triangle_index) != (_S1192.triangle_index);
            }
        }
        else
        {
            _S1319 = false;
        }
        if(_S1319)
        {
            return _S1176;
        }
        FKMedium _S1321 = Medium_x24init_0(_S1175, _S1175, 0.0f);
        BSDFMaterial _S1322 = Material_x24init_0(_S1175, _S1175, 0.0f, 0.0f, 0.0f, 0.0f, _S1175, throughput_3, 1.0f, _S1175, _S1175, 0.5f, 0.0f, 0.0f, _S1175, 0.0f, _S1175);
        FKMedium _S1323 = _S1321;
        FKSurface _S1324 = Surface_x24init_0(_S1175, _S1175, 0.0f, &_S1322, false, 0U, 1.0f, false, &_S1323, 4294967295U, _S1175);
        bool _S1325 = !_S1317;
        bool scatter_2;
        bool is_inside_7;
        float3  throughput_5;
        FKSurface surface_12;
        if(_S1325)
        {
            uint _S1326 = stream(_S1203, b_8);
            uint _S1327 = arrivalLobe_0(b_8, (&prev_0)->lobe);
            FKSurface _S1328 = (fcptSurfaceAtPath((hit_4), ((&ray_2)->origin), (_S1326), (width_3), (layer_0), (b_8), (_S1327), ((&ray_2)->unit_direction)));
            bool _S1329 = !passes_0;
            FKSurface _S1330 = _S1328;
            FKSurface _S1331 = emitting_0(&_S1330, _S1329);
            uint _S1332 = stream(_S1203, b_8 + 256U);
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
                is_inside_7 = _S1342;
            }
            else
            {
                is_inside_7 = scatter_2;
            }
            if(is_inside_7)
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
            float geometry_density_3 = geometryDensity(_S1341.geometry_n, (&ray_2)->unit_direction, (&hit_4)->distance);
            bool _S1346 = b_8 == _S1316;
            if(_S1346)
            {
                float _S1347 = footprintThreshold(geometry_density_3);
                geometry_density_2 = _S1347;
            }
            else
            {
                geometry_density_2 = threshold_2;
            }
            float _S1348 = geometry_density_2;
            scatter_2 = _S1345;
            geometry_density_2 = geometry_density_3;
            threshold_2 = _S1348;
            surface_12 = _S1341;
            turned_1 = _S1337;
        }
        else
        {
            scatter_2 = false;
            geometry_density_2 = 0.0f;
            surface_12 = _S1324;
            throughput_5 = throughput_2;
            is_inside_7 = is_inside_6;
        }
        bool _S1349 = withinFootprint(scatter_2, (&prev_0)->rough, (&prev_0)->pdf, geometry_density_2, threshold_2);
        FKSurface _S1350 = surface_12;
        FKSurface _S1351 = surface_12;
        float _S1352 = dot_0(surface_12.smooth_n, - (&ray_2)->unit_direction);
        float2  _S1353 = vertexEta(_S1350.material, _S1352);
        bool _S1354;
        if(scatter_2)
        {
            bool _S1355 = neeDecision(_S1350.material, _S1352, _S1353.x, _S1353.y);
            _S1354 = _S1355;
        }
        else
        {
            _S1354 = false;
        }
        bool _S1356;
        if(passes_0)
        {
            _S1356 = true;
        }
        else
        {
            _S1356 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S1356)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S1354;
        }
        bool _S1357 = (fcptHairUsed());
        bool _S1358;
        if(_S1357)
        {
            float3  _S1359 = surface_12.hair;
            _S1358 = (dot_0(_S1359, _S1359)) > 0.0f;
        }
        else
        {
            _S1358 = false;
        }
        bool _S1360;
        if(_S1358)
        {
            _S1360 = true;
        }
        else
        {
            BSDFMaterial _S1361 = _S1350.material;
            bool _S1362 = isTranslucent_0(&_S1361);
            _S1360 = _S1362;
        }
        bool _S1363;
        if(_S1360)
        {
            _S1363 = true;
        }
        else
        {
            bool _S1364 = (_S1350.material.transmission) > 0.0f;
            if(_S1364)
            {
                uint _S1365 = (fcptLayers((hit_4)));
                _S1363 = _S1365 == 1U;
            }
            else
            {
                _S1363 = false;
            }
        }
        float3  emission_0;
        if(_S1317)
        {
            float3  _S1366 = (fcptCalculatePointLightContrib(((&hit_4)->instance_index)));
            emission_0 = _S1366;
        }
        else
        {
            emission_0 = _S1350.material.emissive;
        }
        bool _S1367 = !replay_2;
        bool _S1368;
        if(_S1367)
        {
            _S1368 = true;
        }
        else
        {
            _S1368 = b_8 >= _S1191;
        }
        bool _S1369;
        if(_S1368)
        {
            float _S1370 = rgb_to_greyscale(emission_0);
            _S1369 = _S1370 > 0.0f;
        }
        else
        {
            _S1369 = false;
        }
        float3  emission_1;
        if(_S1369)
        {
            NEEVertex _S1371 = nee_vertex_0;
            FKHit _S1372 = hit_4;
            float _S1373 = emissionWeight_0(&_S1371, &_S1372, (&ray_2)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S1373);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S1374;
        if(replay_2)
        {
            _S1374 = _S1180 == 1U;
        }
        else
        {
            _S1374 = false;
        }
        bool _S1375;
        if(_S1374)
        {
            _S1375 = b_8 > _S1179;
        }
        else
        {
            _S1375 = false;
        }
        bool _S1376;
        if(_S1375)
        {
            _S1376 = b_8 == _S1178;
        }
        else
        {
            _S1376 = false;
        }
        bool _S1377;
        if(_S1376)
        {
            bool _S1378 = _S1181 == 1U;
            if(_S1378)
            {
                _S1377 = true;
            }
            else
            {
                _S1377 = _S1181 == 2U;
            }
        }
        else
        {
            _S1377 = false;
        }
        if(_S1377)
        {
            bool _S1379 = _S1317 != (_S1181 == 2U);
            if(_S1379)
            {
                return _S1176;
            }
            return Shift_x24init_0(throughput_5 * emission_1 / make_float3 (r_8->jac), density_2 / r_8->jac);
        }
        uint _S1380 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1381 = _S1380 == 1U;
        Reservoir here_0 = chain_0;
        uint _S1382 = insertBits_0(0U, b_8, 5U, 5U);
        uint _S1383 = insertBits_0(_S1382, 1U, 10U, 2U);
        uint _S1384 = insertBits_0(_S1383, (&prev_0)->lobe, 15U, 3U);
        bool _S1385 = (&prev_0)->inside;
        uint _S1386 = _slang_select(_S1385, 1U,0U);
        uint _S1387 = insertBits_0(_S1384, _S1386, 22U, 1U);
        (&here_0)->path = _S1387;
        float _S1388 = (&prev_0)->pdf * geometry_density_2;
        (&here_0)->jac = _S1388;
        fcptWithReservoirHit((&here_0), (&hit_4));
        bool _S1389;
        if(replay_2)
        {
            _S1389 = _S1180 == 1U;
        }
        else
        {
            _S1389 = false;
        }
        bool _S1390;
        if(_S1389)
        {
            _S1390 = b_8 == _S1179;
        }
        else
        {
            _S1390 = false;
        }
        bool _S1391 = b_8 == _S1191;
        bool _S1392;
        if(_S1391)
        {
            bool _S1393 = !scatter_2;
            if(_S1393)
            {
                _S1392 = true;
            }
            else
            {
                bool _S1394 = _S1180 != 1U;
                if(_S1394)
                {
                    _S1392 = _S1180 != 3U;
                }
                else
                {
                    _S1392 = false;
                }
            }
        }
        else
        {
            _S1392 = false;
        }
        bool _S1395;
        if(_S1392)
        {
            _S1395 = _S1180 == 2U;
        }
        else
        {
            _S1395 = false;
        }
        bool _S1396;
        if(_S1395)
        {
            _S1396 = !_S1349;
        }
        else
        {
            _S1396 = false;
        }
        bool _S1397;
        if(_S1396)
        {
            _S1397 = _S1181 != 4U;
        }
        else
        {
            _S1397 = false;
        }
        bool _S1398 = _S1179 == _S1178;
        bool _S1399;
        if(_S1398)
        {
            _S1399 = _S1181 == 0U;
        }
        else
        {
            _S1399 = false;
        }
        bool _S1400;
        if(_S1399)
        {
            _S1400 = ((&hit_4)->instance_index) == (_S1192.instance_index);
        }
        else
        {
            _S1400 = false;
        }
        bool _S1401;
        if(_S1400)
        {
            _S1401 = ((&hit_4)->triangle_index) == (_S1192.triangle_index);
        }
        else
        {
            _S1401 = false;
        }
        bool _S1402;
        if(_S1401)
        {
            _S1402 = _S1349;
        }
        else
        {
            _S1402 = false;
        }
        bool _S1403 = _slang_select(_S1390, _S1402,_S1397);
        bool _S1404;
        if(nee_0)
        {
            _S1404 = _slang_select(replay_2, _S1403,scatter_2);
        }
        else
        {
            _S1404 = false;
        }
        TreeSample _S1405 = TreeSample_x24init_0(_S1175, _S1175, 0.0f, 0U);
        uint2  _S1406 = make_uint2 (0U);
        float2  _S1407 = make_float2 (0.0f);
        FKHit _S1408 = Hit_x24init_0(_S1407, 4294967295U, 0U, 0U, 0.0f);
        FKHit _S1409 = _S1408;
        ShadowContext _S1410 = ShadowContext_x24init_0(_S1175, _S1175, _S1406, _S1175, 0U, 0U, false, 0.0f, 0.0f, &_S1409, false);
        bool _S1411;
        if(nee_0)
        {
            _S1411 = _S1368;
        }
        else
        {
            _S1411 = false;
        }
        ShadowContext context_5;
        if(_S1411)
        {
            uint _S1412 = arrivalLobe_0(b_8, (&prev_0)->lobe);
            FKMedium _S1413 = (fcptOutsideMedium((hit_4)));
            FKSurface _S1414 = surface_12;
            FKHit _S1415 = hit_4;
            FKMedium _S1416 = _S1413;
            ShadowContext _S1417 = shadowContext_0(&_S1414, turned_1, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_8, _S1412, (&hit_4)->distance, width_3, &_S1415, _S1358, &_S1416);
            context_5 = _S1417;
        }
        else
        {
            context_5 = _S1410;
        }
        float3  throughput_6;
        float3  lit_0;
        if(_S1404)
        {
            float3  _S1418 = (&ray_2)->origin;
            if(_S1358)
            {
                throughput_6 = _S1175;
            }
            else
            {
                throughput_6 = _S1351.smooth_n;
            }
            FKSurface _S1419 = surface_12;
            uint _S1420 = stream(_S1203, b_8 + 64U);
            ShadowContext _S1421 = context_5;
            TreeSample _S1422 = sampleLightTree_0(_S1418, throughput_6, surface_12.geometry_n, surface_12.geometry_offset, _S1363, _S1420, &_S1421);
            bool _S1423 = any_1((_S1422.radiance) != _S1175);
            if(_S1423)
            {
                if(_S1358)
                {
                    uint _S1424 = (fcptMaxBounces());
                    bool _S1425 = b_8 < _S1424;
                    FKSurface _S1426 = surface_12;
                    TreeSample _S1427 = _S1422;
                    float3  _S1428 = hairLight_0(&_S1426, (&ray_2)->unit_direction, &_S1427, _S1425);
                    lit_0 = _S1428;
                }
                else
                {
                    float _S1429 = _S1353.x;
                    float _S1430 = _S1353.y;
                    uint _S1431 = (fcptMaxBounces());
                    bool _S1432 = b_8 < _S1431;
                    TreeSample _S1433 = _S1422;
                    BSDFMaterial _S1434 = _S1350.material;
                    float3  _S1435 = lightBSDF_0((&ray_2)->unit_direction, &_S1433, _S1351.smooth_n, _S1419.geometry_n, &_S1434, _S1429, _S1430, _S1432, surface_12.random_state);
                    lit_0 = _S1435;
                }
            }
            else
            {
                lit_0 = _S1175;
            }
            light_3 = _S1422;
        }
        else
        {
            light_3 = _S1405;
            lit_0 = _S1175;
        }
        bool viewed_1;
        bool refracted_4;
        bool wrong_side_0;
        bool _S1436;
        bool _S1437;
        float density_4;
        if(_S1390)
        {
            bool _S1438 = !_S1349;
            if(_S1438)
            {
                return _S1176;
            }
            float3  throughput_7 = throughput_5 * make_float3 (geometry_density_2);
            float density_5 = density_2 * geometry_density_2;
            if(_S1398)
            {
                viewed_1 = _S1181 == 1U;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                return Shift_x24init_0(throughput_7 * emission_1 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1398)
            {
                refracted_4 = _S1181 == 0U;
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
            {
                bool _S1439 = !nee_0;
                if(_S1439)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S1440 = rgb_to_greyscale(light_3.radiance);
                    passes_0 = !(_S1440 > 0.0f);
                }
                if(passes_0)
                {
                    return _S1176;
                }
                return Shift_x24init_0(throughput_7 * lit_0 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1398)
            {
                wrong_side_0 = _S1181 == 4U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                bool _S1441 = !nee_0;
                if(_S1441)
                {
                    return _S1176;
                }
                float _S1442 = environmentPdf_0(r_8->dir);
                float3  _S1443 = skyBSDF((&ray_2)->unit_direction, r_8->dir, surface_12, _S1353, is_inside_7, _S1442, surface_12.random_state);
                return Shift_x24init_0(throughput_7 * _S1443 * r_8->radiance / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            uint _S1444 = extractBits_0(_S1177, 21U, 1U);
            bool _S1445 = nee_0 != (_S1444 == 1U);
            if(_S1445)
            {
                return _S1176;
            }
            throughput_6 = throughput_7;
            density_4 = density_5;
        }
        else
        {
            if(replay_2)
            {
                viewed_1 = _S1391;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                bool _S1446 = !scatter_2;
                if(_S1446)
                {
                    refracted_4 = true;
                }
                else
                {
                    bool _S1447 = _S1180 != 1U;
                    if(_S1447)
                    {
                        refracted_4 = _S1180 != 3U;
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
                bool _S1448 = _S1180 == 2U;
                if(_S1448)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1349;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1181 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    if(_S1358)
                    {
                        return _S1176;
                    }
                    uint _S1449 = stream(_S1203, b_8 + 448U);
                    FKRay _S1450 = ray_2;
                    FKSurface _S1451 = surface_12;
                    ShadowContext _S1452 = context_5;
                    SkySample _S1453 = sampleSky_0(&_S1450, &_S1451, _S1353, is_inside_7, _S1449, surface_12.random_state, &_S1452);
                    return Shift_x24init_0(throughput_5 * _S1453.color, 1.0f);
                }
                if(_S1448)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1349;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float _S1454 = rgb_to_greyscale(light_3.radiance);
                    bool _S1455 = !(_S1454 > 0.0f);
                    if(_S1455)
                    {
                        return _S1176;
                    }
                    return Shift_x24init_0(throughput_5 * lit_0, 1.0f);
                }
                if(_S1190)
                {
                    passes_0 = _S1181 == 2U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1317;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_5 * emission_1, 1.0f);
                }
                if(_S1190)
                {
                    passes_0 = _S1181 == 1U;
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
                    passes_0 = !_S1349;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_5 * emission_1, 1.0f);
                }
                return _S1176;
            }
            else
            {
                if(_S1367)
                {
                    wrong_side_0 = scatter_2;
                }
                else
                {
                    wrong_side_0 = false;
                }
                if(wrong_side_0)
                {
                    bool _S1456 = b_8 > 0U;
                    if(_S1456)
                    {
                        Reservoir candidate_5 = chain_0;
                        if(_S1381)
                        {
                            float3  _S1457 = safeDivide(throughput_5 * emission_1, chain_throughput_0);
                            (&candidate_5)->radiance = _S1457;
                        }
                        else
                        {
                            if(_S1349)
                            {
                                candidate_5 = here_0;
                            }
                        }
                        float3  _S1458 = throughput_5 * emission_1;
                        Reservoir _S1459 = withEnd(candidate_5, 1U, b_8, _S1458);
                        offer(sel_7, _S1459, _S1458 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    else
                    {
                        float3  _S1460 = throughput_5 * emission_1;
                        float3  _S1461 = sel_7->glow + _S1460;
                        sel_7->glow = _S1461;
                    }
                    if(nee_0)
                    {
                        float3  _S1462 = throughput_5 * lit_0;
                        Reservoir candidate_6 = chain_0;
                        if(_S1381)
                        {
                            float3  _S1463 = safeDivide(_S1462, chain_throughput_0);
                            (&candidate_6)->radiance = _S1463;
                        }
                        else
                        {
                            if(_S1349)
                            {
                                candidate_6 = here_0;
                                uint _S1464 = insertBits_0((&candidate_6)->path, 1U, 21U, 1U);
                                (&candidate_6)->path = _S1464;
                                (&candidate_6)->dir = light_3.dir;
                                (&candidate_6)->radiance = light_3.radiance;
                            }
                            else
                            {
                                uint _S1465 = insertBits_0(0U, b_8 + 1U, 5U, 5U);
                                uint _S1466 = insertBits_0(_S1465, 2U, 10U, 2U);
                                (&candidate_6)->path = _S1466;
                            }
                        }
                        Reservoir _S1467 = withEnd(candidate_6, 0U, b_8, _S1462);
                        offer(sel_7, _S1467, _S1462 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    if(nee_0)
                    {
                        if(_S1358)
                        {
                            _S1436 = false;
                        }
                        else
                        {
                            bool _S1468 = environmentMapped_0();
                            _S1436 = _S1468;
                        }
                    }
                    else
                    {
                        _S1436 = false;
                    }
                    if(_S1436)
                    {
                        uint _S1469 = (fcptMaxBounces());
                        _S1437 = b_8 < _S1469;
                    }
                    else
                    {
                        _S1437 = false;
                    }
                    if(_S1437)
                    {
                        uint _S1470 = stream(_S1203, b_8 + 448U);
                        FKRay _S1471 = ray_2;
                        FKSurface _S1472 = surface_12;
                        ShadowContext _S1473 = context_5;
                        SkySample _S1474 = sampleSky_0(&_S1471, &_S1472, _S1353, is_inside_7, _S1470, surface_12.random_state, &_S1473);
                        float3  _S1475 = throughput_5 * _S1474.color;
                        Reservoir candidate_7 = chain_0;
                        if(_S1381)
                        {
                            float3  _S1476 = safeDivide(_S1475, chain_throughput_0);
                            (&candidate_7)->radiance = _S1476;
                        }
                        else
                        {
                            if(_S1349)
                            {
                                candidate_7 = here_0;
                                uint _S1477 = insertBits_0((&candidate_7)->path, 1U, 21U, 1U);
                                (&candidate_7)->path = _S1477;
                                (&candidate_7)->dir = _S1474.dir;
                                (&candidate_7)->radiance = _S1474.radiance;
                            }
                            else
                            {
                                uint _S1478 = insertBits_0(0U, b_8 + 1U, 5U, 5U);
                                uint _S1479 = insertBits_0(_S1478, 2U, 10U, 2U);
                                (&candidate_7)->path = _S1479;
                            }
                        }
                        Reservoir _S1480 = withEnd(candidate_7, 4U, b_8, _S1475);
                        offer(sel_7, _S1480, _S1475 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                }
            }
            throughput_6 = throughput_5;
            density_4 = density_2;
        }
        bool _S1481;
        bool _S1482;
        bool _S1483;
        bool straight_0;
        bool _S1484;
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
                viewed_1 = _S1391;
            }
            else
            {
                viewed_1 = false;
            }
            uint _S1496 = extractBits_0(_S1177, 15U, 3U);
            uint _S1497 = extractBits_0(_S1177, 18U, 3U);
            uint _S1498 = _slang_select(_S1390, _S1497,_S1496);
            float3  _S1499 = r_8->dir;
            bool refracted_5 = _S1498 == 1U;
            SampleBSDF _S1500 = SampleBSDF_x24init_0(_S1175, _S1175, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_5 = _S1500;
            float3  reconnection_1;
            if(viewed_1)
            {
                uint _S1501 = extractBits_0(_S1177, 22U, 1U);
                bool _S1502 = is_inside_7 != (_S1501 == 1U);
                if(_S1502)
                {
                    return _S1176;
                }
                bool _S1503 = _S1180 == 1U;
                if(_S1503)
                {
                    float3  _S1504 = (fcptHitPosition((_S1192)));
                    throughput_8 = _S1504;
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
                    BSDFMaterial _S1505 = _S1350.material;
                    bool _S1506 = isTranslucent_0(&_S1505);
                    if(_S1506)
                    {
                        refracted_4 = _S1498 == 0U;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                    if(refracted_4)
                    {
                        float3  _S1507 = throughput_8 - (&ray_2)->origin;
                        float3  _S1508 = _slang_select(_S1503, _S1507,_S1499);
                        wrong_side_0 = (dot_0(_S1351.smooth_n, _S1508) * _S1352) < 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    refracted_4 = wrong_side_0;
                }
                if(_S1503)
                {
                    float3  _S1509 = (&ray_2)->origin;
                    FKSurface _S1510 = surface_12;
                    float3  _S1511 = - _S1351.smooth_n;
                    bool _S1512 = is_inside_7 != refracted_4;
                    float3  _S1513 = _slang_select(_S1512, _S1511,_S1351.smooth_n);
                    float3  _S1514 = throughput_8 - (_S1509 + make_float3 (_S1510.geometry_offset) * _S1513);
                    float3  _S1515 = ((((_S1514)) * make_float3(rnorm3df(((_S1514)).x, ((_S1514)).y, ((_S1514)).z))));
                    reconnection_1 = _S1515;
                }
                else
                {
                    reconnection_1 = _S1499;
                }
                if(_S1358)
                {
                    wrong_side_0 = false;
                }
                else
                {
                    bool _S1516 = wrongSide_0(is_inside_7, refracted_4, reconnection_1, surface_12.geometry_n);
                    wrong_side_0 = _S1516;
                }
                if(wrong_side_0)
                {
                    return _S1176;
                }
                float3  _S1517 = throughput_8;
                throughput_8 = reconnection_1;
                b_11 = _S1498;
                wrong_side_0 = false;
                reconnection_1 = _S1517;
            }
            else
            {
                bool _S1518 = !_S1390;
                if(_S1518)
                {
                    SampleBSDF bsdf_sampled_0;
                    SampleBSDF _S1519;
                    if(_S1358)
                    {
                        SampleBSDF _S1520 = (fcptSampleHair((surface_12.hair), (_S1350.material.albedo), (_S1350.material.specular_tint), ((&ray_2)->unit_direction), (surface_12.random_state)));
                        _S1519 = _S1520;
                    }
                    else
                    {
                        SampleBSDF _S1521 = sampleBSDF((&ray_2)->unit_direction, _S1351.smooth_n, _S1350.material, _S1353.x, _S1353.y, surface_12.random_state, _S1407);
                        _S1519 = _S1521;
                    }
                    bsdf_sampled_0 = _S1519;
                    if(_S1358)
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
                            return _S1176;
                        }
                        break;
                    }
                    if(_S1358)
                    {
                        wrong_side_0 = false;
                    }
                    else
                    {
                        bool _S1522 = wrongSide_0(is_inside_7, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, surface_12.geometry_n);
                        wrong_side_0 = _S1522;
                    }
                    if(wrong_side_0)
                    {
                        _S1436 = (_S1350.material.transmission) > 0.0f;
                    }
                    else
                    {
                        _S1436 = false;
                    }
                    if(_S1436)
                    {
                        SampleBSDF _S1523 = sampleBSDF((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n, _S1350.material, _S1353.x, _S1353.y, (&bsdf_sampled_0)->random_state, _S1407);
                        (&bsdf_sampled_0)->unit_direction = _S1523.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1523.refracted;
                        (&bsdf_sampled_0)->throughput = _S1523.throughput;
                    }
                    else
                    {
                        if(wrong_side_0)
                        {
                            float3  _S1524 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n)) * surface_12.geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1524;
                        }
                    }
                    uint _S1525 = (&bsdf_sampled_0)->lobe;
                    float3  _S1526 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1527 = (&bsdf_sampled_0)->refracted;
                    lobe_5 = bsdf_sampled_0;
                    float _S1528 = (&bsdf_sampled_0)->pdf;
                    float _S1529 = _slang_select(wrong_side_0, 0.0f,_S1528);
                    (&lobe_5)->pdf = _S1529;
                    throughput_8 = _S1526;
                    b_11 = _S1525;
                    refracted_4 = _S1527;
                }
                else
                {
                    throughput_8 = _S1499;
                    b_11 = _S1498;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(viewed_1)
            {
                _S1436 = true;
            }
            else
            {
                _S1436 = _S1390;
            }
            float3  chain_throughput_1;
            if(_S1436)
            {
                if(_S1358)
                {
                    SampleBSDF _S1530 = (fcptConnectHair((surface_12.hair), (_S1350.material.albedo), (_S1350.material.specular_tint), ((&ray_2)->unit_direction), (throughput_8)));
                    lobe_5 = _S1530;
                }
                else
                {
                    float3  _S1531 = (&ray_2)->unit_direction;
                    float _S1532 = sign_0(_S1352);
                    float3  _S1533 = _S1351.smooth_n * make_float3 (_S1532);
                    float _S1534 = dot_0(_S1533, throughput_8);
                    float _S1535 = _S1350.material.roughness;
                    float _S1536 = _S1535 * _S1535;
                    AnisotropicFrame _S1537 = anisotropicFrame(_S1350.material, _S1533);
                    float3  _S1538 = reflectedHalf(_S1531, throughput_8);
                    bool _S1539 = b_11 == 1U;
                    if(_S1539)
                    {
                        float3  _S1540 = refractedHalf(_S1531, throughput_8, _S1351.smooth_n, _S1353.x, _S1353.y);
                        throughput_9 = _S1540;
                    }
                    else
                    {
                        throughput_9 = _S1538;
                    }
                    bool _S1541 = b_11 == 0U;
                    if(_S1541)
                    {
                        _S1437 = true;
                    }
                    else
                    {
                        _S1437 = b_11 == 6U;
                    }
                    if(_S1437)
                    {
                        float3  _S1542 = sampledHalf(_S1531, _S1351.smooth_n, _S1350.material, surface_12.random_state, _S1537);
                        throughput_10 = _S1542;
                    }
                    else
                    {
                        throughput_10 = throughput_9;
                    }
                    float3  _S1543 = negate_0(_S1531);
                    float _S1544 = _S1353.x;
                    float _S1545 = _S1353.y;
                    BSDFLobes _S1546 = bsdfLobes(_S1531, _S1543, _S1533, throughput_10, _S1350.material, _S1544, _S1545, _S1537);
                    BSDFLobes lobe_terms_1 = _S1546;
                    float _S1547 = translucentShare(_S1350.material);
                    (&lobe_terms_1)->translucent_share = _S1547;
                    switch(b_11)
                    {
                    case 0U:
                        {
                            float _S1548 = diffusePDF(_S1534, 0.0f, (F32_abs((_S1352))), _S1536, lobe_terms_1, _S1544, _S1545);
                            float3  _S1549 = diffuseBSDF(throughput_8, _S1533, _S1536, _S1350.material, lobe_terms_1);
                            density_6 = _S1548;
                            chain_throughput_1 = _S1549;
                            break;
                        }
                    case 1U:
                        {
                            float _S1550 = refractPDF(_S1534, dot_0(throughput_8, throughput_10), (F32_abs((_S1352))), _S1536, lobe_terms_1, _S1544, _S1545);
                            float3  _S1551 = refractBSDF(throughput_8, _S1533, _S1536, _S1350.material, lobe_terms_1);
                            density_6 = _S1550;
                            chain_throughput_1 = _S1551;
                            break;
                        }
                    case 4U:
                        {
                            float _S1552 = sheenVelvetPDF(_S1534, 0.0f, (F32_abs((_S1352))), _S1536, lobe_terms_1, _S1544, _S1545);
                            float3  _S1553 = sheenVelvetBSDF(throughput_8, _S1533, _S1536, _S1350.material, lobe_terms_1);
                            density_6 = _S1552;
                            chain_throughput_1 = _S1553;
                            break;
                        }
                    case 6U:
                        {
                            float _S1554 = toonPDF(_S1534, dot_0(throughput_8, (&lobe_terms_1)->toon_axis), (F32_abs((_S1352))), _S1536, lobe_terms_1, _S1544, _S1545);
                            float3  _S1555 = toonBSDF(throughput_8, _S1533, _S1536, _S1350.material, lobe_terms_1);
                            density_6 = _S1554;
                            chain_throughput_1 = _S1555;
                            break;
                        }
                    default:
                        {
                            float _S1556 = reflectPDF(_S1534, 0.0f, (F32_abs((_S1352))), _S1536, lobe_terms_1, _S1544, _S1545);
                            float3  _S1557 = reflectBSDF(throughput_8, _S1533, _S1536, _S1350.material, lobe_terms_1);
                            density_6 = _S1556;
                            chain_throughput_1 = _S1557;
                            break;
                        }
                    }
                    bool _S1558 = density_6 > 0.0f;
                    if(_S1558)
                    {
                        SampleBSDF _S1559 = SampleBSDF_x24init_0(throughput_8, chain_throughput_1, surface_12.random_state, _S1539, b_11, density_6);
                        lobe_5 = _S1559;
                    }
                }
            }
            bool _S1560 = b_11 == 0U;
            if(_S1560)
            {
                _S1437 = true;
            }
            else
            {
                _S1437 = b_11 == 4U;
            }
            if(_S1437)
            {
                _S1481 = true;
            }
            else
            {
                _S1481 = b_11 == 6U;
            }
            if(_S1358)
            {
                _S1482 = false;
            }
            else
            {
                bool _S1561 = !_S1481;
                if(_S1561)
                {
                    bool _S1562 = (_S1350.material.roughness) == 0.0f;
                    if(_S1562)
                    {
                        _S1482 = true;
                    }
                    else
                    {
                        bool _S1563 = b_11 == 1U;
                        if(_S1563)
                        {
                            _S1482 = (_S1353.x) == (_S1353.y);
                        }
                        else
                        {
                            _S1482 = false;
                        }
                    }
                }
                else
                {
                    _S1482 = false;
                }
            }
            bool _S1564 = !_S1358;
            if(_S1564)
            {
                _S1483 = b_11 == 1U;
            }
            else
            {
                _S1483 = false;
            }
            if(_S1483)
            {
                straight_0 = (_S1350.material.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S1484 = _S1564;
            }
            else
            {
                _S1484 = false;
            }
            if(_S1484)
            {
                _S1485 = b_11 == 1U;
            }
            else
            {
                _S1485 = false;
            }
            if(_S1485)
            {
                _S1486 = (_S1353.x) == (_S1353.y);
            }
            else
            {
                _S1486 = false;
            }
            BSDFMaterial _S1565 = _S1350.material;
            bool _S1566 = isTranslucent_0(&_S1565);
            if(_S1566)
            {
                _S1487 = _S1560;
            }
            else
            {
                _S1487 = false;
            }
            if(_S1487)
            {
                _S1488 = (dot_0(throughput_8, surface_12.geometry_n)) < 0.0f;
            }
            else
            {
                _S1488 = false;
            }
            if(nee_0)
            {
                _S1489 = !_S1482;
            }
            else
            {
                _S1489 = false;
            }
            if(_S1489)
            {
                _S1490 = !wrong_side_0;
            }
            else
            {
                _S1490 = false;
            }
            if(_S1490)
            {
                float _S1567 = (&lobe_5)->pdf;
                float3  _S1568 = (&ray_2)->origin;
                float3  _S1569 = _slang_select(_S1363, _S1175,_S1351.smooth_n);
                float3  _S1570 = (&ray_2)->origin;
                FKSurface _S1571 = surface_12;
                float3  _S1572 = - _S1351.smooth_n;
                float3  _S1573 = _slang_select(_S1488, _S1572,_S1351.smooth_n);
                NEEVertex _S1574 = NEEVertex_x24init_0(false, _S1567, _S1568, _S1569, _S1570 + make_float3 (_S1571.geometry_offset) * _S1573);
                nee_vertex_0 = _S1574;
            }
            else
            {
                if(_S1358)
                {
                    _S1491 = true;
                }
                else
                {
                    bool _S1575 = b_11 != 1U;
                    if(_S1575)
                    {
                        _S1491 = true;
                    }
                    else
                    {
                        _S1491 = (_S1353.x) != (_S1353.y);
                    }
                }
                if(_S1491)
                {
                    (&nee_vertex_0)->none = true;
                }
            }
            bool _S1576 = withinInverseFootprint((&lobe_5)->pdf, _S1481, (&prev_0)->cos, (&hit_4)->distance, threshold_2);
            bool _S1577 = roughLobe((&lobe_5)->pdf, _S1481, _S1350.material.roughness);
            if(_S1390)
            {
                bool _S1578 = !_S1576;
                if(_S1578)
                {
                    return _S1176;
                }
                bool _S1579 = _S1181 != 1U;
                if(_S1579)
                {
                    _S1491 = _S1181 != 2U;
                }
                else
                {
                    _S1491 = false;
                }
                if(_S1491)
                {
                    float _S1580 = (&lobe_5)->pdf;
                    float _S1581 = _slang_select(nee_0, _S1580,0.0f);
                    float _S1582 = escapeWeight_0(_S1581, _S1499);
                    if(_S1398)
                    {
                        passes_0 = _S1187;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1583 = _slang_select(passes_0, _S1582,1.0f);
                    return Shift_x24init_0(throughput_6 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf)) * r_8->radiance * make_float3 (_S1583) / make_float3 (r_8->jac), density_4 * (&lobe_5)->pdf / r_8->jac);
                }
                float3  _S1584 = throughput_6 * make_float3 ((&lobe_5)->pdf);
                float _S1585 = density_4 * (&lobe_5)->pdf;
                throughput_9 = _S1584;
                density_6 = _S1585;
            }
            else
            {
                throughput_9 = throughput_6;
                density_6 = density_4;
            }
            uint _S1586 = (fcptLayers((hit_4)));
            bool _S1587 = b_11 == 1U;
            bool _S1588 = passesLayer_0(_S1586, _S1587, passes_0);
            if(viewed_1)
            {
                _S1491 = _S1588;
            }
            else
            {
                _S1491 = false;
            }
            if(_S1491)
            {
                return _S1176;
            }
            if(replay_2)
            {
                _S1492 = b_8 <= _S1191;
            }
            else
            {
                _S1492 = false;
            }
            if(_S1492)
            {
                _S1493 = _S1349;
            }
            else
            {
                _S1493 = false;
            }
            if(_S1493)
            {
                _S1494 = _S1576;
            }
            else
            {
                _S1494 = false;
            }
            if(_S1494)
            {
                _S1495 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S1495 = !_S1577;
                }
                else
                {
                    _S1495 = false;
                }
            }
            if(_S1495)
            {
                return _S1176;
            }
            if(viewed_1)
            {
                float3  _S1589 = throughput_9 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf));
                float _S1590 = (&lobe_5)->pdf;
                throughput_10 = _S1589;
                sky_pdf_2 = _S1590;
            }
            else
            {
                float3  _S1591 = throughput_9 * max_0((&lobe_5)->throughput, _S1175);
                throughput_10 = _S1591;
                sky_pdf_2 = density_6;
            }
            bool _S1592;
            if(_S1367)
            {
                _S1592 = !_S1381;
            }
            else
            {
                _S1592 = false;
            }
            bool _S1593;
            if(_S1592)
            {
                _S1593 = _S1349;
            }
            else
            {
                _S1593 = false;
            }
            bool _S1594;
            if(_S1593)
            {
                _S1594 = _S1576;
            }
            else
            {
                _S1594 = false;
            }
            if(_S1594)
            {
                chain_0 = here_0;
                uint _S1595 = insertBits_0((&chain_0)->path, b_11, 18U, 3U);
                uint _S1596 = _slang_select(nee_0, 1U,0U);
                uint _S1597 = insertBits_0(_S1595, _S1596, 21U, 1U);
                (&chain_0)->path = _S1597;
                float _S1598 = (&chain_0)->jac * (&lobe_5)->pdf;
                (&chain_0)->jac = _S1598;
                (&chain_0)->dir = throughput_8;
                chain_throughput_1 = throughput_10;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            FKSurface _S1599 = surface_12;
            Vertex _S1600 = Vertex_x24init_0(_S1577, b_11, (&lobe_5)->pdf, (F32_abs((dot_0(surface_12.geometry_n, throughput_8)))), is_inside_7);
            prev_0 = _S1600;
            float _S1601 = (&lobe_5)->pdf;
            bool _S1602;
            if(_S1587)
            {
                _S1602 = (_S1353.x) == (_S1353.y);
            }
            else
            {
                _S1602 = false;
            }
            float sky_pdf_3 = _slang_select(_S1602, sky_pdf_0,_S1601);
            float _S1603 = _slang_select(_S1358, 0.0f,sky_pdf_3);
            float _S1604 = widened_0(spread_2, (&lobe_5)->pdf, _S1482);
            bool _S1605;
            if(refracted_4)
            {
                _S1605 = !_S1488;
            }
            else
            {
                _S1605 = false;
            }
            bool is_inside_8;
            if(_S1605)
            {
                bool _S1606 = !is_inside_7;
                is_inside_8 = _S1606;
            }
            else
            {
                is_inside_8 = is_inside_7;
            }
            FKSurface _S1607 = surface_12;
            bool _S1608 = boundsVolume_0(&_S1607);
            bool _S1609;
            if(_S1608)
            {
                _S1609 = !_S1588;
            }
            else
            {
                _S1609 = false;
            }
            if(_S1609)
            {
                FKSurface faced_2 = surface_12;
                float3  _S1610 = - _S1599.geometry_n;
                float3  _S1611 = _slang_select(turned_1, _S1610,_S1599.geometry_n);
                (&faced_2)->geometry_n = _S1611;
                FKMedium _S1612 = Medium_x24init_0(scatter_in_0, extinction_in_0, g_in_0);
                FKMedium _S1613 = (fcptOutsideMedium((hit_4)));
                FKSurface _S1614 = faced_2;
                FKMedium _S1615 = _S1612;
                FKMedium _S1616 = _S1613;
                MediumSides _S1617 = mediumSides_0(&_S1614, &_S1615, filling_2, (&ray_2)->unit_direction, &_S1616);
                bool _S1618 = leavesInFront_0((&faced_2)->geometry_n, throughput_8, _S1599.geometry_n);
                float3  _S1619 = _slang_select(_S1618, _S1617.front.scatter,_S1617.behind.scatter);
                scatter_in_0 = _S1619;
                float3  _S1620 = _slang_select(_S1618, _S1617.front.extinction,_S1617.behind.extinction);
                extinction_in_0 = _S1620;
                float _S1621 = _slang_select(_S1618, _S1617.front.g,_S1617.behind.g);
                g_in_0 = _S1621;
                uint _S1622 = _S1617.fillings.x;
                uint _S1623 = _S1617.fillings.y;
                uint _S1624 = _slang_select(_S1618, _S1623,_S1622);
                bool _S1625 = (fcptVaryingUsed());
                uint _S1626 = _slang_select(_S1625, _S1624,4294967295U);
                filling_2 = _S1626;
            }
            (&ray_2)->unit_direction = throughput_8;
            bool _S1627 = !_S1588;
            if(_S1627)
            {
                FKSurface _S1628 = surface_12;
                float _S1629 = _slang_select(straight_0, 0.0f,_S1628.geometry_offset);
                float3  _S1630 = - _S1351.smooth_n;
                bool _S1631 = is_inside_8 != _S1488;
                float3  _S1632 = _slang_select(_S1631, _S1630,_S1351.smooth_n);
                float3  _S1633 = (&ray_2)->origin + make_float3 (_S1629) * _S1632;
                (&ray_2)->origin = _S1633;
            }
            throughput_9 = throughput_10;
            chain_throughput_0 = chain_throughput_1;
            density_6 = sky_pdf_2;
            passes_0 = _S1588;
            viewed_1 = _S1486;
            sky_pdf_2 = _S1603;
            spread_5 = _S1604;
            reconnection_0 = reconnection_1;
            is_inside_6 = is_inside_8;
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
            is_inside_6 = is_inside_7;
        }
        float density_7;
        if(_S1367)
        {
            if(_S1317)
            {
                float3  _S1634 = throughput_9 * emission_1;
                Reservoir candidate_8 = chain_0;
                uint _S1635 = extractBits_0((&chain_0)->path, 10U, 2U);
                bool _S1636 = _S1635 == 1U;
                if(_S1636)
                {
                    float3  _S1637 = safeDivide(_S1634, chain_throughput_0);
                    (&candidate_8)->radiance = _S1637;
                }
                Reservoir _S1638 = withEnd(candidate_8, 2U, b_8, _S1634);
                offer(sel_7, _S1638, _S1634 * make_float3 (scale_3) / make_float3 (density_6));
            }
            if(_S1317)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = scatter_2;
            }
            if(refracted_4)
            {
                float _S1639 = survivalProbability(throughput_9, density_6);
                density_7 = _S1639;
            }
            else
            {
                density_7 = 1.0f;
            }
            uint _S1640 = stream(_S1203, b_8 + 128U);
            Random _S1641 = pcg(_S1640);
            bool _S1642 = density_7 < (_S1641.value);
            if(_S1642)
            {
                wrong_side_0 = true;
            }
            else
            {
                uint _S1643 = (fcptMaxBounces());
                wrong_side_0 = b_8 >= _S1643;
            }
            if(wrong_side_0)
            {
                break;
            }
            float _S1644 = density_6 * density_7;
            density_7 = _S1644;
        }
        else
        {
            density_7 = density_6;
        }
        uint _S1645 = layer_0 ^ 1U;
        uint _S1646 = _slang_select(passes_0, _S1645,0U);
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
            uint _S1647 = b_11 + 1U;
            b_8 = _S1647;
            layer_0 = _S1646;
            continue;
        }
        FKRay _S1648 = ray_2;
        float _S1649 = distance_1(reconnection_0, (&ray_2)->origin) * 1.0010000467300415f;
        if(replay_2)
        {
            refracted_4 = _S1391;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            wrong_side_0 = _S1180 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S1650 = _slang_select(wrong_side_0, _S1649,4.294967296e+09f);
        bool _S1651 = !_S1358;
        if(straight_0)
        {
            _S1436 = true;
        }
        else
        {
            _S1436 = _S1358;
        }
        FKHit _S1652;
        if(_S1436)
        {
            _S1652 = hit_4;
        }
        else
        {
            _S1652 = _S1408;
        }
        FKHit _S1653 = (fcptTraverseInstanceBVH((_S1648), (_S1325), (_S1650), (_S1651), (_S1652), (viewed_1)));
        hit_4 = _S1653;
        if(replay_2)
        {
            _S1437 = _S1391;
        }
        else
        {
            _S1437 = false;
        }
        if(_S1437)
        {
            _S1481 = _S1180 == 1U;
        }
        else
        {
            _S1481 = false;
        }
        if(_S1481)
        {
            _S1482 = ((&hit_4)->instance_index) == (_S1192.instance_index);
        }
        else
        {
            _S1482 = false;
        }
        if(_S1482)
        {
            _S1483 = ((&hit_4)->triangle_index) == (_S1192.triangle_index);
        }
        else
        {
            _S1483 = false;
        }
        if(_S1483)
        {
            (&hit_4)->uv = _S1192.uv;
            float _S1654 = distance_1(reconnection_0, (&ray_2)->origin);
            (&hit_4)->distance = _S1654;
        }
        if(replay_2)
        {
            _S1484 = _S1391;
        }
        else
        {
            _S1484 = false;
        }
        if(_S1484)
        {
            _S1485 = _S1180 == 3U;
        }
        else
        {
            _S1485 = false;
        }
        if(_S1485)
        {
            _S1486 = ((&hit_4)->instance_index) != 4294967295U;
        }
        else
        {
            _S1486 = false;
        }
        if(_S1486)
        {
            return _S1176;
        }
        Reservoir _S1655 = chain_0;
        uint _S1656 = filling_2;
        for(;;)
        {
            bool _S1657 = (fcptVaryingUsed());
            if(_S1657)
            {
                _S1487 = _S1656 != 4294967295U;
            }
            else
            {
                _S1487 = false;
            }
            float _S1658;
            if(_S1487)
            {
                float _S1659 = (fcptMajorant((_S1656)));
                _S1658 = _S1659;
            }
            else
            {
                _S1658 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
            }
            if(replay_2)
            {
                _S1488 = _S1391;
            }
            else
            {
                _S1488 = false;
            }
            if(_S1488)
            {
                _S1489 = _S1180 == 1U;
            }
            else
            {
                _S1489 = false;
            }
            if(_S1489)
            {
                _S1490 = _S1658 > 0.0f;
            }
            else
            {
                _S1490 = false;
            }
            if(_S1490)
            {
                ended_0 = _S1176;
                sky_pdf_1 = sky_pdf_2;
                spread_3 = spread_5;
                width_4 = width_3;
                density_3 = density_7;
                throughput_10 = throughput_9;
                b_11 = b_8;
                _S1491 = true;
                break;
            }
            bool _S1660 = (&prev_0)->rough;
            if(_S1660)
            {
                _S1491 = !(_S1658 > 0.0f);
            }
            else
            {
                _S1491 = false;
            }
            (&prev_0)->rough = _S1491;
            uint _S1661 = b_8 + 320U;
            bool _S1662 = b_8 == 4294967295U;
            uint _S1663 = _slang_select(_S1662, 384U,_S1661);
            uint _S1664 = stream(_S1203, _S1663);
            uint tracking_1 = _S1664;
            weight_1 = throughput_3;
            glowed_0 = _S1175;
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
                    _S1174 = int(2);
                    break;
                }
                uint _S1665 = b_11 + 320U;
                bool _S1666 = b_11 == 4294967295U;
                uint _S1667 = _slang_select(_S1666, 384U,_S1665);
                uint _S1668 = stream(_S1203, _S1667);
                Random _S1669 = pcg(_S1668);
                float _S1670 = freeFlight_0(_S1669.value, _S1658);
                if(_S1487)
                {
                    float3  _S1671 = (&ray_2)->origin;
                    float3  _S1672 = (&ray_2)->unit_direction;
                    float _S1673 = (&hit_4)->distance;
                    uint _S1674 = _slang_select(_S1666, 0U,b_11);
                    uint _S1675 = (&prev_0)->lobe;
                    uint _S1676 = _slang_select(_S1666, 3U,_S1675);
                    float _S1677 = (fcptTrackMedium((_S1656), (_S1671), (_S1672), (_S1673), (&tracking_1), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1674), (_S1676), (_S1666)));
                    spread_4 = _S1677;
                }
                else
                {
                    spread_4 = _S1670;
                }
                bool _S1678 = !(spread_4 < ((&hit_4)->distance));
                if(_S1678)
                {
                    _S1174 = int(2);
                    break;
                }
                if(_S1487)
                {
                    _S1492 = _S1367;
                }
                else
                {
                    _S1492 = false;
                }
                if(_S1492)
                {
                    float3  _S1679 = throughput_10 * glowed_0 / make_float3 (density_3);
                    float3  _S1680 = sel_7->glow + _S1679;
                    sel_7->glow = _S1680;
                }
                else
                {
                }
                glowed_0 = _S1175;
                uint b_12 = b_11 + 1U;
                float3  _S1681 = (&ray_2)->origin + make_float3 (spread_4) * (&ray_2)->unit_direction;
                (&ray_2)->origin = _S1681;
                float3  _S1682 = flightWeight_0(scatter_in_0, extinction_in_0, _S1658, spread_4, true);
                float3  _S1683 = weight_1;
                float3  _S1684 = _slang_select(_S1487, _S1683,_S1682);
                float3  throughput_11 = throughput_10 * _S1684;
                uint _S1685 = stream(_S1203, b_12 + 320U);
                tracking_1 = _S1685;
                weight_1 = throughput_3;
                float width_7 = width_4 + spread_3 * spread_4;
                float _S1686 = spread_3 + 3.14159274101257324f;
                bool _S1687 = scatterSampled_0(replay_2, b_12, _S1191, _S1487);
                TreeSample light_4;
                if(_S1687)
                {
                    float3  _S1688 = (&ray_2)->origin;
                    float3  _S1689 = (&ray_2)->unit_direction;
                    float3  _S1690 = (&ray_2)->unit_direction;
                    uint _S1691 = stream(_S1203, b_12 + 64U);
                    float3  _S1692 = extinction_in_0;
                    float3  _S1693 = extinction_in_0;
                    uint2  _S1694 = make_uint2 (_S1656);
                    float3  _S1695 = (&ray_2)->unit_direction;
                    uint _S1696 = arrivalLobe_0(b_12, (&prev_0)->lobe);
                    FKHit _S1697 = _S1408;
                    ShadowContext _S1698 = ShadowContext_x24init_0(_S1692, _S1693, _S1694, _S1695, b_12, _S1696, false, spread_4, width_7, &_S1697, false);
                    ShadowContext _S1699 = _S1698;
                    TreeSample _S1700 = sampleLightTree_0(_S1688, _S1689, _S1690, 0.0f, true, _S1691, &_S1699);
                    light_4 = _S1700;
                }
                else
                {
                    light_4 = _S1405;
                }
                float _S1701 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_4.dir));
                uint _S1702 = (fcptMaxBounces());
                bool _S1703 = b_12 < _S1702;
                if(_S1703)
                {
                    _S1493 = (light_4.density) > 0.0f;
                }
                else
                {
                    _S1493 = false;
                }
                float _S1704 = _slang_select(_S1493, _S1701,0.0f);
                float3  _S1705 = throughput_11 * light_4.radiance;
                float _S1706 = powerHeuristic(light_4.density, _S1704);
                float3  _S1707 = _S1705 * make_float3 (_S1701 * _S1706);
                float3  _S1708 = _slang_select(_S1687, _S1707,_S1175);
                if(replay_2)
                {
                    _S1494 = b_12 == _S1191;
                }
                else
                {
                    _S1494 = false;
                }
                if(_S1494)
                {
                    bool _S1709 = _S1180 == 2U;
                    if(_S1709)
                    {
                        float _S1710 = rgb_to_greyscale(_S1708);
                        _S1495 = _S1710 > 0.0f;
                    }
                    else
                    {
                        _S1495 = false;
                    }
                    if(_S1495)
                    {
                        Shift _S1711 = Shift_x24init_0(_S1708, 1.0f);
                        _S1174 = int(1);
                        ended_0 = _S1711;
                        spread_4 = _S1686;
                        width_5 = width_7;
                        throughput_8 = throughput_11;
                        b_9 = b_12;
                        break;
                    }
                    _S1174 = int(1);
                    ended_0 = _S1176;
                    spread_4 = _S1686;
                    width_5 = width_7;
                    throughput_8 = throughput_11;
                    b_9 = b_12;
                    break;
                }
                if(_S1367)
                {
                    Reservoir candidate_9 = _S1655;
                    uint _S1712 = extractBits_0(_S1655.path, 10U, 2U);
                    bool _S1713 = _S1712 == 1U;
                    if(_S1713)
                    {
                        float3  _S1714 = safeDivide(_S1708, chain_throughput_0);
                        (&candidate_9)->radiance = _S1714;
                    }
                    else
                    {
                        uint _S1715 = insertBits_0(0U, b_12 + 1U, 5U, 5U);
                        uint _S1716 = insertBits_0(_S1715, 2U, 10U, 2U);
                        (&candidate_9)->path = _S1716;
                    }
                    Reservoir _S1717 = withEnd(candidate_9, 0U, b_12, _S1708);
                    offer(sel_7, _S1717, _S1708 * make_float3 (scale_3) / make_float3 (density_3));
                    float _S1718 = survivalProbability(throughput_11, density_3);
                    uint _S1719 = stream(_S1203, b_12 + 128U);
                    Random _S1720 = pcg(_S1719);
                    bool _S1721 = _S1718 < (_S1720.value);
                    if(_S1721)
                    {
                        _S1495 = true;
                    }
                    else
                    {
                        uint _S1722 = (fcptMaxBounces());
                        _S1495 = b_12 >= _S1722;
                    }
                    if(_S1495)
                    {
                        _S1174 = int(1);
                        ended_0 = _S1176;
                        spread_4 = _S1686;
                        width_5 = width_7;
                        throughput_8 = throughput_11;
                        b_9 = b_12;
                        break;
                    }
                    float _S1723 = density_3 * _S1718;
                    density_3 = _S1723;
                }
                else
                {
                }
                float phase_pdf_1 = 0.0f;
                uint _S1724 = stream(_S1203, b_12);
                float3  _S1725 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1724, &phase_pdf_1);
                (&ray_2)->unit_direction = _S1725;
                NEEVertex _S1726 = NEEVertex_x24init_0(false, phase_pdf_1, (&ray_2)->origin, _S1175, (&ray_2)->origin);
                nee_vertex_0 = _S1726;
                Vertex _S1727 = scatteredVertex_0(is_inside_6);
                prev_0 = _S1727;
                float _S1728 = (&prev_0)->pdf;
                FKRay _S1729 = ray_2;
                FKHit _S1730 = (fcptTraverseInstanceBVH((_S1729), (true), (4.294967296e+09f), (false), (_S1408), (false)));
                hit_4 = _S1730;
                b_11 = b_12;
                throughput_10 = throughput_11;
                spread_3 = _S1686;
                width_4 = width_7;
                sky_pdf_1 = _S1728;
            }
            if(_S1174 != int(2))
            {
                spread_3 = spread_4;
                width_4 = width_5;
                throughput_10 = throughput_8;
                b_11 = b_9;
                _S1491 = true;
                break;
            }
            ended_0 = _S1176;
            _S1491 = false;
            break;
        }
        if(_S1491)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S1492 = b_11 == b_8;
        }
        else
        {
            _S1492 = false;
        }
        bool _S1731 = ((&hit_4)->instance_index) == 4294967295U;
        if(_S1731)
        {
            bool _S1732 = !(&nee_vertex_0)->none;
            float _S1733 = _slang_select(_S1732, sky_pdf_1,0.0f);
            float _S1734 = escapeWeight_0(_S1733, (&ray_2)->unit_direction);
            float3  _S1735 = environment_0((&ray_2)->unit_direction, b_11, (&prev_0)->lobe);
            float3  _S1736 = throughput_10 * _S1735;
            if(replay_2)
            {
                bool _S1737 = b_11 == _S1191;
                if(_S1737)
                {
                    passes_0 = _S1180 == 3U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(_S1736 * make_float3 (_S1734) / make_float3 (r_8->jac), density_3 / r_8->jac);
                }
                if(_S1190)
                {
                    passes_0 = _S1187;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = b_11 == _S1178;
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
                    return Shift_x24init_0(_S1736 * make_float3 (_S1734), 1.0f);
                }
                return _S1176;
            }
            Reservoir candidate_10 = chain_0;
            uint _S1738 = extractBits_0((&chain_0)->path, 10U, 2U);
            bool _S1739 = _S1738 == 1U;
            if(_S1739)
            {
                uint _S1740 = extractBits_0((&chain_0)->path, 5U, 5U);
                bool _S1741 = _S1740 == b_11;
                float _S1742 = _slang_select(_S1741, 1.0f,_S1734);
                float3  _S1743 = safeDivide(_S1736 * make_float3 (_S1742), chain_throughput_0);
                (&candidate_10)->radiance = _S1743;
            }
            else
            {
                bool _S1744 = (&prev_0)->rough;
                if(_S1744)
                {
                    uint _S1745 = insertBits_0(0U, b_11 + 1U, 5U, 5U);
                    uint _S1746 = insertBits_0(_S1745, 3U, 10U, 2U);
                    uint _S1747 = insertBits_0(_S1746, (&prev_0)->lobe, 15U, 3U);
                    bool _S1748 = (&prev_0)->inside;
                    uint _S1749 = _slang_select(_S1748, 1U,0U);
                    uint _S1750 = insertBits_0(_S1747, _S1749, 22U, 1U);
                    (&candidate_10)->path = _S1750;
                    (&candidate_10)->jac = (&prev_0)->pdf;
                    (&candidate_10)->dir = (&ray_2)->unit_direction;
                }
            }
            float3  _S1751 = _S1736 * make_float3 (_S1734);
            Reservoir _S1752 = withEnd(candidate_10, 3U, b_11, _S1751);
            offer(sel_7, _S1752, _S1751 * make_float3 (scale_3) / make_float3 (density_3));
            break;
        }
        float3  _S1753 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
        (&ray_2)->origin = _S1753;
        bool _S1754 = (fcptVaryingUsed());
        if(_S1754)
        {
            _S1493 = filling_2 != 4294967295U;
        }
        else
        {
            _S1493 = false;
        }
        if(_S1493)
        {
            if(_S1367)
            {
                float3  _S1755 = throughput_10 * glowed_0 / make_float3 (density_3);
                float3  _S1756 = sel_7->glow + _S1755;
                sel_7->glow = _S1756;
            }
            float3  _S1757 = throughput_10 * weight_1;
            throughput_8 = _S1757;
        }
        else
        {
            float3  _S1758 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
            float3  _S1759 = throughput_10 * _S1758;
            throughput_8 = _S1759;
        }
        float _S1760 = width_4 + spread_3 * (&hit_4)->distance;
        viewed_0 = _S1492;
        width_3 = _S1760;
        throughput_2 = throughput_8;
        density_2 = density_3;
        sky_pdf_0 = sky_pdf_1;
        spread_2 = spread_3;
        uint _S1647 = b_11 + 1U;
        b_8 = _S1647;
        layer_0 = _S1646;
    }
    return _S1176;
}

static __device__ Shift shift_0(Domain * dom_8, Reservoir * r_9)
{
    Selection _S1761 = (Selection{});
    Selection sel_8 = _S1761;
    bool _S1762 = (r_9->w) <= 0.0f;
    if(_S1762)
    {
        return Shift_x24init_0(make_float3 (0.0f), 0.0f);
    }
    Shift _S1763 = walk_0(dom_8, r_9, true, 0.0f, &sel_8);
    return _S1763;
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

__device__ Random normal_distribution(uint state_4)
{
    Random _S1764 = pcg(state_4);
    Random _S1765 = pcg(_S1764.state);
    float _S1766 = 6.28318548202514648f * _S1764.value;
    float _S1767 = (F32_sqrt((-2.0f * clamp_1((F32_log((_S1765.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S1765.state, _S1767 * (F32_cos((_S1766))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_5, float3  value_2)
{
    RandomSphere _S1768;
    (&_S1768)->state = state_5;
    (&_S1768)->value = value_2;
    return _S1768;
}

__device__ RandomSphere random_sphere(uint state_6)
{
    Random _S1769 = normal_distribution(state_6);
    Random _S1770 = normal_distribution(_S1769.state);
    Random _S1771 = normal_distribution(_S1770.state);
    float3  _S1772 = make_float3 (_S1769.value, _S1770.value, _S1771.value);
    float3  _S1773 = ((((_S1772)) * make_float3(rnorm3df(((_S1772)).x, ((_S1772)).y, ((_S1772)).z))));
    return RandomSphere_x24init_0(_S1771.state, _S1773);
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_12)
{
    float3  _S1774 = p1_0 - p0_0;
    float3  _S1775 = p2_0 - p0_0;
    float2  _S1776 = uv1_0 - uv0_0;
    float2  _S1777 = uv2_0 - uv0_0;
    float _S1778 = _S1776.x;
    float _S1779 = _S1777.y;
    float _S1780 = _S1776.y;
    float _S1781 = _S1777.x;
    float _S1782 = _S1778 * _S1779 - _S1780 * _S1781;
    float _S1783 = 1.0f / _S1782;
    float3  t_21 = (_S1774 * make_float3 (_S1779) - _S1775 * make_float3 (_S1780)) * make_float3 (_S1783);
    float3  _S1784 = (_S1775 * make_float3 (_S1778) - _S1774 * make_float3 (_S1781)) * make_float3 (_S1783);
    float3  _S1785 = t_21 - n_12 * make_float3 (dot_0(n_12, t_21));
    float3  t_22 = ((((_S1785)) * make_float3(rnorm3df(((_S1785)).x, ((_S1785)).y, ((_S1785)).z))));
    bool _S1786 = (dot_0(cross_0(n_12, t_22), _S1784)) > 0.0f;
    float3  t_23;
    if(_S1786)
    {
        float3  _S1787 = negate_0(t_22);
        t_23 = _S1787;
    }
    else
    {
        t_23 = t_22;
    }
    float3  _S1788 = cross_0(n_12, t_23);
    return makeMatrix<float, 3, 3> (t_23, _S1788, n_12);
}

__device__ float3  tangentToWorldNormalMap(float3  v_4, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_4, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_5, float3  uvw_0, float3  position_0)
{
    float3  _S1789 = t1_0 - t0_0;
    float3  _S1790 = t2_2 - t0_0;
    float3  _S1791 = t2_2 - t1_0;
    float _S1792 = (F32_min((length_0(_S1789)), ((F32_min((length_0(_S1790)), (length_0(_S1791)))))));
    float3  _S1793 = make_float3 (distance_1(position_0, t0_0), distance_1(position_0, t1_0), distance_1(position_0, t2_2));
    float3  _S1794 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S1795 = dot_0(geometry_n_5, _S1794);
    float3  _S1796 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S1797 = dot_0(geometry_n_5, _S1796);
    float3  _S1798 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S1799 = acos_0(abs_0(make_float3 (_S1795, _S1797, dot_0(geometry_n_5, _S1798))));
    float3  _S1800 = clamp_2(tan_0(_S1799), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_1(dot_0(_S1793 * _S1800, uvw_0), 0.0f, _S1792 * 0.125f);
}

__device__ float3  straightThrough(float3  dir_15, float3  n_13, BSDFMaterial material_22)
{
    float3  _S1801 = negate_0(dir_15);
    float _S1802 = sign_0(dot_0(n_13, _S1801));
    float3  _S1803 = n_13 * make_float3 (_S1802);
    AnisotropicFrame _S1804 = anisotropicFrame(material_22, _S1803);
    bool _S1805 = (_S1804.alphas.x) > 0.0f;
    if(_S1805)
    {
        float _S1806 = material_22.transmission * (1.0f - material_22.metallic);
        float3  _S1807 = negate_0(_S1803);
        float3  _S1808 = anisotropicLocal(dir_15, _S1804.tangent, _S1807);
        float _S1809 = anisotropicG1(_S1808, _S1804.alphas);
        return make_float3 (_S1806 * _S1809) * material_22.albedo;
    }
    float _S1810 = material_22.transmission * (1.0f - material_22.metallic);
    float _S1811 = material_22.roughness;
    float _S1812 = smithG1(_S1811 * _S1811, (F32_abs((dot_0(n_13, dir_15)))));
    return make_float3 (_S1810 * _S1812) * material_22.albedo;
}

__device__ float hairRow(float3  in_dir_11, float3  t_24, float3  out_dir_3, uint p_13, float w_2, float alpha_20, uint nt_0)
{
    uint _S1813 = p_13 % 4U;
    float _S1814 = w_2 * HAIR_WIDTHS_0[_S1813];
    float _S1815 = (F32_asin((clamp_1(dot_0(out_dir_3, t_24), -1.0f, 1.0f)))) - (F32_asin((clamp_1(dot_0(in_dir_11, t_24), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S1813] * alpha_20;
    return ((F32_asinh((_S1815 / _S1814))) / (F32_asinh((3.14159274101257324f / _S1814))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_12, float3  t_25, float3  out_dir_4, uint np_0)
{
    float3  _S1816 = worldToTangent(out_dir_4, t_25);
    float3  _S1817 = worldToTangent(in_dir_12, t_25);
    return (F32_frac((((F32_atan2((_S1816.z), (_S1816.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S1817.z), (1.17549435082228751e-38f - _S1817.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_13, float3  t_26, uint p_14, float row_0, float column_0, float w_3, float alpha_21, uint nt_1, uint np_1)
{
    float3  _S1818 = worldToTangent(in_dir_13, t_26);
    uint _S1819 = p_14 % 4U;
    float _S1820 = w_3 * HAIR_WIDTHS_0[_S1819];
    float _S1821 = (F32_asin((clamp_1(dot_0(in_dir_13, t_26), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S1819] * alpha_21 + _S1820 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S1820))))));
    float _S1822 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S1818.z), (1.17549435082228751e-38f - _S1818.x)));
    float _S1823 = (F32_cos((_S1821)));
    float3  _S1824 = tangentToWorld(make_float3 (_S1823 * (F32_cos((_S1822))), (F32_sin((_S1821))), _S1823 * (F32_sin((_S1822)))), t_26);
    return _S1824;
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_14, BSDFMaterial material_23, float coverage_1)
{
    float3  _S1825;
    if((material_23.ior) == 1.0f)
    {
        float3  _S1826 = straightThrough(toward_1, n_14, material_23);
        _S1825 = _S1826;
    }
    else
    {
        _S1825 = make_float3 (0.0f);
    }
    return _S1825 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ Shift walk_hook(Domain dom_9, Reservoir r_10, bool replay_3, float scale_4, Selection * sel_9)
{
    Domain _S1827 = dom_9;
    Reservoir _S1828 = r_10;
    Shift _S1829 = walk_0(&_S1827, &_S1828, replay_3, scale_4, sel_9);
    return _S1829;
}

__device__ Shift shift_hook(Domain dom_10, Reservoir r_11)
{
    Domain _S1830 = dom_10;
    Reservoir _S1831 = r_11;
    Shift _S1832 = shift_0(&_S1830, &_S1831);
    return _S1832;
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
