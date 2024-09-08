`ifndef HOG_AXIS_HP0_DRIVER_SV
    `define HOG_AXIS_HP0_DRIVER_SV

	class hog_axis_hp0_driver extends uvm_driver#(hog_axis_seq_item);

		// Register the driver with the UVM factory
		`uvm_component_utils(hog_axis_hp0_driver)

		// Virtual interface to the DUT
		virtual interface axis_hp0_if vif;
		
		function new(string name = "hog_axis_hp0_driver", uvm_component parent = null);
			super.new(name,parent);
		endfunction // new
		
		function void build_phase(uvm_phase phase);
			if (!uvm_config_db#(virtual axil_gp_if)::get(null, "*", "axis_hp0_if", vif))
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
						axi_stream_write(req.s00_axis_tdata);
					end else if(req.read & !req.write) begin
						$display("Driving read transaction:");
						axi_stream_read(req.m00_axis_tdata);					
					end

					seq_item_port.item_done(); // Complete transaction
                
					`uvm_info(get_type_name(), $sformatf("Driver finished sending over AXI STREAM HP0..."), UVM_HIGH)	      
				end
			end
		endtask : main_phase

        task automatic axi_lite_write(input bit [63 : 0] data); // prevent variables to be shared between calls.
			// vif.s00_axis_tlast = ????
			vif.s00_axis_tdata = data;
			vif.s00_axis_tstrb = 8'b11111111;
			vif.s00_axis_tvalid = 1;

			// Wait for slave to be ready...
			wait(vif.s00_axis_tready)

			// clear the valid signals after response is recieved...
			vif.s00_axis_tvalid = 0;

            if(vif.s00_axis_tlast) begin
                vif.s00_axis_tlast = 0;
            end

		endtask;

        task automatic axi_lite_read(input bit [63 : 0] data); // prevent variables to be shared between calls.
			vif.m00_axis_tready = 1;

			// Wait for slave to be valid...
			wait(vif.m00_axis_tvalid)

            if(vif.m00_axis_tstrb == 8'b11111111) begin
                data = vif.m00_axis_tdata;
            end 

            // TODO: WHAT TO DO WITH TLAST????
            //if(vif.m00_axis_tlast) begin
            //    vif.s00_axis_tlast = 0;
            //end
	
		endtask;
        
	endclass : hog_axis_hp0_driver

`endif 

