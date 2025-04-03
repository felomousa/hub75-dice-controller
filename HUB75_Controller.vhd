-- Felo Mousa - 301586676; Nolan Gola - 301581563; 
-- ENSC 252 || 2024 Fall Semester --
-- BONUS PROJECT --
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- Generates a slower pixel clock from a 50MHz clock.
-- Implements a state machine (IDLE, SHIFTING, LATCHING, WAITING) to:
--   - Shift out pixel data for 64 columns.
--   - Latch the shifted data.
--   - Wait and then advance to the next row.
-- Converts the current row number into 4-bit binary 
-- Outputs color signals and control signals via GPIO


entity HUB75_Controller is
    port (
        CLOCK_50 : in  std_logic;
        
        r0_in : in std_logic;
        g0_in : in std_logic;
        b0_in : in std_logic;
        r1_in : in std_logic;
        g1_in : in std_logic;
        b1_in : in std_logic;
        
        GPIO     : out std_logic_vector(35 downto 0);
        
        current_row_out : out integer range 0 to 15;
        pixel_count_out : out integer range 0 to 64
    );
end entity;

architecture rtl of HUB75_Controller is

    constant ROWS : integer := 16;
    constant COLS : integer := 64;
    constant PIXEL_CLK_DIV : integer := 50;

    type state_type is (IDLE, SHIFTING, LATCHING, WAITING);
    signal state       : state_type := IDLE;

    signal current_row : integer range 0 to ROWS-1 := 0;
    signal pixel_count : integer range 0 to COLS := 0;
    signal row_wait    : integer := 0;

    signal pixel_clk_reg : std_logic := '0';
    signal pixel_clk_count : integer := 0;

    signal a_s, b_s, c_s, d_s : std_logic := '0';
    signal clk_s   : std_logic := '0';
    signal latch_s : std_logic := '0';
    signal oe_s    : std_logic := '1';

begin

    current_row_out <= current_row;
    pixel_count_out <= pixel_count;

    a_s <= '1' when ((current_row / 1) mod 2) = 1 else '0';
    b_s <= '1' when ((current_row / 2) mod 2) = 1 else '0';
    c_s <= '1' when ((current_row / 4) mod 2) = 1 else '0';
    d_s <= '1' when ((current_row / 8) mod 2) = 1 else '0';

    process(CLOCK_50)
    begin
        if rising_edge(CLOCK_50) then
            pixel_clk_count <= pixel_clk_count + 1;
            if pixel_clk_count = PIXEL_CLK_DIV/2 then
                pixel_clk_reg <= not pixel_clk_reg;
                pixel_clk_count <= 0;
            end if;
        end if;
    end process;

    clk_s <= pixel_clk_reg;

    process(pixel_clk_reg)
    begin
        if rising_edge(pixel_clk_reg) then
            case state is
                when IDLE =>
                    oe_s    <= '1';
                    latch_s <= '0';
                    pixel_count <= 0;
                    state <= SHIFTING;

                when SHIFTING =>
                    pixel_count <= pixel_count + 1;
                    if pixel_count = COLS then
                        state <= LATCHING;
                    end if;

                when LATCHING =>
                    latch_s <= '1';
                    state <= WAITING;

                when WAITING =>
                    latch_s <= '0';
                    oe_s    <= '0';
                    row_wait <= row_wait + 1;
                    if row_wait > 1000 then
                        row_wait <= 0;
                        current_row <= (current_row + 1) mod ROWS;
                        state <= IDLE;
                    end if;

            end case;
        end if;
    end process;

    GPIO(0)  <= r0_in;
    GPIO(1)  <= g0_in;
    GPIO(2)  <= b0_in;
    GPIO(3)  <= r1_in;
    GPIO(4)  <= g1_in;
    GPIO(5)  <= b1_in;
    GPIO(6)  <= a_s;
    GPIO(7)  <= b_s;
    GPIO(8)  <= c_s;
    GPIO(9)  <= d_s;
    GPIO(10) <= clk_s;
    GPIO(11) <= latch_s;
    GPIO(12) <= oe_s;
    GPIO(35 downto 13) <= (others => '0');

end architecture;
