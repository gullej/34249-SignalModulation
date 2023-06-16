LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY receiver_top IS
    GENERIC (
        DATA_WIDTH : INTEGER := 3
    );
    PORT (
        clk_f     :  IN  STD_LOGIC;
        clk_s     :  IN  STD_LOGIC;
        rst       :  IN  STD_LOGIC;
        --
        rx_data   : IN STD_LOGIC_VECTOR(13 DOWNTO 0);
        --
        tx_data   : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        tx_val    : OUT STD_LOGIC
    );
END receiver_top;

ARCHITECTURE receiver_top_arc OF receiver_top IS

    SIGNAL match_filter_dat_out : STD_LOGIC_VECTOR(27 DOWNTO 0);
    SIGNAL match_filter_val_out : STD_LOGIC;

    SIGNAL clock_recovery_adr_out : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL clock_recovery_val_out : STD_LOGIC;

    SIGNAL downsample_dat_out : STD_LOGIC_VECTOR(27 DOWNTO 0);
    SIGNAL downsample_val_out : STD_LOGIC;

    SIGNAL hard_decision_dat_out : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL hard_decision_val_out : STD_LOGIC;

BEGIN

    tx_data <= hard_decision_dat_out;
    tx_val  <= hard_decision_val_out;

    MatchFilter : ENTITY work.match_filter 
    GENERIC MAP (
        DATA_WIDTH => DATA_WIDTH
    )
    PORT MAP(
        rst      => rst,
        clk      => clk_f,
        --
        rx_dat   => rx_data,
        --
        tx_dat   => match_filter_dat_out,
        tx_val   => match_filter_val_out
    );

    Clock_Recovery : ENTITY work.clk_recovery
    GENERIC MAP (
        DATA_WIDTH => DATA_WIDTH
    )
    PORT MAP (
        rst      => rst,
        clk      => clk_f,
        --
        rx_dat   => match_filter_dat_out,
        rx_val   => match_filter_val_out,
        --
        tx_dat   => clock_recovery_adr_out,
        tx_wr    => clock_recovery_val_out
    );

    Downsample : ENTITY work.downsample
    GENERIC MAP (
        DATA_WIDTH => DATA_WIDTH
    )
    PORT MAP (
        rst         => rst,
        clk_wr      => clk_f,
        clk_rd      => clk_s,
        --
        rx_dat      => match_filter_dat_out,
        rx_wr       => match_filter_val_out,
        --
        rx_addr     => clock_recovery_adr_out,
        rx_rd       => clock_recovery_val_out,
        --
        tx_dat      => downsample_dat_out,
        tx_val      => downsample_val_out
    );

    Hard_Decision : ENTITY work.hard_decision
    GENERIC MAP (
        DATA_WIDTH => DATA_WIDTH
    )
    PORT MAP (
        rst         => rst,
        clk         => clk_s,
        --
        rx_dat      => downsample_dat_out,
        rx_val      => downsample_val_out,
        --
        tx_dat      => hard_decision_dat_out,
        tx_val      => hard_decision_val_out
    );

END receiver_top_arc;