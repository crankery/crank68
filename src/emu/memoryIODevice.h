#pragma once

#include "mem.h"

class MemoryIODevice
{
public:
    MemoryIODevice(const uint8_t slot, const uint8_t offset, const uint8_t count)
        : slot_(slot), offset_(offset), count_(count)
    {
    }

    virtual ~MemoryIODevice() = default;

    uint8_t getSlot() const
    {
        return slot_;
    };

    uint8_t getOffset() const
    {
        return offset_;
    };

    uint8_t getCount() const
    {
        return count_;
    };

    virtual uint8_t in(uint8_t addr) const = 0;

    virtual void out(uint8_t addr, uint8_t value) = 0;

    bool handles(uint16_t addr)
    {
        if (((addr >> 12) == slot_))
        {
            uint8_t offset = addr & 0xf;
            if (offset >= offset_ && offset <= offset_ + count_)
            {
                return true;
            }
        }

        return false;
    }

protected:
    const uint8_t slot_;
    const uint8_t offset_;
    const uint8_t count_;
};