`ifndef TEST_HOG_PKG_SV
	`define TEST_HOG_PKG_SV

package test_hog_pkg; 
	
		import uvm_pkg::*;
		`include "uvm_macros.svh"

		import hog_axil_gp_agent_pkg::*;
		import hog_seq_pkg::*;
		//import configuration_pkg::*;

		//`include "hough_scoreboard.sv"
		`include "hog_environment.sv"
		`include "test_hog_base.sv"
		`include "test_hog_simple.sv"

		`include "hog_interface.sv"


endpackage : test_hog_pkg


`endif