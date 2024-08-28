#	Usage:
#	make - compiles all binary
#	make run - runs the program
#	make clean - remove all binaries and objects

CC = "g++"

SOURCE_CPP=$(wildcard *.cpp)
SOURCE_HPP=$(wildcard *.hpp)

MAIN_TARGET=main*.cpp
TARGET=$(patsubst %.cpp,%,$(wildcard main*.cpp))

.PHONY: all clean

all: $(TARGET)
$(TARGET): $(SOURCE_CPP) $(SOURCE_HPP)
	@echo "compiling..."
	$(CC) -std=c++17 -I ${SYSTEMC}/include -L${SYSTEMC}/lib-linux64 -lsystemc -lm -DSC_INCLUDE_FX -o $@ *.cpp
	
run: $(TARGET)
	@echo "running VP..."
	./$(TARGET)

clean: $(TARGET)
	@echo "cleaning up..."
	rm $(TARGET)
