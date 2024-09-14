library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top is
  generic(DATA_WIDTH:natural:=32;
          BRAM_SIZE:natural:=1024;
          ADDR_WIDTH:natural:=10;
          PIX_WIDTH:natural:=16);
  Port ( 
    clk: in std_logic;
    reset: in std_logic;
    start: in std_logic;
    
    --HP0:
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
end top;

architecture Behavioral of top is

signal ready_s: std_logic;

--sel signal
signal sel_bram_in_s: std_logic_vector(3 downto 0);
signal sel_filter_s: std_logic_vector(2 downto 0);
signal sel_bram_out_s: std_logic_vector(2 downto 0);
signal sel_dram_s: std_logic_vector(4 downto 0);
signal realloc_last_rows_s: std_logic;

signal we_in_s: std_logic_vector(31 downto 0);
signal we_out_s: std_logic_vector(15 downto 0);

signal bram_addrA_l_in_s: std_logic_vector(ADDR_WIDTH - 1 downto 0);
signal bram_addrB_l_in_s: std_logic_vector(ADDR_WIDTH - 1 downto 0);
signal bram_addrA_h_in_s: std_logic_vector(ADDR_WIDTH - 1 downto 0);
signal bram_addrB_h_in_s: std_logic_vector(ADDR_WIDTH - 1 downto 0);
signal bram_addrA12_in_s: std_logic_vector(ADDR_WIDTH - 1 downto 0);
signal bram_addrB12_in_s: std_logic_vector(ADDR_WIDTH - 1 downto 0);

signal bram_addr_A_out_s: std_logic_vector(ADDR_WIDTH - 1 downto 0);
signal bram_addr_B_out_s: std_logic_vector(ADDR_WIDTH - 1 downto 0);

signal data_out1_s, data_out2_s: std_logic_vector(63 downto 0);

--SIGNALS FOR VERIFICATION:----------------------------------------------------------------------------
signal data_out11_s, data_out12_s, data_out13_s, data_out14_s, data_out21_s, data_out22_s, data_out23_s, data_out24_s: std_logic_vector(15 downto 0); 
---------------------------------------------------------------------------------------------------------------------


component data_path is
  generic(WIDTH:natural:=32;
          BRAM_SIZE:natural:=1024;
          ADDR_WIDTH:natural:=10;
          PIX_WIDTH:natural:=16);
  Port ( --data signals 
        data_in1: in std_logic_vector(2*WIDTH-1 downto 0);
        data_in2: in std_logic_vector(2*WIDTH-1 downto 0);
        data_out1: out std_logic_vector(2*WIDTH-1 downto 0);
        data_out2: out std_logic_vector(2*WIDTH-1 downto 0);
        --control signals
        clk: in std_logic;
        we_in: in std_logic_vector(31 downto 0); 
        we_out:in std_logic_vector(15 downto 0);
        sel_bram_in: in std_logic_vector(3 downto 0);
        sel_bram_out: in std_logic_vector(2 downto 0);
        sel_filter: in std_logic_vector(2 downto 0);
        sel_dram: in std_logic_vector(4 downto 0);
        realloc_last_rows: in std_logic;
        bram_addrA_l_in: in std_logic_vector(ADDR_WIDTH - 1 downto 0);
        bram_addrB_l_in: in std_logic_vector(ADDR_WIDTH - 1 downto 0);
        bram_addrA_h_in: in std_logic_vector(ADDR_WIDTH - 1 downto 0);
        bram_addrB_h_in: in std_logic_vector(ADDR_WIDTH - 1 downto 0);
        bram_addrA12_in: in std_logic_vector(ADDR_WIDTH - 1 downto 0);
        bram_addrB12_in: in std_logic_vector(ADDR_WIDTH - 1 downto 0);
        bram_addr_A_out: in std_logic_vector(ADDR_WIDTH - 1 downto 0);
        bram_addr_B_out: in std_logic_vector(ADDR_WIDTH - 1 downto 0)
        );
end component;

component control_path_v2 is
  Port ( 
    clk: in std_logic;
    reset: in std_logic;
    start: in std_logic; 
    
    --HP0:
    --axi stream signals bram to dram
    axi_hp0_ready_out: in std_logic;
    axi_hp0_valid_out: out std_logic;
    axi_hp0_last_out: out std_logic;
    
    --axi stream signals dram to bram
    axi_hp0_last_in: in std_logic;
    axi_hp0_valid_in: in std_logic;
    axi_hp0_ready_in: out std_logic;
    
    --HP1:
    --axi stream signals bram to dram
    axi_hp1_ready_out: in std_logic;
    axi_hp1_valid_out: out std_logic;
    axi_hp1_last_out: out std_logic;
    
    --axi stream signals dram to bram
    axi_hp1_last_in: in std_logic;
    axi_hp1_valid_in: in std_logic;
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
    
    --dram_to_bram
    sel_bram_in: out std_logic_vector(3 downto 0);
    bram_addr_A1: out std_logic_vector(9 downto 0); --bram block 0-3
    bram_addr_B1: out std_logic_vector(9 downto 0); --bram block 0-3
    bram_addr_A2: out std_logic_vector(9 downto 0); --bram block 4-11
    bram_addr_B2: out std_logic_vector(9 downto 0); --bram block 4-11
    bram_addr_A12: out std_logic_vector(9 downto 0); --bram block 12-15
    bram_addr_B12: out std_logic_vector(9 downto 0); --bram block 12-15
    we_in: out std_logic_vector(31 downto 0);
    we_out: out std_logic_vector(15 downto 0); 
    realloc_last_rows: out std_logic;
    
    --control logic
    sel_filter: out std_logic_vector(2 downto 0);
    sel_bram_out: out std_logic_vector(2 downto 0);
    bram_output_addr_A: out std_logic_vector(9 downto 0);
    bram_output_addr_B: out std_logic_vector(9 downto 0);
    
    --bram_to_dram
    sel_dram: out std_logic_vector(4 downto 0));
end component;

begin

data_path_l: data_path
    generic map(
      WIDTH => DATA_WIDTH,
      BRAM_SIZE => BRAM_SIZE,
      ADDR_WIDTH => ADDR_WIDTH,
      PIX_WIDTH => PIX_WIDTH)
    port map(
      data_in1 => data_in1,
      data_in2 => data_in2,
      data_out1 => data_out1_s,
      data_out2 => data_out2_s,
    
      clk => clk,
      we_in => we_in_s,
      we_out => we_out_s,
      sel_bram_in => sel_bram_in_s,
      sel_bram_out => sel_bram_out_s,
      sel_filter => sel_filter_s,
      sel_dram => sel_dram_s,
      realloc_last_rows => realloc_last_rows_s,
      bram_addrA_l_in => bram_addrA_l_in_s,
      bram_addrB_l_in => bram_addrB_l_in_s,
      bram_addrA_h_in => bram_addrA_h_in_s,
      bram_addrB_h_in => bram_addrB_h_in_s,
      bram_addrA12_in => bram_addrA12_in_s,
      bram_addrB12_in => bram_addrB12_in_s,
      bram_addr_A_out => bram_addr_A_out_s,
      bram_addr_B_out => bram_addr_B_out_s);

control_path_l: control_path_v2
Port map( 
    clk => clk,
    reset => reset,
    start => start,
    
    --HP0:
    --axi stream signals bram to dram
    axi_hp0_ready_out => axi_hp0_ready_out,
    axi_hp0_valid_out => axi_hp0_valid_out,
    axi_hp0_last_out => axi_hp0_last_out,
    
    --axi stream signals dram to bram
    axi_hp0_last_in => axi_hp0_last_in,
    axi_hp0_valid_in => axi_hp0_valid_in,
    axi_hp0_ready_in => axi_hp0_ready_in,
    
    --HP1:
    --axi stream signals bram to dram
    axi_hp1_ready_out => axi_hp1_ready_out,
    axi_hp1_valid_out => axi_hp1_valid_out,
    axi_hp1_last_out => axi_hp1_last_out,
    
    --axi stream signals dram to bram
    axi_hp1_last_in => axi_hp1_last_in,
    axi_hp1_valid_in => axi_hp1_valid_in,
    axi_hp1_ready_in => axi_hp1_ready_in,
    
    
    --reg bank
    width => width,
    width_4 => width_4,
    width_2 => width_2,
    height => height,
    bram_height => bram_height,
    cycle_num_limit => cycle_num_limit,
    cycle_num_out => cycle_num_out,
    rows_num => rows_num,
    effective_row_limit => effective_row_limit,
    ready => ready_s,
    
    --dram_to_bram
    sel_bram_in => sel_bram_in_s,
    bram_addr_A1 => bram_addrA_l_in_s,
    bram_addr_B1 => bram_addrB_l_in_s,
    bram_addr_A2 => bram_addrA_h_in_s,
    bram_addr_B2 => bram_addrB_h_in_s,
    bram_addr_A12 => bram_addrA12_in_s,
    bram_addr_B12 => bram_addrB12_in_s,
    we_in => we_in_s,
    we_out => we_out_s,
    realloc_last_rows => realloc_last_rows_s,
    
    --control logic
    sel_filter => sel_filter_s,
    sel_bram_out => sel_bram_out_s,
    bram_output_addr_A => bram_addr_A_out_s,
    bram_output_addr_B => bram_addr_B_out_s,
    
    --bram_to_dram
    sel_dram => sel_dram_s);
  
ready <= ready_s;

data_out1 <= data_out1_s;
data_out2 <= data_out2_s;

axi_hp0_strb_out <= "11111111";
axi_hp1_strb_out <= "11111111";

--SIGNALS FOR VERIFICATION:--------------------------------------------------------------------
data_out11_s <= data_out1_s(63 downto 48);
data_out12_s <= data_out1_s(47 downto 32);
data_out13_s <= data_out1_s(31 downto 16);
data_out14_s <= data_out1_s(15 downto 0);

data_out21_s <= data_out2_s(63 downto 48);
data_out22_s <= data_out2_s(47 downto 32);
data_out23_s <= data_out2_s(31 downto 16);
data_out24_s <= data_out2_s(15 downto 0);
--------------------------------------------------------------------------------------------------
end Behavioral;
