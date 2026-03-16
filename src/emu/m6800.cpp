#include "m6800.h"
#include <sstream>
#include <iomanip>

static M6800::MethodPtr op_dispatch[] = {};
//     &M6800::op_aba,
//     &M6800::op_abx,
//     &M6800::op_adca,
//     &M6800::op_adcb,
//     &M6800::op_adda,
//     &M6800::op_addb,
//     &M6800::op_addd,
//     &M6800::op_aim,
//     &M6800::op_anda,
//     &M6800::op_andb,
//     &M6800::op_asl,
//     &M6800::op_asla,
//     &M6800::op_aslb,
//     &M6800::op_asld,
//     &M6800::op_asr,
//     &M6800::op_asra,
//     &M6800::op_asrb,
//     &M6800::op_bcc,
//     &M6800::op_bcs,
//     &M6800::op_beq,
//     &M6800::op_bge,
//     &M6800::op_bgt,
//     &M6800::op_bhi,
//     &M6800::op_bita,
//     &M6800::op_bitb,
//     &M6800::op_ble,
//     &M6800::op_bls,
//     &M6800::op_blt,
//     &M6800::op_bmi,
//     &M6800::op_bne,
//     &M6800::op_bpl,
//     &M6800::op_bra,
//     &M6800::op_brn,
//     &M6800::op_bsr,
//     &M6800::op_bvc,
//     &M6800::op_bvs,
//     &M6800::op_cba,
//     &M6800::op_clc,
//     &M6800::op_cli,
//     &M6800::op_clr,
//     &M6800::op_clra,
//     &M6800::op_clrb,
//     &M6800::op_clv,
//     &M6800::op_cmpa,
//     &M6800::op_cmpb,
//     &M6800::op_cmpx,
//     &M6800::op_com,
//     &M6800::op_coma,
//     &M6800::op_comb,
//     &M6800::op_daa,
//     &M6800::op_dec,
//     &M6800::op_deca,
//     &M6800::op_decb,
//     &M6800::op_des,
//     &M6800::op_dex,
//     &M6800::op_eim,
//     &M6800::op_eora,
//     &M6800::op_eorb,
//     &M6800::op_ill,
//     &M6800::op_inc,
//     &M6800::op_inca,
//     &M6800::op_incb,
//     &M6800::op_ins,
//     &M6800::op_inx,
//     &M6800::op_jmp,
//     &M6800::op_jsr,
//     &M6800::op_lda,
//     &M6800::op_ldb,
//     &M6800::op_ldd,
//     &M6800::op_lds,
//     &M6800::op_ldx,
//     &M6800::op_lsr,
//     &M6800::op_lsra,
//     &M6800::op_lsrb,
//     &M6800::op_lsrd,
//     &M6800::op_mul,
//     &M6800::op_neg,
//     &M6800::op_nega,
//     &M6800::op_negb,
//     &M6800::op_nop,
//     &M6800::op_oim,
//     &M6800::op_ora,
//     &M6800::op_orb,
//     &M6800::op_psha,
//     &M6800::op_pshb,
//     &M6800::op_pshx,
//     &M6800::op_pula,
//     &M6800::op_pulb,
//     &M6800::op_pulx,
//     &M6800::op_rol,
//     &M6800::op_rola,
//     &M6800::op_rolb,
//     &M6800::op_ror,
//     &M6800::op_rora,
//     &M6800::op_rorb,
//     &M6800::op_rti,
//     &M6800::op_rts,
//     &M6800::op_sba,
//     &M6800::op_sbca,
//     &M6800::op_sbcb,
//     &M6800::op_sec,
//     &M6800::op_sev,
//     &M6800::op_sta,
//     &M6800::op_stb,
//     &M6800::op_sei,
//     &M6800::op_sts,
//     &M6800::op_stx,
//     &M6800::op_suba,
//     &M6800::op_subb,
//     &M6800::op_subd,
//     &M6800::op_swi,
//     &M6800::op_wai,
//     &M6800::op_tab,
//     &M6800::op_tap,
//     &M6800::op_tba,
//     &M6800::op_tim,
//     &M6800::op_tpa,
//     &M6800::op_tst,
//     &M6800::op_tsta,
//     &M6800::op_tstb,
//     &M6800::op_tsx,
//     &M6800::op_txs,
//     &M6800::op_asx1,
//     &M6800::op_asx2,
//     &M6800::op_xgdx,
//     &M6800::op_addx,
//     &M6800::op_adcx,
//     &M6800::op_bitx,
//     &M6800::op_slp};

void M6800::step()
{
    uint8_t op = fetch8();

    op_names op_name = static_cast<op_names>(op_table[op][0]);
    addr_mode addr_mode = static_cast<M6800::addr_mode>(op_table[op][1]);

    MethodPtr operation = operations[op_name];

    if (operation)
    {
        MethodPtr method = operations[op_name];
        if ((this->*method)(op, op_name, addr_mode))
        {
            return;
        }
    }
    else
    {
        printf("not hit %02x\n", op_name);
    }

    unimplemented(op);
}

uint8_t M6800::read8(uint16_t addr) const
{
    return machine_.read(addr);
}

uint16_t M6800::read16(uint16_t addr) const
{
    uint8_t hi = read8(addr);
    uint8_t lo = read8(static_cast<uint16_t>(addr + 1));
    return static_cast<uint16_t>((hi << 8) | lo);
}

void M6800::write8(uint16_t addr, uint8_t value)
{
    machine_.write(addr, value);
}

void M6800::write16(uint16_t addr, uint16_t value)
{
    write8(addr, static_cast<uint8_t>(value >> 8));
    write8(static_cast<uint16_t>(addr + 1), static_cast<uint8_t>(value & 0xFF));
}

uint8_t M6800::fetch8()
{
    return read8(s_.pc++);
}

uint16_t M6800::fetch16()
{
    uint16_t v = read16(s_.pc);
    s_.pc += 2;
    return v;
}

void M6800::push8(uint8_t v)
{
    write8(s_.sp--, v);
}

void M6800::push16(uint16_t v)
{
    push8(static_cast<uint8_t>(v & 0xFF));
    push8(static_cast<uint8_t>(v >> 8));
}

uint8_t M6800::pop8()
{
    return read8(++s_.sp);
}

uint16_t M6800::pop16()
{
    uint8_t hi = pop8();
    uint8_t lo = pop8();
    return static_cast<uint16_t>((hi << 8) | lo);
}

void M6800::set_flag(uint8_t flag, bool on)
{
    if (on)
        s_.cc |= flag;
    else
        s_.cc &= ~flag;
}

bool M6800::get_flag(uint8_t flag) const
{
    return (s_.cc & flag) != 0;
}

void M6800::set_nz8(uint8_t v)
{
    set_flag(Z, v == 0);
    set_flag(N, (v & 0x80) != 0);
}

void M6800::set_nz16(uint16_t v)
{
    set_flag(Z, v == 0);
    set_flag(N, (v & 0x8000) != 0);
}

uint8_t M6800::add8(uint8_t lhs, uint8_t rhs, bool carry_in)
{
    uint16_t c = carry_in ? 1 : 0;
    uint16_t r = static_cast<uint16_t>(lhs) + rhs + c;
    uint8_t out = static_cast<uint8_t>(r & 0xFF);

    set_flag(C, r > 0xFF);
    set_flag(Z, out == 0);
    set_flag(N, (out & 0x80) != 0);
    set_flag(V, ((~(lhs ^ rhs) & (lhs ^ out)) & 0x80) != 0);
    set_flag(H, ((lhs & 0x0F) + (rhs & 0x0F) + c) > 0x0F);

    return out;
}

uint8_t M6800::sub8(uint8_t lhs, uint8_t rhs, bool carry_in)
{
    uint16_t c = carry_in ? 1 : 0;
    uint16_t r = static_cast<uint16_t>(lhs) - rhs - c;
    uint8_t out = static_cast<uint8_t>(r & 0xFF);

    set_flag(C, r > 0xFF);
    set_flag(Z, out == 0);
    set_flag(N, (out & 0x80) != 0);
    set_flag(V, (((lhs ^ rhs) & (lhs ^ out)) & 0x80) != 0);

    return out;
}

void M6800::reset()
{
    s_.a = 0;
    s_.b = 0;
    s_.x = 0;
    s_.cc = I;
    s_.sp = 0x00FF;
    s_.pc = read16(0xFFFE);
}

[[noreturn]] void M6800::unimplemented(uint8_t opcode) const
{
    std::ostringstream oss;
    oss << "Unimplemented opcode 0x"
        << std::hex << std::uppercase << std::setw(2) << std::setfill('0')
        << static_cast<int>(opcode)
        << " at PC=0x"
        << std::setw(4) << static_cast<int>(s_.pc - 1);
    throw std::runtime_error(oss.str());
}
