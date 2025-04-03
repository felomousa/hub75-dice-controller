-- Felo Mousa - 301586676; Nolan Gola - 301581563; 
-- ENSC 252 || 2024 Fall Semester --
-- BONUS PROJECT --

-- settings module for dice game; allows increment/decrement of number of faces (0–5 → 1–6 faces)
-- and dice (0–3 → 1–4 dice) via key input depending on switch state

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY Settings IS
	PORT (
		clock, reset : IN std_logic;
		switch       : IN std_logic_vector(1 DOWNTO 0);
		key_internal : IN std_logic_vector(3 DOWNTO 0);
		NUM_OF_FACES : OUT std_logic_vector(2 DOWNTO 0);
		NUM_OF_DICE  : OUT std_logic_vector(1 DOWNTO 0)
	);
END ENTITY;

ARCHITECTURE Settings OF Settings IS
	SIGNAL faceCounter    : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";
	SIGNAL numDiceCounter : std_logic_vector(1 DOWNTO 0) := "01";
	SIGNAL editFaces      : std_logic := switch(0);
	SIGNAL editNumDice    : std_logic := switch(1);
BEGIN
	PROCESS (clock, reset)
	BEGIN
		IF reset = '1' THEN
			faceCounter    <= "000";
			numDiceCounter <= "01";

		ELSIF rising_edge(clock) THEN
			IF editFaces = '1' AND editNumDice = '1' THEN
				-- invalid state --

			ELSIF editFaces = '1' THEN
				IF (key_internal(0) = '1') THEN
					IF faceCounter = "101"  THEN
						faceCounter <= "000";
					ELSE
						faceCounter <= std_logic_vector(unsigned(faceCounter) + 1);
					END IF;

				ELSIF (key_internal(3) = '1') THEN
					IF faceCounter = "000" THEN
						faceCounter <= "101";
					ELSE
						faceCounter <= std_logic_vector(unsigned(faceCounter) - 1);
					END IF;
				END IF;

			ELSIF editNumDice = '1' THEN
				IF (key_internal(0) = '1') THEN
					IF unsigned(numDiceCounter) < 3 THEN
						numDiceCounter <= std_logic_vector(unsigned(numDiceCounter) + 1);
					ELSE
						numDiceCounter <= "00";
					END IF;

				ELSIF (key_internal(3) = '1') THEN
					IF unsigned(numDiceCounter) > 0 THEN
						numDiceCounter <= std_logic_vector(unsigned(numDiceCounter) - 1);
					ELSE
						numDiceCounter <= "11";
					END IF;
				END IF;
			END IF;

		END IF;

	END PROCESS;

	NUM_OF_FACES <= faceCounter;
	NUM_OF_DICE  <= numDiceCounter;

END ARCHITECTURE;