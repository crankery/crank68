#include "m6800.h"
#include <array>
#include <cstdint>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <iterator>
#include <vector>
#include <memory>

#include "ram.h"
#include "rom.h"
#include "memoryIO.h"
#include "machine.h"
#include "dasm.h"

static void dump_state(const M6800 &cpu)
{
    const auto &s = cpu.state();

    char dasm[256];
    Dasm::disassemble(dasm, sizeof(dasm), s.pc, cpu.read8(s.pc), cpu.read8(s.pc + 1), cpu.read8(s.pc + 2));

    char cc[7];
    snprintf(cc, sizeof(cc), "%s%s%s%s%s%s",
             s.cc & M6800::C ? "C" : " ",
             s.cc & M6800::V ? "V" : " ",
             s.cc & M6800::Z ? "Z" : " ",
             s.cc & M6800::N ? "N" : " ",
             s.cc & M6800::I ? "I" : " ",
             s.cc & M6800::H ? "H" : " ");
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

int main(int argc, char **argv)
{
    M6800 cpu;

    if (argc > 1)
    {
        if (!cpu.loadRom(argv[1], 0x100))
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

    cpu.reset();

    try
    {
        // for (int i = 0; i < 50; ++i)
        while (true)
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

    return 0;
}
