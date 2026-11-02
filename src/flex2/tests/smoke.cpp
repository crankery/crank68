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
        const auto offset=drive*262144+2*256;
        return unsigned(bus.disk[offset+33])*256+bus.disk[offset+34];
    };
    std::array<unsigned,4> initial_free{};
    // Keep identically named files on all four disks at once to catch aliasing.
    for(unsigned drive=0;drive<4;++drive) {
        initial_free[drive]=free_count(drive);
        prepare(drive); fms(2); bus.ram[fcb+59]=255;
        for(unsigned i=0;i<1400;++i) fms(0,uint8_t(i+drive*37));
        fms(4);
        require(free_count(drive)==initial_free[drive]-6,"Wrong allocation count");
    }
    for(unsigned drive=0;drive<4;++drive) {
        prepare(drive); fms(1); bus.ram[fcb+59]=255;
        for(unsigned i=0;i<1400;++i)
            require(fms(0)==uint8_t(i+drive*37),"File round-trip/drive isolation mismatch");
        fms(4); prepare(drive); fms(12);
        require(free_count(drive)==initial_free[drive],"Deletion did not restore free count");
    }
    // Select each drive and exercise its final sector, including page 255.
    for(unsigned drive=0;drive<4;++drive) {
        prepare(drive);
        call(bus,cpu,0xbe8c,fcb);
        require(cpu.s_.b==0,"Drive selection failed");
        const auto offset=(drive+1)*262144-256;
        const auto old=std::vector<uint8_t>(bus.disk.begin()+offset,bus.disk.begin()+offset+256);
        for(unsigned i=0;i<256;++i) bus.ram[0x8400+i]=uint8_t(i+drive);
        call(bus,cpu,0xbe83,0x8400,63,16);
        require(cpu.s_.b==0,"Last-sector write failed");
        call(bus,cpu,0xbe80,0x8500,63,16);
        for(unsigned i=0;i<256;++i)
            require(bus.ram[0x8500+i]==uint8_t(i+drive),"Last-sector read mismatch");
        std::copy(old.begin(),old.end(),bus.disk.begin()+offset);
        const auto before_invalid=bus.disk;
        for(auto track_sector: {std::pair<int,int>{0,0},{0,17},{64,1},{255,16}}) {
            call(bus,cpu,0xbe83,0x8400,track_sector.first,track_sector.second);
            require(cpu.s_.b!=0 && (cpu.s_.cc&1),"Invalid address was accepted");
        }
        require(bus.disk==before_invalid,"Invalid write changed a disk");
    }
    prepare(4);
    call(bus,cpu,0xbe8c,fcb);
    require(cpu.s_.b!=0 && (cpu.s_.cc&1),"Drive 4 was accepted");
    // A ready check for another drive must not change the active selection.
    prepare(3); call(bus,cpu,0xbe8c,fcb);
    prepare(0); call(bus,cpu,0xbe8f,fcb);
    call(bus,cpu,0xbe80,0x8500,0,3);
    require(std::equal(bus.ram.begin()+0x8500,bus.ram.begin()+0x8600,
                       bus.disk.begin()+3*262144+2*256),"Ready check changed selected drive");
    std::ofstream disk("build/smoke.dsk",std::ios::binary);
    disk.write(reinterpret_cast<const char*>(bus.disk.data()),bus.disk.size());
    std::cout<<"Four-drive FMS create/write/read/delete, isolation, and boundary tests passed.\n";
}
static void xbasic_test() {
    Bus bus;
    Cpu cpu(bus);
    const auto inwait=symbol("build/c68flex.lst","C68INW");
    std::copy_n(bus.disk.begin(),256,bus.ram.begin()+0x100);
    cpu.s_.pc=0x100;
    const std::string keys="11,01,26\r1.XBASIC\r10 PRINT 123*100+45\rSAVE \"3.SMOKEBAS\"\rNEW\rLOAD \"3.SMOKEBAS\"\rRUN\rLOAD \"2.CRAPS\"\rRUN\r";
    size_t next=0;
    for (unsigned step=0;step<15000000;++step) {
        if (cpu.s_.pc==inwait && bus.input<0 && next<keys.size())
            bus.input=uint8_t(keys[next++]);
        cpu.step();
        if (next==keys.size() && bus.output.find("12345")!=std::string::npos &&
            bus.output.find("LUCKY FOR YOU TODAY")!=std::string::npos) {
            std::cout<<"XBASIC on drive 1, SAVE/LOAD on drive 3, and game loading from drive 2 passed.\n";
            return;
        }
    }
    bus.output.erase(std::remove(bus.output.begin(),bus.output.end(),char(0)),bus.output.end());
    throw std::runtime_error("XBASIC timed out PC="+std::to_string(cpu.s_.pc)+" keys="+std::to_string(next)+": "+bus.output);
}
#include "z68.h"
#include "random.h"
#include "vars.h"

int main() {
    Bus bus;
    Cpu cpu(bus);
    try {
        xbasic_test();
        z68_test();
        random_test();
        vars_test();
        auto inwait=symbol("build/c68flex.lst","C68INW");
        auto basicin=symbol("build/msbasic.lst","INCH");
        std::copy_n(bus.disk.begin(),256,bus.ram.begin()+0x100);
        cpu.s_.pc=0x100;
        // A BIOS has only copied the linked boot sector; the CPU must load FLEX.
        std::string keys="11,01,26\rCAT\rCAT 4\rCAT 1\rCAT 2\rCAT 3\r1.MSBASIC\r\r\rN\rPRINT 2+2\r";
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
                        bus.output.find("C68BASIC")!=std::string::npos &&
                        bus.output.find("C68GAMES")!=std::string::npos &&
                        bus.output.find("C68FILES")!=std::string::npos,
                        "Imported utilities did not run");
                const std::string drive_zero="CATALOG OF DRIVE NUMBER 0";
                auto first=bus.output.find(drive_zero);
                require(first!=std::string::npos &&
                        bus.output.find(drive_zero,first+1)==std::string::npos,
                        "CAT 4 aliased drive 0");
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
