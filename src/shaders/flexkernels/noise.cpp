#include "slang-cpp-prelude.h"

#ifdef SLANG_PRELUDE_NAMESPACE
using namespace SLANG_PRELUDE_NAMESPACE;
#endif

#ifndef FK_BLUE_NOISE
static uint32_t fkBlueNoiseSize() { return 512u; }
#endif

#ifndef FK_BLUE_NOISE
static uint32_t fkBlueNoise(uint32_t, uint32_t, uint32_t) { return 0xFFFFFFFFu; }
#endif

struct EntryPointParams_0
{
    RWStructuredBuffer<uint32_t> tensor_0;
    uint32_t size_0;
};

struct EntryPointParams_1
{
    RWStructuredBuffer<uint32_t> tensor_1;
    uint32_t size_1;
    uint32_t sweep_0;
    uint32_t colour_0;
};

struct Random
{
    uint32_t state;
    float value;
};

static bool all_0(Vector<bool, 3>  x_0)
{
    bool result_0 = true;
    int32_t i_0 = int(0);
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

SLANG_PRELUDE_EXPORT
uint32_t hash(uint32_t x_1)
{
    uint32_t _S1 = x_1 * 747796405U + 2891336453U;
    uint32_t _S2 = ((_S1 >> ((_S1 >> 28U) + 4U)) ^ _S1) * 277803737U;
    return (_S2 >> 22U) ^ _S2;
}

SLANG_PRELUDE_EXPORT
uint32_t noiseWhite(uint32_t x_2, uint32_t y_0, uint32_t t_0, uint32_t size_2)
{
    FixedArray<uint32_t, 4>  ranks_0;
    uint32_t i_1 = 0U;
    for(;;)
    {
        if(i_1 < 4U)
        {
        }
        else
        {
            break;
        }
        uint32_t _S3 = size_2 - 1U;
        uint32_t _S4 = (x_2 + size_2 / 2U) & _S3;
        bool _S5 = i_1 < 2U;
        uint32_t _S6 = _slang_select(_S5, x_2,_S4);
        uint32_t l_0 = _S6;
        uint32_t r_0 = y_0;
        uint32_t k_0 = 0U;
        for(;;)
        {
            if(k_0 < 4U)
            {
            }
            else
            {
                break;
            }
            uint32_t _S7 = hash(((r_0 ^ (t_0 << 16U)) ^ (k_0 << 28U)) ^ ((i_1 & 1U) << 31U));
            uint32_t _S8 = l_0 ^ (_S7 & _S3);
            uint32_t k_1 = k_0 + 1U;
            l_0 = r_0;
            r_0 = _S8;
            k_0 = k_1;
        }
        uint32_t _S9 = l_0 + r_0 * size_2;
        uint32_t _S10 = size_2 * size_2;
        uint32_t _S11;
        if(_S10 >= 65536U)
        {
            uint32_t _S12 = _S9 / (_S10 / 65536U);
            _S11 = _S12;
        }
        else
        {
            uint32_t _S13 = 65536U / _S10;
            _S11 = _S9 * _S13;
        }
        ranks_0[i_1] = _S11;
        uint32_t i_2 = i_1 + 1U;
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
    uint32_t _S18 = ranks_0[int(0)];
    uint32_t _S19 = ranks_0[int(1)];
    uint32_t _S20 = ranks_0[int(3)];
    uint32_t _S21 = _slang_select(_S15, _S20,_S19);
    return _S18 | (_S21 << 16U);
}

void _noiseStart(void* _S22, void* entryPointParams_0, void* _S23)
{
    ComputeThreadVaryingInput * _S24 = (slang_bit_cast<ComputeThreadVaryingInput *>(_S22));
    Vector<uint32_t, 3>  _S25 = _S24->groupID * Vector<uint32_t, 3> (64U, 1U, 1U) + _S24->groupThreadID;
    uint32_t _S26 = _S25.x;
    bool _S27 = _S26 < ((slang_bit_cast<EntryPointParams_0*>(entryPointParams_0))->size_0 * (slang_bit_cast<EntryPointParams_0*>(entryPointParams_0))->size_0 * 32U);
    if(_S27)
    {
        uint32_t * _S28 = (&((slang_bit_cast<EntryPointParams_0*>(entryPointParams_0))->tensor_0)[_S26]);
        uint32_t _S29 = _S26 % (slang_bit_cast<EntryPointParams_0*>(entryPointParams_0))->size_0;
        uint32_t _S30 = _S26 / (slang_bit_cast<EntryPointParams_0*>(entryPointParams_0))->size_0;
        uint32_t _S31 = _S30 % (slang_bit_cast<EntryPointParams_0*>(entryPointParams_0))->size_0;
        uint32_t _S32 = _S26 / ((slang_bit_cast<EntryPointParams_0*>(entryPointParams_0))->size_0 * (slang_bit_cast<EntryPointParams_0*>(entryPointParams_0))->size_0);
        uint32_t _S33 = noiseWhite(_S29, _S31, _S32, (slang_bit_cast<EntryPointParams_0*>(entryPointParams_0))->size_0);
        *_S28 = _S33;
    }
    return;
}

SLANG_PRELUDE_EXPORT
Vector<uint32_t, 3>  noiseBlock(uint32_t sweep_1, uint32_t colour_1, uint32_t block_0, uint32_t size_3)
{
    uint32_t _S34 = hash(sweep_1 * 7919U + 1U);
    uint32_t _S35 = size_3 / 16U;
    uint32_t _S36 = block_0 % _S35;
    uint32_t _S37 = block_0 / _S35;
    uint32_t _S38 = _S37 % _S35;
    uint32_t _S39 = block_0 / (_S35 * _S35);
    Vector<uint32_t, 3>  _S40 = Vector<uint32_t, 3> (_S36, _S38, _S39);
    Vector<uint32_t, 3>  _S41 = Vector<uint32_t, 3> (colour_1 & 1U, (colour_1 >> 1U) & 1U, colour_1 >> 2U);
    return _S40 * (Vector<uint32_t, 3> )16U + _S41 * (Vector<uint32_t, 3> )8U + Vector<uint32_t, 3> (_S34 & 7U, (_S34 >> 3U) & 7U, (_S34 >> 6U) & 7U);
}

SLANG_PRELUDE_EXPORT
uint32_t stream(uint32_t seed_0, uint32_t index_0)
{
    uint32_t _S42 = hash(index_0);
    uint32_t _S43 = hash(seed_0 ^ _S42);
    return _S43;
}

static uint32_t noiseExp_0(uint32_t q_0)
{
    uint32_t _S44 = (q_0 * 23637U) >> 14U;
    int32_t _S45 = int32_t(_S44 & 4095U);
    int32_t e_0 = int(-3486) + ((int(448) * _S45) >> int(12));
    int32_t e_1 = int(15688) + ((e_0 * _S45) >> int(12));
    int32_t e_2 = int(-45418) + ((e_1 * _S45) >> int(12));
    int32_t e_3 = int(65536) + ((e_2 * _S45) >> int(12));
    return uint32_t(e_3) >> (U32_min((_S44 >> 12U), (31U)));
}

static uint32_t noiseRoot_0(uint32_t q_1)
{
    uint32_t root_0 = 0U;
    uint32_t bit_0 = 268435456U;
    uint32_t rest_0 = q_1;
    for(;;)
    {
        if(bit_0 != 0U)
        {
        }
        else
        {
            break;
        }
        uint32_t _S46 = root_0 + bit_0;
        bool _S47 = rest_0 >= _S46;
        uint32_t _S48 = _slang_select(_S47, _S46,0U);
        uint32_t rest_1 = rest_0 - _S48;
        uint32_t _S49 = root_0 >> 1U;
        uint32_t _S50 = _slang_select(_S47, bit_0,0U);
        uint32_t _S51 = _S49 + _S50;
        uint32_t bit_1 = bit_0 >> 2U;
        root_0 = _S51;
        bit_0 = bit_1;
        rest_0 = rest_1;
    }
    return root_0;
}

static uint32_t noiseFalloff_0(uint32_t a_0, uint32_t v_0)
{
    uint32_t _S52 = a_0 & 65535U;
    uint32_t _S53 = v_0 & 65535U;
    uint32_t _S54 = ((U32_max((_S52), (_S53))) - (U32_min((_S52), (_S53)))) >> 2U;
    uint32_t _S55 = a_0 >> 16U;
    uint32_t _S56 = v_0 >> 16U;
    uint32_t _S57 = ((U32_max((_S55), (_S56))) - (U32_min((_S55), (_S56)))) >> 2U;
    uint32_t _S58 = noiseRoot_0(_S54 * _S54 + _S57 * _S57);
    uint32_t _S59 = noiseExp_0(_S58 >> 2U);
    return _S59;
}

static Vector<uint32_t, 2>  noiseNear_0(RWStructuredBuffer<uint32_t> tensor_2, Vector<uint32_t, 3>  n_0, uint32_t d2_0, uint32_t a_1, uint32_t b_0, uint32_t size_4)
{
    uint32_t _S60 = *(&(tensor_2)[(n_0.z * size_4 + n_0.y) * size_4 + n_0.x]);
    uint32_t _S61 = noiseExp_0(d2_0 * 929U);
    uint32_t _S62 = _S61 >> 8U;
    uint32_t _S63 = noiseFalloff_0(a_1, _S60);
    uint32_t _S64 = noiseFalloff_0(b_0, _S60);
    return (Vector<uint32_t, 2> )_S62 * Vector<uint32_t, 2> (_S63, _S64);
}

static Vector<uint32_t, 2>  noiseEnergy_0(RWStructuredBuffer<uint32_t> tensor_3, Vector<uint32_t, 3>  at_0, uint32_t a_2, uint32_t b_1, Vector<uint32_t, 3>  skip_0, uint32_t size_5)
{
    bool _S65;
    Vector<uint32_t, 2>  _S66 = (Vector<uint32_t, 2> )0U;
    int32_t d_0 = int(-3);
    Vector<uint32_t, 2>  e_4 = _S66;
    for(;;)
    {
        if(d_0 <= int(3))
        {
        }
        else
        {
            break;
        }
        int32_t dx_0 = int(-3);
        Vector<uint32_t, 2>  e_5 = e_4;
        for(;;)
        {
            if(dx_0 <= int(3))
            {
            }
            else
            {
                break;
            }
            int32_t _S67 = int32_t(size_5);
            uint32_t _S68 = size_5 - 1U;
            Vector<uint32_t, 3>  _S69 = Vector<uint32_t, 3> ((at_0.x + uint32_t(dx_0 + _S67)) & _S68, (at_0.y + uint32_t(d_0 + _S67)) & _S68, at_0.z);
            bool _S70 = dx_0 != int(0);
            if(_S70)
            {
                _S65 = true;
            }
            else
            {
                _S65 = d_0 != int(0);
            }
            bool _S71;
            if(_S65)
            {
                _S71 = !all_0(_S69 == skip_0);
            }
            else
            {
                _S71 = false;
            }
            if(_S71)
            {
                Vector<uint32_t, 2>  _S72 = noiseNear_0(tensor_3, _S69, uint32_t(dx_0 * dx_0 + d_0 * d_0), a_2, b_1, size_5);
                Vector<uint32_t, 2>  e_6 = e_5 + _S72;
                e_5 = e_6;
            }
            int32_t dx_1 = dx_0 + int(1);
            dx_0 = dx_1;
        }
        Vector<uint32_t, 3>  _S73 = Vector<uint32_t, 3> (at_0.x, at_0.y, (at_0.z + uint32_t(d_0 + int(32))) % 32U);
        bool _S74 = d_0 != int(0);
        if(_S74)
        {
            _S65 = !all_0(_S73 == skip_0);
        }
        else
        {
            _S65 = false;
        }
        if(_S65)
        {
            Vector<uint32_t, 2>  _S75 = noiseNear_0(tensor_3, _S73, uint32_t(d_0 * d_0), a_2, b_1, size_5);
            Vector<uint32_t, 2>  e_7 = e_5 + _S75;
            e_4 = e_7;
        }
        else
        {
            e_4 = e_5;
        }
        int32_t d_1 = d_0 + int(1);
        d_0 = d_1;
    }
    return e_4;
}

static void noiseSweepBlock_0(RWStructuredBuffer<uint32_t> tensor_4, uint32_t sweep_2, uint32_t colour_2, uint32_t block_1, uint32_t size_6)
{
    Vector<uint32_t, 3>  _S76 = noiseBlock(sweep_2, colour_2, block_1, size_6);
    uint32_t _S77 = size_6 - 1U;
    Vector<uint32_t, 3>  _S78 = Vector<uint32_t, 3> (_S77, _S77, 31U);
    uint32_t attempt_0 = 0U;
    for(;;)
    {
        if(attempt_0 < 512U)
        {
        }
        else
        {
            break;
        }
        uint32_t _S79 = _S76.x;
        uint32_t _S80 = _S76.y;
        uint32_t _S81 = stream((_S79 | (_S80 << 11U)) | ((_S76.z) << 22U), sweep_2 * 4096U + attempt_0);
        uint32_t _S82 = hash(_S81);
        Vector<uint32_t, 3>  _S83 = (_S76 + Vector<uint32_t, 3> (_S82 & 7U, (_S82 >> 3U) & 7U, (_S82 >> 6U) & 7U)) & _S78;
        uint32_t _S84 = (_S79 + ((_S82 >> 9U) & 7U)) & _S77;
        uint32_t _S85 = (_S80 + ((_S82 >> 12U) & 7U)) & _S77;
        uint32_t _S86 = _S83.z;
        Vector<uint32_t, 3>  _S87 = Vector<uint32_t, 3> (_S84, _S85, _S86);
        uint32_t _S88 = _S86 * size_6;
        uint32_t _S89 = (_S88 + _S83.y) * size_6 + _S83.x;
        uint32_t _S90 = (_S88 + _S85) * size_6 + _S84;
        uint32_t _S91 = *(&(tensor_4)[_S89]);
        uint32_t _S92 = *(&(tensor_4)[_S90]);
        Vector<uint32_t, 2>  _S93 = noiseEnergy_0(tensor_4, _S83, _S91, _S92, _S87, size_6);
        Vector<uint32_t, 2>  _S94 = noiseEnergy_0(tensor_4, _S87, _S92, _S91, _S83, size_6);
        bool _S95 = _S89 != _S90;
        bool _S96;
        if(_S95)
        {
            _S96 = (_S93.y + _S94.y) < (_S93.x + _S94.x);
        }
        else
        {
            _S96 = false;
        }
        if(_S96)
        {
            *(&(tensor_4)[_S89]) = _S92;
            *(&(tensor_4)[_S90]) = _S91;
        }
        uint32_t attempt_1 = attempt_0 + 1U;
        attempt_0 = attempt_1;
    }
    return;
}

void _noiseSweep(void* _S97, void* entryPointParams_1, void* _S98)
{
    ComputeThreadVaryingInput * _S99 = (slang_bit_cast<ComputeThreadVaryingInput *>(_S97));
    Vector<uint32_t, 3>  _S100 = _S99->groupID * Vector<uint32_t, 3> (64U, 1U, 1U) + _S99->groupThreadID;
    uint32_t _S101 = _S100.x;
    bool _S102 = _S101 < ((slang_bit_cast<EntryPointParams_1*>(entryPointParams_1))->size_1 / 16U * ((slang_bit_cast<EntryPointParams_1*>(entryPointParams_1))->size_1 / 16U) * 2U);
    if(_S102)
    {
        noiseSweepBlock_0((slang_bit_cast<EntryPointParams_1*>(entryPointParams_1))->tensor_1, (slang_bit_cast<EntryPointParams_1*>(entryPointParams_1))->sweep_0, (slang_bit_cast<EntryPointParams_1*>(entryPointParams_1))->colour_0, _S101, (slang_bit_cast<EntryPointParams_1*>(entryPointParams_1))->size_1);
    }
    return;
}

static Random Random_x24init_0(uint32_t state_0, float value_0)
{
    Random _S103;
    (&_S103)->state = state_0;
    (&_S103)->value = value_0;
    return _S103;
}

SLANG_PRELUDE_EXPORT
Random pcg(uint32_t state_1)
{
    uint32_t _S104 = hash(state_1);
    float value_1 = float(_S104 >> int(8)) * 5.9604644775390625e-08f;
    return Random_x24init_0(_S104, value_1);
}

SLANG_PRELUDE_EXPORT
Vector<uint32_t, 2>  noiseOffset(uint32_t k_2)
{
    Vector<uint32_t, 2>  _S105 = Vector<uint32_t, 2> (k_2 * 3242174889U, k_2 * 2447445414U) >> ((Vector<uint32_t, 2> )16U);
    uint32_t _S106 = (fkBlueNoiseSize());
    return (_S105 * (Vector<uint32_t, 2> )_S106) >> ((Vector<uint32_t, 2> )16U);
}

SLANG_PRELUDE_EXPORT
uint32_t noiseOrigin(Vector<uint32_t, 2>  p_0, uint32_t k_3)
{
    uint32_t _S107 = ((p_0.x) >> 11U) | (((p_0.y) >> 11U) << 4U);
    Vector<uint32_t, 2>  _S108 = noiseOffset(8192U + (k_3 >> 10U) + (_S107 << 20U));
    Vector<uint32_t, 2>  _S109 = (p_0 + _S108) & ((Vector<uint32_t, 2> )2047U);
    return ((_S109.x) | ((_S109.y) << 11U)) | ((k_3 & 1023U) << 22U);
}

SLANG_PRELUDE_EXPORT
uint32_t noiseAddress(uint32_t origin_0, uint32_t bounce_0)
{
    Vector<uint32_t, 2>  _S110 = Vector<uint32_t, 2> (origin_0 & 2047U, (origin_0 >> 11U) & 2047U);
    Vector<uint32_t, 2>  _S111 = noiseOffset(64U + bounce_0 * 17U);
    Vector<uint32_t, 2>  _S112 = (_S110 + _S111) & ((Vector<uint32_t, 2> )2047U);
    return ((_S112.x) | ((_S112.y) << 11U)) | ((origin_0 >> 22U) << 22U);
}

SLANG_PRELUDE_EXPORT
Random draw(uint32_t address_0, uint32_t variable_0)
{
    uint32_t _S113 = address_0 >> 22U;
    uint32_t _S114 = _S113 / 32U;
    Vector<uint32_t, 2>  _S115 = Vector<uint32_t, 2> (address_0 & 2047U, (address_0 >> 11U) & 2047U);
    uint32_t _S116 = variable_0 & 2147483647U;
    Vector<uint32_t, 2>  _S117 = noiseOffset(_S116);
    Vector<uint32_t, 2>  _S118 = _S115 + _S117;
    Vector<uint32_t, 2>  _S119 = noiseOffset(4096U + _S114);
    Vector<uint32_t, 2>  _S120 = _S118 + _S119;
    uint32_t _S121 = (fkBlueNoiseSize());
    Vector<uint32_t, 2>  _S122 = _S120 & ((Vector<uint32_t, 2> )(_S121 - 1U));
    uint32_t _S123 = (fkBlueNoise((_S122.x), (_S122.y), ((_S113 + ((_S114 * 2654435769U) >> 27U)) % 32U)));
    bool _S124 = (variable_0 & 2147483648U) != 0U;
    uint32_t _S125 = stream(address_0, _S116);
    Random _S126 = pcg(_S125);
    uint32_t _S127 = _S123 & 65535U;
    uint32_t _S128 = _S123 >> 16U;
    uint32_t _S129 = _slang_select(_S124, _S128,_S127);
    float _S130 = (float(_S129) + 0.5f) / 6.5536e+04f;
    Random _S131 = pcg(_S126.state);
    float _S132 = _slang_select(_S124, _S131.value,_S126.value);
    bool _S133 = _S123 == 4294967295U;
    float _S134 = _slang_select(_S133, _S132,_S130);
    return Random_x24init_0(address_0, _S134);
}

SLANG_PRELUDE_EXPORT
void noiseStart_Thread(ComputeThreadVaryingInput* varyingInput, void* entryPointParams, void* globalParams)
{
    _noiseStart(varyingInput, entryPointParams, globalParams);
}
SLANG_PRELUDE_EXPORT
void noiseStart_Group(ComputeVaryingInput* varyingInput, void* entryPointParams, void* globalParams)
{
    ComputeThreadVaryingInput threadInput = {};
    threadInput.groupID = varyingInput->startGroupID;
    for (uint32_t x = 0; x < 64; ++x)
    {
        threadInput.groupThreadID.x = x;
        _noiseStart(&threadInput, entryPointParams, globalParams);
    }
}
SLANG_PRELUDE_EXPORT
void noiseStart(ComputeVaryingInput* varyingInput, void* entryPointParams, void* globalParams)
{
    ComputeVaryingInput vi = *varyingInput;
    ComputeVaryingInput groupVaryingInput = {};
    for (uint32_t z = vi.startGroupID.z; z < vi.endGroupID.z; ++z)
    {
        groupVaryingInput.startGroupID.z = z;
        for (uint32_t y = vi.startGroupID.y; y < vi.endGroupID.y; ++y)
        {
            groupVaryingInput.startGroupID.y = y;
            for (uint32_t x = vi.startGroupID.x; x < vi.endGroupID.x; ++x)
            {
                groupVaryingInput.startGroupID.x = x;
                noiseStart_Group(&groupVaryingInput, entryPointParams, globalParams);
            }
        }
    }
}
SLANG_PRELUDE_EXPORT
void noiseSweep_Thread(ComputeThreadVaryingInput* varyingInput, void* entryPointParams, void* globalParams)
{
    _noiseSweep(varyingInput, entryPointParams, globalParams);
}
SLANG_PRELUDE_EXPORT
void noiseSweep_Group(ComputeVaryingInput* varyingInput, void* entryPointParams, void* globalParams)
{
    ComputeThreadVaryingInput threadInput = {};
    threadInput.groupID = varyingInput->startGroupID;
    for (uint32_t x = 0; x < 64; ++x)
    {
        threadInput.groupThreadID.x = x;
        _noiseSweep(&threadInput, entryPointParams, globalParams);
    }
}
SLANG_PRELUDE_EXPORT
void noiseSweep(ComputeVaryingInput* varyingInput, void* entryPointParams, void* globalParams)
{
    ComputeVaryingInput vi = *varyingInput;
    ComputeVaryingInput groupVaryingInput = {};
    for (uint32_t z = vi.startGroupID.z; z < vi.endGroupID.z; ++z)
    {
        groupVaryingInput.startGroupID.z = z;
        for (uint32_t y = vi.startGroupID.y; y < vi.endGroupID.y; ++y)
        {
            groupVaryingInput.startGroupID.y = y;
            for (uint32_t x = vi.startGroupID.x; x < vi.endGroupID.x; ++x)
            {
                groupVaryingInput.startGroupID.x = x;
                noiseSweep_Group(&groupVaryingInput, entryPointParams, globalParams);
            }
        }
    }
}
