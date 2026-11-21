// Test the assembled 17-bit divider and cache replacement/error behavior.
static void memory_cache_test(){
    Bus bus;Cpu cpu(bus);
    const auto flex=file("build/c68flex.bin"),app=file("build/z68.bin");
    std::copy(flex.begin(),flex.end(),bus.ram.begin()+0xa100);
    std::copy(app.begin(),app.end(),bus.ram.begin()+0x300);
    auto sym=[](const std::string&s){return symbol("build/z68.lst",s);};
    auto put=[&](unsigned p,unsigned v){bus.ram[p]=v>>8;bus.ram[p+1]=v;};
    auto word=[&](unsigned p){return unsigned(bus.ram[p])*256+bus.ram[p+1];};
    const auto address=sym("mem_address"),quotient=sym("mem_sector"),remainder=sym("mem_div");
    const auto divide=sym("memory_divide_address");
    for(unsigned n=0;n<131072;++n){
        bus.ram[address]=n>>16;put(address+1,n);call(bus,cpu,divide,0);
        require(!(cpu.s_.cc&1) && word(quotient)==n/252 && !bus.ram[remainder] &&
                !bus.ram[remainder+1] && bus.ram[remainder+2]==n%252,"17-bit address division mismatch");
        require(bus.ram[address]==n>>16 && word(address+1)==(n&65535),"Divider altered story address");
    }
    // A synthetic index refers to raw sectors in this private in-memory disk.
    // No on-disk user files or generated images are modified.
    const auto fcb=sym("story_fcb"),read=sym("memory_read_byte"),sector=sym("story_read_sector");
    put(sym("index_base"),0x7000);put(sym("cache_base"),0x7500);put(sym("index_count"),521);
    put(sym("dynamic_size"),64);put(sym("dynamic_end"),sym("app_end")+64);
    bus.ram[sym("file_index_valid")]=1;bus.ram[fcb+3]=1;
    for(unsigned n=0;n<521;++n){bus.ram[0x7000+2*n]=127;bus.ram[0x7001+2*n]=12+n%4;}
    for(unsigned n=0;n<4;++n){const auto at=sram_drive_bytes+(127*16+11+n)*256;
        for(unsigned i=0;i<252;++i)bus.disk[at+4+i]=uint8_t(n*53+i*7);}
    unsigned reads=0;
    auto invoke=[&](unsigned n,bool valid=true){
        bus.ram[address]=n>>16;put(address+1,n);cpu.s_.pc=read;cpu.s_.sp=0x9ffd;
        bus.ram[0x9ffe]=0x90;bus.ram[0x9fff]=0;
        for(unsigned step=0;step<2000000 && cpu.s_.pc!=0x9000;++step){
            if(cpu.s_.pc==sector)++reads;cpu.step();
        }
        require(cpu.s_.pc==0x9000 && bool(cpu.s_.cc&1)==!valid,"Cached read status/timeout");
        if(valid)require(cpu.s_.a==uint8_t((n/252%4)*53+(n%252)*7),"Wrong cached payload");
        require(bus.ram[address]==n>>16 && word(address+1)==(n&65535),"Cache altered story address");
    };
    invoke(300);invoke(600);invoke(301);invoke(601);invoke(302);invoke(602);
    require(reads==2,"Alternating sectors did not stay in both cache slots");
    invoke(300);invoke(900);invoke(301);
    require(reads==3,"LRU replacement evicted the recently used slot");
    invoke(600);require(reads==4,"LRU miss/read count incorrect");
    bus.ram[0x7000+2*3]=128;invoke(900,false);
    const auto after_error=reads;invoke(601);
    require(reads==after_error,"Failed refill discarded the other valid slot");
    bus.ram[0x7000+2*3]=127;invoke(900);invoke(602);
    require(reads==after_error+1,"Recovery failed to reuse the unmodified cache slot");
    for(unsigned n:{251u,252u,65535u,65536u,131071u})invoke(n);
    invoke(131072,false);
    // Dynamic RAM wins even if the cache holds original bytes from that sector.
    invoke(100);put(sym("dynamic_size"),128);bus.ram[sym("app_end")+100]=0x3c;
    bus.ram[address]=0;put(address+1,100);const auto before_dynamic=reads;
    call(bus,cpu,read,0);require(!(cpu.s_.cc&1) && cpu.s_.a==0x3c && reads==before_dynamic,
                               "Cached disk bytes shadowed writable story RAM");
    std::cout<<"Z68 memory cache: exhaustive 17-bit division, two-slot hits/LRU, failed fills, bounds and dynamic RAM passed.\n";
}
