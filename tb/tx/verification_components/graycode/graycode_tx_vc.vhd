library ieee ;
  use ieee.std_logic_1164.all ;
  use ieee.numeric_std.all ;
  use ieee.numeric_std_unsigned.all ;
  use ieee.math_real.all ;

library osvvm ;
  context osvvm.OsvvmContext ;

library osvvm_common ;
  context osvvm_common.OsvvmCommonContext ;

entity graycode_tx_vc is
    generic (
        MODEL_ID_NAME   : string := "" ;

        DATA_WIDTH      : integer := 2;

        tperiod_Clk     : time := 10 ns ;
        DEFAULT_DELAY   : time := 1 ns ;

        tpd_tx_valid    : time := DEFAULT_DELAY;
        tpd_tx_last     : time := DEFAULT_DELAY;
        tpd_tx_data     : time := DEFAULT_DELAY
    );
    port (
        clk             :  in  std_logic;
        rst             :  in  std_logic;

        tx_valid        :  out std_logic;
        tx_last         :  out std_logic;
        tx_data         :  out std_logic_vector(0 DOWNTO 0);

        --Transactio interface
        trans_rec       :  inout StreamRecType
    );
    -- Name for OSVVM Alerts
    constant MODEL_INSTANCE_NAME : string :=
    IfElse(MODEL_ID_NAME /= "",
    MODEL_ID_NAME, PathTail(to_lower(graycode_tx_vc'PATH_NAME))) ;
end graycode_tx_vc;

architecture Blocking of graycode_tx_vc is
  signal ModelID : AlertLogIDType ;

begin

  ------------------------------------------------------------
  --  Initialize alerts
  ------------------------------------------------------------
  Initialize : process
  variable ID : AlertLogIDType;
begin
  -- Alerts
  ID        := NewID(MODEL_INSTANCE_NAME);
  ModelID   <= ID;
  wait ;
end process Initialize ;

TransactionHandler : process
alias Operation : StreamOperationType is trans_rec.Operation;
begin
  tx_valid  <=  'X';
  tx_last   <=  'X';
  tx_data   <=  (tx_data'range => 'X');
  wait for 0 ns;

  loop
    WaitForTransaction (
      clk  =>  clk,
      rdy  =>  trans_rec.Rdy,
      ack  =>  trans_rec.Ack
    );

    tx_valid  <=  '0';
    case Operation is
       -- Execute Standard Directive Transactions
      when WAIT_FOR_TRANSACTION =>
        wait for 0 ns ; 

      when WAIT_FOR_CLOCK =>
        WaitForClock(Clk, trans_rec.IntToModel) ;

      when GET_ALERTLOG_ID =>
        trans_rec.IntFromModel <= integer(ModelID) ;

      when SEND =>
        tx_valid  <=  '1';
        tx_last   <=  '0';
        tx_data   <=  SafeResize(trans_rec.DataToModel, tx_data'length);

        WaitForClock(clk);

      when others => 
        Alert(ModelID, "Unimplemented Transaction: " & to_string(Operation), FAILURE);

    end case;
  end loop;
end process TransactionHandler;
end architecture Blocking;