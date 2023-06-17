LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY downsample IS
    GENERIC (
        DATA_WIDTH : INTEGER);
    PORT (
        rst         : IN  STD_LOGIC;
        clk_wr      : IN  STD_LOGIC;
        clk_rd      : IN  STD_LOGIC;
        --
        rx_dat      : IN  STD_LOGIC_VECTOR(27 DOWNTO 0);
        rx_wr       : IN  STD_LOGIC;
        --
        rx_addr     : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
        rx_rd       : IN  STD_LOGIC;
        --
        tx_dat      : OUT STD_LOGIC_VECTOR(27 DOWNTO 0);
        tx_val      : OUT STD_LOGIC
    );
END downsample;

ARCHITECTURE downsample_arc OF downsample IS

SIGNAL wr_addr : STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL rd_en_reg1, rd_en_reg2, rd_en_reg3 : STD_LOGIC;

BEGIN

    writer : process(clk_wr)
    begin
        IF (RISING_EDGE(clk_wr)) THEN
            wr_addr <= wr_addr;
            rd_en_reg1 <= rx_rd;
            rd_en_reg2 <= rd_en_reg1;

            IF (rx_wr = '1') THEN
                wr_addr <= wr_addr + 1;
            END IF;

            IF (rst = '1') THEN
                wr_addr <= (others => '0');
            END IF;
        END IF;

    end process writer;

    reader : process(clk_rd)
    begin
        IF (RISING_EDGE(clk_rd)) THEN
            tx_val <= rd_en_reg3;
            rd_en_reg3 <= rd_en_reg2;
        END IF;
    end process reader;

    ram : entity work.dual_port_ram
    PORT MAP (
        data	   => rx_dat,
        rdaddress  => rx_addr,
        rdclock	   => clk_rd,
        rden       => rd_en_reg3,
        wraddress  => wr_addr,
        wrclock	   => clk_wr,
        wren	   => rx_wr,
        q		   => tx_dat
    );

END downsample_arc;