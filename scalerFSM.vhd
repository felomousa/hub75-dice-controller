-- Felo Mousa - 301586676; Nolan Gola - 301581563; 
-- ENSC 252 || 2024 Fall Semester --
-- BONUS PROJECT

--FSM that controls dice roll timing using 3-phase slowdown; 
--outputs scaled clock and active-low Disable to gate rolling; 
--LFSR generates pseudo-random delay before stopping

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity scalerFSM is
    port (
        OutClock, Disable : out std_logic;
        InClock, enable   : in  std_logic;
        reset             : in  std_logic; -- Synchronous reset
        seed              : in  std_logic_vector(3 downto 0) -- New seed input
    );
end entity;


architecture Scaler of scalerFSM is
    type RollState is (Roll_Fast, Roll_Slow, Roll_Slower, Roll_Stopped);
    signal rollNow, rollNext : RollState := Roll_Stopped;
    signal numRolls         : integer := 0;
    signal scaleBy          : integer := 20;
    signal scaledClock      : std_logic;
    signal enableSignal     : std_logic := '0';
    
    -- Pseudo-random value between 0 and 6
    signal random_val : integer range 0 to 6 := 0;
    
    -- LFSR for pseudo-random number generation
    signal lfsr        : std_logic_vector(3 downto 0) := "1001"; -- Default seed
    
    component PreScale is
        port (
            OutClock : out std_logic;
            InClock  : in  std_logic;
            ScaleBy  : in  integer
        );
    end component;

begin

    -- Instantiate PreScale component
    U1 : PreScale
        port map(
            OutClock => scaledClock,
            InClock  => InClock,
            ScaleBy  => scaleBy
        );

    -- LFSR Process: Generates pseudo-random numbers
    process(scaledClock, reset)
    begin
        if reset = '1' then
            lfsr <= seed; -- Initialize LFSR with the seed
            random_val <= 0;
        elsif rising_edge(scaledClock) then
            -- Simple 4-bit LFSR with taps at bit 3 and 2 (example)
            lfsr <= lfsr(2 downto 0) & (lfsr(3) xor lfsr(2));
            
            -- Map LFSR output to 0-6 range
            random_val <= to_integer(unsigned(lfsr)) mod 7;
        end if;
    end process;

    -- FSM Process
    process(scaledClock, reset)
    begin
        if reset = '1' then
            -- Synchronous reset
            rollNow      <= Roll_Stopped;
            rollNext     <= Roll_Stopped;
            numRolls     <= 0;
            scaleBy      <= 20;
            Disable      <= '1';
            enableSignal <= '0';
            -- random_val is reset by LFSR process
        elsif rising_edge(scaledClock) then
            rollNow <= rollNext;

            case rollNow is

                when Roll_Fast =>
                    scaleBy <= 22;
                    if enableSignal = '1' then
                        Disable <= '0';
                        if numRolls >= 20 then
                            rollNext <= Roll_Slow;
                            numRolls <= 0;
                            -- random_val updated by LFSR process
                        else
                            rollNext <= Roll_Fast;
                            numRolls <= numRolls + 1;
                        end if;
                    else
                        rollNext <= Roll_Stopped;
                    end if;

                when Roll_Slow =>
                    scaleBy <= 24;
                    if enableSignal = '1' then
                        Disable <= '0';
                        -- Check if numRolls reached 8 + random_val
                        if numRolls >= (8 + random_val) then
                            rollNext <= Roll_Slower;
                            numRolls <= 0;
                        else
                            rollNext <= Roll_Slow;
                            numRolls <= numRolls + 1;
                        end if;
                    else
                        rollNext <= Roll_Stopped;
                    end if;

                when Roll_Slower =>
                    scaleBy <= 25;
                    if enableSignal = '1' then
                        Disable <= '0';
                        if numRolls >= 1 then
                            rollNext <= Roll_Stopped;
                            numRolls <= 0;
                            enableSignal <= '0'; -- Reset enableSignal after stopping
                        else
                            rollNext <= Roll_Slower;
                            numRolls <= numRolls + 1;
                        end if;
                    else
                        rollNext <= Roll_Stopped;
                    end if;

                when Roll_Stopped =>
                    scaleBy <= 20;
                    Disable <= '1';
                    -- Start rolling if enable is active and FSM is not already enabled
                    if enable = '1' and enableSignal = '0' then
                        rollNext     <= Roll_Fast;
                        numRolls     <= 0;
                        Disable      <= '0';
                        enableSignal <= '1';
                    else
                        rollNext <= Roll_Stopped;
                    end if;

            end case;

        end if;
    end process;

    -- Continuous assignment for OutClock
    OutClock <= scaledClock;

end architecture;
