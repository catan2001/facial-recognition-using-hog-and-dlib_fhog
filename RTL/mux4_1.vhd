----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/11/2024 02:48:52 PM
-- Design Name: 
-- Module Name: mux4_1 - Behavioral
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

entity mux4_1 is
    generic(WIDTH:positive:=32);
    Port (x0: in std_logic_vector(WIDTH-1 downto 0);
          x1: in std_logic_vector(WIDTH-1 downto 0);
          x2: in std_logic_vector(WIDTH-1 downto 0);
          x3: in std_logic_vector(WIDTH-1 downto 0);
          sel: in std_logic_vector(1 downto 0);
          y: out std_logic_vector(WIDTH-1 downto 0));
end mux4_1;

architecture Behavioral of mux4_1 is

begin

mux: process(sel, x0, x1, x2, x3)
begin
    case sel is
    when "00" =>
        y <= x0;
    when "01" =>
        y <= x1;
    when "10" =>
        y <= x2;
    when others =>
        y <= x3;
    end case;
end process;
end Behavioral;
