alias include {source -e -v}
alias rtfo {report_transitive_fanout -from }
alias rtfi {report_transitive_fanin -to }
alias afo { all_fanout -flat -end -from }
alias afi { all_fanin -flat -start -to }
alias soc sizeof_collection
alias rh { report_timing -nos -delay min }
alias r { report_timing -nos -delay max  }
alias pageon {set enable_page_mode true ; set sh_enable_page_mode true}
alias pageoff {set enable_page_mode false ; set sh_enable_page_mode false}
alias cs change_selection

proc csc {cname} { change_selection [get_cell $cname] }
proc csca {cname} { change_selection -a [get_cell $cname] }
proc csn {nname} { change_selection [get_nets $nname] }
proc csna {nname} { change_selection -a [get_nets $nname] }
proc csp {pname} { change_selection [get_nets -of [get_pins $pname]]}
proc cspa {pname} { change_selection -a [get_nets -of [get_pins $pname]]}
proc cc { a } { change_selection [get_fp_cells $a] }

proc get_net_by_pin {iPin} { return [get_nets -of [get_pins $iPin]] }
proc get_pin_by_pin {iPin} { return [all_connected -leaf [get_nets -of [get_pins $iPin]]] }
proc get_cell_by_pin {iPin} { return [get_cells -of [all_connected -leaf [get_nets -of [get_pins $iPin]]]] }
proc get_drv_pin {iPin} { return [filter_collection [all_connected -leaf [get_nets -of [get_pins $iPin]]] pin_direction==out] }

proc dname { a } { foreach_in_collection aa $a {echo [get_attribute $aa full_name] }}
proc dname_sort { a } { foreach_in_collection aa [sort_collection $a full_name] {echo [get_attribute $aa full_name] }}
proc dname_list { a } { foreach aa $a {echo $aa} }

proc dsel {} { dname [get_selection] }
proc dafo { a } { dname [all_fanout -flat -end -from $a] }
proc dafi { a } { dname [all_fanin -flat -start -to $a] }
proc AllConn { a } { dafi $a; dafo $a }

proc list_cell_pin {iCell} { foreach_in_collection iPin [get_pins -of [get_cells $iCell]] { echo [get_attribute $iPin lib_pin_name] [get_attribute $iPin direction] } }
proc list_lib_pin  {iCell} { foreach_in_collection ipin [get_lib_pins */$iCell/*] { echo [get_attribute $ipin base_name] [get_attribute $ipin direction]} }
proc dpins {a} { foreach_in_collection aa [get_pins $a] { echo [get_attribute $aa lib_pin_name] [get_attribute $aa pin_direction]} }

proc GetCelRef { cname } { return [get_attribute [get_cells $cname] ref_name] }
proc GetCelByRef { refname} { dname_sort [get_cells -hier -filter "ref_name=~$refname"] }
proc GetDrvPin { Pins } { 
  foreach iPin $Pins { append_to_collection -unique Dpins [get_drv_pin $iPin] }
  foreach_in_collection iPin $Dpins { 
    set iCell [get_cells -of $iPin]
    echo [get_attribute $iCell full_name] [get_attribute $iCell ref_name] [get_attribute $iPin lib_pin_name]
  }
}
proc GetDrvCell { Pins } {
  foreach iPin $Pins { append_to_collection -unique Cells [get_cells -of [get_drv_pin $iPin]] }
  foreach_in_collection iCell $Cells { echo [get_attribute $iCell full_name] [get_attribute $iCell ref_name] }
}


proc ShowConn { cells } { 
  change_selection $cells
  set snets ""
  foreach_in_collection icell $cells { 
    set pins [get_pins -of_o $icell -filter "@name != CK and @name !=CLK"]
    append_to_collection snets [get_nets -of_o $pins]
  }
  change_selection -add $snets
}

proc ShowSelConn {} {
  foreach_in_collection icell [get_selection -type cell] {
    set pins [get_pins -of_o $icell -filter "@name != CK and @name !=CLK"]
    append_to_collection snets [get_nets -of_o $pins]
  }
  change_selection -add $snets
}


proc HighLightNetCell { iPin } {
   set dPin [GetDrvPin $iPin]
   gui_change_highlight -remove -all_colors

   gui_change_highlight -add -color yellow -collection [get_cells -of [all_connected -leaf [get_nets -of [get_pins $dPin]]]]
   gui_change_highlight -add -color red -collection [get_cells -of $dPin]
   gui_change_highlight -add -color green -collection [get_nets -of [get_pins $dPin]]

   change_selection [get_nets -of [get_pins $dPin]]
   gui_zoom -window [gui_get_window_ids -type Layout] -selection
   dname_sort [get_pin_by_pin $iPin]
}

   



proc HM { hmodule } {
  set hmodule_name [get_attribute $hmodule name]
  set modules [get_cells [get_attribute $hmodule full_name]/* -filter "@is_hierarchical==true"]

  gui_set_highlight_options -auto_cycle_color 1
  gui_change_highlight -remove -all_colors
  change_selection

  set ids 0
  set mcount 0
  echo "" > $hmodule_name.$ids.jpg.txt

  foreach_in_collection imodule [sort_collection $modules full_name] {
    echo [ gui_get_highlight_options -current_color] [get_attribute $imodule full_name] >> $hmodule_name.$ids.jpg.txt
    echo [ gui_get_highlight_options -current_color] [get_attribute $imodule full_name]
    gui_change_highlight -add -collection [get_fp_cells [get_attribute $imodule full_name]/*]
    set mcount [expr $mcount + 1]
    if ($mcount==10) { 
      gui_write_layout_image -view_only -output $hmodule_name.$ids.jpg
      set ids [expr $ids + 1]
      set mcount 0
      echo "" > $hmodule_name.$ids.jpg.txt
      gui_change_highlight -remove -all_colors
    }
  }
  gui_write_layout_image -view_only -output $hmodule_name.$ids.jpg
}

proc HMs { hmodules } {
 gui_set_highlight_options -auto_cycle_color 1
 foreach_in_collection imodule $hmodules { gui_change_highlight -add -collection [get_fp_cells [get_attribute $imodule full_name]/*] }
}
   
proc init_variable {var default} {
   global env $var
   if {[info exists $var]} {
      return
   } elseif {[info exists env($var)]} {
      set $var $env($var)
   } else {
      set $var $default
   }
}

proc SetLog {} {
global runID
init_variable runID noID

set mydate [sh date '+%Y%m%d%H%M']
set logfile logs/$runID.${mydate}.log
set cmdfile logs/$runID.${mydate}.cmd

exec mkdir -p logs
set sh_output_log_file $logfile
set sh_command_log_file $cmdfile
}

proc GetMinSlack { islacks } {
 if {$islacks==""} { return 999 }
 set MinSlack [lindex $islacks 0]
 for {set y 1} {$y<[llength $islacks]} {incr y} {
   set islack [lindex $islacks $y]
   if {$islack == "INFINITY"} { set islack 999}
   if {$MinSlack>$islack} { set MinSlack $islack}
 }
 return $MinSlack
}

proc GetMinSetup { ipoint } {
  set ipath [get_timing_path -through $ipoint]
  set islacks [get_attribute $ipath slack]
  if {$islacks==""} { return 999 }
  set MinSlack [lindex $islacks 0]
  if {$MinSlack == "INFINITY"} { set MinSlack 999}
  for {set y 1} {$y<[llength $islacks]} {incr y} {
    set islack [lindex $islacks $y]
    if {$islack == "INFINITY"} { set islack 999}
    if {$MinSlack>$islack} { set MinSlack $islack}
  }
  return $MinSlack
}

proc GetMinHold { ipoint } {
  set ipath [get_timing_path -delay min -through $ipoint]
  set islacks [get_attribute $ipath slack]
  if {$islacks==""} { return 999 }
  set MinSlack [lindex $islacks 0]
  if {$MinSlack == "INFINITY"} { set MinSlack 999}
  for {set y 1} {$y<[llength $islacks]} {incr y} {
    set islack [lindex $islacks $y]
    if {$islack == "INFINITY"} { set islack 999}
    if {$MinSlack>$islack} { set MinSlack $islack}
  }
  return $MinSlack
}


proc ChkMissingClkFF {} {
  foreach_in_collection iclock [all_clocks] { 
    set Clk1 [afo [get_attribute $iclock sources]]
    set FF1 [get_cells -of $Clk1]
    append_to_collection -unique CKs $Clk1
    append_to_collection -unique REGs $FF1
    echo "Fanout of Clock " [get_attribute $iclock full_name] "is " [soc $Clk1] " related FF Count is " [soc $FF1]
  }
  set Missing [remove_from_collection [all_registers] $REGs]
  set Extra [remove_from_collection $REGs [all_registers]]
  echo "Total FF Count:" [soc [all_registers]]
  echo "Total Clock Coverted FF Count:" [soc $REGs]
  echo "Missing Clock FF Count:" [soc $Missing]
  echo "Extra Clock Fanout:" [soc $Extra]
  dname $Extra
  return $Missing
}

proc GetPinCase { iPin } { get_attribute [get_pins $iPin] case_value }

proc GetCellOnClock {RptName} {
  exec rm -f $RptName
  foreach_in_collection iclock [all_clocks] {
    echo "processing clock" [get_attribute $iclock name]
    set Clk1 [get_attribute $iclock sources]
    set FFs [all_fanout -from $Clk1 -flat -only -end]
    set AFO [all_fanout -from $Clk1 -flat -only]
    set Cells [remove_from_collection $AFO $FFs]
    foreach_in_collection icell $Cells { echo [get_attribute $icell full_name] [get_attribute $icell ref_name] >> $RptName}
  }
}

proc SetDontTouchNetwork { CellTypes PinList } {
  foreach iType $CellTypes {
    foreach_in_collection icell [get_cells -hierarchical -filter "ref_name == $iType"] {
      set cellname [get_attribute $icell full_name]
      echo  "set_dont_touch_network to" $PinList "of" $cellname
      foreach iPin $PinList { set_dont_touch_network $cellname/$iPin }
    }
  }
}

proc DisconnPin { PinName } { disconnect_net [get_nets -of [get_pins $PinName]] [get_pins $PinName] }

proc sizeup { CellList LibName RptName} {
  foreach_in_collection iCell $CellList {
    set iRef [get_attribute $iCell ref_name]
    set cName [get_attribute $iCell full_name]
    set iDrv [string rang $iRef [expr [string last x $iRef] + 1] 100] 
    set fRef $iRef
    set tLib [filter_collection [get_alternative_lib_cells [get_lib_cells */$iRef]] full_name=~${LibName}*]
    foreach_in_collection iLib $tLib {
      set tRef [get_attribute $iLib base_name]
      set tDrv [string rang $tRef [expr [string last x $tRef] + 1] 100]
      if {[string is digit $tDrv]} {if {$tDrv > $iDrv} { set fRef $tRef}}
    }
    if {[string equal $iRef $fRef]} {} else {echo "size_cell $cName $LibName/$fRef" >> $RptName}
  }
}

proc blackbox { InstName BufName} {
  
  echo "Start BlackBoxing $InstName"
  set TopName [current_design]
  set RefName [get_attribute [get_cells $InstName] ref_name]
  current_design $RefName
  link

  set Inputs [get_ports  -filter "pin_direction==in"]
  set Outputs [get_ports -filter "pin_direction==out"]
  append_to_collection Outputs [get_ports -filter "pin_direction==inout"]

  set J 0
  remove_cell -all
  remove_net -all

  foreach_in_collection ipin $Inputs {
#    set Dnets [remove_from_collection [get_nets -of $ipin -segments] [get_nets -of $ipin -segments -top_net_of_hierarchical_group] ]
#    set Dnets [get_nets -of $ipin]
#    disconnect_net $Dnets $ipin

    create_cell Nouse_Cell_$J $BufName
    create_net Nouse_Net_$J
    connect_net Nouse_Net_$J $ipin
    connect_net Nouse_Net_$J Nouse_Cell_$J/A
    set J [expr $J + 1]
  }

  foreach_in_collection ipin $Outputs {
#    set Dnets [remove_from_collection [get_nets -of $ipin -segments] [get_nets -of $ipin -segments -top_net_of_hierarchical_group] ]
#    set Dnets [get_nets -of $ipin]
#    disconnect_net $Dnets $ipin

    create_cell Nouse_Cell_$J $BufName
    create_net Nouse_Net_$J
    connect_net Nouse_Net_$J $ipin
    connect_net Nouse_Net_$J Nouse_Cell_$J/Z
    set J [expr $J + 1]
  }
  current_design $TopName
  link
}


proc precheckFile { args } {
set numFiles [llength $args]
if {$numFiles == 1} { set argsx [lindex $args 0]} else { set argsx $args }
set numFiles [llength $argsx]
for {set i 0} {$i < $numFiles} { incr i} {
set filex [lindex $argsx $i]
        if { ![file exist $filex] } {
                puts "ERROR: There is no file $filex !"
                return -1}
        }
}

proc get_setup_slack { ipin } { return [get_attribute [get_timing_path -through $ipin] slack] }
proc get_hold_slack { ipin } { return [get_attribute [get_timing_path -delay min -through $ipin] slack] }

proc GetBigCel { iRef } {
  set cleancellname [string range $iRef 0 [string last x $iRef]]
  set MaxStrength 0
  foreach_in_collection iCell [get_lib_cells */${cleancellname}*] {
    set icell_name [get_attribute $iCell base_name]
    set Strength [string range $icell_name [expr [string last x $icell_name]+1] [string length $icell_name]]
    if {[string is integer $Strength]} { if {$Strength>$MaxStrength} { set MaxStrength $Strength} }
  }
  return ${cleancellname}$MaxStrength
}

proc SizeUp { Cells Lib Format} {
  foreach iCell $Cells {
    set iRef [get_attribute [get_cells $iCell] ref_name]

    set cleancellname [string range $iRef 0 [string last x $iRef]]
    set MaxStrength 0
    foreach_in_collection iRef [get_lib_cells */${cleancellname}*] {
      set icell_name [get_attribute $iRef base_name]
      set Strength [string range $icell_name [expr [string last x $icell_name]+1] [string length $icell_name]]
      if {[string is integer $Strength]} { if {$Strength>$MaxStrength} { set MaxStrength $Strength} }
    }

    set iBig ${cleancellname}$MaxStrength
    set fBig $Lib[string range $iBig 3 100]
    if {[string equal $iRef $fBig]} {} else { if { $Format == "edi" } { echo "ecoChangeCell -inst $iCell -cell $fBig" } else {echo "size_cell $iCell $fBig" } }
  }
} 

proc GetTimingPathArrivalTime {iPath} {
  set iPoints [get_attribute $iPath points]
  set nPoints [sizeof_collection $iPoints]
  set iPoint  [index_collection $iPoints [expr $nPoints - 1]]
  #echo [get_attribute [get_attribute $iPath startpoint] full_name] [get_attribute [get_attribute $iPath endpoint] full_name] [get_attribute $iPath path_type] [get_attribute $iPoint arrival]
  return $iPoint
}




