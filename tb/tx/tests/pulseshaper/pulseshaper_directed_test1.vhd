architecture pulseshaper_directed_test1 of test_ctrl_e is
      signal Sync1     :  integer_barrier := 1;
      signal TestDone  :  integer_barrier := 1;
      signal TbID      : AlertLogIDType ;
      signal SB        : ScoreboardIDType;
      signal Cov       : CoverageIDType;

      type tx_arr_t is array (0 to 50) of std_logic_vector(8 * DATA_WIDTH - 1 DOWNTO 0);
      signal tx_data_array  :  tx_arr_t :=(
        0  => "111000000000000000000000",
        1  => "011000000000000000000000",
        2  => "001000000000000000000000",
        3  => "001000000000000000000000",
        4  => "101000000000000000000000",
        5  => "101000000000000000000000",
        6  => "101000000000000000000000",
        7  => "011000000000000000000000",
        8  => "001000000000000000000000",
        9  => "001000000000000000000000",
        10 => "101000000000000000000000",
        11 => "011000000000000000000000",
        12 => "011000000000000000000000",
        13 => "101000000000000000000000",
        14 => "101000000000000000000000",
        15 => "101000000000000000000000",
        16 => "111000000000000000000000",
        17 => "001000000000000000000000",
        18 => "111000000000000000000000",
        19 => "111000000000000000000000",
        20 => "001000000000000000000000",
        21 => "101000000000000000000000",
        22 => "111000000000000000000000",
        23 => "111000000000000000000000",
        24 => "111000000000000000000000",
        25 => "011000000000000000000000",
        26 => "101000000000000000000000",
        27 => "001000000000000000000000",
        28 => "001000000000000000000000",
        29 => "101000000000000000000000",
        30 => "001000000000000000000000",
        31 => "101000000000000000000000",
        32 => "101000000000000000000000",
        33 => "011000000000000000000000",
        34 => "011000000000000000000000",
        35 => "011000000000000000000000",
        36 => "111000000000000000000000",
        37 => "101000000000000000000000",
        38 => "001000000000000000000000",
        39 => "111000000000000000000000",
        40 => "101000000000000000000000",
        41 => "111000000000000000000000",
        42 => "101000000000000000000000",
        43 => "011000000000000000000000",
        44 => "111000000000000000000000",
        45 => "001000000000000000000000",
        46 => "111000000000000000000000",
        47 => "001000000000000000000000",
        48 => "001000000000000000000000",
        49 => "101000000000000000000000",
        50 => "000000000000000000000000"
      );
  
      constant Num_of_Tests : integer := 480;
  
      begin
      
        CONTROL_PROC : process
        begin
            SetTestName("Pulseshaper directed test");
            SetLogEnable(PASSED, TRUE);
            TbID <= NewID("Testbench");
            SB   <= NewID("PulseShaper_directed_SB");
            Cov  <= NewID("PulseShaper_directed_Cov");
    
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

        --------------------------------
        -- Pulsehsaper data Generator --
        --------------------------------
        Transmit_PROC : process
        variable TransID  :  AlertLogIDType;
        variable idx      :  integer;
        begin
            wait until rst = '0';

            WaitForClock(pulse_tx_rec,1);
            idx  :=  0;
            TransID  :=  NewID("Transmiter_Pulseshaper");

            while (idx < 51) loop
                Send(pulse_tx_rec, tx_data_array(idx));
                if pulse_tx_rec.BoolFromModel = TRUE then
                    idx := idx + 1;
                end if;
            end loop;

            WaitForBarrier(TestDone);
            wait;
        end process Transmit_PROC;
  
        Cov_PROC : process
        variable CovId  :  AlertLogIDType;
        variable data   :  std_logic_vector(13 DOWNTO 0);
        variable idx    :  integer;
        begin
            wait until rst = '0';
            WaitForClock(pulse_rx_rec, 1);
            idx  :=  0;
            CovId  :=  NewID("PS_Directed_Covrage_test", TbID);

            while (idx < 800) loop
                Get(pulse_rx_rec,data);
                if pulse_rx_rec.BoolFromModel = TRUE then
                    ICover(Cov,to_integer(data));
                    idx  :=  idx + 1;
                end if;
            end loop;
            
            WaitForBarrier(TestDone);
            wait;
        end process Cov_PROC;
  
      
      end pulseshaper_directed_test1;
      
      Configuration TLM_tb_pulseshaper_directed_test1 of TLM_tb is
          for testbench
            for TestCtrl_1 : test_ctrl_e
              use entity work.test_ctrl_e(pulseshaper_directed_test1); 
            end for; 
          end for; 
        end TLM_tb_pulseshaper_directed_test1; 