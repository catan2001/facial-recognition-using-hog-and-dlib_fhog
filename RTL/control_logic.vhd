library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity control_logic is
  Port ( 
    clk: in std_logic;
    reset: in std_logic;
    --reg bank
    width_2: in std_logic_vector(8 downto 0);
    --sig for FSM
    en_pipe: in std_logic;
    cycle_num: in std_logic_vector(5 downto 0); 
    sel_bram_out_fsm: in std_logic_vector(2 downto 0); 
    sel_filter_fsm: in std_logic_vector(2 downto 0);
    pipe_finished: out std_logic;
    --out sig
    bram_output_xy_addr:out std_logic_vector(9 downto 0);
    row_position: out std_logic_vector(8 downto 0);
    sel_bram_out: out std_logic_vector(2 downto 0);
    sel_filter: out std_logic_vector(2 downto 0));
    
end control_logic;

architecture Behavioral of control_logic is

--states control_logic
type state_control_logic_t is
    (init_loop_row, loop_row, end_row);
signal state_control_logic_r, state_control_logic_n: state_control_logic_t;

--reg bank
signal width_2_reg, width_2_next: std_logic_vector(8 downto 0);

signal bram_output_xy_addr_s: std_logic_vector(9 downto 0);

signal sel_filter_reg, sel_filter_next: std_logic_vector(2 downto 0);
signal sel_bram_out_reg, sel_bram_out_next: std_logic_vector(2 downto 0);

signal cycle_num_reg, cycle_num_next: std_logic_vector(5 downto 0); 
signal row_position_reg, row_position_next: std_logic_vector(8 downto 0);
signal cnt_init_reg, cnt_init_next: std_logic_vector(5 downto 0);

signal pipe_finished_s: std_logic;

begin

--init
process(clk) 
begin

if(rising_edge(clk)) then
    if reset = '1' then
        state_control_logic_r <= init_loop_row;

        sel_filter_reg <= (others => '0');
        sel_bram_out_reg <= (others => '0');
        
        row_position_reg <= (others => '0');
        cycle_num_reg <= (others => '0');
        cnt_init_reg <= "000001";

    else

        state_control_logic_r <= state_control_logic_n;

        width_2_reg <= width_2_next;

        sel_filter_reg <= sel_filter_next;
        sel_bram_out_reg <= sel_bram_out_next;
        
        row_position_reg <= row_position_next;
        cycle_num_reg <= cycle_num_next;
        cnt_init_reg <= cnt_init_next;
    end if;
end if;
end process;


process(state_control_logic_r, width_2, sel_filter_reg, sel_bram_out_reg,
        row_position_reg, cycle_num_reg, cnt_init_reg, width_2_reg, sel_filter_fsm, 
        row_position_next, sel_filter_next, sel_bram_out_next, cycle_num, sel_bram_out_fsm, 
        en_pipe)
begin

state_control_logic_n <= state_control_logic_r;

width_2_next <= width_2_reg;

sel_filter_next <= sel_filter_reg;
sel_bram_out_next <= sel_bram_out_reg;

row_position_next <= row_position_reg;
cycle_num_next <= cycle_num_reg;
cnt_init_next <= cnt_init_reg;

case state_control_logic_r is

    when init_loop_row =>
    width_2_next <= width_2;
    
    cycle_num_next <= cycle_num;
    sel_filter_next <= sel_filter_fsm;
    sel_bram_out_next <= sel_bram_out_fsm;
        
    if(en_pipe = '1') then
        row_position_next <= (others => '0');
        state_control_logic_n <= loop_row;
    end if;

    when loop_row =>
        bram_output_xy_addr_s <= std_logic_vector(resize(unsigned(cycle_num_reg)*(unsigned(width_2_reg)-1)+shift_right(unsigned(row_position_reg),1),10));
        row_position_next <= std_logic_vector(unsigned(row_position_reg)+2);
        
        if(row_position_next = std_logic_vector(unsigned(width_2_reg)-1)) then 
            state_control_logic_n <= end_row;
        end if;

    when end_row =>
        sel_filter_next <= std_logic_vector(unsigned(sel_filter_reg) + 1);
        if(sel_filter_next = "100") then
            sel_filter_next <= (others => '0');
        end if;    
        sel_bram_out_next <= std_logic_vector(unsigned(sel_bram_out_reg) + 1);
        if(sel_bram_out_next = "100") then
            sel_bram_out_next <= (others => '0');
        end if;
        pipe_finished_s <= '1';

end case;
end process;

pipe_finished <= pipe_finished_s;
bram_output_xy_addr <= bram_output_xy_addr_s;
row_position <= row_position_reg;
sel_bram_out <= sel_bram_out_reg;
sel_filter <= sel_filter_reg;
end Behavioral;
