`ifndef HOG_AXIL_SEQUENCER_SV
	`define HOG_AXIL_SEQUENCER_SV
	class hog_axil_sequencer extends uvm_sequencer#(hog_axil_seq_item);

		`uvm_component_utils(hog_axil_sequencer)
		// Register sequencer with the UVM factory

		function new(string name = "hog_axil_sequencer", uvm_component parent = null);
			super.new(name,parent);
		endfunction
		
	endclass : hog_axil_sequencer

`endif

//typedef uvm_sequencer#(hog_seq_item) hog_sequencer;
