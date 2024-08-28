----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/20/2024 04:31:09 PM
-- Design Name: 
-- Module Name: tb_top - Behavioral
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
use IEEE.NUMERIC_STD.ALL; 
use std.textio.all;

entity tb_top is
  generic(DATA_WIDTH:natural:=32;
          BRAM_SIZE:natural:=1024;
          ADDR_WIDTH:natural:=10;
          PIX_WIDTH:natural:=16);
--  Port ( );
end tb_top;

architecture Behavioral of tb_top is

component top is
  generic(DATA_WIDTH:natural:=32;
          BRAM_SIZE:natural:=1024;
          ADDR_WIDTH:natural:=10;
          PIX_WIDTH:natural:=16);
  Port ( 
    clk: in std_logic;
    reset: in std_logic;
    start: in std_logic;
    en_axi: in std_logic; 

    --reg bank
    width: in std_logic_vector(9 downto 0);
    width_4: in std_logic_vector(7 downto 0);
    width_2: in std_logic_vector(8 downto 0);
    height: in std_logic_vector(10 downto 0);
    bram_height: in std_logic_vector(4 downto 0);
    dram_in_addr: in std_logic_vector(31 downto 0);
    dram_x_addr: in std_logic_vector(31 downto 0);
    dram_y_addr: in std_logic_vector(31 downto 0);
    cycle_num_limit: in std_logic_vector(5 downto 0); --2*bram_width/width
    cycle_num_out: in std_logic_vector(5 downto 0); --2*(bram_width/(width-1))
    rows_num: in std_logic_vector(9 downto 0); --2*(bram_width/width)*bram_height
    effective_row_limit: in std_logic_vector(9 downto 0); --(height/PTS_PER_COL)*PTS_PER_COL+accumulated_loss 
    
    burst_len_read: out std_logic_vector(7 downto 0);
    burst_len_write: out std_logic_vector(7 downto 0);
    
    dram_addr0: out std_logic_vector(31 downto 0);
    dram_addr1: out std_logic_vector(31 downto 0);
    
    dram_out_addr_x: out std_logic_vector(31 downto 0);
    dram_out_addr_y: out std_logic_vector(31 downto 0);

    ready: out std_logic; 
    
    --data signals
    data_in1: in std_logic_vector(63 downto 0);
    data_in2: in std_logic_vector(63 downto 0);
    data_out1: out std_logic_vector(63 downto 0);
    data_out2: out std_logic_vector(63 downto 0));

end component;

signal clk_s: std_logic;
signal reset_s: std_logic;
signal start_s: std_logic;
signal en_axi_s: std_logic;

signal width_s: std_logic_vector(9 downto 0);
signal width_4_s: std_logic_vector(7 downto 0);
signal width_2_s: std_logic_vector(8 downto 0);
signal height_s: std_logic_vector(10 downto 0);
signal bram_height_s: std_logic_vector(4 downto 0);
signal dram_in_addr_s: std_logic_vector(31 downto 0);
signal dram_x_addr_s: std_logic_vector(31 downto 0); --height*width
signal dram_y_addr_s: std_logic_vector(31 downto 0); --height*width+(height-2)*(width-2)
signal cycle_num_limit_s: std_logic_vector(5 downto 0); --2*bram_width/width
signal cycle_num_out_s: std_logic_vector(5 downto 0); --2*(bram_width/(width-1))
signal rows_num_s: std_logic_vector(9 downto 0); --2*(bram_width/width)*bram_height
signal effective_row_limit_s: std_logic_vector(9 downto 0); --(height/PTS_PER_COL)*PTS_PER_COL+accumulated_loss 

signal burst_len_read_s: std_logic_vector(7 downto 0);
signal burst_len_write_s: std_logic_vector(7 downto 0);
    
signal dram_addr0_s: std_logic_vector(31 downto 0);
signal dram_addr1_s: std_logic_vector(31 downto 0);
    
signal dram_out_addr_x_s: std_logic_vector(31 downto 0);
signal dram_out_addr_y_s: std_logic_vector(31 downto 0);

type data_t is array(0 to 1) of std_logic_vector(2*DATA_WIDTH-1 downto 0);
signal data_in_s, data_out_s: data_t;

signal ready_s: std_logic; 

constant IMG_WIDTH : natural := 152;
constant IMG_HEIGHT : natural := 152;

type rows_type is array(0 to IMG_HEIGHT - 1) of std_logic_vector(15 downto 0);
type dram_type is array(0 to IMG_WIDTH - 1) of rows_type;

impure function dram_init return dram_type is
    variable row_text : line;
    variable float_data : real;
    variable check : boolean;
    variable data : std_logic_vector(15 downto 0);
    variable dram_rows : rows_type;
    variable dram : dram_type;
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
            dram_rows(column) := data;
        end loop;
        dram(row) := dram_rows;
    end loop;
    return dram;
end function;

signal dram : dram_type := dram_init;

begin

top_l: top
generic map(
          DATA_WIDTH => DATA_WIDTH,
          BRAM_SIZE => BRAM_SIZE,
          ADDR_WIDTH => ADDR_WIDTH,
          PIX_WIDTH => PIX_WIDTH)

port map(    
    clk => clk_s,
    reset => reset_s,
    start => start_s,
    en_axi => en_axi_s,

    --reg bank
    width => width_s,
    width_4 => width_4_s,
    width_2 => width_2_s,
    height => height_s,
    bram_height => bram_height_s,
    dram_in_addr => dram_in_addr_s,
    dram_x_addr => dram_x_addr_s,
    dram_y_addr => dram_y_addr_s,
    cycle_num_limit => cycle_num_limit_s,
    cycle_num_out => cycle_num_out_s,
    rows_num => rows_num_s,
    effective_row_limit => effective_row_limit_s,
    
    burst_len_read => burst_len_read_s,
    burst_len_write => burst_len_write_s,
    
    dram_addr0 => dram_addr0_s,
    dram_addr1 => dram_addr1_s,
    
    dram_out_addr_x => dram_out_addr_x_s,
    dram_out_addr_y => dram_out_addr_y_s,

    ready => ready_s,
    
    --data signals
        data_in1 => data_in_s(0),
        data_in2 => data_in_s(1),
        data_out1 => data_out_s(0),
        data_out2 => data_out_s(1));
        
    stim_gen1: process
        variable a : integer := 0;
        variable b: integer := 0;
        variable c: integer := 0;
    begin
        reset_s <= '0', '1' after 10ns, '0' after 25ns;
        start_s <= '0', '1' after 45ns, '0' after 75ns;
        en_axi_s <= '1';
        --data_in_s(0) <= dram(0)(0)&dram(0)(1)&dram(0)(2)&dram(0)(3), dram(2)(0)&dram(2)(1)&dram(2)(2)&dram(2)(3) after 15ns, dram(4)(0)&dram(4)(1)&dram(4)(2)&dram(4)(3) after 30ns; 
        --data_in_s(1) <= dram(1)(0)&dram(1)(1)&dram(1)(2)&dram(1)(3), dram(3)(0)&dram(3)(1)&dram(3)(2)&dram(3)(3) after 15ns, dram(5)(0)&dram(5)(1)&dram(5)(2)&dram(5)(3) after 30ns; 
        for c in 0 to 3 loop
            data_in_s(0) <= x"0000000000000000"; 
            data_in_s(1) <= x"0000000000000000";
                               
                    width_s <= "0010011000";
                    width_4_s <= "00100110";
                    width_2_s <= "001001100";
                    height_s <= "00010011000";
                    bram_height_s <= "10000"; 
                    dram_in_addr_s <= x"00000000";
                    dram_x_addr_s <= x"00005A40";
                    dram_y_addr_s <= x"0000B350";
                    cycle_num_limit_s <= "001101";
                    cycle_num_out_s <= "001101";
                    rows_num_s <= "0011010111";
                    effective_row_limit_s <= "0010011000";
            wait until rising_edge(clk_s);
        end loop;
        
            for a in 0 to 75 loop
                for b in 0 to 37 loop
                    data_in_s(0) <= dram(2*a)(4*b)&dram(2*a)(4*b+1)&dram(2*a)(4*b+2)&dram(2*a)(4*b+3); 
                    data_in_s(1) <= dram(2*a+1)(4*b)&dram(2*a+1)(4*b+1)&dram(2*a+1)(4*b+2)&dram(2*a+1)(4*b+3);
                    --en_axi_s <= '1';
                    width_s <= "0010011000";
                    width_4_s <= "00100110";
                    width_2_s <= "001001100";
                    height_s <= "00010011000";
                    bram_height_s <= "10000"; 
                    dram_in_addr_s <= x"00000000";
                    dram_x_addr_s <= x"00005A40";
                    dram_y_addr_s <= x"0000B350";
                    cycle_num_limit_s <= "001101";
                    cycle_num_out_s <= "001101";
                    rows_num_s <= "0011010111";
                    effective_row_limit_s <= "0010011000";
                wait until rising_edge(clk_s);
                end loop;
            end loop;  
 
    wait;
    end process;

    clk_gen: process
    begin
        clk_s <= '0', '1' after 20 ns;
        wait for 50 ns;
    end process;

end Behavioral;
