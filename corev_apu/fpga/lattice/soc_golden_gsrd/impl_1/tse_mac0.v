// Verilog netlist produced by program LSE 
// Netlist written on Wed Sep 18 11:45:43 2024
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
// Verilog Description of module tse_mac0
// module wrapper written out since it is a black-box. 
//

//

module tse_mac0 (int_o, ignore_pkt_i, reset_n_i, mdo_o, rx_error_o, 
            apb_pready_o, axis_rx_tvalid_o, rx_fifo_error_o, rx_dv_i, 
            axis_rx_tready_i, tx_discfrm_o, tx_sndpausreq_i, tx_er_o, 
            rx_stat_vector_o, rxd_i, apb_pslverr_o, clk_i, rxmac_clk_i, 
            txmac_clk_i, apb_paddr_i, apb_prdata_o, rx_eof_o, tx_sndpaustim_i, 
            tx_staten_o, rx_staten_o, cpu_if_gbit_en_o, tx_macread_o, 
            mdc_i, mdi_i, rx_er_i, axis_rx_tdata_o, tx_fifoctrl_i, 
            tx_en_o, axis_rx_tlast_o, axis_rx_tkeep_o, apb_pwdata_i, 
            axis_tx_tdata_i, axis_tx_tready_o, apb_pwrite_i, apb_psel_i, 
            apb_penable_i, tx_statvec_o, mdio_en_o, axis_tx_tvalid_i, 
            axis_tx_tlast_i, axis_tx_tkeep_i, txd_o, tx_done_o) /* synthesis ORIG_MODULE_NAME="tse_mac0", LATTICE_IP_GENERATED="1", cpe_box=1 */ ;
    output int_o;
    input ignore_pkt_i;
    input reset_n_i;
    output mdo_o;
    output rx_error_o;
    output apb_pready_o;
    output axis_rx_tvalid_o;
    output rx_fifo_error_o;
    input rx_dv_i;
    input axis_rx_tready_i;
    output tx_discfrm_o;
    input tx_sndpausreq_i;
    output tx_er_o;
    output [31:0]rx_stat_vector_o;
    input [7:0]rxd_i;
    output apb_pslverr_o;
    input clk_i;
    input rxmac_clk_i;
    input txmac_clk_i;
    input [10:0]apb_paddr_i;
    output [31:0]apb_prdata_o;
    output rx_eof_o;
    input [15:0]tx_sndpaustim_i;
    output tx_staten_o;
    output rx_staten_o;
    output cpu_if_gbit_en_o;
    output tx_macread_o;
    input mdc_i;
    input mdi_i;
    input rx_er_i;
    output [7:0]axis_rx_tdata_o;
    input tx_fifoctrl_i;
    output tx_en_o;
    output axis_rx_tlast_o;
    output axis_rx_tkeep_o;
    input [31:0]apb_pwdata_i;
    input [7:0]axis_tx_tdata_i;
    output axis_tx_tready_o;
    input apb_pwrite_i;
    input apb_psel_i;
    input apb_penable_i;
    output [31:0]tx_statvec_o;
    output mdio_en_o;
    input axis_tx_tvalid_i;
    input axis_tx_tlast_i;
    input axis_tx_tkeep_i;
    output [7:0]txd_o;
    output tx_done_o;
    
    
    
endmodule
