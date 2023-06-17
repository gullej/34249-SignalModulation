LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY match_filter IS
    GENERIC (
        DATA_WIDTH : INTEGER);
    PORT (
        rst      : IN  STD_LOGIC;
        clk      : IN  STD_LOGIC;
        --
        rx_dat   : IN  STD_LOGIC_VECTOR(13 DOWNTO 0);
        --
        tx_dat   : OUT STD_LOGIC_VECTOR(27 DOWNTO 0);
        tx_val   : OUT STD_LOGIC
    );
END match_filter;

ARCHITECTURE match_filter_arc OF match_filter IS

    CONSTANT coeff_h0  : signed(12 downto 0) := "0000110011001";
    CONSTANT coeff_h1  : signed(12 downto 0) := "0000110001011";
    CONSTANT coeff_h2  : signed(12 downto 0) := "0000101100100";
    CONSTANT coeff_h3  : signed(12 downto 0) := "0000100101001";
    CONSTANT coeff_h4  : signed(12 downto 0) := "0000011011111";
    CONSTANT coeff_h5  : signed(12 downto 0) := "0000010010001";
    CONSTANT coeff_h6  : signed(12 downto 0) := "0000001000111";
    CONSTANT coeff_h7  : signed(12 downto 0) := "0000000001000";
    CONSTANT coeff_h8  : signed(12 downto 0) := "1111111011010";
    CONSTANT coeff_h9  : signed(12 downto 0) := "1111111000000";
    CONSTANT coeff_h10 : signed(12 downto 0) := "1111110111001";
    CONSTANT coeff_h11 : signed(12 downto 0) := "1111111000100";
    CONSTANT coeff_h12 : signed(12 downto 0) := "1111111011010";
    CONSTANT coeff_h13 : signed(12 downto 0) := "1111111110101";
    CONSTANT coeff_h14 : signed(12 downto 0) := "0000000001110";
    CONSTANT coeff_h15 : signed(12 downto 0) := "0000000100000";
    CONSTANT coeff_h16 : signed(12 downto 0) := "0000000010011";

    SIGNAl ctrl : STD_LOGIC_VECTOR(7 DOWNTO 0);

    type sr_type_x is array (0 to 40) of signed(14 downto 0);
    SIGNAL shift_reg_x : sr_type_x;

BEGIN

-- y[n] = h_16*x[n] + h_15*x[n-1] + h_14*x[n-2] + h_13*x[n-3] + h_12*x[n-4] + h_11*x[n-5] + h_10*x[n-6] + h_9*x[n-7] + h_8*x[n-8]
--        + h_7*x[n-9] + h_6*x[n-10] + h_5*x[n-11] + h_4*x[n-12] + h_3*x[n-13] + h_2*x[n-14] + h_1*x[n-15] + h_0*x[n-16] + h_1*x[n-17]
--        + h_2*x[n-18] + h_3*x[n-19] + h_4*x[n-20] + h_5*x[n-21] + h_6*x[n-22] + h_7*x[n-23] + h_8*x[n-24] + h_9*x[n-25] + h_10*x[n-26]
--        + h_11*x[n-27] + h_12*x[n-28] + h_13*x[n-29] + h_14*x[n-30] + h_15*x[n-31] + h_16*x[n-32] + 

-- y[n] = h_16 * (x[n] + x[n-32]) + h_15 * (x[n-1] + x[n-31]) + h_14 * (x[n-1] + x[n-30]) + h_13 * (x[n-3] x[n-29]) + h_12 * (x[n-4] + x[n-28])
--        + h_11 * (x[n-5] + x[n-27]) + h_10 * (x[n-6] + x[n-26]) + h_9 * (x[n-7] + x[n-25]) h_8 * (x[n-8] + x[n-24]) + h_7 * (x[n-9] + x[n-23]) + h_6 * (x[n-10] + x[n-22])
--        + h_5 * (x[n-11] + x[n-21]) + h_4 * (x[n-12] + x[n-20]) + h_3 * (x[n-13] + x[n-19]) + h_2 * (x[n-14] + x[n-18]) + h_1 * (x[n-15] + x[n-17]) + h_0 * x[n-16]

    tx_val <= '1';

    tx_dat <= std_logic_vector(
                coeff_h16   * (shift_reg_x(0)  + shift_reg_x(32)) 
                + coeff_h15 * (shift_reg_x(1)  + shift_reg_x(31)) 
                + coeff_h14 * (shift_reg_x(1)  + shift_reg_x(30)) 
                + coeff_h13 * (shift_reg_x(3)  + shift_reg_x(29)) 
                + coeff_h12 * (shift_reg_x(4)  + shift_reg_x(28))
                + coeff_h11 * (shift_reg_x(5)  + shift_reg_x(27)) 
                + coeff_h10 * (shift_reg_x(6)  + shift_reg_x(26)) 
                + coeff_h9  * (shift_reg_x(7)  + shift_reg_x(25)) 
                + coeff_h7  * (shift_reg_x(9)  + shift_reg_x(23)) 
                + coeff_h8  * (shift_reg_x(8)  + shift_reg_x(24))
                + coeff_h6  * (shift_reg_x(10) + shift_reg_x(22))
                + coeff_h5  * (shift_reg_x(11) + shift_reg_x(21)) 
                + coeff_h4  * (shift_reg_x(12) + shift_reg_x(20)) 
                + coeff_h3  * (shift_reg_x(13) + shift_reg_x(19)) 
                + coeff_h2  * (shift_reg_x(14) + shift_reg_x(18)) 
                + coeff_h1  * (shift_reg_x(15) + shift_reg_x(17)) 
                + coeff_h0  *  shift_reg_x(16) );

    SR : PROCESS(clk)
    BEGIN
        IF (RISING_EDGE(clk)) THEN
            shift_reg_x(1 to 40) <= shift_reg_x(0 to 39);
            shift_reg_x(0) <= resize(signed(rx_dat), 15);

            IF rst = '1' then
                shift_reg_x  <=  (others => (others => '0'));
            end if;     
        END IF;
    END PROCESS SR;
END match_filter_arc;