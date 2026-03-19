#include "m6800.h"

bool M6800::op_anda(uint8_t opcode, op_names op, addr_mode mode)
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

bool M6800::op_nop(uint8_t opcode, op_names op, addr_mode mode)
{
    switch (mode)
    {
    case addr_mode::inh:
        return true;
    default:
        return false;
    }
}

bool M6800::op_inx(uint8_t opcode, op_names op, addr_mode mode)
{
    switch (mode)
    {
    case addr_mode::inh:
        s_.x++;
        set_flag(Z, s_.x == 0);
        return true;
    default:
        return false;
    }
}

bool M6800::op_dex(uint8_t opcode, op_names op, addr_mode mode)
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

bool M6800::op_clc(uint8_t opcode, op_names op, addr_mode mode)
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

bool M6800::op_clra(uint8_t opcode, op_names op, addr_mode mode)
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

bool M6800::op_clv(uint8_t opcode, op_names op, addr_mode mode)
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

bool M6800::op_sec(uint8_t opcode, op_names op, addr_mode mode)
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

bool M6800::op_cli(uint8_t opcode, op_names op, addr_mode mode)
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

bool M6800::op_sei(uint8_t opcode, op_names op, addr_mode mode)
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

bool M6800::op_adda(uint8_t opcode, op_names op, addr_mode mode)
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

bool M6800::op_beq(uint8_t opcode, op_names op, addr_mode mode)
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

bool M6800::op_bne(uint8_t opcode, op_names op, addr_mode mode)
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

bool M6800::op_bra(uint8_t opcode, op_names op, addr_mode mode)
{
    switch (mode)
    {
    case addr_mode::rel:
    {
        int8_t off = static_cast<int8_t>(fetch8());
        s_.pc = static_cast<uint16_t>(s_.pc + off);

        return true;
    }
    default:
        return false;
    }
}

bool M6800::op_clrb(uint8_t opcode, op_names op, addr_mode mode)
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

bool M6800::op_cmpa(uint8_t opcode, op_names op, addr_mode mode)
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

bool M6800::op_deca(uint8_t opcode, op_names op, addr_mode mode)
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

bool M6800::op_decb(uint8_t opcode, op_names op, addr_mode mode)
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

bool M6800::op_incb(uint8_t opcode, op_names op, addr_mode mode)
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

bool M6800::op_jmp(uint8_t opcode, op_names op, addr_mode mode)
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

bool M6800::op_jsr(uint8_t opcode, op_names op, addr_mode mode)
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

bool M6800::op_ldaa(uint8_t opcode, op_names op, addr_mode mode)
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

bool M6800::op_ldab(uint8_t opcode, op_names op, addr_mode mode)
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

bool M6800::op_lds(uint8_t opcode, op_names op, addr_mode mode)
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

bool M6800::op_ldx(uint8_t opcode, op_names op, addr_mode mode)
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

bool M6800::op_psha(uint8_t opcode, op_names op, addr_mode mode)
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

bool M6800::op_pshb(uint8_t opcode, op_names op, addr_mode mode)
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

bool M6800::op_pula(uint8_t opcode, op_names op, addr_mode mode)
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

bool M6800::op_pulb(uint8_t opcode, op_names op, addr_mode mode)
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

bool M6800::op_rts(uint8_t opcode, op_names op, addr_mode mode)
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

bool M6800::op_rti(uint8_t opcode, op_names op, addr_mode mode)
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

bool M6800::op_staa(uint8_t opcode, op_names op, addr_mode mode)
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

bool M6800::op_stab(uint8_t opcode, op_names op, addr_mode mode)
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

bool M6800::op_stx(uint8_t opcode, op_names op, addr_mode mode)
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

bool M6800::op_swi(uint8_t opcode, op_names op, addr_mode mode)
{
    switch (mode)
    {
    default:
        return false;
    }
}

bool M6800::op_tap(uint8_t opcode, op_names op, addr_mode mode)
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

bool M6800::op_tsta(uint8_t opcode, op_names op, addr_mode mode)
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

bool M6800::op_tstb(uint8_t opcode, op_names op, addr_mode mode)
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

bool M6800::op_tpa(uint8_t opcode, op_names op, addr_mode mode)
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

// bool M6800::op_tab(uint8_t opcode, op_names op, addr_mode mode)
// {
// }

/*
bool M6800::op_aba(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_abx(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_adca(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_adcb(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_adda(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_addb(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_addd(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_aim(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_andb(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_asl(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_asla(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_aslb(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_asld(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_asr(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_asra(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_asrb(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_bcc(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_bcs(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_bge(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_bgt(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_bhi(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_bita(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_bitb(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_ble(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_bls(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_blt(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_bmi(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_bpl(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_bra(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_brn(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_bsr(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_bvc(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_bvs(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_cba(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_clc(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_cli(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_clr(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_clra(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_clrb(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_clv(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_cmpb(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_cmpx(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_com(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_coma(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_comb(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_daa(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_dec(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_deca(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_decb(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_des(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_dex(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_eim(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_eora(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_eorb(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_ill(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_inc(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_inca(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_incb(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_ins(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_inx(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_jmp(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_lda(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_ldb(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_ldd(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_lds(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_ldx(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_lsr(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_lsra(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_lsrb(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_lsrd(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_mul(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_neg(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_nega(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_negb(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_nop(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_oim(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_ora(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_orb(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_psha(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_pshb(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_pshx(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_pula(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_pulb(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_pulx(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_rol(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_rola(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_rolb(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_ror(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_rora(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_rorb(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_rti(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_rts(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_sba(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_sbca(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_sbcb(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_sec(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_sev(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_sta(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_stb(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_sei(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_sts(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_stx(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_suba(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_subb(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_subd(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_swi(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_wai(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_tab(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_tap(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_tba(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_tim(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_tpa(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_tst(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_tsta(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_tstb(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_tsx(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_txs(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_asx1(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_asx2(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_xgdx(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_addx(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_adcx(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_bitx(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}

bool M6800::op_slp(uint8_t opcode, op_names op, addr_mode mode)
{
       return false;
}
*/