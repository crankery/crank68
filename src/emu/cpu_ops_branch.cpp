#include "cpu.h"

bool Cpu::op_bcc(uint8_t opcode, op_names op, addr_mode mode)
{
    return branch_if(!get_flag(C), mode);
}

bool Cpu::op_bcs(uint8_t opcode, op_names op, addr_mode mode)
{
    return branch_if(get_flag(C), mode);
}

bool Cpu::op_beq(uint8_t opcode, op_names op, addr_mode mode)
{
    return branch_if(get_flag(Z), mode);
}

bool Cpu::op_bne(uint8_t opcode, op_names op, addr_mode mode)
{
    return branch_if(!get_flag(Z), mode);
}

bool Cpu::op_bmi(uint8_t opcode, op_names op, addr_mode mode)
{
    return branch_if(get_flag(N), mode);
}

bool Cpu::op_bpl(uint8_t opcode, op_names op, addr_mode mode)
{
    return branch_if(!get_flag(N), mode);
}

bool Cpu::op_bvc(uint8_t opcode, op_names op, addr_mode mode)
{
    return branch_if(!get_flag(V), mode);
}

bool Cpu::op_bvs(uint8_t opcode, op_names op, addr_mode mode)
{
    return branch_if(get_flag(V), mode);
}

bool Cpu::op_bhi(uint8_t opcode, op_names op, addr_mode mode)
{
    return branch_if(!get_flag(C) && !get_flag(Z), mode);
}

bool Cpu::op_bls(uint8_t opcode, op_names op, addr_mode mode)
{
    return branch_if(get_flag(C) || get_flag(Z), mode);
}

bool Cpu::op_bge(uint8_t opcode, op_names op, addr_mode mode)
{
    return branch_if(get_flag(N) == get_flag(V), mode);
}

bool Cpu::op_blt(uint8_t opcode, op_names op, addr_mode mode)
{
    return branch_if(get_flag(N) != get_flag(V), mode);
}

bool Cpu::op_bgt(uint8_t opcode, op_names op, addr_mode mode)
{
    return branch_if(!get_flag(Z) && (get_flag(N) == get_flag(V)), mode);
}

bool Cpu::op_ble(uint8_t opcode, op_names op, addr_mode mode)
{
    return branch_if(get_flag(Z) || (get_flag(N) != get_flag(V)), mode);
}

bool Cpu::op_bra(uint8_t opcode, op_names op, addr_mode mode)
{
    return branch_if(true, mode);
}

bool Cpu::op_bsr(uint8_t opcode, op_names op, addr_mode mode)
{
    switch (mode)
    {
    case addr_mode::rel:
    {
        int8_t off = static_cast<int8_t>(fetch8());
        push16(s_.pc);
        uint16_t destAddr = static_cast<uint16_t>(s_.pc + off);
        s_.pc = destAddr;

        return true;
    }
    default:
        return false;
    }
}

bool Cpu::op_jmp(uint8_t opcode, op_names op, addr_mode mode)
{
    return do_jump(mode, false);
}

bool Cpu::op_jsr(uint8_t opcode, op_names op, addr_mode mode)
{
    return do_jump(mode, true);
}

bool Cpu::do_jump(addr_mode mode, bool subroutine)
{
    switch (mode)
    {
    case addr_mode::ext:
    {
        uint16_t addr = fetch16();
        if (subroutine)
        {
            push16(s_.pc);
        }

        s_.pc = addr;
        return true;
    }
    case addr_mode::idx:
    {
        uint8_t off = fetch8();
        uint16_t addr = static_cast<uint16_t>(s_.x + off);

        if (subroutine)
        {
            push16(s_.pc);
        }

        s_.pc = addr;
        return true;
    }
    default:
        return false;
    }
}