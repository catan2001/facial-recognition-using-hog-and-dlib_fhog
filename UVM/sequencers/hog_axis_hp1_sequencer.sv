`ifndef HOG_AXIS_HP1_SEQUENCER_SV
	`define HOG_AXIS_HP1_SEQUENCER_SV
	class hog_axis_hp1_sequencer extends uvm_sequencer#(hog_axis_hp1_seq_item);

		`uvm_component_utils(hog_axis_hp1_sequencer)
		// Register sequencer with the UVM factory

		function new(string name = "hog_axis_hp1_sequencer", uvm_component parent = null);
			super.new(name,parent);
		endfunction
		
    endclass : hog_axis_hp1_sequencer

`endif

//typedef uvm_sequencer#(hog_axis_seq_item) hog_axis_sequencer;
