`ifndef HOG_AXIL_GP_MONITOR_SV
	`define HOG_AXIL_GP_MONITOR_SV

	class hog_axil_gp_monitor extends uvm_monitor;
		// Define a monitor class that extends uvm_monitor

		// control fields for coverage and checker...
   		bit checks_enable = 1;
   		bit coverage_enable = 1;

		uvm_analysis_port #(hog_axil_seq_item) item_collected_port;
		// Analysis port to send observed transactions to other components like scoreboards

   		`uvm_component_utils_begin(hog_axil_gp_monitor)
      		`uvm_field_int(checks_enable, UVM_DEFAULT)
      		`uvm_field_int(coverage_enable, UVM_DEFAULT)
   		`uvm_component_utils_end
		// Register the monitor with the UVM factory

		// Virtual interface to the DUT
		virtual interface axil_gp_if vif;

	    covergroup axil_gp_write;
			option.comment = "AXIL GP Write covergroup";
			option.per_instance = 1;
			option.goal = 3;
			write_address : coverpoint vif.s_axi_awaddr{
				bins sahe1 = {4'b0000}; 
				bins sahe2 = {4'b0100};
				bins sahe3 = {4'b1000};
			}
			write_data : coverpoint vif.s_axi_wdata{
				bins axil_wdata_low = {[32'h00000000 : 32'h0EFFFFFF]};
				bins axil_wdata_high = {[32'h0F000000 : 32'hFFFFFFFF]}; // pomjer
			}    
		endgroup

		covergroup axil_gp_read;
			option.comment = "AXIL GP Read covergroup";
			option.per_instance = 1;
			option.goal = 2;
			read_address: coverpoint vif.s_axi_araddr{
				bins SAHE1 = {4'b0000};
			}
			data_read: coverpoint vif.s_axi_rdata[0]{
				bins data_bin_high = {1};
				bins data_bin_low = {0};
			}

			addr_data_cross: cross read_address, data_read {
        		bins SAHE1_data_high = binsof(read_address.SAHE1) && binsof(data_read.data_bin_high);
        		bins SAHE1_data_low  = binsof(read_address.SAHE1) && binsof(data_read.data_bin_low);
    		}
   		endgroup

		// Constructor for the monitor
		function new(string name = "hog_axil_gp_monitor", uvm_component parent = null);
			super.new(name, parent);	// Call the base class constructor with the name and parent arguments
			item_collected_port = new("item_collected_port", this); // Constructor for analysis port			
			axil_gp_write = new(); 		// Constructor for covergroup axil_gp_write
		    axil_gp_read = new();		// Constructor for covergroup axil_gp_read
		endfunction

		virtual function void build_phase(uvm_phase phase);
			// The build phase where monitor components are instantiated
			super.build_phase(phase);
			// Call the base class build_phase
			if (!uvm_config_db#(virtual axil_gp_if)::get(this, "*", "axil_gp_if", vif))
            	`uvm_fatal("NOVIF",{"virtual interface must be set:",get_full_name(),".vif"})
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
					// Create a new transaction12 item to capture the observed data

					trans.s_axi_awaddr = vif.s_axi_awaddr;
					// Capture the address from the AWADDR channel

					trans.s_axi_wdata = vif.s_axi_wdata;
					// Capture the data from the WDATA channel
					trans.write = 1;
					trans.read = 0;
					axil_gp_write.sample();
					// Indicate that this is a write transaction
					item_collected_port.write(trans);
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
					axil_gp_read.sample();
					// Indicate that this is a read transaction
					item_collected_port.write(trans);
					// Send the observed transaction to the analysis port
				end
			end
		endtask
	endclass : hog_axil_gp_monitor

`endif