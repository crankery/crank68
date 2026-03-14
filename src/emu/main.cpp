#include "m6800.h"
#include <array>
#include <cstdint>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <iterator>
#include <vector>

const int RamStart = 0x0000;
const int RamEnd = 0xBFFF;
const int BankedStart = 0xC000;
const int BankedEnd = 0xDFFF;
const int IOStart = 0xE000;
const int IOEnd = 0xEFFF;
const int RomStart = 0xE100;
const int RomEnd = 0xFFFF;
;

static std::array<uint8_t, 65536> mem{};

static uint8_t mem_read(uint16_t addr)
{
    return mem[addr];
}

static void mem_write(uint16_t addr, uint8_t value)
{
    // crude ROM protection for E000-FFFF
    if (addr >= RomStart)
    {
        return;
    }

    mem[addr] = value;
}

static bool load_binary(const char *path, uint16_t base)
{
    std::ifstream f(path, std::ios::binary);
    if (!f)
        return false;

    std::vector<uint8_t> data((std::istreambuf_iterator<char>(f)),
                              std::istreambuf_iterator<char>());

    if (base + data.size() > mem.size())
        return false;

    for (size_t i = 0; i < data.size(); ++i)
    {
        mem[base + i] = data[i];
    }
    return true;
}

static void dump_state(const M6800 &cpu)
{
    const auto &s = cpu.state();
    std::cout
        << "PC=" << std::hex << std::uppercase << std::setw(4) << std::setfill('0') << s.pc
        << " A=" << std::setw(2) << static_cast<int>(s.a)
        << " B=" << std::setw(2) << static_cast<int>(s.b)
        << " X=" << std::setw(4) << s.x
        << " SP=" << std::setw(4) << s.sp
        << " CC=" << std::setw(2) << static_cast<int>(s.cc)
        << '\n';
}

int main(int argc, char **argv)
{
    // Optional ROM image argument
    if (argc > 1)
    {
        if (!load_binary(argv[1], 0xE000))
        {
            std::cerr << "Failed to load ROM\n";
            return 1;
        }
    }
    else
    {
        std::cerr << "No ROM image provided\n";
        return 1;
    }

    M6800 cpu(mem_read, mem_write);
    cpu.reset();

    try
    {
        for (int i = 0; i < 50; ++i)
        {
            dump_state(cpu);
            cpu.step();
        }
    }
    catch (const std::exception &e)
    {
        std::cerr << "CPU stopped: " << e.what() << '\n';
        dump_state(cpu);
        return 1;
    }

    std::cout << "Memory[0x0080] = 0x"
              << std::hex << std::uppercase << std::setw(2) << std::setfill('0')
              << static_cast<int>(mem[0x0080]) << '\n';

    return 0;
}
