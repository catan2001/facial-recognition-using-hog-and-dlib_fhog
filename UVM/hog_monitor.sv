`ifndef HOG_MONITOR_SV
	`define HOG_MONITOR_SV

	class hog_monitor extends uvm_monitor;

		// code here.

		// control fields:
		bit checks_enable = 1;
		bit coverage_enable = 1;

		uvm_analysis_port #(hog_seq_item) item_collected_port;

		// registration of a UVM component class with the UVM factory
		`uvm_component_utils_begin(hog_monitor)
			`uvm_field_int(checks_enable, UVM_DEFAULT)
			`uvm_field_int(coverage_enable, UVM_DEFAULT)
		`uvm_component_utils_end

		// Virtual interface for all components.
		virtual interface hog_interface vif;

		// constructor for hog_monitor
		function new(string name = "hog_monitor", uvm_component parent = null);
			super.new(name,parent);
			item_collected_port = new("item_collected_port", this);
		endfunction

		// connecting phase.
		function void connect_phase(uvm_phase phase);
			super.connect_phase(phase);
			if (!uvm_config_db#(virtual hog_if)::get(this, "*", "hog_if", vif))
				`uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"})
		endfunction : connect_phase

		task run_phase(uvm_phase phase);
		// code here...
		endtask : run_phase

	endclass : hog_monitor;

`endif