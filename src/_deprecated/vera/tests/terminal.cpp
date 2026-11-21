#include <algorithm>
#include <array>
#include <cstdint>
#include <deque>
#include <fstream>
#include <iterator>
#include <regex>
#include <stdexcept>
#include <string>
#include <vector>
#include "cpu/cpu.h"

static void check(bool ok, const char *message)
{
    if (!ok)
    {
        throw std::runtime_error(message);
    }
}

static std::vector<uint8_t> read_file(const char *name)
{
    std::ifstream file(name, std::ios::binary);
    check(bool(file), "Cannot open test input");
    return {std::istreambuf_iterator<char>(file), {}};
}

static uint16_t symbol(const char *name)
{
    std::ifstream file("../flex2/build/vera.lst");
    std::regex pattern(std::string("^") + name + " +[AS]:([0-9A-Fa-f]{4})$");
    std::smatch match;
    std::string line;
    while (std::getline(file, line))
    {
        if (std::regex_match(line, match, pattern))
        {
            return uint16_t(std::stoul(match[1], nullptr, 16));
        }
    }
    throw std::runtime_error(std::string("Missing symbol: ") + name);
}

struct Bus : IBus
{
    std::array<uint8_t, 65536> ram{};
    std::array<uint8_t, 131072> vram{};
    std::array<uint8_t, 32> registers{};
    uint32_t address = 0;
    std::deque<uint8_t> keys;
    unsigned keyboardReads = 0;

    uint8_t read8(uint16_t a) override
    {
        if (a >= 0xe01c && a <= 0xe01f)
        {
            throw std::runtime_error("Legacy PIA keyboard read");
        }
        if (a == 0xe080)
        {
            ++keyboardReads;
            if (keys.empty())
            {
                return 0;
            }
            const uint8_t value = keys.front();
            keys.pop_front();
            return value;
        }
        if (a >= 0xe040 && a <= 0xe05f)
        {
            return registers[a - 0xe040];
        }
        return ram[a];
    }

    void write8(uint16_t a, uint8_t value) override
    {
        if (a >= 0xe01c && a <= 0xe01f)
        {
            throw std::runtime_error("Legacy PIA keyboard write");
        }
        if (a >= 0xe040 && a <= 0xe05f)
        {
            const auto index = a - 0xe040;
            registers[index] = value;
            if (index == 0)
            {
                address = (address & 0x1ff00) | value;
            }
            else if (index == 1)
            {
                address = (address & 0x100ff) | (uint32_t(value) << 8);
            }
            else if (index == 2)
            {
                address = (address & 0xffff) | (uint32_t(value & 1) << 16);
            }
            else if (index == 3)
            {
                vram[address] = value;
                check((registers[2] & 0xf0) == 0x10, "Expected byte increment");
                address = (address + 1) & 0x1ffff;
            }
            return;
        }
        ram[a] = value;
    }
};

static void call(Cpu &cpu, Bus &bus, uint16_t entry, uint8_t ch)
{
    cpu.s_.pc = entry;
    cpu.s_.a = ch;
    cpu.s_.sp = 0x9ffd;
    bus.ram[0x9ffe] = 0x90;
    bus.ram[0x9fff] = 0;
    for (int i = 0; i < 100000; ++i)
    {
        if (cpu.s_.pc == 0x9000)
        {
            return;
        }
        cpu.step();
    }
    throw std::runtime_error("term_putc did not return");
}

static void run_until(Cpu &cpu, uint16_t stop)
{
    for (int i = 0; i < 100000; ++i)
    {
        cpu.step();
        if (cpu.s_.pc == stop)
        {
            return;
        }
    }
    throw std::runtime_error("Command input loop timed out");
}

int main()
{
    Bus bus;
    const auto binary = read_file("../flex2/build/vera.bin");
    const auto font = read_file("font.bin");
    std::copy(binary.begin(), binary.end(), bus.ram.begin() + 0x0300);
    bus.ram[0xad1e] = 0x39; // FLEX PSTRNG stub: return after the serial notice.
    Cpu cpu(bus);
    cpu.s_.pc = 0x0300;
    cpu.s_.sp = 0x9fff;
    const auto input_loop = symbol("poll_input");
    for (int i = 0; i < 100000; ++i)
    {
        if (cpu.s_.pc == input_loop)
        {
            break;
        }
        cpu.step();
    }
    check(cpu.s_.pc == input_loop, "Initialization timed out");
    check(bus.registers[9] == 0x11, "VGA layer 0 was not enabled");
    check(bus.registers[13] == 0x20, "Map geometry is wrong");
    check(bus.registers[15] == 0x40, "Font tile base is wrong");
    check(bus.registers[10] == 0x80 && bus.registers[11] == 0x40, "Text scaling is wrong");
    check(std::equal(font.begin(), font.end(), bus.vram.begin() + 0x8000), "Font upload differs");
    check(bus.keyboardReads == 0, "Initialization consumed keyboard input");

    const auto putc = symbol("term_putc");
    call(cpu, bus, symbol("vera_init"), 0);
    call(cpu, bus, putc, '\r');
    call(cpu, bus, putc, '\n');
    call(cpu, bus, putc, 'A');
    check(bus.vram[256] == 'A' && bus.vram[257] == 0x0f, "Character missing from row 1");
    call(cpu, bus, putc, 8);
    call(cpu, bus, putc, 'B');
    check(bus.vram[256] == 'B', "Backspace did not reposition cursor");

    for (int row = 1; row <= 29; ++row)
    {
        call(cpu, bus, putc, '\n');
    }
    check(bus.registers[18] == 8, "Scroll did not advance one tile row");
    check(bus.vram[30 * 256] == ' ', "New bottom row was not cleared");
    check(bus.vram[256] == 'B', "Old row content was lost during scroll");

    const auto getc = symbol("keyboard_getc");
    bus.keys.push_back('q');
    bus.keys.push_back('C');
    bus.keys.push_back(13);
    call(cpu, bus, getc, 0);
    check(cpu.s_.a == 'q', "Keyboard AVR byte was not returned");
    call(cpu, bus, getc, 0);
    check(cpu.s_.a == 'C', "Queued byte order is wrong");
    call(cpu, bus, getc, 0);
    check(cpu.s_.a == 13, "Return byte was not returned");
    check(bus.keys.empty(), "Keyboard reads did not consume the queue");

    call(cpu, bus, symbol("vera_init"), 0);
    call(cpu, bus, symbol("keyboard_init"), 0);
    cpu.s_.pc = input_loop;
    cpu.s_.sp = 0x9fff;
    bus.keys.push_back('x');
    run_until(cpu, input_loop);
    check(bus.vram[0] == 'x', "Keyboard input did not reach VERA");
    bus.keys.push_back(3); // Ctrl-C comes translated from the AVR.
    run_until(cpu, 0xad03);
}
