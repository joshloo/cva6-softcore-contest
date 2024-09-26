// =============================================================================
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
// -----------------------------------------------------------------------------
//   Copyright (c) 2019 by Lattice Semiconductor Corporation
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
// File                  : eval_top.v
// Title                 :
// Dependencies          :
// Description           : Evaluation top level design for MC_Avant
// =============================================================================
//                        REVISION HISTORY
// Version               : 1.0.0.
// Author(s)             :
// Mod. Date             : 
// Changes Made          : Initial release.
// =============================================================================
`define LPDDR4
//`define RVL_DBG_EN

`include "kitcar.v"
`include "apb2init.sv"
`include "async_reset_sync_deassert.v"
`include "traffic_gen/ctrl_fifo.v"
`include "traffic_gen/lscc_lfsr.v"
`include "traffic_gen/lscc_axi4_m_csr.sv"
`include "traffic_gen/lscc_axi4_m_rd.sv"
`include "traffic_gen/lscc_axi4_m_wr.sv"
`include "traffic_gen/lscc_axi4_perf_calc.sv"
`include "traffic_gen/lscc_axi4_traffic_gen.sv"
`include "traffic_gen/ahbl0.v" 
`include "traffic_gen/ahbl2apb0.v"
`include "traffic_gen/apb0.v"
`include "traffic_gen/cpu0.v"
`include "traffic_gen/gpio0.v"
`include "traffic_gen/lscc_osc.v"
`include "traffic_gen/memc_apb.v"
`include "traffic_gen/osc0.v"
`include "traffic_gen/eval_mem0.v"
`include "traffic_gen/eval_mem0_sim.v"
`include "traffic_gen/sysmem0.v"
`include "traffic_gen/uart0.v"
`include "traffic_gen/mc_axi4_traffic_gen.v"
`include "axi_bridge/lpddr4_mc_async_fifo.v"
`include "axi_bridge/lscc_fifo_fwft.v"
`include "axi_bridge/lpddr4_mc_sync_fifo.v"
`include "axi_bridge/lpddr4_mc_axi_slv_wr.sv"
`include "axi_bridge/lpddr4_mc_axi_slv_rd.sv"
`include "axi_bridge/lpddr4_mc_axi_slv_rd_rsp.sv"
`include "axi_bridge/lpddr4_mc_axi_iface_top.sv"

`include "pll0.v"

module eval_top #(
  parameter SIM = 0  // 0: Implementation, 1: Simulation
)(
    // inputs
    rstn_i        ,     // from SW1 pushbutton
    pll_refclk_i  ,     // 100MHz
    uart_rxd_i    ,
    // output
    uart_txd_o    ,
    LED           ,     // to LEDs (LED0-9)
    sim_o         ,     // SIM paramter value to tb_top
    // for PLL lock checking
    mc_pll_lock_o  ,
    eval_pll_lock_o,
    sclk          ,
    pclk          ,
    test_port     ,
    test_port_rd  ,
    test_port_wr  ,
  
    ddr_ck_o      , 
    ddr_cke_o     ,
    ddr_cs_o      ,
    ddr_ca_o      ,
`ifdef DDR4
    ddr_we_n_o    , 
    ddr_cas_n_o   , 
    ddr_ras_n_o   , 
    ddr_act_n_o   , 
    ddr_ba_o      , 
    ddr_bg_o      , 
    ddr_odt_o     ,
`endif
    ddr_reset_n_o , 
    ddr_dq_io     ,
    ddr_dqs_io    , 
    ddr_dmi_io    
);

`include "dut_params.v"

localparam  GEN_OUT_WIDTH = 5;
localparam  NARROW_AXI4_DATA  = AXI_DATA_WIDTH < (DDR_WIDTH<<3) ? 1:0; 
localparam  [8:0] TRN_OP_SIM  = (INTERFACE_TYPE == "LPDDR4") ? 9'h01E : 9'h01C;
//-----------------------------------------------------------------------------
//                                                                          --
//                      PORT DEFINITION
//                                                                          --
//----------------------------------------------------------------------------

output wire                    mc_pll_lock_o       ;
output wire                    eval_pll_lock_o     ;

input   wire                   rstn_i                ;     // from SW1 pushbutton
input   wire                   pll_refclk_i        ;     //100MHz since fs=3'b001 // from 125MHz Clk
input   wire                   uart_rxd_i          ;
                                                                                      
// outputs
output  wire                   uart_txd_o          ;
inout         [11:0]           LED                 ;     // to LEDs (LED0-9)
output                         sim_o               ;

//output  reg                    irq_out             ;
output wire                    sclk                ;
output wire                    pclk                ;
output wire                    test_port           ;
output logic                   test_port_rd        ;
output logic                   test_port_wr        ;

output       [CK_WIDTH-1:0]    ddr_ck_o            ; 
output       [CS_WIDTH-1:0]    ddr_cke_o           ;
output       [CS_WIDTH-1:0]    ddr_cs_o            ;
output       [CA_WIDTH-1:0]    ddr_ca_o            ;
//output                         ddr_odt_ca_o        ;
`ifdef DDR4
output                         ddr_we_n_o          ; 
output                         ddr_cas_n_o         ; 
output                         ddr_ras_n_o         ; 
output                         ddr_act_n_o         ; 
output       [BANK_WIDTH-1:0]  ddr_ba_o            ; 
output       [BG_WIDTH-1:0]    ddr_bg_o            ; 
output       [CS_WIDTH-1:0]    ddr_odt_o           ; 
`endif
output                         ddr_reset_n_o       ; 
inout        [BUS_WIDTH -1 :0] ddr_dq_io           ;
inout        [DQS_WIDTH -1:0]  ddr_dqs_io          ; 
inout        [DQS_WIDTH -1:0]  ddr_dmi_io          ;

//------------------------------
// INTERNAL SIGNAL DECLARATIONS: 
//------------------------------
// parameters (constants)

// wires (assigns)
wire          eval_pll_lock;

wire    [7:0] LED_array;  
wire    [7:0] LED_array2; 
wire    [9:0] led_o;

wire                       aclk_i       ;
wire                       pll_rst_n_i ;
wire                       rst_n_i     ;
wire                       pclk_i      ;
wire                       preset_n_i  ;
wire                       pll_lock_o  ; 
wire                       sclk_o      ; 
wire                       irq_o       ; 
//wire                       init_done_o ; 
wire                       a_rd_timeout_o    ;
wire                       a_wr_timeout_o    ;
wire                       a_rd_err_o        ;
wire                       p_rd_error_occur_o;

wire                       apb_penable_i ; 
wire                       apb_psel_i    ; 
wire                       apb_pwrite_i  ; 
wire  [APB_ADDR_WIDTH-1:0] apb_paddr_i   ; 
wire  [APB_DATA_WIDTH-1:0] apb_pwdata_i  ; 
wire                       apb_pready_o  ; 
wire                       apb_pslverr_o ; 
wire  [APB_DATA_WIDTH-1:0] apb_prdata_o  ; 

wire                        rstn_w          ;
wire                        prst_n          ;
wire                        arst_n          ;
wire                        arst2_n         ;
wire                        srst_n          ;


logic                         clk_w      ;
logic                         areset_n_i  ;
// Added syn_keep for easier debugging in post-Synthesis netlist
logic                         axi_arvalid_i  /* synthesis syn_keep=1 */; 
logic [AXI_ID_WIDTH-1 : 0]    axi_arid_i     /* synthesis syn_keep=1 */;
logic [AXI_LEN_WIDTH-1 : 0]   axi_arlen_i    /* synthesis syn_keep=1 */;
logic [1:0]                   axi_arburst_i  /* synthesis syn_keep=1 */;
logic [AXI_ADDR_WIDTH -1 : 0] axi_araddr_i   /* synthesis syn_keep=1 */;
logic                         axi_arready_o  /* synthesis syn_keep=1 */;
logic [AXI_QOS_WIDTH - 1:0]   axi_arqos_i    /* synthesis syn_keep=1 */;
logic [2:0]                   axi_arsize_i   /* synthesis syn_keep=1 */;
logic [1:0]                   axi_rresp_o    /* synthesis syn_keep=1 */;
logic [AXI_ID_WIDTH - 1: 0]   axi_rid_o      /* synthesis syn_keep=1 */;
logic [AXI_DATA_WIDTH - 1: 0] axi_rdata_o    /* synthesis syn_keep=1 */;
wire                          axi_rvalid_o   /* synthesis syn_keep=1 */;
logic                         axi_rlast_o    /* synthesis syn_keep=1 */;
logic                         axi_rready_i   /* synthesis syn_keep=1 */;
logic                         axi_bready_i   /* synthesis syn_keep=1 */; 
logic                         axi_bvalid_o   /* synthesis syn_keep=1 */;
logic [1:0]                   axi_bresp_o    /* synthesis syn_keep=1 */; 
logic [AXI_ID_WIDTH-1 : 0]    axi_bid_o      /* synthesis syn_keep=1 */;
logic                         axi_awvalid_i  /* synthesis syn_keep=1 */;
logic [AXI_ID_WIDTH-1 : 0]    axi_awid_i     /* synthesis syn_keep=1 */;
logic [AXI_LEN_WIDTH - 1: 0]  axi_awlen_i    /* synthesis syn_keep=1 */;
logic  [1:0]                  axi_awburst_i  /* synthesis syn_keep=1 */;
logic  [2:0]                  axi_awsize_i   /* synthesis syn_keep=1 */;
logic [AXI_ADDR_WIDTH -1 : 0] axi_awaddr_i   /* synthesis syn_keep=1 */;
logic                         axi_awready_o  /* synthesis syn_keep=1 */;
logic [AXI_QOS_WIDTH - 1:0]   axi_awqos_i    /* synthesis syn_keep=1 */;
logic                         axi_wvalid_i   /* synthesis syn_keep=1 */;
logic                         axi_wready_o   /* synthesis syn_keep=1 */;
logic [AXI_DATA_WIDTH - 1: 0] axi_wdata_i    /* synthesis syn_keep=1 */;
logic [AXI_DATA_WIDTH/8 -1:0] axi_wstrb_i    /* synthesis syn_keep=1 */;
logic                         axi_wlast_i    /* synthesis syn_keep=1 */;

logic                              wr_req_ready_o   ;
logic                              wr_req_valid_i   ;
logic [AXI_ID_WIDTH-1:0]           wr_req_id_i      ;
logic [ORDER_ID_WIDTH-1:0]         wr_req_order_id_i;
logic [AXI_ADDR_WIDTH-1:0]         wr_req_addr_i    ;
logic [AXI_LEN_WIDTH:0]            wr_req_len_i     ;
logic [2:0]                        wr_req_size_i    ;
logic                              wr_ready_o       ;
logic                              wr_valid_i       ;
logic [BI_RD_DATA_Q_WIDTH-1:0]     wr_data_i        ;
logic [(BI_RD_DATA_Q_WIDTH/8)-1:0] wr_byte_en_i     ;
logic                              wr_be_hole_i     ;
logic                              wr_data_last_i   ;
logic                              rd_req_ready_o   ;
logic                              rd_req_valid_i   ; 
logic [AXI_ID_WIDTH-1:0]           rd_req_id_i      ;
logic [ORDER_ID_WIDTH-1:0]         rd_req_order_id_i;
logic [AXI_ADDR_WIDTH-1:0]         rd_req_addr_i    ;
logic [AXI_LEN_WIDTH:0]            rd_req_len_i     ;
logic [2:0]                        rd_req_size_i    ;
logic                              rd_rsp_ready_i   ;
logic                              rd_rsp_valid_o   ;
logic                              rd_rsp_rlast_o   ;
logic [AXI_ID_WIDTH-1:0]           rd_rsp_rid_o     ;
//logic [ORDER_ID_WIDTH-1:0]       rd_rsp_order_id_o;
logic [BI_RD_DATA_Q_WIDTH -1 :0]   rd_rsp_data_o    ;
//logic [AXI_LEN_WIDTH-1:0]        rd_rsp_len_o     ;
//logic [3-1:0]                    rd_rsp_size_o    ;
//logic [7:0]                      rd_rsp_buff_addr_o;

logic       init_start_i;
logic [8:0] trn_opr_i   ;
logic       init_done_o ;
logic       trn_err_o   ;
logic [GEN_OUT_WIDTH-1:0] a_test_num_w;
logic [GEN_OUT_WIDTH-1:0] p_gen_out_o;
logic                     a_rd_error_occur_r;
logic                     s_rd_error_occur_r1/* synthesis syn_preserve=1 CDC_Register=2 */;
logic                     s_rd_error_occur_r2;
logic [GEN_OUT_WIDTH-2:0] s_test_num_r1     /* synthesis syn_preserve=1 CDC_Register=2 */;
logic [GEN_OUT_WIDTH-2:0] s_test_num_r2;
logic [GEN_OUT_WIDTH-2:0] rvl_s_test_num_r;

logic [GEN_OUT_WIDTH-2:0] rvl_a_test_num_r;
logic [GEN_OUT_WIDTH-2:0] p_test_num_r     /* synthesis syn_preserve=1 */;
logic [GEN_OUT_WIDTH-2:0] rvl_p_test_num_r;
logic                     rvl_s_rd_error_occur_r;

logic                     dbg_wrdata_en_p0_o;
logic                     dbg_rddata_en_p0_o;
logic                     test_port_rd_r;
logic                     test_port_wr_r;
logic                     rst_ctrl;


//-------------------------------------//
//-- assign (non-process) operations --//
//-------------------------------------//
assign pll_rst_n_i = rstn_w   ; 
assign rst_n_i     = rstn_w & ~rst_ctrl  ; 
assign preset_n_i  = prst_n   ; 
assign pclk        = pclk_i     ; // for probing
//assign test_port   = init_done_o; // for probing
assign sim_o           = SIM[0]   ; // tell tb_top if SIM parameter is set
assign mc_pll_lock_o   = pll_lock_o;
assign eval_pll_lock_o = eval_pll_lock;

generate
  if (DATA_CLK_EN) begin : ASYNC_AXI
    assign clk_w   = aclk_i;
  end
  else begin : SYNC_AXI
    assign clk_w   = sclk_o;  
  end
endgenerate

//assign areset_n_i   = arst_n;

always @(posedge pclk_i) begin
  rst_ctrl  <= p_gen_out_o[GEN_OUT_WIDTH-1];
end 

// Synchronize the reset to PCLK on the I/O side
async_reset_sync_deassert #(
  .ACTIVE_LVL(0),
  .RST_STAGES(3)
)
u_p0rstn (
  .clk_i(pclk_i),
  .rst_i(rstn_i),
  .rst_o(rstn_w)
);

async_reset_sync_deassert #(
  .ACTIVE_LVL(0),
  .RST_STAGES(3)
)
u_prstn (
  .clk_i(pclk_i),
  .rst_i(rstn_w),
  .rst_o(prst_n)
);

async_reset_sync_deassert #(
  .ACTIVE_LVL(0),
  .RST_STAGES(3)
)
u_arstn (
  .clk_i(clk_w ),
  .rst_i(rstn_w),
  .rst_o(arst_n)
);

async_reset_sync_deassert #(
  .ACTIVE_LVL(0),
  .RST_STAGES(3)
)
u_a1rstn (
  .clk_i(clk_w     ),
  .rst_i(rstn_w    ),
  .rst_o(areset_n_i)
);

async_reset_sync_deassert #(
  .ACTIVE_LVL(0),
  .RST_STAGES(3)
)
u_a2rstn (
  .clk_i(clk_w  ),
  .rst_i(rstn_w ),
  .rst_o(arst2_n)
);

async_reset_sync_deassert #(
  .ACTIVE_LVL(0),
  .RST_STAGES(3)
)
u_srstn (
  .clk_i(sclk_o),
  .rst_i(rstn_w),
  .rst_o(srst_n)
);

//--------------------------------------------------------------------
//--  module instances
//--------------------------------------------------------------------
// David added
pll0 u_pll0 (
        .clki_i (osc_clk_100  ), 
        .rstn_i (rstn_i       ), 
        .clkop_o(aclk_i       ), 
        .clkos_o(pclk_i       ), 
        .lock_o (eval_pll_lock));
        
osc0 osc_int_inst (
    .en_i      (1'b1   ), 
    .clk_sel_i (1'b0   ), 
    //.clk_out_o (pclk_i));
    .clk_out_o (osc_clk_100));
    
    
// for checking that the AXI clock is running
kitcar #(
    .clk_freq   (27000000 ))
kitcar_inst (
    .clk        (clk_w    ),
    .rstn       (arst2_n  ),
    .LED_array  (LED_array)
);

// for checking that the pclk_i clock is running
kitcar #(
    .clk_freq   (27000000 ))
kitcar_inst2 (
    .clk        (pclk_i    ),
    .rstn       (preset_n_i),
    .LED_array  (LED_array2)
);


// for observing sclk_o - skwong2 9/6/2022
ODDRX1A #(
    .GSR("DISABLED")) 
u_oddrx1 (
    .D0(1'b0),//data_gnd), 
    .D1(1'b1),//data_vccio), 
    .SCLK(sclk_o), 
    .RST(1'b0), 
    .Q(sclk)
);


logic [5:0]  gen_in_w;
logic [1:0]  max_burst_len;
logic        perf_tst_en;
logic        s2p_r1_trn_done/* synthesis syn_preserve=1 CDC_Register=2 */;
logic        s2p_r2_trn_done;
logic        s2p_r1_trn_err/* synthesis syn_preserve=1 CDC_Register=2 */;
logic        s2p_r2_trn_err;
logic [11:0] apb_paddr_o; 
assign max_burst_len = (MAX_BURST_LEN == 64) ? 2'h0 : 
                       (MAX_BURST_LEN == 128) ? 2'h1 : 2'h2;

assign perf_tst_en = SIM ? 1'b0 : 1'b1;
assign gen_in_w    = {max_burst_len,s2p_r2_trn_err, perf_tst_en,s2p_r2_trn_done, irq_o};
assign apb_paddr_i = apb_paddr_o[APB_ADDR_WIDTH-1:0];

always @(posedge pclk_i or negedge preset_n_i) begin
   if (!preset_n_i) begin
       s2p_r1_trn_done <= 1'b0;
       s2p_r2_trn_done <= 1'b0;
       s2p_r1_trn_err  <= 1'b0;
       s2p_r2_trn_err  <= 1'b0;
   end
   else begin
       s2p_r1_trn_done <= init_done_o;
       s2p_r2_trn_done <= s2p_r1_trn_done;
       s2p_r1_trn_err  <= trn_err_o;
       s2p_r2_trn_err  <= s2p_r1_trn_err;
   end
end

mc_axi4_traffic_gen #(
    .SIM           (SIM             ),
    .GEN_IN_WIDTH  (6               ),
    .GEN_OUT_WIDTH (GEN_OUT_WIDTH   ),
    .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH  ),
    .AXI_DATA_WIDTH(AXI_DATA_WIDTH  ),
    .AXI_ID_WIDTH  (AXI_ID_WIDTH    ),
    .AXI_LEN_WIDTH (AXI_LEN_WIDTH   ),
    .TIMEOUT_VALUE (800             ),  // added for timeout detection
    .TIMEOUT_WIDTH (12               ),   // added for timeout detection
    .DDR_CMD_FREQ  (CLK_FREQ        ), 
    .DATA_CLK_EN   (DATA_CLK_EN     )
) u_tragen (
    .aclk_i        (clk_w         ),
    .areset_n_i    (arst_n        ),
    .pclk_i        (pclk_i        ),
    .preset_n_i    (preset_n_i    ),
    .sclk_i        (sclk_o),
    .rstn_i        (srst_n        ),
    .rxd_i         (uart_rxd_i    ), 
    .txd_o         (uart_txd_o    ), 
    .led_o         (led_o         ),
    .a_rd_timeout_o(a_rd_timeout_o),
    .a_wr_timeout_o(a_wr_timeout_o),
    .a_rd_err_o    (a_rd_err_o    ),
    .p_rd_error_occur_o(p_rd_error_occur_o),
    .a_test_num_o  (a_test_num_w),
    .p_gen_out_o  (p_gen_out_o  ),
    .gen_in_i     (gen_in_w     ),
    .apb_psel_o   (apb_psel_i   ),   
    .apb_paddr_o  (apb_paddr_o  ), 
    .apb_penable_o(apb_penable_i), 
    .apb_pwrite_o (apb_pwrite_i ),
    .apb_pwdata_o (apb_pwdata_i ), 
    .apb_pready_i (apb_pready_o ), 
    .apb_prdata_i (apb_prdata_o ), 
    .apb_pslverr_i(apb_pslverr_o),

    .axi_awready_i(axi_awready_o),
    .axi_awvalid_o(axi_awvalid_i),
    .axi_awid_o   (axi_awid_i   ),
    .axi_awaddr_o (axi_awaddr_i ),
    .axi_awlen_o  (axi_awlen_i  ),
    .axi_awburst_o(axi_awburst_i),
    .axi_awqos_o  (axi_awqos_i  ), 
    .axi_awsize_o (axi_awsize_i ),

    .axi_wvalid_o (axi_wvalid_i ), 
    .axi_wready_i (axi_wready_o ),
    .axi_wdata_o  (axi_wdata_i  ), 
    .axi_wstrb_o  (axi_wstrb_i  ), 
    .axi_wlast_o  (axi_wlast_i  ),
    
    .axi_bready_o (axi_bready_i ), 
    .axi_bvalid_i (axi_bvalid_o ),  
    .axi_bresp_i  (axi_bresp_o  ),  
    .axi_bid_i    (axi_bid_o    ),
    
    .axi_arready_i(axi_arready_o),  
    .axi_arvalid_o(axi_arvalid_i),  
    .axi_arid_o   (axi_arid_i   ),  
    .axi_arlen_o  (axi_arlen_i  ),  
    .axi_arburst_o(axi_arburst_i),  
    .axi_araddr_o (axi_araddr_i ),  
    .axi_arqos_o  (axi_arqos_i  ),  
    .axi_arsize_o (axi_arsize_i ),  

    .axi_rready_o (axi_rready_i ),
    .axi_rvalid_i (axi_rvalid_o ),
    .axi_rdata_i  (axi_rdata_o  ),
    .axi_rresp_i  (axi_rresp_o  ),
    .axi_rid_i    (axi_rid_o    ),
    .axi_rlast_i  (axi_rlast_o  )
 );
 
generate 
  if (AXI == 0) begin : BRIDGE
    // AXI4 Interface module
    lddr4_mc_axi_iface_top #(
      .DDR_TYPE                (DDR_TYPE           ),
      .SCH_NUM_RD_SUPPORT      (SCH_NUM_RD_SUPPORTED),
      .SCH_NUM_WR_SUPPORT      (SCH_NUM_WR_SUPPORTED),
      .INT_ID_WIDTH            (ORDER_ID_WIDTH     ),
      .DDR_WIDTH               (DDR_WIDTH          ),
      .AXI_ADDR_WIDTH          (AXI_ADDR_WIDTH     ),
      .AXI_ID_WIDTH            (AXI_ID_WIDTH       ),
      .AXI_DATA_WIDTH          (AXI_DATA_WIDTH     ),
      .AXI_CTRL_WIDTH          (AXI_CTRL_WIDTH     ),
      .AXI_LEN_WIDTH           (AXI_LEN_WIDTH      ),
      .AXI_STRB_WIDTH          (AXI_STRB_WIDTH     ),
      .AXI_QOS_WIDTH           (AXI_QOS_WIDTH      ),
      .BI_RD_DATA_Q_WIDTH      (BI_RD_DATA_Q_WIDTH ),
      .BI_RD_DATA_Q_DEPTH      (BI_RD_DATA_Q_DEPTH ),
      .DATA_CLK_EN             (DATA_CLK_EN        )
      //.NARROW_WIDTH            (NARROW_AXI4_DATA   )
    )
    u_axi_if (
      .clk_i             (sclk_o       ), // Native I/F is only Sync, No CDC
      .sclk_i            (sclk_o       ),
      .rst_n_i           (arst_n       ), // Sync to sclk_o when DATA_CLK_EN=0
      .srst_n_i          (arst_n       ), // Sync to sclk_o when DATA_CLK_EN=0
      //AXI4 INTERFACE
      .axi_arvalid_i     (axi_arvalid_i), 
      .axi_arid_i        (axi_arid_i   ),
      .axi_arlen_i       (axi_arlen_i  ),
      .axi_arburst_i     (axi_arburst_i),
      .axi_araddr_i      (axi_araddr_i ),
      .axi_arready_o     (axi_arready_o),
      .axi_arqos_i       (axi_arqos_i  ),
      .axi_arsize_i      (axi_arsize_i ),
      .axi_rresp_o       (axi_rresp_o  ),
      .axi_rdata_o       (axi_rdata_o  ),
      .axi_rid_o         (axi_rid_o    ),
      .axi_rvalid_o      (axi_rvalid_o ),
      .axi_rlast_o       (axi_rlast_o  ),
      .axi_rready_i      (axi_rready_i ),
      .axi_awvalid_i     (axi_awvalid_i),
      .axi_awlen_i       (axi_awlen_i  ),
      .axi_awburst_i     (axi_awburst_i),
      .axi_awaddr_i      (axi_awaddr_i ),
      .axi_awready_o     (axi_awready_o),
      .axi_awqos_i       (axi_awqos_i  ),
      .axi_awsize_i      (axi_awsize_i ), 
      .axi_awid_i        (axi_awid_i   ),
      .axi_wvalid_i      (axi_wvalid_i ),
      .axi_wready_o      (axi_wready_o ),
      .axi_wdata_i       (axi_wdata_i  ),
      .axi_wstrb_i       (axi_wstrb_i  ),      
      .axi_wlast_i       (axi_wlast_i  ), 
      .axi_bready_i      (axi_bready_i ),
      .axi_bvalid_o      (axi_bvalid_o ),
      .axi_bresp_o       (axi_bresp_o  ),
      .axi_bid_o         (axi_bid_o    ),
      //NATIVE INTERFACE 
      .wr_req_txn_id_o   ({wr_req_id_i,wr_req_order_id_i}),
      .wr_req_addr_o     (wr_req_addr_i     ),
      .wr_req_len_o      (wr_req_len_i      ),
      .wr_req_size_o     (wr_req_size_i     ),
      .wr_req_valid_o    (wr_req_valid_i    ),
      .wr_req_ready_i    (wr_req_ready_o    ),
      .wr_data_o         (wr_data_i         ),
      .wr_byte_en_o      (wr_byte_en_i      ),
      .wr_be_hole_o      (wr_be_hole_i      ),
      .wr_last_o         (wr_data_last_i    ),
      .wr_valid_o        (wr_valid_i        ),
      .wr_ready_i        (wr_ready_o        ),
      .rd_req_valid_o    (rd_req_valid_i    ),
      .rd_req_addr_o     (rd_req_addr_i     ),
      .rd_req_len_o      (rd_req_len_i      ),
      .rd_req_size_o     (rd_req_size_i     ),
      .rd_req_arid_o     ({rd_req_id_i,rd_req_order_id_i}),
      .rd_req_ready_i    (rd_req_ready_o    ),
      .rd_rsp_rid_i      ({rd_rsp_rid_o}    ),
      .rd_rsp_data_i     (rd_rsp_data_o     ),
//      .rd_rsp_len_i      (rd_rsp_len_o      ),
//      .rd_rsp_size_i     (rd_rsp_size_o     ),
//      .rd_rsp_addr_i     (rd_rsp_buff_addr_o),
      .rd_rsp_valid_i    (rd_rsp_valid_o    ),
      .rd_rsp_rlast_i    (rd_rsp_rlast_o    ),
      .rd_rsp_ready_o    (rd_rsp_ready_i    )
    );
  end // BRIDGE
  
  if (APB_INTF_EN == 0) begin : INIT_EN
    apb2init #(
      .DDR_TYPE      (DDR_TYPE      ),
      .GEAR_RATIO    (GEAR_RATIO    ),
      .PWR_DOWN_EN   (PWR_DOWN_EN   ),
      .DBI_ENABLE    (DBI_ENABLE    ),
      .ECC_ENABLE    (0             ),
      .DDR_WIDTH     (DDR_WIDTH     ),
      .RANK_WIDTH    (RANK_WIDTH    ), 
      .APB_DATA_WIDTH(APB_DATA_WIDTH),
      .SIM           (SIM           )
    )
    u_apb2init (
      .pclk_i        (pclk_i          ),
      .preset_n_i    (preset_n_i      ),
      .sclk_i        (sclk_o          ),
      .p_trn_done_i  (s2p_r2_trn_done ),
      .s_init_start_o(init_start_i    ),
      .apb_penable_i (apb_penable_i   ), 
      .apb_psel_i    (apb_psel_i      ), 
      .apb_pwrite_i  (apb_pwrite_i    ), 
      .apb_paddr_i   (apb_paddr_i[9:0]), 
      .apb_pwdata_i  (apb_pwdata_i    ), 
      .apb_pready_o  (apb_pready_o    ), 
      .apb_prdata_o  (apb_prdata_o    ),
      .apb_pslverr_o (apb_pslverr_o   )
    );
    //assign trn_opr_i = SIM ? 8'h1E : 8'h1F
    assign trn_opr_i = SIM ? TRN_OP_SIM : ((CLK_FREQ > 1000) ?  9'h1DF : 9'h0DF);
  end // INIT_EN
  
endgenerate

logic a_rd_err_r /* synthesis syn_preserve=1 */;
logic a_rd_err_tg;
logic a2s_rd_err_tg_r1/* synthesis syn_preserve=1 CDC_Register=2 */;
logic a2s_rd_err_tg_r2;
logic a2s_rd_err_tg_r3;
logic s_rd_err_pulse_r;  // CDC-Style pulse

always_ff@(posedge clk_w or negedge arst_n) begin
  if (!arst_n) begin
    a_rd_err_r  <= 1'b0;
    a_rd_err_tg <= 1'b0;
  end
  else begin
    a_rd_err_r  <= a_rd_err_o;
    if (!a_rd_err_r && a_rd_err_o) // a_rd_err_o rise edge
      a_rd_err_tg <= ~a_rd_err_tg;
  end
end

always_ff@(posedge sclk_o or negedge srst_n) begin
  if (!srst_n) begin
    a2s_rd_err_tg_r1  <= 1'b0;
    a2s_rd_err_tg_r2  <= 1'b0;
    a2s_rd_err_tg_r3  <= 1'b0;
    s_rd_err_pulse_r  <= 1'b0;
  end
  else begin
    a2s_rd_err_tg_r1  <= a_rd_err_tg;
    a2s_rd_err_tg_r2  <= a2s_rd_err_tg_r1;
    a2s_rd_err_tg_r3  <= a2s_rd_err_tg_r2;
    if (s_rd_err_pulse_r)
      s_rd_err_pulse_r <= 1'b0;
    else
      s_rd_err_pulse_r <= a2s_rd_err_tg_r3 != a2s_rd_err_tg_r2;
  end
end




`ifdef RVL_DEBUG_EN
 logic                      rvl_wvalid_r0;
 logic                      rvl_wready_r0;
 logic                      rvl_awvalid_r0;
 logic [AXI_DATA_WIDTH-9:0] rvl_wdata_r0 ;  // reduced logic to fit in reveal
 logic                      rvl_rvalid_r0;
 logic                      rvl_rready_r0;
 logic                      rvl_arvalid_r0;
 logic [AXI_DATA_WIDTH-9:0] rvl_rdata_r0 ;  // reduced logic to fit in reveal


 logic                      rvl_wvalid_r;
 logic                      rvl_wready_r;
 logic [AXI_DATA_WIDTH-9:0] rvl_wdata_r ;  // reduced logic to fit in reveal
 logic                      rvl_awvalid_r;
 logic                      rvl_rvalid_r;
 logic                      rvl_rready_r;
 logic [AXI_DATA_WIDTH-9:0] rvl_rdata_r ;  // reduced logic to fit in reveal
 logic                      rvl_arvalid_r;


 logic [31:0]               scratch_0_o;
 logic [31:0]               scratch_1_o;


// no reset since this will be captured tousand cycles after reset
// doube FF so that this can be placed farther
always_ff@(posedge clk_w) begin
    rvl_wvalid_r0  <= axi_wvalid_i;
    rvl_wready_r0  <= axi_wready_o;
    rvl_wdata_r0   <= axi_wdata_i ;
    rvl_rvalid_r0  <= axi_rvalid_o;
    rvl_rready_r0  <= axi_rready_i;
    rvl_rdata_r0   <= axi_rdata_o ;
        rvl_awvalid_r0 <= axi_awvalid_i;    
        rvl_arvalid_r0 <= axi_arvalid_i;

    rvl_wvalid_r   <= rvl_wvalid_r0;
    rvl_wready_r   <= rvl_wready_r0;
    rvl_wdata_r    <= rvl_wdata_r0 ;
    rvl_rvalid_r   <= rvl_rvalid_r0;
    rvl_rready_r   <= rvl_rready_r0;
    rvl_rdata_r    <= rvl_rdata_r0 ;
    rvl_awvalid_r  <= rvl_awvalid_r0;
    rvl_arvalid_r  <= rvl_arvalid_r0;
end

logic p2s_rd_error_occur_r1;
logic p2s_rd_error_occur_r2;
logic p2s_rd_error_occur_r3;
logic a2s_rd_timeout_r1    ;
logic a2s_rd_timeout_r2    ;
logic a2s_rd_timeout_r3    ;
logic a2s_wr_timeout_r1    ;
logic a2s_wr_timeout_r2    ;
logic a2s_wr_timeout_r3    ;
logic        trig_r1;
logic        trig_r2;
logic        trig_r3;
logic rvl_rd_err_pulse_r   ;
logic rvl_rd_err_r1        ;
logic rvl_rd_err_r2        ;
logic rvl_rd_err_r3        ;

always @(posedge sclk_o) begin  // no need for reset, this is stable when capturing
       p2s_rd_error_occur_r1 <= p_rd_error_occur_o   ;
       p2s_rd_error_occur_r2 <= p2s_rd_error_occur_r1;
       p2s_rd_error_occur_r3 <= p2s_rd_error_occur_r2;
       a2s_rd_timeout_r1     <= a_rd_timeout_o       ;
       a2s_rd_timeout_r2     <= a2s_rd_timeout_r1    ;
       a2s_rd_timeout_r3     <= a2s_rd_timeout_r2    ;
       a2s_wr_timeout_r1     <= a_wr_timeout_o       ;
       a2s_wr_timeout_r2     <= a2s_wr_timeout_r1    ;
       a2s_wr_timeout_r3     <= a2s_wr_timeout_r2    ;
       rvl_rd_err_pulse_r    <= s_rd_err_pulse_r     ;
       rvl_rd_err_r1         <= a_rd_err_r           ;
       rvl_rd_err_r2         <= rvl_rd_err_r1        ;
       rvl_rd_err_r3         <= rvl_rd_err_r2        ;
end

always @(posedge pclk_i or negedge preset_n_i) begin
   if (!preset_n_i) begin
       trig_r1         <= 1'b0;
       trig_r2         <= 1'b0;
       trig_r3         <= 1'b0;
       p_test_num_r    <= {(GEN_OUT_WIDTH-1){1'b0}};
       rvl_p_test_num_r<= {(GEN_OUT_WIDTH-1){1'b0}};
   end
   else begin
       trig_r1         <= scratch_1_o[7:0] == 8'h12;
       trig_r2         <= trig_r1;
       trig_r3         <= trig_r2;
       p_test_num_r    <= p_gen_out_o[GEN_OUT_WIDTH-2:0];
       rvl_p_test_num_r<= p_test_num_r;
   end
end
assign test_port   = trig_r3    ; // for probing specific training state
`endif

`include "dut_inst.v"

//-------------------------------------//
//-------- output assignments  --------//
//-------------------------------------//

assign LED[11:0]    = {~LED_array2[0],~LED_array[0], led_o[9:0]};
//assign ddr_odt_ca_o = 1'b0;  // unused because we use implicit ODT
//--------------------------------------------//
//-------- for debugging with Reveal  --------//
//--------------------------------------------//

always @(posedge clk_w or negedge arst_n) begin
   if (!arst_n) begin
       rvl_a_test_num_r   <= {(GEN_OUT_WIDTH-1){1'b0}};
       a_rd_error_occur_r <= 1'b0;
   end
   else begin
       rvl_a_test_num_r   <= a_test_num_w[GEN_OUT_WIDTH-2:0];
       a_rd_error_occur_r <= a_rd_err_o;
   end
end

always @(posedge sclk_o or negedge srst_n) begin
   if (!srst_n) begin
       s_rd_error_occur_r1    <= 1'b0;
       s_rd_error_occur_r2    <= 1'b0;
       rvl_s_rd_error_occur_r <= 1'b0;
       s_test_num_r1          <= {(GEN_OUT_WIDTH-1){1'b0}};
       s_test_num_r2          <= {(GEN_OUT_WIDTH-1){1'b0}};
       rvl_s_test_num_r       <= {(GEN_OUT_WIDTH-1){1'b0}};
   end
   else begin
       s_rd_error_occur_r1    <= a_rd_error_occur_r;
       s_rd_error_occur_r2    <= s_rd_error_occur_r1;
       rvl_s_rd_error_occur_r <= s_rd_error_occur_r2;
       s_test_num_r1          <= p_test_num_r;
       s_test_num_r2          <= s_test_num_r1;
       rvl_s_test_num_r       <= s_test_num_r2;
   end
end

// Adding a trigger for capturing write/read on the DDR bus
logic init_done_r;
always @(posedge sclk_o or negedge srst_n) begin
   if (!srst_n) begin
       test_port_rd_r    <= 1'b0;
       test_port_wr_r    <= 1'b0;
       test_port_rd      <= 1'b0;
       test_port_wr      <= 1'b0;
       init_done_r       <= 1'b0;
   end
   else begin
       init_done_r       <= init_done_o;
       test_port_rd_r    <= dbg_rddata_en_p0_o & init_done_r;
       test_port_wr_r    <= dbg_wrdata_en_p0_o & init_done_r;
       test_port_rd      <= test_port_rd_r; // extra register is need to map to IO register
       test_port_wr      <= test_port_wr_r; // extra register is need to map to IO register
   end
end

endmodule
