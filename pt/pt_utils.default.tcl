########################################################
# Report annotated data for icexplorer
########################################################

set ::_logFile "dump_data.log"
set ::_maxObjsNumber 500000
set ::_useConstraintMaxTransition false
set ::_ErrorLog ""
set ::_skipCaseValuePins false

proc ice_help_topics {} {
    puts ""
    puts "########################################################"
    puts "# This script is used for ICExplorer Version 2013.06   #"
    puts "# If need help, type ice_help_topics                   #" 
    puts "# To help individual commands to ice_help command_name #"
    puts "# Available commands:                                  #"
    puts "#  -report_scenario_data_for_icexplorer                #"
    puts "#  -report_annotated_data_for_icexplorer               #"
    puts "#  -report_paths_for_icexplorer                        #"
    puts "#  -report_pba_paths_for_icexplorer                    #"
    puts "########################################################"
    ice_help report_scenario_data_for_icexplorer
    ice_help report_annotated_data_for_icexplorer
    ice_help report_paths_for_icexplorer
    ice_help report_pba_paths_for_icexplorer
}


proc ice_help {topic} {
    puts "\n"
    if {$topic == "report_scenario_data_for_icexplorer"} {
      puts "Command: report_scenario_data_for_icexplorer"
      puts "  Use this command to report timing data for a given scenario into a dir."
      puts "Usage  : report_scenario_data_for_icexplorer <scenario> \[dir\]"
      puts "Options:"
      puts "  -scenario: scenario name"
      puts "  -dir     : output dir, by default it's \".\""
      puts "Example:"
      puts "  report_scenario_data_for_icexplorer ss"
      return 1
    }

    if {$topic == "report_annotated_data_for_icexplorer"} {
      puts "Command: report_annotated_data_for_icexplorer"
      puts "  Use this command to report timing data for a given scenario into a dir."
      puts "Usage  : report_annotated_data_for_icexplorer <scenario> <dir>"
      puts "Options:"
      puts "  -scenario: scenario name"
      puts "  -dir     : output dir"
      puts "Example:"
      puts "  report_annotated_data_for_icexplorer ss ./timing_data"
      return 1
    }

    if {$topic == "report_paths_for_icexplorer"} {
      puts "command: report_paths_for_icexplorer"
      puts "  Use this command to report setup or hold paths for ICExplorer."
      puts "  If fix hold violation, set delay_type min. max for setup fix. min_max for setup and hold fix"
      puts "Usage  : report_paths_for_icexplorer <scenario> \[dir\] \[delay_type\] \[max_paths\] \[nworst\] \[setup_threshold\] \[hold_threshold\] \[pba_mode\]"
      puts "Options:"
      puts "  -scenario  : scenario name"
      puts "  -dir       : output dir, by default it's \".\""
      puts "  -delay_type: delay type, can be min, max or min_max, by default it's min"
      puts "  -max_paths : Maximum number of paths per path group to output, by default it's 100000"
      puts "  -nworst    : List N worst paths to endpoint, by default it's 10"
      puts "  -pba_mode  : enable pba_mode, can be none or path, by default it is none"
      puts "  -setup_threshold: Only report those paths with slack less than setup_threshold, by default it's 0.0"
      puts "  -hold_threshold : Only report those paths with slack less than hold_threshold, by default it's 0.0"
      puts "Example:"
      puts "  report_paths_for_icexplorer ss min 10000 10"
      return 1
    }

    if {$topic == "report_pba_paths_for_icexplorer"} {
      puts "Command: report_pba_paths_for_icexplorer"
      puts "  Use this command to report PBA setup or hold paths for ICExplorer."
      puts "  If fix hold violation, set delay_type min. max for setup fix. min_max for setup and hold fix"
      puts "Usage  : report_pba_paths_for_icexplorer <scenario> \[dir\] \[delay_type\] \[max_paths\] \[nworst\] \[setup_threshold\] \[hold_threshold\]"
      puts "Options:"
      puts "  -scenario  : scenario name"
      puts "  -dir       : output dir, by default it's \".\""
      puts "  -delay_type: delay type, can be min, max or min_max, by default it's min"
      puts "  -max_paths : Maximum number of paths per path group to output, by default it's 100000"
      puts "  -nworst    : List N worst paths to endpoint, by default it's 10"
      puts "  -setup_threshold: Only report those paths with slack less than setup_threshold, by default it's 0.0"
      puts "  -hold_threshold : Only report those paths with slack less than hold_threshold, by default it's 0.0"
      puts "Example:"
      puts "  report_pba_paths_for_icexplorer ss min 1000 10"
      return 1
    }

    if { $topic == "check_slack_integrity" } {
      puts "Use this command to check slack integrity for pin timing. The usage is"
      puts "  check_slack_integrity scenario_name"
      puts "Result will be written into file scenario_name_slack_integrity.err"
    }
  
#     if {$topic == "report_delta_data_for_icexplorer"} {
# 	puts "Use this command to report SI timing data"
# 	puts "report_delta_data_for_icexplorer scenario_name dir_name threshold" 
# 	puts "  -scenario_name: current session or scenario name"
# 	puts "  -dir_name: the dir to store generated data, default ."
# 	puts "  -threshold: SI delta threshold"
# 	return 1
#     }
    puts ""
}

proc report_scenario_data_for_icexplorer {scenario_name {dir_name .}} {
    report_annotated_data_for_icexplorer $scenario_name $dir_name
}

proc check_fanin_and_fanout_slack { pin {type "setup"} } {
  set result ""
  set fanin_pins  [all_fanin -to $pin -pin_levels 1] 
  set filterd_pins ""
  if {$type == "setup"} {
    set filterd_pins [filter_collection $fanin_pins  "max_rise_slack != INFINITY || max_fall_slack != INFINITY"]
  } else {
    set filterd_pins [filter_collection $fanin_pins  "min_rise_slack != INFINITY || min_fall_slack != INFINITY"]
  }
  if { [sizeof_collection $filterd_pins] > 0 } {
    foreach_in_collection fp $filterd_pins {
      set pin_name [get_attribute [get_pins $fp] full_name]
      if { $pin_name != $pin } {
        lappend result $pin_name
        break
      }
    }
  }
  set filterd_pins ""
  set fanout_pins [all_fanout -from $pin -pin_levels 1]
  if {$type == "setup"} {
    set filterd_pins [filter_collection $fanout_pins  "max_rise_slack != INFINITY || max_fall_slack != INFINITY"]
  } else {
    set filterd_pins [filter_collection $fanout_pins  "min_rise_slack != INFINITY || min_fall_slack != INFINITY"]
  }
  if { [sizeof_collection $filterd_pins] > 0 } {
    foreach_in_collection fp $filterd_pins {
      set pin_name [get_attribute [get_pins $fp] full_name]
      if { $pin_name != $pin } {
        lappend result $pin_name
        break
      }
    }
  }
  return $result
}

proc check_slack_integrity {scenario_name} {
  scan [time {
  set ::_check_slack_log "${scenario_name}_check_slack.log";
  redirect -append $::_check_slack_log {echo "##################################"}
  redirect -append $::_check_slack_log {echo "#Design Name   : [get_attribute [current_design] full_name]" }
  redirect -append $::_check_slack_log {echo "#Cells  Number : [sizeof_collection [get_cells -hier * -filter "is_hierarchical == false"] ]" }
  redirect -append $::_check_slack_log {echo "#Pins   Number : [sizeof_collection [get_pins -hier * -filter "is_hierarchical == false"] ]" }
  redirect -append $::_check_slack_log {echo "##############################################################"}
  set fo [open ${scenario_name}_slack_integrity.err w]
  set write_flag 0
  ## get inf max slack pins
  scan [time {
  set pins [get_pins -quiet -hier * -filter  "is_hierarchical == false && 
                                              max_rise_slack == INFINITY &&
                                              max_fall_slack == INFINITY "]
  }] "%f microseconds to get infinity max slack pins" tm
  redirect -append $::_check_slack_log {echo [format "get infinity max slack pins use time %.3f seconds" [expr $tm/1000000]]}
  foreach_in_collection sp $pins {
    set pin_name [get_attribute [get_pins $sp] full_name ]
    set fan_in_out [check_fanin_and_fanout_slack $pin_name]
    if { [llength $fan_in_out] == 2 } {
      if { $write_flag == 0 } {
        puts $fo "## pins with infinity max slack values"
        set write_flag 1
      }
      puts $fo $pin_name
      puts $fo "  Fanin pin:  [lindex $fan_in_out 0 ]"
      puts $fo "  Fanout pin: [lindex $fan_in_out 1 ]"
    }
  }
  unset pins
  set write_flag 0
  ## get inf min slack pins
  scan [time {
  set pins [get_pins -quiet -hier * -filter  "is_hierarchical == false && 
                                              min_rise_slack == INFINITY &&
                                              min_fall_slack == INFINITY "]
  }] "%f microseconds to get infinity min slack pins" tm
  redirect -append $::_check_slack_log {echo [format "get infinity min slack pins use time %.3f seconds" [expr $tm/1000000]]}
  
  foreach_in_collection sp $pins {
    set pin_name [get_attribute [get_pins $sp] full_name ]
    set fan_in_out [check_fanin_and_fanout_slack $pin_name hold]
    if { [llength $fan_in_out] == 2 } {
      if { $write_flag == 0 } {
        puts $fo "## pins with infinity min slack values"
        set write_flag 1
      }
      puts $fo $pin_name
      puts $fo "  Fanin pin:  [lindex $fan_in_out 0 ]"
      puts $fo "  Fanout pin: [lindex $fan_in_out 1 ]"
    }
  }
  close $fo
  }] "%f microseconds to check slack integrity" tm
  redirect -append $::_check_slack_log {echo [format "check slack integrity use time %.3f seconds" [expr $tm/1000000]]}
  unset pins
}


proc report_annotated_data_for_icexplorer {scenario_name dir_name args} {
  set ::_ErrorLog "error_$scenario_name\.log"
  if { [file exists $::_ErrorLog] == 1 } {
    exec rm -rf $::_ErrorLog
  }
  exec rm -rf ${dir_name}/${scenario_name}_data_finish
  scan [time {
    set ::_logFile "dump_$scenario_name\_data.log"
    redirect $::_logFile {echo "##############################################################"}
    redirect -append $::_logFile {echo "#Design Name   : [get_attribute [current_design] full_name]" }
    redirect -append $::_logFile {echo "#Cells  Number : [sizeof_collection [get_cells -hier * -filter "is_hierarchical == false"] ]" }
    redirect -append $::_logFile {echo "#Nets   Number : [sizeof_collection [get_nets -hier * -filter "defined(total_capacitance_max)"] ]" }
    redirect -append $::_logFile {echo "#Pins   Number : [sizeof_collection [get_pins -hier * -filter "is_hierarchical == false"] ]" }
    redirect -append $::_logFile {echo "##############################################################"}
    if {$::timing_save_pin_arrival_and_slack == false} {
        set inittime [cputime %g]
        puts "Now set timing_save_pin_arrival_and_slack true and do update_timing"
        set ::timing_save_pin_arrival_and_slack true
        update_timing
        set endtime [cputime %g]
        puts [format "update_timing use time %.4f" [expr $endtime - $inittime]]
        redirect -append $::_logFile {echo [format "update_timing use time %.4f" [expr $endtime - $inittime]] }
    }

    ### output trans for sdf flow, otherwise it always output 0.0
    #catch { set ::timing_use_zero_slew_for_annotated_arcs never }

    #set_propagated_clock [all_clocks]

    # set null file 
    set nfile /dev/null

    set nogzip [no_gzip]
    
    if {$dir_name == ""} {
       set dir_name "."
    } else {
       catch {exec mkdir -p $dir_name}
    }

    # pin timing.
    scan [time {
    set fname ${dir_name}/${scenario_name}_data_pin_timing.txt
    if {[is_support_value_list]} {
       redirect -file $nfile "fastreport_pin_timing_for_icexplorer $fname"
       #redirect -file $nfile "fastreport_pin_timing_for_icexplorer_hier $fname"
    } else {
       redirect -file $nfile "report_pin_timing_for_icexplorer $fname"
    }
    }] "%f microseconds per iteration" tm
    redirect -append $::_logFile {echo [format "dump pin timing use real time %.3f seconds" [expr $tm/1000000]]}
  
    # wire(total) capacitances. name not match
    scan [time {
    set fname ${dir_name}/${scenario_name}_data_total_capacitances.txt
    if {[is_support_value_list]} {
        redirect -file $nfile "fastreport_total_capacitances_for_icexplorer $fname"
        #redirect -file $nfile "fastreport_total_capacitances_for_icexplorer_hier $fname"
    } else {
        redirect -file $nfile "report_total_capacitances_for_icexplorer $fname"
    }
    }] "%f microseconds per iteration" tm
    redirect -append $::_logFile {echo [format "dump total capacitances use real time %.3f seconds" [expr $tm/1000000]]}

    # derate.
    scan [time {
    set fname ${dir_name}/${scenario_name}_data_timing_derates.txt
    redirect -file $nfile "report_timing_derates_for_icexplorer $fname"
    if {!$nogzip} {
        zip_file $fname
    }
    }] "%f microseconds per iteration" tm
    redirect -append $::_logFile {echo [format "dump derate use real time %.3f seconds" [expr $tm/1000000]]}

    # dont touch cells or nets.
    scan [time {
    set fname ${dir_name}/${scenario_name}_data_dont_touch_objects.txt
    redirect -file $nfile "report_dont_touch_objects_for_icexplorer $fname"
    }] "%f microseconds per iteration" tm
    redirect -append $::_logFile {echo [format "dump dont touch objects use real time %.3f seconds" [expr $tm/1000000]]}

    # clock cells.
    scan [time {
    set fname ${dir_name}/${scenario_name}_data_clock_cells.txt
    redirect -file $nfile "report_clock_cells_for_icexplorer $fname"
    }] "%f microseconds per iteration" tm
    redirect -append $::_logFile {echo [format "dump clock cells use real time %.3f seconds" [expr $tm/1000000]]}
    
    # dont used as clock pins, name not match
    scan [time {
    set fname ${dir_name}/${scenario_name}_data_used_as_clocks.txt
    redirect -file $nfile "report_used_as_clock_pins_for_icexplorer $fname"
    }] "%f microseconds per iteration" tm
    redirect -append $::_logFile {echo [format "dump clock pins use real time %.3f seconds" [expr $tm/1000000]]}

    # clock group
    scan [time {
    set fname ${dir_name}/${scenario_name}_data_clock_groups.txt
    redirect -file $nfile "report_clock_groups_for_icexplorer $fname"
    }] "%f microseconds per iteration" tm
    redirect -append $::_logFile {echo [format "dump clock groups use real time %.3f second" [expr $tm/1000000]]}

    # si delta
    scan [time {
    catch {
            if {[is_support_value_list]} {
                fastreport_delta_data_for_icexplorer $scenario_name $dir_name 0.005
            } else {
                report_delta_data_for_icexplorer $scenario_name $dir_name 0.005
            }
    }
    }] "%f microseconds per iteration" tm
    redirect -append $::_logFile {echo [format "dump si delta use real time %.3f seconds" [expr $tm/1000000]]} 
    #IO objects file
    scan [time {
    set fname ${dir_name}/${scenario_name}_data_ilm_objects.txt
    if {[is_support_value_list]} {
       redirect -file $nfile "fastreport_ilm_objects_for_icexplorer $fname"
    } else {
       redirect -file $nfile "report_ilm_objects_for_icexplorer $fname"
    }
    }] "%f microseconds per iteration" tm
    redirect -append $::_logFile {echo [format "dump pin timing use real time %.3f seconds" [expr $tm/1000000]]}
    # upf data
    #set fname ${dir_name}/${scenario_name}_data_voltage_area_cells.txt
    #redirect -file $nfile "report_upf_data_for_icexplorer $fname"

    # path summary
    set fname ${dir_name}/${scenario_name}_data_path_summary.txt
   # redirect -file $nfile "report_path_summary_for_icexplorer $fname"
    if {!$nogzip} {
   #    zip_file $fname
    }
  }] "%f microseconds per iteration" tm
  redirect -append $::_logFile {echo [format "report annotated data use real time %.3f seconds" [expr $tm/1000000]]} 
  exec touch ${dir_name}/${scenario_name}_data_finish
}

##################################################################
# Get max val of two variables.
##################################################################
proc max_value {var1 var2} {
    if {$var1 > $var2} {
        return $var1
    } else {
        return $var2
    }
}

##################################################################
# Get min val of two variables.
##################################################################
proc min_value {var1 var2} {
    if {$var1 < $var2 && $var1 != ""} {
        return $var1
    } else {
        return $var2
    }
}

##################################################################
# Return true if support value_list in get_attribute.
##################################################################
proc is_support_value_list {} {
    set val false
    catch {
        set data ""
        redirect -variable data {get_attribute -help}
        foreach word $data {
            if {[string first "value_list" $word] >= 0} {
                set val true
            }
        }
    }
    return $val
}

###################################################################
# Report pin timing for icexplorer, trans, and max trans.
###################################################################
proc report_pin_timing_for_icexplorer {file_name} {
    if {[no_gzip] == 0} {
       if { [catch {open "| gzip > $file_name.gz" w} fid] } {
           puts stderr "Failed to open file: $file_name"
           return
       }
    } else {
       if { [catch {open $file_name w} fid] } {
           puts stderr "Failed to open file: $file_name"
           return
       }
    }

    current_instance

    ##Put header in it.
    puts $fid "****************************************"
    puts $fid "Report   : report_pin_timing"
    puts $fid "Design   : [get_attribute [current_design] full_name]"
    puts $fid "Vendor   : PT"
    puts $fid "Version  : 1.0"
    puts $fid "TimeUnit : [get_pt_unit time]"
    puts $fid "CapUnit  : [get_pt_unit cap]"
    puts $fid "ResUnit  : [get_pt_unit res]"
    puts $fid "****************************************"
    puts $fid "\n"
 
    ## Put colum name
    ## Default Obj_Type is Pin and can be empty, other candidates are Design
    puts $fid "Point  Setup_Slack  Hold_Slack  Setup_Trans  Hold_Trans  Max_Trans  Max_Cap  Obj_Type "
    puts $fid "--------------------------------------------------------------------------------"

    ## Report design max_transition
    set designs [get_designs *]
    foreach_in_collection dd $designs {
        puts -nonewline $fid [format "%s\t*\t*\t*\t*" [get_attribute $dd full_name] ]

        set maxtrans [get_attribute -quiet $dd max_transition]
        if {$maxtrans == ""} {
            puts -nonewline $fid "\t*" 
        } else {
            puts -nonewline $fid [format "\t%.4f" $maxtrans]
        }
        set maxcaps [get_attribute -quiet $dd max_capacitance]
        if {$maxcaps == ""} {
            puts -nonewline $fid "\t*" 
        } else {
            puts -nonewline $fid [format "\t%.4f" $maxcaps]
        }

        puts $fid "\tDesign"
    }
    unset designs

    ## iterate all ports
    set ports [get_ports *]
    foreach_in_collection pp $ports {
        puts -nonewline $fid [get_attribute $pp full_name]

        #slack
        set maxrslack [get_attribute -quiet $pp max_rise_slack]
        set maxfslack [get_attribute -quiet $pp max_fall_slack]
        set minrslack [get_attribute -quiet $pp min_rise_slack]
        set minfslack [get_attribute -quiet $pp min_fall_slack]

        set maxslack [min_value $maxrslack $maxfslack]
        if {$maxslack == "" || $maxslack == "inf"} {
            puts -nonewline $fid "\t*"
        } else {
            puts -nonewline $fid [format "\t%.6f" $maxslack]
        }

        set minslack [min_value $minrslack $minfslack]
        if {$minslack == "" || $minslack == "inf"} {
            puts -nonewline $fid "\t*"
        } else {
            puts -nonewline $fid [format "\t%.6f" $minslack]
        }


        ## transition
        set rtransitionmax [get_attribute -quiet $pp actual_rise_transition_max]
        set ftransitionmax [get_attribute -quiet $pp actual_fall_transition_max]
        set rtransitionmin [get_attribute -quiet $pp actual_rise_transition_min]
        set ftransitionmin [get_attribute -quiet $pp actual_fall_transition_min]
        set transitionmax [max_value $rtransitionmax $ftransitionmax]
        if {$transitionmax == "" || $transitionmax == "inf"} {
            puts -nonewline $fid "\t*"
        } else {
            puts -nonewline $fid [format "\t%.6f" $transitionmax]
        }

        set transitionmin [min_value $rtransitionmin $ftransitionmin]
        if {$transitionmin == "" || $transitionmin == "inf"} {
            puts -nonewline $fid "\t*"
        } else {
            puts -nonewline $fid [format "\t%.6f" $transitionmin]
        }


        ## max_transition
        set maxtransition [get_attribute -quiet $pp max_transition]
        if {$maxtransition == ""} {
            puts -nonewline $fid "\t*"
        } else {
            puts -nonewline $fid [format "\t%.6f" $maxtransition]
        }


        ## max_capacitance
        set maxcaps [get_attribute -quiet $pp max_capacitance]
        if {$maxcaps == ""} {
            puts -nonewline $fid "\t*"
        } else {
            puts -nonewline $fid [format "\t%.6f" $maxcaps]
        }

        puts $fid ""
    }

    ## iterate all cells
    set cells [get_cells *]
    foreach_in_collection pp $cells {
        report_cell_timing_for_icexplorer $pp $fid
    }

    close $fid
}

proc report_cell_timing_for_icexplorer {cell fid} {
    set baseName [get_attribute $cell base_name]
    set guessFullName [current_instance .]
    if {$guessFullName != ""} {
        append guessFullName $::hierarchy_separator $baseName
    } else {
        set guessFullName $baseName
    }
    if {$guessFullName != [get_attribute $cell full_name]} {
        redirect -append $::_ErrorLog {echo "ERROR : full_name not match '$guessFullName'   '[get_attribute $cell full_name]'"}
        return
    }


    set isHier [get_attribute $cell is_hierarchical]
    if {$isHier} {
        set pcell [get_cells -quiet $baseName ]
        if {$pcell == ""} {
            puts "Can't get cell '$baseName' which full_name is '[get_attribute $cell full_name]' in module '[current_instance .]'"
            return
        }

        puts $fid "BEGINMODULE  $guessFullName"
        current_instance $baseName

        set cells [get_cells -quiet *]
        foreach_in_collection pp $cells {
            report_cell_timing_for_icexplorer $pp $fid
        }

        puts $fid "ENDMODULE    $baseName"
        current_instance ..
    } else {
        puts $fid "$baseName"
        ## iterate all pins
        set pins [get_pins -of_object $cell]
        foreach_in_collection pp $pins {
            puts -nonewline $fid [get_attribute $pp lib_pin_name]

            #slack
            set maxrslack [get_attribute -quiet $pp max_rise_slack]
            set maxfslack [get_attribute -quiet $pp max_fall_slack]
            set minrslack [get_attribute -quiet $pp min_rise_slack]
            set minfslack [get_attribute -quiet $pp min_fall_slack]

            set maxslack [min_value $maxrslack $maxfslack]
            if {$maxslack == "" || $maxslack == "inf"} {
                puts -nonewline $fid "\t*"
            } else {
                puts -nonewline $fid [format "\t%.4f" $maxslack]
            }

            set minslack [min_value $minrslack $minfslack]
            if {$minslack == "" || $minslack == "inf"} {
                puts -nonewline $fid "\t*"
            } else {
                puts -nonewline $fid [format "\t%.4f" $minslack]
            }


            ## transition
            set rtransitionmax [get_attribute -quiet $pp actual_rise_transition_max]
            set ftransitionmax [get_attribute -quiet $pp actual_fall_transition_max]
            set rtransitionmin [get_attribute -quiet $pp actual_rise_transition_min]
            set ftransitionmin [get_attribute -quiet $pp actual_fall_transition_min]
            set transitionmax [max_value $rtransitionmax $ftransitionmax]
            if {$transitionmax == "" || $transitionmax == "inf"} {
                puts -nonewline $fid "\t*"
            } else {
                puts -nonewline $fid [format "\t%.4f" $transitionmax]
            }

            set transitionmin [min_value $rtransitionmin $ftransitionmin]
            if {$transitionmin == "" || $transitionmin == "inf"} {
                puts -nonewline $fid "\t*"
            } else {
                puts -nonewline $fid [format "\t%.4f" $transitionmin]
            }

            ## max_transition
            set maxtransition [get_attribute -quiet $pp constraining_max_transition]
            if {$maxtransition == "" || $maxtransition == "INFINITY"} {
                set maxtransition [get_attribute -quiet $pp max_transition]
            }
            if {$maxtransition == ""} {
                puts -nonewline $fid "\t*"
            } else {
                puts -nonewline $fid [format "\t%.4f" $maxtransition]
            }

            ## max_capacitance
            set maxcaps [get_attribute -quiet $pp max_capacitance]
            if {$maxcaps == ""} {
                puts -nonewline $fid "\t*"
            } else {
                puts -nonewline $fid [format "\t%.4f" $maxcaps]
            }

            puts $fid ""
        }
    }
}

###################################################################
# Fast report pin timing for icexplorer, trans, and max trans.
###################################################################
proc fastreport_pin_timing_for_icexplorer {file_name} {
    if {[no_gzip] == 0} {
       if { [catch {open "| gzip > $file_name.gz" w} fid] } {
           puts stderr "Failed to open file: $file_name"
           return
       }
    } else {
       if { [catch {open $file_name w} fid] } {
           puts stderr "Failed to open file: $file_name"
           return
       }
    }

    redirect -append $::_logFile { echo "Before report_pin_timing mem is [mem] , cputime is [cputime %g]" }

    current_instance

    ##Put header in it.
    puts $fid "****************************************"
    puts $fid "Report   : fast_report_pin_timing"
    puts $fid "Design   : [get_attribute [current_design] full_name]"
    puts $fid "Vendor   : PT"
    puts $fid "Version  : 1.0"
    puts $fid "TimeUnit : [get_pt_unit time]"
    puts $fid "CapUnit  : [get_pt_unit cap]"
    puts $fid "ResUnit  : [get_pt_unit res]"
    puts $fid "****************************************"
 
    ## for designs
    puts $fid "\n#Design  design_name  max_transition  max_capacitance"
    set designs [get_designs *]
    foreach_in_collection dd $designs {
        puts -nonewline $fid [format "%s" [get_attribute $dd full_name] ]

        set maxtrans [get_attribute -quiet $dd max_transition]
        if {$maxtrans == ""} {
            puts -nonewline $fid "\t*" 
        } else {
            puts -nonewline $fid [format "\t%.4f" $maxtrans]
        }
        set maxcaps [get_attribute -quiet $dd max_capacitance]
        if {$maxcaps == ""} {
            puts $fid "\t*" 
        } else {
            puts $fid [format "\t%.4f" $maxcaps]
        }
    }
    unset designs

    set cutnum 100000

    if {!$::_useConstraintMaxTransition} {
        ## for pins max_transition
        redirect -append $::_logFile { echo "Before report max_trans mem is [mem] , cputime is [cputime %g]" }
        set pins [get_pins -hier * -filter "is_hierarchical == false && defined(max_transition)"]
        puts $fid "\n#MaxTransitin pins max_transition [sizeof_collection $pins]"
        set datas [get_attribute -value_list $pins full_name]
        puts $fid "#pins_name [llength $datas]"
        set number [llength $datas]
        set iternum [expr $number/$cutnum]
        for {set x 0} {$x <= $iternum} {incr x} {
            set tmp [lrange $datas [expr $x * $cutnum] [expr (($x+1) * $cutnum) - 1]]
            set tmp [string map {" " "\n" "{" "" "}" ""} $tmp]
            puts $fid $tmp
        }
        unset datas
        redirect -append $::_logFile { echo "After  report max_trans name mem is [mem] , cputime is [cputime %g]" }

        set datas [get_attribute -quiet -value_list $pins constraining_max_transition]
        if {[llength $datas] == [sizeof_collection $pins] } {
            puts $fid "#max_transition [llength $datas]"
            set number [llength $datas]
            set iternum [expr $number/$cutnum]
            for {set x 0} {$x <= $iternum} {incr x} {
                set tmp [lrange $datas [expr $x * $cutnum] [expr (($x+1) * $cutnum) - 1]]
                set tmp [string map {" " "\n"} $tmp]
                puts $fid $tmp
            }
        } else {
            set datas [get_attribute -value_list $pins max_transition]
            puts $fid "#max_transition [llength $datas]"
            set number [llength $datas]
            set iternum [expr $number/$cutnum]
            for {set x 0} {$x <= $iternum} {incr x} {
                set tmp [lrange $datas [expr $x * $cutnum] [expr (($x+1) * $cutnum) - 1]]
                set tmp [string map {" " "\n"} $tmp]
                puts $fid $tmp
            }
        }
        unset datas
    } else {
        ## for max_transition, now using report_constraint -max_transition
        redirect -append $::_logFile { echo "Before report max_trans mem is [mem] , cputime is [cputime %g]" }
        puts $fid "\n#ConstraintMaxTransition"
        redirect -channel $fid {report_constraint -max_transition -sig 4 -nosplit [get_pins -hier *]}
        redirect -append $::_logFile { echo "After  report max_trans data mem is [mem] , cputime is [cputime %g]" }
    }

    ## for ports
    report_ports_timing_for_icexplorer $fid
    redirect -append $::_logFile { echo "After  report ports data mem is [mem] , cputime is [cputime %g]" }

    ## for pins slack and transition
    ## in general, pt always define slack and transition attribute on pin
    set pins ""
    if {$::_skipCaseValuePins} {
        set pins [get_pins -quiet -hier * -filter "is_hierarchical == false && \
                                        defined(max_rise_slack) && defined(max_fall_slack) && \
                                        defined(min_rise_slack) && defined(min_fall_slack) && \
                                        defined(actual_rise_transition_max) && \
                                        defined(actual_fall_transition_max) && \
                                        defined(actual_rise_transition_min) && \
                                        defined(actual_fall_transition_min) && \
                                         (undefined(case_value) || \
                                         (defined(case_value) && case_value != 0 && case_value != 1))"]
    } else {
        set pins [get_pins -quiet -hier * -filter "is_hierarchical == false && \
                                        defined(max_rise_slack) && defined(max_fall_slack) && \
                                        defined(min_rise_slack) && defined(min_fall_slack) && \
                                        defined(actual_rise_transition_max) && \
                                        defined(actual_fall_transition_max) && \
                                        defined(actual_rise_transition_min) && \
                                        defined(actual_fall_transition_min)"]
    }

    redirect -append $::_logFile { echo "Before report slack_trans data mem is [mem] , cputime is [cputime %g]" }
    puts $fid "\n#SlackAndTransition pins max_rise_slack max_fall_slack min_rise_slack min_fall_slack actual_rise_transition_max actual_fall_transition_max actual_rise_transition_min actual_fall_transition_min [sizeof_collection $pins]"
    set datas [get_attribute -quiet -value_list $pins full_name]
    puts $fid "#pins_name [llength $datas]"
    set number [llength $datas]
    set iternum [expr $number/$cutnum]
    for {set x 0} {$x <= $iternum} {incr x} {
        set tmp [lrange $datas [expr $x * $cutnum] [expr (($x+1) * $cutnum) - 1]]
        set tmp [string map {" " "\n" "{" "" "}" ""} $tmp]
        puts $fid $tmp
    }
    unset datas
    redirect -append $::_logFile { echo "After  report slack_trans name mem is [mem] , cputime is [cputime %g]" }

    set datas [get_attribute -quiet -value_list $pins max_rise_slack]
    puts $fid "#max_rise_slack [llength $datas]"
    set number [llength $datas]
    set iternum [expr $number/$cutnum]
    for {set x 0} {$x <= $iternum} {incr x} {
        set tmp [lrange $datas [expr $x * $cutnum] [expr (($x+1) * $cutnum) - 1]]
        set tmp [string map {" " "\n"} $tmp]
        puts $fid $tmp
    }
    unset datas
    redirect -append $::_logFile { echo "After  report max_rise_slack mem is [mem] , cputime is [cputime %g]" }


    set datas [get_attribute -quiet -value_list $pins max_fall_slack]
    puts $fid "#max_fall_slack [llength $datas]"
    set number [llength $datas]
    set iternum [expr $number/$cutnum]
    for {set x 0} {$x <= $iternum} {incr x} {
        set tmp [lrange $datas [expr $x * $cutnum] [expr (($x+1) * $cutnum) - 1]]
        set tmp [string map {" " "\n"} $tmp]
        puts $fid $tmp
    }
    unset datas
    redirect -append $::_logFile { echo "After  report max_fall_slack mem is [mem] , cputime is [cputime %g]" }

    set datas [get_attribute -quiet -value_list $pins min_rise_slack]
    puts $fid "#min_rise_slack [llength $datas]"
    set number [llength $datas]
    set iternum [expr $number/$cutnum]
    for {set x 0} {$x <= $iternum} {incr x} {
        set tmp [lrange $datas [expr $x * $cutnum] [expr (($x+1) * $cutnum) - 1]]
        set tmp [string map {" " "\n"} $tmp]
        puts $fid $tmp
    }
    unset datas
    redirect -append $::_logFile { echo "After  report min_rise_slack mem is [mem] , cputime is [cputime %g]" }

    set datas [get_attribute -quiet -value_list $pins min_fall_slack]
    puts $fid "#min_fall_slack [llength $datas]"
    set number [llength $datas]
    set iternum [expr $number/$cutnum]
    for {set x 0} {$x <= $iternum} {incr x} {
        set tmp [lrange $datas [expr $x * $cutnum] [expr (($x+1) * $cutnum) - 1]]
        set tmp [string map {" " "\n"} $tmp]
        puts $fid $tmp
    }
    unset datas
    redirect -append $::_logFile { echo "After  report min_fall_slack mem is [mem] , cputime is [cputime %g]" }

    set datas [get_attribute -quiet -value_list $pins actual_rise_transition_max]
    puts $fid "#actual_rise_transition_max [llength $datas]"
    set number [llength $datas]
    set iternum [expr $number/$cutnum]
    for {set x 0} {$x <= $iternum} {incr x} {
        set tmp [lrange $datas [expr $x * $cutnum] [expr (($x+1) * $cutnum) - 1]]
        set tmp [string map {" " "\n"} $tmp]
        puts $fid $tmp
    }
    unset datas
    redirect -append $::_logFile { echo "After  report setup_rise_trans mem is [mem] , cputime is [cputime %g]" }

    set datas [get_attribute -quiet -value_list $pins actual_fall_transition_max]
    puts $fid "#actual_fall_transition_max [llength $datas]"
    set number [llength $datas]
    set iternum [expr $number/$cutnum]
    for {set x 0} {$x <= $iternum} {incr x} {
        set tmp [lrange $datas [expr $x * $cutnum] [expr (($x+1) * $cutnum) - 1]]
        set tmp [string map {" " "\n"} $tmp]
        puts $fid $tmp
    }
    unset datas
    redirect -append $::_logFile { echo "After  report setup_fall_trans mem is [mem] , cputime is [cputime %g]" }

    set datas [get_attribute -quiet -value_list $pins actual_rise_transition_min]
    puts $fid "#actual_rise_transition_min [llength $datas]"
    set number [llength $datas]
    set iternum [expr $number/$cutnum]
    for {set x 0} {$x <= $iternum} {incr x} {
        set tmp [lrange $datas [expr $x * $cutnum] [expr (($x+1) * $cutnum) - 1]]
        set tmp [string map {" " "\n"} $tmp]
        puts $fid $tmp
    }
    unset datas
    redirect -append $::_logFile { echo "After  report hold_rise_trans mem is [mem] , cputime is [cputime %g]" }

    set datas [get_attribute -quiet -value_list $pins actual_fall_transition_min]
    puts $fid "#actual_fall_transition_min [llength $datas]"
    set number [llength $datas]
    set iternum [expr $number/$cutnum]
    for {set x 0} {$x <= $iternum} {incr x} {
        set tmp [lrange $datas [expr $x * $cutnum] [expr (($x+1) * $cutnum) - 1]]
        set tmp [string map {" " "\n"} $tmp]
        puts $fid $tmp
    }
    unset datas
    redirect -append $::_logFile { echo "After  report hold_fall_trans mem is [mem] , cputime is [cputime %g]" }

    ## for pins max_capacitance
    set pins [get_pins -hier * -filter "is_hierarchical == false && defined(max_capacitance)"]
    puts $fid "\n#MaxCapacitance pins max_capacitance [sizeof_collection $pins]"
    set datas [get_attribute -quiet -value_list $pins full_name]
    puts $fid "#pins_name [llength $datas]"
    set number [llength $datas]
    set iternum [expr $number/$cutnum]
    for {set x 0} {$x <= $iternum} {incr x} {
        set tmp [lrange $datas [expr $x * $cutnum] [expr (($x+1) * $cutnum) - 1]]
        set tmp [string map {" " "\n" "{" "" "}" ""} $tmp]
        puts $fid $tmp
    }
    unset datas
    redirect -append $::_logFile { echo "After  report max_cap name mem is [mem] , cputime is [cputime %g]" }

    set datas [get_attribute -quiet -value_list $pins max_capacitance]
    puts $fid "#max_capacitance [llength $datas]"
    set datas [string map {" " "\n"} $datas]
    puts $fid $datas
    redirect -append $::_logFile { echo "After  report max_cap data mem is [mem] , cputime is [cputime %g]" }

    unset pins
    unset datas

    close $fid
}

###################################################################
# Report pin timing for icexplorer, trans, and max trans.
###################################################################
proc fastreport_pin_timing_for_icexplorer_hier {file_name} {
    if {[no_gzip] == 0} {
       if { [catch {open "| gzip > $file_name.gz" w} fid] } {
           puts stderr "Failed to open file: $file_name"
           return
       }
    } else {
       if { [catch {open $file_name w} fid] } {
           puts stderr "Failed to open file: $file_name"
           return
       }
    }

    redirect $::_logFile { echo "Before fast report hier pin data mem is [mem] , cputime is [cputime %g]" }

    current_instance

    ##Put header in it.
    puts $fid "****************************************"
    puts $fid "Report   : fast_report_pin_timing_hier"
    puts $fid "Design   : [get_attribute [current_design] full_name]"
    puts $fid "Vendor   : PT"
    puts $fid "Version  : 1.0"
    puts $fid "TimeUnit : [get_pt_unit time]"
    puts $fid "CapUnit  : [get_pt_unit cap]"
    puts $fid "ResUnit  : [get_pt_unit res]"
    puts $fid "****************************************"
 
    ## for designs
    puts $fid "\n#Design  design_name  max_transition  max_capacitance"
    set designs [get_designs *]
    foreach_in_collection dd $designs {
        puts -nonewline $fid [format "%s" [get_attribute $dd full_name] ]

        set maxtrans [get_attribute -quiet $dd max_transition]
        if {$maxtrans == ""} {
            puts -nonewline $fid "\t*" 
        } else {
            puts -nonewline $fid [format "\t%.4f" $maxtrans]
        }
        set maxcaps [get_attribute -quiet $dd max_capacitance]
        if {$maxcaps == ""} {
            puts $fid "\t*" 
        } else {
            puts $fid [format "\t%.4f" $maxcaps]
        }
    }
    unset designs

    ## report data for ports
    report_ports_timing_for_icexplorer $fid

    ## report data for hierarchy cells
    set hiercells [get_cells -quiet * -filter "is_hierarchical == true"]
    foreach_in_collection cell $hiercells {
        report_hiercell_timing_for_icexplorer $cell $fid
    }

    ## report data for non-hierarchy pins
    set allpins [get_pins -quiet * -filter "is_hierarchical == false"]
    report_pins_timing_for_icexplorer $allpins $fid

    redirect -append $::_logFile { echo "After  fast report hier pin data mem is [mem] , cputime is [cputime %g]" }

    close $fid
}

proc report_hiercell_timing_for_icexplorer {cell fid} {
    set baseName [get_attribute $cell base_name]
    set guessFullName [current_instance .]
    if {$guessFullName != ""} {
        append guessFullName $::hierarchy_separator $baseName
    } else {
        set guessFullName $baseName
    }
    if {$guessFullName != [get_attribute $cell full_name]} {
        redirect -append $::_ErrorLog { echo "ERROR : full_name not match '$guessFullName'   '[get_attribute $cell full_name]'" }
        return
    }

    current_instance $baseName
    set allpins [get_pins -quiet -hier * -filter "is_hierarchical == false"]
    #puts $fid "BEGINMODULE  $guessFullName [sizeof_collection $allpins]"

    if {[sizeof_collection $allpins] > $::_maxObjsNumber} {
        set hiercells [get_cells -quiet * -filter "is_hierarchical == true"]
        foreach_in_collection inst $hiercells {
            report_hiercell_timing_for_icexplorer $inst $fid
        }

        set allpins [get_pins -quiet * -filter "is_hierarchical == false"]
        report_pins_timing_for_icexplorer $allpins $fid
    } else {
        report_pins_timing_for_icexplorer $allpins $fid
    }

    #puts $fid "ENDMODULE    $baseName"
    current_instance ..
}

proc report_pins_timing_for_icexplorer {gpins fid} {
    if {[sizeof_collection $gpins] == 0} {
        return
    }
    redirect -append $::_logFile { echo "Before report [sizeof_collection $gpins] pins data mem is [mem] , cputime is [cputime %g]" }

    if {!$::_useConstraintMaxTransition} {
        ## for pins max_transition
        set pins [filter_collection $gpins "is_hierarchical == false && defined(max_transition)"]
        puts $fid "\n#MaxTransitin pins max_transition [sizeof_collection $pins]"
        set datas [get_attribute -value_list $pins full_name]
        puts $fid "#pins_name [llength $datas]"
        set tmp [string map {" " "\n" "{" "" "}" ""} $datas]
        puts $fid $tmp
        unset datas

        set datas [get_attribute -quiet -value_list $pins constraining_max_transition]                         
        if {[llength $datas] == [sizeof_collection $pins] } {                                                  
            puts $fid "#max_transition [llength $datas]"
            set tmp [string map {" " "\n"} $datas]
            puts $fid $tmp
        } else {
            set datas [get_attribute -value_list $pins max_transition]
            puts $fid "#max_transition [llength $datas]"
            set tmp [string map {" " "\n"} $datas]
            puts $fid $tmp
        }
        unset datas
    } else {
        ## for max_transition, now using report_constraint -max_transition
        puts $fid "\n#ConstraintMaxTransition"
        redirect -channel $fid {report_constraint -max_transition -sig 4 -nosplit $gpins}
    }

    ## for pins slack and transition
    ## in general, pt always define slack and transition attribute on pin
    set pins ""
    if {$::_skipCaseValuePins} {
        set pins [filter_collection $gpins "is_hierarchical == false && \
                                        defined(max_rise_slack) && defined(max_fall_slack) && \
                                        defined(min_rise_slack) && defined(min_fall_slack) && \
                                        defined(actual_rise_transition_max) && \
                                        defined(actual_fall_transition_max) && \
                                        defined(actual_rise_transition_min) && \
                                        defined(actual_fall_transition_min) && \
                                         (undefined(case_value) || \
                                         (defined(case_value) && case_value != 0 && case_value != 1))"]
    } else {
        set pins [filter_collection $gpins "is_hierarchical == false && \
                                        defined(max_rise_slack) && defined(max_fall_slack) && \
                                        defined(min_rise_slack) && defined(min_fall_slack) && \
                                        defined(actual_rise_transition_max) && \
                                        defined(actual_fall_transition_max) && \
                                        defined(actual_rise_transition_min) && \
                                        defined(actual_fall_transition_min)"]
    }

    puts $fid "\n#SlackAndTransition pins max_rise_slack max_fall_slack min_rise_slack min_fall_slack actual_rise_transition_max actual_fall_transition_max actual_rise_transition_min actual_fall_transition_min [sizeof_collection $pins]"
    set datas [get_attribute -quiet -value_list $pins full_name]
    puts $fid "#pins_name [llength $datas]"
    set tmp [string map {" " "\n" "{" "" "}" ""} $datas]
    puts $fid $tmp
    unset datas

    set datas [get_attribute -quiet -value_list $pins max_rise_slack]
    puts $fid "#max_rise_slack [llength $datas]"
    set tmp [string map {" " "\n"} $datas]
    puts $fid $tmp
    unset datas

    set datas [get_attribute -quiet -value_list $pins max_fall_slack]
    puts $fid "#max_fall_slack [llength $datas]"
    set tmp [string map {" " "\n"} $datas]
    puts $fid $tmp
    unset datas

    set datas [get_attribute -quiet -value_list $pins min_rise_slack]
    puts $fid "#min_rise_slack [llength $datas]"
    set tmp [string map {" " "\n"} $datas]
    puts $fid $tmp
    unset datas

    set datas [get_attribute -quiet -value_list $pins min_fall_slack]
    puts $fid "#min_fall_slack [llength $datas]"
    set tmp [string map {" " "\n"} $datas]
    puts $fid $tmp
    unset datas

    set datas [get_attribute -quiet -value_list $pins actual_rise_transition_max]
    puts $fid "#actual_rise_transition_max [llength $datas]"
    set tmp [string map {" " "\n"} $datas]
    puts $fid $tmp
    unset datas

    set datas [get_attribute -quiet -value_list $pins actual_fall_transition_max]
    puts $fid "#actual_fall_transition_max [llength $datas]"
    set tmp [string map {" " "\n"} $datas]
    puts $fid $tmp
    unset datas

    set datas [get_attribute -quiet -value_list $pins actual_rise_transition_min]
    puts $fid "#actual_rise_transition_min [llength $datas]"
    set tmp [string map {" " "\n"} $datas]
    puts $fid $tmp
    unset datas

    set datas [get_attribute -quiet -value_list $pins actual_fall_transition_min]
    puts $fid "#actual_fall_transition_min [llength $datas]"
    set tmp [string map {" " "\n"} $datas]
    puts $fid $tmp
    unset datas


    ## for pins max_capacitance
    set pins [filter_collection $gpins "is_hierarchical == false && defined(max_capacitance)"]
    puts $fid "\n#MaxCapacitance pins max_capacitance [sizeof_collection $pins]"
    set datas [get_attribute -quiet -value_list $pins full_name]
    puts $fid "#pins_name [llength $datas]"
    set tmp [string map {" " "\n" "{" "" "}" ""} $datas]
    puts $fid $tmp
    unset datas

    set datas [get_attribute -quiet -value_list $pins max_capacitance]
    puts $fid "#max_capacitance [llength $datas]"
    set datas [string map {" " "\n"} $datas]
    puts $fid $datas

    unset pins
    unset datas
    redirect -append $::_logFile { echo "After  report [sizeof_collection $gpins] pins data mem is [mem] , cputime is [cputime %g]" }
}

proc report_ports_timing_for_icexplorer {fid} {
    ## for ports
    puts $fid "\n#Port port_name Setup_Slack  Hold_Slack  Setup_Trans  Hold_Trans  Max_Trans  Max_Cap"
    set ports [get_ports *]
    foreach_in_collection pp $ports {
        puts -nonewline $fid [get_attribute $pp full_name]

        #slack
        set maxrslack [get_attribute -quiet $pp max_rise_slack]
        set maxfslack [get_attribute -quiet $pp max_fall_slack]
        set minrslack [get_attribute -quiet $pp min_rise_slack]
        set minfslack [get_attribute -quiet $pp min_fall_slack]
        set maxslack [min_value $maxrslack $maxfslack]
        if {$maxslack == "" || $maxslack == "inf"} {
            puts -nonewline $fid "\t*"
        } else {
            puts -nonewline $fid [format "\t%.6f" $maxslack]
        }
        set minslack [min_value $minrslack $minfslack]
        if {$minslack == "" || $minslack == "inf"} {
            puts -nonewline $fid "\t*"
        } else {
            puts -nonewline $fid [format "\t%.6f" $minslack]
        }

        ## transition
        set rtransitionmax [get_attribute -quiet $pp actual_rise_transition_max]
        set ftransitionmax [get_attribute -quiet $pp actual_fall_transition_max]
        set rtransitionmin [get_attribute -quiet $pp actual_rise_transition_min]
        set ftransitionmin [get_attribute -quiet $pp actual_fall_transition_min]
        set transitionmax [max_value $rtransitionmax $ftransitionmax]
        if {$transitionmax == "" || $transitionmax == "inf"} {
            puts -nonewline $fid "\t*"
        } else {
            puts -nonewline $fid [format "\t%.6f" $transitionmax]
        }
        set transitionmin [min_value $rtransitionmin $ftransitionmin]
        if {$transitionmin == "" || $transitionmin == "inf"} {
            puts -nonewline $fid "\t*"
        } else {
            puts -nonewline $fid [format "\t%.6f" $transitionmin]
        }

        ## max_transition
        set maxtransition [get_attribute -quiet $pp max_transition]
        if {$maxtransition == ""} {
            puts -nonewline $fid "\t*"
        } else {
            puts -nonewline $fid [format "\t%.6f" $maxtransition]
        }
        ## max_capacitance
        set maxcaps [get_attribute -quiet $pp max_capacitance]
        if {$maxcaps == ""} {
            puts -nonewline $fid "\t*"
        } else {
            puts -nonewline $fid [format "\t%.6f" $maxcaps]
        }

        puts $fid ""
    }
    unset ports
}


proc report_annotated_transition_for_pt {file_name} {
    if {[no_gzip] == 0} {
       if { [catch {open "| gzip > $file_name.gz" w} fid] } {
           puts stderr "Failed to open file: $file_name"
           return
       }
    } else {
       if { [catch {open $file_name w} fid] } {
           puts stderr "Failed to open file: $file_name"
           return
       }
    }

    set pins [get_pins -hierarchical * -filter "defined(actual_rise_transition_max) && defined(actual_fall_transition_max)"]
    foreach_in_collection {pin} $pins {
        puts $fid "set_annotated_transition -max -rise [get_attribute $pin actual_rise_transition_max] [get_attribute $pin full_name]"
        puts $fid "set_annotated_transition -max -fall [get_attribute $pin actual_fall_transition_max] [get_attribute $pin full_name]"
    }

    set pins [get_pins -hierarchical * -filter "defined(actual_rise_transition_min) && defined(actual_fall_transition_min)"]
    foreach_in_collection {pin} $pins {
        puts $fid "set_annotated_transition -min -rise [get_attribute $pin actual_rise_transition_min] [get_attribute $pin full_name]"
        puts $fid "set_annotated_transition -min -fall [get_attribute $pin actual_fall_transition_min] [get_attribute $pin full_name]"
    }

    close $fid
}

proc report_load_for_pt {file_name} {
    if { [catch {open $file_name w} fid] } {
        puts stderr "Failed to open file: $file_name"
        return
    }

    set nets [get_nets -hierarchical * -filter "defined(wire_capacitance_max)"]
    foreach_in_collection {net} $nets {
        puts $fid "set_load -max [get_attribute $net wire_capacitance_max] [get_attribute $net full_name]"
    }

    set nets [get_nets -hierarchical * -filter "defined(wire_capacitance_min)"]
    foreach_in_collection {net} $nets {
        puts $fid "set_load -min [get_attribute $net wire_capacitance_min] [get_attribute $net full_name]"
    }

    close $fid
}

######################################################
# Report total cap of nets.
######################################################
proc report_total_capacitances_for_icexplorer {file_name} {
    if {[no_gzip] == 0} {
       if { [catch {open "| gzip > $file_name.gz" w} fid] } {
           puts stderr "Failed to open file: $file_name"
           return
       }
    } else {
       if { [catch {open $file_name w} fid] } {
           puts stderr "Failed to open file: $file_name"
           return
       }
    }

    current_instance 

    ##Put header in it.
    puts $fid "****************************************"
    puts $fid "Report  : report_total_capacitance"
    puts $fid "Design  : [get_attribute [current_design] full_name]"
    puts $fid "Vendor  : PT"
    puts $fid "Version : 1.0"
    puts $fid "CapUnit : [get_pt_unit cap]"
    puts $fid "ResUnit : [get_pt_unit res]"
    puts $fid "****************************************"
    puts $fid "\n"

    ## Default Type is Net and can be empty, other candidates are Port
    puts $fid "Name  Total_Cap_Max  Total_Cap_Min  Wire_Cap_Max  Wire_Cap_Min  Total_Res_Max  Total_Res_Min  Type"
    puts $fid "--------------------------------------------------------------------------------"

    set ports [get_ports * -filter "defined(pin_capacitance_max) || defined(pin_capacitance_min)"]
    foreach_in_collection pp $ports {
        set cap_max [get_attribute -quiet $pp pin_capacitance_max]
        set cap_min [get_attribute -quiet $pp pin_capacitance_min]
        if {$cap_max == ""} {
           set cap_max $cap_min
        }
        if {$cap_min == ""} {
           set cap_min $cap_max
        }

        puts $fid [format "%s\t%.6f\t%.6f\t*\t*\t*\t*\tPort" \
                       [get_attribute $pp full_name] \
                       $cap_max \
                       $cap_min ]
    }
    unset ports


    ## puts nets in top module
    set nets [get_nets * -filter "defined(total_capacitance_max) || defined(total_capacitance_min)"]
    foreach_in_collection pp $nets {
        ## name
        puts -nonewline $fid [get_attribute $pp base_name]

        ## total_cap
        set total_max [get_attribute -quiet $pp total_capacitance_max]
        if {$total_max == ""} {
           puts -nonewline $fid "\t*"
        } else {
           puts -nonewline $fid [format "\t%.4f" $total_max]
        }
        set total_min [get_attribute -quiet $pp total_capacitance_min]
        if {$total_min == ""} {
           puts -nonewline $fid "\t*"
        } else {
           puts -nonewline $fid [format "\t%.4f" $total_min]
        }

        ## wire_cap
        set wire_max [get_attribute -quiet $pp wire_capacitance_max]
        if {$wire_max == ""} {
           puts -nonewline $fid "\t*"
        } else {
           puts -nonewline $fid [format "\t%.4f" $wire_max]
        }
        set wire_min [get_attribute -quiet $pp wire_capacitance_min]
        if {$wire_min == ""} {
           puts -nonewline $fid "\t*"
        } else {
           puts -nonewline $fid [format "\t%.4f" $wire_min]
        }

        ## total_resistance
        set res_max [get_attribute -quiet $pp net_resistance_max]
        if {$res_max == ""} {
           puts -nonewline $fid "\t*"
        } else {
           puts -nonewline $fid [format "\t%.4f" $res_max]
        }
        set res_min [get_attribute -quiet $pp net_resistance_min]
        if {$res_min == ""} {
           puts $fid "\t*"
        } else {
           puts $fid [format "\t%.4f" $res_min]
        }
    }
    unset nets

    ## iterate hierarchical cells in top module
    set cells [get_cells * -filter "is_hierarchical == true"]
    foreach_in_collection pp $cells {
        report_cell_capacitances_for_icexplorer $pp $fid 
    }

    close $fid
}

proc report_cell_capacitances_for_icexplorer {cell fid} {
    set baseName [get_attribute $cell base_name]
    set guessFullName [current_instance .]
    if {$guessFullName != ""} {
        append guessFullName $::hierarchy_separator $baseName
    } else {
        set guessFullName $baseName
    }
    if {$guessFullName != [get_attribute $cell full_name]} {
        redirect -append $::_ErrorLog {echo "ERROR : full_name not match '$guessFullName'   '[get_attribute $cell full_name]'" }
        return
    }


    set isHier [get_attribute $cell is_hierarchical]
    if {$isHier} {
        puts $fid "BEGINMODULE  [get_attribute $cell full_name] "
        current_instance $baseName

        ## puts nets in current module
        set nets [get_nets -quiet * -filter "defined(total_capacitance_max) || defined(total_capacitance_min)"]
        foreach_in_collection pp $nets {
            set tmpName $guessFullName
            append tmpName $::hierarchy_separator [get_attribute $pp base_name]
            if {$tmpName != [get_attribute $pp full_name]} {
                continue
            }

            ## name
            puts -nonewline $fid [get_attribute $pp base_name]

            ## total_cap
            set total_max [get_attribute -quiet $pp total_capacitance_max]
            if {$total_max == ""} {
               puts -nonewline $fid "\t*"
            } else {
               puts -nonewline $fid [format "\t%.4f" $total_max]
            }
            set total_min [get_attribute -quiet $pp total_capacitance_min]
            if {$total_min == ""} {
               puts -nonewline $fid "\t*"
            } else {
               puts -nonewline $fid [format "\t%.4f" $total_min]
            }

            ## wire_cap
            set wire_max [get_attribute -quiet $pp wire_capacitance_max]
            if {$wire_max == ""} {
               puts -nonewline $fid "\t*"
            } else {
               puts -nonewline $fid [format "\t%.4f" $wire_max]
            }
            set wire_min [get_attribute -quiet $pp wire_capacitance_min]
            if {$wire_min == ""} {
               puts -nonewline $fid "\t*"
            } else {
               puts -nonewline $fid [format "\t%.4f" $wire_min]
            }

            ## total_resistance
            set res_max [get_attribute -quiet $pp net_resistance_max]
            if {$res_max == ""} {
               puts -nonewline $fid "\t*"
            } else {
               puts -nonewline $fid [format "\t%.4f" $res_max]
            }
            set res_min [get_attribute -quiet $pp net_resistance_min]
            if {$res_min == ""} {
               puts $fid "\t*"
            } else {
               puts $fid [format "\t%.4f" $res_min]
            }
        }

        ## iterate hierarchical cells in current module
        set cells [get_cells * -quiet -filter "is_hierarchical == true"]
        foreach_in_collection pp $cells {
            report_cell_capacitances_for_icexplorer $pp $fid 
        }

        puts $fid "ENDMODULE    [get_attribute $cell base_name] "
        current_instance ..
    }
}

######################################################
# Fast report total cap of nets.
######################################################
proc fastreport_total_capacitances_for_icexplorer {file_name} {
    if {[no_gzip] == 0} {
       if { [catch {open "| gzip > $file_name.gz" w} fid] } {
           puts stderr "Failed to open file: $file_name"
           return
       }
    } else {
       if { [catch {open $file_name w} fid] } {
           puts stderr "Failed to open file: $file_name"
           return
       }
    }
    redirect -append $::_logFile { echo "Before report net_cap data mem is [mem] , cputime is [cputime %g]" }

    current_instance 

    ##Put header in it.
    puts $fid "****************************************"
    puts $fid "Report  : fast_report_total_capacitance"
    puts $fid "Design  : [get_attribute [current_design] full_name]"
    puts $fid "Vendor  : PT"
    puts $fid "Version : 1.0"
    puts $fid "CapUnit : [get_pt_unit cap]"
    puts $fid "ResUnit : [get_pt_unit res]"
    puts $fid "****************************************"

    ## for ports
    puts $fid "\n#Port port_name pin_capacitance_max pin_capacitance_min"
    set ports [get_ports * -filter "defined(pin_capacitance_max) || defined(pin_capacitance_min)"]
    foreach_in_collection pp $ports {
        set cap_max [get_attribute -quiet $pp pin_capacitance_max]
        set cap_min [get_attribute -quiet $pp pin_capacitance_min]
        if {$cap_max == ""} { set cap_max $cap_min }
        if {$cap_min == ""} { set cap_min $cap_max }
        puts $fid [format "%s\t%.6f\t%.6f" \
                       [get_attribute $pp full_name] \
                       $cap_max \
                       $cap_min ]
    }
    unset ports


    ## for nets rc_annotated_segment == true 
    set nets [get_nets -hier * -filter " \
                                  defined(total_capacitance_max) && defined(total_capacitance_min) && \
                                  defined(wire_capacitance_max) && defined(wire_capacitance_min) && \
                                  defined(net_resistance_max) && defined(net_resistance_min)"]
    puts $fid "\n#NetCaps nets total_capacitance_max total_capacitance_min wire_capacitance_max wire_capacitance_min net_resistance_max net_resistance_min [sizeof_collection $nets]"

    set datas [get_attribute -value_list $nets full_name]
    puts $fid "#nets_name [llength $datas]"
    set cutnum 100000
    set number [llength $datas]
    set iternum [expr $number/$cutnum]
    for {set x 0} {$x <= $iternum} {incr x} {
        set tmp [lrange $datas [expr $x * $cutnum] [expr (($x+1) * $cutnum) - 1]]
        set tmp [string map {" " "\n" "{" "" "}" ""} $tmp]
        puts $fid $tmp
    }
    unset datas
    redirect -append $::_logFile { echo "After  report net_cap name mem is [mem] , cputime is [cputime %g]" }

    set datas [get_attribute -value_list $nets total_capacitance_max]
    puts $fid "#total_capacitance_max [llength $datas]"
    set datas [string map {" " "\n"} $datas]
    puts $fid $datas
    unset datas
    redirect -append $::_logFile { echo "After  report total_cap_max name mem is [mem] , cputime is [cputime %g]" }

    set datas [get_attribute -value_list $nets total_capacitance_min]
    puts $fid "#total_capacitance_min [llength $datas]"
    set datas [string map {" " "\n"} $datas]
    puts $fid $datas
    unset datas
    redirect -append $::_logFile { echo "After  report total_cap_min name mem is [mem] , cputime is [cputime %g]" }

    set datas [get_attribute -value_list $nets wire_capacitance_max]
    puts $fid "#wire_capacitance_max [llength $datas]"
    set datas [string map {" " "\n"} $datas]
    puts $fid $datas
    unset datas
    redirect -append $::_logFile { echo "After  report wire_cap_max name mem is [mem] , cputime is [cputime %g]" }

    set datas [get_attribute -value_list $nets wire_capacitance_min]
    puts $fid "#wire_capacitance_min [llength $datas]"
    set datas [string map {" " "\n"} $datas]
    puts $fid $datas
    unset datas
    redirect -append $::_logFile { echo "After  report wire_cap_min name mem is [mem] , cputime is [cputime %g]" }

    set datas [get_attribute -value_list $nets net_resistance_max]
    puts $fid "#net_resistance_max [llength $datas]"
    set datas [string map {" " "\n"} $datas]
    puts $fid $datas
    unset datas
    redirect -append $::_logFile { echo "After  report net_res_max name mem is [mem] , cputime is [cputime %g]" }

    set datas [get_attribute -value_list $nets net_resistance_min]
    puts $fid "#net_resistance_min [llength $datas]"
    set datas [string map {" " "\n"} $datas]
    puts $fid $datas
    unset datas
    redirect -append $::_logFile { echo "After  report net_res_min name mem is [mem] , cputime is [cputime %g]" }

    unset nets

    close $fid
}

######################################################
# Report total cap of nets.
######################################################
proc fastreport_total_capacitances_for_icexplorer_hier {file_name} {
    if {[no_gzip] == 0} {
       if { [catch {open "| gzip > $file_name.gz" w} fid] } {
           puts stderr "Failed to open file: $file_name"
           return
       }
    } else {
       if { [catch {open $file_name w} fid] } {
           puts stderr "Failed to open file: $file_name"
           return
       }
    }
    redirect -append $::_logFile { echo "Before report net_cap data mem is [mem] , cputime is [cputime %g]" }

    current_instance 

    ##Put header in it.
    puts $fid "****************************************"
    puts $fid "Report  : fast_report_total_capacitance_hier"
    puts $fid "Design  : [get_attribute [current_design] full_name]"
    puts $fid "Vendor  : PT"
    puts $fid "Version : 1.0"
    puts $fid "CapUnit : [get_pt_unit cap]"
    puts $fid "ResUnit : [get_pt_unit res]"
    puts $fid "****************************************"

    ## for ports
    puts $fid "\n#Port port_name pin_capacitance_max pin_capacitance_min"
    set ports [get_ports * -filter "defined(pin_capacitance_max) || defined(pin_capacitance_min)"]
    foreach_in_collection pp $ports {
        set cap_max [get_attribute -quiet $pp pin_capacitance_max]
        set cap_min [get_attribute -quiet $pp pin_capacitance_min]
        if {$cap_max == ""} { set cap_max $cap_min }
        if {$cap_min == ""} { set cap_min $cap_max }
        puts $fid [format "%s\t%.6f\t%.6f" \
                       [get_attribute $pp full_name] \
                       $cap_max \
                       $cap_min ]
    }
    unset ports

    ## report data for hierarchy cells
    set hiercells [get_cells -quiet * -filter "is_hierarchical == true"]
    foreach_in_collection cell $hiercells {
        report_hier_cell_capacitances_for_icexplorer $cell $fid
    }

    ## report data for non-hierarchy nets
    set allnets [get_nets -quiet * -filter " \
                                  defined(total_capacitance_max) && defined(total_capacitance_min) && \
                                  defined(wire_capacitance_max) && defined(wire_capacitance_min) && \
                                  defined(net_resistance_max) && defined(net_resistance_min)"]
    report_nets_capacitance_for_icexplorer $allnets $fid

    redirect -append $::_logFile { echo "After  report net_cap data mem is [mem] , cputime is [cputime %g]" }

    close $fid
}

proc report_hier_cell_capacitances_for_icexplorer {cell fid} {
    set baseName [get_attribute $cell base_name]
    set guessFullName [current_instance .]
    if {$guessFullName != ""} {
        append guessFullName $::hierarchy_separator $baseName
    } else {
        set guessFullName $baseName
    }
    if {$guessFullName != [get_attribute $cell full_name]} {
        redirect -append $::_ErrorLog  { echo "ERROR : full_name not match '$guessFullName'   '[get_attribute $cell full_name]'" }
        return
    }

    current_instance $baseName
    set allnets [get_nets -quiet -hier * -filter " \
                                  defined(total_capacitance_max) && defined(total_capacitance_min) && \
                                  defined(wire_capacitance_max) && defined(wire_capacitance_min) && \
                                  defined(net_resistance_max) && defined(net_resistance_min)"]
    #puts $fid "BEGINMODULE  $guessFullName [sizeof_collection $allnets]

    if {[sizeof_collection $allnets] > $::_maxObjsNumber} {
        set hiercells [get_cells -quiet * -filter "is_hierarchical == true"]
        foreach_in_collection inst $hiercells {
            report_hier_cell_capacitances_for_icexplorer $inst $fid
        }

        set allnets [get_nets -quiet * -filter " \
                                  defined(total_capacitance_max) && defined(total_capacitance_min) && \
                                  defined(wire_capacitance_max) && defined(wire_capacitance_min) && \
                                  defined(net_resistance_max) && defined(net_resistance_min)"]
        report_nets_capacitance_for_icexplorer $allnets $fid
    } else {
        report_nets_capacitance_for_icexplorer $allnets $fid
    }

    #puts $fid "ENDMODULE    $baseName"
    current_instance ..
}

proc report_nets_capacitance_for_icexplorer {nets fid} {
    if {[sizeof_collection $nets] == 0} {
        return
    }

    puts $fid "\n#NetCaps nets total_capacitance_max total_capacitance_min wire_capacitance_max wire_capacitance_min net_resistance_max net_resistance_min [sizeof_collection $nets]"

    set datas [get_attribute -value_list $nets full_name]
    puts $fid "#nets_name [llength $datas]"
    set datas [string map {" " "\n" "{" "" "}" ""} $datas]
    puts $fid $datas
    unset datas

    set datas [get_attribute -value_list $nets total_capacitance_max]
    puts $fid "#total_capacitance_max [llength $datas]"
    set datas [string map {" " "\n"} $datas]
    puts $fid $datas
    unset datas

    set datas [get_attribute -value_list $nets total_capacitance_min]
    puts $fid "#total_capacitance_min [llength $datas]"
    set datas [string map {" " "\n"} $datas]
    puts $fid $datas
    unset datas

    set datas [get_attribute -value_list $nets wire_capacitance_max]
    puts $fid "#wire_capacitance_max [llength $datas]"
    set datas [string map {" " "\n"} $datas]
    puts $fid $datas
    unset datas

    set datas [get_attribute -value_list $nets wire_capacitance_min]
    puts $fid "#wire_capacitance_min [llength $datas]"
    set datas [string map {" " "\n"} $datas]
    puts $fid $datas
    unset datas

    set datas [get_attribute -value_list $nets net_resistance_max]
    puts $fid "#net_resistance_max [llength $datas]"
    set datas [string map {" " "\n"} $datas]
    puts $fid $datas
    unset datas

    set datas [get_attribute -value_list $nets net_resistance_min]
    puts $fid "#net_resistance_min [llength $datas]"
    set datas [string map {" " "\n"} $datas]
    puts $fid $datas
    unset datas
}


######################################################
# report timing derate
######################################################
proc report_timing_derates_for_icexplorer {file_name} {
    if { [catch {open $file_name w} fid] } {
        puts stderr "Failed to open file: $file_name"
        return
    }
    puts $fid "****************************************"
    puts $fid "Report  : report_timing_derate"
    puts $fid "Vendor  : PT"
    puts $fid "Version : 1.0"
    puts $fid "****************************************"
    puts $fid "\n"
    close $fid
    redirect -append $file_name {report_timing_derate -nosplit -significant_digits 4}
}

######################################################
# report dont touch objects
######################################################
proc report_dont_touch_objects_for_icexplorer {file_name} {
    if {[no_gzip] == 0} {
       if { [catch {open "| gzip > $file_name.gz" w} fid] } {
           puts stderr "Failed to open file: $file_name"
           return
       }
    } else {
       if { [catch {open $file_name w} fid] } {
           puts stderr "Failed to open file: $file_name"
           return
       }
    }

    ##Put header in it.
    puts $fid "****************************************"
    puts $fid "Report  : report_dont_touch_objects"
    puts $fid "Vendor  : PT"
    puts $fid "Version : 1.0"
    puts $fid "****************************************"
    puts $fid "\n"

    ## Type is Net or Cell
    puts $fid "Name    Type"
    puts $fid "--------------------------------------------------------------------------------"

    set cells [get_cells -hier * -filter "dont_touch == true"]
    foreach_in_collection pp $cells {
        puts $fid "[get_attribute $pp full_name] \tCell"
    }
    unset cells

    set nets [get_nets -hier * -filter "dont_touch == true"]
    foreach_in_collection pp $nets {
        puts $fid "[get_attribute $pp full_name] \t Net"
    }
    unset nets

    close $fid    
}

######################################################
# clock cells
# update by senhua
# the clock cells can be converted from clock pins, 
# so this proc is redundant and should be removed 
######################################################
proc report_clock_cells_for_icexplorer {file_name} {
    if {[no_gzip] == 0} {
       if { [catch {open "| gzip > $file_name.gz" w} fid] } {
           puts stderr "Failed to open file: $file_name"
           return
       }
    } else {
       if { [catch {open $file_name w} fid] } {
           puts stderr "Failed to open file: $file_name"
           return
       }
    }

    ##Put header in it.
    puts $fid "****************************************"
    puts $fid "Report  : repot_clock_cells"
    puts $fid "Vendor  : PT"
    puts $fid "Version : 1.0"
    puts $fid "****************************************"
    puts $fid "\n"

    puts $fid "Name"
    puts $fid "--------------------------------------------------------------------------------"

    set clockcells [get_cells -hier * -filter "is_sequential == true"]
    foreach_in_collection cell $clockcells {
        puts $fid [get_attribute $cell full_name]
    }

    unset clockcells

    if {[sizeof_collection [get_clocks -quiet *]] == 0} {
        return
    }
    set clocks [all_clocks]
    append_to_collection -unique clocks [get_generated_clocks *]
    if { [sizeof_collection $clocks]==0 } {
        puts stderr "Value for list 'clocks' must have more than zero elements."
        return
    }
    set clockcells [get_clock_network_objects -type cell -include_clock_gating_network $clocks]

    foreach_in_collection cell $clockcells {
        puts $fid [get_attribute $cell full_name]
    }

    unset clockcells
    
    close $fid    
}

######################################################
# report clock pins
######################################################
proc report_used_as_clock_pins_for_icexplorer {file_name} {
    if {[no_gzip] == 0} {
       if { [catch {open "| gzip > $file_name.gz" w} fid] } {
           puts stderr "Failed to open file: $file_name"
           return
       }
    } else {
       if { [catch {open $file_name w} fid] } {
           puts stderr "Failed to open file: $file_name"
           return
       }
    }

    ##Put header in it.
    puts $fid "****************************************"
    puts $fid "Report  : report_used_as_clock_pins"
    puts $fid "Vendor  : PT"
    puts $fid "Version : 1.0"
    puts $fid "****************************************"
    puts $fid "\n"

    puts $fid "Name"
    puts $fid "--------------------------------------------------------------------------------"

    if {[sizeof_collection [get_clocks -quiet *]] == 0} {
        return
    }
    set pins [get_clock_network_objects -type pin ]
### dont use -include_clock_gating_network
### typical clock gating network is from Latch/Q to an input pin of AND(OR) cell, and this pin
### is enable pin. if user sets gating check constraint, then the paths in gating network are the
### real paths and should be fixed, so we can't include clock gating network
#    set pins [get_clock_network_objects -type pin -include_clock_gating_network]

    foreach_in_collection pp $pins {
        puts $fid [get_attribute $pp full_name]
    }
    unset pins
    
    set clocks [get_clocks * -quiet -filter "is_generated == true"]
    foreach_in_collection clock $clocks {
        redirect -variable d {report_clock_timing -type latency -clock $clock -ver -no}
        set data [split $d "\n"]
        set match 0
        foreach line $data {
            if {[llength $line] == 1} {
                if {[string match "*--------*" $line]} {
                    set match 1
                }
            }
            if {$match == 0 || [llength $line] < 6} {
                continue
            }
            puts $fid [lindex $line 0]
        }
    }

    close $fid
}

######################################################
# report upf data.
######################################################
proc report_upf_data_for_icexplorer {file_name} {
    if {[no_gzip] == 0} {
       if { [catch {open "| gzip > $file_name.gz" w} fid] } {
           puts stderr "Failed to open file: $file_name"
           return
       }
    } else {
       if { [catch {open $file_name w} fid] } {
           puts stderr "Failed to open file: $file_name"
           return
       }
    }

    puts $fid "**************************************"
    puts $fid "Report: voltage_area_cells"
    puts $fid "**************************************"
    #isolation cell
    puts $fid "#isolation cell"
    set cells [get_cells -hier * -filter "upf_isolation_strategy != {}"]
    foreach_in_collection inst $cells {
        puts $fid [get_attribute $inst full_name]
    }

    #retention cell
    puts $fid "#retention cell"
    set cells [get_cells -hier * -filter "upf_retention_strategy != {}"]
    foreach_in_collection inst $cells {
        puts $fid [get_attribute $inst full_name]
    }

    #level shilter
    puts $fid "#level shilter"

    
    close $fid
}


## only report arcs which delta data > threshold
proc report_delta_data_for_icexplorer {scenario_name dir_name threshold} {
     if {$dir_name == ""} {
       set dir_name "."
     } else {
       catch {exec mkdir -p $dir_name}
     }

    set file_name ${dir_name}/${scenario_name}_data_si_delta.txt
    if {[no_gzip] == 0} {
       if { [catch {open "| gzip > $file_name.gz" w} fid] } {
           puts stderr "Failed to open file: $file_name"
           return
       }
    } else {
       if { [catch {open $file_name w} fid] } {
           puts stderr "Failed to open file: $file_name"
           return
       }
    }

    set arcs [get_timing_arcs -of_objects [get_nets -hier *] ]
    puts $fid "****************************************"
    puts $fid "Report   : annotated_delta"
    puts $fid "Design   : [get_attribute [current_design] full_name]"
    puts $fid "Vendor   : PT"
    puts $fid "Version  : 1.0"
    puts $fid "TimeUnit : [get_pt_unit time]"
    puts $fid "****************************************"
    puts $fid "FromPoint \tToPoint \tDelta_max_rise \tDelta_max_fall \tDelta_min_rise \tDelta_min_fall \tDTrans_max_rise \tDTrans_max_fall \tDTrans_min_rise \tDTrans_min_fall"
    puts $fid "-------------------------------------------------------------------------"
    foreach_in_collection {arc} $arcs {
        set frPin    [get_attribute $arc from_pin]
        set toPin    [get_attribute $arc to_pin]
        set ddmaxr   [get_attribute $arc annotated_delay_delta_max_rise]
        set ddmaxf   [get_attribute $arc annotated_delay_delta_max_fall]
        set ddminr   [get_attribute $arc annotated_delay_delta_min_rise]
        set ddminf   [get_attribute $arc annotated_delay_delta_min_fall]
        set tdmaxr   [get_attribute $toPin annotated_rise_transition_delta_max]
        set tdmaxf   [get_attribute $toPin annotated_fall_transition_delta_max]
        set tdminr   [get_attribute $toPin annotated_rise_transition_delta_min]
        set tdminf   [get_attribute $toPin annotated_fall_transition_delta_min]

        if {[expr abs($ddmaxr)] < $threshold && [expr abs($ddmaxf)] < $threshold && \
            [expr abs($ddminr)] < $threshold && [expr abs($ddminf)] < $threshold && \
            [expr abs($tdmaxr)] < $threshold && [expr abs($tdmaxf)] < $threshold && \
            [expr abs($tdminr)] < $threshold && [expr abs($tdminf)] < $threshold } {
            continue
        }

        puts $fid [format "%s \t%s \t%.4f \t%.4f \t%.4f \t%.4f \t%.4f \t%.4f \t%.4f \t%.4f"\
                   [get_attribute $frPin full_name] \
                   [get_attribute $toPin full_name] \
                   $ddmaxr \
                   $ddmaxf \
                   $ddminr \
                   $ddminf \
                   $tdmaxr \
                   $tdmaxf \
                   $tdminr \
                   $tdminf ]
    } 
    close $fid
}

## only report arcs which delta data > threshold
proc fastreport_delta_data_for_icexplorer {scenario_name dir_name threshold} {
     if {$dir_name == ""} {
        set dir_name "."
     } else {
        catch {exec mkdir -p $dir_name}
     }

    set file_name ${dir_name}/${scenario_name}_data_si_delta.txt
    if {[no_gzip] == 0} {
       if { [catch {open "| gzip > $file_name.gz" w} fid] } {
           puts stderr "Failed to open file: $file_name"
           return
       }
    } else {
       if { [catch {open $file_name w} fid] } {
           puts stderr "Failed to open file: $file_name"
           return
       }
    }

    set cutnum 100000

    puts $fid "****************************************"
    puts $fid "Report   : fast_report_delta"
    puts $fid "Design   : [get_attribute [current_design] full_name]"
    puts $fid "Vendor   : PT"
    puts $fid "Version  : 1.0"
    puts $fid "TimeUnit : [get_pt_unit time]"
    puts $fid "****************************************"
  
    redirect -append $::_logFile { echo "Before report delta data mem is [mem] , cputime is [cputime %g]" }

    set arcs [get_timing_arcs -of_objects [get_nets -hier * -top_net_of_hierarchical_group] -filter "\
                       annotated_delay_delta_max_rise >= $threshold || \
                       annotated_delay_delta_max_fall >= $threshold || \
                       annotated_delay_delta_min_rise >= $threshold || \
                       annotated_delay_delta_min_fall >= $threshold"]
    puts $fid "#Delta_delay annotated_delay_delta_max_rise annotated_delay_delta_max_fall annotated_delay_delta_min_rise annotated_delay_delta_min_fall from_pin_name to_pin_name [sizeof_collection $arcs]"

    redirect -append $::_logFile { echo "After  get_timing_arcs mem is [mem] , cputime is [cputime %g]" }

    set datas [get_attribute -value_list $arcs annotated_delay_delta_max_rise]
    puts $fid "#annotated_delay_delta_max_rise [llength $datas]"
    set datas [string map {" " "\n"} $datas]
    puts $fid $datas

    set datas [get_attribute -value_list $arcs annotated_delay_delta_max_fall]
    puts $fid "#annotated_delay_delta_max_fall [llength $datas]"
    set datas [string map {" " "\n"} $datas]
    puts $fid $datas

    set datas [get_attribute -value_list $arcs annotated_delay_delta_min_rise]
    puts $fid "#annotated_delay_delta_min_rise [llength $datas]"
    set datas [string map {" " "\n"} $datas]
    puts $fid $datas

    set datas [get_attribute -value_list $arcs annotated_delay_delta_min_fall]
    puts $fid "#annotated_delay_delta_min_fall [llength $datas]"
    set datas [string map {" " "\n"} $datas]
    puts $fid $datas

    puts $fid "#from_pins_name [sizeof_collection $arcs]"
    foreach_in_collection arc $arcs {
       puts $fid [get_attribute [get_attribute $arc from_pin] full_name]
    }
  #  set datas [get_attribute -value_list $arcs from_pin]
  #  puts $fid "#from_pins_name [llength $datas]"
  #  foreach data $datas {
  #     puts $fid [get_attribute $data full_name]
  #  }
  #  unset datas

    puts $fid "#to_pins_name [sizeof_collection $arcs]"
    foreach_in_collection arc $arcs {
       puts $fid [get_attribute [get_attribute $arc to_pin] full_name]
    }

    unset datas
    unset arcs

    redirect -append $::_logFile { echo "Before get_pins for delta transition mem is [mem] , cputime is [cputime %g]" }

    puts $fid ""
    set pins [get_pins -hier * -filter "is_hierarchical == false && (\
                      annotated_rise_transition_delta_max >= $threshold || \
                      annotated_fall_transition_delta_max >= $threshold || \
                      annotated_rise_transition_delta_min >= $threshold || \
                      annotated_fall_transition_delta_min >= $threshold)"]
    puts $fid "#Delta_transition annotated_rise_transition_delta_max annotated_fall_transition_delta_max annotated_rise_transition_delta_min annotated_fall_transition_delta_min pin_name [sizeof_collection $pins]"

    redirect -append $::_logFile { echo "After  get_pins for delta transition mem is [mem] , cputime is [cputime %g]" }

    set datas [get_attribute -value_list $pins annotated_rise_transition_delta_max]
    puts $fid "#annotated_transition_delta_rise_max [llength $datas]"
    set datas [string map {" " "\n"} $datas]
    puts $fid $datas

    set datas [get_attribute -value_list $pins annotated_fall_transition_delta_max]
    puts $fid "#annotated_transition_delta_fall_max [llength $datas]"
    set datas [string map {" " "\n"} $datas]
    puts $fid $datas

    set datas [get_attribute -value_list $pins annotated_rise_transition_delta_min]
    puts $fid "#annotated_transition_delta_rise_min [llength $datas]"
    set datas [string map {" " "\n"} $datas]
    puts $fid $datas

    set datas [get_attribute -value_list $pins annotated_fall_transition_delta_min]
    puts $fid "#annotated_transition_delta_fall_min [llength $datas]"
    set datas [string map {" " "\n"} $datas]
    puts $fid $datas

    set datas [get_attribute -value_list $pins full_name]
    puts $fid "#to_pins_name [llength $datas]"
    set number [llength $datas]
    set iternum [expr $number/$cutnum]
    for {set x 0} {$x <= $iternum} {incr x} {
        set tmp [lrange $datas [expr $x * $cutnum] [expr (($x+1) * $cutnum) - 1]]
        set tmp [string map {" " "\n" "{" "" "}" ""} $tmp]
        puts $fid $tmp
    }

    unset datas
    unset pins

    redirect -append $::_logFile { echo "After  report delta datal mem is [mem] , cputime is [cputime %g]" }

    close $fid
}
proc fastreport_ilm_objects_for_icexplorer {file_name} {
  if {[no_gzip] == 0} {
    if { [catch {open "| gzip > $file_name.gz" w} fid] } {
      puts stderr "Failed to open file: $file_name"
      return
    }
  } else {
    if { [catch {open $file_name w} fid] } {
      puts stderr "Failed to open file: $file_name"
      return
    }
  }

  redirect -append $::_logFile { echo "Before report_ilm_objects mem is [mem] , cputime is [cputime %g]" }
  current_instance

  ##Put header in it.
  puts $fid "****************************************"
  puts $fid "Report   : report_ilm_objects"
  puts $fid "Design   : [get_attribute [current_design] full_name]"
  puts $fid "Vendor   : PT"
  puts $fid "Version  : 1.0"
  puts $fid "TimeUnit : [get_pt_unit time]"
  puts $fid "CapUnit  : [get_pt_unit cap]"
  puts $fid "ResUnit  : [get_pt_unit res]"
  puts $fid "****************************************"
  set cutnum 100000
  identify_interface_logic -auto_ignore

  ## get pins on io paths
  set ilm_pins [get_ilm_objects -type pin ]
  set ilm_pins_name [get_attribute -value_list $ilm_pins full_name]
  set number [llength $ilm_pins_name]
  puts $fid "\n#pins_name $number"
  set iternum [expr $number/$cutnum]
  for {set x 0} {$x <= $iternum} {incr x} {
    set tmp [lrange $ilm_pins_name [expr $x * $cutnum] [expr (($x+1) * $cutnum) - 1]]
    set tmp [string map {" " "\n" "{" "" "}" ""} $tmp]
    puts $fid $tmp
  }
  unset ilm_pins
  unset ilm_pins_name

  redirect -append $::_logFile { echo "After  report_ilm_objects mem is [mem] , cputime is [cputime %g]" }
  close $fid
}

proc report_ilm_objects_for_icexplorer {file_name} {
  if {[no_gzip] == 0} {
    if { [catch {open "| gzip > $file_name.gz" w} fid] } {
      puts stderr "Failed to open file: $file_name"
      return
    }
  } else {
    if { [catch {open $file_name w} fid] } {
      puts stderr "Failed to open file: $file_name"
      return
    }
  }

  redirect -append $::_logFile { echo "Before report_ilm_objects mem is [mem] , cputime is [cputime %g]" }
  current_instance

  ##Put header in it.
  puts $fid "****************************************"
  puts $fid "Report   : report_ilm_objects"
  puts $fid "Design   : [get_attribute [current_design] full_name]"
  puts $fid "Vendor   : PT"
  puts $fid "Version  : 1.0"
  puts $fid "TimeUnit : [get_pt_unit time]"
  puts $fid "CapUnit  : [get_pt_unit cap]"
  puts $fid "ResUnit  : [get_pt_unit res]"
  puts $fid "****************************************"
  set cutnum 100000
  identify_interface_logic -auto_ignore

  ## get pins on io paths
  set ilm_pins [get_ilm_objects -type pin ]
  set number [sizeof_collection $ilm_pins]
  puts $fid "\n#pins_name $number"
  foreach_in_collection obj $ilm_pins {
    set name [get_object_name $obj]
    puts $fid "$name"
  }
  unset ilm_pins
  unset obj
  redirect -append $::_logFile { echo "After  report_ilm_objects mem is [mem] , cputime is [cputime %g]" }
  close $fid
}


######################################################
# report path summary for icexplorer
######################################################
proc report_path_summary_for_icexplorer {file_name} {
    redirect $file_name {report_timing -delay_type min -path_type summary -start_end_pair -nosplit}
    redirect $file_name {report_timing -delay_type max -path_type summary -start_end_pair -nosplit} -append
}

######################################################
# report paths for icexplorer
######################################################
proc report_paths_for_icexplorer {sce_name {dir_name .} {delay_type "min"} {max_paths 100000} {nworst 10} {setup_threshold 0.0} {hold_threshold 0.0} {pba_mode "none"} } {
    if {$delay_type != "min" && $delay_type != "max" && $delay_type != "min_max"} {
        puts stderr "delay_type only can be min, max or min_max"   
    }
    if {$pba_mode != "none" && $pba_mode != "path"} {
        puts stderr "pba_mode only can be none or path"   
    }

    if {$dir_name == ""} {
       set dir_name "."
     } else {
       catch {exec mkdir -p $dir_name}
     }

    set file_name ${dir_name}/$sce_name\_data_timing_rpt.txt.gz
    #set timing_remove_clock_reconvergence_pessimism true
    #set pba_aocvm_only_mode false
    #set timing_aocvm_enable_analysis true
    scan [time {
    redirect -compress $file_name {
        if {$delay_type == "min"} {
            report_timing -pba_mode $pba_mode -sig 4 -input_pins -cap -trans -derate -nosplit -delay_type min -slack_lesser_than $hold_threshold  -max_paths $max_paths -nworst $nworst
        } elseif {$delay_type == "max"} {
            report_timing -pba_mode $pba_mode -sig 4 -input_pins -cap -trans -derate -nosplit -delay_type max -slack_lesser_than $setup_threshold -max_paths $max_paths -nworst $nworst
        } else {          
            report_timing -pba_mode $pba_mode -sig 4 -input_pins -cap -trans -derate -nosplit -delay_type min -slack_lesser_than $hold_threshold  -max_paths $max_paths -nworst $nworst
            report_timing -pba_mode $pba_mode -sig 4 -input_pins -cap -trans -derate -nosplit -delay_type max -slack_lesser_than $setup_threshold -max_paths $max_paths -nworst $nworst
        }
    } } ] "%f" realtime

    redirect -append $::_logFile {
        echo "Dump path time for $sce_name use time " [expr $realtime/1000000]
    }
}

######################################################
# report pba paths for icexplorer
######################################################
proc report_pba_paths_for_icexplorer {sce_name {dir_name .} {delay_type "min"} {max_paths 100000} {nworst 10} {setup_threshold 0.0} {hold_threshold 0.0} } {
    report_paths_for_icexplorer $sce_name $dir_name $delay_type $max_paths $nworst $setup_threshold $hold_threshold "path"
}

proc report_clock_groups_for_icexplorer {file_name} {
    if {[no_gzip] == 0} {
      if { [catch {open "| gzip > $file_name.gz" w} fid] } {
        puts stderr "Failed to open file: $file_name"
          return
      }
    } else {
      if { [catch {open $file_name w} fid] } {
        puts stderr "Failed to open file: $file_name"
        return
      }
    }

    ##Put header in it.
    puts $fid "****************************************"
    puts $fid "Report  : repot_clock_groups"
    puts $fid "Vendor  : PT"
    puts $fid "Version : 1.0"
    puts $fid "****************************************"
    puts $fid "\n"

    puts $fid "Name    clocks" 
    puts $fid "--------------------------------------------------------------------------------"
    set ports [get_ports *]
    foreach_in_collection port $ports {
      set cgs [get_attribute $port clocks -quiet]
      if { [sizeof_collection $cgs]!=0 } {
         puts -nonewline $fid [get_attribute $port full_name]
         foreach_in_collection cg $cgs {
           puts -nonewline $fid [format "\t%s" [get_attribute $cg full_name]] 
         }
        puts $fid ""
      }
    }
    unset ports

    set pins [get_pins -hier * -filter "is_clock_pin==true"]

    foreach_in_collection pin $pins {
      set cgs [get_attribute $pin clocks -quiet]
      if { [sizeof_collection $cgs]!=0 } {
        puts -nonewline  $fid [get_attribute $pin full_name]
        foreach_in_collection cg $cgs {
          puts -nonewline $fid [format "\t%s" [get_attribute $cg full_name]]
        }
        puts $fid ""
      }  
    }
    unset pins

    close $fid
}

######################################################
# no_gzip
######################################################
proc no_gzip {} {
    # test gzip
    set nogzip [catch {exec gzip -L}]
    return $nogzip
}

######################################################
# zip file
######################################################
proc zip_file {file_name} {
    if {[catch {exec gzip -f [glob $file_name]}]} {
        puts stderr "Failed to zip $file_name with gzip."
    }
}

######################################################
# get pt unit
# type can be "time", "cap", "res"
######################################################
proc get_pt_unit {type} {
  set timeunit 1e-9 
  set capunit  1e-12 
  set resunit  1000 
  redirect -variable units_data {report_units -nosplit }
  set lines [split $units_data "\n"]
  foreach {line} $lines {
    if {[llength $line] != 4} {
      continue
    }
    if {[lindex $line 0] == "Capacitive_load_unit"} {
      set capunit [lindex $line 2]
    }
    if {[lindex $line 0] == "Time_unit"} {
      set timeunit [lindex $line 2]
    }
    if {[lindex $line 0] == "Resistance_unit"} {
      set resunit [lindex $line 2]
    }
  }

  if {$type == "time"} {
    return $timeunit
  } elseif {$type == "cap"} {
    return $capunit
  } else {
    return $resunit
  }
}
proc get_libs_from_pt { mode corner { scenario "" } } {
  if { $mode == "" } {
    puts stderr "Error: mode name is not specified."
    return -1
  }
  if { $corner == "" } {
    puts stderr "Error: corner name is not specified."
    return -1
  }
  if { $scenario == "" } {
    set scenario "${mode}_${corner}"
  }
  set cfg_file ${scenario}.cfg
  set fd [open ${cfg_file} w]
  puts $fd "scenario: $scenario"
  puts $fd "mode:$mode"
  puts $fd "corner:$corner"
  set lib_list ""
  foreach_in_collection lib [get_libs] {
    set source_name [get_attribute  $lib source_file_name]
    lappend lib_list $source_name
  }
  foreach lib_name $lib_list  {
    puts $fd "db: $lib_name"
  }
  close $fd
}
ice_help_topics
