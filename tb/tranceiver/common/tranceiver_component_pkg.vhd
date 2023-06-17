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