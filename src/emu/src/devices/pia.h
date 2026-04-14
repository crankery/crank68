#pragma once

#include <cstring>

#include "memoryIODevice.h"

class Pia : public MemoryIODevice
{
public:
    Pia(const uint8_t slot, const uint8_t offset)
        : MemoryIODevice(slot, offset, RegisterCount)
    {
        snprintf(name_, sizeof(name_), "pia(%x:%x)", slot, offset);
    }

    virtual uint8_t in(uint8_t port) override;
    virtual void out(uint8_t port, uint8_t value) override;

    virtual char *name() override
    {
        return name_;
    }

    static const uint8_t RegisterCount = 4;

private:
    char name_[25];
};