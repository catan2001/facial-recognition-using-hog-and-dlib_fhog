`ifndef HOG_AXIS_HP0_MONITOR_SV
    `define HOG_AXIS_HP0_MONITOR_SV

	// Define a monitor class that extends uvm_monitor
	class hog_axis_hp0_monitor extends uvm_monitor;

		// control fields for coverage and checker...
   		bit checks_enable = 1;
   		bit coverage_enable = 1;

		// Analysis port to send observed transactions to other components like scoreboards
		uvm_analysis_port #(hog_axis_seq_item) item_collected_port;

		// Register the monitor with the UVM factory
   		`uvm_component_utils_begin(hog_axis_hp0_monitor)
      		`uvm_field_int(checks_enable, UVM_DEFAULT)
      		`uvm_field_int(coverage_enable, UVM_DEFAULT)
   		`uvm_component_utils_end

		// Virtual interface to the DUT
		virtual interface axis_hp0_if vif;

		
	    covergroup axis_hp0_covergroup;
			option.comment = "AXIS HP0 covergroup";
			option.per_instance = 2;
			write_data : coverpoint vif.s00_axis_tdata {
				bins axis_tdata_low  = {[64'h0000000000000000 : 64'h0FFFFFFFFFFFFFFF]};  // Low range
				bins axis_tdata_med  = {[64'h1000000000000000 : 64'hEFFFFFFFFFFFFFFF]};  // Medium range
				bins axis_tdata_high = {[64'hF000000000000000 : 64'hFFFFFFFFFFFFFFFF]};  // High range
			}  
			read_data : coverpoint vif.m00_axis_tdata {
				bins axis_tdata_low  = {[64'h0000000000000000 : 64'h0FFFFFFFFFFFFFFF]};  // Low range
				bins axis_tdata_med  = {[64'h1000000000000000 : 64'hEFFFFFFFFFFFFFFF]};  // Medium range
				bins axis_tdata_high = {[64'hF000000000000000 : 64'hFFFFFFFFFFFFFFFF]};  // High range
			}
		endgroup
		/*
		covergroup axis_hp0_read;
			option.comment = "AXIS HP0 Read covergroup";
			option.per_instance = 1;
			data_read: coverpoint vif.m00_axis_tdata{
				bins axis_tdata_low = {[64'h0000000000000000 : 64'h00000000F0000000]};
				bins axis_tdata_med = {[64'h00000000F0000001 : 64'hF0000000000000000]};
				bins axil_wdata_high = {[64'hF0000000000000001 : 64'hFFFFFFFFFFFFFFFF]};
			}
   		endgroup
		*/
		function new(string name = "hog_axis_hp0_monitor", uvm_component parent = null);
			// Constructor for the monitor
			super.new(name, parent);	// Call the base class constructor with the name and parent arguments
			item_collected_port = new("item_collected_port", this); // Constructor for analysis port			
			axis_hp0_covergroup = new();
		endfunction

		virtual function void build_phase(uvm_phase phase);
			// The build phase where monitor components are instantiated
			super.build_phase(phase);
			// Call the base class build_phase
			if (!uvm_config_db#(virtual axis_hp0_if)::get(this, "*", "axis_hp0_if", vif))
            	`uvm_fatal("NOVIF",{"virtual interface must be set:",get_full_name(),".vif"})
		endfunction

		virtual task run_phase(uvm_phase phase);
			// The main task that observes signals from the DUT during the run phase
			hog_axis_seq_item trans;
			// Declare a variable to hold the transaction item
             
			forever begin
				// Infinite loop to continuously monitor DUT signals
       		 	@(posedge vif.clk);
				// Example: Monitor the write channel
                trans = hog_axis_seq_item::type_id::create("trans");
				// Create a new transaction item to capture the observed data

				if (vif.s00_axis_tvalid) begin

					trans.s00_axis_tdata = vif.s00_axis_tdata;
					// Capture the data from the TDATA channel

                    trans.tlast = vif.s00_axis_tlast;
					// Capture signal from the TLAST channel

					trans.write = 1;
					trans.read = 0;
					// sample data for coverage
					axis_hp0_covergroup.sample();
				end

				// Monitor the read channel
				if (vif.m00_axis_tvalid) begin
					// Capture the data from the TDATA channel
					trans.m00_axis_tdata = vif.m00_axis_tdata;
					// Capture signal from the TLAST channel
                    trans.tlast = vif.m00_axis_tlast;

					// Indicate that this is a read transaction
					trans.write = 0;
					trans.read = 1;
					// sample data for coverage
					axis_hp0_covergroup.sample();
					// send collected item
					item_collected_port.write(trans);
				end
			end
		endtask
	endclass : hog_axis_hp0_monitor

`endif
