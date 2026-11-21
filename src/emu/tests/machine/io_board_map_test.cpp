#include <gtest/gtest.h>

#include "devices/memoryIO.h"

TEST(IoBoardMapTest, CorrectedSlotOneDecode)
{
    MemoryIO io;

    EXPECT_EQ(io.read(0xE010), 0x02);
    EXPECT_EQ(io.read(0xE014), 0x02);
    EXPECT_EQ(io.read(0xE018), 0);
    EXPECT_EQ(io.read(0xE01C), 0);
    EXPECT_EQ(io.read(0xE020), 0xFF);
    EXPECT_EQ(io.read(0xE028), 0xFF);

    io.write(0xE011, 'A');
    io.write(0xE015, 'B');
    EXPECT_EQ(io.acia_1_0_.terminalInAciaOut(), 'A');
    EXPECT_EQ(io.acia_1_1_.terminalInAciaOut(), 'B');
}
