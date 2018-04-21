foreach_in_collection iInput [remove_from_collection [all_inputs] [ get_attribute [get_clocks] sources]] { foreach_in_collection iOutput [all_outputs] {
    echo [get_attribute $iInput full_name] [get_attribute $iOutput full_name]
    set iPath [get_timing_path -from $iInput -to $iOutput]
    set slack [get_attribute $iPath slack]
    if [expr {$slack != ""}] {if [expr {$slack != "INFINITY"}] {
        set sclkname [get_attribute [get_attribute $iPath startpoint_clock] full_name]
        set eclkname [get_attribute [get_attribute $iPath endpoint_clock] full_name]
        if [expr [expr {${sclkname}==${eclkname}}] && [expr {${sclkname}!= ""}]] {
          set clkport [get_attribute [get_attribute [get_clocks $sclkname] sources] full_name]
          set period [get_attribute  [get_clocks $sclkname] period]
          set dly_in [get_attribute $iPath startpoint_input_delay_value] 
          set dly_out [get_attribute $iPath endpoint_output_delay_value] 
          echo [get_attribute $iInput full_name] [get_attribute $iOutput full_name] $sclkname $period $dly_in [expr $dly_in/$period] $dly_out [expr $dly_out/$period] [expr $period - $dly_in - $dly_out] $slack
	}
    }}
}}

