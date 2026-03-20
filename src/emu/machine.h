#pragma once

#include "m6800.h"
#include "ram.h"
#include "rom.h"
#include "memoryIO.h"
#include "bankedMemory.h"

class Machine
{
public:
    static Machine &instance()
    {
        static Machine instance;
        return instance;
    }

    Machine(const Machine &) = delete;
    Machine &operator=(const Machine &) = delete;

    uint8_t read(uint16_t addr) const;
    void write(uint16_t addr, uint8_t value);

    M6800 cpu_;
    Ram ram_;
    Rom rom_;
    MemoryIO memory_io_;
    BankedMemory banked_memory_;

    Machine() = default;
};