`ifndef TEST_HOG_BASE_SV
	`define TEST_HOG_BASE_SV

	class test_hog_base extends uvm_test;

		hog_axil_gp_driver drv;
		hog_axil_sequencer seqr;
		hog_axil_seq_item seq_item;

		`uvm_component_utils(test_hog_base)

		function new(string name = "test_hog_base", uvm_component parent = null);
			super.new(name,parent);
		endfunction : new
		
		function void build_phase(uvm_phase phase);
			super.build_phase(phase);
      		drv = hog_axil_gp_driver::type_id::create("drv", this);      
      		seqr = hog_axil_sequencer::type_id::create("seqr", this);      
		endfunction : build_phase

		function void connect_phase(uvm_phase phase);
			drv.seq_item_port.connect(seqr.seq_item_export);
		endfunction : connect_phase

	endclass : test_hog_base

`endif

