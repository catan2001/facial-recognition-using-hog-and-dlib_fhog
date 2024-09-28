library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux16_1 is
    generic(WIDTH:natural:=32);
    Port (x0: in std_logic_vector(WIDTH-1 downto 0);
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
end mux16_1;

architecture Behavioral of mux16_1 is

begin

mux: process(sel, x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15)
begin
    case sel is
    when "00000" =>
        y <= x0;
    when "00001" =>
        y <= x1;
    when "00010" =>
        y <= x2;
    when "00011" =>
        y <= x3;
    when "00100" =>
        y <= x4;
    when "00101" =>
        y <= x5;
    when "00110" =>
        y <= x6;
    when "00111" =>
        y <= x7;
    when "01000" =>
        y <= x8;
    when "01001" =>
        y <= x9;
    when "01010" =>
        y <= x10;
    when "01011" =>
        y <= x11;
    when "01100" =>
        y <= x12;
    when "01101" =>
        y <= x13; 
    when "01110" =>
        y <= x14;
    when others =>
        y <= x15;                       
    end case;
end process;

end Behavioral;
