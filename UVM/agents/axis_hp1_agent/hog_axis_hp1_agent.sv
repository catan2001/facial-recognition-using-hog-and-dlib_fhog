`ifndef HOG_AXIS_HP1_AGENT_SV
    `define HOG_AXIS_HP1_AGENT_SV

    class hog_axis_hp1_agent extends uvm_agent;

        // components:
		hog_axis_hp1_driver 	axis_hp1_drv;
		hog_axis_hp1_monitor    axis_hp1_mon;
		hog_axis_hp1_sequencer 	    axis_hp1_seqr;

        `uvm_component_utils(hog_axis_hp1_agent)

		//`uvm_component_utils_begin (hog_axil_agent) 
		//	`uvm_field_object(cfg, UVM_DEFAULT); 
		//`uvm_component_utils_end

		function new(string name = "hog_axis_hp1_agent", uvm_component parent = null);
			super.new(name,parent);
		endfunction

		function void build_phase(uvm_phase phase);
			super.build_phase(phase);
			axis_hp1_drv  = hog_axis_hp1_driver::type_id::create("axis_hp1_drv", this);
			axis_hp1_seqr = hog_axis_hp1_sequencer::type_id::create("axis_hp1_seqr", this);
			axis_hp1_mon  = hog_axis_hp1_monitor::type_id::create("axis_hp1_mon", this);
		endfunction : build_phase

		function void connect_phase(uvm_phase phase);
			super.connect_phase(phase);
			axis_hp1_drv.seq_item_port.connect(axis_hp1_seqr.seq_item_export); 
		endfunction : connect_phase

    endclass : hog_axis_hp1_agent

`endif