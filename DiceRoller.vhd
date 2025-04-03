-- Felo Mousa - 301586676; Nolan Gola - 301581563; 
-- ENSC 252 || 2024 Fall Semester --
-- BONUS PROJECT --

-- cycles through 6 dice face states (1–6) when enable is high on clock edge;
-- outputs current face as 3-bit faceState

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
ENTITY DiceRoller IS
	PORT (
	clock, enable : in std_logic;
	faceState: out std_logic_Vector(2 downto 0)
	);
END ENTITY;
ARCHITECTURE Roller OF DiceRoller IS
TYPE State_type IS (Face_One, Face_Two, Face_Three, Face_Four, Face_Five, Face_Six);
Signal diceNow, diceNext: State_type;
BEGIN

PROCESS(enable, diceNow) -- IF enable, diceNext goes to dice++
BEGIN
	case diceNow IS
        WHEN Face_One =>
            IF enable = '1' THEN
                diceNext <= Face_Two;
            ELSE
                diceNext <= Face_One;
            END IF;
        WHEN Face_Two =>
            IF enable = '1' THEN
                diceNext <= Face_Three;
            ELSE
                diceNext <= Face_Two;
            END IF;
        WHEN Face_Three =>
            IF enable = '1' THEN
                diceNext <= Face_Four;
            ELSE
                diceNext <= Face_Three;
            END IF;
        WHEN Face_Four =>
            IF enable = '1' THEN
                diceNext <= Face_Five;
            ELSE
                diceNext <= Face_Four;
            END IF;
        WHEN Face_Five =>
            IF enable = '1' THEN
                diceNext <= Face_Six;
            ELSE
                diceNext <= Face_Five;
            END IF;
        WHEN Face_Six =>
            IF enable = '1' THEN
                diceNext <= Face_One;
            ELSE
                diceNext <= Face_Six;
            END IF;
	END CASE;
END PROCESS;

process(clock)
BEGIN
    if rising_edge(clock) then
        diceNow <= diceNext;
    end if;
end process;

PROCESS(diceNow)
BEGIN
    CASE diceNow IS 

        WHEN Face_One =>
        faceState <= "001"; -- 1

        WHEN Face_Two =>
        faceState <= "010"; -- 2

        WHEN Face_Three =>
        faceState <= "011"; -- 3

        WHEN Face_Four =>
        faceState <= "100"; -- 4

        WHEN Face_Five =>
        faceState <= "101"; -- 5 

        WHEN Face_Six =>
        faceState <= "110"; -- 6

    END CASE;
END PROCESS;

END Roller;