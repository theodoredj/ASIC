### Please refer to var.txt for LIB/RC corner options

set Corners ""
if [expr {$scenario_all == 1}] { set scenario_setup 1; set scenario_hold 1}
if [expr {$scenario_all5 == 1}] {
        set scenario_setup_ssLVLT_m40   1
        set scenario_setup_ssLVHT_rcw   1
        set scenario_hold_ssLVLT_ccw    1
        set scenario_hold_ssHVHT_rcw    1
        set scenario_hold_ffHVHT_rcw    1
}
if [expr {$scenario_setup == 1}] {
	set scenario_setup_ssLVLT_m40	1
	set scenario_setup_ssLVLT_ccw	1
	set scenario_setup_ssLVHT_rcw	1
	set scenario_setup_ssLVHT_ccw	1
	set scenario_setup_typ85		1
}
if [expr {$scenario_hold == 1}] {
	set scenario_hold_ssLVHT_ccb	1
	set scenario_hold_ssLVLT_ccw	1
	set scenario_hold_ssHVHT_rcw	1
	set scenario_hold_ffHVLT_rcb	1
	set scenario_hold_ffHVHT_rcw	1
	set scenario_hold_typ25		1
}
if [expr {$scenario_NoTYP == 1}] {set scenario_setup_typ85 0; set scenario_hold_typ25 0}


if [expr {$scenario_setup_ssLVLT_m40 == 1}]  { lappend Corners [list "ssgnp0p72vm40c" "cworstm40c" "setup"] }
if [expr {$scenario_setup_ssLVLT_ccw == 1}]  { lappend Corners [list "ssgnp0p72v0c" "cworst0c" "setup"] }
if [expr {$scenario_setup_ssLVHT_rcw == 1}] { lappend Corners [list "ssgnp0p72v125c" "rcworst125c" "setup"] }
if [expr {$scenario_setup_ssLVHT_ccw == 1}] { lappend Corners [list "ssgnp0p72v125c" "cworst125c" "setup"] }
if [expr {$scenario_setup_typ85 == 1}]      { lappend Corners [list "tt0p8v85c" "typical85c" "setup"] }
if [expr {$scenario_hold_ssLVHT_ccb == 1}]  { lappend Corners [list "ssgnp0p72v125c" "cbest125c" "hold"] }
if [expr {$scenario_hold_ssLVLT_ccw == 1}]  { lappend Corners [list "ssgnp0p72vm40c" "cworstm40c" "hold"] }
if [expr {$scenario_hold_ssHVHT_rcw == 1}]  { lappend Corners [list "ssgnp0p9v125c" "rcworst125c" "hold"] }
if [expr {$scenario_hold_ffHVLT_rcb == 1}]  { lappend Corners [list "ffgnp0p88vm40c" "rcbestm40c" "hold"] }
if [expr {$scenario_hold_ffHVHT_rcw == 1}]  { lappend Corners [list "ffgnp0p88v125c" "rcworst125c" "hold"] }
if [expr {$scenario_hold_typ25 == 1}]       { lappend Corners [list "tt0p8v25c" "typical25c" "hold"] }

set ModeList ""
while {[string first _ $Mode] > 0} {
  lappend ModeList [string rang $Mode 0 [expr [string first _ $Mode] -1]]
  set Mode [string rang $Mode  [expr [string first _ $Mode] +1] [string length $Mode]]
}
lappend ModeList $Mode

set Scenarios ""
for {set i 0} {$i<[llength $ModeList]} {incr i} {
  set SDCFile ${SdcDIR}/${TOP}/${TOP}.[lindex $ModeList $i].sdc
  for {set x 0} {$x<[llength $Corners]} {incr x} {
	    lappend Scenarios [concat [lindex $ModeList $i] $SDCFile [lindex $Corners $x]]
  }
}

#set_multi_scenario_license_limit -force -feature PrimeTime 2
#set_multi_scenario_license_limit -force -feature PrimeTime-SI 2
#add_distributed_hosts -64 -farm generic -num_of_hosts 2 -options "-background -sgq 16g" -submission_script {/proj/caeeda/SYNOPSYS/PT/bin/pt_shell}
#set_distributed_parameters -script {}
#create_distributed_farm

foreach Scenario $Scenarios {
  set Mode     [lindex $Scenario 0]
  set SDC      [lindex $Scenario 1]
  set LIB      [lindex $Scenario 2]
  set rcCorner [lindex $Scenario 3]
  set TYPE    [lindex $Scenario 4]

  create_scenario -name ${Mode}_${LIB}_${rcCorner}_${TYPE} \
    -specific_variables {Mode SDC LIB rcCorner TYPE} \
    -common_variables {USER DMSA TOP TimeStamp runID ScrDIR SdcDIR RptDIR SessionDIR}
}



#set lic 6
#set_multi_scenario_license_limit -feature PrimeTime $lic
#set_multi_scenario_license_limit -feature PrimeTime-SI $lic
#set_distributed_parameters -script {}
#add_distributed_hosts -64 -farm generic -num_of_hosts 6 -options "-background -sgq 16g " -submission_script {/proj/caeeda/SYNOPSYS/PT/bin/pt_shell}
#create_distributed_farm

set multi_core_enable_analysis                 true
set multi_core_working_directory               multicore_output

#set_host_options -name deneb_host -num_processes [llength $Scenarios] \
        -submit_command "pt_shell -sgq normal -sgm 16 -sgc 1" 

if {[expr {$FLAT == 1}] && [expr {$TOP == "u_be_top"}]} {
  set_distributed_parameters -script {/proj/eda/SYNOPSYS/PT/bin/pt_shell -sgq normal:96m:1c -sgbg -sgdebug}
} else {
  set_distributed_parameters -script {/proj/eda/SYNOPSYS/PT/bin/pt_shell -sgq normal:32m:1c -sgbg -sgdebug}
}
set_host_options -protocol sh -num_processes [llength $Scenarios] -max_cores 4 -terminate_command "qdel"

start_hosts -timeout 21600 -min_hosts [llength $Scenarios]

current_session -all

remote_execute "source -e -v $ScrDIR/slave.tcl"
#source -e -v $ScrDIR/fix_eco.tcl

#remote_execute "save_session $SessionDIR"

echo "ALL RUNS ARE DONE"

if { ${EXIT} } { exit }

