-- Felo Mousa - 301586676; Nolan Gola - 301581563; 
-- ENSC 252 || 2024 Fall Semester --
-- BONUS PROJECT --LIBRARY ieee;

-- This module implements a finite state machine (FSM) that scales an input clock signal across four speed states: FAST, SLOW, SLOWER, and STOPPED. 
-- It uses a PreScale submodule to divide the clock signal based on the current state.
-- Transitions between states are controlled by a counter and the enable input, with progressively slower scaling until the system stops.

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
ENTITY scalerFSM IS
	PORT (
	OutClock : OUT std_logic;
	InClock, enable : IN std_logic);
END ENTITY;

ARCHITECTURE Scaler OF scalerFSM IS
	signal moveToNextState, modifiedFinal, CounterSize : integer range 0 to 5000;
	signal ScalerEnable : std_logic := '1';
	TYPE ScaleState IS (FAST, SLOW, SLOWER, STOPPED);
	Signal scaleNow, scaleNext: ScaleState;
		
	COMPONENT PreScale IS
	PORT (
		OutClock : OUT std_logic;
		InClock, enable : IN std_logic;
		ScaleBy, currentCount : IN INTEGER;
		finalCount : OUT INTEGER);
	END COMPONENT;

BEGIN 
process(InClock)
BEGIN
    if rising_edge(InClock) then
        scaleNow <= scaleNext;
		  moveToNextState <= modifiedFinal;
    end if;
end process;

PROCESS(enable, scaleNow)
BEGIN
	case scaleNow IS
        WHEN FAST =>
		      CounterSize <= 10;
				ScalerEnable <= '1';
            IF moveToNextState >= 10 THEN
                scaleNext <= SLOW;
            ELSE
                scaleNext <= FAST;
            END IF;
        WHEN SLOW =>
		  		CounterSize <= 15;
				ScalerEnable <= '1';
            IF moveToNextState >= 25 THEN
                scaleNext <= SLOWER;
            ELSE
                scaleNext <= SLOW;
            END IF;
        WHEN SLOWER =>
		      CounterSize <= 22;
				ScalerEnable <= '1';
            IF moveToNextState >= 28 THEN
                scaleNext <= STOPPED;
					 ScalerEnable <= '0';
            ELSE
                scaleNext <= SLOWER;
            END IF;
        WHEN STOPPED =>
				ScalerEnable <= '0';
            IF enable = '1' THEN
                scaleNext <= FAST;
            ELSE
                scaleNext <= STOPPED;
            END IF;
	END CASE;
END PROCESS;


U1: PreScale
PORT MAP(
OutClock => OutClock,
InClock => InClock,
ScaleBy => CounterSize,
currentCount => moveToNextState,
finalCount => modifiedFinal,
enable => ScalerEnable);


END Scaler;




