#include "cpu.h"

bool Cpu::op_anda(uint8_t opcode, op_names op, addr_mode mode)
{
    auto value = read_operand8(mode);
    if (!value)
    {
        return false;
    }

    s_.a = logic8(s_.a & *value);

    return true;
}

bool Cpu::op_andb(uint8_t opcode, op_names op, addr_mode mode)
{
    auto value = read_operand8(mode);
    if (!value)
    {
        return false;
    }

    s_.b = logic8(s_.b & *value);

    return true;
}

// not implemented
bool Cpu::op_bita(uint8_t opcode, op_names op, addr_mode mode)
{
    auto value = read_operand8(mode);
    if (!value)
    {
        return false;
    }

    uint8_t r = s_.a & *value;

    set_flag(Z, r == 0);
    set_flag(N, (r & 0x80) != 0);
    set_flag(V, false);

    return true;
}

// not implemented
bool Cpu::op_bitb(uint8_t opcode, op_names op, addr_mode mode)
{
    auto value = read_operand8(mode);
    if (!value)
    {
        return false;
    }

    uint8_t r = s_.b & *value;

    set_flag(Z, r == 0);
    set_flag(N, (r & 0x80) != 0);
    set_flag(V, false);

    return true;
}

bool Cpu::op_oraa(uint8_t opcode, op_names op, addr_mode mode)
{
    auto value = read_operand8(mode);
    if (!value)
    {
        return false;
    }

    s_.a = logic8(s_.a | *value);

    return true;
}

bool Cpu::op_orab(uint8_t opcode, op_names op, addr_mode mode)
{
    auto value = read_operand8(mode);
    if (!value)
    {
        return false;
    }

    s_.b = logic8(s_.b | *value);

    return true;
}

bool Cpu::op_eora(uint8_t opcode, op_names op, addr_mode mode)
{
    auto value = read_operand8(mode);
    if (!value)
    {
        return false;
    }

    s_.a = logic8(s_.a ^ *value);

    return true;
}

bool Cpu::op_eorb(uint8_t opcode, op_names op, addr_mode mode)
{
    auto value = read_operand8(mode);
    if (!value)
    {
        return false;
    }

    s_.b = logic8(s_.b ^ *value);

    return true;
}

uint8_t Cpu::logic8(uint8_t result)
{
    set_flag(Z, result == 0);
    set_flag(N, (result & 0x80) != 0);
    set_flag(V, false);
    return result;
}