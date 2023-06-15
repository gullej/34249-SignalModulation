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

-----------------------------------------------------------
--            Constant/Generic Declaration               --
--vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv--

  constant DATA_WIDTH : integer := 3; -- Data width at transceiver input interface
  constant CONSTALATION_SIZE : integer := 2; -- 1: PAM2 | 2: PAM4 | 3: PAM8

  constant tperiod_Clk   : time := 10 ns ;
  constant tperiod_Clk_b : time := 20 ns ;
  constant tpd           : time := 2 ns ;

-----------------------------------------------------------
--                  Signal Declaration                   --
--vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv--

  signal clk    :  std_logic;
  signal clk_b  :  std_logic;
  signal rst    :  std_logic;

  signal pam_map_data   :  std_logic_vector(0 DOWNTO 0);
  signal pam_map_valid  :  std_logic;

  signal clk_sync_data_in   :  std_logic_vector(DATA_WIDTH-1 DOWNTO 0);
  signal clk_sync_data_out  :  std_logic_vector(DATA_WIDTH*8-1 DOWNTO 0);
  signal clk_sync_read      :  std_logic;
  signal clk_sync_write     :  std_logic;
  signal clk_sync_full      :  std_logic;
  signal clk_sync_empty     :  std_logic;

  signal pulse_shaper_valid_in   :  std_logic;
  signal pulse_shaper_valid_out  :  std_logic;
  signal pulse_shaper_data_out   :  std_logic_vector(13 DOWNTO 0);

  signal match_filter_data_out   :  std_logic_vector(27 DOWNTO 0);
  signal match_filter_valid_out  :  std_logic;

  signal clk_recovery_data_out   :  std_logic_vector(3 DOWNTO 0);
  signal clk_recovery_wr_out     :  std_logic;

  signal tranceiver_data   :  std_logic_vector(13 DOWNTO 0);
  signal tranceiver_valid  :  std_logic;

-----------------------------------------------------------
--         Transaction Interface Declaration             --
--vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv--

  -- Graycode VC interfaces
  signal stream_tx_rec, stream_rx_rec : StreamRecType (
    DataToModel(0 DOWNTO 0),
    DataFromModel(DATA_WIDTH - 1 DOWNTO 0),
    ParamToModel  (16 downto 0),
    ParamFromModel(16 downto 0)
  );

  -- Clock Synchroniser Transmitter interface
  signal  sync_tx_rec : StreamRecType (
    DataToModel(DATA_WIDTH - 1 DOWNTO 0),
    DataFromModel(DATA_WIDTH - 1 DOWNTO 0),
    ParamToModel  (16 downto 0),
    ParamFromModel(16 downto 0)
  );

  -- Clock Synchroniser Receiver interface
  signal  sync_rx_rec : StreamRecType (
    DataToModel(8 * DATA_WIDTH - 1 DOWNTO 0),
    DataFromModel(8 * DATA_WIDTH - 1 DOWNTO 0),
    ParamToModel  (16 downto 0),
    ParamFromModel(16 downto 0)
  );

  -- Pulse Shaper Tx/Rx interfaces
  signal  pulse_tx_rec, pulse_rx_rec : StreamRecType (
    DataToModel(8 * DATA_WIDTH - 1 DOWNTO 0),
    DataFromModel(13 DOWNTO 0),
    ParamToModel  (16 downto 0),
    ParamFromModel(16 downto 0)
  );

  -- Gray Code Tx signals
  signal tx_gray_code_vc_valid  :  std_logic;
  signal tx_gray_code_vc_last   :  std_logic; 
  signal tx_gray_code_vc_data   :  std_logic_vector(0 DOWNTO 0);

  -- Gray Code Rx signals
  signal rx_gray_code_vc_write  :  std_logic;
  signal rx_gray_code_vc_data   :  std_logic_vector(DATA_WIDTH - 1 DOWNTO 0);

-----------------------------------------------------------
--        Test Controller DUTonents Declaration          --
--vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv--

  component test_ctrl_e is
    port (
      rst            :  in  std_logic;
      --Transaction interface
      stream_tx_rec  :  inout StreamRecType;
      stream_rx_rec  :  inout StreamRecType;
      sync_tx_rec    :  inout StreamRecType;
      sync_rx_rec    :  inout StreamRecType;
      pulse_rx_rec   :  inout StreamRecType;
      pulse_tx_rec   :  inout StreamRecType
    );
  end component; 

  begin
    --dbg <= <<signal .TLM_tb.TestCtrl_1.dbg : std_logic>>;
-----------------------------------------------------------
--            OSVVM Clock and Reset Creation             --
--vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv--

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

-----------------------------------------------------------
--             TLM Verification DUTonents               --
--vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv--

  ------------------------------------------
  --      Graycode Transmitter VC         --
  ------------------------------------------
    TX_GrayCode_VC : entity work.graycode_tx_vc
      generic map (
        DATA_WIDTH  =>  DATA_WIDTH
      )
      port map (
        clk         =>  clk,
        rst         =>  rst,
        tx_valid    =>  pam_map_valid,
        tx_last     =>  open,
        tx_data     =>  pam_map_data,
        --Transactio interface
        trans_rec   =>  stream_tx_rec
      );

  ------------------------------------------
  --        Graycode Receiver VC          --
  ------------------------------------------
    RX_GrayCode_VC : entity work.graycode_rx_vc
      generic map (
        DATA_WIDTH  =>  DATA_WIDTH
      )
      port map (
        clk         =>  clk,
        rst         =>  rst,
        rx_write    =>  clk_sync_write,
        rx_data     =>  clk_sync_data_in,
        --Transactio interface
        trans_rec   =>  stream_rx_rec
      );

  ------------------------------------------
  --             Clk_sync VC              --
  ------------------------------------------
    Clk_Sync_VC : entity work.clk_sync_rx_vc
    GENERIC MAP(
            DATA_WIDTH => DATA_WIDTH
        )
    port map (
      clk_rd            =>  clk_b,
      clk_wr            =>  clk,
      rst               =>  rst,

      rx_dat_in         =>  clk_sync_data_in,
      rx_rd_in          =>  clk_sync_read,
      rx_wr_in          =>  clk_sync_write,
      --
      rx_dat_out	      =>  clk_sync_data_out,
      rx_empty_out      =>  clk_sync_empty,
      rx_full_out       =>  clk_sync_full,

      --Transaction interface
      rx_trans_rec_in   =>  sync_tx_rec,
      rx_trans_rec_out  =>  sync_rx_rec
    );

  ------------------------------------------
  --           Pulse Shaper VC            --
  ------------------------------------------
    Pulse_Shaper_VC : entity work.pulseshaper_rx_vc
      generic map (
        DATA_WIDTH    => DATA_WIDTH
      )
      port map (
        clk           =>  clk_b,
        rst           =>  rst,
        rx_valid      =>  pulse_shaper_valid_out,
        rx_data       =>  pulse_shaper_data_out,
        rx_read       =>  clk_sync_read,
        tx_empty      =>  pulse_shaper_valid_in,
        tx_data       =>  clk_sync_data_out,
        -- Transaction interfaces
        rx_trans_rec  =>  pulse_rx_rec,
        tx_trans_rec  =>  pulse_tx_rec
      );

-----------------------------------------------------------
--                 TLM Test Controller                   --
--vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv--

  TestCtrl_1 : test_ctrl_e
    generic map (
      DATA_WIDTH     => DATA_WIDTH
    )
    port map (
      rst            =>  rst,
      stream_tx_rec  =>  stream_tx_rec,
      stream_rx_rec  =>  stream_rx_rec,
      sync_tx_rec    =>  sync_tx_rec,
      sync_rx_rec    =>  sync_rx_rec,
      pulse_rx_rec   =>  pulse_rx_rec,
      pulse_tx_rec   =>  pulse_tx_rec
    );

-----------------------------------------------------------
--               TLM Transmitter DUT's                   --
--vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv--

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
        
        rx_dat  =>  pam_map_data(0),
        rx_val  =>  pam_map_valid,
        rx_full =>  clk_sync_full,
        
        tx_dat  =>  clk_sync_data_in,
        tx_wr   =>  clk_sync_write
      );

  ----------------------------------------------
  --            Clock synchroniser            --
  ----------------------------------------------  
    Clk_Sync_DUT : ENTITY work.clk_sync
      generic map (
          DATA_WIDTH  =>  DATA_WIDTH
      )
      port map (
        clk_rd        =>  clk_b,
        clk_wr        =>  clk,
      
        rx_dat        =>  clk_sync_data_in,
        rx_rd         =>  clk_sync_read,
        rx_wr         =>  clk_sync_write,
      
        tx_dat        =>  open,
        tx_empty      =>  clk_sync_empty,
        tx_full       =>  clk_sync_full
        );

  ----------------------------------------------
  --            Pulse Shaper DUT              --
  ----------------------------------------------  
    PulseShaper_DUT : entity work.pulse_shaper
      generic map (
        DATA_WIDTH  =>  DATA_WIDTH
      )
      port map (
        rst         =>  rst,
        clk         =>  clk_b,
        --
        rx_dat      =>  clk_sync_data_out, 
        rx_empty    =>  pulse_shaper_valid_in,
        --
        tx_dat      =>  pulse_shaper_data_out,
        tx_read     =>  clk_sync_read,
        tx_val      =>  pulse_shaper_valid_out
      );

-----------------------------------------------------------
--                 TLM Receiver DUT's                    --
--vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv--

  ----------------------------------------------
  --            Match Filter DUT              --
  ----------------------------------------------  
    MatchFilter_DUT : entity work.match_filter
      generic map(
        DATA_WIDTH  =>  DATA_WIDTH
      )
      PORT MAP (
        rst         =>  rst,
        clk         =>  clk_b,
        --
        rx_dat      => pulse_shaper_data_out,
        --
        tx_dat      => match_filter_data_out,
        tx_val      => match_filter_valid_out
      );

  ----------------------------------------------
  --           Clock Recovery DUT             --
  ----------------------------------------------  
    ClockRecovery_DUT : entity work.clk_recovery
      generic map (
        DATA_WIDTH  =>  DATA_WIDTH
      )
      PORT MAP (
        rst         =>  rst,
        clk         =>  clk_b,
        --
        rx_dat      => match_filter_data_out,
        rx_val      => match_filter_valid_out,
        --
        tx_dat      => clk_recovery_data_out,
        tx_wr       => clk_recovery_wr_out 
      );

-----------------------------------------------------------
--                     TLM Top DUT                       --
--vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv--

    Transceiver_Top_DUT : entity work.tranceiver_top
      generic map (
        DATA_WIDTH  => DATA_WIDTH
      )
      port map (
        clk_wr      =>  clk,
        clk_rd      =>  clk_b,
        rst         =>  rst,

        rx_valid    =>  pam_map_valid,
        rx_data     =>  pam_map_data(0),
        
        tx_valid    =>  tranceiver_valid,
        tx_data     =>  tranceiver_data
      );

end testbench;