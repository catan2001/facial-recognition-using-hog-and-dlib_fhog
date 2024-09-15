library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity bram is
  Port ( 
    clk: in std_logic;
    en: in std_logic;
    we_a0: in std_logic_vector(3 downto 0);
    we_a1: in std_logic_vector(3 downto 0);
    we_a2: in std_logic_vector(3 downto 0);
    we_a3: in std_logic_vector(3 downto 0);
    we_a4: in std_logic_vector(3 downto 0);
    we_a5: in std_logic_vector(3 downto 0);
    we_a6: in std_logic_vector(3 downto 0);
    we_a7: in std_logic_vector(3 downto 0);
    we_a8: in std_logic_vector(3 downto 0);
    we_a9: in std_logic_vector(3 downto 0);
    we_a10: in std_logic_vector(3 downto 0);
    we_a11: in std_logic_vector(3 downto 0);
    we_a12: in std_logic_vector(3 downto 0);
    we_a13: in std_logic_vector(3 downto 0);
    we_a14: in std_logic_vector(3 downto 0);
    we_a15: in std_logic_vector(3 downto 0);
    we_b0: in std_logic_vector(3 downto 0);
    we_b1: in std_logic_vector(3 downto 0);
    we_b2: in std_logic_vector(3 downto 0);
    we_b3: in std_logic_vector(3 downto 0);
    we_b4: in std_logic_vector(3 downto 0);
    we_b5: in std_logic_vector(3 downto 0);
    we_b6: in std_logic_vector(3 downto 0);
    we_b7: in std_logic_vector(3 downto 0);
    we_b8: in std_logic_vector(3 downto 0);
    we_b9: in std_logic_vector(3 downto 0);
    we_b10: in std_logic_vector(3 downto 0);
    we_b11: in std_logic_vector(3 downto 0);
    we_b12: in std_logic_vector(3 downto 0);
    we_b13: in std_logic_vector(3 downto 0);
    we_b14: in std_logic_vector(3 downto 0);
    we_b15: in std_logic_vector(3 downto 0);
    --INPUT SIGNALS
    bram_inA0: in std_logic_vector(31 downto 0);
    bram_inB0: in std_logic_vector(31 downto 0);
    bram_inA1: in std_logic_vector(31 downto 0);
    bram_inB1: in std_logic_vector(31 downto 0);
    bram_inA2: in std_logic_vector(31 downto 0);
    bram_inB2: in std_logic_vector(31 downto 0);
    bram_inA3: in std_logic_vector(31 downto 0);
    bram_inB3: in std_logic_vector(31 downto 0);
    bram_inA4: in std_logic_vector(31 downto 0);
    bram_inB4: in std_logic_vector(31 downto 0);
    bram_inA5: in std_logic_vector(31 downto 0);
    bram_inB5: in std_logic_vector(31 downto 0);
    bram_inA6: in std_logic_vector(31 downto 0);
    bram_inB6: in std_logic_vector(31 downto 0);
    bram_inA7: in std_logic_vector(31 downto 0);
    bram_inB7: in std_logic_vector(31 downto 0);
    bram_inA8: in std_logic_vector(31 downto 0);
    bram_inB8: in std_logic_vector(31 downto 0);
    bram_inA9: in std_logic_vector(31 downto 0);
    bram_inB9: in std_logic_vector(31 downto 0);
    bram_inA10: in std_logic_vector(31 downto 0);
    bram_inB10: in std_logic_vector(31 downto 0);
    bram_inA11: in std_logic_vector(31 downto 0);
    bram_inB11: in std_logic_vector(31 downto 0);
    bram_inA12: in std_logic_vector(31 downto 0);
    bram_inB12: in std_logic_vector(31 downto 0);
    bram_inA13: in std_logic_vector(31 downto 0);
    bram_inB13: in std_logic_vector(31 downto 0);
    bram_inA14: in std_logic_vector(31 downto 0);
    bram_inB14: in std_logic_vector(31 downto 0);
    bram_inA15: in std_logic_vector(31 downto 0);
    bram_inB15: in std_logic_vector(31 downto 0);
    --INPUT ADDR
    bram_addrA0: in std_logic_vector(9 downto 0);
    bram_addrA1: in std_logic_vector(9 downto 0);
    bram_addrA2: in std_logic_vector(9 downto 0);
    bram_addrA3: in std_logic_vector(9 downto 0);
    bram_addrA4: in std_logic_vector(9 downto 0);
    bram_addrA5: in std_logic_vector(9 downto 0);
    bram_addrA6: in std_logic_vector(9 downto 0);
    bram_addrA7: in std_logic_vector(9 downto 0);
    bram_addrA8: in std_logic_vector(9 downto 0);
    bram_addrA9: in std_logic_vector(9 downto 0);
    bram_addrA10: in std_logic_vector(9 downto 0);
    bram_addrA11: in std_logic_vector(9 downto 0);
    bram_addrA12: in std_logic_vector(9 downto 0);
    bram_addrA13: in std_logic_vector(9 downto 0);
    bram_addrA14: in std_logic_vector(9 downto 0);
    bram_addrA15: in std_logic_vector(9 downto 0);
    bram_addrB0: in std_logic_vector(9 downto 0);
    bram_addrB1: in std_logic_vector(9 downto 0);
    bram_addrB2: in std_logic_vector(9 downto 0);
    bram_addrB3: in std_logic_vector(9 downto 0);
    bram_addrB4: in std_logic_vector(9 downto 0);
    bram_addrB5: in std_logic_vector(9 downto 0);
    bram_addrB6: in std_logic_vector(9 downto 0);
    bram_addrB7: in std_logic_vector(9 downto 0);
    bram_addrB8: in std_logic_vector(9 downto 0);
    bram_addrB9: in std_logic_vector(9 downto 0);
    bram_addrB10: in std_logic_vector(9 downto 0);
    bram_addrB11: in std_logic_vector(9 downto 0);
    bram_addrB12: in std_logic_vector(9 downto 0);
    bram_addrB13: in std_logic_vector(9 downto 0);
    bram_addrB14: in std_logic_vector(9 downto 0);
    bram_addrB15: in std_logic_vector(9 downto 0);
    --OUTPUT SIGNALS
    bram_outA0: out std_logic_vector(31 downto 0);
    bram_outB0: out std_logic_vector(31 downto 0);
    bram_outA1: out std_logic_vector(31 downto 0);
    bram_outB1: out std_logic_vector(31 downto 0);
    bram_outA2: out std_logic_vector(31 downto 0);
    bram_outB2: out std_logic_vector(31 downto 0);
    bram_outA3: out std_logic_vector(31 downto 0);
    bram_outB3: out std_logic_vector(31 downto 0);
    bram_outA4: out std_logic_vector(31 downto 0);
    bram_outB4: out std_logic_vector(31 downto 0);
    bram_outA5: out std_logic_vector(31 downto 0);
    bram_outB5: out std_logic_vector(31 downto 0);
    bram_outA6: out std_logic_vector(31 downto 0);
    bram_outB6: out std_logic_vector(31 downto 0);
    bram_outA7: out std_logic_vector(31 downto 0);
    bram_outB7: out std_logic_vector(31 downto 0);
    bram_outA8: out std_logic_vector(31 downto 0);
    bram_outB8: out std_logic_vector(31 downto 0);
    bram_outA9: out std_logic_vector(31 downto 0);
    bram_outB9: out std_logic_vector(31 downto 0);
    bram_outA10: out std_logic_vector(31 downto 0);
    bram_outB10: out std_logic_vector(31 downto 0);
    bram_outA11: out std_logic_vector(31 downto 0);
    bram_outB11: out std_logic_vector(31 downto 0);
    bram_outA12: out std_logic_vector(31 downto 0);
    bram_outB12: out std_logic_vector(31 downto 0);
    bram_outA13: out std_logic_vector(31 downto 0);
    bram_outB13: out std_logic_vector(31 downto 0);
    bram_outA14: out std_logic_vector(31 downto 0);
    bram_outB14: out std_logic_vector(31 downto 0);
    bram_outA15: out std_logic_vector(31 downto 0);
    bram_outB15: out std_logic_vector(31 downto 0));
end bram;

architecture Behavioral of bram is

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
    end component;

begin

 --bram_block    
bram_block0_in: Dual_Port_BRAM
    Port map(
         clk_a => clk,
         clk_b => clk,
         en_a => en,
         en_b => en,
         we_a => we_a0,
         we_b => we_b0,
         data_output_a => bram_outA0, 
         data_input_a => bram_inA0,
         addr_a => bram_addrA0,
         data_output_b => bram_outB0,
         data_input_b => bram_inB0, 
         addr_b => bram_addrB0);
         
 bram_block1_in: Dual_Port_BRAM
    Port map(
         clk_a => clk,
         clk_b => clk,
         en_a => en,
         en_b => en,
         we_a => we_a1,
         we_b => we_b1,
         data_output_a => bram_outA1, 
         data_input_a => bram_inA1,
         addr_a => bram_addrA1,
         data_output_b => bram_outB1,
         data_input_b => bram_inB1, 
         addr_b => bram_addrB1);

 bram_block2_in: Dual_Port_BRAM
    Port map(
         clk_a => clk,
         clk_b => clk,
         en_a => en,
         en_b => en,
         we_a => we_a2,
         we_b => we_b2,
         data_output_a => bram_outA2, 
         data_input_a => bram_inA2,
         addr_a => bram_addrA2,
         data_output_b => bram_outB2,
         data_input_b => bram_inB2, 
         addr_b => bram_addrB2);
         
 bram_block3_in: Dual_Port_BRAM
    Port map(
         clk_a => clk,
         clk_b => clk,
         en_a => en,
         en_b => en,
         we_a => we_a3,
         we_b => we_b3,
         data_output_a => bram_outA3, 
         data_input_a => bram_inA3,
         addr_a => bram_addrA3,
         data_output_b => bram_outB3,
         data_input_b => bram_inB3, 
         addr_b => bram_addrB3);
         
 bram_block4_in: Dual_Port_BRAM
    Port map(
         clk_a => clk,
         clk_b => clk,
         en_a => en,
         en_b => en,
         we_a => we_a4,
         we_b => we_b4,
         data_output_a => bram_outA4, 
         data_input_a => bram_inA4,
         addr_a => bram_addrA4,
         data_output_b => bram_outB4,
         data_input_b => bram_inB4, 
         addr_b => bram_addrB4);
         
 bram_block5_in: Dual_Port_BRAM
    Port map(
         clk_a => clk,
         clk_b => clk,
         en_a => en,
         en_b => en,
         we_a => we_a5,
         we_b => we_b5,
         data_output_a => bram_outA5, 
         data_input_a => bram_inA5,
         addr_a => bram_addrA5,
         data_output_b => bram_outB5,
         data_input_b => bram_inB5, 
         addr_b => bram_addrB5);
         
  bram_block6_in: Dual_Port_BRAM
    Port map(
         clk_a => clk,
         clk_b => clk,
         en_a => en,
         en_b => en,
         we_a => we_a6,
         we_b => we_b6,
         data_output_a => bram_outA6, 
         data_input_a => bram_inA6,
         addr_a => bram_addrA6,
         data_output_b => bram_outB6,
         data_input_b => bram_inB6, 
         addr_b => bram_addrB6); 
         
  bram_block7_in: Dual_Port_BRAM
    Port map(
         clk_a => clk,
         clk_b => clk,
         en_a => en,
         en_b => en,
         we_a => we_a7,
         we_b => we_b7,
         data_output_a => bram_outA7, 
         data_input_a => bram_inA7,
         addr_a => bram_addrA7,
         data_output_b => bram_outB7,
         data_input_b => bram_inB7, 
         addr_b => bram_addrB7);  
         
   bram_block8_in: Dual_Port_BRAM
    Port map(
         clk_a => clk,
         clk_b => clk,
         en_a => en,
         en_b => en,
         we_a => we_a8,
         we_b => we_b8,
         data_output_a => bram_outA8, 
         data_input_a => bram_inA8,
         addr_a => bram_addrA8,
         data_output_b => bram_outB8,
         data_input_b => bram_inB8, 
         addr_b => bram_addrB8);   
        
    bram_block9_in: Dual_Port_BRAM
    Port map(
         clk_a => clk,
         clk_b => clk,
         en_a => en,
         en_b => en,
         we_a => we_a9,
         we_b => we_b9,
         data_output_a => bram_outA9, 
         data_input_a => bram_inA9,
         addr_a => bram_addrA9,
         data_output_b => bram_outB9,
         data_input_b => bram_inB9, 
         addr_b => bram_addrB9);
         
   bram_block10_in: Dual_Port_BRAM
    Port map(
         clk_a => clk,
         clk_b => clk,
         en_a => en,
         en_b => en,
         we_a => we_a10,
         we_b => we_b10,
         data_output_a => bram_outA10, 
         data_input_a => bram_inA10,
         addr_a => bram_addrA10,
         data_output_b => bram_outB10,
         data_input_b => bram_inB10, 
         addr_b => bram_addrB10);  
         
   bram_block11_in: Dual_Port_BRAM
    Port map(
         clk_a => clk,
         clk_b => clk,
         en_a => en,
         en_b => en,
         we_a => we_a11,
         we_b => we_b11,
         data_output_a => bram_outA11, 
         data_input_a => bram_inA11,
         addr_a => bram_addrA11,
         data_output_b => bram_outB11,
         data_input_b => bram_inB11, 
         addr_b => bram_addrB11);   
         
   bram_block12_in: Dual_Port_BRAM
    Port map(
         clk_a => clk,
         clk_b => clk,
         en_a => en,
         en_b => en,
         we_a => we_a12,
         we_b => we_b12,
         data_output_a => bram_outA12, 
         data_input_a => bram_inA12,
         addr_a => bram_addrA12,
         data_output_b => bram_outB12,
         data_input_b => bram_inB12, 
         addr_b => bram_addrB12);
         
   bram_block13_in: Dual_Port_BRAM
    Port map(
         clk_a => clk,
         clk_b => clk,
         en_a => en,
         en_b => en,
         we_a => we_a13,
         we_b => we_b13,
         data_output_a => bram_outA13, 
         data_input_a => bram_inA13,
         addr_a => bram_addrA13,
         data_output_b => bram_outB13,
         data_input_b => bram_inB13, 
         addr_b => bram_addrB13);
         
   bram_block14_in: Dual_Port_BRAM
    Port map(
         clk_a => clk,
         clk_b => clk,
         en_a => en,
         en_b => en,
         we_a => we_a14,
         we_b => we_b14,
         data_output_a => bram_outA14, 
         data_input_a => bram_inA14,
         addr_a => bram_addrA14,
         data_output_b => bram_outB14,
         data_input_b => bram_inB14, 
         addr_b => bram_addrB14);
         
   bram_block15_in: Dual_Port_BRAM
    Port map(
         clk_a => clk,
         clk_b => clk,
         en_a => en,
         en_b => en,
         we_a => we_a15,
         we_b => we_b15,
         data_output_a => bram_outA15, 
         data_input_a => bram_inA15,
         addr_a => bram_addrA15,
         data_output_b => bram_outB15,
         data_input_b => bram_inB15, 
         addr_b => bram_addrB15);
end Behavioral;
