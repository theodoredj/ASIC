######################  DDR WCK Path Quality Check ###########################
echo "Next is DDR WCK Path Quality Check"
echo "#####################"
proc GetDly { TimingPath RChannel } {
  foreach_in_collection iPoint [get_attribute $TimingPath points] {
    if ([expr {[get_attribute [get_attribute $iPoint object] full_name] eq $RChannel}]) { return  [get_attribute $iPoint arrival] }
  }
}

set RChannel0 uCNPS_DDR_PHY_0/U_DDR_PHY_16/U_DDRPHY_ROUTE_CANPS1/WCK
set RChannel1 uCNPS_DDR_PHY_1/U_DDR_PHY_16/U_DDRPHY_ROUTE_CANPS1/WCK

set Paths ""
append_to_collection Paths [get_timing_path -delay max -rise_to $RChannel0 -from uclock_controller/upll3/uPLL/CLKOUT]
append_to_collection Paths [get_timing_path -delay max -fall_to $RChannel0 -from uclock_controller/upll3/uPLL/CLKOUT]
append_to_collection Paths [get_timing_path -delay min -rise_to $RChannel0 -from uclock_controller/upll3/uPLL/CLKOUT]
append_to_collection Paths [get_timing_path -delay min -fall_to $RChannel0 -from uclock_controller/upll3/uPLL/CLKOUT]
append_to_collection Paths [get_timing_path -delay max -rise_to $RChannel1 -from uclock_controller/upll4/uPLL/CLKOUT]
append_to_collection Paths [get_timing_path -delay max -fall_to $RChannel1 -from uclock_controller/upll4/uPLL/CLKOUT]
append_to_collection Paths [get_timing_path -delay min -rise_to $RChannel1 -from uclock_controller/upll4/uPLL/CLKOUT]
append_to_collection Paths [get_timing_path -delay min -fall_to $RChannel1 -from uclock_controller/upll4/uPLL/CLKOUT]
for {set x 0} {$x<4} {incr x} { echo [GetDly [index_collection $Paths $x] $RChannel0]}
for {set x 4} {$x<8} {incr x} { echo [GetDly [index_collection $Paths $x] $RChannel1]}

foreach_in_collection iPoint [get_attribute [index_collection $Paths 0] points] {
  set iPins [get_attribute $iPoint object]
  echo [get_attribute $iPins full_name] [get_attribute [get_cells -of $iPins] ref_name] [get_attribute $iPoint transition]
}

foreach_in_collection iPoint [get_attribute [index_collection $Paths 4] points] {
  set iPins [get_attribute $iPoint object]
  echo [get_attribute $iPins full_name] [get_attribute [get_cells -of $iPins] ref_name] [get_attribute $iPoint transition]
}

echo "#####################"
##################################################################

######################  DDR MCK Path Quality Check ###########################
echo "Next is DDR MCK Path Quality Check"
echo "#####################"

set MCKs ""
lappend MCKs uCNPS_DDR_PHY_0/U_DDR_PHY_16/U_DDR_ADCM_SUBPHY_0/ISUBPHY/MCK
lappend MCKs uCNPS_DDR_PHY_0/U_DDR_PHY_16/U_DDR_ADCM_SUBPHY_1/ISUBPHY/MCK
lappend MCKs uCNPS_DDR_PHY_0/U_DDR_PHY_16/U_DDR_ADCM_SUBPHY_2/ISUBPHY/MCK
lappend MCKs uCNPS_DDR_PHY_0/U_DDR_PHY_16/U_DDR_ADCM_SUBPHY_3/ISUBPHY/MCK
lappend MCKs uCNPS_DDR_PHY_0/U_DDR_PHY_16/U_DDR_DATA_SUBPHY_0/ISUBPHY/MCK
lappend MCKs uCNPS_DDR_PHY_0/U_DDR_PHY_16/U_DDR_DATA_SUBPHY_1/ISUBPHY/MCK
lappend MCKs uCNPS_DDR_PHY_0/U_DDR_PHY_16/U_DDR_DMSYNC/MCK
set MAX 0
set MIN 1000
foreach iMCK $MCKs {
  set iPath  [get_timing_path -from uclock_controller/upm/BM0_MCK_clkgen/out_clk_reg/CK -rise_to $iMCK]
  set iPathF [get_timing_path -from uclock_controller/upm/BM0_MCK_clkgen/out_clk_reg/CK -fall_to $iMCK]
  set iArrival [get_attribute $iPath arrival]
  if ($iArrival>$MAX) {set MAX $iArrival}
  if ($iArrival<$MIN) {set MIN $iArrival} 
  echo $iMCK $iArrival [get_attribute $iPathF arrival]
}
echo "Skew " [expr $MAX - $MIN]
####
set MCKs ""
lappend MCKs uCNPS_DDR_PHY_1/U_DDR_PHY_16/U_DDR_ADCM_SUBPHY_0/ISUBPHY/MCK
lappend MCKs uCNPS_DDR_PHY_1/U_DDR_PHY_16/U_DDR_ADCM_SUBPHY_1/ISUBPHY/MCK
lappend MCKs uCNPS_DDR_PHY_1/U_DDR_PHY_16/U_DDR_ADCM_SUBPHY_2/ISUBPHY/MCK
lappend MCKs uCNPS_DDR_PHY_1/U_DDR_PHY_16/U_DDR_ADCM_SUBPHY_3/ISUBPHY/MCK
lappend MCKs uCNPS_DDR_PHY_1/U_DDR_PHY_16/U_DDR_DATA_SUBPHY_0/ISUBPHY/MCK
lappend MCKs uCNPS_DDR_PHY_1/U_DDR_PHY_16/U_DDR_DATA_SUBPHY_1/ISUBPHY/MCK
lappend MCKs uCNPS_DDR_PHY_1/U_DDR_PHY_16/U_DDR_DMSYNC/MCK
set MAX 0
set MIN 1000
foreach iMCK $MCKs {
  set iPath [get_timing_path -from uclock_controller/upm/BM1_MCK_clkgen/out_clk_reg/CK -rise_to $iMCK]
  set iPathF [get_timing_path -from uclock_controller/upm/BM1_MCK_clkgen/out_clk_reg/CK -fall_to $iMCK]
  set iArrival [get_attribute $iPath arrival]
  if ($iArrival>$MAX) {set MAX $iArrival}
  if ($iArrival<$MIN) {set MIN $iArrival}
  echo $iMCK $iArrival [get_attribute $iPathF arrival]
}
echo "Skew " [expr $MAX - $MIN]

set PathDDR0R [get_timing_path -delay max -rise_to uclock_controller/upm/BM0_MCK_clkgen/out_clk_reg/CK -from uclock_controller/upll*/uPLL/CLKOUT]
set PathDDR0F [get_timing_path -delay max -fall_to uclock_controller/upm/BM0_MCK_clkgen/out_clk_reg/CK -from uclock_controller/upll*/uPLL/CLKOUT]
set PathDDR1R [get_timing_path -delay max -rise_to uclock_controller/upm/BM1_MCK_clkgen/out_clk_reg/CK -from uclock_controller/upll*/uPLL/CLKOUT]
set PathDDR1F [get_timing_path -delay max -fall_to uclock_controller/upm/BM1_MCK_clkgen/out_clk_reg/CK -from uclock_controller/upll*/uPLL/CLKOUT]

echo "CH0 PLL -> MCLK common diverging point (CK pin of Clock Divider)" [get_attribute $PathDDR0R arrival] [get_attribute $PathDDR0F arrival]
echo "CH1 PLL -> MCLK common diverging point (CK pin of Clock Divider)" [get_attribute $PathDDR1R arrival] [get_attribute $PathDDR1F arrival]
echo "#####################"
######################

######################  NAND PHY MCK/WCK Skew Check ###########################
echo "Next is NAND PHY MCK/WCK Skew Check"
echo "#####################"
set FCKPath_CK2P ""
set FCKDLY_CK2P ""
set FCKPath_Buf2CK ""
set FCKDLY_Buf2CK ""
set BufList ""
lappend BufList uclock_controller/upm/nif_clkgen/NA_CLK_tree_A_buf/Z
lappend BufList uclock_controller/upm/nif_clkgen/NA_CLK_tree_B_buf/Z
lappend BufList uclock_controller/upm/nif_clkgen/NA_CLK_tree_C_buf/Z
lappend BufList uclock_controller/upm/nif_clkgen/NA_CLK_tree_D_buf/Z

for {set x 0} {$x<4} {incr x} {
  set DIVCK uclock_controller/upm/nif_clkgen/MCLK_NA2_${x}clkgen/out_clk_reg/CK

  set FCKPath_CK2P [get_timing_path -from $DIVCK -rise_to uTSB_TOP/beTop/MCLK_NA2[$x]]
  set FCKPath_Buf2CK [get_timing_path -rise_from [lindex $BufList $x] -rise_to $DIVCK]
  set WCKPath_Buf2P [get_timing_path -rise_from [lindex $BufList $x] -rise_to uTSB_TOP/beTop/MCLK_NA[$x]]

  set FCKDLY_CK2P [get_attribute $FCKPath_CK2P arrival]

  foreach_in_collection iPoint [get_attribute $FCKPath_Buf2CK points] {
    if ([expr {[get_attribute [get_attribute $iPoint object] full_name] eq [lindex $BufList $x]}]) { set Buf_DLY [get_attribute $iPoint arrival] }
    if ([expr {[get_attribute [get_attribute $iPoint object] full_name] eq $DIVCK}])               { set CK_DLY  [get_attribute $iPoint arrival] }
  }
  set FCKDLY_Buf2CK [expr $CK_DLY - $Buf_DLY]
  set FCKDLY_Buf2P [expr $FCKDLY_CK2P + $FCKDLY_Buf2CK]

  foreach_in_collection iPoint [get_attribute $WCKPath_Buf2P points] {
    if ([expr {[get_attribute [get_attribute $iPoint object] full_name] eq [lindex $BufList $x]}])          { set Buf_DLY [get_attribute $iPoint arrival] }
    if ([expr {[get_attribute [get_attribute $iPoint object] full_name] eq "uTSB_TOP/beTop/MCLK_NA[$x]"}]) { set P_DLY  [get_attribute $iPoint arrival] }
  }
  set WCKDLY_Buf2P [expr $P_DLY - $Buf_DLY]
  set SKEW [expr $FCKDLY_Buf2P -$WCKDLY_Buf2P]

  echo "BIT $x"
  echo "FCK $FCKDLY_Buf2P"
  echo "WCK $WCKDLY_Buf2P"
  echo "FCK-WCK : $SKEW"
}
echo "#####################"
###########################################################################
#create_clock -name PLL3_CLK -period 0.938 -waveform { 0 0.469 } [get_pins {uclock_controller/upll3/uPLL/CLKOUT}]
#create_clock -name PLL4_CLK -period 0.833 -waveform { 0 0.4165 } [get_pins {uclock_controller/upll4/uPLL/CLKOUT}]
#write_spice_deck -sub_circuit_file spice0.ckt -output wck0.spi [get_timing_path -from uclock_controller/upll3/uPLL/CLKOUT -to uCNPS_DDR_PHY_0/U_DDR_PHY_16/U_DDRPHY_ROUTE_CANPS1/WCK]
#write_spice_deck -sub_circuit_file spice1.ckt -output wck1.spi [get_timing_path -from uclock_controller/upll4/uPLL/CLKOUT -to uCNPS_DDR_PHY_1/U_DDR_PHY_16/U_DDRPHY_ROUTE_CANPS1/WCK]
###########################################################################
set Pins ""
append_to_collection Pins [get_pins uCNPS_DDR_PHY_0/U_DDR_PHY_TST_16/RASb_TDO_REG_POS_reg/D]
append_to_collection Pins [get_pins uCNPS_DDR_PHY_0/U_DDR_PHY_TST_16/CASb_TDO_REG_POS_reg/D]
append_to_collection Pins [get_pins uCNPS_DDR_PHY_0/U_DDR_PHY_TST_16/WEb_TDO_REG_POS_reg/D]
append_to_collection Pins [get_pins uCNPS_DDR_PHY_0/U_DDR_PHY_TST_16/BA_TDO_REG_POS_reg*/D]
append_to_collection Pins [get_pins uCNPS_DDR_PHY_0/U_DDR_PHY_TST_16/AD_TDO_REG_POS_reg*/D]
append_to_collection Pins [get_pins uCNPS_DDR_PHY_0/U_DDR_PHY_TST_16/ODT_TDO_REG_POS_reg*/D]
append_to_collection Pins [get_pins uCNPS_DDR_PHY_0/U_DDR_PHY_TST_16/CKE_TDO_REG_POS_reg*/D]
append_to_collection Pins [get_pins uCNPS_DDR_PHY_0/U_DDR_PHY_TST_16/CSb_TDO_REG_POS_reg*/D]
append_to_collection Pins [get_pins uCNPS_DDR_PHY_0/U_DDR_PHY_TST_16/RASb_TDO_REG_NEG_reg/D]
append_to_collection Pins [get_pins uCNPS_DDR_PHY_0/U_DDR_PHY_TST_16/CASb_TDO_REG_NEG_reg/D]
append_to_collection Pins [get_pins uCNPS_DDR_PHY_0/U_DDR_PHY_TST_16/WEb_TDO_REG_NEG_reg/D]
append_to_collection Pins [get_pins uCNPS_DDR_PHY_0/U_DDR_PHY_TST_16/BA_TDO_REG_NEG_reg*/D]
append_to_collection Pins [get_pins uCNPS_DDR_PHY_0/U_DDR_PHY_TST_16/AD_TDO_REG_NEG_reg*/D]
append_to_collection Pins [get_pins uCNPS_DDR_PHY_0/U_DDR_PHY_TST_16/ODT_TDO_REG_NEG_reg*/D]
append_to_collection Pins [get_pins uCNPS_DDR_PHY_0/U_DDR_PHY_TST_16/CKE_TDO_REG_NEG_reg*/D]
append_to_collection Pins [get_pins uCNPS_DDR_PHY_0/U_DDR_PHY_TST_16/CSb_TDO_REG_NEG_reg*/D]

foreach_in_collection iPin $Pins {
  set iPath [get_timing_path -to $iPin]
  echo [get_attribute [get_attribute $iPath startpoint] full_name] [get_attribute [get_attribute $iPath endpoint] full_name] [get_attribute $iPath arrival]
}
##########################
set Pins ""
append_to_collection Pins [get_pins uCNPS_DDR_PHY_1/U_DDR_PHY_TST_16/RASb_TDO_REG_POS_reg/D]
append_to_collection Pins [get_pins uCNPS_DDR_PHY_1/U_DDR_PHY_TST_16/CASb_TDO_REG_POS_reg/D]
append_to_collection Pins [get_pins uCNPS_DDR_PHY_1/U_DDR_PHY_TST_16/WEb_TDO_REG_POS_reg/D]
append_to_collection Pins [get_pins uCNPS_DDR_PHY_1/U_DDR_PHY_TST_16/BA_TDO_REG_POS_reg*/D]
append_to_collection Pins [get_pins uCNPS_DDR_PHY_1/U_DDR_PHY_TST_16/AD_TDO_REG_POS_reg*/D]
append_to_collection Pins [get_pins uCNPS_DDR_PHY_1/U_DDR_PHY_TST_16/ODT_TDO_REG_POS_reg*/D]
append_to_collection Pins [get_pins uCNPS_DDR_PHY_1/U_DDR_PHY_TST_16/CKE_TDO_REG_POS_reg*/D]
append_to_collection Pins [get_pins uCNPS_DDR_PHY_1/U_DDR_PHY_TST_16/CSb_TDO_REG_POS_reg*/D]
append_to_collection Pins [get_pins uCNPS_DDR_PHY_1/U_DDR_PHY_TST_16/RASb_TDO_REG_NEG_reg/D]
append_to_collection Pins [get_pins uCNPS_DDR_PHY_1/U_DDR_PHY_TST_16/CASb_TDO_REG_NEG_reg/D]
append_to_collection Pins [get_pins uCNPS_DDR_PHY_1/U_DDR_PHY_TST_16/WEb_TDO_REG_NEG_reg/D]
append_to_collection Pins [get_pins uCNPS_DDR_PHY_1/U_DDR_PHY_TST_16/BA_TDO_REG_NEG_reg*/D]
append_to_collection Pins [get_pins uCNPS_DDR_PHY_1/U_DDR_PHY_TST_16/AD_TDO_REG_NEG_reg*/D]
append_to_collection Pins [get_pins uCNPS_DDR_PHY_1/U_DDR_PHY_TST_16/ODT_TDO_REG_NEG_reg*/D]
append_to_collection Pins [get_pins uCNPS_DDR_PHY_1/U_DDR_PHY_TST_16/CKE_TDO_REG_NEG_reg*/D]
append_to_collection Pins [get_pins uCNPS_DDR_PHY_1/U_DDR_PHY_TST_16/CSb_TDO_REG_NEG_reg*/D]

foreach_in_collection iPin $Pins {
  set iPath [get_timing_path -to $iPin]
  echo [get_attribute [get_attribute $iPath startpoint] full_name] [get_attribute [get_attribute $iPath endpoint] full_name] [get_attribute $iPath arrival]
}

####################################
sh rm -f LoopBack.DDR.rpt
set FF0 [get_cells uCNPS_DDR_PHY_0/U_DDR_PHY_TST_16/* -filter "is_sequential==true"]
foreach_in_collection iFF $FF0 {
  set iName [get_attribute $iFF full_name]
#  set iPath_BM0_MCK [get_timing_path -to ${iName}/D -group BM0_MCK]
#  set iPath_DDR_CK [get_timing_path -to ${iName}/D -group DDR_CK_TDOP0_0]
  report_timing -nosplit -to  ${iName}/D -group BM0_MCK >> LoopBack.DDR.rpt
  report_timing -nosplit -to  ${iName}/D -group DDR_CK_TDOP0_0 >> LoopBack.DDR.rpt
}

set FF1 [get_cells uCNPS_DDR_PHY_1/U_DDR_PHY_TST_16/* -filter "is_sequential==true"]
foreach_in_collection iFF $FF1 {
  set iName [get_attribute $iFF full_name]
#  set iPath_BM0_MCK [get_timing_path -to ${iName}/D -group BM0_MCK]
#  set iPath_DDR_CK [get_timing_path -to ${iName}/D -group DDR_CK_TDOP0_0]
  report_timing -nosplit -to  ${iName}/D -group BM0_MCK >> LoopBack.DDR.rpt
  report_timing -nosplit -to  ${iName}/D -group DDR_CK_TDOP1_0 >> LoopBack.DDR.rpt
}







  

