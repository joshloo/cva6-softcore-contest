// Verilog netlist produced by program LSE 
// Netlist written on Wed Sep 18 11:46:08 2024
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
// Verilog Description of module cpu0
// module wrapper written out since it is a black-box. 
//

//

module cpu0 (clk_system_i, clk_realtime_i, rstn_i, system_resetn_o, 
            irq7_i, irq6_i, irq5_i, irq4_i, irq3_i, irq2_i, dBusAxi_aw_payload_id, 
            dBusAxi_aw_payload_addr, dBusAxi_aw_payload_len, dBusAxi_aw_payload_size, 
            dBusAxi_aw_payload_burst, dBusAxi_aw_payload_lock, dBusAxi_aw_payload_cache, 
            dBusAxi_aw_payload_prot, dBusAxi_aw_payload_qos, dBusAxi_aw_payload_region, 
            dBusAxi_aw_valid, dBusAxi_aw_ready, dBusAxi_w_payload_data, 
            dBusAxi_w_payload_strb, dBusAxi_w_payload_last, dBusAxi_w_valid, 
            dBusAxi_w_ready, dBusAxi_b_payload_id, dBusAxi_b_payload_resp, 
            dBusAxi_b_valid, dBusAxi_b_ready, dBusAxi_ar_payload_id, dBusAxi_ar_payload_addr, 
            dBusAxi_ar_payload_len, dBusAxi_ar_payload_size, dBusAxi_ar_payload_burst, 
            dBusAxi_ar_payload_lock, dBusAxi_ar_payload_cache, dBusAxi_ar_payload_prot, 
            dBusAxi_ar_payload_qos, dBusAxi_ar_payload_region, dBusAxi_ar_valid, 
            dBusAxi_ar_ready, dBusAxi_r_payload_id, dBusAxi_r_payload_data, 
            dBusAxi_r_payload_resp, dBusAxi_r_payload_last, dBusAxi_r_valid, 
            dBusAxi_r_ready, iBusAxi_aw_payload_id, iBusAxi_aw_payload_addr, 
            iBusAxi_aw_payload_len, iBusAxi_aw_payload_size, iBusAxi_aw_payload_burst, 
            iBusAxi_aw_payload_lock, iBusAxi_aw_payload_cache, iBusAxi_aw_payload_prot, 
            iBusAxi_aw_payload_qos, iBusAxi_aw_payload_region, iBusAxi_aw_valid, 
            iBusAxi_aw_ready, iBusAxi_w_payload_data, iBusAxi_w_payload_strb, 
            iBusAxi_w_payload_last, iBusAxi_w_valid, iBusAxi_w_ready, 
            iBusAxi_b_payload_id, iBusAxi_b_payload_resp, iBusAxi_b_valid, 
            iBusAxi_b_ready, iBusAxi_ar_payload_id, iBusAxi_ar_payload_addr, 
            iBusAxi_ar_payload_len, iBusAxi_ar_payload_size, iBusAxi_ar_payload_burst, 
            iBusAxi_ar_payload_lock, iBusAxi_ar_payload_cache, iBusAxi_ar_payload_prot, 
            iBusAxi_ar_payload_qos, iBusAxi_ar_payload_region, iBusAxi_ar_valid, 
            iBusAxi_ar_ready, iBusAxi_r_payload_id, iBusAxi_r_payload_data, 
            iBusAxi_r_payload_resp, iBusAxi_r_payload_last, iBusAxi_r_valid, 
            iBusAxi_r_ready) /* synthesis ORIG_MODULE_NAME="cpu0", LATTICE_IP_GENERATED="1", cpe_box=1 */ ;
    input clk_system_i;
    input clk_realtime_i;
    input rstn_i;
    output system_resetn_o;
    input [0:0]irq7_i;
    input [0:0]irq6_i;
    input [0:0]irq5_i;
    input [0:0]irq4_i;
    input [0:0]irq3_i;
    input [0:0]irq2_i;
    output [3:0]dBusAxi_aw_payload_id;
    output [31:0]dBusAxi_aw_payload_addr;
    output [7:0]dBusAxi_aw_payload_len;
    output [2:0]dBusAxi_aw_payload_size;
    output [1:0]dBusAxi_aw_payload_burst;
    output dBusAxi_aw_payload_lock;
    output [3:0]dBusAxi_aw_payload_cache;
    output [2:0]dBusAxi_aw_payload_prot;
    output [3:0]dBusAxi_aw_payload_qos;
    output [3:0]dBusAxi_aw_payload_region;
    output dBusAxi_aw_valid;
    input dBusAxi_aw_ready;
    output [31:0]dBusAxi_w_payload_data;
    output [3:0]dBusAxi_w_payload_strb;
    output dBusAxi_w_payload_last;
    output dBusAxi_w_valid;
    input dBusAxi_w_ready;
    input [3:0]dBusAxi_b_payload_id;
    input [1:0]dBusAxi_b_payload_resp;
    input dBusAxi_b_valid;
    output dBusAxi_b_ready;
    output [3:0]dBusAxi_ar_payload_id;
    output [31:0]dBusAxi_ar_payload_addr;
    output [7:0]dBusAxi_ar_payload_len;
    output [2:0]dBusAxi_ar_payload_size;
    output [1:0]dBusAxi_ar_payload_burst;
    output dBusAxi_ar_payload_lock;
    output [3:0]dBusAxi_ar_payload_cache;
    output [2:0]dBusAxi_ar_payload_prot;
    output [3:0]dBusAxi_ar_payload_qos;
    output [3:0]dBusAxi_ar_payload_region;
    output dBusAxi_ar_valid;
    input dBusAxi_ar_ready;
    input [3:0]dBusAxi_r_payload_id;
    input [31:0]dBusAxi_r_payload_data;
    input [1:0]dBusAxi_r_payload_resp;
    input dBusAxi_r_payload_last;
    input dBusAxi_r_valid;
    output dBusAxi_r_ready;
    output [3:0]iBusAxi_aw_payload_id;
    output [31:0]iBusAxi_aw_payload_addr;
    output [7:0]iBusAxi_aw_payload_len;
    output [2:0]iBusAxi_aw_payload_size;
    output [1:0]iBusAxi_aw_payload_burst;
    output iBusAxi_aw_payload_lock;
    output [3:0]iBusAxi_aw_payload_cache;
    output [2:0]iBusAxi_aw_payload_prot;
    output [3:0]iBusAxi_aw_payload_qos;
    output [3:0]iBusAxi_aw_payload_region;
    output iBusAxi_aw_valid;
    input iBusAxi_aw_ready;
    output [31:0]iBusAxi_w_payload_data;
    output [3:0]iBusAxi_w_payload_strb;
    output iBusAxi_w_payload_last;
    output iBusAxi_w_valid;
    input iBusAxi_w_ready;
    input [3:0]iBusAxi_b_payload_id;
    input [1:0]iBusAxi_b_payload_resp;
    input iBusAxi_b_valid;
    output iBusAxi_b_ready;
    output [3:0]iBusAxi_ar_payload_id;
    output [31:0]iBusAxi_ar_payload_addr;
    output [7:0]iBusAxi_ar_payload_len;
    output [2:0]iBusAxi_ar_payload_size;
    output [1:0]iBusAxi_ar_payload_burst;
    output iBusAxi_ar_payload_lock;
    output [3:0]iBusAxi_ar_payload_cache;
    output [2:0]iBusAxi_ar_payload_prot;
    output [3:0]iBusAxi_ar_payload_qos;
    output [3:0]iBusAxi_ar_payload_region;
    output iBusAxi_ar_valid;
    input iBusAxi_ar_ready;
    input [3:0]iBusAxi_r_payload_id;
    input [31:0]iBusAxi_r_payload_data;
    input [1:0]iBusAxi_r_payload_resp;
    input iBusAxi_r_payload_last;
    input iBusAxi_r_valid;
    output iBusAxi_r_ready;
    
    
    
endmodule
