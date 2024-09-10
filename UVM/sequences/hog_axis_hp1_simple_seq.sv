`ifndef HOG_AXIS_HP1_SIMPLE_SEQ_SV
	`define HOG_AXIS_HP1_SIMPLE_SEQ_SV

	class hog_axis_hp1_simple_seq extends hog_axis_hp1_base_seq;
		
		`uvm_object_utils (hog_axis_hp1_simple_seq)

		function new(string name = "hog_axis_hp1_simple_seq");
			super.new(name);
		endfunction : new

		virtual task body();
			//`uvm_info(get_type_name(), $sformatf("Sequence starting..."), UVM_HIGH);
			hog_axis_hp1_seq_item hog_axis_it;
			// Declare a variable to hold the transaction item

			hog_axis_it = hog_axis_hp1_seq_item::type_id::create("hog_axis_it");
		  	// Create a new transaction item using the UVM factory
			
			start_item(hog_axis_it);
			// Notify the sequencer that a new item is ready to be sent

			hog_axis_it.read = 0;
			hog_axis_it.write = 1;
			hog_axis_it.s00_axis_tdata = 64'h0000000000000007;
			hog_axis_it.tlast = 1'b0;

			finish_item(hog_axis_it);

		endtask : body

	endclass : hog_axis_hp1_simple_seq;


`endif
