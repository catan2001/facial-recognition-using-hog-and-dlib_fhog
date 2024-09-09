`ifndef HOG_AXIS_HP0_MONITOR_SV
    `define HOG_AXIS_HP0_MONITOR_SV

	class hog_axis_hp0_monitor extends uvm_monitor;
		// Define a monitor class that extends uvm_monitor
		`uvm_component_utils(hog_axis_hp0_monitor)
		// Register the monitor with the UVM factory

		// Virtual interface to the DUT
		virtual interface axis_hp0_if vif;

		//uvm_analysis_port #(hog_axis_seq_item) ap;
		// Analysis port to send observed transactions to other components like scoreboards

		function new(string name = "hog_axis_hp0_monitor", uvm_component parent = null);
			// Constructor for the monitor
			super.new(name, parent);
			// Call the base class constructor with the name and parent arguments
		endfunction

		virtual function void build_phase(uvm_phase phase);
			// The build phase where monitor components are instantiated
			super.build_phase(phase);
			// Call the base class build_phase
			if (!uvm_config_db#(virtual axis_hp0_if)::get(this, "*", "axis_hp0_if", vif))
            	`uvm_fatal("NOVIF",{"virtual interface must be set:",get_full_name(),".vif"})
			//ap = uvm_analysis_port #(hog_axis_seq_item)::type_id::create("ap", this);
			// Create the analysis port
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
					// Indicate that this is a write transaction
					$display("MONITOR AXIS HP0 Write: data[%0h]", trans.s00_axis_tdata); 
					//ap.write(trans);
					// Send the observed transaction to the analysis port
				end

				// Example: Monitor the read channel
				if (vif.m00_axis_tvalid) begin

					trans.m00_axis_tdata = vif.m00_axis_tdata;
					// Capture the data from the TDATA channel
                    trans.tlast = vif.m00_axis_tlast;
					// Capture signal from the TLAST channel

					trans.write = 0;
					trans.read = 1;
					// Indicate that this is a read transaction
					$display("MONITOR AXIS HP0 Read: data[%0h]", trans.m00_axis_tdata); 
					//ap.write(trans);
					// Send the observed transaction to the analysis port
				end
			end
		endtask
	endclass : hog_axis_hp0_monitor

`endif
