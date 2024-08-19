----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/19/2024 12:32:01 PM
-- Design Name: 
-- Module Name: tb_datapath - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_datapath is
  generic(WIDTH:natural:=32;
          BRAM_SIZE:natural:=1024;
          ADDR_WIDTH:natural:=10;
          PIX_WIDTH:natural:=16);
--  Port ( );
end tb_datapath;

architecture Behavioral of tb_datapath is

component data_path is
  generic(WIDTH:natural:=32;
          BRAM_SIZE:natural:=1024;
          ADDR_WIDTH:natural:=10;
          PIX_WIDTH:natural:=16);
  Port ( --data signals 
        data_in1: in std_logic_vector(2*WIDTH-1 downto 0);
        data_in2: in std_logic_vector(2*WIDTH-1 downto 0);
        data_out1: out std_logic_vector(2*WIDTH-1 downto 0);
        data_out2: out std_logic_vector(2*WIDTH-1 downto 0);
        --control signals
        clk: in std_logic;
        we_in: in std_logic_vector(31 downto 0); 
        we_out:in std_logic_vector(15 downto 0);
        sel_bram_in: in std_logic_vector(3 downto 0);
        sel_bram_out: in std_logic_vector(2 downto 0);
        sel_filter: in std_logic_vector(2 downto 0);
        sel_dram: in std_logic_vector(4 downto 0);
        bram_addrA_l_in: in std_logic_vector(ADDR_WIDTH - 1 downto 0);
        bram_addrB_l_in: in std_logic_vector(ADDR_WIDTH - 1 downto 0);
        bram_addrA_h_in: in std_logic_vector(ADDR_WIDTH - 1 downto 0);
        bram_addrB_h_in: in std_logic_vector(ADDR_WIDTH - 1 downto 0);
        bram_addr_A_out: in std_logic_vector(ADDR_WIDTH - 1 downto 0);
        bram_addr_B_out: in std_logic_vector(ADDR_WIDTH - 1 downto 0)
        );

end component;

signal clk_s: std_logic;

type data_t is array(0 to 1) of std_logic_vector(2*WIDTH-1 downto 0);
signal data_in_s, data_out_s: data_t;

signal we_in_s: std_logic_vector(31 downto 0); 
signal we_out_s: std_logic_vector(15 downto 0);
signal sel_bram_in_s: std_logic_vector(3 downto 0);
signal sel_bram_out_s: std_logic_vector(2 downto 0);
signal sel_filter_s: std_logic_vector(2 downto 0);
signal sel_dram_s: std_logic_vector(4 downto 0);
signal bram_addrA_l_in_s, bram_addrB_l_in_s, bram_addrA_h_in_s, bram_addrB_h_in_s: std_logic_vector(ADDR_WIDTH - 1 downto 0);
signal bram_addr_A_out_s, bram_addr_B_out_s: std_logic_vector(ADDR_WIDTH - 1 downto 0);

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
    file text_file : text open read_mode is "C:\Users\Andjela\Desktop\psds\gray_normalised.txt";
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

data_path_l1: data_path
  generic map (WIDTH => WIDTH,
          BRAM_SIZE => BRAM_SIZE, 
          ADDR_WIDTH => ADDR_WIDTH,
          PIX_WIDTH => PIX_WIDTH)
  Port map( --data signals 
        data_in1 => data_in_s(0),
        data_in2 => data_in_s(1),
        data_out1 => data_out_s(0),
        data_out2 => data_out_s(1),
        --control signals
        clk => clk_s,
        we_in => we_in_s,
        we_out => we_out_s,
        sel_bram_in => sel_bram_in_s,
        sel_bram_out => sel_bram_out_s,
        sel_filter => sel_filter_s,
        sel_dram => sel_dram_s,
        bram_addrA_l_in => bram_addrA_l_in_s,
        bram_addrB_l_in => bram_addrB_l_in_s,
        bram_addrA_h_in => bram_addrA_h_in_s,
        bram_addrB_h_in => bram_addrB_h_in_s,
        bram_addr_A_out => bram_addr_A_out_s,
        bram_addr_B_out => bram_addr_B_out_s
        );

    stim_gen1: process
    begin
        data_in_s(0) <= dram(0)(0)&dram(0)(1)&dram(0)(2)&dram(0)(3), dram(2)(0)&dram(2)(1)&dram(2)(2)&dram(2)(3) after 15ns, dram(4)(0)&dram(4)(1)&dram(4)(2)&dram(4)(3) after 30ns; 
        data_in_s(1) <= dram(1)(0)&dram(1)(1)&dram(1)(2)&dram(1)(3), dram(3)(0)&dram(3)(1)&dram(3)(2)&dram(3)(3) after 15ns, dram(5)(0)&dram(5)(1)&dram(5)(2)&dram(5)(3) after 30ns; 
        we_in_s <= x"00000000",x"0000000F" after 40ns, x"000000F0" after 90ns, x"00000F00" after 140ns, x"00000000" after 190ns;
        we_out_s <= x"0000", x"00FF" after 300ns, x"0000" after 450ns;
        sel_bram_in_s <= "0000", "0001" after 15ns, "0010" after 30ns;
        sel_filter_s <= "000";
        sel_bram_out_s <= "000";
        sel_dram_s <= "00000";
        bram_addrA_l_in_s <= "0000000000";
        bram_addrB_l_in_s <= "0000000001";
        bram_addrA_h_in_s <= "0000000000";
        bram_addrB_h_in_s <= "0000000001";
        bram_addr_A_out_s <= "0000000000", "0000000001" after 350ns, "0000000010" after 400ns;
        bram_addr_B_out_s <= "0000000001", "00000000010" after 350ns, "0000000011" after 400ns;
    wait;
    end process;

    clk_gen: process
    begin
        clk_s <= '0', '1' after 50 ns;
        wait for 100 ns;
    end process;

end Behavioral;
