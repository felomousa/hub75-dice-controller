-- Felo Mousa - 301586676; Nolan Gola - 301581563;
-- ENSC 252 || 2024 Fall Semester --
-- BONUS PROJECT --

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;


ENTITY HUB75_Controller IS
	PORT (
		CLOCK_50        : IN std_logic;
		r0_in           : IN std_logic;
		g0_in           : IN std_logic;
		b0_in           : IN std_logic;
		r1_in           : IN std_logic;
		g1_in           : IN std_logic;
		b1_in           : IN std_logic;
		GPIO            : OUT std_logic_vector(35 DOWNTO 0);
		current_row_out : OUT INTEGER RANGE 0 TO 15;
		pixel_count_out : OUT INTEGER RANGE 0 TO 64
	);
END ENTITY;
ARCHITECTURE rtl OF HUB75_Controller IS
	CONSTANT ROWS          : INTEGER := 16;
	CONSTANT COLS          : INTEGER := 64;
	CONSTANT PIXEL_CLK_DIV : INTEGER := 50;
	TYPE state_type IS (IDLE, SHIFTING, LATCHING, WAITING);
	SIGNAL state              : state_type := IDLE;
	SIGNAL current_row        : INTEGER RANGE 0 TO ROWS - 1 := 0;
	SIGNAL pixel_count        : INTEGER RANGE 0 TO COLS := 0;
	SIGNAL row_wait           : INTEGER := 0;
	SIGNAL pixel_clk_reg      : std_logic := '0';
	SIGNAL pixel_clk_count    : INTEGER := 0;
	SIGNAL a_s, b_s, c_s, d_s : std_logic := '0';
	SIGNAL clk_s              : std_logic := '0';
	SIGNAL latch_s            : std_logic := '0';
	SIGNAL oe_s               : std_logic := '1';
BEGIN
	current_row_out <= current_row;
	pixel_count_out <= pixel_count;
	a_s             <= '1' WHEN ((current_row / 1) MOD 2) = 1 ELSE '0';
	b_s             <= '1' WHEN ((current_row / 2) MOD 2) = 1 ELSE '0';
	c_s             <= '1' WHEN ((current_row / 4) MOD 2) = 1 ELSE '0';
	d_s             <= '1' WHEN ((current_row / 8) MOD 2) = 1 ELSE '0';
	PROCESS (CLOCK_50)
	BEGIN
		IF rising_edge(CLOCK_50) THEN
			pixel_clk_count <= pixel_clk_count + 1;
			IF pixel_clk_count = PIXEL_CLK_DIV/2 THEN
				pixel_clk_reg   <= NOT pixel_clk_reg;
				pixel_clk_count <= 0;
			END IF;
		END IF;
	END PROCESS;
	clk_s <= pixel_clk_reg;
	PROCESS (pixel_clk_reg)
		BEGIN
			IF rising_edge(pixel_clk_reg) THEN
				CASE state IS
					WHEN IDLE =>
						oe_s        <= '1';
						latch_s     <= '0';
						pixel_count <= 0;
						state       <= SHIFTING;
					WHEN SHIFTING =>
						pixel_count <= pixel_count + 1;
						IF pixel_count = COLS THEN
							state <= LATCHING;
						END IF;
					WHEN LATCHING =>
						latch_s <= '1';
						state   <= WAITING;
					WHEN WAITING =>
						latch_s  <= '0';
						oe_s     <= '0';
						row_wait <= row_wait + 1;
						IF row_wait > 1000 THEN
							row_wait    <= 0;
							current_row <= (current_row + 1) MOD ROWS;
							state       <= IDLE;
						END IF;
				END CASE;
			END IF;
		END PROCESS;
		GPIO(0)            <= r0_in;
		GPIO(1)            <= g0_in;
		GPIO(2)            <= b0_in;
		GPIO(3)            <= r1_in;
		GPIO(4)            <= g1_in;
		GPIO(5)            <= b1_in;
		GPIO(6)            <= a_s;
		GPIO(7)            <= b_s;
		GPIO(8)            <= c_s;
		GPIO(9)            <= d_s;
		GPIO(10)           <= clk_s;
		GPIO(11)           <= latch_s;
		GPIO(12)           <= oe_s;
		GPIO(35 DOWNTO 13) <= (OTHERS => '0');
END ARCHITECTURE;