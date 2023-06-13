architecture clk_sync_test1 of test_ctrl_e is
  function Graycode( f_input : in std_logic_vector(1 DOWNTO 0)) return std_logic_vector is
    begin
      if f_input = "00" then
          return "101";
      elsif f_input = "01" then
          return "111";
      elsif f_input = "11" then
          return "001";
      elsif f_input = "10" then
          return "011";
      end if;
    end function Graycode;

    signal Sync1, TestDone : integer_barrier := 1;
    signal TbID : AlertLogIDType ;
    signal graycode_SB   : ScoreboardIDType;
    signal clk_sync_SB   : ScoreboardIDType;
    signal Cov           : CoverageIDType;

    constant Num_of_Tests : integer := 480;

    begin
    
        CONTROL_PROC : process
        begin
            SetTestName("sync clk test");
            SetLogEnable(PASSED, TRUE);
            TbID <= NewID("Testbench");
            graycode_SB   <= NewID("GrayCode_SB");
            clk_sync_SB   <= NewID("Clk_sync_SB");
            Cov  <= NewID("Clk_sync_Cov");
    
            wait for 0 ns ;  wait for 0 ns;
            TranscriptOpen("ClkSync_Test1.txt") ;
            SetTranscriptMirror(TRUE);

            AddBins(Cov, GenBin(2097152, 2097152));
            AddBins(Cov, GenBin(6291456, 6291456));
            AddBins(Cov, GenBin(10485760, 10485760));
            AddBins(Cov, GenBin(14680064, 14680064));
            AddBins(Cov, 0, GenBin(0, 16777215, 1));
    
            wait until rst = '0';
            ClearAlerts;
    
            WaitForBarrier(TestDone, 35 ms);
            AlertIf(now >= 35 ms, "Test finished due to timeout");

            TranscriptClose;

            WriteBin(Cov);
            EndOfTestReports;
            std.env.stop(GetAlertCount);
            wait;
        end process;

        -----------------------------
        -- GrayCode data Generator --
        -----------------------------
        GC_Generate_Data : process
        variable Manager1Id      : AlertLogIDType;
        variable rnd             : RandomPType;
        variable data_generator  : std_logic_vector(1 DOWNTO 0);
        variable data0           : std_logic_vector(0 DOWNTO 0);
        variable data1           : std_logic_vector(0 DOWNTO 0);
        variable gray_data       : std_logic_vector(2 DOWNTO 0);
        --variable push_cnt        : integer;
        begin
            wait until rst = '0';  
            -- First Alignment to clock
            WaitForClock(stream_tx_rec, 1) ;
            Manager1Id := NewID("Manager", TbID) ; 
    
            for i in 1 to Num_of_Tests loop
                data_generator  :=  rnd.RandSlv(2);
                data0  :=  data_generator(0 DOWNTO 0);
                data1  :=  data_generator(1 DOWNTO 1);
                gray_data  :=  Graycode(data_generator);
                --push_cnt  :=  GetPushCount(graycode_SB);
                --log("Num of Pushs: " & to_string(push_cnt));
                Push(graycode_SB,gray_data);
                Send(stream_tx_rec,data1);
                Send(stream_tx_rec,data0);
            end loop;
    
            WaitForBarrier(TestDone);
            wait;
        end process GC_Generate_Data;

        -----------------------------
        -- GrayCode verify data    --
        -----------------------------
        GC_Check_PROC : process
        variable data       : std_logic_vector(2 downto 0);
        variable CheckID    : AlertLogIDType;
        --variable check_cnt  :  integer;
        begin
            wait until rst = '0';
            WaitForClock(stream_rx_rec, 1);
            CheckID := NewID("Check", TbID);
            --WaitForBarrier();
            while(GetCheckCount(graycode_SB) < Num_of_Tests) loop
                Get(stream_rx_rec,data);
                --check_cnt  :=  GetCheckCount(graycode_SB);
                --log("Num of Chekcs: " & to_string(check_cnt));
                if stream_rx_rec.BoolFromModel = TRUE then
                  Check(graycode_SB,data);
                end if;
            end loop;
    
            WaitForBarrier(TestDone);
            wait;
        end process GC_Check_PROC;

        ----------------------------
        -- Clock Sync get data    --
        ----------------------------
        Get_input_PROC : process
        variable GetID      : AlertLogIDType;
        variable rnd             : RandomPType;
        variable data_generator  : std_logic_vector(DATA_WIDTH - 1 DOWNTO 0);
        variable expected_data   : std_logic_vector(8 * DATA_WIDTH - 1 DOWNTO 0);
        begin
            wait until rst = '0';  
            -- First Alignment to clock
            WaitForClock(sync_tx_rec, 1) ;
            GetID := NewID("Manager", TbID) ; 
    
            while(GetPushCount(clk_sync_SB) < Num_of_Tests) loop
                Get(sync_tx_rec,data_generator);
                expected_data  :=  data_generator & (7 * DATA_WIDTH - 1 DOWNTO 0 => '0');
                --log("Num of Pushs: " & to_string(GetPushCount(clk_sync_SB)));
                if sync_tx_rec.BoolFromModel = TRUE then
                  Push(clk_sync_SB,expected_data);
                end if;
                WaitForClock(sync_tx_rec,1);
            end loop;
    
            WaitForBarrier(TestDone);
            wait;
        end process Get_input_PROC;

        ----------------------------
        -- Clock Sync verify data --
        ----------------------------
        Check_PROC : process
        variable data  : std_logic_vector(8 * DATA_WIDTH - 1 downto 0);
        variable CheckID      : AlertLogIDType;
        begin
            wait until rst = '0';
            WaitForClock(sync_rx_rec, 1);
            CheckID := NewID("Check", TbID) ; 

            while(GetCheckCount(clk_sync_SB) < Num_of_Tests) loop
                Get(sync_rx_rec,data);
                --log("Num of Checks: " & to_string(GetCheckCount(clk_sync_SB)));
                if sync_rx_rec.BoolFromModel = TRUE then
                  ICover(Cov, to_integer(unsigned(data)));
                  Check(clk_sync_SB,data);
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