library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity core_top is
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
end core_top;

architecture Behavioral of core_top is
    component core_unit is 
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
          res_y: out std_logic_vector(WIDTH - 1 downto 0)
    );
    end component;
begin

    filter_0: core_unit
    generic map(
        WIDTH => WIDTH
    )
    Port map(
          ------------------- control signals ------------------
          clk => clk,

          ------------------- input signals --------------------
          pix_0 => pix_0,
          pix_1 => pix_1,
          pix_2 => pix_2,
          pix_3 => pix_3,
          -------------pixel 4 is never used-------------
          pix_5 => pix_5,
          pix_6 => pix_6,
          pix_7 => pix_7,
          pix_8 => pix_8,

          ------------------- output signals -------------------    
          res_x => res_x_0,
          res_y => res_y_0
    );

    filter_1: core_unit
    generic map(
        WIDTH => WIDTH
    )
    Port map(
          ------------------- control signals ------------------
          clk => clk,

          ------------------- input signals --------------------
          pix_0 => pix_3,
          pix_1 => pix_4,
          pix_2 => pix_5,
          pix_3 => pix_6,
          -------------pixel 4 is never used-------------
          pix_5 => pix_8,
          pix_6 => pix_9,
          pix_7 => pix_10,
          pix_8 => pix_11,

          ------------------- output signals -------------------    
          res_x => res_x_1,
          res_y => res_y_1
    );

    filter_2: core_unit
    generic map(
        WIDTH => WIDTH
    )
    Port map(
          ------------------- control signals ------------------
          clk => clk,

          ------------------- input signals --------------------
          pix_0 => pix_6,
          pix_1 => pix_7,
          pix_2 => pix_8,
          pix_3 => pix_9,
          -------------pixel 4 is never used-------------
          pix_5 => pix_11,
          pix_6 => pix_12,
          pix_7 => pix_13,
          pix_8 => pix_14,

          ------------------- output signals -------------------    
          res_x => res_x_2,
          res_y => res_y_2
    );

    filter_3: core_unit
    generic map(
        WIDTH => WIDTH
    )
    Port map(
          ------------------- control signals ------------------
          clk => clk,

          ------------------- input signals --------------------
          pix_0 => pix_9,
          pix_1 => pix_10,
          pix_2 => pix_11,
          pix_3 => pix_12,
          -------------pixel 4 is never used-------------
          pix_5 => pix_14,
          pix_6 => pix_15,
          pix_7 => pix_16,
          pix_8 => pix_17,

          ------------------- output signals -------------------    
          res_x => res_x_3,
          res_y => res_y_3
    );

    filter_4: core_unit
    generic map(
        WIDTH => WIDTH
    )
    Port map(
          ------------------- control signals ------------------
          clk => clk,

          ------------------- input signals --------------------
          pix_0 => pix_12,
          pix_1 => pix_13,
          pix_2 => pix_14,
          pix_3 => pix_15,
          -------------pixel 4 is never used-------------
          pix_5 => pix_17,
          pix_6 => pix_18,
          pix_7 => pix_19,
          pix_8 => pix_20,

          ------------------- output signals -------------------    
          res_x => res_x_4,
          res_y => res_y_4
    );

    filter_5: core_unit
    generic map(
        WIDTH => WIDTH
    )
    Port map(
          ------------------- control signals ------------------
          clk => clk,

          ------------------- input signals --------------------
          pix_0 => pix_15,
          pix_1 => pix_16,
          pix_2 => pix_17,
          pix_3 => pix_18,
          -------------pixel 4 is never used-------------
          pix_5 => pix_20,
          pix_6 => pix_21,
          pix_7 => pix_22,
          pix_8 => pix_23,

          ------------------- output signals -------------------    
          res_x => res_x_5,
          res_y => res_y_5
    );

    filter_6: core_unit
    generic map(
        WIDTH => WIDTH
    )
    Port map(
          ------------------- control signals ------------------
          clk => clk,

          ------------------- input signals --------------------
          pix_0 => pix_18,
          pix_1 => pix_19,
          pix_2 => pix_20,
          pix_3 => pix_21,
          -------------pixel 4 is never used-------------
          pix_5 => pix_23,
          pix_6 => pix_24,
          pix_7 => pix_25,
          pix_8 => pix_26,

          ------------------- output signals -------------------    
          res_x => res_x_6,
          res_y => res_y_6
    );


    filter_7: core_unit
    generic map(
        WIDTH => WIDTH
    )
    Port map(
          ------------------- control signals ------------------
          clk => clk,

          ------------------- input signals --------------------
          pix_0 => pix_21,
          pix_1 => pix_22,
          pix_2 => pix_23,
          pix_3 => pix_24,
          -------------pixel 4 is never used-------------
          pix_5 => pix_26,
          pix_6 => pix_27,
          pix_7 => pix_28,
          pix_8 => pix_29,

          ------------------- output signals -------------------    
          res_x => res_x_7,
          res_y => res_y_7
    );

end Behavioral;
