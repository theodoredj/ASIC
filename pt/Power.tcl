set_case_analysis 1 FMC_VREF_2
set_case_analysis 1 FMC_VREF_6
set_case_analysis 1 FMC_VREF_10
set_case_analysis 1 FMC_VREF_14
set_case_analysis 1 FMC_ND_CAL_PAD
set_case_analysis 0 JTG_TDI
set_case_analysis 0 JTG_TMS
set_case_analysis 1 JTG_TRSTn
#set_case_analysis 1 ICE_ACTN_DI
set_case_analysis 1 ICE_ACTn
set_case_analysis 0 JTG_TDI
set_case_analysis 0 JTG_TMS
set_case_analysis 1 JTG_TRSTn
set_case_analysis 0 uTSB_TOP/u_be_top/tsb_jtg_tms
set_case_analysis 1 uTSB_TOP/u_be_top/tsb_jtg_trstb
set_case_analysis 0 uTSB_TOP/u_be_top/u_ndc_top/u_nd0_isl/tsb_jtg_tms
set_case_analysis 1 uTSB_TOP/u_be_top/u_ndc_top/u_nd0_isl/tsb_jtg_trstb

set power_enable_analysis TRUE
set power_analysis_mode averaged
set power_default_static_probability 0.5
set power_default_toggle_rate $TOGGLE

#check_power
#update_power
#report_power >> $RptDIR/PTPX.NoSaif.$TOGGLE.$LIB.rpt

if [expr {$SAIF != 0}]   {
  echo "SAIF file is set to be $SAIF"
  read_saif $SAIF -strip_path top/dut_top/DENEB_TOP
  check_power
  update_power
#  report_power >> $RptDIR/PTPX.SAIF.$TOGGLE.$LIB.rpt
#  report_switching_activity -list_not_annotated > not_annotated.$LIB.log

    report_power -nosplit -verbose                               > $RptDIR/$LIB.rp_v_saif.rpt
    report_power -nosplit -hierarchy                             > $RptDIR/$LIB.rp_h.rpt
    report_power -nosplit -cell_power -leaf                      > $RptDIR/$LIB.rp_cp_l.rpt
#    report_power -nosplit -cell_power -leaf -hierarchy           > $RptDIR/$LIB.rp_cp_l_h.rpt
    report_switching_activity                                    > $RptDIR/$LIB.rsa.rpt
    report_switching_activity -average_activity                  > $RptDIR/$LIB.rsa_average_saif.rpt
    report_switching_activity -hierarchy -average_activity       > $RptDIR/$LIB.rsa_aa.rpt
    report_switching_activity -hierarchy -coverage               > $RptDIR/$LIB.rsa_h_c.rpt
    report_clock_gate_savings                                    > $RptDIR/$LIB.rcgs.rpt
    report_clock_gate_savings -sequential -nosplit               > $RptDIR/$LIB.rcgs_s_.rpt
    report_clock_gate_savings -sequential -nosplit -hierarchical > $RptDIR/$LIB.rcgs_s_h.rpt
}
