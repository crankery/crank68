#pragma once

#include <cstdio>
#include <string>

#include "memoryIODevice.h"
#include "../../../instore_sd/firmware/instore_sd/src/protocol.h"
#include "../../../instore_sd/firmware/instore_sd/src/direct_link.h"

class DirectSdStorage
{
public:
    explicit DirectSdStorage(const std::string &path);
    ~DirectSdStorage();
    DirectSdStorage(const DirectSdStorage &) = delete;
    DirectSdStorage &operator=(const DirectSdStorage &) = delete;
    sdbridge::Status status() const { return status_; }
    sdbridge::Status read(uint32_t offset, uint8_t *buffer);
    sdbridge::Status write(uint32_t offset, const uint8_t *buffer);
    sdbridge::Status sync();
private:
    sdbridge::Status fail();
    FILE *file_ = nullptr;
    sdbridge::Status status_ = sdbridge::Status::Ok;
};

// Models the Instore latches and pending flags at $E080/$E081. A status read
// returns the currently staged byte, then lets the AVR process one event.
class SdDirect : public MemoryIODevice
{
public:
    explicit SdDirect(const std::string &image);
    uint8_t in(uint8_t port) override;
    void out(uint8_t port, uint8_t value) override;
    char *name() override { return name_; }

    static const uint8_t CommandPending = 1, DataWritePending = 2, DataReadPending = 4;
    uint8_t pending() const { return pending_; }
    uint8_t takeCommand() { pending_ &= ~CommandPending; return command_; }
    uint8_t takeDataWrite() { pending_ &= ~DataWritePending; return input_; }
    void clearDataRead() { pending_ &= ~DataReadPending; }
    void clearAll() { pending_ = 0; }
    void stageData(uint8_t value) { data_ = value; }
    void stageStatus(uint8_t value) { status_ = value; }
    uint32_t now() const { return clock_; }
private:
    char name_[16] = "sd-direct";
    DirectSdStorage storage_;
    sdbridge::Engine<DirectSdStorage> engine_;
    sdbridge::DirectLink<sdbridge::Engine<DirectSdStorage>, SdDirect> link_;
    uint8_t pending_ = 0, command_ = 0, input_ = 0, data_ = 0, status_ = 0;
    uint32_t clock_ = 0;
};
