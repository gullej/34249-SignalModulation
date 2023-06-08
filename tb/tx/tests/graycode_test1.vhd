architecture graycode_test1 of test_ctrl_e is
    signal Sync1, TestDone : integer_barrier := 1 ;
    signal TbID : AlertLogIDType ;  
    signal SB   : ScoreboardIDType;
    begin
    
        CONTROL_PROC : process
        begin
            SetTestName("continuous stream test");
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
    
        MAGAGER_PROC_1 : process
        variable Manager1Id      : AlertLogIDType;
        variable rnd             : RandomPType;
        variable data_generator  : std_logic_vector(1 DOWNTO 0);
        begin
            wait until rst = '0';  
            -- First Alignment to clock
            WaitForClock(stream_tx_rec, 1) ;
            Manager1Id := NewID("Manager", TbID) ; 
    
            for i in 1 to 480 loop
                data_generator  :=  rnd.RandSlv(2);
                Push(SB,data_generator);
                Send(stream_tx_rec,data_generator(0));
                Send(stream_tx_rec,data_generator(1));
            end loop;
    
            WaitForBarrier(TestDone);
            wait;
        end process MAGAGER_PROC_1;
    
        MAGAGER_PROC_2 : process
        variable data  : std_logic_vector(DATA_WIDTH*8-1 downto 0);
        begin
            wait until rst = '0';
    
            WaitForClock(stream_tx_rec, 1);
            for i in 1 to (480/DATA_WIDTH) loop
                Check(stream_tx_rec,data);
            end loop;
    
            WaitForBarrier(TestDone);
        end process MAGAGER_PROC_2;
    
    end graycode_test1;
    
    Configuration TLM_tb_graycode_test1 of TLM_tb is
        for testbench
          for TestCtrl_1 : test_ctrl_e
            use entity work.test_ctrl_e(graycode_test1); 
          end for; 
        end for; 
      end TLM_tb_graycode_test1; 