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
// File                  : lscc_axi4_traffic_gen.v
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

module lscc_axi4_traffic_gen
#(
parameter AXI_DATA_WIDTH  = 0,
parameter AXI_STRB_WIDTH  = AXI_DATA_WIDTH/8,
parameter AXI_ADDR_WIDTH  = 0,
parameter AXI_LEN_WIDTH   = 0,
parameter AXI_SIZE_WIDTH  = 0,
parameter DATA_CLK_EN     = 0,
parameter AXI_ID_WIDTH    = 0,
parameter DDR_WIDTH       = AXI_DATA_WIDTH/8, // consider removing DDR_WIDTH
parameter DDR_CMD_FREQ    = 0.0,
parameter APB_ADDR_WIDTH  = 10,
parameter APB_DATA_WIDTH  = 32,
parameter GEN_IN_WIDTH    = 1,
parameter GEN_OUT_WIDTH   = 4,
parameter TIMEOUT_VALUE   = 512,
parameter TIMEOUT_WIDTH   = 10
)
(
//CLOCKS AND RESETS

  input                            pclk_i       ,
  input                            preset_n_i   ,
  input                            aclk_i       ,
  input                            areset_n_i   ,
  input                            sclk_i       ,
  input                            rstn_i       ,

  input  [GEN_IN_WIDTH-1:0]        gen_in_i          ,
  output                           p_rd_error_occur_o,
  output [GEN_OUT_WIDTH-1:0]       a_gen_out_o       ,
  output                           a_rd_timeout_o    ,
  output                           a_wr_timeout_o    ,
  output                           a_rd_err_o        ,
//APB INTERFACE SIGNALS

  input                            apb_psel_i   ,
  input                            apb_penable_i,
  input                            apb_pwrite_i ,
  input  [APB_ADDR_WIDTH-1:0]      apb_paddr_i  ,
  input  [APB_DATA_WIDTH-1:0]      apb_pwdata_i ,
  output                           apb_pready_o ,
  output [APB_DATA_WIDTH-1:0]      apb_prdata_o ,
  output                           apb_pslverr_o,


//AXI INTERFACE SIGNALS
 input                             axi_awready_i,
 output                            axi_awvalid_o,
 output [AXI_ADDR_WIDTH-1:0]       axi_awaddr_o ,
 output [2:0]                      axi_awsize_o ,
 output [AXI_LEN_WIDTH-1:0]        axi_awlen_o  ,
 output [1:0]                      axi_awburst_o,
 output [3:0]                      axi_awqos_o  ,
 output [AXI_ID_WIDTH-1:0]         axi_awid_o   ,
 
 input                             axi_wready_i,
 output                            axi_wvalid_o,
 output [AXI_DATA_WIDTH-1:0]       axi_wdata_o ,
 output [AXI_DATA_WIDTH/8-1:0]     axi_wstrb_o ,  // FIXME: Need to add WSTRB support
 output                            axi_wlast_o ,
 // FIXME: Need to add Write response channel
 output                            axi_bready_o, 
 input                             axi_bvalid_i,
 input [1:0]                       axi_bresp_i , 
 input [AXI_ID_WIDTH-1 : 0]        axi_bid_i   ,
  
 input                             axi_arready_i,
 output                            axi_arvalid_o,
 output [AXI_ADDR_WIDTH-1:0]       axi_araddr_o ,
 output [2:0]                      axi_arsize_o ,
 output [AXI_LEN_WIDTH-1:0]        axi_arlen_o  ,
 output [1:0]                      axi_arburst_o,
 output [3:0]                      axi_arqos_o  ,
 output [AXI_ID_WIDTH-1:0]         axi_arid_o   ,
 
 output                            axi_rready_o,
 input                             axi_rvalid_i,
 input  [AXI_DATA_WIDTH-1:0]       axi_rdata_i ,
 input  [1:0]                      axi_rresp_i ,
 input  [AXI_ID_WIDTH-1:0]         axi_rid_i   , 
 input                             axi_rlast_i
);

logic [AXI_LEN_WIDTH-1:0] cfg_awlen  ;             
logic [1:0]               cfg_awburst;
logic [2:0]               cfg_awsize ;            
logic [AXI_ID_WIDTH-1:0]  cfg_awid   ;
logic [31:0]              cfg_wr_addr_seed;
logic [31:0]              cfg_wr_data_seed_1;    
logic [31:0]              cfg_wr_data_seed_2;    
logic [19:0]              cfg_num_of_wr_trans;   
logic                     cfg_randomize_wraddr; 
logic                     cfg_randomize_wrctrl; 
logic [5:0]               cfg_wr_txn_delay;      
logic                     wr_start;
  
logic [AXI_LEN_WIDTH-1:0] cfg_arlen  ;             
logic [1:0]               cfg_arburst;           
logic [2:0]               cfg_arsize ;           
logic [AXI_ID_WIDTH-1:0]  cfg_arid   ;
logic                     cfg_fixed_araddr;
logic [31:0]              cfg_rd_addr_seed;      
logic [31:0]              cfg_rd_data_seed_1;    
logic [31:0]              cfg_rd_data_seed_2;    
logic [19:0]              cfg_num_of_rd_trans;   
logic                     cfg_randomize_rdaddr; 
logic                     cfg_randomize_rdctrl; 
logic [5:0]               cfg_rd_txn_delay;      
logic                     rd_start;
logic                     rd_error;
logic [19:0]              num_of_rd_trans;
logic [31:0]              total_num_wr_rd    ;
logic [31:0]              duration_cntr_status_sclk;
logic [31:0]              duration_cntr_status_aclk;

lscc_axi4_m_wr
#(
.DDR_WIDTH        (DDR_WIDTH       ),   
.AXI_DATA_WIDTH   (AXI_DATA_WIDTH  ),  
.AXI_ADDR_WIDTH   (AXI_ADDR_WIDTH  ),  
.AXI_LEN_WIDTH    (AXI_LEN_WIDTH   ),  
.AXI_ID_WIDTH     (AXI_ID_WIDTH    ),
.TIMEOUT_VALUE    (TIMEOUT_VALUE   ),
.TIMEOUT_WIDTH    (TIMEOUT_WIDTH   )
)
u_axi_m_wr
(

//CLOCKS AND RESETS
  .aclk_i              (aclk_i        ),
  .areset_n_i          (areset_n_i    ),
  .wr_timeout_o        (a_wr_timeout_o),
//AXI INTERFACE SIGNALS
  .axi_wready_i        (axi_wready_i  ),
  .axi_wvalid_o        (axi_wvalid_o  ),
  .axi_wlast_o         (axi_wlast_o   ),
  .axi_wdata_o         (axi_wdata_o   ),
  .axi_wstrb_o         (axi_wstrb_o   ),
  
  .axi_awready_i       (axi_awready_i ),
  .axi_awvalid_o       (axi_awvalid_o ),
  .axi_awaddr_o        (axi_awaddr_o  ),
  .axi_awsize_o        (axi_awsize_o  ),
  .axi_awlen_o         (axi_awlen_o   ),
  .axi_awburst_o       (axi_awburst_o ),
  .axi_awqos_o         (axi_awqos_o   ),
  .axi_awid_o          (axi_awid_o    ),
  
  .axi_bready_o        (axi_bready_o  ),
  .axi_bvalid_i        (axi_bvalid_i  ),
  .axi_bresp_i         (axi_bresp_i   ),
  .axi_bid_i           (axi_bid_i     ),

  .cfg_awlen           (cfg_awlen           ),
  .cfg_awburst         (cfg_awburst         ),
  .cfg_awsize          (cfg_awsize          ),
  .cfg_awid            (cfg_awid            ),
  .cfg_wr_addr_seed    (cfg_wr_addr_seed    ),
  .cfg_wr_data_seed_1  (cfg_wr_data_seed_1  ),
  .cfg_wr_data_seed_2  (cfg_wr_data_seed_2  ),
  .cfg_num_of_wr_trans (cfg_num_of_wr_trans ),
  .cfg_randomize_wraddr(cfg_randomize_wraddr),
  .cfg_randomize_wrctrl(cfg_randomize_wrctrl),
  .cfg_wr_txn_delay    (cfg_wr_txn_delay    ),
  .wr_start            (wr_start            ),
  .wr_txn_done         (wr_txn_done         )
);

lscc_axi4_m_rd #(
.DDR_WIDTH        (DDR_WIDTH      ),   
.AXI_DATA_WIDTH   (AXI_DATA_WIDTH ),  
.AXI_ADDR_WIDTH   (AXI_ADDR_WIDTH ), 
.AXI_LEN_WIDTH    (AXI_LEN_WIDTH  ), 
.AXI_ID_WIDTH     (AXI_ID_WIDTH   ), 
.TIMEOUT_VALUE    (TIMEOUT_VALUE  ),
.TIMEOUT_WIDTH    (TIMEOUT_WIDTH  ) 
)
u_axi_m_rd
(

//CLOCKS AND RESETS
.aclk_i                 (aclk_i              ),
.areset_n_i             (areset_n_i          ),

.rd_timeout_o           (a_rd_timeout_o      ),
//.rd_err_o               (a_rd_err_o          ),
.rd_err_o               (                    ),

//AXI INTERFACE SIGNALS
.axi_rvalid_i           (axi_rvalid_i        ),
.axi_rlast_i            (axi_rlast_i         ),
.axi_rdata_i            (axi_rdata_i         ),
.axi_rresp_i            (axi_rresp_i         ),
.axi_rid_i              (axi_rid_i           ),
.axi_rready_o           (axi_rready_o        ),

.axi_arready_i          (axi_arready_i       ),
.axi_arvalid_o          (axi_arvalid_o       ),
.axi_araddr_o           (axi_araddr_o        ),
.axi_arsize_o           (axi_arsize_o        ),
.axi_arlen_o            (axi_arlen_o         ),
.axi_arburst_o          (axi_arburst_o       ),
.axi_arqos_o            (axi_arqos_o         ),
.axi_arid_o             (axi_arid_o          ),

//SIGNALS FROM CSR
.cfg_arlen              (cfg_arlen           ),
.cfg_arburst            (cfg_arburst         ),
.cfg_arsize             (cfg_arsize          ),
.cfg_arid               (cfg_arid            ),
.cfg_fixed_araddr       (cfg_fixed_araddr    ),
.cfg_rd_addr_seed       (cfg_rd_addr_seed    ),
.cfg_rd_data_seed_1     (cfg_rd_data_seed_1  ),
.cfg_rd_data_seed_2     (cfg_rd_data_seed_2  ),
.cfg_num_of_rd_trans    (cfg_num_of_rd_trans ),
.cfg_randomize_rdaddr   (cfg_randomize_rdaddr),
.cfg_randomize_rdctrl   (cfg_randomize_rdctrl),
.cfg_rd_txn_delay       (cfg_rd_txn_delay    ),
.rd_start               (rd_start            ),

//SIGNALS TO CSR
.rd_txn_done            (rd_txn_done    ),
.rd_error               (rd_error       ),
.num_of_rd_trans        (num_of_rd_trans)

);

assign a_rd_err_o = rd_error;

lscc_axi4_m_csr
#(
  .GEN_IN_WIDTH  (GEN_IN_WIDTH  ),
  .APB_ADDR_WIDTH(APB_ADDR_WIDTH),
  .APB_DATA_WIDTH(APB_DATA_WIDTH),
  .AXI_LEN_WIDTH (AXI_LEN_WIDTH ),
  .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
  .DDR_CMD_FREQ  (DDR_CMD_FREQ  ),
  .AXI_ID_WIDTH  (AXI_ID_WIDTH  )
)
u_axi_m_csr (  
  .pclk_i     (pclk_i     ),
  .preset_n_i (preset_n_i ),
  .aclk_i     (aclk_i     ),
  .areset_n_i (areset_n_i ),
  .gen_in_i   (gen_in_i   ),
  .a_gen_out_o(a_gen_out_o),
  .p_rd_error_occur_o(p_rd_error_occur_o),

  .apb_psel   (apb_psel_i      ),
  .apb_penable(apb_penable_i   ),
  .apb_pwrite (apb_pwrite_i    ),
  .apb_paddr  (apb_paddr_i     ),
  .apb_pwdata (apb_pwdata_i    ),
  .apb_pready (apb_pready_o    ),
  .apb_prdata (apb_prdata_o    ),
  .apb_pslverr(apb_pslverr_o   ),

  .cfg_awlen            (cfg_awlen            ),             
  .cfg_awburst          (cfg_awburst          ),
  .cfg_awsize           (cfg_awsize           ),            
  .cfg_awid             (cfg_awid             ),
  .cfg_wr_addr_seed     (cfg_wr_addr_seed     ),
  .cfg_wr_data_seed_1   (cfg_wr_data_seed_1   ),    
  .cfg_wr_data_seed_2   (cfg_wr_data_seed_2   ),    
  .cfg_num_of_wr_trans  (cfg_num_of_wr_trans  ),   
  .cfg_randomize_wraddr (cfg_randomize_wraddr ), 
  .cfg_randomize_wrctrl (cfg_randomize_wrctrl ), 
  .cfg_wr_txn_delay     (cfg_wr_txn_delay     ),      
  .wr_start             (wr_start             ),

  .cfg_arlen            (cfg_arlen            ),             
  .cfg_arburst          (cfg_arburst          ),           
  .cfg_arsize           (cfg_arsize           ),
  .cfg_arid             (cfg_arid             ),
  .cfg_fixed_araddr     (cfg_fixed_araddr     ),
  .cfg_rd_addr_seed     (cfg_rd_addr_seed     ),      
  .cfg_rd_data_seed_1   (cfg_rd_data_seed_1   ),    
  .cfg_rd_data_seed_2   (cfg_rd_data_seed_2   ),    
  .cfg_num_of_rd_trans  (cfg_num_of_rd_trans  ),   
  .cfg_randomize_rdaddr (cfg_randomize_rdaddr ), 
  .cfg_randomize_rdctrl (cfg_randomize_rdctrl ), 
  .cfg_rd_txn_delay     (cfg_rd_txn_delay     ),      
  .rd_start             (rd_start             ),          

  .wr_txn_done           (wr_txn_done    ), //after the num_of_wr_trans is acheived 
  .rd_txn_done           (rd_txn_done    ), //after the num_of_rd_trans is acheived
  .rd_error              (rd_error       ),
  .total_num_wr_rd_i     (total_num_wr_rd    ),
  .duration_cntr_status_aclk_i(duration_cntr_status_aclk ),
  .duration_cntr_status_sclk_i(duration_cntr_status_sclk ),
  .rd_txn_cnt            (num_of_rd_trans)
);

lscc_axi4_perf_calc
 #(
   .DATA_CLK_EN    (DATA_CLK_EN   ),
   .AXI_DATA_WIDTH (AXI_DATA_WIDTH)
  )
u_axi_perf_calc (
  .aclk_i                   (aclk_i               ),
  .areset_n_i               (areset_n_i           ),
  .sclk_i                   (sclk_i               ),
  .rstn_i                   (rstn_i               ),
  .wr_start                 (wr_start             ),           
  .axi_wready_i             (axi_wready_i         ),
  .axi_wvalid_i             (axi_wvalid_o         ),
  .wr_txn_done              (wr_txn_done          ), //after the num_of_wr_trans is acheived 
  .rd_txn_done              (rd_txn_done          ), //after the num_of_rd_trans is acheived
  //.axi_wstrb_i              (axi_wstrb_i          ),
  .axi_awvalid_i            (axi_awvalid_o        ),
  .axi_arvalid_i            (axi_arvalid_o        ),
  .axi_rvalid_i             (axi_rvalid_i         ), 
  .axi_rready_o             (axi_rready_o         ),
  .duration_cntr_status_aclk_o   (duration_cntr_status_aclk ),
  .duration_cntr_status_sclk_o   (duration_cntr_status_sclk ),
  .total_num_wr_rd_o        (total_num_wr_rd      ) 
);
endmodule
