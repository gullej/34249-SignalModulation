library ieee ;
  use ieee.std_logic_1164.all ;
  use ieee.numeric_std.all ;
  use ieee.numeric_std_unsigned.all ;
  use ieee.math_real.all ;
  
library OSVVM ; 
  context OSVVM.OsvvmContext ; 
  use osvvm.ScoreboardPkg_slv.all ;

library osvvm_common ;
  context osvvm_common.OsvvmCommonContext ;

entity test_ctrl_e is
  generic (
    DATA_WIDTH  :  integer := 2
  );
  port (
    rst  :  in  std_logic;

    --Transaction interface
    
    stream_tx_rec  :  inout StreamRecType;
    stream_rx_rec  :  inout StreamRecType

  );
end test_ctrl_e;