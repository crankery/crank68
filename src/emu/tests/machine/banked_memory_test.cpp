#include <gtest/gtest.h>
#include <filesystem>
#include <fstream>
#include <unistd.h>

#include "machine/machine.h"

TEST(BankedMemoryTest, EveryPageIsIndependentAndAccessibleFromEitherWindow)
{
    auto machine = Machine::create_default();
    for (unsigned page = 0; page < 256; ++page)
    {
        machine.write8(0xe002, page);
        machine.write8(0xc000, page);
        machine.write8(0xcfff, page ^ 0xff);
    }
    for (unsigned page = 0; page < 256; ++page)
    {
        machine.write8(0xe003, page);
        EXPECT_EQ(machine.read8(0xd000), page);
        EXPECT_EQ(machine.read8(0xdfff), page ^ 0xff);
    }
    machine.write8(0xe002, 0x80);
    machine.write8(0xe003, 0x7f);
    machine.write8(0xc123, 0x42);
    machine.write8(0xd123, 0x99);
    EXPECT_EQ(machine.read8(0xc123), 0x42);
    machine.write8(0xe003, 0x80);
    EXPECT_EQ(machine.read8(0xd123), 0x42);
    machine.write8(0xd123, 0x55);
    EXPECT_EQ(machine.read8(0xc123), 0x55);
    EXPECT_EQ(machine.read8(0xe002), 0xff);
    EXPECT_EQ(machine.read8(0xe003), 0xff);
}

TEST(BankedMemoryTest, StartsClearedAndLoaderDoesNotChangeLatches)
{
    auto machine = Machine::create_default();
    EXPECT_EQ(machine.read8(0xc000), 0);
    machine.write8(0xe002, 5);
    machine.load(0xe002, 6);
    machine.load(0xc000, 0x73);
    machine.write8(0xe003, 5);
    EXPECT_EQ(machine.read8(0xd000), 0x73);
    machine.write8(0xe000, 6); // old latch address is unconnected
    EXPECT_EQ(machine.read8(0xc000), 0x73);
}

TEST(BankedMemoryTest, ImageRoundTripAndInvalidLoadPreservesMemory)
{
    char filename[] = "/tmp/crank68-sram-XXXXXX";
    int fd = mkstemp(filename);
    ASSERT_GE(fd, 0);
    close(fd);
    struct Cleanup
    {
        const char *path;
        ~Cleanup() { std::filesystem::remove(path); }
    } cleanup{filename};
    auto machine = Machine::create_default();
    machine.write8(0xe002, 0xff);
    machine.write8(0xcfff, 0xa5);
    machine.banked_memory_->saveImage(filename);
    EXPECT_EQ(std::filesystem::file_size(filename), BankedMemory::ImageSize);
    auto restored = Machine::create_default();
    restored.banked_memory_->loadImage(filename);
    restored.write8(0xe003, 0xff);
    EXPECT_EQ(restored.read8(0xdfff), 0xa5);
    EXPECT_EQ(restored.read8(0xc000), 0);
    std::ofstream(filename, std::ios::binary | std::ios::app).put(0);
    EXPECT_THROW(restored.banked_memory_->loadImage(filename), std::runtime_error);
    EXPECT_EQ(restored.read8(0xdfff), 0xa5);
    std::ofstream(filename, std::ios::binary | std::ios::trunc).put(0);
    EXPECT_THROW(restored.banked_memory_->loadImage(filename), std::runtime_error);
    EXPECT_EQ(restored.read8(0xdfff), 0xa5);
}
