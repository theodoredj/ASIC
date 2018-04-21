set PHYs ""
lappend PHYs uCNPS_DDR_PHY_0/U_DDR_PHY_16/U_DDR_ADCM_SUBPHY_0/ISUBPHY
lappend PHYs uCNPS_DDR_PHY_0/U_DDR_PHY_16/U_DDR_ADCM_SUBPHY_1/ISUBPHY
lappend PHYs uCNPS_DDR_PHY_0/U_DDR_PHY_16/U_DDR_ADCM_SUBPHY_2/ISUBPHY
lappend PHYs uCNPS_DDR_PHY_0/U_DDR_PHY_16/U_DDR_ADCM_SUBPHY_3/ISUBPHY
lappend PHYs uCNPS_DDR_PHY_1/U_DDR_PHY_16/U_DDR_ADCM_SUBPHY_0/ISUBPHY
lappend PHYs uCNPS_DDR_PHY_1/U_DDR_PHY_16/U_DDR_ADCM_SUBPHY_1/ISUBPHY
lappend PHYs uCNPS_DDR_PHY_1/U_DDR_PHY_16/U_DDR_ADCM_SUBPHY_2/ISUBPHY
lappend PHYs uCNPS_DDR_PHY_1/U_DDR_PHY_16/U_DDR_ADCM_SUBPHY_3/ISUBPHY

foreach iPHY $PHYs {
  echo $iPHY/MC_WCK [get_attribute [GetDrvPin $iPHY/MC_WCK] full_name]
  echo $iPHY/MC_WCKB [get_attribute [GetDrvPin $iPHY/MC_WCKB] full_name]
  echo $iPHY/MC_WRST [get_attribute [GetDrvPin $iPHY/MC_WRST] full_name]
}

set PHYs ""
lappend PHYs uCNPS_DDR_PHY_0/U_DDR_PHY_16/U_DDR_DATA_SUBPHY_0/ISUBPHY
lappend PHYs uCNPS_DDR_PHY_0/U_DDR_PHY_16/U_DDR_DATA_SUBPHY_1/ISUBPHY
lappend PHYs uCNPS_DDR_PHY_1/U_DDR_PHY_16/U_DDR_DATA_SUBPHY_0/ISUBPHY
lappend PHYs uCNPS_DDR_PHY_1/U_DDR_PHY_16/U_DDR_DATA_SUBPHY_1/ISUBPHY

foreach iPHY $PHYs {
  echo $iPHY/MC_WCK [get_attribute [GetDrvPin $iPHY/MC_WCK] full_name]
  echo $iPHY/MC_WRST [get_attribute [GetDrvPin $iPHY/MC_WRST] full_name]
}

set PHYs ""
lappend PHYs uCNPS_DDR_PHY_0/U_DDR_PHY_16/U_DDR_DMSYNC
lappend PHYs uCNPS_DDR_PHY_1/U_DDR_PHY_16/U_DDR_DMSYNC
foreach iPHY $PHYs {
  echo $iPHY/MC_WCK [get_attribute [GetDrvPin $iPHY/MC_WCK] full_name]
  echo $iPHY/MC_WCKB [get_attribute [GetDrvPin $iPHY/MC_WCKB] full_name]
}


