	if {![file exists $RptDIR/pt4ice] } {exec mkdir $RptDIR/pt4ice}
        source ${ScrDIR}/dont_use.tcl
        source /proj/eda/ICSCAPE/ICEXPLORER/1512.sp3/library/pt_utils.tcl
	report_annotated_data_for_icexplorer  ${Mode}_${LIB} $RptDIR/pt4ice
	report_qor > $RptDIR/pt4ice/${LIB}.${rcCorner}.qor.rpt
	source /proj/cadpnr/pds/tools/pt/clock/pdReportClockTran_pt.tcl
	pdReportClockTran  -output $RptDIR/pt4ice/${LIB}.${rcCorner}.clock_transition.rpt
