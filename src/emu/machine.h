#pragma once

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
#include "bankedMemory.h"

class Machine
{
public:
    Machine()
    {
    }

    bool loadRom(const char *path, uint16_t offset = 0)
    {
        return rom_.load(path, offset);
    }

    uint8_t read(uint16_t addr) const;
    void write(uint16_t addr, uint8_t value);

private:
    mutable Ram ram_;
    mutable Rom rom_;
    mutable MemoryIO memory_io_;
    mutable BankedMemory banked_memory_;
};
