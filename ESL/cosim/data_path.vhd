library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity data_path is
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
        realloc_last_rows: in std_logic;
        bram_addrA_l_in: in std_logic_vector(ADDR_WIDTH - 1 downto 0);  --0-3
        bram_addrB_l_in: in std_logic_vector(ADDR_WIDTH - 1 downto 0);  --0-3
        bram_addrA_h_in: in std_logic_vector(ADDR_WIDTH - 1 downto 0);  --4-11
        bram_addrB_h_in: in std_logic_vector(ADDR_WIDTH - 1 downto 0);  --4-11
        bram_addrA12_in: in std_logic_vector(ADDR_WIDTH - 1 downto 0); --12-15
        bram_addrB12_in: in std_logic_vector(ADDR_WIDTH - 1 downto 0); --12-15
        bram_addr_A_out: in std_logic_vector(ADDR_WIDTH - 1 downto 0);
        bram_addr_B_out: in std_logic_vector(ADDR_WIDTH - 1 downto 0)
        );
end data_path;

architecture Behavioral of data_path is

    --en signal for bram block
     signal en_s: std_logic:='1';

    --demux to bram_block
    signal demux1_out_bram_in0, demux1_out_bram_in1, demux1_out_bram_in2, demux1_out_bram_in3: std_logic_vector(WIDTH-1 downto 0);
    signal demux1_out_bram_in4, demux1_out_bram_in5, demux1_out_bram_in6, demux1_out_bram_in7: std_logic_vector(WIDTH-1 downto 0);
    signal demux2_out_bram_in0, demux2_out_bram_in1, demux2_out_bram_in2, demux2_out_bram_in3: std_logic_vector(WIDTH-1 downto 0);
    signal demux2_out_bram_in4, demux2_out_bram_in5, demux2_out_bram_in6, demux2_out_bram_in7: std_logic_vector(WIDTH-1 downto 0);
    signal demux3_out_bram_in0, demux3_out_bram_in1, demux3_out_bram_in2, demux3_out_bram_in3: std_logic_vector(WIDTH-1 downto 0);
    signal demux3_out_bram_in4, demux3_out_bram_in5, demux3_out_bram_in6, demux3_out_bram_in7: std_logic_vector(WIDTH-1 downto 0);
    signal demux4_out_bram_in0, demux4_out_bram_in1, demux4_out_bram_in2, demux4_out_bram_in3: std_logic_vector(WIDTH-1 downto 0);
    signal demux4_out_bram_in4, demux4_out_bram_in5, demux4_out_bram_in6, demux4_out_bram_in7: std_logic_vector(WIDTH-1 downto 0);
    
    --mux to bram_block
    signal mux0_out_bramA_in0, mux0_out_bramB_in0: std_logic_vector(WIDTH-1 downto 0);
    signal mux1_out_bramA_in1, mux1_out_bramB_in1: std_logic_vector(WIDTH-1 downto 0);
    signal mux2_out_bramA_in2, mux2_out_bramB_in2: std_logic_vector(WIDTH-1 downto 0);
    signal mux3_out_bramA_in3, mux3_out_bramB_in3: std_logic_vector(WIDTH-1 downto 0);
   
    --bram_block to mux
    signal bram_block0A_out_mux_in, bram_block0B_out_mux_in, bram_block1A_out_mux_in, bram_block1B_out_mux_in: std_logic_vector(WIDTH-1 downto 0);
    signal bram_block2A_out_mux_in, bram_block2B_out_mux_in, bram_block3A_out_mux_in, bram_block3B_out_mux_in: std_logic_vector(WIDTH-1 downto 0);
    signal bram_block4A_out_mux_in, bram_block4B_out_mux_in, bram_block5A_out_mux_in, bram_block5B_out_mux_in: std_logic_vector(WIDTH-1 downto 0);
    signal bram_block6A_out_mux_in, bram_block6B_out_mux_in, bram_block7A_out_mux_in, bram_block7B_out_mux_in: std_logic_vector(WIDTH-1 downto 0);
    signal bram_block8A_out_mux_in, bram_block8B_out_mux_in, bram_block9A_out_mux_in, bram_block9B_out_mux_in: std_logic_vector(WIDTH-1 downto 0);
    signal bram_block10A_out_mux_in, bram_block10B_out_mux_in, bram_block11A_out_mux_in, bram_block11B_out_mux_in: std_logic_vector(WIDTH-1 downto 0);
    signal bram_block12A_out_mux_in, bram_block12B_out_mux_in, bram_block13A_out_mux_in, bram_block13B_out_mux_in: std_logic_vector(WIDTH-1 downto 0);
    signal bram_block14A_out_mux_in, bram_block14B_out_mux_in, bram_block15A_out_mux_in, bram_block15B_out_mux_in: std_logic_vector(WIDTH-1 downto 0);
    
    --mux to core
    signal muxA0_out_core_in, muxB0_out_core_in, muxA1_out_core_in, muxB1_out_core_in, muxA2_out_core_in, muxB2_out_core_in: std_logic_vector(WIDTH-1 downto 0);
    signal muxA3_out_core_in, muxB3_out_core_in, muxA4_out_core_in, muxB4_out_core_in, muxA5_out_core_in, muxB5_out_core_in: std_logic_vector(WIDTH-1 downto 0);
    
    --core to demux
    signal filter_x01_to_demux, filter_x23_to_demux, filter_x45_to_demux, filter_x67_to_demux: std_logic_vector(WIDTH-1 downto 0);
    signal filter_y01_to_demux, filter_y23_to_demux, filter_y45_to_demux, filter_y67_to_demux: std_logic_vector(WIDTH-1 downto 0);
    
    --demux to bram_block
    signal demux_x_bram0, demux_x_bram1, demux_x_bram2, demux_x_bram3, demux_x_bram4, demux_x_bram5, demux_x_bram6, demux_x_bram7:std_logic_vector(WIDTH-1 downto 0);
    signal demux_x_bram8, demux_x_bram9, demux_x_bram10, demux_x_bram11, demux_x_bram12, demux_x_bram13, demux_x_bram14, demux_x_bram15:std_logic_vector(WIDTH-1 downto 0);
    signal demux_y_bram0, demux_y_bram1, demux_y_bram2, demux_y_bram3, demux_y_bram4, demux_y_bram5, demux_y_bram6, demux_y_bram7:std_logic_vector(WIDTH-1 downto 0);
    signal demux_y_bram8, demux_y_bram9, demux_y_bram10, demux_y_bram11, demux_y_bram12, demux_y_bram13, demux_y_bram14, demux_y_bram15:std_logic_vector(WIDTH-1 downto 0);
    
    --bram to mux
    signal bram_block0A_x, bram_block1A_x, bram_block2A_x, bram_block3A_x, bram_block4A_x, bram_block5A_x, bram_block6A_x, bram_block7A_x:std_logic_vector(WIDTH-1 downto 0);
    signal bram_block8A_x, bram_block9A_x, bram_block10A_x, bram_block11A_x, bram_block12A_x, bram_block13A_x, bram_block14A_x, bram_block15A_x:std_logic_vector(WIDTH-1 downto 0);
    signal bram_block0B_x, bram_block1B_x, bram_block2B_x, bram_block3B_x, bram_block4B_x, bram_block5B_x, bram_block6B_x, bram_block7B_x:std_logic_vector(WIDTH-1 downto 0);
    signal bram_block8B_x, bram_block9B_x, bram_block10B_x, bram_block11B_x, bram_block12B_x, bram_block13B_x, bram_block14B_x, bram_block15B_x:std_logic_vector(WIDTH-1 downto 0);
    signal bram_block0A_y, bram_block1A_y, bram_block2A_y, bram_block3A_y, bram_block4A_y, bram_block5A_y, bram_block6A_y, bram_block7A_y:std_logic_vector(WIDTH-1 downto 0);
    signal bram_block8A_y, bram_block9A_y, bram_block10A_y, bram_block11A_y, bram_block12A_y, bram_block13A_y, bram_block14A_y, bram_block15A_y:std_logic_vector(WIDTH-1 downto 0);
    signal bram_block0B_y, bram_block1B_y, bram_block2B_y, bram_block3B_y, bram_block4B_y, bram_block5B_y, bram_block6B_y, bram_block7B_y:std_logic_vector(WIDTH-1 downto 0);
    signal bram_block8B_y, bram_block9B_y, bram_block10B_y, bram_block11B_y, bram_block12B_y, bram_block13B_y, bram_block14B_y, bram_block15B_y:std_logic_vector(WIDTH-1 downto 0);
    
    signal data_out1_s, data_out2_s: std_logic_vector(2*WIDTH-1 downto 0);

    signal we_zeros: std_logic_vector(3 downto 0):=(others => '0');
    signal data_input_b_zeros: std_logic_vector(WIDTH - 1 downto 0):=(others => '0');

    
--SIGNALS FOR VERIFICATION:------------------------------------------------------------------------
signal diax00_s, diax01_s, diax10_s, diax11_s, diax20_s, diax21_s, diax30_s, diax31_s: std_logic_vector(15 downto 0);
signal diay00_s, diay01_s, diay10_s, diay11_s, diay20_s, diay21_s, diay30_s, diay31_s: std_logic_vector(15 downto 0);
signal doax00_s, dobx00_s, doax01_s, dobx01_s: std_logic_vector(15 downto 0);
signal data_out1_s0, data_out1_s1, data_out1_s2, data_out1_s3: std_logic_vector(15 downto 0);
signal data_out2_s0, data_out2_s1, data_out2_s2, data_out2_s3: std_logic_vector(15 downto 0);
----------------------------------------------------------------------------------------------------
    
    component demux1_8
        generic (
            WIDTH: natural := 32);
        port (
            ------------------- input signals -------------------
          sel: in std_logic_vector(3 downto 0);
          x: in std_logic_vector(WIDTH-1 downto 0);
            ------------------- output signals -------------------    
          y0: out std_logic_vector(WIDTH-1 downto 0);
          y1: out std_logic_vector(WIDTH-1 downto 0);
          y2: out std_logic_vector(WIDTH-1 downto 0);
          y3: out std_logic_vector(WIDTH-1 downto 0);
          y4: out std_logic_vector(WIDTH-1 downto 0);
          y5: out std_logic_vector(WIDTH-1 downto 0);
          y6: out std_logic_vector(WIDTH-1 downto 0);
          y7: out std_logic_vector(WIDTH-1 downto 0));   
    end component;
    
    component Dual_Port_BRAM
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
    
    component mux4_1
    generic(WIDTH:natural:=32);
    Port (x0: in std_logic_vector(WIDTH-1 downto 0);
          x1: in std_logic_vector(WIDTH-1 downto 0);
          x2: in std_logic_vector(WIDTH-1 downto 0);
          x3: in std_logic_vector(WIDTH-1 downto 0);
          sel: in std_logic_vector(2 downto 0);
          y: out std_logic_vector(WIDTH-1 downto 0));
    end component;
    
    component mux2_1
    generic(WIDTH:natural:=32);
    Port (x0: in std_logic_vector(WIDTH-1 downto 0);
          x1: in std_logic_vector(WIDTH-1 downto 0);
          sel: in std_logic;
          y: out std_logic_vector(WIDTH-1 downto 0));
    end component;
    
    component core_top
        generic (
        WIDTH: natural := 16
);
    Port (
        ------------------- control signals ------------------
        clk: in std_logic;
        ------------------- input signals --------------------
        pix_0: in std_logic_vector(WIDTH - 1 downto 0); -- red 1
        pix_1: in std_logic_vector(WIDTH - 1 downto 0); -- red 1
        pix_2: in std_logic_vector(WIDTH - 1 downto 0); -- red 1
        pix_3: in std_logic_vector(WIDTH - 1 downto 0); -- red 1
        pix_4: in std_logic_vector(WIDTH - 1 downto 0); -- red 2
        pix_5: in std_logic_vector(WIDTH - 1 downto 0); -- red 2
        pix_6: in std_logic_vector(WIDTH - 1 downto 0); -- red 2
        pix_7: in std_logic_vector(WIDTH - 1 downto 0); -- red 2
        pix_8: in std_logic_vector(WIDTH - 1 downto 0); -- red 3
        pix_9: in std_logic_vector(WIDTH - 1 downto 0); -- red 3
        pix_10: in std_logic_vector(WIDTH - 1 downto 0); -- red 3
        pix_11: in std_logic_vector(WIDTH - 1 downto 0); -- red 3
        pix_12: in std_logic_vector(WIDTH - 1 downto 0); -- red 4
        pix_13: in std_logic_vector(WIDTH - 1 downto 0); -- red 4
        pix_14: in std_logic_vector(WIDTH - 1 downto 0); -- red 4
        pix_15: in std_logic_vector(WIDTH - 1 downto 0); -- red 4
        pix_16: in std_logic_vector(WIDTH - 1 downto 0); -- red 5
        pix_17: in std_logic_vector(WIDTH - 1 downto 0); -- red 5
        pix_18: in std_logic_vector(WIDTH - 1 downto 0); -- red 5
        pix_19: in std_logic_vector(WIDTH - 1 downto 0); -- red 5
        pix_20: in std_logic_vector(WIDTH - 1 downto 0); -- red 6
        pix_21: in std_logic_vector(WIDTH - 1 downto 0); -- red 6
        pix_22: in std_logic_vector(WIDTH - 1 downto 0); -- red 6
        pix_23: in std_logic_vector(WIDTH - 1 downto 0); -- red 6

        ------------------- output signals -------------------    
        res_x_0: out std_logic_vector(WIDTH - 1 downto 0); -- red 1
        res_x_1: out std_logic_vector(WIDTH - 1 downto 0); -- red 1
        res_x_2: out std_logic_vector(WIDTH - 1 downto 0); -- red 2
        res_x_3: out std_logic_vector(WIDTH - 1 downto 0); -- red 2
        res_x_4: out std_logic_vector(WIDTH - 1 downto 0); -- red 3
        res_x_5: out std_logic_vector(WIDTH - 1 downto 0); -- red 3
        res_x_6: out std_logic_vector(WIDTH - 1 downto 0); -- red 4
        res_x_7: out std_logic_vector(WIDTH - 1 downto 0); -- red 4

        res_y_0: out std_logic_vector(WIDTH - 1 downto 0); -- red 1
        res_y_1: out std_logic_vector(WIDTH - 1 downto 0); -- red 1
        res_y_2: out std_logic_vector(WIDTH - 1 downto 0); -- red 2
        res_y_3: out std_logic_vector(WIDTH - 1 downto 0); -- red 2
        res_y_4: out std_logic_vector(WIDTH - 1 downto 0); -- red 3
        res_y_5: out std_logic_vector(WIDTH - 1 downto 0); -- red 3
        res_y_6: out std_logic_vector(WIDTH - 1 downto 0); -- red 4
        res_y_7: out std_logic_vector(WIDTH - 1 downto 0)  -- red 4
        );
    end component;
    
    component demux1_4
    generic(WIDTH:natural:=32);
    Port (sel: in std_logic_vector(2 downto 0);
          x: in std_logic_vector(WIDTH-1 downto 0);
          y0: out std_logic_vector(WIDTH-1 downto 0);
          y1: out std_logic_vector(WIDTH-1 downto 0);
          y2: out std_logic_vector(WIDTH-1 downto 0);
          y3: out std_logic_vector(WIDTH-1 downto 0));
    end component;
    
    component mux16_1
        generic(WIDTH:natural:=32);
        Port (
          x0: in std_logic_vector(WIDTH-1 downto 0);
          x1: in std_logic_vector(WIDTH-1 downto 0);
          x2: in std_logic_vector(WIDTH-1 downto 0);
          x3: in std_logic_vector(WIDTH-1 downto 0);
          x4: in std_logic_vector(WIDTH-1 downto 0);
          x5: in std_logic_vector(WIDTH-1 downto 0);
          x6: in std_logic_vector(WIDTH-1 downto 0);
          x7: in std_logic_vector(WIDTH-1 downto 0);
          x8: in std_logic_vector(WIDTH-1 downto 0);
          x9: in std_logic_vector(WIDTH-1 downto 0);
          x10: in std_logic_vector(WIDTH-1 downto 0);
          x11: in std_logic_vector(WIDTH-1 downto 0);
          x12: in std_logic_vector(WIDTH-1 downto 0);
          x13: in std_logic_vector(WIDTH-1 downto 0);
          x14: in std_logic_vector(WIDTH-1 downto 0);
          x15: in std_logic_vector(WIDTH-1 downto 0);
          sel: in std_logic_vector(4 downto 0);
          y: out std_logic_vector(WIDTH-1 downto 0));
    end component;
begin

--demux before bram block
demux_in_1: demux1_8
    generic map(WIDTH => WIDTH)
    port map(sel => sel_bram_in,
             x => data_in1(63 downto 32),
             y0 => demux1_out_bram_in0,
             y1 => demux1_out_bram_in1,
             y2 => demux1_out_bram_in2,
             y3 => demux1_out_bram_in3,
             y4 => demux1_out_bram_in4,
             y5 => demux1_out_bram_in5,
             y6 => demux1_out_bram_in6,
             y7 => demux1_out_bram_in7);
           
demux_in_2: demux1_8
    generic map(WIDTH => WIDTH)
    port map(sel => sel_bram_in,
             x => data_in1(31 downto 0),
             y0 => demux2_out_bram_in0,
             y1 => demux2_out_bram_in1,
             y2 => demux2_out_bram_in2,
             y3 => demux2_out_bram_in3,
             y4 => demux2_out_bram_in4,
             y5 => demux2_out_bram_in5,
             y6 => demux2_out_bram_in6,
             y7 => demux2_out_bram_in7);
             
demux_in_3: demux1_8
    generic map(WIDTH => WIDTH)
    port map(sel => sel_bram_in,
             x => data_in2(63 downto 32),
             y0 => demux3_out_bram_in0,
             y1 => demux3_out_bram_in1,
             y2 => demux3_out_bram_in2,
             y3 => demux3_out_bram_in3,
             y4 => demux3_out_bram_in4,
             y5 => demux3_out_bram_in5,
             y6 => demux3_out_bram_in6,
             y7 => demux3_out_bram_in7);
             
demux_in_4: demux1_8
    generic map(WIDTH => WIDTH)
    port map(sel => sel_bram_in,
             x => data_in2(31 downto 0),
             y0 => demux4_out_bram_in0,
             y1 => demux4_out_bram_in1,
             y2 => demux4_out_bram_in2,
             y3 => demux4_out_bram_in3,
             y4 => demux4_out_bram_in4,
             y5 => demux4_out_bram_in5,
             y6 => demux4_out_bram_in6,
             y7 => demux4_out_bram_in7);
             
mux0A_in_2: mux2_1
    generic map(WIDTH => WIDTH)
    port map(x0 => demux1_out_bram_in0,
             x1 => bram_block12A_out_mux_in,
             sel => realloc_last_rows,
             y => mux0_out_bramA_in0);
             
mux0B_in_2: mux2_1
    generic map(WIDTH => WIDTH)
    port map(x0 => demux2_out_bram_in0,
             x1 => bram_block12B_out_mux_in,
             sel => realloc_last_rows,
             y => mux0_out_bramB_in0);
             
 --bram_block    
bram_block0_in: Dual_Port_BRAM
    generic map(
         WIDTH => WIDTH,
         BRAM_SIZE  => BRAM_SIZE,
         ADDR_WIDTH => ADDR_WIDTH)
    Port map(
         clk_a => clk,
         clk_b => clk,
         en_a => en_s,
         en_b => en_s,
         we_a => we_in(3 downto 0),
         we_b => we_in(3 downto 0),
         data_output_a => bram_block0A_out_mux_in, 
         data_input_a => mux0_out_bramA_in0,
         addr_a => bram_addrA_l_in,
         data_output_b => bram_block0B_out_mux_in,
         data_input_b => mux0_out_bramB_in0, 
         addr_b => bram_addrB_l_in
         );
         
mux1A_in_2: mux2_1
    generic map(WIDTH => WIDTH)
    port map(x0 => demux3_out_bram_in0,
             x1 => bram_block13A_out_mux_in,
             sel => realloc_last_rows,
             y => mux1_out_bramA_in1);
             
mux1B_in_2: mux2_1
    generic map(WIDTH => WIDTH)
    port map(x0 => demux4_out_bram_in0,
             x1 => bram_block13B_out_mux_in,
             sel => realloc_last_rows,
             y => mux1_out_bramB_in1);
        
bram_block1_in: Dual_Port_BRAM
    generic map(
         WIDTH => WIDTH,
         BRAM_SIZE  => BRAM_SIZE,
         ADDR_WIDTH => ADDR_WIDTH)
    Port map(
         clk_a => clk,
         clk_b => clk,
         en_a => en_s,
         en_b => en_s,
         we_a => we_in(3 downto 0),
         we_b => we_in(3 downto 0),
         data_output_a => bram_block1A_out_mux_in, 
         data_input_a => mux1_out_bramA_in1,
         addr_a => bram_addrA_l_in,
         data_output_b => bram_block1B_out_mux_in,
         data_input_b => mux1_out_bramB_in1, 
         addr_b => bram_addrB_l_in
         );
         
mux2A_in_2: mux2_1
    generic map(WIDTH => WIDTH)
    port map(x0 => demux1_out_bram_in1,
             x1 => bram_block14A_out_mux_in,
             sel => realloc_last_rows,
             y => mux2_out_bramA_in2);
             
mux2B_in_2: mux2_1
    generic map(WIDTH => WIDTH)
    port map(x0 => demux2_out_bram_in1,
             x1 => bram_block14B_out_mux_in,
             sel => realloc_last_rows,
             y => mux2_out_bramB_in2);
         
 bram_block2_in: Dual_Port_BRAM
    generic map(
         WIDTH => WIDTH,
         BRAM_SIZE  => BRAM_SIZE,
         ADDR_WIDTH => ADDR_WIDTH)
    Port map(
         clk_a => clk,
         clk_b => clk,
         en_a => en_s,
         en_b => en_s,
         we_a => we_in(7 downto 4),
         we_b => we_in(7 downto 4),
         data_output_a => bram_block2A_out_mux_in, 
         data_input_a => mux2_out_bramA_in2,
         addr_a => bram_addrA_l_in,
         data_output_b => bram_block2B_out_mux_in,
         data_input_b => mux2_out_bramB_in2, 
         addr_b => bram_addrB_l_in
         );
         
mux3A_in_2: mux2_1
    generic map(WIDTH => WIDTH)
    port map(x0 => demux3_out_bram_in1,
             x1 => bram_block15A_out_mux_in,
             sel => realloc_last_rows,
             y => mux3_out_bramA_in3);
             
mux3B_in_2: mux2_1
    generic map(WIDTH => WIDTH)
    port map(x0 => demux4_out_bram_in1,
             x1 => bram_block15B_out_mux_in,
             sel => realloc_last_rows,
             y => mux3_out_bramB_in3);

 bram_block3_in: Dual_Port_BRAM
    generic map(
         WIDTH => WIDTH,
         BRAM_SIZE  => BRAM_SIZE,
         ADDR_WIDTH => ADDR_WIDTH)
    Port map(
         clk_a => clk,
         clk_b => clk,
         en_a => en_s,
         en_b => en_s,
         we_a => we_in(7 downto 4),
         we_b => we_in(7 downto 4),
         data_output_a => bram_block3A_out_mux_in, 
         data_input_a => mux3_out_bramA_in3,
         addr_a => bram_addrA_l_in,
         data_output_b => bram_block3B_out_mux_in,
         data_input_b => mux3_out_bramB_in3, 
         addr_b => bram_addrB_l_in
         );
         
   bram_block4_in: Dual_Port_BRAM
    generic map(
         WIDTH => WIDTH,
         BRAM_SIZE  => BRAM_SIZE,
         ADDR_WIDTH => ADDR_WIDTH)
    Port map(
         clk_a => clk,
         clk_b => clk,
         en_a => en_s,
         en_b => en_s,
         we_a => we_in(11 downto 8),
         we_b => we_in(11 downto 8),
         data_output_a => bram_block4A_out_mux_in, 
         data_input_a => demux1_out_bram_in2,
         addr_a => bram_addrA_h_in,
         data_output_b => bram_block4B_out_mux_in,
         data_input_b => demux2_out_bram_in2, 
         addr_b => bram_addrB_h_in
         );
         
    bram_block5_in: Dual_Port_BRAM
    generic map(
         WIDTH => WIDTH,
         BRAM_SIZE  => BRAM_SIZE,
         ADDR_WIDTH => ADDR_WIDTH)
    Port map(
         clk_a => clk,
         clk_b => clk,
         en_a => en_s,
         en_b => en_s,
         we_a => we_in(11 downto 8),
         we_b => we_in(11 downto 8),
         data_output_a => bram_block5A_out_mux_in, 
         data_input_a => demux3_out_bram_in2,
         addr_a => bram_addrA_h_in,
         data_output_b => bram_block5B_out_mux_in,
         data_input_b => demux4_out_bram_in2, 
         addr_b => bram_addrB_h_in
         );
         
    bram_block6_in: Dual_Port_BRAM
    generic map(
         WIDTH => WIDTH,
         BRAM_SIZE  => BRAM_SIZE,
         ADDR_WIDTH => ADDR_WIDTH)
    Port map(
         clk_a => clk,
         clk_b => clk,
         en_a => en_s,
         en_b => en_s,
         we_a => we_in(15 downto 12),
         we_b => we_in(15 downto 12),
         data_output_a => bram_block6A_out_mux_in, 
         data_input_a => demux1_out_bram_in3,
         addr_a => bram_addrA_h_in,
         data_output_b => bram_block6B_out_mux_in,
         data_input_b => demux2_out_bram_in3, 
         addr_b => bram_addrB_h_in
         );
         
   bram_block7_in: Dual_Port_BRAM
    generic map(
         WIDTH => WIDTH,
         BRAM_SIZE  => BRAM_SIZE,
         ADDR_WIDTH => ADDR_WIDTH)
    Port map(
         clk_a => clk,
         clk_b => clk,
         en_a => en_s,
         en_b => en_s,
         we_a => we_in(15 downto 12),
         we_b => we_in(15 downto 12),
         data_output_a => bram_block7A_out_mux_in, 
         data_input_a => demux3_out_bram_in3,
         addr_a => bram_addrA_h_in,
         data_output_b => bram_block7B_out_mux_in,
         data_input_b => demux4_out_bram_in3, 
         addr_b => bram_addrB_h_in
         );
         
   bram_block8_in: Dual_Port_BRAM
    generic map(
         WIDTH => WIDTH,
         BRAM_SIZE  => BRAM_SIZE,
         ADDR_WIDTH => ADDR_WIDTH)
    Port map(
         clk_a => clk,
         clk_b => clk,
         en_a => en_s,
         en_b => en_s,
         we_a => we_in(19 downto 16),
         we_b => we_in(19 downto 16),
         data_output_a => bram_block8A_out_mux_in, 
         data_input_a => demux1_out_bram_in4,
         addr_a => bram_addrA_h_in,
         data_output_b => bram_block8B_out_mux_in,
         data_input_b => demux2_out_bram_in4, 
         addr_b => bram_addrB_h_in
         );
         
    bram_block9_in: Dual_Port_BRAM
    generic map(
         WIDTH => WIDTH,
         BRAM_SIZE  => BRAM_SIZE,
         ADDR_WIDTH => ADDR_WIDTH)
    Port map(
         clk_a => clk,
         clk_b => clk,
         en_a => en_s,
         en_b => en_s,
         we_a => we_in(19 downto 16),
         we_b => we_in(19 downto 16),
         data_output_a => bram_block9A_out_mux_in, 
         data_input_a => demux3_out_bram_in4,
         addr_a => bram_addrA_h_in,
         data_output_b => bram_block9B_out_mux_in,
         data_input_b => demux4_out_bram_in4, 
         addr_b => bram_addrB_h_in
         );
         
   bram_block10_in: Dual_Port_BRAM
    generic map(
         WIDTH => WIDTH,
         BRAM_SIZE  => BRAM_SIZE,
         ADDR_WIDTH => ADDR_WIDTH)
    Port map(
         clk_a => clk,
         clk_b => clk,
         en_a => en_s,
         en_b => en_s,
         we_a => we_in(23 downto 20),
         we_b => we_in(23 downto 20),
         data_output_a => bram_block10A_out_mux_in, 
         data_input_a => demux1_out_bram_in5,
         addr_a => bram_addrA_h_in,
         data_output_b => bram_block10B_out_mux_in,
         data_input_b => demux2_out_bram_in5, 
         addr_b => bram_addrB_h_in
         );
         
   bram_block11_in: Dual_Port_BRAM
    generic map(
         WIDTH => WIDTH,
         BRAM_SIZE  => BRAM_SIZE,
         ADDR_WIDTH => ADDR_WIDTH)
    Port map(
         clk_a => clk,
         clk_b => clk,
         en_a => en_s,
         en_b => en_s,
         we_a => we_in(23 downto 20),
         we_b => we_in(23 downto 20),
         data_output_a => bram_block11A_out_mux_in, 
         data_input_a => demux3_out_bram_in5,
         addr_a => bram_addrA_h_in,
         data_output_b => bram_block11B_out_mux_in,
         data_input_b => demux4_out_bram_in5, 
         addr_b => bram_addrB_h_in
         );
         
    bram_block12_in: Dual_Port_BRAM
    generic map(
         WIDTH => WIDTH,
         BRAM_SIZE  => BRAM_SIZE,
         ADDR_WIDTH => ADDR_WIDTH)
    Port map(
         clk_a => clk,
         clk_b => clk,
         en_a => en_s,
         en_b => en_s,
         we_a => we_in(27 downto 24),
         we_b => we_in(27 downto 24),
         data_output_a => bram_block12A_out_mux_in, 
         data_input_a => demux1_out_bram_in6,
         addr_a => bram_addrA12_in,
         data_output_b => bram_block12B_out_mux_in,
         data_input_b => demux2_out_bram_in6, 
         addr_b => bram_addrB12_in
         );
         
    bram_block13_in: Dual_Port_BRAM
    generic map(
         WIDTH => WIDTH,
         BRAM_SIZE  => BRAM_SIZE,
         ADDR_WIDTH => ADDR_WIDTH)
    Port map(
         clk_a => clk,
         clk_b => clk,
         en_a => en_s,
         en_b => en_s,
         we_a => we_in(27 downto 24),
         we_b => we_in(27 downto 24),
         data_output_a => bram_block13A_out_mux_in, 
         data_input_a => demux3_out_bram_in6,
         addr_a => bram_addrA12_in,
         data_output_b => bram_block13B_out_mux_in,
         data_input_b => demux4_out_bram_in6, 
         addr_b => bram_addrB12_in
         );
         
    bram_block14_in: Dual_Port_BRAM
    generic map(
         WIDTH => WIDTH,
         BRAM_SIZE  => BRAM_SIZE,
         ADDR_WIDTH => ADDR_WIDTH)
    Port map(
         clk_a => clk,
         clk_b => clk,
         en_a => en_s,
         en_b => en_s,
         we_a => we_in(31 downto 28),
         we_b => we_in(31 downto 28),
         data_output_a => bram_block14A_out_mux_in, 
         data_input_a => demux1_out_bram_in7,
         addr_a => bram_addrA12_in,
         data_output_b => bram_block14B_out_mux_in,
         data_input_b => demux2_out_bram_in7, 
         addr_b => bram_addrB12_in
         );
         
    bram_block15_in: Dual_Port_BRAM
    generic map(
         WIDTH => WIDTH,
         BRAM_SIZE  => BRAM_SIZE,
         ADDR_WIDTH => ADDR_WIDTH)
    Port map(
         clk_a => clk,
         clk_b => clk,
         en_a => en_s,
         en_b => en_s,
         we_a => we_in(31 downto 28),
         we_b => we_in(31 downto 28),
         data_output_a => bram_block15A_out_mux_in, 
         data_input_a => demux3_out_bram_in7,
         addr_a => bram_addrA12_in,
         data_output_b => bram_block15B_out_mux_in,
         data_input_b => demux4_out_bram_in7, 
         addr_b => bram_addrB12_in
         );
  
  --mux before core       
    mux0A_in: mux4_1
    generic map(WIDTH => WIDTH)
    Port map(
          x0 => bram_block0A_out_mux_in,
          x1 => bram_block4A_out_mux_in,
          x2 => bram_block8A_out_mux_in,
          x3 => bram_block12A_out_mux_in,
          sel => sel_filter,
          y => muxA0_out_core_in);
          
    mux0B_in: mux4_1
    generic map(WIDTH => WIDTH)
    Port map(
          x0 => bram_block0B_out_mux_in,
          x1 => bram_block4B_out_mux_in,
          x2 => bram_block8B_out_mux_in,
          x3 => bram_block12B_out_mux_in,
          sel => sel_filter,
          y => muxB0_out_core_in);
          
    mux1A_in: mux4_1
    generic map(WIDTH => WIDTH)
    Port map(
          x0 => bram_block1A_out_mux_in,
          x1 => bram_block5A_out_mux_in,
          x2 => bram_block9A_out_mux_in,
          x3 => bram_block13A_out_mux_in,
          sel => sel_filter,
          y => muxA1_out_core_in);
          
    mux1B_in: mux4_1
    generic map(WIDTH => WIDTH)
    Port map(
          x0 => bram_block1B_out_mux_in,
          x1 => bram_block5B_out_mux_in,
          x2 => bram_block9B_out_mux_in,
          x3 => bram_block13B_out_mux_in,
          sel => sel_filter,
          y => muxB1_out_core_in);
          
    mux2A_in: mux4_1
    generic map(WIDTH => WIDTH)
    Port map(
          x0 => bram_block2A_out_mux_in,
          x1 => bram_block6A_out_mux_in,
          x2 => bram_block10A_out_mux_in,
          x3 => bram_block14A_out_mux_in,
          sel => sel_filter,
          y => muxA2_out_core_in);
          
    mux2B_in: mux4_1
    generic map(WIDTH => WIDTH)
    Port map(
          x0 => bram_block2B_out_mux_in,
          x1 => bram_block6B_out_mux_in,
          x2 => bram_block10B_out_mux_in,
          x3 => bram_block14B_out_mux_in,
          sel => sel_filter,
          y => muxB2_out_core_in);
          
    mux3A_in: mux4_1
    generic map(WIDTH => WIDTH)
    Port map(
          x0 => bram_block3A_out_mux_in,
          x1 => bram_block7A_out_mux_in,
          x2 => bram_block11A_out_mux_in,
          x3 => bram_block15A_out_mux_in,
          sel => sel_filter,
          y => muxA3_out_core_in);
          
    mux3B_in: mux4_1
    generic map(WIDTH => WIDTH)
    Port map(
          x0 => bram_block3B_out_mux_in,
          x1 => bram_block7B_out_mux_in,
          x2 => bram_block11B_out_mux_in,
          x3 => bram_block15B_out_mux_in,
          sel => sel_filter,
          y => muxB3_out_core_in);
          
    mux4A_in: mux4_1
    generic map(WIDTH => WIDTH)
    Port map(
          x0 => bram_block4A_out_mux_in,
          x1 => bram_block8A_out_mux_in,
          x2 => bram_block12A_out_mux_in,
          x3 => bram_block0A_out_mux_in,
          sel => sel_filter,
          y => muxA4_out_core_in);
          
    mux4B_in: mux4_1
    generic map(WIDTH => WIDTH)
    Port map(
          x0 => bram_block4B_out_mux_in,
          x1 => bram_block8B_out_mux_in,
          x2 => bram_block12B_out_mux_in,
          x3 => bram_block0B_out_mux_in,
          sel => sel_filter,
          y => muxB4_out_core_in);
          
    mux5A_in: mux4_1
    generic map(WIDTH => WIDTH)
    Port map(
          x0 => bram_block5A_out_mux_in,
          x1 => bram_block9A_out_mux_in,
          x2 => bram_block13A_out_mux_in,
          x3 => bram_block1A_out_mux_in,
          sel => sel_filter,
          y => muxA5_out_core_in);
          
    mux5B_in: mux4_1
    generic map(WIDTH => WIDTH)
    Port map(
          x0 => bram_block5B_out_mux_in,
          x1 => bram_block9B_out_mux_in,
          x2 => bram_block13B_out_mux_in,
          x3 => bram_block1B_out_mux_in,
          sel => sel_filter,
          y => muxB5_out_core_in);
          
--core
     core: core_top  
     generic map(WIDTH => PIX_WIDTH)
          Port map(
               clk => clk,

               pix_0 => muxA0_out_core_in(31 downto 16),
               pix_1 => muxA0_out_core_in(15 downto 0),
               pix_2 => muxB0_out_core_in(31 downto 16),
               pix_3 => muxB0_out_core_in(15 downto 0),

               pix_4 => muxA1_out_core_in(31 downto 16),
               pix_5 => muxA1_out_core_in(15 downto 0),
               pix_6 => muxB1_out_core_in(31 downto 16),
               pix_7 => muxB1_out_core_in(15 downto 0),

               pix_8 => muxA2_out_core_in(31 downto 16),
               pix_9 => muxA2_out_core_in(15 downto 0),
               pix_10 => muxB2_out_core_in(31 downto 16),
               pix_11 => muxB2_out_core_in(15 downto 0),

               pix_12 => muxA3_out_core_in(31 downto 16),
               pix_13 => muxA3_out_core_in(15 downto 0),
               pix_14 => muxB3_out_core_in(31 downto 16),
               pix_15 => muxB3_out_core_in(15 downto 0),

               pix_16 => muxA4_out_core_in(31 downto 16),
               pix_17 => muxA4_out_core_in(15 downto 0),
               pix_18 => muxB4_out_core_in(31 downto 16),
               pix_19 => muxB4_out_core_in(15 downto 0),

               pix_20 => muxA5_out_core_in(31 downto 16),
               pix_21 => muxA5_out_core_in(15 downto 0),
               pix_22 => muxB5_out_core_in(31 downto 16),
               pix_23 => muxB5_out_core_in(15 downto 0),
       
               res_x_0 => filter_x01_to_demux(31 downto 16),
               res_x_1 => filter_x01_to_demux(15 downto 0),
               res_x_2 => filter_x23_to_demux(31 downto 16),
               res_x_3 => filter_x23_to_demux(15 downto 0),
               res_x_4 => filter_x45_to_demux(31 downto 16),
               res_x_5 => filter_x45_to_demux(15 downto 0),
               res_x_6 => filter_x67_to_demux(31 downto 16),
               res_x_7 => filter_x67_to_demux(15 downto 0),
       
               res_y_0 => filter_y01_to_demux(31 downto 16),
               res_y_1 => filter_y01_to_demux(15 downto 0),
               res_y_2 => filter_y23_to_demux(31 downto 16),
               res_y_3 => filter_y23_to_demux(15 downto 0),
               res_y_4 => filter_y45_to_demux(31 downto 16),
               res_y_5 => filter_y45_to_demux(15 downto 0),
               res_y_6 => filter_y67_to_demux(31 downto 16),
               res_y_7 => filter_y67_to_demux(15 downto 0)
          );

    --demux after bram_block
    demux_x0: demux1_4
    generic map(WIDTH => WIDTH)
    Port map(
          sel => sel_bram_out,
          x => filter_x01_to_demux,
          y0 => demux_x_bram0,
          y1 => demux_x_bram4,
          y2 => demux_x_bram8,
          y3 => demux_x_bram12);
          
    demux_x1: demux1_4
    generic map(WIDTH => WIDTH)
    Port map(
          sel => sel_bram_out,
          x => filter_x23_to_demux,
          y0 => demux_x_bram1,
          y1 => demux_x_bram5,
          y2 => demux_x_bram9,
          y3 => demux_x_bram13);
          
    demux_x2: demux1_4
    generic map(WIDTH => WIDTH)
    Port map(
          sel => sel_bram_out,
          x => filter_x45_to_demux,
          y0 => demux_x_bram2,
          y1 => demux_x_bram6,
          y2 => demux_x_bram10,
          y3 => demux_x_bram14);
          
    demux_x3: demux1_4
    generic map(WIDTH => WIDTH)
    Port map(
          sel => sel_bram_out,
          x => filter_x67_to_demux,
          y0 => demux_x_bram3,
          y1 => demux_x_bram7,
          y2 => demux_x_bram11,
          y3 => demux_x_bram15);
          
    demux_y0: demux1_4
    generic map(WIDTH => WIDTH)
    Port map(
          sel => sel_bram_out,
          x => filter_y01_to_demux,
          y0 => demux_y_bram0,
          y1 => demux_y_bram4,
          y2 => demux_y_bram8,
          y3 => demux_y_bram12);
          
    demux_y1: demux1_4
    generic map(WIDTH => WIDTH)
    Port map(
          sel => sel_bram_out,
          x => filter_y23_to_demux,
          y0 => demux_y_bram1,
          y1 => demux_y_bram5,
          y2 => demux_y_bram9,
          y3 => demux_y_bram13);
          
    demux_y2: demux1_4
    generic map(WIDTH => WIDTH)
    Port map(
          sel => sel_bram_out,
          x => filter_y45_to_demux,
          y0 => demux_y_bram2,
          y1 => demux_y_bram6,
          y2 => demux_y_bram10,
          y3 => demux_y_bram14);
          
    demux_y3: demux1_4
    generic map(WIDTH => WIDTH)
    Port map(
          sel => sel_bram_out,
          x => filter_y67_to_demux,
          y0 => demux_y_bram3,
          y1 => demux_y_bram7,
          y2 => demux_y_bram11,
          y3 => demux_y_bram15);
          
    ---bram_block_x                
    bram_block_x0_out: Dual_Port_BRAM
    generic map(
         WIDTH => WIDTH,
         BRAM_SIZE  => BRAM_SIZE,
         ADDR_WIDTH => ADDR_WIDTH)
    Port map(
         clk_a => clk,
         clk_b => clk,
         en_a => en_s,
         en_b => en_s,
         we_a => we_out(3 downto 0),
         we_b => we_zeros,
         data_output_a => bram_block0A_x, 
         data_input_a => demux_x_bram0,
         addr_a => bram_addr_A_out,
         data_output_b => bram_block0B_x,
         data_input_b => data_input_b_zeros, 
         addr_b => bram_addr_B_out
         );
       
    --signals for verification  
    doax00_s <= bram_block0A_x(31 downto 16);
    doax01_s <= bram_block0A_x(15 downto 0);
    dobx00_s <= bram_block0B_x(31 downto 16);
    dobx01_s <= bram_block0B_x(15 downto 0);
          
    bram_block_x1_out: Dual_Port_BRAM
    generic map(
         WIDTH => WIDTH,
         BRAM_SIZE  => BRAM_SIZE,
         ADDR_WIDTH => ADDR_WIDTH)
    Port map(
         clk_a => clk,
         clk_b => clk,
         en_a => en_s,
         en_b => en_s,
         we_a => we_out(3 downto 0),
         we_b => we_zeros,
         data_output_a => bram_block1A_x, 
         data_input_a => demux_x_bram1,
         addr_a => bram_addr_A_out,
         data_output_b => bram_block1B_x,
         data_input_b => data_input_b_zeros, 
         addr_b => bram_addr_B_out
         );
         
    bram_block_x2_out: Dual_Port_BRAM
    generic map(
         WIDTH => WIDTH,
         BRAM_SIZE  => BRAM_SIZE,
         ADDR_WIDTH => ADDR_WIDTH)
    Port map(
         clk_a => clk,
         clk_b => clk,
         en_a => en_s,
         en_b => en_s,
         we_a => we_out(3 downto 0),
         we_b => we_zeros,
         data_output_a => bram_block2A_x, 
         data_input_a => demux_x_bram2,
         addr_a => bram_addr_A_out,
         data_output_b => bram_block2B_x,
         data_input_b => data_input_b_zeros, 
         addr_b => bram_addr_B_out
         );
         
    bram_block_x3_out: Dual_Port_BRAM
    generic map(
         WIDTH => WIDTH,
         BRAM_SIZE  => BRAM_SIZE,
         ADDR_WIDTH => ADDR_WIDTH)
    Port map(
         clk_a => clk,
         clk_b => clk,
         en_a => en_s,
         en_b => en_s,
         we_a => we_out(3 downto 0),
         we_b => we_zeros,
         data_output_a => bram_block3A_x, 
         data_input_a => demux_x_bram3,
         addr_a => bram_addr_A_out,
         data_output_b => bram_block3B_x,
         data_input_b => data_input_b_zeros, 
         addr_b => bram_addr_B_out
         );
         
    bram_block_x4_out: Dual_Port_BRAM
    generic map(
         WIDTH => WIDTH,
         BRAM_SIZE  => BRAM_SIZE,
         ADDR_WIDTH => ADDR_WIDTH)
    Port map(
         clk_a => clk,
         clk_b => clk,
         en_a => en_s,
         en_b => en_s,
         we_a => we_out(7 downto 4),
         we_b => we_zeros,
         data_output_a => bram_block4A_x, 
         data_input_a => demux_x_bram4,
         addr_a => bram_addr_A_out,
         data_output_b => bram_block4B_x,
         data_input_b => data_input_b_zeros, 
         addr_b => bram_addr_B_out
         );
    bram_block_x5_out: Dual_Port_BRAM
    generic map(
         WIDTH => WIDTH,
         BRAM_SIZE  => BRAM_SIZE,
         ADDR_WIDTH => ADDR_WIDTH)
    Port map(
         clk_a => clk,
         clk_b => clk,
         en_a => en_s,
         en_b => en_s,
         we_a => we_out(7 downto 4),
         we_b => we_zeros,
         data_output_a => bram_block5A_x, 
         data_input_a => demux_x_bram5,
         addr_a => bram_addr_A_out,
         data_output_b => bram_block5B_x,
         data_input_b => data_input_b_zeros, 
         addr_b => bram_addr_B_out
         );     
         
    bram_block_x6_out: Dual_Port_BRAM
    generic map(
         WIDTH => WIDTH,
         BRAM_SIZE  => BRAM_SIZE,
         ADDR_WIDTH => ADDR_WIDTH)
    Port map(
         clk_a => clk,
         clk_b => clk,
         en_a => en_s,
         en_b => en_s,
         we_a => we_out(7 downto 4),
         we_b => we_zeros,
         data_output_a => bram_block6A_x, 
         data_input_a => demux_x_bram6,
         addr_a => bram_addr_A_out,
         data_output_b => bram_block6B_x,
         data_input_b => data_input_b_zeros, 
         addr_b => bram_addr_B_out
         );
         
    bram_block_x7_out: Dual_Port_BRAM
    generic map(
         WIDTH => WIDTH,
         BRAM_SIZE  => BRAM_SIZE,
         ADDR_WIDTH => ADDR_WIDTH)
    Port map(
         clk_a => clk,
         clk_b => clk,
         en_a => en_s,
         en_b => en_s,
         we_a => we_out(7 downto 4),
         we_b => we_zeros,
         data_output_a => bram_block7A_x, 
         data_input_a => demux_x_bram7,
         addr_a => bram_addr_A_out,
         data_output_b => bram_block7B_x,
         data_input_b => data_input_b_zeros, 
         addr_b => bram_addr_B_out
         );
         
    bram_block_x8_out: Dual_Port_BRAM
    generic map(
         WIDTH => WIDTH,
         BRAM_SIZE  => BRAM_SIZE,
         ADDR_WIDTH => ADDR_WIDTH)
    Port map(
         clk_a => clk,
         clk_b => clk,
         en_a => en_s,
         en_b => en_s,
         we_a => we_out(11 downto 8),
         we_b => we_zeros,
         data_output_a => bram_block8A_x, 
         data_input_a => demux_x_bram8,
         addr_a => bram_addr_A_out,
         data_output_b => bram_block8B_x,
         data_input_b => data_input_b_zeros, 
         addr_b => bram_addr_B_out
         ); 
         
    bram_block_x9_out: Dual_Port_BRAM
    generic map(
         WIDTH => WIDTH,
         BRAM_SIZE  => BRAM_SIZE,
         ADDR_WIDTH => ADDR_WIDTH)
    Port map(
         clk_a => clk,
         clk_b => clk,
         en_a => en_s,
         en_b => en_s,
         we_a => we_out(11 downto 8),
         we_b => we_zeros,
         data_output_a => bram_block9A_x, 
         data_input_a => demux_x_bram9,
         addr_a => bram_addr_A_out,
         data_output_b => bram_block9B_x,
         data_input_b => data_input_b_zeros, 
         addr_b => bram_addr_B_out
         );   
         
    bram_block_x10_out: Dual_Port_BRAM
    generic map(
         WIDTH => WIDTH,
         BRAM_SIZE  => BRAM_SIZE,
         ADDR_WIDTH => ADDR_WIDTH)
    Port map(
         clk_a => clk,
         clk_b => clk,
         en_a => en_s,
         en_b => en_s,
         we_a => we_out(11 downto 8),
         we_b => we_zeros,
         data_output_a => bram_block10A_x, 
         data_input_a => demux_x_bram10,
         addr_a => bram_addr_A_out,
         data_output_b => bram_block10B_x,
         data_input_b => data_input_b_zeros, 
         addr_b => bram_addr_B_out
         );   
          
    bram_block_x11_out: Dual_Port_BRAM
    generic map(
         WIDTH => WIDTH,
         BRAM_SIZE  => BRAM_SIZE,
         ADDR_WIDTH => ADDR_WIDTH)
    Port map(
         clk_a => clk,
         clk_b => clk,
         en_a => en_s,
         en_b => en_s,
         we_a => we_out(11 downto 8),
         we_b => we_zeros,
         data_output_a => bram_block11A_x, 
         data_input_a => demux_x_bram11,
         addr_a => bram_addr_A_out,
         data_output_b => bram_block11B_x,
         data_input_b => data_input_b_zeros, 
         addr_b => bram_addr_B_out
         );  
     
    bram_block_x12_out: Dual_Port_BRAM
    generic map(
         WIDTH => WIDTH,
         BRAM_SIZE  => BRAM_SIZE,
         ADDR_WIDTH => ADDR_WIDTH)
    Port map(
         clk_a => clk,
         clk_b => clk,
         en_a => en_s,
         en_b => en_s,
         we_a => we_out(15 downto 12),
         we_b => we_zeros,
         data_output_a => bram_block12A_x, 
         data_input_a => demux_x_bram12,
         addr_a => bram_addr_A_out,
         data_output_b => bram_block12B_x,
         data_input_b => data_input_b_zeros, 
         addr_b => bram_addr_B_out
         );  
         
    bram_block_x13_out: Dual_Port_BRAM
    generic map(
         WIDTH => WIDTH,
         BRAM_SIZE  => BRAM_SIZE,
         ADDR_WIDTH => ADDR_WIDTH)
    Port map(
         clk_a => clk,
         clk_b => clk,
         en_a => en_s,
         en_b => en_s,
         we_a => we_out(15 downto 12),
         we_b => we_zeros,
         data_output_a => bram_block13A_x, 
         data_input_a => demux_x_bram13,
         addr_a => bram_addr_A_out,
         data_output_b => bram_block13B_x,
         data_input_b => data_input_b_zeros, 
         addr_b => bram_addr_B_out
         );  
         
    bram_block_x14_out: Dual_Port_BRAM
    generic map(
         WIDTH => WIDTH,
         BRAM_SIZE  => BRAM_SIZE,
         ADDR_WIDTH => ADDR_WIDTH)
    Port map(
         clk_a => clk,
         clk_b => clk,
         en_a => en_s,
         en_b => en_s,
         we_a => we_out(15 downto 12),
         we_b => we_zeros,
         data_output_a => bram_block14A_x, 
         data_input_a => demux_x_bram14,
         addr_a => bram_addr_A_out,
         data_output_b => bram_block14B_x,
         data_input_b => data_input_b_zeros, 
         addr_b => bram_addr_B_out
         );  
         
    bram_block_x15_out: Dual_Port_BRAM
    generic map(
         WIDTH => WIDTH,
         BRAM_SIZE  => BRAM_SIZE,
         ADDR_WIDTH => ADDR_WIDTH)
    Port map(
         clk_a => clk,
         clk_b => clk,
         en_a => en_s,
         en_b => en_s,
         we_a => we_out(15 downto 12),
         we_b => we_zeros,
         data_output_a => bram_block15A_x, 
         data_input_a => demux_x_bram15,
         addr_a => bram_addr_A_out,
         data_output_b => bram_block15B_x,
         data_input_b => data_input_b_zeros, 
         addr_b => bram_addr_B_out
         );  
         
    ---bram_block_y               
    bram_block_y0_out: Dual_Port_BRAM
    generic map(
         WIDTH => WIDTH,
         BRAM_SIZE  => BRAM_SIZE,
         ADDR_WIDTH => ADDR_WIDTH)
    Port map(
         clk_a => clk,
         clk_b => clk,
         en_a => en_s,
         en_b => en_s,
         we_a => we_out(3 downto 0),
         we_b => we_zeros,
         data_output_a => bram_block0A_y, 
         data_input_a => demux_y_bram0,
         addr_a => bram_addr_A_out,
         data_output_b => bram_block0B_y,
         data_input_b => data_input_b_zeros, 
         addr_b => bram_addr_B_out
         );
          
    bram_block_y1_out: Dual_Port_BRAM
    generic map(
         WIDTH => WIDTH,
         BRAM_SIZE  => BRAM_SIZE,
         ADDR_WIDTH => ADDR_WIDTH)
    Port map(
         clk_a => clk,
         clk_b => clk,
         en_a => en_s,
         en_b => en_s,
         we_a => we_out(3 downto 0),
         we_b => we_zeros,
         data_output_a => bram_block1A_y, 
         data_input_a => demux_y_bram1,
         addr_a => bram_addr_A_out,
         data_output_b => bram_block1B_y,
         data_input_b => data_input_b_zeros, 
         addr_b => bram_addr_B_out
         );
         
    bram_block_y2_out: Dual_Port_BRAM
    generic map(
         WIDTH => WIDTH,
         BRAM_SIZE  => BRAM_SIZE,
         ADDR_WIDTH => ADDR_WIDTH)
    Port map(
         clk_a => clk,
         clk_b => clk,
         en_a => en_s,
         en_b => en_s,
         we_a => we_out(3 downto 0),
         we_b => we_zeros,
         data_output_a => bram_block2A_y, 
         data_input_a => demux_y_bram2,
         addr_a => bram_addr_A_out,
         data_output_b => bram_block2B_y,
         data_input_b => data_input_b_zeros, 
         addr_b => bram_addr_B_out
         );
         
    bram_block_y3_out: Dual_Port_BRAM
    generic map(
         WIDTH => WIDTH,
         BRAM_SIZE  => BRAM_SIZE,
         ADDR_WIDTH => ADDR_WIDTH)
    Port map(
         clk_a => clk,
         clk_b => clk,
         en_a => en_s,
         en_b => en_s,
         we_a => we_out(3 downto 0),
         we_b => we_zeros,
         data_output_a => bram_block3A_y, 
         data_input_a => demux_y_bram3,
         addr_a => bram_addr_A_out,
         data_output_b => bram_block3B_y,
         data_input_b => data_input_b_zeros, 
         addr_b => bram_addr_B_out
         );
         
    bram_block_y4_out: Dual_Port_BRAM
    generic map(
         WIDTH => WIDTH,
         BRAM_SIZE  => BRAM_SIZE,
         ADDR_WIDTH => ADDR_WIDTH)
    Port map(
         clk_a => clk,
         clk_b => clk,
         en_a => en_s,
         en_b => en_s,
         we_a => we_out(7 downto 4),
         we_b => we_zeros,
         data_output_a => bram_block4A_y, 
         data_input_a => demux_y_bram4,
         addr_a => bram_addr_A_out,
         data_output_b => bram_block4B_y,
         data_input_b => data_input_b_zeros, 
         addr_b => bram_addr_B_out
         );
    bram_block_y5_out: Dual_Port_BRAM
    generic map(
         WIDTH => WIDTH,
         BRAM_SIZE  => BRAM_SIZE,
         ADDR_WIDTH => ADDR_WIDTH)
    Port map(
         clk_a => clk,
         clk_b => clk,
         en_a => en_s,
         en_b => en_s,
         we_a => we_out(7 downto 4),
         we_b => we_zeros,
         data_output_a => bram_block5A_y, 
         data_input_a => demux_y_bram5,
         addr_a => bram_addr_A_out,
         data_output_b => bram_block5B_y,
         data_input_b => data_input_b_zeros, 
         addr_b => bram_addr_B_out
         );     
         
    bram_block_y6_out: Dual_Port_BRAM
    generic map(
         WIDTH => WIDTH,
         BRAM_SIZE  => BRAM_SIZE,
         ADDR_WIDTH => ADDR_WIDTH)
    Port map(
         clk_a => clk,
         clk_b => clk,
         en_a => en_s,
         en_b => en_s,
         we_a => we_out(7 downto 4),
         we_b => we_zeros,
         data_output_a => bram_block6A_y, 
         data_input_a => demux_y_bram6,
         addr_a => bram_addr_A_out,
         data_output_b => bram_block6B_y,
         data_input_b => data_input_b_zeros, 
         addr_b => bram_addr_B_out
         );
         
    bram_block_y7_out: Dual_Port_BRAM
    generic map(
         WIDTH => WIDTH,
         BRAM_SIZE  => BRAM_SIZE,
         ADDR_WIDTH => ADDR_WIDTH)
    Port map(
         clk_a => clk,
         clk_b => clk,
         en_a => en_s,
         en_b => en_s,
         we_a => we_out(7 downto 4),
         we_b => we_zeros,
         data_output_a => bram_block7A_y, 
         data_input_a => demux_y_bram7,
         addr_a => bram_addr_A_out,
         data_output_b => bram_block7B_y,
         data_input_b => data_input_b_zeros, 
         addr_b => bram_addr_B_out
         );
         
    bram_block_y8_out: Dual_Port_BRAM
    generic map(
         WIDTH => WIDTH,
         BRAM_SIZE  => BRAM_SIZE,
         ADDR_WIDTH => ADDR_WIDTH)
    Port map(
         clk_a => clk,
         clk_b => clk,
         en_a => en_s,
         en_b => en_s,
         we_a => we_out(11 downto 8),
         we_b => we_zeros,
         data_output_a => bram_block8A_y, 
         data_input_a => demux_y_bram8,
         addr_a => bram_addr_A_out,
         data_output_b => bram_block8B_y,
         data_input_b => data_input_b_zeros, 
         addr_b => bram_addr_B_out
         ); 
         
    bram_block_y9_out: Dual_Port_BRAM
    generic map(
         WIDTH => WIDTH,
         BRAM_SIZE  => BRAM_SIZE,
         ADDR_WIDTH => ADDR_WIDTH)
    Port map(
         clk_a => clk,
         clk_b => clk,
         en_a => en_s,
         en_b => en_s,
         we_a => we_out(11 downto 8),
         we_b => we_zeros,
         data_output_a => bram_block9A_y, 
         data_input_a => demux_y_bram9,
         addr_a => bram_addr_A_out,
         data_output_b => bram_block9B_y,
         data_input_b => data_input_b_zeros, 
         addr_b => bram_addr_B_out
         );   
         
    bram_block_y10_out: Dual_Port_BRAM
    generic map(
         WIDTH => WIDTH,
         BRAM_SIZE  => BRAM_SIZE,
         ADDR_WIDTH => ADDR_WIDTH)
    Port map(
         clk_a => clk,
         clk_b => clk,
         en_a => en_s,
         en_b => en_s,
         we_a => we_out(11 downto 8),
         we_b => we_zeros,
         data_output_a => bram_block10A_y, 
         data_input_a => demux_y_bram10,
         addr_a => bram_addr_A_out,
         data_output_b => bram_block10B_y,
         data_input_b => data_input_b_zeros, 
         addr_b => bram_addr_B_out
         );   
          
    bram_block_y11_out: Dual_Port_BRAM
    generic map(
         WIDTH => WIDTH,
         BRAM_SIZE  => BRAM_SIZE,
         ADDR_WIDTH => ADDR_WIDTH)
    Port map(
         clk_a => clk,
         clk_b => clk,
         en_a => en_s,
         en_b => en_s,
         we_a => we_out(11 downto 8),
         we_b => we_zeros,
         data_output_a => bram_block11A_y, 
         data_input_a => demux_y_bram11,
         addr_a => bram_addr_A_out,
         data_output_b => bram_block11B_y,
         data_input_b => data_input_b_zeros, 
         addr_b => bram_addr_B_out
         );  
     
    bram_block_y12_out: Dual_Port_BRAM
    generic map(
         WIDTH => WIDTH,
         BRAM_SIZE  => BRAM_SIZE,
         ADDR_WIDTH => ADDR_WIDTH)
    Port map(
         clk_a => clk,
         clk_b => clk,
         en_a => en_s,
         en_b => en_s,
         we_a => we_out(15 downto 12),
         we_b => we_zeros,
         data_output_a => bram_block12A_y, 
         data_input_a => demux_y_bram12,
         addr_a => bram_addr_A_out,
         data_output_b => bram_block12B_y,
         data_input_b => data_input_b_zeros, 
         addr_b => bram_addr_B_out
         );  
         
    bram_block_y13_out: Dual_Port_BRAM
    generic map(
         WIDTH => WIDTH,
         BRAM_SIZE  => BRAM_SIZE,
         ADDR_WIDTH => ADDR_WIDTH)
    Port map(
         clk_a => clk,
         clk_b => clk,
         en_a => en_s,
         en_b => en_s,
         we_a => we_out(15 downto 12),
         we_b => we_zeros,
         data_output_a => bram_block13A_y, 
         data_input_a => demux_y_bram13,
         addr_a => bram_addr_A_out,
         data_output_b => bram_block13B_y,
         data_input_b => data_input_b_zeros, 
         addr_b => bram_addr_B_out
         );  
         
    bram_block_y14_out: Dual_Port_BRAM
    generic map(
         WIDTH => WIDTH,
         BRAM_SIZE  => BRAM_SIZE,
         ADDR_WIDTH => ADDR_WIDTH)
    Port map(
         clk_a => clk,
         clk_b => clk,
         en_a => en_s,
         en_b => en_s,
         we_a => we_out(15 downto 12),
         we_b => we_zeros,
         data_output_a => bram_block14A_y, 
         data_input_a => demux_y_bram14,
         addr_a => bram_addr_A_out,
         data_output_b => bram_block14B_y,
         data_input_b => data_input_b_zeros, 
         addr_b => bram_addr_B_out
         );  
         
    bram_block_y15_out: Dual_Port_BRAM
    generic map(
         WIDTH => WIDTH,
         BRAM_SIZE  => BRAM_SIZE,
         ADDR_WIDTH => ADDR_WIDTH)
    Port map(
         clk_a => clk,
         clk_b => clk,
         en_a => en_s,
         en_b => en_s,
         we_a => we_out(15 downto 12),
         we_b => we_zeros,
         data_output_a => bram_block15A_y, 
         data_input_a => demux_y_bram15,
         addr_a => bram_addr_A_out,
         data_output_b => bram_block15B_y,
         data_input_b => data_input_b_zeros, 
         addr_b => bram_addr_B_out
         );  
    
 --mux out    
    mux_xA: mux16_1
        generic map(WIDTH => WIDTH)
        Port map(
          x0 => bram_block0A_x,
          x1 => bram_block1A_x,
          x2 => bram_block2A_x,
          x3 => bram_block3A_x,
          x4 => bram_block4A_x,
          x5 => bram_block5A_x,
          x6 => bram_block6A_x,
          x7 => bram_block7A_x,
          x8 => bram_block8A_x,
          x9 => bram_block9A_x,
          x10 => bram_block10A_x,
          x11 => bram_block11A_x,
          x12 => bram_block12A_x,
          x13 => bram_block13A_x,
          x14 => bram_block14A_x,
          x15 => bram_block15A_x,
          sel => sel_dram,
          y => data_out1_s(63 downto 32));
          
          
    mux_xB: mux16_1
        generic map(WIDTH => WIDTH)
        Port map(
          x0 => bram_block0B_x,
          x1 => bram_block1B_x,
          x2 => bram_block2B_x,
          x3 => bram_block3B_x,
          x4 => bram_block4B_x,
          x5 => bram_block5B_x,
          x6 => bram_block6B_x,
          x7 => bram_block7B_x,
          x8 => bram_block8B_x,
          x9 => bram_block9B_x,
          x10 => bram_block10B_x,
          x11 => bram_block11B_x,
          x12 => bram_block12B_x,
          x13 => bram_block13B_x,
          x14 => bram_block14B_x,
          x15 => bram_block15B_x,
          sel => sel_dram,
          y => data_out1_s(31 downto 0));
          
     data_out1 <= data_out1_s; 
     data_out1_s0 <= data_out1_s(15 downto 0);
     data_out1_s1 <= data_out1_s(31 downto 16);
     data_out1_s2 <= data_out1_s(47 downto 32);
     data_out1_s3 <= data_out1_s(63 downto 48);
          
     mux_yA: mux16_1
        generic map(WIDTH => WIDTH)
        Port map(
          x0 => bram_block0A_y,
          x1 => bram_block1A_y,
          x2 => bram_block2A_y,
          x3 => bram_block3A_y,
          x4 => bram_block4A_y,
          x5 => bram_block5A_y,
          x6 => bram_block6A_y,
          x7 => bram_block7A_y,
          x8 => bram_block8A_y,
          x9 => bram_block9A_y,
          x10 => bram_block10A_y,
          x11 => bram_block11A_y,
          x12 => bram_block12A_y,
          x13 => bram_block13A_y,
          x14 => bram_block14A_y,
          x15 => bram_block15A_y,
          sel => sel_dram,
          y => data_out2_s(63 downto 32)); 
         
          
    mux_yB: mux16_1
        generic map(WIDTH => WIDTH)
        Port map(
          x0 => bram_block0B_y,
          x1 => bram_block1B_y,
          x2 => bram_block2B_y,
          x3 => bram_block3B_y,
          x4 => bram_block4B_y,
          x5 => bram_block5B_y,
          x6 => bram_block6B_y,
          x7 => bram_block7B_y,
          x8 => bram_block8B_y,
          x9 => bram_block9B_y,
          x10 => bram_block10B_y,
          x11 => bram_block11B_y,
          x12 => bram_block12B_y,
          x13 => bram_block13B_y,
          x14 => bram_block14B_y,
          x15 => bram_block15B_y,
          sel => sel_dram,
          y => data_out2_s(31 downto 0));
          
     data_out2 <= data_out2_s;
     data_out2_s0 <= data_out2_s(15 downto 0);
     data_out2_s1 <= data_out2_s(31 downto 16);
     data_out2_s2 <= data_out2_s(47 downto 32);
     data_out2_s3 <= data_out2_s(63 downto 48);
     
--SIGNALS FOR VERIFICATION:----------------------------------------------------------------------
diax00_s <= demux_x_bram0(31 downto 16);
diax01_s <= demux_x_bram0(15 downto 0);

diax10_s <= demux_x_bram1(31 downto 16);
diax11_s <= demux_x_bram1(15 downto 0);

diax20_s <= demux_x_bram2(31 downto 16);
diax21_s <= demux_x_bram2(15 downto 0);

diax30_s <= demux_x_bram3(31 downto 16);
diax31_s <= demux_x_bram3(15 downto 0);

diay00_s <= demux_y_bram0(31 downto 16);
diay01_s <= demux_y_bram0(15 downto 0);

diay10_s <= demux_y_bram1(31 downto 16);
diay11_s <= demux_y_bram1(15 downto 0);

diay20_s <= demux_y_bram2(31 downto 16);
diay21_s <= demux_y_bram2(15 downto 0);

diay30_s <= demux_y_bram3(31 downto 16);
diay31_s <= demux_y_bram3(15 downto 0);

-------------------------------------------------------------------------------------------------

end Behavioral;
