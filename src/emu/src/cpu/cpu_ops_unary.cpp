#include "cpu.h"

bool Cpu::op_clr(uint8_t opcode, op_names op, addr_mode mode)
{
    uint16_t addr;

    switch (mode)
    {
    case addr_mode::ext:
        addr = fetch16();
        break;
    case addr_mode::idx:
        addr = static_cast<uint16_t>(s_.x + fetch8());
        break;
    default:
        return false;
    }

    write8(addr, 0);

    set_flag(N, false);
    set_flag(Z, true);
    set_flag(V, false);
    set_flag(C, false);

    return true;
}

bool Cpu::op_clra(uint8_t opcode, op_names op, addr_mode mode)
{
    switch (mode)
    {
    case addr_mode::inh:
        s_.a = 0;
        set_flag(N, false);
        set_flag(Z, true);
        set_flag(V, false);
        set_flag(C, false);
        return true;
    default:
        return false;
    }
}

bool Cpu::op_clrb(uint8_t opcode, op_names op, addr_mode mode)
{

    switch (mode)
    {
    case addr_mode::inh:
    {
        s_.b = 0;
        set_flag(N, false);
        set_flag(Z, true);
        set_flag(V, false);
        set_flag(C, false);
        return true;
    }
    default:
        return false;
    }
}

bool Cpu::op_clv(uint8_t opcode, op_names op, addr_mode mode)
{
    switch (mode)
    {
    case addr_mode::inh:
        set_flag(V, false);
        return true;
    default:
        return false;
    }
}

// not implemented
bool op_com(uint8_t opcode, op_names op, addr_mode mode)
{
    return false;
}

bool Cpu::op_coma(uint8_t opcode, op_names op, addr_mode mode)
{
    s_.a = ~s_.a;

    set_flag(N, (s_.a & 0x80) != 0);
    set_flag(Z, s_.a == 0);
    set_flag(V, false);
    set_flag(C, true);

    return true;
}

bool Cpu::op_comb(uint8_t opcode, op_names op, addr_mode mode)
{
    s_.b = ~s_.b;

    set_flag(N, (s_.b & 0x80) != 0);
    set_flag(Z, s_.b == 0);
    set_flag(V, false);
    set_flag(C, true);

    return true;
}

bool Cpu::op_dec(uint8_t opcode, op_names op, addr_mode mode)
{
    uint16_t addr = 0;

    switch (mode)
    {
    case addr_mode::idx:
    {
        uint8_t off = fetch8();
        addr = static_cast<uint16_t>(s_.x + off);
        break;
    }
    case addr_mode::ext:
    {
        addr = fetch16();
        break;
    }
    default:
        return false;
    }

    uint8_t value = read8(addr);
    uint8_t result = dec8(value);
    write8(addr, result);
    return true;
}

bool Cpu::op_deca(uint8_t opcode, op_names op, addr_mode mode)
{
    if (mode != addr_mode::inh)
        return false;
    s_.a = dec8(s_.a);
    return true;
}

bool Cpu::op_decb(uint8_t opcode, op_names op, addr_mode mode)
{
    if (mode != addr_mode::inh)
        return false;
    s_.b = dec8(s_.b);
    return true;
}

uint8_t Cpu::dec8(uint8_t value)
{
    uint8_t result = static_cast<uint8_t>(value - 1);

    set_flag(Z, result == 0);
    set_flag(N, (result & 0x80) != 0);
    set_flag(V, value == 0x7F);

    // C unchanged
    // H unchanged

    return result;
}

bool Cpu::op_dex(uint8_t opcode, op_names op, addr_mode mode)
{
    switch (mode)
    {
    case addr_mode::inh:
        s_.x--;
        set_flag(Z, s_.x == 0);
        return true;
    default:
        return false;
    }
}

bool Cpu::op_inc(uint8_t opcode, op_names op, addr_mode mode)
{
    uint16_t addr = 0;

    switch (mode)
    {
    case addr_mode::idx:
    {
        uint8_t off = fetch8();
        addr = static_cast<uint16_t>(s_.x + off);
        break;
    }
    case addr_mode::ext:
    {
        addr = fetch16();
        break;
    }
    default:
        return false;
    }

    uint8_t value = read8(addr);
    uint8_t result = inc8(value);
    write8(addr, result);
    return true;
}

bool Cpu::op_inca(uint8_t opcode, op_names op, addr_mode mode)
{
    if (mode != addr_mode::inh)
        return false;
    s_.a = inc8(s_.a);
    return true;
}

bool Cpu::op_incb(uint8_t opcode, op_names op, addr_mode mode)
{
    if (mode != addr_mode::inh)
        return false;
    s_.b = inc8(s_.b);
    return true;
}

uint8_t Cpu::inc8(uint8_t value)
{
    uint8_t result = static_cast<uint8_t>(value + 1);

    set_flag(Z, result == 0);
    set_flag(N, (result & 0x80) != 0);
    set_flag(V, value == 0x7F);

    // C unchanged
    // H unchanged

    return result;
}

bool Cpu::op_inx(uint8_t opcode, op_names op, addr_mode mode)
{
    switch (mode)
    {
    case addr_mode::inh:
        s_.x++;
        break;
    default:
        return false;
    }

    set_flag(Z, s_.x == 0);
    return true;
}

// not implemented
bool op_neg(uint8_t opcode, op_names op, addr_mode mode)
{
    return false;
}

// not implemented
bool op_nega(uint8_t opcode, op_names op, addr_mode mode)
{
    return false;
}

// not implemented
bool op_negb(uint8_t opcode, op_names op, addr_mode mode)
{
    return false;
}

bool Cpu::op_tst(uint8_t opcode, op_names op, addr_mode mode)
{
    uint16_t addr;

    switch (mode)
    {
    case addr_mode::idx:
        addr = static_cast<uint16_t>(s_.x + fetch8());
        break;
    case addr_mode::ext:
        addr = fetch16();
        break;
    default:
        return false;
    }

    uint8_t value = read8(addr);
    do_test(value);

    return true;
}

bool Cpu::op_tsta(uint8_t opcode, op_names op, addr_mode mode)
{
    if (mode == addr_mode::inh)
    {
        do_test(s_.a);
        return true;
    }

    return false;
}

bool Cpu::op_tstb(uint8_t opcode, op_names op, addr_mode mode)
{
    if (mode == addr_mode::inh)
    {
        do_test(s_.a);
        return true;
    }

    return false;
}