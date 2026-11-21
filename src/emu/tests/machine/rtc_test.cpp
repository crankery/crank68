#include <gtest/gtest.h>
#include <ctime>
#include "machine/machine.h"

TEST(RtcTest, ReadsHostDateAsRp5c01aNibbles)
{
    auto machine = Machine::create_default();
    const std::time_t before = std::time(nullptr);
    auto reg = [&](uint8_t address) {
        machine.write8(0xe070, address);
        return machine.read8(0xe071);
    };
    machine.write8(0xe070, 0xd);
    machine.write8(0xe071, 8);
    ASSERT_EQ(machine.read8(0xe071), 8);
    const unsigned month = reg(0xa)*10 + reg(9);
    const unsigned day = reg(8)*10 + reg(7);
    const unsigned year = reg(0xc)*10 + reg(0xb);
    const std::time_t after = std::time(nullptr);
    auto matches = [&](std::time_t instant) {
        std::tm local{};
        localtime_r(&instant, &local);
        return month == unsigned(local.tm_mon+1) &&
               day == unsigned(local.tm_mday) &&
               year == unsigned((local.tm_year+1900)%100);
    };
    EXPECT_TRUE(matches(before) || matches(after));
    machine.write8(0xe070, 9);
    machine.write8(0xe071, 15); // Host calendar is read-only.
    EXPECT_EQ(machine.read8(0xe071), month%10);
    machine.write8(0xe070, 0xd);
    machine.write8(0xe071, 10); // RAM bank 10.
    machine.write8(0xe070, 2);
    machine.write8(0xe071, 0xb);
    EXPECT_EQ(machine.read8(0xe071), 0xb);
}
