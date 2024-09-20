// =============================================================================
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
// -----------------------------------------------------------------------------
//   Copyright (c) 2022 by Lattice Semiconductor Corporation
//   ALL RIGHTS RESERVED
// -----------------------------------------------------------------------------
//
//   Permission:
//
//      Lattice SG Pte. Ltd. grants permission to use this code
//      pursuant to the terms of the Lattice Reference Design License Agreement.
//
//
//   Disclaimer:
//
//      This VHDL or Verilog source code is intended as a design reference
//      which illustrates how these types of functions can be implemented.
//      It is the user's responsibility to verify their design for
//      consistency and functionality through the use of formal
//      verification methods.  Lattice provides no warranty
//      regarding the use or functionality of this code.
//
// -----------------------------------------------------------------------------
//
//                  Lattice SG Pte. Ltd.
//                  101 Thomson Road, United Square #07-02
//                  Singapore 307591
//
//
//                  TEL: 1-800-Lattice (USA and Canada)
//                       +65-6631-2000 (Singapore)
//                       +1-503-268-8001 (other locations)
//
//                  web: http://www.latticesemi.com/
//                  email: techsupport@latticesemi.com
//
// -----------------------------------------------------------------------------
//
// =============================================================================
//                         FILE DETAILS
// Project               :
// File                  : lpddr4_mc_reorder_buffer.sv
// Title                 :
// Dependencies          :
// Description           :
// =============================================================================
`timescale 1ns/1ns

module lpddr4_mc_reorder_buffer   #(
  parameter AXI_DATA_WIDTH          = 0, 
  parameter AXI_ID_WIDTH            = 0, 
  parameter AXI_LEN_WIDTH           = 0, 
  parameter INT_ID_WIDTH            = 0, 
  parameter BI_RD_DATA_Q_WIDTH      = 0,
  parameter SCH_NUM_WR_SUPPORT      = 0,
  parameter SCH_NUM_RD_SUPPORT      = 0,
  parameter MAX_OUTSTANDING_RD      = 8, 
  parameter MAX_BURST_LEN           = 64,
  parameter DATA_CLK_EN             = 0, 
  parameter DDR_WIDTH               = 0, 
  parameter AXI_DATA_WIDTH_DIV2     = AXI_DATA_WIDTH/2,
  parameter RSP_ADDR_WIDTH          = AXI_LEN_WIDTH  
)
(
  input  sclk,
  input  rst_n,
  input  hclk,
  input  hrst_n,
  input  axi_rready_i,
  output logic [AXI_ID_WIDTH -1 : 0] axi_rid_o,
  output logic axi_rlast_o,
  output logic axi_rvalid_o /* sythesis syn_preserve=1 */,
  output logic [AXI_DATA_WIDTH -1 :0] axi_rdata_o,
 
  input                                        rd_rsp_valid,
  output                                       rd_rsp_ready,
  input [BI_RD_DATA_Q_WIDTH - 1:0]             rd_rsp_data,
  input [AXI_ID_WIDTH + INT_ID_WIDTH-1:0]      rd_rsp_idx,
  input [AXI_LEN_WIDTH -1 :0]                  rd_rsp_length,
  input [3 -1 :0]                              rd_rsp_size,
  input [RSP_ADDR_WIDTH-1:0]                   rd_rsp_addr,

  output logic                                 ebr_empty
);
localparam SIZE_WIDTH       = 3;
localparam RE_BUFF_DEPTH    = MAX_OUTSTANDING_RD * MAX_BURST_LEN;
localparam BURST_ADDR_WIDTH = $clog2(MAX_BURST_LEN);
localparam RE_ADDR_WIDTH    = $clog2(RE_BUFF_DEPTH);
localparam BYTE_CNT_WIDTH   = 16;  // FIXME: This seems to be too big. Need to discuss with Bharathi.
localparam TOTAL_CTRL_WIDTH = AXI_LEN_WIDTH+AXI_ID_WIDTH+INT_ID_WIDTH+SIZE_WIDTH;
localparam TOTAL_ID_WIDTH   = AXI_ID_WIDTH+INT_ID_WIDTH;
localparam CTRL_DPRAM_WIDTH = TOTAL_CTRL_WIDTH+8;  // FIXME: Why address is only 8 bits? MAX_OUTSTANDING_RD *64=512=> 9bits
localparam SIZE_CNT_WIDTH   = 8;


logic [MAX_OUTSTANDING_RD-1:0] ebr_wr;
logic [MAX_OUTSTANDING_RD-1:0] ebr_wr_d;
logic [MAX_OUTSTANDING_RD-1:0] sig_ebr_wr;
logic                          ebr_wr_rep_r; // replicated for EBR instance
logic                          ebr_rd/* synthesis syn_keep=1 */;
logic [RE_ADDR_WIDTH-1:0]      ebr_wraddr;
logic [RE_ADDR_WIDTH-1:0]      ebr_rdaddr;
logic [RE_ADDR_WIDTH-1:0]      sig_ebr_rdaddr;
//logic [RE_ADDR_WIDTH-1:0]      ebr_rdaddr_d;
logic [BI_RD_DATA_Q_WIDTH-1:0] ebr_wrdata;
logic [BI_RD_DATA_Q_WIDTH-1:0] ebr_rddata;
logic [BI_RD_DATA_Q_WIDTH-1:0] ebr_rddata_d;
logic [BI_RD_DATA_Q_WIDTH-1:0] sig_ebr_rddata;

logic [BURST_ADDR_WIDTH-1:0]   bus_wraddr;
//logic [BURST_ADDR_WIDTH-1:0]   bus_wraddr_d;

logic [SIZE_CNT_WIDTH-1:0]     count;
logic [SIZE_CNT_WIDTH-1:0]     count_nxt;
logic [SIZE_CNT_WIDTH-1:0]     len_val_r;  
logic [SIZE_CNT_WIDTH-1:0]     len_val_nxt;
logic [TOTAL_ID_WIDTH-1:0]     idx_value;
logic                          end_count_r;

logic                          dpram_wr;
logic                          dpram_wr_d;
logic [MAX_OUTSTANDING_RD-1:0] sig_dpram_wr;
logic [MAX_OUTSTANDING_RD-1:0] sig_dpram_wr_d;
logic                          dpram_rd;
logic [INT_ID_WIDTH-1:0]       dpram_wraddr;
logic [INT_ID_WIDTH-1:0]       dpram_wraddr_d;
logic [INT_ID_WIDTH-1:0]       dpram_rdaddr;
logic [CTRL_DPRAM_WIDTH-1:0]   dpram_wrdata;
logic [CTRL_DPRAM_WIDTH-1:0]   sig_dpram_rddata;
logic [CTRL_DPRAM_WIDTH-1:0]   dpram_rddata_d;
logic [CTRL_DPRAM_WIDTH-1:0]   dpram_rddata;

logic                             enable_bus;
logic  [MAX_OUTSTANDING_RD-1 : 0] sig_enable_bus;
logic  [MAX_OUTSTANDING_RD-1 : 0] sync_enable_bus;


logic [MAX_OUTSTANDING_RD-1 : 0] ebr_not_empty_r    /* synthesis syn_preserve=1 */;
logic [MAX_OUTSTANDING_RD-1 : 0] ebr_not_empty_rep_r/* synthesis syn_preserve=1 */;
logic [MAX_OUTSTANDING_RD-1 : 0] ebr_not_empty_nxt;
logic [MAX_OUTSTANDING_RD-1 : 0] sync_ebr_not_empty;
logic bus_idle;
logic [AXI_LEN_WIDTH-1:0]        beat_value;
logic [2:0]                      size_value;
logic [RSP_ADDR_WIDTH-1:0]       addr_value;
logic [MAX_OUTSTANDING_RD-1 :0][15:0] ebr_wr_count;
logic [SIZE_CNT_WIDTH-1:0]        bytes;
logic [BYTE_CNT_WIDTH-1:0]        rd_bytes;
logic [BYTE_CNT_WIDTH-1:0]        total_bytes;
logic [RSP_ADDR_WIDTH-1:0]        start_addr;
logic [MAX_OUTSTANDING_RD-1 :0]   ebr_done;
//logic [AXI_DATA_WIDTH_DIV2 -1 :0] axi_rdata_high_o;
//logic [AXI_DATA_WIDTH_DIV2 -1 :0] axi_rdata_low_o;

logic axi_rvalid_r /* synthesis syn_preserve=1 */;
logic axi_rvalid_nxt;
logic rdata_out_en      /* synthesis syn_keep=1 */;
logic rdata_out_en_rep1 /* synthesis syn_keep=1 */;
logic rdata_out_en_rep2 /* synthesis syn_keep=1 */;
logic axi_rlast_nxt;


typedef enum logic [1:0]  {IDLE,BUS_CHECK,BUS_READ} bus_state;
typedef enum logic [2:0]  {EBR0,EBR1,EBR2,EBR3,EBR4,EBR5,EBR6,EBR7} rr_state;
rr_state  rr_pstate, rr_nstate;
bus_state bus_pstate, bus_nstate;

always_ff @(posedge sclk or negedge rst_n)
  if(~rst_n)
   ebr_empty <= 1'b1;
  else
   ebr_empty <= ~|ebr_not_empty_rep_r; 

assign rd_rsp_ready = 1'b1;

generate
for(genvar i = 0; i< MAX_OUTSTANDING_RD ;i++) begin : EBR_CTRL
  assign sig_ebr_wr[i]        =  (rd_rsp_valid == 1'b1  & rd_rsp_idx[INT_ID_WIDTH-1:0] == i) ;
  assign ebr_not_empty_nxt[i] = sig_dpram_wr[i] ? 1'b1 : (sync_enable_bus[i] ? 1'b0 : ebr_not_empty_rep_r[i]);
  
  always_ff @(posedge sclk or negedge rst_n) begin
    if(~rst_n) begin
      ebr_not_empty_r[i]     <= 1'b0;
	  ebr_not_empty_rep_r[i] <= 1'b0;
    end
	else begin
      ebr_not_empty_r[i]     <= ebr_not_empty_nxt[i];
      ebr_not_empty_rep_r[i] <= ebr_not_empty_nxt[i];
	end
  end // always_ff
  
  always_ff @(posedge sclk or negedge rst_n) begin
    if(!rst_n)
      ebr_wr_count[i] <= 0;
    else if(sig_dpram_wr_d[i])
      ebr_wr_count[i] <= 0;
    else if(ebr_wr[i])
      ebr_wr_count[i] <= ebr_wr_count[i] + bytes;
  end // always_ff

  always_ff @(posedge sclk or negedge rst_n) begin
    if(!rst_n)
      ebr_done[i] <= 0;
    else 
      ebr_done[i] <=  (ebr_wr[i] & ebr_wr_d[i]  & ((ebr_wr_count[i] + bytes) >= total_bytes));
  end // always_ff

 assign sig_dpram_wr[i]   =   ebr_done[i] & !ebr_not_empty_rep_r[i];
 assign sig_enable_bus[i] = rr_pstate == i & sync_ebr_not_empty[i] & bus_idle;
 
 if(DATA_CLK_EN == 1) 
  begin : ASYNC
  lpddr4_mc_double_sync 
    u_not_empty_sync(
      .clk_out  (hclk                 ),
      .rst_n_out(hrst_n               ),
      .data_in  (ebr_not_empty_r[i]     ), 
      .data_out (sync_ebr_not_empty[i]) 
    );
  
  
  
  lpddr4_mc_toggle_sync 
    u_enable_bus_sync (
      .clk_in   (hclk             ),
      .rst_n_in (hrst_n           ),
      .pulse_in (sig_enable_bus[i]), 
      .clk_out  (sclk             ),
      .rst_n_out(rst_n            ),
      .pulse_out(sync_enable_bus[i]) 
    );
  end
 else
  begin : SYNC
  assign sync_enable_bus[i] = sig_enable_bus[i];
  assign sync_ebr_not_empty[i] = ebr_not_empty_rep_r[i];
  end
end // EBR_CTRL
endgenerate

always @(posedge sclk or negedge rst_n)
begin
  if(!rst_n)
    ebr_wrdata  <= 0;
  else
    ebr_wrdata  <=   {rd_rsp_valid,rd_rsp_data};
end

assign ebr_wraddr  =   {idx_value[INT_ID_WIDTH -1:0],bus_wraddr};

always @(posedge sclk or negedge rst_n)
begin
  if(!rst_n) begin
    dpram_wraddr    <= 0;
    sig_dpram_wr_d  <= 0;
  end else begin
    dpram_wraddr    <= idx_value[INT_ID_WIDTH-1:0];
    sig_dpram_wr_d  <= sig_dpram_wr;
  end end

always @(posedge sclk or negedge rst_n)
begin
  if(!rst_n)
    dpram_wrdata  <= 0;
  else
    dpram_wrdata  <= {addr_value,size_value,idx_value,beat_value};
end

always @(posedge sclk or negedge rst_n)
begin
  if(!rst_n) begin
     ebr_wr       <= {MAX_OUTSTANDING_RD{1'b0}};
     ebr_wr_d     <= {MAX_OUTSTANDING_RD{1'b0}};
     ebr_wr_rep_r <= 1'b0;
  end else begin 
     ebr_wr       <= sig_ebr_wr;
     ebr_wr_d     <= ebr_wr;
     ebr_wr_rep_r <= |sig_ebr_wr;
  end
end

logic ebr_done_d;

always @(posedge sclk or negedge rst_n)
begin
  if(!rst_n) begin
     size_value <= 3'h0;
     beat_value <= {AXI_LEN_WIDTH{1'b0}};
     addr_value <= {RSP_ADDR_WIDTH{1'b0}};
     idx_value  <= {TOTAL_ID_WIDTH{1'b0}};
     rd_bytes   <= {BYTE_CNT_WIDTH{1'b1}};
  end else if(rd_rsp_valid) begin
     size_value <= {rd_rsp_size};
     beat_value <= {rd_rsp_length};
     addr_value <= {rd_rsp_addr};
     idx_value  <= {rd_rsp_idx};
     rd_bytes   <= rd_rsp_length << rd_rsp_size;
  end
end

always @(posedge sclk or negedge rst_n)
begin
  if(!rst_n) begin
     ebr_done_d <= 1'b0;
  end else begin
     ebr_done_d <= |ebr_done;
  end
end

assign bytes = DDR_WIDTH ; 
assign start_addr = (DDR_WIDTH == 16) ? addr_value[4:0] : (DDR_WIDTH == 32) ? addr_value[5:0] :  addr_value[6:0]; 

always @(posedge sclk or negedge rst_n)
begin
  if(!rst_n)
     bus_wraddr <= {BURST_ADDR_WIDTH{1'b0}};
  else if(((idx_value[INT_ID_WIDTH-1:0] != rd_rsp_idx[INT_ID_WIDTH-1:0])) | (ebr_done_d)) 
    bus_wraddr  <= {BURST_ADDR_WIDTH{1'b0}};
  else if(|ebr_wr)
    bus_wraddr  <= bus_wraddr + {{(BURST_ADDR_WIDTH-1){1'b0}},1'b1};
end

always @(posedge sclk or negedge rst_n)
begin
  if(!rst_n)
    total_bytes <= 0;
  else 
    total_bytes <= rd_bytes + start_addr;
end

assign dpram_wr = |sig_dpram_wr & !dpram_wr_d;

always @(posedge sclk or negedge rst_n)
begin
  if(!rst_n)
   dpram_wr_d <= 0;
  else
   dpram_wr_d <= dpram_wr;
end

lpddr4_mc_dpram  #( 
  .WIDTH (CTRL_DPRAM_WIDTH  ),
  .DEPTH (MAX_OUTSTANDING_RD)
)  // 3 is for size and 8 is for address
u_ctrl_dpram  (
        .wr_clk_i    (sclk), 
        .rd_clk_i    (hclk), 
        .wr_clk_en_i (1'b1), 
        .rd_en_i     (dpram_rd), 
        .rd_clk_en_i (1'b1), 
        .wr_en_i     (dpram_wr), 
        .wr_data_i   (dpram_wrdata) , 
        .wr_addr_i   (dpram_wraddr), 
        .rd_addr_i   (dpram_rdaddr), 
        .rd_data_o   (dpram_rddata) 
) ;


lpddr4_mc_sch_ebr  #(
  .WIDTH(BI_RD_DATA_Q_WIDTH), 
  .DEPTH(RE_BUFF_DEPTH     )
)
u_lpddr4_mc_rd_rtrn_ebr_inst(
  .wr_clk_i(sclk), 
  .rd_clk_i(hclk), 
  //.rst_i(!hrst_n), 
  .rst_i(!rst_n), 
  .wr_clk_en_i(1'b1), 
  .rd_clk_en_i(1'b1), 
  //.wr_en_i(|ebr_wr), 
  .wr_en_i(ebr_wr_rep_r),
  .rd_en_i(ebr_rd), 
  //.rd_en_i(1'b1),  // Let the EBR output be pass through, note that the final rddata is registered
  .wr_data_i(ebr_wrdata), 
  .wr_addr_i(ebr_wraddr), 
  .rd_addr_i(ebr_rdaddr),          // Modified by Alfred for Synthesis
  .ben_i({(BI_RD_DATA_Q_WIDTH/8){1'b1}}),
  .rd_data_o(ebr_rddata)
);


assign dpram_rd = enable_bus;
assign dpram_rdaddr = rr_pstate;
assign enable_bus = |sig_enable_bus;

always_comb
begin
   rr_nstate  = rr_pstate;
case(rr_pstate)
       EBR0 : begin
                  if(sync_ebr_not_empty[0] & bus_idle)
                   begin
                    rr_nstate = EBR1;
                   end
              end
       EBR1 : begin
                  if(sync_ebr_not_empty[1] & bus_idle)
                   begin
                    rr_nstate = EBR2;
                   end
              end
       EBR2 : begin
                  if(sync_ebr_not_empty[2] & bus_idle)
                   begin
                    rr_nstate = EBR3;
                   end
              end
       EBR3 : begin
                  if(sync_ebr_not_empty[3] & bus_idle)
                   begin
                    rr_nstate = EBR4;
                   end
               end
       EBR4 : begin
                  if(sync_ebr_not_empty[4] & bus_idle)
                   begin
                    rr_nstate = EBR5;
                   end
               end
       EBR5 : begin
                  if(sync_ebr_not_empty[5] & bus_idle)
                   begin
                   rr_nstate = EBR6;
                   end
              end
       EBR6 : begin
                 if(sync_ebr_not_empty[6] & bus_idle)
                   begin
                   rr_nstate = EBR7;
                   end
              end
       EBR7 : begin
                if(sync_ebr_not_empty[7] & bus_idle) 
                   begin
                   rr_nstate = EBR0;
                   end
              end
            endcase


end

always @(posedge hclk or negedge hrst_n)
   if(!hrst_n)
     rr_pstate <= EBR0;
   else
     rr_pstate <= rr_nstate;


always @(posedge hclk or negedge hrst_n)
   if(!hrst_n)
     dpram_rddata_d <= 0;
   else if(dpram_rd)
     dpram_rddata_d <= dpram_rddata;


logic sig_read_done;
assign bus_idle = bus_pstate == IDLE | sig_read_done;
assign sig_dpram_rddata = dpram_rddata_d;

always_comb begin
   bus_nstate      = bus_pstate;
   sig_read_done   = 1'b0;
   case(bus_pstate)
      IDLE : begin
         if(enable_bus)
            bus_nstate = BUS_READ;
      end      
      BUS_READ : begin
         //if(end_count_r & axi_rready_i & axi_rlast_o) begin  // Reduced end_count_r to 1 bit reg for better STA
         if(axi_rready_i & axi_rlast_o) begin  // Reduced end_count_r to 1 bit reg for better STA
            sig_read_done = 1'b1;
            bus_nstate    = (enable_bus) ?  BUS_READ : IDLE;
         end
      end
   endcase
end // always_comb


logic                      enable_bus_d;
logic                      enable_bus_dd     /* synthesis syn_preserve=1 */;
logic                      enable_bus_dd_rep1/* synthesis syn_preserve=1 */;
logic                      enable_bus_dd_rep2/* synthesis syn_preserve=1 */;
logic [SIZE_CNT_WIDTH-1:0] size_count;
logic [SIZE_CNT_WIDTH-1:0] size_count_nxt;
logic [SIZE_CNT_WIDTH-1:0] sig_size_count;
logic [SIZE_CNT_WIDTH-1:0] sig16_size_count;
logic [SIZE_CNT_WIDTH-1:0] sig32_size_count;
logic [SIZE_CNT_WIDTH-1:0] sig64_size_count;
logic                      addr_sel;
logic [SIZE_CNT_WIDTH-1:0] nxt_size_count;
logic [SIZE_CNT_WIDTH-1:0] nxt16_size_count;
logic [SIZE_CNT_WIDTH-1:0] nxt32_size_count;
logic [SIZE_CNT_WIDTH-1:0] nxt64_size_count;
logic                      ebr_rdaddr_inc /* synthesis syn_keep=1 */;
logic                      first_ebr_rd_r;
logic                      ebr_rd_ok_nxt;
logic                      ebr_rd_ok_r    /* synthesis syn_preserve=1 */;
logic                      ebr_rd_ok_rep1_r/* synthesis syn_preserve=1 */;
logic                      ebr_rd_ok_rep2_r/* synthesis syn_preserve=1 */;
logic                      ebr_rd_ok_rep3_r/* synthesis syn_preserve=1 */;
logic                      size_count_eq1_r;

//assign ebr_rd = (enable_bus_dd && !axi_rlast_o) | enable_bus_d | (axi_rvalid_r && axi_rready_i && size_count == 1);
//assign ebr_rd = (enable_bus_dd && !axi_rlast_o) | (axi_rvalid_r && axi_rready_i && size_count == 1);
assign ebr_rdaddr_inc = (enable_bus_dd && !axi_rlast_o) | enable_bus_d | (axi_rvalid_r && axi_rready_i && size_count == 1);
// first_ebr_rd_r is equivalent to (enable_bus_dd && !axi_rlast_o) | enable_bus_d
assign ebr_rd        = first_ebr_rd_r | (ebr_rd_ok_r && axi_rready_i);
assign ebr_rd_ok_nxt = axi_rvalid_nxt && (size_count_nxt == 1);

always @(posedge hclk or negedge hrst_n)
   if(!hrst_n) begin
     enable_bus_d       <= 1'b0;
     enable_bus_dd      <= 1'b0;
     enable_bus_dd_rep1 <= 1'b0;
     enable_bus_dd_rep2 <= 1'b0;
     first_ebr_rd_r     <= 1'b0;
     ebr_rd_ok_r        <= 1'b0;
     ebr_rd_ok_rep1_r   <= 1'b0;
     ebr_rd_ok_rep2_r   <= 1'b0;
     ebr_rd_ok_rep3_r   <= 1'b0;
   end else begin
     enable_bus_d       <= enable_bus;
     enable_bus_dd      <= enable_bus_d;
     enable_bus_dd_rep1 <= enable_bus_d;
     enable_bus_dd_rep2 <= enable_bus_d;
     first_ebr_rd_r     <= (enable_bus_d && !axi_rlast_nxt) | enable_bus;
     ebr_rd_ok_r        <= ebr_rd_ok_nxt;
     ebr_rd_ok_rep1_r   <= ebr_rd_ok_nxt;
     ebr_rd_ok_rep2_r   <= ebr_rd_ok_nxt;
     ebr_rd_ok_rep3_r   <= ebr_rd_ok_nxt;
   end

always @(posedge hclk or negedge hrst_n)
   if(!hrst_n)
     bus_pstate <= IDLE;
   else
     bus_pstate <= bus_nstate;

assign len_val_nxt = enable_bus_d ? sig_dpram_rddata[AXI_LEN_WIDTH-1:0] : len_val_r;

always_ff @(posedge hclk or negedge hrst_n) begin
   if(!hrst_n)
      len_val_r <= {SIZE_CNT_WIDTH{1'b0}};
   else 
      len_val_r <= len_val_nxt;
end // always_ff



always_comb begin
   if (dpram_rd)
      size_count_nxt = sig_size_count;
   else if (axi_rvalid_r & axi_rready_i & size_count == 1)
      size_count_nxt = nxt_size_count;
   else if (axi_rvalid_r  & axi_rready_i)
      size_count_nxt = size_count-1;
   else 
      size_count_nxt = size_count;
end

always_ff @(posedge hclk or negedge hrst_n)
   if(!hrst_n)
      size_count <= {SIZE_CNT_WIDTH{1'b0}};
   else if(enable_bus_d)
      size_count <= sig_size_count;
   else  
      size_count <= size_count_nxt;

logic [2:0]axi_size;
logic [7:0]axi_addr;
logic [7:0]axi_nxt_addr;
logic [INT_ID_WIDTH-1:0]int_id;
logic [AXI_ID_WIDTH-1:0]axi_rid;
logic [3:0]data_sel;

assign axi_size = sig_dpram_rddata[TOTAL_CTRL_WIDTH-1:AXI_LEN_WIDTH+INT_ID_WIDTH+AXI_ID_WIDTH];
assign axi_addr = sig_dpram_rddata[TOTAL_CTRL_WIDTH +8-1:TOTAL_CTRL_WIDTH];
assign int_id = sig_dpram_rddata[AXI_LEN_WIDTH+INT_ID_WIDTH-1:AXI_LEN_WIDTH];
assign axi_rid = sig_dpram_rddata[AXI_LEN_WIDTH+INT_ID_WIDTH+AXI_ID_WIDTH-1:AXI_LEN_WIDTH+INT_ID_WIDTH];


assign sig16_size_count =  5'b10000 - axi_addr[3:0]  >> axi_size;
assign sig32_size_count =  6'b100000 - axi_addr[4:0] >> axi_size;
assign sig64_size_count =  7'b1000000 - axi_addr[5:0] >> axi_size;
assign sig_size_count = (DDR_WIDTH ==16) ? sig16_size_count : (DDR_WIDTH == 32) ? sig32_size_count : sig64_size_count;
assign nxt16_size_count =  5'b10000 >> axi_size;
assign nxt32_size_count =  6'b100000  >> axi_size;
assign nxt64_size_count =  7'b1000000  >> axi_size;
assign nxt_size_count = (DDR_WIDTH ==16) ? nxt16_size_count : (DDR_WIDTH == 32) ? nxt32_size_count : nxt64_size_count;


always_comb begin
  if(dpram_rd)
    count_nxt = {SIZE_CNT_WIDTH{1'b0}};
  else if(axi_rvalid_r & axi_rready_i)
    count_nxt = count + 1;
  else 
    count_nxt = count;
end // always_comb

always_ff @(posedge hclk or negedge hrst_n) begin
  if(!hrst_n) begin
    count       <= {SIZE_CNT_WIDTH{1'b0}};
    //end_count_r <= 1'b0;
  end 
  else begin
    count       <= count_nxt;
   // end_count_r <= (count_nxt == (len_val_nxt-1)) | (len_val_nxt == 1);
  end
end // always_ff


assign ebr_rdaddr = (enable_bus_d) ?  {int_id,5'h0,addr_sel} : sig_ebr_rdaddr; 

always @(posedge hclk or negedge hrst_n)
   if(!hrst_n)
      sig_ebr_rdaddr  <= {RE_ADDR_WIDTH{1'b0}};
   else if(enable_bus_d)
      sig_ebr_rdaddr <= {int_id,5'h0,addr_sel} + 1;
   //else if(ebr_rd)
   else if (ebr_rdaddr_inc)
      sig_ebr_rdaddr <= sig_ebr_rdaddr + 1;

assign addr_sel = (DDR_WIDTH == 16) ? sig_dpram_rddata[TOTAL_CTRL_WIDTH+4] :  (DDR_WIDTH == 32) ? sig_dpram_rddata[TOTAL_CTRL_WIDTH+5] :  sig_dpram_rddata[TOTAL_CTRL_WIDTH+6];

always @(posedge hclk or negedge hrst_n)
   if(!hrst_n)
      axi_rid_o  <= {AXI_ID_WIDTH{1'b0}};
   else if((enable_bus_dd & !axi_rlast_o) | (axi_rlast_o & axi_rready_i)) 
      axi_rid_o  <= axi_rid; 

//always @(posedge hclk or negedge hrst_n)
//   if(!hrst_n)
//      axi_rvalid_o  <= 1'b0;
//    else if(enable_bus_dd) 
//      axi_rvalid_o  <= 1'b1;
//   else if(count == len_val_r -1 & axi_rready_i)
//      axi_rvalid_o  <= 1'b0;
always_comb begin 
   if(enable_bus_dd) 
      axi_rvalid_nxt  = 1'b1;
   else if((count == len_val_r -1) & axi_rready_i)
      axi_rvalid_nxt  = 1'b0;
   else 
      axi_rvalid_nxt  = axi_rvalid_r;
end

always_ff @(posedge hclk or negedge hrst_n) begin
   if(!hrst_n) begin
      axi_rvalid_o  <= 1'b0;
      axi_rvalid_r  <= 1'b0;
   end
   else begin
      axi_rvalid_o  <= axi_rvalid_nxt;
      axi_rvalid_r  <= axi_rvalid_nxt;
   end
end


always_comb begin
   if ((count == len_val_r -2 & axi_rready_i & len_val_r != 0 & axi_rvalid_r) | (len_val_r == 1  & enable_bus_dd))
      axi_rlast_nxt  = 1'b1;
   else if (axi_rready_i)
      axi_rlast_nxt  = 1'b0;
   else
      axi_rlast_nxt  = axi_rlast_o;
end

always_ff @(posedge hclk or negedge hrst_n)
   if(!hrst_n)
      axi_rlast_o  <= 1'b0;
   else 
      axi_rlast_o  <= axi_rlast_nxt;

always_ff @(posedge hclk or negedge hrst_n)
   if(!hrst_n)
      axi_nxt_addr  <= 8'b0;
   else if(enable_bus_d) 
      axi_nxt_addr <= axi_addr;
   else if(enable_bus_dd | (axi_rvalid_o & axi_rready_i))
      axi_nxt_addr <= axi_nxt_addr + (1 << axi_size);


generate
if(AXI_DATA_WIDTH == DDR_WIDTH * 4)
assign data_sel = (DDR_WIDTH == 16) ? axi_nxt_addr[3] : (DDR_WIDTH == 32) ? axi_nxt_addr[4] : axi_nxt_addr[5];
if(AXI_DATA_WIDTH == DDR_WIDTH * 2)
assign data_sel = (DDR_WIDTH == 16) ? axi_nxt_addr[3:2] : (DDR_WIDTH == 32) ? axi_nxt_addr[4:3] : axi_nxt_addr[5:4];
if(AXI_DATA_WIDTH == DDR_WIDTH * 1)
assign data_sel = (DDR_WIDTH == 16) ? axi_nxt_addr[3:1] : (DDR_WIDTH == 32) ? axi_nxt_addr[4:2] : axi_nxt_addr[5:3];
if(AXI_DATA_WIDTH == DDR_WIDTH /2)
assign data_sel = (DDR_WIDTH == 16) ? axi_nxt_addr[3:0] : (DDR_WIDTH == 32) ? axi_nxt_addr[4:1] : axi_nxt_addr[5:2];
endgenerate

assign rdata_out_en = enable_bus_dd | (ebr_rd_ok_rep3_r & axi_rready_i);

/*****
assign rdata_out_en_nxt = enable_bus_d | ebr_rd_ok_nxt;

always_ff @(posedge hclk  or negedge hrst_n)
    if(!hrst_n)
       rdata_out_en_r <= 'h0;
    else 
       rdata_out_en_r  <= (rdata_out_en_nxt);

end 
assign rdata_out_en  = rdata_out_en_r & axi_rready_i ;
****/
assign rdata_out_en_rep1 = enable_bus_dd_rep1 | (ebr_rd_ok_rep1_r & axi_rready_i);
assign rdata_out_en_rep2 = enable_bus_dd_rep2 | (ebr_rd_ok_rep2_r & axi_rready_i);

assign sig_ebr_rddata = (rdata_out_en) ? ebr_rddata : ebr_rddata_d;

always_ff @(posedge hclk or negedge hrst_n)
   if(!hrst_n)
      ebr_rddata_d  <= 8'b0;
   else if(rdata_out_en) 
      ebr_rddata_d <= ebr_rddata;

generate
if(AXI_DATA_WIDTH == DDR_WIDTH * 8)
begin
always @(posedge hclk or negedge hrst_n)
   if(!hrst_n)
      axi_rdata_o   <= {AXI_DATA_WIDTH{1'b0}};
   else begin
      if (rdata_out_en_rep1)
        axi_rdata_o[(AXI_DATA_WIDTH/2)-1:0]          <= ebr_rddata[(AXI_DATA_WIDTH/2)-1:0];
      if (rdata_out_en_rep2)
        axi_rdata_o[AXI_DATA_WIDTH-1:AXI_DATA_WIDTH/2] <= ebr_rddata[AXI_DATA_WIDTH-1:AXI_DATA_WIDTH/2];
   end
end
if(AXI_DATA_WIDTH == DDR_WIDTH * 4)
begin
always @(posedge hclk or negedge hrst_n)
   if(!hrst_n)
      axi_rdata_o   <= {AXI_DATA_WIDTH{1'b0}};
   else if ((enable_bus_dd | (axi_rvalid_o & axi_rready_i)) & !data_sel[0])
      axi_rdata_o   <= sig_ebr_rddata[BI_RD_DATA_Q_WIDTH/2 - 1 : 0];
   else if ((enable_bus_dd | (axi_rvalid_o & axi_rready_i)) & data_sel[0])
      axi_rdata_o   <= sig_ebr_rddata[BI_RD_DATA_Q_WIDTH-1 : BI_RD_DATA_Q_WIDTH/2];
end
if(AXI_DATA_WIDTH == DDR_WIDTH * 2)
begin
always @(posedge hclk or negedge hrst_n)
   if(!hrst_n)
      axi_rdata_o   <= {AXI_DATA_WIDTH{1'b0}};
   else if ((enable_bus_dd | (axi_rvalid_o & axi_rready_i)) & data_sel[1:0] == 2'b00)
      axi_rdata_o   <= sig_ebr_rddata[BI_RD_DATA_Q_WIDTH/4 - 1 : 0];
   else if ((enable_bus_dd | (axi_rvalid_o & axi_rready_i)) & data_sel[1:0] == 2'b01)
      axi_rdata_o   <= sig_ebr_rddata[BI_RD_DATA_Q_WIDTH/2 -1 : BI_RD_DATA_Q_WIDTH/4];
   else if ((enable_bus_dd | (axi_rvalid_o & axi_rready_i)) & data_sel[1:0] == 2'b10)
      axi_rdata_o   <= sig_ebr_rddata[(BI_RD_DATA_Q_WIDTH * 3)/4 -1 : BI_RD_DATA_Q_WIDTH/2];
   else if ((enable_bus_dd | (axi_rvalid_o & axi_rready_i)) & data_sel[1:0] == 2'b11)
      axi_rdata_o   <= sig_ebr_rddata[(BI_RD_DATA_Q_WIDTH) -1 : (BI_RD_DATA_Q_WIDTH * 3)/4];
end
if(AXI_DATA_WIDTH == DDR_WIDTH * 1)
begin
always @(posedge hclk or negedge hrst_n)
   if(!hrst_n)
      axi_rdata_o   <= {AXI_DATA_WIDTH{1'b0}};
   else if ((enable_bus_dd | (axi_rvalid_o & axi_rready_i)) & data_sel[2:0] == 3'b000)
      axi_rdata_o   <= sig_ebr_rddata[BI_RD_DATA_Q_WIDTH/8 - 1 : 0];
   else if ((enable_bus_dd | (axi_rvalid_o & axi_rready_i)) & data_sel[2:0] == 3'b001)
      axi_rdata_o   <= sig_ebr_rddata[BI_RD_DATA_Q_WIDTH*2/8 -1 : BI_RD_DATA_Q_WIDTH/8];
   else if ((enable_bus_dd | (axi_rvalid_o & axi_rready_i)) & data_sel[2:0] == 3'b010)
      axi_rdata_o   <= sig_ebr_rddata[(BI_RD_DATA_Q_WIDTH*3)/8 -1 : (BI_RD_DATA_Q_WIDTH*2)/8];
   else if ((enable_bus_dd | (axi_rvalid_o & axi_rready_i)) & data_sel[2:0] == 3'b011)
      axi_rdata_o   <= sig_ebr_rddata[(BI_RD_DATA_Q_WIDTH*4)/8 -1 : (BI_RD_DATA_Q_WIDTH*3)/8];
   else if ((enable_bus_dd | (axi_rvalid_o & axi_rready_i)) & data_sel[2:0] == 3'b100)
      axi_rdata_o   <= sig_ebr_rddata[(BI_RD_DATA_Q_WIDTH*5)/8 -1 : (BI_RD_DATA_Q_WIDTH*4)/8];
   else if ((enable_bus_dd | (axi_rvalid_o & axi_rready_i)) & data_sel[2:0] == 3'b101)
      axi_rdata_o   <= sig_ebr_rddata[(BI_RD_DATA_Q_WIDTH*6)/8 -1 : (BI_RD_DATA_Q_WIDTH*5)/8];
   else if ((enable_bus_dd | (axi_rvalid_o & axi_rready_i)) & data_sel[2:0] == 3'b110)
      axi_rdata_o   <= sig_ebr_rddata[(BI_RD_DATA_Q_WIDTH*7)/8 -1 : (BI_RD_DATA_Q_WIDTH*6)/8];
   else if ((enable_bus_dd | (axi_rvalid_o & axi_rready_i)) & data_sel[2:0] == 3'b111)
      axi_rdata_o   <= sig_ebr_rddata[BI_RD_DATA_Q_WIDTH -1 : (BI_RD_DATA_Q_WIDTH*7)/8];

end
if(AXI_DATA_WIDTH == DDR_WIDTH/2)
begin
always @(posedge hclk or negedge hrst_n)
   if(!hrst_n)
      axi_rdata_o   <= {AXI_DATA_WIDTH{1'b0}};
   else if ((enable_bus_dd | (axi_rvalid_o & axi_rready_i)) & data_sel[3:0] == 4'h0)
      axi_rdata_o   <= sig_ebr_rddata[BI_RD_DATA_Q_WIDTH/16 - 1 : 0];
   else if ((enable_bus_dd | (axi_rvalid_o & axi_rready_i)) & data_sel[3:0] == 4'h1)
      axi_rdata_o   <= sig_ebr_rddata[BI_RD_DATA_Q_WIDTH*2/16 -1 : BI_RD_DATA_Q_WIDTH/16];
   else if ((enable_bus_dd | (axi_rvalid_o & axi_rready_i)) & data_sel[3:0] == 4'h2)
      axi_rdata_o   <= sig_ebr_rddata[(BI_RD_DATA_Q_WIDTH*3)/16 -1 : (BI_RD_DATA_Q_WIDTH*2)/16];
   else if ((enable_bus_dd | (axi_rvalid_o & axi_rready_i)) & data_sel[3:0] == 4'h3)
      axi_rdata_o   <= sig_ebr_rddata[(BI_RD_DATA_Q_WIDTH*4)/16 -1 : (BI_RD_DATA_Q_WIDTH*3)/16];
   else if ((enable_bus_dd | (axi_rvalid_o & axi_rready_i)) & data_sel[3:0] == 4'h4)
      axi_rdata_o   <= sig_ebr_rddata[(BI_RD_DATA_Q_WIDTH*5)/16 -1 : (BI_RD_DATA_Q_WIDTH*4)/16];
   else if ((enable_bus_dd | (axi_rvalid_o & axi_rready_i)) & data_sel[3:0] == 4'h5)
      axi_rdata_o   <= sig_ebr_rddata[(BI_RD_DATA_Q_WIDTH*6)/16 -1 : (BI_RD_DATA_Q_WIDTH*5)/16];
   else if ((enable_bus_dd | (axi_rvalid_o & axi_rready_i)) & data_sel[3:0] == 4'h6)
      axi_rdata_o   <= sig_ebr_rddata[(BI_RD_DATA_Q_WIDTH*7)/16 -1 : (BI_RD_DATA_Q_WIDTH*6)/16];
   else if ((enable_bus_dd | (axi_rvalid_o & axi_rready_i)) & data_sel[3:0] == 4'h7)
      axi_rdata_o   <= sig_ebr_rddata[(BI_RD_DATA_Q_WIDTH*8)/16 -1 : (BI_RD_DATA_Q_WIDTH*7)/16];
   else if ((enable_bus_dd | (axi_rvalid_o & axi_rready_i)) & data_sel[3:0] == 4'h8)
      axi_rdata_o   <= sig_ebr_rddata[(BI_RD_DATA_Q_WIDTH*9)/16 -1 : (BI_RD_DATA_Q_WIDTH*8)/16];
   else if ((enable_bus_dd | (axi_rvalid_o & axi_rready_i)) & data_sel[3:0] == 4'h9)
      axi_rdata_o   <= sig_ebr_rddata[(BI_RD_DATA_Q_WIDTH*10)/16 -1 : (BI_RD_DATA_Q_WIDTH*9)/16];
   else if ((enable_bus_dd | (axi_rvalid_o & axi_rready_i)) & data_sel[3:0] == 4'ha)
      axi_rdata_o   <= sig_ebr_rddata[(BI_RD_DATA_Q_WIDTH*11)/16 -1 : (BI_RD_DATA_Q_WIDTH*10)/16];
   else if ((enable_bus_dd | (axi_rvalid_o & axi_rready_i)) & data_sel[3:0] == 4'hb)
      axi_rdata_o   <= sig_ebr_rddata[(BI_RD_DATA_Q_WIDTH*12)/16 -1 : (BI_RD_DATA_Q_WIDTH*11)/16];
   else if ((enable_bus_dd | (axi_rvalid_o & axi_rready_i)) & data_sel[3:0] == 4'hc)
      axi_rdata_o   <= sig_ebr_rddata[(BI_RD_DATA_Q_WIDTH*13)/16 -1 : (BI_RD_DATA_Q_WIDTH*12)/16];
   else if ((enable_bus_dd | (axi_rvalid_o & axi_rready_i)) & data_sel[3:0] == 4'hd)
      axi_rdata_o   <= sig_ebr_rddata[(BI_RD_DATA_Q_WIDTH*14)/16 -1 : (BI_RD_DATA_Q_WIDTH*13)/16];
   else if ((enable_bus_dd | (axi_rvalid_o & axi_rready_i)) & data_sel[3:0] == 4'he)
      axi_rdata_o   <= sig_ebr_rddata[(BI_RD_DATA_Q_WIDTH*15)/16 -1 : (BI_RD_DATA_Q_WIDTH*14)/16];
   else if ((enable_bus_dd | (axi_rvalid_o & axi_rready_i)) & data_sel[3:0] == 4'hf)
      axi_rdata_o   <= sig_ebr_rddata[BI_RD_DATA_Q_WIDTH -1 : (BI_RD_DATA_Q_WIDTH*15)/16];

end
endgenerate


endmodule
