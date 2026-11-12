#include <gtest/gtest.h>

#include <array>
#include <filesystem>
#include <fstream>
#include <stdexcept>
#include <unistd.h>

#include "machine/machine.h"
#include "../../../instore_sd/firmware/instore_sd/src/protocol.h"
#include "../../../instore_sd/firmware/instore_sd/src/direct_link.h"

TEST(SdBridgeTest, DirectRegistersReadAndPersistSectors)
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
    auto status = [&]() { return machine.read8(0xe080); };
    auto wait = [&](uint8_t bit, uint8_t previous)
    {
        for (unsigned n = 0; n < 1000; ++n)
            if ((status() & bit) != previous) return;
        FAIL() << "SD sequence acknowledgment timed out";
    };
    auto put = [&](uint16_t at, uint8_t value)
    {
        const uint8_t before = status();
        EXPECT_NE(before & sdbridge::StatusBit::RxSpace, 0);
        machine.write8(at, value);
        wait(sdbridge::StatusBit::RxSequence, before & sdbridge::StatusBit::RxSequence);
    };
    auto get = [&]()
    {
        const uint8_t before = status();
        EXPECT_NE(before & sdbridge::StatusBit::TxValid, 0);
        const uint8_t value = machine.read8(0xe081);
        wait(sdbridge::StatusBit::TxSequence, before & sdbridge::StatusBit::TxSequence);
        return value;
    };
    auto request = [&](uint8_t command, uint8_t track, uint8_t sector)
    {
        put(0xe080, command);
        put(0xe081, track);
        put(0xe081, sector);
    };

    put(0xe080, 0);
    for (auto byte : {uint8_t(0), uint8_t(3), uint8_t(128), uint8_t(32), uint8_t(0), uint8_t(1)})
        EXPECT_EQ(get(), byte);

    std::array<uint8_t, sdbridge::SectorBytes> payload{};
    for (unsigned i = 0; i < payload.size(); ++i)
        payload[i] = uint8_t(i ^ 0x5a);
    const auto checksum = sdbridge::sectorChecksum(payload.data());

    request(0x11, 127, 32);
    for (auto byte : payload) put(0xe081, byte);
    put(0xe081, uint8_t(checksum >> 8));
    put(0xe081, uint8_t(checksum));
    EXPECT_EQ(get(), 0);

    request(0x10, 127, 32);
    EXPECT_EQ(get(), 0);
    for (auto byte : payload) EXPECT_EQ(get(), byte);
    EXPECT_EQ(get(), uint8_t(checksum >> 8));
    EXPECT_EQ(get(), uint8_t(checksum));

    request(0x11, 127, 32);
    for (auto byte : payload) put(0xe081, byte ^ 0xff);
    put(0xe081, 0);
    put(0xe081, 0);
    EXPECT_EQ(get(), uint8_t(sdbridge::Status::BadChecksum));

    std::ifstream image(filename, std::ios::binary);
    image.seekg(sdbridge::ImageBytes - sdbridge::SectorBytes);
    for (auto byte : payload) EXPECT_EQ(image.get(), byte);
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
