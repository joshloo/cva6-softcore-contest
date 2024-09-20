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
// File                  : lscc_axi4_m_rd.v
// Title                 :
// Dependencies          : 1.
//                       : 2.
// Description           :
// =============================================================================
//                        REVISION HISTORY
// Version               : 1.0.0
// Author(s)             :
// Mod. Date             :
// Changes Made          : Initial release.
// =============================================================================

module lscc_axi4_m_rd #(
  parameter DDR_WIDTH      = 1,
  parameter AXI_DATA_WIDTH = 1,
  parameter AXI_ADDR_WIDTH = 1,
  parameter AXI_LEN_WIDTH  = 1,
  parameter AXI_ID_WIDTH   = 1,
  parameter CNTR_WIDTH     = 20,
  parameter TIMEOUT_VALUE  = 521,
  parameter TIMEOUT_WIDTH  = 10
)
(
//CLOCKS AND RESETS
  input                             aclk_i    ,
  input                             areset_n_i,

  output                            rd_timeout_o ,
  output logic                      rd_err_o     ,
//AXI INTERFACE SIGNALS
  input                             axi_arready_i,
  output logic                      axi_arvalid_o/* synthesis syn_preserve=1 */,
  output logic [AXI_ADDR_WIDTH-1:0] axi_araddr_o ,
  output logic [2:0]                axi_arsize_o ,
  output logic [AXI_LEN_WIDTH-1:0]  axi_arlen_o  ,
  output logic [1:0]                axi_arburst_o,  // Currently fixed to INCR
  output logic [3:0]                axi_arqos_o  ,  // Currently fixed to 0
  output logic [AXI_ID_WIDTH-1:0]   axi_arid_o   ,

  output logic                      axi_rready_o/* synthesis syn_preserve=1 */,
  input                             axi_rvalid_i,
  input        [AXI_DATA_WIDTH-1:0] axi_rdata_i ,
  input        [1:0]                axi_rresp_i ,
  input        [AXI_ID_WIDTH-1:0]   axi_rid_i   ,
  input                             axi_rlast_i ,
//SIGNALS FROM CSR
  input        [AXI_LEN_WIDTH-1:0]  cfg_arlen           ,
  input        [1:0]                cfg_arburst         ,
  input        [2:0]                cfg_arsize          ,
  input        [AXI_ID_WIDTH-1:0]   cfg_arid            ,
  input                             cfg_fixed_araddr    ,
  input        [31:0]               cfg_rd_addr_seed    ,
  input        [31:0]               cfg_rd_data_seed_1  ,
  input        [31:0]               cfg_rd_data_seed_2  ,
  input        [CNTR_WIDTH-1:0]     cfg_num_of_rd_trans ,
  input                             cfg_randomize_rdaddr,
  input                             cfg_randomize_rdctrl,
  input        [5:0]                cfg_rd_txn_delay    ,
  input                             rd_start            ,
//SIGNALS TO CSR
  output logic         rd_txn_done /* synthesis syn_preserve=1 */,
  output logic         rd_error   ,   // FIXME: Assert this when error occur on the burst
  output logic [19:0]  num_of_rd_trans
);
localparam  AXI_STRB_WIDTH  = AXI_DATA_WIDTH/8;
localparam [2:0] MAX_SIZE   = (AXI_STRB_WIDTH == 128) ? 3'h7 :
                              (AXI_STRB_WIDTH == 64)  ? 3'h6 :
                              (AXI_STRB_WIDTH == 32)  ? 3'h5 :
                              (AXI_STRB_WIDTH == 16)  ? 3'h4 :
                              (AXI_STRB_WIDTH == 8)   ? 3'h3 :
                              (AXI_STRB_WIDTH == 4)   ? 3'h2 :
                              (AXI_STRB_WIDTH == 2)   ? 3'h1 : 0;
localparam OFFSET_BIT        = MAX_SIZE + 2;
localparam NUM_OF_LFSR16     = AXI_DATA_WIDTH / 16 + ((AXI_DATA_WIDTH % 16 == 0) ? 0 : 1);
localparam NUM_BYTES         = AXI_DATA_WIDTH / 8;
localparam NUM_LANE          = (NUM_BYTES > 8) ? NUM_BYTES/8 : 1;

// Separate state per channel
typedef enum logic [1:0] {AR_IDLE, AR_ADDR, AR_WAIT} State_ar;
State_ar currState_ar, nextState_ar;

// To add WD_WAIT if valid de-assertion will be supported
typedef enum logic [1:0] {RD_IDLE, RD_SETUP, RD_DATA} State_rd;
State_rd currState_rd, nextState_rd;


logic [31:0]               lfsr_out_araddr;
logic [2:0]                lfsr_out_arsize;
logic [AXI_LEN_WIDTH-1:0]  lfsr_out_arlen;
logic [AXI_ID_WIDTH-1:0]   lfsr_out_arid;

logic [AXI_ADDR_WIDTH-1:0] mux_araddr;
logic [2:0]                mux_arsize;
logic [AXI_LEN_WIDTH-1:0]  mux_arlen;
logic [AXI_ID_WIDTH-1:0]   mux_arid;
logic [1:0]                mux_arburst;

logic [511:0]              lfsr_data_seed;
logic [511:0]              lfsr_out_data;
logic                      lfsr_addr_enable;
logic                      lfsr_ctrl_enable;
logic                      lfsr_data_enable;
logic                      lfsr_addr_ld_seed_r;
logic                      lfsr_ctrl_ld_seed_r;
logic                      lfsr_data_ld_seed_r;

logic [5:0]                trans_delay_r ;
logic [AXI_LEN_WIDTH-1:0]  trans_length_r;
logic                      data_done_r   ;
logic                      trans_ready_r ;
logic [CNTR_WIDTH-1:0]     trans_cnt_r   ;
logic                      is_last_addr_r /* synthesis syn_preserve=1 */;
//logic [CNTR_WIDTH-1:0]     resp_cnt_r    ;
//logic                      is_last_resp_r;

logic [2:0]                mux_arsize_r  ;
logic [AXI_LEN_WIDTH:0]    mux_arlen_p1_r;
logic [16:0]               addr_inc_w    ;
logic [16:0]               addr_inc_r    ;

logic                      a2d_wr_en_nxt;
logic                      a2d_wr_en    ;
logic                      a2d_rd_en    ;
logic [AXI_LEN_WIDTH+2:0]  a2d_wr_data  ;
logic                      a2d_full     ;
logic                      a2d_empty    ;
logic [AXI_LEN_WIDTH+2:0]  a2d_rd_data  ;
logic                      rst_w        ;

// Replicating axi_arvalid_o and axi_rready_o
logic                      axi_arvalid_r/* synthesis syn_preserve=1 */;
logic                      axi_rready_r /* synthesis syn_preserve=1 */;
logic                      axi_arvalid_nxt;
logic                      axi_rready_nxt ;

assign rst_w = ~areset_n_i;

//////////////////////////////////////////////////////////////////////////////////////////////////////////
always_ff @(posedge aclk_i or negedge areset_n_i) begin
  if(!areset_n_i) begin
    trans_delay_r <= 1'b0;
    trans_ready_r <= 1'b0;
  end
  else begin
    if(axi_rlast_i & axi_rvalid_i & axi_rready_r) begin
      trans_delay_r <= cfg_rd_txn_delay;
    end
    else if (trans_delay_r != 0)
      trans_delay_r <= trans_delay_r - 1;
    // Signal to insert delay between transfers
    trans_ready_r <= (trans_delay_r <= 1) ? 1'b1 : 1'b0;
    if(axi_rlast_i & axi_rvalid_i & axi_rready_r)
      data_done_r   <= 1'b1;
    else if (axi_arvalid_r & axi_arready_i)
      data_done_r   <= 1'b0;
  end
end  // always_ff


///////////////////////   Write Address Channel Logic  ///////////////////////
//typedef enum logic [1:0] {AR_IDLE, AR_ADDR, AR_WAIT} State_ar;
//State_ar , ;

// Read Address Channel FSM: Next State
always_comb
  begin
  nextState_ar  = currState_ar;
  a2d_wr_en_nxt = 1'b0;
  case(currState_ar)
  AR_IDLE  : begin
             nextState_ar  = rd_start ? AR_ADDR : AR_IDLE;
             a2d_wr_en_nxt = rd_start;
           end
  AR_ADDR  : nextState_ar = (axi_arvalid_r & axi_arready_i) ? AR_WAIT : AR_ADDR;
  AR_WAIT  : begin
              if (a2d_full)
                nextState_ar    = AR_WAIT;
              else if (is_last_addr_r)
                nextState_ar    = AR_IDLE;
              else begin
                if (cfg_rd_txn_delay == 0) begin
                  nextState_ar  = AR_ADDR;   // Do outstanding transactions
                  a2d_wr_en_nxt = 1'b1;
                end
                else if (data_done_r & trans_ready_r) begin
                  nextState_ar  =  AR_ADDR;
                  a2d_wr_en_nxt = 1'b1;
                end
                else
                  nextState_ar  =  AR_WAIT;
              end
           end
  default  : nextState_ar = AR_IDLE;
  endcase
end

// Read Address Channel FSM: Current State
always_ff @(posedge aclk_i or negedge areset_n_i) begin
  if(!areset_n_i)
   currState_ar <= AR_IDLE;
  else
   currState_ar <= nextState_ar;
end

// Read Address Channel FSM: State Outputs
// Remove axi_arvalid_o for replication
always_ff @(posedge aclk_i or negedge areset_n_i)
 begin
  if(!areset_n_i) begin
//    axi_arvalid_o  <= 1'b0;
    axi_araddr_o   <= {AXI_ADDR_WIDTH{1'b0}};
    axi_arsize_o   <= 3'h0;
    axi_arlen_o    <= {AXI_LEN_WIDTH{1'b0}};
    axi_arburst_o  <= 2'h1;
    axi_arid_o     <= {AXI_ID_WIDTH{1'b0}};
    a2d_wr_en      <= 1'b0;
  end
  else begin
    a2d_wr_en      <= a2d_wr_en_nxt;
    case(currState_ar)
      AR_IDLE      : begin
        if (rd_start) begin    // The start will happen only during A2D fifo is empty
//          axi_arvalid_o  <= 1'b1;
          axi_araddr_o   <= mux_araddr;
          axi_arsize_o   <= mux_arsize;
          axi_arlen_o    <= mux_arlen;
          axi_arburst_o  <= mux_arburst;
          axi_arid_o     <= mux_arid;
        end
        else begin
//          axi_arvalid_o  <= 1'b0;
          axi_araddr_o   <= {AXI_ADDR_WIDTH{1'b0}};
          axi_arsize_o   <= 3'h0;
          axi_arlen_o    <= {AXI_LEN_WIDTH{1'b0}};
          axi_arburst_o  <= 2'h0;
          axi_arid_o     <= {AXI_ID_WIDTH{1'b0}};
        end
      end
      AR_ADDR: begin
        if(axi_arready_i) begin
//          axi_arvalid_o  <= 1'b0;
          if (!cfg_fixed_araddr)
            axi_araddr_o   <= axi_araddr_o + addr_inc_r;
          // The control signals are not changed for the next burst
        end
//        else
//          axi_arvalid_o  <= 1'b1;
      end
//      AR_WAIT : begin
//        axi_arvalid_o  <= a2d_wr_en_nxt;
//      end
    endcase
  end
end

// Generating axi_arvalid_nxt for replication
always_comb begin
  case(currState_ar)
//    AR_IDLE : axi_arvalid_nxt <= rd_start      ;
    AR_ADDR : axi_arvalid_nxt <= ~axi_arready_i;
    AR_WAIT : axi_arvalid_nxt <= a2d_wr_en_nxt ;
	default : axi_arvalid_nxt <= rd_start      ;
  endcase
end

// Replicating axi_arvalid_o
always_ff @(posedge aclk_i or negedge areset_n_i) begin
  if(!areset_n_i) begin
    axi_arvalid_o  <= 1'b0;
    axi_arvalid_r  <= 1'b0;
  end
  else begin
    axi_arvalid_o  <= axi_arvalid_nxt;
    axi_arvalid_r  <= axi_arvalid_nxt;
  end
end

logic [19:0] trans_cnt_p1;

assign trans_cnt_p1 = trans_cnt_r + 1;

// Read Address Channel FSM: Current State
always_ff @(posedge aclk_i or negedge areset_n_i) begin
  if(!areset_n_i) begin
    trans_cnt_r    <= 'h0;
    is_last_addr_r <= 1'b0;
  end
  else begin
    if ((currState_ar == AR_IDLE) & rd_start) begin
      trans_cnt_r    <= 'h0;
	  is_last_addr_r <= 1'b0;
	end
    else if (axi_arvalid_r & axi_arready_i) begin
      trans_cnt_r    <= trans_cnt_p1;
      is_last_addr_r <= trans_cnt_p1 == cfg_num_of_rd_trans;
	end
  end
end

assign axi_arqos_o     = 4'h0;  // QOS is not supported

generate
  // FIXME: Add address INCR feature
  if (AXI_ADDR_WIDTH <= 32) begin : LT32
	assign mux_araddr = cfg_randomize_rdaddr ? {lfsr_out_araddr[AXI_ADDR_WIDTH-1:OFFSET_BIT], {OFFSET_BIT{1'b0}}} : cfg_rd_addr_seed[AXI_ADDR_WIDTH-1:0];
  end
  else begin : MT32
	assign mux_araddr = cfg_randomize_rdaddr ? {{(AXI_ADDR_WIDTH-32){1'b0}}, lfsr_out_araddr[31:OFFSET_BIT],{OFFSET_BIT{1'b0}}} : {{(AXI_ADDR_WIDTH-32){1'b0}},{cfg_rd_addr_seed}};
  end
endgenerate

assign mux_arburst = cfg_arburst;  // AWBURST is not randomized

assign mux_arid    = !cfg_randomize_rdctrl ? cfg_arid   : lfsr_out_arid;
assign mux_arsize  = !cfg_randomize_rdctrl ? cfg_arsize : (lfsr_out_arsize > MAX_SIZE ? MAX_SIZE : lfsr_out_arsize);
assign mux_arlen   = !cfg_randomize_rdctrl ? cfg_arlen  : (lfsr_out_arlen <= 3 ? lfsr_out_arlen : ({lfsr_out_arlen[AXI_LEN_WIDTH-1:2],2'b00}-1));

// generating the address INCR

logic [AXI_LEN_WIDTH:0] mux_arlen_actual = mux_arlen + 1;

always_ff @(posedge aclk_i or negedge areset_n_i)
 begin
  if(!areset_n_i) begin
    mux_arsize_r   <= 3'h0;
    mux_arlen_p1_r <= 'h0;
    addr_inc_r     <= 'h0;
  end
  else begin
    mux_arsize_r   <= mux_arsize;
    mux_arlen_p1_r <= mux_arlen + 1;
//  addr_inc_r     <= 0;
    case (mux_arsize_r)
      0 : addr_inc_r[AXI_LEN_WIDTH:0]    <=  mux_arlen_p1_r;
      1 : addr_inc_r[AXI_LEN_WIDTH+1:0]  <= {mux_arlen_p1_r, 1'h0};  // x2
      2 : addr_inc_r[AXI_LEN_WIDTH+2:0]  <= {mux_arlen_p1_r, 2'h0};  // x4
      3 : addr_inc_r[AXI_LEN_WIDTH+3:0]  <= {mux_arlen_p1_r, 3'h0};  // x8
      4 : addr_inc_r[AXI_LEN_WIDTH+4:0]  <= {mux_arlen_p1_r, 4'h0};  // x16
      5 : addr_inc_r[AXI_LEN_WIDTH+5:0]  <= {mux_arlen_p1_r, 5'h00}; // x32
      6 : addr_inc_r[AXI_LEN_WIDTH+6:0]  <= {mux_arlen_p1_r, 6'h00}; // x64
      7 : addr_inc_r[AXI_LEN_WIDTH+7:0]  <= {mux_arlen_p1_r, 7'h00}; // x128
    endcase
  end
end

assign a2d_wr_data = {axi_arlen_o, axi_arsize_o};
// Transfering the control information to Data FSM
ctrl_fifo #(
    .DATA_WIDTH(AXI_LEN_WIDTH+3))
u_a2d_fifo (
    .clk_i    (aclk_i     ),
    .rst_i    (rst_w      ),
    .wr_en_i  (a2d_wr_en  ),
    .rd_en_i  (a2d_rd_en  ),
    .wr_data_i(a2d_wr_data),
    .full_o   (a2d_full   ),
    .empty_o  (a2d_empty  ),
    .rd_data_o(a2d_rd_data)
);




always_ff @(posedge aclk_i or negedge areset_n_i)
 begin
  if(!areset_n_i) begin
   lfsr_addr_ld_seed_r   <= 1'b0;
   lfsr_ctrl_ld_seed_r   <= 1'b0;
   lfsr_data_ld_seed_r   <= 1'b0;
  end
  else begin
   lfsr_addr_ld_seed_r   <= cfg_randomize_rdaddr & rd_start;
   lfsr_ctrl_ld_seed_r   <= cfg_randomize_rdctrl & rd_start;
   lfsr_data_ld_seed_r   <= rd_start | (axi_rlast_i & axi_rvalid_i & axi_rready_r & cfg_fixed_araddr);
  end
 end

assign lfsr_ctrl_enable = axi_arvalid_r & axi_arready_i;
assign lfsr_addr_enable = axi_arvalid_r & axi_arready_i & ~cfg_fixed_araddr;



//LFSRs to generate  READ controls
localparam MAX_LEN_WIDTH = 8;
localparam BURST_WIDTH   = 2;
localparam SIZE_WIDTH    = 3;
localparam MAX_ID_WIDTH  = 8;

localparam                  CTRL_WIDTH      = MAX_ID_WIDTH + SIZE_WIDTH + BURST_WIDTH + MAX_LEN_WIDTH; // 21
localparam [CTRL_WIDTH-1:0] CTRL_POLYNOMIAL = 21'h140000;  // x^21 + x^19 + 1

logic [CTRL_WIDTH-1:0] lfsr_ctrl_seed;
logic [CTRL_WIDTH-1:0] lfsr_ctrl_out ;

always_comb begin
  lfsr_ctrl_seed = 0;
  lfsr_ctrl_seed[AXI_LEN_WIDTH-1:0]  = cfg_arlen ;
  lfsr_ctrl_seed[9:8]                = 2'b01     ;
  lfsr_ctrl_seed[12:10]              = cfg_arsize;
  lfsr_ctrl_seed[AXI_ID_WIDTH+12:13] = cfg_arid  ;
end

lscc_lfsr #(
  .LFSR_WIDTH (CTRL_WIDTH     ),
  .POLYNOMIAL (CTRL_POLYNOMIAL),
  .LFSR_INIT  (21'h000001     ))
u_ctrl_gen (
  .clk_i    (aclk_i             ),
  .rst_i    (rst_w              ),
  .enb_i    (lfsr_ctrl_enable   ),
  .ld_seed_i(lfsr_ctrl_ld_seed_r),
  .din_i    (lfsr_ctrl_seed     ),
  .dout_o   (lfsr_ctrl_out      )
);

assign lfsr_out_arlen  = lfsr_ctrl_out[AXI_LEN_WIDTH-1:0];
assign lfsr_out_arsize = lfsr_ctrl_out[12:10];
assign lfsr_out_arid   = lfsr_ctrl_out[AXI_ID_WIDTH+12:13];

lscc_lfsr #(
  .LFSR_WIDTH (32          ),
  .POLYNOMIAL (32'h80200002),// x^32 + x^22 + x^2 + 1
  .LFSR_INIT  (32'h00000100)
)
u_araddr_gen (
  .clk_i      (aclk_i             ),
  .rst_i      (rst_w              ),
  .enb_i      (lfsr_addr_enable   ),
  .ld_seed_i  (lfsr_addr_ld_seed_r),
  .din_i      (cfg_rd_addr_seed   ),
  .dout_o     (lfsr_out_araddr    )
);


///////////////////////   Read Response Channel Logic  ///////////////////////

logic                       RD_SETUP_done_r;
wire                        is_last /* synthesis syn_keep=1 */;
logic                       exp_rlast_r    ;
logic  [AXI_DATA_WIDTH-1:0] exp_rddata_w   ;
//logic  [NUM_OF_LFSR16-1:0]  compare_data_r ;
logic  [NUM_BYTES-1:0]      compare_data_r ;
logic                       compare_err_r  ;
logic                       compare_en_r   ;

assign  is_last = exp_rlast_r & axi_rready_r & axi_rvalid_i;

//typedef enum logic [1:0] {RD_IDLE, RD_SETUP, RD_DATA} State_rd;
//State_rd currState_rd, nextState_rd;

// Read Response Channel FSM: Next State
always_comb
  begin
  nextState_rd  = currState_rd;
  case(currState_rd)
    RD_IDLE  : nextState_rd = a2d_empty ? RD_IDLE : RD_SETUP;
    RD_SETUP : nextState_rd = RD_SETUP_done_r ? RD_DATA : RD_SETUP;
    RD_DATA  : nextState_rd = is_last ? (a2d_empty ? RD_IDLE : RD_SETUP) : RD_DATA;
    default  : nextState_rd = RD_IDLE;
  endcase
end

// Read Response Channel FSM: Current State
always_ff @(posedge aclk_i or negedge areset_n_i) begin
  if(!areset_n_i)
   currState_rd <= RD_IDLE;
  else
   currState_rd <= nextState_rd;
end


// Read Response Channel FSM: State Outputs
// Removing axi_rready_o for replication
always_ff @(posedge aclk_i or negedge areset_n_i) begin
  if(!areset_n_i) begin
//    axi_rready_o    <= 1'b0;
    exp_rlast_r     <= 1'b0;
    RD_SETUP_done_r <= 1'b0;
    trans_length_r  <= 1'b0;
  end
  else begin
    RD_SETUP_done_r <= 1'b0; // This is to stay in RD_SETUP for 2 cycles
    exp_rlast_r     <= 1'b0;
    case(currState_rd)
      RD_IDLE  : begin
//                  axi_rready_o     <= 1'b0;
                  trans_length_r   <= 1'b0;
                end
      RD_SETUP : begin
                  RD_SETUP_done_r  <= 1'b1;
//                  axi_rready_o     <= RD_SETUP_done_r;
                  if (RD_SETUP_done_r)
                    trans_length_r <= a2d_rd_data[AXI_LEN_WIDTH+2:3];
                  exp_rlast_r      <= RD_SETUP_done_r & (a2d_rd_data[AXI_LEN_WIDTH+2:3] == {AXI_LEN_WIDTH{1'b0}});
                end
      RD_DATA  : begin
//                  axi_rready_o     <= (axi_rlast_i & axi_rvalid_i) ? 1'b0 : 1'b1;
`ifdef LAV_AT
                  if (exp_rlast_r)
                    exp_rlast_r <= axi_rvalid_i & axi_rready_r ? 1'b0 : 1'b1;
                  else
                    exp_rlast_r <= ((trans_length_r == 1) & axi_rvalid_i & axi_rready_r) | (trans_length_r == 0);
`else
                  exp_rlast_r      <= ~exp_rlast_r & (((trans_length_r == 1) & axi_rvalid_i & axi_rready_r) | (trans_length_r == 0));
`endif
                  if (axi_rvalid_i & axi_rready_r & (trans_length_r != 0))
                    trans_length_r <= trans_length_r - 1;
                end
    endcase

  end
end

// Generating axi_rready_nxt for replication
always_comb begin
  case(currState_rd)
    RD_SETUP : axi_rready_nxt <= RD_SETUP_done_r;
    RD_DATA  : axi_rready_nxt <= (axi_rlast_i & axi_rvalid_i) ? 1'b0 : 1'b1;
    default  : axi_rready_nxt <= 1'b0;
  endcase
end // always_comb

// Replicating axi_rready_o
always_ff @(posedge aclk_i or negedge areset_n_i) begin
  if(!areset_n_i) begin
    axi_rready_o <= 1'b0;
    axi_rready_r <= 1'b0;
  end
  else begin
    axi_rready_o <= axi_rready_nxt;
    axi_rready_r <= axi_rready_nxt;
  end
end

always_comb begin
    case(currState_rd)
      RD_IDLE  : a2d_rd_en = ~a2d_empty;
      RD_SETUP : a2d_rd_en = 1'b0;
      RD_DATA  : a2d_rd_en = is_last ? ~a2d_empty : 1'b0;
    endcase
end


logic [10:0]  dbg_num_lfsrs;
assign dbg_num_lfsrs = NUM_OF_LFSR16;

assign lfsr_data_seed[ 15:  0] =  cfg_rd_data_seed_1[15:0];
assign lfsr_data_seed[ 31: 16] = {cfg_rd_data_seed_1[14:0], cfg_rd_data_seed_1[15:15]};
assign lfsr_data_seed[ 47: 32] = {cfg_rd_data_seed_1[13:0], cfg_rd_data_seed_1[15:14]};
assign lfsr_data_seed[ 63: 48] = {cfg_rd_data_seed_1[12:0], cfg_rd_data_seed_1[15:13]};
assign lfsr_data_seed[ 79: 64] = {cfg_rd_data_seed_1[11:0], cfg_rd_data_seed_1[15:12]};
assign lfsr_data_seed[ 95: 80] = {cfg_rd_data_seed_1[10:0], cfg_rd_data_seed_1[15:11]};
assign lfsr_data_seed[111: 96] = {cfg_rd_data_seed_1[ 9:0], cfg_rd_data_seed_1[15:10]};
assign lfsr_data_seed[127:112] = {cfg_rd_data_seed_1[ 8:0], cfg_rd_data_seed_1[15: 9]};


assign lfsr_data_seed[143:128] =  cfg_rd_data_seed_1[31:16];
assign lfsr_data_seed[159:144] = {cfg_rd_data_seed_1[30:16], cfg_rd_data_seed_1[31:31]};
assign lfsr_data_seed[175:160] = {cfg_rd_data_seed_1[29:16], cfg_rd_data_seed_1[31:30]};
assign lfsr_data_seed[191:176] = {cfg_rd_data_seed_1[28:16], cfg_rd_data_seed_1[31:29]};
assign lfsr_data_seed[207:192] = {cfg_rd_data_seed_1[27:16], cfg_rd_data_seed_1[31:28]};
assign lfsr_data_seed[223:208] = {cfg_rd_data_seed_1[26:16], cfg_rd_data_seed_1[31:27]};
assign lfsr_data_seed[239:224] = {cfg_rd_data_seed_1[25:16], cfg_rd_data_seed_1[31:26]};
assign lfsr_data_seed[255:240] = {cfg_rd_data_seed_1[24:16], cfg_rd_data_seed_1[31:25]};


assign lfsr_data_seed[ 15+256:  0+256] =  cfg_rd_data_seed_2[15:0];
assign lfsr_data_seed[ 31+256: 16+256] = {cfg_rd_data_seed_2[14:0], cfg_rd_data_seed_2[15:15]};
assign lfsr_data_seed[ 47+256: 32+256] = {cfg_rd_data_seed_2[13:0], cfg_rd_data_seed_2[15:14]};
assign lfsr_data_seed[ 63+256: 48+256] = {cfg_rd_data_seed_2[12:0], cfg_rd_data_seed_2[15:13]};
assign lfsr_data_seed[ 79+256: 64+256] = {cfg_rd_data_seed_2[11:0], cfg_rd_data_seed_2[15:12]};
assign lfsr_data_seed[ 95+256: 80+256] = {cfg_rd_data_seed_2[10:0], cfg_rd_data_seed_2[15:11]};
assign lfsr_data_seed[111+256: 96+256] = {cfg_rd_data_seed_2[ 9:0], cfg_rd_data_seed_2[15:10]};
assign lfsr_data_seed[127+256:112+256] = {cfg_rd_data_seed_2[ 8:0], cfg_rd_data_seed_2[15: 9]};


assign lfsr_data_seed[143+256:128+256] =  cfg_rd_data_seed_2[31:16];
assign lfsr_data_seed[159+256:144+256] = {cfg_rd_data_seed_2[30:16], cfg_rd_data_seed_2[31:31]};
assign lfsr_data_seed[175+256:160+256] = {cfg_rd_data_seed_2[29:16], cfg_rd_data_seed_2[31:30]};
assign lfsr_data_seed[191+256:176+256] = {cfg_rd_data_seed_2[28:16], cfg_rd_data_seed_2[31:29]};
assign lfsr_data_seed[207+256:192+256] = {cfg_rd_data_seed_2[27:16], cfg_rd_data_seed_2[31:28]};
assign lfsr_data_seed[223+256:208+256] = {cfg_rd_data_seed_2[26:16], cfg_rd_data_seed_2[31:27]};
assign lfsr_data_seed[239+256:224+256] = {cfg_rd_data_seed_2[25:16], cfg_rd_data_seed_2[31:26]};
assign lfsr_data_seed[255+256:240+256] = {cfg_rd_data_seed_2[24:16], cfg_rd_data_seed_2[31:25]};

assign lfsr_data_enable = axi_rvalid_i & axi_rready_r;

// Use small LFSR width
localparam [15:0] LFSR16_POLYNOMIAL = 16'hD008; // x^16 + x^15 + x^13 + x^4 +1
genvar li;
generate
  for (li=0; li<NUM_OF_LFSR16; li++) begin : LFSR16
    lscc_lfsr #(
      .LFSR_WIDTH (16               ),
      .POLYNOMIAL (LFSR16_POLYNOMIAL),
      .LFSR_INIT  (1                )
    )
    u_wdata_gen (
      .clk_i      (aclk_i                   ),
      .rst_i      (rst_w                    ),
      .enb_i      (lfsr_data_enable         ),
      .ld_seed_i  (lfsr_data_ld_seed_r      ),
      .din_i      (lfsr_data_seed[li*16+:16]),
      .dout_o     (lfsr_out_data[li*16+:16] )
    );
  end

endgenerate

logic  compare_err_r2;
logic  compare_en_w ;

assign compare_en_w = axi_rvalid_i & axi_rready_r;
assign exp_rddata_w  = lfsr_out_data[AXI_DATA_WIDTH-1:0];       // Pseudo random data
//assign exp_rddata_w = 128'h5F5E5D5C5B5A59585756555453525150;  // Fixed data pattern

integer compi;
// Read response comparison
always_ff @(posedge aclk_i or negedge areset_n_i) begin
  if(!areset_n_i) begin
//    compare_data_r <= {NUM_OF_LFSR16{1'b0}};
	compare_data_r <= {NUM_BYTES{1'b0}};
    compare_en_r   <= 1'b0;
    compare_err_r  <= 1'b0;
    compare_err_r2 <= 1'b0;
	rd_err_o       <= 1'b0;
  end
  else begin
//    for (compi=0; compi<NUM_OF_LFSR16; compi++)
//      compare_data_r[compi] <= exp_rddata_w[compi*16+:16] == axi_rdata_i[compi*16+:16];
    for (compi=0; compi<NUM_BYTES; compi++)
	  compare_data_r[compi] <= exp_rddata_w[compi*8+:8] == axi_rdata_i[compi*8+:8];
    compare_en_r  <= compare_en_w;

    if (rd_start)
      compare_err_r  <= 1'b0;  // reset error flag on start of the test
    else if (compare_en_r)
      compare_err_r  <= compare_err_r | ~(&compare_data_r);  // hold the error signal when asserted

	rd_err_o  <= compare_en_r ? ~(&compare_data_r) : 1'b0;

    if (axi_rvalid_i & axi_rready_r) begin
      if (axi_rresp_i >= 2'b10)
        $error("%010d [AXI_TRAGEN_RD]: **Error Response Error occured! axi_rresp_i=0x%01x\n", $time, axi_rresp_i);
      //if (axi_rid_i != ) ID check is TBD.
      if (axi_rlast_i != exp_rlast_r)
        $error("%010d [AXI_TRAGEN_RD]: **Error axi_rlast_i=&d is wrong! \n", $time, axi_rlast_i);
    end
    compare_err_r2 <= compare_err_r;
    if (!compare_err_r2 & compare_err_r)
      $error("%010d [AXI_TRAGEN_RD]: **Error Compare on transaction No. %0d! \n", $time, trans_cnt_r);
  end
end // always_ff

logic [NUM_LANE-1:0]       rvl_error_lane_r   ;
logic [NUM_BYTES-1:0]      rvl_error_bit_r    ;  // NUM_BYTES == DDR_WIDTH; 1=error in the DDR bit
logic [NUM_BYTES-1:0]      rvl_compare_data_r ;
logic [AXI_DATA_WIDTH-1:0] rvl_act_rdata_r    ;
logic [AXI_DATA_WIDTH-1:0] rvl_exp_rdata_r    ;
logic                      rvl_compare_en_r   ;
logic                      rvl_rd_err_r /* synthesis syn_preserve=1 */;

// Rearrange bits per DDR data bit in 1 BL8
logic [AXI_DATA_WIDTH-1:0] rvl_act_ddr_bit_w;
logic [AXI_DATA_WIDTH-1:0] rvl_exp_ddr_bit_w;

genvar ddr_i;
integer lane;
integer ddr_bit;
generate
  // This debug feature is only available when testing the full data gearing .
  if (AXI_DATA_WIDTH == DDR_WIDTH * 8) begin : FULL_SIZE_CHECK
    for (ddr_i=0; ddr_i<NUM_BYTES; ddr_i++) begin
      assign rvl_act_ddr_bit_w[ddr_i*8+:8] = {rvl_act_rdata_r[7*NUM_BYTES+ddr_i],rvl_act_rdata_r[6*NUM_BYTES+ddr_i],rvl_act_rdata_r[5*NUM_BYTES+ddr_i],rvl_act_rdata_r[4*NUM_BYTES+ddr_i],rvl_act_rdata_r[3*NUM_BYTES+ddr_i],rvl_act_rdata_r[2*NUM_BYTES+ddr_i],rvl_act_rdata_r[1*NUM_BYTES+ddr_i],rvl_act_rdata_r[0*NUM_BYTES+ddr_i]};
      assign rvl_exp_ddr_bit_w[ddr_i*8+:8] = {rvl_exp_rdata_r[7*NUM_BYTES+ddr_i],rvl_exp_rdata_r[6*NUM_BYTES+ddr_i],rvl_exp_rdata_r[5*NUM_BYTES+ddr_i],rvl_exp_rdata_r[4*NUM_BYTES+ddr_i],rvl_exp_rdata_r[3*NUM_BYTES+ddr_i],rvl_exp_rdata_r[2*NUM_BYTES+ddr_i],rvl_exp_rdata_r[1*NUM_BYTES+ddr_i],rvl_exp_rdata_r[0*NUM_BYTES+ddr_i]};
    end

    always_ff @(posedge aclk_i) begin
      rvl_act_rdata_r   <= axi_rdata_i ;
      rvl_exp_rdata_r   <= exp_rddata_w[AXI_DATA_WIDTH-1:0];
      rvl_compare_en_r  <= compare_en_w;
      rvl_compare_data_r<= compare_data_r;
      rvl_rd_err_r      <= rd_err_o;
      if (compare_en_r) begin
        for (lane=0; lane<NUM_LANE; lane++)
          rvl_error_lane_r[lane]   <= ~(compare_data_r[7*NUM_LANE+lane] & compare_data_r[6*NUM_LANE+lane] & compare_data_r[5*NUM_LANE+lane] & compare_data_r[4*NUM_LANE+lane] & compare_data_r[3*NUM_LANE+lane] & compare_data_r[2*NUM_LANE+lane] & compare_data_r[1*NUM_LANE+lane] & compare_data_r[0*NUM_LANE+lane]);
        for (ddr_bit=0; ddr_bit<NUM_BYTES; ddr_bit++)
          rvl_error_bit_r[ddr_bit] <= rvl_act_ddr_bit_w[ddr_bit*8+:8] != rvl_exp_ddr_bit_w[ddr_bit*8+:8];  // assert on error
      end
      else begin
         rvl_error_lane_r <= {NUM_LANE{1'b0}};
         rvl_error_bit_r  <= {NUM_BYTES{1'b0}};
      end
    end
  end
endgenerate

//logic [CNTR_WIDTH-1:0] resp_cnt_p1;
//assign resp_cnt_p1 = resp_cnt_r + 1;

always_ff @(posedge aclk_i or negedge areset_n_i) begin
  if(!areset_n_i) begin
    rd_txn_done    <= 1'b0;
//    resp_cnt_r     <= {CNTR_WIDTH{1'b0}};
//    is_last_resp_r <= 1'b0;
  end
  else begin
    if (is_last_addr_r & a2d_empty & is_last)
      rd_txn_done <= 1'b1;
    else if (rd_start)
      rd_txn_done <= 1'b0;
//    if (axi_rlast_i & axi_rready_r & axi_rvalid_i)
//	  resp_cnt_r  <= resp_cnt_p1
//	else if (rd_start)
//	  resp_cnt_r  <= {CNTR_WIDTH{1'b0}};
  end
end
// FIXME: Check if pulse is better
assign rd_error        = compare_err_r;
assign num_of_rd_trans = trans_cnt_r;

// Added for debugging in reveal
// Separate state per channel
logic [1:0] rvl_currState_ar;
logic [1:0] rvl_currState_rd;
logic       rvl_rd_txn_done;
logic [7:0] rvl_num_rd_trans;
logic [TIMEOUT_WIDTH-1:0] idle_cntr;
logic       rvl_timeout;

logic       rvl_axi_arready;
logic       rvl_axi_arvalid;
logic       rvl_axi_rready ;
logic       rvl_axi_rvalid ;
logic [1:0] rvl_axi_rresp  ;
logic       rvl_axi_rlast  ;

always_ff @(posedge aclk_i or negedge areset_n_i) begin
  if(!areset_n_i) begin
    rvl_currState_ar <= 2'h0;
    rvl_currState_rd <= 2'h0;
    rvl_rd_txn_done  <= 1'b0;
    idle_cntr        <= {TIMEOUT_WIDTH{1'b0}};
    rvl_timeout      <= 1'b0;
    rvl_num_rd_trans <= 8'h0;
    rvl_axi_arready  <= 1'b0;
    rvl_axi_arvalid  <= 1'b0;
    rvl_axi_rready   <= 1'b0;
    rvl_axi_rvalid   <= 1'b0;
    rvl_axi_rresp    <= 2'b00;
    rvl_axi_rlast    <= 1'b0;
  end
  else begin

    case (currState_ar)
      AR_IDLE : rvl_currState_ar <= 2'h0;
	  AR_ADDR : rvl_currState_ar <= 2'h1;
	  AR_WAIT : rvl_currState_ar <= 2'h2;
	  default : rvl_currState_ar <= 2'h3;  // default is not expected
    endcase
	case (currState_rd)
	  RD_IDLE  : rvl_currState_rd <= 2'h0;
	  RD_SETUP : rvl_currState_rd <= 2'h1;
	  RD_DATA  : rvl_currState_rd <= 2'h2;
	  default  : rvl_currState_rd <= 2'h3;  // default is not expected
	endcase
    rvl_rd_txn_done  <= rd_txn_done;
    if (currState_rd == RD_IDLE) begin
      idle_cntr      <= {TIMEOUT_WIDTH{1'b0}};
      rvl_timeout    <= 1'b0;
    end
    else begin
      if (axi_rready_r & axi_rvalid_i)
        idle_cntr    <= {TIMEOUT_WIDTH{1'b0}};
      else if (idle_cntr < TIMEOUT_VALUE)
        idle_cntr    <= idle_cntr + 1;
      rvl_timeout    <= idle_cntr >= TIMEOUT_VALUE;
    end
    rvl_num_rd_trans <= num_of_rd_trans[7:0];
    rvl_axi_arready  <= axi_arready_i;
    rvl_axi_arvalid  <= axi_arvalid_r;
    rvl_axi_rready   <= axi_rready_r ;
    rvl_axi_rvalid   <= axi_rvalid_i ;
    rvl_axi_rresp    <= axi_rresp_i  ;
    rvl_axi_rlast    <= axi_rlast_i  ;
  end
end

assign rd_timeout_o = rvl_timeout;

endmodule
