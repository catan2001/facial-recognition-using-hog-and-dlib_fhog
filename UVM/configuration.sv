`ifndef CONFIGURATION_SV
	`define CONFIGURATION_SV
	
	class configuration extends uvm_object;

	uvm_active_passive_enum is_active = UVM_ACTIVE;

	`uvm_object_utils_begin(configuration)
		`uvm_field_enum(uvm_active_passive_enum, is_active, UVM_DEFAULT)
	`uvm_object_utils_end
	
	function new(string name = "configuration");
		super.new(name);
	endfunction 

	endclass : configuration

`endif