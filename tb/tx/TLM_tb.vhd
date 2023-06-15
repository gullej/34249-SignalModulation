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

  signal fifo_data_in   :  std_logic_vector(DATA_WIDTH-1 DOWNTO 0);
  signal fifo_data_out  :  std_logic_vector(DATA_WIDTH*8-1 DOWNTO 0);
  signal fifo_read      :  std_logic;
  signal fifo_write     :  std_logic;
  signal fifo_full      :  std_logic;
  signal fifo_empty     :  std_logic;

  signal pulse_shaper_valid_in   :  std_logic;
  signal pulse_shaper_valid_out  :  std_logic;
  signal pulse_shaper_data_out   :  std_logic_vector(13 DOWNTO 0);

  signal tranceiver_data   :  std_logic_vector(13 DOWNTO 0);
  signal tranceiver_valid  :  std_logic;

-----------------------------------------------------------
--         Transaction Interface Declaration             --
--vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv--

  signal stream_tx_rec, stream_rx_rec : StreamRecType (
    DataToModel(0 DOWNTO 0),
    DataFromModel(DATA_WIDTH - 1 DOWNTO 0),
    ParamToModel  (16 downto 0),
    ParamFromModel(16 downto 0)
  );

  signal  sync_tx_rec : StreamRecType (
    DataToModel(DATA_WIDTH - 1 DOWNTO 0),
    DataFromModel(DATA_WIDTH - 1 DOWNTO 0),
    ParamToModel  (16 downto 0),
    ParamFromModel(16 downto 0)
  );

  signal  sync_rx_rec : StreamRecType (
    DataToModel(8 * DATA_WIDTH - 1 DOWNTO 0),
    DataFromModel(8 * DATA_WIDTH - 1 DOWNTO 0),
    ParamToModel  (16 downto 0),
    ParamFromModel(16 downto 0)
  );

  signal  pulse_tx_rec, pulse_rx_rec : StreamRecType (
    DataToModel(8 * DATA_WIDTH - 1 DOWNTO 0),
    DataFromModel(13 DOWNTO 0),
    ParamToModel  (16 downto 0),
    ParamFromModel(16 downto 0)
  );


-----------------------------------------------------------
--        Test Controller Components Declaration         --
--vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv--

  component test_ctrl_e is
    port (
      rst  :  in  std_logic;
  
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
--             TLM Verification Components               --
--vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv--

    ------------------------------------------
    -- Graycode VC                          --
    ------------------------------------------
    TX_GrayCode_VC : entity work.graycode_tx_vc
    GENERIC MAP(
            DATA_WIDTH => DATA_WIDTH
        )
    port map (
      clk              => clk,
      rst              => rst,
      tx_valid         => pam_map_valid,
      tx_last          => open,
      tx_data          => pam_map_data,
      --Transactio interface
      trans_rec        => stream_tx_rec
    );

    RX_GrayCode_VC : entity work.graycode_rx_vc
    GENERIC MAP(
            DATA_WIDTH => DATA_WIDTH
        )
    port map (
      clk              => clk,
      rst              => rst,
      rx_write         => fifo_write,
      rx_data          => fifo_data_in,
      --Transactio interface
      trans_rec        => stream_rx_rec
    );

    ------------------------------------------
    -- Clk_sync VC                          --
    ------------------------------------------
    Clk_Sync_VC : entity work.clk_sync_rx_vc
    GENERIC MAP(
            DATA_WIDTH => DATA_WIDTH
        )
    port map (
      clk_rd            =>  clk_b,
      clk_wr            =>  clk,
      rst               =>  rst,

      rx_dat_in         =>  fifo_data_in,
      rx_rd_in          =>  fifo_read,
      rx_wr_in          =>  fifo_write,
      --
      rx_dat_out	      =>  fifo_data_out,
      rx_empty_out      =>  fifo_empty,
      rx_full_out       =>  fifo_full,

      --Transaction interface
      rx_trans_rec_in   =>  sync_tx_rec,
      rx_trans_rec_out  =>  sync_rx_rec
    );

    ------------------------------------------
    -- Pulse Shaper VC                      --
    ------------------------------------------
    Pulse_Shaper_VC : entity work.pulseshaper_rx_vc
      GENERIC MAP(
        DATA_WIDTH => DATA_WIDTH
      )
      port map (
        clk             =>  clk_b,
        rst             =>  rst,
        rx_valid        =>  pulse_shaper_valid_out,
        rx_data         =>  pulse_shaper_data_out,
        rx_read         =>  fifo_read,
        tx_empty        =>  pulse_shaper_valid_in,
        tx_data         =>  fifo_data_out,
        -- Transaction interfaces
        rx_trans_rec    =>  pulse_rx_rec,
        tx_trans_rec    =>  pulse_tx_rec
      );

-----------------------------------------------------------
--                 TLM Test Controller                   --
--vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv--

  TestCtrl_1 : test_ctrl_e
  GENERIC MAP(
        DATA_WIDTH => DATA_WIDTH
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
--                     TLM DUT's                         --
--vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv--

    GrayCode_COMP : entity work.pam_map
    generic map (
        DATA_WIDTH  =>  DATA_WIDTH
    )
    port map(
        rst     =>  rst,
        clk     =>  clk,
        --
        rx_dat  =>  pam_map_data(0),
        rx_val  =>  pam_map_valid,
        rx_full =>  fifo_full,
        --
        tx_dat  =>  fifo_data_in,
        tx_wr   =>  fifo_write
    );

    Clk_Sync_COMP : ENTITY work.clk_sync
        GENERIC MAP(
            DATA_WIDTH  =>  DATA_WIDTH
        )
        PORT MAP(
            clk_rd      =>  clk_b,
            clk_wr      =>  clk,
            --
            rx_dat      =>  fifo_data_in,
            rx_rd       =>  fifo_read,
            rx_wr       =>  fifo_write,
            --
            tx_dat      =>  open,
            tx_empty    =>  fifo_empty,
            tx_full     =>  fifo_full
        );

    PulseShaper_COMP : entity work.pulse_shaper
      generic map (
        DATA_WIDTH  =>  DATA_WIDTH
      )
      PORT MAP (
        rst         =>  rst,
        clk         =>  clk_b,
        --
        rx_dat      =>  fifo_data_out, 
        rx_empty    =>  pulse_shaper_valid_in,
        --
        tx_dat      =>  pulse_shaper_data_out,
        tx_read     =>  fifo_read,
        tx_val      =>  pulse_shaper_valid_out
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