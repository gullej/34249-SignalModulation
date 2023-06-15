LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY downsample IS
    GENERIC (
        DATA_WIDTH : INTEGER);
    PORT (
        rst         : IN  STD_LOGIC;
        clk_a       : IN  STD_LOGIC;
        clk_b       : IN  STD_LOGIC;
        --
        rx_dat      : IN STD_LOGIC_VECTOR(27 DOWNTO 0);
        rx_wr       : IN STD_LOGIC;
        --
        rx_addr     : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        rx_rd       : IN STD_LOGIC;
        --
        tx_dat      : OUT STD_LOGIC_VECTOR(27 DOWNTO 0);
        tx_val      : OUT STD_LOGIC
    );
END downsample;

ARCHITECTURE downsample_arc OF downsample IS

SIGNAL wr_addr : STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL rd_en_reg1, rd_en_reg2, rd_en_reg3 : STD_LOGIC;

BEGIN

rd_en_reg1 <= rx_rd when RISING_EDGE(clk_a);
rd_en_reg2 <= rd_en_reg1 when RISING_EDGE(clk_a);
rd_en_reg3 <= rd_en_reg2 when RISING_EDGE(clk_b);

    ram : entity work.dual_port_ram
    PORT MAP (
        data	   => rx_dat,
        rdaddress  => rx_addr,
        rdclock	   => clk_b,
        rden       => rd_en_reg3,
        wraddress  => wr_addr,
        wrclock	   => clk_a,
        wren	   => rx_wr,
        q		   => tx_dat
    );

END downsample_arc;