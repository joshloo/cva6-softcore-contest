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
// File                  : lddr4_mc_axi_iface_top.v
// Title                 :
// Dependencies          :
// Description           :
// =============================================================================


module lddr4_mc_axi_iface_top #(
  parameter DDR_TYPE            = 0,  // 4'b0011= DDR3, 4'b0100= DDR4, 4'b0101= DDR5 4'b1010= LPDDR2, 4'b1011= LPDDR3, 4'b1100= LPDDR4
  parameter SCH_NUM_RD_SUPPORT  = 0,
  parameter SCH_NUM_WR_SUPPORT  = 0,
  parameter DDR_WIDTH           = 0,
  parameter ORDER_ID_WIDTH      = 0,
  parameter AXI_ADDR_WIDTH      = 0,
  parameter AXI_ID_WIDTH        = 0,
  parameter AXI_USER_WIDTH      = 0,
  parameter AXI_DATA_WIDTH      = 0,
  parameter AXI_CTRL_WIDTH      = 0,                 
  parameter AXI_LEN_WIDTH       = 0,
  parameter AXI_STRB_WIDTH      = 0,
  parameter AXI_QOS_WIDTH       = 0,
  parameter BI_RD_DATA_Q_WIDTH  = 0,
  parameter BI_RD_DATA_Q_DEPTH  = 0,
  parameter BL_DATA_WIDTH       = BI_RD_DATA_Q_WIDTH, 
  parameter BL_BYTE_EN_WIDTH    = BL_DATA_WIDTH/8,
  parameter DATA_CLK_EN         = 0,
  parameter NATV_ID_WIDTH       = AXI_ID_WIDTH + ORDER_ID_WIDTH
)
(
  input                    clk_i   ,
  input                    rst_n_i ,
  input                    sclk_i  ,
  input                    srst_n_i,
  
  //AXI4 INTERFACE
  input                               axi_arvalid_i, 
  input   [AXI_ID_WIDTH  - 1 :0]      axi_arid_i   ,
  input   [AXI_LEN_WIDTH -1 : 0]      axi_arlen_i  ,
  input   [1:0]                       axi_arburst_i,
  input   [AXI_ADDR_WIDTH -1 : 0]     axi_araddr_i ,
  output                              axi_arready_o,
  input   [AXI_QOS_WIDTH -1  : 0]     axi_arqos_i  ,
  input   [2:0]                       axi_arsize_i ,
  
  output  [1:0]                       axi_rresp_o  ,
  output  [AXI_DATA_WIDTH - 1 : 0]    axi_rdata_o  ,
  output  [AXI_ID_WIDTH - 1 : 0]      axi_rid_o    ,
  output                              axi_rvalid_o ,
  output                              axi_rlast_o  ,
  input                               axi_rready_i ,
  
  input                               axi_awvalid_i,
  input  [AXI_LEN_WIDTH -1 : 0]       axi_awlen_i  ,
  input  [1:0]                        axi_awburst_i,
  input  [AXI_ADDR_WIDTH -1 : 0]      axi_awaddr_i ,
  output                              axi_awready_o,
  input  [AXI_QOS_WIDTH -1  : 0]      axi_awqos_i  ,
  input  [2:0]                        axi_awsize_i , 
  input  [AXI_ID_WIDTH -1:0]          axi_awid_i   ,

  input                               axi_wvalid_i,
  output                              axi_wready_o,
  input  [AXI_DATA_WIDTH -1:0]        axi_wdata_i ,
  input  [AXI_STRB_WIDTH -1:0]        axi_wstrb_i ,      
  input                               axi_wlast_i , 

  input                               axi_bready_i,
  output                              axi_bvalid_o,
  output [1:0]                        axi_bresp_o ,
  output [AXI_ID_WIDTH-1:0]           axi_bid_o   ,
  
  //NATIVE INTERFACE 
  // Write Request Channel
  output [NATV_ID_WIDTH-1:0]          wr_req_txn_id_o,
  output [AXI_ADDR_WIDTH-1:0]         wr_req_addr_o  ,
  output [AXI_LEN_WIDTH:0]            wr_req_len_o   ,
  output [2:0]                        wr_req_size_o  ,
  output                              wr_req_valid_o ,
  input                               wr_req_ready_i ,
  // Write data Channel
  output [BI_RD_DATA_Q_WIDTH-1:0]     wr_data_o      ,
  output [(BI_RD_DATA_Q_WIDTH/8)-1:0] wr_byte_en_o   ,
  output                              wr_be_hole_o   ,
  output                              wr_last_o      ,
  output                              wr_valid_o     ,
  input                               wr_ready_i     ,
  input                               wr_rsp_valid_i ,
  input  [AXI_ID_WIDTH - 1 : 0]       wr_rsp_id_i    ,
  // Read Request Channel
  output                              rd_req_valid_o , 
  output [AXI_ADDR_WIDTH-1:0]         rd_req_addr_o  ,
  output [AXI_LEN_WIDTH:0]            rd_req_len_o   ,
  output [2:0]                        rd_req_size_o  ,
  output [NATV_ID_WIDTH -1 : 0]       rd_req_arid_o  ,
  input                               rd_req_ready_i ,
  // Read Response Channel
  input  [AXI_ID_WIDTH - 1 : 0]       rd_rsp_rid_i   ,
  input  [AXI_DATA_WIDTH -1 :0]       rd_rsp_data_i  ,
 // input  [AXI_LEN_WIDTH-1:0]          rd_rsp_len_i   ,
 // input  [3-1:0]                      rd_rsp_size_i   ,
 // input  [7:0]                        rd_rsp_addr_i   ,
  input                               rd_rsp_valid_i ,
  input                               rd_rsp_rlast_i ,
  output                              rd_rsp_ready_o
);


lpddr4_mc_axi_slv_wr #(
  .DATA_CLK_EN       (DATA_CLK_EN       ),
  .SCH_NUM_WR_SUPPORT(SCH_NUM_WR_SUPPORT),
  .DDR_WIDTH         (DDR_WIDTH         ), 
  .AXI_ID_WIDTH      (AXI_ID_WIDTH      ), 
  .ORDER_ID_WIDTH    (ORDER_ID_WIDTH    ), 
  .AXI_ADDR_WIDTH    (AXI_ADDR_WIDTH    ), 
  .AXI_DATA_WIDTH    (AXI_DATA_WIDTH    ), 
  .AXI_CTRL_WIDTH    (AXI_CTRL_WIDTH    ), 
  .AXI_LEN_WIDTH     (AXI_LEN_WIDTH     ), 
  .AXI_QOS_WIDTH     (AXI_QOS_WIDTH     ), 
  .AXI_STRB_WIDTH    (AXI_STRB_WIDTH    ),
  .BL_DATA_WIDTH     (BL_DATA_WIDTH     ), 
  .BL_BYTE_EN_WIDTH  (BL_BYTE_EN_WIDTH  )
)
u_wr (
  .hclk              (clk_i   ),   
  .sclk              (sclk_i  ), 
  .hrst_n            (rst_n_i ),  
  .srst_n            (srst_n_i),
  // AXI4 I/F
  .axi_awid_i        (axi_awid_i     ),
  .axi_awaddr_i      (axi_awaddr_i   ),
  .axi_awlen_i       (axi_awlen_i    ),
  .axi_awsize_i      (axi_awsize_i   ),
  .axi_awburst_i     (axi_awburst_i  ),
  .axi_awqos_i       (axi_awqos_i    ),
  .axi_awvalid_i     (axi_awvalid_i  ),
  .axi_awready_o     (axi_awready_o  ),
  .axi_wdata_i       (axi_wdata_i    ),
  .axi_wstrb_i       (axi_wstrb_i    ),                
  .axi_wlast_i       (axi_wlast_i    ),
  .axi_wvalid_i      (axi_wvalid_i   ),
  .axi_wready_o      (axi_wready_o   ),
  .axi_bid_o         (axi_bid_o      ),
  .axi_bresp_o       (axi_bresp_o    ),
  .axi_bvalid_o      (axi_bvalid_o   ),
  .axi_bready_i      (axi_bready_i   ),
  
  // Native I/F
  .wr_req_ctrl       ({wr_req_txn_id_o,wr_req_size_o,wr_req_len_o}),
  .wr_addr           (wr_req_addr_o     ),
  .wr_req_valid      (wr_req_valid_o    ),
  .wr_req_ready      (wr_req_ready_i    ),
  .wr_data           (wr_data_o         ),     
  .wr_byte_en        (wr_byte_en_o      ),
  .wr_be_hole        (wr_be_hole_o      ),
  .wr_data_last      (wr_last_o         ),     
  .wr_valid          (wr_valid_o        ),
  .wr_ready          (wr_ready_i        ),
  .wr_rsp_valid      (wr_rsp_valid_i    ),
  .wr_rsp_id         (wr_rsp_id_i       )
);

lpddr4_mc_axi_slv_rd #(
  .DATA_CLK_EN       (DATA_CLK_EN),
  .DDR_TYPE          (DDR_TYPE          ), 
  .SCH_NUM_RD_SUPPORT(SCH_NUM_RD_SUPPORT),
  .DDR_WIDTH         (DDR_WIDTH         ), 
  .AXI_ADDR_WIDTH    (AXI_ADDR_WIDTH    ), 
  .AXI_ID_WIDTH      (AXI_ID_WIDTH      ), 
  .ORDER_ID_WIDTH    (ORDER_ID_WIDTH    ), 
  .AXI_DATA_WIDTH    (AXI_DATA_WIDTH    ), 
  .AXI_CTRL_WIDTH    (AXI_CTRL_WIDTH    ), 
  .AXI_LEN_WIDTH     (AXI_LEN_WIDTH     ), 
  .AXI_QOS_WIDTH     (AXI_QOS_WIDTH     ), 
  .BI_RD_DATA_Q_WIDTH(BI_RD_DATA_Q_WIDTH), 
  .BI_RD_DATA_Q_DEPTH(BI_RD_DATA_Q_DEPTH) 
)
u_rd (
  .hclk               (clk_i   ),
  .hrst_n             (rst_n_i ),
  .sclk               (sclk_i  ),
  .srst_n             (srst_n_i),

  .axi_arid_i         (axi_arid_i    ),
  .axi_araddr_i       (axi_araddr_i  ),
  .axi_arsize_i       (axi_arsize_i  ),
  .axi_arlen_i        (axi_arlen_i   ),
  .axi_arburst_i      (axi_arburst_i ),
  .axi_arqos_i        (axi_arqos_i   ),
  .axi_arvalid_i      (axi_arvalid_i ),
  .axi_arready_o      (axi_arready_o ),
  .axi_rid_o          (axi_rid_o     ),
  .axi_rdata_o        (axi_rdata_o   ),
  .axi_rresp_o        (axi_rresp_o   ),
  .axi_rlast_o        (axi_rlast_o   ),
  .axi_rvalid_o       (axi_rvalid_o  ),
  .axi_rready_i       (axi_rready_i  ),
  
  .rd_req_ctrl        ({rd_req_arid_o,rd_req_size_o,rd_req_len_o}),
  .rd_req_addr        (rd_req_addr_o ),
  .rd_req_valid       (rd_req_valid_o),
  .rd_req_ready       (rd_req_ready_i),
  .rd_rsp_rid         (rd_rsp_rid_i  ),
  .rd_rsp_data        (rd_rsp_data_i ),
  //.rd_rsp_length      (rd_rsp_len_i  ),
  //.rd_rsp_size        (rd_rsp_size_i ),
  //.rd_rsp_addr        (rd_rsp_addr_i ),
  .rd_rsp_valid       (rd_rsp_valid_i),
  .rd_rsp_rlast       (rd_rsp_rlast_i),
  .rd_rsp_ready       (rd_rsp_ready_o)
 );

endmodule

