sh date
source -e -v $ScrDIR/lib.tcl

proc Read_RC { Modules Modules_Path Modules_RC } {
	global RptDIR
	global RCFormat
	global parasitics_log_file

	set parasitics_log_file ${RptDIR}/read_rc.${Modules}.log
	echo "loading $Modules $RCFormat file $Modules_RC to block $Modules_Path"

	if [expr {$RCFormat == "SDF"}] {
		if [expr {$Modules_Path == "TOP"}] {
			read_sdf -min_file $Modules_RC -max_file $Modules_RC -verbose
		} else {
       		       	read_sdf -min_file $Modules_RC -max_file $Modules_RC -verbose -path $Modules_Path
		}
	} else {
                if [expr {$Modules_Path == "TOP"}] {
                	read_parasitics -format $RCFormat -increment $Modules_RC -verbose -keep_capacitive_coupling
                } else {
                       read_parasitics -format $RCFormat -increment $Modules_RC -path $Modules_Path -verbose -keep_capacitive_coupling
                }
	}
	echo "finish loading $Modules $RCFormat file $Modules_RC to block $Modules_Path"
}

################ Set Default Value  ####################
set postfix ${RCFormat}
if [expr {$RCFormat == "SPEF"}] { set postfix SPEF.gz }
if [expr {$RCFormat == "SDF"}] { set postfix sdf.gz }

if [expr {$Modules_Verilog == "default"}] { set Modules_Verilog $ReleaseDIR/${TOP}.v }
if [expr {$Modules_RC == "default"}] { set Modules_RC $ReleaseDIR/${TOP}.${rcCorner}.${postfix} }
set Modules $TOP

if [expr {$Modules_SUB != "NONE"}] {
  set var_file [open $Modules_SUB]
  set var_data [read $var_file]
  foreach line [split $var_data "\n"] {
    set length [string length $line]
    if {[string length $line] > 0} { if {[string equal [string index $line 0] "#"]} {} else {
      # Keyword DB/V/RC & Module Name & File Location & Sub block in TOP module path
      set W0 [lindex [split $line " "] 0]
      set W1 [lindex [split $line " "] 1]
      set W2 [lindex [split $line " "] 2]
      if [expr {$W0 == "DB"}] { 
        if [expr {$W2 == "default"}] { set W2 ${ReleaseDIR}/${W1}_${LIB}.db}
        lappend link_library $W2
      } elseif [expr {$W0 == "V"}] { 
        if [expr {$W2 == "default"}] { set W2 ${ReleaseDIR}/${W1}.v}
        lappend Modules_Verilog $W2
      } elseif [expr {$W0 == "RC"}] {
        if [expr {$W2 == "default"}] { set W2 ${ReleaseDIR}/${W1}.${rcCorner}.${postfix}}
        set Modules_RC [linsert $Modules_RC 0 $W2]
        set W3 [lindex [split $line " "] 3]
        set Modules_Path [linsert $Modules_Path 0 $W3]
        set Modules [linsert $Modules 0 $W1]
#        lappend Modules_Path $W3
#        lappend Modules $W1
      }
    }}
  }
  close $var_file
}
foreach iV $Modules_Verilog {read_verilog $iV}
current_design $TOP
link -keep_sub_designs
if [expr {$NoRC == 0}] { for {set x 0} {$x<[llength $Modules]} {incr x} { Read_RC [lindex $Modules $x] [lindex $Modules_Path $x] [lindex $Modules_RC $x] } }
##################################################################
if { ${M9} != 1} {
  set_operating_conditions -analysis_type on_chip_variation -library tcbn16ffcllbwp7d5t16p96cpd${LIB}_ccs -max $LIB -min $LIB
} else {
  set_operating_conditions -analysis_type on_chip_variation -library tcbn16ffcllbwp16p90cpd${LIB}_ccs -max $LIB -min $LIB
}

# ffgnp0p88v125c ffgnp0p88v0c ffgnp0p88vm40c ssgnp0p72v0c ssgnp0p72v125c tt0p8v25c tt0p8v85c
switch -exact $LIB {
  ffgnp0p88v125c   { set HoldCU 0.012; set SetupCU 0.000}
  ffgnp0p88vm40c { set HoldCU 0.012; set SetupCU 0.000}
  ffgnp0p88v0c   { set HoldCU 0.012; set SetupCU 0.000}
  ssgnp0p72v0c   { set HoldCU 0.020; set SetupCU 0.030}
  ssgnp0p72v125c { set HoldCU 0.020; set SetupCU 0.030}
  ssgnp0p72vm40c { set HoldCU 0.020; set SetupCU 0.030}
  ssgnp0p9v125c  { set HoldCU 0.020; set SetupCU 0.030}
  tt0p8v25c      { set HoldCU 0.015; set SetupCU 0.050}
  tt0p8v85c      { set HoldCU 0.015; set SetupCU 0.050}
  default        { echo "Error: LIBRARY_MODE $LIB is not supported.\n"; exit 1 }
}


#if { ${OCV} == 1 } { pdSignoffCriteria -tech 28hpm -scenario ${Mode}_hold_${LIB}_${rcCorner} }
#  set_timing_derate -early [expr 1 - $Launch_Derate]
#  set_timing_derate -late  [expr 1 + $Capture_Derate]
#  set_timing_derate -early 0.8 [get_lib_cells m9*zd_std_${LIB}/*dly*] -cell_delay
#  set_timing_derate -late  1.2 [get_lib_cells m9*zd_std_${LIB}/*dly*] -cell_delay
#  set_timing_derate -early 0.87 [get_lib_cells m9*zd_std_${LIB}/*locvx*] -cell_delay
#  set_timing_derate -late  1.13 [get_lib_cells m9*zd_std_${LIB}/*locvx*] -cell_delay

set_noise_parameters -enable_propagation -include_beyond_rails

if [expr {${TCL1}!="NONE"}] { redirect ${RptDIR}/tcl1.$Mode.$LIB.$rcCorner.log {source -e -v ${TCL1}} }
if [expr {${TCL2}!="NONE"}] { redirect ${RptDIR}/tcl2.$Mode.$LIB.$rcCorner.log {source -e -v ${TCL2}} }
if [expr {${TCL3}!="NONE"}] { redirect ${RptDIR}/tcl3.$Mode.$LIB.$rcCorner.log {source -e -v ${TCL3}} }
if [expr {${TCL4}!="NONE"}] { redirect ${RptDIR}/tcl4.$Mode.$LIB.$rcCorner.log {source -e -v ${TCL4}} }
if [expr {${TCL5}!="NONE"}] { redirect ${RptDIR}/tcl5.$Mode.$LIB.$rcCorner.log {source -e -v ${TCL5}} }

printvar * > ${RptDIR}/variables.rpt
if { ${SAVE} } { save_session $SessionDIR}

##########################################################################################
## Future Process May change Official Timing, thus executed after SAVE SESSION
##########################################################################################

if { ${PT4ICE} == 1 } { 
#	update_timing -full
	if {![file exists $RptDIR/pt4ice] } {exec mkdir $RptDIR/pt4ice}
        source ${ScrDIR}/dont_use.tcl
#	source $ScrDIR/pt4ice.pt_utils.tcl
#	source $ScrDIR/pt_utils.default.tcl
        source /proj/eda/ICSCAPE/ICEXPLORER/1512.sp3/library/pt_utils.tcl
	report_annotated_data_for_icexplorer  ${Mode}_${LIB} $RptDIR/pt4ice
	report_qor > $RptDIR/pt4ice/${LIB}.${rcCorner}.qor.rpt
	source /proj/cadpnr/pds/tools/pt/clock/pdReportClockTran_pt.tcl
	pdReportClockTran  -output $RptDIR/pt4ice/${LIB}.${rcCorner}.clock_transition.rpt
}

if { ${SAVE_SDF} } {
	reset_timing_derate
	update_timing -full
        set filename ${TOP}.${LIB}
        write_sdf -compress gzip -no_negative_values net_delays -no_edge -context verilog ${RptDIR}/${filename}.sdf.gz
}

if { ${MakeDB} == 0 } {
} elseif { ${MakeDB} == 1 } {
	#source ${ScrDIR}/mask_lib_paths.tcl
	update_timing
	extract_model -output ${RptDIR}/${TOP}_${LIB}_${rcCorner}_${TYPE}_${Mode} -format {lib db} -library_cell
} else {
	source ${MakeDB}
}

if { ${EXIT} && !${DMSA}}  { exit }
