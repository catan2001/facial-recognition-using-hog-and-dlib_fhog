`ifndef HOG_SEQ_PKG_SV
	`define HOG_SEQ_PKG_SV

	package hog_seq_pkg;
		import uvm_pkg::*;      // import the UVM library
			`include "uvm_macros.svh" // Include the UVM macros

		import hog_axil_gp_agent_pkg::hog_axil_seq_item;
		import hog_axil_gp_agent_pkg::hog_axil_sequencer;
      	//including base sequences
			`include "hog_axil_base_seq.sv"
			`include "hog_axil_simple_seq.sv"
	endpackage 

`endif
