library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; 

entity tb is
end tb;

architecture Behavioral of tb is

component filter is
generic (
          WIDTH: natural := 16;
          WIDTH_CONST: natural := 3
             );
    Port (
          clk: in std_logic;
          pix_1: in std_logic_vector(WIDTH - 1 downto 0);
          pix_2: in std_logic_vector(WIDTH - 1 downto 0);
          pix_3: in std_logic_vector(WIDTH - 1 downto 0);
          pix_4: in std_logic_vector(WIDTH - 1 downto 0);
          pix_5: in std_logic_vector(WIDTH - 1 downto 0);
          pix_6: in std_logic_vector(WIDTH - 1 downto 0);
          res: out std_logic_vector(WIDTH - 1 downto 0));
end component filter;

signal clk_s: std_logic;
signal pix1_s, pix2_s, pix3_s, pix4_s, pix5_s, pix6_s: std_logic_vector(15 downto 0);
signal result : std_logic_vector(15 downto 0);

begin

    duv: filter
    generic map(
          WIDTH => 16,
          WIDTH_CONST => 3
          )
    port map(
          clk => clk_s,
          pix_1 => pix1_s,
          pix_2 => pix2_s,
          pix_3 => pix3_s,
          pix_4 => pix4_s,
          pix_5 => pix5_s,
          pix_6 => pix6_s,
          res => result
          );  
    

    stim_gen1: process
    begin
        --0 3 3 0 0 1.5 1.3 0.7 2.4
        pix1_s <= X"0873", ("01" & X"8000") after 100 ns, ("00" & X"0000") after 300 ns, ("00" & X"C000") after 500 ns, ("00" & X"A666") after 600 ns, ("00" & X"59AA") after 700 ns, ("01" & X"3333") after 800ns;
        --0 1 -2 -0.25 0.7
        pix2_s <= X"056F", ("00" & X"8000") after 200 ns, ("11" & X"0000") after 400 ns, ("11" & X"E000") after 600 ns, ("00" & X"59AA") after 800 ns;
        --0 -2 -1.25
        pix3_s <= X"0609", ("11" & X"0000") after 300 ns, ("11" & X"6000") after 600 ns;
        --0 3 3 0 0 1.5 1.3 0.7 2.4
        pix4_s <= ("00" & X"0000"), ("01" & X"8000") after 100 ns, ("00" & X"0000") after 300 ns, ("00" & X"C000") after 500 ns, ("00" & X"A666") after 600 ns, ("00" & X"59AA") after 700 ns, ("01" & X"3333") after 800ns;
        --0 1 -2 -0.25 0.7
        pix5_s <= ("00" & X"0000"), ("00" & X"8000") after 200 ns, ("11" & X"0000") after 400 ns, ("11" & X"E000") after 600 ns, ("00" & X"59AA") after 800 ns;
        --0 -2 -1.25
        pix6_s <= ("00" & X"0000"), ("11" & X"0000") after 300 ns, ("11" & X"6000") after 600 ns;
        wait;
    end process;
    
    clk_gen: process
    begin
        clk_s <= '0', '1' after 50 ns;
        wait for 100 ns;
    end process;
    
end Behavioral;