`ifndef SCOREBOARD_SV
	`define SCOREBOARD_SV
	
	`uvm_analysis_imp_decl(_axil)
	`uvm_analysis_imp_decl(_axis_hp0)
	`uvm_analysis_imp_decl(_axis_hp1)

	localparam DATAWIDTH = 64;

	class scoreboard extends uvm_scoreboard;
	
		bit checks_enable = 1;
		bit coverage_enable = 1;
		
		uvm_analysis_imp_axil#(hog_axil_seq_item, scoreboard) axil_import;
		uvm_analysis_imp_axis_hp0#(hog_axis_seq_item, scoreboard) axis_hp0_import;
		uvm_analysis_imp_axis_hp1#(hog_axis_hp1_seq_item, scoreboard) axis_hp1_import;

		int num_of_tr = 0;
		int hp0_i = 0;
		int hp0_j = 0;
		int hp1_i = 0;
		int hp1_j = 0;
		int cnt_hp1_height = 1;
		bit ERR_HP0, ERR_HP1;
		bit [DATAWIDTH - 1 : 0] tmp_dx;
		bit [DATAWIDTH - 1 : 0] tmp_dy;
		golden_vector_cfg gv_cfg;
		
		`uvm_component_utils_begin(scoreboard)
			`uvm_field_int(checks_enable, UVM_DEFAULT)
			`uvm_field_int(coverage_enable, UVM_DEFAULT)
		`uvm_component_utils_end
		
		function new(string name = "scoreboard", uvm_component parent = null);
			super.new(name, parent);
			axil_import = new("axil_import", this);
			axis_hp0_import = new("axis_hp0_import", this);
			axis_hp1_import = new("axis_hp1_import", this);
			hp0_i = 0;
			hp0_j = 0;
			hp1_i = 0;
			hp1_j = 0;
			ERR_HP0 = 0;
			ERR_HP0 = 0;
		endfunction : new
		
		function void build_phase(uvm_phase phase);
			super.build_phase(phase);
			if(!uvm_config_db#(golden_vector_cfg)::get(this, "golden_vector_cfg", "golden_vector_cfg", gv_cfg))
            	`uvm_fatal("GOLDEN VECTOR:",{"golden_vector_cfg object must be set for: ",get_full_name(),".gv_cfg"})
		endfunction : build_phase

		function void connect_phase(uvm_phase phase);
			super.connect_phase(phase);
		endfunction : connect_phase
		
		function write_axil(hog_axil_seq_item tr);
			hog_axil_seq_item tr_clone = tr;
			if(checks_enable) begin
				if(tr_clone.read & !tr_clone.write) begin
				end
				if(!tr_clone.read & tr_clone.write) begin
				end
			end
		endfunction : write_axil

		function write_axis_hp0(hog_axis_seq_item tr);
			hog_axis_seq_item tr_clone_hp0 = tr;
			if(checks_enable) begin
				if(this.hp0_i < gv_cfg.heightInput-2) begin
					if(this.hp0_j <= gv_cfg.widthInput-4) begin
						if(this.hp0_j == gv_cfg.widthInput-4) begin
							assert_hp0_eof  :  assert(tr_clone_hp0.m00_axis_tdata[63:48] == gv_cfg.dx_gv[this.hp0_i][this.hp0_j]
											   && tr_clone_hp0.m00_axis_tdata[47:32] == gv_cfg.dx_gv[this.hp0_i][this.hp0_j+1])
							else begin
								`uvm_error(get_type_name(),$sformatf("missmatch in data for dx at [%0d][%0d].\nData from DUT: [%0h], Data from Golden Vector: [%0h %0h]", this.hp0_i, this.hp0_j, tr_clone_hp0.m00_axis_tdata, gv_cfg.dx_gv[this.hp0_i][this.hp0_j], gv_cfg.dx_gv[this.hp0_i][this.hp0_j+1]))
								ERR_HP0 = 1;
							end
						end
						else begin
							tmp_dx = {gv_cfg.dx_gv[this.hp0_i][this.hp0_j], gv_cfg.dx_gv[this.hp0_i][this.hp0_j+1], gv_cfg.dx_gv[this.hp0_i][this.hp0_j+2], gv_cfg.dx_gv[this.hp0_i][this.hp0_j+3]};
							assert_hp0  :  assert(tr_clone_hp0.m00_axis_tdata == tmp_dx)
							else begin
								`uvm_error(get_type_name(),$sformatf("missmatch in data for dx at [%0d][%0d].\nData from DUT: [%0h], Data from Golden Vector: [%0h]", this.hp0_i, this.hp0_j, tr_clone_hp0.m00_axis_tdata, tmp_dx))
								ERR_HP0 = 1;
							end 
						end
						num_of_tr++;
						this.hp0_j+=4;
						if(this.hp0_j > gv_cfg.widthInput-4) begin
							this.hp0_j = 0;
							this.hp0_i = this.hp0_i+1;
						end
					end
				end
			end	
		endfunction : write_axis_hp0
		
		function write_axis_hp1(hog_axis_hp1_seq_item tr);
			hog_axis_hp1_seq_item tr_clone_hp1 = tr;
			if(checks_enable) begin
				if(this.hp1_i < gv_cfg.heightInput-2) begin
					if(this.hp1_j <= gv_cfg.widthInput-4) begin
						if(this.hp1_j == gv_cfg.widthInput-4) begin
							assert_hp1_eof  :  assert(tr_clone_hp1.m00_axis_tdata[63:48] == gv_cfg.dy_gv[this.hp1_i][this.hp1_j]
											   && tr_clone_hp1.m00_axis_tdata[47:32] == gv_cfg.dy_gv[this.hp1_i][this.hp1_j+1])
							else begin
								`uvm_error(get_type_name(),$sformatf("missmatch in data for dy at [%0d][%0d].\nData from DUT: [%0h], Data from Golden Vector: [%0h %0h]", this.hp1_i, this.hp1_j, tr_clone_hp1.m00_axis_tdata, gv_cfg.dy_gv[this.hp1_i][this.hp1_j],gv_cfg.dy_gv[this.hp1_i][this.hp1_j+1]))
								ERR_HP1 = 1;
							end
						end
						else begin
							tmp_dy = {gv_cfg.dy_gv[this.hp1_i][this.hp1_j], gv_cfg.dy_gv[this.hp1_i][this.hp1_j+1], gv_cfg.dy_gv[this.hp1_i][this.hp1_j+2], gv_cfg.dy_gv[this.hp1_i][this.hp1_j+3]};
							assert_hp1  :  assert(tr_clone_hp1.m00_axis_tdata == tmp_dy)
							else begin
								`uvm_error(get_type_name(),$sformatf("missmatch in data for dy at [%0d][%0d].\nData from DUT: [%0h], Data from Golden Vector: [%0h]", this.hp1_i, this.hp1_j, tr_clone_hp1.m00_axis_tdata, tmp_dy))
								ERR_HP1 = 1;
							end
						end
						num_of_tr++;
						this.hp1_j+=4;
						if(this.hp1_j > gv_cfg.widthInput-4) begin
							this.hp1_j = 0;
							this.hp1_i = this.hp1_i+1;
						end
					end
				end 
			end
		endfunction : write_axis_hp1
				
		function void report_phase(uvm_phase phase);
			`uvm_info(get_type_name(), $sformatf("Scoreboard examined: %0d transactions", num_of_tr), UVM_LOW);
			if(!ERR_HP0) begin
				`uvm_info(get_type_name(), "Data comparison in the scoreboard completed successfully for port HP0 [dx data].", UVM_LOW);
			end
			else begin
				`uvm_info(get_type_name(), "Data comparison in the scoreboard failed for port HP0 [dx data].", UVM_LOW);
			end

			if(!ERR_HP1) begin
				`uvm_info(get_type_name(), "Data comparison in the scoreboard completed successfully for port HP1 [dy data].", UVM_LOW);
			end
			else begin
				`uvm_info(get_type_name(), "Data comparison in the scoreboard failed for port HP1 [dy data].", UVM_LOW);
			end 
		endfunction : report_phase

	endclass : scoreboard
	
`endif