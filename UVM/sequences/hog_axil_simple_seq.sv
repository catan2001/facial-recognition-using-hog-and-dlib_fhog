`ifndef HOG_AXIL_SIMPLE_SEQ_SV
   `define HOG_AXIL_SIMPLE_SEQ_SV

	localparam AXI_GP_DATA_WIDTH = 32;
	localparam C_S_AXI_GP_ADDR_WIDTH	= 5;

	typedef enum bit [C_S_AXI_GP_ADDR_WIDTH - 1 : 0] {
		SAHE_ADDR1 = 5'b00000,
		SAHE_ADDR2 = 5'b00001,
		SAHE_ADDR3 = 5'b00010,
		SAHE_ADDR4 = 5'b00011,
		SAHE_ADDR5 = 5'b00100,
		SAHE_ADDR6 = 5'b00101
	} sahe_address_t;

	class hog_axil_simple_seq extends hog_axil_base_seq;

		`uvm_object_utils (hog_axil_simple_seq)

		function new(string name = "hog_axil_simple_seq");
			super.new(name);
		endfunction : new

		sahe_address_t 					sahe_address = SAHE_ADDR1;
		bit [AXI_GP_DATA_WIDTH - 1 : 0] sahe_data = 8'h00000000;

		// SAHE 1:
		bit [8 : 0] 	width_2; 
		bit [10 : 0] 	height;
		bit [9 : 0]		width;
		bit 			start, ready;
		// SAHE 2:
		bit [5 : 0] 	cycle_num_out, cycle_num_in;
		bit [9 : 0] 	effective_row_limit;
		bit [8 : 0] 	width_4;
		// SAHE 3:
		bit [4 : 0] 	bram_height;
		bit [9 : 0] 	row_capacity_bram;
		// SAHE 4:
		bit [AXI_GP_DATA_WIDTH - 1 : 0] dram_in_addr;
		// SAHE 5: 
		bit [AXI_GP_DATA_WIDTH - 1 : 0] dram_x_addr;
		// SAHE 6:
		bit [AXI_GP_DATA_WIDTH - 1 : 0] dram_y_addr;

		virtual task body();
		    //`uvm_info(get_type_name(), $sformatf("Sequence starting..."), UVM_HIGH)
			hog_axil_seq_item hog_axil_it;
			// Declare a variable to hold the transaction item

			hog_axil_it = hog_axil_seq_item::type_id::create("hog_axil_it");
	      	// Create a new transaction item using the UVM factory
		
			start_item(hog_axil_it);
			// Notify the sequencer that a new item is ready to be sent

			// Generate test signals for SAHE 1:
			width_2 = 9'b001000000; // 64
			width = 10'b0100000000; // 128
			height =10'b01010101010;
			start = 'b0;
			sahe_data = {width_2, height, width, start, ready};

			hog_axil_it.write = 'b1;
			hog_axil_it.read = 'b0;
			hog_axil_it.s_axi_awaddr = 5'b00000;
			hog_axil_it.s_axi_wdata = sahe_data;

			// cetvrti korak − finish
			finish_item(hog_axil_it);
			// Notify the sequencer that the item is complete

			`uvm_info(get_type_name(), $sformatf("SAHE1 sent, proceed to read..."), UVM_HIGH);

			start_item(hog_axil_it);

			`uvm_info(get_type_name(), $sformatf("Reading SAHE1..."), UVM_HIGH);
			hog_axil_it.read = 'b1;
			hog_axil_it = 'b0;
			hog_axil_it.s_axi_araddr = 5'b00000;
			sahe_data = hog_axil_it.s_axi_rdata;
			$display("Data read: %b", sahe_data);
			finish_item(hog_axil_it);
		endtask : body

   	endclass : hog_axil_simple_seq

`endif
