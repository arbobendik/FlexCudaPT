#pragma once
#include "slang-cuda-prelude.h"

static __device__ bool all_0(bool3  x_0)
{
    bool result_0 = true;
    int i_0 = int(0);
    for(;;)
    {
        if(i_0 < int(3))
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

__device__ uint hash(uint x_1)
{
    uint _S1 = x_1 * 747796405U + 2891336453U;
    uint _S2 = ((_S1 >> ((_S1 >> 28U) + 4U)) ^ _S1) * 277803737U;
    return (_S2 >> 22U) ^ _S2;
}

__device__ uint noiseWhite(uint x_2, uint y_0, uint t_0, uint size_0)
{
    FixedArray<uint, 4>  ranks_0;
    uint i_1 = 0U;
    for(;;)
    {
        if(i_1 < 4U)
        {
        }
        else
        {
            break;
        }
        uint _S3 = size_0 - 1U;
        uint _S4 = (x_2 + size_0 / 2U) & _S3;
        bool _S5 = i_1 < 2U;
        uint _S6 = _slang_select(_S5, x_2,_S4);
        uint l_0 = _S6;
        uint r_0 = y_0;
        uint k_0 = 0U;
        for(;;)
        {
            if(k_0 < 4U)
            {
            }
            else
            {
                break;
            }
            uint _S7 = hash(((r_0 ^ (t_0 << 16U)) ^ (k_0 << 28U)) ^ ((i_1 & 1U) << 31U));
            uint _S8 = l_0 ^ (_S7 & _S3);
            uint k_1 = k_0 + 1U;
            l_0 = r_0;
            r_0 = _S8;
            k_0 = k_1;
        }
        uint _S9 = l_0 + r_0 * size_0;
        uint _S10 = size_0 * size_0;
        uint _S11;
        if(_S10 >= 65536U)
        {
            uint _S12 = _S9 / (_S10 / 65536U);
            _S11 = _S12;
        }
        else
        {
            uint _S13 = 65536U / _S10;
            _S11 = _S9 * _S13;
        }
        ranks_0[i_1] = _S11;
        uint i_2 = i_1 + 1U;
        i_1 = i_2;
    }
    bool _S14 = (ranks_0[int(0)]) == 65535U;
    bool _S15;
    if(_S14)
    {
        _S15 = (ranks_0[int(1)]) == 65535U;
    }
    else
    {
        _S15 = false;
    }
    bool _S16 = (ranks_0[int(2)]) == 65535U;
    bool _S17;
    if(_S16)
    {
        _S17 = (ranks_0[int(3)]) == 65535U;
    }
    else
    {
        _S17 = false;
    }
    if(_S15)
    {
        _S15 = (ranks_0[int(3)]) != 65535U;
    }
    else
    {
        _S15 = false;
    }
    if(_S15)
    {
        _S15 = true;
    }
    else
    {
        if(_S17)
        {
            _S15 = (ranks_0[int(1)]) != 65535U;
        }
        else
        {
            _S15 = false;
        }
    }
    uint _S18 = ranks_0[int(0)];
    uint _S19 = ranks_0[int(1)];
    uint _S20 = ranks_0[int(3)];
    uint _S21 = _slang_select(_S15, _S20,_S19);
    return _S18 | (_S21 << 16U);
}

extern "C" __global__ void noiseStart(RWStructuredBuffer<uint> tensor_0, uint size_1)
{
    uint3  _S22 = blockIdx * blockDim + threadIdx;
    uint _S23 = _S22.x;
    uint _S24 = size_1 * size_1;
    bool _S25 = _S23 < (_S24 * 32U);
    if(_S25)
    {
        uint * _S26 = (&(tensor_0)[_S23]);
        uint _S27 = _S23 % size_1;
        uint _S28 = _S23 / size_1;
        uint _S29 = _S28 % size_1;
        uint _S30 = _S23 / _S24;
        uint _S31 = noiseWhite(_S27, _S29, _S30, size_1);
        *_S26 = _S31;
    }
    return;
}

__device__ uint3  noiseBlock(uint sweep_0, uint colour_0, uint block_0, uint size_2)
{
    uint _S32 = hash(sweep_0 * 7919U + 1U);
    uint _S33 = size_2 / 16U;
    uint _S34 = block_0 % _S33;
    uint _S35 = block_0 / _S33;
    uint _S36 = _S35 % _S33;
    uint _S37 = block_0 / (_S33 * _S33);
    uint3  _S38 = make_uint3 (_S34, _S36, _S37);
    uint3  _S39 = make_uint3 (colour_0 & 1U, (colour_0 >> 1U) & 1U, colour_0 >> 2U);
    return _S38 * make_uint3 (16U) + _S39 * make_uint3 (8U) + make_uint3 (_S32 & 7U, (_S32 >> 3U) & 7U, (_S32 >> 6U) & 7U);
}

__device__ uint stream(uint seed_0, uint index_0)
{
    uint _S40 = hash(index_0);
    uint _S41 = hash(seed_0 ^ _S40);
    return _S41;
}

static __device__ uint noiseExp_0(uint q_0)
{
    uint _S42 = (q_0 * 23637U) >> 14U;
    int _S43 = int(_S42 & 4095U);
    int e_0 = int(-3486) + ((int(448) * _S43) >> int(12));
    int e_1 = int(15688) + ((e_0 * _S43) >> int(12));
    int e_2 = int(-45418) + ((e_1 * _S43) >> int(12));
    int e_3 = int(65536) + ((e_2 * _S43) >> int(12));
    return uint(e_3) >> (U32_min((_S42 >> 12U), (31U)));
}

static __device__ uint noiseRoot_0(uint q_1)
{
    uint root_0 = 0U;
    uint bit_0 = 268435456U;
    uint rest_0 = q_1;
    for(;;)
    {
        if(bit_0 != 0U)
        {
        }
        else
        {
            break;
        }
        uint _S44 = root_0 + bit_0;
        bool _S45 = rest_0 >= _S44;
        uint _S46 = _slang_select(_S45, _S44,0U);
        uint rest_1 = rest_0 - _S46;
        uint _S47 = root_0 >> 1U;
        uint _S48 = _slang_select(_S45, bit_0,0U);
        uint _S49 = _S47 + _S48;
        uint bit_1 = bit_0 >> 2U;
        root_0 = _S49;
        bit_0 = bit_1;
        rest_0 = rest_1;
    }
    return root_0;
}

static __device__ uint noiseFalloff_0(uint a_0, uint v_0)
{
    uint _S50 = a_0 & 65535U;
    uint _S51 = v_0 & 65535U;
    uint _S52 = ((U32_max((_S50), (_S51))) - (U32_min((_S50), (_S51)))) >> 2U;
    uint _S53 = a_0 >> 16U;
    uint _S54 = v_0 >> 16U;
    uint _S55 = ((U32_max((_S53), (_S54))) - (U32_min((_S53), (_S54)))) >> 2U;
    uint _S56 = noiseRoot_0(_S52 * _S52 + _S55 * _S55);
    uint _S57 = noiseExp_0(_S56 >> 2U);
    return _S57;
}

static __device__ uint2  noiseNear_0(RWStructuredBuffer<uint> tensor_1, uint3  n_0, uint d2_0, uint a_1, uint b_0, uint size_3)
{
    uint _S58 = *(&(tensor_1)[(n_0.z * size_3 + n_0.y) * size_3 + n_0.x]);
    uint _S59 = noiseExp_0(d2_0 * 929U);
    uint _S60 = _S59 >> 8U;
    uint _S61 = noiseFalloff_0(a_1, _S58);
    uint _S62 = noiseFalloff_0(b_0, _S58);
    return make_uint2 (_S60) * make_uint2 (_S61, _S62);
}

static __device__ uint2  noiseEnergy_0(RWStructuredBuffer<uint> tensor_2, uint3  at_0, uint a_2, uint b_1, uint3  skip_0, uint size_4)
{
    bool _S63;
    uint2  _S64 = make_uint2 (0U);
    int d_0 = int(-3);
    uint2  e_4 = _S64;
    for(;;)
    {
        if(d_0 <= int(3))
        {
        }
        else
        {
            break;
        }
        int dx_0 = int(-3);
        uint2  e_5 = e_4;
        for(;;)
        {
            if(dx_0 <= int(3))
            {
            }
            else
            {
                break;
            }
            int _S65 = int(size_4);
            uint _S66 = size_4 - 1U;
            uint3  _S67 = make_uint3 ((at_0.x + uint(dx_0 + _S65)) & _S66, (at_0.y + uint(d_0 + _S65)) & _S66, at_0.z);
            bool _S68 = dx_0 != int(0);
            if(_S68)
            {
                _S63 = true;
            }
            else
            {
                _S63 = d_0 != int(0);
            }
            bool _S69;
            if(_S63)
            {
                _S69 = !all_0(_S67 == skip_0);
            }
            else
            {
                _S69 = false;
            }
            if(_S69)
            {
                uint2  _S70 = noiseNear_0(tensor_2, _S67, uint(dx_0 * dx_0 + d_0 * d_0), a_2, b_1, size_4);
                uint2  e_6 = e_5 + _S70;
                e_5 = e_6;
            }
            int dx_1 = dx_0 + int(1);
            dx_0 = dx_1;
        }
        uint3  _S71 = make_uint3 (at_0.x, at_0.y, (at_0.z + uint(d_0 + int(32))) % 32U);
        bool _S72 = d_0 != int(0);
        if(_S72)
        {
            _S63 = !all_0(_S71 == skip_0);
        }
        else
        {
            _S63 = false;
        }
        if(_S63)
        {
            uint2  _S73 = noiseNear_0(tensor_2, _S71, uint(d_0 * d_0), a_2, b_1, size_4);
            uint2  e_7 = e_5 + _S73;
            e_4 = e_7;
        }
        else
        {
            e_4 = e_5;
        }
        int d_1 = d_0 + int(1);
        d_0 = d_1;
    }
    return e_4;
}

static __device__ void noiseSweepBlock_0(RWStructuredBuffer<uint> tensor_3, uint sweep_1, uint colour_1, uint block_1, uint size_5)
{
    uint3  _S74 = noiseBlock(sweep_1, colour_1, block_1, size_5);
    uint _S75 = size_5 - 1U;
    uint3  _S76 = make_uint3 (_S75, _S75, 31U);
    uint attempt_0 = 0U;
    for(;;)
    {
        if(attempt_0 < 512U)
        {
        }
        else
        {
            break;
        }
        uint _S77 = _S74.x;
        uint _S78 = _S74.y;
        uint _S79 = stream((_S77 | (_S78 << 11U)) | ((_S74.z) << 22U), sweep_1 * 4096U + attempt_0);
        uint _S80 = hash(_S79);
        uint3  _S81 = (_S74 + make_uint3 (_S80 & 7U, (_S80 >> 3U) & 7U, (_S80 >> 6U) & 7U)) & _S76;
        uint _S82 = (_S77 + ((_S80 >> 9U) & 7U)) & _S75;
        uint _S83 = (_S78 + ((_S80 >> 12U) & 7U)) & _S75;
        uint _S84 = _S81.z;
        uint3  _S85 = make_uint3 (_S82, _S83, _S84);
        uint _S86 = _S84 * size_5;
        uint _S87 = (_S86 + _S81.y) * size_5 + _S81.x;
        uint _S88 = (_S86 + _S83) * size_5 + _S82;
        uint _S89 = *(&(tensor_3)[_S87]);
        uint _S90 = *(&(tensor_3)[_S88]);
        uint2  _S91 = noiseEnergy_0(tensor_3, _S81, _S89, _S90, _S85, size_5);
        uint2  _S92 = noiseEnergy_0(tensor_3, _S85, _S90, _S89, _S81, size_5);
        bool _S93 = _S87 != _S88;
        bool _S94;
        if(_S93)
        {
            _S94 = (_S91.y + _S92.y) < (_S91.x + _S92.x);
        }
        else
        {
            _S94 = false;
        }
        if(_S94)
        {
            *(&(tensor_3)[_S87]) = _S90;
            *(&(tensor_3)[_S88]) = _S89;
        }
        uint attempt_1 = attempt_0 + 1U;
        attempt_0 = attempt_1;
    }
    return;
}

extern "C" __global__ void noiseSweep(RWStructuredBuffer<uint> tensor_4, uint size_6, uint sweep_2, uint colour_2)
{
    uint3  _S95 = blockIdx * blockDim + threadIdx;
    uint _S96 = _S95.x;
    bool _S97 = _S96 < (size_6 / 16U * (size_6 / 16U) * 2U);
    if(_S97)
    {
        noiseSweepBlock_0(tensor_4, sweep_2, colour_2, _S96, size_6);
    }
    return;
}

struct Random
{
    uint state;
    float value;
};

static __device__ Random Random_x24init_0(uint state_0, float value_0)
{
    Random _S98;
    (&_S98)->state = state_0;
    (&_S98)->value = value_0;
    return _S98;
}

__device__ Random pcg(uint state_1)
{
    uint _S99 = hash(state_1);
    float value_1 = float(_S99 >> int(8)) * 5.9604644775390625e-08f;
    return Random_x24init_0(_S99, value_1);
}

__device__ uint2  noiseOffset(uint k_2)
{
    uint2  _S100 = make_uint2 (k_2 * 3242174889U, k_2 * 2447445414U) >> make_uint2 (16U);
    uint _S101 = (fkBlueNoiseSize());
    return (_S100 * make_uint2 (_S101)) >> make_uint2 (16U);
}

__device__ uint noiseOrigin(uint2  p_0, uint k_3)
{
    uint _S102 = ((p_0.x) >> 11U) | (((p_0.y) >> 11U) << 4U);
    uint2  _S103 = noiseOffset(8192U + (k_3 >> 10U) + (_S102 << 20U));
    uint2  _S104 = (p_0 + _S103) & make_uint2 (2047U);
    return ((_S104.x) | ((_S104.y) << 11U)) | ((k_3 & 1023U) << 22U);
}

__device__ uint noiseAddress(uint origin_0, uint bounce_0)
{
    uint2  _S105 = make_uint2 (origin_0 & 2047U, (origin_0 >> 11U) & 2047U);
    uint2  _S106 = noiseOffset(64U + bounce_0 * 17U);
    uint2  _S107 = (_S105 + _S106) & make_uint2 (2047U);
    return ((_S107.x) | ((_S107.y) << 11U)) | ((origin_0 >> 22U) << 22U);
}

__device__ __noinline__ Random draw(uint address_0, uint variable_0)
{
    uint _S108 = address_0 >> 22U;
    uint _S109 = _S108 / 32U;
    uint2  _S110 = make_uint2 (address_0 & 2047U, (address_0 >> 11U) & 2047U);
    uint _S111 = variable_0 & 2147483647U;
    uint2  _S112 = noiseOffset(_S111);
    uint2  _S113 = _S110 + _S112;
    uint2  _S114 = noiseOffset(4096U + _S109);
    uint2  _S115 = _S113 + _S114;
    uint _S116 = (fkBlueNoiseSize());
    uint2  _S117 = _S115 & make_uint2 (_S116 - 1U);
    uint _S118 = (fkBlueNoise((_S117.x), (_S117.y), ((_S108 + ((_S109 * 2654435769U) >> 27U)) % 32U)));
    bool _S119 = (variable_0 & 2147483648U) != 0U;
    uint _S120 = stream(address_0, _S111);
    Random _S121 = pcg(_S120);
    uint _S122 = _S118 & 65535U;
    uint _S123 = _S118 >> 16U;
    uint _S124 = _slang_select(_S119, _S123,_S122);
    float _S125 = (float(_S124) + 0.5f) / 6.5536e+04f;
    Random _S126 = pcg(_S121.state);
    float _S127 = _slang_select(_S119, _S126.value,_S121.value);
    bool _S128 = _S118 == 4294967295U;
    float _S129 = _slang_select(_S128, _S127,_S125);
    return Random_x24init_0(address_0, _S129);
}

