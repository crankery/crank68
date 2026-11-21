PYTHON ?= python3
CXX ?= c++

.PHONY: all test clean
all:
	$(PYTHON) tools/build.py

build/key_logic_test: tests/key_logic_test.cpp firmware/key_logic.cpp firmware/key_logic.h
	@mkdir -p build
	$(CXX) -std=c++11 -Wall -Wextra -Werror -pedantic -Ifirmware tests/key_logic_test.cpp firmware/key_logic.cpp -o $@

test: build/key_logic_test
	./build/key_logic_test

clean:
	$(PYTHON) -c "import shutil; shutil.rmtree('build', ignore_errors=True)"
