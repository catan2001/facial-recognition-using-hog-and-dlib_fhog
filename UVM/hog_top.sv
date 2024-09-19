module hog_top;

	import uvm_pkg::*;
    `include "uvm_macros.svh"

	import test_hog_pkg::*;

	logic clk;
	logic rst;

	axil_gp_if axil_vif(clk, rst);
	axis_hp0_if axis_hp0_vif(clk, rst);
	axis_hp1_if axis_hp1_vif(clk, rst);

	top_axi HOG_DUT(
		.clk 						(clk),

		// HP0 PORTS:
		// Ports of Axi Stream Slave Bus Interface: ip to ddr
		.m00_axis_tvalid			(axis_hp0_vif.m00_axis_tvalid),
		.m00_axis_tdata	            (axis_hp0_vif.m00_axis_tdata),
		.m00_axis_tstrb	            (axis_hp0_vif.m00_axis_tstrb),
		.m00_axis_tlast	            (axis_hp0_vif.m00_axis_tlast),
		.m00_axis_tready	        (axis_hp0_vif.m00_axis_tready),
		// Ports of Axi Master Bus Interface: ddr to ip
		.s00_axis_tready	        (axis_hp0_vif.s00_axis_tready),
		.s00_axis_tdata	            (axis_hp0_vif.s00_axis_tdata),
		.s00_axis_tstrb	            (axis_hp0_vif.s00_axis_tstrb),
		.s00_axis_tlast             (axis_hp0_vif.s00_axis_tlast),
		.s00_axis_tvalid	        (axis_hp0_vif.s00_axis_tvalid),
		
		// HP1 PORTS:
		// Ports of Axi Stream Slave Bus Interface: ip to ddr
		.m01_axis_tvalid	        (axis_hp1_vif.m00_axis_tvalid),
		.m01_axis_tdata	            (axis_hp1_vif.m00_axis_tdata),
		.m01_axis_tstrb	            (axis_hp1_vif.m00_axis_tstrb),
		.m01_axis_tlast	            (axis_hp1_vif.m00_axis_tlast),
		.m01_axis_tready	        (axis_hp1_vif.m00_axis_tready),
		// Ports of Axi Master Bus Interface: ddr to ip
		.s01_axis_tready	        (axis_hp1_vif.s00_axis_tready),
		.s01_axis_tdata	            (axis_hp1_vif.s00_axis_tdata),
		.s01_axis_tstrb	            (axis_hp1_vif.s00_axis_tstrb),
		.s01_axis_tlast             (axis_hp1_vif.s00_axis_tlast),
		.s01_axis_tvalid	        (axis_hp1_vif.s00_axis_tvalid),

		// Ports of Axi Light Slave Bus Interface
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
	end

	always #50 clk = ~clk;

endmodule : hog_top