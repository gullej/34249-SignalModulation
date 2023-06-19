architecture tranceiver_testbench of TLM_tb is
  constant tperiod_Clk   : time := 10 ns ;
  constant tperiod_Clk_b : time := 2.5 ns ;
  constant tperiod_Clk_c : time := 20 ns ;
  constant tpd           : time := 2 ns ;

  constant DATA_WIDTH : integer := 3; -- Data width at transceiver input interface

  signal clk      :  std_logic;
  signal clk_b    :  std_logic;
  signal rst      :  std_logic;

    -- Graycode VC interfaces
  signal stream_tx_rec, stream_rx_rec : StreamRecType (
    DataToModel(0 DOWNTO 0),
    DataFromModel(DATA_WIDTH - 1 DOWNTO 0),
    ParamToModel  (15 downto 0),
    ParamFromModel(15 downto 0)
  );

  -- Clock Synchroniser Transmitter interface
  signal  sync_tx_rec : StreamRecType (
    DataToModel(DATA_WIDTH - 1 DOWNTO 0),
    DataFromModel(DATA_WIDTH - 1 DOWNTO 0),
    ParamToModel  (15 downto 0),
    ParamFromModel(15 downto 0)
  );

  -- Clock Synchroniser Receiver interface
  signal  sync_rx_rec : StreamRecType (
    DataToModel(8 * DATA_WIDTH - 1 DOWNTO 0),
    DataFromModel(8 * DATA_WIDTH - 1 DOWNTO 0),
    ParamToModel  (15 downto 0),
    ParamFromModel(15 downto 0)
  );

  -- Pulse Shaper Tx/Rx interfaces
  signal  pulse_tx_rec, pulse_rx_rec : StreamRecType (
    DataToModel(8 * DATA_WIDTH - 1 DOWNTO 0),
    DataFromModel(13 DOWNTO 0),
    ParamToModel  (15 downto 0),
    ParamFromModel(15 downto 0)
  );

    -- Hard decision Rx interfaces
    signal  hard_decision_rx_rec : StreamRecType (
      DataToModel(27 DOWNTO 0),
      DataFromModel(1 DOWNTO 0),
      ParamToModel  (15 downto 0),
      ParamFromModel(15 downto 0)
    );

    -- Top VC interfaces
  signal rx_top_in_rec, rx_top_out_rec : StreamRecType (
    DataToModel(0 DOWNTO 0),
    DataFromModel(0 DOWNTO 0),
    ParamToModel  (15 downto 0),
    ParamFromModel(15 downto 0)
  );

    component test_ctrl_e is
    port (
      rst            :  in  std_logic;
      --Transaction interface
      stream_tx_rec  :  inout StreamRecType;
      stream_rx_rec  :  inout StreamRecType;
      sync_tx_rec    :  inout StreamRecType;
      sync_rx_rec    :  inout StreamRecType;
      pulse_rx_rec   :  inout StreamRecType;
      pulse_tx_rec   :  inout StreamRecType;
      hard_decision_rx_rec : inout StreamRecType;
      rx_trans_rec_in      :  inout StreamRecType;
      rx_trans_rec_out     :  inout StreamRecType
    );
  end component;

  signal tx_pbrs_data   :  std_logic;
  signal tx_pbrs_valid  :  std_logic;

begin
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

    TestCtrl_1 : test_ctrl_e
    generic map (
      DATA_WIDTH     => DATA_WIDTH
    )
    port map (
      rst                  =>  rst,
      stream_tx_rec        =>  stream_tx_rec,
      stream_rx_rec        =>  stream_rx_rec,
      sync_tx_rec          =>  sync_tx_rec,
      sync_rx_rec          =>  sync_rx_rec,
      pulse_rx_rec         =>  pulse_rx_rec,
      pulse_tx_rec         =>  pulse_tx_rec,
      hard_decision_rx_rec =>  hard_decision_rx_rec,
      rx_trans_rec_in      =>  rx_top_in_rec,
      rx_trans_rec_out     =>  rx_top_out_rec
    );

    PBRS_DUT : PBRS
        port map (
            clk       =>  clk,
            rst       =>  rst,
            
            tx_data   =>  tx_pbrs_data,
            tx_valid  =>  tx_pbrs_valid
        );

    Tranceiver_DUT : tranceiver_top
        generic map (
            DATA_WIDTH  =>  DATA_WIDTH
        )
        port map (
            clk_wr      =>  clk,
            clk_rd      =>  clk_b,
            rst         =>  rst,
            
            rx_valid    =>  tx_pbrs_valid,
            rx_data     =>  tx_pbrs_data,
            
            tx_valid    =>  open,
            tx_data     =>  open
        );

end architecture tranceiver_testbench;