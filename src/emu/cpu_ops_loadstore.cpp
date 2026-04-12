#include "cpu.h"

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

bool Cpu::store16(uint16_t value, addr_mode mode)
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
        addr = fetch16();
        break;

    default:
        return false;
    }

    write16(addr, value);

    set_nz16(value);
    set_flag(V, false);
    return true;
}
