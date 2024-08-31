library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; 

entity DSP_addr_B0 is
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
end DSP_addr_B0;

architecture Behavioral of DSP_addr_B0 is
attribute use_dsp : string;
attribute use_dsp of Behavioral : architecture is "yes";

signal mux_out1: std_logic_vector(5 downto 0);
signal mux_out2: std_logic_vector(9 downto 0);
signal mux_const: std_logic_vector(1 downto 0);

signal mult_out, reg_mult: std_logic_vector(14 downto 0);
signal adder_out: std_logic_vector(14 downto 0);
signal increment1: std_logic_vector(5 downto 0);
signal increment2, reg_increment2: std_logic_vector(9 downto 0);

begin
process(sel_addr, a, b)
begin
    if(sel_addr = '0') then
        mux_out1 <= a;
    else
        mux_out1 <= b;
    end if;
end process;

process(sel_filter, const1, const2)
begin
    if(sel_filter = "011") then
        mux_const <= const1;
    else
        mux_const <= const2; 
    end if;  
end process;

process(sel_addr, c, d) 
begin
    if(sel_addr = '0') then
        mux_out2 <= c;
    else
        mux_out2 <= std_logic_vector(resize(unsigned(d),10));
    end if;
end process;

increment1 <= std_logic_vector(unsigned(mux_out1)+resize(unsigned(mux_const),6));
increment2 <= std_logic_vector(unsigned(mux_out2) + resize(unsigned(const1),10));

mult_out <= std_logic_vector(unsigned(width_2) * unsigned(increment1));
adder_out <= std_logic_vector(unsigned(mult_out) + resize(unsigned(increment2),15));

res <= std_logic_vector(resize(unsigned(adder_out),10));


end Behavioral;
