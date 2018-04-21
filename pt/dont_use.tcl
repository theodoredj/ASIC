define_user_attribute pt_dont_use -quiet -type boolean -class lib_cell
proc set_pt_dont_use {lib_cell} { set_user_attribute -class lib_cell [get_lib_cell -quiet $lib_cell] pt_dont_use true }
set SYNTHESIS_LIBs [list m9hzd_std_${LIB} m9szd_std_${LIB} m9snd_std_${LIB}]

foreach SYNTHESIS_LIB $SYNTHESIS_LIBs {
set_pt_dont_use ${SYNTHESIS_LIB}/*x0
set_pt_dont_use ${SYNTHESIS_LIB}/*x1
set_pt_dont_use ${SYNTHESIS_LIB}/*x20
set_pt_dont_use ${SYNTHESIS_LIB}/*x22
set_pt_dont_use ${SYNTHESIS_LIB}/*x24
set_pt_dont_use ${SYNTHESIS_LIB}/*x28
set_pt_dont_use ${SYNTHESIS_LIB}/*x32
set_pt_dont_use ${SYNTHESIS_LIB}/*x40
set_pt_dont_use ${SYNTHESIS_LIB}/*x48

set_pt_dont_use ${SYNTHESIS_LIB}/*dly*
set_pt_dont_use ${SYNTHESIS_LIB}/*cap*
set_pt_dont_use ${SYNTHESIS_LIB}/*m2
set_pt_dont_use ${SYNTHESIS_LIB}/*tie*
set_pt_dont_use ${SYNTHESIS_LIB}/*_rep*
set_pt_dont_use ${SYNTHESIS_LIB}/*sc*
set_pt_dont_use ${SYNTHESIS_LIB}/*_stbuf*
set_pt_dont_use ${SYNTHESIS_LIB}/*_stlatch*
set_pt_dont_use ${SYNTHESIS_LIB}/*_sbuskpr
set_pt_dont_use ${SYNTHESIS_LIB}/*_sant*

set_pt_dont_use ${SYNTHESIS_LIB}/*5x*
set_pt_dont_use ${SYNTHESIS_LIB}/*soai221x*
set_pt_dont_use ${SYNTHESIS_LIB}/*soai222x*
set_pt_dont_use ${SYNTHESIS_LIB}/*sao*33*
set_pt_dont_use ${SYNTHESIS_LIB}/*soa*33*

set_pt_dont_use ${SYNTHESIS_LIB}/*smxa*
set_pt_dont_use ${SYNTHESIS_LIB}/*smxo*
set_pt_dont_use ${SYNTHESIS_LIB}/*smxn*
set_pt_dont_use ${SYNTHESIS_LIB}/*_ssdf*
}

