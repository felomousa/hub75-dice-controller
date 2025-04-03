-- Felo Mousa - 301586676; Nolan Gola - 301581563; Wasim Mahmood - 301583857;
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
ENTITY PreScale IS
	PORT (
		OutClock : OUT std_logic;
		InClock : IN std_logic;
		ScaleBy : IN INTEGER);
END ENTITY;

ARCHITECTURE accumulator OF PreScale IS
	SIGNAL counter, dynamicTemp : unsigned(30 DOWNTO 0):= (OTHERS => '0');
	SIGNAL fullcounter : unsigned(30 DOWNTO 0) := (OTHERS => '1');
BEGIN
	PROCESS (InClock) IS
	BEGIN
		IF rising_edge(InClock) THEN
		   dynamicTemp(30 DOWNTO 0) <= (OTHERS => '0'); -- Reset
			dynamicTemp(scaleBy-1 DOWNTO 0) <= (OTHERS => '1'); -- Full
				IF (counter AND dynamicTemp) = (fullcounter AND dynamicTemp) THEN
					OutClock <= '1';
					counter <= (OTHERS => '0');
				ELSE
					OutClock <= '0';
					counter <= counter + 1;
				END IF;
			END IF;
	END PROCESS;
END accumulator;
