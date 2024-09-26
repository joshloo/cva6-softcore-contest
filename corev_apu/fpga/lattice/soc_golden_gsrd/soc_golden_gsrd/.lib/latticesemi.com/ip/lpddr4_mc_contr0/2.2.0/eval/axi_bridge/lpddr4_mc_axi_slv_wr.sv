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
// File                  : lpddr4_mc_axi_slv_wr.v
// Title                 :
// Dependencies          :
// Description           :
// =============================================================================

module lpddr4_mc_axi_slv_wr
#(
parameter DDR_WIDTH           = 0,
parameter AXI_ID_WIDTH        = 0,
parameter ORDER_ID_WIDTH      = 0,
parameter AXI_ADDR_WIDTH      = 0,
parameter AXI_DATA_WIDTH      = 0,
parameter AXI_CTRL_WIDTH      = 0,                 
parameter AXI_LEN_WIDTH       = 0,
parameter AXI_STRB_WIDTH      = 0,
parameter AXI_QOS_WIDTH       = 0,
parameter BL_DATA_WIDTH       = 0, 
parameter SCH_NUM_WR_SUPPORT  = 0, 
parameter BL_BYTE_EN_WIDTH    = 0,
parameter DATA_CLK_EN         = 0,
parameter CTRL_FIFO_DEPTH     = 4
)
(
input                          hclk,
input                          sclk,
input                          hrst_n,
input                          srst_n,
////------------WRITE ADDRESS BUS --------------------
input                          axi_awvalid_i,
input [AXI_LEN_WIDTH -1 : 0]   axi_awlen_i,
input [1:0]                    axi_awburst_i,
input [AXI_ADDR_WIDTH -1 : 0]  axi_awaddr_i,
input [2:0]                    axi_awsize_i, 
output   logic                 axi_awready_o/* synthesis syn_preserve=1 */,
input [AXI_QOS_WIDTH -1  : 0]  axi_awqos_i,
input [AXI_ID_WIDTH -1:0]      axi_awid_i,

//------------WRITE DATA BUS --------------------

input                          axi_wvalid_i,
output logic                   axi_wready_o/* synthesis syn_preserve=1 */,
input [AXI_DATA_WIDTH -1:0]    axi_wdata_i,
input [AXI_STRB_WIDTH -1:0]    axi_wstrb_i,      
input                          axi_wlast_i,

output logic                    axi_bvalid_o/* synthesis syn_preserve=1 */,
output logic [1:0]              axi_bresp_o,
output logic [AXI_ID_WIDTH-1:0] axi_bid_o,
input                           axi_bready_i,

//----To Scheduler --------------------------------

input                                 wr_req_ready,
output logic                          wr_req_valid,
output logic  [AXI_CTRL_WIDTH-1:0]    wr_req_ctrl,
output logic  [AXI_ADDR_WIDTH-1:0]    wr_addr,
output logic  [BL_DATA_WIDTH-1 :0]    wr_data,
output logic                          wr_valid,
input logic                           wr_ready,
output logic                          wr_data_last,  
output logic  [BL_BYTE_EN_WIDTH-1 :0] wr_byte_en,
output logic                          wr_be_hole,
input                                 wr_rsp_valid,
input         [AXI_ID_WIDTH - 1 : 0]  wr_rsp_id
);
localparam OUTSTANDING_WR      = CTRL_FIFO_DEPTH + SCH_NUM_WR_SUPPORT;
localparam OUTSTANDING_WR_SUB1 = OUTSTANDING_WR - 1;
localparam DATA_RATIO =  BL_DATA_WIDTH/AXI_DATA_WIDTH;
localparam FULL_BYTES = BL_BYTE_EN_WIDTH; 
localparam BASE_ADDR  = BL_DATA_WIDTH == 512 ? 5 : BL_DATA_WIDTH == 256 ? 4 : 3; 
localparam ADDR_LOW_WIDTH = 8;
 
logic                                     wr_ctrl_fifo_wr;
logic                                     wr_ctrl_fifo_rd;
logic                                     wr_ctrl_fifo_rd_d;
logic [AXI_ADDR_WIDTH+AXI_CTRL_WIDTH : 0] wr_ctrl_fifo_wrdata;
logic [AXI_ADDR_WIDTH+AXI_CTRL_WIDTH : 0] wr_ctrl_fifo_rddata;
logic [AXI_ADDR_WIDTH+AXI_CTRL_WIDTH : 0] wr_ctrl_fifo_rddata_nxt;
logic                                     wr_ctrl_fifo_empty;
logic                                     wr_ctrl_fifo_full;
logic                                     wr_ctrl_fifo_almost_full;

logic                          wr_data_fifo_wr;
logic                          wr_data_fifo_rd;
logic                          wr_data_fifo_rd_d;
logic [BL_DATA_WIDTH -1 : 0]   wr_data_fifo_wrdata;
logic [BL_DATA_WIDTH -1 : 0]   wr_data_fifo_rddata;
logic [BL_DATA_WIDTH -1 : 0]   wr_data_fifo_rddata_nxt;
logic                          wr_data_fifo_empty;
logic                          wr_data_fifo_full;
logic                          wr_data_fifo_almost_full;
logic [BL_BYTE_EN_WIDTH +2:0]  wr_strb_fifo_wrdata;
logic [BL_BYTE_EN_WIDTH +2:0]  wr_strb_fifo_rddata;
logic [BL_BYTE_EN_WIDTH +2:0]  wr_strb_fifo_rddata_nxt;
logic [ORDER_ID_WIDTH - 1 : 0] int_awid;
logic                          rsp_fifo_wr;
logic                          rsp_fifo_rd;
logic                          rsp_fifo_full;
logic                          rsp_fifo_empty;
logic                          rsp_fifo_rd_d;
logic [AXI_ID_WIDTH -1:0]      rsp_fifo_wrdata;
logic [AXI_ID_WIDTH -1:0]      rsp_fifo_rddata;
// For 8 outstanding writes
logic [2:0]                    axi_wr_outstanding;
logic [3:0]                    last_cnt_r;
logic [2:0]                    resp_cnt;
logic [3:0]                    last_cnt_nxt;
logic [3:0]                    addr_outs_r;
logic [3:0]                    addr_outs_nxt;
logic                          last_cnt_r_neq0;
logic                          addr_outs_eq0_r  /* synthesis syn_preserve=1 */;
logic                          addr_outs_neq0_r /* synthesis syn_preserve=1 */;
logic                          addr_outs_eq1_r;


logic wr_ctrl_fifo_wr_latch;
logic [ADDR_LOW_WIDTH -1 : 0]  axi_awaddr_low;
logic [ADDR_LOW_WIDTH -1 : 0]  start_addr;
logic [ADDR_LOW_WIDTH -1 : 0]  axi_awaddr_low_r;
logic [7: 0]  addr_inc;
logic [7: 0]  total_bytes;
logic [7: 0]  total_bytes_d;
logic sig_data_fifo_wr;
logic sig_data_fifo_wr_d;

logic [BL_DATA_WIDTH-1 :0]   axi_wdata;
logic [BL_DATA_WIDTH-1 :0]   sig_axi_wdata;
logic [BL_DATA_WIDTH-1 :0]   sig_axi_wdata_d;
logic [BL_BYTE_EN_WIDTH-1:0] axi_wstrb;
logic [BL_BYTE_EN_WIDTH-1:0] sig_axi_wstrb;
logic [BL_BYTE_EN_WIDTH-1:0] sig_axi_wstrb_d;
logic [AXI_LEN_WIDTH:0]      length   ;
logic [1:0]                  bresp    ;
logic                        wr_data_err;
logic                        int_fifo_wr;
logic                        int_fifo_wr_d;
logic                        int_fifo_rd;
logic                        int_fifo_rd_d;
logic                        int_fifo_empty_rd;
logic                        int_fifo_empty_rd_d;
logic                        int_fifo_full;
logic                        int_fifo_empty;
logic [ADDR_LOW_WIDTH+3-1:0] int_fifo_wrdata;
logic [ADDR_LOW_WIDTH+3-1:0] int_fifo_wrdata_d;
logic [ADDR_LOW_WIDTH+3-1:0] int_fifo_rddata;

logic                        axi_awready_r/* synthesis syn_preserve=1 */;
logic                        axi_wready_r /* synthesis syn_preserve=1 */;
logic                        axi_bvalid_r /* synthesis syn_preserve=1 */;
logic                        axi_awready_nxt;
logic                        axi_wready_nxt;
logic                        axi_bvalid_nxt;
logic                        brespfifo_valid;
logic                        wr_req_valid_rep;
logic                        wr_data_last_rep;  

always_ff @(posedge hclk or negedge hrst_n)   //INTERNAL ID assigned with every transaction to handle out of order requests.
  if(!hrst_n)
    int_awid <= 0;
  else if(axi_awvalid_i & axi_awready_o)
    int_awid <= int_awid + 1'h1;

assign length          = axi_awlen_i + 1;
assign last_cnt_r_neq0 = last_cnt_r != 0;

assign wr_ctrl_fifo_wrdata = {axi_awaddr_i,axi_awid_i,int_awid,axi_awsize_i,length,(axi_awvalid_i & axi_awready_r)};
assign wr_ctrl_fifo_wr     = axi_awvalid_i & axi_awready_r;
//generate
//if(NARROW_WIDTH)
always_ff @(posedge hclk or negedge hrst_n) begin
   if(!hrst_n) begin
     wr_data_fifo_wr <= 0;
  end else begin
     wr_data_fifo_wr <= axi_wvalid_i & axi_wready_r & sig_data_fifo_wr;
   end
end
//else
//assign wr_data_fifo_wr     = axi_wvalid_i & axi_wready_r;
//endgenerate

// Replicating axi_awready_o
//always_ff @(posedge hclk or negedge hrst_n)
//  if(!hrst_n)
//    axi_awready_o   <= 1'b1; 
//  else if(wr_ctrl_fifo_full | (axi_awvalid_i & axi_awready_o))
//    axi_awready_o   <= 1'b0;
//  else
//    axi_awready_o <= axi_wr_outstanding < OUTSTANDING_WR_SUB1;  
always_ff @(posedge hclk or negedge hrst_n) begin
  if(!hrst_n) begin
    axi_awready_o <= 1'b1; 
    axi_awready_r <= 1'b1; 
  end
  else begin
    axi_awready_o <= axi_awready_nxt;  
    axi_awready_r <= axi_awready_nxt; 
  end
end // always_ff

// Generating axi_awready_nxt for replication
always_comb begin
  if(wr_ctrl_fifo_full | (axi_awvalid_i & axi_awready_r))
    axi_awready_nxt  = 1'b0;
  else
    axi_awready_nxt  = axi_wr_outstanding < OUTSTANDING_WR_SUB1;  
end //always_comb



logic wr_data_fifo_full_nxt;
//assign wr_data_fifo_full_nxt = wr_data_fifo_full | (wr_data_fifo_almost_full & axi_wvalid_i & axi_wready_r);
assign wr_data_fifo_full_nxt = wr_data_fifo_full | (wr_data_fifo_almost_full);

// Replicating axi_wready_o
//always_ff @(posedge hclk or negedge hrst_n)
//  if(!hrst_n)
//    axi_wready_o   <= 1'b1; 
//  // Avoiding corner case: data complete before address
//  else if (wr_data_fifo_full_nxt)
//    axi_wready_o   <= 1'b0;
//  else if ((wr_ctrl_fifo_full) |    // Stop receiving data when wr_ctrl_fifo is full or will be full
//           (wr_ctrl_fifo_almost_full & axi_awvalid_i & axi_awready_o) |
//           (last_cnt_nxt == OUTSTANDING_WR_SUB1) | (axi_wr_outstanding == OUTSTANDING_WR_SUB1)) 
//    axi_wready_o   <= (addr_outs_nxt != 4'h0);
//  else
//    axi_wready_o   <= 1'b1;
always_ff @(posedge hclk or negedge hrst_n) begin
  if(!hrst_n) begin
    axi_wready_o   <= 1'b1; 
    axi_wready_r   <= 1'b1; 
  end
  else begin
    axi_wready_o   <= axi_wready_nxt;
    axi_wready_r   <= axi_wready_nxt; 
  end
end // always_ff

// Generating axi_wready_nxt for replication
always_comb begin
  if (wr_data_fifo_full_nxt)
    axi_wready_nxt   = 1'b0;
  else
    axi_wready_nxt   = (addr_outs_nxt != 4'h0);
end // always_comb

//generate
//if(NARROW_WIDTH)
//begin
always_ff @(posedge hclk or negedge hrst_n) begin
  if(!hrst_n) begin
   wr_data_fifo_wrdata <= 0;
   wr_strb_fifo_wrdata <= 0;
  end else begin
   wr_data_fifo_wrdata  <= sig_axi_wdata;
   wr_strb_fifo_wrdata  <= {sig_axi_wstrb,1'b0,axi_wlast_i,{axi_wvalid_i & axi_wready_r}};
  end
end

//end
//else
//begin
//assign wr_data_fifo_wrdata  = axi_wdata_i;
//assign wr_strb_fifo_wrdata  = {axi_wstrb_i,1'b0,axi_wlast_i,{axi_wvalid_i & axi_wready_r}};
//end
//endgenerate
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//generate
//if(NARROW_WIDTH)
//begin
logic int_fifo_empty_d;
logic int_fifo_dummy_rd;
logic int_fifo_dummy_rd_d;
logic [2:0] awsize_d;
logic [2:0] sig_awsize;
logic [ADDR_LOW_WIDTH-1:0] start_addr_d;

lpddr4_mc_sync_fifo
#(
.WIDTH      (ADDR_LOW_WIDTH + 3), // + size
.DEPTH      (OUTSTANDING_WR),
.FWFT       (1)
)
 u_int_fifo
       (
        .clk_i(hclk), 
        .rst_i(!hrst_n), 
        .wr_en_i(int_fifo_wr), 
        .rd_en_i(int_fifo_rd | int_fifo_empty_rd_d), 
        .wr_data_i(int_fifo_wrdata), 
        .full_o(int_fifo_full), 
        .almost_full_o(),
        .empty_o(int_fifo_empty), 
        .rd_data_nxt(),
        .rd_data_o(int_fifo_rddata)
      ) ;

//assign int_fifo_wr = axi_awvalid_i & axi_awready_o & (addr_outs_r != 0 & (!(addr_outs_r == 1 & axi_wlast_i & axi_wready_r)));
assign int_fifo_wr = axi_awvalid_i & axi_awready_o & (addr_outs_neq0_r & (!(addr_outs_eq1_r & axi_wlast_i & axi_wready_r)));
assign int_fifo_wrdata = {axi_awaddr_i[ADDR_LOW_WIDTH-1:0],axi_awsize_i};
assign int_fifo_rd = (axi_wvalid_i & axi_wready_r & axi_wlast_i & !int_fifo_empty);
//assign int_fifo_dummy_rd = (addr_outs_r == 1 & axi_wlast_i & axi_wready_r & axi_awvalid_i & axi_awready_o);
assign int_fifo_dummy_rd = (addr_outs_eq1_r & axi_wlast_i & axi_wready_r & axi_awvalid_i & axi_awready_o);

always_ff @(posedge hclk or negedge hrst_n)
  if(!hrst_n) begin
     int_fifo_empty_d <= 0;
     int_fifo_rd_d <= 0;
     int_fifo_dummy_rd_d <= 0;
     int_fifo_empty_rd_d <= 0;
     int_fifo_wrdata_d <= 0;
     int_fifo_wr_d <= 0;
  end else begin
     int_fifo_empty_d <= int_fifo_empty;
     int_fifo_rd_d <= int_fifo_rd;
     int_fifo_dummy_rd_d <= int_fifo_dummy_rd;
     int_fifo_empty_rd_d <= int_fifo_empty_rd;
     int_fifo_wr_d <= int_fifo_wr;
     int_fifo_wrdata_d <= int_fifo_wrdata;
  end
assign int_fifo_empty_rd = int_fifo_wr_d & int_fifo_empty & axi_wvalid_i & axi_wready_r & axi_wlast_i ;

always_ff @(posedge hclk or negedge hrst_n)
  if(!hrst_n) begin
     start_addr_d <= 0;
     awsize_d <= 0;
  end else if(int_fifo_empty_rd & axi_wvalid_i & axi_wready_r & axi_wlast_i) begin
     start_addr_d <= int_fifo_wrdata_d[ADDR_LOW_WIDTH+3-1:3] ;
     awsize_d <= int_fifo_wrdata_d[2:0];
  end else if(int_fifo_rd) begin
     start_addr_d <= int_fifo_rddata[ADDR_LOW_WIDTH+3-1:3] ;
     awsize_d <= int_fifo_rddata[2:0];
  end else if(int_fifo_dummy_rd) begin
     start_addr_d <= axi_awaddr_i[ADDR_LOW_WIDTH-1:0];
     awsize_d <= axi_awsize_i;
  end else begin
     start_addr_d <= start_addr;
     awsize_d <= sig_awsize;
  end

logic addr_valid;

//assign addr_valid = (axi_awvalid_i & axi_awready_r & addr_outs_r  == 0) | (int_fifo_rd_d | int_fifo_dummy_rd_d);
assign addr_valid = (axi_awvalid_i & axi_awready_r & addr_outs_eq0_r) | (int_fifo_rd_d | int_fifo_dummy_rd_d | int_fifo_empty_rd_d);

always_ff @(posedge hclk or negedge hrst_n)
  if(!hrst_n)
     axi_awaddr_low_r      <= 0; 
  else if(addr_valid & axi_wvalid_i & axi_wready_r)
     axi_awaddr_low_r      <= start_addr + addr_inc; 
  else if(addr_valid)
     axi_awaddr_low_r      <= start_addr; 
  else if(axi_wvalid_i & axi_wready_r)
     axi_awaddr_low_r      <=  axi_awaddr_low_r + addr_inc;

assign axi_awaddr_low = (addr_valid) ? start_addr : axi_awaddr_low_r;

always_ff @(posedge hclk or negedge hrst_n)
  if(!hrst_n)
     sig_axi_wdata_d         <= 0; 
//  else if(sig_data_fifo_wr)
//     sig_axi_wdata_d         <= 0; 
  else if(axi_wvalid_i & axi_wready_r)
     sig_axi_wdata_d         <= sig_axi_wdata;

always_ff @(posedge hclk or negedge hrst_n)
  if(!hrst_n)
     sig_axi_wstrb_d         <= 0; 
  //else if((axi_wvalid_i & axi_wready_r & axi_wlast_i) | sig_data_fifo_wr)
  else if(sig_data_fifo_wr)
     sig_axi_wstrb_d         <= 0; 
  else if(axi_wvalid_i & axi_wready_r)
     sig_axi_wstrb_d         <= sig_axi_wstrb; 

//assign addr_inc =   (addr_outs_r == 0 & axi_awvalid_i & axi_awready_r) ? 1 << axi_awsize_i : (int_fifo_rd_d) ?  1<< int_fifo_rddata[2:0] : addr_inc_d;
//assign start_addr = (addr_outs_r == 0 & axi_awvalid_i & axi_awready_r) ? axi_awaddr_i : (int_fifo_rd_d) ? int_fifo_rddata[AXI_ADDR_WIDTH+3-1:3]  : start_addr_d;
//assign addr_inc   =   (addr_outs_eq0_r & axi_awvalid_i & axi_awready_r) ? 1 << axi_awsize_i : (int_fifo_rd_d) ?  1<< int_fifo_rddata[2:0] : addr_inc_d;
//assign start_addr = (addr_outs_eq0_r & axi_awvalid_i & axi_awready_r) ? axi_awaddr_i[ADDR_LOW_WIDTH-1:0] : (int_fifo_rd_d) ? int_fifo_rddata[ADDR_LOW_WIDTH+3-1:3]  : start_addr_d;

assign sig_awsize    =   (addr_outs_eq0_r & axi_awvalid_i & axi_awready_r) ? axi_awsize_i :  awsize_d;
assign start_addr = (addr_outs_eq0_r & axi_awvalid_i & axi_awready_r) ? axi_awaddr_i[ADDR_LOW_WIDTH-1:0] :  start_addr_d;
assign addr_inc = 1 << sig_awsize;


always_comb 
begin
for (int i = 0 ; i < DATA_RATIO; i++)
axi_wdata[AXI_DATA_WIDTH * i +: AXI_DATA_WIDTH] = axi_wdata_i;
end


if(DATA_RATIO == 1)
assign axi_wstrb  =  axi_wstrb_i; 
if(DATA_RATIO == 2)
begin
assign axi_wstrb  =  axi_wstrb_i << AXI_STRB_WIDTH * axi_awaddr_low[BASE_ADDR];
end
if(DATA_RATIO == 4)
begin
assign axi_wstrb  =  axi_wstrb_i << AXI_STRB_WIDTH * axi_awaddr_low[BASE_ADDR : BASE_ADDR-1];
end
if(DATA_RATIO == 8)
begin
assign axi_wstrb  =  axi_wstrb_i << AXI_STRB_WIDTH * axi_awaddr_low[BASE_ADDR : BASE_ADDR-2];
end
if(DATA_RATIO == 16)
begin
assign axi_wstrb  =  axi_wstrb_i << AXI_STRB_WIDTH * axi_awaddr_low[BASE_ADDR : BASE_ADDR-3];
end

logic [7:0] total_bytes_nxt;
logic total_bytes_full;

always_comb  begin
     total_bytes = total_bytes_d; 
  if(addr_valid & axi_wvalid_i & axi_wready_r)
     total_bytes = start_addr[BASE_ADDR:0] + addr_inc; 
  else if(addr_valid)
     total_bytes = start_addr[BASE_ADDR:0]; 
   else if(axi_wvalid_i & axi_wready_r)
     total_bytes =  total_bytes_d + addr_inc;
 end


//assign sig_data_fifo_wr = (total_bytes == FULL_BYTES & axi_wvalid_i & axi_wready_o) |  (((axi_wvalid_i & axi_wlast_i & axi_wready_o) | ( axi_wstrb[BL_BYTE_EN_WIDTH-1]))  & axi_wvalid_i & axi_wready_o);
assign sig_data_fifo_wr = ((total_bytes == FULL_BYTES |  axi_wlast_i  |  axi_wstrb[BL_BYTE_EN_WIDTH-1])  & axi_wvalid_i & axi_wready_o);

always_ff @(posedge hclk or negedge hrst_n)
  if(!hrst_n)  begin
    total_bytes_d         <= 0; 
    total_bytes_full      <= 1'b0;
  end
  else  begin
    total_bytes_d         <= (total_bytes_nxt == FULL_BYTES) ? 0 : total_bytes_nxt; 
    total_bytes_full      <= (total_bytes_nxt == FULL_BYTES);
  end

assign total_bytes_nxt = (addr_valid | (axi_awvalid_i & axi_awready_r) | ( axi_wvalid_i & axi_wready_r)) ? total_bytes : total_bytes_d;

always_ff @(posedge hclk or negedge hrst_n)
  if(!hrst_n)
     sig_data_fifo_wr_d         <= 0; 
  else 
     sig_data_fifo_wr_d         <= sig_data_fifo_wr; 


assign sig_axi_wstrb = (sig_data_fifo_wr_d) ? axi_wstrb :  sig_axi_wstrb_d | axi_wstrb;
assign sig_axi_wdata =  get_data(axi_wdata,axi_wstrb);

function [BL_DATA_WIDTH -1:0] get_data;
input [BL_DATA_WIDTH-1:0] axi_wdata;
input [BL_BYTE_EN_WIDTH -1:0] axi_wstrb;
begin
get_data = sig_axi_wdata_d;
for (int i = 0 ; i< BL_BYTE_EN_WIDTH ; i++)
if(axi_wstrb[i]) get_data[i*8 +: 8] = axi_wdata[i*8 +:8] ;
end
endfunction


assign rsp_fifo_wr      = wr_rsp_valid;
assign rsp_fifo_wrdata  = wr_rsp_id;

logic rsp_fifo_empty_r;
logic wr_data_done;

assign  wr_data_done = axi_wvalid_i & axi_wready_r & axi_wlast_i;

always_comb begin
  if (wr_data_done & !(rsp_fifo_rd))  // no chance of overflow due to control on outstanding writes
    last_cnt_nxt = last_cnt_r + 'h1;
  else if (!wr_data_done & (rsp_fifo_rd) & last_cnt_r_neq0)
    last_cnt_nxt = last_cnt_r - 'h1;
  else
    last_cnt_nxt = last_cnt_r;
end

always_comb begin
  // no chance of overflow due to control on outstanding writes
  if ((axi_awvalid_i & axi_awready_r) & !(axi_wvalid_i & axi_wready_r & axi_wlast_i))
    addr_outs_nxt = addr_outs_r + 'h1;
  else if (!(axi_awvalid_i & axi_awready_r) & (axi_wvalid_i & axi_wready_r & axi_wlast_i) & addr_outs_neq0_r)
    addr_outs_nxt = addr_outs_r - 'h1;
  else
    addr_outs_nxt = addr_outs_r;
end


//logic axi_bvalid_nxt;

always_ff @(posedge hclk or negedge hrst_n)
 begin
    if(!hrst_n)
       resp_cnt <= 3'h0;
    else if(rsp_fifo_rd  & (!(axi_bvalid_r  & axi_bready_i)))
      resp_cnt <= resp_cnt +1;
    else if(axi_bvalid_r  & axi_bready_i & !rsp_fifo_rd) 
      resp_cnt <= resp_cnt - 1;
 end

always_comb begin
  // The response FIFO will always have data because address phase complete first before data phase
  if (axi_bvalid_r & axi_bready_i) // Make sure the bvalid is only 1 txn at a time.
    axi_bvalid_nxt = 1'b0;
  else if (brespfifo_valid)        // Requires min of 2clk_i from address txn before the bid will be ready in FIFO
    axi_bvalid_nxt = 1'b1;
  else if (axi_bready_i)           // Only de-assert when bvalid and no wr_data_done
    axi_bvalid_nxt = 1'b0;
  else
    axi_bvalid_nxt = axi_bvalid_r;
end

logic last_cnt_r_neq0_r;

always_ff @(posedge hclk or negedge hrst_n)
 begin
    if(!hrst_n)
     begin
      last_cnt_r        <= 'h0;
      addr_outs_r       <= 'h0;
      addr_outs_eq0_r   <= 1'b0;
      addr_outs_neq0_r  <= 1'b0;
      addr_outs_eq1_r   <= 1'b0;
      brespfifo_valid   <= 1'b0;
      axi_bvalid_o      <= 1'b0;
      axi_bvalid_r      <= 1'b0;
      rsp_fifo_empty_r  <= 1'b0;
      axi_bid_o         <= {AXI_ID_WIDTH{1'b0}};
      last_cnt_r_neq0_r <= 1'b0;
     end
    else 
     begin
      last_cnt_r        <= last_cnt_nxt;
      last_cnt_r_neq0_r <= last_cnt_r_neq0;
      // The brespfifo_valid is like a delayed version of not empty.
      // Need to de-assert this after wr_resp tnx to avoid miss judgement due to the delay.
      brespfifo_valid   <= rsp_fifo_rd;
      addr_outs_r       <= addr_outs_nxt;
      addr_outs_eq0_r   <= addr_outs_nxt == 0;
      addr_outs_neq0_r  <= addr_outs_nxt != 0;
      addr_outs_eq1_r   <= addr_outs_nxt == 1;
      axi_bvalid_o      <= axi_bvalid_nxt;
      axi_bvalid_r      <= axi_bvalid_nxt;
      rsp_fifo_empty_r  <= rsp_fifo_empty;
//      if ((!axi_bvalid_o & wr_data_done) | // bid from IDLE to valid
//          (axi_bvalid_o & axi_bready_i))   // bid update during txn in write response
      if (!axi_bvalid_o & axi_bvalid_nxt)    // Update bid together with the bvalid assertion
        axi_bid_o  <= rsp_fifo_rddata;
     end
 end
 
assign rsp_fifo_rd = !rsp_fifo_empty & (resp_cnt == 0) & ((last_cnt_r_neq0 & !last_cnt_r_neq0_r) |     // Prepare the ID in the FIFO output for IDLE to valid
                     (last_cnt_r>=1));
 
assign axi_bresp_o  = 2'h0;


always_ff @(posedge hclk or negedge hrst_n)
 begin
    if(!hrst_n)
       axi_wr_outstanding <= 0;
    else if(axi_awvalid_i & axi_awready_r & axi_bvalid_r & axi_bready_i)
       axi_wr_outstanding <= axi_wr_outstanding;
    else if(axi_awvalid_i & axi_awready_r)
       axi_wr_outstanding <= axi_wr_outstanding + 1;
    else if(axi_bvalid_r & axi_bready_i & axi_wr_outstanding != 0)
       axi_wr_outstanding <= axi_wr_outstanding - 1;
 end


generate
if(DATA_CLK_EN) begin : ASYNC
  lpddr4_mc_async_fifo
  #(
  .WIDTH      (AXI_CTRL_WIDTH+AXI_ADDR_WIDTH+1),
  .DEPTH      (CTRL_FIFO_DEPTH)
  )
   u_ctrl_fifo
         (
          .wr_clk_i(hclk), 
          .rd_clk_i(sclk), 
          .rst_i(!hrst_n), 
          .rp_rst_i(!srst_n), 
          .wr_en_i(wr_ctrl_fifo_wr),
          .rd_en_i(wr_ctrl_fifo_rd), 
          .wr_data_i(wr_ctrl_fifo_wrdata), 
          .full_o(wr_ctrl_fifo_full), 
          .almost_full_o(wr_ctrl_fifo_almost_full),
          .empty_o(wr_ctrl_fifo_empty), 
          .rd_data_nxt(wr_ctrl_fifo_rddata_nxt),
          .rd_data_o(wr_ctrl_fifo_rddata)
        ) ;
  
// Merged data and strobe in 1 sync_fifo to ensure re-convergence
  lpddr4_mc_async_fifo
  #(
  .WIDTH      (BL_BYTE_EN_WIDTH+3+BL_DATA_WIDTH),
  .DEPTH      (16)
  )
   u_data_fifo
         (
          .wr_clk_i(hclk), 
          .rd_clk_i(sclk), 
          .rst_i(!hrst_n), 
          .rp_rst_i(!srst_n), 
          .wr_en_i(wr_data_fifo_wr), 
          .rd_en_i(wr_data_fifo_rd), 
          .wr_data_i({wr_strb_fifo_wrdata, wr_data_fifo_wrdata}), 
          .full_o(wr_data_fifo_full), 
          .almost_full_o(wr_data_fifo_almost_full),
          .empty_o(wr_data_fifo_empty), 
          .rd_data_nxt({wr_strb_fifo_rddata_nxt, wr_data_fifo_rddata_nxt}),
          .rd_data_o({wr_strb_fifo_rddata, wr_data_fifo_rddata})
        ) ;


    lpddr4_mc_async_fifo #(
       .WIDTH      (AXI_ID_WIDTH  ),
       .DEPTH      (OUTSTANDING_WR)  // +2 for pessimistic full
     )
     u_resp_fifo (
       .wr_clk_i   (sclk           ), 
       .rd_clk_i   (hclk           ), 
       .rst_i      (!srst_n        ), 
       .rp_rst_i   (!hrst_n        ), 
       .wr_en_i    (rsp_fifo_wr    ), 
       .rd_en_i    (rsp_fifo_rd    ), 
       .wr_data_i  (rsp_fifo_wrdata), 
       .full_o     (rsp_fifo_full  ), 
       .almost_full_o(             ),
       .empty_o    (rsp_fifo_empty ), 
       .rd_data_nxt(               ),
       .rd_data_o  (rsp_fifo_rddata)
     );
 
  
//  lpddr4_mc_async_fifo
//  #(
//  .WIDTH      (BL_BYTE_EN_WIDTH+3),
//  .DEPTH      (8)
//  )
//   u_strb_fifo
//         (
//          .wr_clk_i(hclk), 
//          .rd_clk_i(sclk), 
//          .rst_i(!hrst_n), 
//          .rp_rst_i(!srst_n), 
//          .wr_en_i(wr_data_fifo_wr), 
//          .rd_en_i(wr_data_fifo_rd), 
//          .wr_data_i(wr_strb_fifo_wrdata), 
//          .full_o(), 
//          .almost_full_o(),
//          .empty_o(wr_strb_fifo_empty), 
//          .rd_data_nxt(wr_strb_fifo_rddata_nxt),
//          .rd_data_o(wr_strb_fifo_rddata)
//        ) ;
end
else begin : SYNC
  lpddr4_mc_sync_fifo
  #(
  .WIDTH      (AXI_CTRL_WIDTH+AXI_ADDR_WIDTH+1),
  .DEPTH      (CTRL_FIFO_DEPTH)
  )
   u_ctrl_fifo
         (
          .clk_i(hclk), 
          .rst_i(!hrst_n), 
          .wr_en_i(wr_ctrl_fifo_wr), 
          .rd_en_i(wr_ctrl_fifo_rd), 
          .wr_data_i(wr_ctrl_fifo_wrdata), 
          .full_o(wr_ctrl_fifo_full), 
          .almost_full_o(wr_ctrl_fifo_almost_full),
          .empty_o(wr_ctrl_fifo_empty), 
          .rd_data_nxt(wr_ctrl_fifo_rddata_nxt),
          .rd_data_o(wr_ctrl_fifo_rddata)
        ) ;
  
// Merged data and strobe similar to sync_FIFO
  lpddr4_mc_sync_fifo
  #(
  .WIDTH      (BL_BYTE_EN_WIDTH+3+BL_DATA_WIDTH),
  .DEPTH      (16)
  )
   u_data_fifo
         (
          .clk_i(hclk), 
          .rst_i(!hrst_n), 
          .wr_en_i(wr_data_fifo_wr), 
          .rd_en_i(wr_data_fifo_rd), 
          .wr_data_i({wr_strb_fifo_wrdata, wr_data_fifo_wrdata}), 
          .full_o(wr_data_fifo_full), 
          .almost_full_o(wr_data_fifo_almost_full),
          .empty_o(wr_data_fifo_empty), 
          .rd_data_nxt({wr_strb_fifo_rddata_nxt, wr_data_fifo_rddata_nxt}),
          .rd_data_o({wr_strb_fifo_rddata, wr_data_fifo_rddata})
        ) ;

    lpddr4_mc_sync_fifo
    #(
    .WIDTH      (AXI_ID_WIDTH  ),
    .DEPTH      (OUTSTANDING_WR)
    )
     u_rsp_fifo
           (
            .clk_i(hclk), 
            .rst_i(!hrst_n), 
            .wr_en_i(rsp_fifo_wr), 
            .rd_en_i(rsp_fifo_rd), 
            .wr_data_i(rsp_fifo_wrdata), 
            .full_o(rsp_fifo_full), 
            .almost_full_o(),
            .empty_o(rsp_fifo_empty), 
            .rd_data_nxt(),
            .rd_data_o(rsp_fifo_rddata)
          ) ;
    
//  lpddr4_mc_sync_fifo
//  #(
//  .WIDTH      (BL_BYTE_EN_WIDTH+3),
//  .DEPTH      (8)
//  )
//   u_strb_fifo
//         (
//          .clk_i(hclk), 
//          .rst_i(!hrst_n), 
//          .wr_en_i(wr_data_fifo_wr), 
//          .rd_en_i(wr_data_fifo_rd), 
//          .wr_data_i(wr_strb_fifo_wrdata), 
//          .full_o(), 
//          .almost_full_o(),
//          .empty_o(wr_strb_fifo_empty), 
//          .rd_data_nxt(wr_strb_fifo_rddata_nxt),
//          .rd_data_o(wr_strb_fifo_rddata)
//        ) ;
  
  
  
end
endgenerate
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////WRITE ASYNC FIFIO///////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
typedef enum logic {WR_IDLE,WR_START} wr_state;
wr_state wr_pstate, wr_nstate;
logic wr_req_valid_d;

// Making the wr_req_valid registered
//assign wr_req_valid          = wr_ctrl_fifo_rddata[0] & (wr_ctrl_fifo_rd_d) ;
wire wr_req_valid_ref          = wr_ctrl_fifo_rddata[0] & (wr_ctrl_fifo_rd_d) ;
wire wr_req_valid_nxt          = wr_ctrl_fifo_rddata_nxt[0] & (wr_ctrl_fifo_rd) ;

always_ff @(posedge sclk or negedge srst_n)
  if(!srst_n)
    wr_req_valid <= 1'b0;
  else 
    wr_req_valid <= wr_req_valid_nxt;

always_ff @(posedge sclk or negedge srst_n)
  if(!srst_n)
    wr_req_valid_rep <= 1'b0;
  else 
    wr_req_valid_rep <= wr_req_valid_nxt;


assign wr_req_ctrl           = wr_ctrl_fifo_rddata[AXI_CTRL_WIDTH:1];
//FIXME: separate the wr_req_txn_id
assign wr_addr               = wr_ctrl_fifo_rddata[AXI_CTRL_WIDTH+AXI_ADDR_WIDTH:AXI_CTRL_WIDTH+1];

always_ff @(posedge sclk or negedge srst_n)
if(!srst_n)
wr_ctrl_fifo_rd_d <= 1'b0;
else 
wr_ctrl_fifo_rd_d <= wr_ctrl_fifo_rd;

logic  wr_valid_ref    ;
logic  wr_data_last_ref;

assign wr_valid_ref       = wr_strb_fifo_rddata[0] & wr_data_fifo_rd_d ;
assign wr_data_last_ref   = wr_strb_fifo_rddata[1] & wr_data_fifo_rd_d ;

//assign wr_data_err        = wr_strb_fifo_rddata[2] & wr_data_fifo_rd_d ;
assign wr_byte_en         = wr_strb_fifo_rddata[BL_BYTE_EN_WIDTH+2:3];
assign wr_data            = wr_data_fifo_rddata;

always_ff @(posedge sclk or negedge srst_n) begin
  if(!srst_n) begin
    wr_data_fifo_rd_d <= 1'b0;
    wr_valid          <= 1'b0;
    wr_data_last      <= 1'b0;
    wr_data_last_rep  <= 1'b0;
    wr_be_hole        <= 1'b0;
  end
  else begin
    wr_data_fifo_rd_d <= wr_data_fifo_rd;
    wr_valid          <= wr_strb_fifo_rddata_nxt[0] & wr_data_fifo_rd ;
    wr_data_last      <= wr_strb_fifo_rddata_nxt[1] & wr_data_fifo_rd ;
    wr_data_last_rep  <= wr_strb_fifo_rddata_nxt[1] & wr_data_fifo_rd ;
    wr_be_hole        <= !(&wr_strb_fifo_rddata_nxt[BL_BYTE_EN_WIDTH+2:3]);
  end
end

`ifdef RVL_DEBUG_EN
logic  rvl_wr_data_fifo_empty;
logic  rvl_wr_data_last_ref  ;
logic  rvl_wr_data_fifo_rd_d ;

always_ff @(posedge sclk or negedge srst_n) begin
  if(!srst_n) begin
    rvl_wr_data_fifo_empty <= 1'b0;
    rvl_wr_data_last_ref   <= 1'b0;
    rvl_wr_data_fifo_rd_d  <= 1'b0;
  end
  else begin
    rvl_wr_data_fifo_empty <= wr_data_fifo_empty;
    rvl_wr_data_last_ref   <= wr_data_last_ref  ;
    rvl_wr_data_fifo_rd_d  <= wr_data_fifo_rd_d ;
  end
end
`endif

always_ff @(posedge sclk or negedge srst_n)
if(!srst_n)
wr_pstate  <= WR_IDLE;
else 
wr_pstate  <= wr_nstate;


always_comb
begin
wr_nstate = wr_pstate;
wr_ctrl_fifo_rd = 1'b0;
wr_data_fifo_rd = 1'b0;
case(wr_pstate)
//WR_WAIT : begin 
//            wr_ctrl_fifo_rd = 1'b1;
//            wr_data_fifo_rd = 1'b1;
//            //if(wr_ctrl_fifo_empty == 1'b1  & wr_data_fifo_empty == 1'b1)
//            if(wr_ctrl_fifo_empty & wr_data_fifo_empty)
//              wr_nstate = WR_IDLE;
//          end
WR_IDLE : begin
           //if(wr_ctrl_fifo_empty == 1'b0  & wr_data_fifo_empty == 1'b0 & wr_req_ready)
           if(!wr_ctrl_fifo_empty & !wr_data_fifo_empty & wr_req_ready)
             begin
                   wr_nstate = WR_START;
                   wr_ctrl_fifo_rd = 1'b1;
                   wr_data_fifo_rd = 1'b1;
             end
          end
WR_START : begin
                if(wr_data_fifo_empty & wr_ctrl_fifo_empty & wr_data_last_rep)
                 begin
                  wr_nstate = WR_IDLE;
                 end
                else if(wr_data_last_rep & wr_req_ready & wr_req_valid_rep)  //SINGLE READ
                 begin
                  wr_ctrl_fifo_rd = 1'b0;
                  wr_data_fifo_rd = 1'b0;
                  wr_nstate = WR_IDLE;
                 end
               else if(wr_data_last_rep & wr_req_ready & !wr_ctrl_fifo_empty & !wr_data_fifo_empty)
                 begin
                  wr_ctrl_fifo_rd = 1'b1;
                  wr_data_fifo_rd = !wr_data_fifo_empty;
                  wr_nstate = WR_START;
                 end
               else if(wr_data_last_rep & wr_data_fifo_empty)
                 begin
                   wr_ctrl_fifo_rd = 1'b0;
                   wr_data_fifo_rd = !wr_data_fifo_empty;
                   wr_nstate = WR_IDLE;
                 end 
               else if(wr_data_last_rep & !wr_req_ready)
                 begin
                  wr_ctrl_fifo_rd = 1'b0;
                  wr_data_fifo_rd = 1'b0;
                  wr_nstate = WR_IDLE;
                 end
                else 
                 begin
                  wr_nstate = WR_START;
                  wr_data_fifo_rd = !wr_data_fifo_empty;
                 end
           end

endcase
end

endmodule
