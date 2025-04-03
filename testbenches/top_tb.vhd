library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Top_tb is
end entity;

architecture behavior of Top_tb is

    -- component declarations
    component Top is
        port(
            CLOCK_50 : in  std_logic;
            SW       : in  std_logic_vector(9 downto 0);
            KEY      : in  std_logic_vector(3 downto 0);
            GPIO     : out std_logic_vector(35 downto 0)
        );
    end component;

    signal CLOCK_50_tb : std_logic := '0';
    signal SW_tb       : std_logic_vector(9 downto 0) := (others => '0');
    signal KEY_tb      : std_logic_vector(3 downto 0) := (others => '1'); -- keys active low
    signal GPIO_tb     : std_logic_vector(35 downto 0);

    -- internal signals we want to watch from U1, U2
    -- we can watch them through the top-level signals indirectly by enabling or disabling
    -- but since they aren't top-level outputs, we rely on testbench observation only.
    -- We'll just run the simulation and observe them in a waveform viewer.

begin

    -- instantiate the top
    DUT: Top
        port map(
            CLOCK_50 => CLOCK_50_tb,
            SW       => SW_tb,
            KEY      => KEY_tb,
            GPIO     => GPIO_tb
        );

    -- clock generation: 20 ns period for 50 MHz clock
    process
    begin
        CLOCK_50_tb <= '0';
        wait for 10 ns;
        CLOCK_50_tb <= '1';
        wait for 10 ns;
    end process;

    -- stimulus
    process
    begin
        -- initial conditions
        SW_tb <= (others => '0');
        KEY_tb <= (others => '1');  -- key not pressed
        wait for 200 ns; 

        -- press key(0) to enable rolling
        KEY_tb(0) <= '0';  
        wait for 2000 ns;

        -- release key(0) to stop enabling
        KEY_tb(0) <= '1';
        wait for 2000 ns;

        wait;
    end process;

end architecture;
