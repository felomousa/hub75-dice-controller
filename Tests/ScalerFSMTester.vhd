-- Felo Mousa - 301586676; Nolan Gola - 301581563; 
-- ENSC 252 || 2024 Fall Semester --
-- BONUS PROJECT --

-- tests scalerFSM by toggling an LED on the scaled clock output, with enable controlled by KEY(0)

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
ENTITY ScalerFSMTester IS
	PORT (
	CLOCK_50: in std_logic;
	KEY : in std_logic_vector(1 downto 0);
	LEDR : out std_logic_Vector(6 downto 0)
	);
END ENTITY;
ARCHITECTURE Tester OF ScalerFSMTester IS
COMPONENT scalerFSM IS
	PORT (
		OutClock : OUT std_logic;
		InClock, enable : IN std_logic
	);
END COMPONENT;
signal bool, st : std_logic;
BEGIN

U1 : scalerFSM
PORT MAP (
InClock => CLOCK_50,
OutClock => bool,
enable => not(key(0)));

process(bool)
begin
if rising_edge(bool) THEN
 st <= not(st);
 LEDR(0) <= st;
 END IF;
END PROCESS;


END ARCHITECTURE;