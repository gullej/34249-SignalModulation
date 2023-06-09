LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.numeric_std_unsigned.ALL;

LIBRARY osvvm;
CONTEXT osvvm.OsvvmContext;

ENTITY pre_PS_tb IS
    GENERIC (
        DATA_WIDTH : INTEGER := 2
    );
END ENTITY pre_PS_tb;

ARCHITECTURE testbench OF pre_PS_tb IS

    CONSTANT tperiod_clk_rd : TIME := 30 ns;
    CONSTANT tpd_rd : TIME := 2 ns;
    SIGNAL   clk_rd : STD_LOGIC;

    CONSTANT tperiod_clk_wr : TIME := 10 ns;
    CONSTANT tpd_wr : TIME := 2 ns;
    SIGNAL   clk_wr : STD_LOGIC;

    SIGNAL rst : STD_LOGIC;

    SIGNAL data   : STD_LOGIC;
    SIGNAL valid  : STD_LOGIC;

    SIGNAL data_tx  : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
    SIGNAL data_rx  : STD_LOGIC_VECTOR(8 * DATA_WIDTH - 1 DOWNTO 0);
    SIGNAL tb_rd    : STD_LOGIC;
    SIGNAL tb_wr    : STD_LOGIC;
    SIGNAL tb_empty : STD_LOGIC;
    SIGNAL tb_full  : STD_LOGIC;

BEGIN

    -- create Clocks
    Osvvm.TbUtilPkg.CreateClock (
        clk => clk_rd,
        Period => Tperiod_clk_rd
    );

    Osvvm.TbUtilPkg.CreateClock (
        clk => clk_wr,
        Period => Tperiod_clk_wr
    );

    -- create rst
    Osvvm.TbUtilPkg.CreateReset (
        Reset => rst,
        ResetActive => '1',
        clk => clk_wr,
        Period => 7 * tperiod_clk_wr,
        tpd => tpd_wr
    );

    DUT_I : entity work.gray_code
    generic map (
        DATA_WIDTH  =>  DATA_WIDTH
    )
    port map(
        rst     =>  rst,
        clk     =>  clk_wr,
        --
        rx_dat  =>  data,
        rx_val  =>  valid,
        rx_full =>  tb_full,
        --
        tx_dat  =>  data_tx,
        tx_wr   =>  tb_wr
    );

    DUT_II : ENTITY work.clk_sync
        GENERIC MAP(
            DATA_WIDTH => DATA_WIDTH
        )
        PORT MAP(
            clk_rd   => clk_rd,
            clk_wr   => clk_wr,
            --
            rx_dat   => data_tx,
            rx_rd    => tb_rd,
            rx_wr    => tb_wr,
            --
            tx_dat   => data_rx,
            tx_empty => tb_empty,
            tx_full  => tb_full
        );

    RANDOM_GEN_WR : PROCESS
        VARIABLE rnd : RandomPType;
    BEGIN
        WAIT UNTIL rising_edge(clk_wr) AND rst = '0';
        data <= rnd.Randslv(1)(1);
        valid <= (not tb_full);
    END PROCESS;

    RANDOM_GEN_RD : PROCESS
    VARIABLE rnd : RandomPType;
    BEGIN
        WAIT UNTIL rising_edge(clk_rd) AND rst = '0';
        tb_rd <= (not tb_empty);
    END PROCESS;

    REPORT_PROC : PROCESS
    BEGIN
        WAIT FOR 1000 ns;

        std.env.finish;
        WAIT;
    END PROCESS;

END testbench; -- testbench