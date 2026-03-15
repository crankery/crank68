#include "m6800.h"
#include <sstream>
#include <iomanip>

M6800::M6800(ReadFn read_fn, WriteFn write_fn)
    : read_(std::move(read_fn)), write_(std::move(write_fn)) {}

uint8_t M6800::read8(uint16_t addr) const
{
    return read_(addr);
}

uint16_t M6800::read16(uint16_t addr) const
{
    uint8_t hi = read8(addr);
    uint8_t lo = read8(static_cast<uint16_t>(addr + 1));
    return static_cast<uint16_t>((hi << 8) | lo);
}

void M6800::write8(uint16_t addr, uint8_t value)
{
    write_(addr, value);
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

void M6800::step()
{
    uint8_t op = fetch8();

    switch (op)
    {
    case 0x01: // NOP
        break;

    case 0x06: // TAP
        s_.cc = s_.a;
        break;

    case 0x07: // TPA
        s_.a = s_.cc;
        set_nz8(s_.a);
        break;

    case 0x08: // INX
        s_.x++;
        set_flag(Z, s_.x == 0);
        break;

    case 0x09: // DEX
        s_.x--;
        set_flag(Z, s_.x == 0);
        break;

    case 0x0A: // CLV
        set_flag(V, false);
        break;

    case 0x0C: // CLC
        set_flag(C, false);
        break;

    case 0x0D: // SEC
        set_flag(C, true);
        break;

    case 0x0E: // CLI
        set_flag(I, false);
        break;

    case 0x0F: // SEI
        set_flag(I, true);
        break;

    case 0x20:
    { // BRA rel8
        int8_t off = static_cast<int8_t>(fetch8());
        s_.pc = static_cast<uint16_t>(s_.pc + off);
        break;
    }

    case 0x26:
    { // BNE rel8
        int8_t off = static_cast<int8_t>(fetch8());
        if (!get_flag(Z))
            s_.pc = static_cast<uint16_t>(s_.pc + off);
        break;
    }

    case 0x27:
    { // BEQ rel8
        int8_t off = static_cast<int8_t>(fetch8());
        if (get_flag(Z))
            s_.pc = static_cast<uint16_t>(s_.pc + off);
        break;
    }

    case 0x39: // RTS
        s_.pc = pop16();
        break;

    case 0x3B: // RTI
        s_.cc = pop8();
        s_.b = pop8();
        s_.a = pop8();
        s_.x = pop16();
        s_.pc = pop16();
        break;

    case 0x3F: // SWI
        push16(s_.pc);
        push16(s_.x);
        push8(s_.a);
        push8(s_.b);
        push8(s_.cc);
        set_flag(I, true);
        s_.pc = read16(0xFFFA);
        break;

    case 0x4A: // DECA
        s_.a = sub8(s_.a, 1);
        break;

    case 0x4C: // INCA
        s_.a = add8(s_.a, 1);
        break;

    case 0x4D: // TSTA
        set_nz8(s_.a);
        set_flag(V, false);
        break;

    case 0x4F: // CLRA
        s_.a = 0;
        set_flag(N, false);
        set_flag(Z, true);
        set_flag(V, false);
        set_flag(C, false);
        break;

    case 0x5A: // DECB
        s_.b = sub8(s_.b, 1);
        break;

    case 0x5C: // INCB
        s_.b = add8(s_.b, 1);
        break;

    case 0x5D: // TSTB
        set_nz8(s_.b);
        set_flag(V, false);
        break;

    case 0x5F: // CLRB
        s_.b = 0;
        set_flag(N, false);
        set_flag(Z, true);
        set_flag(V, false);
        set_flag(C, false);
        break;

    case 0x7E:
    { // JMP extended
        s_.pc = fetch16();
        break;
    }

    case 0x8B:
    { // ADDA #imm
        uint8_t v = fetch8();
        s_.a = add8(s_.a, v);
        break;
    }

    case 0x86:
    { // LDAA #imm
        s_.a = fetch8();
        set_nz8(s_.a);
        set_flag(V, false);
        break;
    }

    case 0x96:
    { // LDAA direct
        uint8_t zp = fetch8();
        s_.a = read8(zp);
        set_nz8(s_.a);
        set_flag(V, false);
        break;
    }

    case 0xB6:
    { // LDAA extended
        uint16_t addr = fetch16();
        s_.a = read8(addr);
        set_nz8(s_.a);
        set_flag(V, false);
        break;
    }

    case 0x97:
    { // STAA direct
        uint8_t zp = fetch8();
        write8(zp, s_.a);
        set_nz8(s_.a);
        set_flag(V, false);
        break;
    }

    case 0xB7:
    { // STAA extended
        uint16_t addr = fetch16();
        write8(addr, s_.a);
        set_nz8(s_.a);
        set_flag(V, false);
        break;
    }

    case 0xC6:
    { // LDAB #imm
        s_.b = fetch8();
        set_nz8(s_.b);
        set_flag(V, false);
        break;
    }

    case 0xD6:
    { // LDAB direct
        uint8_t zp = fetch8();
        s_.b = read8(zp);
        set_nz8(s_.b);
        set_flag(V, false);
        break;
    }

    case 0xF6:
    { // LDAB extended
        uint16_t addr = fetch16();
        s_.b = read8(addr);
        set_nz8(s_.b);
        set_flag(V, false);
        break;
    }

    case 0xD7:
    { // STAB direct
        uint8_t zp = fetch8();
        write8(zp, s_.b);
        set_nz8(s_.b);
        set_flag(V, false);
        break;
    }

    case 0xF7:
    { // STAB extended
        uint16_t addr = fetch16();
        write8(addr, s_.b);
        set_nz8(s_.b);
        set_flag(V, false);
        break;
    }

    case 0x8E:
    { // LDS #imm
        s_.sp = fetch16();
        set_nz16(s_.sp);
        set_flag(V, false);
        break;
    }

    case 0xCE:
    { // LDX #imm
        s_.x = fetch16();
        set_nz16(s_.x);
        set_flag(V, false);
        break;
    }

    case 0xDE:
    { // LDX direct
        uint8_t zp = fetch8();
        s_.x = read16(zp);
        set_nz16(s_.x);
        set_flag(V, false);
        break;
    }

    case 0xFE:
    { // LDX extended
        uint16_t addr = fetch16();
        s_.x = read16(addr);
        set_nz16(s_.x);
        set_flag(V, false);
        break;
    }

    case 0xBD:
    { // JSR extended
        uint16_t addr = fetch16();
        push16(s_.pc);
        s_.pc = addr;
        break;
    }

    case 0x9D:
    { // JSR direct
        uint8_t zp = fetch8();
        push16(s_.pc);
        s_.pc = zp;
        break;
    }

    default:
        unimplemented(op);
    }
}
