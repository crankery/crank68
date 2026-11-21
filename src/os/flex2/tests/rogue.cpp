#include "flex_harness.h"
#include <queue>
#include <set>

static constexpr int MAP_W=60, MAP_H=20, MAP_N=MAP_W*MAP_H;
static unsigned word(const Bus &b, unsigned a) { return unsigned(b.ram[a])*256+b.ram[a+1]; }
static bool walkable(char c) { return c=='.'||c=='#'||c=='+'||c=='*'||c=='%'||c=='<'; }

struct Addresses {
    unsigned map=symbol("build/rogue.lst","map");
    unsigned terrain=symbol("build/rogue.lst","terrain");
    unsigned objects=symbol("build/rogue.lst","objects");
    unsigned actors=symbol("build/rogue.lst","actors");
    unsigned bat=symbol("build/rogue.lst","bat_index");
    unsigned bat_room=symbol("build/rogue.lst","bat_room");
    unsigned kobold=symbol("build/rogue.lst","kobold_index");
    unsigned kobold_room=symbol("build/rogue.lst","kobold_room");
    unsigned kobold_x=symbol("build/rogue.lst","kobold_x");
    unsigned kobold_y=symbol("build/rogue.lst","kobold_y");
    unsigned patrol_right=symbol("build/rogue.lst","patrol_right");
    unsigned rng_state=symbol("build/rogue.lst","rng_state");
    unsigned seed_rng=symbol("build/rogue.lst","seed_rng");
    unsigned rng_next=symbol("build/rogue.lst","rng_next");
    unsigned flex_ticks=symbol("build/c68flex.lst","C68TICKS");
    unsigned seen=symbol("build/rogue.lst","seen");
    unsigned display=symbol("build/rogue.lst","display");
    unsigned inventory=symbol("build/rogue.lst","inventory_item");
    unsigned running=symbol("build/rogue.lst","running");
    unsigned rooms=symbol("build/rogue.lst","rooms");
    unsigned player=symbol("build/rogue.lst","player_index");
    unsigned player_x=symbol("build/rogue.lst","player_x");
    unsigned player_y=symbol("build/rogue.lst","player_y");
    unsigned next_x=symbol("build/rogue.lst","next_x");
    unsigned next_y=symbol("build/rogue.lst","next_y");
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
    int bat_count=0;
    int kobold_count=0;
    for(int y=0;y<MAP_H;++y) for(int x=0;x<MAP_W;++x) {
        char c=b.ram[a.map+y*MAP_W+x]; layout+=c;
        check(c==' '||c=='-'||c=='|'||walkable(c),"unknown map tile");
        char object=(c=='*'||c=='<'||c=='%')?c:0;
        check(b.ram[a.terrain+y*MAP_W+x]==(object?'.':c),"terrain layer mismatch");
        if(object!='*') check(b.ram[a.objects+y*MAP_W+x]==object,"object layer mismatch");
        else check(b.ram[a.objects+y*MAP_W+x]=='*'||
                   b.ram[a.objects+y*MAP_W+x]==0,"invalid gold state");
        char actor=b.ram[a.actors+y*MAP_W+x];
        check(actor==0||actor=='B'||actor=='K',"unknown actor");
        bat_count+=actor=='B';
        kobold_count+=actor=='K';
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
    auto bat=word(b,a.bat);
    check(bat_count==1&&bat<MAP_N&&b.ram[a.actors+bat]=='B',"bat placement");
    check(b.ram[a.terrain+bat]=='.'&&b.ram[a.objects+bat]==0,"bat overlaps object or wall");
    check(b.ram[a.bat_room]<9&&b.ram[a.bat_room]!=b.ram[a.arrival]&&
          b.ram[a.bat_room]!=b.ram[a.down_room],"bat in stair room");
    auto bat_record=a.rooms+6*b.ram[a.bat_room];
    check(bat==b.ram[bat_record+5]*MAP_W+b.ram[bat_record+4]+1,"bat room position");
    auto kobold=word(b,a.kobold);
    check(kobold_count==1&&kobold<MAP_N&&b.ram[a.actors+kobold]=='K',"kobold placement");
    check(b.ram[a.terrain+kobold]=='.',"kobold off room floor");
    check(b.ram[a.kobold_room]<9&&b.ram[a.kobold_room]!=b.ram[a.arrival]&&
          b.ram[a.kobold_room]!=b.ram[a.down_room]&&
          b.ram[a.kobold_room]!=b.ram[a.bat_room],"kobold room");
    auto kroom=a.rooms+6*b.ram[a.kobold_room];
    int kx=kobold%MAP_W, ky=kobold/MAP_W;
    check(kx>b.ram[kroom]&&kx<b.ram[kroom+1]&&
          ky>b.ram[kroom+2]&&ky<b.ram[kroom+3],"kobold left its room");
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
        require(intro.find("   v14")!=std::string::npos,"version marker");
        require(word(bus,a.rng_state)!=0&&
                bus.ram[a.patrol_right]==(word(bus,a.rng_state)&1),
                "startup RNG did not choose patrol direction");
        require(intro.find("\x1b[1;62HMessages")!=std::string::npos,"message sidebar heading");
        require(intro.find("Entered a floor.")!=std::string::npos,"floor entry message");
        require(intro.find("\x1b[?25l")!=std::string::npos,"cursor hide");
        validate(bus,a,0);
        require(bus.ram[a.objects+word(bus,a.up)]=='<'&&
                bus.ram[a.objects+word(bus,a.down)]=='%',"stair objects");
        int arrival=bus.ram[a.arrival];
        auto p=a.rooms+6*arrival;
        for(int y=bus.ram[p+2];y<=bus.ram[p+3];++y)
            for(int x=bus.ram[p];x<=bus.ram[p+1];++x)
                require(bus.ram[a.seen+y*MAP_W+x]!=0,"initial room not revealed");
        int other=(arrival+1)%9; p=a.rooms+6*other;
        require(bus.ram[a.seen+bus.ram[p+5]*MAP_W+bus.ram[p+4]]==0,"remote room revealed");
        require(bus.ram[a.inventory]==1,"starter pocket lint missing");
        auto explored=std::vector<uint8_t>(bus.ram.begin()+a.seen,
                                           bus.ram.begin()+a.seen+MAP_N);
        int page_position=word(bus,a.player);
        int idle_kobold=word(bus,a.kobold);
        auto inventory_view=run("ix","");
        require(inventory_view.find("Inventory")!=std::string::npos&&
                inventory_view.find("a) pocket lint")!=std::string::npos,
                "inventory view");
        require(word(bus,a.player)==unsigned(page_position)&&
                std::equal(explored.begin(),explored.end(),bus.ram.begin()+a.seen)&&
                bus.ram[a.display+page_position]=='@',"inventory return lost map state");
        bus.ram[a.inventory]=0;
        auto empty_inventory=run("ix","");
        require(empty_inventory.find("Your pack is empty.")!=std::string::npos&&
                empty_inventory.find("a) pocket lint")==std::string::npos,
                "inventory view ignored item state");
        bus.ram[a.inventory]=1;
        auto help_view=run("?x","");
        require(help_view.find("ROGUE Help")!=std::string::npos&&
                help_view.find("Press any key to return.")!=std::string::npos,
                "help view");
        require(word(bus,a.player)==unsigned(page_position)&&
                std::equal(explored.begin(),explored.end(),bus.ram.begin()+a.seen)&&
                bus.ram[a.display+page_position]=='@',"help return lost map state");
        require(word(bus,a.kobold)==unsigned(idle_kobold),"views advanced the kobold");
        int before=word(bus,a.player);
        auto move=run("l","");
        require(word(bus,a.player)==unsigned(before+1),"movement right");
        require(word(bus,a.kobold)!=unsigned(idle_kobold),"kobold did not roam on a step");
        require(move.find("\r\n")==std::string::npos,"move scrolled terminal");
        run("h","");
        require(word(bus,a.player)==unsigned(before),"movement left");

        auto floor=validate(bus,a,0);
        int gold_pos=int(floor.find('*'));
        require(gold_pos>=0&&gold_pos<MAP_N,"floor has no gold");
        std::vector<int> gold_prev(MAP_N,-1);
        std::queue<int> gold_queue;
        gold_queue.push(before); gold_prev[before]=before;
        while(!gold_queue.empty()&&gold_prev[gold_pos]<0) {
            int v=gold_queue.front();gold_queue.pop();
            for(int d:{-MAP_W,MAP_W,-1,1}) {
                int u=v+d;
                if(u>=0&&u<MAP_N&&gold_prev[u]<0&&walkable(floor[u])&&
                   bus.ram[a.actors+u]==0) {
                    gold_prev[u]=v;gold_queue.push(u);
                }
            }
        }
        require(gold_prev[gold_pos]>=0,"test route to gold");
        std::string gold_path;
        for(int v=gold_pos;v!=before;v=gold_prev[v]) {
            int d=v-gold_prev[v];
            gold_path+=d==-MAP_W?'k':d==MAP_W?'j':d==-1?'h':'l';
        }
        std::reverse(gold_path.begin(),gold_path.end());
        auto old_gold=bus.ram[symbol("build/rogue.lst","gold")];
        auto pickup=run(gold_path,"");
        require(pickup.find("Picked up gold.")!=std::string::npos,"gold pickup message");
        require(word(bus,a.player)==unsigned(gold_pos),"walk to gold");
        require(bus.ram[symbol("build/rogue.lst","gold")]>old_gold,"gold not collected");
        require(bus.ram[a.objects+gold_pos]==0&&bus.ram[a.terrain+gold_pos]=='.'&&
                bus.ram[a.map+gold_pos]=='*',"pickup changed terrain or source floor");

        // Walk to the bat's left side, then verify that it blocks a move.
        int bat_pos=word(bus,a.bat), bat_left=bat_pos-1;
        int bat_start=word(bus,a.player);
        std::vector<int> bat_prev(MAP_N,-1);
        std::queue<int> bat_queue;
        bat_queue.push(bat_start); bat_prev[bat_start]=bat_start;
        while(!bat_queue.empty()&&bat_prev[bat_left]<0) {
            int v=bat_queue.front();bat_queue.pop();
            for(int d:{-MAP_W,MAP_W,-1,1}) {
                int u=v+d;
                if(u>=0&&u<MAP_N&&bat_prev[u]<0&&walkable(floor[u])&&
                   bus.ram[a.actors+u]==0) {
                    bat_prev[u]=v;bat_queue.push(u);
                }
            }
        }
        require(bat_prev[bat_left]>=0,"test route to bat");
        std::string bat_path;
        for(int v=bat_left;v!=bat_start;v=bat_prev[v]) {
            int d=v-bat_prev[v];
            bat_path+=d==-MAP_W?'k':d==MAP_W?'j':d==-1?'h':'l';
        }
        std::reverse(bat_path.begin(),bat_path.end());
        if(!bat_path.empty()) run(bat_path,"");
        require(word(bus,a.player)==unsigned(bat_left),"walk to bat");
        int bat_bump_kobold=word(bus,a.kobold);
        auto bump=run("l","");
        require(word(bus,a.player)==unsigned(bat_left)&&
                bus.ram[a.actors+bat_pos]=='B',"bat did not block movement");
        require(bump.find("A bat blocks you.")!=std::string::npos,"bat bump message");
        require(word(bus,a.kobold)==unsigned(bat_bump_kobold),
                "blocked player move advanced kobold");

        auto test_run=[&](char command,int delta) {
            int from=word(bus,a.player), expected=from;
            for(;;) {
                int next=expected+delta;
                if(next<0||next>=MAP_N||!walkable(bus.ram[a.terrain+next])||
                   bus.ram[a.actors+next]!=0) break;
                expected=next;
                if(bus.ram[a.terrain+next]=='+'||bus.ram[a.objects+next]!=0) break;
            }
            run(std::string(1,command),"");
            require(word(bus,a.player)==unsigned(expected),
                    std::string("uppercase run stopped incorrectly: ")+command);
            require(bus.ram[a.running]==0,"run did not release input");
            return expected-from;
        };
        require(test_run('H',-1)<=-2,"H did not run across room");
        test_run('L',1);
        test_run('K',-MAP_W);
        test_run('J',MAP_W);

        // Navigate using the generated map, then verify stair continuity.
        auto map=validate(bus,a,0,false);
        int target=word(bus,a.down),start=word(bus,a.player);
        std::vector<int> prev(MAP_N,-1); std::queue<int> q;q.push(start);prev[start]=start;
        for(;!q.empty();) {
            int v=q.front();q.pop(); if(v==target) break;
            for(int d:{-MAP_W,MAP_W,-1,1}) {
                int u=v+d;
                if(u>=0&&u<MAP_N&&prev[u]<0&&walkable(map[u])&&
                   bus.ram[a.actors+u]==0) {prev[u]=v;q.push(u);}
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
                    if(u>=0&&u<MAP_N&&parent[u]<0&&walkable(level[u])&&
                       bus.ram[a.actors+u]==0) {
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
            if(i==bus.ram[a.kobold_room]) {
                auto level=validate(bus,a,bus.ram[a.depth],false);
                goal=-1;
                for(int y=bus.ram[room+2];y<=bus.ram[room+3]&&goal<0;++y)
                    for(int x=bus.ram[room];x<=bus.ram[room+1];++x)
                        if(level[y*MAP_W+x]=='+') {goal=y*MAP_W+x;break;}
                require(goal>=0,"kobold room has no door");
            }
            walk_to(goal);
            require(bus.ram[a.seen+goal]!=0,"room not revealed after entry");
        }
        // Set up a short room encounter to check chasing and mutual blocking.
        auto kr=a.rooms+6*bus.ram[a.kobold_room];
        int cx=bus.ram[kr+4], cy=bus.ram[kr+5];
        int center=cy*MAP_W+cx;
        bus.ram[a.actors+word(bus,a.kobold)]=0;
        bus.ram[a.actors+center+1]='K';
        bus.ram[a.kobold]=uint8_t((center+1)>>8);
        bus.ram[a.kobold+1]=uint8_t(center+1);
        bus.ram[a.kobold_x]=uint8_t(cx+1);
        bus.ram[a.kobold_y]=uint8_t(cy);
        bus.ram[a.player]=uint8_t((center-3)>>8);
        bus.ram[a.player+1]=uint8_t(center-3);
        bus.ram[a.player_x]=bus.ram[a.next_x]=uint8_t(cx-3);
        bus.ram[a.player_y]=bus.ram[a.next_y]=uint8_t(cy);
        run("l","");
        require(word(bus,a.player)==unsigned(center-2)&&
                word(bus,a.kobold)==unsigned(center),"kobold did not approach player");
        run("l","");
        require(word(bus,a.player)==unsigned(center-1)&&
                word(bus,a.kobold)==unsigned(center),"kobold stepped onto player");
        auto kobold_bump=run("l","");
        require(word(bus,a.player)==unsigned(center-1)&&
                word(bus,a.kobold)==unsigned(center),"player stepped onto kobold");
        require(kobold_bump.find("Kobold blocks you.")!=std::string::npos,
                "kobold bump message");
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
        bus.ram[a.flex_ticks]=0x12;
        bus.ram[a.flex_ticks+1]=0x34;
        call(bus,cpu,a.seed_rng,0);
        require(word(bus,a.rng_state)==0x1234,"input-tick seed");
        uint16_t expected_rng=0x1234;
        for(int i=0;i<256;++i) {
            expected_rng=uint16_t((expected_rng>>1)^
                ((expected_rng&1) ? 0xb400 : 0));
            call(bus,cpu,a.rng_next,0);
            require(word(bus,a.rng_state)==expected_rng&&
                    cpu.s_.a==uint8_t(expected_rng),"LFSR sequence");
        }
        bus.ram[a.flex_ticks]=0;
        bus.ram[a.flex_ticks+1]=0;
        call(bus,cpu,a.seed_rng,0);
        require(word(bus,a.rng_state)==0x6801,"zero-tick seed fallback");
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
