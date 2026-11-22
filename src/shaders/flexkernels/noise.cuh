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
        uint _S3;
        if(i_1 < 2U)
        {
            _S3 = x_2;
        }
        else
        {
            _S3 = (x_2 + size_0 / 2U) & (size_0 - 1U);
        }
        uint l_0 = _S3;
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
            uint _S4 = hash(((r_0 ^ (t_0 << 16U)) ^ (k_0 << 28U)) ^ ((i_1 & 1U) << 31U));
            uint _S5 = l_0 ^ (_S4 & (size_0 - 1U));
            uint k_1 = k_0 + 1U;
            l_0 = r_0;
            r_0 = _S5;
            k_0 = k_1;
        }
        uint _S6 = l_0 + r_0 * size_0;
        uint _S7 = size_0 * size_0;
        uint _S8;
        if(_S7 >= 65536U)
        {
            uint _S9 = _S6 / (_S7 / 65536U);
            _S8 = _S9;
        }
        else
        {
            uint _S10 = 65536U / _S7;
            _S8 = _S6 * _S10;
        }
        ranks_0[i_1] = _S8;
        uint i_2 = i_1 + 1U;
        i_1 = i_2;
    }
    bool _S11 = (ranks_0[int(0)]) == 65535U;
    bool _S12;
    if(_S11)
    {
        _S12 = (ranks_0[int(1)]) == 65535U;
    }
    else
    {
        _S12 = false;
    }
    bool _S13 = (ranks_0[int(2)]) == 65535U;
    bool _S14;
    if(_S13)
    {
        _S14 = (ranks_0[int(3)]) == 65535U;
    }
    else
    {
        _S14 = false;
    }
    if(_S12)
    {
        _S12 = (ranks_0[int(3)]) != 65535U;
    }
    else
    {
        _S12 = false;
    }
    if(_S12)
    {
        _S12 = true;
    }
    else
    {
        if(_S14)
        {
            _S12 = (ranks_0[int(1)]) != 65535U;
        }
        else
        {
            _S12 = false;
        }
    }
    uint _S15 = ranks_0[int(0)];
    if(_S12)
    {
        i_1 = ranks_0[int(3)];
    }
    else
    {
        i_1 = ranks_0[int(1)];
    }
    return _S15 | (i_1 << 16U);
}

extern "C" __global__ void noiseStart(RWStructuredBuffer<uint> tensor_0, uint size_1)
{
    uint3  _S16 = blockIdx * blockDim + threadIdx;
    uint _S17 = _S16.x;
    uint _S18 = size_1 * size_1;
    bool _S19 = _S17 < (_S18 * 32U);
    if(_S19)
    {
        uint * _S20 = (&(tensor_0)[_S17]);
        uint _S21 = _S17 % size_1;
        uint _S22 = _S17 / size_1;
        uint _S23 = _S22 % size_1;
        uint _S24 = _S17 / _S18;
        uint _S25 = noiseWhite(_S21, _S23, _S24, size_1);
        *_S20 = _S25;
    }
    return;
}

__device__ uint3  noiseBlock(uint sweep_0, uint colour_0, uint block_0, uint size_2)
{
    uint _S26 = hash(sweep_0 * 7919U + 1U);
    uint _S27 = size_2 / 16U;
    uint _S28 = block_0 % _S27;
    uint _S29 = block_0 / _S27;
    uint _S30 = _S29 % _S27;
    uint _S31 = block_0 / (_S27 * _S27);
    uint3  _S32 = make_uint3 (_S28, _S30, _S31);
    uint3  _S33 = make_uint3 (colour_0 & 1U, (colour_0 >> 1U) & 1U, colour_0 >> 2U);
    return _S32 * make_uint3 (16U) + _S33 * make_uint3 (8U) + make_uint3 (_S26 & 7U, (_S26 >> 3U) & 7U, (_S26 >> 6U) & 7U);
}

__device__ uint stream(uint seed_0, uint index_0)
{
    uint _S34 = hash(index_0);
    uint _S35 = hash(seed_0 ^ _S34);
    return _S35;
}

static __device__ uint noiseExp_0(uint q_0)
{
    uint _S36 = (q_0 * 23637U) >> 14U;
    int _S37 = int(_S36 & 4095U);
    int e_0 = int(-3486) + ((int(448) * _S37) >> int(12));
    int e_1 = int(15688) + ((e_0 * _S37) >> int(12));
    int e_2 = int(-45418) + ((e_1 * _S37) >> int(12));
    int e_3 = int(65536) + ((e_2 * _S37) >> int(12));
    uint _S38 = _S36 >> 12U;
    uint _S39;
    if(_S38 < 31U)
    {
        _S39 = uint(e_3) >> _S38;
    }
    else
    {
        _S39 = 0U;
    }
    return _S39;
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
        uint _S40 = root_0 + bit_0;
        bool _S41 = rest_0 >= _S40;
        uint _S42;
        if(_S41)
        {
            _S42 = _S40;
        }
        else
        {
            _S42 = 0U;
        }
        uint rest_1 = rest_0 - _S42;
        uint _S43 = root_0 >> 1U;
        uint _S44;
        if(_S41)
        {
            _S44 = bit_0;
        }
        else
        {
            _S44 = 0U;
        }
        uint _S45 = _S43 + _S44;
        uint bit_1 = bit_0 >> 2U;
        root_0 = _S45;
        bit_0 = bit_1;
        rest_0 = rest_1;
    }
    return root_0;
}

static __device__ uint noiseFalloff_0(uint a_0, uint v_0)
{
    uint _S46 = a_0 & 65535U;
    uint _S47 = v_0 & 65535U;
    uint _S48 = ((U32_max((_S46), (_S47))) - (U32_min((_S46), (_S47)))) >> 2U;
    uint _S49 = a_0 >> 16U;
    uint _S50 = v_0 >> 16U;
    uint _S51 = ((U32_max((_S49), (_S50))) - (U32_min((_S49), (_S50)))) >> 2U;
    uint _S52 = noiseRoot_0(_S48 * _S48 + _S51 * _S51);
    uint _S53 = noiseExp_0(_S52 >> 2U);
    return _S53;
}

static __device__ uint2  noiseNear_0(RWStructuredBuffer<uint> tensor_1, uint3  n_0, uint d2_0, uint a_1, uint b_0, uint size_3)
{
    uint _S54 = *(&(tensor_1)[(n_0.z * size_3 + n_0.y) * size_3 + n_0.x]);
    uint _S55 = noiseExp_0(d2_0 * 929U);
    uint _S56 = _S55 >> 8U;
    uint _S57 = noiseFalloff_0(a_1, _S54);
    uint _S58 = noiseFalloff_0(b_0, _S54);
    return make_uint2 (_S56) * make_uint2 (_S57, _S58);
}

static __device__ uint2  noiseEnergy_0(RWStructuredBuffer<uint> tensor_2, uint3  at_0, uint a_2, uint b_1, uint3  skip_0, uint size_4)
{
    bool _S59;
    uint2  _S60 = make_uint2 (0U);
    int d_0 = int(-3);
    uint2  e_4 = _S60;
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
            int _S61 = int(size_4);
            uint _S62 = size_4 - 1U;
            uint3  _S63 = make_uint3 ((at_0.x + uint(dx_0 + _S61)) & _S62, (at_0.y + uint(d_0 + _S61)) & _S62, at_0.z);
            bool _S64 = dx_0 != int(0);
            if(_S64)
            {
                _S59 = true;
            }
            else
            {
                _S59 = d_0 != int(0);
            }
            bool _S65;
            if(_S59)
            {
                _S65 = !all_0(_S63 == skip_0);
            }
            else
            {
                _S65 = false;
            }
            if(_S65)
            {
                uint2  _S66 = noiseNear_0(tensor_2, _S63, uint(dx_0 * dx_0 + d_0 * d_0), a_2, b_1, size_4);
                uint2  e_6 = e_5 + _S66;
                e_5 = e_6;
            }
            int dx_1 = dx_0 + int(1);
            dx_0 = dx_1;
        }
        uint3  _S67 = make_uint3 (at_0.x, at_0.y, (at_0.z + uint(d_0 + int(32))) % 32U);
        bool _S68 = d_0 != int(0);
        if(_S68)
        {
            _S59 = !all_0(_S67 == skip_0);
        }
        else
        {
            _S59 = false;
        }
        if(_S59)
        {
            uint2  _S69 = noiseNear_0(tensor_2, _S67, uint(d_0 * d_0), a_2, b_1, size_4);
            uint2  e_7 = e_5 + _S69;
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
    uint3  _S70 = noiseBlock(sweep_1, colour_1, block_1, size_5);
    uint _S71 = size_5 - 1U;
    uint3  _S72 = make_uint3 (_S71, _S71, 31U);
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
        uint _S73 = _S70.x;
        uint _S74 = _S70.y;
        uint _S75 = stream((_S73 | (_S74 << 11U)) | ((_S70.z) << 22U), sweep_1 * 4096U + attempt_0);
        uint _S76 = hash(_S75);
        uint3  _S77 = (_S70 + make_uint3 (_S76 & 7U, (_S76 >> 3U) & 7U, (_S76 >> 6U) & 7U)) & _S72;
        uint _S78 = (_S73 + ((_S76 >> 9U) & 7U)) & _S71;
        uint _S79 = (_S74 + ((_S76 >> 12U) & 7U)) & _S71;
        uint _S80 = _S77.z;
        uint3  _S81 = make_uint3 (_S78, _S79, _S80);
        uint _S82 = _S80 * size_5;
        uint _S83 = (_S82 + _S77.y) * size_5 + _S77.x;
        uint _S84 = (_S82 + _S79) * size_5 + _S78;
        uint _S85 = *(&(tensor_3)[_S83]);
        uint _S86 = *(&(tensor_3)[_S84]);
        uint2  _S87 = noiseEnergy_0(tensor_3, _S77, _S85, _S86, _S81, size_5);
        uint2  _S88 = noiseEnergy_0(tensor_3, _S81, _S86, _S85, _S77, size_5);
        bool _S89 = _S83 != _S84;
        bool _S90;
        if(_S89)
        {
            _S90 = (_S87.y + _S88.y) < (_S87.x + _S88.x);
        }
        else
        {
            _S90 = false;
        }
        if(_S90)
        {
            *(&(tensor_3)[_S83]) = _S86;
            *(&(tensor_3)[_S84]) = _S85;
        }
        uint attempt_1 = attempt_0 + 1U;
        attempt_0 = attempt_1;
    }
    return;
}

extern "C" __global__ void noiseSweep(RWStructuredBuffer<uint> tensor_4, uint size_6, uint sweep_2, uint colour_2)
{
    uint3  _S91 = blockIdx * blockDim + threadIdx;
    uint _S92 = _S91.x;
    bool _S93 = _S92 < (size_6 / 16U * (size_6 / 16U) * 2U);
    if(_S93)
    {
        noiseSweepBlock_0(tensor_4, sweep_2, colour_2, _S92, size_6);
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
    Random _S94;
    (&_S94)->state = state_0;
    (&_S94)->value = value_0;
    return _S94;
}

static __device__ float random_0(uint * state_1)
{
    uint _S95 = hash(*state_1);
    *state_1 = _S95;
    return float((*state_1) >> int(8)) * 5.9604644775390625e-08f;
}

__device__ Random pcg(uint state_2)
{
    uint _S96 = state_2;
    float value_1 = random_0(&_S96);
    return Random_x24init_0(_S96, value_1);
}

__device__ uint2  noiseOffset(uint k_2)
{
    uint2  _S97 = make_uint2 (k_2 * 3242174889U, k_2 * 2447445414U) >> make_uint2 (16U);
    uint _S98 = (fkBlueNoiseSize());
    return (_S97 * make_uint2 (_S98)) >> make_uint2 (16U);
}

__device__ uint noiseOrigin(uint2  p_0, uint k_3)
{
    uint _S99 = ((p_0.x) >> 11U) | (((p_0.y) >> 11U) << 4U);
    uint2  _S100 = noiseOffset(8192U + (k_3 >> 10U) + (_S99 << 20U));
    uint2  _S101 = (p_0 + _S100) & make_uint2 (2047U);
    return ((_S101.x) | ((_S101.y) << 11U)) | ((k_3 & 1023U) << 22U);
}

__device__ uint noiseAddress(uint origin_0, uint bounce_0)
{
    uint2  _S102 = make_uint2 (origin_0 & 2047U, (origin_0 >> 11U) & 2047U);
    uint2  _S103 = noiseOffset(64U + bounce_0 * 17U);
    uint2  _S104 = (_S102 + _S103) & make_uint2 (2047U);
    return ((_S104.x) | ((_S104.y) << 11U)) | ((origin_0 >> 22U) << 22U);
}

__device__ __noinline__ Random draw(uint address_0, uint variable_0)
{
    uint _S105 = address_0 >> 22U;
    uint _S106 = _S105 / 32U;
    uint2  _S107 = make_uint2 (address_0 & 2047U, (address_0 >> 11U) & 2047U);
    uint _S108 = variable_0 & 2147483647U;
    uint2  _S109 = noiseOffset(_S108);
    uint2  _S110 = _S107 + _S109;
    uint2  _S111 = noiseOffset(4096U + _S106);
    uint2  _S112 = _S110 + _S111;
    uint _S113 = (fkBlueNoiseSize());
    uint2  _S114 = _S112 & make_uint2 (_S113 - 1U);
    uint _S115 = (fkBlueNoise((_S114.x), (_S114.y), ((_S105 + ((_S106 * 2654435769U) >> 27U)) % 32U)));
    bool _S116 = (variable_0 & 2147483648U) != 0U;
    uint _S117 = stream(address_0, _S108);
    Random _S118 = pcg(_S117);
    float _S119;
    if(_S115 == 4294967295U)
    {
        if(_S116)
        {
            Random _S120 = pcg(_S118.state);
            _S119 = _S120.value;
        }
        else
        {
            _S119 = _S118.value;
        }
    }
    else
    {
        uint _S121;
        if(_S116)
        {
            _S121 = _S115 >> 16U;
        }
        else
        {
            _S121 = _S115 & 65535U;
        }
        _S119 = (float(_S121) + 0.5f) / 6.5536e+04f;
    }
    return Random_x24init_0(address_0, _S119);
}

