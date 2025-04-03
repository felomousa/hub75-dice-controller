-- Felo Mousa - 301586676; Nolan Gola - 301581563; 
-- ENSC 252 || 2024 Fall Semester --
-- BONUS PROJECT --

-- tests the PreScale module by dividing CLOCK_50 and toggling an LED on the divided clock's rising edge

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.numeric_std.ALL;
ENTITY PreScaleTester IS
	PORT (
	CLOCK_50: in std_logic;
	LEDR : out std_logic_Vector(0 downto 0)
	);
END ENTITY;
ARCHITECTURE Tester OF PreScaleTester IS
COMPONENT PreScale IS
	PORT (
		OutClock : OUT std_logic;
		InClock, enable : IN std_logic;
		ScaleBy, currentCount : IN INTEGER);
END COMPONENT;

signal bool, st : std_logic;
BEGIN

U1 : PreScale
PORT MAP (
InClock => CLOCK_50,
OutClock => bool,
enable => '1',
ScaleBy => 30,
currentCount => 10);

process(bool)
begin
if rising_edge(bool) THEN
 st <= not(st);
 LEDR(0) <= st;
 END IF;
END PROCESS;

END ARCHITECTURE;