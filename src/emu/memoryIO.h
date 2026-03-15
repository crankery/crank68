#pragma once

#include <array>
#include <cstdint>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <iterator>
#include <vector>

#include "mem.h"

class MemoryIO : Mem
{
public:
    static const uint16_t StartAddress = 0xE000;
    static const uint16_t EndAddress = 0xE0FF;

    MemoryIO();

    bool read(uint16_t addr, uint8_t &value) const;
    bool write(uint16_t addr, uint8_t value);

protected:
    virtual uint16_t size() const override
    {
        return EndAddress - StartAddress + 1;
    }
}