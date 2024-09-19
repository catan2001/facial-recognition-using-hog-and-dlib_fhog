`ifndef HOG_SEQ_PKG_SV
	`define HOG_SEQ_PKG_SV

	package hog_seq_pkg;
		import uvm_pkg::*;      // import the UVM library
			`include "uvm_macros.svh" // Include the UVM macros

		`include "golden_vector_cfg.sv"	

		// importing sequence items:
		import hog_axil_gp_agent_pkg::hog_axil_seq_item;
		import hog_axis_hp0_agent_pkg::hog_axis_seq_item; // hp0 and hp1 share the same one
		import hog_axis_hp1_agent_pkg::hog_axis_hp1_seq_item; // hp0 and hp1 share the same one

		// importing sequencers:
		import hog_axil_gp_agent_pkg::hog_axil_sequencer;
		import hog_axis_hp0_agent_pkg::hog_axis_sequencer; // hp0 and hp1 share the same one
		import hog_axis_hp1_agent_pkg::hog_axis_hp1_sequencer; // hp0 and hp1 share the same one

		// including base sequences:
		`include "hog_axil_base_seq.sv"
		`include "hog_axis_hp0_base_seq.sv"
		`include "hog_axis_hp1_base_seq.sv"

		// including simple sequences:
		`include "hog_axil_simple_seq.sv"
		`include "hog_axis_hp0_simple_seq.sv"
		`include "hog_axis_hp1_simple_seq.sv"

	endpackage 

`endif
