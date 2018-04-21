################################################################################
# Slow: 0.72V, 0C & 125C
# TYP: 0.80V, 25C & 85C
# Fast: 0.88V, -40C & 125C & 0C
# LIB Value: ffgnp0p88v125c ffgnp0p88v0c ffgnp0p88vm40c ssgnp0p72v0c ssgnp0p72v125c tt0p8v25c tt0p8v85c

######## Search Path ###################
set search_path [list $LIBSET/db $LIBSET/db/$LIB /proj/elnath1/wa/$USER/scr/pt .]

######## Link Library ###################
#foreach iLIB [ls $LIBSET/db/*${LIB}*.db] { 
#  set i [expr [string last / $iLIB] +1]
#  set jLIB [string range $iLIB $i 1000]
#  if {[string match "m7p5*" $jLIB] || [string match "m9*" $jLIB] || [string match "tcbn16ffc*" $jLIB]} {
#    if {[string match "*ccs*" $jLIB] || [string match "*tcd*" $jLIB]} { lappend link_library $jLIB }
#  } else { 
#    if {[string match "u_*" $jLIB] || [string match "*isl*" $jLIB]} {} else { lappend link_library $jLIB }
#  }
#}
#lappend link_library $LIBSET/db/core_esd_slowgnp0p72v125.db

foreach iLIB [ls $LIBSET/db/$LIB/*.db] {lappend link_library $iLIB}
######## Link Library ###################






######## Target Library ###################
#set libALL [ls $LIBSET/db/tcbn16ffcllbwp*${LIB}_ccs.db]
#set lib7D5T [ls $LIBSET/db/tcbn16ffcllbwp7d5t*${LIB}_ccs.db]
#set lib9T $libALL
#foreach lib7 $lib7D5T { 
#  set iIndex [lsearch -exact $lib7 $lib9T]
#  set lib9T [lreplace $lib9T $iIndex $iIndex]
#}

#if {$TRACK==9} {
#  set target_library $lib9T
#} else {
#  set target_library $lib7D5T
#  set target_library m7p5lnd_synccpdtcbn*${LIB}*.db
#}

#########################################
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
#########################################

if ![file exists $RptDIR] {file mkdir $RptDIR}
if ![file exists $SessionDIR] {file mkdir $SessionDIR}
