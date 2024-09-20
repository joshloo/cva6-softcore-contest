// Verilog netlist produced by program LSE 
// Netlist written on Wed Sep 18 11:45:44 2024
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
// Verilog Description of module qspi0
// module wrapper written out since it is a black-box. 
//

//

module qspi0 (a_clk_i, a_reset_n_i, int_o, qspi_io0, qspi_io1, qspi_io2, 
            qspi_io3, sclk_o, ss_n_o, axi_awid_i, axi_awaddr_i, axi_awlen_i, 
            axi_awsize_i, axi_awburst_i, axi_awlock_i, axi_awcache_i, 
            axi_awprot_i, axi_awvalid_i, axi_awready_o, axi_wdata_i, 
            axi_wstrb_i, axi_wlast_i, axi_wvalid_i, axi_wready_o, axi_bid_o, 
            axi_bresp_o, axi_bvalid_o, axi_bready_i, axi_arid_i, axi_araddr_i, 
            axi_arlen_i, axi_arsize_i, axi_arburst_i, axi_arlock_i, 
            axi_arcache_i, axi_arprot_i, axi_arvalid_i, axi_arready_o, 
            axi_rid_o, axi_rdata_o, axi_rresp_o, axi_rlast_o, axi_rvalid_o, 
            axi_rready_i) /* synthesis ORIG_MODULE_NAME="qspi0", LATTICE_IP_GENERATED="1", cpe_box=1 */ ;
    input a_clk_i;
    input a_reset_n_i;
    output int_o;
    inout qspi_io0;
    inout qspi_io1;
    inout qspi_io2;
    inout qspi_io3;
    output sclk_o;
    output [0:0]ss_n_o;
    input [3:0]axi_awid_i;
    input [31:0]axi_awaddr_i;
    input [7:0]axi_awlen_i;
    input [2:0]axi_awsize_i;
    input [1:0]axi_awburst_i;
    input [0:0]axi_awlock_i;
    input [3:0]axi_awcache_i;
    input [2:0]axi_awprot_i;
    input axi_awvalid_i;
    output axi_awready_o;
    input [31:0]axi_wdata_i;
    input [3:0]axi_wstrb_i;
    input axi_wlast_i;
    input axi_wvalid_i;
    output axi_wready_o;
    output [3:0]axi_bid_o;
    output [1:0]axi_bresp_o;
    output axi_bvalid_o;
    input axi_bready_i;
    input [3:0]axi_arid_i;
    input [31:0]axi_araddr_i;
    input [7:0]axi_arlen_i;
    input [2:0]axi_arsize_i;
    input [1:0]axi_arburst_i;
    input [0:0]axi_arlock_i;
    input [3:0]axi_arcache_i;
    input [2:0]axi_arprot_i;
    input axi_arvalid_i;
    output axi_arready_o;
    output [3:0]axi_rid_o;
    output [31:0]axi_rdata_o;
    output [1:0]axi_rresp_o;
    output axi_rlast_o;
    output axi_rvalid_o;
    input axi_rready_i;
    
    
    
endmodule
