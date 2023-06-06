LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY upscale IS
    GENERIC (
        DATA_WIDTH : INTEGER);
    PORT (
        rst       :  IN  STD_LOGIC;
        clk       :  IN  STD_LOGIC;
        --
        rx_dat    :  IN  STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
        rx_empty  :  IN  STD_LOGIC;
        rx_val    :  IN  STD_LOGIC;
        --
        tx_dat    :  OUT STD_LOGIC_VECTOR(8 * DATA_WIDTH - 1 DOWNTO 0);
        tx_val    :  OUT STD_LOGIC;
        tx_rd     :  OUT STD_LOGIC
    );
END upscale;

ARCHITECTURE upscale_arc OF upscale IS

    CONSTANT zeros : STD_LOGIC_VECTOR(7 * DATA_WIDTH - 1 DOWNTO 0) := (others => '0');

BEGIN

    PROCESS (clk)
    BEGIN
        IF (rising_edge(clk)) THEN
            tx_rd  <= '0';
            tx_val <= '0';
            tx_dat <= rx_dat & zeros;

            IF (rx_empty = '0') THEN
                tx_rd <= '1';
            END IF;

            IF (rx_val = '1') THEN
                tx_val <= '1';
            END IF;
        END IF;

    END PROCESS;

END upscale_arc;