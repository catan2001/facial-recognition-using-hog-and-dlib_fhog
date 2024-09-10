module hog_top;

	import uvm_pkg::*;
    `include "uvm_macros.svh"

	import test_hog_pkg::*;

	logic clk;
	logic rst;

	// just for testing purpose
	logic status = 1;
	logic ctrl;
	logic [9 : 0] width;
	logic [7 : 0] width_4;
	logic [8 : 0] width_2;
	logic [10 : 0] height;
	logic [5 : 0] cycle_num_in;
	logic [5 : 0] cycle_num_out;
	logic [9 : 0] rows_num;
	logic [11 : 0] effective_row_limit;
	logic [4 : 0] bram_height;
	logic [31 : 0] dram_in_addr;
	logic [31 : 0] dram_x_addr;
	logic [31 : 0] dram_y_addr;

	axil_gp_if axil_vif(clk, rst);
	axis_hp0_if axis_hp0_vif(clk, rst);
	axis_hp1_if axis_hp1_vif(clk, rst);

	// DUT HERE:
	axis_gp2ip_v1_0 DUT(					
		.status_reg 				(status),
		.ctrl_reg 					(ctrl),
		.width_reg 					(width),
		.width_4_reg 				(width_4),
		.width_2_reg 				(width_2),
		.height_reg 				(height),
		.cycle_num_in_reg	 		(cycle_num_in),
		.cycle_num_out_reg 			(cycle_num_out),
		.rows_num_reg 				(rows_num),
		.effective_row_limit_reg 	(effective_row_limit),
		.bram_height 				(bram_height),
		.dram_in_addr_reg 			(dram_in_addr),
		.dram_x_addr_reg 			(dram_x_addr),
		.dram_y_addr_reg 			(dram_y_addr),

		// Ports of Axi Slave Bus Interface S00_AXI
		.s00_axi_aclk 				(clk),
		.s00_axi_aresetn 			(rst),
		.s00_axi_awaddr 			(axil_vif.s_axi_awaddr),
		.s00_axi_awprot				(axil_vif.s_axi_awprot),
		.s00_axi_awvalid			(axil_vif.s_axi_awvalid),
		.s00_axi_awready			(axil_vif.s_axi_awready),
		.s00_axi_wdata				(axil_vif.s_axi_wdata),
		.s00_axi_wstrb				(axil_vif.s_axi_wstrb),
		.s00_axi_wvalid				(axil_vif.s_axi_wvalid),
		.s00_axi_wready				(axil_vif.s_axi_wready),
		.s00_axi_bresp				(axil_vif.s_axi_bresp),
		.s00_axi_bvalid				(axil_vif.s_axi_bvalid),
		.s00_axi_bready				(axil_vif.s_axi_bready),
		.s00_axi_araddr				(axil_vif.s_axi_araddr),
		.s00_axi_arprot				(axil_vif.s_axi_arprot),
		.s00_axi_arvalid			(axil_vif.s_axi_arvalid),
		.s00_axi_arready			(axil_vif.s_axi_arready),
		.s00_axi_rdata				(axil_vif.s_axi_rdata),
		.s00_axi_rresp				(axil_vif.s_axi_rresp),
		.s00_axi_rvalid				(axil_vif.s_axi_rvalid),
		.s00_axi_rready				(axil_vif.s_axi_rready)
	);
	
	axi_stream_v1_0 DUT2(					
		.s00_axis_aclk	              (clk),
		.s00_axis_aresetn	          (rst),
		.s00_axis_tready	          (axis_hp0_vif.s00_axis_tready),
		.s00_axis_tdata	              (axis_hp0_vif.s00_axis_tdata),
		.s00_axis_tstrb	              (axis_hp0_vif.s00_axis_tstrb),
		.s00_axis_tlast               (axis_hp0_vif.s00_axis_tlast),
		.s00_axis_tvalid	          (axis_hp0_vif.s00_axis_tvalid),

		// Ports of Axi Master Bus Interface M00_AXIS
		.m00_axis_aclk	               (clk),
		.m00_axis_aresetn	           (rst),
		.m00_axis_tvalid	           (axis_hp0_vif.m00_axis_tvalid),
		.m00_axis_tdata	               (axis_hp0_vif.m00_axis_tdata),
		.m00_axis_tstrb	               (axis_hp0_vif.m00_axis_tstrb),
		.m00_axis_tlast	               (axis_hp0_vif.m00_axis_tlast),
		.m00_axis_tready	           (axis_hp0_vif.m00_axis_tready)
	);

	axi_stream_v1_0 DUT3(					
		.s00_axis_aclk	              (clk),
		.s00_axis_aresetn	          (rst),
		.s00_axis_tready	          (axis_hp1_vif.s00_axis_tready),
		.s00_axis_tdata	              (axis_hp1_vif.s00_axis_tdata),
		.s00_axis_tstrb	              (axis_hp1_vif.s00_axis_tstrb),
		.s00_axis_tlast               (axis_hp1_vif.s00_axis_tlast),
		.s00_axis_tvalid	          (axis_hp1_vif.s00_axis_tvalid),

		// Ports of Axi Master Bus Interface M00_AXIS
		.m00_axis_aclk	               (clk),
		.m00_axis_aresetn	           (rst),
		.m00_axis_tvalid	           (axis_hp1_vif.m00_axis_tvalid),
		.m00_axis_tdata	               (axis_hp1_vif.m00_axis_tdata),
		.m00_axis_tstrb	               (axis_hp1_vif.m00_axis_tstrb),
		.m00_axis_tlast	               (axis_hp1_vif.m00_axis_tlast),
		.m00_axis_tready	           (axis_hp1_vif.m00_axis_tready)
	);

	initial begin
		uvm_config_db#(virtual axil_gp_if)::set(null, "*", "axil_gp_if", axil_vif);
		uvm_config_db#(virtual axis_hp0_if)::set(null, "*", "axis_hp0_if", axis_hp0_vif);
		uvm_config_db#(virtual axis_hp1_if)::set(null, "*", "axis_hp1_if", axis_hp1_vif);

		$display("Starting test...");
		run_test("test_hog_simple");
	end

	initial begin
		clk <= 0;
		rst <= 0;
		#50 rst <= 1;
		#5000 rst <= 0;
	end

	always #50 clk = ~clk;

endmodule : hog_top