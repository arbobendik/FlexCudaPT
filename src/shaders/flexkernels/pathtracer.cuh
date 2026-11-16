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

__device__ float importance(LightNode node_0, float3  p_7, float3  normal_0)
{
    float3  _S210 = (node_0.low + node_0.high) * make_float3 (0.5f);
    float3  _S211 = node_0.high - node_0.low;
    float3  _S212 = p_7 - _S210;
    float3  _S213 = ((((_S212)) * make_float3(rnorm3df(((_S212)).x, ((_S212)).y, ((_S212)).z))));
    float _S214 = dot_0(_S212, _S212);
    float _S215 = dot_0(_S211, _S211) / 4.0f;
    float _S216 = (F32_abs((dot_0(node_0.w, _S213))));
    float _S217 = sine(node_0.cos_theta_o);
    float _S218 = (F32_sqrt(((F32_max((1.0f - _S215 / _S214), (0.0f))))));
    bool _S219 = _S214 < _S215;
    float _S220 = _slang_select(_S219, -1.0f,_S218);
    float _S221 = sine(_S220);
    float _S222 = sine(_S216);
    float _S223 = cosSubClamped(_S222, _S216, _S217, node_0.cos_theta_o);
    float _S224 = sine(_S216);
    float _S225 = _S224 * node_0.cos_theta_o - _S216 * _S217;
    bool _S226 = _S216 > (node_0.cos_theta_o);
    float _S227 = _slang_select(_S226, 0.0f,_S225);
    float _S228 = cosSubClamped(_S227, _S223, _S221, _S220);
    bool _S229 = _S228 <= 0.0f;
    if(_S229)
    {
        return 0.0f;
    }
    float _S230 = - dot_0(_S213, normal_0);
    float _S231 = node_0.phi * _S228 / (F32_max((_S214), (length_0(_S211) / 2.0f)));
    float _S232 = sine(_S230);
    float _S233 = cosSubClamped(_S232, _S230, _S221, _S220);
    bool _S234 = (dot_0(normal_0, normal_0)) == 0.0f;
    float _S235 = _slang_select(_S234, 1.0f,_S233);
    return (F32_max((_S231 * _S235), (0.0f)));
}

__device__ __forceinline__ float childShare(LightNode first_0, LightNode second_0, float3  p_8, float3  normal_1, uint child_0)
{
    float _S236 = importance(first_0, p_8, normal_1);
    float _S237 = importance(second_0, p_8, normal_1);
    float2  _S238 = make_float2 (_S236, _S237);
    float _S239 = _slang_vector_get_element(_S238, child_0) / (_S236 + _S237);
    bool _S240 = _slang_vector_get_element(_S238, child_0) > 0.0f;
    float _S241 = _slang_select(_S240, _S239,0.0f);
    return _S241;
}

__device__ float sphereDensity(float3  center_0, float radius_0, float3  p_9)
{
    float3  _S242 = center_0 - p_9;
    float _S243 = radius_0 * radius_0 / dot_0(_S242, _S242);
    bool _S244 = _S243 >= 1.0f;
    if(_S244)
    {
        return 0.07957746833562851f;
    }
    return (1.0f + (F32_sqrt((1.0f - _S243)))) / (6.28318548202514648f * _S243);
}

static __device__ float3  cross_0(float3  left_0, float3  right_0)
{
    float _S245 = left_0.y;
    float _S246 = right_0.z;
    float _S247 = left_0.z;
    float _S248 = right_0.y;
    float _S249 = right_0.x;
    float _S250 = left_0.x;
    return make_float3 (_S245 * _S246 - _S247 * _S248, _S247 * _S249 - _S250 * _S246, _S250 * _S248 - _S245 * _S249);
}

__device__ float solidAngle(float probability_0, float3  normal_2, float3  toward_0)
{
    return 2.0f * probability_0 * (F32_pow((length_0(toward_0)), (3.0f))) / (F32_abs((dot_0(normal_2, toward_0))));
}

static __device__ float lightPdf_0(float3  origin_3, float3  smooth_n_1, float3  start_5, uint j_0, float3  light_point_0)
{
    bool _S251 = j_0 == 4294967295U;
    if(_S251)
    {
        return 0.0f;
    }
    uint4  _S252 = (fcptLightTrail((j_0)));
    uint2  _S253 = uint2 {_S252.x, _S252.y};
    uint n_0 = 0U;
    uint2  trail_0 = _S253;
    float probability_1 = 1.0f;
    for(;;)
    {
        uint4  _S254 = (fcptLightNode((n_0)));
        if((_S254.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S255 = (fcptLightSecond((n_0)));
        uint _S256 = n_0 + 1U;
        LightNode _S257 = (fcptLightBounds((_S256)));
        LightNode _S258 = (fcptLightBounds((_S255)));
        uint _S259 = trail_0.x;
        uint _S260 = _S259 & 1U;
        float _S261 = childShare(_S257, _S258, origin_3, smooth_n_1, _S260);
        float probability_2 = probability_1 * _S261;
        bool _S262 = _S260 == 1U;
        uint _S263 = _slang_select(_S262, _S255,_S256);
        uint _S264 = trail_0.y;
        uint2  _S265 = make_uint2 ((_S259 >> 1U) | (_S264 << 31U), _S264 >> 1U);
        n_0 = _S263;
        trail_0 = _S265;
        probability_1 = probability_2;
    }
    bool _S266 = (fcptSlotLeaf((n_0), (j_0)));
    bool _S267 = !_S266;
    bool _S268;
    if(_S267)
    {
        _S268 = true;
    }
    else
    {
        LightNode _S269 = (fcptLightBounds((n_0)));
        float _S270 = importance(_S269, origin_3, smooth_n_1);
        _S268 = !(_S270 > 0.0f);
    }
    if(_S268)
    {
        _S268 = true;
    }
    else
    {
        bool _S271 = (dot_0(smooth_n_1, smooth_n_1)) > 0.0f;
        if(_S271)
        {
            _S268 = !((dot_0(smooth_n_1, light_point_0 - origin_3)) > 0.0f);
        }
        else
        {
            _S268 = false;
        }
    }
    if(_S268)
    {
        return 0.0f;
    }
    uint4  _S272 = (fcptLightNode((n_0)));
    bool _S273 = (_S272.x) == 2U;
    if(_S273)
    {
        uint _S274 = _S272.y;
        FKLight _S275 = (fcptLight((_S274)));
        FKLight _S276 = (fcptLight((_S274)));
        float _S277 = sphereDensity(_S275.position, _S276.variance, start_5);
        return probability_1 * _S277;
    }
    uint _S278 = _S272.y;
    uint _S279 = (fcptTriangleOffset((_S278)));
    Matrix<float, 3, 3>  _S280 = (fcptWorldTriangle((_S278), (_S279 + _S272.z)));
    float _S281 = solidAngle(probability_1, cross_0(_S280.rows[int(1)] - _S280.rows[int(0)], _S280.rows[int(2)] - _S280.rows[int(0)]), light_point_0 - start_5);
    return _S281;
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
    Random _S282;
    (&_S282)->state = state_0;
    (&_S282)->value = value_0;
    return _S282;
}

__device__ Random pcg(uint state_1)
{
    uint _S283 = hash(state_1);
    float value_1 = float(_S283 >> int(8)) * 5.9604644775390625e-08f;
    return Random_x24init_0(_S283, value_1);
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
    uint2  _S284 = (fcptEnvironmentCdfSize());
    uint2  _S285 = _S284 - make_uint2 (1U, 0U);
    float2  _S286 = make_float2 ((F32_atan2((- dir_2.y), (dir_2.x))) / 6.28318548202514648f + 0.5f, (F32_acos((clamp_1(dir_2.z, -1.0f, 1.0f)))) / 3.14159274101257324f);
    float2  _S287 = make_float2 ((float)_S285.x, (float)_S285.y);
    float2  _S288 = _S286 * _S287;
    uint2  _S289 = make_uint2 ((uint)_S288.x, (uint)_S288.y);
    uint2  _S290 = min_0(_S289, _S285 - make_uint2 (1U));
    float4  _S291 = (fcptEnvironmentCdf((_S290)));
    float _S292 = _S291.y;
    uint _S293 = _S285.x;
    float4  _S294 = (fcptEnvironmentCdf((make_uint2 (_S293, _S290.y))));
    float _S295 = _S292 * _S294.y;
    return _S295 * float(_S293 * _S285.y) / (19.73921012878417969f * length_1(float2 {dir_2.x, dir_2.y}));
}

static __device__ float3  negate_0(float3  x_13)
{
    return - x_13;
}

static __device__ float sign_0(float e_1)
{
    float _S296;
    if(e_1 > 0.0f)
    {
        _S296 = 1.0f;
    }
    else
    {
        if(e_1 < 0.0f)
        {
            _S296 = -1.0f;
        }
        else
        {
            _S296 = 0.0f;
        }
    }
    return _S296;
}

struct AnisotropicFrame
{
    float3  tangent;
    float2  alphas;
};

static __device__ AnisotropicFrame AnisotropicFrame_x24init_0(float3  tangent_0, float2  alphas_0)
{
    AnisotropicFrame _S297;
    (&_S297)->tangent = tangent_0;
    (&_S297)->alphas = alphas_0;
    return _S297;
}

__device__ float3  tangentToWorld(float3  v_0, float3  n_1)
{
    float3  a_1 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S298 = (F32_abs((dot_0(n_1, a_1)))) > 0.9999847412109375f;
    float3  a_2;
    if(_S298)
    {
        float3  _S299 = make_float3 (1.0f, 0.0f, 0.0f);
        a_2 = _S299;
    }
    else
    {
        a_2 = a_1;
    }
    float3  _S300 = cross_0(n_1, a_2);
    float3  _S301 = ((((_S300)) * make_float3(rnorm3df(((_S300)).x, ((_S300)).y, ((_S300)).z))));
    float3  _S302 = cross_0(n_1, _S301);
    return make_float3 (v_0.x) * _S301 + make_float3 (v_0.y) * n_1 + make_float3 (v_0.z) * _S302;
}

__device__ AnisotropicFrame anisotropicFrame(BSDFMaterial material_0, float3  n_i_0)
{
    float _S303 = material_0.roughness;
    float _S304 = _S303 * _S303;
    bool _S305 = (material_0.anisotropy) == 0.0f;
    bool _S306;
    if(_S305)
    {
        _S306 = true;
    }
    else
    {
        _S306 = !(_S304 > 0.0f);
    }
    if(_S306)
    {
        return AnisotropicFrame_x24init_0(make_float3 (0.0f), make_float2 (0.0f));
    }
    float3  _S307 = material_0.tangent - n_i_0 * make_float3 (dot_0(n_i_0, material_0.tangent));
    float3  _S308 = tangentToWorld(make_float3 (1.0f, 0.0f, 0.0f), n_i_0);
    bool _S309 = (dot_0(_S307, _S307)) > 0.0f;
    float3  _S310 = _slang_select(_S309, _S307,_S308);
    float3  _S311 = ((((_S310)) * make_float3(rnorm3df(((_S310)).x, ((_S310)).y, ((_S310)).z))));
    float _S312 = 6.28318548202514648f * material_0.anisotropic_rotation;
    float _S313 = (F32_sqrt((1.0f - 0.89999997615814209f * (F32_abs((material_0.anisotropy))))));
    float _S314 = 1.0f / _S313;
    bool _S315 = (material_0.anisotropy) < 0.0f;
    float _S316 = _slang_select(_S315, _S314,_S313);
    return AnisotropicFrame_x24init_0(_S311 * make_float3 ((F32_cos((_S312)))) + cross_0(n_i_0, _S311) * make_float3 ((F32_sin((_S312)))), make_float2 (_S304 / _S316, _S304 * _S316));
}

struct SheenProfile
{
    bool on;
    float albedo;
};

static __device__ SheenProfile SheenProfile_x24init_0(bool on_0, float albedo_0)
{
    SheenProfile _S317;
    (&_S317)->on = on_0;
    (&_S317)->albedo = albedo_0;
    return _S317;
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
    SheenProfile _S318 = SheenProfile_x24init_0(false, 0.0f);
    float _S319 = rgb_to_greyscale(material_1.sheen);
    bool _S320 = _S319 > 0.0f;
    SheenProfile profile_0;
    if(_S320)
    {
        float _S321 = clamp_1((F32_sqrt(((F32_max((dot_0(n_i_1, v_1)), (0.0f)))))), 0.0f, 1.0f) * 23.0f;
        uint _S322 = (U32_min((uint(_S321)), (22U)));
        float _S323 = (F32_sqrt((0.05000000074505806f)));
        float _S324 = (F32_sqrt((0.10000000149011612f)));
        bool _S325 = (material_1.velvet) > 0.0f;
        float _S326 = _slang_select(_S325, _S324,_S323);
        float _S327 = (clamp_1((F32_sqrt(((F32_max((material_1.sheen_roughness), (0.0f)))))), _S326, 1.0f) - _S326) / (1.0f - _S326) * 23.0f;
        uint _S328 = (U32_min((uint(_S327)), (22U)));
        uint _S329 = _S322 * 24U + _S328;
        float _S330 = _S321 - float(_S322);
        float _S331 = _S327 - float(_S328);
        if(_S325)
        {
            uint _S332 = _S329 + 24U;
            float _S333 = VELVET_ALBEDO_0[_S329] + (VELVET_ALBEDO_0[_S332] - VELVET_ALBEDO_0[_S329]) * _S330;
            uint _S334 = _S329 + 1U;
            float _S335 = VELVET_ALBEDO_0[_S334] + (VELVET_ALBEDO_0[_S332 + 1U] - VELVET_ALBEDO_0[_S334]) * _S330;
            SheenProfile _S336 = SheenProfile_x24init_0(true, _S333 + (_S335 - _S333) * _S331);
            profile_0 = _S336;
        }
        else
        {
            uint _S337 = _S329 + 24U;
            float _S338 = SHEEN_ALBEDO_0[_S329] + (SHEEN_ALBEDO_0[_S337] - SHEEN_ALBEDO_0[_S329]) * _S330;
            uint _S339 = _S329 + 1U;
            float _S340 = SHEEN_ALBEDO_0[_S339] + (SHEEN_ALBEDO_0[_S337 + 1U] - SHEEN_ALBEDO_0[_S339]) * _S330;
            SheenProfile _S341 = SheenProfile_x24init_0(true, (F32_exp((_S338 + (_S340 - _S338) * _S331))));
            profile_0 = _S341;
        }
    }
    else
    {
        profile_0 = _S318;
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
    BSDFLobes _S342;
    (&_S342)->v_dot_h = v_dot_h_0;
    (&_S342)->n_dot_h = n_dot_h_0;
    (&_S342)->refracted = refracted_1;
    (&_S342)->F = F_0;
    (&_S342)->F_greyscale = F_greyscale_0;
    (&_S342)->reflect_weight = reflect_weight_0;
    (&_S342)->diffuse_weight = diffuse_weight_0;
    (&_S342)->refract_weight = refract_weight_0;
    (&_S342)->p_diffuse = p_diffuse_0;
    (&_S342)->p_reflect = p_reflect_0;
    (&_S342)->p_refract = p_refract_0;
    (&_S342)->translucent_share = translucent_share_0;
    (&_S342)->sheen = sheen_0;
    (&_S342)->p_sheen_velvet = p_sheen_velvet_0;
    (&_S342)->view = view_0;
    (&_S342)->tangent = tangent_1;
    (&_S342)->alphas = alphas_1;
    (&_S342)->visible = visible_0;
    (&_S342)->p_toon = p_toon_0;
    (&_S342)->toon = toon_0;
    (&_S342)->toon_a = toon_a_0;
    (&_S342)->toon_s = toon_s_0;
    (&_S342)->toon_b = toon_b_0;
    (&_S342)->toon_glossy = toon_glossy_0;
    (&_S342)->toon_norm = toon_norm_0;
    (&_S342)->toon_view = toon_view_0;
    (&_S342)->toon_axis = toon_axis_0;
    return _S342;
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
    float3  _S343 = make_float3 (alpha_0 * Ve_0.x, alpha_0 * Ve_0.y, Ve_0.z);
    float3  _S344 = ((((_S343)) * make_float3(rnorm3df(((_S343)).x, ((_S343)).y, ((_S343)).z))));
    float _S345 = _S344.x;
    float _S346 = _S344.y;
    float _S347 = _S345 * _S345 + _S346 * _S346;
    float3  _S348;
    if(_S347 > 0.0f)
    {
        float3  _S349 = make_float3 (- _S346, _S345, 0.0f);
        float _S350 = (rsqrtf((_S347)));
        _S348 = _S349 * make_float3 (_S350);
    }
    else
    {
        _S348 = make_float3 (1.0f, 0.0f, 0.0f);
    }
    float3  _S351 = cross_0(_S344, _S348);
    float _S352 = (F32_sqrt((U1_0)));
    float _S353 = 6.28318548202514648f * U2_0;
    float _S354 = _S352 * (F32_cos((_S353)));
    float t2_0 = _S352 * (F32_sin((_S353)));
    float _S355 = 0.5f * (1.0f + _S344.z);
    float t2_1 = (1.0f - _S355) * (F32_sqrt(((F32_max((0.0f), (1.0f - _S354 * _S354)))))) + _S355 * t2_0;
    float3  _S356 = make_float3 (_S354) * _S348 + make_float3 (t2_1) * _S351;
    float _S357 = unshared_0(_S354);
    float _S358 = unshared_0(_S354);
    float3  _S359 = _S356 + make_float3 ((F32_sqrt(((F32_max((0.0f), (1.0f - _S357 * _S358 - t2_1 * t2_1))))))) * _S344;
    float3  _S360 = make_float3 (alpha_0 * _S359.x, alpha_0 * _S359.y, (F32_max((0.0f), (_S359.z))));
    float3  _S361 = ((((_S360)) * make_float3(rnorm3df(((_S360)).x, ((_S360)).y, ((_S360)).z))));
    return _S361;
}

__device__ float3  worldToTangent(float3  v_2, float3  n_3)
{
    float3  a_3 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S362 = (F32_abs((dot_0(n_3, a_3)))) > 0.9999847412109375f;
    float3  a_4;
    if(_S362)
    {
        float3  _S363 = make_float3 (1.0f, 0.0f, 0.0f);
        a_4 = _S363;
    }
    else
    {
        a_4 = a_3;
    }
    float3  _S364 = cross_0(n_3, a_4);
    float3  _S365 = ((((_S364)) * make_float3(rnorm3df(((_S364)).x, ((_S364)).y, ((_S364)).z))));
    float3  _S366 = cross_0(n_3, _S365);
    return make_float3 (dot_0(v_2, _S365), dot_0(v_2, n_3), dot_0(v_2, _S366));
}

__device__ __forceinline__ float3  sampleHalfVector(float3  v_3, float3  n_i_2, float alpha_1, AnisotropicFrame frame_0, uint * random_state_2)
{
    Random _S367 = pcg(*random_state_2);
    Random _S368 = pcg(_S367.state);
    *random_state_2 = _S368.state;
    float _S369 = frame_0.alphas.x;
    bool _S370 = _S369 > 0.0f;
    if(_S370)
    {
        float3  _S371 = anisotropicLocal(v_3, frame_0.tangent, n_i_2);
        float _S372 = frame_0.alphas.y;
        float3  _S373 = make_float3 (_S369 * _S371.x, _S372 * _S371.y, _S371.z);
        float3  _S374 = ((((_S373)) * make_float3(rnorm3df(((_S373)).x, ((_S373)).y, ((_S373)).z))));
        float3  _S375 = sampleGGXVNDF(_S374, 1.0f, _S367.value, _S368.value);
        float3  _S376 = make_float3 (_S369 * _S375.x, _S372 * _S375.y, _S375.z);
        float3  _S377 = ((((_S376)) * make_float3(rnorm3df(((_S376)).x, ((_S376)).y, ((_S376)).z))));
        return make_float3 (_S377.x) * frame_0.tangent + make_float3 (_S377.y) * cross_0(n_i_2, frame_0.tangent) + make_float3 (_S377.z) * n_i_2;
    }
    float3  _S378 = worldToTangent(v_3, n_i_2);
    float3  _S379 = sampleGGXVNDF(float3 {_S378.x, _S378.z, _S378.y}, alpha_1, _S367.value, _S368.value);
    float3  _S380 = float3 {_S379.x, _S379.z, _S379.y};
    float3  _S381 = tangentToWorld(_S380, n_i_2);
    return _S381;
}

__device__ float3  sampledHalf(float3  in_dir_0, float3  n_4, BSDFMaterial material_2, uint random_state_3, AnisotropicFrame frame_1)
{
    uint state_2 = random_state_3;
    float3  _S382 = negate_0(in_dir_0);
    float _S383 = sign_0(dot_0(n_4, _S382));
    float _S384 = material_2.roughness;
    float3  _S385 = sampleHalfVector(_S382, n_4 * make_float3 (_S383), _S384 * _S384, frame_1, &state_2);
    return _S385;
}

__device__ float3  refractedHalf(float3  in_dir_1, float3  out_dir_0, float3  n_5, float eta_i_0, float eta_o_0)
{
    float3  _S386 = negate_0(in_dir_1);
    float3  _S387 = negate_0(make_float3 (eta_i_0) * _S386 + make_float3 (eta_o_0) * out_dir_0);
    float3  _S388 = ((((_S387)) * make_float3(rnorm3df(((_S387)).x, ((_S387)).y, ((_S387)).z))));
    float _S389 = sign_0(dot_0(n_5, _S386));
    float _S390 = sign_0(dot_0(_S387, n_5 * make_float3 (_S389)));
    return _S388 * make_float3 (_S390);
}

__device__ float3  reflectedHalf(float3  in_dir_2, float3  out_dir_1)
{
    float3  _S391 = negate_0(in_dir_2);
    float3  _S392 = _S391 + out_dir_1;
    float3  _S393 = ((((_S392)) * make_float3(rnorm3df(((_S392)).x, ((_S392)).y, ((_S392)).z))));
    return _S393;
}

static __device__ float3  refract_0(float3  i_5, float3  n_6, float eta_0)
{
    float _S394 = dot_0(n_6, i_5);
    float _S395 = 1.0f - eta_0 * eta_0 * (1.0f - _S394 * _S394);
    if(_S395 < 0.0f)
    {
        return make_float3 (0.0f);
    }
    return make_float3 (eta_0) * i_5 - make_float3 (eta_0 * _S394 + (F32_sqrt((_S395)))) * n_6;
}

__device__ float fresnel(float cos_theta_0, float eta_i_1, float eta_o_1)
{
    float _S396 = (F32_sqrt(((F32_max((0.0f), (1.0f - cos_theta_0 * cos_theta_0))))));
    float _S397 = eta_i_1 / eta_o_1 * _S396;
    bool _S398 = _S397 < 1.0f;
    float kr_0;
    if(_S398)
    {
        float _S399 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S397 * _S397))))));
        bool _S400 = eta_i_1 == eta_o_1;
        float _S401 = _slang_select(_S400, cos_theta_0,_S399);
        float _S402 = eta_o_1 * cos_theta_0;
        float _S403 = eta_i_1 * _S401;
        float _S404 = (_S402 - _S403) / (_S402 + _S403);
        float _S405 = eta_i_1 * cos_theta_0;
        float _S406 = eta_o_1 * _S401;
        float _S407 = (_S405 - _S406) / (_S405 + _S406);
        float _S408 = (_S404 * _S404 + _S407 * _S407) / 2.0f;
        kr_0 = _S408;
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
    float _S409 = (F32_max((w_1.z), (0.0f)));
    return 2.0f * _S409 / (_S409 + length_0(make_float3 (alphas_2.x * w_1.x, alphas_2.y * w_1.y, _S409)));
}

__device__ float anisotropicD(float3  h_0, float2  alphas_3)
{
    float _S410 = alphas_3.x;
    float _S411 = h_0.x / _S410;
    float _S412 = alphas_3.y;
    float _S413 = h_0.y / _S412;
    float _S414 = h_0.z;
    float _S415 = _S411 * _S411 + _S413 * _S413 + _S414 * _S414;
    return 1.0f / (F32_max((3.14159274101257324f * _S410 * _S412 * _S415 * _S415), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ BSDFLobes bsdfLobes(float3  in_dir_3, float3  v_4, float3  n_i_3, float3  ggx_n_0, BSDFMaterial material_3, float eta_i_2, float eta_o_2, AnisotropicFrame frame_2, SheenProfile sheen_profile_0)
{
    float _S416 = dot_0(ggx_n_0, v_4);
    float _S417 = dot_0(n_i_3, ggx_n_0);
    float _S418 = eta_i_2 / eta_o_2;
    float3  _S419 = refract_0(in_dir_3, ggx_n_0, _S418);
    float3  _S420 = ((((_S419)) * make_float3(rnorm3df(((_S419)).x, ((_S419)).y, ((_S419)).z))));
    float _S421 = (F32_min(((F32_sqrt((material_3.specular_level))) * (F32_abs((eta_i_2 - eta_o_2))) / (eta_i_2 + eta_o_2)), (0.9999847412109375f)));
    float _S422 = _S421 * _S421;
    float _S423 = (1.0f + _S421) / (1.0f - _S421);
    float _S424 = (F32_abs((_S416)));
    bool _S425 = eta_i_2 > eta_o_2;
    float sheen_component_0;
    if(_S425)
    {
        sheen_component_0 = _S423;
    }
    else
    {
        sheen_component_0 = 1.0f;
    }
    float toon_component_0;
    if(_S425)
    {
        toon_component_0 = 1.0f;
    }
    else
    {
        toon_component_0 = _S423;
    }
    float _S426 = fresnel(_S424, sheen_component_0, toon_component_0);
    bool _S427 = (eta_i_2 * eta_i_2 * (1.0f - _S416 * _S416)) >= (eta_o_2 * eta_o_2);
    float3  _S428;
    if(_S427)
    {
        _S428 = make_float3 (1.0f);
    }
    else
    {
        float3  _S429 = material_3.specular_tint * make_float3 (_S422);
        _S428 = _S429 + (make_float3 (1.0f) - _S429) * make_float3 (_S426 - _S422) / make_float3 (1.0f - _S422);
    }
    float3  _S430 = make_float3 (1.0f);
    float3  _S431 = make_float3 (0.0f);
    float3  sheen_1;
    float3  view_1;
    float3  scale_1;
    if(sheen_profile_0.on)
    {
        float _S432 = (F32_min((sheen_profile_0.albedo), (1.0f)));
        float3  _S433 = make_float3 (1.0f) - material_3.sheen * make_float3 (_S432);
        float _S434 = rgb_to_greyscale(material_3.sheen);
        float _S435 = _S434 * _S432;
        float3  _S436 = material_3.sheen / make_float3 ((F32_max((sheen_profile_0.albedo), (1.0f))));
        sheen_component_0 = _S435;
        sheen_1 = _S436;
        view_1 = v_4;
        scale_1 = _S433;
    }
    else
    {
        sheen_component_0 = 0.0f;
        sheen_1 = _S431;
        view_1 = _S431;
        scale_1 = _S430;
    }
    float _S437 = material_3.toon.x;
    bool _S438 = _S437 < 0.0f;
    float _S439 = (F32_abs((_S437)));
    bool _S440 = _S439 > 0.0f;
    float toon_a_1;
    float toon_s_1;
    float toon_b_1;
    float toon_norm_1;
    float toon_view_1;
    float3  toon_1;
    float3  toon_axis_1;
    bool _S441;
    if(_S440)
    {
        float _S442 = (F32_min((_S439), (1.0f)));
        float3  scale_2 = scale_1 * make_float3 (1.0f - _S442);
        float _S443 = rgb_to_greyscale(material_3.albedo);
        float _S444 = _S442 * _S443;
        float3  _S445 = make_float3 (_S442) * material_3.albedo;
        float toon_a_2 = clamp_1(material_3.toon.y / _S437, 0.00000999999974738f, 1.0f) * 3.14159274101257324f / 2.0f;
        float toon_s_2 = clamp_1(material_3.toon.z / _S437, 0.0f, 1.0f) * 3.14159274101257324f / 2.0f;
        float _S446 = (F32_min((toon_a_2 + toon_s_2), (1.57079637050628662f)));
        if(_S438)
        {
            toon_component_0 = 1.0f - (F32_cos(((F32_min((_S446), (toon_a_2))))));
        }
        else
        {
            float _S447 = (F32_sin(((F32_min((_S446), (toon_a_2))))));
            toon_component_0 = _S447 * _S447 / 2.0f;
        }
        bool _S448 = _S446 > toon_a_2;
        if(_S448)
        {
            _S441 = toon_s_2 > 0.0f;
        }
        else
        {
            _S441 = false;
        }
        if(_S441)
        {
            if(_S438)
            {
                float _S449 = (F32_cos((toon_a_2)));
                float _S450 = (F32_cos((_S446)));
                toon_a_1 = (1.0f + toon_a_2 / toon_s_2) * (_S449 - _S450) - ((F32_sin((_S446))) - _S446 * _S450 - ((F32_sin((toon_a_2))) - toon_a_2 * _S449)) / toon_s_2;
            }
            else
            {
                float _S451 = 2.0f * toon_a_2;
                float _S452 = (F32_cos((_S451)));
                float _S453 = 2.0f * _S446;
                float _S454 = (F32_cos((_S453)));
                toon_a_1 = (1.0f + toon_a_2 / toon_s_2) * (_S452 - _S454) / 4.0f - ((F32_sin((_S453))) / 8.0f - _S446 * _S454 / 4.0f - ((F32_sin((_S451))) / 8.0f - toon_a_2 * _S452 / 4.0f)) / toon_s_2;
            }
            float integral_0 = toon_component_0 + toon_a_1;
            toon_component_0 = integral_0;
        }
        float _S455 = 6.28318548202514648f * toon_component_0;
        float _S456 = dot_0(n_i_3, v_4);
        float _S457 = (F32_acos(((F32_min((_S456), (1.0f))))));
        if(_S457 < toon_a_2)
        {
            toon_component_0 = 1.0f;
        }
        else
        {
            toon_component_0 = (F32_max((1.0f - (_S457 - toon_a_2) / (F32_max((toon_s_2), (0.0000152587890625f)))), (0.0f)));
        }
        if(_S438)
        {
            float3  _S458 = make_float3 (2.0f * _S456) * n_i_3 - v_4;
            float3  _S459 = ((((_S458)) * make_float3(rnorm3df(((_S458)).x, ((_S458)).y, ((_S458)).z))));
            scale_1 = _S459;
        }
        else
        {
            scale_1 = n_i_3;
        }
        float _S460 = toon_component_0;
        toon_component_0 = _S444;
        toon_1 = _S445;
        toon_a_1 = toon_a_2;
        toon_s_1 = toon_s_2;
        toon_b_1 = _S446;
        toon_norm_1 = _S455;
        toon_view_1 = _S460;
        toon_axis_1 = scale_1;
        scale_1 = scale_2;
    }
    else
    {
        toon_component_0 = 0.0f;
        toon_1 = _S431;
        toon_a_1 = 0.0f;
        toon_s_1 = 0.0f;
        toon_b_1 = 0.0f;
        toon_norm_1 = 1.0f;
        toon_view_1 = 0.0f;
        toon_axis_1 = n_i_3;
    }
    float3  _S461 = mix_0(_S428, material_3.albedo, material_3.metallic);
    float3  F_1 = _S461 * scale_1;
    float _S462 = rgb_to_greyscale(F_1);
    float _S463 = 1.0f - material_3.metallic;
    float3  _S464 = make_float3 (1.0f) - _S428;
    float3  _S465 = make_float3 ((1.0f - material_3.transmission) * _S463) * _S464 * scale_1;
    float3  _S466 = make_float3 (material_3.transmission * _S463) * _S464 * scale_1;
    float _S467 = (F32_max((_S462), (0.0f)));
    float _S468 = rgb_to_greyscale(_S465);
    float _S469 = (F32_max((_S468), (0.0f)));
    float _S470 = rgb_to_greyscale(_S466);
    float _S471 = sign_0(length_0(_S420));
    float _S472 = (F32_max((_S470 * _S471), (0.0f)));
    float _S473 = _S467 + _S469 + _S472 + toon_component_0;
    float _S474 = (F32_min((sheen_component_0), (1.0f)));
    bool _S475 = sheen_component_0 > 0.0f;
    if(_S475)
    {
        _S441 = !(_S473 > 0.0f);
    }
    else
    {
        _S441 = false;
    }
    float _S476 = _slang_select(_S441, 1.0f,_S474);
    float _S477 = (1.0f - _S476) / (F32_max((_S473), (0.0000152587890625f)));
    float _S478 = _S469 * _S477;
    float _S479 = _S467 * _S477;
    float _S480 = _S472 * _S477;
    bool _S481 = (frame_2.alphas.x) > 0.0f;
    float visible_1;
    if(_S481)
    {
        float3  _S482 = anisotropicLocal(v_4, frame_2.tangent, n_i_3);
        float _S483 = anisotropicG1(_S482, frame_2.alphas);
        float3  _S484 = anisotropicLocal(ggx_n_0, frame_2.tangent, n_i_3);
        float _S485 = anisotropicD(_S484, frame_2.alphas);
        float _S486 = _S483 * _S485;
        visible_1 = _S486;
    }
    else
    {
        visible_1 = 0.0f;
    }
    return BSDFLobes_x24init_0(_S416, _S417, _S420, F_1, _S462, 1.0f, _S465, _S466, _S478, _S479, _S480, 0.0f, sheen_1, _S476, view_1, frame_2.tangent, frame_2.alphas, visible_1, toon_component_0 * _S477, toon_1, toon_a_1, toon_s_1, toon_b_1, _S438, toon_norm_1, toon_view_1, toon_axis_1);
}

__device__ float translucentShare(BSDFMaterial material_4)
{
    float _S487 = rgb_to_greyscale(material_4.translucent);
    float _S488 = rgb_to_greyscale(material_4.albedo);
    float _S489 = _S487 / (_S488 + _S487);
    bool _S490 = _S487 > 0.0f;
    float _S491 = _slang_select(_S490, _S489,0.0f);
    return _S491;
}

__device__ __forceinline__ float diffusePDF(float n_i_dot_l_0, float l_dot_h_0, float n_i_dot_v_0, float alpha_2, BSDFLobes lobes_0, float eta_i_3, float eta_o_3)
{
    float _S492 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    float _S493 = lobes_0.p_diffuse * (F32_abs((n_i_dot_l_0))) * 0.31830987334251404f;
    float _S494 = 1.0f - lobes_0.translucent_share;
    bool _S495 = n_i_dot_l_0 < 0.0f;
    float _S496 = _slang_select(_S495, lobes_0.translucent_share,_S494);
    float _S497 = _S493 * _S496;
    bool _S498 = (lobes_0.translucent_share) > 0.0f;
    float _S499 = _slang_select(_S498, _S497,_S492);
    bool _S500 = n_i_dot_v_0 > 0.0f;
    float _S501 = _slang_select(_S500, _S499,0.0f);
    return _S501;
}

__device__ __forceinline__ float3  diffuseBSDF(float3  l_0, float3  n_i_4, float alpha_3, BSDFMaterial material_5, BSDFLobes lobes_1)
{
    bool _S502 = (dot_0(n_i_4, l_0)) < 0.0f;
    float3  _S503 = _slang_select(_S502, material_5.translucent,material_5.albedo);
    float _S504 = 1.0f - lobes_1.translucent_share;
    float _S505 = _slang_select(_S502, lobes_1.translucent_share,_S504);
    float3  _S506 = _S503 / make_float3 (_S505);
    bool _S507 = (lobes_1.translucent_share) > 0.0f;
    float3  _S508 = _slang_select(_S507, _S506,material_5.albedo);
    return lobes_1.diffuse_weight * _S508 / make_float3 (lobes_1.p_diffuse);
}

__device__ float smithG1(float alpha_4, float n_dot_x_0)
{
    float _S509 = alpha_4 * alpha_4;
    float _S510 = 2.0f * n_dot_x_0 / (n_dot_x_0 + (F32_sqrt((_S509 + (1.0f - _S509) * n_dot_x_0 * n_dot_x_0))));
    bool _S511 = alpha_4 > 0.0f;
    float _S512 = _slang_select(_S511, _S510,1.0f);
    return _S512;
}

__device__ float trowbridgeReitz(float alpha_5, float n_dot_h_1)
{
    float _S513 = alpha_5 * alpha_5;
    float _S514 = (1.0f - n_dot_h_1) * (1.0f + n_dot_h_1) + _S513 * n_dot_h_1 * n_dot_h_1;
    return _S513 / (F32_max((3.14159274101257324f * _S514 * _S514), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ float vndfPDF(float n_i_dot_v_1, float alpha_6, BSDFLobes lobes_2)
{
    float _S515 = smithG1(alpha_6, n_i_dot_v_1);
    float _S516 = _S515 * lobes_2.v_dot_h;
    float _S517 = trowbridgeReitz(alpha_6, lobes_2.n_dot_h);
    float _S518 = _S516 * _S517 / n_i_dot_v_1;
    bool _S519 = alpha_6 > 0.0f;
    bool _S520;
    if(_S519)
    {
        _S520 = (lobes_2.v_dot_h) > 0.0f;
    }
    else
    {
        _S520 = false;
    }
    if(_S520)
    {
        _S520 = (lobes_2.n_dot_h) > 0.0f;
    }
    else
    {
        _S520 = false;
    }
    if(_S520)
    {
        _S520 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S520 = false;
    }
    float _S521 = _slang_select(_S520, _S518,0.0f);
    bool _S522 = (lobes_2.alphas.x) > 0.0f;
    float pdf_h_0;
    if(_S522)
    {
        float _S523 = lobes_2.visible * lobes_2.v_dot_h / n_i_dot_v_1;
        bool _S524 = (lobes_2.v_dot_h) > 0.0f;
        if(_S524)
        {
            _S520 = (lobes_2.n_dot_h) > 0.0f;
        }
        else
        {
            _S520 = false;
        }
        if(_S520)
        {
            _S520 = n_i_dot_v_1 > 0.0f;
        }
        else
        {
            _S520 = false;
        }
        float _S525 = _slang_select(_S520, _S523,0.0f);
        pdf_h_0 = _S525;
    }
    else
    {
        pdf_h_0 = _S521;
    }
    return pdf_h_0;
}

__device__ __forceinline__ float refractPDF(float n_i_dot_l_1, float l_dot_h_1, float n_i_dot_v_2, float alpha_7, BSDFLobes lobes_3, float eta_i_4, float eta_o_4)
{
    float _S526 = vndfPDF(n_i_dot_v_2, alpha_7, lobes_3);
    float _S527 = eta_i_4 * lobes_3.v_dot_h + eta_o_4 * l_dot_h_1;
    float _S528 = lobes_3.p_refract * _S526 * eta_o_4 * eta_o_4 * (F32_abs((l_dot_h_1))) / (_S527 * _S527);
    bool _S529 = eta_i_4 != eta_o_4;
    bool _S530;
    if(_S529)
    {
        _S530 = l_dot_h_1 < 0.0f;
    }
    else
    {
        _S530 = false;
    }
    float _S531 = _slang_select(_S530, _S528,0.0f);
    return _S531;
}

__device__ __forceinline__ float3  refractBSDF(float3  l_1, float3  n_i_5, float alpha_8, BSDFMaterial material_6, BSDFLobes lobes_4)
{
    float _S532 = - dot_0(n_i_5, l_1);
    float _S533 = smithG1(alpha_8, (F32_max((_S532), (0.0f))));
    bool _S534 = (lobes_4.alphas.x) > 0.0f;
    float G1_l_0;
    if(_S534)
    {
        float3  _S535 = negate_0(n_i_5);
        float3  _S536 = anisotropicLocal(l_1, lobes_4.tangent, _S535);
        float _S537 = anisotropicG1(_S536, lobes_4.alphas);
        G1_l_0 = _S537;
    }
    else
    {
        G1_l_0 = _S533;
    }
    return lobes_4.refract_weight * make_float3 (G1_l_0) * material_6.albedo / make_float3 (lobes_4.p_refract);
}

__device__ __forceinline__ float sheenVelvetPDF(float n_i_dot_l_2, float l_dot_h_2, float n_i_dot_v_3, float alpha_9, BSDFLobes lobes_5, float eta_i_5, float eta_o_5)
{
    float _S538 = lobes_5.p_sheen_velvet * 0.5f * 0.31830987334251404f;
    bool _S539 = n_i_dot_l_2 > 0.0f;
    bool _S540;
    if(_S539)
    {
        _S540 = n_i_dot_v_3 > 0.0f;
    }
    else
    {
        _S540 = false;
    }
    float _S541 = _slang_select(_S540, _S538,0.0f);
    return _S541;
}

__device__ __forceinline__ float3  sheenVelvetBSDF(float3  l_2, float3  n_i_6, float alpha_10, BSDFMaterial material_7, BSDFLobes lobes_6)
{
    float3  _S542 = l_2 + lobes_6.view;
    float3  _S543 = ((((_S542)) * make_float3(rnorm3df(((_S542)).x, ((_S542)).y, ((_S542)).z))));
    float _S544 = dot_0(n_i_6, _S543);
    float _S545 = (F32_max((dot_0(n_i_6, l_2)), (0.0f)));
    float _S546 = (F32_max((dot_0(n_i_6, lobes_6.view)), (0.0f)));
    float _S547 = 1.0f / (F32_max((material_7.sheen_roughness), (0.05000000074505806f)));
    float _S548 = 1.0f - _S544 * _S544;
    float _S549 = (2.0f + _S547) * (F32_pow(((F32_max((_S548), (0.0f)))), (0.5f * _S547))) * 0.5f * 0.31830987334251404f / (F32_max((4.0f * (_S545 + _S546 - _S545 * _S546)), (0.0000152587890625f)));
    bool _S550 = (material_7.velvet) > 0.0f;
    float f_1;
    if(_S550)
    {
        float _S551 = (F32_max((material_7.sheen_roughness), (0.00999999977648258f)));
        float _S552 = _S551 * _S551;
        float _S553 = (F32_max((_S548), (0.0000152587890625f)));
        float _S554 = (F32_exp((- _S544 * _S544 / (_S553 * _S552)))) / (3.14159274101257324f * _S552 * _S553 * _S553) * (F32_min((1.0f), (2.0f * _S544 * (F32_min((_S545), (_S546))) / (F32_max(((F32_abs((dot_0(_S543, lobes_6.view))))), (0.0000152587890625f)))))) / (F32_max((4.0f * _S545 * _S546), (0.0000152587890625f)));
        f_1 = _S554;
    }
    else
    {
        f_1 = _S549;
    }
    return lobes_6.sheen * make_float3 (f_1 * _S545 * 2.0f * 3.14159274101257324f / lobes_6.p_sheen_velvet);
}

__device__ __forceinline__ float toonPDF(float n_i_dot_l_3, float l_dot_h_3, float n_i_dot_v_4, float alpha_11, BSDFLobes lobes_7, float eta_i_6, float eta_o_6)
{
    float _S555 = _slang_select(lobes_7.toon_glossy, l_dot_h_3,n_i_dot_l_3);
    float _S556 = (F32_acos((clamp_1(_S555, -1.0f, 1.0f))));
    float _S557;
    if(_S556 < (lobes_7.toon_a))
    {
        _S557 = 1.0f;
    }
    else
    {
        _S557 = (F32_max((1.0f - (_S556 - lobes_7.toon_a) / (F32_max((lobes_7.toon_s), (0.0000152587890625f)))), (0.0f)));
    }
    float _S558 = lobes_7.p_toon * _S557;
    float _S559 = _slang_select(lobes_7.toon_glossy, 1.0f,n_i_dot_l_3);
    float _S560 = _S558 * _S559 / lobes_7.toon_norm;
    bool _S561;
    if(lobes_7.toon_glossy)
    {
        _S561 = true;
    }
    else
    {
        _S561 = n_i_dot_l_3 > 0.0f;
    }
    float _S562 = _slang_select(_S561, _S560,0.0f);
    return _S562;
}

__device__ __forceinline__ float3  toonBSDF(float3  l_3, float3  n_i_7, float alpha_12, BSDFMaterial material_8, BSDFLobes lobes_8)
{
    float _S563 = (F32_max((dot_0(n_i_7, l_3)), (0.0f)));
    float _S564 = _slang_select(lobes_8.toon_glossy, _S563,lobes_8.toon_view);
    return lobes_8.toon * make_float3 (_S564) / make_float3 (lobes_8.p_toon);
}

__device__ __forceinline__ float reflectPDF(float n_i_dot_l_4, float l_dot_h_4, float n_i_dot_v_5, float alpha_13, BSDFLobes lobes_9, float eta_i_7, float eta_o_7)
{
    float _S565 = vndfPDF(n_i_dot_v_5, alpha_13, lobes_9);
    float _S566 = lobes_9.p_reflect * _S565 / (4.0f * lobes_9.v_dot_h);
    bool _S567 = _S565 > 0.0f;
    float _S568 = _slang_select(_S567, _S566,0.0f);
    return _S568;
}

__device__ __forceinline__ float3  reflectBSDF(float3  l_4, float3  n_i_8, float alpha_14, BSDFMaterial material_9, BSDFLobes lobes_10)
{
    float _S569 = dot_0(n_i_8, l_4);
    float _S570 = smithG1(alpha_14, (F32_max((_S569), (0.0f))));
    bool _S571 = (lobes_10.alphas.x) > 0.0f;
    float G1_l_1;
    if(_S571)
    {
        float3  _S572 = anisotropicLocal(l_4, lobes_10.tangent, n_i_8);
        float _S573 = anisotropicG1(_S572, lobes_10.alphas);
        G1_l_1 = _S573;
    }
    else
    {
        G1_l_1 = _S570;
    }
    return make_float3 (lobes_10.reflect_weight * G1_l_1) * lobes_10.F / make_float3 (lobes_10.p_reflect);
}

__device__ __forceinline__ float3  BSDF(float3  in_dir_4, float3  out_dir_2, float3  n_7, BSDFMaterial material_10, float eta_i_8, float eta_o_8, bool refracted_2, uint random_state_4, FixedArray<float3 , 5>  * throughputs_0, FixedArray<float, 5>  * pdfs_0)
{
    float3  ggx_n_1;
    float3  _S574 = negate_0(in_dir_4);
    float _S575 = dot_0(n_7, _S574);
    float _S576 = sign_0(_S575);
    float3  _S577 = n_7 * make_float3 (_S576);
    AnisotropicFrame _S578 = anisotropicFrame(material_10, _S577);
    float _S579 = dot_0(_S577, out_dir_2);
    float _S580 = material_10.roughness;
    float _S581 = _S580 * _S580;
    SheenProfile _S582 = sheenProfile(_S574, _S577, material_10);
    float _S583 = rgb_to_greyscale(material_10.translucent);
    bool _S584 = _S583 > 0.0f;
    bool _S585 = (dot_0(n_7, out_dir_2) * _S575) < 0.0f;
    uint _S586;
    if((F32_abs((material_10.toon.x))) > 0.0f)
    {
        _S586 = 5U;
    }
    else
    {
        _S586 = 4U;
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
        float3  _S587 = make_float3 (0.0f);
        (*throughputs_0)[i_6] = _S587;
        (*pdfs_0)[i_6] = 0.0f;
        uint i_7 = i_6 + 1U;
        i_6 = i_7;
    }
    float3  _S588 = make_float3 (0.0f);
    BSDFLobes _S589 = BSDFLobes_x24init_0(0.0f, 0.0f, _S588, _S588, 0.0f, 0.0f, _S588, _S588, 0.0f, 0.0f, 0.0f, 0.0f, _S588, 0.0f, _S588, _S588, make_float2 (0.0f), 0.0f, 0.0f, _S588, 0.0f, 0.0f, 0.0f, false, 1.0f, 0.0f, _S588);
    BSDFLobes lobe_terms_0 = _S589;
    uint half_of_0 = 4294967295U;
    float3  ggx_n_2 = _S588;
    i_6 = 0U;
    for(;;)
    {
        if(i_6 < _S586)
        {
        }
        else
        {
            break;
        }
        uint _S590;
        if(i_6 == 3U)
        {
            _S590 = 4U;
        }
        else
        {
            if(i_6 == 4U)
            {
                _S590 = 6U;
            }
            else
            {
                _S590 = i_6;
            }
        }
        bool _S591 = _S590 == 0U;
        bool _S592;
        if(_S591)
        {
            _S592 = _S584;
        }
        else
        {
            _S592 = false;
        }
        bool _S593;
        if(_S592)
        {
            _S593 = _S585;
        }
        else
        {
            _S593 = _S590 == 1U;
        }
        bool _S594 = _S593 != refracted_2;
        if(_S594)
        {
            ggx_n_1 = ggx_n_2;
            uint i_8 = i_6 + 1U;
            ggx_n_2 = ggx_n_1;
            i_6 = i_8;
            continue;
        }
        uint _S595;
        if(_S590 == 6U)
        {
            _S595 = 0U;
        }
        else
        {
            if(_S590 == 4U)
            {
                _S595 = 2U;
            }
            else
            {
                _S595 = _S590;
            }
        }
        bool _S596 = _S595 != half_of_0;
        uint half_of_1;
        if(_S596)
        {
            bool _S597 = _S595 == 0U;
            if(_S597)
            {
                float3  _S598 = sampledHalf(in_dir_4, n_7, material_10, random_state_4, _S578);
                ggx_n_1 = _S598;
            }
            else
            {
                bool _S599 = _S595 == 1U;
                if(_S599)
                {
                    float3  _S600 = refractedHalf(in_dir_4, out_dir_2, n_7, eta_i_8, eta_o_8);
                    ggx_n_1 = _S600;
                }
                else
                {
                    float3  _S601 = reflectedHalf(in_dir_4, out_dir_2);
                    ggx_n_1 = _S601;
                }
            }
            float3  _S602 = negate_0(in_dir_4);
            BSDFLobes _S603 = bsdfLobes(in_dir_4, _S602, _S577, ggx_n_1, material_10, eta_i_8, eta_o_8, _S578, _S582);
            lobe_terms_0 = _S603;
            float _S604 = translucentShare(material_10);
            (&lobe_terms_0)->translucent_share = _S604;
            half_of_1 = _S595;
        }
        else
        {
            ggx_n_1 = ggx_n_2;
            half_of_1 = half_of_0;
        }
        switch(_S590)
        {
        case 0U:
            {
                float _S605 = diffusePDF(_S579, 0.0f, (F32_abs((_S575))), _S581, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(0)] = _S605;
                float3  _S606 = diffuseBSDF(out_dir_2, _S577, _S581, material_10, lobe_terms_0);
                (*throughputs_0)[int(0)] = _S606;
                break;
            }
        case 1U:
            {
                float _S607 = refractPDF(_S579, dot_0(out_dir_2, ggx_n_1), (F32_abs((_S575))), _S581, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(1)] = _S607;
                float3  _S608 = refractBSDF(out_dir_2, _S577, _S581, material_10, lobe_terms_0);
                (*throughputs_0)[int(1)] = _S608;
                break;
            }
        case 4U:
            {
                float _S609 = sheenVelvetPDF(_S579, 0.0f, (F32_abs((_S575))), _S581, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(3)] = _S609;
                float3  _S610 = sheenVelvetBSDF(out_dir_2, _S577, _S581, material_10, lobe_terms_0);
                (*throughputs_0)[int(3)] = _S610;
                break;
            }
        case 6U:
            {
                float _S611 = toonPDF(_S579, dot_0(out_dir_2, (&lobe_terms_0)->toon_axis), (F32_abs((_S575))), _S581, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(4)] = _S611;
                float3  _S612 = toonBSDF(out_dir_2, _S577, _S581, material_10, lobe_terms_0);
                (*throughputs_0)[int(4)] = _S612;
                break;
            }
        default:
            {
                float _S613 = reflectPDF(_S579, 0.0f, (F32_abs((_S575))), _S581, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(2)] = _S613;
                float3  _S614 = reflectBSDF(out_dir_2, _S577, _S581, material_10, lobe_terms_0);
                (*throughputs_0)[int(2)] = _S614;
                break;
            }
        }
        half_of_0 = half_of_1;
        uint i_8 = i_6 + 1U;
        ggx_n_2 = ggx_n_1;
        i_6 = i_8;
    }
    i_6 = 0U;
    ggx_n_1 = _S588;
    for(;;)
    {
        if(i_6 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S615 = ((*pdfs_0)[i_6]) > 0.0f;
        if(_S615)
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
    bool _S616 = wrongSide_0(is_inside_2, false, dir_3, surface_1->geometry_n);
    float3  _S617 = BSDF(in_dir_5, dir_3, surface_1->smooth_n, surface_1->material, eta_1.x, eta_1.y, _S616, random_state_5, terms_0, pdfs_1);
    float3  _S618 = make_float3 (0.0f);
    uint i_10 = 0U;
    float3  f_3 = _S618;
    for(;;)
    {
        if(i_10 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S619 = ((*pdfs_1)[i_10]) > 0.0f;
        if(_S619)
        {
            float3  _S620 = (*terms_0)[i_10] * make_float3 ((*pdfs_1)[i_10]) / make_float3 ((*pdfs_1)[i_10] + pdf_0);
            (*terms_0)[i_10] = _S620;
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
    FKSurface _S621 = surface_2;
    FixedArray<float3 , 5>  terms_1;
    FixedArray<float, 5>  pdfs_2;
    float3  _S622 = skyLobes_0(in_dir_6, dir_4, &_S621, eta_2, is_inside_3, pdf_1, random_state_6, &terms_1, &pdfs_2);
    return _S622;
}

static __device__ SkySample SkySample_x24init_0(float3  dir_5, float3  radiance_0, float3  color_0, uint random_state_7)
{
    SkySample _S623;
    (&_S623)->dir = dir_5;
    (&_S623)->radiance = radiance_0;
    (&_S623)->color = color_0;
    (&_S623)->random_state = random_state_7;
    return _S623;
}

static __device__ SkySample sampleSky_0(FKRay * ray_0, FKSurface * surface_3, float2  eta_3, bool is_inside_4, uint init_random_state_0, uint lobe_state_0, ShadowContext * context_2)
{
    uint2  _S624 = (fcptEnvironmentCdfSize());
    uint2  _S625 = make_uint2 (1U, 0U);
    uint2  _S626 = _S624 - _S625;
    Random _S627 = pcg(init_random_state_0);
    Random _S628 = pcg(_S627.state);
    Random _S629 = pcg(_S628.state);
    Random _S630 = pcg(_S629.state);
    uint _S631 = _S626.x;
    uint _S632 = searchCDF_0(make_uint2 (_S631, 0U), make_uint2 (0U, 1U), _S626.y, _S627.value);
    uint _S633 = searchCDF_0(make_uint2 (0U, _S632), _S625, _S631, _S628.value);
    float2  _S634 = make_float2 ((float)_S626.x, (float)_S626.y);
    float2  _S635 = (make_float2 (float(_S633), float(_S632)) + make_float2 (_S629.value, _S630.value)) / _S634 * make_float2 (6.28318548202514648f, 3.14159274101257324f);
    float _S636 = _S635.y;
    float _S637 = (F32_sin((_S636)));
    float _S638 = _S635.x;
    float3  _S639 = make_float3 (- _S637 * (F32_cos((_S638))), _S637 * (F32_sin((_S638))), (F32_cos((_S636))));
    float _S640 = environmentPdf_0(_S639);
    float3  _S641 = skyBSDF(ray_0->unit_direction, _S639, *surface_3, eta_3, is_inside_4, _S640, lobe_state_0);
    bool _S642 = !(_S640 > 0.0f);
    bool _S643;
    if(_S642)
    {
        _S643 = true;
    }
    else
    {
        _S643 = all_1(_S641 == make_float3 (0.0f));
    }
    if(_S643)
    {
        float3  _S644 = make_float3 (0.0f);
        return SkySample_x24init_0(_S639, _S644, _S644, _S630.state);
    }
    float3  _S645 = skyRadiance_0(ray_0->origin, surface_3, is_inside_4, _S639, context_2, _S630.state);
    return SkySample_x24init_0(_S639, _S645, _S641 * _S645, _S630.state);
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
    SampleBSDF _S646 = (fcptConnectHair((surface_4->hair), ((&surface_4->material)->albedo), ((&surface_4->material)->specular_tint), (in_dir_7), (light_1->dir)));
    float3  _S647 = _S646.throughput * make_float3 (_S646.pdf);
    float _S648 = light_1->density;
    float _S649 = 1.0f + _S646.pdf * _S646.pdf / (light_1->density * light_1->density);
    bool _S650;
    if(competing_0)
    {
        _S650 = _S648 > 0.0f;
    }
    else
    {
        _S650 = false;
    }
    float _S651 = _slang_select(_S650, _S649,1.0f);
    return _S647 / make_float3 (_S651) * light_1->radiance;
}

static __device__ TreeSample TreeSample_x24init_0(float3  dir_6, float3  radiance_1, float density_0, uint random_state_8)
{
    TreeSample _S652;
    (&_S652)->dir = dir_6;
    (&_S652)->radiance = radiance_1;
    (&_S652)->density = density_0;
    (&_S652)->random_state = random_state_8;
    return _S652;
}

__device__ uint pickChild(LightNode first_1, LightNode second_1, float3  p_10, float3  normal_3, float * pick_0, float * probability_3)
{
    float _S653 = importance(first_1, p_10, normal_3);
    float _S654 = importance(second_1, p_10, normal_3);
    float2  _S655 = make_float2 (_S653, _S654);
    bool _S656 = _S653 == 0.0f;
    bool _S657;
    if(_S656)
    {
        _S657 = _S654 == 0.0f;
    }
    else
    {
        _S657 = false;
    }
    if(_S657)
    {
        return 2U;
    }
    float _S658 = _S653 + _S654;
    bool _S659 = _S654 > 0.0f;
    if(_S659)
    {
        _S657 = (*pick_0 * _S658) >= _S653;
    }
    else
    {
        _S657 = false;
    }
    uint _S660 = uint(_S657);
    float _S661 = (F32_min(((*pick_0 * _S658 - float(_S660) * _S653) / _slang_vector_get_element(_S655, _S660)), (0.99999994039535522f)));
    *pick_0 = _S661;
    float _S662 = *probability_3 * (_slang_vector_get_element(_S655, _S660) / _S658);
    *probability_3 = _S662;
    return _S660;
}

__device__ float3  sampleSphere(float3  center_1, float radius_1, float3  p_11, float u1_0, float u2_0)
{
    float3  _S663 = center_1 - p_11;
    float _S664 = radius_1 * radius_1 / dot_0(_S663, _S663);
    float _S665 = u1_0 * _S664 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S664), (0.0f)))))));
    float _S666 = 2.0f * u1_0;
    bool _S667 = _S664 >= 1.0f;
    float _S668 = _slang_select(_S667, _S666,_S665);
    float _S669 = (F32_sqrt(((F32_max((_S668 * (2.0f - _S668)), (0.0f))))));
    float _S670 = 6.28318548202514648f * u2_0;
    float3  _S671 = make_float3 (_S669 * (F32_cos((_S670))), 1.0f - _S668, _S669 * (F32_sin((_S670))));
    float3  _S672 = ((((_S663)) * make_float3(rnorm3df(((_S663)).x, ((_S663)).y, ((_S663)).z))));
    float3  _S673 = tangentToWorld(_S671, _S672);
    return _S673;
}

__device__ float3  pointLightRadiance(float3  color_1, float intensity_0, float radius_2)
{
    return color_1 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_2 * radius_2);
}

static __device__ float raySphere_0(float3  center_2, float radius_3, FKRay * ray_1, float max_len_0)
{
    float3  _S674 = center_2 - ray_1->origin;
    float _S675 = dot_0(_S674, ray_1->unit_direction);
    float _S676 = dot_0(_S674, _S674) - _S675 * _S675;
    float _S677 = radius_3 * radius_3;
    bool _S678 = _S676 > _S677;
    if(_S678)
    {
        return 4.294967296e+09f;
    }
    float _S679 = (F32_sqrt((_S677 - _S676)));
    float _S680 = _S675 - _S679;
    float _S681 = _S675 + _S679;
    bool _S682 = _S680 > 0.0000152587890625f;
    bool _S683;
    if(_S682)
    {
        _S683 = _S680 < max_len_0;
    }
    else
    {
        _S683 = false;
    }
    if(_S683)
    {
        return _S680;
    }
    bool _S684 = _S681 > 0.0000152587890625f;
    if(_S684)
    {
        _S683 = _S681 < max_len_0;
    }
    else
    {
        _S683 = false;
    }
    if(_S683)
    {
        return _S681;
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
    Random _S685 = pcg(init_random_state_1);
    Random _S686 = pcg(_S685.state);
    Random _S687 = pcg(_S686.state);
    float3  _S688 = make_float3 (0.0f);
    TreeSample _S689 = TreeSample_x24init_0(_S688, _S688, 0.0f, _S687.state);
    TreeSample sample_0 = _S689;
    float3  _S690 = _slang_select(sided_0, _S688,smooth_n_2);
    float3  _S691 = origin_4 + make_float3 (geometry_offset_1) * smooth_n_2;
    float pick_1 = _S685.value;
    float probability_4 = 1.0f;
    uint n_8 = 0U;
    for(;;)
    {
        uint4  _S692 = (fcptLightNode((n_8)));
        if((_S692.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S693 = (fcptLightSecond((n_8)));
        uint _S694 = n_8 + 1U;
        LightNode _S695 = (fcptLightBounds((_S694)));
        LightNode _S696 = (fcptLightBounds((_S693)));
        uint _S697 = pickChild(_S695, _S696, origin_4, _S690, &pick_1, &probability_4);
        bool _S698 = _S697 > 1U;
        if(_S698)
        {
            return sample_0;
        }
        bool _S699 = _S697 == 1U;
        uint _S700 = _slang_select(_S699, _S693,_S694);
        n_8 = _S700;
    }
    bool _S701 = n_8 == 0U;
    bool _S702;
    if(_S701)
    {
        LightNode _S703 = (fcptLightBounds((0U)));
        float _S704 = importance(_S703, origin_4, _S690);
        _S702 = !(_S704 > 0.0f);
    }
    else
    {
        _S702 = false;
    }
    if(_S702)
    {
        return sample_0;
    }
    uint4  _S705 = (fcptLightNode((n_8)));
    FKHit _S706 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    bool _S707 = (_S705.x) == 2U;
    float3  emitter_point_0;
    float3  lift_n_0;
    float3  shadow_1;
    FKHit emitter_0;
    if(_S707)
    {
        FKLight _S708 = (fcptLight((_S705.y)));
        if(sided_0)
        {
            float _S709 = sign_0(dot_0(geometry_n_1, _S708.position - origin_4));
            float3  lift_n_1 = smooth_n_2 * make_float3 (_S709);
            float3  _S710 = origin_4 + make_float3 (geometry_offset_1) * lift_n_1;
            emitter_point_0 = _S710;
            lift_n_0 = lift_n_1;
        }
        else
        {
            emitter_point_0 = _S691;
            lift_n_0 = smooth_n_2;
        }
        bool _S711 = (_S708.variance) == 0.0f;
        if(_S711)
        {
            float3  _S712 = _S708.position - emitter_point_0;
            float3  _S713 = ((((_S712)) * make_float3(rnorm3df(((_S712)).x, ((_S712)).y, ((_S712)).z))));
            (&sample_0)->dir = _S713;
            float3  _S714 = _S708.color * make_float3 (_S708.intensity) / make_float3 (dot_0(_S712, _S712) * probability_4);
            (&sample_0)->radiance = _S714;
            shadow_1 = _S712;
        }
        else
        {
            float3  _S715 = sampleSphere(_S708.position, _S708.variance, emitter_point_0, _S686.value, _S687.value);
            (&sample_0)->dir = _S715;
            float _S716 = sphereDensity(_S708.position, _S708.variance, emitter_point_0);
            float _S717 = probability_4 * _S716;
            (&sample_0)->density = _S717;
            float3  _S718 = pointLightRadiance(_S708.color, _S708.intensity, _S708.variance);
            float3  _S719 = _S718 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S719;
            FKRay _S720 = Ray_x24init_0(emitter_point_0, (&sample_0)->dir);
            float _S721 = raySphere_0(_S708.position, _S708.variance, &_S720, 4.294967296e+09f);
            float3  _S722 = (&sample_0)->dir * make_float3 (_S721);
            shadow_1 = _S722;
        }
        emitter_0 = _S706;
        emitter_point_0 = _S688;
    }
    else
    {
        uint _S723 = _S705.y;
        uint _S724 = (fcptTriangleOffset((_S723)));
        uint _S725 = _S724 + _S705.z;
        Matrix<float, 3, 3>  _S726 = (fcptWorldTriangle((_S723), (_S725)));
        float _S727 = (F32_sqrt((_S686.value)));
        float2  _S728 = make_float2 (_S727 * (1.0f - _S687.value), _S727 * _S687.value);
        float3  _S729 = mul_0(make_float3 (1.0f - _S727, _S728.x, _S728.y), _S726);
        if(sided_0)
        {
            float _S730 = sign_0(dot_0(geometry_n_1, _S729 - origin_4));
            float3  lift_n_2 = smooth_n_2 * make_float3 (_S730);
            float3  _S731 = origin_4 + make_float3 (geometry_offset_1) * lift_n_2;
            emitter_point_0 = _S731;
            lift_n_0 = lift_n_2;
        }
        else
        {
            bool _S732 = !((dot_0(smooth_n_2, _S729 - origin_4)) > 0.0f);
            if(_S732)
            {
                return sample_0;
            }
            emitter_point_0 = _S691;
            lift_n_0 = smooth_n_2;
        }
        FKHit emitter_1 = Hit_x24init_0(_S728, _S723, _S725, 0U, 0.0f);
        float3  _S733 = _S729 - emitter_point_0;
        float3  _S734 = ((((_S733)) * make_float3(rnorm3df(((_S733)).x, ((_S733)).y, ((_S733)).z))));
        (&sample_0)->dir = _S734;
        float _S735 = solidAngle(probability_4, cross_0(_S726.rows[int(1)] - _S726.rows[int(0)], _S726.rows[int(2)] - _S726.rows[int(0)]), _S733);
        (&sample_0)->density = _S735;
        bool _S736 = (fcptShadowFirst());
        bool _S737 = !_S736;
        if(_S737)
        {
            FKSurface _S738 = (fcptLightSurfaceAt((emitter_1), (_S729), (_S687.state), ((&sample_0)->dir), (context_3->depth), (length_0(_S729 - origin_4))));
            (&sample_0)->random_state = _S738.random_state;
            float3  _S739 = _slang_select(_S738.skip, _S688,_S738.material.emissive);
            float3  _S740 = _S739 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S740;
        }
        shadow_1 = _S733;
        emitter_0 = emitter_1;
        emitter_point_0 = _S729;
    }
    FKHit _S741 = emitter_0;
    float3  _S742 = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, context_3, _S687.state, &_S741);
    bool _S743 = (fcptShadowFirst());
    if(_S743)
    {
        _S702 = (emitter_0.instance_index) != 4294967295U;
    }
    else
    {
        _S702 = false;
    }
    if(_S702)
    {
        _S702 = !all_1(_S742 == _S688);
    }
    else
    {
        _S702 = false;
    }
    if(_S702)
    {
        FKSurface _S744 = (fcptLightSurfaceAt((emitter_0), (emitter_point_0), (_S687.state), ((&sample_0)->dir), (context_3->depth), (length_0(emitter_point_0 - origin_4))));
        (&sample_0)->random_state = _S744.random_state;
        float3  _S745 = _slang_select(_S744.skip, _S688,_S744.material.emissive);
        float3  _S746 = _S745 / make_float3 ((&sample_0)->density);
        (&sample_0)->radiance = _S746;
    }
    float3  _S747 = (&sample_0)->radiance * _S742;
    bool _S748 = all_1(_S742 == _S688);
    float3  _S749 = _slang_select(_S748, _S688,_S747);
    (&sample_0)->radiance = _S749;
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
    float _S750 = 1.0f / (1.0f + b_1 / a_5 * (b_1 / a_5));
    bool _S751 = b_1 > 0.0f;
    float _S752 = _slang_select(_S751, _S750,1.0f);
    return _S752;
}

static __device__ float emissionWeight_0(NEEVertex * vertex_0, FKHit * hit_1, float3  light_point_1)
{
    bool _S753 = vertex_0->none;
    if(_S753)
    {
        return 1.0f;
    }
    uint _S754 = (fcptLightSlot((*hit_1)));
    float _S755 = lightPdf_0(vertex_0->origin, vertex_0->smooth_n, vertex_0->start, _S754, light_point_1);
    float _S756 = powerHeuristic(vertex_0->pdf, _S755);
    return _S756;
}

static __device__ float3  environment_0(float3  dir_7, uint depth_0, uint lobe_0)
{
    uint2  _S757 = (fcptEnvironmentMapSize());
    bool _S758 = (_S757.x) > 1U;
    bool _S759;
    if(_S758)
    {
        uint2  _S760 = (fcptEnvironmentMapSize());
        _S759 = (_S760.y) > 1U;
    }
    else
    {
        _S759 = false;
    }
    if(_S759)
    {
        float3  _S761 = (fcptEnvMapSample((dir_7), (depth_0), (lobe_0)));
        return _S761;
    }
    float3  _S762 = (fcptAmbient());
    return _S762;
}

static __device__ bool environmentMapped_0()
{
    uint2  _S763 = (fcptEnvironmentCdfSize());
    bool _S764 = (_S763.x) > 1U;
    bool _S765;
    if(_S764)
    {
        uint2  _S766 = (fcptEnvironmentCdfSize());
        _S765 = (_S766.y) > 1U;
    }
    else
    {
        _S765 = false;
    }
    bool _S767 = !_S765;
    if(_S767)
    {
        return false;
    }
    uint2  _S768 = (fcptEnvironmentMapSize());
    bool _S769 = (_S768.x) > 1U;
    if(_S769)
    {
        uint2  _S770 = (fcptEnvironmentMapSize());
        _S765 = (_S770.y) > 1U;
    }
    else
    {
        _S765 = false;
    }
    return _S765;
}

static __device__ float escapeWeight_0(float pdf_2, float3  dir_8)
{
    bool _S771 = pdf_2 <= 0.0f;
    bool _S772;
    if(_S771)
    {
        _S772 = true;
    }
    else
    {
        bool _S773 = environmentMapped_0();
        _S772 = !_S773;
    }
    if(_S772)
    {
        return 1.0f;
    }
    float _S774 = environmentPdf_0(dir_8);
    return pdf_2 / (pdf_2 + _S774);
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
    uint2  _S775 = uint2 {global_invocation_id_1.x, global_invocation_id_1.y};
    int2  _S776 = make_int2 ((int)_S775.x, (int)_S775.y);
    uint _S777 = previousSeed_0(_S776);
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
            uint _S778 = previousSeed_0(_S776 + make_int2 (x_16, y_5));
            bool _S779 = _S778 == _S777;
            uint _S780 = _slang_select(_S779, 1U,0U);
            uint count_3 = count_2 + _S780;
            int x_17 = x_16 + int(1);
            x_16 = x_17;
            count_2 = count_3;
        }
        int y_6 = y_5 + int(1);
        y_5 = y_6;
    }
    float _S781 = float(count_2 - 1U) / 288.0f;
    bool _S782 = _S777 != 0U;
    float _S783 = _slang_select(_S782, _S781,0.0f);
    fcptStoreDuplication((_S776), (make_uint4 ((F32_asuint((_S783))), 0U, 0U, 0U)));
    return;
}

__device__ uint stream(uint seed_2, uint index_0)
{
    uint _S784 = hash(index_0);
    uint _S785 = hash(seed_2 ^ _S784);
    return _S785;
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
    float _S786 = rgb_to_greyscale(weight_0);
    bool _S787 = _S786 > 0.0f;
    bool _S788;
    if(_S787)
    {
        _S788 = _S786 < 3.00000000549775576e+38f;
    }
    else
    {
        _S788 = false;
    }
    bool _S789 = !_S788;
    if(_S789)
    {
        return;
    }
    bool _S790 = sel_2->sums;
    if(_S790)
    {
        float3  _S791 = sel_2->color + weight_0;
        sel_2->color = _S791;
        return;
    }
    float _S792 = sel_2->w_sum + _S786;
    sel_2->w_sum = _S792;
    float3  _S793 = sel_2->color + weight_0;
    sel_2->color = _S793;
    Random _S794 = pcg(sel_2->random_state);
    sel_2->random_state = _S794.state;
    bool _S795 = (_S794.value * sel_2->w_sum) <= _S786;
    if(_S795)
    {
        sel_2->r = candidate_0;
    }
    return;
}

__device__ void offerShifted(Selection * sel_3, Reservoir r_3, Shift shifted_0, float mis_0)
{
    Reservoir candidate_1 = r_3;
    float3  _S796 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_1)->f = _S796;
    float _S797 = r_3.jac * shifted_0.jac;
    (&candidate_1)->jac = _S797;
    offer(sel_3, candidate_1, make_float3 (mis_0) * shifted_0.f * make_float3 (r_3.w));
    return;
}

__device__ Reservoir finalize(Selection sel_4, float c_1)
{
    Reservoir r_4 = sel_4.r;
    float _S798 = rgb_to_greyscale((&r_4)->f);
    float _S799 = sel_4.w_sum / _S798;
    bool _S800 = _S798 > 0.0f;
    float _S801 = _slang_select(_S800, _S799,0.0f);
    (&r_4)->w = _S801;
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
    uint2  _S802 = uint2 {global_invocation_id_2.x, global_invocation_id_2.y};
    int2  _S803 = make_int2 ((int)_S802.x, (int)_S802.y);
    float3  _S804 = make_float3 (0.0f);
    FKHit _S805 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S806 = Domain_x24init_0(_S804, _S804, &_S805, 0.0f, 0.0f);
    Domain dom_4 = _S806;
    bool _S807 = (fcptCurrentDomain((_S803), (&dom_4)));
    bool _S808 = !_S807;
    if(_S808)
    {
        Reservoir _S809 = (Reservoir{});
        fcptStoreReservoirPrevious((_S803), (_S809), ((&dom_4)->hit));
        return;
    }
    Reservoir _S810 = (fcptLoadReservoirTemporal((_S803)));
    uint t_13 = 0U;
    float count_4 = 0.0f;
    float c_sum_0 = _S810.c;
    for(;;)
    {
        uint _S811 = (fcptRestirNeighbours());
        if(t_13 < _S811)
        {
        }
        else
        {
            break;
        }
        int2  _S812 = partner_0(_S803, t_13);
        Domain neighbor_0 = _S806;
        bool _S813 = (fcptCurrentDomain((_S812), (&neighbor_0)));
        if(_S813)
        {
            float count_5 = count_4 + 1.0f;
            uint4  _S814 = (fcptReservoirTemporal((_S812), (0U)));
            float c_sum_1 = c_sum_0 + (U32_asfloat((_S814.w)));
            count_4 = count_5;
            c_sum_0 = c_sum_1;
        }
        uint t_14 = t_13 + 1U;
        t_13 = t_14;
    }
    float _S815 = _S810.c / (F32_max((count_4), (1.0f)));
    float _S816 = rgb_to_greyscale(_S810.f);
    bool _S817 = count_4 == 0.0f;
    float _S818 = _slang_select(_S817, 1.0f,0.0f);
    Selection _S819 = (Selection{});
    Selection sel_5 = _S819;
    uint _S820 = (fcptFrame());
    uint _S821 = hash(_S820);
    uint _S822 = global_invocation_id_2.x;
    uint2  _S823 = (fcptRenderSize());
    uint _S824 = stream(_S821, _S822 + _S823.x * global_invocation_id_2.y);
    uint _S825 = stream(_S824, 195U);
    (&sel_5)->random_state = _S825;
    t_13 = 0U;
    float canonical_mis_0 = _S818;
    for(;;)
    {
        uint _S826 = (fcptRestirNeighbours());
        if(t_13 < _S826)
        {
        }
        else
        {
            break;
        }
        int2  _S827 = partner_0(_S803, t_13);
        Domain neighbor_dom_0 = _S806;
        bool _S828 = (fcptCurrentDomain((_S827), (&neighbor_dom_0)));
        if(_S828)
        {
            Reservoir _S829 = (fcptLoadReservoirTemporal((_S827)));
            uint4  _S830 = (fcptShiftData((_S827), (t_13)));
            float4  _S831 = asfloat_0(_S830);
            uint4  _S832 = (fcptShiftData((_S803), (t_13)));
            float4  _S833 = asfloat_0(_S832);
            float _S834 = (_S829.c + _S815) / c_sum_0;
            bool _S835 = _S816 > 0.0f;
            float canonical_mis_1;
            if(_S835)
            {
                float _S836 = _S834 * _S815 * _S816;
                float _S837 = _S815 * _S816;
                float _S838 = rgb_to_greyscale(float3 {_S833.x, _S833.y, _S833.z});
                float canonical_mis_2 = canonical_mis_0 + _S836 / (_S837 + _S829.c * _S838);
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            float _S839 = rgb_to_greyscale(_S829.f);
            float3  _S840 = float3 {_S831.x, _S831.y, _S831.z};
            Shift _S841 = Shift_x24init_0(_S840, _S831.w);
            float _S842 = _S834 * _S829.c * _S839;
            float _S843 = _S829.c * _S839;
            float _S844 = rgb_to_greyscale(_S840);
            offerShifted(&sel_5, _S829, _S841, _S842 / (_S843 + _S815 * _S844));
            canonical_mis_0 = canonical_mis_1;
        }
        uint t_15 = t_13 + 1U;
        t_13 = t_15;
    }
    offerShifted(&sel_5, _S810, Shift_x24init_0(_S810.f, 1.0f), canonical_mis_0);
    Reservoir _S845 = finalize(sel_5, c_sum_0);
    fcptStoreReservoirPrevious((_S803), (_S845), ((&dom_4)->hit));
    fcptStorePreviousLayer((_S803), (5U), (make_uint4 (asuint_0((&(&dom_4)->hit)->uv).x, asuint_0((&(&dom_4)->hit)->uv).y, 0U, 0U)));
    fcptAddColor((_S803), (make_float4 ((&sel_5)->color.x, (&sel_5)->color.y, (&sel_5)->color.z, 0.0f)));
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
    uint _S846 = queuedShift_0(workgroup_id_1, local_invocation_index_4);
    bool _S847 = _S846 != 4294967295U;
    if(_S847)
    {
        uint2  _S848 = make_uint2 (_S846, _S846 >> 14U) & make_uint2 (16383U);
        int2  _S849 = make_int2 ((int)_S848.x, (int)_S848.y);
        ShiftJob _S850 = (ShiftJob{});
        ShiftJob shift_job_0 = _S850;
        Shift _S851 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
        uint _S852 = _S846 >> 28U;
        bool _S853 = spatialJob_0(_S849, _S852, &shift_job_0, true);
        Shift shifted_1;
        if(_S853)
        {
            Domain _S854 = (&shift_job_0)->dom;
            Reservoir _S855 = (&shift_job_0)->r;
            Shift _S856 = passShift_0(&_S854, &_S855);
            shifted_1 = _S856;
        }
        else
        {
            shifted_1 = _S851;
        }
        fcptStoreShiftData((_S849), (_S852), (make_uint4 (asuint_1(shifted_1.f).x, asuint_1(shifted_1.f).y, asuint_1(shifted_1.f).z, (F32_asuint((shifted_1.jac))))));
    }
    return;
}

static __device__ void restir_prepass_0(uint3  global_invocation_id_3, uint local_invocation_index_5)
{
    uint2  _S857 = uint2 {global_invocation_id_3.x, global_invocation_id_3.y};
    int2  _S858 = make_int2 ((int)_S857.x, (int)_S857.y);
    FixedArray<uint, 3>  _S859;
    spatialBins_0(_S858, &_S859);
    FixedArray<uint, 3>  _S860 = _S859;
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
        bool _S861 = (_S860[t_16]) == 40U;
        if(_S861)
        {
            fcptStoreShiftData((_S858), (t_16), (make_uint4 (0U)));
        }
        uint t_17 = t_16 + 1U;
        t_16 = t_17;
    }
    FixedArray<uint, 3>  _S862 = _S860;
    queueShifts_0(_S858, &_S862, global_invocation_id_3, local_invocation_index_5);
    return;
}

static __device__ void restir_count_0(uint3  global_invocation_id_4, uint local_invocation_index_6)
{
    uint2  _S863 = uint2 {global_invocation_id_4.x, global_invocation_id_4.y};
    int2  _S864 = make_int2 ((int)_S863.x, (int)_S863.y);
    FixedArray<uint, 3>  _S865;
    spatialBins_0(_S864, &_S865);
    FixedArray<uint, 3>  _S866 = _S865;
    countShifts_0(&_S866, local_invocation_index_6);
    return;
}

static __device__ void restir_temporal_shift_0(uint3  workgroup_id_2, uint local_invocation_index_7)
{
    uint _S867 = queuedShift_0(workgroup_id_2, local_invocation_index_7);
    bool _S868 = _S867 != 4294967295U;
    if(_S868)
    {
        uint2  _S869 = make_uint2 (_S867, _S867 >> 14U) & make_uint2 (16383U);
        int2  _S870 = make_int2 ((int)_S869.x, (int)_S869.y);
        ShiftJob _S871 = (ShiftJob{});
        ShiftJob shift_job_1 = _S871;
        Shift _S872 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
        uint _S873 = _S867 >> 28U;
        bool _S874 = temporalJob_0(_S870, _S873, &shift_job_1, true);
        Shift shifted_2;
        if(_S874)
        {
            if(_S873 == 1U)
            {
                Shift _S875 = (fcptShiftPrevious(((&shift_job_1)->dom), ((&shift_job_1)->r)));
                shifted_2 = _S875;
            }
            else
            {
                Domain _S876 = (&shift_job_1)->dom;
                Reservoir _S877 = (&shift_job_1)->r;
                Shift _S878 = passShift_0(&_S876, &_S877);
                shifted_2 = _S878;
            }
        }
        else
        {
            shifted_2 = _S872;
        }
        fcptStoreTemporalShift((_S870), (_S873), (make_uint4 (asuint_1(shifted_2.f).x, asuint_1(shifted_2.f).y, asuint_1(shifted_2.f).z, (F32_asuint((shifted_2.jac))))));
    }
    return;
}

static __device__ void restir_temporal_prepass_0(uint3  global_invocation_id_5, uint local_invocation_index_8)
{
    uint2  _S879 = uint2 {global_invocation_id_5.x, global_invocation_id_5.y};
    int2  _S880 = make_int2 ((int)_S879.x, (int)_S879.y);
    FixedArray<uint, 3>  _S881;
    temporalBins_0(_S880, &_S881);
    FixedArray<uint, 3>  _S882 = _S881;
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
        bool _S883 = (_S882[t_18]) == 40U;
        if(_S883)
        {
            fcptStoreTemporalShift((_S880), (t_18), (make_uint4 (0U)));
        }
        uint t_19 = t_18 + 1U;
        t_18 = t_19;
    }
    FixedArray<uint, 3>  _S884 = _S882;
    queueShifts_0(_S880, &_S884, global_invocation_id_5, local_invocation_index_8);
    return;
}

static __device__ void restir_temporal_count_0(uint3  global_invocation_id_6, uint local_invocation_index_9)
{
    uint2  _S885 = uint2 {global_invocation_id_6.x, global_invocation_id_6.y};
    int2  _S886 = make_int2 ((int)_S885.x, (int)_S885.y);
    FixedArray<uint, 3>  _S887;
    temporalBins_0(_S886, &_S887);
    FixedArray<uint, 3>  _S888 = _S887;
    countShifts_0(&_S888, local_invocation_index_9);
    return;
}

static __device__ float interpolate_0(float a_6, float b_2, float t_20)
{
    return a_6 + (b_2 - a_6) * t_20;
}

static __device__ void restir_temporal_0(uint3  global_invocation_id_7)
{
    uint2  _S889 = uint2 {global_invocation_id_7.x, global_invocation_id_7.y};
    int2  _S890 = make_int2 ((int)_S889.x, (int)_S889.y);
    float3  _S891 = make_float3 (0.0f);
    FKHit _S892 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S893 = Domain_x24init_0(_S891, _S891, &_S892, 0.0f, 0.0f);
    Domain dom_5 = _S893;
    bool _S894 = (fcptCurrentDomain((_S890), (&dom_5)));
    bool _S895 = !_S894;
    if(_S895)
    {
        Reservoir _S896 = (Reservoir{});
        fcptStoreReservoirTemporal((_S890), (_S896), ((&dom_5)->hit));
        return;
    }
    Reservoir _S897 = (fcptLoadReservoirInitial((_S890)));
    Domain stored_0 = _S893;
    int2  _S898 = make_int2 (int(-1));
    bool _S899 = (fcptStoredDomainInitial((_S890), (_S897.seed), (&stored_0)));
    int2  q_2;
    if(_S899)
    {
        Domain _S900 = stored_0;
        int2  _S901 = temporalNeighbor_0(_S890, &_S900, _S897.seed);
        q_2 = _S901;
    }
    else
    {
        q_2 = _S898;
    }
    bool _S902 = (q_2.x) >= int(0);
    Reservoir r_5;
    if(_S902)
    {
        Reservoir _S903 = (fcptLoadReservoirPrevious((q_2)));
        uint4  _S904 = (fcptDuplication((q_2)));
        float _S905 = (U32_asfloat((_S904.x)));
        uint _S906 = (fcptRestirDecorrelation());
        bool _S907 = _S906 == 1U;
        float _S908 = _slang_select(_S907, _S905,0.0f);
        float _S909 = interpolate_0(20.0f, 1.0f, (F32_pow((_S908), (0.10000000149011612f))));
        float _S910 = (F32_min((_S903.c), (_S909)));
        Domain target_3 = _S893;
        bool _S911 = (_S903.w) > 0.0f;
        bool _S912;
        if(_S911)
        {
            bool _S913 = (fcptStoredDomainInitial((_S890), (_S903.seed), (&target_3)));
            _S912 = _S913;
        }
        else
        {
            _S912 = false;
        }
        if(_S912)
        {
            Domain _S914 = (fcptPreviousDomain((q_2), (_S903.seed)));
            Domain _S915 = _S914;
            Domain _S916 = target_3;
            bool _S917 = temporalIdentity_0(0U, &_S915, &_S916);
            _S912 = _S917;
        }
        else
        {
            _S912 = false;
        }
        float4  _S918;
        if(_S912)
        {
            _S918 = make_float4 (_S903.f.x, _S903.f.y, _S903.f.z, 1.0f);
        }
        else
        {
            uint4  _S919 = (fcptTemporalShift((_S890), (0U)));
            _S918 = asfloat_0(_S919);
        }
        bool _S920 = (_S897.w) > 0.0f;
        if(_S920)
        {
            Domain _S921 = (fcptPreviousDomain((q_2), (_S897.seed)));
            Domain _S922 = _S921;
            Domain _S923 = stored_0;
            bool _S924 = temporalIdentity_0(1U, &_S922, &_S923);
            _S912 = _S924;
        }
        else
        {
            _S912 = false;
        }
        float4  _S925;
        if(_S912)
        {
            _S925 = make_float4 (_S897.f.x, _S897.f.y, _S897.f.z, 1.0f);
        }
        else
        {
            uint4  _S926 = (fcptTemporalShift((_S890), (1U)));
            _S925 = asfloat_0(_S926);
        }
        float _S927 = rgb_to_greyscale(_S897.f);
        float _S928 = rgb_to_greyscale(_S903.f);
        Selection _S929 = (Selection{});
        Selection sel_6 = _S929;
        uint _S930 = (fcptFrame());
        uint _S931 = hash(_S930);
        uint _S932 = global_invocation_id_7.x;
        uint2  _S933 = (fcptRenderSize());
        uint _S934 = stream(_S931, _S932 + _S933.x * global_invocation_id_7.y);
        uint _S935 = stream(_S934, 194U);
        (&sel_6)->random_state = _S935;
        float _S936 = _S897.c * _S927;
        float4  _S937 = _S925;
        float _S938 = rgb_to_greyscale(float3 {_S937.x, _S937.y, _S937.z});
        float _S939 = _S936 / (_S936 + _S910 * _S938);
        float _S940 = _S910 * _S928;
        float4  _S941 = _S918;
        float3  _S942 = float3 {_S941.x, _S941.y, _S941.z};
        float _S943 = rgb_to_greyscale(_S942);
        float _S944 = _S940 / (_S940 + _S897.c * _S943);
        float2  _S945 = make_float2 (_S939, _S944);
        offerShifted(&sel_6, _S897, Shift_x24init_0(_S897.f, 1.0f), _S939);
        offerShifted(&sel_6, _S903, Shift_x24init_0(_S942, _S918.w), _S944);
        Reservoir _S946 = finalize(sel_6, _S897.c + _S910);
        r_5 = _S946;
    }
    else
    {
        r_5 = _S897;
    }
    fcptStoreReservoirTemporal((_S890), (r_5), ((&dom_5)->hit));
    return;
}

static __device__ void restir_initial_0(uint3  global_invocation_id_8)
{
    uint2  _S947 = uint2 {global_invocation_id_8.x, global_invocation_id_8.y};
    int2  _S948 = make_int2 ((int)_S947.x, (int)_S947.y);
    float3  _S949 = make_float3 (0.0f);
    float2  _S950 = make_float2 (0.0f);
    FKHit _S951 = Hit_x24init_0(_S950, 0U, 0U, 0U, 0.0f);
    Domain _S952 = Domain_x24init_0(_S949, _S949, &_S951, 0.0f, 0.0f);
    Domain dom_6 = _S952;
    bool _S953 = (fcptCurrentDomain((_S948), (&dom_6)));
    bool _S954 = !_S953;
    if(_S954)
    {
        Reservoir _S955 = (Reservoir{});
        fcptStoreReservoirInitial((_S948), (_S955), ((&dom_6)->hit));
        return;
    }
    uint _S956 = (fcptFrame());
    uint _S957 = hash(_S956);
    uint _S958 = global_invocation_id_8.x;
    uint2  _S959 = (fcptRenderSize());
    uint _S960 = stream(_S957, _S958 + _S959.x * global_invocation_id_8.y);
    Selection _S961 = (Selection{});
    Selection initial_0 = _S961;
    uint _S962 = stream(_S960, 193U);
    (&initial_0)->random_state = _S962;
    bool _S963 = (fcptRestirUsed());
    bool _S964 = !_S963;
    (&initial_0)->sums = _S964;
    uint _S965 = stream(_S960, 0U);
    (&(&initial_0)->r)->seed = _S965;
    FKHit _S966 = Hit_x24init_0(_S950, 4294967295U, 0U, 0U, 0.0f);
    uint _S967 = (fcptSamples());
    float _S968 = 1.0f / float(_S967);
    FKHit hit_2 = _S966;
    uint i_17 = 0U;
    for(;;)
    {
        uint _S969 = (fcptSamples());
        if(i_17 < _S969)
        {
        }
        else
        {
            break;
        }
        Reservoir _S970 = (Reservoir{});
        Reservoir r_6 = _S970;
        uint _S971 = stream(_S960, i_17);
        (&r_6)->seed = _S971;
        Domain path_0 = _S952;
        bool _S972 = (fcptStoredDomainInitial((_S948), ((&r_6)->seed), (&path_0)));
        bool _S973 = !_S972;
        if(_S973)
        {
            fcptMissed((_S948), (path_0), (_S968));
            uint i_18 = i_17 + 1U;
            i_17 = i_18;
            continue;
        }
        Domain _S974 = path_0;
        Reservoir _S975 = r_6;
        Shift _S976 = passWalk_0(&_S974, &_S975, false, _S968, &initial_0);
        bool _S977 = ((&(&initial_0)->r)->seed) == ((&r_6)->seed);
        FKHit hit_3;
        if(_S977)
        {
            FKHit _S978 = (&path_0)->hit;
            hit_3 = _S978;
        }
        else
        {
            hit_3 = hit_2;
        }
        hit_2 = hit_3;
        uint i_18 = i_17 + 1U;
        i_17 = i_18;
    }
    float3  _S979 = (&initial_0)->glow;
    float3  _S980 = (&initial_0)->color;
    bool _S981 = (&initial_0)->sums;
    float3  _S982 = _slang_select(_S981, _S980,_S949);
    fcptAddColor((_S948), (make_float4 ((_S979 + _S982).x, (_S979 + _S982).y, (_S979 + _S982).z, 1.0f)));
    Reservoir _S983 = finalize(initial_0, 1.0f);
    fcptStoreReservoirInitial((_S948), (_S983), (hit_2));
    return;
}

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_3, float3  origin_5, float3  smooth_n_3, float3  start_6)
{
    NEEVertex _S984;
    (&_S984)->none = none_0;
    (&_S984)->pdf = pdf_3;
    (&_S984)->origin = origin_5;
    (&_S984)->smooth_n = smooth_n_3;
    (&_S984)->start = start_6;
    return _S984;
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
    Vertex _S985;
    (&_S985)->rough = rough_0;
    (&_S985)->lobe = lobe_1;
    (&_S985)->pdf = pdf_4;
    (&_S985)->cos = cos_0;
    (&_S985)->inside = inside_0;
    return _S985;
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
    float3  _S986 = exp_0((make_float3 (sigma_0) - extinction_0) * make_float3 (distance_2));
    float3  _S987 = scatter_0 * _S986 / make_float3 (sigma_0);
    float3  _S988 = _slang_select(scatters_0, _S987,_S986);
    return _S988;
}

static __device__ uint arrivalLobe_0(uint b_3, uint prev_lobe_0)
{
    bool _S989 = b_3 > 0U;
    uint _S990 = _slang_select(_S989, prev_lobe_0,3U);
    return _S990;
}

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_0, uint depth_1, uint lobe_2, bool surface_5, float length_2, float width_1, FKHit * own_0, bool fiber_0)
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
    (&_S991)->own = *own_0;
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

__device__ float3  safeDivide(float3  a_7, float3  b_4)
{
    float3  _S994 = a_7 / b_4;
    float3  _S995 = make_float3 (0.0f);
    bool3  _S996 = b_4 == _S995;
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

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_1, float3  emissive_0, float roughness_0, float metallic_0, float transmission_0, float ior_0, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_2, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_2, float velvet_0, float3  toon_2)
{
    BSDFMaterial _S1019;
    (&_S1019)->albedo = albedo_1;
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

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_11, bool skip_0, uint random_state_11, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S1021;
    (&_S1021)->smooth_n = smooth_n_4;
    (&_S1021)->geometry_n = geometry_n_2;
    (&_S1021)->geometry_offset = geometry_offset_2;
    (&_S1021)->material = *material_11;
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

static __device__ FKSurface uncovered_0(FKSurface * surface_7, float u_1)
{
    float _S1026 = surface_7->coverage;
    bool _S1027 = u_1 < _S1026;
    if(_S1027)
    {
        return *surface_7;
    }
    float3  _S1028 = make_float3 (0.0f);
    float3  _S1029 = make_float3 (1.0f);
    BSDFMaterial _S1030 = Material_x24init_0(_S1028, _S1028, 0.0f, 0.0f, 0.0f, 0.0f, _S1028, _S1029, 1.0f, _S1028, _S1028, 0.5f, 0.0f, 0.0f, _S1028, 0.0f, _S1028);
    BSDFMaterial material_12 = _S1030;
    (&material_12)->albedo = _S1029;
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

__device__ float2  vertexEta(BSDFMaterial material_13, float n_dot_v_0)
{
    bool _S1039 = n_dot_v_0 < 0.0f;
    float _S1040 = _slang_select(_S1039, material_13.ior,1.0f);
    float _S1041 = _slang_select(_S1039, 1.0f,material_13.ior);
    return make_float2 (_S1040, _S1041);
}

__device__ bool neeDecision(BSDFMaterial material_14, float n_dot_v_1, float eta_i_9, float eta_o_9)
{
    float _S1042 = fresnel((F32_abs((n_dot_v_1))), eta_i_9, eta_o_9);
    float3  _S1043 = mix_0(make_float3 (_S1042), material_14.albedo, material_14.metallic);
    float _S1044 = rgb_to_greyscale(_S1043);
    float _S1045 = (F32_max(((1.0f - _S1044) * (1.0f - material_14.metallic) * (1.0f - material_14.transmission)), (0.0f)));
    bool _S1046 = _S1045 > 0.03999999910593033f;
    bool _S1047;
    if(_S1046)
    {
        _S1047 = true;
    }
    else
    {
        _S1047 = (material_14.roughness) > 0.20000000298023224f;
    }
    return _S1047;
}

static __device__ bool isTranslucent_0(BSDFMaterial * material_15)
{
    float _S1048 = rgb_to_greyscale(material_15->translucent);
    return _S1048 > 0.0f;
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
    MediumSides _S1049;
    (&_S1049)->behind = *behind_0;
    (&_S1049)->front = *front_0;
    (&_S1049)->fillings = fillings_1;
    (&_S1049)->face = face_1;
    return _S1049;
}

static __device__ MediumSides mediumSides_0(FKSurface * surface_9, FKMedium * medium_0, uint filling_0, float3  dir_12, FKMedium * outside_0)
{
    float3  _S1050 = surface_9->geometry_n;
    MediumSides _S1051 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_9->geometry_n);
    MediumSides sides_0 = _S1051;
    bool _S1052 = surface_9->encloses;
    if(_S1052)
    {
        (&sides_0)->behind = surface_9->volume;
        *&((&(&sides_0)->fillings)->x) = surface_9->fills;
        bool _S1053 = (dot_0(dir_12, _S1050)) > 0.0f;
        if(_S1053)
        {
            (&sides_0)->front = *outside_0;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_10, bool turned_0, float3  extinction_2, uint filling_1, float3  dir_13, uint depth_2, uint lobe_3, float length_3, float width_2, FKHit * own_1, bool fiber_1, FKMedium * outside_1)
{
    float3  _S1054 = surface_10->geometry_n;
    ShadowContext _S1055 = ShadowContext_x24init_0(extinction_2, extinction_2, make_uint2 (filling_1), surface_10->geometry_n, depth_2, lobe_3, true, length_3, width_2, own_1, fiber_1);
    bool _S1056 = surface_10->encloses;
    ShadowContext context_4;
    if(_S1056)
    {
        FKSurface faced_1 = *surface_10;
        float3  _S1057 = - _S1054;
        float3  _S1058 = _slang_select(turned_0, _S1057,_S1054);
        (&faced_1)->geometry_n = _S1058;
        FKMedium _S1059 = Medium_x24init_0(make_float3 (0.0f), extinction_2, 0.0f);
        FKSurface _S1060 = faced_1;
        FKMedium _S1061 = _S1059;
        MediumSides _S1062 = mediumSides_0(&_S1060, &_S1061, filling_1, dir_13, outside_1);
        ShadowContext _S1063 = ShadowContext_x24init_0(_S1062.behind.extinction, _S1062.front.extinction, _S1062.fillings, _S1054, depth_2, lobe_3, true, length_3, width_2, own_1, fiber_1);
        if(turned_0)
        {
            uint2  _S1064 = _S1062.fillings;
            ShadowContext _S1065 = ShadowContext_x24init_0(_S1062.front.extinction, _S1062.behind.extinction, uint2 {_S1064.y, _S1064.x}, _S1054, depth_2, lobe_3, true, length_3, width_2, own_1, fiber_1);
            context_4 = _S1065;
        }
        else
        {
            context_4 = _S1063;
        }
    }
    else
    {
        context_4 = _S1055;
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
    float3  _S1066 = light_2->dir;
    bool _S1067 = (dot_0(geometry_n_3, - in_dir_8) * dot_0(geometry_n_3, light_2->dir)) <= 0.0f;
    FixedArray<float3 , 5>  throughputs_1;
    FixedArray<float, 5>  pdfs_3;
    float3  _S1068 = BSDF(in_dir_8, _S1066, smooth_n_5, *material_16, eta_i_10, eta_o_10, _S1067, random_state_12, &throughputs_1, &pdfs_3);
    bool _S1069 = !competing_1;
    bool _S1070;
    if(_S1069)
    {
        _S1070 = true;
    }
    else
    {
        _S1070 = (light_2->density) == 0.0f;
    }
    if(_S1070)
    {
        return _S1068 * light_2->radiance;
    }
    float3  _S1071 = make_float3 (0.0f);
    uint i_23 = 0U;
    float3  weighted_0 = _S1071;
    for(;;)
    {
        if(i_23 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S1072 = (pdfs_3[i_23]) > 0.0f;
        if(_S1072)
        {
            float _S1073 = light_2->density;
            float _S1074 = pdfs_3[i_23] / light_2->density;
            float3  weighted_1 = weighted_0 + throughputs_1[i_23] * make_float3 (pdfs_3[i_23]) / make_float3 (_S1073 * (1.0f + _S1074 * _S1074));
            weighted_0 = weighted_1;
        }
        uint i_24 = i_23 + 1U;
        i_23 = i_24;
    }
    return weighted_0 * light_2->radiance * make_float3 (light_2->density);
}

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_1, uint random_state_13, bool refracted_3, uint lobe_4, float pdf_6)
{
    SampleBSDF _S1075;
    (&_S1075)->unit_direction = unit_direction_1;
    (&_S1075)->throughput = throughput_1;
    (&_S1075)->random_state = random_state_13;
    (&_S1075)->refracted = refracted_3;
    (&_S1075)->lobe = lobe_4;
    (&_S1075)->pdf = pdf_6;
    return _S1075;
}

__device__ __forceinline__ SampleBSDF sheenVelvetSample(float3  n_i_9, float n_i_dot_v_6, float alpha_15, BSDFMaterial material_17, BSDFLobes lobes_11, float eta_i_11, float eta_o_11, uint random_state_14)
{
    float3  _S1076 = make_float3 (1.0f);
    SampleBSDF _S1077 = SampleBSDF_x24init_0(_S1076, _S1076, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S1077;
    Random _S1078 = pcg(random_state_14);
    Random _S1079 = pcg(_S1078.state);
    (&sample_1)->random_state = _S1079.state;
    float _S1080 = _S1078.value;
    float _S1081 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1080 * _S1080))))));
    float _S1082 = 6.28318548202514648f * _S1079.value;
    float3  _S1083 = tangentToWorld(make_float3 (_S1081 * (F32_cos((_S1082))), _S1078.value, _S1081 * (F32_sin((_S1082)))), n_i_9);
    (&sample_1)->unit_direction = _S1083;
    (&sample_1)->lobe = 4U;
    float3  _S1084 = sheenVelvetBSDF((&sample_1)->unit_direction, n_i_9, alpha_15, material_17, lobes_11);
    (&sample_1)->throughput = _S1084;
    float _S1085 = sheenVelvetPDF(_S1078.value, 0.0f, n_i_dot_v_6, alpha_15, lobes_11, eta_i_11, eta_o_11);
    (&sample_1)->pdf = _S1085;
    return sample_1;
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S1086 = (F32_sqrt((random_1_0)));
    float _S1087 = 6.28318548202514648f * random_2_0;
    float _S1088 = _S1086 * (F32_cos((_S1087)));
    float _S1089 = _S1086 * (F32_sin((_S1087)));
    float _S1090 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1088 * _S1088 - _S1089 * _S1089))))));
    return make_float3 (_S1088, _S1090, _S1089);
}

__device__ __forceinline__ SampleBSDF diffuseSample(float u_2, float3  n_i_10, float n_i_dot_v_7, float alpha_16, BSDFMaterial material_18, BSDFLobes lobes_12, float eta_i_12, float eta_o_12, uint random_state_15)
{
    float3  _S1091 = make_float3 (1.0f);
    SampleBSDF _S1092 = SampleBSDF_x24init_0(_S1091, _S1091, 0U, false, 0U, 0.0f);
    SampleBSDF sample_2 = _S1092;
    Random _S1093 = pcg(random_state_15);
    Random _S1094 = pcg(_S1093.state);
    (&sample_2)->random_state = _S1094.state;
    float3  _S1095 = sampleCosWeightedHemisphere(_S1093.value, _S1094.value);
    bool _S1096 = u_2 < (lobes_12.p_diffuse * lobes_12.translucent_share);
    float _S1097 = _S1095.y;
    float _S1098 = - _S1097;
    float _S1099 = _slang_select(_S1096, _S1098,_S1097);
    float3  _S1100 = tangentToWorld(make_float3 (_S1095.x, _S1099, _S1095.z), n_i_10);
    (&sample_2)->unit_direction = _S1100;
    (&sample_2)->refracted = _S1096;
    (&sample_2)->lobe = 0U;
    float3  _S1101 = diffuseBSDF((&sample_2)->unit_direction, n_i_10, alpha_16, material_18, lobes_12);
    (&sample_2)->throughput = _S1101;
    float _S1102 = diffusePDF(_S1099, 0.0f, n_i_dot_v_7, alpha_16, lobes_12, eta_i_12, eta_o_12);
    (&sample_2)->pdf = _S1102;
    return sample_2;
}

__device__ __forceinline__ SampleBSDF toonSample(float3  n_i_11, float n_i_dot_v_8, float alpha_17, BSDFMaterial material_19, BSDFLobes lobes_13, float eta_i_13, float eta_o_13, uint random_state_16)
{
    float3  _S1103 = make_float3 (1.0f);
    SampleBSDF _S1104 = SampleBSDF_x24init_0(_S1103, _S1103, 0U, false, 0U, 0.0f);
    SampleBSDF sample_3 = _S1104;
    Random _S1105 = pcg(random_state_16);
    Random _S1106 = pcg(_S1105.state);
    (&sample_3)->random_state = _S1106.state;
    float _S1107 = _S1105.value * lobes_13.toon_norm / 6.28318548202514648f;
    float t_21;
    if(lobes_13.toon_glossy)
    {
        t_21 = (F32_acos((clamp_1(1.0f - _S1107, -1.0f, 1.0f))));
    }
    else
    {
        t_21 = (F32_asin(((F32_min(((F32_sqrt((2.0f * _S1107)))), (1.0f))))));
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
        float _S1108;
        if(t_21 < (lobes_13.toon_a))
        {
            _S1108 = 1.0f;
        }
        else
        {
            _S1108 = (F32_max((1.0f - (t_21 - lobes_13.toon_a) / (F32_max((lobes_13.toon_s), (0.0000152587890625f)))), (0.0f)));
        }
        float integral_1;
        if(lobes_13.toon_glossy)
        {
            integral_1 = 1.0f - (F32_cos(((F32_min((t_21), (lobes_13.toon_a))))));
        }
        else
        {
            float _S1109 = (F32_sin(((F32_min((t_21), (lobes_13.toon_a))))));
            integral_1 = _S1109 * _S1109 / 2.0f;
        }
        bool _S1110 = t_21 > (lobes_13.toon_a);
        bool _S1111;
        if(_S1110)
        {
            _S1111 = (lobes_13.toon_s) > 0.0f;
        }
        else
        {
            _S1111 = false;
        }
        float integral_2;
        if(_S1111)
        {
            if(lobes_13.toon_glossy)
            {
                float _S1112 = (F32_cos((lobes_13.toon_a)));
                float _S1113 = (F32_cos((t_21)));
                integral_2 = (1.0f + lobes_13.toon_a / lobes_13.toon_s) * (_S1112 - _S1113) - ((F32_sin((t_21))) - t_21 * _S1113 - ((F32_sin((lobes_13.toon_a))) - lobes_13.toon_a * _S1112)) / lobes_13.toon_s;
            }
            else
            {
                float _S1114 = 2.0f * lobes_13.toon_a;
                float _S1115 = (F32_cos((_S1114)));
                float _S1116 = 2.0f * t_21;
                float _S1117 = (F32_cos((_S1116)));
                integral_2 = (1.0f + lobes_13.toon_a / lobes_13.toon_s) * (_S1115 - _S1117) / 4.0f - ((F32_sin((_S1116))) / 8.0f - t_21 * _S1117 / 4.0f - ((F32_sin((_S1114))) / 8.0f - lobes_13.toon_a * _S1115 / 4.0f)) / lobes_13.toon_s;
            }
            float integral_3 = integral_1 + integral_2;
            integral_2 = integral_3;
        }
        else
        {
            integral_2 = integral_1;
        }
        float _S1118 = _S1108 * (F32_sin((t_21)));
        float _S1119;
        if(lobes_13.toon_glossy)
        {
            _S1119 = 1.0f;
        }
        else
        {
            _S1119 = (F32_cos((t_21)));
        }
        float _S1120 = _S1118 * _S1119;
        float _S1121 = (integral_2 - _S1107) / _S1120;
        bool _S1122 = _S1120 > 0.0f;
        float _S1123 = _slang_select(_S1122, _S1121,0.0f);
        float _S1124 = clamp_1(t_21 - _S1123, 0.0f, lobes_13.toon_b);
        int k_1 = k_0 + int(1);
        t_21 = _S1124;
        k_0 = k_1;
    }
    float _S1125 = 6.28318548202514648f * _S1106.value;
    float _S1126 = (F32_sin((t_21)));
    float3  _S1127 = tangentToWorld(make_float3 (_S1126 * (F32_cos((_S1125))), (F32_cos((t_21))), _S1126 * (F32_sin((_S1125)))), lobes_13.toon_axis);
    (&sample_3)->unit_direction = _S1127;
    bool _S1128 = (dot_0(n_i_11, (&sample_3)->unit_direction)) < 0.0f;
    (&sample_3)->refracted = _S1128;
    (&sample_3)->lobe = 6U;
    float3  _S1129 = toonBSDF((&sample_3)->unit_direction, n_i_11, alpha_17, material_19, lobes_13);
    (&sample_3)->throughput = _S1129;
    float _S1130 = toonPDF(dot_0(n_i_11, (&sample_3)->unit_direction), dot_0((&sample_3)->unit_direction, lobes_13.toon_axis), n_i_dot_v_8, alpha_17, lobes_13, eta_i_13, eta_o_13);
    (&sample_3)->pdf = _S1130;
    return sample_3;
}

__device__ __forceinline__ SampleBSDF refractSample(float3  ggx_n_3, float3  n_i_12, float n_i_dot_v_9, float alpha_18, BSDFMaterial material_20, BSDFLobes lobes_14, float eta_i_14, float eta_o_14, uint random_state_17)
{
    float3  _S1131 = make_float3 (1.0f);
    SampleBSDF _S1132 = SampleBSDF_x24init_0(_S1131, _S1131, 0U, false, 0U, 0.0f);
    SampleBSDF sample_4 = _S1132;
    (&sample_4)->unit_direction = lobes_14.refracted;
    (&sample_4)->random_state = random_state_17;
    (&sample_4)->refracted = true;
    (&sample_4)->lobe = 1U;
    float3  _S1133 = refractBSDF((&sample_4)->unit_direction, n_i_12, alpha_18, material_20, lobes_14);
    (&sample_4)->throughput = _S1133;
    float _S1134 = refractPDF(0.0f, dot_0((&sample_4)->unit_direction, ggx_n_3), n_i_dot_v_9, alpha_18, lobes_14, eta_i_14, eta_o_14);
    (&sample_4)->pdf = _S1134;
    return sample_4;
}

static __device__ float3  reflect_0(float3  i_25, float3  n_10)
{
    return i_25 - make_float3 (2.0f * dot_0(n_10, i_25)) * n_10;
}

__device__ __forceinline__ SampleBSDF reflectSample(float3  in_dir_9, float3  ggx_n_4, float3  n_i_13, float n_i_dot_v_10, float alpha_19, BSDFMaterial material_21, BSDFLobes lobes_15, float eta_i_15, float eta_o_15, uint random_state_18)
{
    float3  _S1135 = make_float3 (1.0f);
    SampleBSDF _S1136 = SampleBSDF_x24init_0(_S1135, _S1135, 0U, false, 0U, 0.0f);
    SampleBSDF sample_5 = _S1136;
    float3  _S1137 = reflect_0(in_dir_9, ggx_n_4);
    float3  _S1138 = ((((_S1137)) * make_float3(rnorm3df(((_S1137)).x, ((_S1137)).y, ((_S1137)).z))));
    (&sample_5)->unit_direction = _S1138;
    (&sample_5)->random_state = random_state_18;
    (&sample_5)->lobe = 2U;
    float3  _S1139 = reflectBSDF((&sample_5)->unit_direction, n_i_13, alpha_19, material_21, lobes_15);
    (&sample_5)->throughput = _S1139;
    float _S1140 = reflectPDF(0.0f, 0.0f, n_i_dot_v_10, alpha_19, lobes_15, eta_i_15, eta_o_15);
    (&sample_5)->pdf = _S1140;
    return sample_5;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_10, float3  n_11, BSDFMaterial material_22, float eta_i_16, float eta_o_16, uint random_init_0, float2  screen_space_0)
{
    uint random_state_19 = random_init_0;
    float3  _S1141 = negate_0(in_dir_10);
    float _S1142 = dot_0(n_11, _S1141);
    float _S1143 = sign_0(_S1142);
    float3  n_i_14 = n_11 * make_float3 (_S1143);
    float _S1144 = (F32_abs((_S1142)));
    float _S1145 = material_22.roughness;
    float _S1146 = _S1145 * _S1145;
    AnisotropicFrame _S1147 = anisotropicFrame(material_22, n_i_14);
    SheenProfile _S1148 = sheenProfile(_S1141, n_i_14, material_22);
    float3  _S1149 = sampleHalfVector(_S1141, n_i_14, _S1146, _S1147, &random_state_19);
    BSDFLobes _S1150 = bsdfLobes(in_dir_10, _S1141, n_i_14, _S1149, material_22, eta_i_16, eta_o_16, _S1147, _S1148);
    BSDFLobes lobes_16 = _S1150;
    float _S1151 = translucentShare(material_22);
    (&lobes_16)->translucent_share = _S1151;
    Random _S1152 = pcg(random_state_19);
    random_state_19 = _S1152.state;
    bool _S1153 = (_S1152.value) < ((&lobes_16)->p_sheen_velvet);
    if(_S1153)
    {
        SampleBSDF _S1154 = sheenVelvetSample(n_i_14, _S1144, _S1146, material_22, lobes_16, eta_i_16, eta_o_16, random_state_19);
        return _S1154;
    }
    float _S1155 = _S1152.value - (&lobes_16)->p_sheen_velvet;
    bool _S1156 = _S1155 < ((&lobes_16)->p_diffuse);
    if(_S1156)
    {
        SampleBSDF _S1157 = diffuseSample(_S1155, n_i_14, _S1144, _S1146, material_22, lobes_16, eta_i_16, eta_o_16, random_state_19);
        return _S1157;
    }
    bool _S1158 = _S1155 < ((&lobes_16)->p_diffuse + (&lobes_16)->p_toon);
    if(_S1158)
    {
        SampleBSDF _S1159 = toonSample(n_i_14, _S1144, _S1146, material_22, lobes_16, eta_i_16, eta_o_16, random_state_19);
        return _S1159;
    }
    float _S1160 = (&lobes_16)->p_toon;
    bool _S1161 = (_S1155 - _S1160) < ((&lobes_16)->p_diffuse + (&lobes_16)->p_refract);
    if(_S1161)
    {
        SampleBSDF _S1162 = refractSample(_S1149, n_i_14, _S1144, _S1146, material_22, lobes_16, eta_i_16, eta_o_16, random_state_19);
        return _S1162;
    }
    SampleBSDF _S1163 = reflectSample(in_dir_10, _S1149, n_i_14, _S1144, _S1146, material_22, lobes_16, eta_i_16, eta_o_16, random_state_19);
    return _S1163;
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
    bool _S1164;
    bool _S1165;
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
    int _S1166;
    Shift ended_0;
    float density_3;
    float spread_2;
    float width_4;
    float sky_pdf_1;
    float spread_3;
    float width_5;
    uint b_6;
    float3  _S1167 = make_float3 (0.0f);
    Shift _S1168 = Shift_x24init_0(_S1167, 0.0f);
    uint _S1169 = r_8->path;
    uint _S1170 = extractBits_0(r_8->path, 0U, 5U);
    uint _S1171 = extractBits_0(_S1169, 5U, 5U);
    uint _S1172 = extractBits_0(_S1169, 10U, 2U);
    uint _S1173 = extractBits_0(_S1169, 12U, 3U);
    bool passes_0;
    if(replay_1)
    {
        bool _S1174 = _S1173 >= 3U;
        uint _S1175 = _slang_select(_S1174, 1U,0U);
        uint _S1176 = _S1170 + _S1175;
        uint _S1177 = (fcptMaxBounces());
        passes_0 = _S1176 > _S1177;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S1168;
    }
    uint _S1178 = _S1171 - 1U;
    bool _S1179 = _S1173 == 3U;
    uint _S1180 = _slang_select(_S1179, 1U,0U);
    uint _S1181 = _S1170 + _S1180;
    bool _S1182 = _S1172 == 0U;
    uint _S1183 = _slang_select(_S1182, _S1181,_S1178);
    FKHit _S1184 = (fcptReservoirHit((*r_8)));
    float3  _S1185 = dom_7->x0;
    float3  _S1186 = dom_7->x1 - dom_7->x0;
    float3  _S1187 = ((((_S1186)) * make_float3(rnorm3df(((_S1186)).x, ((_S1186)).y, ((_S1186)).z))));
    FKRay _S1188 = Ray_x24init_0(dom_7->x1, _S1187);
    FKRay ray_2 = _S1188;
    FKHit hit_4 = dom_7->hit;
    float3  scatter_in_0 = _S1167;
    float3  throughput_3 = make_float3 (1.0f);
    float3  weight_1 = throughput_3;
    float3  glowed_0 = _S1167;
    float3  extinction_in_0 = _S1167;
    float g_in_0 = 0.0f;
    uint filling_2 = 4294967295U;
    float _S1189 = dom_7->spread;
    float _S1190 = dom_7->width;
    float _S1191 = length_0(_S1186);
    NEEVertex _S1192 = NEEVertex_x24init_0(true, 0.0f, _S1167, _S1167, _S1167);
    NEEVertex nee_vertex_0 = _S1192;
    Vertex _S1193 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_0 = _S1193;
    Reservoir _S1194 = (Reservoir{});
    Reservoir chain_0 = _S1194;
    uint _S1195 = r_8->seed;
    (&chain_0)->seed = r_8->seed;
    (&ray_2)->origin = _S1185;
    (&hit_4)->distance = _S1191;
    FKMedium _S1196 = (fcptCameraMedium(((&ray_2)->unit_direction), ((&hit_4)->distance), (&filling_2)));
    uint _S1197 = filling_2;
    bool _S1198 = (fcptVaryingUsed());
    uint _S1199 = _slang_select(_S1198, _S1197,4294967295U);
    filling_2 = _S1199;
    scatter_in_0 = _S1196.scatter;
    extinction_in_0 = _S1196.extinction;
    g_in_0 = _S1196.g;
    Reservoir _S1200 = chain_0;
    uint _S1201 = filling_2;
    for(;;)
    {
        bool _S1202 = (fcptVaryingUsed());
        if(_S1202)
        {
            passes_0 = _S1201 != 4294967295U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            float _S1203 = (fcptMajorant((_S1201)));
            spread_1 = _S1203;
        }
        else
        {
            spread_1 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
        }
        if(replay_1)
        {
            turned_1 = 4294967295U == _S1183;
        }
        else
        {
            turned_1 = false;
        }
        if(turned_1)
        {
            turned_1 = _S1172 == 1U;
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
            ended_0 = _S1168;
            sky_pdf_0 = 0.0f;
            spread_1 = _S1189;
            width_3 = _S1190;
            density_2 = 1.0f;
            throughput_2 = throughput_3;
            b_5 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S1204 = (&prev_0)->rough;
        if(_S1204)
        {
            turned_1 = !(spread_1 > 0.0f);
        }
        else
        {
            turned_1 = false;
        }
        (&prev_0)->rough = turned_1;
        uint _S1205 = stream(_S1195, 384U);
        uint tracking_0 = _S1205;
        weight_1 = throughput_3;
        glowed_0 = _S1167;
        b_5 = 4294967295U;
        throughput_2 = throughput_3;
        density_2 = 1.0f;
        threshold_0 = _S1189;
        width_3 = _S1190;
        sky_pdf_0 = 0.0f;
        for(;;)
        {
            if(((&hit_4)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S1166 = int(1);
                break;
            }
            uint _S1206 = b_5 + 320U;
            bool _S1207 = b_5 == 4294967295U;
            uint _S1208 = _slang_select(_S1207, 384U,_S1206);
            uint _S1209 = stream(_S1195, _S1208);
            Random _S1210 = pcg(_S1209);
            float _S1211 = - (F32_log((1.0f - _S1210.value))) / spread_1;
            if(passes_0)
            {
                float3  _S1212 = (&ray_2)->origin;
                float3  _S1213 = (&ray_2)->unit_direction;
                float _S1214 = (&hit_4)->distance;
                uint _S1215 = _slang_select(_S1207, 0U,b_5);
                uint _S1216 = (&prev_0)->lobe;
                uint _S1217 = _slang_select(_S1207, 3U,_S1216);
                float _S1218 = (fcptTrackMedium((_S1201), (_S1212), (_S1213), (_S1214), (&tracking_0), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1215), (_S1217), (_S1207)));
                geometry_density_0 = _S1218;
            }
            else
            {
                geometry_density_0 = _S1211;
            }
            bool _S1219 = !(geometry_density_0 < ((&hit_4)->distance));
            if(_S1219)
            {
                _S1166 = int(1);
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
                float3  _S1220 = throughput_2 * glowed_0 / make_float3 (density_2);
                float3  _S1221 = sel_7->glow + _S1220;
                sel_7->glow = _S1221;
            }
            else
            {
            }
            glowed_0 = _S1167;
            uint b_7 = b_5 + 1U;
            float3  _S1222 = (&ray_2)->origin + make_float3 (geometry_density_0) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S1222;
            float3  _S1223 = flightWeight_0(scatter_in_0, extinction_in_0, spread_1, geometry_density_0, true);
            float3  _S1224 = weight_1;
            float3  _S1225 = _slang_select(passes_0, _S1224,_S1223);
            float3  throughput_4 = throughput_2 * _S1225;
            uint _S1226 = stream(_S1195, b_7 + 320U);
            tracking_0 = _S1226;
            weight_1 = throughput_3;
            float width_6 = width_3 + threshold_0 * geometry_density_0;
            float _S1227 = threshold_0 + 3.14159274101257324f;
            bool _S1228 = !replay_1;
            if(_S1228)
            {
                is_inside_5 = true;
            }
            else
            {
                bool _S1229 = b_7 == _S1183;
                if(_S1229)
                {
                    is_inside_5 = !passes_0;
                }
                else
                {
                    is_inside_5 = false;
                }
            }
            TreeSample _S1230 = TreeSample_x24init_0(_S1167, _S1167, 0.0f, 0U);
            if(is_inside_5)
            {
                float3  _S1231 = (&ray_2)->origin;
                float3  _S1232 = (&ray_2)->unit_direction;
                float3  _S1233 = (&ray_2)->unit_direction;
                uint _S1234 = stream(_S1195, b_7 + 64U);
                float3  _S1235 = extinction_in_0;
                float3  _S1236 = extinction_in_0;
                uint2  _S1237 = make_uint2 (_S1201);
                float3  _S1238 = (&ray_2)->unit_direction;
                uint _S1239 = arrivalLobe_0(b_7, (&prev_0)->lobe);
                FKHit _S1240 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S1241 = _S1240;
                ShadowContext _S1242 = ShadowContext_x24init_0(_S1235, _S1236, _S1237, _S1238, b_7, _S1239, false, geometry_density_0, width_6, &_S1241, false);
                ShadowContext _S1243 = _S1242;
                TreeSample _S1244 = sampleLightTree_0(_S1231, _S1232, _S1233, 0.0f, true, _S1234, &_S1243);
                light_3 = _S1244;
            }
            else
            {
                light_3 = _S1230;
            }
            float _S1245 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_3.dir));
            uint _S1246 = (fcptMaxBounces());
            bool _S1247 = b_7 < _S1246;
            if(_S1247)
            {
                viewed_0 = (light_3.density) > 0.0f;
            }
            else
            {
                viewed_0 = false;
            }
            float _S1248 = _slang_select(viewed_0, _S1245,0.0f);
            float3  _S1249 = throughput_4 * light_3.radiance;
            float _S1250 = powerHeuristic(light_3.density, _S1248);
            float3  _S1251 = _S1249 * make_float3 (_S1245 * _S1250);
            float3  _S1252 = _slang_select(is_inside_5, _S1251,_S1167);
            if(replay_1)
            {
                _S1164 = b_7 == _S1183;
            }
            else
            {
                _S1164 = false;
            }
            if(_S1164)
            {
                bool _S1253 = _S1172 == 2U;
                if(_S1253)
                {
                    float _S1254 = rgb_to_greyscale(_S1252);
                    passes_0 = _S1254 > 0.0f;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S1255 = Shift_x24init_0(_S1252, 1.0f);
                    _S1166 = int(0);
                    ended_0 = _S1255;
                    spread_1 = _S1227;
                    geometry_density_0 = width_6;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_7;
                    break;
                }
                _S1166 = int(0);
                ended_0 = _S1168;
                spread_1 = _S1227;
                geometry_density_0 = width_6;
                chain_throughput_0 = throughput_4;
                layer_0 = b_7;
                break;
            }
            if(_S1228)
            {
                Reservoir candidate_3 = _S1200;
                uint _S1256 = extractBits_0(_S1200.path, 10U, 2U);
                bool _S1257 = _S1256 == 1U;
                if(_S1257)
                {
                    float3  _S1258 = safeDivide(_S1252, _S1167);
                    (&candidate_3)->radiance = _S1258;
                }
                else
                {
                    uint _S1259 = insertBits_0(0U, b_7 + 1U, 5U, 5U);
                    uint _S1260 = insertBits_0(_S1259, 2U, 10U, 2U);
                    (&candidate_3)->path = _S1260;
                }
                Reservoir _S1261 = withEnd(candidate_3, 0U, b_7, _S1252);
                offer(sel_7, _S1261, _S1252 * make_float3 (scale_3) / make_float3 (density_2));
                float _S1262 = survivalProbability(throughput_4, density_2);
                uint _S1263 = stream(_S1195, b_7 + 128U);
                Random _S1264 = pcg(_S1263);
                bool _S1265 = _S1262 < (_S1264.value);
                if(_S1265)
                {
                    _S1165 = true;
                }
                else
                {
                    uint _S1266 = (fcptMaxBounces());
                    _S1165 = b_7 >= _S1266;
                }
                if(_S1165)
                {
                    _S1166 = int(0);
                    ended_0 = _S1168;
                    spread_1 = _S1227;
                    geometry_density_0 = width_6;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_7;
                    break;
                }
                float _S1267 = density_2 * _S1262;
                density_2 = _S1267;
            }
            else
            {
            }
            float phase_pdf_0 = 0.0f;
            uint _S1268 = stream(_S1195, b_7);
            float3  _S1269 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1268, &phase_pdf_0);
            (&ray_2)->unit_direction = _S1269;
            NEEVertex _S1270 = NEEVertex_x24init_0(false, phase_pdf_0, (&ray_2)->origin, _S1167, (&ray_2)->origin);
            nee_vertex_0 = _S1270;
            Vertex _S1271 = Vertex_x24init_0(false, 0U, 0.0f, 1.0f, false);
            prev_0 = _S1271;
            float _S1272 = (&prev_0)->pdf;
            FKRay _S1273 = ray_2;
            FKHit _S1274 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S1275 = (fcptTraverseInstanceBVH((_S1273), (true), (4.294967296e+09f), (false), (_S1274), (false)));
            hit_4 = _S1275;
            b_5 = b_7;
            throughput_2 = throughput_4;
            threshold_0 = _S1227;
            width_3 = width_6;
            sky_pdf_0 = _S1272;
        }
        if(_S1166 != int(1))
        {
            width_3 = geometry_density_0;
            throughput_2 = chain_throughput_0;
            b_5 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S1168;
        spread_1 = threshold_0;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    bool _S1276 = b_5 == 4294967295U;
    bool _S1277 = ((&hit_4)->instance_index) == 4294967295U;
    if(_S1277)
    {
        bool _S1278 = !(&nee_vertex_0)->none;
        float _S1279 = _slang_select(_S1278, sky_pdf_0,0.0f);
        float _S1280 = escapeWeight_0(_S1279, (&ray_2)->unit_direction);
        float3  _S1281 = environment_0((&ray_2)->unit_direction, b_5, (&prev_0)->lobe);
        float3  _S1282 = throughput_2 * _S1281;
        if(replay_1)
        {
            bool _S1283 = b_5 == _S1183;
            if(_S1283)
            {
                passes_0 = _S1172 == 3U;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                return Shift_x24init_0(_S1282 * make_float3 (_S1280) / make_float3 (r_8->jac), density_2 / r_8->jac);
            }
            if(_S1182)
            {
                passes_0 = _S1179;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                passes_0 = b_5 == _S1170;
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
                return Shift_x24init_0(_S1282 * make_float3 (_S1280), 1.0f);
            }
            return _S1168;
        }
        Reservoir candidate_4 = chain_0;
        uint _S1284 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1285 = _S1284 == 1U;
        if(_S1285)
        {
            uint _S1286 = extractBits_0((&chain_0)->path, 5U, 5U);
            bool _S1287 = _S1286 == b_5;
            float _S1288 = _slang_select(_S1287, 1.0f,_S1280);
            float3  _S1289 = safeDivide(_S1282 * make_float3 (_S1288), _S1167);
            (&candidate_4)->radiance = _S1289;
        }
        else
        {
            bool _S1290 = (&prev_0)->rough;
            if(_S1290)
            {
                uint _S1291 = insertBits_0(0U, b_5 + 1U, 5U, 5U);
                uint _S1292 = insertBits_0(_S1291, 3U, 10U, 2U);
                uint _S1293 = insertBits_0(_S1292, (&prev_0)->lobe, 15U, 3U);
                bool _S1294 = (&prev_0)->inside;
                uint _S1295 = _slang_select(_S1294, 1U,0U);
                uint _S1296 = insertBits_0(_S1293, _S1295, 22U, 1U);
                (&candidate_4)->path = _S1296;
                (&candidate_4)->jac = (&prev_0)->pdf;
                (&candidate_4)->dir = (&ray_2)->unit_direction;
            }
        }
        float3  _S1297 = _S1282 * make_float3 (_S1280);
        Reservoir _S1298 = withEnd(candidate_4, 3U, b_5, _S1297);
        offer(sel_7, _S1298, _S1297 * make_float3 (scale_3) / make_float3 (density_2));
        return _S1168;
    }
    float3  _S1299 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
    (&ray_2)->origin = _S1299;
    bool _S1300 = (fcptVaryingUsed());
    if(_S1300)
    {
        passes_0 = filling_2 != 4294967295U;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        bool _S1301 = !replay_1;
        if(_S1301)
        {
            float3  _S1302 = throughput_2 * glowed_0 / make_float3 (density_2);
            float3  _S1303 = sel_7->glow + _S1302;
            sel_7->glow = _S1303;
        }
        float3  _S1304 = throughput_2 * weight_1;
        throughput_2 = _S1304;
    }
    else
    {
        float3  _S1305 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
        float3  _S1306 = throughput_2 * _S1305;
        throughput_2 = _S1306;
    }
    float _S1307 = width_3 + spread_1 * (&hit_4)->distance;
    uint _S1308 = b_5 + 1U;
    b_5 = _S1308;
    layer_0 = 0U;
    width_3 = _S1307;
    passes_0 = false;
    threshold_0 = 0.0f;
    turned_1 = false;
    is_inside_5 = false;
    chain_throughput_0 = _S1167;
    float3  reconnection_0 = _S1167;
    viewed_0 = _S1276;
    for(;;)
    {
        bool _S1309 = ((&hit_4)->is_point_light) == 1U;
        if(replay_1)
        {
            _S1164 = _S1172 == 1U;
        }
        else
        {
            _S1164 = false;
        }
        if(_S1164)
        {
            _S1165 = b_5 == _S1171;
        }
        else
        {
            _S1165 = false;
        }
        bool _S1310;
        if(_S1165)
        {
            bool _S1311 = ((&hit_4)->instance_index) != (_S1184.instance_index);
            if(_S1311)
            {
                _S1310 = true;
            }
            else
            {
                _S1310 = ((&hit_4)->triangle_index) != (_S1184.triangle_index);
            }
        }
        else
        {
            _S1310 = false;
        }
        if(_S1310)
        {
            return _S1168;
        }
        FKMedium _S1312 = Medium_x24init_0(_S1167, _S1167, 0.0f);
        BSDFMaterial _S1313 = Material_x24init_0(_S1167, _S1167, 0.0f, 0.0f, 0.0f, 0.0f, _S1167, throughput_3, 1.0f, _S1167, _S1167, 0.5f, 0.0f, 0.0f, _S1167, 0.0f, _S1167);
        FKMedium _S1314 = _S1312;
        FKSurface _S1315 = Surface_x24init_0(_S1167, _S1167, 0.0f, &_S1313, false, 0U, 1.0f, false, &_S1314, 4294967295U, _S1167);
        bool _S1316 = !_S1309;
        bool scatter_2;
        bool is_inside_6;
        float3  throughput_5;
        FKSurface surface_12;
        if(_S1316)
        {
            uint _S1317 = stream(_S1195, b_5);
            uint _S1318 = arrivalLobe_0(b_5, (&prev_0)->lobe);
            FKSurface _S1319 = (fcptSurfaceAtPath((hit_4), ((&ray_2)->origin), (_S1317), (width_3), (layer_0), (b_5), (_S1318), ((&ray_2)->unit_direction)));
            bool _S1320 = !passes_0;
            FKSurface _S1321 = _S1319;
            FKSurface _S1322 = emitting_0(&_S1321, _S1320);
            uint _S1323 = stream(_S1195, b_5 + 256U);
            Random _S1324 = pcg(_S1323);
            FKSurface _S1325 = _S1322;
            FKSurface _S1326 = uncovered_0(&_S1325, _S1324.value);
            float _S1327 = facingSign(_S1326.material.transmission, _S1326.geometry_n, (&ray_2)->unit_direction);
            bool _S1328 = _S1327 < 0.0f;
            bool _S1329 = (_S1326.material.transmission) > 0.0f;
            if(_S1329)
            {
                bool _S1330 = arrivesBehind_0((&ray_2)->unit_direction, _S1326.geometry_n);
                scatter_2 = _S1330;
            }
            else
            {
                scatter_2 = false;
            }
            FKSurface _S1331 = _S1326;
            FKSurface _S1332 = facingRay_0(&_S1331, (&ray_2)->unit_direction);
            if(passes_0)
            {
                bool _S1333 = arrivesBehind_0((&ray_2)->unit_direction, _S1332.geometry_n);
                is_inside_6 = _S1333;
            }
            else
            {
                is_inside_6 = scatter_2;
            }
            if(is_inside_6)
            {
                float3  _S1334 = beerLambert((&hit_4)->distance, _S1332.material.absorption);
                float3  _S1335 = throughput_2 * _S1334;
                throughput_5 = _S1335;
            }
            else
            {
                throughput_5 = throughput_2;
            }
            bool _S1336 = !_S1332.skip;
            float geometry_density_1 = (F32_abs((dot_0(_S1332.geometry_n, (&ray_2)->unit_direction)))) / ((&hit_4)->distance * (&hit_4)->distance);
            bool _S1337 = b_5 == _S1308;
            if(_S1337)
            {
                float _S1338 = 0.00251327408477664f / geometry_density_1;
                geometry_density_0 = _S1338;
            }
            else
            {
                geometry_density_0 = threshold_0;
            }
            float _S1339 = geometry_density_0;
            scatter_2 = _S1336;
            geometry_density_0 = geometry_density_1;
            threshold_0 = _S1339;
            surface_12 = _S1332;
            turned_1 = _S1328;
        }
        else
        {
            scatter_2 = false;
            geometry_density_0 = 0.0f;
            surface_12 = _S1315;
            throughput_5 = throughput_2;
            is_inside_6 = is_inside_5;
        }
        bool _S1340;
        if(scatter_2)
        {
            _S1340 = (&prev_0)->rough;
        }
        else
        {
            _S1340 = false;
        }
        bool _S1341;
        if(_S1340)
        {
            _S1341 = ((&prev_0)->pdf * geometry_density_0 * threshold_0) <= 1.0f;
        }
        else
        {
            _S1341 = false;
        }
        FKSurface _S1342 = surface_12;
        FKSurface _S1343 = surface_12;
        float _S1344 = dot_0(surface_12.smooth_n, - (&ray_2)->unit_direction);
        float2  _S1345 = vertexEta(_S1342.material, _S1344);
        bool _S1346;
        if(scatter_2)
        {
            bool _S1347 = neeDecision(_S1342.material, _S1344, _S1345.x, _S1345.y);
            _S1346 = _S1347;
        }
        else
        {
            _S1346 = false;
        }
        bool _S1348;
        if(passes_0)
        {
            _S1348 = true;
        }
        else
        {
            _S1348 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S1348)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S1346;
        }
        bool _S1349 = (fcptHairUsed());
        bool _S1350;
        if(_S1349)
        {
            float3  _S1351 = surface_12.hair;
            _S1350 = (dot_0(_S1351, _S1351)) > 0.0f;
        }
        else
        {
            _S1350 = false;
        }
        bool _S1352;
        if(_S1350)
        {
            _S1352 = true;
        }
        else
        {
            BSDFMaterial _S1353 = _S1342.material;
            bool _S1354 = isTranslucent_0(&_S1353);
            _S1352 = _S1354;
        }
        bool _S1355;
        if(_S1352)
        {
            _S1355 = true;
        }
        else
        {
            bool _S1356 = (_S1342.material.transmission) > 0.0f;
            if(_S1356)
            {
                uint _S1357 = (fcptLayers((hit_4)));
                _S1355 = _S1357 == 1U;
            }
            else
            {
                _S1355 = false;
            }
        }
        float3  emission_0;
        if(_S1309)
        {
            float3  _S1358 = (fcptCalculatePointLightContrib(((&hit_4)->instance_index)));
            emission_0 = _S1358;
        }
        else
        {
            emission_0 = _S1342.material.emissive;
        }
        bool _S1359 = !replay_1;
        bool _S1360;
        if(_S1359)
        {
            _S1360 = true;
        }
        else
        {
            _S1360 = b_5 >= _S1183;
        }
        bool _S1361;
        if(_S1360)
        {
            float _S1362 = rgb_to_greyscale(emission_0);
            _S1361 = _S1362 > 0.0f;
        }
        else
        {
            _S1361 = false;
        }
        float3  emission_1;
        if(_S1361)
        {
            NEEVertex _S1363 = nee_vertex_0;
            FKHit _S1364 = hit_4;
            float _S1365 = emissionWeight_0(&_S1363, &_S1364, (&ray_2)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S1365);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S1366;
        if(replay_1)
        {
            _S1366 = _S1172 == 1U;
        }
        else
        {
            _S1366 = false;
        }
        bool _S1367;
        if(_S1366)
        {
            _S1367 = b_5 > _S1171;
        }
        else
        {
            _S1367 = false;
        }
        bool _S1368;
        if(_S1367)
        {
            _S1368 = b_5 == _S1170;
        }
        else
        {
            _S1368 = false;
        }
        bool _S1369;
        if(_S1368)
        {
            bool _S1370 = _S1173 == 1U;
            if(_S1370)
            {
                _S1369 = true;
            }
            else
            {
                _S1369 = _S1173 == 2U;
            }
        }
        else
        {
            _S1369 = false;
        }
        if(_S1369)
        {
            bool _S1371 = _S1309 != (_S1173 == 2U);
            if(_S1371)
            {
                return _S1168;
            }
            return Shift_x24init_0(throughput_5 * emission_1 / make_float3 (r_8->jac), density_2 / r_8->jac);
        }
        uint _S1372 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1373 = _S1372 == 1U;
        Reservoir here_0 = chain_0;
        uint _S1374 = insertBits_0(0U, b_5, 5U, 5U);
        uint _S1375 = insertBits_0(_S1374, 1U, 10U, 2U);
        uint _S1376 = insertBits_0(_S1375, (&prev_0)->lobe, 15U, 3U);
        bool _S1377 = (&prev_0)->inside;
        uint _S1378 = _slang_select(_S1377, 1U,0U);
        uint _S1379 = insertBits_0(_S1376, _S1378, 22U, 1U);
        (&here_0)->path = _S1379;
        float _S1380 = (&prev_0)->pdf * geometry_density_0;
        (&here_0)->jac = _S1380;
        fcptWithReservoirHit((&here_0), (&hit_4));
        bool _S1381;
        if(replay_1)
        {
            _S1381 = _S1172 == 1U;
        }
        else
        {
            _S1381 = false;
        }
        bool _S1382;
        if(_S1381)
        {
            _S1382 = b_5 == _S1171;
        }
        else
        {
            _S1382 = false;
        }
        bool _S1383 = b_5 == _S1183;
        bool _S1384;
        if(_S1383)
        {
            bool _S1385 = !scatter_2;
            if(_S1385)
            {
                _S1384 = true;
            }
            else
            {
                bool _S1386 = _S1172 != 1U;
                if(_S1386)
                {
                    _S1384 = _S1172 != 3U;
                }
                else
                {
                    _S1384 = false;
                }
            }
        }
        else
        {
            _S1384 = false;
        }
        bool _S1387;
        if(_S1384)
        {
            _S1387 = _S1172 == 2U;
        }
        else
        {
            _S1387 = false;
        }
        bool _S1388;
        if(_S1387)
        {
            _S1388 = !_S1341;
        }
        else
        {
            _S1388 = false;
        }
        bool _S1389;
        if(_S1388)
        {
            _S1389 = _S1173 != 4U;
        }
        else
        {
            _S1389 = false;
        }
        bool _S1390 = _S1171 == _S1170;
        bool _S1391;
        if(_S1390)
        {
            _S1391 = _S1173 == 0U;
        }
        else
        {
            _S1391 = false;
        }
        bool _S1392;
        if(_S1391)
        {
            _S1392 = ((&hit_4)->instance_index) == (_S1184.instance_index);
        }
        else
        {
            _S1392 = false;
        }
        bool _S1393;
        if(_S1392)
        {
            _S1393 = ((&hit_4)->triangle_index) == (_S1184.triangle_index);
        }
        else
        {
            _S1393 = false;
        }
        bool _S1394;
        if(_S1393)
        {
            _S1394 = _S1341;
        }
        else
        {
            _S1394 = false;
        }
        bool _S1395 = _slang_select(_S1382, _S1394,_S1389);
        bool _S1396;
        if(nee_0)
        {
            _S1396 = _slang_select(replay_1, _S1395,scatter_2);
        }
        else
        {
            _S1396 = false;
        }
        TreeSample _S1397 = TreeSample_x24init_0(_S1167, _S1167, 0.0f, 0U);
        uint2  _S1398 = make_uint2 (0U);
        float2  _S1399 = make_float2 (0.0f);
        FKHit _S1400 = Hit_x24init_0(_S1399, 4294967295U, 0U, 0U, 0.0f);
        FKHit _S1401 = _S1400;
        ShadowContext _S1402 = ShadowContext_x24init_0(_S1167, _S1167, _S1398, _S1167, 0U, 0U, false, 0.0f, 0.0f, &_S1401, false);
        bool _S1403;
        if(nee_0)
        {
            _S1403 = _S1360;
        }
        else
        {
            _S1403 = false;
        }
        ShadowContext context_5;
        if(_S1403)
        {
            uint _S1404 = arrivalLobe_0(b_5, (&prev_0)->lobe);
            FKMedium _S1405 = (fcptOutsideMedium((hit_4)));
            FKSurface _S1406 = surface_12;
            FKHit _S1407 = hit_4;
            FKMedium _S1408 = _S1405;
            ShadowContext _S1409 = shadowContext_0(&_S1406, turned_1, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_5, _S1404, (&hit_4)->distance, width_3, &_S1407, _S1350, &_S1408);
            context_5 = _S1409;
        }
        else
        {
            context_5 = _S1402;
        }
        float3  throughput_6;
        float3  lit_0;
        if(_S1396)
        {
            float3  _S1410 = (&ray_2)->origin;
            if(_S1350)
            {
                throughput_6 = _S1167;
            }
            else
            {
                throughput_6 = _S1343.smooth_n;
            }
            FKSurface _S1411 = surface_12;
            uint _S1412 = stream(_S1195, b_5 + 64U);
            ShadowContext _S1413 = context_5;
            TreeSample _S1414 = sampleLightTree_0(_S1410, throughput_6, surface_12.geometry_n, surface_12.geometry_offset, _S1355, _S1412, &_S1413);
            bool _S1415 = any_1((_S1414.radiance) != _S1167);
            if(_S1415)
            {
                if(_S1350)
                {
                    uint _S1416 = (fcptMaxBounces());
                    bool _S1417 = b_5 < _S1416;
                    FKSurface _S1418 = surface_12;
                    TreeSample _S1419 = _S1414;
                    float3  _S1420 = hairLight_0(&_S1418, (&ray_2)->unit_direction, &_S1419, _S1417);
                    lit_0 = _S1420;
                }
                else
                {
                    float _S1421 = _S1345.x;
                    float _S1422 = _S1345.y;
                    uint _S1423 = (fcptMaxBounces());
                    bool _S1424 = b_5 < _S1423;
                    TreeSample _S1425 = _S1414;
                    BSDFMaterial _S1426 = _S1342.material;
                    float3  _S1427 = lightBSDF_0((&ray_2)->unit_direction, &_S1425, _S1343.smooth_n, _S1411.geometry_n, &_S1426, _S1421, _S1422, _S1424, surface_12.random_state);
                    lit_0 = _S1427;
                }
            }
            else
            {
                lit_0 = _S1167;
            }
            light_3 = _S1414;
        }
        else
        {
            light_3 = _S1397;
            lit_0 = _S1167;
        }
        bool viewed_1;
        bool refracted_4;
        bool wrong_side_0;
        bool _S1428;
        bool _S1429;
        float density_4;
        if(_S1382)
        {
            bool _S1430 = !_S1341;
            if(_S1430)
            {
                return _S1168;
            }
            float3  throughput_7 = throughput_5 * make_float3 (geometry_density_0);
            float density_5 = density_2 * geometry_density_0;
            if(_S1390)
            {
                viewed_1 = _S1173 == 1U;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                return Shift_x24init_0(throughput_7 * emission_1 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1390)
            {
                refracted_4 = _S1173 == 0U;
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
            {
                bool _S1431 = !nee_0;
                if(_S1431)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S1432 = rgb_to_greyscale(light_3.radiance);
                    passes_0 = !(_S1432 > 0.0f);
                }
                if(passes_0)
                {
                    return _S1168;
                }
                return Shift_x24init_0(throughput_7 * lit_0 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1390)
            {
                wrong_side_0 = _S1173 == 4U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                bool _S1433 = !nee_0;
                if(_S1433)
                {
                    return _S1168;
                }
                float _S1434 = environmentPdf_0(r_8->dir);
                float3  _S1435 = skyBSDF((&ray_2)->unit_direction, r_8->dir, surface_12, _S1345, is_inside_6, _S1434, surface_12.random_state);
                return Shift_x24init_0(throughput_7 * _S1435 * r_8->radiance / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            uint _S1436 = extractBits_0(_S1169, 21U, 1U);
            bool _S1437 = nee_0 != (_S1436 == 1U);
            if(_S1437)
            {
                return _S1168;
            }
            throughput_6 = throughput_7;
            density_4 = density_5;
        }
        else
        {
            if(replay_1)
            {
                viewed_1 = _S1383;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                bool _S1438 = !scatter_2;
                if(_S1438)
                {
                    refracted_4 = true;
                }
                else
                {
                    bool _S1439 = _S1172 != 1U;
                    if(_S1439)
                    {
                        refracted_4 = _S1172 != 3U;
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
                bool _S1440 = _S1172 == 2U;
                if(_S1440)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1341;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1173 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    if(_S1350)
                    {
                        return _S1168;
                    }
                    uint _S1441 = stream(_S1195, b_5 + 448U);
                    FKRay _S1442 = ray_2;
                    FKSurface _S1443 = surface_12;
                    ShadowContext _S1444 = context_5;
                    SkySample _S1445 = sampleSky_0(&_S1442, &_S1443, _S1345, is_inside_6, _S1441, surface_12.random_state, &_S1444);
                    return Shift_x24init_0(throughput_5 * _S1445.color, 1.0f);
                }
                if(_S1440)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1341;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float _S1446 = rgb_to_greyscale(light_3.radiance);
                    bool _S1447 = !(_S1446 > 0.0f);
                    if(_S1447)
                    {
                        return _S1168;
                    }
                    return Shift_x24init_0(throughput_5 * lit_0, 1.0f);
                }
                if(_S1182)
                {
                    passes_0 = _S1173 == 2U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1309;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_5 * emission_1, 1.0f);
                }
                if(_S1182)
                {
                    passes_0 = _S1173 == 1U;
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
                    passes_0 = !_S1341;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_5 * emission_1, 1.0f);
                }
                return _S1168;
            }
            else
            {
                if(_S1359)
                {
                    wrong_side_0 = scatter_2;
                }
                else
                {
                    wrong_side_0 = false;
                }
                if(wrong_side_0)
                {
                    bool _S1448 = b_5 > 0U;
                    if(_S1448)
                    {
                        Reservoir candidate_5 = chain_0;
                        if(_S1373)
                        {
                            float3  _S1449 = safeDivide(throughput_5 * emission_1, chain_throughput_0);
                            (&candidate_5)->radiance = _S1449;
                        }
                        else
                        {
                            if(_S1341)
                            {
                                candidate_5 = here_0;
                            }
                        }
                        float3  _S1450 = throughput_5 * emission_1;
                        Reservoir _S1451 = withEnd(candidate_5, 1U, b_5, _S1450);
                        offer(sel_7, _S1451, _S1450 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    else
                    {
                        float3  _S1452 = throughput_5 * emission_1;
                        float3  _S1453 = sel_7->glow + _S1452;
                        sel_7->glow = _S1453;
                    }
                    if(nee_0)
                    {
                        float3  _S1454 = throughput_5 * lit_0;
                        Reservoir candidate_6 = chain_0;
                        if(_S1373)
                        {
                            float3  _S1455 = safeDivide(_S1454, chain_throughput_0);
                            (&candidate_6)->radiance = _S1455;
                        }
                        else
                        {
                            if(_S1341)
                            {
                                candidate_6 = here_0;
                                uint _S1456 = insertBits_0((&candidate_6)->path, 1U, 21U, 1U);
                                (&candidate_6)->path = _S1456;
                                (&candidate_6)->dir = light_3.dir;
                                (&candidate_6)->radiance = light_3.radiance;
                            }
                            else
                            {
                                uint _S1457 = insertBits_0(0U, b_5 + 1U, 5U, 5U);
                                uint _S1458 = insertBits_0(_S1457, 2U, 10U, 2U);
                                (&candidate_6)->path = _S1458;
                            }
                        }
                        Reservoir _S1459 = withEnd(candidate_6, 0U, b_5, _S1454);
                        offer(sel_7, _S1459, _S1454 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    if(nee_0)
                    {
                        if(_S1350)
                        {
                            _S1428 = false;
                        }
                        else
                        {
                            bool _S1460 = environmentMapped_0();
                            _S1428 = _S1460;
                        }
                    }
                    else
                    {
                        _S1428 = false;
                    }
                    if(_S1428)
                    {
                        uint _S1461 = (fcptMaxBounces());
                        _S1429 = b_5 < _S1461;
                    }
                    else
                    {
                        _S1429 = false;
                    }
                    if(_S1429)
                    {
                        uint _S1462 = stream(_S1195, b_5 + 448U);
                        FKRay _S1463 = ray_2;
                        FKSurface _S1464 = surface_12;
                        ShadowContext _S1465 = context_5;
                        SkySample _S1466 = sampleSky_0(&_S1463, &_S1464, _S1345, is_inside_6, _S1462, surface_12.random_state, &_S1465);
                        float3  _S1467 = throughput_5 * _S1466.color;
                        Reservoir candidate_7 = chain_0;
                        if(_S1373)
                        {
                            float3  _S1468 = safeDivide(_S1467, chain_throughput_0);
                            (&candidate_7)->radiance = _S1468;
                        }
                        else
                        {
                            if(_S1341)
                            {
                                candidate_7 = here_0;
                                uint _S1469 = insertBits_0((&candidate_7)->path, 1U, 21U, 1U);
                                (&candidate_7)->path = _S1469;
                                (&candidate_7)->dir = _S1466.dir;
                                (&candidate_7)->radiance = _S1466.radiance;
                            }
                            else
                            {
                                uint _S1470 = insertBits_0(0U, b_5 + 1U, 5U, 5U);
                                uint _S1471 = insertBits_0(_S1470, 2U, 10U, 2U);
                                (&candidate_7)->path = _S1471;
                            }
                        }
                        Reservoir _S1472 = withEnd(candidate_7, 4U, b_5, _S1467);
                        offer(sel_7, _S1472, _S1467 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                }
            }
            throughput_6 = throughput_5;
            density_4 = density_2;
        }
        bool _S1473;
        bool _S1474;
        bool _S1475;
        bool straight_0;
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
        bool _S1487;
        bool _S1488;
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
                viewed_1 = _S1383;
            }
            else
            {
                viewed_1 = false;
            }
            uint _S1489 = extractBits_0(_S1169, 15U, 3U);
            uint _S1490 = extractBits_0(_S1169, 18U, 3U);
            uint _S1491 = _slang_select(_S1382, _S1490,_S1489);
            float3  _S1492 = r_8->dir;
            bool refracted_5 = _S1491 == 1U;
            SampleBSDF _S1493 = SampleBSDF_x24init_0(_S1167, _S1167, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_5 = _S1493;
            float3  reconnection_1;
            if(viewed_1)
            {
                uint _S1494 = extractBits_0(_S1169, 22U, 1U);
                bool _S1495 = is_inside_6 != (_S1494 == 1U);
                if(_S1495)
                {
                    return _S1168;
                }
                bool _S1496 = _S1172 == 1U;
                if(_S1496)
                {
                    float3  _S1497 = (fcptHitPosition((_S1184)));
                    throughput_8 = _S1497;
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
                    BSDFMaterial _S1498 = _S1342.material;
                    bool _S1499 = isTranslucent_0(&_S1498);
                    if(_S1499)
                    {
                        refracted_4 = _S1491 == 0U;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                    if(refracted_4)
                    {
                        float3  _S1500 = throughput_8 - (&ray_2)->origin;
                        float3  _S1501 = _slang_select(_S1496, _S1500,_S1492);
                        wrong_side_0 = (dot_0(_S1343.smooth_n, _S1501) * _S1344) < 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    refracted_4 = wrong_side_0;
                }
                if(_S1496)
                {
                    float3  _S1502 = (&ray_2)->origin;
                    FKSurface _S1503 = surface_12;
                    float3  _S1504 = - _S1343.smooth_n;
                    bool _S1505 = is_inside_6 != refracted_4;
                    float3  _S1506 = _slang_select(_S1505, _S1504,_S1343.smooth_n);
                    float3  _S1507 = throughput_8 - (_S1502 + make_float3 (_S1503.geometry_offset) * _S1506);
                    float3  _S1508 = ((((_S1507)) * make_float3(rnorm3df(((_S1507)).x, ((_S1507)).y, ((_S1507)).z))));
                    reconnection_1 = _S1508;
                }
                else
                {
                    reconnection_1 = _S1492;
                }
                if(_S1350)
                {
                    wrong_side_0 = false;
                }
                else
                {
                    bool _S1509 = wrongSide_0(is_inside_6, refracted_4, reconnection_1, surface_12.geometry_n);
                    wrong_side_0 = _S1509;
                }
                if(wrong_side_0)
                {
                    return _S1168;
                }
                float3  _S1510 = throughput_8;
                throughput_8 = reconnection_1;
                b_8 = _S1491;
                wrong_side_0 = false;
                reconnection_1 = _S1510;
            }
            else
            {
                bool _S1511 = !_S1382;
                if(_S1511)
                {
                    SampleBSDF bsdf_sampled_0;
                    SampleBSDF _S1512;
                    if(_S1350)
                    {
                        SampleBSDF _S1513 = (fcptSampleHair((surface_12.hair), (_S1342.material.albedo), (_S1342.material.specular_tint), ((&ray_2)->unit_direction), (surface_12.random_state)));
                        _S1512 = _S1513;
                    }
                    else
                    {
                        SampleBSDF _S1514 = sampleBSDF((&ray_2)->unit_direction, _S1343.smooth_n, _S1342.material, _S1345.x, _S1345.y, surface_12.random_state, _S1399);
                        _S1512 = _S1514;
                    }
                    bsdf_sampled_0 = _S1512;
                    if(_S1350)
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
                            return _S1168;
                        }
                        break;
                    }
                    if(_S1350)
                    {
                        wrong_side_0 = false;
                    }
                    else
                    {
                        bool _S1515 = wrongSide_0(is_inside_6, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, surface_12.geometry_n);
                        wrong_side_0 = _S1515;
                    }
                    if(wrong_side_0)
                    {
                        _S1428 = (_S1342.material.transmission) > 0.0f;
                    }
                    else
                    {
                        _S1428 = false;
                    }
                    if(_S1428)
                    {
                        SampleBSDF _S1516 = sampleBSDF((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n, _S1342.material, _S1345.x, _S1345.y, (&bsdf_sampled_0)->random_state, _S1399);
                        (&bsdf_sampled_0)->unit_direction = _S1516.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1516.refracted;
                        (&bsdf_sampled_0)->throughput = _S1516.throughput;
                    }
                    else
                    {
                        if(wrong_side_0)
                        {
                            float3  _S1517 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n)) * surface_12.geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1517;
                        }
                    }
                    uint _S1518 = (&bsdf_sampled_0)->lobe;
                    float3  _S1519 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1520 = (&bsdf_sampled_0)->refracted;
                    lobe_5 = bsdf_sampled_0;
                    float _S1521 = (&bsdf_sampled_0)->pdf;
                    float _S1522 = _slang_select(wrong_side_0, 0.0f,_S1521);
                    (&lobe_5)->pdf = _S1522;
                    throughput_8 = _S1519;
                    b_8 = _S1518;
                    refracted_4 = _S1520;
                }
                else
                {
                    throughput_8 = _S1492;
                    b_8 = _S1491;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(viewed_1)
            {
                _S1428 = true;
            }
            else
            {
                _S1428 = _S1382;
            }
            float3  chain_throughput_1;
            if(_S1428)
            {
                if(_S1350)
                {
                    SampleBSDF _S1523 = (fcptConnectHair((surface_12.hair), (_S1342.material.albedo), (_S1342.material.specular_tint), ((&ray_2)->unit_direction), (throughput_8)));
                    lobe_5 = _S1523;
                }
                else
                {
                    float3  _S1524 = (&ray_2)->unit_direction;
                    float _S1525 = sign_0(_S1344);
                    float3  _S1526 = _S1343.smooth_n * make_float3 (_S1525);
                    float _S1527 = dot_0(_S1526, throughput_8);
                    float _S1528 = _S1342.material.roughness;
                    float _S1529 = _S1528 * _S1528;
                    AnisotropicFrame _S1530 = anisotropicFrame(_S1342.material, _S1526);
                    float3  _S1531 = negate_0(_S1524);
                    SheenProfile _S1532 = sheenProfile(_S1531, _S1526, _S1342.material);
                    float3  _S1533 = reflectedHalf(_S1524, throughput_8);
                    bool _S1534 = b_8 == 1U;
                    if(_S1534)
                    {
                        float3  _S1535 = refractedHalf(_S1524, throughput_8, _S1343.smooth_n, _S1345.x, _S1345.y);
                        throughput_9 = _S1535;
                    }
                    else
                    {
                        throughput_9 = _S1533;
                    }
                    bool _S1536 = b_8 == 0U;
                    if(_S1536)
                    {
                        _S1429 = true;
                    }
                    else
                    {
                        _S1429 = b_8 == 6U;
                    }
                    if(_S1429)
                    {
                        float3  _S1537 = sampledHalf(_S1524, _S1343.smooth_n, _S1342.material, surface_12.random_state, _S1530);
                        throughput_10 = _S1537;
                    }
                    else
                    {
                        throughput_10 = throughput_9;
                    }
                    float3  _S1538 = negate_0(_S1524);
                    float _S1539 = _S1345.x;
                    float _S1540 = _S1345.y;
                    BSDFLobes _S1541 = bsdfLobes(_S1524, _S1538, _S1526, throughput_10, _S1342.material, _S1539, _S1540, _S1530, _S1532);
                    BSDFLobes lobe_terms_1 = _S1541;
                    float _S1542 = translucentShare(_S1342.material);
                    (&lobe_terms_1)->translucent_share = _S1542;
                    switch(b_8)
                    {
                    case 0U:
                        {
                            float _S1543 = diffusePDF(_S1527, 0.0f, (F32_abs((_S1344))), _S1529, lobe_terms_1, _S1539, _S1540);
                            float3  _S1544 = diffuseBSDF(throughput_8, _S1526, _S1529, _S1342.material, lobe_terms_1);
                            density_6 = _S1543;
                            chain_throughput_1 = _S1544;
                            break;
                        }
                    case 1U:
                        {
                            float _S1545 = refractPDF(_S1527, dot_0(throughput_8, throughput_10), (F32_abs((_S1344))), _S1529, lobe_terms_1, _S1539, _S1540);
                            float3  _S1546 = refractBSDF(throughput_8, _S1526, _S1529, _S1342.material, lobe_terms_1);
                            density_6 = _S1545;
                            chain_throughput_1 = _S1546;
                            break;
                        }
                    case 4U:
                        {
                            float _S1547 = sheenVelvetPDF(_S1527, 0.0f, (F32_abs((_S1344))), _S1529, lobe_terms_1, _S1539, _S1540);
                            float3  _S1548 = sheenVelvetBSDF(throughput_8, _S1526, _S1529, _S1342.material, lobe_terms_1);
                            density_6 = _S1547;
                            chain_throughput_1 = _S1548;
                            break;
                        }
                    case 6U:
                        {
                            float _S1549 = toonPDF(_S1527, dot_0(throughput_8, (&lobe_terms_1)->toon_axis), (F32_abs((_S1344))), _S1529, lobe_terms_1, _S1539, _S1540);
                            float3  _S1550 = toonBSDF(throughput_8, _S1526, _S1529, _S1342.material, lobe_terms_1);
                            density_6 = _S1549;
                            chain_throughput_1 = _S1550;
                            break;
                        }
                    default:
                        {
                            float _S1551 = reflectPDF(_S1527, 0.0f, (F32_abs((_S1344))), _S1529, lobe_terms_1, _S1539, _S1540);
                            float3  _S1552 = reflectBSDF(throughput_8, _S1526, _S1529, _S1342.material, lobe_terms_1);
                            density_6 = _S1551;
                            chain_throughput_1 = _S1552;
                            break;
                        }
                    }
                    bool _S1553 = density_6 > 0.0f;
                    if(_S1553)
                    {
                        SampleBSDF _S1554 = SampleBSDF_x24init_0(throughput_8, chain_throughput_1, surface_12.random_state, _S1534, b_8, density_6);
                        lobe_5 = _S1554;
                    }
                }
            }
            bool _S1555 = b_8 == 0U;
            if(_S1555)
            {
                _S1429 = true;
            }
            else
            {
                _S1429 = b_8 == 4U;
            }
            if(_S1429)
            {
                _S1473 = true;
            }
            else
            {
                _S1473 = b_8 == 6U;
            }
            if(_S1350)
            {
                _S1474 = false;
            }
            else
            {
                bool _S1556 = !_S1473;
                if(_S1556)
                {
                    bool _S1557 = (_S1342.material.roughness) == 0.0f;
                    if(_S1557)
                    {
                        _S1474 = true;
                    }
                    else
                    {
                        bool _S1558 = b_8 == 1U;
                        if(_S1558)
                        {
                            _S1474 = (_S1345.x) == (_S1345.y);
                        }
                        else
                        {
                            _S1474 = false;
                        }
                    }
                }
                else
                {
                    _S1474 = false;
                }
            }
            bool _S1559 = !_S1350;
            if(_S1559)
            {
                _S1475 = b_8 == 1U;
            }
            else
            {
                _S1475 = false;
            }
            if(_S1475)
            {
                straight_0 = (_S1342.material.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S1476 = _S1559;
            }
            else
            {
                _S1476 = false;
            }
            if(_S1476)
            {
                _S1477 = b_8 == 1U;
            }
            else
            {
                _S1477 = false;
            }
            if(_S1477)
            {
                _S1478 = (_S1345.x) == (_S1345.y);
            }
            else
            {
                _S1478 = false;
            }
            BSDFMaterial _S1560 = _S1342.material;
            bool _S1561 = isTranslucent_0(&_S1560);
            if(_S1561)
            {
                _S1479 = _S1555;
            }
            else
            {
                _S1479 = false;
            }
            if(_S1479)
            {
                _S1480 = (dot_0(throughput_8, surface_12.geometry_n)) < 0.0f;
            }
            else
            {
                _S1480 = false;
            }
            if(nee_0)
            {
                _S1481 = !_S1474;
            }
            else
            {
                _S1481 = false;
            }
            if(_S1481)
            {
                _S1482 = !wrong_side_0;
            }
            else
            {
                _S1482 = false;
            }
            if(_S1482)
            {
                float _S1562 = (&lobe_5)->pdf;
                float3  _S1563 = (&ray_2)->origin;
                float3  _S1564 = _slang_select(_S1355, _S1167,_S1343.smooth_n);
                float3  _S1565 = (&ray_2)->origin;
                FKSurface _S1566 = surface_12;
                float3  _S1567 = - _S1343.smooth_n;
                float3  _S1568 = _slang_select(_S1480, _S1567,_S1343.smooth_n);
                NEEVertex _S1569 = NEEVertex_x24init_0(false, _S1562, _S1563, _S1564, _S1565 + make_float3 (_S1566.geometry_offset) * _S1568);
                nee_vertex_0 = _S1569;
            }
            else
            {
                if(_S1350)
                {
                    _S1483 = true;
                }
                else
                {
                    bool _S1570 = b_8 != 1U;
                    if(_S1570)
                    {
                        _S1483 = true;
                    }
                    else
                    {
                        _S1483 = (_S1345.x) != (_S1345.y);
                    }
                }
                if(_S1483)
                {
                    (&nee_vertex_0)->none = true;
                }
            }
            bool _S1571 = ((&lobe_5)->pdf) > 0.0f;
            if(_S1571)
            {
                if(_S1473)
                {
                    _S1483 = true;
                }
                else
                {
                    _S1483 = ((&lobe_5)->pdf * (&prev_0)->cos / ((&hit_4)->distance * (&hit_4)->distance) * threshold_0) <= 1.0f;
                }
            }
            else
            {
                _S1483 = false;
            }
            bool _S1572 = ((&lobe_5)->pdf) > 0.0f;
            if(_S1572)
            {
                if(_S1473)
                {
                    _S1484 = true;
                }
                else
                {
                    _S1484 = (_S1342.material.roughness) >= 0.20000000298023224f;
                }
            }
            else
            {
                _S1484 = false;
            }
            if(_S1382)
            {
                bool _S1573 = !_S1483;
                if(_S1573)
                {
                    return _S1168;
                }
                bool _S1574 = _S1173 != 1U;
                if(_S1574)
                {
                    _S1485 = _S1173 != 2U;
                }
                else
                {
                    _S1485 = false;
                }
                if(_S1485)
                {
                    float _S1575 = (&lobe_5)->pdf;
                    float _S1576 = _slang_select(nee_0, _S1575,0.0f);
                    float _S1577 = escapeWeight_0(_S1576, _S1492);
                    if(_S1390)
                    {
                        passes_0 = _S1179;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1578 = _slang_select(passes_0, _S1577,1.0f);
                    return Shift_x24init_0(throughput_6 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf)) * r_8->radiance * make_float3 (_S1578) / make_float3 (r_8->jac), density_4 * (&lobe_5)->pdf / r_8->jac);
                }
                float3  _S1579 = throughput_6 * make_float3 ((&lobe_5)->pdf);
                float _S1580 = density_4 * (&lobe_5)->pdf;
                throughput_9 = _S1579;
                density_6 = _S1580;
            }
            else
            {
                throughput_9 = throughput_6;
                density_6 = density_4;
            }
            uint _S1581 = (fcptLayers((hit_4)));
            bool _S1582 = _S1581 > 1U;
            if(_S1582)
            {
                _S1485 = (b_8 == 1U) != passes_0;
            }
            else
            {
                _S1485 = false;
            }
            if(viewed_1)
            {
                _S1486 = _S1485;
            }
            else
            {
                _S1486 = false;
            }
            if(_S1486)
            {
                return _S1168;
            }
            if(replay_1)
            {
                _S1487 = b_5 <= _S1183;
            }
            else
            {
                _S1487 = false;
            }
            if(_S1487)
            {
                _S1488 = _S1341;
            }
            else
            {
                _S1488 = false;
            }
            bool _S1583;
            if(_S1488)
            {
                _S1583 = _S1483;
            }
            else
            {
                _S1583 = false;
            }
            bool _S1584;
            if(_S1583)
            {
                _S1584 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S1584 = !_S1484;
                }
                else
                {
                    _S1584 = false;
                }
            }
            if(_S1584)
            {
                return _S1168;
            }
            if(viewed_1)
            {
                float3  _S1585 = throughput_9 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf));
                float _S1586 = (&lobe_5)->pdf;
                throughput_10 = _S1585;
                sky_pdf_2 = _S1586;
            }
            else
            {
                float3  _S1587 = throughput_9 * max_0((&lobe_5)->throughput, _S1167);
                throughput_10 = _S1587;
                sky_pdf_2 = density_6;
            }
            bool _S1588;
            if(_S1359)
            {
                _S1588 = !_S1373;
            }
            else
            {
                _S1588 = false;
            }
            bool _S1589;
            if(_S1588)
            {
                _S1589 = _S1341;
            }
            else
            {
                _S1589 = false;
            }
            bool _S1590;
            if(_S1589)
            {
                _S1590 = _S1483;
            }
            else
            {
                _S1590 = false;
            }
            if(_S1590)
            {
                chain_0 = here_0;
                uint _S1591 = insertBits_0((&chain_0)->path, b_8, 18U, 3U);
                uint _S1592 = _slang_select(nee_0, 1U,0U);
                uint _S1593 = insertBits_0(_S1591, _S1592, 21U, 1U);
                (&chain_0)->path = _S1593;
                float _S1594 = (&chain_0)->jac * (&lobe_5)->pdf;
                (&chain_0)->jac = _S1594;
                (&chain_0)->dir = throughput_8;
                chain_throughput_1 = throughput_10;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            FKSurface _S1595 = surface_12;
            Vertex _S1596 = Vertex_x24init_0(_S1484, b_8, (&lobe_5)->pdf, (F32_abs((dot_0(surface_12.geometry_n, throughput_8)))), is_inside_6);
            prev_0 = _S1596;
            float _S1597 = (&lobe_5)->pdf;
            bool _S1598 = b_8 == 1U;
            bool _S1599;
            if(_S1598)
            {
                _S1599 = (_S1345.x) == (_S1345.y);
            }
            else
            {
                _S1599 = false;
            }
            float sky_pdf_3 = _slang_select(_S1599, sky_pdf_0,_S1597);
            float _S1600 = _slang_select(_S1350, 0.0f,sky_pdf_3);
            float _S1601 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * (&lobe_5)->pdf))))), (3.14159274101257324f)));
            bool _S1602 = !_S1474;
            float _S1603 = _slang_select(_S1602, _S1601,0.0f);
            float _S1604 = spread_1 + _S1603;
            bool _S1605;
            if(refracted_4)
            {
                _S1605 = !_S1480;
            }
            else
            {
                _S1605 = false;
            }
            bool is_inside_7;
            if(_S1605)
            {
                bool _S1606 = !is_inside_6;
                is_inside_7 = _S1606;
            }
            else
            {
                is_inside_7 = is_inside_6;
            }
            FKSurface _S1607 = surface_12;
            bool _S1608 = boundsVolume_0(&_S1607);
            bool _S1609;
            if(_S1608)
            {
                _S1609 = !_S1485;
            }
            else
            {
                _S1609 = false;
            }
            if(_S1609)
            {
                FKSurface faced_2 = surface_12;
                float3  _S1610 = - _S1595.geometry_n;
                float3  _S1611 = _slang_select(turned_1, _S1610,_S1595.geometry_n);
                (&faced_2)->geometry_n = _S1611;
                FKMedium _S1612 = Medium_x24init_0(scatter_in_0, extinction_in_0, g_in_0);
                FKMedium _S1613 = (fcptOutsideMedium((hit_4)));
                FKSurface _S1614 = faced_2;
                FKMedium _S1615 = _S1612;
                FKMedium _S1616 = _S1613;
                MediumSides _S1617 = mediumSides_0(&_S1614, &_S1615, filling_2, (&ray_2)->unit_direction, &_S1616);
                bool _S1618 = ((dot_0(throughput_8, _S1595.geometry_n)) > 0.0f) == ((dot_0(_S1595.geometry_n, (&faced_2)->geometry_n)) > 0.0f);
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
            bool _S1627 = !_S1485;
            if(_S1627)
            {
                FKSurface _S1628 = surface_12;
                float _S1629 = _slang_select(straight_0, 0.0f,_S1628.geometry_offset);
                float3  _S1630 = - _S1343.smooth_n;
                bool _S1631 = is_inside_7 != _S1480;
                float3  _S1632 = _slang_select(_S1631, _S1630,_S1343.smooth_n);
                float3  _S1633 = (&ray_2)->origin + make_float3 (_S1629) * _S1632;
                (&ray_2)->origin = _S1633;
            }
            throughput_9 = throughput_10;
            chain_throughput_0 = chain_throughput_1;
            density_6 = sky_pdf_2;
            passes_0 = _S1485;
            viewed_1 = _S1478;
            sky_pdf_2 = _S1600;
            spread_4 = _S1604;
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
        if(_S1359)
        {
            if(_S1309)
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
                Reservoir _S1638 = withEnd(candidate_8, 2U, b_5, _S1634);
                offer(sel_7, _S1638, _S1634 * make_float3 (scale_3) / make_float3 (density_6));
            }
            if(_S1309)
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
            uint _S1640 = stream(_S1195, b_5 + 128U);
            Random _S1641 = pcg(_S1640);
            bool _S1642 = density_7 < (_S1641.value);
            if(_S1642)
            {
                wrong_side_0 = true;
            }
            else
            {
                uint _S1643 = (fcptMaxBounces());
                wrong_side_0 = b_5 >= _S1643;
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
            b_8 = b_5;
            viewed_0 = viewed_1;
            throughput_2 = throughput_9;
            density_2 = density_7;
            sky_pdf_0 = sky_pdf_2;
            spread_1 = spread_4;
            uint _S1647 = b_8 + 1U;
            b_5 = _S1647;
            layer_0 = _S1646;
            continue;
        }
        FKRay _S1648 = ray_2;
        float _S1649 = distance_1(reconnection_0, (&ray_2)->origin) * 1.0010000467300415f;
        if(replay_1)
        {
            refracted_4 = _S1383;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            wrong_side_0 = _S1172 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S1650 = _slang_select(wrong_side_0, _S1649,4.294967296e+09f);
        bool _S1651 = !_S1350;
        if(straight_0)
        {
            _S1428 = true;
        }
        else
        {
            _S1428 = _S1350;
        }
        FKHit _S1652;
        if(_S1428)
        {
            _S1652 = hit_4;
        }
        else
        {
            _S1652 = _S1400;
        }
        FKHit _S1653 = (fcptTraverseInstanceBVH((_S1648), (_S1316), (_S1650), (_S1651), (_S1652), (viewed_1)));
        hit_4 = _S1653;
        if(replay_1)
        {
            _S1429 = _S1383;
        }
        else
        {
            _S1429 = false;
        }
        if(_S1429)
        {
            _S1473 = _S1172 == 1U;
        }
        else
        {
            _S1473 = false;
        }
        if(_S1473)
        {
            _S1474 = ((&hit_4)->instance_index) == (_S1184.instance_index);
        }
        else
        {
            _S1474 = false;
        }
        if(_S1474)
        {
            _S1475 = ((&hit_4)->triangle_index) == (_S1184.triangle_index);
        }
        else
        {
            _S1475 = false;
        }
        if(_S1475)
        {
            (&hit_4)->uv = _S1184.uv;
            float _S1654 = distance_1(reconnection_0, (&ray_2)->origin);
            (&hit_4)->distance = _S1654;
        }
        if(replay_1)
        {
            _S1476 = _S1383;
        }
        else
        {
            _S1476 = false;
        }
        if(_S1476)
        {
            _S1477 = _S1172 == 3U;
        }
        else
        {
            _S1477 = false;
        }
        if(_S1477)
        {
            _S1478 = ((&hit_4)->instance_index) != 4294967295U;
        }
        else
        {
            _S1478 = false;
        }
        if(_S1478)
        {
            return _S1168;
        }
        Reservoir _S1655 = chain_0;
        uint _S1656 = filling_2;
        for(;;)
        {
            bool _S1657 = (fcptVaryingUsed());
            if(_S1657)
            {
                _S1479 = _S1656 != 4294967295U;
            }
            else
            {
                _S1479 = false;
            }
            float _S1658;
            if(_S1479)
            {
                float _S1659 = (fcptMajorant((_S1656)));
                _S1658 = _S1659;
            }
            else
            {
                _S1658 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
            }
            if(replay_1)
            {
                _S1480 = _S1383;
            }
            else
            {
                _S1480 = false;
            }
            if(_S1480)
            {
                _S1481 = _S1172 == 1U;
            }
            else
            {
                _S1481 = false;
            }
            if(_S1481)
            {
                _S1482 = _S1658 > 0.0f;
            }
            else
            {
                _S1482 = false;
            }
            if(_S1482)
            {
                ended_0 = _S1168;
                sky_pdf_1 = sky_pdf_2;
                spread_2 = spread_4;
                width_4 = width_3;
                density_3 = density_7;
                throughput_10 = throughput_9;
                b_8 = b_5;
                _S1483 = true;
                break;
            }
            bool _S1660 = (&prev_0)->rough;
            if(_S1660)
            {
                _S1483 = !(_S1658 > 0.0f);
            }
            else
            {
                _S1483 = false;
            }
            (&prev_0)->rough = _S1483;
            uint _S1661 = b_5 + 320U;
            bool _S1662 = b_5 == 4294967295U;
            uint _S1663 = _slang_select(_S1662, 384U,_S1661);
            uint _S1664 = stream(_S1195, _S1663);
            uint tracking_1 = _S1664;
            weight_1 = throughput_3;
            glowed_0 = _S1167;
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
                    _S1166 = int(2);
                    break;
                }
                uint _S1665 = b_8 + 320U;
                bool _S1666 = b_8 == 4294967295U;
                uint _S1667 = _slang_select(_S1666, 384U,_S1665);
                uint _S1668 = stream(_S1195, _S1667);
                Random _S1669 = pcg(_S1668);
                float _S1670 = - (F32_log((1.0f - _S1669.value))) / _S1658;
                if(_S1479)
                {
                    float3  _S1671 = (&ray_2)->origin;
                    float3  _S1672 = (&ray_2)->unit_direction;
                    float _S1673 = (&hit_4)->distance;
                    uint _S1674 = _slang_select(_S1666, 0U,b_8);
                    uint _S1675 = (&prev_0)->lobe;
                    uint _S1676 = _slang_select(_S1666, 3U,_S1675);
                    float _S1677 = (fcptTrackMedium((_S1656), (_S1671), (_S1672), (_S1673), (&tracking_1), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1674), (_S1676), (_S1666)));
                    spread_3 = _S1677;
                }
                else
                {
                    spread_3 = _S1670;
                }
                bool _S1678 = !(spread_3 < ((&hit_4)->distance));
                if(_S1678)
                {
                    _S1166 = int(2);
                    break;
                }
                if(_S1479)
                {
                    _S1484 = _S1359;
                }
                else
                {
                    _S1484 = false;
                }
                if(_S1484)
                {
                    float3  _S1679 = throughput_10 * glowed_0 / make_float3 (density_3);
                    float3  _S1680 = sel_7->glow + _S1679;
                    sel_7->glow = _S1680;
                }
                else
                {
                }
                glowed_0 = _S1167;
                uint b_9 = b_8 + 1U;
                float3  _S1681 = (&ray_2)->origin + make_float3 (spread_3) * (&ray_2)->unit_direction;
                (&ray_2)->origin = _S1681;
                float3  _S1682 = flightWeight_0(scatter_in_0, extinction_in_0, _S1658, spread_3, true);
                float3  _S1683 = weight_1;
                float3  _S1684 = _slang_select(_S1479, _S1683,_S1682);
                float3  throughput_11 = throughput_10 * _S1684;
                uint _S1685 = stream(_S1195, b_9 + 320U);
                tracking_1 = _S1685;
                weight_1 = throughput_3;
                float width_7 = width_4 + spread_2 * spread_3;
                float _S1686 = spread_2 + 3.14159274101257324f;
                if(_S1359)
                {
                    _S1485 = true;
                }
                else
                {
                    bool _S1687 = b_9 == _S1183;
                    if(_S1687)
                    {
                        _S1485 = !_S1479;
                    }
                    else
                    {
                        _S1485 = false;
                    }
                }
                TreeSample light_4;
                if(_S1485)
                {
                    float3  _S1688 = (&ray_2)->origin;
                    float3  _S1689 = (&ray_2)->unit_direction;
                    float3  _S1690 = (&ray_2)->unit_direction;
                    uint _S1691 = stream(_S1195, b_9 + 64U);
                    float3  _S1692 = extinction_in_0;
                    float3  _S1693 = extinction_in_0;
                    uint2  _S1694 = make_uint2 (_S1656);
                    float3  _S1695 = (&ray_2)->unit_direction;
                    uint _S1696 = arrivalLobe_0(b_9, (&prev_0)->lobe);
                    FKHit _S1697 = _S1400;
                    ShadowContext _S1698 = ShadowContext_x24init_0(_S1692, _S1693, _S1694, _S1695, b_9, _S1696, false, spread_3, width_7, &_S1697, false);
                    ShadowContext _S1699 = _S1698;
                    TreeSample _S1700 = sampleLightTree_0(_S1688, _S1689, _S1690, 0.0f, true, _S1691, &_S1699);
                    light_4 = _S1700;
                }
                else
                {
                    light_4 = _S1397;
                }
                float _S1701 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_4.dir));
                uint _S1702 = (fcptMaxBounces());
                bool _S1703 = b_9 < _S1702;
                if(_S1703)
                {
                    _S1486 = (light_4.density) > 0.0f;
                }
                else
                {
                    _S1486 = false;
                }
                float _S1704 = _slang_select(_S1486, _S1701,0.0f);
                float3  _S1705 = throughput_11 * light_4.radiance;
                float _S1706 = powerHeuristic(light_4.density, _S1704);
                float3  _S1707 = _S1705 * make_float3 (_S1701 * _S1706);
                float3  _S1708 = _slang_select(_S1485, _S1707,_S1167);
                if(replay_1)
                {
                    _S1487 = b_9 == _S1183;
                }
                else
                {
                    _S1487 = false;
                }
                if(_S1487)
                {
                    bool _S1709 = _S1172 == 2U;
                    if(_S1709)
                    {
                        float _S1710 = rgb_to_greyscale(_S1708);
                        _S1488 = _S1710 > 0.0f;
                    }
                    else
                    {
                        _S1488 = false;
                    }
                    if(_S1488)
                    {
                        Shift _S1711 = Shift_x24init_0(_S1708, 1.0f);
                        _S1166 = int(1);
                        ended_0 = _S1711;
                        spread_3 = _S1686;
                        width_5 = width_7;
                        throughput_8 = throughput_11;
                        b_6 = b_9;
                        break;
                    }
                    _S1166 = int(1);
                    ended_0 = _S1168;
                    spread_3 = _S1686;
                    width_5 = width_7;
                    throughput_8 = throughput_11;
                    b_6 = b_9;
                    break;
                }
                if(_S1359)
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
                        uint _S1715 = insertBits_0(0U, b_9 + 1U, 5U, 5U);
                        uint _S1716 = insertBits_0(_S1715, 2U, 10U, 2U);
                        (&candidate_9)->path = _S1716;
                    }
                    Reservoir _S1717 = withEnd(candidate_9, 0U, b_9, _S1708);
                    offer(sel_7, _S1717, _S1708 * make_float3 (scale_3) / make_float3 (density_3));
                    float _S1718 = survivalProbability(throughput_11, density_3);
                    uint _S1719 = stream(_S1195, b_9 + 128U);
                    Random _S1720 = pcg(_S1719);
                    bool _S1721 = _S1718 < (_S1720.value);
                    if(_S1721)
                    {
                        _S1488 = true;
                    }
                    else
                    {
                        uint _S1722 = (fcptMaxBounces());
                        _S1488 = b_9 >= _S1722;
                    }
                    if(_S1488)
                    {
                        _S1166 = int(1);
                        ended_0 = _S1168;
                        spread_3 = _S1686;
                        width_5 = width_7;
                        throughput_8 = throughput_11;
                        b_6 = b_9;
                        break;
                    }
                    float _S1723 = density_3 * _S1718;
                    density_3 = _S1723;
                }
                else
                {
                }
                float phase_pdf_1 = 0.0f;
                uint _S1724 = stream(_S1195, b_9);
                float3  _S1725 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1724, &phase_pdf_1);
                (&ray_2)->unit_direction = _S1725;
                NEEVertex _S1726 = NEEVertex_x24init_0(false, phase_pdf_1, (&ray_2)->origin, _S1167, (&ray_2)->origin);
                nee_vertex_0 = _S1726;
                Vertex _S1727 = Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_5);
                prev_0 = _S1727;
                float _S1728 = (&prev_0)->pdf;
                FKRay _S1729 = ray_2;
                FKHit _S1730 = (fcptTraverseInstanceBVH((_S1729), (true), (4.294967296e+09f), (false), (_S1400), (false)));
                hit_4 = _S1730;
                b_8 = b_9;
                throughput_10 = throughput_11;
                spread_2 = _S1686;
                width_4 = width_7;
                sky_pdf_1 = _S1728;
            }
            if(_S1166 != int(2))
            {
                spread_2 = spread_3;
                width_4 = width_5;
                throughput_10 = throughput_8;
                b_8 = b_6;
                _S1483 = true;
                break;
            }
            ended_0 = _S1168;
            _S1483 = false;
            break;
        }
        if(_S1483)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S1484 = b_8 == b_5;
        }
        else
        {
            _S1484 = false;
        }
        bool _S1731 = ((&hit_4)->instance_index) == 4294967295U;
        if(_S1731)
        {
            bool _S1732 = !(&nee_vertex_0)->none;
            float _S1733 = _slang_select(_S1732, sky_pdf_1,0.0f);
            float _S1734 = escapeWeight_0(_S1733, (&ray_2)->unit_direction);
            float3  _S1735 = environment_0((&ray_2)->unit_direction, b_8, (&prev_0)->lobe);
            float3  _S1736 = throughput_10 * _S1735;
            if(replay_1)
            {
                bool _S1737 = b_8 == _S1183;
                if(_S1737)
                {
                    passes_0 = _S1172 == 3U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(_S1736 * make_float3 (_S1734) / make_float3 (r_8->jac), density_3 / r_8->jac);
                }
                if(_S1182)
                {
                    passes_0 = _S1179;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = b_8 == _S1170;
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
                return _S1168;
            }
            Reservoir candidate_10 = chain_0;
            uint _S1738 = extractBits_0((&chain_0)->path, 10U, 2U);
            bool _S1739 = _S1738 == 1U;
            if(_S1739)
            {
                uint _S1740 = extractBits_0((&chain_0)->path, 5U, 5U);
                bool _S1741 = _S1740 == b_8;
                float _S1742 = _slang_select(_S1741, 1.0f,_S1734);
                float3  _S1743 = safeDivide(_S1736 * make_float3 (_S1742), chain_throughput_0);
                (&candidate_10)->radiance = _S1743;
            }
            else
            {
                bool _S1744 = (&prev_0)->rough;
                if(_S1744)
                {
                    uint _S1745 = insertBits_0(0U, b_8 + 1U, 5U, 5U);
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
            Reservoir _S1752 = withEnd(candidate_10, 3U, b_8, _S1751);
            offer(sel_7, _S1752, _S1751 * make_float3 (scale_3) / make_float3 (density_3));
            break;
        }
        float3  _S1753 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
        (&ray_2)->origin = _S1753;
        bool _S1754 = (fcptVaryingUsed());
        if(_S1754)
        {
            _S1485 = filling_2 != 4294967295U;
        }
        else
        {
            _S1485 = false;
        }
        if(_S1485)
        {
            if(_S1359)
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
        float _S1760 = width_4 + spread_2 * (&hit_4)->distance;
        viewed_0 = _S1484;
        width_3 = _S1760;
        throughput_2 = throughput_8;
        density_2 = density_3;
        sky_pdf_0 = sky_pdf_1;
        spread_1 = spread_2;
        uint _S1647 = b_8 + 1U;
        b_5 = _S1647;
        layer_0 = _S1646;
    }
    return _S1168;
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

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_12)
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
    float3  t_22 = (_S1771 * make_float3 (_S1776) - _S1772 * make_float3 (_S1777)) * make_float3 (_S1780);
    float3  _S1781 = (_S1772 * make_float3 (_S1775) - _S1771 * make_float3 (_S1778)) * make_float3 (_S1780);
    float3  _S1782 = t_22 - n_12 * make_float3 (dot_0(n_12, t_22));
    float3  t_23 = ((((_S1782)) * make_float3(rnorm3df(((_S1782)).x, ((_S1782)).y, ((_S1782)).z))));
    bool _S1783 = (dot_0(cross_0(n_12, t_23), _S1781)) > 0.0f;
    float3  t_24;
    if(_S1783)
    {
        float3  _S1784 = negate_0(t_23);
        t_24 = _S1784;
    }
    else
    {
        t_24 = t_23;
    }
    float3  _S1785 = cross_0(n_12, t_24);
    return makeMatrix<float, 3, 3> (t_24, _S1785, n_12);
}

__device__ float3  tangentToWorldNormalMap(float3  v_5, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_5, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_4, float3  uvw_0, float3  position_0)
{
    float3  _S1786 = t1_0 - t0_0;
    float3  _S1787 = t2_2 - t0_0;
    float3  _S1788 = t2_2 - t1_0;
    float _S1789 = (F32_min((length_0(_S1786)), ((F32_min((length_0(_S1787)), (length_0(_S1788)))))));
    float3  _S1790 = make_float3 (distance_1(position_0, t0_0), distance_1(position_0, t1_0), distance_1(position_0, t2_2));
    float3  _S1791 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S1792 = dot_0(geometry_n_4, _S1791);
    float3  _S1793 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S1794 = dot_0(geometry_n_4, _S1793);
    float3  _S1795 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S1796 = acos_0(abs_0(make_float3 (_S1792, _S1794, dot_0(geometry_n_4, _S1795))));
    float3  _S1797 = clamp_2(tan_0(_S1796), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_1(dot_0(_S1790 * _S1797, uvw_0), 0.0f, _S1789 * 0.125f);
}

__device__ float3  straightThrough(float3  dir_14, float3  n_13, BSDFMaterial material_23)
{
    float3  _S1798 = negate_0(dir_14);
    float _S1799 = sign_0(dot_0(n_13, _S1798));
    float3  _S1800 = n_13 * make_float3 (_S1799);
    AnisotropicFrame _S1801 = anisotropicFrame(material_23, _S1800);
    bool _S1802 = (_S1801.alphas.x) > 0.0f;
    if(_S1802)
    {
        float _S1803 = material_23.transmission * (1.0f - material_23.metallic);
        float3  _S1804 = negate_0(_S1800);
        float3  _S1805 = anisotropicLocal(dir_14, _S1801.tangent, _S1804);
        float _S1806 = anisotropicG1(_S1805, _S1801.alphas);
        return make_float3 (_S1803 * _S1806) * material_23.albedo;
    }
    float _S1807 = material_23.transmission * (1.0f - material_23.metallic);
    float _S1808 = material_23.roughness;
    float _S1809 = smithG1(_S1808 * _S1808, (F32_abs((dot_0(n_13, dir_14)))));
    return make_float3 (_S1807 * _S1809) * material_23.albedo;
}

__device__ float hairRow(float3  in_dir_11, float3  t_25, float3  out_dir_3, uint p_12, float w_2, float alpha_20, uint nt_0)
{
    uint _S1810 = p_12 % 4U;
    float _S1811 = w_2 * HAIR_WIDTHS_0[_S1810];
    float _S1812 = (F32_asin((clamp_1(dot_0(out_dir_3, t_25), -1.0f, 1.0f)))) - (F32_asin((clamp_1(dot_0(in_dir_11, t_25), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S1810] * alpha_20;
    return ((F32_asinh((_S1812 / _S1811))) / (F32_asinh((3.14159274101257324f / _S1811))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_12, float3  t_26, float3  out_dir_4, uint np_0)
{
    float3  _S1813 = worldToTangent(out_dir_4, t_26);
    float3  _S1814 = worldToTangent(in_dir_12, t_26);
    return (F32_frac((((F32_atan2((_S1813.z), (_S1813.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S1814.z), (1.17549435082228751e-38f - _S1814.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_13, float3  t_27, uint p_13, float row_0, float column_0, float w_3, float alpha_21, uint nt_1, uint np_1)
{
    float3  _S1815 = worldToTangent(in_dir_13, t_27);
    uint _S1816 = p_13 % 4U;
    float _S1817 = w_3 * HAIR_WIDTHS_0[_S1816];
    float _S1818 = (F32_asin((clamp_1(dot_0(in_dir_13, t_27), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S1816] * alpha_21 + _S1817 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S1817))))));
    float _S1819 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S1815.z), (1.17549435082228751e-38f - _S1815.x)));
    float _S1820 = (F32_cos((_S1818)));
    float3  _S1821 = tangentToWorld(make_float3 (_S1820 * (F32_cos((_S1819))), (F32_sin((_S1818))), _S1820 * (F32_sin((_S1819)))), t_27);
    return _S1821;
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_14, BSDFMaterial material_24, float coverage_1)
{
    float3  _S1822;
    if((material_24.ior) == 1.0f)
    {
        float3  _S1823 = straightThrough(toward_1, n_14, material_24);
        _S1822 = _S1823;
    }
    else
    {
        _S1822 = make_float3 (0.0f);
    }
    return _S1822 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ Shift walk_hook(Domain dom_8, Reservoir r_9, bool replay_2, float scale_4, Selection * sel_8)
{
    Domain _S1824 = dom_8;
    Reservoir _S1825 = r_9;
    Shift _S1826 = walk_0(&_S1824, &_S1825, replay_2, scale_4, sel_8);
    return _S1826;
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
