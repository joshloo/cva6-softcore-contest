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
set WRAPPER_INST "lscc_axi_interconnect_inst"
set TOTAL_EXTMAS_CNT 2
set TOTAL_EXTSLV_CNT 2
set FAMILY "LAV-AT"
set AXI_USER_WIDTH 1
set SIMULATION_EN 0
set EXT_MAS_AXI_ID_WIDTH 2
set EXT_MAS_MAX_ADDR_WIDTH 32
set EXT_MAS_MAX_DATA_WIDTH 32
set MAX_NUM_OF_ID_EXT_MAS_SUPPRT 1
set EXT_SLV_AXI_ID_WIDTH 4
set EXT_SLV_MAX_ADDR_WIDTH 32
set EXT_SLV_MAX_DATA_WIDTH 32
set EXT_SLV_MAX_FRAGMENT_CNT 16
set EXT_MAS_ACCESS_TYPE "{2'd2,2'd2}"
set EXT_MAS_AXI_PROTOCOL  "{1'd0,1'd0}"
set EXT_MAS_CDC_EN "{1'd0,1'd0}"
set EXT_MAS_AXI_ADDR_WIDTH "{7'd32,7'd32}"
set EXT_MAS_AXI_DATA_WIDTH "{11'd32,11'd32}"
set NUM_OF_ID_EXT_MAS_SUPPRT "{7'd1,7'd1}"
set ID_ORDER_EN_EXT_MAS "{1'd0,1'd0}"
set EXT_MAS_AXI_WR_ACCEPT "{5'd8,5'd8}"
set EXT_MAS_AXI_RD_ACCEPT "{5'd8,5'd8}"
set EXT_MAS_BRESP_FIFO_DEPTH "{5'd8,5'd8}"
set EXT_MAS_WR_DATA_FIFO_DEPTH "{10'd16,10'd16}"
set EXT_MAS_RD_DATA_FIFO_DEPTH "{10'd16,10'd16}"
set EXT_MAS_PRIORITY_SCHEME "{1'd0,1'd0}"
set EXT_MAS_FIXED_PRIORITY  "{5'd1,5'd0,5'd1,5'd0}"
set EXT_SLV_ACCESS_TYPE "{2'd2,2'd2}"
set EXT_SLV_AXI_PROTOCOL  "{1'd0,1'd0}"
set EXT_SLV_CDC_EN "{1'd0,1'd0}"
set EXT_SLV_AXI_ADDR_WIDTH "{7'd32,7'd32}"
set EXT_SLV_AXI_DATA_WIDTH "{11'd32,11'd32}"
set EXT_SLV_RESP_OUT_OF_ORDER "{1'd1,1'd1}"
set EXT_SLV_AXI_WR_ISSUE "{5'd8,5'd8}"
set EXT_SLV_AXI_RD_ISSUE "{5'd8,5'd8}"
set EXT_SLV_BRESP_FIFO_DEPTH "{5'd8,5'd8}"
set EXT_SLV_WR_DATA_FIFO_DEPTH "{10'd64,10'd64}"
set EXT_SLV_RD_DATA_FIFO_DEPTH "{10'd64,10'd64}"
set  EXT_SLV_FRAGMENT_CNT "{5'd16,5'd8}"
set EXT_SLV_FRAGMENT_BASE_ADDR "{64'h1f000,64'h1e000,64'h1d000,64'h1c000,64'h1b000,64'h1a000,64'h19000,64'h18000,64'h17000,64'h16000,64'h15000,64'h14000,64'h13000,64'h12000,64'h11000,64'h10000,64'hf000,64'he000,64'hd000,64'hc000,64'hb000,64'ha000,64'h9000,64'h8000,64'h7000,64'h6000,64'h5000,64'h4000,64'h3000,64'h2000,64'h1000,64'h0}"
set EXT_SLV_FRAGMENT_END_ADDR   "{64'h1ffff,64'h1efff,64'h1dfff,64'h1cfff,64'h1bfff,64'h1afff,64'h19fff,64'h18fff,64'h17fff,64'h16fff,64'h15fff,64'h14fff,64'h13fff,64'h12fff,64'h11fff,64'h10fff,64'hffff,64'hefff,64'hdfff,64'hcfff,64'hbfff,64'hafff,64'h9fff,64'h8fff,64'h7fff,64'h6fff,64'h5fff,64'h4fff,64'h3fff,64'h2fff,64'h1fff,64'hfff}"
set EXT_SLV_PRIORITY_SCHEME "{1'd0,1'd0}"
set EXT_SLV_FIXED_PRIORITY  "{5'd1,5'd0,5'd1,5'd0}"


if {$family == "LAV-AT"} {
  set_false_path -to [get_pins -hierarchical {lscc_axi_interconnect_inst/u_lscc_sync_axi_interconnect/*.*/u_fifo_interface/*.*/_CDC_EN.dc_fifo/u_fifo0/fifo_dc0/_FABRIC.u_fifo/*/rst_sync*[*]/PD}] -through [get_nets -hierarchical {lscc_axi_interconnect_inst/u_lscc_sync_axi_interconnect/*.*/u_fifo_interface/*.*/_CDC_EN.dc_fifo/u_fifo0/fifo_dc0/_FABRIC.u_fifo/*/*aresetn_i*}]
  set_max_delay -from [get_pins -hierarchical {lscc_axi_interconnect_inst/u_lscc_sync_axi_interconnect/*.*/u_fifo_interface/*.*/_CDC_EN.dc_fifo/u_fifo0/fifo_dc0/_FABRIC.u_fifo/*/rst_sync*[0]/Q}] -to [get_pins -hierarchical {lscc_axi_interconnect_inst/u_lscc_sync_axi_interconnect/*.*/u_fifo_interface/*.*/_CDC_EN.dc_fifo/u_fifo0/fifo_dc0/_FABRIC.u_fifo/*/rst_sync*[1]/D}] -datapath_only 2
  set_max_delay -from [get_cells -hierarchical {lscc_axi_interconnect_inst/u_lscc_sync_axi_interconnect/*.*/u_fifo_interface/*.*/_CDC_EN.dc_fifo/u_fifo0/fifo_dc0/_FABRIC.u_fifo/distmem_ram*.*}] -datapath_only 2
} else {
  set_false_path -to [get_pins -hierarchical {lscc_axi_interconnect_inst/u_lscc_sync_axi_interconnect/*.*/u_fifo_interface/*.*/_CDC_EN.dc_fifo/u_fifo0/fifo_dc0/_FABRIC.u_fifo/*/rst_sync*[*].ff_inst/LSR}] -through [get_nets -hierarchical {lscc_axi_interconnect_inst/u_lscc_sync_axi_interconnect/*.*/u_fifo_interface/*.*/_CDC_EN.dc_fifo/u_fifo0/fifo_dc0/_FABRIC.u_fifo/*/*aresetn_i*}]
  set_max_delay -from [get_pins -hierarchical {lscc_axi_interconnect_inst/u_lscc_sync_axi_interconnect/*.*/u_fifo_interface/*.*/_CDC_EN.dc_fifo/u_fifo0/fifo_dc0/_FABRIC.u_fifo/*/rst_sync*[0].ff_inst/Q}] -to [get_pins -hierarchical {lscc_axi_interconnect_inst/u_lscc_sync_axi_interconnect/*.*/u_fifo_interface/*.*/_CDC_EN.dc_fifo/u_fifo0/fifo_dc0/_FABRIC.u_fifo/*/rst_sync*[1].ff_inst/DF}] -datapath_only 3.5
  set_max_delay -from [get_cells -hierarchical {lscc_axi_interconnect_inst/u_lscc_sync_axi_interconnect/*.*/u_fifo_interface/*.*/_CDC_EN.dc_fifo/u_fifo0/fifo_dc0/_FABRIC.u_fifo/distmem_ram*.*}] -datapath_only 3.5
}
