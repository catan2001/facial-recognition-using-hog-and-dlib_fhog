----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/11/2024 03:07:20 PM
-- Design Name: 
-- Module Name: demux1_8 - Behavioral
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

entity demux1_8 is
    generic(WIDTH:natural:=32);
    Port (sel: in std_logic_vector(2 downto 0);
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
    when "000" =>
        y0 <= x;
    when "001" =>
        y1 <= x;
    when "010" =>
        y2 <= x;
    when "011" =>
        y3 <= x;
    when "100" =>
        y4 <= x;
    when "101" =>
        y5 <= x;
    when "110" =>
        y6 <= x;
    when others =>
        y7 <= x;
    end case;
end process;

end Behavioral;
