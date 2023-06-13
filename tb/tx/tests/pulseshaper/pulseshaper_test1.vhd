architecture pulseshaper_test1 of test_ctrl_e is
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

    signal Sync1     :  integer_barrier := 1;
    signal TestDone  :  integer_barrier := 1;
    signal TbID      : AlertLogIDType ;
    signal SB        : ScoreboardIDType;
    signal Cov       : CoverageIDType;

    constant Num_of_Tests : integer := 480;

    begin
    
        CONTROL_PROC : process
        begin
            SetTestName("sync clk test");
            SetLogEnable(PASSED, TRUE);
            TbID <= NewID("Testbench");
            SB   <= NewID("PulseShaper_SB");
            Cov  <= NewID("PulseShaper_Cov");
    
            wait for 0 ns ;  wait for 0 ns;
    
            AddBins(Cov, GenBin(0,16383));

            wait until rst = '0';
            ClearAlerts;
    
            WaitForBarrier(TestDone, 35 ms);
            AlertIf(now >= 35 ms, "Test finished due to timeout");
    
            EndOfTestReports;
            WriteBin(Cov);
            std.env.stop(GetAlertCount);
            wait;
        end process;

        -----------------------------
        -- GrayCode data Generator --
        -----------------------------
        GC_Generate_Data : process
        variable GenId           : AlertLogIDType;
        variable rnd             : RandomPType;
        variable data_generator  : std_logic_vector(1 DOWNTO 0);
        variable data0           : std_logic_vector(0 DOWNTO 0);
        variable data1           : std_logic_vector(0 DOWNTO 0);
        variable gray_data       : std_logic_vector(1 DOWNTO 0);
        begin
            wait until rst = '0';  
            -- First Alignment to clock
            WaitForClock(stream_tx_rec, 1);
            GenId := NewID("Manager", TbID);
    
            while (not(IsCovered(Cov))) loop
                data_generator  :=  to_slv(GetRandPoint(Cov),data_generator'length);
                data0           :=  data_generator(0 DOWNTO 0);
                data1           :=  data_generator(1 DOWNTO 1);
                gray_data       :=  Graycode(data_generator); 
                --Push(graycode_SB,gray_data);
                Send(stream_tx_rec,data1);
                Send(stream_tx_rec,data0);
            end loop;
    
            WaitForBarrier(TestDone);
            wait;
        end process GC_Generate_Data;

        Cov_PROC : process
        variable CovId  :  AlertLogIDType;
        variable data   :  std_logic_vector(13 DOWNTO 0);
        begin
            wait until rst = '0';
            WaitForClock(pulse_rx_rec, 1);
            CovId  :=  NewID("Covrage_test", TbID);

            while (not(IsCovered(Cov))) loop
                Get(pulse_rx_rec,data);
                if pulse_rx_rec.BoolFromModel = TRUE then
                    ICover(Cov,to_integer(data));
                end if;
            end loop;
            
            WaitForBarrier(TestDone);
            wait;
        end process Cov_PROC;

    
    end pulseshaper_test1;
    
    Configuration TLM_tb_pulseshaper_test1 of TLM_tb is
        for testbench
          for TestCtrl_1 : test_ctrl_e
            use entity work.test_ctrl_e(pulseshaper_test1); 
          end for; 
        end for; 
      end TLM_tb_pulseshaper_test1; 