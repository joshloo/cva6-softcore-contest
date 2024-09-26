
module lpddr4_mc_axi_slv_rd_rsp #(
  parameter AXI_DATA_WIDTH          = 0, 
  parameter AXI_ID_WIDTH            = 0, 
  parameter AXI_LEN_WIDTH           = 0, 
  parameter ORDER_ID_WIDTH          = 0, 
  parameter BI_RD_DATA_Q_WIDTH      = 0,
  parameter SCH_NUM_WR_SUPPORT      = 0,
  parameter SCH_NUM_RD_SUPPORT      = 0,
  parameter MAX_OUTSTANDING_RD      = 8, 
  parameter MAX_BURST_LEN           = 64,
  parameter DATA_CLK_EN             = 0,
  parameter DDR_WIDTH               = 0, 
  parameter AXI_DATA_WIDTH_DIV2     = AXI_DATA_WIDTH/2,
  parameter RSP_ADDR_WIDTH          = AXI_LEN_WIDTH,  
  parameter SIZE_WIDTH       = 3,
  parameter TOTAL_CTRL_WIDTH = AXI_LEN_WIDTH+AXI_ID_WIDTH+ORDER_ID_WIDTH+SIZE_WIDTH,
  parameter CTRL_DPRAM_WIDTH = TOTAL_CTRL_WIDTH+8   // FIXME: Why address is only 8 bits? MAX_OUTSTANDING_RD *64=512=> 9bits

)
(
  input  sclk,
  input  rst_n,
  input  hclk,
  input  hrst_n,

  input  axi_rready_i,
  output logic [AXI_ID_WIDTH -1 : 0] axi_rid_o,
  output logic axi_rlast_o,
  output logic axi_rvalid_o/* synthesis syn_preserve=1 */,
  output logic [AXI_DATA_WIDTH -1 :0] axi_rdata_o,

  input                                        rd_rsp_valid,
  input                                        rd_rsp_rlast,
  output                                       rd_rsp_ready,
  input [AXI_DATA_WIDTH - 1:0]                 rd_rsp_data,
  input [AXI_ID_WIDTH -1:0]                    rd_rsp_rid

 
 
);

logic [AXI_DATA_WIDTH+AXI_ID_WIDTH :0] rd_rsp_data_fifo_rddata;
logic rd_rsp_data_fifo_rd_d;
logic rd_rsp_data_fifo_empty;
logic rd_rsp_data_fifo_wr;    
logic [AXI_DATA_WIDTH + AXI_ID_WIDTH :0] rd_rsp_data_fifo_wrdata;
logic rd_rsp_data_fifo_full;
logic rd_rsp_data_fifo_almost_full;
logic rd_rsp_data_fifo_rd;

assign rd_rsp_data_fifo_wr     = rd_rsp_valid;
assign rd_rsp_ready            = rd_rsp_data_fifo_almost_full;
assign rd_rsp_data_fifo_wrdata = {rd_rsp_rlast,rd_rsp_rid,rd_rsp_data};



 lpddr4_mc_async_fifo #(
    .WIDTH      (AXI_DATA_WIDTH+AXI_ID_WIDTH+1),
    .DEPTH      (16),
    .FWFT       (1)
  )
  u_data_fifo (
    .wr_clk_i(sclk), 
    .rd_clk_i(hclk), 
    .rst_i(!rst_n), 
    .rp_rst_i(!hrst_n), 
    .wr_en_i(rd_rsp_data_fifo_wr & !rd_rsp_data_fifo_full), 
    .rd_en_i(rd_rsp_data_fifo_rd), 
    .wr_data_i(rd_rsp_data_fifo_wrdata), 
    .full_o(rd_rsp_data_fifo_full), 
    .almost_full_o(rd_rsp_data_fifo_almost_full),
    .empty_o(rd_rsp_data_fifo_empty), 
    .rd_data_nxt(),
    .rd_data_o(rd_rsp_data_fifo_rddata)
  ) ;

//logic axi_txn;

assign rd_rsp_data_fifo_rd = (axi_rvalid_o) ? axi_rready_i & !rd_rsp_data_fifo_empty : !rd_rsp_data_fifo_empty;

//always @(posedge hclk or negedge hrst_n)
//   if(!hrst_n)
//      axi_txn  <= 1'b0;
//   else if((axi_rlast_o & axi_rready_i & axi_rvalid_o) | rd_rsp_data_fifo_empty)
//      axi_txn  <= 1'b0;
//   else if(rd_rsp_data_fifo_rd)  
//      axi_txn  <= 1'b1;
//  

always_ff @(posedge hclk or negedge hrst_n) begin
   if(!hrst_n)
      axi_rvalid_o   <= 1'b0;
   else if(axi_rready_i & axi_rvalid_o  & !rd_rsp_data_fifo_rd)
      axi_rvalid_o   <= 1'b0;
   else if(rd_rsp_data_fifo_rd) 
      axi_rvalid_o   <= 1'b1;
end  // always_ff

always @(posedge hclk or negedge hrst_n)
   if(!hrst_n) 
      axi_rlast_o   <= 1'b0;
  else if (rd_rsp_data_fifo_rd)
      axi_rlast_o   <= rd_rsp_data_fifo_rddata[AXI_DATA_WIDTH+ AXI_ID_WIDTH];
  else if(axi_rready_i)
      axi_rlast_o   <= 1'b0;

 always @(posedge hclk or negedge hrst_n)
   if(!hrst_n) begin
      axi_rdata_o   <= {AXI_DATA_WIDTH{1'b0}};
      axi_rid_o   <= {AXI_ID_WIDTH{1'b0}};
   end else if (rd_rsp_data_fifo_rd) begin
      axi_rdata_o   <= rd_rsp_data_fifo_rddata[AXI_DATA_WIDTH - 1 : 0];
      axi_rid_o   <= rd_rsp_data_fifo_rddata[AXI_DATA_WIDTH + AXI_ID_WIDTH - 1 : AXI_DATA_WIDTH];
   end  



endmodule
