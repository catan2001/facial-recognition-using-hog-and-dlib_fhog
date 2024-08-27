`ifndef HOG_SEQUENCERS_PKG_SV
	`define HOG_SEQUENCERS_PKG_SV

	package hog_sequencers_pkg;
		import uvm_pkg::*;      // import the UVM library
			`include "uvm_macros.svh" // Include the UVM macros
        
        // including sequencers:
            `include "hog_axif_sequencer.sv"
            `include "hog_axil_sequencer.sv"
	endpackage 

`endif
