suppress_message ATTR-3
proc Gen {PortList ClkList Margin} {
  foreach_in_collection iPort $PortList {
    set found 0
    set portname [get_attribute $iPort full_name]
    set portdirection [get_attribute $iPort direction]

    foreach_in_collection iCLK $ClkList {
      set clkname [get_attribute $iCLK full_name]
      if [expr {${portdirection}=="in"}]  { set ipath [get_timing_path -from $portname -group $clkname] }
      if [expr {${portdirection}=="out"}] { set ipath [get_timing_path -to $portname -group $clkname] }
      set slack [get_attribute $ipath slack]
      if [expr {${slack}!="INFINITY" && ${slack}!=""}] {
        set sclkname [get_attribute [get_attribute $ipath startpoint_clock] full_name]
        set eclkname [get_attribute [get_attribute $ipath endpoint_clock] full_name]
        if [expr {${sclkname}==${eclkname}}] {
          set clkport [get_attribute [get_attribute [get_clocks $sclkname] sources] full_name]
          set period [get_attribute  [get_clocks $sclkname] period]
          if [expr {${portdirection}=="in"}]  { set dly_ext [get_attribute $ipath startpoint_input_delay_value] }
          if [expr {${portdirection}=="out"}] { set dly_ext [get_attribute $ipath endpoint_output_delay_value] }
          set dly_int [expr $Margin * ($period - $dly_ext)]
          if [expr $dly_int < [expr 0.1 * $period]] { set dly_int [expr 0.1 * $period] }
          if [expr $dly_int > [expr 0.9 * $period]] { set dly_int [expr 0.9 * $period] }
          if [expr {${portdirection}=="in"}]  { echo $portname "input" $clkport $dly_int "NA" }
          if [expr {${portdirection}=="out"}] { echo $portname "output" $clkport "NA" $dly_int }
          set found 1
        }
      }
    }

    if [expr $found==0] { 
      if [expr {${portdirection}=="in"}]  { echo $portname "input NONE NONE NONE"}
      if [expr {${portdirection}=="out"}] { echo $portname "output NONE NONE NONE"}
    }
  }
}

##############################################################################
set ClkPorts ""
set Clocks [remove_from_collection [get_clocks] [get_generated_clocks]]
foreach_in_collection iCLK $Clocks {
  set portname [get_attribute [get_attribute $iCLK sources] full_name]
  set class [get_attribute [get_attribute $iCLK sources] object_class]
  if [expr {${class}=="port"}] { 
    echo $portname "input" $portname "NA NA" 
    append_to_collection ClkPorts [get_ports $portname]
  }
}
append_to_collection Clocks [get_path_group **clock_gating_default**]
##############################################################################
set MaxDlyPorts [get_ports [list denebX_jtg_shiftdr denebX_jtg_tdi denebX_jtg_trstb denebX_jtg_updatedr hud_int[*] NDC_GCLK_EN NDC_SCLK_EN ndisl2hummg_GPIO[*] PMU_DONE_scan RESET_N tsb_jtg_g_tdi tsb_jtg_g_tdo tsb_jtg_trstb]]
foreach_in_collection iPort $MaxDlyPorts {
  set portname [get_attribute $iPort full_name]
  set portdirection [get_attribute $iPort direction]
#  echo $portname $portdirection "NONE NONE NONE"
    if [expr {${portdirection}=="in"}] {
      echo $portname "input" "NONE NONE NONE"
    }
    if [expr {${portdirection}=="out"}] {
      echo $portname "output" "NONE NONE NONE"
    }
}
##############################################################################
set SpecialMarginPorts [get_ports denebX_jtg_capturedr]
#Gen $SpecialMarginPorts $Clocks 1.0
Gen [remove_from_collection [remove_from_collection [remove_from_collection [get_ports *] $ClkPorts] $MaxDlyPorts] $SpecialMarginPorts] $Clocks 1.5
