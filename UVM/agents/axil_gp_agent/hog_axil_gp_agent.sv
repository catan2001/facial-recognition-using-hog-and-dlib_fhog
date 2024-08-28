`ifndef HOG_AXIL_AGENT_SV
	`define HOG_AXIL_AGENT_SV

	class hog_axil_agent extends uvm_agent;

		// components:
		hog_axil_gp_driver axil_drv;
		//hog_axil_monitor axil_mon;
		hog_axil_sequencer axil_seqr;

		`uvm_component_utils_begin (svm_dskw_axil_agent) 
			//`uvm_field_object(cfg, UVM_DEFAULT); 
		`uvm_component_utils_end

		function new(string name = "svm_dskw_axil_agent", uvm_component parent = null);
			super.new(name,parent);
		endfunction

		function void build_phase(uvm_phase phase);
			super.build_phase(phase);
			axil_drv = svm_dskw_axil_driver::type_id::create("axil_drv", this);
			axil_seqr = axil_sequencer::type_id::create("axil_seqr", this);
			axil_mon = svm_dskw_axil_monitor::type_id::create("axil_monitor", this);
		endfunction : build_phase

		function void connect_phase(uvm_phase phase);
			super.connect_phase(phase);
			axil_drv.seq_item_port.connect(axil_seqr.seq_item_export);      
		endfunction : connect_phase

	endclass : svm_dskw_axil_agent

`endif

