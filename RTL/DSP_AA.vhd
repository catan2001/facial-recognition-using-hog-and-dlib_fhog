library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; 

entity DSP_AA is
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
        
        pout : out std_logic_vector(WIDTH_OUTPUT-1 downto 0)
    
    );
end DSP_AA;

architecture Behavioral of DSP_AA is

signal a : signed(WIDTH-1 downto 0);
signal b : signed(WIDTH-1 downto 0);
signal d1: signed(WIDTH-1 downto 0);

signal add : signed(WIDTH_INTERIM-1 downto 0);
signal mult, p, d2 : signed(WIDTH_INTERIM+1 downto 0);

signal const : signed(WIDTH_CONST-1 downto 0);
begin

    process(clk)
    begin
        if rising_edge(clk) then
            d1 <= signed(din);
            d2 <= resize(d1, WIDTH_INTERIM+2);
            const <= signed(cin);
            
            add <= resize(signed(ain), WIDTH_INTERIM) + resize(signed(bin), WIDTH_INTERIM);
            
            mult <= add * const;
            
            p <= mult + d2;
            
        end if; 
    end process;

    pout <= std_logic_vector(p(18 downto 3));

end Behavioral;