-- Felo Mousa - 301586676; Nolan Gola - 301581563; 
-- ENSC 252 || 2024 Fall Semester --
-- BONUS PROJECT --


-- top-level SINGLE dice module combining scalerFSM and DiceRoller; 
-- rolls die with pseudo-random stop timing from seed, outputs face
-- via faceState using scaled clock

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

entity Dice is
    port (
        clock     : in  std_logic;
        enable    : in  std_logic;
        faceState : out std_logic_vector(2 downto 0);
        seed      : in  std_logic_vector(3 downto 0)
    );
end entity;


architecture DiceFunction of Dice is
    component scalerFSM is
        port (
            OutClock : out std_logic;
            Disable  : out std_logic;
            InClock  : in  std_logic;
            Enable   : in  std_logic;
            reset    : in  std_logic;
            seed     : in  std_logic_vector(3 downto 0) -- Updated scalerFSM
        );
    end component;

    component DiceRoller is
        port (
            clock      : in  std_logic;
            enable     : in  std_logic;
            faceState  : out std_logic_vector(2 downto 0)
        );
    end component;

    signal scaledClock : std_logic;
    signal disable     : std_logic := '1';

begin

    -- Instantiate scalerFSM with seed input
    U1: scalerFSM
        port map(
            InClock  => clock,
            OutClock => scaledClock,
            Disable  => disable,
            Enable   => enable,
            reset    => reset_sig,
            seed     => seed -- Pass the unique seed
        );

    -- Instantiate DiceRoller
    U2: DiceRoller
        port map(
            clock      => scaledClock,
            enable     => not(disable),
            faceState  => faceState
        );

end architecture;
