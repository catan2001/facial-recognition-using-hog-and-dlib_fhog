`ifndef HOG_AXIL_GP_MONITOR_SV
	`define HOG_AXIL_GP_MONITOR_SV

	class hog_axil_gp_monitor extends uvm_monitor;
		// Define a monitor class that extends uvm_monitor
		`uvm_component_utils(hog_axil_gp_monitor)
		// Register the monitor with the UVM factory

		// Virtual interface to the DUT
		virtual interface axil_gp_if vif;

		//uvm_analysis_port #(hog_axil_seq_item) ap;
		// Analysis port to send observed transactions to other components like scoreboards

		function new(string name = "hog_axil_gp_monitor", uvm_component parent = null);
			// Constructor for the monitor
			super.new(name, parent);
			// Call the base class constructor with the name and parent arguments
		endfunction

		virtual function void build_phase(uvm_phase phase);
			// The build phase where monitor components are instantiated
			super.build_phase(phase);
			// Call the base class build_phase
			if (!uvm_config_db#(virtual axil_gp_if)::get(this, "*", "axil_gp_if", vif))
            	`uvm_fatal("NOVIF",{"virtual interface must be set:",get_full_name(),".vif"})
			//ap = uvm_analysis_port #(hog_axil_seq_item)::type_id::create("ap", this);
			// Create the analysis port
		endfunction

		virtual task run_phase(uvm_phase phase);
			// The main task that observes signals from the DUT during the run phase
			hog_axil_seq_item trans;
			// Declare a variable to hold the transaction item
             
			forever begin
				// Infinite loop to continuously monitor DUT signals
       		 	@(posedge vif.clk);
				// Example: Monitor the write channel
				if (vif.s_axi_awvalid && vif.s_axi_awready) begin
					trans = hog_axil_seq_item::type_id::create("trans");
					// Create a new transaction item to capture the observed data

					trans.s_axi_awaddr = vif.s_axi_awaddr;
					// Capture the address from the AWADDR channel

					trans.s_axi_wdata = vif.s_axi_wdata;
					// Capture the data from the WDATA channel

					trans.write = 1;
					trans.read = 0;
					// Indicate that this is a write transaction
					$display("MONITOR Write: addr[%0h] | data[%0h]", trans.s_axi_awaddr, trans.s_axi_wdata); 
					//ap.write(trans);
					// Send the observed transaction to the analysis port
				end

				// Example: Monitor the read channel
				if (vif.s_axi_arvalid && vif.s_axi_arready) begin
					trans = hog_axil_seq_item::type_id::create("trans");
					// Create a new transaction item to capture the observed data

					trans.s_axi_araddr = vif.s_axi_araddr;
					// Capture the address from the ARADDR channel

					trans.s_axi_rdata = vif.s_axi_rdata;
					// Capture the data from the RDATA channel

					trans.write = 0;
					trans.read = 1;
					// Indicate that this is a read transaction
					$display("MONITOR Read: addr[%0h] | data[%0h]", trans.s_axi_araddr, trans.s_axi_rdata); 
					//ap.write(trans);
					// Send the observed transaction to the analysis port
				end
			end
		endtask
	endclass : hog_axil_gp_monitor

`endif