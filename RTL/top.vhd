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
    en_axi: in std_logic; 

    --reg bank
    width: in std_logic_vector(9 downto 0);
    width_4: in std_logic_vector(7 downto 0);
    width_2: in std_logic_vector(8 downto 0);
    height: in std_logic_vector(10 downto 0);
    bram_height: in std_logic_vector(3 downto 0);
    dram_in_addr: in std_logic_vector(31 downto 0);
    dram_x_addr: in std_logic_vector(31 downto 0);
    dram_y_addr: in std_logic_vector(31 downto 0);
    cycle_num_limit: in std_logic_vector(5 downto 0); --2*bram_width/width
    cycle_num_out: in std_logic_vector(5 downto 0); --2*(bram_width/(width-1))
    rows_num: in std_logic_vector(9 downto 0); --2*(bram_width/width)*bram_height
    effective_row_limit: in std_logic_vector(9 downto 0); --(height/PTS_PER_ROW)/accumulated_loss
    
    burst_len_read: out std_logic_vector(7 downto 0);
    burst_len_write: out std_logic_vector(7 downto 0);
    
    dram_addr0: out std_logic_vector(31 downto 0);
    dram_addr1: out std_logic_vector(31 downto 0);
    
    dram_out_addr_x: out std_logic_vector(31 downto 0);
    dram_out_addr_y: out std_logic_vector(31 downto 0);

    ready: out std_logic; 
    
    --data signals
    data_in1: in std_logic_vector(31 downto 0);
    data_in2: in std_logic_vector(31 downto 0);
    data_in3: in std_logic_vector(31 downto 0);
    data_in4: in std_logic_vector(31 downto 0);
    data_out1: out std_logic_vector(31 downto 0);
    data_out2: out std_logic_vector(31 downto 0);
    data_out3: out std_logic_vector(31 downto 0);
    data_out4: out std_logic_vector(31 downto 0));
end top;

architecture Behavioral of top is

signal ready_s: std_logic;

--sel signal
signal sel_bram_in_s: std_logic_vector(3 downto 0);
signal sel_filter_s: std_logic_vector(2 downto 0);
signal sel_bram_out_s: std_logic_vector(2 downto 0);
signal sel_dram_s: std_logic_vector(4 downto 0);

signal we_in_s: std_logic_vector(31 downto 0);
signal we_out_s: std_logic_vector(15 downto 0);

signal bram_addrA_l_in_s: std_logic_vector(ADDR_WIDTH - 1 downto 0);
signal bram_addrB_l_in_s: std_logic_vector(ADDR_WIDTH - 1 downto 0);
signal bram_addrA_h_in_s: std_logic_vector(ADDR_WIDTH - 1 downto 0);
signal bram_addrB_h_in_s: std_logic_vector(ADDR_WIDTH - 1 downto 0);

signal bram_addr_A_out_s: std_logic_vector(ADDR_WIDTH - 1 downto 0);
signal bram_addr_B_out_s: std_logic_vector(ADDR_WIDTH - 1 downto 0);

signal burst_len_read_s: std_logic_vector(7 downto 0);
signal burst_len_write_s: std_logic_vector(7 downto 0);

signal data_out1_s, data_out2_s, data_out3_s, data_out4_s: std_logic_vector(31 downto 0);

signal dram_addr0_s: std_logic_vector(31 downto 0);
signal dram_addr1_s: std_logic_vector(31 downto 0);
signal dram_out_addr_x_s: std_logic_vector(31 downto 0);
signal dram_out_addr_y_s: std_logic_vector(31 downto 0);

component data_path is
  generic(WIDTH:natural:=32;
          BRAM_SIZE:natural:=1024;
          ADDR_WIDTH:natural:=10;
          PIX_WIDTH:natural:=16);
  Port ( --data signals 
        data_in1: in std_logic_vector(WIDTH-1 downto 0);
        data_in2: in std_logic_vector(WIDTH-1 downto 0);
        data_in3: in std_logic_vector(WIDTH-1 downto 0);
        data_in4: in std_logic_vector(WIDTH-1 downto 0);
        data_out1: out std_logic_vector(WIDTH-1 downto 0);
        data_out2: out std_logic_vector(WIDTH-1 downto 0);
        data_out3: out std_logic_vector(WIDTH-1 downto 0);
        data_out4: out std_logic_vector(WIDTH-1 downto 0);
        --control signals
        clk: in std_logic;
        we_in: in std_logic_vector(31 downto 0); 
        we_out:in std_logic_vector(15 downto 0);
        sel_bram_in: in std_logic_vector(3 downto 0);
        sel_bram_out: in std_logic_vector(2 downto 0);
        sel_filter: in std_logic_vector(2 downto 0);
        sel_dram: in std_logic_vector(4 downto 0);
        bram_addrA_l_in: in std_logic_vector(ADDR_WIDTH - 1 downto 0);
        bram_addrB_l_in: in std_logic_vector(ADDR_WIDTH - 1 downto 0);
        bram_addrA_h_in: in std_logic_vector(ADDR_WIDTH - 1 downto 0);
        bram_addrB_h_in: in std_logic_vector(ADDR_WIDTH - 1 downto 0);
        bram_addr_A_out: in std_logic_vector(ADDR_WIDTH - 1 downto 0);
        bram_addr_B_out: in std_logic_vector(ADDR_WIDTH - 1 downto 0)
        );
end component;

component control_path is
  Port ( 
    clk: in std_logic;
    reset: in std_logic;
    start: in std_logic;
    en_axi: in std_logic; 

    --reg bank
    width: in std_logic_vector(9 downto 0);
    width_4: in std_logic_vector(7 downto 0);
    width_2: in std_logic_vector(8 downto 0);
    height: in std_logic_vector(10 downto 0);
    bram_height: in std_logic_vector(3 downto 0);
    dram_in_addr: in std_logic_vector(31 downto 0);
    dram_x_addr: in std_logic_vector(31 downto 0);
    dram_y_addr: in std_logic_vector(31 downto 0);
    cycle_num_limit: in std_logic_vector(5 downto 0); --2*bram_width/width
    cycle_num_out: in std_logic_vector(5 downto 0); --2*(bram_width/(width-1))
    rows_num: in std_logic_vector(9 downto 0); --2*(bram_width/width)*bram_height
    effective_row_limit: in std_logic_vector(9 downto 0); --(height/PTS_PER_ROW)/accumulated_loss

    ready: out std_logic; 
    
    --dram_to_bram
    sel_bram_in: out std_logic_vector(3 downto 0);
    bram_addr_A1: out std_logic_vector(9 downto 0); --bram block 0-1
    bram_addr_B1: out std_logic_vector(9 downto 0); --bram block 0-1
    bram_addr_A2: out std_logic_vector(9 downto 0); --bram block 2-15
    bram_addr_B2: out std_logic_vector(9 downto 0); --bram block 2-15
    dram_addr0: out std_logic_vector(31 downto 0);
    dram_addr1: out std_logic_vector(31 downto 0);
    we_in: out std_logic_vector(31 downto 0);
    we_out: out std_logic_vector(15 downto 0); 
    burst_len_read: out std_logic_vector(7 downto 0);
    burst_len_write: out std_logic_vector(7 downto 0);
    
    --control logic
    sel_filter: out std_logic_vector(2 downto 0);
    sel_bram_out: out std_logic_vector(2 downto 0);
    bram_output_addr_A: out std_logic_vector(9 downto 0);
    bram_output_addr_B: out std_logic_vector(9 downto 0);
    
    --bram_to_dram
    sel_dram: out std_logic_vector(4 downto 0);
    dram_out_addr_x: out std_logic_vector(31 downto 0);
    dram_out_addr_y: out std_logic_vector(31 downto 0)
    );
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
      data_in3 => data_in3,
      data_in4 => data_in4,
      data_out1 => data_out1_s,
      data_out2 => data_out2_s,
      data_out3 => data_out3_s,
      data_out4 => data_out4_s,
    
      clk => clk,
      we_in => we_in_s,
      we_out => we_out_s,
      sel_bram_in => sel_bram_in_s,
      sel_bram_out => sel_bram_out_s,
      sel_filter => sel_filter_s,
      sel_dram => sel_dram_s,
      bram_addrA_l_in => bram_addrA_l_in_s,
      bram_addrB_l_in => bram_addrB_l_in_s,
      bram_addrA_h_in => bram_addrA_h_in_s,
      bram_addrB_h_in => bram_addrB_h_in_s,
      bram_addr_A_out => bram_addr_A_out_s,
      bram_addr_B_out => bram_addr_B_out_s);

control_path_l: control_path
Port map( 
  clk => clk,
  reset => reset,
  start => start,
  en_axi => en_axi, 

  --reg bank
  width => width,
  width_4 => width_4,
  width_2 => width_2,
  height => height,
  bram_height => bram_height,
  dram_in_addr => dram_in_addr,
  dram_x_addr => dram_x_addr,
  dram_y_addr => dram_y_addr,
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
  dram_addr0 => dram_addr0_s,
  dram_addr1 => dram_addr1_s,
  we_in => we_in_s,
  we_out => we_out_s,
  burst_len_read => burst_len_read_s,
  burst_len_write => burst_len_write_s,
  
  --control logic
  sel_filter => sel_filter_s,
  sel_bram_out => sel_bram_out_s,
  bram_output_addr_A => bram_addr_A_out_s,
  bram_output_addr_B => bram_addr_B_out_s,
  
  --bram_to_dram
  sel_dram => sel_dram_s,
  dram_out_addr_x => dram_out_addr_x_s,
  dram_out_addr_y => dram_out_addr_y_s
  );
  
ready <= ready_s;

burst_len_read <= burst_len_read_s;
burst_len_write <= burst_len_write_s;

data_out1 <= data_out1_s;
data_out2 <= data_out2_s;
data_out3 <= data_out3_s;
data_out4 <= data_out4_s;

dram_addr0 <= dram_addr0_s;
dram_addr1 <= dram_addr1_s;
dram_out_addr_x <= dram_out_addr_x_s;
dram_out_addr_y <= dram_out_addr_y_s;

end Behavioral;
