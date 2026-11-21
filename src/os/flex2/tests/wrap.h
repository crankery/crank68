// Exercise the assembled stream wrapper, including delayed wrap at column 80.
static void wrap_test(){
    Bus bus;Cpu cpu(bus);
    auto flex=file("build/c68flex.bin"),app=file("build/z68.bin");
    std::copy(flex.begin(),flex.end(),bus.ram.begin()+0xa100);
    std::copy(app.begin(),app.end(),bus.ram.begin()+0x300);
    auto sym=[](const std::string &s){return symbol("build/z68.lst",s);};
    const auto emit=sym("text_emit"),put=sym("putc"),word=sym("wrap_word");
    auto run=[&](const std::string&s){call(bus,cpu,sym(s),0);};
    auto clean=[&](){auto s=bus.output;s.erase(std::remove(s.begin(),s.end(),char(0)),s.end());return s;};
    auto feed=[&](const std::string&s){for(unsigned char c:s)call(bus,cpu,emit,0,c);};
    struct Case{std::string text,expected;};
    const std::vector<Case> cases={
        {"",""},{"one two","one two"},{"a   b ","a   b "},{"   hello world","   hello world"},
        {std::string(73,'a')+" "+std::string(7,'b'),std::string(73,'a')+"\r\n"+std::string(7,'b')},
        {std::string(72,'a')+" "+std::string(7,'b')+" c",std::string(72,'a')+" "+std::string(7,'b')+"\r\nc"},
        {std::string(80,'a'),std::string(80,'a')},
        {std::string(80,'a')+"\r",std::string(80,'a')+"\r\n"},
        {std::string(80,'a')+" b",std::string(80,'a')+"\r\nb"},
        {std::string(81,'a'),std::string(80,'a')+"\r\na"},
        {std::string(160,'a'),std::string(80,'a')+"\r\n"+std::string(80,'a')},
        {std::string(161,'a'),std::string(80,'a')+"\r\n"+std::string(80,'a')+"\r\na"},
        {std::string(78,'a')+" "+std::string(81,'b'),std::string(78,'a')+"\r\n"+std::string(80,'b')+"\r\nb"},
        {"a\r\rb\r","a\r\n\r\nb\r\n"},
        {std::string(78,'a')+"   bb",std::string(78,'a')+"\r\nbb"}
    };
    for(const auto&t:cases){
        bus.output.clear();const auto guard=bus.ram[word+80];run("wrap_begin");feed(t.text);run("wrap_finish");
        require(clean()==t.expected,"Word wrap differs at boundary/space/newline");
        require(!bus.ram[sym("wrap_enabled")] && bus.ram[word+80]==guard,"Wrapper state/buffer guard");
        StatusTerminal terminal;terminal.feed(clean()); // also exercises actual terminal delayed-wrap semantics
    }
    bus.output.clear();run("wrap_begin");feed(std::string(78,'a')+" ");
    const auto operands=sym("vm_resolved");bus.ram[operands]=0;bus.ram[operands+1]=42;
    run("vm_do_print_num");run("wrap_finish");
    require(clean()==std::string(78,'a')+"\r\n42","Numbers did not join the story word stream");
    bus.output.clear();run("wrap_begin");
    for(char c:std::string("prompt> ")){
        call(bus,cpu,put,0x4567,c,0x89);
        require(cpu.s_.x==0x4567 && cpu.s_.a==uint8_t(c) && cpu.s_.b==0x89,"Wrapping damaged putc ABI");
    }
    run("wrap_flush");require(clean()=="prompt> ","Prompt/trailing space not visible at flush");
    run("wrap_finish");
    bus.output.clear();run("wrap_begin");feed("pending");run("op_save");
    require(clean().find("pending")==0 && clean().find("unimplemented opcode save")!=std::string::npos &&
            !bus.ram[sym("wrap_enabled")],"Error diagnostic lost/reordered pending text");
    bus.output.clear();run("wrap_begin");feed("goodbye");run("vm_run_done");
    require(clean()=="goodbye" && !bus.ram[sym("wrap_enabled")],"Exit lost final unterminated word");
    std::cout<<"Z68 wrapping: word boundaries, spaces, paragraphs, numbers, long words, prompts, errors and exit passed.\n";
}
