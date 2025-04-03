-- Felo Mousa - 301586676; Nolan Gola - 301581563;
-- ENSC 252 || 2024 Fall Semester --
-- BONUS PROJECT --

-- instantiate 4 times, rand + roll

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
ENTITY RollDice IS
	PORT (
		clock, enable, roll : IN std_logic;
		faceState : OUT std_logic_vector(2 DOWNTO 0);
		scaleBy : IN INTEGER
	);
END ENTITY;

ARCHITECTURE THING OF RollDice IS
	COMPONENT DiceRoller IS
		PORT (
			clock, enable : IN std_logic;
			faceState : OUT std_logic_Vector(2 DOWNTO 0)
		);
	END COMPONENT;
	
	COMPONENT PreScale IS
		PORT (
			OutClock : OUT std_logic;
			InClock : IN std_logic;
			ScaleBy : IN INTEGER
		);
	END COMPONENT;
 
	SIGNAL temp_clock, beginRolling : std_logic;
	SIGNAL delay : unsigned(30 DOWNTO 0) := (OTHERS => '0');
BEGIN
	U1 : PreScale
	PORT MAP(
		InClock => clock, 
		OutClock => temp_clock, 
		ScaleBy => scaleBy
	);

	U2 : DiceRoller
	PORT MAP(
		clock => temp_clock, 
		faceState => faceState, 
		enable => beginRolling
	);
 

	PROCESS (clock, enable, roll)
	BEGIN
		IF rising_edge(clock) THEN

			IF enable = '1' AND roll = '1' THEN
				beginRolling <= '1';
				delay <= (OTHERS => '0');
			END IF;

			IF (beginRolling = '1' AND delay(30) = '0') THEN
				delay <= delay + 1;
			ELSIF delay(30) = '1' THEN
				beginRolling <= '0';
				delay <= (OTHERS => '0');
			END IF;
		END IF;

	END PROCESS;
END ARCHITECTURE;