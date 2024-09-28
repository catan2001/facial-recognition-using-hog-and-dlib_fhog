library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity dram_to_bram is
  Port (     
    clk: in std_logic;
    reset: in std_logic;
    
    --axi stream signals
    axi_hp0_last_in: in std_logic;
    axi_hp0_valid_in: in std_logic;
    axi_hp0_ready_in: out std_logic;
    
    axi_hp1_last_in: in std_logic;
    axi_hp1_valid_in: in std_logic;
    axi_hp1_ready_in: out std_logic;
    
    --reg bank
    width_4: in std_logic_vector(7 downto 0);
    width_2: in std_logic_vector(8 downto 0);
    height: in std_logic_vector(10 downto 0);
    bram_height: in std_logic_vector(4 downto 0);
    cycle_num_limit: in std_logic_vector(5 downto 0); --2*bram_width/width
    
    --sig for FSM
    reinit: in std_logic;
    en_dram_to_bram: in std_logic;
    realloc_last_rows: in std_logic;
    last_rows_written: in std_logic;
    dram_to_bram_finished: out std_logic; 
    
    --out signals
    we_in: out std_logic_vector(31 downto 0);
    sel_bram_in: out std_logic_vector(3 downto 0);
    i: out std_logic_vector(5 downto 0);
    k: out std_logic_vector(8 downto 0));
end dram_to_bram;

architecture Behavioral of dram_to_bram is

--states dram to bram
type state_dram_to_bram_t is 
    (loop_dram_to_bram0, loop_dram_to_bram1, end_dram_to_bram);
signal state_dram_to_bram_r, state_dram_to_bram_n : state_dram_to_bram_t;

signal width_2_reg, width_2_next: std_logic_vector(8 downto 0);
signal width_4_reg, width_4_next: std_logic_vector(7 downto 0);
signal height_reg, height_next: std_logic_vector(10 downto 0);
signal bram_height_reg, bram_height_next: std_logic_vector(4 downto 0);
signal cycle_num_limit_reg, cycle_num_limit_next: std_logic_vector(5 downto 0);

signal axi_hp0_ready_in_next, axi_hp0_ready_in_reg: std_logic;
signal axi_hp1_ready_in_next, axi_hp1_ready_in_reg: std_logic;

signal i_reg, i_next: std_logic_vector(5 downto 0);
signal j_reg, j_next: std_logic_vector(4 downto 0);
signal j_limit_reg, j_limit_next: std_logic_vector(4 downto 0);
signal k_reg, k_next: std_logic_vector(8 downto 0);

signal we_in_reg, we_in_next: std_logic_vector(31 downto 0);
signal sel_bram_in_reg, sel_bram_in_next: std_logic_vector(3 downto 0); 

signal dram_to_bram_finished_reg, dram_to_bram_finished_next: std_logic;

begin

process(clk) 
begin

if(rising_edge(clk)) then
    if reset = '1' then
    
        state_dram_to_bram_r <= loop_dram_to_bram0;
        
        axi_hp0_ready_in_reg <= '0';
        axi_hp1_ready_in_reg <= '0';

        sel_bram_in_reg <= (others => '0');
        we_in_reg <= (others => '0');
        
        i_reg <= (others => '0');
        j_reg <= (others => '0');
        j_limit_reg <= "01110";
        k_reg <= (others => '0');

        dram_to_bram_finished_reg <= '0'; 
        
    else
        state_dram_to_bram_r <= state_dram_to_bram_n;
        
        axi_hp0_ready_in_reg <= axi_hp0_ready_in_next;
        axi_hp1_ready_in_reg <= axi_hp1_ready_in_next;

        width_2_reg <= width_2_next;
        width_4_reg <= width_4_next;
        height_reg <= height_next;
        bram_height_reg <= bram_height_next;
        cycle_num_limit_reg <= cycle_num_limit_next;

        sel_bram_in_reg <= sel_bram_in_next;
        we_in_reg <= we_in_next;

        i_reg <= i_next;
        j_reg <= j_next;
        j_limit_reg <= j_limit_next;
        k_reg <= k_next;
 
        dram_to_bram_finished_reg <= dram_to_bram_finished_next;

    end if;
end if;
end process;

process(last_rows_written, state_dram_to_bram_r,  width_2_reg, width_4_reg, height_reg, bram_height_reg,
        cycle_num_limit_reg, sel_bram_in_reg, we_in_reg, i_reg, j_reg, j_limit_reg, 
        k_reg, width_2, width_4, height, bram_height, cycle_num_limit,
        en_dram_to_bram, i_next, reinit, realloc_last_rows, dram_to_bram_finished_reg,
        axi_hp0_ready_in_reg, axi_hp0_valid_in, axi_hp0_last_in, axi_hp1_ready_in_reg, axi_hp1_valid_in, axi_hp1_last_in) 
begin

state_dram_to_bram_n <= state_dram_to_bram_r;

axi_hp0_ready_in_next <= axi_hp0_ready_in_reg;
axi_hp1_ready_in_next <= axi_hp1_ready_in_reg;

--reg bank
width_2_next <= width_2_reg;
width_4_next <= width_4_reg;
height_next <= height_reg;
bram_height_next <= bram_height_reg;
cycle_num_limit_next <= cycle_num_limit_reg;

i_next <= i_reg;
j_next <= j_reg;
j_limit_next <= j_limit_reg;
k_next <= k_reg;

sel_bram_in_next <= sel_bram_in_reg;

dram_to_bram_finished_next <= dram_to_bram_finished_reg;

--reallocate last four rows to the first four BRAM BLOCKS for next pipe:
if(realloc_last_rows = '1') then
    we_in_next <= X"000000FF";
elsif(last_rows_written = '1') then
     we_in_next <= X"00000000";
else
    we_in_next <= we_in_reg;
end if;

case state_dram_to_bram_r is

    when loop_dram_to_bram0 =>
    
        width_2_next <= width_2;
        width_4_next <= width_4;
        height_next <= height;
        bram_height_next <= bram_height;
        cycle_num_limit_next <= cycle_num_limit;
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
            axi_hp0_ready_in_next <= '1';
            axi_hp1_ready_in_next <= '1';
            
            state_dram_to_bram_n <= loop_dram_to_bram1;
        end if;

    when loop_dram_to_bram1 =>
        if(axi_hp0_valid_in = '1' and axi_hp1_valid_in = '1') then
        
            --if(k_reg = std_logic_vector((unsigned(width_2_reg)-4))) then
            --    if(i_reg = std_logic_vector(unsigned(cycle_num_limit_reg) - 1)) then
            --        if(j_reg = j_limit_reg) then
            --            axi_hp0_ready_in_next <= '0';
            --            axi_hp1_ready_in_next <= '0';
            --        end if;
            --    end if;
            --end if;
        
            if(k_reg = std_logic_vector((unsigned(width_2_reg)-2))) then 
                k_next <= (others => '0'); 
               
                --dovoljan jedan kako se i jedan i drugi podizu na 1 u istom momentu
                if(axi_hp0_last_in = '1') then
                    we_in_next <= (others => '0');
                    dram_to_bram_finished_next <= '1';
                    axi_hp0_ready_in_next <= '0';
                    axi_hp1_ready_in_next <= '0';
                    
                    state_dram_to_bram_n <= end_dram_to_bram;
                else
                    --dram_row_ptr1_next <= std_logic_vector(unsigned(dram_row_ptr1_reg) + 2);
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
                        if(i_next = cycle_num_limit_reg) then 
                            we_in_next <= (others => '0');
                            dram_to_bram_finished_next <= '1';
                            axi_hp0_ready_in_next <= '0';
                            axi_hp1_ready_in_next <= '0';
                            
                            state_dram_to_bram_n <= end_dram_to_bram;
                        else
                            j_next <= (others => '0');
                        end if;
                    else
                        j_next <= std_logic_vector(unsigned(j_reg) + 2);
                    end if;
                end if;    
            else
                k_next <= std_logic_vector(unsigned(k_reg) + 2);  
            end if;
        end if;
        
        when end_dram_to_bram =>
            state_dram_to_bram_n <= loop_dram_to_bram0;
            
end case;
end process;

axi_hp0_ready_in <= axi_hp0_ready_in_reg;
axi_hp1_ready_in <= axi_hp1_ready_in_reg;

i <= i_reg;
k <= k_reg;
we_in <= we_in_reg;
sel_bram_in <= sel_bram_in_reg;
dram_to_bram_finished <= dram_to_bram_finished_reg;

end Behavioral;
