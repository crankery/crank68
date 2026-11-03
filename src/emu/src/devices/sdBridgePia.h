#pragma once

#include <cstdio>
#include <string>

#include "pia.h"
#include "../../../sd/firmware/sd_bridge/src/protocol.h"

class SdImageStorage
{
public:
    explicit SdImageStorage(const std::string &path);
    ~SdImageStorage();

    SdImageStorage(const SdImageStorage &) = delete;
    SdImageStorage &operator=(const SdImageStorage &) = delete;

    sdbridge::Status status() const;
    sdbridge::Status read(uint32_t offset, uint8_t *buffer);
    sdbridge::Status write(uint32_t offset, const uint8_t *buffer);
    sdbridge::Status sync();

private:
    sdbridge::Status fail();

    FILE *file_ = nullptr;
    sdbridge::Status status_ = sdbridge::Status::Ok;
};

class SdBridgePia : public Pia
{
public:
    explicit SdBridgePia(const std::string &image);

    uint8_t in(uint8_t port) override;
    void out(uint8_t port, uint8_t value) override;

private:
    void publish();

    SdImageStorage storage_;
    sdbridge::Engine<SdImageStorage> engine_;
    uint8_t cra_ = 0, crb_ = 0, pa_ = 0, pb_ = 0, ddra_ = 0, ddrb_ = 0;
    bool receive_flag_ = false, ready_flag_ = false, published_ = false;
};
