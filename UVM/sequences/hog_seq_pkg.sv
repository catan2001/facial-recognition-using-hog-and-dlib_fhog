`ifndef HOG_SEQ_PKG_SV
	`define HOG_SEQ_PKG_SV

	package hog_seq_pkg;
		import uvm_pkg::*;      // import the UVM library
			`include "uvm_macros.svh" // Include the UVM macros
		// TODO: finish importing agent pkg
		//import hog_agent_pkg::hog_seq_item;
		//import hog_agent_pkg::hog_sequencer;
		import hog_seq_items_pkg::*;
		import hog_sequencers_pkg::*;
      	//including base sequences
			`include "hog_axil_base_seq.sv"
      		`include "hog_axif_base_seq.sv"
      	//including main sequences
			`include "hog_axil_simple_seq.sv"
			`include "hog_axif0_simple_seq.sv"
			`include "hog_axif1_simple_seq.sv"
	endpackage 

`endif
