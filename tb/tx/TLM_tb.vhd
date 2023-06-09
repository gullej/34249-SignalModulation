library ieee ;
  use ieee.std_logic_1164.all ;
  use ieee.numeric_std.all ;
  use ieee.numeric_std_unsigned.all ;

library osvvm ;
  context osvvm.OsvvmContext ;

library osvvm_common ;
  context osvvm_common.OsvvmCommonContext ;

entity TLM_tb is
end entity TLM_tb ;

architecture testbench of TLM_tb is
  constant DATA_WIDTH : integer := 2; -- Data width at transceiver input interface
  constant CONSTALATION_SIZE : integer := 2; -- 1: PAM2 | 2: PAM4 | 3: PAM8

  constant tperiod_Clk   : time := 10 ns ;
  constant tperiod_Clk_b : time := 20 ns ;
  constant tpd           : time := 2 ns ;

  signal clk    :  std_logic;
  signal clk_b  :  std_logic;
  signal rst    :  std_logic;

  signal data_gray   :  std_logic_vector(0 DOWNTO 0);
  signal valid_gray  :  std_logic;

  signal data_in_fifo   :  std_logic_vector(DATA_WIDTH-1 DOWNTO 0);
  signal data_out_fifo  :  std_logic_vector(DATA_WIDTH*8-1 DOWNTO 0);
  signal read_fifo      :  std_logic;
  signal write_fifo     :  std_logic;
  signal full_fifo      :  std_logic;
  signal empty_fifo     :  std_logic;
  signal dbg  :  std_logic;

  signal stream_tx_rec, stream_rx_rec : StreamRecType (
    DataToModel(0 DOWNTO 0),
    DataFromModel(1 DOWNTO 0),
    ParamToModel  (16 downto 0),
    ParamFromModel(16 downto 0)
  );

  component test_ctrl_e is
    port (
      rst  :  in  std_logic;
  
      --Transaction interface
      
      stream_tx_rec  :  inout StreamRecType;
      stream_rx_rec  :  inout StreamRecType
  
    );
  end component; 

  begin
    dbg <= <<signal .TLM_tb.TestCtrl_1.dbg : std_logic>>;
    -- create Clock
    Osvvm.TbUtilPkg.CreateClock (
      Clk        => clk,
      Period     => Tperiod_Clk
    )  ;

    -- create Clock
    Osvvm.TbUtilPkg.CreateClock (
      Clk        => clk_b,
      Period     => tperiod_Clk_b
    )  ;

    -- create nReset
    Osvvm.TbUtilPkg.CreateReset (
      Reset       => rst,
      ResetActive => '1',
      Clk         => Clk,
      Period      => 7 * tperiod_Clk,
      tpd         => tpd
    ) ;

    TX_GrayCode_VC : entity work.graycode_tx_vc
    port map (
      clk              => clk,
      rst              => rst,
      tx_valid         => valid_gray,
      tx_last          => open,
      tx_data          => data_gray,
      --Transactio interface
      trans_rec        => stream_tx_rec
    );

    RX_GrayCode_VC : entity work.graycode_rx_vc
    port map (
      clk              => clk,
      rst              => rst,
      rx_write         => write_fifo,
      rx_data          => data_in_fifo,
      --Transactio interface
      trans_rec        => stream_rx_rec
    );

  TestCtrl_1 : test_ctrl_e
    port map (
      rst            =>  rst,
      stream_tx_rec  =>  stream_tx_rec,
      stream_rx_rec  =>  stream_rx_rec
    );

    DUT_I : entity work.gray_code
    generic map (
        DATA_WIDTH  =>  DATA_WIDTH
    )
    port map(
        rst     =>  rst,
        clk     =>  clk,
        --
        rx_dat  =>  data_gray(0),
        rx_val  =>  valid_gray,
        rx_full =>  full_fifo,
        --
        tx_dat  =>  data_in_fifo,
        tx_wr   =>  write_fifo
    );

    DUT_II : ENTITY work.clk_sync
        GENERIC MAP(
            DATA_WIDTH => DATA_WIDTH
        )
        PORT MAP(
            clk_rd   => clk_b,
            clk_wr   => clk,
            --
            rx_dat   => data_in_fifo,
            rx_rd    => read_fifo,
            rx_wr    => write_fifo,
            --
            tx_dat   => data_out_fifo,
            tx_empty => empty_fifo,
            tx_full  => full_fifo
        );
end testbench;