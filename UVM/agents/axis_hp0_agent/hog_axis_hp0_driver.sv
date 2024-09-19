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
			if (!uvm_config_db#(virtual axis_hp0_if)::get(null, "*", "axis_hp0_if", vif))
				`uvm_fatal("NOVIF",{"virtual interface must be set:",get_full_name(),".vif"})
		endfunction // build_phase

		task main_phase(uvm_phase phase);
			forever begin
				@(posedge vif.clk);	 
				if (vif.rst) begin // reset is active when '0'
					seq_item_port.get_next_item(req); // Fetch transaction
					`uvm_info(get_type_name(), $sformatf("Driver AXIS_HP0 sending...\n%s", req.sprint()), UVM_HIGH)
						axi_stream_write(req.s00_axis_tdata, req.tlast);
						vif.m00_axis_tready = 1;
					seq_item_port.item_done(); // Complete transaction
					`uvm_info(get_type_name(), $sformatf("Driver finished sending over AXI STREAM HP0..."), UVM_HIGH)	      
				end
			end
		endtask : main_phase

        task automatic axi_stream_write(input bit [63 : 0] data, input bit tlast); // prevent variables to be shared between calls.	
			vif.s00_axis_tlast = tlast;
			vif.s00_axis_tdata = data;
			vif.s00_axis_tstrb = 8'b11111111;
			vif.s00_axis_tvalid = 1;
            if(tlast) begin
				@(posedge vif.clk);
                vif.s00_axis_tvalid = 0;
				vif.s00_axis_tlast = 0;
			end
			wait(vif.s00_axis_tready); // Wait for slave to be ready...
		endtask;
        
	endclass : hog_axis_hp0_driver

`endif 

