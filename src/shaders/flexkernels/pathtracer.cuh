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

static __device__ float3  negate_0(float3  x_13)
{
    return - x_13;
}

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
    BSDFLobes _S319;
    (&_S319)->v_dot_h = v_dot_h_0;
    (&_S319)->n_dot_h = n_dot_h_0;
    (&_S319)->refracted = refracted_1;
    (&_S319)->F = F_0;
    (&_S319)->F_greyscale = F_greyscale_0;
    (&_S319)->reflect_weight = reflect_weight_0;
    (&_S319)->diffuse_weight = diffuse_weight_0;
    (&_S319)->refract_weight = refract_weight_0;
    (&_S319)->p_diffuse = p_diffuse_0;
    (&_S319)->p_reflect = p_reflect_0;
    (&_S319)->p_refract = p_refract_0;
    (&_S319)->translucent_share = translucent_share_0;
    (&_S319)->sheen = sheen_0;
    (&_S319)->p_sheen_velvet = p_sheen_velvet_0;
    (&_S319)->view = view_0;
    (&_S319)->tangent = tangent_1;
    (&_S319)->alphas = alphas_1;
    (&_S319)->visible = visible_0;
    (&_S319)->p_toon = p_toon_0;
    (&_S319)->toon = toon_0;
    (&_S319)->toon_a = toon_a_0;
    (&_S319)->toon_s = toon_s_0;
    (&_S319)->toon_b = toon_b_0;
    (&_S319)->toon_glossy = toon_glossy_0;
    (&_S319)->toon_norm = toon_norm_0;
    (&_S319)->toon_view = toon_view_0;
    (&_S319)->toon_axis = toon_axis_0;
    return _S319;
}

__device__ float rgb_to_greyscale(float3  rgb_0)
{
    return dot_0(rgb_0, make_float3 (0.29899999499320984f, 0.58700001239776611f, 0.11400000005960464f));
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
    float3  _S320 = make_float3 (alpha_0 * Ve_0.x, alpha_0 * Ve_0.y, Ve_0.z);
    float3  _S321 = ((((_S320)) * make_float3(rnorm3df(((_S320)).x, ((_S320)).y, ((_S320)).z))));
    float _S322 = _S321.x;
    float _S323 = _S321.y;
    float _S324 = _S322 * _S322 + _S323 * _S323;
    float3  _S325;
    if(_S324 > 0.0f)
    {
        float3  _S326 = make_float3 (- _S323, _S322, 0.0f);
        float _S327 = (rsqrtf((_S324)));
        _S325 = _S326 * make_float3 (_S327);
    }
    else
    {
        _S325 = make_float3 (1.0f, 0.0f, 0.0f);
    }
    float3  _S328 = cross_0(_S321, _S325);
    float _S329 = (F32_sqrt((U1_0)));
    float _S330 = 6.28318548202514648f * U2_0;
    float _S331 = _S329 * (F32_cos((_S330)));
    float t2_0 = _S329 * (F32_sin((_S330)));
    float _S332 = 0.5f * (1.0f + _S321.z);
    float t2_1 = (1.0f - _S332) * (F32_sqrt(((F32_max((0.0f), (1.0f - _S331 * _S331)))))) + _S332 * t2_0;
    float3  _S333 = make_float3 (_S331) * _S325 + make_float3 (t2_1) * _S328;
    float _S334 = unshared_0(_S331);
    float _S335 = unshared_0(_S331);
    float3  _S336 = _S333 + make_float3 ((F32_sqrt(((F32_max((0.0f), (1.0f - _S334 * _S335 - t2_1 * t2_1))))))) * _S321;
    float3  _S337 = make_float3 (alpha_0 * _S336.x, alpha_0 * _S336.y, (F32_max((0.0f), (_S336.z))));
    float3  _S338 = ((((_S337)) * make_float3(rnorm3df(((_S337)).x, ((_S337)).y, ((_S337)).z))));
    return _S338;
}

__device__ float3  worldToTangent(float3  v_1, float3  n_3)
{
    float3  a_3 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S339 = (F32_abs((dot_0(n_3, a_3)))) > 0.9999847412109375f;
    float3  a_4;
    if(_S339)
    {
        float3  _S340 = make_float3 (1.0f, 0.0f, 0.0f);
        a_4 = _S340;
    }
    else
    {
        a_4 = a_3;
    }
    float3  _S341 = cross_0(n_3, a_4);
    float3  _S342 = ((((_S341)) * make_float3(rnorm3df(((_S341)).x, ((_S341)).y, ((_S341)).z))));
    float3  _S343 = cross_0(n_3, _S342);
    return make_float3 (dot_0(v_1, _S342), dot_0(v_1, n_3), dot_0(v_1, _S343));
}

__device__ __forceinline__ float3  sampleHalfVector(float3  v_2, float3  n_i_1, float alpha_1, AnisotropicFrame frame_0, uint * random_state_2)
{
    Random _S344 = pcg(*random_state_2);
    Random _S345 = pcg(_S344.state);
    *random_state_2 = _S345.state;
    float _S346 = frame_0.alphas.x;
    bool _S347 = _S346 > 0.0f;
    if(_S347)
    {
        float3  _S348 = anisotropicLocal(v_2, frame_0.tangent, n_i_1);
        float _S349 = frame_0.alphas.y;
        float3  _S350 = make_float3 (_S346 * _S348.x, _S349 * _S348.y, _S348.z);
        float3  _S351 = ((((_S350)) * make_float3(rnorm3df(((_S350)).x, ((_S350)).y, ((_S350)).z))));
        float3  _S352 = sampleGGXVNDF(_S351, 1.0f, _S344.value, _S345.value);
        float3  _S353 = make_float3 (_S346 * _S352.x, _S349 * _S352.y, _S352.z);
        float3  _S354 = ((((_S353)) * make_float3(rnorm3df(((_S353)).x, ((_S353)).y, ((_S353)).z))));
        return make_float3 (_S354.x) * frame_0.tangent + make_float3 (_S354.y) * cross_0(n_i_1, frame_0.tangent) + make_float3 (_S354.z) * n_i_1;
    }
    float3  _S355 = worldToTangent(v_2, n_i_1);
    float3  _S356 = sampleGGXVNDF(float3 {_S355.x, _S355.z, _S355.y}, alpha_1, _S344.value, _S345.value);
    float3  _S357 = float3 {_S356.x, _S356.z, _S356.y};
    float3  _S358 = tangentToWorld(_S357, n_i_1);
    return _S358;
}

__device__ float3  sampledHalf(float3  in_dir_0, float3  n_4, BSDFMaterial material_1, uint random_state_3, AnisotropicFrame frame_1)
{
    uint state_3 = random_state_3;
    float3  _S359 = negate_0(in_dir_0);
    float _S360 = sign_0(dot_0(n_4, _S359));
    float _S361 = material_1.roughness;
    float3  _S362 = sampleHalfVector(_S359, n_4 * make_float3 (_S360), _S361 * _S361, frame_1, &state_3);
    return _S362;
}

__device__ float3  refractedHalf(float3  in_dir_1, float3  out_dir_0, float3  n_5, float eta_i_0, float eta_o_0)
{
    float3  _S363 = negate_0(in_dir_1);
    float3  _S364 = negate_0(make_float3 (eta_i_0) * _S363 + make_float3 (eta_o_0) * out_dir_0);
    float3  _S365 = ((((_S364)) * make_float3(rnorm3df(((_S364)).x, ((_S364)).y, ((_S364)).z))));
    float _S366 = sign_0(dot_0(n_5, _S363));
    float _S367 = sign_0(dot_0(_S364, n_5 * make_float3 (_S366)));
    return _S365 * make_float3 (_S367);
}

__device__ float3  reflectedHalf(float3  in_dir_2, float3  out_dir_1)
{
    float3  _S368 = negate_0(in_dir_2);
    float3  _S369 = _S368 + out_dir_1;
    float3  _S370 = ((((_S369)) * make_float3(rnorm3df(((_S369)).x, ((_S369)).y, ((_S369)).z))));
    return _S370;
}

static __device__ float3  refract_0(float3  i_5, float3  n_6, float eta_0)
{
    float _S371 = dot_0(n_6, i_5);
    float _S372 = 1.0f - eta_0 * eta_0 * (1.0f - _S371 * _S371);
    if(_S372 < 0.0f)
    {
        return make_float3 (0.0f);
    }
    return make_float3 (eta_0) * i_5 - make_float3 (eta_0 * _S371 + (F32_sqrt((_S372)))) * n_6;
}

__device__ float fresnel(float cos_theta_0, float eta_i_1, float eta_o_1)
{
    float _S373 = (F32_sqrt(((F32_max((0.0f), (1.0f - cos_theta_0 * cos_theta_0))))));
    float _S374 = eta_i_1 / eta_o_1 * _S373;
    bool _S375 = _S374 < 1.0f;
    float kr_0;
    if(_S375)
    {
        float _S376 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S374 * _S374))))));
        float _S377 = eta_o_1 * cos_theta_0;
        float _S378 = eta_i_1 * _S376;
        float _S379 = (_S377 - _S378) / (_S377 + _S378);
        float _S380 = eta_i_1 * cos_theta_0;
        float _S381 = eta_o_1 * _S376;
        float _S382 = (_S380 - _S381) / (_S380 + _S381);
        float _S383 = (_S379 * _S379 + _S382 * _S382) / 2.0f;
        kr_0 = _S383;
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
    float _S384 = (F32_max((w_1.z), (0.0f)));
    return 2.0f * _S384 / (_S384 + length_0(make_float3 (alphas_2.x * w_1.x, alphas_2.y * w_1.y, _S384)));
}

__device__ float anisotropicD(float3  h_0, float2  alphas_3)
{
    float _S385 = alphas_3.x;
    float _S386 = h_0.x / _S385;
    float _S387 = alphas_3.y;
    float _S388 = h_0.y / _S387;
    float _S389 = h_0.z;
    float _S390 = _S386 * _S386 + _S388 * _S388 + _S389 * _S389;
    return 1.0f / (F32_max((3.14159274101257324f * _S385 * _S387 * _S390 * _S390), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ BSDFLobes bsdfLobes(float3  in_dir_3, float3  v_3, float3  n_i_2, float3  ggx_n_0, BSDFMaterial material_2, float eta_i_2, float eta_o_2, AnisotropicFrame frame_2)
{
    float _S391 = dot_0(ggx_n_0, v_3);
    float _S392 = dot_0(n_i_2, ggx_n_0);
    float _S393 = eta_i_2 / eta_o_2;
    float3  _S394 = refract_0(in_dir_3, ggx_n_0, _S393);
    float3  _S395 = ((((_S394)) * make_float3(rnorm3df(((_S394)).x, ((_S394)).y, ((_S394)).z))));
    float _S396 = (F32_min(((F32_sqrt((material_2.specular_level))) * (F32_abs((eta_i_2 - eta_o_2))) / (eta_i_2 + eta_o_2)), (0.9999847412109375f)));
    float _S397 = _S396 * _S396;
    float _S398 = (1.0f + _S396) / (1.0f - _S396);
    float _S399 = (F32_abs((_S391)));
    bool _S400 = eta_i_2 > eta_o_2;
    float sheen_component_0;
    if(_S400)
    {
        sheen_component_0 = _S398;
    }
    else
    {
        sheen_component_0 = 1.0f;
    }
    float toon_component_0;
    if(_S400)
    {
        toon_component_0 = 1.0f;
    }
    else
    {
        toon_component_0 = _S398;
    }
    float _S401 = fresnel(_S399, sheen_component_0, toon_component_0);
    bool _S402 = (eta_i_2 * eta_i_2 * (1.0f - _S391 * _S391)) >= (eta_o_2 * eta_o_2);
    float3  _S403;
    if(_S402)
    {
        _S403 = make_float3 (1.0f);
    }
    else
    {
        float3  _S404 = material_2.specular_tint * make_float3 (_S397);
        _S403 = _S404 + (make_float3 (1.0f) - _S404) * make_float3 (_S401 - _S397) / make_float3 (1.0f - _S397);
    }
    float3  _S405 = make_float3 (1.0f);
    float3  _S406 = make_float3 (0.0f);
    float _S407 = rgb_to_greyscale(material_2.sheen);
    bool _S408 = _S407 > 0.0f;
    float3  sheen_1;
    float3  view_1;
    float3  scale_1;
    if(_S408)
    {
        float _S409 = clamp_1((F32_sqrt(((F32_max((dot_0(n_i_2, v_3)), (0.0f)))))), 0.0f, 1.0f) * 23.0f;
        uint _S410 = (U32_min((uint(_S409)), (22U)));
        float least_0 = (F32_sqrt((0.05000000074505806f)));
        float _S411 = (F32_sqrt((0.10000000149011612f)));
        bool _S412 = (material_2.velvet) > 0.0f;
        float _S413 = _slang_select(_S412, _S411,least_0);
        float _S414 = (clamp_1((F32_sqrt(((F32_max((material_2.sheen_roughness), (0.0f)))))), _S413, 1.0f) - _S413) / (1.0f - _S413) * 23.0f;
        uint _S415 = (U32_min((uint(_S414)), (22U)));
        uint _S416 = _S410 * 24U + _S415;
        float _S417 = _S409 - float(_S410);
        float _S418 = _S414 - float(_S415);
        uint _S419 = _S416 + 24U;
        float a_5 = SHEEN_ALBEDO_0[_S416] + (SHEEN_ALBEDO_0[_S419] - SHEEN_ALBEDO_0[_S416]) * _S417;
        uint _S420 = _S416 + 1U;
        uint _S421 = _S419 + 1U;
        float b_1 = SHEEN_ALBEDO_0[_S420] + (SHEEN_ALBEDO_0[_S421] - SHEEN_ALBEDO_0[_S420]) * _S417;
        float _S422 = (F32_exp((a_5 + (b_1 - a_5) * _S418)));
        if(_S412)
        {
            float a_6 = VELVET_ALBEDO_0[_S416] + (VELVET_ALBEDO_0[_S419] - VELVET_ALBEDO_0[_S416]) * _S417;
            float b_2 = VELVET_ALBEDO_0[_S420] + (VELVET_ALBEDO_0[_S421] - VELVET_ALBEDO_0[_S420]) * _S417;
            float _S423 = a_6 + (b_2 - a_6) * _S418;
            sheen_component_0 = _S423;
        }
        else
        {
            sheen_component_0 = _S422;
        }
        float _S424 = (F32_min((sheen_component_0), (1.0f)));
        float3  _S425 = make_float3 (1.0f) - material_2.sheen * make_float3 (_S424);
        float _S426 = rgb_to_greyscale(material_2.sheen);
        float _S427 = _S426 * _S424;
        float3  _S428 = material_2.sheen / make_float3 ((F32_max((sheen_component_0), (1.0f))));
        sheen_component_0 = _S427;
        sheen_1 = _S428;
        view_1 = v_3;
        scale_1 = _S425;
    }
    else
    {
        sheen_component_0 = 0.0f;
        sheen_1 = _S406;
        view_1 = _S406;
        scale_1 = _S405;
    }
    float _S429 = material_2.toon.x;
    bool _S430 = _S429 < 0.0f;
    float _S431 = (F32_abs((_S429)));
    bool _S432 = _S431 > 0.0f;
    float toon_a_1;
    float toon_s_1;
    float toon_b_1;
    float toon_norm_1;
    float toon_view_1;
    float3  toon_1;
    float3  toon_axis_1;
    bool _S433;
    if(_S432)
    {
        float _S434 = (F32_min((_S431), (1.0f)));
        float3  scale_2 = scale_1 * make_float3 (1.0f - _S434);
        float _S435 = rgb_to_greyscale(material_2.albedo);
        float _S436 = _S434 * _S435;
        float3  _S437 = make_float3 (_S434) * material_2.albedo;
        float toon_a_2 = clamp_1(material_2.toon.y / _S429, 0.00000999999974738f, 1.0f) * 3.14159274101257324f / 2.0f;
        float toon_s_2 = clamp_1(material_2.toon.z / _S429, 0.0f, 1.0f) * 3.14159274101257324f / 2.0f;
        float _S438 = (F32_min((toon_a_2 + toon_s_2), (1.57079637050628662f)));
        if(_S430)
        {
            toon_component_0 = 1.0f - (F32_cos(((F32_min((_S438), (toon_a_2))))));
        }
        else
        {
            float _S439 = (F32_sin(((F32_min((_S438), (toon_a_2))))));
            toon_component_0 = _S439 * _S439 / 2.0f;
        }
        bool _S440 = _S438 > toon_a_2;
        if(_S440)
        {
            _S433 = toon_s_2 > 0.0f;
        }
        else
        {
            _S433 = false;
        }
        if(_S433)
        {
            if(_S430)
            {
                float _S441 = (F32_cos((toon_a_2)));
                float _S442 = (F32_cos((_S438)));
                toon_a_1 = (1.0f + toon_a_2 / toon_s_2) * (_S441 - _S442) - ((F32_sin((_S438))) - _S438 * _S442 - ((F32_sin((toon_a_2))) - toon_a_2 * _S441)) / toon_s_2;
            }
            else
            {
                float _S443 = 2.0f * toon_a_2;
                float _S444 = (F32_cos((_S443)));
                float _S445 = 2.0f * _S438;
                float _S446 = (F32_cos((_S445)));
                toon_a_1 = (1.0f + toon_a_2 / toon_s_2) * (_S444 - _S446) / 4.0f - ((F32_sin((_S445))) / 8.0f - _S438 * _S446 / 4.0f - ((F32_sin((_S443))) / 8.0f - toon_a_2 * _S444 / 4.0f)) / toon_s_2;
            }
            float integral_0 = toon_component_0 + toon_a_1;
            toon_component_0 = integral_0;
        }
        float _S447 = 6.28318548202514648f * toon_component_0;
        float _S448 = dot_0(n_i_2, v_3);
        float _S449 = (F32_acos(((F32_min((_S448), (1.0f))))));
        if(_S449 < toon_a_2)
        {
            toon_component_0 = 1.0f;
        }
        else
        {
            toon_component_0 = (F32_max((1.0f - (_S449 - toon_a_2) / (F32_max((toon_s_2), (0.0000152587890625f)))), (0.0f)));
        }
        if(_S430)
        {
            float3  _S450 = make_float3 (2.0f * _S448) * n_i_2 - v_3;
            float3  _S451 = ((((_S450)) * make_float3(rnorm3df(((_S450)).x, ((_S450)).y, ((_S450)).z))));
            scale_1 = _S451;
        }
        else
        {
            scale_1 = n_i_2;
        }
        float _S452 = toon_component_0;
        toon_component_0 = _S436;
        toon_1 = _S437;
        toon_a_1 = toon_a_2;
        toon_s_1 = toon_s_2;
        toon_b_1 = _S438;
        toon_norm_1 = _S447;
        toon_view_1 = _S452;
        toon_axis_1 = scale_1;
        scale_1 = scale_2;
    }
    else
    {
        toon_component_0 = 0.0f;
        toon_1 = _S406;
        toon_a_1 = 0.0f;
        toon_s_1 = 0.0f;
        toon_b_1 = 0.0f;
        toon_norm_1 = 1.0f;
        toon_view_1 = 0.0f;
        toon_axis_1 = n_i_2;
    }
    float3  _S453 = mix_0(_S403, material_2.albedo, material_2.metallic);
    float3  F_1 = _S453 * scale_1;
    float _S454 = rgb_to_greyscale(F_1);
    float _S455 = 1.0f - material_2.metallic;
    float3  _S456 = make_float3 (1.0f) - _S403;
    float3  _S457 = make_float3 ((1.0f - material_2.transmission) * _S455) * _S456 * scale_1;
    float3  _S458 = make_float3 (material_2.transmission * _S455) * _S456 * scale_1;
    float _S459 = (F32_max((_S454), (0.0f)));
    float _S460 = rgb_to_greyscale(_S457);
    float _S461 = (F32_max((_S460), (0.0f)));
    float _S462 = rgb_to_greyscale(_S458);
    float _S463 = sign_0(length_0(_S395));
    float _S464 = (F32_max((_S462 * _S463), (0.0f)));
    float _S465 = _S459 + _S461 + _S464 + toon_component_0;
    float _S466 = (F32_min((sheen_component_0), (1.0f)));
    bool _S467 = sheen_component_0 > 0.0f;
    if(_S467)
    {
        _S433 = !(_S465 > 0.0f);
    }
    else
    {
        _S433 = false;
    }
    float _S468 = _slang_select(_S433, 1.0f,_S466);
    float _S469 = (1.0f - _S468) / (F32_max((_S465), (0.0000152587890625f)));
    float _S470 = _S461 * _S469;
    float _S471 = _S459 * _S469;
    float _S472 = _S464 * _S469;
    bool _S473 = (frame_2.alphas.x) > 0.0f;
    float visible_1;
    if(_S473)
    {
        float3  _S474 = anisotropicLocal(v_3, frame_2.tangent, n_i_2);
        float _S475 = anisotropicG1(_S474, frame_2.alphas);
        float3  _S476 = anisotropicLocal(ggx_n_0, frame_2.tangent, n_i_2);
        float _S477 = anisotropicD(_S476, frame_2.alphas);
        float _S478 = _S475 * _S477;
        visible_1 = _S478;
    }
    else
    {
        visible_1 = 0.0f;
    }
    return BSDFLobes_x24init_0(_S391, _S392, _S395, F_1, _S454, 1.0f, _S457, _S458, _S470, _S471, _S472, 0.0f, sheen_1, _S468, view_1, frame_2.tangent, frame_2.alphas, visible_1, toon_component_0 * _S469, toon_1, toon_a_1, toon_s_1, toon_b_1, _S430, toon_norm_1, toon_view_1, toon_axis_1);
}

__device__ float translucentShare(BSDFMaterial material_3)
{
    float _S479 = rgb_to_greyscale(material_3.translucent);
    float _S480 = rgb_to_greyscale(material_3.albedo);
    float _S481 = _S479 / (_S480 + _S479);
    bool _S482 = _S479 > 0.0f;
    float _S483 = _slang_select(_S482, _S481,0.0f);
    return _S483;
}

__device__ __forceinline__ float diffusePDF(float n_i_dot_l_0, float l_dot_h_0, float n_i_dot_v_0, float alpha_2, BSDFLobes lobes_0, float eta_i_3, float eta_o_3)
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

__device__ __forceinline__ float3  diffuseBSDF(float3  l_0, float3  n_i_3, float alpha_3, BSDFMaterial material_4, BSDFLobes lobes_1)
{
    bool _S494 = (dot_0(n_i_3, l_0)) < 0.0f;
    float3  _S495 = _slang_select(_S494, material_4.translucent,material_4.albedo);
    float _S496 = 1.0f - lobes_1.translucent_share;
    float _S497 = _slang_select(_S494, lobes_1.translucent_share,_S496);
    float3  _S498 = _S495 / make_float3 (_S497);
    bool _S499 = (lobes_1.translucent_share) > 0.0f;
    float3  _S500 = _slang_select(_S499, _S498,material_4.albedo);
    return lobes_1.diffuse_weight * _S500 / make_float3 (lobes_1.p_diffuse);
}

__device__ float smithG1(float alpha_4, float n_dot_x_0)
{
    float _S501 = alpha_4 * alpha_4;
    float _S502 = 2.0f * n_dot_x_0 / (n_dot_x_0 + (F32_sqrt((_S501 + (1.0f - _S501) * n_dot_x_0 * n_dot_x_0))));
    bool _S503 = alpha_4 > 0.0f;
    float _S504 = _slang_select(_S503, _S502,1.0f);
    return _S504;
}

__device__ float trowbridgeReitz(float alpha_5, float n_dot_h_1)
{
    float _S505 = alpha_5 * alpha_5;
    float _S506 = (1.0f - n_dot_h_1) * (1.0f + n_dot_h_1) + _S505 * n_dot_h_1 * n_dot_h_1;
    return _S505 / (F32_max((3.14159274101257324f * _S506 * _S506), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ float vndfPDF(float n_i_dot_v_1, float alpha_6, BSDFLobes lobes_2)
{
    float _S507 = smithG1(alpha_6, n_i_dot_v_1);
    float _S508 = _S507 * lobes_2.v_dot_h;
    float _S509 = trowbridgeReitz(alpha_6, lobes_2.n_dot_h);
    float _S510 = _S508 * _S509 / n_i_dot_v_1;
    bool _S511 = alpha_6 > 0.0f;
    bool _S512;
    if(_S511)
    {
        _S512 = (lobes_2.v_dot_h) > 0.0f;
    }
    else
    {
        _S512 = false;
    }
    if(_S512)
    {
        _S512 = (lobes_2.n_dot_h) > 0.0f;
    }
    else
    {
        _S512 = false;
    }
    if(_S512)
    {
        _S512 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S512 = false;
    }
    float _S513 = _slang_select(_S512, _S510,0.0f);
    bool _S514 = (lobes_2.alphas.x) > 0.0f;
    float pdf_h_0;
    if(_S514)
    {
        float _S515 = lobes_2.visible * lobes_2.v_dot_h / n_i_dot_v_1;
        bool _S516 = (lobes_2.v_dot_h) > 0.0f;
        if(_S516)
        {
            _S512 = (lobes_2.n_dot_h) > 0.0f;
        }
        else
        {
            _S512 = false;
        }
        if(_S512)
        {
            _S512 = n_i_dot_v_1 > 0.0f;
        }
        else
        {
            _S512 = false;
        }
        float _S517 = _slang_select(_S512, _S515,0.0f);
        pdf_h_0 = _S517;
    }
    else
    {
        pdf_h_0 = _S513;
    }
    return pdf_h_0;
}

__device__ __forceinline__ float refractPDF(float n_i_dot_l_1, float l_dot_h_1, float n_i_dot_v_2, float alpha_7, BSDFLobes lobes_3, float eta_i_4, float eta_o_4)
{
    float _S518 = vndfPDF(n_i_dot_v_2, alpha_7, lobes_3);
    float _S519 = eta_i_4 * lobes_3.v_dot_h + eta_o_4 * l_dot_h_1;
    float _S520 = lobes_3.p_refract * _S518 * eta_o_4 * eta_o_4 * (F32_abs((l_dot_h_1))) / (_S519 * _S519);
    bool _S521 = eta_i_4 != eta_o_4;
    bool _S522;
    if(_S521)
    {
        _S522 = l_dot_h_1 < 0.0f;
    }
    else
    {
        _S522 = false;
    }
    float _S523 = _slang_select(_S522, _S520,0.0f);
    return _S523;
}

__device__ __forceinline__ float3  refractBSDF(float3  l_1, float3  n_i_4, float alpha_8, BSDFMaterial material_5, BSDFLobes lobes_4)
{
    float _S524 = - dot_0(n_i_4, l_1);
    float _S525 = smithG1(alpha_8, (F32_max((_S524), (0.0f))));
    bool _S526 = (lobes_4.alphas.x) > 0.0f;
    float G1_l_0;
    if(_S526)
    {
        float3  _S527 = negate_0(n_i_4);
        float3  _S528 = anisotropicLocal(l_1, lobes_4.tangent, _S527);
        float _S529 = anisotropicG1(_S528, lobes_4.alphas);
        G1_l_0 = _S529;
    }
    else
    {
        G1_l_0 = _S525;
    }
    return lobes_4.refract_weight * make_float3 (G1_l_0) * material_5.albedo / make_float3 (lobes_4.p_refract);
}

__device__ __forceinline__ float sheenVelvetPDF(float n_i_dot_l_2, float l_dot_h_2, float n_i_dot_v_3, float alpha_9, BSDFLobes lobes_5, float eta_i_5, float eta_o_5)
{
    float _S530 = lobes_5.p_sheen_velvet * 0.5f * 0.31830987334251404f;
    bool _S531 = n_i_dot_l_2 > 0.0f;
    bool _S532;
    if(_S531)
    {
        _S532 = n_i_dot_v_3 > 0.0f;
    }
    else
    {
        _S532 = false;
    }
    float _S533 = _slang_select(_S532, _S530,0.0f);
    return _S533;
}

__device__ __forceinline__ float3  sheenVelvetBSDF(float3  l_2, float3  n_i_5, float alpha_10, BSDFMaterial material_6, BSDFLobes lobes_6)
{
    float3  _S534 = l_2 + lobes_6.view;
    float3  _S535 = ((((_S534)) * make_float3(rnorm3df(((_S534)).x, ((_S534)).y, ((_S534)).z))));
    float _S536 = dot_0(n_i_5, _S535);
    float _S537 = (F32_max((dot_0(n_i_5, l_2)), (0.0f)));
    float _S538 = (F32_max((dot_0(n_i_5, lobes_6.view)), (0.0f)));
    float _S539 = 1.0f / (F32_max((material_6.sheen_roughness), (0.05000000074505806f)));
    float _S540 = 1.0f - _S536 * _S536;
    float _S541 = (2.0f + _S539) * (F32_pow(((F32_max((_S540), (0.0f)))), (0.5f * _S539))) * 0.5f * 0.31830987334251404f / (F32_max((4.0f * (_S537 + _S538 - _S537 * _S538)), (0.0000152587890625f)));
    bool _S542 = (material_6.velvet) > 0.0f;
    float f_1;
    if(_S542)
    {
        float _S543 = (F32_max((material_6.sheen_roughness), (0.00999999977648258f)));
        float _S544 = _S543 * _S543;
        float _S545 = (F32_max((_S540), (0.0000152587890625f)));
        float _S546 = (F32_exp((- _S536 * _S536 / (_S545 * _S544)))) / (3.14159274101257324f * _S544 * _S545 * _S545) * (F32_min((1.0f), (2.0f * _S536 * (F32_min((_S537), (_S538))) / (F32_max(((F32_abs((dot_0(_S535, lobes_6.view))))), (0.0000152587890625f)))))) / (F32_max((4.0f * _S537 * _S538), (0.0000152587890625f)));
        f_1 = _S546;
    }
    else
    {
        f_1 = _S541;
    }
    return lobes_6.sheen * make_float3 (f_1 * _S537 * 2.0f * 3.14159274101257324f / lobes_6.p_sheen_velvet);
}

__device__ __forceinline__ float toonPDF(float n_i_dot_l_3, float l_dot_h_3, float n_i_dot_v_4, float alpha_11, BSDFLobes lobes_7, float eta_i_6, float eta_o_6)
{
    float _S547 = _slang_select(lobes_7.toon_glossy, l_dot_h_3,n_i_dot_l_3);
    float _S548 = (F32_acos((clamp_1(_S547, -1.0f, 1.0f))));
    float _S549;
    if(_S548 < (lobes_7.toon_a))
    {
        _S549 = 1.0f;
    }
    else
    {
        _S549 = (F32_max((1.0f - (_S548 - lobes_7.toon_a) / (F32_max((lobes_7.toon_s), (0.0000152587890625f)))), (0.0f)));
    }
    float _S550 = lobes_7.p_toon * _S549;
    float _S551 = _slang_select(lobes_7.toon_glossy, 1.0f,n_i_dot_l_3);
    float _S552 = _S550 * _S551 / lobes_7.toon_norm;
    bool _S553;
    if(lobes_7.toon_glossy)
    {
        _S553 = true;
    }
    else
    {
        _S553 = n_i_dot_l_3 > 0.0f;
    }
    float _S554 = _slang_select(_S553, _S552,0.0f);
    return _S554;
}

__device__ __forceinline__ float3  toonBSDF(float3  l_3, float3  n_i_6, float alpha_12, BSDFMaterial material_7, BSDFLobes lobes_8)
{
    float _S555 = (F32_max((dot_0(n_i_6, l_3)), (0.0f)));
    float _S556 = _slang_select(lobes_8.toon_glossy, _S555,lobes_8.toon_view);
    return lobes_8.toon * make_float3 (_S556) / make_float3 (lobes_8.p_toon);
}

__device__ __forceinline__ float reflectPDF(float n_i_dot_l_4, float l_dot_h_4, float n_i_dot_v_5, float alpha_13, BSDFLobes lobes_9, float eta_i_7, float eta_o_7)
{
    float _S557 = vndfPDF(n_i_dot_v_5, alpha_13, lobes_9);
    float _S558 = lobes_9.p_reflect * _S557 / (4.0f * lobes_9.v_dot_h);
    bool _S559 = _S557 > 0.0f;
    float _S560 = _slang_select(_S559, _S558,0.0f);
    return _S560;
}

__device__ __forceinline__ float3  reflectBSDF(float3  l_4, float3  n_i_7, float alpha_14, BSDFMaterial material_8, BSDFLobes lobes_10)
{
    float _S561 = dot_0(n_i_7, l_4);
    float _S562 = smithG1(alpha_14, (F32_max((_S561), (0.0f))));
    bool _S563 = (lobes_10.alphas.x) > 0.0f;
    float G1_l_1;
    if(_S563)
    {
        float3  _S564 = anisotropicLocal(l_4, lobes_10.tangent, n_i_7);
        float _S565 = anisotropicG1(_S564, lobes_10.alphas);
        G1_l_1 = _S565;
    }
    else
    {
        G1_l_1 = _S562;
    }
    return make_float3 (lobes_10.reflect_weight * G1_l_1) * lobes_10.F / make_float3 (lobes_10.p_reflect);
}

__device__ __forceinline__ float3  misWeighted(float3  throughput_0, float lobe_pdf_0, float pdf_0, bool power_0)
{
    if(power_0)
    {
        float _S566 = lobe_pdf_0 / pdf_0;
        return throughput_0 * make_float3 (lobe_pdf_0) / make_float3 (pdf_0 * (1.0f + _S566 * _S566));
    }
    return throughput_0 * make_float3 (lobe_pdf_0) / make_float3 (lobe_pdf_0 + pdf_0);
}

static __device__ float3  neeLobes_0(float3  in_dir_4, float3  dir_3, float3  n_7, BSDFMaterial * material_9, float eta_i_8, float eta_o_8, bool refracted_2, float pdf_1, bool power_1, uint random_state_4, FixedArray<float3 , 5>  * each_0, uint * reached_0)
{
    float3  _S567 = negate_0(in_dir_4);
    float _S568 = dot_0(n_7, _S567);
    float _S569 = sign_0(_S568);
    float3  _S570 = n_7 * make_float3 (_S569);
    AnisotropicFrame _S571 = anisotropicFrame(*material_9, _S570);
    float _S572 = dot_0(_S570, dir_3);
    float _S573 = material_9->roughness * material_9->roughness;
    float3  _S574 = make_float3 (0.0f);
    *reached_0 = 0U;
    BSDFLobes _S575 = BSDFLobes_x24init_0(0.0f, 0.0f, _S574, _S574, 0.0f, 0.0f, _S574, _S574, 0.0f, 0.0f, 0.0f, 0.0f, _S574, 0.0f, _S574, _S574, make_float2 (0.0f), 0.0f, 0.0f, _S574, 0.0f, 0.0f, 0.0f, false, 1.0f, 0.0f, _S574);
    BSDFLobes lobe_terms_0 = _S575;
    uint _S576;
    if((F32_abs((material_9->toon.x))) > 0.0f)
    {
        _S576 = 5U;
    }
    else
    {
        _S576 = 4U;
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
        (*each_0)[i_6] = _S574;
        uint i_7 = i_6 + 1U;
        i_6 = i_7;
    }
    uint half_of_0 = 4294967295U;
    float3  ggx_n_1 = _S574;
    i_6 = 0U;
    float3  f_2 = _S574;
    for(;;)
    {
        if(i_6 < _S576)
        {
        }
        else
        {
            break;
        }
        uint _S577;
        if(i_6 == 3U)
        {
            _S577 = 4U;
        }
        else
        {
            if(i_6 == 4U)
            {
                _S577 = 6U;
            }
            else
            {
                _S577 = i_6;
            }
        }
        bool _S578 = _S577 == 0U;
        if(_S578)
        {
        }
        bool _S579;
        if(_S578)
        {
            float _S580 = rgb_to_greyscale(material_9->translucent);
            _S579 = _S580 > 0.0f;
        }
        else
        {
            _S579 = false;
        }
        bool _S581;
        if(_S579)
        {
            float _S582 = dot_0(n_7, dir_3);
            float3  _S583 = negate_0(in_dir_4);
            _S581 = ((_S582 * dot_0(n_7, _S583)) < 0.0f) == refracted_2;
        }
        else
        {
            _S581 = (_S577 == 1U) == refracted_2;
        }
        float3  ggx_n_2;
        if(_S581)
        {
            uint _S584;
            if(_S577 == 6U)
            {
                _S584 = 0U;
            }
            else
            {
                if(_S577 == 4U)
                {
                    _S584 = 2U;
                }
                else
                {
                    _S584 = _S577;
                }
            }
            bool _S585 = _S584 != half_of_0;
            uint half_of_1;
            if(_S585)
            {
                bool _S586 = _S584 == 0U;
                if(_S586)
                {
                    float3  _S587 = sampledHalf(in_dir_4, n_7, *material_9, random_state_4, _S571);
                    ggx_n_2 = _S587;
                }
                else
                {
                    bool _S588 = _S584 == 1U;
                    if(_S588)
                    {
                        float3  _S589 = refractedHalf(in_dir_4, dir_3, n_7, eta_i_8, eta_o_8);
                        ggx_n_2 = _S589;
                    }
                    else
                    {
                        float3  _S590 = reflectedHalf(in_dir_4, dir_3);
                        ggx_n_2 = _S590;
                    }
                }
                float3  _S591 = negate_0(in_dir_4);
                BSDFLobes _S592 = bsdfLobes(in_dir_4, _S591, _S570, ggx_n_2, *material_9, eta_i_8, eta_o_8, _S571);
                lobe_terms_0 = _S592;
                float _S593 = translucentShare(*material_9);
                (&lobe_terms_0)->translucent_share = _S593;
                half_of_1 = _S584;
            }
            else
            {
                ggx_n_2 = ggx_n_1;
                half_of_1 = half_of_0;
            }
            float3  throughput_1;
            float lobe_pdf_1;
            switch(_S577)
            {
            case 0U:
                {
                    float _S594 = diffusePDF(_S572, 0.0f, (F32_abs((_S568))), _S573, lobe_terms_0, eta_i_8, eta_o_8);
                    float3  _S595 = diffuseBSDF(dir_3, _S570, _S573, *material_9, lobe_terms_0);
                    lobe_pdf_1 = _S594;
                    throughput_1 = _S595;
                    break;
                }
            case 1U:
                {
                    float _S596 = refractPDF(_S572, dot_0(dir_3, ggx_n_2), (F32_abs((_S568))), _S573, lobe_terms_0, eta_i_8, eta_o_8);
                    float3  _S597 = refractBSDF(dir_3, _S570, _S573, *material_9, lobe_terms_0);
                    lobe_pdf_1 = _S596;
                    throughput_1 = _S597;
                    break;
                }
            case 4U:
                {
                    float _S598 = sheenVelvetPDF(_S572, 0.0f, (F32_abs((_S568))), _S573, lobe_terms_0, eta_i_8, eta_o_8);
                    float3  _S599 = sheenVelvetBSDF(dir_3, _S570, _S573, *material_9, lobe_terms_0);
                    lobe_pdf_1 = _S598;
                    throughput_1 = _S599;
                    break;
                }
            case 6U:
                {
                    float _S600 = toonPDF(_S572, dot_0(dir_3, (&lobe_terms_0)->toon_axis), (F32_abs((_S568))), _S573, lobe_terms_0, eta_i_8, eta_o_8);
                    float3  _S601 = toonBSDF(dir_3, _S570, _S573, *material_9, lobe_terms_0);
                    lobe_pdf_1 = _S600;
                    throughput_1 = _S601;
                    break;
                }
            default:
                {
                    float _S602 = reflectPDF(_S572, 0.0f, (F32_abs((_S568))), _S573, lobe_terms_0, eta_i_8, eta_o_8);
                    float3  _S603 = reflectBSDF(dir_3, _S570, _S573, *material_9, lobe_terms_0);
                    lobe_pdf_1 = _S602;
                    throughput_1 = _S603;
                    break;
                }
            }
            bool _S604 = lobe_pdf_1 > 0.0f;
            float3  f_3;
            if(_S604)
            {
                float3  _S605 = misWeighted(throughput_1, lobe_pdf_1, pdf_1, power_1);
                (*each_0)[i_6] = _S605;
                uint _S606 = (*reached_0) | (1U << i_6);
                *reached_0 = _S606;
                float3  f_4 = f_2 + (*each_0)[i_6];
                f_3 = f_4;
            }
            else
            {
                f_3 = f_2;
            }
            half_of_0 = half_of_1;
            f_2 = f_3;
        }
        else
        {
            ggx_n_2 = ggx_n_1;
        }
        uint i_8 = i_6 + 1U;
        ggx_n_1 = ggx_n_2;
        i_6 = i_8;
    }
    return f_2;
}

__device__ __forceinline__ float3  neeBSDF(float3  in_dir_5, float3  dir_4, float3  n_8, BSDFMaterial material_10, float eta_i_9, float eta_o_9, bool refracted_3, float pdf_2, bool power_2, uint random_state_5)
{
    uint reached_1 = 0U;
    BSDFMaterial _S607 = material_10;
    FixedArray<float3 , 5>  each_1;
    float3  _S608 = neeLobes_0(in_dir_5, dir_4, n_8, &_S607, eta_i_9, eta_o_9, refracted_3, pdf_2, power_2, random_state_5, &each_1, &reached_1);
    return _S608;
}

__device__ float3  skyBSDF(float3  in_dir_6, float3  dir_5, FKSurface surface_1, float2  eta_1, bool is_inside_2, float pdf_3, uint random_state_6)
{
    bool _S609 = wrongSide_0(is_inside_2, false, dir_5, surface_1.geometry_n);
    float3  _S610 = neeBSDF(in_dir_6, dir_5, surface_1.smooth_n, surface_1.material, eta_1.x, eta_1.y, _S609, pdf_3, false, random_state_6);
    return _S610;
}

static __device__ SkySample SkySample_x24init_0(float3  dir_6, float3  radiance_0, float3  color_0, uint random_state_7)
{
    SkySample _S611;
    (&_S611)->dir = dir_6;
    (&_S611)->radiance = radiance_0;
    (&_S611)->color = color_0;
    (&_S611)->random_state = random_state_7;
    return _S611;
}

static __device__ SkySample sampleSky_0(FKRay * ray_0, FKSurface * surface_2, float2  eta_2, bool is_inside_3, uint init_random_state_0, uint lobe_state_0, ShadowContext * context_2)
{
    uint2  _S612 = (fcptEnvironmentCdfSize());
    uint2  _S613 = make_uint2 (1U, 0U);
    uint2  _S614 = _S612 - _S613;
    Random _S615 = pcg(init_random_state_0);
    Random _S616 = pcg(_S615.state);
    Random _S617 = pcg(_S616.state);
    Random _S618 = pcg(_S617.state);
    uint _S619 = _S614.x;
    uint _S620 = searchCDF_0(make_uint2 (_S619, 0U), make_uint2 (0U, 1U), _S614.y, _S615.value);
    uint _S621 = searchCDF_0(make_uint2 (0U, _S620), _S613, _S619, _S616.value);
    float2  _S622 = make_float2 ((float)_S614.x, (float)_S614.y);
    float2  _S623 = (make_float2 (float(_S621), float(_S620)) + make_float2 (_S617.value, _S618.value)) / _S622 * make_float2 (6.28318548202514648f, 3.14159274101257324f);
    float _S624 = _S623.y;
    float _S625 = (F32_sin((_S624)));
    float _S626 = _S623.x;
    float3  _S627 = make_float3 (- _S625 * (F32_cos((_S626))), _S625 * (F32_sin((_S626))), (F32_cos((_S624))));
    float _S628 = environmentPdf_0(_S627);
    float3  _S629 = skyBSDF(ray_0->unit_direction, _S627, *surface_2, eta_2, is_inside_3, _S628, lobe_state_0);
    bool _S630 = !(_S628 > 0.0f);
    bool _S631;
    if(_S630)
    {
        _S631 = true;
    }
    else
    {
        _S631 = all_1(_S629 == make_float3 (0.0f));
    }
    if(_S631)
    {
        float3  _S632 = make_float3 (0.0f);
        return SkySample_x24init_0(_S627, _S632, _S632, _S618.state);
    }
    float3  _S633 = skyRadiance_0(ray_0->origin, surface_2, is_inside_3, _S627, context_2, _S618.state);
    return SkySample_x24init_0(_S627, _S633, _S629 * _S633, _S618.state);
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

static __device__ float3  hairLight_0(FKSurface * surface_3, float3  in_dir_7, TreeSample * light_1, bool competing_0)
{
    SampleBSDF _S634 = (fcptConnectHair((surface_3->hair), ((&surface_3->material)->albedo), ((&surface_3->material)->specular_tint), (in_dir_7), (light_1->dir)));
    float3  _S635 = _S634.throughput * make_float3 (_S634.pdf);
    float _S636 = light_1->density;
    float _S637 = 1.0f + _S634.pdf * _S634.pdf / (light_1->density * light_1->density);
    bool _S638;
    if(competing_0)
    {
        _S638 = _S636 > 0.0f;
    }
    else
    {
        _S638 = false;
    }
    float _S639 = _slang_select(_S638, _S637,1.0f);
    return _S635 / make_float3 (_S639) * light_1->radiance;
}

static __device__ TreeSample TreeSample_x24init_0(float3  dir_7, float3  radiance_1, float density_0, uint random_state_8)
{
    TreeSample _S640;
    (&_S640)->dir = dir_7;
    (&_S640)->radiance = radiance_1;
    (&_S640)->density = density_0;
    (&_S640)->random_state = random_state_8;
    return _S640;
}

__device__ uint pickChild(LightNode first_1, LightNode second_1, float3  p_10, float3  normal_3, float * pick_0, float * probability_3)
{
    float _S641 = importance(first_1, p_10, normal_3);
    float _S642 = importance(second_1, p_10, normal_3);
    float2  _S643 = make_float2 (_S641, _S642);
    bool _S644 = _S641 == 0.0f;
    bool _S645;
    if(_S644)
    {
        _S645 = _S642 == 0.0f;
    }
    else
    {
        _S645 = false;
    }
    if(_S645)
    {
        return 2U;
    }
    float _S646 = _S641 + _S642;
    bool _S647 = _S642 > 0.0f;
    if(_S647)
    {
        _S645 = (*pick_0 * _S646) >= _S641;
    }
    else
    {
        _S645 = false;
    }
    uint _S648 = uint(_S645);
    float _S649 = (F32_min(((*pick_0 * _S646 - float(_S648) * _S641) / _slang_vector_get_element(_S643, _S648)), (0.99999994039535522f)));
    *pick_0 = _S649;
    float _S650 = *probability_3 * (_slang_vector_get_element(_S643, _S648) / _S646);
    *probability_3 = _S650;
    return _S648;
}

__device__ float3  sampleSphere(float3  center_1, float radius_1, float3  p_11, float u1_0, float u2_0)
{
    float3  _S651 = center_1 - p_11;
    float _S652 = radius_1 * radius_1 / dot_0(_S651, _S651);
    float _S653 = u1_0 * _S652 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S652), (0.0f)))))));
    float _S654 = 2.0f * u1_0;
    bool _S655 = _S652 >= 1.0f;
    float _S656 = _slang_select(_S655, _S654,_S653);
    float _S657 = (F32_sqrt(((F32_max((_S656 * (2.0f - _S656)), (0.0f))))));
    float _S658 = 6.28318548202514648f * u2_0;
    float3  _S659 = make_float3 (_S657 * (F32_cos((_S658))), 1.0f - _S656, _S657 * (F32_sin((_S658))));
    float3  _S660 = ((((_S651)) * make_float3(rnorm3df(((_S651)).x, ((_S651)).y, ((_S651)).z))));
    float3  _S661 = tangentToWorld(_S659, _S660);
    return _S661;
}

__device__ float3  pointLightRadiance(float3  color_1, float intensity_0, float radius_2)
{
    return color_1 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_2 * radius_2);
}

static __device__ float raySphere_0(float3  center_2, float radius_3, FKRay * ray_1, float max_len_0)
{
    float3  _S662 = center_2 - ray_1->origin;
    float _S663 = dot_0(_S662, ray_1->unit_direction);
    float _S664 = dot_0(_S662, _S662) - _S663 * _S663;
    float _S665 = radius_3 * radius_3;
    bool _S666 = _S664 > _S665;
    if(_S666)
    {
        return 4.294967296e+09f;
    }
    float _S667 = (F32_sqrt((_S665 - _S664)));
    float _S668 = _S663 - _S667;
    float _S669 = _S663 + _S667;
    bool _S670 = _S668 > 0.0000152587890625f;
    bool _S671;
    if(_S670)
    {
        _S671 = _S668 < max_len_0;
    }
    else
    {
        _S671 = false;
    }
    if(_S671)
    {
        return _S668;
    }
    bool _S672 = _S669 > 0.0000152587890625f;
    if(_S672)
    {
        _S671 = _S669 < max_len_0;
    }
    else
    {
        _S671 = false;
    }
    if(_S671)
    {
        return _S669;
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
        int i_9 = int(0);
        float sum_0 = 0.0f;
        for(;;)
        {
            if(i_9 < int(3))
            {
            }
            else
            {
                break;
            }
            float sum_1 = sum_0 + _slang_vector_get_element(left_1, i_9) * _slang_vector_get_element(right_1.rows[i_9], j_1);
            i_9 = i_9 + int(1);
            sum_0 = sum_1;
        }
        *_slang_vector_get_element_ptr(&result_5, j_1) = sum_0;
        j_1 = j_1 + int(1);
    }
    return result_5;
}

static __device__ __forceinline__ TreeSample sampleLightTree_0(float3  origin_4, float3  smooth_n_2, float3  geometry_n_1, float geometry_offset_1, bool sided_0, uint init_random_state_1, ShadowContext * context_3)
{
    Random _S673 = pcg(init_random_state_1);
    Random _S674 = pcg(_S673.state);
    Random _S675 = pcg(_S674.state);
    float3  _S676 = make_float3 (0.0f);
    TreeSample _S677 = TreeSample_x24init_0(_S676, _S676, 0.0f, _S675.state);
    TreeSample sample_0 = _S677;
    float3  _S678 = _slang_select(sided_0, _S676,smooth_n_2);
    float3  _S679 = origin_4 + make_float3 (geometry_offset_1) * smooth_n_2;
    float pick_1 = _S673.value;
    float probability_4 = 1.0f;
    uint n_9 = 0U;
    for(;;)
    {
        uint4  _S680 = (fcptLightNode((n_9)));
        if((_S680.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S681 = (fcptLightSecond((n_9)));
        uint _S682 = n_9 + 1U;
        LightNode _S683 = (fcptLightBounds((_S682)));
        LightNode _S684 = (fcptLightBounds((_S681)));
        uint _S685 = pickChild(_S683, _S684, origin_4, _S678, &pick_1, &probability_4);
        bool _S686 = _S685 > 1U;
        if(_S686)
        {
            return sample_0;
        }
        bool _S687 = _S685 == 1U;
        uint _S688 = _slang_select(_S687, _S681,_S682);
        n_9 = _S688;
    }
    bool _S689 = n_9 == 0U;
    bool _S690;
    if(_S689)
    {
        LightNode _S691 = (fcptLightBounds((0U)));
        float _S692 = importance(_S691, origin_4, _S678);
        _S690 = !(_S692 > 0.0f);
    }
    else
    {
        _S690 = false;
    }
    if(_S690)
    {
        return sample_0;
    }
    uint4  _S693 = (fcptLightNode((n_9)));
    FKHit _S694 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    bool _S695 = (_S693.x) == 2U;
    float3  emitter_point_0;
    float3  lift_n_0;
    float3  shadow_1;
    FKHit emitter_0;
    if(_S695)
    {
        FKLight _S696 = (fcptLight((_S693.y)));
        if(sided_0)
        {
            float _S697 = sign_0(dot_0(geometry_n_1, _S696.position - origin_4));
            float3  lift_n_1 = smooth_n_2 * make_float3 (_S697);
            float3  _S698 = origin_4 + make_float3 (geometry_offset_1) * lift_n_1;
            emitter_point_0 = _S698;
            lift_n_0 = lift_n_1;
        }
        else
        {
            emitter_point_0 = _S679;
            lift_n_0 = smooth_n_2;
        }
        bool _S699 = (_S696.variance) == 0.0f;
        if(_S699)
        {
            float3  _S700 = _S696.position - emitter_point_0;
            float3  _S701 = ((((_S700)) * make_float3(rnorm3df(((_S700)).x, ((_S700)).y, ((_S700)).z))));
            (&sample_0)->dir = _S701;
            float3  _S702 = _S696.color * make_float3 (_S696.intensity) / make_float3 (dot_0(_S700, _S700) * probability_4);
            (&sample_0)->radiance = _S702;
            shadow_1 = _S700;
        }
        else
        {
            float3  _S703 = sampleSphere(_S696.position, _S696.variance, emitter_point_0, _S674.value, _S675.value);
            (&sample_0)->dir = _S703;
            float _S704 = sphereDensity(_S696.position, _S696.variance, emitter_point_0);
            float _S705 = probability_4 * _S704;
            (&sample_0)->density = _S705;
            float3  _S706 = pointLightRadiance(_S696.color, _S696.intensity, _S696.variance);
            float3  _S707 = _S706 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S707;
            FKRay _S708 = Ray_x24init_0(emitter_point_0, (&sample_0)->dir);
            float _S709 = raySphere_0(_S696.position, _S696.variance, &_S708, 4.294967296e+09f);
            float3  _S710 = (&sample_0)->dir * make_float3 (_S709);
            shadow_1 = _S710;
        }
        emitter_0 = _S694;
        emitter_point_0 = _S676;
    }
    else
    {
        uint _S711 = _S693.y;
        uint _S712 = (fcptTriangleOffset((_S711)));
        uint _S713 = _S712 + _S693.z;
        Matrix<float, 3, 3>  _S714 = (fcptWorldTriangle((_S711), (_S713)));
        float _S715 = (F32_sqrt((_S674.value)));
        float2  _S716 = make_float2 (_S715 * (1.0f - _S675.value), _S715 * _S675.value);
        float3  _S717 = mul_0(make_float3 (1.0f - _S715, _S716.x, _S716.y), _S714);
        if(sided_0)
        {
            float _S718 = sign_0(dot_0(geometry_n_1, _S717 - origin_4));
            float3  lift_n_2 = smooth_n_2 * make_float3 (_S718);
            float3  _S719 = origin_4 + make_float3 (geometry_offset_1) * lift_n_2;
            emitter_point_0 = _S719;
            lift_n_0 = lift_n_2;
        }
        else
        {
            bool _S720 = !((dot_0(smooth_n_2, _S717 - origin_4)) > 0.0f);
            if(_S720)
            {
                return sample_0;
            }
            emitter_point_0 = _S679;
            lift_n_0 = smooth_n_2;
        }
        FKHit emitter_1 = Hit_x24init_0(_S716, _S711, _S713, 0U, 0.0f);
        float3  _S721 = _S717 - emitter_point_0;
        float3  _S722 = ((((_S721)) * make_float3(rnorm3df(((_S721)).x, ((_S721)).y, ((_S721)).z))));
        (&sample_0)->dir = _S722;
        float _S723 = solidAngle(probability_4, cross_0(_S714.rows[int(1)] - _S714.rows[int(0)], _S714.rows[int(2)] - _S714.rows[int(0)]), _S721);
        (&sample_0)->density = _S723;
        bool _S724 = (fcptShadowFirst());
        bool _S725 = !_S724;
        if(_S725)
        {
            FKSurface _S726 = (fcptLightSurfaceAt((emitter_1), (_S717), (_S675.state), ((&sample_0)->dir), (context_3->depth), (length_0(_S717 - origin_4))));
            (&sample_0)->random_state = _S726.random_state;
            float3  _S727 = _slang_select(_S726.skip, _S676,_S726.material.emissive);
            float3  _S728 = _S727 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S728;
        }
        shadow_1 = _S721;
        emitter_0 = emitter_1;
        emitter_point_0 = _S717;
    }
    FKHit _S729 = emitter_0;
    float3  _S730 = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, context_3, _S675.state, &_S729);
    bool _S731 = (fcptShadowFirst());
    if(_S731)
    {
        _S690 = (emitter_0.instance_index) != 4294967295U;
    }
    else
    {
        _S690 = false;
    }
    if(_S690)
    {
        _S690 = !all_1(_S730 == _S676);
    }
    else
    {
        _S690 = false;
    }
    if(_S690)
    {
        FKSurface _S732 = (fcptLightSurfaceAt((emitter_0), (emitter_point_0), (_S675.state), ((&sample_0)->dir), (context_3->depth), (length_0(emitter_point_0 - origin_4))));
        (&sample_0)->random_state = _S732.random_state;
        float3  _S733 = _slang_select(_S732.skip, _S676,_S732.material.emissive);
        float3  _S734 = _S733 / make_float3 ((&sample_0)->density);
        (&sample_0)->radiance = _S734;
    }
    float3  _S735 = (&sample_0)->radiance * _S730;
    bool _S736 = all_1(_S730 == _S676);
    float3  _S737 = _slang_select(_S736, _S676,_S735);
    (&sample_0)->radiance = _S737;
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
    float _S738 = 1.0f / (1.0f + b_3 / a_7 * (b_3 / a_7));
    bool _S739 = b_3 > 0.0f;
    float _S740 = _slang_select(_S739, _S738,1.0f);
    return _S740;
}

static __device__ float emissionWeight_0(NEEVertex * vertex_0, FKHit * hit_1, float3  light_point_1)
{
    bool _S741 = vertex_0->none;
    if(_S741)
    {
        return 1.0f;
    }
    uint _S742 = (fcptLightSlot((*hit_1)));
    float _S743 = lightPdf_0(vertex_0->origin, vertex_0->smooth_n, vertex_0->start, _S742, light_point_1);
    float _S744 = powerHeuristic(vertex_0->pdf, _S743);
    return _S744;
}

static __device__ float3  environment_0(float3  dir_8, uint depth_0, uint lobe_0)
{
    uint2  _S745 = (fcptEnvironmentMapSize());
    bool _S746 = (_S745.x) > 1U;
    bool _S747;
    if(_S746)
    {
        uint2  _S748 = (fcptEnvironmentMapSize());
        _S747 = (_S748.y) > 1U;
    }
    else
    {
        _S747 = false;
    }
    if(_S747)
    {
        float3  _S749 = (fcptEnvMapSample((dir_8), (depth_0), (lobe_0)));
        return _S749;
    }
    float3  _S750 = (fcptAmbient());
    return _S750;
}

static __device__ bool environmentMapped_0()
{
    uint2  _S751 = (fcptEnvironmentCdfSize());
    bool _S752 = (_S751.x) > 1U;
    bool _S753;
    if(_S752)
    {
        uint2  _S754 = (fcptEnvironmentCdfSize());
        _S753 = (_S754.y) > 1U;
    }
    else
    {
        _S753 = false;
    }
    bool _S755 = !_S753;
    if(_S755)
    {
        return false;
    }
    uint2  _S756 = (fcptEnvironmentMapSize());
    bool _S757 = (_S756.x) > 1U;
    if(_S757)
    {
        uint2  _S758 = (fcptEnvironmentMapSize());
        _S753 = (_S758.y) > 1U;
    }
    else
    {
        _S753 = false;
    }
    return _S753;
}

static __device__ float escapeWeight_0(float pdf_4, float3  dir_9)
{
    bool _S759 = pdf_4 <= 0.0f;
    bool _S760;
    if(_S759)
    {
        _S760 = true;
    }
    else
    {
        bool _S761 = environmentMapped_0();
        _S760 = !_S761;
    }
    if(_S760)
    {
        return 1.0f;
    }
    float _S762 = environmentPdf_0(dir_9);
    return pdf_4 / (pdf_4 + _S762);
}

static __device__ float3  min_1(float3  x_15, float3  y_4)
{
    float3  result_6;
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
        *_slang_vector_get_element_ptr(&result_6, i_10) = (F32_min((_slang_vector_get_element(x_15, i_10)), (_slang_vector_get_element(y_4, i_10))));
        i_10 = i_10 + int(1);
    }
    return result_6;
}

static __device__ void restir_duplicates_0(uint3  global_invocation_id_1, uint3  local_invocation_id_0, uint local_invocation_index_3)
{
    uint2  _S763 = uint2 {global_invocation_id_1.x, global_invocation_id_1.y};
    int2  _S764 = make_int2 ((int)_S763.x, (int)_S763.y);
    uint _S765 = previousSeed_0(_S764);
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
            uint _S766 = previousSeed_0(_S764 + make_int2 (x_16, y_5));
            bool _S767 = _S766 == _S765;
            uint _S768 = _slang_select(_S767, 1U,0U);
            uint count_3 = count_2 + _S768;
            int x_17 = x_16 + int(1);
            x_16 = x_17;
            count_2 = count_3;
        }
        int y_6 = y_5 + int(1);
        y_5 = y_6;
    }
    float _S769 = float(count_2 - 1U) / 288.0f;
    bool _S770 = _S765 != 0U;
    float _S771 = _slang_select(_S770, _S769,0.0f);
    fcptStoreDuplication((_S764), (make_uint4 ((F32_asuint((_S771))), 0U, 0U, 0U)));
    return;
}

__device__ uint stream(uint seed_2, uint index_0)
{
    uint _S772 = hash(index_0);
    uint _S773 = hash(seed_2 ^ _S772);
    return _S773;
}

static __device__ float4  asfloat_0(uint4  x_18)
{
    float4  result_7;
    int i_11 = int(0);
    for(;;)
    {
        if(i_11 < int(4))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_7, i_11) = (U32_asfloat((_slang_vector_get_element(x_18, i_11))));
        i_11 = i_11 + int(1);
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
    float _S774 = rgb_to_greyscale(weight_0);
    bool _S775 = _S774 > 0.0f;
    bool _S776;
    if(_S775)
    {
        _S776 = _S774 < 3.00000000549775576e+38f;
    }
    else
    {
        _S776 = false;
    }
    bool _S777 = !_S776;
    if(_S777)
    {
        return;
    }
    bool _S778 = sel_2->sums;
    if(_S778)
    {
        float3  _S779 = sel_2->color + weight_0;
        sel_2->color = _S779;
        return;
    }
    float _S780 = sel_2->w_sum + _S774;
    sel_2->w_sum = _S780;
    float3  _S781 = sel_2->color + weight_0;
    sel_2->color = _S781;
    Random _S782 = pcg(sel_2->random_state);
    sel_2->random_state = _S782.state;
    bool _S783 = (_S782.value * sel_2->w_sum) <= _S774;
    if(_S783)
    {
        sel_2->r = candidate_0;
    }
    return;
}

__device__ void offerShifted(Selection * sel_3, Reservoir r_3, Shift shifted_0, float mis_0)
{
    Reservoir candidate_1 = r_3;
    float3  _S784 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_1)->f = _S784;
    float _S785 = r_3.jac * shifted_0.jac;
    (&candidate_1)->jac = _S785;
    offer(sel_3, candidate_1, make_float3 (mis_0) * shifted_0.f * make_float3 (r_3.w));
    return;
}

__device__ Reservoir finalize(Selection sel_4, float c_1)
{
    Reservoir r_4 = sel_4.r;
    float _S786 = rgb_to_greyscale((&r_4)->f);
    float _S787 = sel_4.w_sum / _S786;
    bool _S788 = _S786 > 0.0f;
    float _S789 = _slang_select(_S788, _S787,0.0f);
    (&r_4)->w = _S789;
    (&r_4)->c = c_1;
    return r_4;
}

static __device__ uint2  asuint_0(float2  x_19)
{
    uint2  result_8;
    int i_12 = int(0);
    for(;;)
    {
        if(i_12 < int(2))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_8, i_12) = (F32_asuint((_slang_vector_get_element(x_19, i_12))));
        i_12 = i_12 + int(1);
    }
    return result_8;
}

static __device__ void restir_spatial_0(uint3  global_invocation_id_2)
{
    uint2  _S790 = uint2 {global_invocation_id_2.x, global_invocation_id_2.y};
    int2  _S791 = make_int2 ((int)_S790.x, (int)_S790.y);
    float3  _S792 = make_float3 (0.0f);
    FKHit _S793 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S794 = Domain_x24init_0(_S792, _S792, &_S793, 0.0f, 0.0f);
    Domain dom_4 = _S794;
    bool _S795 = (fcptCurrentDomain((_S791), (&dom_4)));
    bool _S796 = !_S795;
    if(_S796)
    {
        Reservoir _S797 = (Reservoir{});
        fcptStoreReservoirPrevious((_S791), (_S797), ((&dom_4)->hit));
        return;
    }
    Reservoir _S798 = (fcptLoadReservoirTemporal((_S791)));
    uint t_13 = 0U;
    float count_4 = 0.0f;
    float c_sum_1 = _S798.c;
    for(;;)
    {
        uint _S799 = (fcptRestirNeighbours());
        if(t_13 < _S799)
        {
        }
        else
        {
            break;
        }
        int2  _S800 = partner_0(_S791, t_13);
        Domain neighbor_0 = _S794;
        bool _S801 = (fcptCurrentDomain((_S800), (&neighbor_0)));
        if(_S801)
        {
            float count_5 = count_4 + 1.0f;
            uint4  _S802 = (fcptReservoirTemporal((_S800), (0U)));
            float c_sum_2 = c_sum_1 + (U32_asfloat((_S802.w)));
            count_4 = count_5;
            c_sum_1 = c_sum_2;
        }
        uint t_14 = t_13 + 1U;
        t_13 = t_14;
    }
    float _S803 = _S798.c / (F32_max((count_4), (1.0f)));
    float _S804 = rgb_to_greyscale(_S798.f);
    bool _S805 = count_4 == 0.0f;
    float _S806 = _slang_select(_S805, 1.0f,0.0f);
    Selection _S807 = (Selection{});
    Selection sel_5 = _S807;
    uint _S808 = (fcptFrame());
    uint _S809 = hash(_S808);
    uint _S810 = global_invocation_id_2.x;
    uint2  _S811 = (fcptRenderSize());
    uint _S812 = stream(_S809, _S810 + _S811.x * global_invocation_id_2.y);
    uint _S813 = stream(_S812, 195U);
    (&sel_5)->random_state = _S813;
    t_13 = 0U;
    float canonical_mis_0 = _S806;
    for(;;)
    {
        uint _S814 = (fcptRestirNeighbours());
        if(t_13 < _S814)
        {
        }
        else
        {
            break;
        }
        int2  _S815 = partner_0(_S791, t_13);
        Domain neighbor_dom_0 = _S794;
        bool _S816 = (fcptCurrentDomain((_S815), (&neighbor_dom_0)));
        if(_S816)
        {
            Reservoir _S817 = (fcptLoadReservoirTemporal((_S815)));
            uint4  _S818 = (fcptShiftData((_S815), (t_13)));
            float4  _S819 = asfloat_0(_S818);
            uint4  _S820 = (fcptShiftData((_S791), (t_13)));
            float4  _S821 = asfloat_0(_S820);
            float _S822 = pairShare(_S817.c, _S803, c_sum_1);
            bool _S823 = _S804 > 0.0f;
            float canonical_mis_1;
            if(_S823)
            {
                float _S824 = rgb_to_greyscale(float3 {_S821.x, _S821.y, _S821.z});
                float _S825 = canonicalWeight(_S822, _S803, _S804, _S817.c, _S824);
                float canonical_mis_2 = canonical_mis_0 + _S825;
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            float3  _S826 = float3 {_S819.x, _S819.y, _S819.z};
            Shift _S827 = Shift_x24init_0(_S826, _S819.w);
            float _S828 = rgb_to_greyscale(_S817.f);
            float _S829 = rgb_to_greyscale(_S826);
            float _S830 = neighborWeight(_S822, _S817.c, _S828, _S803, _S829);
            offerShifted(&sel_5, _S817, _S827, _S830);
            canonical_mis_0 = canonical_mis_1;
        }
        uint t_15 = t_13 + 1U;
        t_13 = t_15;
    }
    offerShifted(&sel_5, _S798, Shift_x24init_0(_S798.f, 1.0f), canonical_mis_0);
    Reservoir _S831 = finalize(sel_5, c_sum_1);
    fcptStoreReservoirPrevious((_S791), (_S831), ((&dom_4)->hit));
    fcptStorePreviousLayer((_S791), (5U), (make_uint4 (asuint_0((&(&dom_4)->hit)->uv).x, asuint_0((&(&dom_4)->hit)->uv).y, 0U, 0U)));
    fcptAddColor((_S791), (make_float4 ((&sel_5)->color.x, (&sel_5)->color.y, (&sel_5)->color.z, 0.0f)));
    return;
}

static __device__ uint3  asuint_1(float3  x_20)
{
    uint3  result_9;
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
        *_slang_vector_get_element_ptr(&result_9, i_13) = (F32_asuint((_slang_vector_get_element(x_20, i_13))));
        i_13 = i_13 + int(1);
    }
    return result_9;
}

static __device__ void restir_shift_0(uint3  workgroup_id_1, uint local_invocation_index_4)
{
    uint _S832 = queuedShift_0(workgroup_id_1, local_invocation_index_4);
    bool _S833 = _S832 != 4294967295U;
    if(_S833)
    {
        uint2  _S834 = make_uint2 (_S832, _S832 >> 14U) & make_uint2 (16383U);
        int2  _S835 = make_int2 ((int)_S834.x, (int)_S834.y);
        ShiftJob _S836 = (ShiftJob{});
        ShiftJob shift_job_0 = _S836;
        Shift _S837 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
        uint _S838 = _S832 >> 28U;
        bool _S839 = spatialJob_0(_S835, _S838, &shift_job_0, true);
        Shift shifted_1;
        if(_S839)
        {
            Domain _S840 = (&shift_job_0)->dom;
            Reservoir _S841 = (&shift_job_0)->r;
            Shift _S842 = passShift_0(&_S840, &_S841);
            shifted_1 = _S842;
        }
        else
        {
            shifted_1 = _S837;
        }
        fcptStoreShiftData((_S835), (_S838), (make_uint4 (asuint_1(shifted_1.f).x, asuint_1(shifted_1.f).y, asuint_1(shifted_1.f).z, (F32_asuint((shifted_1.jac))))));
    }
    return;
}

static __device__ void restir_prepass_0(uint3  global_invocation_id_3, uint local_invocation_index_5)
{
    uint2  _S843 = uint2 {global_invocation_id_3.x, global_invocation_id_3.y};
    int2  _S844 = make_int2 ((int)_S843.x, (int)_S843.y);
    FixedArray<uint, 3>  _S845;
    spatialBins_0(_S844, &_S845);
    FixedArray<uint, 3>  _S846 = _S845;
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
        bool _S847 = (_S846[t_16]) == 40U;
        if(_S847)
        {
            fcptStoreShiftData((_S844), (t_16), (make_uint4 (0U)));
        }
        uint t_17 = t_16 + 1U;
        t_16 = t_17;
    }
    FixedArray<uint, 3>  _S848 = _S846;
    queueShifts_0(_S844, &_S848, global_invocation_id_3, local_invocation_index_5);
    return;
}

static __device__ void restir_count_0(uint3  global_invocation_id_4, uint local_invocation_index_6)
{
    uint2  _S849 = uint2 {global_invocation_id_4.x, global_invocation_id_4.y};
    int2  _S850 = make_int2 ((int)_S849.x, (int)_S849.y);
    FixedArray<uint, 3>  _S851;
    spatialBins_0(_S850, &_S851);
    FixedArray<uint, 3>  _S852 = _S851;
    countShifts_0(&_S852, local_invocation_index_6);
    return;
}

static __device__ void restir_temporal_shift_0(uint3  workgroup_id_2, uint local_invocation_index_7)
{
    uint _S853 = queuedShift_0(workgroup_id_2, local_invocation_index_7);
    bool _S854 = _S853 != 4294967295U;
    if(_S854)
    {
        uint2  _S855 = make_uint2 (_S853, _S853 >> 14U) & make_uint2 (16383U);
        int2  _S856 = make_int2 ((int)_S855.x, (int)_S855.y);
        ShiftJob _S857 = (ShiftJob{});
        ShiftJob shift_job_1 = _S857;
        Shift _S858 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
        uint _S859 = _S853 >> 28U;
        bool _S860 = temporalJob_0(_S856, _S859, &shift_job_1, true);
        Shift shifted_2;
        if(_S860)
        {
            if(_S859 == 1U)
            {
                Shift _S861 = (fcptShiftPrevious(((&shift_job_1)->dom), ((&shift_job_1)->r)));
                shifted_2 = _S861;
            }
            else
            {
                Domain _S862 = (&shift_job_1)->dom;
                Reservoir _S863 = (&shift_job_1)->r;
                Shift _S864 = passShift_0(&_S862, &_S863);
                shifted_2 = _S864;
            }
        }
        else
        {
            shifted_2 = _S858;
        }
        fcptStoreTemporalShift((_S856), (_S859), (make_uint4 (asuint_1(shifted_2.f).x, asuint_1(shifted_2.f).y, asuint_1(shifted_2.f).z, (F32_asuint((shifted_2.jac))))));
    }
    return;
}

static __device__ void restir_temporal_prepass_0(uint3  global_invocation_id_5, uint local_invocation_index_8)
{
    uint2  _S865 = uint2 {global_invocation_id_5.x, global_invocation_id_5.y};
    int2  _S866 = make_int2 ((int)_S865.x, (int)_S865.y);
    FixedArray<uint, 3>  _S867;
    temporalBins_0(_S866, &_S867);
    FixedArray<uint, 3>  _S868 = _S867;
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
        bool _S869 = (_S868[t_18]) == 40U;
        if(_S869)
        {
            fcptStoreTemporalShift((_S866), (t_18), (make_uint4 (0U)));
        }
        uint t_19 = t_18 + 1U;
        t_18 = t_19;
    }
    FixedArray<uint, 3>  _S870 = _S868;
    queueShifts_0(_S866, &_S870, global_invocation_id_5, local_invocation_index_8);
    return;
}

static __device__ void restir_temporal_count_0(uint3  global_invocation_id_6, uint local_invocation_index_9)
{
    uint2  _S871 = uint2 {global_invocation_id_6.x, global_invocation_id_6.y};
    int2  _S872 = make_int2 ((int)_S871.x, (int)_S871.y);
    FixedArray<uint, 3>  _S873;
    temporalBins_0(_S872, &_S873);
    FixedArray<uint, 3>  _S874 = _S873;
    countShifts_0(&_S874, local_invocation_index_9);
    return;
}

static __device__ float interpolate_0(float a_8, float b_4, float t_20)
{
    return a_8 + (b_4 - a_8) * t_20;
}

__device__ float confidenceCap(float duplicated_0)
{
    float _S875 = interpolate_0(20.0f, 1.0f, (F32_pow((duplicated_0), (0.10000000149011612f))));
    return _S875;
}

__device__ float2  temporalWeights(float c_2, float p_c_1, float c_t_0, float p_t_0, float g_previous_0, float g_current_0)
{
    float _S876 = c_2 * p_c_1;
    float _S877 = c_t_0 * p_t_0;
    return make_float2 (_S876 / (_S876 + c_t_0 * g_previous_0), _S877 / (_S877 + c_2 * g_current_0));
}

static __device__ void restir_temporal_0(uint3  global_invocation_id_7)
{
    uint2  _S878 = uint2 {global_invocation_id_7.x, global_invocation_id_7.y};
    int2  _S879 = make_int2 ((int)_S878.x, (int)_S878.y);
    float3  _S880 = make_float3 (0.0f);
    FKHit _S881 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S882 = Domain_x24init_0(_S880, _S880, &_S881, 0.0f, 0.0f);
    Domain dom_5 = _S882;
    bool _S883 = (fcptCurrentDomain((_S879), (&dom_5)));
    bool _S884 = !_S883;
    if(_S884)
    {
        Reservoir _S885 = (Reservoir{});
        fcptStoreReservoirTemporal((_S879), (_S885), ((&dom_5)->hit));
        return;
    }
    Reservoir _S886 = (fcptLoadReservoirInitial((_S879)));
    Domain stored_0 = _S882;
    int2  _S887 = make_int2 (int(-1));
    bool _S888 = (fcptStoredDomainInitial((_S879), (_S886.seed), (&stored_0)));
    int2  q_2;
    if(_S888)
    {
        Domain _S889 = stored_0;
        int2  _S890 = temporalNeighbor_0(_S879, &_S889, _S886.seed);
        q_2 = _S890;
    }
    else
    {
        q_2 = _S887;
    }
    bool _S891 = (q_2.x) >= int(0);
    Reservoir r_5;
    if(_S891)
    {
        Reservoir _S892 = (fcptLoadReservoirPrevious((q_2)));
        uint4  _S893 = (fcptDuplication((q_2)));
        float _S894 = (U32_asfloat((_S893.x)));
        uint _S895 = (fcptRestirDecorrelation());
        bool _S896 = _S895 == 1U;
        float _S897 = _slang_select(_S896, _S894,0.0f);
        float _S898 = confidenceCap(_S897);
        float _S899 = (F32_min((_S892.c), (_S898)));
        Domain target_3 = _S882;
        bool _S900 = (_S892.w) > 0.0f;
        bool _S901;
        if(_S900)
        {
            bool _S902 = (fcptStoredDomainInitial((_S879), (_S892.seed), (&target_3)));
            _S901 = _S902;
        }
        else
        {
            _S901 = false;
        }
        if(_S901)
        {
            Domain _S903 = (fcptPreviousDomain((q_2), (_S892.seed)));
            Domain _S904 = _S903;
            Domain _S905 = target_3;
            bool _S906 = temporalIdentity_0(0U, &_S904, &_S905);
            _S901 = _S906;
        }
        else
        {
            _S901 = false;
        }
        float4  _S907;
        if(_S901)
        {
            _S907 = make_float4 (_S892.f.x, _S892.f.y, _S892.f.z, 1.0f);
        }
        else
        {
            uint4  _S908 = (fcptTemporalShift((_S879), (0U)));
            _S907 = asfloat_0(_S908);
        }
        bool _S909 = (_S886.w) > 0.0f;
        if(_S909)
        {
            Domain _S910 = (fcptPreviousDomain((q_2), (_S886.seed)));
            Domain _S911 = _S910;
            Domain _S912 = stored_0;
            bool _S913 = temporalIdentity_0(1U, &_S911, &_S912);
            _S901 = _S913;
        }
        else
        {
            _S901 = false;
        }
        float4  _S914;
        if(_S901)
        {
            _S914 = make_float4 (_S886.f.x, _S886.f.y, _S886.f.z, 1.0f);
        }
        else
        {
            uint4  _S915 = (fcptTemporalShift((_S879), (1U)));
            _S914 = asfloat_0(_S915);
        }
        float _S916 = rgb_to_greyscale(_S886.f);
        float _S917 = rgb_to_greyscale(_S892.f);
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
        float4  _S927 = _S907;
        float3  _S928 = float3 {_S927.x, _S927.y, _S927.z};
        float _S929 = rgb_to_greyscale(_S928);
        float2  _S930 = temporalWeights(_S886.c, _S916, _S899, _S917, _S926, _S929);
        offerShifted(&sel_6, _S886, Shift_x24init_0(_S886.f, 1.0f), _S930.x);
        offerShifted(&sel_6, _S892, Shift_x24init_0(_S928, _S907.w), _S930.y);
        Reservoir _S931 = finalize(sel_6, _S886.c + _S899);
        r_5 = _S931;
    }
    else
    {
        r_5 = _S886;
    }
    fcptStoreReservoirTemporal((_S879), (r_5), ((&dom_5)->hit));
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
    uint i_14 = 0U;
    for(;;)
    {
        uint _S954 = (fcptSamples());
        if(i_14 < _S954)
        {
        }
        else
        {
            break;
        }
        Reservoir _S955 = (Reservoir{});
        Reservoir r_6 = _S955;
        uint _S956 = stream(_S945, i_14);
        (&r_6)->seed = _S956;
        Domain path_0 = _S937;
        bool _S957 = (fcptStoredDomainInitial((_S933), ((&r_6)->seed), (&path_0)));
        bool _S958 = !_S957;
        if(_S958)
        {
            fcptMissed((_S933), (path_0), (_S953));
            uint i_15 = i_14 + 1U;
            i_14 = i_15;
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
        uint i_15 = i_14 + 1U;
        i_14 = i_15;
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

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_5, float3  origin_5, float3  smooth_n_3, float3  start_6)
{
    NEEVertex _S969;
    (&_S969)->none = none_0;
    (&_S969)->pdf = pdf_5;
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

static __device__ Vertex Vertex_x24init_0(bool rough_0, uint lobe_1, float pdf_6, float cos_0, bool inside_0)
{
    Vertex _S970;
    (&_S970)->rough = rough_0;
    (&_S970)->lobe = lobe_1;
    (&_S970)->pdf = pdf_6;
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
        *_slang_vector_get_element_ptr(&result_10, i_16) = (F32_exp((_slang_vector_get_element(x_21, i_16))));
        i_16 = i_16 + int(1);
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

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_0, uint depth_1, uint lobe_2, bool surface_4, float length_2, float width_1, FKHit * own_0, bool fiber_0)
{
    ShadowContext _S979;
    (&_S979)->extinction_behind = extinction_behind_0;
    (&_S979)->extinction_front = extinction_front_0;
    (&_S979)->fillings = fillings_0;
    (&_S979)->side = side_0;
    (&_S979)->depth = depth_1;
    (&_S979)->lobe = lobe_2;
    (&_S979)->surface = surface_4;
    (&_S979)->length = length_2;
    (&_S979)->width = width_1;
    (&_S979)->own = *own_0;
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

__device__ Reservoir withEnd(Reservoir r_7, uint end_type_0, uint end_0, float3  f_5)
{
    Reservoir candidate_2 = r_7;
    uint _S987 = insertBits_0(r_7.path, end_0, 0U, 5U);
    uint _S988 = insertBits_0(_S987, end_type_0, 12U, 3U);
    (&candidate_2)->path = _S988;
    (&candidate_2)->f = f_5;
    return candidate_2;
}

__device__ float survivalProbability(float3  throughput_2, float density_1)
{
    return (F32_min(((F32_max(((F32_max((throughput_2.x), ((F32_max((throughput_2.y), (throughput_2.z)))))) / density_1), (0.0f)))), (1.0f)));
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

static __device__ float3  samplePhase_0(float g_1, float3  dir_10, uint random_state_10, float * pdf_7)
{
    bool _S994 = (F32_abs((g_1))) < 0.00100000004749745f;
    if(_S994)
    {
        *pdf_7 = 0.07957746833562851f;
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
    *pdf_7 = _S1004;
    float3  _S1005 = tangentToWorld(make_float3 (_S1002 * (F32_cos((_S1003))), _S1001, _S1002 * (F32_sin((_S1003)))), dir_10);
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

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_11, bool skip_0, uint random_state_11, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S1009;
    (&_S1009)->smooth_n = smooth_n_4;
    (&_S1009)->geometry_n = geometry_n_2;
    (&_S1009)->geometry_offset = geometry_offset_2;
    (&_S1009)->material = *material_11;
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
    BSDFMaterial material_12 = _S1018;
    (&material_12)->albedo = _S1017;
    (&material_12)->emissive = (&surface_6->material)->emissive;
    (&material_12)->transmission = 1.0f;
    (&material_12)->ior = 1.0f;
    (&material_12)->absorption = (&surface_6->material)->absorption;
    FKSurface through_0 = *surface_6;
    (&through_0)->material = material_12;
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

static __device__ bool arrivesBehind_0(float3  dir_11, float3  n_10)
{
    return (dot_0(dir_11, n_10)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_7, float3  dir_12)
{
    float3  _S1022 = surface_7->geometry_n;
    float _S1023 = facingSign((&surface_7->material)->transmission, surface_7->geometry_n, dir_12);
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
        *_slang_vector_get_element_ptr(&result_11, i_17) = (F32_max((_slang_vector_get_element(x_22, i_17)), (_slang_vector_get_element(y_7, i_17))));
        i_17 = i_17 + int(1);
    }
    return result_11;
}

static __device__ float3  log_0(float3  x_23)
{
    float3  result_12;
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
        *_slang_vector_get_element_ptr(&result_12, i_18) = (F32_log((_slang_vector_get_element(x_23, i_18))));
        i_18 = i_18 + int(1);
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

__device__ float2  vertexEta(BSDFMaterial material_13, float n_dot_v_0)
{
    bool _S1028 = n_dot_v_0 < 0.0f;
    float _S1029 = _slang_select(_S1028, material_13.ior,1.0f);
    float _S1030 = _slang_select(_S1028, 1.0f,material_13.ior);
    return make_float2 (_S1029, _S1030);
}

__device__ bool neeDecision(BSDFMaterial material_14, float n_dot_v_1, float eta_i_10, float eta_o_10)
{
    float _S1031 = fresnel((F32_abs((n_dot_v_1))), eta_i_10, eta_o_10);
    float3  _S1032 = mix_0(make_float3 (_S1031), material_14.albedo, material_14.metallic);
    float _S1033 = rgb_to_greyscale(_S1032);
    float _S1034 = (F32_max(((1.0f - _S1033) * (1.0f - material_14.metallic) * (1.0f - material_14.transmission)), (0.0f)));
    bool _S1035 = _S1034 > 0.03999999910593033f;
    bool _S1036;
    if(_S1035)
    {
        _S1036 = true;
    }
    else
    {
        _S1036 = (material_14.roughness) > 0.20000000298023224f;
    }
    return _S1036;
}

static __device__ bool isTranslucent_0(BSDFMaterial * material_15)
{
    float _S1037 = rgb_to_greyscale(material_15->translucent);
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

static __device__ MediumSides mediumSides_0(FKSurface * surface_8, FKMedium * medium_0, uint filling_0, float3  dir_13, FKMedium * outside_0)
{
    float3  _S1039 = surface_8->geometry_n;
    MediumSides _S1040 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_8->geometry_n);
    MediumSides sides_0 = _S1040;
    bool _S1041 = surface_8->encloses;
    if(_S1041)
    {
        (&sides_0)->behind = surface_8->volume;
        *&((&(&sides_0)->fillings)->x) = surface_8->fills;
        bool _S1042 = (dot_0(dir_13, _S1039)) > 0.0f;
        if(_S1042)
        {
            (&sides_0)->front = *outside_0;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_9, bool turned_0, float3  extinction_2, uint filling_1, float3  dir_14, uint depth_2, uint lobe_3, float length_3, float width_2, FKHit * own_1, bool fiber_1, FKMedium * outside_1)
{
    float3  _S1043 = surface_9->geometry_n;
    ShadowContext _S1044 = ShadowContext_x24init_0(extinction_2, extinction_2, make_uint2 (filling_1), surface_9->geometry_n, depth_2, lobe_3, true, length_3, width_2, own_1, fiber_1);
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
        MediumSides _S1051 = mediumSides_0(&_S1049, &_S1050, filling_1, dir_14, outside_1);
        ShadowContext _S1052 = ShadowContext_x24init_0(_S1051.behind.extinction, _S1051.front.extinction, _S1051.fillings, _S1043, depth_2, lobe_3, true, length_3, width_2, own_1, fiber_1);
        if(turned_0)
        {
            uint2  _S1053 = _S1051.fillings;
            ShadowContext _S1054 = ShadowContext_x24init_0(_S1051.front.extinction, _S1051.behind.extinction, uint2 {_S1053.y, _S1053.x}, _S1043, depth_2, lobe_3, true, length_3, width_2, own_1, fiber_1);
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
        if(result_13)
        {
            result_13 = true;
        }
        else
        {
            result_13 = (bool((_slang_vector_get_element(x_24, i_19))));
        }
        i_19 = i_19 + int(1);
    }
    return result_13;
}

__device__ __forceinline__ float3  BSDF(float3  in_dir_8, float3  out_dir_2, float3  n_11, float3  g_n_0, BSDFMaterial material_16, float eta_i_11, float eta_o_11, uint random_state_12)
{
    float3  _S1055 = negate_0(in_dir_8);
    float _S1056 = dot_0(n_11, _S1055);
    float _S1057 = sign_0(_S1056);
    float3  _S1058 = n_11 * make_float3 (_S1057);
    AnisotropicFrame _S1059 = anisotropicFrame(material_16, _S1058);
    float _S1060 = dot_0(_S1058, out_dir_2);
    float _S1061 = material_16.roughness;
    float _S1062 = _S1061 * _S1061;
    bool _S1063 = (dot_0(g_n_0, _S1055) * dot_0(g_n_0, out_dir_2)) > 0.0f;
    uint _S1064;
    if((F32_abs((material_16.toon.x))) > 0.0f)
    {
        _S1064 = 1U;
    }
    else
    {
        _S1064 = 0U;
    }
    if(_S1063)
    {
        _S1064 = 3U + _S1064;
    }
    else
    {
        _S1064 = 1U;
    }
    float3  _S1065 = make_float3 (0.0f);
    BSDFLobes _S1066 = BSDFLobes_x24init_0(0.0f, 0.0f, _S1065, _S1065, 0.0f, 0.0f, _S1065, _S1065, 0.0f, 0.0f, 0.0f, 0.0f, _S1065, 0.0f, _S1065, _S1065, make_float2 (0.0f), 0.0f, 0.0f, _S1065, 0.0f, 0.0f, 0.0f, false, 1.0f, 0.0f, _S1065);
    BSDFLobes lobe_terms_1 = _S1066;
    uint half_of_2 = 4294967295U;
    float3  ggx_n_3 = _S1065;
    float3  f_6 = _S1065;
    uint i_20 = 0U;
    for(;;)
    {
        if(i_20 < _S1064)
        {
        }
        else
        {
            break;
        }
        uint _S1067;
        if(!_S1063)
        {
            _S1067 = 1U;
        }
        else
        {
            if(i_20 == 0U)
            {
                _S1067 = 0U;
            }
            else
            {
                if(i_20 == 1U)
                {
                    _S1067 = 2U;
                }
                else
                {
                    if(i_20 == 2U)
                    {
                        _S1067 = 4U;
                    }
                    else
                    {
                        _S1067 = 6U;
                    }
                }
            }
        }
        uint _S1068;
        if(_S1067 == 6U)
        {
            _S1068 = 0U;
        }
        else
        {
            if(_S1067 == 4U)
            {
                _S1068 = 2U;
            }
            else
            {
                _S1068 = _S1067;
            }
        }
        bool _S1069 = _S1068 != half_of_2;
        float3  ggx_n_4;
        if(_S1069)
        {
            bool _S1070 = _S1068 == 0U;
            if(_S1070)
            {
                float3  _S1071 = sampledHalf(in_dir_8, n_11, material_16, random_state_12, _S1059);
                ggx_n_4 = _S1071;
            }
            else
            {
                bool _S1072 = _S1068 == 1U;
                if(_S1072)
                {
                    float3  _S1073 = refractedHalf(in_dir_8, out_dir_2, n_11, eta_i_11, eta_o_11);
                    ggx_n_4 = _S1073;
                }
                else
                {
                    float3  _S1074 = reflectedHalf(in_dir_8, out_dir_2);
                    ggx_n_4 = _S1074;
                }
            }
            float3  _S1075 = negate_0(in_dir_8);
            BSDFLobes _S1076 = bsdfLobes(in_dir_8, _S1075, _S1058, ggx_n_4, material_16, eta_i_11, eta_o_11, _S1059);
            lobe_terms_1 = _S1076;
            float _S1077 = translucentShare(material_16);
            (&lobe_terms_1)->translucent_share = _S1077;
            half_of_2 = _S1068;
        }
        else
        {
            ggx_n_4 = ggx_n_3;
        }
        float3  throughput_3;
        float pdf_8;
        switch(_S1067)
        {
        case 0U:
            {
                float _S1078 = diffusePDF(_S1060, 0.0f, (F32_abs((_S1056))), _S1062, lobe_terms_1, eta_i_11, eta_o_11);
                float3  _S1079 = diffuseBSDF(out_dir_2, _S1058, _S1062, material_16, lobe_terms_1);
                pdf_8 = _S1078;
                throughput_3 = _S1079;
                break;
            }
        case 1U:
            {
                float _S1080 = refractPDF(_S1060, dot_0(out_dir_2, ggx_n_4), (F32_abs((_S1056))), _S1062, lobe_terms_1, eta_i_11, eta_o_11);
                float3  _S1081 = refractBSDF(out_dir_2, _S1058, _S1062, material_16, lobe_terms_1);
                pdf_8 = _S1080;
                throughput_3 = _S1081;
                break;
            }
        case 4U:
            {
                float _S1082 = sheenVelvetPDF(_S1060, 0.0f, (F32_abs((_S1056))), _S1062, lobe_terms_1, eta_i_11, eta_o_11);
                float3  _S1083 = sheenVelvetBSDF(out_dir_2, _S1058, _S1062, material_16, lobe_terms_1);
                pdf_8 = _S1082;
                throughput_3 = _S1083;
                break;
            }
        case 6U:
            {
                float _S1084 = toonPDF(_S1060, dot_0(out_dir_2, (&lobe_terms_1)->toon_axis), (F32_abs((_S1056))), _S1062, lobe_terms_1, eta_i_11, eta_o_11);
                float3  _S1085 = toonBSDF(out_dir_2, _S1058, _S1062, material_16, lobe_terms_1);
                pdf_8 = _S1084;
                throughput_3 = _S1085;
                break;
            }
        default:
            {
                float _S1086 = reflectPDF(_S1060, 0.0f, (F32_abs((_S1056))), _S1062, lobe_terms_1, eta_i_11, eta_o_11);
                float3  _S1087 = reflectBSDF(out_dir_2, _S1058, _S1062, material_16, lobe_terms_1);
                pdf_8 = _S1086;
                throughput_3 = _S1087;
                break;
            }
        }
        float3  _S1088;
        if(pdf_8 > 0.0f)
        {
            _S1088 = throughput_3 * make_float3 (pdf_8);
        }
        else
        {
            _S1088 = _S1065;
        }
        if(i_20 == 0U)
        {
            f_6 = _S1088;
        }
        else
        {
            f_6 = f_6 + _S1088;
        }
        uint i_21 = i_20 + 1U;
        ggx_n_3 = ggx_n_4;
        i_20 = i_21;
    }
    return f_6;
}

__device__ float3  translucentCorrection(float3  in_dir_9, float3  out_dir_3, float3  n_12, float3  g_n_1, BSDFMaterial material_17, float eta_i_12, float eta_o_12, uint random_state_13)
{
    float _S1089 = dot_0(n_12, out_dir_3);
    float3  _S1090 = negate_0(in_dir_9);
    bool _S1091 = (_S1089 * dot_0(n_12, _S1090)) < 0.0f;
    float3  _S1092 = negate_0(in_dir_9);
    float _S1093 = dot_0(n_12, _S1092);
    float _S1094 = sign_0(_S1093);
    float3  _S1095 = n_12 * make_float3 (_S1094);
    AnisotropicFrame _S1096 = anisotropicFrame(material_17, _S1095);
    float _S1097 = material_17.roughness;
    float _S1098 = _S1097 * _S1097;
    float3  _S1099 = negate_0(in_dir_9);
    float3  _S1100 = sampledHalf(in_dir_9, n_12, material_17, random_state_13, _S1096);
    BSDFLobes _S1101 = bsdfLobes(in_dir_9, _S1099, _S1095, _S1100, material_17, eta_i_12, eta_o_12, _S1096);
    BSDFLobes sampled_0 = _S1101;
    float _S1102 = translucentShare(material_17);
    (&sampled_0)->translucent_share = _S1102;
    float _S1103 = diffusePDF(dot_0(_S1095, out_dir_3), 0.0f, (F32_abs((_S1093))), _S1098, sampled_0, eta_i_12, eta_o_12);
    float3  _S1104;
    if(_S1103 > 0.0f)
    {
        float3  _S1105 = diffuseBSDF(out_dir_3, _S1095, _S1098, material_17, sampled_0);
        _S1104 = _S1105 * make_float3 (_S1103);
    }
    else
    {
        _S1104 = make_float3 (0.0f);
    }
    float3  _S1106 = negate_0(in_dir_9);
    bool _S1107 = (dot_0(g_n_1, _S1106) * dot_0(g_n_1, out_dir_3)) > 0.0f;
    float3  _S1108 = make_float3 (0.0f);
    float _S1109 = _slang_select(_S1107, -1.0f,1.0f);
    float3  _S1110 = _S1104 * make_float3 (_S1109);
    float3  _S1111 = _slang_select(_S1091, _S1110,_S1108);
    return _S1111;
}

__device__ float3  translucentBSDF(float3  in_dir_10, float3  out_dir_4, float3  n_13, float3  g_n_2, BSDFMaterial material_18, float eta_i_13, float eta_o_13, uint random_state_14)
{
    float3  _S1112 = BSDF(in_dir_10, out_dir_4, n_13, g_n_2, material_18, eta_i_13, eta_o_13, random_state_14);
    float3  _S1113 = translucentCorrection(in_dir_10, out_dir_4, n_13, g_n_2, material_18, eta_i_13, eta_o_13, random_state_14);
    return _S1112 + _S1113;
}

static __device__ __forceinline__ float3  lightBSDF_0(float3  in_dir_11, TreeSample * light_2, float3  smooth_n_5, float3  geometry_n_4, BSDFMaterial * material_19, float eta_i_14, float eta_o_14, bool competing_1, uint random_state_15)
{
    bool _S1114 = !competing_1;
    bool _S1115;
    if(_S1114)
    {
        _S1115 = true;
    }
    else
    {
        _S1115 = (light_2->density) == 0.0f;
    }
    if(_S1115)
    {
        bool _S1116 = isTranslucent_0(material_19);
        if(_S1116)
        {
            float3  _S1117 = translucentBSDF(in_dir_11, light_2->dir, smooth_n_5, geometry_n_4, *material_19, eta_i_14, eta_o_14, random_state_15);
            return _S1117 * light_2->radiance;
        }
        float3  _S1118 = BSDF(in_dir_11, light_2->dir, smooth_n_5, geometry_n_4, *material_19, eta_i_14, eta_o_14, random_state_15);
        return _S1118 * light_2->radiance;
    }
    float3  _S1119 = light_2->dir;
    bool _S1120 = (dot_0(geometry_n_4, - in_dir_11) * dot_0(geometry_n_4, light_2->dir)) <= 0.0f;
    float3  _S1121 = neeBSDF(in_dir_11, _S1119, smooth_n_5, *material_19, eta_i_14, eta_o_14, _S1120, light_2->density, true, random_state_15);
    return _S1121 * light_2->radiance * make_float3 (light_2->density);
}

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_4, uint random_state_16, bool refracted_4, uint lobe_4, float pdf_9)
{
    SampleBSDF _S1122;
    (&_S1122)->unit_direction = unit_direction_1;
    (&_S1122)->throughput = throughput_4;
    (&_S1122)->random_state = random_state_16;
    (&_S1122)->refracted = refracted_4;
    (&_S1122)->lobe = lobe_4;
    (&_S1122)->pdf = pdf_9;
    return _S1122;
}

__device__ __forceinline__ SampleBSDF sheenVelvetSample(float3  n_i_8, float n_i_dot_v_6, float alpha_15, BSDFMaterial material_20, BSDFLobes lobes_11, float eta_i_15, float eta_o_15, uint random_state_17)
{
    float3  _S1123 = make_float3 (1.0f);
    SampleBSDF _S1124 = SampleBSDF_x24init_0(_S1123, _S1123, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S1124;
    Random _S1125 = pcg(random_state_17);
    Random _S1126 = pcg(_S1125.state);
    (&sample_1)->random_state = _S1126.state;
    float _S1127 = _S1125.value;
    float _S1128 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1127 * _S1127))))));
    float _S1129 = 6.28318548202514648f * _S1126.value;
    float3  _S1130 = tangentToWorld(make_float3 (_S1128 * (F32_cos((_S1129))), _S1125.value, _S1128 * (F32_sin((_S1129)))), n_i_8);
    (&sample_1)->unit_direction = _S1130;
    (&sample_1)->lobe = 4U;
    float3  _S1131 = sheenVelvetBSDF((&sample_1)->unit_direction, n_i_8, alpha_15, material_20, lobes_11);
    (&sample_1)->throughput = _S1131;
    float _S1132 = sheenVelvetPDF(_S1125.value, 0.0f, n_i_dot_v_6, alpha_15, lobes_11, eta_i_15, eta_o_15);
    (&sample_1)->pdf = _S1132;
    return sample_1;
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S1133 = (F32_sqrt((random_1_0)));
    float _S1134 = 6.28318548202514648f * random_2_0;
    float _S1135 = _S1133 * (F32_cos((_S1134)));
    float _S1136 = _S1133 * (F32_sin((_S1134)));
    float _S1137 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1135 * _S1135 - _S1136 * _S1136))))));
    return make_float3 (_S1135, _S1137, _S1136);
}

__device__ __forceinline__ SampleBSDF diffuseSample(float u_3, float3  n_i_9, float n_i_dot_v_7, float alpha_16, BSDFMaterial material_21, BSDFLobes lobes_12, float eta_i_16, float eta_o_16, uint random_state_18)
{
    float3  _S1138 = make_float3 (1.0f);
    SampleBSDF _S1139 = SampleBSDF_x24init_0(_S1138, _S1138, 0U, false, 0U, 0.0f);
    SampleBSDF sample_2 = _S1139;
    Random _S1140 = pcg(random_state_18);
    Random _S1141 = pcg(_S1140.state);
    (&sample_2)->random_state = _S1141.state;
    float3  _S1142 = sampleCosWeightedHemisphere(_S1140.value, _S1141.value);
    bool _S1143 = u_3 < (lobes_12.p_diffuse * lobes_12.translucent_share);
    float _S1144 = _S1142.y;
    float _S1145 = - _S1144;
    float _S1146 = _slang_select(_S1143, _S1145,_S1144);
    float3  _S1147 = tangentToWorld(make_float3 (_S1142.x, _S1146, _S1142.z), n_i_9);
    (&sample_2)->unit_direction = _S1147;
    (&sample_2)->refracted = _S1143;
    (&sample_2)->lobe = 0U;
    float3  _S1148 = diffuseBSDF((&sample_2)->unit_direction, n_i_9, alpha_16, material_21, lobes_12);
    (&sample_2)->throughput = _S1148;
    float _S1149 = diffusePDF(_S1146, 0.0f, n_i_dot_v_7, alpha_16, lobes_12, eta_i_16, eta_o_16);
    (&sample_2)->pdf = _S1149;
    return sample_2;
}

__device__ __forceinline__ SampleBSDF toonSample(float3  n_i_10, float n_i_dot_v_8, float alpha_17, BSDFMaterial material_22, BSDFLobes lobes_13, float eta_i_17, float eta_o_17, uint random_state_19)
{
    float3  _S1150 = make_float3 (1.0f);
    SampleBSDF _S1151 = SampleBSDF_x24init_0(_S1150, _S1150, 0U, false, 0U, 0.0f);
    SampleBSDF sample_3 = _S1151;
    Random _S1152 = pcg(random_state_19);
    Random _S1153 = pcg(_S1152.state);
    (&sample_3)->random_state = _S1153.state;
    float _S1154 = _S1152.value * lobes_13.toon_norm / 6.28318548202514648f;
    float t_21;
    if(lobes_13.toon_glossy)
    {
        t_21 = (F32_acos((clamp_1(1.0f - _S1154, -1.0f, 1.0f))));
    }
    else
    {
        t_21 = (F32_asin(((F32_min(((F32_sqrt((2.0f * _S1154)))), (1.0f))))));
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
        float _S1155;
        if(t_21 < (lobes_13.toon_a))
        {
            _S1155 = 1.0f;
        }
        else
        {
            _S1155 = (F32_max((1.0f - (t_21 - lobes_13.toon_a) / (F32_max((lobes_13.toon_s), (0.0000152587890625f)))), (0.0f)));
        }
        float integral_1;
        if(lobes_13.toon_glossy)
        {
            integral_1 = 1.0f - (F32_cos(((F32_min((t_21), (lobes_13.toon_a))))));
        }
        else
        {
            float _S1156 = (F32_sin(((F32_min((t_21), (lobes_13.toon_a))))));
            integral_1 = _S1156 * _S1156 / 2.0f;
        }
        bool _S1157 = t_21 > (lobes_13.toon_a);
        bool _S1158;
        if(_S1157)
        {
            _S1158 = (lobes_13.toon_s) > 0.0f;
        }
        else
        {
            _S1158 = false;
        }
        float integral_2;
        if(_S1158)
        {
            if(lobes_13.toon_glossy)
            {
                float _S1159 = (F32_cos((lobes_13.toon_a)));
                float _S1160 = (F32_cos((t_21)));
                integral_2 = (1.0f + lobes_13.toon_a / lobes_13.toon_s) * (_S1159 - _S1160) - ((F32_sin((t_21))) - t_21 * _S1160 - ((F32_sin((lobes_13.toon_a))) - lobes_13.toon_a * _S1159)) / lobes_13.toon_s;
            }
            else
            {
                float _S1161 = 2.0f * lobes_13.toon_a;
                float _S1162 = (F32_cos((_S1161)));
                float _S1163 = 2.0f * t_21;
                float _S1164 = (F32_cos((_S1163)));
                integral_2 = (1.0f + lobes_13.toon_a / lobes_13.toon_s) * (_S1162 - _S1164) / 4.0f - ((F32_sin((_S1163))) / 8.0f - t_21 * _S1164 / 4.0f - ((F32_sin((_S1161))) / 8.0f - lobes_13.toon_a * _S1162 / 4.0f)) / lobes_13.toon_s;
            }
            float integral_3 = integral_1 + integral_2;
            integral_2 = integral_3;
        }
        else
        {
            integral_2 = integral_1;
        }
        float _S1165 = _S1155 * (F32_sin((t_21)));
        float _S1166;
        if(lobes_13.toon_glossy)
        {
            _S1166 = 1.0f;
        }
        else
        {
            _S1166 = (F32_cos((t_21)));
        }
        float _S1167 = _S1165 * _S1166;
        float _S1168 = (integral_2 - _S1154) / _S1167;
        bool _S1169 = _S1167 > 0.0f;
        float _S1170 = _slang_select(_S1169, _S1168,0.0f);
        float _S1171 = clamp_1(t_21 - _S1170, 0.0f, lobes_13.toon_b);
        int k_1 = k_0 + int(1);
        t_21 = _S1171;
        k_0 = k_1;
    }
    float _S1172 = 6.28318548202514648f * _S1153.value;
    float _S1173 = (F32_sin((t_21)));
    float3  _S1174 = tangentToWorld(make_float3 (_S1173 * (F32_cos((_S1172))), (F32_cos((t_21))), _S1173 * (F32_sin((_S1172)))), lobes_13.toon_axis);
    (&sample_3)->unit_direction = _S1174;
    bool _S1175 = (dot_0(n_i_10, (&sample_3)->unit_direction)) < 0.0f;
    (&sample_3)->refracted = _S1175;
    (&sample_3)->lobe = 6U;
    float3  _S1176 = toonBSDF((&sample_3)->unit_direction, n_i_10, alpha_17, material_22, lobes_13);
    (&sample_3)->throughput = _S1176;
    float _S1177 = toonPDF(dot_0(n_i_10, (&sample_3)->unit_direction), dot_0((&sample_3)->unit_direction, lobes_13.toon_axis), n_i_dot_v_8, alpha_17, lobes_13, eta_i_17, eta_o_17);
    (&sample_3)->pdf = _S1177;
    return sample_3;
}

__device__ __forceinline__ SampleBSDF refractSample(float3  ggx_n_5, float3  n_i_11, float n_i_dot_v_9, float alpha_18, BSDFMaterial material_23, BSDFLobes lobes_14, float eta_i_18, float eta_o_18, uint random_state_20)
{
    float3  _S1178 = make_float3 (1.0f);
    SampleBSDF _S1179 = SampleBSDF_x24init_0(_S1178, _S1178, 0U, false, 0U, 0.0f);
    SampleBSDF sample_4 = _S1179;
    (&sample_4)->unit_direction = lobes_14.refracted;
    (&sample_4)->random_state = random_state_20;
    (&sample_4)->refracted = true;
    (&sample_4)->lobe = 1U;
    float3  _S1180 = refractBSDF((&sample_4)->unit_direction, n_i_11, alpha_18, material_23, lobes_14);
    (&sample_4)->throughput = _S1180;
    float _S1181 = refractPDF(0.0f, dot_0((&sample_4)->unit_direction, ggx_n_5), n_i_dot_v_9, alpha_18, lobes_14, eta_i_18, eta_o_18);
    (&sample_4)->pdf = _S1181;
    return sample_4;
}

static __device__ float3  reflect_0(float3  i_22, float3  n_14)
{
    return i_22 - make_float3 (2.0f * dot_0(n_14, i_22)) * n_14;
}

__device__ __forceinline__ SampleBSDF reflectSample(float3  in_dir_12, float3  ggx_n_6, float3  n_i_12, float n_i_dot_v_10, float alpha_19, BSDFMaterial material_24, BSDFLobes lobes_15, float eta_i_19, float eta_o_19, uint random_state_21)
{
    float3  _S1182 = make_float3 (1.0f);
    SampleBSDF _S1183 = SampleBSDF_x24init_0(_S1182, _S1182, 0U, false, 0U, 0.0f);
    SampleBSDF sample_5 = _S1183;
    float3  _S1184 = reflect_0(in_dir_12, ggx_n_6);
    float3  _S1185 = ((((_S1184)) * make_float3(rnorm3df(((_S1184)).x, ((_S1184)).y, ((_S1184)).z))));
    (&sample_5)->unit_direction = _S1185;
    (&sample_5)->random_state = random_state_21;
    (&sample_5)->lobe = 2U;
    float3  _S1186 = reflectBSDF((&sample_5)->unit_direction, n_i_12, alpha_19, material_24, lobes_15);
    (&sample_5)->throughput = _S1186;
    float _S1187 = reflectPDF(0.0f, 0.0f, n_i_dot_v_10, alpha_19, lobes_15, eta_i_19, eta_o_19);
    (&sample_5)->pdf = _S1187;
    return sample_5;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_13, float3  n_15, BSDFMaterial material_25, float eta_i_20, float eta_o_20, uint random_init_0, float2  screen_space_0)
{
    uint random_state_22 = random_init_0;
    float3  _S1188 = negate_0(in_dir_13);
    float _S1189 = dot_0(n_15, _S1188);
    float _S1190 = sign_0(_S1189);
    float3  n_i_13 = n_15 * make_float3 (_S1190);
    float _S1191 = (F32_abs((_S1189)));
    float _S1192 = material_25.roughness;
    float _S1193 = _S1192 * _S1192;
    AnisotropicFrame _S1194 = anisotropicFrame(material_25, n_i_13);
    float3  _S1195 = sampleHalfVector(_S1188, n_i_13, _S1193, _S1194, &random_state_22);
    BSDFLobes _S1196 = bsdfLobes(in_dir_13, _S1188, n_i_13, _S1195, material_25, eta_i_20, eta_o_20, _S1194);
    BSDFLobes lobes_16 = _S1196;
    float _S1197 = translucentShare(material_25);
    (&lobes_16)->translucent_share = _S1197;
    Random _S1198 = pcg(random_state_22);
    random_state_22 = _S1198.state;
    bool _S1199 = (_S1198.value) < ((&lobes_16)->p_sheen_velvet);
    if(_S1199)
    {
        SampleBSDF _S1200 = sheenVelvetSample(n_i_13, _S1191, _S1193, material_25, lobes_16, eta_i_20, eta_o_20, random_state_22);
        return _S1200;
    }
    float _S1201 = _S1198.value - (&lobes_16)->p_sheen_velvet;
    bool _S1202 = _S1201 < ((&lobes_16)->p_diffuse);
    if(_S1202)
    {
        SampleBSDF _S1203 = diffuseSample(_S1201, n_i_13, _S1191, _S1193, material_25, lobes_16, eta_i_20, eta_o_20, random_state_22);
        return _S1203;
    }
    bool _S1204 = _S1201 < ((&lobes_16)->p_diffuse + (&lobes_16)->p_toon);
    if(_S1204)
    {
        SampleBSDF _S1205 = toonSample(n_i_13, _S1191, _S1193, material_25, lobes_16, eta_i_20, eta_o_20, random_state_22);
        return _S1205;
    }
    float _S1206 = (&lobes_16)->p_toon;
    bool _S1207 = (_S1201 - _S1206) < ((&lobes_16)->p_diffuse + (&lobes_16)->p_refract);
    if(_S1207)
    {
        SampleBSDF _S1208 = refractSample(_S1195, n_i_13, _S1191, _S1193, material_25, lobes_16, eta_i_20, eta_o_20, random_state_22);
        return _S1208;
    }
    SampleBSDF _S1209 = reflectSample(in_dir_13, _S1195, n_i_13, _S1191, _S1193, material_25, lobes_16, eta_i_20, eta_o_20, random_state_22);
    return _S1209;
}

__device__ bool withinInverseFootprint(float pdf_10, bool diffuse_0, float prev_cos_0, float distance_5, float threshold_1)
{
    bool _S1210 = pdf_10 > 0.0f;
    bool _S1211;
    if(_S1210)
    {
        if(diffuse_0)
        {
            _S1211 = true;
        }
        else
        {
            _S1211 = (pdf_10 * prev_cos_0 / (distance_5 * distance_5) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S1211 = false;
    }
    return _S1211;
}

__device__ bool roughLobe(float pdf_11, bool diffuse_1, float roughness_1)
{
    bool _S1212 = pdf_11 > 0.0f;
    bool _S1213;
    if(_S1212)
    {
        if(diffuse_1)
        {
            _S1213 = true;
        }
        else
        {
            _S1213 = roughness_1 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S1213 = false;
    }
    return _S1213;
}

static __device__ bool passesLayer_0(uint layers_0, bool refracting_0, bool passed_0)
{
    bool _S1214 = layers_0 > 1U;
    bool _S1215;
    if(_S1214)
    {
        _S1215 = refracting_0 != passed_0;
    }
    else
    {
        _S1215 = false;
    }
    return _S1215;
}

static __device__ float widened_0(float spread_1, float pdf_12, bool delta_0)
{
    float _S1216 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * pdf_12))))), (3.14159274101257324f)));
    bool _S1217 = !delta_0;
    float _S1218 = _slang_select(_S1217, _S1216,0.0f);
    return spread_1 + _S1218;
}

static __device__ bool boundsVolume_0(FKSurface * surface_10)
{
    return surface_10->encloses;
}

static __device__ bool leavesInFront_0(float3  face_2, float3  dir_15, float3  g_3)
{
    return ((dot_0(dir_15, g_3)) > 0.0f) == ((dot_0(g_3, face_2)) > 0.0f);
}

static __device__ Shift walk_0(Domain * dom_7, Reservoir * r_8, bool replay_2, float scale_3, Selection * sel_7)
{
    float spread_2;
    bool turned_1;
    bool is_inside_5;
    bool viewed_0;
    bool _S1219;
    float density_2;
    float threshold_2;
    float width_3;
    float sky_pdf_0;
    float geometry_density_2;
    uint b_8;
    uint layer_0;
    float3  throughput_5;
    float3  chain_throughput_0;
    TreeSample light_3;
    int _S1220;
    Shift ended_0;
    float density_3;
    float spread_3;
    float width_4;
    float sky_pdf_1;
    float spread_4;
    float width_5;
    uint b_9;
    float3  _S1221 = make_float3 (0.0f);
    Shift _S1222 = Shift_x24init_0(_S1221, 0.0f);
    uint _S1223 = r_8->path;
    uint _S1224 = extractBits_0(r_8->path, 0U, 5U);
    uint _S1225 = extractBits_0(_S1223, 5U, 5U);
    uint _S1226 = extractBits_0(_S1223, 10U, 2U);
    uint _S1227 = extractBits_0(_S1223, 12U, 3U);
    bool passes_0;
    if(replay_2)
    {
        bool _S1228 = _S1227 >= 3U;
        uint _S1229 = _slang_select(_S1228, 1U,0U);
        uint _S1230 = _S1224 + _S1229;
        uint _S1231 = (fcptMaxBounces());
        passes_0 = _S1230 > _S1231;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S1222;
    }
    uint _S1232 = _S1225 - 1U;
    bool _S1233 = _S1227 == 3U;
    uint _S1234 = _slang_select(_S1233, 1U,0U);
    uint _S1235 = _S1224 + _S1234;
    bool _S1236 = _S1226 == 0U;
    uint _S1237 = _slang_select(_S1236, _S1235,_S1232);
    FKHit _S1238 = (fcptReservoirHit((*r_8)));
    float3  _S1239 = dom_7->x0;
    float3  _S1240 = dom_7->x1 - dom_7->x0;
    float3  _S1241 = ((((_S1240)) * make_float3(rnorm3df(((_S1240)).x, ((_S1240)).y, ((_S1240)).z))));
    FKRay _S1242 = Ray_x24init_0(dom_7->x1, _S1241);
    FKRay ray_2 = _S1242;
    FKHit hit_4 = dom_7->hit;
    float3  scatter_in_0 = _S1221;
    float3  throughput_6 = make_float3 (1.0f);
    float3  weight_1 = throughput_6;
    float3  glowed_0 = _S1221;
    float3  extinction_in_0 = _S1221;
    float g_in_0 = 0.0f;
    uint filling_2 = 4294967295U;
    float _S1243 = dom_7->spread;
    float _S1244 = dom_7->width;
    float _S1245 = length_0(_S1240);
    NEEVertex _S1246 = NEEVertex_x24init_0(true, 0.0f, _S1221, _S1221, _S1221);
    NEEVertex nee_vertex_0 = _S1246;
    Vertex _S1247 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_0 = _S1247;
    Reservoir _S1248 = (Reservoir{});
    Reservoir chain_0 = _S1248;
    uint _S1249 = r_8->seed;
    (&chain_0)->seed = r_8->seed;
    (&ray_2)->origin = _S1239;
    (&hit_4)->distance = _S1245;
    FKMedium _S1250 = (fcptCameraMedium(((&ray_2)->unit_direction), ((&hit_4)->distance), (&filling_2)));
    uint _S1251 = filling_2;
    bool _S1252 = (fcptVaryingUsed());
    uint _S1253 = _slang_select(_S1252, _S1251,4294967295U);
    filling_2 = _S1253;
    scatter_in_0 = _S1250.scatter;
    extinction_in_0 = _S1250.extinction;
    g_in_0 = _S1250.g;
    Reservoir _S1254 = chain_0;
    uint _S1255 = filling_2;
    for(;;)
    {
        bool _S1256 = (fcptVaryingUsed());
        if(_S1256)
        {
            passes_0 = _S1255 != 4294967295U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            float _S1257 = (fcptMajorant((_S1255)));
            spread_2 = _S1257;
        }
        else
        {
            spread_2 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
        }
        if(replay_2)
        {
            turned_1 = 4294967295U == _S1237;
        }
        else
        {
            turned_1 = false;
        }
        if(turned_1)
        {
            turned_1 = _S1226 == 1U;
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
            ended_0 = _S1222;
            sky_pdf_0 = 0.0f;
            spread_2 = _S1243;
            width_3 = _S1244;
            density_2 = 1.0f;
            throughput_5 = throughput_6;
            b_8 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S1258 = (&prev_0)->rough;
        if(_S1258)
        {
            turned_1 = !(spread_2 > 0.0f);
        }
        else
        {
            turned_1 = false;
        }
        (&prev_0)->rough = turned_1;
        uint _S1259 = stream(_S1249, 384U);
        uint tracking_0 = _S1259;
        weight_1 = throughput_6;
        glowed_0 = _S1221;
        b_8 = 4294967295U;
        throughput_5 = throughput_6;
        density_2 = 1.0f;
        threshold_2 = _S1243;
        width_3 = _S1244;
        sky_pdf_0 = 0.0f;
        for(;;)
        {
            if(((&hit_4)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S1220 = int(1);
                break;
            }
            uint _S1260 = b_8 + 320U;
            bool _S1261 = b_8 == 4294967295U;
            uint _S1262 = _slang_select(_S1261, 384U,_S1260);
            uint _S1263 = stream(_S1249, _S1262);
            Random _S1264 = pcg(_S1263);
            float _S1265 = freeFlight_0(_S1264.value, spread_2);
            if(passes_0)
            {
                float3  _S1266 = (&ray_2)->origin;
                float3  _S1267 = (&ray_2)->unit_direction;
                float _S1268 = (&hit_4)->distance;
                uint _S1269 = _slang_select(_S1261, 0U,b_8);
                uint _S1270 = (&prev_0)->lobe;
                uint _S1271 = _slang_select(_S1261, 3U,_S1270);
                float _S1272 = (fcptTrackMedium((_S1255), (_S1266), (_S1267), (_S1268), (&tracking_0), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1269), (_S1271), (_S1261)));
                geometry_density_2 = _S1272;
            }
            else
            {
                geometry_density_2 = _S1265;
            }
            bool _S1273 = !(geometry_density_2 < ((&hit_4)->distance));
            if(_S1273)
            {
                _S1220 = int(1);
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
                float3  _S1274 = throughput_5 * glowed_0 / make_float3 (density_2);
                float3  _S1275 = sel_7->glow + _S1274;
                sel_7->glow = _S1275;
            }
            else
            {
            }
            glowed_0 = _S1221;
            uint b_10 = b_8 + 1U;
            float3  _S1276 = (&ray_2)->origin + make_float3 (geometry_density_2) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S1276;
            float3  _S1277 = flightWeight_0(scatter_in_0, extinction_in_0, spread_2, geometry_density_2, true);
            float3  _S1278 = weight_1;
            float3  _S1279 = _slang_select(passes_0, _S1278,_S1277);
            float3  throughput_7 = throughput_5 * _S1279;
            uint _S1280 = stream(_S1249, b_10 + 320U);
            tracking_0 = _S1280;
            weight_1 = throughput_6;
            float width_6 = width_3 + threshold_2 * geometry_density_2;
            float _S1281 = threshold_2 + 3.14159274101257324f;
            bool _S1282 = scatterSampled_0(replay_2, b_10, _S1237, passes_0);
            TreeSample _S1283 = TreeSample_x24init_0(_S1221, _S1221, 0.0f, 0U);
            if(_S1282)
            {
                float3  _S1284 = (&ray_2)->origin;
                float3  _S1285 = (&ray_2)->unit_direction;
                float3  _S1286 = (&ray_2)->unit_direction;
                uint _S1287 = stream(_S1249, b_10 + 64U);
                float3  _S1288 = extinction_in_0;
                float3  _S1289 = extinction_in_0;
                uint2  _S1290 = make_uint2 (_S1255);
                float3  _S1291 = (&ray_2)->unit_direction;
                uint _S1292 = arrivalLobe_0(b_10, (&prev_0)->lobe);
                FKHit _S1293 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S1294 = _S1293;
                ShadowContext _S1295 = ShadowContext_x24init_0(_S1288, _S1289, _S1290, _S1291, b_10, _S1292, false, geometry_density_2, width_6, &_S1294, false);
                ShadowContext _S1296 = _S1295;
                TreeSample _S1297 = sampleLightTree_0(_S1284, _S1285, _S1286, 0.0f, true, _S1287, &_S1296);
                light_3 = _S1297;
            }
            else
            {
                light_3 = _S1283;
            }
            float _S1298 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_3.dir));
            uint _S1299 = (fcptMaxBounces());
            bool _S1300 = b_10 < _S1299;
            if(_S1300)
            {
                is_inside_5 = (light_3.density) > 0.0f;
            }
            else
            {
                is_inside_5 = false;
            }
            float _S1301 = _slang_select(is_inside_5, _S1298,0.0f);
            float3  _S1302 = throughput_7 * light_3.radiance;
            float _S1303 = powerHeuristic(light_3.density, _S1301);
            float3  _S1304 = _S1302 * make_float3 (_S1298 * _S1303);
            float3  _S1305 = _slang_select(_S1282, _S1304,_S1221);
            if(replay_2)
            {
                viewed_0 = b_10 == _S1237;
            }
            else
            {
                viewed_0 = false;
            }
            if(viewed_0)
            {
                bool _S1306 = _S1226 == 2U;
                if(_S1306)
                {
                    float _S1307 = rgb_to_greyscale(_S1305);
                    passes_0 = _S1307 > 0.0f;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S1308 = Shift_x24init_0(_S1305, 1.0f);
                    _S1220 = int(0);
                    ended_0 = _S1308;
                    spread_2 = _S1281;
                    geometry_density_2 = width_6;
                    chain_throughput_0 = throughput_7;
                    layer_0 = b_10;
                    break;
                }
                _S1220 = int(0);
                ended_0 = _S1222;
                spread_2 = _S1281;
                geometry_density_2 = width_6;
                chain_throughput_0 = throughput_7;
                layer_0 = b_10;
                break;
            }
            bool _S1309 = !replay_2;
            if(_S1309)
            {
                Reservoir candidate_3 = _S1254;
                uint _S1310 = extractBits_0(_S1254.path, 10U, 2U);
                bool _S1311 = _S1310 == 1U;
                if(_S1311)
                {
                    float3  _S1312 = safeDivide(_S1305, _S1221);
                    (&candidate_3)->radiance = _S1312;
                }
                else
                {
                    uint _S1313 = insertBits_0(0U, b_10 + 1U, 5U, 5U);
                    uint _S1314 = insertBits_0(_S1313, 2U, 10U, 2U);
                    (&candidate_3)->path = _S1314;
                }
                Reservoir _S1315 = withEnd(candidate_3, 0U, b_10, _S1305);
                offer(sel_7, _S1315, _S1305 * make_float3 (scale_3) / make_float3 (density_2));
                float _S1316 = survivalProbability(throughput_7, density_2);
                uint _S1317 = stream(_S1249, b_10 + 128U);
                Random _S1318 = pcg(_S1317);
                bool _S1319 = _S1316 < (_S1318.value);
                if(_S1319)
                {
                    _S1219 = true;
                }
                else
                {
                    uint _S1320 = (fcptMaxBounces());
                    _S1219 = b_10 >= _S1320;
                }
                if(_S1219)
                {
                    _S1220 = int(0);
                    ended_0 = _S1222;
                    spread_2 = _S1281;
                    geometry_density_2 = width_6;
                    chain_throughput_0 = throughput_7;
                    layer_0 = b_10;
                    break;
                }
                float _S1321 = density_2 * _S1316;
                density_2 = _S1321;
            }
            else
            {
            }
            float phase_pdf_0 = 0.0f;
            uint _S1322 = stream(_S1249, b_10);
            float3  _S1323 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1322, &phase_pdf_0);
            (&ray_2)->unit_direction = _S1323;
            NEEVertex _S1324 = NEEVertex_x24init_0(false, phase_pdf_0, (&ray_2)->origin, _S1221, (&ray_2)->origin);
            nee_vertex_0 = _S1324;
            Vertex _S1325 = scatteredVertex_0(false);
            prev_0 = _S1325;
            float _S1326 = (&prev_0)->pdf;
            FKRay _S1327 = ray_2;
            FKHit _S1328 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S1329 = (fcptTraverseInstanceBVH((_S1327), (true), (4.294967296e+09f), (false), (_S1328), (false)));
            hit_4 = _S1329;
            b_8 = b_10;
            throughput_5 = throughput_7;
            threshold_2 = _S1281;
            width_3 = width_6;
            sky_pdf_0 = _S1326;
        }
        if(_S1220 != int(1))
        {
            width_3 = geometry_density_2;
            throughput_5 = chain_throughput_0;
            b_8 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S1222;
        spread_2 = threshold_2;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    bool _S1330 = b_8 == 4294967295U;
    bool _S1331 = ((&hit_4)->instance_index) == 4294967295U;
    if(_S1331)
    {
        bool _S1332 = !(&nee_vertex_0)->none;
        float _S1333 = _slang_select(_S1332, sky_pdf_0,0.0f);
        float _S1334 = escapeWeight_0(_S1333, (&ray_2)->unit_direction);
        float3  _S1335 = environment_0((&ray_2)->unit_direction, b_8, (&prev_0)->lobe);
        float3  _S1336 = throughput_5 * _S1335;
        if(replay_2)
        {
            bool _S1337 = b_8 == _S1237;
            if(_S1337)
            {
                passes_0 = _S1226 == 3U;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                return Shift_x24init_0(_S1336 * make_float3 (_S1334) / make_float3 (r_8->jac), density_2 / r_8->jac);
            }
            if(_S1236)
            {
                passes_0 = _S1233;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                passes_0 = b_8 == _S1224;
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
                return Shift_x24init_0(_S1336 * make_float3 (_S1334), 1.0f);
            }
            return _S1222;
        }
        Reservoir candidate_4 = chain_0;
        uint _S1338 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1339 = _S1338 == 1U;
        if(_S1339)
        {
            uint _S1340 = extractBits_0((&chain_0)->path, 5U, 5U);
            bool _S1341 = _S1340 == b_8;
            float _S1342 = _slang_select(_S1341, 1.0f,_S1334);
            float3  _S1343 = safeDivide(_S1336 * make_float3 (_S1342), _S1221);
            (&candidate_4)->radiance = _S1343;
        }
        else
        {
            bool _S1344 = (&prev_0)->rough;
            if(_S1344)
            {
                uint _S1345 = insertBits_0(0U, b_8 + 1U, 5U, 5U);
                uint _S1346 = insertBits_0(_S1345, 3U, 10U, 2U);
                uint _S1347 = insertBits_0(_S1346, (&prev_0)->lobe, 15U, 3U);
                bool _S1348 = (&prev_0)->inside;
                uint _S1349 = _slang_select(_S1348, 1U,0U);
                uint _S1350 = insertBits_0(_S1347, _S1349, 22U, 1U);
                (&candidate_4)->path = _S1350;
                (&candidate_4)->jac = (&prev_0)->pdf;
                (&candidate_4)->dir = (&ray_2)->unit_direction;
            }
        }
        float3  _S1351 = _S1336 * make_float3 (_S1334);
        Reservoir _S1352 = withEnd(candidate_4, 3U, b_8, _S1351);
        offer(sel_7, _S1352, _S1351 * make_float3 (scale_3) / make_float3 (density_2));
        return _S1222;
    }
    float3  _S1353 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
    (&ray_2)->origin = _S1353;
    bool _S1354 = (fcptVaryingUsed());
    if(_S1354)
    {
        passes_0 = filling_2 != 4294967295U;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        bool _S1355 = !replay_2;
        if(_S1355)
        {
            float3  _S1356 = throughput_5 * glowed_0 / make_float3 (density_2);
            float3  _S1357 = sel_7->glow + _S1356;
            sel_7->glow = _S1357;
        }
        float3  _S1358 = throughput_5 * weight_1;
        throughput_5 = _S1358;
    }
    else
    {
        float3  _S1359 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
        float3  _S1360 = throughput_5 * _S1359;
        throughput_5 = _S1360;
    }
    float _S1361 = width_3 + spread_2 * (&hit_4)->distance;
    uint _S1362 = b_8 + 1U;
    b_8 = _S1362;
    layer_0 = 0U;
    width_3 = _S1361;
    passes_0 = false;
    threshold_2 = 0.0f;
    turned_1 = false;
    is_inside_5 = false;
    chain_throughput_0 = _S1221;
    float3  reconnection_0 = _S1221;
    viewed_0 = _S1330;
    for(;;)
    {
        bool _S1363 = ((&hit_4)->is_point_light) == 1U;
        if(replay_2)
        {
            _S1219 = _S1226 == 1U;
        }
        else
        {
            _S1219 = false;
        }
        bool _S1364;
        if(_S1219)
        {
            _S1364 = b_8 == _S1225;
        }
        else
        {
            _S1364 = false;
        }
        bool _S1365;
        if(_S1364)
        {
            bool _S1366 = ((&hit_4)->instance_index) != (_S1238.instance_index);
            if(_S1366)
            {
                _S1365 = true;
            }
            else
            {
                _S1365 = ((&hit_4)->triangle_index) != (_S1238.triangle_index);
            }
        }
        else
        {
            _S1365 = false;
        }
        if(_S1365)
        {
            return _S1222;
        }
        FKMedium _S1367 = Medium_x24init_0(_S1221, _S1221, 0.0f);
        BSDFMaterial _S1368 = Material_x24init_0(_S1221, _S1221, 0.0f, 0.0f, 0.0f, 0.0f, _S1221, throughput_6, 1.0f, _S1221, _S1221, 0.5f, 0.0f, 0.0f, _S1221, 0.0f, _S1221);
        FKMedium _S1369 = _S1367;
        FKSurface _S1370 = Surface_x24init_0(_S1221, _S1221, 0.0f, &_S1368, false, 0U, 1.0f, false, &_S1369, 4294967295U, _S1221);
        bool _S1371 = !_S1363;
        bool scatter_2;
        bool is_inside_6;
        float3  throughput_8;
        FKSurface surface_11;
        if(_S1371)
        {
            uint _S1372 = stream(_S1249, b_8);
            uint _S1373 = arrivalLobe_0(b_8, (&prev_0)->lobe);
            FKSurface _S1374 = (fcptSurfaceAtPath((hit_4), ((&ray_2)->origin), (_S1372), (width_3), (layer_0), (b_8), (_S1373), ((&ray_2)->unit_direction)));
            bool _S1375 = !passes_0;
            FKSurface _S1376 = _S1374;
            FKSurface _S1377 = emitting_0(&_S1376, _S1375);
            uint _S1378 = stream(_S1249, b_8 + 256U);
            Random _S1379 = pcg(_S1378);
            FKSurface _S1380 = _S1377;
            FKSurface _S1381 = uncovered_0(&_S1380, _S1379.value);
            float _S1382 = facingSign(_S1381.material.transmission, _S1381.geometry_n, (&ray_2)->unit_direction);
            bool _S1383 = _S1382 < 0.0f;
            bool _S1384 = (_S1381.material.transmission) > 0.0f;
            if(_S1384)
            {
                bool _S1385 = arrivesBehind_0((&ray_2)->unit_direction, _S1381.geometry_n);
                scatter_2 = _S1385;
            }
            else
            {
                scatter_2 = false;
            }
            FKSurface _S1386 = _S1381;
            FKSurface _S1387 = facingRay_0(&_S1386, (&ray_2)->unit_direction);
            if(passes_0)
            {
                bool _S1388 = arrivesBehind_0((&ray_2)->unit_direction, _S1387.geometry_n);
                is_inside_6 = _S1388;
            }
            else
            {
                is_inside_6 = scatter_2;
            }
            if(is_inside_6)
            {
                float3  _S1389 = beerLambert((&hit_4)->distance, _S1387.material.absorption);
                float3  _S1390 = throughput_5 * _S1389;
                throughput_8 = _S1390;
            }
            else
            {
                throughput_8 = throughput_5;
            }
            bool _S1391 = !_S1387.skip;
            float geometry_density_3 = geometryDensity(_S1387.geometry_n, (&ray_2)->unit_direction, (&hit_4)->distance);
            bool _S1392 = b_8 == _S1362;
            if(_S1392)
            {
                float _S1393 = footprintThreshold(geometry_density_3);
                geometry_density_2 = _S1393;
            }
            else
            {
                geometry_density_2 = threshold_2;
            }
            float _S1394 = geometry_density_2;
            scatter_2 = _S1391;
            geometry_density_2 = geometry_density_3;
            threshold_2 = _S1394;
            surface_11 = _S1387;
            turned_1 = _S1383;
        }
        else
        {
            scatter_2 = false;
            geometry_density_2 = 0.0f;
            surface_11 = _S1370;
            throughput_8 = throughput_5;
            is_inside_6 = is_inside_5;
        }
        bool _S1395 = withinFootprint(scatter_2, (&prev_0)->rough, (&prev_0)->pdf, geometry_density_2, threshold_2);
        FKSurface _S1396 = surface_11;
        FKSurface _S1397 = surface_11;
        float _S1398 = dot_0(surface_11.smooth_n, - (&ray_2)->unit_direction);
        float2  _S1399 = vertexEta(_S1396.material, _S1398);
        bool _S1400;
        if(scatter_2)
        {
            bool _S1401 = neeDecision(_S1396.material, _S1398, _S1399.x, _S1399.y);
            _S1400 = _S1401;
        }
        else
        {
            _S1400 = false;
        }
        bool _S1402;
        if(passes_0)
        {
            _S1402 = true;
        }
        else
        {
            _S1402 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S1402)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S1400;
        }
        bool _S1403 = (fcptHairUsed());
        bool _S1404;
        if(_S1403)
        {
            float3  _S1405 = surface_11.hair;
            _S1404 = (dot_0(_S1405, _S1405)) > 0.0f;
        }
        else
        {
            _S1404 = false;
        }
        bool _S1406;
        if(_S1404)
        {
            _S1406 = true;
        }
        else
        {
            BSDFMaterial _S1407 = _S1396.material;
            bool _S1408 = isTranslucent_0(&_S1407);
            _S1406 = _S1408;
        }
        bool _S1409;
        if(_S1406)
        {
            _S1409 = true;
        }
        else
        {
            bool _S1410 = (_S1396.material.transmission) > 0.0f;
            if(_S1410)
            {
                uint _S1411 = (fcptLayers((hit_4)));
                _S1409 = _S1411 == 1U;
            }
            else
            {
                _S1409 = false;
            }
        }
        float3  emission_0;
        if(_S1363)
        {
            float3  _S1412 = (fcptCalculatePointLightContrib(((&hit_4)->instance_index)));
            emission_0 = _S1412;
        }
        else
        {
            emission_0 = _S1396.material.emissive;
        }
        float _S1413 = rgb_to_greyscale(emission_0);
        bool _S1414 = _S1413 > 0.0f;
        float3  emission_1;
        if(_S1414)
        {
            NEEVertex _S1415 = nee_vertex_0;
            FKHit _S1416 = hit_4;
            float _S1417 = emissionWeight_0(&_S1415, &_S1416, (&ray_2)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S1417);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S1418;
        if(replay_2)
        {
            _S1418 = _S1226 == 1U;
        }
        else
        {
            _S1418 = false;
        }
        bool _S1419;
        if(_S1418)
        {
            _S1419 = b_8 > _S1225;
        }
        else
        {
            _S1419 = false;
        }
        bool _S1420;
        if(_S1419)
        {
            _S1420 = b_8 == _S1224;
        }
        else
        {
            _S1420 = false;
        }
        bool _S1421;
        if(_S1420)
        {
            bool _S1422 = _S1227 == 1U;
            if(_S1422)
            {
                _S1421 = true;
            }
            else
            {
                _S1421 = _S1227 == 2U;
            }
        }
        else
        {
            _S1421 = false;
        }
        if(_S1421)
        {
            bool _S1423 = _S1363 != (_S1227 == 2U);
            if(_S1423)
            {
                return _S1222;
            }
            return Shift_x24init_0(throughput_8 * emission_1 / make_float3 (r_8->jac), density_2 / r_8->jac);
        }
        uint _S1424 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1425 = _S1424 == 1U;
        Reservoir here_0 = chain_0;
        uint _S1426 = insertBits_0(0U, b_8, 5U, 5U);
        uint _S1427 = insertBits_0(_S1426, 1U, 10U, 2U);
        uint _S1428 = insertBits_0(_S1427, (&prev_0)->lobe, 15U, 3U);
        bool _S1429 = (&prev_0)->inside;
        uint _S1430 = _slang_select(_S1429, 1U,0U);
        uint _S1431 = insertBits_0(_S1428, _S1430, 22U, 1U);
        (&here_0)->path = _S1431;
        float _S1432 = (&prev_0)->pdf * geometry_density_2;
        (&here_0)->jac = _S1432;
        fcptWithReservoirHit((&here_0), (&hit_4));
        bool _S1433;
        if(replay_2)
        {
            _S1433 = _S1226 == 1U;
        }
        else
        {
            _S1433 = false;
        }
        bool _S1434;
        if(_S1433)
        {
            _S1434 = b_8 == _S1225;
        }
        else
        {
            _S1434 = false;
        }
        bool _S1435 = b_8 == _S1237;
        bool _S1436;
        if(_S1435)
        {
            bool _S1437 = !scatter_2;
            if(_S1437)
            {
                _S1436 = true;
            }
            else
            {
                bool _S1438 = _S1226 != 1U;
                if(_S1438)
                {
                    _S1436 = _S1226 != 3U;
                }
                else
                {
                    _S1436 = false;
                }
            }
        }
        else
        {
            _S1436 = false;
        }
        bool _S1439;
        if(_S1436)
        {
            _S1439 = _S1226 == 2U;
        }
        else
        {
            _S1439 = false;
        }
        bool _S1440;
        if(_S1439)
        {
            _S1440 = !_S1395;
        }
        else
        {
            _S1440 = false;
        }
        bool _S1441;
        if(_S1440)
        {
            _S1441 = _S1227 != 4U;
        }
        else
        {
            _S1441 = false;
        }
        bool _S1442 = _S1225 == _S1224;
        bool _S1443;
        if(_S1442)
        {
            _S1443 = _S1227 == 0U;
        }
        else
        {
            _S1443 = false;
        }
        bool _S1444;
        if(_S1443)
        {
            _S1444 = ((&hit_4)->instance_index) == (_S1238.instance_index);
        }
        else
        {
            _S1444 = false;
        }
        bool _S1445;
        if(_S1444)
        {
            _S1445 = ((&hit_4)->triangle_index) == (_S1238.triangle_index);
        }
        else
        {
            _S1445 = false;
        }
        bool _S1446;
        if(_S1445)
        {
            _S1446 = _S1395;
        }
        else
        {
            _S1446 = false;
        }
        bool _S1447 = _slang_select(_S1434, _S1446,_S1441);
        bool _S1448;
        if(nee_0)
        {
            _S1448 = _slang_select(replay_2, _S1447,scatter_2);
        }
        else
        {
            _S1448 = false;
        }
        TreeSample _S1449 = TreeSample_x24init_0(_S1221, _S1221, 0.0f, 0U);
        uint2  _S1450 = make_uint2 (0U);
        float2  _S1451 = make_float2 (0.0f);
        FKHit _S1452 = Hit_x24init_0(_S1451, 4294967295U, 0U, 0U, 0.0f);
        FKHit _S1453 = _S1452;
        ShadowContext _S1454 = ShadowContext_x24init_0(_S1221, _S1221, _S1450, _S1221, 0U, 0U, false, 0.0f, 0.0f, &_S1453, false);
        ShadowContext context_5;
        if(nee_0)
        {
            uint _S1455 = arrivalLobe_0(b_8, (&prev_0)->lobe);
            FKMedium _S1456 = (fcptOutsideMedium((hit_4)));
            FKSurface _S1457 = surface_11;
            FKHit _S1458 = hit_4;
            FKMedium _S1459 = _S1456;
            ShadowContext _S1460 = shadowContext_0(&_S1457, turned_1, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_8, _S1455, (&hit_4)->distance, width_3, &_S1458, _S1404, &_S1459);
            context_5 = _S1460;
        }
        else
        {
            context_5 = _S1454;
        }
        float3  throughput_9;
        float3  lit_0;
        if(_S1448)
        {
            float3  _S1461 = (&ray_2)->origin;
            if(_S1404)
            {
                throughput_9 = _S1221;
            }
            else
            {
                throughput_9 = _S1397.smooth_n;
            }
            FKSurface _S1462 = surface_11;
            uint _S1463 = stream(_S1249, b_8 + 64U);
            ShadowContext _S1464 = context_5;
            TreeSample _S1465 = sampleLightTree_0(_S1461, throughput_9, surface_11.geometry_n, surface_11.geometry_offset, _S1409, _S1463, &_S1464);
            bool _S1466 = any_1((_S1465.radiance) != _S1221);
            if(_S1466)
            {
                if(_S1404)
                {
                    uint _S1467 = (fcptMaxBounces());
                    bool _S1468 = b_8 < _S1467;
                    FKSurface _S1469 = surface_11;
                    TreeSample _S1470 = _S1465;
                    float3  _S1471 = hairLight_0(&_S1469, (&ray_2)->unit_direction, &_S1470, _S1468);
                    lit_0 = _S1471;
                }
                else
                {
                    float _S1472 = _S1399.x;
                    float _S1473 = _S1399.y;
                    uint _S1474 = (fcptMaxBounces());
                    bool _S1475 = b_8 < _S1474;
                    TreeSample _S1476 = _S1465;
                    BSDFMaterial _S1477 = _S1396.material;
                    float3  _S1478 = lightBSDF_0((&ray_2)->unit_direction, &_S1476, _S1397.smooth_n, _S1462.geometry_n, &_S1477, _S1472, _S1473, _S1475, surface_11.random_state);
                    lit_0 = _S1478;
                }
            }
            else
            {
                lit_0 = _S1221;
            }
            light_3 = _S1465;
        }
        else
        {
            light_3 = _S1449;
            lit_0 = _S1221;
        }
        bool viewed_1;
        bool refracted_5;
        bool wrong_side_0;
        bool _S1479;
        bool _S1480;
        float density_4;
        if(_S1434)
        {
            bool _S1481 = !_S1395;
            if(_S1481)
            {
                return _S1222;
            }
            float3  throughput_10 = throughput_8 * make_float3 (geometry_density_2);
            float density_5 = density_2 * geometry_density_2;
            if(_S1442)
            {
                viewed_1 = _S1227 == 1U;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                return Shift_x24init_0(throughput_10 * emission_1 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1442)
            {
                refracted_5 = _S1227 == 0U;
            }
            else
            {
                refracted_5 = false;
            }
            if(refracted_5)
            {
                bool _S1482 = !nee_0;
                if(_S1482)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S1483 = rgb_to_greyscale(light_3.radiance);
                    passes_0 = !(_S1483 > 0.0f);
                }
                if(passes_0)
                {
                    return _S1222;
                }
                return Shift_x24init_0(throughput_10 * lit_0 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1442)
            {
                wrong_side_0 = _S1227 == 4U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                bool _S1484 = !nee_0;
                if(_S1484)
                {
                    return _S1222;
                }
                float _S1485 = environmentPdf_0(r_8->dir);
                float3  _S1486 = skyBSDF((&ray_2)->unit_direction, r_8->dir, surface_11, _S1399, is_inside_6, _S1485, surface_11.random_state);
                return Shift_x24init_0(throughput_10 * _S1486 * r_8->radiance / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            uint _S1487 = extractBits_0(_S1223, 21U, 1U);
            bool _S1488 = nee_0 != (_S1487 == 1U);
            if(_S1488)
            {
                return _S1222;
            }
            throughput_9 = throughput_10;
            density_4 = density_5;
        }
        else
        {
            if(replay_2)
            {
                viewed_1 = _S1435;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                bool _S1489 = !scatter_2;
                if(_S1489)
                {
                    refracted_5 = true;
                }
                else
                {
                    bool _S1490 = _S1226 != 1U;
                    if(_S1490)
                    {
                        refracted_5 = _S1226 != 3U;
                    }
                    else
                    {
                        refracted_5 = false;
                    }
                }
            }
            else
            {
                refracted_5 = false;
            }
            if(refracted_5)
            {
                bool _S1491 = _S1226 == 2U;
                if(_S1491)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1395;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1227 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    if(_S1404)
                    {
                        return _S1222;
                    }
                    uint _S1492 = stream(_S1249, b_8 + 448U);
                    FKRay _S1493 = ray_2;
                    FKSurface _S1494 = surface_11;
                    ShadowContext _S1495 = context_5;
                    SkySample _S1496 = sampleSky_0(&_S1493, &_S1494, _S1399, is_inside_6, _S1492, surface_11.random_state, &_S1495);
                    return Shift_x24init_0(throughput_8 * _S1496.color, 1.0f);
                }
                if(_S1491)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1395;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float _S1497 = rgb_to_greyscale(light_3.radiance);
                    bool _S1498 = !(_S1497 > 0.0f);
                    if(_S1498)
                    {
                        return _S1222;
                    }
                    return Shift_x24init_0(throughput_8 * lit_0, 1.0f);
                }
                if(_S1236)
                {
                    passes_0 = _S1227 == 2U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1363;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_8 * emission_1, 1.0f);
                }
                if(_S1236)
                {
                    passes_0 = _S1227 == 1U;
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
                    passes_0 = !_S1395;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_8 * emission_1, 1.0f);
                }
                return _S1222;
            }
            else
            {
                bool _S1499 = !replay_2;
                if(_S1499)
                {
                    wrong_side_0 = scatter_2;
                }
                else
                {
                    wrong_side_0 = false;
                }
                if(wrong_side_0)
                {
                    bool _S1500 = b_8 > 0U;
                    if(_S1500)
                    {
                        Reservoir candidate_5 = chain_0;
                        if(_S1425)
                        {
                            float3  _S1501 = safeDivide(throughput_8 * emission_1, chain_throughput_0);
                            (&candidate_5)->radiance = _S1501;
                        }
                        else
                        {
                            if(_S1395)
                            {
                                candidate_5 = here_0;
                            }
                        }
                        float3  _S1502 = throughput_8 * emission_1;
                        Reservoir _S1503 = withEnd(candidate_5, 1U, b_8, _S1502);
                        offer(sel_7, _S1503, _S1502 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    else
                    {
                        float3  _S1504 = throughput_8 * emission_1;
                        float3  _S1505 = sel_7->glow + _S1504;
                        sel_7->glow = _S1505;
                    }
                    if(nee_0)
                    {
                        float3  _S1506 = throughput_8 * lit_0;
                        Reservoir candidate_6 = chain_0;
                        if(_S1425)
                        {
                            float3  _S1507 = safeDivide(_S1506, chain_throughput_0);
                            (&candidate_6)->radiance = _S1507;
                        }
                        else
                        {
                            if(_S1395)
                            {
                                candidate_6 = here_0;
                                uint _S1508 = insertBits_0((&candidate_6)->path, 1U, 21U, 1U);
                                (&candidate_6)->path = _S1508;
                                (&candidate_6)->dir = light_3.dir;
                                (&candidate_6)->radiance = light_3.radiance;
                            }
                            else
                            {
                                uint _S1509 = insertBits_0(0U, b_8 + 1U, 5U, 5U);
                                uint _S1510 = insertBits_0(_S1509, 2U, 10U, 2U);
                                (&candidate_6)->path = _S1510;
                            }
                        }
                        Reservoir _S1511 = withEnd(candidate_6, 0U, b_8, _S1506);
                        offer(sel_7, _S1511, _S1506 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    if(nee_0)
                    {
                        if(_S1404)
                        {
                            _S1479 = false;
                        }
                        else
                        {
                            bool _S1512 = environmentMapped_0();
                            _S1479 = _S1512;
                        }
                    }
                    else
                    {
                        _S1479 = false;
                    }
                    if(_S1479)
                    {
                        uint _S1513 = (fcptMaxBounces());
                        _S1480 = b_8 < _S1513;
                    }
                    else
                    {
                        _S1480 = false;
                    }
                    if(_S1480)
                    {
                        uint _S1514 = stream(_S1249, b_8 + 448U);
                        FKRay _S1515 = ray_2;
                        FKSurface _S1516 = surface_11;
                        ShadowContext _S1517 = context_5;
                        SkySample _S1518 = sampleSky_0(&_S1515, &_S1516, _S1399, is_inside_6, _S1514, surface_11.random_state, &_S1517);
                        float3  _S1519 = throughput_8 * _S1518.color;
                        Reservoir candidate_7 = chain_0;
                        if(_S1425)
                        {
                            float3  _S1520 = safeDivide(_S1519, chain_throughput_0);
                            (&candidate_7)->radiance = _S1520;
                        }
                        else
                        {
                            if(_S1395)
                            {
                                candidate_7 = here_0;
                                uint _S1521 = insertBits_0((&candidate_7)->path, 1U, 21U, 1U);
                                (&candidate_7)->path = _S1521;
                                (&candidate_7)->dir = _S1518.dir;
                                (&candidate_7)->radiance = _S1518.radiance;
                            }
                            else
                            {
                                uint _S1522 = insertBits_0(0U, b_8 + 1U, 5U, 5U);
                                uint _S1523 = insertBits_0(_S1522, 2U, 10U, 2U);
                                (&candidate_7)->path = _S1523;
                            }
                        }
                        Reservoir _S1524 = withEnd(candidate_7, 4U, b_8, _S1519);
                        offer(sel_7, _S1524, _S1519 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                }
            }
            throughput_9 = throughput_8;
            density_4 = density_2;
        }
        bool _S1525;
        bool _S1526;
        bool _S1527;
        bool straight_0;
        bool _S1528;
        bool _S1529;
        bool _S1530;
        bool _S1531;
        bool _S1532;
        bool _S1533;
        bool _S1534;
        bool _S1535;
        bool _S1536;
        bool _S1537;
        bool _S1538;
        bool _S1539;
        float density_6;
        float sky_pdf_2;
        float spread_5;
        uint b_11;
        float3  throughput_11;
        float3  throughput_12;
        float3  throughput_13;
        if(scatter_2)
        {
            if(replay_2)
            {
                viewed_1 = _S1435;
            }
            else
            {
                viewed_1 = false;
            }
            uint _S1540 = extractBits_0(_S1223, 15U, 3U);
            uint _S1541 = extractBits_0(_S1223, 18U, 3U);
            uint _S1542 = _slang_select(_S1434, _S1541,_S1540);
            float3  _S1543 = r_8->dir;
            bool refracted_6 = _S1542 == 1U;
            SampleBSDF _S1544 = SampleBSDF_x24init_0(_S1221, _S1221, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_5 = _S1544;
            float3  reconnection_1;
            if(viewed_1)
            {
                uint _S1545 = extractBits_0(_S1223, 22U, 1U);
                bool _S1546 = is_inside_6 != (_S1545 == 1U);
                if(_S1546)
                {
                    return _S1222;
                }
                bool _S1547 = _S1226 == 1U;
                if(_S1547)
                {
                    float3  _S1548 = (fcptHitPosition((_S1238)));
                    throughput_11 = _S1548;
                }
                else
                {
                    throughput_11 = reconnection_0;
                }
                if(refracted_6)
                {
                    refracted_5 = true;
                }
                else
                {
                    BSDFMaterial _S1549 = _S1396.material;
                    bool _S1550 = isTranslucent_0(&_S1549);
                    if(_S1550)
                    {
                        refracted_5 = _S1542 == 0U;
                    }
                    else
                    {
                        refracted_5 = false;
                    }
                    if(refracted_5)
                    {
                        float3  _S1551 = throughput_11 - (&ray_2)->origin;
                        float3  _S1552 = _slang_select(_S1547, _S1551,_S1543);
                        wrong_side_0 = (dot_0(_S1397.smooth_n, _S1552) * _S1398) < 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    refracted_5 = wrong_side_0;
                }
                if(_S1547)
                {
                    float3  _S1553 = (&ray_2)->origin;
                    FKSurface _S1554 = surface_11;
                    float3  _S1555 = - _S1397.smooth_n;
                    bool _S1556 = is_inside_6 != refracted_5;
                    float3  _S1557 = _slang_select(_S1556, _S1555,_S1397.smooth_n);
                    float3  _S1558 = throughput_11 - (_S1553 + make_float3 (_S1554.geometry_offset) * _S1557);
                    float3  _S1559 = ((((_S1558)) * make_float3(rnorm3df(((_S1558)).x, ((_S1558)).y, ((_S1558)).z))));
                    reconnection_1 = _S1559;
                }
                else
                {
                    reconnection_1 = _S1543;
                }
                if(_S1404)
                {
                    wrong_side_0 = false;
                }
                else
                {
                    bool _S1560 = wrongSide_0(is_inside_6, refracted_5, reconnection_1, surface_11.geometry_n);
                    wrong_side_0 = _S1560;
                }
                if(wrong_side_0)
                {
                    return _S1222;
                }
                float3  _S1561 = throughput_11;
                throughput_11 = reconnection_1;
                b_11 = _S1542;
                wrong_side_0 = false;
                reconnection_1 = _S1561;
            }
            else
            {
                bool _S1562 = !_S1434;
                if(_S1562)
                {
                    SampleBSDF bsdf_sampled_0;
                    SampleBSDF _S1563;
                    if(_S1404)
                    {
                        SampleBSDF _S1564 = (fcptSampleHair((surface_11.hair), (_S1396.material.albedo), (_S1396.material.specular_tint), ((&ray_2)->unit_direction), (surface_11.random_state)));
                        _S1563 = _S1564;
                    }
                    else
                    {
                        SampleBSDF _S1565 = sampleBSDF((&ray_2)->unit_direction, _S1397.smooth_n, _S1396.material, _S1399.x, _S1399.y, surface_11.random_state, _S1451);
                        _S1563 = _S1565;
                    }
                    bsdf_sampled_0 = _S1563;
                    if(_S1404)
                    {
                        refracted_5 = !(((&bsdf_sampled_0)->pdf) > 0.0f);
                    }
                    else
                    {
                        refracted_5 = false;
                    }
                    if(refracted_5)
                    {
                        if(replay_2)
                        {
                            return _S1222;
                        }
                        break;
                    }
                    if(_S1404)
                    {
                        wrong_side_0 = false;
                    }
                    else
                    {
                        bool _S1566 = wrongSide_0(is_inside_6, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, surface_11.geometry_n);
                        wrong_side_0 = _S1566;
                    }
                    if(wrong_side_0)
                    {
                        _S1479 = (_S1396.material.transmission) > 0.0f;
                    }
                    else
                    {
                        _S1479 = false;
                    }
                    if(_S1479)
                    {
                        SampleBSDF _S1567 = sampleBSDF((&bsdf_sampled_0)->unit_direction, surface_11.geometry_n, _S1396.material, _S1399.x, _S1399.y, (&bsdf_sampled_0)->random_state, _S1451);
                        (&bsdf_sampled_0)->unit_direction = _S1567.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1567.refracted;
                        (&bsdf_sampled_0)->throughput = _S1567.throughput;
                    }
                    else
                    {
                        if(wrong_side_0)
                        {
                            float3  _S1568 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, surface_11.geometry_n)) * surface_11.geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1568;
                        }
                    }
                    uint _S1569 = (&bsdf_sampled_0)->lobe;
                    float3  _S1570 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1571 = (&bsdf_sampled_0)->refracted;
                    lobe_5 = bsdf_sampled_0;
                    float _S1572 = (&bsdf_sampled_0)->pdf;
                    float _S1573 = _slang_select(wrong_side_0, 0.0f,_S1572);
                    (&lobe_5)->pdf = _S1573;
                    throughput_11 = _S1570;
                    b_11 = _S1569;
                    refracted_5 = _S1571;
                }
                else
                {
                    throughput_11 = _S1543;
                    b_11 = _S1542;
                    wrong_side_0 = false;
                    refracted_5 = refracted_6;
                }
                reconnection_1 = reconnection_0;
            }
            if(viewed_1)
            {
                _S1479 = true;
            }
            else
            {
                _S1479 = _S1434;
            }
            float3  chain_throughput_1;
            if(_S1479)
            {
                if(_S1404)
                {
                    SampleBSDF _S1574 = (fcptConnectHair((surface_11.hair), (_S1396.material.albedo), (_S1396.material.specular_tint), ((&ray_2)->unit_direction), (throughput_11)));
                    lobe_5 = _S1574;
                }
                else
                {
                    float3  _S1575 = (&ray_2)->unit_direction;
                    float _S1576 = sign_0(_S1398);
                    float3  _S1577 = _S1397.smooth_n * make_float3 (_S1576);
                    float _S1578 = dot_0(_S1577, throughput_11);
                    float _S1579 = _S1396.material.roughness;
                    float _S1580 = _S1579 * _S1579;
                    AnisotropicFrame _S1581 = anisotropicFrame(_S1396.material, _S1577);
                    float3  _S1582 = reflectedHalf(_S1575, throughput_11);
                    bool _S1583 = b_11 == 1U;
                    if(_S1583)
                    {
                        float3  _S1584 = refractedHalf(_S1575, throughput_11, _S1397.smooth_n, _S1399.x, _S1399.y);
                        throughput_12 = _S1584;
                    }
                    else
                    {
                        throughput_12 = _S1582;
                    }
                    bool _S1585 = b_11 == 0U;
                    if(_S1585)
                    {
                        _S1480 = true;
                    }
                    else
                    {
                        _S1480 = b_11 == 6U;
                    }
                    if(_S1480)
                    {
                        float3  _S1586 = sampledHalf(_S1575, _S1397.smooth_n, _S1396.material, surface_11.random_state, _S1581);
                        throughput_13 = _S1586;
                    }
                    else
                    {
                        throughput_13 = throughput_12;
                    }
                    float3  _S1587 = negate_0(_S1575);
                    float _S1588 = _S1399.x;
                    float _S1589 = _S1399.y;
                    BSDFLobes _S1590 = bsdfLobes(_S1575, _S1587, _S1577, throughput_13, _S1396.material, _S1588, _S1589, _S1581);
                    BSDFLobes lobe_terms_2 = _S1590;
                    float _S1591 = translucentShare(_S1396.material);
                    (&lobe_terms_2)->translucent_share = _S1591;
                    switch(b_11)
                    {
                    case 0U:
                        {
                            float _S1592 = diffusePDF(_S1578, 0.0f, (F32_abs((_S1398))), _S1580, lobe_terms_2, _S1588, _S1589);
                            float3  _S1593 = diffuseBSDF(throughput_11, _S1577, _S1580, _S1396.material, lobe_terms_2);
                            density_6 = _S1592;
                            chain_throughput_1 = _S1593;
                            break;
                        }
                    case 1U:
                        {
                            float _S1594 = refractPDF(_S1578, dot_0(throughput_11, throughput_13), (F32_abs((_S1398))), _S1580, lobe_terms_2, _S1588, _S1589);
                            float3  _S1595 = refractBSDF(throughput_11, _S1577, _S1580, _S1396.material, lobe_terms_2);
                            density_6 = _S1594;
                            chain_throughput_1 = _S1595;
                            break;
                        }
                    case 4U:
                        {
                            float _S1596 = sheenVelvetPDF(_S1578, 0.0f, (F32_abs((_S1398))), _S1580, lobe_terms_2, _S1588, _S1589);
                            float3  _S1597 = sheenVelvetBSDF(throughput_11, _S1577, _S1580, _S1396.material, lobe_terms_2);
                            density_6 = _S1596;
                            chain_throughput_1 = _S1597;
                            break;
                        }
                    case 6U:
                        {
                            float _S1598 = toonPDF(_S1578, dot_0(throughput_11, (&lobe_terms_2)->toon_axis), (F32_abs((_S1398))), _S1580, lobe_terms_2, _S1588, _S1589);
                            float3  _S1599 = toonBSDF(throughput_11, _S1577, _S1580, _S1396.material, lobe_terms_2);
                            density_6 = _S1598;
                            chain_throughput_1 = _S1599;
                            break;
                        }
                    default:
                        {
                            float _S1600 = reflectPDF(_S1578, 0.0f, (F32_abs((_S1398))), _S1580, lobe_terms_2, _S1588, _S1589);
                            float3  _S1601 = reflectBSDF(throughput_11, _S1577, _S1580, _S1396.material, lobe_terms_2);
                            density_6 = _S1600;
                            chain_throughput_1 = _S1601;
                            break;
                        }
                    }
                    bool _S1602 = density_6 > 0.0f;
                    if(_S1602)
                    {
                        SampleBSDF _S1603 = SampleBSDF_x24init_0(throughput_11, chain_throughput_1, surface_11.random_state, _S1583, b_11, density_6);
                        lobe_5 = _S1603;
                    }
                }
            }
            bool _S1604 = b_11 == 0U;
            if(_S1604)
            {
                _S1480 = true;
            }
            else
            {
                _S1480 = b_11 == 4U;
            }
            if(_S1480)
            {
                _S1525 = true;
            }
            else
            {
                _S1525 = b_11 == 6U;
            }
            if(_S1404)
            {
                _S1526 = false;
            }
            else
            {
                bool _S1605 = !_S1525;
                if(_S1605)
                {
                    bool _S1606 = (_S1396.material.roughness) == 0.0f;
                    if(_S1606)
                    {
                        _S1526 = true;
                    }
                    else
                    {
                        bool _S1607 = b_11 == 1U;
                        if(_S1607)
                        {
                            _S1526 = (_S1399.x) == (_S1399.y);
                        }
                        else
                        {
                            _S1526 = false;
                        }
                    }
                }
                else
                {
                    _S1526 = false;
                }
            }
            bool _S1608 = !_S1404;
            if(_S1608)
            {
                _S1527 = b_11 == 1U;
            }
            else
            {
                _S1527 = false;
            }
            if(_S1527)
            {
                straight_0 = (_S1396.material.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S1528 = _S1608;
            }
            else
            {
                _S1528 = false;
            }
            if(_S1528)
            {
                _S1529 = b_11 == 1U;
            }
            else
            {
                _S1529 = false;
            }
            if(_S1529)
            {
                _S1530 = (_S1399.x) == (_S1399.y);
            }
            else
            {
                _S1530 = false;
            }
            BSDFMaterial _S1609 = _S1396.material;
            bool _S1610 = isTranslucent_0(&_S1609);
            if(_S1610)
            {
                _S1531 = _S1604;
            }
            else
            {
                _S1531 = false;
            }
            if(_S1531)
            {
                _S1532 = (dot_0(throughput_11, surface_11.geometry_n)) < 0.0f;
            }
            else
            {
                _S1532 = false;
            }
            if(nee_0)
            {
                _S1533 = !_S1526;
            }
            else
            {
                _S1533 = false;
            }
            if(_S1533)
            {
                _S1534 = !wrong_side_0;
            }
            else
            {
                _S1534 = false;
            }
            if(_S1534)
            {
                float _S1611 = (&lobe_5)->pdf;
                float3  _S1612 = (&ray_2)->origin;
                float3  _S1613 = _slang_select(_S1409, _S1221,_S1397.smooth_n);
                float3  _S1614 = (&ray_2)->origin;
                FKSurface _S1615 = surface_11;
                float3  _S1616 = - _S1397.smooth_n;
                float3  _S1617 = _slang_select(_S1532, _S1616,_S1397.smooth_n);
                NEEVertex _S1618 = NEEVertex_x24init_0(false, _S1611, _S1612, _S1613, _S1614 + make_float3 (_S1615.geometry_offset) * _S1617);
                nee_vertex_0 = _S1618;
            }
            else
            {
                if(_S1404)
                {
                    _S1535 = true;
                }
                else
                {
                    bool _S1619 = b_11 != 1U;
                    if(_S1619)
                    {
                        _S1535 = true;
                    }
                    else
                    {
                        _S1535 = (_S1399.x) != (_S1399.y);
                    }
                }
                if(_S1535)
                {
                    (&nee_vertex_0)->none = true;
                }
            }
            bool _S1620 = withinInverseFootprint((&lobe_5)->pdf, _S1525, (&prev_0)->cos, (&hit_4)->distance, threshold_2);
            bool _S1621 = roughLobe((&lobe_5)->pdf, _S1525, _S1396.material.roughness);
            if(_S1434)
            {
                bool _S1622 = !_S1620;
                if(_S1622)
                {
                    return _S1222;
                }
                bool _S1623 = _S1227 != 1U;
                if(_S1623)
                {
                    _S1535 = _S1227 != 2U;
                }
                else
                {
                    _S1535 = false;
                }
                if(_S1535)
                {
                    float _S1624 = (&lobe_5)->pdf;
                    float _S1625 = _slang_select(nee_0, _S1624,0.0f);
                    float _S1626 = escapeWeight_0(_S1625, _S1543);
                    if(_S1442)
                    {
                        passes_0 = _S1233;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1627 = _slang_select(passes_0, _S1626,1.0f);
                    return Shift_x24init_0(throughput_9 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf)) * r_8->radiance * make_float3 (_S1627) / make_float3 (r_8->jac), density_4 * (&lobe_5)->pdf / r_8->jac);
                }
                float3  _S1628 = throughput_9 * make_float3 ((&lobe_5)->pdf);
                float _S1629 = density_4 * (&lobe_5)->pdf;
                throughput_12 = _S1628;
                density_6 = _S1629;
            }
            else
            {
                throughput_12 = throughput_9;
                density_6 = density_4;
            }
            uint _S1630 = (fcptLayers((hit_4)));
            bool _S1631 = b_11 == 1U;
            bool _S1632 = passesLayer_0(_S1630, _S1631, passes_0);
            if(viewed_1)
            {
                _S1535 = _S1632;
            }
            else
            {
                _S1535 = false;
            }
            if(_S1535)
            {
                return _S1222;
            }
            if(replay_2)
            {
                _S1536 = b_8 <= _S1237;
            }
            else
            {
                _S1536 = false;
            }
            if(_S1536)
            {
                _S1537 = _S1395;
            }
            else
            {
                _S1537 = false;
            }
            if(_S1537)
            {
                _S1538 = _S1620;
            }
            else
            {
                _S1538 = false;
            }
            if(_S1538)
            {
                _S1539 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S1539 = !_S1621;
                }
                else
                {
                    _S1539 = false;
                }
            }
            if(_S1539)
            {
                return _S1222;
            }
            if(viewed_1)
            {
                float3  _S1633 = throughput_12 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf));
                float _S1634 = (&lobe_5)->pdf;
                throughput_13 = _S1633;
                sky_pdf_2 = _S1634;
            }
            else
            {
                float3  _S1635 = throughput_12 * max_0((&lobe_5)->throughput, _S1221);
                throughput_13 = _S1635;
                sky_pdf_2 = density_6;
            }
            bool _S1636 = !replay_2;
            bool _S1637;
            if(_S1636)
            {
                _S1637 = !_S1425;
            }
            else
            {
                _S1637 = false;
            }
            bool _S1638;
            if(_S1637)
            {
                _S1638 = _S1395;
            }
            else
            {
                _S1638 = false;
            }
            bool _S1639;
            if(_S1638)
            {
                _S1639 = _S1620;
            }
            else
            {
                _S1639 = false;
            }
            if(_S1639)
            {
                chain_0 = here_0;
                uint _S1640 = insertBits_0((&chain_0)->path, b_11, 18U, 3U);
                uint _S1641 = _slang_select(nee_0, 1U,0U);
                uint _S1642 = insertBits_0(_S1640, _S1641, 21U, 1U);
                (&chain_0)->path = _S1642;
                float _S1643 = (&chain_0)->jac * (&lobe_5)->pdf;
                (&chain_0)->jac = _S1643;
                (&chain_0)->dir = throughput_11;
                chain_throughput_1 = throughput_13;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            FKSurface _S1644 = surface_11;
            Vertex _S1645 = Vertex_x24init_0(_S1621, b_11, (&lobe_5)->pdf, (F32_abs((dot_0(surface_11.geometry_n, throughput_11)))), is_inside_6);
            prev_0 = _S1645;
            float _S1646 = (&lobe_5)->pdf;
            bool _S1647;
            if(_S1631)
            {
                _S1647 = (_S1399.x) == (_S1399.y);
            }
            else
            {
                _S1647 = false;
            }
            float sky_pdf_3 = _slang_select(_S1647, sky_pdf_0,_S1646);
            float _S1648 = _slang_select(_S1404, 0.0f,sky_pdf_3);
            float _S1649 = widened_0(spread_2, (&lobe_5)->pdf, _S1526);
            bool _S1650;
            if(refracted_5)
            {
                _S1650 = !_S1532;
            }
            else
            {
                _S1650 = false;
            }
            bool is_inside_7;
            if(_S1650)
            {
                bool _S1651 = !is_inside_6;
                is_inside_7 = _S1651;
            }
            else
            {
                is_inside_7 = is_inside_6;
            }
            FKSurface _S1652 = surface_11;
            bool _S1653 = boundsVolume_0(&_S1652);
            bool _S1654;
            if(_S1653)
            {
                _S1654 = !_S1632;
            }
            else
            {
                _S1654 = false;
            }
            if(_S1654)
            {
                FKSurface faced_2 = surface_11;
                float3  _S1655 = - _S1644.geometry_n;
                float3  _S1656 = _slang_select(turned_1, _S1655,_S1644.geometry_n);
                (&faced_2)->geometry_n = _S1656;
                FKMedium _S1657 = Medium_x24init_0(scatter_in_0, extinction_in_0, g_in_0);
                FKMedium _S1658 = (fcptOutsideMedium((hit_4)));
                FKSurface _S1659 = faced_2;
                FKMedium _S1660 = _S1657;
                FKMedium _S1661 = _S1658;
                MediumSides _S1662 = mediumSides_0(&_S1659, &_S1660, filling_2, (&ray_2)->unit_direction, &_S1661);
                bool _S1663 = leavesInFront_0((&faced_2)->geometry_n, throughput_11, _S1644.geometry_n);
                float3  _S1664 = _slang_select(_S1663, _S1662.front.scatter,_S1662.behind.scatter);
                scatter_in_0 = _S1664;
                float3  _S1665 = _slang_select(_S1663, _S1662.front.extinction,_S1662.behind.extinction);
                extinction_in_0 = _S1665;
                float _S1666 = _slang_select(_S1663, _S1662.front.g,_S1662.behind.g);
                g_in_0 = _S1666;
                uint _S1667 = _S1662.fillings.x;
                uint _S1668 = _S1662.fillings.y;
                uint _S1669 = _slang_select(_S1663, _S1668,_S1667);
                bool _S1670 = (fcptVaryingUsed());
                uint _S1671 = _slang_select(_S1670, _S1669,4294967295U);
                filling_2 = _S1671;
            }
            (&ray_2)->unit_direction = throughput_11;
            bool _S1672 = !_S1632;
            if(_S1672)
            {
                FKSurface _S1673 = surface_11;
                float _S1674 = _slang_select(straight_0, 0.0f,_S1673.geometry_offset);
                float3  _S1675 = - _S1397.smooth_n;
                bool _S1676 = is_inside_7 != _S1532;
                float3  _S1677 = _slang_select(_S1676, _S1675,_S1397.smooth_n);
                float3  _S1678 = (&ray_2)->origin + make_float3 (_S1674) * _S1677;
                (&ray_2)->origin = _S1678;
            }
            throughput_12 = throughput_13;
            chain_throughput_0 = chain_throughput_1;
            density_6 = sky_pdf_2;
            passes_0 = _S1632;
            viewed_1 = _S1530;
            sky_pdf_2 = _S1648;
            spread_5 = _S1649;
            reconnection_0 = reconnection_1;
            is_inside_5 = is_inside_7;
        }
        else
        {
            (&prev_0)->rough = false;
            (&prev_0)->pdf = 0.0f;
            throughput_12 = throughput_9;
            density_6 = density_4;
            passes_0 = false;
            viewed_1 = viewed_0;
            sky_pdf_2 = 0.0f;
            spread_5 = spread_2;
            straight_0 = false;
            is_inside_5 = is_inside_6;
        }
        bool _S1679 = !replay_2;
        float density_7;
        if(_S1679)
        {
            if(_S1363)
            {
                float3  _S1680 = throughput_12 * emission_1;
                Reservoir candidate_8 = chain_0;
                uint _S1681 = extractBits_0((&chain_0)->path, 10U, 2U);
                bool _S1682 = _S1681 == 1U;
                if(_S1682)
                {
                    float3  _S1683 = safeDivide(_S1680, chain_throughput_0);
                    (&candidate_8)->radiance = _S1683;
                }
                Reservoir _S1684 = withEnd(candidate_8, 2U, b_8, _S1680);
                offer(sel_7, _S1684, _S1680 * make_float3 (scale_3) / make_float3 (density_6));
            }
            if(_S1363)
            {
                refracted_5 = true;
            }
            else
            {
                refracted_5 = scatter_2;
            }
            if(refracted_5)
            {
                float _S1685 = survivalProbability(throughput_12, density_6);
                density_7 = _S1685;
            }
            else
            {
                density_7 = 1.0f;
            }
            uint _S1686 = stream(_S1249, b_8 + 128U);
            Random _S1687 = pcg(_S1686);
            bool _S1688 = density_7 < (_S1687.value);
            if(_S1688)
            {
                wrong_side_0 = true;
            }
            else
            {
                uint _S1689 = (fcptMaxBounces());
                wrong_side_0 = b_8 >= _S1689;
            }
            if(wrong_side_0)
            {
                break;
            }
            float _S1690 = density_6 * density_7;
            density_7 = _S1690;
        }
        else
        {
            density_7 = density_6;
        }
        uint _S1691 = layer_0 ^ 1U;
        uint _S1692 = _slang_select(passes_0, _S1691,0U);
        if(passes_0)
        {
            (&prev_0)->rough = false;
            (&hit_4)->distance = 0.0f;
            b_11 = b_8;
            viewed_0 = viewed_1;
            throughput_5 = throughput_12;
            density_2 = density_7;
            sky_pdf_0 = sky_pdf_2;
            spread_2 = spread_5;
            uint _S1693 = b_11 + 1U;
            b_8 = _S1693;
            layer_0 = _S1692;
            continue;
        }
        FKRay _S1694 = ray_2;
        float _S1695 = distance_1(reconnection_0, (&ray_2)->origin) * 1.0010000467300415f;
        if(replay_2)
        {
            refracted_5 = _S1435;
        }
        else
        {
            refracted_5 = false;
        }
        if(refracted_5)
        {
            wrong_side_0 = _S1226 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S1696 = _slang_select(wrong_side_0, _S1695,4.294967296e+09f);
        bool _S1697 = !_S1404;
        if(straight_0)
        {
            _S1479 = true;
        }
        else
        {
            _S1479 = _S1404;
        }
        FKHit _S1698;
        if(_S1479)
        {
            _S1698 = hit_4;
        }
        else
        {
            _S1698 = _S1452;
        }
        FKHit _S1699 = (fcptTraverseInstanceBVH((_S1694), (_S1371), (_S1696), (_S1697), (_S1698), (viewed_1)));
        hit_4 = _S1699;
        if(replay_2)
        {
            _S1480 = _S1435;
        }
        else
        {
            _S1480 = false;
        }
        if(_S1480)
        {
            _S1525 = _S1226 == 1U;
        }
        else
        {
            _S1525 = false;
        }
        if(_S1525)
        {
            _S1526 = ((&hit_4)->instance_index) == (_S1238.instance_index);
        }
        else
        {
            _S1526 = false;
        }
        if(_S1526)
        {
            _S1527 = ((&hit_4)->triangle_index) == (_S1238.triangle_index);
        }
        else
        {
            _S1527 = false;
        }
        if(_S1527)
        {
            (&hit_4)->uv = _S1238.uv;
            float _S1700 = distance_1(reconnection_0, (&ray_2)->origin);
            (&hit_4)->distance = _S1700;
        }
        if(replay_2)
        {
            _S1528 = _S1435;
        }
        else
        {
            _S1528 = false;
        }
        if(_S1528)
        {
            _S1529 = _S1226 == 3U;
        }
        else
        {
            _S1529 = false;
        }
        if(_S1529)
        {
            _S1530 = ((&hit_4)->instance_index) != 4294967295U;
        }
        else
        {
            _S1530 = false;
        }
        if(_S1530)
        {
            return _S1222;
        }
        Reservoir _S1701 = chain_0;
        uint _S1702 = filling_2;
        for(;;)
        {
            bool _S1703 = (fcptVaryingUsed());
            if(_S1703)
            {
                _S1531 = _S1702 != 4294967295U;
            }
            else
            {
                _S1531 = false;
            }
            float _S1704;
            if(_S1531)
            {
                float _S1705 = (fcptMajorant((_S1702)));
                _S1704 = _S1705;
            }
            else
            {
                _S1704 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
            }
            if(replay_2)
            {
                _S1532 = _S1435;
            }
            else
            {
                _S1532 = false;
            }
            if(_S1532)
            {
                _S1533 = _S1226 == 1U;
            }
            else
            {
                _S1533 = false;
            }
            if(_S1533)
            {
                _S1534 = _S1704 > 0.0f;
            }
            else
            {
                _S1534 = false;
            }
            if(_S1534)
            {
                ended_0 = _S1222;
                sky_pdf_1 = sky_pdf_2;
                spread_3 = spread_5;
                width_4 = width_3;
                density_3 = density_7;
                throughput_13 = throughput_12;
                b_11 = b_8;
                _S1535 = true;
                break;
            }
            bool _S1706 = (&prev_0)->rough;
            if(_S1706)
            {
                _S1535 = !(_S1704 > 0.0f);
            }
            else
            {
                _S1535 = false;
            }
            (&prev_0)->rough = _S1535;
            uint _S1707 = b_8 + 320U;
            bool _S1708 = b_8 == 4294967295U;
            uint _S1709 = _slang_select(_S1708, 384U,_S1707);
            uint _S1710 = stream(_S1249, _S1709);
            uint tracking_1 = _S1710;
            weight_1 = throughput_6;
            glowed_0 = _S1221;
            b_11 = b_8;
            throughput_13 = throughput_12;
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
                    _S1220 = int(2);
                    break;
                }
                uint _S1711 = b_11 + 320U;
                bool _S1712 = b_11 == 4294967295U;
                uint _S1713 = _slang_select(_S1712, 384U,_S1711);
                uint _S1714 = stream(_S1249, _S1713);
                Random _S1715 = pcg(_S1714);
                float _S1716 = freeFlight_0(_S1715.value, _S1704);
                if(_S1531)
                {
                    float3  _S1717 = (&ray_2)->origin;
                    float3  _S1718 = (&ray_2)->unit_direction;
                    float _S1719 = (&hit_4)->distance;
                    uint _S1720 = _slang_select(_S1712, 0U,b_11);
                    uint _S1721 = (&prev_0)->lobe;
                    uint _S1722 = _slang_select(_S1712, 3U,_S1721);
                    float _S1723 = (fcptTrackMedium((_S1702), (_S1717), (_S1718), (_S1719), (&tracking_1), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1720), (_S1722), (_S1712)));
                    spread_4 = _S1723;
                }
                else
                {
                    spread_4 = _S1716;
                }
                bool _S1724 = !(spread_4 < ((&hit_4)->distance));
                if(_S1724)
                {
                    _S1220 = int(2);
                    break;
                }
                if(_S1531)
                {
                    _S1536 = _S1679;
                }
                else
                {
                    _S1536 = false;
                }
                if(_S1536)
                {
                    float3  _S1725 = throughput_13 * glowed_0 / make_float3 (density_3);
                    float3  _S1726 = sel_7->glow + _S1725;
                    sel_7->glow = _S1726;
                }
                else
                {
                }
                glowed_0 = _S1221;
                uint b_12 = b_11 + 1U;
                float3  _S1727 = (&ray_2)->origin + make_float3 (spread_4) * (&ray_2)->unit_direction;
                (&ray_2)->origin = _S1727;
                float3  _S1728 = flightWeight_0(scatter_in_0, extinction_in_0, _S1704, spread_4, true);
                float3  _S1729 = weight_1;
                float3  _S1730 = _slang_select(_S1531, _S1729,_S1728);
                float3  throughput_14 = throughput_13 * _S1730;
                uint _S1731 = stream(_S1249, b_12 + 320U);
                tracking_1 = _S1731;
                weight_1 = throughput_6;
                float width_7 = width_4 + spread_3 * spread_4;
                float _S1732 = spread_3 + 3.14159274101257324f;
                bool _S1733 = scatterSampled_0(replay_2, b_12, _S1237, _S1531);
                TreeSample light_4;
                if(_S1733)
                {
                    float3  _S1734 = (&ray_2)->origin;
                    float3  _S1735 = (&ray_2)->unit_direction;
                    float3  _S1736 = (&ray_2)->unit_direction;
                    uint _S1737 = stream(_S1249, b_12 + 64U);
                    float3  _S1738 = extinction_in_0;
                    float3  _S1739 = extinction_in_0;
                    uint2  _S1740 = make_uint2 (_S1702);
                    float3  _S1741 = (&ray_2)->unit_direction;
                    uint _S1742 = arrivalLobe_0(b_12, (&prev_0)->lobe);
                    FKHit _S1743 = _S1452;
                    ShadowContext _S1744 = ShadowContext_x24init_0(_S1738, _S1739, _S1740, _S1741, b_12, _S1742, false, spread_4, width_7, &_S1743, false);
                    ShadowContext _S1745 = _S1744;
                    TreeSample _S1746 = sampleLightTree_0(_S1734, _S1735, _S1736, 0.0f, true, _S1737, &_S1745);
                    light_4 = _S1746;
                }
                else
                {
                    light_4 = _S1449;
                }
                float _S1747 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_4.dir));
                uint _S1748 = (fcptMaxBounces());
                bool _S1749 = b_12 < _S1748;
                if(_S1749)
                {
                    _S1537 = (light_4.density) > 0.0f;
                }
                else
                {
                    _S1537 = false;
                }
                float _S1750 = _slang_select(_S1537, _S1747,0.0f);
                float3  _S1751 = throughput_14 * light_4.radiance;
                float _S1752 = powerHeuristic(light_4.density, _S1750);
                float3  _S1753 = _S1751 * make_float3 (_S1747 * _S1752);
                float3  _S1754 = _slang_select(_S1733, _S1753,_S1221);
                if(replay_2)
                {
                    _S1538 = b_12 == _S1237;
                }
                else
                {
                    _S1538 = false;
                }
                if(_S1538)
                {
                    bool _S1755 = _S1226 == 2U;
                    if(_S1755)
                    {
                        float _S1756 = rgb_to_greyscale(_S1754);
                        _S1539 = _S1756 > 0.0f;
                    }
                    else
                    {
                        _S1539 = false;
                    }
                    if(_S1539)
                    {
                        Shift _S1757 = Shift_x24init_0(_S1754, 1.0f);
                        _S1220 = int(1);
                        ended_0 = _S1757;
                        spread_4 = _S1732;
                        width_5 = width_7;
                        throughput_11 = throughput_14;
                        b_9 = b_12;
                        break;
                    }
                    _S1220 = int(1);
                    ended_0 = _S1222;
                    spread_4 = _S1732;
                    width_5 = width_7;
                    throughput_11 = throughput_14;
                    b_9 = b_12;
                    break;
                }
                if(_S1679)
                {
                    Reservoir candidate_9 = _S1701;
                    uint _S1758 = extractBits_0(_S1701.path, 10U, 2U);
                    bool _S1759 = _S1758 == 1U;
                    if(_S1759)
                    {
                        float3  _S1760 = safeDivide(_S1754, chain_throughput_0);
                        (&candidate_9)->radiance = _S1760;
                    }
                    else
                    {
                        uint _S1761 = insertBits_0(0U, b_12 + 1U, 5U, 5U);
                        uint _S1762 = insertBits_0(_S1761, 2U, 10U, 2U);
                        (&candidate_9)->path = _S1762;
                    }
                    Reservoir _S1763 = withEnd(candidate_9, 0U, b_12, _S1754);
                    offer(sel_7, _S1763, _S1754 * make_float3 (scale_3) / make_float3 (density_3));
                    float _S1764 = survivalProbability(throughput_14, density_3);
                    uint _S1765 = stream(_S1249, b_12 + 128U);
                    Random _S1766 = pcg(_S1765);
                    bool _S1767 = _S1764 < (_S1766.value);
                    if(_S1767)
                    {
                        _S1539 = true;
                    }
                    else
                    {
                        uint _S1768 = (fcptMaxBounces());
                        _S1539 = b_12 >= _S1768;
                    }
                    if(_S1539)
                    {
                        _S1220 = int(1);
                        ended_0 = _S1222;
                        spread_4 = _S1732;
                        width_5 = width_7;
                        throughput_11 = throughput_14;
                        b_9 = b_12;
                        break;
                    }
                    float _S1769 = density_3 * _S1764;
                    density_3 = _S1769;
                }
                else
                {
                }
                float phase_pdf_1 = 0.0f;
                uint _S1770 = stream(_S1249, b_12);
                float3  _S1771 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1770, &phase_pdf_1);
                (&ray_2)->unit_direction = _S1771;
                NEEVertex _S1772 = NEEVertex_x24init_0(false, phase_pdf_1, (&ray_2)->origin, _S1221, (&ray_2)->origin);
                nee_vertex_0 = _S1772;
                Vertex _S1773 = scatteredVertex_0(is_inside_5);
                prev_0 = _S1773;
                float _S1774 = (&prev_0)->pdf;
                FKRay _S1775 = ray_2;
                FKHit _S1776 = (fcptTraverseInstanceBVH((_S1775), (true), (4.294967296e+09f), (false), (_S1452), (false)));
                hit_4 = _S1776;
                b_11 = b_12;
                throughput_13 = throughput_14;
                spread_3 = _S1732;
                width_4 = width_7;
                sky_pdf_1 = _S1774;
            }
            if(_S1220 != int(2))
            {
                spread_3 = spread_4;
                width_4 = width_5;
                throughput_13 = throughput_11;
                b_11 = b_9;
                _S1535 = true;
                break;
            }
            ended_0 = _S1222;
            _S1535 = false;
            break;
        }
        if(_S1535)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S1536 = b_11 == b_8;
        }
        else
        {
            _S1536 = false;
        }
        bool _S1777 = ((&hit_4)->instance_index) == 4294967295U;
        if(_S1777)
        {
            bool _S1778 = !(&nee_vertex_0)->none;
            float _S1779 = _slang_select(_S1778, sky_pdf_1,0.0f);
            float _S1780 = escapeWeight_0(_S1779, (&ray_2)->unit_direction);
            float3  _S1781 = environment_0((&ray_2)->unit_direction, b_11, (&prev_0)->lobe);
            float3  _S1782 = throughput_13 * _S1781;
            if(replay_2)
            {
                bool _S1783 = b_11 == _S1237;
                if(_S1783)
                {
                    passes_0 = _S1226 == 3U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(_S1782 * make_float3 (_S1780) / make_float3 (r_8->jac), density_3 / r_8->jac);
                }
                if(_S1236)
                {
                    passes_0 = _S1233;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = b_11 == _S1224;
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
                    return Shift_x24init_0(_S1782 * make_float3 (_S1780), 1.0f);
                }
                return _S1222;
            }
            Reservoir candidate_10 = chain_0;
            uint _S1784 = extractBits_0((&chain_0)->path, 10U, 2U);
            bool _S1785 = _S1784 == 1U;
            if(_S1785)
            {
                uint _S1786 = extractBits_0((&chain_0)->path, 5U, 5U);
                bool _S1787 = _S1786 == b_11;
                float _S1788 = _slang_select(_S1787, 1.0f,_S1780);
                float3  _S1789 = safeDivide(_S1782 * make_float3 (_S1788), chain_throughput_0);
                (&candidate_10)->radiance = _S1789;
            }
            else
            {
                bool _S1790 = (&prev_0)->rough;
                if(_S1790)
                {
                    uint _S1791 = insertBits_0(0U, b_11 + 1U, 5U, 5U);
                    uint _S1792 = insertBits_0(_S1791, 3U, 10U, 2U);
                    uint _S1793 = insertBits_0(_S1792, (&prev_0)->lobe, 15U, 3U);
                    bool _S1794 = (&prev_0)->inside;
                    uint _S1795 = _slang_select(_S1794, 1U,0U);
                    uint _S1796 = insertBits_0(_S1793, _S1795, 22U, 1U);
                    (&candidate_10)->path = _S1796;
                    (&candidate_10)->jac = (&prev_0)->pdf;
                    (&candidate_10)->dir = (&ray_2)->unit_direction;
                }
            }
            float3  _S1797 = _S1782 * make_float3 (_S1780);
            Reservoir _S1798 = withEnd(candidate_10, 3U, b_11, _S1797);
            offer(sel_7, _S1798, _S1797 * make_float3 (scale_3) / make_float3 (density_3));
            break;
        }
        float3  _S1799 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
        (&ray_2)->origin = _S1799;
        bool _S1800 = (fcptVaryingUsed());
        if(_S1800)
        {
            _S1537 = filling_2 != 4294967295U;
        }
        else
        {
            _S1537 = false;
        }
        if(_S1537)
        {
            if(_S1679)
            {
                float3  _S1801 = throughput_13 * glowed_0 / make_float3 (density_3);
                float3  _S1802 = sel_7->glow + _S1801;
                sel_7->glow = _S1802;
            }
            float3  _S1803 = throughput_13 * weight_1;
            throughput_11 = _S1803;
        }
        else
        {
            float3  _S1804 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
            float3  _S1805 = throughput_13 * _S1804;
            throughput_11 = _S1805;
        }
        float _S1806 = width_4 + spread_3 * (&hit_4)->distance;
        viewed_0 = _S1536;
        width_3 = _S1806;
        throughput_5 = throughput_11;
        density_2 = density_3;
        sky_pdf_0 = sky_pdf_1;
        spread_2 = spread_3;
        uint _S1693 = b_11 + 1U;
        b_8 = _S1693;
        layer_0 = _S1692;
    }
    return _S1222;
}

static __device__ Shift shift_0(Domain * dom_8, Reservoir * r_9)
{
    Selection _S1807 = (Selection{});
    Selection sel_8 = _S1807;
    bool _S1808 = (r_9->w) <= 0.0f;
    if(_S1808)
    {
        return Shift_x24init_0(make_float3 (0.0f), 0.0f);
    }
    Shift _S1809 = walk_0(dom_8, r_9, true, 0.0f, &sel_8);
    return _S1809;
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
    int i_23 = int(0);
    for(;;)
    {
        if(i_23 < int(3))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_14, i_23) = (F32_tan((_slang_vector_get_element(x_26, i_23))));
        i_23 = i_23 + int(1);
    }
    return result_14;
}

static __device__ float3  acos_0(float3  x_27)
{
    float3  result_15;
    int i_24 = int(0);
    for(;;)
    {
        if(i_24 < int(3))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_15, i_24) = (F32_acos((_slang_vector_get_element(x_27, i_24))));
        i_24 = i_24 + int(1);
    }
    return result_15;
}

static __device__ float3  abs_0(float3  x_28)
{
    float3  result_16;
    int i_25 = int(0);
    for(;;)
    {
        if(i_25 < int(3))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_16, i_25) = (F32_abs((_slang_vector_get_element(x_28, i_25))));
        i_25 = i_25 + int(1);
    }
    return result_16;
}

__device__ Random normal_distribution(uint state_4)
{
    Random _S1810 = pcg(state_4);
    Random _S1811 = pcg(_S1810.state);
    float _S1812 = 6.28318548202514648f * _S1810.value;
    float _S1813 = (F32_sqrt((-2.0f * clamp_1((F32_log((_S1811.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S1811.state, _S1813 * (F32_cos((_S1812))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_5, float3  value_2)
{
    RandomSphere _S1814;
    (&_S1814)->state = state_5;
    (&_S1814)->value = value_2;
    return _S1814;
}

__device__ RandomSphere random_sphere(uint state_6)
{
    Random _S1815 = normal_distribution(state_6);
    Random _S1816 = normal_distribution(_S1815.state);
    Random _S1817 = normal_distribution(_S1816.state);
    float3  _S1818 = make_float3 (_S1815.value, _S1816.value, _S1817.value);
    float3  _S1819 = ((((_S1818)) * make_float3(rnorm3df(((_S1818)).x, ((_S1818)).y, ((_S1818)).z))));
    return RandomSphere_x24init_0(_S1817.state, _S1819);
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_16)
{
    float3  _S1820 = p1_0 - p0_0;
    float3  _S1821 = p2_0 - p0_0;
    float2  _S1822 = uv1_0 - uv0_0;
    float2  _S1823 = uv2_0 - uv0_0;
    float _S1824 = _S1822.x;
    float _S1825 = _S1823.y;
    float _S1826 = _S1822.y;
    float _S1827 = _S1823.x;
    float _S1828 = _S1824 * _S1825 - _S1826 * _S1827;
    float _S1829 = 1.0f / _S1828;
    float3  t_22 = (_S1820 * make_float3 (_S1825) - _S1821 * make_float3 (_S1826)) * make_float3 (_S1829);
    float3  _S1830 = (_S1821 * make_float3 (_S1824) - _S1820 * make_float3 (_S1827)) * make_float3 (_S1829);
    float3  _S1831 = t_22 - n_16 * make_float3 (dot_0(n_16, t_22));
    float3  t_23 = ((((_S1831)) * make_float3(rnorm3df(((_S1831)).x, ((_S1831)).y, ((_S1831)).z))));
    bool _S1832 = (dot_0(cross_0(n_16, t_23), _S1830)) > 0.0f;
    float3  t_24;
    if(_S1832)
    {
        float3  _S1833 = negate_0(t_23);
        t_24 = _S1833;
    }
    else
    {
        t_24 = t_23;
    }
    float3  _S1834 = cross_0(n_16, t_24);
    return makeMatrix<float, 3, 3> (t_24, _S1834, n_16);
}

__device__ float3  tangentToWorldNormalMap(float3  v_4, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_4, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_5, float3  uvw_0, float3  position_0)
{
    float3  _S1835 = t1_0 - t0_0;
    float3  _S1836 = t2_2 - t0_0;
    float3  _S1837 = t2_2 - t1_0;
    float _S1838 = (F32_min((length_0(_S1835)), ((F32_min((length_0(_S1836)), (length_0(_S1837)))))));
    float3  _S1839 = make_float3 (distance_1(position_0, t0_0), distance_1(position_0, t1_0), distance_1(position_0, t2_2));
    float3  _S1840 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S1841 = dot_0(geometry_n_5, _S1840);
    float3  _S1842 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S1843 = dot_0(geometry_n_5, _S1842);
    float3  _S1844 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S1845 = acos_0(abs_0(make_float3 (_S1841, _S1843, dot_0(geometry_n_5, _S1844))));
    float3  _S1846 = clamp_2(tan_0(_S1845), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_1(dot_0(_S1839 * _S1846, uvw_0), 0.0f, _S1838 * 0.125f);
}

__device__ float3  straightThrough(float3  dir_16, float3  n_17, BSDFMaterial material_26)
{
    float3  _S1847 = negate_0(dir_16);
    float _S1848 = sign_0(dot_0(n_17, _S1847));
    float3  _S1849 = n_17 * make_float3 (_S1848);
    AnisotropicFrame _S1850 = anisotropicFrame(material_26, _S1849);
    bool _S1851 = (_S1850.alphas.x) > 0.0f;
    if(_S1851)
    {
        float _S1852 = material_26.transmission * (1.0f - material_26.metallic);
        float3  _S1853 = negate_0(_S1849);
        float3  _S1854 = anisotropicLocal(dir_16, _S1850.tangent, _S1853);
        float _S1855 = anisotropicG1(_S1854, _S1850.alphas);
        return make_float3 (_S1852 * _S1855) * material_26.albedo;
    }
    float _S1856 = material_26.transmission * (1.0f - material_26.metallic);
    float _S1857 = material_26.roughness;
    float _S1858 = smithG1(_S1857 * _S1857, (F32_abs((dot_0(n_17, dir_16)))));
    return make_float3 (_S1856 * _S1858) * material_26.albedo;
}

__device__ float hairRow(float3  in_dir_14, float3  t_25, float3  out_dir_5, uint p_12, float w_2, float alpha_20, uint nt_0)
{
    uint _S1859 = p_12 % 4U;
    float _S1860 = w_2 * HAIR_WIDTHS_0[_S1859];
    float _S1861 = (F32_asin((clamp_1(dot_0(out_dir_5, t_25), -1.0f, 1.0f)))) - (F32_asin((clamp_1(dot_0(in_dir_14, t_25), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S1859] * alpha_20;
    return ((F32_asinh((_S1861 / _S1860))) / (F32_asinh((3.14159274101257324f / _S1860))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_15, float3  t_26, float3  out_dir_6, uint np_0)
{
    float3  _S1862 = worldToTangent(out_dir_6, t_26);
    float3  _S1863 = worldToTangent(in_dir_15, t_26);
    return (F32_frac((((F32_atan2((_S1862.z), (_S1862.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S1863.z), (1.17549435082228751e-38f - _S1863.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_16, float3  t_27, uint p_13, float row_0, float column_0, float w_3, float alpha_21, uint nt_1, uint np_1)
{
    float3  _S1864 = worldToTangent(in_dir_16, t_27);
    uint _S1865 = p_13 % 4U;
    float _S1866 = w_3 * HAIR_WIDTHS_0[_S1865];
    float _S1867 = (F32_asin((clamp_1(dot_0(in_dir_16, t_27), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S1865] * alpha_21 + _S1866 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S1866))))));
    float _S1868 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S1864.z), (1.17549435082228751e-38f - _S1864.x)));
    float _S1869 = (F32_cos((_S1867)));
    float3  _S1870 = tangentToWorld(make_float3 (_S1869 * (F32_cos((_S1868))), (F32_sin((_S1867))), _S1869 * (F32_sin((_S1868)))), t_27);
    return _S1870;
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_18, BSDFMaterial material_27, float coverage_1)
{
    float3  _S1871;
    if((material_27.ior) == 1.0f)
    {
        float3  _S1872 = straightThrough(toward_1, n_18, material_27);
        _S1871 = _S1872;
    }
    else
    {
        _S1871 = make_float3 (0.0f);
    }
    return _S1871 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ Shift walk_hook(Domain dom_9, Reservoir r_10, bool replay_3, float scale_4, Selection * sel_9)
{
    Domain _S1873 = dom_9;
    Reservoir _S1874 = r_10;
    Shift _S1875 = walk_0(&_S1873, &_S1874, replay_3, scale_4, sel_9);
    return _S1875;
}

__device__ Shift shift_hook(Domain dom_10, Reservoir r_11)
{
    Domain _S1876 = dom_10;
    Reservoir _S1877 = r_11;
    Shift _S1878 = shift_0(&_S1876, &_S1877);
    return _S1878;
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
