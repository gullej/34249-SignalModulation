library ieee ;
  use ieee.std_logic_1164.all ;
  use ieee.numeric_std.all ;
  use ieee.numeric_std_unsigned.all ;
  use ieee.math_real.all ;

library osvvm ;
  context osvvm.OsvvmContext ;

library osvvm_common ;
  context osvvm_common.OsvvmCommonContext ;

entity pulseshaper_rx_vc is
    generic (
        MODEL_ID_NAME   : string := "" ;

        DATA_WIDTH      : integer := 2;

        tperiod_Clk     : time := 10 ns ;
        DEFAULT_DELAY   : time := 1 ns ;

        tpd_rx_write    : time := DEFAULT_DELAY;
        tpd_rx_data     : time := DEFAULT_DELAY

    );
    port (
        clk             :  in  std_logic;
        rst             :  in  std_logic;

        rx_valid        :  in  std_logic;
        rx_data         :  in  std_logic_vector(13 DOWNTO 0);

        tx_valid        :  out std_logic;
        tx_data         :  out std_logic_vector(8 * DATA_WIDTH - 1 DOWNTO 0);

        -- Input Transactio interface
        rx_trans_rec    :  inout StreamRecType;
        -- Output Transactio interface
        tx_trans_rec    :  inout StreamRecType
    );
    -- Name for OSVVM Alerts
    constant MODEL_INSTANCE_NAME : string :=
    IfElse(MODEL_ID_NAME /= "",
    MODEL_ID_NAME, PathTail(to_lower(pulseshaper_rx_vc'PATH_NAME))) ;
end pulseshaper_rx_vc;

architecture Blocking of pulseshaper_rx_vc is
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

--------------------------------------------
-- Transaction Handler for getting Data   --
--------------------------------------------
TransactionHandler_Input : process
alias Operation : StreamOperationType is rx_trans_rec.Operation;
begin

  wait for 0 ns;

  loop
    WaitForTransaction (
      clk  =>  clk,
      rdy  =>  rx_trans_rec.Rdy,
      ack  =>  rx_trans_rec.Ack
    );

    case Operation is
       -- Execute Standard Directive Transactions
      when WAIT_FOR_TRANSACTION =>
        wait for 0 ns ; 

      when WAIT_FOR_CLOCK =>
        WaitForClock(Clk, rx_trans_rec.IntToModel);

      when GET_ALERTLOG_ID =>
        rx_trans_rec.IntFromModel <= integer(ModelID);

      when Get =>
        if rx_valid = '1' then
            rx_trans_rec.BoolFromModel  <=  TRUE;
        else
            rx_trans_rec.BoolFromModel  <=  FALSE;
        end if;
        rx_trans_rec.DataFromModel  <=  SafeResize(rx_data,rx_trans_rec.DataFromModel'length);

        WaitForClock(clk);

      when others => 
        Alert(ModelID, "Unimplemented Transaction: " & to_string(Operation), FAILURE);

    end case;
  end loop;
end process TransactionHandler_Input;


------------------------------------------
-- Transaction Handler for sending Data --
------------------------------------------
TransactionHandler_Output : process
alias Operation : StreamOperationType is tx_trans_rec.Operation;
begin

  wait for 0 ns;

  loop
    WaitForTransaction (
      clk  =>  clk,
      rdy  =>  tx_trans_rec.Rdy,
      ack  =>  tx_trans_rec.Ack
    );

    case Operation is
       -- Execute Standard Directive Transactions
      when WAIT_FOR_TRANSACTION =>
        wait for 0 ns ; 

      when WAIT_FOR_CLOCK =>
        WaitForClock(Clk, tx_trans_rec.IntToModel);

      when GET_ALERTLOG_ID =>
        tx_trans_rec.IntFromModel <= integer(ModelID);

      when SEND =>
        tx_valid  <=  '1';
        tx_data   <=  SafeResize(tx_trans_rec.DataToModel, tx_data'length);

        WaitForClock(clk);

      when others => 
        Alert(ModelID, "Unimplemented Transaction: " & to_string(Operation), FAILURE);

    end case;
  end loop;
end process TransactionHandler_Output;
end architecture Blocking;