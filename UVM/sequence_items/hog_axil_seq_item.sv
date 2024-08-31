`ifndef HOG_AXIL_SEQ_ITEM_SV
	`define HOG_AXIL_SEQ_ITEM_SV

	localparam integer C_S_AXI_GP_DATA_WIDTH	= 32;
	localparam integer C_S_AXI_GP_ADDR_WIDTH	= 5;

	class hog_axil_seq_item extends uvm_sequence_item;
		
		// TODO: add constraints.

		// fields of sequence_item:
		rand bit [C_S_AXI_GP_ADDR_WIDTH - 1 : 0]        s_axi_awaddr; // Write Address // Master
		rand bit [C_S_AXI_GP_DATA_WIDTH - 1 : 0]        s_axi_wdata; // Write Data // Master
		rand bit [C_S_AXI_GP_ADDR_WIDTH - 1 : 0]        s_axi_araddr; // Read Address // Master
		rand bit [C_S_AXI_GP_DATA_WIDTH - 1 : 0]        s_axi_rdata; // Read Data // Slave

		rand bit read, write;

		`uvm_object_utils_begin(hog_axil_seq_item)
			`uvm_field_int(s_axi_awaddr, UVM_DEFAULT)
			`uvm_field_int(s_axi_wdata, UVM_DEFAULT)
			`uvm_field_int(s_axi_araddr, UVM_DEFAULT)
			`uvm_field_int(s_axi_rdata, UVM_DEFAULT)
			`uvm_field_int(read, UVM_DEFAULT)
			`uvm_field_int(write, UVM_DEFAULT)
		`uvm_object_utils_end

		// constructor
		function new(string name = "hog_axil_seq_item");
			super.new(name);
		endfunction : new

	endclass;

`endif