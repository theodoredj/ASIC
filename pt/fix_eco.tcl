set eco_instance_name_prefix ECO1205Hold_
fix_eco_timing -type hold -methods insert_buffer_at_load_pins -setup_margin 0.01 -buffer_list {hzd_sbufx2 hzd_sbufx4} 
remote_execute {write_change -format ptsh -output ./rpt/ECO.Hold.PT.tcl}
remote_execute {write_change -format text -output ./rpt/ECO.Hold.TXT}

