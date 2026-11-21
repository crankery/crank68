PYTHON ?= python3
CXX ?= c++
.PHONY: all firmware test check
all: firmware
firmware:
	$(PYTHON) tools/build.py
build/direct_protocol_test: tests/direct_protocol_test.cpp firmware/instore_sd/src/protocol.h firmware/instore_sd/src/direct_link.h
	@mkdir -p build
	$(CXX) -std=c++11 -Wall -Wextra -Werror -pedantic -Ifirmware/instore_sd/src $< -o $@
test: build/direct_protocol_test
	./build/direct_protocol_test
check: test firmware
