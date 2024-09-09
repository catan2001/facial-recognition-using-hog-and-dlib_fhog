`ifndef TEST_HOG_PKG_SV
	`define TEST_HOG_PKG_SV

package test_hog_pkg; 
	
		import uvm_pkg::*;
		`include "uvm_macros.svh"

		// importing agents:
		import hog_axil_gp_agent_pkg::*;
		import hog_axis_hp0_agent_pkg::*;

		import hog_seq_pkg::*;

		`include "hog_environment.sv"
		`include "test_hog_base.sv"
		`include "test_hog_simple.sv"

endpackage : test_hog_pkg

`include "hog_interface.sv"

`endif