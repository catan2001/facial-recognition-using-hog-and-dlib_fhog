library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity dram_to_bram is
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
    bram_height: in std_logic_vector(4 downto 0);
    
    --sig for FSM
    reinit: in std_logic;
    en_dram_to_bram: in std_logic;
    dram_row_ptr0: in std_logic_vector(10 downto 0);
    dram_row_ptr1: in std_logic_vector(10 downto 0); 
    dram_to_bram_finished: out std_logic; 
    realloc_last_rows: in std_logic;
    
    --out signals
    we_in: out std_logic_vector(31 downto 0);
    sel_bram_in: out std_logic_vector(3 downto 0);
    i: out std_logic_vector(5 downto 0);
    k: out std_logic_vector(9 downto 0);
    dram_addr0: out std_logic_vector(31 downto 0);
    dram_addr1: out std_logic_vector(31 downto 0);
    burst_len_read: out std_logic_vector(7 downto 0));
end dram_to_bram;

architecture Behavioral of dram_to_bram is

--states dram to bram
type state_dram_to_bram_t is 
    (loop_dram_to_bram0, loop_dram_to_bram1);
signal state_dram_to_bram_r, state_dram_to_bram_n : state_dram_to_bram_t;

signal width_2_reg, width_2_next: std_logic_vector(8 downto 0);
signal width_4_reg, width_4_next: std_logic_vector(7 downto 0);
signal height_reg, height_next: std_logic_vector(10 downto 0);
signal bram_height_reg, bram_height_next: std_logic_vector(4 downto 0);
signal dram_in_addr_reg, dram_in_addr_next: std_logic_vector(31 downto 0);
signal cycle_num_limit_reg, cycle_num_limit_next: std_logic_vector(5 downto 0);

signal i_reg, i_next: std_logic_vector(5 downto 0);
signal j_reg, j_next: std_logic_vector(4 downto 0);
signal j_limit_reg, j_limit_next: std_logic_vector(4 downto 0);
signal k_reg, k_next: std_logic_vector(9 downto 0);

signal we_in_reg, we_in_next: std_logic_vector(31 downto 0);
signal sel_bram_in_reg, sel_bram_in_next: std_logic_vector(3 downto 0); 

signal dram_addr0_s, dram_addr1_s: std_logic_vector(31 downto 0);
signal dram_row_ptr0_reg, dram_row_ptr0_next: std_logic_vector(10 downto 0);
signal dram_row_ptr1_reg, dram_row_ptr1_next: std_logic_vector(10 downto 0);

signal dram_to_bram_finished_reg, dram_to_bram_finished_next: std_logic;
--signal burst_len_read_s: std_logic_vector(7 downto 0);

begin

process(clk) 
begin

if(rising_edge(clk)) then
    if reset = '1' then
    
        state_dram_to_bram_r <= loop_dram_to_bram0;

        sel_bram_in_reg <= (others => '0');
        we_in_reg <= (others => '0');
        
        i_reg <= (others => '0');
        j_reg <= (others => '0');
        k_reg <= (others => '0');

        dram_row_ptr0_reg <= (others => '0');
        dram_row_ptr1_reg <= "00000000001";
        
        dram_to_bram_finished_reg <= '0'; 
        
    else
        state_dram_to_bram_r <= state_dram_to_bram_n;

        width_2_reg <= width_2_next;
        width_4_reg <= width_4_next;
        height_reg <= height_next;
        bram_height_reg <= bram_height_next;
        cycle_num_limit_reg <= cycle_num_limit_next;
        dram_in_addr_reg <= dram_in_addr_next;

        sel_bram_in_reg <= sel_bram_in_next;
        we_in_reg <= we_in_next;

        i_reg <= i_next;
        j_reg <= j_next;
        j_limit_reg <= j_limit_next;
        k_reg <= k_next;

        dram_row_ptr0_reg <= dram_row_ptr0_next; 
        dram_row_ptr1_reg <= dram_row_ptr1_next; 
        
        dram_to_bram_finished_reg <= dram_to_bram_finished_next;

    end if;
end if;
end process;

process(state_dram_to_bram_r,  width_2_reg, width_4_reg, height_reg, bram_height_reg,
    cycle_num_limit_reg, dram_in_addr_reg, sel_bram_in_reg,
    we_in_reg, i_reg, j_reg, j_limit_reg, k_reg, dram_row_ptr0_reg, dram_row_ptr1_reg, width_2,
    width_4, height, bram_height, cycle_num_limit, dram_in_addr, dram_row_ptr0, dram_row_ptr1,
    en_dram_to_bram, i_next, dram_row_ptr1_next, reinit, realloc_last_rows, dram_to_bram_finished_reg) 
begin

state_dram_to_bram_n <= state_dram_to_bram_r;

--reg bank
width_2_next <= width_2_reg;
width_4_next <= width_4_reg;
height_next <= height_reg;
bram_height_next <= bram_height_reg;
cycle_num_limit_next <= cycle_num_limit_reg;
dram_in_addr_next <= dram_in_addr_reg;


i_next <= i_reg;
j_next <= j_reg;
j_limit_next <= j_limit_reg;
k_next <= k_reg;

dram_to_bram_finished_next <= dram_to_bram_finished_reg;
--reallocate last four rows to the first four BRAM BLOCKS for next pipe:
if(realloc_last_rows = '1') then
    we_in_next <= X"000000FF";
else
    we_in_next <= we_in_reg;
end if;

sel_bram_in_next <= sel_bram_in_reg;


--if(reinit = '1') then
--    dram_row_ptr0_next <= dram_row_ptr0;
--    dram_row_ptr1_next <= dram_row_ptr1;
--else
--    dram_row_ptr0_next <= dram_row_ptr0_reg;
--    dram_row_ptr1_next <= dram_row_ptr1_reg;
--end if;

case state_dram_to_bram_r is

    when loop_dram_to_bram0 =>
    
        width_2_next <= width_2;
        width_4_next <= width_4;
        height_next <= height;
        bram_height_next <= bram_height;
        cycle_num_limit_next <= cycle_num_limit;
        dram_in_addr_next <= dram_in_addr;
        dram_to_bram_finished_next <= '0';   
                        
        
        if(en_dram_to_bram = '1') then 
            i_next <= (others => '0');
            
            if(reinit = '1') then
                sel_bram_in_next <= "0010";
                we_in_next <= X"00000F00";
                j_limit_next <= std_logic_vector(unsigned(bram_height_reg)-6);
            else
                sel_bram_in_next <= (others => '0');
                we_in_next <= X"0000000F";  
                j_limit_next <= std_logic_vector(unsigned(bram_height_reg)-2);
            end if;
                        
            j_next <= (others => '0');
            k_next <= (others => '0');
--            dram_addr0_s <= std_logic_vector(unsigned(dram_in_addr_reg) + resize(unsigned(dram_row_ptr0_reg)*unsigned(width_4_reg),32));
--            dram_addr1_s <= std_logic_vector(unsigned(dram_in_addr_reg) + resize(unsigned(dram_row_ptr1_reg)*unsigned(width_4_reg),32));
          
            
            state_dram_to_bram_n <= loop_dram_to_bram1;
        end if;
 
--    when loop_dram_to_bram_axi=>
--        if(en_axi = '1') then
--            k_next <= (others => '0');
                      
--            --we_in_next <= X"0000000F";
        
--            state_dram_to_bram_n <= loop_dram_to_bram1;
--        end if;

    when loop_dram_to_bram1 =>
        
        if(k_reg = std_logic_vector(resize((unsigned(width_2_reg)-2),10))) then 
            k_next <= (others => '0'); 
           
            if(dram_row_ptr1_reg = std_logic_vector(unsigned(height_reg)-1)) then 
                we_in_next <= (others => '0');
                dram_to_bram_finished_next <= '1';
                state_dram_to_bram_n <= loop_dram_to_bram0;
            else
--                dram_row_ptr0_next <= std_logic_vector(unsigned(dram_row_ptr0_reg) + 2);
                dram_row_ptr1_next <= std_logic_vector(unsigned(dram_row_ptr1_reg) + 2);
                if(sel_bram_in_reg = "0111") then
                    sel_bram_in_next <= (others => '0');
                    we_in_next <= X"0000000F";
                else
                    sel_bram_in_next <= std_logic_vector(unsigned(sel_bram_in_reg) + 1);
                    we_in_next <= std_logic_vector(shift_left(unsigned(we_in_reg),4));
                end if;
      
                if(j_reg = j_limit_reg) then
                    j_limit_next <= std_logic_vector(unsigned(bram_height_reg)-2);
                    i_next <= std_logic_vector(unsigned(i_reg) + 1);
                    --we_in_next <= X"0000000F";
                    if(i_next = cycle_num_limit_reg) then 
                        we_in_next <= (others => '0');
                        dram_to_bram_finished_next <= '1';
                        state_dram_to_bram_n <= loop_dram_to_bram0;
                    else
                        j_next <= (others => '0');
--                        dram_addr0_s <= std_logic_vector(unsigned(dram_in_addr_reg) + resize(unsigned(dram_row_ptr0_next)*unsigned(width_4_reg),32));
--                        dram_addr1_s <= std_logic_vector(unsigned(dram_in_addr_reg) + resize(unsigned(dram_row_ptr1_next)*unsigned(width_4_reg),32));
                    end if;
                else
                    j_next <= std_logic_vector(unsigned(j_reg) + 2);
--                    dram_addr0_s <= std_logic_vector(unsigned(dram_in_addr_reg) + resize(unsigned(dram_row_ptr0_next)*unsigned(width_4_reg), 32));
--                    dram_addr1_s <= std_logic_vector(unsigned(dram_in_addr_reg) + resize(unsigned(dram_row_ptr1_next)*unsigned(width_4_reg), 32));
                end if;
            end if;    
        else
            k_next <= std_logic_vector(unsigned(k_reg) + 2);  
        end if;
        
--        when end_dram_to_bram =>
--            dram_to_bram_finished_s <= '1';
--            state_dram_to_bram_n <= loop_dram_to_bram0;
            

end case;
end process;

we_in <= we_in_reg;
sel_bram_in <= sel_bram_in_reg;
i <= i_reg;
k <= k_reg;
dram_addr0 <= dram_addr0_s;
dram_addr1 <= dram_addr1_s;
dram_to_bram_finished <= dram_to_bram_finished_reg;
--burst_len_read_s <= std_logic_vector(resize((unsigned(width_4_reg) - 1),8));
burst_len_read <= std_logic_vector(resize((unsigned(width_4_reg) - 1),8));

end Behavioral;
