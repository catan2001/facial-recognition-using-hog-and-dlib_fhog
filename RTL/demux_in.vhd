library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity demux_in is
 generic (WIDTH: natural := 32);
  Port ( 
        sel_bram_in: in std_logic_vector(3 downto 0);
        data_in1: in std_logic_vector(31 downto 0);
        data_in2: in std_logic_vector(31 downto 0);
        data_in3: in std_logic_vector(31 downto 0);
        data_in4: in std_logic_vector(31 downto 0);
        bram_blockA0: out std_logic_vector(31 downto 0);
        bram_blockB0: out std_logic_vector(31 downto 0);
        bram_blockA1: out std_logic_vector(31 downto 0);
        bram_blockB1: out std_logic_vector(31 downto 0);
        bram_blockA2: out std_logic_vector(31 downto 0);
        bram_blockB2: out std_logic_vector(31 downto 0);
        bram_blockA3: out std_logic_vector(31 downto 0);
        bram_blockB3: out std_logic_vector(31 downto 0);
        bram_blockA4: out std_logic_vector(31 downto 0);
        bram_blockB4: out std_logic_vector(31 downto 0);
        bram_blockA5: out std_logic_vector(31 downto 0);
        bram_blockB5: out std_logic_vector(31 downto 0);
        bram_blockA6: out std_logic_vector(31 downto 0);
        bram_blockB6: out std_logic_vector(31 downto 0);
        bram_blockA7: out std_logic_vector(31 downto 0);
        bram_blockB7: out std_logic_vector(31 downto 0);
        bram_blockA8: out std_logic_vector(31 downto 0);
        bram_blockB8: out std_logic_vector(31 downto 0);
        bram_blockA9: out std_logic_vector(31 downto 0);
        bram_blockB9: out std_logic_vector(31 downto 0);
        bram_blockA10: out std_logic_vector(31 downto 0);
        bram_blockB10: out std_logic_vector(31 downto 0);
        bram_blockA11: out std_logic_vector(31 downto 0);
        bram_blockB11: out std_logic_vector(31 downto 0);
        bram_blockA12: out std_logic_vector(31 downto 0);
        bram_blockB12: out std_logic_vector(31 downto 0);
        bram_blockA13: out std_logic_vector(31 downto 0);
        bram_blockB13: out std_logic_vector(31 downto 0);
        bram_blockA14: out std_logic_vector(31 downto 0);
        bram_blockB14: out std_logic_vector(31 downto 0);
        bram_blockA15: out std_logic_vector(31 downto 0);
        bram_blockB15: out std_logic_vector(31 downto 0));
end demux_in;

architecture Behavioral of demux_in is
    component demux1_8 is
        generic (
            WIDTH: natural := 32);
        port (
            ------------------- input signals -------------------
          sel: in std_logic_vector(3 downto 0);
          x: in std_logic_vector(WIDTH-1 downto 0);
            ------------------- output signals -------------------    
          y0: out std_logic_vector(WIDTH-1 downto 0);
          y1: out std_logic_vector(WIDTH-1 downto 0);
          y2: out std_logic_vector(WIDTH-1 downto 0);
          y3: out std_logic_vector(WIDTH-1 downto 0);
          y4: out std_logic_vector(WIDTH-1 downto 0);
          y5: out std_logic_vector(WIDTH-1 downto 0);
          y6: out std_logic_vector(WIDTH-1 downto 0);
          y7: out std_logic_vector(WIDTH-1 downto 0));   
    end component;
begin

demux1:demux1_8
    generic map(WIDTH => WIDTH)
    port map(
        ------------------- input signals -------------------
      sel => sel_bram_in,
      x => data_in1,
        ------------------- output signals -------------------    
      y0 => bram_blockA0,
      y1 => bram_blockA2,
      y2 => bram_blockA4,
      y3 => bram_blockA6,
      y4 => bram_blockA8,
      y5 => bram_blockA10,
      y6 => bram_blockA12,
      y7 => bram_blockA14);  
      
demux2:demux1_8
    generic map(WIDTH => WIDTH)
    port map(
        ------------------- input signals -------------------
      sel => sel_bram_in,
      x => data_in2,
        ------------------- output signals -------------------    
      y0 => bram_blockB0,
      y1 => bram_blockB2,
      y2 => bram_blockB4,
      y3 => bram_blockB6,
      y4 => bram_blockB8,
      y5 => bram_blockB10,
      y6 => bram_blockB12,
      y7 => bram_blockB14);  

demux3:demux1_8
    generic map(WIDTH => WIDTH)
    port map(
        ------------------- input signals -------------------
      sel => sel_bram_in,
      x => data_in3,
        ------------------- output signals -------------------    
      y0 => bram_blockA1,
      y1 => bram_blockA3,
      y2 => bram_blockA5,
      y3 => bram_blockA7,
      y4 => bram_blockA9,
      y5 => bram_blockA11,
      y6 => bram_blockA13,
      y7 => bram_blockA15);  


demux4:demux1_8
    generic map(WIDTH => WIDTH)
    port map(
        ------------------- input signals -------------------
      sel => sel_bram_in,
      x => data_in4,
        ------------------- output signals -------------------    
      y0 => bram_blockB1,
      y1 => bram_blockB3,
      y2 => bram_blockB5,
      y3 => bram_blockB7,
      y4 => bram_blockB9,
      y5 => bram_blockB11,
      y6 => bram_blockB13,
      y7 => bram_blockB15);  
end Behavioral;
