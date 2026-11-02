// Small VT100 model for the subset emitted by Z68. Rows/columns are zero-based.
struct StatusTerminal {
    std::array<std::string,24> rows;
    unsigned row=0,col=0,top=0,bottom=23,saved_row=0,saved_col=0;
    bool reverse=false,saved_reverse=false,wrap=false;
    StatusTerminal(){for(auto &r:rows)r=std::string(80,' ');}
    void newline(){if(row==bottom){for(unsigned n=top;n<bottom;++n)rows[n]=rows[n+1];rows[bottom]=std::string(80,' ');}else if(row<23)++row;wrap=false;}
    void feed(const std::string &s){
        for(size_t i=0;i<s.size();++i){
            unsigned char ch=s[i];
            if(ch==27){
                require(++i<s.size(),"Truncated terminal escape");
                if(s[i]=='7'){saved_row=row;saved_col=col;saved_reverse=reverse;continue;}
                if(s[i]=='8'){row=saved_row;col=saved_col;reverse=saved_reverse;wrap=false;continue;}
                require(s[i]=='[',"Unexpected terminal escape");
                std::vector<unsigned> args;unsigned value=0;bool digits=false;
                while(++i<s.size() && (std::isdigit(static_cast<unsigned char>(s[i])) || s[i]==';')){
                    if(s[i]==';'){args.push_back(value);value=0;}else{digits=true;value=value*10+s[i]-'0';}
                }
                if(digits || !args.empty())args.push_back(value);
                require(i<s.size(),"Truncated CSI");
                auto a=[&](unsigned n,unsigned fallback){return n<args.size()&&args[n]?args[n]:fallback;};
                switch(s[i]){
                    case 'H':row=a(0,1)-1;col=a(1,1)-1;wrap=false;break;
                    case 'r':top=a(0,1)-1;bottom=a(1,24)-1;row=col=0;wrap=false;break;
                    case 'J':require(a(0,0)==2,"Unexpected erase mode");for(auto &r:rows)r=std::string(80,' ');break;
                    case 'm':reverse=a(0,0)==7;break;
                    default:throw std::runtime_error("Unexpected CSI final");
                }
                require(row<24 && col<80 && top<=bottom && bottom<24,"Invalid terminal position/margins");
            }else if(ch=='\r'){col=0;wrap=false;}
            else if(ch=='\n')newline();
            else if(ch=='\b'){if(col)--col;wrap=false;}
            else if(ch>=32 && ch<127){if(wrap){col=0;newline();}rows[row][col]=ch;if(col==79)wrap=true;else ++col;}
        }
    }
};

static void status_test(){
    Bus bus;Cpu cpu(bus);
    auto flex=file("build/c68flex.bin"),app=file("build/z68.bin");
    std::copy(flex.begin(),flex.end(),bus.ram.begin()+0xa100);
    std::copy(app.begin(),app.end(),bus.ram.begin()+0x300);
    auto sym=[](const std::string &s){return symbol("build/z68.lst",s);};
    auto put=[&](unsigned p,unsigned v){bus.ram[p]=v>>8;bus.ram[p+1]=v;};
    const auto base=sym("app_end"),header=sym("story_header"),resolved=sym("vm_resolved"),value=sym("vm_value");
    put(sym("dynamic_size"),2048);put(sym("dynamic_end"),base+2048);
    put(header+10,0x300);put(header+12,64);put(base+0x300+62+7,0x400);
    put(base+64,1);put(base+66,uint16_t(-12));put(base+68,345);
    auto room=[&](const std::string &s){
        std::vector<unsigned> z;for(char c:s)z.push_back(c==' '?0:c-'a'+6);
        while(z.size()%3)z.push_back(5);bus.ram[base+0x400]=z.size()/3;
        for(unsigned n=0;n<z.size();n+=3)put(base+0x401+2*(n/3),(n+3==z.size()?0x8000:0)|(z[n]<<10)|(z[n+1]<<5)|z[n+2]);
    };
    auto run=[&](const std::string &s){call(bus,cpu,sym(s),0);require(!(cpu.s_.cc&1),"Status routine failed: "+s);};
    bus.output.clear();bus.ram[sym("terminal_enabled")]=0;run("terminal_begin");run("vm_do_show_status");run("terminal_end");
    require(bus.output.empty(),"Plain mode emitted terminal controls");
    bus.ram[sym("terminal_enabled")]=1;room("test room");run("terminal_begin");run("wrap_begin");
    StatusTerminal screen;screen.feed(bus.output);bus.output.clear();screen.feed("story prompt>");
    const auto old_row=screen.row,old_col=screen.col;
    put(resolved,0x1234);put(value,0x5678);put(sym("vm_pc")+1,0xabcd);
    run("vm_do_show_status");screen.feed(bus.output);
    require(screen.rows[0].substr(1,9)=="test room" && screen.rows[0].find("Score: -12 Moves: 345")!=std::string::npos,"Score status content");
    require(screen.row==old_row && screen.col==old_col && !screen.reverse,"Status damaged cursor/attributes: got "+std::to_string(screen.row)+","+std::to_string(screen.col)+","+std::to_string(screen.reverse)+" expected "+std::to_string(old_row)+","+std::to_string(old_col));
    require(bus.ram[resolved]==0x12 && bus.ram[resolved+1]==0x34 && bus.ram[value]==0x56 && bus.ram[value+1]==0x78 &&
            bus.ram[sym("vm_pc")+1]==0xab && bus.ram[sym("vm_pc")+2]==0xcd,"Status damaged VM operands/value/PC");
    auto bar=screen.rows[0];for(unsigned n=0;n<40;++n)screen.feed("\r\nscrolling story");
    require(screen.rows[0]==bar,"Story scrolling erased status row");
    room(std::string(70,'a'));bus.output.clear();run("vm_do_show_status");screen.feed(bus.output);
    require(screen.rows[0].substr(45,3)=="..." && screen.rows[0].find("Moves: 345")!=std::string::npos,"Long room overwrote status fields");
    room("test room");bus.ram[base+1]=2;put(base+66,8);put(base+68,5);
    bus.output.clear();run("vm_do_show_status");screen.feed(bus.output);
    require(screen.rows[0].find("Time: 08:05")!=std::string::npos && screen.rows[0].find("Moves:")==std::string::npos,"Time status/old text clearing");
    bus.output.clear();run("wrap_finish");run("terminal_end");screen.feed(bus.output);
    require(screen.top==0 && screen.bottom==23 && !screen.reverse && !bus.ram[sym("terminal_active")],"FLEX terminal cleanup");
    bus.output.clear();run("terminal_end");require(bus.output.empty(),"Terminal cleanup not idempotent");
    std::cout<<"Z68 VT100 status: score/time, clipping, cursor, scrolling, VM state and cleanup passed.\n";
}
