library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux2_1 is
    generic(WIDTH:natural:=32);
    Port (x0: in std_logic_vector(WIDTH-1 downto 0);
          x1: in std_logic_vector(WIDTH-1 downto 0);
          sel: in std_logic;
          y: out std_logic_vector(WIDTH-1 downto 0));
end mux2_1;

architecture Behavioral of mux2_1 is

begin

mux: process(sel, x0, x1)
begin
    case sel is
    when '0' =>
        y <= x0;
    when others =>
        y <= x1;
    end case;
end process;
end Behavioral;
