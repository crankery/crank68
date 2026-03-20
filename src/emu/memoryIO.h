#pragma once

#include <cstdint>
#include <vector>

#include "mem.h"

// devices
#include "memoryIODevice.h"

#include "latch.h"
#include "acia.h"

class MemoryIO : public Mem
{
public:
    MemoryIO()
        : Mem(StartAddress, EndAddress),
          banked_memory_latch_(SlotLatch, OffsetBankedMemoryLatch),
          acia_0_(SlotCom0, OffsetAcia),
          acia_1_(SlotCom1, OffsetAcia)
    {
        devices_.push_back(&banked_memory_latch_);
        devices_.push_back(&acia_0_);
        devices_.push_back(&acia_1_);
    }

    virtual uint8_t read(uint16_t addr) const override
    {
        for (auto dev : devices_)
        {
            if (dev->handles(addr))
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
            if (dev->handles(addr))
            {
                dev->out(addr, value);
                return;
            }
        }
    }

    uint8_t getBankedMemoryLatchValue()
    {
        return banked_memory_latch_.getValue();
    }

private:
    static const uint16_t StartAddress = 0xE000;
    static const uint16_t EndAddress = 0xE0FF;

    static const uint8_t SlotLatch = 0x0;
    static const uint8_t OffsetBankedMemoryLatch = 0x0;

    static const uint8_t SlotCom0 = 0x1;
    static const uint8_t SlotCom1 = 0x2;
    static const uint8_t OffsetAcia = 0x0;

    Latch banked_memory_latch_;
    Acia acia_0_;
    Acia acia_1_;

    std::vector<MemoryIODevice *> devices_;
};