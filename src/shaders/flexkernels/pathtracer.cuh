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
        float _S405 = eta_o_1 * cos_theta_0;
        float _S406 = eta_i_1 * _S404;
        float _S407 = (_S405 - _S406) / (_S405 + _S406);
        float _S408 = eta_i_1 * cos_theta_0;
        float _S409 = eta_o_1 * _S404;
        float _S410 = (_S408 - _S409) / (_S408 + _S409);
        float _S411 = (_S407 * _S407 + _S410 * _S410) / 2.0f;
        kr_0 = _S411;
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
    float _S412 = (F32_max((w_1.z), (0.0f)));
    return 2.0f * _S412 / (_S412 + length_0(make_float3 (alphas_2.x * w_1.x, alphas_2.y * w_1.y, _S412)));
}

__device__ float anisotropicD(float3  h_0, float2  alphas_3)
{
    float _S413 = alphas_3.x;
    float _S414 = h_0.x / _S413;
    float _S415 = alphas_3.y;
    float _S416 = h_0.y / _S415;
    float _S417 = h_0.z;
    float _S418 = _S414 * _S414 + _S416 * _S416 + _S417 * _S417;
    return 1.0f / (F32_max((3.14159274101257324f * _S413 * _S415 * _S418 * _S418), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ BSDFLobes bsdfLobes(float3  in_dir_3, float3  v_4, float3  n_i_3, float3  ggx_n_0, BSDFMaterial material_3, float eta_i_2, float eta_o_2, AnisotropicFrame frame_2, SheenProfile sheen_profile_0)
{
    float _S419 = dot_0(ggx_n_0, v_4);
    float _S420 = dot_0(n_i_3, ggx_n_0);
    float _S421 = eta_i_2 / eta_o_2;
    float3  _S422 = refract_0(in_dir_3, ggx_n_0, _S421);
    float3  _S423 = ((((_S422)) * make_float3(rnorm3df(((_S422)).x, ((_S422)).y, ((_S422)).z))));
    float _S424 = (F32_min(((F32_sqrt((material_3.specular_level))) * (F32_abs((eta_i_2 - eta_o_2))) / (eta_i_2 + eta_o_2)), (0.9999847412109375f)));
    float _S425 = _S424 * _S424;
    float _S426 = (1.0f + _S424) / (1.0f - _S424);
    float _S427 = (F32_abs((_S419)));
    bool _S428 = eta_i_2 > eta_o_2;
    float sheen_component_0;
    if(_S428)
    {
        sheen_component_0 = _S426;
    }
    else
    {
        sheen_component_0 = 1.0f;
    }
    float toon_component_0;
    if(_S428)
    {
        toon_component_0 = 1.0f;
    }
    else
    {
        toon_component_0 = _S426;
    }
    float _S429 = fresnel(_S427, sheen_component_0, toon_component_0);
    bool _S430 = (eta_i_2 * eta_i_2 * (1.0f - _S419 * _S419)) >= (eta_o_2 * eta_o_2);
    float3  _S431;
    if(_S430)
    {
        _S431 = make_float3 (1.0f);
    }
    else
    {
        float3  _S432 = material_3.specular_tint * make_float3 (_S425);
        _S431 = _S432 + (make_float3 (1.0f) - _S432) * make_float3 (_S429 - _S425) / make_float3 (1.0f - _S425);
    }
    float3  _S433 = make_float3 (1.0f);
    float3  _S434 = make_float3 (0.0f);
    float3  sheen_1;
    float3  view_1;
    float3  scale_1;
    if(sheen_profile_0.on)
    {
        float _S435 = (F32_min((sheen_profile_0.albedo), (1.0f)));
        float3  _S436 = make_float3 (1.0f) - material_3.sheen * make_float3 (_S435);
        float _S437 = rgb_to_greyscale(material_3.sheen);
        float _S438 = _S437 * _S435;
        float3  _S439 = material_3.sheen / make_float3 ((F32_max((sheen_profile_0.albedo), (1.0f))));
        sheen_component_0 = _S438;
        sheen_1 = _S439;
        view_1 = v_4;
        scale_1 = _S436;
    }
    else
    {
        sheen_component_0 = 0.0f;
        sheen_1 = _S434;
        view_1 = _S434;
        scale_1 = _S433;
    }
    float _S440 = material_3.toon.x;
    bool _S441 = _S440 < 0.0f;
    float _S442 = (F32_abs((_S440)));
    bool _S443 = _S442 > 0.0f;
    float toon_a_1;
    float toon_s_1;
    float toon_b_1;
    float toon_norm_1;
    float toon_view_1;
    float3  toon_1;
    float3  toon_axis_1;
    bool _S444;
    if(_S443)
    {
        float _S445 = (F32_min((_S442), (1.0f)));
        float3  scale_2 = scale_1 * make_float3 (1.0f - _S445);
        float _S446 = rgb_to_greyscale(material_3.albedo);
        float _S447 = _S445 * _S446;
        float3  _S448 = make_float3 (_S445) * material_3.albedo;
        float toon_a_2 = clamp_1(material_3.toon.y / _S440, 0.00000999999974738f, 1.0f) * 3.14159274101257324f / 2.0f;
        float toon_s_2 = clamp_1(material_3.toon.z / _S440, 0.0f, 1.0f) * 3.14159274101257324f / 2.0f;
        float _S449 = (F32_min((toon_a_2 + toon_s_2), (1.57079637050628662f)));
        if(_S441)
        {
            toon_component_0 = 1.0f - (F32_cos(((F32_min((_S449), (toon_a_2))))));
        }
        else
        {
            float _S450 = (F32_sin(((F32_min((_S449), (toon_a_2))))));
            toon_component_0 = _S450 * _S450 / 2.0f;
        }
        bool _S451 = _S449 > toon_a_2;
        if(_S451)
        {
            _S444 = toon_s_2 > 0.0f;
        }
        else
        {
            _S444 = false;
        }
        if(_S444)
        {
            if(_S441)
            {
                float _S452 = (F32_cos((toon_a_2)));
                float _S453 = (F32_cos((_S449)));
                toon_a_1 = (1.0f + toon_a_2 / toon_s_2) * (_S452 - _S453) - ((F32_sin((_S449))) - _S449 * _S453 - ((F32_sin((toon_a_2))) - toon_a_2 * _S452)) / toon_s_2;
            }
            else
            {
                float _S454 = 2.0f * toon_a_2;
                float _S455 = (F32_cos((_S454)));
                float _S456 = 2.0f * _S449;
                float _S457 = (F32_cos((_S456)));
                toon_a_1 = (1.0f + toon_a_2 / toon_s_2) * (_S455 - _S457) / 4.0f - ((F32_sin((_S456))) / 8.0f - _S449 * _S457 / 4.0f - ((F32_sin((_S454))) / 8.0f - toon_a_2 * _S455 / 4.0f)) / toon_s_2;
            }
            float integral_0 = toon_component_0 + toon_a_1;
            toon_component_0 = integral_0;
        }
        float _S458 = 6.28318548202514648f * toon_component_0;
        float _S459 = dot_0(n_i_3, v_4);
        float _S460 = (F32_acos(((F32_min((_S459), (1.0f))))));
        if(_S460 < toon_a_2)
        {
            toon_component_0 = 1.0f;
        }
        else
        {
            toon_component_0 = (F32_max((1.0f - (_S460 - toon_a_2) / (F32_max((toon_s_2), (0.0000152587890625f)))), (0.0f)));
        }
        if(_S441)
        {
            float3  _S461 = make_float3 (2.0f * _S459) * n_i_3 - v_4;
            float3  _S462 = ((((_S461)) * make_float3(rnorm3df(((_S461)).x, ((_S461)).y, ((_S461)).z))));
            scale_1 = _S462;
        }
        else
        {
            scale_1 = n_i_3;
        }
        float _S463 = toon_component_0;
        toon_component_0 = _S447;
        toon_1 = _S448;
        toon_a_1 = toon_a_2;
        toon_s_1 = toon_s_2;
        toon_b_1 = _S449;
        toon_norm_1 = _S458;
        toon_view_1 = _S463;
        toon_axis_1 = scale_1;
        scale_1 = scale_2;
    }
    else
    {
        toon_component_0 = 0.0f;
        toon_1 = _S434;
        toon_a_1 = 0.0f;
        toon_s_1 = 0.0f;
        toon_b_1 = 0.0f;
        toon_norm_1 = 1.0f;
        toon_view_1 = 0.0f;
        toon_axis_1 = n_i_3;
    }
    float3  _S464 = mix_0(_S431, material_3.albedo, material_3.metallic);
    float3  F_1 = _S464 * scale_1;
    float _S465 = rgb_to_greyscale(F_1);
    float _S466 = 1.0f - material_3.metallic;
    float3  _S467 = make_float3 (1.0f) - _S431;
    float3  _S468 = make_float3 ((1.0f - material_3.transmission) * _S466) * _S467 * scale_1;
    float3  _S469 = make_float3 (material_3.transmission * _S466) * _S467 * scale_1;
    float _S470 = (F32_max((_S465), (0.0f)));
    float _S471 = rgb_to_greyscale(_S468);
    float _S472 = (F32_max((_S471), (0.0f)));
    float _S473 = rgb_to_greyscale(_S469);
    float _S474 = sign_0(length_0(_S423));
    float _S475 = (F32_max((_S473 * _S474), (0.0f)));
    float _S476 = _S470 + _S472 + _S475 + toon_component_0;
    float _S477 = (F32_min((sheen_component_0), (1.0f)));
    bool _S478 = sheen_component_0 > 0.0f;
    if(_S478)
    {
        _S444 = !(_S476 > 0.0f);
    }
    else
    {
        _S444 = false;
    }
    float _S479 = _slang_select(_S444, 1.0f,_S477);
    float _S480 = (1.0f - _S479) / (F32_max((_S476), (0.0000152587890625f)));
    float _S481 = _S472 * _S480;
    float _S482 = _S470 * _S480;
    float _S483 = _S475 * _S480;
    bool _S484 = (frame_2.alphas.x) > 0.0f;
    float visible_1;
    if(_S484)
    {
        float3  _S485 = anisotropicLocal(v_4, frame_2.tangent, n_i_3);
        float _S486 = anisotropicG1(_S485, frame_2.alphas);
        float3  _S487 = anisotropicLocal(ggx_n_0, frame_2.tangent, n_i_3);
        float _S488 = anisotropicD(_S487, frame_2.alphas);
        float _S489 = _S486 * _S488;
        visible_1 = _S489;
    }
    else
    {
        visible_1 = 0.0f;
    }
    return BSDFLobes_x24init_0(_S419, _S420, _S423, F_1, _S465, 1.0f, _S468, _S469, _S481, _S482, _S483, 0.0f, sheen_1, _S479, view_1, frame_2.tangent, frame_2.alphas, visible_1, toon_component_0 * _S480, toon_1, toon_a_1, toon_s_1, toon_b_1, _S441, toon_norm_1, toon_view_1, toon_axis_1);
}

__device__ float translucentShare(BSDFMaterial material_4)
{
    float _S490 = rgb_to_greyscale(material_4.translucent);
    float _S491 = rgb_to_greyscale(material_4.albedo);
    float _S492 = _S490 / (_S491 + _S490);
    bool _S493 = _S490 > 0.0f;
    float _S494 = _slang_select(_S493, _S492,0.0f);
    return _S494;
}

__device__ __forceinline__ float diffusePDF(float n_i_dot_l_0, float l_dot_h_0, float n_i_dot_v_0, float alpha_2, BSDFLobes lobes_0, float eta_i_3, float eta_o_3)
{
    float _S495 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    float _S496 = lobes_0.p_diffuse * (F32_abs((n_i_dot_l_0))) * 0.31830987334251404f;
    float _S497 = 1.0f - lobes_0.translucent_share;
    bool _S498 = n_i_dot_l_0 < 0.0f;
    float _S499 = _slang_select(_S498, lobes_0.translucent_share,_S497);
    float _S500 = _S496 * _S499;
    bool _S501 = (lobes_0.translucent_share) > 0.0f;
    float _S502 = _slang_select(_S501, _S500,_S495);
    bool _S503 = n_i_dot_v_0 > 0.0f;
    float _S504 = _slang_select(_S503, _S502,0.0f);
    return _S504;
}

__device__ __forceinline__ float3  diffuseBSDF(float3  l_0, float3  n_i_4, float alpha_3, BSDFMaterial material_5, BSDFLobes lobes_1)
{
    bool _S505 = (dot_0(n_i_4, l_0)) < 0.0f;
    float3  _S506 = _slang_select(_S505, material_5.translucent,material_5.albedo);
    float _S507 = 1.0f - lobes_1.translucent_share;
    float _S508 = _slang_select(_S505, lobes_1.translucent_share,_S507);
    float3  _S509 = _S506 / make_float3 (_S508);
    bool _S510 = (lobes_1.translucent_share) > 0.0f;
    float3  _S511 = _slang_select(_S510, _S509,material_5.albedo);
    return lobes_1.diffuse_weight * _S511 / make_float3 (lobes_1.p_diffuse);
}

__device__ float smithG1(float alpha_4, float n_dot_x_0)
{
    float _S512 = alpha_4 * alpha_4;
    float _S513 = 2.0f * n_dot_x_0 / (n_dot_x_0 + (F32_sqrt((_S512 + (1.0f - _S512) * n_dot_x_0 * n_dot_x_0))));
    bool _S514 = alpha_4 > 0.0f;
    float _S515 = _slang_select(_S514, _S513,1.0f);
    return _S515;
}

__device__ float trowbridgeReitz(float alpha_5, float n_dot_h_1)
{
    float _S516 = alpha_5 * alpha_5;
    float _S517 = (1.0f - n_dot_h_1) * (1.0f + n_dot_h_1) + _S516 * n_dot_h_1 * n_dot_h_1;
    return _S516 / (F32_max((3.14159274101257324f * _S517 * _S517), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ float vndfPDF(float n_i_dot_v_1, float alpha_6, BSDFLobes lobes_2)
{
    float _S518 = smithG1(alpha_6, n_i_dot_v_1);
    float _S519 = _S518 * lobes_2.v_dot_h;
    float _S520 = trowbridgeReitz(alpha_6, lobes_2.n_dot_h);
    float _S521 = _S519 * _S520 / n_i_dot_v_1;
    bool _S522 = alpha_6 > 0.0f;
    bool _S523;
    if(_S522)
    {
        _S523 = (lobes_2.v_dot_h) > 0.0f;
    }
    else
    {
        _S523 = false;
    }
    if(_S523)
    {
        _S523 = (lobes_2.n_dot_h) > 0.0f;
    }
    else
    {
        _S523 = false;
    }
    if(_S523)
    {
        _S523 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S523 = false;
    }
    float _S524 = _slang_select(_S523, _S521,0.0f);
    bool _S525 = (lobes_2.alphas.x) > 0.0f;
    float pdf_h_0;
    if(_S525)
    {
        float _S526 = lobes_2.visible * lobes_2.v_dot_h / n_i_dot_v_1;
        bool _S527 = (lobes_2.v_dot_h) > 0.0f;
        if(_S527)
        {
            _S523 = (lobes_2.n_dot_h) > 0.0f;
        }
        else
        {
            _S523 = false;
        }
        if(_S523)
        {
            _S523 = n_i_dot_v_1 > 0.0f;
        }
        else
        {
            _S523 = false;
        }
        float _S528 = _slang_select(_S523, _S526,0.0f);
        pdf_h_0 = _S528;
    }
    else
    {
        pdf_h_0 = _S524;
    }
    return pdf_h_0;
}

__device__ __forceinline__ float refractPDF(float n_i_dot_l_1, float l_dot_h_1, float n_i_dot_v_2, float alpha_7, BSDFLobes lobes_3, float eta_i_4, float eta_o_4)
{
    float _S529 = vndfPDF(n_i_dot_v_2, alpha_7, lobes_3);
    float _S530 = eta_i_4 * lobes_3.v_dot_h + eta_o_4 * l_dot_h_1;
    float _S531 = lobes_3.p_refract * _S529 * eta_o_4 * eta_o_4 * (F32_abs((l_dot_h_1))) / (_S530 * _S530);
    bool _S532 = eta_i_4 != eta_o_4;
    bool _S533;
    if(_S532)
    {
        _S533 = l_dot_h_1 < 0.0f;
    }
    else
    {
        _S533 = false;
    }
    float _S534 = _slang_select(_S533, _S531,0.0f);
    return _S534;
}

__device__ __forceinline__ float3  refractBSDF(float3  l_1, float3  n_i_5, float alpha_8, BSDFMaterial material_6, BSDFLobes lobes_4)
{
    float _S535 = - dot_0(n_i_5, l_1);
    float _S536 = smithG1(alpha_8, (F32_max((_S535), (0.0f))));
    bool _S537 = (lobes_4.alphas.x) > 0.0f;
    float G1_l_0;
    if(_S537)
    {
        float3  _S538 = negate_0(n_i_5);
        float3  _S539 = anisotropicLocal(l_1, lobes_4.tangent, _S538);
        float _S540 = anisotropicG1(_S539, lobes_4.alphas);
        G1_l_0 = _S540;
    }
    else
    {
        G1_l_0 = _S536;
    }
    return lobes_4.refract_weight * make_float3 (G1_l_0) * material_6.albedo / make_float3 (lobes_4.p_refract);
}

__device__ __forceinline__ float sheenVelvetPDF(float n_i_dot_l_2, float l_dot_h_2, float n_i_dot_v_3, float alpha_9, BSDFLobes lobes_5, float eta_i_5, float eta_o_5)
{
    float _S541 = lobes_5.p_sheen_velvet * 0.5f * 0.31830987334251404f;
    bool _S542 = n_i_dot_l_2 > 0.0f;
    bool _S543;
    if(_S542)
    {
        _S543 = n_i_dot_v_3 > 0.0f;
    }
    else
    {
        _S543 = false;
    }
    float _S544 = _slang_select(_S543, _S541,0.0f);
    return _S544;
}

__device__ __forceinline__ float3  sheenVelvetBSDF(float3  l_2, float3  n_i_6, float alpha_10, BSDFMaterial material_7, BSDFLobes lobes_6)
{
    float3  _S545 = l_2 + lobes_6.view;
    float3  _S546 = ((((_S545)) * make_float3(rnorm3df(((_S545)).x, ((_S545)).y, ((_S545)).z))));
    float _S547 = dot_0(n_i_6, _S546);
    float _S548 = (F32_max((dot_0(n_i_6, l_2)), (0.0f)));
    float _S549 = (F32_max((dot_0(n_i_6, lobes_6.view)), (0.0f)));
    float _S550 = 1.0f / (F32_max((material_7.sheen_roughness), (0.05000000074505806f)));
    float _S551 = 1.0f - _S547 * _S547;
    float _S552 = (2.0f + _S550) * (F32_pow(((F32_max((_S551), (0.0f)))), (0.5f * _S550))) * 0.5f * 0.31830987334251404f / (F32_max((4.0f * (_S548 + _S549 - _S548 * _S549)), (0.0000152587890625f)));
    bool _S553 = (material_7.velvet) > 0.0f;
    float f_1;
    if(_S553)
    {
        float _S554 = (F32_max((material_7.sheen_roughness), (0.00999999977648258f)));
        float _S555 = _S554 * _S554;
        float _S556 = (F32_max((_S551), (0.0000152587890625f)));
        float _S557 = (F32_exp((- _S547 * _S547 / (_S556 * _S555)))) / (3.14159274101257324f * _S555 * _S556 * _S556) * (F32_min((1.0f), (2.0f * _S547 * (F32_min((_S548), (_S549))) / (F32_max(((F32_abs((dot_0(_S546, lobes_6.view))))), (0.0000152587890625f)))))) / (F32_max((4.0f * _S548 * _S549), (0.0000152587890625f)));
        f_1 = _S557;
    }
    else
    {
        f_1 = _S552;
    }
    return lobes_6.sheen * make_float3 (f_1 * _S548 * 2.0f * 3.14159274101257324f / lobes_6.p_sheen_velvet);
}

__device__ __forceinline__ float toonPDF(float n_i_dot_l_3, float l_dot_h_3, float n_i_dot_v_4, float alpha_11, BSDFLobes lobes_7, float eta_i_6, float eta_o_6)
{
    float _S558 = _slang_select(lobes_7.toon_glossy, l_dot_h_3,n_i_dot_l_3);
    float _S559 = (F32_acos((clamp_1(_S558, -1.0f, 1.0f))));
    float _S560;
    if(_S559 < (lobes_7.toon_a))
    {
        _S560 = 1.0f;
    }
    else
    {
        _S560 = (F32_max((1.0f - (_S559 - lobes_7.toon_a) / (F32_max((lobes_7.toon_s), (0.0000152587890625f)))), (0.0f)));
    }
    float _S561 = lobes_7.p_toon * _S560;
    float _S562 = _slang_select(lobes_7.toon_glossy, 1.0f,n_i_dot_l_3);
    float _S563 = _S561 * _S562 / lobes_7.toon_norm;
    bool _S564;
    if(lobes_7.toon_glossy)
    {
        _S564 = true;
    }
    else
    {
        _S564 = n_i_dot_l_3 > 0.0f;
    }
    float _S565 = _slang_select(_S564, _S563,0.0f);
    return _S565;
}

__device__ __forceinline__ float3  toonBSDF(float3  l_3, float3  n_i_7, float alpha_12, BSDFMaterial material_8, BSDFLobes lobes_8)
{
    float _S566 = (F32_max((dot_0(n_i_7, l_3)), (0.0f)));
    float _S567 = _slang_select(lobes_8.toon_glossy, _S566,lobes_8.toon_view);
    return lobes_8.toon * make_float3 (_S567) / make_float3 (lobes_8.p_toon);
}

__device__ __forceinline__ float reflectPDF(float n_i_dot_l_4, float l_dot_h_4, float n_i_dot_v_5, float alpha_13, BSDFLobes lobes_9, float eta_i_7, float eta_o_7)
{
    float _S568 = vndfPDF(n_i_dot_v_5, alpha_13, lobes_9);
    float _S569 = lobes_9.p_reflect * _S568 / (4.0f * lobes_9.v_dot_h);
    bool _S570 = _S568 > 0.0f;
    float _S571 = _slang_select(_S570, _S569,0.0f);
    return _S571;
}

__device__ __forceinline__ float3  reflectBSDF(float3  l_4, float3  n_i_8, float alpha_14, BSDFMaterial material_9, BSDFLobes lobes_10)
{
    float _S572 = dot_0(n_i_8, l_4);
    float _S573 = smithG1(alpha_14, (F32_max((_S572), (0.0f))));
    bool _S574 = (lobes_10.alphas.x) > 0.0f;
    float G1_l_1;
    if(_S574)
    {
        float3  _S575 = anisotropicLocal(l_4, lobes_10.tangent, n_i_8);
        float _S576 = anisotropicG1(_S575, lobes_10.alphas);
        G1_l_1 = _S576;
    }
    else
    {
        G1_l_1 = _S573;
    }
    return make_float3 (lobes_10.reflect_weight * G1_l_1) * lobes_10.F / make_float3 (lobes_10.p_reflect);
}

__device__ __forceinline__ float3  BSDF(float3  in_dir_4, float3  out_dir_2, float3  n_7, BSDFMaterial material_10, float eta_i_8, float eta_o_8, bool refracted_2, uint random_state_4, FixedArray<float3 , 5>  * throughputs_0, FixedArray<float, 5>  * pdfs_0)
{
    float3  ggx_n_1;
    float3  _S577 = negate_0(in_dir_4);
    float _S578 = dot_0(n_7, _S577);
    float _S579 = sign_0(_S578);
    float3  _S580 = n_7 * make_float3 (_S579);
    AnisotropicFrame _S581 = anisotropicFrame(material_10, _S580);
    float _S582 = dot_0(_S580, out_dir_2);
    float _S583 = material_10.roughness;
    float _S584 = _S583 * _S583;
    SheenProfile _S585 = sheenProfile(_S577, _S580, material_10);
    float _S586 = rgb_to_greyscale(material_10.translucent);
    bool _S587 = _S586 > 0.0f;
    bool _S588 = (dot_0(n_7, out_dir_2) * _S578) < 0.0f;
    uint _S589;
    if((F32_abs((material_10.toon.x))) > 0.0f)
    {
        _S589 = 5U;
    }
    else
    {
        _S589 = 4U;
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
        float3  _S590 = make_float3 (0.0f);
        (*throughputs_0)[i_6] = _S590;
        (*pdfs_0)[i_6] = 0.0f;
        uint i_7 = i_6 + 1U;
        i_6 = i_7;
    }
    float3  _S591 = make_float3 (0.0f);
    BSDFLobes _S592 = BSDFLobes_x24init_0(0.0f, 0.0f, _S591, _S591, 0.0f, 0.0f, _S591, _S591, 0.0f, 0.0f, 0.0f, 0.0f, _S591, 0.0f, _S591, _S591, make_float2 (0.0f), 0.0f, 0.0f, _S591, 0.0f, 0.0f, 0.0f, false, 1.0f, 0.0f, _S591);
    BSDFLobes lobe_terms_0 = _S592;
    uint half_of_0 = 4294967295U;
    float3  ggx_n_2 = _S591;
    i_6 = 0U;
    for(;;)
    {
        if(i_6 < _S589)
        {
        }
        else
        {
            break;
        }
        uint _S593;
        if(i_6 == 3U)
        {
            _S593 = 4U;
        }
        else
        {
            if(i_6 == 4U)
            {
                _S593 = 6U;
            }
            else
            {
                _S593 = i_6;
            }
        }
        bool _S594 = _S593 == 0U;
        bool _S595;
        if(_S594)
        {
            _S595 = _S587;
        }
        else
        {
            _S595 = false;
        }
        bool _S596;
        if(_S595)
        {
            _S596 = _S588;
        }
        else
        {
            _S596 = _S593 == 1U;
        }
        bool _S597 = _S596 != refracted_2;
        if(_S597)
        {
            ggx_n_1 = ggx_n_2;
            uint i_8 = i_6 + 1U;
            ggx_n_2 = ggx_n_1;
            i_6 = i_8;
            continue;
        }
        uint _S598;
        if(_S593 == 6U)
        {
            _S598 = 0U;
        }
        else
        {
            if(_S593 == 4U)
            {
                _S598 = 2U;
            }
            else
            {
                _S598 = _S593;
            }
        }
        bool _S599 = _S598 != half_of_0;
        uint half_of_1;
        if(_S599)
        {
            bool _S600 = _S598 == 0U;
            if(_S600)
            {
                float3  _S601 = sampledHalf(in_dir_4, n_7, material_10, random_state_4, _S581);
                ggx_n_1 = _S601;
            }
            else
            {
                bool _S602 = _S598 == 1U;
                if(_S602)
                {
                    float3  _S603 = refractedHalf(in_dir_4, out_dir_2, n_7, eta_i_8, eta_o_8);
                    ggx_n_1 = _S603;
                }
                else
                {
                    float3  _S604 = reflectedHalf(in_dir_4, out_dir_2);
                    ggx_n_1 = _S604;
                }
            }
            float3  _S605 = negate_0(in_dir_4);
            BSDFLobes _S606 = bsdfLobes(in_dir_4, _S605, _S580, ggx_n_1, material_10, eta_i_8, eta_o_8, _S581, _S585);
            lobe_terms_0 = _S606;
            float _S607 = translucentShare(material_10);
            (&lobe_terms_0)->translucent_share = _S607;
            half_of_1 = _S598;
        }
        else
        {
            ggx_n_1 = ggx_n_2;
            half_of_1 = half_of_0;
        }
        switch(_S593)
        {
        case 0U:
            {
                float _S608 = diffusePDF(_S582, 0.0f, (F32_abs((_S578))), _S584, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(0)] = _S608;
                float3  _S609 = diffuseBSDF(out_dir_2, _S580, _S584, material_10, lobe_terms_0);
                (*throughputs_0)[int(0)] = _S609;
                break;
            }
        case 1U:
            {
                float _S610 = refractPDF(_S582, dot_0(out_dir_2, ggx_n_1), (F32_abs((_S578))), _S584, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(1)] = _S610;
                float3  _S611 = refractBSDF(out_dir_2, _S580, _S584, material_10, lobe_terms_0);
                (*throughputs_0)[int(1)] = _S611;
                break;
            }
        case 4U:
            {
                float _S612 = sheenVelvetPDF(_S582, 0.0f, (F32_abs((_S578))), _S584, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(3)] = _S612;
                float3  _S613 = sheenVelvetBSDF(out_dir_2, _S580, _S584, material_10, lobe_terms_0);
                (*throughputs_0)[int(3)] = _S613;
                break;
            }
        case 6U:
            {
                float _S614 = toonPDF(_S582, dot_0(out_dir_2, (&lobe_terms_0)->toon_axis), (F32_abs((_S578))), _S584, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(4)] = _S614;
                float3  _S615 = toonBSDF(out_dir_2, _S580, _S584, material_10, lobe_terms_0);
                (*throughputs_0)[int(4)] = _S615;
                break;
            }
        default:
            {
                float _S616 = reflectPDF(_S582, 0.0f, (F32_abs((_S578))), _S584, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(2)] = _S616;
                float3  _S617 = reflectBSDF(out_dir_2, _S580, _S584, material_10, lobe_terms_0);
                (*throughputs_0)[int(2)] = _S617;
                break;
            }
        }
        half_of_0 = half_of_1;
        uint i_8 = i_6 + 1U;
        ggx_n_2 = ggx_n_1;
        i_6 = i_8;
    }
    i_6 = 0U;
    ggx_n_1 = _S591;
    for(;;)
    {
        if(i_6 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S618 = ((*pdfs_0)[i_6]) > 0.0f;
        if(_S618)
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
    bool _S619 = wrongSide_0(is_inside_2, false, dir_3, surface_1->geometry_n);
    float3  _S620 = BSDF(in_dir_5, dir_3, surface_1->smooth_n, surface_1->material, eta_1.x, eta_1.y, _S619, random_state_5, terms_0, pdfs_1);
    float3  _S621 = make_float3 (0.0f);
    uint i_10 = 0U;
    float3  f_3 = _S621;
    for(;;)
    {
        if(i_10 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S622 = ((*pdfs_1)[i_10]) > 0.0f;
        if(_S622)
        {
            float3  _S623 = (*terms_0)[i_10] * make_float3 ((*pdfs_1)[i_10]) / make_float3 ((*pdfs_1)[i_10] + pdf_0);
            (*terms_0)[i_10] = _S623;
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
    FKSurface _S624 = surface_2;
    FixedArray<float3 , 5>  terms_1;
    FixedArray<float, 5>  pdfs_2;
    float3  _S625 = skyLobes_0(in_dir_6, dir_4, &_S624, eta_2, is_inside_3, pdf_1, random_state_6, &terms_1, &pdfs_2);
    return _S625;
}

static __device__ SkySample SkySample_x24init_0(float3  dir_5, float3  radiance_0, float3  color_0, uint random_state_7)
{
    SkySample _S626;
    (&_S626)->dir = dir_5;
    (&_S626)->radiance = radiance_0;
    (&_S626)->color = color_0;
    (&_S626)->random_state = random_state_7;
    return _S626;
}

static __device__ SkySample sampleSky_0(FKRay * ray_0, FKSurface * surface_3, float2  eta_3, bool is_inside_4, uint init_random_state_0, uint lobe_state_0, ShadowContext * context_2)
{
    uint2  _S627 = (fcptEnvironmentCdfSize());
    uint2  _S628 = make_uint2 (1U, 0U);
    uint2  _S629 = _S627 - _S628;
    Random _S630 = pcg(init_random_state_0);
    Random _S631 = pcg(_S630.state);
    Random _S632 = pcg(_S631.state);
    Random _S633 = pcg(_S632.state);
    uint _S634 = _S629.x;
    uint _S635 = searchCDF_0(make_uint2 (_S634, 0U), make_uint2 (0U, 1U), _S629.y, _S630.value);
    uint _S636 = searchCDF_0(make_uint2 (0U, _S635), _S628, _S634, _S631.value);
    float2  _S637 = make_float2 ((float)_S629.x, (float)_S629.y);
    float2  _S638 = (make_float2 (float(_S636), float(_S635)) + make_float2 (_S632.value, _S633.value)) / _S637 * make_float2 (6.28318548202514648f, 3.14159274101257324f);
    float _S639 = _S638.y;
    float _S640 = (F32_sin((_S639)));
    float _S641 = _S638.x;
    float3  _S642 = make_float3 (- _S640 * (F32_cos((_S641))), _S640 * (F32_sin((_S641))), (F32_cos((_S639))));
    float _S643 = environmentPdf_0(_S642);
    float3  _S644 = skyBSDF(ray_0->unit_direction, _S642, *surface_3, eta_3, is_inside_4, _S643, lobe_state_0);
    bool _S645 = !(_S643 > 0.0f);
    bool _S646;
    if(_S645)
    {
        _S646 = true;
    }
    else
    {
        _S646 = all_1(_S644 == make_float3 (0.0f));
    }
    if(_S646)
    {
        float3  _S647 = make_float3 (0.0f);
        return SkySample_x24init_0(_S642, _S647, _S647, _S633.state);
    }
    float3  _S648 = skyRadiance_0(ray_0->origin, surface_3, is_inside_4, _S642, context_2, _S633.state);
    return SkySample_x24init_0(_S642, _S648, _S644 * _S648, _S633.state);
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
    SampleBSDF _S649 = (fcptConnectHair((surface_4->hair), ((&surface_4->material)->albedo), ((&surface_4->material)->specular_tint), (in_dir_7), (light_1->dir)));
    float3  _S650 = _S649.throughput * make_float3 (_S649.pdf);
    float _S651 = light_1->density;
    float _S652 = 1.0f + _S649.pdf * _S649.pdf / (light_1->density * light_1->density);
    bool _S653;
    if(competing_0)
    {
        _S653 = _S651 > 0.0f;
    }
    else
    {
        _S653 = false;
    }
    float _S654 = _slang_select(_S653, _S652,1.0f);
    return _S650 / make_float3 (_S654) * light_1->radiance;
}

static __device__ TreeSample TreeSample_x24init_0(float3  dir_6, float3  radiance_1, float density_0, uint random_state_8)
{
    TreeSample _S655;
    (&_S655)->dir = dir_6;
    (&_S655)->radiance = radiance_1;
    (&_S655)->density = density_0;
    (&_S655)->random_state = random_state_8;
    return _S655;
}

__device__ uint pickChild(LightNode first_1, LightNode second_1, float3  p_11, float3  normal_3, float * pick_0, float * probability_3)
{
    float _S656 = importance(first_1, p_11, normal_3);
    float _S657 = importance(second_1, p_11, normal_3);
    float2  _S658 = make_float2 (_S656, _S657);
    bool _S659 = _S656 == 0.0f;
    bool _S660;
    if(_S659)
    {
        _S660 = _S657 == 0.0f;
    }
    else
    {
        _S660 = false;
    }
    if(_S660)
    {
        return 2U;
    }
    float _S661 = _S656 + _S657;
    bool _S662 = _S657 > 0.0f;
    if(_S662)
    {
        _S660 = (*pick_0 * _S661) >= _S656;
    }
    else
    {
        _S660 = false;
    }
    uint _S663 = uint(_S660);
    float _S664 = (F32_min(((*pick_0 * _S661 - float(_S663) * _S656) / _slang_vector_get_element(_S658, _S663)), (0.99999994039535522f)));
    *pick_0 = _S664;
    float _S665 = *probability_3 * (_slang_vector_get_element(_S658, _S663) / _S661);
    *probability_3 = _S665;
    return _S663;
}

__device__ float3  sampleSphere(float3  center_1, float radius_1, float3  p_12, float u1_0, float u2_0)
{
    float3  _S666 = center_1 - p_12;
    float _S667 = radius_1 * radius_1 / dot_0(_S666, _S666);
    float _S668 = u1_0 * _S667 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S667), (0.0f)))))));
    float _S669 = 2.0f * u1_0;
    bool _S670 = _S667 >= 1.0f;
    float _S671 = _slang_select(_S670, _S669,_S668);
    float _S672 = (F32_sqrt(((F32_max((_S671 * (2.0f - _S671)), (0.0f))))));
    float _S673 = 6.28318548202514648f * u2_0;
    float3  _S674 = make_float3 (_S672 * (F32_cos((_S673))), 1.0f - _S671, _S672 * (F32_sin((_S673))));
    float3  _S675 = ((((_S666)) * make_float3(rnorm3df(((_S666)).x, ((_S666)).y, ((_S666)).z))));
    float3  _S676 = tangentToWorld(_S674, _S675);
    return _S676;
}

__device__ float3  pointLightRadiance(float3  color_1, float intensity_0, float radius_2)
{
    return color_1 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_2 * radius_2);
}

static __device__ float raySphere_0(float3  center_2, float radius_3, FKRay * ray_1, float max_len_0)
{
    float3  _S677 = center_2 - ray_1->origin;
    float _S678 = dot_0(_S677, ray_1->unit_direction);
    float _S679 = dot_0(_S677, _S677) - _S678 * _S678;
    float _S680 = radius_3 * radius_3;
    bool _S681 = _S679 > _S680;
    if(_S681)
    {
        return 4.294967296e+09f;
    }
    float _S682 = (F32_sqrt((_S680 - _S679)));
    float _S683 = _S678 - _S682;
    float _S684 = _S678 + _S682;
    bool _S685 = _S683 > 0.0000152587890625f;
    bool _S686;
    if(_S685)
    {
        _S686 = _S683 < max_len_0;
    }
    else
    {
        _S686 = false;
    }
    if(_S686)
    {
        return _S683;
    }
    bool _S687 = _S684 > 0.0000152587890625f;
    if(_S687)
    {
        _S686 = _S684 < max_len_0;
    }
    else
    {
        _S686 = false;
    }
    if(_S686)
    {
        return _S684;
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
    Random _S688 = pcg(init_random_state_1);
    Random _S689 = pcg(_S688.state);
    Random _S690 = pcg(_S689.state);
    float3  _S691 = make_float3 (0.0f);
    TreeSample _S692 = TreeSample_x24init_0(_S691, _S691, 0.0f, _S690.state);
    TreeSample sample_0 = _S692;
    float3  _S693 = _slang_select(sided_0, _S691,smooth_n_2);
    float3  _S694 = origin_4 + make_float3 (geometry_offset_1) * smooth_n_2;
    float pick_1 = _S688.value;
    float probability_4 = 1.0f;
    uint n_8 = 0U;
    for(;;)
    {
        uint4  _S695 = (fcptLightNode((n_8)));
        if((_S695.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S696 = (fcptLightSecond((n_8)));
        uint _S697 = n_8 + 1U;
        LightNode _S698 = (fcptLightBounds((_S697)));
        LightNode _S699 = (fcptLightBounds((_S696)));
        uint _S700 = pickChild(_S698, _S699, origin_4, _S693, &pick_1, &probability_4);
        bool _S701 = _S700 > 1U;
        if(_S701)
        {
            return sample_0;
        }
        bool _S702 = _S700 == 1U;
        uint _S703 = _slang_select(_S702, _S696,_S697);
        n_8 = _S703;
    }
    bool _S704 = n_8 == 0U;
    bool _S705;
    if(_S704)
    {
        LightNode _S706 = (fcptLightBounds((0U)));
        float _S707 = importance(_S706, origin_4, _S693);
        _S705 = !(_S707 > 0.0f);
    }
    else
    {
        _S705 = false;
    }
    if(_S705)
    {
        return sample_0;
    }
    uint4  _S708 = (fcptLightNode((n_8)));
    FKHit _S709 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    bool _S710 = (_S708.x) == 2U;
    float3  emitter_point_0;
    float3  lift_n_0;
    float3  shadow_1;
    FKHit emitter_0;
    if(_S710)
    {
        FKLight _S711 = (fcptLight((_S708.y)));
        if(sided_0)
        {
            float _S712 = sign_0(dot_0(geometry_n_1, _S711.position - origin_4));
            float3  lift_n_1 = smooth_n_2 * make_float3 (_S712);
            float3  _S713 = origin_4 + make_float3 (geometry_offset_1) * lift_n_1;
            emitter_point_0 = _S713;
            lift_n_0 = lift_n_1;
        }
        else
        {
            emitter_point_0 = _S694;
            lift_n_0 = smooth_n_2;
        }
        bool _S714 = (_S711.variance) == 0.0f;
        if(_S714)
        {
            float3  _S715 = _S711.position - emitter_point_0;
            float3  _S716 = ((((_S715)) * make_float3(rnorm3df(((_S715)).x, ((_S715)).y, ((_S715)).z))));
            (&sample_0)->dir = _S716;
            float3  _S717 = _S711.color * make_float3 (_S711.intensity) / make_float3 (dot_0(_S715, _S715) * probability_4);
            (&sample_0)->radiance = _S717;
            shadow_1 = _S715;
        }
        else
        {
            float3  _S718 = sampleSphere(_S711.position, _S711.variance, emitter_point_0, _S689.value, _S690.value);
            (&sample_0)->dir = _S718;
            float _S719 = sphereDensity(_S711.position, _S711.variance, emitter_point_0);
            float _S720 = probability_4 * _S719;
            (&sample_0)->density = _S720;
            float3  _S721 = pointLightRadiance(_S711.color, _S711.intensity, _S711.variance);
            float3  _S722 = _S721 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S722;
            FKRay _S723 = Ray_x24init_0(emitter_point_0, (&sample_0)->dir);
            float _S724 = raySphere_0(_S711.position, _S711.variance, &_S723, 4.294967296e+09f);
            float3  _S725 = (&sample_0)->dir * make_float3 (_S724);
            shadow_1 = _S725;
        }
        emitter_0 = _S709;
        emitter_point_0 = _S691;
    }
    else
    {
        uint _S726 = _S708.y;
        uint _S727 = (fcptTriangleOffset((_S726)));
        uint _S728 = _S727 + _S708.z;
        Matrix<float, 3, 3>  _S729 = (fcptWorldTriangle((_S726), (_S728)));
        float _S730 = (F32_sqrt((_S689.value)));
        float2  _S731 = make_float2 (_S730 * (1.0f - _S690.value), _S730 * _S690.value);
        float3  _S732 = mul_0(make_float3 (1.0f - _S730, _S731.x, _S731.y), _S729);
        if(sided_0)
        {
            float _S733 = sign_0(dot_0(geometry_n_1, _S732 - origin_4));
            float3  lift_n_2 = smooth_n_2 * make_float3 (_S733);
            float3  _S734 = origin_4 + make_float3 (geometry_offset_1) * lift_n_2;
            emitter_point_0 = _S734;
            lift_n_0 = lift_n_2;
        }
        else
        {
            bool _S735 = !((dot_0(smooth_n_2, _S732 - origin_4)) > 0.0f);
            if(_S735)
            {
                return sample_0;
            }
            emitter_point_0 = _S694;
            lift_n_0 = smooth_n_2;
        }
        FKHit emitter_1 = Hit_x24init_0(_S731, _S726, _S728, 0U, 0.0f);
        float3  _S736 = _S732 - emitter_point_0;
        float3  _S737 = ((((_S736)) * make_float3(rnorm3df(((_S736)).x, ((_S736)).y, ((_S736)).z))));
        (&sample_0)->dir = _S737;
        float _S738 = solidAngle(probability_4, cross_0(_S729.rows[int(1)] - _S729.rows[int(0)], _S729.rows[int(2)] - _S729.rows[int(0)]), _S736);
        (&sample_0)->density = _S738;
        bool _S739 = (fcptShadowFirst());
        bool _S740 = !_S739;
        if(_S740)
        {
            FKSurface _S741 = (fcptLightSurfaceAt((emitter_1), (_S732), (_S690.state), ((&sample_0)->dir), (context_3->depth), (length_0(_S732 - origin_4))));
            (&sample_0)->random_state = _S741.random_state;
            float3  _S742 = _slang_select(_S741.skip, _S691,_S741.material.emissive);
            float3  _S743 = _S742 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S743;
        }
        shadow_1 = _S736;
        emitter_0 = emitter_1;
        emitter_point_0 = _S732;
    }
    FKHit _S744 = emitter_0;
    float3  _S745 = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, context_3, _S690.state, &_S744);
    bool _S746 = (fcptShadowFirst());
    if(_S746)
    {
        _S705 = (emitter_0.instance_index) != 4294967295U;
    }
    else
    {
        _S705 = false;
    }
    if(_S705)
    {
        _S705 = !all_1(_S745 == _S691);
    }
    else
    {
        _S705 = false;
    }
    if(_S705)
    {
        FKSurface _S747 = (fcptLightSurfaceAt((emitter_0), (emitter_point_0), (_S690.state), ((&sample_0)->dir), (context_3->depth), (length_0(emitter_point_0 - origin_4))));
        (&sample_0)->random_state = _S747.random_state;
        float3  _S748 = _slang_select(_S747.skip, _S691,_S747.material.emissive);
        float3  _S749 = _S748 / make_float3 ((&sample_0)->density);
        (&sample_0)->radiance = _S749;
    }
    float3  _S750 = (&sample_0)->radiance * _S745;
    bool _S751 = all_1(_S745 == _S691);
    float3  _S752 = _slang_select(_S751, _S691,_S750);
    (&sample_0)->radiance = _S752;
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
    float _S753 = 1.0f / (1.0f + b_1 / a_5 * (b_1 / a_5));
    bool _S754 = b_1 > 0.0f;
    float _S755 = _slang_select(_S754, _S753,1.0f);
    return _S755;
}

static __device__ float emissionWeight_0(NEEVertex * vertex_0, FKHit * hit_1, float3  light_point_1)
{
    bool _S756 = vertex_0->none;
    if(_S756)
    {
        return 1.0f;
    }
    uint _S757 = (fcptLightSlot((*hit_1)));
    float _S758 = lightPdf_0(vertex_0->origin, vertex_0->smooth_n, vertex_0->start, _S757, light_point_1);
    float _S759 = powerHeuristic(vertex_0->pdf, _S758);
    return _S759;
}

static __device__ float3  environment_0(float3  dir_7, uint depth_0, uint lobe_0)
{
    uint2  _S760 = (fcptEnvironmentMapSize());
    bool _S761 = (_S760.x) > 1U;
    bool _S762;
    if(_S761)
    {
        uint2  _S763 = (fcptEnvironmentMapSize());
        _S762 = (_S763.y) > 1U;
    }
    else
    {
        _S762 = false;
    }
    if(_S762)
    {
        float3  _S764 = (fcptEnvMapSample((dir_7), (depth_0), (lobe_0)));
        return _S764;
    }
    float3  _S765 = (fcptAmbient());
    return _S765;
}

static __device__ bool environmentMapped_0()
{
    uint2  _S766 = (fcptEnvironmentCdfSize());
    bool _S767 = (_S766.x) > 1U;
    bool _S768;
    if(_S767)
    {
        uint2  _S769 = (fcptEnvironmentCdfSize());
        _S768 = (_S769.y) > 1U;
    }
    else
    {
        _S768 = false;
    }
    bool _S770 = !_S768;
    if(_S770)
    {
        return false;
    }
    uint2  _S771 = (fcptEnvironmentMapSize());
    bool _S772 = (_S771.x) > 1U;
    if(_S772)
    {
        uint2  _S773 = (fcptEnvironmentMapSize());
        _S768 = (_S773.y) > 1U;
    }
    else
    {
        _S768 = false;
    }
    return _S768;
}

static __device__ float escapeWeight_0(float pdf_2, float3  dir_8)
{
    bool _S774 = pdf_2 <= 0.0f;
    bool _S775;
    if(_S774)
    {
        _S775 = true;
    }
    else
    {
        bool _S776 = environmentMapped_0();
        _S775 = !_S776;
    }
    if(_S775)
    {
        return 1.0f;
    }
    float _S777 = environmentPdf_0(dir_8);
    return pdf_2 / (pdf_2 + _S777);
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
    uint2  _S778 = uint2 {global_invocation_id_1.x, global_invocation_id_1.y};
    int2  _S779 = make_int2 ((int)_S778.x, (int)_S778.y);
    uint _S780 = previousSeed_0(_S779);
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
            uint _S781 = previousSeed_0(_S779 + make_int2 (x_16, y_5));
            bool _S782 = _S781 == _S780;
            uint _S783 = _slang_select(_S782, 1U,0U);
            uint count_3 = count_2 + _S783;
            int x_17 = x_16 + int(1);
            x_16 = x_17;
            count_2 = count_3;
        }
        int y_6 = y_5 + int(1);
        y_5 = y_6;
    }
    float _S784 = float(count_2 - 1U) / 288.0f;
    bool _S785 = _S780 != 0U;
    float _S786 = _slang_select(_S785, _S784,0.0f);
    fcptStoreDuplication((_S779), (make_uint4 ((F32_asuint((_S786))), 0U, 0U, 0U)));
    return;
}

__device__ uint stream(uint seed_3, uint index_0)
{
    uint _S787 = hash(index_0);
    uint _S788 = hash(seed_3 ^ _S787);
    return _S788;
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
    float _S789 = rgb_to_greyscale(weight_0);
    bool _S790 = _S789 > 0.0f;
    bool _S791;
    if(_S790)
    {
        _S791 = _S789 < 3.00000000549775576e+38f;
    }
    else
    {
        _S791 = false;
    }
    bool _S792 = !_S791;
    if(_S792)
    {
        return;
    }
    bool _S793 = sel_2->sums;
    if(_S793)
    {
        float3  _S794 = sel_2->color + weight_0;
        sel_2->color = _S794;
        return;
    }
    float _S795 = sel_2->w_sum + _S789;
    sel_2->w_sum = _S795;
    float3  _S796 = sel_2->color + weight_0;
    sel_2->color = _S796;
    Random _S797 = pcg(sel_2->random_state);
    sel_2->random_state = _S797.state;
    bool _S798 = (_S797.value * sel_2->w_sum) <= _S789;
    if(_S798)
    {
        sel_2->r = candidate_0;
    }
    return;
}

__device__ void offerShifted(Selection * sel_3, Reservoir r_3, Shift shifted_0, float mis_0)
{
    Reservoir candidate_1 = r_3;
    float3  _S799 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_1)->f = _S799;
    float _S800 = r_3.jac * shifted_0.jac;
    (&candidate_1)->jac = _S800;
    offer(sel_3, candidate_1, make_float3 (mis_0) * shifted_0.f * make_float3 (r_3.w));
    return;
}

__device__ Reservoir finalize(Selection sel_4, float c_1)
{
    Reservoir r_4 = sel_4.r;
    float _S801 = rgb_to_greyscale((&r_4)->f);
    float _S802 = sel_4.w_sum / _S801;
    bool _S803 = _S801 > 0.0f;
    float _S804 = _slang_select(_S803, _S802,0.0f);
    (&r_4)->w = _S804;
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
    uint2  _S805 = uint2 {global_invocation_id_2.x, global_invocation_id_2.y};
    int2  _S806 = make_int2 ((int)_S805.x, (int)_S805.y);
    float3  _S807 = make_float3 (0.0f);
    FKHit _S808 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S809 = Domain_x24init_0(_S807, _S807, &_S808, 0.0f, 0.0f);
    Domain dom_4 = _S809;
    bool _S810 = (fcptCurrentDomain((_S806), (&dom_4)));
    bool _S811 = !_S810;
    if(_S811)
    {
        Reservoir _S812 = (Reservoir{});
        fcptStoreReservoirPrevious((_S806), (_S812), ((&dom_4)->hit));
        return;
    }
    Reservoir _S813 = (fcptLoadReservoirTemporal((_S806)));
    uint t_12 = 0U;
    float count_4 = 0.0f;
    float c_sum_0 = _S813.c;
    for(;;)
    {
        uint _S814 = (fcptRestirNeighbours());
        if(t_12 < _S814)
        {
        }
        else
        {
            break;
        }
        int2  _S815 = partner_0(_S806, t_12);
        Domain neighbor_0 = _S809;
        bool _S816 = (fcptCurrentDomain((_S815), (&neighbor_0)));
        if(_S816)
        {
            float count_5 = count_4 + 1.0f;
            uint4  _S817 = (fcptReservoirTemporal((_S815), (0U)));
            float c_sum_1 = c_sum_0 + (U32_asfloat((_S817.w)));
            count_4 = count_5;
            c_sum_0 = c_sum_1;
        }
        uint t_13 = t_12 + 1U;
        t_12 = t_13;
    }
    float _S818 = _S813.c / (F32_max((count_4), (1.0f)));
    float _S819 = rgb_to_greyscale(_S813.f);
    bool _S820 = count_4 == 0.0f;
    float _S821 = _slang_select(_S820, 1.0f,0.0f);
    Selection _S822 = (Selection{});
    Selection sel_5 = _S822;
    uint _S823 = (fcptFrame());
    uint _S824 = hash(_S823);
    uint _S825 = global_invocation_id_2.x;
    uint2  _S826 = (fcptRenderSize());
    uint _S827 = stream(_S824, _S825 + _S826.x * global_invocation_id_2.y);
    uint _S828 = stream(_S827, 195U);
    (&sel_5)->random_state = _S828;
    t_12 = 0U;
    float canonical_mis_0 = _S821;
    for(;;)
    {
        uint _S829 = (fcptRestirNeighbours());
        if(t_12 < _S829)
        {
        }
        else
        {
            break;
        }
        int2  _S830 = partner_0(_S806, t_12);
        Domain neighbor_dom_0 = _S809;
        bool _S831 = (fcptCurrentDomain((_S830), (&neighbor_dom_0)));
        if(_S831)
        {
            Reservoir _S832 = (fcptLoadReservoirTemporal((_S830)));
            uint4  _S833 = (fcptShiftData((_S830), (t_12)));
            float4  _S834 = asfloat_0(_S833);
            uint4  _S835 = (fcptShiftData((_S806), (t_12)));
            float4  _S836 = asfloat_0(_S835);
            float _S837 = (_S832.c + _S818) / c_sum_0;
            bool _S838 = _S819 > 0.0f;
            float canonical_mis_1;
            if(_S838)
            {
                float _S839 = _S837 * _S818 * _S819;
                float _S840 = _S818 * _S819;
                float _S841 = rgb_to_greyscale(float3 {_S836.x, _S836.y, _S836.z});
                float canonical_mis_2 = canonical_mis_0 + _S839 / (_S840 + _S832.c * _S841);
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            float _S842 = rgb_to_greyscale(_S832.f);
            float3  _S843 = float3 {_S834.x, _S834.y, _S834.z};
            Shift _S844 = Shift_x24init_0(_S843, _S834.w);
            float _S845 = _S837 * _S832.c * _S842;
            float _S846 = _S832.c * _S842;
            float _S847 = rgb_to_greyscale(_S843);
            offerShifted(&sel_5, _S832, _S844, _S845 / (_S846 + _S818 * _S847));
            canonical_mis_0 = canonical_mis_1;
        }
        uint t_14 = t_12 + 1U;
        t_12 = t_14;
    }
    offerShifted(&sel_5, _S813, Shift_x24init_0(_S813.f, 1.0f), canonical_mis_0);
    Reservoir _S848 = finalize(sel_5, c_sum_0);
    fcptStoreReservoirPrevious((_S806), (_S848), ((&dom_4)->hit));
    fcptStorePreviousLayer((_S806), (5U), (make_uint4 (asuint_0((&(&dom_4)->hit)->uv).x, asuint_0((&(&dom_4)->hit)->uv).y, 0U, 0U)));
    fcptAddColor((_S806), (make_float4 ((&sel_5)->color.x, (&sel_5)->color.y, (&sel_5)->color.z, 0.0f)));
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
    uint _S849 = queuedShift_0(workgroup_id_1, local_invocation_index_4);
    bool _S850 = _S849 != 4294967295U;
    if(_S850)
    {
        uint2  _S851 = make_uint2 (_S849, _S849 >> 14U) & make_uint2 (16383U);
        int2  _S852 = make_int2 ((int)_S851.x, (int)_S851.y);
        ShiftJob _S853 = (ShiftJob{});
        ShiftJob shift_job_0 = _S853;
        Shift _S854 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
        uint _S855 = _S849 >> 28U;
        bool _S856 = spatialJob_0(_S852, _S855, &shift_job_0, true);
        Shift shifted_1;
        if(_S856)
        {
            Domain _S857 = (&shift_job_0)->dom;
            Reservoir _S858 = (&shift_job_0)->r;
            Shift _S859 = passShift_0(&_S857, &_S858);
            shifted_1 = _S859;
        }
        else
        {
            shifted_1 = _S854;
        }
        fcptStoreShiftData((_S852), (_S855), (make_uint4 (asuint_1(shifted_1.f).x, asuint_1(shifted_1.f).y, asuint_1(shifted_1.f).z, (F32_asuint((shifted_1.jac))))));
    }
    return;
}

static __device__ void restir_prepass_0(uint3  global_invocation_id_3, uint local_invocation_index_5)
{
    uint2  _S860 = uint2 {global_invocation_id_3.x, global_invocation_id_3.y};
    int2  _S861 = make_int2 ((int)_S860.x, (int)_S860.y);
    FixedArray<uint, 3>  _S862;
    spatialBins_0(_S861, &_S862);
    FixedArray<uint, 3>  _S863 = _S862;
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
        bool _S864 = (_S863[t_15]) == 40U;
        if(_S864)
        {
            fcptStoreShiftData((_S861), (t_15), (make_uint4 (0U)));
        }
        uint t_16 = t_15 + 1U;
        t_15 = t_16;
    }
    FixedArray<uint, 3>  _S865 = _S863;
    queueShifts_0(_S861, &_S865, global_invocation_id_3, local_invocation_index_5);
    return;
}

static __device__ void restir_count_0(uint3  global_invocation_id_4, uint local_invocation_index_6)
{
    uint2  _S866 = uint2 {global_invocation_id_4.x, global_invocation_id_4.y};
    int2  _S867 = make_int2 ((int)_S866.x, (int)_S866.y);
    FixedArray<uint, 3>  _S868;
    spatialBins_0(_S867, &_S868);
    FixedArray<uint, 3>  _S869 = _S868;
    countShifts_0(&_S869, local_invocation_index_6);
    return;
}

static __device__ void restir_temporal_shift_0(uint3  workgroup_id_2, uint local_invocation_index_7)
{
    uint _S870 = queuedShift_0(workgroup_id_2, local_invocation_index_7);
    bool _S871 = _S870 != 4294967295U;
    if(_S871)
    {
        uint2  _S872 = make_uint2 (_S870, _S870 >> 14U) & make_uint2 (16383U);
        int2  _S873 = make_int2 ((int)_S872.x, (int)_S872.y);
        ShiftJob _S874 = (ShiftJob{});
        ShiftJob shift_job_1 = _S874;
        Shift _S875 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
        uint _S876 = _S870 >> 28U;
        bool _S877 = temporalJob_0(_S873, _S876, &shift_job_1, true);
        Shift shifted_2;
        if(_S877)
        {
            if(_S876 == 1U)
            {
                Shift _S878 = (fcptShiftPrevious(((&shift_job_1)->dom), ((&shift_job_1)->r)));
                shifted_2 = _S878;
            }
            else
            {
                Domain _S879 = (&shift_job_1)->dom;
                Reservoir _S880 = (&shift_job_1)->r;
                Shift _S881 = passShift_0(&_S879, &_S880);
                shifted_2 = _S881;
            }
        }
        else
        {
            shifted_2 = _S875;
        }
        fcptStoreTemporalShift((_S873), (_S876), (make_uint4 (asuint_1(shifted_2.f).x, asuint_1(shifted_2.f).y, asuint_1(shifted_2.f).z, (F32_asuint((shifted_2.jac))))));
    }
    return;
}

static __device__ void restir_temporal_prepass_0(uint3  global_invocation_id_5, uint local_invocation_index_8)
{
    uint2  _S882 = uint2 {global_invocation_id_5.x, global_invocation_id_5.y};
    int2  _S883 = make_int2 ((int)_S882.x, (int)_S882.y);
    FixedArray<uint, 3>  _S884;
    temporalBins_0(_S883, &_S884);
    FixedArray<uint, 3>  _S885 = _S884;
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
        bool _S886 = (_S885[t_17]) == 40U;
        if(_S886)
        {
            fcptStoreTemporalShift((_S883), (t_17), (make_uint4 (0U)));
        }
        uint t_18 = t_17 + 1U;
        t_17 = t_18;
    }
    FixedArray<uint, 3>  _S887 = _S885;
    queueShifts_0(_S883, &_S887, global_invocation_id_5, local_invocation_index_8);
    return;
}

static __device__ void restir_temporal_count_0(uint3  global_invocation_id_6, uint local_invocation_index_9)
{
    uint2  _S888 = uint2 {global_invocation_id_6.x, global_invocation_id_6.y};
    int2  _S889 = make_int2 ((int)_S888.x, (int)_S888.y);
    bool _S890 = (fcptSceneUnchanged());
    bool _S891 = !_S890;
    bool _S892;
    if(_S891)
    {
        uint2  _S893 = (fcptRenderSize());
        int2  _S894 = make_int2 ((int)_S893.x, (int)_S893.y);
        _S892 = all_0(_S889 < _S894);
    }
    else
    {
        _S892 = false;
    }
    if(_S892)
    {
        Reservoir _S895 = (fcptLoadReservoirInitial((_S889)));
        int2  _S896 = sampleNeighbor_0(_S889, _S895.seed);
        fcptStoreTemporalNeighbor((_S889), (_S896));
    }
    FixedArray<uint, 3>  _S897;
    temporalBins_0(_S889, &_S897);
    FixedArray<uint, 3>  _S898 = _S897;
    countShifts_0(&_S898, local_invocation_index_9);
    return;
}

static __device__ float interpolate_0(float a_6, float b_2, float t_19)
{
    return a_6 + (b_2 - a_6) * t_19;
}

static __device__ void restir_temporal_0(uint3  global_invocation_id_7)
{
    uint2  _S899 = uint2 {global_invocation_id_7.x, global_invocation_id_7.y};
    int2  _S900 = make_int2 ((int)_S899.x, (int)_S899.y);
    float3  _S901 = make_float3 (0.0f);
    FKHit _S902 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S903 = Domain_x24init_0(_S901, _S901, &_S902, 0.0f, 0.0f);
    Domain dom_5 = _S903;
    bool _S904 = (fcptCurrentDomain((_S900), (&dom_5)));
    bool _S905 = !_S904;
    if(_S905)
    {
        Reservoir _S906 = (Reservoir{});
        fcptStoreReservoirTemporal((_S900), (_S906), ((&dom_5)->hit));
        return;
    }
    Reservoir _S907 = (fcptLoadReservoirInitial((_S900)));
    bool _S908 = (fcptSceneUnchanged());
    int2  _S909;
    if(_S908)
    {
        int2  _S910 = sampleNeighbor_0(_S900, _S907.seed);
        _S909 = _S910;
    }
    else
    {
        int2  _S911 = (fcptLoadTemporalNeighbor((_S900)));
        _S909 = _S911;
    }
    bool _S912 = (_S909.x) >= int(0);
    Reservoir r_5;
    if(_S912)
    {
        Reservoir _S913 = (fcptLoadReservoirPrevious((_S909)));
        uint4  _S914 = (fcptDuplication((_S909)));
        float _S915 = (U32_asfloat((_S914.x)));
        uint _S916 = (fcptRestirDecorrelation());
        bool _S917 = _S916 == 1U;
        float _S918 = _slang_select(_S917, _S915,0.0f);
        float _S919 = interpolate_0(20.0f, 1.0f, (F32_pow((_S918), (0.10000000149011612f))));
        float _S920 = (F32_min((_S913.c), (_S919)));
        bool _S921 = (fcptSceneUnchanged());
        float4  _S922;
        if(_S921)
        {
            _S922 = make_float4 (_S913.f.x, _S913.f.y, _S913.f.z, 1.0f);
        }
        else
        {
            uint4  _S923 = (fcptTemporalShift((_S900), (0U)));
            _S922 = asfloat_0(_S923);
        }
        Domain own_1 = _S903;
        bool _S924;
        if(_S921)
        {
            _S924 = true;
        }
        else
        {
            bool _S925 = (fcptPreviousScenes());
            bool _S926 = !_S925;
            if(_S926)
            {
                _S924 = (_S907.w) > 0.0f;
            }
            else
            {
                _S924 = false;
            }
            if(_S924)
            {
                bool _S927 = (fcptStoredDomainInitial((_S900), (_S907.seed), (&own_1)));
                _S924 = _S927;
            }
            else
            {
                _S924 = false;
            }
            if(_S924)
            {
                Domain _S928 = (fcptPreviousDomain((_S909), (_S907.seed)));
                Domain _S929 = _S928;
                Domain _S930 = own_1;
                bool _S931 = sameDomain_0(&_S929, &_S930);
                _S924 = _S931;
            }
            else
            {
                _S924 = false;
            }
        }
        float4  _S932;
        if(_S924)
        {
            _S932 = make_float4 (_S907.f.x, _S907.f.y, _S907.f.z, 1.0f);
        }
        else
        {
            uint4  _S933 = (fcptTemporalShift((_S900), (1U)));
            _S932 = asfloat_0(_S933);
        }
        float _S934 = rgb_to_greyscale(_S907.f);
        float _S935 = rgb_to_greyscale(_S913.f);
        Selection _S936 = (Selection{});
        Selection sel_6 = _S936;
        uint _S937 = (fcptFrame());
        uint _S938 = hash(_S937);
        uint _S939 = global_invocation_id_7.x;
        uint2  _S940 = (fcptRenderSize());
        uint _S941 = stream(_S938, _S939 + _S940.x * global_invocation_id_7.y);
        uint _S942 = stream(_S941, 194U);
        (&sel_6)->random_state = _S942;
        float _S943 = _S907.c * _S934;
        float4  _S944 = _S932;
        float _S945 = rgb_to_greyscale(float3 {_S944.x, _S944.y, _S944.z});
        float _S946 = _S943 / (_S943 + _S920 * _S945);
        float _S947 = _S920 * _S935;
        float4  _S948 = _S922;
        float3  _S949 = float3 {_S948.x, _S948.y, _S948.z};
        float _S950 = rgb_to_greyscale(_S949);
        float _S951 = _S947 / (_S947 + _S907.c * _S950);
        float2  _S952 = make_float2 (_S946, _S951);
        offerShifted(&sel_6, _S907, Shift_x24init_0(_S907.f, 1.0f), _S946);
        offerShifted(&sel_6, _S913, Shift_x24init_0(_S949, _S922.w), _S951);
        Reservoir _S953 = finalize(sel_6, _S907.c + _S920);
        r_5 = _S953;
    }
    else
    {
        r_5 = _S907;
    }
    fcptStoreReservoirTemporal((_S900), (r_5), ((&dom_5)->hit));
    return;
}

static __device__ void restir_initial_0(uint3  global_invocation_id_8)
{
    uint2  _S954 = uint2 {global_invocation_id_8.x, global_invocation_id_8.y};
    int2  _S955 = make_int2 ((int)_S954.x, (int)_S954.y);
    float3  _S956 = make_float3 (0.0f);
    float2  _S957 = make_float2 (0.0f);
    FKHit _S958 = Hit_x24init_0(_S957, 0U, 0U, 0U, 0.0f);
    Domain _S959 = Domain_x24init_0(_S956, _S956, &_S958, 0.0f, 0.0f);
    Domain dom_6 = _S959;
    bool _S960 = (fcptCurrentDomain((_S955), (&dom_6)));
    bool _S961 = !_S960;
    if(_S961)
    {
        Reservoir _S962 = (Reservoir{});
        fcptStoreReservoirInitial((_S955), (_S962), ((&dom_6)->hit));
        return;
    }
    uint _S963 = (fcptFrame());
    uint _S964 = hash(_S963);
    uint _S965 = global_invocation_id_8.x;
    uint2  _S966 = (fcptRenderSize());
    uint _S967 = stream(_S964, _S965 + _S966.x * global_invocation_id_8.y);
    Selection _S968 = (Selection{});
    Selection initial_0 = _S968;
    uint _S969 = stream(_S967, 193U);
    (&initial_0)->random_state = _S969;
    bool _S970 = (fcptRestirUsed());
    bool _S971 = !_S970;
    (&initial_0)->sums = _S971;
    uint _S972 = stream(_S967, 0U);
    (&(&initial_0)->r)->seed = _S972;
    FKHit _S973 = Hit_x24init_0(_S957, 4294967295U, 0U, 0U, 0.0f);
    uint _S974 = (fcptSamples());
    float _S975 = 1.0f / float(_S974);
    FKHit hit_2 = _S973;
    uint i_17 = 0U;
    for(;;)
    {
        uint _S976 = (fcptSamples());
        if(i_17 < _S976)
        {
        }
        else
        {
            break;
        }
        Reservoir _S977 = (Reservoir{});
        Reservoir r_6 = _S977;
        uint _S978 = stream(_S967, i_17);
        (&r_6)->seed = _S978;
        Domain path_0 = _S959;
        bool _S979 = (fcptStoredDomainInitial((_S955), ((&r_6)->seed), (&path_0)));
        bool _S980 = !_S979;
        if(_S980)
        {
            fcptMissed((_S955), (path_0), (_S975));
            uint i_18 = i_17 + 1U;
            i_17 = i_18;
            continue;
        }
        Domain _S981 = path_0;
        Reservoir _S982 = r_6;
        Shift _S983 = passWalk_0(&_S981, &_S982, false, _S975, &initial_0);
        bool _S984 = ((&(&initial_0)->r)->seed) == ((&r_6)->seed);
        FKHit hit_3;
        if(_S984)
        {
            FKHit _S985 = (&path_0)->hit;
            hit_3 = _S985;
        }
        else
        {
            hit_3 = hit_2;
        }
        hit_2 = hit_3;
        uint i_18 = i_17 + 1U;
        i_17 = i_18;
    }
    float3  _S986 = (&initial_0)->glow;
    float3  _S987 = (&initial_0)->color;
    bool _S988 = (&initial_0)->sums;
    float3  _S989 = _slang_select(_S988, _S987,_S956);
    fcptAddColor((_S955), (make_float4 ((_S986 + _S989).x, (_S986 + _S989).y, (_S986 + _S989).z, 1.0f)));
    Reservoir _S990 = finalize(initial_0, 1.0f);
    fcptStoreReservoirInitial((_S955), (_S990), (hit_2));
    return;
}

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_3, float3  origin_5, float3  smooth_n_3, float3  start_6)
{
    NEEVertex _S991;
    (&_S991)->none = none_0;
    (&_S991)->pdf = pdf_3;
    (&_S991)->origin = origin_5;
    (&_S991)->smooth_n = smooth_n_3;
    (&_S991)->start = start_6;
    return _S991;
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
    Vertex _S992;
    (&_S992)->rough = rough_0;
    (&_S992)->lobe = lobe_1;
    (&_S992)->pdf = pdf_4;
    (&_S992)->cos = cos_0;
    (&_S992)->inside = inside_0;
    return _S992;
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
    float3  _S993 = exp_0((make_float3 (sigma_0) - extinction_0) * make_float3 (distance_2));
    float3  _S994 = scatter_0 * _S993 / make_float3 (sigma_0);
    float3  _S995 = _slang_select(scatters_0, _S994,_S993);
    return _S995;
}

static __device__ uint arrivalLobe_0(uint b_3, uint prev_lobe_0)
{
    bool _S996 = b_3 > 0U;
    uint _S997 = _slang_select(_S996, prev_lobe_0,3U);
    return _S997;
}

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_0, uint depth_1, uint lobe_2, bool surface_5, float length_2, float width_1, FKHit * own_2, bool fiber_0)
{
    ShadowContext _S998;
    (&_S998)->extinction_behind = extinction_behind_0;
    (&_S998)->extinction_front = extinction_front_0;
    (&_S998)->fillings = fillings_0;
    (&_S998)->side = side_0;
    (&_S998)->depth = depth_1;
    (&_S998)->lobe = lobe_2;
    (&_S998)->surface = surface_5;
    (&_S998)->length = length_2;
    (&_S998)->width = width_1;
    (&_S998)->own = *own_2;
    (&_S998)->fiber = fiber_0;
    return _S998;
}

static __device__ float phaseHG_0(float g_0, float mu_0)
{
    bool _S999 = (F32_abs((g_0))) < 0.00100000004749745f;
    if(_S999)
    {
        return 0.07957746833562851f;
    }
    float _S1000 = g_0 * g_0;
    return (1.0f - _S1000) * 0.25f * 0.31830987334251404f / (F32_pow((1.0f + _S1000 - 2.0f * g_0 * mu_0), (1.5f)));
}

__device__ float3  safeDivide(float3  a_7, float3  b_4)
{
    float3  _S1001 = a_7 / b_4;
    float3  _S1002 = make_float3 (0.0f);
    bool3  _S1003 = b_4 == _S1002;
    float3  _S1004 = _slang_select(_S1003, _S1002,_S1001);
    return _S1004;
}

static __device__ uint insertBits_0(uint e_2, uint newbits_0, uint offset_1, uint count_6)
{
    uint _S1005 = (1U << count_6) - 1U;
    return (e_2 & (~(_S1005 << offset_1))) | ((newbits_0 & _S1005) << offset_1);
}

__device__ Reservoir withEnd(Reservoir r_7, uint end_type_0, uint end_0, float3  f_5)
{
    Reservoir candidate_2 = r_7;
    uint _S1006 = insertBits_0(r_7.path, end_0, 0U, 5U);
    uint _S1007 = insertBits_0(_S1006, end_type_0, 12U, 3U);
    (&candidate_2)->path = _S1007;
    (&candidate_2)->f = f_5;
    return candidate_2;
}

__device__ float survivalProbability(float3  throughput_0, float density_1)
{
    return (F32_min(((F32_max(((F32_max((throughput_0.x), ((F32_max((throughput_0.y), (throughput_0.z)))))) / density_1), (0.0f)))), (1.0f)));
}

static __device__ float3  isotropic_0(uint random_state_9)
{
    Random _S1008 = pcg(random_state_9);
    Random _S1009 = pcg(_S1008.state);
    float _S1010 = 1.0f - 2.0f * _S1008.value;
    float _S1011 = (F32_sqrt(((F32_max((1.0f - _S1010 * _S1010), (0.0f))))));
    float _S1012 = 6.28318548202514648f * _S1009.value;
    return make_float3 (_S1011 * (F32_cos((_S1012))), _S1011 * (F32_sin((_S1012))), _S1010);
}

static __device__ float3  samplePhase_0(float g_1, float3  dir_9, uint random_state_10, float * pdf_5)
{
    bool _S1013 = (F32_abs((g_1))) < 0.00100000004749745f;
    if(_S1013)
    {
        *pdf_5 = 0.07957746833562851f;
        float3  _S1014 = isotropic_0(random_state_10);
        return _S1014;
    }
    Random _S1015 = pcg(random_state_10);
    Random _S1016 = pcg(_S1015.state);
    float _S1017 = g_1 * g_1;
    float _S1018 = 2.0f * g_1;
    float _S1019 = (1.0f - _S1017) / (1.0f - g_1 + _S1018 * _S1015.value);
    float _S1020 = clamp_1((1.0f + _S1017 - _S1019 * _S1019) / _S1018, -1.0f, 1.0f);
    float _S1021 = (F32_sqrt(((F32_max((1.0f - _S1020 * _S1020), (0.0f))))));
    float _S1022 = 6.28318548202514648f * _S1016.value;
    float _S1023 = phaseHG_0(g_1, _S1020);
    *pdf_5 = _S1023;
    float3  _S1024 = tangentToWorld(make_float3 (_S1021 * (F32_cos((_S1022))), _S1020, _S1021 * (F32_sin((_S1022)))), dir_9);
    float3  _S1025 = ((((_S1024)) * make_float3(rnorm3df(((_S1024)).x, ((_S1024)).y, ((_S1024)).z))));
    return _S1025;
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_1, float3  emissive_0, float roughness_0, float metallic_0, float transmission_0, float ior_0, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_2, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_2, float velvet_0, float3  toon_2)
{
    BSDFMaterial _S1026;
    (&_S1026)->albedo = albedo_1;
    (&_S1026)->emissive = emissive_0;
    (&_S1026)->roughness = roughness_0;
    (&_S1026)->metallic = metallic_0;
    (&_S1026)->transmission = transmission_0;
    (&_S1026)->ior = ior_0;
    (&_S1026)->absorption = absorption_0;
    (&_S1026)->specular_tint = specular_tint_0;
    (&_S1026)->specular_level = specular_level_0;
    (&_S1026)->translucent = translucent_0;
    (&_S1026)->sheen = sheen_2;
    (&_S1026)->sheen_roughness = sheen_roughness_0;
    (&_S1026)->anisotropy = anisotropy_0;
    (&_S1026)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S1026)->tangent = tangent_2;
    (&_S1026)->velvet = velvet_0;
    (&_S1026)->toon = toon_2;
    return _S1026;
}

static __device__ FKMedium Medium_x24init_0(float3  scatter_1, float3  extinction_1, float g_2)
{
    FKMedium _S1027;
    (&_S1027)->scatter = scatter_1;
    (&_S1027)->extinction = extinction_1;
    (&_S1027)->g = g_2;
    return _S1027;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_11, bool skip_0, uint random_state_11, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S1028;
    (&_S1028)->smooth_n = smooth_n_4;
    (&_S1028)->geometry_n = geometry_n_2;
    (&_S1028)->geometry_offset = geometry_offset_2;
    (&_S1028)->material = *material_11;
    (&_S1028)->skip = skip_0;
    (&_S1028)->random_state = random_state_11;
    (&_S1028)->coverage = coverage_0;
    (&_S1028)->encloses = encloses_0;
    (&_S1028)->volume = *volume_0;
    (&_S1028)->fills = fills_0;
    (&_S1028)->hair = hair_0;
    return _S1028;
}

static __device__ FKSurface emitting_0(FKSurface * surface_6, bool top_0)
{
    FKSurface lower_0 = *surface_6;
    float3  _S1029 = (&surface_6->material)->emissive;
    float3  _S1030 = make_float3 (0.0f);
    bool _S1031 = !top_0;
    float3  _S1032 = _slang_select(_S1031, _S1030,_S1029);
    (&(&lower_0)->material)->emissive = _S1032;
    return lower_0;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_7, float u_1)
{
    float _S1033 = surface_7->coverage;
    bool _S1034 = u_1 < _S1033;
    if(_S1034)
    {
        return *surface_7;
    }
    float3  _S1035 = make_float3 (0.0f);
    float3  _S1036 = make_float3 (1.0f);
    BSDFMaterial _S1037 = Material_x24init_0(_S1035, _S1035, 0.0f, 0.0f, 0.0f, 0.0f, _S1035, _S1036, 1.0f, _S1035, _S1035, 0.5f, 0.0f, 0.0f, _S1035, 0.0f, _S1035);
    BSDFMaterial material_12 = _S1037;
    (&material_12)->albedo = _S1036;
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
    bool _S1038 = transmission_1 > 0.0f;
    bool _S1039;
    if(_S1038)
    {
        _S1039 = true;
    }
    else
    {
        _S1039 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S1040;
    if(_S1039)
    {
        _S1040 = 1.0f;
    }
    else
    {
        _S1040 = -1.0f;
    }
    return _S1040;
}

static __device__ bool arrivesBehind_0(float3  dir_10, float3  n_9)
{
    return (dot_0(dir_10, n_9)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_8, float3  dir_11)
{
    float3  _S1041 = surface_8->geometry_n;
    float _S1042 = facingSign((&surface_8->material)->transmission, surface_8->geometry_n, dir_11);
    FKSurface faced_0 = *surface_8;
    float3  _S1043 = surface_8->smooth_n * make_float3 (_S1042);
    (&faced_0)->smooth_n = _S1043;
    float3  _S1044 = _S1041 * make_float3 (_S1042);
    (&faced_0)->geometry_n = _S1044;
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
    float3  _S1045 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_3) * log_0(_S1045));
}

__device__ float2  vertexEta(BSDFMaterial material_13, float n_dot_v_0)
{
    bool _S1046 = n_dot_v_0 < 0.0f;
    float _S1047 = _slang_select(_S1046, material_13.ior,1.0f);
    float _S1048 = _slang_select(_S1046, 1.0f,material_13.ior);
    return make_float2 (_S1047, _S1048);
}

__device__ bool neeDecision(BSDFMaterial material_14, float n_dot_v_1, float eta_i_9, float eta_o_9)
{
    float _S1049 = fresnel((F32_abs((n_dot_v_1))), eta_i_9, eta_o_9);
    float3  _S1050 = mix_0(make_float3 (_S1049), material_14.albedo, material_14.metallic);
    float _S1051 = rgb_to_greyscale(_S1050);
    float _S1052 = (F32_max(((1.0f - _S1051) * (1.0f - material_14.metallic) * (1.0f - material_14.transmission)), (0.0f)));
    bool _S1053 = _S1052 > 0.03999999910593033f;
    bool _S1054;
    if(_S1053)
    {
        _S1054 = true;
    }
    else
    {
        _S1054 = (material_14.roughness) > 0.20000000298023224f;
    }
    return _S1054;
}

static __device__ bool isTranslucent_0(BSDFMaterial * material_15)
{
    float _S1055 = rgb_to_greyscale(material_15->translucent);
    return _S1055 > 0.0f;
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
    MediumSides _S1056;
    (&_S1056)->behind = *behind_0;
    (&_S1056)->front = *front_0;
    (&_S1056)->fillings = fillings_1;
    (&_S1056)->face = face_1;
    return _S1056;
}

static __device__ MediumSides mediumSides_0(FKSurface * surface_9, FKMedium * medium_0, uint filling_0, float3  dir_12, FKMedium * outside_0)
{
    float3  _S1057 = surface_9->geometry_n;
    MediumSides _S1058 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_9->geometry_n);
    MediumSides sides_0 = _S1058;
    bool _S1059 = surface_9->encloses;
    if(_S1059)
    {
        (&sides_0)->behind = surface_9->volume;
        *&((&(&sides_0)->fillings)->x) = surface_9->fills;
        bool _S1060 = (dot_0(dir_12, _S1057)) > 0.0f;
        if(_S1060)
        {
            (&sides_0)->front = *outside_0;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_10, bool turned_0, float3  extinction_2, uint filling_1, float3  dir_13, uint depth_2, uint lobe_3, float length_3, float width_2, FKHit * own_3, bool fiber_1, FKMedium * outside_1)
{
    float3  _S1061 = surface_10->geometry_n;
    ShadowContext _S1062 = ShadowContext_x24init_0(extinction_2, extinction_2, make_uint2 (filling_1), surface_10->geometry_n, depth_2, lobe_3, true, length_3, width_2, own_3, fiber_1);
    bool _S1063 = surface_10->encloses;
    ShadowContext context_4;
    if(_S1063)
    {
        FKSurface faced_1 = *surface_10;
        float3  _S1064 = - _S1061;
        float3  _S1065 = _slang_select(turned_0, _S1064,_S1061);
        (&faced_1)->geometry_n = _S1065;
        FKMedium _S1066 = Medium_x24init_0(make_float3 (0.0f), extinction_2, 0.0f);
        FKSurface _S1067 = faced_1;
        FKMedium _S1068 = _S1066;
        MediumSides _S1069 = mediumSides_0(&_S1067, &_S1068, filling_1, dir_13, outside_1);
        ShadowContext _S1070 = ShadowContext_x24init_0(_S1069.behind.extinction, _S1069.front.extinction, _S1069.fillings, _S1061, depth_2, lobe_3, true, length_3, width_2, own_3, fiber_1);
        if(turned_0)
        {
            uint2  _S1071 = _S1069.fillings;
            ShadowContext _S1072 = ShadowContext_x24init_0(_S1069.front.extinction, _S1069.behind.extinction, uint2 {_S1071.y, _S1071.x}, _S1061, depth_2, lobe_3, true, length_3, width_2, own_3, fiber_1);
            context_4 = _S1072;
        }
        else
        {
            context_4 = _S1070;
        }
    }
    else
    {
        context_4 = _S1062;
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
    float3  _S1073 = light_2->dir;
    bool _S1074 = (dot_0(geometry_n_3, - in_dir_8) * dot_0(geometry_n_3, light_2->dir)) <= 0.0f;
    FixedArray<float3 , 5>  throughputs_1;
    FixedArray<float, 5>  pdfs_3;
    float3  _S1075 = BSDF(in_dir_8, _S1073, smooth_n_5, *material_16, eta_i_10, eta_o_10, _S1074, random_state_12, &throughputs_1, &pdfs_3);
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
        return _S1075 * light_2->radiance;
    }
    float3  _S1078 = make_float3 (0.0f);
    uint i_23 = 0U;
    float3  weighted_0 = _S1078;
    for(;;)
    {
        if(i_23 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S1079 = (pdfs_3[i_23]) > 0.0f;
        if(_S1079)
        {
            float _S1080 = light_2->density;
            float _S1081 = pdfs_3[i_23] / light_2->density;
            float3  weighted_1 = weighted_0 + throughputs_1[i_23] * make_float3 (pdfs_3[i_23]) / make_float3 (_S1080 * (1.0f + _S1081 * _S1081));
            weighted_0 = weighted_1;
        }
        uint i_24 = i_23 + 1U;
        i_23 = i_24;
    }
    return weighted_0 * light_2->radiance * make_float3 (light_2->density);
}

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_1, uint random_state_13, bool refracted_3, uint lobe_4, float pdf_6)
{
    SampleBSDF _S1082;
    (&_S1082)->unit_direction = unit_direction_1;
    (&_S1082)->throughput = throughput_1;
    (&_S1082)->random_state = random_state_13;
    (&_S1082)->refracted = refracted_3;
    (&_S1082)->lobe = lobe_4;
    (&_S1082)->pdf = pdf_6;
    return _S1082;
}

__device__ __forceinline__ SampleBSDF sheenVelvetSample(float3  n_i_9, float n_i_dot_v_6, float alpha_15, BSDFMaterial material_17, BSDFLobes lobes_11, float eta_i_11, float eta_o_11, uint random_state_14)
{
    float3  _S1083 = make_float3 (1.0f);
    SampleBSDF _S1084 = SampleBSDF_x24init_0(_S1083, _S1083, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S1084;
    Random _S1085 = pcg(random_state_14);
    Random _S1086 = pcg(_S1085.state);
    (&sample_1)->random_state = _S1086.state;
    float _S1087 = _S1085.value;
    float _S1088 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1087 * _S1087))))));
    float _S1089 = 6.28318548202514648f * _S1086.value;
    float3  _S1090 = tangentToWorld(make_float3 (_S1088 * (F32_cos((_S1089))), _S1085.value, _S1088 * (F32_sin((_S1089)))), n_i_9);
    (&sample_1)->unit_direction = _S1090;
    (&sample_1)->lobe = 4U;
    float3  _S1091 = sheenVelvetBSDF((&sample_1)->unit_direction, n_i_9, alpha_15, material_17, lobes_11);
    (&sample_1)->throughput = _S1091;
    float _S1092 = sheenVelvetPDF(_S1085.value, 0.0f, n_i_dot_v_6, alpha_15, lobes_11, eta_i_11, eta_o_11);
    (&sample_1)->pdf = _S1092;
    return sample_1;
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S1093 = (F32_sqrt((random_1_0)));
    float _S1094 = 6.28318548202514648f * random_2_0;
    float _S1095 = _S1093 * (F32_cos((_S1094)));
    float _S1096 = _S1093 * (F32_sin((_S1094)));
    float _S1097 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1095 * _S1095 - _S1096 * _S1096))))));
    return make_float3 (_S1095, _S1097, _S1096);
}

__device__ __forceinline__ SampleBSDF diffuseSample(float u_2, float3  n_i_10, float n_i_dot_v_7, float alpha_16, BSDFMaterial material_18, BSDFLobes lobes_12, float eta_i_12, float eta_o_12, uint random_state_15)
{
    float3  _S1098 = make_float3 (1.0f);
    SampleBSDF _S1099 = SampleBSDF_x24init_0(_S1098, _S1098, 0U, false, 0U, 0.0f);
    SampleBSDF sample_2 = _S1099;
    Random _S1100 = pcg(random_state_15);
    Random _S1101 = pcg(_S1100.state);
    (&sample_2)->random_state = _S1101.state;
    float3  _S1102 = sampleCosWeightedHemisphere(_S1100.value, _S1101.value);
    bool _S1103 = u_2 < (lobes_12.p_diffuse * lobes_12.translucent_share);
    float _S1104 = _S1102.y;
    float _S1105 = - _S1104;
    float _S1106 = _slang_select(_S1103, _S1105,_S1104);
    float3  _S1107 = tangentToWorld(make_float3 (_S1102.x, _S1106, _S1102.z), n_i_10);
    (&sample_2)->unit_direction = _S1107;
    (&sample_2)->refracted = _S1103;
    (&sample_2)->lobe = 0U;
    float3  _S1108 = diffuseBSDF((&sample_2)->unit_direction, n_i_10, alpha_16, material_18, lobes_12);
    (&sample_2)->throughput = _S1108;
    float _S1109 = diffusePDF(_S1106, 0.0f, n_i_dot_v_7, alpha_16, lobes_12, eta_i_12, eta_o_12);
    (&sample_2)->pdf = _S1109;
    return sample_2;
}

__device__ __forceinline__ SampleBSDF toonSample(float3  n_i_11, float n_i_dot_v_8, float alpha_17, BSDFMaterial material_19, BSDFLobes lobes_13, float eta_i_13, float eta_o_13, uint random_state_16)
{
    float3  _S1110 = make_float3 (1.0f);
    SampleBSDF _S1111 = SampleBSDF_x24init_0(_S1110, _S1110, 0U, false, 0U, 0.0f);
    SampleBSDF sample_3 = _S1111;
    Random _S1112 = pcg(random_state_16);
    Random _S1113 = pcg(_S1112.state);
    (&sample_3)->random_state = _S1113.state;
    float _S1114 = _S1112.value * lobes_13.toon_norm / 6.28318548202514648f;
    float t_20;
    if(lobes_13.toon_glossy)
    {
        t_20 = (F32_acos((clamp_1(1.0f - _S1114, -1.0f, 1.0f))));
    }
    else
    {
        t_20 = (F32_asin(((F32_min(((F32_sqrt((2.0f * _S1114)))), (1.0f))))));
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
        float _S1115;
        if(t_20 < (lobes_13.toon_a))
        {
            _S1115 = 1.0f;
        }
        else
        {
            _S1115 = (F32_max((1.0f - (t_20 - lobes_13.toon_a) / (F32_max((lobes_13.toon_s), (0.0000152587890625f)))), (0.0f)));
        }
        float integral_1;
        if(lobes_13.toon_glossy)
        {
            integral_1 = 1.0f - (F32_cos(((F32_min((t_20), (lobes_13.toon_a))))));
        }
        else
        {
            float _S1116 = (F32_sin(((F32_min((t_20), (lobes_13.toon_a))))));
            integral_1 = _S1116 * _S1116 / 2.0f;
        }
        bool _S1117 = t_20 > (lobes_13.toon_a);
        bool _S1118;
        if(_S1117)
        {
            _S1118 = (lobes_13.toon_s) > 0.0f;
        }
        else
        {
            _S1118 = false;
        }
        float integral_2;
        if(_S1118)
        {
            if(lobes_13.toon_glossy)
            {
                float _S1119 = (F32_cos((lobes_13.toon_a)));
                float _S1120 = (F32_cos((t_20)));
                integral_2 = (1.0f + lobes_13.toon_a / lobes_13.toon_s) * (_S1119 - _S1120) - ((F32_sin((t_20))) - t_20 * _S1120 - ((F32_sin((lobes_13.toon_a))) - lobes_13.toon_a * _S1119)) / lobes_13.toon_s;
            }
            else
            {
                float _S1121 = 2.0f * lobes_13.toon_a;
                float _S1122 = (F32_cos((_S1121)));
                float _S1123 = 2.0f * t_20;
                float _S1124 = (F32_cos((_S1123)));
                integral_2 = (1.0f + lobes_13.toon_a / lobes_13.toon_s) * (_S1122 - _S1124) / 4.0f - ((F32_sin((_S1123))) / 8.0f - t_20 * _S1124 / 4.0f - ((F32_sin((_S1121))) / 8.0f - lobes_13.toon_a * _S1122 / 4.0f)) / lobes_13.toon_s;
            }
            float integral_3 = integral_1 + integral_2;
            integral_2 = integral_3;
        }
        else
        {
            integral_2 = integral_1;
        }
        float _S1125 = _S1115 * (F32_sin((t_20)));
        float _S1126;
        if(lobes_13.toon_glossy)
        {
            _S1126 = 1.0f;
        }
        else
        {
            _S1126 = (F32_cos((t_20)));
        }
        float _S1127 = _S1125 * _S1126;
        float _S1128 = (integral_2 - _S1114) / _S1127;
        bool _S1129 = _S1127 > 0.0f;
        float _S1130 = _slang_select(_S1129, _S1128,0.0f);
        float _S1131 = clamp_1(t_20 - _S1130, 0.0f, lobes_13.toon_b);
        int k_1 = k_0 + int(1);
        t_20 = _S1131;
        k_0 = k_1;
    }
    float _S1132 = 6.28318548202514648f * _S1113.value;
    float _S1133 = (F32_sin((t_20)));
    float3  _S1134 = tangentToWorld(make_float3 (_S1133 * (F32_cos((_S1132))), (F32_cos((t_20))), _S1133 * (F32_sin((_S1132)))), lobes_13.toon_axis);
    (&sample_3)->unit_direction = _S1134;
    bool _S1135 = (dot_0(n_i_11, (&sample_3)->unit_direction)) < 0.0f;
    (&sample_3)->refracted = _S1135;
    (&sample_3)->lobe = 6U;
    float3  _S1136 = toonBSDF((&sample_3)->unit_direction, n_i_11, alpha_17, material_19, lobes_13);
    (&sample_3)->throughput = _S1136;
    float _S1137 = toonPDF(dot_0(n_i_11, (&sample_3)->unit_direction), dot_0((&sample_3)->unit_direction, lobes_13.toon_axis), n_i_dot_v_8, alpha_17, lobes_13, eta_i_13, eta_o_13);
    (&sample_3)->pdf = _S1137;
    return sample_3;
}

__device__ __forceinline__ SampleBSDF refractSample(float3  ggx_n_3, float3  n_i_12, float n_i_dot_v_9, float alpha_18, BSDFMaterial material_20, BSDFLobes lobes_14, float eta_i_14, float eta_o_14, uint random_state_17)
{
    float3  _S1138 = make_float3 (1.0f);
    SampleBSDF _S1139 = SampleBSDF_x24init_0(_S1138, _S1138, 0U, false, 0U, 0.0f);
    SampleBSDF sample_4 = _S1139;
    (&sample_4)->unit_direction = lobes_14.refracted;
    (&sample_4)->random_state = random_state_17;
    (&sample_4)->refracted = true;
    (&sample_4)->lobe = 1U;
    float3  _S1140 = refractBSDF((&sample_4)->unit_direction, n_i_12, alpha_18, material_20, lobes_14);
    (&sample_4)->throughput = _S1140;
    float _S1141 = refractPDF(0.0f, dot_0((&sample_4)->unit_direction, ggx_n_3), n_i_dot_v_9, alpha_18, lobes_14, eta_i_14, eta_o_14);
    (&sample_4)->pdf = _S1141;
    return sample_4;
}

static __device__ float3  reflect_0(float3  i_25, float3  n_10)
{
    return i_25 - make_float3 (2.0f * dot_0(n_10, i_25)) * n_10;
}

__device__ __forceinline__ SampleBSDF reflectSample(float3  in_dir_9, float3  ggx_n_4, float3  n_i_13, float n_i_dot_v_10, float alpha_19, BSDFMaterial material_21, BSDFLobes lobes_15, float eta_i_15, float eta_o_15, uint random_state_18)
{
    float3  _S1142 = make_float3 (1.0f);
    SampleBSDF _S1143 = SampleBSDF_x24init_0(_S1142, _S1142, 0U, false, 0U, 0.0f);
    SampleBSDF sample_5 = _S1143;
    float3  _S1144 = reflect_0(in_dir_9, ggx_n_4);
    float3  _S1145 = ((((_S1144)) * make_float3(rnorm3df(((_S1144)).x, ((_S1144)).y, ((_S1144)).z))));
    (&sample_5)->unit_direction = _S1145;
    (&sample_5)->random_state = random_state_18;
    (&sample_5)->lobe = 2U;
    float3  _S1146 = reflectBSDF((&sample_5)->unit_direction, n_i_13, alpha_19, material_21, lobes_15);
    (&sample_5)->throughput = _S1146;
    float _S1147 = reflectPDF(0.0f, 0.0f, n_i_dot_v_10, alpha_19, lobes_15, eta_i_15, eta_o_15);
    (&sample_5)->pdf = _S1147;
    return sample_5;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_10, float3  n_11, BSDFMaterial material_22, float eta_i_16, float eta_o_16, uint random_init_0, float2  screen_space_0)
{
    uint random_state_19 = random_init_0;
    float3  _S1148 = negate_0(in_dir_10);
    float _S1149 = dot_0(n_11, _S1148);
    float _S1150 = sign_0(_S1149);
    float3  n_i_14 = n_11 * make_float3 (_S1150);
    float _S1151 = (F32_abs((_S1149)));
    float _S1152 = material_22.roughness;
    float _S1153 = _S1152 * _S1152;
    AnisotropicFrame _S1154 = anisotropicFrame(material_22, n_i_14);
    SheenProfile _S1155 = sheenProfile(_S1148, n_i_14, material_22);
    float3  _S1156 = sampleHalfVector(_S1148, n_i_14, _S1153, _S1154, &random_state_19);
    BSDFLobes _S1157 = bsdfLobes(in_dir_10, _S1148, n_i_14, _S1156, material_22, eta_i_16, eta_o_16, _S1154, _S1155);
    BSDFLobes lobes_16 = _S1157;
    float _S1158 = translucentShare(material_22);
    (&lobes_16)->translucent_share = _S1158;
    Random _S1159 = pcg(random_state_19);
    random_state_19 = _S1159.state;
    bool _S1160 = (_S1159.value) < ((&lobes_16)->p_sheen_velvet);
    if(_S1160)
    {
        SampleBSDF _S1161 = sheenVelvetSample(n_i_14, _S1151, _S1153, material_22, lobes_16, eta_i_16, eta_o_16, random_state_19);
        return _S1161;
    }
    float _S1162 = _S1159.value - (&lobes_16)->p_sheen_velvet;
    bool _S1163 = _S1162 < ((&lobes_16)->p_diffuse);
    if(_S1163)
    {
        SampleBSDF _S1164 = diffuseSample(_S1162, n_i_14, _S1151, _S1153, material_22, lobes_16, eta_i_16, eta_o_16, random_state_19);
        return _S1164;
    }
    bool _S1165 = _S1162 < ((&lobes_16)->p_diffuse + (&lobes_16)->p_toon);
    if(_S1165)
    {
        SampleBSDF _S1166 = toonSample(n_i_14, _S1151, _S1153, material_22, lobes_16, eta_i_16, eta_o_16, random_state_19);
        return _S1166;
    }
    float _S1167 = (&lobes_16)->p_toon;
    bool _S1168 = (_S1162 - _S1167) < ((&lobes_16)->p_diffuse + (&lobes_16)->p_refract);
    if(_S1168)
    {
        SampleBSDF _S1169 = refractSample(_S1156, n_i_14, _S1151, _S1153, material_22, lobes_16, eta_i_16, eta_o_16, random_state_19);
        return _S1169;
    }
    SampleBSDF _S1170 = reflectSample(in_dir_10, _S1156, n_i_14, _S1151, _S1153, material_22, lobes_16, eta_i_16, eta_o_16, random_state_19);
    return _S1170;
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
    bool _S1171;
    bool _S1172;
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
    int _S1173;
    Shift ended_0;
    float density_3;
    float spread_2;
    float width_4;
    float sky_pdf_1;
    float spread_3;
    float width_5;
    uint b_6;
    float3  _S1174 = make_float3 (0.0f);
    Shift _S1175 = Shift_x24init_0(_S1174, 0.0f);
    uint _S1176 = r_8->path;
    uint _S1177 = extractBits_0(r_8->path, 0U, 5U);
    uint _S1178 = extractBits_0(_S1176, 5U, 5U);
    uint _S1179 = extractBits_0(_S1176, 10U, 2U);
    uint _S1180 = extractBits_0(_S1176, 12U, 3U);
    bool passes_0;
    if(replay_1)
    {
        bool _S1181 = _S1180 >= 3U;
        uint _S1182 = _slang_select(_S1181, 1U,0U);
        uint _S1183 = _S1177 + _S1182;
        uint _S1184 = (fcptMaxBounces());
        passes_0 = _S1183 > _S1184;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S1175;
    }
    uint _S1185 = _S1178 - 1U;
    bool _S1186 = _S1180 == 3U;
    uint _S1187 = _slang_select(_S1186, 1U,0U);
    uint _S1188 = _S1177 + _S1187;
    bool _S1189 = _S1179 == 0U;
    uint _S1190 = _slang_select(_S1189, _S1188,_S1185);
    FKHit _S1191 = (fcptReservoirHit((*r_8)));
    float3  _S1192 = dom_7->x0;
    float3  _S1193 = dom_7->x1 - dom_7->x0;
    float3  _S1194 = ((((_S1193)) * make_float3(rnorm3df(((_S1193)).x, ((_S1193)).y, ((_S1193)).z))));
    FKRay _S1195 = Ray_x24init_0(dom_7->x1, _S1194);
    FKRay ray_2 = _S1195;
    FKHit hit_4 = dom_7->hit;
    float3  scatter_in_0 = _S1174;
    float3  throughput_3 = make_float3 (1.0f);
    float3  weight_1 = throughput_3;
    float3  glowed_0 = _S1174;
    float3  extinction_in_0 = _S1174;
    float g_in_0 = 0.0f;
    uint filling_2 = 4294967295U;
    float _S1196 = dom_7->spread;
    float _S1197 = dom_7->width;
    float _S1198 = length_0(_S1193);
    NEEVertex _S1199 = NEEVertex_x24init_0(true, 0.0f, _S1174, _S1174, _S1174);
    NEEVertex nee_vertex_0 = _S1199;
    Vertex _S1200 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_0 = _S1200;
    Reservoir _S1201 = (Reservoir{});
    Reservoir chain_0 = _S1201;
    uint _S1202 = r_8->seed;
    (&chain_0)->seed = r_8->seed;
    (&ray_2)->origin = _S1192;
    (&hit_4)->distance = _S1198;
    FKMedium _S1203 = (fcptCameraMedium(((&ray_2)->unit_direction), ((&hit_4)->distance), (&filling_2)));
    uint _S1204 = filling_2;
    bool _S1205 = (fcptVaryingUsed());
    uint _S1206 = _slang_select(_S1205, _S1204,4294967295U);
    filling_2 = _S1206;
    scatter_in_0 = _S1203.scatter;
    extinction_in_0 = _S1203.extinction;
    g_in_0 = _S1203.g;
    Reservoir _S1207 = chain_0;
    uint _S1208 = filling_2;
    for(;;)
    {
        bool _S1209 = (fcptVaryingUsed());
        if(_S1209)
        {
            passes_0 = _S1208 != 4294967295U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            float _S1210 = (fcptMajorant((_S1208)));
            spread_1 = _S1210;
        }
        else
        {
            spread_1 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
        }
        if(replay_1)
        {
            turned_1 = 4294967295U == _S1190;
        }
        else
        {
            turned_1 = false;
        }
        if(turned_1)
        {
            turned_1 = _S1179 == 1U;
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
            ended_0 = _S1175;
            sky_pdf_0 = 0.0f;
            spread_1 = _S1196;
            width_3 = _S1197;
            density_2 = 1.0f;
            throughput_2 = throughput_3;
            b_5 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S1211 = (&prev_0)->rough;
        if(_S1211)
        {
            turned_1 = !(spread_1 > 0.0f);
        }
        else
        {
            turned_1 = false;
        }
        (&prev_0)->rough = turned_1;
        uint _S1212 = stream(_S1202, 384U);
        uint tracking_0 = _S1212;
        weight_1 = throughput_3;
        glowed_0 = _S1174;
        b_5 = 4294967295U;
        throughput_2 = throughput_3;
        density_2 = 1.0f;
        threshold_0 = _S1196;
        width_3 = _S1197;
        sky_pdf_0 = 0.0f;
        for(;;)
        {
            if(((&hit_4)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S1173 = int(1);
                break;
            }
            uint _S1213 = b_5 + 320U;
            bool _S1214 = b_5 == 4294967295U;
            uint _S1215 = _slang_select(_S1214, 384U,_S1213);
            uint _S1216 = stream(_S1202, _S1215);
            Random _S1217 = pcg(_S1216);
            float _S1218 = - (F32_log((1.0f - _S1217.value))) / spread_1;
            if(passes_0)
            {
                float3  _S1219 = (&ray_2)->origin;
                float3  _S1220 = (&ray_2)->unit_direction;
                float _S1221 = (&hit_4)->distance;
                uint _S1222 = _slang_select(_S1214, 0U,b_5);
                uint _S1223 = (&prev_0)->lobe;
                uint _S1224 = _slang_select(_S1214, 3U,_S1223);
                float _S1225 = (fcptTrackMedium((_S1208), (_S1219), (_S1220), (_S1221), (&tracking_0), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1222), (_S1224), (_S1214)));
                geometry_density_0 = _S1225;
            }
            else
            {
                geometry_density_0 = _S1218;
            }
            bool _S1226 = !(geometry_density_0 < ((&hit_4)->distance));
            if(_S1226)
            {
                _S1173 = int(1);
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
                float3  _S1227 = throughput_2 * glowed_0 / make_float3 (density_2);
                float3  _S1228 = sel_7->glow + _S1227;
                sel_7->glow = _S1228;
            }
            else
            {
            }
            glowed_0 = _S1174;
            uint b_7 = b_5 + 1U;
            float3  _S1229 = (&ray_2)->origin + make_float3 (geometry_density_0) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S1229;
            float3  _S1230 = flightWeight_0(scatter_in_0, extinction_in_0, spread_1, geometry_density_0, true);
            float3  _S1231 = weight_1;
            float3  _S1232 = _slang_select(passes_0, _S1231,_S1230);
            float3  throughput_4 = throughput_2 * _S1232;
            uint _S1233 = stream(_S1202, b_7 + 320U);
            tracking_0 = _S1233;
            weight_1 = throughput_3;
            float width_6 = width_3 + threshold_0 * geometry_density_0;
            float _S1234 = threshold_0 + 3.14159274101257324f;
            bool _S1235 = !replay_1;
            if(_S1235)
            {
                is_inside_5 = true;
            }
            else
            {
                bool _S1236 = b_7 == _S1190;
                if(_S1236)
                {
                    is_inside_5 = !passes_0;
                }
                else
                {
                    is_inside_5 = false;
                }
            }
            TreeSample _S1237 = TreeSample_x24init_0(_S1174, _S1174, 0.0f, 0U);
            if(is_inside_5)
            {
                float3  _S1238 = (&ray_2)->origin;
                float3  _S1239 = (&ray_2)->unit_direction;
                float3  _S1240 = (&ray_2)->unit_direction;
                uint _S1241 = stream(_S1202, b_7 + 64U);
                float3  _S1242 = extinction_in_0;
                float3  _S1243 = extinction_in_0;
                uint2  _S1244 = make_uint2 (_S1208);
                float3  _S1245 = (&ray_2)->unit_direction;
                uint _S1246 = arrivalLobe_0(b_7, (&prev_0)->lobe);
                FKHit _S1247 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S1248 = _S1247;
                ShadowContext _S1249 = ShadowContext_x24init_0(_S1242, _S1243, _S1244, _S1245, b_7, _S1246, false, geometry_density_0, width_6, &_S1248, false);
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
            bool _S1254 = b_7 < _S1253;
            if(_S1254)
            {
                viewed_0 = (light_3.density) > 0.0f;
            }
            else
            {
                viewed_0 = false;
            }
            float _S1255 = _slang_select(viewed_0, _S1252,0.0f);
            float3  _S1256 = throughput_4 * light_3.radiance;
            float _S1257 = powerHeuristic(light_3.density, _S1255);
            float3  _S1258 = _S1256 * make_float3 (_S1252 * _S1257);
            float3  _S1259 = _slang_select(is_inside_5, _S1258,_S1174);
            if(replay_1)
            {
                _S1171 = b_7 == _S1190;
            }
            else
            {
                _S1171 = false;
            }
            if(_S1171)
            {
                bool _S1260 = _S1179 == 2U;
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
                    _S1173 = int(0);
                    ended_0 = _S1262;
                    spread_1 = _S1234;
                    geometry_density_0 = width_6;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_7;
                    break;
                }
                _S1173 = int(0);
                ended_0 = _S1175;
                spread_1 = _S1234;
                geometry_density_0 = width_6;
                chain_throughput_0 = throughput_4;
                layer_0 = b_7;
                break;
            }
            if(_S1235)
            {
                Reservoir candidate_3 = _S1207;
                uint _S1263 = extractBits_0(_S1207.path, 10U, 2U);
                bool _S1264 = _S1263 == 1U;
                if(_S1264)
                {
                    float3  _S1265 = safeDivide(_S1259, _S1174);
                    (&candidate_3)->radiance = _S1265;
                }
                else
                {
                    uint _S1266 = insertBits_0(0U, b_7 + 1U, 5U, 5U);
                    uint _S1267 = insertBits_0(_S1266, 2U, 10U, 2U);
                    (&candidate_3)->path = _S1267;
                }
                Reservoir _S1268 = withEnd(candidate_3, 0U, b_7, _S1259);
                offer(sel_7, _S1268, _S1259 * make_float3 (scale_3) / make_float3 (density_2));
                float _S1269 = survivalProbability(throughput_4, density_2);
                uint _S1270 = stream(_S1202, b_7 + 128U);
                Random _S1271 = pcg(_S1270);
                bool _S1272 = _S1269 < (_S1271.value);
                if(_S1272)
                {
                    _S1172 = true;
                }
                else
                {
                    uint _S1273 = (fcptMaxBounces());
                    _S1172 = b_7 >= _S1273;
                }
                if(_S1172)
                {
                    _S1173 = int(0);
                    ended_0 = _S1175;
                    spread_1 = _S1234;
                    geometry_density_0 = width_6;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_7;
                    break;
                }
                float _S1274 = density_2 * _S1269;
                density_2 = _S1274;
            }
            else
            {
            }
            float phase_pdf_0 = 0.0f;
            uint _S1275 = stream(_S1202, b_7);
            float3  _S1276 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1275, &phase_pdf_0);
            (&ray_2)->unit_direction = _S1276;
            NEEVertex _S1277 = NEEVertex_x24init_0(false, phase_pdf_0, (&ray_2)->origin, _S1174, (&ray_2)->origin);
            nee_vertex_0 = _S1277;
            Vertex _S1278 = Vertex_x24init_0(false, 0U, 0.0f, 1.0f, false);
            prev_0 = _S1278;
            float _S1279 = (&prev_0)->pdf;
            FKRay _S1280 = ray_2;
            FKHit _S1281 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S1282 = (fcptTraverseInstanceBVH((_S1280), (true), (4.294967296e+09f), (false), (_S1281), (false)));
            hit_4 = _S1282;
            b_5 = b_7;
            throughput_2 = throughput_4;
            threshold_0 = _S1234;
            width_3 = width_6;
            sky_pdf_0 = _S1279;
        }
        if(_S1173 != int(1))
        {
            width_3 = geometry_density_0;
            throughput_2 = chain_throughput_0;
            b_5 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S1175;
        spread_1 = threshold_0;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    bool _S1283 = b_5 == 4294967295U;
    bool _S1284 = ((&hit_4)->instance_index) == 4294967295U;
    if(_S1284)
    {
        bool _S1285 = !(&nee_vertex_0)->none;
        float _S1286 = _slang_select(_S1285, sky_pdf_0,0.0f);
        float _S1287 = escapeWeight_0(_S1286, (&ray_2)->unit_direction);
        float3  _S1288 = environment_0((&ray_2)->unit_direction, b_5, (&prev_0)->lobe);
        float3  _S1289 = throughput_2 * _S1288;
        if(replay_1)
        {
            bool _S1290 = b_5 == _S1190;
            if(_S1290)
            {
                passes_0 = _S1179 == 3U;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                return Shift_x24init_0(_S1289 * make_float3 (_S1287) / make_float3 (r_8->jac), density_2 / r_8->jac);
            }
            if(_S1189)
            {
                passes_0 = _S1186;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                passes_0 = b_5 == _S1177;
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
                return Shift_x24init_0(_S1289 * make_float3 (_S1287), 1.0f);
            }
            return _S1175;
        }
        Reservoir candidate_4 = chain_0;
        uint _S1291 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1292 = _S1291 == 1U;
        if(_S1292)
        {
            uint _S1293 = extractBits_0((&chain_0)->path, 5U, 5U);
            bool _S1294 = _S1293 == b_5;
            float _S1295 = _slang_select(_S1294, 1.0f,_S1287);
            float3  _S1296 = safeDivide(_S1289 * make_float3 (_S1295), _S1174);
            (&candidate_4)->radiance = _S1296;
        }
        else
        {
            bool _S1297 = (&prev_0)->rough;
            if(_S1297)
            {
                uint _S1298 = insertBits_0(0U, b_5 + 1U, 5U, 5U);
                uint _S1299 = insertBits_0(_S1298, 3U, 10U, 2U);
                uint _S1300 = insertBits_0(_S1299, (&prev_0)->lobe, 15U, 3U);
                bool _S1301 = (&prev_0)->inside;
                uint _S1302 = _slang_select(_S1301, 1U,0U);
                uint _S1303 = insertBits_0(_S1300, _S1302, 22U, 1U);
                (&candidate_4)->path = _S1303;
                (&candidate_4)->jac = (&prev_0)->pdf;
                (&candidate_4)->dir = (&ray_2)->unit_direction;
            }
        }
        float3  _S1304 = _S1289 * make_float3 (_S1287);
        Reservoir _S1305 = withEnd(candidate_4, 3U, b_5, _S1304);
        offer(sel_7, _S1305, _S1304 * make_float3 (scale_3) / make_float3 (density_2));
        return _S1175;
    }
    float3  _S1306 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
    (&ray_2)->origin = _S1306;
    bool _S1307 = (fcptVaryingUsed());
    if(_S1307)
    {
        passes_0 = filling_2 != 4294967295U;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        bool _S1308 = !replay_1;
        if(_S1308)
        {
            float3  _S1309 = throughput_2 * glowed_0 / make_float3 (density_2);
            float3  _S1310 = sel_7->glow + _S1309;
            sel_7->glow = _S1310;
        }
        float3  _S1311 = throughput_2 * weight_1;
        throughput_2 = _S1311;
    }
    else
    {
        float3  _S1312 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
        float3  _S1313 = throughput_2 * _S1312;
        throughput_2 = _S1313;
    }
    float _S1314 = width_3 + spread_1 * (&hit_4)->distance;
    uint _S1315 = b_5 + 1U;
    b_5 = _S1315;
    layer_0 = 0U;
    width_3 = _S1314;
    passes_0 = false;
    threshold_0 = 0.0f;
    turned_1 = false;
    is_inside_5 = false;
    chain_throughput_0 = _S1174;
    float3  reconnection_0 = _S1174;
    viewed_0 = _S1283;
    for(;;)
    {
        bool _S1316 = ((&hit_4)->is_point_light) == 1U;
        if(replay_1)
        {
            _S1171 = _S1179 == 1U;
        }
        else
        {
            _S1171 = false;
        }
        if(_S1171)
        {
            _S1172 = b_5 == _S1178;
        }
        else
        {
            _S1172 = false;
        }
        bool _S1317;
        if(_S1172)
        {
            bool _S1318 = ((&hit_4)->instance_index) != (_S1191.instance_index);
            if(_S1318)
            {
                _S1317 = true;
            }
            else
            {
                _S1317 = ((&hit_4)->triangle_index) != (_S1191.triangle_index);
            }
        }
        else
        {
            _S1317 = false;
        }
        if(_S1317)
        {
            return _S1175;
        }
        FKMedium _S1319 = Medium_x24init_0(_S1174, _S1174, 0.0f);
        BSDFMaterial _S1320 = Material_x24init_0(_S1174, _S1174, 0.0f, 0.0f, 0.0f, 0.0f, _S1174, throughput_3, 1.0f, _S1174, _S1174, 0.5f, 0.0f, 0.0f, _S1174, 0.0f, _S1174);
        FKMedium _S1321 = _S1319;
        FKSurface _S1322 = Surface_x24init_0(_S1174, _S1174, 0.0f, &_S1320, false, 0U, 1.0f, false, &_S1321, 4294967295U, _S1174);
        bool _S1323 = !_S1316;
        bool scatter_2;
        bool is_inside_6;
        float3  throughput_5;
        FKSurface surface_12;
        if(_S1323)
        {
            uint _S1324 = stream(_S1202, b_5);
            uint _S1325 = arrivalLobe_0(b_5, (&prev_0)->lobe);
            FKSurface _S1326 = (fcptSurfaceAtPath((hit_4), ((&ray_2)->origin), (_S1324), (width_3), (layer_0), (b_5), (_S1325), ((&ray_2)->unit_direction)));
            bool _S1327 = !passes_0;
            FKSurface _S1328 = _S1326;
            FKSurface _S1329 = emitting_0(&_S1328, _S1327);
            uint _S1330 = stream(_S1202, b_5 + 256U);
            Random _S1331 = pcg(_S1330);
            FKSurface _S1332 = _S1329;
            FKSurface _S1333 = uncovered_0(&_S1332, _S1331.value);
            float _S1334 = facingSign(_S1333.material.transmission, _S1333.geometry_n, (&ray_2)->unit_direction);
            bool _S1335 = _S1334 < 0.0f;
            bool _S1336 = (_S1333.material.transmission) > 0.0f;
            if(_S1336)
            {
                bool _S1337 = arrivesBehind_0((&ray_2)->unit_direction, _S1333.geometry_n);
                scatter_2 = _S1337;
            }
            else
            {
                scatter_2 = false;
            }
            FKSurface _S1338 = _S1333;
            FKSurface _S1339 = facingRay_0(&_S1338, (&ray_2)->unit_direction);
            if(passes_0)
            {
                bool _S1340 = arrivesBehind_0((&ray_2)->unit_direction, _S1339.geometry_n);
                is_inside_6 = _S1340;
            }
            else
            {
                is_inside_6 = scatter_2;
            }
            if(is_inside_6)
            {
                float3  _S1341 = beerLambert((&hit_4)->distance, _S1339.material.absorption);
                float3  _S1342 = throughput_2 * _S1341;
                throughput_5 = _S1342;
            }
            else
            {
                throughput_5 = throughput_2;
            }
            bool _S1343 = !_S1339.skip;
            float geometry_density_1 = (F32_abs((dot_0(_S1339.geometry_n, (&ray_2)->unit_direction)))) / ((&hit_4)->distance * (&hit_4)->distance);
            bool _S1344 = b_5 == _S1315;
            if(_S1344)
            {
                float _S1345 = 0.00251327408477664f / geometry_density_1;
                geometry_density_0 = _S1345;
            }
            else
            {
                geometry_density_0 = threshold_0;
            }
            float _S1346 = geometry_density_0;
            scatter_2 = _S1343;
            geometry_density_0 = geometry_density_1;
            threshold_0 = _S1346;
            surface_12 = _S1339;
            turned_1 = _S1335;
        }
        else
        {
            scatter_2 = false;
            geometry_density_0 = 0.0f;
            surface_12 = _S1322;
            throughput_5 = throughput_2;
            is_inside_6 = is_inside_5;
        }
        bool _S1347;
        if(scatter_2)
        {
            _S1347 = (&prev_0)->rough;
        }
        else
        {
            _S1347 = false;
        }
        bool _S1348;
        if(_S1347)
        {
            _S1348 = ((&prev_0)->pdf * geometry_density_0 * threshold_0) <= 1.0f;
        }
        else
        {
            _S1348 = false;
        }
        FKSurface _S1349 = surface_12;
        FKSurface _S1350 = surface_12;
        float _S1351 = dot_0(surface_12.smooth_n, - (&ray_2)->unit_direction);
        float2  _S1352 = vertexEta(_S1349.material, _S1351);
        bool _S1353;
        if(scatter_2)
        {
            bool _S1354 = neeDecision(_S1349.material, _S1351, _S1352.x, _S1352.y);
            _S1353 = _S1354;
        }
        else
        {
            _S1353 = false;
        }
        bool _S1355;
        if(passes_0)
        {
            _S1355 = true;
        }
        else
        {
            _S1355 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S1355)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S1353;
        }
        bool _S1356 = (fcptHairUsed());
        bool _S1357;
        if(_S1356)
        {
            float3  _S1358 = surface_12.hair;
            _S1357 = (dot_0(_S1358, _S1358)) > 0.0f;
        }
        else
        {
            _S1357 = false;
        }
        bool _S1359;
        if(_S1357)
        {
            _S1359 = true;
        }
        else
        {
            BSDFMaterial _S1360 = _S1349.material;
            bool _S1361 = isTranslucent_0(&_S1360);
            _S1359 = _S1361;
        }
        bool _S1362;
        if(_S1359)
        {
            _S1362 = true;
        }
        else
        {
            bool _S1363 = (_S1349.material.transmission) > 0.0f;
            if(_S1363)
            {
                uint _S1364 = (fcptLayers((hit_4)));
                _S1362 = _S1364 == 1U;
            }
            else
            {
                _S1362 = false;
            }
        }
        float3  emission_0;
        if(_S1316)
        {
            float3  _S1365 = (fcptCalculatePointLightContrib(((&hit_4)->instance_index)));
            emission_0 = _S1365;
        }
        else
        {
            emission_0 = _S1349.material.emissive;
        }
        bool _S1366 = !replay_1;
        bool _S1367;
        if(_S1366)
        {
            _S1367 = true;
        }
        else
        {
            _S1367 = b_5 >= _S1190;
        }
        bool _S1368;
        if(_S1367)
        {
            float _S1369 = rgb_to_greyscale(emission_0);
            _S1368 = _S1369 > 0.0f;
        }
        else
        {
            _S1368 = false;
        }
        float3  emission_1;
        if(_S1368)
        {
            NEEVertex _S1370 = nee_vertex_0;
            FKHit _S1371 = hit_4;
            float _S1372 = emissionWeight_0(&_S1370, &_S1371, (&ray_2)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S1372);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S1373;
        if(replay_1)
        {
            _S1373 = _S1179 == 1U;
        }
        else
        {
            _S1373 = false;
        }
        bool _S1374;
        if(_S1373)
        {
            _S1374 = b_5 > _S1178;
        }
        else
        {
            _S1374 = false;
        }
        bool _S1375;
        if(_S1374)
        {
            _S1375 = b_5 == _S1177;
        }
        else
        {
            _S1375 = false;
        }
        bool _S1376;
        if(_S1375)
        {
            bool _S1377 = _S1180 == 1U;
            if(_S1377)
            {
                _S1376 = true;
            }
            else
            {
                _S1376 = _S1180 == 2U;
            }
        }
        else
        {
            _S1376 = false;
        }
        if(_S1376)
        {
            bool _S1378 = _S1316 != (_S1180 == 2U);
            if(_S1378)
            {
                return _S1175;
            }
            return Shift_x24init_0(throughput_5 * emission_1 / make_float3 (r_8->jac), density_2 / r_8->jac);
        }
        uint _S1379 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1380 = _S1379 == 1U;
        Reservoir here_0 = chain_0;
        uint _S1381 = insertBits_0(0U, b_5, 5U, 5U);
        uint _S1382 = insertBits_0(_S1381, 1U, 10U, 2U);
        uint _S1383 = insertBits_0(_S1382, (&prev_0)->lobe, 15U, 3U);
        bool _S1384 = (&prev_0)->inside;
        uint _S1385 = _slang_select(_S1384, 1U,0U);
        uint _S1386 = insertBits_0(_S1383, _S1385, 22U, 1U);
        (&here_0)->path = _S1386;
        float _S1387 = (&prev_0)->pdf * geometry_density_0;
        (&here_0)->jac = _S1387;
        fcptWithReservoirHit((&here_0), (&hit_4));
        bool _S1388;
        if(replay_1)
        {
            _S1388 = _S1179 == 1U;
        }
        else
        {
            _S1388 = false;
        }
        bool _S1389;
        if(_S1388)
        {
            _S1389 = b_5 == _S1178;
        }
        else
        {
            _S1389 = false;
        }
        bool _S1390 = b_5 == _S1190;
        bool _S1391;
        if(_S1390)
        {
            bool _S1392 = !scatter_2;
            if(_S1392)
            {
                _S1391 = true;
            }
            else
            {
                bool _S1393 = _S1179 != 1U;
                if(_S1393)
                {
                    _S1391 = _S1179 != 3U;
                }
                else
                {
                    _S1391 = false;
                }
            }
        }
        else
        {
            _S1391 = false;
        }
        bool _S1394;
        if(_S1391)
        {
            _S1394 = _S1179 == 2U;
        }
        else
        {
            _S1394 = false;
        }
        bool _S1395;
        if(_S1394)
        {
            _S1395 = !_S1348;
        }
        else
        {
            _S1395 = false;
        }
        bool _S1396;
        if(_S1395)
        {
            _S1396 = _S1180 != 4U;
        }
        else
        {
            _S1396 = false;
        }
        bool _S1397 = _S1178 == _S1177;
        bool _S1398;
        if(_S1397)
        {
            _S1398 = _S1180 == 0U;
        }
        else
        {
            _S1398 = false;
        }
        bool _S1399;
        if(_S1398)
        {
            _S1399 = ((&hit_4)->instance_index) == (_S1191.instance_index);
        }
        else
        {
            _S1399 = false;
        }
        bool _S1400;
        if(_S1399)
        {
            _S1400 = ((&hit_4)->triangle_index) == (_S1191.triangle_index);
        }
        else
        {
            _S1400 = false;
        }
        bool _S1401;
        if(_S1400)
        {
            _S1401 = _S1348;
        }
        else
        {
            _S1401 = false;
        }
        bool _S1402 = _slang_select(_S1389, _S1401,_S1396);
        bool _S1403;
        if(nee_0)
        {
            _S1403 = _slang_select(replay_1, _S1402,scatter_2);
        }
        else
        {
            _S1403 = false;
        }
        TreeSample _S1404 = TreeSample_x24init_0(_S1174, _S1174, 0.0f, 0U);
        uint2  _S1405 = make_uint2 (0U);
        float2  _S1406 = make_float2 (0.0f);
        FKHit _S1407 = Hit_x24init_0(_S1406, 4294967295U, 0U, 0U, 0.0f);
        FKHit _S1408 = _S1407;
        ShadowContext _S1409 = ShadowContext_x24init_0(_S1174, _S1174, _S1405, _S1174, 0U, 0U, false, 0.0f, 0.0f, &_S1408, false);
        bool _S1410;
        if(nee_0)
        {
            _S1410 = _S1367;
        }
        else
        {
            _S1410 = false;
        }
        ShadowContext context_5;
        if(_S1410)
        {
            uint _S1411 = arrivalLobe_0(b_5, (&prev_0)->lobe);
            FKMedium _S1412 = (fcptOutsideMedium((hit_4)));
            FKSurface _S1413 = surface_12;
            FKHit _S1414 = hit_4;
            FKMedium _S1415 = _S1412;
            ShadowContext _S1416 = shadowContext_0(&_S1413, turned_1, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_5, _S1411, (&hit_4)->distance, width_3, &_S1414, _S1357, &_S1415);
            context_5 = _S1416;
        }
        else
        {
            context_5 = _S1409;
        }
        float3  throughput_6;
        float3  lit_0;
        if(_S1403)
        {
            float3  _S1417 = (&ray_2)->origin;
            if(_S1357)
            {
                throughput_6 = _S1174;
            }
            else
            {
                throughput_6 = _S1350.smooth_n;
            }
            FKSurface _S1418 = surface_12;
            uint _S1419 = stream(_S1202, b_5 + 64U);
            ShadowContext _S1420 = context_5;
            TreeSample _S1421 = sampleLightTree_0(_S1417, throughput_6, surface_12.geometry_n, surface_12.geometry_offset, _S1362, _S1419, &_S1420);
            bool _S1422 = any_1((_S1421.radiance) != _S1174);
            if(_S1422)
            {
                if(_S1357)
                {
                    uint _S1423 = (fcptMaxBounces());
                    bool _S1424 = b_5 < _S1423;
                    FKSurface _S1425 = surface_12;
                    TreeSample _S1426 = _S1421;
                    float3  _S1427 = hairLight_0(&_S1425, (&ray_2)->unit_direction, &_S1426, _S1424);
                    lit_0 = _S1427;
                }
                else
                {
                    float _S1428 = _S1352.x;
                    float _S1429 = _S1352.y;
                    uint _S1430 = (fcptMaxBounces());
                    bool _S1431 = b_5 < _S1430;
                    TreeSample _S1432 = _S1421;
                    BSDFMaterial _S1433 = _S1349.material;
                    float3  _S1434 = lightBSDF_0((&ray_2)->unit_direction, &_S1432, _S1350.smooth_n, _S1418.geometry_n, &_S1433, _S1428, _S1429, _S1431, surface_12.random_state);
                    lit_0 = _S1434;
                }
            }
            else
            {
                lit_0 = _S1174;
            }
            light_3 = _S1421;
        }
        else
        {
            light_3 = _S1404;
            lit_0 = _S1174;
        }
        bool viewed_1;
        bool refracted_4;
        bool wrong_side_0;
        bool _S1435;
        bool _S1436;
        float density_4;
        if(_S1389)
        {
            bool _S1437 = !_S1348;
            if(_S1437)
            {
                return _S1175;
            }
            float3  throughput_7 = throughput_5 * make_float3 (geometry_density_0);
            float density_5 = density_2 * geometry_density_0;
            if(_S1397)
            {
                viewed_1 = _S1180 == 1U;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                return Shift_x24init_0(throughput_7 * emission_1 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1397)
            {
                refracted_4 = _S1180 == 0U;
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
            {
                bool _S1438 = !nee_0;
                if(_S1438)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S1439 = rgb_to_greyscale(light_3.radiance);
                    passes_0 = !(_S1439 > 0.0f);
                }
                if(passes_0)
                {
                    return _S1175;
                }
                return Shift_x24init_0(throughput_7 * lit_0 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1397)
            {
                wrong_side_0 = _S1180 == 4U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                bool _S1440 = !nee_0;
                if(_S1440)
                {
                    return _S1175;
                }
                float _S1441 = environmentPdf_0(r_8->dir);
                float3  _S1442 = skyBSDF((&ray_2)->unit_direction, r_8->dir, surface_12, _S1352, is_inside_6, _S1441, surface_12.random_state);
                return Shift_x24init_0(throughput_7 * _S1442 * r_8->radiance / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            uint _S1443 = extractBits_0(_S1176, 21U, 1U);
            bool _S1444 = nee_0 != (_S1443 == 1U);
            if(_S1444)
            {
                return _S1175;
            }
            throughput_6 = throughput_7;
            density_4 = density_5;
        }
        else
        {
            if(replay_1)
            {
                viewed_1 = _S1390;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                bool _S1445 = !scatter_2;
                if(_S1445)
                {
                    refracted_4 = true;
                }
                else
                {
                    bool _S1446 = _S1179 != 1U;
                    if(_S1446)
                    {
                        refracted_4 = _S1179 != 3U;
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
                bool _S1447 = _S1179 == 2U;
                if(_S1447)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1348;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1180 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    if(_S1357)
                    {
                        return _S1175;
                    }
                    uint _S1448 = stream(_S1202, b_5 + 448U);
                    FKRay _S1449 = ray_2;
                    FKSurface _S1450 = surface_12;
                    ShadowContext _S1451 = context_5;
                    SkySample _S1452 = sampleSky_0(&_S1449, &_S1450, _S1352, is_inside_6, _S1448, surface_12.random_state, &_S1451);
                    return Shift_x24init_0(throughput_5 * _S1452.color, 1.0f);
                }
                if(_S1447)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1348;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float _S1453 = rgb_to_greyscale(light_3.radiance);
                    bool _S1454 = !(_S1453 > 0.0f);
                    if(_S1454)
                    {
                        return _S1175;
                    }
                    return Shift_x24init_0(throughput_5 * lit_0, 1.0f);
                }
                if(_S1189)
                {
                    passes_0 = _S1180 == 2U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1316;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_5 * emission_1, 1.0f);
                }
                if(_S1189)
                {
                    passes_0 = _S1180 == 1U;
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
                    passes_0 = !_S1348;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_5 * emission_1, 1.0f);
                }
                return _S1175;
            }
            else
            {
                if(_S1366)
                {
                    wrong_side_0 = scatter_2;
                }
                else
                {
                    wrong_side_0 = false;
                }
                if(wrong_side_0)
                {
                    bool _S1455 = b_5 > 0U;
                    if(_S1455)
                    {
                        Reservoir candidate_5 = chain_0;
                        if(_S1380)
                        {
                            float3  _S1456 = safeDivide(throughput_5 * emission_1, chain_throughput_0);
                            (&candidate_5)->radiance = _S1456;
                        }
                        else
                        {
                            if(_S1348)
                            {
                                candidate_5 = here_0;
                            }
                        }
                        float3  _S1457 = throughput_5 * emission_1;
                        Reservoir _S1458 = withEnd(candidate_5, 1U, b_5, _S1457);
                        offer(sel_7, _S1458, _S1457 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    else
                    {
                        float3  _S1459 = throughput_5 * emission_1;
                        float3  _S1460 = sel_7->glow + _S1459;
                        sel_7->glow = _S1460;
                    }
                    if(nee_0)
                    {
                        float3  _S1461 = throughput_5 * lit_0;
                        Reservoir candidate_6 = chain_0;
                        if(_S1380)
                        {
                            float3  _S1462 = safeDivide(_S1461, chain_throughput_0);
                            (&candidate_6)->radiance = _S1462;
                        }
                        else
                        {
                            if(_S1348)
                            {
                                candidate_6 = here_0;
                                uint _S1463 = insertBits_0((&candidate_6)->path, 1U, 21U, 1U);
                                (&candidate_6)->path = _S1463;
                                (&candidate_6)->dir = light_3.dir;
                                (&candidate_6)->radiance = light_3.radiance;
                            }
                            else
                            {
                                uint _S1464 = insertBits_0(0U, b_5 + 1U, 5U, 5U);
                                uint _S1465 = insertBits_0(_S1464, 2U, 10U, 2U);
                                (&candidate_6)->path = _S1465;
                            }
                        }
                        Reservoir _S1466 = withEnd(candidate_6, 0U, b_5, _S1461);
                        offer(sel_7, _S1466, _S1461 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    if(nee_0)
                    {
                        if(_S1357)
                        {
                            _S1435 = false;
                        }
                        else
                        {
                            bool _S1467 = environmentMapped_0();
                            _S1435 = _S1467;
                        }
                    }
                    else
                    {
                        _S1435 = false;
                    }
                    if(_S1435)
                    {
                        uint _S1468 = (fcptMaxBounces());
                        _S1436 = b_5 < _S1468;
                    }
                    else
                    {
                        _S1436 = false;
                    }
                    if(_S1436)
                    {
                        uint _S1469 = stream(_S1202, b_5 + 448U);
                        FKRay _S1470 = ray_2;
                        FKSurface _S1471 = surface_12;
                        ShadowContext _S1472 = context_5;
                        SkySample _S1473 = sampleSky_0(&_S1470, &_S1471, _S1352, is_inside_6, _S1469, surface_12.random_state, &_S1472);
                        float3  _S1474 = throughput_5 * _S1473.color;
                        Reservoir candidate_7 = chain_0;
                        if(_S1380)
                        {
                            float3  _S1475 = safeDivide(_S1474, chain_throughput_0);
                            (&candidate_7)->radiance = _S1475;
                        }
                        else
                        {
                            if(_S1348)
                            {
                                candidate_7 = here_0;
                                uint _S1476 = insertBits_0((&candidate_7)->path, 1U, 21U, 1U);
                                (&candidate_7)->path = _S1476;
                                (&candidate_7)->dir = _S1473.dir;
                                (&candidate_7)->radiance = _S1473.radiance;
                            }
                            else
                            {
                                uint _S1477 = insertBits_0(0U, b_5 + 1U, 5U, 5U);
                                uint _S1478 = insertBits_0(_S1477, 2U, 10U, 2U);
                                (&candidate_7)->path = _S1478;
                            }
                        }
                        Reservoir _S1479 = withEnd(candidate_7, 4U, b_5, _S1474);
                        offer(sel_7, _S1479, _S1474 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                }
            }
            throughput_6 = throughput_5;
            density_4 = density_2;
        }
        bool _S1480;
        bool _S1481;
        bool _S1482;
        bool straight_0;
        bool _S1483;
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
        float spread_4;
        uint b_8;
        float3  throughput_8;
        float3  throughput_9;
        float3  throughput_10;
        if(scatter_2)
        {
            if(replay_1)
            {
                viewed_1 = _S1390;
            }
            else
            {
                viewed_1 = false;
            }
            uint _S1496 = extractBits_0(_S1176, 15U, 3U);
            uint _S1497 = extractBits_0(_S1176, 18U, 3U);
            uint _S1498 = _slang_select(_S1389, _S1497,_S1496);
            float3  _S1499 = r_8->dir;
            bool refracted_5 = _S1498 == 1U;
            SampleBSDF _S1500 = SampleBSDF_x24init_0(_S1174, _S1174, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_5 = _S1500;
            float3  reconnection_1;
            if(viewed_1)
            {
                uint _S1501 = extractBits_0(_S1176, 22U, 1U);
                bool _S1502 = is_inside_6 != (_S1501 == 1U);
                if(_S1502)
                {
                    return _S1175;
                }
                bool _S1503 = _S1179 == 1U;
                if(_S1503)
                {
                    float3  _S1504 = (fcptHitPosition((_S1191)));
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
                    BSDFMaterial _S1505 = _S1349.material;
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
                        wrong_side_0 = (dot_0(_S1350.smooth_n, _S1508) * _S1351) < 0.0f;
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
                    float3  _S1511 = - _S1350.smooth_n;
                    bool _S1512 = is_inside_6 != refracted_4;
                    float3  _S1513 = _slang_select(_S1512, _S1511,_S1350.smooth_n);
                    float3  _S1514 = throughput_8 - (_S1509 + make_float3 (_S1510.geometry_offset) * _S1513);
                    float3  _S1515 = ((((_S1514)) * make_float3(rnorm3df(((_S1514)).x, ((_S1514)).y, ((_S1514)).z))));
                    reconnection_1 = _S1515;
                }
                else
                {
                    reconnection_1 = _S1499;
                }
                if(_S1357)
                {
                    wrong_side_0 = false;
                }
                else
                {
                    bool _S1516 = wrongSide_0(is_inside_6, refracted_4, reconnection_1, surface_12.geometry_n);
                    wrong_side_0 = _S1516;
                }
                if(wrong_side_0)
                {
                    return _S1175;
                }
                float3  _S1517 = throughput_8;
                throughput_8 = reconnection_1;
                b_8 = _S1498;
                wrong_side_0 = false;
                reconnection_1 = _S1517;
            }
            else
            {
                bool _S1518 = !_S1389;
                if(_S1518)
                {
                    SampleBSDF bsdf_sampled_0;
                    SampleBSDF _S1519;
                    if(_S1357)
                    {
                        SampleBSDF _S1520 = (fcptSampleHair((surface_12.hair), (_S1349.material.albedo), (_S1349.material.specular_tint), ((&ray_2)->unit_direction), (surface_12.random_state)));
                        _S1519 = _S1520;
                    }
                    else
                    {
                        SampleBSDF _S1521 = sampleBSDF((&ray_2)->unit_direction, _S1350.smooth_n, _S1349.material, _S1352.x, _S1352.y, surface_12.random_state, _S1406);
                        _S1519 = _S1521;
                    }
                    bsdf_sampled_0 = _S1519;
                    if(_S1357)
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
                            return _S1175;
                        }
                        break;
                    }
                    if(_S1357)
                    {
                        wrong_side_0 = false;
                    }
                    else
                    {
                        bool _S1522 = wrongSide_0(is_inside_6, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, surface_12.geometry_n);
                        wrong_side_0 = _S1522;
                    }
                    if(wrong_side_0)
                    {
                        _S1435 = (_S1349.material.transmission) > 0.0f;
                    }
                    else
                    {
                        _S1435 = false;
                    }
                    if(_S1435)
                    {
                        SampleBSDF _S1523 = sampleBSDF((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n, _S1349.material, _S1352.x, _S1352.y, (&bsdf_sampled_0)->random_state, _S1406);
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
                    b_8 = _S1525;
                    refracted_4 = _S1527;
                }
                else
                {
                    throughput_8 = _S1499;
                    b_8 = _S1498;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(viewed_1)
            {
                _S1435 = true;
            }
            else
            {
                _S1435 = _S1389;
            }
            float3  chain_throughput_1;
            if(_S1435)
            {
                if(_S1357)
                {
                    SampleBSDF _S1530 = (fcptConnectHair((surface_12.hair), (_S1349.material.albedo), (_S1349.material.specular_tint), ((&ray_2)->unit_direction), (throughput_8)));
                    lobe_5 = _S1530;
                }
                else
                {
                    float3  _S1531 = (&ray_2)->unit_direction;
                    float _S1532 = sign_0(_S1351);
                    float3  _S1533 = _S1350.smooth_n * make_float3 (_S1532);
                    float _S1534 = dot_0(_S1533, throughput_8);
                    float _S1535 = _S1349.material.roughness;
                    float _S1536 = _S1535 * _S1535;
                    AnisotropicFrame _S1537 = anisotropicFrame(_S1349.material, _S1533);
                    float3  _S1538 = negate_0(_S1531);
                    SheenProfile _S1539 = sheenProfile(_S1538, _S1533, _S1349.material);
                    float3  _S1540 = reflectedHalf(_S1531, throughput_8);
                    bool _S1541 = b_8 == 1U;
                    if(_S1541)
                    {
                        float3  _S1542 = refractedHalf(_S1531, throughput_8, _S1350.smooth_n, _S1352.x, _S1352.y);
                        throughput_9 = _S1542;
                    }
                    else
                    {
                        throughput_9 = _S1540;
                    }
                    bool _S1543 = b_8 == 0U;
                    if(_S1543)
                    {
                        _S1436 = true;
                    }
                    else
                    {
                        _S1436 = b_8 == 6U;
                    }
                    if(_S1436)
                    {
                        float3  _S1544 = sampledHalf(_S1531, _S1350.smooth_n, _S1349.material, surface_12.random_state, _S1537);
                        throughput_10 = _S1544;
                    }
                    else
                    {
                        throughput_10 = throughput_9;
                    }
                    float3  _S1545 = negate_0(_S1531);
                    float _S1546 = _S1352.x;
                    float _S1547 = _S1352.y;
                    BSDFLobes _S1548 = bsdfLobes(_S1531, _S1545, _S1533, throughput_10, _S1349.material, _S1546, _S1547, _S1537, _S1539);
                    BSDFLobes lobe_terms_1 = _S1548;
                    float _S1549 = translucentShare(_S1349.material);
                    (&lobe_terms_1)->translucent_share = _S1549;
                    switch(b_8)
                    {
                    case 0U:
                        {
                            float _S1550 = diffusePDF(_S1534, 0.0f, (F32_abs((_S1351))), _S1536, lobe_terms_1, _S1546, _S1547);
                            float3  _S1551 = diffuseBSDF(throughput_8, _S1533, _S1536, _S1349.material, lobe_terms_1);
                            density_6 = _S1550;
                            chain_throughput_1 = _S1551;
                            break;
                        }
                    case 1U:
                        {
                            float _S1552 = refractPDF(_S1534, dot_0(throughput_8, throughput_10), (F32_abs((_S1351))), _S1536, lobe_terms_1, _S1546, _S1547);
                            float3  _S1553 = refractBSDF(throughput_8, _S1533, _S1536, _S1349.material, lobe_terms_1);
                            density_6 = _S1552;
                            chain_throughput_1 = _S1553;
                            break;
                        }
                    case 4U:
                        {
                            float _S1554 = sheenVelvetPDF(_S1534, 0.0f, (F32_abs((_S1351))), _S1536, lobe_terms_1, _S1546, _S1547);
                            float3  _S1555 = sheenVelvetBSDF(throughput_8, _S1533, _S1536, _S1349.material, lobe_terms_1);
                            density_6 = _S1554;
                            chain_throughput_1 = _S1555;
                            break;
                        }
                    case 6U:
                        {
                            float _S1556 = toonPDF(_S1534, dot_0(throughput_8, (&lobe_terms_1)->toon_axis), (F32_abs((_S1351))), _S1536, lobe_terms_1, _S1546, _S1547);
                            float3  _S1557 = toonBSDF(throughput_8, _S1533, _S1536, _S1349.material, lobe_terms_1);
                            density_6 = _S1556;
                            chain_throughput_1 = _S1557;
                            break;
                        }
                    default:
                        {
                            float _S1558 = reflectPDF(_S1534, 0.0f, (F32_abs((_S1351))), _S1536, lobe_terms_1, _S1546, _S1547);
                            float3  _S1559 = reflectBSDF(throughput_8, _S1533, _S1536, _S1349.material, lobe_terms_1);
                            density_6 = _S1558;
                            chain_throughput_1 = _S1559;
                            break;
                        }
                    }
                    bool _S1560 = density_6 > 0.0f;
                    if(_S1560)
                    {
                        SampleBSDF _S1561 = SampleBSDF_x24init_0(throughput_8, chain_throughput_1, surface_12.random_state, _S1541, b_8, density_6);
                        lobe_5 = _S1561;
                    }
                }
            }
            bool _S1562 = b_8 == 0U;
            if(_S1562)
            {
                _S1436 = true;
            }
            else
            {
                _S1436 = b_8 == 4U;
            }
            if(_S1436)
            {
                _S1480 = true;
            }
            else
            {
                _S1480 = b_8 == 6U;
            }
            if(_S1357)
            {
                _S1481 = false;
            }
            else
            {
                bool _S1563 = !_S1480;
                if(_S1563)
                {
                    bool _S1564 = (_S1349.material.roughness) == 0.0f;
                    if(_S1564)
                    {
                        _S1481 = true;
                    }
                    else
                    {
                        bool _S1565 = b_8 == 1U;
                        if(_S1565)
                        {
                            _S1481 = (_S1352.x) == (_S1352.y);
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
            }
            bool _S1566 = !_S1357;
            if(_S1566)
            {
                _S1482 = b_8 == 1U;
            }
            else
            {
                _S1482 = false;
            }
            if(_S1482)
            {
                straight_0 = (_S1349.material.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S1483 = _S1566;
            }
            else
            {
                _S1483 = false;
            }
            if(_S1483)
            {
                _S1484 = b_8 == 1U;
            }
            else
            {
                _S1484 = false;
            }
            if(_S1484)
            {
                _S1485 = (_S1352.x) == (_S1352.y);
            }
            else
            {
                _S1485 = false;
            }
            BSDFMaterial _S1567 = _S1349.material;
            bool _S1568 = isTranslucent_0(&_S1567);
            if(_S1568)
            {
                _S1486 = _S1562;
            }
            else
            {
                _S1486 = false;
            }
            if(_S1486)
            {
                _S1487 = (dot_0(throughput_8, surface_12.geometry_n)) < 0.0f;
            }
            else
            {
                _S1487 = false;
            }
            if(nee_0)
            {
                _S1488 = !_S1481;
            }
            else
            {
                _S1488 = false;
            }
            if(_S1488)
            {
                _S1489 = !wrong_side_0;
            }
            else
            {
                _S1489 = false;
            }
            if(_S1489)
            {
                float _S1569 = (&lobe_5)->pdf;
                float3  _S1570 = (&ray_2)->origin;
                float3  _S1571 = _slang_select(_S1362, _S1174,_S1350.smooth_n);
                float3  _S1572 = (&ray_2)->origin;
                FKSurface _S1573 = surface_12;
                float3  _S1574 = - _S1350.smooth_n;
                float3  _S1575 = _slang_select(_S1487, _S1574,_S1350.smooth_n);
                NEEVertex _S1576 = NEEVertex_x24init_0(false, _S1569, _S1570, _S1571, _S1572 + make_float3 (_S1573.geometry_offset) * _S1575);
                nee_vertex_0 = _S1576;
            }
            else
            {
                if(_S1357)
                {
                    _S1490 = true;
                }
                else
                {
                    bool _S1577 = b_8 != 1U;
                    if(_S1577)
                    {
                        _S1490 = true;
                    }
                    else
                    {
                        _S1490 = (_S1352.x) != (_S1352.y);
                    }
                }
                if(_S1490)
                {
                    (&nee_vertex_0)->none = true;
                }
            }
            bool _S1578 = ((&lobe_5)->pdf) > 0.0f;
            if(_S1578)
            {
                if(_S1480)
                {
                    _S1490 = true;
                }
                else
                {
                    _S1490 = ((&lobe_5)->pdf * (&prev_0)->cos / ((&hit_4)->distance * (&hit_4)->distance) * threshold_0) <= 1.0f;
                }
            }
            else
            {
                _S1490 = false;
            }
            bool _S1579 = ((&lobe_5)->pdf) > 0.0f;
            if(_S1579)
            {
                if(_S1480)
                {
                    _S1491 = true;
                }
                else
                {
                    _S1491 = (_S1349.material.roughness) >= 0.20000000298023224f;
                }
            }
            else
            {
                _S1491 = false;
            }
            if(_S1389)
            {
                bool _S1580 = !_S1490;
                if(_S1580)
                {
                    return _S1175;
                }
                bool _S1581 = _S1180 != 1U;
                if(_S1581)
                {
                    _S1492 = _S1180 != 2U;
                }
                else
                {
                    _S1492 = false;
                }
                if(_S1492)
                {
                    float _S1582 = (&lobe_5)->pdf;
                    float _S1583 = _slang_select(nee_0, _S1582,0.0f);
                    float _S1584 = escapeWeight_0(_S1583, _S1499);
                    if(_S1397)
                    {
                        passes_0 = _S1186;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1585 = _slang_select(passes_0, _S1584,1.0f);
                    return Shift_x24init_0(throughput_6 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf)) * r_8->radiance * make_float3 (_S1585) / make_float3 (r_8->jac), density_4 * (&lobe_5)->pdf / r_8->jac);
                }
                float3  _S1586 = throughput_6 * make_float3 ((&lobe_5)->pdf);
                float _S1587 = density_4 * (&lobe_5)->pdf;
                throughput_9 = _S1586;
                density_6 = _S1587;
            }
            else
            {
                throughput_9 = throughput_6;
                density_6 = density_4;
            }
            uint _S1588 = (fcptLayers((hit_4)));
            bool _S1589 = _S1588 > 1U;
            if(_S1589)
            {
                _S1492 = (b_8 == 1U) != passes_0;
            }
            else
            {
                _S1492 = false;
            }
            if(viewed_1)
            {
                _S1493 = _S1492;
            }
            else
            {
                _S1493 = false;
            }
            if(_S1493)
            {
                return _S1175;
            }
            if(replay_1)
            {
                _S1494 = b_5 <= _S1190;
            }
            else
            {
                _S1494 = false;
            }
            if(_S1494)
            {
                _S1495 = _S1348;
            }
            else
            {
                _S1495 = false;
            }
            bool _S1590;
            if(_S1495)
            {
                _S1590 = _S1490;
            }
            else
            {
                _S1590 = false;
            }
            bool _S1591;
            if(_S1590)
            {
                _S1591 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S1591 = !_S1491;
                }
                else
                {
                    _S1591 = false;
                }
            }
            if(_S1591)
            {
                return _S1175;
            }
            if(viewed_1)
            {
                float3  _S1592 = throughput_9 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf));
                float _S1593 = (&lobe_5)->pdf;
                throughput_10 = _S1592;
                sky_pdf_2 = _S1593;
            }
            else
            {
                float3  _S1594 = throughput_9 * max_0((&lobe_5)->throughput, _S1174);
                throughput_10 = _S1594;
                sky_pdf_2 = density_6;
            }
            bool _S1595;
            if(_S1366)
            {
                _S1595 = !_S1380;
            }
            else
            {
                _S1595 = false;
            }
            bool _S1596;
            if(_S1595)
            {
                _S1596 = _S1348;
            }
            else
            {
                _S1596 = false;
            }
            bool _S1597;
            if(_S1596)
            {
                _S1597 = _S1490;
            }
            else
            {
                _S1597 = false;
            }
            if(_S1597)
            {
                chain_0 = here_0;
                uint _S1598 = insertBits_0((&chain_0)->path, b_8, 18U, 3U);
                uint _S1599 = _slang_select(nee_0, 1U,0U);
                uint _S1600 = insertBits_0(_S1598, _S1599, 21U, 1U);
                (&chain_0)->path = _S1600;
                float _S1601 = (&chain_0)->jac * (&lobe_5)->pdf;
                (&chain_0)->jac = _S1601;
                (&chain_0)->dir = throughput_8;
                chain_throughput_1 = throughput_10;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            FKSurface _S1602 = surface_12;
            Vertex _S1603 = Vertex_x24init_0(_S1491, b_8, (&lobe_5)->pdf, (F32_abs((dot_0(surface_12.geometry_n, throughput_8)))), is_inside_6);
            prev_0 = _S1603;
            float _S1604 = (&lobe_5)->pdf;
            bool _S1605 = b_8 == 1U;
            bool _S1606;
            if(_S1605)
            {
                _S1606 = (_S1352.x) == (_S1352.y);
            }
            else
            {
                _S1606 = false;
            }
            float sky_pdf_3 = _slang_select(_S1606, sky_pdf_0,_S1604);
            float _S1607 = _slang_select(_S1357, 0.0f,sky_pdf_3);
            float _S1608 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * (&lobe_5)->pdf))))), (3.14159274101257324f)));
            bool _S1609 = !_S1481;
            float _S1610 = _slang_select(_S1609, _S1608,0.0f);
            float _S1611 = spread_1 + _S1610;
            bool _S1612;
            if(refracted_4)
            {
                _S1612 = !_S1487;
            }
            else
            {
                _S1612 = false;
            }
            bool is_inside_7;
            if(_S1612)
            {
                bool _S1613 = !is_inside_6;
                is_inside_7 = _S1613;
            }
            else
            {
                is_inside_7 = is_inside_6;
            }
            FKSurface _S1614 = surface_12;
            bool _S1615 = boundsVolume_0(&_S1614);
            bool _S1616;
            if(_S1615)
            {
                _S1616 = !_S1492;
            }
            else
            {
                _S1616 = false;
            }
            if(_S1616)
            {
                FKSurface faced_2 = surface_12;
                float3  _S1617 = - _S1602.geometry_n;
                float3  _S1618 = _slang_select(turned_1, _S1617,_S1602.geometry_n);
                (&faced_2)->geometry_n = _S1618;
                FKMedium _S1619 = Medium_x24init_0(scatter_in_0, extinction_in_0, g_in_0);
                FKMedium _S1620 = (fcptOutsideMedium((hit_4)));
                FKSurface _S1621 = faced_2;
                FKMedium _S1622 = _S1619;
                FKMedium _S1623 = _S1620;
                MediumSides _S1624 = mediumSides_0(&_S1621, &_S1622, filling_2, (&ray_2)->unit_direction, &_S1623);
                bool _S1625 = ((dot_0(throughput_8, _S1602.geometry_n)) > 0.0f) == ((dot_0(_S1602.geometry_n, (&faced_2)->geometry_n)) > 0.0f);
                float3  _S1626 = _slang_select(_S1625, _S1624.front.scatter,_S1624.behind.scatter);
                scatter_in_0 = _S1626;
                float3  _S1627 = _slang_select(_S1625, _S1624.front.extinction,_S1624.behind.extinction);
                extinction_in_0 = _S1627;
                float _S1628 = _slang_select(_S1625, _S1624.front.g,_S1624.behind.g);
                g_in_0 = _S1628;
                uint _S1629 = _S1624.fillings.x;
                uint _S1630 = _S1624.fillings.y;
                uint _S1631 = _slang_select(_S1625, _S1630,_S1629);
                bool _S1632 = (fcptVaryingUsed());
                uint _S1633 = _slang_select(_S1632, _S1631,4294967295U);
                filling_2 = _S1633;
            }
            (&ray_2)->unit_direction = throughput_8;
            bool _S1634 = !_S1492;
            if(_S1634)
            {
                FKSurface _S1635 = surface_12;
                float _S1636 = _slang_select(straight_0, 0.0f,_S1635.geometry_offset);
                float3  _S1637 = - _S1350.smooth_n;
                bool _S1638 = is_inside_7 != _S1487;
                float3  _S1639 = _slang_select(_S1638, _S1637,_S1350.smooth_n);
                float3  _S1640 = (&ray_2)->origin + make_float3 (_S1636) * _S1639;
                (&ray_2)->origin = _S1640;
            }
            throughput_9 = throughput_10;
            chain_throughput_0 = chain_throughput_1;
            density_6 = sky_pdf_2;
            passes_0 = _S1492;
            viewed_1 = _S1485;
            sky_pdf_2 = _S1607;
            spread_4 = _S1611;
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
        if(_S1366)
        {
            if(_S1316)
            {
                float3  _S1641 = throughput_9 * emission_1;
                Reservoir candidate_8 = chain_0;
                uint _S1642 = extractBits_0((&chain_0)->path, 10U, 2U);
                bool _S1643 = _S1642 == 1U;
                if(_S1643)
                {
                    float3  _S1644 = safeDivide(_S1641, chain_throughput_0);
                    (&candidate_8)->radiance = _S1644;
                }
                Reservoir _S1645 = withEnd(candidate_8, 2U, b_5, _S1641);
                offer(sel_7, _S1645, _S1641 * make_float3 (scale_3) / make_float3 (density_6));
            }
            if(_S1316)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = scatter_2;
            }
            if(refracted_4)
            {
                float _S1646 = survivalProbability(throughput_9, density_6);
                density_7 = _S1646;
            }
            else
            {
                density_7 = 1.0f;
            }
            uint _S1647 = stream(_S1202, b_5 + 128U);
            Random _S1648 = pcg(_S1647);
            bool _S1649 = density_7 < (_S1648.value);
            if(_S1649)
            {
                wrong_side_0 = true;
            }
            else
            {
                uint _S1650 = (fcptMaxBounces());
                wrong_side_0 = b_5 >= _S1650;
            }
            if(wrong_side_0)
            {
                break;
            }
            float _S1651 = density_6 * density_7;
            density_7 = _S1651;
        }
        else
        {
            density_7 = density_6;
        }
        uint _S1652 = layer_0 ^ 1U;
        uint _S1653 = _slang_select(passes_0, _S1652,0U);
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
            uint _S1654 = b_8 + 1U;
            b_5 = _S1654;
            layer_0 = _S1653;
            continue;
        }
        FKRay _S1655 = ray_2;
        float _S1656 = distance_1(reconnection_0, (&ray_2)->origin) * 1.0010000467300415f;
        if(replay_1)
        {
            refracted_4 = _S1390;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            wrong_side_0 = _S1179 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S1657 = _slang_select(wrong_side_0, _S1656,4.294967296e+09f);
        bool _S1658 = !_S1357;
        if(straight_0)
        {
            _S1435 = true;
        }
        else
        {
            _S1435 = _S1357;
        }
        FKHit _S1659;
        if(_S1435)
        {
            _S1659 = hit_4;
        }
        else
        {
            _S1659 = _S1407;
        }
        FKHit _S1660 = (fcptTraverseInstanceBVH((_S1655), (_S1323), (_S1657), (_S1658), (_S1659), (viewed_1)));
        hit_4 = _S1660;
        if(replay_1)
        {
            _S1436 = _S1390;
        }
        else
        {
            _S1436 = false;
        }
        if(_S1436)
        {
            _S1480 = _S1179 == 1U;
        }
        else
        {
            _S1480 = false;
        }
        if(_S1480)
        {
            _S1481 = ((&hit_4)->instance_index) == (_S1191.instance_index);
        }
        else
        {
            _S1481 = false;
        }
        if(_S1481)
        {
            _S1482 = ((&hit_4)->triangle_index) == (_S1191.triangle_index);
        }
        else
        {
            _S1482 = false;
        }
        if(_S1482)
        {
            (&hit_4)->uv = _S1191.uv;
            float _S1661 = distance_1(reconnection_0, (&ray_2)->origin);
            (&hit_4)->distance = _S1661;
        }
        if(replay_1)
        {
            _S1483 = _S1390;
        }
        else
        {
            _S1483 = false;
        }
        if(_S1483)
        {
            _S1484 = _S1179 == 3U;
        }
        else
        {
            _S1484 = false;
        }
        if(_S1484)
        {
            _S1485 = ((&hit_4)->instance_index) != 4294967295U;
        }
        else
        {
            _S1485 = false;
        }
        if(_S1485)
        {
            return _S1175;
        }
        Reservoir _S1662 = chain_0;
        uint _S1663 = filling_2;
        for(;;)
        {
            bool _S1664 = (fcptVaryingUsed());
            if(_S1664)
            {
                _S1486 = _S1663 != 4294967295U;
            }
            else
            {
                _S1486 = false;
            }
            float _S1665;
            if(_S1486)
            {
                float _S1666 = (fcptMajorant((_S1663)));
                _S1665 = _S1666;
            }
            else
            {
                _S1665 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
            }
            if(replay_1)
            {
                _S1487 = _S1390;
            }
            else
            {
                _S1487 = false;
            }
            if(_S1487)
            {
                _S1488 = _S1179 == 1U;
            }
            else
            {
                _S1488 = false;
            }
            if(_S1488)
            {
                _S1489 = _S1665 > 0.0f;
            }
            else
            {
                _S1489 = false;
            }
            if(_S1489)
            {
                ended_0 = _S1175;
                sky_pdf_1 = sky_pdf_2;
                spread_2 = spread_4;
                width_4 = width_3;
                density_3 = density_7;
                throughput_10 = throughput_9;
                b_8 = b_5;
                _S1490 = true;
                break;
            }
            bool _S1667 = (&prev_0)->rough;
            if(_S1667)
            {
                _S1490 = !(_S1665 > 0.0f);
            }
            else
            {
                _S1490 = false;
            }
            (&prev_0)->rough = _S1490;
            uint _S1668 = b_5 + 320U;
            bool _S1669 = b_5 == 4294967295U;
            uint _S1670 = _slang_select(_S1669, 384U,_S1668);
            uint _S1671 = stream(_S1202, _S1670);
            uint tracking_1 = _S1671;
            weight_1 = throughput_3;
            glowed_0 = _S1174;
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
                    _S1173 = int(2);
                    break;
                }
                uint _S1672 = b_8 + 320U;
                bool _S1673 = b_8 == 4294967295U;
                uint _S1674 = _slang_select(_S1673, 384U,_S1672);
                uint _S1675 = stream(_S1202, _S1674);
                Random _S1676 = pcg(_S1675);
                float _S1677 = - (F32_log((1.0f - _S1676.value))) / _S1665;
                if(_S1486)
                {
                    float3  _S1678 = (&ray_2)->origin;
                    float3  _S1679 = (&ray_2)->unit_direction;
                    float _S1680 = (&hit_4)->distance;
                    uint _S1681 = _slang_select(_S1673, 0U,b_8);
                    uint _S1682 = (&prev_0)->lobe;
                    uint _S1683 = _slang_select(_S1673, 3U,_S1682);
                    float _S1684 = (fcptTrackMedium((_S1663), (_S1678), (_S1679), (_S1680), (&tracking_1), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1681), (_S1683), (_S1673)));
                    spread_3 = _S1684;
                }
                else
                {
                    spread_3 = _S1677;
                }
                bool _S1685 = !(spread_3 < ((&hit_4)->distance));
                if(_S1685)
                {
                    _S1173 = int(2);
                    break;
                }
                if(_S1486)
                {
                    _S1491 = _S1366;
                }
                else
                {
                    _S1491 = false;
                }
                if(_S1491)
                {
                    float3  _S1686 = throughput_10 * glowed_0 / make_float3 (density_3);
                    float3  _S1687 = sel_7->glow + _S1686;
                    sel_7->glow = _S1687;
                }
                else
                {
                }
                glowed_0 = _S1174;
                uint b_9 = b_8 + 1U;
                float3  _S1688 = (&ray_2)->origin + make_float3 (spread_3) * (&ray_2)->unit_direction;
                (&ray_2)->origin = _S1688;
                float3  _S1689 = flightWeight_0(scatter_in_0, extinction_in_0, _S1665, spread_3, true);
                float3  _S1690 = weight_1;
                float3  _S1691 = _slang_select(_S1486, _S1690,_S1689);
                float3  throughput_11 = throughput_10 * _S1691;
                uint _S1692 = stream(_S1202, b_9 + 320U);
                tracking_1 = _S1692;
                weight_1 = throughput_3;
                float width_7 = width_4 + spread_2 * spread_3;
                float _S1693 = spread_2 + 3.14159274101257324f;
                if(_S1366)
                {
                    _S1492 = true;
                }
                else
                {
                    bool _S1694 = b_9 == _S1190;
                    if(_S1694)
                    {
                        _S1492 = !_S1486;
                    }
                    else
                    {
                        _S1492 = false;
                    }
                }
                TreeSample light_4;
                if(_S1492)
                {
                    float3  _S1695 = (&ray_2)->origin;
                    float3  _S1696 = (&ray_2)->unit_direction;
                    float3  _S1697 = (&ray_2)->unit_direction;
                    uint _S1698 = stream(_S1202, b_9 + 64U);
                    float3  _S1699 = extinction_in_0;
                    float3  _S1700 = extinction_in_0;
                    uint2  _S1701 = make_uint2 (_S1663);
                    float3  _S1702 = (&ray_2)->unit_direction;
                    uint _S1703 = arrivalLobe_0(b_9, (&prev_0)->lobe);
                    FKHit _S1704 = _S1407;
                    ShadowContext _S1705 = ShadowContext_x24init_0(_S1699, _S1700, _S1701, _S1702, b_9, _S1703, false, spread_3, width_7, &_S1704, false);
                    ShadowContext _S1706 = _S1705;
                    TreeSample _S1707 = sampleLightTree_0(_S1695, _S1696, _S1697, 0.0f, true, _S1698, &_S1706);
                    light_4 = _S1707;
                }
                else
                {
                    light_4 = _S1404;
                }
                float _S1708 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_4.dir));
                uint _S1709 = (fcptMaxBounces());
                bool _S1710 = b_9 < _S1709;
                if(_S1710)
                {
                    _S1493 = (light_4.density) > 0.0f;
                }
                else
                {
                    _S1493 = false;
                }
                float _S1711 = _slang_select(_S1493, _S1708,0.0f);
                float3  _S1712 = throughput_11 * light_4.radiance;
                float _S1713 = powerHeuristic(light_4.density, _S1711);
                float3  _S1714 = _S1712 * make_float3 (_S1708 * _S1713);
                float3  _S1715 = _slang_select(_S1492, _S1714,_S1174);
                if(replay_1)
                {
                    _S1494 = b_9 == _S1190;
                }
                else
                {
                    _S1494 = false;
                }
                if(_S1494)
                {
                    bool _S1716 = _S1179 == 2U;
                    if(_S1716)
                    {
                        float _S1717 = rgb_to_greyscale(_S1715);
                        _S1495 = _S1717 > 0.0f;
                    }
                    else
                    {
                        _S1495 = false;
                    }
                    if(_S1495)
                    {
                        Shift _S1718 = Shift_x24init_0(_S1715, 1.0f);
                        _S1173 = int(1);
                        ended_0 = _S1718;
                        spread_3 = _S1693;
                        width_5 = width_7;
                        throughput_8 = throughput_11;
                        b_6 = b_9;
                        break;
                    }
                    _S1173 = int(1);
                    ended_0 = _S1175;
                    spread_3 = _S1693;
                    width_5 = width_7;
                    throughput_8 = throughput_11;
                    b_6 = b_9;
                    break;
                }
                if(_S1366)
                {
                    Reservoir candidate_9 = _S1662;
                    uint _S1719 = extractBits_0(_S1662.path, 10U, 2U);
                    bool _S1720 = _S1719 == 1U;
                    if(_S1720)
                    {
                        float3  _S1721 = safeDivide(_S1715, chain_throughput_0);
                        (&candidate_9)->radiance = _S1721;
                    }
                    else
                    {
                        uint _S1722 = insertBits_0(0U, b_9 + 1U, 5U, 5U);
                        uint _S1723 = insertBits_0(_S1722, 2U, 10U, 2U);
                        (&candidate_9)->path = _S1723;
                    }
                    Reservoir _S1724 = withEnd(candidate_9, 0U, b_9, _S1715);
                    offer(sel_7, _S1724, _S1715 * make_float3 (scale_3) / make_float3 (density_3));
                    float _S1725 = survivalProbability(throughput_11, density_3);
                    uint _S1726 = stream(_S1202, b_9 + 128U);
                    Random _S1727 = pcg(_S1726);
                    bool _S1728 = _S1725 < (_S1727.value);
                    if(_S1728)
                    {
                        _S1495 = true;
                    }
                    else
                    {
                        uint _S1729 = (fcptMaxBounces());
                        _S1495 = b_9 >= _S1729;
                    }
                    if(_S1495)
                    {
                        _S1173 = int(1);
                        ended_0 = _S1175;
                        spread_3 = _S1693;
                        width_5 = width_7;
                        throughput_8 = throughput_11;
                        b_6 = b_9;
                        break;
                    }
                    float _S1730 = density_3 * _S1725;
                    density_3 = _S1730;
                }
                else
                {
                }
                float phase_pdf_1 = 0.0f;
                uint _S1731 = stream(_S1202, b_9);
                float3  _S1732 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1731, &phase_pdf_1);
                (&ray_2)->unit_direction = _S1732;
                NEEVertex _S1733 = NEEVertex_x24init_0(false, phase_pdf_1, (&ray_2)->origin, _S1174, (&ray_2)->origin);
                nee_vertex_0 = _S1733;
                Vertex _S1734 = Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_5);
                prev_0 = _S1734;
                float _S1735 = (&prev_0)->pdf;
                FKRay _S1736 = ray_2;
                FKHit _S1737 = (fcptTraverseInstanceBVH((_S1736), (true), (4.294967296e+09f), (false), (_S1407), (false)));
                hit_4 = _S1737;
                b_8 = b_9;
                throughput_10 = throughput_11;
                spread_2 = _S1693;
                width_4 = width_7;
                sky_pdf_1 = _S1735;
            }
            if(_S1173 != int(2))
            {
                spread_2 = spread_3;
                width_4 = width_5;
                throughput_10 = throughput_8;
                b_8 = b_6;
                _S1490 = true;
                break;
            }
            ended_0 = _S1175;
            _S1490 = false;
            break;
        }
        if(_S1490)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S1491 = b_8 == b_5;
        }
        else
        {
            _S1491 = false;
        }
        bool _S1738 = ((&hit_4)->instance_index) == 4294967295U;
        if(_S1738)
        {
            bool _S1739 = !(&nee_vertex_0)->none;
            float _S1740 = _slang_select(_S1739, sky_pdf_1,0.0f);
            float _S1741 = escapeWeight_0(_S1740, (&ray_2)->unit_direction);
            float3  _S1742 = environment_0((&ray_2)->unit_direction, b_8, (&prev_0)->lobe);
            float3  _S1743 = throughput_10 * _S1742;
            if(replay_1)
            {
                bool _S1744 = b_8 == _S1190;
                if(_S1744)
                {
                    passes_0 = _S1179 == 3U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(_S1743 * make_float3 (_S1741) / make_float3 (r_8->jac), density_3 / r_8->jac);
                }
                if(_S1189)
                {
                    passes_0 = _S1186;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = b_8 == _S1177;
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
                    return Shift_x24init_0(_S1743 * make_float3 (_S1741), 1.0f);
                }
                return _S1175;
            }
            Reservoir candidate_10 = chain_0;
            uint _S1745 = extractBits_0((&chain_0)->path, 10U, 2U);
            bool _S1746 = _S1745 == 1U;
            if(_S1746)
            {
                uint _S1747 = extractBits_0((&chain_0)->path, 5U, 5U);
                bool _S1748 = _S1747 == b_8;
                float _S1749 = _slang_select(_S1748, 1.0f,_S1741);
                float3  _S1750 = safeDivide(_S1743 * make_float3 (_S1749), chain_throughput_0);
                (&candidate_10)->radiance = _S1750;
            }
            else
            {
                bool _S1751 = (&prev_0)->rough;
                if(_S1751)
                {
                    uint _S1752 = insertBits_0(0U, b_8 + 1U, 5U, 5U);
                    uint _S1753 = insertBits_0(_S1752, 3U, 10U, 2U);
                    uint _S1754 = insertBits_0(_S1753, (&prev_0)->lobe, 15U, 3U);
                    bool _S1755 = (&prev_0)->inside;
                    uint _S1756 = _slang_select(_S1755, 1U,0U);
                    uint _S1757 = insertBits_0(_S1754, _S1756, 22U, 1U);
                    (&candidate_10)->path = _S1757;
                    (&candidate_10)->jac = (&prev_0)->pdf;
                    (&candidate_10)->dir = (&ray_2)->unit_direction;
                }
            }
            float3  _S1758 = _S1743 * make_float3 (_S1741);
            Reservoir _S1759 = withEnd(candidate_10, 3U, b_8, _S1758);
            offer(sel_7, _S1759, _S1758 * make_float3 (scale_3) / make_float3 (density_3));
            break;
        }
        float3  _S1760 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
        (&ray_2)->origin = _S1760;
        bool _S1761 = (fcptVaryingUsed());
        if(_S1761)
        {
            _S1492 = filling_2 != 4294967295U;
        }
        else
        {
            _S1492 = false;
        }
        if(_S1492)
        {
            if(_S1366)
            {
                float3  _S1762 = throughput_10 * glowed_0 / make_float3 (density_3);
                float3  _S1763 = sel_7->glow + _S1762;
                sel_7->glow = _S1763;
            }
            float3  _S1764 = throughput_10 * weight_1;
            throughput_8 = _S1764;
        }
        else
        {
            float3  _S1765 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
            float3  _S1766 = throughput_10 * _S1765;
            throughput_8 = _S1766;
        }
        float _S1767 = width_4 + spread_2 * (&hit_4)->distance;
        viewed_0 = _S1491;
        width_3 = _S1767;
        throughput_2 = throughput_8;
        density_2 = density_3;
        sky_pdf_0 = sky_pdf_1;
        spread_1 = spread_2;
        uint _S1654 = b_8 + 1U;
        b_5 = _S1654;
        layer_0 = _S1653;
    }
    return _S1175;
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
    Random _S1768 = pcg(state_3);
    Random _S1769 = pcg(_S1768.state);
    float _S1770 = 6.28318548202514648f * _S1768.value;
    float _S1771 = (F32_sqrt((-2.0f * clamp_1((F32_log((_S1769.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S1769.state, _S1771 * (F32_cos((_S1770))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_4, float3  value_2)
{
    RandomSphere _S1772;
    (&_S1772)->state = state_4;
    (&_S1772)->value = value_2;
    return _S1772;
}

__device__ RandomSphere random_sphere(uint state_5)
{
    Random _S1773 = normal_distribution(state_5);
    Random _S1774 = normal_distribution(_S1773.state);
    Random _S1775 = normal_distribution(_S1774.state);
    float3  _S1776 = make_float3 (_S1773.value, _S1774.value, _S1775.value);
    float3  _S1777 = ((((_S1776)) * make_float3(rnorm3df(((_S1776)).x, ((_S1776)).y, ((_S1776)).z))));
    return RandomSphere_x24init_0(_S1775.state, _S1777);
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_12)
{
    float3  _S1778 = p1_0 - p0_0;
    float3  _S1779 = p2_0 - p0_0;
    float2  _S1780 = uv1_0 - uv0_0;
    float2  _S1781 = uv2_0 - uv0_0;
    float _S1782 = _S1780.x;
    float _S1783 = _S1781.y;
    float _S1784 = _S1780.y;
    float _S1785 = _S1781.x;
    float _S1786 = _S1782 * _S1783 - _S1784 * _S1785;
    float _S1787 = 1.0f / _S1786;
    float3  t_21 = (_S1778 * make_float3 (_S1783) - _S1779 * make_float3 (_S1784)) * make_float3 (_S1787);
    float3  _S1788 = (_S1779 * make_float3 (_S1782) - _S1778 * make_float3 (_S1785)) * make_float3 (_S1787);
    float3  _S1789 = t_21 - n_12 * make_float3 (dot_0(n_12, t_21));
    float3  t_22 = ((((_S1789)) * make_float3(rnorm3df(((_S1789)).x, ((_S1789)).y, ((_S1789)).z))));
    bool _S1790 = (dot_0(cross_0(n_12, t_22), _S1788)) > 0.0f;
    float3  t_23;
    if(_S1790)
    {
        float3  _S1791 = negate_0(t_22);
        t_23 = _S1791;
    }
    else
    {
        t_23 = t_22;
    }
    float3  _S1792 = cross_0(n_12, t_23);
    return makeMatrix<float, 3, 3> (t_23, _S1792, n_12);
}

__device__ float3  tangentToWorldNormalMap(float3  v_5, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_5, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_4, float3  uvw_0, float3  position_0)
{
    float3  _S1793 = t1_0 - t0_0;
    float3  _S1794 = t2_2 - t0_0;
    float3  _S1795 = t2_2 - t1_0;
    float _S1796 = (F32_min((length_0(_S1793)), ((F32_min((length_0(_S1794)), (length_0(_S1795)))))));
    float3  _S1797 = make_float3 (distance_1(position_0, t0_0), distance_1(position_0, t1_0), distance_1(position_0, t2_2));
    float3  _S1798 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S1799 = dot_0(geometry_n_4, _S1798);
    float3  _S1800 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S1801 = dot_0(geometry_n_4, _S1800);
    float3  _S1802 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S1803 = acos_0(abs_0(make_float3 (_S1799, _S1801, dot_0(geometry_n_4, _S1802))));
    float3  _S1804 = clamp_2(tan_0(_S1803), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_1(dot_0(_S1797 * _S1804, uvw_0), 0.0f, _S1796 * 0.125f);
}

__device__ float3  straightThrough(float3  dir_14, float3  n_13, BSDFMaterial material_23)
{
    float3  _S1805 = negate_0(dir_14);
    float _S1806 = sign_0(dot_0(n_13, _S1805));
    float3  _S1807 = n_13 * make_float3 (_S1806);
    AnisotropicFrame _S1808 = anisotropicFrame(material_23, _S1807);
    bool _S1809 = (_S1808.alphas.x) > 0.0f;
    if(_S1809)
    {
        float _S1810 = material_23.transmission * (1.0f - material_23.metallic);
        float3  _S1811 = negate_0(_S1807);
        float3  _S1812 = anisotropicLocal(dir_14, _S1808.tangent, _S1811);
        float _S1813 = anisotropicG1(_S1812, _S1808.alphas);
        return make_float3 (_S1810 * _S1813) * material_23.albedo;
    }
    float _S1814 = material_23.transmission * (1.0f - material_23.metallic);
    float _S1815 = material_23.roughness;
    float _S1816 = smithG1(_S1815 * _S1815, (F32_abs((dot_0(n_13, dir_14)))));
    return make_float3 (_S1814 * _S1816) * material_23.albedo;
}

__device__ float hairRow(float3  in_dir_11, float3  t_24, float3  out_dir_3, uint p_13, float w_2, float alpha_20, uint nt_0)
{
    uint _S1817 = p_13 % 4U;
    float _S1818 = w_2 * HAIR_WIDTHS_0[_S1817];
    float _S1819 = (F32_asin((clamp_1(dot_0(out_dir_3, t_24), -1.0f, 1.0f)))) - (F32_asin((clamp_1(dot_0(in_dir_11, t_24), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S1817] * alpha_20;
    return ((F32_asinh((_S1819 / _S1818))) / (F32_asinh((3.14159274101257324f / _S1818))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_12, float3  t_25, float3  out_dir_4, uint np_0)
{
    float3  _S1820 = worldToTangent(out_dir_4, t_25);
    float3  _S1821 = worldToTangent(in_dir_12, t_25);
    return (F32_frac((((F32_atan2((_S1820.z), (_S1820.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S1821.z), (1.17549435082228751e-38f - _S1821.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_13, float3  t_26, uint p_14, float row_0, float column_0, float w_3, float alpha_21, uint nt_1, uint np_1)
{
    float3  _S1822 = worldToTangent(in_dir_13, t_26);
    uint _S1823 = p_14 % 4U;
    float _S1824 = w_3 * HAIR_WIDTHS_0[_S1823];
    float _S1825 = (F32_asin((clamp_1(dot_0(in_dir_13, t_26), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S1823] * alpha_21 + _S1824 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S1824))))));
    float _S1826 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S1822.z), (1.17549435082228751e-38f - _S1822.x)));
    float _S1827 = (F32_cos((_S1825)));
    float3  _S1828 = tangentToWorld(make_float3 (_S1827 * (F32_cos((_S1826))), (F32_sin((_S1825))), _S1827 * (F32_sin((_S1826)))), t_26);
    return _S1828;
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_14, BSDFMaterial material_24, float coverage_1)
{
    float3  _S1829;
    if((material_24.ior) == 1.0f)
    {
        float3  _S1830 = straightThrough(toward_1, n_14, material_24);
        _S1829 = _S1830;
    }
    else
    {
        _S1829 = make_float3 (0.0f);
    }
    return _S1829 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ Shift walk_hook(Domain dom_8, Reservoir r_9, bool replay_2, float scale_4, Selection * sel_8)
{
    Domain _S1831 = dom_8;
    Reservoir _S1832 = r_9;
    Shift _S1833 = walk_0(&_S1831, &_S1832, replay_2, scale_4, sel_8);
    return _S1833;
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
