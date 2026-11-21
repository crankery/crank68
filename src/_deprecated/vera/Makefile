.PHONY: all test
EMU := ../emu/src
EMU_SRCS := $(wildcard $(EMU)/cpu/*.cpp $(EMU)/gen/*.g.cpp) $(addprefix $(EMU)/util/,symbols.cpp logging.cpp logBuffer.cpp)

all:
	$(MAKE) -C ../flex2 vera

build/terminal-test: tests/terminal.cpp
	@mkdir -p build
	c++ -std=c++17 -O2 -I$(EMU) -o $@ $< $(EMU_SRCS)

test: all build/terminal-test
	./build/terminal-test
	$(MAKE) -C ../flex2 verify-image
