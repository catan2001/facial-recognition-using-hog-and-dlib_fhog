library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity FSM is
  Port ( 
  dram_to_bram_finished: in std_logic;
  pipe_finished: in std_logic;
  bram_to_dram_finished: in std_logic;
  
  cycle_num_limit: in std_logic_vector(5 downto 0); --2*bram_width/width
  rows_num: in std_logic_vector(9 downto 0); --2*(bram_width/width)*bram_height
  effective_row_limit: in std_logic_vector(9 downto 0); --(height/PTS_PER_ROW)/accumulated_loss
  
  start: in std_logic;
  
  --dram2bram
  dram_row_ptr0: out std_logic_vector(10 downto 0);
  dram_row_ptr1: out std_logic_vector(10 downto 0); 
  
  --ctrl log
  cycle_num: out std_logic_vector(5 downto 0); 
  sel_bram_out_fsm: out std_logic_vector(2 downto 0); 
  sel_filter_fsm: out std_logic_vector(2 downto 0);
  
  ready: out std_logic;
  sel_bram_addr: out std_logic;
  we_out: out std_logic_vector(15 downto 0); 
  
  en_dram_to_bram: out std_logic;
  en_pipe: out std_logic;
  en_bram_to_dram:out std_logic);
end FSM;

architecture Behavioral of FSM is

--states fsm
type state_t is 
    (idle, dr2br, ctrl_loop, pipe, br2dr, reint);
signal state_r, state_n : state_t;

signal sel_bram_addr_reg, sel_bram_addr_next: std_logic;
signal sel_bram_out_fsm_reg, sel_bram_out_fsm_next: std_logic_vector(2 downto 0); 
signal sel_filter_fsm_reg, sel_filter_fsm_next: std_logic_vector(2 downto 0);

signal cycle_num_limit_reg, cycle_num_limit_next: std_logic_vector(5 downto 0);
signal rows_num_reg, rows_num_next: std_logic_vector(9 downto 0); 
signal effective_row_limit_reg, effective_row_limit_next: std_logic_vector(9 downto 0);

signal x_reg, x_next: std_logic_vector(9 downto 0);
signal cycle_num_reg, cycle_num_next: std_logic_vector(5 downto 0); 
signal cnt_init_reg, cnt_init_next: std_logic_vector(5 downto 0);
signal dram_row_ptr0_reg, dram_row_ptr0_next: std_logic_vector(10 downto 0);
signal dram_row_ptr1_reg, dram_row_ptr1_next: std_logic_vector(10 downto 0);
signal we_out_reg, we_out_next: std_logic_vector(15 downto 0); 

signal en_dram_to_bram_s: std_logic;
signal en_pipe_s: std_logic;
signal en_bram_to_dram_s: std_logic;

begin

process(state_r) --lista
--dodati signale
begin
case state_r is
    when idle =>
        ready <= '1';
        x_next <= (others => '0');
        if(start = '1') then
            state_n <= dr2br;
        end if;
        
    when dr2br =>
        sel_bram_addr_next <= '0';
        en_dram_to_bram_s <= '1';
        
        if(dram_to_bram_finished = '1') then
            x_next <= (others => '0');
            en_dram_to_bram_s <= '0';
            state_n <= ctrl_loop;
        end if;
      
    when ctrl_loop =>
        sel_bram_addr_next <= '1'; 
        cycle_num_next <= x_reg(9 downto 4);
        if(cycle_num_next = std_logic_vector(unsigned(cycle_num_limit_reg)-1) and x_reg = std_logic_vector(12*unsigned(cycle_num_next))) then  
            dram_row_ptr0_next <= std_logic_vector((unsigned(rows_num) - 4) * unsigned(cnt_init_reg));
            dram_row_ptr1_next <= std_logic_vector((unsigned(rows_num) - 4) * unsigned(cnt_init_reg) + 1);
            cnt_init_next <= std_logic_vector(unsigned(cnt_init_reg) + 1);
            x_next <= std_logic_vector(unsigned(x_reg) + 4);
            cycle_num_next <= (others => '0');
            sel_filter_fsm_next <= (others => '0');
            sel_bram_out_fsm_next <= (others => '0');
            state_n <= reint;
        else
            state_n <= pipe;
        end if;
        
     when reint =>
        we_out_next <= (others => '0');
        en_dram_to_bram_s <= '1';
        en_bram_to_dram_s <= '1';
        if(dram_to_bram_finished = '1' and bram_to_dram_finished = '1') then
            en_dram_to_bram_s <= '0';
            en_bram_to_dram_s <= '0';
            state_n <= pipe;
        end if;       
        
     when pipe =>
        we_out_next <= X"000F";
        x_next <= std_logic_vector(unsigned(x_reg)+4);
        en_pipe_s <= '1';
        if(pipe_finished = '1' and x_next = effective_row_limit_reg) then
            en_pipe_s <= '1';
            state_n <= br2dr;
        else
            en_pipe_s <= '0';
            state_n <= ctrl_loop;
        end if;
     when br2dr =>
        sel_bram_addr_next <= '0';
        en_bram_to_dram_s <= '1';
        if(bram_to_dram_finished = '1') then
            en_bram_to_dram_s <= '0';
            state_n <= idle;
        end if;
        
end case;
end process;

sel_bram_addr <= sel_bram_addr_reg;
en_dram_to_bram <= en_dram_to_bram_s;
en_pipe <= en_pipe_s;
en_bram_to_dram <= en_bram_to_dram_s;

end Behavioral;
