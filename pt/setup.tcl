source -e -v $ScrDIR/lib.tcl

if [expr {$XTALK == 0}] {
  set si_enable_analysis false
} else {
  setenv SNPSLMD_QUEUE 1
  set si_enable_analysis true
#  set si_xtalk_reselect_critical_path false
#  set si_xtalk_exit_on_max_iteration_count      2
  set si_analysis_logical_correlation_mode      true
  set si_xtalk_delay_analysis_mode              all_paths
#  set si_filter_per_aggr_noise_peak_ratio       0.01
#  set si_xtalk_reselect_clock_network           true
}

if ![file exists $RptDIR] {file mkdir $RptDIR}
if ![file exists $SessionDIR] {file mkdir $SessionDIR}
