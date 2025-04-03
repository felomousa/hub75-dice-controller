-- Felo Mousa - 301586676; Nolan Gola - 301581563; 
-- ENSC 252 || 2024 Fall Semester --
-- BONUS PROJECT --

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY Top IS
	PORT (
		CLOCK_50 : IN std_logic;
		SW       : IN std_logic_vector(9 DOWNTO 0);
		KEY      : IN std_logic_vector(3 DOWNTO 0);
		GPIO     : OUT std_logic_vector(35 DOWNTO 0)
	);
END ENTITY;

ARCHITECTURE rtl OF Top IS
	SIGNAL current_row_sig        : INTEGER RANGE 0 TO 15;
	SIGNAL pixel_count_sig        : INTEGER RANGE 0 TO 64;
	SIGNAL r0_sig, g0_sig, b0_sig : std_logic;
	SIGNAL r1_sig, g1_sig, b1_sig : std_logic;
	SIGNAL face_center_in         : std_logic_vector(2 DOWNTO 0);
	SIGNAL face_left_in           : std_logic_vector(2 DOWNTO 0);
	SIGNAL face_right_in          : std_logic_vector(2 DOWNTO 0);
	SIGNAL enable_center          : std_logic := KEY(0);
	SIGNAL enable_left            : std_logic := KEY(1);
	SIGNAL enable_right           : std_logic := KEY(2);
	SIGNAL display_off            : std_logic := SW(9);
	SIGNAL scaledClock            : std_logic := '0';
	SIGNAL scaledClock1           : std_logic := '0';
	SIGNAL scaledClock2           : std_logic := '0';
	SIGNAL rolling                : std_logic := '0';
	SIGNAL rolling1               : std_logic := '1';
	SIGNAL stopRolling            : std_logic := '0';
	COMPONENT PreScale IS
		PORT (
			OutClock        : OUT std_logic;
			InClock, enable : IN std_logic;
			ScaleBy         : IN INTEGER
		);
	END COMPONENT;

	COMPONENT DiceRoller IS
		PORT (
			clock, isRolling : IN std_logic;
			Seg              : OUT std_logic_Vector(2 DOWNTO 0)
		);
	END COMPONENT;
BEGIN
	U1 : PreScale
	PORT MAP(
		InClock  => CLOCK_50, 
		OutClock => scaledClock, 
		enable   => rolling, 
		scaleBy  => 22
	);

	U2 : PreScale
	PORT MAP(
		InClock  => CLOCK_50, 
		OutClock => scaledClock1, 
		enable   => rolling, 
		scaleBy  => 24
	);

	U3 : PreScale
	PORT MAP(
		InClock  => CLOCK_50, 
		OutClock => scaledClock2, 
		enable   => rolling, 
		scaleBy  => 25
	);

	U4 : DiceRoller
	PORT MAP(
		clock     => scaledClock1, 
		isRolling => NOT(KEY(3)), 
		Seg       => face_left_in
	);

	U5 : DiceRoller
	PORT MAP(
		clock     => scaledClock2, 
		isRolling => NOT(KEY(3)), 
		Seg       => face_center_in
	);

	U6 : DiceRoller
	PORT MAP(
		clock     => scaledClock, 
		isRolling => NOT(KEY(3)), 
		Seg       => face_right_in
	);
	
	Logic_inst : ENTITY work.HUB75_Dice_Logic
		PORT MAP(
			CLOCK_50          => CLOCK_50, 
			current_row_in    => current_row_sig, 
			pixel_count_in    => pixel_count_sig, 
			display_on        => display_off, 
			face_left_in      => face_left_in, 
			face_center_in    => face_center_in, 
			face_right_in     => face_right_in, 
			enable_left       => enable_left, 
			enable_center     => enable_center, 
			enable_right      => enable_right, 
			r0_out            => r0_sig, 
			g0_out            => g0_sig, 
			b0_out            => b0_sig, 
			r1_out            => r1_sig, 
			g1_out            => g1_sig, 
			b1_out            => b1_sig, 
			face_far_right_in => face_center_in, 
			enable_far_right  => enable_right
		);

	Driver_inst : ENTITY work.HUB75_Controller
		PORT MAP(
			CLOCK_50        => CLOCK_50, 
			r0_in           => r0_sig, 
			g0_in           => g0_sig, 
			b0_in           => b0_sig, 
			r1_in           => r1_sig, 
			g1_in           => g1_sig, 
			b1_in           => b1_sig, 
			GPIO            => GPIO, 
			current_row_out => current_row_sig, 
			pixel_count_out => pixel_count_sig
		);

END ARCHITECTURE;