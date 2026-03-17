#include "m6800.h"
#include <sstream>
#include <iomanip>

#include "m6800.h"

void M6800::step()
{
    uint8_t op = fetch8();

    op_names op_name = m6800_op_table[op].op_name;
    addr_mode addr_mode = m6800_op_table[op].addr_mode;

    bool result = false;
    switch (op_name)
    {
    case op_names::lds:
        result = op_lds(op, op_name, addr_mode);
        break;
    case op_names::clra:
        result = op_clra(op, op_name, addr_mode);
        break;
    case op_names::tab:
        result = op_tab(op, op_name, addr_mode);
    default:
        result = false;
    }

    if (!result)
    {
        unimplemented(op);
    }
}

void M6800::disassemble(char *result, size_t result_size, uint16_t pc, uint8_t op, uint8_t b0, uint8_t b1)
{
    const char *op_name = m6800_op_table[op].op_name_s;
    addr_mode addr_mode = m6800_op_table[op].addr_mode;

    char buf2[256];

    memset(buf2, 0, sizeof(buf2));
    memset(result, 0, result_size);

    switch (addr_mode)
    {
    case rel: /* relative */
        snprintf(buf2, sizeof(buf2), "%s $%04x", op_name, pc + ((int8_t)b0) + 2);
        snprintf(result, result_size, "%02x %02x     %s", op, b0, buf2);
        break;
    case imb: /* immediate (byte) */
        snprintf(buf2, sizeof(buf2), "%s #$%02x", op_name, (uint8_t)b0);
        snprintf(result, result_size, "%02x %02x    %s", op, b0, buf2);
        break;
    case imw: /* immediate (word) */
        snprintf(buf2, sizeof(buf2), "%s #$%04x", op_name, (uint16_t)(b1 | (b0 << 8)));
        snprintf(result, result_size, "%02x %02x %02x %s", op, b0, b1, buf2);
        break;
    case idx: /* indexed + byte offset */
        snprintf(buf2, sizeof(buf2), "%s $%02x,x", op_name, (uint8_t)b0);
        snprintf(result, result_size, "%02x %02x    %s", op, b0, buf2);
        break;
    case dir: /* direct address */
        snprintf(buf2, sizeof(buf2), "%s $%02x", op_name, (uint8_t)b0);
        snprintf(result, result_size, "%02x %02x    %s", op, b1, buf2);
        break;
    case ext: /* extended address */
        snprintf(buf2, sizeof(buf2), "%s $%04x", op_name, (uint16_t)(b0 | (b1 << 8)));
        snprintf(result, result_size, "%02x %02x %02x %s", op, b0, b1, buf2);
        break;
    case inh: /* inherent */
        snprintf(buf2, sizeof(buf2), "%s", op_name);
        snprintf(result, result_size, "%02x       %s", op, buf2);
        break;
    default:
        std::cerr << "disassemble default code=0x%02x, op_name=%s addr_mode=%02x\n"
                  << op << op_name << addr_mode;
    }

    // Pad with spaces
    int len = strlen(result);
    memset(result + len, ' ', result_size - strlen(result));
    result[20] = '\0';
}

void M6800::dump_state(const M6800 &cpu)
{
    char dasm[256];
    const auto &s = cpu.state();

    disassemble(dasm, sizeof(dasm), s.pc, cpu.read8(s.pc), cpu.read8(s.pc + 1), cpu.read8(s.pc + 2));

    char cc[7];
    snprintf(cc, sizeof(cc), "%s%s%s%s%s%s",
             s.cc & C ? "C" : " ",
             s.cc & V ? "V" : " ",
             s.cc & Z ? "Z" : " ",
             s.cc & N ? "N" : " ",
             s.cc & I ? "I" : " ",
             s.cc & H ? "H" : " ");
    std::cout
        << std::hex << std::setw(4) << std::setfill('0') << s.pc << ": "
        << dasm
        << " A=" << std::setw(2) << static_cast<int>(s.a)
        << " B=" << std::setw(2) << static_cast<int>(s.b)
        << " X=" << std::setw(4) << s.x
        << " SP=" << std::setw(4) << s.sp
        << " " << cc
        << std::endl;
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
        << std::hex << std::setw(2) << std::setfill('0')
        << static_cast<int>(opcode)
        << " at PC=0x"
        << std::setw(4) << static_cast<int>(s_.pc - 1);
    throw std::runtime_error(oss.str());
}
