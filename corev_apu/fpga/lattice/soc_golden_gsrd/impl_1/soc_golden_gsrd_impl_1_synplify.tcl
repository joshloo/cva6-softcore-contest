#-- Lattice Semiconductor Corporation Ltd.
#-- Synplify OEM project file

#device options
set_option -technology LAV-AT
set_option -part LAV_AT_E70ES1
set_option -package LFG1156C
set_option -speed_grade -1
#compilation/mapping options
set_option -symbolic_fsm_compiler true
set_option -resource_sharing true

#use verilog standard option
set_option -vlog_std v2001

#map options
set_option -frequency 200
set_option -maxfan 1000
set_option -auto_constrain_io 0
set_option -retiming false; set_option -pipe true
set_option -force_gsr false
set_option -compiler_compatible 0


set_option -default_enum_encoding default

#timing analysis options



#automatic place and route (vendor) options
set_option -write_apr_constraint 1

#synplifyPro options
set_option -fix_gated_and_generated_clocks 0
set_option -update_models_cp 0
set_option -resolve_multiple_driver 0


set_option -rw_check_on_ram 0
set_option -seqshift_no_replicate 0
set_option -automatic_compile_point 1

#-- set any command lines input by customer

set_option -dup false
set_option -disable_io_insertion false
add_file -constraint {C:/lscc/radiant/2024.1/scripts/tcl/flow/radiant_synplify_vars.tcl}
add_file -constraint {soc_golden_gsrd_impl_1_cpe.ldc}
add_file -verilog {C:/lscc/radiant/2024.1/ip/pmi/pmi_lav-at.v}
add_file -vhdl -lib pmi {C:/lscc/radiant/2024.1/ip/pmi/pmi_lav-at.vhd}
add_file -verilog -vlog_std sysv {C:/code/cva6-joshloo/cva6/corev_apu/fpga/lattice/soc_golden_gsrd/soc_golden_gsrd/lib/latticesemi.com/ip/axi4_interconnect0/2.0.1/rtl/axi4_interconnect0.sv}
add_file -verilog -vlog_std v2001 {C:/code/cva6-joshloo/cva6/corev_apu/fpga/lattice/soc_golden_gsrd/soc_golden_gsrd/lib/latticesemi.com/ip/tse_mac0/1.6.0/rtl/tse_mac0.v}
add_file -verilog -vlog_std v2001 {C:/code/cva6-joshloo/cva6/corev_apu/fpga/lattice/soc_golden_gsrd/soc_golden_gsrd/lib/latticesemi.com/ip/qspi0/1.2.0/rtl/qspi0.v}
add_file -verilog -vlog_std sysv {C:/code/cva6-joshloo/cva6/corev_apu/fpga/lattice/soc_golden_gsrd/soc_golden_gsrd/lib/latticesemi.com/ip/axi4_interconnect1/2.0.1/rtl/axi4_interconnect1.sv}
add_file -verilog -vlog_std v2001 {C:/code/cva6-joshloo/cva6/corev_apu/fpga/lattice/soc_golden_gsrd/soc_golden_gsrd/lib/latticesemi.com/ip/axi_register_slice0/1.0.0/rtl/axi_register_slice0.v}
add_file -verilog -vlog_std v2001 {C:/code/cva6-joshloo/cva6/corev_apu/fpga/lattice/soc_golden_gsrd/soc_golden_gsrd/lib/latticesemi.com/module/apb_interconnect0/1.2.1/rtl/apb_interconnect0.v}
add_file -verilog -vlog_std sysv {C:/code/cva6-joshloo/cva6/corev_apu/fpga/lattice/soc_golden_gsrd/soc_golden_gsrd/lib/latticesemi.com/ip/sgdma0/2.2.0/rtl/sgdma0.sv}
add_file -verilog -vlog_std sysv {C:/code/cva6-joshloo/cva6/corev_apu/fpga/lattice/soc_golden_gsrd/soc_golden_gsrd/lib/latticesemi.com/ip/mpmc0/1.0.0/rtl/mpmc0.sv}
add_file -verilog -vlog_std v2001 {C:/code/cva6-joshloo/cva6/corev_apu/fpga/lattice/soc_golden_gsrd/soc_golden_gsrd/soc_golden_gsrd.v}
add_file -verilog -vlog_std v2001 {C:/code/cva6-joshloo/cva6/corev_apu/fpga/lattice/soc_golden_gsrd/soc_golden_gsrd/lib/latticesemi.com/ip/axi2apb0/1.2.0/rtl/axi2apb0.v}
add_file -verilog -vlog_std v2001 {C:/code/cva6-joshloo/cva6/corev_apu/fpga/lattice/soc_golden_gsrd/soc_golden_gsrd/lib/latticesemi.com/ip/mbconfig0/1.0.0/rtl/mbconfig0.v}
add_file -verilog -vlog_std v2001 {C:/code/cva6-joshloo/cva6/corev_apu/fpga/lattice/soc_golden_gsrd/soc_golden_gsrd/lib/latticesemi.com/ip/tse_to_rgmii_bridge0/1.0.0/rtl/tse_to_rgmii_bridge0.v}
add_file -verilog -vlog_std v2001 {C:/code/cva6-joshloo/cva6/corev_apu/fpga/lattice/soc_golden_gsrd/soc_golden_gsrd/lib/latticesemi.com/ip/rst_sync0/3.0.0/rtl/rst_sync0.v}
add_file -verilog -vlog_std v2001 {C:/code/cva6-joshloo/cva6/corev_apu/fpga/lattice/soc_golden_gsrd/soc_golden_gsrd/lib/latticesemi.com/ip/gpio0/1.6.2/rtl/gpio0.v}
add_file -verilog -vlog_std v2001 {C:/code/cva6-joshloo/cva6/corev_apu/fpga/lattice/soc_golden_gsrd/soc_golden_gsrd/lib/latticesemi.com/ip/sysmem0/2.2.0/rtl/sysmem0.v}
add_file -verilog -vlog_std sysv {C:/code/cva6-joshloo/cva6/corev_apu/fpga/lattice/soc_golden_gsrd/soc_golden_gsrd/lib/latticesemi.com/ip/lpddr4_mc_contr0/2.2.0/rtl/lpddr4_mc_contr0.sv}
add_file -verilog -vlog_std v2001 {C:/code/cva6-joshloo/cva6/corev_apu/fpga/lattice/soc_golden_gsrd/soc_golden_gsrd/lib/latticesemi.com/ip/uart0/1.3.0/rtl/uart0.v}
add_file -verilog -vlog_std v2001 {C:/code/cva6-joshloo/cva6/corev_apu/fpga/lattice/soc_golden_gsrd/soc_golden_gsrd/lib/latticesemi.com/module/pll0/2.5.0/rtl/pll0.v}
add_file -verilog -vlog_std sysv {C:/code/cva6-joshloo/cva6/corev_apu/fpga/lattice/soc_golden_gsrd/soc_golden_gsrd/lib/latticesemi.com/ip/cpu0/2.4.0/rtl/cpu0.sv}
add_file -verilog -vlog_std v2001 {C:/code/cva6-joshloo/cva6/corev_apu/fpga/lattice/soc_golden_gsrd/soc_golden_gsrd/lib/latticesemi.com/module/osc0/2.1.0/rtl/osc0.v}
#-- top module name
set_option -top_module soc_golden_gsrd
set_option -include_path {C:/code/cva6-joshloo/cva6/corev_apu/fpga/lattice/soc_golden_gsrd}
set_option -include_path {C:/code/cva6-joshloo/cva6/corev_apu/fpga/lattice/soc_golden_gsrd}
set_option -include_path {C:/code/cva6-joshloo/cva6/corev_apu/fpga/lattice/soc_golden_gsrd/soc_golden_gsrd/lib/latticesemi.com/ip/axi2apb0/1.2.0}
set_option -include_path {C:/code/cva6-joshloo/cva6/corev_apu/fpga/lattice/soc_golden_gsrd/soc_golden_gsrd/lib/latticesemi.com/ip/axi4_interconnect0/2.0.1}
set_option -include_path {C:/code/cva6-joshloo/cva6/corev_apu/fpga/lattice/soc_golden_gsrd/soc_golden_gsrd/lib/latticesemi.com/ip/axi4_interconnect1/2.0.1}
set_option -include_path {C:/code/cva6-joshloo/cva6/corev_apu/fpga/lattice/soc_golden_gsrd/soc_golden_gsrd/lib/latticesemi.com/ip/axi_register_slice0/1.0.0}
set_option -include_path {C:/code/cva6-joshloo/cva6/corev_apu/fpga/lattice/soc_golden_gsrd/soc_golden_gsrd/lib/latticesemi.com/ip/cpu0/2.4.0}
set_option -include_path {C:/code/cva6-joshloo/cva6/corev_apu/fpga/lattice/soc_golden_gsrd/soc_golden_gsrd/lib/latticesemi.com/ip/gpio0/1.6.2}
set_option -include_path {C:/code/cva6-joshloo/cva6/corev_apu/fpga/lattice/soc_golden_gsrd/soc_golden_gsrd/lib/latticesemi.com/ip/lpddr4_mc_contr0/2.2.0}
set_option -include_path {C:/code/cva6-joshloo/cva6/corev_apu/fpga/lattice/soc_golden_gsrd/soc_golden_gsrd/lib/latticesemi.com/ip/mbconfig0/1.0.0}
set_option -include_path {C:/code/cva6-joshloo/cva6/corev_apu/fpga/lattice/soc_golden_gsrd/soc_golden_gsrd/lib/latticesemi.com/ip/mpmc0/1.0.0}
set_option -include_path {C:/code/cva6-joshloo/cva6/corev_apu/fpga/lattice/soc_golden_gsrd/soc_golden_gsrd/lib/latticesemi.com/ip/qspi0/1.2.0}
set_option -include_path {C:/code/cva6-joshloo/cva6/corev_apu/fpga/lattice/soc_golden_gsrd/soc_golden_gsrd/lib/latticesemi.com/ip/rst_sync0/3.0.0}
set_option -include_path {C:/code/cva6-joshloo/cva6/corev_apu/fpga/lattice/soc_golden_gsrd/soc_golden_gsrd/lib/latticesemi.com/ip/sgdma0/2.2.0}
set_option -include_path {C:/code/cva6-joshloo/cva6/corev_apu/fpga/lattice/soc_golden_gsrd/soc_golden_gsrd/lib/latticesemi.com/ip/sysmem0/2.2.0}
set_option -include_path {C:/code/cva6-joshloo/cva6/corev_apu/fpga/lattice/soc_golden_gsrd/soc_golden_gsrd/lib/latticesemi.com/ip/tse_mac0/1.6.0}
set_option -include_path {C:/code/cva6-joshloo/cva6/corev_apu/fpga/lattice/soc_golden_gsrd/soc_golden_gsrd/lib/latticesemi.com/ip/tse_to_rgmii_bridge0/1.0.0}
set_option -include_path {C:/code/cva6-joshloo/cva6/corev_apu/fpga/lattice/soc_golden_gsrd/soc_golden_gsrd/lib/latticesemi.com/ip/uart0/1.3.0}
set_option -include_path {C:/code/cva6-joshloo/cva6/corev_apu/fpga/lattice/soc_golden_gsrd/soc_golden_gsrd/lib/latticesemi.com/module/apb_interconnect0/1.2.1}
set_option -include_path {C:/code/cva6-joshloo/cva6/corev_apu/fpga/lattice/soc_golden_gsrd/soc_golden_gsrd/lib/latticesemi.com/module/osc0/2.1.0}
set_option -include_path {C:/code/cva6-joshloo/cva6/corev_apu/fpga/lattice/soc_golden_gsrd/soc_golden_gsrd/lib/latticesemi.com/module/pll0/2.5.0}

#-- set result format/file last
project -result_format "vm"
project -result_file {C:/code/cva6-joshloo/cva6/corev_apu/fpga/lattice/soc_golden_gsrd/impl_1/soc_golden_gsrd_impl_1.vm}

#-- error message log file
project -log_file {soc_golden_gsrd_impl_1.srf}
project -run -clean
