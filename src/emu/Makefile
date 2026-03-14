# Compiler
CXX = g++

# Compiler flags
CXXFLAGS = -std=c++17 -Wall -O2 -Imame

# Target executable
TARGET = emu

# Source files (all .cpp in current directory)
SRCS = $(wildcard *.cpp)

# Object files
OBJS = $(SRCS:.cpp=.o)

# Default target
all: $(TARGET)

# Link
$(TARGET): $(OBJS)
	$(CXX) $(OBJS) -o $(TARGET)

# Compile
%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

# Clean build files
clean:
	rm -f $(OBJS) $(TARGET)

.PHONY: all clean
