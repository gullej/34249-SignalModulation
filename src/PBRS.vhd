library ieee ;
  use ieee.std_logic_1164.all ;
  use ieee.numeric_std.all ;
  use ieee.std_logic_unsigned.all;

entity PBRS is
    port (
        clk       :  in  std_logic;
        rst       :  in  std_logic;
        --Output
        tx_data   :  out  std_logic;
        tx_valid  :  out  std_logic
    );
end entity PBRS;

architecture RTL of PBRS is

    signal sr     :  std_logic_vector(6 downto 0);
    signal valid  :  std_logic;

    begin

    tx_data  <=  sr(6);
    tx_valid <=  valid;

    process(clk) is
    begin
        if rising_edge(clk) then

            sr(0)  <=  sr(6) xor sr(5);
            sr(1)  <=  sr(0);
            sr(2)  <=  sr(1);
            sr(3)  <=  sr(2);
            sr(4)  <=  sr(3);
            sr(5)  <=  sr(4);
            sr(6)  <=  sr(5);
            
            valid  <=  '1';
            if rst = '1' then
                sr     <=  (others => '1');
                valid  <=  '0';
            end if;
        end if;
    end process;
end architecture RTL;