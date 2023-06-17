architecture pam_map_testbench of TLM_tb is
  constant tperiod_Clk   : time := 10 ns ;
  constant tperiod_Clk_b : time := 20 ns ;
  constant tperiod_Clk_c : time := 160 ns ;
  constant tpd           : time := 2 ns ;

  constant DATA_WIDTH : integer := 3; -- Data width at transceiver input interface

  signal clk    :  std_logic;
  signal rst    :  std_logic;

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

  -- Gray Code Tx VC signals
  signal tx_gray_code_vc_valid  :  std_logic;
  signal tx_gray_code_vc_last   :  std_logic; 
  signal tx_gray_code_vc_data   :  std_logic_vector(0 DOWNTO 0);

  -- Gray Code Rx VC signals
  signal rx_gray_code_vc_write  :  std_logic;
  signal rx_gray_code_vc_data   :  std_logic_vector(DATA_WIDTH - 1 DOWNTO 0);

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
      hard_decision_rx_rec : inout StreamRecType
    );
  end component; 
  
begin

    -- create Clock
    Osvvm.TbUtilPkg.CreateClock (
      Clk        => clk,
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

  ------------------------------------------
  --      Graycode Transmitter VC         --
  ------------------------------------------
    TX_GrayCode_VC : graycode_tx_vc
      generic map (
        DATA_WIDTH  =>  DATA_WIDTH
      )
      port map (
        clk         =>  clk,
        rst         =>  rst,
        tx_valid    =>  tx_gray_code_vc_valid,
        tx_last     =>  tx_gray_code_vc_last,
        tx_data     =>  tx_gray_code_vc_data,
        --Transactio interface
        trans_rec   =>  stream_tx_rec
      );

  ------------------------------------------
  --        Graycode Receiver VC          --
  ------------------------------------------
    RX_GrayCode_VC : graycode_rx_vc
      generic map (
        DATA_WIDTH  =>  DATA_WIDTH
      )
      port map (
        clk         =>  clk,
        rst         =>  rst,
        rx_write    =>  rx_gray_code_vc_write,
        rx_data     =>  rx_gray_code_vc_data,
        --Transactio interface
        trans_rec   =>  stream_rx_rec
      );

  ----------------------------------------------
  --              Gray code DUT               --
  ----------------------------------------------  
    GrayCode_DUT : entity work.pam_map
      generic map (
        DATA_WIDTH  =>  DATA_WIDTH
      )
      port map (
        rst     =>  rst,
        clk     =>  clk,
        
        rx_dat  =>  tx_gray_code_vc_data(0),
        rx_val  =>  tx_gray_code_vc_valid,
        rx_full =>  '0',
        
        tx_dat  =>  rx_gray_code_vc_data,
        tx_wr   =>  rx_gray_code_vc_write
      );

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
      hard_decision_rx_rec =>  hard_decision_rx_rec
    );

end architecture pam_map_testbench;