/*******************************************************************************
    Verilog netlist generated by IPGEN Lattice Propel (64-bit)
    2024.1.2406150513_p
    Soft IP Version: 2.4.0
    2024 08 24 00:15:47
*******************************************************************************/
/*******************************************************************************
    Wrapper Module generated per user settings.
*******************************************************************************/
module cpu0 (clk_system_i, clk_realtime_i, rstn_i, system_resetn_o, irq7_i,
    irq6_i, irq5_i, irq4_i, irq3_i, irq2_i, dBusAxi_aw_payload_id,
    dBusAxi_aw_payload_addr, dBusAxi_aw_payload_len, dBusAxi_aw_payload_size,
    dBusAxi_aw_payload_burst, dBusAxi_aw_payload_lock,
    dBusAxi_aw_payload_cache, dBusAxi_aw_payload_prot, dBusAxi_aw_payload_qos,
    dBusAxi_aw_payload_region, dBusAxi_aw_valid, dBusAxi_aw_ready,
    dBusAxi_w_payload_data, dBusAxi_w_payload_strb, dBusAxi_w_payload_last,
    dBusAxi_w_valid, dBusAxi_w_ready, dBusAxi_b_payload_id,
    dBusAxi_b_payload_resp, dBusAxi_b_valid, dBusAxi_b_ready,
    dBusAxi_ar_payload_id, dBusAxi_ar_payload_addr, dBusAxi_ar_payload_len,
    dBusAxi_ar_payload_size, dBusAxi_ar_payload_burst, dBusAxi_ar_payload_lock,
    dBusAxi_ar_payload_cache, dBusAxi_ar_payload_prot, dBusAxi_ar_payload_qos,
    dBusAxi_ar_payload_region, dBusAxi_ar_valid, dBusAxi_ar_ready,
    dBusAxi_r_payload_id, dBusAxi_r_payload_data, dBusAxi_r_payload_resp,
    dBusAxi_r_payload_last, dBusAxi_r_valid, dBusAxi_r_ready,
    iBusAxi_aw_payload_id, iBusAxi_aw_payload_addr, iBusAxi_aw_payload_len,
    iBusAxi_aw_payload_size, iBusAxi_aw_payload_burst, iBusAxi_aw_payload_lock,
    iBusAxi_aw_payload_cache, iBusAxi_aw_payload_prot, iBusAxi_aw_payload_qos,
    iBusAxi_aw_payload_region, iBusAxi_aw_valid, iBusAxi_aw_ready,
    iBusAxi_w_payload_data, iBusAxi_w_payload_strb, iBusAxi_w_payload_last,
    iBusAxi_w_valid, iBusAxi_w_ready, iBusAxi_b_payload_id,
    iBusAxi_b_payload_resp, iBusAxi_b_valid, iBusAxi_b_ready,
    iBusAxi_ar_payload_id, iBusAxi_ar_payload_addr, iBusAxi_ar_payload_len,
    iBusAxi_ar_payload_size, iBusAxi_ar_payload_burst, iBusAxi_ar_payload_lock,
    iBusAxi_ar_payload_cache, iBusAxi_ar_payload_prot, iBusAxi_ar_payload_qos,
    iBusAxi_ar_payload_region, iBusAxi_ar_valid, iBusAxi_ar_ready,
    iBusAxi_r_payload_id, iBusAxi_r_payload_data, iBusAxi_r_payload_resp,
    iBusAxi_r_payload_last, iBusAxi_r_valid, iBusAxi_r_ready)/* synthesis syn_black_box syn_declare_black_box=1 */;
    input  clk_system_i;
    input  clk_realtime_i;
    input  rstn_i;
    output  system_resetn_o;
    input  [0:0]  irq7_i;
    input  [0:0]  irq6_i;
    input  [0:0]  irq5_i;
    input  [0:0]  irq4_i;
    input  [0:0]  irq3_i;
    input  [0:0]  irq2_i;
    output  [3:0]  dBusAxi_aw_payload_id;
    output  [31:0]  dBusAxi_aw_payload_addr;
    output  [7:0]  dBusAxi_aw_payload_len;
    output  [2:0]  dBusAxi_aw_payload_size;
    output  [1:0]  dBusAxi_aw_payload_burst;
    output  dBusAxi_aw_payload_lock;
    output  [3:0]  dBusAxi_aw_payload_cache;
    output  [2:0]  dBusAxi_aw_payload_prot;
    output  [3:0]  dBusAxi_aw_payload_qos;
    output  [3:0]  dBusAxi_aw_payload_region;
    output  dBusAxi_aw_valid;
    input  dBusAxi_aw_ready;
    output  [31:0]  dBusAxi_w_payload_data;
    output  [3:0]  dBusAxi_w_payload_strb;
    output  dBusAxi_w_payload_last;
    output  dBusAxi_w_valid;
    input  dBusAxi_w_ready;
    input  [3:0]  dBusAxi_b_payload_id;
    input  [1:0]  dBusAxi_b_payload_resp;
    input  dBusAxi_b_valid;
    output  dBusAxi_b_ready;
    output  [3:0]  dBusAxi_ar_payload_id;
    output  [31:0]  dBusAxi_ar_payload_addr;
    output  [7:0]  dBusAxi_ar_payload_len;
    output  [2:0]  dBusAxi_ar_payload_size;
    output  [1:0]  dBusAxi_ar_payload_burst;
    output  dBusAxi_ar_payload_lock;
    output  [3:0]  dBusAxi_ar_payload_cache;
    output  [2:0]  dBusAxi_ar_payload_prot;
    output  [3:0]  dBusAxi_ar_payload_qos;
    output  [3:0]  dBusAxi_ar_payload_region;
    output  dBusAxi_ar_valid;
    input  dBusAxi_ar_ready;
    input  [3:0]  dBusAxi_r_payload_id;
    input  [31:0]  dBusAxi_r_payload_data;
    input  [1:0]  dBusAxi_r_payload_resp;
    input  dBusAxi_r_payload_last;
    input  dBusAxi_r_valid;
    output  dBusAxi_r_ready;
    output  [3:0]  iBusAxi_aw_payload_id;
    output  [31:0]  iBusAxi_aw_payload_addr;
    output  [7:0]  iBusAxi_aw_payload_len;
    output  [2:0]  iBusAxi_aw_payload_size;
    output  [1:0]  iBusAxi_aw_payload_burst;
    output  iBusAxi_aw_payload_lock;
    output  [3:0]  iBusAxi_aw_payload_cache;
    output  [2:0]  iBusAxi_aw_payload_prot;
    output  [3:0]  iBusAxi_aw_payload_qos;
    output  [3:0]  iBusAxi_aw_payload_region;
    output  iBusAxi_aw_valid;
    input  iBusAxi_aw_ready;
    output  [31:0]  iBusAxi_w_payload_data;
    output  [3:0]  iBusAxi_w_payload_strb;
    output  iBusAxi_w_payload_last;
    output  iBusAxi_w_valid;
    input  iBusAxi_w_ready;
    input  [3:0]  iBusAxi_b_payload_id;
    input  [1:0]  iBusAxi_b_payload_resp;
    input  iBusAxi_b_valid;
    output  iBusAxi_b_ready;
    output  [3:0]  iBusAxi_ar_payload_id;
    output  [31:0]  iBusAxi_ar_payload_addr;
    output  [7:0]  iBusAxi_ar_payload_len;
    output  [2:0]  iBusAxi_ar_payload_size;
    output  [1:0]  iBusAxi_ar_payload_burst;
    output  iBusAxi_ar_payload_lock;
    output  [3:0]  iBusAxi_ar_payload_cache;
    output  [2:0]  iBusAxi_ar_payload_prot;
    output  [3:0]  iBusAxi_ar_payload_qos;
    output  [3:0]  iBusAxi_ar_payload_region;
    output  iBusAxi_ar_valid;
    input  iBusAxi_ar_ready;
    input  [3:0]  iBusAxi_r_payload_id;
    input  [31:0]  iBusAxi_r_payload_data;
    input  [1:0]  iBusAxi_r_payload_resp;
    input  iBusAxi_r_payload_last;
    input  iBusAxi_r_valid;
    output  iBusAxi_r_ready;
endmodule