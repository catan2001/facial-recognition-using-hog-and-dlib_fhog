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
    
--SIGNALS FOR VERIFICATION:------------------------------------------------------------------------
signal diax00_s, diax01_s, diax10_s, diax11_s, diax20_s, diax21_s, diax30_s, diax31_s: std_logic_vector(15 downto 0);
signal diay00_s, diay01_s, diay10_s, diay11_s, diay20_s, diay21_s, diay30_s, diay31_s: std_logic_vector(15 downto 0);
signal doax00_s, dobx00_s, doax01_s, dobx01_s: std_logic_vector(15 downto 0);
signal data_out1_s0, data_out1_s1, data_out1_s2, data_out1_s3: std_logic_vector(15 downto 0);
signal data_out2_s0, data_out2_s1, data_out2_s2, data_out2_s3: std_logic_vector(15 downto 0);
----------------------------------------------------------------------------------------------------
  component demux_in is
     generic (WIDTH: natural := 32);
      Port ( 
        sel_bram_in: in std_logic_vector(3 downto 0);
        data_in1: in std_logic_vector(31 downto 0);
        data_in2: in std_logic_vector(31 downto 0);
        data_in3: in std_logic_vector(31 downto 0);
        data_in4: in std_logic_vector(31 downto 0);
        bram_blockA0: out std_logic_vector(31 downto 0);
        bram_blockB0: out std_logic_vector(31 downto 0);
        bram_blockA1: out std_logic_vector(31 downto 0);
        bram_blockB1: out std_logic_vector(31 downto 0);
        bram_blockA2: out std_logic_vector(31 downto 0);
        bram_blockB2: out std_logic_vector(31 downto 0);
        bram_blockA3: out std_logic_vector(31 downto 0);
        bram_blockB3: out std_logic_vector(31 downto 0);
        bram_blockA4: out std_logic_vector(31 downto 0);
        bram_blockB4: out std_logic_vector(31 downto 0);
        bram_blockA5: out std_logic_vector(31 downto 0);
        bram_blockB5: out std_logic_vector(31 downto 0);
        bram_blockA6: out std_logic_vector(31 downto 0);
        bram_blockB6: out std_logic_vector(31 downto 0);
        bram_blockA7: out std_logic_vector(31 downto 0);
        bram_blockB7: out std_logic_vector(31 downto 0);
        bram_blockA8: out std_logic_vector(31 downto 0);
        bram_blockB8: out std_logic_vector(31 downto 0);
        bram_blockA9: out std_logic_vector(31 downto 0);
        bram_blockB9: out std_logic_vector(31 downto 0);
        bram_blockA10: out std_logic_vector(31 downto 0);
        bram_blockB10: out std_logic_vector(31 downto 0);
        bram_blockA11: out std_logic_vector(31 downto 0);
        bram_blockB11: out std_logic_vector(31 downto 0);
        bram_blockA12: out std_logic_vector(31 downto 0);
        bram_blockB12: out std_logic_vector(31 downto 0);
        bram_blockA13: out std_logic_vector(31 downto 0);
        bram_blockB13: out std_logic_vector(31 downto 0);
        bram_blockA14: out std_logic_vector(31 downto 0);
        bram_blockB14: out std_logic_vector(31 downto 0);
        bram_blockA15: out std_logic_vector(31 downto 0);
        bram_blockB15: out std_logic_vector(31 downto 0));
    end component;
    
 component bram is
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
 end component;
    
    component mux_filter is
    generic(WIDTH:natural:=32);
      Port ( 
      sel_filter: in std_logic_vector(2 downto 0);
      bram_outA0: in std_logic_vector(31 downto 0);
      bram_outB0: in std_logic_vector(31 downto 0);
      bram_outA1: in std_logic_vector(31 downto 0);
      bram_outB1: in std_logic_vector(31 downto 0);
      bram_outA2: in std_logic_vector(31 downto 0);
      bram_outB2: in std_logic_vector(31 downto 0);
      bram_outA3: in std_logic_vector(31 downto 0);
      bram_outB3: in std_logic_vector(31 downto 0);
      bram_outA4: in std_logic_vector(31 downto 0);
      bram_outB4: in std_logic_vector(31 downto 0);
      bram_outA5: in std_logic_vector(31 downto 0);
      bram_outB5: in std_logic_vector(31 downto 0);
      bram_outA6: in std_logic_vector(31 downto 0);
      bram_outB6: in std_logic_vector(31 downto 0);
      bram_outA7: in std_logic_vector(31 downto 0);
      bram_outB7: in std_logic_vector(31 downto 0);
      bram_outA8: in std_logic_vector(31 downto 0);
      bram_outB8: in std_logic_vector(31 downto 0);
      bram_outA9: in std_logic_vector(31 downto 0);
      bram_outB9: in std_logic_vector(31 downto 0);
      bram_outA10: in std_logic_vector(31 downto 0);
      bram_outB10: in std_logic_vector(31 downto 0);
      bram_outA11: in std_logic_vector(31 downto 0);
      bram_outB11: in std_logic_vector(31 downto 0);
      bram_outA12: in std_logic_vector(31 downto 0);
      bram_outB12: in std_logic_vector(31 downto 0);
      bram_outA13: in std_logic_vector(31 downto 0);
      bram_outB13: in std_logic_vector(31 downto 0);
      bram_outA14: in std_logic_vector(31 downto 0);
      bram_outB14: in std_logic_vector(31 downto 0);
      bram_outA15: in std_logic_vector(31 downto 0);
      bram_outB15: in std_logic_vector(31 downto 0);
      filter_inA0: out std_logic_vector(31 downto 0);
      filter_inB0: out std_logic_vector(31 downto 0);
      filter_inA1: out std_logic_vector(31 downto 0);
      filter_inB1: out std_logic_vector(31 downto 0);
      filter_inA2: out std_logic_vector(31 downto 0);
      filter_inB2: out std_logic_vector(31 downto 0);
      filter_inA3: out std_logic_vector(31 downto 0);
      filter_inB3: out std_logic_vector(31 downto 0);
      filter_inA4: out std_logic_vector(31 downto 0);
      filter_inB4: out std_logic_vector(31 downto 0);
      filter_inA5: out std_logic_vector(31 downto 0);
      filter_inB5: out std_logic_vector(31 downto 0));
    end component;    
       
    component mux2_1 is
    generic(WIDTH:natural:=32);
    Port (x0: in std_logic_vector(WIDTH-1 downto 0);
          x1: in std_logic_vector(WIDTH-1 downto 0);
          sel: in std_logic;
          y: out std_logic_vector(WIDTH-1 downto 0));
    end component;
    
    component core_top is
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
    
    component demux_out
      generic(WIDTH:natural:=32);
      Port ( 
        sel: in std_logic_vector(2 downto 0);
        filter_out1: in std_logic_vector(31 downto 0);
        filter_out2: in std_logic_vector(31 downto 0);
        filter_out3: in std_logic_vector(31 downto 0);
        filter_out4: in std_logic_vector(31 downto 0);
        bram_in0: out std_logic_vector(31 downto 0);
        bram_in1: out std_logic_vector(31 downto 0);
        bram_in2: out std_logic_vector(31 downto 0);
        bram_in3: out std_logic_vector(31 downto 0);
        bram_in4: out std_logic_vector(31 downto 0);
        bram_in5: out std_logic_vector(31 downto 0);
        bram_in6: out std_logic_vector(31 downto 0);
        bram_in7: out std_logic_vector(31 downto 0);
        bram_in8: out std_logic_vector(31 downto 0);
        bram_in9: out std_logic_vector(31 downto 0);
        bram_in10: out std_logic_vector(31 downto 0);
        bram_in11: out std_logic_vector(31 downto 0);
        bram_in12: out std_logic_vector(31 downto 0);
        bram_in13: out std_logic_vector(31 downto 0);
        bram_in14: out std_logic_vector(31 downto 0);
        bram_in15: out std_logic_vector(31 downto 0));  
    end component;    
    
    component mux_out
    generic(WIDTH:natural:=32);
    Port ( 
        sel: in std_logic_vector(4 downto 0);
        bram_block0A: in std_logic_vector(31 downto 0);
        bram_block0B: in std_logic_vector(31 downto 0);
        bram_block1A: in std_logic_vector(31 downto 0);
        bram_block1B: in std_logic_vector(31 downto 0);
        bram_block2A: in std_logic_vector(31 downto 0);
        bram_block2B: in std_logic_vector(31 downto 0);
        bram_block3A: in std_logic_vector(31 downto 0);
        bram_block3B: in std_logic_vector(31 downto 0);
        bram_block4A: in std_logic_vector(31 downto 0);
        bram_block4B: in std_logic_vector(31 downto 0);
        bram_block5A: in std_logic_vector(31 downto 0);
        bram_block5B: in std_logic_vector(31 downto 0);
        bram_block6A: in std_logic_vector(31 downto 0);
        bram_block6B: in std_logic_vector(31 downto 0);
        bram_block7A: in std_logic_vector(31 downto 0);
        bram_block7B: in std_logic_vector(31 downto 0);
        bram_block8A: in std_logic_vector(31 downto 0);
        bram_block8B: in std_logic_vector(31 downto 0);
        bram_block9A: in std_logic_vector(31 downto 0);
        bram_block9B: in std_logic_vector(31 downto 0);
        bram_block10A: in std_logic_vector(31 downto 0);
        bram_block10B: in std_logic_vector(31 downto 0);
        bram_block11A: in std_logic_vector(31 downto 0);
        bram_block11B: in std_logic_vector(31 downto 0);
        bram_block12A: in std_logic_vector(31 downto 0);
        bram_block12B: in std_logic_vector(31 downto 0);
        bram_block13A: in std_logic_vector(31 downto 0);
        bram_block13B: in std_logic_vector(31 downto 0);
        bram_block14A: in std_logic_vector(31 downto 0);
        bram_block14B: in std_logic_vector(31 downto 0);
        bram_block15A: in std_logic_vector(31 downto 0);
        bram_block15B: in std_logic_vector(31 downto 0);
        data_out1: out std_logic_vector(31 downto 0);
        data_out2: out std_logic_vector(31 downto 0));   
    end component;
begin

--demux before bram block
demuxIn: demux_in
     generic map(WIDTH => WIDTH)
      Port map( 
        sel_bram_in => sel_bram_in,
        data_in1 => data_in1(63 downto 32),
        data_in2 => data_in1(31 downto 0),
        data_in3 => data_in2(63 downto 32),
        data_in4 => data_in2(31 downto 0),
        bram_blockA0 => demux1_out_bram_in0,
        bram_blockB0 => demux2_out_bram_in0,
        bram_blockA1 => demux3_out_bram_in0,
        bram_blockB1 => demux4_out_bram_in0,
        bram_blockA2 => demux1_out_bram_in1,
        bram_blockB2 => demux2_out_bram_in1,
        bram_blockA3 => demux3_out_bram_in1,
        bram_blockB3 => demux4_out_bram_in1,
        bram_blockA4 => demux1_out_bram_in2,
        bram_blockB4 => demux2_out_bram_in2,
        bram_blockA5 => demux3_out_bram_in2,
        bram_blockB5 => demux4_out_bram_in2,
        bram_blockA6 => demux1_out_bram_in3,
        bram_blockB6 => demux2_out_bram_in3,
        bram_blockA7 => demux3_out_bram_in3,
        bram_blockB7 => demux4_out_bram_in3,
        bram_blockA8 => demux1_out_bram_in4,
        bram_blockB8 => demux2_out_bram_in4,
        bram_blockA9 => demux3_out_bram_in4,
        bram_blockB9 => demux4_out_bram_in4,
        bram_blockA10 => demux1_out_bram_in5,
        bram_blockB10 => demux2_out_bram_in5,
        bram_blockA11 => demux3_out_bram_in5,
        bram_blockB11 => demux4_out_bram_in5,
        bram_blockA12 => demux1_out_bram_in6,
        bram_blockB12 => demux2_out_bram_in6,
        bram_blockA13 => demux3_out_bram_in6,
        bram_blockB13 => demux4_out_bram_in6,
        bram_blockA14 => demux1_out_bram_in7,
        bram_blockB14 => demux2_out_bram_in7,
        bram_blockA15 => demux3_out_bram_in7,
        bram_blockB15 => demux4_out_bram_in7);
             
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
            
 bram_in: bram
   Port map( 
    clk => clk,
    en => '1',
    we_a0 => we_in(3 downto 0),
    we_a1 => we_in(3 downto 0),
    we_a2 => we_in(7 downto 4),
    we_a3 => we_in(7 downto 4),
    we_a4 => we_in(11 downto 8),
    we_a5 => we_in(11 downto 8),
    we_a6 => we_in(15 downto 12),
    we_a7 => we_in(15 downto 12),
    we_a8 => we_in(19 downto 16),
    we_a9 => we_in(19 downto 16),
    we_a10 => we_in(23 downto 20),
    we_a11 => we_in(23 downto 20),
    we_a12 => we_in(27 downto 24),
    we_a13 => we_in(27 downto 24),
    we_a14 => we_in(31 downto 28),
    we_a15 => we_in(31 downto 28),
    we_b0 => we_in(3 downto 0),
    we_b1 => we_in(3 downto 0),
    we_b2 => we_in(7 downto 4),
    we_b3 => we_in(7 downto 4),
    we_b4 => we_in(11 downto 8),
    we_b5 => we_in(11 downto 8),
    we_b6 => we_in(15 downto 12),
    we_b7 => we_in(15 downto 12),
    we_b8 => we_in(19 downto 16),
    we_b9 => we_in(19 downto 16),
    we_b10 => we_in(23 downto 20),
    we_b11 => we_in(23 downto 20),
    we_b12 => we_in(27 downto 24),
    we_b13 => we_in(27 downto 24),
    we_b14 => we_in(31 downto 28),
    we_b15 => we_in(31 downto 28),
    --INPUT SIGNALS
    bram_inA0 => mux0_out_bramA_in0,
    bram_inB0 => mux0_out_bramB_in0,
    bram_inA1 => mux1_out_bramA_in1,
    bram_inB1 => mux1_out_bramB_in1,
    bram_inA2 => mux2_out_bramA_in2,
    bram_inB2 => mux2_out_bramB_in2,
    bram_inA3 => mux3_out_bramA_in3,
    bram_inB3 => mux3_out_bramB_in3,
    bram_inA4 => demux1_out_bram_in2,
    bram_inB4 => demux2_out_bram_in2,
    bram_inA5 => demux3_out_bram_in2,
    bram_inB5 => demux4_out_bram_in2,
    bram_inA6 => demux1_out_bram_in3,
    bram_inB6 => demux2_out_bram_in3,
    bram_inA7 => demux3_out_bram_in3,
    bram_inB7 => demux4_out_bram_in3,
    bram_inA8 => demux1_out_bram_in4,
    bram_inB8 => demux2_out_bram_in4,
    bram_inA9 => demux3_out_bram_in4,
    bram_inB9 => demux4_out_bram_in4,
    bram_inA10 => demux1_out_bram_in5,
    bram_inB10 => demux2_out_bram_in5,
    bram_inA11 => demux3_out_bram_in5,
    bram_inB11 => demux4_out_bram_in5,
    bram_inA12 => demux1_out_bram_in6,
    bram_inB12 => demux2_out_bram_in6,
    bram_inA13 => demux3_out_bram_in6,
    bram_inB13 => demux4_out_bram_in6,
    bram_inA14 => demux1_out_bram_in7,
    bram_inB14 => demux2_out_bram_in7,
    bram_inA15 => demux3_out_bram_in7,
    bram_inB15 => demux4_out_bram_in7,
    --INPUT ADDR
    bram_addrA0 => bram_addrA_l_in,
    bram_addrA1 => bram_addrA_l_in,
    bram_addrA2 => bram_addrA_l_in,
    bram_addrA3 => bram_addrA_l_in,
    bram_addrA4 => bram_addrA_h_in,
    bram_addrA5 => bram_addrA_h_in,
    bram_addrA6 => bram_addrA_h_in,
    bram_addrA7 => bram_addrA_h_in,
    bram_addrA8 => bram_addrA_h_in,
    bram_addrA9 => bram_addrA_h_in,
    bram_addrA10 => bram_addrA_h_in,
    bram_addrA11 => bram_addrA_h_in,
    bram_addrA12 => bram_addrA12_in,
    bram_addrA13 => bram_addrA12_in,
    bram_addrA14 => bram_addrA12_in,
    bram_addrA15 => bram_addrA12_in,
    bram_addrB0 => bram_addrB_l_in,
    bram_addrB1 => bram_addrB_l_in,
    bram_addrB2 => bram_addrB_l_in,
    bram_addrB3 => bram_addrB_l_in,
    bram_addrB4 => bram_addrB_h_in,
    bram_addrB5 => bram_addrB_h_in,
    bram_addrB6 => bram_addrB_h_in,
    bram_addrB7 => bram_addrB_h_in,
    bram_addrB8 => bram_addrB_h_in,
    bram_addrB9 => bram_addrB_h_in,
    bram_addrB10 => bram_addrB_h_in,
    bram_addrB11 => bram_addrB_h_in,
    bram_addrB12 => bram_addrB12_in,
    bram_addrB13 => bram_addrB12_in,
    bram_addrB14 => bram_addrB12_in,
    bram_addrB15 => bram_addrB12_in,
    --OUTPUT SIGNALS
    bram_outA0 => bram_block0A_out_mux_in,
    bram_outB0 => bram_block0B_out_mux_in,
    bram_outA1 => bram_block1A_out_mux_in,
    bram_outB1 => bram_block1B_out_mux_in,
    bram_outA2 => bram_block2A_out_mux_in,
    bram_outB2 => bram_block2B_out_mux_in,
    bram_outA3 => bram_block3A_out_mux_in,
    bram_outB3 => bram_block3B_out_mux_in,
    bram_outA4 => bram_block4A_out_mux_in,
    bram_outB4 => bram_block4B_out_mux_in,
    bram_outA5 => bram_block5A_out_mux_in,
    bram_outB5 => bram_block5B_out_mux_in,
    bram_outA6 => bram_block6A_out_mux_in,
    bram_outB6 => bram_block6B_out_mux_in,
    bram_outA7 => bram_block7A_out_mux_in,
    bram_outB7 => bram_block7B_out_mux_in,
    bram_outA8 => bram_block8A_out_mux_in,
    bram_outB8 => bram_block8B_out_mux_in,
    bram_outA9 => bram_block9A_out_mux_in,
    bram_outB9 => bram_block9B_out_mux_in,
    bram_outA10 => bram_block10A_out_mux_in, 
    bram_outB10 => bram_block10B_out_mux_in,
    bram_outA11 => bram_block11A_out_mux_in,
    bram_outB11 => bram_block11B_out_mux_in,
    bram_outA12 => bram_block12A_out_mux_in,
    bram_outB12 => bram_block12B_out_mux_in,
    bram_outA13 => bram_block13A_out_mux_in,
    bram_outB13 => bram_block13B_out_mux_in,
    bram_outA14 => bram_block14A_out_mux_in,
    bram_outB14 => bram_block14B_out_mux_in,
    bram_outA15 => bram_block15A_out_mux_in,
    bram_outB15 => bram_block15B_out_mux_in);
                     
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
    
  --mux before core 
  muxIn: mux_filter
  generic map(WIDTH=>WIDTH)
   Port map( 
      sel_filter => sel_filter,
      bram_outA0 => bram_block0A_out_mux_in,
      bram_outB0 => bram_block0B_out_mux_in,
      bram_outA1 => bram_block1A_out_mux_in,
      bram_outB1 => bram_block1B_out_mux_in,
      bram_outA2 => bram_block2A_out_mux_in,
      bram_outB2 => bram_block2B_out_mux_in,
      bram_outA3 => bram_block3A_out_mux_in,
      bram_outB3 => bram_block3B_out_mux_in,
      bram_outA4 => bram_block4A_out_mux_in,
      bram_outB4 => bram_block4B_out_mux_in,
      bram_outA5 => bram_block5A_out_mux_in,
      bram_outB5 => bram_block5B_out_mux_in,
      bram_outA6 => bram_block6A_out_mux_in,
      bram_outB6 => bram_block6B_out_mux_in,
      bram_outA7 => bram_block7A_out_mux_in,
      bram_outB7 => bram_block7B_out_mux_in,
      bram_outA8 => bram_block8A_out_mux_in,
      bram_outB8 => bram_block8B_out_mux_in,
      bram_outA9 => bram_block9A_out_mux_in,
      bram_outB9 => bram_block9B_out_mux_in,
      bram_outA10 => bram_block10A_out_mux_in,
      bram_outB10 => bram_block10B_out_mux_in,
      bram_outA11 => bram_block11A_out_mux_in,
      bram_outB11 => bram_block11B_out_mux_in,
      bram_outA12 => bram_block12A_out_mux_in,
      bram_outB12 => bram_block12B_out_mux_in,
      bram_outA13 => bram_block13A_out_mux_in,
      bram_outB13 => bram_block13B_out_mux_in,
      bram_outA14 => bram_block14A_out_mux_in,
      bram_outB14 => bram_block14B_out_mux_in,
      bram_outA15 => bram_block15A_out_mux_in,
      bram_outB15 => bram_block15B_out_mux_in,
      filter_inA0 => muxA0_out_core_in,
      filter_inB0 => muxB0_out_core_in,
      filter_inA1 => muxA1_out_core_in,
      filter_inB1 => muxB1_out_core_in,
      filter_inA2 => muxA2_out_core_in,
      filter_inB2 => muxB2_out_core_in,
      filter_inA3 => muxA3_out_core_in,
      filter_inB3 => muxB3_out_core_in,
      filter_inA4 => muxA4_out_core_in,
      filter_inB4 => muxB4_out_core_in,
      filter_inA5 => muxA5_out_core_in,
      filter_inB5 => muxB5_out_core_in);
        
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
    demuxOutX: demux_out
      generic map(WIDTH => WIDTH)
      Port map( 
        sel => sel_bram_out,
        filter_out1 => filter_x01_to_demux,
        filter_out2 => filter_x23_to_demux,
        filter_out3 => filter_x45_to_demux,
        filter_out4 => filter_x67_to_demux,
        bram_in0 => demux_x_bram0,
        bram_in1 => demux_x_bram1,
        bram_in2 => demux_x_bram2,
        bram_in3 => demux_x_bram3,
        bram_in4 => demux_x_bram4,
        bram_in5 => demux_x_bram5,
        bram_in6 => demux_x_bram6,
        bram_in7 => demux_x_bram7,
        bram_in8 => demux_x_bram8,
        bram_in9 => demux_x_bram9,
        bram_in10 => demux_x_bram10,
        bram_in11 => demux_x_bram11,
        bram_in12 => demux_x_bram12,
        bram_in13 => demux_x_bram13,
        bram_in14 => demux_x_bram14,
        bram_in15 => demux_x_bram15);  
       
     demuxOutY: demux_out
      generic map(WIDTH => WIDTH)
      Port map( 
        sel => sel_bram_out,
        filter_out1 => filter_y01_to_demux,
        filter_out2 => filter_y23_to_demux,
        filter_out3 => filter_y45_to_demux,
        filter_out4 => filter_y67_to_demux,
        bram_in0 => demux_y_bram0,
        bram_in1 => demux_y_bram1,
        bram_in2 => demux_y_bram2,
        bram_in3 => demux_y_bram3,
        bram_in4 => demux_y_bram4,
        bram_in5 => demux_y_bram5,
        bram_in6 => demux_y_bram6,
        bram_in7 => demux_y_bram7,
        bram_in8 => demux_y_bram8,
        bram_in9 => demux_y_bram9,
        bram_in10 => demux_y_bram10,
        bram_in11 => demux_y_bram11,
        bram_in12 => demux_y_bram12,
        bram_in13 => demux_y_bram13,
        bram_in14 => demux_y_bram14,
        bram_in15 => demux_y_bram15);    
          
    ---bram_block_x     
    bram_outx: bram
    Port map( 
    clk => clk,
    en => '1',
    we_a0 => we_out(3 downto 0),
    we_a1 => we_out(3 downto 0),
    we_a2 => we_out(3 downto 0),
    we_a3 => we_out(3 downto 0),
    we_a4 => we_out(7 downto 4),
    we_a5 => we_out(7 downto 4),
    we_a6 => we_out(7 downto 4),
    we_a7 => we_out(7 downto 4),
    we_a8 => we_out(11 downto 8),
    we_a9 => we_out(11 downto 8),
    we_a10 => we_out(11 downto 8),
    we_a11 => we_out(11 downto 8),
    we_a12 => we_out(15 downto 12),
    we_a13 => we_out(15 downto 12),
    we_a14 => we_out(15 downto 12),
    we_a15 => we_out(15 downto 12),
    we_b0 => (others => '0'),
    we_b1 => (others => '0'),
    we_b2 => (others => '0'),
    we_b3 => (others => '0'),
    we_b4 => (others => '0'),
    we_b5 => (others => '0'),
    we_b6 => (others => '0'),
    we_b7 => (others => '0'),
    we_b8 => (others => '0'),
    we_b9 => (others => '0'),
    we_b10 => (others => '0'),
    we_b11 => (others => '0'),
    we_b12 => (others => '0'),
    we_b13 => (others => '0'),
    we_b14 => (others => '0'),
    we_b15 => (others => '0'),
    --INPUT SIGNALS
    bram_inA0 => demux_x_bram0,
    bram_inB0 => (others => '0'),
    bram_inA1 => demux_x_bram1,
    bram_inB1 => (others => '0'),
    bram_inA2 => demux_x_bram2,
    bram_inB2 => (others => '0'),
    bram_inA3 => demux_x_bram3,
    bram_inB3 => (others => '0'),
    bram_inA4 => demux_x_bram4,
    bram_inB4 => (others => '0'),
    bram_inA5 => demux_x_bram5,
    bram_inB5 => (others => '0'),
    bram_inA6 => demux_x_bram6,
    bram_inB6 => (others => '0'),
    bram_inA7 => demux_x_bram7,
    bram_inB7 => (others => '0'),
    bram_inA8 => demux_x_bram8,
    bram_inB8 => (others => '0'),
    bram_inA9 => demux_x_bram9,
    bram_inB9 => (others => '0'),
    bram_inA10 => demux_x_bram10,
    bram_inB10 => (others => '0'),
    bram_inA11 => demux_x_bram11,
    bram_inB11 => (others => '0'),
    bram_inA12 => demux_x_bram12,
    bram_inB12 => (others => '0'),
    bram_inA13 => demux_x_bram13,
    bram_inB13 => (others => '0'),
    bram_inA14 => demux_x_bram14,
    bram_inB14 => (others => '0'),
    bram_inA15 => demux_x_bram15,
    bram_inB15 => (others => '0'),
    --INPUT ADDR
    bram_addrA0 => bram_addr_A_out,
    bram_addrA1 => bram_addr_A_out,
    bram_addrA2 => bram_addr_A_out,
    bram_addrA3 => bram_addr_A_out,
    bram_addrA4 => bram_addr_A_out,
    bram_addrA5 => bram_addr_A_out,
    bram_addrA6 => bram_addr_A_out,
    bram_addrA7 => bram_addr_A_out,
    bram_addrA8 => bram_addr_A_out,
    bram_addrA9 => bram_addr_A_out,
    bram_addrA10 => bram_addr_A_out,
    bram_addrA11 => bram_addr_A_out,
    bram_addrA12 => bram_addr_A_out,
    bram_addrA13 => bram_addr_A_out,
    bram_addrA14 => bram_addr_A_out,
    bram_addrA15 => bram_addr_A_out,
    bram_addrB0 => bram_addr_B_out,
    bram_addrB1 => bram_addr_B_out,
    bram_addrB2 => bram_addr_B_out,
    bram_addrB3 => bram_addr_B_out,
    bram_addrB4 => bram_addr_B_out,
    bram_addrB5 => bram_addr_B_out,
    bram_addrB6 => bram_addr_B_out,
    bram_addrB7 => bram_addr_B_out,
    bram_addrB8 => bram_addr_B_out,
    bram_addrB9 => bram_addr_B_out,
    bram_addrB10 => bram_addr_B_out,
    bram_addrB11 => bram_addr_B_out,
    bram_addrB12 => bram_addr_B_out,
    bram_addrB13 => bram_addr_B_out,
    bram_addrB14 => bram_addr_B_out,
    bram_addrB15 => bram_addr_B_out,
    --OUTPUT SIGNALS
    bram_outA0 => bram_block0A_x,
    bram_outB0 => bram_block0B_x,
    bram_outA1 => bram_block1A_x,
    bram_outB1 => bram_block1B_x,
    bram_outA2 => bram_block2A_x,
    bram_outB2 => bram_block2B_x,
    bram_outA3 => bram_block3A_x,
    bram_outB3 => bram_block3B_x,
    bram_outA4 => bram_block4A_x,
    bram_outB4 => bram_block4B_x,
    bram_outA5 => bram_block5A_x,
    bram_outB5 => bram_block5B_x,
    bram_outA6 => bram_block6A_x,
    bram_outB6 => bram_block6B_x,
    bram_outA7 => bram_block7A_x,
    bram_outB7 => bram_block7B_x,
    bram_outA8 => bram_block8A_x,
    bram_outB8 => bram_block8B_x,
    bram_outA9 => bram_block9A_x,
    bram_outB9 => bram_block9B_x,
    bram_outA10 => bram_block10A_x,
    bram_outB10 => bram_block10B_x,
    bram_outA11 => bram_block11A_x,
    bram_outB11 => bram_block11B_x,
    bram_outA12 => bram_block12A_x,
    bram_outB12 => bram_block12B_x,
    bram_outA13 => bram_block13A_x,
    bram_outB13 => bram_block13B_x,
    bram_outA14 => bram_block14A_x,
    bram_outB14 => bram_block14B_x,
    bram_outA15 => bram_block15A_x,
    bram_outB15 => bram_block15B_x);      

    --signals for verification  
    doax00_s <= bram_block0A_x(31 downto 16);
    doax01_s <= bram_block0A_x(15 downto 0);
    dobx00_s <= bram_block0B_x(31 downto 16);
    dobx01_s <= bram_block0B_x(15 downto 0);
  
    ---bram_block_y  
   bram_outy: bram
    Port map( 
    clk => clk,
    en => '1',
    we_a0 => we_out(3 downto 0),
    we_a1 => we_out(3 downto 0),
    we_a2 => we_out(3 downto 0),
    we_a3 => we_out(3 downto 0),
    we_a4 => we_out(7 downto 4),
    we_a5 => we_out(7 downto 4),
    we_a6 => we_out(7 downto 4),
    we_a7 => we_out(7 downto 4),
    we_a8 => we_out(11 downto 8),
    we_a9 => we_out(11 downto 8),
    we_a10 => we_out(11 downto 8),
    we_a11 => we_out(11 downto 8),
    we_a12 => we_out(15 downto 12),
    we_a13 => we_out(15 downto 12),
    we_a14 => we_out(15 downto 12),
    we_a15 => we_out(15 downto 12),
    we_b0 => (others => '0'),
    we_b1 => (others => '0'),
    we_b2 => (others => '0'),
    we_b3 => (others => '0'),
    we_b4 => (others => '0'),
    we_b5 => (others => '0'),
    we_b6 => (others => '0'),
    we_b7 => (others => '0'),
    we_b8 => (others => '0'),
    we_b9 => (others => '0'),
    we_b10 => (others => '0'),
    we_b11 => (others => '0'),
    we_b12 => (others => '0'),
    we_b13 => (others => '0'),
    we_b14 => (others => '0'),
    we_b15 => (others => '0'),
    --INPUT SIGNALS
    bram_inA0 => demux_y_bram0,
    bram_inB0 => (others => '0'),
    bram_inA1 => demux_y_bram1,
    bram_inB1 => (others => '0'),
    bram_inA2 => demux_y_bram2,
    bram_inB2 => (others => '0'),
    bram_inA3 => demux_y_bram3,
    bram_inB3 => (others => '0'),
    bram_inA4 => demux_y_bram4,
    bram_inB4 => (others => '0'),
    bram_inA5 => demux_y_bram5,
    bram_inB5 => (others => '0'),
    bram_inA6 => demux_y_bram6,
    bram_inB6 => (others => '0'),
    bram_inA7 => demux_y_bram7,
    bram_inB7 => (others => '0'),
    bram_inA8 => demux_y_bram8,
    bram_inB8 => (others => '0'),
    bram_inA9 => demux_y_bram9,
    bram_inB9 => (others => '0'),
    bram_inA10 => demux_y_bram10,
    bram_inB10 => (others => '0'),
    bram_inA11 => demux_y_bram11,
    bram_inB11 => (others => '0'),
    bram_inA12 => demux_y_bram12,
    bram_inB12 => (others => '0'),
    bram_inA13 => demux_y_bram13,
    bram_inB13 => (others => '0'),
    bram_inA14 => demux_y_bram14,
    bram_inB14 => (others => '0'),
    bram_inA15 => demux_y_bram15,
    bram_inB15 => (others => '0'),
    --INPUT ADDR
    bram_addrA0 => bram_addr_A_out,
    bram_addrA1 => bram_addr_A_out,
    bram_addrA2 => bram_addr_A_out,
    bram_addrA3 => bram_addr_A_out,
    bram_addrA4 => bram_addr_A_out,
    bram_addrA5 => bram_addr_A_out,
    bram_addrA6 => bram_addr_A_out,
    bram_addrA7 => bram_addr_A_out,
    bram_addrA8 => bram_addr_A_out,
    bram_addrA9 => bram_addr_A_out,
    bram_addrA10 => bram_addr_A_out,
    bram_addrA11 => bram_addr_A_out,
    bram_addrA12 => bram_addr_A_out,
    bram_addrA13 => bram_addr_A_out,
    bram_addrA14 => bram_addr_A_out,
    bram_addrA15 => bram_addr_A_out,
    bram_addrB0 => bram_addr_B_out,
    bram_addrB1 => bram_addr_B_out,
    bram_addrB2 => bram_addr_B_out,
    bram_addrB3 => bram_addr_B_out,
    bram_addrB4 => bram_addr_B_out,
    bram_addrB5 => bram_addr_B_out,
    bram_addrB6 => bram_addr_B_out,
    bram_addrB7 => bram_addr_B_out,
    bram_addrB8 => bram_addr_B_out,
    bram_addrB9 => bram_addr_B_out,
    bram_addrB10 => bram_addr_B_out,
    bram_addrB11 => bram_addr_B_out,
    bram_addrB12 => bram_addr_B_out,
    bram_addrB13 => bram_addr_B_out,
    bram_addrB14 => bram_addr_B_out,
    bram_addrB15 => bram_addr_B_out,
    --OUTPUT SIGNALS
    bram_outA0 => bram_block0A_y,
    bram_outB0 => bram_block0B_y,
    bram_outA1 => bram_block1A_y,
    bram_outB1 => bram_block1B_y,
    bram_outA2 => bram_block2A_y,
    bram_outB2 => bram_block2B_y,
    bram_outA3 => bram_block3A_y,
    bram_outB3 => bram_block3B_y,
    bram_outA4 => bram_block4A_y,
    bram_outB4 => bram_block4B_y,
    bram_outA5 => bram_block5A_y,
    bram_outB5 => bram_block5B_y,
    bram_outA6 => bram_block6A_y,
    bram_outB6 => bram_block6B_y,
    bram_outA7 => bram_block7A_y,
    bram_outB7 => bram_block7B_y,
    bram_outA8 => bram_block8A_y,
    bram_outB8 => bram_block8B_y,
    bram_outA9 => bram_block9A_y,
    bram_outB9 => bram_block9B_y,
    bram_outA10 => bram_block10A_y,
    bram_outB10 => bram_block10B_y,
    bram_outA11 => bram_block11A_y,
    bram_outB11 => bram_block11B_y,
    bram_outA12 => bram_block12A_y,
    bram_outB12 => bram_block12B_y,
    bram_outA13 => bram_block13A_y,
    bram_outB13 => bram_block13B_y,
    bram_outA14 => bram_block14A_y,
    bram_outB14 => bram_block14B_y,
    bram_outA15 => bram_block15A_y,
    bram_outB15 => bram_block15B_y); 
                  
 --mux out    
 mux_x: mux_out
    generic map(WIDTH => WIDTH)
    Port map( 
        sel => sel_dram,
        bram_block0A => bram_block0A_x,
        bram_block0B => bram_block0B_x,
        bram_block1A => bram_block1A_x,
        bram_block1B => bram_block1B_x,
        bram_block2A => bram_block2A_x,
        bram_block2B => bram_block2B_x,
        bram_block3A => bram_block3A_x,
        bram_block3B => bram_block3B_x,
        bram_block4A => bram_block4A_x,
        bram_block4B => bram_block4B_x,
        bram_block5A => bram_block5A_x,
        bram_block5B => bram_block5B_x,
        bram_block6A => bram_block6A_x,
        bram_block6B => bram_block6B_x,
        bram_block7A => bram_block7A_x,
        bram_block7B => bram_block7B_x,
        bram_block8A => bram_block8A_x,
        bram_block8B => bram_block8B_x,
        bram_block9A => bram_block9A_x,
        bram_block9B => bram_block9B_x,
        bram_block10A => bram_block10A_x,
        bram_block10B => bram_block10B_x,
        bram_block11A => bram_block11A_x,
        bram_block11B => bram_block11B_x,
        bram_block12A => bram_block12A_x,
        bram_block12B => bram_block12B_x,
        bram_block13A => bram_block13A_x,
        bram_block13B => bram_block13B_x,
        bram_block14A => bram_block14A_x,
        bram_block14B => bram_block14B_x,
        bram_block15A => bram_block15A_x,
        bram_block15B => bram_block15B_x,
        data_out1 => data_out1_s(63 downto 32),
        data_out2 => data_out1_s(31 downto 0));  

     data_out1 <= data_out1_s; 
     data_out1_s0 <= data_out1_s(15 downto 0);
     data_out1_s1 <= data_out1_s(31 downto 16);
     data_out1_s2 <= data_out1_s(47 downto 32);
     data_out1_s3 <= data_out1_s(63 downto 48);
     
 mux_y: mux_out
    generic map(WIDTH => WIDTH)
    Port map( 
        sel => sel_dram,
        bram_block0A => bram_block0A_y,
        bram_block0B => bram_block0B_y,
        bram_block1A => bram_block1A_y,
        bram_block1B => bram_block1B_y,
        bram_block2A => bram_block2A_y,
        bram_block2B => bram_block2B_y,
        bram_block3A => bram_block3A_y,
        bram_block3B => bram_block3B_y,
        bram_block4A => bram_block4A_y,
        bram_block4B => bram_block4B_y,
        bram_block5A => bram_block5A_y,
        bram_block5B => bram_block5B_y,
        bram_block6A => bram_block6A_y,
        bram_block6B => bram_block6B_y,
        bram_block7A => bram_block7A_y,
        bram_block7B => bram_block7B_y,
        bram_block8A => bram_block8A_y,
        bram_block8B => bram_block8B_y,
        bram_block9A => bram_block9A_y,
        bram_block9B => bram_block9B_y,
        bram_block10A => bram_block10A_y,
        bram_block10B => bram_block10B_y,
        bram_block11A => bram_block11A_y,
        bram_block11B => bram_block11B_y,
        bram_block12A => bram_block12A_y,
        bram_block12B => bram_block12B_y,
        bram_block13A => bram_block13A_y,
        bram_block13B => bram_block13B_y,
        bram_block14A => bram_block14A_y,
        bram_block14B => bram_block14B_y,
        bram_block15A => bram_block15A_y,
        bram_block15B => bram_block15B_y,
        data_out1 => data_out2_s(63 downto 32),
        data_out2 => data_out2_s(31 downto 0)); 
          
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
