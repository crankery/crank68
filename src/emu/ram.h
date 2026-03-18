#pragma once

#include <cstdint>
#include <vector>

#include "mem.h"

class Ram : Mem
{
public:
    Ram(uint16_t startAddress, uint16_t endAddress)
        : Mem(startAddress, endAddress)
    {
        memory_.reserve(size());
    }

    virtual uint8_t read(uint16_t addr) const override;
    virtual void write(uint16_t addr, uint8_t value) override;

private:
    std::vector<uint8_t> memory_;
};