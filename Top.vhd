-- Felo Mousa - 301586676; Nolan Gola - 301581563; 
-- ENSC 252 || 2024 Fall Semester --
-- BONUS PROJECT --
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

-- top-level module integrating dice settings, logic, and rendering; reads switches/keys to configure number of dice and faces,
-- generates face signals, and drives HUB75 LED matrix output via GPIO

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
	SIGNAL face_dice_2            : std_logic_vector(2 DOWNTO 0);
	SIGNAL face_dice_3            : std_logic_vector(2 DOWNTO 0);
	SIGNAL face_dice_1            : std_logic_vector(2 DOWNTO 0);
	SIGNAL face_dice_0            : std_logic_vector(2 DOWNTO 0);
	SIGNAL enable_dice_2          : std_logic := SW(1);
	SIGNAL enable_dice_3          : std_logic := SW(0);
	SIGNAL enable_dice_1          : std_logic := SW(2);
	SIGNAL enable_dice_0          : std_logic := SW(3);
	SIGNAL display_off            : std_logic := SW(9);
   SIGNAL NUM_OF_FACES           : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL NUM_OF_DICE            : std_logic_vector(1 DOWNTO 0);

	COMPONENT Settings IS
	PORT (
		clock, reset : IN std_logic;
		switch       : IN std_logic_vector(1 DOWNTO 0);
		key_internal : IN std_logic_vector(3 DOWNTO 0);
		NUM_OF_FACES : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		NUM_OF_DICE  : OUT std_logic_vector(1 DOWNTO 0)
	);
	END COMPONENT;
	BEGIN
	
	U1 : Settings
	PORT MAP(
	clock => CLOCK_50,
	switch => SW(1 DOWNTO 0),
	key_internal => not(KEY(3 DOWNTO 0)),
	reset => SW(8),
	NUM_OF_FACES => NUM_OF_FACES,
	NUM_OF_DICE => NUM_OF_DICE);
	
	face_dice_0 <= NUM_OF_FACES;
	face_dice_1 <= NUM_OF_FACES;
	face_dice_2 <= NUM_OF_FACES;
	face_dice_3 <= NUM_OF_FACES;
	
	 PROCESS(NUM_OF_DICE)
	 BEGIN
		  CASE NUM_OF_DICE IS
				WHEN "00" =>
					 enable_dice_0 <= '1';
					 enable_dice_1 <= '0';
					 enable_dice_2 <= '0';
					 enable_dice_3 <= '0';
				WHEN "01" =>
					 enable_dice_0 <= '1';
					 enable_dice_1 <= '1';
					 enable_dice_2 <= '0';
					 enable_dice_3 <= '0';
				WHEN "10" =>
					 enable_dice_0 <= '1';
					 enable_dice_1 <= '1';
					 enable_dice_2 <= '1';
					 enable_dice_3 <= '0';
				WHEN "11" =>
					 enable_dice_0 <= '1';
					 enable_dice_1 <= '1';
					 enable_dice_2 <= '1';
					 enable_dice_3 <= '1';
		  END CASE;
	 END PROCESS;




	Logic_inst : ENTITY work.HUB75_Dice_Logic
		PORT MAP(
			CLOCK_50          => CLOCK_50, 
			current_row_in    => current_row_sig, 
			pixel_count_in    => pixel_count_sig, 
			display_on        => display_off, 
			face_dice_3       => face_dice_3, 
			face_dice_2       => face_dice_2, 
			face_dice_1       => face_dice_1, 
			enable_dice_3     => enable_dice_3, 
			enable_dice_2     => enable_dice_2, 
			enable_dice_1     => enable_dice_1, 
			face_dice_0       => face_dice_0, 
			enable_dice_0     => enable_dice_0,
			r0_out            => r0_sig, 
			g0_out            => g0_sig, 
			b0_out            => b0_sig, 
			r1_out            => r1_sig, 
			g1_out            => g1_sig, 
			b1_out            => b1_sig 
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
