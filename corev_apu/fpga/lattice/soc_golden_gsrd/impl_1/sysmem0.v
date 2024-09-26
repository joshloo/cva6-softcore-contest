// Verilog netlist produced by program LSE 
// Netlist written on Wed Sep 18 11:45:59 2024
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
// Verilog Description of module sysmem0
// module wrapper written out since it is a black-box. 
//

//

module sysmem0 (axi_aclk_i, axi_resetn_i, axi_s0_awaddr_i, axi_s0_awvalid_i, 
            axi_s0_awprot_i, axi_s0_awready_o, axi_s0_awid_i, axi_s0_awlen_i, 
            axi_s0_awsize_i, axi_s0_awburst_i, axi_s0_awlock_i, axi_s0_awcache_i, 
            axi_s0_awqos_i, axi_s0_awregion_i, axi_s0_wdata_i, axi_s0_wstrb_i, 
            axi_s0_wvalid_i, axi_s0_wready_o, axi_s0_wlast_i, axi_s0_bready_i, 
            axi_s0_bresp_o, axi_s0_bvalid_o, axi_s0_bid_o, axi_s0_araddr_i, 
            axi_s0_arvalid_i, axi_s0_arprot_i, axi_s0_arready_o, axi_s0_arid_i, 
            axi_s0_arlen_i, axi_s0_arsize_i, axi_s0_arburst_i, axi_s0_arlock_i, 
            axi_s0_arcache_i, axi_s0_arqos_i, axi_s0_arregion_i, axi_s0_rdata_o, 
            axi_s0_rready_i, axi_s0_rresp_o, axi_s0_rvalid_o, axi_s0_rid_o, 
            axi_s0_rlast_o) /* synthesis ORIG_MODULE_NAME="sysmem0", LATTICE_IP_GENERATED="1", cpe_box=1 */ ;
    input axi_aclk_i;
    input axi_resetn_i;
    input [31:0]axi_s0_awaddr_i;
    input axi_s0_awvalid_i;
    input [2:0]axi_s0_awprot_i;
    output axi_s0_awready_o;
    input [3:0]axi_s0_awid_i;
    input [7:0]axi_s0_awlen_i;
    input [2:0]axi_s0_awsize_i;
    input [1:0]axi_s0_awburst_i;
    input axi_s0_awlock_i;
    input [3:0]axi_s0_awcache_i;
    input [3:0]axi_s0_awqos_i;
    input [3:0]axi_s0_awregion_i;
    input [31:0]axi_s0_wdata_i;
    input [3:0]axi_s0_wstrb_i;
    input axi_s0_wvalid_i;
    output axi_s0_wready_o;
    input axi_s0_wlast_i;
    input axi_s0_bready_i;
    output [1:0]axi_s0_bresp_o;
    output axi_s0_bvalid_o;
    output [3:0]axi_s0_bid_o;
    input [31:0]axi_s0_araddr_i;
    input axi_s0_arvalid_i;
    input [2:0]axi_s0_arprot_i;
    output axi_s0_arready_o;
    input [3:0]axi_s0_arid_i;
    input [7:0]axi_s0_arlen_i;
    input [2:0]axi_s0_arsize_i;
    input [1:0]axi_s0_arburst_i;
    input axi_s0_arlock_i;
    input [3:0]axi_s0_arcache_i;
    input [3:0]axi_s0_arqos_i;
    input [3:0]axi_s0_arregion_i;
    output [31:0]axi_s0_rdata_o;
    input axi_s0_rready_i;
    output [1:0]axi_s0_rresp_o;
    output axi_s0_rvalid_o;
    output [3:0]axi_s0_rid_o;
    output axi_s0_rlast_o;
    
    
    
endmodule
