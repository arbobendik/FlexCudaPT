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

static __device__ BSDFLobes BSDFLobes_x24init_0(float v_dot_h_0, float n_dot_h_0, float3  refracted_1, float3  F_0, float F_greyscale_0, float reflect_weight_0, float3  diffuse_weight_0, float3  refract_weight_0, float p_diffuse_0, float p_reflect_0, float p_refract_0, float translucent_share_0, float3  sheen_0, float p_sheen_velvet_0, float3  view_0, float3  tangent_1, float2  alphas_3, float visible_0, float p_toon_0, float3  toon_0, float toon_a_0, float toon_s_0, float toon_b_0, bool toon_glossy_0, float toon_norm_0, float toon_view_0, float3  toon_axis_0)
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
    (&_S383)->p_toon = p_toon_0;
    (&_S383)->toon = toon_0;
    (&_S383)->toon_a = toon_a_0;
    (&_S383)->toon_s = toon_s_0;
    (&_S383)->toon_b = toon_b_0;
    (&_S383)->toon_glossy = toon_glossy_0;
    (&_S383)->toon_norm = toon_norm_0;
    (&_S383)->toon_view = toon_view_0;
    (&_S383)->toon_axis = toon_axis_0;
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
    float _S422 = material_1.toon.x;
    bool _S423 = _S422 < 0.0f;
    float _S424 = (F32_abs((_S422)));
    bool _S425 = _S424 > 0.0f;
    float toon_a_1;
    float toon_s_1;
    float toon_b_1;
    float toon_norm_1;
    float toon_view_1;
    float3  toon_1;
    float3  toon_axis_1;
    bool _S426;
    if(_S425)
    {
        float _S427 = (F32_min((_S424), (1.0f)));
        float3  scale_2 = scale_1 * make_float3 (1.0f - _S427);
        float _S428 = rgb_to_greyscale(material_1.albedo);
        float _S429 = _S427 * _S428;
        float3  _S430 = make_float3 (_S427) * material_1.albedo;
        float toon_a_2 = clamp_1(material_1.toon.y / _S422, 0.00000999999974738f, 1.0f) * 3.14159274101257324f / 2.0f;
        float toon_s_2 = clamp_1(material_1.toon.z / _S422, 0.0f, 1.0f) * 3.14159274101257324f / 2.0f;
        float _S431 = (F32_min((toon_a_2 + toon_s_2), (1.57079637050628662f)));
        if(_S423)
        {
            toon_component_0 = 1.0f - (F32_cos(((F32_min((_S431), (toon_a_2))))));
        }
        else
        {
            float _S432 = (F32_sin(((F32_min((_S431), (toon_a_2))))));
            toon_component_0 = _S432 * _S432 / 2.0f;
        }
        bool _S433 = _S431 > toon_a_2;
        if(_S433)
        {
            _S426 = toon_s_2 > 0.0f;
        }
        else
        {
            _S426 = false;
        }
        if(_S426)
        {
            if(_S423)
            {
                float _S434 = (F32_cos((toon_a_2)));
                float _S435 = (F32_cos((_S431)));
                toon_a_1 = (1.0f + toon_a_2 / toon_s_2) * (_S434 - _S435) - ((F32_sin((_S431))) - _S431 * _S435 - ((F32_sin((toon_a_2))) - toon_a_2 * _S434)) / toon_s_2;
            }
            else
            {
                float _S436 = 2.0f * toon_a_2;
                float _S437 = (F32_cos((_S436)));
                float _S438 = 2.0f * _S431;
                float _S439 = (F32_cos((_S438)));
                toon_a_1 = (1.0f + toon_a_2 / toon_s_2) * (_S437 - _S439) / 4.0f - ((F32_sin((_S438))) / 8.0f - _S431 * _S439 / 4.0f - ((F32_sin((_S436))) / 8.0f - toon_a_2 * _S437 / 4.0f)) / toon_s_2;
            }
            float integral_0 = toon_component_0 + toon_a_1;
            toon_component_0 = integral_0;
        }
        float _S440 = 6.28318548202514648f * toon_component_0;
        float _S441 = dot_0(n_i_2, v_3);
        float _S442 = (F32_acos(((F32_min((_S441), (1.0f))))));
        if(_S442 < toon_a_2)
        {
            toon_component_0 = 1.0f;
        }
        else
        {
            toon_component_0 = (F32_max((1.0f - (_S442 - toon_a_2) / (F32_max((toon_s_2), (0.0000152587890625f)))), (0.0f)));
        }
        if(_S423)
        {
            float3  _S443 = make_float3 (2.0f * _S441) * n_i_2 - v_3;
            float3  _S444 = ((((_S443)) * make_float3(rnorm3df(((_S443)).x, ((_S443)).y, ((_S443)).z))));
            scale_1 = _S444;
        }
        else
        {
            scale_1 = n_i_2;
        }
        float _S445 = toon_component_0;
        toon_component_0 = _S429;
        toon_1 = _S430;
        toon_a_1 = toon_a_2;
        toon_s_1 = toon_s_2;
        toon_b_1 = _S431;
        toon_norm_1 = _S440;
        toon_view_1 = _S445;
        toon_axis_1 = scale_1;
        scale_1 = scale_2;
    }
    else
    {
        toon_component_0 = 0.0f;
        toon_1 = _S399;
        toon_a_1 = 0.0f;
        toon_s_1 = 0.0f;
        toon_b_1 = 0.0f;
        toon_norm_1 = 1.0f;
        toon_view_1 = 0.0f;
        toon_axis_1 = n_i_2;
    }
    float3  _S446 = mix_0(_S396, material_1.albedo, material_1.metallic);
    float3  F_1 = _S446 * scale_1;
    float _S447 = rgb_to_greyscale(F_1);
    float _S448 = 1.0f - material_1.metallic;
    float3  _S449 = make_float3 (1.0f) - _S396;
    float3  _S450 = make_float3 ((1.0f - material_1.transmission) * _S448) * _S449 * scale_1;
    float3  _S451 = make_float3 (material_1.transmission * _S448) * _S449 * scale_1;
    float _S452 = (F32_max((_S447), (0.0f)));
    float _S453 = rgb_to_greyscale(_S450);
    float _S454 = (F32_max((_S453), (0.0f)));
    float _S455 = rgb_to_greyscale(_S451);
    float _S456 = sign_0(length_0(_S388));
    float _S457 = (F32_max((_S455 * _S456), (0.0f)));
    float _S458 = _S452 + _S454 + _S457 + toon_component_0;
    float _S459 = (F32_min((sheen_component_0), (1.0f)));
    bool _S460 = sheen_component_0 > 0.0f;
    if(_S460)
    {
        _S426 = !(_S458 > 0.0f);
    }
    else
    {
        _S426 = false;
    }
    float _S461 = _slang_select(_S426, 1.0f,_S459);
    float _S462 = (1.0f - _S461) / (F32_max((_S458), (0.0000152587890625f)));
    float _S463 = _S454 * _S462;
    float _S464 = _S452 * _S462;
    float _S465 = _S457 * _S462;
    bool _S466 = (frame_1.alphas.x) > 0.0f;
    float visible_1;
    if(_S466)
    {
        float3  _S467 = anisotropicLocal(v_3, frame_1.tangent, n_i_2);
        float _S468 = anisotropicG1(_S467, frame_1.alphas);
        float3  _S469 = anisotropicLocal(ggx_n_0, frame_1.tangent, n_i_2);
        float _S470 = anisotropicD(_S469, frame_1.alphas);
        float _S471 = _S468 * _S470;
        visible_1 = _S471;
    }
    else
    {
        visible_1 = 0.0f;
    }
    return BSDFLobes_x24init_0(_S384, _S385, _S388, F_1, _S447, 1.0f, _S450, _S451, _S463, _S464, _S465, 0.0f, sheen_1, _S461, view_1, frame_1.tangent, frame_1.alphas, visible_1, toon_component_0 * _S462, toon_1, toon_a_1, toon_s_1, toon_b_1, _S423, toon_norm_1, toon_view_1, toon_axis_1);
}

__device__ float translucentShare(BSDFMaterial material_2)
{
    float _S472 = rgb_to_greyscale(material_2.translucent);
    float _S473 = rgb_to_greyscale(material_2.albedo);
    float _S474 = _S472 / (_S473 + _S472);
    bool _S475 = _S472 > 0.0f;
    float _S476 = _slang_select(_S475, _S474,0.0f);
    return _S476;
}

__device__ float smithG1(float alpha_2, float n_dot_x_0)
{
    float _S477 = alpha_2 * alpha_2;
    float _S478 = 2.0f * n_dot_x_0 / (n_dot_x_0 + (F32_sqrt((_S477 + (1.0f - _S477) * n_dot_x_0 * n_dot_x_0))));
    bool _S479 = alpha_2 > 0.0f;
    float _S480 = _slang_select(_S479, _S478,1.0f);
    return _S480;
}

__device__ float trowbridgeReitz(float alpha_3, float n_dot_h_1)
{
    float _S481 = alpha_3 * alpha_3;
    float _S482 = (1.0f - n_dot_h_1) * (1.0f + n_dot_h_1) + _S481 * n_dot_h_1 * n_dot_h_1;
    return _S481 / (F32_max((3.14159274101257324f * _S482 * _S482), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ float lobeDensity(float n_i_dot_l_0, float l_dot_h_0, float n_i_dot_v_0, float alpha_4, BSDFLobes lobes_0, float eta_i_2, float eta_o_2, uint lobe_0)
{
    bool _S483 = lobe_0 == 0U;
    if(_S483)
    {
        float _S484 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
        float _S485 = lobes_0.p_diffuse * (F32_abs((n_i_dot_l_0))) * 0.31830987334251404f;
        float _S486 = 1.0f - lobes_0.translucent_share;
        bool _S487 = n_i_dot_l_0 < 0.0f;
        float _S488 = _slang_select(_S487, lobes_0.translucent_share,_S486);
        float _S489 = _S485 * _S488;
        bool _S490 = (lobes_0.translucent_share) > 0.0f;
        float _S491 = _slang_select(_S490, _S489,_S484);
        bool _S492 = n_i_dot_v_0 > 0.0f;
        float _S493 = _slang_select(_S492, _S491,0.0f);
        return _S493;
    }
    bool _S494 = lobe_0 == 4U;
    bool _S495;
    if(_S494)
    {
        float _S496 = lobes_0.p_sheen_velvet * 0.5f * 0.31830987334251404f;
        bool _S497 = n_i_dot_l_0 > 0.0f;
        if(_S497)
        {
            _S495 = n_i_dot_v_0 > 0.0f;
        }
        else
        {
            _S495 = false;
        }
        float _S498 = _slang_select(_S495, _S496,0.0f);
        return _S498;
    }
    bool _S499 = lobe_0 == 6U;
    float pdf_h_0;
    if(_S499)
    {
        float _S500 = _slang_select(lobes_0.toon_glossy, l_dot_h_0,n_i_dot_l_0);
        float _S501 = (F32_acos((clamp_1(_S500, -1.0f, 1.0f))));
        if(_S501 < (lobes_0.toon_a))
        {
            pdf_h_0 = 1.0f;
        }
        else
        {
            pdf_h_0 = (F32_max((1.0f - (_S501 - lobes_0.toon_a) / (F32_max((lobes_0.toon_s), (0.0000152587890625f)))), (0.0f)));
        }
        float _S502 = lobes_0.p_toon * pdf_h_0;
        float _S503 = _slang_select(lobes_0.toon_glossy, 1.0f,n_i_dot_l_0);
        float _S504 = _S502 * _S503 / lobes_0.toon_norm;
        if(lobes_0.toon_glossy)
        {
            _S495 = true;
        }
        else
        {
            _S495 = n_i_dot_l_0 > 0.0f;
        }
        float _S505 = _slang_select(_S495, _S504,0.0f);
        return _S505;
    }
    float _S506 = smithG1(alpha_4, n_i_dot_v_0);
    float _S507 = _S506 * lobes_0.v_dot_h;
    float _S508 = trowbridgeReitz(alpha_4, lobes_0.n_dot_h);
    float _S509 = _S507 * _S508 / n_i_dot_v_0;
    bool _S510 = alpha_4 > 0.0f;
    if(_S510)
    {
        _S495 = (lobes_0.v_dot_h) > 0.0f;
    }
    else
    {
        _S495 = false;
    }
    if(_S495)
    {
        _S495 = (lobes_0.n_dot_h) > 0.0f;
    }
    else
    {
        _S495 = false;
    }
    if(_S495)
    {
        _S495 = n_i_dot_v_0 > 0.0f;
    }
    else
    {
        _S495 = false;
    }
    float _S511 = _slang_select(_S495, _S509,0.0f);
    bool _S512 = (lobes_0.alphas.x) > 0.0f;
    if(_S512)
    {
        float _S513 = lobes_0.visible * lobes_0.v_dot_h / n_i_dot_v_0;
        bool _S514 = (lobes_0.v_dot_h) > 0.0f;
        if(_S514)
        {
            _S495 = (lobes_0.n_dot_h) > 0.0f;
        }
        else
        {
            _S495 = false;
        }
        if(_S495)
        {
            _S495 = n_i_dot_v_0 > 0.0f;
        }
        else
        {
            _S495 = false;
        }
        float _S515 = _slang_select(_S495, _S513,0.0f);
        pdf_h_0 = _S515;
    }
    else
    {
        pdf_h_0 = _S511;
    }
    bool _S516 = lobe_0 == 1U;
    if(_S516)
    {
        float _S517 = eta_i_2 * lobes_0.v_dot_h + eta_o_2 * l_dot_h_0;
        float _S518 = lobes_0.p_refract * pdf_h_0 * eta_o_2 * eta_o_2 * (F32_abs((l_dot_h_0))) / (_S517 * _S517);
        bool _S519 = eta_i_2 != eta_o_2;
        if(_S519)
        {
            _S495 = l_dot_h_0 < 0.0f;
        }
        else
        {
            _S495 = false;
        }
        float _S520 = _slang_select(_S495, _S518,0.0f);
        return _S520;
    }
    float _S521 = lobes_0.p_reflect * pdf_h_0 / (4.0f * lobes_0.v_dot_h);
    bool _S522 = pdf_h_0 > 0.0f;
    float _S523 = _slang_select(_S522, _S521,0.0f);
    return _S523;
}

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_0, uint random_state_3, bool refracted_2, uint lobe_1, float pdf_0)
{
    SampleBSDF _S524;
    (&_S524)->unit_direction = unit_direction_1;
    (&_S524)->throughput = throughput_0;
    (&_S524)->random_state = random_state_3;
    (&_S524)->refracted = refracted_2;
    (&_S524)->lobe = lobe_1;
    (&_S524)->pdf = pdf_0;
    return _S524;
}

__device__ __forceinline__ float3  lobeThroughput(float3  l_0, float3  n_i_3, float alpha_5, BSDFMaterial material_3, BSDFLobes lobes_1, uint lobe_2)
{
    bool _S525 = lobe_2 == 0U;
    if(_S525)
    {
        bool _S526 = (dot_0(n_i_3, l_0)) < 0.0f;
        float3  _S527 = _slang_select(_S526, material_3.translucent,material_3.albedo);
        float _S528 = 1.0f - lobes_1.translucent_share;
        float _S529 = _slang_select(_S526, lobes_1.translucent_share,_S528);
        float3  _S530 = _S527 / make_float3 (_S529);
        bool _S531 = (lobes_1.translucent_share) > 0.0f;
        float3  _S532 = _slang_select(_S531, _S530,material_3.albedo);
        return lobes_1.diffuse_weight * _S532 / make_float3 (lobes_1.p_diffuse);
    }
    bool _S533 = lobe_2 == 4U;
    float f_1;
    if(_S533)
    {
        float3  _S534 = l_0 + lobes_1.view;
        float3  _S535 = ((((_S534)) * make_float3(rnorm3df(((_S534)).x, ((_S534)).y, ((_S534)).z))));
        float _S536 = dot_0(n_i_3, _S535);
        float _S537 = (F32_max((dot_0(n_i_3, l_0)), (0.0f)));
        float _S538 = (F32_max((dot_0(n_i_3, lobes_1.view)), (0.0f)));
        float _S539 = 1.0f / (F32_max((material_3.sheen_roughness), (0.05000000074505806f)));
        float _S540 = 1.0f - _S536 * _S536;
        float _S541 = (2.0f + _S539) * (F32_pow(((F32_max((_S540), (0.0f)))), (0.5f * _S539))) * 0.5f * 0.31830987334251404f / (F32_max((4.0f * (_S537 + _S538 - _S537 * _S538)), (0.0000152587890625f)));
        bool _S542 = (material_3.velvet) > 0.0f;
        if(_S542)
        {
            float _S543 = (F32_max((material_3.sheen_roughness), (0.00999999977648258f)));
            float _S544 = _S543 * _S543;
            float _S545 = (F32_max((_S540), (0.0000152587890625f)));
            float _S546 = (F32_exp((- _S536 * _S536 / (_S545 * _S544)))) / (3.14159274101257324f * _S544 * _S545 * _S545) * (F32_min((1.0f), (2.0f * _S536 * (F32_min((_S537), (_S538))) / (F32_max(((F32_abs((dot_0(_S535, lobes_1.view))))), (0.0000152587890625f)))))) / (F32_max((4.0f * _S537 * _S538), (0.0000152587890625f)));
            f_1 = _S546;
        }
        else
        {
            f_1 = _S541;
        }
        return lobes_1.sheen * make_float3 (f_1 * _S537 * 2.0f * 3.14159274101257324f / lobes_1.p_sheen_velvet);
    }
    bool _S547 = lobe_2 == 6U;
    if(_S547)
    {
        float _S548 = (F32_max((dot_0(n_i_3, l_0)), (0.0f)));
        float _S549 = _slang_select(lobes_1.toon_glossy, _S548,lobes_1.toon_view);
        return lobes_1.toon * make_float3 (_S549) / make_float3 (lobes_1.p_toon);
    }
    bool _S550 = lobe_2 == 1U;
    if(_S550)
    {
        float _S551 = - dot_0(n_i_3, l_0);
        float _S552 = smithG1(alpha_5, (F32_max((_S551), (0.0f))));
        bool _S553 = (lobes_1.alphas.x) > 0.0f;
        if(_S553)
        {
            float3  _S554 = negate_0(n_i_3);
            float3  _S555 = anisotropicLocal(l_0, lobes_1.tangent, _S554);
            float _S556 = anisotropicG1(_S555, lobes_1.alphas);
            f_1 = _S556;
        }
        else
        {
            f_1 = _S552;
        }
        return lobes_1.refract_weight * make_float3 (f_1) * material_3.albedo / make_float3 (lobes_1.p_refract);
    }
    float _S557 = dot_0(n_i_3, l_0);
    float _S558 = smithG1(alpha_5, (F32_max((_S557), (0.0f))));
    bool _S559 = (lobes_1.alphas.x) > 0.0f;
    if(_S559)
    {
        float3  _S560 = anisotropicLocal(l_0, lobes_1.tangent, n_i_3);
        float _S561 = anisotropicG1(_S560, lobes_1.alphas);
        f_1 = _S561;
    }
    else
    {
        f_1 = _S558;
    }
    return make_float3 (lobes_1.reflect_weight * f_1) * lobes_1.F / make_float3 (lobes_1.p_reflect);
}

__device__ __forceinline__ SampleBSDF connectBSDF(float3  in_dir_1, float3  out_dir_0, float3  n_5, BSDFMaterial material_4, float eta_i_3, float eta_o_3, uint lobe_3, uint random_init_0)
{
    uint random_state_4 = random_init_0;
    float3  _S562 = negate_0(in_dir_1);
    float _S563 = dot_0(n_5, _S562);
    float _S564 = sign_0(_S563);
    float3  _S565 = n_5 * make_float3 (_S564);
    float _S566 = material_4.roughness;
    float _S567 = _S566 * _S566;
    AnisotropicFrame _S568 = anisotropicFrame(material_4, _S565);
    float3  _S569 = _S562 + out_dir_0;
    float3  _S570 = ((((_S569)) * make_float3(rnorm3df(((_S569)).x, ((_S569)).y, ((_S569)).z))));
    bool _S571 = lobe_3 == 0U;
    float3  ggx_n_1;
    if(_S571)
    {
        float3  _S572 = sampleHalfVector(_S562, _S565, _S567, _S568, &random_state_4);
        ggx_n_1 = _S572;
    }
    else
    {
        ggx_n_1 = _S570;
    }
    bool _S573 = lobe_3 == 1U;
    if(_S573)
    {
        float3  _S574 = negate_0(make_float3 (eta_i_3) * _S562 + make_float3 (eta_o_3) * out_dir_0);
        float3  _S575 = ((((_S574)) * make_float3(rnorm3df(((_S574)).x, ((_S574)).y, ((_S574)).z))));
        float _S576 = sign_0(dot_0(_S574, _S565));
        float3  _S577 = _S575 * make_float3 (_S576);
        ggx_n_1 = _S577;
    }
    bool _S578 = lobe_3 == 2U;
    if(_S578)
    {
        float3  _S579 = ((((_S569)) * make_float3(rnorm3df(((_S569)).x, ((_S569)).y, ((_S569)).z))));
        ggx_n_1 = _S579;
    }
    bool _S580 = lobe_3 == 4U;
    if(_S580)
    {
        float3  _S581 = ((((_S569)) * make_float3(rnorm3df(((_S569)).x, ((_S569)).y, ((_S569)).z))));
        ggx_n_1 = _S581;
    }
    bool _S582 = lobe_3 == 6U;
    if(_S582)
    {
        float3  _S583 = sampleHalfVector(_S562, _S565, _S567, _S568, &random_state_4);
        ggx_n_1 = _S583;
    }
    BSDFLobes _S584 = bsdfLobes(in_dir_1, _S562, _S565, ggx_n_1, material_4, eta_i_3, eta_o_3, _S568);
    BSDFLobes lobes_2 = _S584;
    float _S585 = translucentShare(material_4);
    (&lobes_2)->translucent_share = _S585;
    float _S586 = dot_0(out_dir_0, ggx_n_1);
    float _S587 = dot_0(out_dir_0, (&lobes_2)->toon_axis);
    float _S588 = _slang_select(_S582, _S587,_S586);
    float _S589 = lobeDensity(dot_0(_S565, out_dir_0), _S588, (F32_abs((_S563))), _S567, lobes_2, eta_i_3, eta_o_3, lobe_3);
    bool _S590 = !(_S589 > 0.0f);
    if(_S590)
    {
        float3  _S591 = make_float3 (0.0f);
        return SampleBSDF_x24init_0(_S591, _S591, 0U, false, 0U, 0.0f);
    }
    float3  _S592 = lobeThroughput(out_dir_0, _S565, _S567, material_4, lobes_2, lobe_3);
    return SampleBSDF_x24init_0(out_dir_0, _S592, random_state_4, _S573, lobe_3, _S589);
}

__device__ __forceinline__ float3  neeBSDF(float3  in_dir_2, float3  dir_3, float3  n_6, BSDFMaterial material_5, float eta_i_4, float eta_o_4, bool refracted_3, float pdf_1, bool power_0, uint random_state_5)
{
    float3  _S593 = make_float3 (0.0f);
    uint _S594;
    if((F32_abs((material_5.toon.x))) > 0.0f)
    {
        _S594 = 5U;
    }
    else
    {
        _S594 = 4U;
    }
    uint i_6 = 0U;
    float3  f_2 = _S593;
    for(;;)
    {
        if(i_6 < _S594)
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
        if(_S596)
        {
        }
        bool _S597;
        if(_S596)
        {
            float _S598 = rgb_to_greyscale(material_5.translucent);
            _S597 = _S598 > 0.0f;
        }
        else
        {
            _S597 = false;
        }
        bool _S599;
        if(_S597)
        {
            float _S600 = dot_0(n_6, dir_3);
            float3  _S601 = negate_0(in_dir_2);
            _S599 = ((_S600 * dot_0(n_6, _S601)) < 0.0f) == refracted_3;
        }
        else
        {
            _S599 = (_S595 == 1U) == refracted_3;
        }
        float3  f_3;
        if(_S599)
        {
            SampleBSDF _S602 = connectBSDF(in_dir_2, dir_3, n_6, material_5, eta_i_4, eta_o_4, _S595, random_state_5);
            bool _S603 = (_S602.pdf) > 0.0f;
            if(_S603)
            {
                if(power_0)
                {
                    float _S604 = _S602.pdf / pdf_1;
                    float3  f_4 = f_2 + _S602.throughput * make_float3 (_S602.pdf) / make_float3 (pdf_1 * (1.0f + _S604 * _S604));
                    f_3 = f_4;
                }
                else
                {
                    float3  f_5 = f_2 + _S602.throughput * make_float3 (_S602.pdf) / make_float3 (_S602.pdf + pdf_1);
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
    bool _S605 = wrongSide_0(is_inside_2, false, dir_4, surface_1.geometry_n);
    float3  _S606 = neeBSDF(in_dir_3, dir_4, surface_1.smooth_n, surface_1.material, eta_1.x, eta_1.y, _S605, pdf_2, false, random_state_6);
    return _S606;
}

static __device__ SkySample SkySample_x24init_0(float3  dir_5, float3  radiance_0, float3  color_0, uint random_state_7)
{
    SkySample _S607;
    (&_S607)->dir = dir_5;
    (&_S607)->radiance = radiance_0;
    (&_S607)->color = color_0;
    (&_S607)->random_state = random_state_7;
    return _S607;
}

static __device__ SkySample sampleSky_0(FKRay * ray_0, FKSurface * surface_2, float2  eta_2, bool is_inside_3, uint init_random_state_0, uint lobe_state_0, ShadowContext * context_2)
{
    uint2  _S608 = (fcptEnvironmentCdfSize());
    uint2  _S609 = make_uint2 (1U, 0U);
    uint2  _S610 = _S608 - _S609;
    Random _S611 = pcg(init_random_state_0);
    Random _S612 = pcg(_S611.state);
    Random _S613 = pcg(_S612.state);
    Random _S614 = pcg(_S613.state);
    uint _S615 = _S610.x;
    uint _S616 = searchCDF_0(make_uint2 (_S615, 0U), make_uint2 (0U, 1U), _S610.y, _S611.value);
    uint _S617 = searchCDF_0(make_uint2 (0U, _S616), _S609, _S615, _S612.value);
    float2  _S618 = make_float2 ((float)_S610.x, (float)_S610.y);
    float2  _S619 = (make_float2 (float(_S617), float(_S616)) + make_float2 (_S613.value, _S614.value)) / _S618 * make_float2 (6.28318548202514648f, 3.14159274101257324f);
    float _S620 = _S619.y;
    float _S621 = (F32_sin((_S620)));
    float _S622 = _S619.x;
    float3  _S623 = make_float3 (- _S621 * (F32_cos((_S622))), _S621 * (F32_sin((_S622))), (F32_cos((_S620))));
    float _S624 = environmentPdf_0(_S623);
    float3  _S625 = skyBSDF(ray_0->unit_direction, _S623, *surface_2, eta_2, is_inside_3, _S624, lobe_state_0);
    bool _S626 = !(_S624 > 0.0f);
    bool _S627;
    if(_S626)
    {
        _S627 = true;
    }
    else
    {
        _S627 = all_1(_S625 == make_float3 (0.0f));
    }
    if(_S627)
    {
        float3  _S628 = make_float3 (0.0f);
        return SkySample_x24init_0(_S623, _S628, _S628, _S614.state);
    }
    float3  _S629 = skyRadiance_0(ray_0->origin, surface_2, is_inside_3, _S623, context_2, _S614.state);
    return SkySample_x24init_0(_S623, _S629, _S625 * _S629, _S614.state);
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
    SampleBSDF _S630 = (fcptConnectHair((surface_3->hair), ((&surface_3->material)->albedo), ((&surface_3->material)->specular_tint), (in_dir_4), (light_1->dir)));
    float3  _S631 = _S630.throughput * make_float3 (_S630.pdf);
    float _S632 = light_1->density;
    float _S633 = 1.0f + _S630.pdf * _S630.pdf / (light_1->density * light_1->density);
    bool _S634;
    if(competing_0)
    {
        _S634 = _S632 > 0.0f;
    }
    else
    {
        _S634 = false;
    }
    float _S635 = _slang_select(_S634, _S633,1.0f);
    return _S631 / make_float3 (_S635) * light_1->radiance;
}

static __device__ TreeSample TreeSample_x24init_0(float3  dir_6, float3  radiance_1, float density_0, uint random_state_8)
{
    TreeSample _S636;
    (&_S636)->dir = dir_6;
    (&_S636)->radiance = radiance_1;
    (&_S636)->density = density_0;
    (&_S636)->random_state = random_state_8;
    return _S636;
}

__device__ uint pickChild(LightNode first_1, LightNode second_1, float3  p_11, float3  normal_3, float * pick_0, float * probability_3)
{
    float _S637 = importance(first_1, p_11, normal_3);
    float _S638 = importance(second_1, p_11, normal_3);
    float2  _S639 = make_float2 (_S637, _S638);
    bool _S640 = _S637 == 0.0f;
    bool _S641;
    if(_S640)
    {
        _S641 = _S638 == 0.0f;
    }
    else
    {
        _S641 = false;
    }
    if(_S641)
    {
        return 2U;
    }
    float _S642 = _S637 + _S638;
    bool _S643 = _S638 > 0.0f;
    if(_S643)
    {
        _S641 = (*pick_0 * _S642) >= _S637;
    }
    else
    {
        _S641 = false;
    }
    uint _S644 = uint(_S641);
    float _S645 = (F32_min(((*pick_0 * _S642 - float(_S644) * _S637) / _slang_vector_get_element(_S639, _S644)), (0.99999994039535522f)));
    *pick_0 = _S645;
    float _S646 = *probability_3 * (_slang_vector_get_element(_S639, _S644) / _S642);
    *probability_3 = _S646;
    return _S644;
}

__device__ float3  sampleSphere(float3  center_1, float radius_1, float3  p_12, float u1_0, float u2_0)
{
    float3  _S647 = center_1 - p_12;
    float _S648 = radius_1 * radius_1 / dot_0(_S647, _S647);
    float _S649 = u1_0 * _S648 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S648), (0.0f)))))));
    float _S650 = 2.0f * u1_0;
    bool _S651 = _S648 >= 1.0f;
    float _S652 = _slang_select(_S651, _S650,_S649);
    float _S653 = (F32_sqrt(((F32_max((_S652 * (2.0f - _S652)), (0.0f))))));
    float _S654 = 6.28318548202514648f * u2_0;
    float3  _S655 = make_float3 (_S653 * (F32_cos((_S654))), 1.0f - _S652, _S653 * (F32_sin((_S654))));
    float3  _S656 = ((((_S647)) * make_float3(rnorm3df(((_S647)).x, ((_S647)).y, ((_S647)).z))));
    float3  _S657 = tangentToWorld(_S655, _S656);
    return _S657;
}

__device__ float3  pointLightRadiance(float3  color_1, float intensity_0, float radius_2)
{
    return color_1 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_2 * radius_2);
}

static __device__ float raySphere_0(float3  center_2, float radius_3, FKRay * ray_1, float max_len_0)
{
    float3  _S658 = center_2 - ray_1->origin;
    float _S659 = dot_0(_S658, ray_1->unit_direction);
    float _S660 = dot_0(_S658, _S658) - _S659 * _S659;
    float _S661 = radius_3 * radius_3;
    bool _S662 = _S660 > _S661;
    if(_S662)
    {
        return 4.294967296e+09f;
    }
    float _S663 = (F32_sqrt((_S661 - _S660)));
    float _S664 = _S659 - _S663;
    float _S665 = _S659 + _S663;
    bool _S666 = _S664 > 0.0000152587890625f;
    bool _S667;
    if(_S666)
    {
        _S667 = _S664 < max_len_0;
    }
    else
    {
        _S667 = false;
    }
    if(_S667)
    {
        return _S664;
    }
    bool _S668 = _S665 > 0.0000152587890625f;
    if(_S668)
    {
        _S667 = _S665 < max_len_0;
    }
    else
    {
        _S667 = false;
    }
    if(_S667)
    {
        return _S665;
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
    Random _S669 = pcg(init_random_state_1);
    Random _S670 = pcg(_S669.state);
    Random _S671 = pcg(_S670.state);
    float3  _S672 = make_float3 (0.0f);
    TreeSample _S673 = TreeSample_x24init_0(_S672, _S672, 0.0f, _S671.state);
    TreeSample sample_0 = _S673;
    float3  _S674 = _slang_select(sided_0, _S672,smooth_n_2);
    float3  _S675 = origin_4 + make_float3 (geometry_offset_1) * smooth_n_2;
    float pick_1 = _S669.value;
    float probability_4 = 1.0f;
    uint n_7 = 0U;
    for(;;)
    {
        uint4  _S676 = (fcptLightNode((n_7)));
        if((_S676.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S677 = (fcptLightSecond((n_7)));
        uint _S678 = n_7 + 1U;
        LightNode _S679 = (fcptLightBounds((_S678)));
        LightNode _S680 = (fcptLightBounds((_S677)));
        uint _S681 = pickChild(_S679, _S680, origin_4, _S674, &pick_1, &probability_4);
        bool _S682 = _S681 > 1U;
        if(_S682)
        {
            return sample_0;
        }
        bool _S683 = _S681 == 1U;
        uint _S684 = _slang_select(_S683, _S677,_S678);
        n_7 = _S684;
    }
    bool _S685 = n_7 == 0U;
    bool _S686;
    if(_S685)
    {
        LightNode _S687 = (fcptLightBounds((0U)));
        float _S688 = importance(_S687, origin_4, _S674);
        _S686 = !(_S688 > 0.0f);
    }
    else
    {
        _S686 = false;
    }
    if(_S686)
    {
        return sample_0;
    }
    uint4  _S689 = (fcptLightNode((n_7)));
    FKHit _S690 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    bool _S691 = (_S689.x) == 2U;
    float3  emitter_point_0;
    float3  lift_n_0;
    float3  shadow_1;
    FKHit emitter_0;
    if(_S691)
    {
        FKLight _S692 = (fcptLight((_S689.y)));
        if(sided_0)
        {
            float _S693 = sign_0(dot_0(geometry_n_1, _S692.position - origin_4));
            float3  lift_n_1 = smooth_n_2 * make_float3 (_S693);
            float3  _S694 = origin_4 + make_float3 (geometry_offset_1) * lift_n_1;
            emitter_point_0 = _S694;
            lift_n_0 = lift_n_1;
        }
        else
        {
            emitter_point_0 = _S675;
            lift_n_0 = smooth_n_2;
        }
        bool _S695 = (_S692.variance) == 0.0f;
        if(_S695)
        {
            float3  _S696 = _S692.position - emitter_point_0;
            float3  _S697 = ((((_S696)) * make_float3(rnorm3df(((_S696)).x, ((_S696)).y, ((_S696)).z))));
            (&sample_0)->dir = _S697;
            float3  _S698 = _S692.color * make_float3 (_S692.intensity) / make_float3 (dot_0(_S696, _S696) * probability_4);
            (&sample_0)->radiance = _S698;
            shadow_1 = _S696;
        }
        else
        {
            float3  _S699 = sampleSphere(_S692.position, _S692.variance, emitter_point_0, _S670.value, _S671.value);
            (&sample_0)->dir = _S699;
            float _S700 = sphereDensity(_S692.position, _S692.variance, emitter_point_0);
            float _S701 = probability_4 * _S700;
            (&sample_0)->density = _S701;
            float3  _S702 = pointLightRadiance(_S692.color, _S692.intensity, _S692.variance);
            float3  _S703 = _S702 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S703;
            FKRay _S704 = Ray_x24init_0(emitter_point_0, (&sample_0)->dir);
            float _S705 = raySphere_0(_S692.position, _S692.variance, &_S704, 4.294967296e+09f);
            float3  _S706 = (&sample_0)->dir * make_float3 (_S705);
            shadow_1 = _S706;
        }
        emitter_0 = _S690;
        emitter_point_0 = _S672;
    }
    else
    {
        uint _S707 = _S689.y;
        uint _S708 = (fcptTriangleOffset((_S707)));
        uint _S709 = _S708 + _S689.z;
        Matrix<float, 3, 3>  _S710 = (fcptWorldTriangle((_S707), (_S709)));
        float _S711 = (F32_sqrt((_S670.value)));
        float2  _S712 = make_float2 (_S711 * (1.0f - _S671.value), _S711 * _S671.value);
        float3  _S713 = mul_0(make_float3 (1.0f - _S711, _S712.x, _S712.y), _S710);
        if(sided_0)
        {
            float _S714 = sign_0(dot_0(geometry_n_1, _S713 - origin_4));
            float3  lift_n_2 = smooth_n_2 * make_float3 (_S714);
            float3  _S715 = origin_4 + make_float3 (geometry_offset_1) * lift_n_2;
            emitter_point_0 = _S715;
            lift_n_0 = lift_n_2;
        }
        else
        {
            bool _S716 = !((dot_0(smooth_n_2, _S713 - origin_4)) > 0.0f);
            if(_S716)
            {
                return sample_0;
            }
            emitter_point_0 = _S675;
            lift_n_0 = smooth_n_2;
        }
        FKHit emitter_1 = Hit_x24init_0(_S712, _S707, _S709, 0U, 0.0f);
        float3  _S717 = _S713 - emitter_point_0;
        float3  _S718 = ((((_S717)) * make_float3(rnorm3df(((_S717)).x, ((_S717)).y, ((_S717)).z))));
        (&sample_0)->dir = _S718;
        float _S719 = solidAngle(probability_4, cross_0(_S710.rows[int(1)] - _S710.rows[int(0)], _S710.rows[int(2)] - _S710.rows[int(0)]), _S717);
        (&sample_0)->density = _S719;
        bool _S720 = (fcptShadowFirst());
        bool _S721 = !_S720;
        if(_S721)
        {
            FKSurface _S722 = (fcptLightSurfaceAt((emitter_1), (_S713), (_S671.state), ((&sample_0)->dir), (context_3->depth), (length_0(_S713 - origin_4))));
            (&sample_0)->random_state = _S722.random_state;
            float3  _S723 = _slang_select(_S722.skip, _S672,_S722.material.emissive);
            float3  _S724 = _S723 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S724;
        }
        shadow_1 = _S717;
        emitter_0 = emitter_1;
        emitter_point_0 = _S713;
    }
    FKHit _S725 = emitter_0;
    float3  _S726 = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, context_3, _S671.state, &_S725);
    bool _S727 = (fcptShadowFirst());
    if(_S727)
    {
        _S686 = (emitter_0.instance_index) != 4294967295U;
    }
    else
    {
        _S686 = false;
    }
    if(_S686)
    {
        _S686 = !all_1(_S726 == _S672);
    }
    else
    {
        _S686 = false;
    }
    if(_S686)
    {
        FKSurface _S728 = (fcptLightSurfaceAt((emitter_0), (emitter_point_0), (_S671.state), ((&sample_0)->dir), (context_3->depth), (length_0(emitter_point_0 - origin_4))));
        (&sample_0)->random_state = _S728.random_state;
        float3  _S729 = _slang_select(_S728.skip, _S672,_S728.material.emissive);
        float3  _S730 = _S729 / make_float3 ((&sample_0)->density);
        (&sample_0)->radiance = _S730;
    }
    float3  _S731 = (&sample_0)->radiance * _S726;
    bool _S732 = all_1(_S726 == _S672);
    float3  _S733 = _slang_select(_S732, _S672,_S731);
    (&sample_0)->radiance = _S733;
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
    float _S734 = 1.0f / (1.0f + b_3 / a_7 * (b_3 / a_7));
    bool _S735 = b_3 > 0.0f;
    float _S736 = _slang_select(_S735, _S734,1.0f);
    return _S736;
}

static __device__ float emissionWeight_0(NEEVertex * vertex_0, FKHit * hit_1, float3  light_point_1)
{
    bool _S737 = vertex_0->none;
    if(_S737)
    {
        return 1.0f;
    }
    uint _S738 = (fcptLightSlot((*hit_1)));
    float _S739 = lightPdf_0(vertex_0->origin, vertex_0->smooth_n, vertex_0->start, _S738, light_point_1);
    float _S740 = powerHeuristic(vertex_0->pdf, _S739);
    return _S740;
}

static __device__ float3  environment_0(float3  dir_7, uint depth_0, uint lobe_4)
{
    uint2  _S741 = (fcptEnvironmentMapSize());
    bool _S742 = (_S741.x) > 1U;
    bool _S743;
    if(_S742)
    {
        uint2  _S744 = (fcptEnvironmentMapSize());
        _S743 = (_S744.y) > 1U;
    }
    else
    {
        _S743 = false;
    }
    if(_S743)
    {
        float3  _S745 = (fcptEnvMapSample((dir_7), (depth_0), (lobe_4)));
        return _S745;
    }
    float3  _S746 = (fcptAmbient());
    return _S746;
}

static __device__ bool environmentMapped_0()
{
    uint2  _S747 = (fcptEnvironmentCdfSize());
    bool _S748 = (_S747.x) > 1U;
    bool _S749;
    if(_S748)
    {
        uint2  _S750 = (fcptEnvironmentCdfSize());
        _S749 = (_S750.y) > 1U;
    }
    else
    {
        _S749 = false;
    }
    bool _S751 = !_S749;
    if(_S751)
    {
        return false;
    }
    uint2  _S752 = (fcptEnvironmentMapSize());
    bool _S753 = (_S752.x) > 1U;
    if(_S753)
    {
        uint2  _S754 = (fcptEnvironmentMapSize());
        _S749 = (_S754.y) > 1U;
    }
    else
    {
        _S749 = false;
    }
    return _S749;
}

static __device__ float escapeWeight_0(float pdf_3, float3  dir_8)
{
    bool _S755 = pdf_3 <= 0.0f;
    bool _S756;
    if(_S755)
    {
        _S756 = true;
    }
    else
    {
        bool _S757 = environmentMapped_0();
        _S756 = !_S757;
    }
    if(_S756)
    {
        return 1.0f;
    }
    float _S758 = environmentPdf_0(dir_8);
    return pdf_3 / (pdf_3 + _S758);
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
    uint2  _S759 = uint2 {global_invocation_id_1.x, global_invocation_id_1.y};
    int2  _S760 = make_int2 ((int)_S759.x, (int)_S759.y);
    uint _S761 = previousSeed_0(_S760);
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
            uint _S762 = previousSeed_0(_S760 + make_int2 (x_16, y_5));
            bool _S763 = _S762 == _S761;
            uint _S764 = _slang_select(_S763, 1U,0U);
            uint count_3 = count_2 + _S764;
            int x_17 = x_16 + int(1);
            x_16 = x_17;
            count_2 = count_3;
        }
        int y_6 = y_5 + int(1);
        y_5 = y_6;
    }
    float _S765 = float(count_2 - 1U) / 288.0f;
    bool _S766 = _S761 != 0U;
    float _S767 = _slang_select(_S766, _S765,0.0f);
    fcptStoreDuplication((_S760), (make_uint4 ((F32_asuint((_S767))), 0U, 0U, 0U)));
    return;
}

__device__ uint stream(uint seed_3, uint index_0)
{
    uint _S768 = hash(index_0);
    uint _S769 = hash(seed_3 ^ _S768);
    return _S769;
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
    float _S770 = rgb_to_greyscale(weight_0);
    bool _S771 = _S770 > 0.0f;
    bool _S772;
    if(_S771)
    {
        _S772 = _S770 < 3.00000000549775576e+38f;
    }
    else
    {
        _S772 = false;
    }
    bool _S773 = !_S772;
    if(_S773)
    {
        return;
    }
    bool _S774 = sel_2->sums;
    if(_S774)
    {
        float3  _S775 = sel_2->color + weight_0;
        sel_2->color = _S775;
        return;
    }
    float _S776 = sel_2->w_sum + _S770;
    sel_2->w_sum = _S776;
    float3  _S777 = sel_2->color + weight_0;
    sel_2->color = _S777;
    Random _S778 = pcg(sel_2->random_state);
    sel_2->random_state = _S778.state;
    bool _S779 = (_S778.value * sel_2->w_sum) <= _S770;
    if(_S779)
    {
        sel_2->r = candidate_0;
    }
    return;
}

__device__ void offerShifted(Selection * sel_3, Reservoir r_3, Shift shifted_0, float mis_0)
{
    Reservoir candidate_1 = r_3;
    float3  _S780 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_1)->f = _S780;
    float _S781 = r_3.jac * shifted_0.jac;
    (&candidate_1)->jac = _S781;
    offer(sel_3, candidate_1, make_float3 (mis_0) * shifted_0.f * make_float3 (r_3.w));
    return;
}

__device__ Reservoir finalize(Selection sel_4, float c_1)
{
    Reservoir r_4 = sel_4.r;
    float _S782 = rgb_to_greyscale((&r_4)->f);
    float _S783 = sel_4.w_sum / _S782;
    bool _S784 = _S782 > 0.0f;
    float _S785 = _slang_select(_S784, _S783,0.0f);
    (&r_4)->w = _S785;
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
    uint2  _S786 = uint2 {global_invocation_id_2.x, global_invocation_id_2.y};
    int2  _S787 = make_int2 ((int)_S786.x, (int)_S786.y);
    float3  _S788 = make_float3 (0.0f);
    FKHit _S789 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S790 = Domain_x24init_0(_S788, _S788, &_S789, 0.0f, 0.0f);
    Domain dom_4 = _S790;
    bool _S791 = (fcptCurrentDomain((_S787), (&dom_4)));
    bool _S792 = !_S791;
    if(_S792)
    {
        Reservoir _S793 = (Reservoir{});
        fcptStoreReservoirPrevious((_S787), (_S793), ((&dom_4)->hit));
        return;
    }
    Reservoir _S794 = (fcptLoadReservoirTemporal((_S787)));
    uint t_12 = 0U;
    float count_4 = 0.0f;
    float c_sum_1 = _S794.c;
    for(;;)
    {
        uint _S795 = (fcptRestirNeighbours());
        if(t_12 < _S795)
        {
        }
        else
        {
            break;
        }
        int2  _S796 = partner_0(_S787, t_12);
        Domain neighbor_0 = _S790;
        bool _S797 = (fcptCurrentDomain((_S796), (&neighbor_0)));
        if(_S797)
        {
            float count_5 = count_4 + 1.0f;
            uint4  _S798 = (fcptReservoirTemporal((_S796), (0U)));
            float c_sum_2 = c_sum_1 + (U32_asfloat((_S798.w)));
            count_4 = count_5;
            c_sum_1 = c_sum_2;
        }
        uint t_13 = t_12 + 1U;
        t_12 = t_13;
    }
    float _S799 = _S794.c / (F32_max((count_4), (1.0f)));
    float _S800 = rgb_to_greyscale(_S794.f);
    bool _S801 = count_4 == 0.0f;
    float _S802 = _slang_select(_S801, 1.0f,0.0f);
    Selection _S803 = (Selection{});
    Selection sel_5 = _S803;
    uint _S804 = (fcptFrame());
    uint _S805 = hash(_S804);
    uint _S806 = global_invocation_id_2.x;
    uint2  _S807 = (fcptRenderSize());
    uint _S808 = stream(_S805, _S806 + _S807.x * global_invocation_id_2.y);
    uint _S809 = stream(_S808, 195U);
    (&sel_5)->random_state = _S809;
    t_12 = 0U;
    float canonical_mis_0 = _S802;
    for(;;)
    {
        uint _S810 = (fcptRestirNeighbours());
        if(t_12 < _S810)
        {
        }
        else
        {
            break;
        }
        int2  _S811 = partner_0(_S787, t_12);
        Domain neighbor_dom_0 = _S790;
        bool _S812 = (fcptCurrentDomain((_S811), (&neighbor_dom_0)));
        if(_S812)
        {
            Reservoir _S813 = (fcptLoadReservoirTemporal((_S811)));
            uint4  _S814 = (fcptShiftData((_S811), (t_12)));
            float4  _S815 = asfloat_0(_S814);
            uint4  _S816 = (fcptShiftData((_S787), (t_12)));
            float4  _S817 = asfloat_0(_S816);
            float _S818 = pairShare(_S813.c, _S799, c_sum_1);
            bool _S819 = _S800 > 0.0f;
            float canonical_mis_1;
            if(_S819)
            {
                float _S820 = rgb_to_greyscale(float3 {_S817.x, _S817.y, _S817.z});
                float _S821 = canonicalWeight(_S818, _S799, _S800, _S813.c, _S820);
                float canonical_mis_2 = canonical_mis_0 + _S821;
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            float3  _S822 = float3 {_S815.x, _S815.y, _S815.z};
            Shift _S823 = Shift_x24init_0(_S822, _S815.w);
            float _S824 = rgb_to_greyscale(_S813.f);
            float _S825 = rgb_to_greyscale(_S822);
            float _S826 = neighborWeight(_S818, _S813.c, _S824, _S799, _S825);
            offerShifted(&sel_5, _S813, _S823, _S826);
            canonical_mis_0 = canonical_mis_1;
        }
        uint t_14 = t_12 + 1U;
        t_12 = t_14;
    }
    offerShifted(&sel_5, _S794, Shift_x24init_0(_S794.f, 1.0f), canonical_mis_0);
    Reservoir _S827 = finalize(sel_5, c_sum_1);
    fcptStoreReservoirPrevious((_S787), (_S827), ((&dom_4)->hit));
    fcptStorePreviousLayer((_S787), (5U), (make_uint4 (asuint_0((&(&dom_4)->hit)->uv).x, asuint_0((&(&dom_4)->hit)->uv).y, 0U, 0U)));
    fcptAddColor((_S787), (make_float4 ((&sel_5)->color.x, (&sel_5)->color.y, (&sel_5)->color.z, 0.0f)));
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
    uint _S828 = queuedShift_0(workgroup_id_1, local_invocation_index_4);
    bool _S829 = _S828 != 4294967295U;
    if(_S829)
    {
        uint2  _S830 = make_uint2 (_S828, _S828 >> 14U) & make_uint2 (16383U);
        int2  _S831 = make_int2 ((int)_S830.x, (int)_S830.y);
        ShiftJob _S832 = (ShiftJob{});
        ShiftJob shift_job_0 = _S832;
        Shift _S833 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
        uint _S834 = _S828 >> 28U;
        bool _S835 = spatialJob_0(_S831, _S834, &shift_job_0, true);
        Shift shifted_1;
        if(_S835)
        {
            Domain _S836 = (&shift_job_0)->dom;
            Reservoir _S837 = (&shift_job_0)->r;
            Shift _S838 = passShift_0(&_S836, &_S837);
            shifted_1 = _S838;
        }
        else
        {
            shifted_1 = _S833;
        }
        fcptStoreShiftData((_S831), (_S834), (make_uint4 (asuint_1(shifted_1.f).x, asuint_1(shifted_1.f).y, asuint_1(shifted_1.f).z, (F32_asuint((shifted_1.jac))))));
    }
    return;
}

static __device__ void restir_prepass_0(uint3  global_invocation_id_3, uint local_invocation_index_5)
{
    uint2  _S839 = uint2 {global_invocation_id_3.x, global_invocation_id_3.y};
    int2  _S840 = make_int2 ((int)_S839.x, (int)_S839.y);
    FixedArray<uint, 3>  _S841;
    spatialBins_0(_S840, &_S841);
    FixedArray<uint, 3>  _S842 = _S841;
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
        bool _S843 = (_S842[t_15]) == 40U;
        if(_S843)
        {
            fcptStoreShiftData((_S840), (t_15), (make_uint4 (0U)));
        }
        uint t_16 = t_15 + 1U;
        t_15 = t_16;
    }
    FixedArray<uint, 3>  _S844 = _S842;
    queueShifts_0(_S840, &_S844, global_invocation_id_3, local_invocation_index_5);
    return;
}

static __device__ void restir_count_0(uint3  global_invocation_id_4, uint local_invocation_index_6)
{
    uint2  _S845 = uint2 {global_invocation_id_4.x, global_invocation_id_4.y};
    int2  _S846 = make_int2 ((int)_S845.x, (int)_S845.y);
    FixedArray<uint, 3>  _S847;
    spatialBins_0(_S846, &_S847);
    FixedArray<uint, 3>  _S848 = _S847;
    countShifts_0(&_S848, local_invocation_index_6);
    return;
}

static __device__ void restir_temporal_shift_0(uint3  workgroup_id_2, uint local_invocation_index_7)
{
    uint _S849 = queuedShift_0(workgroup_id_2, local_invocation_index_7);
    bool _S850 = _S849 != 4294967295U;
    if(_S850)
    {
        uint2  _S851 = make_uint2 (_S849, _S849 >> 14U) & make_uint2 (16383U);
        int2  _S852 = make_int2 ((int)_S851.x, (int)_S851.y);
        ShiftJob _S853 = (ShiftJob{});
        ShiftJob shift_job_1 = _S853;
        Shift _S854 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
        uint _S855 = _S849 >> 28U;
        bool _S856 = temporalJob_0(_S852, _S855, &shift_job_1, true);
        Shift shifted_2;
        if(_S856)
        {
            if(_S855 == 1U)
            {
                Shift _S857 = (fcptShiftPrevious(((&shift_job_1)->dom), ((&shift_job_1)->r)));
                shifted_2 = _S857;
            }
            else
            {
                Domain _S858 = (&shift_job_1)->dom;
                Reservoir _S859 = (&shift_job_1)->r;
                Shift _S860 = passShift_0(&_S858, &_S859);
                shifted_2 = _S860;
            }
        }
        else
        {
            shifted_2 = _S854;
        }
        fcptStoreTemporalShift((_S852), (_S855), (make_uint4 (asuint_1(shifted_2.f).x, asuint_1(shifted_2.f).y, asuint_1(shifted_2.f).z, (F32_asuint((shifted_2.jac))))));
    }
    return;
}

static __device__ void restir_temporal_prepass_0(uint3  global_invocation_id_5, uint local_invocation_index_8)
{
    uint2  _S861 = uint2 {global_invocation_id_5.x, global_invocation_id_5.y};
    int2  _S862 = make_int2 ((int)_S861.x, (int)_S861.y);
    FixedArray<uint, 3>  _S863;
    temporalBins_0(_S862, &_S863);
    FixedArray<uint, 3>  _S864 = _S863;
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
        bool _S865 = (_S864[t_17]) == 40U;
        if(_S865)
        {
            fcptStoreTemporalShift((_S862), (t_17), (make_uint4 (0U)));
        }
        uint t_18 = t_17 + 1U;
        t_17 = t_18;
    }
    FixedArray<uint, 3>  _S866 = _S864;
    queueShifts_0(_S862, &_S866, global_invocation_id_5, local_invocation_index_8);
    return;
}

static __device__ void restir_temporal_count_0(uint3  global_invocation_id_6, uint local_invocation_index_9)
{
    uint2  _S867 = uint2 {global_invocation_id_6.x, global_invocation_id_6.y};
    int2  _S868 = make_int2 ((int)_S867.x, (int)_S867.y);
    bool _S869 = (fcptSceneUnchanged());
    bool _S870 = !_S869;
    bool _S871;
    if(_S870)
    {
        uint2  _S872 = (fcptRenderSize());
        int2  _S873 = make_int2 ((int)_S872.x, (int)_S872.y);
        _S871 = all_0(_S868 < _S873);
    }
    else
    {
        _S871 = false;
    }
    if(_S871)
    {
        Reservoir _S874 = (fcptLoadReservoirInitial((_S868)));
        int2  _S875 = sampleNeighbor_0(_S868, _S874.seed);
        fcptStoreTemporalNeighbor((_S868), (_S875));
    }
    FixedArray<uint, 3>  _S876;
    temporalBins_0(_S868, &_S876);
    FixedArray<uint, 3>  _S877 = _S876;
    countShifts_0(&_S877, local_invocation_index_9);
    return;
}

static __device__ float interpolate_0(float a_8, float b_4, float t_19)
{
    return a_8 + (b_4 - a_8) * t_19;
}

__device__ float confidenceCap(float duplicated_0)
{
    float _S878 = interpolate_0(20.0f, 1.0f, (F32_pow((duplicated_0), (0.10000000149011612f))));
    return _S878;
}

__device__ float2  temporalWeights(float c_2, float p_c_1, float c_t_0, float p_t_0, float g_previous_0, float g_current_0)
{
    float _S879 = c_2 * p_c_1;
    float _S880 = c_t_0 * p_t_0;
    return make_float2 (_S879 / (_S879 + c_t_0 * g_previous_0), _S880 / (_S880 + c_2 * g_current_0));
}

static __device__ void restir_temporal_0(uint3  global_invocation_id_7)
{
    uint2  _S881 = uint2 {global_invocation_id_7.x, global_invocation_id_7.y};
    int2  _S882 = make_int2 ((int)_S881.x, (int)_S881.y);
    float3  _S883 = make_float3 (0.0f);
    FKHit _S884 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S885 = Domain_x24init_0(_S883, _S883, &_S884, 0.0f, 0.0f);
    Domain dom_5 = _S885;
    bool _S886 = (fcptCurrentDomain((_S882), (&dom_5)));
    bool _S887 = !_S886;
    if(_S887)
    {
        Reservoir _S888 = (Reservoir{});
        fcptStoreReservoirTemporal((_S882), (_S888), ((&dom_5)->hit));
        return;
    }
    Reservoir _S889 = (fcptLoadReservoirInitial((_S882)));
    bool _S890 = (fcptSceneUnchanged());
    int2  _S891;
    if(_S890)
    {
        int2  _S892 = sampleNeighbor_0(_S882, _S889.seed);
        _S891 = _S892;
    }
    else
    {
        int2  _S893 = (fcptLoadTemporalNeighbor((_S882)));
        _S891 = _S893;
    }
    bool _S894 = (_S891.x) >= int(0);
    Reservoir r_5;
    if(_S894)
    {
        Reservoir _S895 = (fcptLoadReservoirPrevious((_S891)));
        uint4  _S896 = (fcptDuplication((_S891)));
        float _S897 = (U32_asfloat((_S896.x)));
        uint _S898 = (fcptRestirDecorrelation());
        bool _S899 = _S898 == 1U;
        float _S900 = _slang_select(_S899, _S897,0.0f);
        float _S901 = confidenceCap(_S900);
        float _S902 = (F32_min((_S895.c), (_S901)));
        bool _S903 = (fcptSceneUnchanged());
        float4  _S904;
        if(_S903)
        {
            _S904 = make_float4 (_S895.f.x, _S895.f.y, _S895.f.z, 1.0f);
        }
        else
        {
            uint4  _S905 = (fcptTemporalShift((_S882), (0U)));
            _S904 = asfloat_0(_S905);
        }
        Domain own_1 = _S885;
        bool _S906;
        if(_S903)
        {
            _S906 = true;
        }
        else
        {
            bool _S907 = (fcptPreviousScenes());
            bool _S908 = !_S907;
            if(_S908)
            {
                _S906 = (_S889.w) > 0.0f;
            }
            else
            {
                _S906 = false;
            }
            if(_S906)
            {
                bool _S909 = (fcptStoredDomainInitial((_S882), (_S889.seed), (&own_1)));
                _S906 = _S909;
            }
            else
            {
                _S906 = false;
            }
            if(_S906)
            {
                Domain _S910 = (fcptPreviousDomain((_S891), (_S889.seed)));
                Domain _S911 = _S910;
                Domain _S912 = own_1;
                bool _S913 = sameDomain_0(&_S911, &_S912);
                _S906 = _S913;
            }
            else
            {
                _S906 = false;
            }
        }
        float4  _S914;
        if(_S906)
        {
            _S914 = make_float4 (_S889.f.x, _S889.f.y, _S889.f.z, 1.0f);
        }
        else
        {
            uint4  _S915 = (fcptTemporalShift((_S882), (1U)));
            _S914 = asfloat_0(_S915);
        }
        float _S916 = rgb_to_greyscale(_S889.f);
        float _S917 = rgb_to_greyscale(_S895.f);
        Selection _S918 = (Selection{});
        Selection sel_6 = _S918;
        uint _S919 = (fcptFrame());
        uint _S920 = hash(_S919);
        uint _S921 = global_invocation_id_7.x;
        uint2  _S922 = (fcptRenderSize());
        uint _S923 = stream(_S920, _S921 + _S922.x * global_invocation_id_7.y);
        uint _S924 = stream(_S923, 194U);
        (&sel_6)->random_state = _S924;
        float4  _S925 = _S914;
        float _S926 = rgb_to_greyscale(float3 {_S925.x, _S925.y, _S925.z});
        float4  _S927 = _S904;
        float3  _S928 = float3 {_S927.x, _S927.y, _S927.z};
        float _S929 = rgb_to_greyscale(_S928);
        float2  _S930 = temporalWeights(_S889.c, _S916, _S902, _S917, _S926, _S929);
        offerShifted(&sel_6, _S889, Shift_x24init_0(_S889.f, 1.0f), _S930.x);
        offerShifted(&sel_6, _S895, Shift_x24init_0(_S928, _S904.w), _S930.y);
        Reservoir _S931 = finalize(sel_6, _S889.c + _S902);
        r_5 = _S931;
    }
    else
    {
        r_5 = _S889;
    }
    fcptStoreReservoirTemporal((_S882), (r_5), ((&dom_5)->hit));
    return;
}

static __device__ void restir_initial_0(uint3  global_invocation_id_8)
{
    uint2  _S932 = uint2 {global_invocation_id_8.x, global_invocation_id_8.y};
    int2  _S933 = make_int2 ((int)_S932.x, (int)_S932.y);
    float3  _S934 = make_float3 (0.0f);
    float2  _S935 = make_float2 (0.0f);
    FKHit _S936 = Hit_x24init_0(_S935, 0U, 0U, 0U, 0.0f);
    Domain _S937 = Domain_x24init_0(_S934, _S934, &_S936, 0.0f, 0.0f);
    Domain dom_6 = _S937;
    bool _S938 = (fcptCurrentDomain((_S933), (&dom_6)));
    bool _S939 = !_S938;
    if(_S939)
    {
        Reservoir _S940 = (Reservoir{});
        fcptStoreReservoirInitial((_S933), (_S940), ((&dom_6)->hit));
        return;
    }
    uint _S941 = (fcptFrame());
    uint _S942 = hash(_S941);
    uint _S943 = global_invocation_id_8.x;
    uint2  _S944 = (fcptRenderSize());
    uint _S945 = stream(_S942, _S943 + _S944.x * global_invocation_id_8.y);
    Selection _S946 = (Selection{});
    Selection initial_0 = _S946;
    uint _S947 = stream(_S945, 193U);
    (&initial_0)->random_state = _S947;
    bool _S948 = (fcptRestirUsed());
    bool _S949 = !_S948;
    (&initial_0)->sums = _S949;
    uint _S950 = stream(_S945, 0U);
    (&(&initial_0)->r)->seed = _S950;
    FKHit _S951 = Hit_x24init_0(_S935, 4294967295U, 0U, 0U, 0.0f);
    uint _S952 = (fcptSamples());
    float _S953 = 1.0f / float(_S952);
    FKHit hit_2 = _S951;
    uint i_13 = 0U;
    for(;;)
    {
        uint _S954 = (fcptSamples());
        if(i_13 < _S954)
        {
        }
        else
        {
            break;
        }
        Reservoir _S955 = (Reservoir{});
        Reservoir r_6 = _S955;
        uint _S956 = stream(_S945, i_13);
        (&r_6)->seed = _S956;
        Domain path_0 = _S937;
        bool _S957 = (fcptStoredDomainInitial((_S933), ((&r_6)->seed), (&path_0)));
        bool _S958 = !_S957;
        if(_S958)
        {
            fcptMissed((_S933), (path_0), (_S953));
            uint i_14 = i_13 + 1U;
            i_13 = i_14;
            continue;
        }
        Domain _S959 = path_0;
        Reservoir _S960 = r_6;
        Shift _S961 = passWalk_0(&_S959, &_S960, false, _S953, &initial_0);
        bool _S962 = ((&(&initial_0)->r)->seed) == ((&r_6)->seed);
        FKHit hit_3;
        if(_S962)
        {
            FKHit _S963 = (&path_0)->hit;
            hit_3 = _S963;
        }
        else
        {
            hit_3 = hit_2;
        }
        hit_2 = hit_3;
        uint i_14 = i_13 + 1U;
        i_13 = i_14;
    }
    float3  _S964 = (&initial_0)->glow;
    float3  _S965 = (&initial_0)->color;
    bool _S966 = (&initial_0)->sums;
    float3  _S967 = _slang_select(_S966, _S965,_S934);
    fcptAddColor((_S933), (make_float4 ((_S964 + _S967).x, (_S964 + _S967).y, (_S964 + _S967).z, 1.0f)));
    Reservoir _S968 = finalize(initial_0, 1.0f);
    fcptStoreReservoirInitial((_S933), (_S968), (hit_2));
    return;
}

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_4, float3  origin_5, float3  smooth_n_3, float3  start_6)
{
    NEEVertex _S969;
    (&_S969)->none = none_0;
    (&_S969)->pdf = pdf_4;
    (&_S969)->origin = origin_5;
    (&_S969)->smooth_n = smooth_n_3;
    (&_S969)->start = start_6;
    return _S969;
}

struct Vertex
{
    bool rough;
    uint lobe;
    float pdf;
    float cos;
    bool inside;
};

static __device__ Vertex Vertex_x24init_0(bool rough_0, uint lobe_5, float pdf_5, float cos_0, bool inside_0)
{
    Vertex _S970;
    (&_S970)->rough = rough_0;
    (&_S970)->lobe = lobe_5;
    (&_S970)->pdf = pdf_5;
    (&_S970)->cos = cos_0;
    (&_S970)->inside = inside_0;
    return _S970;
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
    float3  _S971 = exp_0((make_float3 (sigma_1) - extinction_0) * make_float3 (distance_2));
    float3  _S972 = scatter_0 * _S971 / make_float3 (sigma_1);
    float3  _S973 = _slang_select(scatters_0, _S972,_S971);
    return _S973;
}

static __device__ bool scatterSampled_0(bool replay_1, uint b_5, uint stop_0, bool varying_0)
{
    bool _S974 = !replay_1;
    bool _S975;
    if(_S974)
    {
        _S975 = true;
    }
    else
    {
        bool _S976 = b_5 == stop_0;
        if(_S976)
        {
            _S975 = !varying_0;
        }
        else
        {
            _S975 = false;
        }
    }
    return _S975;
}

static __device__ uint arrivalLobe_0(uint b_6, uint prev_lobe_0)
{
    bool _S977 = b_6 > 0U;
    uint _S978 = _slang_select(_S977, prev_lobe_0,3U);
    return _S978;
}

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_0, uint depth_1, uint lobe_6, bool surface_4, float length_2, float width_1, FKHit * own_2, bool fiber_0)
{
    ShadowContext _S979;
    (&_S979)->extinction_behind = extinction_behind_0;
    (&_S979)->extinction_front = extinction_front_0;
    (&_S979)->fillings = fillings_0;
    (&_S979)->side = side_0;
    (&_S979)->depth = depth_1;
    (&_S979)->lobe = lobe_6;
    (&_S979)->surface = surface_4;
    (&_S979)->length = length_2;
    (&_S979)->width = width_1;
    (&_S979)->own = *own_2;
    (&_S979)->fiber = fiber_0;
    return _S979;
}

static __device__ float phaseHG_0(float g_0, float mu_0)
{
    bool _S980 = (F32_abs((g_0))) < 0.00100000004749745f;
    if(_S980)
    {
        return 0.07957746833562851f;
    }
    float _S981 = g_0 * g_0;
    return (1.0f - _S981) * 0.25f * 0.31830987334251404f / (F32_pow((1.0f + _S981 - 2.0f * g_0 * mu_0), (1.5f)));
}

__device__ float3  safeDivide(float3  a_9, float3  b_7)
{
    float3  _S982 = a_9 / b_7;
    float3  _S983 = make_float3 (0.0f);
    bool3  _S984 = b_7 == _S983;
    float3  _S985 = _slang_select(_S984, _S983,_S982);
    return _S985;
}

static __device__ uint insertBits_0(uint e_2, uint newbits_0, uint offset_1, uint count_6)
{
    uint _S986 = (1U << count_6) - 1U;
    return (e_2 & (~(_S986 << offset_1))) | ((newbits_0 & _S986) << offset_1);
}

__device__ Reservoir withEnd(Reservoir r_7, uint end_type_0, uint end_0, float3  f_6)
{
    Reservoir candidate_2 = r_7;
    uint _S987 = insertBits_0(r_7.path, end_0, 0U, 5U);
    uint _S988 = insertBits_0(_S987, end_type_0, 12U, 3U);
    (&candidate_2)->path = _S988;
    (&candidate_2)->f = f_6;
    return candidate_2;
}

__device__ float survivalProbability(float3  throughput_1, float density_1)
{
    return (F32_min(((F32_max(((F32_max((throughput_1.x), ((F32_max((throughput_1.y), (throughput_1.z)))))) / density_1), (0.0f)))), (1.0f)));
}

static __device__ float3  isotropic_0(uint random_state_9)
{
    Random _S989 = pcg(random_state_9);
    Random _S990 = pcg(_S989.state);
    float _S991 = 1.0f - 2.0f * _S989.value;
    float _S992 = (F32_sqrt(((F32_max((1.0f - _S991 * _S991), (0.0f))))));
    float _S993 = 6.28318548202514648f * _S990.value;
    return make_float3 (_S992 * (F32_cos((_S993))), _S992 * (F32_sin((_S993))), _S991);
}

static __device__ float3  samplePhase_0(float g_1, float3  dir_9, uint random_state_10, float * pdf_6)
{
    bool _S994 = (F32_abs((g_1))) < 0.00100000004749745f;
    if(_S994)
    {
        *pdf_6 = 0.07957746833562851f;
        float3  _S995 = isotropic_0(random_state_10);
        return _S995;
    }
    Random _S996 = pcg(random_state_10);
    Random _S997 = pcg(_S996.state);
    float _S998 = g_1 * g_1;
    float _S999 = 2.0f * g_1;
    float _S1000 = (1.0f - _S998) / (1.0f - g_1 + _S999 * _S996.value);
    float _S1001 = clamp_1((1.0f + _S998 - _S1000 * _S1000) / _S999, -1.0f, 1.0f);
    float _S1002 = (F32_sqrt(((F32_max((1.0f - _S1001 * _S1001), (0.0f))))));
    float _S1003 = 6.28318548202514648f * _S997.value;
    float _S1004 = phaseHG_0(g_1, _S1001);
    *pdf_6 = _S1004;
    float3  _S1005 = tangentToWorld(make_float3 (_S1002 * (F32_cos((_S1003))), _S1001, _S1002 * (F32_sin((_S1003)))), dir_9);
    float3  _S1006 = ((((_S1005)) * make_float3(rnorm3df(((_S1005)).x, ((_S1005)).y, ((_S1005)).z))));
    return _S1006;
}

static __device__ Vertex scatteredVertex_0(bool is_inside_4)
{
    return Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_4);
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_0, float3  emissive_0, float roughness_0, float metallic_0, float transmission_0, float ior_0, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_2, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_2, float velvet_0, float3  toon_2)
{
    BSDFMaterial _S1007;
    (&_S1007)->albedo = albedo_0;
    (&_S1007)->emissive = emissive_0;
    (&_S1007)->roughness = roughness_0;
    (&_S1007)->metallic = metallic_0;
    (&_S1007)->transmission = transmission_0;
    (&_S1007)->ior = ior_0;
    (&_S1007)->absorption = absorption_0;
    (&_S1007)->specular_tint = specular_tint_0;
    (&_S1007)->specular_level = specular_level_0;
    (&_S1007)->translucent = translucent_0;
    (&_S1007)->sheen = sheen_2;
    (&_S1007)->sheen_roughness = sheen_roughness_0;
    (&_S1007)->anisotropy = anisotropy_0;
    (&_S1007)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S1007)->tangent = tangent_2;
    (&_S1007)->velvet = velvet_0;
    (&_S1007)->toon = toon_2;
    return _S1007;
}

static __device__ FKMedium Medium_x24init_0(float3  scatter_1, float3  extinction_1, float g_2)
{
    FKMedium _S1008;
    (&_S1008)->scatter = scatter_1;
    (&_S1008)->extinction = extinction_1;
    (&_S1008)->g = g_2;
    return _S1008;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_6, bool skip_0, uint random_state_11, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S1009;
    (&_S1009)->smooth_n = smooth_n_4;
    (&_S1009)->geometry_n = geometry_n_2;
    (&_S1009)->geometry_offset = geometry_offset_2;
    (&_S1009)->material = *material_6;
    (&_S1009)->skip = skip_0;
    (&_S1009)->random_state = random_state_11;
    (&_S1009)->coverage = coverage_0;
    (&_S1009)->encloses = encloses_0;
    (&_S1009)->volume = *volume_0;
    (&_S1009)->fills = fills_0;
    (&_S1009)->hair = hair_0;
    return _S1009;
}

static __device__ FKSurface emitting_0(FKSurface * surface_5, bool top_0)
{
    FKSurface lower_0 = *surface_5;
    float3  _S1010 = (&surface_5->material)->emissive;
    float3  _S1011 = make_float3 (0.0f);
    bool _S1012 = !top_0;
    float3  _S1013 = _slang_select(_S1012, _S1011,_S1010);
    (&(&lower_0)->material)->emissive = _S1013;
    return lower_0;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_6, float u_2)
{
    float _S1014 = surface_6->coverage;
    bool _S1015 = u_2 < _S1014;
    if(_S1015)
    {
        return *surface_6;
    }
    float3  _S1016 = make_float3 (0.0f);
    float3  _S1017 = make_float3 (1.0f);
    BSDFMaterial _S1018 = Material_x24init_0(_S1016, _S1016, 0.0f, 0.0f, 0.0f, 0.0f, _S1016, _S1017, 1.0f, _S1016, _S1016, 0.5f, 0.0f, 0.0f, _S1016, 0.0f, _S1016);
    BSDFMaterial material_7 = _S1018;
    (&material_7)->albedo = _S1017;
    (&material_7)->emissive = (&surface_6->material)->emissive;
    (&material_7)->transmission = 1.0f;
    (&material_7)->ior = 1.0f;
    (&material_7)->absorption = (&surface_6->material)->absorption;
    FKSurface through_0 = *surface_6;
    (&through_0)->material = material_7;
    return through_0;
}

__device__ float facingSign(float transmission_1, float3  face_0, float3  direction_0)
{
    bool _S1019 = transmission_1 > 0.0f;
    bool _S1020;
    if(_S1019)
    {
        _S1020 = true;
    }
    else
    {
        _S1020 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S1021;
    if(_S1020)
    {
        _S1021 = 1.0f;
    }
    else
    {
        _S1021 = -1.0f;
    }
    return _S1021;
}

static __device__ bool arrivesBehind_0(float3  dir_10, float3  n_8)
{
    return (dot_0(dir_10, n_8)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_7, float3  dir_11)
{
    float3  _S1022 = surface_7->geometry_n;
    float _S1023 = facingSign((&surface_7->material)->transmission, surface_7->geometry_n, dir_11);
    FKSurface faced_0 = *surface_7;
    float3  _S1024 = surface_7->smooth_n * make_float3 (_S1023);
    (&faced_0)->smooth_n = _S1024;
    float3  _S1025 = _S1022 * make_float3 (_S1023);
    (&faced_0)->geometry_n = _S1025;
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
    float3  _S1026 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_3) * log_0(_S1026));
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
    bool _S1027;
    if(open_0)
    {
        _S1027 = prev_rough_0;
    }
    else
    {
        _S1027 = false;
    }
    if(_S1027)
    {
        _S1027 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S1027 = false;
    }
    return _S1027;
}

__device__ float2  vertexEta(BSDFMaterial material_8, float n_dot_v_0)
{
    bool _S1028 = n_dot_v_0 < 0.0f;
    float _S1029 = _slang_select(_S1028, material_8.ior,1.0f);
    float _S1030 = _slang_select(_S1028, 1.0f,material_8.ior);
    return make_float2 (_S1029, _S1030);
}

__device__ bool neeDecision(BSDFMaterial material_9, float n_dot_v_1, float eta_i_5, float eta_o_5)
{
    float _S1031 = fresnel((F32_abs((n_dot_v_1))), eta_i_5, eta_o_5);
    float3  _S1032 = mix_0(make_float3 (_S1031), material_9.albedo, material_9.metallic);
    float _S1033 = rgb_to_greyscale(_S1032);
    float _S1034 = (F32_max(((1.0f - _S1033) * (1.0f - material_9.metallic) * (1.0f - material_9.transmission)), (0.0f)));
    bool _S1035 = _S1034 > 0.03999999910593033f;
    bool _S1036;
    if(_S1035)
    {
        _S1036 = true;
    }
    else
    {
        _S1036 = (material_9.roughness) > 0.20000000298023224f;
    }
    return _S1036;
}

static __device__ bool isTranslucent_0(BSDFMaterial * material_10)
{
    float _S1037 = rgb_to_greyscale(material_10->translucent);
    return _S1037 > 0.0f;
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
    MediumSides _S1038;
    (&_S1038)->behind = *behind_0;
    (&_S1038)->front = *front_0;
    (&_S1038)->fillings = fillings_1;
    (&_S1038)->face = face_1;
    return _S1038;
}

static __device__ MediumSides mediumSides_0(FKSurface * surface_8, FKMedium * medium_0, uint filling_0, float3  dir_12, FKMedium * outside_0)
{
    float3  _S1039 = surface_8->geometry_n;
    MediumSides _S1040 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_8->geometry_n);
    MediumSides sides_0 = _S1040;
    bool _S1041 = surface_8->encloses;
    if(_S1041)
    {
        (&sides_0)->behind = surface_8->volume;
        *&((&(&sides_0)->fillings)->x) = surface_8->fills;
        bool _S1042 = (dot_0(dir_12, _S1039)) > 0.0f;
        if(_S1042)
        {
            (&sides_0)->front = *outside_0;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_9, bool turned_0, float3  extinction_2, uint filling_1, float3  dir_13, uint depth_2, uint lobe_7, float length_3, float width_2, FKHit * own_3, bool fiber_1, FKMedium * outside_1)
{
    float3  _S1043 = surface_9->geometry_n;
    ShadowContext _S1044 = ShadowContext_x24init_0(extinction_2, extinction_2, make_uint2 (filling_1), surface_9->geometry_n, depth_2, lobe_7, true, length_3, width_2, own_3, fiber_1);
    bool _S1045 = surface_9->encloses;
    ShadowContext context_4;
    if(_S1045)
    {
        FKSurface faced_1 = *surface_9;
        float3  _S1046 = - _S1043;
        float3  _S1047 = _slang_select(turned_0, _S1046,_S1043);
        (&faced_1)->geometry_n = _S1047;
        FKMedium _S1048 = Medium_x24init_0(make_float3 (0.0f), extinction_2, 0.0f);
        FKSurface _S1049 = faced_1;
        FKMedium _S1050 = _S1048;
        MediumSides _S1051 = mediumSides_0(&_S1049, &_S1050, filling_1, dir_13, outside_1);
        ShadowContext _S1052 = ShadowContext_x24init_0(_S1051.behind.extinction, _S1051.front.extinction, _S1051.fillings, _S1043, depth_2, lobe_7, true, length_3, width_2, own_3, fiber_1);
        if(turned_0)
        {
            uint2  _S1053 = _S1051.fillings;
            ShadowContext _S1054 = ShadowContext_x24init_0(_S1051.front.extinction, _S1051.behind.extinction, uint2 {_S1053.y, _S1053.x}, _S1043, depth_2, lobe_7, true, length_3, width_2, own_3, fiber_1);
            context_4 = _S1054;
        }
        else
        {
            context_4 = _S1052;
        }
    }
    else
    {
        context_4 = _S1044;
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

__device__ __forceinline__ float3  BSDF(float3  in_dir_5, float3  out_dir_1, float3  n_9, float3  g_n_0, BSDFMaterial material_11, float eta_i_6, float eta_o_6, uint random_state_12)
{
    float3  _S1055 = negate_0(in_dir_5);
    bool _S1056 = (dot_0(g_n_0, _S1055) * dot_0(g_n_0, out_dir_1)) > 0.0f;
    if(_S1056)
    {
        SampleBSDF _S1057 = connectBSDF(in_dir_5, out_dir_1, n_9, material_11, eta_i_6, eta_o_6, 0U, random_state_12);
        SampleBSDF _S1058 = connectBSDF(in_dir_5, out_dir_1, n_9, material_11, eta_i_6, eta_o_6, 2U, random_state_12);
        SampleBSDF _S1059 = connectBSDF(in_dir_5, out_dir_1, n_9, material_11, eta_i_6, eta_o_6, 4U, random_state_12);
        bool _S1060 = (F32_abs((material_11.toon.x))) > 0.0f;
        if(_S1060)
        {
            SampleBSDF _S1061 = connectBSDF(in_dir_5, out_dir_1, n_9, material_11, eta_i_6, eta_o_6, 6U, random_state_12);
            return _S1057.throughput * make_float3 (_S1057.pdf) + _S1058.throughput * make_float3 (_S1058.pdf) + _S1059.throughput * make_float3 (_S1059.pdf) + _S1061.throughput * make_float3 (_S1061.pdf);
        }
        return _S1057.throughput * make_float3 (_S1057.pdf) + _S1058.throughput * make_float3 (_S1058.pdf) + _S1059.throughput * make_float3 (_S1059.pdf);
    }
    SampleBSDF _S1062 = connectBSDF(in_dir_5, out_dir_1, n_9, material_11, eta_i_6, eta_o_6, 1U, random_state_12);
    return _S1062.throughput * make_float3 (_S1062.pdf);
}

__device__ float3  translucentCorrection(float3  in_dir_6, float3  out_dir_2, float3  n_10, float3  g_n_1, BSDFMaterial material_12, float eta_i_7, float eta_o_7, uint random_state_13)
{
    float _S1063 = dot_0(n_10, out_dir_2);
    float3  _S1064 = negate_0(in_dir_6);
    bool _S1065 = (_S1063 * dot_0(n_10, _S1064)) < 0.0f;
    SampleBSDF _S1066 = connectBSDF(in_dir_6, out_dir_2, n_10, material_12, eta_i_7, eta_o_7, 0U, random_state_13);
    float3  _S1067 = negate_0(in_dir_6);
    bool _S1068 = (dot_0(g_n_1, _S1067) * dot_0(g_n_1, out_dir_2)) > 0.0f;
    float3  _S1069 = make_float3 (0.0f);
    float3  _S1070 = _S1066.throughput * make_float3 (_S1066.pdf);
    float _S1071 = _slang_select(_S1068, -1.0f,1.0f);
    float3  _S1072 = _S1070 * make_float3 (_S1071);
    float3  _S1073 = _slang_select(_S1065, _S1072,_S1069);
    return _S1073;
}

__device__ float3  translucentBSDF(float3  in_dir_7, float3  out_dir_3, float3  n_11, float3  g_n_2, BSDFMaterial material_13, float eta_i_8, float eta_o_8, uint random_state_14)
{
    float3  _S1074 = BSDF(in_dir_7, out_dir_3, n_11, g_n_2, material_13, eta_i_8, eta_o_8, random_state_14);
    float3  _S1075 = translucentCorrection(in_dir_7, out_dir_3, n_11, g_n_2, material_13, eta_i_8, eta_o_8, random_state_14);
    return _S1074 + _S1075;
}

static __device__ __forceinline__ float3  lightBSDF_0(float3  in_dir_8, TreeSample * light_2, float3  smooth_n_5, float3  geometry_n_4, BSDFMaterial * material_14, float eta_i_9, float eta_o_9, bool competing_1, uint random_state_15)
{
    bool _S1076 = !competing_1;
    bool _S1077;
    if(_S1076)
    {
        _S1077 = true;
    }
    else
    {
        _S1077 = (light_2->density) == 0.0f;
    }
    if(_S1077)
    {
        bool _S1078 = isTranslucent_0(material_14);
        if(_S1078)
        {
            float3  _S1079 = translucentBSDF(in_dir_8, light_2->dir, smooth_n_5, geometry_n_4, *material_14, eta_i_9, eta_o_9, random_state_15);
            return _S1079 * light_2->radiance;
        }
        float3  _S1080 = BSDF(in_dir_8, light_2->dir, smooth_n_5, geometry_n_4, *material_14, eta_i_9, eta_o_9, random_state_15);
        return _S1080 * light_2->radiance;
    }
    float3  _S1081 = light_2->dir;
    bool _S1082 = (dot_0(geometry_n_4, - in_dir_8) * dot_0(geometry_n_4, light_2->dir)) <= 0.0f;
    float3  _S1083 = neeBSDF(in_dir_8, _S1081, smooth_n_5, *material_14, eta_i_9, eta_o_9, _S1082, light_2->density, true, random_state_15);
    return _S1083 * light_2->radiance * make_float3 (light_2->density);
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S1084 = (F32_sqrt((random_1_0)));
    float _S1085 = 6.28318548202514648f * random_2_0;
    float _S1086 = _S1084 * (F32_cos((_S1085)));
    float _S1087 = _S1084 * (F32_sin((_S1085)));
    float _S1088 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1086 * _S1086 - _S1087 * _S1087))))));
    return make_float3 (_S1086, _S1088, _S1087);
}

static __device__ float3  reflect_0(float3  i_19, float3  n_12)
{
    return i_19 - make_float3 (2.0f * dot_0(n_12, i_19)) * n_12;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_9, float3  n_13, BSDFMaterial material_15, float eta_i_10, float eta_o_10, uint random_init_1, float2  screen_space_0)
{
    uint random_state_16 = random_init_1;
    float3  _S1089 = negate_0(in_dir_9);
    float _S1090 = dot_0(n_13, _S1089);
    float _S1091 = sign_0(_S1090);
    float3  n_i_4 = n_13 * make_float3 (_S1091);
    float _S1092 = (F32_abs((_S1090)));
    float _S1093 = material_15.roughness;
    float _S1094 = _S1093 * _S1093;
    AnisotropicFrame _S1095 = anisotropicFrame(material_15, n_i_4);
    float3  _S1096 = sampleHalfVector(_S1089, n_i_4, _S1094, _S1095, &random_state_16);
    BSDFLobes _S1097 = bsdfLobes(in_dir_9, _S1089, n_i_4, _S1096, material_15, eta_i_10, eta_o_10, _S1095);
    BSDFLobes lobes_3 = _S1097;
    float _S1098 = translucentShare(material_15);
    (&lobes_3)->translucent_share = _S1098;
    float3  _S1099 = make_float3 (1.0f);
    SampleBSDF _S1100 = SampleBSDF_x24init_0(_S1099, _S1099, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S1100;
    Random _S1101 = pcg(random_state_16);
    random_state_16 = _S1101.state;
    bool _S1102 = (_S1101.value) < ((&lobes_3)->p_sheen_velvet);
    if(_S1102)
    {
        Random _S1103 = pcg(random_state_16);
        Random _S1104 = pcg(_S1103.state);
        (&sample_1)->random_state = _S1104.state;
        float _S1105 = _S1103.value;
        float _S1106 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1105 * _S1105))))));
        float _S1107 = 6.28318548202514648f * _S1104.value;
        float3  _S1108 = tangentToWorld(make_float3 (_S1106 * (F32_cos((_S1107))), _S1103.value, _S1106 * (F32_sin((_S1107)))), n_i_4);
        (&sample_1)->unit_direction = _S1108;
        float3  _S1109 = lobeThroughput((&sample_1)->unit_direction, n_i_4, _S1094, material_15, lobes_3, 4U);
        (&sample_1)->throughput = _S1109;
        float _S1110 = lobeDensity(_S1103.value, 0.0f, _S1092, _S1094, lobes_3, eta_i_10, eta_o_10, 4U);
        (&sample_1)->pdf = _S1110;
        (&sample_1)->lobe = 4U;
        return sample_1;
    }
    float _S1111 = _S1101.value - (&lobes_3)->p_sheen_velvet;
    bool _S1112 = _S1111 < ((&lobes_3)->p_diffuse);
    if(_S1112)
    {
        Random _S1113 = pcg(random_state_16);
        Random _S1114 = pcg(_S1113.state);
        (&sample_1)->random_state = _S1114.state;
        float3  _S1115 = sampleCosWeightedHemisphere(_S1113.value, _S1114.value);
        bool _S1116 = _S1111 < ((&lobes_3)->p_diffuse * (&lobes_3)->translucent_share);
        float _S1117 = _S1115.y;
        float _S1118 = - _S1117;
        float _S1119 = _slang_select(_S1116, _S1118,_S1117);
        float3  _S1120 = tangentToWorld(make_float3 (_S1115.x, _S1119, _S1115.z), n_i_4);
        (&sample_1)->unit_direction = _S1120;
        float3  _S1121 = lobeThroughput((&sample_1)->unit_direction, n_i_4, _S1094, material_15, lobes_3, 0U);
        (&sample_1)->throughput = _S1121;
        float _S1122 = lobeDensity(_S1119, 0.0f, _S1092, _S1094, lobes_3, eta_i_10, eta_o_10, 0U);
        (&sample_1)->pdf = _S1122;
        (&sample_1)->refracted = _S1116;
        return sample_1;
    }
    bool _S1123 = _S1111 < ((&lobes_3)->p_diffuse + (&lobes_3)->p_toon);
    if(_S1123)
    {
        Random _S1124 = pcg(random_state_16);
        Random _S1125 = pcg(_S1124.state);
        (&sample_1)->random_state = _S1125.state;
        float _S1126 = (&lobes_3)->toon_a;
        float _S1127 = (&lobes_3)->toon_s;
        bool _S1128 = (&lobes_3)->toon_glossy;
        float _S1129 = _S1124.value * (&lobes_3)->toon_norm / 6.28318548202514648f;
        float t_20;
        if(_S1128)
        {
            t_20 = (F32_acos((clamp_1(1.0f - _S1129, -1.0f, 1.0f))));
        }
        else
        {
            t_20 = (F32_asin(((F32_min(((F32_sqrt((2.0f * _S1129)))), (1.0f))))));
        }
        if(t_20 < _S1126)
        {
        }
        else
        {
            t_20 = (_S1126 + (&lobes_3)->toon_b) / 2.0f;
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
            float _S1130;
            if(t_20 < _S1126)
            {
                _S1130 = 1.0f;
            }
            else
            {
                _S1130 = (F32_max((1.0f - (t_20 - _S1126) / (F32_max((_S1127), (0.0000152587890625f)))), (0.0f)));
            }
            float integral_1;
            if(_S1128)
            {
                integral_1 = 1.0f - (F32_cos(((F32_min((t_20), (_S1126))))));
            }
            else
            {
                float _S1131 = (F32_sin(((F32_min((t_20), (_S1126))))));
                integral_1 = _S1131 * _S1131 / 2.0f;
            }
            bool _S1132 = t_20 > _S1126;
            bool _S1133;
            if(_S1132)
            {
                _S1133 = _S1127 > 0.0f;
            }
            else
            {
                _S1133 = false;
            }
            float integral_2;
            if(_S1133)
            {
                if(_S1128)
                {
                    float _S1134 = (F32_cos((_S1126)));
                    float _S1135 = (F32_cos((t_20)));
                    integral_2 = (1.0f + _S1126 / _S1127) * (_S1134 - _S1135) - ((F32_sin((t_20))) - t_20 * _S1135 - ((F32_sin((_S1126))) - _S1126 * _S1134)) / _S1127;
                }
                else
                {
                    float _S1136 = 2.0f * _S1126;
                    float _S1137 = (F32_cos((_S1136)));
                    float _S1138 = 2.0f * t_20;
                    float _S1139 = (F32_cos((_S1138)));
                    integral_2 = (1.0f + _S1126 / _S1127) * (_S1137 - _S1139) / 4.0f - ((F32_sin((_S1138))) / 8.0f - t_20 * _S1139 / 4.0f - ((F32_sin((_S1136))) / 8.0f - _S1126 * _S1137 / 4.0f)) / _S1127;
                }
                float integral_3 = integral_1 + integral_2;
                integral_2 = integral_3;
            }
            else
            {
                integral_2 = integral_1;
            }
            float _S1140 = _S1130 * (F32_sin((t_20)));
            float _S1141;
            if(_S1128)
            {
                _S1141 = 1.0f;
            }
            else
            {
                _S1141 = (F32_cos((t_20)));
            }
            float _S1142 = _S1140 * _S1141;
            float _S1143 = (integral_2 - _S1129) / _S1142;
            bool _S1144 = _S1142 > 0.0f;
            float _S1145 = _slang_select(_S1144, _S1143,0.0f);
            float _S1146 = clamp_1(t_20 - _S1145, 0.0f, (&lobes_3)->toon_b);
            int k_1 = k_0 + int(1);
            t_20 = _S1146;
            k_0 = k_1;
        }
        float _S1147 = 6.28318548202514648f * _S1125.value;
        float _S1148 = (F32_sin((t_20)));
        float3  _S1149 = tangentToWorld(make_float3 (_S1148 * (F32_cos((_S1147))), (F32_cos((t_20))), _S1148 * (F32_sin((_S1147)))), (&lobes_3)->toon_axis);
        (&sample_1)->unit_direction = _S1149;
        float3  _S1150 = lobeThroughput((&sample_1)->unit_direction, n_i_4, _S1094, material_15, lobes_3, 6U);
        (&sample_1)->throughput = _S1150;
        float _S1151 = lobeDensity(dot_0(n_i_4, (&sample_1)->unit_direction), dot_0((&sample_1)->unit_direction, (&lobes_3)->toon_axis), _S1092, _S1094, lobes_3, eta_i_10, eta_o_10, 6U);
        (&sample_1)->pdf = _S1151;
        bool _S1152 = (dot_0(n_i_4, (&sample_1)->unit_direction)) < 0.0f;
        (&sample_1)->refracted = _S1152;
        (&sample_1)->lobe = 6U;
        return sample_1;
    }
    float _S1153 = _S1111 - (&lobes_3)->p_toon;
    bool _S1154 = _S1153 < ((&lobes_3)->p_diffuse + (&lobes_3)->p_refract);
    if(_S1154)
    {
        (&sample_1)->unit_direction = (&lobes_3)->refracted;
        float _S1155 = lobeDensity(0.0f, dot_0((&sample_1)->unit_direction, _S1096), _S1092, _S1094, lobes_3, eta_i_10, eta_o_10, 1U);
        (&sample_1)->pdf = _S1155;
        float3  _S1156 = lobeThroughput((&sample_1)->unit_direction, n_i_4, _S1094, material_15, lobes_3, 1U);
        (&sample_1)->throughput = _S1156;
        (&sample_1)->random_state = random_state_16;
        (&sample_1)->refracted = true;
        (&sample_1)->lobe = 1U;
        return sample_1;
    }
    float3  _S1157 = reflect_0(in_dir_9, _S1096);
    float3  _S1158 = ((((_S1157)) * make_float3(rnorm3df(((_S1157)).x, ((_S1157)).y, ((_S1157)).z))));
    (&sample_1)->unit_direction = _S1158;
    float3  _S1159 = lobeThroughput((&sample_1)->unit_direction, n_i_4, _S1094, material_15, lobes_3, 2U);
    (&sample_1)->throughput = _S1159;
    (&sample_1)->random_state = random_state_16;
    (&sample_1)->lobe = 2U;
    float _S1160 = lobeDensity(0.0f, 0.0f, _S1092, _S1094, lobes_3, eta_i_10, eta_o_10, 2U);
    (&sample_1)->pdf = _S1160;
    return sample_1;
}

__device__ bool withinInverseFootprint(float pdf_7, bool diffuse_0, float prev_cos_0, float distance_5, float threshold_1)
{
    bool _S1161 = pdf_7 > 0.0f;
    bool _S1162;
    if(_S1161)
    {
        if(diffuse_0)
        {
            _S1162 = true;
        }
        else
        {
            _S1162 = (pdf_7 * prev_cos_0 / (distance_5 * distance_5) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S1162 = false;
    }
    return _S1162;
}

__device__ bool roughLobe(float pdf_8, bool diffuse_1, float roughness_1)
{
    bool _S1163 = pdf_8 > 0.0f;
    bool _S1164;
    if(_S1163)
    {
        if(diffuse_1)
        {
            _S1164 = true;
        }
        else
        {
            _S1164 = roughness_1 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S1164 = false;
    }
    return _S1164;
}

static __device__ bool passesLayer_0(uint layers_0, bool refracting_0, bool passed_0)
{
    bool _S1165 = layers_0 > 1U;
    bool _S1166;
    if(_S1165)
    {
        _S1166 = refracting_0 != passed_0;
    }
    else
    {
        _S1166 = false;
    }
    return _S1166;
}

static __device__ float widened_0(float spread_1, float pdf_9, bool delta_0)
{
    float _S1167 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * pdf_9))))), (3.14159274101257324f)));
    bool _S1168 = !delta_0;
    float _S1169 = _slang_select(_S1168, _S1167,0.0f);
    return spread_1 + _S1169;
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
    uint b_8;
    uint layer_0;
    float3  throughput_2;
    float3  chain_throughput_0;
    TreeSample light_3;
    int _S1170;
    Shift ended_0;
    float density_3;
    float spread_3;
    float width_4;
    float sky_pdf_1;
    float spread_4;
    float width_5;
    uint b_9;
    float3  _S1171 = make_float3 (0.0f);
    Shift _S1172 = Shift_x24init_0(_S1171, 0.0f);
    uint _S1173 = r_8->path;
    uint _S1174 = extractBits_0(r_8->path, 0U, 5U);
    uint _S1175 = extractBits_0(_S1173, 5U, 5U);
    uint _S1176 = extractBits_0(_S1173, 10U, 2U);
    uint _S1177 = extractBits_0(_S1173, 12U, 3U);
    bool passes_0;
    if(replay_2)
    {
        bool _S1178 = _S1177 >= 3U;
        uint _S1179 = _slang_select(_S1178, 1U,0U);
        uint _S1180 = _S1174 + _S1179;
        uint _S1181 = (fcptMaxBounces());
        passes_0 = _S1180 > _S1181;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S1172;
    }
    uint _S1182 = _S1175 - 1U;
    bool _S1183 = _S1177 == 3U;
    uint _S1184 = _slang_select(_S1183, 1U,0U);
    uint _S1185 = _S1174 + _S1184;
    bool _S1186 = _S1176 == 0U;
    uint _S1187 = _slang_select(_S1186, _S1185,_S1182);
    FKHit _S1188 = (fcptReservoirHit((*r_8)));
    float3  _S1189 = dom_7->x0;
    float3  _S1190 = dom_7->x1 - dom_7->x0;
    float3  _S1191 = ((((_S1190)) * make_float3(rnorm3df(((_S1190)).x, ((_S1190)).y, ((_S1190)).z))));
    FKRay _S1192 = Ray_x24init_0(dom_7->x1, _S1191);
    FKRay ray_2 = _S1192;
    FKHit hit_4 = dom_7->hit;
    float3  scatter_in_0 = _S1171;
    float3  throughput_3 = make_float3 (1.0f);
    float3  weight_1 = throughput_3;
    float3  glowed_0 = _S1171;
    float3  extinction_in_0 = _S1171;
    float g_in_0 = 0.0f;
    uint filling_2 = 4294967295U;
    float _S1193 = dom_7->spread;
    float _S1194 = dom_7->width;
    float _S1195 = length_0(_S1190);
    NEEVertex _S1196 = NEEVertex_x24init_0(true, 0.0f, _S1171, _S1171, _S1171);
    NEEVertex nee_vertex_0 = _S1196;
    Vertex _S1197 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_0 = _S1197;
    Reservoir _S1198 = (Reservoir{});
    Reservoir chain_0 = _S1198;
    uint _S1199 = r_8->seed;
    (&chain_0)->seed = r_8->seed;
    (&ray_2)->origin = _S1189;
    (&hit_4)->distance = _S1195;
    FKMedium _S1200 = (fcptCameraMedium(((&ray_2)->unit_direction), ((&hit_4)->distance), (&filling_2)));
    uint _S1201 = filling_2;
    bool _S1202 = (fcptVaryingUsed());
    uint _S1203 = _slang_select(_S1202, _S1201,4294967295U);
    filling_2 = _S1203;
    scatter_in_0 = _S1200.scatter;
    extinction_in_0 = _S1200.extinction;
    g_in_0 = _S1200.g;
    Reservoir _S1204 = chain_0;
    uint _S1205 = filling_2;
    for(;;)
    {
        bool _S1206 = (fcptVaryingUsed());
        if(_S1206)
        {
            passes_0 = _S1205 != 4294967295U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            float _S1207 = (fcptMajorant((_S1205)));
            spread_2 = _S1207;
        }
        else
        {
            spread_2 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
        }
        if(replay_2)
        {
            turned_1 = 4294967295U == _S1187;
        }
        else
        {
            turned_1 = false;
        }
        if(turned_1)
        {
            turned_1 = _S1176 == 1U;
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
            ended_0 = _S1172;
            sky_pdf_0 = 0.0f;
            spread_2 = _S1193;
            width_3 = _S1194;
            density_2 = 1.0f;
            throughput_2 = throughput_3;
            b_8 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S1208 = (&prev_0)->rough;
        if(_S1208)
        {
            turned_1 = !(spread_2 > 0.0f);
        }
        else
        {
            turned_1 = false;
        }
        (&prev_0)->rough = turned_1;
        uint _S1209 = stream(_S1199, 384U);
        uint tracking_0 = _S1209;
        weight_1 = throughput_3;
        glowed_0 = _S1171;
        b_8 = 4294967295U;
        throughput_2 = throughput_3;
        density_2 = 1.0f;
        threshold_2 = _S1193;
        width_3 = _S1194;
        sky_pdf_0 = 0.0f;
        for(;;)
        {
            if(((&hit_4)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S1170 = int(1);
                break;
            }
            uint _S1210 = b_8 + 320U;
            bool _S1211 = b_8 == 4294967295U;
            uint _S1212 = _slang_select(_S1211, 384U,_S1210);
            uint _S1213 = stream(_S1199, _S1212);
            Random _S1214 = pcg(_S1213);
            float _S1215 = freeFlight_0(_S1214.value, spread_2);
            if(passes_0)
            {
                float3  _S1216 = (&ray_2)->origin;
                float3  _S1217 = (&ray_2)->unit_direction;
                float _S1218 = (&hit_4)->distance;
                uint _S1219 = _slang_select(_S1211, 0U,b_8);
                uint _S1220 = (&prev_0)->lobe;
                uint _S1221 = _slang_select(_S1211, 3U,_S1220);
                float _S1222 = (fcptTrackMedium((_S1205), (_S1216), (_S1217), (_S1218), (&tracking_0), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1219), (_S1221), (_S1211)));
                geometry_density_2 = _S1222;
            }
            else
            {
                geometry_density_2 = _S1215;
            }
            bool _S1223 = !(geometry_density_2 < ((&hit_4)->distance));
            if(_S1223)
            {
                _S1170 = int(1);
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
                float3  _S1224 = throughput_2 * glowed_0 / make_float3 (density_2);
                float3  _S1225 = sel_7->glow + _S1224;
                sel_7->glow = _S1225;
            }
            else
            {
            }
            glowed_0 = _S1171;
            uint b_10 = b_8 + 1U;
            float3  _S1226 = (&ray_2)->origin + make_float3 (geometry_density_2) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S1226;
            float3  _S1227 = flightWeight_0(scatter_in_0, extinction_in_0, spread_2, geometry_density_2, true);
            float3  _S1228 = weight_1;
            float3  _S1229 = _slang_select(passes_0, _S1228,_S1227);
            float3  throughput_4 = throughput_2 * _S1229;
            uint _S1230 = stream(_S1199, b_10 + 320U);
            tracking_0 = _S1230;
            weight_1 = throughput_3;
            float width_6 = width_3 + threshold_2 * geometry_density_2;
            float _S1231 = threshold_2 + 3.14159274101257324f;
            bool _S1232 = scatterSampled_0(replay_2, b_10, _S1187, passes_0);
            TreeSample _S1233 = TreeSample_x24init_0(_S1171, _S1171, 0.0f, 0U);
            if(_S1232)
            {
                float3  _S1234 = (&ray_2)->origin;
                float3  _S1235 = (&ray_2)->unit_direction;
                float3  _S1236 = (&ray_2)->unit_direction;
                uint _S1237 = stream(_S1199, b_10 + 64U);
                float3  _S1238 = extinction_in_0;
                float3  _S1239 = extinction_in_0;
                uint2  _S1240 = make_uint2 (_S1205);
                float3  _S1241 = (&ray_2)->unit_direction;
                uint _S1242 = arrivalLobe_0(b_10, (&prev_0)->lobe);
                FKHit _S1243 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S1244 = _S1243;
                ShadowContext _S1245 = ShadowContext_x24init_0(_S1238, _S1239, _S1240, _S1241, b_10, _S1242, false, geometry_density_2, width_6, &_S1244, false);
                ShadowContext _S1246 = _S1245;
                TreeSample _S1247 = sampleLightTree_0(_S1234, _S1235, _S1236, 0.0f, true, _S1237, &_S1246);
                light_3 = _S1247;
            }
            else
            {
                light_3 = _S1233;
            }
            float _S1248 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_3.dir));
            uint _S1249 = (fcptMaxBounces());
            bool _S1250 = b_10 < _S1249;
            if(_S1250)
            {
                is_inside_5 = (light_3.density) > 0.0f;
            }
            else
            {
                is_inside_5 = false;
            }
            float _S1251 = _slang_select(is_inside_5, _S1248,0.0f);
            float3  _S1252 = throughput_4 * light_3.radiance;
            float _S1253 = powerHeuristic(light_3.density, _S1251);
            float3  _S1254 = _S1252 * make_float3 (_S1248 * _S1253);
            float3  _S1255 = _slang_select(_S1232, _S1254,_S1171);
            if(replay_2)
            {
                viewed_0 = b_10 == _S1187;
            }
            else
            {
                viewed_0 = false;
            }
            if(viewed_0)
            {
                bool _S1256 = _S1176 == 2U;
                if(_S1256)
                {
                    float _S1257 = rgb_to_greyscale(_S1255);
                    passes_0 = _S1257 > 0.0f;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S1258 = Shift_x24init_0(_S1255, 1.0f);
                    _S1170 = int(0);
                    ended_0 = _S1258;
                    spread_2 = _S1231;
                    geometry_density_2 = width_6;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_10;
                    break;
                }
                _S1170 = int(0);
                ended_0 = _S1172;
                spread_2 = _S1231;
                geometry_density_2 = width_6;
                chain_throughput_0 = throughput_4;
                layer_0 = b_10;
                break;
            }
            bool _S1259 = !replay_2;
            if(_S1259)
            {
                Reservoir candidate_3 = _S1204;
                uint _S1260 = extractBits_0(_S1204.path, 10U, 2U);
                bool _S1261 = _S1260 == 1U;
                if(_S1261)
                {
                    float3  _S1262 = safeDivide(_S1255, _S1171);
                    (&candidate_3)->radiance = _S1262;
                }
                else
                {
                    uint _S1263 = insertBits_0(0U, b_10 + 1U, 5U, 5U);
                    uint _S1264 = insertBits_0(_S1263, 2U, 10U, 2U);
                    (&candidate_3)->path = _S1264;
                }
                Reservoir _S1265 = withEnd(candidate_3, 0U, b_10, _S1255);
                offer(sel_7, _S1265, _S1255 * make_float3 (scale_3) / make_float3 (density_2));
                float _S1266 = survivalProbability(throughput_4, density_2);
                uint _S1267 = stream(_S1199, b_10 + 128U);
                Random _S1268 = pcg(_S1267);
                bool _S1269 = _S1266 < (_S1268.value);
                if(_S1269)
                {
                    scatter_2 = true;
                }
                else
                {
                    uint _S1270 = (fcptMaxBounces());
                    scatter_2 = b_10 >= _S1270;
                }
                if(scatter_2)
                {
                    _S1170 = int(0);
                    ended_0 = _S1172;
                    spread_2 = _S1231;
                    geometry_density_2 = width_6;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_10;
                    break;
                }
                float _S1271 = density_2 * _S1266;
                density_2 = _S1271;
            }
            else
            {
            }
            float phase_pdf_0 = 0.0f;
            uint _S1272 = stream(_S1199, b_10);
            float3  _S1273 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1272, &phase_pdf_0);
            (&ray_2)->unit_direction = _S1273;
            NEEVertex _S1274 = NEEVertex_x24init_0(false, phase_pdf_0, (&ray_2)->origin, _S1171, (&ray_2)->origin);
            nee_vertex_0 = _S1274;
            Vertex _S1275 = scatteredVertex_0(false);
            prev_0 = _S1275;
            float _S1276 = (&prev_0)->pdf;
            FKRay _S1277 = ray_2;
            FKHit _S1278 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S1279 = (fcptTraverseInstanceBVH((_S1277), (true), (4.294967296e+09f), (false), (_S1278), (false)));
            hit_4 = _S1279;
            b_8 = b_10;
            throughput_2 = throughput_4;
            threshold_2 = _S1231;
            width_3 = width_6;
            sky_pdf_0 = _S1276;
        }
        if(_S1170 != int(1))
        {
            width_3 = geometry_density_2;
            throughput_2 = chain_throughput_0;
            b_8 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S1172;
        spread_2 = threshold_2;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    bool _S1280 = b_8 == 4294967295U;
    bool _S1281 = ((&hit_4)->instance_index) == 4294967295U;
    if(_S1281)
    {
        bool _S1282 = !(&nee_vertex_0)->none;
        float _S1283 = _slang_select(_S1282, sky_pdf_0,0.0f);
        float _S1284 = escapeWeight_0(_S1283, (&ray_2)->unit_direction);
        float3  _S1285 = environment_0((&ray_2)->unit_direction, b_8, (&prev_0)->lobe);
        float3  _S1286 = throughput_2 * _S1285;
        if(replay_2)
        {
            bool _S1287 = b_8 == _S1187;
            if(_S1287)
            {
                passes_0 = _S1176 == 3U;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                return Shift_x24init_0(_S1286 * make_float3 (_S1284) / make_float3 (r_8->jac), density_2 / r_8->jac);
            }
            if(_S1186)
            {
                passes_0 = _S1183;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                passes_0 = b_8 == _S1174;
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
                return Shift_x24init_0(_S1286 * make_float3 (_S1284), 1.0f);
            }
            return _S1172;
        }
        Reservoir candidate_4 = chain_0;
        uint _S1288 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1289 = _S1288 == 1U;
        if(_S1289)
        {
            uint _S1290 = extractBits_0((&chain_0)->path, 5U, 5U);
            bool _S1291 = _S1290 == b_8;
            float _S1292 = _slang_select(_S1291, 1.0f,_S1284);
            float3  _S1293 = safeDivide(_S1286 * make_float3 (_S1292), _S1171);
            (&candidate_4)->radiance = _S1293;
        }
        else
        {
            bool _S1294 = (&prev_0)->rough;
            if(_S1294)
            {
                uint _S1295 = insertBits_0(0U, b_8 + 1U, 5U, 5U);
                uint _S1296 = insertBits_0(_S1295, 3U, 10U, 2U);
                uint _S1297 = insertBits_0(_S1296, (&prev_0)->lobe, 15U, 3U);
                bool _S1298 = (&prev_0)->inside;
                uint _S1299 = _slang_select(_S1298, 1U,0U);
                uint _S1300 = insertBits_0(_S1297, _S1299, 22U, 1U);
                (&candidate_4)->path = _S1300;
                (&candidate_4)->jac = (&prev_0)->pdf;
                (&candidate_4)->dir = (&ray_2)->unit_direction;
            }
        }
        float3  _S1301 = _S1286 * make_float3 (_S1284);
        Reservoir _S1302 = withEnd(candidate_4, 3U, b_8, _S1301);
        offer(sel_7, _S1302, _S1301 * make_float3 (scale_3) / make_float3 (density_2));
        return _S1172;
    }
    float3  _S1303 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
    (&ray_2)->origin = _S1303;
    bool _S1304 = (fcptVaryingUsed());
    if(_S1304)
    {
        passes_0 = filling_2 != 4294967295U;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        bool _S1305 = !replay_2;
        if(_S1305)
        {
            float3  _S1306 = throughput_2 * glowed_0 / make_float3 (density_2);
            float3  _S1307 = sel_7->glow + _S1306;
            sel_7->glow = _S1307;
        }
        float3  _S1308 = throughput_2 * weight_1;
        throughput_2 = _S1308;
    }
    else
    {
        float3  _S1309 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
        float3  _S1310 = throughput_2 * _S1309;
        throughput_2 = _S1310;
    }
    float _S1311 = width_3 + spread_2 * (&hit_4)->distance;
    uint _S1312 = b_8 + 1U;
    b_8 = _S1312;
    layer_0 = 0U;
    width_3 = _S1311;
    passes_0 = false;
    threshold_2 = 0.0f;
    turned_1 = false;
    is_inside_5 = false;
    chain_throughput_0 = _S1171;
    float3  reconnection_0 = _S1171;
    viewed_0 = _S1280;
    for(;;)
    {
        bool _S1313 = ((&hit_4)->is_point_light) == 1U;
        FKMedium _S1314 = Medium_x24init_0(_S1171, _S1171, 0.0f);
        BSDFMaterial _S1315 = Material_x24init_0(_S1171, _S1171, 0.0f, 0.0f, 0.0f, 0.0f, _S1171, throughput_3, 1.0f, _S1171, _S1171, 0.5f, 0.0f, 0.0f, _S1171, 0.0f, _S1171);
        FKMedium _S1316 = _S1314;
        FKSurface _S1317 = Surface_x24init_0(_S1171, _S1171, 0.0f, &_S1315, false, 0U, 1.0f, false, &_S1316, 4294967295U, _S1171);
        bool _S1318 = !_S1313;
        bool is_inside_6;
        float3  throughput_5;
        FKSurface surface_11;
        if(_S1318)
        {
            uint _S1319 = stream(_S1199, b_8);
            uint _S1320 = arrivalLobe_0(b_8, (&prev_0)->lobe);
            FKSurface _S1321 = (fcptSurfaceAtPath((hit_4), ((&ray_2)->origin), (_S1319), (width_3), (layer_0), (b_8), (_S1320), ((&ray_2)->unit_direction)));
            bool _S1322 = !passes_0;
            FKSurface _S1323 = _S1321;
            FKSurface _S1324 = emitting_0(&_S1323, _S1322);
            uint _S1325 = stream(_S1199, b_8 + 256U);
            Random _S1326 = pcg(_S1325);
            FKSurface _S1327 = _S1324;
            FKSurface _S1328 = uncovered_0(&_S1327, _S1326.value);
            float _S1329 = facingSign(_S1328.material.transmission, _S1328.geometry_n, (&ray_2)->unit_direction);
            bool _S1330 = _S1329 < 0.0f;
            bool _S1331 = (_S1328.material.transmission) > 0.0f;
            if(_S1331)
            {
                bool _S1332 = arrivesBehind_0((&ray_2)->unit_direction, _S1328.geometry_n);
                scatter_2 = _S1332;
            }
            else
            {
                scatter_2 = false;
            }
            FKSurface _S1333 = _S1328;
            FKSurface _S1334 = facingRay_0(&_S1333, (&ray_2)->unit_direction);
            if(passes_0)
            {
                bool _S1335 = arrivesBehind_0((&ray_2)->unit_direction, _S1334.geometry_n);
                is_inside_6 = _S1335;
            }
            else
            {
                is_inside_6 = scatter_2;
            }
            if(is_inside_6)
            {
                float3  _S1336 = beerLambert((&hit_4)->distance, _S1334.material.absorption);
                float3  _S1337 = throughput_2 * _S1336;
                throughput_5 = _S1337;
            }
            else
            {
                throughput_5 = throughput_2;
            }
            bool _S1338 = !_S1334.skip;
            float geometry_density_3 = geometryDensity(_S1334.geometry_n, (&ray_2)->unit_direction, (&hit_4)->distance);
            bool _S1339 = b_8 == _S1312;
            if(_S1339)
            {
                float _S1340 = footprintThreshold(geometry_density_3);
                geometry_density_2 = _S1340;
            }
            else
            {
                geometry_density_2 = threshold_2;
            }
            float _S1341 = geometry_density_2;
            scatter_2 = _S1338;
            geometry_density_2 = geometry_density_3;
            threshold_2 = _S1341;
            surface_11 = _S1334;
            turned_1 = _S1330;
        }
        else
        {
            scatter_2 = false;
            geometry_density_2 = 0.0f;
            surface_11 = _S1317;
            throughput_5 = throughput_2;
            is_inside_6 = is_inside_5;
        }
        bool _S1342 = withinFootprint(scatter_2, (&prev_0)->rough, (&prev_0)->pdf, geometry_density_2, threshold_2);
        FKSurface _S1343 = surface_11;
        FKSurface _S1344 = surface_11;
        float _S1345 = dot_0(surface_11.smooth_n, - (&ray_2)->unit_direction);
        float2  _S1346 = vertexEta(_S1343.material, _S1345);
        bool _S1347;
        if(scatter_2)
        {
            bool _S1348 = neeDecision(_S1343.material, _S1345, _S1346.x, _S1346.y);
            _S1347 = _S1348;
        }
        else
        {
            _S1347 = false;
        }
        bool _S1349;
        if(passes_0)
        {
            _S1349 = true;
        }
        else
        {
            _S1349 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S1349)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S1347;
        }
        bool _S1350 = (fcptHairUsed());
        bool _S1351;
        if(_S1350)
        {
            float3  _S1352 = surface_11.hair;
            _S1351 = (dot_0(_S1352, _S1352)) > 0.0f;
        }
        else
        {
            _S1351 = false;
        }
        bool _S1353;
        if(_S1351)
        {
            _S1353 = true;
        }
        else
        {
            BSDFMaterial _S1354 = _S1343.material;
            bool _S1355 = isTranslucent_0(&_S1354);
            _S1353 = _S1355;
        }
        bool _S1356;
        if(_S1353)
        {
            _S1356 = true;
        }
        else
        {
            bool _S1357 = (_S1343.material.transmission) > 0.0f;
            if(_S1357)
            {
                uint _S1358 = (fcptLayers((hit_4)));
                _S1356 = _S1358 == 1U;
            }
            else
            {
                _S1356 = false;
            }
        }
        float3  emission_0;
        if(_S1313)
        {
            float3  _S1359 = (fcptCalculatePointLightContrib(((&hit_4)->instance_index)));
            emission_0 = _S1359;
        }
        else
        {
            emission_0 = _S1343.material.emissive;
        }
        float _S1360 = rgb_to_greyscale(emission_0);
        bool _S1361 = _S1360 > 0.0f;
        float3  emission_1;
        if(_S1361)
        {
            NEEVertex _S1362 = nee_vertex_0;
            FKHit _S1363 = hit_4;
            float _S1364 = emissionWeight_0(&_S1362, &_S1363, (&ray_2)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S1364);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S1365;
        if(replay_2)
        {
            _S1365 = _S1176 == 1U;
        }
        else
        {
            _S1365 = false;
        }
        bool _S1366;
        if(_S1365)
        {
            _S1366 = b_8 > _S1175;
        }
        else
        {
            _S1366 = false;
        }
        bool _S1367;
        if(_S1366)
        {
            _S1367 = b_8 == _S1174;
        }
        else
        {
            _S1367 = false;
        }
        bool _S1368;
        if(_S1367)
        {
            bool _S1369 = _S1177 == 1U;
            if(_S1369)
            {
                _S1368 = true;
            }
            else
            {
                _S1368 = _S1177 == 2U;
            }
        }
        else
        {
            _S1368 = false;
        }
        if(_S1368)
        {
            bool _S1370 = _S1313 != (_S1177 == 2U);
            if(_S1370)
            {
                return _S1172;
            }
            return Shift_x24init_0(throughput_5 * emission_1 / make_float3 (r_8->jac), density_2 / r_8->jac);
        }
        uint _S1371 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1372 = _S1371 == 1U;
        Reservoir here_0 = chain_0;
        uint _S1373 = insertBits_0(0U, b_8, 5U, 5U);
        uint _S1374 = insertBits_0(_S1373, 1U, 10U, 2U);
        uint _S1375 = insertBits_0(_S1374, (&prev_0)->lobe, 15U, 3U);
        bool _S1376 = (&prev_0)->inside;
        uint _S1377 = _slang_select(_S1376, 1U,0U);
        uint _S1378 = insertBits_0(_S1375, _S1377, 22U, 1U);
        (&here_0)->path = _S1378;
        float _S1379 = (&prev_0)->pdf * geometry_density_2;
        (&here_0)->jac = _S1379;
        fcptWithReservoirHit((&here_0), (&hit_4));
        bool _S1380;
        if(replay_2)
        {
            _S1380 = _S1176 == 1U;
        }
        else
        {
            _S1380 = false;
        }
        bool _S1381;
        if(_S1380)
        {
            _S1381 = b_8 == _S1175;
        }
        else
        {
            _S1381 = false;
        }
        bool _S1382 = b_8 == _S1187;
        bool _S1383;
        if(_S1382)
        {
            bool _S1384 = !scatter_2;
            if(_S1384)
            {
                _S1383 = true;
            }
            else
            {
                bool _S1385 = _S1176 != 1U;
                if(_S1385)
                {
                    _S1383 = _S1176 != 3U;
                }
                else
                {
                    _S1383 = false;
                }
            }
        }
        else
        {
            _S1383 = false;
        }
        bool _S1386;
        if(_S1383)
        {
            _S1386 = _S1176 == 2U;
        }
        else
        {
            _S1386 = false;
        }
        bool _S1387;
        if(_S1386)
        {
            _S1387 = !_S1342;
        }
        else
        {
            _S1387 = false;
        }
        bool _S1388;
        if(_S1387)
        {
            _S1388 = _S1177 != 4U;
        }
        else
        {
            _S1388 = false;
        }
        bool _S1389 = _S1175 == _S1174;
        bool _S1390;
        if(_S1389)
        {
            _S1390 = _S1177 == 0U;
        }
        else
        {
            _S1390 = false;
        }
        bool _S1391;
        if(_S1390)
        {
            _S1391 = ((&hit_4)->instance_index) == (_S1188.instance_index);
        }
        else
        {
            _S1391 = false;
        }
        bool _S1392;
        if(_S1391)
        {
            _S1392 = ((&hit_4)->triangle_index) == (_S1188.triangle_index);
        }
        else
        {
            _S1392 = false;
        }
        bool _S1393;
        if(_S1392)
        {
            _S1393 = _S1342;
        }
        else
        {
            _S1393 = false;
        }
        bool _S1394 = _slang_select(_S1381, _S1393,_S1388);
        bool _S1395;
        if(nee_0)
        {
            _S1395 = _slang_select(replay_2, _S1394,scatter_2);
        }
        else
        {
            _S1395 = false;
        }
        TreeSample _S1396 = TreeSample_x24init_0(_S1171, _S1171, 0.0f, 0U);
        uint2  _S1397 = make_uint2 (0U);
        float2  _S1398 = make_float2 (0.0f);
        FKHit _S1399 = Hit_x24init_0(_S1398, 4294967295U, 0U, 0U, 0.0f);
        FKHit _S1400 = _S1399;
        ShadowContext _S1401 = ShadowContext_x24init_0(_S1171, _S1171, _S1397, _S1171, 0U, 0U, false, 0.0f, 0.0f, &_S1400, false);
        ShadowContext context_5;
        if(nee_0)
        {
            uint _S1402 = arrivalLobe_0(b_8, (&prev_0)->lobe);
            FKMedium _S1403 = (fcptOutsideMedium((hit_4)));
            FKSurface _S1404 = surface_11;
            FKHit _S1405 = hit_4;
            FKMedium _S1406 = _S1403;
            ShadowContext _S1407 = shadowContext_0(&_S1404, turned_1, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_8, _S1402, (&hit_4)->distance, width_3, &_S1405, _S1351, &_S1406);
            context_5 = _S1407;
        }
        else
        {
            context_5 = _S1401;
        }
        float3  throughput_6;
        float3  lit_0;
        if(_S1395)
        {
            float3  _S1408 = (&ray_2)->origin;
            if(_S1351)
            {
                throughput_6 = _S1171;
            }
            else
            {
                throughput_6 = _S1344.smooth_n;
            }
            FKSurface _S1409 = surface_11;
            uint _S1410 = stream(_S1199, b_8 + 64U);
            ShadowContext _S1411 = context_5;
            TreeSample _S1412 = sampleLightTree_0(_S1408, throughput_6, surface_11.geometry_n, surface_11.geometry_offset, _S1356, _S1410, &_S1411);
            bool _S1413 = any_1((_S1412.radiance) != _S1171);
            if(_S1413)
            {
                if(_S1351)
                {
                    uint _S1414 = (fcptMaxBounces());
                    bool _S1415 = b_8 < _S1414;
                    FKSurface _S1416 = surface_11;
                    TreeSample _S1417 = _S1412;
                    float3  _S1418 = hairLight_0(&_S1416, (&ray_2)->unit_direction, &_S1417, _S1415);
                    lit_0 = _S1418;
                }
                else
                {
                    float _S1419 = _S1346.x;
                    float _S1420 = _S1346.y;
                    uint _S1421 = (fcptMaxBounces());
                    bool _S1422 = b_8 < _S1421;
                    TreeSample _S1423 = _S1412;
                    BSDFMaterial _S1424 = _S1343.material;
                    float3  _S1425 = lightBSDF_0((&ray_2)->unit_direction, &_S1423, _S1344.smooth_n, _S1409.geometry_n, &_S1424, _S1419, _S1420, _S1422, surface_11.random_state);
                    lit_0 = _S1425;
                }
            }
            else
            {
                lit_0 = _S1171;
            }
            light_3 = _S1412;
        }
        else
        {
            light_3 = _S1396;
            lit_0 = _S1171;
        }
        bool viewed_1;
        bool refracted_4;
        bool wrong_side_0;
        bool _S1426;
        bool _S1427;
        float density_4;
        if(_S1381)
        {
            bool _S1428 = ((&hit_4)->instance_index) != (_S1188.instance_index);
            if(_S1428)
            {
                viewed_1 = true;
            }
            else
            {
                viewed_1 = ((&hit_4)->triangle_index) != (_S1188.triangle_index);
            }
            if(viewed_1)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = !_S1342;
            }
            if(refracted_4)
            {
                return _S1172;
            }
            float3  throughput_7 = throughput_5 * make_float3 (geometry_density_2);
            float density_5 = density_2 * geometry_density_2;
            if(_S1389)
            {
                wrong_side_0 = _S1177 == 1U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                return Shift_x24init_0(throughput_7 * emission_1 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1389)
            {
                _S1426 = _S1177 == 0U;
            }
            else
            {
                _S1426 = false;
            }
            if(_S1426)
            {
                bool _S1429 = !nee_0;
                if(_S1429)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S1430 = rgb_to_greyscale(light_3.radiance);
                    passes_0 = !(_S1430 > 0.0f);
                }
                if(passes_0)
                {
                    return _S1172;
                }
                return Shift_x24init_0(throughput_7 * lit_0 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1389)
            {
                _S1427 = _S1177 == 4U;
            }
            else
            {
                _S1427 = false;
            }
            if(_S1427)
            {
                bool _S1431 = !nee_0;
                if(_S1431)
                {
                    return _S1172;
                }
                float _S1432 = environmentPdf_0(r_8->dir);
                float3  _S1433 = skyBSDF((&ray_2)->unit_direction, r_8->dir, surface_11, _S1346, is_inside_6, _S1432, surface_11.random_state);
                return Shift_x24init_0(throughput_7 * _S1433 * r_8->radiance / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            uint _S1434 = extractBits_0(_S1173, 21U, 1U);
            bool _S1435 = nee_0 != (_S1434 == 1U);
            if(_S1435)
            {
                return _S1172;
            }
            throughput_6 = throughput_7;
            density_4 = density_5;
        }
        else
        {
            if(replay_2)
            {
                viewed_1 = _S1382;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                bool _S1436 = !scatter_2;
                if(_S1436)
                {
                    refracted_4 = true;
                }
                else
                {
                    bool _S1437 = _S1176 != 1U;
                    if(_S1437)
                    {
                        refracted_4 = _S1176 != 3U;
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
                bool _S1438 = _S1176 == 2U;
                if(_S1438)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1342;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1177 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    if(_S1351)
                    {
                        return _S1172;
                    }
                    uint _S1439 = stream(_S1199, b_8 + 448U);
                    FKRay _S1440 = ray_2;
                    FKSurface _S1441 = surface_11;
                    ShadowContext _S1442 = context_5;
                    SkySample _S1443 = sampleSky_0(&_S1440, &_S1441, _S1346, is_inside_6, _S1439, surface_11.random_state, &_S1442);
                    return Shift_x24init_0(throughput_5 * _S1443.color, 1.0f);
                }
                if(_S1438)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1342;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float _S1444 = rgb_to_greyscale(light_3.radiance);
                    bool _S1445 = !(_S1444 > 0.0f);
                    if(_S1445)
                    {
                        return _S1172;
                    }
                    return Shift_x24init_0(throughput_5 * lit_0, 1.0f);
                }
                if(_S1186)
                {
                    passes_0 = _S1177 == 2U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1313;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_5 * emission_1, 1.0f);
                }
                if(_S1186)
                {
                    passes_0 = _S1177 == 1U;
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
                    passes_0 = !_S1342;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_5 * emission_1, 1.0f);
                }
                return _S1172;
            }
            else
            {
                bool _S1446 = !replay_2;
                if(_S1446)
                {
                    wrong_side_0 = scatter_2;
                }
                else
                {
                    wrong_side_0 = false;
                }
                if(wrong_side_0)
                {
                    bool _S1447 = b_8 > 0U;
                    if(_S1447)
                    {
                        Reservoir candidate_5 = chain_0;
                        if(_S1372)
                        {
                            float3  _S1448 = safeDivide(throughput_5 * emission_1, chain_throughput_0);
                            (&candidate_5)->radiance = _S1448;
                        }
                        else
                        {
                            if(_S1342)
                            {
                                candidate_5 = here_0;
                            }
                        }
                        float3  _S1449 = throughput_5 * emission_1;
                        Reservoir _S1450 = withEnd(candidate_5, 1U, b_8, _S1449);
                        offer(sel_7, _S1450, _S1449 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    else
                    {
                        float3  _S1451 = throughput_5 * emission_1;
                        float3  _S1452 = sel_7->glow + _S1451;
                        sel_7->glow = _S1452;
                    }
                    if(nee_0)
                    {
                        float3  _S1453 = throughput_5 * lit_0;
                        Reservoir candidate_6 = chain_0;
                        if(_S1372)
                        {
                            float3  _S1454 = safeDivide(_S1453, chain_throughput_0);
                            (&candidate_6)->radiance = _S1454;
                        }
                        else
                        {
                            if(_S1342)
                            {
                                candidate_6 = here_0;
                                uint _S1455 = insertBits_0((&candidate_6)->path, 1U, 21U, 1U);
                                (&candidate_6)->path = _S1455;
                                (&candidate_6)->dir = light_3.dir;
                                (&candidate_6)->radiance = light_3.radiance;
                            }
                            else
                            {
                                uint _S1456 = insertBits_0(0U, b_8 + 1U, 5U, 5U);
                                uint _S1457 = insertBits_0(_S1456, 2U, 10U, 2U);
                                (&candidate_6)->path = _S1457;
                            }
                        }
                        Reservoir _S1458 = withEnd(candidate_6, 0U, b_8, _S1453);
                        offer(sel_7, _S1458, _S1453 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    if(nee_0)
                    {
                        if(_S1351)
                        {
                            _S1426 = false;
                        }
                        else
                        {
                            bool _S1459 = environmentMapped_0();
                            _S1426 = _S1459;
                        }
                    }
                    else
                    {
                        _S1426 = false;
                    }
                    if(_S1426)
                    {
                        uint _S1460 = (fcptMaxBounces());
                        _S1427 = b_8 < _S1460;
                    }
                    else
                    {
                        _S1427 = false;
                    }
                    if(_S1427)
                    {
                        uint _S1461 = stream(_S1199, b_8 + 448U);
                        FKRay _S1462 = ray_2;
                        FKSurface _S1463 = surface_11;
                        ShadowContext _S1464 = context_5;
                        SkySample _S1465 = sampleSky_0(&_S1462, &_S1463, _S1346, is_inside_6, _S1461, surface_11.random_state, &_S1464);
                        float3  _S1466 = throughput_5 * _S1465.color;
                        Reservoir candidate_7 = chain_0;
                        if(_S1372)
                        {
                            float3  _S1467 = safeDivide(_S1466, chain_throughput_0);
                            (&candidate_7)->radiance = _S1467;
                        }
                        else
                        {
                            if(_S1342)
                            {
                                candidate_7 = here_0;
                                uint _S1468 = insertBits_0((&candidate_7)->path, 1U, 21U, 1U);
                                (&candidate_7)->path = _S1468;
                                (&candidate_7)->dir = _S1465.dir;
                                (&candidate_7)->radiance = _S1465.radiance;
                            }
                            else
                            {
                                uint _S1469 = insertBits_0(0U, b_8 + 1U, 5U, 5U);
                                uint _S1470 = insertBits_0(_S1469, 2U, 10U, 2U);
                                (&candidate_7)->path = _S1470;
                            }
                        }
                        Reservoir _S1471 = withEnd(candidate_7, 4U, b_8, _S1466);
                        offer(sel_7, _S1471, _S1466 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                }
            }
            throughput_6 = throughput_5;
            density_4 = density_2;
        }
        bool _S1472;
        bool _S1473;
        bool _S1474;
        bool straight_0;
        bool _S1475;
        bool _S1476;
        bool _S1477;
        bool _S1478;
        bool _S1479;
        bool _S1480;
        bool _S1481;
        bool _S1482;
        bool _S1483;
        bool _S1484;
        bool _S1485;
        bool _S1486;
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
                viewed_1 = _S1382;
            }
            else
            {
                viewed_1 = false;
            }
            uint _S1487 = extractBits_0(_S1173, 15U, 3U);
            uint _S1488 = extractBits_0(_S1173, 18U, 3U);
            uint _S1489 = _slang_select(_S1381, _S1488,_S1487);
            float3  _S1490 = r_8->dir;
            bool refracted_5 = _S1489 == 1U;
            SampleBSDF _S1491 = SampleBSDF_x24init_0(_S1171, _S1171, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_8 = _S1491;
            float3  reconnection_1;
            SampleBSDF _S1492;
            if(viewed_1)
            {
                uint _S1493 = extractBits_0(_S1173, 22U, 1U);
                bool _S1494 = is_inside_6 != (_S1493 == 1U);
                if(_S1494)
                {
                    return _S1172;
                }
                bool _S1495 = _S1176 == 1U;
                if(_S1495)
                {
                    float3  _S1496 = (fcptHitPosition((_S1188)));
                    throughput_8 = _S1496;
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
                    BSDFMaterial _S1497 = _S1343.material;
                    bool _S1498 = isTranslucent_0(&_S1497);
                    if(_S1498)
                    {
                        refracted_4 = _S1489 == 0U;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                    if(refracted_4)
                    {
                        float3  _S1499 = throughput_8 - (&ray_2)->origin;
                        float3  _S1500 = _slang_select(_S1495, _S1499,_S1490);
                        wrong_side_0 = (dot_0(_S1344.smooth_n, _S1500) * _S1345) < 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    refracted_4 = wrong_side_0;
                }
                if(_S1495)
                {
                    float3  _S1501 = (&ray_2)->origin;
                    FKSurface _S1502 = surface_11;
                    float3  _S1503 = - _S1344.smooth_n;
                    bool _S1504 = is_inside_6 != refracted_4;
                    float3  _S1505 = _slang_select(_S1504, _S1503,_S1344.smooth_n);
                    float3  _S1506 = throughput_8 - (_S1501 + make_float3 (_S1502.geometry_offset) * _S1505);
                    float3  _S1507 = ((((_S1506)) * make_float3(rnorm3df(((_S1506)).x, ((_S1506)).y, ((_S1506)).z))));
                    reconnection_1 = _S1507;
                }
                else
                {
                    reconnection_1 = _S1490;
                }
                if(_S1351)
                {
                    wrong_side_0 = false;
                }
                else
                {
                    bool _S1508 = wrongSide_0(is_inside_6, refracted_4, reconnection_1, surface_11.geometry_n);
                    wrong_side_0 = _S1508;
                }
                if(wrong_side_0)
                {
                    return _S1172;
                }
                float3  _S1509 = throughput_8;
                throughput_8 = reconnection_1;
                b_11 = _S1489;
                wrong_side_0 = false;
                reconnection_1 = _S1509;
            }
            else
            {
                bool _S1510 = !_S1381;
                if(_S1510)
                {
                    SampleBSDF bsdf_sampled_0;
                    if(_S1351)
                    {
                        SampleBSDF _S1511 = (fcptSampleHair((surface_11.hair), (_S1343.material.albedo), (_S1343.material.specular_tint), ((&ray_2)->unit_direction), (surface_11.random_state)));
                        _S1492 = _S1511;
                    }
                    else
                    {
                        SampleBSDF _S1512 = sampleBSDF((&ray_2)->unit_direction, _S1344.smooth_n, _S1343.material, _S1346.x, _S1346.y, surface_11.random_state, _S1398);
                        _S1492 = _S1512;
                    }
                    bsdf_sampled_0 = _S1492;
                    if(_S1351)
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
                            return _S1172;
                        }
                        break;
                    }
                    if(_S1351)
                    {
                        wrong_side_0 = false;
                    }
                    else
                    {
                        bool _S1513 = wrongSide_0(is_inside_6, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, surface_11.geometry_n);
                        wrong_side_0 = _S1513;
                    }
                    if(wrong_side_0)
                    {
                        _S1426 = (_S1343.material.transmission) > 0.0f;
                    }
                    else
                    {
                        _S1426 = false;
                    }
                    if(_S1426)
                    {
                        SampleBSDF _S1514 = sampleBSDF((&bsdf_sampled_0)->unit_direction, surface_11.geometry_n, _S1343.material, _S1346.x, _S1346.y, (&bsdf_sampled_0)->random_state, _S1398);
                        (&bsdf_sampled_0)->unit_direction = _S1514.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1514.refracted;
                        (&bsdf_sampled_0)->throughput = _S1514.throughput;
                    }
                    else
                    {
                        if(wrong_side_0)
                        {
                            float3  _S1515 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, surface_11.geometry_n)) * surface_11.geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1515;
                        }
                    }
                    uint _S1516 = (&bsdf_sampled_0)->lobe;
                    float3  _S1517 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1518 = (&bsdf_sampled_0)->refracted;
                    lobe_8 = bsdf_sampled_0;
                    float _S1519 = (&bsdf_sampled_0)->pdf;
                    float _S1520 = _slang_select(wrong_side_0, 0.0f,_S1519);
                    (&lobe_8)->pdf = _S1520;
                    throughput_8 = _S1517;
                    b_11 = _S1516;
                    refracted_4 = _S1518;
                }
                else
                {
                    throughput_8 = _S1490;
                    b_11 = _S1489;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(viewed_1)
            {
                _S1426 = true;
            }
            else
            {
                _S1426 = _S1381;
            }
            if(_S1426)
            {
                if(_S1351)
                {
                    SampleBSDF _S1521 = (fcptConnectHair((surface_11.hair), (_S1343.material.albedo), (_S1343.material.specular_tint), ((&ray_2)->unit_direction), (throughput_8)));
                    _S1492 = _S1521;
                }
                else
                {
                    SampleBSDF _S1522 = connectBSDF((&ray_2)->unit_direction, throughput_8, _S1344.smooth_n, _S1343.material, _S1346.x, _S1346.y, b_11, surface_11.random_state);
                    _S1492 = _S1522;
                }
                lobe_8 = _S1492;
            }
            bool _S1523 = b_11 == 0U;
            if(_S1523)
            {
                _S1427 = true;
            }
            else
            {
                _S1427 = b_11 == 4U;
            }
            if(_S1427)
            {
                _S1472 = true;
            }
            else
            {
                _S1472 = b_11 == 6U;
            }
            if(_S1351)
            {
                _S1473 = false;
            }
            else
            {
                bool _S1524 = !_S1472;
                if(_S1524)
                {
                    bool _S1525 = (_S1343.material.roughness) == 0.0f;
                    if(_S1525)
                    {
                        _S1473 = true;
                    }
                    else
                    {
                        bool _S1526 = b_11 == 1U;
                        if(_S1526)
                        {
                            _S1473 = (_S1346.x) == (_S1346.y);
                        }
                        else
                        {
                            _S1473 = false;
                        }
                    }
                }
                else
                {
                    _S1473 = false;
                }
            }
            bool _S1527 = !_S1351;
            if(_S1527)
            {
                _S1474 = b_11 == 1U;
            }
            else
            {
                _S1474 = false;
            }
            if(_S1474)
            {
                straight_0 = (_S1343.material.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S1475 = _S1527;
            }
            else
            {
                _S1475 = false;
            }
            if(_S1475)
            {
                _S1476 = b_11 == 1U;
            }
            else
            {
                _S1476 = false;
            }
            if(_S1476)
            {
                _S1477 = (_S1346.x) == (_S1346.y);
            }
            else
            {
                _S1477 = false;
            }
            BSDFMaterial _S1528 = _S1343.material;
            bool _S1529 = isTranslucent_0(&_S1528);
            if(_S1529)
            {
                _S1478 = _S1523;
            }
            else
            {
                _S1478 = false;
            }
            if(_S1478)
            {
                _S1479 = (dot_0(throughput_8, surface_11.geometry_n)) < 0.0f;
            }
            else
            {
                _S1479 = false;
            }
            if(nee_0)
            {
                _S1480 = !_S1473;
            }
            else
            {
                _S1480 = false;
            }
            if(_S1480)
            {
                _S1481 = !wrong_side_0;
            }
            else
            {
                _S1481 = false;
            }
            if(_S1481)
            {
                float _S1530 = (&lobe_8)->pdf;
                float3  _S1531 = (&ray_2)->origin;
                float3  _S1532 = _slang_select(_S1356, _S1171,_S1344.smooth_n);
                float3  _S1533 = (&ray_2)->origin;
                FKSurface _S1534 = surface_11;
                float3  _S1535 = - _S1344.smooth_n;
                float3  _S1536 = _slang_select(_S1479, _S1535,_S1344.smooth_n);
                NEEVertex _S1537 = NEEVertex_x24init_0(false, _S1530, _S1531, _S1532, _S1533 + make_float3 (_S1534.geometry_offset) * _S1536);
                nee_vertex_0 = _S1537;
            }
            else
            {
                if(_S1351)
                {
                    _S1482 = true;
                }
                else
                {
                    bool _S1538 = b_11 != 1U;
                    if(_S1538)
                    {
                        _S1482 = true;
                    }
                    else
                    {
                        _S1482 = (_S1346.x) != (_S1346.y);
                    }
                }
                if(_S1482)
                {
                    (&nee_vertex_0)->none = true;
                }
            }
            bool _S1539 = withinInverseFootprint((&lobe_8)->pdf, _S1472, (&prev_0)->cos, (&hit_4)->distance, threshold_2);
            bool _S1540 = roughLobe((&lobe_8)->pdf, _S1472, _S1343.material.roughness);
            if(_S1381)
            {
                bool _S1541 = !_S1539;
                if(_S1541)
                {
                    return _S1172;
                }
                bool _S1542 = _S1177 != 1U;
                if(_S1542)
                {
                    _S1482 = _S1177 != 2U;
                }
                else
                {
                    _S1482 = false;
                }
                if(_S1482)
                {
                    float _S1543 = (&lobe_8)->pdf;
                    float _S1544 = _slang_select(nee_0, _S1543,0.0f);
                    float _S1545 = escapeWeight_0(_S1544, _S1490);
                    if(_S1389)
                    {
                        passes_0 = _S1183;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1546 = _slang_select(passes_0, _S1545,1.0f);
                    return Shift_x24init_0(throughput_6 * ((&lobe_8)->throughput * make_float3 ((&lobe_8)->pdf)) * r_8->radiance * make_float3 (_S1546) / make_float3 (r_8->jac), density_4 * (&lobe_8)->pdf / r_8->jac);
                }
                float3  _S1547 = throughput_6 * make_float3 ((&lobe_8)->pdf);
                float _S1548 = density_4 * (&lobe_8)->pdf;
                throughput_9 = _S1547;
                density_6 = _S1548;
            }
            else
            {
                throughput_9 = throughput_6;
                density_6 = density_4;
            }
            uint _S1549 = (fcptLayers((hit_4)));
            bool _S1550 = b_11 == 1U;
            bool _S1551 = passesLayer_0(_S1549, _S1550, passes_0);
            if(viewed_1)
            {
                _S1482 = _S1551;
            }
            else
            {
                _S1482 = false;
            }
            if(_S1482)
            {
                return _S1172;
            }
            if(replay_2)
            {
                _S1483 = b_8 <= _S1187;
            }
            else
            {
                _S1483 = false;
            }
            if(_S1483)
            {
                _S1484 = _S1342;
            }
            else
            {
                _S1484 = false;
            }
            if(_S1484)
            {
                _S1485 = _S1539;
            }
            else
            {
                _S1485 = false;
            }
            if(_S1485)
            {
                _S1486 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S1486 = !_S1540;
                }
                else
                {
                    _S1486 = false;
                }
            }
            if(_S1486)
            {
                return _S1172;
            }
            if(viewed_1)
            {
                float3  _S1552 = throughput_9 * ((&lobe_8)->throughput * make_float3 ((&lobe_8)->pdf));
                float _S1553 = (&lobe_8)->pdf;
                throughput_10 = _S1552;
                sky_pdf_2 = _S1553;
            }
            else
            {
                float3  _S1554 = throughput_9 * max_0((&lobe_8)->throughput, _S1171);
                throughput_10 = _S1554;
                sky_pdf_2 = density_6;
            }
            bool _S1555 = !replay_2;
            bool _S1556;
            if(_S1555)
            {
                _S1556 = !_S1372;
            }
            else
            {
                _S1556 = false;
            }
            bool _S1557;
            if(_S1556)
            {
                _S1557 = _S1342;
            }
            else
            {
                _S1557 = false;
            }
            bool _S1558;
            if(_S1557)
            {
                _S1558 = _S1539;
            }
            else
            {
                _S1558 = false;
            }
            float3  chain_throughput_1;
            if(_S1558)
            {
                chain_0 = here_0;
                uint _S1559 = insertBits_0((&chain_0)->path, b_11, 18U, 3U);
                uint _S1560 = _slang_select(nee_0, 1U,0U);
                uint _S1561 = insertBits_0(_S1559, _S1560, 21U, 1U);
                (&chain_0)->path = _S1561;
                float _S1562 = (&chain_0)->jac * (&lobe_8)->pdf;
                (&chain_0)->jac = _S1562;
                (&chain_0)->dir = throughput_8;
                chain_throughput_1 = throughput_10;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            FKSurface _S1563 = surface_11;
            Vertex _S1564 = Vertex_x24init_0(_S1540, b_11, (&lobe_8)->pdf, (F32_abs((dot_0(surface_11.geometry_n, throughput_8)))), is_inside_6);
            prev_0 = _S1564;
            float _S1565 = (&lobe_8)->pdf;
            bool _S1566;
            if(_S1550)
            {
                _S1566 = (_S1346.x) == (_S1346.y);
            }
            else
            {
                _S1566 = false;
            }
            float sky_pdf_3 = _slang_select(_S1566, sky_pdf_0,_S1565);
            float _S1567 = _slang_select(_S1351, 0.0f,sky_pdf_3);
            float _S1568 = widened_0(spread_2, (&lobe_8)->pdf, _S1473);
            bool _S1569;
            if(refracted_4)
            {
                _S1569 = !_S1479;
            }
            else
            {
                _S1569 = false;
            }
            bool is_inside_7;
            if(_S1569)
            {
                bool _S1570 = !is_inside_6;
                is_inside_7 = _S1570;
            }
            else
            {
                is_inside_7 = is_inside_6;
            }
            FKSurface _S1571 = surface_11;
            bool _S1572 = boundsVolume_0(&_S1571);
            bool _S1573;
            if(_S1572)
            {
                _S1573 = !_S1551;
            }
            else
            {
                _S1573 = false;
            }
            if(_S1573)
            {
                FKSurface faced_2 = surface_11;
                float3  _S1574 = - _S1563.geometry_n;
                float3  _S1575 = _slang_select(turned_1, _S1574,_S1563.geometry_n);
                (&faced_2)->geometry_n = _S1575;
                FKMedium _S1576 = Medium_x24init_0(scatter_in_0, extinction_in_0, g_in_0);
                FKMedium _S1577 = (fcptOutsideMedium((hit_4)));
                FKSurface _S1578 = faced_2;
                FKMedium _S1579 = _S1576;
                FKMedium _S1580 = _S1577;
                MediumSides _S1581 = mediumSides_0(&_S1578, &_S1579, filling_2, (&ray_2)->unit_direction, &_S1580);
                bool _S1582 = leavesInFront_0((&faced_2)->geometry_n, throughput_8, _S1563.geometry_n);
                float3  _S1583 = _slang_select(_S1582, _S1581.front.scatter,_S1581.behind.scatter);
                scatter_in_0 = _S1583;
                float3  _S1584 = _slang_select(_S1582, _S1581.front.extinction,_S1581.behind.extinction);
                extinction_in_0 = _S1584;
                float _S1585 = _slang_select(_S1582, _S1581.front.g,_S1581.behind.g);
                g_in_0 = _S1585;
                uint _S1586 = _S1581.fillings.x;
                uint _S1587 = _S1581.fillings.y;
                uint _S1588 = _slang_select(_S1582, _S1587,_S1586);
                bool _S1589 = (fcptVaryingUsed());
                uint _S1590 = _slang_select(_S1589, _S1588,4294967295U);
                filling_2 = _S1590;
            }
            (&ray_2)->unit_direction = throughput_8;
            bool _S1591 = !_S1551;
            if(_S1591)
            {
                FKSurface _S1592 = surface_11;
                float _S1593 = _slang_select(straight_0, 0.0f,_S1592.geometry_offset);
                float3  _S1594 = - _S1344.smooth_n;
                bool _S1595 = is_inside_7 != _S1479;
                float3  _S1596 = _slang_select(_S1595, _S1594,_S1344.smooth_n);
                float3  _S1597 = (&ray_2)->origin + make_float3 (_S1593) * _S1596;
                (&ray_2)->origin = _S1597;
            }
            throughput_9 = throughput_10;
            chain_throughput_0 = chain_throughput_1;
            density_6 = sky_pdf_2;
            passes_0 = _S1551;
            viewed_1 = _S1477;
            sky_pdf_2 = _S1567;
            spread_5 = _S1568;
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
        bool _S1598 = !replay_2;
        float density_7;
        if(_S1598)
        {
            if(_S1313)
            {
                float3  _S1599 = throughput_9 * emission_1;
                Reservoir candidate_8 = chain_0;
                uint _S1600 = extractBits_0((&chain_0)->path, 10U, 2U);
                bool _S1601 = _S1600 == 1U;
                if(_S1601)
                {
                    float3  _S1602 = safeDivide(_S1599, chain_throughput_0);
                    (&candidate_8)->radiance = _S1602;
                }
                Reservoir _S1603 = withEnd(candidate_8, 2U, b_8, _S1599);
                offer(sel_7, _S1603, _S1599 * make_float3 (scale_3) / make_float3 (density_6));
            }
            if(_S1313)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = scatter_2;
            }
            if(refracted_4)
            {
                float _S1604 = survivalProbability(throughput_9, density_6);
                density_7 = _S1604;
            }
            else
            {
                density_7 = 1.0f;
            }
            uint _S1605 = stream(_S1199, b_8 + 128U);
            Random _S1606 = pcg(_S1605);
            bool _S1607 = density_7 < (_S1606.value);
            if(_S1607)
            {
                wrong_side_0 = true;
            }
            else
            {
                uint _S1608 = (fcptMaxBounces());
                wrong_side_0 = b_8 >= _S1608;
            }
            if(wrong_side_0)
            {
                break;
            }
            float _S1609 = density_6 * density_7;
            density_7 = _S1609;
        }
        else
        {
            density_7 = density_6;
        }
        uint _S1610 = layer_0 ^ 1U;
        uint _S1611 = _slang_select(passes_0, _S1610,0U);
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
            uint _S1612 = b_11 + 1U;
            b_8 = _S1612;
            layer_0 = _S1611;
            continue;
        }
        FKRay _S1613 = ray_2;
        float _S1614 = distance_1(reconnection_0, (&ray_2)->origin) * 1.0010000467300415f;
        if(replay_2)
        {
            refracted_4 = _S1382;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            wrong_side_0 = _S1176 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S1615 = _slang_select(wrong_side_0, _S1614,4.294967296e+09f);
        bool _S1616 = !_S1351;
        if(straight_0)
        {
            _S1426 = true;
        }
        else
        {
            _S1426 = _S1351;
        }
        FKHit _S1617;
        if(_S1426)
        {
            _S1617 = hit_4;
        }
        else
        {
            _S1617 = _S1399;
        }
        FKHit _S1618 = (fcptTraverseInstanceBVH((_S1613), (_S1318), (_S1615), (_S1616), (_S1617), (viewed_1)));
        hit_4 = _S1618;
        if(replay_2)
        {
            _S1427 = _S1382;
        }
        else
        {
            _S1427 = false;
        }
        if(_S1427)
        {
            _S1472 = _S1176 == 1U;
        }
        else
        {
            _S1472 = false;
        }
        if(_S1472)
        {
            _S1473 = ((&hit_4)->instance_index) == (_S1188.instance_index);
        }
        else
        {
            _S1473 = false;
        }
        if(_S1473)
        {
            _S1474 = ((&hit_4)->triangle_index) == (_S1188.triangle_index);
        }
        else
        {
            _S1474 = false;
        }
        if(_S1474)
        {
            (&hit_4)->uv = _S1188.uv;
            float _S1619 = distance_1(reconnection_0, (&ray_2)->origin);
            (&hit_4)->distance = _S1619;
        }
        if(replay_2)
        {
            _S1475 = _S1382;
        }
        else
        {
            _S1475 = false;
        }
        if(_S1475)
        {
            _S1476 = _S1176 == 3U;
        }
        else
        {
            _S1476 = false;
        }
        if(_S1476)
        {
            _S1477 = ((&hit_4)->instance_index) != 4294967295U;
        }
        else
        {
            _S1477 = false;
        }
        if(_S1477)
        {
            return _S1172;
        }
        Reservoir _S1620 = chain_0;
        uint _S1621 = filling_2;
        for(;;)
        {
            bool _S1622 = (fcptVaryingUsed());
            if(_S1622)
            {
                _S1478 = _S1621 != 4294967295U;
            }
            else
            {
                _S1478 = false;
            }
            float _S1623;
            if(_S1478)
            {
                float _S1624 = (fcptMajorant((_S1621)));
                _S1623 = _S1624;
            }
            else
            {
                _S1623 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
            }
            if(replay_2)
            {
                _S1479 = _S1382;
            }
            else
            {
                _S1479 = false;
            }
            if(_S1479)
            {
                _S1480 = _S1176 == 1U;
            }
            else
            {
                _S1480 = false;
            }
            if(_S1480)
            {
                _S1481 = _S1623 > 0.0f;
            }
            else
            {
                _S1481 = false;
            }
            if(_S1481)
            {
                ended_0 = _S1172;
                sky_pdf_1 = sky_pdf_2;
                spread_3 = spread_5;
                width_4 = width_3;
                density_3 = density_7;
                throughput_10 = throughput_9;
                b_11 = b_8;
                _S1482 = true;
                break;
            }
            bool _S1625 = (&prev_0)->rough;
            if(_S1625)
            {
                _S1482 = !(_S1623 > 0.0f);
            }
            else
            {
                _S1482 = false;
            }
            (&prev_0)->rough = _S1482;
            uint _S1626 = b_8 + 320U;
            bool _S1627 = b_8 == 4294967295U;
            uint _S1628 = _slang_select(_S1627, 384U,_S1626);
            uint _S1629 = stream(_S1199, _S1628);
            uint tracking_1 = _S1629;
            weight_1 = throughput_3;
            glowed_0 = _S1171;
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
                    _S1170 = int(2);
                    break;
                }
                uint _S1630 = b_11 + 320U;
                bool _S1631 = b_11 == 4294967295U;
                uint _S1632 = _slang_select(_S1631, 384U,_S1630);
                uint _S1633 = stream(_S1199, _S1632);
                Random _S1634 = pcg(_S1633);
                float _S1635 = freeFlight_0(_S1634.value, _S1623);
                if(_S1478)
                {
                    float3  _S1636 = (&ray_2)->origin;
                    float3  _S1637 = (&ray_2)->unit_direction;
                    float _S1638 = (&hit_4)->distance;
                    uint _S1639 = _slang_select(_S1631, 0U,b_11);
                    uint _S1640 = (&prev_0)->lobe;
                    uint _S1641 = _slang_select(_S1631, 3U,_S1640);
                    float _S1642 = (fcptTrackMedium((_S1621), (_S1636), (_S1637), (_S1638), (&tracking_1), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1639), (_S1641), (_S1631)));
                    spread_4 = _S1642;
                }
                else
                {
                    spread_4 = _S1635;
                }
                bool _S1643 = !(spread_4 < ((&hit_4)->distance));
                if(_S1643)
                {
                    _S1170 = int(2);
                    break;
                }
                if(_S1478)
                {
                    _S1483 = _S1598;
                }
                else
                {
                    _S1483 = false;
                }
                if(_S1483)
                {
                    float3  _S1644 = throughput_10 * glowed_0 / make_float3 (density_3);
                    float3  _S1645 = sel_7->glow + _S1644;
                    sel_7->glow = _S1645;
                }
                else
                {
                }
                glowed_0 = _S1171;
                uint b_12 = b_11 + 1U;
                float3  _S1646 = (&ray_2)->origin + make_float3 (spread_4) * (&ray_2)->unit_direction;
                (&ray_2)->origin = _S1646;
                float3  _S1647 = flightWeight_0(scatter_in_0, extinction_in_0, _S1623, spread_4, true);
                float3  _S1648 = weight_1;
                float3  _S1649 = _slang_select(_S1478, _S1648,_S1647);
                float3  throughput_11 = throughput_10 * _S1649;
                uint _S1650 = stream(_S1199, b_12 + 320U);
                tracking_1 = _S1650;
                weight_1 = throughput_3;
                float width_7 = width_4 + spread_3 * spread_4;
                float _S1651 = spread_3 + 3.14159274101257324f;
                bool _S1652 = scatterSampled_0(replay_2, b_12, _S1187, _S1478);
                TreeSample light_4;
                if(_S1652)
                {
                    float3  _S1653 = (&ray_2)->origin;
                    float3  _S1654 = (&ray_2)->unit_direction;
                    float3  _S1655 = (&ray_2)->unit_direction;
                    uint _S1656 = stream(_S1199, b_12 + 64U);
                    float3  _S1657 = extinction_in_0;
                    float3  _S1658 = extinction_in_0;
                    uint2  _S1659 = make_uint2 (_S1621);
                    float3  _S1660 = (&ray_2)->unit_direction;
                    uint _S1661 = arrivalLobe_0(b_12, (&prev_0)->lobe);
                    FKHit _S1662 = _S1399;
                    ShadowContext _S1663 = ShadowContext_x24init_0(_S1657, _S1658, _S1659, _S1660, b_12, _S1661, false, spread_4, width_7, &_S1662, false);
                    ShadowContext _S1664 = _S1663;
                    TreeSample _S1665 = sampleLightTree_0(_S1653, _S1654, _S1655, 0.0f, true, _S1656, &_S1664);
                    light_4 = _S1665;
                }
                else
                {
                    light_4 = _S1396;
                }
                float _S1666 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_4.dir));
                uint _S1667 = (fcptMaxBounces());
                bool _S1668 = b_12 < _S1667;
                if(_S1668)
                {
                    _S1484 = (light_4.density) > 0.0f;
                }
                else
                {
                    _S1484 = false;
                }
                float _S1669 = _slang_select(_S1484, _S1666,0.0f);
                float3  _S1670 = throughput_11 * light_4.radiance;
                float _S1671 = powerHeuristic(light_4.density, _S1669);
                float3  _S1672 = _S1670 * make_float3 (_S1666 * _S1671);
                float3  _S1673 = _slang_select(_S1652, _S1672,_S1171);
                if(replay_2)
                {
                    _S1485 = b_12 == _S1187;
                }
                else
                {
                    _S1485 = false;
                }
                if(_S1485)
                {
                    bool _S1674 = _S1176 == 2U;
                    if(_S1674)
                    {
                        float _S1675 = rgb_to_greyscale(_S1673);
                        _S1486 = _S1675 > 0.0f;
                    }
                    else
                    {
                        _S1486 = false;
                    }
                    if(_S1486)
                    {
                        Shift _S1676 = Shift_x24init_0(_S1673, 1.0f);
                        _S1170 = int(1);
                        ended_0 = _S1676;
                        spread_4 = _S1651;
                        width_5 = width_7;
                        throughput_8 = throughput_11;
                        b_9 = b_12;
                        break;
                    }
                    _S1170 = int(1);
                    ended_0 = _S1172;
                    spread_4 = _S1651;
                    width_5 = width_7;
                    throughput_8 = throughput_11;
                    b_9 = b_12;
                    break;
                }
                if(_S1598)
                {
                    Reservoir candidate_9 = _S1620;
                    uint _S1677 = extractBits_0(_S1620.path, 10U, 2U);
                    bool _S1678 = _S1677 == 1U;
                    if(_S1678)
                    {
                        float3  _S1679 = safeDivide(_S1673, chain_throughput_0);
                        (&candidate_9)->radiance = _S1679;
                    }
                    else
                    {
                        uint _S1680 = insertBits_0(0U, b_12 + 1U, 5U, 5U);
                        uint _S1681 = insertBits_0(_S1680, 2U, 10U, 2U);
                        (&candidate_9)->path = _S1681;
                    }
                    Reservoir _S1682 = withEnd(candidate_9, 0U, b_12, _S1673);
                    offer(sel_7, _S1682, _S1673 * make_float3 (scale_3) / make_float3 (density_3));
                    float _S1683 = survivalProbability(throughput_11, density_3);
                    uint _S1684 = stream(_S1199, b_12 + 128U);
                    Random _S1685 = pcg(_S1684);
                    bool _S1686 = _S1683 < (_S1685.value);
                    if(_S1686)
                    {
                        _S1486 = true;
                    }
                    else
                    {
                        uint _S1687 = (fcptMaxBounces());
                        _S1486 = b_12 >= _S1687;
                    }
                    if(_S1486)
                    {
                        _S1170 = int(1);
                        ended_0 = _S1172;
                        spread_4 = _S1651;
                        width_5 = width_7;
                        throughput_8 = throughput_11;
                        b_9 = b_12;
                        break;
                    }
                    float _S1688 = density_3 * _S1683;
                    density_3 = _S1688;
                }
                else
                {
                }
                float phase_pdf_1 = 0.0f;
                uint _S1689 = stream(_S1199, b_12);
                float3  _S1690 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1689, &phase_pdf_1);
                (&ray_2)->unit_direction = _S1690;
                NEEVertex _S1691 = NEEVertex_x24init_0(false, phase_pdf_1, (&ray_2)->origin, _S1171, (&ray_2)->origin);
                nee_vertex_0 = _S1691;
                Vertex _S1692 = scatteredVertex_0(is_inside_5);
                prev_0 = _S1692;
                float _S1693 = (&prev_0)->pdf;
                FKRay _S1694 = ray_2;
                FKHit _S1695 = (fcptTraverseInstanceBVH((_S1694), (true), (4.294967296e+09f), (false), (_S1399), (false)));
                hit_4 = _S1695;
                b_11 = b_12;
                throughput_10 = throughput_11;
                spread_3 = _S1651;
                width_4 = width_7;
                sky_pdf_1 = _S1693;
            }
            if(_S1170 != int(2))
            {
                spread_3 = spread_4;
                width_4 = width_5;
                throughput_10 = throughput_8;
                b_11 = b_9;
                _S1482 = true;
                break;
            }
            ended_0 = _S1172;
            _S1482 = false;
            break;
        }
        if(_S1482)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S1483 = b_11 == b_8;
        }
        else
        {
            _S1483 = false;
        }
        bool _S1696 = ((&hit_4)->instance_index) == 4294967295U;
        if(_S1696)
        {
            bool _S1697 = !(&nee_vertex_0)->none;
            float _S1698 = _slang_select(_S1697, sky_pdf_1,0.0f);
            float _S1699 = escapeWeight_0(_S1698, (&ray_2)->unit_direction);
            float3  _S1700 = environment_0((&ray_2)->unit_direction, b_11, (&prev_0)->lobe);
            float3  _S1701 = throughput_10 * _S1700;
            if(replay_2)
            {
                bool _S1702 = b_11 == _S1187;
                if(_S1702)
                {
                    passes_0 = _S1176 == 3U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(_S1701 * make_float3 (_S1699) / make_float3 (r_8->jac), density_3 / r_8->jac);
                }
                if(_S1186)
                {
                    passes_0 = _S1183;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = b_11 == _S1174;
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
                    return Shift_x24init_0(_S1701 * make_float3 (_S1699), 1.0f);
                }
                return _S1172;
            }
            Reservoir candidate_10 = chain_0;
            uint _S1703 = extractBits_0((&chain_0)->path, 10U, 2U);
            bool _S1704 = _S1703 == 1U;
            if(_S1704)
            {
                uint _S1705 = extractBits_0((&chain_0)->path, 5U, 5U);
                bool _S1706 = _S1705 == b_11;
                float _S1707 = _slang_select(_S1706, 1.0f,_S1699);
                float3  _S1708 = safeDivide(_S1701 * make_float3 (_S1707), chain_throughput_0);
                (&candidate_10)->radiance = _S1708;
            }
            else
            {
                bool _S1709 = (&prev_0)->rough;
                if(_S1709)
                {
                    uint _S1710 = insertBits_0(0U, b_11 + 1U, 5U, 5U);
                    uint _S1711 = insertBits_0(_S1710, 3U, 10U, 2U);
                    uint _S1712 = insertBits_0(_S1711, (&prev_0)->lobe, 15U, 3U);
                    bool _S1713 = (&prev_0)->inside;
                    uint _S1714 = _slang_select(_S1713, 1U,0U);
                    uint _S1715 = insertBits_0(_S1712, _S1714, 22U, 1U);
                    (&candidate_10)->path = _S1715;
                    (&candidate_10)->jac = (&prev_0)->pdf;
                    (&candidate_10)->dir = (&ray_2)->unit_direction;
                }
            }
            float3  _S1716 = _S1701 * make_float3 (_S1699);
            Reservoir _S1717 = withEnd(candidate_10, 3U, b_11, _S1716);
            offer(sel_7, _S1717, _S1716 * make_float3 (scale_3) / make_float3 (density_3));
            break;
        }
        float3  _S1718 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
        (&ray_2)->origin = _S1718;
        bool _S1719 = (fcptVaryingUsed());
        if(_S1719)
        {
            _S1484 = filling_2 != 4294967295U;
        }
        else
        {
            _S1484 = false;
        }
        if(_S1484)
        {
            if(_S1598)
            {
                float3  _S1720 = throughput_10 * glowed_0 / make_float3 (density_3);
                float3  _S1721 = sel_7->glow + _S1720;
                sel_7->glow = _S1721;
            }
            float3  _S1722 = throughput_10 * weight_1;
            throughput_8 = _S1722;
        }
        else
        {
            float3  _S1723 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
            float3  _S1724 = throughput_10 * _S1723;
            throughput_8 = _S1724;
        }
        float _S1725 = width_4 + spread_3 * (&hit_4)->distance;
        viewed_0 = _S1483;
        width_3 = _S1725;
        throughput_2 = throughput_8;
        density_2 = density_3;
        sky_pdf_0 = sky_pdf_1;
        spread_2 = spread_3;
        uint _S1612 = b_11 + 1U;
        b_8 = _S1612;
        layer_0 = _S1611;
    }
    return _S1172;
}

static __device__ Shift shift_0(Domain * dom_8, Reservoir * r_9)
{
    Selection _S1726 = (Selection{});
    Selection sel_8 = _S1726;
    bool _S1727 = (r_9->w) <= 0.0f;
    if(_S1727)
    {
        return Shift_x24init_0(make_float3 (0.0f), 0.0f);
    }
    Shift _S1728 = walk_0(dom_8, r_9, true, 0.0f, &sel_8);
    return _S1728;
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
    Random _S1729 = pcg(state_3);
    Random _S1730 = pcg(_S1729.state);
    float _S1731 = 6.28318548202514648f * _S1729.value;
    float _S1732 = (F32_sqrt((-2.0f * clamp_1((F32_log((_S1730.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S1730.state, _S1732 * (F32_cos((_S1731))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_4, float3  value_2)
{
    RandomSphere _S1733;
    (&_S1733)->state = state_4;
    (&_S1733)->value = value_2;
    return _S1733;
}

__device__ RandomSphere random_sphere(uint state_5)
{
    Random _S1734 = normal_distribution(state_5);
    Random _S1735 = normal_distribution(_S1734.state);
    Random _S1736 = normal_distribution(_S1735.state);
    float3  _S1737 = make_float3 (_S1734.value, _S1735.value, _S1736.value);
    float3  _S1738 = ((((_S1737)) * make_float3(rnorm3df(((_S1737)).x, ((_S1737)).y, ((_S1737)).z))));
    return RandomSphere_x24init_0(_S1736.state, _S1738);
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_14)
{
    float3  _S1739 = p1_0 - p0_0;
    float3  _S1740 = p2_0 - p0_0;
    float2  _S1741 = uv1_0 - uv0_0;
    float2  _S1742 = uv2_0 - uv0_0;
    float _S1743 = _S1741.x;
    float _S1744 = _S1742.y;
    float _S1745 = _S1741.y;
    float _S1746 = _S1742.x;
    float _S1747 = _S1743 * _S1744 - _S1745 * _S1746;
    float _S1748 = 1.0f / _S1747;
    float3  t_21 = (_S1739 * make_float3 (_S1744) - _S1740 * make_float3 (_S1745)) * make_float3 (_S1748);
    float3  _S1749 = (_S1740 * make_float3 (_S1743) - _S1739 * make_float3 (_S1746)) * make_float3 (_S1748);
    float3  _S1750 = t_21 - n_14 * make_float3 (dot_0(n_14, t_21));
    float3  t_22 = ((((_S1750)) * make_float3(rnorm3df(((_S1750)).x, ((_S1750)).y, ((_S1750)).z))));
    bool _S1751 = (dot_0(cross_0(n_14, t_22), _S1749)) > 0.0f;
    float3  t_23;
    if(_S1751)
    {
        float3  _S1752 = negate_0(t_22);
        t_23 = _S1752;
    }
    else
    {
        t_23 = t_22;
    }
    float3  _S1753 = cross_0(n_14, t_23);
    return makeMatrix<float, 3, 3> (t_23, _S1753, n_14);
}

__device__ float3  tangentToWorldNormalMap(float3  v_4, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_4, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_5, float3  uvw_0, float3  position_0)
{
    float3  _S1754 = t1_0 - t0_0;
    float3  _S1755 = t2_2 - t0_0;
    float3  _S1756 = t2_2 - t1_0;
    float _S1757 = (F32_min((length_0(_S1754)), ((F32_min((length_0(_S1755)), (length_0(_S1756)))))));
    float3  _S1758 = make_float3 (distance_1(position_0, t0_0), distance_1(position_0, t1_0), distance_1(position_0, t2_2));
    float3  _S1759 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S1760 = dot_0(geometry_n_5, _S1759);
    float3  _S1761 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S1762 = dot_0(geometry_n_5, _S1761);
    float3  _S1763 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S1764 = acos_0(abs_0(make_float3 (_S1760, _S1762, dot_0(geometry_n_5, _S1763))));
    float3  _S1765 = clamp_2(tan_0(_S1764), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_1(dot_0(_S1758 * _S1765, uvw_0), 0.0f, _S1757 * 0.125f);
}

__device__ float3  straightThrough(float3  dir_15, float3  n_15, BSDFMaterial material_16)
{
    float3  _S1766 = negate_0(dir_15);
    float _S1767 = sign_0(dot_0(n_15, _S1766));
    float3  _S1768 = n_15 * make_float3 (_S1767);
    AnisotropicFrame _S1769 = anisotropicFrame(material_16, _S1768);
    bool _S1770 = (_S1769.alphas.x) > 0.0f;
    if(_S1770)
    {
        float _S1771 = material_16.transmission * (1.0f - material_16.metallic);
        float3  _S1772 = negate_0(_S1768);
        float3  _S1773 = anisotropicLocal(dir_15, _S1769.tangent, _S1772);
        float _S1774 = anisotropicG1(_S1773, _S1769.alphas);
        return make_float3 (_S1771 * _S1774) * material_16.albedo;
    }
    float _S1775 = material_16.transmission * (1.0f - material_16.metallic);
    float _S1776 = material_16.roughness;
    float _S1777 = smithG1(_S1776 * _S1776, (F32_abs((dot_0(n_15, dir_15)))));
    return make_float3 (_S1775 * _S1777) * material_16.albedo;
}

__device__ float hairRow(float3  in_dir_10, float3  t_24, float3  out_dir_4, uint p_13, float w_2, float alpha_6, uint nt_0)
{
    uint _S1778 = p_13 % 4U;
    float _S1779 = w_2 * HAIR_WIDTHS_0[_S1778];
    float _S1780 = (F32_asin((clamp_1(dot_0(out_dir_4, t_24), -1.0f, 1.0f)))) - (F32_asin((clamp_1(dot_0(in_dir_10, t_24), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S1778] * alpha_6;
    return ((F32_asinh((_S1780 / _S1779))) / (F32_asinh((3.14159274101257324f / _S1779))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_11, float3  t_25, float3  out_dir_5, uint np_0)
{
    float3  _S1781 = worldToTangent(out_dir_5, t_25);
    float3  _S1782 = worldToTangent(in_dir_11, t_25);
    return (F32_frac((((F32_atan2((_S1781.z), (_S1781.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S1782.z), (1.17549435082228751e-38f - _S1782.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_12, float3  t_26, uint p_14, float row_0, float column_0, float w_3, float alpha_7, uint nt_1, uint np_1)
{
    float3  _S1783 = worldToTangent(in_dir_12, t_26);
    uint _S1784 = p_14 % 4U;
    float _S1785 = w_3 * HAIR_WIDTHS_0[_S1784];
    float _S1786 = (F32_asin((clamp_1(dot_0(in_dir_12, t_26), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S1784] * alpha_7 + _S1785 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S1785))))));
    float _S1787 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S1783.z), (1.17549435082228751e-38f - _S1783.x)));
    float _S1788 = (F32_cos((_S1786)));
    float3  _S1789 = tangentToWorld(make_float3 (_S1788 * (F32_cos((_S1787))), (F32_sin((_S1786))), _S1788 * (F32_sin((_S1787)))), t_26);
    return _S1789;
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_16, BSDFMaterial material_17, float coverage_1)
{
    float3  _S1790;
    if((material_17.ior) == 1.0f)
    {
        float3  _S1791 = straightThrough(toward_1, n_16, material_17);
        _S1790 = _S1791;
    }
    else
    {
        _S1790 = make_float3 (0.0f);
    }
    return _S1790 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ Shift walk_hook(Domain dom_9, Reservoir r_10, bool replay_3, float scale_4, Selection * sel_9)
{
    Domain _S1792 = dom_9;
    Reservoir _S1793 = r_10;
    Shift _S1794 = walk_0(&_S1792, &_S1793, replay_3, scale_4, sel_9);
    return _S1794;
}

__device__ Shift shift_hook(Domain dom_10, Reservoir r_11)
{
    Domain _S1795 = dom_10;
    Reservoir _S1796 = r_11;
    Shift _S1797 = shift_0(&_S1795, &_S1796);
    return _S1797;
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
