mrvl_report_shorted_output_pins -output $RptDIR/short_output.rpt
mrvl_report_unconnected_input_pins -leaf_only -output $RptDIR/open_input.rpt
source /proj/cadpnr/pds/tools/pt/clock/pdReportClockTran_pt.tcl
pdReportClockTran > $RptDIR/clk.tran.rpt
sh mv pdClockTran.tran                         $RptDIR/.
sh mv pdClockTran_noneClkBufList.rpt   $RptDIR/.
sh mv pdClockTran_pseudoClkTrace.rpt   $RptDIR/.
sh mv pdClockTran_violationSummary.rpt $RptDIR/.
sh mv pdClockTran_vioNetDriver.rpt     $RptDIR/.

