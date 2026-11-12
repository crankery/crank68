#include "sdDirect.h"

#include <stdexcept>

DirectSdStorage::DirectSdStorage(const std::string &path)
{
    file_ = std::fopen(path.c_str(), "r+b");
    if (!file_)
        throw std::runtime_error("Cannot open SD image for read/write: " + path);
    if (std::fseek(file_, 0, SEEK_END) != 0 ||
        std::ftell(file_) != long(sdbridge::ImageBytes))
    {
        std::fclose(file_);
        file_ = nullptr;
        throw std::runtime_error("SD image must be exactly 1 MiB: " + path);
    }
}

DirectSdStorage::~DirectSdStorage()
{
    if (file_) std::fclose(file_);
}

sdbridge::Status DirectSdStorage::fail()
{
    status_ = sdbridge::Status::IoError;
    return status_;
}

sdbridge::Status DirectSdStorage::read(uint32_t offset, uint8_t *buffer)
{
    if (status_ != sdbridge::Status::Ok) return status_;
    if (offset > sdbridge::ImageBytes - sdbridge::SectorBytes)
        return sdbridge::Status::BadAddress;
    if (std::fseek(file_, long(offset), SEEK_SET) != 0 ||
        std::fread(buffer, 1, sdbridge::SectorBytes, file_) != sdbridge::SectorBytes)
        return fail();
    return sdbridge::Status::Ok;
}

sdbridge::Status DirectSdStorage::write(uint32_t offset, const uint8_t *buffer)
{
    if (status_ != sdbridge::Status::Ok) return status_;
    if (offset > sdbridge::ImageBytes - sdbridge::SectorBytes)
        return sdbridge::Status::BadAddress;
    if (std::fseek(file_, long(offset), SEEK_SET) != 0 ||
        std::fwrite(buffer, 1, sdbridge::SectorBytes, file_) != sdbridge::SectorBytes ||
        std::fflush(file_) != 0)
        return fail();
    return sdbridge::Status::Ok;
}

sdbridge::Status DirectSdStorage::sync()
{
    if (status_ != sdbridge::Status::Ok) return status_;
    return std::fflush(file_) == 0 ? sdbridge::Status::Ok : fail();
}

SdDirect::SdDirect(const std::string &image)
    : MemoryIODevice(0x8, 0x0, 2), storage_(image), engine_(storage_),
      link_(engine_, *this)
{
    link_.begin();
}

uint8_t SdDirect::in(uint8_t port)
{
    if (port == 0)
    {
        const uint8_t value = status_;
        ++clock_;
        link_.poll();
        return value;
    }
    if (port == 1)
    {
        pending_ |= DataReadPending;
        return data_;
    }
    return 0xff;
}

void SdDirect::out(uint8_t port, uint8_t value)
{
    if (port == 0)
    {
        command_ = value;
        pending_ |= CommandPending;
    }
    else if (port == 1)
    {
        input_ = value;
        pending_ |= DataWritePending;
    }
}
