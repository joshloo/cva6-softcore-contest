set current_path "C:/code/cva6-joshloo/cva6/corev_apu/fpga/lattice/soc_golden_gsrd"

cd $current_path

set radiant_project "C:/code/cva6-joshloo/cva6/corev_apu/fpga/lattice/soc_golden_gsrd/soc_golden_gsrd.rdf"

set DEVICE "LAV-AT-E70ES1-1LFG1156C"

set DESIGN "soc_golden_gsrd"

array set VFILE_LIST ""
set VFILE_LIST(1) "C:/code/cva6-joshloo/cva6/corev_apu/fpga/lattice/soc_golden_gsrd/soc_golden_gsrd/lib/latticesemi.com/ip/tse_to_rgmii_bridge0/1.0.0/tse_to_rgmii_bridge0.ipx"
set VFILE_LIST(2) "C:/code/cva6-joshloo/cva6/corev_apu/fpga/lattice/soc_golden_gsrd/soc_golden_gsrd/lib/latticesemi.com/ip/axi2apb0/1.2.0/axi2apb0.ipx"
set VFILE_LIST(3) "C:/code/cva6-joshloo/cva6/corev_apu/fpga/lattice/soc_golden_gsrd/soc_golden_gsrd/lib/latticesemi.com/ip/mpmc0/1.0.0/mpmc0.ipx"
set VFILE_LIST(4) "C:/code/cva6-joshloo/cva6/corev_apu/fpga/lattice/soc_golden_gsrd/soc_golden_gsrd/lib/latticesemi.com/ip/rst_sync0/3.0.0/rst_sync0.ipx"
set VFILE_LIST(5) "C:/code/cva6-joshloo/cva6/corev_apu/fpga/lattice/soc_golden_gsrd/soc_golden_gsrd/lib/latticesemi.com/ip/uart0/1.3.0/uart0.ipx"
set VFILE_LIST(6) "C:/code/cva6-joshloo/cva6/corev_apu/fpga/lattice/soc_golden_gsrd/soc_golden_gsrd/lib/latticesemi.com/ip/axi4_interconnect1/2.0.1/axi4_interconnect1.ipx"
set VFILE_LIST(7) "C:/code/cva6-joshloo/cva6/corev_apu/fpga/lattice/soc_golden_gsrd/soc_golden_gsrd/lib/latticesemi.com/ip/gpio0/1.6.2/gpio0.ipx"
set VFILE_LIST(8) "C:/code/cva6-joshloo/cva6/corev_apu/fpga/lattice/soc_golden_gsrd/soc_golden_gsrd/lib/latticesemi.com/ip/axi_register_slice0/1.0.0/axi_register_slice0.ipx"
set VFILE_LIST(9) "C:/code/cva6-joshloo/cva6/corev_apu/fpga/lattice/soc_golden_gsrd/soc_golden_gsrd/lib/latticesemi.com/ip/axi4_interconnect0/2.0.1/axi4_interconnect0.ipx"
set VFILE_LIST(10) "C:/code/cva6-joshloo/cva6/corev_apu/fpga/lattice/soc_golden_gsrd/soc_golden_gsrd/lib/latticesemi.com/module/pll0/2.5.0/pll0.ipx"
set VFILE_LIST(11) "C:/code/cva6-joshloo/cva6/corev_apu/fpga/lattice/soc_golden_gsrd/soc_golden_gsrd/lib/latticesemi.com/ip/mbconfig0/1.0.0/mbconfig0.ipx"
set VFILE_LIST(12) "C:/code/cva6-joshloo/cva6/corev_apu/fpga/lattice/soc_golden_gsrd/soc_golden_gsrd/lib/latticesemi.com/ip/lpddr4_mc_contr0/2.2.0/lpddr4_mc_contr0.ipx"
set VFILE_LIST(13) "C:/code/cva6-joshloo/cva6/corev_apu/fpga/lattice/soc_golden_gsrd/soc_golden_gsrd/lib/latticesemi.com/ip/tse_mac0/1.6.0/tse_mac0.ipx"
set VFILE_LIST(14) "C:/code/cva6-joshloo/cva6/corev_apu/fpga/lattice/soc_golden_gsrd/soc_golden_gsrd/lib/latticesemi.com/module/osc0/2.1.0/osc0.ipx"
set VFILE_LIST(15) "C:/code/cva6-joshloo/cva6/corev_apu/fpga/lattice/soc_golden_gsrd/soc_golden_gsrd/lib/latticesemi.com/ip/cpu0/2.4.0/cpu0.ipx"
set VFILE_LIST(16) "C:/code/cva6-joshloo/cva6/corev_apu/fpga/lattice/soc_golden_gsrd/soc_golden_gsrd/lib/latticesemi.com/ip/sysmem0/2.2.0/sysmem0.ipx"
set VFILE_LIST(17) "C:/code/cva6-joshloo/cva6/corev_apu/fpga/lattice/soc_golden_gsrd/soc_golden_gsrd/lib/latticesemi.com/ip/qspi0/1.2.0/qspi0.ipx"
set VFILE_LIST(18) "C:/code/cva6-joshloo/cva6/corev_apu/fpga/lattice/soc_golden_gsrd/soc_golden_gsrd/lib/latticesemi.com/ip/sgdma0/2.2.0/sgdma0.ipx"
set VFILE_LIST(19) "C:/code/cva6-joshloo/cva6/corev_apu/fpga/lattice/soc_golden_gsrd/soc_golden_gsrd/lib/latticesemi.com/module/apb_interconnect0/1.2.1/apb_interconnect0.ipx"
set VFILE_LIST(20) "C:/code/cva6-joshloo/cva6/corev_apu/fpga/lattice/soc_golden_gsrd/soc_golden_gsrd/soc_golden_gsrd.v"

set index [array names VFILE_LIST]
if { [file exists $radiant_project] == 1} {
    prj_open $radiant_project
    prj_set_device -part $DEVICE -performance 1
} else {
    prj_create -name "soc_golden_gsrd" -impl "impl_1" -dev $DEVICE -performance 1 -synthesis "synplify"
    prj_save
}


foreach i $index {
    if { [catch {prj_add_source $VFILE_LIST($i)} fid] } {
        puts "file already exists in project."
    }
}

prj_save

