library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; 
use std.textio.all;

entity core_tb is
    generic (
        WIDTH: natural := 16; --input is [-2,2] -> 3.15
        WIDTH_CONST: natural := 3
       );
end core_tb;

architecture Behavioral of core_tb is

component core_top is
generic (
        WIDTH: natural := 16
    );
    port (
        ------------------- control signals ------------------
        clk: in std_logic;

        ------------------- input signals --------------------
        pix_0: in std_logic_vector(WIDTH - 1 downto 0);
        pix_1: in std_logic_vector(WIDTH - 1 downto 0);
        pix_2: in std_logic_vector(WIDTH - 1 downto 0);
        pix_3: in std_logic_vector(WIDTH - 1 downto 0); 
        pix_4: in std_logic_vector(WIDTH - 1 downto 0);
        pix_5: in std_logic_vector(WIDTH - 1 downto 0);
        pix_6: in std_logic_vector(WIDTH - 1 downto 0);
        pix_7: in std_logic_vector(WIDTH - 1 downto 0);
        pix_8: in std_logic_vector(WIDTH - 1 downto 0);
        pix_9: in std_logic_vector(WIDTH - 1 downto 0);
        pix_10: in std_logic_vector(WIDTH - 1 downto 0);
        pix_11: in std_logic_vector(WIDTH - 1 downto 0); 
        pix_12: in std_logic_vector(WIDTH - 1 downto 0);
        pix_13: in std_logic_vector(WIDTH - 1 downto 0);
        pix_14: in std_logic_vector(WIDTH - 1 downto 0);
        pix_15: in std_logic_vector(WIDTH - 1 downto 0);
        pix_16: in std_logic_vector(WIDTH - 1 downto 0);
        pix_17: in std_logic_vector(WIDTH - 1 downto 0); 
        pix_18: in std_logic_vector(WIDTH - 1 downto 0);
        pix_19: in std_logic_vector(WIDTH - 1 downto 0);
        pix_20: in std_logic_vector(WIDTH - 1 downto 0);
        pix_21: in std_logic_vector(WIDTH - 1 downto 0);
        pix_22: in std_logic_vector(WIDTH - 1 downto 0);
        pix_23: in std_logic_vector(WIDTH - 1 downto 0); 
        pix_24: in std_logic_vector(WIDTH - 1 downto 0);
        pix_25: in std_logic_vector(WIDTH - 1 downto 0);
        pix_26: in std_logic_vector(WIDTH - 1 downto 0);
        pix_27: in std_logic_vector(WIDTH - 1 downto 0);
        pix_28: in std_logic_vector(WIDTH - 1 downto 0);
        pix_29: in std_logic_vector(WIDTH - 1 downto 0); 

        ------------------- output signals -------------------    
        res_x_0: out std_logic_vector(WIDTH - 1 downto 0);
        res_x_1: out std_logic_vector(WIDTH - 1 downto 0);
        res_x_2: out std_logic_vector(WIDTH - 1 downto 0);
        res_x_3: out std_logic_vector(WIDTH - 1 downto 0);
        res_x_4: out std_logic_vector(WIDTH - 1 downto 0);
        res_x_5: out std_logic_vector(WIDTH - 1 downto 0);
        res_x_6: out std_logic_vector(WIDTH - 1 downto 0);
        res_x_7: out std_logic_vector(WIDTH - 1 downto 0);

        res_y_0: out std_logic_vector(WIDTH - 1 downto 0);
        res_y_1: out std_logic_vector(WIDTH - 1 downto 0);
        res_y_2: out std_logic_vector(WIDTH - 1 downto 0);
        res_y_3: out std_logic_vector(WIDTH - 1 downto 0);
        res_y_4: out std_logic_vector(WIDTH - 1 downto 0);
        res_y_5: out std_logic_vector(WIDTH - 1 downto 0);
        res_y_6: out std_logic_vector(WIDTH - 1 downto 0);
        res_y_7: out std_logic_vector(WIDTH - 1 downto 0)
        );
end component core_top;

signal clk_s: std_logic;

type mem30 is array(0 to 29) of std_logic_vector(15 downto 0);
signal reg30: mem30;

type mem16 is array(0 to 15) of std_logic_vector(15 downto 0);
signal dram: mem16;

constant IMG_WIDTH : natural := 152;
constant IMG_HEIGHT : natural := 152;

type rows_type is array(0 to IMG_HEIGHT - 1) of std_logic_vector(WIDTH - 1 downto 0);
type bram_type is array(0 to IMG_WIDTH - 1) of rows_type;

impure function bram_init return bram_type is
    variable row_text : line;
    variable float_data : real;
    variable check : boolean;
    variable data : std_logic_vector(WIDTH - 1 downto 0);
    variable bram_rows : rows_type;
    variable bram : bram_type;
    file text_file : text open read_mode is "C:\Users\cata\Documents\rachel_files\gray_normalised.txt";
begin
    for row in 0 to IMG_HEIGHT - 1 loop
        readline(text_file, row_text);
        if row_text.all'length = 0 then -- skip empty lines if there are any
            next;
         end if;
        for column in 0 to IMG_WIDTH - 1 loop
            read(row_text, float_data, check);
            data := std_logic_vector(to_signed(integer(32768.0*float_data), 16));
            bram_rows(column) := data;
        end loop;
        bram(row) := bram_rows;
    end loop;
    return bram;
end function;

signal bram : bram_type := bram_init; 

begin

    duv: core_top
    generic map(
        WIDTH => 16
    )
    port map(
        clk => clk_s,
        pix_0 => reg30(0),
        pix_1 => reg30(1),
        pix_2 => reg30(2),
        pix_3 => reg30(3),
        pix_4 => reg30(4),
        pix_5 => reg30(5),
        pix_6 => reg30(6),
        pix_7 => reg30(7),
        pix_8 => reg30(8),
        pix_9 => reg30(9),
        pix_10 => reg30(10),
        pix_11 => reg30(11), 
        pix_12 => reg30(12),
        pix_13 => reg30(13),
        pix_14 => reg30(14),
        pix_15 => reg30(15),
        pix_16 => reg30(16),
        pix_17 => reg30(17), 
        pix_18 => reg30(18),
        pix_19 => reg30(19),
        pix_20 => reg30(20),
        pix_21 => reg30(21),
        pix_22 => reg30(22),
        pix_23 => reg30(23),
        pix_24 => reg30(24),
        pix_25 => reg30(25),
        pix_26 => reg30(26),
        pix_27 => reg30(27),
        pix_28 => reg30(28),
        pix_29 => reg30(29),   
        res_x_0 => dram(0),
        res_x_1 => dram(1),
        res_x_2 => dram(2),
        res_x_3 => dram(3),
        res_x_4 => dram(4),
        res_x_5 => dram(5),
        res_x_6 => dram(6),
        res_x_7 => dram(7),
        res_y_0 => dram(8),
        res_y_1 => dram(9),
        res_y_2 => dram(10),
        res_y_3 => dram(11),
        res_y_4 => dram(12),
        res_y_5 => dram(13),
        res_y_6 => dram(14),
        res_y_7 => dram(15)
        );
    

    stim_gen1: process
    begin
        for i in 0 to 0 loop
            for j in 0 to 10 loop
                for k in 0 to 9 loop
                    reg30(0 + k*3) <= bram(i*9 + k)(j)      after (i*149+ j)*100 ns;
                    reg30(1 + k*3) <= bram(i*9 + k)(j + 1)    after (i*149+ j)*100 ns;
                    reg30(2 + k*3) <= bram(i*9 + k)(j + 2)    after (i*149+ j)*100 ns;
                end loop;
            end loop;
        end loop;
        wait;
    end process;
    
    clk_gen: process
    begin
        clk_s <= '0', '1' after 50 ns;
        wait for 100 ns;
    end process;

end Behavioral;