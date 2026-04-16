#include "cpu.h"

bool Cpu::op_clc(uint8_t opcode, op_names op, addr_mode mode)
{
    switch (mode)
    {
    case addr_mode::inh:
        set_flag(C, false);
        return true;
    default:
        return false;
    }
}

bool Cpu::op_cli(uint8_t opcode, op_names op, addr_mode mode)
{
    switch (mode)
    {
    case addr_mode::inh:
        set_flag(I, false);
        return true;
    default:
        return false;
    }
}

bool Cpu::op_nop(uint8_t opcode, op_names op, addr_mode mode)
{
    switch (mode)
    {
    case addr_mode::inh:
        return true;
    default:
        return false;
    }
}

bool Cpu::op_rti(uint8_t opcode, op_names op, addr_mode mode)
{
    switch (mode)
    {
    case addr_mode::inh:
    {
        s_.cc = pop8();
        s_.b = pop8();
        s_.a = pop8();
        s_.x = pop16();
        s_.pc = pop16();
        return true;
    }
    default:
        return false;
    }
}

bool Cpu::op_rts(uint8_t opcode, op_names op, addr_mode mode)
{
    switch (mode)
    {
    case addr_mode::inh:
    {
        s_.pc = pop16();
        return true;
    }
    default:
        return false;
    }
}

bool Cpu::op_sec(uint8_t opcode, op_names op, addr_mode mode)
{
    switch (mode)
    {
    case addr_mode::inh:
        set_flag(C, true);
        return true;
    default:
        return false;
    }
}

// not implemented
bool Cpu::op_sev(uint8_t opcode, op_names op, addr_mode mode)
{
    return false;
}

bool Cpu::op_sei(uint8_t opcode, op_names op, addr_mode mode)
{
    switch (mode)
    {
    case addr_mode::inh:

        set_flag(I, true);
        return true;
    default:
        return false;
    }
}

// not implemented
bool Cpu::op_swi(uint8_t opcode, op_names op, addr_mode mode)
{
    return false;
}

bool Cpu::op_tab(uint8_t opcode, op_names op, addr_mode mode)
{
    switch (mode)
    {
    case addr_mode::inh:
    {
        s_.b = s_.a;

        set_nz8(s_.b);
        set_flag(V, false);
        // C unchanged

        return true;
    }
    default:
        return false;
    }
}

bool Cpu::op_tap(uint8_t opcode, op_names op, addr_mode mode)
{
    switch (mode)
    {
    case addr_mode::inh:
        s_.cc = s_.a;
        return true;
    default:
        return false;
    }
}

bool Cpu::op_tba(uint8_t opcode, op_names op, addr_mode mode)
{
    switch (mode)
    {
    case addr_mode::inh:
    {
        s_.a = s_.b;

        set_nz8(s_.a);
        set_flag(V, false);
        // C unchanged

        return true;
    }
    default:
        return false;
    }
}

bool Cpu::op_tpa(uint8_t opcode, op_names op, addr_mode mode)
{
    switch (mode)
    {
    case addr_mode::inh:
        s_.a = s_.cc;
        set_nz8(s_.a);

        return true;
    default:
        return false;
    }
}

// not implemented
bool Cpu::op_wai(uint8_t opcode, op_names op, addr_mode mode)
{
    return false;
}

// the remaining ops need a real home

// not implemented
bool Cpu::op_com(uint8_t opcode, op_names op, addr_mode mode)
{
    return false;
}
bool Cpu::op_neg(uint8_t opcode, op_names op, addr_mode mode)
{
    return neg_mem(mode);
}

bool Cpu::op_nega(uint8_t opcode, op_names op, addr_mode mode)
{
    return mode == addr_mode::inh ? neg_a() : false;
}

bool Cpu::op_negb(uint8_t opcode, op_names op, addr_mode mode)
{
    return mode == addr_mode::inh ? neg_b() : false;
}

bool Cpu::neg_a()
{
    s_.a = do_neg8(s_.a);
    return true;
}

bool Cpu::neg_b()
{
    s_.b = do_neg8(s_.b);
    return true;
}

bool Cpu::neg_mem(addr_mode mode)
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
    value = do_neg8(value);
    write8(addr, value);
    return true;
}

uint8_t Cpu::do_neg8(uint8_t value)
{
    const uint8_t result = static_cast<uint8_t>(0u - value);

    set_flag(C, value != 0);
    set_flag(V, value == 0x80);
    set_nz8(result);
    // H unaffected

    return result;
}
