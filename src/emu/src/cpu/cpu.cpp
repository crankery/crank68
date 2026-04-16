#include <sstream>
#include <iomanip>

#include "cpu.h"
#include "machine/machine.h"
#include "gen/cpu_defs.g.h"

uint8_t Cpu::read8(uint16_t addr) const
{
    return Machine::instance().read8(addr);
}

uint16_t Cpu::read16(uint16_t addr) const
{
    return Machine::instance().read16(addr);
}

void Cpu::write8(uint16_t addr, uint8_t value)
{
    Machine::instance().write8(addr, value);
}

void Cpu::write16(uint16_t addr, uint16_t value)
{
    Machine::instance().write16(addr, value);
}

void Cpu::step()
{
    uint16_t pc = s_.pc;
    uint8_t opcode = fetch8();
    OpInfo op_info = cpu_op_table[opcode];
    cycles_ += op_info.cycles;

    bool result = dispatch(opcode, op_info);

    Machine::instance().logging_.trace(pc);

    if (!result)
    {
        unimplemented(opcode);
    }
}

uint8_t Cpu::fetch8()
{
    return read8(s_.pc++);
}

uint16_t Cpu::fetch16()
{
    uint16_t v = read16(s_.pc);
    s_.pc += 2;
    return v;
}

void Cpu::push8(uint8_t v)
{
    write8(--s_.sp, v);
}

void Cpu::push16(uint16_t v)
{
    push8(static_cast<uint8_t>(v & 0xFF));
    push8(static_cast<uint8_t>(v >> 8));
}

uint8_t Cpu::pop8()
{
    return read8(s_.sp++);
}

uint16_t Cpu::pop16()
{
    uint8_t hi = pop8();
    uint8_t lo = pop8();
    uint16_t result = static_cast<uint16_t>((hi << 8) | lo);
    return result;
}

void Cpu::set_flag(uint8_t flag, bool on)
{
    if (on)
        s_.cc |= flag;
    else
        s_.cc &= ~flag;
}

bool Cpu::get_flag(uint8_t flag) const
{
    return (s_.cc & flag) != 0;
}

void Cpu::set_nz8(uint8_t v)
{
    set_flag(Z, v == 0);
    set_flag(N, (v & 0x80) != 0);
}

void Cpu::set_nz16(uint16_t v)
{
    set_flag(Z, v == 0);
    set_flag(N, (v & 0x8000) != 0);
}

uint8_t Cpu::add8(uint8_t lhs, uint8_t rhs, bool carry_in)
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

uint8_t Cpu::sub8(uint8_t lhs, uint8_t rhs, bool carry_in)
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

uint16_t Cpu::sub16(uint16_t lhs, uint16_t rhs, bool carry_in)
{
    uint32_t c = carry_in ? 1u : 0u;
    uint32_t r = static_cast<uint32_t>(lhs) - static_cast<uint32_t>(rhs) - c;
    uint16_t out = static_cast<uint16_t>(r & 0xFFFF);

    set_flag(C, r > 0xFFFF);
    set_flag(Z, out == 0);
    set_flag(N, (out & 0x8000) != 0);
    set_flag(V, (((lhs ^ rhs) & (lhs ^ out)) & 0x8000) != 0);

    return out;
}

void Cpu::reset()
{
    uint16_t reset_vector = read16(0xFFFE);

    char message[256];
    snprintf(message, sizeof(message), "---\nreset pc=%04x\n---\n", reset_vector);
    Machine::instance().logging_.log(message);

    s_.a = 0;
    s_.b = 0;
    s_.x = 0;
    s_.cc = I;
    s_.sp = 0x00FF;
    s_.pc = reset_vector;
}

[[noreturn]] void Cpu::unimplemented(uint8_t opcode) const
{
    char message[256];
    snprintf(message, sizeof(message), "\r\n---\r\n\r\nunimplemented opcode 0x%02x at 0x%04x\r\n\r\n---\r\n", opcode, s_.pc - 1);
    Machine::instance().logging_.log(message);

    throw std::runtime_error(message);
}

uint8_t Cpu::do_shift8(uint8_t value, ShiftOp op)
{
    uint8_t result = value;

    switch (op)
    {
    case ShiftOp::asl:
    {
        const bool old7 = (value & 0x80) != 0;
        result = static_cast<uint8_t>(value << 1);
        set_flag(C, old7);
        set_nz8(result);
        set_flag(V, get_flag(N) ^ get_flag(C));
        break;
    }
    case ShiftOp::asr:
    {
        const bool old0 = (value & 0x01) != 0;
        const uint8_t msb = value & 0x80;
        result = static_cast<uint8_t>((value >> 1) | msb);
        set_flag(C, old0);
        set_nz8(result);
        set_flag(V, get_flag(N) ^ get_flag(C));
        break;
    }
    case ShiftOp::lsr:
    {
        const bool old0 = (value & 0x01) != 0;
        result = static_cast<uint8_t>(value >> 1);
        set_flag(C, old0);
        set_nz8(result);
        set_flag(V, get_flag(N) ^ get_flag(C));
        break;
    }
    case ShiftOp::rol:
    {
        const bool old7 = (value & 0x80) != 0;
        const bool oldC = get_flag(C);
        result = static_cast<uint8_t>((value << 1) | (oldC ? 1 : 0));
        set_flag(C, old7);
        set_nz8(result);
        set_flag(V, get_flag(N) ^ get_flag(C));
        break;
    }
    case ShiftOp::ror:
    {
        const bool old0 = (value & 0x01) != 0;
        const bool oldC = get_flag(C);
        result = static_cast<uint8_t>((value >> 1) | (oldC ? 0x80 : 0x00));
        set_flag(C, old0);
        set_nz8(result);
        set_flag(V, get_flag(N) ^ get_flag(C));
        break;
    }
    }

    return result;
}

uint8_t Cpu::do_rol8(uint8_t value)
{
    const bool old7 = (value & 0x80) != 0;
    const bool oldC = get_flag(C);

    const uint8_t result =
        static_cast<uint8_t>((value << 1) | (oldC ? 1 : 0));

    const bool newC = old7;
    const bool newN = (result & 0x80) != 0;

    set_flag(C, newC);
    set_flag(N, newN);
    set_flag(Z, result == 0);
    set_flag(V, newN ^ newC);

    return result;
}

uint8_t Cpu::do_ror8(uint8_t value)
{
    const bool old0 = (value & 0x01) != 0;
    const bool oldC = get_flag(C);

    const uint8_t result =
        static_cast<uint8_t>((value >> 1) | (oldC ? 0x80 : 0x00));

    const bool newC = old0;
    const bool newN = (result & 0x80) != 0;

    set_flag(C, newC);
    set_flag(N, newN);
    set_flag(Z, result == 0);
    set_flag(V, newN ^ newC);

    return result;
}
bool Cpu::shift_a(ShiftOp op)
{
    s_.a = do_shift8(s_.a, op);
    return true;
}

bool Cpu::shift_b(ShiftOp op)
{
    s_.b = do_shift8(s_.b, op);
    return true;
}

bool Cpu::shift_mem(addr_mode mode, ShiftOp op)
{
    uint16_t addr = 0;

    switch (mode)
    {
    case addr_mode::idx:
    {
        uint8_t off = fetch8();
        addr = static_cast<uint16_t>(s_.x + off);
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

    uint8_t value = read8(addr);
    value = do_shift8(value, op);
    write8(addr, value);
    return true;
}

bool Cpu::branch_if(bool condition, addr_mode mode)
{
    if (mode != addr_mode::rel)
        return false;

    int8_t off = static_cast<int8_t>(fetch8());

    if (condition)
        s_.pc = static_cast<uint16_t>(s_.pc + off);

    return true;
}

void Cpu::do_test(uint8_t value)
{
    set_nz8(value);
    set_flag(V, false);
    set_flag(C, false);
}

bool Cpu::store8(uint8_t value, addr_mode mode)
{
    uint16_t addr;

    switch (mode)
    {
    case addr_mode::dir:
        addr = fetch8();
        break;

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

    write8(addr, value);

    set_nz8(value);
    set_flag(V, false);
    return true;
}

bool Cpu::store16(uint16_t value, addr_mode mode)
{
    uint16_t addr;

    switch (mode)
    {
    case addr_mode::dir:
    {
        addr = fetch8();
        break;
    }
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

bool Cpu::load8(uint8_t &value, addr_mode mode)
{
    uint16_t addr;

    switch (mode)
    {
    case addr_mode::dir:
        addr = fetch8();
        value = read8(addr);
        break;

    case addr_mode::imb:
        value = fetch8();
        break;

    case addr_mode::idx:
    {
        uint8_t off = fetch8();
        addr = s_.x + off;
        value = read8(addr);
        break;
    }

    case addr_mode::ext:
        addr = fetch16();
        value = read8(addr);
        break;

    default:
        return false;
    }

    return true;
}

bool Cpu::load16(uint16_t &dst, addr_mode mode)
{
    uint16_t value;

    switch (mode)
    {
    case addr_mode::dir:
        value = read16(fetch8());
        break;
    case addr_mode::imw:
        value = fetch16();
        break;
    case addr_mode::idx:
    {
        uint8_t off = fetch8();
        value = read16(s_.x + off);
        break;
    }
    case addr_mode::ext:
        value = read16(fetch16());
        break;
    default:
        return false;
    }

    dst = value;
    set_nz16(dst);
    set_flag(V, false);
    return true;
}

std::optional<uint16_t> Cpu::resolve_operand_addr(addr_mode mode)
{
    switch (mode)
    {
    case addr_mode::dir:
        return static_cast<uint16_t>(fetch8());

    case addr_mode::idx:
    {
        uint8_t off = fetch8();
        return static_cast<uint16_t>(s_.x + off);
    }

    case addr_mode::ext:
        return fetch16();

    default:
        return std::nullopt;
    }
}

std::optional<uint8_t> Cpu::read_operand8(addr_mode mode)
{
    switch (mode)
    {
    case addr_mode::imb:
        return fetch8();

    case addr_mode::dir:
    case addr_mode::idx:
    case addr_mode::ext:
    {
        auto addr = resolve_operand_addr(mode);
        if (!addr)
            return std::nullopt;

        return read8(*addr);
    }

    default:
        return std::nullopt;
    }
}

[[noreturn]] void Cpu::infiniteloop() const
{
    char message[256];
    snprintf(message, sizeof(message), "---\ninfinite loop at %04x\n---\n", s_.pc);
    Machine::instance().logging_.log(message);

    throw std::runtime_error("infinite loop");
}