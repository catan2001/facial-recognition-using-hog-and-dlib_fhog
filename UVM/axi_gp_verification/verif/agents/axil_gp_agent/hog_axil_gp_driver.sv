`ifndef HOG_AXIL_GP_DRIVER_SV
	`define HOG_AXIL_GP_DRIVER_SV

	class hog_axil_gp_driver extends uvm_driver#(hog_axil_seq_item);

		// Register the driver with the UVM factory
		`uvm_component_utils(hog_axil_gp_driver)

		// Virtual interface to the DUT
		virtual interface axil_gp_if vif;
		
		function new(string name = "hog_axil_gp_driver", uvm_component parent = null);
			super.new(name,parent);
		endfunction // new
		
		function void build_phase(uvm_phase phase);
			if (!uvm_config_db#(virtual axil_gp_if)::get(null, "*", "axil_gp_if", vif))
				`uvm_fatal("NOVIF",{"virtual interface must be set:",get_full_name(),".vif"})
		endfunction // build_phase

		task main_phase(uvm_phase phase);
			forever begin
				@(posedge vif.clk);	 
				if (vif.rst) begin // reset is active when '0'
					seq_item_port.get_next_item(req); // Fetch transaction

					`uvm_info(get_type_name(), $sformatf("Driver sending...\n%s", req.sprint()), UVM_HIGH)

					if(!req.read & req.write) begin // Write transaction
					    $display("Driving write transaction:");
						axi_lite_write(req.s_axi_awaddr, req.s_axi_wdata);
					end else if(req.read & !req.write) begin
						$display("Driving read transaction:");
						axi_lite_read(req.s_axi_araddr, req.s_axi_rdata);					
					end

					seq_item_port.item_done(); // Complete transaction
                
					`uvm_info(get_type_name(), $sformatf("Driver finished sending over AXI LITE GP..."), UVM_HIGH)	      
				end

			end
		endtask : main_phase

		task automatic axi_lite_write(input bit [4 : 0] address, input bit [31 : 0] data); // prevent variables to be shared between calls.
			vif.s_axi_awaddr = address;
			vif.s_axi_awprot = 3'b000;
			vif.s_axi_awvalid = 1;
			vif.s_axi_wdata = data;
			vif.s_axi_wstrb = 4'b1111;
			vif.s_axi_wvalid = 1;
			vif.s_axi_bready = 1;

			// Wait for slave to be ready...
			wait(vif.s_axi_wready && vif.s_axi_awready)
			
			// Wait for slave to respond valid...
			wait(vif.s_axi_bvalid)
			assert(vif.s_axi_bresp == 2'b00) else
				`uvm_error(get_type_name(), $sformatf("Error occured! Slave Response indicated failure!"));

			// clear the valid signals after response is recieved...
			vif.s_axi_awvalid = 0;
    		vif.s_axi_wvalid = 0;
    		vif.s_axi_wdata = 0;	      

			wait(!vif.s_axi_bvalid);

    		// Deassert write response ready	
    		vif.s_axi_bready = 0;
	
		endtask;

		task automatic axi_lite_read(input bit [4 : 0] address, input bit [31 : 0] data); // prevent variables to be shared between calls.
			vif.s_axi_araddr = address;
			vif.s_axi_arprot = 3'b000;
			vif.s_axi_arvalid = 1;
			vif.s_axi_rready = 1;

			// Wait for slave to be ready...
			wait(vif.s_axi_arready)
			
			// Wait for slave to respond valid...
			wait(vif.s_axi_rvalid)
			assert(vif.s_axi_rresp == 2'b00) else
				`uvm_error(get_type_name(), $sformatf("Error occured! Slave Response indicated failure!"));

			// clear the valid signals after response is recieved...
			vif.s_axi_arvalid = 0;
    		vif.s_axi_araddr = 0;	      

			wait(!vif.s_axi_rvalid);
			// read data
			data = vif.s_axi_rdata;
    		// Deassert read response ready	
    		vif.s_axi_rready = 0;
	
		endtask;

	endclass : hog_axil_gp_driver

`endif
