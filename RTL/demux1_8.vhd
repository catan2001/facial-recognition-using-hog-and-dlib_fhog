library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity demux1_8 is
    generic(WIDTH:natural:=32);
    Port (sel: in std_logic_vector(3 downto 0);
          x: in std_logic_vector(WIDTH-1 downto 0);
          y0: out std_logic_vector(WIDTH-1 downto 0);
          y1: out std_logic_vector(WIDTH-1 downto 0);
          y2: out std_logic_vector(WIDTH-1 downto 0);
          y3: out std_logic_vector(WIDTH-1 downto 0);
          y4: out std_logic_vector(WIDTH-1 downto 0);
          y5: out std_logic_vector(WIDTH-1 downto 0);
          y6: out std_logic_vector(WIDTH-1 downto 0);
          y7: out std_logic_vector(WIDTH-1 downto 0));
end demux1_8;

architecture Behavioral of demux1_8 is

begin

demux:process(sel, x)
begin
    case sel is 
    when "0000" =>
        y0 <= x;
    when "0001" =>
        y1 <= x;
    when "0010" =>
        y2 <= x;
    when "0011" =>
        y3 <= x;
    when "0100" =>
        y4 <= x;
    when "0101" =>
        y5 <= x;
    when "0110" =>
        y6 <= x;
    when others =>
        y7 <= x;
    end case;
end process;

end Behavioral;
