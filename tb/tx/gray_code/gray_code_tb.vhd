library ieee ;
  use ieee.std_logic_1164.all ;
  use ieee.numeric_std.all ;
  use ieee.numeric_std_unsigned.all ;

library osvvm ;
  context osvvm.OsvvmContext ;

entity gray_code_tb is
    generic(
        DATA_WIDTH : integer := 2
    );
end entity gray_code_tb;

architecture testbench of gray_code_tb is

    constant tperiod_clk : time := 10 ns ;
    constant tpd         : time := 2 ns ;

    signal clk  :  std_logic;
    signal rst  :  std_logic;

    signal data  :  std_logic;
    signal valid :  std_logic;
    signal full  :  std_logic;

    signal dbg_data   :  std_logic_vector(DATA_WIDTH-1 DOWNTO 0);
    signal dgb_write  :  std_logic;

    shared variable cov_a : covPType;
    shared variable cov_b : covPType;

    signal Cov1 : CoverageIDType ;
    signal Cov2 : CoverageIDType ;
    
    begin

    -- create Clock
    Osvvm.TbUtilPkg.CreateClock (
        clk        => clk,
        Period     => Tperiod_clk
    )  ;

    -- create rst
    Osvvm.TbUtilPkg.CreateReset (
        Reset       => rst,
        ResetActive => '1',
        clk         => clk,
        Period      => 7 * tperiod_clk,
        tpd         => tpd
    ) ;

    DUT : entity work.gray_code
        generic map (
            DATA_WIDTH  =>  DATA_WIDTH
        )
        port map(
            rst     =>  rst,
            clk     =>  clk,
            --
            rx_dat  =>  data,
            rx_val  =>  valid,
            rx_full =>  full,
            --
            tx_dat  =>  dbg_data,
            tx_wr   =>  dgb_write
        );

    RANDOM_GEN : process
        variable rnd : RandomPType;
        begin
            wait until rising_edge(clk) and rst = '0';
            data   <=  rnd.Randslv(1)(1);
            valid  <=  rnd.Randslv(1)(1);
            full   <=  '0';
    end process;

    cov_a_INTI_PROC : process
        begin
            --Cov1 <= NewID("Cov1") ;
            Cov2 <= NewID("Cov2") ;
            wait for 0 ns ; -- Update Cov1
            --AddBins(cov1,GenBin(0,0));
            --AddBins(cov1,GenBin(1,1));
            --AddBins(cov1,GenBin(2,2));
            --AddBins(cov1,GenBin(3,3));

            AddBins(Cov2,GenBin(0,0));
            AddBins(Cov2,GenBin(1,1));
            AddBins(Cov2,GenBin(2,2));
            AddBins(Cov2,GenBin(3,3));
            wait ;
    end process;

    SAMPLE_PROC : process
        begin
            --loop
                wait until rising_edge(clk) and rst = '0';
                --if valid = '1' then
                --    cov_a.ICover(to_integer(data));
                --end if;
                if dgb_write = '1' then
                    ICover(Cov2,to_integer(unsigned(dbg_data)));
                end if;
            --end loop ;
    end process;

    REPORT_PROC : process
        begin
            wait for 1000 ns;
            --report("Input Samples");
            --cov_a.WriteBin;
            report("Output Samples");
            WriteBin(Cov2);

            wait ;
    end process;

end testbench ; -- testbench