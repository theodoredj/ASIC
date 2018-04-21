set power_enable_analysis TRUE
set power_analysis_mode averaged
set power_default_toggle_rate 0.1 
set power_default_static_probability 0.5 

check_power -verbose
update_power
report_power >> $RptDIR/PTPX10.rpt
