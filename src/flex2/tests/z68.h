#include <filesystem>
#include <sstream>
#include <iomanip>

// Exercise the FLEX command loader and file API with synthetic, non-game data.
static void z68_test() {
    Bus bus;
    Cpu cpu(bus);
    const auto inwait=symbol("build/c68flex.lst","C68INW");
    auto run=[&](const std::string &keys) {
        bus.output.clear();
        size_t next=0;
        for (unsigned step=0;step<5000000;++step) {
            if (cpu.s_.pc==inwait && bus.input<0) {
                if (next<keys.size()) bus.input=uint8_t(keys[next++]);
                else {
                    auto text=bus.output;
                    text.erase(std::remove(text.begin(),text.end(),char(0)),text.end());
                    if (text.size()>=3 && text.substr(text.size()-3)=="+++") return text;
                }
            }
            cpu.step();
        }
        throw std::runtime_error("Z68 command did not return to FLEX prompt");
    };
    std::copy_n(bus.disk.begin(),256,bus.ram.begin()+0x100);
    cpu.s_.pc=0x100;
    run("11,01,26\r");
    auto read_word=[&](const std::string &name) {
        const auto address=symbol("build/z68.lst",name);
        return unsigned(bus.ram[address])*256+bus.ram[address+1];
    };
    const auto app_end=symbol("build/z68.lst","app_end");
    constexpr unsigned reservations=1042+504+2048;
    auto check_layout=[&](const std::vector<uint8_t> &bytes,unsigned top) {
        const auto size=unsigned(bytes[14])*256+bytes[15];
        require(bus.ram[symbol("build/z68.lst","dynamic_loaded")]==1,"Dynamic load not complete");
        require(read_word("dynamic_start")==app_end && read_word("dynamic_size")==size &&
                read_word("dynamic_end")==app_end+size,"Wrong dynamic story mapping");
        require(std::equal(bytes.begin(),bytes.begin()+size,bus.ram.begin()+app_end),
                "Loaded writable story differs from original bytes");
        require(read_word("cpu_stack_base")==top+1-512 &&
                read_word("vm_stack_base")==top+1-512-2048 &&
                read_word("cache_base")==top+1-512-2048-504 &&
                read_word("index_base")==top+1-512-reservations &&
                read_word("growth_bytes")==top+1-512-reservations-app_end-size,
                "Interpreter RAM reservations overlap or exceed FLEX MEMEND");
    };
    // Also load any local stories, without requiring copyrighted fixtures.
    if (std::filesystem::exists("../z68/stories")) {
        for (const auto &entry:std::filesystem::directory_iterator("../z68/stories")) {
            auto extension=entry.path().extension().string();
            std::transform(extension.begin(),extension.end(),extension.begin(),::toupper);
            if (!entry.is_regular_file() || (extension!=".DAT" && extension!=".Z3")) continue;
            auto stem=entry.path().stem().string();
            std::transform(stem.begin(),stem.end(),stem.begin(),::toupper);
            const auto bytes=file(entry.path().c_str());
            const auto output=run("Z68 3."+stem+".DAT\r");
            auto word=[&](size_t offset) {
                std::ostringstream hex;
                hex<<std::uppercase<<std::hex<<std::setw(4)<<std::setfill('0')
                   <<(unsigned(bytes.at(offset))*256+bytes.at(offset+1));
                return hex.str();
            };
            require(output.find("Release: $"+word(2))!=std::string::npos &&
                    output.find("Dynamic bytes: $"+word(14))!=std::string::npos &&
                    output.find("Initial PC: $"+word(6))!=std::string::npos &&
                    output.find("Z68: V3 story header")!=std::string::npos,
                    "Local story probe failed: "+stem+"\n"+output);
            std::cout<<output<<"\n";
            check_layout(bytes,0x7fff);
        }
    }
    const uint16_t fcb=0x8000;
    auto write_file=[&](const std::string &name,const std::vector<uint8_t> &data) {
        std::fill_n(bus.ram.begin()+fcb,320,0);
        bus.ram[fcb+3]=3;
        std::copy(name.begin(),name.end(),bus.ram.begin()+fcb+4);
        bus.ram[fcb+12]='D'; bus.ram[fcb+13]='A'; bus.ram[fcb+14]='T';
        auto invoke=[&](uint8_t command,uint8_t value=0) {
            bus.ram[fcb]=command;
            call(bus,cpu,0xb406,fcb,value);
            require(bus.ram[fcb+1]==0,"Cannot create Z68 test fixture");
        };
        // Save the prompt's execution state while calling FMS directly.
        const auto state=cpu.s_;
        const auto prompt_stack=std::vector<uint8_t>(bus.ram.begin()+0x9e00,bus.ram.begin()+0xa000);
        invoke(2); bus.ram[fcb+59]=255;
        for(auto value:data) invoke(0,value);
        invoke(4);
        std::copy(prompt_stack.begin(),prompt_stack.end(),bus.ram.begin()+0x9e00);
        cpu.s_=state;
    };
    std::vector<uint8_t> header(64);
    header[0]=3; header[2]=9; header[3]=255;
    header[4]=0x23; header[5]=0x45;
    header[6]=0x24; header[7]=0x68;
    header[14]=0x12; header[15]=0x34;
    const std::string serial="261101";
    std::copy(serial.begin(),serial.end(),header.begin()+18);
    header[26]=255; header[27]=255; // 17-bit byte count $01FFFE.
    const auto raw_header=header;
    write_file("SHORT",header); // Valid header, truncated dynamic region.
    header.resize(0x1234);
    for(size_t i=64;i<header.size();++i) header[i]=uint8_t(i*37+9);
    const auto probe=header;
    write_file("PROBE",header);
    header[0]=5; write_file("V5",header);
    header[0]=3; header[14]=0; header[15]=0; write_file("BAD",header);
    header[14]=0x12; header[15]=0x34; header[4]=0x10; header[5]=0;
    write_file("BADHIGH",header);
    header[4]=0x23; header[5]=0x45; header[6]=0x10; header[7]=0;
    write_file("BADPC",header);
    header[14]=0x7f; header[15]=0; header[4]=0x7f; header[5]=0;
    header[6]=0x7f; header[7]=0; write_file("TOOBIG",header);
    auto minimal=raw_header;
    minimal[14]=0; minimal[15]=64;
    write_file("MINIMAL",minimal);
    // Leave plenty of space for this probe, but make the FLEX limit smaller
    // than the machine's physical RAM. Nothing in $4000-$7FFF may be touched.
    bus.ram[0xac2b]=0x5f; bus.ram[0xac2c]=0xff;
    std::fill(bus.ram.begin()+0x5de0,bus.ram.begin()+0x5e00,0x5a);
    std::fill(bus.ram.begin()+0x6000,bus.ram.begin()+0x8000,0xa5);
    auto output=run("Z68 3.PROBE.DAT\r");
    auto has=[&](const std::string &needle) {
        require(output.find(needle)!=std::string::npos,"Missing Z68 report: "+needle+"\n"+output);
    };
    has("Z68: V3 story header"); has("Release: $09FF"); has("Serial: 261101");
    has("Declared story bytes (zero=unknown): $01FFFE");
    has("Dynamic bytes: $1234"); has("High memory: $2345"); has("Initial PC: $2468");
    check_layout(probe,0x5fff);
    const auto expected_budget=0x6000-app_end-512-reservations;
    const auto budget=symbol("build/z68.lst","ram_budget");
    require(unsigned(bus.ram[budget])*256+bus.ram[budget+1]==expected_budget,
            "Z68 ignored FLEX's memory limit: "+output);
    output=run("Z68 3.PROBE\r"); has("Z68: V3 story header"); // default DAT
    output=run("Z68\r"); has("Usage: Z68");
    output=run("Z68 3.ABSENT.DAT\r"); has("cannot open story");
    output=run("Z68 3.V5.DAT\r"); has("only V3 is supported");
    output=run("Z68 3.BAD.DAT\r"); has("invalid V3 memory layout");
    output=run("Z68 3.BADHIGH.DAT\r"); has("invalid V3 memory layout");
    output=run("Z68 3.BADPC.DAT\r"); has("invalid V3 memory layout");
    output=run("Z68 3.SHORT.DAT\r"); has("cannot load dynamic memory");
    require(bus.ram[symbol("build/z68.lst","dynamic_loaded")]==0 &&
            bus.ram[symbol("build/z68.lst","story_opened")]==0,"Failed load leaked state");
    output=run("Z68 3.MINIMAL.DAT\r"); has("Loaded writable story bytes: $0040");
    check_layout(minimal,0x5fff);
    output=run("Z68 3.TOOBIG.DAT\r"); has("dynamic memory exceeds");
    // Exact fit succeeds; one byte less fails before touching dynamic RAM.
    const auto exact_top=app_end+reservations+512+probe.size()-1;
    bus.ram[0xac2b]=exact_top>>8; bus.ram[0xac2c]=exact_top&255;
    output=run("Z68 3.PROBE\r"); has("Loaded writable story bytes");
    check_layout(probe,exact_top);
    bus.ram[0xac2b]=(exact_top-1)>>8; bus.ram[0xac2c]=(exact_top-1)&255;
    std::fill(bus.ram.begin()+app_end,bus.ram.begin()+app_end+probe.size(),0xa7);
    output=run("Z68 3.PROBE\r"); has("dynamic memory exceeds");
    require(std::all_of(bus.ram.begin()+app_end,bus.ram.begin()+app_end+probe.size(),
                       [](uint8_t value){return value==0xa7;}),"Rejected layout wrote dynamic RAM");
    // Insufficient runtime RAM must be detected before switching stacks.
    bus.ram[0xac2b]=(app_end+255)>>8; bus.ram[0xac2c]=(app_end+255)&255;
    output=run("Z68 3.PROBE\r"); has("insufficient FLEX application RAM");
    require(std::all_of(bus.ram.begin()+0x6000,bus.ram.begin()+0x8000,
                       [](uint8_t value){return value==0xa5;}),"Z68 wrote above FLEX MEMEND");
    require(std::all_of(bus.ram.begin()+0x5de0,bus.ram.begin()+0x5e00,
                       [](uint8_t value){return value==0x5a;}),"Z68 stack exceeded its reservation");
    bus.ram[0xac2b]=0xff; bus.ram[0xac2c]=0xff;
    output=run("Z68 3.PROBE\r"); has("Z68: V3 story header");
    const auto top=symbol("build/z68.lst","ram_top");
    require(bus.ram[top]==0x7f && bus.ram[top+1]==0xff,"Z68 exceeded the $7FFF cap");
    require(bus.ram[symbol("build/z68.lst","story_opened")]==0,"Z68 leaked an open story");
    // A raw V3 fixture with strings in RAM, across FLEX sectors, and above 64 KiB.
    std::vector<uint8_t> text_story(0x10004);
    text_story[0]=3; text_story[4]=3; text_story[6]=3;
    text_story[14]=2; text_story[24]=0; text_story[25]=0x80;
    text_story[26]=0x80; text_story[27]=2;
    auto put_word=[&](size_t at,unsigned value) {
        text_story[at]=value>>8; text_story[at+1]=value&255;
    };
    auto put_text=[&](size_t at,std::vector<unsigned> chars) {
        while(chars.size()%3) chars.push_back(5);
        for(size_t n=0;n<chars.size();n+=3) {
            unsigned value=(chars[n]<<10)|(chars[n+1]<<5)|chars[n+2];
            if(n+3==chars.size()) value|=0x8000;
            put_word(at,value); at+=2;
        }
        return at;
    };
    put_text(0x180,{20,19,10}); // one
    put_text(0x188,{25,28,20}); // two
    put_text(0x1a0,{1,0,5});   // forbidden nested abbreviation
    put_word(0x80,0x180/2); put_word(0x82,0x1a0/2);
    put_word(0x80+64,0x188/2); put_word(0x80+128,0x10000/2);
    auto end_abbrev=put_text(0x300,{4,13,14,0,1,0,0,2,0,0,3,0,0,6});
    put_text(0x320,{5,6,2,1,5,7,5,6,0,0,6,5,6,31,31});
    put_text(0x340,{1,1,5}); // nested expansion must fail
    auto end_incomplete=put_text(0x350,{5,6,2}); // unfinished escape is legal
    std::vector<unsigned> punctuation;
    for(unsigned z=7;z<=31;++z) {punctuation.push_back(5);punctuation.push_back(z);}
    put_text(0x360,punctuation);
    put_text(0x2f2,{6,7,8,9,10,11,12,13,14}); // crosses 252-byte sector boundary
    put_text(0xfffe,{6,7,8,9,10,11,12,13,14}); // crosses $FFFF/$10000
    write_file("TEXT",text_story);
    auto preview=[&](const std::string &argument,const std::string &expected,unsigned end) {
        const auto out=run("Z68 3.TEXT.DAT "+argument+"\r");
        require(out.find("Decoded text (not story execution):\r\n"+expected+"\r\n")!=std::string::npos,
                "Packed-text mismatch: "+argument+"\n"+out);
        const auto cursor=symbol("build/z68.lst","text_cursor");
        require((unsigned(bus.ram[cursor])*65536+unsigned(bus.ram[cursor+1])*256+
                 bus.ram[cursor+2])==end,"Text cursor not restored/advanced correctly");
    };
    preview("300","Hi one two defghi a",end_abbrev);
    preview("320","A\r\na?",0x32a);
    preview("350","",end_incomplete);
    preview("360","\r\n0123456789.,!?_#'\"/\\-:()",0x382);
    preview("2f2","abcdefghi",0x2f8); // lowercase hex argument
    preview("0FFFE","abcdefghi",0x10004);
    preview("P 8000","defghi",0x10004);
    output=run("Z68 3.TEXT.DAT 340\r"); has("invalid or inaccessible packed text");
    output=run("Z68 3.TEXT.DAT 10004\r"); has("invalid or inaccessible packed text");
    output=run("Z68 3.TEXT.DAT 20000\r"); has("Usage:");
    // Check every slot and version without enabling an execution loop.
    const std::vector<std::vector<std::string>> names={
        {"rtrue","rfalse","print","print_ret","nop","save","restore","restart",
         "ret_popped","pop","quit","new_line","show_status","verify"},
        {"jz","get_sibling","get_child","get_parent","get_prop_len","inc","dec","print_addr",
         "","remove_obj","print_obj","ret","jump","print_paddr","load","not"},
        {"","je","jl","jg","dec_chk","inc_chk","jin","test","or","and","test_attr",
         "set_attr","clear_attr","store","insert_obj","loadw","loadb","get_prop",
         "get_prop_addr","get_next_prop","add","sub","mul","div","mod"},
        {"call","storew","storeb","put_prop","sread","print_char","print_num","random",
         "push","pull","split_window","set_window","","","","","","","",
         "output_stream","input_stream","sound_effect"}};
    const auto original_state=cpu.s_;
    const auto original_stack=std::vector<uint8_t>(bus.ram.begin()+0x9e00,bus.ram.begin()+0xa000);
    auto invoke_op=[&](const std::string &routine) {
        call(bus,cpu,symbol("build/z68.lst",routine),0);
        std::copy(original_stack.begin(),original_stack.end(),bus.ram.begin()+0x9e00);
    };
    const auto op_class=symbol("build/z68.lst","op_class");
    const auto op_number=symbol("build/z68.lst","op_number");
    const auto version=symbol("build/z68.lst","story_header");
    unsigned handlers=0;
    for(unsigned v=1;v<=3;++v) for(unsigned group=0;group<4;++group)
        for(unsigned number=0;number<32;++number) {
            const bool exists=number<names[group].size() && !names[group][number].empty();
            const bool needs_v3=(group==0 && number>=12) ||
                                (group==3 && (number==10 || number==11 || number>=19));
            const bool valid=exists && (!needs_v3 || v==3);
            bus.ram[version]=v; bus.ram[op_class]=group; bus.ram[op_number]=number;
            invoke_op("op_lookup");
            require(bool(cpu.s_.cc&1)==!valid,"Wrong opcode validity/version gate");
            if(valid) require(cpu.s_.x==symbol("build/z68.lst","op_"+names[group][number]),
                              "Opcode dispatched to wrong handler");
            if(v==3 && valid) {
                ++handlers;
                const std::vector<std::string> remaining={"save","restore","restart","show_status",
                    "split_window","set_window","output_stream","input_stream","sound_effect"};
                if(std::find(remaining.begin(),remaining.end(),names[group][number])==remaining.end()) continue;
                bus.output.clear();
                const auto before=std::vector<uint8_t>(bus.ram.begin()+app_end,bus.ram.begin()+app_end+64);
                const auto pc=symbol("build/z68.lst","op_pc");
                bus.ram[pc]=1; bus.ram[pc+1]=0x23; bus.ram[pc+2]=0x45;
                bus.ram[symbol("build/z68.lst","op_halted")]=0;
                invoke_op("op_dispatch");
                require((cpu.s_.cc&1) && bus.ram[symbol("build/z68.lst","op_halted")]==1,
                        "Unimplemented opcode did not halt");
                require(bus.output.find("unimplemented opcode "+names[group][number])!=std::string::npos &&
                        bus.output.find("012345")!=std::string::npos,"Missing opcode diagnostic/name/PC");
                require(std::equal(before.begin(),before.end(),bus.ram.begin()+app_end),
                        "Opcode stub changed story memory");
            }
        }
    require(handlers==68,"Incomplete V1-3 opcode scaffold");
    for(auto entry: {std::pair<unsigned,unsigned>{0,2},{0,5},{1,2},{1,5},{1,14},{2,13}}) {
        bus.ram[version]=3; bus.ram[op_class]=entry.first; bus.ram[op_number]=entry.second;
        invoke_op("op_lookup");
        const unsigned expected=entry.first==0 ? (entry.second==2 ? 4:2) :
                                entry.first==1 ? (entry.second==2 ? 3 : entry.second==5 ? 8:9):8;
        require(bus.ram[symbol("build/z68.lst","op_flags")]==expected,"Incorrect opcode suffix flags");
    }
    bus.ram[op_class]=4; bus.ram[op_number]=0; bus.output.clear();
    invoke_op("op_dispatch");
    require((cpu.s_.cc&1) && bus.output.find("invalid opcode")!=std::string::npos,"Invalid class accepted");
    cpu.s_=original_state;
    std::cout<<"All 68 V1-3 opcode slots, version gates, suffix flags and remaining trap diagnostics passed.\n";
    std::cout<<"V3 text alphabets, escapes, abbreviation frames, sector crossings and 17-bit addresses passed.\n";
    std::cout<<"Z68 writable-memory loading, full layout, exact-fit/overflow, EOF recovery, and RAM limits passed.\n";
}
