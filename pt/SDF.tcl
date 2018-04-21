reset_timing_derate
update_timing -full
set filename ${TOP}.${LIB}
write_sdf -compress gzip -no_negative_values net_delays -no_edge -context verilog ${RptDIR}/${filename}.sdf.gz
