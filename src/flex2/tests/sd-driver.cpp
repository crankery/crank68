#include "flex_harness.h"
#include "../build/drive-config.h"
#include "../../instore_sd/firmware/instore_sd/src/protocol.h"
#include "../../instore_sd/firmware/instore_sd/src/direct_link.h"

// Test fixture: the direct register latches and pending flags connected to the
// real AVR protocol engine. Service an event after each status read so the
// 6800 must observe the sequence acknowledgment instead of stale status bits.
struct Storage
{
    std::vector<uint8_t> disk = std::vector<uint8_t>(sdbridge::ImageBytes);
    sdbridge::Status mounted = sdbridge::Status::Ok;
    unsigned writes = 0;
    sdbridge::Status status() const { return mounted; }
    sdbridge::Status read(uint32_t at, uint8_t *buffer)
    {
        if (mounted != sdbridge::Status::Ok) return mounted;
        std::copy_n(disk.begin() + at, 256, buffer);
        return mounted;
    }
    sdbridge::Status write(uint32_t at, const uint8_t *buffer)
    {
        if (mounted != sdbridge::Status::Ok) return mounted;
        ++writes;
        std::copy_n(buffer, 256, disk.begin() + at);
        return mounted;
    }
    sdbridge::Status sync() { return mounted; }
};

struct SdBus : Bus
{
    static const uint8_t CommandPending = 1, DataWritePending = 2, DataReadPending = 4;
    Storage storage;
    sdbridge::Engine<Storage> bridge{storage};
    uint8_t flags = 0, command = 0, input = 0, data = 0, status = 0;
    uint32_t clock = 0;
    bool disconnected = false, badReadSum = false, badWriteData = false, badInfo = false;
    unsigned responseIndex = 0, requestIndex = 0, opcode = 0, commandWrites = 0;
    sdbridge::DirectLink<sdbridge::Engine<Storage>, SdBus> link{bridge, *this};
    SdBus() { link.begin(); }

    uint8_t pending() const { return flags; }
    uint8_t takeCommand() { flags &= ~CommandPending; return command; }
    uint8_t takeDataWrite() { flags &= ~DataWritePending; return input; }
    void clearDataRead() { flags &= ~DataReadPending; ++responseIndex; }
    void clearAll() { flags = 0; }
    void stageData(uint8_t value)
    {
        data = value;
        if (badReadSum && opcode == 0x10 && responseIndex == 257) data ^= 1;
        if (badInfo && opcode == 0 && responseIndex == 1) data = 1;
    }
    void stageStatus(uint8_t value) { status = value; }
    uint32_t now() const { return clock; }

    uint8_t read8(uint16_t at) override
    {
        if (at == 0xe080)
        {
            const uint8_t value = status;
            if (!disconnected) { ++clock; link.poll(); }
            return value;
        }
        if (at == 0xe081)
        {
            flags |= DataReadPending;
            return data;
        }
        return Bus::read8(at);
    }
    void write8(uint16_t at, uint8_t value) override
    {
        if (at == 0xe080)
        {
            command = value;
            opcode = value;
            responseIndex = requestIndex = 0;
            ++commandWrites;
            flags |= CommandPending;
            return;
        }
        if (at == 0xe081)
        {
            input = value;
            if (badWriteData && opcode == 0x11 && requestIndex == 2) input ^= 1;
            ++requestIndex;
            flags |= DataWritePending;
            return;
        }
        Bus::write8(at, value);
    }
};

int main()
{
    try
    {
        SdBus bus;
        Cpu cpu(bus);
        const auto flex = file("build/c68flex.bin");
        std::copy(flex.begin(), flex.end(), bus.ram.begin() + 0xa100);
        require(symbol("build/c68flex.lst", "SDADAPTEREND") < 0xaa00, "SD adapters overlap FMEME");
        require(symbol("build/c68flex.lst", "C68FILECASEEND") < 0xaa00,
                "Filename case routine overlaps FMEME");
        const uint16_t fcb = 0x8000, buffer = 0x8400;
        const auto select = [&](uint8_t drive)
        {
            bus.ram[fcb + 3] = drive;
            call(bus, cpu, 0xbe8c, fcb);
        };

        const auto success = [&]()
        { require(cpu.s_.b == 0 && (cpu.s_.cc & 5) == 4, "Expected B=0/Z=1/C=0"); };
        const auto failure = [&]()
        { require(cpu.s_.b != 0 && (cpu.s_.cc & 5) == 1, "Expected B!=0/Z=0/C=1"); };
        const auto signature = bus.ram[0xf00c];
        bus.ram[0xf00c] = 0;
        select(SdDrive);
        failure();
        bus.ram[0xf00c] = signature;
        const auto romBefore = std::vector<uint8_t>(bus.ram.begin() + 0xe100, bus.ram.end());
        select(SdDrive);
        success();
        require(bus.commandWrites >= 2, "Direct-register INFO/STATUS exchange");
        const auto sram = bus.disk;
        for (auto address :
             {std::pair<uint8_t, uint8_t>{0, 1}, {0, 17}, {63, 32}, {64, 1}, {127, 32}})
        {
            for (unsigned i = 0; i < 256; ++i)
                bus.ram[buffer + i] = uint8_t(i + address.first + address.second);
            call(bus, cpu, 0xbe83, buffer, address.first, address.second);
            success();
            call(bus, cpu, 0xbe80, buffer + 256, address.first, address.second);
            success();
            require(std::equal(bus.ram.begin() + buffer, bus.ram.begin() + buffer + 256,
                               bus.ram.begin() + buffer + 256),
                    "SD round trip");
        }

        require(bus.disk == sram, "SD writes altered SRAM");
        const auto before = bus.storage.disk;
        for (auto address : {std::pair<uint8_t, uint8_t>{128, 1}, {0, 0}, {0, 33}})
        {
            call(bus, cpu, 0xbe83, buffer, address.first, address.second);
            failure();
        }

        bus.badWriteData = true;
        const auto writes = bus.storage.writes;
        call(bus, cpu, 0xbe83, buffer, 1, 1);
        failure();
        require(bus.storage.writes == writes && bus.storage.disk == before,
                "Corrupt WRITE committed");
        bus.badWriteData = false;
        bus.badReadSum = true;
        call(bus, cpu, 0xbe80, buffer, 1, 1);
        failure();
        require(cpu.s_.b == 8 && !(bus.status & sdbridge::StatusBit::TxValid), "READ checksum failure/ACK drain");
        bus.badReadSum = false;
        call(bus, cpu, 0xbe80, buffer, 1, 1);
        success();
        bus.badInfo = true;
        select(SdDrive);
        failure();
        require(!(bus.status & sdbridge::StatusBit::TxValid), "INFO mismatch left unconsumed bytes");
        bus.badInfo = false;
        bus.storage.mounted = sdbridge::Status::NoCard;
        select(SdDrive);
        failure();
        bus.storage.mounted = sdbridge::Status::Ok;
        select(Sram1Drive);
        success();
        bus.ram[fcb + 3] = SdDrive;
        call(bus, cpu, 0xbe8f, fcb);
        success();
        require(cpu.s_.x == fcb, "READY lost FCB pointer");
        call(bus, cpu, 0xbe80, buffer, 0, 3);
        success();
        require(std::equal(bus.ram.begin() + buffer, bus.ram.begin() + buffer + 256,
                           bus.disk.begin() + sram_drive_bytes + 512),
                "READY changed selected backend");
        select(Sram0Drive);
        success();
        call(bus, cpu, 0xbe80, buffer, 0, 3);
        success();
        require(std::equal(bus.ram.begin() + buffer, bus.ram.begin() + buffer + 256,
                           bus.disk.begin() + 512), "SRAM unit 0 mapping");
        select(Sram1Drive);
        success();
        call(bus, cpu, 0xbe80, buffer, 0, 3);
        success();
        require(std::equal(bus.ram.begin() + buffer, bus.ram.begin() + buffer + 256,
                           bus.disk.begin() + sram_drive_bytes + 512), "SRAM unit 1 mapping");
        select(3);
        failure();
        // Exercise the actual FMS allocator and file chains on the removable volume.
        bus.storage.disk = file("build/sd-test.dsk");
        require(bus.storage.disk.size() == sdbridge::ImageBytes, "SD test image size");
        call(bus, cpu, 0xb400, fcb);
        const auto prepare = [&]()
        {
            std::fill_n(bus.ram.begin() + fcb, 320, 0);
            bus.ram[fcb + 3] = SdDrive;
            const std::string name = "SDTEST";
            std::copy(name.begin(), name.end(), bus.ram.begin() + fcb + 4);
            bus.ram[fcb + 12] = 'B';
            bus.ram[fcb + 13] = 'I';
            bus.ram[fcb + 14] = 'N';
        };

        const auto fms = [&](uint8_t command, uint8_t value = 0)
        {
            bus.ram[fcb] = command;
            call(bus, cpu, 0xb406, fcb, value);
            require(bus.ram[fcb + 1] == 0, "SD FMS command " + std::to_string(command) +
                                               " failed: " + std::to_string(bus.ram[fcb + 1]));
            return cpu.s_.a;
        };

        const auto freeCount = [&]()
        { return unsigned(bus.storage.disk[545]) * 256 + bus.storage.disk[546]; };
        const auto initialFree = freeCount();
        prepare();
        fms(2);
        bus.ram[fcb + 59] = 255;
        for (unsigned i = 0; i < 1400; ++i)
            fms(0, uint8_t(i * 7));
        fms(4);
        require(freeCount() == initialFree - 6, "SD allocation count");
        prepare();
        fms(1);
        bus.ram[fcb + 59] = 255;
        for (unsigned i = 0; i < 1400; ++i)
            require(fms(0) == uint8_t(i * 7), "SD FMS file data changed");
        fms(4);
        prepare();
        fms(12);
        require(freeCount() == initialFree, "SD delete leaked sectors");
        require(std::equal(romBefore.begin(), romBefore.end(), bus.ram.begin() + 0xe100),
                "SD driver wrote into ROM");
        bus.disconnected = true;
        select(SdDrive);
        failure();
        std::cout
            << "6800 SD driver: sector boundaries, checksums, INFO, missing media, timeout, "
               "direct registers, FMS create/read/write/delete and SRAM selection isolation passed.\n";
    }

    catch (const std::exception &error)
    {
        std::cerr << error.what() << '\n';
        return 1;
    }
}
