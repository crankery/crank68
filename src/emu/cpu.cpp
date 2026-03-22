#include <sstream>
#include <iomanip>

#include "cpu.h"
#include "machine.h"

// 8 bit read on the machine's bus
uint8_t Cpu::read8(uint16_t addr) const
{
    return Machine::instance().read(addr);
}

// 8 bit write on the machine's bus
void Cpu::write8(uint16_t addr, uint8_t value)
{
    Machine::instance().write(addr, value);
}

void Cpu::traceBefore(char *buf, size_t buf_size)
{
    uint16_t pc = s_.pc;
    uint8_t op = read8(pc);
    OpInfo op_info = cpu_op_table[op];
    const char *op_name_s = op_info.op_name_s;
    addr_mode addr_mode = op_info.addr_mode;

    int argc =
        addr_mode == rel ? 1 : addr_mode == imb ? 1
                           : addr_mode == imw   ? 2
                           : addr_mode == idx   ? 1
                           : addr_mode == dir   ? 1
                           : addr_mode == ext   ? 2
                                                : 0;

    char args[10];
    if (argc == 0)
    {
        args[0] = '\0';
    }
    else if (argc == 1)
    {
        snprintf(args, sizeof(args), "%02x", read8(pc + 1));
    }
    else
    {
        snprintf(args, sizeof(args), "%02x %02x", read8(pc + 1), read8(pc + 2));
    }

    char op_formatted[16];
    switch (addr_mode)
    {
    case inh:
        snprintf(op_formatted, sizeof(op_formatted), "%s", op_name_s);
        break;
    case imb:
        snprintf(op_formatted, sizeof(op_formatted), "%s #$%02x", op_name_s, read8(pc + 1));
        break;
    case imw:
        snprintf(op_formatted, sizeof(op_formatted), "%s #$%04x", op_name_s, (read8(pc + 1) << 8) | read8(pc + 2));
        break;
    case idx:
        snprintf(op_formatted, sizeof(op_formatted), "%s $%02x, x", op_name_s, read8(pc + 1));
        break;
    case dir:
        snprintf(op_formatted, sizeof(op_formatted), "%s $%02x", op_name_s, read8(pc + 1));
        break;
    case ext:
        snprintf(op_formatted, sizeof(op_formatted), "%s $%04x", op_name_s, (read8(pc + 1) << 8) | read8(pc + 2));
        break;
    case rel:
        snprintf(op_formatted, sizeof(op_formatted), "%s [$%04x] ", op_name_s, pc + 2 + ((int8_t)read8(pc + 1)));
        break;
    default:
        break;
    }

    snprintf(buf,
             buf_size,
             "%04x: %02x %-8s %-12s",
             pc,
             op,
             args,
             op_formatted);
}

void Cpu::traceAfter(char *before)
{
    char message[256];
    char stack[64];

    stack[0] = '\0';
    int count = 0;
    for (int sp = s_.sp; sp < 0xbfff; ++sp)
    {
        snprintf(stack, sizeof(stack), "%s %02x", stack, read8(sp));
        if (++count > 8)
            break;
    }

    snprintf(message,
             sizeof(message),
             "%s | %c%c%c%c%c%c | a:%02x b:%02x x:%04x s:%04x|%s\n",
             before,
             s_.cc & C ? 'C' : ' ',
             s_.cc & V ? 'V' : ' ',
             s_.cc & Z ? 'Z' : ' ',
             s_.cc & N ? 'N' : ' ',
             s_.cc & I ? 'I' : ' ',
             s_.cc & H ? 'H' : ' ',
             s_.a,
             s_.b,
             s_.x,
             s_.sp,
             stack);

    Machine::instance().trace(message);
}

uint16_t Cpu::read16(uint16_t addr) const
{
    uint8_t hi = read8(addr);
    uint8_t lo = read8(static_cast<uint16_t>(addr + 1));
    return static_cast<uint16_t>((hi << 8) | lo);
}

void Cpu::write16(uint16_t addr, uint16_t value)
{
    write8(addr, static_cast<uint8_t>(value >> 8));
    write8(static_cast<uint16_t>(addr + 1), static_cast<uint8_t>(value & 0xFF));
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

void Cpu::reset()
{
    uint16_t reset_vector = read16(0xFFFE);

    char message[256];
    snprintf(message, sizeof(message), "---\nreset pc=%04x\n---\n", reset_vector);
    Machine::instance().trace(message);

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
    snprintf(message, sizeof(message), "---\n\n failure: unimplemented opcode 0x%02x at 0x%04x\n\n---\n", opcode, s_.pc - 1);
    Machine::instance().trace(message);

    throw std::runtime_error("unimplemented opcode");
}

[[noreturn]] void Cpu::infiniteloop() const
{
    char message[256];
    snprintf(message, sizeof(message), "---\ninfinite loop at %04x\n---\n", s_.pc);
    Machine::instance().trace(message);

    throw std::runtime_error("infinite loop");
}