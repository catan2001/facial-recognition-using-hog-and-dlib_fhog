library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; 
use std.textio.all;

entity bram_tb is
--  Port ( );
end bram_tb;

architecture Behavioral of bram_tb is
constant WIDTH : natural := 32;
constant ADDR_WIDTH : natural := 10;

component Dual_Port_BRAM is
    generic(
         WIDTH      : natural := 32;
         BRAM_SIZE  : natural := 1024;
         ADDR_WIDTH : natural := 10
         );
    Port(
         clk_a : in std_logic;
         clk_b : in std_logic;
         --When inactive no data is written to the block RAM and the output bus remains in its previous state:
         en_a : in std_logic;
         en_b : in std_logic;
         --Byte-wide write enable. must be 0000 for read operation:
         we_a: in std_logic_vector(3 downto 0); --if it is defined as a bit it will map to 1 BRAM else 2 lut 1 BRAM
         we_b : in std_logic_vector(3 downto 0);
     
         ------------------- PORT A -------------------
         data_output_a : out std_logic_vector(WIDTH - 1 downto 0); --reading three pixels in a clk
         data_input_a : in std_logic_vector(WIDTH - 1 downto 0);
         addr_a : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
         
         
         ------------------- PORT B -------------------
         data_output_b : out std_logic_vector(WIDTH - 1 downto 0);
         data_input_b: in std_logic_vector(WIDTH - 1 downto 0); --writing four pixels in a clk
         addr_b : in std_logic_vector(ADDR_WIDTH - 1 downto 0)
         );
end component Dual_Port_BRAM;

signal clk_s: std_logic;
signal en_a_s, en_b_s : std_logic;
signal we_a_s, we_b_s : std_logic_vector(3 downto 0);
signal data_output_a_s, data_input_a_s, data_output_b_s, data_input_b_s : std_logic_vector(WIDTH - 1 downto 0);
signal addr_a_s, addr_b_s : std_logic_vector(ADDR_WIDTH - 1 downto 0);

begin

     clk_gen: process
     begin
         clk_s <= '0', '1' after 50 ns;
         wait for 100 ns;
     end process;

     bram: Dual_Port_BRAM
     generic map (
          WIDTH => WIDTH,
          BRAM_SIZE => 1024,
          ADDR_WIDTH => 10
     )
     port map(
          clk_a => clk_s,
          clk_b => clk_s,
          --When inactive no data is written to the block RAM and the output bus remains in its previous state:
          en_a => en_a_s,
          en_b => en_b_s,
          --Byte-wide write enable. must be 0000 for read operation:
          we_a => we_a_s, --if it is defined as a bit it will map to 1 BRAM else 2 lut 1 BRAM
          we_b => we_b_s,
      
          ------------------- PORT A -------------------
          data_output_a => data_output_a_s, --reading three pixels in a clk
          data_input_a => data_input_a_s,
          addr_a => addr_a_s,
          
          
          ------------------- PORT B -------------------
          data_output_b => data_output_b_s,
          data_input_b => data_input_b_s, --writing four pixels in a clk
          addr_b => addr_b_s
     );

     stim_gen1: process
     begin
          en_a_s <= '0', '1' after 200ns;
          en_b_s <= '0', '1' after 200ns;

          we_a_s <= "1111", "1111" after 100ns, "0000" after 600ns;
          we_b_s <= "1111", "1111" after 300ns, "0000" after 600ns;

          data_input_a_s <= x"00000000", x"FFFFFFFF" after 150ns;
          addr_a_s <= x"00" & "00"; 

          data_input_b_s <= x"00000001", x"F8F8F8F8" after 170ns;
          addr_b_s <= x"00" & "01"; 

          wait;
     end process;

end Behavioral;
