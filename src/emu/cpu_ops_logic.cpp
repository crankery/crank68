#include "cpu.h"

bool Cpu::op_anda(uint8_t opcode, op_names op, addr_mode mode)
{
    uint8_t v;
    uint8_t r;
    switch (mode)
    {
    case addr_mode::imb:
    {
        v = fetch8();
        r = s_.a & v;
        break;
    }
    default:
        return false;
    }

    s_.a = r;
    set_flag(Z, r == 0);
    set_flag(N, (r & 0x80) != 0);
    set_flag(V, (((s_.a ^ v) & (s_.a ^ r)) & 0x80) != 0);

    return true;
}

bool Cpu::op_andb(uint8_t opcode, op_names op, addr_mode mode)
{
    uint8_t r;
    uint8_t v;

    switch (mode)
    {
    case addr_mode::imb:
    {
        v = fetch8();
        r = s_.b & v;
        break;
    }
    default:
        return false;
    }

    s_.b = r;
    set_flag(Z, r == 0);
    set_flag(N, (r & 0x80) != 0);
    set_flag(V, (((s_.b ^ v) & (s_.b ^ r)) & 0x80) != 0);

    return true;
}

// not implemented
bool Cpu::op_bita(uint8_t opcode, op_names op, addr_mode mode)
{
    return false;
}

// not implemented
bool Cpu::op_bitb(uint8_t opcode, op_names op, addr_mode mode)
{
    return false;
}

// not implemented
bool Cpu::op_oraa(uint8_t opcode, op_names op, addr_mode mode)
{
    return false;
}

// not implemented
bool Cpu::op_orab(uint8_t opcode, op_names op, addr_mode mode)
{
    return false;
}

// not implemented
bool Cpu::op_eora(uint8_t opcode, op_names op, addr_mode mode)
{
    return false;
}

// not implemented
bool Cpu::op_eorb(uint8_t opcode, op_names op, addr_mode mode)
{
    return false;
}