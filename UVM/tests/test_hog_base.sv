`ifndef TEST_HOG_BASE_SV
	`define TEST_HOG_BASE_SV

	class test_hog_base extends uvm_test;

		hog_environment env;

		`uvm_component_utils(test_hog_base)

		function new(string name = "test_hog_base", uvm_component parent = null);
			super.new(name,parent);
		endfunction : new
		
		function void build_phase(uvm_phase phase);
			super.build_phase(phase);
			env = hog_environment::type_id::create("env", this);
		endfunction : build_phase

		function void end_of_elaboration_phase(uvm_phase phase);
			super.end_of_elaboration_phase(phase);
			uvm_top.print_topology();
		endfunction : end_of_elaboration_phase

	endclass : test_hog_base

`endif

