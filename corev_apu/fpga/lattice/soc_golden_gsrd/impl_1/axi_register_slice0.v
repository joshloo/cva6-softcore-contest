// Verilog netlist produced by program LSE 
// Netlist written on Wed Sep 18 11:45:46 2024
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
// Verilog Description of module axi_register_slice0
// module wrapper written out since it is a black-box. 
//

//

module axi_register_slice0 (a_clk_i, a_reset_n_i, s_axi_awid_i, s_axi_awaddr_i, 
            s_axi_awlen_i, s_axi_awsize_i, s_axi_awburst_i, s_axi_awlock_i, 
            s_axi_awcache_i, s_axi_awprot_i, s_axi_awregion_i, s_axi_awqos_i, 
            s_axi_awuser_i, s_axi_awvalid_i, s_axi_awready_o, s_axi_wdata_i, 
            s_axi_wstrb_i, s_axi_wlast_i, s_axi_wuser_i, s_axi_wvalid_i, 
            s_axi_wready_o, s_axi_bid_o, s_axi_bresp_o, s_axi_buser_o, 
            s_axi_bvalid_o, s_axi_bready_i, s_axi_arid_i, s_axi_araddr_i, 
            s_axi_arlen_i, s_axi_arsize_i, s_axi_arburst_i, s_axi_arlock_i, 
            s_axi_arcache_i, s_axi_arprot_i, s_axi_arregion_i, s_axi_arqos_i, 
            s_axi_aruser_i, s_axi_arvalid_i, s_axi_arready_o, s_axi_rid_o, 
            s_axi_rdata_o, s_axi_rresp_o, s_axi_rlast_o, s_axi_ruser_o, 
            s_axi_rvalid_o, s_axi_rready_i, m_axi_awid_o, m_axi_awaddr_o, 
            m_axi_awlen_o, m_axi_awsize_o, m_axi_awburst_o, m_axi_awlock_o, 
            m_axi_awcache_o, m_axi_awprot_o, m_axi_awregion_o, m_axi_awqos_o, 
            m_axi_awuser_o, m_axi_awvalid_o, m_axi_awready_i, m_axi_wdata_o, 
            m_axi_wstrb_o, m_axi_wlast_o, m_axi_wuser_o, m_axi_wvalid_o, 
            m_axi_wready_i, m_axi_bid_i, m_axi_bresp_i, m_axi_buser_i, 
            m_axi_bvalid_i, m_axi_bready_o, m_axi_arid_o, m_axi_araddr_o, 
            m_axi_arlen_o, m_axi_arsize_o, m_axi_arburst_o, m_axi_arlock_o, 
            m_axi_arcache_o, m_axi_arprot_o, m_axi_arregion_o, m_axi_arqos_o, 
            m_axi_aruser_o, m_axi_arvalid_o, m_axi_arready_i, m_axi_rid_i, 
            m_axi_rdata_i, m_axi_rresp_i, m_axi_rlast_i, m_axi_ruser_i, 
            m_axi_rvalid_i, m_axi_rready_o) /* synthesis ORIG_MODULE_NAME="axi_register_slice0", LATTICE_IP_GENERATED="1", cpe_box=1 */ ;
    input a_clk_i;
    input a_reset_n_i;
    input [3:0]s_axi_awid_i;
    input [31:0]s_axi_awaddr_i;
    input [7:0]s_axi_awlen_i;
    input [2:0]s_axi_awsize_i;
    input [1:0]s_axi_awburst_i;
    input [0:0]s_axi_awlock_i;
    input [3:0]s_axi_awcache_i;
    input [2:0]s_axi_awprot_i;
    input [3:0]s_axi_awregion_i;
    input [3:0]s_axi_awqos_i;
    input [0:0]s_axi_awuser_i;
    input s_axi_awvalid_i;
    output s_axi_awready_o;
    input [31:0]s_axi_wdata_i;
    input [3:0]s_axi_wstrb_i;
    input s_axi_wlast_i;
    input [0:0]s_axi_wuser_i;
    input s_axi_wvalid_i;
    output s_axi_wready_o;
    output [3:0]s_axi_bid_o;
    output [1:0]s_axi_bresp_o;
    output [0:0]s_axi_buser_o;
    output s_axi_bvalid_o;
    input s_axi_bready_i;
    input [3:0]s_axi_arid_i;
    input [31:0]s_axi_araddr_i;
    input [7:0]s_axi_arlen_i;
    input [2:0]s_axi_arsize_i;
    input [1:0]s_axi_arburst_i;
    input [0:0]s_axi_arlock_i;
    input [3:0]s_axi_arcache_i;
    input [2:0]s_axi_arprot_i;
    input [3:0]s_axi_arregion_i;
    input [3:0]s_axi_arqos_i;
    input [0:0]s_axi_aruser_i;
    input s_axi_arvalid_i;
    output s_axi_arready_o;
    output [3:0]s_axi_rid_o;
    output [31:0]s_axi_rdata_o;
    output [1:0]s_axi_rresp_o;
    output s_axi_rlast_o;
    output [0:0]s_axi_ruser_o;
    output s_axi_rvalid_o;
    input s_axi_rready_i;
    output [3:0]m_axi_awid_o;
    output [31:0]m_axi_awaddr_o;
    output [7:0]m_axi_awlen_o;
    output [2:0]m_axi_awsize_o;
    output [1:0]m_axi_awburst_o;
    output [0:0]m_axi_awlock_o;
    output [3:0]m_axi_awcache_o;
    output [2:0]m_axi_awprot_o;
    output [3:0]m_axi_awregion_o;
    output [3:0]m_axi_awqos_o;
    output [0:0]m_axi_awuser_o;
    output m_axi_awvalid_o;
    input m_axi_awready_i;
    output [31:0]m_axi_wdata_o;
    output [3:0]m_axi_wstrb_o;
    output m_axi_wlast_o;
    output [0:0]m_axi_wuser_o;
    output m_axi_wvalid_o;
    input m_axi_wready_i;
    input [3:0]m_axi_bid_i;
    input [1:0]m_axi_bresp_i;
    input [0:0]m_axi_buser_i;
    input m_axi_bvalid_i;
    output m_axi_bready_o;
    output [3:0]m_axi_arid_o;
    output [31:0]m_axi_araddr_o;
    output [7:0]m_axi_arlen_o;
    output [2:0]m_axi_arsize_o;
    output [1:0]m_axi_arburst_o;
    output [0:0]m_axi_arlock_o;
    output [3:0]m_axi_arcache_o;
    output [2:0]m_axi_arprot_o;
    output [3:0]m_axi_arregion_o;
    output [3:0]m_axi_arqos_o;
    output [0:0]m_axi_aruser_o;
    output m_axi_arvalid_o;
    input m_axi_arready_i;
    input [3:0]m_axi_rid_i;
    input [31:0]m_axi_rdata_i;
    input [1:0]m_axi_rresp_i;
    input m_axi_rlast_i;
    input [0:0]m_axi_ruser_i;
    input m_axi_rvalid_i;
    output m_axi_rready_o;
    
    
    
endmodule
