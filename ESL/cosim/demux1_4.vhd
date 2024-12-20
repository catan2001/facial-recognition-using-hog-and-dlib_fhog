library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity demux1_4 is
    generic(WIDTH:natural:=32);
    Port (sel: in std_logic_vector(2 downto 0);
          x: in std_logic_vector(WIDTH-1 downto 0);
          y0: out std_logic_vector(WIDTH-1 downto 0);
          y1: out std_logic_vector(WIDTH-1 downto 0);
          y2: out std_logic_vector(WIDTH-1 downto 0);
          y3: out std_logic_vector(WIDTH-1 downto 0));
end demux1_4;

architecture Behavioral of demux1_4 is

begin

demux:process(sel, x)
begin
    case sel is 
    when "000" =>
        y0 <= x;
    when "001" =>
        y1 <= x;
    when "010" =>
        y2 <= x;
    when others =>
        y3 <= x;
    end case;
end process;


end Behavioral;
