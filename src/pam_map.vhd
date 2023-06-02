LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY pam_map IS
    GENERIC (
        CONSTELLATION_SIZE : INTEGER);
    PORT (
        rst      : IN  STD_LOGIC;
        clk      : IN  STD_LOGIC;
        --
        rx_dat   : IN  STD_LOGIC;
        rx_val   : IN  STD_LOGIC;
        rx_full  : IN  STD_LOGIC;
        --
        tx_dat   : OUT STD_LOGIC_VECTOR(CONSTELLATION_SIZE - 1 DOWNTO 0);
        tx_wr    : OUT STD_LOGIC
    );
END pam_map;

ARCHITECTURE pam_map_arc OF pam_map IS
BEGIN

END pam_map_arc;