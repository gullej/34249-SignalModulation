LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY upscale IS
    GENERIC (
        CONSTELLATION_SIZE : INTEGER);
    PORT (
        rst       : IN  STD_LOGIC;
        clk       : IN  STD_LOGIC;
        --
        rx_dat    : IN  STD_LOGIC_VECTOR(CONSTELLATION_SIZE - 1 DOWNTO 0);
        rx_empty  : IN  STD_LOGIC;
        --
        tx_dat    : OUT STD_LOGIC_VECTOR(8 * CONSTELLATION_SIZE - 1 DOWNTO 0);
        tx_val    : OUT STD_LOGIC;
        tx_rd     : OUT STD_LOGIC
    );
END upscale;

ARCHITECTURE upscale_arc OF upscale IS
BEGIN

END upscale_arc;