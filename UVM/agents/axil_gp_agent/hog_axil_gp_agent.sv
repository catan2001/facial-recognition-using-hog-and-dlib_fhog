`ifndef HOG_AXIL_GP_AGENT_SV
	`define HOG_AXIL_GP_AGENT_SV

	class hog_axil_gp_agent extends uvm_agent;

		// components:
		hog_axil_gp_driver 	axil_drv;
		hog_axil_gp_monitor axil_mon;
		hog_axil_sequencer 	axil_seqr;

        `uvm_component_utils(hog_axil_gp_agent)

		//`uvm_component_utils_begin (hog_axil_agent) 
		//	`uvm_field_object(cfg, UVM_DEFAULT); 
		//`uvm_component_utils_end

		function new(string name = "hog_axil_gp_agent", uvm_component parent = null);
			super.new(name,parent);
		endfunction

		function void build_phase(uvm_phase phase);
			super.build_phase(phase);
			axil_drv = hog_axil_gp_driver::type_id::create("axil_drv", this);
			axil_seqr = hog_axil_sequencer::type_id::create("axil_seqr", this);
			axil_mon = hog_axil_gp_monitor::type_id::create("axil_mon", this);
		endfunction : build_phase

		function void connect_phase(uvm_phase phase);
			super.connect_phase(phase);
			axil_drv.seq_item_port.connect(axil_seqr.seq_item_export); 
		endfunction : connect_phase

	endclass : hog_axil_gp_agent

`endif

