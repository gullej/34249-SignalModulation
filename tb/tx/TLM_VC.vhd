library ieee ;
  use ieee.std_logic_1164.all ;
  use ieee.numeric_std.all ;
  use ieee.numeric_std_unsigned.all ;
  use ieee.math_real.all ;

library osvvm ;
  context osvvm.OsvvmContext ;

library osvvm_common ;
  context osvvm_common.OsvvmCommonContext ;

entity TLM_VC is
    generic (
        MODEL_ID_NAME   : string := "" ;

        tperiod_Clk     : time := 10 ns ;
        DEFAULT_DELAY   : time := 1 ns ;

        tpd_rx_valid    : time := DEFAULT_DELAY;
        tpd_rx_last     : time := DEFAULT_DELAY;
        tpd_rx_data     : time := DEFAULT_DELAY;

        tpd_tx_valid    : time := DEFAULT_DELAY;
        tpd_tx_last     : time := DEFAULT_DELAY;
        tpd_tx_data     : time := DEFAULT_DELAY
    );
    port (
        clk        :  in  std_logic;
        rst        :  in  std_logic;

        rx_valid   :  in  std_logic;
        rx_last    :  in  std_logic;
        rx_data    :  in  std_logic;

        tx_valid   :  out std_logic;
        tx_last    :  out std_logic;
        tx_data    :  out std_logic;

        --Transactio interface
        trans_rec  :  inout StreamRecType
    );
    -- Name for OSVVM Alerts
    constant MODEL_INSTANCE_NAME : string :=
    IfElse(MODEL_ID_NAME /= "",
    MODEL_ID_NAME, PathTail(to_lower(TLM_VC'PATH_NAME))) ;
end TLM_VC;

architecture Blocking of TLM_VC is
  signal ModelID : AlertLogIDType ;

begin

  ------------------------------------------------------------
  --  Initialize alerts
  ------------------------------------------------------------
  Initialize : process
  variable ID : AlertLogIDType ;
begin
  -- Alerts
  ID        := NewID(MODEL_INSTANCE_NAME) ;
  ModelID   <= ID ;
  wait ;
end process Initialize ;

TransactionHandler : process
  alias Operation : StreamOperationType is trans_rec.Operation;

  wait for 0 ns;

  loop
    WaitForTransaction (
      clk  =>  clk,
      rdy  =>  trans_rec.Rdy,
      ack  =>  trans_rec.Ackd
    );

    case Operation is

      when others => 
        Alert(ModelID, "Unimplemented Transaction: " & to_string(Operation), FAILURE);
        
    end case;

end Blocking;