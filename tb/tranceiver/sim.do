quit -sim

vlib tranceiver_lib

vcom -work tranceiver_lib -2008 ../tb/tranceiver/common/tranceiver_component_pkg.vhd
vcom -work tranceiver_lib -2008 ../tb/tranceiver/common/transceiver_context.vhd

project new ./ Tranceiver

project addfile ../src/tranceiver/PBRS.vhd
project addfile ../src/tranceiver/pam_map.vhd
project addfile ../src/tranceiver/clk_sync.vhd
project addfile ../src/tranceiver/pulse_shaper.vhd
project addfile ../src/tranceiver/tranceiver_top.vhd

project addfile ../src/receiver/clk_recovery.vhd
project addfile ../src/receiver/downsample.vhd
project addfile ../src/receiver/match_filter.vhd
project addfile ../src/receiver/hard_decision.vhd
project addfile ../src/receiver/dual_port_ram.vhd
project addfile ../src/receiver/receiver_top.vhd

project addfile ../tb/test_ctrl_e.vhd
project addfile ../tb/tranceiver/verification_components/clk_sync/clk_sync_rx_vc.vhd
project addfile ../tb/tranceiver/verification_components/graycode/graycode_rx_vc.vhd
project addfile ../tb/tranceiver/verification_components/graycode/graycode_tx_vc.vhd
project addfile ../tb/tranceiver/verification_components/pulseshaper/pulseshaper_rx_vc.vhd

project addfile ../tb/receiver/verification_components/pulse2out/pulse2out_rx_vc.vhd

project addfile ../tb/TLM_tb.vhd
project addfile ../tb/tranceiver/tests/clk_sync/clk_sync_test1.vhd
project addfile ../tb/tranceiver/tests/graycode/graycode_test1.vhd
project addfile ../tb/tranceiver/tests/pulseshaper/pulseshaper_directed_test1.vhd
project addfile ../tb/tranceiver/tests/pulseshaper/pulseshaper_test1.vhd
project addfile ../tb/tranceiver/TLM/tranceiver_tlm.vhd
project addfile ../tb/tranceiver/TLM/pam_map_tlm.vhd