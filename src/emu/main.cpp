#include "m6800.h"
#include <array>
#include <cstdint>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <iterator>
#include <vector>

const uint16_t RamStart = 0x0000;
const uint16_t RamEnd = 0xBFFF;
// const uint16_t BankedStart = 0xC000;
// const uint16_t BankedEnd = 0xDFFF;
const uint16_t IOStart = 0xE000;
const uint16_t IOEnd = 0xE0FF;
const uint16_t RomStart = 0xE100;
const uint16_t RomEnd = 0xFFFF;

const uint8_t SlotLatch = 0x0;
const uint8_t SlotCom = 0x1;

static std::array<uint8_t, 65536> mem{};

static bool ram_read(uint16_t addr, uint8_t &value)
{
    if (addr >= RamStart && addr <= RamEnd)
    {
        value = mem[addr];
        return true;
    }

    return false;
}

static bool rom_read(uint16_t addr, uint8_t &value)
{
    if (addr >= RomStart && addr <= RomEnd)
    {
        value = mem[addr];
        return true;
    }

    return false;
}

static bool banked_read(uint16_t addr, uint8_t &value)
{
    // if (addr >= BankedStart && addr <= BankedEnd)
    // {
    //     value = mem[addr];
    //     return true;
    // }

    return false;
}

static bool read_communications_port(uint8_t port, uint8_t &value)
{
    // For simplicity, we return 0 for all communication port reads in this toy emulator
    value = 0;
    return true;
}

static bool io_read(uint16_t addr, uint8_t &value)
{
    if (addr >= IOStart && addr <= IOEnd)
    {
        switch ((addr >> 8) & 0xF0)
        {
        case SlotCom:
            return read_communications_port(addr & 0xFF, value);
        }
        return true;
    }

    return false;
}

static uint8_t mem_read(uint16_t addr)
{
    uint8_t value;

    if (ram_read(addr, value) || rom_read(addr, value) || banked_read(addr, value) || io_read(addr, value))
    {
        return value;
    }

    return 0xff;
}

static bool write_communication_port(uint8_t port, uint8_t value)
{
    std::cout << "Write to communication port " << static_cast<int>(port)
              << ": 0x" << std::hex << std::uppercase << std::setw(2) << std::setfill('0')
              << static_cast<int>(value) << '\n';

    return true;
}

static bool io_write(uint16_t addr, uint8_t value)
{
    if (addr >= IOStart && addr <= IOEnd)
    {
        switch ((addr >> 8) & 0xF0)
        {
        case SlotLatch:
            // For simplicity, we ignore bank switching in this toy emulator
            return true;
        case SlotCom:
            return write_communication_port(addr & 0xFF, value);
        }
    }

    return false;
}

static bool ram_write(uint16_t addr, uint8_t value)
{
    if (addr >= RamStart && addr <= RamEnd)
    {
        mem[addr] = value;
        return true;
    }

    return false;
}

static bool banked_write(uint16_t addr, uint8_t value)
{
    // if (addr >= BankedStart && addr <= BankedEnd)
    // {
    //     mem[addr] = value;
    //     return true;
    // }

    return false;
}

static bool mem_write(uint16_t addr, uint8_t value)
{

    return ram_write(addr, value) || banked_write(addr, value) || io_write(addr, value);
}

static bool load_binary(const char *path, uint16_t base)
{
    std::ifstream f(path, std::ios::binary);

    std::cout << "Loading binary file '" << path << "' at base address 0x"
              << std::hex << std::uppercase << std::setw(4) << std::setfill('0') << base
              << '\n';

    if (!f)
        return false;

    std::vector<uint8_t> data((std::istreambuf_iterator<char>(f)),
                              std::istreambuf_iterator<char>());

    if (base + data.size() > mem.size())
    {

        std::cout << "base address: 0x" << std::hex << std::uppercase << std::setw(4) << std::setfill('0') << base
                  << ", file size: " << data.size() << " bytes\n";
        std::cout << "Binary file is too large to fit in memory\n";
        return false;
    }

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
