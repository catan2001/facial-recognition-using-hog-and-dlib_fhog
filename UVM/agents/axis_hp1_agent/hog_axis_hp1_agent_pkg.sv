`ifndef HOG_AXIS_HP1_AGENT_PKG_SV
    `define HOG_AXIS_HP1_AGENT_PKG_SV

    package hog_axis_hp1_agent_pkg;
		import uvm_pkg::*;      // import the UVM library
			`include "uvm_macros.svh" // Include the UVM macros

			import hog_axil_gp_agent_pkg::golden_vector_cfg; // has to be imported like this

			`include "hog_axis_hp1_seq_item.sv"
			`include "hog_axis_hp1_sequencer.sv"

			`include "hog_axis_hp1_driver.sv"
			`include "hog_axis_hp1_monitor.sv"
			`include "hog_axis_hp1_agent.sv"
	endpackage 

`endif