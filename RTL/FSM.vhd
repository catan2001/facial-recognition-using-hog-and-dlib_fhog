library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity FSM is
  Port ( 
  clk: in std_logic;
  reset: in std_logic;
  
  dram_to_bram_finished: in std_logic;
  pipe_finished: in std_logic;
  bram_to_dram_finished: in std_logic;
  
  cycle_num_limit: in std_logic_vector(5 downto 0); --2*bram_width/width
  rows_num: in std_logic_vector(9 downto 0); --2*(bram_width/width)*bram_height
  effective_row_limit: in std_logic_vector(9 downto 0); --(height/PTS_PER_COL)*PTS_PER_COL+accumulated_loss 
  
  start: in std_logic;
  
  --dram2bram
  dram_row_ptr0: out std_logic_vector(10 downto 0);
  dram_row_ptr1: out std_logic_vector(10 downto 0); 
  realloc_last_rows: out std_logic;
  
  --ctrl log
  cycle_num: out std_logic_vector(5 downto 0);
  cycle_num0: out std_logic_vector(5 downto 0); 
  sel_bram_out_fsm: out std_logic_vector(2 downto 0); 
  sel_filter: in std_logic_vector(2 downto 0);
  
  ready: out std_logic;
  sel_bram_addr: out std_logic;
  we_out: out std_logic_vector(15 downto 0); 
  
  reinit: out std_logic;
  pipe_br2dr: out std_logic;
  reinit_pipe: out std_logic;
  en_dram_to_bram: out std_logic;
  en_pipe: out std_logic;
  en_bram_to_dram:out std_logic;
  
  --bram2dram
  row_cnt: out std_logic_vector(10 downto 0));
end FSM;

architecture Behavioral of FSM is

--states fsm
type state_t is 
    (idle, dr2br, ctrl_loop, pipe, br2dr, reint);
signal state_r, state_n : state_t;

signal sel_bram_addr_reg, sel_bram_addr_next: std_logic; 

signal cycle_num_limit_reg, cycle_num_limit_next: std_logic_vector(5 downto 0);
signal rows_num_reg, rows_num_next: std_logic_vector(9 downto 0); 
signal effective_row_limit_reg, effective_row_limit_next: std_logic_vector(9 downto 0);

signal x_reg, x_next: std_logic_vector(9 downto 0);
signal cycle_num_reg, cycle_num_next: std_logic_vector(5 downto 0); 
signal cnt_init_reg, cnt_init_next: std_logic_vector(5 downto 0);
signal dram_row_ptr0_s: std_logic_vector(10 downto 0);
signal dram_row_ptr1_s: std_logic_vector(10 downto 0);
signal we_out_reg, we_out_next: std_logic_vector(15 downto 0); 

signal ready_reg, ready_next: std_logic;
signal start_reg, start_next: std_logic;

signal reinit_s: std_logic := '0';
signal pipe_br2dr_s: std_logic:='0';
signal reinit_pipe_s: std_logic:='0';
signal en_dram_to_bram_s: std_logic := '0';
signal en_pipe_s: std_logic := '0';
signal en_bram_to_dram_s: std_logic := '0';

signal row_cnt_s: std_logic_vector(10 downto 0);
signal realloc_last_rows_s: std_logic := '0';

signal reinit_const: std_logic_vector(4 downto 0) := "01100";

begin

--init
process(clk) 
begin

if(rising_edge(clk)) then
    if reset = '1' then
        state_r <= idle;
        
        sel_bram_addr_reg <= '0';
        
        we_out_reg <= X"000F";
        
        ready_reg <= '0';

        x_reg <= (others => '0');
        cycle_num_reg <= (others => '0');
        cnt_init_reg <= "000001";

    else
        state_r <= state_n;
        
        rows_num_reg <= rows_num_next;
        cycle_num_limit_reg <= cycle_num_limit_next;
        effective_row_limit_reg <= effective_row_limit_next;
        ready_reg <= ready_next;
        --start_reg <= start_next;

        sel_bram_addr_reg <= sel_bram_addr_next;

        we_out_reg <= we_out_next;

        x_reg <= x_next;
        cycle_num_reg <= cycle_num_next;
        cnt_init_reg <= cnt_init_next; 

    end if;
end if;
end process;

process(state_r, rows_num_reg, cycle_num_limit_reg, effective_row_limit_reg,
        sel_bram_addr_reg, x_reg, cycle_num_reg, cnt_init_reg, we_out_reg, rows_num, cycle_num_limit, effective_row_limit,
        start, dram_to_bram_finished, bram_to_dram_finished, pipe_finished, x_next,
        ready_reg, sel_filter, reinit_const)
        --start_reg, start_next 
begin

state_n  <= state_r;    
    
rows_num_next <= rows_num_reg;
cycle_num_limit_next <= cycle_num_limit_reg;
effective_row_limit_next <= effective_row_limit_reg;
ready_next <= ready_reg;
--start_next <= start_reg;

sel_bram_addr_next <= sel_bram_addr_reg;

x_next <= x_reg;
cycle_num_next <= cycle_num_reg;
cnt_init_next <= cnt_init_reg; 
we_out_next <= we_out_reg;

case state_r is
    when idle =>
        rows_num_next <= rows_num;
        cycle_num_limit_next <= cycle_num_limit;
        effective_row_limit_next <= effective_row_limit;
        --start_next <= start;
        
        ready_next <= '1';
        x_next <= (others => '0');
        if(start = '1') then
            state_n <= dr2br;
        end if;
        
    when dr2br =>
        sel_bram_addr_next <= '0';
        dram_row_ptr0_s <= (others => '0');
        dram_row_ptr1_s <= "00000000001";
        en_dram_to_bram_s <= '1';
        
        if(dram_to_bram_finished = '1') then
            x_next <= (others => '0');
            en_dram_to_bram_s <= '0';
            state_n <= ctrl_loop;
        end if;
      
    when ctrl_loop =>
    
          if(cycle_num_reg = std_logic_vector(unsigned(cycle_num_limit_reg)-1) and x_reg = std_logic_vector(resize(unsigned(reinit_const), 10) + shift_left(resize(((unsigned(cycle_num_limit_reg) - 1)*unsigned(cnt_init_reg)), 10), 4))) then  
       
 
            dram_row_ptr0_s <= std_logic_vector(resize(unsigned(std_logic_vector((unsigned(rows_num_reg) - 4) * unsigned(cnt_init_reg))),11));
            dram_row_ptr1_s <= std_logic_vector(resize(unsigned(std_logic_vector((unsigned(rows_num_reg) - 4) * unsigned(cnt_init_reg) + 1)),11));
            cnt_init_next <= std_logic_vector(unsigned(cnt_init_reg) + 1);
            x_next <= std_logic_vector(unsigned(x_reg) + 4);
            cycle_num_next <= (others => '0');
            we_out_next <= (others => '0');
            row_cnt_s <= std_logic_vector(resize(((unsigned(rows_num) - 1)*(unsigned(cnt_init_reg)-1)), 11));
            
            reinit_s <= '1';
            en_dram_to_bram_s <= '1';
            en_bram_to_dram_s <= '1';
            
            sel_bram_addr_next <= '0';
            state_n <= reint;
        --end if;
        else
        
            if(cycle_num_reg = std_logic_vector(unsigned(cycle_num_limit_reg)-1)) then
              if(sel_filter = "001") then
                realloc_last_rows_s <= '1';
                
              elsif(sel_filter = "010") then
                realloc_last_rows_s <= '0';
              
              end if;
            end if;
        
            sel_bram_addr_next <= '1'; 
            cycle_num_next <= std_logic_vector(resize((resize(unsigned(x_reg(9 downto 4)), 12) - (unsigned(cnt_init_reg)-1)*(unsigned(cycle_num_limit_reg))), 6));
            --x_next <= std_logic_vector(unsigned(x_reg)+4);
            state_n <= pipe;
        end if;
        
        
     when reint =>
     
        reinit_s <= '0';
        we_out_next <= X"0000";
        --sel_bram_addr_next <= '0';
        
        if(cnt_init_reg = "000010") then
            reinit_const <= "11100"; 
        end if;
        
            if(dram_to_bram_finished = '1') then
                en_dram_to_bram_s <= '0';
            end if;
            
            if(bram_to_dram_finished = '1') then
                    en_bram_to_dram_s <= '0';
                    
                    sel_bram_addr_next <= '1'; 
                    reinit_pipe_s <= '1';
                    state_n <= pipe;
            end if;
        
     when pipe =>
     
        if(pipe_finished = '1') then
            reinit_pipe_s <= '0';
            en_pipe_s <= '0';
            x_next <= std_logic_vector(unsigned(x_reg)+4);
            --cycle_num_next <= std_logic_vector(resize((resize(unsigned(x_next(9 downto 4)), 12) - (unsigned(cnt_init_reg)-1)*(unsigned(cycle_num_limit_reg)-1)), 6));
            
            if(x_reg = std_logic_vector(unsigned(effective_row_limit_reg) - 4)) then
                we_out_next <= X"0000";
                pipe_br2dr_s <= '1';
                state_n <= br2dr;
            else
                state_n <= ctrl_loop;
            end if;     
        else
            en_pipe_s <= '1';
        end if;
        
     when br2dr => 
        sel_bram_addr_next <= '0';
        en_bram_to_dram_s <= '1';
        if(bram_to_dram_finished = '1') then
            pipe_br2dr_s <= '0';
            en_bram_to_dram_s <= '0';
            state_n <= idle;
        end if;
        
end case;
end process;

ready <= ready_reg;
sel_bram_addr <= sel_bram_addr_reg;
we_out <= we_out_reg;
cycle_num <= cycle_num_reg;
dram_row_ptr0 <= dram_row_ptr0_s;
dram_row_ptr1 <= dram_row_ptr1_s;
en_dram_to_bram <= en_dram_to_bram_s;
en_pipe <= en_pipe_s;
en_bram_to_dram <= en_bram_to_dram_s;
reinit <= reinit_s;
pipe_br2dr <= pipe_br2dr_s;
reinit_pipe <= reinit_pipe_s;
realloc_last_rows <= realloc_last_rows_s;


cycle_num0 <= cycle_num_reg when realloc_last_rows_s = '0' else
              (others => '0');

--bram2dram
row_cnt <= row_cnt_s;

end Behavioral;
