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
    const auto line_entry=sym("input_read_line");
    const auto sector_entry=sym("story_read_sector"), miss_entry=sym("memory_cache_miss");
    unsigned sector_reads=0,cache_misses=0,first_reads=0,first_misses=0;uint32_t first_cycles=0;
    const auto pc=sym("op_pc"), group=sym("op_class"), number=sym("op_number"), args=sym("vm_resolved"), count=sym("vm_operand_count");
    std::deque<std::string> trace;unsigned seen[4][32]={};
    auto run=[&](const std::string &initial,const std::string &line=std::string()){
      auto keys=initial;bool queued=false;
      bus.output.clear();size_t next=0;
      for(unsigned n=0;n<500000000;++n){
       if(cpu.s_.pc==sector_entry)++sector_reads;
       if(cpu.s_.pc==miss_entry)++cache_misses;
       if(cpu.s_.pc==line_entry){
          if(queued && next==keys.size()) {auto out=bus.output;out.erase(std::remove(out.begin(),out.end(),char(0)),out.end());return out;}
          if(!queued){first_cycles=cpu.cycles_;first_reads=sector_reads;first_misses=cache_misses;keys+=line;queued=true;}
       }
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
    cpu.cycles_=0;sector_reads=cache_misses=0;
    auto output=run("Z68 1."+name+".DAT RUN\r",name=="CZECH"?"":name=="ZORK1"?"OPEN MAILBOX\r":"LOOK\r");
    std::ofstream("build/"+name+"-run.txt")<<output;std::cout<<output<<"\nLast operations:\n";
    for(auto &r:trace)std::cout<<r<<"\n";
    std::cout<<"Performance: startup cycles="<<first_cycles<<" sector_reads="<<first_reads<<" cache_misses="<<first_misses<<"\n";
    std::cout<<"Performance: command cycles="<<uint32_t(cpu.cycles_-first_cycles)<<" sector_reads="<<sector_reads-first_reads<<" cache_misses="<<cache_misses-first_misses<<"\n";
    std::cout<<"Executed opcode counts:\n";
    for(unsigned g=0;g<4;++g)for(unsigned n=0;n<32;++n)if(seen[g][n])std::cout<<std::hex<<g<<":"<<n<<std::dec<<" "<<seen[g][n]<<"\n";
    if(argc>2 && std::string(argv[2])=="--expect-prompt") {
        require(output.find(">")!=std::string::npos && bus.ram[sym("vm_input_requested")]==1 &&
                bus.ram[sym("vm_input_complete")]==0 &&
                !bus.ram[sym("op_halted")] && !bus.ram[sym("vm_finished")],
                "Story failed to reach the expected first input prompt");
        const std::string expected=name=="ZORK1"?"open mailbox":"look";
        const auto address=sym("input_text_address");
        const unsigned offset=unsigned(bus.ram[address])*256+bus.ram[address+1];
        const unsigned text=sym("app_end")+offset;
        require(text+1+expected.size()<65536 &&
                bus.ram[sym("input_length")]==expected.size() &&
                std::string(bus.ram.begin()+text+1,bus.ram.begin()+text+1+expected.size())==expected &&
                bus.ram[text+1+expected.size()]==0,
                "Captured command differs in the story text buffer");
        std::cout<<"First prompt and story text buffer passed: "<<name<<" ("<<expected<<").\n";
    }
    return 0;
 }catch(const std::exception &e){std::cerr<<e.what()<<"\n";return 1;}
}
