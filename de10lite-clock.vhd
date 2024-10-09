library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity clock_display is
    Port (
        clk : in STD_LOGIC;              -- Clock input (assuming 50 MHz)
        SW : in STD_LOGIC_VECTOR(0 downto 0);  -- Switches (SW[0] tied to reset)
        KEY : in STD_LOGIC_VECTOR(1 downto 0);  -- Keys (KEY[0] to increase minutes, KEY[1] to increase hours)
        HEX0 : out STD_LOGIC_VECTOR(6 downto 0); -- Segment output for seconds (units)
        HEX1 : out STD_LOGIC_VECTOR(6 downto 0); -- Segment output for seconds (tens)
        HEX2 : out STD_LOGIC_VECTOR(6 downto 0); -- Segment output for minutes (units)
        HEX3 : out STD_LOGIC_VECTOR(6 downto 0); -- Segment output for minutes (tens)
        HEX4 : out STD_LOGIC_VECTOR(6 downto 0); -- Segment output for hours (units)
        HEX5 : out STD_LOGIC_VECTOR(6 downto 0); -- Segment output for hours (tens)
        dp0 : out STD_LOGIC;
        dp1 : out STD_LOGIC;
        dp2 : out STD_LOGIC;
        dp3 : out STD_LOGIC;
        dp4 : out STD_LOGIC;
        dp5 : out STD_LOGIC
    );
end clock_display;

architecture Behavioral of clock_display is
    signal reset : STD_LOGIC;

    -- Clocks
    signal clk_separators : STD_LOGIC := '0';
    signal clk_counter : INTEGER := 0;
    constant CLK_DIVIDER : INTEGER := 50000000 - 1; -- To generate 1 pulse every second
    signal clk_1hz : STD_LOGIC := '0';      -- 1 Hz clock signal to increment seconds

    -- Signals to hold time values
    signal seconds_units : INTEGER range 0 to 9 := 0;
    signal seconds_tens  : INTEGER range 0 to 5 := 0;
    signal minutes_units : INTEGER range 0 to 9 := 0;
    signal minutes_tens  : INTEGER range 0 to 5 := 0;
    signal hours_units   : INTEGER range 0 to 9 := 0;
    signal hours_tens    : INTEGER range 0 to 2 := 0;

    -- Signals to detect key presses
    signal key_prev : STD_LOGIC_VECTOR(1 downto 0) := "00";
    signal key_curr : STD_LOGIC_VECTOR(1 downto 0);

    -- Signals for driving seven_segment_display instances
    signal digit_seconds_units : STD_LOGIC_VECTOR(3 downto 0);
    signal digit_seconds_tens  : STD_LOGIC_VECTOR(3 downto 0);
    signal digit_minutes_units : STD_LOGIC_VECTOR(3 downto 0);
    signal digit_minutes_tens  : STD_LOGIC_VECTOR(3 downto 0);
    signal digit_hours_units   : STD_LOGIC_VECTOR(3 downto 0);
    signal digit_hours_tens    : STD_LOGIC_VECTOR(3 downto 0);

begin
    -- Tie the reset signal to the physical switch on the board
    reset <= SW(0);
    
    -- Synchronize the time separators with the corresponding signal
    dp0 <= '1';
    dp1 <= '1';
    dp2 <= clk_separators;
    dp3 <= '1';
    dp4 <= clk_separators;
    dp5 <= '1';

    -- Clock divider process: Generate 1 Hz clock and signal to blink separators
    process(clk)
    begin
        if rising_edge(clk) then
            if clk_counter = CLK_DIVIDER then -- create very short pulse every second
                clk_1hz <= '1';  
                clk_separators <= not clk_separators; -- invert separator signal to create a slow (0.5Hz) blink
                clk_counter <= 0;
            else
                clk_1hz <= '0';  -- clk_1hz is high for only 1 clock cycle, otherwise low
                clk_counter <= clk_counter + 1;
            end if;
        end if;
    end process;

    -- Unified process to handle both time counting and key press detection
    process(clk, reset)
    begin
        if reset = '1' then
            -- Reset all time values to zero
            seconds_units <= 0;
            seconds_tens <= 0;
            minutes_units <= 0;
            minutes_tens <= 0;
            hours_units <= 0;
            hours_tens <= 0;
            key_prev <= "00";
            key_curr <= "00";
        elsif rising_edge(clk) then
            -- Store previous key state for edge detection (active low)
            key_prev <= key_curr;
            key_curr <= not KEY;  -- Invert KEY because buttons are active low

            -- Key press detection (only increment when key press is detected)
            if key_prev(0) = '0' and key_curr(0) = '1' then
                -- Increment minutes when KEY[0] is pressed
                if minutes_units = 9 then
                    minutes_units <= 0;
                    if minutes_tens = 5 then
                        minutes_tens <= 0;
                    else
                        minutes_tens <= minutes_tens + 1;
                    end if;
                else
                    minutes_units <= minutes_units + 1;
                end if;
            end if;

            if key_prev(1) = '0' and key_curr(1) = '1' then
                -- Increment hours when KEY[1] is pressed
                if hours_units = 3 and hours_tens = 2 then
                    hours_units <= 0;
                    hours_tens <= 0;
                elsif hours_units = 9 then
                    hours_units <= 0;
                    hours_tens <= hours_tens + 1;
                else
                    hours_units <= hours_units + 1;
                end if;
            end if;

            -- Increment the seconds every second
            if clk_1hz = '1' then
                if seconds_units = 9 then
                    seconds_units <= 0;
                    if seconds_tens = 5 then
                        seconds_tens <= 0;
                        -- Increment the minutes
                        if minutes_units = 9 then
                            minutes_units <= 0;
                            if minutes_tens = 5 then
                                minutes_tens <= 0;
                                -- Increment the hours
                                if hours_units = 3 and hours_tens = 2 then -- Reset after 23:59:59
                                    hours_units <= 0;
                                    hours_tens <= 0;  
                                elsif hours_units = 9 then
                                    hours_units <= 0;
                                    hours_tens <= hours_tens + 1;
                                else
                                    hours_units <= hours_units + 1;
                                end if;
                            else
                                minutes_tens <= minutes_tens + 1;
                            end if;
                        else
                            minutes_units <= minutes_units + 1;
                        end if;
                    else
                        seconds_tens <= seconds_tens + 1;
                    end if;
                else
                    seconds_units <= seconds_units + 1;
                end if;
            end if;
        end if;
    end process;

    -- Convert time values to 4-bit BCD for each seven-segment display
    digit_seconds_units <= std_logic_vector(to_unsigned(seconds_units, 4));
    digit_seconds_tens  <= std_logic_vector(to_unsigned(seconds_tens, 4));
    digit_minutes_units <= std_logic_vector(to_unsigned(minutes_units, 4));
    digit_minutes_tens  <= std_logic_vector(to_unsigned(minutes_tens, 4));
    digit_hours_units   <= std_logic_vector(to_unsigned(hours_units, 4));
    digit_hours_tens    <= std_logic_vector(to_unsigned(hours_tens, 4));

    -- Instantiate the seven_segment_display modules
    U0 : entity work.seven_segment_display
        port map (
            clk => clk,
            digit => digit_seconds_units,
            segments => HEX0
        );

    U1 : entity work.seven_segment_display
        port map (
            clk => clk,
            digit => digit_seconds_tens,
            segments => HEX1
        );

    U2 : entity work.seven_segment_display
        port map (
            clk => clk,
            digit => digit_minutes_units,
            segments => HEX2
        );

    U3 : entity work.seven_segment_display
        port map (
            clk => clk,
            digit => digit_minutes_tens,
            segments => HEX3
        );

    U4 : entity work.seven_segment_display
        port map (
            clk => clk,
            digit => digit_hours_units,
            segments => HEX4
        );

    U5 : entity work.seven_segment_display
        port map (
            clk => clk,
            digit => digit_hours_tens,
            segments => HEX5
        );

end Behavioral;
