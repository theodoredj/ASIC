if [expr {$Mode == "flat"}] {
  set FLAT 1
} else {
  set FLAT 0
}

set SESSION $env(SESSION)

set Corners ""
if [expr {$scenario_slow125_10 == 1}] { lappend Corners "slow0p81v125_rcworst125_1_0" }
if [expr {$scenario_slow125_11 == 1}] { lappend Corners "slow0p81v125_rcworst125_1_1" }
if [expr {$scenario_fastn40_11 == 1}] { lappend Corners "fast0p99vn40_rcbestn40_1_1" }
if [expr {$scenario_fast125_11 == 1}] { lappend Corners "fast0p99v125_cbest125_1_1" }
if [expr {$scenario_typ110_11 == 1}]  { lappend Corners "typ0p9v110_typical110_1_1" }
if [expr {$scenario_slown10_10 == 1}] { lappend Corners "slow0p81vn10_cworstn10_1_0" }
if [expr {$scenario_slown10_11 == 1}] { lappend Corners "slow0p81vn10_cworstn10_1_1" }

set ModeList ""
while {[string first _ $Mode] > 0} {
  lappend ModeList [string rang $Mode 0 [expr [string first _ $Mode] -1]]
  set Mode [string rang $Mode  [expr [string first _ $Mode] +1] [string length $Mode]]
}
lappend ModeList $Mode

set Scenarios ""
for {set i 0} {$i<[llength $ModeList]} {incr i} {
  for {set x 0} {$x<[llength $Corners]} {incr x} {
    lappend Scenarios [lindex $ModeList $i]_[lindex $Corners $x]
  }
}

foreach Scenario $Scenarios {
  set ptimage  ${SESSION}/${Scenario}/session
  create_scenario -name $Scenario  -image $ptimage
  if ![file exists $runID/$Scenario/$RptDIR] {file mkdir $runID/$Scenario/$RptDIR}
}

set multi_core_enable_analysis                 true
set multi_core_working_directory               multicore_output

set_host_options -num_processes [llength $Scenarios] -max_cores 4 -terminate_command "qdel"
if {[expr {$FLAT == 1}] && [expr {$TOP == "u_be_top"}]} {
  set_distributed_parameters -script {/proj/eda/SYNOPSYS/PT/bin/pt_shell -sgq normal -sgm 96 -sgc 1 -sgbg -sgdebug}
} else {
  set_distributed_parameters -script {/proj/eda/SYNOPSYS/PT/bin/pt_shell -sgq normal -sgm 32 -sgc 1 -sgbg -sgdebug}
}

start_hosts 

current_session -all

echo "Loading DONE"



#exit


