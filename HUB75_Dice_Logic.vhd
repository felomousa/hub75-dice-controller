-- Felo Mousa - 301586676; Nolan Gola - 301581563; 
-- ENSC 252 || 2024 Fall Semester --
-- BONUS PROJECT --

-- computes HUB75 LED matrix dice display logic for up to 4 dice
-- uses face inputs to determine dot positions and maps pixel coordinates to dice regions
-- outputs red for dice dots, white for dice background, black elsewhere


LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY HUB75_Dice_Logic IS
	PORT (
		CLOCK_50          : IN std_logic;
		current_row_in    : IN INTEGER RANGE 0 TO 15;
		pixel_count_in    : IN INTEGER RANGE 0 TO 64;
		display_on        : IN std_logic;

		face_left_in      : IN std_logic_vector(2 DOWNTO 0);
		face_center_in    : IN std_logic_vector(2 DOWNTO 0);
		face_right_in     : IN std_logic_vector(2 DOWNTO 0);
		face_far_right_in : IN std_logic_vector(2 DOWNTO 0);

		enable_left       : IN std_logic;
		enable_center     : IN std_logic;
		enable_right      : IN std_logic;
		enable_far_right  : IN std_logic;

		r0_out            : OUT std_logic;
		g0_out            : OUT std_logic;
		b0_out            : OUT std_logic;
		r1_out            : OUT std_logic;
		g1_out            : OUT std_logic;
		b1_out            : OUT std_logic
	);
END ENTITY;

ARCHITECTURE rtl OF HUB75_Dice_Logic IS

	TYPE int_array_12 IS ARRAY (1 TO 12) OF INTEGER;

	CONSTANT DICE_SIZE              : INTEGER := 12;

	CONSTANT CENTER_DICE_X_START    : INTEGER := 22;
	CONSTANT LEFT_DICE_X_START      : INTEGER := 8;
	CONSTANT RIGHT_DICE_X_START     : INTEGER := 36;
	CONSTANT FAR_RIGHT_DICE_X_START : INTEGER := 50;
	CONSTANT DICE_Y_START           : INTEGER := 12;

	FUNCTION is_dot(face            : INTEGER;
		x_in, y_in                      : INTEGER) RETURN BOOLEAN IS
		VARIABLE dots                   : int_array_12 := (OTHERS => - 1);
BEGIN
	CASE face IS
		WHEN 1 => 
			dots := (5, 5, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1);
		WHEN 2 => 
			dots := (2, 2, 8, 8, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1);
		WHEN 3 => 
			dots := (2, 2, 5, 5, 8, 8, - 1, - 1, - 1, - 1, - 1, - 1);
		WHEN 4 => 
			dots := (2, 2, 2, 8, 8, 2, 8, 8, - 1, - 1, - 1, - 1);
		WHEN 5 => 
			dots := (2, 2, 2, 8, 5, 5, 8, 2, 8, 8, - 1, - 1);
		WHEN 6 => 
			dots := (2, 2, 2, 8, 5, 2, 5, 8, 8, 2, 8, 8);
		WHEN OTHERS => RETURN false;
	END CASE;

	FOR idx IN 0 TO 5 LOOP
		IF dots(2 * idx + 1) =- 1 THEN
			EXIT;
		END IF;
		IF ((x_in = dots(2 * idx + 1) AND y_in = dots(2 * idx + 2)) OR
		 (x_in = dots(2 * idx + 1) + 1 AND y_in = dots(2 * idx + 2)) OR
		 (x_in = dots(2 * idx + 1) AND y_in = dots(2 * idx + 2) + 1) OR
		 (x_in = dots(2 * idx + 1) + 1 AND y_in = dots(2 * idx + 2) + 1)) THEN RETURN true;
		END IF;
		END LOOP; RETURN false;
	END FUNCTION;

	SIGNAL r0_s, g0_s, b0_s : std_logic := '1';
	SIGNAL r1_s, g1_s, b1_s : std_logic := '1';

	PROCEDURE pixel_color(
		x, y                                               : INTEGER;
		disp_on                                            : std_logic;
		face_left, face_center, face_right, face_far_right : INTEGER;
		en_left, en_center, en_right, en_far_right         : std_logic;
	SIGNAL r, g, b                                     : OUT std_logic) IS

		VARIABLE in_any_dice                               : BOOLEAN := false;
		VARIABLE dot                                       : BOOLEAN := false;
	BEGIN
		IF disp_on = '1' THEN
			r <= '0';
			g <= '0';
			b <= '0'; RETURN;
		END IF;

		IF en_left = '1' AND (x >= LEFT_DICE_X_START AND x < LEFT_DICE_X_START + DICE_SIZE AND
		 y >= DICE_Y_START AND y < DICE_Y_START + DICE_SIZE) THEN
			in_any_dice := true;
			IF is_dot(face_left, x - LEFT_DICE_X_START, y - DICE_Y_START) THEN
				dot := true;
			END IF;
		END IF;

		IF (NOT in_any_dice) AND en_center = '1' AND
			 (x >= CENTER_DICE_X_START AND x < CENTER_DICE_X_START + DICE_SIZE AND
			 y >= DICE_Y_START AND y < DICE_Y_START + DICE_SIZE) THEN
				in_any_dice := true;
				IF is_dot(face_center, x - CENTER_DICE_X_START, y - DICE_Y_START) THEN
					dot := true;
				END IF;
			END IF;

			IF (NOT in_any_dice) AND en_right = '1' AND
			 (x >= RIGHT_DICE_X_START AND x < RIGHT_DICE_X_START + DICE_SIZE AND
			 y >= DICE_Y_START AND y < DICE_Y_START + DICE_SIZE) THEN
				in_any_dice := true;
				IF is_dot(face_right, x - RIGHT_DICE_X_START, y - DICE_Y_START) THEN
					dot := true;
				END IF;
			END IF;

			IF (NOT in_any_dice) AND en_far_right = '1' AND
				 (x >= FAR_RIGHT_DICE_X_START AND x < FAR_RIGHT_DICE_X_START + DICE_SIZE AND
				 y >= DICE_Y_START AND y < DICE_Y_START + DICE_SIZE) THEN
					in_any_dice := true;
					IF is_dot(face_far_right, x - FAR_RIGHT_DICE_X_START, y - DICE_Y_START) THEN
						dot := true;
					END IF;
				END IF;

				IF in_any_dice THEN
					IF dot THEN
						-- red dot
						r <= '1';
						g <= '0';
						b <= '0';
					ELSE
						-- white dice background 
						r <= '1';
						g <= '1';
						b <= '1';
					END IF;
				ELSE
					-- otherwise OFF
					r <= '0';
					g <= '0';
					b <= '0';
				END IF;
			END PROCEDURE;

			FUNCTION face_val_from_slv(slv : std_logic_vector(2 DOWNTO 0)) RETURN INTEGER IS
				VARIABLE val                   : INTEGER;
				BEGIN
					val := to_integer(unsigned(slv));
					IF val < 1 THEN RETURN 1;
					END IF;
					IF val > 6 THEN RETURN 6;
					END IF; RETURN val;
				END FUNCTION;

				BEGIN
					PROCESS (CLOCK_50, current_row_in, pixel_count_in, display_on, 
						face_left_in, face_center_in, face_right_in, face_far_right_in, 
						enable_left, enable_center, enable_right, enable_far_right)
					VARIABLE x                                      : INTEGER;
					VARIABLE y_top                                  : INTEGER;
					VARIABLE y_bottom                               : INTEGER;
					VARIABLE f_left, f_center, f_right, f_far_right : INTEGER;
					BEGIN
						f_left      := face_val_from_slv(face_left_in);
						f_center    := face_val_from_slv(face_center_in);
						f_right     := face_val_from_slv(face_right_in);
						f_far_right := face_val_from_slv(face_far_right_in);

						x           := pixel_count_in;
						y_top       := current_row_in;
						y_bottom    := current_row_in + 16;

						pixel_color(x, y_top, display_on, f_left, f_center, f_right, f_far_right, 
						enable_left, enable_center, enable_right, enable_far_right, r0_s, g0_s, b0_s);
						pixel_color(x, y_bottom, display_on, f_left, f_center, f_right, f_far_right, 
						enable_left, enable_center, enable_right, enable_far_right, r1_s, g1_s, b1_s);
					END PROCESS;

					r0_out <= r0_s;
					g0_out <= g0_s;
					b0_out <= b0_s;
					r1_out <= r1_s;
					g1_out <= g1_s;
					b1_out <= b1_s;

END ARCHITECTURE;