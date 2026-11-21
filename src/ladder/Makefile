VASM = ../tools/bin/vasm6800_std
CXX ?= c++
EMU_SRC = ../emu/src
FLEX_PROBE_SOURCES = tools/probe_flex_jump.cpp $(wildcard $(EMU_SRC)/cpu/*.cpp) \
	$(EMU_SRC)/gen/cpu_defs.g.cpp $(EMU_SRC)/gen/cpu_dispatch.g.cpp \
	$(EMU_SRC)/util/symbols.cpp $(EMU_SRC)/util/logging.cpp $(EMU_SRC)/util/logBuffer.cpp

LEVEL_INCS = $(addprefix flex/,easy_street.inc long_island.inc ghost_town.inc tunnel_vision.inc point_of_no_return.inc bug_city.inc gangland.inc)

.PHONY: all levels test-jump test-maps clean
all: LADDER.CMD

levels: $(LEVEL_INCS)

test-maps: levels
	python3 tools/verify_flex_maps.py

$(LEVEL_INCS): tools/make_levels.py Ladder/src/ladicons.pas analysis/map-parity.csv
	python3 tools/make_levels.py

ladder.bin ladder.lst: flex/ladder.s flex/easy_street.inc
	$(VASM) -Iflex -Fbin -L ladder.lst -o ladder.bin flex/ladder.s

LADDER.CMD: ladder.bin tools/make_cmd.py
	python3 tools/make_cmd.py

build/probe_flex_jump: $(FLEX_PROBE_SOURCES)
	mkdir -p build
	$(CXX) -std=c++17 -O2 -I$(EMU_SRC) -I../emu/mame -o $@ $(FLEX_PROBE_SOURCES)

test-jump: ladder.bin ladder.lst build/probe_flex_jump
	build/probe_flex_jump ladder.bin ladder.lst

clean:
	rm -f ladder.bin ladder.lst LADDER.CMD
