#pragma once

#include <cstdint>
#include <vector>

#include "mem.h"

// devices
#include "memoryIODevice.h"

#include "latch.h"
#include "acia.h"
#include "switches.h"

class MemoryIO : public Mem
{
public:
    MemoryIO()
        : Mem(StartAddress, EndAddress),
          banked_memory_latch_(0, OffsetBankedMemoryLatch),
          config_switches_(0, OffsetConfigSwitches),
          acia_0_(1, OffsetAcia0)
    //   ,
    //   acia_1_(1, OffsetAcia1),
    //   acia_2_(1, OffsetAcia2),
    //   acia_3_(1, OffsetAcia3)
    {
        devices_.push_back(&banked_memory_latch_);
        devices_.push_back(&config_switches_);
        devices_.push_back(&acia_0_);

        // devices_.push_back(&acia_1_);
        // devices_.push_back(&acia_2_);
        // devices_.push_back(&acia_3_);
    }

    virtual uint8_t read(uint16_t addr) const override
    {
        // printf("memory IO read: %04x\r\n", addr);

        for (auto dev : devices_)
        {
            // printf("checking %04x with dev slot %1x offset %1x count %1x\r\n", addr, dev->getSlot(), dev->getOffset(), dev->getCount());

            if (dev->handles(addr) >= 0)
            {
                // printf("IO read: dev @ %1x:%1x handles\r\n", dev->getSlot(), dev->getOffset());
                return dev->in(addr);
            }
        }

        return 0xff;
    }

    virtual void write(uint16_t addr, uint8_t value) override
    {
        // printf("memory io write %04x %02x\r\n", addr, value);
        for (auto dev : devices_)
        {
            // printf("checking %04x with dev slot %1x offset %1x count %1x\r\n", addr, dev->getSlot(), dev->getOffset(), dev->getCount());

            int8_t port = dev->handles(addr);
            if (port >= 0)
            {
                // printf("sending %02x to device port %x\r\n", value, port);
                dev->out(port, value);
                return;
            }
        }
    }

    Latch banked_memory_latch_;
    Switches config_switches_;
    Acia acia_0_;
    // Acia acia_1_;
    // Acia acia_2_;
    // Acia acia_3_;

private:
    static const uint16_t StartAddress = 0xE000;
    static const uint16_t EndAddress = 0xE0FF;

    static const uint8_t OffsetBankedMemoryLatch = 0;
    static const uint8_t OffsetConfigSwitches = 1;

    static const uint8_t OffsetAcia0 = 0;
    // static const uint8_t OffsetAcia1 = 2;
    // static const uint8_t OffsetAcia2 = 4;
    // static const uint8_t OffsetAcia3 = 6;

    std::vector<MemoryIODevice *> devices_;
};