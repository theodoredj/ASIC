set power_enable_analysis TRUE
set power_analysis_mode averaged
set power_default_static_probability 0.5

#set power_default_toggle_rate 0.1 
#check_power
#update_power
#report_power >> $RptDIR/PTPX.NoSaif.010.rpt

#set power_default_toggle_rate 0.08
#check_power 
#update_power
#report_power >> $RptDIR/PTPX.NoSaif.008.rpt

######################################################################################################
set power_default_toggle_rate 0.1
read_saif ./sas_file_wr.saif -strip_path top/dut_top/DENEB_TOP
check_power
update_power
report_power >> $RptDIR/PTPX.SAIF.010.rpt

#set power_default_toggle_rate 0.08
#check_power
#update_power
#report_power >> $RptDIR/PTPX.SAIF.008.rpt

