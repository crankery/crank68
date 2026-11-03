#include <gtest/gtest.h>

#include <array>
#include <filesystem>
#include <fstream>
#include <stdexcept>
#include <unistd.h>

#include "machine/machine.h"
#include "../../../sd/firmware/sd_bridge/src/protocol.h"

TEST(SdBridgeTest, PiaHandshakeReadsAndPersistsSectors)
{
    char filename[] = "/tmp/crank68-sd-XXXXXX";
    const int fd = mkstemp(filename);
    ASSERT_GE(fd, 0);
    ASSERT_EQ(ftruncate(fd, sdbridge::ImageBytes), 0);
    close(fd);
    struct Cleanup
    {
        const char *path;
        ~Cleanup() { std::filesystem::remove(path); }
    } cleanup{filename};

    auto machine = Machine::create_default();
    machine.memory_io_->attachSdImage(filename);
    machine.write8(0xe021, 0x3a);
    machine.write8(0xe023, 0x3a);
    machine.write8(0xe020, 0xff);
    machine.write8(0xe022, 0);
    machine.write8(0xe021, 0x3e);
    machine.write8(0xe023, 0x3e);
    EXPECT_EQ(machine.read8(0xe020), 0);
    EXPECT_EQ(machine.read8(0xe022), 0);

    const auto put = [&](uint8_t value)
    {
        machine.write8(0xe020, value);
        machine.write8(0xe021, 0x36);
        machine.write8(0xe021, 0x3e);
        EXPECT_NE(machine.read8(0xe021) & 0x80, 0);
        machine.read8(0xe020);
    };
    const auto get = [&]()
    {
        EXPECT_NE(machine.read8(0xe023) & 0x80, 0);
        const uint8_t value = machine.read8(0xe022);
        machine.write8(0xe023, 0x36);
        machine.write8(0xe023, 0x3e);
        return value;
    };
    const auto request = [&](uint8_t command, uint8_t track, uint8_t sector)
    {
        for (auto byte : {uint8_t(0xa5), uint8_t(0x5a), command, track, sector})
            put(byte);
    };

    request(0, 0, 0);
    for (auto byte : {uint8_t(0), uint8_t(2), uint8_t(128), uint8_t(32), uint8_t(0), uint8_t(1)})
        EXPECT_EQ(get(), byte);

    std::array<uint8_t, sdbridge::SectorBytes> payload{};
    for (unsigned i = 0; i < payload.size(); ++i)
        payload[i] = uint8_t(i ^ 0x5a);
    const auto checksum = sdbridge::sectorChecksum(payload.data());

    request(0x11, 127, 32);
    for (auto byte : payload)
        put(byte);
    put(uint8_t(checksum >> 8));
    put(uint8_t(checksum));
    EXPECT_EQ(get(), 0);

    request(0x10, 127, 32);
    EXPECT_EQ(get(), 0);
    for (auto byte : payload)
        EXPECT_EQ(get(), byte);
    EXPECT_EQ(get(), uint8_t(checksum >> 8));
    EXPECT_EQ(get(), uint8_t(checksum));

    request(0x11, 127, 32);
    for (auto byte : payload)
        put(byte ^ 0xff);
    put(0);
    put(0);
    EXPECT_EQ(get(), uint8_t(sdbridge::Status::BadChecksum));

    std::ifstream image(filename, std::ios::binary);
    image.seekg(sdbridge::ImageBytes - sdbridge::SectorBytes);
    for (auto byte : payload)
        EXPECT_EQ(image.get(), byte);
}

TEST(SdBridgeTest, RejectsMissingAndWrongSizedImages)
{
    auto machine = Machine::create_default();
    EXPECT_THROW(machine.memory_io_->attachSdImage("/tmp/crank68-sd-missing-image"), std::runtime_error);

    char filename[] = "/tmp/crank68-sd-small-XXXXXX";
    const int fd = mkstemp(filename);
    ASSERT_GE(fd, 0);
    close(fd);
    struct Cleanup
    {
        const char *path;
        ~Cleanup() { std::filesystem::remove(path); }
    } cleanup{filename};
    EXPECT_THROW(machine.memory_io_->attachSdImage(filename), std::runtime_error);
}
