set Modules ""
lappend Modules u_ndc_top/u_nmpy_0/u_NDPHY_1RB_1BS_wrapper_WITH_VREF/u_NDPHY_28
lappend Modules u_ndc_top/u_nmpy_1/u_NDPHY_1RB_1BS_wrapper/u_NDPHY_28
lappend Modules u_ndc_top/u_nmpy_2/u_NDPHY_1RB_1BS_wrapper_WITH_VREF/u_NDPHY_28
lappend Modules u_ndc_top/u_nmpy_3/u_NDPHY_1RB_1BS_wrapper/u_NDPHY_28
lappend Modules u_ndc_top/u_nmpy_4/u_NDPHY_1RB_1BS_wrapper_WITH_VREF/u_NDPHY_28
lappend Modules u_ndc_top/u_nmpy_5/u_NDPHY_1RB_1BS_H_wrapper_WITH_CORNER/u_NDPHY_28
lappend Modules u_ndc_top/u_nmpy_6/u_NDPHY_1RB_1BS_H_wrapper_WITH_VREF/u_NDPHY_28
lappend Modules u_ndc_top/u_nmpy_7/u_NDPHY_1RB_1BS_H_wrapper/u_NDPHY_28
lappend Modules u_ndc_top/u_nmpy_8/u_NDPHY_1RB_1BS_H_wrapper_WITH_CAL_AND_VREF/u_NDPHY_28
lappend Modules u_ndc_top/u_nmpy_9/u_NDPHY_1RB_1BS_H_wrapper/u_NDPHY_28
lappend Modules u_ndc_top/u_nmpy_10/u_NDPHY_1RB_1BS_H_wrapper_WITH_VREF/u_NDPHY_28
lappend Modules u_ndc_top/u_nmpy_11/u_NDPHY_1RB_1BS_H_wrapper/u_NDPHY_28
lappend Modules u_ndc_top/u_nmpy_12/u_NDPHY_1RB_1BS_H_wrapper_WITH_VREF/u_NDPHY_28
lappend Modules u_ndc_top/u_nmpy_13/u_NDPHY_1RB_1BS_wrapper_WITH_CORNER/u_NDPHY_28
lappend Modules u_ndc_top/u_nmpy_14/u_NDPHY_1RB_1BS_wrapper_WITH_VREF/u_NDPHY_28
lappend Modules u_ndc_top/u_nmpy_15/u_NDPHY_1RB_1BS_wrapper/u_NDPHY_28
lappend Modules u_ndc_top/u_nmpy_16/u_NDPHY_1RB_1BS_wrapper_WITH_VREF/u_NDPHY_28
lappend Modules u_ndc_top/u_nmpy_17/u_NDPHY_1RB_1BS_wrapper/u_NDPHY_28


foreach iModule $Modules {
  set WCKPin  ${iModule}/U_ND_CMND_03_SUBPHY/FC_WCK
  set WCKPathR  [get_timing_path -from MCLK_NA* -rise_through $WCKPin]
  foreach_in_collection iPoint [get_attribute $WCKPathR points]  { if ([expr {[get_attribute [get_attribute $iPoint object] full_name] eq $WCKPin}])  { set WCKArrivalR  [get_attribute $iPoint arrival] } }

#  set WCKSourceR [get_attribute $WCKPathR startpoint_clock_latency]
  set WCKSourceR 0
  set WCKTimeR [expr $WCKSourceR + $WCKArrivalR]
#####
  set WCKBPin ${iModule}/U_ND_CMND_03_SUBPHY/FC_WCKB
  set WCKBPathR [get_timing_path -from MCLK_NA* -rise_through $WCKBPin]
  foreach_in_collection iPoint [get_attribute $WCKBPathR points] { if ([expr {[get_attribute [get_attribute $iPoint object] full_name] eq $WCKBPin}]) { set WCKBArrivalR [get_attribute $iPoint arrival] } }

#  set WCKBSourceR [get_attribute $WCKPathR startpoint_clock_latency]
  set WCKBSourceR 0
  set WCKBTimeR [expr $WCKBSourceR + $WCKBArrivalR]
#####
  set FCKPin  ${iModule}/U_ND_CMND_03_SUBPHY/FCLK
  set FCKPathR  [get_timing_path -from u_ndc_top/u_ndcdiv*/u_div/pre_scan_out_clk_reg/CK -rise_through $FCKPin]
  foreach_in_collection iPoint [get_attribute $FCKPathR points]  { if ([expr {[get_attribute [get_attribute $iPoint object] full_name] eq $FCKPin}])  { set FCKArrivalR  [get_attribute $iPoint arrival] } }

  set Mpoint [get_attribute [get_attribute $FCKPathR startpoint] full_name]
  set FCKPathS  [get_timing_path -from MCLK_NA* -rise_to $Mpoint]
  foreach_in_collection iPoint [get_attribute $FCKPathS points]  { if ([expr {[get_attribute [get_attribute $iPoint object] full_name] eq $Mpoint}])  { set FCKSourceR  [get_attribute $iPoint arrival] } }
  set FCKTimeR [expr $FCKSourceR + $FCKArrivalR]
######################################################
  if ([expr ($WCKTimeR >  [expr $WCKBTimeR  - 0.050]) && ($WCKTimeR <  [expr $WCKBTimeR  + 0.050]) ]) {set Rule1  "PASS"} else { set Rule1  "Violated" }
  if ([expr ($WCKTimeR >  [expr $FCKTimeR  * 1.150]) && ($WCKTimeR <  [expr $FCKTimeR  * 1.200]) ]) {set Rule2 "PASS"} else { set Rule2 "Violated" }

  echo "$iModule/U_ND_CMND_03_SUBPHY WCK  Rise $WCKTimeR"
  echo "$iModule/U_ND_CMND_03_SUBPHY WCKB Rise $WCKBTimeR"
  echo "$iModule/U_ND_CMND_03_SUBPHY FCK  Rise $FCKTimeR"


  echo "Rule1  : WCK/WCKB SKew < 50ps, 			$Rule1"
  echo "Rule2  : FCK*1.15([expr $FCKTimeR  * 1.150]) < WCK($WCKTimeR) < FCK*1.2([expr $FCKTimeR  * 1.200]) $Rule2"
  echo ""
}
############################################################################################################
############################################################################################################
############################################################################################################
############################################################################################################
foreach iModule $Modules {
  set BUSW_FCK ${iModule}/U_ND_BUS_SW_SUBPHY/FCLK
  set CEB4_FCK ${iModule}/U_ND_CEB45_SUBPHY/FCLK
  set CEB6_FCK ${iModule}/U_ND_CEB67_SUBPHY/FCLK
  set CMND_FCK ${iModule}/U_ND_CMND_03_SUBPHY/FCLK
  set DATA_FCK ${iModule}/U_ND_DATA_SUBPHY/FCLK
  set RBND_FCK ${iModule}/U_ND_RB_SUBPHY/FCLK
  set REND_FCK ${iModule}/U_ND_RE_SUBPHY/FCLK
  set WEND_FCK ${iModule}/U_ND_WE_SUBPHY/FCLK

  set BUSW_Path [get_timing_path -from u_ndc_top/u_ndcdiv*/u_div/pre_scan_out_clk_reg/CK -rise_through $BUSW_FCK]
  set CEB4_Path [get_timing_path -from u_ndc_top/u_ndcdiv*/u_div/pre_scan_out_clk_reg/CK -rise_through $CEB4_FCK]
  set CEB6_Path [get_timing_path -from u_ndc_top/u_ndcdiv*/u_div/pre_scan_out_clk_reg/CK -rise_through $CEB6_FCK]
  set CMND_Path [get_timing_path -from u_ndc_top/u_ndcdiv*/u_div/pre_scan_out_clk_reg/CK -rise_through $CMND_FCK]
  set DATA_Path [get_timing_path -from u_ndc_top/u_ndcdiv*/u_div/pre_scan_out_clk_reg/CK -rise_through $DATA_FCK]
  set RBND_Path [get_timing_path -from u_ndc_top/u_ndcdiv*/u_div/pre_scan_out_clk_reg/CK -rise_through $RBND_FCK]
  set REND_Path [get_timing_path -from u_ndc_top/u_ndcdiv*/u_div/pre_scan_out_clk_reg/CK -rise_through $REND_FCK]
  set WEND_Path [get_timing_path -from u_ndc_top/u_ndcdiv*/u_div/pre_scan_out_clk_reg/CK -rise_through $WEND_FCK]

  foreach_in_collection iPoint [get_attribute $BUSW_Path points] { if ([expr {[get_attribute [get_attribute $iPoint object] full_name] eq $BUSW_FCK}]) { set BUSW_DLY  [get_attribute $iPoint arrival] }}
  foreach_in_collection iPoint [get_attribute $CEB4_Path points] { if ([expr {[get_attribute [get_attribute $iPoint object] full_name] eq $CEB4_FCK}]) { set CEB4_DLY  [get_attribute $iPoint arrival] }}
  foreach_in_collection iPoint [get_attribute $CEB6_Path points] { if ([expr {[get_attribute [get_attribute $iPoint object] full_name] eq $CEB6_FCK}]) { set CEB6_DLY  [get_attribute $iPoint arrival] }}
  foreach_in_collection iPoint [get_attribute $CMND_Path points] { if ([expr {[get_attribute [get_attribute $iPoint object] full_name] eq $CMND_FCK}]) { set CMND_DLY  [get_attribute $iPoint arrival] }}
  foreach_in_collection iPoint [get_attribute $DATA_Path points] { if ([expr {[get_attribute [get_attribute $iPoint object] full_name] eq $DATA_FCK}]) { set DATA_DLY  [get_attribute $iPoint arrival] }}
  foreach_in_collection iPoint [get_attribute $RBND_Path points] { if ([expr {[get_attribute [get_attribute $iPoint object] full_name] eq $RBND_FCK}]) { set RBND_DLY  [get_attribute $iPoint arrival] }}
  foreach_in_collection iPoint [get_attribute $REND_Path points] { if ([expr {[get_attribute [get_attribute $iPoint object] full_name] eq $REND_FCK}]) { set REND_DLY  [get_attribute $iPoint arrival] }}
  foreach_in_collection iPoint [get_attribute $WEND_Path points] { if ([expr {[get_attribute [get_attribute $iPoint object] full_name] eq $WEND_FCK}]) { set WEND_DLY  [get_attribute $iPoint arrival] }}
######################################################
set MAX 0
set MIN 1000
if ($BUSW_DLY>$MAX) {set MAX $BUSW_DLY}
if ($CEB4_DLY>$MAX) {set MAX $CEB4_DLY}
if ($CEB6_DLY>$MAX) {set MAX $CEB6_DLY}
if ($CMND_DLY>$MAX) {set MAX $CMND_DLY}
if ($DATA_DLY>$MAX) {set MAX $DATA_DLY}
if ($RBND_DLY>$MAX) {set MAX $RBND_DLY}
if ($REND_DLY>$MAX) {set MAX $REND_DLY}
if ($WEND_DLY>$MAX) {set MAX $WEND_DLY}

if ($BUSW_DLY<$MIN) {set MIN $BUSW_DLY}
if ($CEB4_DLY<$MIN) {set MIN $CEB4_DLY}
if ($CEB6_DLY<$MIN) {set MIN $CEB6_DLY}
if ($CMND_DLY<$MIN) {set MIN $CMND_DLY}
if ($DATA_DLY<$MIN) {set MIN $DATA_DLY}
if ($RBND_DLY<$MIN) {set MIN $RBND_DLY}
if ($REND_DLY<$MIN) {set MIN $REND_DLY}
if ($WEND_DLY<$MIN) {set MIN $WEND_DLY}

if ([expr [expr $MAX - $MIN] < 0.05]) {set RuleSkew "PASS"} else {set RuleSkew "Violated"}
if ($MAX==$CMND_DLY) {set RuleMAX "PASS"} else {set RuleMAX "Violated"}

  echo "BUSW_FCK $BUSW_DLY"
  echo "CEB4_FCK $CEB4_DLY"
  echo "CEB6_FCK $CEB6_DLY"
  echo "CMND_FCK $CMND_DLY"
  echo "DATA_FCK $DATA_DLY"
  echo "RBND_FCK $RBND_DLY"
  echo "REND_FCK $REND_DLY"
  echo "WEND_FCK $WEND_DLY"
  echo "SKEW [expr $MAX - $MIN]		$RuleSkew"
  echo "CMDN FCK MAX                    $RuleMAX"
  echo ""
}

