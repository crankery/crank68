#include "protocol.h"
#include "link.h"
#include <algorithm>
#include <array>
#include <cstdlib>
#include <iostream>
#include <stdexcept>
#include <vector>
using namespace sdbridge;
static void require(bool ok, const char *message)
{
    if (!ok)
        throw std::runtime_error(message);
}

struct Store
{
    std::vector<uint8_t> disk = std::vector<uint8_t>(ImageBytes);
    Status state = Status::Ok, nextRead = Status::Ok, nextWrite = Status::Ok, nextSync = Status::Ok;
    unsigned reads = 0, writes = 0, syncs = 0;
    uint32_t lastOffset = 0;
    Status status() const
    {
        return state;
    }

    Status read(uint32_t at, uint8_t *buffer)
    {
        ++reads;
        lastOffset = at;
        if (state != Status::Ok)
            return state;
        if (nextRead != Status::Ok)
            return nextRead;
        require(at <= ImageBytes - SectorBytes, "Read escaped disk");
        std::copy_n(disk.begin() + at, SectorBytes, buffer);
        return Status::Ok;
    }

    Status write(uint32_t at, const uint8_t *buffer)
    {
        ++writes;
        lastOffset = at;
        if (state != Status::Ok)
            return state;
        if (nextWrite != Status::Ok)
            return nextWrite;
        require(at <= ImageBytes - SectorBytes, "Write escaped disk");
        std::copy_n(buffer, SectorBytes, disk.begin() + at);
        return Status::Ok;
    }

    Status sync()
    {
        ++syncs;
        return state == Status::Ok ? nextSync : state;
    }
};

static std::vector<uint8_t> collect(Engine<Store> &engine)
{
    std::vector<uint8_t> bytes;
    uint8_t value;
    while (engine.responseByte(value))
    {
        uint8_t same = 0;
        require(engine.responseByte(same) && same == value, "Peek consumed response");
        bytes.push_back(value);
        require(engine.acknowledgeResponse(), "Response ACK rejected");
    }

    return bytes;
}

static void request(Engine<Store> &e, Command cmd, uint8_t track = 0, uint8_t sector = 0)
{
    for (auto c : {uint8_t(0xa5), uint8_t(0x5a), static_cast<uint8_t>(cmd), track, sector})
        require(e.receive(c), "Request refused");
}

struct IO
{
    uint32_t clock = 0;
    uint8_t incoming = 0, outgoing = 0;
    unsigned inputAcks = 0, publications = 0, recoveries = 0;
    bool ready = false;
    uint32_t now() const
    {
        return clock;
    }

    uint8_t receiveByte()
    {
        return incoming;
    }

    void acknowledgeReceive()
    {
        ++inputAcks;
    }

    void publishByte(uint8_t b)
    {
        require(!ready, "Overwrote an unacknowledged output byte");
        outgoing = b;
        ready = true;
        ++publications;
    }

    void withdrawByte()
    {
        ready = false;
    }

    void idle()
    {
        ready = false;
        ++recoveries;
    }
};

int main()
{
    try
    {
        Store store;
        Engine<Store> e(store);
        require(sizeof(e) < 320, "Engine staging memory grew unexpectedly");
        require(fileOffset(0, 1) == 0 && fileOffset(127, 32) == ImageBytes - 256,
                "32-bit sector addressing");
        for (unsigned track = 0; track < 256; ++track)
            for (unsigned sector = 0; sector < 256; ++sector)
                require(validAddress(track, sector) == (track < 128 && sector >= 1 && sector <= 32),
                        "Geometry validation");
        request(e, Command::Info);
        require(!e.receive(0xa5), "Accepted input during response");
        require(collect(e) == std::vector<uint8_t>({0, 2, 128, 32, 0, 1}), "INFO response");
        for (Status state : {Status::Ok, Status::NoCard, Status::NoFilesystem, Status::NoImage,
                             Status::BadImage, Status::IoError})
        {
            store.state = state;
            request(e, Command::Status);
            require(collect(e) == std::vector<uint8_t>({static_cast<uint8_t>(state)}),
                    "STATUS response");
        }

        store.state = Status::Ok;
        std::array<uint8_t, 256> payload{};
        for (unsigned n = 0; n < 256; ++n)
            payload[n] = n;
        for (auto ts : {std::pair<uint8_t, uint8_t>{0, 1}, {0, 2}, {0, 16}, {0, 17}, {63, 32}, {64, 1}, {127, 32}})
        {
            auto expected = store.disk;
            const auto at = fileOffset(ts.first, ts.second);
            std::copy(payload.begin(), payload.end(), expected.begin() + at);
            request(e, Command::Write, ts.first, ts.second);
            const auto before = store.writes;
            for (unsigned n = 0; n < 255; ++n)
                require(e.receive(payload[n]), "Payload refused");
            uint8_t b;
            require(store.writes == before && !e.responseByte(b),
                    "Write happened before full sector");
            require(e.receive(payload[255]) && store.writes == before && !e.responseByte(b),
                    "Payload committed before checksum");
            require(e.receive(0x7f) && store.writes == before && !e.responseByte(b),
                    "Partial checksum committed a write");
            require(e.receive(0x80) && store.writes == before + 1,
                    "Checksummed write not committed before response");
            require(collect(e) == std::vector<uint8_t>({0}) && store.disk == expected,
                    "Sector overwrite changed other bytes");
            request(e, Command::Read, ts.first, ts.second);
            auto response = collect(e);
            require(response.size() == 259 && response[0] == 0 &&
                        std::equal(payload.begin(), payload.end(), response.begin() + 1) &&
                        response[257] == 0x7f && response[258] == 0x80,
                    "Read payload/order");
        }

        for (auto ts : {std::pair<uint8_t, uint8_t>{128, 1}, {255, 16}, {0, 0}, {0, 33}})
        {
            const auto reads = store.reads, writes = store.writes;
            request(e, Command::Read, ts.first, ts.second);
            require(collect(e) == std::vector<uint8_t>({5}), "Invalid READ address");
            request(e, Command::Write, ts.first, ts.second);
            for (auto b : payload)
                require(e.receive(b), "Invalid WRITE payload not drained");
            e.receive(0x7f);
            e.receive(0x80);
            require(collect(e) == std::vector<uint8_t>({5}) && store.reads == reads &&
                        store.writes == writes,
                    "Invalid address touched storage");
        }

        store.nextRead = Status::IoError;
        request(e, Command::Read, 0, 1);
        require(collect(e) == std::vector<uint8_t>({6}), "Read error concealed");
        store.nextRead = Status::Ok;
        store.nextWrite = Status::IoError;
        request(e, Command::Write, 0, 1);
        for (auto b : payload)
            e.receive(b);
        e.receive(0x7f);
        e.receive(0x80);
        require(collect(e) == std::vector<uint8_t>({6}), "Write/sync error concealed");
        store.nextWrite = Status::Ok;
        store.nextSync = Status::IoError;
        request(e, Command::Sync);
        require(collect(e) == std::vector<uint8_t>({6}), "Sync error concealed");
        request(e, static_cast<Command>(0xee));
        require(collect(e) == std::vector<uint8_t>({7}), "Unknown command");
        request(e, Command::Info, 1, 0);
        require(collect(e) == std::vector<uint8_t>({5}), "Reserved address bytes accepted");
        e.receive(0);
        e.receive(0xa5);
        e.receive(0xa5);
        e.receive(0x5a);
        e.receive(0);
        e.receive(0);
        e.receive(0);
        require(collect(e) == std::vector<uint8_t>({0, 2, 128, 32, 0, 1}),
                "Header resynchronization");
        // Known vectors and both checksum bytes; all one-byte payload corruptions
        // must reject the write without invoking storage or changing the image.
        require(sectorChecksum(payload.data()) == 0x7f80, "Ascending-byte checksum vector");
        std::array<uint8_t, 256> zeros{}, ones;
        ones.fill(0xff);
        require(sectorChecksum(zeros.data()) == 0 && sectorChecksum(ones.data()) == 0xff00,
                "Checksum zero/carry vectors");
        auto rejected = [&](const std::array<uint8_t, 256> &data, uint8_t hi, uint8_t lo)
        {
            const auto before = store.disk;
            const auto writes = store.writes;
            request(e, Command::Write, 0, 1);
            for (auto b : data)
                e.receive(b);
            e.receive(hi);
            e.receive(lo);
            require(collect(e) == std::vector<uint8_t>({8}) && store.writes == writes &&
                        store.disk == before,
                    "Bad checksum reached storage");
        };

        rejected(payload, 0x7e, 0x80);
        rejected(payload, 0x7f, 0x81);
        rejected(payload, 0x80, 0x7f);
        for (unsigned n = 0; n < 256; ++n)
        {
            auto corrupt = payload;
            corrupt[n] ^= 1;
            rejected(corrupt, 0x7f, 0x80);
        }

        for (const auto &data : {zeros, ones})
        {
            const uint16_t sum = data[0] ? 0xff00 : 0;
            request(e, Command::Write, 127, 32);
            for (auto b : data)
                e.receive(b);
            e.receive(sum >> 8);
            e.receive(sum);
            require(collect(e) == std::vector<uint8_t>({0}),
                    "Checksum recovery/known-vector write failed");
            request(e, Command::Read, 127, 32);
            const auto response = collect(e);
            require(response.size() == 259 && response[257] == uint8_t(sum >> 8) &&
                        response[258] == uint8_t(sum),
                    "READ checksum byte order");
        }

        // A sector plus only one checksum byte is still incomplete and disposable.
        const auto beforePartial = store.disk;
        const auto partialWrites = store.writes;
        request(e, Command::Write, 0, 1);
        for (auto b : payload)
            e.receive(b);
        e.receive(0x7f);
        e.reset();
        require(store.writes == partialWrites && store.disk == beforePartial,
                "Partial checksum wrote data");
        const auto writes = store.writes;
        request(e, Command::Write, 0, 1);
        for (unsigned n = 0; n < 250; ++n)
            e.receive(0xa5);
        e.reset();
        require(store.writes == writes && e.idle(), "Aborted sector wrote partial data");
        IO io;
        Link<Engine<Store>, IO> link(e, io);
        link.begin();
        auto input = [&](uint8_t b)
        {
            io.incoming = b;
            link.poll(ReceiveEvent);
        };

        for (uint8_t b : {0xa5, 0x5a, 0, 0, 0})
            input(b);
        require(io.inputAcks == 5 && io.ready && io.outgoing == 0,
                "Link request acknowledgment/publication");
        const auto published = io.publications;
        link.poll(0);
        require(io.publications == published, "Response advanced without host ACK");
        for (unsigned n = 0; n < 5; ++n)
            link.poll(ConsumeEvent);
        require(io.ready && io.outgoing == 1, "INFO bytes not serialized");
        // Final response ACK and first byte of next request may share an ISR batch.
        io.incoming = 0xa5;
        link.poll(ConsumeEvent | ReceiveEvent);
        require(!io.ready && !e.idle() && io.inputAcks == 6, "Back-to-back transaction race");
        input(0x5a);
        input(1);
        input(0);
        input(0);
        require(io.ready && io.outgoing == 0, "Second request response");
        io.clock += LinkTimeoutMs + 1;
        link.poll(0);
        require(e.idle() && !io.ready, "Response timeout failed to isolate/reset link");
        input(0xa5);
        io.clock += LinkTimeoutMs + 1;
        link.poll(0);
        require(e.idle(), "Partial request timeout");
        const auto recoveries = io.recoveries;
        link.poll(ConsumeEvent);
        require(io.recoveries == recoveries + 1, "Stray ACK accepted");
        input(0xa5);
        link.poll(OverrunEvent);
        require(e.idle(), "ISR overrun did not recover");
        // A host stall after all data and one checksum byte must not commit.
        const auto beforeTimeout = store.disk;
        const auto writesBeforeTimeout = store.writes;
        for (uint8_t b : {0xa5, 0x5a, 0x11, 0, 1})
            input(b);
        for (auto b : payload)
            input(b);
        input(0x7f);
        require(!io.ready && store.writes == writesBeforeTimeout,
                "Link published/committed before checksum completion");
        io.clock += LinkTimeoutMs + 1;
        link.poll(0);
        require(e.idle() && !io.ready && store.disk == beforeTimeout,
                "Checksum timeout wrote partial sector");
        // Millisecond counter rollover must not immediately time out a valid frame.
        io.clock = 0xfffffff0;
        link.begin();
        input(0xa5);
        io.clock = 10;
        link.poll(0);
        require(!e.idle(), "Timer rollover broke timeout");
        std::cout
            << "Protocol/link tests passed: framing, full-byte sectors, checksums, geometry, errors, ACK ordering, backpressure, timeouts and rollover.\n";
        return EXIT_SUCCESS;
    }

    catch (const std::exception &e)
    {
        std::cerr << e.what() << '\n';
        return EXIT_FAILURE;
    }
}
