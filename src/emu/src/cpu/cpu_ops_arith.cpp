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
    const uint8_t cin = get_flag(C) ? 1 : 0;
    const uint16_t sum = a + b + cin;
    const uint8_t result = sum & 0xff;

    set_flag(C, sum > 0xff);
    set_flag(Z, result == 0);
    set_flag(N, (result & 0x80) != 0);
    set_flag(V, (~(a ^ b) & (a ^ result) & 0x80) != 0);
    set_flag(H, ((a & 0x0f) + (b & 0x0F) + cin) > 0x0f);

    return result;
}

bool Cpu::op_cba(uint8_t opcode, op_names op, addr_mode mode)
{
    sub8(s_.a, s_.b);
    return true;
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
    case addr_mode::idx:
    {
        const uint8_t off = fetch8();
        v = read16(static_cast<uint16_t>(s_.x + off));
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

    // The original 6800 compares high bytes for N/V and the full word for Z.
    // Unlike the 6801/6803, CPX leaves carry unchanged.
    const uint8_t lhs = s_.x >> 8;
    const uint8_t rhs = v >> 8;
    const uint8_t result = static_cast<uint8_t>(lhs - rhs);
    set_flag(N, (result & 0x80) != 0);
    set_flag(V, ((lhs ^ rhs) & (lhs ^ result) & 0x80) != 0);
    set_flag(Z, s_.x == v);
    return true;
}

bool Cpu::op_daa(uint8_t opcode, op_names op, addr_mode mode)
{
    const uint8_t value = s_.a;
    uint8_t correction = 0;
    if ((value & 0x0f) > 9 || get_flag(H))
        correction |= 0x06;
    if (value > 0x99 || get_flag(C))
        correction |= 0x60;

    const uint16_t result = value + correction;
    s_.a = static_cast<uint8_t>(result);
    set_nz8(s_.a);
    set_flag(V, false);
    set_flag(C, get_flag(C) || result > 0xff);
    return true;
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