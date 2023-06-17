library ieee ;
  use ieee.std_logic_1164.all ;
  use ieee.numeric_std.all ;
  use ieee.numeric_std_unsigned.all ;

library osvvm ;
  context osvvm.OsvvmContext ;

library osvvm_common ;
  context osvvm_common.OsvvmCommonContext ;

library tranceiver_lib;
  context tranceiver_lib.transceiver_context;

entity TLM_tb is
end entity TLM_tb ;

architecture testbench of TLM_tb is

-----------------------------------------------------------
--            Constant/Generic Declaration               --
--vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv--

  constant DATA_WIDTH : integer := 3; -- Data width at transceiver input interface

  constant tperiod_Clk   : time := 10 ns ;
  constant tperiod_Clk_b : time := 20 ns ;
  constant tperiod_Clk_c : time := 160 ns ;
  constant tpd           : time := 2 ns ;

-----------------------------------------------------------
--                  Signal Declaration                   --
--vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv--

  signal clk    :  std_logic;
  signal clk_b  :  std_logic;
  signal clk_c  :  std_logic;
  signal rst    :  std_logic;

  signal pam_map_data   :  std_logic_vector(0 DOWNTO 0);
  signal pam_map_valid  :  std_logic;
  signal pam_map_full   :  std_logic;

  signal clk_sync_data_in   :  std_logic_vector(DATA_WIDTH-1 DOWNTO 0);
  signal clk_sync_data_out  :  std_logic_vector(DATA_WIDTH*8-1 DOWNTO 0);
  signal clk_sync_read      :  std_logic;
  signal clk_sync_write     :  std_logic;
  signal clk_sync_full      :  std_logic;
  signal clk_sync_empty     :  std_logic;

  signal pulse_shaper_valid_in   :  std_logic;
  signal pulse_shaper_valid_out  :  std_logic;
  signal pulse_shaper_data_in    :  std_logic_vector(8 * DATA_WIDTH - 1 DOWNTO 0);
  signal pulse_shaper_data_out   :  std_logic_vector(13 DOWNTO 0);

  signal match_filter_data_out   :  std_logic_vector(27 DOWNTO 0);
  signal match_filter_valid_out  :  std_logic;

  signal clk_recovery_data_out   :  std_logic_vector(3 DOWNTO 0);
  signal clk_recovery_wr_out     :  std_logic;

  signal downsample_data_out     :  std_logic_vector(27 DOWNTO 0);
  signal downsample_val_out      :  std_logic;

  signal hard_decision_data_out  : std_logic_vector(1 DOWNTO 0);
  signal hard_decision_val_out   : std_logic;

  signal tranceiver_data   :  std_logic_vector(13 DOWNTO 0);
  signal tranceiver_valid  :  std_logic;

-----------------------------------------------------------
--         Transaction Interface Declaration             --
--vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv--

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

  -- Clock Synchroniser Rx VC signals
  --Input signals
  signal rx_clk_sync_vc_dat_in     :  std_logic_vector(DATA_WIDTH - 1 DOWNTO 0);
  signal rx_clk_sync_vc_rd_in      :  std_logic;
  signal rx_clk_sync_vc_wr_in      :  std_logic;
  --Output signals
  signal rx_clk_sync_vc_dat_out	   :  std_logic_vector(8 * DATA_WIDTH - 1 DOWNTO 0);
  signal rx_clk_sync_vc_empty_out  :  std_logic;
  signal rx_clk_sync_vc_full_out   :  std_logic;

  -- Pulse Shaper VC signals
  --Receive signals 
  signal rx_pulse_shaper_vc_valid  :  std_logic;
  signal rx_pulse_shaper_vc_data   :  std_logic_vector(13 DOWNTO 0);
  signal rx_pulse_shaper_vc_read   :  std_logic;
  --Transmsit signals
  signal tx_pulse_shaper_vc_empty  :  std_logic;
  signal tx_pulse_shaper_vc_data   :  std_logic_vector(8 * DATA_WIDTH - 1 DOWNTO 0);

  -- Pulse2Out VC signals
  signal pulse2out_vc_data         : std_logic_vector(1 downto 0);
  signal pulse2out_vc_valid        : std_logic;
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
      pulse_tx_rec   :  inout StreamRecType;
      hard_decision_rx_rec : inout StreamRecType
    );
  end component; 

  begin

    -- Mapping of Gray Code Tx VC
    pam_map_valid  <=  tx_gray_code_vc_valid;
    pam_map_data   <=  tx_gray_code_vc_data;
    
    -- Mapping of Gray Code Rx VC
    rx_gray_code_vc_write  <=  clk_sync_write;
    rx_gray_code_vc_data   <=  clk_sync_data_in;
    
    -- Mapping of Clock Synchroniser RX VC
    --Input signals
    rx_clk_sync_vc_dat_in     <=  clk_sync_data_in;
    rx_clk_sync_vc_rd_in      <=  clk_sync_read;
    rx_clk_sync_vc_wr_in      <=  clk_sync_write;
    --Output signals
    rx_clk_sync_vc_dat_out	  <=  clk_sync_data_out;
    rx_clk_sync_vc_empty_out  <=  clk_sync_empty;
    rx_clk_sync_vc_full_out   <=  clk_sync_full;


    rx_pulse_shaper_vc_valid  <=  pulse_shaper_valid_out;
    rx_pulse_shaper_vc_data   <=  pulse_shaper_data_out;

    
    rx_pulse_shaper_vc_read   <=  clk_sync_read;


    pam_map_full  <=  '0' when (stream_tx_rec.ParamFromModel = x"0002") else
                      clk_sync_full;

    pulse_shaper_valid_in  <=  tx_pulse_shaper_vc_empty when (pulse_tx_rec.ParamFromModel = x"0001") else
                               clk_sync_empty;
    pulse_shaper_data_in   <=  tx_pulse_shaper_vc_data when (pulse_tx_rec.ParamFromModel = x"0001") else
                               clk_sync_data_out;

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

    -- create Clock
    Osvvm.TbUtilPkg.CreateClock (
      Clk        => clk_c,
      Period     => tperiod_Clk_c
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

  ------------------------------------------
  --             Clk_sync VC              --
  ------------------------------------------
    Clk_Sync_VC : clk_sync_rx_vc
    GENERIC MAP(
            DATA_WIDTH => DATA_WIDTH
        )
    port map (
      clk_rd            =>  clk_b,
      clk_wr            =>  clk,
      rst               =>  rst,

      rx_dat_in         =>  rx_clk_sync_vc_dat_in,
      rx_rd_in          =>  rx_clk_sync_vc_rd_in,
      rx_wr_in          =>  rx_clk_sync_vc_wr_in,
      
      rx_dat_out	      =>  rx_clk_sync_vc_dat_out,
      rx_empty_out      =>  rx_clk_sync_vc_empty_out,
      rx_full_out       =>  rx_clk_sync_vc_full_out,

      --Transaction interface
      rx_trans_rec_in   =>  sync_tx_rec,
      rx_trans_rec_out  =>  sync_rx_rec
    );

  ------------------------------------------
  --           Pulse Shaper VC            --
  ------------------------------------------
    Pulse_Shaper_VC : pulseshaper_rx_vc
      generic map (
        DATA_WIDTH    => DATA_WIDTH
      )
      port map (
        clk           =>  clk_b,
        rst           =>  rst,
        rx_valid      =>  rx_pulse_shaper_vc_valid,
        rx_data       =>  rx_pulse_shaper_vc_data,
        rx_read       =>  rx_pulse_shaper_vc_read,
        tx_empty      =>  tx_pulse_shaper_vc_empty,
        tx_data       =>  tx_pulse_shaper_vc_data,
        -- Transaction interfaces
        rx_trans_rec  =>  pulse_rx_rec,
        tx_trans_rec  =>  pulse_tx_rec
      );

  ------------------------------------------
  --           Hard Decision VC           --
  ------------------------------------------
  HardDecision_VC : entity work.pulse2out_rx_vc
  generic map (
    DATA_WIDTH    => DATA_WIDTH
  )
  port map (
    clk           =>  clk_c,
    rst           =>  rst,
    rx_data       =>  pulse2out_vc_data,
    rx_val        =>  pulse2out_vc_valid,
    -- Transaction interfaces
    trans_rec  =>  hard_decision_rx_rec
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
      pulse_tx_rec   =>  pulse_tx_rec,
      hard_decision_rx_rec => hard_decision_rx_rec
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
        rx_full =>  pam_map_full,
        
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
      
        tx_dat        =>  clk_sync_data_out,
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
        rx_dat      =>  pulse_shaper_data_in,
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

  ----------------------------------------------
  --             Downsample DUT               --
  ----------------------------------------------  

    Downsample_DUT : entity work.downsample
    generic map(
      DATA_WIDTH  =>  DATA_WIDTH
    )
    PORT MAP (
      rst         =>  rst,
      clk_wr      => clk_b,
      clk_rd      => clk_c,
      --
      rx_dat      => match_filter_data_out,
      rx_wr       => match_filter_valid_out,
      --
      rx_addr     => clk_recovery_data_out,
      rx_rd       => clk_recovery_wr_out,
      --
      tx_dat      => downsample_data_out,
      tx_val      => downsample_val_out
    );

  ----------------------------------------------
  --                 HD DUT                   --
  ----------------------------------------------

  HardDecision_DUT : entity work.hard_decision
  generic map(
    DATA_WIDTH  =>  DATA_WIDTH
  )
  PORT MAP (
    rst         =>  rst,
    clk         => clk_c,
    --
    rx_dat      => downsample_data_out,
    rx_val      => downsample_val_out,
    --
    tx_dat      => pulse2out_vc_data,
    tx_val      => pulse2out_vc_valid
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