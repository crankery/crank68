#include "cpu.h"

bool Cpu::op_adda(uint8_t opcode, op_names op, addr_mode mode)
{
    auto value = read_operand8(mode);
    if (!value)
        return false;

    add8(s_.a, *value, false);
    return true;
}

bool Cpu::op_addb(uint8_t opcode, op_names op, addr_mode mode)
{
    auto value = read_operand8(mode);
    if (!value)
        return false;

    add8(s_.b, *value, false);
    return true;
}

bool Cpu::op_aba(uint8_t opcode, op_names op, addr_mode mode)
{
    s_.a = add8(s_.a, s_.b, false);
    return true;
}

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
bool Cpu::op_asla(uint8_t opcode, op_names op, addr_mode mode)
{
    return mode == addr_mode::inh ? shift_a(ShiftOp::asl) : false;
}

bool Cpu::op_aslb(uint8_t opcode, op_names op, addr_mode mode)
{
    return mode == addr_mode::inh ? shift_b(ShiftOp::asl) : false;
}

bool Cpu::op_asl(uint8_t opcode, op_names op, addr_mode mode)
{
    return shift_mem(mode, ShiftOp::asl);
}

bool Cpu::op_asra(uint8_t opcode, op_names op, addr_mode mode)
{
    return mode == addr_mode::inh ? shift_a(ShiftOp::asr) : false;
}

bool Cpu::op_asrb(uint8_t opcode, op_names op, addr_mode mode)
{
    return mode == addr_mode::inh ? shift_b(ShiftOp::asr) : false;
}

bool Cpu::op_asr(uint8_t opcode, op_names op, addr_mode mode)
{
    return shift_mem(mode, ShiftOp::asr);
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
    uint8_t v;

    switch (mode)
    {
    case addr_mode::imb:
    {
        v = fetch8();
        break;
    }
    case idx:
    {
        uint8_t off = fetch8();
        uint16_t addr = static_cast<uint16_t>(s_.x + off);
        v = read8(addr);
        break;
    }
    case addr_mode::ext:
    {
        uint16_t addr = fetch16();
        v = read8(addr);
        break;
    }
    default:
        return false;
    }

    sub8(s_.a, v);
    return true;
}

bool Cpu::op_cmpb(uint8_t opcode, op_names op, addr_mode mode)
{
    uint8_t v;

    switch (mode)
    {
    case addr_mode::imb:
    {
        v = fetch8();
        break;
    }
    case idx:
    {
        uint8_t off = fetch8();
        uint16_t addr = static_cast<uint16_t>(s_.x + off);
        v = read8(addr);
        break;
    }
    case addr_mode::ext:
    {
        uint16_t addr = fetch16();
        v = read8(addr);
        break;
    }
    default:
        return false;
    }

    sub8(s_.b, v);
    return true;
}

bool Cpu::op_cpx(uint8_t opcode, op_names op, addr_mode mode)
{
    uint16_t v;

    switch (mode)
    {
    case addr_mode::imw:
    {
        v = fetch16();
        break;
    }
    case addr_mode::dir:
    {
        uint8_t zp = fetch8();
        v = read16(zp);
        break;
    }
    case addr_mode::ext:
    {
        uint16_t addr = fetch16();
        v = read16(addr);
        break;
    }
    default:
        return false;
    }

    sub16(s_.x, v);
    return true;
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

bool Cpu::op_jmp(uint8_t opcode, op_names op, addr_mode mode)
{
    switch (mode)
    {
    case addr_mode::idx:
    {
        s_.pc = static_cast<uint16_t>(s_.x + fetch8());
        return true;
    }
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
    return load16(s_.sp, mode);
}

bool Cpu::op_ldx(uint8_t opcode, op_names op, addr_mode mode)
{
    return load16(s_.x, mode);
}

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
    set_flag(N, false);                     // always reset
    set_flag(V, get_flag(N) ^ get_flag(C)); // this boils down to C
    set_flag(Z, s_.a == 0);
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
        return false;
    s_.b = do_rol8(s_.b);
    return true;
}

bool Cpu::op_rora(uint8_t opcode, op_names op, addr_mode mode)
{
    if (mode != addr_mode::inh)
        return false;
    s_.a = do_ror8(s_.a);
    return true;
}

bool Cpu::op_rorb(uint8_t opcode, op_names op, addr_mode mode)
{
    if (mode != addr_mode::inh)
        return false;
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
    case addr_mode::idx:
    {
        uint8_t off = fetch8();
        uint16_t addr = static_cast<uint16_t>(s_.x + off);
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
    case addr_mode::idx:
    {
        uint8_t off = fetch8();
        uint16_t addr = static_cast<uint16_t>(s_.x + off);
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
    return store16(s_.x, mode);
}

bool Cpu::op_sts(uint8_t opcode, op_names op, addr_mode mode)
{
    return store16(s_.sp, mode);
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

bool Cpu::op_suba(uint8_t opcode, op_names op, addr_mode mode)
{
    auto value = read_operand8(mode);
    if (!value)
        return false;

    s_.a = sub8(s_.a, *value, false);
    return true;
}

bool Cpu::op_sba(uint8_t opcode, op_names op, addr_mode mode)
{
    s_.a = sub8(s_.a, s_.b, false);
    return true;
}

bool Cpu::op_subb(uint8_t opcode, op_names op, addr_mode mode)
{
    auto value = read_operand8(mode);
    if (!value)
        return false;

    s_.b = sub8(s_.b, *value, false);
    return true;
}

bool Cpu::op_sbca(uint8_t opcode, op_names op, addr_mode mode)
{
    auto value = read_operand8(mode);
    if (!value)
        return false;

    s_.a = sub8(s_.a, *value, get_flag(C));
    return true;
}

bool Cpu::op_sbcb(uint8_t opcode, op_names op, addr_mode mode)
{
    auto value = read_operand8(mode);
    if (!value)
        return false;

    s_.b = sub8(s_.b, *value, get_flag(C));
    return true;
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