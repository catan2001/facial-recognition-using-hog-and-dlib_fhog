`ifndef HOG_AXIS_HP0_SIMPLE_SEQ_SV
	`define HOG_AXIS_HP0_SIMPLE_SEQ_SV

	class hog_axis_hp0_simple_seq extends hog_axis_hp0_base_seq;

		`uvm_object_utils (hog_axis_hp0_simple_seq)

		localparam DATAWIDTH = 16;

		int width = 0; // width of input picture
		int height = 0; // height of input picture
		bit [DATAWIDTH - 1 : 0] inputImage[$][$]; // input Image queue 

		function new(string name = "hog_axis_hp0_simple_seq");
			super.new(name);
			width = p_sequencer.gv_cfg.widthInput;
			height = p_sequencer.gv_cfg.heightInput;
			inputImage = p_sequencer.gv_cfg.inputImg;
		endfunction : new

		virtual task body();
			hog_axis_seq_item hog_axis_it;
			// Declare a variable to hold the transaction item

			hog_axis_it = hog_axis_seq_item::type_id::create("hog_axis_it");
		  	// Create a new transaction item using the UVM factory
			for(int i = 0; i < height; i = i + 2) begin
				for(int j = 0; j < width; j = j + 4) begin
					start_item(hog_axis_it);
					hog_axis_it.read = 0;
					hog_axis_it.write = 1;
					hog_axis_it.s00_axis_tdata = {inputImage[i][j], inputImage[i][j+1], inputImage[i][j+2], inputImage[i][j+3]};
					if(i >= (height - 2) & j >= (width - 4)) begin
						hog_axis_it.tlast = 1'b1;
					end
					else 
						hog_axis_it.tlast = 1'b0;
					finish_item(hog_axis_it); // Notify the sequencer that a new item is ready to be sent
				end
			end
		endtask : body

	endclass : hog_axis_hp0_simple_seq;


`endif
