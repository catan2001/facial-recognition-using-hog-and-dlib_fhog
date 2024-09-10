`ifndef HOG_SEQ_ITEMS_PKG_SV
	`define HOG_SEQ_ITEMS_PKG_SV

	package hog_seq_items_pkg;
		import uvm_pkg::*;      // import the UVM library
			`include "uvm_macros.svh" // Include the UVM macros
            `include "hog_axil_seq_item.sv"
			`include "hog_axis_seq_item.sv" // hp0 
			`include "hog_axis_hp1_seq_item.sv" //hp1
	endpackage 

`endif
