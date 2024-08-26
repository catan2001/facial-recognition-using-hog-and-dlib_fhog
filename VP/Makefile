all: main

# main: main.cpp generator.cpp generator.hpp memory.cpp memory.hpp top.cpp top.hpp utils.cpp utils.hpp conv.cpp conv.hpp
# 	g++ -I/opt/systemc/include -L/opt/systemc/lib-linux64 -lsystemc -o main main.cpp generator.cpp memory.cpp top.cpp utils.cpp conv.cpp

main: main.cpp bram.cpp hw.cpp interconnect.cpp sw.cpp utils.cpp VP.cpp bram_ctrl.cpp dram.cpp bram_out.cpp dram_ctrl.cpp
	g++ -std=c++11 -DSC_INCLUDE_FX -I/opt/systemc/include -L/opt/systemc/lib-linux64 -lsystemc -o main main.cpp bram.cpp hw.cpp interconnect.cpp sw.cpp utils.cpp VP.cpp bram_ctrl.cpp dram.cpp bram_out.cpp dram_ctrl.cpp

.PHONY: clean
clean:
	rm main