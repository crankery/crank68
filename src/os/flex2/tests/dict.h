// Independent host encoder and token expectations for the assembled V3 lexer.
static std::array<uint8_t,4> dict_key_reference(const std::string &word){
    const std::string a2="\r0123456789.,!?_#'\"/\\-:()";
    std::vector<unsigned> z;
    for(unsigned char c:word){
        if(c>='a' && c<='z')z.push_back(c-'a'+6);
        else if(c==' ')z.push_back(0);
        else {auto n=a2.find(c);z.push_back(5);if(n!=std::string::npos)z.push_back(n+7);
              else {z.push_back(6);z.push_back(c>>5);z.push_back(c&31);}}
    }
    z.resize(6,5);std::array<uint8_t,4> result{};
    for(unsigned n=0;n<2;++n){unsigned v=(z[n*3]<<10)|(z[n*3+1]<<5)|z[n*3+2]|(n?0x8000:0);
        result[n*2]=v>>8;result[n*2+1]=v;}
    return result;
}
static void dict_test(){
    Bus bus;Cpu cpu(bus);
    auto flex=file("build/c68flex.bin"),app=file("build/z68.bin");
    std::copy(flex.begin(),flex.end(),bus.ram.begin()+0xa100);
    std::copy(app.begin(),app.end(),bus.ram.begin()+0x300);
    auto sym=[](const std::string &s){return symbol("build/z68.lst",s);};
    auto put=[&](unsigned p,unsigned v){bus.ram[p]=v>>8;bus.ram[p+1]=v;};
    const auto base=sym("app_end"), raw=sym("input_buffer"), operand=sym("vm_resolved");
    const unsigned dynamic=8192,parse=0x100,text=0x400,dictionary=0x800;
    put(sym("dynamic_size"),dynamic);put(sym("dynamic_end"),base+dynamic);put(sym("story_header")+8,dictionary);
    struct Word{std::string text;std::array<uint8_t,4> key;unsigned address;};
    std::vector<Word> words;
    for(const auto &w:{"a","z","open","mailbox","look","north","northwest","xyzzy","123","foo","a-b","@","don't",",",".","\""})
        words.push_back({w,dict_key_reference(w),0});
    std::sort(words.begin(),words.end(),[](const Word&a,const Word&b){return a.key<b.key;});
    for(unsigned n=0;n<words.size();++n)words[n].address=dictionary+7+7*n;
    auto setup=[&](unsigned capacity){
        std::fill_n(bus.ram.begin()+base,dynamic,0xa5);
        bus.ram[base+parse]=capacity;bus.ram[base+text]=255;
        bus.ram[base+dictionary]=3;bus.ram[base+dictionary+1]=',';bus.ram[base+dictionary+2]='.';bus.ram[base+dictionary+3]='"';
        bus.ram[base+dictionary+4]=7;put(base+dictionary+5,words.size());
        for(const auto &w:words)std::copy(w.key.begin(),w.key.end(),bus.ram.begin()+base+w.address);
        bus.ram[sym("vm_operand_count")]=2;put(operand,text);put(operand+2,parse);bus.ram[sym("op_halted")]=0;
    };
    auto run=[&](const std::string &s,bool good=true){call(bus,cpu,sym(s),0);require(bool(cpu.s_.cc&1)==!good,"Dictionary status: "+s);};
    auto match=[&](const std::string &s){auto key=dict_key_reference(s);for(const auto &w:words)if(w.key==key)return w.address;return 0u;};
    struct Case{std::string line;unsigned capacity;};
    const std::vector<Case> cases={
        {"  open mailbox",16},{"open,mailbox.\"look\"",16},{"nonesuch northwest",16},
        {"@ a-b don't 123",16},{"open...look",16},{"a z north foo xyzzy",16},
        {"open mailbox look north",2},{"",16},{"       ",16},{std::string(254,'x'),16},
        {std::string(100,','),120},{std::string(100,','),240},{std::string(100,','),64}
    };
    for(const auto &test:cases){
        setup(test.capacity);std::copy(test.line.begin(),test.line.end(),bus.ram.begin()+raw);
        bus.ram[raw+test.line.size()]=0;bus.ram[sym("input_length")]=test.line.size();
        run("input_prepare_text");run("dict_prepare");
        auto expected=std::vector<uint8_t>(bus.ram.begin()+base,bus.ram.begin()+base+dynamic);
        const unsigned limit=(test.capacity==120 || test.capacity==240)?59:test.capacity;
        unsigned count=0,p=0;
        while(p<test.line.size() && count<limit){
            if(test.line[p]==' '){++p;continue;}
            unsigned start=p++;
            if(std::string(",.\"").find(test.line[start])==std::string::npos)
                while(p<test.line.size() && test.line[p]!=' ' && std::string(",.\"").find(test.line[p])==std::string::npos)++p;
            auto address=match(test.line.substr(start,p-start));unsigned at=parse+2+4*count++;
            expected[at]=address>>8;expected[at+1]=address;expected[at+2]=p-start;expected[at+3]=start+1;
        }
        expected[parse+1]=count;run("dict_tokenize");
        require(std::equal(expected.begin(),expected.end(),bus.ram.begin()+base),
                "Dictionary token addresses, offsets, lengths or untouched bytes differ: "+test.line);
    }
    // Exact packed key tests cover padding and truncation inside shift/escape.
    for(const auto &w:{"", "abcdefghi", "abcde,", "abcd@", "@", "123", "don't"}){
        const std::string word=w;std::copy(word.begin(),word.end(),bus.ram.begin()+raw);
        bus.ram[sym("dict_word_start")]=0;bus.ram[sym("dict_word_length")]=word.size();
        call(bus,cpu,sym("dict_encode"),0);
        auto key=dict_key_reference(word);
        require(std::equal(key.begin(),key.end(),bus.ram.begin()+sym("dict_key")),"V3 dictionary encoding mismatch: "+word);
    }
    for(unsigned bad=0;bad<6;++bad){
        setup(16);run("input_prepare_text");
        if(bad==0)bus.ram[base+parse]=0;
        if(bad==1)put(operand+2,dynamic-2);
        if(bad==2)put(operand+2,text);
        if(bad==3)bus.ram[base+dictionary+4]=3;
        if(bad==4)put(base+dictionary+5,0x8000);
        if(bad==5){put(base+dictionary+5,32767);bus.ram[base+dictionary+4]=255;}
        const auto before=std::vector<uint8_t>(bus.ram.begin()+base,bus.ram.begin()+base+dynamic);
        run("dict_prepare",false);
        require(bus.ram[sym("op_halted")]==1 && std::equal(before.begin(),before.end(),bus.ram.begin()+base),
                "Malformed parse buffer/dictionary changed story RAM");
    }
    std::cout<<"Z68 dictionary: encoding, binary lookup, punctuation, unknowns, offsets, capacities and bounds passed.\n";
}
