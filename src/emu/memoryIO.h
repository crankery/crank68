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

    MemoryIO() : Mem()
    {
    }

    virtual uint8_t read(uint16_t addr) const override;
    virtual void write(uint16_t addr, uint8_t value) override;

protected:
    virtual uint16_t size() const override
    {
        return EndAddress - StartAddress + 1;
    }
};