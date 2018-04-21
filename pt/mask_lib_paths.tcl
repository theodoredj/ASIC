set_false_path -from [get_ports {denebX_jtg_capturedr}]
set_false_path -from [get_ports {denebX_jtg_shiftdr}]
set_false_path -from [get_ports {denebX_jtg_tdi}]
set_false_path -from [get_ports {denebX_jtg_updatedr}]
set_false_path -from [get_ports {deneb*_jtg_data_reg_sel}]
set_false_path -from [get_ports {deneb*_jtg_index_reg_sel}]
set_false_path -to [get_ports {deneb*_jtg_index_reg_tdo}]
set_false_path -to [get_ports {deneb*_jtg_data_reg_tdo}]
set_false_path -from [get_ports {denebX_jtg_trstb}]

#set_false_path -to [get_ports deneb*_POR_B]
#set_false_path -to [get_ports deneb*_TEST*]
#set_false_path -to [get_ports deneb*_PROG_SEQ_CODE_CLK]
#set_false_path -to [get_ports deneb*_PROG_SEQ_CODE]
#set_false_path -to [get_ports deneb*_fuse0_PRDT_out]
#set_false_path -to [get_ports deneb*_fuse0_CSB_out]
#set_false_path -to [get_ports deneb*_fuse0_SCLK_out]
#set_false_path -to [get_ports deneb*_fuse0_PGM_B_out]
#set_false_path -to [get_ports deneb*_fuse0_LOAD_out]
#set_false_path -from [get_ports deneb*_MATCH]

set_false_path -from [get_ports *scan_en_in]
set_false_path -from [get_ports *scan_en_out]
set_false_path -from [get_ports *wrapper_en]
set_false_path -from [get_ports ext_wsi*]
set_false_path -to [get_ports ext_wso*]
set_false_path -from [get_ports *edt_channels_in*]
set_false_path -to [get_ports *edt_channels_out*]

#update_timing
#extract_model -output ${RptDIR}/${TOP}_${LIB} -format {lib db} -library_cell

#remove_propagated_clock [all_clocks]
#update_timing
#extract_model -output ${RptDIR}/${TOP}_${LIB}.PreCTS -format {lib db} -library_cell

