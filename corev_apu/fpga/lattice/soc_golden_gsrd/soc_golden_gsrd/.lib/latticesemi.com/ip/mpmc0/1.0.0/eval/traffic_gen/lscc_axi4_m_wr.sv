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
// File                  : lscc_axi4_m_wr.v
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

module lscc_axi4_m_wr
#(
parameter DDR_WIDTH       = 1,
parameter AXI_DATA_WIDTH  = 1,
parameter AXI_ADDR_WIDTH  = 1,
parameter AXI_LEN_WIDTH   = 1,
parameter AXI_ID_WIDTH    = 1,
parameter AXI_STRB_WIDTH  = AXI_DATA_WIDTH/8,
parameter TIMEOUT_VALUE   = 521,
parameter TIMEOUT_WIDTH   = 10
)
(

//CLOCKS AND RESETS
 input                             aclk_i       ,
 input                             areset_n_i   ,
 output logic                      wr_timeout_o ,
//AXI INTERFACE SIGNALS
 input                             axi_awready_i,
 output logic                      axi_awvalid_o /* synthesis syn_preserve=1 */,
 output logic [AXI_ADDR_WIDTH-1:0] axi_awaddr_o ,
 output logic [2:0]                axi_awsize_o ,
 output logic [AXI_LEN_WIDTH-1:0]  axi_awlen_o  ,
 output logic [1:0]                axi_awburst_o,
 output logic [3:0]                axi_awqos_o  ,
 output logic [AXI_ID_WIDTH-1:0]   axi_awid_o   ,
 
 input                             axi_wready_i,
 output logic                      axi_wvalid_o /* synthesis syn_preserve=1 */,
 output logic [AXI_DATA_WIDTH-1:0] axi_wdata_o ,
 output logic [AXI_STRB_WIDTH-1:0] axi_wstrb_o ,  // FIXME: Need to add WSTRB support
 output logic                      axi_wlast_o /* synthesis syn_preserve=1 */,
 // FIXME: Need to add Write response channel
 output logic                      axi_bready_o, 
 input                             axi_bvalid_i,
 input       [1:0]                 axi_bresp_i , 
 input       [AXI_ID_WIDTH-1 : 0]  axi_bid_i   ,

 input [AXI_LEN_WIDTH-1:0]   cfg_awlen  ,             
 input [1:0]                 cfg_awburst,
 input [2:0]                 cfg_awsize , 
 input [AXI_ID_WIDTH-1:0]    cfg_awid   , 
 input [31:0]                cfg_wr_addr_seed,
 input [31:0]                cfg_wr_data_seed_1,    
 input [31:0]                cfg_wr_data_seed_2,    
 input [19:0]                cfg_num_of_wr_trans,   
 input                       cfg_randomize_wraddr, 
 input                       cfg_randomize_wrctrl, 
 input [5:0]                 cfg_wr_txn_delay,      
 input                       wr_start,   // 1 cycle pulse

 output logic                wr_txn_done
);
localparam [2:0] MAX_SIZE   = (AXI_STRB_WIDTH == 128) ? 3'h7 : 
                              (AXI_STRB_WIDTH == 64)  ? 3'h6 : 
                              (AXI_STRB_WIDTH == 32)  ? 3'h5 : 
                              (AXI_STRB_WIDTH == 16)  ? 3'h4 : 
                              (AXI_STRB_WIDTH == 8)   ? 3'h3 : 
                              (AXI_STRB_WIDTH == 4)   ? 3'h2 : 
                              (AXI_STRB_WIDTH == 2)   ? 3'h1 : 0;
localparam OFFSET_BIT       = MAX_SIZE + 2;

localparam NUM_OF_LFSR16     = AXI_DATA_WIDTH / 16 + ((AXI_DATA_WIDTH % 16 == 0) ? 0 : 1);
//localparam POLYNOMIAL       = 32'hb4040;

// Separate state per channel
typedef enum logic [1:0] {AW_IDLE, AW_ADDR, AW_WAIT} State_aw;
State_aw currState_aw, nextState_aw;

// To add WD_WAIT if valid de-assertion will be supported
typedef enum logic [1:0] {WD_IDLE, WD_SETUP, WD_DATA} State_wd;
State_wd currState_wd, nextState_wd;

// The BRESP FSM is for enhancement
//typedef enum logic [1:0] {BR_IDLE, BR_WAIT, BR_LAST} State_br;
//State_br currState_br, nextState_br;


logic [31:0]                  lfsr_out_awaddr;
logic [2:0]                   lfsr_out_awsize;
logic [AXI_LEN_WIDTH-1:0]     lfsr_out_awlen;
logic [AXI_ID_WIDTH-1:0]      lfsr_out_awid;

logic [AXI_ADDR_WIDTH-1:0]    mux_awaddr;
logic [2:0]                   mux_awsize;
logic [AXI_LEN_WIDTH-1:0]     mux_awlen;
logic [AXI_ID_WIDTH-1:0]      mux_awid;
logic [1:0]                   mux_awburst;

logic [511:0]  lfsr_data_seed;      
logic [511:0]  lfsr_out_data;      
logic          lfsr_addr_enable;
logic          lfsr_ctrl_enable;
logic          lfsr_data_enable;
logic          lfsr_addr_ld_seed_r;
logic          lfsr_ctrl_ld_seed_r;
logic          lfsr_data_ld_seed_r;

logic [5:0]               trans_delay_r ;      
logic [AXI_LEN_WIDTH-1:0] trans_length_r;
logic                     data_done_r   ;
logic                     trans_ready_r ;
logic [19:0]              trans_cnt_r   ;
logic                     is_last_addr_r;

logic [2:0]               mux_awsize_r  ;
logic [AXI_LEN_WIDTH:0]   mux_awlen_p1_r;
logic [16:0]              addr_inc_w    ;
logic [16:0]              addr_inc_r    ;

logic                     a2d_wr_en_nxt;
logic                     a2d_wr_en    ;
logic                     a2d_rd_en    ;
logic [AXI_LEN_WIDTH+2:0] a2d_wr_data  ;
logic                     a2d_full     ;
logic                     a2d_empty    ;
logic [AXI_LEN_WIDTH+2:0] a2d_rd_data  ;
logic                     rst_w        ;

// Replicating output Flow control signals
logic                     axi_awvalid_r /* synthesis syn_preserve=1 */;
logic                     axi_wvalid_r  /* synthesis syn_preserve=1 */;
logic                     axi_wlast_r   /* synthesis syn_preserve=1 */;
logic                     axi_awvalid_nxt;
logic                     axi_wvalid_nxt ;
logic                     axi_wlast_nxt  ;

assign rst_w = ~areset_n_i;

//////////////////////////////////////////////////////////////////////////////////////////////////////////
always_ff @(posedge aclk_i or negedge areset_n_i) begin
  if(!areset_n_i) begin
    trans_delay_r <= 1'b0;
    trans_ready_r <= 1'b0;
  end
  else begin
    if(axi_wlast_r & axi_wvalid_r & axi_wready_i) begin
      trans_delay_r <= cfg_wr_txn_delay;
    end
    else if (trans_delay_r != 0)
      trans_delay_r <= trans_delay_r - 1;
    // Signal to insert delay between transfers
    trans_ready_r <= (trans_delay_r <= 1) ? 1'b1 : 1'b0; 
    if(axi_wlast_r & axi_wvalid_r & axi_wready_i) 
      data_done_r   <= 1'b1;
    else if (axi_awvalid_r & axi_awready_i)
      data_done_r   <= 1'b0;
  end
end  // always_ff


///////////////////////   Write Address Channel Logic  ///////////////////////
//typedef enum logic [1:0] {AW_IDLE, AW_ADDR, AW_WAIT} State_aw;
//State_aw , ;

// Write Address Channel FSM: Next State
always_comb
  begin
  nextState_aw  = currState_aw;
  a2d_wr_en_nxt = 1'b0;
  case(currState_aw)
  AW_IDLE  : begin
             nextState_aw  = wr_start ? AW_ADDR : AW_IDLE;
             a2d_wr_en_nxt = wr_start;
           end
  AW_ADDR  : nextState_aw = (axi_awvalid_r & axi_awready_i) ? AW_WAIT : AW_ADDR;
  AW_WAIT  : begin 
              if (a2d_full)
                nextState_aw    = AW_WAIT;
              else if (is_last_addr_r)
                nextState_aw    = AW_IDLE;
              else begin
                if (cfg_wr_txn_delay == 0) begin
                  nextState_aw  = AW_ADDR;   // Do outstanding transactions
                  a2d_wr_en_nxt = 1'b1;
                end
                else if (data_done_r & trans_ready_r) begin
                  nextState_aw  =  AW_ADDR;
                  a2d_wr_en_nxt = 1'b1;
                end
                else 
                  nextState_aw  =  AW_WAIT;
              end
           end
  default  : nextState_aw = AW_IDLE;
  endcase
end

// Write Address Channel FSM: Current State
always_ff @(posedge aclk_i or negedge areset_n_i) begin
  if(!areset_n_i)
   currState_aw <= AW_IDLE;
  else 
   currState_aw <= nextState_aw;
end

// Write Address Channel FSM: State Outputs
// Move axi_awvalid_o to separate always_ff/always_comb block for replication
always_ff @(posedge aclk_i or negedge areset_n_i) begin
  if(!areset_n_i) begin
//    axi_awvalid_o  <= 1'b0;
    axi_awaddr_o   <= {AXI_ADDR_WIDTH{1'b0}};
    axi_awsize_o   <= 3'h0;
    axi_awlen_o    <= {AXI_LEN_WIDTH{1'b0}};
    axi_awburst_o  <= 2'h1;
    axi_awid_o     <= {AXI_ID_WIDTH{1'b0}};
    a2d_wr_en      <= 1'b0;
  end
  else begin
    a2d_wr_en      <= a2d_wr_en_nxt;
    case(currState_aw)
      AW_IDLE      : begin
        if (wr_start) begin    // The start will happen only during A2D fifo is empty
//          axi_awvalid_o  <= 1'b1;
          axi_awaddr_o   <= mux_awaddr;
          axi_awsize_o   <= mux_awsize;
          axi_awlen_o    <= mux_awlen;
          axi_awburst_o  <= mux_awburst; 
          axi_awid_o     <= mux_awid;
        end
        else begin
//          axi_awvalid_o  <= 1'b0;
          axi_awaddr_o   <= {AXI_ADDR_WIDTH{1'b0}};
          axi_awsize_o   <= 3'h0;
          axi_awlen_o    <= {AXI_LEN_WIDTH{1'b0}};
          axi_awburst_o  <= 2'h0;
          axi_awid_o     <= {AXI_ID_WIDTH{1'b0}};
        end
      end
      AW_ADDR: begin
        if(axi_awready_i) begin  
//          axi_awvalid_o  <= 1'b0;  
          axi_awaddr_o   <= axi_awaddr_o + addr_inc_r;
          // The control signals are not changed for the next burst
        end 
//        else 
//          axi_awvalid_o  <= 1'b1;
      end
//      AW_WAIT : begin
//        axi_awvalid_o  <= a2d_wr_en_nxt;
//      end
    endcase
  end
end //always_ff

// Replicating axi_awvalid_o
always_comb begin
  case(currState_aw)
    AW_IDLE : axi_awvalid_nxt <= wr_start      ;
    AW_ADDR : axi_awvalid_nxt <= ~axi_awready_i;
    AW_WAIT : axi_awvalid_nxt <= a2d_wr_en_nxt ;
    default : axi_awvalid_nxt <= axi_awvalid_r ;
  endcase
end //always_comb

always_ff @(posedge aclk_i or negedge areset_n_i) begin
  if(!areset_n_i) begin
   axi_awvalid_r <= 1'b0;
   axi_awvalid_o <= 1'b0;
  end
  else begin
   axi_awvalid_r <= axi_awvalid_nxt;
   axi_awvalid_o <= axi_awvalid_nxt;
  end
end

logic [19:0] trans_cnt_p1;

assign trans_cnt_p1 = trans_cnt_r + 1;

// Write Address Channel FSM: Current State
always_ff @(posedge aclk_i or negedge areset_n_i) begin
  if(!areset_n_i) begin
    trans_cnt_r    <= 'h0;
    is_last_addr_r <= 1'b0;
  end
  else begin
    if ((currState_aw == AW_IDLE) & wr_start) begin
      trans_cnt_r    <= 'h0;
      is_last_addr_r <= 1'b0;
    end
    else if (axi_awvalid_r & axi_awready_i) begin
      trans_cnt_r    <= trans_cnt_p1;
      is_last_addr_r <= trans_cnt_p1 == cfg_num_of_wr_trans;
    end
  end
end


assign axi_awqos_o = 4'h0;  // QOS is not supported

generate 
  // FIXME: Add address INCR feature
  if (AXI_ADDR_WIDTH <= 32) begin : LT32
    assign mux_awaddr = cfg_randomize_wraddr ? {lfsr_out_awaddr[AXI_ADDR_WIDTH-1:OFFSET_BIT], {OFFSET_BIT{1'b0}}} : cfg_wr_addr_seed[AXI_ADDR_WIDTH-1:0];
  end
  else begin : MT32
    assign mux_awaddr = cfg_randomize_wraddr ? {{(AXI_ADDR_WIDTH-32){1'b0}}, lfsr_out_awaddr[31:OFFSET_BIT],{OFFSET_BIT{1'b0}}} : {{(AXI_ADDR_WIDTH-32){1'b0}},{cfg_wr_addr_seed}};
  end
endgenerate

assign mux_awburst = cfg_awburst;  // AWBURST is not randomized

assign mux_awid    = !cfg_randomize_wrctrl ? cfg_awid   : lfsr_out_awid;
assign mux_awsize  = !cfg_randomize_wrctrl ? cfg_awsize : (lfsr_out_awsize > MAX_SIZE ? MAX_SIZE : lfsr_out_awsize);
assign mux_awlen   = !cfg_randomize_wrctrl ? cfg_awlen  : (lfsr_out_awlen <= 3 ? lfsr_out_awlen : ({lfsr_out_awlen[AXI_LEN_WIDTH-1:2],2'b00}-1)); 

// generating the address INCR

logic [AXI_LEN_WIDTH:0] mux_awlen_actual = mux_awlen + 1;

always_ff @(posedge aclk_i or negedge areset_n_i) 
 begin
  if(!areset_n_i) begin
    mux_awsize_r   <= 3'h0;
    mux_awlen_p1_r <= 'h0;
    addr_inc_r     <= 'h0;
  end
  else begin
    mux_awsize_r   <= mux_awsize;
    mux_awlen_p1_r <= mux_awlen + 1;
//  addr_inc_r     <= 0;
    case (mux_awsize_r)
      0 : addr_inc_r[AXI_LEN_WIDTH:0]    <=  mux_awlen_p1_r;
      1 : addr_inc_r[AXI_LEN_WIDTH+1:0]  <= {mux_awlen_p1_r, 1'h0};  // x2
      2 : addr_inc_r[AXI_LEN_WIDTH+2:0]  <= {mux_awlen_p1_r, 2'h0};  // x4
      3 : addr_inc_r[AXI_LEN_WIDTH+3:0]  <= {mux_awlen_p1_r, 3'h0};  // x8
      4 : addr_inc_r[AXI_LEN_WIDTH+4:0]  <= {mux_awlen_p1_r, 4'h0};  // x16
      5 : addr_inc_r[AXI_LEN_WIDTH+5:0]  <= {mux_awlen_p1_r, 5'h00}; // x32
      6 : addr_inc_r[AXI_LEN_WIDTH+6:0]  <= {mux_awlen_p1_r, 6'h00}; // x64
      7 : addr_inc_r[AXI_LEN_WIDTH+7:0]  <= {mux_awlen_p1_r, 7'h00}; // x128
    endcase
  end
end

assign a2d_wr_data = {axi_awlen_o, axi_awsize_o};
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
   lfsr_addr_ld_seed_r   <= cfg_randomize_wraddr & wr_start;
   lfsr_ctrl_ld_seed_r   <= cfg_randomize_wrctrl & wr_start;
   lfsr_data_ld_seed_r   <= wr_start;
  end
 end

assign lfsr_ctrl_enable = axi_awvalid_r & axi_awready_i; 
assign lfsr_addr_enable = axi_awvalid_r & axi_awready_i;  



//LFSRs to generate  WRITE controls
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
  lfsr_ctrl_seed[AXI_LEN_WIDTH-1:0]  = cfg_awlen ;
  lfsr_ctrl_seed[9:8]                = 2'b01     ;
  lfsr_ctrl_seed[12:10]              = cfg_awsize;
  lfsr_ctrl_seed[AXI_ID_WIDTH+12:13] = cfg_awid  ;
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

assign lfsr_out_awlen  = lfsr_ctrl_out[AXI_LEN_WIDTH-1:0];
assign lfsr_out_awsize = lfsr_ctrl_out[12:10];
assign lfsr_out_awid   = lfsr_ctrl_out[AXI_ID_WIDTH+12:13];

lscc_lfsr #(
  .LFSR_WIDTH (32          ), 
  .POLYNOMIAL (32'h80200002),// x^32 + x^22 + x^2 + 1
  .LFSR_INIT  (32'h00000100)
)
u_awaddr_gen (
  .clk_i      (aclk_i             ), 
  .rst_i      (rst_w              ), 
  .enb_i      (lfsr_addr_enable   ), 
  .ld_seed_i  (lfsr_addr_ld_seed_r), 
  .din_i      (cfg_wr_addr_seed   ),
  .dout_o     (lfsr_out_awaddr    ) 
);







///////////////////////////////////////////////////////////////////////////
///////////////////////   Write Data Channel Logic  ///////////////////////

logic   wd_setup_done_r;
//logic   last_data_r;
logic   is_last;
assign  is_last = axi_wlast_r & axi_wready_i;

//typedef enum logic [1:0] {WD_IDLE, WD_SETUP, WD_DATA} State_wd;
//State_wd currState_wd, nextState_wd;

// Write Data Channel FSM: Next State
always_comb
  begin
  nextState_wd  = currState_wd;
  case(currState_wd)
    WD_IDLE  : nextState_wd = a2d_empty ? WD_IDLE : WD_SETUP;
    WD_SETUP : nextState_wd = wd_setup_done_r ? WD_DATA : WD_SETUP;
    WD_DATA  : nextState_wd = is_last ? (a2d_empty ? WD_IDLE : WD_SETUP) : WD_DATA;
    default  : nextState_wd = WD_IDLE;
  endcase
end

// Write Data Channel FSM: Current State
always_ff @(posedge aclk_i or negedge areset_n_i) begin
  if(!areset_n_i)
   currState_wd <= WD_IDLE;
  else 
   currState_wd <= nextState_wd;
end



// Write Data Channel FSM: State Outputs
// Removing axi_wvalid_o and axi_wlast_o for replication
always_ff @(posedge aclk_i or negedge areset_n_i) begin
  if(!areset_n_i) begin
//    axi_wvalid_o    <= 1'b0;
//    axi_wlast_o     <= 1'b0;
    wd_setup_done_r <= 1'b0;
    trans_length_r  <= 1'b0;
  end
  else begin
    wd_setup_done_r <= 1'b0; // This is to stay in WD_SETUP for 2 cycles
//    axi_wlast_o     <= 1'b0;
    case(currState_wd)
      WD_IDLE  : begin
//                  axi_wvalid_o     <= 1'b0;
                  trans_length_r   <= 1'b0;
                end
      WD_SETUP : begin
                  wd_setup_done_r  <= 1'b1;
                  if (wd_setup_done_r) 
                    trans_length_r <= a2d_rd_data[AXI_LEN_WIDTH+2:3];
//                  axi_wvalid_o     <= wd_setup_done_r;
//                  axi_wlast_o      <= wd_setup_done_r & (a2d_rd_data[AXI_LEN_WIDTH+2:3] == {AXI_LEN_WIDTH{1'b0}});
                end
      WD_DATA  : begin
//                  axi_wvalid_o     <= (axi_wlast_o & axi_wready_i) ? 1'b0 : 1'b1;
//                  axi_wlast_o      <=  axi_wready_i ? (~axi_wlast_o & (trans_length_r == 1)) : axi_wlast_o;
                  if (axi_wready_i & (trans_length_r != 0))
                    trans_length_r <= trans_length_r - 1;
                end
    endcase
  
  end 
end // always_ff

// Generating axi_wvalid_nxt for replication
always_comb begin
  case(currState_wd)
    WD_SETUP : axi_wvalid_nxt <= wd_setup_done_r ? wd_setup_done_r : axi_wvalid_r;
    WD_DATA  : axi_wvalid_nxt <= (axi_wlast_r & axi_wready_i) ? 1'b0 : 1'b1;
    default  : axi_wvalid_nxt <= 1'b0;
  endcase
end // always_comb

// Generating axi_wlast_nxt for replication
always_comb begin
  case(currState_wd)
    WD_SETUP : axi_wlast_nxt <= wd_setup_done_r ? (wd_setup_done_r & (a2d_rd_data[AXI_LEN_WIDTH+2:3] == {AXI_LEN_WIDTH{1'b0}})) : axi_wlast_r;
    WD_DATA  : axi_wlast_nxt <= axi_wready_i ? (~axi_wlast_r & (trans_length_r == 1)) : axi_wlast_r;
    default  : axi_wlast_nxt <= 1'b0;
  endcase
end // always_comb

// Replicating axi_wvalid_o and axi_wlast_o
always_ff @(posedge aclk_i or negedge areset_n_i) begin
  if(!areset_n_i) begin
    axi_wvalid_o <= 1'b0;
    axi_wvalid_r <= 1'b0;
    axi_wlast_o  <= 1'b0;
    axi_wlast_r  <= 1'b0;
  end
  else begin
    axi_wvalid_o <= axi_wvalid_nxt;
    axi_wvalid_r <= axi_wvalid_nxt;
    axi_wlast_o  <= axi_wlast_nxt ;
    axi_wlast_r  <= axi_wlast_nxt ;
  end 
end // always_ff



always_comb begin
    case(currState_wd)
      WD_IDLE  : a2d_rd_en = ~a2d_empty;
      WD_SETUP : a2d_rd_en = 1'b0;
      WD_DATA  : a2d_rd_en = is_last ? ~a2d_empty : 1'b0;
    endcase
end


logic [10:0]  dbg_num_lfsrs;
assign dbg_num_lfsrs = NUM_OF_LFSR16;

assign lfsr_data_seed[ 15:  0] =  cfg_wr_data_seed_1[15:0];
assign lfsr_data_seed[ 31: 16] = {cfg_wr_data_seed_1[14:0], cfg_wr_data_seed_1[15:15]};
assign lfsr_data_seed[ 47: 32] = {cfg_wr_data_seed_1[13:0], cfg_wr_data_seed_1[15:14]};
assign lfsr_data_seed[ 63: 48] = {cfg_wr_data_seed_1[12:0], cfg_wr_data_seed_1[15:13]};
assign lfsr_data_seed[ 79: 64] = {cfg_wr_data_seed_1[11:0], cfg_wr_data_seed_1[15:12]};
assign lfsr_data_seed[ 95: 80] = {cfg_wr_data_seed_1[10:0], cfg_wr_data_seed_1[15:11]};
assign lfsr_data_seed[111: 96] = {cfg_wr_data_seed_1[ 9:0], cfg_wr_data_seed_1[15:10]};
assign lfsr_data_seed[127:112] = {cfg_wr_data_seed_1[ 8:0], cfg_wr_data_seed_1[15: 9]};


assign lfsr_data_seed[143:128] =  cfg_wr_data_seed_1[31:16];
assign lfsr_data_seed[159:144] = {cfg_wr_data_seed_1[30:16], cfg_wr_data_seed_1[31:31]};
assign lfsr_data_seed[175:160] = {cfg_wr_data_seed_1[29:16], cfg_wr_data_seed_1[31:30]};
assign lfsr_data_seed[191:176] = {cfg_wr_data_seed_1[28:16], cfg_wr_data_seed_1[31:29]};
assign lfsr_data_seed[207:192] = {cfg_wr_data_seed_1[27:16], cfg_wr_data_seed_1[31:28]};
assign lfsr_data_seed[223:208] = {cfg_wr_data_seed_1[26:16], cfg_wr_data_seed_1[31:27]};
assign lfsr_data_seed[239:224] = {cfg_wr_data_seed_1[25:16], cfg_wr_data_seed_1[31:26]};
assign lfsr_data_seed[255:240] = {cfg_wr_data_seed_1[24:16], cfg_wr_data_seed_1[31:25]};


assign lfsr_data_seed[ 15+256:  0+256] =  cfg_wr_data_seed_2[15:0];
assign lfsr_data_seed[ 31+256: 16+256] = {cfg_wr_data_seed_2[14:0], cfg_wr_data_seed_2[15:15]};
assign lfsr_data_seed[ 47+256: 32+256] = {cfg_wr_data_seed_2[13:0], cfg_wr_data_seed_2[15:14]};
assign lfsr_data_seed[ 63+256: 48+256] = {cfg_wr_data_seed_2[12:0], cfg_wr_data_seed_2[15:13]};
assign lfsr_data_seed[ 79+256: 64+256] = {cfg_wr_data_seed_2[11:0], cfg_wr_data_seed_2[15:12]};
assign lfsr_data_seed[ 95+256: 80+256] = {cfg_wr_data_seed_2[10:0], cfg_wr_data_seed_2[15:11]};
assign lfsr_data_seed[111+256: 96+256] = {cfg_wr_data_seed_2[ 9:0], cfg_wr_data_seed_2[15:10]};
assign lfsr_data_seed[127+256:112+256] = {cfg_wr_data_seed_2[ 8:0], cfg_wr_data_seed_2[15: 9]};


assign lfsr_data_seed[143+256:128+256] =  cfg_wr_data_seed_2[31:16];
assign lfsr_data_seed[159+256:144+256] = {cfg_wr_data_seed_2[30:16], cfg_wr_data_seed_2[31:31]};
assign lfsr_data_seed[175+256:160+256] = {cfg_wr_data_seed_2[29:16], cfg_wr_data_seed_2[31:30]};
assign lfsr_data_seed[191+256:176+256] = {cfg_wr_data_seed_2[28:16], cfg_wr_data_seed_2[31:29]};
assign lfsr_data_seed[207+256:192+256] = {cfg_wr_data_seed_2[27:16], cfg_wr_data_seed_2[31:28]};
assign lfsr_data_seed[223+256:208+256] = {cfg_wr_data_seed_2[26:16], cfg_wr_data_seed_2[31:27]};
assign lfsr_data_seed[239+256:224+256] = {cfg_wr_data_seed_2[25:16], cfg_wr_data_seed_2[31:26]};
assign lfsr_data_seed[255+256:240+256] = {cfg_wr_data_seed_2[24:16], cfg_wr_data_seed_2[31:25]};

assign lfsr_data_enable = axi_wvalid_r & axi_wready_i;

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

always_ff @(posedge aclk_i or negedge areset_n_i) begin
  if(!areset_n_i) 
    wr_txn_done <= 1'b0;
  else
    if (is_last_addr_r & a2d_empty & is_last)
      wr_txn_done <= 1'b1;
    else if (wr_start)
      wr_txn_done <= 1'b0;
end

assign axi_wdata_o = lfsr_out_data[AXI_DATA_WIDTH-1:0];       // Pseudo random data
//assign axi_wdata_o = 128'h5F5E5D5C5B5A59585756555453525150; // Fixed data pattern
assign axi_wstrb_o = {AXI_STRB_WIDTH{1'b1}};  // FIXME: Need to support patial access later

assign axi_bready_o = 1'b1; // Just accept the write response for this version

logic [TIMEOUT_WIDTH-1:0] idle_cntr;
logic       rvl_axi_awready;
logic       rvl_axi_awvalid;
logic       rvl_axi_wready ;
logic       rvl_axi_wvalid ;
logic       rvl_axi_wlast  ;
logic       rvl_axi_bready ; 
logic       rvl_axi_bvalid ;
logic [1:0] rvl_axi_bresp  ; 


always_ff @(posedge aclk_i or negedge areset_n_i) begin
  if(!areset_n_i) begin
    idle_cntr        <= {TIMEOUT_WIDTH{1'b0}};
    wr_timeout_o     <= 1'b0;
    rvl_axi_awready  <= 1'b0;
	rvl_axi_awvalid  <= 1'b0;
    rvl_axi_wready   <= 1'b0;
    rvl_axi_wvalid   <= 1'b0;
    rvl_axi_wlast    <= 1'b0;
    rvl_axi_bready   <= 1'b0; 
    rvl_axi_bvalid   <= 1'b0;
    rvl_axi_bresp    <= 2'h0; 
  end
  else begin
    if (currState_wd == WD_IDLE) begin
      idle_cntr      <= {TIMEOUT_WIDTH{1'b0}};
      wr_timeout_o   <= 1'b0;
    end
    else begin
      if (axi_bready_o & axi_bvalid_i)
        idle_cntr    <= {TIMEOUT_WIDTH{1'b0}};   
      else if (idle_cntr < TIMEOUT_VALUE)
        idle_cntr    <= idle_cntr + 1;
      wr_timeout_o   <= idle_cntr >= TIMEOUT_VALUE;
    end
    rvl_axi_awready  <= axi_awready_i;
	rvl_axi_awvalid  <= axi_awvalid_r;
    rvl_axi_wready   <= axi_wready_i ;
    rvl_axi_wvalid   <= axi_wvalid_r ;
    rvl_axi_wlast    <= axi_wlast_r  ;
    rvl_axi_bready   <= axi_bready_o ; 
    rvl_axi_bvalid   <= axi_bvalid_i ;
    rvl_axi_bresp    <= axi_bresp_i  ; 
  end
end

endmodule
