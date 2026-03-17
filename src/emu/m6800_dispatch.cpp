#include "m6800.h"

void M6800::step()
{
    M6800::trace();

    // uint16_t pc = s_.pc;
    uint8_t op = fetch8();

    OpInfo op_info = m6800_op_table[op];

    bool result = false;
    switch (op_info.op_name)
    {
    case op_names::anda:
        result = op_anda(op, op_info.op_name, op_info.addr_mode);
        break;
    case op_names::beq:
        result = op_beq(op, op_info.op_name, op_info.addr_mode);
        break;
    case op_names::bne:
        result = op_bne(op, op_info.op_name, op_info.addr_mode);
        break;
    case op_names::cli:
        result = op_cli(op, op_info.op_name, op_info.addr_mode);
        break;
    case op_names::cmpa:
        result = op_cmpa(op, op_info.op_name, op_info.addr_mode);
        break;
    case op_names::clra:
        result = op_clra(op, op_info.op_name, op_info.addr_mode);
        break;
    case op_names::inx:
        result = op_inx(op, op_info.op_name, op_info.addr_mode);
        break;
    case op_names::ldaa:
        result = op_ldaa(op, op_info.op_name, op_info.addr_mode);
        break;
    case op_names::ldab:
        result = op_ldab(op, op_info.op_name, op_info.addr_mode);
        break;
    case op_names::lds:
        result = op_lds(op, op_info.op_name, op_info.addr_mode);
        break;
    case op_names::ldx:
        result = op_ldx(op, op_info.op_name, op_info.addr_mode);
        break;
    case op_names::jsr:
        result = op_jsr(op, op_info.op_name, op_info.addr_mode);
        break;
    case op_names::nop:
        result = op_nop(op, op_info.op_name, op_info.addr_mode);
        break;
    case op_names::psha:
        result = op_psha(op, op_info.op_name, op_info.addr_mode);
        break;
    case op_names::pshb:
        result = op_pshb(op, op_info.op_name, op_info.addr_mode);
        break;
    case op_names::pula:
        result = op_pula(op, op_info.op_name, op_info.addr_mode);
        break;
    case op_names::pulb:
        result = op_pulb(op, op_info.op_name, op_info.addr_mode);
        break;
    case op_names::rts:
        result = op_rts(op, op_info.op_name, op_info.addr_mode);
        break;
    case op_names::sei:
        result = op_sei(op, op_info.op_name, op_info.addr_mode);
        break;
    case op_names::staa:
        result = op_staa(op, op_info.op_name, op_info.addr_mode);
        break;
    case op_names::stab:
        result = op_stab(op, op_info.op_name, op_info.addr_mode);
        break;
    case op_names::stx:
        result = op_stx(op, op_info.op_name, op_info.addr_mode);
        break;
    case op_names::tap:
        result = op_tap(op, op_info.op_name, op_info.addr_mode);
        break;
    case op_names::tpa:
        result = op_tpa(op, op_info.op_name, op_info.addr_mode);
        break;
    default:
        result = false;
    }

    if (!result)
    {
        unimplemented(op);
    }
}