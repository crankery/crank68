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
    switch (mode)
    {
    case addr_mode::ext:
    {
        uint16_t addr = fetch16();
        uint8_t o = read8(addr);
        uint8_t r = sub8(o, 1);
        // printf("dec %04d: v=%02d r=%02d\r\n", addr, o, r);
        write8(addr, r);
        break;
    }
    default:
        return false;
    }

    return true;
}

bool Cpu::op_deca(uint8_t opcode, op_names op, addr_mode mode)
{
    switch (mode)
    {
    case addr_mode::inh:
    {
        s_.a = sub8(s_.a, 1);
        break;
    }
    default:
        return false;
    }

    return true;
}

bool Cpu::op_decb(uint8_t opcode, op_names op, addr_mode mode)
{
    switch (mode)
    {
    case addr_mode::inh:
    {
        s_.b = sub8(s_.b, 1);
        break;
    }
    default:
        return false;
    }
    return true;
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
    switch (mode)
    {
    case addr_mode::ext:
    {
        uint16_t addr = fetch16();
        uint8_t o = read8(addr);
        uint8_t r = add8(o, 1);
        write8(addr, r);
        break;
    }
    default:
        return false;
    }

    return true;
}

bool Cpu::op_inca(uint8_t opcode, op_names op, addr_mode mode)
{
    switch (mode)
    {
    case addr_mode::inh:
    {
        s_.a = add8(s_.a, 1);
        return true;
    }
    default:
        return false;
    }
}

bool Cpu::op_incb(uint8_t opcode, op_names op, addr_mode mode)
{
    switch (mode)
    {
    case addr_mode::inh:
    {
        s_.b = add8(s_.b, 1);
        return true;
    }
    default:
        return false;
    }
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