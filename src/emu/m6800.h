#pragma once

#include <cstdint>
#include <functional>
#include <stdexcept>
#include <string>
#include <map>

#include "m6800_defs.h"

class M6800
{
public:
    enum CC : uint8_t
    {
        C = 0x01, // Carry
        V = 0x02, // Overflow
        Z = 0x04, // Zero
        N = 0x08, // Negative
        I = 0x10, // IRQ mask
        H = 0x20  // Half-carry
    };

    struct State
    {
        uint8_t a = 0;
        uint8_t b = 0;
        uint16_t x = 0;
        uint16_t sp = 0;
        uint16_t pc = 0;
        uint8_t cc = 0;
    };

    M6800()
    {
    }

    void reset();
    void step();

    const State &state() const { return s_; }
    State &state() { return s_; }

private:
    State s_;

    void trace();

    uint8_t fetch8();
    uint16_t fetch16();
    uint8_t read8(uint16_t addr) const;
    uint16_t read16(uint16_t addr) const;
    void write8(uint16_t addr, uint8_t value);
    void write16(uint16_t addr, uint16_t value);
    void push8(uint8_t v);
    void push16(uint16_t v);
    uint8_t pop8();
    uint16_t pop16();

    void set_nz8(uint8_t v);
    void set_nz16(uint16_t v);
    void set_flag(uint8_t flag, bool on);
    bool get_flag(uint8_t flag) const;

    uint8_t add8(uint8_t lhs, uint8_t rhs, bool carry_in = false);
    uint8_t sub8(uint8_t lhs, uint8_t rhs, bool carry_in = false);

    [[noreturn]] void unimplemented(uint8_t opcode) const;

    // operations
    bool op_adda(uint8_t opcode, op_names op, addr_mode mode);
    bool op_anda(uint8_t opcode, op_names op, addr_mode mode);
    bool op_clc(uint8_t opcode, op_names op, addr_mode mode);
    bool op_cli(uint8_t opcode, op_names op, addr_mode mode);
    bool op_clra(uint8_t opcode, op_names op, addr_mode mode);
    bool op_clrb(uint8_t opcode, op_names op, addr_mode mode);
    bool op_clv(uint8_t opcode, op_names op, addr_mode mode);
    bool op_cmpa(uint8_t opcode, op_names op, addr_mode mode);

    bool op_beq(uint8_t opcode, op_names op, addr_mode mode);
    bool op_bne(uint8_t opcode, op_names op, addr_mode mode);
    bool op_bra(uint8_t opcode, op_names op, addr_mode mode);

    bool op_deca(uint8_t opcode, op_names op, addr_mode mode);
    bool op_decb(uint8_t opcode, op_names op, addr_mode mode);
    bool op_dex(uint8_t opcode, op_names op, addr_mode mode);

    bool op_inca(uint8_t opcode, op_names op, addr_mode mode);
    bool op_incb(uint8_t opcode, op_names op, addr_mode mode);
    bool op_inx(uint8_t opcode, op_names op, addr_mode mode);

    bool op_jmp(uint8_t opcode, op_names op, addr_mode mode);
    bool op_jsr(uint8_t opcode, op_names op, addr_mode mode);

    bool op_ldaa(uint8_t opcode, op_names op, addr_mode mode);
    bool op_ldab(uint8_t opcode, op_names op, addr_mode mode);
    bool op_lds(uint8_t opcode, op_names op, addr_mode mode);
    bool op_ldx(uint8_t opcode, op_names op, addr_mode mode);

    bool op_nop(uint8_t opcode, op_names op, addr_mode mode);

    bool op_psha(uint8_t opcode, op_names op, addr_mode mode);
    bool op_pshb(uint8_t opcode, op_names op, addr_mode mode);
    bool op_pula(uint8_t opcode, op_names op, addr_mode mode);
    bool op_pulb(uint8_t opcode, op_names op, addr_mode mode);

    bool op_rts(uint8_t opcode, op_names op, addr_mode mode);
    bool op_rti(uint8_t opcode, op_names op, addr_mode mode);

    bool op_sec(uint8_t opcode, op_names op, addr_mode mode);
    bool op_sei(uint8_t opcode, op_names op, addr_mode mode);
    bool op_staa(uint8_t opcode, op_names op, addr_mode mode);
    bool op_stab(uint8_t opcode, op_names op, addr_mode mode);
    bool op_stx(uint8_t opcode, op_names op, addr_mode mode);
    bool op_swi(uint8_t opcode, op_names op, addr_mode mode);

    bool op_tap(uint8_t opcode, op_names op, addr_mode mode);
    bool op_tpa(uint8_t opcode, op_names op, addr_mode mode);
    bool op_tsta(uint8_t opcode, op_names op, addr_mode mode);
    bool op_tstb(uint8_t opcode, op_names op, addr_mode mode);

    // bool op_aba(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_abx(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_adca(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_adcb(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_adda(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_addb(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_addd(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_aim(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_andb(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_asl(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_asla(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_aslb(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_asld(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_asr(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_asra(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_asrb(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_bcc(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_bcs(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_beq(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_bge(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_bgt(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_bhi(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_bita(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_bitb(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_ble(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_bls(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_blt(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_bmi(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_bne(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_bpl(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_bra(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_brn(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_bsr(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_bvc(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_bvs(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_cba(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_clc(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_cli(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_clr(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_clra(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_clrb(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_clv(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_cmpa(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_cmpb(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_cmpx(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_com(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_coma(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_comb(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_daa(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_dec(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_deca(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_decb(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_des(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_dex(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_eim(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_eora(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_eorb(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_ill(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_inc(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_inca(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_incb(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_ins(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_inx(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_jmp(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_jsr(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_lda(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_ldb(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_ldd(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_lds(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_ldx(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_lsr(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_lsra(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_lsrb(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_lsrd(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_mul(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_neg(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_nega(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_negb(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_nop(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_oim(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_ora(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_orb(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_psha(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_pshb(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_pshx(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_pula(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_pulb(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_pulx(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_rol(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_rola(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_rolb(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_ror(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_rora(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_rorb(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_rti(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_rts(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_sba(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_sbca(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_sbcb(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_sec(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_sev(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_sta(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_stb(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_sei(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_sts(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_stx(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_suba(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_subb(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_subd(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_swi(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_wai(uint8_t opcode, op_names op, addr_mode mode);
    bool op_tab(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_tap(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_tba(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_tim(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_tpa(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_tst(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_tsta(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_tstb(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_tsx(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_txs(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_asx1(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_asx2(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_xgdx(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_addx(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_adcx(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_bitx(uint8_t opcode, op_names op, addr_mode mode);
    // bool op_slp(uint8_t opcode, op_names op, addr_mode mode);
};
