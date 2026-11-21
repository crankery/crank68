// Execute the assembled variable operations on the actual emulated 6800.
static void vars_test() {
    Bus bus; Cpu cpu(bus);
    auto flex=file("build/c68flex.bin"), app=file("build/z68.bin");
    std::copy(flex.begin(),flex.end(),bus.ram.begin()+0xa100);
    std::copy(app.begin(),app.end(),bus.ram.begin()+0x300);
    auto sym=[](const std::string &n){return symbol("build/z68.lst",n);};
    auto put=[&](unsigned p,unsigned v){bus.ram[p]=v>>8;bus.ram[p+1]=v;};
    auto get=[&](unsigned p){return unsigned(bus.ram[p])*256+bus.ram[p+1];};
    auto run=[&](const std::string &n,unsigned a=0,bool ok=true){
        call(bus,cpu,sym(n),0,a);
        require(bool(cpu.s_.cc&1)==!ok,"Variable operation status: "+n);
    };
    const auto value=sym("vm_value"), sp=sym("vm_stack_pointer");
    const auto end=sym("app_end"), header=sym("story_header");
    put(sym("vm_stack_base"),0x7000);put(sym("cpu_stack_base"),0x7800);
    put(header+12,64);put(sym("dynamic_size"),1024);put(sym("dynamic_end"),end+1024);
    run("vars_init");
    for(unsigned v: {16u,255u}) {
        put(value,0xab00+v);run("var_write",v);put(value,0);run("var_read",v);
        require(get(value)==0xab00+v && get(end+64+2*(v-16))==0xab00+v,"Global mapping/endian");
    }
    run("var_read",1,false);run("var_read",0,false);
    auto push=[&](unsigned v){put(value,v);run("var_write");};
    auto pop=[&](){run("var_read");return get(value);};
    push(43);push(44);push(45);
    run("var_peek");require(get(value)==45 && get(sp)==0x7006,"Peek popped stack");
    put(value,46);run("var_replace");require(pop()==46 && pop()==44 && pop()==43,"Stack replacement/LIFO");
    run("var_replace",0,false);
    for(unsigned n=0;n<1024;++n) push(n);
    put(value,0);run("var_write",0,false);
    for(int n=1023;n>=0;--n) require(pop()==unsigned(n),"Full stack corrupted");
    put(sp,0x7001);run("var_read",0,false);run("vars_init");
    put(sym("vm_local_base"),0x7000);put(sym("vm_eval_base"),0x701e);put(sp,0x701e);
    bus.ram[sym("vm_local_count")]=15;
    put(value,0x1234);run("var_write",1);put(value,0xbeef);run("var_write",15);
    run("var_read",1);require(get(value)==0x1234,"Local one mapping");
    run("var_read",15);require(get(value)==0xbeef,"Local fifteen mapping");
    run("var_read",0,false);bus.ram[sym("vm_local_count")]=1;run("var_read",2,false);
    put(header+12,600);run("var_read",16,false);put(header+12,64);
    run("vars_init");
    const auto count=sym("vm_operand_count"), types=sym("vm_operand_types");
    const auto raw=sym("vm_operands"), resolved=sym("vm_resolved");
    auto operand=[&](unsigned n,unsigned type,unsigned v){bus.ram[types+n]=type;put(raw+2*n,v);};
    auto op=[&](const std::string &n,unsigned nops){bus.ram[count]=nops;run("vm_resolve");run("vm_do_"+n);};
    // load sp -> sp duplicates, while a variable operand containing zero pops
    // its pointer exactly once before accessing the remaining top in place.
    push(45);operand(0,1,0);bus.ram[sym("vm_store_variable")]=0;op("load",1);
    require(pop()==45 && pop()==45,"load sp -> sp failed");
    push(45);push(0);operand(0,2,0);bus.ram[sym("vm_store_variable")]=16;op("load",1);
    require(get(end+64)==45 && pop()==45,"Indirect stack load popped twice");
    push(43);push(44);push(45);operand(0,1,0);operand(1,2,0);op("store",2);
    require(pop()==45 && pop()==43,"store sp sp semantics");
    push(43);push(44);push(45);operand(0,1,0);op("pull",1);
    require(pop()==45 && pop()==43,"pull sp semantics");
    push(43);push(44);push(45);push(0);operand(0,2,0);op("pull",1);
    require(pop()==45 && pop()==43,"pull [sp] semantics");
    push(44);push(45);push(0);operand(0,2,0);operand(1,2,0);op("store",2);
    require(pop()==45 && get(raw)==0 && get(raw+2)==0,"Left to right resolution/raw operand preservation");
    push(0x7fff);operand(0,1,0);op("inc",1);require(pop()==0x8000,"inc signed wrap");
    push(0x8000);op("dec",1);require(pop()==0x7fff,"dec signed wrap");
    operand(0,0,0x9876);op("push",1);require(pop()==0x9876,"push operand");
    push(12);op("pop",0);require(get(sp)==0x7000,"pop did not discard");
    operand(0,0,0xffff);bus.ram[sym("vm_store_variable")]=0;op("random",1);
    require(pop()==0,"random seed result store");
    operand(0,1,6);bus.ram[sym("vm_store_variable")]=255;op("random",1);
    require(get(end+64+478)>=1 && get(end+64+478)<=6,"random range result store");
    operand(0,2,1);bus.ram[count]=1;run("vm_resolve",0,false);
    bus.ram[count]=5;run("vm_resolve",0,false);
    bus.ram[count]=0;run("vm_do_load",0,false);
    // Full decode/resolve/dispatch execution, with constants and variable-zero
    // reads. The story stays in dynamic RAM so no fake disk service is needed.
    const unsigned program=600;
    std::vector<uint8_t> code={0xe8,0x7f,42,0x9e,0,16,0x95,16,
                              0x2d,17,16,0xe9,0x7f,18,0xba};
    std::copy(code.begin(),code.end(),bus.ram.begin()+end+program);
    put(header+6,program);bus.ram[header]=3;
    run("vm_run",0,false); // quit returns carry set, with vm_finished set
    require(bus.ram[sym("vm_finished")]==1 && !bus.ram[sym("op_halted")],"Variable story execution halted");
    require(get(end+64)==43 && get(end+66)==43 && get(end+68)==42 && get(sp)==0x7000,
            "Decoded variable story produced wrong globals/stack");
    // Return tests also exercise malformed private frames directly.
    const auto frame=sym("vm_frame_pointer"), eval=sym("vm_eval_base");
    const auto locals=sym("vm_local_base"), nlocals=sym("vm_local_count");
    auto make_frame=[&](unsigned at,unsigned parent,unsigned local,unsigned countLocal,
                        unsigned evaluation,unsigned pc,unsigned dest){
        put(at,parent);put(at+2,local);bus.ram[at+4]=countLocal;put(at+5,evaluation);
        bus.ram[at+7]=pc>>16;put(at+8,pc);bus.ram[at+10]=dest;bus.ram[at+11]=0;
    };
    for(unsigned dest: {0u,1u,16u}) for(unsigned truth: {0u,1u}) {
        run("vars_init");run("calls_init");
        make_frame(0x7010,0,0x7000,2,0x7004,0x12345,dest);
        put(0x7000,0xaaaa);put(0x7002,0xbbbb);put(0x700e,0xcafe);
        put(frame,0x7010);put(locals,0x701c);bus.ram[nlocals]=1;
        put(eval,0x701e);put(sp,0x7024);bus.ram[sym("vm_finished")]=0;
        run(truth?"op_rtrue":"op_rfalse");
        require(get(value)==truth && get(frame)==0 && get(locals)==0x7000 &&
                bus.ram[nlocals]==2 && get(eval)==0x7004,"Caller context restoration");
        const auto pc=sym("vm_pc");
        require(bus.ram[pc]==1 && get(pc+1)==0x2345 && !bus.ram[sym("vm_finished")],
                "17-bit return PC/finished flag");
        require(get(sp)==(dest?0x7010:0x7012) && get(0x700e)==0xcafe,
                "Return failed to discard callee stack/preserve caller stack");
        require(get(dest==0?0x7010:dest==1?0x7000:end+64)==truth,"Return result destination");
    }
    // Unwind two contexts and store in the restored outer local, then global.
    run("vars_init");
    make_frame(0x7004,0,0,0,0x7000,700,17);
    make_frame(0x7020,0x7004,0x7010,1,0x7012,710,1);
    put(frame,0x7020);put(eval,0x702c);put(sp,0x7030);
    run("op_rtrue");
    require(get(frame)==0x7004 && get(0x7010)==1,"Nested return did not restore parent");
    run("op_rfalse");
    require(get(frame)==0 && get(sp)==0x7004 && get(end+66)==0,"Outer return context");
    for(unsigned truth: {0u,1u}) {
        bus.ram[end+program]=truth?0xb0:0xb1;put(header+6,program);
        put(frame,0x7777); // vm_run must reset stale call state
        run("vm_run",0,false);
        require(bus.ram[sym("vm_finished")] && !bus.ram[sym("op_halted")] && get(value)==truth,
                "Initial-context rtrue/rfalse did not finish execution");
    }
    run("vars_init");put(frame,0x6ffe);run("op_rtrue",0,false);
    put(frame,0x7000);put(eval,0x700a);run("op_rfalse",0,false); // truncated frame
    make_frame(0x7010,0x7010,0,0,0x7000,700,16);
    put(frame,0x7010);put(eval,0x701c);run("op_rtrue",0,false); // cyclic link
    make_frame(0x7010,0,0,0,0x6ffe,700,16);run("op_rfalse",0,false);
    std::cout << "Z68 routine returns: true/false, nested frames, destinations, root exit and bounds passed.\n";
    std::cout << "Z68 variables: globals, locals, stack bounds, indirect operands and execution passed.\n";
}
