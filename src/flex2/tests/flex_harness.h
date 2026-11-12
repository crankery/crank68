#pragma once
// Execute the actual boot sector and generated system with the sibling 6800 CPU.
#include <algorithm>
#include <array>
#include <cstdint>
#include <fstream>
#include <iostream>
#include <iterator>
#include <regex>
#include <stdexcept>
#include <string>
#include <vector>
#include "cpu/cpu.h"

static void require(bool ok, const std::string &why) {
    if (!ok) throw std::runtime_error(why);
}
static std::vector<uint8_t> file(const char *name) {
    std::ifstream f(name, std::ios::binary);
    require(bool(f), std::string("Cannot open ")+name);
    return {std::istreambuf_iterator<char>(f), {}};
}
static uint16_t symbol(const char *listing, const std::string &name) {
    std::ifstream f(listing);
    std::string line;
    std::regex pattern("^"+name+" +[AS]:([0-9A-Fa-f]{4})$");
    std::smatch match;
    while (std::getline(f,line)) if (std::regex_match(line,match,pattern))
        return std::stoul(match[1],nullptr,16);
    throw std::runtime_error("Missing symbol "+name);
}
constexpr unsigned sram_drives=2, sram_tracks=128, sram_drive_bytes=512*1024;
struct Bus : IBus {
    std::array<uint8_t,65536> ram{};
    std::vector<uint8_t> disk = file("build/flex2.dsk");
    Bus() {
        const auto rom=file("../roms/mikbug2/mikbug2.rom");
        require(rom.size()==8192,"MIKBUG ROM size");
        std::copy(rom.begin(),rom.end(),ram.begin()+0xe000);
    }
    uint8_t page=0;
    int input=-1;
    std::string output;
    std::vector<uint8_t> sound_writes;
    uint8_t read8(uint16_t a) override {
        if (a>=0xc000 && a<0xd000) return disk[size_t(page)*4096+(a&4095)];
        if (a==0xe010) return 2 | (input>=0 ? 1 : 0);
        if (a==0xe011) { require(input>=0,"Read empty ACIA"); auto c=input; input=-1; return c; }
        if (a==0xe080 || a==0xe081) return 0; // Unattached direct SD device.
        if (a>=0xe000 && a<0xe100) throw std::runtime_error("Unexpected I/O read "+std::to_string(a));
        return ram[a];
    }
    void write8(uint16_t a,uint8_t v) override {
        if (a>=0xc000 && a<0xd000) { disk[size_t(page)*4096+(a&4095)]=v; return; }
        if (a==0xe002) { page=v; return; }
        if (a==0xe011) { output+=char(v); return; }
        if (a==0xe060) { sound_writes.push_back(v); return; }
        if (a==0xe080 || a==0xe081) return;
        if (a>=0xe000 && a<0xe100) throw std::runtime_error("Unexpected I/O write "+std::to_string(a));
        ram[a]=v;
    }
};
static void call(Bus &bus, Cpu &cpu, uint16_t entry, uint16_t x, uint8_t a=0, uint8_t b=0) {
    cpu.s_.pc=entry; cpu.s_.x=x; cpu.s_.a=a; cpu.s_.b=b;
    cpu.s_.sp=0x9ffd; bus.ram[0x9ffe]=0x90; bus.ram[0x9fff]=0;
    for(unsigned n=0;n<20000000;++n) {
        if(cpu.s_.pc==0x9000) return;
        cpu.step();
    }
    throw std::runtime_error("Subroutine timed out");
}
