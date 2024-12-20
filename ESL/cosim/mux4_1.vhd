library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux4_1 is
    generic(WIDTH:natural:=32);
    Port (x0: in std_logic_vector(WIDTH-1 downto 0);
          x1: in std_logic_vector(WIDTH-1 downto 0);
          x2: in std_logic_vector(WIDTH-1 downto 0);
          x3: in std_logic_vector(WIDTH-1 downto 0);
          sel: in std_logic_vector(2 downto 0);
          y: out std_logic_vector(WIDTH-1 downto 0));
end mux4_1;

architecture Behavioral of mux4_1 is

begin

mux: process(sel, x0, x1, x2, x3)
begin
    case sel is
    when "000" =>
        y <= x0;
    when "001" =>
        y <= x1;
    when "010" =>
        y <= x2;
    when others =>
        y <= x3;
    end case;
end process;
end Behavioral;
