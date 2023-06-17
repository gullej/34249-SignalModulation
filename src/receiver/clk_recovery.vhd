LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY clk_recovery IS
    GENERIC (
        DATA_WIDTH : INTEGER);
    PORT (
        rst      : IN  STD_LOGIC;
        clk      : IN  STD_LOGIC;
        --
        rx_dat   : IN  STD_LOGIC_VECTOR(27 DOWNTO 0);
        rx_val   : IN  STD_LOGIC;
        --
        tx_dat   : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        tx_wr    : OUT STD_LOGIC
    );
END clk_recovery;

ARCHITECTURE clk_recovery_arc OF clk_recovery IS

    TYPE sr_type IS ARRAY (0 TO 2) OF signed(27 DOWNTO 0);
    SIGNAL shift_reg : sr_type;

    CONSTANT delta_pos : SIGNED(27 DOWNTO 0) := "0000000000000000100000110001";
    CONSTANT delta_neg : SIGNED(27 DOWNTO 0) := "1111111111111111011111001111";

    SIGNAL wr_cnt    : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL wr_addr   : STD_LOGIC_VECTOR(3 DOWNTO 0);

    SIGNAL calc_cnt  : STD_LOGIC_VECTOR(11 DOWNTO 0);

    SIGNAL calc_val  : STD_LOGIC;
    SIGNAL calc_diff : SIGNED(27 DOWNTO 0);
    SIGNAL calc_sum  : SIGNED(2095 DOWNTO 0);
    SIGNAL calc_avg  : SIGNED(2095 DOWNTO 0);

BEGIN

tx_dat    <= wr_addr;

calc_diff <= abs(shift_reg(2)) - abs(shift_reg(0));
calc_avg  <= resize(calc_sum(2095 DOWNTO 12), 2096);

SR : PROCESS(clk)
BEGIN
    IF (RISING_EDGE(clk)) THEN
        shift_reg <= shift_reg;
        tx_wr <= '0';
        calc_cnt <= calc_cnt;
        wr_cnt   <= wr_cnt;
        wr_addr  <= wr_addr;

        IF (rx_val = '1') THEN
            tx_wr <= '1';

            shift_reg(1 to 2) <= shift_reg(0 to 1);
            shift_reg(0) <= signed(rx_dat);

            calc_cnt <= calc_cnt + 1;
            wr_cnt <= wr_cnt(6 downto 0) & wr_cnt(7);

            IF(wr_cnt(7) = '1') THEN
                wr_addr <= wr_addr + 8;
                calc_sum  <= calc_sum + calc_diff;
            END IF;            

            IF (to_integer(unsigned(calc_cnt)) = 2048) THEN
                IF (calc_avg > delta_pos) THEN
                    wr_addr <= wr_addr + 9;
                ELSIF (calc_avg < delta_neg) THEN
                    wr_addr <= wr_addr + 7;
                END IF;
                calc_cnt <= (others => '0');
                calc_sum <= (others => '0');
            END IF;

            IF rst = '1' THEN
                shift_reg  <=  (others => (others => '0'));
                calc_cnt <= (others => '0');
                calc_sum <= (others => '0');
                wr_cnt   <= "00000001";
                wr_addr  <= (others => '0');
            END IF;     
        END IF;
    END IF;
END PROCESS SR;

END clk_recovery_arc;