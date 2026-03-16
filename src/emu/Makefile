BUILD_DIR = build

# Compiler
CXX = g++

# Compiler flags
CXXFLAGS = -std=c++17 -Wall -O2 -Imame -g

# Target executable
TARGET = $(BUILD_DIR)/emu

# Source files (all .cpp in current directory)
SRCS = $(wildcard *.cpp)

# Object files
OBJS = $(SRCS:%.cpp=$(BUILD_DIR)/%.o)

# Default target
all: $(TARGET)

# Links
$(TARGET): $(OBJS)
	$(CXX) $(CXXFLAGS) $(OBJS) -o $@

# Compile
${BUILD_DIR}/%.o: %.cpp | ${BUILD_DIR}
	$(CXX) $(CXXFLAGS) -c $< -o $@

# Clean build files
clean:
	rm -rf $(BUILD_DIR)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

.PHONY: all clean
