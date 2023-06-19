library ieee ;
  use ieee.std_logic_1164.all ;
  use ieee.numeric_std.all ;
  use ieee.std_logic_unsigned.all;

entity DE1_SOC_TOP_DAC is
    port (
        CLOCK_50    :  IN  STD_LOGIC;
        rst_button  :  IN  STD_LOGIC; --Reset Button
        -- 0 TO 13 Data | Data Pins A on GPIO 0 of ADC
        GPIO_1_D15  :  OUT STD_LOGIC; --Data Pin 0
        GPIO_1_D13  :  OUT STD_LOGIC; --Data Pin 1
        GPIO_1_D14  :  OUT STD_LOGIC; --Data Pin 2
        GPIO_1_D12  :  OUT STD_LOGIC; --Data Pin 3
        GPIO_1_D11  :  OUT STD_LOGIC; --Data Pin 4
        GPIO_1_D9   :  OUT STD_LOGIC; --Data Pin 5
        GPIO_1_D10  :  OUT STD_LOGIC; --Data Pin 6
        GPIO_1_D8   :  OUT STD_LOGIC; --Data Pin 7
        GPIO_1_D7   :  OUT STD_LOGIC; --Data Pin 8
        GPIO_1_D5   :  OUT STD_LOGIC; --Data Pin 9
        GPIO_1_D6   :  OUT STD_LOGIC; --Data Pin 10
        GPIO_1_D4   :  OUT STD_LOGIC; --Data Pin 11
        GPIO_1_D3   :  OUT STD_LOGIC; --Data Pin 12
        GPIO_1_D1   :  OUT STD_LOGIC; --Data Pin 13
        --SMA_DAC4 | SMA D/A External Clock Input (J5)
        GPIO_1_D0   :  OUT STD_LOGIC;
        --OSC_SMA_ADC4 | SMA A/D External Clock Input (J5) or 100MHz Oscillator Clock Input
        GPIO_1_D2   :  OUT STD_LOGIC;
        --PLL_OUT_DAC0 | PLL Clock Input Channel A
        GPIO_1_D16  :  IN  STD_LOGIC;
        --DAC_WRTA | Input Write Signal Channel A
        GPIO_1_D17  :  OUT STD_LOGIC;
        --DAC_MODE | Mode Select. 1=dual port, 0=interleaved
        GPIO_1_D35  :  OUT STD_LOGIC

    );
end entity DE1_SOC_TOP_DAC;

architecture RTL of DE1_SOC_TOP_DAC is

    constant DATA_WIDTH  :  integer := 3;

    signal clk_160  :  std_logic;
    signal clk_20   :  std_logic;
    signal locked   :  std_logic;
    signal clk_200  :  std_logic;
    signal locked2  :  std_logic;

    signal SMA_DAC4      :  std_logic;
    signal OSC_SMA_ADC4  :  std_logic;

    signal pbrs_data   :  std_logic;
    signal pbrs_valid  :  std_logic;

    signal tx_tranceiver_data   :  std_logic_vector(13 DOWNTO 0);
    signal tx_tranceiver_valid  :  std_logic;

    component PLL_0002 is
        port (
            refclk   : in  std_logic := 'X'; -- clk
            rst      : in  std_logic := 'X'; -- reset
            outclk_0 : out std_logic;        -- clk
            outclk_1 : out std_logic;        -- clk
            locked   : out std_logic         -- export
        );
    end component PLL_0002;

    component PLL2_0002 is
		port (
			refclk   : in  std_logic := 'X'; -- clk
			rst      : in  std_logic := 'X'; -- reset
			outclk_0 : out std_logic;        -- clk
			locked   : out std_logic         -- export
		);
	end component PLL2_0002;

    begin
    
    -- Data Pins
    GPIO_0_D15  <=  tx_tranceiver_data(0);
    GPIO_0_D13  <=  tx_tranceiver_data(1);
    GPIO_0_D14  <=  tx_tranceiver_data(2);
    GPIO_0_D12  <=  tx_tranceiver_data(3);
    GPIO_0_D11  <=  tx_tranceiver_data(4);
    GPIO_0_D9   <=  tx_tranceiver_data(5);
    GPIO_0_D10  <=  tx_tranceiver_data(6);
    GPIO_0_D8   <=  tx_tranceiver_data(7);
    GPIO_0_D7   <=  tx_tranceiver_data(8);
    GPIO_0_D5   <=  tx_tranceiver_data(9);
    GPIO_0_D6   <=  tx_tranceiver_data(10);
    GPIO_0_D4   <=  tx_tranceiver_data(11);
    GPIO_0_D3   <=  tx_tranceiver_data(12);
    GPIO_0_D1   <=  tx_tranceiver_data(13);
    
    --Clock out
    GPIO_0_D0  <=  clk_20;

    --Write Pin
    GPIO_0_D17  <=  tx_tranceiver_valid;
    
    pll_inst : component PLL_0002
        port map (
            refclk   => CLOCK_50,   --  refclk.clk
            rst      => '0',      --   reset.reset
            outclk_0 => clk_160, -- outclk0.clk
            outclk_1 => clk_20, -- outclk1.clk
            locked   => locked    --  locked.export
        );

    pll2_inst : component PLL2_0002
        port map (
            refclk    =>  CLOCK_50,
            rst       =>  '0',
            outclk_0  =>  clk_200,
            locked    =>  locked2
        );

    PBRS_Map : entity work.PBRS
        port map (
            clk       =>  clk_160,
            rst       =>  not rst_button,
            --Output
            tx_data   =>  pbrs_data,
            tx_valid  =>  pbrs_valid
        );

    Tranciever_Top : entity work.tranceiver_top
        generic map (
            DATA_WIDTH  =>  DATA_WIDTH
        )
        port map (
            clk_wr      =>  clk_160,
            clk_rd      =>  clk_20,
            rst         =>  not rst_button,
            
            rx_valid    =>  pbrs_valid,
            rx_data     =>  pbrs_data,
             
            tx_valid    =>  tx_tranceiver_valid,
            tx_data     =>  tx_tranceiver_data
        );

end architecture RTL;