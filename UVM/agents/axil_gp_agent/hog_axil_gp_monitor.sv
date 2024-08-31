import uvm_pkg::*;      // import the UVM library
    `include "uvm_macros.svh" 
import hog_seq_items_pkg::*;
    `include "hog_axil_seq_item.svh"

`ifndef HOG_AXIF_SEQUENCER_SV
	`define HOG_AXIF_SEQUENCER_SV

	class axi_lite_gp_monitor extends uvm_monitor;
		// Define a monitor class that extends uvm_monitor
		`uvm_component_utils(axi_lite_gp_monitor)
		// Register the monitor with the UVM factory

		// Virtual interface to the DUT
		virtual interface axil_gp_if vif;

		uvm_analysis_port #(axi_lite_seq_item) ap;
		// Analysis port to send observed transactions to other components like scoreboards

		function new(string name, uvm_component parent);
			// Constructor for the monitor
			super.new(name, parent);
			// Call the base class constructor with the name and parent arguments
		endfunction

		virtual function void build_phase(uvm_phase phase);
			// The build phase where monitor components are instantiated
			super.build_phase(phase);
			// Call the base class build_phase

			//ap = uvm_analysis_port #(axi_lite_seq_item)::type_id::create("ap", this);
			// Create the analysis port
		endfunction

		virtual task run_phase(uvm_phase phase);
			// The main task that observes signals from the DUT during the run phase
			hog_axil_seq_item trans;
			// Declare a variable to hold the transaction item

			forever begin
				// Infinite loop to continuously monitor DUT signals

				// Example: Monitor the write channel
				if (vif.awvalid && vif.awready) begin
					trans = hog_axil_seq_item::type_id::create("trans");
					// Create a new transaction item to capture the observed data

					trans.s_axi_awaddr = vif.awaddr;
					// Capture the address from the AWADDR channel

					trans.s_axi_wdata = vif.wdata;
					// Capture the data from the WDATA channel

					trans.write = 1;
					trans.read = 0;
					// Indicate that this is a write transaction

					//ap.write(trans);
					// Send the observed transaction to the analysis port
				end

				// Example: Monitor the read channel
				if (vif.arvalid && vif.arready) begin
					trans = hog_axil_seq_item::type_id::create("trans");
					// Create a new transaction item to capture the observed data

					trans.s_axi_araddr = vif.araddr;
					// Capture the address from the ARADDR channel

					trans.s_axi_rdata = vif.rdata;
					// Capture the data from the RDATA channel

					trans.write = 0;
					trans.read = 1;
					// Indicate that this is a read transaction

					//ap.write(trans);
					// Send the observed transaction to the analysis port
				end
			end
		endtask
	endclass

`endif