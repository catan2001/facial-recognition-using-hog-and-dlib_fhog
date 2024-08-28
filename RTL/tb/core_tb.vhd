library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; 
use std.textio.all;
 
entity core_tb is
    generic (
        WIDTH: natural := 16; --input is [-2,2] -> 3.15
        NUM_PIX : natural := 24;
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
 
type mem24 is array(0 to NUM_PIX-1) of std_logic_vector(15 downto 0);
signal reg24: mem24;
 
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
    file text_file : text open read_mode is "/home/koshek/Desktop/emotion_recognition_git/facial-recognition-using-hog-and-dlib_fhog/input_files/gray_normalised.txt";
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
        pix_0 => reg24(0),
        pix_1 => reg24(1),
        pix_2 => reg24(2),
        pix_3 => reg24(3),
        pix_4 => reg24(4),
        pix_5 => reg24(5),
        pix_6 => reg24(6),
        pix_7 => reg24(7),
        pix_8 => reg24(8),
        pix_9 => reg24(9),
        pix_10 => reg24(10),
        pix_11 => reg24(11), 
        pix_12 => reg24(12),
        pix_13 => reg24(13),
        pix_14 => reg24(14),
        pix_15 => reg24(15),
        pix_16 => reg24(16),
        pix_17 => reg24(17), 
        pix_18 => reg24(18),
        pix_19 => reg24(19),
        pix_20 => reg24(20),
        pix_21 => reg24(21),
        pix_22 => reg24(22),
        pix_23 => reg24(23),
 
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
                reg24(0) <= bram(i)(j*4);
                reg24(1) <= bram(i)(j*4+1);
                reg24(2) <= bram(i)(j*4+2);
                reg24(3) <= bram(i)(j*4+3);
                reg24(4) <= bram(i+1)(j*4);
                reg24(5) <= bram(i+1)(j*4+1);
                reg24(6) <= bram(i+1)(j*4+2);
                reg24(7) <= bram(i+1)(j*4+3);     
                reg24(8) <= bram(i+2)(j*4);
                reg24(9) <= bram(i+2)(j*4+1);
                reg24(10) <= bram(i+2)(j*4+2);
                reg24(11) <= bram(i+2)(j*4+3);
                reg24(12) <= bram(i+3)(j*4);
                reg24(13) <= bram(i+3)(j*4+1);
                reg24(14) <= bram(i+3)(j*4+2);
                reg24(15) <= bram(i+3)(j*4+3);
                reg24(16) <= bram(i+4)(j*4);
                reg24(17) <= bram(i+4)(j*4+1);
                reg24(18) <= bram(i+4)(j*4+2);
                reg24(19) <= bram(i+4)(j*4+3);
                reg24(20) <= bram(i+5)(j*4);
                reg24(21) <= bram(i+5)(j*4+1);
                reg24(22) <= bram(i+5)(j*4+2);
                reg24(23) <= bram(i+5)(j*4+3);
        wait until rising_edge(clk_s);
            end loop;
        end loop;
 
 
--        reg24(0) <= bram(0)(0), bram(0)(1) after 100 ns, bram(0)(2) after 200 ns;
--        reg24(1) <= bram(0)(1), bram(0)(2) after 100 ns, bram(0)(3) after 200 ns;
--        reg24(2) <= bram(0)(2), bram(0)(3) after 100 ns, bram(0)(4) after 200 ns;
--        reg24(3) <= bram(0)(3), bram(0)(4) after 100 ns, bram(0)(5) after 200 ns;
--        reg24(4) <= bram(1)(0), bram(1)(1) after 100 ns, bram(1)(2) after 200 ns;
--        reg24(5) <= bram(1)(1), bram(1)(2) after 100 ns, bram(1)(3) after 200 ns;
--        reg24(6) <= bram(1)(2), bram(1)(3) after 100 ns, bram(1)(4) after 200 ns;
--        reg24(7) <= bram(1)(3), bram(1)(4) after 100 ns, bram(1)(5) after 200 ns;      
--        reg24(8) <= bram(2)(0), bram(2)(1) after 100 ns, bram(2)(2) after 200 ns;
--        reg24(9) <= bram(2)(1), bram(2)(2) after 100 ns, bram(2)(3) after 200 ns;
--        reg24(10) <= bram(2)(2), bram(2)(3) after 100 ns, bram(2)(4) after 200 ns;
--        reg24(11) <= bram(2)(3), bram(2)(4) after 100 ns, bram(2)(5) after 200 ns;
--        reg24(12) <= bram(3)(0), bram(3)(1) after 100 ns, bram(3)(2) after 200 ns;
--        reg24(13) <= bram(3)(1), bram(3)(2) after 100 ns, bram(3)(3) after 200 ns;
--        reg24(14) <= bram(3)(2), bram(3)(3) after 100 ns, bram(3)(4) after 200 ns;
--        reg24(15) <= bram(3)(3), bram(3)(4) after 100 ns, bram(3)(5) after 200 ns; 
--        reg24(16) <= bram(4)(0), bram(4)(1) after 100 ns, bram(4)(2) after 200 ns;
--        reg24(17) <= bram(4)(1), bram(4)(2) after 100 ns, bram(4)(3) after 200 ns;
--        reg24(18) <= bram(4)(2), bram(4)(3) after 100 ns, bram(4)(4) after 200 ns;
--        reg24(19) <= bram(4)(3), bram(4)(4) after 100 ns, bram(4)(5) after 200 ns;
--        reg24(20) <= bram(5)(0), bram(5)(1) after 100 ns, bram(5)(2) after 200 ns;
--        reg24(21) <= bram(5)(1), bram(5)(2) after 100 ns, bram(5)(3) after 200 ns;
--        reg24(22) <= bram(5)(2), bram(5)(3) after 100 ns, bram(5)(4) after 200 ns;
--        reg24(23) <= bram(5)(3), bram(5)(4) after 100 ns, bram(5)(5) after 200 ns;         
 
       wait;
    end process;
 
    clk_gen: process
    begin
        clk_s <= '0', '1' after 50 ns;
        wait for 100 ns;
    end process;
 
end Behavioral;