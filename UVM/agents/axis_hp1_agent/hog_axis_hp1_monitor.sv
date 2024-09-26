`ifndef HOG_AXIS_HP1_MONITOR_SV
    `define HOG_AXIS_HP1_MONITOR_SV

	class hog_axis_hp1_monitor extends uvm_monitor;
		// Define a monitor class that extends uvm_monitor

		// control fields for coverage and checker...
   		bit checks_enable = 1;
   		bit coverage_enable = 1;

		uvm_analysis_port #(hog_axis_hp1_seq_item) item_collected_port;
		// Analysis port to send observed transactions to other components like scoreboards

   		`uvm_component_utils_begin(hog_axis_hp1_monitor)
      		`uvm_field_int(checks_enable, UVM_DEFAULT)
      		`uvm_field_int(coverage_enable, UVM_DEFAULT)
   		`uvm_component_utils_end
		// Register the monitor with the UVM factory

		// Virtual interface to the DUT
		virtual interface axis_hp1_if vif;

	    covergroup axis_hp1_covergroup;
			option.comment = "AXIS HP1 covergroup";
			option.per_instance = 2;
			write_data : coverpoint vif.s00_axis_tdata {
				bins axis_tdata_low  = {[64'h0000000000000000 : 64'h00FFFFFFFFFFFFF]};  // Low range
				bins axis_tdata_med  = {[64'h0100000000000000 : 64'h0EFFFFFFFFFFFFFF]};  // Medium range
				bins axis_tdata_high = {[64'h1000000000000000 : 64'hFFFFFFFFFFFFFFFF]};  // High range
			}  
			read_data : coverpoint vif.m00_axis_tdata {
				bins axis_tdata_low  = {[64'h0000000000000000 : 64'h0FFFFFFFFFFFFFFF]};  // Low range
				bins axis_tdata_med  = {[64'h1000000000000000 : 64'hEFFFFFFFFFFFFFFF]};  // Medium range
				bins axis_tdata_high = {[64'hF000000000000000 : 64'hFFFFFFFFFFFFFFFF]};  // High range
			}
		endgroup

		function new(string name = "hog_axis_hp1_monitor", uvm_component parent = null);
			// Constructor for the monitor
			super.new(name, parent);	// Call the base class constructor with the name and parent arguments
			item_collected_port = new("item_collected_port", this); // Constructor for analysis port			
			axis_hp1_covergroup = new();
		endfunction

		virtual function void build_phase(uvm_phase phase);
			// The build phase where monitor components are instantiated
			super.build_phase(phase);
			// Call the base class build_phase
			if (!uvm_config_db#(virtual axis_hp1_if)::get(this, "*", "axis_hp1_if", vif))
            	`uvm_fatal("NOVIF",{"virtual interface must be set:",get_full_name(),".vif"})
		endfunction

		virtual task run_phase(uvm_phase phase);
			// The main task that observes signals from the DUT during the run phase
			hog_axis_hp1_seq_item trans;
			// Declare a variable to hold the transaction item
             
			forever begin
				// Infinite loop to continuously monitor DUT signals
       		 	@(posedge vif.clk);
				// Example: Monitor the write channel
                trans = hog_axis_hp1_seq_item::type_id::create("trans");
				// Create a new transaction item to capture the observed data

				if (vif.s00_axis_tvalid) begin

					trans.s00_axis_tdata = vif.s00_axis_tdata;
					// Capture the data from the TDATA channel

                    trans.tlast = vif.s00_axis_tlast;
					// Capture signal from the TLAST channel

					trans.write = 1;
					trans.read = 0;

					axis_hp1_covergroup.sample();
				end

				// Example: Monitor the read channel
				if (vif.m00_axis_tvalid) begin

					trans.m00_axis_tdata = vif.m00_axis_tdata;
					// Capture the data from the TDATA channel
                    trans.tlast = vif.m00_axis_tlast;
					// Capture signal from the TLAST channel

					// Indicate that this is a read transaction
					trans.write = 0;
					trans.read = 1;
					
					axis_hp1_covergroup.sample();
					
					// Send the observed transaction to the analysis port
					item_collected_port.write(trans);
				end
			end
		endtask
	endclass : hog_axis_hp1_monitor

`endif
