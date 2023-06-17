library ieee;
  use ieee.std_logic_1164.all;

library osvvm_common;
  context osvvm_common.OsvvmCommonContext;

package tranceiver_component_pkg is

    ------------------------------------------------------------
    component PBRS is
    ------------------------------------------------------------
        port (
            clk       :  in  std_logic;
            rst       :  in  std_logic;
            --Output
            tx_data   :  out  std_logic;
            tx_valid  :  out  std_logic
        );
    end component PBRS;



    ------------------------------------------------------------
    component pam_map is
    ------------------------------------------------------------
        generic (
            DATA_WIDTH : INTEGER := 3
        );
        port (
            rst        :  IN  STD_LOGIC;
            clk        :  IN  STD_LOGIC;
            --
            rx_dat     :  IN  STD_LOGIC;
            rx_val     :  IN  STD_LOGIC;
            rx_full    :  IN  STD_LOGIC;
            --
            tx_dat     :  OUT STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
            tx_wr      :  OUT STD_LOGIC
        );
    end component pam_map;



    ------------------------------------------------------------
    component clk_sync is
    ------------------------------------------------------------
        generic (
            DATA_WIDTH : INTEGER := 3
        );
        port (
            clk_rd      :  IN  STD_LOGIC;
            clk_wr      :  IN  STD_LOGIC;
            
            rx_dat      :  IN  STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
            rx_rd       :  IN  STD_LOGIC;
            rx_wr       :  IN  STD_LOGIC;
            
            tx_dat	    :  OUT STD_LOGIC_VECTOR(8 * DATA_WIDTH - 1 DOWNTO 0);
            tx_empty    :  OUT STD_LOGIC;
            tx_full     :  OUT STD_LOGIC 
        );
    end component clk_sync;


    ------------------------------------------------------------
    component pulse_shaper IS
    ------------------------------------------------------------
        generic (
            DATA_WIDTH : INTEGER := 3
        );
        port (
            rst         : IN  STD_LOGIC;
            clk         : IN  STD_LOGIC;
            
            rx_dat      : IN  STD_LOGIC_VECTOR(8 * DATA_WIDTH - 1 DOWNTO 0);
            rx_empty    : IN  STD_LOGIC;

            tx_dat      : OUT STD_LOGIC_VECTOR(13 DOWNTO 0);
            tx_read     : OUT STD_LOGIC;
            tx_val      : OUT STD_LOGIC
        );
    end component pulse_shaper;



    ------------------------------------------------------------
    component graycode_rx_vc is
    ------------------------------------------------------------
        generic (
            MODEL_ID_NAME   : string := "" ;

            DATA_WIDTH      : integer;

            tperiod_Clk     : time := 10 ns ;
            DEFAULT_DELAY   : time := 1 ns ;

            tpd_rx_write    : time := DEFAULT_DELAY;
            tpd_rx_data     : time := DEFAULT_DELAY
        );
        port (
            clk             :  in  std_logic;
            rst             :  in  std_logic;

            rx_write        :  in  std_logic;
            rx_data         :  in  std_logic_vector(DATA_WIDTH-1 DOWNTO 0);

            trans_rec       :  inout StreamRecType
        );
    end component graycode_rx_vc;


    ------------------------------------------------------------
    component graycode_tx_vc is
    ------------------------------------------------------------
        generic (
            MODEL_ID_NAME   : string := "" ;

            DATA_WIDTH      : integer := 2;

            tperiod_Clk     : time := 10 ns ;
            DEFAULT_DELAY   : time := 1 ns ;

            tpd_tx_valid    : time := DEFAULT_DELAY;
            tpd_tx_last     : time := DEFAULT_DELAY;
            tpd_tx_data     : time := DEFAULT_DELAY
        );
        port (
            clk             :  in  std_logic;
            rst             :  in  std_logic;

            tx_valid        :  out std_logic;
            tx_last         :  out std_logic;
            tx_data         :  out std_logic_vector(0 DOWNTO 0);

            trans_rec       :  inout StreamRecType
        );
    end component graycode_tx_vc;

    ------------------------------------------------------------
    component clk_sync_rx_vc is
    ------------------------------------------------------------
        generic (
            MODEL_ID_NAME     : string := "" ;

            DATA_WIDTH        : integer;

            tperiod_Clk       : time := 10 ns ;
            DEFAULT_DELAY     : time := 1 ns ;

            tpd_rx_write      : time := DEFAULT_DELAY;
            tpd_rx_data       : time := DEFAULT_DELAY
        );
        port (
            clk_rd            :  in  STD_LOGIC;
            clk_wr            :  IN  STD_LOGIC;
            rst               :  in  STD_LOGIC;

            rx_dat_in         :  IN  STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
            rx_rd_in          :  IN  STD_LOGIC;
            rx_wr_in          :  IN  STD_LOGIC;
            
            rx_dat_out	      :  IN  STD_LOGIC_VECTOR(8 * DATA_WIDTH - 1 DOWNTO 0);
            rx_empty_out      :  IN  STD_LOGIC;
            rx_full_out       :  IN  STD_LOGIC;

            rx_trans_rec_in   :  inout StreamRecType;
            rx_trans_rec_out  :  inout StreamRecType
        );
    end component;



    ------------------------------------------------------------
    component pulseshaper_rx_vc is
    ------------------------------------------------------------
        generic (
            MODEL_ID_NAME   : string := "" ;

            DATA_WIDTH      : integer := 2;

            tperiod_Clk     : time := 10 ns ;
            DEFAULT_DELAY   : time := 1 ns ;

            tpd_rx_write    : time := DEFAULT_DELAY;
            tpd_rx_data     : time := DEFAULT_DELAY
        );
        port (
            clk             :  in  std_logic;
            rst             :  in  std_logic;

            rx_valid        :  in  std_logic;
            rx_data         :  in  std_logic_vector(13 DOWNTO 0);

            rx_read         :  in  std_logic;

            tx_empty        :  out std_logic;
            tx_data         :  out std_logic_vector(8 * DATA_WIDTH - 1 DOWNTO 0);

            rx_trans_rec    :  inout StreamRecType;
            tx_trans_rec    :  inout StreamRecType
        );
    end component pulseshaper_rx_vc;

end package tranceiver_component_pkg;