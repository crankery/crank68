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
    std::vector<uint8_t> sound_writes;
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
        if (a==0xe060) { sound_writes.push_back(v); return; }
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
        bus.input = mode == "nmi" ? -1 : mode == "lowercase" ? 'f'
                  : mode == "continue-empty" ? 'C'
                  : mode == "help" ? '?'
                  : mode == "help-lower" ? 'h' : 'F';
        cpu.reset();
        if (mode == "help" || mode == "help-lower") {
            const auto command_loop=symbol("../roms/mikbug2/mikbug2.lst","contrl");
            for (unsigned step=0;step<2000000;++step) {
                cpu.step();
                if (bus.output.find("V    SET BREAK")!=std::string::npos &&
                    cpu.s_.pc==command_loop) {
                    require(bus.output.find("F  BOOT FLEX")!=std::string::npos &&
                            bus.output.find("L    LOAD S-RECORDS")!=std::string::npos &&
                            bus.output.find("C  CONTINUE")!=std::string::npos,
                            "MIKBUG help omitted a command group");
                    std::cout<<"MIKBUG help command passed: "<<mode<<".\n";
                    return 0;
                }
            }
            throw std::runtime_error("MIKBUG help did not return to prompt");
        }
        if (mode == "continue-empty") {
            const auto command_loop=symbol("../roms/mikbug2/mikbug2.lst","contrl");
            for (unsigned step=0;step<100000;++step) {
                cpu.step();
                if (bus.output.find("NO SAVED CONTEXT")!=std::string::npos &&
                    cpu.s_.pc==command_loop) {
                    std::cout<<"Fresh MIKBUG C command rejected safely.\n";
                    return 0;
                }
            }
            throw std::runtime_error("Fresh MIKBUG C did not return to prompt");
        }
        if (mode == "nmi") {
            const auto command_loop=symbol("../roms/mikbug2/mikbug2.lst","contrl");
            for (unsigned step=0;step<100000 && cpu.s_.pc!=command_loop;++step)
                cpu.step();
            require(cpu.s_.pc==command_loop,"MIKBUG did not reach its command loop");
            cpu.requestNmi();
            cpu.step();
            require(cpu.s_.pc==symbol("../roms/mikbug2/mikbug2.lst","powdwn"),
                    "NMI did not use the hardware vector");
            cpu.step(); // JMP nmi
            require(cpu.s_.pc==symbol("../roms/mikbug2/mikbug2.lst","nmi"),
                    "MIKBUG NMI vector did not reach its monitor handler");
            for (unsigned resume=0;resume<200000 && cpu.s_.pc!=command_loop;++resume)
                cpu.step();
            require(cpu.s_.pc==command_loop,
                    "MIKBUG NMI handler did not return to the command loop");
            require(bus.output.find("CC B A X P S")!=std::string::npos,
                    "MIKBUG NMI did not display the interrupted registers");
            std::cout<<"MIKBUG NMI direct vector passed.\n";
            return 0;
        }
        if (mode == "flex-nmi") {
            const std::string date="11,01,26\r";
            size_t next=0;
            for (unsigned step=0;step<2000000;++step) {
                if (cpu.s_.pc==inwait && bus.input<0 && next<date.size())
                    bus.input=uint8_t(date[next++]);
                if (next==date.size() && bus.output.find("+++")!=std::string::npos &&
                    cpu.s_.pc==inwait) {
                    cpu.requestNmi();
                    cpu.step();
                    require(cpu.s_.pc==symbol("../roms/mikbug2/mikbug2.lst","powdwn"),
                            "FLEX NMI did not use hardware vector");
                    cpu.step();
                    require(cpu.s_.pc==symbol("../roms/mikbug2/mikbug2.lst","nmi"),
                            "FLEX NMI did not reach MIKBUG handler");
                    const auto command_loop=symbol("../roms/mikbug2/mikbug2.lst","contrl");
                    for (unsigned resume=0;resume<200000 && cpu.s_.pc!=command_loop;++resume)
                        cpu.step();
                    require(cpu.s_.pc==command_loop,
                            "MIKBUG did not regain its command loop after FLEX NMI");
                    const auto first_banner=bus.output.find("MIKBUG 2/C68");
                    require(first_banner!=std::string::npos &&
                            bus.output.find("MIKBUG 2/C68",first_banner+1)!=std::string::npos,
                            "FLEX NMI did not reinitialize MIKBUG");
                    require(bus.ram[0xbe44]==0x11,
                            "FLEX NMI did not restore MIKBUG ACIA configuration");
                    bus.input='C';
                    for (unsigned resume=0;resume<100000;++resume) {
                        cpu.step();
                        if (bus.output.find("NO SAVED CONTEXT")!=std::string::npos &&
                            cpu.s_.pc==command_loop) {
                            std::cout<<"FLEX NMI returned to MIKBUG; C rejected safely.\n";
                            return 0;
                        }
                    }
                    throw std::runtime_error("C after FLEX NMI did not return to prompt");
                }
                cpu.step();
            }
            throw std::runtime_error("FLEX did not reach its prompt for NMI test");
        }
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
                std::ifstream sound_config("../roms/mikbug2/build/sound-board.cfg");
                int sound_revision=0;
                sound_config >> sound_revision;
                require(bool(sound_config) && (sound_revision==1 || sound_revision==2),
                        "Missing sound board revision");
                const std::vector<uint8_t> expected = sound_revision==2
                    ? std::vector<uint8_t>{0x9f,0xbf,0xdf,0xff,0x8c,0x11,0x92,0x9f}
                    : std::vector<uint8_t>{0xf9,0xfd,0xfb,0xff,0x31,0x88,0x49,0xf9};
                require(mode=="direct" ? bus.sound_writes.empty() : bus.sound_writes==expected,
                        "Unexpected MIKBUG startup sound writes");
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
