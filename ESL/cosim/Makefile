CC = "g++"
PROJECT = cosimulation
SRC = main.cpp interconnect.cpp sw.cpp dram.cpp dram_ctrl.cpp ip_core.cpp utils.cpp control_logic.vhd control_path_v2.vhd core_top.vhd core_unit.vhd data_path.vhd demux1_4.vhd demux1_8.vhd dram_to_bram.vhd DSP_AA.vhd DSP_addr_A0.vhd DSP_addr_B0.vhd DSP_addr_BX.vhd DSP_MA.vhd DSP_MS.vhd Dual_Port_BRAM.vhd filter.vhd FSM.vhd mux2_1.vhd mux4_1.vhd mux16_1.vhd top.vhd bram_to_dram.vhd DSP_addr_AX.vhd 

$(PROJECT) : $(SRC)
	 xmsc_run -sc_main -DSC_INCLUDE_DYNAMIC_PROCESSES -DSC_INCLUDE_FX -gui -access +r $(SRC)

clean:
	rm *.log *.key *.so -r *.d




