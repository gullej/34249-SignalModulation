architecture top_test1 of test_ctrl_e is
    signal Sync1, TestDone : integer_barrier := 1;
    signal TbID : AlertLogIDType ;
    signal SB   : ScoreboardIDType;

    constant Num_of_Tests : integer := 480;

    begin
    
        CONTROL_PROC : process
        begin
            SetTestName("Top test");
            SetLogEnable(PASSED, TRUE);
            TbID <= NewID("Testbench");
            SB   <= NewID("Top_SB");
    
            wait for 0 ns ;  wait for 0 ns;
            TranscriptOpen("top_test1.txt") ;
            SetTranscriptMirror(TRUE);
    
            wait until rst = '0';
            ClearAlerts;
    
            WaitForBarrier(TestDone, 35 ms);
            AlertIf(now >= 35 ms, "Test finished due to timeout");

            TranscriptClose;

            EndOfTestReports;
            std.env.stop(GetAlertCount);
            wait;
        end process;

        ----------------------------
        -- Clock Sync get data    --
        ----------------------------
        Get_input_PROC : process
        variable PushID  : AlertLogIDType;
        variable rnd    : RandomPType;
        variable data   : std_logic_vector(0 DOWNTO 0);
        begin
            wait until rst = '0';  
            WaitForClock(rx_trans_rec_in, 1) ;
            PushID := NewID("Push", TbID) ; 
    
            while(GetPushCount(SB) < Num_of_Tests) loop
                Get(rx_trans_rec_in,data);
                --log("Num of Pushs: " & to_string(GetPushCount(clk_sync_SB)));
                if rx_trans_rec_in.BoolFromModel = TRUE then
                  Push(SB,data);
                end if;
                WaitForClock(rx_trans_rec_in,1);
            end loop;
    
            WaitForBarrier(TestDone);
            wait;
        end process Get_input_PROC;

        -----------------------------
        -- Top verify data    --
        -----------------------------
        GC_Check_PROC : process
        variable data       : std_logic_vector(0 downto 0);
        variable CheckID    : AlertLogIDType;
        --variable check_cnt  :  integer;
        begin
            wait until rst = '0';
            WaitForClock(rx_trans_rec_out, 1);
            CheckID := NewID("Check", TbID);

            while(GetCheckCount(SB) < Num_of_Tests) loop
                Get(rx_trans_rec_out,data);
                --check_cnt  :=  GetCheckCount(graycode_SB);
                --log("Num of Chekcs: " & to_string(check_cnt));
                if rx_trans_rec_out.BoolFromModel = TRUE then
                  Check(SB,data);
                end if;
            end loop;
    
            WaitForBarrier(TestDone);
            wait;
        end process GC_Check_PROC;
    
    end top_test1;
    
    Configuration TLM_tb_top_test1 of TLM_tb is
        for testbench
          for TestCtrl_1 : test_ctrl_e
            use entity work.test_ctrl_e(top_test1); 
          end for; 
        end for; 
      end TLM_tb_top_test1; 