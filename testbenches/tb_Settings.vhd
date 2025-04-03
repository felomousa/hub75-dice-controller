-- Testbench for Settings module
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY tb_Settings IS
END ENTITY;

ARCHITECTURE behavior OF tb_Settings IS

    -- Component declaration for the unit under test (UUT)
    COMPONENT Settings
        PORT (
            clock        : IN std_logic;
            reset        : IN std_logic;
            switch       : IN std_logic_vector(1 DOWNTO 0);
            key_internal : IN std_logic_vector(3 DOWNTO 0);
            NUM_OF_FACES : OUT std_logic_vector(2 DOWNTO 0);
            NUM_OF_DICE  : OUT std_logic_vector(1 DOWNTO 0)
        );
    END COMPONENT;

    -- Signals to connect to the UUT
    SIGNAL clock        : std_logic := '0';
    SIGNAL reset        : std_logic := '0';
    SIGNAL switch       : std_logic_vector(1 DOWNTO 0) := "00";
    SIGNAL key_internal : std_logic_vector(3 DOWNTO 0) := "0000";
    SIGNAL NUM_OF_FACES : std_logic_vector(2 DOWNTO 0);
    SIGNAL NUM_OF_DICE  : std_logic_vector(1 DOWNTO 0);

    -- Clock period definition
    CONSTANT clock_period : time := 10 ns;

BEGIN

    -- Instantiate the Unit Under Test (UUT)
    UUT: Settings
        PORT MAP (
            clock        => clock,
            reset        => reset,
            switch       => switch,
            key_internal => key_internal,
            NUM_OF_FACES => NUM_OF_FACES,
            NUM_OF_DICE  => NUM_OF_DICE
        );

    -- Clock process definition
    clock_process : PROCESS
    BEGIN
        clock <= '0';
        WAIT FOR clock_period / 2;
        clock <= '1';
        WAIT FOR clock_period / 2;
    END PROCESS;

    -- Stimulus process
    stim_proc: PROCESS
    BEGIN
        -- Initial reset
        reset <= '1';
        WAIT FOR clock_period;
        reset <= '0';
        WAIT FOR clock_period;

        -- Wait for a few clock cycles
        WAIT FOR 2 * clock_period;

        -- Test 1: Increment NUM_OF_FACES
        report "Test 1: Increment NUM_OF_FACES";
        switch <= "01"; -- Enable editing of NUM_OF_FACES

        -- Press key_internal(0) to increment
        key_internal <= "0001"; -- Press key_internal(0)
        WAIT FOR clock_period;
        key_internal <= "0000"; -- Release key
        WAIT FOR clock_period;

        -- Press key_internal(0) multiple times to reach wrap-around
        FOR i IN 1 TO 6 LOOP
            report "Pressing key_internal(0) to increment NUM_OF_FACES";
            key_internal <= "0001"; -- Press increment key
            WAIT FOR clock_period;
            key_internal <= "0000"; -- Release key
            WAIT FOR clock_period;
        END LOOP;

        -- Test 2: Decrement NUM_OF_FACES
        report "Test 2: Decrement NUM_OF_FACES";

        -- Press key_internal(3) to decrement
        key_internal <= "1000"; -- Press key_internal(3)
        WAIT FOR clock_period;
        key_internal <= "0000"; -- Release key
        WAIT FOR clock_period;

        -- Press key_internal(3) multiple times to reach wrap-around
        FOR i IN 1 TO 6 LOOP
            report "Pressing key_internal(3) to decrement NUM_OF_FACES";
            key_internal <= "1000"; -- Press decrement key
            WAIT FOR clock_period;
            key_internal <= "0000"; -- Release key
            WAIT FOR clock_period;
        END LOOP;

        -- Test 3: Increment NUM_OF_DICE
        report "Test 3: Increment NUM_OF_DICE";
        switch <= "10"; -- Enable editing of NUM_OF_DICE

        -- Press key_internal(0) to increment
        key_internal <= "0001"; -- Press key_internal(0)
        WAIT FOR clock_period;
        key_internal <= "0000"; -- Release key
        WAIT FOR clock_period;

        -- Press key_internal(0) multiple times to reach wrap-around
        FOR i IN 1 TO 4 LOOP
            report "Pressing key_internal(0) to increment NUM_OF_DICE";
            key_internal <= "0001"; -- Press increment key
            WAIT FOR clock_period;
            key_internal <= "0000"; -- Release key
            WAIT FOR clock_period;
        END LOOP;

        -- Test 4: Decrement NUM_OF_DICE
        report "Test 4: Decrement NUM_OF_DICE";

        -- Press key_internal(3) to decrement
        key_internal <= "1000"; -- Press key_internal(3)
        WAIT FOR clock_period;
        key_internal <= "0000"; -- Release key
        WAIT FOR clock_period;

        -- Press key_internal(3) multiple times to reach wrap-around
        FOR i IN 1 TO 4 LOOP
            report "Pressing key_internal(3) to decrement NUM_OF_DICE";
            key_internal <= "1000"; -- Press decrement key
            WAIT FOR clock_period;
            key_internal <= "0000"; -- Release key
            WAIT FOR clock_period;
        END LOOP;

        -- Test 5: Invalid state (both switches active)
        report "Test 5: Invalid State - Both switches active";
        switch <= "11"; -- Enable both switches

        -- Attempt to press increment key
        key_internal <= "0001"; -- Press key_internal(0)
        WAIT FOR clock_period;
        key_internal <= "0000"; -- Release key
        WAIT FOR clock_period;

        -- Attempt to press decrement key
        key_internal <= "1000"; -- Press key_internal(3)
        WAIT FOR clock_period;
        key_internal <= "0000"; -- Release key
        WAIT FOR clock_period;

        -- Ensure no changes occurred
        report "Verify that NUM_OF_FACES and NUM_OF_DICE did not change";

        -- Return switches to default
        switch <= "00"; -- Disable editing
        WAIT FOR 2 * clock_period;

        -- End simulation
        report "End of Testbench";
        WAIT;
    END PROCESS;

    -- Monitor process to display output values on rising edge of clock
    monitor_proc: PROCESS(clock)
    BEGIN
        IF rising_edge(clock) THEN
            report "At time " & time'image(now) & ": NUM_OF_FACES = " & integer'image(to_integer(unsigned(NUM_OF_FACES))) &
                   ", NUM_OF_DICE = " & integer'image(to_integer(unsigned(NUM_OF_DICE)));
        END IF;
    END PROCESS;

END ARCHITECTURE;
