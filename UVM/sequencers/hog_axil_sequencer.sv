`ifndef HOG_AXIL_SEQUENCER_SV
	`define HOG_AXIL_SEQUENCER_SV
	class hog_axil_sequencer extends uvm_sequencer#(hog_axil_seq_item);

		`uvm_component_utils(hog_axil_sequencer)
		// Register sequencer with the UVM factory
		golden_vector_cfg gv_cfg;
		function new(string name = "hog_axil_sequencer", uvm_component parent = null);
			super.new(name,parent);
			if(!uvm_config_db#(golden_vector_cfg)::get(this, "golden_vector_cfg", "golden_vector_cfg", gv_cfg))
            	`uvm_fatal("NOCONFIG",{"golden_vector_cfg object must be set for: ",get_full_name(),".gv_cfg"})
		endfunction
		
	endclass : hog_axil_sequencer

`endif
