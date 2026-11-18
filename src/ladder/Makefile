VASM = ../tools/bin/vasm6800_std

LEVEL_INCS = $(addprefix flex/,easy_street.inc long_island.inc ghost_town.inc tunnel_vision.inc point_of_no_return.inc bug_city.inc gangland.inc)

.PHONY: all levels clean
all: LADDER.CMD

levels: $(LEVEL_INCS)

$(LEVEL_INCS): tools/make_levels.py Ladder/src/ladicons.pas
	python3 tools/make_levels.py

ladder.bin ladder.lst: flex/ladder.s flex/easy_street.inc
	$(VASM) -Iflex -Fbin -L ladder.lst -o ladder.bin flex/ladder.s

LADDER.CMD: ladder.bin tools/make_cmd.py
	python3 tools/make_cmd.py

clean:
	rm -f ladder.bin ladder.lst LADDER.CMD
