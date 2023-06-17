LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY tranceiver_top IS
    GENERIC (
        DATA_WIDTH : INTEGER := 3
    );
    PORT (
        clk_wr    :  IN  STD_LOGIC;
        clk_rd    :  IN  STD_LOGIC;
        rst       :  IN  STD_LOGIC;
        --CONTROL INPUTS
        rx_valid  :  IN  STD_LOGIC;
        --DATA INPUTS
        rx_data   :  IN  STD_LOGIC;
        --CONTROL OUTPUTS
        tx_valid  :  OUT STD_LOGIC;
        --DATA OUTPUTS
        tx_data   :  OUT STD_LOGIC_VECTOR(13 DOWNTO 0)
    );
END tranceiver_top;

ARCHITECTURE tranceiver_top_arc OF tranceiver_top IS

    SIGNAL pam_map_data   :  STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
    SIGNAL pam_map_write  :  STD_LOGIC;

    SIGNAL clk_sync_data   :  STD_LOGIC_VECTOR(8 * DATA_WIDTH - 1 DOWNTO 0);
    SIGNAL clk_sync_empty  :  STD_LOGIC;
    SIGNAL clk_sync_full   :  STD_LOGIC;

    SIGNAL pulse_shaper_data   :  STD_LOGIC_VECTOR(13 DOWNTO 0);
    SIGNAL pulse_shaper_read   :  STD_LOGIC;
    SIGNAL pulse_shaper_valid  :  STD_LOGIC;

BEGIN

    tx_data   <=  pulse_shaper_data;
    tx_valid  <=  pulse_shaper_valid;

    Pam_Map_DUT : ENTITY WORK.pam_map
        GENERIC MAP (
            DATA_WIDTH  =>  DATA_WIDTH
        )
        PORT MAP (
            rst         =>  rst,
            clk         =>  clk_wr,
            --
            rx_dat      =>  rx_data,
            rx_val      =>  rx_valid,
            rx_full     =>  clk_sync_full,
            --
            tx_dat      =>  pam_map_data,
            tx_wr       =>  pam_map_write
        );

    CLK_Sync_DUT : ENTITY WORK.clk_sync
        GENERIC MAP (
            DATA_WIDTH  =>  DATA_WIDTH
        )
        PORT MAP (
            clk_rd      =>  clk_rd,
            clk_wr      =>  clk_wr,
            --
            rx_dat      =>  pam_map_data,
            rx_rd       =>  pulse_shaper_read,
            rx_wr       =>  pam_map_write,
            --
            tx_dat	    =>  clk_sync_data,
            tx_empty    =>  clk_sync_empty,
            tx_full     =>  clk_sync_full
        );

    Pulse_Shaper_DUT : ENTITY WORK.pulse_shaper
        GENERIC MAP (
            DATA_WIDTH  =>  DATA_WIDTH
        )
        PORT MAP (
            rst         =>  rst,
            clk         =>  clk_rd,
            --
            rx_dat      =>  clk_sync_data,
            rx_empty    =>  clk_sync_empty,
            --
            tx_dat      =>  pulse_shaper_data,
            tx_read     =>  pulse_shaper_read,
            tx_val      =>  pulse_shaper_valid
        );
END tranceiver_top_arc;