proc UnconnIn { ExcludePins } {
  set allpins [get_pins -leaf -quiet -of [get_cells -hier * -filter is_hierarchical==false]]
  foreach ePin $ExcludePins { set allpins [remove_from_collection $allpins [filter_collection $allpins lib_pin_name==$ePin]] }

  set inpins [filter_collection $allpins "pin_direction==in"]
  set outpins [filter_collection $allpins "pin_direction==out"]
  append_to_collection outpins [filter_collection $allpins "pin_direction==internal"]

  set okinpins [get_pins -quiet -leaf -of [get_nets -quiet -of $outpins] -filter "pin_direction==in"]
  set TIE0PINS [get_pins * -hier -filter "constant_value==0"]
  set TIE1PINS [get_pins * -hier -filter "constant_value==1"]
  set InputPortPins [get_pins -quiet -leaf -of [get_nets -quiet -of [all_inputs]]  -filter "pin_direction==in"]
  set unDrivenPins [remove_from_collection [remove_from_collection [remove_from_collection [remove_from_collection $inpins $okinpins] $TIE0PINS] $TIE1PINS] $InputPortPins]
  return $unDrivenPins
}


proc rsetup {} {
  global RptDIR
  report_constraints -all_violators -v -max_delay -recovery -nosplit > $RptDIR/setup.verbose.rpt
  report_constraints -all_violators -max_delay -recovery -nosplit > $RptDIR/setup.brief.rpt
}

proc rhold {} {
  global RptDIR
  report_constraints -min_delay -all_violators -v -max_delay -recovery -nosplit > $RptDIR/setup.verbose.rpt
  report_constraints -min_delay -all_violators -max_delay -recovery -nosplit > $RptDIR/setup.brief.rpt
}

report_constraints -all_violators -max_transition -nosplit > $RptDIR/tran.brief.rpt
report_constraints -all_violators -v -max_delay -recovery -nosplit > $RptDIR/setup.verbose.rpt
report_constraints -all_violators -max_delay -recovery -nosplit > $RptDIR/setup.brief.rpt
report_constraints -all_violators -v -min_delay -removal -nosplit > $RptDIR/hold.verbose.rpt
report_constraints -all_violators -min_delay -removal -nosplit > $RptDIR/hold.brief.rpt

#report_qor > $RptDIR/qor.rpt
report_global_timing > $RptDIR/global_timing.rpt
report_clock_timing -type summary > $RptDIR/clock.summary.rpt
#foreach_in_collection iClock [get_clocks * -filter "is_generated==false && full_name !~ IO_* && full_name !~ DRO*" ] { report_clock_timing -nosplit -type latency -clock $iClock >> $RptDIR/Clock.Latency.rpt }


#source /proj/cadpnr/pds/tools/pt/clock/pdReportClockTran_pt.tcl
#if { ${M9} != 1} {
#  pdReportClockTran -of_lib tcbn16ffcllbwp7d5t16p96cpdlvt${LIB}_ccs -clockBuf CTS_*_BUF -clockInv CTS_*_INV > $RptDIR/clk.tran.rpt
#
#} else {
#  pdReportClockTran -of_lib m9szd_clklib_${LIB}_ccstn -clockBuf scbuf -clockInv sciv > $RptDIR/clk.tran.rpt
#}
#
#sh mv pdClockTran.tran                  $RptDIR/.
#sh mv pdClockTran_noneClkBufList.rpt    $RptDIR/.
#sh mv pdClockTran_pseudoClkTrace.rpt    $RptDIR/.
#sh mv pdClockTran_violationSummary.rpt  $RptDIR/.
#sh mv pdClockTran_vioNetDriver.rpt      $RptDIR/.
################################################################################################
#set power_enable_analysis TRUE
#set power_analysis_mode averaged
#define_user_attribute -type string -class lib default_threshold_voltage_group
#set_user_attribute [get_libs tcbn16ffcllbwp7d5t*p96cpd${LIB}]		default_threshold_voltage_group 7D_SVT
#set_user_attribute [get_libs tcbn16ffcllbwp7d5t*p96cpdlvt${LIB}]  	default_threshold_voltage_group 7D_LVT
#set_user_attribute [get_libs tcbn16ffcllbwp7d5t*p96cpdulvt${LIB}]       default_threshold_voltage_group 7D_ULVT
#set_user_attribute [get_libs tcbn16ffcllbwp7d5t*p96cpdmb${LIB}]		default_threshold_voltage_group 7D_MBSVT
#set_user_attribute [get_libs tcbn16ffcllbwp7d5t*p96cpdmblvt${LIB}]	default_threshold_voltage_group 7D_MBLVT
#set_user_attribute [get_libs tcbn16ffcllbwp7d5t*p96cpdmbulvt${LIB}]	default_threshold_voltage_group 7D_MBULVT
#set_user_attribute [get_libs tcbn16ffcllbwp7d5t*p96cpdpm${LIB}]		default_threshold_voltage_group 7D_PMSVT
#set_user_attribute [get_libs tcbn16ffcllbwp7d5t*p96cpdpmlvt${LIB}]	default_threshold_voltage_group 7D_PMLVT
#set_user_attribute [get_libs tcbn16ffcllbwp7d5t*p96cpdpmulvt${LIB}]	default_threshold_voltage_group 7D_PMULVT
#report_threshold_voltage_group >> $RptDIR/pwr.cell.percentage.rpt

################################################################################################
#report_cell_usage -pattern_priority { hzd szd snd lzd **logic} >> $RptDIR/cell.usage.rpt
#mrvl_report_shorted_output_pins -output $RptDIR/mrvl_short_output.rpt
#mrvl_report_unconnected_input_pins -leaf_only -output $RptDIR/mrvl_open_input.rpt
#set UnIn [UnconnIn ""]
#foreach_in_collection iPin $UnIn { echo [get_attribute $iPin full_name] >> $RptDIR/mrvl_open_input.rpt }
################################################################################################
#set power_enable_analysis TRUE
#set power_analysis_mode averaged
#set power_default_toggle_rate 0.1
#check_power -verbose
#update_power
#report_power >> $RptDIR/PTPX.rpt
################################################################################################
