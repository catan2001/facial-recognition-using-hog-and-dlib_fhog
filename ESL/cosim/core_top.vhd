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
end core_top;

architecture Behavioral of core_top is
    component core_unit 
    generic (
        WIDTH: natural := 16
    );
    Port (
          ------------------- control signals ------------------
          clk: in std_logic;

          ------------------- input signals --------------------
          pix_0: in std_logic_vector(WIDTH - 1 downto 0); -- red 1
          pix_1: in std_logic_vector(WIDTH - 1 downto 0); -- red 1
          pix_2: in std_logic_vector(WIDTH - 1 downto 0); -- red 2
          pix_3: in std_logic_vector(WIDTH - 1 downto 0); -- red 2
          -------------pixel 4 is never used-------------
          pix_5: in std_logic_vector(WIDTH - 1 downto 0); -- red 3
          pix_6: in std_logic_vector(WIDTH - 1 downto 0); -- red 3
          pix_7: in std_logic_vector(WIDTH - 1 downto 0); -- red 4
          pix_8: in std_logic_vector(WIDTH - 1 downto 0); -- red 4

          ------------------- output signals -------------------    
          res_x: out std_logic_vector(WIDTH - 1 downto 0);
          res_y: out std_logic_vector(WIDTH - 1 downto 0)
    );
    end component;
begin
    -- filter 0 i 1 su prvi red
    filter_0: core_unit
    generic map(
        WIDTH => WIDTH
    )
    Port map(
          ------------------- control signals ------------------
          clk => clk,

          ------------------- input signals --------------------
          pix_0 => pix_0, -- 0 1 2 3
          pix_1 => pix_1, -- 4 5 6 7
          pix_2 => pix_2, -- 8 9 10 11
          pix_3 => pix_4,
          -------------pixel 4 is never used-------------
          pix_5 => pix_6,
          pix_6 => pix_8,
          pix_7 => pix_9,
          pix_8 => pix_10,

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
          pix_0 => pix_1, -- 0 1 2 3
          pix_1 => pix_2, -- 4 5 6 7 
          pix_2 => pix_3, -- 8 9 10 11
          pix_3 => pix_5,
          -------------pixel 4 is never used-------------
          pix_5 => pix_7,
          pix_6 => pix_9,
          pix_7 => pix_10,
          pix_8 => pix_11,

          ------------------- output signals -------------------    
          res_x => res_x_1,
          res_y => res_y_1
    );
    -- filter 2 i 3 su drugi red
    filter_2: core_unit
    generic map(
        WIDTH => WIDTH
    )
    Port map(
          ------------------- control signals ------------------
          clk => clk,

          ------------------- input signals --------------------
          pix_0 => pix_4, -- 4  5  6  7
          pix_1 => pix_5, -- 8  9  10 11
          pix_2 => pix_6, -- 12 13 14 15
          pix_3 => pix_8,
          -------------pixel 4 is never used-------------
          pix_5 => pix_10,
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
          pix_0 => pix_5, -- 4  5  6  7
          pix_1 => pix_6,-- 8  9  10 11 
          pix_2 => pix_7,-- 12 13 14 15
          pix_3 => pix_9,
          -------------pixel 4 is never used-------------
          pix_5 => pix_11,
          pix_6 => pix_13,
          pix_7 => pix_14,
          pix_8 => pix_15,

          ------------------- output signals -------------------    
          res_x => res_x_3,
          res_y => res_y_3
    );
    -- filter 4 i 5 su treci red
    filter_4: core_unit
    generic map(
        WIDTH => WIDTH
    )
    Port map(
          ------------------- control signals ------------------
          clk => clk,

          ------------------- input signals --------------------
          pix_0 => pix_8, -- 8  9  10 11
          pix_1 => pix_9, -- 12 13 14 15
          pix_2 => pix_10, -- 16 17 18 19
          pix_3 => pix_12,
          -------------pixel 4 is never used-------------
          pix_5 => pix_14,
          pix_6 => pix_16,
          pix_7 => pix_17,
          pix_8 => pix_18,

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
          pix_0 => pix_9, -- 8  9  10 11
          pix_1 => pix_10,-- 12 13 14 15
          pix_2 => pix_11,-- 16 17 18 19
          pix_3 => pix_13,
          -------------pixel 4 is never used-------------
          pix_5 => pix_15,
          pix_6 => pix_17,
          pix_7 => pix_18,
          pix_8 => pix_19,

          ------------------- output signals -------------------    
          res_x => res_x_5,
          res_y => res_y_5
    );
    -- filter 6 i 7 su cetvrti red
    filter_6: core_unit
    generic map(
        WIDTH => WIDTH
    )
    Port map(
          ------------------- control signals ------------------
          clk => clk,

          ------------------- input signals --------------------
          pix_0 => pix_12, -- 12 13 14 15
          pix_1 => pix_13,-- 16 17 18 19
          pix_2 => pix_14,-- 20 21 22 23
          pix_3 => pix_16,
          -------------pixel 4 is never used-------------
          pix_5 => pix_18,
          pix_6 => pix_20,
          pix_7 => pix_21,
          pix_8 => pix_22,

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
          pix_0 => pix_13,-- 12 13 14 15
          pix_1 => pix_14,-- 16 17 18 19
          pix_2 => pix_15,-- 20 21 22 23
          pix_3 => pix_17,
          -------------pixel 4 is never used-------------
          pix_5 => pix_19,
          pix_6 => pix_21,
          pix_7 => pix_22,
          pix_8 => pix_23,

          ------------------- output signals -------------------    
          res_x => res_x_7,
          res_y => res_y_7
    );

end Behavioral;
