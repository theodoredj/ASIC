set power_enable_analysis TRUE
set power_analysis_mode averaged
set power_default_toggle_rate 0.08 
set power_default_static_probability 0.5 

read_saif /proj/deneb1/wa/deneb1/TSB_release/SAIF/sas_file_wr.saif.gz -strip_path uTSB_TOP/u_fe_top
read_saif /proj/deneb1/wa/deneb1/TSB_release/SAIF/sas_file_wr.saif.gz -strip_path uTSB_TOP/u_be_top

check_power -verbose
update_power
report_power >> $RptDIR/PTPX08.rpt
