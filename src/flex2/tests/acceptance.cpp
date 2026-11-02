#include "flex_harness.h"

int main() {
    std::ofstream("build/acceptance.json")<<"{\n  \"czech_status\": \"error\",\n  \"detail\": \"acceptance run incomplete\"\n}\n";
    try {
        Bus bus; Cpu cpu(bus);
        const auto wait=symbol("build/c68flex.lst","C68INW");
        auto run=[&](const std::string &keys) {
            bus.output.clear(); size_t next=0;
            for(unsigned n=0;n<500000000;++n) {
                if(cpu.s_.pc==wait && bus.input<0) {
                    if(next<keys.size()) bus.input=uint8_t(keys[next++]);
                    else {
                        auto out=bus.output;
                        out.erase(std::remove(out.begin(),out.end(),char(0)),out.end());
                        if(out.size()>=3 && out.substr(out.size()-3)=="+++") return out;
                    }
                }
                cpu.step();
            }
            throw std::runtime_error("Acceptance command timed out: "+keys);
        };
        auto byte=[&](const std::string &name) {return bus.ram[symbol("build/z68.lst",name)];};
        auto word=[&](const std::string &name) {
            const auto p=symbol("build/z68.lst",name);return unsigned(bus.ram[p])*256+bus.ram[p+1];
        };
        std::copy_n(bus.disk.begin(),256,bus.ram.begin()+0x100);cpu.s_.pc=0x100;
        run("11,02,26\r");
        auto build_output=run("LIST 0.BUILD.TXT\r");
        auto build_stamp=file("build/BUILD.TXT");
        std::string build_text(build_stamp.begin(),build_stamp.end());
        // LIST may insert LF after CR; compare printable stamp lines.
        size_t start=0;
        while(start<build_text.size()) {
            auto end=build_text.find('\r',start);
            if(end==std::string::npos) end=build_text.size();
            require(build_output.find(build_text.substr(start,end-start))!=std::string::npos,
                    "Build information not readable through FLEX LIST: "+build_output);
            start=end+1;
        }
        std::ofstream("build/build-info-list.txt")<<build_output;
        const auto czech=file("build/CZECH.DAT");
        require(czech[0]==3,"Acceptance story is not V3");
        auto output=run("Z68 3.CZECH.DAT\r");
        require(output.find("Loaded writable story bytes")!=std::string::npos,"CZECH did not load");
        const unsigned dynamic=unsigned(czech[14])*256+czech[15];
        const auto base=word("dynamic_start");
        require(std::equal(czech.begin(),czech.begin()+dynamic,bus.ram.begin()+base),"CZECH writable bytes differ");
        std::ofstream("build/czech-load.txt")<<output;
        // Exercise forms/suffixes in writable story RAM without executing them.
        struct DecodeCase {
            std::vector<uint8_t> code;
            unsigned group, number, count, store, branch1, branch2;
            std::vector<unsigned> values,types;
        };
        const std::vector<DecodeCase> cases={
            {{0x14,10,20,16},2,20,2,16,0,0,{10,20},{1,1}},
            {{0x74,0,16,17},2,20,2,17,0,0,{0,16},{2,2}},
            {{0x92,1,16,0xc1},1,2,1,16,0xc1,0,{1},{1}},
            {{0x80,0,0,0xc2},1,0,1,0,0xc2,0,{0},{0}},
            {{0xb5,0x82,0},0,5,0,0,0x82,0,{},{}},
            {{0xc1,0x55,5,4,3,2,0xc2},2,1,4,0,0xc2,0,{5,4,3,2},{1,1,1,1}},
            {{0xe0,3,0x2a,0x39,0x80,0x10,0xff,0xff,0},3,0,3,0,0,0,{0x2a39,0x8010,65535},{0,0,0}}
        };
        const auto saved_cpu=cpu.s_;
        const auto saved_stack=std::vector<uint8_t>(bus.ram.begin()+0x9e00,bus.ram.begin()+0xa000);
        const auto scratch=base+0x400;
        const auto original=std::vector<uint8_t>(bus.ram.begin()+scratch,bus.ram.begin()+scratch+32);
        const auto vm_pc=symbol("build/z68.lst","vm_pc");
        const auto operands=symbol("build/z68.lst","vm_operands");
        const auto types=symbol("build/z68.lst","vm_operand_types");
        for(const auto &test:cases) {
            std::copy(test.code.begin(),test.code.end(),bus.ram.begin()+scratch);
            bus.ram[vm_pc]=0;bus.ram[vm_pc+1]=4;bus.ram[vm_pc+2]=0;
            const auto stack_before=word("vm_stack_pointer");
            call(bus,cpu,symbol("build/z68.lst","vm_decode"),0);
            require(!(cpu.s_.cc&1) && byte("op_class")==test.group && byte("op_number")==test.number &&
                    byte("vm_operand_count")==test.count && byte("vm_store_variable")==test.store &&
                    byte("vm_branch_first")==test.branch1 && byte("vm_branch_second")==test.branch2 &&
                    unsigned(bus.ram[vm_pc+1])*256+bus.ram[vm_pc+2]==0x400+test.code.size(),
                    "Instruction form/suffix/PC decode failed");
            for(unsigned n=0;n<test.count;++n)
                require(unsigned(bus.ram[operands+n*2])*256+bus.ram[operands+n*2+1]==test.values[n] &&
                        bus.ram[types+n]==test.types[n],"Raw operand types/values lost");
            require(word("vm_stack_pointer")==stack_before,"Raw decoding resolved/popped variables");
        }
        bus.ram[scratch]=0xbe; // V5 extended prefix is invalid in V3.
        bus.ram[vm_pc]=0;bus.ram[vm_pc+1]=4;bus.ram[vm_pc+2]=0;
        call(bus,cpu,symbol("build/z68.lst","vm_decode"),0);
        require(cpu.s_.cc&1,"V4+ opcode accepted in V3");
        std::copy(original.begin(),original.end(),bus.ram.begin()+scratch);
        std::copy(saved_stack.begin(),saved_stack.end(),bus.ram.begin()+0x9e00);
        cpu.s_=saved_cpu;
        output=run("Z68 3.VMBOOT.DAT RUN\r");
        require(output.find("Z68 execution smoke test")!=std::string::npos &&
                byte("vm_finished")==1 && byte("op_halted")==0,"Print/nop/newline/quit execution failed: "+output);
        std::ofstream("build/vmboot.txt")<<output;
        output=run("Z68 3.VMFAIL.DAT RUN\r");
        require(output.find("invalid/truncated instruction")!=std::string::npos &&
                byte("vm_finished")==0 && byte("op_halted")==1,"Truncated operand/store accepted");
        output=run("Z68 3.VMLIMIT.DAT RUN\r");
        require(output.find("execution step limit")!=std::string::npos &&
                byte("vm_finished")==0,"Instruction budget did not stop execution");
        output=run("Z68 3.CZECH.DAT RUN\r");
        std::ofstream("build/czech-actual.txt")<<output;
        std::smatch summary;
        require(std::regex_search(output,summary,std::regex("Passed: ([0-9]+), Failed: ([0-9]+), Print tests: ([0-9]+)")),
                "CZECH did not reach its test summary: "+output);
        const unsigned passed=std::stoul(summary[1]), failed=std::stoul(summary[2]), visual=std::stoul(summary[3]);
        require(passed==349 && failed==0 && visual==19 && byte("vm_finished")==1 &&
                byte("op_halted")==0 && byte("vm_input_requested")==0,
                "CZECH automatic checks failed or execution did not quit: "+output);
        require(byte("story_opened")==0,"Acceptance run leaked its story file");
        bool zork=false;
        // The copyrighted story is optional and supplied locally by its owner.
        std::ifstream local("../z68/stories/ZORK1.DAT",std::ios::binary);
        if(local.good()) {
            output=run("Z68 3.ZORK1.DAT RUN\r");
            std::ofstream("build/zork-startup.txt")<<output;
            const auto title=output.find("ZORK I: The Great Underground Empire");
            const auto room=output.find("West of House",title);
            const auto description=output.find("You are standing in an open field west of a white house",room);
            const auto mailbox=output.find("There is a small mailbox here.",description);
            const auto prompt=output.find(">",mailbox);
            const auto boundary=output.find("first input request reached",prompt);
            require(title!=std::string::npos && room!=std::string::npos && description!=std::string::npos &&
                    mailbox!=std::string::npos && prompt!=std::string::npos && boundary!=std::string::npos &&
                    byte("vm_input_requested")==1 && byte("vm_finished")==0 && byte("op_halted")==0,
                    "Zork failed to reach the first prompt normally: "+output);
            require(byte("story_opened")==0,"Zork input boundary leaked its story file");
            require((bus.ram[word("dynamic_start")+1]&0x70)==0x10,"Serial terminal capabilities incorrect");
            zork=true;
        }
        std::ofstream("build/acceptance.json")
            <<"{\n  \"bootstrap_gates_passed\": 6,\n  \"czech_status\": \"passed\",\n"
            <<"  \"czech_checks_passed\": "<<passed<<",\n  \"czech_checks_failed\": "<<failed<<",\n"
            <<"  \"czech_expected_automatic\": 349,\n  \"czech_visual_checks\": "<<visual<<",\n"
            <<"  \"zork_first_prompt\": "<<(zork?"true":"null")<<"\n}\n";
        std::cout<<"Acceptance: 6 bootstrap gates; CZECH 349 automatic checks passed (19 visual checks require review).\n";
        std::cout<<(zork?"Zork opening, West of House, mailbox and first input prompt passed.\n":
                         "Zork startup skipped: no local ZORK1.DAT.\n");
        return 0;
    } catch(const std::exception &error) {
        std::cerr<<error.what()<<"\n";return 1;
    }
}
