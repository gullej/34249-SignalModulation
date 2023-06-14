library ieee ;
  use ieee.std_logic_1164.all ;
  use ieee.numeric_std.all ;
  use ieee.std_logic_unsigned.all;

ENTITY pam_map IS
    GENERIC (
        DATA_WIDTH : INTEGER := 3
    );
    PORT (
        rst        :  IN  STD_LOGIC;
        clk        :  IN  STD_LOGIC;
        --
        rx_dat     :  IN  STD_LOGIC;
        rx_val     :  IN  STD_LOGIC;
        rx_full    :  IN  STD_LOGIC;
        --
        tx_dat     :  OUT STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
        tx_wr      :  OUT STD_LOGIC
    );
END pam_map;

ARCHITECTURE pam_map_arc OF pam_map IS

    SIGNAL rx_dat_sr :  STD_LOGIC_VECTOR(DATA_WIDTH - 2 DOWNTO 0);
    SIGNAL cnt       :  STD_LOGIC_VECTOR(1 DOWNTO 0);

BEGIN

process  (rx_dat_sr) is
    variable sel : STD_LOGIC_VECTOR(DATA_WIDTH - 2 DOWNTO 0);
begin
    sel := rx_dat_sr;
case sel is
    when "00" =>
        -- -3
        tx_dat <= "101";
    when "01" =>
        -- -1
        tx_dat <= "111";
    when "11" =>
        -- +1
        tx_dat <= "001";
    when "10" =>
        -- +3
        tx_dat <= "011";
    when others =>
        -- ?
        tx_dat <= "000";
end case;
end process;

    PROCESS (clk)
    BEGIN
        IF (rising_edge(clk)) THEN
            cnt   <= cnt;
            tx_wr <= '0';
            rx_dat_sr <= rx_dat_sr;


            IF (rx_full = '0') THEN
                IF (rx_val = '1') THEN
                    rx_dat_sr <=  rx_dat_sr(rx_dat_sr'LEFT-1 DOWNTO 0) & rx_dat;
                    cnt <= cnt + 1;
                END IF;

                IF (to_integer(unsigned(cnt)) = DATA_WIDTH - 2) THEN
                    cnt <= (others => '0');
                    tx_wr <= '1';
                END IF;
            END IF;

            IF (rst = '1') THEN
                cnt <= (others => '0');
            END IF;
        END IF;

    END PROCESS;
    
END pam_map_arc;