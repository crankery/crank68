#include <stdio.h>
#include "cpu.h"
#include "ram.h"
#include "rom.h"
#include "memoryIO.h"
#include "machine.h"

int main(int argc, char **argv)
{
    if (argc > 1)
    {
        if (!Machine::instance().rom_.load(argv[1], 0x100))
        {
            printf("Failed to load ROM\n");
            return 1;
        }
    }
    else
    {
        printf("No ROM image provided\n");
        return 1;
    }

    Machine::instance().cpu_.reset();

    try
    {
        while (true)
        {
            Machine::instance().cpu_.step();
        }
    }
    catch (const std::exception &e)
    {
        printf("CPU stopped: %s\n", e.what());
        return 1;
    }

    return 0;
}
