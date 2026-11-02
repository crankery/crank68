#include <array>
#include <initializer_list>
#include <gtest/gtest.h>

#include "cpu/cpu.h"

namespace
{
class TestBus final : public IBus
{
public:
    std::array<uint8_t, 65536> memory{};
    uint8_t read8(uint16_t addr) override { return memory[addr]; }
    void write8(uint16_t addr, uint8_t value) override { memory[addr] = value; }
};

class CpuRegression : public testing::Test
{
protected:
    TestBus bus;
    Cpu cpu{bus};

    void instruction(std::initializer_list<uint8_t> bytes)
    {
        cpu.s_.pc = 0x1000;
        uint16_t addr = cpu.s_.pc;
        for (auto byte : bytes)
            bus.memory[addr++] = byte;
        cpu.step();
    }
};

TEST_F(CpuRegression, DecimalAdjustAllValidBcdAdditions)
{
    // Decimal arithmetic supplies an independent oracle for ADD/ADC followed by DAA.
    for (int lhs = 0; lhs < 100; ++lhs)
        for (int rhs = 0; rhs < 100; ++rhs)
            for (int carry = 0; carry <= 1; ++carry)
            {
                cpu.s_.a = ((lhs / 10) << 4) | (lhs % 10);
                cpu.s_.cc = I | (carry ? C : 0);
                instruction({0x89, static_cast<uint8_t>(((rhs / 10) << 4) | (rhs % 10))});
                const uint8_t half = cpu.s_.cc & H;
                instruction({0x19});
                const int sum = lhs + rhs + carry;
                const int decimal = sum % 100;
                ASSERT_EQ(cpu.s_.a, ((decimal / 10) << 4) | (decimal % 10));
                ASSERT_EQ(cpu.s_.cc & C, sum >= 100 ? C : 0);
                ASSERT_EQ(cpu.s_.cc & Z, decimal == 0 ? Z : 0);
                ASSERT_EQ(cpu.s_.cc & N, decimal >= 80 ? N : 0);
                ASSERT_EQ(cpu.s_.cc & (H | I), half | I);
            }
}

TEST_F(CpuRegression, DecimalAdjustSavedTraceValue)
{
    cpu.s_.a = 0x11;
    instruction({0x19});
    EXPECT_EQ(cpu.s_.a, 0x11);
    EXPECT_EQ(cpu.s_.pc, 0x1001);
}

TEST_F(CpuRegression, TestBUsesBAndLeavesRegistersAlone)
{
    for (uint8_t value : {0x00, 0x80, 0x01})
    {
        cpu.s_.a = 0x42;
        cpu.s_.b = value;
        cpu.s_.cc = H | I | C | V;
        instruction({0x5d});
        EXPECT_EQ(cpu.s_.a, 0x42);
        EXPECT_EQ(cpu.s_.b, value);
        EXPECT_EQ(cpu.s_.cc, (H | I) | (value == 0 ? Z : 0) | (value == 0x80 ? N : 0));
    }
}

TEST_F(CpuRegression, DecrementOverflowAcrossAllOperandsAndForms)
{
    for (uint8_t opcode : {0x4a, 0x5a, 0x6a, 0x7a})
        for (int value = 0; value < 256; ++value)
        {
            cpu.s_.a = cpu.s_.b = bus.memory[0x2000] = value;
            cpu.s_.x = 0x2000;
            cpu.s_.cc = H | I | C | V;
            if (opcode == 0x7a)
                instruction({opcode, 0x20, 0x00});
            else if (opcode == 0x6a)
                instruction({opcode, 0x00});
            else
                instruction({opcode});
            const uint8_t result = static_cast<uint8_t>(value - 1);
            EXPECT_EQ(opcode == 0x4a ? cpu.s_.a : opcode == 0x5a ? cpu.s_.b : bus.memory[0x2000], result);
            EXPECT_EQ(cpu.s_.cc, (H | I | C) | (result == 0 ? Z : 0) | (result & 0x80 ? N : 0) | (value == 0x80 ? V : 0));
        }
}

TEST_F(CpuRegression, PullAccumulatorsPreservesEveryConditionCode)
{
    for (uint8_t opcode : {0x32, 0x33})
        for (int flags = 0; flags < 64; ++flags)
        {
            cpu.s_.sp = 0x01ff;
            bus.memory[0x0200] = 0x80;
            cpu.s_.cc = flags;
            instruction({opcode});
            EXPECT_EQ(opcode == 0x32 ? cpu.s_.a : cpu.s_.b, 0x80);
            EXPECT_EQ(cpu.s_.sp, 0x0200);
            EXPECT_EQ(cpu.s_.cc, flags);
        }
}

TEST_F(CpuRegression, TpaPreservesConditionCodes)
{
    for (int flags = 0; flags < 64; ++flags)
    {
        cpu.s_.cc = flags;
        instruction({0x07});
        EXPECT_EQ(cpu.s_.a, flags);
        EXPECT_EQ(cpu.s_.cc, flags);
    }
}

TEST_F(CpuRegression, CompareAccumulatorsDoesNotChangeThem)
{
    cpu.s_.a = 0x80;
    cpu.s_.b = 1;
    cpu.s_.cc = H | I;
    instruction({0x11});
    EXPECT_EQ(cpu.s_.a, 0x80);
    EXPECT_EQ(cpu.s_.b, 1);
    EXPECT_EQ(cpu.s_.cc, H | I | V);
}

TEST_F(CpuRegression, DesWrapsWithoutChangingFlags)
{
    cpu.s_.sp = 0;
    cpu.s_.cc = 0x3f;
    instruction({0x34});
    EXPECT_EQ(cpu.s_.sp, 0xffff);
    EXPECT_EQ(cpu.s_.cc, 0x3f);
}

TEST_F(CpuRegression, SevSetsOnlyOverflow)
{
    cpu.s_.cc = H | I | C | Z | N;
    instruction({0x0b});
    EXPECT_EQ(cpu.s_.cc, 0x3f);
}

TEST_F(CpuRegression, ComplementMemoryIndexedAndExtended)
{
    for (uint8_t opcode : {0x63, 0x73})
        for (int value = 0; value < 256; ++value)
        {
            cpu.s_.x = 0x1fff;
            cpu.s_.cc = H | I | V;
            bus.memory[0x2000] = value;
            if (opcode == 0x63)
                instruction({opcode, 1});
            else
                instruction({opcode, 0x20, 0});
            const uint8_t result = static_cast<uint8_t>(~value);
            EXPECT_EQ(bus.memory[0x2000], result);
            EXPECT_EQ(cpu.s_.cc, (H | I | C) | (result == 0 ? Z : 0) | (result & 0x80 ? N : 0));
        }
}

TEST_F(CpuRegression, CpxUses6800HighByteFlagsAndPreservesCarry)
{
    for (uint8_t carry : {0, 1})
    {
        cpu.s_.x = 0x1000;
        cpu.s_.cc = H | I | carry;
        instruction({0x8c, 0x10, 0x01});
        EXPECT_EQ(cpu.s_.cc, H | I | carry); // Low-byte borrow does not set N.
        cpu.s_.x = 0x8000;
        instruction({0x8c, 0x00, 0x01});
        EXPECT_EQ(cpu.s_.cc, H | I | N | carry); // Low-byte borrow does not set V.
    }
}

TEST_F(CpuRegression, CpxReadsAllMemoryAddressingModes)
{
    for (uint8_t opcode : {0x9c, 0xac, 0xbc})
    {
        cpu.s_.x = 0x2000;
        cpu.s_.cc = H | I | C | N | V;
        bus.memory[0x20] = bus.memory[0x2001] = 0x20;
        bus.memory[0x21] = bus.memory[0x2002] = 0;
        if (opcode == 0x9c)
            instruction({opcode, 0x20});
        else if (opcode == 0xac)
            instruction({opcode, 1});
        else
            instruction({opcode, 0x20, 1});
        EXPECT_EQ(cpu.s_.x, 0x2000);
        EXPECT_EQ(cpu.s_.cc, H | I | C | Z);
        EXPECT_EQ(cpu.s_.pc, opcode == 0xbc ? 0x1003 : 0x1002);
    }
}

TEST_F(CpuRegression, SwiStacksStateAndRtiRestoresIt)
{
    cpu.s_ = {0x12, 0x34, 0x5678, 0x0200, 0, H | C};
    bus.memory[0xfffa] = 0x30;
    bus.memory[0xfffb] = 0x00;
    bus.memory[0x3000] = 0x3b;
    instruction({0x3f});
    EXPECT_EQ(cpu.s_.pc, 0x3000);
    EXPECT_EQ(cpu.s_.sp, 0x01f9);
    EXPECT_EQ(cpu.s_.cc, H | C | I);
    EXPECT_EQ(bus.memory[0x200], 0x01);
    EXPECT_EQ(bus.memory[0x1ff], 0x10);
    EXPECT_EQ(bus.memory[0x1fe], 0x78);
    EXPECT_EQ(bus.memory[0x1fd], 0x56);
    EXPECT_EQ(bus.memory[0x1fc], 0x12);
    EXPECT_EQ(bus.memory[0x1fb], 0x34);
    EXPECT_EQ(bus.memory[0x1fa], H | C);
    cpu.step();
    EXPECT_EQ(cpu.s_.pc, 0x1001);
    EXPECT_EQ(cpu.s_.sp, 0x0200);
    EXPECT_EQ(cpu.s_.a, 0x12);
    EXPECT_EQ(cpu.s_.b, 0x34);
    EXPECT_EQ(cpu.s_.x, 0x5678);
    EXPECT_EQ(cpu.s_.cc, H | C);
}
} // namespace
