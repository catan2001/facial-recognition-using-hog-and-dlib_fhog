#Usage:
#	make - compiles all binary
#	make run - runs the program
#	make clean - remove all binaries and objects

.PHONY: all

all: bit_analysis.cpp gray_norm.txt
	@echo "compiling..."
	g++ -o bit_analysis bit_analysis.cpp -std=c++17 -I ${SYSTEMC}/include -L${SYSTEMC}/lib-linux64 -lsystemc -lm

gray_norm.txt:
	@echo "ERR: must have gray_norm.txt to run test"

clean: bit_analysis
	@echo "cleaning up..."
	rm bit_analysis
run: bit_analysis
	@echo "running program..."
	./bit_analysis



