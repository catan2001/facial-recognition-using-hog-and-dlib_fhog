`ifndef HOG_AXIL_GP_AGENT_PKG
	`define HOG_AXIL_GP_AGENT_PKG

	package hog_axil_gp_agent_pkg;
		import uvm_pkg::*;      // import the UVM library
			`include "uvm_macros.svh" // Include the UVM macros

			`include "hog_axil_seq_item.sv"
			`include "hog_axil_sequencer.sv"

			`include "hog_axil_gp_driver.sv"
			`include "hog_axil_gp_monitor.sv"
			`include "hog_axil_gp_agent.sv"
	endpackage 

`endif