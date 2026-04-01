#pragma once

#include "mem.h"
#include <stdio.h>

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

    virtual uint8_t in(uint8_t addr) = 0;

    virtual void out(uint8_t addr, uint8_t value) = 0;

    virtual char *name() = 0;

    int8_t handles(uint16_t addr)
    {
        uint8_t io_port = addr & 0xff;
        uint8_t slot = io_port >> 4;
        uint8_t offset = io_port & 0xf;

        // printf("%s handles %04x?\r\n", name(), addr);

        if ((slot_ == slot))
        {
            if (offset >= offset_ && offset < offset_ + count_)
            {
                // printf("%s handles io_port %02x: slot: %1x=%1x %1x>=%1x<%1x\r\n", name(), io_port, slot, slot_, offset, offset_, offset_ + count_);
                int8_t devPort = offset - offset_;
                // printf("%s dev match %x:%x\r\n", name(), slot, devPort);
                return devPort;
            }
        }

        return -1;
    }

protected:
    const uint8_t slot_;
    const uint8_t offset_;
    const uint8_t count_;
};