#pragma once

#include <cstdint>
#include <vector>

#include "mem.h"
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
    {
        devices_.push_back(&banked_memory_latch_);
        devices_.push_back(&config_switches_);
        devices_.push_back(&acia_0_);
    }

    virtual uint8_t read(uint16_t addr) const override
    {
        for (auto dev : devices_)
        {
            if (dev->handles(addr) >= 0)
            {
                return dev->in(addr);
            }
        }

        return 0xff;
    }

    virtual void write(uint16_t addr, uint8_t value) override
    {
        for (auto dev : devices_)
        {
            int8_t port = dev->handles(addr);
            if (port >= 0)
            {
                dev->out(port, value);
                return;
            }
        }
    }

    Latch banked_memory_latch_;
    Switches config_switches_;
    Acia acia_0_;

private:
    static const uint16_t StartAddress = 0xE000;
    static const uint16_t EndAddress = 0xE0FF;

    static const uint8_t OffsetBankedMemoryLatch = 0;
    static const uint8_t OffsetConfigSwitches = 1;

    static const uint8_t OffsetAcia0 = 0;

    std::vector<MemoryIODevice *> devices_;
};