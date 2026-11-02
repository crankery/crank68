// tests/machine/Machine_smoke_test.cpp
#include <gtest/gtest.h>

#include "machine/machine.h"

TEST(MachineSmokeTest, CanConstructSystemUnderTest)
{
    auto sut = Machine::create_default();

    EXPECT_TRUE(true);
}