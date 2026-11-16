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

static __device__ bool previousValid_0(int2  q_1)
{
    bool _S80 = all_0(q_1 >= make_int2 (int(0)));
    bool _S81;
    if(_S80)
    {
        uint2  _S82 = (fcptRenderSize());
        int2  _S83 = make_int2 ((int)_S82.x, (int)_S82.y);
        _S81 = all_0(q_1 < _S83);
    }
    else
    {
        _S81 = false;
    }
    if(_S81)
    {
        uint4  _S84 = (fcptReservoirPrevious((q_1), (0U)));
        _S81 = (U32_asfloat((_S84.w))) > 0.0f;
    }
    else
    {
        _S81 = false;
    }
    return _S81;
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
    bool _S85 = all_1((a_0->x0) == (b_0->x0));
    bool _S86;
    if(_S85)
    {
        _S86 = ((&a_0->hit)->instance_index) == ((&b_0->hit)->instance_index);
    }
    else
    {
        _S86 = false;
    }
    if(_S86)
    {
        _S86 = ((&a_0->hit)->triangle_index) == ((&b_0->hit)->triangle_index);
    }
    else
    {
        _S86 = false;
    }
    if(_S86)
    {
        _S86 = all_0(((&a_0->hit)->uv) == ((&b_0->hit)->uv));
    }
    else
    {
        _S86 = false;
    }
    return _S86;
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

static __device__ int2  temporalNeighbor_0(int2  p_4, Domain * dom_2, uint seed_1)
{
    bool _S87 = previousValid_0(p_4);
    bool _S88;
    if(_S87)
    {
        Domain _S89 = (fcptPreviousDomain((p_4), (seed_1)));
        Domain _S90 = _S89;
        bool _S91 = sameDomain_0(&_S90, dom_2);
        _S88 = _S91;
    }
    else
    {
        _S88 = false;
    }
    if(_S88)
    {
        return p_4;
    }
    uint _S92 = (&dom_2->hit)->instance_index;
    bool _S93 = ((&dom_2->hit)->instance_index) == 4294967295U;
    if(_S93)
    {
        return make_int2 (int(-1));
    }
    float3  _S94 = dom_2->x1;
    float2  _S95 = (fcptPixelOf((dom_2->x1), (true)));
    float2  _S96 = floor_0(_S95);
    int2  _S97 = make_int2 ((int)_S96.x, (int)_S96.y);
    bool _S98 = previousValid_0(_S97);
    bool _S99 = !_S98;
    if(_S99)
    {
        return make_int2 (int(-1));
    }
    uint4  _S100 = (fcptReservoirPrevious((_S97), (0U)));
    Domain _S101 = (fcptPreviousDomain((_S97), (_S100.x)));
    bool _S102 = (_S101.hit.instance_index) == _S92;
    if(_S102)
    {
        float _S103 = distance_1(_S101.x1, _S94);
        float _S104 = (&dom_2->hit)->distance * 8.0f;
        uint2  _S105 = (fcptRenderSize());
        _S88 = _S103 <= (_S104 / float(_S105.x));
    }
    else
    {
        _S88 = false;
    }
    if(_S88)
    {
        return _S97;
    }
    int2  _S106 = p_4 + _S97;
    float2  _S107 = make_float2 ((float)_S106.x, (float)_S106.y);
    float2  _S108 = _S107 + make_float2 (1.0f);
    float2  _S109 = (fcptPixelOf((_S101.x1), (false)));
    float2  _S110 = floor_0(_S108 - _S109);
    int2  _S111 = make_int2 ((int)_S110.x, (int)_S110.y);
    int2  _S112 = make_int2 (int(-1));
    bool _S113 = previousValid_0(_S111);
    int2  _S114 = _slang_select(_S113, _S111,_S112);
    return _S114;
}

static __device__ bool temporalIdentity_0(uint t_6, Domain * source_0, Domain * target_1)
{
    bool _S115 = sameDomain_0(source_0, target_1);
    bool _S116;
    if(_S115)
    {
        bool _S117 = (fcptSceneUnchanged());
        if(_S117)
        {
            _S116 = true;
        }
        else
        {
            bool _S118 = t_6 == 1U;
            if(_S118)
            {
                bool _S119 = (fcptPreviousScenes());
                _S116 = !_S119;
            }
            else
            {
                _S116 = false;
            }
        }
    }
    else
    {
        _S116 = false;
    }
    return _S116;
}

static __device__ bool temporalJob_0(int2  p_5, uint t_7, ShiftJob * job_2, bool target_2)
{
    Reservoir _S120 = (fcptLoadReservoirInitial((p_5)));
    float3  _S121 = make_float3 (0.0f);
    FKHit _S122 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S123 = Domain_x24init_0(_S121, _S121, &_S122, 0.0f, 0.0f);
    Domain dom_3 = _S123;
    bool _S124 = t_7 > 1U;
    bool _S125;
    if(_S124)
    {
        _S125 = true;
    }
    else
    {
        bool _S126 = (fcptStoredDomainInitial((p_5), (_S120.seed), (&dom_3)));
        _S125 = !_S126;
    }
    if(_S125)
    {
        return false;
    }
    Domain _S127 = dom_3;
    int2  _S128 = temporalNeighbor_0(p_5, &_S127, _S120.seed);
    bool _S129 = (_S128.x) < int(0);
    if(_S129)
    {
        return false;
    }
    bool _S130 = t_7 == 0U;
    if(_S130)
    {
        Reservoir _S131 = (fcptLoadReservoirPrevious((_S128)));
        job_2->r = _S131;
        bool _S132 = !target_2;
        if(_S132)
        {
            bool _S133 = (fcptSceneUnchanged());
            _S125 = !_S133;
        }
        else
        {
            _S125 = false;
        }
        if(_S125)
        {
            return ((&job_2->r)->w) > 0.0f;
        }
        bool _S134 = ((&job_2->r)->w) > 0.0f;
        if(_S134)
        {
            bool _S135 = (fcptStoredDomainInitial((p_5), ((&job_2->r)->seed), (&job_2->dom)));
            _S125 = _S135;
        }
        else
        {
            _S125 = false;
        }
        if(_S125)
        {
            Domain _S136 = (fcptPreviousDomain((_S128), ((&job_2->r)->seed)));
            Domain _S137 = _S136;
            Domain _S138 = job_2->dom;
            bool _S139 = temporalIdentity_0(0U, &_S137, &_S138);
            _S125 = !_S139;
        }
        else
        {
            _S125 = false;
        }
        return _S125;
    }
    job_2->r = _S120;
    bool _S140 = !target_2;
    if(_S140)
    {
        bool _S141 = (fcptSceneUnchanged());
        _S125 = !_S141;
    }
    else
    {
        _S125 = false;
    }
    if(_S125)
    {
        bool _S142 = (fcptPreviousScenes());
        _S125 = _S142;
    }
    else
    {
        _S125 = false;
    }
    if(_S125)
    {
        return ((&job_2->r)->w) > 0.0f;
    }
    Domain _S143 = (fcptPreviousDomain((_S128), (_S120.seed)));
    job_2->dom = _S143;
    bool _S144 = ((&job_2->r)->w) > 0.0f;
    if(_S144)
    {
        Domain _S145 = job_2->dom;
        Domain _S146 = dom_3;
        bool _S147 = temporalIdentity_0(1U, &_S145, &_S146);
        _S125 = !_S147;
    }
    else
    {
        _S125 = false;
    }
    return _S125;
}

static __device__ void temporalBins_0(int2  p_6, FixedArray<uint, 3>  * _S148)
{
    FixedArray<uint, 3>  _S149 = { {
        40U, 40U, 40U
    } };
    FixedArray<uint, 3>  bins_2;
    bins_2[int(0)] = 40U;
    bins_2[int(1)] = 40U;
    bins_2[int(2)] = 40U;
    uint t_8 = 0U;
    for(;;)
    {
        if(t_8 < 2U)
        {
        }
        else
        {
            break;
        }
        ShiftJob _S150 = (ShiftJob{});
        ShiftJob job_3 = _S150;
        bool _S151 = temporalJob_0(p_6, t_8, &job_3, false);
        if(_S151)
        {
            Reservoir _S152 = (&job_3)->r;
            uint _S153 = shiftBin_0(&_S152);
            bins_2[t_8] = _S153;
        }
        uint t_9 = t_8 + 1U;
        t_8 = t_9;
    }
    *_S148 = bins_2;
    return;
}

static __device__ void countShifts_0(FixedArray<uint, 3>  * bins_3, uint local_invocation_index_2)
{
    uint t_10 = 0U;
    for(;;)
    {
        if(t_10 < 3U)
        {
        }
        else
        {
            break;
        }
        uint _S154 = (*bins_3)[t_10];
        bool _S155 = ((*bins_3)[t_10]) < 40U;
        if(_S155)
        {
            uint _S156 = (fcptQueueCountAdd((_S154), (1U)));
        }
        uint t_11 = t_10 + 1U;
        t_10 = t_11;
    }
    return;
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
    FKRay _S157;
    (&_S157)->origin = origin_0;
    (&_S157)->unit_direction = unit_direction_0;
    return _S157;
}

static __device__ float3  skyRadiance_0(float3  origin_1, FKSurface * surface_0, bool is_inside_1, float3  dir_1, ShadowContext * context_0, uint random_state_0)
{
    bool _S158 = wrongSide_0(is_inside_1, false, dir_1, surface_0->geometry_n);
    bool _S159 = is_inside_1 != _S158;
    float _S160 = surface_0->geometry_offset;
    float3  _S161 = surface_0->smooth_n;
    float3  _S162 = - surface_0->smooth_n;
    float3  _S163 = _slang_select(_S159, _S162,_S161);
    FKRay _S164 = Ray_x24init_0(origin_1 + make_float3 (_S160) * _S163, dir_1);
    bool _S165 = (dot_0(context_0->side, dir_1)) > 0.0f;
    float3  _S166 = (fcptEnvMapSample((dir_1), (0U), (3U)));
    float3  _S167 = context_0->extinction_behind;
    float3  _S168 = context_0->extinction_front;
    float3  _S169 = _slang_select(_S165, _S168,_S167);
    uint _S170 = context_0->fillings.x;
    uint _S171 = context_0->fillings.y;
    uint _S172 = _slang_select(_S165, _S171,_S170);
    uint _S173 = context_0->depth;
    uint _S174 = context_0->lobe;
    bool _S175 = context_0->surface;
    bool _S176;
    if(_S175)
    {
        _S176 = !context_0->fiber;
    }
    else
    {
        _S176 = false;
    }
    float _S177 = context_0->length;
    float _S178 = context_0->width;
    FKHit _S179 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    float3  _S180 = (fcptShadowTransmittanceIn((_S164), (4.294967296e+09f), (_S169), (_S172), (random_state_0), (_S173), (_S174), (_S176), (_S177), (_S178), (_S179), (_S179)));
    return _S166 * _S180;
}

static __device__ uint searchCDF_0(uint2  start_4, uint2  step_0, uint count_1, float u_0)
{
    uint _S181 = count_1 - 1U;
    uint low_0 = 0U;
    uint high_0 = _S181;
    for(;;)
    {
        if(low_0 < high_0)
        {
        }
        else
        {
            break;
        }
        uint _S182 = (low_0 + high_0) / 2U;
        float4  _S183 = (fcptEnvironmentCdf((start_4 + step_0 * make_uint2 (_S182))));
        bool _S184 = (_S183.x) > u_0;
        if(_S184)
        {
            high_0 = _S182;
        }
        else
        {
            uint _S185 = _S182 + 1U;
            low_0 = _S185;
        }
    }
    return low_0;
}

static __device__ float3  skyFrame_0(float3  dir_2)
{
    float3  _S186 = make_float3 (- dir_2.x, dir_2.z, dir_2.y);
    bool _S187 = ((true));
    float3  _S188 = _slang_select(_S187, _S186,dir_2);
    return _S188;
}

__device__ float shadowLength(float3  shadow_0)
{
    return length_0(shadow_0) * 0.99989998340606689f;
}

static __device__ float3  lightTransmittance_0(float3  origin_2, float3  smooth_n_0, float geometry_offset_0, float3  light_dir_0, ShadowContext * context_1, uint random_state_1, FKHit * light_0)
{
    float3  _S189 = ((((light_dir_0)) * make_float3(rnorm3df(((light_dir_0)).x, ((light_dir_0)).y, ((light_dir_0)).z))));
    bool _S190 = (dot_0(smooth_n_0, _S189)) < 0.0f;
    if(_S190)
    {
        return make_float3 (0.0f);
    }
    float3  _S191 = make_float3 (geometry_offset_0) * smooth_n_0;
    float3  _S192 = origin_2 + _S191;
    FKRay _S193 = Ray_x24init_0(_S192, _S189);
    bool _S194 = (dot_0(context_1->side, light_dir_0 + _S191)) > 0.0f;
    float _S195 = shadowLength(light_dir_0);
    float3  _S196 = context_1->extinction_behind;
    float3  _S197 = context_1->extinction_front;
    float3  _S198 = _slang_select(_S194, _S197,_S196);
    uint _S199 = context_1->fillings.x;
    uint _S200 = context_1->fillings.y;
    uint _S201 = _slang_select(_S194, _S200,_S199);
    uint _S202 = context_1->depth;
    uint _S203 = context_1->lobe;
    bool _S204 = context_1->surface;
    bool _S205;
    if(_S204)
    {
        _S205 = !context_1->fiber;
    }
    else
    {
        _S205 = false;
    }
    float _S206 = context_1->length;
    float _S207 = context_1->width;
    FKHit _S208;
    if(context_1->fiber)
    {
        _S208 = context_1->own;
    }
    else
    {
        _S208 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    }
    float3  _S209 = (fcptShadowTransmittanceIn((_S193), (_S195), (_S198), (_S201), (random_state_1), (_S202), (_S203), (_S205), (_S206), (_S207), (_S208), (*light_0)));
    return _S209;
}

__device__ float sine(float c_0)
{
    return (F32_sqrt(((F32_max((1.0f - c_0 * c_0), (0.0f))))));
}

__device__ float cosSubClamped(float sin_a_0, float cos_a_0, float sin_b_0, float cos_b_0)
{
    float _S210 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    bool _S211 = cos_a_0 > cos_b_0;
    float _S212 = _slang_select(_S211, 1.0f,_S210);
    return _S212;
}

__device__ float importance(LightNode node_0, float3  p_7, float3  normal_0)
{
    float3  _S213 = (node_0.low + node_0.high) * make_float3 (0.5f);
    float3  _S214 = node_0.high - node_0.low;
    float3  _S215 = p_7 - _S213;
    float3  _S216 = ((((_S215)) * make_float3(rnorm3df(((_S215)).x, ((_S215)).y, ((_S215)).z))));
    float _S217 = dot_0(_S215, _S215);
    float _S218 = dot_0(_S214, _S214) / 4.0f;
    float _S219 = (F32_abs((dot_0(node_0.w, _S216))));
    float _S220 = sine(node_0.cos_theta_o);
    float _S221 = (F32_sqrt(((F32_max((1.0f - _S218 / _S217), (0.0f))))));
    bool _S222 = _S217 < _S218;
    float _S223 = _slang_select(_S222, -1.0f,_S221);
    float _S224 = sine(_S223);
    float _S225 = sine(_S219);
    float _S226 = cosSubClamped(_S225, _S219, _S220, node_0.cos_theta_o);
    float _S227 = sine(_S219);
    float _S228 = _S227 * node_0.cos_theta_o - _S219 * _S220;
    bool _S229 = _S219 > (node_0.cos_theta_o);
    float _S230 = _slang_select(_S229, 0.0f,_S228);
    float _S231 = cosSubClamped(_S230, _S226, _S224, _S223);
    bool _S232 = _S231 <= 0.0f;
    if(_S232)
    {
        return 0.0f;
    }
    float _S233 = - dot_0(_S216, normal_0);
    float _S234 = node_0.phi * _S231 / (F32_max((_S217), (length_0(_S214) / 2.0f)));
    float _S235 = sine(_S233);
    float _S236 = cosSubClamped(_S235, _S233, _S224, _S223);
    bool _S237 = (dot_0(normal_0, normal_0)) == 0.0f;
    float _S238 = _slang_select(_S237, 1.0f,_S236);
    return (F32_max((_S234 * _S238), (0.0f)));
}

__device__ __forceinline__ float childShare(LightNode first_0, LightNode second_0, float3  p_8, float3  normal_1, uint child_0)
{
    float _S239 = importance(first_0, p_8, normal_1);
    float _S240 = importance(second_0, p_8, normal_1);
    float2  _S241 = make_float2 (_S239, _S240);
    float _S242 = _slang_vector_get_element(_S241, child_0) / (_S239 + _S240);
    bool _S243 = _slang_vector_get_element(_S241, child_0) > 0.0f;
    float _S244 = _slang_select(_S243, _S242,0.0f);
    return _S244;
}

__device__ float sphereDensity(float3  center_0, float radius_0, float3  p_9)
{
    float3  _S245 = center_0 - p_9;
    float _S246 = radius_0 * radius_0 / dot_0(_S245, _S245);
    bool _S247 = _S246 >= 1.0f;
    if(_S247)
    {
        return 0.07957746833562851f;
    }
    return (1.0f + (F32_sqrt((1.0f - _S246)))) / (6.28318548202514648f * _S246);
}

static __device__ float3  cross_0(float3  left_0, float3  right_0)
{
    float _S248 = left_0.y;
    float _S249 = right_0.z;
    float _S250 = left_0.z;
    float _S251 = right_0.y;
    float _S252 = right_0.x;
    float _S253 = left_0.x;
    return make_float3 (_S248 * _S249 - _S250 * _S251, _S250 * _S252 - _S253 * _S249, _S253 * _S251 - _S248 * _S252);
}

__device__ float solidAngle(float probability_0, float3  normal_2, float3  toward_0)
{
    return 2.0f * probability_0 * (F32_pow((length_0(toward_0)), (3.0f))) / (F32_abs((dot_0(normal_2, toward_0))));
}

static __device__ float lightPdf_0(float3  origin_3, float3  smooth_n_1, float3  start_5, uint j_0, float3  light_point_0)
{
    bool _S254 = j_0 == 4294967295U;
    if(_S254)
    {
        return 0.0f;
    }
    uint4  _S255 = (fcptLightTrail((j_0)));
    uint2  _S256 = uint2 {_S255.x, _S255.y};
    uint n_0 = 0U;
    uint2  trail_0 = _S256;
    float probability_1 = 1.0f;
    for(;;)
    {
        uint4  _S257 = (fcptLightNode((n_0)));
        if((_S257.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S258 = (fcptLightSecond((n_0)));
        uint _S259 = n_0 + 1U;
        LightNode _S260 = (fcptLightBounds((_S259)));
        LightNode _S261 = (fcptLightBounds((_S258)));
        uint _S262 = trail_0.x;
        uint _S263 = _S262 & 1U;
        float _S264 = childShare(_S260, _S261, origin_3, smooth_n_1, _S263);
        float probability_2 = probability_1 * _S264;
        bool _S265 = _S263 == 1U;
        uint _S266 = _slang_select(_S265, _S258,_S259);
        uint _S267 = trail_0.y;
        uint2  _S268 = make_uint2 ((_S262 >> 1U) | (_S267 << 31U), _S267 >> 1U);
        n_0 = _S266;
        trail_0 = _S268;
        probability_1 = probability_2;
    }
    bool _S269 = (fcptSlotLeaf((n_0), (j_0)));
    bool _S270 = !_S269;
    bool _S271;
    if(_S270)
    {
        _S271 = true;
    }
    else
    {
        LightNode _S272 = (fcptLightBounds((n_0)));
        float _S273 = importance(_S272, origin_3, smooth_n_1);
        _S271 = !(_S273 > 0.0f);
    }
    if(_S271)
    {
        _S271 = true;
    }
    else
    {
        bool _S274 = (dot_0(smooth_n_1, smooth_n_1)) > 0.0f;
        if(_S274)
        {
            _S271 = !((dot_0(smooth_n_1, light_point_0 - origin_3)) > 0.0f);
        }
        else
        {
            _S271 = false;
        }
    }
    if(_S271)
    {
        return 0.0f;
    }
    uint4  _S275 = (fcptLightNode((n_0)));
    bool _S276 = (_S275.x) == 2U;
    if(_S276)
    {
        FKLight _S277 = (fcptLight((_S275.y)));
        float _S278 = sphereDensity(_S277.position, _S277.variance, start_5);
        return probability_1 * _S278;
    }
    uint _S279 = _S275.y;
    uint _S280 = (fcptTriangleOffset((_S279)));
    Matrix<float, 3, 3>  _S281 = (fcptWorldTriangle((_S279), (_S280 + _S275.z)));
    float _S282 = solidAngle(probability_1, cross_0(_S281.rows[int(1)] - _S281.rows[int(0)], _S281.rows[int(2)] - _S281.rows[int(0)]), light_point_0 - start_5);
    return _S282;
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
    Random _S283;
    (&_S283)->state = state_0;
    (&_S283)->value = value_0;
    return _S283;
}

__device__ Random pcg(uint state_1)
{
    uint _S284 = hash(state_1);
    float value_1 = float(_S284 >> int(8)) * 5.9604644775390625e-08f;
    return Random_x24init_0(_S284, value_1);
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
    uint2  _S285 = (fcptEnvironmentCdfSize());
    uint2  _S286 = _S285 - make_uint2 (1U, 0U);
    float3  _S287 = skyFrame_0(dir_3);
    float2  _S288 = make_float2 ((F32_atan2((- _S287.z), (- _S287.x))) / 6.28318548202514648f + 0.5f, (F32_acos((clamp_1(_S287.y, -1.0f, 1.0f)))) / 3.14159274101257324f);
    float2  _S289 = make_float2 ((float)_S286.x, (float)_S286.y);
    float2  _S290 = _S288 * _S289;
    uint2  _S291 = make_uint2 ((uint)_S290.x, (uint)_S290.y);
    uint2  _S292 = min_0(_S291, _S286 - make_uint2 (1U));
    float4  _S293 = (fcptEnvironmentCdf((_S292)));
    float _S294 = _S293.y;
    uint _S295 = _S286.x;
    float4  _S296 = (fcptEnvironmentCdf((make_uint2 (_S295, _S292.y))));
    float _S297 = _S294 * _S296.y;
    return _S297 * float(_S295 * _S286.y) / (19.73921012878417969f * length_1(float2 {_S287.x, _S287.z}));
}

static __device__ float3  negate_0(float3  x_13)
{
    return - x_13;
}

static __device__ float sign_0(float e_1)
{
    bool _S298 = e_1 < 0.0f;
    float _S299 = _slang_select(_S298, -1.0f,0.0f);
    bool _S300 = e_1 > 0.0f;
    float _S301 = _slang_select(_S300, 1.0f,_S299);
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
    1.03603994846343994f, 1.04969000816345215f, 1.02470004558563232f, 1.01461005210876465f, 1.00961005687713623f, 1.00680005550384521f, 1.0050499439239502f, 1.00390005111694336f, 1.00312995910644531f, 1.00258004665374756f, 1.00213003158569336f, 1.0017399787902832f, 1.00138998031616211f, 1.00112998485565186f, 1.00097000598907471f, 1.00092995166778564f, 1.00098001956939697f, 1.00108003616333008f, 1.0011899471282959f, 1.00127995014190674f, 1.0013200044631958f, 1.00134003162384033f, 1.00133001804351807f, 1.00130999088287354f, 0.90734100341796875f, 0.98275798559188843f, 0.98386698961257935f, 0.98714500665664673f, 0.98988902568817139f, 0.99194902181625366f, 0.99348098039627075f, 0.99463999271392822f, 0.99551397562026978f, 0.99620199203491211f, 0.99678301811218262f, 0.99725902080535889f, 0.99762099981307983f, 0.99788099527359009f, 0.99806898832321167f, 0.99822998046875f, 0.9984009861946106f, 0.99860197305679321f, 0.99882900714874268f, 0.99905097484588623f, 0.99924802780151367f, 0.99941599369049072f, 0.99955397844314575f, 0.99966597557067871f, 0.47049999237060547f, 0.72047901153564453f, 0.82541298866271973f, 0.88024801015853882f, 0.91317099332809448f, 0.93422400951385498f, 0.94845300912857056f, 0.9585450291633606f, 0.96597200632095337f, 0.97161900997161865f, 0.97599798440933228f, 0.97946298122406006f, 0.98225301504135132f, 0.98453700542449951f, 0.98643702268600464f, 0.98803901672363281f, 0.98940402269363403f, 0.99057799577713013f, 0.99159497022628784f, 0.9924740195274353f, 0.99323201179504395f, 0.99394601583480835f, 0.9946179986000061f, 0.99514299631118774f, 0.10339099913835526f, 0.37652701139450073f, 0.58990597724914551f, 0.7168310284614563f, 0.79374098777770996f, 0.8438420295715332f, 0.87787497043609619f, 0.90189200639724731f, 0.919514000415802f, 0.93284100294113159f, 0.94317400455474854f, 0.95135498046875f, 0.95794999599456787f, 0.9633520245552063f, 0.96783697605133057f, 0.97160798311233521f, 0.97481298446655273f, 0.97755998373031616f, 0.97992998361587524f, 0.98198497295379639f, 0.98377299308776855f, 0.98532998561859131f, 0.98668897151947021f, 0.98788100481033325f, 0.00549574987962842f, 0.12130799889564514f, 0.33038300275802612f, 0.50957399606704712f, 0.63582301139831543f, 0.72130399942398071f, 0.78063100576400757f, 0.82337701320648193f, 0.85500001907348633f, 0.87895798683166504f, 0.89755398035049438f, 0.91228801012039185f, 0.92417001724243164f, 0.93390399217605591f, 0.94199001789093018f, 0.94878798723220825f, 0.95456397533416748f, 0.95951497554779053f, 0.96378600597381592f, 0.96749001741409302f, 0.97071200609207153f, 0.97352099418640137f, 0.97597402334213257f, 0.97811698913574219f, 0.00006616840255447f, 0.01978570036590099f, 0.13480900228023529f, 0.30441498756408691f, 0.4568449854850769f, 0.57461702823638916f, 0.66137099266052246f, 0.72547799348831177f, 0.77361601591110229f, 0.81061500310897827f, 0.83951497077941895f, 0.86248302459716797f, 0.88104599714279175f, 0.89627498388290405f, 0.90893799066543579f, 0.91959297657012939f, 0.92865198850631714f, 0.93641901016235352f, 0.94312202930450439f, 0.94893598556518555f, 0.95399397611618042f, 0.95840400457382202f, 0.96225601434707642f, 0.96562099456787109f, 6.08604011631541653e-08f, 0.00167625001631677f, 0.03686590120196342f, 0.14405199885368347f, 0.28643798828125f, 0.41852200031280518f, 0.5268089771270752f, 0.61179697513580322f, 0.67761099338531494f, 0.72897201776504517f, 0.76956802606582642f, 0.80211901664733887f, 0.82861298322677612f, 0.85041999816894531f, 0.86859399080276489f, 0.88391202688217163f, 0.89695101976394653f, 0.90814197063446045f, 0.91780698299407959f, 0.9261929988861084f, 0.933493971824646f, 0.93986201286315918f, 0.94542300701141357f, 0.95028501749038696f, 1.25722999719246609e-12f, 0.00005344190140022f, 0.00689807021990418f, 0.05298750102519989f, 0.15135200321674347f, 0.27379500865936279f, 0.38978201150894165f, 0.48924699425697327f, 0.57068902254104614f, 0.6363450288772583f, 0.68930798768997192f, 0.73230600357055664f, 0.7675589919090271f, 0.79679697751998901f, 0.82128000259399414f, 0.84197902679443359f, 0.85963702201843262f, 0.87481701374053955f, 0.88794499635696411f, 0.89934700727462769f, 0.90928000211715698f, 0.91794902086257935f, 0.92552399635314941f, 0.93214702606201172f, 1.32430000482605838e-19f, 4.34398998550022952e-07f, 0.00078319699969143f, 0.01505979988723993f, 0.06700140237808228f, 0.15685500204563141f, 0.26414799690246582f, 0.36752399802207947f, 0.45892399549484253f, 0.53633898496627808f, 0.60086798667907715f, 0.65432101488113403f, 0.69876497983932495f, 0.73594701290130615f, 0.76730400323867798f, 0.79397499561309814f, 0.8168100118637085f, 0.83649301528930664f, 0.85354900360107422f, 0.86838698387145996f, 0.88132798671722412f, 0.89263200759887695f, 0.90251702070236206f, 0.91116297245025635f, 1.21214998864702984e-29f, 5.61858004566317959e-10f, 0.00004580340100802f, 0.00315008009783924f, 0.02455909922719002f, 0.07877019792795181f, 0.16104799509048462f, 0.25635600090026855f, 0.34949898719787598f, 0.43382999300956726f, 0.50729697942733765f, 0.57010501623153687f, 0.62341398000717163f, 0.66865599155426025f, 0.70718997716903687f, 0.74018502235412598f, 0.76862901449203491f, 0.79324597120285034f, 0.8146439790725708f, 0.83329999446868896f, 0.84960097074508667f, 0.86386102437973022f, 0.87634098529815674f, 0.88726699352264404f, 1.17709071003284634e-43f, 6.58941014274917747e-14f, 1.12094994619837962e-06f, 0.00044787500519305f, 0.00728174997493625f, 0.03418119996786118f, 0.08846849948167801f, 0.16411800682544708f, 0.24980400502681732f, 0.33453500270843506f, 0.41271701455116272f, 0.48244500160217285f, 0.54331201314926147f, 0.59608602523803711f, 0.64167797565460205f, 0.68114197254180908f, 0.71539402008056641f, 0.7452319860458374f, 0.77129900455474854f, 0.79410398006439209f, 0.81407999992370605f, 0.83158797025680542f, 0.846934974193573f, 0.86038398742675781f, 0.0f, 3.5722200588590534e-19f, 8.93677043478646738e-09f, 0.00003873859895975f, 0.00167270004749298f, 0.01264849957078695f, 0.04320650175213814f, 0.09630840271711349f, 0.16610400378704071f, 0.24392600357532501f, 0.32165700197219849f, 0.394569993019104f, 0.46081000566482544f, 0.51976299285888672f, 0.57175701856613159f, 0.61742901802062988f, 0.65750598907470703f, 0.69269400835037231f, 0.72362500429153442f, 0.75082802772521973f, 0.77473902702331543f, 0.79575198888778687f, 0.81420797109603882f, 0.83040601015090942f, 0.0f, 3.95292991891679393e-26f, 1.71184993263961971e-11f, 1.77651998001238098e-06f, 0.0002783710078802f, 0.00388711993582547f, 0.01858510076999664f, 0.05124599859118462f, 0.10246899724006653f, 0.16709500551223755f, 0.23837999999523163f, 0.31022000312805176f, 0.37857699394226074f, 0.44168499112129211f, 0.4988040030002594f, 0.54993897676467896f, 0.59550100564956665f, 0.63594001531600952f, 0.67177599668502808f, 0.70349597930908203f, 0.73152798414230347f, 0.75625097751617432f, 0.77802300453186035f, 0.79716801643371582f, 0.0f, 3.2483199352805935e-35f, 5.40527002565222188e-15f, 3.64182994871953269e-08f, 0.00003074659980484f, 0.00094859098317102f, 0.00691073015332222f, 0.02452139928936958f, 0.05809320136904716f, 0.10707399994134903f, 0.16711099445819855f, 0.23287899792194366f, 0.29971298575401306f, 0.36412099003791809f, 0.42443698644638062f, 0.47984799742698669f, 0.53011900186538696f, 0.57539498805999756f, 0.61597698926925659f, 0.65218400955200195f, 0.6844019889831543f, 0.71295899152755737f, 0.73819798231124878f, 0.7604449987411499f, 0.0f, 0.0f, 1.7447100275121598e-19f, 2.68698008287771017e-10f, 2.01520992959558498e-06f, 0.00017266000213567f, 0.00214895000681281f, 0.01039279997348785f, 0.03002390079200268f, 0.06362999975681305f, 0.11018999665975571f, 0.16611799597740173f, 0.22714599967002869f, 0.2896830141544342f, 0.35065999627113342f, 0.40850698947906494f, 0.46232399344444275f, 0.51169002056121826f, 0.55654400587081909f, 0.59701400995254517f, 0.63333100080490112f, 0.66571998596191406f, 0.69448697566986084f, 0.71991300582885742f, 0.0f, 0.0f, 3.08185990824019565e-25f, 5.37352009676722586e-13f, 6.76860025805581245e-08f, 0.00002156710070267f, 0.00053187098819762f, 0.00379640003666282f, 0.01394980028271675f, 0.03477099910378456f, 0.06777119636535645f, 0.11182600259780884f, 0.16402900218963623f, 0.22092700004577637f, 0.27971801161766052f, 0.33767500519752502f, 0.3932889997959137f, 0.44556498527526855f, 0.493927001953125f, 0.53815799951553345f, 0.57827800512313843f, 0.61434602737426758f, 0.64652997255325317f, 0.67506802082061768f, 0.0f, 0.0f, 1.27565998769738086e-32f, 1.98236004320260421e-16f, 9.54645029693779179e-10f, 1.650769945626962e-06f, 0.00009778440289665f, 0.00114505004603416f, 0.00568277994170785f, 0.01722680032253265f, 0.03851649910211563f, 0.0704336017370224f, 0.11193899810314178f, 0.16071000695228577f, 0.21397699415683746f, 0.2693760097026825f, 0.32457900047302246f, 0.37806499004364014f, 0.42872300744056702f, 0.4758630096912384f, 0.51915699243545532f, 0.55846899747848511f, 0.59376901388168335f, 0.62519502639770508f, 0.0f, 0.0f, 3.7106383335321156e-42f, 7.81385018096993734e-21f, 4.26179013954253172e-12f, 6.59224994592477742e-08f, 0.00001210350001202f, 0.00026765500660986f, 0.00194808002561331f, 0.00754345022141933f, 0.01991299912333488f, 0.04105570167303085f, 0.0715148001909256f, 0.11042399704456329f, 0.15595099329948425f, 0.20584699511528015f, 0.25806799530982971f, 0.31055599451065063f, 0.36178100109100342f, 0.41049200296401978f, 0.45592901110649109f, 0.49765899777412415f, 0.53551197052001953f, 0.56948697566986084f, 0.0f, 0.0f, 0.0f, 1.4501699354155858e-26f, 3.9408500097373126e-15f, 1.07906994450956972e-09f, 8.70304006639344152e-07f, 0.0000440725016233f, 0.0005269440007396f, 0.00279516004957259f, 0.00910075008869171f, 0.02173379994928837f, 0.04219720140099525f, 0.07087449729442596f, 0.10709299892187119f, 0.14939899742603302f, 0.19591200351715088f, 0.24481700360774994f, 0.29424700140953064f, 0.34261700510978699f, 0.38869300484657288f, 0.43174698948860168f, 0.47139298915863037f, 0.50751799345016479f, 0.0f, 0.0f, 0.0f, 3.37722993781223165e-34f, 3.80885988849822355e-19f, 4.90656994200922014e-12f, 2.86603007992880521e-08f, 4.38328015661682002e-06f, 0.00010134100011783f, 0.00081476598279551f, 0.00349242007359862f, 0.01008209958672523f, 0.02243220061063766f, 0.04172819852828979f, 0.06827779859304428f, 0.10154099762439728f, 0.14030000567436218f, 0.18292999267578125f, 0.22785000503063202f, 0.27340999245643616f, 0.31820300221443176f, 0.36118099093437195f, 0.40175101161003113f, 0.43962100148200989f, 0.0f, 0.0f, 0.0f, 9.8090892502737195e-45f, 1.13511000171572082e-24f, 3.09601003078345365e-15f, 2.82900008974351636e-10f, 2.00208006617685896e-07f, 0.00001151220021711f, 0.00016400900494773f, 0.00102415005676448f, 0.00382522004656494f, 0.01021770015358925f, 0.02173330076038837f, 0.03936100006103516f, 0.06336659938097f, 0.09330789744853973f, 0.12818600237369537f, 0.16668100655078888f, 0.20739200711250305f, 0.24903899431228638f, 0.29063498973846436f, 0.33134400844573975f, 0.37064099311828613f, 0.0f, 0.0f, 0.0f, 0.0f, 8.14998004479130106e-33f, 6.36954985683458947e-20f, 3.45817992297714483e-13f, 2.37365993527305363e-09f, 5.25424979969102424e-07f, 0.00001739979961712f, 0.00018874299712479f, 0.00102673994842917f, 0.00357491988688707f, 0.00922095961868763f, 0.01929700002074242f, 0.03473329916596413f, 0.05588230118155479f, 0.08250939846038818f, 0.1139099970459938f, 0.14910100400447845f, 0.18701300024986267f, 0.22664099931716919f, 0.26713100075721741f, 0.3078019917011261f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 7.3832999238063224e-28f, 4.4141699295504271e-18f, 1.48473995684877957e-12f, 3.29401994569877843e-09f, 4.59630996374471579e-07f, 0.00001273939960811f, 0.00013086199760437f, 0.00071139499777928f, 0.00253174011595547f, 0.00673073995858431f, 0.01454710029065609f, 0.02702569961547852f, 0.04481859877705574f, 0.06811539828777313f, 0.09668000042438507f, 0.12994599342346191f, 0.1671299934387207f, 0.2073339968919754f, 0.24963200092315674f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 3.35172992357784324e-37f, 1.16603995591046571e-24f, 3.39939997419364372e-17f, 1.64230001126197678e-12f, 1.9398800343850553e-09f, 2.402420022917795e-07f, 7.1422400651499629e-06f, 0.00008337580220541f, 0.0005176099948585f, 0.00207298994064331f, 0.00607771007344127f, 0.01419879961758852f, 0.0280108992010355f, 0.04858930036425591f, 0.07628270238637924f, 0.11069700121879578f, 0.15084299445152283f, 0.19536399841308594f
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
        float _S329 = (F32_sqrt((0.00999999977648258f)));
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
    float3  _S348 = make_float3 (alpha_0 * Ve_0.x, alpha_0 * Ve_0.y, Ve_0.z);
    float3  _S349 = ((((_S348)) * make_float3(rnorm3df(((_S348)).x, ((_S348)).y, ((_S348)).z))));
    float _S350 = _S349.x;
    float _S351 = _S349.y;
    float _S352 = _S350 * _S350 + _S351 * _S351;
    float3  _S353 = make_float3 (1.0f, 0.0f, 0.0f);
    float3  _S354 = make_float3 (- _S351, _S350, 0.0f);
    float _S355 = (rsqrtf((_S352)));
    float3  _S356 = _S354 * make_float3 (_S355);
    bool _S357 = _S352 > 0.0f;
    float3  _S358 = _slang_select(_S357, _S356,_S353);
    float3  _S359 = cross_0(_S349, _S358);
    float _S360 = (F32_sqrt((U1_0)));
    float _S361 = 6.28318548202514648f * U2_0;
    float _S362 = _S360 * (F32_cos((_S361)));
    float t2_0 = _S360 * (F32_sin((_S361)));
    float _S363 = 0.5f * (1.0f + _S349.z);
    float t2_1 = (1.0f - _S363) * (F32_sqrt(((F32_max((0.0f), (1.0f - _S362 * _S362)))))) + _S363 * t2_0;
    float3  _S364 = make_float3 (_S362) * _S358 + make_float3 (t2_1) * _S359;
    float _S365 = unshared_0(_S362);
    float _S366 = unshared_0(_S362);
    float3  _S367 = _S364 + make_float3 ((F32_sqrt(((F32_max((0.0f), (1.0f - _S365 * _S366 - t2_1 * t2_1))))))) * _S349;
    float3  _S368 = make_float3 (alpha_0 * _S367.x, alpha_0 * _S367.y, (F32_max((0.0f), (_S367.z))));
    float3  _S369 = ((((_S368)) * make_float3(rnorm3df(((_S368)).x, ((_S368)).y, ((_S368)).z))));
    return _S369;
}

__device__ float3  worldToTangent(float3  v_2, float3  n_3)
{
    float3  a_3 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S370 = (F32_abs((dot_0(n_3, a_3)))) > 0.9999847412109375f;
    float3  a_4;
    if(_S370)
    {
        float3  _S371 = make_float3 (1.0f, 0.0f, 0.0f);
        a_4 = _S371;
    }
    else
    {
        a_4 = a_3;
    }
    float3  _S372 = cross_0(n_3, a_4);
    float3  _S373 = ((((_S372)) * make_float3(rnorm3df(((_S372)).x, ((_S372)).y, ((_S372)).z))));
    float3  _S374 = cross_0(n_3, _S373);
    return make_float3 (dot_0(v_2, _S373), dot_0(v_2, n_3), dot_0(v_2, _S374));
}

__device__ __forceinline__ float3  sampleHalfVector(float3  v_3, float3  n_i_2, float alpha_1, AnisotropicFrame frame_0, uint * random_state_2)
{
    Random _S375 = pcg(*random_state_2);
    Random _S376 = pcg(_S375.state);
    *random_state_2 = _S376.state;
    float _S377 = frame_0.alphas.x;
    bool _S378 = _S377 > 0.0f;
    if(_S378)
    {
        float3  _S379 = anisotropicLocal(v_3, frame_0.tangent, n_i_2);
        float _S380 = frame_0.alphas.y;
        float3  _S381 = make_float3 (_S377 * _S379.x, _S380 * _S379.y, _S379.z);
        float3  _S382 = ((((_S381)) * make_float3(rnorm3df(((_S381)).x, ((_S381)).y, ((_S381)).z))));
        float3  _S383 = sampleGGXVNDF(_S382, 1.0f, _S375.value, _S376.value);
        float3  _S384 = make_float3 (_S377 * _S383.x, _S380 * _S383.y, _S383.z);
        float3  _S385 = ((((_S384)) * make_float3(rnorm3df(((_S384)).x, ((_S384)).y, ((_S384)).z))));
        return make_float3 (_S385.x) * frame_0.tangent + make_float3 (_S385.y) * cross_0(n_i_2, frame_0.tangent) + make_float3 (_S385.z) * n_i_2;
    }
    float3  _S386 = worldToTangent(v_3, n_i_2);
    float3  _S387 = sampleGGXVNDF(float3 {_S386.x, _S386.z, _S386.y}, alpha_1, _S375.value, _S376.value);
    float3  _S388 = float3 {_S387.x, _S387.z, _S387.y};
    float3  _S389 = tangentToWorld(_S388, n_i_2);
    return _S389;
}

__device__ float3  sampledHalf(float3  in_dir_0, float3  n_4, BSDFMaterial material_2, uint random_state_3, AnisotropicFrame frame_1)
{
    uint state_2 = random_state_3;
    float3  _S390 = negate_0(in_dir_0);
    float _S391 = sign_0(dot_0(n_4, _S390));
    float _S392 = material_2.roughness;
    float3  _S393 = sampleHalfVector(_S390, n_4 * make_float3 (_S391), _S392 * _S392, frame_1, &state_2);
    return _S393;
}

__device__ float3  refractedHalf(float3  in_dir_1, float3  out_dir_0, float3  n_5, float eta_i_0, float eta_o_0)
{
    float3  _S394 = negate_0(in_dir_1);
    float3  _S395 = negate_0(make_float3 (eta_i_0) * _S394 + make_float3 (eta_o_0) * out_dir_0);
    float3  _S396 = ((((_S395)) * make_float3(rnorm3df(((_S395)).x, ((_S395)).y, ((_S395)).z))));
    float _S397 = sign_0(dot_0(n_5, _S394));
    float _S398 = sign_0(dot_0(_S395, n_5 * make_float3 (_S397)));
    return _S396 * make_float3 (_S398);
}

__device__ float3  reflectedHalf(float3  in_dir_2, float3  out_dir_1)
{
    float3  _S399 = negate_0(in_dir_2);
    float3  _S400 = _S399 + out_dir_1;
    float3  _S401 = ((((_S400)) * make_float3(rnorm3df(((_S400)).x, ((_S400)).y, ((_S400)).z))));
    return _S401;
}

static __device__ float3  refract_0(float3  i_5, float3  n_6, float eta_0)
{
    float _S402 = dot_0(n_6, i_5);
    float _S403 = 1.0f - eta_0 * eta_0 * (1.0f - _S402 * _S402);
    if(_S403 < 0.0f)
    {
        return make_float3 (0.0f);
    }
    return make_float3 (eta_0) * i_5 - make_float3 (eta_0 * _S402 + (F32_sqrt((_S403)))) * n_6;
}

__device__ float fresnel(float cos_theta_0, float eta_i_1, float eta_o_1)
{
    float _S404 = (F32_sqrt(((F32_max((0.0f), (1.0f - cos_theta_0 * cos_theta_0))))));
    float _S405 = eta_i_1 / eta_o_1 * _S404;
    bool _S406 = _S405 < 1.0f;
    float kr_0;
    if(_S406)
    {
        float _S407 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S405 * _S405))))));
        bool _S408 = eta_i_1 == eta_o_1;
        float _S409 = _slang_select(_S408, cos_theta_0,_S407);
        float _S410 = eta_o_1 * cos_theta_0;
        float _S411 = eta_i_1 * _S409;
        float _S412 = (_S410 - _S411) / (_S410 + _S411);
        float _S413 = eta_i_1 * cos_theta_0;
        float _S414 = eta_o_1 * _S409;
        float _S415 = (_S413 - _S414) / (_S413 + _S414);
        float _S416 = (_S412 * _S412 + _S415 * _S415) / 2.0f;
        kr_0 = _S416;
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
    float _S417 = (F32_max((w_1.z), (0.0f)));
    return 2.0f * _S417 / (_S417 + length_0(make_float3 (alphas_2.x * w_1.x, alphas_2.y * w_1.y, _S417)));
}

__device__ float anisotropicD(float3  h_0, float2  alphas_3)
{
    float _S418 = alphas_3.x;
    float _S419 = h_0.x / _S418;
    float _S420 = alphas_3.y;
    float _S421 = h_0.y / _S420;
    float _S422 = h_0.z;
    float _S423 = _S419 * _S419 + _S421 * _S421 + _S422 * _S422;
    return 1.0f / (F32_max((3.14159274101257324f * _S418 * _S420 * _S423 * _S423), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ BSDFLobes bsdfLobes(float3  in_dir_3, float3  v_4, float3  n_i_3, float3  ggx_n_0, BSDFMaterial material_3, float eta_i_2, float eta_o_2, AnisotropicFrame frame_2, SheenProfile sheen_profile_0)
{
    float _S424 = dot_0(ggx_n_0, v_4);
    float _S425 = dot_0(n_i_3, ggx_n_0);
    float _S426 = eta_i_2 / eta_o_2;
    float3  _S427 = refract_0(in_dir_3, ggx_n_0, _S426);
    float3  _S428 = ((((_S427)) * make_float3(rnorm3df(((_S427)).x, ((_S427)).y, ((_S427)).z))));
    float _S429 = (F32_min(((F32_sqrt((material_3.specular_level))) * (F32_abs((eta_i_2 - eta_o_2))) / (eta_i_2 + eta_o_2)), (0.9999847412109375f)));
    float _S430 = _S429 * _S429;
    float _S431 = (1.0f + _S429) / (1.0f - _S429);
    float _S432 = (F32_abs((_S424)));
    bool _S433 = eta_i_2 > eta_o_2;
    float _S434 = _slang_select(_S433, _S431,1.0f);
    float _S435 = _slang_select(_S433, 1.0f,_S431);
    float _S436 = fresnel(_S432, _S434, _S435);
    bool _S437 = (eta_i_2 * eta_i_2 * (1.0f - _S424 * _S424)) >= (eta_o_2 * eta_o_2);
    float3  _S438 = material_3.specular_tint * make_float3 (_S430);
    float3  _S439 = _S438 + (make_float3 (1.0f) - _S438) * make_float3 (_S436 - _S430) / make_float3 (1.0f - _S430);
    float3  _S440 = make_float3 (1.0f);
    float3  _S441 = _slang_select(_S437, _S440,_S439);
    float3  _S442 = make_float3 (0.0f);
    float sheen_component_0;
    float3  sheen_1;
    float3  view_1;
    float3  scale_1;
    if(sheen_profile_0.on)
    {
        float _S443 = (F32_min((sheen_profile_0.albedo), (1.0f)));
        float3  _S444 = make_float3 (1.0f) - material_3.sheen * make_float3 (_S443);
        float _S445 = rgb_to_greyscale(material_3.sheen);
        float _S446 = _S445 * _S443;
        float3  _S447 = material_3.sheen / make_float3 ((F32_max((sheen_profile_0.albedo), (1.0f))));
        sheen_component_0 = _S446;
        sheen_1 = _S447;
        view_1 = v_4;
        scale_1 = _S444;
    }
    else
    {
        sheen_component_0 = 0.0f;
        sheen_1 = _S442;
        view_1 = _S442;
        scale_1 = _S440;
    }
    float _S448 = material_3.toon.x;
    bool _S449 = _S448 < 0.0f;
    float _S450 = (F32_abs((_S448)));
    bool _S451 = _S450 > 0.0f;
    float toon_component_0;
    float toon_a_1;
    float toon_s_1;
    float toon_b_1;
    float toon_norm_1;
    float toon_view_1;
    float3  toon_1;
    float3  toon_axis_1;
    bool _S452;
    if(_S451)
    {
        float _S453 = (F32_min((_S450), (1.0f)));
        float3  scale_2 = scale_1 * make_float3 (1.0f - _S453);
        float _S454 = rgb_to_greyscale(material_3.albedo);
        float _S455 = _S453 * _S454;
        float3  _S456 = make_float3 (_S453) * material_3.albedo;
        float toon_a_2 = clamp_1(material_3.toon.y / _S448, 0.00000999999974738f, 1.0f) * 3.14159274101257324f / 2.0f;
        float toon_s_2 = clamp_1(material_3.toon.z / _S448, 0.0f, 1.0f) * 3.14159274101257324f / 2.0f;
        float _S457 = (F32_min((toon_a_2 + toon_s_2), (1.57079637050628662f)));
        if(_S449)
        {
            toon_component_0 = 1.0f - (F32_cos(((F32_min((_S457), (toon_a_2))))));
        }
        else
        {
            float _S458 = (F32_sin(((F32_min((_S457), (toon_a_2))))));
            toon_component_0 = _S458 * _S458 / 2.0f;
        }
        bool _S459 = _S457 > toon_a_2;
        if(_S459)
        {
            _S452 = toon_s_2 > 0.0f;
        }
        else
        {
            _S452 = false;
        }
        if(_S452)
        {
            if(_S449)
            {
                float _S460 = (F32_cos((toon_a_2)));
                float _S461 = (F32_cos((_S457)));
                toon_a_1 = (1.0f + toon_a_2 / toon_s_2) * (_S460 - _S461) - ((F32_sin((_S457))) - _S457 * _S461 - ((F32_sin((toon_a_2))) - toon_a_2 * _S460)) / toon_s_2;
            }
            else
            {
                float _S462 = 2.0f * toon_a_2;
                float _S463 = (F32_cos((_S462)));
                float _S464 = 2.0f * _S457;
                float _S465 = (F32_cos((_S464)));
                toon_a_1 = (1.0f + toon_a_2 / toon_s_2) * (_S463 - _S465) / 4.0f - ((F32_sin((_S464))) / 8.0f - _S457 * _S465 / 4.0f - ((F32_sin((_S462))) / 8.0f - toon_a_2 * _S463 / 4.0f)) / toon_s_2;
            }
            float integral_0 = toon_component_0 + toon_a_1;
            toon_component_0 = integral_0;
        }
        float _S466 = 6.28318548202514648f * toon_component_0;
        float _S467 = dot_0(n_i_3, v_4);
        float _S468 = (F32_acos(((F32_min((_S467), (1.0f))))));
        if(_S468 < toon_a_2)
        {
            toon_component_0 = 1.0f;
        }
        else
        {
            toon_component_0 = (F32_max((1.0f - (_S468 - toon_a_2) / (F32_max((toon_s_2), (0.0000152587890625f)))), (0.0f)));
        }
        if(_S449)
        {
            float3  _S469 = make_float3 (2.0f * _S467) * n_i_3 - v_4;
            float3  _S470 = ((((_S469)) * make_float3(rnorm3df(((_S469)).x, ((_S469)).y, ((_S469)).z))));
            scale_1 = _S470;
        }
        else
        {
            scale_1 = n_i_3;
        }
        float _S471 = toon_component_0;
        toon_component_0 = _S455;
        toon_1 = _S456;
        toon_a_1 = toon_a_2;
        toon_s_1 = toon_s_2;
        toon_b_1 = _S457;
        toon_norm_1 = _S466;
        toon_view_1 = _S471;
        toon_axis_1 = scale_1;
        scale_1 = scale_2;
    }
    else
    {
        toon_component_0 = 0.0f;
        toon_1 = _S442;
        toon_a_1 = 0.0f;
        toon_s_1 = 0.0f;
        toon_b_1 = 0.0f;
        toon_norm_1 = 1.0f;
        toon_view_1 = 0.0f;
        toon_axis_1 = n_i_3;
    }
    float3  _S472 = mix_0(_S441, material_3.albedo, material_3.metallic);
    float3  F_1 = _S472 * scale_1;
    float _S473 = rgb_to_greyscale(F_1);
    float _S474 = 1.0f - material_3.metallic;
    float3  _S475 = make_float3 (1.0f) - _S441;
    float3  _S476 = make_float3 ((1.0f - material_3.transmission) * _S474) * _S475 * scale_1;
    float3  _S477 = make_float3 (material_3.transmission * _S474) * _S475 * scale_1;
    float _S478 = (F32_max((_S473), (0.0f)));
    float _S479 = rgb_to_greyscale(_S476);
    float _S480 = (F32_max((_S479), (0.0f)));
    float _S481 = rgb_to_greyscale(_S477);
    float _S482 = sign_0(length_0(_S428));
    float _S483 = (F32_max((_S481 * _S482), (0.0f)));
    float _S484 = _S478 + _S480 + _S483 + toon_component_0;
    float _S485 = (F32_min((sheen_component_0), (1.0f)));
    bool _S486 = sheen_component_0 > 0.0f;
    if(_S486)
    {
        _S452 = !(_S484 > 0.0f);
    }
    else
    {
        _S452 = false;
    }
    float _S487 = _slang_select(_S452, 1.0f,_S485);
    float _S488 = (1.0f - _S487) / (F32_max((_S484), (0.0000152587890625f)));
    float _S489 = _S480 * _S488;
    float _S490 = _S478 * _S488;
    float _S491 = _S483 * _S488;
    bool _S492 = (frame_2.alphas.x) > 0.0f;
    float visible_1;
    if(_S492)
    {
        float3  _S493 = anisotropicLocal(v_4, frame_2.tangent, n_i_3);
        float _S494 = anisotropicG1(_S493, frame_2.alphas);
        float3  _S495 = anisotropicLocal(ggx_n_0, frame_2.tangent, n_i_3);
        float _S496 = anisotropicD(_S495, frame_2.alphas);
        float _S497 = _S494 * _S496;
        visible_1 = _S497;
    }
    else
    {
        visible_1 = 0.0f;
    }
    return BSDFLobes_x24init_0(_S424, _S425, _S428, F_1, _S473, 1.0f, _S476, _S477, _S489, _S490, _S491, 0.0f, sheen_1, _S487, view_1, frame_2.tangent, frame_2.alphas, visible_1, toon_component_0 * _S488, toon_1, toon_a_1, toon_s_1, toon_b_1, _S449, toon_norm_1, toon_view_1, toon_axis_1);
}

__device__ float translucentShare(BSDFMaterial material_4)
{
    float _S498 = rgb_to_greyscale(material_4.translucent);
    float _S499 = rgb_to_greyscale(material_4.albedo);
    float _S500 = _S498 / (_S499 + _S498);
    bool _S501 = _S498 > 0.0f;
    float _S502 = _slang_select(_S501, _S500,0.0f);
    return _S502;
}

__device__ __forceinline__ float diffusePDF(float n_i_dot_l_0, float l_dot_h_0, float n_i_dot_v_0, float alpha_2, BSDFLobes lobes_0, float eta_i_3, float eta_o_3)
{
    float _S503 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    float _S504 = lobes_0.p_diffuse * (F32_abs((n_i_dot_l_0))) * 0.31830987334251404f;
    float _S505 = 1.0f - lobes_0.translucent_share;
    bool _S506 = n_i_dot_l_0 < 0.0f;
    float _S507 = _slang_select(_S506, lobes_0.translucent_share,_S505);
    float _S508 = _S504 * _S507;
    bool _S509 = (lobes_0.translucent_share) > 0.0f;
    float _S510 = _slang_select(_S509, _S508,_S503);
    bool _S511 = n_i_dot_v_0 > 0.0f;
    float _S512 = _slang_select(_S511, _S510,0.0f);
    return _S512;
}

__device__ __forceinline__ float3  diffuseBSDF(float3  l_0, float3  n_i_4, float alpha_3, BSDFMaterial material_5, BSDFLobes lobes_1)
{
    bool _S513 = (dot_0(n_i_4, l_0)) < 0.0f;
    float3  _S514 = _slang_select(_S513, material_5.translucent,material_5.albedo);
    float _S515 = 1.0f - lobes_1.translucent_share;
    float _S516 = _slang_select(_S513, lobes_1.translucent_share,_S515);
    float3  _S517 = _S514 / make_float3 (_S516);
    bool _S518 = (lobes_1.translucent_share) > 0.0f;
    float3  _S519 = _slang_select(_S518, _S517,material_5.albedo);
    return lobes_1.diffuse_weight * _S519 / make_float3 (lobes_1.p_diffuse);
}

__device__ float smithG1(float alpha_4, float n_dot_x_0)
{
    float _S520 = alpha_4 * alpha_4;
    float _S521 = 2.0f * n_dot_x_0 / (n_dot_x_0 + (F32_sqrt((_S520 + (1.0f - _S520) * n_dot_x_0 * n_dot_x_0))));
    bool _S522 = alpha_4 > 0.0f;
    float _S523 = _slang_select(_S522, _S521,1.0f);
    return _S523;
}

__device__ float trowbridgeReitz(float alpha_5, float n_dot_h_1)
{
    float _S524 = alpha_5 * alpha_5;
    float _S525 = (1.0f - n_dot_h_1) * (1.0f + n_dot_h_1) + _S524 * n_dot_h_1 * n_dot_h_1;
    return _S524 / (F32_max((3.14159274101257324f * _S525 * _S525), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ float vndfPDF(float n_i_dot_v_1, float alpha_6, BSDFLobes lobes_2)
{
    float _S526 = smithG1(alpha_6, n_i_dot_v_1);
    float _S527 = _S526 * lobes_2.v_dot_h;
    float _S528 = trowbridgeReitz(alpha_6, lobes_2.n_dot_h);
    float _S529 = _S527 * _S528 / n_i_dot_v_1;
    bool _S530 = alpha_6 > 0.0f;
    bool _S531;
    if(_S530)
    {
        _S531 = (lobes_2.v_dot_h) > 0.0f;
    }
    else
    {
        _S531 = false;
    }
    if(_S531)
    {
        _S531 = (lobes_2.n_dot_h) > 0.0f;
    }
    else
    {
        _S531 = false;
    }
    if(_S531)
    {
        _S531 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S531 = false;
    }
    float _S532 = _slang_select(_S531, _S529,0.0f);
    bool _S533 = (lobes_2.alphas.x) > 0.0f;
    float pdf_h_0;
    if(_S533)
    {
        float _S534 = lobes_2.visible * lobes_2.v_dot_h / n_i_dot_v_1;
        bool _S535 = (lobes_2.v_dot_h) > 0.0f;
        if(_S535)
        {
            _S531 = (lobes_2.n_dot_h) > 0.0f;
        }
        else
        {
            _S531 = false;
        }
        if(_S531)
        {
            _S531 = n_i_dot_v_1 > 0.0f;
        }
        else
        {
            _S531 = false;
        }
        float _S536 = _slang_select(_S531, _S534,0.0f);
        pdf_h_0 = _S536;
    }
    else
    {
        pdf_h_0 = _S532;
    }
    return pdf_h_0;
}

__device__ __forceinline__ float refractPDF(float n_i_dot_l_1, float l_dot_h_1, float n_i_dot_v_2, float alpha_7, BSDFLobes lobes_3, float eta_i_4, float eta_o_4)
{
    float _S537 = vndfPDF(n_i_dot_v_2, alpha_7, lobes_3);
    float _S538 = eta_i_4 * lobes_3.v_dot_h + eta_o_4 * l_dot_h_1;
    float _S539 = lobes_3.p_refract * _S537 * eta_o_4 * eta_o_4 * (F32_abs((l_dot_h_1))) / (_S538 * _S538);
    bool _S540 = eta_i_4 != eta_o_4;
    bool _S541;
    if(_S540)
    {
        _S541 = l_dot_h_1 < 0.0f;
    }
    else
    {
        _S541 = false;
    }
    float _S542 = _slang_select(_S541, _S539,0.0f);
    return _S542;
}

__device__ __forceinline__ float3  refractBSDF(float3  l_1, float3  n_i_5, float alpha_8, BSDFMaterial material_6, BSDFLobes lobes_4)
{
    float _S543 = - dot_0(n_i_5, l_1);
    float _S544 = smithG1(alpha_8, (F32_max((_S543), (0.0f))));
    bool _S545 = (lobes_4.alphas.x) > 0.0f;
    float G1_l_0;
    if(_S545)
    {
        float3  _S546 = negate_0(n_i_5);
        float3  _S547 = anisotropicLocal(l_1, lobes_4.tangent, _S546);
        float _S548 = anisotropicG1(_S547, lobes_4.alphas);
        G1_l_0 = _S548;
    }
    else
    {
        G1_l_0 = _S544;
    }
    return lobes_4.refract_weight * make_float3 (G1_l_0) * material_6.albedo / make_float3 (lobes_4.p_refract);
}

__device__ __forceinline__ float sheenVelvetPDF(float n_i_dot_l_2, float l_dot_h_2, float n_i_dot_v_3, float alpha_9, BSDFLobes lobes_5, float eta_i_5, float eta_o_5)
{
    float _S549 = lobes_5.p_sheen_velvet * 0.5f * 0.31830987334251404f;
    bool _S550 = n_i_dot_l_2 > 0.0f;
    bool _S551;
    if(_S550)
    {
        _S551 = n_i_dot_v_3 > 0.0f;
    }
    else
    {
        _S551 = false;
    }
    float _S552 = _slang_select(_S551, _S549,0.0f);
    return _S552;
}

__device__ __forceinline__ float3  sheenVelvetBSDF(float3  l_2, float3  n_i_6, float alpha_10, BSDFMaterial material_7, BSDFLobes lobes_6)
{
    float3  _S553 = l_2 + lobes_6.view;
    float3  _S554 = ((((_S553)) * make_float3(rnorm3df(((_S553)).x, ((_S553)).y, ((_S553)).z))));
    float _S555 = dot_0(n_i_6, _S554);
    float _S556 = (F32_max((dot_0(n_i_6, l_2)), (0.0f)));
    float _S557 = (F32_max((dot_0(n_i_6, lobes_6.view)), (0.0f)));
    float _S558 = 1.0f / (F32_max((material_7.sheen_roughness), (0.05000000074505806f)));
    float _S559 = 1.0f - _S555 * _S555;
    float _S560 = (2.0f + _S558) * (F32_pow(((F32_max((_S559), (0.0f)))), (0.5f * _S558))) * 0.5f * 0.31830987334251404f / (F32_max((4.0f * (_S556 + _S557 - _S556 * _S557)), (0.0000152587890625f)));
    bool _S561 = (material_7.velvet) > 0.0f;
    float f_1;
    if(_S561)
    {
        float _S562 = (F32_max((material_7.sheen_roughness), (0.00999999977648258f)));
        float _S563 = _S562 * _S562;
        float _S564 = (F32_max((_S559), (0.0000152587890625f)));
        float _S565 = (F32_exp((- _S555 * _S555 / (_S564 * _S563)))) / (3.14159274101257324f * _S563 * _S564 * _S564) * (F32_min((1.0f), (2.0f * _S555 * (F32_min((_S556), (_S557))) / (F32_max(((F32_abs((dot_0(_S554, lobes_6.view))))), (0.0000152587890625f)))))) / (F32_max((4.0f * _S556 * _S557), (0.0000152587890625f)));
        f_1 = _S565;
    }
    else
    {
        f_1 = _S560;
    }
    return lobes_6.sheen * make_float3 (f_1 * _S556 * 2.0f * 3.14159274101257324f / lobes_6.p_sheen_velvet);
}

__device__ __forceinline__ float toonPDF(float n_i_dot_l_3, float l_dot_h_3, float n_i_dot_v_4, float alpha_11, BSDFLobes lobes_7, float eta_i_6, float eta_o_6)
{
    float _S566 = _slang_select(lobes_7.toon_glossy, l_dot_h_3,n_i_dot_l_3);
    float _S567 = (F32_acos((clamp_1(_S566, -1.0f, 1.0f))));
    float _S568;
    if(_S567 < (lobes_7.toon_a))
    {
        _S568 = 1.0f;
    }
    else
    {
        _S568 = (F32_max((1.0f - (_S567 - lobes_7.toon_a) / (F32_max((lobes_7.toon_s), (0.0000152587890625f)))), (0.0f)));
    }
    float _S569 = lobes_7.p_toon * _S568;
    float _S570 = _slang_select(lobes_7.toon_glossy, 1.0f,n_i_dot_l_3);
    float _S571 = _S569 * _S570 / lobes_7.toon_norm;
    bool _S572;
    if(lobes_7.toon_glossy)
    {
        _S572 = true;
    }
    else
    {
        _S572 = n_i_dot_l_3 > 0.0f;
    }
    float _S573 = _slang_select(_S572, _S571,0.0f);
    return _S573;
}

__device__ __forceinline__ float3  toonBSDF(float3  l_3, float3  n_i_7, float alpha_12, BSDFMaterial material_8, BSDFLobes lobes_8)
{
    float _S574 = (F32_max((dot_0(n_i_7, l_3)), (0.0f)));
    float _S575 = _slang_select(lobes_8.toon_glossy, _S574,lobes_8.toon_view);
    return lobes_8.toon * make_float3 (_S575) / make_float3 (lobes_8.p_toon);
}

__device__ __forceinline__ float reflectPDF(float n_i_dot_l_4, float l_dot_h_4, float n_i_dot_v_5, float alpha_13, BSDFLobes lobes_9, float eta_i_7, float eta_o_7)
{
    float _S576 = vndfPDF(n_i_dot_v_5, alpha_13, lobes_9);
    float _S577 = lobes_9.p_reflect * _S576 / (4.0f * lobes_9.v_dot_h);
    bool _S578 = _S576 > 0.0f;
    float _S579 = _slang_select(_S578, _S577,0.0f);
    return _S579;
}

__device__ __forceinline__ float3  reflectBSDF(float3  l_4, float3  n_i_8, float alpha_14, BSDFMaterial material_9, BSDFLobes lobes_10)
{
    float _S580 = dot_0(n_i_8, l_4);
    float _S581 = smithG1(alpha_14, (F32_max((_S580), (0.0f))));
    bool _S582 = (lobes_10.alphas.x) > 0.0f;
    float G1_l_1;
    if(_S582)
    {
        float3  _S583 = anisotropicLocal(l_4, lobes_10.tangent, n_i_8);
        float _S584 = anisotropicG1(_S583, lobes_10.alphas);
        G1_l_1 = _S584;
    }
    else
    {
        G1_l_1 = _S581;
    }
    return make_float3 (lobes_10.reflect_weight * G1_l_1) * lobes_10.F / make_float3 (lobes_10.p_reflect);
}

__device__ __forceinline__ float3  BSDF(float3  in_dir_4, float3  out_dir_2, float3  n_7, BSDFMaterial material_10, float eta_i_8, float eta_o_8, bool refracted_2, uint random_state_4, FixedArray<float3 , 5>  * throughputs_0, FixedArray<float, 5>  * pdfs_0)
{
    float3  ggx_n_1;
    float3  _S585 = negate_0(in_dir_4);
    float _S586 = dot_0(n_7, _S585);
    float _S587 = sign_0(_S586);
    float3  _S588 = n_7 * make_float3 (_S587);
    AnisotropicFrame _S589 = anisotropicFrame(material_10, _S588);
    float _S590 = dot_0(_S588, out_dir_2);
    float _S591 = material_10.roughness;
    float _S592 = _S591 * _S591;
    SheenProfile _S593 = sheenProfile(_S585, _S588, material_10);
    float _S594 = rgb_to_greyscale(material_10.translucent);
    bool _S595 = _S594 > 0.0f;
    bool _S596 = (dot_0(n_7, out_dir_2) * _S586) < 0.0f;
    uint _S597;
    if((F32_abs((material_10.toon.x))) > 0.0f)
    {
        _S597 = 5U;
    }
    else
    {
        _S597 = 4U;
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
        float3  _S598 = make_float3 (0.0f);
        (*throughputs_0)[i_6] = _S598;
        (*pdfs_0)[i_6] = 0.0f;
        uint i_7 = i_6 + 1U;
        i_6 = i_7;
    }
    float3  _S599 = make_float3 (0.0f);
    BSDFLobes _S600 = BSDFLobes_x24init_0(0.0f, 0.0f, _S599, _S599, 0.0f, 0.0f, _S599, _S599, 0.0f, 0.0f, 0.0f, 0.0f, _S599, 0.0f, _S599, _S599, make_float2 (0.0f), 0.0f, 0.0f, _S599, 0.0f, 0.0f, 0.0f, false, 1.0f, 0.0f, _S599);
    BSDFLobes lobe_terms_0 = _S600;
    uint half_of_0 = 4294967295U;
    float3  ggx_n_2 = _S599;
    i_6 = 0U;
    for(;;)
    {
        if(i_6 < _S597)
        {
        }
        else
        {
            break;
        }
        uint _S601;
        if(i_6 == 3U)
        {
            _S601 = 4U;
        }
        else
        {
            if(i_6 == 4U)
            {
                _S601 = 6U;
            }
            else
            {
                _S601 = i_6;
            }
        }
        bool _S602 = _S601 == 0U;
        bool _S603;
        if(_S602)
        {
            _S603 = _S595;
        }
        else
        {
            _S603 = false;
        }
        bool _S604;
        if(_S603)
        {
            _S604 = _S596;
        }
        else
        {
            _S604 = _S601 == 1U;
        }
        bool _S605 = _S604 != refracted_2;
        if(_S605)
        {
            ggx_n_1 = ggx_n_2;
            uint i_8 = i_6 + 1U;
            ggx_n_2 = ggx_n_1;
            i_6 = i_8;
            continue;
        }
        uint _S606;
        if(_S601 == 6U)
        {
            _S606 = 0U;
        }
        else
        {
            if(_S601 == 4U)
            {
                _S606 = 2U;
            }
            else
            {
                _S606 = _S601;
            }
        }
        bool _S607 = _S606 != half_of_0;
        uint half_of_1;
        if(_S607)
        {
            bool _S608 = _S606 == 0U;
            if(_S608)
            {
                float3  _S609 = sampledHalf(in_dir_4, n_7, material_10, random_state_4, _S589);
                ggx_n_1 = _S609;
            }
            else
            {
                bool _S610 = _S606 == 1U;
                if(_S610)
                {
                    float3  _S611 = refractedHalf(in_dir_4, out_dir_2, n_7, eta_i_8, eta_o_8);
                    ggx_n_1 = _S611;
                }
                else
                {
                    float3  _S612 = reflectedHalf(in_dir_4, out_dir_2);
                    ggx_n_1 = _S612;
                }
            }
            float3  _S613 = negate_0(in_dir_4);
            BSDFLobes _S614 = bsdfLobes(in_dir_4, _S613, _S588, ggx_n_1, material_10, eta_i_8, eta_o_8, _S589, _S593);
            lobe_terms_0 = _S614;
            float _S615 = translucentShare(material_10);
            (&lobe_terms_0)->translucent_share = _S615;
            half_of_1 = _S606;
        }
        else
        {
            ggx_n_1 = ggx_n_2;
            half_of_1 = half_of_0;
        }
        switch(_S601)
        {
        case 0U:
            {
                float _S616 = diffusePDF(_S590, 0.0f, (F32_abs((_S586))), _S592, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(0)] = _S616;
                float3  _S617 = diffuseBSDF(out_dir_2, _S588, _S592, material_10, lobe_terms_0);
                (*throughputs_0)[int(0)] = _S617;
                break;
            }
        case 1U:
            {
                float _S618 = refractPDF(_S590, dot_0(out_dir_2, ggx_n_1), (F32_abs((_S586))), _S592, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(1)] = _S618;
                float3  _S619 = refractBSDF(out_dir_2, _S588, _S592, material_10, lobe_terms_0);
                (*throughputs_0)[int(1)] = _S619;
                break;
            }
        case 4U:
            {
                float _S620 = sheenVelvetPDF(_S590, 0.0f, (F32_abs((_S586))), _S592, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(3)] = _S620;
                float3  _S621 = sheenVelvetBSDF(out_dir_2, _S588, _S592, material_10, lobe_terms_0);
                (*throughputs_0)[int(3)] = _S621;
                break;
            }
        case 6U:
            {
                float _S622 = toonPDF(_S590, dot_0(out_dir_2, (&lobe_terms_0)->toon_axis), (F32_abs((_S586))), _S592, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(4)] = _S622;
                float3  _S623 = toonBSDF(out_dir_2, _S588, _S592, material_10, lobe_terms_0);
                (*throughputs_0)[int(4)] = _S623;
                break;
            }
        default:
            {
                float _S624 = reflectPDF(_S590, 0.0f, (F32_abs((_S586))), _S592, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(2)] = _S624;
                float3  _S625 = reflectBSDF(out_dir_2, _S588, _S592, material_10, lobe_terms_0);
                (*throughputs_0)[int(2)] = _S625;
                break;
            }
        }
        half_of_0 = half_of_1;
        uint i_8 = i_6 + 1U;
        ggx_n_2 = ggx_n_1;
        i_6 = i_8;
    }
    i_6 = 0U;
    ggx_n_1 = _S599;
    for(;;)
    {
        if(i_6 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S626 = ((*pdfs_0)[i_6]) > 0.0f;
        if(_S626)
        {
            float3  f_2 = ggx_n_1 + (*throughputs_0)[i_6] * make_float3 ((*pdfs_0)[i_6]);
            ggx_n_1 = f_2;
        }
        uint i_9 = i_6 + 1U;
        i_6 = i_9;
    }
    return ggx_n_1;
}

static __device__ __forceinline__ float3  skyLobes_0(float3  in_dir_5, float3  dir_4, FKSurface * surface_1, float2  eta_1, bool is_inside_2, float pdf_0, uint random_state_5, FixedArray<float3 , 5>  * terms_0, FixedArray<float, 5>  * pdfs_1)
{
    bool _S627 = wrongSide_0(is_inside_2, false, dir_4, surface_1->geometry_n);
    float3  _S628 = BSDF(in_dir_5, dir_4, surface_1->smooth_n, surface_1->material, eta_1.x, eta_1.y, _S627, random_state_5, terms_0, pdfs_1);
    float3  _S629 = make_float3 (0.0f);
    uint i_10 = 0U;
    float3  f_3 = _S629;
    for(;;)
    {
        if(i_10 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S630 = ((*pdfs_1)[i_10]) > 0.0f;
        if(_S630)
        {
            float3  _S631 = (*terms_0)[i_10] * make_float3 ((*pdfs_1)[i_10]) / make_float3 ((*pdfs_1)[i_10] + pdf_0);
            (*terms_0)[i_10] = _S631;
            float3  f_4 = f_3 + (*terms_0)[i_10];
            f_3 = f_4;
        }
        uint i_11 = i_10 + 1U;
        i_10 = i_11;
    }
    return f_3;
}

__device__ float3  skyBSDF(float3  in_dir_6, float3  dir_5, FKSurface surface_2, float2  eta_2, bool is_inside_3, float pdf_1, uint random_state_6)
{
    FKSurface _S632 = surface_2;
    FixedArray<float3 , 5>  terms_1;
    FixedArray<float, 5>  pdfs_2;
    float3  _S633 = skyLobes_0(in_dir_6, dir_5, &_S632, eta_2, is_inside_3, pdf_1, random_state_6, &terms_1, &pdfs_2);
    return _S633;
}

static __device__ SkySample SkySample_x24init_0(float3  dir_6, float3  radiance_0, float3  color_0, uint random_state_7)
{
    SkySample _S634;
    (&_S634)->dir = dir_6;
    (&_S634)->radiance = radiance_0;
    (&_S634)->color = color_0;
    (&_S634)->random_state = random_state_7;
    return _S634;
}

static __device__ SkySample sampleSky_0(FKRay * ray_0, FKSurface * surface_3, float2  eta_3, bool is_inside_4, uint init_random_state_0, uint lobe_state_0, ShadowContext * context_2)
{
    uint2  _S635 = (fcptEnvironmentCdfSize());
    uint2  _S636 = make_uint2 (1U, 0U);
    uint2  _S637 = _S635 - _S636;
    Random _S638 = pcg(init_random_state_0);
    Random _S639 = pcg(_S638.state);
    Random _S640 = pcg(_S639.state);
    Random _S641 = pcg(_S640.state);
    uint _S642 = _S637.x;
    uint _S643 = searchCDF_0(make_uint2 (_S642, 0U), make_uint2 (0U, 1U), _S637.y, _S638.value);
    uint _S644 = searchCDF_0(make_uint2 (0U, _S643), _S636, _S642, _S639.value);
    float2  _S645 = make_float2 ((float)_S637.x, (float)_S637.y);
    float2  _S646 = (make_float2 (float(_S644), float(_S643)) + make_float2 (_S640.value, _S641.value)) / _S645 * make_float2 (6.28318548202514648f, 3.14159274101257324f);
    float _S647 = _S646.y;
    float _S648 = (F32_sin((_S647)));
    float _S649 = _S646.x;
    float3  _S650 = skyFrame_0(make_float3 (_S648 * (F32_cos((_S649))), (F32_cos((_S647))), _S648 * (F32_sin((_S649)))));
    float _S651 = environmentPdf_0(_S650);
    float3  _S652 = skyBSDF(ray_0->unit_direction, _S650, *surface_3, eta_3, is_inside_4, _S651, lobe_state_0);
    bool _S653 = !(_S651 > 0.0f);
    bool _S654;
    if(_S653)
    {
        _S654 = true;
    }
    else
    {
        _S654 = all_1(_S652 == make_float3 (0.0f));
    }
    if(_S654)
    {
        float3  _S655 = make_float3 (0.0f);
        return SkySample_x24init_0(_S650, _S655, _S655, _S641.state);
    }
    float3  _S656 = skyRadiance_0(ray_0->origin, surface_3, is_inside_4, _S650, context_2, _S641.state);
    return SkySample_x24init_0(_S650, _S656, _S652 * _S656, _S641.state);
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
    SampleBSDF _S657 = (fcptConnectHair((surface_4->hair), ((&surface_4->material)->albedo), ((&surface_4->material)->specular_tint), (in_dir_7), (light_1->dir)));
    float3  _S658 = _S657.throughput * make_float3 (_S657.pdf);
    float _S659 = light_1->density;
    float _S660 = 1.0f + _S657.pdf * _S657.pdf / (light_1->density * light_1->density);
    bool _S661;
    if(competing_0)
    {
        _S661 = _S659 > 0.0f;
    }
    else
    {
        _S661 = false;
    }
    float _S662 = _slang_select(_S661, _S660,1.0f);
    return _S658 / make_float3 (_S662) * light_1->radiance;
}

static __device__ TreeSample TreeSample_x24init_0(float3  dir_7, float3  radiance_1, float density_0, uint random_state_8)
{
    TreeSample _S663;
    (&_S663)->dir = dir_7;
    (&_S663)->radiance = radiance_1;
    (&_S663)->density = density_0;
    (&_S663)->random_state = random_state_8;
    return _S663;
}

__device__ uint pickChild(LightNode first_1, LightNode second_1, float3  p_10, float3  normal_3, float * pick_0, float * probability_3)
{
    float _S664 = importance(first_1, p_10, normal_3);
    float _S665 = importance(second_1, p_10, normal_3);
    float2  _S666 = make_float2 (_S664, _S665);
    bool _S667 = _S664 == 0.0f;
    bool _S668;
    if(_S667)
    {
        _S668 = _S665 == 0.0f;
    }
    else
    {
        _S668 = false;
    }
    if(_S668)
    {
        return 2U;
    }
    float _S669 = _S664 + _S665;
    bool _S670 = _S665 > 0.0f;
    if(_S670)
    {
        _S668 = (*pick_0 * _S669) >= _S664;
    }
    else
    {
        _S668 = false;
    }
    uint _S671 = uint(_S668);
    float _S672 = (F32_min(((*pick_0 * _S669 - float(_S671) * _S664) / _slang_vector_get_element(_S666, _S671)), (0.99999994039535522f)));
    *pick_0 = _S672;
    float _S673 = *probability_3 * (_slang_vector_get_element(_S666, _S671) / _S669);
    *probability_3 = _S673;
    return _S671;
}

__device__ float3  sampleSphere(float3  center_1, float radius_1, float3  p_11, float u1_0, float u2_0)
{
    float3  _S674 = center_1 - p_11;
    float _S675 = radius_1 * radius_1 / dot_0(_S674, _S674);
    float _S676 = u1_0 * _S675 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S675), (0.0f)))))));
    float _S677 = 2.0f * u1_0;
    bool _S678 = _S675 >= 1.0f;
    float _S679 = _slang_select(_S678, _S677,_S676);
    float _S680 = (F32_sqrt(((F32_max((_S679 * (2.0f - _S679)), (0.0f))))));
    float _S681 = 6.28318548202514648f * u2_0;
    float3  _S682 = make_float3 (_S680 * (F32_cos((_S681))), 1.0f - _S679, _S680 * (F32_sin((_S681))));
    float3  _S683 = ((((_S674)) * make_float3(rnorm3df(((_S674)).x, ((_S674)).y, ((_S674)).z))));
    float3  _S684 = tangentToWorld(_S682, _S683);
    return _S684;
}

__device__ float3  pointLightRadiance(float3  color_1, float intensity_0, float radius_2)
{
    return color_1 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_2 * radius_2);
}

static __device__ float raySphere_0(float3  center_2, float radius_3, FKRay * ray_1, float max_len_0)
{
    float3  _S685 = center_2 - ray_1->origin;
    float _S686 = dot_0(_S685, ray_1->unit_direction);
    float _S687 = dot_0(_S685, _S685) - _S686 * _S686;
    float _S688 = radius_3 * radius_3;
    bool _S689 = _S687 > _S688;
    if(_S689)
    {
        return 4.294967296e+09f;
    }
    float _S690 = (F32_sqrt((_S688 - _S687)));
    float _S691 = _S686 - _S690;
    float _S692 = _S686 + _S690;
    bool _S693 = _S691 > 0.0000152587890625f;
    bool _S694;
    if(_S693)
    {
        _S694 = _S691 < max_len_0;
    }
    else
    {
        _S694 = false;
    }
    if(_S694)
    {
        return _S691;
    }
    bool _S695 = _S692 > 0.0000152587890625f;
    if(_S695)
    {
        _S694 = _S692 < max_len_0;
    }
    else
    {
        _S694 = false;
    }
    if(_S694)
    {
        return _S692;
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

static __device__ float3  emitted_0(float3  emissive_0, float3  dir_8, float3  n_8)
{
    float _S696 = sign_0(dot_0(- dir_8, n_8));
    float3  _S697 = emissive_0 * make_float3 ((F32_max((_S696), (0.0f))));
    bool _S698 = ((true));
    float3  _S699 = _slang_select(_S698, emissive_0,_S697);
    return _S699;
}

static __device__ __forceinline__ TreeSample sampleLightTree_0(float3  origin_4, float3  smooth_n_2, float3  geometry_n_1, float geometry_offset_1, bool sided_0, uint init_random_state_1, ShadowContext * context_3)
{
    Random _S700 = pcg(init_random_state_1);
    Random _S701 = pcg(_S700.state);
    Random _S702 = pcg(_S701.state);
    float3  _S703 = make_float3 (0.0f);
    TreeSample _S704 = TreeSample_x24init_0(_S703, _S703, 0.0f, _S702.state);
    TreeSample sample_0 = _S704;
    float3  _S705 = _slang_select(sided_0, _S703,smooth_n_2);
    float3  _S706 = origin_4 + make_float3 (geometry_offset_1) * smooth_n_2;
    float pick_1 = _S700.value;
    float probability_4 = 1.0f;
    uint n_9 = 0U;
    for(;;)
    {
        uint4  _S707 = (fcptLightNode((n_9)));
        if((_S707.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S708 = (fcptLightSecond((n_9)));
        uint _S709 = n_9 + 1U;
        LightNode _S710 = (fcptLightBounds((_S709)));
        LightNode _S711 = (fcptLightBounds((_S708)));
        uint _S712 = pickChild(_S710, _S711, origin_4, _S705, &pick_1, &probability_4);
        bool _S713 = _S712 > 1U;
        if(_S713)
        {
            return sample_0;
        }
        bool _S714 = _S712 == 1U;
        uint _S715 = _slang_select(_S714, _S708,_S709);
        n_9 = _S715;
    }
    bool _S716 = n_9 == 0U;
    bool _S717;
    if(_S716)
    {
        LightNode _S718 = (fcptLightBounds((0U)));
        float _S719 = importance(_S718, origin_4, _S705);
        _S717 = !(_S719 > 0.0f);
    }
    else
    {
        _S717 = false;
    }
    if(_S717)
    {
        return sample_0;
    }
    uint4  _S720 = (fcptLightNode((n_9)));
    FKHit _S721 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    bool _S722 = (_S720.x) == 2U;
    float3  emitter_point_0;
    float3  lift_n_0;
    float3  shadow_1;
    FKHit emitter_0;
    if(_S722)
    {
        FKLight _S723 = (fcptLight((_S720.y)));
        if(sided_0)
        {
            float _S724 = sign_0(dot_0(geometry_n_1, _S723.position - origin_4));
            float3  lift_n_1 = smooth_n_2 * make_float3 (_S724);
            float3  _S725 = origin_4 + make_float3 (geometry_offset_1) * lift_n_1;
            emitter_point_0 = _S725;
            lift_n_0 = lift_n_1;
        }
        else
        {
            emitter_point_0 = _S706;
            lift_n_0 = smooth_n_2;
        }
        bool _S726 = (_S723.variance) == 0.0f;
        if(_S726)
        {
            float3  _S727 = _S723.position - emitter_point_0;
            float3  _S728 = ((((_S727)) * make_float3(rnorm3df(((_S727)).x, ((_S727)).y, ((_S727)).z))));
            (&sample_0)->dir = _S728;
            float3  _S729 = _S723.color * make_float3 (_S723.intensity) / make_float3 (dot_0(_S727, _S727) * probability_4);
            (&sample_0)->radiance = _S729;
            shadow_1 = _S727;
        }
        else
        {
            float3  _S730 = sampleSphere(_S723.position, _S723.variance, emitter_point_0, _S701.value, _S702.value);
            (&sample_0)->dir = _S730;
            float _S731 = sphereDensity(_S723.position, _S723.variance, emitter_point_0);
            float _S732 = probability_4 * _S731;
            (&sample_0)->density = _S732;
            float3  _S733 = pointLightRadiance(_S723.color, _S723.intensity, _S723.variance);
            float3  _S734 = _S733 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S734;
            FKRay _S735 = Ray_x24init_0(emitter_point_0, (&sample_0)->dir);
            float _S736 = raySphere_0(_S723.position, _S723.variance, &_S735, 4.294967296e+09f);
            float3  _S737 = (&sample_0)->dir * make_float3 (_S736);
            shadow_1 = _S737;
        }
        emitter_0 = _S721;
        emitter_point_0 = _S703;
    }
    else
    {
        uint _S738 = _S720.y;
        uint _S739 = (fcptTriangleOffset((_S738)));
        uint _S740 = _S739 + _S720.z;
        Matrix<float, 3, 3>  _S741 = (fcptWorldTriangle((_S738), (_S740)));
        float _S742 = (F32_sqrt((_S701.value)));
        float2  _S743 = make_float2 (_S742 * (1.0f - _S702.value), _S742 * _S702.value);
        float3  _S744 = mul_0(make_float3 (1.0f - _S742, _S743.x, _S743.y), _S741);
        if(sided_0)
        {
            float _S745 = sign_0(dot_0(geometry_n_1, _S744 - origin_4));
            float3  lift_n_2 = smooth_n_2 * make_float3 (_S745);
            float3  _S746 = origin_4 + make_float3 (geometry_offset_1) * lift_n_2;
            emitter_point_0 = _S746;
            lift_n_0 = lift_n_2;
        }
        else
        {
            bool _S747 = !((dot_0(smooth_n_2, _S744 - origin_4)) > 0.0f);
            if(_S747)
            {
                return sample_0;
            }
            emitter_point_0 = _S706;
            lift_n_0 = smooth_n_2;
        }
        FKHit emitter_1 = Hit_x24init_0(_S743, _S738, _S740, 0U, 0.0f);
        float3  _S748 = _S744 - emitter_point_0;
        float3  _S749 = ((((_S748)) * make_float3(rnorm3df(((_S748)).x, ((_S748)).y, ((_S748)).z))));
        (&sample_0)->dir = _S749;
        float _S750 = solidAngle(probability_4, cross_0(_S741.rows[int(1)] - _S741.rows[int(0)], _S741.rows[int(2)] - _S741.rows[int(0)]), _S748);
        (&sample_0)->density = _S750;
        bool _S751 = (fcptShadowFirst());
        bool _S752 = !_S751;
        if(_S752)
        {
            FKSurface _S753 = (fcptLightSurfaceAt((emitter_1), (_S744), (_S702.state), ((&sample_0)->dir), (context_3->depth), (length_0(_S744 - origin_4))));
            (&sample_0)->random_state = _S753.random_state;
            float3  _S754 = emitted_0(_S753.material.emissive, (&sample_0)->dir, _S753.smooth_n);
            float3  _S755 = _slang_select(_S753.skip, _S703,_S754);
            float3  _S756 = _S755 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S756;
        }
        shadow_1 = _S748;
        emitter_0 = emitter_1;
        emitter_point_0 = _S744;
    }
    FKHit _S757 = emitter_0;
    float3  _S758 = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, context_3, _S702.state, &_S757);
    bool _S759 = (fcptShadowFirst());
    if(_S759)
    {
        _S717 = (emitter_0.instance_index) != 4294967295U;
    }
    else
    {
        _S717 = false;
    }
    if(_S717)
    {
        _S717 = !all_1(_S758 == _S703);
    }
    else
    {
        _S717 = false;
    }
    if(_S717)
    {
        FKSurface _S760 = (fcptLightSurfaceAt((emitter_0), (emitter_point_0), (_S702.state), ((&sample_0)->dir), (context_3->depth), (length_0(emitter_point_0 - origin_4))));
        (&sample_0)->random_state = _S760.random_state;
        float3  _S761 = emitted_0(_S760.material.emissive, (&sample_0)->dir, _S760.smooth_n);
        float3  _S762 = _slang_select(_S760.skip, _S703,_S761);
        float3  _S763 = _S762 / make_float3 ((&sample_0)->density);
        (&sample_0)->radiance = _S763;
    }
    float3  _S764 = (&sample_0)->radiance * _S758;
    bool _S765 = all_1(_S758 == _S703);
    float3  _S766 = _slang_select(_S765, _S703,_S764);
    (&sample_0)->radiance = _S766;
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
    float _S767 = 1.0f / (1.0f + b_1 / a_5 * (b_1 / a_5));
    bool _S768 = b_1 > 0.0f;
    float _S769 = _slang_select(_S768, _S767,1.0f);
    return _S769;
}

static __device__ float emissionWeight_0(NEEVertex * vertex_0, FKHit * hit_1, float3  light_point_1)
{
    bool _S770 = vertex_0->none;
    if(_S770)
    {
        return 1.0f;
    }
    uint _S771 = (fcptLightSlot((*hit_1)));
    float _S772 = lightPdf_0(vertex_0->origin, vertex_0->smooth_n, vertex_0->start, _S771, light_point_1);
    float _S773 = powerHeuristic(vertex_0->pdf, _S772);
    return _S773;
}

static __device__ float3  environment_0(float3  dir_9, uint depth_0, uint lobe_0)
{
    uint2  _S774 = (fcptEnvironmentMapSize());
    bool _S775 = all_0(_S774 > make_uint2 (1U));
    if(_S775)
    {
        float3  _S776 = (fcptEnvMapSample((dir_9), (depth_0), (lobe_0)));
        return _S776;
    }
    float3  _S777 = (fcptAmbient());
    return _S777;
}

static __device__ bool environmentMapped_0()
{
    uint2  _S778 = (fcptEnvironmentCdfSize());
    bool _S779 = !all_0(_S778 > make_uint2 (1U));
    if(_S779)
    {
        return false;
    }
    uint2  _S780 = (fcptEnvironmentMapSize());
    return all_0(_S780 > make_uint2 (1U));
}

static __device__ float escapeWeight_0(float pdf_2, float3  dir_10)
{
    bool _S781 = pdf_2 <= 0.0f;
    bool _S782;
    if(_S781)
    {
        _S782 = true;
    }
    else
    {
        bool _S783 = environmentMapped_0();
        _S782 = !_S783;
    }
    if(_S782)
    {
        return 1.0f;
    }
    float _S784 = environmentPdf_0(dir_10);
    return pdf_2 / (pdf_2 + _S784);
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
    uint2  _S785 = uint2 {global_invocation_id_1.x, global_invocation_id_1.y};
    int2  _S786 = make_int2 ((int)_S785.x, (int)_S785.y);
    uint _S787 = previousSeed_0(_S786);
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
            uint _S788 = previousSeed_0(_S786 + make_int2 (x_16, y_5));
            bool _S789 = _S788 == _S787;
            uint _S790 = _slang_select(_S789, 1U,0U);
            uint count_3 = count_2 + _S790;
            int x_17 = x_16 + int(1);
            x_16 = x_17;
            count_2 = count_3;
        }
        int y_6 = y_5 + int(1);
        y_5 = y_6;
    }
    float _S791 = float(count_2 - 1U) / 288.0f;
    bool _S792 = _S787 != 0U;
    float _S793 = _slang_select(_S792, _S791,0.0f);
    fcptStoreDuplication((_S786), (make_uint4 ((F32_asuint((_S793))), 0U, 0U, 0U)));
    return;
}

__device__ uint stream(uint seed_2, uint index_0)
{
    uint _S794 = hash(index_0);
    uint _S795 = hash(seed_2 ^ _S794);
    return _S795;
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
    float _S796 = rgb_to_greyscale(weight_0);
    bool _S797 = _S796 > 0.0f;
    bool _S798;
    if(_S797)
    {
        _S798 = _S796 < 3.00000000549775576e+38f;
    }
    else
    {
        _S798 = false;
    }
    bool _S799 = !_S798;
    if(_S799)
    {
        return;
    }
    bool _S800 = sel_2->sums;
    if(_S800)
    {
        float3  _S801 = sel_2->color + weight_0;
        sel_2->color = _S801;
        return;
    }
    float _S802 = sel_2->w_sum + _S796;
    sel_2->w_sum = _S802;
    float3  _S803 = sel_2->color + weight_0;
    sel_2->color = _S803;
    Random _S804 = pcg(sel_2->random_state);
    sel_2->random_state = _S804.state;
    bool _S805 = (_S804.value * sel_2->w_sum) <= _S796;
    if(_S805)
    {
        sel_2->r = candidate_0;
    }
    return;
}

__device__ void offerShifted(Selection * sel_3, Reservoir r_3, Shift shifted_0, float mis_0)
{
    Reservoir candidate_1 = r_3;
    float3  _S806 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_1)->f = _S806;
    float _S807 = r_3.jac * shifted_0.jac;
    (&candidate_1)->jac = _S807;
    offer(sel_3, candidate_1, make_float3 (mis_0) * shifted_0.f * make_float3 (r_3.w));
    return;
}

__device__ Reservoir finalize(Selection sel_4, float c_1)
{
    Reservoir r_4 = sel_4.r;
    float _S808 = rgb_to_greyscale((&r_4)->f);
    float _S809 = sel_4.w_sum / _S808;
    bool _S810 = _S808 > 0.0f;
    float _S811 = _slang_select(_S810, _S809,0.0f);
    (&r_4)->w = _S811;
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
    uint2  _S812 = uint2 {global_invocation_id_2.x, global_invocation_id_2.y};
    int2  _S813 = make_int2 ((int)_S812.x, (int)_S812.y);
    float3  _S814 = make_float3 (0.0f);
    FKHit _S815 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S816 = Domain_x24init_0(_S814, _S814, &_S815, 0.0f, 0.0f);
    Domain dom_4 = _S816;
    bool _S817 = (fcptCurrentDomain((_S813), (&dom_4)));
    bool _S818 = !_S817;
    if(_S818)
    {
        Reservoir _S819 = (Reservoir{});
        fcptStoreReservoirPrevious((_S813), (_S819), ((&dom_4)->hit));
        return;
    }
    Reservoir _S820 = (fcptLoadReservoirTemporal((_S813)));
    uint t_13 = 0U;
    float count_4 = 0.0f;
    float c_sum_0 = _S820.c;
    for(;;)
    {
        uint _S821 = (fcptRestirNeighbours());
        if(t_13 < _S821)
        {
        }
        else
        {
            break;
        }
        int2  _S822 = partner_0(_S813, t_13);
        Domain neighbor_0 = _S816;
        bool _S823 = (fcptCurrentDomain((_S822), (&neighbor_0)));
        if(_S823)
        {
            float count_5 = count_4 + 1.0f;
            uint4  _S824 = (fcptReservoirTemporal((_S822), (0U)));
            float c_sum_1 = c_sum_0 + (U32_asfloat((_S824.w)));
            count_4 = count_5;
            c_sum_0 = c_sum_1;
        }
        uint t_14 = t_13 + 1U;
        t_13 = t_14;
    }
    float _S825 = _S820.c / (F32_max((count_4), (1.0f)));
    float _S826 = rgb_to_greyscale(_S820.f);
    bool _S827 = count_4 == 0.0f;
    float _S828 = _slang_select(_S827, 1.0f,0.0f);
    Selection _S829 = (Selection{});
    Selection sel_5 = _S829;
    uint _S830 = (fcptFrame());
    uint _S831 = hash(_S830);
    uint _S832 = global_invocation_id_2.x;
    uint2  _S833 = (fcptRenderSize());
    uint _S834 = stream(_S831, _S832 + _S833.x * global_invocation_id_2.y);
    uint _S835 = stream(_S834, 195U);
    (&sel_5)->random_state = _S835;
    t_13 = 0U;
    float canonical_mis_0 = _S828;
    for(;;)
    {
        uint _S836 = (fcptRestirNeighbours());
        if(t_13 < _S836)
        {
        }
        else
        {
            break;
        }
        int2  _S837 = partner_0(_S813, t_13);
        Domain neighbor_dom_0 = _S816;
        bool _S838 = (fcptCurrentDomain((_S837), (&neighbor_dom_0)));
        if(_S838)
        {
            Reservoir _S839 = (fcptLoadReservoirTemporal((_S837)));
            uint4  _S840 = (fcptShiftData((_S837), (t_13)));
            float4  _S841 = asfloat_0(_S840);
            uint4  _S842 = (fcptShiftData((_S813), (t_13)));
            float4  _S843 = asfloat_0(_S842);
            float _S844 = (_S839.c + _S825) / c_sum_0;
            bool _S845 = _S826 > 0.0f;
            float canonical_mis_1;
            if(_S845)
            {
                float _S846 = _S844 * _S825 * _S826;
                float _S847 = _S825 * _S826;
                float _S848 = rgb_to_greyscale(float3 {_S843.x, _S843.y, _S843.z});
                float canonical_mis_2 = canonical_mis_0 + _S846 / (_S847 + _S839.c * _S848);
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            float _S849 = rgb_to_greyscale(_S839.f);
            float3  _S850 = float3 {_S841.x, _S841.y, _S841.z};
            Shift _S851 = Shift_x24init_0(_S850, _S841.w);
            float _S852 = _S844 * _S839.c * _S849;
            float _S853 = _S839.c * _S849;
            float _S854 = rgb_to_greyscale(_S850);
            offerShifted(&sel_5, _S839, _S851, _S852 / (_S853 + _S825 * _S854));
            canonical_mis_0 = canonical_mis_1;
        }
        uint t_15 = t_13 + 1U;
        t_13 = t_15;
    }
    offerShifted(&sel_5, _S820, Shift_x24init_0(_S820.f, 1.0f), canonical_mis_0);
    Reservoir _S855 = finalize(sel_5, c_sum_0);
    fcptStoreReservoirPrevious((_S813), (_S855), ((&dom_4)->hit));
    fcptStorePreviousLayer((_S813), (5U), (make_uint4 (asuint_0((&(&dom_4)->hit)->uv).x, asuint_0((&(&dom_4)->hit)->uv).y, 0U, 0U)));
    fcptAddColor((_S813), (make_float4 ((&sel_5)->color.x, (&sel_5)->color.y, (&sel_5)->color.z, 0.0f)));
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
    uint _S856 = queuedShift_0(workgroup_id_1, local_invocation_index_4);
    bool _S857 = _S856 != 4294967295U;
    if(_S857)
    {
        uint2  _S858 = make_uint2 (_S856, _S856 >> 14U) & make_uint2 (16383U);
        int2  _S859 = make_int2 ((int)_S858.x, (int)_S858.y);
        ShiftJob _S860 = (ShiftJob{});
        ShiftJob shift_job_0 = _S860;
        Shift _S861 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
        uint _S862 = _S856 >> 28U;
        bool _S863 = spatialJob_0(_S859, _S862, &shift_job_0, true);
        Shift shifted_1;
        if(_S863)
        {
            Domain _S864 = (&shift_job_0)->dom;
            Reservoir _S865 = (&shift_job_0)->r;
            Shift _S866 = passShift_0(&_S864, &_S865);
            shifted_1 = _S866;
        }
        else
        {
            shifted_1 = _S861;
        }
        fcptStoreShiftData((_S859), (_S862), (make_uint4 (asuint_1(shifted_1.f).x, asuint_1(shifted_1.f).y, asuint_1(shifted_1.f).z, (F32_asuint((shifted_1.jac))))));
    }
    return;
}

static __device__ void restir_prepass_0(uint3  global_invocation_id_3, uint local_invocation_index_5)
{
    uint2  _S867 = uint2 {global_invocation_id_3.x, global_invocation_id_3.y};
    int2  _S868 = make_int2 ((int)_S867.x, (int)_S867.y);
    FixedArray<uint, 3>  _S869;
    spatialBins_0(_S868, &_S869);
    FixedArray<uint, 3>  _S870 = _S869;
    uint t_16 = 0U;
    for(;;)
    {
        if(t_16 < 3U)
        {
        }
        else
        {
            break;
        }
        bool _S871 = (_S870[t_16]) == 40U;
        if(_S871)
        {
            fcptStoreShiftData((_S868), (t_16), (make_uint4 (0U)));
        }
        uint t_17 = t_16 + 1U;
        t_16 = t_17;
    }
    FixedArray<uint, 3>  _S872 = _S870;
    queueShifts_0(_S868, &_S872, global_invocation_id_3, local_invocation_index_5);
    return;
}

static __device__ void restir_count_0(uint3  global_invocation_id_4, uint local_invocation_index_6)
{
    uint2  _S873 = uint2 {global_invocation_id_4.x, global_invocation_id_4.y};
    int2  _S874 = make_int2 ((int)_S873.x, (int)_S873.y);
    FixedArray<uint, 3>  _S875;
    spatialBins_0(_S874, &_S875);
    FixedArray<uint, 3>  _S876 = _S875;
    countShifts_0(&_S876, local_invocation_index_6);
    return;
}

static __device__ void restir_temporal_shift_0(uint3  workgroup_id_2, uint local_invocation_index_7)
{
    uint _S877 = queuedShift_0(workgroup_id_2, local_invocation_index_7);
    bool _S878 = _S877 != 4294967295U;
    if(_S878)
    {
        uint2  _S879 = make_uint2 (_S877, _S877 >> 14U) & make_uint2 (16383U);
        int2  _S880 = make_int2 ((int)_S879.x, (int)_S879.y);
        ShiftJob _S881 = (ShiftJob{});
        ShiftJob shift_job_1 = _S881;
        Shift _S882 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
        uint _S883 = _S877 >> 28U;
        bool _S884 = temporalJob_0(_S880, _S883, &shift_job_1, true);
        Shift shifted_2;
        if(_S884)
        {
            if(_S883 == 1U)
            {
                Shift _S885 = (fcptShiftPrevious(((&shift_job_1)->dom), ((&shift_job_1)->r)));
                shifted_2 = _S885;
            }
            else
            {
                Domain _S886 = (&shift_job_1)->dom;
                Reservoir _S887 = (&shift_job_1)->r;
                Shift _S888 = passShift_0(&_S886, &_S887);
                shifted_2 = _S888;
            }
        }
        else
        {
            shifted_2 = _S882;
        }
        fcptStoreTemporalShift((_S880), (_S883), (make_uint4 (asuint_1(shifted_2.f).x, asuint_1(shifted_2.f).y, asuint_1(shifted_2.f).z, (F32_asuint((shifted_2.jac))))));
    }
    return;
}

static __device__ void restir_temporal_prepass_0(uint3  global_invocation_id_5, uint local_invocation_index_8)
{
    uint2  _S889 = uint2 {global_invocation_id_5.x, global_invocation_id_5.y};
    int2  _S890 = make_int2 ((int)_S889.x, (int)_S889.y);
    FixedArray<uint, 3>  _S891;
    temporalBins_0(_S890, &_S891);
    FixedArray<uint, 3>  _S892 = _S891;
    uint t_18 = 0U;
    for(;;)
    {
        if(t_18 < 2U)
        {
        }
        else
        {
            break;
        }
        bool _S893 = (_S892[t_18]) == 40U;
        if(_S893)
        {
            fcptStoreTemporalShift((_S890), (t_18), (make_uint4 (0U)));
        }
        uint t_19 = t_18 + 1U;
        t_18 = t_19;
    }
    FixedArray<uint, 3>  _S894 = _S892;
    queueShifts_0(_S890, &_S894, global_invocation_id_5, local_invocation_index_8);
    return;
}

static __device__ void restir_temporal_count_0(uint3  global_invocation_id_6, uint local_invocation_index_9)
{
    uint2  _S895 = uint2 {global_invocation_id_6.x, global_invocation_id_6.y};
    int2  _S896 = make_int2 ((int)_S895.x, (int)_S895.y);
    FixedArray<uint, 3>  _S897;
    temporalBins_0(_S896, &_S897);
    FixedArray<uint, 3>  _S898 = _S897;
    countShifts_0(&_S898, local_invocation_index_9);
    return;
}

static __device__ float interpolate_0(float a_6, float b_2, float t_20)
{
    return a_6 + (b_2 - a_6) * t_20;
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
    Domain stored_0 = _S903;
    int2  _S908 = make_int2 (int(-1));
    bool _S909 = (fcptStoredDomainInitial((_S900), (_S907.seed), (&stored_0)));
    int2  q_2;
    if(_S909)
    {
        Domain _S910 = stored_0;
        int2  _S911 = temporalNeighbor_0(_S900, &_S910, _S907.seed);
        q_2 = _S911;
    }
    else
    {
        q_2 = _S908;
    }
    bool _S912 = (q_2.x) >= int(0);
    Reservoir r_5;
    if(_S912)
    {
        Reservoir _S913 = (fcptLoadReservoirPrevious((q_2)));
        uint4  _S914 = (fcptDuplication((q_2)));
        float _S915 = (U32_asfloat((_S914.x)));
        uint _S916 = (fcptRestirDecorrelation());
        bool _S917 = _S916 == 1U;
        float _S918 = _slang_select(_S917, _S915,0.0f);
        float _S919 = interpolate_0(20.0f, 1.0f, (F32_pow((_S918), (0.10000000149011612f))));
        float _S920 = (F32_min((_S913.c), (_S919)));
        Domain target_3 = _S903;
        bool _S921 = (_S913.w) > 0.0f;
        bool _S922;
        if(_S921)
        {
            bool _S923 = (fcptStoredDomainInitial((_S900), (_S913.seed), (&target_3)));
            _S922 = _S923;
        }
        else
        {
            _S922 = false;
        }
        if(_S922)
        {
            Domain _S924 = (fcptPreviousDomain((q_2), (_S913.seed)));
            Domain _S925 = _S924;
            Domain _S926 = target_3;
            bool _S927 = temporalIdentity_0(0U, &_S925, &_S926);
            _S922 = _S927;
        }
        else
        {
            _S922 = false;
        }
        float4  _S928;
        if(_S922)
        {
            _S928 = make_float4 (_S913.f.x, _S913.f.y, _S913.f.z, 1.0f);
        }
        else
        {
            uint4  _S929 = (fcptTemporalShift((_S900), (0U)));
            _S928 = asfloat_0(_S929);
        }
        bool _S930 = (_S907.w) > 0.0f;
        if(_S930)
        {
            Domain _S931 = (fcptPreviousDomain((q_2), (_S907.seed)));
            Domain _S932 = _S931;
            Domain _S933 = stored_0;
            bool _S934 = temporalIdentity_0(1U, &_S932, &_S933);
            _S922 = _S934;
        }
        else
        {
            _S922 = false;
        }
        float4  _S935;
        if(_S922)
        {
            _S935 = make_float4 (_S907.f.x, _S907.f.y, _S907.f.z, 1.0f);
        }
        else
        {
            uint4  _S936 = (fcptTemporalShift((_S900), (1U)));
            _S935 = asfloat_0(_S936);
        }
        float _S937 = rgb_to_greyscale(_S907.f);
        float _S938 = rgb_to_greyscale(_S913.f);
        Selection _S939 = (Selection{});
        Selection sel_6 = _S939;
        uint _S940 = (fcptFrame());
        uint _S941 = hash(_S940);
        uint _S942 = global_invocation_id_7.x;
        uint2  _S943 = (fcptRenderSize());
        uint _S944 = stream(_S941, _S942 + _S943.x * global_invocation_id_7.y);
        uint _S945 = stream(_S944, 194U);
        (&sel_6)->random_state = _S945;
        float _S946 = _S907.c * _S937;
        float4  _S947 = _S935;
        float _S948 = rgb_to_greyscale(float3 {_S947.x, _S947.y, _S947.z});
        float _S949 = _S946 / (_S946 + _S920 * _S948);
        float _S950 = _S920 * _S938;
        float4  _S951 = _S928;
        float3  _S952 = float3 {_S951.x, _S951.y, _S951.z};
        float _S953 = rgb_to_greyscale(_S952);
        float _S954 = _S950 / (_S950 + _S907.c * _S953);
        float2  _S955 = make_float2 (_S949, _S954);
        offerShifted(&sel_6, _S907, Shift_x24init_0(_S907.f, 1.0f), _S949);
        offerShifted(&sel_6, _S913, Shift_x24init_0(_S952, _S928.w), _S954);
        Reservoir _S956 = finalize(sel_6, _S907.c + _S920);
        r_5 = _S956;
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

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_0, uint depth_1, uint lobe_2, bool surface_5, float length_2, float width_1, FKHit * own_0, bool fiber_0)
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
    (&_S1001)->own = *own_0;
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

static __device__ float3  samplePhase_0(float g_1, float3  dir_11, uint random_state_10, float * pdf_5)
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
    float3  _S1027 = tangentToWorld(make_float3 (_S1024 * (F32_cos((_S1025))), _S1023, _S1024 * (F32_sin((_S1025)))), dir_11);
    float3  _S1028 = ((((_S1027)) * make_float3(rnorm3df(((_S1027)).x, ((_S1027)).y, ((_S1027)).z))));
    return _S1028;
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_1, float3  emissive_1, float roughness_0, float metallic_0, float transmission_0, float ior_0, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_2, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_2, float velvet_0, float3  toon_2)
{
    BSDFMaterial _S1029;
    (&_S1029)->albedo = albedo_1;
    (&_S1029)->emissive = emissive_1;
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

static __device__ bool arrivesBehind_0(float3  dir_12, float3  n_10)
{
    return (dot_0(dir_12, n_10)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_8, float3  dir_13)
{
    float3  _S1044 = surface_8->geometry_n;
    float _S1045 = facingSign((&surface_8->material)->transmission, surface_8->geometry_n, dir_13);
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

static __device__ MediumSides mediumSides_0(FKSurface * surface_9, FKMedium * medium_0, uint filling_0, float3  dir_14, FKMedium * outside_0)
{
    float3  _S1060 = surface_9->geometry_n;
    MediumSides _S1061 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_9->geometry_n);
    MediumSides sides_0 = _S1061;
    bool _S1062 = surface_9->encloses;
    if(_S1062)
    {
        (&sides_0)->behind = surface_9->volume;
        *&((&(&sides_0)->fillings)->x) = surface_9->fills;
        bool _S1063 = (dot_0(dir_14, _S1060)) > 0.0f;
        if(_S1063)
        {
            (&sides_0)->front = *outside_0;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_10, bool turned_0, float3  extinction_2, uint filling_1, float3  dir_15, uint depth_2, uint lobe_3, float length_3, float width_2, FKHit * own_1, bool fiber_1, FKMedium * outside_1)
{
    float3  _S1064 = surface_10->geometry_n;
    ShadowContext _S1065 = ShadowContext_x24init_0(extinction_2, extinction_2, make_uint2 (filling_1), surface_10->geometry_n, depth_2, lobe_3, true, length_3, width_2, own_1, fiber_1);
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
        MediumSides _S1072 = mediumSides_0(&_S1070, &_S1071, filling_1, dir_15, outside_1);
        ShadowContext _S1073 = ShadowContext_x24init_0(_S1072.behind.extinction, _S1072.front.extinction, _S1072.fillings, _S1064, depth_2, lobe_3, true, length_3, width_2, own_1, fiber_1);
        if(turned_0)
        {
            uint2  _S1074 = _S1072.fillings;
            ShadowContext _S1075 = ShadowContext_x24init_0(_S1072.front.extinction, _S1072.behind.extinction, uint2 {_S1074.y, _S1074.x}, _S1064, depth_2, lobe_3, true, length_3, width_2, own_1, fiber_1);
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
    float t_21;
    if(lobes_13.toon_glossy)
    {
        t_21 = (F32_acos((clamp_1(1.0f - _S1117, -1.0f, 1.0f))));
    }
    else
    {
        t_21 = (F32_asin(((F32_min(((F32_sqrt((2.0f * _S1117)))), (1.0f))))));
    }
    if(t_21 < (lobes_13.toon_a))
    {
    }
    else
    {
        t_21 = (lobes_13.toon_a + lobes_13.toon_b) / 2.0f;
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
        if(t_21 < (lobes_13.toon_a))
        {
            _S1118 = 1.0f;
        }
        else
        {
            _S1118 = (F32_max((1.0f - (t_21 - lobes_13.toon_a) / (F32_max((lobes_13.toon_s), (0.0000152587890625f)))), (0.0f)));
        }
        float integral_1;
        if(lobes_13.toon_glossy)
        {
            integral_1 = 1.0f - (F32_cos(((F32_min((t_21), (lobes_13.toon_a))))));
        }
        else
        {
            float _S1119 = (F32_sin(((F32_min((t_21), (lobes_13.toon_a))))));
            integral_1 = _S1119 * _S1119 / 2.0f;
        }
        bool _S1120 = t_21 > (lobes_13.toon_a);
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
                float _S1123 = (F32_cos((t_21)));
                integral_2 = (1.0f + lobes_13.toon_a / lobes_13.toon_s) * (_S1122 - _S1123) - ((F32_sin((t_21))) - t_21 * _S1123 - ((F32_sin((lobes_13.toon_a))) - lobes_13.toon_a * _S1122)) / lobes_13.toon_s;
            }
            else
            {
                float _S1124 = 2.0f * lobes_13.toon_a;
                float _S1125 = (F32_cos((_S1124)));
                float _S1126 = 2.0f * t_21;
                float _S1127 = (F32_cos((_S1126)));
                integral_2 = (1.0f + lobes_13.toon_a / lobes_13.toon_s) * (_S1125 - _S1127) / 4.0f - ((F32_sin((_S1126))) / 8.0f - t_21 * _S1127 / 4.0f - ((F32_sin((_S1124))) / 8.0f - lobes_13.toon_a * _S1125 / 4.0f)) / lobes_13.toon_s;
            }
            float integral_3 = integral_1 + integral_2;
            integral_2 = integral_3;
        }
        else
        {
            integral_2 = integral_1;
        }
        float _S1128 = _S1118 * (F32_sin((t_21)));
        float _S1129;
        if(lobes_13.toon_glossy)
        {
            _S1129 = 1.0f;
        }
        else
        {
            _S1129 = (F32_cos((t_21)));
        }
        float _S1130 = _S1128 * _S1129;
        float _S1131 = (integral_2 - _S1117) / _S1130;
        bool _S1132 = _S1130 > 0.0f;
        float _S1133 = _slang_select(_S1132, _S1131,0.0f);
        float _S1134 = clamp_1(t_21 - _S1133, 0.0f, lobes_13.toon_b);
        int k_1 = k_0 + int(1);
        t_21 = _S1134;
        k_0 = k_1;
    }
    float _S1135 = 6.28318548202514648f * _S1116.value;
    float _S1136 = (F32_sin((t_21)));
    float3  _S1137 = tangentToWorld(make_float3 (_S1136 * (F32_cos((_S1135))), (F32_cos((t_21))), _S1136 * (F32_sin((_S1135)))), lobes_13.toon_axis);
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

static __device__ float3  reflect_0(float3  i_25, float3  n_11)
{
    return i_25 - make_float3 (2.0f * dot_0(n_11, i_25)) * n_11;
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

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_10, float3  n_12, BSDFMaterial material_22, float eta_i_16, float eta_o_16, uint random_init_0, float2  screen_space_0)
{
    uint random_state_19 = random_init_0;
    float3  _S1151 = negate_0(in_dir_10);
    float _S1152 = dot_0(n_12, _S1151);
    float _S1153 = sign_0(_S1152);
    float3  n_i_14 = n_12 * make_float3 (_S1153);
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
        float3  front_n_0;
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
                front_n_0 = _S1345;
            }
            else
            {
                front_n_0 = throughput_2;
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
            float3  _S1349 = front_n_0;
            float _S1350 = geometry_density_0;
            scatter_2 = _S1346;
            geometry_density_0 = geometry_density_1;
            threshold_0 = _S1350;
            surface_12 = _S1342;
            front_n_0 = _S1336.smooth_n;
            throughput_5 = _S1349;
            turned_1 = _S1338;
        }
        else
        {
            scatter_2 = false;
            geometry_density_0 = 0.0f;
            surface_12 = _S1325;
            front_n_0 = _S1177;
            throughput_5 = throughput_2;
            is_inside_6 = is_inside_5;
        }
        bool _S1351;
        if(scatter_2)
        {
            _S1351 = (&prev_0)->rough;
        }
        else
        {
            _S1351 = false;
        }
        bool _S1352;
        if(_S1351)
        {
            _S1352 = ((&prev_0)->pdf * geometry_density_0 * threshold_0) <= 1.0f;
        }
        else
        {
            _S1352 = false;
        }
        FKSurface _S1353 = surface_12;
        FKSurface _S1354 = surface_12;
        float _S1355 = dot_0(surface_12.smooth_n, - (&ray_2)->unit_direction);
        float2  _S1356 = vertexEta(_S1353.material, _S1355);
        bool _S1357;
        if(scatter_2)
        {
            uint _S1358 = (fcptMaxBounces());
            bool _S1359 = b_5 >= _S1358;
            if(_S1359)
            {
                _S1357 = true;
            }
            else
            {
                bool _S1360 = neeDecision(_S1353.material, _S1355, _S1356.x, _S1356.y);
                _S1357 = _S1360;
            }
        }
        else
        {
            _S1357 = false;
        }
        bool _S1361;
        if(passes_0)
        {
            _S1361 = true;
        }
        else
        {
            _S1361 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S1361)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S1357;
        }
        bool _S1362 = (fcptHairUsed());
        bool _S1363;
        if(_S1362)
        {
            float3  _S1364 = surface_12.hair;
            _S1363 = (dot_0(_S1364, _S1364)) > 0.0f;
        }
        else
        {
            _S1363 = false;
        }
        bool _S1365;
        if(_S1363)
        {
            _S1365 = true;
        }
        else
        {
            BSDFMaterial _S1366 = _S1353.material;
            bool _S1367 = isTranslucent_0(&_S1366);
            _S1365 = _S1367;
        }
        bool _S1368;
        if(_S1365)
        {
            _S1368 = true;
        }
        else
        {
            bool _S1369 = (_S1353.material.transmission) > 0.0f;
            if(_S1369)
            {
                uint _S1370 = (fcptLayers((hit_4)));
                _S1368 = _S1370 == 1U;
            }
            else
            {
                _S1368 = false;
            }
        }
        float3  _S1371 = emitted_0(_S1353.material.emissive, (&ray_2)->unit_direction, front_n_0);
        float3  emission_0;
        if(_S1319)
        {
            float3  _S1372 = (fcptCalculatePointLightContrib(((&hit_4)->instance_index)));
            emission_0 = _S1372;
        }
        else
        {
            emission_0 = _S1371;
        }
        bool _S1373 = !replay_1;
        bool _S1374;
        if(_S1373)
        {
            _S1374 = true;
        }
        else
        {
            _S1374 = b_5 >= _S1193;
        }
        bool _S1375;
        if(_S1374)
        {
            float _S1376 = rgb_to_greyscale(emission_0);
            _S1375 = _S1376 > 0.0f;
        }
        else
        {
            _S1375 = false;
        }
        float3  emission_1;
        if(_S1375)
        {
            NEEVertex _S1377 = nee_vertex_0;
            FKHit _S1378 = hit_4;
            float _S1379 = emissionWeight_0(&_S1377, &_S1378, (&ray_2)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S1379);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S1380;
        if(replay_1)
        {
            _S1380 = _S1182 == 1U;
        }
        else
        {
            _S1380 = false;
        }
        bool _S1381;
        if(_S1380)
        {
            _S1381 = b_5 > _S1181;
        }
        else
        {
            _S1381 = false;
        }
        bool _S1382;
        if(_S1381)
        {
            _S1382 = b_5 == _S1180;
        }
        else
        {
            _S1382 = false;
        }
        bool _S1383;
        if(_S1382)
        {
            bool _S1384 = _S1183 == 1U;
            if(_S1384)
            {
                _S1383 = true;
            }
            else
            {
                _S1383 = _S1183 == 2U;
            }
        }
        else
        {
            _S1383 = false;
        }
        if(_S1383)
        {
            bool _S1385 = _S1319 != (_S1183 == 2U);
            if(_S1385)
            {
                return _S1178;
            }
            return Shift_x24init_0(throughput_5 * emission_1 / make_float3 (r_8->jac), density_2 / r_8->jac);
        }
        uint _S1386 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1387 = _S1386 == 1U;
        Reservoir here_0 = chain_0;
        uint _S1388 = insertBits_0(0U, b_5, 5U, 5U);
        uint _S1389 = insertBits_0(_S1388, 1U, 10U, 2U);
        uint _S1390 = insertBits_0(_S1389, (&prev_0)->lobe, 15U, 3U);
        bool _S1391 = (&prev_0)->inside;
        uint _S1392 = _slang_select(_S1391, 1U,0U);
        uint _S1393 = insertBits_0(_S1390, _S1392, 22U, 1U);
        (&here_0)->path = _S1393;
        float _S1394 = (&prev_0)->pdf * geometry_density_0;
        (&here_0)->jac = _S1394;
        fcptWithReservoirHit((&here_0), (&hit_4));
        bool _S1395;
        if(replay_1)
        {
            _S1395 = _S1182 == 1U;
        }
        else
        {
            _S1395 = false;
        }
        bool _S1396;
        if(_S1395)
        {
            _S1396 = b_5 == _S1181;
        }
        else
        {
            _S1396 = false;
        }
        bool _S1397 = b_5 == _S1193;
        bool _S1398;
        if(_S1397)
        {
            bool _S1399 = !scatter_2;
            if(_S1399)
            {
                _S1398 = true;
            }
            else
            {
                bool _S1400 = _S1182 != 1U;
                if(_S1400)
                {
                    _S1398 = _S1182 != 3U;
                }
                else
                {
                    _S1398 = false;
                }
            }
        }
        else
        {
            _S1398 = false;
        }
        bool _S1401;
        if(_S1398)
        {
            _S1401 = _S1182 == 2U;
        }
        else
        {
            _S1401 = false;
        }
        bool _S1402;
        if(_S1401)
        {
            _S1402 = !_S1352;
        }
        else
        {
            _S1402 = false;
        }
        bool _S1403;
        if(_S1402)
        {
            _S1403 = _S1183 != 4U;
        }
        else
        {
            _S1403 = false;
        }
        bool _S1404 = _S1181 == _S1180;
        bool _S1405;
        if(_S1404)
        {
            _S1405 = _S1183 == 0U;
        }
        else
        {
            _S1405 = false;
        }
        bool _S1406;
        if(_S1405)
        {
            _S1406 = ((&hit_4)->instance_index) == (_S1194.instance_index);
        }
        else
        {
            _S1406 = false;
        }
        bool _S1407;
        if(_S1406)
        {
            _S1407 = ((&hit_4)->triangle_index) == (_S1194.triangle_index);
        }
        else
        {
            _S1407 = false;
        }
        bool _S1408;
        if(_S1407)
        {
            _S1408 = _S1352;
        }
        else
        {
            _S1408 = false;
        }
        bool _S1409 = _slang_select(_S1396, _S1408,_S1403);
        bool _S1410;
        if(nee_0)
        {
            _S1410 = _slang_select(replay_1, _S1409,scatter_2);
        }
        else
        {
            _S1410 = false;
        }
        TreeSample _S1411 = TreeSample_x24init_0(_S1177, _S1177, 0.0f, 0U);
        uint2  _S1412 = make_uint2 (0U);
        float2  _S1413 = make_float2 (0.0f);
        FKHit _S1414 = Hit_x24init_0(_S1413, 4294967295U, 0U, 0U, 0.0f);
        FKHit _S1415 = _S1414;
        ShadowContext _S1416 = ShadowContext_x24init_0(_S1177, _S1177, _S1412, _S1177, 0U, 0U, false, 0.0f, 0.0f, &_S1415, false);
        bool _S1417;
        if(nee_0)
        {
            _S1417 = _S1374;
        }
        else
        {
            _S1417 = false;
        }
        ShadowContext context_5;
        if(_S1417)
        {
            uint _S1418 = arrivalLobe_0(b_5, (&prev_0)->lobe);
            FKMedium _S1419 = (fcptOutsideMedium((hit_4)));
            FKSurface _S1420 = surface_12;
            FKHit _S1421 = hit_4;
            FKMedium _S1422 = _S1419;
            ShadowContext _S1423 = shadowContext_0(&_S1420, turned_1, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_5, _S1418, (&hit_4)->distance, width_3, &_S1421, _S1363, &_S1422);
            context_5 = _S1423;
        }
        else
        {
            context_5 = _S1416;
        }
        float3  throughput_6;
        float3  lit_0;
        if(_S1410)
        {
            float3  _S1424 = (&ray_2)->origin;
            if(_S1363)
            {
                throughput_6 = _S1177;
            }
            else
            {
                throughput_6 = _S1354.smooth_n;
            }
            FKSurface _S1425 = surface_12;
            uint _S1426 = stream(_S1205, b_5 + 64U);
            ShadowContext _S1427 = context_5;
            TreeSample _S1428 = sampleLightTree_0(_S1424, throughput_6, surface_12.geometry_n, surface_12.geometry_offset, _S1368, _S1426, &_S1427);
            bool _S1429 = any_1((_S1428.radiance) != _S1177);
            if(_S1429)
            {
                if(_S1363)
                {
                    uint _S1430 = (fcptMaxBounces());
                    bool _S1431 = b_5 < _S1430;
                    FKSurface _S1432 = surface_12;
                    TreeSample _S1433 = _S1428;
                    float3  _S1434 = hairLight_0(&_S1432, (&ray_2)->unit_direction, &_S1433, _S1431);
                    lit_0 = _S1434;
                }
                else
                {
                    float _S1435 = _S1356.x;
                    float _S1436 = _S1356.y;
                    uint _S1437 = (fcptMaxBounces());
                    bool _S1438 = b_5 < _S1437;
                    TreeSample _S1439 = _S1428;
                    BSDFMaterial _S1440 = _S1353.material;
                    float3  _S1441 = lightBSDF_0((&ray_2)->unit_direction, &_S1439, _S1354.smooth_n, _S1425.geometry_n, &_S1440, _S1435, _S1436, _S1438, surface_12.random_state);
                    lit_0 = _S1441;
                }
            }
            else
            {
                lit_0 = _S1177;
            }
            light_3 = _S1428;
        }
        else
        {
            light_3 = _S1411;
            lit_0 = _S1177;
        }
        bool viewed_1;
        bool refracted_4;
        bool wrong_side_0;
        bool _S1442;
        bool _S1443;
        float density_4;
        if(_S1396)
        {
            bool _S1444 = !_S1352;
            if(_S1444)
            {
                return _S1178;
            }
            float3  throughput_7 = throughput_5 * make_float3 (geometry_density_0);
            float density_5 = density_2 * geometry_density_0;
            if(_S1404)
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
            if(_S1404)
            {
                refracted_4 = _S1183 == 0U;
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
            {
                bool _S1445 = !nee_0;
                if(_S1445)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S1446 = rgb_to_greyscale(light_3.radiance);
                    passes_0 = !(_S1446 > 0.0f);
                }
                if(passes_0)
                {
                    return _S1178;
                }
                return Shift_x24init_0(throughput_7 * lit_0 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1404)
            {
                wrong_side_0 = _S1183 == 4U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                bool _S1447 = !nee_0;
                if(_S1447)
                {
                    return _S1178;
                }
                float _S1448 = environmentPdf_0(r_8->dir);
                float3  _S1449 = skyBSDF((&ray_2)->unit_direction, r_8->dir, surface_12, _S1356, is_inside_6, _S1448, surface_12.random_state);
                return Shift_x24init_0(throughput_7 * _S1449 * r_8->radiance / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            uint _S1450 = extractBits_0(_S1179, 21U, 1U);
            bool _S1451 = nee_0 != (_S1450 == 1U);
            if(_S1451)
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
                viewed_1 = _S1397;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                bool _S1452 = !scatter_2;
                if(_S1452)
                {
                    refracted_4 = true;
                }
                else
                {
                    bool _S1453 = _S1182 != 1U;
                    if(_S1453)
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
                bool _S1454 = _S1182 == 2U;
                if(_S1454)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1352;
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
                    if(_S1363)
                    {
                        return _S1178;
                    }
                    uint _S1455 = stream(_S1205, b_5 + 448U);
                    FKRay _S1456 = ray_2;
                    FKSurface _S1457 = surface_12;
                    ShadowContext _S1458 = context_5;
                    SkySample _S1459 = sampleSky_0(&_S1456, &_S1457, _S1356, is_inside_6, _S1455, surface_12.random_state, &_S1458);
                    return Shift_x24init_0(throughput_5 * _S1459.color, 1.0f);
                }
                if(_S1454)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1352;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float _S1460 = rgb_to_greyscale(light_3.radiance);
                    bool _S1461 = !(_S1460 > 0.0f);
                    if(_S1461)
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
                    passes_0 = !_S1352;
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
                if(_S1373)
                {
                    wrong_side_0 = scatter_2;
                }
                else
                {
                    wrong_side_0 = false;
                }
                if(wrong_side_0)
                {
                    bool _S1462 = b_5 > 0U;
                    if(_S1462)
                    {
                        Reservoir candidate_5 = chain_0;
                        if(_S1387)
                        {
                            float3  _S1463 = safeDivide(throughput_5 * emission_1, chain_throughput_0);
                            (&candidate_5)->radiance = _S1463;
                        }
                        else
                        {
                            if(_S1352)
                            {
                                candidate_5 = here_0;
                            }
                        }
                        float3  _S1464 = throughput_5 * emission_1;
                        Reservoir _S1465 = withEnd(candidate_5, 1U, b_5, _S1464);
                        offer(sel_7, _S1465, _S1464 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    else
                    {
                        float3  _S1466 = throughput_5 * emission_1;
                        float3  _S1467 = sel_7->glow + _S1466;
                        sel_7->glow = _S1467;
                    }
                    if(nee_0)
                    {
                        float3  _S1468 = throughput_5 * lit_0;
                        Reservoir candidate_6 = chain_0;
                        if(_S1387)
                        {
                            float3  _S1469 = safeDivide(_S1468, chain_throughput_0);
                            (&candidate_6)->radiance = _S1469;
                        }
                        else
                        {
                            if(_S1352)
                            {
                                candidate_6 = here_0;
                                uint _S1470 = insertBits_0((&candidate_6)->path, 1U, 21U, 1U);
                                (&candidate_6)->path = _S1470;
                                (&candidate_6)->dir = light_3.dir;
                                (&candidate_6)->radiance = light_3.radiance;
                            }
                            else
                            {
                                uint _S1471 = insertBits_0(0U, b_5 + 1U, 5U, 5U);
                                uint _S1472 = insertBits_0(_S1471, 2U, 10U, 2U);
                                (&candidate_6)->path = _S1472;
                            }
                        }
                        Reservoir _S1473 = withEnd(candidate_6, 0U, b_5, _S1468);
                        offer(sel_7, _S1473, _S1468 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    if(nee_0)
                    {
                        if(_S1363)
                        {
                            _S1442 = false;
                        }
                        else
                        {
                            bool _S1474 = environmentMapped_0();
                            _S1442 = _S1474;
                        }
                    }
                    else
                    {
                        _S1442 = false;
                    }
                    if(_S1442)
                    {
                        uint _S1475 = (fcptMaxBounces());
                        _S1443 = b_5 < _S1475;
                    }
                    else
                    {
                        _S1443 = false;
                    }
                    if(_S1443)
                    {
                        uint _S1476 = stream(_S1205, b_5 + 448U);
                        FKRay _S1477 = ray_2;
                        FKSurface _S1478 = surface_12;
                        ShadowContext _S1479 = context_5;
                        SkySample _S1480 = sampleSky_0(&_S1477, &_S1478, _S1356, is_inside_6, _S1476, surface_12.random_state, &_S1479);
                        float3  _S1481 = throughput_5 * _S1480.color;
                        Reservoir candidate_7 = chain_0;
                        if(_S1387)
                        {
                            float3  _S1482 = safeDivide(_S1481, chain_throughput_0);
                            (&candidate_7)->radiance = _S1482;
                        }
                        else
                        {
                            if(_S1352)
                            {
                                candidate_7 = here_0;
                                uint _S1483 = insertBits_0((&candidate_7)->path, 1U, 21U, 1U);
                                (&candidate_7)->path = _S1483;
                                (&candidate_7)->dir = _S1480.dir;
                                (&candidate_7)->radiance = _S1480.radiance;
                            }
                            else
                            {
                                uint _S1484 = insertBits_0(0U, b_5 + 1U, 5U, 5U);
                                uint _S1485 = insertBits_0(_S1484, 2U, 10U, 2U);
                                (&candidate_7)->path = _S1485;
                            }
                        }
                        Reservoir _S1486 = withEnd(candidate_7, 4U, b_5, _S1481);
                        offer(sel_7, _S1486, _S1481 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                }
            }
            throughput_6 = throughput_5;
            density_4 = density_2;
        }
        bool _S1487;
        bool _S1488;
        bool _S1489;
        bool straight_0;
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
        bool _S1501;
        bool _S1502;
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
                viewed_1 = _S1397;
            }
            else
            {
                viewed_1 = false;
            }
            uint _S1503 = extractBits_0(_S1179, 15U, 3U);
            uint _S1504 = extractBits_0(_S1179, 18U, 3U);
            uint _S1505 = _slang_select(_S1396, _S1504,_S1503);
            float3  _S1506 = r_8->dir;
            bool refracted_5 = _S1505 == 1U;
            SampleBSDF _S1507 = SampleBSDF_x24init_0(_S1177, _S1177, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_5 = _S1507;
            float3  reconnection_1;
            if(viewed_1)
            {
                uint _S1508 = extractBits_0(_S1179, 22U, 1U);
                bool _S1509 = is_inside_6 != (_S1508 == 1U);
                if(_S1509)
                {
                    return _S1178;
                }
                bool _S1510 = _S1182 == 1U;
                if(_S1510)
                {
                    float3  _S1511 = (fcptHitPosition((_S1194)));
                    throughput_8 = _S1511;
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
                    BSDFMaterial _S1512 = _S1353.material;
                    bool _S1513 = isTranslucent_0(&_S1512);
                    if(_S1513)
                    {
                        refracted_4 = _S1505 == 0U;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                    if(refracted_4)
                    {
                        float3  _S1514 = throughput_8 - (&ray_2)->origin;
                        float3  _S1515 = _slang_select(_S1510, _S1514,_S1506);
                        wrong_side_0 = (dot_0(_S1354.smooth_n, _S1515) * _S1355) < 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    refracted_4 = wrong_side_0;
                }
                if(_S1510)
                {
                    float3  _S1516 = (&ray_2)->origin;
                    FKSurface _S1517 = surface_12;
                    float3  _S1518 = - _S1354.smooth_n;
                    bool _S1519 = is_inside_6 != refracted_4;
                    float3  _S1520 = _slang_select(_S1519, _S1518,_S1354.smooth_n);
                    float3  _S1521 = throughput_8 - (_S1516 + make_float3 (_S1517.geometry_offset) * _S1520);
                    float3  _S1522 = ((((_S1521)) * make_float3(rnorm3df(((_S1521)).x, ((_S1521)).y, ((_S1521)).z))));
                    reconnection_1 = _S1522;
                }
                else
                {
                    reconnection_1 = _S1506;
                }
                if(_S1363)
                {
                    wrong_side_0 = false;
                }
                else
                {
                    bool _S1523 = wrongSide_0(is_inside_6, refracted_4, reconnection_1, surface_12.geometry_n);
                    wrong_side_0 = _S1523;
                }
                if(wrong_side_0)
                {
                    return _S1178;
                }
                float3  _S1524 = throughput_8;
                throughput_8 = reconnection_1;
                b_8 = _S1505;
                wrong_side_0 = false;
                reconnection_1 = _S1524;
            }
            else
            {
                bool _S1525 = !_S1396;
                if(_S1525)
                {
                    SampleBSDF bsdf_sampled_0;
                    SampleBSDF _S1526;
                    if(_S1363)
                    {
                        SampleBSDF _S1527 = (fcptSampleHair((surface_12.hair), (_S1353.material.albedo), (_S1353.material.specular_tint), ((&ray_2)->unit_direction), (surface_12.random_state)));
                        _S1526 = _S1527;
                    }
                    else
                    {
                        SampleBSDF _S1528 = sampleBSDF((&ray_2)->unit_direction, _S1354.smooth_n, _S1353.material, _S1356.x, _S1356.y, surface_12.random_state, _S1413);
                        _S1526 = _S1528;
                    }
                    bsdf_sampled_0 = _S1526;
                    if(_S1363)
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
                    if(_S1363)
                    {
                        wrong_side_0 = false;
                    }
                    else
                    {
                        bool _S1529 = wrongSide_0(is_inside_6, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, surface_12.geometry_n);
                        wrong_side_0 = _S1529;
                    }
                    if(wrong_side_0)
                    {
                        _S1442 = (_S1353.material.transmission) > 0.0f;
                    }
                    else
                    {
                        _S1442 = false;
                    }
                    if(_S1442)
                    {
                        SampleBSDF _S1530 = sampleBSDF((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n, _S1353.material, _S1356.x, _S1356.y, (&bsdf_sampled_0)->random_state, _S1413);
                        (&bsdf_sampled_0)->unit_direction = _S1530.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1530.refracted;
                        (&bsdf_sampled_0)->throughput = _S1530.throughput;
                        (&bsdf_sampled_0)->lobe = _S1530.lobe;
                    }
                    else
                    {
                        if(wrong_side_0)
                        {
                            float3  _S1531 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n)) * surface_12.geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1531;
                        }
                    }
                    uint _S1532 = (&bsdf_sampled_0)->lobe;
                    float3  _S1533 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1534 = (&bsdf_sampled_0)->refracted;
                    lobe_5 = bsdf_sampled_0;
                    float _S1535 = (&bsdf_sampled_0)->pdf;
                    float _S1536 = _slang_select(wrong_side_0, 0.0f,_S1535);
                    (&lobe_5)->pdf = _S1536;
                    throughput_8 = _S1533;
                    b_8 = _S1532;
                    refracted_4 = _S1534;
                }
                else
                {
                    throughput_8 = _S1506;
                    b_8 = _S1505;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(viewed_1)
            {
                _S1442 = true;
            }
            else
            {
                _S1442 = _S1396;
            }
            float3  chain_throughput_1;
            if(_S1442)
            {
                if(_S1363)
                {
                    SampleBSDF _S1537 = (fcptConnectHair((surface_12.hair), (_S1353.material.albedo), (_S1353.material.specular_tint), ((&ray_2)->unit_direction), (throughput_8)));
                    lobe_5 = _S1537;
                }
                else
                {
                    float3  _S1538 = (&ray_2)->unit_direction;
                    float _S1539 = sign_0(_S1355);
                    float3  _S1540 = _S1354.smooth_n * make_float3 (_S1539);
                    float _S1541 = dot_0(_S1540, throughput_8);
                    float _S1542 = _S1353.material.roughness;
                    float _S1543 = _S1542 * _S1542;
                    AnisotropicFrame _S1544 = anisotropicFrame(_S1353.material, _S1540);
                    float3  _S1545 = negate_0(_S1538);
                    SheenProfile _S1546 = sheenProfile(_S1545, _S1540, _S1353.material);
                    float3  _S1547 = reflectedHalf(_S1538, throughput_8);
                    bool _S1548 = b_8 == 1U;
                    if(_S1548)
                    {
                        float3  _S1549 = refractedHalf(_S1538, throughput_8, _S1354.smooth_n, _S1356.x, _S1356.y);
                        throughput_9 = _S1549;
                    }
                    else
                    {
                        throughput_9 = _S1547;
                    }
                    bool _S1550 = b_8 == 0U;
                    if(_S1550)
                    {
                        _S1443 = true;
                    }
                    else
                    {
                        _S1443 = b_8 == 6U;
                    }
                    if(_S1443)
                    {
                        float3  _S1551 = sampledHalf(_S1538, _S1354.smooth_n, _S1353.material, surface_12.random_state, _S1544);
                        throughput_10 = _S1551;
                    }
                    else
                    {
                        throughput_10 = throughput_9;
                    }
                    float3  _S1552 = negate_0(_S1538);
                    float _S1553 = _S1356.x;
                    float _S1554 = _S1356.y;
                    BSDFLobes _S1555 = bsdfLobes(_S1538, _S1552, _S1540, throughput_10, _S1353.material, _S1553, _S1554, _S1544, _S1546);
                    BSDFLobes lobe_terms_1 = _S1555;
                    float _S1556 = translucentShare(_S1353.material);
                    (&lobe_terms_1)->translucent_share = _S1556;
                    switch(b_8)
                    {
                    case 0U:
                        {
                            float _S1557 = diffusePDF(_S1541, 0.0f, (F32_abs((_S1355))), _S1543, lobe_terms_1, _S1553, _S1554);
                            float3  _S1558 = diffuseBSDF(throughput_8, _S1540, _S1543, _S1353.material, lobe_terms_1);
                            density_6 = _S1557;
                            chain_throughput_1 = _S1558;
                            break;
                        }
                    case 1U:
                        {
                            float _S1559 = refractPDF(_S1541, dot_0(throughput_8, throughput_10), (F32_abs((_S1355))), _S1543, lobe_terms_1, _S1553, _S1554);
                            float3  _S1560 = refractBSDF(throughput_8, _S1540, _S1543, _S1353.material, lobe_terms_1);
                            density_6 = _S1559;
                            chain_throughput_1 = _S1560;
                            break;
                        }
                    case 4U:
                        {
                            float _S1561 = sheenVelvetPDF(_S1541, 0.0f, (F32_abs((_S1355))), _S1543, lobe_terms_1, _S1553, _S1554);
                            float3  _S1562 = sheenVelvetBSDF(throughput_8, _S1540, _S1543, _S1353.material, lobe_terms_1);
                            density_6 = _S1561;
                            chain_throughput_1 = _S1562;
                            break;
                        }
                    case 6U:
                        {
                            float _S1563 = toonPDF(_S1541, dot_0(throughput_8, (&lobe_terms_1)->toon_axis), (F32_abs((_S1355))), _S1543, lobe_terms_1, _S1553, _S1554);
                            float3  _S1564 = toonBSDF(throughput_8, _S1540, _S1543, _S1353.material, lobe_terms_1);
                            density_6 = _S1563;
                            chain_throughput_1 = _S1564;
                            break;
                        }
                    default:
                        {
                            float _S1565 = reflectPDF(_S1541, 0.0f, (F32_abs((_S1355))), _S1543, lobe_terms_1, _S1553, _S1554);
                            float3  _S1566 = reflectBSDF(throughput_8, _S1540, _S1543, _S1353.material, lobe_terms_1);
                            density_6 = _S1565;
                            chain_throughput_1 = _S1566;
                            break;
                        }
                    }
                    bool _S1567 = density_6 > 0.0f;
                    if(_S1567)
                    {
                        SampleBSDF _S1568 = SampleBSDF_x24init_0(throughput_8, chain_throughput_1, surface_12.random_state, _S1548, b_8, density_6);
                        lobe_5 = _S1568;
                    }
                }
            }
            bool _S1569 = b_8 == 0U;
            if(_S1569)
            {
                _S1443 = true;
            }
            else
            {
                _S1443 = b_8 == 4U;
            }
            if(_S1443)
            {
                _S1487 = true;
            }
            else
            {
                _S1487 = b_8 == 6U;
            }
            if(_S1363)
            {
                _S1488 = false;
            }
            else
            {
                bool _S1570 = !_S1487;
                if(_S1570)
                {
                    bool _S1571 = (_S1353.material.roughness) == 0.0f;
                    if(_S1571)
                    {
                        _S1488 = true;
                    }
                    else
                    {
                        bool _S1572 = b_8 == 1U;
                        if(_S1572)
                        {
                            _S1488 = (_S1356.x) == (_S1356.y);
                        }
                        else
                        {
                            _S1488 = false;
                        }
                    }
                }
                else
                {
                    _S1488 = false;
                }
            }
            bool _S1573 = !_S1363;
            if(_S1573)
            {
                _S1489 = b_8 == 1U;
            }
            else
            {
                _S1489 = false;
            }
            if(_S1489)
            {
                straight_0 = (_S1353.material.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S1490 = _S1573;
            }
            else
            {
                _S1490 = false;
            }
            if(_S1490)
            {
                _S1491 = b_8 == 1U;
            }
            else
            {
                _S1491 = false;
            }
            if(_S1491)
            {
                _S1492 = (_S1356.x) == (_S1356.y);
            }
            else
            {
                _S1492 = false;
            }
            BSDFMaterial _S1574 = _S1353.material;
            bool _S1575 = isTranslucent_0(&_S1574);
            if(_S1575)
            {
                _S1493 = _S1569;
            }
            else
            {
                _S1493 = false;
            }
            if(_S1493)
            {
                _S1494 = (dot_0(throughput_8, surface_12.geometry_n)) < 0.0f;
            }
            else
            {
                _S1494 = false;
            }
            if(nee_0)
            {
                _S1495 = !_S1488;
            }
            else
            {
                _S1495 = false;
            }
            if(_S1495)
            {
                _S1496 = !wrong_side_0;
            }
            else
            {
                _S1496 = false;
            }
            if(_S1496)
            {
                float _S1576 = (&lobe_5)->pdf;
                float3  _S1577 = (&ray_2)->origin;
                float3  _S1578 = _slang_select(_S1368, _S1177,_S1354.smooth_n);
                float3  _S1579 = (&ray_2)->origin;
                FKSurface _S1580 = surface_12;
                float3  _S1581 = - _S1354.smooth_n;
                float3  _S1582 = _slang_select(_S1494, _S1581,_S1354.smooth_n);
                NEEVertex _S1583 = NEEVertex_x24init_0(false, _S1576, _S1577, _S1578, _S1579 + make_float3 (_S1580.geometry_offset) * _S1582);
                nee_vertex_0 = _S1583;
            }
            else
            {
                if(_S1363)
                {
                    _S1497 = true;
                }
                else
                {
                    bool _S1584 = b_8 != 1U;
                    if(_S1584)
                    {
                        _S1497 = true;
                    }
                    else
                    {
                        _S1497 = (_S1356.x) != (_S1356.y);
                    }
                }
                if(_S1497)
                {
                    (&nee_vertex_0)->none = true;
                }
            }
            bool _S1585 = ((&lobe_5)->pdf) > 0.0f;
            if(_S1585)
            {
                if(_S1487)
                {
                    _S1497 = true;
                }
                else
                {
                    _S1497 = ((&lobe_5)->pdf * (&prev_0)->cos / ((&hit_4)->distance * (&hit_4)->distance) * threshold_0) <= 1.0f;
                }
            }
            else
            {
                _S1497 = false;
            }
            bool _S1586 = ((&lobe_5)->pdf) > 0.0f;
            if(_S1586)
            {
                if(_S1487)
                {
                    _S1498 = true;
                }
                else
                {
                    _S1498 = (_S1353.material.roughness) >= 0.20000000298023224f;
                }
            }
            else
            {
                _S1498 = false;
            }
            if(_S1396)
            {
                bool _S1587 = !_S1497;
                if(_S1587)
                {
                    return _S1178;
                }
                bool _S1588 = _S1183 != 1U;
                if(_S1588)
                {
                    _S1499 = _S1183 != 2U;
                }
                else
                {
                    _S1499 = false;
                }
                if(_S1499)
                {
                    float _S1589 = (&lobe_5)->pdf;
                    float _S1590 = _slang_select(nee_0, _S1589,0.0f);
                    float _S1591 = escapeWeight_0(_S1590, _S1506);
                    if(_S1404)
                    {
                        passes_0 = _S1189;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1592 = _slang_select(passes_0, _S1591,1.0f);
                    return Shift_x24init_0(throughput_6 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf)) * r_8->radiance * make_float3 (_S1592) / make_float3 (r_8->jac), density_4 * (&lobe_5)->pdf / r_8->jac);
                }
                float3  _S1593 = throughput_6 * make_float3 ((&lobe_5)->pdf);
                float _S1594 = density_4 * (&lobe_5)->pdf;
                throughput_9 = _S1593;
                density_6 = _S1594;
            }
            else
            {
                throughput_9 = throughput_6;
                density_6 = density_4;
            }
            uint _S1595 = (fcptLayers((hit_4)));
            bool _S1596 = _S1595 > 1U;
            if(_S1596)
            {
                _S1499 = (b_8 == 1U) != passes_0;
            }
            else
            {
                _S1499 = false;
            }
            if(viewed_1)
            {
                _S1500 = _S1499;
            }
            else
            {
                _S1500 = false;
            }
            if(_S1500)
            {
                return _S1178;
            }
            if(replay_1)
            {
                _S1501 = b_5 <= _S1193;
            }
            else
            {
                _S1501 = false;
            }
            if(_S1501)
            {
                _S1502 = _S1352;
            }
            else
            {
                _S1502 = false;
            }
            bool _S1597;
            if(_S1502)
            {
                _S1597 = _S1497;
            }
            else
            {
                _S1597 = false;
            }
            bool _S1598;
            if(_S1597)
            {
                _S1598 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S1598 = !_S1498;
                }
                else
                {
                    _S1598 = false;
                }
            }
            if(_S1598)
            {
                return _S1178;
            }
            if(viewed_1)
            {
                float3  _S1599 = throughput_9 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf));
                float _S1600 = (&lobe_5)->pdf;
                throughput_10 = _S1599;
                sky_pdf_2 = _S1600;
            }
            else
            {
                float3  _S1601 = throughput_9 * max_0((&lobe_5)->throughput, _S1177);
                throughput_10 = _S1601;
                sky_pdf_2 = density_6;
            }
            bool _S1602;
            if(_S1373)
            {
                _S1602 = !_S1387;
            }
            else
            {
                _S1602 = false;
            }
            bool _S1603;
            if(_S1602)
            {
                _S1603 = _S1352;
            }
            else
            {
                _S1603 = false;
            }
            bool _S1604;
            if(_S1603)
            {
                _S1604 = _S1497;
            }
            else
            {
                _S1604 = false;
            }
            if(_S1604)
            {
                chain_0 = here_0;
                uint _S1605 = insertBits_0((&chain_0)->path, b_8, 18U, 3U);
                uint _S1606 = _slang_select(nee_0, 1U,0U);
                uint _S1607 = insertBits_0(_S1605, _S1606, 21U, 1U);
                (&chain_0)->path = _S1607;
                float _S1608 = (&chain_0)->jac * (&lobe_5)->pdf;
                (&chain_0)->jac = _S1608;
                (&chain_0)->dir = throughput_8;
                chain_throughput_1 = throughput_10;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            FKSurface _S1609 = surface_12;
            Vertex _S1610 = Vertex_x24init_0(_S1498, b_8, (&lobe_5)->pdf, (F32_abs((dot_0(surface_12.geometry_n, throughput_8)))), is_inside_6);
            prev_0 = _S1610;
            float _S1611 = (&lobe_5)->pdf;
            bool _S1612 = b_8 == 1U;
            bool _S1613;
            if(_S1612)
            {
                _S1613 = (_S1356.x) == (_S1356.y);
            }
            else
            {
                _S1613 = false;
            }
            float sky_pdf_3 = _slang_select(_S1613, sky_pdf_0,_S1611);
            float _S1614 = _slang_select(_S1363, 0.0f,sky_pdf_3);
            float _S1615 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * (&lobe_5)->pdf))))), (3.14159274101257324f)));
            bool _S1616 = !_S1488;
            float _S1617 = _slang_select(_S1616, _S1615,0.0f);
            float _S1618 = spread_1 + _S1617;
            bool _S1619;
            if(refracted_4)
            {
                _S1619 = !_S1494;
            }
            else
            {
                _S1619 = false;
            }
            bool is_inside_7;
            if(_S1619)
            {
                bool _S1620 = !is_inside_6;
                is_inside_7 = _S1620;
            }
            else
            {
                is_inside_7 = is_inside_6;
            }
            FKSurface _S1621 = surface_12;
            bool _S1622 = boundsVolume_0(&_S1621);
            bool _S1623;
            if(_S1622)
            {
                _S1623 = !_S1499;
            }
            else
            {
                _S1623 = false;
            }
            if(_S1623)
            {
                FKSurface faced_2 = surface_12;
                float3  _S1624 = - _S1609.geometry_n;
                float3  _S1625 = _slang_select(turned_1, _S1624,_S1609.geometry_n);
                (&faced_2)->geometry_n = _S1625;
                FKMedium _S1626 = Medium_x24init_0(scatter_in_0, extinction_in_0, g_in_0);
                FKMedium _S1627 = (fcptOutsideMedium((hit_4)));
                FKSurface _S1628 = faced_2;
                FKMedium _S1629 = _S1626;
                FKMedium _S1630 = _S1627;
                MediumSides _S1631 = mediumSides_0(&_S1628, &_S1629, filling_2, (&ray_2)->unit_direction, &_S1630);
                bool _S1632 = ((dot_0(throughput_8, _S1609.geometry_n)) > 0.0f) == ((dot_0(_S1609.geometry_n, (&faced_2)->geometry_n)) > 0.0f);
                float3  _S1633 = _slang_select(_S1632, _S1631.front.scatter,_S1631.behind.scatter);
                scatter_in_0 = _S1633;
                float3  _S1634 = _slang_select(_S1632, _S1631.front.extinction,_S1631.behind.extinction);
                extinction_in_0 = _S1634;
                float _S1635 = _slang_select(_S1632, _S1631.front.g,_S1631.behind.g);
                g_in_0 = _S1635;
                uint _S1636 = _S1631.fillings.x;
                uint _S1637 = _S1631.fillings.y;
                uint _S1638 = _slang_select(_S1632, _S1637,_S1636);
                bool _S1639 = (fcptVaryingUsed());
                uint _S1640 = _slang_select(_S1639, _S1638,4294967295U);
                filling_2 = _S1640;
            }
            (&ray_2)->unit_direction = throughput_8;
            bool _S1641 = !_S1499;
            if(_S1641)
            {
                FKSurface _S1642 = surface_12;
                float _S1643 = _slang_select(straight_0, 0.0f,_S1642.geometry_offset);
                float3  _S1644 = - _S1354.smooth_n;
                bool _S1645 = is_inside_7 != _S1494;
                float3  _S1646 = _slang_select(_S1645, _S1644,_S1354.smooth_n);
                float3  _S1647 = (&ray_2)->origin + make_float3 (_S1643) * _S1646;
                (&ray_2)->origin = _S1647;
            }
            throughput_9 = throughput_10;
            chain_throughput_0 = chain_throughput_1;
            density_6 = sky_pdf_2;
            passes_0 = _S1499;
            viewed_1 = _S1492;
            sky_pdf_2 = _S1614;
            spread_4 = _S1618;
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
        if(_S1373)
        {
            if(_S1319)
            {
                float3  _S1648 = throughput_9 * emission_1;
                Reservoir candidate_8 = chain_0;
                uint _S1649 = extractBits_0((&chain_0)->path, 10U, 2U);
                bool _S1650 = _S1649 == 1U;
                if(_S1650)
                {
                    float3  _S1651 = safeDivide(_S1648, chain_throughput_0);
                    (&candidate_8)->radiance = _S1651;
                }
                Reservoir _S1652 = withEnd(candidate_8, 2U, b_5, _S1648);
                offer(sel_7, _S1652, _S1648 * make_float3 (scale_3) / make_float3 (density_6));
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
                float _S1653 = survivalProbability(throughput_9, density_6);
                density_7 = _S1653;
            }
            else
            {
                density_7 = 1.0f;
            }
            uint _S1654 = stream(_S1205, b_5 + 128U);
            Random _S1655 = pcg(_S1654);
            bool _S1656 = density_7 < (_S1655.value);
            if(_S1656)
            {
                wrong_side_0 = true;
            }
            else
            {
                uint _S1657 = (fcptMaxBounces());
                wrong_side_0 = b_5 >= _S1657;
            }
            if(wrong_side_0)
            {
                break;
            }
            float _S1658 = density_6 * density_7;
            density_7 = _S1658;
        }
        else
        {
            density_7 = density_6;
        }
        uint _S1659 = layer_0 ^ 1U;
        uint _S1660 = _slang_select(passes_0, _S1659,0U);
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
            uint _S1661 = b_8 + 1U;
            b_5 = _S1661;
            layer_0 = _S1660;
            continue;
        }
        FKRay _S1662 = ray_2;
        float _S1663 = distance_1(reconnection_0, (&ray_2)->origin) * 1.0010000467300415f;
        if(replay_1)
        {
            refracted_4 = _S1397;
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
        float _S1664 = _slang_select(wrong_side_0, _S1663,4.294967296e+09f);
        bool _S1665 = !_S1363;
        if(straight_0)
        {
            _S1442 = true;
        }
        else
        {
            _S1442 = _S1363;
        }
        FKHit _S1666;
        if(_S1442)
        {
            _S1666 = hit_4;
        }
        else
        {
            _S1666 = _S1414;
        }
        FKHit _S1667 = (fcptTraverseInstanceBVH((_S1662), (_S1326), (_S1664), (_S1665), (_S1666), (viewed_1)));
        hit_4 = _S1667;
        if(replay_1)
        {
            _S1443 = _S1397;
        }
        else
        {
            _S1443 = false;
        }
        if(_S1443)
        {
            _S1487 = _S1182 == 1U;
        }
        else
        {
            _S1487 = false;
        }
        if(_S1487)
        {
            _S1488 = ((&hit_4)->instance_index) == (_S1194.instance_index);
        }
        else
        {
            _S1488 = false;
        }
        if(_S1488)
        {
            _S1489 = ((&hit_4)->triangle_index) == (_S1194.triangle_index);
        }
        else
        {
            _S1489 = false;
        }
        if(_S1489)
        {
            (&hit_4)->uv = _S1194.uv;
            float _S1668 = distance_1(reconnection_0, (&ray_2)->origin);
            (&hit_4)->distance = _S1668;
        }
        if(replay_1)
        {
            _S1490 = _S1397;
        }
        else
        {
            _S1490 = false;
        }
        if(_S1490)
        {
            _S1491 = _S1182 == 3U;
        }
        else
        {
            _S1491 = false;
        }
        if(_S1491)
        {
            _S1492 = ((&hit_4)->instance_index) != 4294967295U;
        }
        else
        {
            _S1492 = false;
        }
        if(_S1492)
        {
            return _S1178;
        }
        Reservoir _S1669 = chain_0;
        uint _S1670 = filling_2;
        for(;;)
        {
            bool _S1671 = (fcptVaryingUsed());
            if(_S1671)
            {
                _S1493 = _S1670 != 4294967295U;
            }
            else
            {
                _S1493 = false;
            }
            float _S1672;
            if(_S1493)
            {
                float _S1673 = (fcptMajorant((_S1670)));
                _S1672 = _S1673;
            }
            else
            {
                _S1672 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
            }
            if(replay_1)
            {
                _S1494 = _S1397;
            }
            else
            {
                _S1494 = false;
            }
            if(_S1494)
            {
                _S1495 = _S1182 == 1U;
            }
            else
            {
                _S1495 = false;
            }
            if(_S1495)
            {
                _S1496 = _S1672 > 0.0f;
            }
            else
            {
                _S1496 = false;
            }
            if(_S1496)
            {
                ended_0 = _S1178;
                sky_pdf_1 = sky_pdf_2;
                spread_2 = spread_4;
                width_4 = width_3;
                density_3 = density_7;
                throughput_10 = throughput_9;
                b_8 = b_5;
                _S1497 = true;
                break;
            }
            bool _S1674 = (&prev_0)->rough;
            if(_S1674)
            {
                _S1497 = !(_S1672 > 0.0f);
            }
            else
            {
                _S1497 = false;
            }
            (&prev_0)->rough = _S1497;
            uint _S1675 = b_5 + 320U;
            bool _S1676 = b_5 == 4294967295U;
            uint _S1677 = _slang_select(_S1676, 384U,_S1675);
            uint _S1678 = stream(_S1205, _S1677);
            uint tracking_1 = _S1678;
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
                uint _S1679 = b_8 + 320U;
                bool _S1680 = b_8 == 4294967295U;
                uint _S1681 = _slang_select(_S1680, 384U,_S1679);
                uint _S1682 = stream(_S1205, _S1681);
                Random _S1683 = pcg(_S1682);
                float _S1684 = - (F32_log((1.0f - _S1683.value))) / _S1672;
                if(_S1493)
                {
                    float3  _S1685 = (&ray_2)->origin;
                    float3  _S1686 = (&ray_2)->unit_direction;
                    float _S1687 = (&hit_4)->distance;
                    uint _S1688 = _slang_select(_S1680, 0U,b_8);
                    uint _S1689 = (&prev_0)->lobe;
                    uint _S1690 = _slang_select(_S1680, 3U,_S1689);
                    float _S1691 = (fcptTrackMedium((_S1670), (_S1685), (_S1686), (_S1687), (&tracking_1), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1688), (_S1690), (_S1680)));
                    spread_3 = _S1691;
                }
                else
                {
                    spread_3 = _S1684;
                }
                bool _S1692 = !(spread_3 < ((&hit_4)->distance));
                if(_S1692)
                {
                    _S1176 = int(2);
                    break;
                }
                if(_S1493)
                {
                    _S1498 = _S1373;
                }
                else
                {
                    _S1498 = false;
                }
                if(_S1498)
                {
                    float3  _S1693 = throughput_10 * glowed_0 / make_float3 (density_3);
                    float3  _S1694 = sel_7->glow + _S1693;
                    sel_7->glow = _S1694;
                }
                else
                {
                }
                glowed_0 = _S1177;
                uint b_9 = b_8 + 1U;
                float3  _S1695 = (&ray_2)->origin + make_float3 (spread_3) * (&ray_2)->unit_direction;
                (&ray_2)->origin = _S1695;
                float3  _S1696 = flightWeight_0(scatter_in_0, extinction_in_0, _S1672, spread_3, true);
                float3  _S1697 = weight_1;
                float3  _S1698 = _slang_select(_S1493, _S1697,_S1696);
                float3  throughput_11 = throughput_10 * _S1698;
                uint _S1699 = stream(_S1205, b_9 + 320U);
                tracking_1 = _S1699;
                weight_1 = throughput_3;
                float width_7 = width_4 + spread_2 * spread_3;
                float _S1700 = spread_2 + 3.14159274101257324f;
                if(_S1373)
                {
                    _S1499 = true;
                }
                else
                {
                    bool _S1701 = b_9 == _S1193;
                    if(_S1701)
                    {
                        _S1499 = !_S1493;
                    }
                    else
                    {
                        _S1499 = false;
                    }
                }
                TreeSample light_4;
                if(_S1499)
                {
                    float3  _S1702 = (&ray_2)->origin;
                    float3  _S1703 = (&ray_2)->unit_direction;
                    float3  _S1704 = (&ray_2)->unit_direction;
                    uint _S1705 = stream(_S1205, b_9 + 64U);
                    float3  _S1706 = extinction_in_0;
                    float3  _S1707 = extinction_in_0;
                    uint2  _S1708 = make_uint2 (_S1670);
                    float3  _S1709 = (&ray_2)->unit_direction;
                    uint _S1710 = arrivalLobe_0(b_9, (&prev_0)->lobe);
                    FKHit _S1711 = _S1414;
                    ShadowContext _S1712 = ShadowContext_x24init_0(_S1706, _S1707, _S1708, _S1709, b_9, _S1710, false, spread_3, width_7, &_S1711, false);
                    ShadowContext _S1713 = _S1712;
                    TreeSample _S1714 = sampleLightTree_0(_S1702, _S1703, _S1704, 0.0f, true, _S1705, &_S1713);
                    light_4 = _S1714;
                }
                else
                {
                    light_4 = _S1411;
                }
                float _S1715 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_4.dir));
                uint _S1716 = (fcptMaxBounces());
                bool _S1717 = b_9 < _S1716;
                if(_S1717)
                {
                    _S1500 = (light_4.density) > 0.0f;
                }
                else
                {
                    _S1500 = false;
                }
                float _S1718 = _slang_select(_S1500, _S1715,0.0f);
                float3  _S1719 = throughput_11 * light_4.radiance;
                float _S1720 = powerHeuristic(light_4.density, _S1718);
                float3  _S1721 = _S1719 * make_float3 (_S1715 * _S1720);
                float3  _S1722 = _slang_select(_S1499, _S1721,_S1177);
                if(replay_1)
                {
                    _S1501 = b_9 == _S1193;
                }
                else
                {
                    _S1501 = false;
                }
                if(_S1501)
                {
                    bool _S1723 = _S1182 == 2U;
                    if(_S1723)
                    {
                        float _S1724 = rgb_to_greyscale(_S1722);
                        _S1502 = _S1724 > 0.0f;
                    }
                    else
                    {
                        _S1502 = false;
                    }
                    if(_S1502)
                    {
                        Shift _S1725 = Shift_x24init_0(_S1722, 1.0f);
                        _S1176 = int(1);
                        ended_0 = _S1725;
                        spread_3 = _S1700;
                        width_5 = width_7;
                        throughput_8 = throughput_11;
                        b_6 = b_9;
                        break;
                    }
                    _S1176 = int(1);
                    ended_0 = _S1178;
                    spread_3 = _S1700;
                    width_5 = width_7;
                    throughput_8 = throughput_11;
                    b_6 = b_9;
                    break;
                }
                if(_S1373)
                {
                    Reservoir candidate_9 = _S1669;
                    uint _S1726 = extractBits_0(_S1669.path, 10U, 2U);
                    bool _S1727 = _S1726 == 1U;
                    if(_S1727)
                    {
                        float3  _S1728 = safeDivide(_S1722, chain_throughput_0);
                        (&candidate_9)->radiance = _S1728;
                    }
                    else
                    {
                        uint _S1729 = insertBits_0(0U, b_9 + 1U, 5U, 5U);
                        uint _S1730 = insertBits_0(_S1729, 2U, 10U, 2U);
                        (&candidate_9)->path = _S1730;
                    }
                    Reservoir _S1731 = withEnd(candidate_9, 0U, b_9, _S1722);
                    offer(sel_7, _S1731, _S1722 * make_float3 (scale_3) / make_float3 (density_3));
                    float _S1732 = survivalProbability(throughput_11, density_3);
                    uint _S1733 = stream(_S1205, b_9 + 128U);
                    Random _S1734 = pcg(_S1733);
                    bool _S1735 = _S1732 < (_S1734.value);
                    if(_S1735)
                    {
                        _S1502 = true;
                    }
                    else
                    {
                        uint _S1736 = (fcptMaxBounces());
                        _S1502 = b_9 >= _S1736;
                    }
                    if(_S1502)
                    {
                        _S1176 = int(1);
                        ended_0 = _S1178;
                        spread_3 = _S1700;
                        width_5 = width_7;
                        throughput_8 = throughput_11;
                        b_6 = b_9;
                        break;
                    }
                    float _S1737 = density_3 * _S1732;
                    density_3 = _S1737;
                }
                else
                {
                }
                float phase_pdf_1 = 0.0f;
                uint _S1738 = stream(_S1205, b_9);
                float3  _S1739 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1738, &phase_pdf_1);
                (&ray_2)->unit_direction = _S1739;
                NEEVertex _S1740 = NEEVertex_x24init_0(false, phase_pdf_1, (&ray_2)->origin, _S1177, (&ray_2)->origin);
                nee_vertex_0 = _S1740;
                Vertex _S1741 = Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_5);
                prev_0 = _S1741;
                float _S1742 = (&prev_0)->pdf;
                FKRay _S1743 = ray_2;
                FKHit _S1744 = (fcptTraverseInstanceBVH((_S1743), (true), (4.294967296e+09f), (false), (_S1414), (false)));
                hit_4 = _S1744;
                b_8 = b_9;
                throughput_10 = throughput_11;
                spread_2 = _S1700;
                width_4 = width_7;
                sky_pdf_1 = _S1742;
            }
            if(_S1176 != int(2))
            {
                spread_2 = spread_3;
                width_4 = width_5;
                throughput_10 = throughput_8;
                b_8 = b_6;
                _S1497 = true;
                break;
            }
            ended_0 = _S1178;
            _S1497 = false;
            break;
        }
        if(_S1497)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S1498 = b_8 == b_5;
        }
        else
        {
            _S1498 = false;
        }
        bool _S1745 = ((&hit_4)->instance_index) == 4294967295U;
        if(_S1745)
        {
            bool _S1746 = !(&nee_vertex_0)->none;
            float _S1747 = _slang_select(_S1746, sky_pdf_1,0.0f);
            float _S1748 = escapeWeight_0(_S1747, (&ray_2)->unit_direction);
            float3  _S1749 = environment_0((&ray_2)->unit_direction, b_8, (&prev_0)->lobe);
            float3  _S1750 = throughput_10 * _S1749;
            if(replay_1)
            {
                bool _S1751 = b_8 == _S1193;
                if(_S1751)
                {
                    passes_0 = _S1182 == 3U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(_S1750 * make_float3 (_S1748) / make_float3 (r_8->jac), density_3 / r_8->jac);
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
                    return Shift_x24init_0(_S1750 * make_float3 (_S1748), 1.0f);
                }
                return _S1178;
            }
            Reservoir candidate_10 = chain_0;
            uint _S1752 = extractBits_0((&chain_0)->path, 10U, 2U);
            bool _S1753 = _S1752 == 1U;
            if(_S1753)
            {
                uint _S1754 = extractBits_0((&chain_0)->path, 5U, 5U);
                bool _S1755 = _S1754 == b_8;
                float _S1756 = _slang_select(_S1755, 1.0f,_S1748);
                float3  _S1757 = safeDivide(_S1750 * make_float3 (_S1756), chain_throughput_0);
                (&candidate_10)->radiance = _S1757;
            }
            else
            {
                bool _S1758 = (&prev_0)->rough;
                if(_S1758)
                {
                    uint _S1759 = insertBits_0(0U, b_8 + 1U, 5U, 5U);
                    uint _S1760 = insertBits_0(_S1759, 3U, 10U, 2U);
                    uint _S1761 = insertBits_0(_S1760, (&prev_0)->lobe, 15U, 3U);
                    bool _S1762 = (&prev_0)->inside;
                    uint _S1763 = _slang_select(_S1762, 1U,0U);
                    uint _S1764 = insertBits_0(_S1761, _S1763, 22U, 1U);
                    (&candidate_10)->path = _S1764;
                    (&candidate_10)->jac = (&prev_0)->pdf;
                    (&candidate_10)->dir = (&ray_2)->unit_direction;
                }
            }
            float3  _S1765 = _S1750 * make_float3 (_S1748);
            Reservoir _S1766 = withEnd(candidate_10, 3U, b_8, _S1765);
            offer(sel_7, _S1766, _S1765 * make_float3 (scale_3) / make_float3 (density_3));
            break;
        }
        float3  _S1767 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
        (&ray_2)->origin = _S1767;
        bool _S1768 = (fcptVaryingUsed());
        if(_S1768)
        {
            _S1499 = filling_2 != 4294967295U;
        }
        else
        {
            _S1499 = false;
        }
        if(_S1499)
        {
            if(_S1373)
            {
                float3  _S1769 = throughput_10 * glowed_0 / make_float3 (density_3);
                float3  _S1770 = sel_7->glow + _S1769;
                sel_7->glow = _S1770;
            }
            float3  _S1771 = throughput_10 * weight_1;
            throughput_8 = _S1771;
        }
        else
        {
            float3  _S1772 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
            float3  _S1773 = throughput_10 * _S1772;
            throughput_8 = _S1773;
        }
        float _S1774 = width_4 + spread_2 * (&hit_4)->distance;
        viewed_0 = _S1498;
        width_3 = _S1774;
        throughput_2 = throughput_8;
        density_2 = density_3;
        sky_pdf_0 = sky_pdf_1;
        spread_1 = spread_2;
        uint _S1661 = b_8 + 1U;
        b_5 = _S1661;
        layer_0 = _S1660;
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
    Random _S1775 = pcg(state_3);
    Random _S1776 = pcg(_S1775.state);
    float _S1777 = 6.28318548202514648f * _S1775.value;
    float _S1778 = (F32_sqrt((-2.0f * clamp_1((F32_log((_S1776.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S1776.state, _S1778 * (F32_cos((_S1777))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_4, float3  value_2)
{
    RandomSphere _S1779;
    (&_S1779)->state = state_4;
    (&_S1779)->value = value_2;
    return _S1779;
}

__device__ RandomSphere random_sphere(uint state_5)
{
    Random _S1780 = normal_distribution(state_5);
    Random _S1781 = normal_distribution(_S1780.state);
    Random _S1782 = normal_distribution(_S1781.state);
    float3  _S1783 = make_float3 (_S1780.value, _S1781.value, _S1782.value);
    float3  _S1784 = ((((_S1783)) * make_float3(rnorm3df(((_S1783)).x, ((_S1783)).y, ((_S1783)).z))));
    return RandomSphere_x24init_0(_S1782.state, _S1784);
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_13)
{
    float3  _S1785 = p1_0 - p0_0;
    float3  _S1786 = p2_0 - p0_0;
    float2  _S1787 = uv1_0 - uv0_0;
    float2  _S1788 = uv2_0 - uv0_0;
    float _S1789 = _S1787.x;
    float _S1790 = _S1788.y;
    float _S1791 = _S1787.y;
    float _S1792 = _S1788.x;
    float _S1793 = _S1789 * _S1790 - _S1791 * _S1792;
    float _S1794 = 1.0f / _S1793;
    float3  t_22 = (_S1785 * make_float3 (_S1790) - _S1786 * make_float3 (_S1791)) * make_float3 (_S1794);
    float3  _S1795 = (_S1786 * make_float3 (_S1789) - _S1785 * make_float3 (_S1792)) * make_float3 (_S1794);
    float3  _S1796 = t_22 - n_13 * make_float3 (dot_0(n_13, t_22));
    float3  _S1797 = tangentToWorld(make_float3 (1.0f, 0.0f, 0.0f), n_13);
    bool _S1798 = (dot_0(_S1796, _S1796)) > 0.0f;
    float3  _S1799 = _slang_select(_S1798, _S1796,_S1797);
    float3  _S1800 = ((((_S1799)) * make_float3(rnorm3df(((_S1799)).x, ((_S1799)).y, ((_S1799)).z))));
    bool _S1801 = (dot_0(cross_0(n_13, _S1800), _S1795)) > 0.0f;
    float3  t_23;
    if(_S1801)
    {
        float3  _S1802 = negate_0(_S1800);
        t_23 = _S1802;
    }
    else
    {
        t_23 = _S1800;
    }
    float3  _S1803 = cross_0(n_13, t_23);
    return makeMatrix<float, 3, 3> (t_23, _S1803, n_13);
}

__device__ float3  tangentToWorldNormalMap(float3  v_5, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_5, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_4, float3  uvw_0, float3  position_0)
{
    float3  _S1804 = t1_0 - t0_0;
    float3  _S1805 = t2_2 - t0_0;
    float3  _S1806 = t2_2 - t1_0;
    float _S1807 = (F32_min((length_0(_S1804)), ((F32_min((length_0(_S1805)), (length_0(_S1806)))))));
    float3  _S1808 = make_float3 (distance_1(position_0, t0_0), distance_1(position_0, t1_0), distance_1(position_0, t2_2));
    float3  _S1809 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S1810 = dot_0(geometry_n_4, _S1809);
    float3  _S1811 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S1812 = dot_0(geometry_n_4, _S1811);
    float3  _S1813 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S1814 = acos_0(abs_0(make_float3 (_S1810, _S1812, dot_0(geometry_n_4, _S1813))));
    float3  _S1815 = clamp_2(tan_0(_S1814), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_1(dot_0(_S1808 * _S1815, uvw_0), 0.0f, _S1807 * 0.125f);
}

__device__ float3  straightThrough(BSDFMaterial material_23)
{
    return make_float3 (material_23.transmission * (1.0f - material_23.metallic)) * material_23.albedo;
}

__device__ float hairRow(float3  in_dir_11, float3  t_24, float3  out_dir_3, uint p_12, float w_2, float alpha_20, uint nt_0)
{
    uint _S1816 = p_12 % 4U;
    float _S1817 = w_2 * HAIR_WIDTHS_0[_S1816];
    float _S1818 = (F32_asin((clamp_1(dot_0(out_dir_3, t_24), -1.0f, 1.0f)))) - (F32_asin((clamp_1(dot_0(in_dir_11, t_24), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S1816] * alpha_20;
    return ((F32_asinh((_S1818 / _S1817))) / (F32_asinh((3.14159274101257324f / _S1817))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_12, float3  t_25, float3  out_dir_4, uint np_0)
{
    float3  _S1819 = worldToTangent(out_dir_4, t_25);
    float3  _S1820 = worldToTangent(in_dir_12, t_25);
    return (F32_frac((((F32_atan2((_S1819.z), (_S1819.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S1820.z), (1.17549435082228751e-38f - _S1820.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_13, float3  t_26, uint p_13, float row_0, float column_0, float w_3, float alpha_21, uint nt_1, uint np_1)
{
    float3  _S1821 = worldToTangent(in_dir_13, t_26);
    uint _S1822 = p_13 % 4U;
    float _S1823 = w_3 * HAIR_WIDTHS_0[_S1822];
    float _S1824 = (F32_asin((clamp_1(dot_0(in_dir_13, t_26), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S1822] * alpha_21 + _S1823 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S1823))))));
    float _S1825 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S1821.z), (1.17549435082228751e-38f - _S1821.x)));
    float _S1826 = (F32_cos((_S1824)));
    float3  _S1827 = tangentToWorld(make_float3 (_S1826 * (F32_cos((_S1825))), (F32_sin((_S1824))), _S1826 * (F32_sin((_S1825)))), t_26);
    return _S1827;
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_14, BSDFMaterial material_24, float coverage_1)
{
    float3  _S1828;
    if((material_24.ior) == 1.0f)
    {
        float3  _S1829 = straightThrough(material_24);
        _S1828 = _S1829;
    }
    else
    {
        _S1828 = make_float3 (0.0f);
    }
    return _S1828 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ Shift walk_hook(Domain dom_8, Reservoir r_9, bool replay_2, float scale_4, Selection * sel_8)
{
    Domain _S1830 = dom_8;
    Reservoir _S1831 = r_9;
    Shift _S1832 = walk_0(&_S1830, &_S1831, replay_2, scale_4, sel_8);
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
