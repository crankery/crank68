#include "flex_harness.h"
#include <queue>
#include <set>

static constexpr int MAP_W=60, MAP_H=20, MAP_N=MAP_W*MAP_H;
static unsigned word(const Bus &b, unsigned a) { return unsigned(b.ram[a])*256+b.ram[a+1]; }
static bool walkable(char c) { return c=='.'||c=='#'||c=='+'||c=='*'||c=='%'||c=='<'; }

struct Addresses {
    unsigned map=symbol("build/rogue.lst","map");
    unsigned seen=symbol("build/rogue.lst","seen");
    unsigned rooms=symbol("build/rogue.lst","rooms");
    unsigned player=symbol("build/rogue.lst","player_index");
    unsigned up=symbol("build/rogue.lst","up_index");
    unsigned down=symbol("build/rogue.lst","stairs_index");
    unsigned down_room=symbol("build/rogue.lst","stairs_room");
    unsigned arrival=symbol("build/rogue.lst","arrival_slot");
    unsigned depth=symbol("build/rogue.lst","depth");
    unsigned new_level=symbol("build/rogue.lst","new_level");
    unsigned load_floor=symbol("build/rogue.lst","load_floor");
};

static std::string validate(const Bus &b, const Addresses &a, int seed, bool arrived=true) {
    auto check=[&](bool ok,const std::string &what) {
        require(ok,"seed "+std::to_string(seed)+": "+what);
    };
    std::string layout;
    std::vector<int> owner(MAP_N,-1);
    int floor_count=0;
    for(int y=0;y<MAP_H;++y) for(int x=0;x<MAP_W;++x) {
        char c=b.ram[a.map+y*MAP_W+x]; layout+=c;
        check(c==' '||c=='-'||c=='|'||walkable(c),"unknown map tile");
        if(y==0||y==MAP_H-1||x==0||x==MAP_W-1) check(c==' ',"tile on screen boundary");
    }
    for(int i=0;i<9;++i) {
        auto p=a.rooms+6*i;
        int l=b.ram[p],r=b.ram[p+1],t=b.ram[p+2],bot=b.ram[p+3];
        check(l>=1&&r<=58&&t>=1&&bot<=18,"room outside bounds");
        check(r-l+1>=12&&r-l+1<=16&&bot-t+1>=4&&bot-t+1<=5,"room size");
        check(b.ram[p+4]>l&&b.ram[p+4]<r&&b.ram[p+5]>t&&b.ram[p+5]<bot,"room center");
        for(int y=t;y<=bot;++y) for(int x=l;x<=r;++x) {
            int pos=y*MAP_W+x; check(owner[pos]<0,"overlapping rooms"); owner[pos]=i;
            char c=layout[pos];
            if(y==t||y==bot) check(c=='-'||c=='+',"broken horizontal wall");
            else if(x==l||x==r) check(c=='|'||c=='+',"broken vertical wall");
            else {check(c=='.'||c=='*'||c=='%'||c=='<',"broken room interior"); ++floor_count;}
        }
    }
    check(floor_count>=180,"too little room floor");
    for(int band=0;band<2;++band) {
        int bridges=0;
        for(int column=0;column<3;++column) {
            auto upper=a.rooms+6*(band*3+column);
            auto lower=upper+18;
            for(int x=std::max(int(b.ram[upper]),int(b.ram[lower]))+1;
                x<std::min(int(b.ram[upper+1]),int(b.ram[lower+1]));++x) {
                if(layout[b.ram[upper+3]*MAP_W+x]=='+'&&
                   layout[b.ram[lower+2]*MAP_W+x]=='+') {++bridges;break;}
            }
        }
        check(bridges==2,"expected two vertical bridges between room bands");
    }
    auto up=word(b,a.up),down=word(b,a.down);
    check(up<MAP_N&&down<MAP_N&&up!=down,"stair offsets");
    check(layout[up]=='<'&&layout[down]=='%',"stair tiles");
    check(std::count(layout.begin(),layout.end(),'<')==1&&std::count(layout.begin(),layout.end(),'%')==1,"stair count");
    if(arrived) check(word(b,a.player)==up,"player did not arrive on upstairs");
    check(b.ram[a.arrival]<9&&b.ram[a.down_room]<9&&b.ram[a.arrival]!=b.ram[a.down_room],"stair rooms");
    std::vector<int> dist(MAP_N,-1); std::queue<int> q; q.push(up); dist[up]=0;
    while(!q.empty()) {
        int v=q.front();q.pop();
        for(int d:{-MAP_W,MAP_W,-1,1}) {
            int u=v+d;
            if(u>=0&&u<MAP_N&&dist[u]<0&&walkable(layout[u])) {dist[u]=dist[v]+1;q.push(u);}
        }
    }
    check(dist[down]>=0,"downstairs unreachable");
    for(int i=0;i<MAP_N;++i) if(walkable(layout[i])) check(dist[i]>=0,"isolated passable tile");
    return layout;
}

int main() {
    try {
        Bus bus; Cpu cpu(bus); Addresses a;
        auto inwait=symbol("build/c68flex.lst","C68INW");
        auto run=[&](const std::string &keys,const std::string &marker) {
            bus.output.clear(); size_t next=0;
            for(unsigned n=0;n<30000000;++n) {
                if(cpu.s_.pc==inwait&&bus.input<0&&next<keys.size()) bus.input=uint8_t(keys[next++]);
                cpu.step();
                if(next==keys.size()&&cpu.s_.pc==inwait&&bus.input<0&&
                   (marker.empty()||bus.output.find(marker)!=std::string::npos))
                    return bus.output;
            }
            throw std::runtime_error("ROGUE command timed out at PC="+std::to_string(cpu.s_.pc));
        };
        std::copy_n(bus.disk.begin(),256,bus.ram.begin()+0x100);cpu.s_.pc=0x100;
        auto intro=run("11,01,26\rROGUE\r","h j k l move");
        require(intro.find("   v7")!=std::string::npos,"version marker");
        require(intro.find("\x1b[?25l")!=std::string::npos,"cursor hide");
        validate(bus,a,0);
        int arrival=bus.ram[a.arrival];
        auto p=a.rooms+6*arrival;
        for(int y=bus.ram[p+2];y<=bus.ram[p+3];++y)
            for(int x=bus.ram[p];x<=bus.ram[p+1];++x)
                require(bus.ram[a.seen+y*MAP_W+x]!=0,"initial room not revealed");
        int other=(arrival+1)%9; p=a.rooms+6*other;
        require(bus.ram[a.seen+bus.ram[p+5]*MAP_W+bus.ram[p+4]]==0,"remote room revealed");
        int before=word(bus,a.player);
        auto move=run("l","");
        require(word(bus,a.player)==unsigned(before+1),"movement right");
        require(move.find("\r\n")==std::string::npos,"move scrolled terminal");
        run("h","");
        require(word(bus,a.player)==unsigned(before),"movement left");

        // Navigate using the generated map, then verify stair continuity.
        auto map=validate(bus,a,0);
        int target=word(bus,a.down),start=word(bus,a.player);
        std::vector<int> prev(MAP_N,-1); std::queue<int> q;q.push(start);prev[start]=start;
        for(;!q.empty();) {
            int v=q.front();q.pop(); if(v==target) break;
            for(int d:{-MAP_W,MAP_W,-1,1}) {
                int u=v+d;
                if(u>=0&&u<MAP_N&&prev[u]<0&&walkable(map[u])) {prev[u]=v;q.push(u);}
            }
        }
        require(prev[target]>=0,"test route to stairs");
        std::string path;
        for(int v=target;v!=start;v=prev[v]) {
            int d=v-prev[v];path+=d==-MAP_W?'k':d==MAP_W?'j':d==-1?'h':'l';
        }
        std::reverse(path.begin(),path.end());
        run(path,"");
        require(word(bus,a.player)==unsigned(target),"walk to downstairs");
        int old_down_room=bus.ram[a.down_room];
        run(">","");
        require(bus.ram[a.depth]==2&&bus.ram[a.arrival]==old_down_room,"descent or arrival slot");
        require(validate(bus,a,0)!=map,"descent repeated same layout");
        auto walk_to=[&](int goal) {
            auto level=validate(bus,a,bus.ram[a.depth],false);
            int from=word(bus,a.player);
            std::vector<int> parent(MAP_N,-1);std::queue<int> queue;
            queue.push(from);parent[from]=from;
            while(!queue.empty()&&parent[goal]<0) {
                int v=queue.front();queue.pop();
                for(int d:{-MAP_W,MAP_W,-1,1}) {
                    int u=v+d;
                    if(u>=0&&u<MAP_N&&parent[u]<0&&walkable(level[u])) {
                        parent[u]=v;queue.push(u);
                    }
                }
            }
            require(parent[goal]>=0,"test route to room");
            std::string directions;
            for(int v=goal;v!=from;v=parent[v]) {
                int d=v-parent[v];directions+=d==-MAP_W?'k':d==MAP_W?'j':d==-1?'h':'l';
            }
            std::reverse(directions.begin(),directions.end());
            if(!directions.empty()) run(directions,"");
            require(word(bus,a.player)==unsigned(goal),"movement failed on depth "+
                    std::to_string(bus.ram[a.depth])+" at goal "+std::to_string(goal));
        };
        walk_to(word(bus,a.down));
        run(">","");
        require(bus.ram[a.depth]==3,"did not reach floor 3");
        for(int i=0;i<9;++i) {
            auto room=a.rooms+6*i;
            int goal=bus.ram[room+5]*MAP_W+bus.ram[room+4];
            walk_to(goal);
            require(bus.ram[a.seen+goal]!=0,"room not revealed after entry");
        }
        auto goodbye=run("Q","");
        require(goodbye.find("\x1b[?25h")!=std::string::npos,"cursor restore");

        std::set<std::string> layouts;
        std::set<int> widths, lefts;
        int previous_down=-1;
        for(int depth=1;depth<=26;++depth) {
            auto name=std::string("build/RFL")+(depth<10?"0":"")+std::to_string(depth)+".DAT";
            auto data=file(name.c_str());
            require(data.size()==1262&&std::equal(data.begin(),data.begin()+4,"RFL1"),"floor file header");
            require(data[4]==depth&&data[5]<9&&data[6]<9&&data[5]!=data[6],"floor file stairs");
            unsigned checksum=0;
            for(size_t i=4;i<data.size()-1;++i) checksum^=data[i];
            require(checksum==data.back(),"floor file checksum");
            if(previous_down>=0) require(data[5]==previous_down,"floor file stair chain");
            previous_down=data[6];
            bus.ram[a.depth]=depth-1;
            bus.ram[a.arrival]=data[5];
            bus.output.clear();
            call(bus,cpu,a.new_level,0);
            require(bus.ram[a.depth]==depth,"loaded depth");
            require(std::equal(data.begin()+61,data.begin()+1261,bus.ram.begin()+a.map),"disk map differs from loaded map");
            require(std::equal(data.begin()+7,data.begin()+61,bus.ram.begin()+a.rooms),"disk rooms differ from loaded rooms");
            layouts.insert(validate(bus,a,depth));
            widths.insert(bus.ram[a.rooms+1]-bus.ram[a.rooms]+1);
            lefts.insert(bus.ram[a.rooms]);
        }
        require(layouts.size()==26,"duplicate floor layouts");
        require(widths.size()>=4&&lefts.size()>=2,"room dimensions or placement did not vary");
        bus.ram[a.depth]=27;
        call(bus,cpu,a.load_floor,0);
        require(cpu.s_.cc & 1,"missing floor did not report error");
        size_t first_sector=0;
        for(int i=0;i<120;++i) {
            size_t entry=sram_drive_bytes+(4+i/10)*256+16+(i%10)*24;
            if(std::equal(bus.disk.begin()+entry,bus.disk.begin()+entry+5,"RFL01")) {
                first_sector=sram_drive_bytes+
                    (size_t(bus.disk[entry+13])*16+bus.disk[entry+14]-1)*256;
                break;
            }
        }
        require(first_sector!=0,"floor file missing from FLEX directory");
        bus.disk[first_sector+4+100]^=1;
        bus.ram[a.depth]=1;
        bus.ram[a.arrival]=0;
        call(bus,cpu,a.load_floor,0);
        require(cpu.s_.cc & 1,"damaged floor did not report error");
        std::cout<<"ROGUE: movement, descent, reveal, and 26 distinct disk floors passed.\n";
    } catch(const std::exception &e) {std::cerr<<e.what()<<"\n";return 1;}
}
