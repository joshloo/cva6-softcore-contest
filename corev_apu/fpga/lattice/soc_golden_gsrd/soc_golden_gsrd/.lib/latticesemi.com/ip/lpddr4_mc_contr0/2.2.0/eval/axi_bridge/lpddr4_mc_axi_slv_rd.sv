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
// File                  : lpddr4_mc_axi_slv_rd.v
// Title                 :
// Dependencies          :
// Description           :
// =============================================================================

module lpddr4_mc_axi_slv_rd
#(
parameter DDR_TYPE            = 0, // 4'b0011= DDR3, 4'b0100= DDR4, 4'b0101= DDR5 4'b1010= LPDDR2, 4'b1011= LPDDR3, 4'b1100= LPDDR4
parameter SCH_NUM_RD_SUPPORT  = 0,
parameter DDR_WIDTH           = 0,
parameter AXI_ADDR_WIDTH      = 0,
parameter AXI_ID_WIDTH        = 0,
parameter AXI_DATA_WIDTH      = 0,
parameter AXI_CTRL_WIDTH      = 0,                 
parameter AXI_LEN_WIDTH       = 0,
parameter AXI_QOS_WIDTH       = 0,
parameter BI_RD_DATA_Q_WIDTH  = 0,
parameter BI_RD_DATA_Q_DEPTH  = 0,
parameter ORDER_ID_WIDTH      = 0,
parameter DATA_CLK_EN         = 0,
parameter CTRL_FIFO_DEPTH     = 4
)
(
input                                 hclk,
input                                 hrst_n,
input                                 sclk,
input                                 srst_n,

input                                 axi_arvalid_i,
input [AXI_ID_WIDTH - 1 :0]           axi_arid_i,
input [AXI_LEN_WIDTH -1 : 0]          axi_arlen_i,
input [1:0]                           axi_arburst_i,
input [AXI_ADDR_WIDTH -1 : 0]         axi_araddr_i,
output logic                          axi_arready_o,
input [AXI_QOS_WIDTH -1  : 0]         axi_arqos_i,
input  [2:0]                          axi_arsize_i,    

input                                 axi_rready_i,

output [1:0]                    axi_rresp_o,
output [AXI_ID_WIDTH -1 : 0]    axi_rid_o,
output                          axi_rlast_o,
output                          axi_rvalid_o,
output [AXI_DATA_WIDTH -1 :0]   axi_rdata_o,

        
input                                 rd_req_ready,
output logic                          rd_req_valid,
output logic  [AXI_CTRL_WIDTH-1:0]    rd_req_ctrl,
output logic  [AXI_ADDR_WIDTH-1:0]    rd_req_addr,

input                                        rd_rsp_valid,
input                                        rd_rsp_rlast,
output                                       rd_rsp_ready,
input [AXI_DATA_WIDTH - 1:0]             rd_rsp_data,
input [AXI_ID_WIDTH -1:0]                    rd_rsp_rid
//input [AXI_LEN_WIDTH -1 :0]                  rd_rsp_length,
//input [3 -1 :0]                              rd_rsp_size,
//input [7:0]                                  rd_rsp_addr




 
);
localparam OUTSTANDING_RD      = CTRL_FIFO_DEPTH + SCH_NUM_RD_SUPPORT;
localparam OUTSTANDING_RD_SUB1 = OUTSTANDING_RD - 1;
//---------------Declarations for Req queue related signals--------------
logic                                                rd_ctrl_fifo_wr;
logic                                                rd_ctrl_fifo_rd;
logic                                                rd_ctrl_fifo_rd_d;
logic [AXI_CTRL_WIDTH+AXI_ADDR_WIDTH : 0]            rd_ctrl_fifo_wrdata;
logic [AXI_CTRL_WIDTH+AXI_ADDR_WIDTH : 0]            rd_ctrl_fifo_rddata;
logic                                                rd_ctrl_fifo_empty;
logic                                                rd_ctrl_fifo_empty_d;
logic                                                rd_ctrl_fifo_full;

logic [ORDER_ID_WIDTH -1:0] int_arid; 
logic [8:0]length;
logic [2:0]                          axi_rd_outstanding;
logic                               sig_rd_req_valid;
logic  [AXI_CTRL_WIDTH-1:0]         sig_rd_req_ctrl;
logic  [AXI_ADDR_WIDTH-1:0]         sig_rd_req_addr;

assign length      = axi_arlen_i+ 1;
assign axi_rresp_o = 0;


always_ff @(posedge hclk or negedge hrst_n)   //INTERNAL ID assigned with every transaction to handle out of order requests.
  if(!hrst_n)
    int_arid <= 0;
  else if(axi_arvalid_i & axi_arready_o)
    int_arid <= int_arid + 1'h1;

always_ff @(posedge hclk or negedge hrst_n)
  if(!hrst_n)
     rd_ctrl_fifo_wrdata  <= 9'h0;
  else if(axi_arvalid_i & axi_arready_o)
     rd_ctrl_fifo_wrdata  <= {axi_araddr_i,axi_arid_i,int_arid,axi_arsize_i,length,{axi_arvalid_i & axi_arready_o}};                   


always_ff @(posedge hclk or negedge hrst_n)
  if(!hrst_n)
     rd_ctrl_fifo_wr  <= 1'h0;
  else if(axi_arvalid_i & axi_arready_o) 
     rd_ctrl_fifo_wr <= 1'b1;
  else if(!rd_ctrl_fifo_full)
     rd_ctrl_fifo_wr <= 1'b0;
                      
always_ff @(posedge hclk or negedge hrst_n)
  if(!hrst_n)
     axi_arready_o <= 1'b1; 
  else if(rd_ctrl_fifo_full | ((axi_rd_outstanding <= OUTSTANDING_RD_SUB1) & axi_arvalid_i & axi_arready_o))
     axi_arready_o <= 1'b0;
  else
     axi_arready_o <= axi_rd_outstanding < OUTSTANDING_RD_SUB1;  

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
          .wr_en_i(rd_ctrl_fifo_wr & !rd_ctrl_fifo_full), 
          .rd_en_i(rd_ctrl_fifo_rd), 
          .wr_data_i(rd_ctrl_fifo_wrdata), 
          .full_o(rd_ctrl_fifo_full), 
          .almost_full_o(),
          .empty_o(rd_ctrl_fifo_empty), 
          .rd_data_nxt(),
          .rd_data_o(rd_ctrl_fifo_rddata)
        ) ;
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
          .wr_en_i(rd_ctrl_fifo_wr & !rd_ctrl_fifo_full), 
          .rd_en_i(rd_ctrl_fifo_rd), 
          .wr_data_i(rd_ctrl_fifo_wrdata), 
          .full_o(rd_ctrl_fifo_full), 
          .almost_full_o(),
          .empty_o(rd_ctrl_fifo_empty), 
          .rd_data_nxt(),
          .rd_data_o(rd_ctrl_fifo_rddata)
        ) ;
  
end

endgenerate


typedef enum logic {IDLE,READ} state;
state pstate, nstate;

always_comb
begin
sig_rd_req_valid        = 0;
sig_rd_req_ctrl         = 0;
sig_rd_req_addr         = 0;
rd_ctrl_fifo_rd         = 1'b0;
nstate                  = IDLE;
case(pstate)
IDLE : if(rd_req_ready & !rd_ctrl_fifo_empty)
          begin
           rd_ctrl_fifo_rd   = 1'b1;
           nstate            = READ;
          end

READ  : begin
         sig_rd_req_valid        = rd_ctrl_fifo_rddata[0] ;                                     
         sig_rd_req_ctrl         = rd_ctrl_fifo_rddata[AXI_CTRL_WIDTH:1];
         sig_rd_req_addr         = rd_ctrl_fifo_rddata[AXI_CTRL_WIDTH+AXI_ADDR_WIDTH : AXI_CTRL_WIDTH +1]; 
         if(rd_req_ready) begin
         nstate              = IDLE;
         end
         else 
         nstate              = READ;
        end
endcase
end


//assign rd_req_valid        = rd_ctrl_fifo_rddata[0] & rd_ctrl_fifo_rd_d ;
//assign rd_req_ctrl         = rd_ctrl_fifo_rddata[AXI_CTRL_WIDTH:1];
//assign rd_req_addr         = rd_ctrl_fifo_rddata[AXI_CTRL_WIDTH+AXI_ADDR_WIDTH : AXI_CTRL_WIDTH +1]   ;
//
//assign rd_ctrl_fifo_rd     = !rd_ctrl_fifo_empty  & rd_req_ready;

always_ff @(posedge sclk or negedge srst_n)
if(!srst_n)
rd_ctrl_fifo_rd_d <= 1'b0;
else 
rd_ctrl_fifo_rd_d <= rd_ctrl_fifo_rd;

always_ff @(posedge sclk or negedge srst_n)
if(!srst_n)
pstate <= IDLE;
else 
pstate <= nstate;

always_ff @(posedge sclk or negedge srst_n)
if(!srst_n)
begin
rd_req_valid <= 0  ;
rd_req_ctrl  <= 0  ;
rd_req_addr  <= 0  ;
end
else 
begin
rd_req_valid <= sig_rd_req_valid  ;
rd_req_ctrl  <= sig_rd_req_ctrl   ;
rd_req_addr  <= sig_rd_req_addr   ;
end



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////READ RESPONSE///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

always_ff @(posedge hclk or negedge hrst_n)
 if(~hrst_n)
    axi_rd_outstanding <= 0;
 else if(axi_rvalid_o & axi_rready_i & axi_rlast_o & axi_arvalid_i & axi_arready_o)
    axi_rd_outstanding <= axi_rd_outstanding;
 else if(axi_arvalid_i & axi_arready_o & axi_rd_outstanding != OUTSTANDING_RD_SUB1)
    axi_rd_outstanding <= axi_rd_outstanding + 1;
 else if(axi_rvalid_o & axi_rready_i & axi_rlast_o & axi_rd_outstanding != 0)
    axi_rd_outstanding <= axi_rd_outstanding - 1;


lpddr4_mc_axi_slv_rd_rsp #(
    .AXI_DATA_WIDTH       (AXI_DATA_WIDTH    ),
    .DATA_CLK_EN          (DATA_CLK_EN       ),
    .DDR_WIDTH            (DDR_WIDTH         ),
    .AXI_ID_WIDTH         (AXI_ID_WIDTH      ),
    .ORDER_ID_WIDTH         (ORDER_ID_WIDTH      ),
    .AXI_LEN_WIDTH        (AXI_LEN_WIDTH     ),
    .BI_RD_DATA_Q_WIDTH   (BI_RD_DATA_Q_WIDTH),
    .SCH_NUM_RD_SUPPORT   (SCH_NUM_RD_SUPPORT)  
  )
  u_rd_rsp (
    .sclk           (sclk            ),
    .rst_n          (srst_n          ),  // sclk-based reset
    .hclk           (hclk            ),
    .hrst_n         (hrst_n          ),  // aclk-based reset
    .axi_rvalid_o   (axi_rvalid_o    ),
    .axi_rlast_o    (axi_rlast_o     ),
    .axi_rdata_o    (axi_rdata_o     ),
    .axi_rready_i   (axi_rready_i    ),
    .axi_rid_o      (axi_rid_o       ),

    .rd_rsp_valid (rd_rsp_valid),
    .rd_rsp_ready (rd_rsp_ready),
    .rd_rsp_rid   (rd_rsp_rid),
    .rd_rsp_data  (rd_rsp_data),
    .rd_rsp_rlast (rd_rsp_rlast)

  );

 
endmodule
