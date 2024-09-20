// Verilog netlist produced by program LSE 
// Netlist written on Wed Sep 18 11:45:48 2024
// Source file index table: 
// Object locations will have the form @<file_index>(<first_ line>[<left_column>],<last_line>[<right_column>])
// file 0 "c:/lscc/radiant/2024.1/ip/common/adder/rtl/lscc_adder.v"
// file 1 "c:/lscc/radiant/2024.1/ip/common/adder_subtractor/rtl/lscc_add_sub.v"
// file 2 "c:/lscc/radiant/2024.1/ip/common/complex_mult/rtl/lscc_complex_mult.v"
// file 3 "c:/lscc/radiant/2024.1/ip/common/counter/rtl/lscc_cntr.v"
// file 4 "c:/lscc/radiant/2024.1/ip/common/distributed_dpram/rtl/lscc_distributed_dpram.v"
// file 5 "c:/lscc/radiant/2024.1/ip/common/distributed_rom/rtl/lscc_distributed_rom.v"
// file 6 "c:/lscc/radiant/2024.1/ip/common/distributed_spram/rtl/lscc_distributed_spram.v"
// file 7 "c:/lscc/radiant/2024.1/ip/common/fifo/rtl/lscc_fifo.v"
// file 8 "c:/lscc/radiant/2024.1/ip/common/fifo_dc/rtl/lscc_fifo_dc.v"
// file 9 "c:/lscc/radiant/2024.1/ip/common/mult_accumulate/rtl/lscc_mult_accumulate.v"
// file 10 "c:/lscc/radiant/2024.1/ip/common/mult_add_sub/rtl/lscc_mult_add_sub.v"
// file 11 "c:/lscc/radiant/2024.1/ip/common/mult_add_sub_sum/rtl/lscc_mult_add_sub_sum.v"
// file 12 "c:/lscc/radiant/2024.1/ip/common/multiplier/rtl/lscc_multiplier.v"
// file 13 "c:/lscc/radiant/2024.1/ip/common/ram_dp/rtl/lscc_ram_dp.v"
// file 14 "c:/lscc/radiant/2024.1/ip/common/ram_dp_true/rtl/lscc_ram_dp_true.v"
// file 15 "c:/lscc/radiant/2024.1/ip/common/ram_dq/rtl/lscc_ram_dq.v"
// file 16 "c:/lscc/radiant/2024.1/ip/common/ram_shift_reg/rtl/lscc_shift_register.v"
// file 17 "c:/lscc/radiant/2024.1/ip/common/rom/rtl/lscc_rom.v"
// file 18 "c:/lscc/radiant/2024.1/ip/common/subtractor/rtl/lscc_subtractor.v"
// file 19 "c:/lscc/radiant/2024.1/ip/pmi/pmi_add.v"
// file 20 "c:/lscc/radiant/2024.1/ip/pmi/pmi_addsub.v"
// file 21 "c:/lscc/radiant/2024.1/ip/pmi/pmi_complex_mult.v"
// file 22 "c:/lscc/radiant/2024.1/ip/pmi/pmi_counter.v"
// file 23 "c:/lscc/radiant/2024.1/ip/pmi/pmi_distributed_dpram.v"
// file 24 "c:/lscc/radiant/2024.1/ip/pmi/pmi_distributed_rom.v"
// file 25 "c:/lscc/radiant/2024.1/ip/pmi/pmi_distributed_shift_reg.v"
// file 26 "c:/lscc/radiant/2024.1/ip/pmi/pmi_distributed_spram.v"
// file 27 "c:/lscc/radiant/2024.1/ip/pmi/pmi_fifo.v"
// file 28 "c:/lscc/radiant/2024.1/ip/pmi/pmi_fifo_dc.v"
// file 29 "c:/lscc/radiant/2024.1/ip/pmi/pmi_mac.v"
// file 30 "c:/lscc/radiant/2024.1/ip/pmi/pmi_mult.v"
// file 31 "c:/lscc/radiant/2024.1/ip/pmi/pmi_multaddsub.v"
// file 32 "c:/lscc/radiant/2024.1/ip/pmi/pmi_multaddsubsum.v"
// file 33 "c:/lscc/radiant/2024.1/ip/pmi/pmi_ram_dp.v"
// file 34 "c:/lscc/radiant/2024.1/ip/pmi/pmi_ram_dp_be.v"
// file 35 "c:/lscc/radiant/2024.1/ip/pmi/pmi_ram_dp_true.v"
// file 36 "c:/lscc/radiant/2024.1/ip/pmi/pmi_ram_dq.v"
// file 37 "c:/lscc/radiant/2024.1/ip/pmi/pmi_ram_dq_be.v"
// file 38 "c:/lscc/radiant/2024.1/ip/pmi/pmi_rom.v"
// file 39 "c:/lscc/radiant/2024.1/ip/pmi/pmi_sub.v"
// file 40 "c:/lscc/radiant/2024.1/cae_library/simulation/verilog/applatform/dpr16x4a.v"
// file 41 "c:/lscc/radiant/2024.1/cae_library/simulation/verilog/applatform/dpr32x2.v"
// file 42 "c:/lscc/radiant/2024.1/cae_library/simulation/verilog/applatform/spr16x4a.v"
// file 43 "c:/lscc/radiant/2024.1/cae_library/simulation/verilog/applatform/spr32x2.v"
// file 44 "c:/lscc/radiant/2024.1/cae_library/simulation/verilog/applatform/widefn9.v"
// file 45 "c:/lscc/radiant/2024.1/cae_library/simulation/verilog/applatform/io_specialprim.v"

//
// Verilog Description of module sgdma0
// module wrapper written out since it is a black-box. 
//

//

module sgdma0 (clk, rstn, axil_clk, axil_rstn, s_axil_awaddr_i, s_axil_awprot_i, 
            s_axil_awvalid_i, s_axil_awready_o, s_axil_wdata_i, s_axil_wstrb_i, 
            s_axil_wvalid_i, s_axil_wready_o, s_axil_bresp_o, s_axil_bvalid_o, 
            s_axil_bready_i, s_axil_araddr_i, s_axil_arprot_i, s_axil_arvalid_i, 
            s_axil_arready_o, s_axil_rdata_o, s_axil_rresp_o, s_axil_rvalid_o, 
            s_axil_rready_i, m_axi_mm2s_arready_i, m_axi_mm2s_arid_o, 
            m_axi_mm2s_araddr_o, m_axi_mm2s_arregion_o, m_axi_mm2s_arlen_o, 
            m_axi_mm2s_arsize_o, m_axi_mm2s_arburst_o, m_axi_mm2s_arlock_o, 
            m_axi_mm2s_arcache_o, m_axi_mm2s_arprot_o, m_axi_mm2s_arqos_o, 
            m_axi_mm2s_arvalid_o, m_axi_mm2s_rready_o, m_axi_mm2s_rid_i, 
            m_axi_mm2s_rdata_i, m_axi_mm2s_rresp_i, m_axi_mm2s_rlast_i, 
            m_axi_mm2s_rvalid_i, m_axi_s2mm_awready_i, m_axi_s2mm_awid_o, 
            m_axi_s2mm_awaddr_o, m_axi_s2mm_awregion_o, m_axi_s2mm_awlen_o, 
            m_axi_s2mm_awsize_o, m_axi_s2mm_awburst_o, m_axi_s2mm_awlock_o, 
            m_axi_s2mm_awcache_o, m_axi_s2mm_awprot_o, m_axi_s2mm_awqos_o, 
            m_axi_s2mm_awvalid_o, m_axi_s2mm_wready_i, m_axi_s2mm_wdata_o, 
            m_axi_s2mm_wstrb_o, m_axi_s2mm_wlast_o, m_axi_s2mm_wvalid_o, 
            m_axi_s2mm_bready_o, m_axi_s2mm_bid_i, m_axi_s2mm_bresp_i, 
            m_axi_s2mm_bvalid_i, m_axi_bd_awready_i, m_axi_bd_awid_o, 
            m_axi_bd_awaddr_o, m_axi_bd_awregion_o, m_axi_bd_awlen_o, 
            m_axi_bd_awsize_o, m_axi_bd_awburst_o, m_axi_bd_awlock_o, 
            m_axi_bd_awcache_o, m_axi_bd_awprot_o, m_axi_bd_awqos_o, m_axi_bd_awvalid_o, 
            m_axi_bd_wready_i, m_axi_bd_wdata_o, m_axi_bd_wstrb_o, m_axi_bd_wlast_o, 
            m_axi_bd_wvalid_o, m_axi_bd_bready_o, m_axi_bd_bid_i, m_axi_bd_bresp_i, 
            m_axi_bd_bvalid_i, m_axi_bd_arready_i, m_axi_bd_arid_o, m_axi_bd_araddr_o, 
            m_axi_bd_arregion_o, m_axi_bd_arlen_o, m_axi_bd_arsize_o, 
            m_axi_bd_arburst_o, m_axi_bd_arlock_o, m_axi_bd_arcache_o, 
            m_axi_bd_arprot_o, m_axi_bd_arqos_o, m_axi_bd_arvalid_o, m_axi_bd_rready_o, 
            m_axi_bd_rid_i, m_axi_bd_rdata_i, m_axi_bd_rresp_i, m_axi_bd_rlast_i, 
            m_axi_bd_rvalid_i, tx_axis_mm2s_tready_i, tx_axis_mm2s_tvalid_o, 
            tx_axis_mm2s_tdata_o, tx_axis_mm2s_tkeep_o, tx_axis_mm2s_tlast_o, 
            tx_axis_mm2s_tid_o, tx_axis_mm2s_tdest_o, rx_axis_s2mm_tvalid_i, 
            rx_axis_s2mm_tdata_i, rx_axis_s2mm_tkeep_i, rx_axis_s2mm_tlast_i, 
            rx_axis_s2mm_tid_i, rx_axis_s2mm_tready_o, rx_axis_s2mm_tdest_i, 
            s2mm_xfer_cmpl_irq_o, mm2s_xfer_cmpl_irq_o) /* synthesis ORIG_MODULE_NAME="sgdma0", LATTICE_IP_GENERATED="1", cpe_box=1 */ ;
    input clk;
    input rstn;
    input axil_clk;
    input axil_rstn;
    input [31:0]s_axil_awaddr_i;
    input [2:0]s_axil_awprot_i;
    input s_axil_awvalid_i;
    output s_axil_awready_o;
    input [31:0]s_axil_wdata_i;
    input [3:0]s_axil_wstrb_i;
    input s_axil_wvalid_i;
    output s_axil_wready_o;
    output [1:0]s_axil_bresp_o;
    output s_axil_bvalid_o;
    input s_axil_bready_i;
    input [31:0]s_axil_araddr_i;
    input [2:0]s_axil_arprot_i;
    input s_axil_arvalid_i;
    output s_axil_arready_o;
    output [31:0]s_axil_rdata_o;
    output [1:0]s_axil_rresp_o;
    output s_axil_rvalid_o;
    input s_axil_rready_i;
    input m_axi_mm2s_arready_i;
    output [1:0]m_axi_mm2s_arid_o;
    output [31:0]m_axi_mm2s_araddr_o;
    output [3:0]m_axi_mm2s_arregion_o;
    output [7:0]m_axi_mm2s_arlen_o;
    output [2:0]m_axi_mm2s_arsize_o;
    output [1:0]m_axi_mm2s_arburst_o;
    output m_axi_mm2s_arlock_o;
    output [3:0]m_axi_mm2s_arcache_o;
    output [2:0]m_axi_mm2s_arprot_o;
    output [3:0]m_axi_mm2s_arqos_o;
    output m_axi_mm2s_arvalid_o;
    output m_axi_mm2s_rready_o;
    input [1:0]m_axi_mm2s_rid_i;
    input [31:0]m_axi_mm2s_rdata_i;
    input [1:0]m_axi_mm2s_rresp_i;
    input m_axi_mm2s_rlast_i;
    input m_axi_mm2s_rvalid_i;
    input m_axi_s2mm_awready_i;
    output [1:0]m_axi_s2mm_awid_o;
    output [31:0]m_axi_s2mm_awaddr_o;
    output [3:0]m_axi_s2mm_awregion_o;
    output [7:0]m_axi_s2mm_awlen_o;
    output [2:0]m_axi_s2mm_awsize_o;
    output [1:0]m_axi_s2mm_awburst_o;
    output m_axi_s2mm_awlock_o;
    output [3:0]m_axi_s2mm_awcache_o;
    output [2:0]m_axi_s2mm_awprot_o;
    output [3:0]m_axi_s2mm_awqos_o;
    output m_axi_s2mm_awvalid_o;
    input m_axi_s2mm_wready_i;
    output [31:0]m_axi_s2mm_wdata_o;
    output [3:0]m_axi_s2mm_wstrb_o;
    output m_axi_s2mm_wlast_o;
    output m_axi_s2mm_wvalid_o;
    output m_axi_s2mm_bready_o;
    input [1:0]m_axi_s2mm_bid_i;
    input [1:0]m_axi_s2mm_bresp_i;
    input m_axi_s2mm_bvalid_i;
    input m_axi_bd_awready_i;
    output [1:0]m_axi_bd_awid_o;
    output [31:0]m_axi_bd_awaddr_o;
    output [3:0]m_axi_bd_awregion_o;
    output [7:0]m_axi_bd_awlen_o;
    output [2:0]m_axi_bd_awsize_o;
    output [1:0]m_axi_bd_awburst_o;
    output m_axi_bd_awlock_o;
    output [3:0]m_axi_bd_awcache_o;
    output [2:0]m_axi_bd_awprot_o;
    output [3:0]m_axi_bd_awqos_o;
    output m_axi_bd_awvalid_o;
    input m_axi_bd_wready_i;
    output [31:0]m_axi_bd_wdata_o;
    output [3:0]m_axi_bd_wstrb_o;
    output m_axi_bd_wlast_o;
    output m_axi_bd_wvalid_o;
    output m_axi_bd_bready_o;
    input [1:0]m_axi_bd_bid_i;
    input [1:0]m_axi_bd_bresp_i;
    input m_axi_bd_bvalid_i;
    input m_axi_bd_arready_i;
    output [1:0]m_axi_bd_arid_o;
    output [31:0]m_axi_bd_araddr_o;
    output [3:0]m_axi_bd_arregion_o;
    output [7:0]m_axi_bd_arlen_o;
    output [2:0]m_axi_bd_arsize_o;
    output [1:0]m_axi_bd_arburst_o;
    output m_axi_bd_arlock_o;
    output [3:0]m_axi_bd_arcache_o;
    output [2:0]m_axi_bd_arprot_o;
    output [3:0]m_axi_bd_arqos_o;
    output m_axi_bd_arvalid_o;
    output m_axi_bd_rready_o;
    input [1:0]m_axi_bd_rid_i;
    input [31:0]m_axi_bd_rdata_i;
    input [1:0]m_axi_bd_rresp_i;
    input m_axi_bd_rlast_i;
    input m_axi_bd_rvalid_i;
    input tx_axis_mm2s_tready_i;
    output tx_axis_mm2s_tvalid_o;
    output [7:0]tx_axis_mm2s_tdata_o;
    output [0:0]tx_axis_mm2s_tkeep_o;
    output tx_axis_mm2s_tlast_o;
    output [3:0]tx_axis_mm2s_tid_o;
    output [3:0]tx_axis_mm2s_tdest_o;
    input rx_axis_s2mm_tvalid_i;
    input [7:0]rx_axis_s2mm_tdata_i;
    input [0:0]rx_axis_s2mm_tkeep_i;
    input rx_axis_s2mm_tlast_i;
    input [3:0]rx_axis_s2mm_tid_i;
    output rx_axis_s2mm_tready_o;
    input [3:0]rx_axis_s2mm_tdest_i;
    output s2mm_xfer_cmpl_irq_o;
    output mm2s_xfer_cmpl_irq_o;
    
    
    
endmodule
