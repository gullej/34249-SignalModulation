LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY hard_decision IS
    GENERIC (
        DATA_WIDTH : INTEGER);
    PORT (
        rst         : IN  STD_LOGIC;
        clk         : IN  STD_LOGIC;
        --
        rx_dat      : IN  STD_LOGIC_VECTOR(27 DOWNTO 0);
        rx_val      : IN  STD_LOGIC;
        --
        tx_dat      : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        tx_val      : OUT STD_LOGIC
    );
END hard_decision;

ARCHITECTURE hard_decision_arc OF hard_decision IS

CONSTANT thresh_pos : SIGNED(27 DOWNTO 0) := "0000000010000000000000000000";
CONSTANT thresh_neg : SIGNED(27 DOWNTO 0) := "1111111110000000000000000000";

BEGIN

PROCESS (clk)
BEGIN
    IF (rising_edge(clk)) THEN
        tx_val <= '0';
        tx_dat <= "00";

        IF (rx_val = '1') THEN
            tx_val <= '1';
            IF (signed(rx_dat) > thresh_pos) THEN
                tx_dat <= "10";
            elsif (signed(rx_dat) > 0) THEN
                tx_dat <= "11";
            ELSIF (signed(rx_dat) < thresh_neg) THEN
                tx_dat <= "00";
            ELSE -- rx_dat < 0
                tx_dat <= "01";
            END IF;
        END IF;

    END IF;

END PROCESS;

END hard_decision_arc;