----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/21/2024 09:00:52 PM
-- Design Name: 
-- Module Name: control_path_v2 - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity control_path_v2 is
  Port ( 
    clk: in std_logic;
    reset: in std_logic;
    --reg bank
    width_2: in std_logic_vector(8 downto 0);
    height: in std_logic_vector(10 downto 0);
    cycle_num_limit: in std_logic_vector(5 downto 0); --2*bram_width/width
    rows_num: in std_logic_vector(9 downto 0); --2*(bram_width/width)*bram_height
    effective_row_limit: in std_logic_vector(9 downto 0); --(height/PTS_PER_ROW)/accumulated_loss
    --sig for FSM
    en_pipe: in std_logic;
    cycle_num: in std_logic_vector(5 downto 0); 
    sel_bram_out_fsm: in std_logic_vector(2 downto 0); --pazi
    sel_filter_fsm: in std_logic_vector(2 downto 0);
    pipe_finished: out std_logic;
    --out sig
    bram_output_xy_addr:out std_logic_vector(9 downto 0);
    bram_addr_A1_read: out std_logic_vector(9 downto 0);
    bram_addr_B1_read: out std_logic_vector(9 downto 0);
    bram_addr_A2_read: out std_logic_vector(9 downto 0); 
    bram_addr_B2_read: out std_logic_vector(9 downto 0);
    sel_bram_out: out std_logic_vector(2 downto 0);
    sel_filter: out std_logic_vector(2 downto 0));
end control_path_v2;

architecture Behavioral of control_path_v2 is

component bram_to_dram is
  Port ( 
    clk: in std_logic;
    reset: in std_logic;
    --reg bank
    width: in std_logic_vector(9 downto 0);
    width_4: in std_logic_vector(7 downto 0);
    width_2: in std_logic_vector(8 downto 0);
    height: in std_logic_vector(10 downto 0);
    bram_height: in std_logic_vector(3 downto 0);
    cycle_num_out: in std_logic_vector(5 downto 0); --2*(bram_width/(width-1))
    dram_x_addr: in std_logic_vector(31 downto 0);
    dram_y_addr: in std_logic_vector(31 downto 0);
    --sig for FSM
    en_bram_to_dram: in std_logic;
    bram_to_dram_finished: out std_logic;
    --bram_to_dram
    bram_addr_bram_to_dram_A: out std_logic_vector(9 downto 0);
    bram_addr_bram_to_dram_B: out std_logic_vector(9 downto 0);
    sel_dram: out std_logic_vector(4 downto 0);
    dram_out_addr_x: out std_logic_vector(31 downto 0);
    dram_out_addr_y: out std_logic_vector(31 downto 0));
end component;

component control_logic is
  Port ( 
    clk: in std_logic;
    reset: in std_logic;
    --reg bank
    width_2: in std_logic_vector(8 downto 0);
    height: in std_logic_vector(10 downto 0);
    cycle_num_limit: in std_logic_vector(5 downto 0); --2*bram_width/width
    rows_num: in std_logic_vector(9 downto 0); --2*(bram_width/width)*bram_height
    effective_row_limit: in std_logic_vector(9 downto 0); --(height/PTS_PER_ROW)/accumulated_loss
    --sig for FSM
    en_pipe: in std_logic;
    cycle_num: in std_logic_vector(5 downto 0); 
    sel_bram_out_fsm: in std_logic_vector(2 downto 0); --pazi
    sel_filter_fsm: in std_logic_vector(2 downto 0);
    pipe_finished: out std_logic;
    --out sig
    bram_output_xy_addr:out std_logic_vector(9 downto 0);
    bram_addr_A1_read: out std_logic_vector(9 downto 0);
    bram_addr_B1_read: out std_logic_vector(9 downto 0);
    bram_addr_A2_read: out std_logic_vector(9 downto 0); 
    bram_addr_B2_read: out std_logic_vector(9 downto 0);
    sel_bram_out: out std_logic_vector(2 downto 0);
    sel_filter: out std_logic_vector(2 downto 0));
end component;

component dram_to_bram is
  Port (     
    clk: in std_logic;
    reset: in std_logic;
    en_axi: in std_logic;
    
    --reg bank
    width_4: in std_logic_vector(7 downto 0);
    width_2: in std_logic_vector(8 downto 0);
    height: in std_logic_vector(10 downto 0);
    dram_in_addr: in std_logic_vector(31 downto 0);
    cycle_num_limit: in std_logic_vector(5 downto 0); --2*bram_width/width
    bram_height: in std_logic_vector(3 downto 0);
    
    --sig for FSM
    en_dram_to_bram: in std_logic;
    dram_row_ptr0: in std_logic_vector(10 downto 0);
    dram_row_ptr1: in std_logic_vector(10 downto 0); 
    dram_to_bram_finished: out std_logic; 
    
    --out signals
    we_in: out std_logic_vector(31 downto 0);
    sel_bram_in: out std_logic_vector(3 downto 0);
    bram_addr_A1_write: out std_logic_vector(9 downto 0); --bram block 0-1
    bram_addr_B1_write: out std_logic_vector(9 downto 0); --bram block 0-1
    bram_addr_A2_write: out std_logic_vector(9 downto 0); --bram block 2-15
    bram_addr_B2_write: out std_logic_vector(9 downto 0); --bram block 2-15
    dram_addr0: out std_logic_vector(31 downto 0);
    dram_addr1: out std_logic_vector(31 downto 0);
    burst_len_read: out std_logic_vector(7 downto 0));
end component;


begin


end Behavioral;
