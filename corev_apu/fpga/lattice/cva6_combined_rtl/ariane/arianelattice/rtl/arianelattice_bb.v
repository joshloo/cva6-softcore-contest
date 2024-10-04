/*******************************************************************************
    Verilog netlist generated by IPGEN Lattice Radiant Software (64-bit)
    2024.1.1.259.1
    Soft IP Version: 1.0
    2024 10 04 15:38:27
*******************************************************************************/
/*******************************************************************************
    Wrapper Module generated per user settings.
*******************************************************************************/
module arianelattice (clk_i, rst_ni, boot_addr_i, hart_id_i, irq_i, ipi_i,
    time_irq_i, debug_req_i, noc_req_o_aw_valid, noc_req_o_w_valid,
    noc_req_o_b_ready, noc_req_o_ar_valid, noc_req_o_r_ready,
    noc_resp_i_aw_ready, noc_resp_i_ar_ready, noc_resp_i_w_ready,
    noc_resp_i_b_valid, noc_resp_i_r_valid, noc_resp_i_b_id, noc_resp_i_b_resp,
    noc_resp_i_b_user, noc_resp_i_r_id, noc_resp_i_r_data, noc_resp_i_r_resp,
    noc_resp_i_r_last, noc_resp_i_r_user, noc_req_o_aw_id, noc_req_o_aw_addr,
    noc_req_o_aw_len, noc_req_o_aw_size, noc_req_o_aw_burst, noc_req_o_aw_lock,
    noc_req_o_aw_cache, noc_req_o_aw_prot, noc_req_o_aw_qos,
    noc_req_o_aw_region, noc_req_o_aw_atop, noc_req_o_aw_user,
    noc_req_o_w_data, noc_req_o_w_strb, noc_req_o_w_last, noc_req_o_w_user,
    noc_req_o_ar_id, noc_req_o_ar_addr, noc_req_o_ar_len, noc_req_o_ar_size,
    noc_req_o_ar_burst, noc_req_o_ar_lock, noc_req_o_ar_cache,
    noc_req_o_ar_prot, noc_req_o_ar_qos, noc_req_o_ar_region,
    noc_req_o_ar_user, rvfi_o_valid, rvfi_o_order, rvfi_o_insn, rvfi_o_trap,
    rvfi_o_cause, rvfi_o_halt, rvfi_o_intr, rvfi_o_mode, rvfi_o_ixl,
    rvfi_o_rs1_addr, rvfi_o_rs2_addr, rvfi_o_rs1_rdata, rvfi_o_rs2_rdata,
    rvfi_o_rd_addr, rvfi_o_rd_wdata, rvfi_o_pc_rdata, rvfi_o_pc_wdata,
    rvfi_o_mem_addr, rvfi_o_mem_paddr, rvfi_o_mem_rmask, rvfi_o_mem_wmask,
    rvfi_o_mem_rdata, rvfi_o_mem_wdata)/* synthesis syn_black_box syn_declare_black_box=1 */;
    input  clk_i;
    input  rst_ni;
    input  [31:0]  boot_addr_i;
    input  [33:0]  hart_id_i;
    input  [1:0]  irq_i;
    input  ipi_i;
    input  time_irq_i;
    input  debug_req_i;
    output  noc_req_o_aw_valid;
    output  noc_req_o_w_valid;
    output  noc_req_o_b_ready;
    output  noc_req_o_ar_valid;
    output  noc_req_o_r_ready;
    input  noc_resp_i_aw_ready;
    input  noc_resp_i_ar_ready;
    input  noc_resp_i_w_ready;
    input  noc_resp_i_b_valid;
    input  noc_resp_i_r_valid;
    input  [3:0]  noc_resp_i_b_id;
    input  [1:0]  noc_resp_i_b_resp;
    input  [31:0]  noc_resp_i_b_user;
    input  [3:0]  noc_resp_i_r_id;
    input  [63:0]  noc_resp_i_r_data;
    input  [1:0]  noc_resp_i_r_resp;
    input  noc_resp_i_r_last;
    input  [31:0]  noc_resp_i_r_user;
    output  [3:0]  noc_req_o_aw_id;
    output  [63:0]  noc_req_o_aw_addr;
    output  [7:0]  noc_req_o_aw_len;
    output  [2:0]  noc_req_o_aw_size;
    output  [1:0]  noc_req_o_aw_burst;
    output  noc_req_o_aw_lock;
    output  [3:0]  noc_req_o_aw_cache;
    output  [2:0]  noc_req_o_aw_prot;
    output  [3:0]  noc_req_o_aw_qos;
    output  [3:0]  noc_req_o_aw_region;
    output  [5:0]  noc_req_o_aw_atop;
    output  [31:0]  noc_req_o_aw_user;
    output  [63:0]  noc_req_o_w_data;
    output  [7:0]  noc_req_o_w_strb;
    output  noc_req_o_w_last;
    output  [31:0]  noc_req_o_w_user;
    output  [3:0]  noc_req_o_ar_id;
    output  [63:0]  noc_req_o_ar_addr;
    output  [7:0]  noc_req_o_ar_len;
    output  [2:0]  noc_req_o_ar_size;
    output  [1:0]  noc_req_o_ar_burst;
    output  noc_req_o_ar_lock;
    output  [3:0]  noc_req_o_ar_cache;
    output  [2:0]  noc_req_o_ar_prot;
    output  [3:0]  noc_req_o_ar_qos;
    output  [3:0]  noc_req_o_ar_region;
    output  [31:0]  noc_req_o_ar_user;
    output  rvfi_o_valid;
    output  [63:0]  rvfi_o_order;
    output  [31:0]  rvfi_o_insn;
    output  rvfi_o_trap;
    output  [31:0]  rvfi_o_cause;
    output  rvfi_o_halt;
    output  rvfi_o_intr;
    output  [1:0]  rvfi_o_mode;
    output  [1:0]  rvfi_o_ixl;
    output  [4:0]  rvfi_o_rs1_addr;
    output  [4:0]  rvfi_o_rs2_addr;
    output  [31:0]  rvfi_o_rs1_rdata;
    output  [31:0]  rvfi_o_rs2_rdata;
    output  [4:0]  rvfi_o_rd_addr;
    output  [31:0]  rvfi_o_rd_wdata;
    output  [31:0]  rvfi_o_pc_rdata;
    output  [31:0]  rvfi_o_pc_wdata;
    output  [31:0]  rvfi_o_mem_addr;
    output  [33:0]  rvfi_o_mem_paddr;
    output  [3:0]  rvfi_o_mem_rmask;
    output  [2:0]  rvfi_o_mem_wmask;
    output  [31:0]  rvfi_o_mem_rdata;
    output  [31:0]  rvfi_o_mem_wdata;
endmodule