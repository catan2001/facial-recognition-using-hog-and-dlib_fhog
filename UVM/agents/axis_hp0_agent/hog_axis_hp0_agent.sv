`ifndef HOG_AXIS_HP0_AGENT_SV
    `define HOG_AXIS_HP0_AGENT_SV

    class hog_axis_hp0_agent extends uvm_agent;

        // components:
		hog_axis_hp0_driver 	axis_hp0_drv;
		hog_axis_hp0_monitor    axis_hp0_mon;
		hog_axis_sequencer 	    axis_hp0_seqr;

        `uvm_component_utils(hog_axis_hp0_agent)

		//`uvm_component_utils_begin (hog_axil_agent) 
		//	`uvm_field_object(cfg, UVM_DEFAULT); 
		//`uvm_component_utils_end

		function new(string name = "hog_axis_hp0_agent", uvm_component parent = null);
			super.new(name,parent);
		endfunction

		function void build_phase(uvm_phase phase);
			super.build_phase(phase);
			axis_hp0_drv  = hog_axis_hp0_driver::type_id::create("axis_hp0_drv", this);
			axis_hp0_seqr = hog_axis_sequencer::type_id::create("axis_hp0_seqr", this);
			axis_hp0_mon  = hog_axis_hp0_monitor::type_id::create("axis_hp0_mon", this);
		endfunction : build_phase

		function void connect_phase(uvm_phase phase);
			super.connect_phase(phase);
			axis_hp0_drv.seq_item_port.connect(axis_hp0_seqr.seq_item_export); 
		endfunction : connect_phase

    endclass : hog_axis_hp0_agent

`endif