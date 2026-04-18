APP_NAME := emu

SRC_DIR := src
TEST_DIR := tests
BUILD_DIR := build

OBJ_DIR := $(BUILD_DIR)/obj
BIN_DIR := $(BUILD_DIR)/bin
TEST_BIN_DIR := $(BUILD_DIR)/tests

GEN_DIR := $(SRC_DIR)/gen
GENERATOR := $(GEN_DIR)/cpu_codegen.py

# googletest
GTEST_DIR := gtest
GTEST_BUILD_DIR := $(GTEST_DIR)/build
GTEST_LIB_DIR := $(GTEST_BUILD_DIR)/lib
GTEST_LIBS := \
	$(GTEST_LIB_DIR)/libgtest.a \
	$(GTEST_LIB_DIR)/libgtest_main.a

# tools
CXX := g++
PYTHON := python3

CPPFLAGS := -Isrc -Imame
TEST_CPPFLAGS := $(CPPFLAGS) -I./gtest/googletest/include
CXXFLAGS := -std=c++17 -Wall -O2 -g -MMD -MP
LDFLAGS :=
LDLIBS :=

# outputs
TARGET := $(BIN_DIR)/$(APP_NAME)
TEST_BIN := $(TEST_BIN_DIR)/run_tests

all: $(TARGET)
.PHONY: all

# generated sources
GEN_TEMPLATES := $(wildcard $(GEN_DIR)/*.in)
GEN_INPUTS := $(GEN_DIR)/cpu_operations.csv
GEN_OUTS_CPP := $(GEN_DIR)/cpu_defs.g.cpp $(GEN_DIR)/cpu_dispatch.g.cpp
GEN_OUTS_H := $(GEN_DIR)/cpu_defs.g.h $(GEN_DIR)/cpu_operations.g.h
GEN_OUTS := $(GEN_OUTS_CPP) $(GEN_OUTS_H)

$(GEN_OUTS): $(GENERATOR) $(GEN_TEMPLATES) $(GEN_INPUTS)
	$(PYTHON) $(GENERATOR)

# source discovery
BASE_SRCS := $(shell find $(SRC_DIR) -name '*.cpp')
SRCS := $(filter-out $(GEN_OUTS_CPP),$(BASE_SRCS)) $(GEN_OUTS_CPP)

APP_SRCS := $(SRCS)
CORE_SRCS := $(filter-out $(SRC_DIR)/emu.cpp,$(APP_SRCS))
TEST_SRCS := $(shell find $(TEST_DIR) -name '*.cpp')

# object mapping
APP_OBJS := $(patsubst %.cpp,$(OBJ_DIR)/%.o,$(APP_SRCS))
CORE_OBJS := $(patsubst %.cpp,$(OBJ_DIR)/%.o,$(CORE_SRCS))
TEST_OBJS := $(patsubst %.cpp,$(OBJ_DIR)/%.o,$(TEST_SRCS))

DEPS := $(APP_OBJS:.o=.d) $(TEST_OBJS:.o=.d)

generated: $(GEN_OUTS)

# main executable
$(TARGET): $(APP_OBJS) 
	@mkdir -p $(dir $@)
	$(CXX) $(LDFLAGS) -o $@ $(APP_OBJS) $(LDLIBS)


# test runner
test: $(TEST_BIN)
	./$(TEST_BIN)

$(TEST_BIN): $(CORE_OBJS) $(TEST_OBJS) $(GTEST_LIBS)
	@mkdir -p $(dir $@)
	$(CXX) $(LDFLAGS) -o $@ \
		$(CORE_OBJS) \
		$(TEST_OBJS) \
		$(GTEST_LIBS) \
		-pthread

# googletest local build
gtest: $(GTEST_LIBS)

$(GTEST_LIBS):
	cmake -S $(GTEST_DIR) -B $(GTEST_BUILD_DIR)
	$(MAKE) -C $(GTEST_BUILD_DIR)

# compile any .cpp under src/ or tests/
$(OBJ_DIR)/src/%.o: src/%.cpp $(GEN_OUTS_H)
	@mkdir -p $(dir $@)
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c $< -o $@

$(OBJ_DIR)/tests/%.o: tests/%.cpp $(GEN_OUTS_H)
	@echo USING TEST RULE
	@mkdir -p $(dir $@)
	$(CXX) $(TEST_CPPFLAGS) $(CXXFLAGS) -c $< -o $@

regen:
	rm -f $(GEN_OUTS)
	$(MAKE) generated

clean:
	rm -rf $(BUILD_DIR) $(GEN_OUTS) $(GTEST_BUILD_DIR)

-include $(DEPS)