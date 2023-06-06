LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY gray_code IS
    GENERIC (
        DATA_WIDTH : INTEGER);
    PORT (
        rst : IN STD_LOGIC;
        clk : IN STD_LOGIC;
        --
        rx_dat : IN STD_LOGIC;
        rx_val : IN STD_LOGIC;
        rx_full : IN STD_LOGIC;
        --
        tx_dat : OUT STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
        tx_wr : OUT STD_LOGIC
    );
END gray_code;

ARCHITECTURE gray_code_arc OF gray_code IS

    SIGNAL rx_dat_sr : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
    SIGNAL cnt : INTEGER RANGE 0 TO DATA_WIDTH - 1;

BEGIN

    tx_dat <= rx_dat_sr XOR ('0' & rx_dat_sr(rx_dat_sr'LEFT - 1 DOWNTO 1));

    PROCESS (clk)
    BEGIN
        IF (rising_edge(clk)) THEN
            tx_wr <= '0';
            cnt <= cnt;
            rx_dat_sr <= rx_dat_sr;

            IF (rx_full = '0') THEN
                IF (rx_val = '1') THEN
                    rx_dat_sr <= rx_dat & rx_dat_sr(rx_dat_sr'LEFT - 1 DOWNTO 1);
                    cnt <= cnt + 1;
                END IF;

                IF (cnt = DATA_WIDTH) THEN
                    tx_wr <= '1';
                END IF;
            END IF;

            IF (rst = '1') THEN
                cnt <= 0;
            END IF;
        END IF;
    END PROCESS;
END gray_code_arc;