report_constraints -all_violators -max_transition -nosplit > $RptDIR/tran.brief.rpt
report_constraints -all_violators -v -max_delay -recovery -nosplit > $RptDIR/setup.verbose.rpt
report_constraints -all_violators -max_delay -recovery -nosplit > $RptDIR/setup.brief.rpt
report_constraints -all_violators -v -min_delay -removal -nosplit > $RptDIR/hold.verbose.rpt
report_constraints -all_violators -min_delay -removal -nosplit > $RptDIR/hold.brief.rpt

proc rsetup {} {
  global RptDIR
  report_constraints -all_violators -v -max_delay -recovery -nosplit > $RptDIR/setup.verbose.rpt
  report_constraints -all_violators -max_delay -recovery -nosplit > $RptDIR/setup.brief.rpt
}

proc rhold {} {
  global RptDIR
  report_constraints -all_violators -v -min_delay -removal -nosplit > $RptDIR/hold.verbose.rpt
  report_constraints -all_violators -min_delay -removal -nosplit > $RptDIR/hold.brief.rpt
}

