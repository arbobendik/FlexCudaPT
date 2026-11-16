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

__device__ float shadowLength(float3  shadow_0)
{
    return length_0(shadow_0) * 0.99989998340606689f;
}

static __device__ float3  lightTransmittance_0(float3  origin_2, float3  smooth_n_0, float geometry_offset_0, float3  light_dir_0, ShadowContext * context_1, uint random_state_1, FKHit * light_0)
{
    float3  _S186 = ((((light_dir_0)) * make_float3(rnorm3df(((light_dir_0)).x, ((light_dir_0)).y, ((light_dir_0)).z))));
    bool _S187 = (dot_0(smooth_n_0, _S186)) < 0.0f;
    if(_S187)
    {
        return make_float3 (0.0f);
    }
    float3  _S188 = make_float3 (geometry_offset_0) * smooth_n_0;
    float3  _S189 = origin_2 + _S188;
    FKRay _S190 = Ray_x24init_0(_S189, _S186);
    bool _S191 = (dot_0(context_1->side, light_dir_0 + _S188)) > 0.0f;
    float _S192 = shadowLength(light_dir_0);
    float3  _S193 = context_1->extinction_behind;
    float3  _S194 = context_1->extinction_front;
    float3  _S195 = _slang_select(_S191, _S194,_S193);
    uint _S196 = context_1->fillings.x;
    uint _S197 = context_1->fillings.y;
    uint _S198 = _slang_select(_S191, _S197,_S196);
    uint _S199 = context_1->depth;
    uint _S200 = context_1->lobe;
    bool _S201 = context_1->surface;
    bool _S202;
    if(_S201)
    {
        _S202 = !context_1->fiber;
    }
    else
    {
        _S202 = false;
    }
    float _S203 = context_1->length;
    float _S204 = context_1->width;
    FKHit _S205;
    if(context_1->fiber)
    {
        _S205 = context_1->own;
    }
    else
    {
        _S205 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    }
    float3  _S206 = (fcptShadowTransmittanceIn((_S190), (_S192), (_S195), (_S198), (random_state_1), (_S199), (_S200), (_S202), (_S203), (_S204), (_S205), (*light_0)));
    return _S206;
}

__device__ float sine(float c_0)
{
    return (F32_sqrt(((F32_max((1.0f - c_0 * c_0), (0.0f))))));
}

__device__ float cosSubClamped(float sin_a_0, float cos_a_0, float sin_b_0, float cos_b_0)
{
    float _S207 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    bool _S208 = cos_a_0 > cos_b_0;
    float _S209 = _slang_select(_S208, 1.0f,_S207);
    return _S209;
}

__device__ float sinSubClamped(float sin_a_1, float cos_a_1, float sin_b_1, float cos_b_1)
{
    float _S210 = sin_a_1 * cos_b_1 - cos_a_1 * sin_b_1;
    bool _S211 = cos_a_1 > cos_b_1;
    float _S212 = _slang_select(_S211, 0.0f,_S210);
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
    float _S228 = sinSubClamped(_S227, _S219, _S220, node_0.cos_theta_o);
    float _S229 = cosSubClamped(_S228, _S226, _S224, _S223);
    bool _S230 = _S229 <= 0.0f;
    if(_S230)
    {
        return 0.0f;
    }
    float _S231 = - dot_0(_S216, normal_0);
    float _S232 = node_0.phi * _S229 / (F32_max((_S217), (length_0(_S214) / 2.0f)));
    float _S233 = sine(_S231);
    float _S234 = cosSubClamped(_S233, _S231, _S224, _S223);
    bool _S235 = (dot_0(normal_0, normal_0)) == 0.0f;
    float _S236 = _slang_select(_S235, 1.0f,_S234);
    return (F32_max((_S232 * _S236), (0.0f)));
}

__device__ __forceinline__ float childShare(LightNode first_0, LightNode second_0, float3  p_8, float3  normal_1, uint child_0)
{
    float _S237 = importance(first_0, p_8, normal_1);
    float _S238 = importance(second_0, p_8, normal_1);
    float2  _S239 = make_float2 (_S237, _S238);
    float _S240 = _slang_vector_get_element(_S239, child_0) / (_S237 + _S238);
    bool _S241 = _slang_vector_get_element(_S239, child_0) > 0.0f;
    float _S242 = _slang_select(_S241, _S240,0.0f);
    return _S242;
}

__device__ float sphereDensity(float3  center_0, float radius_0, float3  p_9)
{
    float3  _S243 = center_0 - p_9;
    float _S244 = radius_0 * radius_0 / dot_0(_S243, _S243);
    bool _S245 = _S244 >= 1.0f;
    if(_S245)
    {
        return 0.07957746833562851f;
    }
    return (1.0f + (F32_sqrt((1.0f - _S244)))) / (6.28318548202514648f * _S244);
}

static __device__ float3  cross_0(float3  left_0, float3  right_0)
{
    float _S246 = left_0.y;
    float _S247 = right_0.z;
    float _S248 = left_0.z;
    float _S249 = right_0.y;
    float _S250 = right_0.x;
    float _S251 = left_0.x;
    return make_float3 (_S246 * _S247 - _S248 * _S249, _S248 * _S250 - _S251 * _S247, _S251 * _S249 - _S246 * _S250);
}

__device__ float solidAngle(float probability_0, float3  normal_2, float3  toward_0)
{
    return 2.0f * probability_0 * (F32_pow((length_0(toward_0)), (3.0f))) / (F32_abs((dot_0(normal_2, toward_0))));
}

static __device__ float lightPdf_0(float3  origin_3, float3  smooth_n_1, float3  start_5, uint j_0, float3  light_point_0)
{
    bool _S252 = j_0 == 4294967295U;
    if(_S252)
    {
        return 0.0f;
    }
    uint4  _S253 = (fcptLightTrail((j_0)));
    uint2  _S254 = uint2 {_S253.x, _S253.y};
    uint n_0 = 0U;
    uint2  trail_0 = _S254;
    float probability_1 = 1.0f;
    for(;;)
    {
        uint4  _S255 = (fcptLightNode((n_0)));
        if((_S255.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S256 = (fcptLightSecond((n_0)));
        uint _S257 = n_0 + 1U;
        LightNode _S258 = (fcptLightBounds((_S257)));
        LightNode _S259 = (fcptLightBounds((_S256)));
        uint _S260 = trail_0.x;
        uint _S261 = _S260 & 1U;
        float _S262 = childShare(_S258, _S259, origin_3, smooth_n_1, _S261);
        float probability_2 = probability_1 * _S262;
        bool _S263 = _S261 == 1U;
        uint _S264 = _slang_select(_S263, _S256,_S257);
        uint _S265 = trail_0.y;
        uint2  _S266 = make_uint2 ((_S260 >> 1U) | (_S265 << 31U), _S265 >> 1U);
        n_0 = _S264;
        trail_0 = _S266;
        probability_1 = probability_2;
    }
    bool _S267 = (fcptSlotLeaf((n_0), (j_0)));
    bool _S268 = !_S267;
    bool _S269;
    if(_S268)
    {
        _S269 = true;
    }
    else
    {
        LightNode _S270 = (fcptLightBounds((n_0)));
        float _S271 = importance(_S270, origin_3, smooth_n_1);
        _S269 = !(_S271 > 0.0f);
    }
    if(_S269)
    {
        _S269 = true;
    }
    else
    {
        bool _S272 = (dot_0(smooth_n_1, smooth_n_1)) > 0.0f;
        if(_S272)
        {
            _S269 = !((dot_0(smooth_n_1, light_point_0 - origin_3)) > 0.0f);
        }
        else
        {
            _S269 = false;
        }
    }
    if(_S269)
    {
        return 0.0f;
    }
    uint4  _S273 = (fcptLightNode((n_0)));
    bool _S274 = (_S273.x) == 2U;
    if(_S274)
    {
        uint _S275 = _S273.y;
        FKLight _S276 = (fcptLight((_S275)));
        FKLight _S277 = (fcptLight((_S275)));
        float _S278 = sphereDensity(_S276.position, _S277.variance, start_5);
        return probability_1 * _S278;
    }
    uint _S279 = _S273.y;
    uint _S280 = (fcptTriangleOffset((_S279)));
    Matrix<float, 3, 3>  _S281 = (fcptWorldTriangle((_S279), (_S280 + _S273.z)));
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

static __device__ float random_0(uint * state_0)
{
    uint _S283 = hash(*state_0);
    *state_0 = _S283;
    return float((*state_0) >> int(8)) * 5.9604644775390625e-08f;
}

static __device__ Random Random_x24init_0(uint state_1, float value_0)
{
    Random _S284;
    (&_S284)->state = state_1;
    (&_S284)->value = value_0;
    return _S284;
}

__device__ Random pcg(uint state_2)
{
    uint _S285 = state_2;
    float value_1 = random_0(&_S285);
    return Random_x24init_0(_S285, value_1);
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
    uint2  _S286 = (fcptEnvironmentCdfSize());
    uint2  _S287 = _S286 - make_uint2 (1U, 0U);
    float2  _S288 = make_float2 ((F32_atan2((- dir_2.y), (dir_2.x))) / 6.28318548202514648f + 0.5f, (F32_acos((clamp_1(dir_2.z, -1.0f, 1.0f)))) / 3.14159274101257324f);
    float2  _S289 = make_float2 ((float)_S287.x, (float)_S287.y);
    float2  _S290 = _S288 * _S289;
    uint2  _S291 = make_uint2 ((uint)_S290.x, (uint)_S290.y);
    uint2  _S292 = min_0(_S291, _S287 - make_uint2 (1U));
    float4  _S293 = (fcptEnvironmentCdf((_S292)));
    float _S294 = _S293.y;
    uint _S295 = _S287.x;
    float4  _S296 = (fcptEnvironmentCdf((make_uint2 (_S295, _S292.y))));
    float _S297 = _S294 * _S296.y;
    return _S297 * float(_S295 * _S287.y) / (19.73921012878417969f * length_1(float2 {dir_2.x, dir_2.y}));
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
    float _S298;
    if(e_1 > 0.0f)
    {
        _S298 = 1.0f;
    }
    else
    {
        if(e_1 < 0.0f)
        {
            _S298 = -1.0f;
        }
        else
        {
            _S298 = 0.0f;
        }
    }
    return _S298;
}

struct AnisotropicFrame
{
    float3  tangent;
    float2  alphas;
};

static __device__ AnisotropicFrame AnisotropicFrame_x24init_0(float3  tangent_0, float2  alphas_0)
{
    AnisotropicFrame _S299;
    (&_S299)->tangent = tangent_0;
    (&_S299)->alphas = alphas_0;
    return _S299;
}

__device__ float3  tangentToWorld(float3  v_0, float3  n_1)
{
    float3  a_1 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S300 = (F32_abs((dot_0(n_1, a_1)))) > 0.9999847412109375f;
    float3  a_2;
    if(_S300)
    {
        float3  _S301 = make_float3 (1.0f, 0.0f, 0.0f);
        a_2 = _S301;
    }
    else
    {
        a_2 = a_1;
    }
    float3  _S302 = cross_0(n_1, a_2);
    float3  _S303 = ((((_S302)) * make_float3(rnorm3df(((_S302)).x, ((_S302)).y, ((_S302)).z))));
    float3  _S304 = cross_0(n_1, _S303);
    return make_float3 (v_0.x) * _S303 + make_float3 (v_0.y) * n_1 + make_float3 (v_0.z) * _S304;
}

__device__ AnisotropicFrame anisotropicFrame(BSDFMaterial material_0, float3  n_i_0)
{
    float _S305 = material_0.roughness;
    float _S306 = _S305 * _S305;
    bool _S307 = (material_0.anisotropy) == 0.0f;
    bool _S308;
    if(_S307)
    {
        _S308 = true;
    }
    else
    {
        _S308 = !(_S306 > 0.0f);
    }
    if(_S308)
    {
        return AnisotropicFrame_x24init_0(make_float3 (0.0f), make_float2 (0.0f));
    }
    float3  _S309 = material_0.tangent - n_i_0 * make_float3 (dot_0(n_i_0, material_0.tangent));
    float3  _S310 = tangentToWorld(make_float3 (1.0f, 0.0f, 0.0f), n_i_0);
    bool _S311 = (dot_0(_S309, _S309)) > 0.0f;
    float3  _S312 = _slang_select(_S311, _S309,_S310);
    float3  _S313 = ((((_S312)) * make_float3(rnorm3df(((_S312)).x, ((_S312)).y, ((_S312)).z))));
    float _S314 = 6.28318548202514648f * material_0.anisotropic_rotation;
    float _S315 = (F32_sqrt((1.0f - 0.89999997615814209f * (F32_abs((material_0.anisotropy))))));
    float _S316 = 1.0f / _S315;
    bool _S317 = (material_0.anisotropy) < 0.0f;
    float _S318 = _slang_select(_S317, _S316,_S315);
    return AnisotropicFrame_x24init_0(_S313 * make_float3 ((F32_cos((_S314)))) + cross_0(n_i_0, _S313) * make_float3 ((F32_sin((_S314)))), make_float2 (_S306 / _S318, _S306 * _S318));
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
    float3  _S319 = make_float3 (alpha_0 * Ve_0.x, alpha_0 * Ve_0.y, Ve_0.z);
    float3  _S320 = ((((_S319)) * make_float3(rnorm3df(((_S319)).x, ((_S319)).y, ((_S319)).z))));
    float _S321 = _S320.x;
    float _S322 = _S320.y;
    float _S323 = _S321 * _S321 + _S322 * _S322;
    float3  _S324;
    if(_S323 > 0.0f)
    {
        float3  _S325 = make_float3 (- _S322, _S321, 0.0f);
        float _S326 = (rsqrtf((_S323)));
        _S324 = _S325 * make_float3 (_S326);
    }
    else
    {
        _S324 = make_float3 (1.0f, 0.0f, 0.0f);
    }
    float3  _S327 = cross_0(_S320, _S324);
    float _S328 = (F32_sqrt((U1_0)));
    float _S329 = 6.28318548202514648f * U2_0;
    float _S330 = _S328 * (F32_cos((_S329)));
    float t2_0 = _S328 * (F32_sin((_S329)));
    float _S331 = 0.5f * (1.0f + _S320.z);
    float t2_1 = (1.0f - _S331) * (F32_sqrt(((F32_max((0.0f), (1.0f - _S330 * _S330)))))) + _S331 * t2_0;
    float3  _S332 = make_float3 (_S330) * _S324 + make_float3 (t2_1) * _S327;
    float _S333 = unshared_0(_S330);
    float _S334 = unshared_0(_S330);
    float3  _S335 = _S332 + make_float3 ((F32_sqrt(((F32_max((0.0f), (1.0f - _S333 * _S334 - t2_1 * t2_1))))))) * _S320;
    float3  _S336 = make_float3 (alpha_0 * _S335.x, alpha_0 * _S335.y, (F32_max((0.0f), (_S335.z))));
    float3  _S337 = ((((_S336)) * make_float3(rnorm3df(((_S336)).x, ((_S336)).y, ((_S336)).z))));
    return _S337;
}

__device__ float3  worldToTangent(float3  v_1, float3  n_3)
{
    float3  a_3 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S338 = (F32_abs((dot_0(n_3, a_3)))) > 0.9999847412109375f;
    float3  a_4;
    if(_S338)
    {
        float3  _S339 = make_float3 (1.0f, 0.0f, 0.0f);
        a_4 = _S339;
    }
    else
    {
        a_4 = a_3;
    }
    float3  _S340 = cross_0(n_3, a_4);
    float3  _S341 = ((((_S340)) * make_float3(rnorm3df(((_S340)).x, ((_S340)).y, ((_S340)).z))));
    float3  _S342 = cross_0(n_3, _S341);
    return make_float3 (dot_0(v_1, _S341), dot_0(v_1, n_3), dot_0(v_1, _S342));
}

__device__ __forceinline__ float3  sampleHalfVector(float3  v_2, float3  n_i_1, float alpha_1, AnisotropicFrame frame_0, uint * random_state_2)
{
    Random _S343 = pcg(*random_state_2);
    Random _S344 = pcg(_S343.state);
    *random_state_2 = _S344.state;
    float _S345 = frame_0.alphas.x;
    bool _S346 = _S345 > 0.0f;
    if(_S346)
    {
        float3  _S347 = anisotropicLocal(v_2, frame_0.tangent, n_i_1);
        float _S348 = frame_0.alphas.y;
        float3  _S349 = make_float3 (_S345 * _S347.x, _S348 * _S347.y, _S347.z);
        float3  _S350 = ((((_S349)) * make_float3(rnorm3df(((_S349)).x, ((_S349)).y, ((_S349)).z))));
        float3  _S351 = sampleGGXVNDF(_S350, 1.0f, _S343.value, _S344.value);
        float3  _S352 = make_float3 (_S345 * _S351.x, _S348 * _S351.y, _S351.z);
        float3  _S353 = ((((_S352)) * make_float3(rnorm3df(((_S352)).x, ((_S352)).y, ((_S352)).z))));
        return make_float3 (_S353.x) * frame_0.tangent + make_float3 (_S353.y) * cross_0(n_i_1, frame_0.tangent) + make_float3 (_S353.z) * n_i_1;
    }
    float3  _S354 = worldToTangent(v_2, n_i_1);
    float3  _S355 = sampleGGXVNDF(float3 {_S354.x, _S354.z, _S354.y}, alpha_1, _S343.value, _S344.value);
    float3  _S356 = float3 {_S355.x, _S355.z, _S355.y};
    float3  _S357 = tangentToWorld(_S356, n_i_1);
    return _S357;
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
    float _S358 = dot_0(n_4, i_5);
    float _S359 = 1.0f - eta_0 * eta_0 * (1.0f - _S358 * _S358);
    if(_S359 < 0.0f)
    {
        return make_float3 (0.0f);
    }
    return make_float3 (eta_0) * i_5 - make_float3 (eta_0 * _S358 + (F32_sqrt((_S359)))) * n_4;
}

__device__ float fresnel(float cos_theta_0, float eta_i_0, float eta_o_0)
{
    float _S360 = (F32_sqrt(((F32_max((0.0f), (1.0f - cos_theta_0 * cos_theta_0))))));
    float _S361 = eta_i_0 / eta_o_0 * _S360;
    bool _S362 = _S361 < 1.0f;
    float kr_0;
    if(_S362)
    {
        float _S363 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S361 * _S361))))));
        float _S364 = eta_o_0 * cos_theta_0;
        float _S365 = eta_i_0 * _S363;
        float _S366 = (_S364 - _S365) / (_S364 + _S365);
        float _S367 = eta_i_0 * cos_theta_0;
        float _S368 = eta_o_0 * _S363;
        float _S369 = (_S367 - _S368) / (_S367 + _S368);
        float _S370 = (_S366 * _S366 + _S369 * _S369) / 2.0f;
        kr_0 = _S370;
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
    float _S371 = (F32_max((w_1.z), (0.0f)));
    return 2.0f * _S371 / (_S371 + length_0(make_float3 (alphas_1.x * w_1.x, alphas_1.y * w_1.y, _S371)));
}

__device__ float anisotropicD(float3  h_0, float2  alphas_2)
{
    float _S372 = alphas_2.x;
    float _S373 = h_0.x / _S372;
    float _S374 = alphas_2.y;
    float _S375 = h_0.y / _S374;
    float _S376 = h_0.z;
    float _S377 = _S373 * _S373 + _S375 * _S375 + _S376 * _S376;
    return 1.0f / (F32_max((3.14159274101257324f * _S372 * _S374 * _S377 * _S377), (1.17549435082228751e-38f)));
}

static __device__ BSDFLobes BSDFLobes_x24init_0(float v_dot_h_0, float n_dot_h_0, float3  refracted_1, float3  F_0, float F_greyscale_0, float reflect_weight_0, float3  diffuse_weight_0, float3  refract_weight_0, float p_diffuse_0, float p_reflect_0, float p_refract_0, float translucent_share_0, float3  sheen_0, float p_sheen_velvet_0, float3  view_0, float3  tangent_1, float2  alphas_3, float visible_0, float toon_share_0)
{
    BSDFLobes _S378;
    (&_S378)->v_dot_h = v_dot_h_0;
    (&_S378)->n_dot_h = n_dot_h_0;
    (&_S378)->refracted = refracted_1;
    (&_S378)->F = F_0;
    (&_S378)->F_greyscale = F_greyscale_0;
    (&_S378)->reflect_weight = reflect_weight_0;
    (&_S378)->diffuse_weight = diffuse_weight_0;
    (&_S378)->refract_weight = refract_weight_0;
    (&_S378)->p_diffuse = p_diffuse_0;
    (&_S378)->p_reflect = p_reflect_0;
    (&_S378)->p_refract = p_refract_0;
    (&_S378)->translucent_share = translucent_share_0;
    (&_S378)->sheen = sheen_0;
    (&_S378)->p_sheen_velvet = p_sheen_velvet_0;
    (&_S378)->view = view_0;
    (&_S378)->tangent = tangent_1;
    (&_S378)->alphas = alphas_3;
    (&_S378)->visible = visible_0;
    (&_S378)->toon_share = toon_share_0;
    return _S378;
}

__device__ __forceinline__ BSDFLobes bsdfLobes(float3  in_dir_0, float3  v_3, float3  n_i_2, float3  ggx_n_0, BSDFMaterial material_1, float eta_i_1, float eta_o_1, AnisotropicFrame frame_1)
{
    float _S379 = dot_0(ggx_n_0, v_3);
    float _S380 = dot_0(n_i_2, ggx_n_0);
    float _S381 = eta_i_1 / eta_o_1;
    float3  _S382 = refract_0(in_dir_0, ggx_n_0, _S381);
    float3  _S383 = ((((_S382)) * make_float3(rnorm3df(((_S382)).x, ((_S382)).y, ((_S382)).z))));
    float _S384 = (F32_min(((F32_sqrt((material_1.specular_level))) * (F32_abs((eta_i_1 - eta_o_1))) / (eta_i_1 + eta_o_1)), (0.9999847412109375f)));
    float _S385 = _S384 * _S384;
    float _S386 = (1.0f + _S384) / (1.0f - _S384);
    float _S387 = (F32_abs((_S379)));
    bool _S388 = eta_i_1 > eta_o_1;
    float sheen_component_0;
    if(_S388)
    {
        sheen_component_0 = _S386;
    }
    else
    {
        sheen_component_0 = 1.0f;
    }
    float toon_component_0;
    if(_S388)
    {
        toon_component_0 = 1.0f;
    }
    else
    {
        toon_component_0 = _S386;
    }
    float _S389 = fresnel(_S387, sheen_component_0, toon_component_0);
    bool _S390 = (eta_i_1 * eta_i_1 * (1.0f - _S379 * _S379)) >= (eta_o_1 * eta_o_1);
    float3  _S391;
    if(_S390)
    {
        _S391 = make_float3 (1.0f);
    }
    else
    {
        float3  _S392 = material_1.specular_tint * make_float3 (_S385);
        _S391 = _S392 + (make_float3 (1.0f) - _S392) * make_float3 (_S389 - _S385) / make_float3 (1.0f - _S385);
    }
    float3  _S393 = make_float3 (1.0f);
    float3  _S394 = make_float3 (0.0f);
    float _S395 = rgb_to_greyscale(material_1.sheen);
    bool _S396 = _S395 > 0.0f;
    float3  sheen_1;
    float3  view_1;
    float3  scale_1;
    if(_S396)
    {
        float _S397 = clamp_1((F32_sqrt(((F32_max((dot_0(n_i_2, v_3)), (0.0f)))))), 0.0f, 1.0f) * 23.0f;
        uint _S398 = (U32_min((uint(_S397)), (22U)));
        float least_0 = (F32_sqrt((0.05000000074505806f)));
        float _S399 = (F32_sqrt((0.10000000149011612f)));
        bool _S400 = (material_1.velvet) > 0.0f;
        float _S401 = _slang_select(_S400, _S399,least_0);
        float _S402 = (clamp_1((F32_sqrt(((F32_max((material_1.sheen_roughness), (0.0f)))))), _S401, 1.0f) - _S401) / (1.0f - _S401) * 23.0f;
        uint _S403 = (U32_min((uint(_S402)), (22U)));
        uint _S404 = _S398 * 24U + _S403;
        float _S405 = _S397 - float(_S398);
        float _S406 = _S402 - float(_S403);
        uint _S407 = _S404 + 24U;
        float a_5 = SHEEN_ALBEDO_0[_S404] + (SHEEN_ALBEDO_0[_S407] - SHEEN_ALBEDO_0[_S404]) * _S405;
        uint _S408 = _S404 + 1U;
        uint _S409 = _S407 + 1U;
        float b_1 = SHEEN_ALBEDO_0[_S408] + (SHEEN_ALBEDO_0[_S409] - SHEEN_ALBEDO_0[_S408]) * _S405;
        float _S410 = (F32_exp((a_5 + (b_1 - a_5) * _S406)));
        if(_S400)
        {
            float a_6 = VELVET_ALBEDO_0[_S404] + (VELVET_ALBEDO_0[_S407] - VELVET_ALBEDO_0[_S404]) * _S405;
            float b_2 = VELVET_ALBEDO_0[_S408] + (VELVET_ALBEDO_0[_S409] - VELVET_ALBEDO_0[_S408]) * _S405;
            float _S411 = a_6 + (b_2 - a_6) * _S406;
            sheen_component_0 = _S411;
        }
        else
        {
            sheen_component_0 = _S410;
        }
        float _S412 = (F32_min((sheen_component_0), (1.0f)));
        float3  _S413 = make_float3 (1.0f) - material_1.sheen * make_float3 (_S412);
        float _S414 = rgb_to_greyscale(material_1.sheen);
        float _S415 = _S414 * _S412;
        float3  _S416 = material_1.sheen / make_float3 ((F32_max((sheen_component_0), (1.0f))));
        sheen_component_0 = _S415;
        sheen_1 = _S416;
        view_1 = v_3;
        scale_1 = _S413;
    }
    else
    {
        sheen_component_0 = 0.0f;
        sheen_1 = _S394;
        view_1 = _S394;
        scale_1 = _S393;
    }
    float _S417 = (F32_abs((material_1.toon.x)));
    bool _S418 = _S417 > 0.0f;
    if(_S418)
    {
        float _S419 = (F32_min((_S417), (1.0f)));
        float3  scale_2 = scale_1 * make_float3 (1.0f - _S419);
        float _S420 = rgb_to_greyscale(material_1.albedo);
        float _S421 = _S419 * _S420;
        toon_component_0 = _S421;
        scale_1 = scale_2;
    }
    else
    {
        toon_component_0 = 0.0f;
    }
    float3  _S422 = mix_0(_S391, material_1.albedo, material_1.metallic);
    float3  F_1 = _S422 * scale_1;
    float _S423 = rgb_to_greyscale(F_1);
    float _S424 = 1.0f - material_1.metallic;
    float3  _S425 = make_float3 (1.0f) - _S391;
    float3  _S426 = make_float3 ((1.0f - material_1.transmission) * _S424) * _S425 * scale_1;
    float3  _S427 = make_float3 (material_1.transmission * _S424) * _S425 * scale_1;
    float _S428 = (F32_max((_S423), (0.0f)));
    float _S429 = rgb_to_greyscale(_S426);
    float _S430 = (F32_max((_S429), (0.0f)));
    float _S431 = rgb_to_greyscale(_S427);
    float _S432 = sign_0(length_0(_S383));
    float _S433 = (F32_max((_S431 * _S432), (0.0f)));
    float _S434 = _S428 + _S430 + _S433 + toon_component_0;
    float _S435 = (F32_min((sheen_component_0), (1.0f)));
    bool _S436 = sheen_component_0 > 0.0f;
    bool _S437;
    if(_S436)
    {
        _S437 = !(_S434 > 0.0f);
    }
    else
    {
        _S437 = false;
    }
    float _S438 = _slang_select(_S437, 1.0f,_S435);
    float _S439 = (1.0f - _S438) / (F32_max((_S434), (0.0000152587890625f)));
    float _S440 = _S430 + toon_component_0;
    float _S441 = _S440 * _S439;
    float _S442 = _S428 * _S439;
    float _S443 = _S433 * _S439;
    bool _S444 = (frame_1.alphas.x) > 0.0f;
    float visible_1;
    if(_S444)
    {
        float3  _S445 = anisotropicLocal(v_3, frame_1.tangent, n_i_2);
        float _S446 = anisotropicG1(_S445, frame_1.alphas);
        float3  _S447 = anisotropicLocal(ggx_n_0, frame_1.tangent, n_i_2);
        float _S448 = anisotropicD(_S447, frame_1.alphas);
        float _S449 = _S446 * _S448;
        visible_1 = _S449;
    }
    else
    {
        visible_1 = 0.0f;
    }
    return BSDFLobes_x24init_0(_S379, _S380, _S383, F_1, _S423, 1.0f, _S426, _S427, _S441, _S442, _S443, 0.0f, sheen_1, _S438, view_1, frame_1.tangent, frame_1.alphas, visible_1, toon_component_0 / (F32_max((_S440), (0.0000152587890625f))));
}

__device__ float translucentShare(BSDFMaterial material_2)
{
    float _S450 = rgb_to_greyscale(material_2.translucent);
    float _S451 = rgb_to_greyscale(material_2.albedo);
    float _S452 = _S450 / (_S451 + _S450);
    bool _S453 = _S450 > 0.0f;
    float _S454 = _slang_select(_S453, _S452,0.0f);
    return _S454;
}

__device__ float smithG1(float alpha_2, float n_dot_x_0)
{
    float _S455 = alpha_2 * alpha_2;
    float _S456 = 2.0f * n_dot_x_0 / (n_dot_x_0 + (F32_sqrt((_S455 + (1.0f - _S455) * n_dot_x_0 * n_dot_x_0))));
    bool _S457 = alpha_2 > 0.0f;
    float _S458 = _slang_select(_S457, _S456,1.0f);
    return _S458;
}

__device__ float trowbridgeReitz(float alpha_3, float n_dot_h_1)
{
    float _S459 = alpha_3 * alpha_3;
    float _S460 = (1.0f - n_dot_h_1) * (1.0f + n_dot_h_1) + _S459 * n_dot_h_1 * n_dot_h_1;
    return _S459 / (F32_max((3.14159274101257324f * _S460 * _S460), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ float lobeDensity(float n_i_dot_l_0, float l_dot_h_0, float n_i_dot_v_0, float alpha_4, BSDFLobes lobes_0, float eta_i_2, float eta_o_2, uint lobe_0)
{
    bool _S461 = lobe_0 == 0U;
    if(_S461)
    {
        float _S462 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
        float _S463 = lobes_0.p_diffuse * (F32_abs((n_i_dot_l_0))) * 0.31830987334251404f;
        float _S464 = 1.0f - lobes_0.translucent_share;
        bool _S465 = n_i_dot_l_0 < 0.0f;
        float _S466 = _slang_select(_S465, lobes_0.translucent_share,_S464);
        float _S467 = _S463 * _S466;
        bool _S468 = (lobes_0.translucent_share) > 0.0f;
        float _S469 = _slang_select(_S468, _S467,_S462);
        bool _S470 = n_i_dot_v_0 > 0.0f;
        float _S471 = _slang_select(_S470, _S469,0.0f);
        return _S471;
    }
    bool _S472 = lobe_0 == 4U;
    bool _S473;
    if(_S472)
    {
        float _S474 = lobes_0.p_sheen_velvet * 0.5f * 0.31830987334251404f;
        bool _S475 = n_i_dot_l_0 > 0.0f;
        if(_S475)
        {
            _S473 = n_i_dot_v_0 > 0.0f;
        }
        else
        {
            _S473 = false;
        }
        float _S476 = _slang_select(_S473, _S474,0.0f);
        return _S476;
    }
    float _S477 = smithG1(alpha_4, n_i_dot_v_0);
    float _S478 = _S477 * lobes_0.v_dot_h;
    float _S479 = trowbridgeReitz(alpha_4, lobes_0.n_dot_h);
    float _S480 = _S478 * _S479 / n_i_dot_v_0;
    bool _S481 = alpha_4 > 0.0f;
    if(_S481)
    {
        _S473 = (lobes_0.v_dot_h) > 0.0f;
    }
    else
    {
        _S473 = false;
    }
    if(_S473)
    {
        _S473 = (lobes_0.n_dot_h) > 0.0f;
    }
    else
    {
        _S473 = false;
    }
    if(_S473)
    {
        _S473 = n_i_dot_v_0 > 0.0f;
    }
    else
    {
        _S473 = false;
    }
    float _S482 = _slang_select(_S473, _S480,0.0f);
    bool _S483 = (lobes_0.alphas.x) > 0.0f;
    float pdf_h_0;
    if(_S483)
    {
        float _S484 = lobes_0.visible * lobes_0.v_dot_h / n_i_dot_v_0;
        bool _S485 = (lobes_0.v_dot_h) > 0.0f;
        if(_S485)
        {
            _S473 = (lobes_0.n_dot_h) > 0.0f;
        }
        else
        {
            _S473 = false;
        }
        if(_S473)
        {
            _S473 = n_i_dot_v_0 > 0.0f;
        }
        else
        {
            _S473 = false;
        }
        float _S486 = _slang_select(_S473, _S484,0.0f);
        pdf_h_0 = _S486;
    }
    else
    {
        pdf_h_0 = _S482;
    }
    bool _S487 = lobe_0 == 1U;
    if(_S487)
    {
        float _S488 = eta_i_2 * lobes_0.v_dot_h + eta_o_2 * l_dot_h_0;
        float _S489 = lobes_0.p_refract * pdf_h_0 * eta_o_2 * eta_o_2 * (F32_abs((l_dot_h_0))) / (_S488 * _S488);
        bool _S490 = eta_i_2 != eta_o_2;
        if(_S490)
        {
            _S473 = l_dot_h_0 < 0.0f;
        }
        else
        {
            _S473 = false;
        }
        float _S491 = _slang_select(_S473, _S489,0.0f);
        return _S491;
    }
    float _S492 = lobes_0.p_reflect * pdf_h_0 / (4.0f * lobes_0.v_dot_h);
    bool _S493 = pdf_h_0 > 0.0f;
    float _S494 = _slang_select(_S493, _S492,0.0f);
    return _S494;
}

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_0, uint random_state_3, bool refracted_2, uint lobe_1, float pdf_0)
{
    SampleBSDF _S495;
    (&_S495)->unit_direction = unit_direction_1;
    (&_S495)->throughput = throughput_0;
    (&_S495)->random_state = random_state_3;
    (&_S495)->refracted = refracted_2;
    (&_S495)->lobe = lobe_1;
    (&_S495)->pdf = pdf_0;
    return _S495;
}

__device__ __forceinline__ float3  lobeThroughput(float3  l_0, float3  n_i_3, float alpha_5, BSDFMaterial material_3, BSDFLobes lobes_1, uint lobe_2)
{
    bool _S496 = lobe_2 == 0U;
    if(_S496)
    {
        bool _S497 = (dot_0(n_i_3, l_0)) < 0.0f;
        float3  _S498 = _slang_select(_S497, material_3.translucent,material_3.albedo);
        float _S499 = 1.0f - lobes_1.translucent_share;
        float _S500 = _slang_select(_S497, lobes_1.translucent_share,_S499);
        float3  _S501 = _S498 / make_float3 (_S500);
        bool _S502 = (lobes_1.translucent_share) > 0.0f;
        float3  _S503 = _slang_select(_S502, _S501,material_3.albedo);
        return lobes_1.diffuse_weight * _S503 / make_float3 (lobes_1.p_diffuse);
    }
    bool _S504 = lobe_2 == 4U;
    float f_1;
    if(_S504)
    {
        float3  _S505 = l_0 + lobes_1.view;
        float3  _S506 = ((((_S505)) * make_float3(rnorm3df(((_S505)).x, ((_S505)).y, ((_S505)).z))));
        float _S507 = dot_0(n_i_3, _S506);
        float _S508 = (F32_max((dot_0(n_i_3, l_0)), (0.0f)));
        float _S509 = (F32_max((dot_0(n_i_3, lobes_1.view)), (0.0f)));
        float _S510 = 1.0f / (F32_max((material_3.sheen_roughness), (0.05000000074505806f)));
        float _S511 = 1.0f - _S507 * _S507;
        float _S512 = (2.0f + _S510) * (F32_pow(((F32_max((_S511), (0.0f)))), (0.5f * _S510))) * 0.5f * 0.31830987334251404f / (F32_max((4.0f * (_S508 + _S509 - _S508 * _S509)), (0.0000152587890625f)));
        bool _S513 = (material_3.velvet) > 0.0f;
        if(_S513)
        {
            float _S514 = (F32_max((material_3.sheen_roughness), (0.00999999977648258f)));
            float _S515 = _S514 * _S514;
            float _S516 = (F32_max((_S511), (0.0000152587890625f)));
            float _S517 = (F32_exp((- _S507 * _S507 / (_S516 * _S515)))) / (3.14159274101257324f * _S515 * _S516 * _S516) * (F32_min((1.0f), (2.0f * _S507 * (F32_min((_S508), (_S509))) / (F32_max(((F32_abs((dot_0(_S506, lobes_1.view))))), (0.0000152587890625f)))))) / (F32_max((4.0f * _S508 * _S509), (0.0000152587890625f)));
            f_1 = _S517;
        }
        else
        {
            f_1 = _S512;
        }
        return lobes_1.sheen * make_float3 (f_1 * _S508 * 2.0f * 3.14159274101257324f / lobes_1.p_sheen_velvet);
    }
    bool _S518 = lobe_2 == 1U;
    if(_S518)
    {
        float _S519 = - dot_0(n_i_3, l_0);
        float _S520 = smithG1(alpha_5, (F32_max((_S519), (0.0f))));
        bool _S521 = (lobes_1.alphas.x) > 0.0f;
        if(_S521)
        {
            float3  _S522 = negate_0(n_i_3);
            float3  _S523 = anisotropicLocal(l_0, lobes_1.tangent, _S522);
            float _S524 = anisotropicG1(_S523, lobes_1.alphas);
            f_1 = _S524;
        }
        else
        {
            f_1 = _S520;
        }
        return lobes_1.refract_weight * make_float3 (f_1) * material_3.albedo / make_float3 (lobes_1.p_refract);
    }
    float _S525 = dot_0(n_i_3, l_0);
    float _S526 = smithG1(alpha_5, (F32_max((_S525), (0.0f))));
    bool _S527 = (lobes_1.alphas.x) > 0.0f;
    if(_S527)
    {
        float3  _S528 = anisotropicLocal(l_0, lobes_1.tangent, n_i_3);
        float _S529 = anisotropicG1(_S528, lobes_1.alphas);
        f_1 = _S529;
    }
    else
    {
        f_1 = _S526;
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
    ToonLobe_0 _S530;
    (&_S530)->a_7 = a_8;
    (&_S530)->s_0 = s_1;
    (&_S530)->b_3 = b_4;
    (&_S530)->glossy_0 = glossy_1;
    return _S530;
}

static __device__ ToonLobe_0 toonLobe_0(float3  toon_0)
{
    float _S531 = toon_0.x;
    bool _S532 = (F32_abs((_S531))) > 0.0f;
    float _S533 = _slang_select(_S532, _S531,1.0f);
    float _S534 = clamp_1(toon_0.y / _S533, 0.00000999999974738f, 1.0f) * 3.14159274101257324f / 2.0f;
    float _S535 = clamp_1(toon_0.z / _S533, 0.0f, 1.0f) * 3.14159274101257324f / 2.0f;
    return ToonLobe_x24init_0(_S534, _S535, (F32_min((_S534 + _S535), (1.57079637050628662f))), _S531 < 0.0f);
}

static __device__ float toonProfile_0(float t_13, ToonLobe_0 * lobe_3)
{
    float _S536 = lobe_3->a_7;
    float _S537;
    if(t_13 < (lobe_3->a_7))
    {
        _S537 = 1.0f;
    }
    else
    {
        _S537 = (F32_max((1.0f - (t_13 - _S536) / (F32_max((lobe_3->s_0), (0.0000152587890625f)))), (0.0f)));
    }
    return _S537;
}

static __device__ float toonIntegral_0(float t_14, ToonLobe_0 * lobe_4)
{
    float _S538 = lobe_4->a_7;
    bool _S539 = lobe_4->glossy_0;
    float _S540;
    if(lobe_4->glossy_0)
    {
        _S540 = 1.0f - (F32_cos(((F32_min((t_14), (_S538))))));
    }
    else
    {
        float _S541 = (F32_sin(((F32_min((t_14), (_S538))))));
        _S540 = _S541 * _S541 / 2.0f;
    }
    bool _S542 = t_14 > _S538;
    bool _S543;
    if(_S542)
    {
        _S543 = (lobe_4->s_0) > 0.0f;
    }
    else
    {
        _S543 = false;
    }
    bool _S544 = !_S543;
    if(_S544)
    {
        return _S540;
    }
    if(_S539)
    {
        float _S545 = (F32_cos((_S538)));
        float _S546 = (F32_cos((t_14)));
        return _S540 + (1.0f + _S538 / lobe_4->s_0) * (_S545 - _S546) - ((F32_sin((t_14))) - t_14 * _S546 - ((F32_sin((_S538))) - _S538 * _S545)) / lobe_4->s_0;
    }
    float _S547 = 2.0f * _S538;
    float _S548 = (F32_cos((_S547)));
    float _S549 = 2.0f * t_14;
    float _S550 = (F32_cos((_S549)));
    return _S540 + (1.0f + _S538 / lobe_4->s_0) * (_S548 - _S550) / 4.0f - ((F32_sin((_S549))) / 8.0f - t_14 * _S550 / 4.0f - ((F32_sin((_S547))) / 8.0f - _S538 * _S548 / 4.0f)) / lobe_4->s_0;
}

__device__ float toonDensity(float3  v_4, float3  l_1, float3  n_5, float3  toon_1)
{
    ToonLobe_0 _S551 = toonLobe_0(toon_1);
    float _S552 = dot_0(n_5, l_1);
    if(_S551.glossy_0)
    {
        float _S553 = (F32_acos((clamp_1(dot_0(make_float3 (2.0f * dot_0(n_5, v_4)) * n_5 - v_4, l_1), -1.0f, 1.0f))));
        ToonLobe_0 _S554 = _S551;
        float _S555 = toonProfile_0(_S553, &_S554);
        ToonLobe_0 _S556 = _S551;
        float _S557 = toonIntegral_0(_S551.b_3, &_S556);
        return _S555 / (6.28318548202514648f * _S557);
    }
    float _S558 = (F32_acos(((F32_min((_S552), (1.0f))))));
    ToonLobe_0 _S559 = _S551;
    float _S560 = toonProfile_0(_S558, &_S559);
    float _S561 = _S560 * _S552;
    ToonLobe_0 _S562 = _S551;
    float _S563 = toonIntegral_0(_S551.b_3, &_S562);
    float _S564 = _S561 / (6.28318548202514648f * _S563);
    bool _S565 = _S552 > 0.0f;
    float _S566 = _slang_select(_S565, _S564,0.0f);
    return _S566;
}

__device__ float toonBSDF(float3  v_5, float3  l_2, float3  n_6, float3  toon_2)
{
    ToonLobe_0 _S567 = toonLobe_0(toon_2);
    float _S568 = dot_0(n_6, v_5);
    float _S569 = dot_0(n_6, l_2);
    bool _S570 = _S568 > 0.0f;
    bool _S571;
    if(_S570)
    {
        _S571 = _S569 > 0.0f;
    }
    else
    {
        _S571 = false;
    }
    bool _S572 = !_S571;
    if(_S572)
    {
        return 0.0f;
    }
    if(_S567.glossy_0)
    {
        float _S573 = (F32_acos((clamp_1(dot_0(make_float3 (2.0f * _S568) * n_6 - v_5, l_2), -1.0f, 1.0f))));
        ToonLobe_0 _S574 = _S567;
        float _S575 = toonProfile_0(_S573, &_S574);
        ToonLobe_0 _S576 = _S567;
        float _S577 = toonIntegral_0(_S567.b_3, &_S576);
        return _S575 / (6.28318548202514648f * _S577);
    }
    float _S578 = (F32_acos(((F32_min((_S568), (1.0f))))));
    ToonLobe_0 _S579 = _S567;
    float _S580 = toonProfile_0(_S578, &_S579);
    float _S581 = (F32_acos(((F32_min((_S569), (1.0f))))));
    ToonLobe_0 _S582 = _S567;
    float _S583 = toonProfile_0(_S581, &_S582);
    float _S584 = _S580 * _S583;
    ToonLobe_0 _S585 = _S567;
    float _S586 = toonIntegral_0(_S567.b_3, &_S585);
    return _S584 / (6.28318548202514648f * _S586);
}

static __device__ void toonMix_0(SampleBSDF * drawn_0, float3  v_6, float3  n_i_4, BSDFMaterial * material_4, BSDFLobes * lobes_2)
{
    float3  _S587 = drawn_0->unit_direction;
    float _S588 = (F32_max((drawn_0->pdf), (0.0f)));
    float _S589 = (1.0f - lobes_2->toon_share) * _S588;
    float _S590 = lobes_2->toon_share * lobes_2->p_diffuse;
    float3  _S591 = material_4->toon;
    float _S592 = toonDensity(v_6, _S587, n_i_4, material_4->toon);
    float _S593 = _S589 + _S590 * _S592;
    float3  _S594 = make_float3 ((F32_min(((F32_abs((_S591.x)))), (1.0f)))) * material_4->albedo;
    float _S595 = toonBSDF(v_6, _S587, n_i_4, _S591);
    float3  _S596 = _S594 * make_float3 (_S595) * make_float3 ((F32_max((dot_0(n_i_4, _S587)), (0.0f))));
    float3  _S597 = make_float3 (0.0f);
    float3  _S598 = (drawn_0->throughput * make_float3 (_S588) + _S596) / make_float3 (_S593);
    bool _S599 = _S593 > 0.0f;
    float3  _S600 = _slang_select(_S599, _S598,_S597);
    drawn_0->throughput = _S600;
    drawn_0->pdf = _S593;
    return;
}

__device__ __forceinline__ SampleBSDF connectBSDF(float3  in_dir_1, float3  out_dir_0, float3  n_7, BSDFMaterial material_5, float eta_i_3, float eta_o_3, uint lobe_5, uint random_init_0)
{
    uint random_state_4 = random_init_0;
    float3  _S601 = negate_0(in_dir_1);
    float _S602 = dot_0(n_7, _S601);
    float _S603 = sign_0(_S602);
    float3  _S604 = n_7 * make_float3 (_S603);
    float _S605 = material_5.roughness;
    float _S606 = _S605 * _S605;
    AnisotropicFrame _S607 = anisotropicFrame(material_5, _S604);
    float3  _S608 = _S601 + out_dir_0;
    float3  _S609 = ((((_S608)) * make_float3(rnorm3df(((_S608)).x, ((_S608)).y, ((_S608)).z))));
    bool _S610 = lobe_5 == 0U;
    float3  ggx_n_1;
    if(_S610)
    {
        float3  _S611 = sampleHalfVector(_S601, _S604, _S606, _S607, &random_state_4);
        ggx_n_1 = _S611;
    }
    else
    {
        bool _S612 = lobe_5 == 1U;
        if(_S612)
        {
            float3  _S613 = negate_0(make_float3 (eta_i_3) * _S601 + make_float3 (eta_o_3) * out_dir_0);
            float3  _S614 = ((((_S613)) * make_float3(rnorm3df(((_S613)).x, ((_S613)).y, ((_S613)).z))));
            float _S615 = sign_0(dot_0(_S613, _S604));
            float3  _S616 = _S614 * make_float3 (_S615);
            ggx_n_1 = _S616;
        }
        else
        {
            ggx_n_1 = _S609;
        }
    }
    BSDFLobes _S617 = bsdfLobes(in_dir_1, _S601, _S604, ggx_n_1, material_5, eta_i_3, eta_o_3, _S607);
    BSDFLobes lobes_3 = _S617;
    float _S618 = translucentShare(material_5);
    (&lobes_3)->translucent_share = _S618;
    float _S619 = lobeDensity(dot_0(_S604, out_dir_0), dot_0(out_dir_0, ggx_n_1), (F32_abs((_S602))), _S606, lobes_3, eta_i_3, eta_o_3, lobe_5);
    bool _S620 = !(_S619 > 0.0f);
    if(_S620)
    {
        float3  _S621 = make_float3 (0.0f);
        return SampleBSDF_x24init_0(_S621, _S621, 0U, false, 0U, 0.0f);
    }
    float3  _S622 = lobeThroughput(out_dir_0, _S604, _S606, material_5, lobes_3, lobe_5);
    SampleBSDF _S623 = SampleBSDF_x24init_0(out_dir_0, _S622, random_state_4, lobe_5 == 1U, lobe_5, _S619);
    SampleBSDF sample_0 = _S623;
    bool _S624;
    if(_S610)
    {
        _S624 = ((&lobes_3)->toon_share) > 0.0f;
    }
    else
    {
        _S624 = false;
    }
    if(_S624)
    {
        BSDFMaterial _S625 = material_5;
        BSDFLobes _S626 = lobes_3;
        toonMix_0(&sample_0, _S601, _S604, &_S625, &_S626);
    }
    return sample_0;
}

__device__ __forceinline__ float3  neeBSDF(float3  in_dir_2, float3  dir_3, float3  n_8, BSDFMaterial material_6, float eta_i_4, float eta_o_4, bool refracted_3, float pdf_1, bool power_0, uint random_state_5)
{
    float3  _S627 = make_float3 (0.0f);
    uint i_6 = 0U;
    float3  f_2 = _S627;
    for(;;)
    {
        if(i_6 < 4U)
        {
        }
        else
        {
            break;
        }
        uint _S628;
        if(i_6 == 3U)
        {
            _S628 = 4U;
        }
        else
        {
            _S628 = i_6;
        }
        bool _S629 = _S628 == 0U;
        if(_S629)
        {
        }
        bool _S630;
        if(_S629)
        {
            float _S631 = rgb_to_greyscale(material_6.translucent);
            _S630 = _S631 > 0.0f;
        }
        else
        {
            _S630 = false;
        }
        bool _S632;
        if(_S630)
        {
            float _S633 = dot_0(n_8, dir_3);
            float3  _S634 = negate_0(in_dir_2);
            _S632 = ((_S633 * dot_0(n_8, _S634)) < 0.0f) == refracted_3;
        }
        else
        {
            _S632 = (_S628 == 1U) == refracted_3;
        }
        float3  f_3;
        if(_S632)
        {
            SampleBSDF _S635 = connectBSDF(in_dir_2, dir_3, n_8, material_6, eta_i_4, eta_o_4, _S628, random_state_5);
            bool _S636 = (_S635.pdf) > 0.0f;
            if(_S636)
            {
                if(power_0)
                {
                    float _S637 = _S635.pdf / pdf_1;
                    float3  f_4 = f_2 + _S635.throughput * make_float3 (_S635.pdf) / make_float3 (pdf_1 * (1.0f + _S637 * _S637));
                    f_3 = f_4;
                }
                else
                {
                    float3  f_5 = f_2 + _S635.throughput * make_float3 (_S635.pdf) / make_float3 (_S635.pdf + pdf_1);
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
    bool _S638 = wrongSide_0(is_inside_2, false, dir_4, surface_1.geometry_n);
    float3  _S639 = neeBSDF(in_dir_3, dir_4, surface_1.smooth_n, surface_1.material, eta_1.x, eta_1.y, _S638, pdf_2, false, random_state_6);
    return _S639;
}

static __device__ SkySample SkySample_x24init_0(float3  dir_5, float3  radiance_0, float3  color_0, uint random_state_7)
{
    SkySample _S640;
    (&_S640)->dir = dir_5;
    (&_S640)->radiance = radiance_0;
    (&_S640)->color = color_0;
    (&_S640)->random_state = random_state_7;
    return _S640;
}

static __device__ SkySample sampleSky_0(FKRay * ray_0, FKSurface * surface_2, float2  eta_2, bool is_inside_3, uint init_random_state_0, uint lobe_state_0, ShadowContext * context_2)
{
    uint2  _S641 = (fcptEnvironmentCdfSize());
    uint2  _S642 = make_uint2 (1U, 0U);
    uint2  _S643 = _S641 - _S642;
    Random _S644 = pcg(init_random_state_0);
    Random _S645 = pcg(_S644.state);
    Random _S646 = pcg(_S645.state);
    Random _S647 = pcg(_S646.state);
    uint _S648 = _S643.x;
    uint _S649 = searchCDF_0(make_uint2 (_S648, 0U), make_uint2 (0U, 1U), _S643.y, _S644.value);
    uint _S650 = searchCDF_0(make_uint2 (0U, _S649), _S642, _S648, _S645.value);
    float2  _S651 = make_float2 ((float)_S643.x, (float)_S643.y);
    float2  _S652 = (make_float2 (float(_S650), float(_S649)) + make_float2 (_S646.value, _S647.value)) / _S651 * make_float2 (6.28318548202514648f, 3.14159274101257324f);
    float _S653 = _S652.y;
    float _S654 = (F32_sin((_S653)));
    float _S655 = _S652.x;
    float3  _S656 = make_float3 (- _S654 * (F32_cos((_S655))), _S654 * (F32_sin((_S655))), (F32_cos((_S653))));
    float _S657 = environmentPdf_0(_S656);
    float3  _S658 = skyBSDF(ray_0->unit_direction, _S656, *surface_2, eta_2, is_inside_3, _S657, lobe_state_0);
    bool _S659 = !(_S657 > 0.0f);
    bool _S660;
    if(_S659)
    {
        _S660 = true;
    }
    else
    {
        _S660 = all_1(_S658 == make_float3 (0.0f));
    }
    if(_S660)
    {
        float3  _S661 = make_float3 (0.0f);
        return SkySample_x24init_0(_S656, _S661, _S661, _S647.state);
    }
    float3  _S662 = skyRadiance_0(ray_0->origin, surface_2, is_inside_3, _S656, context_2, _S647.state);
    return SkySample_x24init_0(_S656, _S662, _S658 * _S662, _S647.state);
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
    SampleBSDF _S663 = (fcptConnectHair((surface_3->hair), ((&surface_3->material)->albedo), ((&surface_3->material)->specular_tint), (in_dir_4), (light_1->dir)));
    float3  _S664 = _S663.throughput * make_float3 (_S663.pdf);
    float _S665 = light_1->density;
    float _S666 = 1.0f + _S663.pdf * _S663.pdf / (light_1->density * light_1->density);
    bool _S667;
    if(competing_0)
    {
        _S667 = _S665 > 0.0f;
    }
    else
    {
        _S667 = false;
    }
    float _S668 = _slang_select(_S667, _S666,1.0f);
    return _S664 / make_float3 (_S668) * light_1->radiance;
}

static __device__ TreeSample TreeSample_x24init_0(float3  dir_6, float3  radiance_1, float density_0, uint random_state_8)
{
    TreeSample _S669;
    (&_S669)->dir = dir_6;
    (&_S669)->radiance = radiance_1;
    (&_S669)->density = density_0;
    (&_S669)->random_state = random_state_8;
    return _S669;
}

__device__ uint pickChild(LightNode first_1, LightNode second_1, float3  p_10, float3  normal_3, float * pick_0, float * probability_3)
{
    float _S670 = importance(first_1, p_10, normal_3);
    float _S671 = importance(second_1, p_10, normal_3);
    float2  _S672 = make_float2 (_S670, _S671);
    bool _S673 = _S670 == 0.0f;
    bool _S674;
    if(_S673)
    {
        _S674 = _S671 == 0.0f;
    }
    else
    {
        _S674 = false;
    }
    if(_S674)
    {
        return 2U;
    }
    float _S675 = _S670 + _S671;
    bool _S676 = _S671 > 0.0f;
    if(_S676)
    {
        _S674 = (*pick_0 * _S675) >= _S670;
    }
    else
    {
        _S674 = false;
    }
    uint _S677 = uint(_S674);
    float _S678 = (F32_min(((*pick_0 * _S675 - float(_S677) * _S670) / _slang_vector_get_element(_S672, _S677)), (0.99999994039535522f)));
    *pick_0 = _S678;
    float _S679 = *probability_3 * (_slang_vector_get_element(_S672, _S677) / _S675);
    *probability_3 = _S679;
    return _S677;
}

__device__ float3  sampleSphere(float3  center_1, float radius_1, float3  p_11, float u1_0, float u2_0)
{
    float3  _S680 = center_1 - p_11;
    float _S681 = radius_1 * radius_1 / dot_0(_S680, _S680);
    float _S682 = u1_0 * _S681 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S681), (0.0f)))))));
    float _S683 = 2.0f * u1_0;
    bool _S684 = _S681 >= 1.0f;
    float _S685 = _slang_select(_S684, _S683,_S682);
    float _S686 = (F32_sqrt(((F32_max((_S685 * (2.0f - _S685)), (0.0f))))));
    float _S687 = 6.28318548202514648f * u2_0;
    float3  _S688 = make_float3 (_S686 * (F32_cos((_S687))), 1.0f - _S685, _S686 * (F32_sin((_S687))));
    float3  _S689 = ((((_S680)) * make_float3(rnorm3df(((_S680)).x, ((_S680)).y, ((_S680)).z))));
    float3  _S690 = tangentToWorld(_S688, _S689);
    return _S690;
}

__device__ float3  pointLightRadiance(float3  color_1, float intensity_0, float radius_2)
{
    return color_1 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_2 * radius_2);
}

static __device__ float raySphere_0(float3  center_2, float radius_3, FKRay * ray_1, float max_len_0)
{
    float3  _S691 = center_2 - ray_1->origin;
    float _S692 = dot_0(_S691, ray_1->unit_direction);
    float _S693 = dot_0(_S691, _S691) - _S692 * _S692;
    float _S694 = radius_3 * radius_3;
    bool _S695 = _S693 > _S694;
    if(_S695)
    {
        return 4.294967296e+09f;
    }
    float _S696 = (F32_sqrt((_S694 - _S693)));
    float _S697 = _S692 - _S696;
    float _S698 = _S692 + _S696;
    bool _S699 = _S697 > 0.0000152587890625f;
    bool _S700;
    if(_S699)
    {
        _S700 = _S697 < max_len_0;
    }
    else
    {
        _S700 = false;
    }
    if(_S700)
    {
        return _S697;
    }
    bool _S701 = _S698 > 0.0000152587890625f;
    if(_S701)
    {
        _S700 = _S698 < max_len_0;
    }
    else
    {
        _S700 = false;
    }
    if(_S700)
    {
        return _S698;
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
    Random _S702 = pcg(init_random_state_1);
    Random _S703 = pcg(_S702.state);
    Random _S704 = pcg(_S703.state);
    float3  _S705 = make_float3 (0.0f);
    TreeSample _S706 = TreeSample_x24init_0(_S705, _S705, 0.0f, _S704.state);
    TreeSample sample_1 = _S706;
    float3  _S707 = _slang_select(sided_0, _S705,smooth_n_2);
    float3  _S708 = origin_4 + make_float3 (geometry_offset_1) * smooth_n_2;
    float pick_1 = _S702.value;
    float probability_4 = 1.0f;
    uint n_9 = 0U;
    for(;;)
    {
        uint4  _S709 = (fcptLightNode((n_9)));
        if((_S709.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S710 = (fcptLightSecond((n_9)));
        uint _S711 = n_9 + 1U;
        LightNode _S712 = (fcptLightBounds((_S711)));
        LightNode _S713 = (fcptLightBounds((_S710)));
        uint _S714 = pickChild(_S712, _S713, origin_4, _S707, &pick_1, &probability_4);
        bool _S715 = _S714 > 1U;
        if(_S715)
        {
            return sample_1;
        }
        bool _S716 = _S714 == 1U;
        uint _S717 = _slang_select(_S716, _S710,_S711);
        n_9 = _S717;
    }
    bool _S718 = n_9 == 0U;
    bool _S719;
    if(_S718)
    {
        LightNode _S720 = (fcptLightBounds((0U)));
        float _S721 = importance(_S720, origin_4, _S707);
        _S719 = !(_S721 > 0.0f);
    }
    else
    {
        _S719 = false;
    }
    if(_S719)
    {
        return sample_1;
    }
    uint4  _S722 = (fcptLightNode((n_9)));
    FKHit _S723 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    bool _S724 = (_S722.x) == 2U;
    float3  emitter_point_0;
    float3  lift_n_0;
    float3  shadow_1;
    FKHit emitter_0;
    if(_S724)
    {
        FKLight _S725 = (fcptLight((_S722.y)));
        if(sided_0)
        {
            float _S726 = sign_0(dot_0(geometry_n_1, _S725.position - origin_4));
            float3  lift_n_1 = smooth_n_2 * make_float3 (_S726);
            float3  _S727 = origin_4 + make_float3 (geometry_offset_1) * lift_n_1;
            emitter_point_0 = _S727;
            lift_n_0 = lift_n_1;
        }
        else
        {
            emitter_point_0 = _S708;
            lift_n_0 = smooth_n_2;
        }
        bool _S728 = (_S725.variance) == 0.0f;
        if(_S728)
        {
            float3  _S729 = _S725.position - emitter_point_0;
            float3  _S730 = ((((_S729)) * make_float3(rnorm3df(((_S729)).x, ((_S729)).y, ((_S729)).z))));
            (&sample_1)->dir = _S730;
            float3  _S731 = _S725.color * make_float3 (_S725.intensity) / make_float3 (dot_0(_S729, _S729) * probability_4);
            (&sample_1)->radiance = _S731;
            shadow_1 = _S729;
        }
        else
        {
            float3  _S732 = sampleSphere(_S725.position, _S725.variance, emitter_point_0, _S703.value, _S704.value);
            (&sample_1)->dir = _S732;
            float _S733 = sphereDensity(_S725.position, _S725.variance, emitter_point_0);
            float _S734 = probability_4 * _S733;
            (&sample_1)->density = _S734;
            float3  _S735 = pointLightRadiance(_S725.color, _S725.intensity, _S725.variance);
            float3  _S736 = _S735 / make_float3 ((&sample_1)->density);
            (&sample_1)->radiance = _S736;
            FKRay _S737 = Ray_x24init_0(emitter_point_0, (&sample_1)->dir);
            float _S738 = raySphere_0(_S725.position, _S725.variance, &_S737, 4.294967296e+09f);
            float3  _S739 = (&sample_1)->dir * make_float3 (_S738);
            shadow_1 = _S739;
        }
        emitter_0 = _S723;
        emitter_point_0 = _S705;
    }
    else
    {
        uint _S740 = _S722.y;
        uint _S741 = (fcptTriangleOffset((_S740)));
        uint _S742 = _S741 + _S722.z;
        Matrix<float, 3, 3>  _S743 = (fcptWorldTriangle((_S740), (_S742)));
        float _S744 = (F32_sqrt((_S703.value)));
        float2  _S745 = make_float2 (_S744 * (1.0f - _S704.value), _S744 * _S704.value);
        float3  _S746 = mul_0(make_float3 (1.0f - _S744, _S745.x, _S745.y), _S743);
        if(sided_0)
        {
            float _S747 = sign_0(dot_0(geometry_n_1, _S746 - origin_4));
            float3  lift_n_2 = smooth_n_2 * make_float3 (_S747);
            float3  _S748 = origin_4 + make_float3 (geometry_offset_1) * lift_n_2;
            emitter_point_0 = _S748;
            lift_n_0 = lift_n_2;
        }
        else
        {
            bool _S749 = !((dot_0(smooth_n_2, _S746 - origin_4)) > 0.0f);
            if(_S749)
            {
                return sample_1;
            }
            emitter_point_0 = _S708;
            lift_n_0 = smooth_n_2;
        }
        FKHit emitter_1 = Hit_x24init_0(_S745, _S740, _S742, 0U, 0.0f);
        float3  _S750 = _S746 - emitter_point_0;
        float3  _S751 = ((((_S750)) * make_float3(rnorm3df(((_S750)).x, ((_S750)).y, ((_S750)).z))));
        (&sample_1)->dir = _S751;
        float _S752 = solidAngle(probability_4, cross_0(_S743.rows[int(1)] - _S743.rows[int(0)], _S743.rows[int(2)] - _S743.rows[int(0)]), _S750);
        (&sample_1)->density = _S752;
        bool _S753 = (fcptShadowFirst());
        bool _S754 = !_S753;
        if(_S754)
        {
            FKSurface _S755 = (fcptLightSurfaceAt((emitter_1), (_S746), (_S704.state), ((&sample_1)->dir), (context_3->depth), (length_0(_S746 - origin_4))));
            (&sample_1)->random_state = _S755.random_state;
            float3  _S756 = _slang_select(_S755.skip, _S705,_S755.material.emissive);
            float3  _S757 = _S756 / make_float3 ((&sample_1)->density);
            (&sample_1)->radiance = _S757;
        }
        shadow_1 = _S750;
        emitter_0 = emitter_1;
        emitter_point_0 = _S746;
    }
    FKHit _S758 = emitter_0;
    float3  _S759 = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, context_3, _S704.state, &_S758);
    bool _S760 = (fcptShadowFirst());
    if(_S760)
    {
        _S719 = (emitter_0.instance_index) != 4294967295U;
    }
    else
    {
        _S719 = false;
    }
    if(_S719)
    {
        _S719 = !all_1(_S759 == _S705);
    }
    else
    {
        _S719 = false;
    }
    if(_S719)
    {
        FKSurface _S761 = (fcptLightSurfaceAt((emitter_0), (emitter_point_0), (_S704.state), ((&sample_1)->dir), (context_3->depth), (length_0(emitter_point_0 - origin_4))));
        (&sample_1)->random_state = _S761.random_state;
        float3  _S762 = _slang_select(_S761.skip, _S705,_S761.material.emissive);
        float3  _S763 = _S762 / make_float3 ((&sample_1)->density);
        (&sample_1)->radiance = _S763;
    }
    float3  _S764 = (&sample_1)->radiance * _S759;
    bool _S765 = all_1(_S759 == _S705);
    float3  _S766 = _slang_select(_S765, _S705,_S764);
    (&sample_1)->radiance = _S766;
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
    float _S767 = 1.0f / (1.0f + b_5 / a_9 * (b_5 / a_9));
    bool _S768 = b_5 > 0.0f;
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

static __device__ float3  environment_0(float3  dir_7, uint depth_0, uint lobe_6)
{
    uint2  _S774 = (fcptEnvironmentMapSize());
    bool _S775 = (_S774.x) > 1U;
    bool _S776;
    if(_S775)
    {
        uint2  _S777 = (fcptEnvironmentMapSize());
        _S776 = (_S777.y) > 1U;
    }
    else
    {
        _S776 = false;
    }
    if(_S776)
    {
        float3  _S778 = (fcptEnvMapSample((dir_7), (depth_0), (lobe_6)));
        return _S778;
    }
    float3  _S779 = (fcptAmbient());
    return _S779;
}

static __device__ bool environmentMapped_0()
{
    uint2  _S780 = (fcptEnvironmentCdfSize());
    bool _S781 = (_S780.x) > 1U;
    bool _S782;
    if(_S781)
    {
        uint2  _S783 = (fcptEnvironmentCdfSize());
        _S782 = (_S783.y) > 1U;
    }
    else
    {
        _S782 = false;
    }
    bool _S784 = !_S782;
    if(_S784)
    {
        return false;
    }
    uint2  _S785 = (fcptEnvironmentMapSize());
    bool _S786 = (_S785.x) > 1U;
    if(_S786)
    {
        uint2  _S787 = (fcptEnvironmentMapSize());
        _S782 = (_S787.y) > 1U;
    }
    else
    {
        _S782 = false;
    }
    return _S782;
}

static __device__ float escapeWeight_0(float pdf_3, float3  dir_8)
{
    bool _S788 = pdf_3 <= 0.0f;
    bool _S789;
    if(_S788)
    {
        _S789 = true;
    }
    else
    {
        bool _S790 = environmentMapped_0();
        _S789 = !_S790;
    }
    if(_S789)
    {
        return 1.0f;
    }
    float _S791 = environmentPdf_0(dir_8);
    return pdf_3 / (pdf_3 + _S791);
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
    uint2  _S792 = uint2 {global_invocation_id_1.x, global_invocation_id_1.y};
    int2  _S793 = make_int2 ((int)_S792.x, (int)_S792.y);
    uint _S794 = previousSeed_0(_S793);
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
            uint _S795 = previousSeed_0(_S793 + make_int2 (x_16, y_5));
            bool _S796 = _S795 == _S794;
            uint _S797 = _slang_select(_S796, 1U,0U);
            uint count_3 = count_2 + _S797;
            int x_17 = x_16 + int(1);
            x_16 = x_17;
            count_2 = count_3;
        }
        int y_6 = y_5 + int(1);
        y_5 = y_6;
    }
    float _S798 = float(count_2 - 1U) / 288.0f;
    bool _S799 = _S794 != 0U;
    float _S800 = _slang_select(_S799, _S798,0.0f);
    fcptStoreDuplication((_S793), (make_uint4 ((F32_asuint((_S800))), 0U, 0U, 0U)));
    return;
}

__device__ uint stream(uint seed_2, uint index_0)
{
    uint _S801 = hash(index_0);
    uint _S802 = hash(seed_2 ^ _S801);
    return _S802;
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
    float _S803 = rgb_to_greyscale(weight_0);
    bool _S804 = _S803 > 0.0f;
    bool _S805;
    if(_S804)
    {
        _S805 = _S803 < 3.00000000549775576e+38f;
    }
    else
    {
        _S805 = false;
    }
    bool _S806 = !_S805;
    if(_S806)
    {
        return;
    }
    bool _S807 = sel_2->sums;
    if(_S807)
    {
        float3  _S808 = sel_2->color + weight_0;
        sel_2->color = _S808;
        return;
    }
    float _S809 = sel_2->w_sum + _S803;
    sel_2->w_sum = _S809;
    float3  _S810 = sel_2->color + weight_0;
    sel_2->color = _S810;
    Random _S811 = pcg(sel_2->random_state);
    sel_2->random_state = _S811.state;
    bool _S812 = (_S811.value * sel_2->w_sum) <= _S803;
    if(_S812)
    {
        sel_2->r = candidate_0;
    }
    return;
}

__device__ void offerShifted(Selection * sel_3, Reservoir r_3, Shift shifted_0, float mis_0)
{
    Reservoir candidate_1 = r_3;
    float3  _S813 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_1)->f = _S813;
    float _S814 = r_3.jac * shifted_0.jac;
    (&candidate_1)->jac = _S814;
    offer(sel_3, candidate_1, make_float3 (mis_0) * shifted_0.f * make_float3 (r_3.w));
    return;
}

__device__ Reservoir finalize(Selection sel_4, float c_1)
{
    Reservoir r_4 = sel_4.r;
    float _S815 = rgb_to_greyscale((&r_4)->f);
    float _S816 = sel_4.w_sum / _S815;
    bool _S817 = _S815 > 0.0f;
    float _S818 = _slang_select(_S817, _S816,0.0f);
    (&r_4)->w = _S818;
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
    uint2  _S819 = uint2 {global_invocation_id_2.x, global_invocation_id_2.y};
    int2  _S820 = make_int2 ((int)_S819.x, (int)_S819.y);
    float3  _S821 = make_float3 (0.0f);
    FKHit _S822 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S823 = Domain_x24init_0(_S821, _S821, &_S822, 0.0f, 0.0f);
    Domain dom_4 = _S823;
    bool _S824 = (fcptCurrentDomain((_S820), (&dom_4)));
    bool _S825 = !_S824;
    if(_S825)
    {
        Reservoir _S826 = (Reservoir{});
        fcptStoreReservoirPrevious((_S820), (_S826), ((&dom_4)->hit));
        return;
    }
    Reservoir _S827 = (fcptLoadReservoirTemporal((_S820)));
    uint t_15 = 0U;
    float count_4 = 0.0f;
    float c_sum_1 = _S827.c;
    for(;;)
    {
        uint _S828 = (fcptRestirNeighbours());
        if(t_15 < _S828)
        {
        }
        else
        {
            break;
        }
        int2  _S829 = partner_0(_S820, t_15);
        Domain neighbor_0 = _S823;
        bool _S830 = (fcptCurrentDomain((_S829), (&neighbor_0)));
        if(_S830)
        {
            float count_5 = count_4 + 1.0f;
            uint4  _S831 = (fcptReservoirTemporal((_S829), (0U)));
            float c_sum_2 = c_sum_1 + (U32_asfloat((_S831.w)));
            count_4 = count_5;
            c_sum_1 = c_sum_2;
        }
        uint t_16 = t_15 + 1U;
        t_15 = t_16;
    }
    float _S832 = _S827.c / (F32_max((count_4), (1.0f)));
    float _S833 = rgb_to_greyscale(_S827.f);
    bool _S834 = count_4 == 0.0f;
    float _S835 = _slang_select(_S834, 1.0f,0.0f);
    Selection _S836 = (Selection{});
    Selection sel_5 = _S836;
    uint _S837 = (fcptFrame());
    uint _S838 = hash(_S837);
    uint _S839 = global_invocation_id_2.x;
    uint2  _S840 = (fcptRenderSize());
    uint _S841 = stream(_S838, _S839 + _S840.x * global_invocation_id_2.y);
    uint _S842 = stream(_S841, 195U);
    (&sel_5)->random_state = _S842;
    t_15 = 0U;
    float canonical_mis_0 = _S835;
    for(;;)
    {
        uint _S843 = (fcptRestirNeighbours());
        if(t_15 < _S843)
        {
        }
        else
        {
            break;
        }
        int2  _S844 = partner_0(_S820, t_15);
        Domain neighbor_dom_0 = _S823;
        bool _S845 = (fcptCurrentDomain((_S844), (&neighbor_dom_0)));
        if(_S845)
        {
            Reservoir _S846 = (fcptLoadReservoirTemporal((_S844)));
            uint4  _S847 = (fcptShiftData((_S844), (t_15)));
            float4  _S848 = asfloat_0(_S847);
            uint4  _S849 = (fcptShiftData((_S820), (t_15)));
            float4  _S850 = asfloat_0(_S849);
            float _S851 = pairShare(_S846.c, _S832, c_sum_1);
            bool _S852 = _S833 > 0.0f;
            float canonical_mis_1;
            if(_S852)
            {
                float _S853 = rgb_to_greyscale(float3 {_S850.x, _S850.y, _S850.z});
                float _S854 = canonicalWeight(_S851, _S832, _S833, _S846.c, _S853);
                float canonical_mis_2 = canonical_mis_0 + _S854;
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            float3  _S855 = float3 {_S848.x, _S848.y, _S848.z};
            Shift _S856 = Shift_x24init_0(_S855, _S848.w);
            float _S857 = rgb_to_greyscale(_S846.f);
            float _S858 = rgb_to_greyscale(_S855);
            float _S859 = neighborWeight(_S851, _S846.c, _S857, _S832, _S858);
            offerShifted(&sel_5, _S846, _S856, _S859);
            canonical_mis_0 = canonical_mis_1;
        }
        uint t_17 = t_15 + 1U;
        t_15 = t_17;
    }
    offerShifted(&sel_5, _S827, Shift_x24init_0(_S827.f, 1.0f), canonical_mis_0);
    Reservoir _S860 = finalize(sel_5, c_sum_1);
    fcptStoreReservoirPrevious((_S820), (_S860), ((&dom_4)->hit));
    fcptStorePreviousLayer((_S820), (5U), (make_uint4 (asuint_0((&(&dom_4)->hit)->uv).x, asuint_0((&(&dom_4)->hit)->uv).y, 0U, 0U)));
    fcptAddColor((_S820), (make_float4 ((&sel_5)->color.x, (&sel_5)->color.y, (&sel_5)->color.z, 0.0f)));
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
    uint _S861 = queuedShift_0(workgroup_id_1, local_invocation_index_4);
    bool _S862 = _S861 != 4294967295U;
    if(_S862)
    {
        uint2  _S863 = make_uint2 (_S861, _S861 >> 14U) & make_uint2 (16383U);
        int2  _S864 = make_int2 ((int)_S863.x, (int)_S863.y);
        ShiftJob _S865 = (ShiftJob{});
        ShiftJob shift_job_0 = _S865;
        Shift _S866 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
        uint _S867 = _S861 >> 28U;
        bool _S868 = spatialJob_0(_S864, _S867, &shift_job_0, true);
        Shift shifted_1;
        if(_S868)
        {
            Domain _S869 = (&shift_job_0)->dom;
            Reservoir _S870 = (&shift_job_0)->r;
            Shift _S871 = passShift_0(&_S869, &_S870);
            shifted_1 = _S871;
        }
        else
        {
            shifted_1 = _S866;
        }
        fcptStoreShiftData((_S864), (_S867), (make_uint4 (asuint_1(shifted_1.f).x, asuint_1(shifted_1.f).y, asuint_1(shifted_1.f).z, (F32_asuint((shifted_1.jac))))));
    }
    return;
}

static __device__ void restir_prepass_0(uint3  global_invocation_id_3, uint local_invocation_index_5)
{
    uint2  _S872 = uint2 {global_invocation_id_3.x, global_invocation_id_3.y};
    int2  _S873 = make_int2 ((int)_S872.x, (int)_S872.y);
    FixedArray<uint, 3>  _S874;
    spatialBins_0(_S873, &_S874);
    FixedArray<uint, 3>  _S875 = _S874;
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
        bool _S876 = (_S875[t_18]) == 40U;
        if(_S876)
        {
            fcptStoreShiftData((_S873), (t_18), (make_uint4 (0U)));
        }
        uint t_19 = t_18 + 1U;
        t_18 = t_19;
    }
    FixedArray<uint, 3>  _S877 = _S875;
    queueShifts_0(_S873, &_S877, global_invocation_id_3, local_invocation_index_5);
    return;
}

static __device__ void restir_count_0(uint3  global_invocation_id_4, uint local_invocation_index_6)
{
    uint2  _S878 = uint2 {global_invocation_id_4.x, global_invocation_id_4.y};
    int2  _S879 = make_int2 ((int)_S878.x, (int)_S878.y);
    FixedArray<uint, 3>  _S880;
    spatialBins_0(_S879, &_S880);
    FixedArray<uint, 3>  _S881 = _S880;
    countShifts_0(&_S881, local_invocation_index_6);
    return;
}

static __device__ void restir_temporal_shift_0(uint3  workgroup_id_2, uint local_invocation_index_7)
{
    uint _S882 = queuedShift_0(workgroup_id_2, local_invocation_index_7);
    bool _S883 = _S882 != 4294967295U;
    if(_S883)
    {
        uint2  _S884 = make_uint2 (_S882, _S882 >> 14U) & make_uint2 (16383U);
        int2  _S885 = make_int2 ((int)_S884.x, (int)_S884.y);
        ShiftJob _S886 = (ShiftJob{});
        ShiftJob shift_job_1 = _S886;
        Shift _S887 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
        uint _S888 = _S882 >> 28U;
        bool _S889 = temporalJob_0(_S885, _S888, &shift_job_1, true);
        Shift shifted_2;
        if(_S889)
        {
            if(_S888 == 1U)
            {
                Shift _S890 = (fcptShiftPrevious(((&shift_job_1)->dom), ((&shift_job_1)->r)));
                shifted_2 = _S890;
            }
            else
            {
                Domain _S891 = (&shift_job_1)->dom;
                Reservoir _S892 = (&shift_job_1)->r;
                Shift _S893 = passShift_0(&_S891, &_S892);
                shifted_2 = _S893;
            }
        }
        else
        {
            shifted_2 = _S887;
        }
        fcptStoreTemporalShift((_S885), (_S888), (make_uint4 (asuint_1(shifted_2.f).x, asuint_1(shifted_2.f).y, asuint_1(shifted_2.f).z, (F32_asuint((shifted_2.jac))))));
    }
    return;
}

static __device__ void restir_temporal_prepass_0(uint3  global_invocation_id_5, uint local_invocation_index_8)
{
    uint2  _S894 = uint2 {global_invocation_id_5.x, global_invocation_id_5.y};
    int2  _S895 = make_int2 ((int)_S894.x, (int)_S894.y);
    FixedArray<uint, 3>  _S896;
    temporalBins_0(_S895, &_S896);
    FixedArray<uint, 3>  _S897 = _S896;
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
        bool _S898 = (_S897[t_20]) == 40U;
        if(_S898)
        {
            fcptStoreTemporalShift((_S895), (t_20), (make_uint4 (0U)));
        }
        uint t_21 = t_20 + 1U;
        t_20 = t_21;
    }
    FixedArray<uint, 3>  _S899 = _S897;
    queueShifts_0(_S895, &_S899, global_invocation_id_5, local_invocation_index_8);
    return;
}

static __device__ void restir_temporal_count_0(uint3  global_invocation_id_6, uint local_invocation_index_9)
{
    uint2  _S900 = uint2 {global_invocation_id_6.x, global_invocation_id_6.y};
    int2  _S901 = make_int2 ((int)_S900.x, (int)_S900.y);
    FixedArray<uint, 3>  _S902;
    temporalBins_0(_S901, &_S902);
    FixedArray<uint, 3>  _S903 = _S902;
    countShifts_0(&_S903, local_invocation_index_9);
    return;
}

static __device__ float interpolate_0(float a_10, float b_6, float t_22)
{
    return a_10 + (b_6 - a_10) * t_22;
}

__device__ float confidenceCap(float duplicated_0)
{
    float _S904 = interpolate_0(20.0f, 1.0f, (F32_pow((duplicated_0), (0.10000000149011612f))));
    return _S904;
}

__device__ float2  temporalWeights(float c_2, float p_c_1, float c_t_0, float p_t_0, float g_previous_0, float g_current_0)
{
    float _S905 = c_2 * p_c_1;
    float _S906 = c_t_0 * p_t_0;
    return make_float2 (_S905 / (_S905 + c_t_0 * g_previous_0), _S906 / (_S906 + c_2 * g_current_0));
}

static __device__ void restir_temporal_0(uint3  global_invocation_id_7)
{
    uint2  _S907 = uint2 {global_invocation_id_7.x, global_invocation_id_7.y};
    int2  _S908 = make_int2 ((int)_S907.x, (int)_S907.y);
    float3  _S909 = make_float3 (0.0f);
    FKHit _S910 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S911 = Domain_x24init_0(_S909, _S909, &_S910, 0.0f, 0.0f);
    Domain dom_5 = _S911;
    bool _S912 = (fcptCurrentDomain((_S908), (&dom_5)));
    bool _S913 = !_S912;
    if(_S913)
    {
        Reservoir _S914 = (Reservoir{});
        fcptStoreReservoirTemporal((_S908), (_S914), ((&dom_5)->hit));
        return;
    }
    Reservoir _S915 = (fcptLoadReservoirInitial((_S908)));
    Domain stored_0 = _S911;
    int2  _S916 = make_int2 (int(-1));
    bool _S917 = (fcptStoredDomainInitial((_S908), (_S915.seed), (&stored_0)));
    int2  q_2;
    if(_S917)
    {
        Domain _S918 = stored_0;
        int2  _S919 = temporalNeighbor_0(_S908, &_S918, _S915.seed);
        q_2 = _S919;
    }
    else
    {
        q_2 = _S916;
    }
    bool _S920 = (q_2.x) >= int(0);
    Reservoir r_5;
    if(_S920)
    {
        Reservoir _S921 = (fcptLoadReservoirPrevious((q_2)));
        uint4  _S922 = (fcptDuplication((q_2)));
        float _S923 = (U32_asfloat((_S922.x)));
        uint _S924 = (fcptRestirDecorrelation());
        bool _S925 = _S924 == 1U;
        float _S926 = _slang_select(_S925, _S923,0.0f);
        float _S927 = confidenceCap(_S926);
        float _S928 = (F32_min((_S921.c), (_S927)));
        Domain target_3 = _S911;
        bool _S929 = (_S921.w) > 0.0f;
        bool _S930;
        if(_S929)
        {
            bool _S931 = (fcptStoredDomainInitial((_S908), (_S921.seed), (&target_3)));
            _S930 = _S931;
        }
        else
        {
            _S930 = false;
        }
        if(_S930)
        {
            Domain _S932 = (fcptPreviousDomain((q_2), (_S921.seed)));
            Domain _S933 = _S932;
            Domain _S934 = target_3;
            bool _S935 = temporalIdentity_0(0U, &_S933, &_S934);
            _S930 = _S935;
        }
        else
        {
            _S930 = false;
        }
        float4  _S936;
        if(_S930)
        {
            _S936 = make_float4 (_S921.f.x, _S921.f.y, _S921.f.z, 1.0f);
        }
        else
        {
            uint4  _S937 = (fcptTemporalShift((_S908), (0U)));
            _S936 = asfloat_0(_S937);
        }
        bool _S938 = (_S915.w) > 0.0f;
        if(_S938)
        {
            Domain _S939 = (fcptPreviousDomain((q_2), (_S915.seed)));
            Domain _S940 = _S939;
            Domain _S941 = stored_0;
            bool _S942 = temporalIdentity_0(1U, &_S940, &_S941);
            _S930 = _S942;
        }
        else
        {
            _S930 = false;
        }
        float4  _S943;
        if(_S930)
        {
            _S943 = make_float4 (_S915.f.x, _S915.f.y, _S915.f.z, 1.0f);
        }
        else
        {
            uint4  _S944 = (fcptTemporalShift((_S908), (1U)));
            _S943 = asfloat_0(_S944);
        }
        float _S945 = rgb_to_greyscale(_S915.f);
        float _S946 = rgb_to_greyscale(_S921.f);
        Selection _S947 = (Selection{});
        Selection sel_6 = _S947;
        uint _S948 = (fcptFrame());
        uint _S949 = hash(_S948);
        uint _S950 = global_invocation_id_7.x;
        uint2  _S951 = (fcptRenderSize());
        uint _S952 = stream(_S949, _S950 + _S951.x * global_invocation_id_7.y);
        uint _S953 = stream(_S952, 194U);
        (&sel_6)->random_state = _S953;
        float4  _S954 = _S943;
        float _S955 = rgb_to_greyscale(float3 {_S954.x, _S954.y, _S954.z});
        float4  _S956 = _S936;
        float3  _S957 = float3 {_S956.x, _S956.y, _S956.z};
        float _S958 = rgb_to_greyscale(_S957);
        float2  _S959 = temporalWeights(_S915.c, _S945, _S928, _S946, _S955, _S958);
        offerShifted(&sel_6, _S915, Shift_x24init_0(_S915.f, 1.0f), _S959.x);
        offerShifted(&sel_6, _S921, Shift_x24init_0(_S957, _S936.w), _S959.y);
        Reservoir _S960 = finalize(sel_6, _S915.c + _S928);
        r_5 = _S960;
    }
    else
    {
        r_5 = _S915;
    }
    fcptStoreReservoirTemporal((_S908), (r_5), ((&dom_5)->hit));
    return;
}

static __device__ void restir_initial_0(uint3  global_invocation_id_8)
{
    uint2  _S961 = uint2 {global_invocation_id_8.x, global_invocation_id_8.y};
    int2  _S962 = make_int2 ((int)_S961.x, (int)_S961.y);
    float3  _S963 = make_float3 (0.0f);
    float2  _S964 = make_float2 (0.0f);
    FKHit _S965 = Hit_x24init_0(_S964, 0U, 0U, 0U, 0.0f);
    Domain _S966 = Domain_x24init_0(_S963, _S963, &_S965, 0.0f, 0.0f);
    Domain dom_6 = _S966;
    bool _S967 = (fcptCurrentDomain((_S962), (&dom_6)));
    bool _S968 = !_S967;
    if(_S968)
    {
        Reservoir _S969 = (Reservoir{});
        fcptStoreReservoirInitial((_S962), (_S969), ((&dom_6)->hit));
        return;
    }
    uint _S970 = (fcptFrame());
    uint _S971 = hash(_S970);
    uint _S972 = global_invocation_id_8.x;
    uint2  _S973 = (fcptRenderSize());
    uint _S974 = stream(_S971, _S972 + _S973.x * global_invocation_id_8.y);
    Selection _S975 = (Selection{});
    Selection initial_0 = _S975;
    uint _S976 = stream(_S974, 193U);
    (&initial_0)->random_state = _S976;
    bool _S977 = (fcptRestirUsed());
    bool _S978 = !_S977;
    (&initial_0)->sums = _S978;
    uint _S979 = stream(_S974, 0U);
    (&(&initial_0)->r)->seed = _S979;
    FKHit _S980 = Hit_x24init_0(_S964, 4294967295U, 0U, 0U, 0.0f);
    uint _S981 = (fcptSamples());
    float _S982 = 1.0f / float(_S981);
    FKHit hit_2 = _S980;
    uint i_13 = 0U;
    for(;;)
    {
        uint _S983 = (fcptSamples());
        if(i_13 < _S983)
        {
        }
        else
        {
            break;
        }
        Reservoir _S984 = (Reservoir{});
        Reservoir r_6 = _S984;
        uint _S985 = stream(_S974, i_13);
        (&r_6)->seed = _S985;
        Domain path_0 = _S966;
        bool _S986 = (fcptStoredDomainInitial((_S962), ((&r_6)->seed), (&path_0)));
        bool _S987 = !_S986;
        if(_S987)
        {
            fcptMissed((_S962), (path_0), (_S982));
            uint i_14 = i_13 + 1U;
            i_13 = i_14;
            continue;
        }
        Domain _S988 = path_0;
        Reservoir _S989 = r_6;
        Shift _S990 = passWalk_0(&_S988, &_S989, false, _S982, &initial_0);
        bool _S991 = ((&(&initial_0)->r)->seed) == ((&r_6)->seed);
        FKHit hit_3;
        if(_S991)
        {
            FKHit _S992 = (&path_0)->hit;
            hit_3 = _S992;
        }
        else
        {
            hit_3 = hit_2;
        }
        hit_2 = hit_3;
        uint i_14 = i_13 + 1U;
        i_13 = i_14;
    }
    float3  _S993 = (&initial_0)->glow;
    float3  _S994 = (&initial_0)->color;
    bool _S995 = (&initial_0)->sums;
    float3  _S996 = _slang_select(_S995, _S994,_S963);
    fcptAddColor((_S962), (make_float4 ((_S993 + _S996).x, (_S993 + _S996).y, (_S993 + _S996).z, 1.0f)));
    Reservoir _S997 = finalize(initial_0, 1.0f);
    fcptStoreReservoirInitial((_S962), (_S997), (hit_2));
    return;
}

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_4, float3  origin_5, float3  smooth_n_3, float3  start_6)
{
    NEEVertex _S998;
    (&_S998)->none = none_0;
    (&_S998)->pdf = pdf_4;
    (&_S998)->origin = origin_5;
    (&_S998)->smooth_n = smooth_n_3;
    (&_S998)->start = start_6;
    return _S998;
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
    Vertex _S999;
    (&_S999)->rough = rough_0;
    (&_S999)->lobe = lobe_7;
    (&_S999)->pdf = pdf_5;
    (&_S999)->cos = cos_0;
    (&_S999)->inside = inside_0;
    return _S999;
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
    float3  _S1000 = exp_0((make_float3 (sigma_1) - extinction_0) * make_float3 (distance_2));
    float3  _S1001 = scatter_0 * _S1000 / make_float3 (sigma_1);
    float3  _S1002 = _slang_select(scatters_0, _S1001,_S1000);
    return _S1002;
}

static __device__ bool scatterSampled_0(bool replay_1, uint b_7, uint stop_0, bool varying_0)
{
    bool _S1003 = !replay_1;
    bool _S1004;
    if(_S1003)
    {
        _S1004 = true;
    }
    else
    {
        bool _S1005 = b_7 == stop_0;
        if(_S1005)
        {
            _S1004 = !varying_0;
        }
        else
        {
            _S1004 = false;
        }
    }
    return _S1004;
}

static __device__ uint arrivalLobe_0(uint b_8, uint prev_lobe_0)
{
    bool _S1006 = b_8 > 0U;
    uint _S1007 = _slang_select(_S1006, prev_lobe_0,3U);
    return _S1007;
}

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_0, uint depth_1, uint lobe_8, bool surface_4, float length_2, float width_1, FKHit * own_0, bool fiber_0)
{
    ShadowContext _S1008;
    (&_S1008)->extinction_behind = extinction_behind_0;
    (&_S1008)->extinction_front = extinction_front_0;
    (&_S1008)->fillings = fillings_0;
    (&_S1008)->side = side_0;
    (&_S1008)->depth = depth_1;
    (&_S1008)->lobe = lobe_8;
    (&_S1008)->surface = surface_4;
    (&_S1008)->length = length_2;
    (&_S1008)->width = width_1;
    (&_S1008)->own = *own_0;
    (&_S1008)->fiber = fiber_0;
    return _S1008;
}

static __device__ float phaseHG_0(float g_0, float mu_0)
{
    bool _S1009 = (F32_abs((g_0))) < 0.00100000004749745f;
    if(_S1009)
    {
        return 0.07957746833562851f;
    }
    float _S1010 = g_0 * g_0;
    return (1.0f - _S1010) * 0.25f * 0.31830987334251404f / (F32_pow((1.0f + _S1010 - 2.0f * g_0 * mu_0), (1.5f)));
}

__device__ float3  safeDivide(float3  a_11, float3  b_9)
{
    float3  _S1011 = a_11 / b_9;
    float3  _S1012 = make_float3 (0.0f);
    bool3  _S1013 = b_9 == _S1012;
    float3  _S1014 = _slang_select(_S1013, _S1012,_S1011);
    return _S1014;
}

static __device__ uint insertBits_0(uint e_2, uint newbits_0, uint offset_1, uint count_6)
{
    uint _S1015 = (1U << count_6) - 1U;
    return (e_2 & (~(_S1015 << offset_1))) | ((newbits_0 & _S1015) << offset_1);
}

__device__ Reservoir withEnd(Reservoir r_7, uint end_type_0, uint end_0, float3  f_6)
{
    Reservoir candidate_2 = r_7;
    uint _S1016 = insertBits_0(r_7.path, end_0, 0U, 5U);
    uint _S1017 = insertBits_0(_S1016, end_type_0, 12U, 3U);
    (&candidate_2)->path = _S1017;
    (&candidate_2)->f = f_6;
    return candidate_2;
}

__device__ float survivalProbability(float3  throughput_1, float density_1)
{
    return (F32_min(((F32_max(((F32_max((throughput_1.x), ((F32_max((throughput_1.y), (throughput_1.z)))))) / density_1), (0.0f)))), (1.0f)));
}

static __device__ float3  isotropic_0(uint random_state_9)
{
    Random _S1018 = pcg(random_state_9);
    Random _S1019 = pcg(_S1018.state);
    float _S1020 = 1.0f - 2.0f * _S1018.value;
    float _S1021 = (F32_sqrt(((F32_max((1.0f - _S1020 * _S1020), (0.0f))))));
    float _S1022 = 6.28318548202514648f * _S1019.value;
    return make_float3 (_S1021 * (F32_cos((_S1022))), _S1021 * (F32_sin((_S1022))), _S1020);
}

static __device__ float3  samplePhase_0(float g_1, float3  dir_9, uint random_state_10, float * pdf_6)
{
    bool _S1023 = (F32_abs((g_1))) < 0.00100000004749745f;
    if(_S1023)
    {
        *pdf_6 = 0.07957746833562851f;
        float3  _S1024 = isotropic_0(random_state_10);
        return _S1024;
    }
    Random _S1025 = pcg(random_state_10);
    Random _S1026 = pcg(_S1025.state);
    float _S1027 = g_1 * g_1;
    float _S1028 = 2.0f * g_1;
    float _S1029 = (1.0f - _S1027) / (1.0f - g_1 + _S1028 * _S1025.value);
    float _S1030 = clamp_1((1.0f + _S1027 - _S1029 * _S1029) / _S1028, -1.0f, 1.0f);
    float _S1031 = (F32_sqrt(((F32_max((1.0f - _S1030 * _S1030), (0.0f))))));
    float _S1032 = 6.28318548202514648f * _S1026.value;
    float _S1033 = phaseHG_0(g_1, _S1030);
    *pdf_6 = _S1033;
    float3  _S1034 = tangentToWorld(make_float3 (_S1031 * (F32_cos((_S1032))), _S1030, _S1031 * (F32_sin((_S1032)))), dir_9);
    float3  _S1035 = ((((_S1034)) * make_float3(rnorm3df(((_S1034)).x, ((_S1034)).y, ((_S1034)).z))));
    return _S1035;
}

static __device__ Vertex scatteredVertex_0(bool is_inside_4)
{
    return Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_4);
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_0, float3  emissive_0, float roughness_0, float metallic_0, float transmission_0, float ior_0, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_2, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_2, float velvet_0, float3  toon_3)
{
    BSDFMaterial _S1036;
    (&_S1036)->albedo = albedo_0;
    (&_S1036)->emissive = emissive_0;
    (&_S1036)->roughness = roughness_0;
    (&_S1036)->metallic = metallic_0;
    (&_S1036)->transmission = transmission_0;
    (&_S1036)->ior = ior_0;
    (&_S1036)->absorption = absorption_0;
    (&_S1036)->specular_tint = specular_tint_0;
    (&_S1036)->specular_level = specular_level_0;
    (&_S1036)->translucent = translucent_0;
    (&_S1036)->sheen = sheen_2;
    (&_S1036)->sheen_roughness = sheen_roughness_0;
    (&_S1036)->anisotropy = anisotropy_0;
    (&_S1036)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S1036)->tangent = tangent_2;
    (&_S1036)->velvet = velvet_0;
    (&_S1036)->toon = toon_3;
    return _S1036;
}

static __device__ FKMedium Medium_x24init_0(float3  scatter_1, float3  extinction_1, float g_2)
{
    FKMedium _S1037;
    (&_S1037)->scatter = scatter_1;
    (&_S1037)->extinction = extinction_1;
    (&_S1037)->g = g_2;
    return _S1037;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_7, bool skip_0, uint random_state_11, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S1038;
    (&_S1038)->smooth_n = smooth_n_4;
    (&_S1038)->geometry_n = geometry_n_2;
    (&_S1038)->geometry_offset = geometry_offset_2;
    (&_S1038)->material = *material_7;
    (&_S1038)->skip = skip_0;
    (&_S1038)->random_state = random_state_11;
    (&_S1038)->coverage = coverage_0;
    (&_S1038)->encloses = encloses_0;
    (&_S1038)->volume = *volume_0;
    (&_S1038)->fills = fills_0;
    (&_S1038)->hair = hair_0;
    return _S1038;
}

static __device__ FKSurface emitting_0(FKSurface * surface_5, bool top_0)
{
    FKSurface lower_0 = *surface_5;
    float3  _S1039 = (&surface_5->material)->emissive;
    float3  _S1040 = make_float3 (0.0f);
    bool _S1041 = !top_0;
    float3  _S1042 = _slang_select(_S1041, _S1040,_S1039);
    (&(&lower_0)->material)->emissive = _S1042;
    return lower_0;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_6, float u_2)
{
    float _S1043 = surface_6->coverage;
    bool _S1044 = u_2 < _S1043;
    if(_S1044)
    {
        return *surface_6;
    }
    float3  _S1045 = make_float3 (0.0f);
    float3  _S1046 = make_float3 (1.0f);
    BSDFMaterial _S1047 = Material_x24init_0(_S1045, _S1045, 0.0f, 0.0f, 0.0f, 0.0f, _S1045, _S1046, 1.0f, _S1045, _S1045, 0.5f, 0.0f, 0.0f, _S1045, 0.0f, _S1045);
    BSDFMaterial material_8 = _S1047;
    (&material_8)->albedo = _S1046;
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
    bool _S1048 = transmission_1 > 0.0f;
    bool _S1049;
    if(_S1048)
    {
        _S1049 = true;
    }
    else
    {
        _S1049 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S1050;
    if(_S1049)
    {
        _S1050 = 1.0f;
    }
    else
    {
        _S1050 = -1.0f;
    }
    return _S1050;
}

static __device__ bool arrivesBehind_0(float3  dir_10, float3  n_10)
{
    return (dot_0(dir_10, n_10)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_7, float3  dir_11)
{
    float3  _S1051 = surface_7->geometry_n;
    float _S1052 = facingSign((&surface_7->material)->transmission, surface_7->geometry_n, dir_11);
    FKSurface faced_0 = *surface_7;
    float3  _S1053 = surface_7->smooth_n * make_float3 (_S1052);
    (&faced_0)->smooth_n = _S1053;
    float3  _S1054 = _S1051 * make_float3 (_S1052);
    (&faced_0)->geometry_n = _S1054;
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
    float3  _S1055 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_3) * log_0(_S1055));
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
    bool _S1056;
    if(open_0)
    {
        _S1056 = prev_rough_0;
    }
    else
    {
        _S1056 = false;
    }
    if(_S1056)
    {
        _S1056 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S1056 = false;
    }
    return _S1056;
}

__device__ float2  vertexEta(BSDFMaterial material_9, float n_dot_v_0)
{
    bool _S1057 = n_dot_v_0 < 0.0f;
    float _S1058 = _slang_select(_S1057, material_9.ior,1.0f);
    float _S1059 = _slang_select(_S1057, 1.0f,material_9.ior);
    return make_float2 (_S1058, _S1059);
}

__device__ bool neeDecision(BSDFMaterial material_10, float n_dot_v_1, float eta_i_5, float eta_o_5)
{
    float _S1060 = fresnel((F32_abs((n_dot_v_1))), eta_i_5, eta_o_5);
    float3  _S1061 = mix_0(make_float3 (_S1060), material_10.albedo, material_10.metallic);
    float _S1062 = rgb_to_greyscale(_S1061);
    float _S1063 = (F32_max(((1.0f - _S1062) * (1.0f - material_10.metallic) * (1.0f - material_10.transmission)), (0.0f)));
    bool _S1064 = _S1063 > 0.03999999910593033f;
    bool _S1065;
    if(_S1064)
    {
        _S1065 = true;
    }
    else
    {
        _S1065 = (material_10.roughness) > 0.20000000298023224f;
    }
    return _S1065;
}

static __device__ bool isTranslucent_0(BSDFMaterial * material_11)
{
    float _S1066 = rgb_to_greyscale(material_11->translucent);
    return _S1066 > 0.0f;
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
    MediumSides _S1067;
    (&_S1067)->behind = *behind_0;
    (&_S1067)->front = *front_0;
    (&_S1067)->fillings = fillings_1;
    (&_S1067)->face = face_1;
    return _S1067;
}

static __device__ MediumSides mediumSides_0(FKSurface * surface_8, FKMedium * medium_0, uint filling_0, float3  dir_12, FKMedium * outside_0)
{
    float3  _S1068 = surface_8->geometry_n;
    MediumSides _S1069 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_8->geometry_n);
    MediumSides sides_0 = _S1069;
    bool _S1070 = surface_8->encloses;
    if(_S1070)
    {
        (&sides_0)->behind = surface_8->volume;
        *&((&(&sides_0)->fillings)->x) = surface_8->fills;
        bool _S1071 = (dot_0(dir_12, _S1068)) > 0.0f;
        if(_S1071)
        {
            (&sides_0)->front = *outside_0;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_9, bool turned_0, float3  extinction_2, uint filling_1, float3  dir_13, uint depth_2, uint lobe_9, float length_3, float width_2, FKHit * own_1, bool fiber_1, FKMedium * outside_1)
{
    float3  _S1072 = surface_9->geometry_n;
    ShadowContext _S1073 = ShadowContext_x24init_0(extinction_2, extinction_2, make_uint2 (filling_1), surface_9->geometry_n, depth_2, lobe_9, true, length_3, width_2, own_1, fiber_1);
    bool _S1074 = surface_9->encloses;
    ShadowContext context_4;
    if(_S1074)
    {
        FKSurface faced_1 = *surface_9;
        float3  _S1075 = - _S1072;
        float3  _S1076 = _slang_select(turned_0, _S1075,_S1072);
        (&faced_1)->geometry_n = _S1076;
        FKMedium _S1077 = Medium_x24init_0(make_float3 (0.0f), extinction_2, 0.0f);
        FKSurface _S1078 = faced_1;
        FKMedium _S1079 = _S1077;
        MediumSides _S1080 = mediumSides_0(&_S1078, &_S1079, filling_1, dir_13, outside_1);
        ShadowContext _S1081 = ShadowContext_x24init_0(_S1080.behind.extinction, _S1080.front.extinction, _S1080.fillings, _S1072, depth_2, lobe_9, true, length_3, width_2, own_1, fiber_1);
        if(turned_0)
        {
            uint2  _S1082 = _S1080.fillings;
            ShadowContext _S1083 = ShadowContext_x24init_0(_S1080.front.extinction, _S1080.behind.extinction, uint2 {_S1082.y, _S1082.x}, _S1072, depth_2, lobe_9, true, length_3, width_2, own_1, fiber_1);
            context_4 = _S1083;
        }
        else
        {
            context_4 = _S1081;
        }
    }
    else
    {
        context_4 = _S1073;
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
    float3  _S1084 = negate_0(in_dir_5);
    bool _S1085 = (dot_0(g_n_0, _S1084) * dot_0(g_n_0, out_dir_1)) > 0.0f;
    if(_S1085)
    {
        SampleBSDF _S1086 = connectBSDF(in_dir_5, out_dir_1, n_11, material_12, eta_i_6, eta_o_6, 0U, random_state_12);
        SampleBSDF _S1087 = connectBSDF(in_dir_5, out_dir_1, n_11, material_12, eta_i_6, eta_o_6, 2U, random_state_12);
        SampleBSDF _S1088 = connectBSDF(in_dir_5, out_dir_1, n_11, material_12, eta_i_6, eta_o_6, 4U, random_state_12);
        return _S1086.throughput * make_float3 (_S1086.pdf) + _S1087.throughput * make_float3 (_S1087.pdf) + _S1088.throughput * make_float3 (_S1088.pdf);
    }
    SampleBSDF _S1089 = connectBSDF(in_dir_5, out_dir_1, n_11, material_12, eta_i_6, eta_o_6, 1U, random_state_12);
    return _S1089.throughput * make_float3 (_S1089.pdf);
}

__device__ float3  translucentCorrection(float3  in_dir_6, float3  out_dir_2, float3  n_12, float3  g_n_1, BSDFMaterial material_13, float eta_i_7, float eta_o_7, uint random_state_13)
{
    float _S1090 = dot_0(n_12, out_dir_2);
    float3  _S1091 = negate_0(in_dir_6);
    bool _S1092 = (_S1090 * dot_0(n_12, _S1091)) < 0.0f;
    SampleBSDF _S1093 = connectBSDF(in_dir_6, out_dir_2, n_12, material_13, eta_i_7, eta_o_7, 0U, random_state_13);
    float3  _S1094 = negate_0(in_dir_6);
    bool _S1095 = (dot_0(g_n_1, _S1094) * dot_0(g_n_1, out_dir_2)) > 0.0f;
    float3  _S1096 = make_float3 (0.0f);
    float3  _S1097 = _S1093.throughput * make_float3 (_S1093.pdf);
    float _S1098 = _slang_select(_S1095, -1.0f,1.0f);
    float3  _S1099 = _S1097 * make_float3 (_S1098);
    float3  _S1100 = _slang_select(_S1092, _S1099,_S1096);
    return _S1100;
}

__device__ float3  translucentBSDF(float3  in_dir_7, float3  out_dir_3, float3  n_13, float3  g_n_2, BSDFMaterial material_14, float eta_i_8, float eta_o_8, uint random_state_14)
{
    float3  _S1101 = BSDF(in_dir_7, out_dir_3, n_13, g_n_2, material_14, eta_i_8, eta_o_8, random_state_14);
    float3  _S1102 = translucentCorrection(in_dir_7, out_dir_3, n_13, g_n_2, material_14, eta_i_8, eta_o_8, random_state_14);
    return _S1101 + _S1102;
}

static __device__ __forceinline__ float3  lightBSDF_0(float3  in_dir_8, TreeSample * light_2, float3  smooth_n_5, float3  geometry_n_4, BSDFMaterial * material_15, float eta_i_9, float eta_o_9, bool competing_1, uint random_state_15)
{
    bool _S1103 = !competing_1;
    bool _S1104;
    if(_S1103)
    {
        _S1104 = true;
    }
    else
    {
        _S1104 = (light_2->density) == 0.0f;
    }
    if(_S1104)
    {
        bool _S1105 = isTranslucent_0(material_15);
        if(_S1105)
        {
            float3  _S1106 = translucentBSDF(in_dir_8, light_2->dir, smooth_n_5, geometry_n_4, *material_15, eta_i_9, eta_o_9, random_state_15);
            return _S1106 * light_2->radiance;
        }
        float3  _S1107 = BSDF(in_dir_8, light_2->dir, smooth_n_5, geometry_n_4, *material_15, eta_i_9, eta_o_9, random_state_15);
        return _S1107 * light_2->radiance;
    }
    float3  _S1108 = light_2->dir;
    bool _S1109 = (dot_0(geometry_n_4, - in_dir_8) * dot_0(geometry_n_4, light_2->dir)) <= 0.0f;
    float3  _S1110 = neeBSDF(in_dir_8, _S1108, smooth_n_5, *material_15, eta_i_9, eta_o_9, _S1109, light_2->density, true, random_state_15);
    return _S1110 * light_2->radiance * make_float3 (light_2->density);
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S1111 = (F32_sqrt((random_1_0)));
    float _S1112 = 6.28318548202514648f * random_2_0;
    float _S1113 = _S1111 * (F32_cos((_S1112)));
    float _S1114 = _S1111 * (F32_sin((_S1112)));
    float _S1115 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1113 * _S1113 - _S1114 * _S1114))))));
    return make_float3 (_S1113, _S1115, _S1114);
}

static __device__ float toonInvert_0(float target_4, ToonLobe_0 * lobe_10)
{
    bool _S1116 = lobe_10->glossy_0;
    float t_23;
    if(lobe_10->glossy_0)
    {
        t_23 = (F32_acos((clamp_1(1.0f - target_4, -1.0f, 1.0f))));
    }
    else
    {
        t_23 = (F32_asin(((F32_min(((F32_sqrt((2.0f * target_4)))), (1.0f))))));
    }
    float _S1117 = lobe_10->a_7;
    if(t_23 < (lobe_10->a_7))
    {
    }
    else
    {
        t_23 = (_S1117 + lobe_10->b_3) / 2.0f;
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
        float _S1118 = toonProfile_0(t_23, lobe_10);
        float _S1119 = _S1118 * (F32_sin((t_23)));
        float _S1120;
        if(_S1116)
        {
            _S1120 = 1.0f;
        }
        else
        {
            _S1120 = (F32_cos((t_23)));
        }
        float _S1121 = _S1119 * _S1120;
        float _S1122 = toonIntegral_0(t_23, lobe_10);
        float _S1123 = (_S1122 - target_4) / _S1121;
        bool _S1124 = _S1121 > 0.0f;
        float _S1125 = _slang_select(_S1124, _S1123,0.0f);
        float _S1126 = clamp_1(t_23 - _S1125, 0.0f, lobe_10->b_3);
        int k_1 = k_0 + int(1);
        t_23 = _S1126;
        k_0 = k_1;
    }
    return t_23;
}

__device__ float3  sampleToon(float3  v_7, float3  n_14, float3  toon_4, float u_1_0, float u_2_0)
{
    ToonLobe_0 _S1127 = toonLobe_0(toon_4);
    ToonLobe_0 _S1128 = _S1127;
    float _S1129 = toonIntegral_0(_S1127.b_3, &_S1128);
    float _S1130 = u_1_0 * _S1129;
    ToonLobe_0 _S1131 = _S1127;
    float _S1132 = toonInvert_0(_S1130, &_S1131);
    float _S1133 = 6.28318548202514648f * u_2_0;
    float3  _S1134;
    if(_S1127.glossy_0)
    {
        float3  _S1135 = make_float3 (2.0f * dot_0(n_14, v_7)) * n_14 - v_7;
        float3  _S1136 = ((((_S1135)) * make_float3(rnorm3df(((_S1135)).x, ((_S1135)).y, ((_S1135)).z))));
        _S1134 = _S1136;
    }
    else
    {
        _S1134 = n_14;
    }
    float _S1137 = (F32_sin((_S1132)));
    float3  _S1138 = tangentToWorld(make_float3 (_S1137 * (F32_cos((_S1133))), (F32_cos((_S1132))), _S1137 * (F32_sin((_S1133)))), _S1134);
    return _S1138;
}

static __device__ float3  reflect_0(float3  i_19, float3  n_15)
{
    return i_19 - make_float3 (2.0f * dot_0(n_15, i_19)) * n_15;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_9, float3  n_16, BSDFMaterial material_16, float eta_i_10, float eta_o_10, uint random_init_1, float2  screen_space_0)
{
    uint random_state_16 = random_init_1;
    float3  _S1139 = negate_0(in_dir_9);
    float _S1140 = dot_0(n_16, _S1139);
    float _S1141 = sign_0(_S1140);
    float3  n_i_5 = n_16 * make_float3 (_S1141);
    float _S1142 = (F32_abs((_S1140)));
    float _S1143 = material_16.roughness;
    float _S1144 = _S1143 * _S1143;
    AnisotropicFrame _S1145 = anisotropicFrame(material_16, n_i_5);
    float3  _S1146 = sampleHalfVector(_S1139, n_i_5, _S1144, _S1145, &random_state_16);
    BSDFLobes _S1147 = bsdfLobes(in_dir_9, _S1139, n_i_5, _S1146, material_16, eta_i_10, eta_o_10, _S1145);
    BSDFLobes lobes_4 = _S1147;
    float _S1148 = translucentShare(material_16);
    (&lobes_4)->translucent_share = _S1148;
    float3  _S1149 = make_float3 (1.0f);
    SampleBSDF _S1150 = SampleBSDF_x24init_0(_S1149, _S1149, 0U, false, 0U, 0.0f);
    SampleBSDF sample_2 = _S1150;
    Random _S1151 = pcg(random_state_16);
    random_state_16 = _S1151.state;
    bool _S1152 = (_S1151.value) < ((&lobes_4)->p_sheen_velvet);
    if(_S1152)
    {
        Random _S1153 = pcg(random_state_16);
        Random _S1154 = pcg(_S1153.state);
        (&sample_2)->random_state = _S1154.state;
        float _S1155 = _S1153.value;
        float _S1156 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1155 * _S1155))))));
        float _S1157 = 6.28318548202514648f * _S1154.value;
        float3  _S1158 = tangentToWorld(make_float3 (_S1156 * (F32_cos((_S1157))), _S1153.value, _S1156 * (F32_sin((_S1157)))), n_i_5);
        (&sample_2)->unit_direction = _S1158;
        float3  _S1159 = lobeThroughput((&sample_2)->unit_direction, n_i_5, _S1144, material_16, lobes_4, 4U);
        (&sample_2)->throughput = _S1159;
        float _S1160 = lobeDensity(_S1153.value, 0.0f, _S1142, _S1144, lobes_4, eta_i_10, eta_o_10, 4U);
        (&sample_2)->pdf = _S1160;
        (&sample_2)->lobe = 4U;
        return sample_2;
    }
    float _S1161 = _S1151.value - (&lobes_4)->p_sheen_velvet;
    bool _S1162 = _S1161 < ((&lobes_4)->p_diffuse);
    if(_S1162)
    {
        Random _S1163 = pcg(random_state_16);
        Random _S1164 = pcg(_S1163.state);
        (&sample_2)->random_state = _S1164.state;
        float3  _S1165 = sampleCosWeightedHemisphere(_S1163.value, _S1164.value);
        bool _S1166 = ((&lobes_4)->toon_share) > 0.0f;
        if(_S1166)
        {
            bool _S1167 = _S1161 >= ((&lobes_4)->p_diffuse * (1.0f - (&lobes_4)->toon_share));
            bool _S1168 = _S1161 < ((&lobes_4)->p_diffuse * (1.0f - (&lobes_4)->toon_share) * (&lobes_4)->translucent_share);
            float _S1169 = _S1165.y;
            float _S1170 = - _S1169;
            float _S1171 = _slang_select(_S1168, _S1170,_S1169);
            float3  _S1172;
            if(_S1167)
            {
                float3  _S1173 = sampleToon(_S1139, n_i_5, material_16.toon, _S1163.value, _S1164.value);
                _S1172 = _S1173;
            }
            else
            {
                float3  _S1174 = tangentToWorld(make_float3 (_S1165.x, _S1171, _S1165.z), n_i_5);
                _S1172 = _S1174;
            }
            (&sample_2)->unit_direction = _S1172;
            float3  _S1175 = lobeThroughput((&sample_2)->unit_direction, n_i_5, _S1144, material_16, lobes_4, 0U);
            (&sample_2)->throughput = _S1175;
            float _S1176 = lobeDensity(dot_0(n_i_5, (&sample_2)->unit_direction), 0.0f, _S1142, _S1144, lobes_4, eta_i_10, eta_o_10, 0U);
            (&sample_2)->pdf = _S1176;
            bool _S1177 = (dot_0(n_i_5, (&sample_2)->unit_direction)) < 0.0f;
            (&sample_2)->refracted = _S1177;
            BSDFMaterial _S1178 = material_16;
            BSDFLobes _S1179 = lobes_4;
            toonMix_0(&sample_2, _S1139, n_i_5, &_S1178, &_S1179);
            return sample_2;
        }
        bool _S1180 = _S1161 < ((&lobes_4)->p_diffuse * (&lobes_4)->translucent_share);
        float _S1181 = _S1165.y;
        float _S1182 = - _S1181;
        float _S1183 = _slang_select(_S1180, _S1182,_S1181);
        float3  _S1184 = tangentToWorld(make_float3 (_S1165.x, _S1183, _S1165.z), n_i_5);
        (&sample_2)->unit_direction = _S1184;
        float3  _S1185 = lobeThroughput((&sample_2)->unit_direction, n_i_5, _S1144, material_16, lobes_4, 0U);
        (&sample_2)->throughput = _S1185;
        float _S1186 = lobeDensity(_S1183, 0.0f, _S1142, _S1144, lobes_4, eta_i_10, eta_o_10, 0U);
        (&sample_2)->pdf = _S1186;
        (&sample_2)->refracted = _S1180;
        return sample_2;
    }
    bool _S1187 = _S1161 < ((&lobes_4)->p_diffuse + (&lobes_4)->p_refract);
    if(_S1187)
    {
        (&sample_2)->unit_direction = (&lobes_4)->refracted;
        float _S1188 = lobeDensity(0.0f, dot_0((&sample_2)->unit_direction, _S1146), _S1142, _S1144, lobes_4, eta_i_10, eta_o_10, 1U);
        (&sample_2)->pdf = _S1188;
        float3  _S1189 = lobeThroughput((&sample_2)->unit_direction, n_i_5, _S1144, material_16, lobes_4, 1U);
        (&sample_2)->throughput = _S1189;
        (&sample_2)->random_state = random_state_16;
        (&sample_2)->refracted = true;
        (&sample_2)->lobe = 1U;
        return sample_2;
    }
    float3  _S1190 = reflect_0(in_dir_9, _S1146);
    float3  _S1191 = ((((_S1190)) * make_float3(rnorm3df(((_S1190)).x, ((_S1190)).y, ((_S1190)).z))));
    (&sample_2)->unit_direction = _S1191;
    float3  _S1192 = lobeThroughput((&sample_2)->unit_direction, n_i_5, _S1144, material_16, lobes_4, 2U);
    (&sample_2)->throughput = _S1192;
    (&sample_2)->random_state = random_state_16;
    (&sample_2)->lobe = 2U;
    float _S1193 = lobeDensity(0.0f, 0.0f, _S1142, _S1144, lobes_4, eta_i_10, eta_o_10, 2U);
    (&sample_2)->pdf = _S1193;
    return sample_2;
}

__device__ bool withinInverseFootprint(float pdf_7, bool diffuse_0, float prev_cos_0, float distance_5, float threshold_1)
{
    bool _S1194 = pdf_7 > 0.0f;
    bool _S1195;
    if(_S1194)
    {
        if(diffuse_0)
        {
            _S1195 = true;
        }
        else
        {
            _S1195 = (pdf_7 * prev_cos_0 / (distance_5 * distance_5) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S1195 = false;
    }
    return _S1195;
}

__device__ bool roughLobe(float pdf_8, bool diffuse_1, float roughness_1)
{
    bool _S1196 = pdf_8 > 0.0f;
    bool _S1197;
    if(_S1196)
    {
        if(diffuse_1)
        {
            _S1197 = true;
        }
        else
        {
            _S1197 = roughness_1 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S1197 = false;
    }
    return _S1197;
}

static __device__ bool passesLayer_0(uint layers_0, bool refracting_0, bool passed_0)
{
    bool _S1198 = layers_0 > 1U;
    bool _S1199;
    if(_S1198)
    {
        _S1199 = refracting_0 != passed_0;
    }
    else
    {
        _S1199 = false;
    }
    return _S1199;
}

static __device__ float widened_0(float spread_1, float pdf_9, bool delta_0)
{
    float _S1200 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * pdf_9))))), (3.14159274101257324f)));
    bool _S1201 = !delta_0;
    float _S1202 = _slang_select(_S1201, _S1200,0.0f);
    return spread_1 + _S1202;
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
    int _S1203;
    Shift ended_0;
    float density_3;
    float spread_3;
    float width_4;
    float sky_pdf_1;
    float spread_4;
    float width_5;
    uint b_11;
    float3  _S1204 = make_float3 (0.0f);
    Shift _S1205 = Shift_x24init_0(_S1204, 0.0f);
    uint _S1206 = r_8->path;
    uint _S1207 = extractBits_0(r_8->path, 0U, 5U);
    uint _S1208 = extractBits_0(_S1206, 5U, 5U);
    uint _S1209 = extractBits_0(_S1206, 10U, 2U);
    uint _S1210 = extractBits_0(_S1206, 12U, 3U);
    bool passes_0;
    if(replay_2)
    {
        bool _S1211 = _S1210 >= 3U;
        uint _S1212 = _slang_select(_S1211, 1U,0U);
        uint _S1213 = _S1207 + _S1212;
        uint _S1214 = (fcptMaxBounces());
        passes_0 = _S1213 > _S1214;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S1205;
    }
    uint _S1215 = _S1208 - 1U;
    bool _S1216 = _S1210 == 3U;
    uint _S1217 = _slang_select(_S1216, 1U,0U);
    uint _S1218 = _S1207 + _S1217;
    bool _S1219 = _S1209 == 0U;
    uint _S1220 = _slang_select(_S1219, _S1218,_S1215);
    FKHit _S1221 = (fcptReservoirHit((*r_8)));
    float3  _S1222 = dom_7->x0;
    float3  _S1223 = dom_7->x1 - dom_7->x0;
    float3  _S1224 = ((((_S1223)) * make_float3(rnorm3df(((_S1223)).x, ((_S1223)).y, ((_S1223)).z))));
    FKRay _S1225 = Ray_x24init_0(dom_7->x1, _S1224);
    FKRay ray_2 = _S1225;
    FKHit hit_4 = dom_7->hit;
    float3  scatter_in_0 = _S1204;
    float3  throughput_3 = make_float3 (1.0f);
    float3  weight_1 = throughput_3;
    float3  glowed_0 = _S1204;
    float3  extinction_in_0 = _S1204;
    float g_in_0 = 0.0f;
    uint filling_2 = 4294967295U;
    float _S1226 = dom_7->spread;
    float _S1227 = dom_7->width;
    float _S1228 = length_0(_S1223);
    NEEVertex _S1229 = NEEVertex_x24init_0(true, 0.0f, _S1204, _S1204, _S1204);
    NEEVertex nee_vertex_0 = _S1229;
    Vertex _S1230 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_0 = _S1230;
    Reservoir _S1231 = (Reservoir{});
    Reservoir chain_0 = _S1231;
    uint _S1232 = r_8->seed;
    (&chain_0)->seed = r_8->seed;
    (&ray_2)->origin = _S1222;
    (&hit_4)->distance = _S1228;
    FKMedium _S1233 = (fcptCameraMedium(((&ray_2)->unit_direction), ((&hit_4)->distance), (&filling_2)));
    uint _S1234 = filling_2;
    bool _S1235 = (fcptVaryingUsed());
    uint _S1236 = _slang_select(_S1235, _S1234,4294967295U);
    filling_2 = _S1236;
    scatter_in_0 = _S1233.scatter;
    extinction_in_0 = _S1233.extinction;
    g_in_0 = _S1233.g;
    Reservoir _S1237 = chain_0;
    uint _S1238 = filling_2;
    for(;;)
    {
        bool _S1239 = (fcptVaryingUsed());
        if(_S1239)
        {
            passes_0 = _S1238 != 4294967295U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            float _S1240 = (fcptMajorant((_S1238)));
            spread_2 = _S1240;
        }
        else
        {
            spread_2 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
        }
        if(replay_2)
        {
            turned_1 = 4294967295U == _S1220;
        }
        else
        {
            turned_1 = false;
        }
        if(turned_1)
        {
            turned_1 = _S1209 == 1U;
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
            ended_0 = _S1205;
            sky_pdf_0 = 0.0f;
            spread_2 = _S1226;
            width_3 = _S1227;
            density_2 = 1.0f;
            throughput_2 = throughput_3;
            b_10 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S1241 = (&prev_0)->rough;
        if(_S1241)
        {
            turned_1 = !(spread_2 > 0.0f);
        }
        else
        {
            turned_1 = false;
        }
        (&prev_0)->rough = turned_1;
        uint _S1242 = stream(_S1232, 384U);
        uint tracking_0 = _S1242;
        weight_1 = throughput_3;
        glowed_0 = _S1204;
        b_10 = 4294967295U;
        throughput_2 = throughput_3;
        density_2 = 1.0f;
        threshold_2 = _S1226;
        width_3 = _S1227;
        sky_pdf_0 = 0.0f;
        for(;;)
        {
            if(((&hit_4)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S1203 = int(1);
                break;
            }
            uint _S1243 = b_10 + 320U;
            bool _S1244 = b_10 == 4294967295U;
            uint _S1245 = _slang_select(_S1244, 384U,_S1243);
            uint _S1246 = stream(_S1232, _S1245);
            Random _S1247 = pcg(_S1246);
            float _S1248 = freeFlight_0(_S1247.value, spread_2);
            if(passes_0)
            {
                float3  _S1249 = (&ray_2)->origin;
                float3  _S1250 = (&ray_2)->unit_direction;
                float _S1251 = (&hit_4)->distance;
                uint _S1252 = _slang_select(_S1244, 0U,b_10);
                uint _S1253 = (&prev_0)->lobe;
                uint _S1254 = _slang_select(_S1244, 3U,_S1253);
                float _S1255 = (fcptTrackMedium((_S1238), (_S1249), (_S1250), (_S1251), (&tracking_0), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1252), (_S1254), (_S1244)));
                geometry_density_2 = _S1255;
            }
            else
            {
                geometry_density_2 = _S1248;
            }
            bool _S1256 = !(geometry_density_2 < ((&hit_4)->distance));
            if(_S1256)
            {
                _S1203 = int(1);
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
                float3  _S1257 = throughput_2 * glowed_0 / make_float3 (density_2);
                float3  _S1258 = sel_7->glow + _S1257;
                sel_7->glow = _S1258;
            }
            else
            {
            }
            glowed_0 = _S1204;
            uint b_12 = b_10 + 1U;
            float3  _S1259 = (&ray_2)->origin + make_float3 (geometry_density_2) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S1259;
            float3  _S1260 = flightWeight_0(scatter_in_0, extinction_in_0, spread_2, geometry_density_2, true);
            float3  _S1261 = weight_1;
            float3  _S1262 = _slang_select(passes_0, _S1261,_S1260);
            float3  throughput_4 = throughput_2 * _S1262;
            uint _S1263 = stream(_S1232, b_12 + 320U);
            tracking_0 = _S1263;
            weight_1 = throughput_3;
            float width_6 = width_3 + threshold_2 * geometry_density_2;
            float _S1264 = threshold_2 + 3.14159274101257324f;
            bool _S1265 = scatterSampled_0(replay_2, b_12, _S1220, passes_0);
            TreeSample _S1266 = TreeSample_x24init_0(_S1204, _S1204, 0.0f, 0U);
            if(_S1265)
            {
                float3  _S1267 = (&ray_2)->origin;
                float3  _S1268 = (&ray_2)->unit_direction;
                float3  _S1269 = (&ray_2)->unit_direction;
                uint _S1270 = stream(_S1232, b_12 + 64U);
                float3  _S1271 = extinction_in_0;
                float3  _S1272 = extinction_in_0;
                uint2  _S1273 = make_uint2 (_S1238);
                float3  _S1274 = (&ray_2)->unit_direction;
                uint _S1275 = arrivalLobe_0(b_12, (&prev_0)->lobe);
                FKHit _S1276 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S1277 = _S1276;
                ShadowContext _S1278 = ShadowContext_x24init_0(_S1271, _S1272, _S1273, _S1274, b_12, _S1275, false, geometry_density_2, width_6, &_S1277, false);
                ShadowContext _S1279 = _S1278;
                TreeSample _S1280 = sampleLightTree_0(_S1267, _S1268, _S1269, 0.0f, true, _S1270, &_S1279);
                light_3 = _S1280;
            }
            else
            {
                light_3 = _S1266;
            }
            float _S1281 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_3.dir));
            uint _S1282 = (fcptMaxBounces());
            bool _S1283 = b_12 < _S1282;
            if(_S1283)
            {
                is_inside_5 = (light_3.density) > 0.0f;
            }
            else
            {
                is_inside_5 = false;
            }
            float _S1284 = _slang_select(is_inside_5, _S1281,0.0f);
            float3  _S1285 = throughput_4 * light_3.radiance;
            float _S1286 = powerHeuristic(light_3.density, _S1284);
            float3  _S1287 = _S1285 * make_float3 (_S1281 * _S1286);
            float3  _S1288 = _slang_select(_S1265, _S1287,_S1204);
            if(replay_2)
            {
                viewed_0 = b_12 == _S1220;
            }
            else
            {
                viewed_0 = false;
            }
            if(viewed_0)
            {
                bool _S1289 = _S1209 == 2U;
                if(_S1289)
                {
                    float _S1290 = rgb_to_greyscale(_S1288);
                    passes_0 = _S1290 > 0.0f;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S1291 = Shift_x24init_0(_S1288, 1.0f);
                    _S1203 = int(0);
                    ended_0 = _S1291;
                    spread_2 = _S1264;
                    geometry_density_2 = width_6;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_12;
                    break;
                }
                _S1203 = int(0);
                ended_0 = _S1205;
                spread_2 = _S1264;
                geometry_density_2 = width_6;
                chain_throughput_0 = throughput_4;
                layer_0 = b_12;
                break;
            }
            bool _S1292 = !replay_2;
            if(_S1292)
            {
                Reservoir candidate_3 = _S1237;
                uint _S1293 = extractBits_0(_S1237.path, 10U, 2U);
                bool _S1294 = _S1293 == 1U;
                if(_S1294)
                {
                    float3  _S1295 = safeDivide(_S1288, _S1204);
                    (&candidate_3)->radiance = _S1295;
                }
                else
                {
                    uint _S1296 = insertBits_0(0U, b_12 + 1U, 5U, 5U);
                    uint _S1297 = insertBits_0(_S1296, 2U, 10U, 2U);
                    (&candidate_3)->path = _S1297;
                }
                Reservoir _S1298 = withEnd(candidate_3, 0U, b_12, _S1288);
                offer(sel_7, _S1298, _S1288 * make_float3 (scale_3) / make_float3 (density_2));
                float _S1299 = survivalProbability(throughput_4, density_2);
                uint _S1300 = stream(_S1232, b_12 + 128U);
                Random _S1301 = pcg(_S1300);
                bool _S1302 = _S1299 < (_S1301.value);
                if(_S1302)
                {
                    scatter_2 = true;
                }
                else
                {
                    uint _S1303 = (fcptMaxBounces());
                    scatter_2 = b_12 >= _S1303;
                }
                if(scatter_2)
                {
                    _S1203 = int(0);
                    ended_0 = _S1205;
                    spread_2 = _S1264;
                    geometry_density_2 = width_6;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_12;
                    break;
                }
                float _S1304 = density_2 * _S1299;
                density_2 = _S1304;
            }
            else
            {
            }
            float phase_pdf_0 = 0.0f;
            uint _S1305 = stream(_S1232, b_12);
            float3  _S1306 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1305, &phase_pdf_0);
            (&ray_2)->unit_direction = _S1306;
            NEEVertex _S1307 = NEEVertex_x24init_0(false, phase_pdf_0, (&ray_2)->origin, _S1204, (&ray_2)->origin);
            nee_vertex_0 = _S1307;
            Vertex _S1308 = scatteredVertex_0(false);
            prev_0 = _S1308;
            float _S1309 = (&prev_0)->pdf;
            FKRay _S1310 = ray_2;
            FKHit _S1311 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S1312 = (fcptTraverseInstanceBVH((_S1310), (true), (4.294967296e+09f), (false), (_S1311), (false)));
            hit_4 = _S1312;
            b_10 = b_12;
            throughput_2 = throughput_4;
            threshold_2 = _S1264;
            width_3 = width_6;
            sky_pdf_0 = _S1309;
        }
        if(_S1203 != int(1))
        {
            width_3 = geometry_density_2;
            throughput_2 = chain_throughput_0;
            b_10 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S1205;
        spread_2 = threshold_2;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    bool _S1313 = b_10 == 4294967295U;
    bool _S1314 = ((&hit_4)->instance_index) == 4294967295U;
    if(_S1314)
    {
        bool _S1315 = !(&nee_vertex_0)->none;
        float _S1316 = _slang_select(_S1315, sky_pdf_0,0.0f);
        float _S1317 = escapeWeight_0(_S1316, (&ray_2)->unit_direction);
        float3  _S1318 = environment_0((&ray_2)->unit_direction, b_10, (&prev_0)->lobe);
        float3  _S1319 = throughput_2 * _S1318;
        if(replay_2)
        {
            bool _S1320 = b_10 == _S1220;
            if(_S1320)
            {
                passes_0 = _S1209 == 3U;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                return Shift_x24init_0(_S1319 * make_float3 (_S1317) / make_float3 (r_8->jac), density_2 / r_8->jac);
            }
            if(_S1219)
            {
                passes_0 = _S1216;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                passes_0 = b_10 == _S1207;
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
                return Shift_x24init_0(_S1319 * make_float3 (_S1317), 1.0f);
            }
            return _S1205;
        }
        Reservoir candidate_4 = chain_0;
        uint _S1321 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1322 = _S1321 == 1U;
        if(_S1322)
        {
            uint _S1323 = extractBits_0((&chain_0)->path, 5U, 5U);
            bool _S1324 = _S1323 == b_10;
            float _S1325 = _slang_select(_S1324, 1.0f,_S1317);
            float3  _S1326 = safeDivide(_S1319 * make_float3 (_S1325), _S1204);
            (&candidate_4)->radiance = _S1326;
        }
        else
        {
            bool _S1327 = (&prev_0)->rough;
            if(_S1327)
            {
                uint _S1328 = insertBits_0(0U, b_10 + 1U, 5U, 5U);
                uint _S1329 = insertBits_0(_S1328, 3U, 10U, 2U);
                uint _S1330 = insertBits_0(_S1329, (&prev_0)->lobe, 15U, 3U);
                bool _S1331 = (&prev_0)->inside;
                uint _S1332 = _slang_select(_S1331, 1U,0U);
                uint _S1333 = insertBits_0(_S1330, _S1332, 22U, 1U);
                (&candidate_4)->path = _S1333;
                (&candidate_4)->jac = (&prev_0)->pdf;
                (&candidate_4)->dir = (&ray_2)->unit_direction;
            }
        }
        float3  _S1334 = _S1319 * make_float3 (_S1317);
        Reservoir _S1335 = withEnd(candidate_4, 3U, b_10, _S1334);
        offer(sel_7, _S1335, _S1334 * make_float3 (scale_3) / make_float3 (density_2));
        return _S1205;
    }
    float3  _S1336 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
    (&ray_2)->origin = _S1336;
    bool _S1337 = (fcptVaryingUsed());
    if(_S1337)
    {
        passes_0 = filling_2 != 4294967295U;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        bool _S1338 = !replay_2;
        if(_S1338)
        {
            float3  _S1339 = throughput_2 * glowed_0 / make_float3 (density_2);
            float3  _S1340 = sel_7->glow + _S1339;
            sel_7->glow = _S1340;
        }
        float3  _S1341 = throughput_2 * weight_1;
        throughput_2 = _S1341;
    }
    else
    {
        float3  _S1342 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
        float3  _S1343 = throughput_2 * _S1342;
        throughput_2 = _S1343;
    }
    float _S1344 = width_3 + spread_2 * (&hit_4)->distance;
    uint _S1345 = b_10 + 1U;
    b_10 = _S1345;
    layer_0 = 0U;
    width_3 = _S1344;
    passes_0 = false;
    threshold_2 = 0.0f;
    turned_1 = false;
    is_inside_5 = false;
    chain_throughput_0 = _S1204;
    float3  reconnection_0 = _S1204;
    viewed_0 = _S1313;
    for(;;)
    {
        bool _S1346 = ((&hit_4)->is_point_light) == 1U;
        FKMedium _S1347 = Medium_x24init_0(_S1204, _S1204, 0.0f);
        BSDFMaterial _S1348 = Material_x24init_0(_S1204, _S1204, 0.0f, 0.0f, 0.0f, 0.0f, _S1204, throughput_3, 1.0f, _S1204, _S1204, 0.5f, 0.0f, 0.0f, _S1204, 0.0f, _S1204);
        FKMedium _S1349 = _S1347;
        FKSurface _S1350 = Surface_x24init_0(_S1204, _S1204, 0.0f, &_S1348, false, 0U, 1.0f, false, &_S1349, 4294967295U, _S1204);
        bool _S1351 = !_S1346;
        bool is_inside_6;
        float3  throughput_5;
        FKSurface surface_11;
        if(_S1351)
        {
            uint _S1352 = stream(_S1232, b_10);
            uint _S1353 = arrivalLobe_0(b_10, (&prev_0)->lobe);
            FKSurface _S1354 = (fcptSurfaceAtPath((hit_4), ((&ray_2)->origin), (_S1352), (width_3), (layer_0), (b_10), (_S1353), ((&ray_2)->unit_direction)));
            bool _S1355 = !passes_0;
            FKSurface _S1356 = _S1354;
            FKSurface _S1357 = emitting_0(&_S1356, _S1355);
            uint _S1358 = stream(_S1232, b_10 + 256U);
            Random _S1359 = pcg(_S1358);
            FKSurface _S1360 = _S1357;
            FKSurface _S1361 = uncovered_0(&_S1360, _S1359.value);
            float _S1362 = facingSign(_S1361.material.transmission, _S1361.geometry_n, (&ray_2)->unit_direction);
            bool _S1363 = _S1362 < 0.0f;
            bool _S1364 = (_S1361.material.transmission) > 0.0f;
            if(_S1364)
            {
                bool _S1365 = arrivesBehind_0((&ray_2)->unit_direction, _S1361.geometry_n);
                scatter_2 = _S1365;
            }
            else
            {
                scatter_2 = false;
            }
            FKSurface _S1366 = _S1361;
            FKSurface _S1367 = facingRay_0(&_S1366, (&ray_2)->unit_direction);
            if(passes_0)
            {
                bool _S1368 = arrivesBehind_0((&ray_2)->unit_direction, _S1367.geometry_n);
                is_inside_6 = _S1368;
            }
            else
            {
                is_inside_6 = scatter_2;
            }
            if(is_inside_6)
            {
                float3  _S1369 = beerLambert((&hit_4)->distance, _S1367.material.absorption);
                float3  _S1370 = throughput_2 * _S1369;
                throughput_5 = _S1370;
            }
            else
            {
                throughput_5 = throughput_2;
            }
            bool _S1371 = !_S1367.skip;
            float geometry_density_3 = geometryDensity(_S1367.geometry_n, (&ray_2)->unit_direction, (&hit_4)->distance);
            bool _S1372 = b_10 == _S1345;
            if(_S1372)
            {
                float _S1373 = footprintThreshold(geometry_density_3);
                geometry_density_2 = _S1373;
            }
            else
            {
                geometry_density_2 = threshold_2;
            }
            float _S1374 = geometry_density_2;
            scatter_2 = _S1371;
            geometry_density_2 = geometry_density_3;
            threshold_2 = _S1374;
            surface_11 = _S1367;
            turned_1 = _S1363;
        }
        else
        {
            scatter_2 = false;
            geometry_density_2 = 0.0f;
            surface_11 = _S1350;
            throughput_5 = throughput_2;
            is_inside_6 = is_inside_5;
        }
        bool _S1375 = withinFootprint(scatter_2, (&prev_0)->rough, (&prev_0)->pdf, geometry_density_2, threshold_2);
        FKSurface _S1376 = surface_11;
        FKSurface _S1377 = surface_11;
        float _S1378 = dot_0(surface_11.smooth_n, - (&ray_2)->unit_direction);
        float2  _S1379 = vertexEta(_S1376.material, _S1378);
        bool _S1380;
        if(scatter_2)
        {
            bool _S1381 = neeDecision(_S1376.material, _S1378, _S1379.x, _S1379.y);
            _S1380 = _S1381;
        }
        else
        {
            _S1380 = false;
        }
        bool _S1382;
        if(passes_0)
        {
            _S1382 = true;
        }
        else
        {
            _S1382 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S1382)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S1380;
        }
        bool _S1383 = (fcptHairUsed());
        bool _S1384;
        if(_S1383)
        {
            float3  _S1385 = surface_11.hair;
            _S1384 = (dot_0(_S1385, _S1385)) > 0.0f;
        }
        else
        {
            _S1384 = false;
        }
        bool _S1386;
        if(_S1384)
        {
            _S1386 = true;
        }
        else
        {
            BSDFMaterial _S1387 = _S1376.material;
            bool _S1388 = isTranslucent_0(&_S1387);
            _S1386 = _S1388;
        }
        bool _S1389;
        if(_S1386)
        {
            _S1389 = true;
        }
        else
        {
            bool _S1390 = (_S1376.material.transmission) > 0.0f;
            if(_S1390)
            {
                uint _S1391 = (fcptLayers((hit_4)));
                _S1389 = _S1391 == 1U;
            }
            else
            {
                _S1389 = false;
            }
        }
        float3  emission_0;
        if(_S1346)
        {
            float3  _S1392 = (fcptCalculatePointLightContrib(((&hit_4)->instance_index)));
            emission_0 = _S1392;
        }
        else
        {
            emission_0 = _S1376.material.emissive;
        }
        float _S1393 = rgb_to_greyscale(emission_0);
        bool _S1394 = _S1393 > 0.0f;
        float3  emission_1;
        if(_S1394)
        {
            NEEVertex _S1395 = nee_vertex_0;
            FKHit _S1396 = hit_4;
            float _S1397 = emissionWeight_0(&_S1395, &_S1396, (&ray_2)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S1397);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S1398;
        if(replay_2)
        {
            _S1398 = _S1209 == 1U;
        }
        else
        {
            _S1398 = false;
        }
        bool _S1399;
        if(_S1398)
        {
            _S1399 = b_10 > _S1208;
        }
        else
        {
            _S1399 = false;
        }
        bool _S1400;
        if(_S1399)
        {
            _S1400 = b_10 == _S1207;
        }
        else
        {
            _S1400 = false;
        }
        bool _S1401;
        if(_S1400)
        {
            bool _S1402 = _S1210 == 1U;
            if(_S1402)
            {
                _S1401 = true;
            }
            else
            {
                _S1401 = _S1210 == 2U;
            }
        }
        else
        {
            _S1401 = false;
        }
        if(_S1401)
        {
            bool _S1403 = _S1346 != (_S1210 == 2U);
            if(_S1403)
            {
                return _S1205;
            }
            return Shift_x24init_0(throughput_5 * emission_1 / make_float3 (r_8->jac), density_2 / r_8->jac);
        }
        uint _S1404 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1405 = _S1404 == 1U;
        Reservoir here_0 = chain_0;
        uint _S1406 = insertBits_0(0U, b_10, 5U, 5U);
        uint _S1407 = insertBits_0(_S1406, 1U, 10U, 2U);
        uint _S1408 = insertBits_0(_S1407, (&prev_0)->lobe, 15U, 3U);
        bool _S1409 = (&prev_0)->inside;
        uint _S1410 = _slang_select(_S1409, 1U,0U);
        uint _S1411 = insertBits_0(_S1408, _S1410, 22U, 1U);
        (&here_0)->path = _S1411;
        float _S1412 = (&prev_0)->pdf * geometry_density_2;
        (&here_0)->jac = _S1412;
        fcptWithReservoirHit((&here_0), (&hit_4));
        bool _S1413;
        if(replay_2)
        {
            _S1413 = _S1209 == 1U;
        }
        else
        {
            _S1413 = false;
        }
        bool _S1414;
        if(_S1413)
        {
            _S1414 = b_10 == _S1208;
        }
        else
        {
            _S1414 = false;
        }
        bool _S1415 = b_10 == _S1220;
        bool _S1416;
        if(_S1415)
        {
            bool _S1417 = !scatter_2;
            if(_S1417)
            {
                _S1416 = true;
            }
            else
            {
                bool _S1418 = _S1209 != 1U;
                if(_S1418)
                {
                    _S1416 = _S1209 != 3U;
                }
                else
                {
                    _S1416 = false;
                }
            }
        }
        else
        {
            _S1416 = false;
        }
        bool _S1419;
        if(_S1416)
        {
            _S1419 = _S1209 == 2U;
        }
        else
        {
            _S1419 = false;
        }
        bool _S1420;
        if(_S1419)
        {
            _S1420 = !_S1375;
        }
        else
        {
            _S1420 = false;
        }
        bool _S1421;
        if(_S1420)
        {
            _S1421 = _S1210 != 4U;
        }
        else
        {
            _S1421 = false;
        }
        bool _S1422 = _S1208 == _S1207;
        bool _S1423;
        if(_S1422)
        {
            _S1423 = _S1210 == 0U;
        }
        else
        {
            _S1423 = false;
        }
        bool _S1424;
        if(_S1423)
        {
            _S1424 = ((&hit_4)->instance_index) == (_S1221.instance_index);
        }
        else
        {
            _S1424 = false;
        }
        bool _S1425;
        if(_S1424)
        {
            _S1425 = ((&hit_4)->triangle_index) == (_S1221.triangle_index);
        }
        else
        {
            _S1425 = false;
        }
        bool _S1426;
        if(_S1425)
        {
            _S1426 = _S1375;
        }
        else
        {
            _S1426 = false;
        }
        bool _S1427 = _slang_select(_S1414, _S1426,_S1421);
        bool _S1428;
        if(nee_0)
        {
            _S1428 = _slang_select(replay_2, _S1427,scatter_2);
        }
        else
        {
            _S1428 = false;
        }
        TreeSample _S1429 = TreeSample_x24init_0(_S1204, _S1204, 0.0f, 0U);
        uint2  _S1430 = make_uint2 (0U);
        float2  _S1431 = make_float2 (0.0f);
        FKHit _S1432 = Hit_x24init_0(_S1431, 4294967295U, 0U, 0U, 0.0f);
        FKHit _S1433 = _S1432;
        ShadowContext _S1434 = ShadowContext_x24init_0(_S1204, _S1204, _S1430, _S1204, 0U, 0U, false, 0.0f, 0.0f, &_S1433, false);
        ShadowContext context_5;
        if(nee_0)
        {
            uint _S1435 = arrivalLobe_0(b_10, (&prev_0)->lobe);
            FKMedium _S1436 = (fcptOutsideMedium((hit_4)));
            FKSurface _S1437 = surface_11;
            FKHit _S1438 = hit_4;
            FKMedium _S1439 = _S1436;
            ShadowContext _S1440 = shadowContext_0(&_S1437, turned_1, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_10, _S1435, (&hit_4)->distance, width_3, &_S1438, _S1384, &_S1439);
            context_5 = _S1440;
        }
        else
        {
            context_5 = _S1434;
        }
        float3  throughput_6;
        float3  lit_0;
        if(_S1428)
        {
            float3  _S1441 = (&ray_2)->origin;
            if(_S1384)
            {
                throughput_6 = _S1204;
            }
            else
            {
                throughput_6 = _S1377.smooth_n;
            }
            FKSurface _S1442 = surface_11;
            uint _S1443 = stream(_S1232, b_10 + 64U);
            ShadowContext _S1444 = context_5;
            TreeSample _S1445 = sampleLightTree_0(_S1441, throughput_6, surface_11.geometry_n, surface_11.geometry_offset, _S1389, _S1443, &_S1444);
            bool _S1446 = any_1((_S1445.radiance) != _S1204);
            if(_S1446)
            {
                if(_S1384)
                {
                    uint _S1447 = (fcptMaxBounces());
                    bool _S1448 = b_10 < _S1447;
                    FKSurface _S1449 = surface_11;
                    TreeSample _S1450 = _S1445;
                    float3  _S1451 = hairLight_0(&_S1449, (&ray_2)->unit_direction, &_S1450, _S1448);
                    lit_0 = _S1451;
                }
                else
                {
                    float _S1452 = _S1379.x;
                    float _S1453 = _S1379.y;
                    uint _S1454 = (fcptMaxBounces());
                    bool _S1455 = b_10 < _S1454;
                    TreeSample _S1456 = _S1445;
                    BSDFMaterial _S1457 = _S1376.material;
                    float3  _S1458 = lightBSDF_0((&ray_2)->unit_direction, &_S1456, _S1377.smooth_n, _S1442.geometry_n, &_S1457, _S1452, _S1453, _S1455, surface_11.random_state);
                    lit_0 = _S1458;
                }
            }
            else
            {
                lit_0 = _S1204;
            }
            light_3 = _S1445;
        }
        else
        {
            light_3 = _S1429;
            lit_0 = _S1204;
        }
        bool viewed_1;
        bool refracted_4;
        bool wrong_side_0;
        bool _S1459;
        bool _S1460;
        float density_4;
        if(_S1414)
        {
            bool _S1461 = ((&hit_4)->instance_index) != (_S1221.instance_index);
            if(_S1461)
            {
                viewed_1 = true;
            }
            else
            {
                viewed_1 = ((&hit_4)->triangle_index) != (_S1221.triangle_index);
            }
            if(viewed_1)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = !_S1375;
            }
            if(refracted_4)
            {
                return _S1205;
            }
            float3  throughput_7 = throughput_5 * make_float3 (geometry_density_2);
            float density_5 = density_2 * geometry_density_2;
            if(_S1422)
            {
                wrong_side_0 = _S1210 == 1U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                return Shift_x24init_0(throughput_7 * emission_1 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1422)
            {
                _S1459 = _S1210 == 0U;
            }
            else
            {
                _S1459 = false;
            }
            if(_S1459)
            {
                bool _S1462 = !nee_0;
                if(_S1462)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S1463 = rgb_to_greyscale(light_3.radiance);
                    passes_0 = !(_S1463 > 0.0f);
                }
                if(passes_0)
                {
                    return _S1205;
                }
                return Shift_x24init_0(throughput_7 * lit_0 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1422)
            {
                _S1460 = _S1210 == 4U;
            }
            else
            {
                _S1460 = false;
            }
            if(_S1460)
            {
                bool _S1464 = !nee_0;
                if(_S1464)
                {
                    return _S1205;
                }
                float _S1465 = environmentPdf_0(r_8->dir);
                float3  _S1466 = skyBSDF((&ray_2)->unit_direction, r_8->dir, surface_11, _S1379, is_inside_6, _S1465, surface_11.random_state);
                return Shift_x24init_0(throughput_7 * _S1466 * r_8->radiance / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            uint _S1467 = extractBits_0(_S1206, 21U, 1U);
            bool _S1468 = nee_0 != (_S1467 == 1U);
            if(_S1468)
            {
                return _S1205;
            }
            throughput_6 = throughput_7;
            density_4 = density_5;
        }
        else
        {
            if(replay_2)
            {
                viewed_1 = _S1415;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                bool _S1469 = !scatter_2;
                if(_S1469)
                {
                    refracted_4 = true;
                }
                else
                {
                    bool _S1470 = _S1209 != 1U;
                    if(_S1470)
                    {
                        refracted_4 = _S1209 != 3U;
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
                bool _S1471 = _S1209 == 2U;
                if(_S1471)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1375;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1210 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    if(_S1384)
                    {
                        return _S1205;
                    }
                    uint _S1472 = stream(_S1232, b_10 + 448U);
                    FKRay _S1473 = ray_2;
                    FKSurface _S1474 = surface_11;
                    ShadowContext _S1475 = context_5;
                    SkySample _S1476 = sampleSky_0(&_S1473, &_S1474, _S1379, is_inside_6, _S1472, surface_11.random_state, &_S1475);
                    return Shift_x24init_0(throughput_5 * _S1476.color, 1.0f);
                }
                if(_S1471)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1375;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float _S1477 = rgb_to_greyscale(light_3.radiance);
                    bool _S1478 = !(_S1477 > 0.0f);
                    if(_S1478)
                    {
                        return _S1205;
                    }
                    return Shift_x24init_0(throughput_5 * lit_0, 1.0f);
                }
                if(_S1219)
                {
                    passes_0 = _S1210 == 2U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1346;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_5 * emission_1, 1.0f);
                }
                if(_S1219)
                {
                    passes_0 = _S1210 == 1U;
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
                    passes_0 = !_S1375;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_5 * emission_1, 1.0f);
                }
                return _S1205;
            }
            else
            {
                bool _S1479 = !replay_2;
                if(_S1479)
                {
                    wrong_side_0 = scatter_2;
                }
                else
                {
                    wrong_side_0 = false;
                }
                if(wrong_side_0)
                {
                    bool _S1480 = b_10 > 0U;
                    if(_S1480)
                    {
                        Reservoir candidate_5 = chain_0;
                        if(_S1405)
                        {
                            float3  _S1481 = safeDivide(throughput_5 * emission_1, chain_throughput_0);
                            (&candidate_5)->radiance = _S1481;
                        }
                        else
                        {
                            if(_S1375)
                            {
                                candidate_5 = here_0;
                            }
                        }
                        float3  _S1482 = throughput_5 * emission_1;
                        Reservoir _S1483 = withEnd(candidate_5, 1U, b_10, _S1482);
                        offer(sel_7, _S1483, _S1482 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    else
                    {
                        float3  _S1484 = throughput_5 * emission_1;
                        float3  _S1485 = sel_7->glow + _S1484;
                        sel_7->glow = _S1485;
                    }
                    if(nee_0)
                    {
                        float3  _S1486 = throughput_5 * lit_0;
                        Reservoir candidate_6 = chain_0;
                        if(_S1405)
                        {
                            float3  _S1487 = safeDivide(_S1486, chain_throughput_0);
                            (&candidate_6)->radiance = _S1487;
                        }
                        else
                        {
                            if(_S1375)
                            {
                                candidate_6 = here_0;
                                uint _S1488 = insertBits_0((&candidate_6)->path, 1U, 21U, 1U);
                                (&candidate_6)->path = _S1488;
                                (&candidate_6)->dir = light_3.dir;
                                (&candidate_6)->radiance = light_3.radiance;
                            }
                            else
                            {
                                uint _S1489 = insertBits_0(0U, b_10 + 1U, 5U, 5U);
                                uint _S1490 = insertBits_0(_S1489, 2U, 10U, 2U);
                                (&candidate_6)->path = _S1490;
                            }
                        }
                        Reservoir _S1491 = withEnd(candidate_6, 0U, b_10, _S1486);
                        offer(sel_7, _S1491, _S1486 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    if(nee_0)
                    {
                        if(_S1384)
                        {
                            _S1459 = false;
                        }
                        else
                        {
                            bool _S1492 = environmentMapped_0();
                            _S1459 = _S1492;
                        }
                    }
                    else
                    {
                        _S1459 = false;
                    }
                    if(_S1459)
                    {
                        uint _S1493 = (fcptMaxBounces());
                        _S1460 = b_10 < _S1493;
                    }
                    else
                    {
                        _S1460 = false;
                    }
                    if(_S1460)
                    {
                        uint _S1494 = stream(_S1232, b_10 + 448U);
                        FKRay _S1495 = ray_2;
                        FKSurface _S1496 = surface_11;
                        ShadowContext _S1497 = context_5;
                        SkySample _S1498 = sampleSky_0(&_S1495, &_S1496, _S1379, is_inside_6, _S1494, surface_11.random_state, &_S1497);
                        float3  _S1499 = throughput_5 * _S1498.color;
                        Reservoir candidate_7 = chain_0;
                        if(_S1405)
                        {
                            float3  _S1500 = safeDivide(_S1499, chain_throughput_0);
                            (&candidate_7)->radiance = _S1500;
                        }
                        else
                        {
                            if(_S1375)
                            {
                                candidate_7 = here_0;
                                uint _S1501 = insertBits_0((&candidate_7)->path, 1U, 21U, 1U);
                                (&candidate_7)->path = _S1501;
                                (&candidate_7)->dir = _S1498.dir;
                                (&candidate_7)->radiance = _S1498.radiance;
                            }
                            else
                            {
                                uint _S1502 = insertBits_0(0U, b_10 + 1U, 5U, 5U);
                                uint _S1503 = insertBits_0(_S1502, 2U, 10U, 2U);
                                (&candidate_7)->path = _S1503;
                            }
                        }
                        Reservoir _S1504 = withEnd(candidate_7, 4U, b_10, _S1499);
                        offer(sel_7, _S1504, _S1499 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                }
            }
            throughput_6 = throughput_5;
            density_4 = density_2;
        }
        bool _S1505;
        bool _S1506;
        bool straight_0;
        bool _S1507;
        bool _S1508;
        bool _S1509;
        bool _S1510;
        bool _S1511;
        bool _S1512;
        bool _S1513;
        bool _S1514;
        bool _S1515;
        bool _S1516;
        bool _S1517;
        bool _S1518;
        bool _S1519;
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
                viewed_1 = _S1415;
            }
            else
            {
                viewed_1 = false;
            }
            uint _S1520 = extractBits_0(_S1206, 15U, 3U);
            uint _S1521 = extractBits_0(_S1206, 18U, 3U);
            uint _S1522 = _slang_select(_S1414, _S1521,_S1520);
            float3  _S1523 = r_8->dir;
            bool refracted_5 = _S1522 == 1U;
            SampleBSDF _S1524 = SampleBSDF_x24init_0(_S1204, _S1204, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_11 = _S1524;
            float3  reconnection_1;
            SampleBSDF _S1525;
            if(viewed_1)
            {
                uint _S1526 = extractBits_0(_S1206, 22U, 1U);
                bool _S1527 = is_inside_6 != (_S1526 == 1U);
                if(_S1527)
                {
                    return _S1205;
                }
                bool _S1528 = _S1209 == 1U;
                if(_S1528)
                {
                    float3  _S1529 = (fcptHitPosition((_S1221)));
                    throughput_8 = _S1529;
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
                    BSDFMaterial _S1530 = _S1376.material;
                    bool _S1531 = isTranslucent_0(&_S1530);
                    if(_S1531)
                    {
                        refracted_4 = _S1522 == 0U;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                    if(refracted_4)
                    {
                        float3  _S1532 = throughput_8 - (&ray_2)->origin;
                        float3  _S1533 = _slang_select(_S1528, _S1532,_S1523);
                        wrong_side_0 = (dot_0(_S1377.smooth_n, _S1533) * _S1378) < 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    refracted_4 = wrong_side_0;
                }
                if(_S1528)
                {
                    float3  _S1534 = (&ray_2)->origin;
                    FKSurface _S1535 = surface_11;
                    float3  _S1536 = - _S1377.smooth_n;
                    bool _S1537 = is_inside_6 != refracted_4;
                    float3  _S1538 = _slang_select(_S1537, _S1536,_S1377.smooth_n);
                    float3  _S1539 = throughput_8 - (_S1534 + make_float3 (_S1535.geometry_offset) * _S1538);
                    float3  _S1540 = ((((_S1539)) * make_float3(rnorm3df(((_S1539)).x, ((_S1539)).y, ((_S1539)).z))));
                    reconnection_1 = _S1540;
                }
                else
                {
                    reconnection_1 = _S1523;
                }
                if(_S1384)
                {
                    wrong_side_0 = false;
                }
                else
                {
                    bool _S1541 = wrongSide_0(is_inside_6, refracted_4, reconnection_1, surface_11.geometry_n);
                    wrong_side_0 = _S1541;
                }
                if(wrong_side_0)
                {
                    return _S1205;
                }
                float3  _S1542 = throughput_8;
                throughput_8 = reconnection_1;
                b_13 = _S1522;
                wrong_side_0 = false;
                reconnection_1 = _S1542;
            }
            else
            {
                bool _S1543 = !_S1414;
                if(_S1543)
                {
                    SampleBSDF bsdf_sampled_0;
                    if(_S1384)
                    {
                        SampleBSDF _S1544 = (fcptSampleHair((surface_11.hair), (_S1376.material.albedo), (_S1376.material.specular_tint), ((&ray_2)->unit_direction), (surface_11.random_state)));
                        _S1525 = _S1544;
                    }
                    else
                    {
                        SampleBSDF _S1545 = sampleBSDF((&ray_2)->unit_direction, _S1377.smooth_n, _S1376.material, _S1379.x, _S1379.y, surface_11.random_state, _S1431);
                        _S1525 = _S1545;
                    }
                    bsdf_sampled_0 = _S1525;
                    if(_S1384)
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
                            return _S1205;
                        }
                        break;
                    }
                    if(_S1384)
                    {
                        wrong_side_0 = false;
                    }
                    else
                    {
                        bool _S1546 = wrongSide_0(is_inside_6, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, surface_11.geometry_n);
                        wrong_side_0 = _S1546;
                    }
                    if(wrong_side_0)
                    {
                        _S1459 = (_S1376.material.transmission) > 0.0f;
                    }
                    else
                    {
                        _S1459 = false;
                    }
                    if(_S1459)
                    {
                        SampleBSDF _S1547 = sampleBSDF((&bsdf_sampled_0)->unit_direction, surface_11.geometry_n, _S1376.material, _S1379.x, _S1379.y, (&bsdf_sampled_0)->random_state, _S1431);
                        (&bsdf_sampled_0)->unit_direction = _S1547.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1547.refracted;
                        (&bsdf_sampled_0)->throughput = _S1547.throughput;
                    }
                    else
                    {
                        if(wrong_side_0)
                        {
                            float3  _S1548 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, surface_11.geometry_n)) * surface_11.geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1548;
                        }
                    }
                    uint _S1549 = (&bsdf_sampled_0)->lobe;
                    float3  _S1550 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1551 = (&bsdf_sampled_0)->refracted;
                    lobe_11 = bsdf_sampled_0;
                    float _S1552 = (&bsdf_sampled_0)->pdf;
                    float _S1553 = _slang_select(wrong_side_0, 0.0f,_S1552);
                    (&lobe_11)->pdf = _S1553;
                    throughput_8 = _S1550;
                    b_13 = _S1549;
                    refracted_4 = _S1551;
                }
                else
                {
                    throughput_8 = _S1523;
                    b_13 = _S1522;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(viewed_1)
            {
                _S1459 = true;
            }
            else
            {
                _S1459 = _S1414;
            }
            if(_S1459)
            {
                if(_S1384)
                {
                    SampleBSDF _S1554 = (fcptConnectHair((surface_11.hair), (_S1376.material.albedo), (_S1376.material.specular_tint), ((&ray_2)->unit_direction), (throughput_8)));
                    _S1525 = _S1554;
                }
                else
                {
                    SampleBSDF _S1555 = connectBSDF((&ray_2)->unit_direction, throughput_8, _S1377.smooth_n, _S1376.material, _S1379.x, _S1379.y, b_13, surface_11.random_state);
                    _S1525 = _S1555;
                }
                lobe_11 = _S1525;
            }
            bool _S1556 = b_13 == 0U;
            if(_S1556)
            {
                _S1460 = true;
            }
            else
            {
                _S1460 = b_13 == 4U;
            }
            if(_S1384)
            {
                _S1505 = false;
            }
            else
            {
                bool _S1557 = !_S1460;
                if(_S1557)
                {
                    bool _S1558 = (_S1376.material.roughness) == 0.0f;
                    if(_S1558)
                    {
                        _S1505 = true;
                    }
                    else
                    {
                        bool _S1559 = b_13 == 1U;
                        if(_S1559)
                        {
                            _S1505 = (_S1379.x) == (_S1379.y);
                        }
                        else
                        {
                            _S1505 = false;
                        }
                    }
                }
                else
                {
                    _S1505 = false;
                }
            }
            bool _S1560 = !_S1384;
            if(_S1560)
            {
                _S1506 = b_13 == 1U;
            }
            else
            {
                _S1506 = false;
            }
            if(_S1506)
            {
                straight_0 = (_S1376.material.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S1507 = _S1560;
            }
            else
            {
                _S1507 = false;
            }
            if(_S1507)
            {
                _S1508 = b_13 == 1U;
            }
            else
            {
                _S1508 = false;
            }
            if(_S1508)
            {
                _S1509 = (_S1379.x) == (_S1379.y);
            }
            else
            {
                _S1509 = false;
            }
            BSDFMaterial _S1561 = _S1376.material;
            bool _S1562 = isTranslucent_0(&_S1561);
            if(_S1562)
            {
                _S1510 = _S1556;
            }
            else
            {
                _S1510 = false;
            }
            if(_S1510)
            {
                _S1511 = (dot_0(throughput_8, surface_11.geometry_n)) < 0.0f;
            }
            else
            {
                _S1511 = false;
            }
            if(nee_0)
            {
                _S1512 = !_S1505;
            }
            else
            {
                _S1512 = false;
            }
            if(_S1512)
            {
                _S1513 = !wrong_side_0;
            }
            else
            {
                _S1513 = false;
            }
            if(_S1513)
            {
                float _S1563 = (&lobe_11)->pdf;
                float3  _S1564 = (&ray_2)->origin;
                float3  _S1565 = _slang_select(_S1389, _S1204,_S1377.smooth_n);
                float3  _S1566 = (&ray_2)->origin;
                FKSurface _S1567 = surface_11;
                float3  _S1568 = - _S1377.smooth_n;
                float3  _S1569 = _slang_select(_S1511, _S1568,_S1377.smooth_n);
                NEEVertex _S1570 = NEEVertex_x24init_0(false, _S1563, _S1564, _S1565, _S1566 + make_float3 (_S1567.geometry_offset) * _S1569);
                nee_vertex_0 = _S1570;
            }
            else
            {
                if(_S1384)
                {
                    _S1514 = true;
                }
                else
                {
                    bool _S1571 = b_13 != 1U;
                    if(_S1571)
                    {
                        _S1514 = true;
                    }
                    else
                    {
                        _S1514 = (_S1379.x) != (_S1379.y);
                    }
                }
                if(_S1514)
                {
                    (&nee_vertex_0)->none = true;
                }
            }
            bool _S1572 = withinInverseFootprint((&lobe_11)->pdf, _S1460, (&prev_0)->cos, (&hit_4)->distance, threshold_2);
            bool _S1573 = roughLobe((&lobe_11)->pdf, _S1460, _S1376.material.roughness);
            if(_S1414)
            {
                bool _S1574 = !_S1572;
                if(_S1574)
                {
                    return _S1205;
                }
                bool _S1575 = _S1210 != 1U;
                if(_S1575)
                {
                    _S1514 = _S1210 != 2U;
                }
                else
                {
                    _S1514 = false;
                }
                if(_S1514)
                {
                    float _S1576 = (&lobe_11)->pdf;
                    float _S1577 = _slang_select(nee_0, _S1576,0.0f);
                    float _S1578 = escapeWeight_0(_S1577, _S1523);
                    if(_S1422)
                    {
                        passes_0 = _S1216;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1579 = _slang_select(passes_0, _S1578,1.0f);
                    return Shift_x24init_0(throughput_6 * ((&lobe_11)->throughput * make_float3 ((&lobe_11)->pdf)) * r_8->radiance * make_float3 (_S1579) / make_float3 (r_8->jac), density_4 * (&lobe_11)->pdf / r_8->jac);
                }
                float3  _S1580 = throughput_6 * make_float3 ((&lobe_11)->pdf);
                float _S1581 = density_4 * (&lobe_11)->pdf;
                throughput_9 = _S1580;
                density_6 = _S1581;
            }
            else
            {
                throughput_9 = throughput_6;
                density_6 = density_4;
            }
            uint _S1582 = (fcptLayers((hit_4)));
            bool _S1583 = b_13 == 1U;
            bool _S1584 = passesLayer_0(_S1582, _S1583, passes_0);
            if(viewed_1)
            {
                _S1514 = _S1584;
            }
            else
            {
                _S1514 = false;
            }
            if(_S1514)
            {
                return _S1205;
            }
            if(replay_2)
            {
                _S1515 = b_10 <= _S1220;
            }
            else
            {
                _S1515 = false;
            }
            if(_S1515)
            {
                _S1516 = _S1375;
            }
            else
            {
                _S1516 = false;
            }
            if(_S1516)
            {
                _S1517 = _S1572;
            }
            else
            {
                _S1517 = false;
            }
            if(_S1517)
            {
                _S1518 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S1518 = !_S1573;
                }
                else
                {
                    _S1518 = false;
                }
            }
            if(_S1518)
            {
                return _S1205;
            }
            if(viewed_1)
            {
                float3  _S1585 = throughput_9 * ((&lobe_11)->throughput * make_float3 ((&lobe_11)->pdf));
                float _S1586 = (&lobe_11)->pdf;
                throughput_10 = _S1585;
                sky_pdf_2 = _S1586;
            }
            else
            {
                float3  _S1587 = throughput_9 * max_0((&lobe_11)->throughput, _S1204);
                throughput_10 = _S1587;
                sky_pdf_2 = density_6;
            }
            bool _S1588 = !replay_2;
            if(_S1588)
            {
                _S1519 = !_S1405;
            }
            else
            {
                _S1519 = false;
            }
            bool _S1589;
            if(_S1519)
            {
                _S1589 = _S1375;
            }
            else
            {
                _S1589 = false;
            }
            bool _S1590;
            if(_S1589)
            {
                _S1590 = _S1572;
            }
            else
            {
                _S1590 = false;
            }
            float3  chain_throughput_1;
            if(_S1590)
            {
                chain_0 = here_0;
                uint _S1591 = insertBits_0((&chain_0)->path, b_13, 18U, 3U);
                uint _S1592 = _slang_select(nee_0, 1U,0U);
                uint _S1593 = insertBits_0(_S1591, _S1592, 21U, 1U);
                (&chain_0)->path = _S1593;
                float _S1594 = (&chain_0)->jac * (&lobe_11)->pdf;
                (&chain_0)->jac = _S1594;
                (&chain_0)->dir = throughput_8;
                chain_throughput_1 = throughput_10;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            FKSurface _S1595 = surface_11;
            Vertex _S1596 = Vertex_x24init_0(_S1573, b_13, (&lobe_11)->pdf, (F32_abs((dot_0(surface_11.geometry_n, throughput_8)))), is_inside_6);
            prev_0 = _S1596;
            float _S1597 = (&lobe_11)->pdf;
            bool _S1598;
            if(_S1583)
            {
                _S1598 = (_S1379.x) == (_S1379.y);
            }
            else
            {
                _S1598 = false;
            }
            float sky_pdf_3 = _slang_select(_S1598, sky_pdf_0,_S1597);
            float _S1599 = _slang_select(_S1384, 0.0f,sky_pdf_3);
            float _S1600 = widened_0(spread_2, (&lobe_11)->pdf, _S1505);
            bool _S1601;
            if(refracted_4)
            {
                _S1601 = !_S1511;
            }
            else
            {
                _S1601 = false;
            }
            bool is_inside_7;
            if(_S1601)
            {
                bool _S1602 = !is_inside_6;
                is_inside_7 = _S1602;
            }
            else
            {
                is_inside_7 = is_inside_6;
            }
            FKSurface _S1603 = surface_11;
            bool _S1604 = boundsVolume_0(&_S1603);
            bool _S1605;
            if(_S1604)
            {
                _S1605 = !_S1584;
            }
            else
            {
                _S1605 = false;
            }
            if(_S1605)
            {
                FKSurface faced_2 = surface_11;
                float3  _S1606 = - _S1595.geometry_n;
                float3  _S1607 = _slang_select(turned_1, _S1606,_S1595.geometry_n);
                (&faced_2)->geometry_n = _S1607;
                FKMedium _S1608 = Medium_x24init_0(scatter_in_0, extinction_in_0, g_in_0);
                FKMedium _S1609 = (fcptOutsideMedium((hit_4)));
                FKSurface _S1610 = faced_2;
                FKMedium _S1611 = _S1608;
                FKMedium _S1612 = _S1609;
                MediumSides _S1613 = mediumSides_0(&_S1610, &_S1611, filling_2, (&ray_2)->unit_direction, &_S1612);
                bool _S1614 = leavesInFront_0((&faced_2)->geometry_n, throughput_8, _S1595.geometry_n);
                float3  _S1615 = _slang_select(_S1614, _S1613.front.scatter,_S1613.behind.scatter);
                scatter_in_0 = _S1615;
                float3  _S1616 = _slang_select(_S1614, _S1613.front.extinction,_S1613.behind.extinction);
                extinction_in_0 = _S1616;
                float _S1617 = _slang_select(_S1614, _S1613.front.g,_S1613.behind.g);
                g_in_0 = _S1617;
                uint _S1618 = _S1613.fillings.x;
                uint _S1619 = _S1613.fillings.y;
                uint _S1620 = _slang_select(_S1614, _S1619,_S1618);
                bool _S1621 = (fcptVaryingUsed());
                uint _S1622 = _slang_select(_S1621, _S1620,4294967295U);
                filling_2 = _S1622;
            }
            (&ray_2)->unit_direction = throughput_8;
            bool _S1623 = !_S1584;
            if(_S1623)
            {
                FKSurface _S1624 = surface_11;
                float _S1625 = _slang_select(straight_0, 0.0f,_S1624.geometry_offset);
                float3  _S1626 = - _S1377.smooth_n;
                bool _S1627 = is_inside_7 != _S1511;
                float3  _S1628 = _slang_select(_S1627, _S1626,_S1377.smooth_n);
                float3  _S1629 = (&ray_2)->origin + make_float3 (_S1625) * _S1628;
                (&ray_2)->origin = _S1629;
            }
            throughput_9 = throughput_10;
            chain_throughput_0 = chain_throughput_1;
            density_6 = sky_pdf_2;
            passes_0 = _S1584;
            viewed_1 = _S1509;
            sky_pdf_2 = _S1599;
            spread_5 = _S1600;
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
        bool _S1630 = !replay_2;
        float density_7;
        if(_S1630)
        {
            if(_S1346)
            {
                float3  _S1631 = throughput_9 * emission_1;
                Reservoir candidate_8 = chain_0;
                uint _S1632 = extractBits_0((&chain_0)->path, 10U, 2U);
                bool _S1633 = _S1632 == 1U;
                if(_S1633)
                {
                    float3  _S1634 = safeDivide(_S1631, chain_throughput_0);
                    (&candidate_8)->radiance = _S1634;
                }
                Reservoir _S1635 = withEnd(candidate_8, 2U, b_10, _S1631);
                offer(sel_7, _S1635, _S1631 * make_float3 (scale_3) / make_float3 (density_6));
            }
            if(_S1346)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = scatter_2;
            }
            if(refracted_4)
            {
                float _S1636 = survivalProbability(throughput_9, density_6);
                density_7 = _S1636;
            }
            else
            {
                density_7 = 1.0f;
            }
            uint _S1637 = stream(_S1232, b_10 + 128U);
            Random _S1638 = pcg(_S1637);
            bool _S1639 = density_7 < (_S1638.value);
            if(_S1639)
            {
                wrong_side_0 = true;
            }
            else
            {
                uint _S1640 = (fcptMaxBounces());
                wrong_side_0 = b_10 >= _S1640;
            }
            if(wrong_side_0)
            {
                break;
            }
            float _S1641 = density_6 * density_7;
            density_7 = _S1641;
        }
        else
        {
            density_7 = density_6;
        }
        uint _S1642 = layer_0 ^ 1U;
        uint _S1643 = _slang_select(passes_0, _S1642,0U);
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
            uint _S1644 = b_13 + 1U;
            b_10 = _S1644;
            layer_0 = _S1643;
            continue;
        }
        FKRay _S1645 = ray_2;
        float _S1646 = distance_1(reconnection_0, (&ray_2)->origin) * 1.0010000467300415f;
        if(replay_2)
        {
            refracted_4 = _S1415;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            wrong_side_0 = _S1209 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S1647 = _slang_select(wrong_side_0, _S1646,4.294967296e+09f);
        bool _S1648 = !_S1384;
        if(straight_0)
        {
            _S1459 = true;
        }
        else
        {
            _S1459 = _S1384;
        }
        FKHit _S1649;
        if(_S1459)
        {
            _S1649 = hit_4;
        }
        else
        {
            _S1649 = _S1432;
        }
        FKHit _S1650 = (fcptTraverseInstanceBVH((_S1645), (_S1351), (_S1647), (_S1648), (_S1649), (viewed_1)));
        hit_4 = _S1650;
        if(replay_2)
        {
            _S1460 = _S1415;
        }
        else
        {
            _S1460 = false;
        }
        if(_S1460)
        {
            _S1505 = _S1209 == 1U;
        }
        else
        {
            _S1505 = false;
        }
        if(_S1505)
        {
            _S1506 = ((&hit_4)->instance_index) == (_S1221.instance_index);
        }
        else
        {
            _S1506 = false;
        }
        if(_S1506)
        {
            _S1507 = ((&hit_4)->triangle_index) == (_S1221.triangle_index);
        }
        else
        {
            _S1507 = false;
        }
        if(_S1507)
        {
            (&hit_4)->uv = _S1221.uv;
            float _S1651 = distance_1(reconnection_0, (&ray_2)->origin);
            (&hit_4)->distance = _S1651;
        }
        if(replay_2)
        {
            _S1508 = _S1415;
        }
        else
        {
            _S1508 = false;
        }
        if(_S1508)
        {
            _S1509 = _S1209 == 3U;
        }
        else
        {
            _S1509 = false;
        }
        if(_S1509)
        {
            _S1510 = ((&hit_4)->instance_index) != 4294967295U;
        }
        else
        {
            _S1510 = false;
        }
        if(_S1510)
        {
            return _S1205;
        }
        Reservoir _S1652 = chain_0;
        uint _S1653 = filling_2;
        for(;;)
        {
            bool _S1654 = (fcptVaryingUsed());
            if(_S1654)
            {
                _S1511 = _S1653 != 4294967295U;
            }
            else
            {
                _S1511 = false;
            }
            float _S1655;
            if(_S1511)
            {
                float _S1656 = (fcptMajorant((_S1653)));
                _S1655 = _S1656;
            }
            else
            {
                _S1655 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
            }
            if(replay_2)
            {
                _S1512 = _S1415;
            }
            else
            {
                _S1512 = false;
            }
            if(_S1512)
            {
                _S1513 = _S1209 == 1U;
            }
            else
            {
                _S1513 = false;
            }
            if(_S1513)
            {
                _S1514 = _S1655 > 0.0f;
            }
            else
            {
                _S1514 = false;
            }
            if(_S1514)
            {
                ended_0 = _S1205;
                sky_pdf_1 = sky_pdf_2;
                spread_3 = spread_5;
                width_4 = width_3;
                density_3 = density_7;
                throughput_10 = throughput_9;
                b_13 = b_10;
                _S1515 = true;
                break;
            }
            bool _S1657 = (&prev_0)->rough;
            if(_S1657)
            {
                _S1515 = !(_S1655 > 0.0f);
            }
            else
            {
                _S1515 = false;
            }
            (&prev_0)->rough = _S1515;
            uint _S1658 = b_10 + 320U;
            bool _S1659 = b_10 == 4294967295U;
            uint _S1660 = _slang_select(_S1659, 384U,_S1658);
            uint _S1661 = stream(_S1232, _S1660);
            uint tracking_1 = _S1661;
            weight_1 = throughput_3;
            glowed_0 = _S1204;
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
                    _S1203 = int(2);
                    break;
                }
                uint _S1662 = b_13 + 320U;
                bool _S1663 = b_13 == 4294967295U;
                uint _S1664 = _slang_select(_S1663, 384U,_S1662);
                uint _S1665 = stream(_S1232, _S1664);
                Random _S1666 = pcg(_S1665);
                float _S1667 = freeFlight_0(_S1666.value, _S1655);
                if(_S1511)
                {
                    float3  _S1668 = (&ray_2)->origin;
                    float3  _S1669 = (&ray_2)->unit_direction;
                    float _S1670 = (&hit_4)->distance;
                    uint _S1671 = _slang_select(_S1663, 0U,b_13);
                    uint _S1672 = (&prev_0)->lobe;
                    uint _S1673 = _slang_select(_S1663, 3U,_S1672);
                    float _S1674 = (fcptTrackMedium((_S1653), (_S1668), (_S1669), (_S1670), (&tracking_1), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1671), (_S1673), (_S1663)));
                    spread_4 = _S1674;
                }
                else
                {
                    spread_4 = _S1667;
                }
                bool _S1675 = !(spread_4 < ((&hit_4)->distance));
                if(_S1675)
                {
                    _S1203 = int(2);
                    break;
                }
                if(_S1511)
                {
                    _S1516 = _S1630;
                }
                else
                {
                    _S1516 = false;
                }
                if(_S1516)
                {
                    float3  _S1676 = throughput_10 * glowed_0 / make_float3 (density_3);
                    float3  _S1677 = sel_7->glow + _S1676;
                    sel_7->glow = _S1677;
                }
                else
                {
                }
                glowed_0 = _S1204;
                uint b_14 = b_13 + 1U;
                float3  _S1678 = (&ray_2)->origin + make_float3 (spread_4) * (&ray_2)->unit_direction;
                (&ray_2)->origin = _S1678;
                float3  _S1679 = flightWeight_0(scatter_in_0, extinction_in_0, _S1655, spread_4, true);
                float3  _S1680 = weight_1;
                float3  _S1681 = _slang_select(_S1511, _S1680,_S1679);
                float3  throughput_11 = throughput_10 * _S1681;
                uint _S1682 = stream(_S1232, b_14 + 320U);
                tracking_1 = _S1682;
                weight_1 = throughput_3;
                float width_7 = width_4 + spread_3 * spread_4;
                float _S1683 = spread_3 + 3.14159274101257324f;
                bool _S1684 = scatterSampled_0(replay_2, b_14, _S1220, _S1511);
                TreeSample light_4;
                if(_S1684)
                {
                    float3  _S1685 = (&ray_2)->origin;
                    float3  _S1686 = (&ray_2)->unit_direction;
                    float3  _S1687 = (&ray_2)->unit_direction;
                    uint _S1688 = stream(_S1232, b_14 + 64U);
                    float3  _S1689 = extinction_in_0;
                    float3  _S1690 = extinction_in_0;
                    uint2  _S1691 = make_uint2 (_S1653);
                    float3  _S1692 = (&ray_2)->unit_direction;
                    uint _S1693 = arrivalLobe_0(b_14, (&prev_0)->lobe);
                    FKHit _S1694 = _S1432;
                    ShadowContext _S1695 = ShadowContext_x24init_0(_S1689, _S1690, _S1691, _S1692, b_14, _S1693, false, spread_4, width_7, &_S1694, false);
                    ShadowContext _S1696 = _S1695;
                    TreeSample _S1697 = sampleLightTree_0(_S1685, _S1686, _S1687, 0.0f, true, _S1688, &_S1696);
                    light_4 = _S1697;
                }
                else
                {
                    light_4 = _S1429;
                }
                float _S1698 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_4.dir));
                uint _S1699 = (fcptMaxBounces());
                bool _S1700 = b_14 < _S1699;
                if(_S1700)
                {
                    _S1517 = (light_4.density) > 0.0f;
                }
                else
                {
                    _S1517 = false;
                }
                float _S1701 = _slang_select(_S1517, _S1698,0.0f);
                float3  _S1702 = throughput_11 * light_4.radiance;
                float _S1703 = powerHeuristic(light_4.density, _S1701);
                float3  _S1704 = _S1702 * make_float3 (_S1698 * _S1703);
                float3  _S1705 = _slang_select(_S1684, _S1704,_S1204);
                if(replay_2)
                {
                    _S1518 = b_14 == _S1220;
                }
                else
                {
                    _S1518 = false;
                }
                if(_S1518)
                {
                    bool _S1706 = _S1209 == 2U;
                    if(_S1706)
                    {
                        float _S1707 = rgb_to_greyscale(_S1705);
                        _S1519 = _S1707 > 0.0f;
                    }
                    else
                    {
                        _S1519 = false;
                    }
                    if(_S1519)
                    {
                        Shift _S1708 = Shift_x24init_0(_S1705, 1.0f);
                        _S1203 = int(1);
                        ended_0 = _S1708;
                        spread_4 = _S1683;
                        width_5 = width_7;
                        throughput_8 = throughput_11;
                        b_11 = b_14;
                        break;
                    }
                    _S1203 = int(1);
                    ended_0 = _S1205;
                    spread_4 = _S1683;
                    width_5 = width_7;
                    throughput_8 = throughput_11;
                    b_11 = b_14;
                    break;
                }
                if(_S1630)
                {
                    Reservoir candidate_9 = _S1652;
                    uint _S1709 = extractBits_0(_S1652.path, 10U, 2U);
                    bool _S1710 = _S1709 == 1U;
                    if(_S1710)
                    {
                        float3  _S1711 = safeDivide(_S1705, chain_throughput_0);
                        (&candidate_9)->radiance = _S1711;
                    }
                    else
                    {
                        uint _S1712 = insertBits_0(0U, b_14 + 1U, 5U, 5U);
                        uint _S1713 = insertBits_0(_S1712, 2U, 10U, 2U);
                        (&candidate_9)->path = _S1713;
                    }
                    Reservoir _S1714 = withEnd(candidate_9, 0U, b_14, _S1705);
                    offer(sel_7, _S1714, _S1705 * make_float3 (scale_3) / make_float3 (density_3));
                    float _S1715 = survivalProbability(throughput_11, density_3);
                    uint _S1716 = stream(_S1232, b_14 + 128U);
                    Random _S1717 = pcg(_S1716);
                    bool _S1718 = _S1715 < (_S1717.value);
                    if(_S1718)
                    {
                        _S1519 = true;
                    }
                    else
                    {
                        uint _S1719 = (fcptMaxBounces());
                        _S1519 = b_14 >= _S1719;
                    }
                    if(_S1519)
                    {
                        _S1203 = int(1);
                        ended_0 = _S1205;
                        spread_4 = _S1683;
                        width_5 = width_7;
                        throughput_8 = throughput_11;
                        b_11 = b_14;
                        break;
                    }
                    float _S1720 = density_3 * _S1715;
                    density_3 = _S1720;
                }
                else
                {
                }
                float phase_pdf_1 = 0.0f;
                uint _S1721 = stream(_S1232, b_14);
                float3  _S1722 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1721, &phase_pdf_1);
                (&ray_2)->unit_direction = _S1722;
                NEEVertex _S1723 = NEEVertex_x24init_0(false, phase_pdf_1, (&ray_2)->origin, _S1204, (&ray_2)->origin);
                nee_vertex_0 = _S1723;
                Vertex _S1724 = scatteredVertex_0(is_inside_5);
                prev_0 = _S1724;
                float _S1725 = (&prev_0)->pdf;
                FKRay _S1726 = ray_2;
                FKHit _S1727 = (fcptTraverseInstanceBVH((_S1726), (true), (4.294967296e+09f), (false), (_S1432), (false)));
                hit_4 = _S1727;
                b_13 = b_14;
                throughput_10 = throughput_11;
                spread_3 = _S1683;
                width_4 = width_7;
                sky_pdf_1 = _S1725;
            }
            if(_S1203 != int(2))
            {
                spread_3 = spread_4;
                width_4 = width_5;
                throughput_10 = throughput_8;
                b_13 = b_11;
                _S1515 = true;
                break;
            }
            ended_0 = _S1205;
            _S1515 = false;
            break;
        }
        if(_S1515)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S1516 = b_13 == b_10;
        }
        else
        {
            _S1516 = false;
        }
        bool _S1728 = ((&hit_4)->instance_index) == 4294967295U;
        if(_S1728)
        {
            bool _S1729 = !(&nee_vertex_0)->none;
            float _S1730 = _slang_select(_S1729, sky_pdf_1,0.0f);
            float _S1731 = escapeWeight_0(_S1730, (&ray_2)->unit_direction);
            float3  _S1732 = environment_0((&ray_2)->unit_direction, b_13, (&prev_0)->lobe);
            float3  _S1733 = throughput_10 * _S1732;
            if(replay_2)
            {
                bool _S1734 = b_13 == _S1220;
                if(_S1734)
                {
                    passes_0 = _S1209 == 3U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(_S1733 * make_float3 (_S1731) / make_float3 (r_8->jac), density_3 / r_8->jac);
                }
                if(_S1219)
                {
                    passes_0 = _S1216;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = b_13 == _S1207;
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
                    return Shift_x24init_0(_S1733 * make_float3 (_S1731), 1.0f);
                }
                return _S1205;
            }
            Reservoir candidate_10 = chain_0;
            uint _S1735 = extractBits_0((&chain_0)->path, 10U, 2U);
            bool _S1736 = _S1735 == 1U;
            if(_S1736)
            {
                uint _S1737 = extractBits_0((&chain_0)->path, 5U, 5U);
                bool _S1738 = _S1737 == b_13;
                float _S1739 = _slang_select(_S1738, 1.0f,_S1731);
                float3  _S1740 = safeDivide(_S1733 * make_float3 (_S1739), chain_throughput_0);
                (&candidate_10)->radiance = _S1740;
            }
            else
            {
                bool _S1741 = (&prev_0)->rough;
                if(_S1741)
                {
                    uint _S1742 = insertBits_0(0U, b_13 + 1U, 5U, 5U);
                    uint _S1743 = insertBits_0(_S1742, 3U, 10U, 2U);
                    uint _S1744 = insertBits_0(_S1743, (&prev_0)->lobe, 15U, 3U);
                    bool _S1745 = (&prev_0)->inside;
                    uint _S1746 = _slang_select(_S1745, 1U,0U);
                    uint _S1747 = insertBits_0(_S1744, _S1746, 22U, 1U);
                    (&candidate_10)->path = _S1747;
                    (&candidate_10)->jac = (&prev_0)->pdf;
                    (&candidate_10)->dir = (&ray_2)->unit_direction;
                }
            }
            float3  _S1748 = _S1733 * make_float3 (_S1731);
            Reservoir _S1749 = withEnd(candidate_10, 3U, b_13, _S1748);
            offer(sel_7, _S1749, _S1748 * make_float3 (scale_3) / make_float3 (density_3));
            break;
        }
        float3  _S1750 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
        (&ray_2)->origin = _S1750;
        bool _S1751 = (fcptVaryingUsed());
        if(_S1751)
        {
            _S1517 = filling_2 != 4294967295U;
        }
        else
        {
            _S1517 = false;
        }
        if(_S1517)
        {
            if(_S1630)
            {
                float3  _S1752 = throughput_10 * glowed_0 / make_float3 (density_3);
                float3  _S1753 = sel_7->glow + _S1752;
                sel_7->glow = _S1753;
            }
            float3  _S1754 = throughput_10 * weight_1;
            throughput_8 = _S1754;
        }
        else
        {
            float3  _S1755 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
            float3  _S1756 = throughput_10 * _S1755;
            throughput_8 = _S1756;
        }
        float _S1757 = width_4 + spread_3 * (&hit_4)->distance;
        viewed_0 = _S1516;
        width_3 = _S1757;
        throughput_2 = throughput_8;
        density_2 = density_3;
        sky_pdf_0 = sky_pdf_1;
        spread_2 = spread_3;
        uint _S1644 = b_13 + 1U;
        b_10 = _S1644;
        layer_0 = _S1643;
    }
    return _S1205;
}

static __device__ Shift shift_0(Domain * dom_8, Reservoir * r_9)
{
    Selection _S1758 = (Selection{});
    Selection sel_8 = _S1758;
    bool _S1759 = (r_9->w) <= 0.0f;
    if(_S1759)
    {
        return Shift_x24init_0(make_float3 (0.0f), 0.0f);
    }
    Shift _S1760 = walk_0(dom_8, r_9, true, 0.0f, &sel_8);
    return _S1760;
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
    Random _S1761 = pcg(state_3);
    Random _S1762 = pcg(_S1761.state);
    float _S1763 = 6.28318548202514648f * _S1761.value;
    float _S1764 = (F32_sqrt((-2.0f * clamp_1((F32_log((_S1762.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S1762.state, _S1764 * (F32_cos((_S1763))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_4, float3  value_2)
{
    RandomSphere _S1765;
    (&_S1765)->state = state_4;
    (&_S1765)->value = value_2;
    return _S1765;
}

__device__ RandomSphere random_sphere(uint state_5)
{
    Random _S1766 = normal_distribution(state_5);
    Random _S1767 = normal_distribution(_S1766.state);
    Random _S1768 = normal_distribution(_S1767.state);
    float3  _S1769 = make_float3 (_S1766.value, _S1767.value, _S1768.value);
    float3  _S1770 = ((((_S1769)) * make_float3(rnorm3df(((_S1769)).x, ((_S1769)).y, ((_S1769)).z))));
    return RandomSphere_x24init_0(_S1768.state, _S1770);
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_17)
{
    float3  _S1771 = p1_0 - p0_0;
    float3  _S1772 = p2_0 - p0_0;
    float2  _S1773 = uv1_0 - uv0_0;
    float2  _S1774 = uv2_0 - uv0_0;
    float _S1775 = _S1773.x;
    float _S1776 = _S1774.y;
    float _S1777 = _S1773.y;
    float _S1778 = _S1774.x;
    float _S1779 = _S1775 * _S1776 - _S1777 * _S1778;
    float _S1780 = 1.0f / _S1779;
    float3  t_24 = (_S1771 * make_float3 (_S1776) - _S1772 * make_float3 (_S1777)) * make_float3 (_S1780);
    float3  _S1781 = (_S1772 * make_float3 (_S1775) - _S1771 * make_float3 (_S1778)) * make_float3 (_S1780);
    float3  _S1782 = t_24 - n_17 * make_float3 (dot_0(n_17, t_24));
    float3  t_25 = ((((_S1782)) * make_float3(rnorm3df(((_S1782)).x, ((_S1782)).y, ((_S1782)).z))));
    bool _S1783 = (dot_0(cross_0(n_17, t_25), _S1781)) > 0.0f;
    float3  t_26;
    if(_S1783)
    {
        float3  _S1784 = negate_0(t_25);
        t_26 = _S1784;
    }
    else
    {
        t_26 = t_25;
    }
    float3  _S1785 = cross_0(n_17, t_26);
    return makeMatrix<float, 3, 3> (t_26, _S1785, n_17);
}

__device__ float3  tangentToWorldNormalMap(float3  v_8, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_8, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_5, float3  uvw_0, float3  position_0)
{
    float3  _S1786 = t1_0 - t0_0;
    float3  _S1787 = t2_2 - t0_0;
    float3  _S1788 = t2_2 - t1_0;
    float _S1789 = (F32_min((length_0(_S1786)), ((F32_min((length_0(_S1787)), (length_0(_S1788)))))));
    float3  _S1790 = make_float3 (distance_1(position_0, t0_0), distance_1(position_0, t1_0), distance_1(position_0, t2_2));
    float3  _S1791 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S1792 = dot_0(geometry_n_5, _S1791);
    float3  _S1793 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S1794 = dot_0(geometry_n_5, _S1793);
    float3  _S1795 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S1796 = acos_0(abs_0(make_float3 (_S1792, _S1794, dot_0(geometry_n_5, _S1795))));
    float3  _S1797 = clamp_2(tan_0(_S1796), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_1(dot_0(_S1790 * _S1797, uvw_0), 0.0f, _S1789 * 0.125f);
}

__device__ float3  straightThrough(float3  dir_15, float3  n_18, BSDFMaterial material_17)
{
    float3  _S1798 = negate_0(dir_15);
    float _S1799 = sign_0(dot_0(n_18, _S1798));
    float3  _S1800 = n_18 * make_float3 (_S1799);
    AnisotropicFrame _S1801 = anisotropicFrame(material_17, _S1800);
    bool _S1802 = (_S1801.alphas.x) > 0.0f;
    if(_S1802)
    {
        float _S1803 = material_17.transmission * (1.0f - material_17.metallic);
        float3  _S1804 = negate_0(_S1800);
        float3  _S1805 = anisotropicLocal(dir_15, _S1801.tangent, _S1804);
        float _S1806 = anisotropicG1(_S1805, _S1801.alphas);
        return make_float3 (_S1803 * _S1806) * material_17.albedo;
    }
    float _S1807 = material_17.transmission * (1.0f - material_17.metallic);
    float _S1808 = material_17.roughness;
    float _S1809 = smithG1(_S1808 * _S1808, (F32_abs((dot_0(n_18, dir_15)))));
    return make_float3 (_S1807 * _S1809) * material_17.albedo;
}

__device__ float hairRow(float3  in_dir_10, float3  t_27, float3  out_dir_4, uint p_12, float w_2, float alpha_6, uint nt_0)
{
    uint _S1810 = p_12 % 4U;
    float _S1811 = w_2 * HAIR_WIDTHS_0[_S1810];
    float _S1812 = (F32_asin((clamp_1(dot_0(out_dir_4, t_27), -1.0f, 1.0f)))) - (F32_asin((clamp_1(dot_0(in_dir_10, t_27), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S1810] * alpha_6;
    return ((F32_asinh((_S1812 / _S1811))) / (F32_asinh((3.14159274101257324f / _S1811))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_11, float3  t_28, float3  out_dir_5, uint np_0)
{
    float3  _S1813 = worldToTangent(out_dir_5, t_28);
    float3  _S1814 = worldToTangent(in_dir_11, t_28);
    return (F32_frac((((F32_atan2((_S1813.z), (_S1813.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S1814.z), (1.17549435082228751e-38f - _S1814.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_12, float3  t_29, uint p_13, float row_0, float column_0, float w_3, float alpha_7, uint nt_1, uint np_1)
{
    float3  _S1815 = worldToTangent(in_dir_12, t_29);
    uint _S1816 = p_13 % 4U;
    float _S1817 = w_3 * HAIR_WIDTHS_0[_S1816];
    float _S1818 = (F32_asin((clamp_1(dot_0(in_dir_12, t_29), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S1816] * alpha_7 + _S1817 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S1817))))));
    float _S1819 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S1815.z), (1.17549435082228751e-38f - _S1815.x)));
    float _S1820 = (F32_cos((_S1818)));
    float3  _S1821 = tangentToWorld(make_float3 (_S1820 * (F32_cos((_S1819))), (F32_sin((_S1818))), _S1820 * (F32_sin((_S1819)))), t_29);
    return _S1821;
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_19, BSDFMaterial material_18, float coverage_1)
{
    float3  _S1822;
    if((material_18.ior) == 1.0f)
    {
        float3  _S1823 = straightThrough(toward_1, n_19, material_18);
        _S1822 = _S1823;
    }
    else
    {
        _S1822 = make_float3 (0.0f);
    }
    return _S1822 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ Shift walk_hook(Domain dom_9, Reservoir r_10, bool replay_3, float scale_4, Selection * sel_9)
{
    Domain _S1824 = dom_9;
    Reservoir _S1825 = r_10;
    Shift _S1826 = walk_0(&_S1824, &_S1825, replay_3, scale_4, sel_9);
    return _S1826;
}

__device__ Shift shift_hook(Domain dom_10, Reservoir r_11)
{
    Domain _S1827 = dom_10;
    Reservoir _S1828 = r_11;
    Shift _S1829 = shift_0(&_S1827, &_S1828);
    return _S1829;
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
