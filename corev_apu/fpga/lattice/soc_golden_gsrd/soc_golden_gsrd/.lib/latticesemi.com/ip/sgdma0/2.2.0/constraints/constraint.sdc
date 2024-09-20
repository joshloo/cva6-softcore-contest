set device "LAV-AT-E70ES1"
set device_int "ap6a400be"
set package "LFG1156"
set package_int "LFG1156"
set speed "1"
set speed_int "1"
set operation "Commercial"
set family "LAV-AT"
set architecture "ap6a00b"
set partnumber "LAV-AT-E70ES1-1LFG1156C"
set WRAPPER_INST "sgdmac_core_inst"
set AXI_DWIDTH 32
set AXI_AWIDTH 32
set AXI_ID_WIDTH 2
set TDATA_WIDTH 8
set TDEST_WIDTH 4
set TID_WIDTH 4
set MM2S_FIFO_DEPTH 2048
set S2MM_FIFO_DEPTH 2048
set AXIL_DWIDTH 32
set AXIL_AWIDTH 32
set BD_DWIDTH 32
set BD_AWIDTH 32


if { $radiant(stage) == "presyn" } {

	#Please modify the clock definitions and wild cards as you deem necessary for your system design
	#create_clock -name {axi_clk} -period 8 [get_ports clk]
	#create_clock -name {axil_clk} -period 8 [get_ports axil_clk]

} elseif { $radiant(stage) == "premap" } {

	if { $radiant(synthesis) == "lse"} {
		#set_max_delay -from [get_pins {*sgdmac_core_inst/sgdma_csr/genblk1.cc_s2mm_cfg_addr/genblk1.din*.ff_inst/Q}] -to [get_pins {*sgdmac_core_inst/sgdma_csr/genblk1.cc_s2mm_cfg_addr/genblk1.dout*.ff_inst/DF}] -datapath_only 5
		#set_max_delay -from [get_pins {*sgdmac_core_inst/sgdma_csr/genblk1.cc_mm2s_cfg_addr/genblk1.din*.ff_inst/Q}] -to [get_pins {*sgdmac_core_inst/sgdma_csr/genblk1.cc_mm2s_cfg_addr/genblk1.dout*.ff_inst/DF}] -datapath_only 5
	} else {
		set_max_delay -from [get_pins {*sgdmac_core_inst/sgdma_csr/genblk1.cc_s2mm_cfg_addr/genblk1.din[*].ff_inst/Q}] -to [get_pins {*sgdmac_core_inst/sgdma_csr/genblk1.cc_s2mm_cfg_addr/genblk1.dout[*].ff_inst/DF}] -datapath_only 5
		set_max_delay -from [get_pins {*sgdmac_core_inst/sgdma_csr/genblk1.cc_mm2s_cfg_addr/genblk1.din[*].ff_inst/Q}] -to [get_pins {*sgdmac_core_inst/sgdma_csr/genblk1.cc_mm2s_cfg_addr/genblk1.dout[*].ff_inst/DF}] -datapath_only 5
	}
	
}