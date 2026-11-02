#include "flex_harness.h"

int main() {
    std::ofstream("build/acceptance.json")<<"{\n  \"czech_status\": \"error\",\n  \"detail\": \"acceptance run incomplete\"\n}\n";
    try {
        Bus bus; Cpu cpu(bus);
        const auto wait=symbol("build/c68flex.lst","C68INW");
        auto run=[&](const std::string &keys) {
            bus.output.clear(); size_t next=0;
            for(unsigned n=0;n<30000000;++n) {
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
        require(byte("vm_raw_opcode")==0xe0 && byte("op_class")==3 && byte("op_number")==0 &&
                byte("vm_operand_count")==1 && byte("vm_operand_types")==0 &&
                word("vm_operands")==((unsigned(czech[unsigned(czech[6])*256+czech[7]+2])*256)+
                                     czech[unsigned(czech[6])*256+czech[7]+3]) &&
                byte("vm_store_variable")==255,"CZECH bootstrap call decoded incorrectly");
        require(output.find("unimplemented opcode call")!=std::string::npos &&
                byte("vm_finished")==0 && byte("op_halted")==1,"CZECH blocker missing or falsely completed");
        require(byte("story_opened")==0,"Acceptance run leaked its story file");
        std::ofstream("build/acceptance.json")
            <<"{\n  \"bootstrap_gates_passed\": 6,\n  \"czech_status\": \"blocked\",\n"
            <<"  \"blocker\": \"call (VAR:00)\",\n  \"czech_checks_passed\": 0,\n"
            <<"  \"czech_expected_automatic\": 349,\n  \"czech_visual_checks\": 19\n}\n";
        std::cout<<"Acceptance: 6 bootstrap gates passed; CZECH BLOCKED at call (0 CZECH checks passed).\n";
        return 0;
    } catch(const std::exception &error) {
        std::cerr<<error.what()<<"\n";return 1;
    }
}
