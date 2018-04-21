################################################################################
set LIBSET 20160105
set s_path [list . /proj/deneb1/wa/$USER/scr/sta \
/proj/libs/marvell/tsmc28hpm/hvt/m9hzd_std/rev3.2.0.2/synopsys/ccstn \
/proj/libs/marvell/tsmc28hpm/svt/m9szd_std/rev3.2.0.1/synopsys/ccstn \
/proj/libs/marvell/tsmc28hpm/lvt/m9lzd_std/rev3.2.0.1/synopsys/ccstn \
/proj/libs/marvell_custom/tsmc28hpm/svt/m9szd_misc/rev3.3/synopsys/ccstn \
/proj/libs/marvell/tsmc28hpm/svt/m9snd_std/rev3.2.0.1/synopsys/ccstn \
/proj/libs/marvell/tsmc28hpm/svt/m9szd_clklib/rev3.2/synopsys/ccstn \
/proj/libs/marvell/tsmc28hpm/svt/m9szd_tielib/rev2.0.1/synopsys \
/proj/libs/marvell_custom/tsmc28hpm/lvt/m9lzd_misc/rev3.3/synopsys/ccstn \
/proj/libs/marvell/tsmc28hpm/svt/m9szd_tcd/rev3.2/synopsys \
/proj/libs/marvell/tsmc28hpm/lvt/m7lzd_clklib/rev1.3/synopsys/ccstn \
/proj/libs/marvell/tsmc28hpm/hvt/m7hzd_std/dev1.3/synopsys/ccstn \
/proj/libs/marvell/tsmc28hpm/svt/m7szd_std/rev1.2/synopsys/ccstn \
/proj/libs/marvell/tsmc28hpm/lvt/m7lzd_std/rev1.2/synopsys/ccstn \
/proj/libs/marvell_custom/tsmc28hpm/svt/m7szd_sync/rev1.1/synopsys/ccstn \
/proj/libs/marvell/tsmc28hpm/svt/m7snd_std/dev1.3/synopsys/ccstn \
/proj/libs/marvell/tsmc28hpm/svt/m7szd_clklib/rev1.3/synopsys/ccstn \
/proj/libs/marvell/tsmc28hpm/svt/m7spd_tielib/rev1.2/synopsys \
/proj/libs/marvell_custom/tsmc28hpm/lvt/m7lzd_sync/rev1.1/synopsys/ccstn \
/proj/libs/marvell/tsmc28hpm/svt/m7spd_tcd/rev1.2/synopsys \
/proj/libs/marvell/tsmc28hpm/lvt/m9lzd_clklib/rev3.2/synopsys/ccstn \
/proj/deneb1/libset/DENEB_TOP.1.0A.$LIBSET/db \
]


#/proj/deneb1/wa/wswang/memory/hpm_hvt/hvt_t28hpmhvtrf2p64x123mx2dtng4/current \


foreach SingleLib [list slow0p81v125 typ0p9v50 typ0p9v110 fast0p99vn40 fast0p99v125 slow0p81vn10] {

  set link_lib_ram_$SingleLib ""
  foreach iRAMIP [ls /proj/deneb1/libset/DENEB_TOP.1.0A.$LIBSET/db/*_${SingleLib}*.db] {
    if {[string match "*m?hzd*" $iRAMIP] || [string match "*m?szd*" $iRAMIP] || [string match "*m?lzd*" $iRAMIP] || [string match "*m?snd*" $iRAMIP] || [string match "*m?spd*" $iRAMIP] || \
        [string match "*u_lut*" $iRAMIP]  || [string match "*u_udm*" $iRAMIP] || [string match "*u_dpar*" $iRAMIP]  || [string match "*u_dpaw*" $iRAMIP]  || [string match "*nd_isl*" $iRAMIP]  ||  \
        [string match "*nvm_isl*" $iRAMIP]  || [string match "*pci_isl*" $iRAMIP] || [string match "*u_sas*" $iRAMIP]  || [string match "*u_be_top*" $iRAMIP] } \
    {} else { lappend link_lib_ram_$SingleLib $iRAMIP}
  }

  set link_lib_std_$SingleLib [list * \
    /proj/libs/marvell/tsmc28hpm/lvt/m9lzd_std/rev3.2.0.1/synopsys/ccstn/m9lzd_std_${SingleLib}_ccstn.db \
    /proj/libs/marvell/tsmc28hpm/hvt/m9hzd_std/rev3.2.0.2/synopsys/ccstn/m9hzd_std_${SingleLib}_ccstn.db \
    /proj/libs/marvell/tsmc28hpm/svt/m9szd_std/rev3.2.0.1/synopsys/ccstn/m9szd_std_${SingleLib}_ccstn.db \
    /proj/libs/marvell/tsmc28hpm/svt/m9snd_std/rev3.2.0.1/synopsys/ccstn/m9snd_std_${SingleLib}_ccstn.db \
    /proj/libs/marvell_custom/tsmc28hpm/svt/m9szd_misc/rev3.3/synopsys/ccstn/m9szd_misc_${SingleLib}_ccstn.db \
    /proj/libs/marvell/tsmc28hpm/svt/m9szd_clklib/rev3.2/synopsys/ccstn/m9szd_clklib_${SingleLib}_ccstn.db \
    /proj/libs/marvell/tsmc28hpm/svt/m9szd_tielib/rev2.0.1/synopsys/m9szd_tielib_${SingleLib}.db \
    /proj/libs/marvell/tsmc28hpm/svt/m9szd_tcd/rev3.2/synopsys/m9szd_tcd_${SingleLib}.db \
    /proj/libs/marvell_custom/tsmc28hpm/lvt/m9lzd_misc/rev3.3/synopsys/ccstn/m9lzd_misc_${SingleLib}_ccstn.db \
    /proj/libs/marvell/tsmc28hpm/lvt/m7lzd_std/rev1.2.0.1/synopsys/ccstn/m7lzd_std_slow0p9vn40_ccstn.db \
    /proj/libs/marvell/tsmc28hpm/hvt/m7hzd_std/dev1.4/synopsys/ccstn/m7hzd_std_${SingleLib}_ccstn.db \
    /proj/libs/marvell/tsmc28hpm/svt/m7szd_std/dev1.4/synopsys/ccstn/m7szd_std_${SingleLib}_ccstn.db \
    /proj/libs/marvell/tsmc28hpm/svt/m7snd_std/dev1.4/synopsys/ccstn/m7snd_std_${SingleLib}_ccstn.db \
    /proj/libs/marvell_custom/tsmc28hpm/svt/m7szd_sync/rev1.1/synopsys/ccstn/m7szd_sync_${SingleLib}_ccstn.db \
    /proj/libs/marvell/tsmc28hpm/svt/m7szd_clklib/rev1.3/synopsys/ccstn/m7szd_clklib_${SingleLib}_ccstn.db \
    /proj/libs/marvell/tsmc28hpm/svt/m7spd_tielib/rev1.2/synopsys/m7spd_tielib_slow0p81vn40.db \
    /proj/libs/marvell/tsmc28hpm/svt/m7spd_tcd/rev1.2/synopsys/m7spd_tcd_slow0p81vn40.db \
    /proj/libs/marvell_custom/tsmc28hpm/lvt/m7lzd_sync/rev1.1/synopsys/ccstn/m7lzd_sync_${SingleLib}_ccstn.db \
    /proj/libs/marvell/tsmc28hpm/lvt/m7lzd_clklib/rev1.3/synopsys/ccstn/m7lzd_clklib_${SingleLib}_ccstn.db \
    /proj/libs/marvell/tsmc28hpm/lvt/m9lzd_clklib/rev3.2/synopsys/ccstn/m9lzd_clklib_${SingleLib}_ccstn.db \
]

# IPs are already included in link_lib_ram_$SingleLib So this parameter has no use
  set link_lib_ip_${SingleLib} "" 
}

