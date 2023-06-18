library ieee ;
  use ieee.std_logic_1164.all ;
  use ieee.numeric_std.all ;
  use ieee.numeric_std_unsigned.all ;
  use ieee.math_real.all ;

library osvvm ;
  context osvvm.OsvvmContext ;

library osvvm_common ;
  context osvvm_common.OsvvmCommonContext ;

entity top_vc is
    generic (
        MODEL_ID_NAME   : string := "" ;

        DATA_WIDTH      : integer;

        tperiod_Clk     : time := 10 ns ;
        DEFAULT_DELAY   : time := 1 ns ;

        tpd_rx_write    : time := DEFAULT_DELAY;
        tpd_rx_data     : time := DEFAULT_DELAY

    );
    port (
        clk               :  in  std_logic;
        clk_b             :  in  std_logic;
        rst               :  in  std_logic;

        rx_valid_in       :  in  std_logic;
        rx_data_in        :  in  std_logic_vector(0 DOWNTO 0);

        rx_valid_out      :  in  std_logic;
        rx_data_out       :  in  std_logic_vector(0 DOWNTO 0);

        --Transactio interface
        rx_trans_rec_in   :  inout StreamRecType;
        rx_trans_rec_out  :  inout StreamRecType
    );
    -- Name for OSVVM Alerts
    constant MODEL_INSTANCE_NAME : string :=
    IfElse(MODEL_ID_NAME /= "",
    MODEL_ID_NAME, PathTail(to_lower(top_vc'PATH_NAME))) ;
end top_vc;

architecture Blocking of top_vc is
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

TransactionHandlerIn : process
alias Operation : StreamOperationType is rx_trans_rec_in.Operation;
begin

  wait for 0 ns;

  loop
    WaitForTransaction (
      clk  =>  clk,
      rdy  =>  rx_trans_rec_in.Rdy,
      ack  =>  rx_trans_rec_in.Ack
    );

    case Operation is
       -- Execute Standard Directive Transactions
      when WAIT_FOR_TRANSACTION =>
        wait for 0 ns ; 

      when WAIT_FOR_CLOCK =>
        WaitForClock(Clk, rx_trans_rec_in.IntToModel);

      when GET_ALERTLOG_ID =>
        rx_trans_rec_in.IntFromModel <= integer(ModelID);

      when Get =>
        if rx_valid_in = '1' then
            rx_trans_rec_in.BoolFromModel  <=  TRUE;
        else
            rx_trans_rec_in.BoolFromModel  <=  FALSE;
        end if;
        rx_trans_rec_in.DataFromModel  <=  SafeResize(rx_data_in,rx_trans_rec_in.DataFromModel'length);
        WaitForClock(clk);

      when others => 
        Alert(ModelID, "Unimplemented Transaction: " & to_string(Operation), FAILURE);

    end case;
  end loop;
end process TransactionHandlerIn;

TransactionHandlerOut : process
alias Operation : StreamOperationType is rx_trans_rec_out.Operation;
begin

  wait for 0 ns;

  loop
    WaitForTransaction (
      clk  =>  clk_b,
      rdy  =>  rx_trans_rec_out.Rdy,
      ack  =>  rx_trans_rec_out.Ack
    );

    case Operation is
       -- Execute Standard Directive Transactions
      when WAIT_FOR_TRANSACTION =>
        wait for 0 ns ; 

      when WAIT_FOR_CLOCK =>
        WaitForClock(clk_b, rx_trans_rec_out.IntToModel);

      when GET_ALERTLOG_ID =>
        rx_trans_rec_out.IntFromModel <= integer(ModelID);

      when Get =>
        if rx_valid_out = '1' then
            rx_trans_rec_out.BoolFromModel  <=  TRUE;
        else
            rx_trans_rec_out.BoolFromModel  <=  FALSE;
        end if;
        rx_trans_rec_out.DataFromModel  <=  SafeResize(rx_data_out,rx_trans_rec_out.DataFromModel'length);
        WaitForClock(clk_b);

      when others => 
        Alert(ModelID, "Unimplemented Transaction: " & to_string(Operation), FAILURE);

    end case;
  end loop;
end process TransactionHandlerOut;
end architecture Blocking;