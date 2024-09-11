library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity control_path_v2 is
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
    bram_height: in std_logic_vector(4 downto 0);
    dram_in_addr: in std_logic_vector(31 downto 0);
    dram_x_addr: in std_logic_vector(31 downto 0);
    dram_y_addr: in std_logic_vector(31 downto 0);
    cycle_num_limit: in std_logic_vector(5 downto 0); --2*bram_width/width
    cycle_num_out: in std_logic_vector(5 downto 0); --2*(bram_width/(width-1))
    rows_num: in std_logic_vector(9 downto 0); --2*(bram_width/width)*bram_height
    effective_row_limit: in std_logic_vector(9 downto 0); --(height/PTS_PER_COL)*PTS_PER_COL+accumulated_loss 

    ready: out std_logic; 
    
    --dram_to_bram
    sel_bram_in: out std_logic_vector(3 downto 0);
    bram_addr_A1: out std_logic_vector(9 downto 0); --bram block 0-3
    bram_addr_B1: out std_logic_vector(9 downto 0); --bram block 0-3
    bram_addr_A2: out std_logic_vector(9 downto 0); --bram block 4-11
    bram_addr_B2: out std_logic_vector(9 downto 0); --bram block 4-11
    bram_addr_A12: out std_logic_vector(9 downto 0); --bram block 12-15
    bram_addr_B12: out std_logic_vector(9 downto 0); --bram block 12-15
    dram_addr0: out std_logic_vector(31 downto 0);
    dram_addr1: out std_logic_vector(31 downto 0);
    we_in: out std_logic_vector(31 downto 0);
    we_out: out std_logic_vector(15 downto 0); 
    burst_len_read: out std_logic_vector(7 downto 0);
    burst_len_write: out std_logic_vector(7 downto 0); --bram to dram
    realloc_last_rows: out std_logic;
    
    --control logic
    sel_filter: out std_logic_vector(2 downto 0);
    sel_bram_out: out std_logic_vector(2 downto 0);
    bram_output_addr_A: out std_logic_vector(9 downto 0);
    bram_output_addr_B: out std_logic_vector(9 downto 0);
    
    --bram_to_dram
    sel_dram: out std_logic_vector(4 downto 0);
    dram_out_addr_x: out std_logic_vector(31 downto 0);
    dram_out_addr_y: out std_logic_vector(31 downto 0));
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
    bram_height: in std_logic_vector(4 downto 0);
    cycle_num_out: in std_logic_vector(5 downto 0); --2*(bram_width/(width-1))
    dram_x_addr: in std_logic_vector(31 downto 0);
    dram_y_addr: in std_logic_vector(31 downto 0);
    burst_len_write: out std_logic_vector(7 downto 0);
    --sig for FSM
    en_bram_to_dram: in std_logic;
    bram_to_dram_finished: out std_logic;
    reinit: in std_logic;
    row_cnt_fsm: in std_logic_vector(10 downto 0);
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
    --sig for FSM
    reinit: in std_logic;
    br2dr: in std_logic;
    reinit_pipe: in std_logic;
    en_pipe: in std_logic;
    cycle_num: in std_logic_vector(5 downto 0); 
    sel_bram_out_fsm: in std_logic_vector(2 downto 0); --pazi
    sel_filter_fsm: out std_logic_vector(2 downto 0);
    we_out_fsm: in std_logic_vector(15 downto 0);
    pipe_finished: out std_logic;
    realloc_last_rows: in std_logic;
    --out sig
    bram_output_xy_addr:out std_logic_vector(9 downto 0);
    row_position: out std_logic_vector(8 downto 0);
    row_position0: out std_logic_vector(8 downto 0);
    row_position12: out std_logic_vector(8 downto 0);
    sel_bram_out: out std_logic_vector(2 downto 0);
    sel_filter: out std_logic_vector(2 downto 0);
    we_out: out std_logic_vector(15 downto 0));
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
    bram_height: in std_logic_vector(4 downto 0);
    
    --sig for FSM
    reinit: in std_logic;
    en_dram_to_bram: in std_logic; 
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
end component;

component FSM is
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
  
  row_cnt: out std_logic_vector(10 downto 0));
end component;

component DSP_addr_A0
  Port ( 
    clk: in std_logic;
    width_2: in std_logic_vector(8 downto 0);
    a: in std_logic_vector(5 downto 0); --i
    b: in std_logic_vector(5 downto 0); --cycle_num 
    c: in std_logic_vector(9 downto 0); --k
    d: in std_logic_vector(8 downto 0); --row_position
    const1: in std_logic_vector(1 downto 0);
    const2: in std_logic_vector(1 downto 0);
    sel_addr: in std_logic;
    sel_filter: in std_logic_vector(2 downto 0);
    res: out std_logic_vector(9 downto 0) --bram addr
  );
end component;

component DSP_addr_B0
  Port ( 
    clk: in std_logic;
    width_2: in std_logic_vector(8 downto 0);
    a: in std_logic_vector(5 downto 0); --i
    b: in std_logic_vector(5 downto 0); --cycle_num 
    c: in std_logic_vector(9 downto 0); --k
    d: in std_logic_vector(8 downto 0); --row_position
    const1: in std_logic_vector(1 downto 0);
    const2: in std_logic_vector(1 downto 0);
    sel_addr: in std_logic;
    sel_filter: in std_logic_vector(2 downto 0);
    res: out std_logic_vector(9 downto 0) --bram addr
  );
end component;

component DSP_addr_AX
  Port ( 
    width_2: in std_logic_vector(8 downto 0);
    a: in std_logic_vector(5 downto 0); --i
    b: in std_logic_vector(5 downto 0); --cycle_num 
    c: in std_logic_vector(9 downto 0); --k
    d: in std_logic_vector(8 downto 0); --row_position
    sel_addr: in std_logic;
    res: out std_logic_vector(9 downto 0) --bram addr
    );

end component;

component DSP_addr_BX
  Port (     
    width_2: in std_logic_vector(8 downto 0);
    a: in std_logic_vector(5 downto 0); --i
    b: in std_logic_vector(5 downto 0); --cycle_num 
    c: in std_logic_vector(9 downto 0); --k
    d: in std_logic_vector(8 downto 0); --row_position
    const1: in std_logic_vector(1 downto 0);
    sel_addr: in std_logic;
    res: out std_logic_vector(9 downto 0) --bram addr
    );

end component;

--dram to bram
signal en_dram_to_bram_s: std_logic;
signal dram_row_ptr0_s: std_logic_vector(10 downto 0);
signal dram_row_ptr1_s: std_logic_vector(10 downto 0); 
signal dram_to_bram_finished_s: std_logic; 
signal i_s: std_logic_vector(5 downto 0);
signal k_s: std_logic_vector(9 downto 0);
signal realloc_last_rows_s: std_logic;

--control logic
signal bram_output_xy_addr_s: std_logic_vector(9 downto 0);
signal cycle_num_s: std_logic_vector(5 downto 0);
signal cycle_num0_s: std_logic_vector(5 downto 0); 
signal row_position_s: std_logic_vector(8 downto 0);
signal row_position0_s: std_logic_vector(8 downto 0);
signal row_position12_s: std_logic_vector(8 downto 0);
signal sel_bram_out_fsm_s: std_logic_vector(2 downto 0); 
signal sel_filter_fsm_s: std_logic_vector(2 downto 0);
signal sel_filter_s: std_logic_vector(2 downto 0);
signal sel_bram_out_s: std_logic_vector(2 downto 0); 
signal en_pipe_s: std_logic;
signal pipe_finished_s: std_logic;
signal we_out_pipe_s: std_logic_vector(15 downto 0); --we_out that will be led to the data_path

--bram to dram
signal en_bram_to_dram_s: std_logic;
signal bram_to_dram_finished_s: std_logic;
signal bram_addr_bram_to_dram_A_s: std_logic_vector(9 downto 0);

--FSM
signal we_out_fsm_s: std_logic_vector(15 downto 0); --we_out connecting FSM and control_logic
signal reinit_s: std_logic;
signal pipe_br2dr_s: std_logic;
signal reinit_pipe_s: std_logic;
signal sel_bram_addr_s: std_logic;
signal row_cnt_s: std_logic_vector(10 downto 0);

signal const1_s: std_logic_vector(1 downto 0):="01";
signal const2_s: std_logic_vector(1 downto 0):="00";

--reg
signal bram_output_xy_addr_reg1, bram_output_xy_addr_next1: std_logic_vector(9 downto 0);
signal bram_output_xy_addr_reg2, bram_output_xy_addr_next2: std_logic_vector(9 downto 0);
signal bram_output_xy_addr_reg3, bram_output_xy_addr_next3: std_logic_vector(9 downto 0);
signal bram_output_xy_addr_reg4, bram_output_xy_addr_next4: std_logic_vector(9 downto 0);

signal sel_bram_out_reg1, sel_bram_out_next1: std_logic_vector(2 downto 0);
signal sel_bram_out_reg2, sel_bram_out_next2: std_logic_vector(2 downto 0);
signal sel_bram_out_reg3, sel_bram_out_next3: std_logic_vector(2 downto 0);
signal sel_bram_out_reg4, sel_bram_out_next4: std_logic_vector(2 downto 0);

signal we_out_reg1, we_out_next1: std_logic_vector(15 downto 0);
signal we_out_reg2, we_out_next2: std_logic_vector(15 downto 0);
signal we_out_reg3, we_out_next3: std_logic_vector(15 downto 0);
signal we_out_reg4, we_out_next4: std_logic_vector(15 downto 0);
signal we_out_reg5, we_out_next5: std_logic_vector(15 downto 0);
signal we_out_reg6, we_out_next6: std_logic_vector(15 downto 0);

signal en_bram_to_dram_reg, en_bram_to_dram_next: std_logic; 

begin

dram_to_bram_l: dram_to_bram
port map(    
    clk => clk,
    reset => reset,
    en_axi => en_axi,
    
    --reg bank
    width_4 => width_4,
    width_2 => width_2,
    height => height,
    dram_in_addr => dram_in_addr,
    cycle_num_limit => cycle_num_limit,
    bram_height => bram_height,
    
    --sig for FSM
    reinit => reinit_s,
    en_dram_to_bram => en_dram_to_bram_s,
    dram_to_bram_finished => dram_to_bram_finished_s,
    realloc_last_rows => realloc_last_rows_s,
    
    --out signals
    we_in => we_in,
    sel_bram_in => sel_bram_in,
    i => i_s,
    k => k_s,
    dram_addr0 => dram_addr0,
    dram_addr1 => dram_addr1,
    burst_len_read => burst_len_read);
    
control_logic_l: control_logic
port map(    
    clk => clk,
    reset => reset,
    --reg bank
    width_2 => width_2,
    --sig for FSM
    reinit => reinit_s,
    br2dr => pipe_br2dr_s,
    en_pipe => en_pipe_s,
    reinit_pipe => reinit_pipe_s,
    cycle_num => cycle_num_s,
    sel_bram_out_fsm => sel_bram_out_fsm_s,
    sel_filter_fsm => sel_filter_fsm_s,
    we_out_fsm => we_out_fsm_s,
    pipe_finished => pipe_finished_s,
    realloc_last_rows => realloc_last_rows_s,
    --out sig
    bram_output_xy_addr => bram_output_xy_addr_s,
    row_position => row_position_s,
    row_position0 => row_position0_s,
    row_position12 => row_position12_s,
    sel_bram_out => sel_bram_out_s,
    sel_filter => sel_filter_s,
    we_out => we_out_pipe_s);

bram_to_dram_l: bram_to_dram
port map(
    clk => clk,
    reset => reset,
    --reg bank
    width => width,
    width_4 => width_4,
    width_2 => width_2,
    height => height,
    bram_height => bram_height,
    cycle_num_out => cycle_num_out,
    dram_x_addr => dram_x_addr, 
    dram_y_addr => dram_y_addr,
    burst_len_write => burst_len_write,
    --sig for FSM
    en_bram_to_dram => en_bram_to_dram_s,
    bram_to_dram_finished => bram_to_dram_finished_s,
    reinit => reinit_s,
    row_cnt_fsm => row_cnt_s,
    --bram_to_dram
    bram_addr_bram_to_dram_A => bram_addr_bram_to_dram_A_s,
    bram_addr_bram_to_dram_B => bram_output_addr_B,
    sel_dram => sel_dram,
    dram_out_addr_x => dram_out_addr_x,
    dram_out_addr_y => dram_out_addr_y);

FSM_l: FSM
Port map( 
  clk => clk,
  reset => reset,
  
  dram_to_bram_finished => dram_to_bram_finished_s,
  pipe_finished => pipe_finished_s,
  bram_to_dram_finished => bram_to_dram_finished_s,
  
  cycle_num_limit => cycle_num_limit,
  rows_num => rows_num,
  effective_row_limit => effective_row_limit,
  
  start => start,
  
  --dram2bram
  dram_row_ptr0 => dram_row_ptr0_s,
  dram_row_ptr1 => dram_row_ptr1_s,
  realloc_last_rows => realloc_last_rows_s,
  
  --ctrl log
  cycle_num => cycle_num_s,
  cycle_num0 => cycle_num0_s,
  sel_bram_out_fsm => sel_bram_out_fsm_s,
  sel_filter => sel_filter_fsm_s,
  
  ready => ready,
  sel_bram_addr => sel_bram_addr_s,
  we_out => we_out_fsm_s,
  
  reinit => reinit_s,
  pipe_br2dr => pipe_br2dr_s,
  reinit_pipe => reinit_pipe_s,
  en_dram_to_bram => en_dram_to_bram_s,
  en_pipe => en_pipe_s,
  en_bram_to_dram => en_bram_to_dram_s,
  
  --bram2dram
  row_cnt => row_cnt_s);
  
DSP_addr_A0_l: DSP_addr_A0
Port map( 
    clk => clk,
    width_2 => width_2,
    a => i_s,
    b => cycle_num0_s, 
    c => k_s,
    d => row_position0_s,
    const1 => const1_s,
    const2 => const2_s,
    sel_addr => sel_bram_addr_s,
    sel_filter => sel_filter_s,
    res => bram_addr_A1);
    
DSP_addr_B0_l: DSP_addr_B0
Port map(
    clk => clk,
    width_2 => width_2,
    a => i_s,
    b => cycle_num0_s, 
    c => k_s,
    d => row_position0_s,
    const1 => const1_s,
    const2 => const2_s,
    sel_addr => sel_bram_addr_s,
    sel_filter => sel_filter_s,
    res => bram_addr_B1);
    
DSP_addr_AX_l: DSP_addr_AX
Port map( 
    width_2 => width_2,
    a => i_s,
    b => cycle_num_s, 
    c => k_s,
    d => row_position_s,
    sel_addr => sel_bram_addr_s,
    res => bram_addr_A2);
    
DSP_addr_BX_l: DSP_addr_BX
Port map(    
    width_2 => width_2,
    a => i_s,
    b => cycle_num_s, 
    c => k_s,
    d => row_position_s,
    const1 => const1_s,
    sel_addr => sel_bram_addr_s,
    res => bram_addr_B2); 
    
DSP_addr_A12_l: DSP_addr_AX
Port map( 
    width_2 => width_2,
    a => i_s,
    b => cycle_num_s, 
    c => k_s,
    d => row_position12_s,
    sel_addr => sel_bram_addr_s,
    res => bram_addr_A12);
    
DSP_addr_B12_l: DSP_addr_BX
Port map(    
    width_2 => width_2,
    a => i_s,
    b => cycle_num_s, 
    c => k_s,
    d => row_position12_s,
    const1 => const1_s,
    sel_addr => sel_bram_addr_s,
    res => bram_addr_B12); 
    
--mux control_logic and bram_to_dram
process(sel_bram_addr_s, bram_output_xy_addr_reg4, bram_addr_bram_to_dram_A_s)
begin


    if(sel_bram_addr_s = '0') then
        bram_output_addr_A <= bram_addr_bram_to_dram_A_s;
    else
        bram_output_addr_A <= bram_output_xy_addr_reg3;
    end if;

end process;

process(clk)
begin
if(falling_edge(clk)) then
    if(reset = '1') then
        sel_bram_out_reg1 <= (others => '0');
        sel_bram_out_reg2 <= (others => '0');
        sel_bram_out_reg3 <= (others => '0');
        sel_bram_out_reg4 <= (others => '0');

        bram_output_xy_addr_reg1 <= (others => '0');
        bram_output_xy_addr_reg2 <= (others => '0');
        bram_output_xy_addr_reg3 <= (others => '0');
        bram_output_xy_addr_reg4 <= (others => '0');
        
        we_out_reg1 <= (others => '0');
        we_out_reg2 <= (others => '0');
        we_out_reg3 <= (others => '0');
        we_out_reg4 <= (others => '0');
        we_out_reg5 <= (others => '0');
        we_out_reg6 <= (others => '0');
        
        en_bram_to_dram_reg <= '0';
      
    else
        bram_output_xy_addr_reg1 <= bram_output_xy_addr_next1;
        bram_output_xy_addr_reg2 <= bram_output_xy_addr_next2;
        bram_output_xy_addr_reg3 <= bram_output_xy_addr_next3;
        bram_output_xy_addr_reg4 <= bram_output_xy_addr_next4;
     
        
        sel_bram_out_reg1 <= sel_bram_out_next1;
        sel_bram_out_reg2 <= sel_bram_out_next2;
        sel_bram_out_reg3 <= sel_bram_out_next3;
        sel_bram_out_reg4 <= sel_bram_out_next4;
        
        we_out_reg1 <= we_out_next1;
        we_out_reg2 <= we_out_next2;
        we_out_reg3 <= we_out_next3;
        we_out_reg4 <= we_out_next4;
        we_out_reg5 <= we_out_next5;
        we_out_reg6 <= we_out_next6;
        
        en_bram_to_dram_reg <= en_bram_to_dram_next;
        
    end if;
end if;
end process;

process(sel_bram_out_reg1, sel_bram_out_reg2, sel_bram_out_reg3, sel_bram_out_reg4, sel_bram_out_s, bram_output_xy_addr_reg1, 
        bram_output_xy_addr_reg2, bram_output_xy_addr_reg3, bram_output_xy_addr_reg4, bram_output_xy_addr_s, we_out_pipe_s,
        we_out_reg1, we_out_reg2, we_out_reg3)
begin

sel_bram_out_next1 <= sel_bram_out_s;
sel_bram_out_next2 <= sel_bram_out_reg1;
sel_bram_out_next3 <= sel_bram_out_reg2;
sel_bram_out_next4 <= sel_bram_out_reg3;


bram_output_xy_addr_next1 <= bram_output_xy_addr_s;
bram_output_xy_addr_next2 <= bram_output_xy_addr_reg1;
bram_output_xy_addr_next3 <= bram_output_xy_addr_reg2;
bram_output_xy_addr_next4 <= bram_output_xy_addr_reg3;

we_out_next1 <= we_out_pipe_s;
we_out_next2 <= we_out_reg1;
we_out_next3 <= we_out_reg2;
we_out_next4 <= we_out_reg3;
we_out_next5 <= we_out_reg4;
we_out_next6 <= we_out_reg5;

en_bram_to_dram_next <= en_bram_to_dram_s;


end process;

sel_bram_out <= sel_bram_out_reg4;
sel_filter <= sel_filter_s;
--we_out <= we_out_reg4;
--we_out <= (others => '0') when en_bram_to_dram_reg = '1' else we_out_reg6;
we_out <= (others => '0') when en_bram_to_dram_reg = '1' else we_out_reg4;
realloc_last_rows <= realloc_last_rows_s;

end Behavioral;
