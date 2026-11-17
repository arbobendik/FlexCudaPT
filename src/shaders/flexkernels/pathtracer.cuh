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
    float p_sheen_velvet;
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

__device__ float anisotropicG1(float3  w_1, float2  alphas_1)
{
    float _S376 = (F32_max((w_1.z), (0.0f)));
    return 2.0f * _S376 / (_S376 + length_0(make_float3 (alphas_1.x * w_1.x, alphas_1.y * w_1.y, _S376)));
}

__device__ float anisotropicD(float3  h_0, float2  alphas_2)
{
    float _S377 = alphas_2.x;
    float _S378 = h_0.x / _S377;
    float _S379 = alphas_2.y;
    float _S380 = h_0.y / _S379;
    float _S381 = h_0.z;
    float _S382 = _S378 * _S378 + _S380 * _S380 + _S381 * _S381;
    return 1.0f / (F32_max((3.14159274101257324f * _S377 * _S379 * _S382 * _S382), (1.17549435082228751e-38f)));
}

static __device__ BSDFLobes BSDFLobes_x24init_0(float v_dot_h_0, float n_dot_h_0, float3  refracted_1, float3  F_0, float F_greyscale_0, float reflect_weight_0, float3  diffuse_weight_0, float3  refract_weight_0, float p_diffuse_0, float p_reflect_0, float p_refract_0, float translucent_share_0, float3  sheen_0, float p_sheen_velvet_0, float3  view_0, float3  tangent_1, float2  alphas_3, float visible_0, float toon_share_0)
{
    BSDFLobes _S383;
    (&_S383)->v_dot_h = v_dot_h_0;
    (&_S383)->n_dot_h = n_dot_h_0;
    (&_S383)->refracted = refracted_1;
    (&_S383)->F = F_0;
    (&_S383)->F_greyscale = F_greyscale_0;
    (&_S383)->reflect_weight = reflect_weight_0;
    (&_S383)->diffuse_weight = diffuse_weight_0;
    (&_S383)->refract_weight = refract_weight_0;
    (&_S383)->p_diffuse = p_diffuse_0;
    (&_S383)->p_reflect = p_reflect_0;
    (&_S383)->p_refract = p_refract_0;
    (&_S383)->translucent_share = translucent_share_0;
    (&_S383)->sheen = sheen_0;
    (&_S383)->p_sheen_velvet = p_sheen_velvet_0;
    (&_S383)->view = view_0;
    (&_S383)->tangent = tangent_1;
    (&_S383)->alphas = alphas_3;
    (&_S383)->visible = visible_0;
    (&_S383)->toon_share = toon_share_0;
    return _S383;
}

__device__ __forceinline__ BSDFLobes bsdfLobes(float3  in_dir_0, float3  v_3, float3  n_i_2, float3  ggx_n_0, BSDFMaterial material_1, float eta_i_1, float eta_o_1, AnisotropicFrame frame_1)
{
    float _S384 = dot_0(ggx_n_0, v_3);
    float _S385 = dot_0(n_i_2, ggx_n_0);
    float _S386 = eta_i_1 / eta_o_1;
    float3  _S387 = refract_0(in_dir_0, ggx_n_0, _S386);
    float3  _S388 = ((((_S387)) * make_float3(rnorm3df(((_S387)).x, ((_S387)).y, ((_S387)).z))));
    float _S389 = (F32_min(((F32_sqrt((material_1.specular_level))) * (F32_abs((eta_i_1 - eta_o_1))) / (eta_i_1 + eta_o_1)), (0.9999847412109375f)));
    float _S390 = _S389 * _S389;
    float _S391 = (1.0f + _S389) / (1.0f - _S389);
    float _S392 = (F32_abs((_S384)));
    bool _S393 = eta_i_1 > eta_o_1;
    float sheen_component_0;
    if(_S393)
    {
        sheen_component_0 = _S391;
    }
    else
    {
        sheen_component_0 = 1.0f;
    }
    float toon_component_0;
    if(_S393)
    {
        toon_component_0 = 1.0f;
    }
    else
    {
        toon_component_0 = _S391;
    }
    float _S394 = fresnel(_S392, sheen_component_0, toon_component_0);
    bool _S395 = (eta_i_1 * eta_i_1 * (1.0f - _S384 * _S384)) >= (eta_o_1 * eta_o_1);
    float3  _S396;
    if(_S395)
    {
        _S396 = make_float3 (1.0f);
    }
    else
    {
        float3  _S397 = material_1.specular_tint * make_float3 (_S390);
        _S396 = _S397 + (make_float3 (1.0f) - _S397) * make_float3 (_S394 - _S390) / make_float3 (1.0f - _S390);
    }
    float3  _S398 = make_float3 (1.0f);
    float3  _S399 = make_float3 (0.0f);
    float _S400 = rgb_to_greyscale(material_1.sheen);
    bool _S401 = _S400 > 0.0f;
    float3  sheen_1;
    float3  view_1;
    float3  scale_1;
    if(_S401)
    {
        float _S402 = clamp_1((F32_sqrt(((F32_max((dot_0(n_i_2, v_3)), (0.0f)))))), 0.0f, 1.0f) * 23.0f;
        uint _S403 = (U32_min((uint(_S402)), (22U)));
        float least_0 = (F32_sqrt((0.05000000074505806f)));
        float _S404 = (F32_sqrt((0.10000000149011612f)));
        bool _S405 = (material_1.velvet) > 0.0f;
        float _S406 = _slang_select(_S405, _S404,least_0);
        float _S407 = (clamp_1((F32_sqrt(((F32_max((material_1.sheen_roughness), (0.0f)))))), _S406, 1.0f) - _S406) / (1.0f - _S406) * 23.0f;
        uint _S408 = (U32_min((uint(_S407)), (22U)));
        uint _S409 = _S403 * 24U + _S408;
        float _S410 = _S402 - float(_S403);
        float _S411 = _S407 - float(_S408);
        uint _S412 = _S409 + 24U;
        float a_5 = SHEEN_ALBEDO_0[_S409] + (SHEEN_ALBEDO_0[_S412] - SHEEN_ALBEDO_0[_S409]) * _S410;
        uint _S413 = _S409 + 1U;
        uint _S414 = _S412 + 1U;
        float b_1 = SHEEN_ALBEDO_0[_S413] + (SHEEN_ALBEDO_0[_S414] - SHEEN_ALBEDO_0[_S413]) * _S410;
        float _S415 = (F32_exp((a_5 + (b_1 - a_5) * _S411)));
        if(_S405)
        {
            float a_6 = VELVET_ALBEDO_0[_S409] + (VELVET_ALBEDO_0[_S412] - VELVET_ALBEDO_0[_S409]) * _S410;
            float b_2 = VELVET_ALBEDO_0[_S413] + (VELVET_ALBEDO_0[_S414] - VELVET_ALBEDO_0[_S413]) * _S410;
            float _S416 = a_6 + (b_2 - a_6) * _S411;
            sheen_component_0 = _S416;
        }
        else
        {
            sheen_component_0 = _S415;
        }
        float _S417 = (F32_min((sheen_component_0), (1.0f)));
        float3  _S418 = make_float3 (1.0f) - material_1.sheen * make_float3 (_S417);
        float _S419 = rgb_to_greyscale(material_1.sheen);
        float _S420 = _S419 * _S417;
        float3  _S421 = material_1.sheen / make_float3 ((F32_max((sheen_component_0), (1.0f))));
        sheen_component_0 = _S420;
        sheen_1 = _S421;
        view_1 = v_3;
        scale_1 = _S418;
    }
    else
    {
        sheen_component_0 = 0.0f;
        sheen_1 = _S399;
        view_1 = _S399;
        scale_1 = _S398;
    }
    float _S422 = (F32_abs((material_1.toon.x)));
    bool _S423 = _S422 > 0.0f;
    if(_S423)
    {
        float _S424 = (F32_min((_S422), (1.0f)));
        float3  scale_2 = scale_1 * make_float3 (1.0f - _S424);
        float _S425 = rgb_to_greyscale(material_1.albedo);
        float _S426 = _S424 * _S425;
        toon_component_0 = _S426;
        scale_1 = scale_2;
    }
    else
    {
        toon_component_0 = 0.0f;
    }
    float3  _S427 = mix_0(_S396, material_1.albedo, material_1.metallic);
    float3  F_1 = _S427 * scale_1;
    float _S428 = rgb_to_greyscale(F_1);
    float _S429 = 1.0f - material_1.metallic;
    float3  _S430 = make_float3 (1.0f) - _S396;
    float3  _S431 = make_float3 ((1.0f - material_1.transmission) * _S429) * _S430 * scale_1;
    float3  _S432 = make_float3 (material_1.transmission * _S429) * _S430 * scale_1;
    float _S433 = (F32_max((_S428), (0.0f)));
    float _S434 = rgb_to_greyscale(_S431);
    float _S435 = (F32_max((_S434), (0.0f)));
    float _S436 = rgb_to_greyscale(_S432);
    float _S437 = sign_0(length_0(_S388));
    float _S438 = (F32_max((_S436 * _S437), (0.0f)));
    float _S439 = _S433 + _S435 + _S438 + toon_component_0;
    float _S440 = (F32_min((sheen_component_0), (1.0f)));
    bool _S441 = sheen_component_0 > 0.0f;
    bool _S442;
    if(_S441)
    {
        _S442 = !(_S439 > 0.0f);
    }
    else
    {
        _S442 = false;
    }
    float _S443 = _slang_select(_S442, 1.0f,_S440);
    float _S444 = (1.0f - _S443) / (F32_max((_S439), (0.0000152587890625f)));
    float _S445 = _S435 + toon_component_0;
    float _S446 = _S445 * _S444;
    float _S447 = _S433 * _S444;
    float _S448 = _S438 * _S444;
    bool _S449 = (frame_1.alphas.x) > 0.0f;
    float visible_1;
    if(_S449)
    {
        float3  _S450 = anisotropicLocal(v_3, frame_1.tangent, n_i_2);
        float _S451 = anisotropicG1(_S450, frame_1.alphas);
        float3  _S452 = anisotropicLocal(ggx_n_0, frame_1.tangent, n_i_2);
        float _S453 = anisotropicD(_S452, frame_1.alphas);
        float _S454 = _S451 * _S453;
        visible_1 = _S454;
    }
    else
    {
        visible_1 = 0.0f;
    }
    return BSDFLobes_x24init_0(_S384, _S385, _S388, F_1, _S428, 1.0f, _S431, _S432, _S446, _S447, _S448, 0.0f, sheen_1, _S443, view_1, frame_1.tangent, frame_1.alphas, visible_1, toon_component_0 / (F32_max((_S445), (0.0000152587890625f))));
}

__device__ float translucentShare(BSDFMaterial material_2)
{
    float _S455 = rgb_to_greyscale(material_2.translucent);
    float _S456 = rgb_to_greyscale(material_2.albedo);
    float _S457 = _S455 / (_S456 + _S455);
    bool _S458 = _S455 > 0.0f;
    float _S459 = _slang_select(_S458, _S457,0.0f);
    return _S459;
}

__device__ float smithG1(float alpha_2, float n_dot_x_0)
{
    float _S460 = alpha_2 * alpha_2;
    float _S461 = 2.0f * n_dot_x_0 / (n_dot_x_0 + (F32_sqrt((_S460 + (1.0f - _S460) * n_dot_x_0 * n_dot_x_0))));
    bool _S462 = alpha_2 > 0.0f;
    float _S463 = _slang_select(_S462, _S461,1.0f);
    return _S463;
}

__device__ float trowbridgeReitz(float alpha_3, float n_dot_h_1)
{
    float _S464 = alpha_3 * alpha_3;
    float _S465 = (1.0f - n_dot_h_1) * (1.0f + n_dot_h_1) + _S464 * n_dot_h_1 * n_dot_h_1;
    return _S464 / (F32_max((3.14159274101257324f * _S465 * _S465), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ float lobeDensity(float n_i_dot_l_0, float l_dot_h_0, float n_i_dot_v_0, float alpha_4, BSDFLobes lobes_0, float eta_i_2, float eta_o_2, uint lobe_0)
{
    bool _S466 = lobe_0 == 0U;
    if(_S466)
    {
        float _S467 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
        float _S468 = lobes_0.p_diffuse * (F32_abs((n_i_dot_l_0))) * 0.31830987334251404f;
        float _S469 = 1.0f - lobes_0.translucent_share;
        bool _S470 = n_i_dot_l_0 < 0.0f;
        float _S471 = _slang_select(_S470, lobes_0.translucent_share,_S469);
        float _S472 = _S468 * _S471;
        bool _S473 = (lobes_0.translucent_share) > 0.0f;
        float _S474 = _slang_select(_S473, _S472,_S467);
        bool _S475 = n_i_dot_v_0 > 0.0f;
        float _S476 = _slang_select(_S475, _S474,0.0f);
        return _S476;
    }
    bool _S477 = lobe_0 == 4U;
    bool _S478;
    if(_S477)
    {
        float _S479 = lobes_0.p_sheen_velvet * 0.5f * 0.31830987334251404f;
        bool _S480 = n_i_dot_l_0 > 0.0f;
        if(_S480)
        {
            _S478 = n_i_dot_v_0 > 0.0f;
        }
        else
        {
            _S478 = false;
        }
        float _S481 = _slang_select(_S478, _S479,0.0f);
        return _S481;
    }
    float _S482 = smithG1(alpha_4, n_i_dot_v_0);
    float _S483 = _S482 * lobes_0.v_dot_h;
    float _S484 = trowbridgeReitz(alpha_4, lobes_0.n_dot_h);
    float _S485 = _S483 * _S484 / n_i_dot_v_0;
    bool _S486 = alpha_4 > 0.0f;
    if(_S486)
    {
        _S478 = (lobes_0.v_dot_h) > 0.0f;
    }
    else
    {
        _S478 = false;
    }
    if(_S478)
    {
        _S478 = (lobes_0.n_dot_h) > 0.0f;
    }
    else
    {
        _S478 = false;
    }
    if(_S478)
    {
        _S478 = n_i_dot_v_0 > 0.0f;
    }
    else
    {
        _S478 = false;
    }
    float _S487 = _slang_select(_S478, _S485,0.0f);
    bool _S488 = (lobes_0.alphas.x) > 0.0f;
    float pdf_h_0;
    if(_S488)
    {
        float _S489 = lobes_0.visible * lobes_0.v_dot_h / n_i_dot_v_0;
        bool _S490 = (lobes_0.v_dot_h) > 0.0f;
        if(_S490)
        {
            _S478 = (lobes_0.n_dot_h) > 0.0f;
        }
        else
        {
            _S478 = false;
        }
        if(_S478)
        {
            _S478 = n_i_dot_v_0 > 0.0f;
        }
        else
        {
            _S478 = false;
        }
        float _S491 = _slang_select(_S478, _S489,0.0f);
        pdf_h_0 = _S491;
    }
    else
    {
        pdf_h_0 = _S487;
    }
    bool _S492 = lobe_0 == 1U;
    if(_S492)
    {
        float _S493 = eta_i_2 * lobes_0.v_dot_h + eta_o_2 * l_dot_h_0;
        float _S494 = lobes_0.p_refract * pdf_h_0 * eta_o_2 * eta_o_2 * (F32_abs((l_dot_h_0))) / (_S493 * _S493);
        bool _S495 = eta_i_2 != eta_o_2;
        if(_S495)
        {
            _S478 = l_dot_h_0 < 0.0f;
        }
        else
        {
            _S478 = false;
        }
        float _S496 = _slang_select(_S478, _S494,0.0f);
        return _S496;
    }
    float _S497 = lobes_0.p_reflect * pdf_h_0 / (4.0f * lobes_0.v_dot_h);
    bool _S498 = pdf_h_0 > 0.0f;
    float _S499 = _slang_select(_S498, _S497,0.0f);
    return _S499;
}

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_0, uint random_state_3, bool refracted_2, uint lobe_1, float pdf_0)
{
    SampleBSDF _S500;
    (&_S500)->unit_direction = unit_direction_1;
    (&_S500)->throughput = throughput_0;
    (&_S500)->random_state = random_state_3;
    (&_S500)->refracted = refracted_2;
    (&_S500)->lobe = lobe_1;
    (&_S500)->pdf = pdf_0;
    return _S500;
}

__device__ __forceinline__ float3  lobeThroughput(float3  l_0, float3  n_i_3, float alpha_5, BSDFMaterial material_3, BSDFLobes lobes_1, uint lobe_2)
{
    bool _S501 = lobe_2 == 0U;
    if(_S501)
    {
        bool _S502 = (dot_0(n_i_3, l_0)) < 0.0f;
        float3  _S503 = _slang_select(_S502, material_3.translucent,material_3.albedo);
        float _S504 = 1.0f - lobes_1.translucent_share;
        float _S505 = _slang_select(_S502, lobes_1.translucent_share,_S504);
        float3  _S506 = _S503 / make_float3 (_S505);
        bool _S507 = (lobes_1.translucent_share) > 0.0f;
        float3  _S508 = _slang_select(_S507, _S506,material_3.albedo);
        return lobes_1.diffuse_weight * _S508 / make_float3 (lobes_1.p_diffuse);
    }
    bool _S509 = lobe_2 == 4U;
    float f_1;
    if(_S509)
    {
        float3  _S510 = l_0 + lobes_1.view;
        float3  _S511 = ((((_S510)) * make_float3(rnorm3df(((_S510)).x, ((_S510)).y, ((_S510)).z))));
        float _S512 = dot_0(n_i_3, _S511);
        float _S513 = (F32_max((dot_0(n_i_3, l_0)), (0.0f)));
        float _S514 = (F32_max((dot_0(n_i_3, lobes_1.view)), (0.0f)));
        float _S515 = 1.0f / (F32_max((material_3.sheen_roughness), (0.05000000074505806f)));
        float _S516 = 1.0f - _S512 * _S512;
        float _S517 = (2.0f + _S515) * (F32_pow(((F32_max((_S516), (0.0f)))), (0.5f * _S515))) * 0.5f * 0.31830987334251404f / (F32_max((4.0f * (_S513 + _S514 - _S513 * _S514)), (0.0000152587890625f)));
        bool _S518 = (material_3.velvet) > 0.0f;
        if(_S518)
        {
            float _S519 = (F32_max((material_3.sheen_roughness), (0.00999999977648258f)));
            float _S520 = _S519 * _S519;
            float _S521 = (F32_max((_S516), (0.0000152587890625f)));
            float _S522 = (F32_exp((- _S512 * _S512 / (_S521 * _S520)))) / (3.14159274101257324f * _S520 * _S521 * _S521) * (F32_min((1.0f), (2.0f * _S512 * (F32_min((_S513), (_S514))) / (F32_max(((F32_abs((dot_0(_S511, lobes_1.view))))), (0.0000152587890625f)))))) / (F32_max((4.0f * _S513 * _S514), (0.0000152587890625f)));
            f_1 = _S522;
        }
        else
        {
            f_1 = _S517;
        }
        return lobes_1.sheen * make_float3 (f_1 * _S513 * 2.0f * 3.14159274101257324f / lobes_1.p_sheen_velvet);
    }
    bool _S523 = lobe_2 == 1U;
    if(_S523)
    {
        float _S524 = - dot_0(n_i_3, l_0);
        float _S525 = smithG1(alpha_5, (F32_max((_S524), (0.0f))));
        bool _S526 = (lobes_1.alphas.x) > 0.0f;
        if(_S526)
        {
            float3  _S527 = negate_0(n_i_3);
            float3  _S528 = anisotropicLocal(l_0, lobes_1.tangent, _S527);
            float _S529 = anisotropicG1(_S528, lobes_1.alphas);
            f_1 = _S529;
        }
        else
        {
            f_1 = _S525;
        }
        return lobes_1.refract_weight * make_float3 (f_1) * material_3.albedo / make_float3 (lobes_1.p_refract);
    }
    float _S530 = dot_0(n_i_3, l_0);
    float _S531 = smithG1(alpha_5, (F32_max((_S530), (0.0f))));
    bool _S532 = (lobes_1.alphas.x) > 0.0f;
    if(_S532)
    {
        float3  _S533 = anisotropicLocal(l_0, lobes_1.tangent, n_i_3);
        float _S534 = anisotropicG1(_S533, lobes_1.alphas);
        f_1 = _S534;
    }
    else
    {
        f_1 = _S531;
    }
    return make_float3 (lobes_1.reflect_weight * f_1) * lobes_1.F / make_float3 (lobes_1.p_reflect);
}

struct ToonLobe_0
{
    float a_7;
    float s_0;
    float b_3;
    bool glossy_0;
};

static __device__ ToonLobe_0 ToonLobe_x24init_0(float a_8, float s_1, float b_4, bool glossy_1)
{
    ToonLobe_0 _S535;
    (&_S535)->a_7 = a_8;
    (&_S535)->s_0 = s_1;
    (&_S535)->b_3 = b_4;
    (&_S535)->glossy_0 = glossy_1;
    return _S535;
}

static __device__ ToonLobe_0 toonLobe_0(float3  toon_0)
{
    float _S536 = toon_0.x;
    bool _S537 = (F32_abs((_S536))) > 0.0f;
    float _S538 = _slang_select(_S537, _S536,1.0f);
    float _S539 = clamp_1(toon_0.y / _S538, 0.00000999999974738f, 1.0f) * 3.14159274101257324f / 2.0f;
    float _S540 = clamp_1(toon_0.z / _S538, 0.0f, 1.0f) * 3.14159274101257324f / 2.0f;
    return ToonLobe_x24init_0(_S539, _S540, (F32_min((_S539 + _S540), (1.57079637050628662f))), _S536 < 0.0f);
}

static __device__ float toonProfile_0(float t_12, ToonLobe_0 * lobe_3)
{
    float _S541 = lobe_3->a_7;
    float _S542;
    if(t_12 < (lobe_3->a_7))
    {
        _S542 = 1.0f;
    }
    else
    {
        _S542 = (F32_max((1.0f - (t_12 - _S541) / (F32_max((lobe_3->s_0), (0.0000152587890625f)))), (0.0f)));
    }
    return _S542;
}

static __device__ float toonIntegral_0(float t_13, ToonLobe_0 * lobe_4)
{
    float _S543 = lobe_4->a_7;
    bool _S544 = lobe_4->glossy_0;
    float _S545;
    if(lobe_4->glossy_0)
    {
        _S545 = 1.0f - (F32_cos(((F32_min((t_13), (_S543))))));
    }
    else
    {
        float _S546 = (F32_sin(((F32_min((t_13), (_S543))))));
        _S545 = _S546 * _S546 / 2.0f;
    }
    bool _S547 = t_13 > _S543;
    bool _S548;
    if(_S547)
    {
        _S548 = (lobe_4->s_0) > 0.0f;
    }
    else
    {
        _S548 = false;
    }
    bool _S549 = !_S548;
    if(_S549)
    {
        return _S545;
    }
    if(_S544)
    {
        float _S550 = (F32_cos((_S543)));
        float _S551 = (F32_cos((t_13)));
        return _S545 + (1.0f + _S543 / lobe_4->s_0) * (_S550 - _S551) - ((F32_sin((t_13))) - t_13 * _S551 - ((F32_sin((_S543))) - _S543 * _S550)) / lobe_4->s_0;
    }
    float _S552 = 2.0f * _S543;
    float _S553 = (F32_cos((_S552)));
    float _S554 = 2.0f * t_13;
    float _S555 = (F32_cos((_S554)));
    return _S545 + (1.0f + _S543 / lobe_4->s_0) * (_S553 - _S555) / 4.0f - ((F32_sin((_S554))) / 8.0f - t_13 * _S555 / 4.0f - ((F32_sin((_S552))) / 8.0f - _S543 * _S553 / 4.0f)) / lobe_4->s_0;
}

__device__ float toonDensity(float3  v_4, float3  l_1, float3  n_5, float3  toon_1)
{
    ToonLobe_0 _S556 = toonLobe_0(toon_1);
    float _S557 = dot_0(n_5, l_1);
    if(_S556.glossy_0)
    {
        float _S558 = (F32_acos((clamp_1(dot_0(make_float3 (2.0f * dot_0(n_5, v_4)) * n_5 - v_4, l_1), -1.0f, 1.0f))));
        ToonLobe_0 _S559 = _S556;
        float _S560 = toonProfile_0(_S558, &_S559);
        ToonLobe_0 _S561 = _S556;
        float _S562 = toonIntegral_0(_S556.b_3, &_S561);
        return _S560 / (6.28318548202514648f * _S562);
    }
    float _S563 = (F32_acos(((F32_min((_S557), (1.0f))))));
    ToonLobe_0 _S564 = _S556;
    float _S565 = toonProfile_0(_S563, &_S564);
    float _S566 = _S565 * _S557;
    ToonLobe_0 _S567 = _S556;
    float _S568 = toonIntegral_0(_S556.b_3, &_S567);
    float _S569 = _S566 / (6.28318548202514648f * _S568);
    bool _S570 = _S557 > 0.0f;
    float _S571 = _slang_select(_S570, _S569,0.0f);
    return _S571;
}

__device__ float toonBSDF(float3  v_5, float3  l_2, float3  n_6, float3  toon_2)
{
    ToonLobe_0 _S572 = toonLobe_0(toon_2);
    float _S573 = dot_0(n_6, v_5);
    float _S574 = dot_0(n_6, l_2);
    bool _S575 = _S573 > 0.0f;
    bool _S576;
    if(_S575)
    {
        _S576 = _S574 > 0.0f;
    }
    else
    {
        _S576 = false;
    }
    bool _S577 = !_S576;
    if(_S577)
    {
        return 0.0f;
    }
    if(_S572.glossy_0)
    {
        float _S578 = (F32_acos((clamp_1(dot_0(make_float3 (2.0f * _S573) * n_6 - v_5, l_2), -1.0f, 1.0f))));
        ToonLobe_0 _S579 = _S572;
        float _S580 = toonProfile_0(_S578, &_S579);
        ToonLobe_0 _S581 = _S572;
        float _S582 = toonIntegral_0(_S572.b_3, &_S581);
        return _S580 / (6.28318548202514648f * _S582);
    }
    float _S583 = (F32_acos(((F32_min((_S573), (1.0f))))));
    ToonLobe_0 _S584 = _S572;
    float _S585 = toonProfile_0(_S583, &_S584);
    float _S586 = (F32_acos(((F32_min((_S574), (1.0f))))));
    ToonLobe_0 _S587 = _S572;
    float _S588 = toonProfile_0(_S586, &_S587);
    float _S589 = _S585 * _S588;
    ToonLobe_0 _S590 = _S572;
    float _S591 = toonIntegral_0(_S572.b_3, &_S590);
    return _S589 / (6.28318548202514648f * _S591);
}

static __device__ void toonMix_0(SampleBSDF * drawn_0, float3  v_6, float3  n_i_4, BSDFMaterial * material_4, BSDFLobes * lobes_2)
{
    float3  _S592 = drawn_0->unit_direction;
    float _S593 = (F32_max((drawn_0->pdf), (0.0f)));
    float _S594 = (1.0f - lobes_2->toon_share) * _S593;
    float _S595 = lobes_2->toon_share * lobes_2->p_diffuse;
    float3  _S596 = material_4->toon;
    float _S597 = toonDensity(v_6, _S592, n_i_4, material_4->toon);
    float _S598 = _S594 + _S595 * _S597;
    float3  _S599 = make_float3 ((F32_min(((F32_abs((_S596.x)))), (1.0f)))) * material_4->albedo;
    float _S600 = toonBSDF(v_6, _S592, n_i_4, _S596);
    float3  _S601 = _S599 * make_float3 (_S600) * make_float3 ((F32_max((dot_0(n_i_4, _S592)), (0.0f))));
    float3  _S602 = make_float3 (0.0f);
    float3  _S603 = (drawn_0->throughput * make_float3 (_S593) + _S601) / make_float3 (_S598);
    bool _S604 = _S598 > 0.0f;
    float3  _S605 = _slang_select(_S604, _S603,_S602);
    drawn_0->throughput = _S605;
    drawn_0->pdf = _S598;
    return;
}

__device__ __forceinline__ SampleBSDF connectBSDF(float3  in_dir_1, float3  out_dir_0, float3  n_7, BSDFMaterial material_5, float eta_i_3, float eta_o_3, uint lobe_5, uint random_init_0)
{
    uint random_state_4 = random_init_0;
    float3  _S606 = negate_0(in_dir_1);
    float _S607 = dot_0(n_7, _S606);
    float _S608 = sign_0(_S607);
    float3  _S609 = n_7 * make_float3 (_S608);
    float _S610 = material_5.roughness;
    float _S611 = _S610 * _S610;
    AnisotropicFrame _S612 = anisotropicFrame(material_5, _S609);
    float3  _S613 = _S606 + out_dir_0;
    float3  _S614 = ((((_S613)) * make_float3(rnorm3df(((_S613)).x, ((_S613)).y, ((_S613)).z))));
    bool _S615 = lobe_5 == 0U;
    float3  ggx_n_1;
    if(_S615)
    {
        float3  _S616 = sampleHalfVector(_S606, _S609, _S611, _S612, &random_state_4);
        ggx_n_1 = _S616;
    }
    else
    {
        bool _S617 = lobe_5 == 1U;
        if(_S617)
        {
            float3  _S618 = negate_0(make_float3 (eta_i_3) * _S606 + make_float3 (eta_o_3) * out_dir_0);
            float3  _S619 = ((((_S618)) * make_float3(rnorm3df(((_S618)).x, ((_S618)).y, ((_S618)).z))));
            float _S620 = sign_0(dot_0(_S618, _S609));
            float3  _S621 = _S619 * make_float3 (_S620);
            ggx_n_1 = _S621;
        }
        else
        {
            ggx_n_1 = _S614;
        }
    }
    BSDFLobes _S622 = bsdfLobes(in_dir_1, _S606, _S609, ggx_n_1, material_5, eta_i_3, eta_o_3, _S612);
    BSDFLobes lobes_3 = _S622;
    float _S623 = translucentShare(material_5);
    (&lobes_3)->translucent_share = _S623;
    float _S624 = lobeDensity(dot_0(_S609, out_dir_0), dot_0(out_dir_0, ggx_n_1), (F32_abs((_S607))), _S611, lobes_3, eta_i_3, eta_o_3, lobe_5);
    bool _S625 = !(_S624 > 0.0f);
    if(_S625)
    {
        float3  _S626 = make_float3 (0.0f);
        return SampleBSDF_x24init_0(_S626, _S626, 0U, false, 0U, 0.0f);
    }
    float3  _S627 = lobeThroughput(out_dir_0, _S609, _S611, material_5, lobes_3, lobe_5);
    SampleBSDF _S628 = SampleBSDF_x24init_0(out_dir_0, _S627, random_state_4, lobe_5 == 1U, lobe_5, _S624);
    SampleBSDF sample_0 = _S628;
    bool _S629;
    if(_S615)
    {
        _S629 = ((&lobes_3)->toon_share) > 0.0f;
    }
    else
    {
        _S629 = false;
    }
    if(_S629)
    {
        BSDFMaterial _S630 = material_5;
        BSDFLobes _S631 = lobes_3;
        toonMix_0(&sample_0, _S606, _S609, &_S630, &_S631);
    }
    return sample_0;
}

__device__ __forceinline__ float3  neeBSDF(float3  in_dir_2, float3  dir_3, float3  n_8, BSDFMaterial material_6, float eta_i_4, float eta_o_4, bool refracted_3, float pdf_1, bool power_0, uint random_state_5)
{
    float3  _S632 = make_float3 (0.0f);
    uint i_6 = 0U;
    float3  f_2 = _S632;
    for(;;)
    {
        if(i_6 < 4U)
        {
        }
        else
        {
            break;
        }
        uint _S633;
        if(i_6 == 3U)
        {
            _S633 = 4U;
        }
        else
        {
            _S633 = i_6;
        }
        bool _S634 = _S633 == 0U;
        if(_S634)
        {
        }
        bool _S635;
        if(_S634)
        {
            float _S636 = rgb_to_greyscale(material_6.translucent);
            _S635 = _S636 > 0.0f;
        }
        else
        {
            _S635 = false;
        }
        bool _S637;
        if(_S635)
        {
            float _S638 = dot_0(n_8, dir_3);
            float3  _S639 = negate_0(in_dir_2);
            _S637 = ((_S638 * dot_0(n_8, _S639)) < 0.0f) == refracted_3;
        }
        else
        {
            _S637 = (_S633 == 1U) == refracted_3;
        }
        float3  f_3;
        if(_S637)
        {
            SampleBSDF _S640 = connectBSDF(in_dir_2, dir_3, n_8, material_6, eta_i_4, eta_o_4, _S633, random_state_5);
            bool _S641 = (_S640.pdf) > 0.0f;
            if(_S641)
            {
                if(power_0)
                {
                    float _S642 = _S640.pdf / pdf_1;
                    float3  f_4 = f_2 + _S640.throughput * make_float3 (_S640.pdf) / make_float3 (pdf_1 * (1.0f + _S642 * _S642));
                    f_3 = f_4;
                }
                else
                {
                    float3  f_5 = f_2 + _S640.throughput * make_float3 (_S640.pdf) / make_float3 (_S640.pdf + pdf_1);
                    f_3 = f_5;
                }
            }
            else
            {
                f_3 = f_2;
            }
        }
        else
        {
            f_3 = f_2;
        }
        uint i_7 = i_6 + 1U;
        i_6 = i_7;
        f_2 = f_3;
    }
    return f_2;
}

__device__ float3  skyBSDF(float3  in_dir_3, float3  dir_4, FKSurface surface_1, float2  eta_1, bool is_inside_2, float pdf_2, uint random_state_6)
{
    bool _S643 = wrongSide_0(is_inside_2, false, dir_4, surface_1.geometry_n);
    float3  _S644 = neeBSDF(in_dir_3, dir_4, surface_1.smooth_n, surface_1.material, eta_1.x, eta_1.y, _S643, pdf_2, false, random_state_6);
    return _S644;
}

static __device__ SkySample SkySample_x24init_0(float3  dir_5, float3  radiance_0, float3  color_0, uint random_state_7)
{
    SkySample _S645;
    (&_S645)->dir = dir_5;
    (&_S645)->radiance = radiance_0;
    (&_S645)->color = color_0;
    (&_S645)->random_state = random_state_7;
    return _S645;
}

static __device__ SkySample sampleSky_0(FKRay * ray_0, FKSurface * surface_2, float2  eta_2, bool is_inside_3, uint init_random_state_0, uint lobe_state_0, ShadowContext * context_2)
{
    uint2  _S646 = (fcptEnvironmentCdfSize());
    uint2  _S647 = make_uint2 (1U, 0U);
    uint2  _S648 = _S646 - _S647;
    Random _S649 = pcg(init_random_state_0);
    Random _S650 = pcg(_S649.state);
    Random _S651 = pcg(_S650.state);
    Random _S652 = pcg(_S651.state);
    uint _S653 = _S648.x;
    uint _S654 = searchCDF_0(make_uint2 (_S653, 0U), make_uint2 (0U, 1U), _S648.y, _S649.value);
    uint _S655 = searchCDF_0(make_uint2 (0U, _S654), _S647, _S653, _S650.value);
    float2  _S656 = make_float2 ((float)_S648.x, (float)_S648.y);
    float2  _S657 = (make_float2 (float(_S655), float(_S654)) + make_float2 (_S651.value, _S652.value)) / _S656 * make_float2 (6.28318548202514648f, 3.14159274101257324f);
    float _S658 = _S657.y;
    float _S659 = (F32_sin((_S658)));
    float _S660 = _S657.x;
    float3  _S661 = make_float3 (- _S659 * (F32_cos((_S660))), _S659 * (F32_sin((_S660))), (F32_cos((_S658))));
    float _S662 = environmentPdf_0(_S661);
    float3  _S663 = skyBSDF(ray_0->unit_direction, _S661, *surface_2, eta_2, is_inside_3, _S662, lobe_state_0);
    bool _S664 = !(_S662 > 0.0f);
    bool _S665;
    if(_S664)
    {
        _S665 = true;
    }
    else
    {
        _S665 = all_1(_S663 == make_float3 (0.0f));
    }
    if(_S665)
    {
        float3  _S666 = make_float3 (0.0f);
        return SkySample_x24init_0(_S661, _S666, _S666, _S652.state);
    }
    float3  _S667 = skyRadiance_0(ray_0->origin, surface_2, is_inside_3, _S661, context_2, _S652.state);
    return SkySample_x24init_0(_S661, _S667, _S663 * _S667, _S652.state);
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
    SampleBSDF _S668 = (fcptConnectHair((surface_3->hair), ((&surface_3->material)->albedo), ((&surface_3->material)->specular_tint), (in_dir_4), (light_1->dir)));
    float3  _S669 = _S668.throughput * make_float3 (_S668.pdf);
    float _S670 = light_1->density;
    float _S671 = 1.0f + _S668.pdf * _S668.pdf / (light_1->density * light_1->density);
    bool _S672;
    if(competing_0)
    {
        _S672 = _S670 > 0.0f;
    }
    else
    {
        _S672 = false;
    }
    float _S673 = _slang_select(_S672, _S671,1.0f);
    return _S669 / make_float3 (_S673) * light_1->radiance;
}

static __device__ TreeSample TreeSample_x24init_0(float3  dir_6, float3  radiance_1, float density_0, uint random_state_8)
{
    TreeSample _S674;
    (&_S674)->dir = dir_6;
    (&_S674)->radiance = radiance_1;
    (&_S674)->density = density_0;
    (&_S674)->random_state = random_state_8;
    return _S674;
}

__device__ uint pickChild(LightNode first_1, LightNode second_1, float3  p_11, float3  normal_3, float * pick_0, float * probability_3)
{
    float _S675 = importance(first_1, p_11, normal_3);
    float _S676 = importance(second_1, p_11, normal_3);
    float2  _S677 = make_float2 (_S675, _S676);
    bool _S678 = _S675 == 0.0f;
    bool _S679;
    if(_S678)
    {
        _S679 = _S676 == 0.0f;
    }
    else
    {
        _S679 = false;
    }
    if(_S679)
    {
        return 2U;
    }
    float _S680 = _S675 + _S676;
    bool _S681 = _S676 > 0.0f;
    if(_S681)
    {
        _S679 = (*pick_0 * _S680) >= _S675;
    }
    else
    {
        _S679 = false;
    }
    uint _S682 = uint(_S679);
    float _S683 = (F32_min(((*pick_0 * _S680 - float(_S682) * _S675) / _slang_vector_get_element(_S677, _S682)), (0.99999994039535522f)));
    *pick_0 = _S683;
    float _S684 = *probability_3 * (_slang_vector_get_element(_S677, _S682) / _S680);
    *probability_3 = _S684;
    return _S682;
}

__device__ float3  sampleSphere(float3  center_1, float radius_1, float3  p_12, float u1_0, float u2_0)
{
    float3  _S685 = center_1 - p_12;
    float _S686 = radius_1 * radius_1 / dot_0(_S685, _S685);
    float _S687 = u1_0 * _S686 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S686), (0.0f)))))));
    float _S688 = 2.0f * u1_0;
    bool _S689 = _S686 >= 1.0f;
    float _S690 = _slang_select(_S689, _S688,_S687);
    float _S691 = (F32_sqrt(((F32_max((_S690 * (2.0f - _S690)), (0.0f))))));
    float _S692 = 6.28318548202514648f * u2_0;
    float3  _S693 = make_float3 (_S691 * (F32_cos((_S692))), 1.0f - _S690, _S691 * (F32_sin((_S692))));
    float3  _S694 = ((((_S685)) * make_float3(rnorm3df(((_S685)).x, ((_S685)).y, ((_S685)).z))));
    float3  _S695 = tangentToWorld(_S693, _S694);
    return _S695;
}

__device__ float3  pointLightRadiance(float3  color_1, float intensity_0, float radius_2)
{
    return color_1 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_2 * radius_2);
}

static __device__ float raySphere_0(float3  center_2, float radius_3, FKRay * ray_1, float max_len_0)
{
    float3  _S696 = center_2 - ray_1->origin;
    float _S697 = dot_0(_S696, ray_1->unit_direction);
    float _S698 = dot_0(_S696, _S696) - _S697 * _S697;
    float _S699 = radius_3 * radius_3;
    bool _S700 = _S698 > _S699;
    if(_S700)
    {
        return 4.294967296e+09f;
    }
    float _S701 = (F32_sqrt((_S699 - _S698)));
    float _S702 = _S697 - _S701;
    float _S703 = _S697 + _S701;
    bool _S704 = _S702 > 0.0000152587890625f;
    bool _S705;
    if(_S704)
    {
        _S705 = _S702 < max_len_0;
    }
    else
    {
        _S705 = false;
    }
    if(_S705)
    {
        return _S702;
    }
    bool _S706 = _S703 > 0.0000152587890625f;
    if(_S706)
    {
        _S705 = _S703 < max_len_0;
    }
    else
    {
        _S705 = false;
    }
    if(_S705)
    {
        return _S703;
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
        int i_8 = int(0);
        float sum_0 = 0.0f;
        for(;;)
        {
            if(i_8 < int(3))
            {
            }
            else
            {
                break;
            }
            float sum_1 = sum_0 + _slang_vector_get_element(left_1, i_8) * _slang_vector_get_element(right_1.rows[i_8], j_1);
            i_8 = i_8 + int(1);
            sum_0 = sum_1;
        }
        *_slang_vector_get_element_ptr(&result_5, j_1) = sum_0;
        j_1 = j_1 + int(1);
    }
    return result_5;
}

static __device__ __forceinline__ TreeSample sampleLightTree_0(float3  origin_4, float3  smooth_n_2, float3  geometry_n_1, float geometry_offset_1, bool sided_0, uint init_random_state_1, ShadowContext * context_3)
{
    Random _S707 = pcg(init_random_state_1);
    Random _S708 = pcg(_S707.state);
    Random _S709 = pcg(_S708.state);
    float3  _S710 = make_float3 (0.0f);
    TreeSample _S711 = TreeSample_x24init_0(_S710, _S710, 0.0f, _S709.state);
    TreeSample sample_1 = _S711;
    float3  _S712 = _slang_select(sided_0, _S710,smooth_n_2);
    float3  _S713 = origin_4 + make_float3 (geometry_offset_1) * smooth_n_2;
    float pick_1 = _S707.value;
    float probability_4 = 1.0f;
    uint n_9 = 0U;
    for(;;)
    {
        uint4  _S714 = (fcptLightNode((n_9)));
        if((_S714.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S715 = (fcptLightSecond((n_9)));
        uint _S716 = n_9 + 1U;
        LightNode _S717 = (fcptLightBounds((_S716)));
        LightNode _S718 = (fcptLightBounds((_S715)));
        uint _S719 = pickChild(_S717, _S718, origin_4, _S712, &pick_1, &probability_4);
        bool _S720 = _S719 > 1U;
        if(_S720)
        {
            return sample_1;
        }
        bool _S721 = _S719 == 1U;
        uint _S722 = _slang_select(_S721, _S715,_S716);
        n_9 = _S722;
    }
    bool _S723 = n_9 == 0U;
    bool _S724;
    if(_S723)
    {
        LightNode _S725 = (fcptLightBounds((0U)));
        float _S726 = importance(_S725, origin_4, _S712);
        _S724 = !(_S726 > 0.0f);
    }
    else
    {
        _S724 = false;
    }
    if(_S724)
    {
        return sample_1;
    }
    uint4  _S727 = (fcptLightNode((n_9)));
    FKHit _S728 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    bool _S729 = (_S727.x) == 2U;
    float3  emitter_point_0;
    float3  lift_n_0;
    float3  shadow_1;
    FKHit emitter_0;
    if(_S729)
    {
        FKLight _S730 = (fcptLight((_S727.y)));
        if(sided_0)
        {
            float _S731 = sign_0(dot_0(geometry_n_1, _S730.position - origin_4));
            float3  lift_n_1 = smooth_n_2 * make_float3 (_S731);
            float3  _S732 = origin_4 + make_float3 (geometry_offset_1) * lift_n_1;
            emitter_point_0 = _S732;
            lift_n_0 = lift_n_1;
        }
        else
        {
            emitter_point_0 = _S713;
            lift_n_0 = smooth_n_2;
        }
        bool _S733 = (_S730.variance) == 0.0f;
        if(_S733)
        {
            float3  _S734 = _S730.position - emitter_point_0;
            float3  _S735 = ((((_S734)) * make_float3(rnorm3df(((_S734)).x, ((_S734)).y, ((_S734)).z))));
            (&sample_1)->dir = _S735;
            float3  _S736 = _S730.color * make_float3 (_S730.intensity) / make_float3 (dot_0(_S734, _S734) * probability_4);
            (&sample_1)->radiance = _S736;
            shadow_1 = _S734;
        }
        else
        {
            float3  _S737 = sampleSphere(_S730.position, _S730.variance, emitter_point_0, _S708.value, _S709.value);
            (&sample_1)->dir = _S737;
            float _S738 = sphereDensity(_S730.position, _S730.variance, emitter_point_0);
            float _S739 = probability_4 * _S738;
            (&sample_1)->density = _S739;
            float3  _S740 = pointLightRadiance(_S730.color, _S730.intensity, _S730.variance);
            float3  _S741 = _S740 / make_float3 ((&sample_1)->density);
            (&sample_1)->radiance = _S741;
            FKRay _S742 = Ray_x24init_0(emitter_point_0, (&sample_1)->dir);
            float _S743 = raySphere_0(_S730.position, _S730.variance, &_S742, 4.294967296e+09f);
            float3  _S744 = (&sample_1)->dir * make_float3 (_S743);
            shadow_1 = _S744;
        }
        emitter_0 = _S728;
        emitter_point_0 = _S710;
    }
    else
    {
        uint _S745 = _S727.y;
        uint _S746 = (fcptTriangleOffset((_S745)));
        uint _S747 = _S746 + _S727.z;
        Matrix<float, 3, 3>  _S748 = (fcptWorldTriangle((_S745), (_S747)));
        float _S749 = (F32_sqrt((_S708.value)));
        float2  _S750 = make_float2 (_S749 * (1.0f - _S709.value), _S749 * _S709.value);
        float3  _S751 = mul_0(make_float3 (1.0f - _S749, _S750.x, _S750.y), _S748);
        if(sided_0)
        {
            float _S752 = sign_0(dot_0(geometry_n_1, _S751 - origin_4));
            float3  lift_n_2 = smooth_n_2 * make_float3 (_S752);
            float3  _S753 = origin_4 + make_float3 (geometry_offset_1) * lift_n_2;
            emitter_point_0 = _S753;
            lift_n_0 = lift_n_2;
        }
        else
        {
            bool _S754 = !((dot_0(smooth_n_2, _S751 - origin_4)) > 0.0f);
            if(_S754)
            {
                return sample_1;
            }
            emitter_point_0 = _S713;
            lift_n_0 = smooth_n_2;
        }
        FKHit emitter_1 = Hit_x24init_0(_S750, _S745, _S747, 0U, 0.0f);
        float3  _S755 = _S751 - emitter_point_0;
        float3  _S756 = ((((_S755)) * make_float3(rnorm3df(((_S755)).x, ((_S755)).y, ((_S755)).z))));
        (&sample_1)->dir = _S756;
        float _S757 = solidAngle(probability_4, cross_0(_S748.rows[int(1)] - _S748.rows[int(0)], _S748.rows[int(2)] - _S748.rows[int(0)]), _S755);
        (&sample_1)->density = _S757;
        bool _S758 = (fcptShadowFirst());
        bool _S759 = !_S758;
        if(_S759)
        {
            FKSurface _S760 = (fcptLightSurfaceAt((emitter_1), (_S751), (_S709.state), ((&sample_1)->dir), (context_3->depth), (length_0(_S751 - origin_4))));
            (&sample_1)->random_state = _S760.random_state;
            float3  _S761 = _slang_select(_S760.skip, _S710,_S760.material.emissive);
            float3  _S762 = _S761 / make_float3 ((&sample_1)->density);
            (&sample_1)->radiance = _S762;
        }
        shadow_1 = _S755;
        emitter_0 = emitter_1;
        emitter_point_0 = _S751;
    }
    FKHit _S763 = emitter_0;
    float3  _S764 = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, context_3, _S709.state, &_S763);
    bool _S765 = (fcptShadowFirst());
    if(_S765)
    {
        _S724 = (emitter_0.instance_index) != 4294967295U;
    }
    else
    {
        _S724 = false;
    }
    if(_S724)
    {
        _S724 = !all_1(_S764 == _S710);
    }
    else
    {
        _S724 = false;
    }
    if(_S724)
    {
        FKSurface _S766 = (fcptLightSurfaceAt((emitter_0), (emitter_point_0), (_S709.state), ((&sample_1)->dir), (context_3->depth), (length_0(emitter_point_0 - origin_4))));
        (&sample_1)->random_state = _S766.random_state;
        float3  _S767 = _slang_select(_S766.skip, _S710,_S766.material.emissive);
        float3  _S768 = _S767 / make_float3 ((&sample_1)->density);
        (&sample_1)->radiance = _S768;
    }
    float3  _S769 = (&sample_1)->radiance * _S764;
    bool _S770 = all_1(_S764 == _S710);
    float3  _S771 = _slang_select(_S770, _S710,_S769);
    (&sample_1)->radiance = _S771;
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

__device__ float powerHeuristic(float a_9, float b_5)
{
    float _S772 = 1.0f / (1.0f + b_5 / a_9 * (b_5 / a_9));
    bool _S773 = b_5 > 0.0f;
    float _S774 = _slang_select(_S773, _S772,1.0f);
    return _S774;
}

static __device__ float emissionWeight_0(NEEVertex * vertex_0, FKHit * hit_1, float3  light_point_1)
{
    bool _S775 = vertex_0->none;
    if(_S775)
    {
        return 1.0f;
    }
    uint _S776 = (fcptLightSlot((*hit_1)));
    float _S777 = lightPdf_0(vertex_0->origin, vertex_0->smooth_n, vertex_0->start, _S776, light_point_1);
    float _S778 = powerHeuristic(vertex_0->pdf, _S777);
    return _S778;
}

static __device__ float3  environment_0(float3  dir_7, uint depth_0, uint lobe_6)
{
    uint2  _S779 = (fcptEnvironmentMapSize());
    bool _S780 = (_S779.x) > 1U;
    bool _S781;
    if(_S780)
    {
        uint2  _S782 = (fcptEnvironmentMapSize());
        _S781 = (_S782.y) > 1U;
    }
    else
    {
        _S781 = false;
    }
    if(_S781)
    {
        float3  _S783 = (fcptEnvMapSample((dir_7), (depth_0), (lobe_6)));
        return _S783;
    }
    float3  _S784 = (fcptAmbient());
    return _S784;
}

static __device__ bool environmentMapped_0()
{
    uint2  _S785 = (fcptEnvironmentCdfSize());
    bool _S786 = (_S785.x) > 1U;
    bool _S787;
    if(_S786)
    {
        uint2  _S788 = (fcptEnvironmentCdfSize());
        _S787 = (_S788.y) > 1U;
    }
    else
    {
        _S787 = false;
    }
    bool _S789 = !_S787;
    if(_S789)
    {
        return false;
    }
    uint2  _S790 = (fcptEnvironmentMapSize());
    bool _S791 = (_S790.x) > 1U;
    if(_S791)
    {
        uint2  _S792 = (fcptEnvironmentMapSize());
        _S787 = (_S792.y) > 1U;
    }
    else
    {
        _S787 = false;
    }
    return _S787;
}

static __device__ float escapeWeight_0(float pdf_3, float3  dir_8)
{
    bool _S793 = pdf_3 <= 0.0f;
    bool _S794;
    if(_S793)
    {
        _S794 = true;
    }
    else
    {
        bool _S795 = environmentMapped_0();
        _S794 = !_S795;
    }
    if(_S794)
    {
        return 1.0f;
    }
    float _S796 = environmentPdf_0(dir_8);
    return pdf_3 / (pdf_3 + _S796);
}

static __device__ float3  min_1(float3  x_15, float3  y_4)
{
    float3  result_6;
    int i_9 = int(0);
    for(;;)
    {
        if(i_9 < int(3))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_6, i_9) = (F32_min((_slang_vector_get_element(x_15, i_9)), (_slang_vector_get_element(y_4, i_9))));
        i_9 = i_9 + int(1);
    }
    return result_6;
}

static __device__ void restir_duplicates_0(uint3  global_invocation_id_1, uint3  local_invocation_id_0, uint local_invocation_index_3)
{
    uint2  _S797 = uint2 {global_invocation_id_1.x, global_invocation_id_1.y};
    int2  _S798 = make_int2 ((int)_S797.x, (int)_S797.y);
    uint _S799 = previousSeed_0(_S798);
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
            uint _S800 = previousSeed_0(_S798 + make_int2 (x_16, y_5));
            bool _S801 = _S800 == _S799;
            uint _S802 = _slang_select(_S801, 1U,0U);
            uint count_3 = count_2 + _S802;
            int x_17 = x_16 + int(1);
            x_16 = x_17;
            count_2 = count_3;
        }
        int y_6 = y_5 + int(1);
        y_5 = y_6;
    }
    float _S803 = float(count_2 - 1U) / 288.0f;
    bool _S804 = _S799 != 0U;
    float _S805 = _slang_select(_S804, _S803,0.0f);
    fcptStoreDuplication((_S798), (make_uint4 ((F32_asuint((_S805))), 0U, 0U, 0U)));
    return;
}

__device__ uint stream(uint seed_3, uint index_0)
{
    uint _S806 = hash(index_0);
    uint _S807 = hash(seed_3 ^ _S806);
    return _S807;
}

static __device__ float4  asfloat_0(uint4  x_18)
{
    float4  result_7;
    int i_10 = int(0);
    for(;;)
    {
        if(i_10 < int(4))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_7, i_10) = (U32_asfloat((_slang_vector_get_element(x_18, i_10))));
        i_10 = i_10 + int(1);
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
    float _S808 = rgb_to_greyscale(weight_0);
    bool _S809 = _S808 > 0.0f;
    bool _S810;
    if(_S809)
    {
        _S810 = _S808 < 3.00000000549775576e+38f;
    }
    else
    {
        _S810 = false;
    }
    bool _S811 = !_S810;
    if(_S811)
    {
        return;
    }
    bool _S812 = sel_2->sums;
    if(_S812)
    {
        float3  _S813 = sel_2->color + weight_0;
        sel_2->color = _S813;
        return;
    }
    float _S814 = sel_2->w_sum + _S808;
    sel_2->w_sum = _S814;
    float3  _S815 = sel_2->color + weight_0;
    sel_2->color = _S815;
    Random _S816 = pcg(sel_2->random_state);
    sel_2->random_state = _S816.state;
    bool _S817 = (_S816.value * sel_2->w_sum) <= _S808;
    if(_S817)
    {
        sel_2->r = candidate_0;
    }
    return;
}

__device__ void offerShifted(Selection * sel_3, Reservoir r_3, Shift shifted_0, float mis_0)
{
    Reservoir candidate_1 = r_3;
    float3  _S818 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_1)->f = _S818;
    float _S819 = r_3.jac * shifted_0.jac;
    (&candidate_1)->jac = _S819;
    offer(sel_3, candidate_1, make_float3 (mis_0) * shifted_0.f * make_float3 (r_3.w));
    return;
}

__device__ Reservoir finalize(Selection sel_4, float c_1)
{
    Reservoir r_4 = sel_4.r;
    float _S820 = rgb_to_greyscale((&r_4)->f);
    float _S821 = sel_4.w_sum / _S820;
    bool _S822 = _S820 > 0.0f;
    float _S823 = _slang_select(_S822, _S821,0.0f);
    (&r_4)->w = _S823;
    (&r_4)->c = c_1;
    return r_4;
}

static __device__ uint2  asuint_0(float2  x_19)
{
    uint2  result_8;
    int i_11 = int(0);
    for(;;)
    {
        if(i_11 < int(2))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_8, i_11) = (F32_asuint((_slang_vector_get_element(x_19, i_11))));
        i_11 = i_11 + int(1);
    }
    return result_8;
}

static __device__ void restir_spatial_0(uint3  global_invocation_id_2)
{
    uint2  _S824 = uint2 {global_invocation_id_2.x, global_invocation_id_2.y};
    int2  _S825 = make_int2 ((int)_S824.x, (int)_S824.y);
    float3  _S826 = make_float3 (0.0f);
    FKHit _S827 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S828 = Domain_x24init_0(_S826, _S826, &_S827, 0.0f, 0.0f);
    Domain dom_4 = _S828;
    bool _S829 = (fcptCurrentDomain((_S825), (&dom_4)));
    bool _S830 = !_S829;
    if(_S830)
    {
        Reservoir _S831 = (Reservoir{});
        fcptStoreReservoirPrevious((_S825), (_S831), ((&dom_4)->hit));
        return;
    }
    Reservoir _S832 = (fcptLoadReservoirTemporal((_S825)));
    uint t_14 = 0U;
    float count_4 = 0.0f;
    float c_sum_1 = _S832.c;
    for(;;)
    {
        uint _S833 = (fcptRestirNeighbours());
        if(t_14 < _S833)
        {
        }
        else
        {
            break;
        }
        int2  _S834 = partner_0(_S825, t_14);
        Domain neighbor_0 = _S828;
        bool _S835 = (fcptCurrentDomain((_S834), (&neighbor_0)));
        if(_S835)
        {
            float count_5 = count_4 + 1.0f;
            uint4  _S836 = (fcptReservoirTemporal((_S834), (0U)));
            float c_sum_2 = c_sum_1 + (U32_asfloat((_S836.w)));
            count_4 = count_5;
            c_sum_1 = c_sum_2;
        }
        uint t_15 = t_14 + 1U;
        t_14 = t_15;
    }
    float _S837 = _S832.c / (F32_max((count_4), (1.0f)));
    float _S838 = rgb_to_greyscale(_S832.f);
    bool _S839 = count_4 == 0.0f;
    float _S840 = _slang_select(_S839, 1.0f,0.0f);
    Selection _S841 = (Selection{});
    Selection sel_5 = _S841;
    uint _S842 = (fcptFrame());
    uint _S843 = hash(_S842);
    uint _S844 = global_invocation_id_2.x;
    uint2  _S845 = (fcptRenderSize());
    uint _S846 = stream(_S843, _S844 + _S845.x * global_invocation_id_2.y);
    uint _S847 = stream(_S846, 195U);
    (&sel_5)->random_state = _S847;
    t_14 = 0U;
    float canonical_mis_0 = _S840;
    for(;;)
    {
        uint _S848 = (fcptRestirNeighbours());
        if(t_14 < _S848)
        {
        }
        else
        {
            break;
        }
        int2  _S849 = partner_0(_S825, t_14);
        Domain neighbor_dom_0 = _S828;
        bool _S850 = (fcptCurrentDomain((_S849), (&neighbor_dom_0)));
        if(_S850)
        {
            Reservoir _S851 = (fcptLoadReservoirTemporal((_S849)));
            uint4  _S852 = (fcptShiftData((_S849), (t_14)));
            float4  _S853 = asfloat_0(_S852);
            uint4  _S854 = (fcptShiftData((_S825), (t_14)));
            float4  _S855 = asfloat_0(_S854);
            float _S856 = pairShare(_S851.c, _S837, c_sum_1);
            bool _S857 = _S838 > 0.0f;
            float canonical_mis_1;
            if(_S857)
            {
                float _S858 = rgb_to_greyscale(float3 {_S855.x, _S855.y, _S855.z});
                float _S859 = canonicalWeight(_S856, _S837, _S838, _S851.c, _S858);
                float canonical_mis_2 = canonical_mis_0 + _S859;
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            float3  _S860 = float3 {_S853.x, _S853.y, _S853.z};
            Shift _S861 = Shift_x24init_0(_S860, _S853.w);
            float _S862 = rgb_to_greyscale(_S851.f);
            float _S863 = rgb_to_greyscale(_S860);
            float _S864 = neighborWeight(_S856, _S851.c, _S862, _S837, _S863);
            offerShifted(&sel_5, _S851, _S861, _S864);
            canonical_mis_0 = canonical_mis_1;
        }
        uint t_16 = t_14 + 1U;
        t_14 = t_16;
    }
    offerShifted(&sel_5, _S832, Shift_x24init_0(_S832.f, 1.0f), canonical_mis_0);
    Reservoir _S865 = finalize(sel_5, c_sum_1);
    fcptStoreReservoirPrevious((_S825), (_S865), ((&dom_4)->hit));
    fcptStorePreviousLayer((_S825), (5U), (make_uint4 (asuint_0((&(&dom_4)->hit)->uv).x, asuint_0((&(&dom_4)->hit)->uv).y, 0U, 0U)));
    fcptAddColor((_S825), (make_float4 ((&sel_5)->color.x, (&sel_5)->color.y, (&sel_5)->color.z, 0.0f)));
    return;
}

static __device__ uint3  asuint_1(float3  x_20)
{
    uint3  result_9;
    int i_12 = int(0);
    for(;;)
    {
        if(i_12 < int(3))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_9, i_12) = (F32_asuint((_slang_vector_get_element(x_20, i_12))));
        i_12 = i_12 + int(1);
    }
    return result_9;
}

static __device__ void restir_shift_0(uint3  workgroup_id_1, uint local_invocation_index_4)
{
    uint _S866 = queuedShift_0(workgroup_id_1, local_invocation_index_4);
    bool _S867 = _S866 != 4294967295U;
    if(_S867)
    {
        uint2  _S868 = make_uint2 (_S866, _S866 >> 14U) & make_uint2 (16383U);
        int2  _S869 = make_int2 ((int)_S868.x, (int)_S868.y);
        ShiftJob _S870 = (ShiftJob{});
        ShiftJob shift_job_0 = _S870;
        Shift _S871 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
        uint _S872 = _S866 >> 28U;
        bool _S873 = spatialJob_0(_S869, _S872, &shift_job_0, true);
        Shift shifted_1;
        if(_S873)
        {
            Domain _S874 = (&shift_job_0)->dom;
            Reservoir _S875 = (&shift_job_0)->r;
            Shift _S876 = passShift_0(&_S874, &_S875);
            shifted_1 = _S876;
        }
        else
        {
            shifted_1 = _S871;
        }
        fcptStoreShiftData((_S869), (_S872), (make_uint4 (asuint_1(shifted_1.f).x, asuint_1(shifted_1.f).y, asuint_1(shifted_1.f).z, (F32_asuint((shifted_1.jac))))));
    }
    return;
}

static __device__ void restir_prepass_0(uint3  global_invocation_id_3, uint local_invocation_index_5)
{
    uint2  _S877 = uint2 {global_invocation_id_3.x, global_invocation_id_3.y};
    int2  _S878 = make_int2 ((int)_S877.x, (int)_S877.y);
    FixedArray<uint, 3>  _S879;
    spatialBins_0(_S878, &_S879);
    FixedArray<uint, 3>  _S880 = _S879;
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
        bool _S881 = (_S880[t_17]) == 40U;
        if(_S881)
        {
            fcptStoreShiftData((_S878), (t_17), (make_uint4 (0U)));
        }
        uint t_18 = t_17 + 1U;
        t_17 = t_18;
    }
    FixedArray<uint, 3>  _S882 = _S880;
    queueShifts_0(_S878, &_S882, global_invocation_id_3, local_invocation_index_5);
    return;
}

static __device__ void restir_count_0(uint3  global_invocation_id_4, uint local_invocation_index_6)
{
    uint2  _S883 = uint2 {global_invocation_id_4.x, global_invocation_id_4.y};
    int2  _S884 = make_int2 ((int)_S883.x, (int)_S883.y);
    FixedArray<uint, 3>  _S885;
    spatialBins_0(_S884, &_S885);
    FixedArray<uint, 3>  _S886 = _S885;
    countShifts_0(&_S886, local_invocation_index_6);
    return;
}

static __device__ void restir_temporal_shift_0(uint3  workgroup_id_2, uint local_invocation_index_7)
{
    uint _S887 = queuedShift_0(workgroup_id_2, local_invocation_index_7);
    bool _S888 = _S887 != 4294967295U;
    if(_S888)
    {
        uint2  _S889 = make_uint2 (_S887, _S887 >> 14U) & make_uint2 (16383U);
        int2  _S890 = make_int2 ((int)_S889.x, (int)_S889.y);
        ShiftJob _S891 = (ShiftJob{});
        ShiftJob shift_job_1 = _S891;
        Shift _S892 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
        uint _S893 = _S887 >> 28U;
        bool _S894 = temporalJob_0(_S890, _S893, &shift_job_1, true);
        Shift shifted_2;
        if(_S894)
        {
            if(_S893 == 1U)
            {
                Shift _S895 = (fcptShiftPrevious(((&shift_job_1)->dom), ((&shift_job_1)->r)));
                shifted_2 = _S895;
            }
            else
            {
                Domain _S896 = (&shift_job_1)->dom;
                Reservoir _S897 = (&shift_job_1)->r;
                Shift _S898 = passShift_0(&_S896, &_S897);
                shifted_2 = _S898;
            }
        }
        else
        {
            shifted_2 = _S892;
        }
        fcptStoreTemporalShift((_S890), (_S893), (make_uint4 (asuint_1(shifted_2.f).x, asuint_1(shifted_2.f).y, asuint_1(shifted_2.f).z, (F32_asuint((shifted_2.jac))))));
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
        bool _S903 = (_S902[t_19]) == 40U;
        if(_S903)
        {
            fcptStoreTemporalShift((_S900), (t_19), (make_uint4 (0U)));
        }
        uint t_20 = t_19 + 1U;
        t_19 = t_20;
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

static __device__ float interpolate_0(float a_10, float b_6, float t_21)
{
    return a_10 + (b_6 - a_10) * t_21;
}

__device__ float confidenceCap(float duplicated_0)
{
    float _S916 = interpolate_0(20.0f, 1.0f, (F32_pow((duplicated_0), (0.10000000149011612f))));
    return _S916;
}

__device__ float2  temporalWeights(float c_2, float p_c_1, float c_t_0, float p_t_0, float g_previous_0, float g_current_0)
{
    float _S917 = c_2 * p_c_1;
    float _S918 = c_t_0 * p_t_0;
    return make_float2 (_S917 / (_S917 + c_t_0 * g_previous_0), _S918 / (_S918 + c_2 * g_current_0));
}

static __device__ void restir_temporal_0(uint3  global_invocation_id_7)
{
    uint2  _S919 = uint2 {global_invocation_id_7.x, global_invocation_id_7.y};
    int2  _S920 = make_int2 ((int)_S919.x, (int)_S919.y);
    float3  _S921 = make_float3 (0.0f);
    FKHit _S922 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S923 = Domain_x24init_0(_S921, _S921, &_S922, 0.0f, 0.0f);
    Domain dom_5 = _S923;
    bool _S924 = (fcptCurrentDomain((_S920), (&dom_5)));
    bool _S925 = !_S924;
    if(_S925)
    {
        Reservoir _S926 = (Reservoir{});
        fcptStoreReservoirTemporal((_S920), (_S926), ((&dom_5)->hit));
        return;
    }
    Reservoir _S927 = (fcptLoadReservoirInitial((_S920)));
    bool _S928 = (fcptSceneUnchanged());
    int2  _S929;
    if(_S928)
    {
        int2  _S930 = sampleNeighbor_0(_S920, _S927.seed);
        _S929 = _S930;
    }
    else
    {
        int2  _S931 = (fcptLoadTemporalNeighbor((_S920)));
        _S929 = _S931;
    }
    bool _S932 = (_S929.x) >= int(0);
    Reservoir r_5;
    if(_S932)
    {
        Reservoir _S933 = (fcptLoadReservoirPrevious((_S929)));
        uint4  _S934 = (fcptDuplication((_S929)));
        float _S935 = (U32_asfloat((_S934.x)));
        uint _S936 = (fcptRestirDecorrelation());
        bool _S937 = _S936 == 1U;
        float _S938 = _slang_select(_S937, _S935,0.0f);
        float _S939 = confidenceCap(_S938);
        float _S940 = (F32_min((_S933.c), (_S939)));
        bool _S941 = (fcptSceneUnchanged());
        float4  _S942;
        if(_S941)
        {
            _S942 = make_float4 (_S933.f.x, _S933.f.y, _S933.f.z, 1.0f);
        }
        else
        {
            uint4  _S943 = (fcptTemporalShift((_S920), (0U)));
            _S942 = asfloat_0(_S943);
        }
        Domain own_1 = _S923;
        bool _S944;
        if(_S941)
        {
            _S944 = true;
        }
        else
        {
            bool _S945 = (fcptPreviousScenes());
            bool _S946 = !_S945;
            if(_S946)
            {
                _S944 = (_S927.w) > 0.0f;
            }
            else
            {
                _S944 = false;
            }
            if(_S944)
            {
                bool _S947 = (fcptStoredDomainInitial((_S920), (_S927.seed), (&own_1)));
                _S944 = _S947;
            }
            else
            {
                _S944 = false;
            }
            if(_S944)
            {
                Domain _S948 = (fcptPreviousDomain((_S929), (_S927.seed)));
                Domain _S949 = _S948;
                Domain _S950 = own_1;
                bool _S951 = sameDomain_0(&_S949, &_S950);
                _S944 = _S951;
            }
            else
            {
                _S944 = false;
            }
        }
        float4  _S952;
        if(_S944)
        {
            _S952 = make_float4 (_S927.f.x, _S927.f.y, _S927.f.z, 1.0f);
        }
        else
        {
            uint4  _S953 = (fcptTemporalShift((_S920), (1U)));
            _S952 = asfloat_0(_S953);
        }
        float _S954 = rgb_to_greyscale(_S927.f);
        float _S955 = rgb_to_greyscale(_S933.f);
        Selection _S956 = (Selection{});
        Selection sel_6 = _S956;
        uint _S957 = (fcptFrame());
        uint _S958 = hash(_S957);
        uint _S959 = global_invocation_id_7.x;
        uint2  _S960 = (fcptRenderSize());
        uint _S961 = stream(_S958, _S959 + _S960.x * global_invocation_id_7.y);
        uint _S962 = stream(_S961, 194U);
        (&sel_6)->random_state = _S962;
        float4  _S963 = _S952;
        float _S964 = rgb_to_greyscale(float3 {_S963.x, _S963.y, _S963.z});
        float4  _S965 = _S942;
        float3  _S966 = float3 {_S965.x, _S965.y, _S965.z};
        float _S967 = rgb_to_greyscale(_S966);
        float2  _S968 = temporalWeights(_S927.c, _S954, _S940, _S955, _S964, _S967);
        offerShifted(&sel_6, _S927, Shift_x24init_0(_S927.f, 1.0f), _S968.x);
        offerShifted(&sel_6, _S933, Shift_x24init_0(_S966, _S942.w), _S968.y);
        Reservoir _S969 = finalize(sel_6, _S927.c + _S940);
        r_5 = _S969;
    }
    else
    {
        r_5 = _S927;
    }
    fcptStoreReservoirTemporal((_S920), (r_5), ((&dom_5)->hit));
    return;
}

static __device__ void restir_initial_0(uint3  global_invocation_id_8)
{
    uint2  _S970 = uint2 {global_invocation_id_8.x, global_invocation_id_8.y};
    int2  _S971 = make_int2 ((int)_S970.x, (int)_S970.y);
    float3  _S972 = make_float3 (0.0f);
    float2  _S973 = make_float2 (0.0f);
    FKHit _S974 = Hit_x24init_0(_S973, 0U, 0U, 0U, 0.0f);
    Domain _S975 = Domain_x24init_0(_S972, _S972, &_S974, 0.0f, 0.0f);
    Domain dom_6 = _S975;
    bool _S976 = (fcptCurrentDomain((_S971), (&dom_6)));
    bool _S977 = !_S976;
    if(_S977)
    {
        Reservoir _S978 = (Reservoir{});
        fcptStoreReservoirInitial((_S971), (_S978), ((&dom_6)->hit));
        return;
    }
    uint _S979 = (fcptFrame());
    uint _S980 = hash(_S979);
    uint _S981 = global_invocation_id_8.x;
    uint2  _S982 = (fcptRenderSize());
    uint _S983 = stream(_S980, _S981 + _S982.x * global_invocation_id_8.y);
    Selection _S984 = (Selection{});
    Selection initial_0 = _S984;
    uint _S985 = stream(_S983, 193U);
    (&initial_0)->random_state = _S985;
    bool _S986 = (fcptRestirUsed());
    bool _S987 = !_S986;
    (&initial_0)->sums = _S987;
    uint _S988 = stream(_S983, 0U);
    (&(&initial_0)->r)->seed = _S988;
    FKHit _S989 = Hit_x24init_0(_S973, 4294967295U, 0U, 0U, 0.0f);
    uint _S990 = (fcptSamples());
    float _S991 = 1.0f / float(_S990);
    FKHit hit_2 = _S989;
    uint i_13 = 0U;
    for(;;)
    {
        uint _S992 = (fcptSamples());
        if(i_13 < _S992)
        {
        }
        else
        {
            break;
        }
        Reservoir _S993 = (Reservoir{});
        Reservoir r_6 = _S993;
        uint _S994 = stream(_S983, i_13);
        (&r_6)->seed = _S994;
        Domain path_0 = _S975;
        bool _S995 = (fcptStoredDomainInitial((_S971), ((&r_6)->seed), (&path_0)));
        bool _S996 = !_S995;
        if(_S996)
        {
            fcptMissed((_S971), (path_0), (_S991));
            uint i_14 = i_13 + 1U;
            i_13 = i_14;
            continue;
        }
        Domain _S997 = path_0;
        Reservoir _S998 = r_6;
        Shift _S999 = passWalk_0(&_S997, &_S998, false, _S991, &initial_0);
        bool _S1000 = ((&(&initial_0)->r)->seed) == ((&r_6)->seed);
        FKHit hit_3;
        if(_S1000)
        {
            FKHit _S1001 = (&path_0)->hit;
            hit_3 = _S1001;
        }
        else
        {
            hit_3 = hit_2;
        }
        hit_2 = hit_3;
        uint i_14 = i_13 + 1U;
        i_13 = i_14;
    }
    float3  _S1002 = (&initial_0)->glow;
    float3  _S1003 = (&initial_0)->color;
    bool _S1004 = (&initial_0)->sums;
    float3  _S1005 = _slang_select(_S1004, _S1003,_S972);
    fcptAddColor((_S971), (make_float4 ((_S1002 + _S1005).x, (_S1002 + _S1005).y, (_S1002 + _S1005).z, 1.0f)));
    Reservoir _S1006 = finalize(initial_0, 1.0f);
    fcptStoreReservoirInitial((_S971), (_S1006), (hit_2));
    return;
}

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_4, float3  origin_5, float3  smooth_n_3, float3  start_6)
{
    NEEVertex _S1007;
    (&_S1007)->none = none_0;
    (&_S1007)->pdf = pdf_4;
    (&_S1007)->origin = origin_5;
    (&_S1007)->smooth_n = smooth_n_3;
    (&_S1007)->start = start_6;
    return _S1007;
}

struct Vertex
{
    bool rough;
    uint lobe;
    float pdf;
    float cos;
    bool inside;
};

static __device__ Vertex Vertex_x24init_0(bool rough_0, uint lobe_7, float pdf_5, float cos_0, bool inside_0)
{
    Vertex _S1008;
    (&_S1008)->rough = rough_0;
    (&_S1008)->lobe = lobe_7;
    (&_S1008)->pdf = pdf_5;
    (&_S1008)->cos = cos_0;
    (&_S1008)->inside = inside_0;
    return _S1008;
}

static __device__ float freeFlight_0(float u_1, float sigma_0)
{
    return - (F32_log((1.0f - u_1))) / sigma_0;
}

static __device__ float3  exp_0(float3  x_21)
{
    float3  result_10;
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
        *_slang_vector_get_element_ptr(&result_10, i_15) = (F32_exp((_slang_vector_get_element(x_21, i_15))));
        i_15 = i_15 + int(1);
    }
    return result_10;
}

static __device__ float3  flightWeight_0(float3  scatter_0, float3  extinction_0, float sigma_1, float distance_2, bool scatters_0)
{
    float3  _S1009 = exp_0((make_float3 (sigma_1) - extinction_0) * make_float3 (distance_2));
    float3  _S1010 = scatter_0 * _S1009 / make_float3 (sigma_1);
    float3  _S1011 = _slang_select(scatters_0, _S1010,_S1009);
    return _S1011;
}

static __device__ bool scatterSampled_0(bool replay_1, uint b_7, uint stop_0, bool varying_0)
{
    bool _S1012 = !replay_1;
    bool _S1013;
    if(_S1012)
    {
        _S1013 = true;
    }
    else
    {
        bool _S1014 = b_7 == stop_0;
        if(_S1014)
        {
            _S1013 = !varying_0;
        }
        else
        {
            _S1013 = false;
        }
    }
    return _S1013;
}

static __device__ uint arrivalLobe_0(uint b_8, uint prev_lobe_0)
{
    bool _S1015 = b_8 > 0U;
    uint _S1016 = _slang_select(_S1015, prev_lobe_0,3U);
    return _S1016;
}

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_0, uint depth_1, uint lobe_8, bool surface_4, float length_2, float width_1, FKHit * own_2, bool fiber_0)
{
    ShadowContext _S1017;
    (&_S1017)->extinction_behind = extinction_behind_0;
    (&_S1017)->extinction_front = extinction_front_0;
    (&_S1017)->fillings = fillings_0;
    (&_S1017)->side = side_0;
    (&_S1017)->depth = depth_1;
    (&_S1017)->lobe = lobe_8;
    (&_S1017)->surface = surface_4;
    (&_S1017)->length = length_2;
    (&_S1017)->width = width_1;
    (&_S1017)->own = *own_2;
    (&_S1017)->fiber = fiber_0;
    return _S1017;
}

static __device__ float phaseHG_0(float g_0, float mu_0)
{
    bool _S1018 = (F32_abs((g_0))) < 0.00100000004749745f;
    if(_S1018)
    {
        return 0.07957746833562851f;
    }
    float _S1019 = g_0 * g_0;
    return (1.0f - _S1019) * 0.25f * 0.31830987334251404f / (F32_pow((1.0f + _S1019 - 2.0f * g_0 * mu_0), (1.5f)));
}

__device__ float3  safeDivide(float3  a_11, float3  b_9)
{
    float3  _S1020 = a_11 / b_9;
    float3  _S1021 = make_float3 (0.0f);
    bool3  _S1022 = b_9 == _S1021;
    float3  _S1023 = _slang_select(_S1022, _S1021,_S1020);
    return _S1023;
}

static __device__ uint insertBits_0(uint e_2, uint newbits_0, uint offset_1, uint count_6)
{
    uint _S1024 = (1U << count_6) - 1U;
    return (e_2 & (~(_S1024 << offset_1))) | ((newbits_0 & _S1024) << offset_1);
}

__device__ Reservoir withEnd(Reservoir r_7, uint end_type_0, uint end_0, float3  f_6)
{
    Reservoir candidate_2 = r_7;
    uint _S1025 = insertBits_0(r_7.path, end_0, 0U, 5U);
    uint _S1026 = insertBits_0(_S1025, end_type_0, 12U, 3U);
    (&candidate_2)->path = _S1026;
    (&candidate_2)->f = f_6;
    return candidate_2;
}

__device__ float survivalProbability(float3  throughput_1, float density_1)
{
    return (F32_min(((F32_max(((F32_max((throughput_1.x), ((F32_max((throughput_1.y), (throughput_1.z)))))) / density_1), (0.0f)))), (1.0f)));
}

static __device__ float3  isotropic_0(uint random_state_9)
{
    Random _S1027 = pcg(random_state_9);
    Random _S1028 = pcg(_S1027.state);
    float _S1029 = 1.0f - 2.0f * _S1027.value;
    float _S1030 = (F32_sqrt(((F32_max((1.0f - _S1029 * _S1029), (0.0f))))));
    float _S1031 = 6.28318548202514648f * _S1028.value;
    return make_float3 (_S1030 * (F32_cos((_S1031))), _S1030 * (F32_sin((_S1031))), _S1029);
}

static __device__ float3  samplePhase_0(float g_1, float3  dir_9, uint random_state_10, float * pdf_6)
{
    bool _S1032 = (F32_abs((g_1))) < 0.00100000004749745f;
    if(_S1032)
    {
        *pdf_6 = 0.07957746833562851f;
        float3  _S1033 = isotropic_0(random_state_10);
        return _S1033;
    }
    Random _S1034 = pcg(random_state_10);
    Random _S1035 = pcg(_S1034.state);
    float _S1036 = g_1 * g_1;
    float _S1037 = 2.0f * g_1;
    float _S1038 = (1.0f - _S1036) / (1.0f - g_1 + _S1037 * _S1034.value);
    float _S1039 = clamp_1((1.0f + _S1036 - _S1038 * _S1038) / _S1037, -1.0f, 1.0f);
    float _S1040 = (F32_sqrt(((F32_max((1.0f - _S1039 * _S1039), (0.0f))))));
    float _S1041 = 6.28318548202514648f * _S1035.value;
    float _S1042 = phaseHG_0(g_1, _S1039);
    *pdf_6 = _S1042;
    float3  _S1043 = tangentToWorld(make_float3 (_S1040 * (F32_cos((_S1041))), _S1039, _S1040 * (F32_sin((_S1041)))), dir_9);
    float3  _S1044 = ((((_S1043)) * make_float3(rnorm3df(((_S1043)).x, ((_S1043)).y, ((_S1043)).z))));
    return _S1044;
}

static __device__ Vertex scatteredVertex_0(bool is_inside_4)
{
    return Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_4);
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_0, float3  emissive_0, float roughness_0, float metallic_0, float transmission_0, float ior_0, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_2, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_2, float velvet_0, float3  toon_3)
{
    BSDFMaterial _S1045;
    (&_S1045)->albedo = albedo_0;
    (&_S1045)->emissive = emissive_0;
    (&_S1045)->roughness = roughness_0;
    (&_S1045)->metallic = metallic_0;
    (&_S1045)->transmission = transmission_0;
    (&_S1045)->ior = ior_0;
    (&_S1045)->absorption = absorption_0;
    (&_S1045)->specular_tint = specular_tint_0;
    (&_S1045)->specular_level = specular_level_0;
    (&_S1045)->translucent = translucent_0;
    (&_S1045)->sheen = sheen_2;
    (&_S1045)->sheen_roughness = sheen_roughness_0;
    (&_S1045)->anisotropy = anisotropy_0;
    (&_S1045)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S1045)->tangent = tangent_2;
    (&_S1045)->velvet = velvet_0;
    (&_S1045)->toon = toon_3;
    return _S1045;
}

static __device__ FKMedium Medium_x24init_0(float3  scatter_1, float3  extinction_1, float g_2)
{
    FKMedium _S1046;
    (&_S1046)->scatter = scatter_1;
    (&_S1046)->extinction = extinction_1;
    (&_S1046)->g = g_2;
    return _S1046;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_7, bool skip_0, uint random_state_11, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S1047;
    (&_S1047)->smooth_n = smooth_n_4;
    (&_S1047)->geometry_n = geometry_n_2;
    (&_S1047)->geometry_offset = geometry_offset_2;
    (&_S1047)->material = *material_7;
    (&_S1047)->skip = skip_0;
    (&_S1047)->random_state = random_state_11;
    (&_S1047)->coverage = coverage_0;
    (&_S1047)->encloses = encloses_0;
    (&_S1047)->volume = *volume_0;
    (&_S1047)->fills = fills_0;
    (&_S1047)->hair = hair_0;
    return _S1047;
}

static __device__ FKSurface emitting_0(FKSurface * surface_5, bool top_0)
{
    FKSurface lower_0 = *surface_5;
    float3  _S1048 = (&surface_5->material)->emissive;
    float3  _S1049 = make_float3 (0.0f);
    bool _S1050 = !top_0;
    float3  _S1051 = _slang_select(_S1050, _S1049,_S1048);
    (&(&lower_0)->material)->emissive = _S1051;
    return lower_0;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_6, float u_2)
{
    float _S1052 = surface_6->coverage;
    bool _S1053 = u_2 < _S1052;
    if(_S1053)
    {
        return *surface_6;
    }
    float3  _S1054 = make_float3 (0.0f);
    float3  _S1055 = make_float3 (1.0f);
    BSDFMaterial _S1056 = Material_x24init_0(_S1054, _S1054, 0.0f, 0.0f, 0.0f, 0.0f, _S1054, _S1055, 1.0f, _S1054, _S1054, 0.5f, 0.0f, 0.0f, _S1054, 0.0f, _S1054);
    BSDFMaterial material_8 = _S1056;
    (&material_8)->albedo = _S1055;
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
    bool _S1057 = transmission_1 > 0.0f;
    bool _S1058;
    if(_S1057)
    {
        _S1058 = true;
    }
    else
    {
        _S1058 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S1059;
    if(_S1058)
    {
        _S1059 = 1.0f;
    }
    else
    {
        _S1059 = -1.0f;
    }
    return _S1059;
}

static __device__ bool arrivesBehind_0(float3  dir_10, float3  n_10)
{
    return (dot_0(dir_10, n_10)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_7, float3  dir_11)
{
    float3  _S1060 = surface_7->geometry_n;
    float _S1061 = facingSign((&surface_7->material)->transmission, surface_7->geometry_n, dir_11);
    FKSurface faced_0 = *surface_7;
    float3  _S1062 = surface_7->smooth_n * make_float3 (_S1061);
    (&faced_0)->smooth_n = _S1062;
    float3  _S1063 = _S1060 * make_float3 (_S1061);
    (&faced_0)->geometry_n = _S1063;
    return faced_0;
}

static __device__ float3  max_0(float3  x_22, float3  y_7)
{
    float3  result_11;
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
        *_slang_vector_get_element_ptr(&result_11, i_16) = (F32_max((_slang_vector_get_element(x_22, i_16)), (_slang_vector_get_element(y_7, i_16))));
        i_16 = i_16 + int(1);
    }
    return result_11;
}

static __device__ float3  log_0(float3  x_23)
{
    float3  result_12;
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
        *_slang_vector_get_element_ptr(&result_12, i_17) = (F32_log((_slang_vector_get_element(x_23, i_17))));
        i_17 = i_17 + int(1);
    }
    return result_12;
}

__device__ float3  beerLambert(float distance_3, float3  absorption_1)
{
    float3  _S1064 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_3) * log_0(_S1064));
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
    bool _S1065;
    if(open_0)
    {
        _S1065 = prev_rough_0;
    }
    else
    {
        _S1065 = false;
    }
    if(_S1065)
    {
        _S1065 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S1065 = false;
    }
    return _S1065;
}

__device__ float2  vertexEta(BSDFMaterial material_9, float n_dot_v_0)
{
    bool _S1066 = n_dot_v_0 < 0.0f;
    float _S1067 = _slang_select(_S1066, material_9.ior,1.0f);
    float _S1068 = _slang_select(_S1066, 1.0f,material_9.ior);
    return make_float2 (_S1067, _S1068);
}

__device__ bool neeDecision(BSDFMaterial material_10, float n_dot_v_1, float eta_i_5, float eta_o_5)
{
    float _S1069 = fresnel((F32_abs((n_dot_v_1))), eta_i_5, eta_o_5);
    float3  _S1070 = mix_0(make_float3 (_S1069), material_10.albedo, material_10.metallic);
    float _S1071 = rgb_to_greyscale(_S1070);
    float _S1072 = (F32_max(((1.0f - _S1071) * (1.0f - material_10.metallic) * (1.0f - material_10.transmission)), (0.0f)));
    bool _S1073 = _S1072 > 0.03999999910593033f;
    bool _S1074;
    if(_S1073)
    {
        _S1074 = true;
    }
    else
    {
        _S1074 = (material_10.roughness) > 0.20000000298023224f;
    }
    return _S1074;
}

static __device__ bool isTranslucent_0(BSDFMaterial * material_11)
{
    float _S1075 = rgb_to_greyscale(material_11->translucent);
    return _S1075 > 0.0f;
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
    MediumSides _S1076;
    (&_S1076)->behind = *behind_0;
    (&_S1076)->front = *front_0;
    (&_S1076)->fillings = fillings_1;
    (&_S1076)->face = face_1;
    return _S1076;
}

static __device__ MediumSides mediumSides_0(FKSurface * surface_8, FKMedium * medium_0, uint filling_0, float3  dir_12, FKMedium * outside_0)
{
    float3  _S1077 = surface_8->geometry_n;
    MediumSides _S1078 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_8->geometry_n);
    MediumSides sides_0 = _S1078;
    bool _S1079 = surface_8->encloses;
    if(_S1079)
    {
        (&sides_0)->behind = surface_8->volume;
        *&((&(&sides_0)->fillings)->x) = surface_8->fills;
        bool _S1080 = (dot_0(dir_12, _S1077)) > 0.0f;
        if(_S1080)
        {
            (&sides_0)->front = *outside_0;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_9, bool turned_0, float3  extinction_2, uint filling_1, float3  dir_13, uint depth_2, uint lobe_9, float length_3, float width_2, FKHit * own_3, bool fiber_1, FKMedium * outside_1)
{
    float3  _S1081 = surface_9->geometry_n;
    ShadowContext _S1082 = ShadowContext_x24init_0(extinction_2, extinction_2, make_uint2 (filling_1), surface_9->geometry_n, depth_2, lobe_9, true, length_3, width_2, own_3, fiber_1);
    bool _S1083 = surface_9->encloses;
    ShadowContext context_4;
    if(_S1083)
    {
        FKSurface faced_1 = *surface_9;
        float3  _S1084 = - _S1081;
        float3  _S1085 = _slang_select(turned_0, _S1084,_S1081);
        (&faced_1)->geometry_n = _S1085;
        FKMedium _S1086 = Medium_x24init_0(make_float3 (0.0f), extinction_2, 0.0f);
        FKSurface _S1087 = faced_1;
        FKMedium _S1088 = _S1086;
        MediumSides _S1089 = mediumSides_0(&_S1087, &_S1088, filling_1, dir_13, outside_1);
        ShadowContext _S1090 = ShadowContext_x24init_0(_S1089.behind.extinction, _S1089.front.extinction, _S1089.fillings, _S1081, depth_2, lobe_9, true, length_3, width_2, own_3, fiber_1);
        if(turned_0)
        {
            uint2  _S1091 = _S1089.fillings;
            ShadowContext _S1092 = ShadowContext_x24init_0(_S1089.front.extinction, _S1089.behind.extinction, uint2 {_S1091.y, _S1091.x}, _S1081, depth_2, lobe_9, true, length_3, width_2, own_3, fiber_1);
            context_4 = _S1092;
        }
        else
        {
            context_4 = _S1090;
        }
    }
    else
    {
        context_4 = _S1082;
    }
    return context_4;
}

static __device__ bool any_1(bool3  x_24)
{
    bool result_13 = false;
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
        if(result_13)
        {
            result_13 = true;
        }
        else
        {
            result_13 = (bool((_slang_vector_get_element(x_24, i_18))));
        }
        i_18 = i_18 + int(1);
    }
    return result_13;
}

__device__ __forceinline__ float3  BSDF(float3  in_dir_5, float3  out_dir_1, float3  n_11, float3  g_n_0, BSDFMaterial material_12, float eta_i_6, float eta_o_6, uint random_state_12)
{
    float3  _S1093 = negate_0(in_dir_5);
    bool _S1094 = (dot_0(g_n_0, _S1093) * dot_0(g_n_0, out_dir_1)) > 0.0f;
    if(_S1094)
    {
        SampleBSDF _S1095 = connectBSDF(in_dir_5, out_dir_1, n_11, material_12, eta_i_6, eta_o_6, 0U, random_state_12);
        SampleBSDF _S1096 = connectBSDF(in_dir_5, out_dir_1, n_11, material_12, eta_i_6, eta_o_6, 2U, random_state_12);
        SampleBSDF _S1097 = connectBSDF(in_dir_5, out_dir_1, n_11, material_12, eta_i_6, eta_o_6, 4U, random_state_12);
        return _S1095.throughput * make_float3 (_S1095.pdf) + _S1096.throughput * make_float3 (_S1096.pdf) + _S1097.throughput * make_float3 (_S1097.pdf);
    }
    SampleBSDF _S1098 = connectBSDF(in_dir_5, out_dir_1, n_11, material_12, eta_i_6, eta_o_6, 1U, random_state_12);
    return _S1098.throughput * make_float3 (_S1098.pdf);
}

__device__ float3  translucentCorrection(float3  in_dir_6, float3  out_dir_2, float3  n_12, float3  g_n_1, BSDFMaterial material_13, float eta_i_7, float eta_o_7, uint random_state_13)
{
    float _S1099 = dot_0(n_12, out_dir_2);
    float3  _S1100 = negate_0(in_dir_6);
    bool _S1101 = (_S1099 * dot_0(n_12, _S1100)) < 0.0f;
    SampleBSDF _S1102 = connectBSDF(in_dir_6, out_dir_2, n_12, material_13, eta_i_7, eta_o_7, 0U, random_state_13);
    float3  _S1103 = negate_0(in_dir_6);
    bool _S1104 = (dot_0(g_n_1, _S1103) * dot_0(g_n_1, out_dir_2)) > 0.0f;
    float3  _S1105 = make_float3 (0.0f);
    float3  _S1106 = _S1102.throughput * make_float3 (_S1102.pdf);
    float _S1107 = _slang_select(_S1104, -1.0f,1.0f);
    float3  _S1108 = _S1106 * make_float3 (_S1107);
    float3  _S1109 = _slang_select(_S1101, _S1108,_S1105);
    return _S1109;
}

__device__ float3  translucentBSDF(float3  in_dir_7, float3  out_dir_3, float3  n_13, float3  g_n_2, BSDFMaterial material_14, float eta_i_8, float eta_o_8, uint random_state_14)
{
    float3  _S1110 = BSDF(in_dir_7, out_dir_3, n_13, g_n_2, material_14, eta_i_8, eta_o_8, random_state_14);
    float3  _S1111 = translucentCorrection(in_dir_7, out_dir_3, n_13, g_n_2, material_14, eta_i_8, eta_o_8, random_state_14);
    return _S1110 + _S1111;
}

static __device__ __forceinline__ float3  lightBSDF_0(float3  in_dir_8, TreeSample * light_2, float3  smooth_n_5, float3  geometry_n_4, BSDFMaterial * material_15, float eta_i_9, float eta_o_9, bool competing_1, uint random_state_15)
{
    bool _S1112 = !competing_1;
    bool _S1113;
    if(_S1112)
    {
        _S1113 = true;
    }
    else
    {
        _S1113 = (light_2->density) == 0.0f;
    }
    if(_S1113)
    {
        bool _S1114 = isTranslucent_0(material_15);
        if(_S1114)
        {
            float3  _S1115 = translucentBSDF(in_dir_8, light_2->dir, smooth_n_5, geometry_n_4, *material_15, eta_i_9, eta_o_9, random_state_15);
            return _S1115 * light_2->radiance;
        }
        float3  _S1116 = BSDF(in_dir_8, light_2->dir, smooth_n_5, geometry_n_4, *material_15, eta_i_9, eta_o_9, random_state_15);
        return _S1116 * light_2->radiance;
    }
    float3  _S1117 = light_2->dir;
    bool _S1118 = (dot_0(geometry_n_4, - in_dir_8) * dot_0(geometry_n_4, light_2->dir)) <= 0.0f;
    float3  _S1119 = neeBSDF(in_dir_8, _S1117, smooth_n_5, *material_15, eta_i_9, eta_o_9, _S1118, light_2->density, true, random_state_15);
    return _S1119 * light_2->radiance * make_float3 (light_2->density);
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

static __device__ float toonInvert_0(float target_2, ToonLobe_0 * lobe_10)
{
    bool _S1125 = lobe_10->glossy_0;
    float t_22;
    if(lobe_10->glossy_0)
    {
        t_22 = (F32_acos((clamp_1(1.0f - target_2, -1.0f, 1.0f))));
    }
    else
    {
        t_22 = (F32_asin(((F32_min(((F32_sqrt((2.0f * target_2)))), (1.0f))))));
    }
    float _S1126 = lobe_10->a_7;
    if(t_22 < (lobe_10->a_7))
    {
    }
    else
    {
        t_22 = (_S1126 + lobe_10->b_3) / 2.0f;
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
        float _S1127 = toonProfile_0(t_22, lobe_10);
        float _S1128 = _S1127 * (F32_sin((t_22)));
        float _S1129;
        if(_S1125)
        {
            _S1129 = 1.0f;
        }
        else
        {
            _S1129 = (F32_cos((t_22)));
        }
        float _S1130 = _S1128 * _S1129;
        float _S1131 = toonIntegral_0(t_22, lobe_10);
        float _S1132 = (_S1131 - target_2) / _S1130;
        bool _S1133 = _S1130 > 0.0f;
        float _S1134 = _slang_select(_S1133, _S1132,0.0f);
        float _S1135 = clamp_1(t_22 - _S1134, 0.0f, lobe_10->b_3);
        int k_1 = k_0 + int(1);
        t_22 = _S1135;
        k_0 = k_1;
    }
    return t_22;
}

__device__ float3  sampleToon(float3  v_7, float3  n_14, float3  toon_4, float u_1_0, float u_2_0)
{
    ToonLobe_0 _S1136 = toonLobe_0(toon_4);
    ToonLobe_0 _S1137 = _S1136;
    float _S1138 = toonIntegral_0(_S1136.b_3, &_S1137);
    float _S1139 = u_1_0 * _S1138;
    ToonLobe_0 _S1140 = _S1136;
    float _S1141 = toonInvert_0(_S1139, &_S1140);
    float _S1142 = 6.28318548202514648f * u_2_0;
    float3  _S1143;
    if(_S1136.glossy_0)
    {
        float3  _S1144 = make_float3 (2.0f * dot_0(n_14, v_7)) * n_14 - v_7;
        float3  _S1145 = ((((_S1144)) * make_float3(rnorm3df(((_S1144)).x, ((_S1144)).y, ((_S1144)).z))));
        _S1143 = _S1145;
    }
    else
    {
        _S1143 = n_14;
    }
    float _S1146 = (F32_sin((_S1141)));
    float3  _S1147 = tangentToWorld(make_float3 (_S1146 * (F32_cos((_S1142))), (F32_cos((_S1141))), _S1146 * (F32_sin((_S1142)))), _S1143);
    return _S1147;
}

static __device__ float3  reflect_0(float3  i_19, float3  n_15)
{
    return i_19 - make_float3 (2.0f * dot_0(n_15, i_19)) * n_15;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_9, float3  n_16, BSDFMaterial material_16, float eta_i_10, float eta_o_10, uint random_init_1, float2  screen_space_0)
{
    uint random_state_16 = random_init_1;
    float3  _S1148 = negate_0(in_dir_9);
    float _S1149 = dot_0(n_16, _S1148);
    float _S1150 = sign_0(_S1149);
    float3  n_i_5 = n_16 * make_float3 (_S1150);
    float _S1151 = (F32_abs((_S1149)));
    float _S1152 = material_16.roughness;
    float _S1153 = _S1152 * _S1152;
    AnisotropicFrame _S1154 = anisotropicFrame(material_16, n_i_5);
    float3  _S1155 = sampleHalfVector(_S1148, n_i_5, _S1153, _S1154, &random_state_16);
    BSDFLobes _S1156 = bsdfLobes(in_dir_9, _S1148, n_i_5, _S1155, material_16, eta_i_10, eta_o_10, _S1154);
    BSDFLobes lobes_4 = _S1156;
    float _S1157 = translucentShare(material_16);
    (&lobes_4)->translucent_share = _S1157;
    float3  _S1158 = make_float3 (1.0f);
    SampleBSDF _S1159 = SampleBSDF_x24init_0(_S1158, _S1158, 0U, false, 0U, 0.0f);
    SampleBSDF sample_2 = _S1159;
    Random _S1160 = pcg(random_state_16);
    random_state_16 = _S1160.state;
    bool _S1161 = (_S1160.value) < ((&lobes_4)->p_sheen_velvet);
    if(_S1161)
    {
        Random _S1162 = pcg(random_state_16);
        Random _S1163 = pcg(_S1162.state);
        (&sample_2)->random_state = _S1163.state;
        float _S1164 = _S1162.value;
        float _S1165 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1164 * _S1164))))));
        float _S1166 = 6.28318548202514648f * _S1163.value;
        float3  _S1167 = tangentToWorld(make_float3 (_S1165 * (F32_cos((_S1166))), _S1162.value, _S1165 * (F32_sin((_S1166)))), n_i_5);
        (&sample_2)->unit_direction = _S1167;
        float3  _S1168 = lobeThroughput((&sample_2)->unit_direction, n_i_5, _S1153, material_16, lobes_4, 4U);
        (&sample_2)->throughput = _S1168;
        float _S1169 = lobeDensity(_S1162.value, 0.0f, _S1151, _S1153, lobes_4, eta_i_10, eta_o_10, 4U);
        (&sample_2)->pdf = _S1169;
        (&sample_2)->lobe = 4U;
        return sample_2;
    }
    float _S1170 = _S1160.value - (&lobes_4)->p_sheen_velvet;
    bool _S1171 = _S1170 < ((&lobes_4)->p_diffuse);
    if(_S1171)
    {
        Random _S1172 = pcg(random_state_16);
        Random _S1173 = pcg(_S1172.state);
        (&sample_2)->random_state = _S1173.state;
        float3  _S1174 = sampleCosWeightedHemisphere(_S1172.value, _S1173.value);
        bool _S1175 = ((&lobes_4)->toon_share) > 0.0f;
        if(_S1175)
        {
            bool _S1176 = _S1170 >= ((&lobes_4)->p_diffuse * (1.0f - (&lobes_4)->toon_share));
            bool _S1177 = _S1170 < ((&lobes_4)->p_diffuse * (1.0f - (&lobes_4)->toon_share) * (&lobes_4)->translucent_share);
            float _S1178 = _S1174.y;
            float _S1179 = - _S1178;
            float _S1180 = _slang_select(_S1177, _S1179,_S1178);
            float3  _S1181;
            if(_S1176)
            {
                float3  _S1182 = sampleToon(_S1148, n_i_5, material_16.toon, _S1172.value, _S1173.value);
                _S1181 = _S1182;
            }
            else
            {
                float3  _S1183 = tangentToWorld(make_float3 (_S1174.x, _S1180, _S1174.z), n_i_5);
                _S1181 = _S1183;
            }
            (&sample_2)->unit_direction = _S1181;
            float3  _S1184 = lobeThroughput((&sample_2)->unit_direction, n_i_5, _S1153, material_16, lobes_4, 0U);
            (&sample_2)->throughput = _S1184;
            float _S1185 = lobeDensity(dot_0(n_i_5, (&sample_2)->unit_direction), 0.0f, _S1151, _S1153, lobes_4, eta_i_10, eta_o_10, 0U);
            (&sample_2)->pdf = _S1185;
            bool _S1186 = (dot_0(n_i_5, (&sample_2)->unit_direction)) < 0.0f;
            (&sample_2)->refracted = _S1186;
            BSDFMaterial _S1187 = material_16;
            BSDFLobes _S1188 = lobes_4;
            toonMix_0(&sample_2, _S1148, n_i_5, &_S1187, &_S1188);
            return sample_2;
        }
        bool _S1189 = _S1170 < ((&lobes_4)->p_diffuse * (&lobes_4)->translucent_share);
        float _S1190 = _S1174.y;
        float _S1191 = - _S1190;
        float _S1192 = _slang_select(_S1189, _S1191,_S1190);
        float3  _S1193 = tangentToWorld(make_float3 (_S1174.x, _S1192, _S1174.z), n_i_5);
        (&sample_2)->unit_direction = _S1193;
        float3  _S1194 = lobeThroughput((&sample_2)->unit_direction, n_i_5, _S1153, material_16, lobes_4, 0U);
        (&sample_2)->throughput = _S1194;
        float _S1195 = lobeDensity(_S1192, 0.0f, _S1151, _S1153, lobes_4, eta_i_10, eta_o_10, 0U);
        (&sample_2)->pdf = _S1195;
        (&sample_2)->refracted = _S1189;
        return sample_2;
    }
    bool _S1196 = _S1170 < ((&lobes_4)->p_diffuse + (&lobes_4)->p_refract);
    if(_S1196)
    {
        (&sample_2)->unit_direction = (&lobes_4)->refracted;
        float _S1197 = lobeDensity(0.0f, dot_0((&sample_2)->unit_direction, _S1155), _S1151, _S1153, lobes_4, eta_i_10, eta_o_10, 1U);
        (&sample_2)->pdf = _S1197;
        float3  _S1198 = lobeThroughput((&sample_2)->unit_direction, n_i_5, _S1153, material_16, lobes_4, 1U);
        (&sample_2)->throughput = _S1198;
        (&sample_2)->random_state = random_state_16;
        (&sample_2)->refracted = true;
        (&sample_2)->lobe = 1U;
        return sample_2;
    }
    float3  _S1199 = reflect_0(in_dir_9, _S1155);
    float3  _S1200 = ((((_S1199)) * make_float3(rnorm3df(((_S1199)).x, ((_S1199)).y, ((_S1199)).z))));
    (&sample_2)->unit_direction = _S1200;
    float3  _S1201 = lobeThroughput((&sample_2)->unit_direction, n_i_5, _S1153, material_16, lobes_4, 2U);
    (&sample_2)->throughput = _S1201;
    (&sample_2)->random_state = random_state_16;
    (&sample_2)->lobe = 2U;
    float _S1202 = lobeDensity(0.0f, 0.0f, _S1151, _S1153, lobes_4, eta_i_10, eta_o_10, 2U);
    (&sample_2)->pdf = _S1202;
    return sample_2;
}

__device__ bool withinInverseFootprint(float pdf_7, bool diffuse_0, float prev_cos_0, float distance_5, float threshold_1)
{
    bool _S1203 = pdf_7 > 0.0f;
    bool _S1204;
    if(_S1203)
    {
        if(diffuse_0)
        {
            _S1204 = true;
        }
        else
        {
            _S1204 = (pdf_7 * prev_cos_0 / (distance_5 * distance_5) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S1204 = false;
    }
    return _S1204;
}

__device__ bool roughLobe(float pdf_8, bool diffuse_1, float roughness_1)
{
    bool _S1205 = pdf_8 > 0.0f;
    bool _S1206;
    if(_S1205)
    {
        if(diffuse_1)
        {
            _S1206 = true;
        }
        else
        {
            _S1206 = roughness_1 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S1206 = false;
    }
    return _S1206;
}

static __device__ bool passesLayer_0(uint layers_0, bool refracting_0, bool passed_0)
{
    bool _S1207 = layers_0 > 1U;
    bool _S1208;
    if(_S1207)
    {
        _S1208 = refracting_0 != passed_0;
    }
    else
    {
        _S1208 = false;
    }
    return _S1208;
}

static __device__ float widened_0(float spread_1, float pdf_9, bool delta_0)
{
    float _S1209 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * pdf_9))))), (3.14159274101257324f)));
    bool _S1210 = !delta_0;
    float _S1211 = _slang_select(_S1210, _S1209,0.0f);
    return spread_1 + _S1211;
}

static __device__ bool boundsVolume_0(FKSurface * surface_10)
{
    return surface_10->encloses;
}

static __device__ bool leavesInFront_0(float3  face_2, float3  dir_14, float3  g_3)
{
    return ((dot_0(dir_14, g_3)) > 0.0f) == ((dot_0(g_3, face_2)) > 0.0f);
}

static __device__ Shift walk_0(Domain * dom_7, Reservoir * r_8, bool replay_2, float scale_3, Selection * sel_7)
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
    uint b_10;
    uint layer_0;
    float3  throughput_2;
    float3  chain_throughput_0;
    TreeSample light_3;
    int _S1212;
    Shift ended_0;
    float density_3;
    float spread_3;
    float width_4;
    float sky_pdf_1;
    float spread_4;
    float width_5;
    uint b_11;
    float3  _S1213 = make_float3 (0.0f);
    Shift _S1214 = Shift_x24init_0(_S1213, 0.0f);
    uint _S1215 = r_8->path;
    uint _S1216 = extractBits_0(r_8->path, 0U, 5U);
    uint _S1217 = extractBits_0(_S1215, 5U, 5U);
    uint _S1218 = extractBits_0(_S1215, 10U, 2U);
    uint _S1219 = extractBits_0(_S1215, 12U, 3U);
    bool passes_0;
    if(replay_2)
    {
        bool _S1220 = _S1219 >= 3U;
        uint _S1221 = _slang_select(_S1220, 1U,0U);
        uint _S1222 = _S1216 + _S1221;
        uint _S1223 = (fcptMaxBounces());
        passes_0 = _S1222 > _S1223;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S1214;
    }
    uint _S1224 = _S1217 - 1U;
    bool _S1225 = _S1219 == 3U;
    uint _S1226 = _slang_select(_S1225, 1U,0U);
    uint _S1227 = _S1216 + _S1226;
    bool _S1228 = _S1218 == 0U;
    uint _S1229 = _slang_select(_S1228, _S1227,_S1224);
    FKHit _S1230 = (fcptReservoirHit((*r_8)));
    float3  _S1231 = dom_7->x0;
    float3  _S1232 = dom_7->x1 - dom_7->x0;
    float3  _S1233 = ((((_S1232)) * make_float3(rnorm3df(((_S1232)).x, ((_S1232)).y, ((_S1232)).z))));
    FKRay _S1234 = Ray_x24init_0(dom_7->x1, _S1233);
    FKRay ray_2 = _S1234;
    FKHit hit_4 = dom_7->hit;
    float3  scatter_in_0 = _S1213;
    float3  throughput_3 = make_float3 (1.0f);
    float3  weight_1 = throughput_3;
    float3  glowed_0 = _S1213;
    float3  extinction_in_0 = _S1213;
    float g_in_0 = 0.0f;
    uint filling_2 = 4294967295U;
    float _S1235 = dom_7->spread;
    float _S1236 = dom_7->width;
    float _S1237 = length_0(_S1232);
    NEEVertex _S1238 = NEEVertex_x24init_0(true, 0.0f, _S1213, _S1213, _S1213);
    NEEVertex nee_vertex_0 = _S1238;
    Vertex _S1239 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_0 = _S1239;
    Reservoir _S1240 = (Reservoir{});
    Reservoir chain_0 = _S1240;
    uint _S1241 = r_8->seed;
    (&chain_0)->seed = r_8->seed;
    (&ray_2)->origin = _S1231;
    (&hit_4)->distance = _S1237;
    FKMedium _S1242 = (fcptCameraMedium(((&ray_2)->unit_direction), ((&hit_4)->distance), (&filling_2)));
    uint _S1243 = filling_2;
    bool _S1244 = (fcptVaryingUsed());
    uint _S1245 = _slang_select(_S1244, _S1243,4294967295U);
    filling_2 = _S1245;
    scatter_in_0 = _S1242.scatter;
    extinction_in_0 = _S1242.extinction;
    g_in_0 = _S1242.g;
    Reservoir _S1246 = chain_0;
    uint _S1247 = filling_2;
    for(;;)
    {
        bool _S1248 = (fcptVaryingUsed());
        if(_S1248)
        {
            passes_0 = _S1247 != 4294967295U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            float _S1249 = (fcptMajorant((_S1247)));
            spread_2 = _S1249;
        }
        else
        {
            spread_2 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
        }
        if(replay_2)
        {
            turned_1 = 4294967295U == _S1229;
        }
        else
        {
            turned_1 = false;
        }
        if(turned_1)
        {
            turned_1 = _S1218 == 1U;
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
            ended_0 = _S1214;
            sky_pdf_0 = 0.0f;
            spread_2 = _S1235;
            width_3 = _S1236;
            density_2 = 1.0f;
            throughput_2 = throughput_3;
            b_10 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S1250 = (&prev_0)->rough;
        if(_S1250)
        {
            turned_1 = !(spread_2 > 0.0f);
        }
        else
        {
            turned_1 = false;
        }
        (&prev_0)->rough = turned_1;
        uint _S1251 = stream(_S1241, 384U);
        uint tracking_0 = _S1251;
        weight_1 = throughput_3;
        glowed_0 = _S1213;
        b_10 = 4294967295U;
        throughput_2 = throughput_3;
        density_2 = 1.0f;
        threshold_2 = _S1235;
        width_3 = _S1236;
        sky_pdf_0 = 0.0f;
        for(;;)
        {
            if(((&hit_4)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S1212 = int(1);
                break;
            }
            uint _S1252 = b_10 + 320U;
            bool _S1253 = b_10 == 4294967295U;
            uint _S1254 = _slang_select(_S1253, 384U,_S1252);
            uint _S1255 = stream(_S1241, _S1254);
            Random _S1256 = pcg(_S1255);
            float _S1257 = freeFlight_0(_S1256.value, spread_2);
            if(passes_0)
            {
                float3  _S1258 = (&ray_2)->origin;
                float3  _S1259 = (&ray_2)->unit_direction;
                float _S1260 = (&hit_4)->distance;
                uint _S1261 = _slang_select(_S1253, 0U,b_10);
                uint _S1262 = (&prev_0)->lobe;
                uint _S1263 = _slang_select(_S1253, 3U,_S1262);
                float _S1264 = (fcptTrackMedium((_S1247), (_S1258), (_S1259), (_S1260), (&tracking_0), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1261), (_S1263), (_S1253)));
                geometry_density_2 = _S1264;
            }
            else
            {
                geometry_density_2 = _S1257;
            }
            bool _S1265 = !(geometry_density_2 < ((&hit_4)->distance));
            if(_S1265)
            {
                _S1212 = int(1);
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
                float3  _S1266 = throughput_2 * glowed_0 / make_float3 (density_2);
                float3  _S1267 = sel_7->glow + _S1266;
                sel_7->glow = _S1267;
            }
            else
            {
            }
            glowed_0 = _S1213;
            uint b_12 = b_10 + 1U;
            float3  _S1268 = (&ray_2)->origin + make_float3 (geometry_density_2) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S1268;
            float3  _S1269 = flightWeight_0(scatter_in_0, extinction_in_0, spread_2, geometry_density_2, true);
            float3  _S1270 = weight_1;
            float3  _S1271 = _slang_select(passes_0, _S1270,_S1269);
            float3  throughput_4 = throughput_2 * _S1271;
            uint _S1272 = stream(_S1241, b_12 + 320U);
            tracking_0 = _S1272;
            weight_1 = throughput_3;
            float width_6 = width_3 + threshold_2 * geometry_density_2;
            float _S1273 = threshold_2 + 3.14159274101257324f;
            bool _S1274 = scatterSampled_0(replay_2, b_12, _S1229, passes_0);
            TreeSample _S1275 = TreeSample_x24init_0(_S1213, _S1213, 0.0f, 0U);
            if(_S1274)
            {
                float3  _S1276 = (&ray_2)->origin;
                float3  _S1277 = (&ray_2)->unit_direction;
                float3  _S1278 = (&ray_2)->unit_direction;
                uint _S1279 = stream(_S1241, b_12 + 64U);
                float3  _S1280 = extinction_in_0;
                float3  _S1281 = extinction_in_0;
                uint2  _S1282 = make_uint2 (_S1247);
                float3  _S1283 = (&ray_2)->unit_direction;
                uint _S1284 = arrivalLobe_0(b_12, (&prev_0)->lobe);
                FKHit _S1285 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S1286 = _S1285;
                ShadowContext _S1287 = ShadowContext_x24init_0(_S1280, _S1281, _S1282, _S1283, b_12, _S1284, false, geometry_density_2, width_6, &_S1286, false);
                ShadowContext _S1288 = _S1287;
                TreeSample _S1289 = sampleLightTree_0(_S1276, _S1277, _S1278, 0.0f, true, _S1279, &_S1288);
                light_3 = _S1289;
            }
            else
            {
                light_3 = _S1275;
            }
            float _S1290 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_3.dir));
            uint _S1291 = (fcptMaxBounces());
            bool _S1292 = b_12 < _S1291;
            if(_S1292)
            {
                is_inside_5 = (light_3.density) > 0.0f;
            }
            else
            {
                is_inside_5 = false;
            }
            float _S1293 = _slang_select(is_inside_5, _S1290,0.0f);
            float3  _S1294 = throughput_4 * light_3.radiance;
            float _S1295 = powerHeuristic(light_3.density, _S1293);
            float3  _S1296 = _S1294 * make_float3 (_S1290 * _S1295);
            float3  _S1297 = _slang_select(_S1274, _S1296,_S1213);
            if(replay_2)
            {
                viewed_0 = b_12 == _S1229;
            }
            else
            {
                viewed_0 = false;
            }
            if(viewed_0)
            {
                bool _S1298 = _S1218 == 2U;
                if(_S1298)
                {
                    float _S1299 = rgb_to_greyscale(_S1297);
                    passes_0 = _S1299 > 0.0f;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S1300 = Shift_x24init_0(_S1297, 1.0f);
                    _S1212 = int(0);
                    ended_0 = _S1300;
                    spread_2 = _S1273;
                    geometry_density_2 = width_6;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_12;
                    break;
                }
                _S1212 = int(0);
                ended_0 = _S1214;
                spread_2 = _S1273;
                geometry_density_2 = width_6;
                chain_throughput_0 = throughput_4;
                layer_0 = b_12;
                break;
            }
            bool _S1301 = !replay_2;
            if(_S1301)
            {
                Reservoir candidate_3 = _S1246;
                uint _S1302 = extractBits_0(_S1246.path, 10U, 2U);
                bool _S1303 = _S1302 == 1U;
                if(_S1303)
                {
                    float3  _S1304 = safeDivide(_S1297, _S1213);
                    (&candidate_3)->radiance = _S1304;
                }
                else
                {
                    uint _S1305 = insertBits_0(0U, b_12 + 1U, 5U, 5U);
                    uint _S1306 = insertBits_0(_S1305, 2U, 10U, 2U);
                    (&candidate_3)->path = _S1306;
                }
                Reservoir _S1307 = withEnd(candidate_3, 0U, b_12, _S1297);
                offer(sel_7, _S1307, _S1297 * make_float3 (scale_3) / make_float3 (density_2));
                float _S1308 = survivalProbability(throughput_4, density_2);
                uint _S1309 = stream(_S1241, b_12 + 128U);
                Random _S1310 = pcg(_S1309);
                bool _S1311 = _S1308 < (_S1310.value);
                if(_S1311)
                {
                    scatter_2 = true;
                }
                else
                {
                    uint _S1312 = (fcptMaxBounces());
                    scatter_2 = b_12 >= _S1312;
                }
                if(scatter_2)
                {
                    _S1212 = int(0);
                    ended_0 = _S1214;
                    spread_2 = _S1273;
                    geometry_density_2 = width_6;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_12;
                    break;
                }
                float _S1313 = density_2 * _S1308;
                density_2 = _S1313;
            }
            else
            {
            }
            float phase_pdf_0 = 0.0f;
            uint _S1314 = stream(_S1241, b_12);
            float3  _S1315 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1314, &phase_pdf_0);
            (&ray_2)->unit_direction = _S1315;
            NEEVertex _S1316 = NEEVertex_x24init_0(false, phase_pdf_0, (&ray_2)->origin, _S1213, (&ray_2)->origin);
            nee_vertex_0 = _S1316;
            Vertex _S1317 = scatteredVertex_0(false);
            prev_0 = _S1317;
            float _S1318 = (&prev_0)->pdf;
            FKRay _S1319 = ray_2;
            FKHit _S1320 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S1321 = (fcptTraverseInstanceBVH((_S1319), (true), (4.294967296e+09f), (false), (_S1320), (false)));
            hit_4 = _S1321;
            b_10 = b_12;
            throughput_2 = throughput_4;
            threshold_2 = _S1273;
            width_3 = width_6;
            sky_pdf_0 = _S1318;
        }
        if(_S1212 != int(1))
        {
            width_3 = geometry_density_2;
            throughput_2 = chain_throughput_0;
            b_10 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S1214;
        spread_2 = threshold_2;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    bool _S1322 = b_10 == 4294967295U;
    bool _S1323 = ((&hit_4)->instance_index) == 4294967295U;
    if(_S1323)
    {
        bool _S1324 = !(&nee_vertex_0)->none;
        float _S1325 = _slang_select(_S1324, sky_pdf_0,0.0f);
        float _S1326 = escapeWeight_0(_S1325, (&ray_2)->unit_direction);
        float3  _S1327 = environment_0((&ray_2)->unit_direction, b_10, (&prev_0)->lobe);
        float3  _S1328 = throughput_2 * _S1327;
        if(replay_2)
        {
            bool _S1329 = b_10 == _S1229;
            if(_S1329)
            {
                passes_0 = _S1218 == 3U;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                return Shift_x24init_0(_S1328 * make_float3 (_S1326) / make_float3 (r_8->jac), density_2 / r_8->jac);
            }
            if(_S1228)
            {
                passes_0 = _S1225;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                passes_0 = b_10 == _S1216;
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
                return Shift_x24init_0(_S1328 * make_float3 (_S1326), 1.0f);
            }
            return _S1214;
        }
        Reservoir candidate_4 = chain_0;
        uint _S1330 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1331 = _S1330 == 1U;
        if(_S1331)
        {
            uint _S1332 = extractBits_0((&chain_0)->path, 5U, 5U);
            bool _S1333 = _S1332 == b_10;
            float _S1334 = _slang_select(_S1333, 1.0f,_S1326);
            float3  _S1335 = safeDivide(_S1328 * make_float3 (_S1334), _S1213);
            (&candidate_4)->radiance = _S1335;
        }
        else
        {
            bool _S1336 = (&prev_0)->rough;
            if(_S1336)
            {
                uint _S1337 = insertBits_0(0U, b_10 + 1U, 5U, 5U);
                uint _S1338 = insertBits_0(_S1337, 3U, 10U, 2U);
                uint _S1339 = insertBits_0(_S1338, (&prev_0)->lobe, 15U, 3U);
                bool _S1340 = (&prev_0)->inside;
                uint _S1341 = _slang_select(_S1340, 1U,0U);
                uint _S1342 = insertBits_0(_S1339, _S1341, 22U, 1U);
                (&candidate_4)->path = _S1342;
                (&candidate_4)->jac = (&prev_0)->pdf;
                (&candidate_4)->dir = (&ray_2)->unit_direction;
            }
        }
        float3  _S1343 = _S1328 * make_float3 (_S1326);
        Reservoir _S1344 = withEnd(candidate_4, 3U, b_10, _S1343);
        offer(sel_7, _S1344, _S1343 * make_float3 (scale_3) / make_float3 (density_2));
        return _S1214;
    }
    float3  _S1345 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
    (&ray_2)->origin = _S1345;
    bool _S1346 = (fcptVaryingUsed());
    if(_S1346)
    {
        passes_0 = filling_2 != 4294967295U;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        bool _S1347 = !replay_2;
        if(_S1347)
        {
            float3  _S1348 = throughput_2 * glowed_0 / make_float3 (density_2);
            float3  _S1349 = sel_7->glow + _S1348;
            sel_7->glow = _S1349;
        }
        float3  _S1350 = throughput_2 * weight_1;
        throughput_2 = _S1350;
    }
    else
    {
        float3  _S1351 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
        float3  _S1352 = throughput_2 * _S1351;
        throughput_2 = _S1352;
    }
    float _S1353 = width_3 + spread_2 * (&hit_4)->distance;
    uint _S1354 = b_10 + 1U;
    b_10 = _S1354;
    layer_0 = 0U;
    width_3 = _S1353;
    passes_0 = false;
    threshold_2 = 0.0f;
    turned_1 = false;
    is_inside_5 = false;
    chain_throughput_0 = _S1213;
    float3  reconnection_0 = _S1213;
    viewed_0 = _S1322;
    for(;;)
    {
        bool _S1355 = ((&hit_4)->is_point_light) == 1U;
        FKMedium _S1356 = Medium_x24init_0(_S1213, _S1213, 0.0f);
        BSDFMaterial _S1357 = Material_x24init_0(_S1213, _S1213, 0.0f, 0.0f, 0.0f, 0.0f, _S1213, throughput_3, 1.0f, _S1213, _S1213, 0.5f, 0.0f, 0.0f, _S1213, 0.0f, _S1213);
        FKMedium _S1358 = _S1356;
        FKSurface _S1359 = Surface_x24init_0(_S1213, _S1213, 0.0f, &_S1357, false, 0U, 1.0f, false, &_S1358, 4294967295U, _S1213);
        bool _S1360 = !_S1355;
        bool is_inside_6;
        float3  throughput_5;
        FKSurface surface_11;
        if(_S1360)
        {
            uint _S1361 = stream(_S1241, b_10);
            uint _S1362 = arrivalLobe_0(b_10, (&prev_0)->lobe);
            FKSurface _S1363 = (fcptSurfaceAtPath((hit_4), ((&ray_2)->origin), (_S1361), (width_3), (layer_0), (b_10), (_S1362), ((&ray_2)->unit_direction)));
            bool _S1364 = !passes_0;
            FKSurface _S1365 = _S1363;
            FKSurface _S1366 = emitting_0(&_S1365, _S1364);
            uint _S1367 = stream(_S1241, b_10 + 256U);
            Random _S1368 = pcg(_S1367);
            FKSurface _S1369 = _S1366;
            FKSurface _S1370 = uncovered_0(&_S1369, _S1368.value);
            float _S1371 = facingSign(_S1370.material.transmission, _S1370.geometry_n, (&ray_2)->unit_direction);
            bool _S1372 = _S1371 < 0.0f;
            bool _S1373 = (_S1370.material.transmission) > 0.0f;
            if(_S1373)
            {
                bool _S1374 = arrivesBehind_0((&ray_2)->unit_direction, _S1370.geometry_n);
                scatter_2 = _S1374;
            }
            else
            {
                scatter_2 = false;
            }
            FKSurface _S1375 = _S1370;
            FKSurface _S1376 = facingRay_0(&_S1375, (&ray_2)->unit_direction);
            if(passes_0)
            {
                bool _S1377 = arrivesBehind_0((&ray_2)->unit_direction, _S1376.geometry_n);
                is_inside_6 = _S1377;
            }
            else
            {
                is_inside_6 = scatter_2;
            }
            if(is_inside_6)
            {
                float3  _S1378 = beerLambert((&hit_4)->distance, _S1376.material.absorption);
                float3  _S1379 = throughput_2 * _S1378;
                throughput_5 = _S1379;
            }
            else
            {
                throughput_5 = throughput_2;
            }
            bool _S1380 = !_S1376.skip;
            float geometry_density_3 = geometryDensity(_S1376.geometry_n, (&ray_2)->unit_direction, (&hit_4)->distance);
            bool _S1381 = b_10 == _S1354;
            if(_S1381)
            {
                float _S1382 = footprintThreshold(geometry_density_3);
                geometry_density_2 = _S1382;
            }
            else
            {
                geometry_density_2 = threshold_2;
            }
            float _S1383 = geometry_density_2;
            scatter_2 = _S1380;
            geometry_density_2 = geometry_density_3;
            threshold_2 = _S1383;
            surface_11 = _S1376;
            turned_1 = _S1372;
        }
        else
        {
            scatter_2 = false;
            geometry_density_2 = 0.0f;
            surface_11 = _S1359;
            throughput_5 = throughput_2;
            is_inside_6 = is_inside_5;
        }
        bool _S1384 = withinFootprint(scatter_2, (&prev_0)->rough, (&prev_0)->pdf, geometry_density_2, threshold_2);
        FKSurface _S1385 = surface_11;
        FKSurface _S1386 = surface_11;
        float _S1387 = dot_0(surface_11.smooth_n, - (&ray_2)->unit_direction);
        float2  _S1388 = vertexEta(_S1385.material, _S1387);
        bool _S1389;
        if(scatter_2)
        {
            bool _S1390 = neeDecision(_S1385.material, _S1387, _S1388.x, _S1388.y);
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
            BSDFMaterial _S1396 = _S1385.material;
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
            bool _S1399 = (_S1385.material.transmission) > 0.0f;
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
        if(_S1355)
        {
            float3  _S1401 = (fcptCalculatePointLightContrib(((&hit_4)->instance_index)));
            emission_0 = _S1401;
        }
        else
        {
            emission_0 = _S1385.material.emissive;
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
            _S1407 = _S1218 == 1U;
        }
        else
        {
            _S1407 = false;
        }
        bool _S1408;
        if(_S1407)
        {
            _S1408 = b_10 > _S1217;
        }
        else
        {
            _S1408 = false;
        }
        bool _S1409;
        if(_S1408)
        {
            _S1409 = b_10 == _S1216;
        }
        else
        {
            _S1409 = false;
        }
        bool _S1410;
        if(_S1409)
        {
            bool _S1411 = _S1219 == 1U;
            if(_S1411)
            {
                _S1410 = true;
            }
            else
            {
                _S1410 = _S1219 == 2U;
            }
        }
        else
        {
            _S1410 = false;
        }
        if(_S1410)
        {
            bool _S1412 = _S1355 != (_S1219 == 2U);
            if(_S1412)
            {
                return _S1214;
            }
            return Shift_x24init_0(throughput_5 * emission_1 / make_float3 (r_8->jac), density_2 / r_8->jac);
        }
        uint _S1413 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1414 = _S1413 == 1U;
        Reservoir here_0 = chain_0;
        uint _S1415 = insertBits_0(0U, b_10, 5U, 5U);
        uint _S1416 = insertBits_0(_S1415, 1U, 10U, 2U);
        uint _S1417 = insertBits_0(_S1416, (&prev_0)->lobe, 15U, 3U);
        bool _S1418 = (&prev_0)->inside;
        uint _S1419 = _slang_select(_S1418, 1U,0U);
        uint _S1420 = insertBits_0(_S1417, _S1419, 22U, 1U);
        (&here_0)->path = _S1420;
        float _S1421 = (&prev_0)->pdf * geometry_density_2;
        (&here_0)->jac = _S1421;
        fcptWithReservoirHit((&here_0), (&hit_4));
        bool _S1422;
        if(replay_2)
        {
            _S1422 = _S1218 == 1U;
        }
        else
        {
            _S1422 = false;
        }
        bool _S1423;
        if(_S1422)
        {
            _S1423 = b_10 == _S1217;
        }
        else
        {
            _S1423 = false;
        }
        bool _S1424 = b_10 == _S1229;
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
                bool _S1427 = _S1218 != 1U;
                if(_S1427)
                {
                    _S1425 = _S1218 != 3U;
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
            _S1428 = _S1218 == 2U;
        }
        else
        {
            _S1428 = false;
        }
        bool _S1429;
        if(_S1428)
        {
            _S1429 = !_S1384;
        }
        else
        {
            _S1429 = false;
        }
        bool _S1430;
        if(_S1429)
        {
            _S1430 = _S1219 != 4U;
        }
        else
        {
            _S1430 = false;
        }
        bool _S1431 = _S1217 == _S1216;
        bool _S1432;
        if(_S1431)
        {
            _S1432 = _S1219 == 0U;
        }
        else
        {
            _S1432 = false;
        }
        bool _S1433;
        if(_S1432)
        {
            _S1433 = ((&hit_4)->instance_index) == (_S1230.instance_index);
        }
        else
        {
            _S1433 = false;
        }
        bool _S1434;
        if(_S1433)
        {
            _S1434 = ((&hit_4)->triangle_index) == (_S1230.triangle_index);
        }
        else
        {
            _S1434 = false;
        }
        bool _S1435;
        if(_S1434)
        {
            _S1435 = _S1384;
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
        TreeSample _S1438 = TreeSample_x24init_0(_S1213, _S1213, 0.0f, 0U);
        uint2  _S1439 = make_uint2 (0U);
        float2  _S1440 = make_float2 (0.0f);
        FKHit _S1441 = Hit_x24init_0(_S1440, 4294967295U, 0U, 0U, 0.0f);
        FKHit _S1442 = _S1441;
        ShadowContext _S1443 = ShadowContext_x24init_0(_S1213, _S1213, _S1439, _S1213, 0U, 0U, false, 0.0f, 0.0f, &_S1442, false);
        ShadowContext context_5;
        if(nee_0)
        {
            uint _S1444 = arrivalLobe_0(b_10, (&prev_0)->lobe);
            FKMedium _S1445 = (fcptOutsideMedium((hit_4)));
            FKSurface _S1446 = surface_11;
            FKHit _S1447 = hit_4;
            FKMedium _S1448 = _S1445;
            ShadowContext _S1449 = shadowContext_0(&_S1446, turned_1, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_10, _S1444, (&hit_4)->distance, width_3, &_S1447, _S1393, &_S1448);
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
                throughput_6 = _S1213;
            }
            else
            {
                throughput_6 = _S1386.smooth_n;
            }
            FKSurface _S1451 = surface_11;
            uint _S1452 = stream(_S1241, b_10 + 64U);
            ShadowContext _S1453 = context_5;
            TreeSample _S1454 = sampleLightTree_0(_S1450, throughput_6, surface_11.geometry_n, surface_11.geometry_offset, _S1398, _S1452, &_S1453);
            bool _S1455 = any_1((_S1454.radiance) != _S1213);
            if(_S1455)
            {
                if(_S1393)
                {
                    uint _S1456 = (fcptMaxBounces());
                    bool _S1457 = b_10 < _S1456;
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
                    bool _S1464 = b_10 < _S1463;
                    TreeSample _S1465 = _S1454;
                    BSDFMaterial _S1466 = _S1385.material;
                    float3  _S1467 = lightBSDF_0((&ray_2)->unit_direction, &_S1465, _S1386.smooth_n, _S1451.geometry_n, &_S1466, _S1461, _S1462, _S1464, surface_11.random_state);
                    lit_0 = _S1467;
                }
            }
            else
            {
                lit_0 = _S1213;
            }
            light_3 = _S1454;
        }
        else
        {
            light_3 = _S1438;
            lit_0 = _S1213;
        }
        bool viewed_1;
        bool refracted_4;
        bool wrong_side_0;
        bool _S1468;
        bool _S1469;
        float density_4;
        if(_S1423)
        {
            bool _S1470 = ((&hit_4)->instance_index) != (_S1230.instance_index);
            if(_S1470)
            {
                viewed_1 = true;
            }
            else
            {
                viewed_1 = ((&hit_4)->triangle_index) != (_S1230.triangle_index);
            }
            if(viewed_1)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = !_S1384;
            }
            if(refracted_4)
            {
                return _S1214;
            }
            float3  throughput_7 = throughput_5 * make_float3 (geometry_density_2);
            float density_5 = density_2 * geometry_density_2;
            if(_S1431)
            {
                wrong_side_0 = _S1219 == 1U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                return Shift_x24init_0(throughput_7 * emission_1 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1431)
            {
                _S1468 = _S1219 == 0U;
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
                    return _S1214;
                }
                return Shift_x24init_0(throughput_7 * lit_0 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1431)
            {
                _S1469 = _S1219 == 4U;
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
                    return _S1214;
                }
                float _S1474 = environmentPdf_0(r_8->dir);
                float3  _S1475 = skyBSDF((&ray_2)->unit_direction, r_8->dir, surface_11, _S1388, is_inside_6, _S1474, surface_11.random_state);
                return Shift_x24init_0(throughput_7 * _S1475 * r_8->radiance / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            uint _S1476 = extractBits_0(_S1215, 21U, 1U);
            bool _S1477 = nee_0 != (_S1476 == 1U);
            if(_S1477)
            {
                return _S1214;
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
                    bool _S1479 = _S1218 != 1U;
                    if(_S1479)
                    {
                        refracted_4 = _S1218 != 3U;
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
                bool _S1480 = _S1218 == 2U;
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
                    passes_0 = !_S1384;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1219 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    if(_S1393)
                    {
                        return _S1214;
                    }
                    uint _S1481 = stream(_S1241, b_10 + 448U);
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
                    passes_0 = !_S1384;
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
                        return _S1214;
                    }
                    return Shift_x24init_0(throughput_5 * lit_0, 1.0f);
                }
                if(_S1228)
                {
                    passes_0 = _S1219 == 2U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1355;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_5 * emission_1, 1.0f);
                }
                if(_S1228)
                {
                    passes_0 = _S1219 == 1U;
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
                    passes_0 = !_S1384;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_5 * emission_1, 1.0f);
                }
                return _S1214;
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
                    bool _S1489 = b_10 > 0U;
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
                            if(_S1384)
                            {
                                candidate_5 = here_0;
                            }
                        }
                        float3  _S1491 = throughput_5 * emission_1;
                        Reservoir _S1492 = withEnd(candidate_5, 1U, b_10, _S1491);
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
                            if(_S1384)
                            {
                                candidate_6 = here_0;
                                uint _S1497 = insertBits_0((&candidate_6)->path, 1U, 21U, 1U);
                                (&candidate_6)->path = _S1497;
                                (&candidate_6)->dir = light_3.dir;
                                (&candidate_6)->radiance = light_3.radiance;
                            }
                            else
                            {
                                uint _S1498 = insertBits_0(0U, b_10 + 1U, 5U, 5U);
                                uint _S1499 = insertBits_0(_S1498, 2U, 10U, 2U);
                                (&candidate_6)->path = _S1499;
                            }
                        }
                        Reservoir _S1500 = withEnd(candidate_6, 0U, b_10, _S1495);
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
                        _S1469 = b_10 < _S1502;
                    }
                    else
                    {
                        _S1469 = false;
                    }
                    if(_S1469)
                    {
                        uint _S1503 = stream(_S1241, b_10 + 448U);
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
                            if(_S1384)
                            {
                                candidate_7 = here_0;
                                uint _S1510 = insertBits_0((&candidate_7)->path, 1U, 21U, 1U);
                                (&candidate_7)->path = _S1510;
                                (&candidate_7)->dir = _S1507.dir;
                                (&candidate_7)->radiance = _S1507.radiance;
                            }
                            else
                            {
                                uint _S1511 = insertBits_0(0U, b_10 + 1U, 5U, 5U);
                                uint _S1512 = insertBits_0(_S1511, 2U, 10U, 2U);
                                (&candidate_7)->path = _S1512;
                            }
                        }
                        Reservoir _S1513 = withEnd(candidate_7, 4U, b_10, _S1508);
                        offer(sel_7, _S1513, _S1508 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                }
            }
            throughput_6 = throughput_5;
            density_4 = density_2;
        }
        bool _S1514;
        bool _S1515;
        bool straight_0;
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
        uint b_13;
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
            uint _S1529 = extractBits_0(_S1215, 15U, 3U);
            uint _S1530 = extractBits_0(_S1215, 18U, 3U);
            uint _S1531 = _slang_select(_S1423, _S1530,_S1529);
            float3  _S1532 = r_8->dir;
            bool refracted_5 = _S1531 == 1U;
            SampleBSDF _S1533 = SampleBSDF_x24init_0(_S1213, _S1213, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_11 = _S1533;
            float3  reconnection_1;
            SampleBSDF _S1534;
            if(viewed_1)
            {
                uint _S1535 = extractBits_0(_S1215, 22U, 1U);
                bool _S1536 = is_inside_6 != (_S1535 == 1U);
                if(_S1536)
                {
                    return _S1214;
                }
                bool _S1537 = _S1218 == 1U;
                if(_S1537)
                {
                    float3  _S1538 = (fcptHitPosition((_S1230)));
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
                    BSDFMaterial _S1539 = _S1385.material;
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
                        wrong_side_0 = (dot_0(_S1386.smooth_n, _S1542) * _S1387) < 0.0f;
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
                    float3  _S1545 = - _S1386.smooth_n;
                    bool _S1546 = is_inside_6 != refracted_4;
                    float3  _S1547 = _slang_select(_S1546, _S1545,_S1386.smooth_n);
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
                    return _S1214;
                }
                float3  _S1551 = throughput_8;
                throughput_8 = reconnection_1;
                b_13 = _S1531;
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
                        SampleBSDF _S1553 = (fcptSampleHair((surface_11.hair), (_S1385.material.albedo), (_S1385.material.specular_tint), ((&ray_2)->unit_direction), (surface_11.random_state)));
                        _S1534 = _S1553;
                    }
                    else
                    {
                        SampleBSDF _S1554 = sampleBSDF((&ray_2)->unit_direction, _S1386.smooth_n, _S1385.material, _S1388.x, _S1388.y, surface_11.random_state, _S1440);
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
                            return _S1214;
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
                        _S1468 = (_S1385.material.transmission) > 0.0f;
                    }
                    else
                    {
                        _S1468 = false;
                    }
                    if(_S1468)
                    {
                        SampleBSDF _S1556 = sampleBSDF((&bsdf_sampled_0)->unit_direction, surface_11.geometry_n, _S1385.material, _S1388.x, _S1388.y, (&bsdf_sampled_0)->random_state, _S1440);
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
                    lobe_11 = bsdf_sampled_0;
                    float _S1561 = (&bsdf_sampled_0)->pdf;
                    float _S1562 = _slang_select(wrong_side_0, 0.0f,_S1561);
                    (&lobe_11)->pdf = _S1562;
                    throughput_8 = _S1559;
                    b_13 = _S1558;
                    refracted_4 = _S1560;
                }
                else
                {
                    throughput_8 = _S1532;
                    b_13 = _S1531;
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
                    SampleBSDF _S1563 = (fcptConnectHair((surface_11.hair), (_S1385.material.albedo), (_S1385.material.specular_tint), ((&ray_2)->unit_direction), (throughput_8)));
                    _S1534 = _S1563;
                }
                else
                {
                    SampleBSDF _S1564 = connectBSDF((&ray_2)->unit_direction, throughput_8, _S1386.smooth_n, _S1385.material, _S1388.x, _S1388.y, b_13, surface_11.random_state);
                    _S1534 = _S1564;
                }
                lobe_11 = _S1534;
            }
            bool _S1565 = b_13 == 0U;
            if(_S1565)
            {
                _S1469 = true;
            }
            else
            {
                _S1469 = b_13 == 4U;
            }
            if(_S1393)
            {
                _S1514 = false;
            }
            else
            {
                bool _S1566 = !_S1469;
                if(_S1566)
                {
                    bool _S1567 = (_S1385.material.roughness) == 0.0f;
                    if(_S1567)
                    {
                        _S1514 = true;
                    }
                    else
                    {
                        bool _S1568 = b_13 == 1U;
                        if(_S1568)
                        {
                            _S1514 = (_S1388.x) == (_S1388.y);
                        }
                        else
                        {
                            _S1514 = false;
                        }
                    }
                }
                else
                {
                    _S1514 = false;
                }
            }
            bool _S1569 = !_S1393;
            if(_S1569)
            {
                _S1515 = b_13 == 1U;
            }
            else
            {
                _S1515 = false;
            }
            if(_S1515)
            {
                straight_0 = (_S1385.material.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S1516 = _S1569;
            }
            else
            {
                _S1516 = false;
            }
            if(_S1516)
            {
                _S1517 = b_13 == 1U;
            }
            else
            {
                _S1517 = false;
            }
            if(_S1517)
            {
                _S1518 = (_S1388.x) == (_S1388.y);
            }
            else
            {
                _S1518 = false;
            }
            BSDFMaterial _S1570 = _S1385.material;
            bool _S1571 = isTranslucent_0(&_S1570);
            if(_S1571)
            {
                _S1519 = _S1565;
            }
            else
            {
                _S1519 = false;
            }
            if(_S1519)
            {
                _S1520 = (dot_0(throughput_8, surface_11.geometry_n)) < 0.0f;
            }
            else
            {
                _S1520 = false;
            }
            if(nee_0)
            {
                _S1521 = !_S1514;
            }
            else
            {
                _S1521 = false;
            }
            if(_S1521)
            {
                _S1522 = !wrong_side_0;
            }
            else
            {
                _S1522 = false;
            }
            if(_S1522)
            {
                float _S1572 = (&lobe_11)->pdf;
                float3  _S1573 = (&ray_2)->origin;
                float3  _S1574 = _slang_select(_S1398, _S1213,_S1386.smooth_n);
                float3  _S1575 = (&ray_2)->origin;
                FKSurface _S1576 = surface_11;
                float3  _S1577 = - _S1386.smooth_n;
                float3  _S1578 = _slang_select(_S1520, _S1577,_S1386.smooth_n);
                NEEVertex _S1579 = NEEVertex_x24init_0(false, _S1572, _S1573, _S1574, _S1575 + make_float3 (_S1576.geometry_offset) * _S1578);
                nee_vertex_0 = _S1579;
            }
            else
            {
                if(_S1393)
                {
                    _S1523 = true;
                }
                else
                {
                    bool _S1580 = b_13 != 1U;
                    if(_S1580)
                    {
                        _S1523 = true;
                    }
                    else
                    {
                        _S1523 = (_S1388.x) != (_S1388.y);
                    }
                }
                if(_S1523)
                {
                    (&nee_vertex_0)->none = true;
                }
            }
            bool _S1581 = withinInverseFootprint((&lobe_11)->pdf, _S1469, (&prev_0)->cos, (&hit_4)->distance, threshold_2);
            bool _S1582 = roughLobe((&lobe_11)->pdf, _S1469, _S1385.material.roughness);
            if(_S1423)
            {
                bool _S1583 = !_S1581;
                if(_S1583)
                {
                    return _S1214;
                }
                bool _S1584 = _S1219 != 1U;
                if(_S1584)
                {
                    _S1523 = _S1219 != 2U;
                }
                else
                {
                    _S1523 = false;
                }
                if(_S1523)
                {
                    float _S1585 = (&lobe_11)->pdf;
                    float _S1586 = _slang_select(nee_0, _S1585,0.0f);
                    float _S1587 = escapeWeight_0(_S1586, _S1532);
                    if(_S1431)
                    {
                        passes_0 = _S1225;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1588 = _slang_select(passes_0, _S1587,1.0f);
                    return Shift_x24init_0(throughput_6 * ((&lobe_11)->throughput * make_float3 ((&lobe_11)->pdf)) * r_8->radiance * make_float3 (_S1588) / make_float3 (r_8->jac), density_4 * (&lobe_11)->pdf / r_8->jac);
                }
                float3  _S1589 = throughput_6 * make_float3 ((&lobe_11)->pdf);
                float _S1590 = density_4 * (&lobe_11)->pdf;
                throughput_9 = _S1589;
                density_6 = _S1590;
            }
            else
            {
                throughput_9 = throughput_6;
                density_6 = density_4;
            }
            uint _S1591 = (fcptLayers((hit_4)));
            bool _S1592 = b_13 == 1U;
            bool _S1593 = passesLayer_0(_S1591, _S1592, passes_0);
            if(viewed_1)
            {
                _S1523 = _S1593;
            }
            else
            {
                _S1523 = false;
            }
            if(_S1523)
            {
                return _S1214;
            }
            if(replay_2)
            {
                _S1524 = b_10 <= _S1229;
            }
            else
            {
                _S1524 = false;
            }
            if(_S1524)
            {
                _S1525 = _S1384;
            }
            else
            {
                _S1525 = false;
            }
            if(_S1525)
            {
                _S1526 = _S1581;
            }
            else
            {
                _S1526 = false;
            }
            if(_S1526)
            {
                _S1527 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S1527 = !_S1582;
                }
                else
                {
                    _S1527 = false;
                }
            }
            if(_S1527)
            {
                return _S1214;
            }
            if(viewed_1)
            {
                float3  _S1594 = throughput_9 * ((&lobe_11)->throughput * make_float3 ((&lobe_11)->pdf));
                float _S1595 = (&lobe_11)->pdf;
                throughput_10 = _S1594;
                sky_pdf_2 = _S1595;
            }
            else
            {
                float3  _S1596 = throughput_9 * max_0((&lobe_11)->throughput, _S1213);
                throughput_10 = _S1596;
                sky_pdf_2 = density_6;
            }
            bool _S1597 = !replay_2;
            if(_S1597)
            {
                _S1528 = !_S1414;
            }
            else
            {
                _S1528 = false;
            }
            bool _S1598;
            if(_S1528)
            {
                _S1598 = _S1384;
            }
            else
            {
                _S1598 = false;
            }
            bool _S1599;
            if(_S1598)
            {
                _S1599 = _S1581;
            }
            else
            {
                _S1599 = false;
            }
            float3  chain_throughput_1;
            if(_S1599)
            {
                chain_0 = here_0;
                uint _S1600 = insertBits_0((&chain_0)->path, b_13, 18U, 3U);
                uint _S1601 = _slang_select(nee_0, 1U,0U);
                uint _S1602 = insertBits_0(_S1600, _S1601, 21U, 1U);
                (&chain_0)->path = _S1602;
                float _S1603 = (&chain_0)->jac * (&lobe_11)->pdf;
                (&chain_0)->jac = _S1603;
                (&chain_0)->dir = throughput_8;
                chain_throughput_1 = throughput_10;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            FKSurface _S1604 = surface_11;
            Vertex _S1605 = Vertex_x24init_0(_S1582, b_13, (&lobe_11)->pdf, (F32_abs((dot_0(surface_11.geometry_n, throughput_8)))), is_inside_6);
            prev_0 = _S1605;
            float _S1606 = (&lobe_11)->pdf;
            bool _S1607;
            if(_S1592)
            {
                _S1607 = (_S1388.x) == (_S1388.y);
            }
            else
            {
                _S1607 = false;
            }
            float sky_pdf_3 = _slang_select(_S1607, sky_pdf_0,_S1606);
            float _S1608 = _slang_select(_S1393, 0.0f,sky_pdf_3);
            float _S1609 = widened_0(spread_2, (&lobe_11)->pdf, _S1514);
            bool _S1610;
            if(refracted_4)
            {
                _S1610 = !_S1520;
            }
            else
            {
                _S1610 = false;
            }
            bool is_inside_7;
            if(_S1610)
            {
                bool _S1611 = !is_inside_6;
                is_inside_7 = _S1611;
            }
            else
            {
                is_inside_7 = is_inside_6;
            }
            FKSurface _S1612 = surface_11;
            bool _S1613 = boundsVolume_0(&_S1612);
            bool _S1614;
            if(_S1613)
            {
                _S1614 = !_S1593;
            }
            else
            {
                _S1614 = false;
            }
            if(_S1614)
            {
                FKSurface faced_2 = surface_11;
                float3  _S1615 = - _S1604.geometry_n;
                float3  _S1616 = _slang_select(turned_1, _S1615,_S1604.geometry_n);
                (&faced_2)->geometry_n = _S1616;
                FKMedium _S1617 = Medium_x24init_0(scatter_in_0, extinction_in_0, g_in_0);
                FKMedium _S1618 = (fcptOutsideMedium((hit_4)));
                FKSurface _S1619 = faced_2;
                FKMedium _S1620 = _S1617;
                FKMedium _S1621 = _S1618;
                MediumSides _S1622 = mediumSides_0(&_S1619, &_S1620, filling_2, (&ray_2)->unit_direction, &_S1621);
                bool _S1623 = leavesInFront_0((&faced_2)->geometry_n, throughput_8, _S1604.geometry_n);
                float3  _S1624 = _slang_select(_S1623, _S1622.front.scatter,_S1622.behind.scatter);
                scatter_in_0 = _S1624;
                float3  _S1625 = _slang_select(_S1623, _S1622.front.extinction,_S1622.behind.extinction);
                extinction_in_0 = _S1625;
                float _S1626 = _slang_select(_S1623, _S1622.front.g,_S1622.behind.g);
                g_in_0 = _S1626;
                uint _S1627 = _S1622.fillings.x;
                uint _S1628 = _S1622.fillings.y;
                uint _S1629 = _slang_select(_S1623, _S1628,_S1627);
                bool _S1630 = (fcptVaryingUsed());
                uint _S1631 = _slang_select(_S1630, _S1629,4294967295U);
                filling_2 = _S1631;
            }
            (&ray_2)->unit_direction = throughput_8;
            bool _S1632 = !_S1593;
            if(_S1632)
            {
                FKSurface _S1633 = surface_11;
                float _S1634 = _slang_select(straight_0, 0.0f,_S1633.geometry_offset);
                float3  _S1635 = - _S1386.smooth_n;
                bool _S1636 = is_inside_7 != _S1520;
                float3  _S1637 = _slang_select(_S1636, _S1635,_S1386.smooth_n);
                float3  _S1638 = (&ray_2)->origin + make_float3 (_S1634) * _S1637;
                (&ray_2)->origin = _S1638;
            }
            throughput_9 = throughput_10;
            chain_throughput_0 = chain_throughput_1;
            density_6 = sky_pdf_2;
            passes_0 = _S1593;
            viewed_1 = _S1518;
            sky_pdf_2 = _S1608;
            spread_5 = _S1609;
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
        bool _S1639 = !replay_2;
        float density_7;
        if(_S1639)
        {
            if(_S1355)
            {
                float3  _S1640 = throughput_9 * emission_1;
                Reservoir candidate_8 = chain_0;
                uint _S1641 = extractBits_0((&chain_0)->path, 10U, 2U);
                bool _S1642 = _S1641 == 1U;
                if(_S1642)
                {
                    float3  _S1643 = safeDivide(_S1640, chain_throughput_0);
                    (&candidate_8)->radiance = _S1643;
                }
                Reservoir _S1644 = withEnd(candidate_8, 2U, b_10, _S1640);
                offer(sel_7, _S1644, _S1640 * make_float3 (scale_3) / make_float3 (density_6));
            }
            if(_S1355)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = scatter_2;
            }
            if(refracted_4)
            {
                float _S1645 = survivalProbability(throughput_9, density_6);
                density_7 = _S1645;
            }
            else
            {
                density_7 = 1.0f;
            }
            uint _S1646 = stream(_S1241, b_10 + 128U);
            Random _S1647 = pcg(_S1646);
            bool _S1648 = density_7 < (_S1647.value);
            if(_S1648)
            {
                wrong_side_0 = true;
            }
            else
            {
                uint _S1649 = (fcptMaxBounces());
                wrong_side_0 = b_10 >= _S1649;
            }
            if(wrong_side_0)
            {
                break;
            }
            float _S1650 = density_6 * density_7;
            density_7 = _S1650;
        }
        else
        {
            density_7 = density_6;
        }
        uint _S1651 = layer_0 ^ 1U;
        uint _S1652 = _slang_select(passes_0, _S1651,0U);
        if(passes_0)
        {
            (&prev_0)->rough = false;
            (&hit_4)->distance = 0.0f;
            b_13 = b_10;
            viewed_0 = viewed_1;
            throughput_2 = throughput_9;
            density_2 = density_7;
            sky_pdf_0 = sky_pdf_2;
            spread_2 = spread_5;
            uint _S1653 = b_13 + 1U;
            b_10 = _S1653;
            layer_0 = _S1652;
            continue;
        }
        FKRay _S1654 = ray_2;
        float _S1655 = distance_1(reconnection_0, (&ray_2)->origin) * 1.0010000467300415f;
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
            wrong_side_0 = _S1218 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S1656 = _slang_select(wrong_side_0, _S1655,4.294967296e+09f);
        bool _S1657 = !_S1393;
        if(straight_0)
        {
            _S1468 = true;
        }
        else
        {
            _S1468 = _S1393;
        }
        FKHit _S1658;
        if(_S1468)
        {
            _S1658 = hit_4;
        }
        else
        {
            _S1658 = _S1441;
        }
        FKHit _S1659 = (fcptTraverseInstanceBVH((_S1654), (_S1360), (_S1656), (_S1657), (_S1658), (viewed_1)));
        hit_4 = _S1659;
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
            _S1514 = _S1218 == 1U;
        }
        else
        {
            _S1514 = false;
        }
        if(_S1514)
        {
            _S1515 = ((&hit_4)->instance_index) == (_S1230.instance_index);
        }
        else
        {
            _S1515 = false;
        }
        if(_S1515)
        {
            _S1516 = ((&hit_4)->triangle_index) == (_S1230.triangle_index);
        }
        else
        {
            _S1516 = false;
        }
        if(_S1516)
        {
            (&hit_4)->uv = _S1230.uv;
            float _S1660 = distance_1(reconnection_0, (&ray_2)->origin);
            (&hit_4)->distance = _S1660;
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
            _S1518 = _S1218 == 3U;
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
            return _S1214;
        }
        Reservoir _S1661 = chain_0;
        uint _S1662 = filling_2;
        for(;;)
        {
            bool _S1663 = (fcptVaryingUsed());
            if(_S1663)
            {
                _S1520 = _S1662 != 4294967295U;
            }
            else
            {
                _S1520 = false;
            }
            float _S1664;
            if(_S1520)
            {
                float _S1665 = (fcptMajorant((_S1662)));
                _S1664 = _S1665;
            }
            else
            {
                _S1664 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
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
                _S1522 = _S1218 == 1U;
            }
            else
            {
                _S1522 = false;
            }
            if(_S1522)
            {
                _S1523 = _S1664 > 0.0f;
            }
            else
            {
                _S1523 = false;
            }
            if(_S1523)
            {
                ended_0 = _S1214;
                sky_pdf_1 = sky_pdf_2;
                spread_3 = spread_5;
                width_4 = width_3;
                density_3 = density_7;
                throughput_10 = throughput_9;
                b_13 = b_10;
                _S1524 = true;
                break;
            }
            bool _S1666 = (&prev_0)->rough;
            if(_S1666)
            {
                _S1524 = !(_S1664 > 0.0f);
            }
            else
            {
                _S1524 = false;
            }
            (&prev_0)->rough = _S1524;
            uint _S1667 = b_10 + 320U;
            bool _S1668 = b_10 == 4294967295U;
            uint _S1669 = _slang_select(_S1668, 384U,_S1667);
            uint _S1670 = stream(_S1241, _S1669);
            uint tracking_1 = _S1670;
            weight_1 = throughput_3;
            glowed_0 = _S1213;
            b_13 = b_10;
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
                    _S1212 = int(2);
                    break;
                }
                uint _S1671 = b_13 + 320U;
                bool _S1672 = b_13 == 4294967295U;
                uint _S1673 = _slang_select(_S1672, 384U,_S1671);
                uint _S1674 = stream(_S1241, _S1673);
                Random _S1675 = pcg(_S1674);
                float _S1676 = freeFlight_0(_S1675.value, _S1664);
                if(_S1520)
                {
                    float3  _S1677 = (&ray_2)->origin;
                    float3  _S1678 = (&ray_2)->unit_direction;
                    float _S1679 = (&hit_4)->distance;
                    uint _S1680 = _slang_select(_S1672, 0U,b_13);
                    uint _S1681 = (&prev_0)->lobe;
                    uint _S1682 = _slang_select(_S1672, 3U,_S1681);
                    float _S1683 = (fcptTrackMedium((_S1662), (_S1677), (_S1678), (_S1679), (&tracking_1), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1680), (_S1682), (_S1672)));
                    spread_4 = _S1683;
                }
                else
                {
                    spread_4 = _S1676;
                }
                bool _S1684 = !(spread_4 < ((&hit_4)->distance));
                if(_S1684)
                {
                    _S1212 = int(2);
                    break;
                }
                if(_S1520)
                {
                    _S1525 = _S1639;
                }
                else
                {
                    _S1525 = false;
                }
                if(_S1525)
                {
                    float3  _S1685 = throughput_10 * glowed_0 / make_float3 (density_3);
                    float3  _S1686 = sel_7->glow + _S1685;
                    sel_7->glow = _S1686;
                }
                else
                {
                }
                glowed_0 = _S1213;
                uint b_14 = b_13 + 1U;
                float3  _S1687 = (&ray_2)->origin + make_float3 (spread_4) * (&ray_2)->unit_direction;
                (&ray_2)->origin = _S1687;
                float3  _S1688 = flightWeight_0(scatter_in_0, extinction_in_0, _S1664, spread_4, true);
                float3  _S1689 = weight_1;
                float3  _S1690 = _slang_select(_S1520, _S1689,_S1688);
                float3  throughput_11 = throughput_10 * _S1690;
                uint _S1691 = stream(_S1241, b_14 + 320U);
                tracking_1 = _S1691;
                weight_1 = throughput_3;
                float width_7 = width_4 + spread_3 * spread_4;
                float _S1692 = spread_3 + 3.14159274101257324f;
                bool _S1693 = scatterSampled_0(replay_2, b_14, _S1229, _S1520);
                TreeSample light_4;
                if(_S1693)
                {
                    float3  _S1694 = (&ray_2)->origin;
                    float3  _S1695 = (&ray_2)->unit_direction;
                    float3  _S1696 = (&ray_2)->unit_direction;
                    uint _S1697 = stream(_S1241, b_14 + 64U);
                    float3  _S1698 = extinction_in_0;
                    float3  _S1699 = extinction_in_0;
                    uint2  _S1700 = make_uint2 (_S1662);
                    float3  _S1701 = (&ray_2)->unit_direction;
                    uint _S1702 = arrivalLobe_0(b_14, (&prev_0)->lobe);
                    FKHit _S1703 = _S1441;
                    ShadowContext _S1704 = ShadowContext_x24init_0(_S1698, _S1699, _S1700, _S1701, b_14, _S1702, false, spread_4, width_7, &_S1703, false);
                    ShadowContext _S1705 = _S1704;
                    TreeSample _S1706 = sampleLightTree_0(_S1694, _S1695, _S1696, 0.0f, true, _S1697, &_S1705);
                    light_4 = _S1706;
                }
                else
                {
                    light_4 = _S1438;
                }
                float _S1707 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_4.dir));
                uint _S1708 = (fcptMaxBounces());
                bool _S1709 = b_14 < _S1708;
                if(_S1709)
                {
                    _S1526 = (light_4.density) > 0.0f;
                }
                else
                {
                    _S1526 = false;
                }
                float _S1710 = _slang_select(_S1526, _S1707,0.0f);
                float3  _S1711 = throughput_11 * light_4.radiance;
                float _S1712 = powerHeuristic(light_4.density, _S1710);
                float3  _S1713 = _S1711 * make_float3 (_S1707 * _S1712);
                float3  _S1714 = _slang_select(_S1693, _S1713,_S1213);
                if(replay_2)
                {
                    _S1527 = b_14 == _S1229;
                }
                else
                {
                    _S1527 = false;
                }
                if(_S1527)
                {
                    bool _S1715 = _S1218 == 2U;
                    if(_S1715)
                    {
                        float _S1716 = rgb_to_greyscale(_S1714);
                        _S1528 = _S1716 > 0.0f;
                    }
                    else
                    {
                        _S1528 = false;
                    }
                    if(_S1528)
                    {
                        Shift _S1717 = Shift_x24init_0(_S1714, 1.0f);
                        _S1212 = int(1);
                        ended_0 = _S1717;
                        spread_4 = _S1692;
                        width_5 = width_7;
                        throughput_8 = throughput_11;
                        b_11 = b_14;
                        break;
                    }
                    _S1212 = int(1);
                    ended_0 = _S1214;
                    spread_4 = _S1692;
                    width_5 = width_7;
                    throughput_8 = throughput_11;
                    b_11 = b_14;
                    break;
                }
                if(_S1639)
                {
                    Reservoir candidate_9 = _S1661;
                    uint _S1718 = extractBits_0(_S1661.path, 10U, 2U);
                    bool _S1719 = _S1718 == 1U;
                    if(_S1719)
                    {
                        float3  _S1720 = safeDivide(_S1714, chain_throughput_0);
                        (&candidate_9)->radiance = _S1720;
                    }
                    else
                    {
                        uint _S1721 = insertBits_0(0U, b_14 + 1U, 5U, 5U);
                        uint _S1722 = insertBits_0(_S1721, 2U, 10U, 2U);
                        (&candidate_9)->path = _S1722;
                    }
                    Reservoir _S1723 = withEnd(candidate_9, 0U, b_14, _S1714);
                    offer(sel_7, _S1723, _S1714 * make_float3 (scale_3) / make_float3 (density_3));
                    float _S1724 = survivalProbability(throughput_11, density_3);
                    uint _S1725 = stream(_S1241, b_14 + 128U);
                    Random _S1726 = pcg(_S1725);
                    bool _S1727 = _S1724 < (_S1726.value);
                    if(_S1727)
                    {
                        _S1528 = true;
                    }
                    else
                    {
                        uint _S1728 = (fcptMaxBounces());
                        _S1528 = b_14 >= _S1728;
                    }
                    if(_S1528)
                    {
                        _S1212 = int(1);
                        ended_0 = _S1214;
                        spread_4 = _S1692;
                        width_5 = width_7;
                        throughput_8 = throughput_11;
                        b_11 = b_14;
                        break;
                    }
                    float _S1729 = density_3 * _S1724;
                    density_3 = _S1729;
                }
                else
                {
                }
                float phase_pdf_1 = 0.0f;
                uint _S1730 = stream(_S1241, b_14);
                float3  _S1731 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1730, &phase_pdf_1);
                (&ray_2)->unit_direction = _S1731;
                NEEVertex _S1732 = NEEVertex_x24init_0(false, phase_pdf_1, (&ray_2)->origin, _S1213, (&ray_2)->origin);
                nee_vertex_0 = _S1732;
                Vertex _S1733 = scatteredVertex_0(is_inside_5);
                prev_0 = _S1733;
                float _S1734 = (&prev_0)->pdf;
                FKRay _S1735 = ray_2;
                FKHit _S1736 = (fcptTraverseInstanceBVH((_S1735), (true), (4.294967296e+09f), (false), (_S1441), (false)));
                hit_4 = _S1736;
                b_13 = b_14;
                throughput_10 = throughput_11;
                spread_3 = _S1692;
                width_4 = width_7;
                sky_pdf_1 = _S1734;
            }
            if(_S1212 != int(2))
            {
                spread_3 = spread_4;
                width_4 = width_5;
                throughput_10 = throughput_8;
                b_13 = b_11;
                _S1524 = true;
                break;
            }
            ended_0 = _S1214;
            _S1524 = false;
            break;
        }
        if(_S1524)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S1525 = b_13 == b_10;
        }
        else
        {
            _S1525 = false;
        }
        bool _S1737 = ((&hit_4)->instance_index) == 4294967295U;
        if(_S1737)
        {
            bool _S1738 = !(&nee_vertex_0)->none;
            float _S1739 = _slang_select(_S1738, sky_pdf_1,0.0f);
            float _S1740 = escapeWeight_0(_S1739, (&ray_2)->unit_direction);
            float3  _S1741 = environment_0((&ray_2)->unit_direction, b_13, (&prev_0)->lobe);
            float3  _S1742 = throughput_10 * _S1741;
            if(replay_2)
            {
                bool _S1743 = b_13 == _S1229;
                if(_S1743)
                {
                    passes_0 = _S1218 == 3U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(_S1742 * make_float3 (_S1740) / make_float3 (r_8->jac), density_3 / r_8->jac);
                }
                if(_S1228)
                {
                    passes_0 = _S1225;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = b_13 == _S1216;
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
                    return Shift_x24init_0(_S1742 * make_float3 (_S1740), 1.0f);
                }
                return _S1214;
            }
            Reservoir candidate_10 = chain_0;
            uint _S1744 = extractBits_0((&chain_0)->path, 10U, 2U);
            bool _S1745 = _S1744 == 1U;
            if(_S1745)
            {
                uint _S1746 = extractBits_0((&chain_0)->path, 5U, 5U);
                bool _S1747 = _S1746 == b_13;
                float _S1748 = _slang_select(_S1747, 1.0f,_S1740);
                float3  _S1749 = safeDivide(_S1742 * make_float3 (_S1748), chain_throughput_0);
                (&candidate_10)->radiance = _S1749;
            }
            else
            {
                bool _S1750 = (&prev_0)->rough;
                if(_S1750)
                {
                    uint _S1751 = insertBits_0(0U, b_13 + 1U, 5U, 5U);
                    uint _S1752 = insertBits_0(_S1751, 3U, 10U, 2U);
                    uint _S1753 = insertBits_0(_S1752, (&prev_0)->lobe, 15U, 3U);
                    bool _S1754 = (&prev_0)->inside;
                    uint _S1755 = _slang_select(_S1754, 1U,0U);
                    uint _S1756 = insertBits_0(_S1753, _S1755, 22U, 1U);
                    (&candidate_10)->path = _S1756;
                    (&candidate_10)->jac = (&prev_0)->pdf;
                    (&candidate_10)->dir = (&ray_2)->unit_direction;
                }
            }
            float3  _S1757 = _S1742 * make_float3 (_S1740);
            Reservoir _S1758 = withEnd(candidate_10, 3U, b_13, _S1757);
            offer(sel_7, _S1758, _S1757 * make_float3 (scale_3) / make_float3 (density_3));
            break;
        }
        float3  _S1759 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
        (&ray_2)->origin = _S1759;
        bool _S1760 = (fcptVaryingUsed());
        if(_S1760)
        {
            _S1526 = filling_2 != 4294967295U;
        }
        else
        {
            _S1526 = false;
        }
        if(_S1526)
        {
            if(_S1639)
            {
                float3  _S1761 = throughput_10 * glowed_0 / make_float3 (density_3);
                float3  _S1762 = sel_7->glow + _S1761;
                sel_7->glow = _S1762;
            }
            float3  _S1763 = throughput_10 * weight_1;
            throughput_8 = _S1763;
        }
        else
        {
            float3  _S1764 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
            float3  _S1765 = throughput_10 * _S1764;
            throughput_8 = _S1765;
        }
        float _S1766 = width_4 + spread_3 * (&hit_4)->distance;
        viewed_0 = _S1525;
        width_3 = _S1766;
        throughput_2 = throughput_8;
        density_2 = density_3;
        sky_pdf_0 = sky_pdf_1;
        spread_2 = spread_3;
        uint _S1653 = b_13 + 1U;
        b_10 = _S1653;
        layer_0 = _S1652;
    }
    return _S1214;
}

static __device__ Shift shift_0(Domain * dom_8, Reservoir * r_9)
{
    Selection _S1767 = (Selection{});
    Selection sel_8 = _S1767;
    bool _S1768 = (r_9->w) <= 0.0f;
    if(_S1768)
    {
        return Shift_x24init_0(make_float3 (0.0f), 0.0f);
    }
    Shift _S1769 = walk_0(dom_8, r_9, true, 0.0f, &sel_8);
    return _S1769;
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
        *_slang_vector_get_element_ptr(&result_14, i_20) = (F32_tan((_slang_vector_get_element(x_26, i_20))));
        i_20 = i_20 + int(1);
    }
    return result_14;
}

static __device__ float3  acos_0(float3  x_27)
{
    float3  result_15;
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
        *_slang_vector_get_element_ptr(&result_15, i_21) = (F32_acos((_slang_vector_get_element(x_27, i_21))));
        i_21 = i_21 + int(1);
    }
    return result_15;
}

static __device__ float3  abs_0(float3  x_28)
{
    float3  result_16;
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
        *_slang_vector_get_element_ptr(&result_16, i_22) = (F32_abs((_slang_vector_get_element(x_28, i_22))));
        i_22 = i_22 + int(1);
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

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_17)
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
    float3  t_23 = (_S1780 * make_float3 (_S1785) - _S1781 * make_float3 (_S1786)) * make_float3 (_S1789);
    float3  _S1790 = (_S1781 * make_float3 (_S1784) - _S1780 * make_float3 (_S1787)) * make_float3 (_S1789);
    float3  _S1791 = t_23 - n_17 * make_float3 (dot_0(n_17, t_23));
    float3  t_24 = ((((_S1791)) * make_float3(rnorm3df(((_S1791)).x, ((_S1791)).y, ((_S1791)).z))));
    bool _S1792 = (dot_0(cross_0(n_17, t_24), _S1790)) > 0.0f;
    float3  t_25;
    if(_S1792)
    {
        float3  _S1793 = negate_0(t_24);
        t_25 = _S1793;
    }
    else
    {
        t_25 = t_24;
    }
    float3  _S1794 = cross_0(n_17, t_25);
    return makeMatrix<float, 3, 3> (t_25, _S1794, n_17);
}

__device__ float3  tangentToWorldNormalMap(float3  v_8, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_8, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_5, float3  uvw_0, float3  position_0)
{
    float3  _S1795 = t1_0 - t0_0;
    float3  _S1796 = t2_2 - t0_0;
    float3  _S1797 = t2_2 - t1_0;
    float _S1798 = (F32_min((length_0(_S1795)), ((F32_min((length_0(_S1796)), (length_0(_S1797)))))));
    float3  _S1799 = make_float3 (distance_1(position_0, t0_0), distance_1(position_0, t1_0), distance_1(position_0, t2_2));
    float3  _S1800 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S1801 = dot_0(geometry_n_5, _S1800);
    float3  _S1802 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S1803 = dot_0(geometry_n_5, _S1802);
    float3  _S1804 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S1805 = acos_0(abs_0(make_float3 (_S1801, _S1803, dot_0(geometry_n_5, _S1804))));
    float3  _S1806 = clamp_2(tan_0(_S1805), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_1(dot_0(_S1799 * _S1806, uvw_0), 0.0f, _S1798 * 0.125f);
}

__device__ float3  straightThrough(float3  dir_15, float3  n_18, BSDFMaterial material_17)
{
    float3  _S1807 = negate_0(dir_15);
    float _S1808 = sign_0(dot_0(n_18, _S1807));
    float3  _S1809 = n_18 * make_float3 (_S1808);
    AnisotropicFrame _S1810 = anisotropicFrame(material_17, _S1809);
    bool _S1811 = (_S1810.alphas.x) > 0.0f;
    if(_S1811)
    {
        float _S1812 = material_17.transmission * (1.0f - material_17.metallic);
        float3  _S1813 = negate_0(_S1809);
        float3  _S1814 = anisotropicLocal(dir_15, _S1810.tangent, _S1813);
        float _S1815 = anisotropicG1(_S1814, _S1810.alphas);
        return make_float3 (_S1812 * _S1815) * material_17.albedo;
    }
    float _S1816 = material_17.transmission * (1.0f - material_17.metallic);
    float _S1817 = material_17.roughness;
    float _S1818 = smithG1(_S1817 * _S1817, (F32_abs((dot_0(n_18, dir_15)))));
    return make_float3 (_S1816 * _S1818) * material_17.albedo;
}

__device__ float hairRow(float3  in_dir_10, float3  t_26, float3  out_dir_4, uint p_13, float w_2, float alpha_6, uint nt_0)
{
    uint _S1819 = p_13 % 4U;
    float _S1820 = w_2 * HAIR_WIDTHS_0[_S1819];
    float _S1821 = (F32_asin((clamp_1(dot_0(out_dir_4, t_26), -1.0f, 1.0f)))) - (F32_asin((clamp_1(dot_0(in_dir_10, t_26), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S1819] * alpha_6;
    return ((F32_asinh((_S1821 / _S1820))) / (F32_asinh((3.14159274101257324f / _S1820))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_11, float3  t_27, float3  out_dir_5, uint np_0)
{
    float3  _S1822 = worldToTangent(out_dir_5, t_27);
    float3  _S1823 = worldToTangent(in_dir_11, t_27);
    return (F32_frac((((F32_atan2((_S1822.z), (_S1822.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S1823.z), (1.17549435082228751e-38f - _S1823.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_12, float3  t_28, uint p_14, float row_0, float column_0, float w_3, float alpha_7, uint nt_1, uint np_1)
{
    float3  _S1824 = worldToTangent(in_dir_12, t_28);
    uint _S1825 = p_14 % 4U;
    float _S1826 = w_3 * HAIR_WIDTHS_0[_S1825];
    float _S1827 = (F32_asin((clamp_1(dot_0(in_dir_12, t_28), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S1825] * alpha_7 + _S1826 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S1826))))));
    float _S1828 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S1824.z), (1.17549435082228751e-38f - _S1824.x)));
    float _S1829 = (F32_cos((_S1827)));
    float3  _S1830 = tangentToWorld(make_float3 (_S1829 * (F32_cos((_S1828))), (F32_sin((_S1827))), _S1829 * (F32_sin((_S1828)))), t_28);
    return _S1830;
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_19, BSDFMaterial material_18, float coverage_1)
{
    float3  _S1831;
    if((material_18.ior) == 1.0f)
    {
        float3  _S1832 = straightThrough(toward_1, n_19, material_18);
        _S1831 = _S1832;
    }
    else
    {
        _S1831 = make_float3 (0.0f);
    }
    return _S1831 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ Shift walk_hook(Domain dom_9, Reservoir r_10, bool replay_3, float scale_4, Selection * sel_9)
{
    Domain _S1833 = dom_9;
    Reservoir _S1834 = r_10;
    Shift _S1835 = walk_0(&_S1833, &_S1834, replay_3, scale_4, sel_9);
    return _S1835;
}

__device__ Shift shift_hook(Domain dom_10, Reservoir r_11)
{
    Domain _S1836 = dom_10;
    Reservoir _S1837 = r_11;
    Shift _S1838 = shift_0(&_S1836, &_S1837);
    return _S1838;
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
