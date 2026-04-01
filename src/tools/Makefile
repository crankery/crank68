BIN_DIR := bin

VASM_DIR := vasm
VASM_DAILY := http://sun.hasenbraten.de/vasm/daily/vasm.tar.gz
VASM := vasm6800_std
VOBJDUMP := vobjdump
VLINK_DAILY := http://sun.hasenbraten.de/vlink/daily/vlink.tar.gz
VLINK := vlink

TARGET_VASM := $(BIN_DIR)/$(VASM)
VASM_OUT := $(VASM_DIR)/$(VASM)
TARGET_VOBJDUMP := $(BIN_DIR)/$(VOBJDUMP)
VOBJDUMP_OUT := $(VASM_DIR)/$(VOBJDUMP)

VLINK_DIR := $(VLINK)
VLINK_OBJ_DIR := $(VLINK_DIR)/objects
VLINK_OUT := $(VLINK_DIR)/$(VLINK)
TARGET_VLINK := $(BIN_DIR)/$(VLINK)

TARGETS := $(TARGET_VASM) $(TARGET_VLINK) $(TARGET_VOBJDUMP) 

tools: $(TARGETS)

all: tools

$(VASM_DIR):
	wget -O - $(VASM_DAILY) | tar -xz

$(VLINK_DIR):
	wget -O - $(VLINK_DAILY) | tar -xz

$(TARGET_VLINK): $(VLINK_OUT) $(BIN_DIR)
	cp $(VLINK_OUT) $(TARGET_VLINK)

$(TARGET_VASM): $(VASM_OUT) $(BIN_DIR)
	cp $(VASM_OUT) $(TARGET_VASM)

$(TARGET_VOBJDUMP): $(VASM_OUT)
	cp $(VOBJDUMP_OUT) $(TARGET_VOBJDUMP)

$(VASM_OUT): $(VASM_DIR)
	$(MAKE) -C $(VASM_DIR) CPU=6800 SYNTAX=std
	$(MAKE) -C $(VASM_DIR) CPU=6800 SYNTAX=mot
	$(MAKE) -C $(VASM_DIR) CPU=6800 SYNTAX=oldstyle
	
$(VLINK_OBJ_DIR):
	mkdir -p $(VLINK_OBJ_DIR)

$(VLINK_OUT): $(VLINK_DIR) $(VLINK_OBJ_DIR)
	$(MAKE) -C $(VLINK_DIR)

$(BIN_DIR):
	mkdir -p $(BIN_DIR)

clean: clean_bin clean_vasm clean_vlink

clean_bin:
	rm -rf $(TARGET_VASM) $(TARGET_VOBJDUMP) $(TARGET_VLINK) $(TARGET_VASM_MOT)

clean_vlink:
	rm -rf $(VLINK_DIR)

clean_vasm:
	rm -rf $(VASM_DIR)

.PHONY: all clean tools
