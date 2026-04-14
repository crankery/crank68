#include "cpu.h"

bool Cpu::op_aba(uint8_t opcode, op_names op, addr_mode mode)
{
    s_.a = add8(s_.a, s_.b, false);
    return true;
}

bool Cpu::op_adda(uint8_t opcode, op_names op, addr_mode mode)
{
    auto value = read_operand8(mode);
    if (!value)
    {
        return false;
    }

    s_.a = add8(s_.a, *value, false);
    return true;
}

bool Cpu::op_addb(uint8_t opcode, op_names op, addr_mode mode)
{
    auto value = read_operand8(mode);
    if (!value)
    {
        return false;
    }

    s_.b = add8(s_.b, *value, false);
    return true;
}

bool Cpu::op_adca(uint8_t opcode, op_names op, addr_mode mode)
{
    uint8_t value;

    if (!load8(value, mode))
        return false;

    s_.a = adc8(s_.a, value);
    return true;
}

bool Cpu::op_adcb(uint8_t opcode, op_names op, addr_mode mode)
{
    uint8_t value;

    if (!load8(value, mode))
        return false;

    s_.b = adc8(s_.b, value);
    return true;
}

uint8_t Cpu::adc8(uint8_t a, uint8_t b)
{
    uint16_t sum = a + b + (get_flag(C) ? 1 : 0);

    uint8_t result = sum & 0xFF;

    // Carry out
    set_flag(C, sum > 0xFF);

    // Zero
    set_flag(Z, result == 0);

    // Negative
    set_flag(N, (result & 0x80) != 0);

    // Overflow (signed)
    set_flag(V, (~(a ^ b) & (a ^ result) & 0x80) != 0);

    // Half carry (for BCD, still required)
    set_flag(H, ((a & 0x0F) + (b & 0x0F) + (get_flag(C) ? 1 : 0)) > 0x0F);

    return result;
}

bool Cpu::op_cba(uint8_t opcode, op_names op, addr_mode mode)
{
    return false;
}

bool Cpu::op_cmpa(uint8_t opcode, op_names op, addr_mode mode)
{
    uint8_t v;

    switch (mode)
    {
    case addr_mode::dir:
    {
        v = read8(fetch8());
        break;
    }
    case addr_mode::imb:
    {
        v = fetch8();
        break;
    }
    case addr_mode::idx:
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
    case addr_mode::dir:
    {
        v = read8(fetch8());
        break;
    }
    case addr_mode::imb:
    {
        v = fetch8();
        break;
    }
    case addr_mode::idx:
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

bool Cpu::op_daa(uint8_t opcode, op_names op, addr_mode mode)
{
    return false;
}

bool Cpu::op_sba(uint8_t opcode, op_names op, addr_mode mode)
{
    s_.a = sub8(s_.a, s_.b, false);
    return true;
}

bool Cpu::op_suba(uint8_t opcode, op_names op, addr_mode mode)
{
    auto value = read_operand8(mode);
    if (!value)
    {
        return false;
    }

    s_.a = sub8(s_.a, *value, false);
    return true;
}

bool Cpu::op_subb(uint8_t opcode, op_names op, addr_mode mode)
{
    auto value = read_operand8(mode);
    if (!value)
    {
        return false;
    }

    s_.b = sub8(s_.b, *value, false);
    return true;
}

bool Cpu::op_sbca(uint8_t opcode, op_names op, addr_mode mode)
{
    auto value = read_operand8(mode);
    if (!value)
    {
        return false;
    }

    s_.a = sub8(s_.a, *value, get_flag(C));
    return true;
}

bool Cpu::op_sbcb(uint8_t opcode, op_names op, addr_mode mode)
{
    auto value = read_operand8(mode);
    if (!value)
    {
        return false;
    }

    s_.b = sub8(s_.b, *value, get_flag(C));
    return true;
}