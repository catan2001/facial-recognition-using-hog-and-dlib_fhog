library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity core_unit is
    generic (
        WIDTH: natural := 16
    );
    Port (
          ------------------- control signals ------------------
          clk: in std_logic;

          ------------------- input signals --------------------
          pix_0: in std_logic_vector(WIDTH - 1 downto 0);
          pix_1: in std_logic_vector(WIDTH - 1 downto 0);
          pix_2: in std_logic_vector(WIDTH - 1 downto 0);
          pix_3: in std_logic_vector(WIDTH - 1 downto 0); 
          -------------pixel 4 is never used-------------
          pix_5: in std_logic_vector(WIDTH - 1 downto 0);
          pix_6: in std_logic_vector(WIDTH - 1 downto 0);
          pix_7: in std_logic_vector(WIDTH - 1 downto 0);
          pix_8: in std_logic_vector(WIDTH - 1 downto 0);

          ------------------- output signals -------------------    
          res_x: out std_logic_vector(WIDTH - 1 downto 0);
          res_y: out std_logic_vector(WIDTH - 1 downto 0));
end core_unit;

architecture Behavioral of core_unit is
    ------------------- components -------------------    
    component filter is 
        generic (
            WIDTH: natural := 16;
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
    end component;
begin

    filter_x: filter 
    generic map(
        WIDTH => WIDTH,
        WIDTH_CONST => 3
        )
    Port map(
          ------------------- control signals ------------------
          clk => clk,

          ------------------- input signals --------------------
          pix_1 => pix_3,
          pix_2 => pix_0,
          pix_3 => pix_5,
          pix_4 => pix_6,
          pix_5 => pix_2,
          pix_6 => pix_8,
          ------------------- output signals -------------------    
          res => res_x
    );

    filter_y: filter 
    generic map(
        WIDTH => WIDTH,
        WIDTH_CONST => 3
        )
    Port map(
          ------------------- control signals ------------------
          clk => clk,

          ------------------- input signals --------------------
          pix_1 => pix_1,
          pix_2 => pix_0,
          pix_3 => pix_7,
          pix_4 => pix_2,
          pix_5 => pix_6,
          pix_6 => pix_8,
          ------------------- output signals -------------------    
          res => res_y
    );

end Behavioral;
