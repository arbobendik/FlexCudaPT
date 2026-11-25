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
        uint32_t _S3;
        if(i_1 < 2U)
        {
            _S3 = x_2;
        }
        else
        {
            _S3 = (x_2 + size_2 / 2U) & (size_2 - 1U);
        }
        uint32_t l_0 = _S3;
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
            uint32_t _S4 = hash(((r_0 ^ (t_0 << 16U)) ^ (k_0 << 28U)) ^ ((i_1 & 1U) << 31U));
            uint32_t _S5 = l_0 ^ (_S4 & (size_2 - 1U));
            uint32_t k_1 = k_0 + 1U;
            l_0 = r_0;
            r_0 = _S5;
            k_0 = k_1;
        }
        uint32_t _S6 = l_0 + r_0 * size_2;
        uint32_t _S7 = size_2 * size_2;
        uint32_t _S8;
        if(_S7 >= 65536U)
        {
            uint32_t _S9 = _S6 / (_S7 / 65536U);
            _S8 = _S9;
        }
        else
        {
            uint32_t _S10 = 65536U / _S7;
            _S8 = _S6 * _S10;
        }
        ranks_0[i_1] = _S8;
        uint32_t i_2 = i_1 + 1U;
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
    uint32_t _S15 = ranks_0[int(0)];
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

void _noiseStart(void* _S16, void* entryPointParams_0, void* _S17)
{
    ComputeThreadVaryingInput * _S18 = (slang_bit_cast<ComputeThreadVaryingInput *>(_S16));
    Vector<uint32_t, 3>  _S19 = _S18->groupID * Vector<uint32_t, 3> (64U, 1U, 1U) + _S18->groupThreadID;
    uint32_t _S20 = _S19.x;
    bool _S21 = _S20 < ((slang_bit_cast<EntryPointParams_0*>(entryPointParams_0))->size_0 * (slang_bit_cast<EntryPointParams_0*>(entryPointParams_0))->size_0 * 32U);
    if(_S21)
    {
        uint32_t * _S22 = (&((slang_bit_cast<EntryPointParams_0*>(entryPointParams_0))->tensor_0)[_S20]);
        uint32_t _S23 = _S20 % (slang_bit_cast<EntryPointParams_0*>(entryPointParams_0))->size_0;
        uint32_t _S24 = _S20 / (slang_bit_cast<EntryPointParams_0*>(entryPointParams_0))->size_0;
        uint32_t _S25 = _S24 % (slang_bit_cast<EntryPointParams_0*>(entryPointParams_0))->size_0;
        uint32_t _S26 = _S20 / ((slang_bit_cast<EntryPointParams_0*>(entryPointParams_0))->size_0 * (slang_bit_cast<EntryPointParams_0*>(entryPointParams_0))->size_0);
        uint32_t _S27 = noiseWhite(_S23, _S25, _S26, (slang_bit_cast<EntryPointParams_0*>(entryPointParams_0))->size_0);
        *_S22 = _S27;
    }
    return;
}

SLANG_PRELUDE_EXPORT
Vector<uint32_t, 3>  noiseBlock(uint32_t sweep_1, uint32_t colour_1, uint32_t block_0, uint32_t size_3)
{
    uint32_t _S28 = hash(sweep_1 * 7919U + 1U);
    uint32_t _S29 = size_3 / 16U;
    uint32_t _S30 = block_0 % _S29;
    uint32_t _S31 = block_0 / _S29;
    uint32_t _S32 = _S31 % _S29;
    uint32_t _S33 = block_0 / (_S29 * _S29);
    Vector<uint32_t, 3>  _S34 = Vector<uint32_t, 3> (_S30, _S32, _S33);
    Vector<uint32_t, 3>  _S35 = Vector<uint32_t, 3> (colour_1 & 1U, (colour_1 >> 1U) & 1U, colour_1 >> 2U);
    return _S34 * (Vector<uint32_t, 3> )16U + _S35 * (Vector<uint32_t, 3> )8U + Vector<uint32_t, 3> (_S28 & 7U, (_S28 >> 3U) & 7U, (_S28 >> 6U) & 7U);
}

SLANG_PRELUDE_EXPORT
uint32_t stream(uint32_t seed_0, uint32_t index_0)
{
    uint32_t _S36 = hash(index_0);
    uint32_t _S37 = hash(seed_0 ^ _S36);
    return _S37;
}

static uint32_t noiseExp_0(uint32_t q_0)
{
    uint32_t _S38 = (q_0 * 23637U) >> 14U;
    int32_t _S39 = int32_t(_S38 & 4095U);
    int32_t e_0 = int(-3486) + ((int(448) * _S39) >> int(12));
    int32_t e_1 = int(15688) + ((e_0 * _S39) >> int(12));
    int32_t e_2 = int(-45418) + ((e_1 * _S39) >> int(12));
    int32_t e_3 = int(65536) + ((e_2 * _S39) >> int(12));
    uint32_t _S40 = _S38 >> 12U;
    uint32_t _S41;
    if(_S40 < 31U)
    {
        _S41 = uint32_t(e_3) >> _S40;
    }
    else
    {
        _S41 = 0U;
    }
    return _S41;
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
        uint32_t _S42 = root_0 + bit_0;
        bool _S43 = rest_0 >= _S42;
        uint32_t _S44;
        if(_S43)
        {
            _S44 = _S42;
        }
        else
        {
            _S44 = 0U;
        }
        uint32_t rest_1 = rest_0 - _S44;
        uint32_t _S45 = root_0 >> 1U;
        uint32_t _S46;
        if(_S43)
        {
            _S46 = bit_0;
        }
        else
        {
            _S46 = 0U;
        }
        uint32_t _S47 = _S45 + _S46;
        uint32_t bit_1 = bit_0 >> 2U;
        root_0 = _S47;
        bit_0 = bit_1;
        rest_0 = rest_1;
    }
    return root_0;
}

static uint32_t noiseFalloff_0(uint32_t a_0, uint32_t v_0)
{
    uint32_t _S48 = a_0 & 65535U;
    uint32_t _S49 = v_0 & 65535U;
    uint32_t _S50 = ((U32_max((_S48), (_S49))) - (U32_min((_S48), (_S49)))) >> 2U;
    uint32_t _S51 = a_0 >> 16U;
    uint32_t _S52 = v_0 >> 16U;
    uint32_t _S53 = ((U32_max((_S51), (_S52))) - (U32_min((_S51), (_S52)))) >> 2U;
    uint32_t _S54 = noiseRoot_0(_S50 * _S50 + _S53 * _S53);
    uint32_t _S55 = noiseExp_0(_S54 >> 2U);
    return _S55;
}

static Vector<uint32_t, 2>  noiseNear_0(RWStructuredBuffer<uint32_t> tensor_2, Vector<uint32_t, 3>  n_0, uint32_t d2_0, uint32_t a_1, uint32_t b_0, uint32_t size_4)
{
    uint32_t _S56 = *(&(tensor_2)[(n_0.z * size_4 + n_0.y) * size_4 + n_0.x]);
    uint32_t _S57 = noiseExp_0(d2_0 * 929U);
    uint32_t _S58 = _S57 >> 8U;
    uint32_t _S59 = noiseFalloff_0(a_1, _S56);
    uint32_t _S60 = noiseFalloff_0(b_0, _S56);
    return (Vector<uint32_t, 2> )_S58 * Vector<uint32_t, 2> (_S59, _S60);
}

static Vector<uint32_t, 2>  noiseEnergy_0(RWStructuredBuffer<uint32_t> tensor_3, Vector<uint32_t, 3>  at_0, uint32_t a_2, uint32_t b_1, Vector<uint32_t, 3>  skip_0, uint32_t size_5)
{
    bool _S61;
    Vector<uint32_t, 2>  _S62 = (Vector<uint32_t, 2> )0U;
    int32_t d_0 = int(-3);
    Vector<uint32_t, 2>  e_4 = _S62;
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
            int32_t _S63 = int32_t(size_5);
            uint32_t _S64 = size_5 - 1U;
            Vector<uint32_t, 3>  _S65 = Vector<uint32_t, 3> ((at_0.x + uint32_t(dx_0 + _S63)) & _S64, (at_0.y + uint32_t(d_0 + _S63)) & _S64, at_0.z);
            bool _S66 = dx_0 != int(0);
            if(_S66)
            {
                _S61 = true;
            }
            else
            {
                _S61 = d_0 != int(0);
            }
            bool _S67;
            if(_S61)
            {
                _S67 = !all_0(_S65 == skip_0);
            }
            else
            {
                _S67 = false;
            }
            if(_S67)
            {
                Vector<uint32_t, 2>  _S68 = noiseNear_0(tensor_3, _S65, uint32_t(dx_0 * dx_0 + d_0 * d_0), a_2, b_1, size_5);
                Vector<uint32_t, 2>  e_6 = e_5 + _S68;
                e_5 = e_6;
            }
            int32_t dx_1 = dx_0 + int(1);
            dx_0 = dx_1;
        }
        Vector<uint32_t, 3>  _S69 = Vector<uint32_t, 3> (at_0.x, at_0.y, (at_0.z + uint32_t(d_0 + int(32))) % 32U);
        bool _S70 = d_0 != int(0);
        if(_S70)
        {
            _S61 = !all_0(_S69 == skip_0);
        }
        else
        {
            _S61 = false;
        }
        if(_S61)
        {
            Vector<uint32_t, 2>  _S71 = noiseNear_0(tensor_3, _S69, uint32_t(d_0 * d_0), a_2, b_1, size_5);
            Vector<uint32_t, 2>  e_7 = e_5 + _S71;
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
    Vector<uint32_t, 3>  _S72 = noiseBlock(sweep_2, colour_2, block_1, size_6);
    uint32_t _S73 = size_6 - 1U;
    Vector<uint32_t, 3>  _S74 = Vector<uint32_t, 3> (_S73, _S73, 31U);
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
        uint32_t _S75 = _S72.x;
        uint32_t _S76 = _S72.y;
        uint32_t _S77 = stream((_S75 | (_S76 << 11U)) | ((_S72.z) << 22U), sweep_2 * 4096U + attempt_0);
        uint32_t _S78 = hash(_S77);
        Vector<uint32_t, 3>  _S79 = (_S72 + Vector<uint32_t, 3> (_S78 & 7U, (_S78 >> 3U) & 7U, (_S78 >> 6U) & 7U)) & _S74;
        uint32_t _S80 = (_S75 + ((_S78 >> 9U) & 7U)) & _S73;
        uint32_t _S81 = (_S76 + ((_S78 >> 12U) & 7U)) & _S73;
        uint32_t _S82 = _S79.z;
        Vector<uint32_t, 3>  _S83 = Vector<uint32_t, 3> (_S80, _S81, _S82);
        uint32_t _S84 = _S82 * size_6;
        uint32_t _S85 = (_S84 + _S79.y) * size_6 + _S79.x;
        uint32_t _S86 = (_S84 + _S81) * size_6 + _S80;
        uint32_t _S87 = *(&(tensor_4)[_S85]);
        uint32_t _S88 = *(&(tensor_4)[_S86]);
        Vector<uint32_t, 2>  _S89 = noiseEnergy_0(tensor_4, _S79, _S87, _S88, _S83, size_6);
        Vector<uint32_t, 2>  _S90 = noiseEnergy_0(tensor_4, _S83, _S88, _S87, _S79, size_6);
        bool _S91 = _S85 != _S86;
        bool _S92;
        if(_S91)
        {
            _S92 = (_S89.y + _S90.y) < (_S89.x + _S90.x);
        }
        else
        {
            _S92 = false;
        }
        if(_S92)
        {
            *(&(tensor_4)[_S85]) = _S88;
            *(&(tensor_4)[_S86]) = _S87;
        }
        uint32_t attempt_1 = attempt_0 + 1U;
        attempt_0 = attempt_1;
    }
    return;
}

void _noiseSweep(void* _S93, void* entryPointParams_1, void* _S94)
{
    ComputeThreadVaryingInput * _S95 = (slang_bit_cast<ComputeThreadVaryingInput *>(_S93));
    Vector<uint32_t, 3>  _S96 = _S95->groupID * Vector<uint32_t, 3> (64U, 1U, 1U) + _S95->groupThreadID;
    uint32_t _S97 = _S96.x;
    bool _S98 = _S97 < ((slang_bit_cast<EntryPointParams_1*>(entryPointParams_1))->size_1 / 16U * ((slang_bit_cast<EntryPointParams_1*>(entryPointParams_1))->size_1 / 16U) * 2U);
    if(_S98)
    {
        noiseSweepBlock_0((slang_bit_cast<EntryPointParams_1*>(entryPointParams_1))->tensor_1, (slang_bit_cast<EntryPointParams_1*>(entryPointParams_1))->sweep_0, (slang_bit_cast<EntryPointParams_1*>(entryPointParams_1))->colour_0, _S97, (slang_bit_cast<EntryPointParams_1*>(entryPointParams_1))->size_1);
    }
    return;
}

static Random Random_x24init_0(uint32_t state_0, float value_0)
{
    Random _S99;
    (&_S99)->state = state_0;
    (&_S99)->value = value_0;
    return _S99;
}

static float random_0(uint32_t * state_1)
{
    uint32_t _S100 = hash(*state_1);
    *state_1 = _S100;
    return float((*state_1) >> int(8)) * 5.9604644775390625e-08f;
}

SLANG_PRELUDE_EXPORT
Random pcg(uint32_t state_2)
{
    uint32_t _S101 = state_2;
    float value_1 = random_0(&_S101);
    return Random_x24init_0(_S101, value_1);
}

SLANG_PRELUDE_EXPORT
Vector<uint32_t, 2>  noiseOffset(uint32_t k_2)
{
    Vector<uint32_t, 2>  _S102 = Vector<uint32_t, 2> (k_2 * 3242174889U, k_2 * 2447445414U) >> ((Vector<uint32_t, 2> )16U);
    uint32_t _S103 = (fkBlueNoiseSize());
    return (_S102 * (Vector<uint32_t, 2> )_S103) >> ((Vector<uint32_t, 2> )16U);
}

SLANG_PRELUDE_EXPORT
uint32_t noiseOrigin(Vector<uint32_t, 2>  p_0, uint32_t k_3)
{
    uint32_t _S104 = ((p_0.x) >> 11U) | (((p_0.y) >> 11U) << 4U);
    Vector<uint32_t, 2>  _S105 = noiseOffset(8192U + (k_3 >> 10U) + (_S104 << 20U));
    Vector<uint32_t, 2>  _S106 = (p_0 + _S105) & ((Vector<uint32_t, 2> )2047U);
    return ((_S106.x) | ((_S106.y) << 11U)) | ((k_3 & 1023U) << 22U);
}

SLANG_PRELUDE_EXPORT
uint32_t noiseAddress(uint32_t origin_0, uint32_t bounce_0)
{
    Vector<uint32_t, 2>  _S107 = Vector<uint32_t, 2> (origin_0 & 2047U, (origin_0 >> 11U) & 2047U);
    Vector<uint32_t, 2>  _S108 = noiseOffset(64U + bounce_0 * 17U);
    Vector<uint32_t, 2>  _S109 = (_S107 + _S108) & ((Vector<uint32_t, 2> )2047U);
    return ((_S109.x) | ((_S109.y) << 11U)) | ((origin_0 >> 22U) << 22U);
}

SLANG_PRELUDE_EXPORT
Random draw(uint32_t address_0, uint32_t variable_0)
{
    uint32_t _S110 = address_0 >> 22U;
    uint32_t _S111 = _S110 / 32U;
    Vector<uint32_t, 2>  _S112 = Vector<uint32_t, 2> (address_0 & 2047U, (address_0 >> 11U) & 2047U);
    uint32_t _S113 = variable_0 & 2147483647U;
    Vector<uint32_t, 2>  _S114 = noiseOffset(_S113);
    Vector<uint32_t, 2>  _S115 = _S112 + _S114;
    Vector<uint32_t, 2>  _S116 = noiseOffset(4096U + _S111);
    Vector<uint32_t, 2>  _S117 = _S115 + _S116;
    uint32_t _S118 = (fkBlueNoiseSize());
    Vector<uint32_t, 2>  _S119 = _S117 & ((Vector<uint32_t, 2> )(_S118 - 1U));
    uint32_t _S120 = (fkBlueNoise((_S119.x), (_S119.y), ((_S110 + ((_S111 * 2654435769U) >> 27U)) % 32U)));
    bool _S121 = (variable_0 & 2147483648U) != 0U;
    uint32_t _S122 = stream(address_0, _S113);
    Random _S123 = pcg(_S122);
    float _S124;
    if(_S120 == 4294967295U)
    {
        if(_S121)
        {
            Random _S125 = pcg(_S123.state);
            _S124 = _S125.value;
        }
        else
        {
            _S124 = _S123.value;
        }
    }
    else
    {
        uint32_t _S126;
        if(_S121)
        {
            _S126 = _S120 >> 16U;
        }
        else
        {
            _S126 = _S120 & 65535U;
        }
        _S124 = (float(_S126) + 0.5f) / 6.5536e+04f;
    }
    return Random_x24init_0(address_0, _S124);
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
