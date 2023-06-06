LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.numeric_std_unsigned.ALL;

LIBRARY osvvm;
CONTEXT osvvm.OsvvmContext;

ENTITY clk_sync_tb IS
    GENERIC (
        DATA_WIDTH : INTEGER := 2
    );
END ENTITY clk_sync_tb;

ARCHITECTURE testbench OF clk_sync_tb IS

    CONSTANT tperiod_clk_rd : TIME := 30 ns;
    CONSTANT tpd_rd : TIME := 2 ns;
    SIGNAL   clk_rd : STD_LOGIC;

    CONSTANT tperiod_clk_wr : TIME := 10 ns;
    CONSTANT tpd_wr : TIME := 2 ns;
    SIGNAL   clk_wr : STD_LOGIC;

    SIGNAL rst : STD_LOGIC;

    SIGNAL data_tx  : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
    SIGNAL data_rx  : STD_LOGIC_VECTOR(8 * DATA_WIDTH - 1 DOWNTO 0);
    SIGNAL tb_rd    : STD_LOGIC;
    SIGNAL tb_wr    : STD_LOGIC;
    SIGNAL tb_empty : STD_LOGIC;
    SIGNAL tb_full  : STD_LOGIC;

    SIGNAL dbg_data : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
    SIGNAL dgb_write : STD_LOGIC;

    SHARED VARIABLE cov_a : covPType;
    SHARED VARIABLE cov_b : covPType;

    SIGNAL Cov1 : CoverageIDType;
    SIGNAL Cov2 : CoverageIDType;

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

    DUT : ENTITY work.clk_sync
        GENERIC MAP(
            DATA_WIDTH => DATA_WIDTH
        )
        PORT MAP(
            clk_rd => clk_rd,
            clk_wr => clk_wr,
            --
            rx_dat => data_tx,
            rx_rd => tb_rd,
            rx_wr => tb_wr,
            --
            tx_dat => data_rx,
            tx_empty => tb_empty,
            tx_full => tb_full
        );

    RANDOM_GEN_WR : PROCESS
        VARIABLE rnd : RandomPType;
    BEGIN
        WAIT UNTIL rising_edge(clk_wr) AND rst = '0';
        data_tx <= rnd.Randslv(DATA_WIDTH);
        tb_wr <= rnd.Randslv(1)(1) and (not tb_full);
    END PROCESS;

    RANDOM_GEN_RD : PROCESS
    VARIABLE rnd : RandomPType;
    BEGIN
        WAIT UNTIL rising_edge(clk_rd) AND rst = '0';
        tb_rd <= rnd.Randslv(1)(1) and (not tb_empty);
    END PROCESS;

    -- cov_a_INTI_PROC : PROCESS
    -- BEGIN
    --     --Cov1 <= NewID("Cov1") ;
    --     Cov2 <= NewID("Cov2");
    --     WAIT FOR 0 ns; -- Update Cov1
    --     --AddBins(cov1,GenBin(0,0));
    --     --AddBins(cov1,GenBin(1,1));
    --     --AddBins(cov1,GenBin(2,2));
    --     --AddBins(cov1,GenBin(3,3));
-- 
    --     AddBins(Cov2, GenBin(0, 0));
    --     AddBins(Cov2, GenBin(1, 1));
    --     AddBins(Cov2, GenBin(2, 2));
    --     AddBins(Cov2, GenBin(3, 3));
    --     WAIT;
    -- END PROCESS;

    --SAMPLE_PROC : PROCESS
    --BEGIN
    --    --loop
    --    WAIT UNTIL rising_edge(clk) AND rst = '0';
    --    --if valid = '1' then
    --    --    cov_a.ICover(to_integer(data));
    --    --end if;
    --    IF dgb_write = '1' THEN
    --        ICover(Cov2, to_integer(unsigned(dbg_data)));
    --    END IF;
    --    --end loop ;
    --END PROCESS;

    REPORT_PROC : PROCESS
    BEGIN
        WAIT FOR 1000 ns;
        --report("Input Samples");
        --cov_a.WriteBin;
        --REPORT("Output Samples");
        --WriteBin(Cov2);

        std.env.finish;
        WAIT;
    END PROCESS;

END testbench; -- testbench