LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY pulse_shaper IS
    GENERIC (
        CONSTELLATION_SIZE : INTEGER);
    PORT (
        rst      : IN  STD_LOGIC;
        clk      : IN  STD_LOGIC;
        --
        rx_dat_i : IN  STD_LOGIC_VECTOR(8 * CONSTELLATION_SIZE - 1 DOWNTO 0);
        rx_val_i : IN  STD_LOGIC;
        --
        tx_dat_o : OUT STD_LOGIC_VECTOR(13 DOWNTO 0);
        tx_val_o : OUT STD_LOGIC
    );
END pulse_shaper;

ARCHITECTURE pulse_shaper_arc OF pulse_shaper IS
BEGIN

END pulse_shaper_arc;