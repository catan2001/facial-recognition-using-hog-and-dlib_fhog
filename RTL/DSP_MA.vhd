----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/29/2024 11:21:30 PM
-- Design Name: 
-- Module Name: DSP_MA - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: this module does formula a*b+c using just one DSP block
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
use IEEE.NUMERIC_STD.ALL; 

entity DSP_MA is
    generic (WIDTH: natural := 16;
             WIDTH_CONST: natural := 3;
             WIDTH_INTERIM: natural := 18
             );
    Port (
          clk: in std_logic;
          a: in std_logic_vector(WIDTH - 1 downto 0);                 --16
          b: in std_logic_vector(WIDTH_CONST - 1 downto 0);           --3
          c: in std_logic_vector(WIDTH - 1 downto 0);                 --16
          res: out std_logic_vector(WIDTH_INTERIM - 1 downto 0));   
end DSP_MA;

architecture Behavioral of DSP_MA is
    attribute use_dsp : string;
    attribute use_dsp of Behavioral : architecture is "yes";

    signal mult_out : std_logic_vector(WIDTH_INTERIM downto 0);
    
    signal reg_mult : std_logic_vector(WIDTH_INTERIM downto 0);
    signal reg_c : std_logic_vector(WIDTH-1 downto 0);
    
    signal adder_out : std_logic_vector(WIDTH_INTERIM-1 downto 0);
    


begin
    
    process(a, b) is
    begin
        mult_out <= std_logic_vector(signed(a) * signed(b));
    end process;

    reg_middle: process(clk) is
    begin
        if(rising_edge(clk)) then
            reg_mult <= mult_out;
            reg_c <= c;
        end if;
    end process;

    process(reg_mult, reg_c) is
    begin
        adder_out <= std_logic_vector(resize(signed(reg_mult) + resize(signed(reg_c), (WIDTH_INTERIM+1)), WIDTH_INTERIM));
    end process;
    
    reg_out: process(clk) is
    begin
        if(rising_edge(clk)) then
            res <= adder_out;
        end if;
    end process;

end Behavioral;
