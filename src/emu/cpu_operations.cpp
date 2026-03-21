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

    set_flag(Z, r == 0);
    set_flag(N, (r & 0x80) != 0);
    set_flag(V, (((s_.a ^ v) & (s_.a ^ r)) & 0x80) != 0);

    return true;
}

bool Cpu::op_andb(uint8_t opcode, op_names op, addr_mode mode)
{
    uint8_t v;
    uint8_t r;
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

    set_flag(Z, r == 0);
    set_flag(N, (r & 0x80) != 0);
    set_flag(V, (((s_.b ^ v) & (s_.b ^ r)) & 0x80) != 0);

    return true;
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

bool Cpu::op_adda(uint8_t opcode, op_names op, addr_mode mode)
{
    switch (mode)
    {
    case addr_mode::imb:
    {
        uint8_t v = fetch8();
        s_.a = add8(s_.a, v);
        return true;
    }
    default:
        return false;
    }
}

bool Cpu::op_beq(uint8_t opcode, op_names op, addr_mode mode)
{
    switch (mode)
    {
    case addr_mode::rel:
    {
        int8_t off = static_cast<int8_t>(fetch8());
        if (get_flag(Z))
            s_.pc = static_cast<uint16_t>(s_.pc + off);
        return true;
    }
    default:
        return false;
    }
}

bool Cpu::op_bne(uint8_t opcode, op_names op, addr_mode mode)
{
    switch (mode)
    {
    case addr_mode::rel:
    {
        int8_t off = static_cast<int8_t>(fetch8());
        if (!get_flag(Z))
        {
            s_.pc = static_cast<uint16_t>(s_.pc + off);
        }

        return true;
    }
    default:
        return false;
    }
}

bool Cpu::op_bra(uint8_t opcode, op_names op, addr_mode mode)
{
    switch (mode)
    {
    case addr_mode::rel:
    {
        uint16_t instAddr = s_.pc - 1;
        int8_t off = static_cast<int8_t>(fetch8());
        uint16_t destAddr = static_cast<uint16_t>(s_.pc + off);
        s_.pc = destAddr;

        if (instAddr == destAddr)
        {
            infiniteloop();
        }

        return true;
    }
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

bool Cpu::op_cmpa(uint8_t opcode, op_names op, addr_mode mode)
{
    uint8_t r;
    uint8_t v;

    switch (mode)
    {
    case addr_mode::imb:
    {
        v = fetch8();
        r = sub8(s_.a, v);
        break;
    }
    default:
        return false;
    }

    set_flag(Z, r == 0);
    set_flag(N, (r & 0x80) != 0);
    set_flag(V, (((s_.a ^ v) & (s_.a ^ r)) & 0x80) != 0);
    return true;
}

bool Cpu::op_cmpb(uint8_t opcode, op_names op, addr_mode mode)
{
    uint8_t r;
    uint8_t v;

    switch (mode)
    {
    case addr_mode::imb:
    {
        v = fetch8();
        r = sub8(s_.b, v);
        break;
    }
    case idx:
    {
        uint8_t off = fetch8();
        uint16_t addr = static_cast<uint16_t>(s_.x + off);
        v = read8(addr);
        r = sub8(s_.b, v);
        break;
    }
    default:
        return false;
    }

    set_flag(Z, r == 0);
    set_flag(N, (r & 0x80) != 0);
    set_flag(V, (((s_.b ^ v) & (s_.b ^ r)) & 0x80) != 0);
    return true;
}

bool Cpu::op_deca(uint8_t opcode, op_names op, addr_mode mode)
{
    switch (mode)
    {
    case addr_mode::inh:
    {
        s_.a = sub8(s_.a, 1);
        return true;
    }
    default:
        return false;
    }
}

bool Cpu::op_decb(uint8_t opcode, op_names op, addr_mode mode)
{
    switch (mode)
    {
    case addr_mode::inh:
    {
        s_.b = sub8(s_.b, 1);
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
        s_.a = add8(s_.a, 1);
        return true;
    }
    default:
        return false;
    }
}

bool Cpu::op_jmp(uint8_t opcode, op_names op, addr_mode mode)
{
    switch (mode)
    {
    case addr_mode::ext:
    {
        s_.pc = fetch16();
        return true;
    }
    default:
        return false;
    }
}

bool Cpu::op_jsr(uint8_t opcode, op_names op, addr_mode mode)
{
    switch (mode)
    {
    case addr_mode::ext:
    {
        uint16_t addr = fetch16();
        push16(s_.pc);
        s_.pc = addr;
        return true;
    }
    case addr_mode::dir:
    {
        uint8_t zp = fetch8();
        push16(s_.pc);
        s_.pc = zp;
        return true;
    }
    default:
        return false;
    }
}

bool Cpu::op_ldaa(uint8_t opcode, op_names op, addr_mode mode)
{
    switch (mode)
    {
    case addr_mode::imb:
    {
        s_.a = fetch8();
        break;
    }
    case addr_mode::dir:
    {
        uint8_t zp = fetch8();
        s_.a = read8(zp);
        break;
    }
    case addr_mode::ext:
    {
        uint16_t addr = fetch16();
        s_.a = read8(addr);
        break;
    }
    case addr_mode::idx:
    {
        uint8_t off = fetch8();
        uint16_t addr = static_cast<uint16_t>(s_.x + off);
        s_.a = read8(addr);
        break;
    }
    default:
        return false;
    }

    set_nz8(s_.a);
    set_flag(V, false);
    return true;
}

bool Cpu::op_ldab(uint8_t opcode, op_names op, addr_mode mode)
{
    switch (mode)
    {
    case addr_mode::imb:
    {
        s_.b = fetch8();
        break;
    }
    case addr_mode::dir:
    {
        uint8_t zp = fetch8();
        s_.b = read8(zp);
        break;
    }
    case addr_mode::ext:
    {
        uint16_t addr = fetch16();
        s_.b = read8(addr);
        break;
    }
    default:
        return false;
    }

    set_nz8(s_.b);
    set_flag(V, false);
    return true;
}

bool Cpu::op_lds(uint8_t opcode, op_names op, addr_mode mode)
{
    switch (mode)
    {
    case addr_mode::imw:
    {
        s_.sp = fetch16();
        set_nz16(s_.sp);
        set_flag(V, false);
        return true;
    }
    default:
        return false;
    }
}

bool Cpu::op_ldx(uint8_t opcode, op_names op, addr_mode mode)
{
    switch (mode)
    {
    case addr_mode::imw:
    {
        s_.x = fetch16();
        break;
    }
    case addr_mode::dir:
    {
        uint8_t zp = fetch8();
        s_.x = read16(zp);
        break;
    }
    case addr_mode::ext:
    {
        uint16_t addr = fetch16();
        s_.x = read16(addr);
        break;
    }
    default:
        return false;
    }

    set_nz16(s_.x);
    set_flag(V, false);

    return true;
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

bool Cpu::op_staa(uint8_t opcode, op_names op, addr_mode mode)
{
    switch (mode)
    {
    case addr_mode::dir:
    {
        uint8_t zp = fetch8();
        write8(zp, s_.a);
    }
    break;
    case addr_mode::ext:
    {
        uint16_t addr = fetch16();
        write8(addr, s_.a);
        break;
    }
    default:
        return false;
    }

    set_nz8(s_.a);
    set_flag(V, false);

    return true;
}

bool Cpu::op_stab(uint8_t opcode, op_names op, addr_mode mode)
{
    switch (mode)
    {
    case addr_mode::dir:
    {
        uint8_t zp = fetch8();
        write8(zp, s_.b);
    }
    break;
    case addr_mode::ext:
    {
        uint16_t addr = fetch16();
        write8(addr, s_.b);
        break;
    }
    default:
        return false;
    }

    set_nz8(s_.b);
    set_flag(V, false);

    return true;
}

bool Cpu::op_stx(uint8_t opcode, op_names op, addr_mode mode)
{
    switch (mode)
    {
    case addr_mode::idx:
    {
        uint8_t off = fetch8();
        uint16_t addr = static_cast<uint16_t>(s_.x + off);
        write8(addr, s_.x & 0xFF);
        write8(static_cast<uint16_t>(addr + 1), s_.x >> 8);
        break;
    }
    case addr_mode::dir:
    {
        uint8_t zp = fetch8();
        write8(static_cast<uint8_t>(zp), (uint8_t)(s_.x >> 8));
        write8(static_cast<uint8_t>(zp + 1), (uint8_t)s_.x & 0xff);
        break;
    }
    default:
        return false;
    }

    set_nz16(s_.x);
    set_flag(V, false);

    return true;
}

bool Cpu::op_swi(uint8_t opcode, op_names op, addr_mode mode)
{
    switch (mode)
    {
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

bool Cpu::op_tsta(uint8_t opcode, op_names op, addr_mode mode)
{
    switch (mode)
    {
    case addr_mode::inh:
    {
        set_nz8(s_.a);
        set_flag(V, false);
        return true;
    }
    default:
        return false;
    }
}

bool Cpu::op_tstb(uint8_t opcode, op_names op, addr_mode mode)
{
    switch (mode)
    {
    case addr_mode::inh:
    {
        set_nz8(s_.b);
        set_flag(V, false);
        break;
    }
    case addr_mode::imb:
    {
        uint8_t zp = fetch8();
        write8(zp, s_.b);
        break;
    }
    case addr_mode::imw:
    {
        uint16_t addr = fetch16();
        write8(addr, s_.b);
        break;
    }
    default:
        return false;
    }

    set_nz8(s_.b);
    set_flag(V, false);
    return true;
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
