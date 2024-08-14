library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity control_path is
  Port ( 
    clk: in std_logic;
    reset: in std_logic;
    start: in std_logic;
    en_axi: in std_logic; 
    width_4: in std_logic_vector(7 downto 0);
    width_2: in std_logic_vector(8 downto 0);
    dram_in_addr: in std_logic_vector(31 downto 0);
    dram_x_addr: in std_logic_vector(31 downto 0);
    dram_y_addr: in std_logic_vector(31 downto 0);
    cycle_num_limit: in std_logic_vector(5 downto 0); --2*bram_width/width
    cycle_num_out: in std_logic_vector(5 downto 0); --2*(bram_width/(width-1))
    bram_height: in std_logic_vector(3 downto 0);
    height: in std_logic_vector(10 downto 0);
    rows_num: in std_logic_vector(9 downto 0); --2*(bram_width/width)*bram_height
    effective_row_limit: in std_logic_vector(9 downto 0); --(height/PTS_PER_ROW)/accumulated_loss

    ready: out std_logic; 
    
    --dram_to_bram_out
    sel_bram_in: out std_logic_vector(2 downto 0);
    burst_len: out std_logic_vector(7 downto 0);
    bram_addr_A: out std_logic_vector(9 downto 0);
    bram_addr_B: out std_logic_vector(9 downto 0);
    dram_addr0: out std_logic_vector(31 downto 0);
    dram_addr1: out std_logic_vector(31 downto 0);
    
    --control logic
    sel_filter: out std_logic_vector(1 downto 0);
    sel_bram_out: out std_logic_vector(1 downto 0);
    bram_addr_x: out std_logic_vector(9 downto 0);
    bram_addr_y: out std_logic_vector(9 downto 0);
    
    --dram_to_bram
    sel_dram: out std_logic_vector(3 downto 0);
    dram_addr_x: out std_logic_vector(31 downto 0);
    dram_addr_y: out std_logic_vector(31 downto 0)
    );
end control_path;

architecture Behavioral of control_path is

type state_t is 
       (idle, dram_to_bram, control_logic, bram_to_dram);
signal state_r, state_n : state_t;

type state_dram_to_bram_t is 
       (loop_dram_to_bram0, loop_dram_to_bram1, loop_dram_to_bram2, loop_dram_to_bram3, end_dram_to_bram1, end_dram_to_bram2, end_dram_to_bram3, loop_dram_to_bram_axi);
signal state_dram_to_bram_r, state_dram_to_bram_n : state_dram_to_bram_t;

type state_control_logic_t is
        (init_loop_x, control_loop, init_loop_row, loop_row);
signal state_control_logic_r, state_control_logic_n: state_control_logic_t;

signal sel_bram_in_reg, sel_bram_in_next: std_logic_vector(3 downto 0); 
signal sel_filter_reg, sel_filter_next: std_logic_vector(1 downto 0);
signal sel_bram_out_reg, sel_bram_out_next: std_logic_vector(1 downto 0);
signal sel_dram_reg, sel_dram_next: std_logic_vector(3 downto 0);

signal dram_row_ptr0_reg, dram_row_ptr0_next: std_logic_vector(10 downto 0);
signal dram_row_ptr1_reg, dram_row_ptr1_next: std_logic_vector(10 downto 0);

signal init: std_logic;
signal burst_len_read, burst_len_write: std_logic_vector(7 downto 0);

signal width_2_reg, width_2_next: std_logic_vector(8 downto 0);
signal width_4_reg, width_4_next: std_logic_vector(9 downto 0);
signal height_reg, height_next: std_logic_vector(10 downto 0);
signal rows_num_reg, rows_num_next: std_logic_vector(9 downto 0); --2*(bram_width/width)*bram_height
signal effective_row_limit_reg, effective_row_limit_next: std_logic_vector(9 downto 0); --(height/PTS_PER_ROW)/accumulated_loss
signal bram_height_reg, bram_height_next: std_logic_vector(3 downto 0);
signal cycle_num_limit_reg, cycle_num_limit_next: std_logic_vector(5 downto 0);

signal i_reg, i_next: std_logic_vector(4 downto 0);
signal j_reg, j_next: std_logic_vector(3 downto 0);
signal k_reg, k_next: std_logic_vector(9 downto 0);

signal x_reg, x_next: std_logic_vector(9 downto 0);
signal row_position_reg, row_position_next: std_logic_vector(8 downto 0);

signal cycle_num_reg, cycle_num_next: std_logic_vector(5 downto 0);
signal sel_bram_addr_in_reg, sel_bram_addr_in_next: std_logic; 
signal counter_init_reg, counter_init_next: std_logic_vector(5 downto 0);

begin

--init
process(clk) 
begin

if(rising_edge(clk)) then
    if reset = '1' then
        state_r <= idle;
        state_dram_to_bram_r <= loop_dram_to_bram0;

        sel_bram_in_reg <= (others => '0');
        sel_filter_reg <= (others => '0');
        sel_bram_out_reg <= (others => '0');
        sel_dram_reg <= (others => '0');

        i_reg <= (others => '0');
        j_reg <= (others => '0');
        k_reg <= (others => '0');

        x_reg <= (others => '0');
        row_position_reg <= (others => '0');

        cycle_num_reg <= (others => '0');
        sel_bram_addr_in_reg <= '0';
        counter_init_reg <= (others => '0');

        dram_row_ptr0_reg <= (others => '0');
        dram_row_ptr1_reg <= "0000000001";
        init <= '1';
        burst_len_read <= "11111111";
        burst_len_write <= "11111111";
    else

        state_r <= state_n;
        state_dram_to_bram_r <= state_dram_to_bram_n;

        width_2_reg <= width_2_next;
        rows_num_reg <= rows_num_next;
        height_reg <= height_next;
        width_4_reg <= width_4_next;
        bram_height_reg <= bram_height_next;
        cycle_num_limit_reg <= cycle_num_limit_next;

        sel_bram_in_reg <= sel_bram_in_next;
        sel_filter_reg <= sel_filter_next;
        sel_bram_out_reg <= sel_bram_out_next;
        sel_dram_reg <= sel_dram_next;

        i_reg <= i_next;
        j_reg <= j_next;
        k_reg <= k_next;

        x_reg <= x_next;
        row_position_reg <= row_position_next;

        cycle_num_reg <= cycle_num_next;
        sel_bram_addr_in_reg <= sel_bram_addr_in_next;
        counter_init_reg <= counter_init_next;

        dram_row_ptr0_reg <= dram_row_ptr0_next; 
        dram_row_ptr1_reg <= dram_row_ptr1_next; 

        burst_len_read <= std_logic_vector(unsigned(width_4_reg) - 1);
        burst_len_write <= std_logic_vector(unsigned(width_4_reg) - 2);
    end if;
end if;
end process;

process(state_r) --dodati ostale sinale
begin

state_n <= state_r;

width_2_next <= width_2_reg;
rows_num_next <= rows_num_reg;
height_next <= height_reg;
width_4_next <= width_4_reg;
bram_height_next <= bram_height_reg;
cycle_num_limit_next <= cycle_num_limit_reg;

ready <= '0';

sel_bram_in_next <= sel_bram_in_reg;

case state_r is
    when idle =>    
        width_2_next <= width_2;
        rows_num_next <= rows_num;
        height_next <= height;
        width_4_next <= width_4;
        bram_height_next <= bram_height;
        cycle_num_limit_next <= cycle_num_limit;
    
        ready <= '1';
    
        if(start = '1') then
            state_n <= dram_to_bram;
        end if;

    when dram_to_bram =>
    state_dram_to_bram_n <= state_dram_to_bram_r;
    i_next <= i_reg;
    sel_bram_in_next <= sel_bram_in_reg;
    j_next <= j_reg;
    k_next <= k_reg;
    dram_row_ptr0_next <= dram_row_ptr0_reg;
    dram_row_ptr1_next <= dram_row_ptr1_reg;
    case state_dram_to_bram_r is
        when loop_dram_to_bram0 =>
            i_next <= (others => '0');
            sel_bram_in_next <= (others => '0');
            state_dram_to_bram_n <= loop_dram_to_bram1;
        when loop_dram_to_bram1 =>
            j_next <= (others => '0');
            state_dram_to_bram_n <= loop_dram_to_bram2;
        when loop_dram_to_bram2 =>
            dram_addr0 <= std_logic_vector(unsigned(dram_row_ptr0_reg)*unsigned(width_4_reg));
            dram_addr1 <= std_logic_vector(unsigned(dram_row_ptr1_reg)*unsigned(width_4_reg));
            k_next <= (others => '0');
            state_dram_to_bram_n <= loop_dram_to_bram_axi;
        when loop_dram_to_bram_axi=>
            if(en_axi = '1') then
                state_dram_to_bram_n <= loop_dram_to_bram3;
            end if;
        when loop_dram_to_bram3 =>
            bram_addr_A <= std_logic_vector(unsigned(i_reg)*unsigned(width_2_reg) + unsigned(k_reg)); 
            bram_addr_B <= std_logic_vector(unsigned(i_reg)*unsigned(width_2_reg) + unsigned(k_reg) + 1);  
            k_next <= std_logic_vector(unsigned(k_reg) + 2);
            
            if(k_next = width_2_reg) then
                state_dram_to_bram_n <= end_dram_to_bram3;
            end if;
        when end_dram_to_bram3 =>
            dram_row_ptr0_next <= std_logic_vector(unsigned(dram_row_ptr0_reg) + 2);
            dram_row_ptr1_next <= std_logic_vector(unsigned(dram_row_ptr1_reg) + 2);
            sel_bram_in_next <= std_logic_vector(unsigned(sel_bram_in_reg) + 1);
            
            if(dram_row_ptr1_next = height_reg) then
                state_dram_to_bram_n <= end_dram_to_bram1;
            end if;

            if(sel_bram_in_next = "1000") then
                sel_bram_in_next <= (others => '0');
            end if;
            
            j_next <= std_logic_vector(unsigned(j_reg) + 2);
            
            if(j_next = bram_height_reg) then
                state_dram_to_bram_n <= end_dram_to_bram2;
            else
                state_dram_to_bram_n <= loop_dram_to_bram2;
            end if;
        when end_dram_to_bram2 =>
            i_next <= std_logic_vector(unsigned(i_reg) + 1);
            if(i_next = cycle_num_limit_reg) then
                state_dram_to_bram_n <= end_dram_to_bram1;
            else
                state_dram_to_bram_n <= loop_dram_to_bram1;
            end if;
        when end_dram_to_bram1 =>
            if(init = '1') then
                init <= '0';
                i_next <= (others => '0');
                state_n <= control_logic;
            else
                state_n <= control_logic;
                state_control_logic_n <= init_loop_row;
            end if;
    end case;
    
    when control_logic =>
    state_control_logic_n <= state_control_logic_r;
    x_next <= x_reg;
    row_position_next <= row_position_reg;
    cycle_num_next <= cycle_num_reg;
    sel_bram_addr_in_next <= sel_bram_addr_in_reg;
    counter_init_next <= counter_init_reg;
    case state_control_logic_r is
        when init_loop_x =>
            x_next <= (others => '0');
            state_control_logic_n <= control_loop;
        when control_loop =>
            cycle_num_next <= x_reg(9 downto 4);
            if(cycle_num_next = cycle_num_limit_reg and x_reg = std_logic_vector(12*unsigned(cycle_num_next))) then
                if(dram_row_ptr1_reg < height_reg) then --da li ovo treba staviti i fore poslije when?
                    counter_init_next <= std_logic_vector(unsigned(counter_init_reg) + 1); 
                    dram_row_ptr0_next <= std_logic_vector(unsigned(rows_num_reg) - 4 * unsigned(counter_init_next));
                    dram_row_ptr1_next <= std_logic_vector(unsigned(rows_num_reg) - 4 * unsigned(counter_init_next) + 1);
                    x_next <= std_logic_vector(unsigned(x_reg) + 4);
                    cycle_num_next <= (others => '0');
                    sel_filter_next <= (others => '0');
                    sel_bram_out_next <= (others => '0');
                    state_n <= dram_to_bram; 
                    state_dram_to_bram_n <= loop_dram_to_bram0;
                else 
                    state_control_logic_n <= init_loop_row;
                end if;
            else
                state_control_logic_n <= init_loop_row;
            end if;
        when init_loop_row =>
            row_position_next <= (others => '0');
            sel_bram_addr_in_next <= '1';
            state_control_logic_n <= loop_row;
    
    end case;
end case;
end process;
end Behavioral;
