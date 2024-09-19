`ifndef HOG_AXIL_SIMPLE_SEQ_SV
   `define HOG_AXIL_SIMPLE_SEQ_SV

	localparam AXI_GP_DATA_WIDTH = 32;
	localparam C_S_AXI_GP_ADDR_WIDTH	= 4;

	typedef enum bit [C_S_AXI_GP_ADDR_WIDTH - 1 : 0] {
		SAHE_ADDR1 = 4'b0000,
		SAHE_ADDR2 = 4'b0100,
		SAHE_ADDR3 = 4'b1000
	} sahe_address_t; 

	class hog_axil_simple_seq extends hog_axil_base_seq;

		`uvm_object_utils (hog_axil_simple_seq)

		sahe_address_t 					sahe_address;
		bit [AXI_GP_DATA_WIDTH - 1 : 0] sahe_data;

		int accumulated_loss;
		// SAHE 1:
		bit [8 : 0] 	width_2; 
		bit [10 : 0] 	height;
		bit [9 : 0]		width;
		bit 			ctrl;
		bit 			ready;
		// SAHE 2:
		bit [5 : 0] 	cycle_num_out, cycle_num_in;
		bit [11 : 0] 	effective_row_limit;
		bit [7 : 0] 	width_4;
		// SAHE 3:
		bit [4 : 0] 	bram_height;
		bit [9 : 0] 	rows_num;

		function new(string name = "hog_axil_simple_seq");
			super.new(name);
			width = p_sequencer.gv_cfg.widthInput;
			height = p_sequencer.gv_cfg.heightInput;
			width_2 = p_sequencer.gv_cfg.widthInput/2;
			width_4 = p_sequencer.gv_cfg.widthInput/4;
			bram_height = 16;
			accumulated_loss = ($ceil(real'(height)/(16*(2048/(real'(width)))))-1)*4;
			rows_num = ((2048/(width))*16);
			cycle_num_out = 2048/(width-2);
			cycle_num_in = 2048/width;
			effective_row_limit = $floor(real'(height)/4)*4 + accumulated_loss;
		endfunction : new

		virtual task body();
			hog_axil_seq_item hog_axil_it;
			// Declare a variable to hold the transaction item

			hog_axil_it = hog_axil_seq_item::type_id::create("hog_axil_it");
	      	// Create a new transaction item using the UVM factory

			/*while(!ready) begin // wait until DUT signals ready to be '1'
				start_item(hog_axil_it); 
				hog_axil_it.read = 'b1;
				hog_axil_it.write = 'b0;
				hog_axil_it.s_axi_araddr = SAHE_ADDR1;
				sahe_data = hog_axil_it.s_axi_rdata;
				ready = sahe_data[0];
				finish_item(hog_axil_it); 	
			end */

			start_item(hog_axil_it);
			// Notify the sequencer that a new item is ready to be sent
			sahe_address = SAHE_ADDR3;
			sahe_data = {16'b0000000000000001, bram_height, rows_num};
			hog_axil_it.write = 1;
			hog_axil_it.read = 0;
			hog_axil_it.s_axi_awaddr = sahe_address;
			hog_axil_it.s_axi_wdata = sahe_data;
			finish_item(hog_axil_it);

			start_item(hog_axil_it);
			// Notify the sequencer that a new item is ready to be sent
			sahe_address = SAHE_ADDR3;
			sahe_data = {16'b0000000000000000, bram_height, rows_num};
			hog_axil_it.write = 1;
			hog_axil_it.read = 0;
			hog_axil_it.s_axi_awaddr = sahe_address;
			hog_axil_it.s_axi_wdata = sahe_data;
			finish_item(hog_axil_it);

			start_item(hog_axil_it);
			// Notify the sequencer that a new item is ready to be sent
			sahe_address = SAHE_ADDR2;
			sahe_data = {2'b000, cycle_num_out, cycle_num_in, effective_row_limit, width_4};
			hog_axil_it.write = 1;
			hog_axil_it.read = 0;
			hog_axil_it.s_axi_awaddr = sahe_address;
			hog_axil_it.s_axi_wdata = sahe_data;
			finish_item(hog_axil_it);

			start_item(hog_axil_it);
			// Notify the sequencer that a new item is ready to be sent
			ctrl = 1;
			sahe_address = SAHE_ADDR1;
			sahe_data = {width_2, height, width, ctrl, 1'b0};
			hog_axil_it.write = 1;
			hog_axil_it.read = 0;
			hog_axil_it.s_axi_awaddr = sahe_address;
			hog_axil_it.s_axi_wdata = sahe_data;
			finish_item(hog_axil_it);

			start_item(hog_axil_it);
			ctrl = 0;
			sahe_address = SAHE_ADDR1;
			sahe_data = {width_2, height, width, ctrl, 1'b0};
			hog_axil_it.write = 1;
			hog_axil_it.read = 0;
			hog_axil_it.s_axi_awaddr = sahe_address;
			hog_axil_it.s_axi_wdata = sahe_data;
			finish_item(hog_axil_it);

			while(!ready) begin // wait until DUT signals ready to be '1'
				start_item(hog_axil_it); 
				hog_axil_it.read = 'b1;
				hog_axil_it.write = 'b0;
				hog_axil_it.s_axi_araddr = SAHE_ADDR1;
				sahe_data = hog_axil_it.s_axi_rdata;
				ready = sahe_data[0];
				finish_item(hog_axil_it); 	
			end

		endtask : body
       
   	endclass : hog_axil_simple_seq

`endif
