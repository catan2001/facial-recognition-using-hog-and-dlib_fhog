`ifndef HOG_SEQUENCERS_PKG_SV
	`define HOG_SEQUENCERS_PKG_SV

	package hog_sequencers_pkg;
		import uvm_pkg::*;      // import the UVM library
			`include "uvm_macros.svh" // Include the UVM macros

            `include "hog_axil_sequencer.sv"
			`include "hog_axis_sequencer.sv" // hp0
			`include "hog_axis_hp1_sequencer.sv"
	endpackage 

`endif
