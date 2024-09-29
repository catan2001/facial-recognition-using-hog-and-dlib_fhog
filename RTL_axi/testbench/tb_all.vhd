library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; 
use std.textio.all;

entity tb_all is
  generic(
    AXIS_DATA_WIDTH:natural:=64;
    AXIL_ADDR_WIDTH:natural:=4;
    DATA_WIDTH:natural:=32;
    BRAM_SIZE:natural:=1024;
    ADDR_WIDTH:natural:=10;
    PIX_WIDTH:natural:=16);
end tb_all;

architecture Behavioral of tb_all is

component top_axi is
 generic(
    AXIS_DATA_WIDTH:natural:=64;
    AXIL_ADDR_WIDTH:natural:=4;
    DATA_WIDTH:natural:=32;
    BRAM_SIZE:natural:=1024;
    ADDR_WIDTH:natural:=10;
    PIX_WIDTH:natural:=16
    );
    
 port ( 
    clk: in std_logic;
    
    --HP0 PORTS:
    -- Ports of Axi Stream Slave Bus Interface: ip to ddr
    m00_axis_tready	: in std_logic;
    m00_axis_tdata	: out std_logic_vector(AXIS_DATA_WIDTH-1 downto 0);
    m00_axis_tstrb	: out std_logic_vector((AXIS_DATA_WIDTH/8)-1 downto 0);
    m00_axis_tlast	: out std_logic;
    m00_axis_tvalid	: out std_logic;

    -- Ports of Axi Master Bus Interface: ddr to ip
    s00_axis_tvalid	: in std_logic;
    s00_axis_tdata	: in std_logic_vector(AXIS_DATA_WIDTH-1 downto 0);
    s00_axis_tstrb	: in std_logic_vector((AXIS_DATA_WIDTH/8)-1 downto 0);
    s00_axis_tlast	: in std_logic;
    s00_axis_tready	: out std_logic;
    
    --HP1 PORTS:
    -- Ports of Axi Stream Slave Bus Interface: ip to ddr
    m01_axis_tready	: in std_logic;
    m01_axis_tdata	: out std_logic_vector(AXIS_DATA_WIDTH-1 downto 0);
    m01_axis_tstrb	: out std_logic_vector((AXIS_DATA_WIDTH/8)-1 downto 0);
    m01_axis_tlast	: out std_logic;
    m01_axis_tvalid	: out std_logic;

    -- Ports of Axi Master Bus Interface: ddr to ip
    s01_axis_tvalid	: in std_logic;
    s01_axis_tdata	: in std_logic_vector(AXIS_DATA_WIDTH-1 downto 0);
    s01_axis_tstrb	: in std_logic_vector((AXIS_DATA_WIDTH/8)-1 downto 0);
    s01_axis_tlast	: in std_logic;
    s01_axis_tready	: out std_logic;
    
    -- Ports of Axi Light Slave Bus Interface
    s00_axi_aresetn	: in std_logic;
    s00_axi_awaddr	: in std_logic_vector(AXIL_ADDR_WIDTH-1 downto 0);
    s00_axi_awprot	: in std_logic_vector(2 downto 0);
    s00_axi_awvalid	: in std_logic;
    s00_axi_awready	: out std_logic;
    s00_axi_wdata	: in std_logic_vector(DATA_WIDTH-1 downto 0);
    s00_axi_wstrb	: in std_logic_vector((DATA_WIDTH/8)-1 downto 0);
    s00_axi_wvalid	: in std_logic;
    s00_axi_wready	: out std_logic;
    s00_axi_bresp	: out std_logic_vector(1 downto 0);
    s00_axi_bvalid	: out std_logic;
    s00_axi_bready	: in std_logic;
    s00_axi_araddr	: in std_logic_vector(AXIL_ADDR_WIDTH-1 downto 0);
    s00_axi_arprot	: in std_logic_vector(2 downto 0);
    s00_axi_arvalid	: in std_logic;
    s00_axi_arready	: out std_logic;
    s00_axi_rdata	: out std_logic_vector(DATA_WIDTH-1 downto 0);
    s00_axi_rresp	: out std_logic_vector(1 downto 0);
    s00_axi_rvalid	: out std_logic;
    s00_axi_rready	: in std_logic
    );

end component;

signal clk_s: std_logic;

--axi stream signals
--slave signals -> bram to dram
--master signals -> dram to bram
signal s00_axi_ready, s01_axi_ready, m00_axi_ready, m01_axi_ready: std_logic;
signal s00_axi_valid, s01_axi_valid, m00_axi_valid, m01_axi_valid: std_logic;
signal s00_axi_strb, s01_axi_strb, m00_axi_strb, m01_axi_strb: std_logic_vector(7 downto 0);
signal s00_axi_last, s01_axi_last, m00_axi_last, m01_axi_last: std_logic;

signal gp_axi_reset: std_logic;
signal gp_axi_awaddr: std_logic_vector(AXIL_ADDR_WIDTH-1 downto 0);
signal gp_axi_awprot: std_logic_vector(2 downto 0);
signal gp_axi_awvalid: std_logic;
signal gp_axi_awready: std_logic;
signal gp_axi_wdata: std_logic_vector(DATA_WIDTH-1 downto 0);
signal gp_axi_wstrb: std_logic_vector((DATA_WIDTH/8)-1 downto 0);
signal gp_axi_wvalid: std_logic;
signal gp_axi_wready: std_logic;
signal gp_axi_bresp	: std_logic_vector(1 downto 0);
signal gp_axi_bvalid: std_logic;
signal gp_axi_bready: std_logic;
signal gp_axi_araddr: std_logic_vector(AXIL_ADDR_WIDTH-1 downto 0);
signal gp_axi_arprot: std_logic_vector(2 downto 0);
signal gp_axi_arvalid: std_logic;
signal gp_axi_arready: std_logic;
signal gp_axi_rdata: std_logic_vector(DATA_WIDTH-1 downto 0);
signal gp_axi_rresp: std_logic_vector(1 downto 0);
signal gp_axi_rvalid: std_logic;
signal gp_axi_rready: std_logic;

type data_t is array(0 to 1) of std_logic_vector(2*DATA_WIDTH-1 downto 0);
signal data_in_s, data_out_s: data_t;

constant IMG_WIDTH : natural := 152;
constant IMG_HEIGHT : natural := 152;

type rows_type is array(0 to IMG_WIDTH - 1) of std_logic_vector(15 downto 0);
type dram_type is array(0 to IMG_HEIGHT - 1) of rows_type;

impure function dram_init return dram_type is
    variable row_text : line;
    variable float_data : real;
    variable check : boolean;
    variable data : std_logic_vector(15 downto 0);
    variable dram_rows : rows_type;
    variable dram : dram_type;
    file text_file : text open read_mode is "/home/koshek/Desktop/emotion_recognition_git/facial-recognition-using-hog-and-dlib_fhog/input_files/input150_150/gray_normalised.txt";
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

signal dram1 : dram_type := dram_init;
signal dram2 : dram_type := dram_init;
signal dram3 : dram_type := dram_init;

begin

top_axi_l: top_axi
generic map(
  AXIS_DATA_WIDTH => AXIS_DATA_WIDTH,
  AXIL_ADDR_WIDTH => AXIL_ADDR_WIDTH,
  DATA_WIDTH => DATA_WIDTH,
  BRAM_SIZE => BRAM_SIZE,
  ADDR_WIDTH => ADDR_WIDTH,
  PIX_WIDTH => PIX_WIDTH)

port map(    
    clk => clk_s,
    
    --HP0 PORTS:
    -- Ports of Axi Stream Slave Bus Interface: ip to ddr
    m00_axis_tready	=> m00_axi_ready, 
    m00_axis_tdata	=> data_out_s(0),
    m00_axis_tstrb	=> m00_axi_strb,
    m00_axis_tlast	=> m00_axi_last,
    m00_axis_tvalid	=> m00_axi_valid,

    -- Ports of Axi Master Bus Interface: ddr to ip
    s00_axis_tvalid	=> s00_axi_valid,
    s00_axis_tdata	=> data_in_s(0),
    s00_axis_tstrb	=> s00_axi_strb,
    s00_axis_tlast	=> s00_axi_last,
    s00_axis_tready	=> s00_axi_ready,
    
    --HP1 PORTS:
    -- Ports of Axi Stream Slave Bus Interface: ip to ddr
    m01_axis_tready	=> m01_axi_ready,
    m01_axis_tdata	=> data_out_s(1),
    m01_axis_tstrb	=> m01_axi_strb,
    m01_axis_tlast	=> m01_axi_last,
    m01_axis_tvalid	=> m01_axi_valid,

    -- Ports of Axi Master Bus Interface: ddr to ip
    s01_axis_tvalid	=> s01_axi_valid,
    s01_axis_tdata	=> data_in_s(1),
    s01_axis_tstrb	=> s01_axi_strb,
    s01_axis_tlast	=> s01_axi_last,
    s01_axis_tready	=> s01_axi_ready,
    
    -- Ports of Axi Light Slave Bus Interface
    s00_axi_aresetn	=> gp_axi_reset,
    s00_axi_awaddr	=> gp_axi_awaddr,
    s00_axi_awprot	=> gp_axi_awprot,
    s00_axi_awvalid	=> gp_axi_awvalid,
    s00_axi_awready	=> gp_axi_awready,
    s00_axi_wdata	=> gp_axi_wdata,
    s00_axi_wstrb	=> gp_axi_wstrb,
    s00_axi_wvalid	=> gp_axi_wvalid,
    s00_axi_wready	=> gp_axi_wready,
    s00_axi_bresp	=> gp_axi_bresp,
    s00_axi_bvalid	=> gp_axi_bvalid,
    s00_axi_bready	=> gp_axi_bready,
    s00_axi_araddr	=> gp_axi_araddr,
    s00_axi_arprot	=> gp_axi_arprot,
    s00_axi_arvalid	=> gp_axi_arvalid,
    s00_axi_arready	=> gp_axi_arready,
    s00_axi_rdata	=> gp_axi_rdata,
    s00_axi_rresp	=> gp_axi_rresp,
    s00_axi_rvalid	=> gp_axi_rvalid,
    s00_axi_rready	=> gp_axi_rready
);
        
    stim_gen1: process
        variable a : integer := 0;
        variable b: integer := 0;
    begin
        --AXI LIGHT SETUP:------------------------------------------------------------
        --axi lite has to be reset before it's used
        gp_axi_reset <= '0', '1' after 30 ns;
        
        --setup all signals for a write transaction:
        --type of access prot = 000 => data access, secure, unprivileged 
        gp_axi_awprot <= "000";
        --we want all bytes written to the register (strb => 1111)
        gp_axi_wstrb <= "1111";
        --say that we are ready for slave responses at all times?
        gp_axi_bready <= '1';
        
        --data and address set: rst = '1' reset the system SAHE3
        --gp_axi_wdata <= "00000000000000001100000010000000";
        gp_axi_wdata <= "00000000000000001100000011010111";
        gp_axi_awaddr <= "1000";
        
        --address and data lines are valid:
        gp_axi_awvalid <= '1';
        gp_axi_wvalid <= '1';
       
        --wait for slave to be ready to accept data on given address:
        wait until (gp_axi_wready = '1' and gp_axi_awready = '1'); 
        --indicator that the data was written into given address
        wait until (gp_axi_bvalid = '1');
       
        --data and address set: rst = '0' reset the system SAHE3
        --246x300
        --gp_axi_wdata <= "00000000000000000100000010000000";
        --150x150
        gp_axi_wdata <= "00000000000000000100000011010111";
        gp_axi_awaddr <= "1000";
       
        --wait for slave to be ready to accept data on given address:
        wait until (gp_axi_wready = '1' and gp_axi_awready = '1'); 
        --indicator that the data was written into given address
        wait until (gp_axi_bvalid = '1');
       
        --SAHE2
        --246x300
        --gp_axi_wdata <= "00100000100000010011010000111110";
        gp_axi_wdata <= "00110100110100001001100000100110";
        gp_axi_awaddr <= "0100";
        
        --wait for slave to be ready to accept data on given address:
        wait until (gp_axi_wready = '1' and gp_axi_awready = '1');
        --indicator that the data was written into given address
        wait until (gp_axi_bvalid = '1');
        
        --set start bit to '1' SAHE1
        --gp_axi_wdata <= "00111110000100101110001111100010";
        gp_axi_wdata <= "00100110000010011000001001100010";
        gp_axi_awaddr <= "0000";
        
        --wait for slave to be ready to accept data on given address:
        wait until (gp_axi_wready = '1' and gp_axi_awready = '1');
        --indicator that the data was written into given address
        wait until (gp_axi_bvalid = '1');
        
        --set start bit to '1'
        --gp_axi_wdata <= "00111110000100101110001111100000";
        gp_axi_wdata <= "00100110000010011000001001100000";
        gp_axi_awaddr <= "0000";
        
        --wait for slave to be ready to accept data on given address:
        wait until (gp_axi_wready = '1' and gp_axi_awready = '1');
        --indicator that the data was written into given address
        wait until (gp_axi_bvalid = '1');
        
    wait;
    end process; 
    
    stim_gen2: process
        variable a : integer := 0;
        variable b: integer := 0;
    begin
        --AXI STREAM HP0 SETUP:------------------------------------------------------------
        
        s00_axi_strb <= "11111111";
        s00_axi_valid <= '0';
        s00_axi_last <= '0';
        --imitating ddr being ready to receive data_out:
        m00_axi_ready <= '0';
      
        wait for 1500 ns;
        s00_axi_valid <= '1';
  
          for a in 0 to 75 loop
            for b in 0 to 37 loop
               
                data_in_s(0) <= dram1(2*a)(4*b)&dram1(2*a)(4*b+1)&dram1(2*a)(4*b+2)&dram1(2*a)(4*b+3);
               
                if(a = 75 and b = 37) then
                    --wait until rising_edge(clk_s);
                    --wait for 50 ns;
                    s00_axi_last <= '1';
                    
                    wait until rising_edge(clk_s);
                    s00_axi_last <= '0';
                    s00_axi_valid <= '0';
                    
                end if; 
                
                if(s00_axi_ready = '0') then
                    wait until (s00_axi_ready = '1');
                    --wait until rising_edge(clk_s);
                    report "a: " & integer'image(a) & " b: " & integer'image(b);
                end if;
                   
                wait until rising_edge(clk_s);
            end loop;            
        end loop; 
        
        wait for 300100 ns;
        m00_axi_ready <= '1';
        
--          s00_axi_last <= '1';
--          s00_axi_valid <= '0';
            
--          wait until rising_edge(clk_s);
--          s00_axi_last <= '0';
        
    wait;
    end process; 
        
    stim_gen3: process
        variable c : integer := 0;
        variable d: integer := 0;
    begin
       
        --AXI STREAM HP1 SETUP:------------------------------------------------------------
       
        s01_axi_strb <= "11111111";
        s01_axi_valid <= '0';
        s01_axi_last <= '0';
        --imitating ddr being ready to receive data_out:
        m01_axi_ready <= '0';
        
        wait for 1000 ns;
        s01_axi_valid <= '1';
       
        --for a in 0 to 150 loop
            --for b in 0 to 61 loop
       for c in 0 to 75 loop
         for d in 0 to 37 loop
                
                data_in_s(1) <= dram1(2*c+1)(4*d)&dram1(2*c+1)(4*d+1)&dram1(2*c+1)(4*d+2)&dram1(2*c+1)(4*d+3);
                
                if(c = 75 and d = 37) then
                --wait until rising_edge(clk_s);
                    --wait for 50 ns;
                    s01_axi_last <= '1';
                    
                    wait until rising_edge(clk_s);
                    s01_axi_last <= '0';
                    s01_axi_valid <= '0';               
                end if;
                
                if(s01_axi_ready = '0') then
                    wait until (s01_axi_ready = '1');
                    --wait until rising_edge(clk_s);
                    report "c: " & integer'image(c) & " d: " & integer'image(d);
                end if;
                    
                wait until rising_edge(clk_s);
            end loop;            
        end loop; 
        
        wait for 300200 ns;
        m01_axi_ready <= '1';
         
        
--        s01_axi_last <= '1';
--        s01_axi_valid <= '0';
        
--        wait until rising_edge(clk_s);
--        s01_axi_last <= '0';
        
    wait;
    end process;

    clk_gen: process
    begin
        clk_s <= '0', '1' after 25 ns;
        wait for 50 ns;
    end process;

end Behavioral;