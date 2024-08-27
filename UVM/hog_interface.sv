`ifndef HOG_INTERFACE_SV
	`define HOG_INTERFACE_SV

	//parameter integer WIDTH = 16;
	//parameter integer ADDRESS  = 4;   	
	parameter integer C_S_AXI_HP_DATA_WIDTH	= 64;	
	parameter integer C_S_AXI_HP_ADDR_WIDTH	= 32;	
	parameter integer C_S_AXI_GP_DATA_WIDTH	= 32;
	parameter integer C_S_AXI_GP_ADDR_WIDTH	= 5;

   interface axil_gp_if (input clk, logic rst);
		// AXI4Lite GP Slave Port interface
		
		logic [C_S_AXI_GP_ADDR_WIDTH - 1 : 0]        s_axi_awaddr;
		logic [2 : 0]                                s_axi_awprot;
		logic                                        s_axi_awvalid;
		logic                                        s_axi_awready;
		logic [C_S_AXI_GP_DATA_WIDTH - 1 : 0]        s_axi_wdata;
		logic [(C_S_AXI_GP_DATA_WIDTH/8) - 1 : 0]    s_axi_wstrb; // = 4'b1111;
		logic                                        s_axi_wvalid;
		logic                                        s_axi_wready;
		logic [1 : 0]                                s_axi_bresp;
		logic                                        s_axi_bvalid;
		logic                                        s_axi_bready;
		logic [C_S_AXI_GP_ADDR_WIDTH - 1 : 0]        s_axi_araddr;
		logic [2 : 0]                                s_axi_arprot;
		logic                                        s_axi_arvalid;
		logic                                        s_axi_arready;
		logic [C_S_AXI_GP_ADDR_WIDTH - 1 : 0]        s_axi_rdata;
		logic [1 : 0]                                s_axi_rresp;
		logic                                        s_axi_rvalid;
		logic                                        s_axi_rready;

   endinterface : axil_gp_if

   interface axif_hp_if (input clk, logic rst);

		// Ports of AXI4Full Slave Bus Interface S_AXIS

		//logic	                                       s_axi_aclk;
		logic                                     	s_axi_aresetn;
		logic	[C_S_AXI_HP_ADDR_WIDTH - 1 : 0]        s_axi_awaddr;
		logic	[2 : 0]                                s_axi_awprot;
		logic	                                       s_axi_awvalid
		logic	                                       s_axi_awready
		logic [C_S_AXI_HP_DATA_WIDTH - 1 : 0]	      s_axi_wdata;
		logic [(C_S_AXI_HP_DATA_WIDTH/8) - 1 : 0]    s_axi_wstrb;
		logic	                                       s_axi_wvalid;
		logic	                                       s_axi_wready;
		logic [1 : 0]                                s_axi_bresp;
		logic	                                       s_axi_bvalid;
		logic	                                       s_axi_bready;
		logic	[C_S_AXI_HP_ADDR_WIDTH-1 : 0]          s_axi_araddr;
		logic	[2 : 0]                                s_axi_arprot;
		logic	                                       s_axi_arvalid;
		logic	                                       s_axi_arready;
		logic [C_S_AXI_HP_DATA_WIDTH-1 : 0]          s_axi_rdata;
		logic	[1 downto 0]                           s_axi_rresp;
		logic	                                       s_axi_rvalid;
		logic	                                       s_axi_rready;
		
	endinterface : axif_hp_if

`endif

