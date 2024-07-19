#	Usage:
#	make - compiles all binary
#	make run - runs the program
#	make clean - remove all binaries and objects

.PHONY: all clean

all: main.cpp VP.cpp sw.cpp hw.cpp interconnect.cpp dram_ctrl.cpp dram.cpp bram_ctrl.cpp bram.cpp utils.cpp  gray.txt
	@echo "compiling..."
	g++ -o main main.cpp VP.cpp sw.cpp hw.cpp interconnect.cpp dram.cpp dram_ctrl.cpp bram.cpp bram_ctrl.cpp utils.cpp -std=c++17 -I ${SYSTEMC}/include -L${SYSTEMC}/lib-linux64 -lsystemc -lm -DSC_INCLUDE_FX

gray.txt:
	@echo "ERR: must have gray.txt to run test"

clean: main
	@echo "cleaning up..."
	rm main
run: main
	@echo "running program..."
	./main

