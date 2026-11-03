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
struct Bus : IBus {
    std::array<uint8_t,65536> ram{};
    std::vector<uint8_t> disk = file("build/flex2.dsk");
    uint8_t page=0;
    int input=-1;
    std::string output;
    uint8_t read8(uint16_t a) override {
        if (a>=0xc000 && a<0xd000) return disk[size_t(page)*4096+(a&4095)];
        if (a==0xe010) return 2 | (input>=0 ? 1 : 0);
        if (a==0xe011) { require(input>=0,"Read empty ACIA"); auto c=input; input=-1; return c; }
        if (a>=0xe000 && a<0xe100) throw std::runtime_error("Unexpected I/O read "+std::to_string(a));
        return ram[a];
    }
    void write8(uint16_t a,uint8_t v) override {
        if (a>=0xc000 && a<0xd000) { disk[size_t(page)*4096+(a&4095)]=v; return; }
        if (a==0xe002) { page=v; return; }
        if (a==0xe010) return;
        if (a==0xe011) { output+=char(v); return; }
        if (a>=0xe000 && a<0xe100) throw std::runtime_error("Unexpected I/O write "+std::to_string(a));
        ram[a]=v;
    }
};
int main(int argc, char **argv) {
    Bus bus;
    Cpu cpu(bus);
    try {
        auto inwait=symbol("build/c68flex.lst","C68INW");
        auto basicin=symbol("build/msbasic.lst","INCH");
        auto rom=file("../roms/mikbug2/mikbug2.rom");
        require(rom.size()==8192,"ROM size");
        std::copy(rom.begin(),rom.end(),bus.ram.begin()+0xe000);
        bus.page=123;
        const std::string mode = argc > 1 ? argv[1] : "normal";
        bus.input = mode == "lowercase" ? 'f' : 'F';
        cpu.reset();
        if (mode == "direct") { bus.input=-1; cpu.s_.pc=0xffc0; }
        // Boot through the ROM; no FLEX code is preloaded into RAM.
        std::string keys="11,01,26\rMSBASIC\r\r\rN\rPRINT 2+2\r";
        size_t next=0;
        for (unsigned step=0;step<15000000;++step) {
            if ((cpu.s_.pc==inwait || cpu.s_.pc==basicin) && bus.input<0 && next<keys.size())
                bus.input=uint8_t(keys[next++]);
            cpu.step();
            if (bus.output.find("MITS ALTAIR 680 BASIC")!=std::string::npos &&
                bus.output.find(" 4 ")!=std::string::npos) {
                for(auto c:bus.output) if(c) std::cout<<c;
                std::cout<<"\nBoot, FLEX command loading, and BASIC arithmetic passed.\n";

                return 0;
            }
        }
        throw std::runtime_error("Timed out at PC="+std::to_string(cpu.s_.pc));
    } catch(const std::exception &e) {
        std::cerr<<bus.output<<"\n"<<e.what()<<" PC="<<std::hex<<cpu.s_.pc<<"\n";
        return 1;
    }
}
