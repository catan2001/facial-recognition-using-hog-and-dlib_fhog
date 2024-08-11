----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/11/2024 02:58:06 PM
-- Design Name: 
-- Module Name: mux16_1 - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

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
          sel: in std_logic_vector(3 downto 0);
          y: out std_logic_vector(WIDTH-1 downto 0));
end mux16_1;

architecture Behavioral of mux16_1 is

begin

mux: process(sel, x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15)
begin
    case sel is
    when "0000" =>
        y <= x0;
    when "0001" =>
        y <= x1;
    when "0010" =>
        y <= x2;
    when "0011" =>
        y <= x3;
    when "0100" =>
        y <= x4;
    when "0101" =>
        y <= x5;
    when "0110" =>
        y <= x6;
    when "0111" =>
        y <= x7;
    when "1000" =>
        y <= x8;
    when "1001" =>
        y <= x9;
    when "1010" =>
        y <= x10;
    when "1011" =>
        y <= x11;
    when "1100" =>
        y <= x12;
    when "1101" =>
        y <= x13; 
    when "1110" =>
        y <= x14;
    when others =>
        y <= x15;                       
    end case;
end process;

end Behavioral;
