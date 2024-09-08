`ifndef HOG_AXIS_SEQ_ITEM_SV
    `define HOF_AXIS_SEQ_ITEM_SV

    localparam integer C_S00_AXIS_TDATA_WIDTH = 64;
    localparam integer C_M00_AXIS_TDATA_WIDTH = 64;

 	class hog_axis_seq_item extends uvm_sequence_item;
		
		// TODO: add constraints.

		// fields of sequence_item:
		rand bit [C_S00_AXIS_TDATA_WIDTH - 1 : 0]       s00_axis_tdata; // Transaction Data // Slave
		rand bit [C_M00_AXIS_TDATA_WIDTH - 1 : 0] 		m00_axis_tdata; // Transaction Data // Master

		rand bit read, write;

		`uvm_object_utils_begin(hog_axis_seq_item)
			`uvm_field_int(s00_axis_tdata, UVM_DEFAULT);
			`uvm_field_int(m00_axis_tdata, UVM_DEFAULT);
			`uvm_field_int(read, UVM_DEFAULT);
			`uvm_field_int(write, UVM_DEFAULT);
		`uvm_object_utils_end

		// constructor
		function new(string name = "hog_axis_seq_item");
			super.new(name);
		endfunction : new

	endclass : hog_axis_seq_item;   

`endif
