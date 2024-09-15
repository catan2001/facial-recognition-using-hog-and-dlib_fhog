library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity demux_out is
  generic(WIDTH:natural:=32);
  Port ( 
        sel: in std_logic_vector(2 downto 0);
        filter_out1: in std_logic_vector(31 downto 0);
        filter_out2: in std_logic_vector(31 downto 0);
        filter_out3: in std_logic_vector(31 downto 0);
        filter_out4: in std_logic_vector(31 downto 0);
        bram_in0: out std_logic_vector(31 downto 0);
        bram_in1: out std_logic_vector(31 downto 0);
        bram_in2: out std_logic_vector(31 downto 0);
        bram_in3: out std_logic_vector(31 downto 0);
        bram_in4: out std_logic_vector(31 downto 0);
        bram_in5: out std_logic_vector(31 downto 0);
        bram_in6: out std_logic_vector(31 downto 0);
        bram_in7: out std_logic_vector(31 downto 0);
        bram_in8: out std_logic_vector(31 downto 0);
        bram_in9: out std_logic_vector(31 downto 0);
        bram_in10: out std_logic_vector(31 downto 0);
        bram_in11: out std_logic_vector(31 downto 0);
        bram_in12: out std_logic_vector(31 downto 0);
        bram_in13: out std_logic_vector(31 downto 0);
        bram_in14: out std_logic_vector(31 downto 0);
        bram_in15: out std_logic_vector(31 downto 0));
end demux_out;

architecture Behavioral of demux_out is

component demux1_4 is
generic(WIDTH:natural:=32);
Port (sel: in std_logic_vector(2 downto 0);
      x: in std_logic_vector(WIDTH-1 downto 0);
      y0: out std_logic_vector(WIDTH-1 downto 0);
      y1: out std_logic_vector(WIDTH-1 downto 0);
      y2: out std_logic_vector(WIDTH-1 downto 0);
      y3: out std_logic_vector(WIDTH-1 downto 0));
end component;

begin

demux1: demux1_4
generic map(WIDTH => WIDTH)
Port map(sel => sel,
         x => filter_out1,
         y0 => bram_in0,
         y1 => bram_in4,
         y2 => bram_in8,
         y3 => bram_in12);
         
demux2: demux1_4
generic map(WIDTH => WIDTH)
Port map(sel => sel,
         x => filter_out2,
         y0 => bram_in1,
         y1 => bram_in5,
         y2 => bram_in9,
         y3 => bram_in13);
         
demux3: demux1_4
generic map(WIDTH => WIDTH)
Port map(sel => sel,
         x => filter_out3,
         y0 => bram_in2,
         y1 => bram_in6,
         y2 => bram_in10,
         y3 => bram_in14);
         
demux4: demux1_4
generic map(WIDTH => WIDTH)
Port map(sel => sel,
         x => filter_out4,
         y0 => bram_in3,
         y1 => bram_in7,
         y2 => bram_in11,
         y3 => bram_in15);

end Behavioral;
