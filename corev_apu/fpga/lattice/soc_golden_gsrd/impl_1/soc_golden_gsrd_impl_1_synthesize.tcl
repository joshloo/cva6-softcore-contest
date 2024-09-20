if {[catch {

# define run engine funtion
source [file join {C:/lscc/radiant/2024.1} scripts tcl flow run_engine.tcl]
# define global variables
global para
set para(gui_mode) "1"
set para(prj_dir) "C:/code/cva6-joshloo/cva6/corev_apu/fpga/lattice/soc_golden_gsrd"
# synthesize IPs
# synthesize VMs
# propgate constraints
file delete -force -- soc_golden_gsrd_impl_1_cpe.ldc
::radiant::runengine::run_engine_newmsg cpe -syn synpro -f "soc_golden_gsrd_impl_1.cprj" "axi4_interconnect0.cprj" "tse_mac0.cprj" "qspi0.cprj" "axi4_interconnect1.cprj" "axi_register_slice0.cprj" "apb_interconnect0.cprj" "sgdma0.cprj" "mpmc0.cprj" "axi2apb0.cprj" "mbconfig0.cprj" "tse_to_rgmii_bridge0.cprj" "rst_sync0.cprj" "gpio0.cprj" "sysmem0.cprj" "lpddr4_mc_contr0.cprj" "uart0.cprj" "pll0.cprj" "cpu0.cprj" "osc0.cprj" -a "LAV-AT"  -o soc_golden_gsrd_impl_1_cpe.ldc
# synthesize top design
file delete -force -- soc_golden_gsrd_impl_1.vm soc_golden_gsrd_impl_1.ldc
if {[ catch {::radiant::runengine::run_engine synpwrap -prj "soc_golden_gsrd_impl_1_synplify.tcl" -log "soc_golden_gsrd_impl_1.srf"} result options ]} {
    file delete -force -- soc_golden_gsrd_impl_1.vm soc_golden_gsrd_impl_1.ldc
    return -options $options $result
}
::radiant::runengine::run_postsyn [list -a LAV-AT -p LAV-AT-E70ES1 -t LFG1156 -sp 1 -oc Commercial -top -ipsdc ipsdclist.txt -w -o soc_golden_gsrd_impl_1_syn.udb soc_golden_gsrd_impl_1.vm] [list C:/code/cva6-joshloo/cva6/corev_apu/fpga/lattice/soc_golden_gsrd/impl_1/soc_golden_gsrd_impl_1.ldc]

} out]} {
   ::radiant::runengine::runtime_log $out
   exit 1
}
