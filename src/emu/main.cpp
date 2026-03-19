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

int main(int argc, char **argv)
{
    // if (argc > 1)
    // {
    //     if (!MachineInstance.rom_.load(argv[1], 0x100))
    //     {
    //         std::cerr << "Failed to load ROM " << errno << "\n";
    //         return 1;
    //     }
    // }
    // else
    // {
    //     std::cerr << "No ROM image provided\n";
    //     return 1;
    // }

    MachineInstance.cpu_.reset();

    try
    {
        while (true)
        {
            MachineInstance.cpu_.step();
        }
    }
    catch (const std::exception &e)
    {
        std::cerr << "CPU stopped: " << e.what() << '\n';
        return 1;
    }

    return 0;
}
