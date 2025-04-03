-- Felo Mousa - 301586676; Nolan Gola - 301581563; 
-- ENSC 252 || 2024 Fall Semester --
-- BONUS PROJECT --

-- Implements a dice roller FSM cycling through states ONE to SIX.
-- On each clock edge, if isRolling is high, the state advances; otherwise it holds.
-- Each state drives a corresponding value on 7-Seg.

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
ENTITY DiceRoller IS
	PORT (
	clock, isRolling : in std_logic;
	Seg: out std_logic_Vector(2 downto 0)
	);
END ENTITY;
ARCHITECTURE Roller OF DiceRoller IS
TYPE State_type IS (ONE, TWO, THREE, FOUR, FIVE, SIX);
Signal diceNow, diceNext: State_type;
BEGIN

PROCESS(isRolling, diceNow) -- IF isRolling, diceNext goes to dice++
BEGIN
	case diceNow IS
        WHEN ONE =>
            IF isRolling = '1' THEN
                diceNext <= TWO;
            ELSE
                diceNext <= ONE;
            END IF;
        WHEN TWO =>
            IF isRolling = '1' THEN
                diceNext <= THREE;
            ELSE
                diceNext <= TWO;
            END IF;
        WHEN THREE =>
            IF isRolling = '1' THEN
                diceNext <= FOUR;
            ELSE
                diceNext <= THREE;
            END IF;
        WHEN FOUR =>
            IF isRolling = '1' THEN
                diceNext <= FIVE;
            ELSE
                diceNext <= FOUR;
            END IF;
        WHEN FIVE =>
            IF isRolling = '1' THEN
                diceNext <= SIX;
            ELSE
                diceNext <= FIVE;
            END IF;
        WHEN SIX =>
            IF isRolling = '1' THEN
                diceNext <= ONE;
            ELSE
                diceNext <= SIX;
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

        WHEN ONE =>
        Seg <= "001"; -- 1

        WHEN TWO =>
        Seg <= "010"; -- 2

        WHEN THREE =>
        Seg <= "011"; -- 3

        WHEN FOUR =>
        Seg <= "100"; -- 4

        WHEN FIVE =>
        Seg <= "101"; -- 5 

        WHEN SIX =>
        Seg <= "110"; -- 6

    END CASE;
END PROCESS;

END Roller;