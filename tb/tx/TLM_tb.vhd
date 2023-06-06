library ieee ;
  use ieee.std_logic_1164.all ;
  use ieee.numeric_std.all ;
  use ieee.numeric_std_unsigned.all ;

library osvvm ;
  context osvvm.OsvvmContext ;

entity transceiver_tb is
end entity transceiver_tb ;

architecture testbench of transceiver_tb is
  constant DATA_WIDTH : integer := 1; -- Data width at transceiver input interface
  constant CONSTALATION_SIZE : integer := 2; -- 1: PAM2 | 2: PAM4 | 3: PAM8

  constant tperiod_Clk : time := 10 ns ;
  constant tpd         : time := 2 ns ;

  signal clk  :  std_logic;
  signal rst  :  std_logic;

  begin
    -- create Clock
    Osvvm.TbUtilPkg.CreateClock (
      Clk        => Clk,
      Period     => Tperiod_Clk
    )  ;

    -- create nReset
    Osvvm.TbUtilPkg.CreateReset (
      Reset       => rst,
      ResetActive => '1',
      Clk         => Clk,
      Period      => 7 * tperiod_Clk,
      tpd         => tpd
    ) ;
end testbench;