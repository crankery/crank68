#pragma once

#include <cstdint>
#include <fstream>
#include <iomanip>
#include <iostream>

class Dasm
{
public:
    enum addr_mode
    {
        inh, /* inherent */
        rel, /* relative */
        imb, /* immediate (byte) */
        imw, /* immediate (word) */
        dir, /* direct address */
        imd, /* HD63701YO: immediate, direct address */
        ext, /* extended address */
        idx, /* x + byte offset */
        imx, /* HD63701YO: immediate, x + byte offset */
        sx1  /* HD63701YO: undocumented opcodes: byte from (s+1) */
    };

    enum op_names
    {
        aba = 0,
        abx,
        adca,
        adcb,
        adda,
        addb,
        addd,
        aim,
        anda,
        andb,
        asl,
        asla,
        aslb,
        asld,
        asr,
        asra,
        asrb,
        bcc,
        bcs,
        beq,
        bge,
        bgt,
        bhi,
        bita,
        bitb,
        ble,
        bls,
        blt,
        bmi,
        bne,
        bpl,
        bra,
        brn,
        bsr,
        bvc,
        bvs,
        cba,
        clc,
        cli,
        clr,
        clra,
        clrb,
        clv,
        cmpa,
        cmpb,
        cmpx,
        com,
        coma,
        comb,
        daa,
        dec,
        deca,
        decb,
        des,
        dex,
        eim,
        eora,
        eorb,
        ill,
        inc,
        inca,
        incb,
        ins,
        inx,
        jmp,
        jsr,
        lda,
        ldb,
        ldd,
        lds,
        ldx,
        lsr,
        lsra,
        lsrb,
        lsrd,
        mul,
        neg,
        nega,
        negb,
        nop,
        oim,
        ora,
        orb,
        psha,
        pshb,
        pshx,
        pula,
        pulb,
        pulx,
        rol,
        rola,
        rolb,
        ror,
        rora,
        rorb,
        rti,
        rts,
        sba,
        sbca,
        sbcb,
        sec,
        sev,
        sta,
        stb,
        _std,
        sei,
        sts,
        stx,
        suba,
        subb,
        subd,
        swi,
        wai,
        tab,
        tap,
        tba,
        tim,
        tpa,
        tst,
        tsta,
        tstb,
        tsx,
        txs,
        asx1,
        asx2,
        xgdx,
        addx,
        adcx,
        bitx,
        slp
    };

    static const char *const op_name_str[];
    static const uint8_t table[0x104][3];

    static void disassemble(char *result, size_t result_size, uint16_t pc, uint8_t code, uint8_t b0, uint8_t b1);
};
