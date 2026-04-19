#include <gtest/gtest.h>

#include "machine/machine.h"

TEST(cpu_op_arth_tests, ldaa_imb)
{
    Machine m;

    m.write8(0x1000, 0x86);
    m.write8(0x1001, 0x42);

    m.cpu_.s_.pc = 0x1000;

    m.cpu_.step();

    EXPECT_EQ(m.cpu_.s_.a, 0x42);
}
