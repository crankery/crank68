#pragma once

#include <cstring>
#include "memoryIODevice.h"

// simple write only latch
class Latch : public MemoryIODevice
{
public:
    Latch(const uint8_t slot, const uint8_t offset)
        : MemoryIODevice(slot, offset, 1)
    {
        value_ = 0;
        snprintf(name_, sizeof(name_), "latch(%x:%x)", slot, offset);
    }

    virtual uint8_t in(uint8_t port) override;
    virtual void out(uint8_t addr, uint8_t value) override;

    virtual char *name() override
    {
        return name_;
    }

    uint8_t getValue()
    {
        return value_;
    }

private:
    uint8_t value_;
    char name_[25];
};