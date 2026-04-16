#include "cpu.h"

// not implemented
bool Cpu::op_des(uint8_t opcode, op_names op, addr_mode mode)
{
    return false;
}

bool Cpu::op_ins(uint8_t opcode, op_names op, addr_mode mode)
{
    if (mode == addr_mode::inh)
    {
        s_.sp = static_cast<uint16_t>(s_.sp + 1);

        return true;
    }

    return false;
}

bool Cpu::op_psha(uint8_t opcode, op_names op, addr_mode mode)
{
    switch (mode)
    {
    case addr_mode::inh:
    {
        push8(s_.a);
        return true;
    }
    default:
        return false;
    }
}

bool Cpu::op_pshb(uint8_t opcode, op_names op, addr_mode mode)
{
    switch (mode)
    {
    case addr_mode::inh:
    {
        push8(s_.b);
        return true;
    }
    default:
        return false;
    }
}

bool Cpu::op_pula(uint8_t opcode, op_names op, addr_mode mode)
{
    switch (mode)
    {
    case addr_mode::inh:
    {
        uint8_t a = pop8();
        s_.a = a;
        set_nz8(s_.a);
        set_flag(V, false);
        return true;
    }
    default:
        return false;
    }
}

bool Cpu::op_pulb(uint8_t opcode, op_names op, addr_mode mode)
{
    switch (mode)
    {
    case addr_mode::inh:
    {
        uint8_t b = pop8();
        s_.b = b;
        set_nz8(s_.b);
        set_flag(V, false);
        return true;
    }
    default:
        return false;
    }
}

bool Cpu::op_tsx(uint8_t opcode, op_names op, addr_mode mode)
{
    switch (mode)
    {
    case addr_mode::inh:
        s_.x = s_.sp;
        return true;
    default:
        return false;
    }
}

bool Cpu::op_txs(uint8_t opcode, op_names op, addr_mode mode)
{
    switch (mode)
    {
    case addr_mode::inh:
        s_.sp = s_.x;
        return true;
    default:
        return false;
    }
}
