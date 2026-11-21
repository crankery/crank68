#include <cassert>
#include <cstdint>
#include <vector>
#include "protocol.h"
#include "direct_link.h"

struct Storage
{
    sdbridge::Status state = sdbridge::Status::Ok;
    uint8_t disk[sdbridge::SectorBytes] = {};
    unsigned reads = 0, writes = 0;
    uint32_t lastOffset = 0;
    sdbridge::Status status() const { return state; }
    sdbridge::Status read(uint32_t offset, uint8_t *buffer)
    {
        ++reads; lastOffset = offset;
        for (unsigned n = 0; n < sdbridge::SectorBytes; ++n) buffer[n] = disk[n];
        return state;
    }
    sdbridge::Status write(uint32_t offset, const uint8_t *buffer)
    {
        ++writes; lastOffset = offset;
        for (unsigned n = 0; n < sdbridge::SectorBytes; ++n) disk[n] = buffer[n];
        return state;
    }
    sdbridge::Status sync() { return state; }
};

struct IO
{
    static const uint8_t CommandPending = 1, DataWritePending = 2, DataReadPending = 4;
    uint8_t flags = 0, command = 0, input = 0, data = 0, status = 0;
    uint32_t clock = 0;
    std::vector<uint8_t> statuses;
    uint8_t pending() const { return flags; }
    uint8_t takeCommand() { flags &= ~CommandPending; return command; }
    uint8_t takeDataWrite() { flags &= ~DataWritePending; return input; }
    void clearDataRead() { flags &= ~DataReadPending; }
    void clearAll() { flags = 0; }
    void stageData(uint8_t value) { data = value; }
    void stageStatus(uint8_t value) { status = value; statuses.push_back(value); }
    uint32_t now() const { return clock; }
};

int main()
{
    Storage store;
    sdbridge::Engine<Storage> engine(store);
    IO io;
    sdbridge::DirectLink<sdbridge::Engine<Storage>, IO> link(engine, io);
    link.begin();
    using namespace sdbridge;
    assert(io.status & StatusBit::RxSpace);
    assert(io.status & StatusBit::MediaReady);
    assert(!(io.status & StatusBit::TxValid));

    auto sendCommand = [&](uint8_t value) {
        assert(io.status & StatusBit::RxSpace);
        const uint8_t before = io.status & StatusBit::RxSequence;
        io.command = value; io.flags |= IO::CommandPending;
        // The status latch is stale until the AVR services the pending FF.
        assert((io.status & StatusBit::RxSequence) == before);
        link.poll();
        assert(!(io.flags & IO::CommandPending));
        assert((io.status & StatusBit::RxSequence) != before);
        assert((io.statuses[io.statuses.size() - 2] & StatusBit::RxSequence) == before);
    };
    auto sendData = [&](uint8_t value) {
        assert(io.status & StatusBit::RxSpace);
        const uint8_t before = io.status & StatusBit::RxSequence;
        io.input = value; io.flags |= IO::DataWritePending;
        link.poll();
        assert(!(io.flags & IO::DataWritePending));
        assert((io.status & StatusBit::RxSequence) != before);
        assert((io.statuses[io.statuses.size() - 2] & StatusBit::RxSequence) == before);
    };
    auto receive = [&]() -> uint8_t {
        assert(io.status & StatusBit::TxValid);
        const uint8_t before = io.status & StatusBit::TxSequence;
        const uint8_t value = io.data;
        io.flags |= IO::DataReadPending;
        link.poll();
        assert(!(io.flags & IO::DataReadPending));
        assert((io.status & StatusBit::TxSequence) != before);
        assert((io.statuses[io.statuses.size() - 2] & StatusBit::TxSequence) == before);
        return value;
    };

    sendCommand(uint8_t(Command::Info));
    assert(!(io.status & StatusBit::RxSpace));
    for (uint8_t expected : {uint8_t(0),uint8_t(3),uint8_t(128),uint8_t(32),uint8_t(0),uint8_t(1)})
        assert(receive() == expected);
    assert(io.status & StatusBit::RxSpace);
    assert(!(io.status & StatusBit::TxValid));

    for (unsigned n = 0; n < 256; ++n) store.disk[n] = uint8_t(n);
    sendCommand(uint8_t(Command::Read));
    sendData(2); sendData(3);
    assert(store.reads == 1 && store.lastOffset == (2 * 32 + 2) * 256);
    assert(receive() == 0);
    for (unsigned n = 0; n < 256; ++n) assert(receive() == uint8_t(n));
    assert(receive() == 0x7f);
    assert(receive() == 0x80);
    assert(io.status & StatusBit::RxSpace);

    sendCommand(uint8_t(Command::Write));
    sendData(1); sendData(1);
    for (unsigned n = 0; n < 256; ++n) sendData(uint8_t(255 - n));
    sendData(0x7f); sendData(0x80);
    assert(store.writes == 1 && store.lastOffset == 32 * 256);
    assert(receive() == 0);
    for (unsigned n = 0; n < 256; ++n) assert(store.disk[n] == uint8_t(255 - n));

    sendCommand(uint8_t(Command::Write));
    sendData(0); sendData(1);
    for (unsigned n = 0; n < 256; ++n) sendData(0);
    sendData(0); sendData(1); // Wrong checksum; no card write.
    assert(receive() == uint8_t(Status::BadChecksum));
    assert(store.writes == 1);
    assert(io.status & StatusBit::Error);

    sendCommand(uint8_t(Command::Status));
    assert(!(io.status & StatusBit::Error));
    assert(receive() == 0);
    sendCommand(0xff);
    assert(receive() == uint8_t(Status::BadCommand));
    assert(io.status & StatusBit::RxSpace);

    sendCommand(uint8_t(Command::Read));
    sendData(128); sendData(1);
    assert(receive() == uint8_t(Status::BadAddress));
    assert(store.reads == 1);

    // A missing card still leaves the command register available for INFO.
    store.state = Status::NoCard;
    link.begin();
    assert(!(io.status & StatusBit::MediaReady));
    assert(io.status & StatusBit::RxSpace);
    sendCommand(uint8_t(Command::Status));
    assert(receive() == uint8_t(Status::NoCard));

    sendCommand(uint8_t(Command::Write));
    sendData(0); // Partial request times out and returns to command mode.
    io.clock += LinkTimeoutMs + 1;
    link.poll();
    assert(io.status & StatusBit::RxSpace);
    assert(io.status & StatusBit::Error);

    // Two outstanding hardware flags cannot be ordered; recover explicitly.
    io.flags = IO::CommandPending | IO::DataWritePending;
    link.poll();
    assert(io.flags == 0);
    assert(io.status & StatusBit::RxSpace);
    assert(io.status & StatusBit::Error);
}
