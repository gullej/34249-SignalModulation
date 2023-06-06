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
entity gray_code_tb;

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
        variable RV : RandomPType;
        begin
            data   <=  rnd.Randslv(1)(1);
            valid  <=  rnd.Randslv(1)(1);
            full   <=  '0';
    end process;

    cov_a_INTI_PROC : process
        begin
            cov_a.AddBin(GenBin(0,0));
            cov_a.AddBin(GenBin(1,1));
            cov_a.AddBin(GenBin(2,2));
            cov_a.AddBin(GenBin(3,3));

            cov_b.AddBin(GenBin(0,0));
            cov_b.AddBin(GenBin(1,1));
            cov_b.AddBin(GenBin(2,2));
            cov_b.AddBin(GenBin(3,3));
    end process

    SAMPLE_PROC : process
        begin
            if valid = '1' then
                cov_a.ICover(to_integer(unsigned(data)));
            end if;
            if dgb_write = '1' then
                cov_b.ICover(to_integer(unsigned(dbg_data)));
            end if;
    end process;

    REPORT_PROC : process
        begin
            wait until 100 ns;
            report("Input Samples");
            cov_a.WriteBin;
            report("Output Samples");
            cov_a.WriteBin;
    end process;

end testbench ; -- testbench