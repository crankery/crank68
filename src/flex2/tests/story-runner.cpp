// Run a real FLEX command, retaining the transcript and last decoded operations.
#include "flex_harness.h"
#include <deque>
#include <iomanip>
#include <sstream>
int main(int argc,char **argv) {
 try {
    Bus bus;Cpu cpu(bus);
    auto sym=[](const std::string &s){return symbol("build/z68.lst",s);};
    const auto wait=symbol("build/c68flex.lst","C68INW"), dispatch=sym("op_dispatch");
    const auto pc=sym("op_pc"), group=sym("op_class"), number=sym("op_number"), args=sym("vm_resolved"), count=sym("vm_operand_count");
    std::deque<std::string> trace;unsigned seen[4][32]={};
    auto run=[&](const std::string &keys){
      bus.output.clear();size_t next=0;
      for(unsigned n=0;n<500000000;++n){
       if(cpu.s_.pc==dispatch){
        std::ostringstream row;row<<std::hex<<std::setfill('0')<<std::setw(2)<<unsigned(bus.ram[pc])<<std::setw(2)<<unsigned(bus.ram[pc+1])<<std::setw(2)<<unsigned(bus.ram[pc+2])<<" "<<unsigned(bus.ram[group])<<":"<<unsigned(bus.ram[number]);
        for(unsigned i=0;i<bus.ram[count];++i)row<<" "<<std::setw(4)<<(unsigned(bus.ram[args+2*i])*256+bus.ram[args+2*i+1]);
        trace.push_back(row.str());if(trace.size()>24)trace.pop_front();
        if(bus.ram[group]<4 && bus.ram[number]<32)++seen[bus.ram[group]][bus.ram[number]];
       }
       if(cpu.s_.pc==wait && bus.input<0){
        if(next<keys.size())bus.input=uint8_t(keys[next++]);
        else {auto out=bus.output;out.erase(std::remove(out.begin(),out.end(),char(0)),out.end());
          if(out.size()>=3 && out.substr(out.size()-3)=="+++")return out;}
       }
       cpu.step();
      }
      throw std::runtime_error("Story command timed out PC="+std::to_string(cpu.s_.pc));
    };
    std::copy_n(bus.disk.begin(),256,bus.ram.begin()+0x100);cpu.s_.pc=0x100;
    run("11,02,26\r");
    const std::string name=argc>1?argv[1]:"ZORK1";
    auto output=run("Z68 3."+name+".DAT RUN\r");
    std::ofstream("build/"+name+"-run.txt")<<output;std::cout<<output<<"\nLast operations:\n";
    for(auto &r:trace)std::cout<<r<<"\n";
    std::cout<<"Executed opcode counts:\n";
    for(unsigned g=0;g<4;++g)for(unsigned n=0;n<32;++n)if(seen[g][n])std::cout<<std::hex<<g<<":"<<n<<std::dec<<" "<<seen[g][n]<<"\n";
    if(argc>2 && std::string(argv[2])=="--expect-prompt") {
        require(output.find("West of House")!=std::string::npos &&
                output.find("There is a small mailbox here.")!=std::string::npos &&
                output.find(">")!=std::string::npos && bus.ram[sym("vm_input_requested")]==1 &&
                !bus.ram[sym("op_halted")] && !bus.ram[sym("vm_finished")],
                "Story failed to reach the expected first input prompt");
    }
    return 0;
 }catch(const std::exception &e){std::cerr<<e.what()<<"\n";return 1;}
}
