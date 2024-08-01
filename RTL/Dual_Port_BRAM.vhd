library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity Dual_Port_BRAM is
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
end Dual_Port_BRAM;


architecture Behavioral of Dual_Port_BRAM is

--attribute ram_style : string;
--attribute ram_style of Dual_Port_BRAM : signal is "block";

type ram_type is array(0 to BRAM_SIZE - 1) of std_logic_vector(WIDTH - 1 downto 0);
signal bram_block : ram_type  := (others => (others => '0'));

begin

PORT_A : process(clk_a)
begin
   
    if(rising_edge(clk_a)) then

        if(en_a = '1') then
            if(we_a /= "0000") then
            bram_block(to_integer(unsigned(addr_a))) <= data_input_a;
            else
            data_output_a <= bram_block(to_integer(unsigned(addr_a)));
            end if;
        end if;
    end if;

end process;

PORT_B : process(clk_b)
begin
   
    if(rising_edge(clk_b)) then

        if(en_b = '1') then
            if(we_b /= "0000") then
            bram_block(to_integer(unsigned(addr_b))) <= data_input_b;
            else
            data_output_b <= bram_block(to_integer(unsigned(addr_b)));
            end if;
        end if;
    end if;

end process;


end Behavioral;