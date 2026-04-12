#pragma once

#include <array>
#include <cstdint>

#include "mem.h"

class Rom : public Mem
{
public:
    static const int StartAddress = 0xE100;
    static const int EndAddress = 0xFFFF;
    static const int Size = EndAddress - StartAddress + 1;

    Rom() : Mem(StartAddress, EndAddress)
    {
    }

    virtual uint8_t read(uint16_t addr) const override;
    virtual void write(uint16_t addr, uint8_t value) override;

private:
    std::array<uint8_t, Size> memory_;
};
