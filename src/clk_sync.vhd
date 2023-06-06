LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY clk_sync IS
    GENERIC (
        DATA_WIDTH : INTEGER);
    PORT (
        rst       :  IN  STD_LOGIC;
        clk       :  IN  STD_LOGIC;
        -- 
        rx_dat    :  IN  STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
        rx_rd     :  IN  STD_LOGIC;
        rx_wr     :  IN  STD_LOGIC;
        --
        tx_dat    :  OUT STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
        tx_val    :  OUT STD_LOGIC;
        tx_empty  :  OUT STD_LOGIC;
        tx_full   :  OUT STD_LOGIC
    );
END clk_sync;

ARCHITECTURE clk_sync_arc OF clk_sync IS
BEGIN





END clk_sync_arc;