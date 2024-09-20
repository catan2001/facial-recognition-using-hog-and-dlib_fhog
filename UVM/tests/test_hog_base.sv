`ifndef TEST_HOG_BASE_SV
	`define TEST_HOG_BASE_SV

	class test_hog_base extends uvm_test;

		hog_environment env;
		golden_vector_cfg gv_cfg;
		configuration cfg;

		string inputImgPath = "input246_300.txt"; 
		string inputDxPath = "dx_golden.txt";
		string inputDyPath = "dy_golden.txt";

		`uvm_component_utils(test_hog_base)

		function new(string name = "test_hog_base", uvm_component parent = null);
			super.new(name,parent);
			gv_cfg.initializeData(inputImgPath, inputDxPath, inputDyPath);
			$display("Initialization finished, Width = %0d, height = %0d", gv_cfg.widthInput, gv_cfg.heightInput);
		endfunction : new
		
		function void build_phase(uvm_phase phase);
			super.build_phase(phase);
			env = hog_environment::type_id::create("env", this);
			uvm_config_db#(golden_vector_cfg)::set(this,"*","golden_vector_cfg",gv_cfg);
		endfunction : build_phase

		function void end_of_elaboration_phase(uvm_phase phase);
			super.end_of_elaboration_phase(phase);
			uvm_top.print_topology();
		endfunction : end_of_elaboration_phase

	endclass : test_hog_base

`endif

