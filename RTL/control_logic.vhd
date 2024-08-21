library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity control_logic is
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
    sel_bram_out_fsm: in std_logic_vector(2 downto 0); 
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
    
end control_logic;

architecture Behavioral of control_logic is

--states control_logic
type state_control_logic_t is
    (init_loop_row, loop_row, end_row);
signal state_control_logic_r, state_control_logic_n: state_control_logic_t;

--reg bank
signal width_2_reg, width_2_next: std_logic_vector(8 downto 0);
signal height_reg, height_next: std_logic_vector(10 downto 0);
signal rows_num_reg, rows_num_next: std_logic_vector(9 downto 0); --2*(bram_width/width)*bram_height
signal cycle_num_limit_reg, cycle_num_limit_next: std_logic_vector(5 downto 0);
signal effective_row_limit_reg, effective_row_limit_next: std_logic_vector(9 downto 0); --(height/PTS_PER_ROW)/accumulated_loss

signal bram_addr_A1_read_s, bram_addr_B1_read_s, bram_addr_A2_read_s, bram_addr_B2_read_s: std_logic_vector(9 downto 0);
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
        height_reg <= height_next;
        rows_num_reg <= rows_num_next;
        cycle_num_limit_reg <= cycle_num_limit_next;
        effective_row_limit_reg <= effective_row_limit_next;

        sel_filter_reg <= sel_filter_next;
        sel_bram_out_reg <= sel_bram_out_next;
        
        row_position_reg <= row_position_next;
        cycle_num_reg <= cycle_num_next;
        cnt_init_reg <= cnt_init_next;
    end if;
end if;
end process;


process(state_control_logic_r, width_2, height, rows_num, cycle_num_limit, effective_row_limit, sel_filter_reg, sel_bram_out_reg,
        row_position_reg, cycle_num_reg, cnt_init_reg, width_2_reg, height_reg, rows_num_reg, cycle_num_limit_reg, effective_row_limit_reg,
        row_position_next, sel_filter_next, sel_bram_out_next)
begin

state_control_logic_n <= state_control_logic_r;

width_2_next <= width_2_reg;
height_next <= height_reg;
rows_num_next <= rows_num_reg;
cycle_num_limit_next <= cycle_num_limit_reg;
effective_row_limit_next <= effective_row_limit_reg;

sel_filter_next <= sel_filter_reg;
sel_bram_out_next <= sel_bram_out_reg;

row_position_next <= row_position_reg;
cycle_num_next <= cycle_num_reg;
cnt_init_next <= cnt_init_reg;

case state_control_logic_r is


    when init_loop_row =>
    width_2_next <= width_2;
    height_next <= height;
    rows_num_next <= rows_num;
    cycle_num_limit_next <= cycle_num_limit;
    effective_row_limit_next <= effective_row_limit;
    
    cycle_num_next <= cycle_num;
    sel_filter_next <= sel_filter_fsm;
    sel_bram_out_next <= sel_bram_out_fsm;
        
    if(en_pipe = '1') then
        row_position_next <= (others => '0');
        state_control_logic_n <= loop_row;
    end if;

    when loop_row =>
        if (sel_filter_reg = "100") then
            bram_addr_A1_read_s <= std_logic_vector(resize((unsigned(cycle_num_reg)+1)*unsigned(width_2_reg)+unsigned(row_position_reg),10));
            bram_addr_B1_read_s <= std_logic_vector(resize((unsigned(cycle_num_reg)+1)*unsigned(width_2_reg)+unsigned(row_position_reg)+1,10));
            bram_addr_A2_read_s <= std_logic_vector(resize(unsigned(cycle_num_reg)*unsigned(width_2_reg)+unsigned(row_position_reg),10));
            bram_addr_B2_read_s <= std_logic_vector(resize(unsigned(cycle_num_reg)*unsigned(width_2_reg)+unsigned(row_position_reg)+1,10));
        else
            bram_addr_A1_read_s <= std_logic_vector(resize(unsigned(cycle_num_reg)*unsigned(width_2)+unsigned(row_position_reg),10));
            bram_addr_A2_read_s <= std_logic_vector(resize(unsigned(cycle_num_reg)*unsigned(width_2)+unsigned(row_position_reg),10));
            bram_addr_B2_read_s <= std_logic_vector(resize(unsigned(cycle_num_reg)*unsigned(width_2)+unsigned(row_position_reg)+1,10));
            bram_addr_B2_read_s <= std_logic_vector(resize(unsigned(cycle_num_reg)*unsigned(width_2)+unsigned(row_position_reg)+1,10));
        end if;

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
bram_addr_A1_read <= bram_addr_A1_read_s;
bram_addr_B1_read <= bram_addr_B1_read_s;
bram_addr_A2_read <= bram_addr_A2_read_s;
bram_addr_B2_read <= bram_addr_B2_read_s;
sel_bram_out <= sel_bram_out_reg;
sel_filter <= sel_filter_reg;
end Behavioral;
