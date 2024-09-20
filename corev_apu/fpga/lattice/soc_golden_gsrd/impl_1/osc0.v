// Verilog netlist produced by program LSE 
// Netlist written on Wed Sep 18 11:46:09 2024
// Source file index table: 
// Object locations will have the form @<file_index>(<first_ line>[<left_column>],<last_line>[<right_column>])
// file 0 "c:/code/cva6-joshloo/cva6/corev_apu/fpga/lattice/soc_golden_gsrd/bht_ini.bin"
// file 1 "c:/code/cva6-joshloo/cva6/corev_apu/fpga/lattice/soc_golden_gsrd/reginit.bin"
// file 2 "c:/lscc/radiant/2024.1/ip/common/adder/rtl/lscc_adder.v"
// file 3 "c:/lscc/radiant/2024.1/ip/common/adder_subtractor/rtl/lscc_add_sub.v"
// file 4 "c:/lscc/radiant/2024.1/ip/common/complex_mult/rtl/lscc_complex_mult.v"
// file 5 "c:/lscc/radiant/2024.1/ip/common/counter/rtl/lscc_cntr.v"
// file 6 "c:/lscc/radiant/2024.1/ip/common/distributed_dpram/rtl/lscc_distributed_dpram.v"
// file 7 "c:/lscc/radiant/2024.1/ip/common/distributed_rom/rtl/lscc_distributed_rom.v"
// file 8 "c:/lscc/radiant/2024.1/ip/common/distributed_spram/rtl/lscc_distributed_spram.v"
// file 9 "c:/lscc/radiant/2024.1/ip/common/fifo/rtl/lscc_fifo.v"
// file 10 "c:/lscc/radiant/2024.1/ip/common/fifo_dc/rtl/lscc_fifo_dc.v"
// file 11 "c:/lscc/radiant/2024.1/ip/common/mult_accumulate/rtl/lscc_mult_accumulate.v"
// file 12 "c:/lscc/radiant/2024.1/ip/common/mult_add_sub/rtl/lscc_mult_add_sub.v"
// file 13 "c:/lscc/radiant/2024.1/ip/common/mult_add_sub_sum/rtl/lscc_mult_add_sub_sum.v"
// file 14 "c:/lscc/radiant/2024.1/ip/common/multiplier/rtl/lscc_multiplier.v"
// file 15 "c:/lscc/radiant/2024.1/ip/common/ram_dp/rtl/lscc_ram_dp.v"
// file 16 "c:/lscc/radiant/2024.1/ip/common/ram_dp_true/rtl/lscc_ram_dp_true.v"
// file 17 "c:/lscc/radiant/2024.1/ip/common/ram_dq/rtl/lscc_ram_dq.v"
// file 18 "c:/lscc/radiant/2024.1/ip/common/ram_shift_reg/rtl/lscc_shift_register.v"
// file 19 "c:/lscc/radiant/2024.1/ip/common/rom/rtl/lscc_rom.v"
// file 20 "c:/lscc/radiant/2024.1/ip/common/subtractor/rtl/lscc_subtractor.v"
// file 21 "c:/lscc/radiant/2024.1/ip/pmi/pmi_add.v"
// file 22 "c:/lscc/radiant/2024.1/ip/pmi/pmi_addsub.v"
// file 23 "c:/lscc/radiant/2024.1/ip/pmi/pmi_complex_mult.v"
// file 24 "c:/lscc/radiant/2024.1/ip/pmi/pmi_counter.v"
// file 25 "c:/lscc/radiant/2024.1/ip/pmi/pmi_distributed_dpram.v"
// file 26 "c:/lscc/radiant/2024.1/ip/pmi/pmi_distributed_rom.v"
// file 27 "c:/lscc/radiant/2024.1/ip/pmi/pmi_distributed_shift_reg.v"
// file 28 "c:/lscc/radiant/2024.1/ip/pmi/pmi_distributed_spram.v"
// file 29 "c:/lscc/radiant/2024.1/ip/pmi/pmi_fifo.v"
// file 30 "c:/lscc/radiant/2024.1/ip/pmi/pmi_fifo_dc.v"
// file 31 "c:/lscc/radiant/2024.1/ip/pmi/pmi_mac.v"
// file 32 "c:/lscc/radiant/2024.1/ip/pmi/pmi_mult.v"
// file 33 "c:/lscc/radiant/2024.1/ip/pmi/pmi_multaddsub.v"
// file 34 "c:/lscc/radiant/2024.1/ip/pmi/pmi_multaddsubsum.v"
// file 35 "c:/lscc/radiant/2024.1/ip/pmi/pmi_ram_dp.v"
// file 36 "c:/lscc/radiant/2024.1/ip/pmi/pmi_ram_dp_be.v"
// file 37 "c:/lscc/radiant/2024.1/ip/pmi/pmi_ram_dp_true.v"
// file 38 "c:/lscc/radiant/2024.1/ip/pmi/pmi_ram_dq.v"
// file 39 "c:/lscc/radiant/2024.1/ip/pmi/pmi_ram_dq_be.v"
// file 40 "c:/lscc/radiant/2024.1/ip/pmi/pmi_rom.v"
// file 41 "c:/lscc/radiant/2024.1/ip/pmi/pmi_sub.v"
// file 42 "c:/lscc/radiant/2024.1/cae_library/simulation/verilog/applatform/dpr16x4a.v"
// file 43 "c:/lscc/radiant/2024.1/cae_library/simulation/verilog/applatform/dpr32x2.v"
// file 44 "c:/lscc/radiant/2024.1/cae_library/simulation/verilog/applatform/spr16x4a.v"
// file 45 "c:/lscc/radiant/2024.1/cae_library/simulation/verilog/applatform/spr32x2.v"
// file 46 "c:/lscc/radiant/2024.1/cae_library/simulation/verilog/applatform/widefn9.v"
// file 47 "c:/lscc/radiant/2024.1/cae_library/simulation/verilog/applatform/io_specialprim.v"

//
// Verilog Description of module osc0
// module wrapper written out since it is a black-box. 
//

//

module osc0 (en_i, clk_sel_i, clk_out_o) /* synthesis ORIG_MODULE_NAME="osc0", LATTICE_IP_GENERATED="1", cpe_box=1 */ ;
    input en_i;
    input clk_sel_i;
    output clk_out_o;
    
    
    
endmodule
