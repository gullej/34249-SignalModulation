architecture clk_sync_test1 of test_ctrl_e is
    signal Sync1, TestDone : integer_barrier := 1;
    signal TbID : AlertLogIDType ;
    signal SB   : ScoreboardIDType;

    begin
    
        CONTROL_PROC : process
        begin
            SetTestName("sync clk test");
            SetLogEnable(PASSED, TRUE);
            TbID <= NewID("Testbench");
            SB   <= NewID("Clk_sync_tb");
    
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
                Push(SB,gray_data);
                Send(stream_tx_rec,data1);
                WaitForClock(stream_tx_rec,1);
            end loop;
    
            WaitForBarrier(TestDone);
            wait;
        end process MAGAGER_PROC_1;
    
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
    
    end clk_sync_test1;
    
    Configuration TLM_tb_clk_sync_test1 of TLM_tb is
        for testbench
          for TestCtrl_1 : test_ctrl_e
            use entity work.test_ctrl_e(clk_sync_test1); 
          end for; 
        end for; 
      end TLM_tb_clk_sync_test1; 