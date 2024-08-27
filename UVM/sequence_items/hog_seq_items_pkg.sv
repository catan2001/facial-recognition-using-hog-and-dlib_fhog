`ifndef HOG_SEQ_ITEMS_PKG_SV
	`define HOG_SEQ_ITEMS_PKG_SV

	package hog_seq_items_pkg;
		import uvm_pkg::*;      // import the UVM library
			`include "uvm_macros.svh" // Include the UVM macros
        
        // including seq_items:
            `include "hog_axif_seq_item.sv"
            `include "hog_axil_seq_item.sv"
	endpackage 

`endif
