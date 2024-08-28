`ifndef HOG_AXIL_SIMPLE_SEQ_SV
   `define HOG_AXIL_SIMPLE_SEQ_SV

	parameter integer AXI_GP_DATA_WIDTH	= 32;
	parameter integer C_S_AXI_GP_ADDR_WIDTH	= 5;

	typedef enum bit [C_S_AXI_GP_ADDR_WIDTH - 1 : 0] {
		SAHE_ADDR1 = b'00000;
		SAHE_ADDR2 = b'00001;
		SAHE_ADDR3 = b'00010;
		SAHE_ADDR4 = b'00011;
		SAHE_ADDR5 = b'00100;
		SAHE_ADDR6 = b'00101;
	} sahe_address_t;

	typedef enum int {
		WRITE = 
	} 

	class hog_axil_simple_seq extends hog_axil_base_seq;

		`uvm_object_utils (hog_axil_simple_seq)

		function new(string name = "hog_axil_simple_seq");
			super.new(name);
		endfunction
		
		//  TODO: read HEIGHT, WIDTH, WIDTH/4

		sahe_address_t 					sahe_address = SAHE_ADDR1;
		bit [AXI_GP_DATA_WIDTH - 1 : 0] sahe_data = h'00000000;

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
		    `uvm_info(get_type_name(), $sformatf("Sequence starting..."), UVM_HIGH);
			hog_axil_seq_item hog_axil_it;
			// Declare a variable to hold the transaction item

			hog_axil_it = hog_seq_item::type_id::create("hog_axil_it");
	      	// Create a new transaction item using the UVM factory
		
			start_item(hog_axil_it);
			// Notify the sequencer that a new item is ready to be sent

			// Generate test signals for SAHE 1:
			width_2 = b'001000000; // 64
			height = b'0101010101;
			rand.randomize();
			start = b'0;
			sahe_data = {width_2, height, width, start, ready};

			hog_axil_it.write = b'1;
			hog_axil_it.read = b'0;
			hog_axil_it.s_axi_awaddr = b'00000;
			hog_axil_it.s_axi_wdata = sahe_data
			// po potrebi moguce prosiriti sa npr. inline ogranicenjima
			//assert (hog_axil_it.randomize() with {hog_axil_it. });
			// cetvrti korak − finish
			finish_item(hog_axil_it);
			// Notify the sequencer that the item is complete

			`uvm_info(get_type_name(), $sformatf("SAHE1 sent, proceed to read..."), UVM_HIGH);
		endtask : body

   	endclass : hog_axil_simple_seq

`endif
