PYTHON ?= python3
CXX ?= c++
.PHONY: all firmware test check-board check image clean program program-dry-run program-isp program-isp-dry-run
all: firmware
firmware:
	$(PYTHON) tools/build.py
build/protocol_test: tests/protocol_test.cpp firmware/sd_bridge/src/protocol.h firmware/sd_bridge/src/link.h
	@mkdir -p build
	$(CXX) -std=c++11 -Wall -Wextra -Werror -pedantic -Ifirmware/sd_bridge/src $< -o $@
test: build/protocol_test
	./build/protocol_test
	$(PYTHON) tests/image_test.py
check-board:
	$(PYTHON) tools/check_board.py
check: test check-board firmware
SD_VOLUME ?= 1
image:
	$(PYTHON) tools/extract_image.py --drive $(SD_VOLUME)
program: firmware
	$(PYTHON) tools/program_avr.py build/sd_bridge.ino.hex
program-dry-run: firmware
	$(PYTHON) tools/program_avr.py --dry-run build/sd_bridge.ino.hex
program-isp: firmware
	$(PYTHON) tools/program_avr.py --icsp build/sd_bridge.ino.hex
program-isp-dry-run: firmware
	$(PYTHON) tools/program_avr.py --dry-run --icsp build/sd_bridge.ino.hex
clean:
	$(PYTHON) -c "import shutil; shutil.rmtree('build', ignore_errors=True)"
