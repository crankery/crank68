// Exercise real 6800 line editing through the C68 FLEX raw-console service.
static void input_test() {
    Bus bus;Cpu cpu(bus);
    auto flex=file("build/c68flex.bin"),app=file("build/z68.bin");
    std::copy(flex.begin(),flex.end(),bus.ram.begin()+0xa100);
    std::copy(app.begin(),app.end(),bus.ram.begin()+0x300);
    const auto entry=symbol("build/z68.lst","input_read_line");
    const auto buffer=symbol("build/z68.lst","input_buffer");
    const auto length=symbol("build/z68.lst","input_length");
    const auto skip=symbol("build/z68.lst","input_skip_lf");
    const auto wait=symbol("build/c68flex.lst","C68INW");
    require(symbol("build/c68flex.lst","C68IN")==0xbf00,"C68 raw-console ABI moved");
    auto read=[&](unsigned limit,const std::string &keys,size_t &next){
        std::fill_n(bus.ram.begin()+buffer,256,0xcc);
        const auto guard=bus.ram[buffer+256];
        bus.output.clear();cpu.s_.pc=entry;cpu.s_.a=limit;cpu.s_.sp=0x9ffd;
        bus.ram[0x9ffe]=0x90;bus.ram[0x9fff]=0;
        for(unsigned n=0;n<2000000 && cpu.s_.pc!=0x9000;++n){
            if(cpu.s_.pc==wait && bus.input<0 && next<keys.size())bus.input=uint8_t(keys[next++]);
            cpu.step();
        }
        require(cpu.s_.pc==0x9000 && !(cpu.s_.cc&1),"Console line read timed out/failed");
        require(bus.ram[length]==cpu.s_.b && bus.ram[length]<=limit,"Line length/result ABI");
        require(bus.ram[buffer+bus.ram[length]]==0,"Missing line terminator");
        require(bus.ram[buffer+256]==guard,"Line overflowed private buffer");
        for(unsigned n=limit+1;n<256;++n) require(bus.ram[buffer+n]==0xcc,"Line exceeded supplied capacity");
        bus.output.erase(std::remove(bus.output.begin(),bus.output.end(),char(0)),bus.output.end());
        return std::string(bus.ram.begin()+buffer,bus.ram.begin()+buffer+bus.ram[length]);
    };
    struct Case{unsigned limit;std::string keys,value,echo;};
    const std::vector<Case> cases={
        {255,"Open MAILBOX\r","open mailbox","Open MAILBOX\r\n"},
        {255,"\r","","\r\n"},{255,"\n","","\r\n"},
        {255,std::string("\b\x7f")+"ab\bC\x7f"+"D\r","ad","ab\b \bC\b \bD\r\n"},
        {3,"ABCD\bZ\r","abz","ABC\a\b \bZ\r\n"},
        {0,"A\b\r","","\a\r\n"},
        {255,std::string("a\t\x01")+"B\r","ab","aB\r\n"},
        {255,std::string(255,'A')+"B\r",std::string(255,'a'),std::string(255,'A')+"\a\r\n"}
    };
    for(const auto &t:cases){
        bus.ram[skip]=0;size_t next=0;
        require(read(t.limit,t.keys,next)==t.value,"Console captured wrong string");
        require(bus.output==t.echo,"Console echo/editing differs");
        require(next==t.keys.size() && bus.input<0,"Line did not consume through Enter");
    }
    bus.ram[skip]=0;size_t next=0;const std::string pair="first\r\nSECOND\n";
    require(read(255,pair,next)=="first" && next==6,"CR consumed beyond terminator");
    require(read(255,pair,next)=="second" && next==pair.size(),"CRLF leaked into next line");
    std::cout<<"Z68 console lines: case, echo, BS/DEL, empty input, controls, limits and CRLF passed.\n";
}

// Check actual sread writes against the V3 story buffer contract, including
// rejection before reading input or altering RAM for malformed destinations.
static void input_story_test() {
    Bus bus;Cpu cpu(bus);
    auto flex=file("build/c68flex.bin"),app=file("build/z68.bin");
    std::copy(flex.begin(),flex.end(),bus.ram.begin()+0xa100);
    std::copy(app.begin(),app.end(),bus.ram.begin()+0x300);
    auto sym=[](const std::string &s){return symbol("build/z68.lst",s);};
    const auto entry=sym("vm_do_sread"), base=sym("app_end"), operands=sym("vm_resolved");
    const auto count=sym("vm_operand_count"), length=sym("input_length");
    const auto done=sym("vm_input_complete"), requested=sym("vm_input_requested"), halted=sym("op_halted");
    const auto wait=symbol("build/c68flex.lst","C68INW");
    auto put=[&](unsigned p,unsigned v){bus.ram[p]=v>>8;bus.ram[p+1]=v;};
    put(sym("dynamic_size"),2048);put(sym("dynamic_end"),base+2048);put(sym("story_header")+8,0x500);
    struct Case{unsigned at,max,count;std::string keys,expected;bool valid;};
    const std::vector<Case> cases={
        {128,20,2,"OPEN Mailbox\r","open mailbox",true},
        {128,5,2,"ABCDE\r","abcd",true},
        {128,2,2,"AB\r","a",true},
        {128,255,2,std::string(255,'X')+"\r",std::string(254,'x'),true},
        {128,20,2,"\r","",true},
        {128,5,2,"abc\bD\r","abd",true},
        {2042,5,2,"ABCD\r","abcd",true}, // terminator exactly at dynamic end - 1
        {2043,5,2,"", "",false}, // maximum extent crosses into static memory
        {2048,5,2,"", "",false},
        {63,5,2,"", "",false},
        {128,0,2,"", "",false}, {128,1,2,"", "",false},
        {128,20,1,"", "",false}, {128,20,3,"", "",false},
        {65535,255,2,"", "",false}
    };
    for(const auto &t:cases){
        std::fill_n(bus.ram.begin()+base,2048,0xa5);
        bus.ram[base-1]=0x5a;bus.ram[base+2048]=0x5a;
        if(t.at<2048)bus.ram[base+t.at]=t.max;
        bus.ram[base+0x600]=1;
        bus.ram[base+0x500]=0;bus.ram[base+0x501]=4;put(base+0x502,0);
        bus.ram[count]=t.count;put(operands,t.at);put(operands+2,0x600);
        bus.ram[done]=0;bus.ram[requested]=0;bus.ram[halted]=0;bus.ram[sym("input_skip_lf")]=0;
        auto expected=std::vector<uint8_t>(bus.ram.begin()+base,bus.ram.begin()+base+2048);
        bus.output.clear();bus.input=-1;size_t next=0;
        cpu.s_.pc=entry;cpu.s_.sp=0x9ffd;bus.ram[0x9ffe]=0x90;bus.ram[0x9fff]=0;
        for(unsigned n=0;n<2000000 && cpu.s_.pc!=0x9000;++n){
            if(cpu.s_.pc==wait && bus.input<0 && next<t.keys.size())bus.input=uint8_t(t.keys[next++]);
            cpu.step();
        }
        require(cpu.s_.pc==0x9000 && bool(cpu.s_.cc&1)==!t.valid,"sread status/return");
        if(t.valid){
            std::copy(t.expected.begin(),t.expected.end(),expected.begin()+t.at+1);
            expected[t.at+1+t.expected.size()]=0;
            expected[0x601]=t.expected.empty()?0:1;
            if(!t.expected.empty()) {
                expected[0x602]=expected[0x603]=0;
                expected[0x604]=t.expected.find(' ')==std::string::npos?t.expected.size():t.expected.find(' ');
                expected[0x605]=1;
            }
            require(bus.ram[done]==1 && bus.ram[requested]==0 && !bus.ram[halted] &&
                    bus.ram[length]==t.expected.size() && next==t.keys.size(),"sread capture flags/limit");
        } else require(bus.ram[done]==0 && !bus.ram[requested] && bus.ram[halted]==1 && next==0,
                       "Invalid text buffer accepted or consumed input");
        require(std::equal(expected.begin(),expected.end(),bus.ram.begin()+base),
                "sread changed wrong story bytes (header/tail/parse buffer or bounds)");
        require(bus.ram[base-1]==0x5a && bus.ram[base+2048]==0x5a,"sread escaped dynamic RAM");
    }
    std::cout<<"Z68 V3 story input: text bytes, terminator, capacity, guards and invalid buffers passed.\n";
}
