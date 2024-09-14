library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_axi is
generic(

    AXIS_DATA_WIDTH:natural:=64;
    AXIL_ADDR_WIDTH:natural:=4;
    DATA_WIDTH:natural:=32;
    BRAM_SIZE:natural:=1024;
    ADDR_WIDTH:natural:=10;
    PIX_WIDTH:natural:=16
    
       );
  Port ( 
    clk: in std_logic;
    
    --HP0 PORTS:
    -- Ports of Axi Stream Slave Bus Interface: ip to ddr
    m00_axis_tready	: in std_logic;
    m00_axis_tdata	: out std_logic_vector(AXIS_DATA_WIDTH-1 downto 0);
    m00_axis_tstrb	: out std_logic_vector((AXIS_DATA_WIDTH/8)-1 downto 0);
    m00_axis_tlast	: out std_logic;
    m00_axis_tvalid	: out std_logic;

    -- Ports of Axi Master Bus Interface: ddr to ip
    s00_axis_tvalid	: in std_logic;
    s00_axis_tdata	: in std_logic_vector(AXIS_DATA_WIDTH-1 downto 0);
    s00_axis_tstrb	: in std_logic_vector((AXIS_DATA_WIDTH/8)-1 downto 0);
    s00_axis_tlast	: in std_logic;
    s00_axis_tready	: out std_logic;
    
    --HP1 PORTS:
    -- Ports of Axi Stream Slave Bus Interface: ip to ddr
    m01_axis_tready	: in std_logic;
    m01_axis_tdata	: out std_logic_vector(AXIS_DATA_WIDTH-1 downto 0);
    m01_axis_tstrb	: out std_logic_vector((AXIS_DATA_WIDTH/8)-1 downto 0);
    m01_axis_tlast	: out std_logic;
    m01_axis_tvalid	: out std_logic;

    -- Ports of Axi Master Bus Interface: ddr to ip
    s01_axis_tvalid	: in std_logic;
    s01_axis_tdata	: in std_logic_vector(AXIS_DATA_WIDTH-1 downto 0);
    s01_axis_tstrb	: in std_logic_vector((AXIS_DATA_WIDTH/8)-1 downto 0);
    s01_axis_tlast	: in std_logic;
    s01_axis_tready	: out std_logic;
    
    -- Ports of Axi Light Slave Bus Interface
    s00_axi_aresetn	: in std_logic;
    s00_axi_awaddr	: in std_logic_vector(AXIL_ADDR_WIDTH-1 downto 0);
    s00_axi_awprot	: in std_logic_vector(2 downto 0);
    s00_axi_awvalid	: in std_logic;
    s00_axi_awready	: out std_logic;
    s00_axi_wdata	: in std_logic_vector(DATA_WIDTH-1 downto 0);
    s00_axi_wstrb	: in std_logic_vector((DATA_WIDTH/8)-1 downto 0);
    s00_axi_wvalid	: in std_logic;
    s00_axi_wready	: out std_logic;
    s00_axi_bresp	: out std_logic_vector(1 downto 0);
    s00_axi_bvalid	: out std_logic;
    s00_axi_bready	: in std_logic;
    s00_axi_araddr	: in std_logic_vector(AXIL_ADDR_WIDTH-1 downto 0);
    s00_axi_arprot	: in std_logic_vector(2 downto 0);
    s00_axi_arvalid	: in std_logic;
    s00_axi_arready	: out std_logic;
    s00_axi_rdata	: out std_logic_vector(DATA_WIDTH-1 downto 0);
    s00_axi_rresp	: out std_logic_vector(1 downto 0);
    s00_axi_rvalid	: out std_logic;
    s00_axi_rready	: in std_logic
    
    );
end top_axi;

architecture Behavioral of top_axi is

component top is
 generic(
    DATA_WIDTH:natural:=32;
    BRAM_SIZE:natural:=1024;
    ADDR_WIDTH:natural:=10;
    PIX_WIDTH:natural:=16);
 port ( 
    clk: in std_logic;
    reset: in std_logic;
    start: in std_logic;
    
    --HP0
    --axi stream signals bram to dram
    axi_hp0_ready_out: in std_logic;
    axi_hp0_valid_out: out std_logic;
    axi_hp0_strb_out: out std_logic_vector(7 downto 0);
    axi_hp0_last_out: out std_logic;
    
    --axi stream signals dram to bram
    axi_hp0_last_in: in std_logic;
    axi_hp0_valid_in: in std_logic;
    axi_hp0_strb_in: in std_logic_vector(7 downto 0);
    axi_hp0_ready_in: out std_logic;
    
    --HP1:
    --axi stream signals bram to dram
    axi_hp1_ready_out: in std_logic;
    axi_hp1_valid_out: out std_logic;
    axi_hp1_strb_out: out std_logic_vector(7 downto 0);
    axi_hp1_last_out: out std_logic;
    
    --axi stream signals dram to bram
    axi_hp1_last_in: in std_logic;
    axi_hp1_valid_in: in std_logic;
    axi_hp1_strb_in: in std_logic_vector(7 downto 0);
    axi_hp1_ready_in: out std_logic;

    --reg bank
    width: in std_logic_vector(9 downto 0);
    width_4: in std_logic_vector(7 downto 0);
    width_2: in std_logic_vector(8 downto 0);
    height: in std_logic_vector(10 downto 0);
    bram_height: in std_logic_vector(4 downto 0);
    cycle_num_limit: in std_logic_vector(5 downto 0); --2*bram_width/width
    cycle_num_out: in std_logic_vector(5 downto 0); --2*(bram_width/(width-1))
    rows_num: in std_logic_vector(9 downto 0); --2*(bram_width/width)*bram_height
    effective_row_limit: in std_logic_vector(11 downto 0); --(height/PTS_PER_COL)*PTS_PER_COL+accumulated_loss 

    ready: out std_logic; 
    
    --data signals
    data_in1: in std_logic_vector(63 downto 0);
    data_in2: in std_logic_vector(63 downto 0);
    data_out1: out std_logic_vector(63 downto 0);
    data_out2: out std_logic_vector(63 downto 0));
end component;

component axi_light_v1_0 is
	generic (
		C_S00_AXI_DATA_WIDTH	: integer	:= 32;
		C_S00_AXI_ADDR_WIDTH	: integer	:= 4
	);
	port (
		  -- Ports towards the IP core
		-- input ports:
		status_reg : in std_logic;
		
		-- output ports:
		reset_reg: out std_logic;
		ctrl_reg : out std_logic;
		width_reg : out std_logic_vector(9 downto 0);
		width_4_reg : out std_logic_vector(7 downto 0);
		width_2_reg: out std_logic_vector(8 downto 0);
		height_reg : out std_logic_vector(10 downto 0);
		cycle_num_in_reg : out std_logic_vector(5 downto 0); --2*bram_width/width
		cycle_num_out_reg : out std_logic_vector(5 downto 0); --2*(bram_width/(width-1))
		rows_num_reg : out std_logic_vector(9 downto 0); --2*(bram_width/width)*bram_height
		effective_row_limit_reg : out std_logic_vector(11 downto 0); --(height/PTS_PER_ROW)/accumulated_loss
		bram_height : out std_logic_vector(4 downto 0);
		
		-- Ports of Axi Slave Bus Interface S00_AXI
		s00_axi_aclk	: in std_logic;
		s00_axi_aresetn	: in std_logic;
		s00_axi_awaddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_awprot	: in std_logic_vector(2 downto 0);
		s00_axi_awvalid	: in std_logic;
		s00_axi_awready	: out std_logic;
		s00_axi_wdata	: in std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_wstrb	: in std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
		s00_axi_wvalid	: in std_logic;
		s00_axi_wready	: out std_logic;
		s00_axi_bresp	: out std_logic_vector(1 downto 0);
		s00_axi_bvalid	: out std_logic;
		s00_axi_bready	: in std_logic;
		s00_axi_araddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_arprot	: in std_logic_vector(2 downto 0);
		s00_axi_arvalid	: in std_logic;
		s00_axi_arready	: out std_logic;
		s00_axi_rdata	: out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_rresp	: out std_logic_vector(1 downto 0);
		s00_axi_rvalid	: out std_logic;
		s00_axi_rready	: in std_logic
	);
end component;

signal width_reg_s: std_logic_vector(9 downto 0);
signal width_4_reg_s: std_logic_vector(7 downto 0);
signal width_2_reg_s: std_logic_vector(8 downto 0);
signal height_reg_s: std_logic_vector(10 downto 0);
signal bram_height_s: std_logic_vector(4 downto 0);
signal cycle_num_in_reg_s, cycle_num_out_reg_s: std_logic_vector(5 downto 0);
signal rows_num_reg_s: std_logic_vector(9 downto 0);
signal effective_row_limit_reg_s: std_logic_vector(11 downto 0);
signal reset_s, start_s, ready_s: std_logic;

begin

--TOP:----------------------------------------------------------------------------------

top_l: top
generic map(        
    DATA_WIDTH => DATA_WIDTH,
    BRAM_SIZE => BRAM_SIZE,
    ADDR_WIDTH => ADDR_WIDTH,
    PIX_WIDTH => PIX_WIDTH
    )
  port map( 
    clk => clk,
    reset => reset_s,
    start => start_s,
    
    --HP0:
    --axi stream signals bram to dram
    axi_hp0_ready_out => m00_axis_tready,
    axi_hp0_valid_out => m00_axis_tvalid,
    axi_hp0_strb_out  => m00_axis_tstrb,
    axi_hp0_last_out  => m00_axis_tlast,
    
    --axi stream signals dram to bram
    axi_hp0_last_in	=> s00_axis_tlast,
    axi_hp0_valid_in => s00_axis_tvalid,
    axi_hp0_strb_in	=> s00_axis_tstrb,
    axi_hp0_ready_in => s00_axis_tready,
    
    --HP1:
    --axi stream signals bram to dram
    axi_hp1_ready_out => m01_axis_tready,
    axi_hp1_valid_out => m01_axis_tvalid,
    axi_hp1_strb_out  => m01_axis_tstrb,
    axi_hp1_last_out  => m01_axis_tlast,
    
    --axi stream signals dram to bram
    axi_hp1_last_in	=> s01_axis_tlast,
    axi_hp1_valid_in => s01_axis_tvalid,
    axi_hp1_strb_in	=> s01_axis_tstrb,
    axi_hp1_ready_in => s01_axis_tready,

    --reg bank
    width => width_reg_s,
    width_4 => width_4_reg_s,
    width_2 => width_2_reg_s,
    height => height_reg_s,
    bram_height => bram_height_s,
    cycle_num_limit => cycle_num_in_reg_s,
    cycle_num_out => cycle_num_out_reg_s,
    rows_num => rows_num_reg_s,
    effective_row_limit => effective_row_limit_reg_s,
		
    ready => ready_s,
    
    --data signals
    data_in1 => s00_axis_tdata,
    data_in2 => s01_axis_tdata,
    data_out1 => m00_axis_tdata,
    data_out2 => m01_axis_tdata
);
    
--AXI_LIGHT:-------------------------------------------------------------------------------------

axi_light_l: axi_light_v1_0
	generic map(
		C_S00_AXI_DATA_WIDTH => DATA_WIDTH,
		C_S00_AXI_ADDR_WIDTH => AXIL_ADDR_WIDTH 
	)
	port map(
		  -- Ports towards the IP core
		-- input ports:
		status_reg => ready_s, 
		
		-- output ports:
		reset_reg => reset_s,
		ctrl_reg => start_s,
		width_reg => width_reg_s,
		width_4_reg => width_4_reg_s,
		width_2_reg => width_2_reg_s,
		height_reg => height_reg_s,
		cycle_num_in_reg => cycle_num_in_reg_s,
		cycle_num_out_reg => cycle_num_out_reg_s,
		rows_num_reg => rows_num_reg_s,
		effective_row_limit_reg => effective_row_limit_reg_s,
		bram_height => bram_height_s,
		
		-- Ports of Axi Slave Bus Interface S00_AXI
		s00_axi_aclk => clk,
		s00_axi_aresetn	=> s00_axi_aresetn,
		s00_axi_awaddr	=> s00_axi_awaddr,
		s00_axi_awprot	=> s00_axi_awprot,
		s00_axi_awvalid	=> s00_axi_awvalid,
		s00_axi_awready	=> s00_axi_awready,
		s00_axi_wdata	=> s00_axi_wdata,
		s00_axi_wstrb	=> s00_axi_wstrb,
		s00_axi_wvalid	=> s00_axi_wvalid,
		s00_axi_wready	=> s00_axi_wready,
		s00_axi_bresp	=> s00_axi_bresp,
		s00_axi_bvalid	=> s00_axi_bvalid,
		s00_axi_bready	=> s00_axi_bready,
		s00_axi_araddr	=> s00_axi_araddr,
		s00_axi_arprot	=> s00_axi_arprot,
		s00_axi_arvalid	=> s00_axi_arvalid,
		s00_axi_arready	=> s00_axi_arready,
		s00_axi_rdata	=> s00_axi_rdata,
		s00_axi_rresp	=> s00_axi_rresp,
		s00_axi_rvalid	=> s00_axi_rvalid,
		s00_axi_rready	=> s00_axi_rready
);


end Behavioral;
