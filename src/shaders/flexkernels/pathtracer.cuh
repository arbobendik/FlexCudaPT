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

__device__ static const FixedArray<float, 576>  VELVET_ALBEDO_0 = { {
    1.00383996963500977f, 1.00428998470306396f, 1.00356996059417725f, 1.00303995609283447f, 1.00261998176574707f, 1.00229001045227051f, 1.00198996067047119f, 1.00171005725860596f, 1.00144004821777344f, 1.00120997428894043f, 1.00102996826171875f, 1.00092005729675293f, 1.00088000297546387f, 1.0009000301361084f, 1.00095999240875244f, 1.00106000900268555f, 1.00115001201629639f, 1.00124001502990723f, 1.001289963722229f, 1.0013200044631958f, 1.00133001804351807f, 1.00133001804351807f, 1.0013200044631958f, 1.00129997730255127f, 0.99086397886276245f, 0.9934689998626709f, 0.99439799785614014f, 0.99513500928878784f, 0.99574202299118042f, 0.9962649941444397f, 0.99671798944473267f, 0.99709898233413696f, 0.997406005859375f, 0.99764800071716309f, 0.99783498048782349f, 0.99798601865768433f, 0.99811899662017822f, 0.99825501441955566f, 0.99840497970581055f, 0.99857097864151001f, 0.99874699115753174f, 0.99892902374267578f, 0.9990919828414917f, 0.99923902750015259f, 0.99936902523040771f, 0.99948000907897949f, 0.99957501888275146f, 0.99965798854827881f, 0.94088798761367798f, 0.95128101110458374f, 0.95866602659225464f, 0.96450901031494141f, 0.96921002864837646f, 0.973052978515625f, 0.97623497247695923f, 0.97890102863311768f, 0.98115700483322144f, 0.98308497667312622f, 0.98474901914596558f, 0.98619699478149414f, 0.98746699094772339f, 0.98858797550201416f, 0.98958402872085571f, 0.99047297239303589f, 0.99127000570297241f, 0.99198299646377563f, 0.99262100458145142f, 0.99318897724151611f, 0.99372398853302002f, 0.99426800012588501f, 0.99475300312042236f, 0.99514400959014893f, 0.86131101846694946f, 0.88463401794433594f, 0.90212702751159668f, 0.91595500707626343f, 0.92708200216293335f, 0.93617302179336548f, 0.94370102882385254f, 0.95000702142715454f, 0.95534700155258179f, 0.9599120020866394f, 0.96384698152542114f, 0.96726799011230469f, 0.97026199102401733f, 0.97289901971817017f, 0.97523599863052368f, 0.97731602191925049f, 0.97917401790618896f, 0.98083901405334473f, 0.98233497142791748f, 0.98368102312088013f, 0.98489302396774292f, 0.98598498106002808f, 0.98697298765182495f, 0.98787301778793335f, 0.75306302309036255f, 0.79328000545501709f, 0.82418698072433472f, 0.84881901741027832f, 0.86874997615814209f, 0.88506197929382324f, 0.89858502149581909f, 0.9099239706993103f, 0.91952997446060181f, 0.9277459979057312f, 0.93483197689056396f, 0.94099199771881104f, 0.9463840126991272f, 0.95113497972488403f, 0.95534402132034302f, 0.95908999443054199f, 0.9624369740486145f, 0.96543699502944946f, 0.96813201904296875f, 0.97055697441101074f, 0.97274202108383179f, 0.97471201419830322f, 0.97649002075195312f, 0.97809398174285889f, 0.62183499336242676f, 0.68052101135253906f, 0.72705197334289551f, 0.76452702283859253f, 0.79505598545074463f, 0.82021200656890869f, 0.84120297431945801f, 0.85885602235794067f, 0.87384098768234253f, 0.88667500019073486f, 0.89775800704956055f, 0.90739899873733521f, 0.91584599018096924f, 0.92329102754592896f, 0.929889976978302f, 0.93576502799987793f, 0.94101500511169434f, 0.94572198390960693f, 0.94994997978210449f, 0.95375597476959229f, 0.95718497037887573f, 0.9602770209312439f, 0.96306699514389038f, 0.96558600664138794f, 0.47742500901222229f, 0.5522189736366272f, 0.61415499448776245f, 0.66520899534225464f, 0.70744901895523071f, 0.74262100458145142f, 0.77213901281356812f, 0.7971159815788269f, 0.81841897964477539f, 0.83673000335693359f, 0.85258400440216064f, 0.86640900373458862f, 0.87854301929473877f, 0.88924998044967651f, 0.89874798059463501f, 0.90721100568771362f, 0.91477799415588379f, 0.92156499624252319f, 0.92766499519348145f, 0.93315702676773071f, 0.9381060004234314f, 0.94257098436355591f, 0.94660097360610962f, 0.95023900270462036f, 0.33539599180221558f, 0.41908100247383118f, 0.49247598648071289f, 0.55531197786331177f, 0.60879099369049072f, 0.65415602922439575f, 0.69274699687957764f, 0.72571200132369995f, 0.75402498245239258f, 0.77849102020263672f, 0.79976201057434082f, 0.81836599111557007f, 0.83474302291870117f, 0.84922301769256592f, 0.86208897829055786f, 0.87356698513031006f, 0.88384199142456055f, 0.89306402206420898f, 0.90135800838470459f, 0.9088289737701416f, 0.91556602716445923f, 0.92164498567581177f, 0.92713397741317749f, 0.93208998441696167f, 0.21194499731063843f, 0.29365798830986023f, 0.37110498547554016f, 0.44143900275230408f, 0.5036969780921936f, 0.55801302194595337f, 0.60521197319030762f, 0.64614301919937134f, 0.68169897794723511f, 0.71268302202224731f, 0.73979401588439941f, 0.76362699270248413f, 0.78467601537704468f, 0.80335497856140137f, 0.82000100612640381f, 0.83488202095031738f, 0.8482239842414856f, 0.86021500825881958f, 0.87101101875305176f, 0.88074499368667603f, 0.88952797651290894f, 0.89745801687240601f, 0.90461999177932739f, 0.91109001636505127f, 0.11949499696493149f, 0.18745699524879456f, 0.25997200608253479f, 0.33120998740196228f, 0.39773499965667725f, 0.45832300186157227f, 0.51248997449874878f, 0.56048798561096191f, 0.6028980016708374f, 0.64032697677612305f, 0.67339599132537842f, 0.70268499851226807f, 0.72870397567749023f, 0.75189602375030518f, 0.77263599634170532f, 0.7912449836730957f, 0.80796998739242554f, 0.82303100824356079f, 0.8366129994392395f, 0.84887397289276123f, 0.85994899272918701f, 0.86995697021484375f, 0.87900298833847046f, 0.88717901706695557f, 0.05942929908633232f, 0.10839699953794479f, 0.16785700619220734f, 0.23236599564552307f, 0.29767501354217529f, 0.36022999882698059f, 0.41842898726463318f, 0.47170799970626831f, 0.5198180079460144f, 0.56301301717758179f, 0.60171198844909668f, 0.63635998964309692f, 0.66739702224731445f, 0.69524997472763062f, 0.720287024974823f, 0.74283498525619507f, 0.76317602396011353f, 0.78155702352523804f, 0.79817098379135132f, 0.81319701671600342f, 0.8267899751663208f, 0.83908802270889282f, 0.85021400451660156f, 0.86027902364730835f, 0.02584660053253174f, 0.05619670078158379f, 0.09917669743299484f, 0.15162299573421478f, 0.20941600203514099f, 0.26902499794960022f, 0.32757499814033508f, 0.38318398594856262f, 0.43501600623130798f, 0.48271399736404419f, 0.52620798349380493f, 0.56570100784301758f, 0.60149699449539185f, 0.63392102718353271f, 0.66328197717666626f, 0.68988502025604248f, 0.7139970064163208f, 0.7358660101890564f, 0.75570398569107056f, 0.77369099855422974f, 0.78999698162078857f, 0.80477499961853027f, 0.81816202402114868f, 0.83028298616409302f, 0.00968609005212784f, 0.02591750025749207f, 0.05318830162286758f, 0.09121809899806976f, 0.13777700066566467f, 0.18976299464702606f, 0.244159996509552f, 0.29880800843238831f, 0.35169300436973572f, 0.40180501341819763f, 0.44872200489044189f, 0.49213200807571411f, 0.53206497430801392f, 0.5686650276184082f, 0.60214298963546753f, 0.63272500038146973f, 0.66062301397323608f, 0.68605399131774902f, 0.70922297239303589f, 0.73031198978424072f, 0.74948400259017944f, 0.76689702272415161f, 0.78270000219345093f, 0.79702901840209961f, 0.00303822988644242f, 0.01048239972442389f, 0.02568300068378448f, 0.05025380104780197f, 0.08408640325069427f, 0.12561400234699249f, 0.17249999940395355f, 0.22232000529766083f, 0.27309399843215942f, 0.32321798801422119f, 0.37149098515510559f, 0.4173240065574646f, 0.4603630006313324f, 0.50043797492980957f, 0.53755801916122437f, 0.57181298732757568f, 0.60333001613616943f, 0.63226902484893799f, 0.65877401828765869f, 0.68301999568939209f, 0.70514601469039917f, 0.7253040075302124f, 0.74363899230957031f, 0.76029098033905029f, 0.00076204299693927f, 0.00361976004205644f, 0.0110037000849843f, 0.02512970007956028f, 0.04727460071444511f, 0.07745999842882156f, 0.11460299789905548f, 0.1569570004940033f, 0.20258499681949615f, 0.24971699714660645f, 0.29707801342010498f, 0.34340900182723999f, 0.38799500465393066f, 0.43043500185012817f, 0.47039699554443359f, 0.50777101516723633f, 0.54253697395324707f, 0.57473397254943848f, 0.60444700717926025f, 0.63179397583007812f, 0.65686798095703125f, 0.67979699373245239f, 0.70071202516555786f, 0.71974599361419678f, 0.00014345299859997f, 0.00102306995540857f, 0.00407376000657678f, 0.01122699957340956f, 0.02423799969255924f, 0.04415180161595345f, 0.07109060138463974f, 0.10433399677276611f, 0.14259399473667145f, 0.184347003698349f, 0.2281080037355423f, 0.27265200018882751f, 0.31696400046348572f, 0.36016398668289185f, 0.40178799629211426f, 0.44139501452445984f, 0.47875601053237915f, 0.51375597715377808f, 0.54635101556777954f, 0.57658302783966064f, 0.60447400808334351f, 0.63009101152420044f, 0.65352898836135864f, 0.67488902807235718f, 0.00001858420000644f, 0.0002227969962405f, 0.00124967005103827f, 0.00435766018927097f, 0.01113030035048723f, 0.0229835007339716f, 0.04079980030655861f, 0.06477940082550049f, 0.09447769820690155f, 0.12897300720214844f, 0.16708999872207642f, 0.20760199427604675f, 0.24936899542808533f, 0.29154899716377258f, 0.3332040011882782f, 0.37377101182937622f, 0.41274300217628479f, 0.44977998733520508f, 0.4846780002117157f, 0.51733100414276123f, 0.54769200086593628f, 0.57572799921035767f, 0.6014779806137085f, 0.62501102685928345f, 1.46482000218384201e-06f, 0.00003429050047998f, 0.0002985020109918f, 0.00140504003502429f, 0.00443577999249101f, 0.01069260016083717f, 0.02133879996836185f, 0.0371410995721817f, 0.05836030095815659f, 0.08476380258798599f, 0.11572299897670746f, 0.1503559947013855f, 0.18766500055789948f, 0.22665500640869141f, 0.26647698879241943f, 0.30632400512695312f, 0.34550899267196655f, 0.38344401121139526f, 0.41970700025558472f, 0.45401400327682495f, 0.48618701100349426f, 0.51614201068878174f, 0.54384201765060425f, 0.56930899620056152f, 5.83937982412408019e-08f, 3.2765999549155822e-06f, 0.00005055400106357f, 0.00035111699253321f, 0.00145683996379375f, 0.00427943980321288f, 0.0098936902359128f, 0.01927389949560165f, 0.03310279920697212f, 0.05168719962239265f, 0.07495570182800293f, 0.10250899940729141f, 0.13370099663734436f, 0.1677280068397522f, 0.20372100174427032f, 0.24084299802780151f, 0.27840098738670349f, 0.31564199924468994f, 0.35190799832344055f, 0.38674798607826233f, 0.41985601186752319f, 0.45104199647903442f, 0.48021000623703003f, 0.50734001398086548f, 8.73966010672688753e-10f, 1.57741993689342053e-07f, 5.21975016454234719e-06f, 0.00006079579907237f, 0.00036219600588083f, 0.00138045998755842f, 0.00386844994500279f, 0.00871635042130947f, 0.01675550080835819f, 0.02860799990594387f, 0.04461279883980751f, 0.06480839848518372f, 0.08895269781351089f, 0.11656700074672699f, 0.1470009982585907f, 0.17950700223445892f, 0.21331800520420074f, 0.24785000085830688f, 0.28237700462341309f, 0.31631898880004883f, 0.34923198819160461f, 0.38083100318908691f, 0.41094100475311279f, 0.43946701288223267f, 2.8866399288257627e-12f, 2.63671995348602195e-09f, 2.51094007808205788e-07f, 5.97520011069718748e-06f, 0.00005859580051037f, 0.0003192939911969f, 0.00116373994387686f, 0.00319523992948234f, 0.00714873988181353f, 0.0137449000030756f, 0.0235638003796339f, 0.03696820139884949f, 0.05407309904694557f, 0.0747511014342308f, 0.09866459667682648f, 0.12531900405883789f, 0.15412400662899017f, 0.18446199595928192f, 0.21573600172996521f, 0.24741099774837494f, 0.27903899550437927f, 0.310263991355896f, 0.34082499146461487f, 0.37054198980331421f, 6.94488983838260476e-16f, 7.04290011727115584e-12f, 3.21448001550095341e-09f, 2.20180993437679717e-07f, 4.50593006462440826e-06f, 0.00004154839916737f, 0.00022262999846134f, 0.00081575999502093f, 0.00227530999109149f, 0.00519366981461644f, 0.01020010001957417f, 0.0178545992821455f, 0.02856850065290928f, 0.04256030172109604f, 0.05984469875693321f, 0.08025020360946655f, 0.10345599800348282f, 0.12904399633407593f, 0.15654699504375458f, 0.1854960024356842f, 0.21545499563217163f, 0.24603499472141266f, 0.27690801024436951f, 0.3078019917011261f, 5.46278023199234311e-22f, 3.43167987041791307e-16f, 2.29294990113093622e-12f, 9.57796952860689998e-10f, 6.87986982939037262e-08f, 1.5533599935224629e-06f, 0.00001600819996384f, 0.00009555240103509f, 0.00038631301140413f, 0.00117554003372788f, 0.00289549003355205f, 0.00607588002458215f, 0.01126710046082735f, 0.01896269991993904f, 0.02954130060970783f, 0.04323289915919304f, 0.06011129915714264f, 0.0801049992442131f, 0.10301999747753143f, 0.12857000529766083f, 0.15640300512313843f, 0.18612800538539886f, 0.21734000742435455f, 0.24963200092315674f, 0.0f, 0.0f, 3.09890004335006815e-24f, 2.21276004416278673e-18f, 2.67358004631774657e-14f, 2.24439997836833882e-11f, 3.13075010360819306e-09f, 1.26480998119404831e-07f, 2.12951999856159091e-06f, 0.00001907769910758f, 0.00010753999958979f, 0.00042892698547803f, 0.00131604995112866f, 0.00330013991333544f, 0.00707077002152801f, 0.01337909977883101f, 0.02291939966380596f, 0.03622379899024963f, 0.05359359830617905f, 0.07507230341434479f, 0.10045900195837021f, 0.12935000658035278f, 0.16119599342346191f, 0.19536399841308594f
} };
__device__ float velvetAlbedo(float mu_0, float r_3)
{
    float _S371 = (F32_sqrt((0.10000000149011612f)));
    float _S372 = clamp_1((F32_sqrt(((F32_max((mu_0), (0.0f)))))), 0.0f, 1.0f) * 23.0f;
    float _S373 = (clamp_1((F32_sqrt(((F32_max((r_3), (0.0f)))))), _S371, 1.0f) - _S371) / (1.0f - _S371) * 23.0f;
    uint _S374 = (U32_min((uint(_S372)), (22U)));
    uint _S375 = (U32_min((uint(_S373)), (22U)));
    float _S376 = _S372 - float(_S374);
    float _S377 = _S373 - float(_S375);
    uint _S378 = _S374 * 24U + _S375;
    uint _S379 = _S378 + 24U;
    float _S380 = VELVET_ALBEDO_0[_S378] + (VELVET_ALBEDO_0[_S379] - VELVET_ALBEDO_0[_S378]) * _S376;
    uint _S381 = _S378 + 1U;
    float _S382 = VELVET_ALBEDO_0[_S381] + (VELVET_ALBEDO_0[_S379 + 1U] - VELVET_ALBEDO_0[_S381]) * _S376;
    return _S380 + (_S382 - _S380) * _S377;
}

__device__ static const FixedArray<float, 576>  SHEEN_ALBEDO_0 = { {
    0.62089997529983521f, 0.49450001120567322f, 0.38080000877380371f, 0.28439998626708984f, 0.20010000467300415f, 0.1257999986410141f, 0.05990000069141388f, 0.00109999999403954f, -0.05160000175237656f, -0.09889999777078629f, -0.14159999787807465f, -0.18009999394416809f, -0.2151000052690506f, -0.24690000712871552f, -0.27590000629425049f, -0.30230000615119934f, -0.32649999856948853f, -0.34860000014305115f, -0.36890000104904175f, -0.38760000467300415f, -0.40479999780654907f, -0.42070001363754272f, -0.43439999222755432f, -0.44929999113082886f, 0.59240001440048218f, 0.47049999237060547f, 0.35899999737739563f, 0.26440000534057617f, 0.18150000274181366f, 0.10830000042915344f, 0.04329999908804893f, -0.01470000017434359f, -0.066600002348423f, -0.11339999735355377f, -0.15549999475479126f, -0.19370000064373016f, -0.22820000350475311f, -0.25970000028610229f, -0.28830000758171082f, -0.31450000405311584f, -0.33840000629425049f, -0.36039999127388f, -0.38049998879432678f, -0.39899998903274536f, -0.41609999537467957f, -0.43180000782012939f, -0.44539999961853027f, -0.46070000529289246f, 0.5228000283241272f, 0.40599998831748962f, 0.30259999632835388f, 0.21250000596046448f, 0.13330000638961792f, 0.06319999694824219f, 0.00069999997504056f, -0.05510000139474869f, -0.10520000010728836f, -0.15039999783039093f, -0.19120000302791595f, -0.2281000018119812f, -0.26170000433921814f, -0.2921999990940094f, -0.31999999284744263f, -0.34549999237060547f, -0.36869999766349792f, -0.39010000228881836f, -0.40970000624656677f, -0.42770001292228699f, -0.44440001249313354f, -0.45969998836517334f, -0.47389999032020569f, -0.48800000548362732f, 0.43569999933242798f, 0.32769998908042908f, 0.23160000145435333f, 0.14730000495910645f, 0.07280000299215317f, 0.00659999996423721f, -0.05260000005364418f, -0.10559999942779541f, -0.1534000039100647f, -0.19650000333786011f, -0.23549999296665192f, -0.27090001106262207f, -0.30309998989105225f, -0.33239999413490295f, -0.35920000076293945f, -0.38359999656677246f, -0.40599998831748962f, -0.42660000920295715f, -0.44549998641014099f, -0.46290001273155212f, -0.47900000214576721f, -0.49380001425743103f, -0.50749999284744263f, -0.52090001106262207f, 0.33129999041557312f, 0.23459999263286591f, 0.14740000665187836f, 0.07010000199079514f, 0.00139999995008111f, -0.0601000003516674f, -0.11519999802112579f, -0.16490000486373901f, -0.20970000326633453f, -0.25029999017715454f, -0.28720000386238098f, -0.3206000030040741f, -0.35109999775886536f, -0.37900000810623169f, -0.40439999103546143f, -0.42770001292228699f, -0.44900000095367432f, -0.46869999170303345f, -0.48669999837875366f, -0.5033000111579895f, -0.5187000036239624f, -0.53289997577667236f, -0.54600000381469727f, -0.55860000848770142f, 0.21109999716281891f, 0.12790000438690186f, 0.0511000007390976f, -0.01769999973475933f, -0.07970000058412552f, -0.13549999892711639f, -0.18600000441074371f, -0.23160000145435333f, -0.27300000190734863f, -0.31069999933242798f, -0.34490001201629639f, -0.37619999051094055f, -0.40470001101493835f, -0.43070000410079956f, -0.4546000063419342f, -0.476500004529953f, -0.49660000205039978f, -0.51510000228881836f, -0.53210002183914185f, -0.54780000448226929f, -0.56230002641677856f, -0.57580000162124634f, -0.58819997310638428f, -0.60009998083114624f, 0.0754999965429306f, 0.00800000037997961f, -0.05649999901652336f, -0.11569999903440475f, -0.16979999840259552f, -0.21920000016689301f, -0.26420000195503235f, -0.3052000105381012f, -0.34270000457763672f, -0.37689998745918274f, -0.40819999575614929f, -0.43680000305175781f, -0.46299999952316284f, -0.48710000514984131f, -0.50910001993179321f, -0.52939999103546143f, -0.54809999465942383f, -0.56529998779296875f, -0.5810999870300293f, -0.59570002555847168f, -0.60930001735687256f, -0.6218000054359436f, -0.63340002298355103f, -0.6445000171661377f, -0.07569999992847443f, -0.12489999830722809f, -0.17569999396800995f, -0.22380000352859497f, -0.26890000700950623f, -0.3107999861240387f, -0.34959998726844788f, -0.38539999723434448f, -0.41839998960494995f, -0.44870001077651978f, -0.47659999132156372f, -0.50230002403259277f, -0.52590000629425049f, -0.54759997129440308f, -0.56760001182556152f, -0.58600002527236938f, -0.6029999852180481f, -0.61870002746582031f, -0.63330000638961792f, -0.64670002460479736f, -0.6590999960899353f, -0.67059999704360962f, -0.68129998445510864f, -0.69160002470016479f, -0.24320000410079956f, -0.27120000123977661f, -0.30640000104904175f, -0.34209999442100525f, -0.37700000405311584f, -0.41060000658035278f, -0.44229999184608459f, -0.47220000624656677f, -0.50010001659393311f, -0.52600002288818359f, -0.55010002851486206f, -0.57239997386932373f, -0.59310001134872437f, -0.61220002174377441f, -0.62989997863769531f, -0.64620000123977661f, -0.66140002012252808f, -0.6754000186920166f, -0.68839997053146362f, -0.70039999485015869f, -0.71160000562667847f, -0.72200000286102295f, -0.73159998655319214f, -0.74089998006820679f, -0.42809998989105225f, -0.43149998784065247f, -0.44920000433921814f, -0.47099998593330383f, -0.49459999799728394f, -0.51880002021789551f, -0.54269999265670776f, -0.5658000111579895f, -0.58799999952316284f, -0.60900002717971802f, -0.62870001792907715f, -0.64730000495910645f, -0.6646999716758728f, -0.68080002069473267f, -0.69590002298355103f, -0.70999997854232788f, -0.72299998998641968f, -0.73509997129440308f, -0.74639999866485596f, -0.75690001249313354f, -0.76670002937316895f, -0.77579998970031738f, -0.78430002927780151f, -0.79250001907348633f, -0.63230001926422119f, -0.60759997367858887f, -0.60519999265670776f, -0.61119997501373291f, -0.62209999561309814f, -0.63580000400543213f, -0.65090000629425049f, -0.66659998893737793f, -0.68239998817443848f, -0.69789999723434448f, -0.71289998292922974f, -0.7271999716758728f, -0.74089998006820679f, -0.75379997491836548f, -0.76590001583099365f, -0.77740001678466797f, -0.78810000419616699f, -0.79809999465942383f, -0.80750000476837158f, -0.81629997491836548f, -0.82450002431869507f, -0.83209997415542603f, -0.83929997682571411f, -0.84630000591278076f, -0.85790002346038818f, -0.80119997262954712f, -0.77600002288818359f, -0.76410001516342163f, -0.76059997081756592f, -0.76239997148513794f, -0.76770001649856567f, -0.7750999927520752f, -0.78380000591278076f, -0.79309999942779541f, -0.80279999971389771f, -0.8125f, -0.82200002670288086f, -0.8312000036239624f, -0.8400999903678894f, -0.84859997034072876f, -0.85670000314712524f, -0.86440002918243408f, -0.8716999888420105f, -0.87849998474121094f, -0.88499999046325684f, -0.89099997282028198f, -0.89670002460479736f, -0.90240001678466797f, -1.10769999027252197f, -1.01429998874664307f, -0.96329998970031738f, -0.93110001087188721f, -0.91140002012252808f, -0.89990001916885376f, -0.89410001039505005f, -0.89219999313354492f, -0.89289999008178711f, -0.89539998769760132f, -0.89910000562667847f, -0.9035000205039978f, -0.90850001573562622f, -0.91360002756118774f, -0.9189000129699707f, -0.92419999837875366f, -0.92940002679824829f, -0.93440002202987671f, -0.93930000066757202f, -0.9440000057220459f, -0.94849997758865356f, -0.95270001888275146f, -0.95679998397827148f, -0.96100002527236938f, -1.38499999046325684f, -1.24950003623962402f, -1.16919994354248047f, -1.11409997940063477f, -1.07599997520446777f, -1.0494999885559082f, -1.03129994869232178f, -1.01880002021789551f, -1.01059997081756592f, -1.00539994239807129f, -1.00240004062652588f, -1.00109994411468506f, -1.0009000301361084f, -1.00150001049041748f, -1.00279998779296875f, -1.00440001487731934f, -1.00639998912811279f, -1.00849997997283936f, -1.01069998741149902f, -1.0130000114440918f, -1.01530003547668457f, -1.01750004291534424f, -1.01979994773864746f, -1.02230000495910645f, -1.69420003890991211f, -1.51020002365112305f, -1.39649999141693115f, -1.31540000438690186f, -1.2565000057220459f, -1.21309995651245117f, -1.18079996109008789f, -1.15649998188018799f, -1.13820004463195801f, -1.12440001964569092f, -1.11389994621276855f, -1.10599994659423828f, -1.10010004043579102f, -1.09560000896453857f, -1.09230005741119385f, -1.09000003337860107f, -1.08829998970031738f, -1.08710002899169922f, -1.08640003204345703f, -1.08599996566772461f, -1.08580005168914795f, -1.08580005168914795f, -1.08599996566772461f, -1.0866999626159668f, -2.04089999198913574f, -1.80079996585845947f, -1.64869999885559082f, -1.53789997100830078f, -1.45539999008178711f, -1.392799973487854f, -1.34459996223449707f, -1.30700004100799561f, -1.27730000019073486f, -1.25380003452301025f, -1.23489999771118164f, -1.21959996223449707f, -1.20720005035400391f, -1.19700002670288086f, -1.18859994411468506f, -1.18169999122619629f, -1.17589998245239258f, -1.17100000381469727f, -1.16690003871917725f, -1.16349995136260986f, -1.16059994697570801f, -1.15810000896453857f, -1.15600001811981201f, -1.15470004081726074f, -2.43269991874694824f, -2.12700009346008301f, -1.93060004711151123f, -1.78569996356964111f, -1.67610001564025879f, -1.59159994125366211f, -1.52530002593994141f, -1.47249996662139893f, -1.4299999475479126f, -1.39540004730224609f, -1.36689996719360352f, -1.3432999849319458f, -1.32350003719329834f, -1.30680000782012939f, -1.29270005226135254f, -1.28059995174407959f, -1.27009999752044678f, -1.26110005378723145f, -1.25329995155334473f, -1.24639999866485596f, -1.24039995670318604f, -1.23500001430511475f, -1.23029994964599609f, -1.22669994831085205f, -2.87989997863769531f, -2.49659991264343262f, -2.24860000610351562f, -2.06410002708435059f, -1.92330002784729004f, -1.8135000467300415f, -1.72640001773834229f, -1.65620005130767822f, -1.59899997711181641f, -1.55169999599456787f, -1.51230001449584961f, -1.47909998893737793f, -1.45099997520446777f, -1.42690002918243408f, -1.40610003471374512f, -1.3881000280380249f, -1.37240004539489746f, -1.35860002040863037f, -1.34640002250671387f, -1.33570003509521484f, -1.32609999179840088f, -1.31749999523162842f, -1.30980002880096436f, -1.30359995365142822f, -3.39750003814697266f, -2.92090010643005371f, -2.6119999885559082f, -2.38100004196166992f, -2.20359992980957031f, -2.0643000602722168f, -1.95290005207061768f, -1.86249995231628418f, -1.7882000207901001f, -1.72619998455047607f, -1.67410004138946533f, -1.62989997863769531f, -1.59200000762939453f, -1.55929994583129883f, -1.53090000152587891f, -1.50610005855560303f, -1.48430001735687256f, -1.46500003337860107f, -1.44790005683898926f, -1.43260002136230469f, -1.4189000129699707f, -1.40649998188018799f, -1.39540004730224609f, -1.38629996776580811f, -4.00810003280639648f, -3.41639995574951172f, -3.03419995307922363f, -2.74749994277954102f, -2.52649998664855957f, -2.35209989547729492f, -2.21210002899169922f, -2.09780001640319824f, -2.00309991836547852f, -1.92390000820159912f, -1.85679996013641357f, -1.7994999885559082f, -1.75020003318786621f, -1.70739996433258057f, -1.66999995708465576f, -1.6371999979019165f, -1.60819995403289795f, -1.58239996433258057f, -1.55949997901916504f, -1.53890001773834229f, -1.52040004730224609f, -1.50370001792907715f, -1.48860001564025879f, -1.47609996795654297f, -4.7491002082824707f, -4.00920009613037109f, -3.53640007972717285f, -3.18140006065368652f, -2.90700006484985352f, -2.69000005722045898f, -2.5150001049041748f, -2.37150001525878906f, -2.25230002403259277f, -2.15199995040893555f, -2.06680011749267578f, -1.99370002746582031f, -1.93060004711151123f, -1.87559998035430908f, -1.82739996910095215f, -1.78489995002746582f, -1.74730002880096436f, -1.71379995346069336f, -1.68389999866485596f, -1.65699994564056396f, -1.63279998302459717f, -1.6109999418258667f, -1.59109997749328613f, -1.5746999979019165f, -5.68760013580322266f, -4.74030017852783203f, -4.15259981155395508f, -3.71110010147094727f, -3.36949992179870605f, -3.09859991073608398f, -2.87960004806518555f, -2.69939994812011719f, -2.54920005798339844f, -2.42239999771118164f, -2.31439995765686035f, -2.22140002250671387f, -2.1408998966217041f, -2.07069993019104004f, -2.00900006294250488f, -1.95459997653961182f, -1.90629994869232178f, -1.86329996585845947f, -1.82480001449584961f, -1.79030001163482666f, -1.75919997692108154f, -1.73099994659423828f, -1.70550000667572021f, -1.68429994583129883f, -6.68940019607543945f, -5.34350013732910156f, -4.86259984970092773f, -4.34409999847412109f, -3.93390011787414551f, -3.60269999504089355f, -3.33100008964538574f, -3.10509991645812988f, -2.91510009765625f, -2.75390005111694336f, -2.61590003967285156f, -2.49690008163452148f, -2.3935999870300293f, -2.30340003967285156f, -2.22420001029968262f, -2.15440011024475098f, -2.09240007400512695f, -2.03730010986328125f, -1.98800003528594971f, -1.94369995594024658f, -1.90390002727508545f, -1.86790001392364502f, -1.83480000495910645f, -1.8078000545501709f, -9.69550037384033203f, -7.62489986419677734f, -6.61070013046264648f, -5.72329998016357422f, -5.04829978942871094f, -4.52129983901977539f, -4.10120010375976562f, -3.76049995422363281f, -3.48009991645812988f, -3.24640011787414551f, -3.04959988594055176f, -2.88229990005493164f, -2.738800048828125f, -2.61479997634887695f, -2.50699996948242188f, -2.41269993782043457f, -2.32960009574890137f, -2.25620007514953613f, -2.19090008735656738f, -2.13269996643066406f, -2.08049988746643066f, -2.03349995613098145f, -1.99049997329711914f, -1.95369994640350342f
} };
__device__ float sheenAlbedo(float mu_1, float r_4)
{
    float _S383 = (F32_sqrt((0.05000000074505806f)));
    float _S384 = clamp_1((F32_sqrt(((F32_max((mu_1), (0.0f)))))), 0.0f, 1.0f) * 23.0f;
    float _S385 = (clamp_1((F32_sqrt(((F32_max((r_4), (0.0f)))))), _S383, 1.0f) - _S383) / (1.0f - _S383) * 23.0f;
    uint _S386 = (U32_min((uint(_S384)), (22U)));
    uint _S387 = (U32_min((uint(_S385)), (22U)));
    float _S388 = _S384 - float(_S386);
    float _S389 = _S385 - float(_S387);
    uint _S390 = _S386 * 24U + _S387;
    uint _S391 = _S390 + 24U;
    float _S392 = SHEEN_ALBEDO_0[_S390] + (SHEEN_ALBEDO_0[_S391] - SHEEN_ALBEDO_0[_S390]) * _S388;
    uint _S393 = _S390 + 1U;
    float _S394 = SHEEN_ALBEDO_0[_S393] + (SHEEN_ALBEDO_0[_S391 + 1U] - SHEEN_ALBEDO_0[_S393]) * _S388;
    return (F32_exp((_S392 + (_S394 - _S392) * _S389)));
}

static __device__ float3  mix_0(float3  e1_0, float3  e2_0, float e3_0)
{
    return e1_0 * make_float3 (1.0f - e3_0) + e2_0 * make_float3 (e3_0);
}

__device__ float anisotropicG1(float3  w_1, float2  alphas_1)
{
    float _S395 = (F32_max((w_1.z), (0.0f)));
    return 2.0f * _S395 / (_S395 + length_0(make_float3 (alphas_1.x * w_1.x, alphas_1.y * w_1.y, _S395)));
}

__device__ float anisotropicD(float3  h_0, float2  alphas_2)
{
    float _S396 = alphas_2.x;
    float _S397 = h_0.x / _S396;
    float _S398 = alphas_2.y;
    float _S399 = h_0.y / _S398;
    float _S400 = h_0.z;
    float _S401 = _S397 * _S397 + _S399 * _S399 + _S400 * _S400;
    return 1.0f / (F32_max((3.14159274101257324f * _S396 * _S398 * _S401 * _S401), (1.17549435082228751e-38f)));
}

static __device__ BSDFLobes BSDFLobes_x24init_0(float v_dot_h_0, float n_dot_h_0, float3  refracted_1, float3  F_0, float F_greyscale_0, float reflect_weight_0, float3  diffuse_weight_0, float3  refract_weight_0, float p_diffuse_0, float p_reflect_0, float p_refract_0, float translucent_share_0, float3  sheen_0, float3  view_0, float3  tangent_1, float2  alphas_3, float visible_0, float toon_share_0)
{
    BSDFLobes _S402;
    (&_S402)->v_dot_h = v_dot_h_0;
    (&_S402)->n_dot_h = n_dot_h_0;
    (&_S402)->refracted = refracted_1;
    (&_S402)->F = F_0;
    (&_S402)->F_greyscale = F_greyscale_0;
    (&_S402)->reflect_weight = reflect_weight_0;
    (&_S402)->diffuse_weight = diffuse_weight_0;
    (&_S402)->refract_weight = refract_weight_0;
    (&_S402)->p_diffuse = p_diffuse_0;
    (&_S402)->p_reflect = p_reflect_0;
    (&_S402)->p_refract = p_refract_0;
    (&_S402)->translucent_share = translucent_share_0;
    (&_S402)->sheen = sheen_0;
    (&_S402)->view = view_0;
    (&_S402)->tangent = tangent_1;
    (&_S402)->alphas = alphas_3;
    (&_S402)->visible = visible_0;
    (&_S402)->toon_share = toon_share_0;
    return _S402;
}

__device__ __forceinline__ BSDFLobes bsdfLobes(float3  in_dir_0, float3  v_3, float3  n_i_2, float3  ggx_n_0, BSDFMaterial material_1, float eta_i_1, float eta_o_1, AnisotropicFrame frame_1)
{
    float _S403 = dot_0(ggx_n_0, v_3);
    float _S404 = dot_0(n_i_2, ggx_n_0);
    float _S405 = eta_i_1 / eta_o_1;
    float3  _S406 = refract_0(in_dir_0, ggx_n_0, _S405);
    float3  _S407 = ((((_S406)) * make_float3(rnorm3df(((_S406)).x, ((_S406)).y, ((_S406)).z))));
    float _S408 = (F32_min(((F32_sqrt((material_1.specular_level))) * (F32_abs((eta_i_1 - eta_o_1))) / (eta_i_1 + eta_o_1)), (0.9999847412109375f)));
    float _S409 = _S408 * _S408;
    float _S410 = (1.0f + _S408) / (1.0f - _S408);
    float _S411 = (F32_abs((_S403)));
    bool _S412 = eta_i_1 > eta_o_1;
    float sheen_component_0;
    if(_S412)
    {
        sheen_component_0 = _S410;
    }
    else
    {
        sheen_component_0 = 1.0f;
    }
    float toon_component_0;
    if(_S412)
    {
        toon_component_0 = 1.0f;
    }
    else
    {
        toon_component_0 = _S410;
    }
    float _S413 = fresnel(_S411, sheen_component_0, toon_component_0);
    bool _S414 = (eta_i_1 * eta_i_1 * (1.0f - _S403 * _S403)) >= (eta_o_1 * eta_o_1);
    float3  _S415;
    if(_S414)
    {
        _S415 = make_float3 (1.0f);
    }
    else
    {
        float3  _S416 = material_1.specular_tint * make_float3 (_S409);
        _S415 = _S416 + (make_float3 (1.0f) - _S416) * make_float3 (_S413 - _S409) / make_float3 (1.0f - _S409);
    }
    float3  _S417 = make_float3 (1.0f);
    float3  _S418 = make_float3 (0.0f);
    float _S419 = rgb_to_greyscale(material_1.sheen);
    bool _S420 = _S419 > 0.0f;
    float3  sheen_1;
    float3  view_1;
    float3  scale_1;
    if(_S420)
    {
        if((material_1.velvet) > 0.0f)
        {
            float _S421 = velvetAlbedo(dot_0(n_i_2, v_3), material_1.sheen_roughness);
            sheen_component_0 = _S421;
        }
        else
        {
            float _S422 = sheenAlbedo(dot_0(n_i_2, v_3), material_1.sheen_roughness);
            sheen_component_0 = _S422;
        }
        float _S423 = (F32_min((sheen_component_0), (1.0f)));
        float3  _S424 = make_float3 (1.0f) - material_1.sheen * make_float3 (_S423);
        float _S425 = rgb_to_greyscale(material_1.sheen);
        float _S426 = _S425 * _S423;
        float3  _S427 = material_1.sheen / make_float3 ((F32_max((sheen_component_0), (1.0f))));
        sheen_component_0 = _S426;
        sheen_1 = _S427;
        view_1 = v_3;
        scale_1 = _S424;
    }
    else
    {
        sheen_component_0 = 0.0f;
        sheen_1 = _S418;
        view_1 = _S418;
        scale_1 = _S417;
    }
    float _S428 = (F32_abs((material_1.toon.x)));
    bool _S429 = _S428 > 0.0f;
    if(_S429)
    {
        float _S430 = (F32_min((_S428), (1.0f)));
        float3  scale_2 = scale_1 * make_float3 (1.0f - _S430);
        float _S431 = rgb_to_greyscale(material_1.albedo);
        float _S432 = _S430 * _S431;
        toon_component_0 = _S432;
        scale_1 = scale_2;
    }
    else
    {
        toon_component_0 = 0.0f;
    }
    float3  _S433 = mix_0(_S415, material_1.albedo, material_1.metallic);
    float3  F_1 = _S433 * scale_1;
    float _S434 = rgb_to_greyscale(F_1);
    float _S435 = 1.0f - material_1.metallic;
    float3  _S436 = make_float3 (1.0f) - _S415;
    float3  _S437 = make_float3 ((1.0f - material_1.transmission) * _S435) * _S436 * scale_1;
    float3  _S438 = make_float3 (material_1.transmission * _S435) * _S436 * scale_1;
    float _S439 = (F32_max((_S434), (0.0f)));
    float _S440 = rgb_to_greyscale(_S437);
    float _S441 = (F32_max((_S440), (0.0f)));
    float _S442 = rgb_to_greyscale(_S438);
    float _S443 = sign_0(length_0(_S407));
    float _S444 = (F32_max((_S442 * _S443), (0.0f)));
    float _S445 = _S439 + _S441 + _S444 + sheen_component_0 + toon_component_0;
    float _S446 = 1.0f / (F32_max((_S445), (0.0000152587890625f)));
    float _S447 = _S441 + sheen_component_0 + toon_component_0;
    float _S448 = _S447 * _S446;
    float _S449 = _S439 * _S446;
    float _S450 = _S444 * _S446;
    bool _S451 = (frame_1.alphas.x) > 0.0f;
    float visible_1;
    if(_S451)
    {
        float3  _S452 = anisotropicLocal(v_3, frame_1.tangent, n_i_2);
        float _S453 = anisotropicG1(_S452, frame_1.alphas);
        float3  _S454 = anisotropicLocal(ggx_n_0, frame_1.tangent, n_i_2);
        float _S455 = anisotropicD(_S454, frame_1.alphas);
        float _S456 = _S453 * _S455;
        visible_1 = _S456;
    }
    else
    {
        visible_1 = 0.0f;
    }
    return BSDFLobes_x24init_0(_S403, _S404, _S407, F_1, _S434, 1.0f, _S437, _S438, _S448, _S449, _S450, 0.0f, sheen_1, view_1, frame_1.tangent, frame_1.alphas, visible_1, toon_component_0 / (F32_max((_S447), (0.0000152587890625f))));
}

__device__ float translucentShare(BSDFMaterial material_2)
{
    float _S457 = rgb_to_greyscale(material_2.translucent);
    float _S458 = rgb_to_greyscale(material_2.albedo);
    float _S459 = _S457 / (_S458 + _S457);
    bool _S460 = _S457 > 0.0f;
    float _S461 = _slang_select(_S460, _S459,0.0f);
    return _S461;
}

__device__ float smithG1(float alpha_2, float n_dot_x_0)
{
    float _S462 = alpha_2 * alpha_2;
    float _S463 = 2.0f * n_dot_x_0 / (n_dot_x_0 + (F32_sqrt((_S462 + (1.0f - _S462) * n_dot_x_0 * n_dot_x_0))));
    bool _S464 = alpha_2 > 0.0f;
    float _S465 = _slang_select(_S464, _S463,1.0f);
    return _S465;
}

__device__ float trowbridgeReitz(float alpha_3, float n_dot_h_1)
{
    float _S466 = alpha_3 * alpha_3;
    float _S467 = (1.0f - n_dot_h_1) * (1.0f + n_dot_h_1) + _S466 * n_dot_h_1 * n_dot_h_1;
    return _S466 / (F32_max((3.14159274101257324f * _S467 * _S467), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ float lobeDensity(float n_i_dot_l_0, float l_dot_h_0, float n_i_dot_v_0, float alpha_4, BSDFLobes lobes_0, float eta_i_2, float eta_o_2, uint lobe_0)
{
    bool _S468 = lobe_0 == 0U;
    if(_S468)
    {
        float _S469 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
        float _S470 = lobes_0.p_diffuse * (F32_abs((n_i_dot_l_0))) * 0.31830987334251404f;
        float _S471 = 1.0f - lobes_0.translucent_share;
        bool _S472 = n_i_dot_l_0 < 0.0f;
        float _S473 = _slang_select(_S472, lobes_0.translucent_share,_S471);
        float _S474 = _S470 * _S473;
        bool _S475 = (lobes_0.translucent_share) > 0.0f;
        float _S476 = _slang_select(_S475, _S474,_S469);
        bool _S477 = n_i_dot_v_0 > 0.0f;
        float _S478 = _slang_select(_S477, _S476,0.0f);
        return _S478;
    }
    float _S479 = smithG1(alpha_4, n_i_dot_v_0);
    float _S480 = _S479 * lobes_0.v_dot_h;
    float _S481 = trowbridgeReitz(alpha_4, lobes_0.n_dot_h);
    float _S482 = _S480 * _S481 / n_i_dot_v_0;
    bool _S483 = alpha_4 > 0.0f;
    bool _S484;
    if(_S483)
    {
        _S484 = (lobes_0.v_dot_h) > 0.0f;
    }
    else
    {
        _S484 = false;
    }
    if(_S484)
    {
        _S484 = (lobes_0.n_dot_h) > 0.0f;
    }
    else
    {
        _S484 = false;
    }
    if(_S484)
    {
        _S484 = n_i_dot_v_0 > 0.0f;
    }
    else
    {
        _S484 = false;
    }
    float _S485 = _slang_select(_S484, _S482,0.0f);
    bool _S486 = (lobes_0.alphas.x) > 0.0f;
    float pdf_h_0;
    if(_S486)
    {
        float _S487 = lobes_0.visible * lobes_0.v_dot_h / n_i_dot_v_0;
        bool _S488 = (lobes_0.v_dot_h) > 0.0f;
        if(_S488)
        {
            _S484 = (lobes_0.n_dot_h) > 0.0f;
        }
        else
        {
            _S484 = false;
        }
        if(_S484)
        {
            _S484 = n_i_dot_v_0 > 0.0f;
        }
        else
        {
            _S484 = false;
        }
        float _S489 = _slang_select(_S484, _S487,0.0f);
        pdf_h_0 = _S489;
    }
    else
    {
        pdf_h_0 = _S485;
    }
    bool _S490 = lobe_0 == 1U;
    if(_S490)
    {
        float _S491 = eta_i_2 * lobes_0.v_dot_h + eta_o_2 * l_dot_h_0;
        float _S492 = lobes_0.p_refract * pdf_h_0 * eta_o_2 * eta_o_2 * (F32_abs((l_dot_h_0))) / (_S491 * _S491);
        bool _S493 = eta_i_2 != eta_o_2;
        if(_S493)
        {
            _S484 = l_dot_h_0 < 0.0f;
        }
        else
        {
            _S484 = false;
        }
        float _S494 = _slang_select(_S484, _S492,0.0f);
        return _S494;
    }
    float _S495 = lobes_0.p_reflect * pdf_h_0 / (4.0f * lobes_0.v_dot_h);
    bool _S496 = pdf_h_0 > 0.0f;
    float _S497 = _slang_select(_S496, _S495,0.0f);
    return _S497;
}

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_0, uint random_state_3, bool refracted_2, uint lobe_1, float pdf_0)
{
    SampleBSDF _S498;
    (&_S498)->unit_direction = unit_direction_1;
    (&_S498)->throughput = throughput_0;
    (&_S498)->random_state = random_state_3;
    (&_S498)->refracted = refracted_2;
    (&_S498)->lobe = lobe_1;
    (&_S498)->pdf = pdf_0;
    return _S498;
}

__device__ float velvetBRDF(float3  l_0, float3  v_4, float3  n_5, float r_5)
{
    float _S499 = (F32_max((r_5), (0.00999999977648258f)));
    float _S500 = _S499 * _S499;
    float3  _S501 = l_0 + v_4;
    float3  _S502 = ((((_S501)) * make_float3(rnorm3df(((_S501)).x, ((_S501)).y, ((_S501)).z))));
    float _S503 = dot_0(n_5, _S502);
    float _S504 = (F32_max((dot_0(n_5, l_0)), (0.0f)));
    float _S505 = (F32_max((dot_0(n_5, v_4)), (0.0f)));
    float _S506 = (F32_max((1.0f - _S503 * _S503), (0.0000152587890625f)));
    float _S507 = (F32_exp((- _S503 * _S503 / (_S506 * _S500)))) / (3.14159274101257324f * _S500 * _S506 * _S506);
    float _S508 = (F32_min((1.0f), (2.0f * _S503 * (F32_min((_S504), (_S505))) / (F32_max(((F32_abs((dot_0(_S502, v_4))))), (0.0000152587890625f))))));
    return _S507 * _S508 / (F32_max((4.0f * _S504 * _S505), (0.0000152587890625f)));
}

__device__ float sheenBRDF(float3  l_1, float3  v_5, float3  n_6, float r_6)
{
    float _S509 = 1.0f / (F32_max((r_6), (0.05000000074505806f)));
    float3  _S510 = l_1 + v_5;
    float3  _S511 = ((((_S510)) * make_float3(rnorm3df(((_S510)).x, ((_S510)).y, ((_S510)).z))));
    float _S512 = dot_0(n_6, _S511);
    float _S513 = (F32_max((dot_0(n_6, l_1)), (0.0f)));
    float _S514 = (F32_max((dot_0(n_6, v_5)), (0.0f)));
    return (2.0f + _S509) * (F32_pow(((F32_max((1.0f - _S512 * _S512), (0.0f)))), (0.5f * _S509))) * 0.5f * 0.31830987334251404f / (F32_max((4.0f * (_S513 + _S514 - _S513 * _S514)), (0.0000152587890625f)));
}

__device__ __forceinline__ float3  lobeThroughput(float3  l_2, float3  n_i_3, float alpha_5, BSDFMaterial material_3, BSDFLobes lobes_1, uint lobe_2)
{
    bool _S515 = lobe_2 == 0U;
    float G1_l_0;
    if(_S515)
    {
        bool _S516 = (dot_0(n_i_3, l_2)) < 0.0f;
        float3  _S517 = _slang_select(_S516, material_3.translucent,material_3.albedo);
        float _S518 = 1.0f - lobes_1.translucent_share;
        float _S519 = _slang_select(_S516, lobes_1.translucent_share,_S518);
        float3  _S520 = _S517 / make_float3 (_S519);
        bool _S521 = (lobes_1.translucent_share) > 0.0f;
        float3  _S522 = _slang_select(_S521, _S520,material_3.albedo);
        float _S523 = rgb_to_greyscale(material_3.sheen);
        bool _S524 = _S523 > 0.0f;
        bool _S525;
        if(_S524)
        {
            _S525 = !_S516;
        }
        else
        {
            _S525 = false;
        }
        if(_S525)
        {
            if((material_3.velvet) > 0.0f)
            {
                float _S526 = velvetBRDF(l_2, lobes_1.view, n_i_3, material_3.sheen_roughness);
                G1_l_0 = _S526;
            }
            else
            {
                float _S527 = sheenBRDF(l_2, lobes_1.view, n_i_3, material_3.sheen_roughness);
                G1_l_0 = _S527;
            }
            float3  _S528 = lobes_1.diffuse_weight * _S522;
            float3  _S529 = lobes_1.sheen * make_float3 (3.14159274101257324f) * make_float3 (G1_l_0);
            float _S530 = _slang_select(_S521, _S518,1.0f);
            return (_S528 + _S529 / make_float3 (_S530)) / make_float3 (lobes_1.p_diffuse);
        }
        return lobes_1.diffuse_weight * _S522 / make_float3 (lobes_1.p_diffuse);
    }
    bool _S531 = lobe_2 == 1U;
    if(_S531)
    {
        float _S532 = - dot_0(n_i_3, l_2);
        float _S533 = smithG1(alpha_5, (F32_max((_S532), (0.0f))));
        bool _S534 = (lobes_1.alphas.x) > 0.0f;
        if(_S534)
        {
            float3  _S535 = negate_0(n_i_3);
            float3  _S536 = anisotropicLocal(l_2, lobes_1.tangent, _S535);
            float _S537 = anisotropicG1(_S536, lobes_1.alphas);
            G1_l_0 = _S537;
        }
        else
        {
            G1_l_0 = _S533;
        }
        return lobes_1.refract_weight * make_float3 (G1_l_0) * material_3.albedo / make_float3 (lobes_1.p_refract);
    }
    float _S538 = dot_0(n_i_3, l_2);
    float _S539 = smithG1(alpha_5, (F32_max((_S538), (0.0f))));
    bool _S540 = (lobes_1.alphas.x) > 0.0f;
    if(_S540)
    {
        float3  _S541 = anisotropicLocal(l_2, lobes_1.tangent, n_i_3);
        float _S542 = anisotropicG1(_S541, lobes_1.alphas);
        G1_l_0 = _S542;
    }
    else
    {
        G1_l_0 = _S539;
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
    ToonLobe_0 _S543;
    (&_S543)->a_5 = a_6;
    (&_S543)->s_0 = s_1;
    (&_S543)->b_1 = b_2;
    (&_S543)->glossy_0 = glossy_1;
    return _S543;
}

static __device__ ToonLobe_0 toonLobe_0(float3  toon_0)
{
    float _S544 = toon_0.x;
    bool _S545 = (F32_abs((_S544))) > 0.0f;
    float _S546 = _slang_select(_S545, _S544,1.0f);
    float _S547 = clamp_1(toon_0.y / _S546, 0.00000999999974738f, 1.0f) * 3.14159274101257324f / 2.0f;
    float _S548 = clamp_1(toon_0.z / _S546, 0.0f, 1.0f) * 3.14159274101257324f / 2.0f;
    return ToonLobe_x24init_0(_S547, _S548, (F32_min((_S547 + _S548), (1.57079637050628662f))), _S544 < 0.0f);
}

static __device__ float toonProfile_0(float t_13, ToonLobe_0 * lobe_3)
{
    float _S549 = lobe_3->a_5;
    float _S550;
    if(t_13 < (lobe_3->a_5))
    {
        _S550 = 1.0f;
    }
    else
    {
        _S550 = (F32_max((1.0f - (t_13 - _S549) / (F32_max((lobe_3->s_0), (0.0000152587890625f)))), (0.0f)));
    }
    return _S550;
}

static __device__ float toonIntegral_0(float t_14, ToonLobe_0 * lobe_4)
{
    float _S551 = lobe_4->a_5;
    bool _S552 = lobe_4->glossy_0;
    float _S553;
    if(lobe_4->glossy_0)
    {
        _S553 = 1.0f - (F32_cos(((F32_min((t_14), (_S551))))));
    }
    else
    {
        float _S554 = (F32_sin(((F32_min((t_14), (_S551))))));
        _S553 = _S554 * _S554 / 2.0f;
    }
    bool _S555 = t_14 > _S551;
    bool _S556;
    if(_S555)
    {
        _S556 = (lobe_4->s_0) > 0.0f;
    }
    else
    {
        _S556 = false;
    }
    bool _S557 = !_S556;
    if(_S557)
    {
        return _S553;
    }
    if(_S552)
    {
        float _S558 = (F32_cos((_S551)));
        float _S559 = (F32_cos((t_14)));
        return _S553 + (1.0f + _S551 / lobe_4->s_0) * (_S558 - _S559) - ((F32_sin((t_14))) - t_14 * _S559 - ((F32_sin((_S551))) - _S551 * _S558)) / lobe_4->s_0;
    }
    float _S560 = 2.0f * _S551;
    float _S561 = (F32_cos((_S560)));
    float _S562 = 2.0f * t_14;
    float _S563 = (F32_cos((_S562)));
    return _S553 + (1.0f + _S551 / lobe_4->s_0) * (_S561 - _S563) / 4.0f - ((F32_sin((_S562))) / 8.0f - t_14 * _S563 / 4.0f - ((F32_sin((_S560))) / 8.0f - _S551 * _S561 / 4.0f)) / lobe_4->s_0;
}

__device__ float toonDensity(float3  v_6, float3  l_3, float3  n_7, float3  toon_1)
{
    ToonLobe_0 _S564 = toonLobe_0(toon_1);
    float _S565 = dot_0(n_7, l_3);
    if(_S564.glossy_0)
    {
        float _S566 = (F32_acos((clamp_1(dot_0(make_float3 (2.0f * dot_0(n_7, v_6)) * n_7 - v_6, l_3), -1.0f, 1.0f))));
        ToonLobe_0 _S567 = _S564;
        float _S568 = toonProfile_0(_S566, &_S567);
        ToonLobe_0 _S569 = _S564;
        float _S570 = toonIntegral_0(_S564.b_1, &_S569);
        return _S568 / (6.28318548202514648f * _S570);
    }
    float _S571 = (F32_acos(((F32_min((_S565), (1.0f))))));
    ToonLobe_0 _S572 = _S564;
    float _S573 = toonProfile_0(_S571, &_S572);
    float _S574 = _S573 * _S565;
    ToonLobe_0 _S575 = _S564;
    float _S576 = toonIntegral_0(_S564.b_1, &_S575);
    float _S577 = _S574 / (6.28318548202514648f * _S576);
    bool _S578 = _S565 > 0.0f;
    float _S579 = _slang_select(_S578, _S577,0.0f);
    return _S579;
}

__device__ float toonBSDF(float3  v_7, float3  l_4, float3  n_8, float3  toon_2)
{
    ToonLobe_0 _S580 = toonLobe_0(toon_2);
    float _S581 = dot_0(n_8, v_7);
    float _S582 = dot_0(n_8, l_4);
    bool _S583 = _S581 > 0.0f;
    bool _S584;
    if(_S583)
    {
        _S584 = _S582 > 0.0f;
    }
    else
    {
        _S584 = false;
    }
    bool _S585 = !_S584;
    if(_S585)
    {
        return 0.0f;
    }
    if(_S580.glossy_0)
    {
        float _S586 = (F32_acos((clamp_1(dot_0(make_float3 (2.0f * _S581) * n_8 - v_7, l_4), -1.0f, 1.0f))));
        ToonLobe_0 _S587 = _S580;
        float _S588 = toonProfile_0(_S586, &_S587);
        ToonLobe_0 _S589 = _S580;
        float _S590 = toonIntegral_0(_S580.b_1, &_S589);
        return _S588 / (6.28318548202514648f * _S590);
    }
    float _S591 = (F32_acos(((F32_min((_S581), (1.0f))))));
    ToonLobe_0 _S592 = _S580;
    float _S593 = toonProfile_0(_S591, &_S592);
    float _S594 = (F32_acos(((F32_min((_S582), (1.0f))))));
    ToonLobe_0 _S595 = _S580;
    float _S596 = toonProfile_0(_S594, &_S595);
    float _S597 = _S593 * _S596;
    ToonLobe_0 _S598 = _S580;
    float _S599 = toonIntegral_0(_S580.b_1, &_S598);
    return _S597 / (6.28318548202514648f * _S599);
}

static __device__ void toonMix_0(SampleBSDF * drawn_0, float3  v_8, float3  n_i_4, BSDFMaterial * material_4, BSDFLobes * lobes_2)
{
    float3  _S600 = drawn_0->unit_direction;
    float _S601 = (F32_max((drawn_0->pdf), (0.0f)));
    float _S602 = (1.0f - lobes_2->toon_share) * _S601;
    float _S603 = lobes_2->toon_share * lobes_2->p_diffuse;
    float3  _S604 = material_4->toon;
    float _S605 = toonDensity(v_8, _S600, n_i_4, material_4->toon);
    float _S606 = _S602 + _S603 * _S605;
    float3  _S607 = make_float3 ((F32_min(((F32_abs((_S604.x)))), (1.0f)))) * material_4->albedo;
    float _S608 = toonBSDF(v_8, _S600, n_i_4, _S604);
    float3  _S609 = _S607 * make_float3 (_S608) * make_float3 ((F32_max((dot_0(n_i_4, _S600)), (0.0f))));
    float3  _S610 = make_float3 (0.0f);
    float3  _S611 = (drawn_0->throughput * make_float3 (_S601) + _S609) / make_float3 (_S606);
    bool _S612 = _S606 > 0.0f;
    float3  _S613 = _slang_select(_S612, _S611,_S610);
    drawn_0->throughput = _S613;
    drawn_0->pdf = _S606;
    return;
}

__device__ __forceinline__ SampleBSDF connectBSDF(float3  in_dir_1, float3  out_dir_0, float3  n_9, BSDFMaterial material_5, float eta_i_3, float eta_o_3, uint lobe_5, uint random_init_0)
{
    uint random_state_4 = random_init_0;
    float3  _S614 = negate_0(in_dir_1);
    float _S615 = dot_0(n_9, _S614);
    float _S616 = sign_0(_S615);
    float3  _S617 = n_9 * make_float3 (_S616);
    float _S618 = material_5.roughness;
    float _S619 = _S618 * _S618;
    AnisotropicFrame _S620 = anisotropicFrame(material_5, _S617);
    float3  _S621 = _S614 + out_dir_0;
    float3  _S622 = ((((_S621)) * make_float3(rnorm3df(((_S621)).x, ((_S621)).y, ((_S621)).z))));
    bool _S623 = lobe_5 == 0U;
    float3  ggx_n_1;
    if(_S623)
    {
        float3  _S624 = sampleHalfVector(_S614, _S617, _S619, _S620, &random_state_4);
        ggx_n_1 = _S624;
    }
    else
    {
        bool _S625 = lobe_5 == 1U;
        if(_S625)
        {
            float3  _S626 = negate_0(make_float3 (eta_i_3) * _S614 + make_float3 (eta_o_3) * out_dir_0);
            float3  _S627 = ((((_S626)) * make_float3(rnorm3df(((_S626)).x, ((_S626)).y, ((_S626)).z))));
            float _S628 = sign_0(dot_0(_S626, _S617));
            float3  _S629 = _S627 * make_float3 (_S628);
            ggx_n_1 = _S629;
        }
        else
        {
            ggx_n_1 = _S622;
        }
    }
    BSDFLobes _S630 = bsdfLobes(in_dir_1, _S614, _S617, ggx_n_1, material_5, eta_i_3, eta_o_3, _S620);
    BSDFLobes lobes_3 = _S630;
    float _S631 = translucentShare(material_5);
    (&lobes_3)->translucent_share = _S631;
    float _S632 = lobeDensity(dot_0(_S617, out_dir_0), dot_0(out_dir_0, ggx_n_1), (F32_abs((_S615))), _S619, lobes_3, eta_i_3, eta_o_3, lobe_5);
    bool _S633 = !(_S632 > 0.0f);
    if(_S633)
    {
        float3  _S634 = make_float3 (0.0f);
        return SampleBSDF_x24init_0(_S634, _S634, 0U, false, 0U, 0.0f);
    }
    float3  _S635 = lobeThroughput(out_dir_0, _S617, _S619, material_5, lobes_3, lobe_5);
    SampleBSDF _S636 = SampleBSDF_x24init_0(out_dir_0, _S635, random_state_4, lobe_5 == 1U, lobe_5, _S632);
    SampleBSDF sample_0 = _S636;
    bool _S637;
    if(_S623)
    {
        _S637 = ((&lobes_3)->toon_share) > 0.0f;
    }
    else
    {
        _S637 = false;
    }
    if(_S637)
    {
        BSDFMaterial _S638 = material_5;
        BSDFLobes _S639 = lobes_3;
        toonMix_0(&sample_0, _S614, _S617, &_S638, &_S639);
    }
    return sample_0;
}

__device__ __forceinline__ float3  neeBSDF(float3  in_dir_2, float3  dir_3, float3  n_10, BSDFMaterial material_6, float eta_i_4, float eta_o_4, bool refracted_3, float pdf_1, bool power_0, uint random_state_5)
{
    float3  _S640 = make_float3 (0.0f);
    uint lobe_6 = 0U;
    float3  f_1 = _S640;
    for(;;)
    {
        if(lobe_6 < 3U)
        {
        }
        else
        {
            break;
        }
        bool _S641 = lobe_6 == 0U;
        if(_S641)
        {
        }
        bool _S642;
        if(_S641)
        {
            float _S643 = rgb_to_greyscale(material_6.translucent);
            _S642 = _S643 > 0.0f;
        }
        else
        {
            _S642 = false;
        }
        bool _S644;
        if(_S642)
        {
            float _S645 = dot_0(n_10, dir_3);
            float3  _S646 = negate_0(in_dir_2);
            _S644 = ((_S645 * dot_0(n_10, _S646)) < 0.0f) == refracted_3;
        }
        else
        {
            _S644 = (lobe_6 == 1U) == refracted_3;
        }
        float3  f_2;
        if(_S644)
        {
            SampleBSDF _S647 = connectBSDF(in_dir_2, dir_3, n_10, material_6, eta_i_4, eta_o_4, lobe_6, random_state_5);
            bool _S648 = (_S647.pdf) > 0.0f;
            if(_S648)
            {
                if(power_0)
                {
                    float _S649 = _S647.pdf / pdf_1;
                    float3  f_3 = f_1 + _S647.throughput * make_float3 (_S647.pdf) / make_float3 (pdf_1 * (1.0f + _S649 * _S649));
                    f_2 = f_3;
                }
                else
                {
                    float3  f_4 = f_1 + _S647.throughput * make_float3 (_S647.pdf) / make_float3 (_S647.pdf + pdf_1);
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
    bool _S650 = wrongSide_0(is_inside_2, false, dir_4, surface_1.geometry_n);
    float3  _S651 = neeBSDF(in_dir_3, dir_4, surface_1.smooth_n, surface_1.material, eta_1.x, eta_1.y, _S650, pdf_2, false, random_state_6);
    return _S651;
}

static __device__ SkySample SkySample_x24init_0(float3  dir_5, float3  radiance_0, float3  color_0, uint random_state_7)
{
    SkySample _S652;
    (&_S652)->dir = dir_5;
    (&_S652)->radiance = radiance_0;
    (&_S652)->color = color_0;
    (&_S652)->random_state = random_state_7;
    return _S652;
}

static __device__ SkySample sampleSky_0(FKRay * ray_0, FKSurface * surface_2, float2  eta_2, bool is_inside_3, uint init_random_state_0, uint lobe_state_0, ShadowContext * context_2)
{
    uint2  _S653 = (fcptEnvironmentCdfSize());
    uint2  _S654 = make_uint2 (1U, 0U);
    uint2  _S655 = _S653 - _S654;
    Random _S656 = pcg(init_random_state_0);
    Random _S657 = pcg(_S656.state);
    Random _S658 = pcg(_S657.state);
    Random _S659 = pcg(_S658.state);
    uint _S660 = _S655.x;
    uint _S661 = searchCDF_0(make_uint2 (_S660, 0U), make_uint2 (0U, 1U), _S655.y, _S656.value);
    uint _S662 = searchCDF_0(make_uint2 (0U, _S661), _S654, _S660, _S657.value);
    float2  _S663 = make_float2 ((float)_S655.x, (float)_S655.y);
    float2  _S664 = (make_float2 (float(_S662), float(_S661)) + make_float2 (_S658.value, _S659.value)) / _S663 * make_float2 (6.28318548202514648f, 3.14159274101257324f);
    float _S665 = _S664.y;
    float _S666 = (F32_sin((_S665)));
    float _S667 = _S664.x;
    float3  _S668 = make_float3 (- _S666 * (F32_cos((_S667))), _S666 * (F32_sin((_S667))), (F32_cos((_S665))));
    float _S669 = environmentPdf_0(_S668);
    float3  _S670 = skyBSDF(ray_0->unit_direction, _S668, *surface_2, eta_2, is_inside_3, _S669, lobe_state_0);
    bool _S671 = !(_S669 > 0.0f);
    bool _S672;
    if(_S671)
    {
        _S672 = true;
    }
    else
    {
        _S672 = all_1(_S670 == make_float3 (0.0f));
    }
    if(_S672)
    {
        float3  _S673 = make_float3 (0.0f);
        return SkySample_x24init_0(_S668, _S673, _S673, _S659.state);
    }
    float3  _S674 = skyRadiance_0(ray_0->origin, surface_2, is_inside_3, _S668, context_2, _S659.state);
    return SkySample_x24init_0(_S668, _S674, _S670 * _S674, _S659.state);
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
    SampleBSDF _S675 = (fcptConnectHair((surface_3->hair), ((&surface_3->material)->albedo), ((&surface_3->material)->specular_tint), (in_dir_4), (light_1->dir)));
    float3  _S676 = _S675.throughput * make_float3 (_S675.pdf);
    float _S677 = light_1->density;
    float _S678 = 1.0f + _S675.pdf * _S675.pdf / (light_1->density * light_1->density);
    bool _S679;
    if(competing_0)
    {
        _S679 = _S677 > 0.0f;
    }
    else
    {
        _S679 = false;
    }
    float _S680 = _slang_select(_S679, _S678,1.0f);
    return _S676 / make_float3 (_S680) * light_1->radiance;
}

static __device__ TreeSample TreeSample_x24init_0(float3  dir_6, float3  radiance_1, float density_0, uint random_state_8)
{
    TreeSample _S681;
    (&_S681)->dir = dir_6;
    (&_S681)->radiance = radiance_1;
    (&_S681)->density = density_0;
    (&_S681)->random_state = random_state_8;
    return _S681;
}

__device__ uint pickChild(LightNode first_1, LightNode second_1, float3  p_10, float3  normal_3, float * pick_0, float * probability_3)
{
    float _S682 = importance(first_1, p_10, normal_3);
    float _S683 = importance(second_1, p_10, normal_3);
    float2  _S684 = make_float2 (_S682, _S683);
    bool _S685 = _S682 == 0.0f;
    bool _S686;
    if(_S685)
    {
        _S686 = _S683 == 0.0f;
    }
    else
    {
        _S686 = false;
    }
    if(_S686)
    {
        return 2U;
    }
    float _S687 = _S682 + _S683;
    bool _S688 = _S683 > 0.0f;
    if(_S688)
    {
        _S686 = (*pick_0 * _S687) >= _S682;
    }
    else
    {
        _S686 = false;
    }
    uint _S689 = uint(_S686);
    float _S690 = (F32_min(((*pick_0 * _S687 - float(_S689) * _S682) / _slang_vector_get_element(_S684, _S689)), (0.99999994039535522f)));
    *pick_0 = _S690;
    float _S691 = *probability_3 * (_slang_vector_get_element(_S684, _S689) / _S687);
    *probability_3 = _S691;
    return _S689;
}

__device__ float3  sampleSphere(float3  center_1, float radius_1, float3  p_11, float u1_0, float u2_0)
{
    float3  _S692 = center_1 - p_11;
    float _S693 = radius_1 * radius_1 / dot_0(_S692, _S692);
    float _S694 = u1_0 * _S693 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S693), (0.0f)))))));
    float _S695 = 2.0f * u1_0;
    bool _S696 = _S693 >= 1.0f;
    float _S697 = _slang_select(_S696, _S695,_S694);
    float _S698 = (F32_sqrt(((F32_max((_S697 * (2.0f - _S697)), (0.0f))))));
    float _S699 = 6.28318548202514648f * u2_0;
    float3  _S700 = make_float3 (_S698 * (F32_cos((_S699))), 1.0f - _S697, _S698 * (F32_sin((_S699))));
    float3  _S701 = ((((_S692)) * make_float3(rnorm3df(((_S692)).x, ((_S692)).y, ((_S692)).z))));
    float3  _S702 = tangentToWorld(_S700, _S701);
    return _S702;
}

__device__ float3  pointLightRadiance(float3  color_1, float intensity_0, float radius_2)
{
    return color_1 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_2 * radius_2);
}

static __device__ float raySphere_0(float3  center_2, float radius_3, FKRay * ray_1, float max_len_0)
{
    float3  _S703 = center_2 - ray_1->origin;
    float _S704 = dot_0(_S703, ray_1->unit_direction);
    float _S705 = dot_0(_S703, _S703) - _S704 * _S704;
    float _S706 = radius_3 * radius_3;
    bool _S707 = _S705 > _S706;
    if(_S707)
    {
        return 4.294967296e+09f;
    }
    float _S708 = (F32_sqrt((_S706 - _S705)));
    float _S709 = _S704 - _S708;
    float _S710 = _S704 + _S708;
    bool _S711 = _S709 > 0.0000152587890625f;
    bool _S712;
    if(_S711)
    {
        _S712 = _S709 < max_len_0;
    }
    else
    {
        _S712 = false;
    }
    if(_S712)
    {
        return _S709;
    }
    bool _S713 = _S710 > 0.0000152587890625f;
    if(_S713)
    {
        _S712 = _S710 < max_len_0;
    }
    else
    {
        _S712 = false;
    }
    if(_S712)
    {
        return _S710;
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
    Random _S714 = pcg(init_random_state_1);
    Random _S715 = pcg(_S714.state);
    Random _S716 = pcg(_S715.state);
    float3  _S717 = make_float3 (0.0f);
    TreeSample _S718 = TreeSample_x24init_0(_S717, _S717, 0.0f, _S716.state);
    TreeSample sample_1 = _S718;
    float3  _S719 = _slang_select(sided_0, _S717,smooth_n_2);
    float3  _S720 = origin_4 + make_float3 (geometry_offset_1) * smooth_n_2;
    float pick_1 = _S714.value;
    float probability_4 = 1.0f;
    uint n_11 = 0U;
    for(;;)
    {
        uint4  _S721 = (fcptLightNode((n_11)));
        if((_S721.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S722 = (fcptLightSecond((n_11)));
        uint _S723 = n_11 + 1U;
        LightNode _S724 = (fcptLightBounds((_S723)));
        LightNode _S725 = (fcptLightBounds((_S722)));
        uint _S726 = pickChild(_S724, _S725, origin_4, _S719, &pick_1, &probability_4);
        bool _S727 = _S726 > 1U;
        if(_S727)
        {
            return sample_1;
        }
        bool _S728 = _S726 == 1U;
        uint _S729 = _slang_select(_S728, _S722,_S723);
        n_11 = _S729;
    }
    bool _S730 = n_11 == 0U;
    bool _S731;
    if(_S730)
    {
        LightNode _S732 = (fcptLightBounds((0U)));
        float _S733 = importance(_S732, origin_4, _S719);
        _S731 = !(_S733 > 0.0f);
    }
    else
    {
        _S731 = false;
    }
    if(_S731)
    {
        return sample_1;
    }
    uint4  _S734 = (fcptLightNode((n_11)));
    FKHit _S735 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    bool _S736 = (_S734.x) == 2U;
    float3  emitter_point_0;
    float3  lift_n_0;
    float3  shadow_1;
    FKHit emitter_0;
    if(_S736)
    {
        FKLight _S737 = (fcptLight((_S734.y)));
        if(sided_0)
        {
            float _S738 = sign_0(dot_0(geometry_n_1, _S737.position - origin_4));
            float3  lift_n_1 = smooth_n_2 * make_float3 (_S738);
            float3  _S739 = origin_4 + make_float3 (geometry_offset_1) * lift_n_1;
            emitter_point_0 = _S739;
            lift_n_0 = lift_n_1;
        }
        else
        {
            emitter_point_0 = _S720;
            lift_n_0 = smooth_n_2;
        }
        bool _S740 = (_S737.variance) == 0.0f;
        if(_S740)
        {
            float3  _S741 = _S737.position - emitter_point_0;
            float3  _S742 = ((((_S741)) * make_float3(rnorm3df(((_S741)).x, ((_S741)).y, ((_S741)).z))));
            (&sample_1)->dir = _S742;
            float3  _S743 = _S737.color * make_float3 (_S737.intensity) / make_float3 (dot_0(_S741, _S741) * probability_4);
            (&sample_1)->radiance = _S743;
            shadow_1 = _S741;
        }
        else
        {
            float3  _S744 = sampleSphere(_S737.position, _S737.variance, emitter_point_0, _S715.value, _S716.value);
            (&sample_1)->dir = _S744;
            float _S745 = sphereDensity(_S737.position, _S737.variance, emitter_point_0);
            float _S746 = probability_4 * _S745;
            (&sample_1)->density = _S746;
            float3  _S747 = pointLightRadiance(_S737.color, _S737.intensity, _S737.variance);
            float3  _S748 = _S747 / make_float3 ((&sample_1)->density);
            (&sample_1)->radiance = _S748;
            FKRay _S749 = Ray_x24init_0(emitter_point_0, (&sample_1)->dir);
            float _S750 = raySphere_0(_S737.position, _S737.variance, &_S749, 4.294967296e+09f);
            float3  _S751 = (&sample_1)->dir * make_float3 (_S750);
            shadow_1 = _S751;
        }
        emitter_0 = _S735;
        emitter_point_0 = _S717;
    }
    else
    {
        uint _S752 = _S734.y;
        uint _S753 = (fcptTriangleOffset((_S752)));
        uint _S754 = _S753 + _S734.z;
        Matrix<float, 3, 3>  _S755 = (fcptWorldTriangle((_S752), (_S754)));
        float _S756 = (F32_sqrt((_S715.value)));
        float2  _S757 = make_float2 (_S756 * (1.0f - _S716.value), _S756 * _S716.value);
        float3  _S758 = mul_0(make_float3 (1.0f - _S756, _S757.x, _S757.y), _S755);
        if(sided_0)
        {
            float _S759 = sign_0(dot_0(geometry_n_1, _S758 - origin_4));
            float3  lift_n_2 = smooth_n_2 * make_float3 (_S759);
            float3  _S760 = origin_4 + make_float3 (geometry_offset_1) * lift_n_2;
            emitter_point_0 = _S760;
            lift_n_0 = lift_n_2;
        }
        else
        {
            bool _S761 = !((dot_0(smooth_n_2, _S758 - origin_4)) > 0.0f);
            if(_S761)
            {
                return sample_1;
            }
            emitter_point_0 = _S720;
            lift_n_0 = smooth_n_2;
        }
        FKHit emitter_1 = Hit_x24init_0(_S757, _S752, _S754, 0U, 0.0f);
        float3  _S762 = _S758 - emitter_point_0;
        float3  _S763 = ((((_S762)) * make_float3(rnorm3df(((_S762)).x, ((_S762)).y, ((_S762)).z))));
        (&sample_1)->dir = _S763;
        float _S764 = solidAngle(probability_4, cross_0(_S755.rows[int(1)] - _S755.rows[int(0)], _S755.rows[int(2)] - _S755.rows[int(0)]), _S762);
        (&sample_1)->density = _S764;
        bool _S765 = (fcptShadowFirst());
        bool _S766 = !_S765;
        if(_S766)
        {
            FKSurface _S767 = (fcptLightSurfaceAt((emitter_1), (_S758), (_S716.state), ((&sample_1)->dir), (context_3->depth), (length_0(_S758 - origin_4))));
            (&sample_1)->random_state = _S767.random_state;
            float3  _S768 = _slang_select(_S767.skip, _S717,_S767.material.emissive);
            float3  _S769 = _S768 / make_float3 ((&sample_1)->density);
            (&sample_1)->radiance = _S769;
        }
        shadow_1 = _S762;
        emitter_0 = emitter_1;
        emitter_point_0 = _S758;
    }
    FKHit _S770 = emitter_0;
    float3  _S771 = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, context_3, _S716.state, &_S770);
    bool _S772 = (fcptShadowFirst());
    if(_S772)
    {
        _S731 = (emitter_0.instance_index) != 4294967295U;
    }
    else
    {
        _S731 = false;
    }
    if(_S731)
    {
        _S731 = !all_1(_S771 == _S717);
    }
    else
    {
        _S731 = false;
    }
    if(_S731)
    {
        FKSurface _S773 = (fcptLightSurfaceAt((emitter_0), (emitter_point_0), (_S716.state), ((&sample_1)->dir), (context_3->depth), (length_0(emitter_point_0 - origin_4))));
        (&sample_1)->random_state = _S773.random_state;
        float3  _S774 = _slang_select(_S773.skip, _S717,_S773.material.emissive);
        float3  _S775 = _S774 / make_float3 ((&sample_1)->density);
        (&sample_1)->radiance = _S775;
    }
    float3  _S776 = (&sample_1)->radiance * _S771;
    bool _S777 = all_1(_S771 == _S717);
    float3  _S778 = _slang_select(_S777, _S717,_S776);
    (&sample_1)->radiance = _S778;
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
    float _S779 = 1.0f / (1.0f + b_3 / a_7 * (b_3 / a_7));
    bool _S780 = b_3 > 0.0f;
    float _S781 = _slang_select(_S780, _S779,1.0f);
    return _S781;
}

static __device__ float emissionWeight_0(NEEVertex * vertex_0, FKHit * hit_1, float3  light_point_1)
{
    bool _S782 = vertex_0->none;
    if(_S782)
    {
        return 1.0f;
    }
    uint _S783 = (fcptLightSlot((*hit_1)));
    float _S784 = lightPdf_0(vertex_0->origin, vertex_0->smooth_n, vertex_0->start, _S783, light_point_1);
    float _S785 = powerHeuristic(vertex_0->pdf, _S784);
    return _S785;
}

static __device__ float3  environment_0(float3  dir_7, uint depth_0, uint lobe_8)
{
    uint2  _S786 = (fcptEnvironmentMapSize());
    bool _S787 = (_S786.x) > 1U;
    bool _S788;
    if(_S787)
    {
        uint2  _S789 = (fcptEnvironmentMapSize());
        _S788 = (_S789.y) > 1U;
    }
    else
    {
        _S788 = false;
    }
    if(_S788)
    {
        float3  _S790 = (fcptEnvMapSample((dir_7), (depth_0), (lobe_8)));
        return _S790;
    }
    float3  _S791 = (fcptAmbient());
    return _S791;
}

static __device__ bool environmentMapped_0()
{
    uint2  _S792 = (fcptEnvironmentCdfSize());
    bool _S793 = (_S792.x) > 1U;
    bool _S794;
    if(_S793)
    {
        uint2  _S795 = (fcptEnvironmentCdfSize());
        _S794 = (_S795.y) > 1U;
    }
    else
    {
        _S794 = false;
    }
    bool _S796 = !_S794;
    if(_S796)
    {
        return false;
    }
    uint2  _S797 = (fcptEnvironmentMapSize());
    bool _S798 = (_S797.x) > 1U;
    if(_S798)
    {
        uint2  _S799 = (fcptEnvironmentMapSize());
        _S794 = (_S799.y) > 1U;
    }
    else
    {
        _S794 = false;
    }
    return _S794;
}

static __device__ float escapeWeight_0(float pdf_3, float3  dir_8)
{
    bool _S800 = pdf_3 <= 0.0f;
    bool _S801;
    if(_S800)
    {
        _S801 = true;
    }
    else
    {
        bool _S802 = environmentMapped_0();
        _S801 = !_S802;
    }
    if(_S801)
    {
        return 1.0f;
    }
    float _S803 = environmentPdf_0(dir_8);
    return pdf_3 / (pdf_3 + _S803);
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
    uint2  _S804 = uint2 {global_invocation_id_1.x, global_invocation_id_1.y};
    int2  _S805 = make_int2 ((int)_S804.x, (int)_S804.y);
    uint _S806 = previousSeed_0(_S805);
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
            uint _S807 = previousSeed_0(_S805 + make_int2 (x_16, y_5));
            bool _S808 = _S807 == _S806;
            uint _S809 = _slang_select(_S808, 1U,0U);
            uint count_3 = count_2 + _S809;
            int x_17 = x_16 + int(1);
            x_16 = x_17;
            count_2 = count_3;
        }
        int y_6 = y_5 + int(1);
        y_5 = y_6;
    }
    float _S810 = float(count_2 - 1U) / 288.0f;
    bool _S811 = _S806 != 0U;
    float _S812 = _slang_select(_S811, _S810,0.0f);
    fcptStoreDuplication((_S805), (make_uint4 ((F32_asuint((_S812))), 0U, 0U, 0U)));
    return;
}

__device__ uint stream(uint seed_2, uint index_0)
{
    uint _S813 = hash(index_0);
    uint _S814 = hash(seed_2 ^ _S813);
    return _S814;
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
    float _S815 = rgb_to_greyscale(weight_0);
    bool _S816 = _S815 > 0.0f;
    bool _S817;
    if(_S816)
    {
        _S817 = _S815 < 3.00000000549775576e+38f;
    }
    else
    {
        _S817 = false;
    }
    bool _S818 = !_S817;
    if(_S818)
    {
        return;
    }
    bool _S819 = sel_2->sums;
    if(_S819)
    {
        float3  _S820 = sel_2->color + weight_0;
        sel_2->color = _S820;
        return;
    }
    float _S821 = sel_2->w_sum + _S815;
    sel_2->w_sum = _S821;
    float3  _S822 = sel_2->color + weight_0;
    sel_2->color = _S822;
    Random _S823 = pcg(sel_2->random_state);
    sel_2->random_state = _S823.state;
    bool _S824 = (_S823.value * sel_2->w_sum) <= _S815;
    if(_S824)
    {
        sel_2->r = candidate_0;
    }
    return;
}

__device__ void offerShifted(Selection * sel_3, Reservoir r_7, Shift shifted_0, float mis_0)
{
    Reservoir candidate_1 = r_7;
    float3  _S825 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_1)->f = _S825;
    float _S826 = r_7.jac * shifted_0.jac;
    (&candidate_1)->jac = _S826;
    offer(sel_3, candidate_1, make_float3 (mis_0) * shifted_0.f * make_float3 (r_7.w));
    return;
}

__device__ Reservoir finalize(Selection sel_4, float c_1)
{
    Reservoir r_8 = sel_4.r;
    float _S827 = rgb_to_greyscale((&r_8)->f);
    float _S828 = sel_4.w_sum / _S827;
    bool _S829 = _S827 > 0.0f;
    float _S830 = _slang_select(_S829, _S828,0.0f);
    (&r_8)->w = _S830;
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
    uint2  _S831 = uint2 {global_invocation_id_2.x, global_invocation_id_2.y};
    int2  _S832 = make_int2 ((int)_S831.x, (int)_S831.y);
    float3  _S833 = make_float3 (0.0f);
    FKHit _S834 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S835 = Domain_x24init_0(_S833, _S833, &_S834, 0.0f, 0.0f);
    Domain dom_4 = _S835;
    bool _S836 = (fcptCurrentDomain((_S832), (&dom_4)));
    bool _S837 = !_S836;
    if(_S837)
    {
        Reservoir _S838 = (Reservoir{});
        fcptStoreReservoirPrevious((_S832), (_S838), ((&dom_4)->hit));
        return;
    }
    Reservoir _S839 = (fcptLoadReservoirTemporal((_S832)));
    uint t_15 = 0U;
    float count_4 = 0.0f;
    float c_sum_1 = _S839.c;
    for(;;)
    {
        uint _S840 = (fcptRestirNeighbours());
        if(t_15 < _S840)
        {
        }
        else
        {
            break;
        }
        int2  _S841 = partner_0(_S832, t_15);
        Domain neighbor_0 = _S835;
        bool _S842 = (fcptCurrentDomain((_S841), (&neighbor_0)));
        if(_S842)
        {
            float count_5 = count_4 + 1.0f;
            uint4  _S843 = (fcptReservoirTemporal((_S841), (0U)));
            float c_sum_2 = c_sum_1 + (U32_asfloat((_S843.w)));
            count_4 = count_5;
            c_sum_1 = c_sum_2;
        }
        uint t_16 = t_15 + 1U;
        t_15 = t_16;
    }
    float _S844 = _S839.c / (F32_max((count_4), (1.0f)));
    float _S845 = rgb_to_greyscale(_S839.f);
    bool _S846 = count_4 == 0.0f;
    float _S847 = _slang_select(_S846, 1.0f,0.0f);
    Selection _S848 = (Selection{});
    Selection sel_5 = _S848;
    uint _S849 = (fcptFrame());
    uint _S850 = hash(_S849);
    uint _S851 = global_invocation_id_2.x;
    uint2  _S852 = (fcptRenderSize());
    uint _S853 = stream(_S850, _S851 + _S852.x * global_invocation_id_2.y);
    uint _S854 = stream(_S853, 195U);
    (&sel_5)->random_state = _S854;
    t_15 = 0U;
    float canonical_mis_0 = _S847;
    for(;;)
    {
        uint _S855 = (fcptRestirNeighbours());
        if(t_15 < _S855)
        {
        }
        else
        {
            break;
        }
        int2  _S856 = partner_0(_S832, t_15);
        Domain neighbor_dom_0 = _S835;
        bool _S857 = (fcptCurrentDomain((_S856), (&neighbor_dom_0)));
        if(_S857)
        {
            Reservoir _S858 = (fcptLoadReservoirTemporal((_S856)));
            uint4  _S859 = (fcptShiftData((_S856), (t_15)));
            float4  _S860 = asfloat_0(_S859);
            uint4  _S861 = (fcptShiftData((_S832), (t_15)));
            float4  _S862 = asfloat_0(_S861);
            float _S863 = pairShare(_S858.c, _S844, c_sum_1);
            bool _S864 = _S845 > 0.0f;
            float canonical_mis_1;
            if(_S864)
            {
                float _S865 = rgb_to_greyscale(float3 {_S862.x, _S862.y, _S862.z});
                float _S866 = canonicalWeight(_S863, _S844, _S845, _S858.c, _S865);
                float canonical_mis_2 = canonical_mis_0 + _S866;
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            float3  _S867 = float3 {_S860.x, _S860.y, _S860.z};
            Shift _S868 = Shift_x24init_0(_S867, _S860.w);
            float _S869 = rgb_to_greyscale(_S858.f);
            float _S870 = rgb_to_greyscale(_S867);
            float _S871 = neighborWeight(_S863, _S858.c, _S869, _S844, _S870);
            offerShifted(&sel_5, _S858, _S868, _S871);
            canonical_mis_0 = canonical_mis_1;
        }
        uint t_17 = t_15 + 1U;
        t_15 = t_17;
    }
    offerShifted(&sel_5, _S839, Shift_x24init_0(_S839.f, 1.0f), canonical_mis_0);
    Reservoir _S872 = finalize(sel_5, c_sum_1);
    fcptStoreReservoirPrevious((_S832), (_S872), ((&dom_4)->hit));
    fcptStorePreviousLayer((_S832), (5U), (make_uint4 (asuint_0((&(&dom_4)->hit)->uv).x, asuint_0((&(&dom_4)->hit)->uv).y, 0U, 0U)));
    fcptAddColor((_S832), (make_float4 ((&sel_5)->color.x, (&sel_5)->color.y, (&sel_5)->color.z, 0.0f)));
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
    uint _S873 = queuedShift_0(workgroup_id_1, local_invocation_index_4);
    bool _S874 = _S873 != 4294967295U;
    if(_S874)
    {
        uint2  _S875 = make_uint2 (_S873, _S873 >> 14U) & make_uint2 (16383U);
        int2  _S876 = make_int2 ((int)_S875.x, (int)_S875.y);
        ShiftJob _S877 = (ShiftJob{});
        ShiftJob shift_job_0 = _S877;
        Shift _S878 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
        uint _S879 = _S873 >> 28U;
        bool _S880 = spatialJob_0(_S876, _S879, &shift_job_0, true);
        Shift shifted_1;
        if(_S880)
        {
            Domain _S881 = (&shift_job_0)->dom;
            Reservoir _S882 = (&shift_job_0)->r;
            Shift _S883 = passShift_0(&_S881, &_S882);
            shifted_1 = _S883;
        }
        else
        {
            shifted_1 = _S878;
        }
        fcptStoreShiftData((_S876), (_S879), (make_uint4 (asuint_1(shifted_1.f).x, asuint_1(shifted_1.f).y, asuint_1(shifted_1.f).z, (F32_asuint((shifted_1.jac))))));
    }
    return;
}

static __device__ void restir_prepass_0(uint3  global_invocation_id_3, uint local_invocation_index_5)
{
    uint2  _S884 = uint2 {global_invocation_id_3.x, global_invocation_id_3.y};
    int2  _S885 = make_int2 ((int)_S884.x, (int)_S884.y);
    FixedArray<uint, 3>  _S886;
    spatialBins_0(_S885, &_S886);
    FixedArray<uint, 3>  _S887 = _S886;
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
        bool _S888 = (_S887[t_18]) == 40U;
        if(_S888)
        {
            fcptStoreShiftData((_S885), (t_18), (make_uint4 (0U)));
        }
        uint t_19 = t_18 + 1U;
        t_18 = t_19;
    }
    FixedArray<uint, 3>  _S889 = _S887;
    queueShifts_0(_S885, &_S889, global_invocation_id_3, local_invocation_index_5);
    return;
}

static __device__ void restir_count_0(uint3  global_invocation_id_4, uint local_invocation_index_6)
{
    uint2  _S890 = uint2 {global_invocation_id_4.x, global_invocation_id_4.y};
    int2  _S891 = make_int2 ((int)_S890.x, (int)_S890.y);
    FixedArray<uint, 3>  _S892;
    spatialBins_0(_S891, &_S892);
    FixedArray<uint, 3>  _S893 = _S892;
    countShifts_0(&_S893, local_invocation_index_6);
    return;
}

static __device__ void restir_temporal_shift_0(uint3  workgroup_id_2, uint local_invocation_index_7)
{
    uint _S894 = queuedShift_0(workgroup_id_2, local_invocation_index_7);
    bool _S895 = _S894 != 4294967295U;
    if(_S895)
    {
        uint2  _S896 = make_uint2 (_S894, _S894 >> 14U) & make_uint2 (16383U);
        int2  _S897 = make_int2 ((int)_S896.x, (int)_S896.y);
        ShiftJob _S898 = (ShiftJob{});
        ShiftJob shift_job_1 = _S898;
        Shift _S899 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
        uint _S900 = _S894 >> 28U;
        bool _S901 = temporalJob_0(_S897, _S900, &shift_job_1, true);
        Shift shifted_2;
        if(_S901)
        {
            if(_S900 == 1U)
            {
                Shift _S902 = (fcptShiftPrevious(((&shift_job_1)->dom), ((&shift_job_1)->r)));
                shifted_2 = _S902;
            }
            else
            {
                Domain _S903 = (&shift_job_1)->dom;
                Reservoir _S904 = (&shift_job_1)->r;
                Shift _S905 = passShift_0(&_S903, &_S904);
                shifted_2 = _S905;
            }
        }
        else
        {
            shifted_2 = _S899;
        }
        fcptStoreTemporalShift((_S897), (_S900), (make_uint4 (asuint_1(shifted_2.f).x, asuint_1(shifted_2.f).y, asuint_1(shifted_2.f).z, (F32_asuint((shifted_2.jac))))));
    }
    return;
}

static __device__ void restir_temporal_prepass_0(uint3  global_invocation_id_5, uint local_invocation_index_8)
{
    uint2  _S906 = uint2 {global_invocation_id_5.x, global_invocation_id_5.y};
    int2  _S907 = make_int2 ((int)_S906.x, (int)_S906.y);
    FixedArray<uint, 3>  _S908;
    temporalBins_0(_S907, &_S908);
    FixedArray<uint, 3>  _S909 = _S908;
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
        bool _S910 = (_S909[t_20]) == 40U;
        if(_S910)
        {
            fcptStoreTemporalShift((_S907), (t_20), (make_uint4 (0U)));
        }
        uint t_21 = t_20 + 1U;
        t_20 = t_21;
    }
    FixedArray<uint, 3>  _S911 = _S909;
    queueShifts_0(_S907, &_S911, global_invocation_id_5, local_invocation_index_8);
    return;
}

static __device__ void restir_temporal_count_0(uint3  global_invocation_id_6, uint local_invocation_index_9)
{
    uint2  _S912 = uint2 {global_invocation_id_6.x, global_invocation_id_6.y};
    int2  _S913 = make_int2 ((int)_S912.x, (int)_S912.y);
    FixedArray<uint, 3>  _S914;
    temporalBins_0(_S913, &_S914);
    FixedArray<uint, 3>  _S915 = _S914;
    countShifts_0(&_S915, local_invocation_index_9);
    return;
}

static __device__ float interpolate_0(float a_8, float b_4, float t_22)
{
    return a_8 + (b_4 - a_8) * t_22;
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
    Domain stored_0 = _S923;
    int2  _S928 = make_int2 (int(-1));
    bool _S929 = (fcptStoredDomainInitial((_S920), (_S927.seed), (&stored_0)));
    int2  q_2;
    if(_S929)
    {
        Domain _S930 = stored_0;
        int2  _S931 = temporalNeighbor_0(_S920, &_S930, _S927.seed);
        q_2 = _S931;
    }
    else
    {
        q_2 = _S928;
    }
    bool _S932 = (q_2.x) >= int(0);
    Reservoir r_9;
    if(_S932)
    {
        Reservoir _S933 = (fcptLoadReservoirPrevious((q_2)));
        uint4  _S934 = (fcptDuplication((q_2)));
        float _S935 = (U32_asfloat((_S934.x)));
        uint _S936 = (fcptRestirDecorrelation());
        bool _S937 = _S936 == 1U;
        float _S938 = _slang_select(_S937, _S935,0.0f);
        float _S939 = confidenceCap(_S938);
        float _S940 = (F32_min((_S933.c), (_S939)));
        Domain target_3 = _S923;
        bool _S941 = (_S933.w) > 0.0f;
        bool _S942;
        if(_S941)
        {
            bool _S943 = (fcptStoredDomainInitial((_S920), (_S933.seed), (&target_3)));
            _S942 = _S943;
        }
        else
        {
            _S942 = false;
        }
        if(_S942)
        {
            Domain _S944 = (fcptPreviousDomain((q_2), (_S933.seed)));
            Domain _S945 = _S944;
            Domain _S946 = target_3;
            bool _S947 = temporalIdentity_0(0U, &_S945, &_S946);
            _S942 = _S947;
        }
        else
        {
            _S942 = false;
        }
        float4  _S948;
        if(_S942)
        {
            _S948 = make_float4 (_S933.f.x, _S933.f.y, _S933.f.z, 1.0f);
        }
        else
        {
            uint4  _S949 = (fcptTemporalShift((_S920), (0U)));
            _S948 = asfloat_0(_S949);
        }
        bool _S950 = (_S927.w) > 0.0f;
        if(_S950)
        {
            Domain _S951 = (fcptPreviousDomain((q_2), (_S927.seed)));
            Domain _S952 = _S951;
            Domain _S953 = stored_0;
            bool _S954 = temporalIdentity_0(1U, &_S952, &_S953);
            _S942 = _S954;
        }
        else
        {
            _S942 = false;
        }
        float4  _S955;
        if(_S942)
        {
            _S955 = make_float4 (_S927.f.x, _S927.f.y, _S927.f.z, 1.0f);
        }
        else
        {
            uint4  _S956 = (fcptTemporalShift((_S920), (1U)));
            _S955 = asfloat_0(_S956);
        }
        float _S957 = rgb_to_greyscale(_S927.f);
        float _S958 = rgb_to_greyscale(_S933.f);
        Selection _S959 = (Selection{});
        Selection sel_6 = _S959;
        uint _S960 = (fcptFrame());
        uint _S961 = hash(_S960);
        uint _S962 = global_invocation_id_7.x;
        uint2  _S963 = (fcptRenderSize());
        uint _S964 = stream(_S961, _S962 + _S963.x * global_invocation_id_7.y);
        uint _S965 = stream(_S964, 194U);
        (&sel_6)->random_state = _S965;
        float4  _S966 = _S955;
        float _S967 = rgb_to_greyscale(float3 {_S966.x, _S966.y, _S966.z});
        float4  _S968 = _S948;
        float3  _S969 = float3 {_S968.x, _S968.y, _S968.z};
        float _S970 = rgb_to_greyscale(_S969);
        float2  _S971 = temporalWeights(_S927.c, _S957, _S940, _S958, _S967, _S970);
        offerShifted(&sel_6, _S927, Shift_x24init_0(_S927.f, 1.0f), _S971.x);
        offerShifted(&sel_6, _S933, Shift_x24init_0(_S969, _S948.w), _S971.y);
        Reservoir _S972 = finalize(sel_6, _S927.c + _S940);
        r_9 = _S972;
    }
    else
    {
        r_9 = _S927;
    }
    fcptStoreReservoirTemporal((_S920), (r_9), ((&dom_5)->hit));
    return;
}

static __device__ void restir_initial_0(uint3  global_invocation_id_8)
{
    uint2  _S973 = uint2 {global_invocation_id_8.x, global_invocation_id_8.y};
    int2  _S974 = make_int2 ((int)_S973.x, (int)_S973.y);
    float3  _S975 = make_float3 (0.0f);
    float2  _S976 = make_float2 (0.0f);
    FKHit _S977 = Hit_x24init_0(_S976, 0U, 0U, 0U, 0.0f);
    Domain _S978 = Domain_x24init_0(_S975, _S975, &_S977, 0.0f, 0.0f);
    Domain dom_6 = _S978;
    bool _S979 = (fcptCurrentDomain((_S974), (&dom_6)));
    bool _S980 = !_S979;
    if(_S980)
    {
        Reservoir _S981 = (Reservoir{});
        fcptStoreReservoirInitial((_S974), (_S981), ((&dom_6)->hit));
        return;
    }
    uint _S982 = (fcptFrame());
    uint _S983 = hash(_S982);
    uint _S984 = global_invocation_id_8.x;
    uint2  _S985 = (fcptRenderSize());
    uint _S986 = stream(_S983, _S984 + _S985.x * global_invocation_id_8.y);
    Selection _S987 = (Selection{});
    Selection initial_0 = _S987;
    uint _S988 = stream(_S986, 193U);
    (&initial_0)->random_state = _S988;
    bool _S989 = (fcptRestirUsed());
    bool _S990 = !_S989;
    (&initial_0)->sums = _S990;
    uint _S991 = stream(_S986, 0U);
    (&(&initial_0)->r)->seed = _S991;
    FKHit _S992 = Hit_x24init_0(_S976, 4294967295U, 0U, 0U, 0.0f);
    uint _S993 = (fcptSamples());
    float _S994 = 1.0f / float(_S993);
    FKHit hit_2 = _S992;
    uint i_11 = 0U;
    for(;;)
    {
        uint _S995 = (fcptSamples());
        if(i_11 < _S995)
        {
        }
        else
        {
            break;
        }
        Reservoir _S996 = (Reservoir{});
        Reservoir r_10 = _S996;
        uint _S997 = stream(_S986, i_11);
        (&r_10)->seed = _S997;
        Domain path_0 = _S978;
        bool _S998 = (fcptStoredDomainInitial((_S974), ((&r_10)->seed), (&path_0)));
        bool _S999 = !_S998;
        if(_S999)
        {
            fcptMissed((_S974), (path_0), (_S994));
            uint i_12 = i_11 + 1U;
            i_11 = i_12;
            continue;
        }
        Domain _S1000 = path_0;
        Reservoir _S1001 = r_10;
        Shift _S1002 = passWalk_0(&_S1000, &_S1001, false, _S994, &initial_0);
        bool _S1003 = ((&(&initial_0)->r)->seed) == ((&r_10)->seed);
        FKHit hit_3;
        if(_S1003)
        {
            FKHit _S1004 = (&path_0)->hit;
            hit_3 = _S1004;
        }
        else
        {
            hit_3 = hit_2;
        }
        hit_2 = hit_3;
        uint i_12 = i_11 + 1U;
        i_11 = i_12;
    }
    float3  _S1005 = (&initial_0)->glow;
    float3  _S1006 = (&initial_0)->color;
    bool _S1007 = (&initial_0)->sums;
    float3  _S1008 = _slang_select(_S1007, _S1006,_S975);
    fcptAddColor((_S974), (make_float4 ((_S1005 + _S1008).x, (_S1005 + _S1008).y, (_S1005 + _S1008).z, 1.0f)));
    Reservoir _S1009 = finalize(initial_0, 1.0f);
    fcptStoreReservoirInitial((_S974), (_S1009), (hit_2));
    return;
}

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_4, float3  origin_5, float3  smooth_n_3, float3  start_6)
{
    NEEVertex _S1010;
    (&_S1010)->none = none_0;
    (&_S1010)->pdf = pdf_4;
    (&_S1010)->origin = origin_5;
    (&_S1010)->smooth_n = smooth_n_3;
    (&_S1010)->start = start_6;
    return _S1010;
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
    Vertex _S1011;
    (&_S1011)->rough = rough_0;
    (&_S1011)->lobe = lobe_9;
    (&_S1011)->pdf = pdf_5;
    (&_S1011)->cos = cos_0;
    (&_S1011)->inside = inside_0;
    return _S1011;
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
    float3  _S1012 = exp_0((make_float3 (sigma_1) - extinction_0) * make_float3 (distance_2));
    float3  _S1013 = scatter_0 * _S1012 / make_float3 (sigma_1);
    float3  _S1014 = _slang_select(scatters_0, _S1013,_S1012);
    return _S1014;
}

static __device__ bool scatterSampled_0(bool replay_1, uint b_5, uint stop_0, bool varying_0)
{
    bool _S1015 = !replay_1;
    bool _S1016;
    if(_S1015)
    {
        _S1016 = true;
    }
    else
    {
        bool _S1017 = b_5 == stop_0;
        if(_S1017)
        {
            _S1016 = !varying_0;
        }
        else
        {
            _S1016 = false;
        }
    }
    return _S1016;
}

static __device__ uint arrivalLobe_0(uint b_6, uint prev_lobe_0)
{
    bool _S1018 = b_6 > 0U;
    uint _S1019 = _slang_select(_S1018, prev_lobe_0,3U);
    return _S1019;
}

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_0, uint depth_1, uint lobe_10, bool surface_4, float length_2, float width_1, FKHit * own_0, bool fiber_0)
{
    ShadowContext _S1020;
    (&_S1020)->extinction_behind = extinction_behind_0;
    (&_S1020)->extinction_front = extinction_front_0;
    (&_S1020)->fillings = fillings_0;
    (&_S1020)->side = side_0;
    (&_S1020)->depth = depth_1;
    (&_S1020)->lobe = lobe_10;
    (&_S1020)->surface = surface_4;
    (&_S1020)->length = length_2;
    (&_S1020)->width = width_1;
    (&_S1020)->own = *own_0;
    (&_S1020)->fiber = fiber_0;
    return _S1020;
}

static __device__ float phaseHG_0(float g_0, float mu_2)
{
    bool _S1021 = (F32_abs((g_0))) < 0.00100000004749745f;
    if(_S1021)
    {
        return 0.07957746833562851f;
    }
    float _S1022 = g_0 * g_0;
    return (1.0f - _S1022) * 0.25f * 0.31830987334251404f / (F32_pow((1.0f + _S1022 - 2.0f * g_0 * mu_2), (1.5f)));
}

__device__ float3  safeDivide(float3  a_9, float3  b_7)
{
    float3  _S1023 = a_9 / b_7;
    float3  _S1024 = make_float3 (0.0f);
    bool3  _S1025 = b_7 == _S1024;
    float3  _S1026 = _slang_select(_S1025, _S1024,_S1023);
    return _S1026;
}

static __device__ uint insertBits_0(uint e_2, uint newbits_0, uint offset_1, uint count_6)
{
    uint _S1027 = (1U << count_6) - 1U;
    return (e_2 & (~(_S1027 << offset_1))) | ((newbits_0 & _S1027) << offset_1);
}

__device__ Reservoir withEnd(Reservoir r_11, uint end_type_0, uint end_0, float3  f_5)
{
    Reservoir candidate_2 = r_11;
    uint _S1028 = insertBits_0(r_11.path, end_0, 0U, 5U);
    uint _S1029 = insertBits_0(_S1028, end_type_0, 12U, 3U);
    (&candidate_2)->path = _S1029;
    (&candidate_2)->f = f_5;
    return candidate_2;
}

__device__ float survivalProbability(float3  throughput_1, float density_1)
{
    return (F32_min(((F32_max(((F32_max((throughput_1.x), ((F32_max((throughput_1.y), (throughput_1.z)))))) / density_1), (0.0f)))), (1.0f)));
}

static __device__ float3  isotropic_0(uint random_state_9)
{
    Random _S1030 = pcg(random_state_9);
    Random _S1031 = pcg(_S1030.state);
    float _S1032 = 1.0f - 2.0f * _S1030.value;
    float _S1033 = (F32_sqrt(((F32_max((1.0f - _S1032 * _S1032), (0.0f))))));
    float _S1034 = 6.28318548202514648f * _S1031.value;
    return make_float3 (_S1033 * (F32_cos((_S1034))), _S1033 * (F32_sin((_S1034))), _S1032);
}

static __device__ float3  samplePhase_0(float g_1, float3  dir_9, uint random_state_10, float * pdf_6)
{
    bool _S1035 = (F32_abs((g_1))) < 0.00100000004749745f;
    if(_S1035)
    {
        *pdf_6 = 0.07957746833562851f;
        float3  _S1036 = isotropic_0(random_state_10);
        return _S1036;
    }
    Random _S1037 = pcg(random_state_10);
    Random _S1038 = pcg(_S1037.state);
    float _S1039 = g_1 * g_1;
    float _S1040 = 2.0f * g_1;
    float _S1041 = (1.0f - _S1039) / (1.0f - g_1 + _S1040 * _S1037.value);
    float _S1042 = clamp_1((1.0f + _S1039 - _S1041 * _S1041) / _S1040, -1.0f, 1.0f);
    float _S1043 = (F32_sqrt(((F32_max((1.0f - _S1042 * _S1042), (0.0f))))));
    float _S1044 = 6.28318548202514648f * _S1038.value;
    float _S1045 = phaseHG_0(g_1, _S1042);
    *pdf_6 = _S1045;
    float3  _S1046 = tangentToWorld(make_float3 (_S1043 * (F32_cos((_S1044))), _S1042, _S1043 * (F32_sin((_S1044)))), dir_9);
    float3  _S1047 = ((((_S1046)) * make_float3(rnorm3df(((_S1046)).x, ((_S1046)).y, ((_S1046)).z))));
    return _S1047;
}

static __device__ Vertex scatteredVertex_0(bool is_inside_4)
{
    return Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_4);
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_0, float3  emissive_0, float roughness_0, float metallic_0, float transmission_0, float ior_0, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_2, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_2, float velvet_0, float3  toon_3)
{
    BSDFMaterial _S1048;
    (&_S1048)->albedo = albedo_0;
    (&_S1048)->emissive = emissive_0;
    (&_S1048)->roughness = roughness_0;
    (&_S1048)->metallic = metallic_0;
    (&_S1048)->transmission = transmission_0;
    (&_S1048)->ior = ior_0;
    (&_S1048)->absorption = absorption_0;
    (&_S1048)->specular_tint = specular_tint_0;
    (&_S1048)->specular_level = specular_level_0;
    (&_S1048)->translucent = translucent_0;
    (&_S1048)->sheen = sheen_2;
    (&_S1048)->sheen_roughness = sheen_roughness_0;
    (&_S1048)->anisotropy = anisotropy_0;
    (&_S1048)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S1048)->tangent = tangent_2;
    (&_S1048)->velvet = velvet_0;
    (&_S1048)->toon = toon_3;
    return _S1048;
}

static __device__ FKMedium Medium_x24init_0(float3  scatter_1, float3  extinction_1, float g_2)
{
    FKMedium _S1049;
    (&_S1049)->scatter = scatter_1;
    (&_S1049)->extinction = extinction_1;
    (&_S1049)->g = g_2;
    return _S1049;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_7, bool skip_0, uint random_state_11, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S1050;
    (&_S1050)->smooth_n = smooth_n_4;
    (&_S1050)->geometry_n = geometry_n_2;
    (&_S1050)->geometry_offset = geometry_offset_2;
    (&_S1050)->material = *material_7;
    (&_S1050)->skip = skip_0;
    (&_S1050)->random_state = random_state_11;
    (&_S1050)->coverage = coverage_0;
    (&_S1050)->encloses = encloses_0;
    (&_S1050)->volume = *volume_0;
    (&_S1050)->fills = fills_0;
    (&_S1050)->hair = hair_0;
    return _S1050;
}

static __device__ FKSurface emitting_0(FKSurface * surface_5, bool top_0)
{
    FKSurface lower_0 = *surface_5;
    float3  _S1051 = (&surface_5->material)->emissive;
    float3  _S1052 = make_float3 (0.0f);
    bool _S1053 = !top_0;
    float3  _S1054 = _slang_select(_S1053, _S1052,_S1051);
    (&(&lower_0)->material)->emissive = _S1054;
    return lower_0;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_6, float u_2)
{
    float _S1055 = surface_6->coverage;
    bool _S1056 = u_2 < _S1055;
    if(_S1056)
    {
        return *surface_6;
    }
    float3  _S1057 = make_float3 (0.0f);
    float3  _S1058 = make_float3 (1.0f);
    BSDFMaterial _S1059 = Material_x24init_0(_S1057, _S1057, 0.0f, 0.0f, 0.0f, 0.0f, _S1057, _S1058, 1.0f, _S1057, _S1057, 0.5f, 0.0f, 0.0f, _S1057, 0.0f, _S1057);
    BSDFMaterial material_8 = _S1059;
    (&material_8)->albedo = _S1058;
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
    bool _S1060 = transmission_1 > 0.0f;
    bool _S1061;
    if(_S1060)
    {
        _S1061 = true;
    }
    else
    {
        _S1061 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S1062;
    if(_S1061)
    {
        _S1062 = 1.0f;
    }
    else
    {
        _S1062 = -1.0f;
    }
    return _S1062;
}

static __device__ bool arrivesBehind_0(float3  dir_10, float3  n_12)
{
    return (dot_0(dir_10, n_12)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_7, float3  dir_11)
{
    float3  _S1063 = surface_7->geometry_n;
    float _S1064 = facingSign((&surface_7->material)->transmission, surface_7->geometry_n, dir_11);
    FKSurface faced_0 = *surface_7;
    float3  _S1065 = surface_7->smooth_n * make_float3 (_S1064);
    (&faced_0)->smooth_n = _S1065;
    float3  _S1066 = _S1063 * make_float3 (_S1064);
    (&faced_0)->geometry_n = _S1066;
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
    float3  _S1067 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_3) * log_0(_S1067));
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
    bool _S1068;
    if(open_0)
    {
        _S1068 = prev_rough_0;
    }
    else
    {
        _S1068 = false;
    }
    if(_S1068)
    {
        _S1068 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S1068 = false;
    }
    return _S1068;
}

static __device__ float2  vertexEta_0(BSDFMaterial * material_9, float n_dot_v_0)
{
    bool _S1069 = n_dot_v_0 < 0.0f;
    float _S1070 = material_9->ior;
    float _S1071 = _slang_select(_S1069, _S1070,1.0f);
    float _S1072 = _slang_select(_S1069, 1.0f,_S1070);
    return make_float2 (_S1071, _S1072);
}

__device__ bool samplesLights(BSDFMaterial material_10)
{
    bool _S1073 = (material_10.roughness) > 0.0f;
    bool _S1074;
    if(_S1073)
    {
        _S1074 = true;
    }
    else
    {
        bool _S1075 = (material_10.metallic) < 1.0f;
        if(_S1075)
        {
            _S1074 = (material_10.transmission) < 1.0f;
        }
        else
        {
            _S1074 = false;
        }
    }
    return _S1074;
}

static __device__ bool isTranslucent_0(BSDFMaterial * material_11)
{
    float _S1076 = rgb_to_greyscale(material_11->translucent);
    return _S1076 > 0.0f;
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
    MediumSides _S1077;
    (&_S1077)->behind = *behind_0;
    (&_S1077)->front = *front_0;
    (&_S1077)->fillings = fillings_1;
    (&_S1077)->face = face_1;
    return _S1077;
}

static __device__ MediumSides mediumSides_0(FKSurface * surface_8, FKMedium * medium_0, uint filling_0, float3  dir_12, FKMedium * outside_0)
{
    float3  _S1078 = surface_8->geometry_n;
    MediumSides _S1079 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_8->geometry_n);
    MediumSides sides_0 = _S1079;
    bool _S1080 = surface_8->encloses;
    if(_S1080)
    {
        (&sides_0)->behind = surface_8->volume;
        *&((&(&sides_0)->fillings)->x) = surface_8->fills;
        bool _S1081 = (dot_0(dir_12, _S1078)) > 0.0f;
        if(_S1081)
        {
            (&sides_0)->front = *outside_0;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_9, bool turned_0, float3  extinction_2, uint filling_1, float3  dir_13, uint depth_2, uint lobe_11, float length_3, float width_2, FKHit * own_1, bool fiber_1, FKMedium * outside_1)
{
    float3  _S1082 = surface_9->geometry_n;
    ShadowContext _S1083 = ShadowContext_x24init_0(extinction_2, extinction_2, make_uint2 (filling_1), surface_9->geometry_n, depth_2, lobe_11, true, length_3, width_2, own_1, fiber_1);
    bool _S1084 = surface_9->encloses;
    ShadowContext context_4;
    if(_S1084)
    {
        FKSurface faced_1 = *surface_9;
        float3  _S1085 = - _S1082;
        float3  _S1086 = _slang_select(turned_0, _S1085,_S1082);
        (&faced_1)->geometry_n = _S1086;
        FKMedium _S1087 = Medium_x24init_0(make_float3 (0.0f), extinction_2, 0.0f);
        FKSurface _S1088 = faced_1;
        FKMedium _S1089 = _S1087;
        MediumSides _S1090 = mediumSides_0(&_S1088, &_S1089, filling_1, dir_13, outside_1);
        ShadowContext _S1091 = ShadowContext_x24init_0(_S1090.behind.extinction, _S1090.front.extinction, _S1090.fillings, _S1082, depth_2, lobe_11, true, length_3, width_2, own_1, fiber_1);
        if(turned_0)
        {
            uint2  _S1092 = _S1090.fillings;
            ShadowContext _S1093 = ShadowContext_x24init_0(_S1090.front.extinction, _S1090.behind.extinction, uint2 {_S1092.y, _S1092.x}, _S1082, depth_2, lobe_11, true, length_3, width_2, own_1, fiber_1);
            context_4 = _S1093;
        }
        else
        {
            context_4 = _S1091;
        }
    }
    else
    {
        context_4 = _S1083;
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
    float3  _S1094 = negate_0(in_dir_5);
    bool _S1095 = (dot_0(g_n_0, _S1094) * dot_0(g_n_0, out_dir_1)) > 0.0f;
    if(_S1095)
    {
        SampleBSDF _S1096 = connectBSDF(in_dir_5, out_dir_1, n_13, material_12, eta_i_5, eta_o_5, 0U, random_state_12);
        SampleBSDF _S1097 = connectBSDF(in_dir_5, out_dir_1, n_13, material_12, eta_i_5, eta_o_5, 2U, random_state_12);
        return _S1096.throughput * make_float3 (_S1096.pdf) + _S1097.throughput * make_float3 (_S1097.pdf);
    }
    SampleBSDF _S1098 = connectBSDF(in_dir_5, out_dir_1, n_13, material_12, eta_i_5, eta_o_5, 1U, random_state_12);
    return _S1098.throughput * make_float3 (_S1098.pdf);
}

__device__ float3  translucentCorrection(float3  in_dir_6, float3  out_dir_2, float3  n_14, float3  g_n_1, BSDFMaterial material_13, float eta_i_6, float eta_o_6, uint random_state_13)
{
    float _S1099 = dot_0(n_14, out_dir_2);
    float3  _S1100 = negate_0(in_dir_6);
    bool _S1101 = (_S1099 * dot_0(n_14, _S1100)) < 0.0f;
    SampleBSDF _S1102 = connectBSDF(in_dir_6, out_dir_2, n_14, material_13, eta_i_6, eta_o_6, 0U, random_state_13);
    float3  _S1103 = negate_0(in_dir_6);
    bool _S1104 = (dot_0(g_n_1, _S1103) * dot_0(g_n_1, out_dir_2)) > 0.0f;
    float3  _S1105 = make_float3 (0.0f);
    float3  _S1106 = _S1102.throughput * make_float3 (_S1102.pdf);
    float _S1107 = _slang_select(_S1104, -1.0f,1.0f);
    float3  _S1108 = _S1106 * make_float3 (_S1107);
    float3  _S1109 = _slang_select(_S1101, _S1108,_S1105);
    return _S1109;
}

__device__ float3  translucentBSDF(float3  in_dir_7, float3  out_dir_3, float3  n_15, float3  g_n_2, BSDFMaterial material_14, float eta_i_7, float eta_o_7, uint random_state_14)
{
    float3  _S1110 = BSDF(in_dir_7, out_dir_3, n_15, g_n_2, material_14, eta_i_7, eta_o_7, random_state_14);
    float3  _S1111 = translucentCorrection(in_dir_7, out_dir_3, n_15, g_n_2, material_14, eta_i_7, eta_o_7, random_state_14);
    return _S1110 + _S1111;
}

static __device__ __forceinline__ float3  lightBSDF_0(float3  in_dir_8, TreeSample * light_2, float3  smooth_n_5, float3  geometry_n_4, BSDFMaterial * material_15, float eta_i_8, float eta_o_8, bool competing_1, uint random_state_15)
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
            float3  _S1115 = translucentBSDF(in_dir_8, light_2->dir, smooth_n_5, geometry_n_4, *material_15, eta_i_8, eta_o_8, random_state_15);
            return _S1115 * light_2->radiance;
        }
        float3  _S1116 = BSDF(in_dir_8, light_2->dir, smooth_n_5, geometry_n_4, *material_15, eta_i_8, eta_o_8, random_state_15);
        return _S1116 * light_2->radiance;
    }
    float3  _S1117 = light_2->dir;
    bool _S1118 = (dot_0(geometry_n_4, - in_dir_8) * dot_0(geometry_n_4, light_2->dir)) <= 0.0f;
    float3  _S1119 = neeBSDF(in_dir_8, _S1117, smooth_n_5, *material_15, eta_i_8, eta_o_8, _S1118, light_2->density, true, random_state_15);
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

static __device__ float toonInvert_0(float target_4, ToonLobe_0 * lobe_12)
{
    bool _S1125 = lobe_12->glossy_0;
    float t_23;
    if(lobe_12->glossy_0)
    {
        t_23 = (F32_acos((clamp_1(1.0f - target_4, -1.0f, 1.0f))));
    }
    else
    {
        t_23 = (F32_asin(((F32_min(((F32_sqrt((2.0f * target_4)))), (1.0f))))));
    }
    float _S1126 = lobe_12->a_5;
    if(t_23 < (lobe_12->a_5))
    {
    }
    else
    {
        t_23 = (_S1126 + lobe_12->b_1) / 2.0f;
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
        float _S1127 = toonProfile_0(t_23, lobe_12);
        float _S1128 = _S1127 * (F32_sin((t_23)));
        float _S1129;
        if(_S1125)
        {
            _S1129 = 1.0f;
        }
        else
        {
            _S1129 = (F32_cos((t_23)));
        }
        float _S1130 = _S1128 * _S1129;
        float _S1131 = toonIntegral_0(t_23, lobe_12);
        float _S1132 = (_S1131 - target_4) / _S1130;
        bool _S1133 = _S1130 > 0.0f;
        float _S1134 = _slang_select(_S1133, _S1132,0.0f);
        float _S1135 = clamp_1(t_23 - _S1134, 0.0f, lobe_12->b_1);
        int k_1 = k_0 + int(1);
        t_23 = _S1135;
        k_0 = k_1;
    }
    return t_23;
}

__device__ float3  sampleToon(float3  v_9, float3  n_16, float3  toon_4, float u_1_0, float u_2_0)
{
    ToonLobe_0 _S1136 = toonLobe_0(toon_4);
    ToonLobe_0 _S1137 = _S1136;
    float _S1138 = toonIntegral_0(_S1136.b_1, &_S1137);
    float _S1139 = u_1_0 * _S1138;
    ToonLobe_0 _S1140 = _S1136;
    float _S1141 = toonInvert_0(_S1139, &_S1140);
    float _S1142 = 6.28318548202514648f * u_2_0;
    float3  _S1143;
    if(_S1136.glossy_0)
    {
        float3  _S1144 = make_float3 (2.0f * dot_0(n_16, v_9)) * n_16 - v_9;
        float3  _S1145 = ((((_S1144)) * make_float3(rnorm3df(((_S1144)).x, ((_S1144)).y, ((_S1144)).z))));
        _S1143 = _S1145;
    }
    else
    {
        _S1143 = n_16;
    }
    float _S1146 = (F32_sin((_S1141)));
    float3  _S1147 = tangentToWorld(make_float3 (_S1146 * (F32_cos((_S1142))), (F32_cos((_S1141))), _S1146 * (F32_sin((_S1142)))), _S1143);
    return _S1147;
}

static __device__ float3  reflect_0(float3  i_17, float3  n_17)
{
    return i_17 - make_float3 (2.0f * dot_0(n_17, i_17)) * n_17;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_9, float3  n_18, BSDFMaterial material_16, float eta_i_9, float eta_o_9, uint random_init_1, float2  screen_space_0)
{
    uint random_state_16 = random_init_1;
    float3  _S1148 = negate_0(in_dir_9);
    float _S1149 = dot_0(n_18, _S1148);
    float _S1150 = sign_0(_S1149);
    float3  n_i_5 = n_18 * make_float3 (_S1150);
    float _S1151 = (F32_abs((_S1149)));
    float _S1152 = material_16.roughness;
    float _S1153 = _S1152 * _S1152;
    AnisotropicFrame _S1154 = anisotropicFrame(material_16, n_i_5);
    float3  _S1155 = sampleHalfVector(_S1148, n_i_5, _S1153, _S1154, &random_state_16);
    BSDFLobes _S1156 = bsdfLobes(in_dir_9, _S1148, n_i_5, _S1155, material_16, eta_i_9, eta_o_9, _S1154);
    BSDFLobes lobes_4 = _S1156;
    float _S1157 = translucentShare(material_16);
    (&lobes_4)->translucent_share = _S1157;
    float3  _S1158 = make_float3 (1.0f);
    SampleBSDF _S1159 = SampleBSDF_x24init_0(_S1158, _S1158, 0U, false, 0U, 0.0f);
    SampleBSDF sample_2 = _S1159;
    Random _S1160 = pcg(random_state_16);
    random_state_16 = _S1160.state;
    bool _S1161 = (_S1160.value) < ((&lobes_4)->p_diffuse);
    if(_S1161)
    {
        Random _S1162 = pcg(random_state_16);
        Random _S1163 = pcg(_S1162.state);
        (&sample_2)->random_state = _S1163.state;
        float3  _S1164 = sampleCosWeightedHemisphere(_S1162.value, _S1163.value);
        bool _S1165 = ((&lobes_4)->toon_share) > 0.0f;
        if(_S1165)
        {
            bool _S1166 = (_S1160.value) >= ((&lobes_4)->p_diffuse * (1.0f - (&lobes_4)->toon_share));
            bool _S1167 = (_S1160.value) < ((&lobes_4)->p_diffuse * (1.0f - (&lobes_4)->toon_share) * (&lobes_4)->translucent_share);
            float _S1168 = _S1164.y;
            float _S1169 = - _S1168;
            float _S1170 = _slang_select(_S1167, _S1169,_S1168);
            float3  _S1171;
            if(_S1166)
            {
                float3  _S1172 = sampleToon(_S1148, n_i_5, material_16.toon, _S1162.value, _S1163.value);
                _S1171 = _S1172;
            }
            else
            {
                float3  _S1173 = tangentToWorld(make_float3 (_S1164.x, _S1170, _S1164.z), n_i_5);
                _S1171 = _S1173;
            }
            (&sample_2)->unit_direction = _S1171;
            float3  _S1174 = lobeThroughput((&sample_2)->unit_direction, n_i_5, _S1153, material_16, lobes_4, 0U);
            (&sample_2)->throughput = _S1174;
            float _S1175 = lobeDensity(dot_0(n_i_5, (&sample_2)->unit_direction), 0.0f, _S1151, _S1153, lobes_4, eta_i_9, eta_o_9, 0U);
            (&sample_2)->pdf = _S1175;
            bool _S1176 = (dot_0(n_i_5, (&sample_2)->unit_direction)) < 0.0f;
            (&sample_2)->refracted = _S1176;
            BSDFMaterial _S1177 = material_16;
            BSDFLobes _S1178 = lobes_4;
            toonMix_0(&sample_2, _S1148, n_i_5, &_S1177, &_S1178);
            return sample_2;
        }
        bool _S1179 = (_S1160.value) < ((&lobes_4)->p_diffuse * (&lobes_4)->translucent_share);
        float _S1180 = _S1164.y;
        float _S1181 = - _S1180;
        float _S1182 = _slang_select(_S1179, _S1181,_S1180);
        float3  _S1183 = tangentToWorld(make_float3 (_S1164.x, _S1182, _S1164.z), n_i_5);
        (&sample_2)->unit_direction = _S1183;
        float3  _S1184 = lobeThroughput((&sample_2)->unit_direction, n_i_5, _S1153, material_16, lobes_4, 0U);
        (&sample_2)->throughput = _S1184;
        float _S1185 = lobeDensity(_S1182, 0.0f, _S1151, _S1153, lobes_4, eta_i_9, eta_o_9, 0U);
        (&sample_2)->pdf = _S1185;
        (&sample_2)->refracted = _S1179;
        return sample_2;
    }
    bool _S1186 = (_S1160.value) < ((&lobes_4)->p_diffuse + (&lobes_4)->p_refract);
    if(_S1186)
    {
        (&sample_2)->unit_direction = (&lobes_4)->refracted;
        float _S1187 = lobeDensity(0.0f, dot_0((&sample_2)->unit_direction, _S1155), _S1151, _S1153, lobes_4, eta_i_9, eta_o_9, 1U);
        (&sample_2)->pdf = _S1187;
        float3  _S1188 = lobeThroughput((&sample_2)->unit_direction, n_i_5, _S1153, material_16, lobes_4, 1U);
        (&sample_2)->throughput = _S1188;
        (&sample_2)->random_state = random_state_16;
        (&sample_2)->refracted = true;
        (&sample_2)->lobe = 1U;
        return sample_2;
    }
    float3  _S1189 = reflect_0(in_dir_9, _S1155);
    float3  _S1190 = ((((_S1189)) * make_float3(rnorm3df(((_S1189)).x, ((_S1189)).y, ((_S1189)).z))));
    (&sample_2)->unit_direction = _S1190;
    float3  _S1191 = lobeThroughput((&sample_2)->unit_direction, n_i_5, _S1153, material_16, lobes_4, 2U);
    (&sample_2)->throughput = _S1191;
    (&sample_2)->random_state = random_state_16;
    (&sample_2)->lobe = 2U;
    float _S1192 = lobeDensity(0.0f, 0.0f, _S1151, _S1153, lobes_4, eta_i_9, eta_o_9, 2U);
    (&sample_2)->pdf = _S1192;
    return sample_2;
}

__device__ bool withinInverseFootprint(float pdf_7, bool diffuse_0, float prev_cos_0, float distance_5, float threshold_1)
{
    bool _S1193 = pdf_7 > 0.0f;
    bool _S1194;
    if(_S1193)
    {
        if(diffuse_0)
        {
            _S1194 = true;
        }
        else
        {
            _S1194 = (pdf_7 * prev_cos_0 / (distance_5 * distance_5) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S1194 = false;
    }
    return _S1194;
}

__device__ bool roughLobe(float pdf_8, bool diffuse_1, float roughness_1)
{
    bool _S1195 = pdf_8 > 0.0f;
    bool _S1196;
    if(_S1195)
    {
        if(diffuse_1)
        {
            _S1196 = true;
        }
        else
        {
            _S1196 = roughness_1 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S1196 = false;
    }
    return _S1196;
}

static __device__ bool passesLayer_0(uint layers_0, bool refracting_0, bool passed_0)
{
    bool _S1197 = layers_0 > 1U;
    bool _S1198;
    if(_S1197)
    {
        _S1198 = refracting_0 != passed_0;
    }
    else
    {
        _S1198 = false;
    }
    return _S1198;
}

static __device__ float widened_0(float spread_1, float pdf_9, bool delta_0)
{
    float _S1199 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * pdf_9))))), (3.14159274101257324f)));
    bool _S1200 = !delta_0;
    float _S1201 = _slang_select(_S1200, _S1199,0.0f);
    return spread_1 + _S1201;
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
    int _S1202;
    Shift ended_0;
    float density_3;
    float spread_3;
    float width_4;
    float sky_pdf_1;
    float spread_4;
    float width_5;
    uint b_9;
    float3  _S1203 = make_float3 (0.0f);
    Shift _S1204 = Shift_x24init_0(_S1203, 0.0f);
    uint _S1205 = r_12->path;
    uint _S1206 = extractBits_0(r_12->path, 0U, 5U);
    uint _S1207 = extractBits_0(_S1205, 5U, 5U);
    uint _S1208 = extractBits_0(_S1205, 10U, 2U);
    uint _S1209 = extractBits_0(_S1205, 12U, 3U);
    bool passes_0;
    if(replay_2)
    {
        bool _S1210 = _S1209 >= 3U;
        uint _S1211 = _slang_select(_S1210, 1U,0U);
        uint _S1212 = _S1206 + _S1211;
        uint _S1213 = (fcptMaxBounces());
        passes_0 = _S1212 > _S1213;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S1204;
    }
    uint _S1214 = _S1207 - 1U;
    bool _S1215 = _S1209 == 3U;
    uint _S1216 = _slang_select(_S1215, 1U,0U);
    uint _S1217 = _S1206 + _S1216;
    bool _S1218 = _S1208 == 0U;
    uint _S1219 = _slang_select(_S1218, _S1217,_S1214);
    FKHit _S1220 = (fcptReservoirHit((*r_12)));
    float3  _S1221 = dom_7->x0;
    float3  _S1222 = dom_7->x1 - dom_7->x0;
    float3  _S1223 = ((((_S1222)) * make_float3(rnorm3df(((_S1222)).x, ((_S1222)).y, ((_S1222)).z))));
    FKRay _S1224 = Ray_x24init_0(dom_7->x1, _S1223);
    FKRay ray_2 = _S1224;
    FKHit hit_4 = dom_7->hit;
    float3  scatter_in_0 = _S1203;
    float3  throughput_3 = make_float3 (1.0f);
    float3  weight_1 = throughput_3;
    float3  glowed_0 = _S1203;
    float3  extinction_in_0 = _S1203;
    float g_in_0 = 0.0f;
    uint filling_2 = 4294967295U;
    float _S1225 = dom_7->spread;
    float _S1226 = dom_7->width;
    float _S1227 = length_0(_S1222);
    NEEVertex _S1228 = NEEVertex_x24init_0(true, 0.0f, _S1203, _S1203, _S1203);
    NEEVertex nee_vertex_0 = _S1228;
    Vertex _S1229 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_0 = _S1229;
    Reservoir _S1230 = (Reservoir{});
    Reservoir chain_0 = _S1230;
    uint _S1231 = r_12->seed;
    (&chain_0)->seed = r_12->seed;
    (&ray_2)->origin = _S1221;
    (&hit_4)->distance = _S1227;
    FKMedium _S1232 = (fcptCameraMedium(((&ray_2)->unit_direction), ((&hit_4)->distance), (&filling_2)));
    uint _S1233 = filling_2;
    bool _S1234 = (fcptVaryingUsed());
    uint _S1235 = _slang_select(_S1234, _S1233,4294967295U);
    filling_2 = _S1235;
    scatter_in_0 = _S1232.scatter;
    extinction_in_0 = _S1232.extinction;
    g_in_0 = _S1232.g;
    Reservoir _S1236 = chain_0;
    uint _S1237 = filling_2;
    for(;;)
    {
        bool _S1238 = (fcptVaryingUsed());
        if(_S1238)
        {
            passes_0 = _S1237 != 4294967295U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            float _S1239 = (fcptMajorant((_S1237)));
            spread_2 = _S1239;
        }
        else
        {
            spread_2 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
        }
        if(replay_2)
        {
            turned_1 = 4294967295U == _S1219;
        }
        else
        {
            turned_1 = false;
        }
        if(turned_1)
        {
            turned_1 = _S1208 == 1U;
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
            ended_0 = _S1204;
            sky_pdf_0 = 0.0f;
            spread_2 = _S1225;
            width_3 = _S1226;
            density_2 = 1.0f;
            throughput_2 = throughput_3;
            b_8 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S1240 = (&prev_0)->rough;
        if(_S1240)
        {
            turned_1 = !(spread_2 > 0.0f);
        }
        else
        {
            turned_1 = false;
        }
        (&prev_0)->rough = turned_1;
        uint _S1241 = stream(_S1231, 384U);
        uint tracking_0 = _S1241;
        weight_1 = throughput_3;
        glowed_0 = _S1203;
        b_8 = 4294967295U;
        throughput_2 = throughput_3;
        density_2 = 1.0f;
        threshold_2 = _S1225;
        width_3 = _S1226;
        sky_pdf_0 = 0.0f;
        for(;;)
        {
            if(((&hit_4)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S1202 = int(1);
                break;
            }
            uint _S1242 = b_8 + 320U;
            bool _S1243 = b_8 == 4294967295U;
            uint _S1244 = _slang_select(_S1243, 384U,_S1242);
            uint _S1245 = stream(_S1231, _S1244);
            Random _S1246 = pcg(_S1245);
            float _S1247 = freeFlight_0(_S1246.value, spread_2);
            if(passes_0)
            {
                float3  _S1248 = (&ray_2)->origin;
                float3  _S1249 = (&ray_2)->unit_direction;
                float _S1250 = (&hit_4)->distance;
                uint _S1251 = _slang_select(_S1243, 0U,b_8);
                uint _S1252 = (&prev_0)->lobe;
                uint _S1253 = _slang_select(_S1243, 3U,_S1252);
                float _S1254 = (fcptTrackMedium((_S1237), (_S1248), (_S1249), (_S1250), (&tracking_0), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1251), (_S1253), (_S1243)));
                geometry_density_2 = _S1254;
            }
            else
            {
                geometry_density_2 = _S1247;
            }
            bool _S1255 = !(geometry_density_2 < ((&hit_4)->distance));
            if(_S1255)
            {
                _S1202 = int(1);
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
                float3  _S1256 = throughput_2 * glowed_0 / make_float3 (density_2);
                float3  _S1257 = sel_7->glow + _S1256;
                sel_7->glow = _S1257;
            }
            else
            {
            }
            glowed_0 = _S1203;
            uint b_10 = b_8 + 1U;
            float3  _S1258 = (&ray_2)->origin + make_float3 (geometry_density_2) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S1258;
            float3  _S1259 = flightWeight_0(scatter_in_0, extinction_in_0, spread_2, geometry_density_2, true);
            float3  _S1260 = weight_1;
            float3  _S1261 = _slang_select(passes_0, _S1260,_S1259);
            float3  throughput_4 = throughput_2 * _S1261;
            uint _S1262 = stream(_S1231, b_10 + 320U);
            tracking_0 = _S1262;
            weight_1 = throughput_3;
            float width_6 = width_3 + threshold_2 * geometry_density_2;
            float _S1263 = threshold_2 + 3.14159274101257324f;
            bool _S1264 = scatterSampled_0(replay_2, b_10, _S1219, passes_0);
            TreeSample _S1265 = TreeSample_x24init_0(_S1203, _S1203, 0.0f, 0U);
            if(_S1264)
            {
                float3  _S1266 = (&ray_2)->origin;
                float3  _S1267 = (&ray_2)->unit_direction;
                float3  _S1268 = (&ray_2)->unit_direction;
                uint _S1269 = stream(_S1231, b_10 + 64U);
                float3  _S1270 = extinction_in_0;
                float3  _S1271 = extinction_in_0;
                uint2  _S1272 = make_uint2 (_S1237);
                float3  _S1273 = (&ray_2)->unit_direction;
                uint _S1274 = arrivalLobe_0(b_10, (&prev_0)->lobe);
                FKHit _S1275 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S1276 = _S1275;
                ShadowContext _S1277 = ShadowContext_x24init_0(_S1270, _S1271, _S1272, _S1273, b_10, _S1274, false, geometry_density_2, width_6, &_S1276, false);
                ShadowContext _S1278 = _S1277;
                TreeSample _S1279 = sampleLightTree_0(_S1266, _S1267, _S1268, 0.0f, true, _S1269, &_S1278);
                light_3 = _S1279;
            }
            else
            {
                light_3 = _S1265;
            }
            float _S1280 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_3.dir));
            uint _S1281 = (fcptMaxBounces());
            bool _S1282 = b_10 < _S1281;
            if(_S1282)
            {
                is_inside_5 = (light_3.density) > 0.0f;
            }
            else
            {
                is_inside_5 = false;
            }
            float _S1283 = _slang_select(is_inside_5, _S1280,0.0f);
            float3  _S1284 = throughput_4 * light_3.radiance;
            float _S1285 = powerHeuristic(light_3.density, _S1283);
            float3  _S1286 = _S1284 * make_float3 (_S1280 * _S1285);
            float3  _S1287 = _slang_select(_S1264, _S1286,_S1203);
            if(replay_2)
            {
                viewed_0 = b_10 == _S1219;
            }
            else
            {
                viewed_0 = false;
            }
            if(viewed_0)
            {
                bool _S1288 = _S1208 == 2U;
                if(_S1288)
                {
                    float _S1289 = rgb_to_greyscale(_S1287);
                    passes_0 = _S1289 > 0.0f;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S1290 = Shift_x24init_0(_S1287, 1.0f);
                    _S1202 = int(0);
                    ended_0 = _S1290;
                    spread_2 = _S1263;
                    geometry_density_2 = width_6;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_10;
                    break;
                }
                _S1202 = int(0);
                ended_0 = _S1204;
                spread_2 = _S1263;
                geometry_density_2 = width_6;
                chain_throughput_0 = throughput_4;
                layer_0 = b_10;
                break;
            }
            bool _S1291 = !replay_2;
            if(_S1291)
            {
                Reservoir candidate_3 = _S1236;
                uint _S1292 = extractBits_0(_S1236.path, 10U, 2U);
                bool _S1293 = _S1292 == 1U;
                if(_S1293)
                {
                    float3  _S1294 = safeDivide(_S1287, _S1203);
                    (&candidate_3)->radiance = _S1294;
                }
                else
                {
                    uint _S1295 = insertBits_0(0U, b_10 + 1U, 5U, 5U);
                    uint _S1296 = insertBits_0(_S1295, 2U, 10U, 2U);
                    (&candidate_3)->path = _S1296;
                }
                Reservoir _S1297 = withEnd(candidate_3, 0U, b_10, _S1287);
                offer(sel_7, _S1297, _S1287 * make_float3 (scale_3) / make_float3 (density_2));
                float _S1298 = survivalProbability(throughput_4, density_2);
                uint _S1299 = stream(_S1231, b_10 + 128U);
                Random _S1300 = pcg(_S1299);
                bool _S1301 = _S1298 < (_S1300.value);
                if(_S1301)
                {
                    scatter_2 = true;
                }
                else
                {
                    uint _S1302 = (fcptMaxBounces());
                    scatter_2 = b_10 >= _S1302;
                }
                if(scatter_2)
                {
                    _S1202 = int(0);
                    ended_0 = _S1204;
                    spread_2 = _S1263;
                    geometry_density_2 = width_6;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_10;
                    break;
                }
                float _S1303 = density_2 * _S1298;
                density_2 = _S1303;
            }
            else
            {
            }
            float phase_pdf_0 = 0.0f;
            uint _S1304 = stream(_S1231, b_10);
            float3  _S1305 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1304, &phase_pdf_0);
            (&ray_2)->unit_direction = _S1305;
            NEEVertex _S1306 = NEEVertex_x24init_0(false, phase_pdf_0, (&ray_2)->origin, _S1203, (&ray_2)->origin);
            nee_vertex_0 = _S1306;
            Vertex _S1307 = scatteredVertex_0(false);
            prev_0 = _S1307;
            float _S1308 = (&prev_0)->pdf;
            FKRay _S1309 = ray_2;
            FKHit _S1310 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S1311 = (fcptTraverseInstanceBVH((_S1309), (true), (4.294967296e+09f), (false), (_S1310), (false)));
            hit_4 = _S1311;
            b_8 = b_10;
            throughput_2 = throughput_4;
            threshold_2 = _S1263;
            width_3 = width_6;
            sky_pdf_0 = _S1308;
        }
        if(_S1202 != int(1))
        {
            width_3 = geometry_density_2;
            throughput_2 = chain_throughput_0;
            b_8 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S1204;
        spread_2 = threshold_2;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    bool _S1312 = b_8 == 4294967295U;
    bool _S1313 = ((&hit_4)->instance_index) == 4294967295U;
    if(_S1313)
    {
        bool _S1314 = !(&nee_vertex_0)->none;
        float _S1315 = _slang_select(_S1314, sky_pdf_0,0.0f);
        float _S1316 = escapeWeight_0(_S1315, (&ray_2)->unit_direction);
        float3  _S1317 = environment_0((&ray_2)->unit_direction, b_8, (&prev_0)->lobe);
        float3  _S1318 = throughput_2 * _S1317;
        if(replay_2)
        {
            bool _S1319 = b_8 == _S1219;
            if(_S1319)
            {
                passes_0 = _S1208 == 3U;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                return Shift_x24init_0(_S1318 * make_float3 (_S1316) / make_float3 (r_12->jac), density_2 / r_12->jac);
            }
            if(_S1218)
            {
                passes_0 = _S1215;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                passes_0 = b_8 == _S1206;
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
                return Shift_x24init_0(_S1318 * make_float3 (_S1316), 1.0f);
            }
            return _S1204;
        }
        Reservoir candidate_4 = chain_0;
        uint _S1320 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1321 = _S1320 == 1U;
        if(_S1321)
        {
            uint _S1322 = extractBits_0((&chain_0)->path, 5U, 5U);
            bool _S1323 = _S1322 == b_8;
            float _S1324 = _slang_select(_S1323, 1.0f,_S1316);
            float3  _S1325 = safeDivide(_S1318 * make_float3 (_S1324), _S1203);
            (&candidate_4)->radiance = _S1325;
        }
        else
        {
            bool _S1326 = (&prev_0)->rough;
            if(_S1326)
            {
                uint _S1327 = insertBits_0(0U, b_8 + 1U, 5U, 5U);
                uint _S1328 = insertBits_0(_S1327, 3U, 10U, 2U);
                uint _S1329 = insertBits_0(_S1328, (&prev_0)->lobe, 15U, 2U);
                bool _S1330 = (&prev_0)->inside;
                uint _S1331 = _slang_select(_S1330, 1U,0U);
                uint _S1332 = insertBits_0(_S1329, _S1331, 20U, 1U);
                (&candidate_4)->path = _S1332;
                (&candidate_4)->jac = (&prev_0)->pdf;
                (&candidate_4)->dir = (&ray_2)->unit_direction;
            }
        }
        float3  _S1333 = _S1318 * make_float3 (_S1316);
        Reservoir _S1334 = withEnd(candidate_4, 3U, b_8, _S1333);
        offer(sel_7, _S1334, _S1333 * make_float3 (scale_3) / make_float3 (density_2));
        return _S1204;
    }
    float3  _S1335 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
    (&ray_2)->origin = _S1335;
    bool _S1336 = (fcptVaryingUsed());
    if(_S1336)
    {
        passes_0 = filling_2 != 4294967295U;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        bool _S1337 = !replay_2;
        if(_S1337)
        {
            float3  _S1338 = throughput_2 * glowed_0 / make_float3 (density_2);
            float3  _S1339 = sel_7->glow + _S1338;
            sel_7->glow = _S1339;
        }
        float3  _S1340 = throughput_2 * weight_1;
        throughput_2 = _S1340;
    }
    else
    {
        float3  _S1341 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
        float3  _S1342 = throughput_2 * _S1341;
        throughput_2 = _S1342;
    }
    float _S1343 = width_3 + spread_2 * (&hit_4)->distance;
    uint _S1344 = b_8 + 1U;
    b_8 = _S1344;
    layer_0 = 0U;
    width_3 = _S1343;
    passes_0 = false;
    threshold_2 = 0.0f;
    turned_1 = false;
    is_inside_5 = false;
    chain_throughput_0 = _S1203;
    float3  reconnection_0 = _S1203;
    viewed_0 = _S1312;
    for(;;)
    {
        bool _S1345 = ((&hit_4)->is_point_light) == 1U;
        FKMedium _S1346 = Medium_x24init_0(_S1203, _S1203, 0.0f);
        BSDFMaterial _S1347 = Material_x24init_0(_S1203, _S1203, 0.0f, 0.0f, 0.0f, 0.0f, _S1203, throughput_3, 1.0f, _S1203, _S1203, 0.5f, 0.0f, 0.0f, _S1203, 0.0f, _S1203);
        FKMedium _S1348 = _S1346;
        FKSurface _S1349 = Surface_x24init_0(_S1203, _S1203, 0.0f, &_S1347, false, 0U, 1.0f, false, &_S1348, 4294967295U, _S1203);
        bool _S1350 = !_S1345;
        bool is_inside_6;
        float3  throughput_5;
        FKSurface surface_11;
        if(_S1350)
        {
            uint _S1351 = stream(_S1231, b_8);
            uint _S1352 = arrivalLobe_0(b_8, (&prev_0)->lobe);
            FKSurface _S1353 = (fcptSurfaceAtPath((hit_4), ((&ray_2)->origin), (_S1351), (width_3), (layer_0), (b_8), (_S1352), ((&ray_2)->unit_direction)));
            bool _S1354 = !passes_0;
            FKSurface _S1355 = _S1353;
            FKSurface _S1356 = emitting_0(&_S1355, _S1354);
            uint _S1357 = stream(_S1231, b_8 + 256U);
            Random _S1358 = pcg(_S1357);
            FKSurface _S1359 = _S1356;
            FKSurface _S1360 = uncovered_0(&_S1359, _S1358.value);
            float _S1361 = facingSign(_S1360.material.transmission, _S1360.geometry_n, (&ray_2)->unit_direction);
            bool _S1362 = _S1361 < 0.0f;
            bool _S1363 = (_S1360.material.transmission) > 0.0f;
            if(_S1363)
            {
                bool _S1364 = arrivesBehind_0((&ray_2)->unit_direction, _S1360.geometry_n);
                scatter_2 = _S1364;
            }
            else
            {
                scatter_2 = false;
            }
            FKSurface _S1365 = _S1360;
            FKSurface _S1366 = facingRay_0(&_S1365, (&ray_2)->unit_direction);
            if(passes_0)
            {
                bool _S1367 = arrivesBehind_0((&ray_2)->unit_direction, _S1366.geometry_n);
                is_inside_6 = _S1367;
            }
            else
            {
                is_inside_6 = scatter_2;
            }
            if(is_inside_6)
            {
                float3  _S1368 = beerLambert((&hit_4)->distance, _S1366.material.absorption);
                float3  _S1369 = throughput_2 * _S1368;
                throughput_5 = _S1369;
            }
            else
            {
                throughput_5 = throughput_2;
            }
            bool _S1370 = !_S1366.skip;
            float geometry_density_3 = geometryDensity(_S1366.geometry_n, (&ray_2)->unit_direction, (&hit_4)->distance);
            bool _S1371 = b_8 == _S1344;
            if(_S1371)
            {
                float _S1372 = footprintThreshold(geometry_density_3);
                geometry_density_2 = _S1372;
            }
            else
            {
                geometry_density_2 = threshold_2;
            }
            float _S1373 = geometry_density_2;
            scatter_2 = _S1370;
            geometry_density_2 = geometry_density_3;
            threshold_2 = _S1373;
            surface_11 = _S1366;
            turned_1 = _S1362;
        }
        else
        {
            scatter_2 = false;
            geometry_density_2 = 0.0f;
            surface_11 = _S1349;
            throughput_5 = throughput_2;
            is_inside_6 = is_inside_5;
        }
        bool _S1374 = withinFootprint(scatter_2, (&prev_0)->rough, (&prev_0)->pdf, geometry_density_2, threshold_2);
        FKSurface _S1375 = surface_11;
        FKSurface _S1376 = surface_11;
        float _S1377 = dot_0(surface_11.smooth_n, - (&ray_2)->unit_direction);
        BSDFMaterial _S1378 = _S1375.material;
        float2  _S1379 = vertexEta_0(&_S1378, _S1377);
        bool _S1380;
        if(scatter_2)
        {
            bool _S1381 = samplesLights(_S1375.material);
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
            BSDFMaterial _S1387 = _S1375.material;
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
            bool _S1390 = (_S1375.material.transmission) > 0.0f;
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
        if(_S1345)
        {
            float3  _S1392 = (fcptCalculatePointLightContrib(((&hit_4)->instance_index)));
            emission_0 = _S1392;
        }
        else
        {
            emission_0 = _S1375.material.emissive;
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
            _S1398 = _S1208 == 1U;
        }
        else
        {
            _S1398 = false;
        }
        bool _S1399;
        if(_S1398)
        {
            _S1399 = b_8 > _S1207;
        }
        else
        {
            _S1399 = false;
        }
        bool _S1400;
        if(_S1399)
        {
            _S1400 = b_8 == _S1206;
        }
        else
        {
            _S1400 = false;
        }
        bool _S1401;
        if(_S1400)
        {
            bool _S1402 = _S1209 == 1U;
            if(_S1402)
            {
                _S1401 = true;
            }
            else
            {
                _S1401 = _S1209 == 2U;
            }
        }
        else
        {
            _S1401 = false;
        }
        if(_S1401)
        {
            bool _S1403 = _S1345 != (_S1209 == 2U);
            if(_S1403)
            {
                return _S1204;
            }
            return Shift_x24init_0(throughput_5 * emission_1 / make_float3 (r_12->jac), density_2 / r_12->jac);
        }
        uint _S1404 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1405 = _S1404 == 1U;
        Reservoir here_0 = chain_0;
        uint _S1406 = insertBits_0(0U, b_8, 5U, 5U);
        uint _S1407 = insertBits_0(_S1406, 1U, 10U, 2U);
        uint _S1408 = insertBits_0(_S1407, (&prev_0)->lobe, 15U, 2U);
        bool _S1409 = (&prev_0)->inside;
        uint _S1410 = _slang_select(_S1409, 1U,0U);
        uint _S1411 = insertBits_0(_S1408, _S1410, 20U, 1U);
        (&here_0)->path = _S1411;
        float _S1412 = (&prev_0)->pdf * geometry_density_2;
        (&here_0)->jac = _S1412;
        fcptWithReservoirHit((&here_0), (&hit_4));
        bool _S1413;
        if(replay_2)
        {
            _S1413 = _S1208 == 1U;
        }
        else
        {
            _S1413 = false;
        }
        bool _S1414;
        if(_S1413)
        {
            _S1414 = b_8 == _S1207;
        }
        else
        {
            _S1414 = false;
        }
        bool _S1415 = b_8 == _S1219;
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
                bool _S1418 = _S1208 != 1U;
                if(_S1418)
                {
                    _S1416 = _S1208 != 3U;
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
            _S1419 = _S1208 == 2U;
        }
        else
        {
            _S1419 = false;
        }
        bool _S1420;
        if(_S1419)
        {
            _S1420 = !_S1374;
        }
        else
        {
            _S1420 = false;
        }
        bool _S1421;
        if(_S1420)
        {
            _S1421 = _S1209 != 4U;
        }
        else
        {
            _S1421 = false;
        }
        bool _S1422 = _S1207 == _S1206;
        bool _S1423;
        if(_S1422)
        {
            _S1423 = _S1209 == 0U;
        }
        else
        {
            _S1423 = false;
        }
        bool _S1424;
        if(_S1423)
        {
            _S1424 = ((&hit_4)->instance_index) == (_S1220.instance_index);
        }
        else
        {
            _S1424 = false;
        }
        bool _S1425;
        if(_S1424)
        {
            _S1425 = ((&hit_4)->triangle_index) == (_S1220.triangle_index);
        }
        else
        {
            _S1425 = false;
        }
        bool _S1426;
        if(_S1425)
        {
            _S1426 = _S1374;
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
        TreeSample _S1429 = TreeSample_x24init_0(_S1203, _S1203, 0.0f, 0U);
        uint2  _S1430 = make_uint2 (0U);
        float2  _S1431 = make_float2 (0.0f);
        FKHit _S1432 = Hit_x24init_0(_S1431, 4294967295U, 0U, 0U, 0.0f);
        FKHit _S1433 = _S1432;
        ShadowContext _S1434 = ShadowContext_x24init_0(_S1203, _S1203, _S1430, _S1203, 0U, 0U, false, 0.0f, 0.0f, &_S1433, false);
        ShadowContext context_5;
        if(nee_0)
        {
            uint _S1435 = arrivalLobe_0(b_8, (&prev_0)->lobe);
            FKMedium _S1436 = (fcptOutsideMedium((hit_4)));
            FKSurface _S1437 = surface_11;
            FKHit _S1438 = hit_4;
            FKMedium _S1439 = _S1436;
            ShadowContext _S1440 = shadowContext_0(&_S1437, turned_1, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_8, _S1435, (&hit_4)->distance, width_3, &_S1438, _S1384, &_S1439);
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
                throughput_6 = _S1203;
            }
            else
            {
                throughput_6 = _S1376.smooth_n;
            }
            FKSurface _S1442 = surface_11;
            uint _S1443 = stream(_S1231, b_8 + 64U);
            ShadowContext _S1444 = context_5;
            TreeSample _S1445 = sampleLightTree_0(_S1441, throughput_6, surface_11.geometry_n, surface_11.geometry_offset, _S1389, _S1443, &_S1444);
            bool _S1446 = any_1((_S1445.radiance) != _S1203);
            if(_S1446)
            {
                if(_S1384)
                {
                    uint _S1447 = (fcptMaxBounces());
                    bool _S1448 = b_8 < _S1447;
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
                    bool _S1455 = b_8 < _S1454;
                    TreeSample _S1456 = _S1445;
                    BSDFMaterial _S1457 = _S1375.material;
                    float3  _S1458 = lightBSDF_0((&ray_2)->unit_direction, &_S1456, _S1376.smooth_n, _S1442.geometry_n, &_S1457, _S1452, _S1453, _S1455, surface_11.random_state);
                    lit_0 = _S1458;
                }
            }
            else
            {
                lit_0 = _S1203;
            }
            light_3 = _S1445;
        }
        else
        {
            light_3 = _S1429;
            lit_0 = _S1203;
        }
        bool viewed_1;
        bool refracted_4;
        bool wrong_side_0;
        bool _S1459;
        bool _S1460;
        float density_4;
        if(_S1414)
        {
            bool _S1461 = ((&hit_4)->instance_index) != (_S1220.instance_index);
            if(_S1461)
            {
                viewed_1 = true;
            }
            else
            {
                viewed_1 = ((&hit_4)->triangle_index) != (_S1220.triangle_index);
            }
            if(viewed_1)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = !_S1374;
            }
            if(refracted_4)
            {
                return _S1204;
            }
            float3  throughput_7 = throughput_5 * make_float3 (geometry_density_2);
            float density_5 = density_2 * geometry_density_2;
            if(_S1422)
            {
                wrong_side_0 = _S1209 == 1U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                return Shift_x24init_0(throughput_7 * emission_1 / make_float3 (r_12->jac), density_5 / r_12->jac);
            }
            if(_S1422)
            {
                _S1459 = _S1209 == 0U;
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
                    return _S1204;
                }
                return Shift_x24init_0(throughput_7 * lit_0 / make_float3 (r_12->jac), density_5 / r_12->jac);
            }
            if(_S1422)
            {
                _S1460 = _S1209 == 4U;
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
                    return _S1204;
                }
                float _S1465 = environmentPdf_0(r_12->dir);
                float3  _S1466 = skyBSDF((&ray_2)->unit_direction, r_12->dir, surface_11, _S1379, is_inside_6, _S1465, surface_11.random_state);
                return Shift_x24init_0(throughput_7 * _S1466 * r_12->radiance / make_float3 (r_12->jac), density_5 / r_12->jac);
            }
            uint _S1467 = extractBits_0(_S1205, 19U, 1U);
            bool _S1468 = nee_0 != (_S1467 == 1U);
            if(_S1468)
            {
                return _S1204;
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
                    bool _S1470 = _S1208 != 1U;
                    if(_S1470)
                    {
                        refracted_4 = _S1208 != 3U;
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
                bool _S1471 = _S1208 == 2U;
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
                    passes_0 = !_S1374;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1209 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    if(_S1384)
                    {
                        return _S1204;
                    }
                    uint _S1472 = stream(_S1231, b_8 + 448U);
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
                    passes_0 = !_S1374;
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
                        return _S1204;
                    }
                    return Shift_x24init_0(throughput_5 * lit_0, 1.0f);
                }
                if(_S1218)
                {
                    passes_0 = _S1209 == 2U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1345;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_5 * emission_1, 1.0f);
                }
                if(_S1218)
                {
                    passes_0 = _S1209 == 1U;
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
                    passes_0 = !_S1374;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_5 * emission_1, 1.0f);
                }
                return _S1204;
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
                    bool _S1480 = b_8 > 0U;
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
                            if(_S1374)
                            {
                                candidate_5 = here_0;
                            }
                        }
                        float3  _S1482 = throughput_5 * emission_1;
                        Reservoir _S1483 = withEnd(candidate_5, 1U, b_8, _S1482);
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
                            if(_S1374)
                            {
                                candidate_6 = here_0;
                                uint _S1488 = insertBits_0((&candidate_6)->path, 1U, 19U, 1U);
                                (&candidate_6)->path = _S1488;
                                (&candidate_6)->dir = light_3.dir;
                                (&candidate_6)->radiance = light_3.radiance;
                            }
                            else
                            {
                                uint _S1489 = insertBits_0(0U, b_8 + 1U, 5U, 5U);
                                uint _S1490 = insertBits_0(_S1489, 2U, 10U, 2U);
                                (&candidate_6)->path = _S1490;
                            }
                        }
                        Reservoir _S1491 = withEnd(candidate_6, 0U, b_8, _S1486);
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
                        _S1460 = b_8 < _S1493;
                    }
                    else
                    {
                        _S1460 = false;
                    }
                    if(_S1460)
                    {
                        uint _S1494 = stream(_S1231, b_8 + 448U);
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
                            if(_S1374)
                            {
                                candidate_7 = here_0;
                                uint _S1501 = insertBits_0((&candidate_7)->path, 1U, 19U, 1U);
                                (&candidate_7)->path = _S1501;
                                (&candidate_7)->dir = _S1498.dir;
                                (&candidate_7)->radiance = _S1498.radiance;
                            }
                            else
                            {
                                uint _S1502 = insertBits_0(0U, b_8 + 1U, 5U, 5U);
                                uint _S1503 = insertBits_0(_S1502, 2U, 10U, 2U);
                                (&candidate_7)->path = _S1503;
                            }
                        }
                        Reservoir _S1504 = withEnd(candidate_7, 4U, b_8, _S1499);
                        offer(sel_7, _S1504, _S1499 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                }
            }
            throughput_6 = throughput_5;
            density_4 = density_2;
        }
        bool _S1505;
        bool straight_0;
        bool _S1506;
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
        uint b_11;
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
            uint _S1520 = extractBits_0(_S1205, 15U, 2U);
            uint _S1521 = extractBits_0(_S1205, 17U, 2U);
            uint _S1522 = _slang_select(_S1414, _S1521,_S1520);
            float3  _S1523 = r_12->dir;
            bool refracted_5 = _S1522 == 1U;
            SampleBSDF _S1524 = SampleBSDF_x24init_0(_S1203, _S1203, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_13 = _S1524;
            float3  reconnection_1;
            SampleBSDF _S1525;
            if(viewed_1)
            {
                uint _S1526 = extractBits_0(_S1205, 20U, 1U);
                bool _S1527 = is_inside_6 != (_S1526 == 1U);
                if(_S1527)
                {
                    return _S1204;
                }
                bool _S1528 = _S1208 == 1U;
                if(_S1528)
                {
                    float3  _S1529 = (fcptHitPosition((_S1220)));
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
                    BSDFMaterial _S1530 = _S1375.material;
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
                        wrong_side_0 = (dot_0(_S1376.smooth_n, _S1533) * _S1377) < 0.0f;
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
                    float3  _S1536 = - _S1376.smooth_n;
                    bool _S1537 = is_inside_6 != refracted_4;
                    float3  _S1538 = _slang_select(_S1537, _S1536,_S1376.smooth_n);
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
                    return _S1204;
                }
                float3  _S1542 = throughput_8;
                throughput_8 = reconnection_1;
                b_11 = _S1522;
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
                        SampleBSDF _S1544 = (fcptSampleHair((surface_11.hair), (_S1375.material.albedo), (_S1375.material.specular_tint), ((&ray_2)->unit_direction), (surface_11.random_state)));
                        _S1525 = _S1544;
                    }
                    else
                    {
                        SampleBSDF _S1545 = sampleBSDF((&ray_2)->unit_direction, _S1376.smooth_n, _S1375.material, _S1379.x, _S1379.y, surface_11.random_state, _S1431);
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
                            return _S1204;
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
                        _S1459 = (_S1375.material.transmission) > 0.0f;
                    }
                    else
                    {
                        _S1459 = false;
                    }
                    if(_S1459)
                    {
                        SampleBSDF _S1547 = sampleBSDF((&bsdf_sampled_0)->unit_direction, surface_11.geometry_n, _S1375.material, _S1379.x, _S1379.y, (&bsdf_sampled_0)->random_state, _S1431);
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
                    lobe_13 = bsdf_sampled_0;
                    float _S1552 = (&bsdf_sampled_0)->pdf;
                    float _S1553 = _slang_select(wrong_side_0, 0.0f,_S1552);
                    (&lobe_13)->pdf = _S1553;
                    throughput_8 = _S1550;
                    b_11 = _S1549;
                    refracted_4 = _S1551;
                }
                else
                {
                    throughput_8 = _S1523;
                    b_11 = _S1522;
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
                    SampleBSDF _S1554 = (fcptConnectHair((surface_11.hair), (_S1375.material.albedo), (_S1375.material.specular_tint), ((&ray_2)->unit_direction), (throughput_8)));
                    _S1525 = _S1554;
                }
                else
                {
                    SampleBSDF _S1555 = connectBSDF((&ray_2)->unit_direction, throughput_8, _S1376.smooth_n, _S1375.material, _S1379.x, _S1379.y, b_11, surface_11.random_state);
                    _S1525 = _S1555;
                }
                lobe_13 = _S1525;
            }
            if(_S1384)
            {
                _S1460 = false;
            }
            else
            {
                bool _S1556 = b_11 != 0U;
                if(_S1556)
                {
                    bool _S1557 = (_S1375.material.roughness) == 0.0f;
                    if(_S1557)
                    {
                        _S1460 = true;
                    }
                    else
                    {
                        bool _S1558 = b_11 == 1U;
                        if(_S1558)
                        {
                            _S1460 = (_S1379.x) == (_S1379.y);
                        }
                        else
                        {
                            _S1460 = false;
                        }
                    }
                }
                else
                {
                    _S1460 = false;
                }
            }
            bool _S1559 = !_S1384;
            if(_S1559)
            {
                _S1505 = b_11 == 1U;
            }
            else
            {
                _S1505 = false;
            }
            if(_S1505)
            {
                straight_0 = (_S1375.material.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S1506 = _S1559;
            }
            else
            {
                _S1506 = false;
            }
            if(_S1506)
            {
                _S1507 = b_11 == 1U;
            }
            else
            {
                _S1507 = false;
            }
            if(_S1507)
            {
                _S1508 = (_S1379.x) == (_S1379.y);
            }
            else
            {
                _S1508 = false;
            }
            BSDFMaterial _S1560 = _S1375.material;
            bool _S1561 = isTranslucent_0(&_S1560);
            if(_S1561)
            {
                _S1509 = b_11 == 0U;
            }
            else
            {
                _S1509 = false;
            }
            if(_S1509)
            {
                _S1510 = (dot_0(throughput_8, surface_11.geometry_n)) < 0.0f;
            }
            else
            {
                _S1510 = false;
            }
            if(nee_0)
            {
                _S1511 = !_S1460;
            }
            else
            {
                _S1511 = false;
            }
            if(_S1511)
            {
                _S1512 = !wrong_side_0;
            }
            else
            {
                _S1512 = false;
            }
            if(_S1512)
            {
                float _S1562 = (&lobe_13)->pdf;
                float3  _S1563 = (&ray_2)->origin;
                float3  _S1564 = _slang_select(_S1389, _S1203,_S1376.smooth_n);
                float3  _S1565 = (&ray_2)->origin;
                FKSurface _S1566 = surface_11;
                float3  _S1567 = - _S1376.smooth_n;
                float3  _S1568 = _slang_select(_S1510, _S1567,_S1376.smooth_n);
                NEEVertex _S1569 = NEEVertex_x24init_0(false, _S1562, _S1563, _S1564, _S1565 + make_float3 (_S1566.geometry_offset) * _S1568);
                nee_vertex_0 = _S1569;
            }
            else
            {
                if(_S1384)
                {
                    _S1513 = true;
                }
                else
                {
                    bool _S1570 = b_11 != 1U;
                    if(_S1570)
                    {
                        _S1513 = true;
                    }
                    else
                    {
                        _S1513 = (_S1379.x) != (_S1379.y);
                    }
                }
                if(_S1513)
                {
                    (&nee_vertex_0)->none = true;
                }
            }
            bool _S1571 = b_11 == 0U;
            bool _S1572 = withinInverseFootprint((&lobe_13)->pdf, _S1571, (&prev_0)->cos, (&hit_4)->distance, threshold_2);
            bool _S1573 = roughLobe((&lobe_13)->pdf, _S1571, _S1375.material.roughness);
            if(_S1414)
            {
                bool _S1574 = !_S1572;
                if(_S1574)
                {
                    return _S1204;
                }
                bool _S1575 = _S1209 != 1U;
                if(_S1575)
                {
                    _S1513 = _S1209 != 2U;
                }
                else
                {
                    _S1513 = false;
                }
                if(_S1513)
                {
                    float _S1576 = (&lobe_13)->pdf;
                    float _S1577 = _slang_select(nee_0, _S1576,0.0f);
                    float _S1578 = escapeWeight_0(_S1577, _S1523);
                    if(_S1422)
                    {
                        passes_0 = _S1215;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1579 = _slang_select(passes_0, _S1578,1.0f);
                    return Shift_x24init_0(throughput_6 * ((&lobe_13)->throughput * make_float3 ((&lobe_13)->pdf)) * r_12->radiance * make_float3 (_S1579) / make_float3 (r_12->jac), density_4 * (&lobe_13)->pdf / r_12->jac);
                }
                float3  _S1580 = throughput_6 * make_float3 ((&lobe_13)->pdf);
                float _S1581 = density_4 * (&lobe_13)->pdf;
                throughput_9 = _S1580;
                density_6 = _S1581;
            }
            else
            {
                throughput_9 = throughput_6;
                density_6 = density_4;
            }
            uint _S1582 = (fcptLayers((hit_4)));
            bool _S1583 = b_11 == 1U;
            bool _S1584 = passesLayer_0(_S1582, _S1583, passes_0);
            if(viewed_1)
            {
                _S1513 = _S1584;
            }
            else
            {
                _S1513 = false;
            }
            if(_S1513)
            {
                return _S1204;
            }
            if(replay_2)
            {
                _S1514 = b_8 <= _S1219;
            }
            else
            {
                _S1514 = false;
            }
            if(_S1514)
            {
                _S1515 = _S1374;
            }
            else
            {
                _S1515 = false;
            }
            if(_S1515)
            {
                _S1516 = _S1572;
            }
            else
            {
                _S1516 = false;
            }
            if(_S1516)
            {
                _S1517 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S1517 = !_S1573;
                }
                else
                {
                    _S1517 = false;
                }
            }
            if(_S1517)
            {
                return _S1204;
            }
            if(viewed_1)
            {
                float3  _S1585 = throughput_9 * ((&lobe_13)->throughput * make_float3 ((&lobe_13)->pdf));
                float _S1586 = (&lobe_13)->pdf;
                throughput_10 = _S1585;
                sky_pdf_2 = _S1586;
            }
            else
            {
                float3  _S1587 = throughput_9 * max_0((&lobe_13)->throughput, _S1203);
                throughput_10 = _S1587;
                sky_pdf_2 = density_6;
            }
            bool _S1588 = !replay_2;
            if(_S1588)
            {
                _S1518 = !_S1405;
            }
            else
            {
                _S1518 = false;
            }
            if(_S1518)
            {
                _S1519 = _S1374;
            }
            else
            {
                _S1519 = false;
            }
            bool _S1589;
            if(_S1519)
            {
                _S1589 = _S1572;
            }
            else
            {
                _S1589 = false;
            }
            float3  chain_throughput_1;
            if(_S1589)
            {
                chain_0 = here_0;
                uint _S1590 = insertBits_0((&chain_0)->path, b_11, 17U, 2U);
                uint _S1591 = _slang_select(nee_0, 1U,0U);
                uint _S1592 = insertBits_0(_S1590, _S1591, 19U, 1U);
                (&chain_0)->path = _S1592;
                float _S1593 = (&chain_0)->jac * (&lobe_13)->pdf;
                (&chain_0)->jac = _S1593;
                (&chain_0)->dir = throughput_8;
                chain_throughput_1 = throughput_10;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            FKSurface _S1594 = surface_11;
            Vertex _S1595 = Vertex_x24init_0(_S1573, b_11, (&lobe_13)->pdf, (F32_abs((dot_0(surface_11.geometry_n, throughput_8)))), is_inside_6);
            prev_0 = _S1595;
            float _S1596 = (&lobe_13)->pdf;
            bool _S1597;
            if(_S1583)
            {
                _S1597 = (_S1379.x) == (_S1379.y);
            }
            else
            {
                _S1597 = false;
            }
            float sky_pdf_3 = _slang_select(_S1597, sky_pdf_0,_S1596);
            float _S1598 = _slang_select(_S1384, 0.0f,sky_pdf_3);
            float _S1599 = widened_0(spread_2, (&lobe_13)->pdf, _S1460);
            bool _S1600;
            if(refracted_4)
            {
                _S1600 = !_S1510;
            }
            else
            {
                _S1600 = false;
            }
            bool is_inside_7;
            if(_S1600)
            {
                bool _S1601 = !is_inside_6;
                is_inside_7 = _S1601;
            }
            else
            {
                is_inside_7 = is_inside_6;
            }
            FKSurface _S1602 = surface_11;
            bool _S1603 = boundsVolume_0(&_S1602);
            bool _S1604;
            if(_S1603)
            {
                _S1604 = !_S1584;
            }
            else
            {
                _S1604 = false;
            }
            if(_S1604)
            {
                FKSurface faced_2 = surface_11;
                float3  _S1605 = - _S1594.geometry_n;
                float3  _S1606 = _slang_select(turned_1, _S1605,_S1594.geometry_n);
                (&faced_2)->geometry_n = _S1606;
                FKMedium _S1607 = Medium_x24init_0(scatter_in_0, extinction_in_0, g_in_0);
                FKMedium _S1608 = (fcptOutsideMedium((hit_4)));
                FKSurface _S1609 = faced_2;
                FKMedium _S1610 = _S1607;
                FKMedium _S1611 = _S1608;
                MediumSides _S1612 = mediumSides_0(&_S1609, &_S1610, filling_2, (&ray_2)->unit_direction, &_S1611);
                bool _S1613 = leavesInFront_0((&faced_2)->geometry_n, throughput_8, _S1594.geometry_n);
                float3  _S1614 = _slang_select(_S1613, _S1612.front.scatter,_S1612.behind.scatter);
                scatter_in_0 = _S1614;
                float3  _S1615 = _slang_select(_S1613, _S1612.front.extinction,_S1612.behind.extinction);
                extinction_in_0 = _S1615;
                float _S1616 = _slang_select(_S1613, _S1612.front.g,_S1612.behind.g);
                g_in_0 = _S1616;
                uint _S1617 = _S1612.fillings.x;
                uint _S1618 = _S1612.fillings.y;
                uint _S1619 = _slang_select(_S1613, _S1618,_S1617);
                bool _S1620 = (fcptVaryingUsed());
                uint _S1621 = _slang_select(_S1620, _S1619,4294967295U);
                filling_2 = _S1621;
            }
            (&ray_2)->unit_direction = throughput_8;
            bool _S1622 = !_S1584;
            if(_S1622)
            {
                FKSurface _S1623 = surface_11;
                float _S1624 = _slang_select(straight_0, 0.0f,_S1623.geometry_offset);
                float3  _S1625 = - _S1376.smooth_n;
                bool _S1626 = is_inside_7 != _S1510;
                float3  _S1627 = _slang_select(_S1626, _S1625,_S1376.smooth_n);
                float3  _S1628 = (&ray_2)->origin + make_float3 (_S1624) * _S1627;
                (&ray_2)->origin = _S1628;
            }
            throughput_9 = throughput_10;
            chain_throughput_0 = chain_throughput_1;
            density_6 = sky_pdf_2;
            passes_0 = _S1584;
            viewed_1 = _S1508;
            sky_pdf_2 = _S1598;
            spread_5 = _S1599;
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
        bool _S1629 = !replay_2;
        float density_7;
        if(_S1629)
        {
            if(_S1345)
            {
                float3  _S1630 = throughput_9 * emission_1;
                Reservoir candidate_8 = chain_0;
                uint _S1631 = extractBits_0((&chain_0)->path, 10U, 2U);
                bool _S1632 = _S1631 == 1U;
                if(_S1632)
                {
                    float3  _S1633 = safeDivide(_S1630, chain_throughput_0);
                    (&candidate_8)->radiance = _S1633;
                }
                Reservoir _S1634 = withEnd(candidate_8, 2U, b_8, _S1630);
                offer(sel_7, _S1634, _S1630 * make_float3 (scale_3) / make_float3 (density_6));
            }
            if(_S1345)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = scatter_2;
            }
            if(refracted_4)
            {
                float _S1635 = survivalProbability(throughput_9, density_6);
                density_7 = _S1635;
            }
            else
            {
                density_7 = 1.0f;
            }
            uint _S1636 = stream(_S1231, b_8 + 128U);
            Random _S1637 = pcg(_S1636);
            bool _S1638 = density_7 < (_S1637.value);
            if(_S1638)
            {
                wrong_side_0 = true;
            }
            else
            {
                uint _S1639 = (fcptMaxBounces());
                wrong_side_0 = b_8 >= _S1639;
            }
            if(wrong_side_0)
            {
                break;
            }
            float _S1640 = density_6 * density_7;
            density_7 = _S1640;
        }
        else
        {
            density_7 = density_6;
        }
        uint _S1641 = layer_0 ^ 1U;
        uint _S1642 = _slang_select(passes_0, _S1641,0U);
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
            uint _S1643 = b_11 + 1U;
            b_8 = _S1643;
            layer_0 = _S1642;
            continue;
        }
        FKRay _S1644 = ray_2;
        float _S1645 = distance_1(reconnection_0, (&ray_2)->origin) * 1.0010000467300415f;
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
            wrong_side_0 = _S1208 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S1646 = _slang_select(wrong_side_0, _S1645,4.294967296e+09f);
        bool _S1647 = !_S1384;
        if(straight_0)
        {
            _S1459 = true;
        }
        else
        {
            _S1459 = _S1384;
        }
        FKHit _S1648;
        if(_S1459)
        {
            _S1648 = hit_4;
        }
        else
        {
            _S1648 = _S1432;
        }
        FKHit _S1649 = (fcptTraverseInstanceBVH((_S1644), (_S1350), (_S1646), (_S1647), (_S1648), (viewed_1)));
        hit_4 = _S1649;
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
            _S1505 = _S1208 == 1U;
        }
        else
        {
            _S1505 = false;
        }
        if(_S1505)
        {
            _S1506 = ((&hit_4)->instance_index) == (_S1220.instance_index);
        }
        else
        {
            _S1506 = false;
        }
        if(_S1506)
        {
            _S1507 = ((&hit_4)->triangle_index) == (_S1220.triangle_index);
        }
        else
        {
            _S1507 = false;
        }
        if(_S1507)
        {
            (&hit_4)->uv = _S1220.uv;
            float _S1650 = distance_1(reconnection_0, (&ray_2)->origin);
            (&hit_4)->distance = _S1650;
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
            _S1509 = _S1208 == 3U;
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
            return _S1204;
        }
        Reservoir _S1651 = chain_0;
        uint _S1652 = filling_2;
        for(;;)
        {
            bool _S1653 = (fcptVaryingUsed());
            if(_S1653)
            {
                _S1511 = _S1652 != 4294967295U;
            }
            else
            {
                _S1511 = false;
            }
            float _S1654;
            if(_S1511)
            {
                float _S1655 = (fcptMajorant((_S1652)));
                _S1654 = _S1655;
            }
            else
            {
                _S1654 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
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
                _S1513 = _S1208 == 1U;
            }
            else
            {
                _S1513 = false;
            }
            if(_S1513)
            {
                _S1514 = _S1654 > 0.0f;
            }
            else
            {
                _S1514 = false;
            }
            if(_S1514)
            {
                ended_0 = _S1204;
                sky_pdf_1 = sky_pdf_2;
                spread_3 = spread_5;
                width_4 = width_3;
                density_3 = density_7;
                throughput_10 = throughput_9;
                b_11 = b_8;
                _S1515 = true;
                break;
            }
            bool _S1656 = (&prev_0)->rough;
            if(_S1656)
            {
                _S1515 = !(_S1654 > 0.0f);
            }
            else
            {
                _S1515 = false;
            }
            (&prev_0)->rough = _S1515;
            uint _S1657 = b_8 + 320U;
            bool _S1658 = b_8 == 4294967295U;
            uint _S1659 = _slang_select(_S1658, 384U,_S1657);
            uint _S1660 = stream(_S1231, _S1659);
            uint tracking_1 = _S1660;
            weight_1 = throughput_3;
            glowed_0 = _S1203;
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
                    _S1202 = int(2);
                    break;
                }
                uint _S1661 = b_11 + 320U;
                bool _S1662 = b_11 == 4294967295U;
                uint _S1663 = _slang_select(_S1662, 384U,_S1661);
                uint _S1664 = stream(_S1231, _S1663);
                Random _S1665 = pcg(_S1664);
                float _S1666 = freeFlight_0(_S1665.value, _S1654);
                if(_S1511)
                {
                    float3  _S1667 = (&ray_2)->origin;
                    float3  _S1668 = (&ray_2)->unit_direction;
                    float _S1669 = (&hit_4)->distance;
                    uint _S1670 = _slang_select(_S1662, 0U,b_11);
                    uint _S1671 = (&prev_0)->lobe;
                    uint _S1672 = _slang_select(_S1662, 3U,_S1671);
                    float _S1673 = (fcptTrackMedium((_S1652), (_S1667), (_S1668), (_S1669), (&tracking_1), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1670), (_S1672), (_S1662)));
                    spread_4 = _S1673;
                }
                else
                {
                    spread_4 = _S1666;
                }
                bool _S1674 = !(spread_4 < ((&hit_4)->distance));
                if(_S1674)
                {
                    _S1202 = int(2);
                    break;
                }
                if(_S1511)
                {
                    _S1516 = _S1629;
                }
                else
                {
                    _S1516 = false;
                }
                if(_S1516)
                {
                    float3  _S1675 = throughput_10 * glowed_0 / make_float3 (density_3);
                    float3  _S1676 = sel_7->glow + _S1675;
                    sel_7->glow = _S1676;
                }
                else
                {
                }
                glowed_0 = _S1203;
                uint b_12 = b_11 + 1U;
                float3  _S1677 = (&ray_2)->origin + make_float3 (spread_4) * (&ray_2)->unit_direction;
                (&ray_2)->origin = _S1677;
                float3  _S1678 = flightWeight_0(scatter_in_0, extinction_in_0, _S1654, spread_4, true);
                float3  _S1679 = weight_1;
                float3  _S1680 = _slang_select(_S1511, _S1679,_S1678);
                float3  throughput_11 = throughput_10 * _S1680;
                uint _S1681 = stream(_S1231, b_12 + 320U);
                tracking_1 = _S1681;
                weight_1 = throughput_3;
                float width_7 = width_4 + spread_3 * spread_4;
                float _S1682 = spread_3 + 3.14159274101257324f;
                bool _S1683 = scatterSampled_0(replay_2, b_12, _S1219, _S1511);
                TreeSample light_4;
                if(_S1683)
                {
                    float3  _S1684 = (&ray_2)->origin;
                    float3  _S1685 = (&ray_2)->unit_direction;
                    float3  _S1686 = (&ray_2)->unit_direction;
                    uint _S1687 = stream(_S1231, b_12 + 64U);
                    float3  _S1688 = extinction_in_0;
                    float3  _S1689 = extinction_in_0;
                    uint2  _S1690 = make_uint2 (_S1652);
                    float3  _S1691 = (&ray_2)->unit_direction;
                    uint _S1692 = arrivalLobe_0(b_12, (&prev_0)->lobe);
                    FKHit _S1693 = _S1432;
                    ShadowContext _S1694 = ShadowContext_x24init_0(_S1688, _S1689, _S1690, _S1691, b_12, _S1692, false, spread_4, width_7, &_S1693, false);
                    ShadowContext _S1695 = _S1694;
                    TreeSample _S1696 = sampleLightTree_0(_S1684, _S1685, _S1686, 0.0f, true, _S1687, &_S1695);
                    light_4 = _S1696;
                }
                else
                {
                    light_4 = _S1429;
                }
                float _S1697 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_4.dir));
                uint _S1698 = (fcptMaxBounces());
                bool _S1699 = b_12 < _S1698;
                if(_S1699)
                {
                    _S1517 = (light_4.density) > 0.0f;
                }
                else
                {
                    _S1517 = false;
                }
                float _S1700 = _slang_select(_S1517, _S1697,0.0f);
                float3  _S1701 = throughput_11 * light_4.radiance;
                float _S1702 = powerHeuristic(light_4.density, _S1700);
                float3  _S1703 = _S1701 * make_float3 (_S1697 * _S1702);
                float3  _S1704 = _slang_select(_S1683, _S1703,_S1203);
                if(replay_2)
                {
                    _S1518 = b_12 == _S1219;
                }
                else
                {
                    _S1518 = false;
                }
                if(_S1518)
                {
                    bool _S1705 = _S1208 == 2U;
                    if(_S1705)
                    {
                        float _S1706 = rgb_to_greyscale(_S1704);
                        _S1519 = _S1706 > 0.0f;
                    }
                    else
                    {
                        _S1519 = false;
                    }
                    if(_S1519)
                    {
                        Shift _S1707 = Shift_x24init_0(_S1704, 1.0f);
                        _S1202 = int(1);
                        ended_0 = _S1707;
                        spread_4 = _S1682;
                        width_5 = width_7;
                        throughput_8 = throughput_11;
                        b_9 = b_12;
                        break;
                    }
                    _S1202 = int(1);
                    ended_0 = _S1204;
                    spread_4 = _S1682;
                    width_5 = width_7;
                    throughput_8 = throughput_11;
                    b_9 = b_12;
                    break;
                }
                if(_S1629)
                {
                    Reservoir candidate_9 = _S1651;
                    uint _S1708 = extractBits_0(_S1651.path, 10U, 2U);
                    bool _S1709 = _S1708 == 1U;
                    if(_S1709)
                    {
                        float3  _S1710 = safeDivide(_S1704, chain_throughput_0);
                        (&candidate_9)->radiance = _S1710;
                    }
                    else
                    {
                        uint _S1711 = insertBits_0(0U, b_12 + 1U, 5U, 5U);
                        uint _S1712 = insertBits_0(_S1711, 2U, 10U, 2U);
                        (&candidate_9)->path = _S1712;
                    }
                    Reservoir _S1713 = withEnd(candidate_9, 0U, b_12, _S1704);
                    offer(sel_7, _S1713, _S1704 * make_float3 (scale_3) / make_float3 (density_3));
                    float _S1714 = survivalProbability(throughput_11, density_3);
                    uint _S1715 = stream(_S1231, b_12 + 128U);
                    Random _S1716 = pcg(_S1715);
                    bool _S1717 = _S1714 < (_S1716.value);
                    if(_S1717)
                    {
                        _S1519 = true;
                    }
                    else
                    {
                        uint _S1718 = (fcptMaxBounces());
                        _S1519 = b_12 >= _S1718;
                    }
                    if(_S1519)
                    {
                        _S1202 = int(1);
                        ended_0 = _S1204;
                        spread_4 = _S1682;
                        width_5 = width_7;
                        throughput_8 = throughput_11;
                        b_9 = b_12;
                        break;
                    }
                    float _S1719 = density_3 * _S1714;
                    density_3 = _S1719;
                }
                else
                {
                }
                float phase_pdf_1 = 0.0f;
                uint _S1720 = stream(_S1231, b_12);
                float3  _S1721 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1720, &phase_pdf_1);
                (&ray_2)->unit_direction = _S1721;
                NEEVertex _S1722 = NEEVertex_x24init_0(false, phase_pdf_1, (&ray_2)->origin, _S1203, (&ray_2)->origin);
                nee_vertex_0 = _S1722;
                Vertex _S1723 = scatteredVertex_0(is_inside_5);
                prev_0 = _S1723;
                float _S1724 = (&prev_0)->pdf;
                FKRay _S1725 = ray_2;
                FKHit _S1726 = (fcptTraverseInstanceBVH((_S1725), (true), (4.294967296e+09f), (false), (_S1432), (false)));
                hit_4 = _S1726;
                b_11 = b_12;
                throughput_10 = throughput_11;
                spread_3 = _S1682;
                width_4 = width_7;
                sky_pdf_1 = _S1724;
            }
            if(_S1202 != int(2))
            {
                spread_3 = spread_4;
                width_4 = width_5;
                throughput_10 = throughput_8;
                b_11 = b_9;
                _S1515 = true;
                break;
            }
            ended_0 = _S1204;
            _S1515 = false;
            break;
        }
        if(_S1515)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S1516 = b_11 == b_8;
        }
        else
        {
            _S1516 = false;
        }
        bool _S1727 = ((&hit_4)->instance_index) == 4294967295U;
        if(_S1727)
        {
            bool _S1728 = !(&nee_vertex_0)->none;
            float _S1729 = _slang_select(_S1728, sky_pdf_1,0.0f);
            float _S1730 = escapeWeight_0(_S1729, (&ray_2)->unit_direction);
            float3  _S1731 = environment_0((&ray_2)->unit_direction, b_11, (&prev_0)->lobe);
            float3  _S1732 = throughput_10 * _S1731;
            if(replay_2)
            {
                bool _S1733 = b_11 == _S1219;
                if(_S1733)
                {
                    passes_0 = _S1208 == 3U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(_S1732 * make_float3 (_S1730) / make_float3 (r_12->jac), density_3 / r_12->jac);
                }
                if(_S1218)
                {
                    passes_0 = _S1215;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = b_11 == _S1206;
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
                    return Shift_x24init_0(_S1732 * make_float3 (_S1730), 1.0f);
                }
                return _S1204;
            }
            Reservoir candidate_10 = chain_0;
            uint _S1734 = extractBits_0((&chain_0)->path, 10U, 2U);
            bool _S1735 = _S1734 == 1U;
            if(_S1735)
            {
                uint _S1736 = extractBits_0((&chain_0)->path, 5U, 5U);
                bool _S1737 = _S1736 == b_11;
                float _S1738 = _slang_select(_S1737, 1.0f,_S1730);
                float3  _S1739 = safeDivide(_S1732 * make_float3 (_S1738), chain_throughput_0);
                (&candidate_10)->radiance = _S1739;
            }
            else
            {
                bool _S1740 = (&prev_0)->rough;
                if(_S1740)
                {
                    uint _S1741 = insertBits_0(0U, b_11 + 1U, 5U, 5U);
                    uint _S1742 = insertBits_0(_S1741, 3U, 10U, 2U);
                    uint _S1743 = insertBits_0(_S1742, (&prev_0)->lobe, 15U, 2U);
                    bool _S1744 = (&prev_0)->inside;
                    uint _S1745 = _slang_select(_S1744, 1U,0U);
                    uint _S1746 = insertBits_0(_S1743, _S1745, 20U, 1U);
                    (&candidate_10)->path = _S1746;
                    (&candidate_10)->jac = (&prev_0)->pdf;
                    (&candidate_10)->dir = (&ray_2)->unit_direction;
                }
            }
            float3  _S1747 = _S1732 * make_float3 (_S1730);
            Reservoir _S1748 = withEnd(candidate_10, 3U, b_11, _S1747);
            offer(sel_7, _S1748, _S1747 * make_float3 (scale_3) / make_float3 (density_3));
            break;
        }
        float3  _S1749 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
        (&ray_2)->origin = _S1749;
        bool _S1750 = (fcptVaryingUsed());
        if(_S1750)
        {
            _S1517 = filling_2 != 4294967295U;
        }
        else
        {
            _S1517 = false;
        }
        if(_S1517)
        {
            if(_S1629)
            {
                float3  _S1751 = throughput_10 * glowed_0 / make_float3 (density_3);
                float3  _S1752 = sel_7->glow + _S1751;
                sel_7->glow = _S1752;
            }
            float3  _S1753 = throughput_10 * weight_1;
            throughput_8 = _S1753;
        }
        else
        {
            float3  _S1754 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
            float3  _S1755 = throughput_10 * _S1754;
            throughput_8 = _S1755;
        }
        float _S1756 = width_4 + spread_3 * (&hit_4)->distance;
        viewed_0 = _S1516;
        width_3 = _S1756;
        throughput_2 = throughput_8;
        density_2 = density_3;
        sky_pdf_0 = sky_pdf_1;
        spread_2 = spread_3;
        uint _S1643 = b_11 + 1U;
        b_8 = _S1643;
        layer_0 = _S1642;
    }
    return _S1204;
}

static __device__ Shift shift_0(Domain * dom_8, Reservoir * r_13)
{
    Selection _S1757 = (Selection{});
    Selection sel_8 = _S1757;
    bool _S1758 = (r_13->w) <= 0.0f;
    if(_S1758)
    {
        return Shift_x24init_0(make_float3 (0.0f), 0.0f);
    }
    Shift _S1759 = walk_0(dom_8, r_13, true, 0.0f, &sel_8);
    return _S1759;
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
    Random _S1760 = pcg(state_3);
    Random _S1761 = pcg(_S1760.state);
    float _S1762 = 6.28318548202514648f * _S1760.value;
    float _S1763 = (F32_sqrt((-2.0f * clamp_1((F32_log((_S1761.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S1761.state, _S1763 * (F32_cos((_S1762))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_4, float3  value_2)
{
    RandomSphere _S1764;
    (&_S1764)->state = state_4;
    (&_S1764)->value = value_2;
    return _S1764;
}

__device__ RandomSphere random_sphere(uint state_5)
{
    Random _S1765 = normal_distribution(state_5);
    Random _S1766 = normal_distribution(_S1765.state);
    Random _S1767 = normal_distribution(_S1766.state);
    float3  _S1768 = make_float3 (_S1765.value, _S1766.value, _S1767.value);
    float3  _S1769 = ((((_S1768)) * make_float3(rnorm3df(((_S1768)).x, ((_S1768)).y, ((_S1768)).z))));
    return RandomSphere_x24init_0(_S1767.state, _S1769);
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_19)
{
    float3  _S1770 = p1_0 - p0_0;
    float3  _S1771 = p2_0 - p0_0;
    float2  _S1772 = uv1_0 - uv0_0;
    float2  _S1773 = uv2_0 - uv0_0;
    float _S1774 = _S1772.x;
    float _S1775 = _S1773.y;
    float _S1776 = _S1772.y;
    float _S1777 = _S1773.x;
    float _S1778 = _S1774 * _S1775 - _S1776 * _S1777;
    float _S1779 = 1.0f / _S1778;
    float3  t_24 = (_S1770 * make_float3 (_S1775) - _S1771 * make_float3 (_S1776)) * make_float3 (_S1779);
    float3  _S1780 = (_S1771 * make_float3 (_S1774) - _S1770 * make_float3 (_S1777)) * make_float3 (_S1779);
    float3  _S1781 = t_24 - n_19 * make_float3 (dot_0(n_19, t_24));
    float3  t_25 = ((((_S1781)) * make_float3(rnorm3df(((_S1781)).x, ((_S1781)).y, ((_S1781)).z))));
    bool _S1782 = (dot_0(cross_0(n_19, t_25), _S1780)) > 0.0f;
    float3  t_26;
    if(_S1782)
    {
        float3  _S1783 = negate_0(t_25);
        t_26 = _S1783;
    }
    else
    {
        t_26 = t_25;
    }
    float3  _S1784 = cross_0(n_19, t_26);
    return makeMatrix<float, 3, 3> (t_26, _S1784, n_19);
}

__device__ float3  tangentToWorldNormalMap(float3  v_10, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_10, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_5, float3  uvw_0, float3  position_0)
{
    float3  _S1785 = t1_0 - t0_0;
    float3  _S1786 = t2_2 - t0_0;
    float3  _S1787 = t2_2 - t1_0;
    float _S1788 = (F32_min((length_0(_S1785)), ((F32_min((length_0(_S1786)), (length_0(_S1787)))))));
    float3  _S1789 = make_float3 (distance_1(position_0, t0_0), distance_1(position_0, t1_0), distance_1(position_0, t2_2));
    float3  _S1790 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S1791 = dot_0(geometry_n_5, _S1790);
    float3  _S1792 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S1793 = dot_0(geometry_n_5, _S1792);
    float3  _S1794 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S1795 = acos_0(abs_0(make_float3 (_S1791, _S1793, dot_0(geometry_n_5, _S1794))));
    float3  _S1796 = clamp_2(tan_0(_S1795), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_1(dot_0(_S1789 * _S1796, uvw_0), 0.0f, _S1788 * 0.125f);
}

__device__ float3  straightThrough(float3  dir_15, float3  n_20, BSDFMaterial material_17)
{
    float3  _S1797 = negate_0(dir_15);
    float _S1798 = sign_0(dot_0(n_20, _S1797));
    float3  _S1799 = n_20 * make_float3 (_S1798);
    AnisotropicFrame _S1800 = anisotropicFrame(material_17, _S1799);
    bool _S1801 = (_S1800.alphas.x) > 0.0f;
    if(_S1801)
    {
        float _S1802 = material_17.transmission * (1.0f - material_17.metallic);
        float3  _S1803 = negate_0(_S1799);
        float3  _S1804 = anisotropicLocal(dir_15, _S1800.tangent, _S1803);
        float _S1805 = anisotropicG1(_S1804, _S1800.alphas);
        return make_float3 (_S1802 * _S1805) * material_17.albedo;
    }
    float _S1806 = material_17.transmission * (1.0f - material_17.metallic);
    float _S1807 = material_17.roughness;
    float _S1808 = smithG1(_S1807 * _S1807, (F32_abs((dot_0(n_20, dir_15)))));
    return make_float3 (_S1806 * _S1808) * material_17.albedo;
}

__device__ float hairRow(float3  in_dir_10, float3  t_27, float3  out_dir_4, uint p_12, float w_2, float alpha_6, uint nt_0)
{
    uint _S1809 = p_12 % 4U;
    float _S1810 = w_2 * HAIR_WIDTHS_0[_S1809];
    float _S1811 = (F32_asin((clamp_1(dot_0(out_dir_4, t_27), -1.0f, 1.0f)))) - (F32_asin((clamp_1(dot_0(in_dir_10, t_27), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S1809] * alpha_6;
    return ((F32_asinh((_S1811 / _S1810))) / (F32_asinh((3.14159274101257324f / _S1810))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_11, float3  t_28, float3  out_dir_5, uint np_0)
{
    float3  _S1812 = worldToTangent(out_dir_5, t_28);
    float3  _S1813 = worldToTangent(in_dir_11, t_28);
    return (F32_frac((((F32_atan2((_S1812.z), (_S1812.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S1813.z), (1.17549435082228751e-38f - _S1813.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_12, float3  t_29, uint p_13, float row_0, float column_0, float w_3, float alpha_7, uint nt_1, uint np_1)
{
    float3  _S1814 = worldToTangent(in_dir_12, t_29);
    uint _S1815 = p_13 % 4U;
    float _S1816 = w_3 * HAIR_WIDTHS_0[_S1815];
    float _S1817 = (F32_asin((clamp_1(dot_0(in_dir_12, t_29), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S1815] * alpha_7 + _S1816 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S1816))))));
    float _S1818 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S1814.z), (1.17549435082228751e-38f - _S1814.x)));
    float _S1819 = (F32_cos((_S1817)));
    float3  _S1820 = tangentToWorld(make_float3 (_S1819 * (F32_cos((_S1818))), (F32_sin((_S1817))), _S1819 * (F32_sin((_S1818)))), t_29);
    return _S1820;
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_21, BSDFMaterial material_18, float coverage_1)
{
    float3  _S1821;
    if((material_18.ior) == 1.0f)
    {
        float3  _S1822 = straightThrough(toward_1, n_21, material_18);
        _S1821 = _S1822;
    }
    else
    {
        _S1821 = make_float3 (0.0f);
    }
    return _S1821 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ Shift walk_hook(Domain dom_9, Reservoir r_14, bool replay_3, float scale_4, Selection * sel_9)
{
    Domain _S1823 = dom_9;
    Reservoir _S1824 = r_14;
    Shift _S1825 = walk_0(&_S1823, &_S1824, replay_3, scale_4, sel_9);
    return _S1825;
}

__device__ Shift shift_hook(Domain dom_10, Reservoir r_15)
{
    Domain _S1826 = dom_10;
    Reservoir _S1827 = r_15;
    Shift _S1828 = shift_0(&_S1826, &_S1827);
    return _S1828;
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
