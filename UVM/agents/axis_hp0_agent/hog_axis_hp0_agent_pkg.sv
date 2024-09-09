`ifndef HOG_AXIS_HP0_AGENT_PKG_SV
    `define HOG_AXIS_HP0_AGENT_PKG_SV

    package hog_axis_hp0_agent_pkg;
		import uvm_pkg::*;      // import the UVM library
			`include "uvm_macros.svh" // Include the UVM macros

			`include "hog_axis_seq_item.sv"
			`include "hog_axis_sequencer.sv"

			`include "hog_axis_hp0_driver.sv"
			`include "hog_axis_hp0_monitor.sv"
			`include "hog_axis_hp0_agent.sv"
	endpackage 

`endif