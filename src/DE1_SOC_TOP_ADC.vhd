library ieee ;
  use ieee.std_logic_1164.all ;
  use ieee.numeric_std.all ;
  use ieee.std_logic_unsigned.all;
  
entity DE1_SOC_TOP_ADC is
    port (
        -- 0 TO 13 Data | Data Pins A on GPIO 0 of ADC
        GPIO_0_D17  :  IN  STD_LOGIC;
        GPIO_0_D19  :  IN  STD_LOGIC;
        GPIO_0_D20  :  IN  STD_LOGIC;
        GPIO_0_D22  :  IN  STD_LOGIC;
        GPIO_0_D21  :  IN  STD_LOGIC;
        GPIO_0_D23  :  IN  STD_LOGIC;
        GPIO_0_D24  :  IN  STD_LOGIC;
        GPIO_0_D26  :  IN  STD_LOGIC;
        GPIO_0_D25  :  IN  STD_LOGIC;
        GPIO_0_D27  :  IN  STD_LOGIC;
        GPIO_0_D28  :  IN  STD_LOGIC;
        GPIO_0_D30  :  IN  STD_LOGIC;
        GPIO_0_D29  :  IN  STD_LOGIC;
        GPIO_0_D31  :  IN  STD_LOGIC;

    );
end entity DE1_SOC_TOP_ADC;

architecture RTL of DE1_SOC_TOP_ADC is

    begin

    GPIO_0_D17  <=  rx_data(0);
    GPIO_0_D19  <=  rx_data(1);
    GPIO_0_D20  <=  rx_data(2);
    GPIO_0_D22  <=  rx_data(3);
    GPIO_0_D21  <=  rx_data(4);
    GPIO_0_D23  <=  rx_data(5);
    GPIO_0_D24  <=  rx_data(6);
    GPIO_0_D26  <=  rx_data(7);
    GPIO_0_D25  <=  rx_data(8);
    GPIO_0_D27  <=  rx_data(9);
    GPIO_0_D28  <=  rx_data(10);
    GPIO_0_D30  <=  rx_data(11);
    GPIO_0_D29  <=  rx_data(12);
    GPIO_0_D31  <=  rx_data(13);

    Tranciever_Top : entity work.tranceiver_top
        GENERIC (
            DATA_WIDTH
        );
        PORT (
            clk_wr    =>  ,
            clk_rd    =>  ,
            rst       =>  ,
            
            rx_valid  =>  ,
            rx_data   =>  ,
             
            tx_valid  =>  ,
            tx_data   =>  
        );

end architecture RTL;