`ifndef HOG_AXIL_SIMPLE_SEQ_SV
   `define HOG_AXIL_SIMPLE_SEQ_SV

	localparam AXI_GP_DATA_WIDTH = 32;
	localparam C_S_AXI_GP_ADDR_WIDTH	= 5;

	typedef enum bit [C_S_AXI_GP_ADDR_WIDTH - 1 : 0] {
		SAHE_ADDR1 = 5'b00000,
		SAHE_ADDR2 = 5'b00100,
		SAHE_ADDR3 = 5'b01000,
		SAHE_ADDR4 = 5'b01100,
		SAHE_ADDR5 = 5'b10000,
		SAHE_ADDR6 = 5'b10100
	} sahe_address_t; 

	class hog_axil_simple_seq extends hog_axil_base_seq;

		`uvm_object_utils (hog_axil_simple_seq)

		function new(string name = "hog_axil_simple_seq");
			super.new(name);
		endfunction : new
        
		sahe_address_t 					sahe_address;
		bit [AXI_GP_DATA_WIDTH - 1 : 0] sahe_data;

		// SAHE 1:
		bit [8 : 0] 	width_2; 
		bit [10 : 0] 	height;
		bit [9 : 0]		width;
		bit 			ctrl;
		// SAHE 2:
		bit [5 : 0] 	cycle_num_out, cycle_num_in;
		bit [11 : 0] 	effective_row_limit;
		bit [7 : 0] 	width_4;
		// SAHE 3:
		bit [4 : 0] 	bram_height;
		bit [9 : 0] 	rows_num;
		// SAHE 4:
		bit [AXI_GP_DATA_WIDTH - 1 : 0] dram_in_addr;
		// SAHE 5: 
		bit [AXI_GP_DATA_WIDTH - 1 : 0] dram_x_addr;
		// SAHE 6:
		bit [AXI_GP_DATA_WIDTH - 1 : 0] dram_y_addr;

		virtual task body();
		    //`uvm_info(get_type_name(), $sformatf("Sequence starting..."), UVM_HIGH);
			hog_axil_seq_item hog_axil_it;
			// Declare a variable to hold the transaction item

			hog_axil_it = hog_axil_seq_item::type_id::create("hog_axil_it");
	      	// Create a new transaction item using the UVM factory
			
			start_item(hog_axil_it);
			// Notify the sequencer that a new item is ready to be sent

			// Generate test signals for SAHE 1:
		 	width_2 = 9'b000000001; 
		 	height = 11'b00000011000;
			width = 10'b0000000100;
			ctrl = 1;

			sahe_address = SAHE_ADDR1;
			sahe_data = {width_2, height, width, ctrl, 1'b0};

			hog_axil_it.write = 1;
			hog_axil_it.read = 0;
			hog_axil_it.s_axi_awaddr = sahe_address;
			hog_axil_it.s_axi_wdata = sahe_data;

			// cetvrti korak − finish
			finish_item(hog_axil_it);
			
			start_item(hog_axil_it);
			// Notify the sequencer that a new item is ready to be sent

			// Generate test signals for SAHE 2:
			cycle_num_out = 6'b000101; // 64
			cycle_num_in = 6'b001000; // 128
			effective_row_limit = 12'b101010101000;
			width_4 = 8'b11100001;
			sahe_address = SAHE_ADDR2;
			sahe_data = {2'b000, cycle_num_out, cycle_num_in, effective_row_limit, width_4};

			hog_axil_it.write = 1;
			hog_axil_it.read = 0;
			hog_axil_it.s_axi_awaddr = sahe_address;
			hog_axil_it.s_axi_wdata = sahe_data;

			// cetvrti korak − finish
			finish_item(hog_axil_it);

			start_item(hog_axil_it);
			// Notify the sequencer that a new item is ready to be sent

			// Generate test signals for SAHE 3:
			bram_height = 5'b01000;
			rows_num = 10'b0100001000;

			sahe_address = SAHE_ADDR3;
			sahe_data = {16'b0000000000000000, bram_height, rows_num};

			hog_axil_it.write = 1;
			hog_axil_it.read = 0;
			hog_axil_it.s_axi_awaddr = sahe_address;
			hog_axil_it.s_axi_wdata = sahe_data;

			// cetvrti korak − finish
			finish_item(hog_axil_it);

			start_item(hog_axil_it);
			// Notify the sequencer that a new item is ready to be sent

			// Generate test signals for SAHE 4:
			dram_in_addr = 32'h00000411;

			sahe_address = SAHE_ADDR4;
			sahe_data = dram_in_addr;

			hog_axil_it.write = 1;
			hog_axil_it.read = 0;
			hog_axil_it.s_axi_awaddr = sahe_address;
			hog_axil_it.s_axi_wdata = sahe_data;

			// cetvrti korak − finish
			finish_item(hog_axil_it);

			start_item(hog_axil_it);
			// Notify the sequencer that a new item is ready to be sent

			// Generate test signals for SAHE 5:
			dram_x_addr = 32'h00000511;

			sahe_address = SAHE_ADDR5;
			sahe_data = dram_x_addr;

			hog_axil_it.write = 1;
			hog_axil_it.read = 0;
			hog_axil_it.s_axi_awaddr = sahe_address;
			hog_axil_it.s_axi_wdata = sahe_data;

			// cetvrti korak − finish
			finish_item(hog_axil_it);

			start_item(hog_axil_it);
			// Notify the sequencer that a new item is ready to be sent

			// Generate test signals for SAHE 6:
			dram_y_addr = 32'h00000611;

			sahe_address = SAHE_ADDR6;
			sahe_data = dram_y_addr;

			hog_axil_it.write = 1;
			hog_axil_it.read = 0;
			hog_axil_it.s_axi_awaddr = sahe_address;
			hog_axil_it.s_axi_wdata = sahe_data;

			// cetvrti korak − finish
			finish_item(hog_axil_it);


			// Notify the sequencer that the item is complete
			//while(!ready) begin // TODO: change back when not needed... 
			`uvm_info(get_type_name(), $sformatf("SAHE1 sent, proceed to read..."), UVM_HIGH);
				
			start_item(hog_axil_it);
			$display("Driving read transaction:");
			`uvm_info(get_type_name(), $sformatf("Reading SAHE1..."), UVM_HIGH);
			hog_axil_it.read = 'b1;
			hog_axil_it.write = 'b0;
			hog_axil_it.s_axi_araddr = SAHE_ADDR1;
			sahe_data = hog_axil_it.s_axi_rdata;
			$display("Data read: %b", sahe_data);
			finish_item(hog_axil_it); 			
			//end

			start_item(hog_axil_it);
			hog_axil_it.read = 'b1;
			hog_axil_it.write = 'b0;
			hog_axil_it.s_axi_araddr = SAHE_ADDR2;
			sahe_data = hog_axil_it.s_axi_rdata;
			finish_item(hog_axil_it); 	

			start_item(hog_axil_it);
			hog_axil_it.read = 'b1;
			hog_axil_it.write = 'b0;
			hog_axil_it.s_axi_araddr = SAHE_ADDR3;
			sahe_data = hog_axil_it.s_axi_rdata;
			finish_item(hog_axil_it); 	

			start_item(hog_axil_it);
			hog_axil_it.read = 'b1;
			hog_axil_it.write = 'b0;
			hog_axil_it.s_axi_araddr = SAHE_ADDR4;
			sahe_data = hog_axil_it.s_axi_rdata;
			finish_item(hog_axil_it); 

			start_item(hog_axil_it);
			hog_axil_it.read = 'b1;
			hog_axil_it.write = 'b0;
			hog_axil_it.s_axi_araddr = SAHE_ADDR5;
			sahe_data = hog_axil_it.s_axi_rdata;
			finish_item(hog_axil_it); 

			start_item(hog_axil_it);
			hog_axil_it.read = 'b1;
			hog_axil_it.write = 'b0;
			hog_axil_it.s_axi_araddr = SAHE_ADDR6;
			sahe_data = hog_axil_it.s_axi_rdata;
			finish_item(hog_axil_it); 

		endtask : body
       
   	endclass : hog_axil_simple_seq

`endif
