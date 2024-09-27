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
        y1 <= (others => '0');
        y2 <= (others => '0');
        y3 <= (others => '0');
    when "001" =>
        y1 <= x;
        y0 <= (others => '0');
        y2 <= (others => '0');
        y3 <= (others => '0');
    when "010" =>
        y2 <= x;
        y1 <= (others => '0');
        y0 <= (others => '0');
        y3 <= (others => '0');
    when others =>
        y3 <= x;
        y1 <= (others => '0');
        y2 <= (others => '0');
        y0 <= (others => '0');
    end case;
end process;


end Behavioral;
