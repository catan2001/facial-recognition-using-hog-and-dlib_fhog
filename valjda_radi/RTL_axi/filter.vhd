library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity filter is
    generic (WIDTH: natural := 16;
             WIDTH_CONST: natural := 3
             );
    Port (
          clk: in std_logic;
          pix_1: in std_logic_vector(WIDTH - 1 downto 0);
          pix_2: in std_logic_vector(WIDTH - 1 downto 0);
          pix_3: in std_logic_vector(WIDTH - 1 downto 0);
          pix_4: in std_logic_vector(WIDTH - 1 downto 0);
          pix_5: in std_logic_vector(WIDTH - 1 downto 0);
          pix_6: in std_logic_vector(WIDTH - 1 downto 0);
          res: out std_logic_vector(WIDTH - 1 downto 0));
end filter;

architecture Behavioral of filter is
-- CHECK IF NEEDED
    attribute use_dsp : string;
    attribute use_dsp of Behavioral : architecture is "yes";

    signal two : std_logic_vector(WIDTH_CONST - 1 downto 0) := "010"; -- multiplying by constant 2
    signal negative_two : std_logic_vector(WIDTH_CONST - 1 downto 0) := "110"; -- multiplying by constant -2
    signal negative_one : std_logic_vector(WIDTH_CONST - 1 downto 0) := "111"; -- multiplying by constant -1

    signal res_ma_1 : std_logic_vector((WIDTH + WIDTH_CONST - 1) - 1 downto 0);
    signal res_ma_2 : std_logic_vector((WIDTH + WIDTH_CONST - 1) - 1 downto 0);
    signal res_ms : std_logic_vector((WIDTH + WIDTH_CONST - 1) - 1 downto 0);

    signal res_aa : std_logic_vector(WIDTH - 1 downto 0);

    component DSP_MA is
        generic (
            WIDTH: natural := 16;
            WIDTH_CONST: natural := 3;
            WIDTH_INTERIM: natural := 18
            );
        port (
            ------------------- control signals -------------------
            clk: in std_logic;
            
            ------------------- input signals -------------------
            a: in std_logic_vector(WIDTH - 1 downto 0);               
            b: in std_logic_vector(WIDTH_CONST - 1 downto 0);      
            c: in std_logic_vector(WIDTH - 1 downto 0);   
            
            ------------------- output signals -------------------    
            res: out std_logic_vector(WIDTH_INTERIM - 1 downto 0));   
    end component;

    component DSP_MS is
        generic (
            WIDTH: natural := 16;
            WIDTH_CONST: natural := 3;
            WIDTH_INTERIM: natural := 18
            );
        port (
            ------------------- control signals -------------------
            clk: in std_logic;
            
            ------------------- input signals -------------------
            a: in std_logic_vector(WIDTH - 1 downto 0);               
            b: in std_logic_vector(WIDTH_CONST - 1 downto 0);      
            c: in std_logic_vector(WIDTH - 1 downto 0);   
            
            ------------------- output signals -------------------    
            res: out std_logic_vector(WIDTH_INTERIM - 1 downto 0));   
    end component;

    component DSP_AA is
        generic (
            WIDTH : natural := 18; 
            WIDTH_INTERIM : natural := 19;
            WIDTH_OUTPUT : natural := 16;
            WIDTH_CONST : natural := 2
        );
        port (
            clk : in std_logic; 
            
            ain : in std_logic_vector(WIDTH-1 downto 0); 
            bin : in std_logic_vector(WIDTH-1 downto 0);
            cin : in std_logic_vector(WIDTH_CONST-1 downto 0); 
            din : in std_logic_vector(WIDTH-1 downto 0); 
            
            pout : out std_logic_vector(WIDTH_OUTPUT-1 downto 0));
    end component;

begin

    dsp1: DSP_MA 
    generic map(
        WIDTH => WIDTH, 
        WIDTH_CONST => WIDTH_CONST,
        WIDTH_INTERIM => WIDTH + WIDTH_CONST - 1
        )
    Port map(
        clk => clk,
        a => pix_1,
        b => two,
        c => pix_2,
        res => res_ma_1
    );

    dsp2: DSP_MA 
    generic map(
        WIDTH => WIDTH, 
        WIDTH_CONST => WIDTH_CONST,
        WIDTH_INTERIM => WIDTH + WIDTH_CONST - 1
        )
    Port map(
        clk => clk,
        a => pix_3,
        b => negative_two,
        c => pix_4,
        res => res_ma_2
    );

    dsp3: DSP_MS 
    generic map(
        WIDTH => WIDTH, 
        WIDTH_CONST => WIDTH_CONST,
        WIDTH_INTERIM => WIDTH + WIDTH_CONST - 1
        )
    Port map(
        clk => clk,
        a => pix_5,
        b => negative_one,
        c => pix_6,
        res => res_ms
    );

    dsp4: DSP_AA
    generic map(
        WIDTH => WIDTH + WIDTH_CONST - 1,
        WIDTH_INTERIM => WIDTH + WIDTH_CONST,
        WIDTH_OUTPUT => WIDTH,
        WIDTH_CONST => WIDTH_CONST - 1
        )
    Port map(
        clk => clk,
        ain => res_ma_1,
        bin => res_ma_2,
        cin => "01",
        din => res_ms,
        pout => res_aa
    );

    res <= res_aa(WIDTH - 1 downto 0); -- final output

end Behavioral;
