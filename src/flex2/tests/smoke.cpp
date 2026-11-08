#include "flex_harness.h"

static void filesystem_test(Bus &bus, Cpu &cpu) {
    const uint16_t fcb=0x8000;
    auto prepare=[&](unsigned drive) {
        std::fill_n(bus.ram.begin()+fcb,320,0);
        bus.ram[fcb+3]=drive;
        const std::string name="SMOKE";
        std::copy(name.begin(),name.end(),bus.ram.begin()+fcb+4);
        bus.ram[fcb+12]='B'; bus.ram[fcb+13]='I'; bus.ram[fcb+14]='N';
    };
    auto fms=[&](uint8_t cmd,uint8_t value=0) {
        bus.ram[fcb]=cmd;
        call(bus,cpu,0xb406,fcb,value);
        require(bus.ram[fcb+1]==0,"FMS error "+std::to_string(bus.ram[fcb+1])+" drive="+std::to_string(bus.ram[fcb+3])+" cmd="+std::to_string(cmd));
        return cpu.s_.a;
    };
    auto free_count=[&](unsigned drive) {
        const auto offset=drive*sram_drive_bytes+2*256;
        return unsigned(bus.disk[offset+33])*256+bus.disk[offset+34];
    };
    std::array<unsigned,sram_drives> initial_free{};
    // Keep identically named files on both SRAM disks at once to catch aliasing.
    for(unsigned drive=0;drive<sram_drives;++drive) {
        initial_free[drive]=free_count(drive);
        prepare(drive); fms(2); bus.ram[fcb+59]=255;
        for(unsigned i=0;i<1400;++i) fms(0,uint8_t(i+drive*37));
        fms(4);
        require(free_count(drive)==initial_free[drive]-6,"Wrong allocation count");
    }
    for(unsigned drive=0;drive<sram_drives;++drive) {
        prepare(drive); fms(1); bus.ram[fcb+59]=255;
        for(unsigned i=0;i<1400;++i)
            require(fms(0)==uint8_t(i+drive*37),"File round-trip/drive isolation mismatch");
        fms(4); prepare(drive); fms(12);
        require(free_count(drive)==initial_free[drive],"Deletion did not restore free count");
    }
    // Select each drive and exercise its final sector, including page 255.
    for(unsigned drive=0;drive<sram_drives;++drive) {
        prepare(drive);
        call(bus,cpu,0xbe8c,fcb);
        require(cpu.s_.b==0,"Drive selection failed");
        const auto offset=(drive+1)*sram_drive_bytes-256;
        const auto old=std::vector<uint8_t>(bus.disk.begin()+offset,bus.disk.begin()+offset+256);
        for(unsigned i=0;i<256;++i) bus.ram[0x8400+i]=uint8_t(i+drive);
        call(bus,cpu,0xbe83,0x8400,sram_tracks-1,16);
        require(cpu.s_.b==0,"Last-sector write failed");
        call(bus,cpu,0xbe80,0x8500,sram_tracks-1,16);
        for(unsigned i=0;i<256;++i)
            require(bus.ram[0x8500+i]==uint8_t(i+drive),"Last-sector read mismatch");
        std::copy(old.begin(),old.end(),bus.disk.begin()+offset);
        const auto before_invalid=bus.disk;
        for(auto track_sector: {std::pair<int,int>{0,0},{0,17},{128,1},{255,16}}) {
            call(bus,cpu,0xbe83,0x8400,track_sector.first,track_sector.second);
            require(cpu.s_.b!=0 && (cpu.s_.cc&1),"Invalid address was accepted");
        }
        require(bus.disk==before_invalid,"Invalid write changed a disk");
    }
    // This bus has no SD bridge attached; drive 2 times out, other slots reject.
    for(unsigned absent:{2u,3u,4u,255u}) {
        prepare(absent);call(bus,cpu,0xbe8c,fcb);
        require(cpu.s_.b!=0 && (cpu.s_.cc&1),"Unavailable drive selection accepted");
        call(bus,cpu,0xbe8f,fcb);
        require(cpu.s_.b!=0 && (cpu.s_.cc&1),"Unavailable drive reported ready");
    }
    // A ready check for another drive must not change the active selection.
    prepare(1); call(bus,cpu,0xbe8c,fcb);
    prepare(0); call(bus,cpu,0xbe8f,fcb);
    call(bus,cpu,0xbe80,0x8500,0,3);
    require(std::equal(bus.ram.begin()+0x8500,bus.ram.begin()+0x8600,
                       bus.disk.begin()+sram_drive_bytes+2*256),"Ready check changed selected drive");
    std::ofstream disk("build/smoke.dsk",std::ios::binary);
    disk.write(reinterpret_cast<const char*>(bus.disk.data()),bus.disk.size());
    std::cout<<"Two-drive FMS create/write/read/delete, isolation, and boundary tests passed.\n";
}
static void xbasic_test() {
    Bus bus;
    Cpu cpu(bus);
    const auto inwait=symbol("build/c68flex.lst","C68INW");
    std::copy_n(bus.disk.begin(),256,bus.ram.begin()+0x100);
    cpu.s_.pc=0x100;
    const std::string keys="11,01,26\r0.XBASIC\r10 PRINT 123*100+45\rSAVE \"1.SMOKEBAS\"\rNEW\rLOAD \"1.SMOKEBAS\"\rRUN\rLOAD \"1.CRAPS\"\rRUN\r";
    size_t next=0;
    for (unsigned step=0;step<15000000;++step) {
        if (cpu.s_.pc==inwait && bus.input<0 && next<keys.size())
            bus.input=uint8_t(keys[next++]);
        cpu.step();
        if (next==keys.size() && bus.output.find("12345")!=std::string::npos &&
            bus.output.find("LUCKY FOR YOU TODAY")!=std::string::npos) {
            std::cout<<"XBASIC on drive 0, SAVE/LOAD and game loading on drive 1 passed.\n";
            return;
        }
    }
    bus.output.erase(std::remove(bus.output.begin(),bus.output.end(),char(0)),bus.output.end());
    throw std::runtime_error("XBASIC timed out PC="+std::to_string(cpu.s_.pc)+" keys="+std::to_string(next)+": "+bus.output);
}
#include "z68.h"
#include "random.h"
#include "vars.h"
#include "input.h"
#include "status.h"
#include "dict.h"
#include "wrap.h"
#include "memory.h"

int main(int argc,char **argv) {
    Bus bus;
    Cpu cpu(bus);
    try {
        if(argc>1 && std::string(argv[1])=="--status-only") {status_test();return 0;}
        if(argc>1 && std::string(argv[1])=="--memory-only") {memory_cache_test();return 0;}
        if(argc>1 && std::string(argv[1])=="--wrap-only") {wrap_test();status_test();return 0;}
        if(argc>1 && std::string(argv[1])=="--input-only") {input_test();input_story_test();dict_test();return 0;}
        xbasic_test();
        z68_test();
        random_test();
        vars_test();
        input_test();
        input_story_test();
        status_test();
        dict_test();
        wrap_test();
        memory_cache_test();
        auto inwait=symbol("build/c68flex.lst","C68INW");
        auto basicin=symbol("build/msbasic.lst","INCH");
        std::copy_n(bus.disk.begin(),256,bus.ram.begin()+0x100);
        cpu.s_.pc=0x100;
        // A BIOS has only copied the linked boot sector; the CPU must load FLEX.
        std::string keys="11,01,26\rboop\rcaX\177t\rcat 4\rcat 1\rcat 2\rcat 3\r0.msbasic\r\r\rN\rPRINT 2+2\r";
        size_t next=0;
        for (unsigned step=0;step<15000000;++step) {
            if ((cpu.s_.pc==inwait || cpu.s_.pc==basicin) && bus.input<0 && next<keys.size())
                bus.input=uint8_t(keys[next++]);
            cpu.step();
            if (bus.output.find("MITS ALTAIR 680 BASIC")!=std::string::npos &&
                bus.output.find(" 4 ")!=std::string::npos) {
                for(auto c:bus.output) if(c) std::cout<<c;
                std::cout<<"\nBoot, FLEX command loading, and BASIC arithmetic passed.\n";
                require(bus.output.find("ERRORS")!=std::string::npos &&
                        bus.output.find("XOUT")!=std::string::npos &&
                        bus.output.find("MEMFILL")!=std::string::npos &&
                        bus.output.find("C68DATA")!=std::string::npos,
                        "Imported utilities did not run");
                require(bus.output.find("\b \b")!=std::string::npos,
                        "FLEX did not visibly erase a DEL input");
                std::ifstream sound_config("build/sound-board.cfg");
                int sound_revision=0;
                sound_config >> sound_revision;
                require(bool(sound_config) && (sound_revision==1 || sound_revision==2),
                        "Missing sound board revision");
                const std::vector<uint8_t> boop = sound_revision==2
                    ? std::vector<uint8_t>{0x9f,0xbf,0xdf,0xff,0x8c,0x11,0x92,0x9f}
                    : std::vector<uint8_t>{0xf9,0xfd,0xfb,0xff,0x31,0x88,0x49,0xf9};
                require(std::search(bus.sound_writes.begin(),bus.sound_writes.end(),
                                    boop.begin(),boop.end())!=bus.sound_writes.end(),
                        "BOOP did not write the expected bit-reversed sound commands");
                const std::string drive_zero="CATALOG OF DRIVE NUMBER 0";
                auto first=bus.output.find(drive_zero);
                require(first!=std::string::npos &&
                        bus.output.find(drive_zero,first+1)==std::string::npos,
                        "CAT 4 aliased drive 0");
                const std::string drive_one="CATALOG OF DRIVE NUMBER 1";
                const auto second=bus.output.find(drive_one);
                require(second!=std::string::npos && bus.output.find(drive_one,second+1)==std::string::npos,
                        "Unavailable CAT drive aliased drive 1");
                filesystem_test(bus,cpu);
                return 0;
            }
        }
        throw std::runtime_error("Timed out at PC="+std::to_string(cpu.s_.pc));
    } catch(const std::exception &e) {
        std::cerr<<bus.output<<"\n"<<e.what()<<" PC="<<std::hex<<cpu.s_.pc<<"\n";
        return 1;
    }
}
