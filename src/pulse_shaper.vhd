LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY pulse_shaper IS
    GENERIC (
        DATA_WIDTH : INTEGER);
    PORT (
        rst      : IN  STD_LOGIC;
        clk      : IN  STD_LOGIC;
        --
        rx_dat_i : IN  STD_LOGIC_VECTOR(8 * DATA_WIDTH - 1 DOWNTO 0);
        -- { x[n-7] x[n-6] x[n-5] x[n-4] x[n-3] x[n-2] x[n-1] x[n] } 
        rx_val_i : IN  STD_LOGIC;
        --
        tx_dat_o : OUT STD_LOGIC_VECTOR(13 DOWNTO 0);
        -- y[n]
        tx_val_o : OUT STD_LOGIC
    );
END pulse_shaper;

ARCHITECTURE pulse_shaper_arc OF pulse_shaper IS

    CONSTANT coeff_h0  : signed(13 downto 0) := "00000011001100";
    CONSTANT coeff_h1  : signed(13 downto 0) := "00000011000110";
    CONSTANT coeff_h2  : signed(13 downto 0) := "00000010110010";
    CONSTANT coeff_h3  : signed(13 downto 0) := "00000010010100";
    CONSTANT coeff_h4  : signed(13 downto 0) := "00000001110000";
    CONSTANT coeff_h5  : signed(13 downto 0) := "00000001001001";
    CONSTANT coeff_h6  : signed(13 downto 0) := "00000000100011";
    CONSTANT coeff_h7  : signed(13 downto 0) := "00000000000100";
    --       coeff_h8  == h_12
    CONSTANT coeff_h9  : signed(13 downto 0) := "11111111100000";
    CONSTANT coeff_h10 : signed(13 downto 0) := "11111111011101";
    CONSTANT coeff_h11 : signed(13 downto 0) := "11111111100010";
    CONSTANT coeff_h12 : signed(13 downto 0) := "11111111101101";
    CONSTANT coeff_h13 : signed(13 downto 0) := "11111111111010";
    CONSTANT coeff_h14 : signed(13 downto 0) := "00000000000111";
    CONSTANT coeff_h15 : signed(13 downto 0) := "00000000010000";
    CONSTANT coeff_h16 : signed(13 downto 0) := "00000000001010";

    SIGNAL reg_x : SIGNED(13 DOWNTO 0);

BEGIN

-- y[n] = h_16*x[n] + h_15*x[n-1] + h_14*x[n-2] + h_13*x[n-3] + h_12*x[n-4] + h_11*x[n-5] + h_10*x[n-6] + h_9*x[n-7] + h_8*x[n-8]
--        + h_7*x[n-9] + h_6*x[n-10] + h_5*x[n-11] + h_4*x[n-12] + h_3*x[n-13] + h_2*x[n-14] + h_1*x[n-15] + h_0*x[n-16] + h_1*x[n-17]
--        + h_2*x[n-18] + h_3*x[n-19] + h_4*x[n-20] + h_5*x[n-21] + h_6*x[n-22] + h_7*x[n-23] + h_8*x[n-24] + h_9*x[n-25] + h_10*x[n-26]
--        + h_11*x[n-27] + h_12*x[n-28] + h_13*x[n-29] + h_14*x[n-30] + h_15*x[n-31] + h_16*x[n-32] + 

-- y[n] = h_16 * (x[n] + x[n-32]) + h_15 * (x[n-1] + x[n-31]) + h_14 * (x[n-1] + x[n-30]) + h_13 * (x[n-3] x[n-29]) + h_12 * (x[n-4] + x[n-8] + x[n-24] + x[n-28})
--        + h_11 * (x[n-5] + x[n-27]) + h_10 * (x[n-6] + x[n-26]) + h_9 * (x[n-7] + x[n-25]) + h_7 * (x[n-9] + x[n-23]) + h_6 * (x[n-10] + x[n-22])
--        + h_5 * (x[n-11] + x[n-21]) + h_4 * (x[n-12] + x[n-20]) + h_3 * (x[n-13] + x[n-19]) + h_2 * (x[n-14] + x[n-18]) + h_1 * (x[n-15] + x[n-17]) + h_0 * x[n-16]


END pulse_shaper_arc;