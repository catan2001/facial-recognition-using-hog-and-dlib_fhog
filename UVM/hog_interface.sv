`ifndef HOG_INTERFACE_SV
	`define HOG_INTERFACE_SV
  	
	parameter integer C_S_AXI_HP_DATA_WIDTH	= 64;	
	parameter integer C_S_AXI_HP_ADDR_WIDTH	= 32;	
	parameter integer C_S_AXI_GP_DATA_WIDTH	= 32;
	parameter integer C_S_AXI_GP_ADDR_WIDTH	= 5;

    interface axil_gp_if (input clk, logic rst);
		// AXI4Lite GP Slave Port interface
		
		logic [C_S_AXI_GP_ADDR_WIDTH - 1 : 0]        s_axi_awaddr; // Write Address // Master
		logic [2 : 0]                                s_axi_awprot = 3'b000; // Normal, Secure, Data = 3'b000 => Unprivileged, Secure, Data // Master
		logic                                        s_axi_awvalid; // Write address valid // Master
		logic                                        s_axi_awready; // Write address ready // Slave
		logic [C_S_AXI_GP_DATA_WIDTH - 1 : 0]        s_axi_wdata; // Write Data // Master
		logic [(C_S_AXI_GP_DATA_WIDTH/8) - 1 : 0]    s_axi_wstrb = 4'b1111; // Signals Valid byte of lane // Master
		logic                                        s_axi_wvalid; // Write Valid // Master
		logic                                        s_axi_wready; // Write ready // Slave
		logic [1 : 0]                                s_axi_bresp; // Write response // Slave
		logic                                        s_axi_bvalid; // Write response valid. // Slave
		logic                                        s_axi_bready; // Response ready // Master
		logic [C_S_AXI_GP_ADDR_WIDTH - 1 : 0]        s_axi_araddr; // Read Address // Master
		logic [2 : 0]                                s_axi_arprot = 3'b000; // Protection Type // Master
		logic                                        s_axi_arvalid; // Read Address Valid // Master
		logic                                        s_axi_arready; // Read Address Ready // Slave
		logic [C_S_AXI_GP_ADDR_WIDTH - 1 : 0]        s_axi_rdata; // Read Data // Slave
		logic [1 : 0]                                s_axi_rresp; // Read response // Slave
		logic                                        s_axi_rvalid; // Read valid // Slave
		logic                                        s_axi_rready; // Read Ready // Master

   endinterface : axil_gp_if

`endif

