LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY scalerFSM_tb IS
END scalerFSM_tb;

ARCHITECTURE behavior OF scalerFSM_tb IS

    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT scalerFSM IS
        PORT(
            OutClock : OUT std_logic;
            InClock  : IN std_logic;
            Enable   : IN std_logic
        );
    END COMPONENT;

    -- Signals to connect to UUT
    SIGNAL OutClock   : std_logic;
    SIGNAL InClock    : std_logic := '0';
    SIGNAL Enable     : std_logic := '0';
    CONSTANT clk_period : time := 20 ns; -- 50 MHz input clock period

BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut: scalerFSM PORT MAP (
        OutClock => OutClock,
        InClock  => InClock,
        Enable   => Enable
    );

    -- Clock generation process (50 MHz clock)
    InClock_process : PROCESS
    BEGIN
        WHILE TRUE LOOP
            InClock <= '0';
            WAIT FOR clk_period / 2;
            InClock <= '1';
            WAIT FOR clk_period / 2;
        END LOOP;
    END PROCESS;

    -- Stimulus process
    stimulus_process : PROCESS
    BEGIN
        -- Reset and wait for stabilization
        WAIT FOR 50 ns;
        Enable <= '1'; -- Enable the FSM

        -- Let it run for a simulated second
        WAIT FOR 1 sec;

        -- Disable the FSM and observe for another simulated second
        Enable <= '0';
        WAIT FOR 1 sec;

        -- Re-enable to test state transitions again for another simulated second
        Enable <= '1';
        WAIT FOR 1 sec;

        -- End simulation
        WAIT;
    END PROCESS;

    -- Monitor FSM signals (optional debug)
    monitor_process : PROCESS
    BEGIN
        WHILE TRUE LOOP
            WAIT FOR 1 sec; -- Check every simulated second
            REPORT "Time: " & time'image(NOW) & 
                   ", OutClock: " & std_logic'image(OutClock);
        END LOOP;
    END PROCESS;

END behavior;
