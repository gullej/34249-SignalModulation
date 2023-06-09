LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.numeric_std_unsigned.ALL;

ENTITY add_mul_tb IS
    GENERIC (
        DATA_WIDTH : INTEGER := 2
    );
END ENTITY add_mul_tb;

ARCHITECTURE testbench OF add_mul_tb IS

    CONSTANT coeff : signed(10 downto 0) := "00010000000";

    SIGNAL ans : signed(13 downto 0);

    SIGNAL a, b : signed(1 DOWNTO 0);
    SIGNAL c : signed(2 downto 0);

    SIGNAL sq : STD_LOGIC;

BEGIN

c <= resize(a,3) + resize(b,3);
ans <= coeff * c;

DRIVER : PROCESS
BEGIN
    WAIT FOR 5 ns;
    a <= "00";
    b <= "00";

    WAIT FOR 5 ns;
    a <= "00";
    b <= "01";

    WAIT FOR 5 ns;
    a <= "00";
    b <= "10";    
    
    WAIT FOR 5 ns;
    a <= "00";
    b <= "11";    
    
    WAIT FOR 5 ns;
    a <= "01";
    b <= "01";    
    
    WAIT FOR 5 ns;
    a <= "01";
    b <= "10";    
    
    WAIT FOR 5 ns;
    a <= "01";
    b <= "11";    
    
    WAIT FOR 5 ns;
    a <= "10";
    b <= "01";    
    
    WAIT FOR 5 ns;
    a <= "10";
    b <= "10";  

    WAIT FOR 5 ns;
    a <= "10";
    b <= "11";   

    WAIT;
END PROCESS DRIVER;

END testbench; -- testbench