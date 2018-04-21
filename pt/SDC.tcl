if { [file exists ${SDC}] } {
  echo "loading sdc file ${SDC}"
  redirect ${RptDIR}/source_sdc.log {source -e -v ${SDC}}
  echo "loaded sdc file ${SDC}"
}

set ExtraMargin 0.000
if { ${preCTS} == 1 } {
  remove_propagated_clock [all_clocks]
  set_clock_uncertainty 0.2  -hold  [all_clocks]
  set_clock_uncertainty 0.2 -setup [all_clocks]
} else {
  set_propagated_clock [all_clocks]
  if {[expr {$Mode == "TDF"}]} { set ExtraMargin 0.005 }
  set_clock_uncertainty [expr $HoldCU+$ExtraMargin]  -hold  [all_clocks]
  set_clock_uncertainty $SetupCU -setup [all_clocks] 
}

    ##------------------------------------
    ## Scenario NamingPreRequsites
    ##------------------------------------
    ## The scenario name should follow the following convention:
    ## [mode]_[timing_type]_[stdcell_library_corner]_[rc_corner][rc_temp]
    ##  - mode: design mode, func/shift/cap/mbist etc.
    ##  - timing_type: setup|hold to indicate setup or hold analysis
    ##  - rc_corner: (cworst|cbest|typical|rcworst|rcbest)(CCb|CCw)?T? to indicate RC corner
    ##  - rc_temp: mXXX, nXXX or XXX to indicate temp corner
    ## Example:
    ##  - func_setup_slow0p945v125_cworst125
    ##  - shift_hold_fast1p155vn40_cbestn40
    ##------------------------------------

#pdSignoffCriteria -tech 16ff -scenario ${Mode}_${TYPE}_${LIB}_${rcCorner}
mSignoffCriteria -tech 16nm -scenario ${Mode}_${TYPE}_${LIB}_${rcCorner}
