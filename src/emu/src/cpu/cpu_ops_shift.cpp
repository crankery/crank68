#include "cpu.h"

bool Cpu::op_asl(uint8_t opcode, op_names op, addr_mode mode)
{
    return shift_mem(mode, ShiftOp::asl);
}

bool Cpu::op_asla(uint8_t opcode, op_names op, addr_mode mode)
{
    return mode == addr_mode::inh ? shift_a(ShiftOp::asl) : false;
}

bool Cpu::op_aslb(uint8_t opcode, op_names op, addr_mode mode)
{
    return mode == addr_mode::inh ? shift_b(ShiftOp::asl) : false;
}

bool Cpu::op_asr(uint8_t opcode, op_names op, addr_mode mode)
{
    return shift_mem(mode, ShiftOp::asr);
}

bool Cpu::op_asra(uint8_t opcode, op_names op, addr_mode mode)
{
    return mode == addr_mode::inh ? shift_a(ShiftOp::asr) : false;
}

bool Cpu::op_asrb(uint8_t opcode, op_names op, addr_mode mode)
{
    return mode == addr_mode::inh ? shift_b(ShiftOp::asr) : false;
}

// not implemented
bool Cpu::op_lsr(uint8_t opcode, op_names op, addr_mode mode)
{
    return false;
}

// combine with lsrb
bool Cpu::op_lsra(uint8_t opcode, op_names op, addr_mode mode)
{
    bool lsb;
    switch (mode)
    {
    case addr_mode::inh:
    {
        lsb = (s_.a & 1) == 1;
        s_.a >>= 1;

        break;
    }
    default:
        return false;
    }

    set_flag(C, lsb);
    set_flag(N, false); // always reset
    set_flag(V, get_flag(C));
    set_flag(Z, s_.a == 0);
    return true;
}

bool Cpu::op_lsrb(uint8_t opcode, op_names op, addr_mode mode)
{
    bool lsb;
    switch (mode)
    {
    case addr_mode::inh:
    {
        lsb = (s_.b & 1) == 1;
        s_.b >>= 1;

        break;
    }
    default:
        return false;
    }

    set_flag(C, lsb);
    set_flag(N, false); // always reset
    set_flag(V, get_flag(C));
    set_flag(Z, s_.b == 0);
    return true;
}

bool Cpu::op_rola(uint8_t opcode, op_names op, addr_mode mode)
{
    if (mode != addr_mode::inh)
        return false;
    s_.a = do_rol8(s_.a);
    return true;
}

bool Cpu::op_rolb(uint8_t opcode, op_names op, addr_mode mode)
{
    if (mode != addr_mode::inh)
    {
        return false;
    }

    s_.b = do_rol8(s_.b);
    return true;
}

bool Cpu::op_rora(uint8_t opcode, op_names op, addr_mode mode)
{
    if (mode != addr_mode::inh)
    {
        return false;
    }

    s_.a = do_ror8(s_.a);
    return true;
}

bool Cpu::op_rorb(uint8_t opcode, op_names op, addr_mode mode)
{
    if (mode != addr_mode::inh)
    {
        return false;
    }

    s_.b = do_ror8(s_.b);
    return true;
}

bool Cpu::op_rol(uint8_t opcode, op_names op, addr_mode mode)
{
    uint16_t addr;

    switch (mode)
    {
    case addr_mode::idx:
    {
        uint8_t off = fetch8();
        addr = s_.x + off;
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

    uint8_t val = read8(addr);
    val = do_rol8(val);
    write8(addr, val);
    return true;
}

bool Cpu::op_ror(uint8_t opcode, op_names op, addr_mode mode)
{
    uint16_t addr;

    switch (mode)
    {
    case addr_mode::idx:
    {
        uint8_t off = fetch8();
        addr = s_.x + off;
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

    uint8_t val = read8(addr);
    val = do_ror8(val);
    write8(addr, val);
    return true;
}
