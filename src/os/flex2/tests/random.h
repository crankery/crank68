// Test the assembled 6800 routines against an independent host reference.
static void random_test() {
    Bus bus; Cpu cpu(bus);
    const auto flex=file("build/c68flex.bin");
    const auto app=file("build/z68.bin");
    std::copy(flex.begin(),flex.end(),bus.ram.begin()+0xa100);
    std::copy(app.begin(),app.end(),bus.ram.begin()+0x300);
    const auto entry=symbol("build/z68.lst","rnd");
    const auto next=symbol("build/z68.lst","rnd_next");
    const auto state=symbol("build/z68.lst","rnd_state");
    const auto result=symbol("build/z68.lst","rnd_result");
    const auto mode=symbol("build/z68.lst","rnd_mode");
    auto read_state=[&]() {
        uint32_t value=0;
        for(unsigned n=0;n<4;++n) value=(value<<8)|bus.ram[state+n];
        return value;
    };
    auto write_state=[&](uint32_t value) {
        for(int n=3;n>=0;--n) {bus.ram[state+n]=value&255;value>>=8;}
    };
    auto invoke=[&](uint16_t argument) {
        call(bus,cpu,entry,0x5678,argument>>8,argument&255);
        const unsigned value=unsigned(cpu.s_.a)*256+cpu.s_.b;
        require(!(cpu.s_.cc&1) && cpu.s_.x==0x5678,"Random API damaged carry or X");
        require(value==unsigned(bus.ram[result])*256+bus.ram[result+1],"Random result/register mismatch");
        return value;
    };
    auto advance=[](uint32_t &value) {
        if(value==0) value=0xa5;
        value^=value<<13; value^=value>>17; value^=value<<5;
        return unsigned(value>>16);
    };
    auto seeded=[&](uint16_t argument) {
        uint32_t value=(uint32_t((argument>>8)^0x6d)<<24)|
                       (uint32_t((argument&255)^0x2b)<<16)|
                       (uint32_t((argument>>8)^0x79)<<8)|((argument&255)^0xf5);
        for(unsigned n=0;n<8;++n) advance(value);
        return value;
    };
    bus.ram[0xac0e]=11; bus.ram[0xac0f]=2; bus.ram[0xac10]=26;
    for(int seed: {1,10,999,1000,32768}) {
        const auto argument=uint16_t(-seed);
        require(invoke(argument)==0 && bus.ram[mode]==1,"Predictable seed did not return zero");
        uint32_t reference=seeded(argument);
        require(read_state()==reference,"Predictable seed expansion differs");
        std::vector<unsigned> first;
        for(unsigned n=0;n<64;++n) first.push_back(invoke(100));
        bus.ram[0xac0e]^=7; bus.ram[0xbff8]^=0xff;
        require(invoke(argument)==0,"Repeated seed failed");
        for(unsigned n=0;n<64;++n) require(invoke(100)==first[n],"Seed is not repeatable independently of date/time");
    }
    invoke(uint16_t(-1234)); uint32_t reference=seeded(uint16_t(-1234));
    for(unsigned range: {1,2,3,6,100,255,256,257,1000,16384,32767}) {
        const unsigned threshold=65536u%range;
        for(unsigned n=0;n<128;++n) {
            unsigned sample;
            do {sample=advance(reference);} while(sample<threshold);
            const auto value=invoke(range);
            require(value==sample%range+1 && value>=1 && value<=range,
                    "Random range or rejection-sampling error");
            require(read_state()==reference,"Generator sequence differs from reference");
        }
    }
    // Force a sample of zero with a nonzero state to exercise rejection.
    uint32_t rejected_seed=1;
    for(;;++rejected_seed) {auto value=rejected_seed;if(advance(value)<2) break;}
    write_state(rejected_seed); reference=rejected_seed;
    unsigned sample,draws=0;
    do {sample=advance(reference);++draws;} while(sample<2);
    require(draws>1 && invoke(32767)==sample%32767+1 && read_state()==reference,
            "Rejected sample was accepted or consumed incorrectly");
    write_state(0); call(bus,cpu,next,0x5678);
    reference=0; advance(reference);
    require(read_state()==reference && read_state()!=0,"Zero RNG state was not repaired");
    write_state(0);
    require(invoke(6)>=1 && read_state()!=0 && bus.ram[mode]==0,"Uninitialized random mode failed");
    write_state(0); bus.ram[0xbff8]=0; bus.ram[0xbff9]=1;
    require(invoke(0)==0 && bus.ram[mode]==0,"Random zero did not reseed normally");
    const auto first=read_state();
    require(invoke(0)==0 && read_state()!=first,"Consecutive random reseeds repeated state");
    const auto nonce=symbol("build/z68.lst","rnd_nonce");
    for(unsigned timing: {0,1,0x1234,0xffff}) {
        write_state(0); bus.ram[nonce]=0; bus.ram[nonce+1]=0;
        bus.ram[0xac0e]=11; bus.ram[0xac0f]=2; bus.ram[0xac10]=26;
        bus.ram[0xbff8]=timing>>8; bus.ram[0xbff9]=timing&255;
        reference=(uint32_t((timing>>8)^26)<<24)|
                  (uint32_t((timing&255)^2)<<16)|(11u<<8)|0xa4;
        for(unsigned n=0;n<8;++n) advance(reference);
        require(invoke(0)==0 && read_state()==reference,"FLEX date/poll timing seed differs");
    }
    // The input-poll entropy ABI wraps, and input still preserves B and X.
    require(symbol("build/c68flex.lst","C68TICKS")==0xbff8,"Polling entropy ABI moved");
    bus.ram[0xbff8]=255; bus.ram[0xbff9]=255; bus.input='Q';
    call(bus,cpu,symbol("build/c68flex.lst","C68IN"),0x5678,0,0xa7);
    require(bus.ram[0xbff8]==0 && bus.ram[0xbff9]==0 && cpu.s_.a=='Q' &&
            cpu.s_.b==0xa7 && cpu.s_.x==0x5678,"Input entropy counter broke console ABI/wrap");
    std::cout<<"V3 random seeds, reference sequences, unbiased bounds, reseeding and FLEX poll timing passed.\n";
}
