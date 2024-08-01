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
        --two
        pix1_s <= X"0000", X"056F" after 100ns, X"0609" after 200ns, X"04D4" after 300ns, X"0609" after 400ns,
        X"039F" after 500ns, X"039F" after 600ns, X"056F" after 700ns, X"06A4" after 800ns;
        --two
        pix2_s <= X"0000";
        
        --negative two
        pix3_s <= X"0609", X"04D4" after 100ns, X"0609" after 200ns, X"039F" after 300ns, X"039F" after 400ns,
        X"056F" after 500ns, X"06A4" after 600ns, X"0609" after 700ns, X"0609" after 800ns;
        --negative two
        pix4_s <= X"0000", X"0873" after 100ns, X"0439" after 200ns, X"0609" after 300ns, X"0609" after 400ns,
        X"056F" after 500ns, X"0609" after 600ns, X"06A4" after 700ns, X"0609" after 800ns;
        
        --negative one
        pix5_s <= X"0000";
        --negative one
        pix6_s <= X"0439", X"0609" after 100ns, X"0609" after 200ns, X"056F" after 300ns, X"0609" after 400ns,
        X"06A4" after 500ns, X"0609" after 600ns, X"0609" after 700ns, X"056F" after 800ns;
        wait;
    end process;
    
    clk_gen: process
    begin
        clk_s <= '0', '1' after 50 ns;
        wait for 100 ns;
    end process;
    
end Behavioral;