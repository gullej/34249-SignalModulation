library ieee ;
  use ieee.std_logic_1164.all ;
  use ieee.numeric_std.all ;
  use ieee.numeric_std_unsigned.all ;
  use ieee.math_real.all ;

library osvvm ;
  context osvvm.OsvvmContext ;

library osvvm_common ;
  context osvvm_common.OsvvmCommonContext ;

entity clk_sync_rx_vc is
    generic (
        MODEL_ID_NAME     : string := "" ;

        DATA_WIDTH        : integer;

        tperiod_Clk       : time := 10 ns ;
        DEFAULT_DELAY     : time := 1 ns ;

        tpd_rx_write      : time := DEFAULT_DELAY;
        tpd_rx_data       : time := DEFAULT_DELAY

    );
    port (
        clk_rd            :  in  STD_LOGIC;
        clk_wr            :  IN  STD_LOGIC;
        rst               :  in  STD_LOGIC;

        
        rx_dat_in         :  IN  STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
        rx_rd_in          :  IN  STD_LOGIC;
        rx_wr_in          :  IN  STD_LOGIC;
        --
        rx_dat_out	      :  IN  STD_LOGIC_VECTOR(8 * DATA_WIDTH - 1 DOWNTO 0);
        rx_empty_out      :  IN  STD_LOGIC;
        rx_full_out       :  IN  STD_LOGIC;
        
        

        --Transactio interface
        rx_trans_rec_in   :  inout StreamRecType;
        rx_trans_rec_out  :  inout StreamRecType
    );
    -- Name for OSVVM Alerts
    constant MODEL_INSTANCE_NAME : string :=
    IfElse(MODEL_ID_NAME /= "",
    MODEL_ID_NAME, PathTail(to_lower(clk_sync_rx_vc'PATH_NAME))) ;
end clk_sync_rx_vc;

architecture Blocking of clk_sync_rx_vc is
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

TransactionHandler_input : process
alias Operation : StreamOperationType is rx_trans_rec_in.Operation;
begin

  wait for 0 ns;

  loop
    WaitForTransaction (
      clk  =>  clk_wr,
      rdy  =>  rx_trans_rec_in.Rdy,
      ack  =>  rx_trans_rec_in.Ack
    );

    case Operation is
       -- Execute Standard Directive Transactions
      when WAIT_FOR_TRANSACTION =>
        wait for 0 ns ; 

      when WAIT_FOR_CLOCK =>
        WaitForClock(clk_wr, rx_trans_rec_in.IntToModel);

      when GET_ALERTLOG_ID =>
        rx_trans_rec_in.IntFromModel <= integer(ModelID);

      when GET =>
        if rx_wr_in = '1' then
          rx_trans_rec_in.BoolFromModel  <=  TRUE;
        else
          rx_trans_rec_in.BoolFromModel  <=  FALSE;
        end if;
        rx_trans_rec_in.DataFromModel  <=  SafeResize(rx_dat_in,rx_trans_rec_in.DataFromModel'length);

        WaitForClock(clk_wr);

      when others => 
        Alert(ModelID, "Unimplemented Transaction: " & to_string(Operation), FAILURE);

    end case;
  end loop;
end process TransactionHandler_input;

TransactionHandler_output : process
alias Operation : StreamOperationType is rx_trans_rec_out.Operation;
begin

  wait for 0 ns;

  loop
    WaitForTransaction (
      clk  =>  clk_rd,
      rdy  =>  rx_trans_rec_out.Rdy,
      ack  =>  rx_trans_rec_out.Ack
    );

    case Operation is
       -- Execute Standard Directive Transactions
      when WAIT_FOR_TRANSACTION =>
        wait for 0 ns ; 

      when WAIT_FOR_CLOCK =>
        WaitForClock(clk_rd, rx_trans_rec_out.IntToModel);

      when GET_ALERTLOG_ID =>
        rx_trans_rec_out.IntFromModel <= integer(ModelID);

      when GET =>
        if rx_rd_in = '1' then
          rx_trans_rec_out.BoolFromModel  <=  TRUE;
        else
          rx_trans_rec_out.BoolFromModel  <=  FALSE;
        end if;
        WaitForClock(clk_rd);
        rx_trans_rec_out.DataFromModel  <=  SafeResize(rx_dat_out,rx_trans_rec_out.DataFromModel'length);


      when others => 
        Alert(ModelID, "Unimplemented Transaction: " & to_string(Operation), FAILURE);

    end case;
  end loop;
end process TransactionHandler_output;
end architecture Blocking;