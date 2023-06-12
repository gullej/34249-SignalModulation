architecture graycode_test1 of test_ctrl_e is
    function Graycode( f_input : in std_logic_vector(1 DOWNTO 0)) return std_logic_vector is
    begin
      if f_input = "00" then
          return "00";
      elsif f_input = "01" then
          return "01";
      elsif f_input = "10" then
          return "11";
      elsif f_input = "11" then
          return "10";
      end if;
    end function Graycode;

    signal Sync1, TestDone : integer_barrier := 1 ;
    signal TbID : AlertLogIDType ;  
    signal SB   : ScoreboardIDType;

    signal dbg : std_logic := '0';
    begin
    
        CONTROL_PROC : process
        begin
            SetTestName("Gray code test");
            SetLogEnable(PASSED, TRUE);
            TbID <= NewID("Testbench");
            SB   <= NewID("Graycode_SB");
    
            wait for 0 ns ;  wait for 0 ns;
    
            wait until rst = '0';
            ClearAlerts;
    
            WaitForBarrier(TestDone, 35 ms);
            AlertIf(now >= 35 ms, "Test finished due to timeout");
    
            EndOfTestReports; 
            std.env.stop(GetAlertCount);
            wait;
        end process;
    
        GC_Generate_Data : process
        variable Manager1Id      : AlertLogIDType;
        variable rnd             : RandomPType;
        variable data_generator  : std_logic_vector(1 DOWNTO 0);
        variable data0           : std_logic_vector(0 DOWNTO 0);
        variable data1           : std_logic_vector(0 DOWNTO 0);
        variable gray_data       : std_logic_vector(1 DOWNTO 0);
        begin
            wait until rst = '0';  
            -- First Alignment to clock
            WaitForClock(stream_tx_rec, 1) ;
            Manager1Id := NewID("Manager", TbID) ; 
    
            for i in 1 to 480 loop
                data_generator  :=  rnd.RandSlv(2);
                data0  :=  data_generator(0 DOWNTO 0);
                data1  :=  data_generator(1 DOWNTO 1);
                gray_data  :=  Graycode(data_generator); 
                dbg  <=  not dbg;
                Push(SB,gray_data);
                Send(stream_tx_rec,data1);
                Send(stream_tx_rec,data0);
            end loop;
    
            WaitForBarrier(TestDone);
            wait;
        end process GC_Generate_Data;
    
        Check_PROC : process
        variable data  : std_logic_vector(1 downto 0);
        variable CheckID      : AlertLogIDType;
        begin
            wait until rst = '0';
            WaitForClock(stream_rx_rec, 1);
            CheckID := NewID("Check", TbID) ; 

            while(TRUE) loop
                Get(stream_rx_rec,data);
                if stream_rx_rec.BoolFromModel = TRUE then
                  Check(SB,data);
                end if;
            end loop;
    
            WaitForBarrier(TestDone);
            wait;
        end process Check_PROC;
    
    end graycode_test1;
    
    Configuration TLM_tb_graycode_test1 of TLM_tb is
        for testbench
          for TestCtrl_1 : test_ctrl_e
            use entity work.test_ctrl_e(graycode_test1); 
          end for; 
        end for; 
      end TLM_tb_graycode_test1; 