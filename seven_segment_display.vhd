library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity seven_segment_display is
    Port (
        clk : in STD_LOGIC;  -- Clock signal
        digit : in STD_LOGIC_VECTOR(3 downto 0);  -- 4-bit input for the digit (0-9)
        segments : out STD_LOGIC_VECTOR(6 downto 0)  -- Outputs for the 7-segment display
    );
end seven_segment_display;

architecture RTL of seven_segment_display is
    signal seg_reg : STD_LOGIC_VECTOR(6 downto 0);  -- Register for storing segment data
begin
    -- Sequential logic to update the display register on every clock edge
    process(clk)
    begin
        if rising_edge(clk) then
            case digit is
                when "0000" =>  -- Digit 0
                    seg_reg <= "1000000"; -- a,b,c,d,e,f are on, g is off
                when "0001" =>  -- Digit 1
                    seg_reg <= "1111001"; -- b,c are on
                when "0010" =>  -- Digit 2
                    seg_reg <= "0100100"; -- a,b,d,e,g are on
                when "0011" =>  -- Digit 3
                    seg_reg <= "0110000"; -- a,b,c,d,g are on
                when "0100" =>  -- Digit 4
                    seg_reg <= "0011001"; -- b,c,f,g are on
                when "0101" =>  -- Digit 5
                    seg_reg <= "0010010"; -- a,c,d,f,g are on
                when "0110" =>  -- Digit 6
                    seg_reg <= "0000010"; -- a,c,d,e,f,g are on
                when "0111" =>  -- Digit 7
                    seg_reg <= "1111000"; -- a,b,c are on
                when "1000" =>  -- Digit 8
                    seg_reg <= "0000000"; -- All segments are on
                when "1001" =>  -- Digit 9
                    seg_reg <= "0010000"; -- a,b,c,d,f,g are on
                when others =>
                    seg_reg <= "1111111"; -- All segments off (blank)
            end case;
        end if;
    end process;

    -- Combinational logic to drive the segments
    segments <= seg_reg;
	
end RTL;
