// Verilog netlist produced by program LSE 
// Netlist written on Wed Sep 18 11:45:49 2024
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
// Verilog Description of module mpmc0
// module wrapper written out since it is a black-box. 
//

//

module mpmc0 (axi_S01_aclk_i, axi_S01_aresetn_i, axi_S00_aclk_i, axi_S00_aresetn_i, 
            axi_S01_awvalid_i, axi_S01_awid_i, axi_S01_awaddr_i, axi_S01_awlen_i, 
            axi_S01_awsize_i, axi_S01_awburst_i, axi_S01_awlock_i, axi_S01_awcache_i, 
            axi_S01_awprot_i, axi_S01_awqos_i, axi_S01_awregion_i, axi_S01_awuser_i, 
            axi_S01_awready_o, axi_S01_wvalid_i, axi_S01_wdata_i, axi_S01_wstrb_i, 
            axi_S01_wlast_i, axi_S01_wuser_i, axi_S01_wready_o, axi_S01_bready_i, 
            axi_S01_bvalid_o, axi_S01_bid_o, axi_S01_bresp_o, axi_S01_buser_o, 
            axi_S01_arvalid_i, axi_S01_arid_i, axi_S01_araddr_i, axi_S01_arlen_i, 
            axi_S01_arsize_i, axi_S01_arburst_i, axi_S01_arlock_i, axi_S01_arcache_i, 
            axi_S01_arprot_i, axi_S01_arqos_i, axi_S01_arregion_i, axi_S01_aruser_i, 
            axi_S01_arready_o, axi_S01_rready_i, axi_S01_rvalid_o, axi_S01_rid_o, 
            axi_S01_rdata_o, axi_S01_rresp_o, axi_S01_rlast_o, axi_S01_ruser_o, 
            axi_S00_awvalid_i, axi_S00_awid_i, axi_S00_awaddr_i, axi_S00_awlen_i, 
            axi_S00_awsize_i, axi_S00_awburst_i, axi_S00_awlock_i, axi_S00_awcache_i, 
            axi_S00_awprot_i, axi_S00_awqos_i, axi_S00_awregion_i, axi_S00_awuser_i, 
            axi_S00_awready_o, axi_S00_wvalid_i, axi_S00_wdata_i, axi_S00_wstrb_i, 
            axi_S00_wlast_i, axi_S00_wuser_i, axi_S00_wready_o, axi_S00_bready_i, 
            axi_S00_bvalid_o, axi_S00_bid_o, axi_S00_bresp_o, axi_S00_buser_o, 
            axi_S00_arvalid_i, axi_S00_arid_i, axi_S00_araddr_i, axi_S00_arlen_i, 
            axi_S00_arsize_i, axi_S00_arburst_i, axi_S00_arlock_i, axi_S00_arcache_i, 
            axi_S00_arprot_i, axi_S00_arqos_i, axi_S00_arregion_i, axi_S00_aruser_i, 
            axi_S00_arready_o, axi_S00_rready_i, axi_S00_rvalid_o, axi_S00_rid_o, 
            axi_S00_rdata_o, axi_S00_rresp_o, axi_S00_rlast_o, axi_S00_ruser_o, 
            axi_M00_aclk_i, axi_M00_aresetn_i, axi_M00_awvalid_o, axi_M00_awid_o, 
            axi_M00_awaddr_o, axi_M00_awlen_o, axi_M00_awsize_o, axi_M00_awburst_o, 
            axi_M00_awlock_o, axi_M00_awcache_o, axi_M00_awprot_o, axi_M00_awqos_o, 
            axi_M00_awregion_o, axi_M00_awuser_o, axi_M00_awready_i, axi_M00_wvalid_o, 
            axi_M00_wdata_o, axi_M00_wstrb_o, axi_M00_wlast_o, axi_M00_wuser_o, 
            axi_M00_wready_i, axi_M00_bvalid_i, axi_M00_bid_i, axi_M00_bresp_i, 
            axi_M00_buser_i, axi_M00_bready_o, axi_M00_arvalid_o, axi_M00_arid_o, 
            axi_M00_araddr_o, axi_M00_arlen_o, axi_M00_arsize_o, axi_M00_arburst_o, 
            axi_M00_arlock_o, axi_M00_arcache_o, axi_M00_arprot_o, axi_M00_arqos_o, 
            axi_M00_arregion_o, axi_M00_aruser_o, axi_M00_arready_i, axi_M00_rvalid_i, 
            axi_M00_rid_i, axi_M00_rdata_i, axi_M00_rresp_i, axi_M00_rlast_i, 
            axi_M00_ruser_i, axi_M00_rready_o) /* synthesis ORIG_MODULE_NAME="mpmc0", LATTICE_IP_GENERATED="1", cpe_box=1 */ ;
    input [0:0]axi_S01_aclk_i;
    input [0:0]axi_S01_aresetn_i;
    input [0:0]axi_S00_aclk_i;
    input [0:0]axi_S00_aresetn_i;
    input [0:0]axi_S01_awvalid_i;
    input [3:0]axi_S01_awid_i;
    input [31:0]axi_S01_awaddr_i;
    input [7:0]axi_S01_awlen_i;
    input [2:0]axi_S01_awsize_i;
    input [1:0]axi_S01_awburst_i;
    input [0:0]axi_S01_awlock_i;
    input [3:0]axi_S01_awcache_i;
    input [2:0]axi_S01_awprot_i;
    input [3:0]axi_S01_awqos_i;
    input [3:0]axi_S01_awregion_i;
    input [0:0]axi_S01_awuser_i;
    output [0:0]axi_S01_awready_o;
    input [0:0]axi_S01_wvalid_i;
    input [31:0]axi_S01_wdata_i;
    input [3:0]axi_S01_wstrb_i;
    input [0:0]axi_S01_wlast_i;
    input [0:0]axi_S01_wuser_i;
    output [0:0]axi_S01_wready_o;
    input [0:0]axi_S01_bready_i;
    output [0:0]axi_S01_bvalid_o;
    output [3:0]axi_S01_bid_o;
    output [1:0]axi_S01_bresp_o;
    output [0:0]axi_S01_buser_o;
    input [0:0]axi_S01_arvalid_i;
    input [3:0]axi_S01_arid_i;
    input [31:0]axi_S01_araddr_i;
    input [7:0]axi_S01_arlen_i;
    input [2:0]axi_S01_arsize_i;
    input [1:0]axi_S01_arburst_i;
    input [0:0]axi_S01_arlock_i;
    input [3:0]axi_S01_arcache_i;
    input [2:0]axi_S01_arprot_i;
    input [3:0]axi_S01_arqos_i;
    input [3:0]axi_S01_arregion_i;
    input [0:0]axi_S01_aruser_i;
    output [0:0]axi_S01_arready_o;
    input [0:0]axi_S01_rready_i;
    output [0:0]axi_S01_rvalid_o;
    output [3:0]axi_S01_rid_o;
    output [31:0]axi_S01_rdata_o;
    output [1:0]axi_S01_rresp_o;
    output [0:0]axi_S01_rlast_o;
    output [0:0]axi_S01_ruser_o;
    input [0:0]axi_S00_awvalid_i;
    input [3:0]axi_S00_awid_i;
    input [31:0]axi_S00_awaddr_i;
    input [7:0]axi_S00_awlen_i;
    input [2:0]axi_S00_awsize_i;
    input [1:0]axi_S00_awburst_i;
    input [0:0]axi_S00_awlock_i;
    input [3:0]axi_S00_awcache_i;
    input [2:0]axi_S00_awprot_i;
    input [3:0]axi_S00_awqos_i;
    input [3:0]axi_S00_awregion_i;
    input [0:0]axi_S00_awuser_i;
    output [0:0]axi_S00_awready_o;
    input [0:0]axi_S00_wvalid_i;
    input [31:0]axi_S00_wdata_i;
    input [3:0]axi_S00_wstrb_i;
    input [0:0]axi_S00_wlast_i;
    input [0:0]axi_S00_wuser_i;
    output [0:0]axi_S00_wready_o;
    input [0:0]axi_S00_bready_i;
    output [0:0]axi_S00_bvalid_o;
    output [3:0]axi_S00_bid_o;
    output [1:0]axi_S00_bresp_o;
    output [0:0]axi_S00_buser_o;
    input [0:0]axi_S00_arvalid_i;
    input [3:0]axi_S00_arid_i;
    input [31:0]axi_S00_araddr_i;
    input [7:0]axi_S00_arlen_i;
    input [2:0]axi_S00_arsize_i;
    input [1:0]axi_S00_arburst_i;
    input [0:0]axi_S00_arlock_i;
    input [3:0]axi_S00_arcache_i;
    input [2:0]axi_S00_arprot_i;
    input [3:0]axi_S00_arqos_i;
    input [3:0]axi_S00_arregion_i;
    input [0:0]axi_S00_aruser_i;
    output [0:0]axi_S00_arready_o;
    input [0:0]axi_S00_rready_i;
    output [0:0]axi_S00_rvalid_o;
    output [3:0]axi_S00_rid_o;
    output [31:0]axi_S00_rdata_o;
    output [1:0]axi_S00_rresp_o;
    output [0:0]axi_S00_rlast_o;
    output [0:0]axi_S00_ruser_o;
    input [0:0]axi_M00_aclk_i;
    input [0:0]axi_M00_aresetn_i;
    output [0:0]axi_M00_awvalid_o;
    output [3:0]axi_M00_awid_o;
    output [31:0]axi_M00_awaddr_o;
    output [7:0]axi_M00_awlen_o;
    output [2:0]axi_M00_awsize_o;
    output [1:0]axi_M00_awburst_o;
    output [0:0]axi_M00_awlock_o;
    output [3:0]axi_M00_awcache_o;
    output [2:0]axi_M00_awprot_o;
    output [3:0]axi_M00_awqos_o;
    output [3:0]axi_M00_awregion_o;
    output [0:0]axi_M00_awuser_o;
    input [0:0]axi_M00_awready_i;
    output [0:0]axi_M00_wvalid_o;
    output [255:0]axi_M00_wdata_o;
    output [31:0]axi_M00_wstrb_o;
    output [0:0]axi_M00_wlast_o;
    output [0:0]axi_M00_wuser_o;
    input [0:0]axi_M00_wready_i;
    input [0:0]axi_M00_bvalid_i;
    input [3:0]axi_M00_bid_i;
    input [1:0]axi_M00_bresp_i;
    input [0:0]axi_M00_buser_i;
    output [0:0]axi_M00_bready_o;
    output [0:0]axi_M00_arvalid_o;
    output [3:0]axi_M00_arid_o;
    output [31:0]axi_M00_araddr_o;
    output [7:0]axi_M00_arlen_o;
    output [2:0]axi_M00_arsize_o;
    output [1:0]axi_M00_arburst_o;
    output [0:0]axi_M00_arlock_o;
    output [3:0]axi_M00_arcache_o;
    output [2:0]axi_M00_arprot_o;
    output [3:0]axi_M00_arqos_o;
    output [3:0]axi_M00_arregion_o;
    output [0:0]axi_M00_aruser_o;
    input [0:0]axi_M00_arready_i;
    input [0:0]axi_M00_rvalid_i;
    input [3:0]axi_M00_rid_i;
    input [255:0]axi_M00_rdata_i;
    input [1:0]axi_M00_rresp_i;
    input [0:0]axi_M00_rlast_i;
    input [0:0]axi_M00_ruser_i;
    output [0:0]axi_M00_rready_o;
    
    
    
endmodule
