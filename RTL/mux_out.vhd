library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux_out is
  generic(WIDTH:natural:=32);
  Port ( 
    sel: in std_logic_vector(4 downto 0);
    bram_block0A: in std_logic_vector(31 downto 0);
    bram_block0B: in std_logic_vector(31 downto 0);
    bram_block1A: in std_logic_vector(31 downto 0);
    bram_block1B: in std_logic_vector(31 downto 0);
    bram_block2A: in std_logic_vector(31 downto 0);
    bram_block2B: in std_logic_vector(31 downto 0);
    bram_block3A: in std_logic_vector(31 downto 0);
    bram_block3B: in std_logic_vector(31 downto 0);
    bram_block4A: in std_logic_vector(31 downto 0);
    bram_block4B: in std_logic_vector(31 downto 0);
    bram_block5A: in std_logic_vector(31 downto 0);
    bram_block5B: in std_logic_vector(31 downto 0);
    bram_block6A: in std_logic_vector(31 downto 0);
    bram_block6B: in std_logic_vector(31 downto 0);
    bram_block7A: in std_logic_vector(31 downto 0);
    bram_block7B: in std_logic_vector(31 downto 0);
    bram_block8A: in std_logic_vector(31 downto 0);
    bram_block8B: in std_logic_vector(31 downto 0);
    bram_block9A: in std_logic_vector(31 downto 0);
    bram_block9B: in std_logic_vector(31 downto 0);
    bram_block10A: in std_logic_vector(31 downto 0);
    bram_block10B: in std_logic_vector(31 downto 0);
    bram_block11A: in std_logic_vector(31 downto 0);
    bram_block11B: in std_logic_vector(31 downto 0);
    bram_block12A: in std_logic_vector(31 downto 0);
    bram_block12B: in std_logic_vector(31 downto 0);
    bram_block13A: in std_logic_vector(31 downto 0);
    bram_block13B: in std_logic_vector(31 downto 0);
    bram_block14A: in std_logic_vector(31 downto 0);
    bram_block14B: in std_logic_vector(31 downto 0);
    bram_block15A: in std_logic_vector(31 downto 0);
    bram_block15B: in std_logic_vector(31 downto 0);
    data_out1: out std_logic_vector(31 downto 0);
    data_out2: out std_logic_vector(31 downto 0));
end mux_out;

architecture Behavioral of mux_out is
    component mux16_1 is
        generic(WIDTH:natural:=32);
        Port (
          x0: in std_logic_vector(WIDTH-1 downto 0);
          x1: in std_logic_vector(WIDTH-1 downto 0);
          x2: in std_logic_vector(WIDTH-1 downto 0);
          x3: in std_logic_vector(WIDTH-1 downto 0);
          x4: in std_logic_vector(WIDTH-1 downto 0);
          x5: in std_logic_vector(WIDTH-1 downto 0);
          x6: in std_logic_vector(WIDTH-1 downto 0);
          x7: in std_logic_vector(WIDTH-1 downto 0);
          x8: in std_logic_vector(WIDTH-1 downto 0);
          x9: in std_logic_vector(WIDTH-1 downto 0);
          x10: in std_logic_vector(WIDTH-1 downto 0);
          x11: in std_logic_vector(WIDTH-1 downto 0);
          x12: in std_logic_vector(WIDTH-1 downto 0);
          x13: in std_logic_vector(WIDTH-1 downto 0);
          x14: in std_logic_vector(WIDTH-1 downto 0);
          x15: in std_logic_vector(WIDTH-1 downto 0);
          sel: in std_logic_vector(4 downto 0);
          y: out std_logic_vector(WIDTH-1 downto 0));
    end component;
begin

mux1: mux16_1
        generic map(WIDTH => WIDTH)
        Port map(
          x0 => bram_block0A,
          x1 => bram_block1A,
          x2 => bram_block2A,
          x3 => bram_block3A,
          x4 => bram_block4A,
          x5 => bram_block5A,
          x6 => bram_block6A,
          x7 => bram_block7A,
          x8 => bram_block8A,
          x9 => bram_block9A,
          x10 => bram_block10A,
          x11 => bram_block11A,
          x12 => bram_block12A,
          x13 => bram_block13A,
          x14 => bram_block14A,
          x15 => bram_block15A,
          sel => sel,
          y => data_out1);

mux2: mux16_1
        generic map(WIDTH => WIDTH)
        Port map(
          x0 => bram_block0B,
          x1 => bram_block1B,
          x2 => bram_block2B,
          x3 => bram_block3B,
          x4 => bram_block4B,
          x5 => bram_block5B,
          x6 => bram_block6B,
          x7 => bram_block7B,
          x8 => bram_block8B,
          x9 => bram_block9B,
          x10 => bram_block10B,
          x11 => bram_block11B,
          x12 => bram_block12B,
          x13 => bram_block13B,
          x14 => bram_block14B,
          x15 => bram_block15B,
          sel => sel,
          y => data_out2);

end Behavioral;
