library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity mux_filter is
  generic(WIDTH:natural:=32);
  Port ( 
  sel_filter: in std_logic_vector(2 downto 0);
  bram_outA0: in std_logic_vector(31 downto 0);
  bram_outB0: in std_logic_vector(31 downto 0);
  bram_outA1: in std_logic_vector(31 downto 0);
  bram_outB1: in std_logic_vector(31 downto 0);
  bram_outA2: in std_logic_vector(31 downto 0);
  bram_outB2: in std_logic_vector(31 downto 0);
  bram_outA3: in std_logic_vector(31 downto 0);
  bram_outB3: in std_logic_vector(31 downto 0);
  bram_outA4: in std_logic_vector(31 downto 0);
  bram_outB4: in std_logic_vector(31 downto 0);
  bram_outA5: in std_logic_vector(31 downto 0);
  bram_outB5: in std_logic_vector(31 downto 0);
  bram_outA6: in std_logic_vector(31 downto 0);
  bram_outB6: in std_logic_vector(31 downto 0);
  bram_outA7: in std_logic_vector(31 downto 0);
  bram_outB7: in std_logic_vector(31 downto 0);
  bram_outA8: in std_logic_vector(31 downto 0);
  bram_outB8: in std_logic_vector(31 downto 0);
  bram_outA9: in std_logic_vector(31 downto 0);
  bram_outB9: in std_logic_vector(31 downto 0);
  bram_outA10: in std_logic_vector(31 downto 0);
  bram_outB10: in std_logic_vector(31 downto 0);
  bram_outA11: in std_logic_vector(31 downto 0);
  bram_outB11: in std_logic_vector(31 downto 0);
  bram_outA12: in std_logic_vector(31 downto 0);
  bram_outB12: in std_logic_vector(31 downto 0);
  bram_outA13: in std_logic_vector(31 downto 0);
  bram_outB13: in std_logic_vector(31 downto 0);
  bram_outA14: in std_logic_vector(31 downto 0);
  bram_outB14: in std_logic_vector(31 downto 0);
  bram_outA15: in std_logic_vector(31 downto 0);
  bram_outB15: in std_logic_vector(31 downto 0);
  filter_inA0: out std_logic_vector(31 downto 0);
  filter_inB0: out std_logic_vector(31 downto 0);
  filter_inA1: out std_logic_vector(31 downto 0);
  filter_inB1: out std_logic_vector(31 downto 0);
  filter_inA2: out std_logic_vector(31 downto 0);
  filter_inB2: out std_logic_vector(31 downto 0);
  filter_inA3: out std_logic_vector(31 downto 0);
  filter_inB3: out std_logic_vector(31 downto 0);
  filter_inA4: out std_logic_vector(31 downto 0);
  filter_inB4: out std_logic_vector(31 downto 0);
  filter_inA5: out std_logic_vector(31 downto 0);
  filter_inB5: out std_logic_vector(31 downto 0));
end mux_filter;

architecture Behavioral of mux_filter is
    component mux4_1 is
    generic(WIDTH:natural:=32);
    Port (x0: in std_logic_vector(WIDTH-1 downto 0);
          x1: in std_logic_vector(WIDTH-1 downto 0);
          x2: in std_logic_vector(WIDTH-1 downto 0);
          x3: in std_logic_vector(WIDTH-1 downto 0);
          sel: in std_logic_vector(2 downto 0);
          y: out std_logic_vector(WIDTH-1 downto 0));
    end component;
begin

mux0A:mux4_1
    generic map(WIDTH => WIDTH)
    Port map(x0 => bram_outA0,
          x1 => bram_outA4,
          x2 => bram_outA8,
          x3 => bram_outA12,
          sel => sel_filter,
          y => filter_inA0);
          
mux0B:mux4_1
    generic map(WIDTH => WIDTH)
    Port map(x0 => bram_outB0,
          x1 => bram_outB4,
          x2 => bram_outB8,
          x3 => bram_outB12,
          sel => sel_filTer,
          y => filter_inB0);
          
mux1A:mux4_1
    generic map(WIDTH => WIDTH)
    Port map(x0 => bram_outA1,
          x1 => bram_outA5,
          x2 => bram_outA9,
          x3 => bram_outA13,
          sel => sel_filter,
          y => filter_inA1);
          
mux1B:mux4_1
    generic map(WIDTH => WIDTH)
    Port map(x0 => bram_outB1,
          x1 => bram_outB5,
          x2 => bram_outB9,
          x3 => bram_outB13,
          sel => sel_filter,
          y => filter_inB1);
          
 mux2A:mux4_1
    generic map(WIDTH => WIDTH)
    Port map(x0 => bram_outA2,
          x1 => bram_outA6,
          x2 => bram_outA10,
          x3 => bram_outA14,
          sel => sel_filter,
          y => filter_inA2);
          
mux2B:mux4_1
    generic map(WIDTH => WIDTH)
    Port map(x0 => bram_outB2,
          x1 => bram_outB6,
          x2 => bram_outB10,
          x3 => bram_outB14,
          sel => sel_filter,
          y => filter_inB2);
          
 mux3A:mux4_1
    generic map(WIDTH => WIDTH)
    Port map(x0 => bram_outA3,
          x1 => bram_outA7,
          x2 => bram_outA11,
          x3 => bram_outA15,
          sel => sel_filter,
          y => filter_inA3);
 
 mux3B:mux4_1
    generic map(WIDTH => WIDTH)
    Port map(x0 => bram_outB3,
          x1 => bram_outB7,
          x2 => bram_outB11,
          x3 => bram_outB15,
          sel => sel_filter,
          y => filter_inB3);
          
 mux4A:mux4_1
    generic map(WIDTH => WIDTH)
    Port map(x0 => bram_outA4,
          x1 => bram_outA8,
          x2 => bram_outA12,
          x3 => bram_outA0,
          sel => sel_filter,
          y => filter_inA4);
          
 mux4B:mux4_1
    generic map(WIDTH => WIDTH)
    Port map(x0 => bram_outB4,
          x1 => bram_outB8,
          x2 => bram_outB12,
          x3 => bram_outB0,
          sel => sel_filter,
          y => filter_inB4);
          
 mux5A:mux4_1
    generic map(WIDTH => WIDTH)
    Port map(x0 => bram_outA5,
          x1 => bram_outA9,
          x2 => bram_outA13,
          x3 => bram_outA1,
          sel => sel_filter,
          y => filter_inA5);
          
 mux5B:mux4_1
    generic map(WIDTH => WIDTH)
    Port map(x0 => bram_outB5,
          x1 => bram_outB9,
          x2 => bram_outB13,
          x3 => bram_outB1,
          sel => sel_filter,
          y => filter_inB5);
end Behavioral;
