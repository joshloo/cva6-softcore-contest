if {[catch {

# define run engine funtion
source [file join {C:/lscc/radiant/2024.1} scripts tcl flow run_engine.tcl]
# define global variables
global para
set para(gui_mode) "1"
set para(prj_dir) "C:/code/cva6-softcore-contest-joshloo/cva6-softcore-contest/corev_apu/fpga/lattice/cva6_combined_rtl/ariane"
# synthesize IPs
# synthesize VMs
# synthesize top design
file delete -force -- ariane_impl_1.vm ariane_impl_1.ldc
if {[ catch {::radiant::runengine::run_engine synpwrap -prj "ariane_impl_1_synplify.tcl" -log "ariane_impl_1.srf"} result options ]} {
    file delete -force -- ariane_impl_1.vm ariane_impl_1.ldc
    return -options $options $result
}
::radiant::runengine::run_postsyn [list -a LAV-AT -p LAV-AT-E70ES1 -t LFG676 -sp 1 -oc Commercial -top -w -o ariane_impl_1_syn.udb ariane_impl_1.vm] [list C:/code/cva6-softcore-contest-joshloo/cva6-softcore-contest/corev_apu/fpga/lattice/cva6_combined_rtl/ariane/impl_1/ariane_impl_1.ldc]

} out]} {
   ::radiant::runengine::runtime_log $out
   exit 1
}
