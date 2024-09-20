`define LAV_AT

`ifdef LAV_AT
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
  `define MC_LAV_SUPPORTED

  `include "pll0.v"
  `include "kitcar.v"
  `include "apb2init.sv"
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
  `include "traffic_gen/eval_mem2.v"
  `include "traffic_gen/eval_mem3.v"
  `include "traffic_gen/eval_mem4.v"
  `include "traffic_gen/eval_mem2_sim.v"
  `include "traffic_gen/eval_mem3_sim.v"
  `include "traffic_gen/eval_mem4_sim.v"
  `include "traffic_gen/sysmem0_sim.v"
  `include "traffic_gen/uart0.v"
  `include "traffic_gen/mc_axi4_traffic_gen.v"
  `include "axi_bridge/lpddr4_mc_async_fifo.v"
  `include "axi_bridge/lscc_fifo_fwft.v"
  `include "axi_bridge/lpddr4_mc_sync_fifo.v"
  `include "axi_bridge/lpddr4_mc_axi_slv_wr.sv"
  `include "axi_bridge/lpddr4_mc_axi_slv_rd.sv"
  `include "axi_bridge/lpddr4_mc_axi_slv_rd_rsp.sv"
  `include "axi_bridge/lpddr4_mc_axi_iface_top.sv"
`ifdef MC_LAV_SUPPORTED
  `include "mc_lav.sv"
`endif

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
  //	irq_out       ,
      sclk          ,
    pclk          ,
    test_port     ,
      test_port_rd  ,
      test_port_wr  ,

      ddr_ck_o      ,
      ddr_cke_o     ,
      ddr_cs_o      ,
      ddr_ca_o      ,
      ddr_odt_ca_o  ,
      ddr_reset_n_o ,
      ddr_dq_io     ,
      ddr_dqs_io    ,
      ddr_dmi_io
  );
  `include "dut_params.v"
  `include "avant_mc_params.v"

  localparam  GEN_OUT_WIDTH = 4;
  localparam  NARROW_AXI4_DATA  = AXI_DATA_WIDTH < (DDR_WIDTH<<3) ? 1:0;
  //-----------------------------------------------------------------------------
  //                                                                          --
  //                      PORT DEFINITION
  //                                                                          --
  //----------------------------------------------------------------------------

  output wire                    mc_pll_lock_o       ;
  output wire                    eval_pll_lock_o     ;

  // input   wire                   clk_i               ;
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
  output       [5:0]             ddr_ca_o            ;
  output                         ddr_odt_ca_o        ;
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

  wire                       clk_i       ;
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

  reg                        prst_n          ;
  reg                        prst_n_r0       ;
  reg                        prst_n_r1       ;

  reg                        arst_n          ;
  reg                        arst_n_r0       ;
  reg                        arst_n_r1       ;

  reg                        srst_n          ;
  reg                        srst_n_r0       ;
  reg                        srst_n_r1       ;

  logic                         clk_w      ;
  logic                         reset_n_i  ;
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
  logic                         axi_rvalid_o   /* synthesis syn_keep=1 */;
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
  logic [AXI_LEN_WIDTH-1:0]          wr_req_len_i     ;
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
  logic [AXI_LEN_WIDTH-1:0]          rd_req_len_i     ;
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
  logic [GEN_OUT_WIDTH-1:0]  a_test_num_w;
  logic                     a_rd_error_occur_r;
  logic                     s_rd_error_occur_r1/* synthesis syn_preserve=1 CDC_Register=2 */;
  logic                     s_rd_error_occur_r2;

  logic [GEN_OUT_WIDTH-1:0] rvl_a_test_num_r;
  logic                     rvl_s_rd_error_occur_r;

  logic                     dbg_wrdata_en_p0_o;
  logic                     dbg_rddata_en_p0_o;
  logic                     test_port_rd_r;
  logic                     test_port_wr_r;

  // Declare all possible ports for the dut here.
  // Some may be unused, depending on cofiguration
  logic [0:0] axi_S00_aclk_i;
  logic [0:0] axi_S00_aresetn_i;
  logic [0:0] axi_S01_aclk_i;
  logic [0:0] axi_S01_aresetn_i;
  logic [0:0] axi_S02_aclk_i;
  logic [0:0] axi_S02_aresetn_i;
  logic [0:0] axi_S03_aclk_i;
  logic [0:0] axi_S03_aresetn_i;
  logic [0:0] axi_S04_aclk_i;
  logic [0:0] axi_S04_aresetn_i;
  logic [0:0] axi_S05_aclk_i;
  logic [0:0] axi_S05_aresetn_i;
  logic [0:0] axi_S06_aclk_i;
  logic [0:0] axi_S06_aresetn_i;
  logic [0:0] axi_S07_aclk_i;
  logic [0:0] axi_S07_aresetn_i;
  logic [0:0] axi_M00_aclk_i;
  logic [0:0] axi_M00_aresetn_i ;

  logic [0:0] axi_S00_awvalid_i ;
  logic [ID_WIDTH_TOP-1:0] axi_S00_awid_i ;
  logic [ADDR_WIDTH_TOP-1:0] axi_S00_awaddr_i ;
  logic [7:0] axi_S00_awlen_i ;
  logic [2:0] axi_S00_awsize_i ;
  logic [1:0] axi_S00_awburst_i ;
  logic [0:0] axi_S00_awlock_i ;
  logic [3:0] axi_S00_awcache_i ;
  logic [2:0] axi_S00_awprot_i ;
  logic [3:0] axi_S00_awqos_i ;
  logic [3:0] axi_S00_awregion_i ;
  logic [0:0] axi_S00_awuser_i ;
  logic [0:0] axi_S00_awready_o ;
  logic [0:0] axi_S00_wvalid_i ;
  logic [SI_MAX_DATA_WIDTH_TOP-1:0] axi_S00_wdata_i ;
  logic [(SI_MAX_DATA_WIDTH_TOP/8)-1:0] axi_S00_wstrb_i ;
  logic [0:0] axi_S00_wlast_i ;
  logic [0:0] axi_S00_wuser_i ;
  logic [0:0] axi_S00_wready_o ;
  logic [0:0] axi_S00_bready_i ;
  logic [0:0] axi_S00_bvalid_o ;
  logic [ID_WIDTH_TOP-1:0] axi_S00_bid_o ;
  logic [1:0] axi_S00_bresp_o ;
  logic [0:0] axi_S00_buser_o ;
  logic [0:0] axi_S00_arvalid_i ;
  logic [ID_WIDTH_TOP-1:0] axi_S00_arid_i ;
  logic [ADDR_WIDTH_TOP-1:0] axi_S00_araddr_i ;
  logic [7:0] axi_S00_arlen_i ;
  logic [2:0] axi_S00_arsize_i ;
  logic [1:0] axi_S00_arburst_i ;
  logic [0:0] axi_S00_arlock_i ;
  logic [3:0] axi_S00_arcache_i ;
  logic [2:0] axi_S00_arprot_i ;
  logic [3:0] axi_S00_arqos_i ;
  logic [3:0] axi_S00_arregion_i ;
  logic [0:0] axi_S00_aruser_i ;
  logic [0:0] axi_S00_arready_o ;
  logic [0:0] axi_S00_rready_i ;
  logic [0:0] axi_S00_rvalid_o ;
  logic [ID_WIDTH_TOP-1:0] axi_S00_rid_o ;
  logic [SI_MAX_DATA_WIDTH_TOP-1:0] axi_S00_rdata_o ;
  logic [1:0] axi_S00_rresp_o ;
  logic [0:0] axi_S00_rlast_o ;
  logic [0:0] axi_S00_ruser_o ;

  logic [0:0] axi_S01_awvalid_i ;
  logic [ID_WIDTH_TOP-1:0] axi_S01_awid_i ;
  logic [ADDR_WIDTH_TOP-1:0] axi_S01_awaddr_i ;
  logic [7:0] axi_S01_awlen_i ;
  logic [2:0] axi_S01_awsize_i ;
  logic [1:0] axi_S01_awburst_i ;
  logic [0:0] axi_S01_awlock_i ;
  logic [3:0] axi_S01_awcache_i ;
  logic [2:0] axi_S01_awprot_i ;
  logic [3:0] axi_S01_awqos_i ;
  logic [3:0] axi_S01_awregion_i ;
  logic [0:0] axi_S01_awuser_i ;
  logic [0:0] axi_S01_awready_o ;
  logic [0:0] axi_S01_wvalid_i ;
  logic [SI_MAX_DATA_WIDTH_TOP-1:0] axi_S01_wdata_i ;
  logic [(SI_MAX_DATA_WIDTH_TOP/8)-1:0] axi_S01_wstrb_i ;
  logic [0:0] axi_S01_wlast_i ;
  logic [0:0] axi_S01_wuser_i ;
  logic [0:0] axi_S01_wready_o ;
  logic [0:0] axi_S01_bready_i ;
  logic [0:0] axi_S01_bvalid_o ;
  logic [ID_WIDTH_TOP-1:0] axi_S01_bid_o ;
  logic [1:0] axi_S01_bresp_o ;
  logic [0:0] axi_S01_buser_o ;
  logic [0:0] axi_S01_arvalid_i ;
  logic [ID_WIDTH_TOP-1:0] axi_S01_arid_i ;
  logic [ADDR_WIDTH_TOP-1:0] axi_S01_araddr_i ;
  logic [7:0] axi_S01_arlen_i ;
  logic [2:0] axi_S01_arsize_i ;
  logic [1:0] axi_S01_arburst_i ;
  logic [0:0] axi_S01_arlock_i ;
  logic [3:0] axi_S01_arcache_i ;
  logic [2:0] axi_S01_arprot_i ;
  logic [3:0] axi_S01_arqos_i ;
  logic [3:0] axi_S01_arregion_i ;
  logic [0:0] axi_S01_aruser_i ;
  logic [0:0] axi_S01_arready_o ;
  logic [0:0] axi_S01_rready_i ;
  logic [0:0] axi_S01_rvalid_o ;
  logic [ID_WIDTH_TOP-1:0] axi_S01_rid_o ;
  logic [SI_MAX_DATA_WIDTH_TOP-1:0] axi_S01_rdata_o ;
  logic [1:0] axi_S01_rresp_o ;
  logic [0:0] axi_S01_rlast_o ;
  logic [0:0] axi_S01_ruser_o ;

  logic [0:0] axi_S02_awvalid_i ;
  logic [ID_WIDTH_TOP-1:0] axi_S02_awid_i ;
  logic [ADDR_WIDTH_TOP-1:0] axi_S02_awaddr_i ;
  logic [7:0] axi_S02_awlen_i ;
  logic [2:0] axi_S02_awsize_i ;
  logic [1:0] axi_S02_awburst_i ;
  logic [0:0] axi_S02_awlock_i ;
  logic [3:0] axi_S02_awcache_i ;
  logic [2:0] axi_S02_awprot_i ;
  logic [3:0] axi_S02_awqos_i ;
  logic [3:0] axi_S02_awregion_i ;
  logic [0:0] axi_S02_awuser_i ;
  logic [0:0] axi_S02_awready_o ;
  logic [0:0] axi_S02_wvalid_i ;
  logic [SI_MAX_DATA_WIDTH_TOP-1:0] axi_S02_wdata_i ;
  logic [(SI_MAX_DATA_WIDTH_TOP/8)-1:0] axi_S02_wstrb_i ;
  logic [0:0] axi_S02_wlast_i ;
  logic [0:0] axi_S02_wuser_i ;
  logic [0:0] axi_S02_wready_o ;
  logic [0:0] axi_S02_bready_i ;
  logic [0:0] axi_S02_bvalid_o ;
  logic [ID_WIDTH_TOP-1:0] axi_S02_bid_o ;
  logic [1:0] axi_S02_bresp_o ;
  logic [0:0] axi_S02_buser_o ;
  logic [0:0] axi_S02_arvalid_i ;
  logic [ID_WIDTH_TOP-1:0] axi_S02_arid_i ;
  logic [ADDR_WIDTH_TOP-1:0] axi_S02_araddr_i ;
  logic [7:0] axi_S02_arlen_i ;
  logic [2:0] axi_S02_arsize_i ;
  logic [1:0] axi_S02_arburst_i ;
  logic [0:0] axi_S02_arlock_i ;
  logic [3:0] axi_S02_arcache_i ;
  logic [2:0] axi_S02_arprot_i ;
  logic [3:0] axi_S02_arqos_i ;
  logic [3:0] axi_S02_arregion_i ;
  logic [0:0] axi_S02_aruser_i ;
  logic [0:0] axi_S02_arready_o ;
  logic [0:0] axi_S02_rready_i ;
  logic [0:0] axi_S02_rvalid_o ;
  logic [ID_WIDTH_TOP-1:0] axi_S02_rid_o ;
  logic [SI_MAX_DATA_WIDTH_TOP-1:0] axi_S02_rdata_o ;
  logic [1:0] axi_S02_rresp_o ;
  logic [0:0] axi_S02_rlast_o ;
  logic [0:0] axi_S02_ruser_o ;

  logic [0:0] axi_S03_awvalid_i ;
  logic [ID_WIDTH_TOP-1:0] axi_S03_awid_i ;
  logic [ADDR_WIDTH_TOP-1:0] axi_S03_awaddr_i ;
  logic [7:0] axi_S03_awlen_i ;
  logic [2:0] axi_S03_awsize_i ;
  logic [1:0] axi_S03_awburst_i ;
  logic [0:0] axi_S03_awlock_i ;
  logic [3:0] axi_S03_awcache_i ;
  logic [2:0] axi_S03_awprot_i ;
  logic [3:0] axi_S03_awqos_i ;
  logic [3:0] axi_S03_awregion_i ;
  logic [0:0] axi_S03_awuser_i ;
  logic [0:0] axi_S03_awready_o ;
  logic [0:0] axi_S03_wvalid_i ;
  logic [SI_MAX_DATA_WIDTH_TOP-1:0] axi_S03_wdata_i ;
  logic [(SI_MAX_DATA_WIDTH_TOP/8)-1:0] axi_S03_wstrb_i ;
  logic [0:0] axi_S03_wlast_i ;
  logic [0:0] axi_S03_wuser_i ;
  logic [0:0] axi_S03_wready_o ;
  logic [0:0] axi_S03_bready_i ;
  logic [0:0] axi_S03_bvalid_o ;
  logic [ID_WIDTH_TOP-1:0] axi_S03_bid_o ;
  logic [1:0] axi_S03_bresp_o ;
  logic [0:0] axi_S03_buser_o ;
  logic [0:0] axi_S03_arvalid_i ;
  logic [ID_WIDTH_TOP-1:0] axi_S03_arid_i ;
  logic [ADDR_WIDTH_TOP-1:0] axi_S03_araddr_i ;
  logic [7:0] axi_S03_arlen_i ;
  logic [2:0] axi_S03_arsize_i ;
  logic [1:0] axi_S03_arburst_i ;
  logic [0:0] axi_S03_arlock_i ;
  logic [3:0] axi_S03_arcache_i ;
  logic [2:0] axi_S03_arprot_i ;
  logic [3:0] axi_S03_arqos_i ;
  logic [3:0] axi_S03_arregion_i ;
  logic [0:0] axi_S03_aruser_i ;
  logic [0:0] axi_S03_arready_o ;
  logic [0:0] axi_S03_rready_i ;
  logic [0:0] axi_S03_rvalid_o ;
  logic [ID_WIDTH_TOP-1:0] axi_S03_rid_o ;
  logic [SI_MAX_DATA_WIDTH_TOP-1:0] axi_S03_rdata_o ;
  logic [1:0] axi_S03_rresp_o ;
  logic [0:0] axi_S03_rlast_o ;
  logic [0:0] axi_S03_ruser_o ;

  logic [0:0] axi_S04_awvalid_i ;
  logic [ID_WIDTH_TOP-1:0] axi_S04_awid_i ;
  logic [ADDR_WIDTH_TOP-1:0] axi_S04_awaddr_i ;
  logic [7:0] axi_S04_awlen_i ;
  logic [2:0] axi_S04_awsize_i ;
  logic [1:0] axi_S04_awburst_i ;
  logic [0:0] axi_S04_awlock_i ;
  logic [3:0] axi_S04_awcache_i ;
  logic [2:0] axi_S04_awprot_i ;
  logic [3:0] axi_S04_awqos_i ;
  logic [3:0] axi_S04_awregion_i ;
  logic [0:0] axi_S04_awuser_i ;
  logic [0:0] axi_S04_awready_o ;
  logic [0:0] axi_S04_wvalid_i ;
  logic [SI_MAX_DATA_WIDTH_TOP-1:0] axi_S04_wdata_i ;
  logic [(SI_MAX_DATA_WIDTH_TOP/8)-1:0] axi_S04_wstrb_i ;
  logic [0:0] axi_S04_wlast_i ;
  logic [0:0] axi_S04_wuser_i ;
  logic [0:0] axi_S04_wready_o ;
  logic [0:0] axi_S04_bready_i ;
  logic [0:0] axi_S04_bvalid_o ;
  logic [ID_WIDTH_TOP-1:0] axi_S04_bid_o ;
  logic [1:0] axi_S04_bresp_o ;
  logic [0:0] axi_S04_buser_o ;
  logic [0:0] axi_S04_arvalid_i ;
  logic [ID_WIDTH_TOP-1:0] axi_S04_arid_i ;
  logic [ADDR_WIDTH_TOP-1:0] axi_S04_araddr_i ;
  logic [7:0] axi_S04_arlen_i ;
  logic [2:0] axi_S04_arsize_i ;
  logic [1:0] axi_S04_arburst_i ;
  logic [0:0] axi_S04_arlock_i ;
  logic [3:0] axi_S04_arcache_i ;
  logic [2:0] axi_S04_arprot_i ;
  logic [3:0] axi_S04_arqos_i ;
  logic [3:0] axi_S04_arregion_i ;
  logic [0:0] axi_S04_aruser_i ;
  logic [0:0] axi_S04_arready_o ;
  logic [0:0] axi_S04_rready_i ;
  logic [0:0] axi_S04_rvalid_o ;
  logic [ID_WIDTH_TOP-1:0] axi_S04_rid_o ;
  logic [SI_MAX_DATA_WIDTH_TOP-1:0] axi_S04_rdata_o ;
  logic [1:0] axi_S04_rresp_o ;
  logic [0:0] axi_S04_rlast_o ;
  logic [0:0] axi_S04_ruser_o ;

  logic [0:0] axi_S05_awvalid_i ;
  logic [ID_WIDTH_TOP-1:0] axi_S05_awid_i ;
  logic [ADDR_WIDTH_TOP-1:0] axi_S05_awaddr_i ;
  logic [7:0] axi_S05_awlen_i ;
  logic [2:0] axi_S05_awsize_i ;
  logic [1:0] axi_S05_awburst_i ;
  logic [0:0] axi_S05_awlock_i ;
  logic [3:0] axi_S05_awcache_i ;
  logic [2:0] axi_S05_awprot_i ;
  logic [3:0] axi_S05_awqos_i ;
  logic [3:0] axi_S05_awregion_i ;
  logic [0:0] axi_S05_awuser_i ;
  logic [0:0] axi_S05_awready_o ;
  logic [0:0] axi_S05_wvalid_i ;
  logic [SI_MAX_DATA_WIDTH_TOP-1:0] axi_S05_wdata_i ;
  logic [(SI_MAX_DATA_WIDTH_TOP/8)-1:0] axi_S05_wstrb_i ;
  logic [0:0] axi_S05_wlast_i ;
  logic [0:0] axi_S05_wuser_i ;
  logic [0:0] axi_S05_wready_o ;
  logic [0:0] axi_S05_bready_i ;
  logic [0:0] axi_S05_bvalid_o ;
  logic [ID_WIDTH_TOP-1:0] axi_S05_bid_o ;
  logic [1:0] axi_S05_bresp_o ;
  logic [0:0] axi_S05_buser_o ;
  logic [0:0] axi_S05_arvalid_i ;
  logic [ID_WIDTH_TOP-1:0] axi_S05_arid_i ;
  logic [ADDR_WIDTH_TOP-1:0] axi_S05_araddr_i ;
  logic [7:0] axi_S05_arlen_i ;
  logic [2:0] axi_S05_arsize_i ;
  logic [1:0] axi_S05_arburst_i ;
  logic [0:0] axi_S05_arlock_i ;
  logic [3:0] axi_S05_arcache_i ;
  logic [2:0] axi_S05_arprot_i ;
  logic [3:0] axi_S05_arqos_i ;
  logic [3:0] axi_S05_arregion_i ;
  logic [0:0] axi_S05_aruser_i ;
  logic [0:0] axi_S05_arready_o ;
  logic [0:0] axi_S05_rready_i ;
  logic [0:0] axi_S05_rvalid_o ;
  logic [ID_WIDTH_TOP-1:0] axi_S05_rid_o ;
  logic [SI_MAX_DATA_WIDTH_TOP-1:0] axi_S05_rdata_o ;
  logic [1:0] axi_S05_rresp_o ;
  logic [0:0] axi_S05_rlast_o ;
  logic [0:0] axi_S05_ruser_o ;

  logic [0:0] axi_S06_awvalid_i ;
  logic [ID_WIDTH_TOP-1:0] axi_S06_awid_i ;
  logic [ADDR_WIDTH_TOP-1:0] axi_S06_awaddr_i ;
  logic [7:0] axi_S06_awlen_i ;
  logic [2:0] axi_S06_awsize_i ;
  logic [1:0] axi_S06_awburst_i ;
  logic [0:0] axi_S06_awlock_i ;
  logic [3:0] axi_S06_awcache_i ;
  logic [2:0] axi_S06_awprot_i ;
  logic [3:0] axi_S06_awqos_i ;
  logic [3:0] axi_S06_awregion_i ;
  logic [0:0] axi_S06_awuser_i ;
  logic [0:0] axi_S06_awready_o ;
  logic [0:0] axi_S06_wvalid_i ;
  logic [SI_MAX_DATA_WIDTH_TOP-1:0] axi_S06_wdata_i ;
  logic [(SI_MAX_DATA_WIDTH_TOP/8)-1:0] axi_S06_wstrb_i ;
  logic [0:0] axi_S06_wlast_i ;
  logic [0:0] axi_S06_wuser_i ;
  logic [0:0] axi_S06_wready_o ;
  logic [0:0] axi_S06_bready_i ;
  logic [0:0] axi_S06_bvalid_o ;
  logic [ID_WIDTH_TOP-1:0] axi_S06_bid_o ;
  logic [1:0] axi_S06_bresp_o ;
  logic [0:0] axi_S06_buser_o ;
  logic [0:0] axi_S06_arvalid_i ;
  logic [ID_WIDTH_TOP-1:0] axi_S06_arid_i ;
  logic [ADDR_WIDTH_TOP-1:0] axi_S06_araddr_i ;
  logic [7:0] axi_S06_arlen_i ;
  logic [2:0] axi_S06_arsize_i ;
  logic [1:0] axi_S06_arburst_i ;
  logic [0:0] axi_S06_arlock_i ;
  logic [3:0] axi_S06_arcache_i ;
  logic [2:0] axi_S06_arprot_i ;
  logic [3:0] axi_S06_arqos_i ;
  logic [3:0] axi_S06_arregion_i ;
  logic [0:0] axi_S06_aruser_i ;
  logic [0:0] axi_S06_arready_o ;
  logic [0:0] axi_S06_rready_i ;
  logic [0:0] axi_S06_rvalid_o ;
  logic [ID_WIDTH_TOP-1:0] axi_S06_rid_o ;
  logic [SI_MAX_DATA_WIDTH_TOP-1:0] axi_S06_rdata_o ;
  logic [1:0] axi_S06_rresp_o ;
  logic [0:0] axi_S06_rlast_o ;
  logic [0:0] axi_S06_ruser_o ;

  logic [0:0] axi_S07_awvalid_i ;
  logic [ID_WIDTH_TOP-1:0] axi_S07_awid_i ;
  logic [ADDR_WIDTH_TOP-1:0] axi_S07_awaddr_i ;
  logic [7:0] axi_S07_awlen_i ;
  logic [2:0] axi_S07_awsize_i ;
  logic [1:0] axi_S07_awburst_i ;
  logic [0:0] axi_S07_awlock_i ;
  logic [3:0] axi_S07_awcache_i ;
  logic [2:0] axi_S07_awprot_i ;
  logic [3:0] axi_S07_awqos_i ;
  logic [3:0] axi_S07_awregion_i ;
  logic [0:0] axi_S07_awuser_i ;
  logic [0:0] axi_S07_awready_o ;
  logic [0:0] axi_S07_wvalid_i ;
  logic [SI_MAX_DATA_WIDTH_TOP-1:0] axi_S07_wdata_i ;
  logic [(SI_MAX_DATA_WIDTH_TOP/8)-1:0] axi_S07_wstrb_i ;
  logic [0:0] axi_S07_wlast_i ;
  logic [0:0] axi_S07_wuser_i ;
  logic [0:0] axi_S07_wready_o ;
  logic [0:0] axi_S07_bready_i ;
  logic [0:0] axi_S07_bvalid_o ;
  logic [ID_WIDTH_TOP-1:0] axi_S07_bid_o ;
  logic [1:0] axi_S07_bresp_o ;
  logic [0:0] axi_S07_buser_o ;
  logic [0:0] axi_S07_arvalid_i ;
  logic [ID_WIDTH_TOP-1:0] axi_S07_arid_i ;
  logic [ADDR_WIDTH_TOP-1:0] axi_S07_araddr_i ;
  logic [7:0] axi_S07_arlen_i ;
  logic [2:0] axi_S07_arsize_i ;
  logic [1:0] axi_S07_arburst_i ;
  logic [0:0] axi_S07_arlock_i ;
  logic [3:0] axi_S07_arcache_i ;
  logic [2:0] axi_S07_arprot_i ;
  logic [3:0] axi_S07_arqos_i ;
  logic [3:0] axi_S07_arregion_i ;
  logic [0:0] axi_S07_aruser_i ;
  logic [0:0] axi_S07_arready_o ;
  logic [0:0] axi_S07_rready_i ;
  logic [0:0] axi_S07_rvalid_o ;
  logic [ID_WIDTH_TOP-1:0] axi_S07_rid_o ;
  logic [SI_MAX_DATA_WIDTH_TOP-1:0] axi_S07_rdata_o ;
  logic [1:0] axi_S07_rresp_o ;
  logic [0:0] axi_S07_rlast_o ;
  logic [0:0] axi_S07_ruser_o ;

  logic [0:0] axi_M00_awvalid_o ;
  logic [ID_WIDTH_TOP-1:0] axi_M00_awid_o ;
  logic [ADDR_WIDTH_TOP-1:0] axi_M00_awaddr_o ;
  logic [7:0] axi_M00_awlen_o ;
  logic [2:0] axi_M00_awsize_o ;
  logic [1:0] axi_M00_awburst_o ;
  logic [0:0] axi_M00_awlock_o ;
  logic [3:0] axi_M00_awcache_o ;
  logic [2:0] axi_M00_awprot_o ;
  logic [3:0] axi_M00_awqos_o ;
  logic [3:0] axi_M00_awregion_o ;
  logic [0:0] axi_M00_awuser_o ;
  logic [0:0] axi_M00_awready_i ;
  logic [0:0] axi_M00_wvalid_o ;
  logic [MI_DATA_WIDTH_TOP-1:0] axi_M00_wdata_o ;
  logic [(MI_DATA_WIDTH_TOP/8)-1:0] axi_M00_wstrb_o ;
  logic [0:0] axi_M00_wlast_o ;
  logic [0:0] axi_M00_wuser_o ;
  logic [0:0] axi_M00_wready_i ;
  logic [0:0] axi_M00_bvalid_i ;
  logic [ID_WIDTH_TOP-1:0] axi_M00_bid_i ;
  logic [1:0] axi_M00_bresp_i ;
  logic [0:0] axi_M00_buser_i ;
  logic [0:0] axi_M00_bready_o ;
  logic [0:0] axi_M00_arvalid_o ;
  logic [ID_WIDTH_TOP-1:0] axi_M00_arid_o ;
  logic [ADDR_WIDTH_TOP-1:0] axi_M00_araddr_o ;
  logic [7:0] axi_M00_arlen_o ;
  logic [2:0] axi_M00_arsize_o ;
  logic [1:0] axi_M00_arburst_o ;
  logic [0:0] axi_M00_arlock_o ;
  logic [3:0] axi_M00_arcache_o ;
  logic [2:0] axi_M00_arprot_o ;
  logic [3:0] axi_M00_arqos_o ;
  logic [3:0] axi_M00_arregion_o ;
  logic [0:0] axi_M00_aruser_o ;
  logic [0:0] axi_M00_arready_i ;
  logic [0:0] axi_M00_rvalid_i ;
  logic [ID_WIDTH_TOP-1:0] axi_M00_rid_i ;
  logic [MI_DATA_WIDTH_TOP-1:0] axi_M00_rdata_i ;
  logic [1:0] axi_M00_rresp_i ;
  logic [0:0] axi_M00_rlast_i ;
  logic [0:0] axi_M00_ruser_i ;
  logic [0:0] axi_M00_rready_o ;

  logic [TOTAL_MGR_COUNT_TOP-1:0]                         axi_arready_i;
  logic [TOTAL_MGR_COUNT_TOP-1:0]                         axi_arvalid_o;
  logic [TOTAL_MGR_COUNT_TOP*ADDR_WIDTH_TOP-1:0]          axi_araddr_o ;
  logic [TOTAL_MGR_COUNT_TOP*ID_WIDTH_TOP-1:0]            axi_arid_o   ;
  logic [TOTAL_MGR_COUNT_TOP*AXI_LEN_WIDTH-1:0]           axi_arlen_o  ;
  logic [TOTAL_MGR_COUNT_TOP*2-1:0]                       axi_arburst_o;
  logic [TOTAL_MGR_COUNT_TOP*4-1:0]                       axi_arqos_o  ;
  logic [TOTAL_MGR_COUNT_TOP*3-1:0]                       axi_arsize_o ;

  logic [TOTAL_MGR_COUNT_TOP-1:0]                         axi_rready_o ;
  logic [TOTAL_MGR_COUNT_TOP-1:0]                         axi_rvalid_i ;
  logic [TOTAL_MGR_COUNT_TOP*SI_MAX_DATA_WIDTH_TOP-1:0]   axi_rdata_i  ;
  logic [TOTAL_MGR_COUNT_TOP*2-1:0]                       axi_rresp_i  ;
  logic [TOTAL_MGR_COUNT_TOP*ID_WIDTH_TOP-1:0]            axi_rid_i    ;
  logic [TOTAL_MGR_COUNT_TOP-1:0]                         axi_rlast_i  ;

  logic [TOTAL_MGR_COUNT_TOP-1:0]                         axi_bready_o ;
  logic [TOTAL_MGR_COUNT_TOP-1:0]                         axi_bvalid_i ;
  logic [TOTAL_MGR_COUNT_TOP*2-1:0]                       axi_bresp_i  ;
  logic [TOTAL_MGR_COUNT_TOP*ID_WIDTH_TOP-1:0]            axi_bid_i    ;

  logic [TOTAL_MGR_COUNT_TOP-1:0]                         axi_awvalid_o;
  logic [TOTAL_MGR_COUNT_TOP*ID_WIDTH_TOP-1:0]            axi_awid_o   ;
  logic [TOTAL_MGR_COUNT_TOP*AXI_LEN_WIDTH-1:0]           axi_awlen_o  ;
  logic [TOTAL_MGR_COUNT_TOP*2-1:0]                       axi_awburst_o;
  logic [TOTAL_MGR_COUNT_TOP*ADDR_WIDTH_TOP-1:0]          axi_awaddr_o ;
  logic [TOTAL_MGR_COUNT_TOP*3-1:0]                       axi_awsize_o ;
  logic [TOTAL_MGR_COUNT_TOP*4-1:0]                       axi_awqos_o  ;
  logic [TOTAL_MGR_COUNT_TOP-1:0]                         axi_awready_i;

  logic [TOTAL_MGR_COUNT_TOP-1:0]                         axi_wvalid_o ;
  logic [TOTAL_MGR_COUNT_TOP*SI_MAX_DATA_WIDTH_TOP-1:0]   axi_wdata_o  ;
  logic [TOTAL_MGR_COUNT_TOP*SI_MAX_DATA_WIDTH_TOP/8-1:0] axi_wstrb_o  ;
  logic [TOTAL_MGR_COUNT_TOP-1:0]                         axi_wlast_o  ;
  logic [TOTAL_MGR_COUNT_TOP-1:0]                         axi_wready_i ;

  //-------------------------------------//
  //-- assign (non-process) operations --//
  //-------------------------------------//
  assign pll_rst_n_i = rstn_i   ;
  assign rst_n_i     = rstn_i   ;
  assign preset_n_i  = prst_n   ;
  assign pclk        = pclk_i     ; // for probing
  //assign test_port   = init_done_o; // for probing
  assign sim_o           = SIM[0]   ; // tell tb_top if SIM parameter is set
  assign mc_pll_lock_o   = pll_lock_o;
  assign eval_pll_lock_o = eval_pll_lock;

  generate
    if (DATA_CLK_EN) begin : ASYNC_AXI
      assign clk_w   = clk_i;
    end
    else begin : SYNC_AXI
      assign clk_w   = sclk_o;
    end
  endgenerate

  assign reset_n_i   = arst_n;

  always @(posedge pclk_i or negedge rstn_i) begin
    if (!rstn_i) begin
      prst_n    <= 1'b0;
      prst_n_r0 <= 1'b0;
      prst_n_r1 <= 1'b0;
    end
    else begin
      prst_n_r0 <= 1'b1;
      prst_n_r1 <= prst_n_r0;
      prst_n    <= prst_n_r1;
    end
  end

  //  GSRA  GSR_INST (
  //      .GSR_N (prst_n ));

  always @(posedge clk_w or negedge rstn_i) begin
    if (!rstn_i) begin
      arst_n    <= 1'b0;
      arst_n_r0 <= 1'b0;
      arst_n_r1 <= 1'b0;
    end
    else begin
      //arst_n_r0 <= pll_lock_o;  // only release this reset when PLL locks
      arst_n_r0 <= 1'b1      ;
      arst_n_r1 <= arst_n_r0 ;
      arst_n    <= arst_n_r1 ;
    end
  end

  always @(posedge sclk_o or negedge rstn_i) begin
    if (!rstn_i) begin
      srst_n    <= 1'b0;
      srst_n_r0 <= 1'b0;
      srst_n_r1 <= 1'b0;
    end
    else begin
      //arst_n_r0 <= pll_lock_o;  // only release this reset when PLL locks
      srst_n_r0 <= 1'b1      ;
      srst_n_r1 <= srst_n_r0 ;
      srst_n    <= srst_n_r1 ;
    end
  end

  //always @(posedge pclk_i or negedge preset_n_i) begin
  //   if (!preset_n_i) begin
  //	 irq_out               <= 1'b0;
  //   end
  //   else begin
  //	 irq_out               <= irq_o;
  //   end
  //end

  //--------------------------------------------------------------------
  //--  module instances
  //--------------------------------------------------------------------
  // David added
  pll0 u_pll0 (
          .clki_i (osc_clk_100  ),
          .rstn_i (1'b1         ),
          .clkop_o(clk_i        ),
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
      .rstn       (reset_n_i),
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


  logic [3:0]  gen_in_w;
  logic        perf_tst_en;
  logic        s2p_r1_trn_done;
  logic        s2p_r2_trn_done;
  logic        s2p_r1_trn_err;
  logic        s2p_r2_trn_err;
  logic [11:0] apb_paddr_o;
  assign perf_tst_en = SIM ? 1'b0 : 1'b1;
  assign gen_in_w    = {s2p_r2_trn_err, perf_tst_en,s2p_r2_trn_done, irq_o};
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
    .GEN_IN_WIDTH  (4               ),
      .AXI_ADDR_WIDTH(ADDR_WIDTH_TOP  ),
      .AXI_DATA_WIDTH(SI_MAX_DATA_WIDTH_TOP  ),
      .AXI_ID_WIDTH  (ID_WIDTH_TOP    ),
      .AXI_LEN_WIDTH (8   ),
      .TIMEOUT_VALUE (250             ),  // added for timeout detection
      .TIMEOUT_WIDTH (8               ),   // added for timeout detection
      .DDR_CMD_FREQ  (CLK_FREQ        ),
      .DATA_CLK_EN   (DATA_CLK_EN     ),
      .TOTAL_MGR_COUNT (TOTAL_MGR_COUNT_TOP)
  ) u_tragen (
      .aclk_i        (clk_w         ),
    .areset_n_i    (reset_n_i     ),
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
      .gen_in_i     (gen_in_w     ),
      .apb_psel_o   (apb_psel_i   ),
      .apb_paddr_o  (apb_paddr_o  ),
      .apb_penable_o(apb_penable_i),
      .apb_pwrite_o (apb_pwrite_i ),
      .apb_pwdata_o (apb_pwdata_i ),
      .apb_pready_i (apb_pready_o ),
      .apb_prdata_i (apb_prdata_o ),
      .apb_pslverr_i(apb_pslverr_o),

      .axi_awready_i(axi_awready_i),
      .axi_awvalid_o(axi_awvalid_o),
      .axi_awid_o   (axi_awid_o   ),
      .axi_awaddr_o (axi_awaddr_o ),
      .axi_awlen_o  (axi_awlen_o  ),
      .axi_awburst_o(axi_awburst_o),
      .axi_awqos_o  (axi_awqos_o  ),
      .axi_awsize_o (axi_awsize_o ),

      .axi_wvalid_o (axi_wvalid_o ),
      .axi_wready_i (axi_wready_i ),
      .axi_wdata_o  (axi_wdata_o  ),
      .axi_wstrb_o  (axi_wstrb_o  ),
      .axi_wlast_o  (axi_wlast_o  ),

      .axi_bready_o (axi_bready_o ),
      .axi_bvalid_i (axi_bvalid_i ),
      .axi_bresp_i  (axi_bresp_i  ),
      .axi_bid_i    (axi_bid_i    ),

      .axi_arready_i(axi_arready_i),
      .axi_arvalid_o(axi_arvalid_o),
      .axi_arid_o   (axi_arid_o   ),
      .axi_arlen_o  (axi_arlen_o  ),
      .axi_arburst_o(axi_arburst_o),
      .axi_araddr_o (axi_araddr_o ),
      .axi_arqos_o  (axi_arqos_o  ),
      .axi_arsize_o (axi_arsize_o ),

      .axi_rready_o (axi_rready_o ),
      .axi_rvalid_i (axi_rvalid_i ),
      .axi_rdata_i  (axi_rdata_i  ),
      .axi_rresp_i  (axi_rresp_i  ),
      .axi_rid_i    (axi_rid_i    ),
      .axi_rlast_i  (axi_rlast_i  )
  );

  // ---------------------------------------------------------
  // Map to the MPMC AXI S* Ports from the traffic generators
  // ---------------------------------------------------------
  assign axi_awready_i = {axi_S07_awready_o, axi_S06_awready_o,
                          axi_S05_awready_o, axi_S04_awready_o,
                          axi_S03_awready_o, axi_S02_awready_o,
                          axi_S01_awready_o, axi_S00_awready_o};
  assign axi_wready_i = {axi_S07_wready_o, axi_S06_wready_o,
                        axi_S05_wready_o, axi_S04_wready_o,
                        axi_S03_wready_o, axi_S02_wready_o,
                        axi_S01_wready_o, axi_S00_wready_o};
  assign axi_bvalid_i = {axi_S07_bvalid_o, axi_S06_bvalid_o,
                        axi_S05_bvalid_o, axi_S04_bvalid_o,
                        axi_S03_bvalid_o, axi_S02_bvalid_o,
                        axi_S01_bvalid_o, axi_S00_bvalid_o};
  assign axi_bresp_i = {axi_S07_bresp_o, axi_S06_bresp_o,
                        axi_S05_bresp_o, axi_S04_bresp_o,
                        axi_S03_bresp_o, axi_S02_bresp_o,
                        axi_S01_bresp_o, axi_S00_bresp_o};
  assign axi_bid_i = {axi_S07_bid_o, axi_S06_bid_o,
                      axi_S05_bid_o, axi_S04_bid_o,
                      axi_S03_bid_o, axi_S02_bid_o,
                      axi_S01_bid_o, axi_S00_bid_o};
  assign axi_arready_i = {axi_S07_arready_o, axi_S06_arready_o,
                          axi_S05_arready_o, axi_S04_arready_o,
                          axi_S03_arready_o, axi_S02_arready_o,
                          axi_S01_arready_o, axi_S00_arready_o};
  assign axi_rvalid_i = {axi_S07_rvalid_o, axi_S06_rvalid_o,
                        axi_S05_rvalid_o, axi_S04_rvalid_o,
                        axi_S03_rvalid_o, axi_S02_rvalid_o,
                        axi_S01_rvalid_o, axi_S00_rvalid_o};
  assign axi_rdata_i = {axi_S07_rdata_o, axi_S06_rdata_o,
                        axi_S05_rdata_o, axi_S04_rdata_o,
                        axi_S03_rdata_o, axi_S02_rdata_o,
                        axi_S01_rdata_o, axi_S00_rdata_o};
  assign axi_rresp_i = {axi_S07_rresp_o, axi_S06_rresp_o,
                        axi_S05_rresp_o, axi_S04_rresp_o,
                        axi_S03_rresp_o, axi_S02_rresp_o,
                        axi_S01_rresp_o, axi_S00_rresp_o};
  assign axi_rid_i = {axi_S07_rid_o, axi_S06_rid_o,
                      axi_S05_rid_o, axi_S04_rid_o,
                      axi_S03_rid_o, axi_S02_rid_o,
                      axi_S01_rid_o, axi_S00_rid_o};
  assign axi_rlast_i = {axi_S07_rlast_o, axi_S06_rlast_o,
                        axi_S05_rlast_o, axi_S04_rlast_o,
                        axi_S03_rlast_o, axi_S02_rlast_o,
                        axi_S01_rlast_o, axi_S00_rlast_o};

  always @* begin
    axi_S00_awvalid_i = axi_awvalid_o[0*1 +: 1];
    axi_S00_awid_i = axi_awid_o[0*ID_WIDTH_TOP +: ID_WIDTH_TOP] ;
    axi_S00_awaddr_i = axi_awaddr_o[0*ADDR_WIDTH_TOP +: ADDR_WIDTH_TOP] ;
    axi_S00_awlen_i = axi_awlen_o[0*AXI_LEN_WIDTH +: AXI_LEN_WIDTH] ;
    axi_S00_awsize_i = axi_awsize_o[0*3 +: 3] ;
    axi_S00_awburst_i = axi_awburst_o[0*2 +: 2] ;
    axi_S00_awlock_i = 1'h0 ;
    axi_S00_awcache_i = 4'h0 ;
    axi_S00_awprot_i = 3'h0 ;
    axi_S00_awqos_i = axi_awqos_o[0*4 +: 4] ;
    axi_S00_awregion_i = 4'h0 ;
    axi_S00_awuser_i = 1'h0 ;
    axi_S00_wvalid_i = axi_wvalid_o[0*1 +: 1] ;
    axi_S00_wdata_i = axi_wdata_o[0*SI_MAX_DATA_WIDTH_TOP +: SI_MAX_DATA_WIDTH_TOP] ;
    axi_S00_wstrb_i = axi_wstrb_o[0*SI_MAX_DATA_WIDTH_TOP/8 +: SI_MAX_DATA_WIDTH_TOP/8] ;
    axi_S00_wlast_i = axi_wlast_o[0*1 +: 1] ;
    axi_S00_wuser_i = 1'h0 ;
    axi_S00_bready_i = axi_bready_o[0*1 +: 1] ;
    axi_S00_arvalid_i = axi_arvalid_o[0*1 +: 1] ;
    axi_S00_arid_i = axi_arid_o[0*ID_WIDTH_TOP +: ID_WIDTH_TOP] ;
    axi_S00_araddr_i = axi_araddr_o[0*ADDR_WIDTH_TOP +: ADDR_WIDTH_TOP] ;
    axi_S00_arlen_i = axi_arlen_o[0*AXI_LEN_WIDTH +: AXI_LEN_WIDTH] ;
    axi_S00_arsize_i = axi_arsize_o[0*3 +: 3] ;
    axi_S00_arburst_i = axi_arburst_o[0*2 +: 2] ;
    axi_S00_arlock_i = 1'h0 ;
    axi_S00_arcache_i = 4'h0 ;
    axi_S00_arprot_i = 3'h0 ;
    axi_S00_arqos_i = axi_arqos_o[0*4 +: 4] ;
    axi_S00_arregion_i = 4'h0 ;
    axi_S00_aruser_i = 1'h0 ;
    axi_S00_rready_i = axi_rready_o[0*1 +: 1] ;

    axi_S01_awvalid_i = axi_awvalid_o[1*1 +: 1];
    axi_S01_awid_i = axi_awid_o[1*ID_WIDTH_TOP +: ID_WIDTH_TOP] ;
    axi_S01_awaddr_i = axi_awaddr_o[1*ADDR_WIDTH_TOP +: ADDR_WIDTH_TOP] ;
    axi_S01_awlen_i = axi_awlen_o[1*AXI_LEN_WIDTH +: AXI_LEN_WIDTH] ;
    axi_S01_awsize_i = axi_awsize_o[1*3 +: 3] ;
    axi_S01_awburst_i = axi_awburst_o[1*2 +: 2] ;
    axi_S01_awlock_i = 1'h0 ;
    axi_S01_awcache_i = 4'h0 ;
    axi_S01_awprot_i = 3'h0 ;
    axi_S01_awqos_i = axi_awqos_o[1*4 +: 4] ;
    axi_S01_awregion_i = 4'h0 ;
    axi_S01_awuser_i = 1'h0 ;
    axi_S01_wvalid_i = axi_wvalid_o[1*1 +: 1] ;
    axi_S01_wdata_i = axi_wdata_o[1*SI_MAX_DATA_WIDTH_TOP +: SI_MAX_DATA_WIDTH_TOP] ;
    axi_S01_wstrb_i = axi_wstrb_o[1*SI_MAX_DATA_WIDTH_TOP/8 +: SI_MAX_DATA_WIDTH_TOP/8] ;
    axi_S01_wlast_i = axi_wlast_o[1*1 +: 1] ;
    axi_S01_wuser_i = 1'h0 ;
    axi_S01_bready_i = axi_bready_o[1*1 +: 1] ;
    axi_S01_arvalid_i = axi_arvalid_o[1*1 +: 1] ;
    axi_S01_arid_i = axi_arid_o[1*ID_WIDTH_TOP +: ID_WIDTH_TOP] ;
    axi_S01_araddr_i = axi_araddr_o[1*ADDR_WIDTH_TOP +: ADDR_WIDTH_TOP] ;
    axi_S01_arlen_i = axi_arlen_o[1*AXI_LEN_WIDTH +: AXI_LEN_WIDTH] ;
    axi_S01_arsize_i = axi_arsize_o[1*3 +: 3] ;
    axi_S01_arburst_i = axi_arburst_o[1*2 +: 2] ;
    axi_S01_arlock_i = 1'h0 ;
    axi_S01_arcache_i = 4'h0 ;
    axi_S01_arprot_i = 3'h0 ;
    axi_S01_arqos_i = axi_arqos_o[1*4 +: 4] ;
    axi_S01_arregion_i = 4'h0 ;
    axi_S01_aruser_i = 1'h0 ;
    axi_S01_rready_i = axi_rready_o[1*1 +: 1] ;

    axi_S02_awvalid_i = 1'h0 ;
    axi_S02_awid_i = {ID_WIDTH_TOP{1'b0}} ;
    axi_S02_awaddr_i = {ADDR_WIDTH_TOP{1'b0}} ;
    axi_S02_awlen_i = 8'h0 ;
    axi_S02_awsize_i = 3'h0 ;
    axi_S02_awburst_i = 2'h0 ;
    axi_S02_awlock_i = 1'h0 ;
    axi_S02_awcache_i = 4'h0 ;
    axi_S02_awprot_i = 3'h0 ;
    axi_S02_awqos_i = 4'h0 ;
    axi_S02_awregion_i = 4'h0 ;
    axi_S02_awuser_i = 1'h0 ;
    axi_S02_wvalid_i = 1'h0 ;
    axi_S02_wdata_i = {SI_MAX_DATA_WIDTH_TOP{1'b0}} ;
    axi_S02_wstrb_i = {(SI_MAX_DATA_WIDTH_TOP/8){1'b0}} ;
    axi_S02_wlast_i = 1'h0 ;
    axi_S02_wuser_i = 1'h0 ;
    axi_S02_bready_i = 1'h0 ;
    axi_S02_arvalid_i = 1'h0 ;
    axi_S02_arid_i = {ID_WIDTH_TOP{1'b0}} ;
    axi_S02_araddr_i = {ADDR_WIDTH_TOP{1'b0}} ;
    axi_S02_arlen_i = 8'h0 ;
    axi_S02_arsize_i = 3'h0 ;
    axi_S02_arburst_i = 2'h0 ;
    axi_S02_arlock_i = 1'h0 ;
    axi_S02_arcache_i = 4'h0 ;
    axi_S02_arprot_i = 3'h0 ;
    axi_S02_arqos_i = 4'h0 ;
    axi_S02_arregion_i = 4'h0 ;
    axi_S02_aruser_i = 1'h0 ;
    axi_S02_rready_i = 1'h0 ;

    axi_S03_awvalid_i = 1'h0 ;
    axi_S03_awid_i = {ID_WIDTH_TOP{1'b0}} ;
    axi_S03_awaddr_i = {ADDR_WIDTH_TOP{1'b0}} ;
    axi_S03_awlen_i = 8'h0 ;
    axi_S03_awsize_i = 3'h0 ;
    axi_S03_awburst_i = 2'h0 ;
    axi_S03_awlock_i = 1'h0 ;
    axi_S03_awcache_i = 4'h0 ;
    axi_S03_awprot_i = 3'h0 ;
    axi_S03_awqos_i = 4'h0 ;
    axi_S03_awregion_i = 4'h0 ;
    axi_S03_awuser_i = 1'h0 ;
    axi_S03_wvalid_i = 1'h0 ;
    axi_S03_wdata_i = {SI_MAX_DATA_WIDTH_TOP{1'b0}} ;
    axi_S03_wstrb_i = {(SI_MAX_DATA_WIDTH_TOP/8){1'b0}} ;
    axi_S03_wlast_i = 1'h0 ;
    axi_S03_wuser_i = 1'h0 ;
    axi_S03_bready_i = 1'h0 ;
    axi_S03_arvalid_i = 1'h0 ;
    axi_S03_arid_i = {ID_WIDTH_TOP{1'b0}} ;
    axi_S03_araddr_i = {ADDR_WIDTH_TOP{1'b0}} ;
    axi_S03_arlen_i = 8'h0 ;
    axi_S03_arsize_i = 3'h0 ;
    axi_S03_arburst_i = 2'h0 ;
    axi_S03_arlock_i = 1'h0 ;
    axi_S03_arcache_i = 4'h0 ;
    axi_S03_arprot_i = 3'h0 ;
    axi_S03_arqos_i = 4'h0 ;
    axi_S03_arregion_i = 4'h0 ;
    axi_S03_aruser_i = 1'h0 ;
    axi_S03_rready_i = 1'h0 ;

    axi_S04_awvalid_i = 1'h0 ;
    axi_S04_awid_i = {ID_WIDTH_TOP{1'b0}} ;
    axi_S04_awaddr_i = {ADDR_WIDTH_TOP{1'b0}} ;
    axi_S04_awlen_i = 8'h0 ;
    axi_S04_awsize_i = 3'h0 ;
    axi_S04_awburst_i = 2'h0 ;
    axi_S04_awlock_i = 1'h0 ;
    axi_S04_awcache_i = 4'h0 ;
    axi_S04_awprot_i = 3'h0 ;
    axi_S04_awqos_i = 4'h0 ;
    axi_S04_awregion_i = 4'h0 ;
    axi_S04_awuser_i = 1'h0 ;
    axi_S04_wvalid_i = 1'h0 ;
    axi_S04_wdata_i = {SI_MAX_DATA_WIDTH_TOP{1'b0}} ;
    axi_S04_wstrb_i = {(SI_MAX_DATA_WIDTH_TOP/8){1'b0}} ;
    axi_S04_wlast_i = 1'h0 ;
    axi_S04_wuser_i = 1'h0 ;
    axi_S04_bready_i = 1'h0 ;
    axi_S04_arvalid_i = 1'h0 ;
    axi_S04_arid_i = {ID_WIDTH_TOP{1'b0}} ;
    axi_S04_araddr_i = {ADDR_WIDTH_TOP{1'b0}} ;
    axi_S04_arlen_i = 8'h0 ;
    axi_S04_arsize_i = 3'h0 ;
    axi_S04_arburst_i = 2'h0 ;
    axi_S04_arlock_i = 1'h0 ;
    axi_S04_arcache_i = 4'h0 ;
    axi_S04_arprot_i = 3'h0 ;
    axi_S04_arqos_i = 4'h0 ;
    axi_S04_arregion_i = 4'h0 ;
    axi_S04_aruser_i = 1'h0 ;
    axi_S04_rready_i = 1'h0 ;

    axi_S05_awvalid_i = 1'h0 ;
    axi_S05_awid_i = {ID_WIDTH_TOP{1'b0}} ;
    axi_S05_awaddr_i = {ADDR_WIDTH_TOP{1'b0}} ;
    axi_S05_awlen_i = 8'h0 ;
    axi_S05_awsize_i = 3'h0 ;
    axi_S05_awburst_i = 2'h0 ;
    axi_S05_awlock_i = 1'h0 ;
    axi_S05_awcache_i = 4'h0 ;
    axi_S05_awprot_i = 3'h0 ;
    axi_S05_awqos_i = 4'h0 ;
    axi_S05_awregion_i = 4'h0 ;
    axi_S05_awuser_i = 1'h0 ;
    axi_S05_wvalid_i = 1'h0 ;
    axi_S05_wdata_i = {SI_MAX_DATA_WIDTH_TOP{1'b0}} ;
    axi_S05_wstrb_i = {(SI_MAX_DATA_WIDTH_TOP/8){1'b0}} ;
    axi_S05_wlast_i = 1'h0 ;
    axi_S05_wuser_i = 1'h0 ;
    axi_S05_bready_i = 1'h0 ;
    axi_S05_arvalid_i = 1'h0 ;
    axi_S05_arid_i = {ID_WIDTH_TOP{1'b0}} ;
    axi_S05_araddr_i = {ADDR_WIDTH_TOP{1'b0}} ;
    axi_S05_arlen_i = 8'h0 ;
    axi_S05_arsize_i = 3'h0 ;
    axi_S05_arburst_i = 2'h0 ;
    axi_S05_arlock_i = 1'h0 ;
    axi_S05_arcache_i = 4'h0 ;
    axi_S05_arprot_i = 3'h0 ;
    axi_S05_arqos_i = 4'h0 ;
    axi_S05_arregion_i = 4'h0 ;
    axi_S05_aruser_i = 1'h0 ;
    axi_S05_rready_i = 1'h0 ;

    axi_S06_awvalid_i = 1'h0 ;
    axi_S06_awid_i = {ID_WIDTH_TOP{1'b0}} ;
    axi_S06_awaddr_i = {ADDR_WIDTH_TOP{1'b0}} ;
    axi_S06_awlen_i = 8'h0 ;
    axi_S06_awsize_i = 3'h0 ;
    axi_S06_awburst_i = 2'h0 ;
    axi_S06_awlock_i = 1'h0 ;
    axi_S06_awcache_i = 4'h0 ;
    axi_S06_awprot_i = 3'h0 ;
    axi_S06_awqos_i = 4'h0 ;
    axi_S06_awregion_i = 4'h0 ;
    axi_S06_awuser_i = 1'h0 ;
    axi_S06_wvalid_i = 1'h0 ;
    axi_S06_wdata_i = {SI_MAX_DATA_WIDTH_TOP{1'b0}} ;
    axi_S06_wstrb_i = {(SI_MAX_DATA_WIDTH_TOP/8){1'b0}} ;
    axi_S06_wlast_i = 1'h0 ;
    axi_S06_wuser_i = 1'h0 ;
    axi_S06_bready_i = 1'h0 ;
    axi_S06_arvalid_i = 1'h0 ;
    axi_S06_arid_i = {ID_WIDTH_TOP{1'b0}} ;
    axi_S06_araddr_i = {ADDR_WIDTH_TOP{1'b0}} ;
    axi_S06_arlen_i = 8'h0 ;
    axi_S06_arsize_i = 3'h0 ;
    axi_S06_arburst_i = 2'h0 ;
    axi_S06_arlock_i = 1'h0 ;
    axi_S06_arcache_i = 4'h0 ;
    axi_S06_arprot_i = 3'h0 ;
    axi_S06_arqos_i = 4'h0 ;
    axi_S06_arregion_i = 4'h0 ;
    axi_S06_aruser_i = 1'h0 ;
    axi_S06_rready_i = 1'h0 ;

    axi_S07_awvalid_i = 1'h0 ;
    axi_S07_awid_i = {ID_WIDTH_TOP{1'b0}} ;
    axi_S07_awaddr_i = {ADDR_WIDTH_TOP{1'b0}} ;
    axi_S07_awlen_i = 8'h0 ;
    axi_S07_awsize_i = 3'h0 ;
    axi_S07_awburst_i = 2'h0 ;
    axi_S07_awlock_i = 1'h0 ;
    axi_S07_awcache_i = 4'h0 ;
    axi_S07_awprot_i = 3'h0 ;
    axi_S07_awqos_i = 4'h0 ;
    axi_S07_awregion_i = 4'h0 ;
    axi_S07_awuser_i = 1'h0 ;
    axi_S07_wvalid_i = 1'h0 ;
    axi_S07_wdata_i = {SI_MAX_DATA_WIDTH_TOP{1'b0}} ;
    axi_S07_wstrb_i = {(SI_MAX_DATA_WIDTH_TOP/8){1'b0}} ;
    axi_S07_wlast_i = 1'h0 ;
    axi_S07_wuser_i = 1'h0 ;
    axi_S07_bready_i = 1'h0 ;
    axi_S07_arvalid_i = 1'h0 ;
    axi_S07_arid_i = {ID_WIDTH_TOP{1'b0}} ;
    axi_S07_araddr_i = {ADDR_WIDTH_TOP{1'b0}} ;
    axi_S07_arlen_i = 8'h0 ;
    axi_S07_arsize_i = 3'h0 ;
    axi_S07_arburst_i = 2'h0 ;
    axi_S07_arlock_i = 1'h0 ;
    axi_S07_arcache_i = 4'h0 ;
    axi_S07_arprot_i = 3'h0 ;
    axi_S07_arqos_i = 4'h0 ;
    axi_S07_arregion_i = 4'h0 ;
    axi_S07_aruser_i = 1'h0 ;
    axi_S07_rready_i = 1'h0 ;

    if(TOTAL_MGR_COUNT_TOP>=3) begin
      axi_S02_awvalid_i = axi_awvalid_o[2*1 +: 1];
      axi_S02_awid_i = axi_awid_o[2*ID_WIDTH_TOP +: ID_WIDTH_TOP] ;
      axi_S02_awaddr_i = axi_awaddr_o[2*ADDR_WIDTH_TOP +: ADDR_WIDTH_TOP] ;
      axi_S02_awlen_i = axi_awlen_o[2*AXI_LEN_WIDTH +: AXI_LEN_WIDTH] ;
      axi_S02_awsize_i = axi_awsize_o[2*3 +: 3] ;
      axi_S02_awburst_i = axi_awburst_o[2*2 +: 2] ;
      axi_S02_awqos_i = axi_awqos_o[2*4 +: 4] ;
      axi_S02_wvalid_i = axi_wvalid_o[2*1 +: 1] ;
      axi_S02_wdata_i = axi_wdata_o[2*SI_MAX_DATA_WIDTH_TOP +: SI_MAX_DATA_WIDTH_TOP] ;
      axi_S02_wstrb_i = axi_wstrb_o[2*SI_MAX_DATA_WIDTH_TOP/8 +: SI_MAX_DATA_WIDTH_TOP/8] ;
      axi_S02_wlast_i = axi_wlast_o[2*1 +: 1] ;
      axi_S02_bready_i = axi_bready_o[2*1 +: 1] ;
      axi_S02_arvalid_i = axi_arvalid_o[2*1 +: 1] ;
      axi_S02_arid_i = axi_arid_o[2*ID_WIDTH_TOP +: ID_WIDTH_TOP] ;
      axi_S02_araddr_i = axi_araddr_o[2*ADDR_WIDTH_TOP +: ADDR_WIDTH_TOP] ;
      axi_S02_arlen_i = axi_arlen_o[2*AXI_LEN_WIDTH +: AXI_LEN_WIDTH] ;
      axi_S02_arsize_i = axi_arsize_o[2*3 +: 3] ;
      axi_S02_arburst_i = axi_arburst_o[2*2 +: 2] ;
      axi_S02_arqos_i = axi_arqos_o[2*4 +: 4] ;
      axi_S02_rready_i = axi_rready_o[2*1 +: 1] ;
    end

    if(TOTAL_MGR_COUNT_TOP>=4) begin
      axi_S03_awvalid_i = axi_awvalid_o[3*1 +: 1];
      axi_S03_awid_i = axi_awid_o[3*ID_WIDTH_TOP +: ID_WIDTH_TOP] ;
      axi_S03_awaddr_i = axi_awaddr_o[3*ADDR_WIDTH_TOP +: ADDR_WIDTH_TOP] ;
      axi_S03_awlen_i = axi_awlen_o[3*AXI_LEN_WIDTH +: AXI_LEN_WIDTH] ;
      axi_S03_awsize_i = axi_awsize_o[3*3 +: 3] ;
      axi_S03_awburst_i = axi_awburst_o[3*2 +: 2] ;
      axi_S03_awqos_i = axi_awqos_o[3*4 +: 4] ;
      axi_S03_wvalid_i = axi_wvalid_o[3*1 +: 1] ;
      axi_S03_wdata_i = axi_wdata_o[3*SI_MAX_DATA_WIDTH_TOP +: SI_MAX_DATA_WIDTH_TOP] ;
      axi_S03_wstrb_i = axi_wstrb_o[3*SI_MAX_DATA_WIDTH_TOP/8 +: SI_MAX_DATA_WIDTH_TOP/8] ;
      axi_S03_wlast_i = axi_wlast_o[3*1 +: 1] ;
      axi_S03_bready_i = axi_bready_o[3*1 +: 1] ;
      axi_S03_arvalid_i = axi_arvalid_o[3*1 +: 1] ;
      axi_S03_arid_i = axi_arid_o[3*ID_WIDTH_TOP +: ID_WIDTH_TOP] ;
      axi_S03_araddr_i = axi_araddr_o[3*ADDR_WIDTH_TOP +: ADDR_WIDTH_TOP] ;
      axi_S03_arlen_i = axi_arlen_o[3*AXI_LEN_WIDTH +: AXI_LEN_WIDTH] ;
      axi_S03_arsize_i = axi_arsize_o[3*3 +: 3] ;
      axi_S03_arburst_i = axi_arburst_o[3*2 +: 2] ;
      axi_S03_arqos_i = axi_arqos_o[3*4 +: 4] ;
      axi_S03_rready_i = axi_rready_o[3*1 +: 1] ;
    end

    if(TOTAL_MGR_COUNT_TOP>=5) begin
      axi_S04_awvalid_i = axi_awvalid_o[4*1 +: 1];
      axi_S04_awid_i = axi_awid_o[4*ID_WIDTH_TOP +: ID_WIDTH_TOP] ;
      axi_S04_awaddr_i = axi_awaddr_o[4*ADDR_WIDTH_TOP +: ADDR_WIDTH_TOP] ;
      axi_S04_awlen_i = axi_awlen_o[4*AXI_LEN_WIDTH +: AXI_LEN_WIDTH] ;
      axi_S04_awsize_i = axi_awsize_o[4*3 +: 3] ;
      axi_S04_awburst_i = axi_awburst_o[4*2 +: 2] ;
      axi_S04_awqos_i = axi_awqos_o[4*4 +: 4] ;
      axi_S04_wvalid_i = axi_wvalid_o[4*1 +: 1] ;
      axi_S04_wdata_i = axi_wdata_o[4*SI_MAX_DATA_WIDTH_TOP +: SI_MAX_DATA_WIDTH_TOP] ;
      axi_S04_wstrb_i = axi_wstrb_o[4*SI_MAX_DATA_WIDTH_TOP/8 +: SI_MAX_DATA_WIDTH_TOP/8] ;
      axi_S04_wlast_i = axi_wlast_o[4*1 +: 1] ;
      axi_S04_bready_i = axi_bready_o[4*1 +: 1] ;
      axi_S04_arvalid_i = axi_arvalid_o[4*1 +: 1] ;
      axi_S04_arid_i = axi_arid_o[4*ID_WIDTH_TOP +: ID_WIDTH_TOP] ;
      axi_S04_araddr_i = axi_araddr_o[4*ADDR_WIDTH_TOP +: ADDR_WIDTH_TOP] ;
      axi_S04_arlen_i = axi_arlen_o[4*AXI_LEN_WIDTH +: AXI_LEN_WIDTH] ;
      axi_S04_arsize_i = axi_arsize_o[4*3 +: 3] ;
      axi_S04_arburst_i = axi_arburst_o[4*2 +: 2] ;
      axi_S04_arqos_i = axi_arqos_o[4*4 +: 4] ;
      axi_S04_rready_i = axi_rready_o[4*1 +: 1] ;
    end

    if(TOTAL_MGR_COUNT_TOP>=6) begin
      axi_S05_awvalid_i = axi_awvalid_o[5*1 +: 1];
      axi_S05_awid_i = axi_awid_o[5*ID_WIDTH_TOP +: ID_WIDTH_TOP] ;
      axi_S05_awaddr_i = axi_awaddr_o[5*ADDR_WIDTH_TOP +: ADDR_WIDTH_TOP] ;
      axi_S05_awlen_i = axi_awlen_o[5*AXI_LEN_WIDTH +: AXI_LEN_WIDTH] ;
      axi_S05_awsize_i = axi_awsize_o[5*3 +: 3] ;
      axi_S05_awburst_i = axi_awburst_o[5*2 +: 2] ;
      axi_S05_awqos_i = axi_awqos_o[5*4 +: 4] ;
      axi_S05_wvalid_i = axi_wvalid_o[5*1 +: 1] ;
      axi_S05_wdata_i = axi_wdata_o[5*SI_MAX_DATA_WIDTH_TOP +: SI_MAX_DATA_WIDTH_TOP] ;
      axi_S05_wstrb_i = axi_wstrb_o[5*SI_MAX_DATA_WIDTH_TOP/8 +: SI_MAX_DATA_WIDTH_TOP/8] ;
      axi_S05_wlast_i = axi_wlast_o[5*1 +: 1] ;
      axi_S05_bready_i = axi_bready_o[5*1 +: 1] ;
      axi_S05_arvalid_i = axi_arvalid_o[5*1 +: 1] ;
      axi_S05_arid_i = axi_arid_o[5*ID_WIDTH_TOP +: ID_WIDTH_TOP] ;
      axi_S05_araddr_i = axi_araddr_o[5*ADDR_WIDTH_TOP +: ADDR_WIDTH_TOP] ;
      axi_S05_arlen_i = axi_arlen_o[5*AXI_LEN_WIDTH +: AXI_LEN_WIDTH] ;
      axi_S05_arsize_i = axi_arsize_o[5*3 +: 3] ;
      axi_S05_arburst_i = axi_arburst_o[5*2 +: 2] ;
      axi_S05_arqos_i = axi_arqos_o[5*4 +: 4] ;
      axi_S05_rready_i = axi_rready_o[5*1 +: 1] ;
    end

    if(TOTAL_MGR_COUNT_TOP>=7) begin
      axi_S06_awvalid_i = axi_awvalid_o[6*1 +: 1];
      axi_S06_awid_i = axi_awid_o[6*ID_WIDTH_TOP +: ID_WIDTH_TOP] ;
      axi_S06_awaddr_i = axi_awaddr_o[6*ADDR_WIDTH_TOP +: ADDR_WIDTH_TOP] ;
      axi_S06_awlen_i = axi_awlen_o[6*AXI_LEN_WIDTH +: AXI_LEN_WIDTH] ;
      axi_S06_awsize_i = axi_awsize_o[6*3 +: 3] ;
      axi_S06_awburst_i = axi_awburst_o[6*2 +: 2] ;
      axi_S06_awqos_i = axi_awqos_o[6*4 +: 4] ;
      axi_S06_wvalid_i = axi_wvalid_o[6*1 +: 1] ;
      axi_S06_wdata_i = axi_wdata_o[6*SI_MAX_DATA_WIDTH_TOP +: SI_MAX_DATA_WIDTH_TOP] ;
      axi_S06_wstrb_i = axi_wstrb_o[6*SI_MAX_DATA_WIDTH_TOP/8 +: SI_MAX_DATA_WIDTH_TOP/8] ;
      axi_S06_wlast_i = axi_wlast_o[6*1 +: 1] ;
      axi_S06_bready_i = axi_bready_o[6*1 +: 1] ;
      axi_S06_arvalid_i = axi_arvalid_o[6*1 +: 1] ;
      axi_S06_arid_i = axi_arid_o[6*ID_WIDTH_TOP +: ID_WIDTH_TOP] ;
      axi_S06_araddr_i = axi_araddr_o[6*ADDR_WIDTH_TOP +: ADDR_WIDTH_TOP] ;
      axi_S06_arlen_i = axi_arlen_o[6*AXI_LEN_WIDTH +: AXI_LEN_WIDTH] ;
      axi_S06_arsize_i = axi_arsize_o[6*3 +: 3] ;
      axi_S06_arburst_i = axi_arburst_o[6*2 +: 2] ;
      axi_S06_arqos_i = axi_arqos_o[6*4 +: 4] ;
      axi_S06_rready_i = axi_rready_o[6*1 +: 1] ;
    end

    if(TOTAL_MGR_COUNT_TOP==8) begin
      axi_S07_awvalid_i = axi_awvalid_o[7*1 +: 1];
      axi_S07_awid_i = axi_awid_o[7*ID_WIDTH_TOP +: ID_WIDTH_TOP] ;
      axi_S07_awaddr_i = axi_awaddr_o[7*ADDR_WIDTH_TOP +: ADDR_WIDTH_TOP] ;
      axi_S07_awlen_i = axi_awlen_o[7*AXI_LEN_WIDTH +: AXI_LEN_WIDTH] ;
      axi_S07_awsize_i = axi_awsize_o[7*3 +: 3] ;
      axi_S07_awburst_i = axi_awburst_o[7*2 +: 2] ;
      axi_S07_awqos_i = axi_awqos_o[7*4 +: 4] ;
      axi_S07_wvalid_i = axi_wvalid_o[7*1 +: 1] ;
      axi_S07_wdata_i = axi_wdata_o[7*SI_MAX_DATA_WIDTH_TOP +: SI_MAX_DATA_WIDTH_TOP] ;
      axi_S07_wstrb_i = axi_wstrb_o[7*SI_MAX_DATA_WIDTH_TOP/8 +: SI_MAX_DATA_WIDTH_TOP/8] ;
      axi_S07_wlast_i = axi_wlast_o[7*1 +: 1] ;
      axi_S07_bready_i = axi_bready_o[7*1 +: 1] ;
      axi_S07_arvalid_i = axi_arvalid_o[7*1 +: 1] ;
      axi_S07_arid_i = axi_arid_o[7*ID_WIDTH_TOP +: ID_WIDTH_TOP] ;
      axi_S07_araddr_i = axi_araddr_o[7*ADDR_WIDTH_TOP +: ADDR_WIDTH_TOP] ;
      axi_S07_arlen_i = axi_arlen_o[7*AXI_LEN_WIDTH +: AXI_LEN_WIDTH] ;
      axi_S07_arsize_i = axi_arsize_o[7*3 +: 3] ;
      axi_S07_arburst_i = axi_arburst_o[7*2 +: 2] ;
      axi_S07_arqos_i = axi_arqos_o[7*4 +: 4] ;
      axi_S07_rready_i = axi_rready_o[7*1 +: 1] ;
    end
  end

  // ---------------------------------------------------------
  // Map from the MPMC AXI M* Ports to MC AXI ports
  // ---------------------------------------------------------
  assign axi_arvalid_i = axi_M00_arvalid_o[0];
  assign axi_arid_i = axi_M00_arid_o;
  assign axi_arlen_i = axi_M00_arlen_o;
  assign axi_arburst_i = axi_M00_arburst_o;
  assign axi_araddr_i = axi_M00_araddr_o;
  assign axi_M00_arready_i[0] = axi_arready_o;
  assign axi_arqos_i = axi_M00_arqos_o;
  assign axi_arsize_i = axi_M00_arsize_o;
  assign axi_M00_rresp_i = axi_rresp_o;
  assign axi_M00_rid_i = axi_rid_o;
  assign axi_M00_rdata_i = axi_rdata_o;
  assign axi_M00_rvalid_i[0] = axi_rvalid_o;
  assign axi_M00_rlast_i[0] = axi_rlast_o;
  assign axi_rready_i = axi_M00_rready_o;
  assign axi_bready_i = axi_M00_bready_o[0];
  assign axi_M00_bvalid_i[0] = axi_bvalid_o;
  assign axi_M00_bresp_i = axi_bresp_o;
  assign axi_M00_bid_i = axi_bid_o;
  assign axi_awvalid_i = axi_M00_awvalid_o[0];
  assign axi_awid_i = axi_M00_awid_o;
  assign axi_awlen_i = axi_M00_awlen_o;
  assign axi_awburst_i = axi_M00_awburst_o;
  assign axi_awsize_i = axi_M00_awsize_o;
  assign axi_awaddr_i = axi_M00_awaddr_o;
  assign axi_M00_awready_i[0] = axi_awready_o;
  assign axi_awqos_i = axi_M00_awqos_o;
  assign axi_wvalid_i = axi_M00_wvalid_o[0];
  assign axi_M00_wready_i[0] = axi_wready_o;
  assign axi_wdata_i = axi_M00_wdata_o;
  assign axi_wstrb_i = axi_M00_wstrb_o;
  assign axi_wlast_i = axi_M00_wlast_o[0];

  assign axi_S00_aclk_i = clk_w;
  assign axi_S00_aresetn_i = reset_n_i;
  assign axi_S01_aclk_i = clk_w;
  assign axi_S01_aresetn_i = reset_n_i;
  assign axi_S02_aclk_i = clk_w;
  assign axi_S02_aresetn_i = reset_n_i;
  assign axi_S03_aclk_i = clk_w;
  assign axi_S03_aresetn_i = reset_n_i;
  assign axi_S04_aclk_i = clk_w;
  assign axi_S04_aresetn_i = reset_n_i;
  assign axi_S05_aclk_i = clk_w;
  assign axi_S05_aresetn_i = reset_n_i;
  assign axi_S06_aclk_i = clk_w;
  assign axi_S06_aresetn_i = reset_n_i;
  assign axi_S07_aclk_i = clk_w;
  assign axi_S07_aresetn_i = reset_n_i;
  assign axi_M00_aclk_i = clk_w;
  assign axi_M00_aresetn_i = reset_n_i;

  generate
    if (AXI == 0) begin : BRIDGE
      // AXI4 Interface module
      lpddr4_mc_axi_iface_top #(
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
      assign trn_opr_i = SIM ? 9'h01E : ((CLK_FREQ >= 800) ?  9'h11F : 9'h01f);;
    end // INIT_EN

  endgenerate

  logic a_rd_err_r /* synthesis syn_preserve=1 */;
  logic a_rd_err_tg;
  logic a2s_rd_err_tg_r1;
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
  logic [AXI_DATA_WIDTH-9:0] rvl_wdata_r0 ;  // reduced logic to fit in reveal
  logic                      rvl_rvalid_r0;
  logic                      rvl_rready_r0;
  logic [AXI_DATA_WIDTH-9:0] rvl_rdata_r0 ;  // reduced logic to fit in reveal


  logic                      rvl_wvalid_r;
  logic                      rvl_wready_r;
  logic [AXI_DATA_WIDTH-9:0] rvl_wdata_r ;  // reduced logic to fit in reveal
  logic                      rvl_rvalid_r;
  logic                      rvl_rready_r;
  logic [AXI_DATA_WIDTH-9:0] rvl_rdata_r ;  // reduced logic to fit in reveal
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

    rvl_wvalid_r   <= rvl_wvalid_r0;
    rvl_wready_r   <= rvl_wready_r0;
    rvl_wdata_r    <= rvl_wdata_r0 ;
    rvl_rvalid_r   <= rvl_rvalid_r0;
    rvl_rready_r   <= rvl_rready_r0;
    rvl_rdata_r    <= rvl_rdata_r0 ;

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
    end
    else begin
      trig_r1         <= scratch_1_o[7:0] == 8'h12;
      trig_r2         <= trig_r1;
      trig_r3         <= trig_r2;
    end
  end
  assign test_port   = trig_r3    ; // for probing specific training state
  `endif

  `include "dut_inst.v"
`ifdef MC_LAV_SUPPORTED
  `include "avant_mc_inst.v"
`endif

  //-------------------------------------//
  //-------- output assignments  --------//
  //-------------------------------------//

  assign LED[11:0]    = {~LED_array2[0],~LED_array[0], led_o[9:0]};
  assign ddr_odt_ca_o = 1'b0;  // unused because we use implicit ODT
  //--------------------------------------------//
  //-------- for debugging with Reveal  --------//
  //--------------------------------------------//

  always @(posedge clk_w or negedge arst_n) begin
    if (!arst_n) begin
        rvl_a_test_num_r   <= {GEN_OUT_WIDTH{1'b0}};
        a_rd_error_occur_r <= 1'b0;
    end
    else begin
        rvl_a_test_num_r   <= a_test_num_w;
        a_rd_error_occur_r <= a_rd_err_o;
    end
  end

  always @(posedge sclk_o or negedge srst_n) begin
    if (!srst_n) begin
        s_rd_error_occur_r1    <= 1'b0;
        s_rd_error_occur_r2    <= 1'b0;
        rvl_s_rd_error_occur_r <= 1'b0;
    end
    else begin
        s_rd_error_occur_r1    <= a_rd_error_occur_r;
        s_rd_error_occur_r2    <= s_rd_error_occur_r1;
        rvl_s_rd_error_occur_r <= s_rd_error_occur_r2;
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

`else
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


  `include "kitcar.v"
  `include "pll_aclk_pclk.v"
  `include "apb2init.sv"
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
  `include "traffic_gen/lscc_ram_dp_true.v"
  `include "traffic_gen/sysmem0.v"
  `include "traffic_gen/sysmem2.v"
  `include "traffic_gen/sysmem3.v"
  `include "traffic_gen/sysmem4.v"
  `include "traffic_gen/sysmem0_sim.v"
  `include "traffic_gen/sysmem2_sim.v"
  `include "traffic_gen/sysmem3_sim.v"
  `include "traffic_gen/sysmem4_sim.v"
  `include "traffic_gen/uart0.v"
  `include "traffic_gen/mc_axi4_traffic_gen.v"
  `include "axi_bridge/lscc_ram_dp.v"
  `include "axi_bridge/lpddr4_mc_dpram.v"
  `include "axi_bridge/lpddr4_mc_sch_ebr.v"
  `include "axi_bridge/lpddr4_mc_double_sync.sv"
  `include "axi_bridge/lpddr4_mc_toggle_sync.sv"
  `include "axi_bridge/lpddr4_mc_sync_fifo.v"
  `include "axi_bridge/lpddr4_mc_reorder_buffer.sv"
  `include "axi_bridge/lpddr4_mc_axi_slv_wr.sv"
  `include "axi_bridge/lpddr4_mc_axi_slv_rd.sv"
  `include "axi_bridge/lpddr4_mc_axi_iface_top.sv"
  `include "mc.sv"

  // For debugging the DQS/DQ/DMI on the board
  // Look for dbg_rddata_en_o, dbg_wddata_en_o in ports.xml
  //`define DQSDQ_DEBUG_EN

  module eval_top #(
    // SIM=0 for implementation to FPGA device
    // SIM=1 for skipping training for faster simulation
    parameter SIM = 0  // set to 1 for maverick regression
  )(
      // inputs
    clk_ext       ,     // 27M ext clock
  //    clk_i         ,
      rstn_i        ,     // from SW1 pushbutton
      pll_refclk_i  ,     // 100MHz
      uart_rxd_i    ,
      // output
      init_done_o   ,
      uart_txd_o    ,
      LED           ,     // to LEDs (LED0-9)
      fs            ,
      cmos_xclr     ,
      mipi_clk      ,
      out_clk0      ,
      gnd_clk       ,
      out_clk1      ,
      sim_o         ,     // SIM paramter value to tb_top
  `ifdef DQSDQ_DEBUG_EN
      dbg_rddata_en_out,
      dbg_wddata_en_out,
  `endif
  //    ddr_ck_t_o    ,
  //    ddr_ck_c_o    ,
      ddr_ck_o      ,
      ddr_cke_o     ,
      ddr_cs_o      ,
      ddr_ca_o      ,
      ddr_odt_ca_o  ,
      ddr_reset_n_o ,
      ddr_dq_io     ,
      ddr_dqs_io    ,
      ddr_dmi_io
  );

  `include "dut_params.v"
  `include "cpnx_mc_params.v"
  localparam BI_WR_DATA_FIFO_DEPTH  = 8;
  localparam GEN_OUT_WIDTH          = 4;

  //-----------------------------------------------------------------------------
  //                                                                          --
  //                      PORT DEFINITION
  //                                                                          --
  //----------------------------------------------------------------------------
  input   wire                   clk_ext             ;     // 27M ext clock
  //input   wire                   clk_i               ;
  input   wire                   rstn_i              ;     // from SW1 pushbutton
  input   wire                   pll_refclk_i        ;     //100MHz since fs=3'b001 // from 125MHz Clk
  input   wire                   uart_rxd_i          ;
  //input   wire                 perf_tst_en_i       ;

  // outputs
  output  wire                   uart_txd_o          ;
  output  wire                   init_done_o         ;
  inout         [11:0]            LED    /* synthesis syn_force_pads=1 */;     // to LEDs (LED0-9) /
  output                         sim_o               ;
  output  wire  [2:0]            fs                  ;
  output  wire                   cmos_xclr           ;
  output  wire                   mipi_clk            ;
  output  wire                   out_clk0            ;
  output  wire                   gnd_clk             ;
  output  wire                   out_clk1            ;
  `ifdef DQSDQ_DEBUG_EN
  output  logic                  dbg_rddata_en_out   ;
  output  logic                  dbg_wddata_en_out   ;
  `endif
  //output       [0:0]             ddr_ck_t_o          ;
  //output       [0:0]             ddr_ck_c_o          ;
  output       [0:0]             ddr_ck_o            ;
  output       [0:0]             ddr_cke_o           ;
  output       [0:0]             ddr_cs_o            ;
  output       [5:0]             ddr_ca_o            ;
  output                         ddr_odt_ca_o        ;
  output                         ddr_reset_n_o       ;
  inout        [BUS_WIDTH -1 :0] ddr_dq_io           ;
  inout        [DQS_WIDTH -1:0]  ddr_dqs_io          ;
  inout        [DQS_WIDTH -1:0]  ddr_dmi_io          ;

  //------------------------------
  // INTERNAL SIGNAL DECLARATIONS:
  //------------------------------
  // parameters (constants)

  // wires (assigns)
  wire          pll_out   ;

  wire    [7:0] LED_array ;
  wire    [7:0] LED_array2;
  wire    [9:0] led_o     ;
  wire                       aclk_i        ;
  wire                       pll_rst_n_i   ;
  wire                       rst_n_i       ;
  wire                       pclk_i        ;
  wire                       preset_n_i    ;
  wire                       pll_lock_o    ;
  wire                       sclk_o        ;
  wire                       irq_o         ;
  wire                       init_start_i  ;
  wire  [ 7:0]               trn_opr_i     ;
  //wire                       init_done_o   ;
  wire                       trn_err_o     ;

  wire                       apb_penable_i ;
  wire                       apb_psel_i    ;
  wire                       apb_pwrite_i  ;
  wire  [APB_ADDR_WIDTH-1:0] apb_paddr_i   ;
  wire  [APB_DATA_WIDTH-1:0] apb_pwdata_i  ;
  logic                      apb_pready_o  ;
  wire                       apb_pslverr_o ;
  logic [APB_DATA_WIDTH-1:0] apb_prdata_o  ;

  reg                        prst_n        ;
  reg                        prst_n_r0     ;
  reg                        prst_n_r1     ;

  reg                        areset_n      ;
  reg                        areset_n_r0   ;
  reg                        areset_n_r1   ;

  reg                        sreset_n      ;
  reg                        sreset_n_r0   ;
  reg                        sreset_n_r1   ;



  logic                         clk_w      ;
  logic                         areset_n_i ;
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
  logic                         axi_rvalid_o   /* synthesis syn_keep=1 */;
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
  logic [AXI_LEN_WIDTH-1:0]          wr_req_len_i     ;
  logic [2:0]                        wr_req_size_i    ;
  logic                              wr_ready_o       ;
  logic                              wr_valid_i       ;
  logic [BI_RD_DATA_Q_WIDTH-1:0]     wr_data_i        ;
  logic [(BI_RD_DATA_Q_WIDTH/8)-1:0] wr_byte_en_i     ;
  logic                              wr_data_last_i   ;
  logic                              rd_req_ready_o   ;
  logic                              rd_req_valid_i   ;
  logic [AXI_ID_WIDTH-1:0]           rd_req_id_i      ;
  logic [ORDER_ID_WIDTH-1:0]         rd_req_order_id_i;
  logic [AXI_ADDR_WIDTH-1:0]         rd_req_addr_i    ;
  logic [AXI_LEN_WIDTH-1:0]          rd_req_len_i     ;
  logic [2:0]                        rd_req_size_i    ;
  logic                              rd_rsp_ready_i   ;
  logic                              rd_rsp_valid_o   ;
  logic [AXI_ID_WIDTH-1:0]           rd_rsp_id_o      ;
  logic [ORDER_ID_WIDTH-1:0]         rd_rsp_order_id_o;
  logic [BI_RD_DATA_Q_WIDTH -1 :0]   rd_rsp_data_o    ;
  logic [AXI_LEN_WIDTH-1:0]          rd_rsp_len_o     ;
  logic [3-1:0]                      rd_rsp_size_o    ;
  logic [7:0]                        rd_rsp_buff_addr_o;

  logic                         arst_w;
  logic                         osc_clk_90;

  logic [TOTAL_MGR_COUNT_TOP*GEN_OUT_WIDTH-1:0] a_test_num_w;
  logic [TOTAL_MGR_COUNT_TOP-1:0] a_rd_error_occur_w;
  logic [TOTAL_MGR_COUNT_TOP-1:0] a_rd_error_occur_r;
  logic [TOTAL_MGR_COUNT_TOP-1:0] s_rd_error_occur_r1/* synthesis syn_preserve=1 CDC_Register=2 */;
  logic [TOTAL_MGR_COUNT_TOP-1:0] s_rd_error_occur_r2;
  logic [TOTAL_MGR_COUNT_TOP*GEN_OUT_WIDTH-1:0] rvl_a_test_num_r;
  logic [TOTAL_MGR_COUNT_TOP*GEN_OUT_WIDTH-1:0] a_test_num_r     /* synthesis syn_preserve=1 */;
  logic [TOTAL_MGR_COUNT_TOP*GEN_OUT_WIDTH-1:0] a2s_test_num_r1  /* synthesis syn_preserve=1 CDC_Register=2 */;
  logic [TOTAL_MGR_COUNT_TOP*GEN_OUT_WIDTH-1:0] a2s_test_num_r2 ;
  logic [TOTAL_MGR_COUNT_TOP*GEN_OUT_WIDTH-1:0] rvl_s_test_num_r;
  logic                     rvl_s_rd_error_occur_r;
  `ifdef DQSDQ_DEBUG_EN
  logic                     dbg_rddata_en_o;
  logic                     dbg_wddata_en_o;
  `endif

  // Declare all possible ports for the dut here.
  // Some may be unused, depending on cofiguration
  logic [0:0] axi_S00_aclk_i;
  logic [0:0] axi_S00_aresetn_i;
  logic [0:0] axi_S01_aclk_i;
  logic [0:0] axi_S01_aresetn_i;
  logic [0:0] axi_S02_aclk_i;
  logic [0:0] axi_S02_aresetn_i;
  logic [0:0] axi_S03_aclk_i;
  logic [0:0] axi_S03_aresetn_i;
  logic [0:0] axi_S04_aclk_i;
  logic [0:0] axi_S04_aresetn_i;
  logic [0:0] axi_S05_aclk_i;
  logic [0:0] axi_S05_aresetn_i;
  logic [0:0] axi_S06_aclk_i;
  logic [0:0] axi_S06_aresetn_i;
  logic [0:0] axi_S07_aclk_i;
  logic [0:0] axi_S07_aresetn_i;
  logic [0:0] axi_M00_aclk_i;
  logic [0:0] axi_M00_aresetn_i ;

  logic [0:0] axi_S00_awvalid_i ;
  logic [ID_WIDTH_TOP-1:0] axi_S00_awid_i ;
  logic [ADDR_WIDTH_TOP-1:0] axi_S00_awaddr_i ;
  logic [7:0] axi_S00_awlen_i ;
  logic [2:0] axi_S00_awsize_i ;
  logic [1:0] axi_S00_awburst_i ;
  logic [0:0] axi_S00_awlock_i ;
  logic [3:0] axi_S00_awcache_i ;
  logic [2:0] axi_S00_awprot_i ;
  logic [3:0] axi_S00_awqos_i ;
  logic [3:0] axi_S00_awregion_i ;
  logic [0:0] axi_S00_awuser_i ;
  logic [0:0] axi_S00_awready_o ;
  logic [0:0] axi_S00_wvalid_i ;
  logic [SI_MAX_DATA_WIDTH_TOP-1:0] axi_S00_wdata_i ;
  logic [(SI_MAX_DATA_WIDTH_TOP/8)-1:0] axi_S00_wstrb_i ;
  logic [0:0] axi_S00_wlast_i ;
  logic [0:0] axi_S00_wuser_i ;
  logic [0:0] axi_S00_wready_o ;
  logic [0:0] axi_S00_bready_i ;
  logic [0:0] axi_S00_bvalid_o ;
  logic [ID_WIDTH_TOP-1:0] axi_S00_bid_o ;
  logic [1:0] axi_S00_bresp_o ;
  logic [0:0] axi_S00_buser_o ;
  logic [0:0] axi_S00_arvalid_i ;
  logic [ID_WIDTH_TOP-1:0] axi_S00_arid_i ;
  logic [ADDR_WIDTH_TOP-1:0] axi_S00_araddr_i ;
  logic [7:0] axi_S00_arlen_i ;
  logic [2:0] axi_S00_arsize_i ;
  logic [1:0] axi_S00_arburst_i ;
  logic [0:0] axi_S00_arlock_i ;
  logic [3:0] axi_S00_arcache_i ;
  logic [2:0] axi_S00_arprot_i ;
  logic [3:0] axi_S00_arqos_i ;
  logic [3:0] axi_S00_arregion_i ;
  logic [0:0] axi_S00_aruser_i ;
  logic [0:0] axi_S00_arready_o ;
  logic [0:0] axi_S00_rready_i ;
  logic [0:0] axi_S00_rvalid_o ;
  logic [ID_WIDTH_TOP-1:0] axi_S00_rid_o ;
  logic [SI_MAX_DATA_WIDTH_TOP-1:0] axi_S00_rdata_o ;
  logic [1:0] axi_S00_rresp_o ;
  logic [0:0] axi_S00_rlast_o ;
  logic [0:0] axi_S00_ruser_o ;

  logic [0:0] axi_S01_awvalid_i ;
  logic [ID_WIDTH_TOP-1:0] axi_S01_awid_i ;
  logic [ADDR_WIDTH_TOP-1:0] axi_S01_awaddr_i ;
  logic [7:0] axi_S01_awlen_i ;
  logic [2:0] axi_S01_awsize_i ;
  logic [1:0] axi_S01_awburst_i ;
  logic [0:0] axi_S01_awlock_i ;
  logic [3:0] axi_S01_awcache_i ;
  logic [2:0] axi_S01_awprot_i ;
  logic [3:0] axi_S01_awqos_i ;
  logic [3:0] axi_S01_awregion_i ;
  logic [0:0] axi_S01_awuser_i ;
  logic [0:0] axi_S01_awready_o ;
  logic [0:0] axi_S01_wvalid_i ;
  logic [SI_MAX_DATA_WIDTH_TOP-1:0] axi_S01_wdata_i ;
  logic [(SI_MAX_DATA_WIDTH_TOP/8)-1:0] axi_S01_wstrb_i ;
  logic [0:0] axi_S01_wlast_i ;
  logic [0:0] axi_S01_wuser_i ;
  logic [0:0] axi_S01_wready_o ;
  logic [0:0] axi_S01_bready_i ;
  logic [0:0] axi_S01_bvalid_o ;
  logic [ID_WIDTH_TOP-1:0] axi_S01_bid_o ;
  logic [1:0] axi_S01_bresp_o ;
  logic [0:0] axi_S01_buser_o ;
  logic [0:0] axi_S01_arvalid_i ;
  logic [ID_WIDTH_TOP-1:0] axi_S01_arid_i ;
  logic [ADDR_WIDTH_TOP-1:0] axi_S01_araddr_i ;
  logic [7:0] axi_S01_arlen_i ;
  logic [2:0] axi_S01_arsize_i ;
  logic [1:0] axi_S01_arburst_i ;
  logic [0:0] axi_S01_arlock_i ;
  logic [3:0] axi_S01_arcache_i ;
  logic [2:0] axi_S01_arprot_i ;
  logic [3:0] axi_S01_arqos_i ;
  logic [3:0] axi_S01_arregion_i ;
  logic [0:0] axi_S01_aruser_i ;
  logic [0:0] axi_S01_arready_o ;
  logic [0:0] axi_S01_rready_i ;
  logic [0:0] axi_S01_rvalid_o ;
  logic [ID_WIDTH_TOP-1:0] axi_S01_rid_o ;
  logic [SI_MAX_DATA_WIDTH_TOP-1:0] axi_S01_rdata_o ;
  logic [1:0] axi_S01_rresp_o ;
  logic [0:0] axi_S01_rlast_o ;
  logic [0:0] axi_S01_ruser_o ;

  logic [0:0] axi_S02_awvalid_i ;
  logic [ID_WIDTH_TOP-1:0] axi_S02_awid_i ;
  logic [ADDR_WIDTH_TOP-1:0] axi_S02_awaddr_i ;
  logic [7:0] axi_S02_awlen_i ;
  logic [2:0] axi_S02_awsize_i ;
  logic [1:0] axi_S02_awburst_i ;
  logic [0:0] axi_S02_awlock_i ;
  logic [3:0] axi_S02_awcache_i ;
  logic [2:0] axi_S02_awprot_i ;
  logic [3:0] axi_S02_awqos_i ;
  logic [3:0] axi_S02_awregion_i ;
  logic [0:0] axi_S02_awuser_i ;
  logic [0:0] axi_S02_awready_o ;
  logic [0:0] axi_S02_wvalid_i ;
  logic [SI_MAX_DATA_WIDTH_TOP-1:0] axi_S02_wdata_i ;
  logic [(SI_MAX_DATA_WIDTH_TOP/8)-1:0] axi_S02_wstrb_i ;
  logic [0:0] axi_S02_wlast_i ;
  logic [0:0] axi_S02_wuser_i ;
  logic [0:0] axi_S02_wready_o ;
  logic [0:0] axi_S02_bready_i ;
  logic [0:0] axi_S02_bvalid_o ;
  logic [ID_WIDTH_TOP-1:0] axi_S02_bid_o ;
  logic [1:0] axi_S02_bresp_o ;
  logic [0:0] axi_S02_buser_o ;
  logic [0:0] axi_S02_arvalid_i ;
  logic [ID_WIDTH_TOP-1:0] axi_S02_arid_i ;
  logic [ADDR_WIDTH_TOP-1:0] axi_S02_araddr_i ;
  logic [7:0] axi_S02_arlen_i ;
  logic [2:0] axi_S02_arsize_i ;
  logic [1:0] axi_S02_arburst_i ;
  logic [0:0] axi_S02_arlock_i ;
  logic [3:0] axi_S02_arcache_i ;
  logic [2:0] axi_S02_arprot_i ;
  logic [3:0] axi_S02_arqos_i ;
  logic [3:0] axi_S02_arregion_i ;
  logic [0:0] axi_S02_aruser_i ;
  logic [0:0] axi_S02_arready_o ;
  logic [0:0] axi_S02_rready_i ;
  logic [0:0] axi_S02_rvalid_o ;
  logic [ID_WIDTH_TOP-1:0] axi_S02_rid_o ;
  logic [SI_MAX_DATA_WIDTH_TOP-1:0] axi_S02_rdata_o ;
  logic [1:0] axi_S02_rresp_o ;
  logic [0:0] axi_S02_rlast_o ;
  logic [0:0] axi_S02_ruser_o ;

  logic [0:0] axi_S03_awvalid_i ;
  logic [ID_WIDTH_TOP-1:0] axi_S03_awid_i ;
  logic [ADDR_WIDTH_TOP-1:0] axi_S03_awaddr_i ;
  logic [7:0] axi_S03_awlen_i ;
  logic [2:0] axi_S03_awsize_i ;
  logic [1:0] axi_S03_awburst_i ;
  logic [0:0] axi_S03_awlock_i ;
  logic [3:0] axi_S03_awcache_i ;
  logic [2:0] axi_S03_awprot_i ;
  logic [3:0] axi_S03_awqos_i ;
  logic [3:0] axi_S03_awregion_i ;
  logic [0:0] axi_S03_awuser_i ;
  logic [0:0] axi_S03_awready_o ;
  logic [0:0] axi_S03_wvalid_i ;
  logic [SI_MAX_DATA_WIDTH_TOP-1:0] axi_S03_wdata_i ;
  logic [(SI_MAX_DATA_WIDTH_TOP/8)-1:0] axi_S03_wstrb_i ;
  logic [0:0] axi_S03_wlast_i ;
  logic [0:0] axi_S03_wuser_i ;
  logic [0:0] axi_S03_wready_o ;
  logic [0:0] axi_S03_bready_i ;
  logic [0:0] axi_S03_bvalid_o ;
  logic [ID_WIDTH_TOP-1:0] axi_S03_bid_o ;
  logic [1:0] axi_S03_bresp_o ;
  logic [0:0] axi_S03_buser_o ;
  logic [0:0] axi_S03_arvalid_i ;
  logic [ID_WIDTH_TOP-1:0] axi_S03_arid_i ;
  logic [ADDR_WIDTH_TOP-1:0] axi_S03_araddr_i ;
  logic [7:0] axi_S03_arlen_i ;
  logic [2:0] axi_S03_arsize_i ;
  logic [1:0] axi_S03_arburst_i ;
  logic [0:0] axi_S03_arlock_i ;
  logic [3:0] axi_S03_arcache_i ;
  logic [2:0] axi_S03_arprot_i ;
  logic [3:0] axi_S03_arqos_i ;
  logic [3:0] axi_S03_arregion_i ;
  logic [0:0] axi_S03_aruser_i ;
  logic [0:0] axi_S03_arready_o ;
  logic [0:0] axi_S03_rready_i ;
  logic [0:0] axi_S03_rvalid_o ;
  logic [ID_WIDTH_TOP-1:0] axi_S03_rid_o ;
  logic [SI_MAX_DATA_WIDTH_TOP-1:0] axi_S03_rdata_o ;
  logic [1:0] axi_S03_rresp_o ;
  logic [0:0] axi_S03_rlast_o ;
  logic [0:0] axi_S03_ruser_o ;

  logic [0:0] axi_S04_awvalid_i ;
  logic [ID_WIDTH_TOP-1:0] axi_S04_awid_i ;
  logic [ADDR_WIDTH_TOP-1:0] axi_S04_awaddr_i ;
  logic [7:0] axi_S04_awlen_i ;
  logic [2:0] axi_S04_awsize_i ;
  logic [1:0] axi_S04_awburst_i ;
  logic [0:0] axi_S04_awlock_i ;
  logic [3:0] axi_S04_awcache_i ;
  logic [2:0] axi_S04_awprot_i ;
  logic [3:0] axi_S04_awqos_i ;
  logic [3:0] axi_S04_awregion_i ;
  logic [0:0] axi_S04_awuser_i ;
  logic [0:0] axi_S04_awready_o ;
  logic [0:0] axi_S04_wvalid_i ;
  logic [SI_MAX_DATA_WIDTH_TOP-1:0] axi_S04_wdata_i ;
  logic [(SI_MAX_DATA_WIDTH_TOP/8)-1:0] axi_S04_wstrb_i ;
  logic [0:0] axi_S04_wlast_i ;
  logic [0:0] axi_S04_wuser_i ;
  logic [0:0] axi_S04_wready_o ;
  logic [0:0] axi_S04_bready_i ;
  logic [0:0] axi_S04_bvalid_o ;
  logic [ID_WIDTH_TOP-1:0] axi_S04_bid_o ;
  logic [1:0] axi_S04_bresp_o ;
  logic [0:0] axi_S04_buser_o ;
  logic [0:0] axi_S04_arvalid_i ;
  logic [ID_WIDTH_TOP-1:0] axi_S04_arid_i ;
  logic [ADDR_WIDTH_TOP-1:0] axi_S04_araddr_i ;
  logic [7:0] axi_S04_arlen_i ;
  logic [2:0] axi_S04_arsize_i ;
  logic [1:0] axi_S04_arburst_i ;
  logic [0:0] axi_S04_arlock_i ;
  logic [3:0] axi_S04_arcache_i ;
  logic [2:0] axi_S04_arprot_i ;
  logic [3:0] axi_S04_arqos_i ;
  logic [3:0] axi_S04_arregion_i ;
  logic [0:0] axi_S04_aruser_i ;
  logic [0:0] axi_S04_arready_o ;
  logic [0:0] axi_S04_rready_i ;
  logic [0:0] axi_S04_rvalid_o ;
  logic [ID_WIDTH_TOP-1:0] axi_S04_rid_o ;
  logic [SI_MAX_DATA_WIDTH_TOP-1:0] axi_S04_rdata_o ;
  logic [1:0] axi_S04_rresp_o ;
  logic [0:0] axi_S04_rlast_o ;
  logic [0:0] axi_S04_ruser_o ;

  logic [0:0] axi_S05_awvalid_i ;
  logic [ID_WIDTH_TOP-1:0] axi_S05_awid_i ;
  logic [ADDR_WIDTH_TOP-1:0] axi_S05_awaddr_i ;
  logic [7:0] axi_S05_awlen_i ;
  logic [2:0] axi_S05_awsize_i ;
  logic [1:0] axi_S05_awburst_i ;
  logic [0:0] axi_S05_awlock_i ;
  logic [3:0] axi_S05_awcache_i ;
  logic [2:0] axi_S05_awprot_i ;
  logic [3:0] axi_S05_awqos_i ;
  logic [3:0] axi_S05_awregion_i ;
  logic [0:0] axi_S05_awuser_i ;
  logic [0:0] axi_S05_awready_o ;
  logic [0:0] axi_S05_wvalid_i ;
  logic [SI_MAX_DATA_WIDTH_TOP-1:0] axi_S05_wdata_i ;
  logic [(SI_MAX_DATA_WIDTH_TOP/8)-1:0] axi_S05_wstrb_i ;
  logic [0:0] axi_S05_wlast_i ;
  logic [0:0] axi_S05_wuser_i ;
  logic [0:0] axi_S05_wready_o ;
  logic [0:0] axi_S05_bready_i ;
  logic [0:0] axi_S05_bvalid_o ;
  logic [ID_WIDTH_TOP-1:0] axi_S05_bid_o ;
  logic [1:0] axi_S05_bresp_o ;
  logic [0:0] axi_S05_buser_o ;
  logic [0:0] axi_S05_arvalid_i ;
  logic [ID_WIDTH_TOP-1:0] axi_S05_arid_i ;
  logic [ADDR_WIDTH_TOP-1:0] axi_S05_araddr_i ;
  logic [7:0] axi_S05_arlen_i ;
  logic [2:0] axi_S05_arsize_i ;
  logic [1:0] axi_S05_arburst_i ;
  logic [0:0] axi_S05_arlock_i ;
  logic [3:0] axi_S05_arcache_i ;
  logic [2:0] axi_S05_arprot_i ;
  logic [3:0] axi_S05_arqos_i ;
  logic [3:0] axi_S05_arregion_i ;
  logic [0:0] axi_S05_aruser_i ;
  logic [0:0] axi_S05_arready_o ;
  logic [0:0] axi_S05_rready_i ;
  logic [0:0] axi_S05_rvalid_o ;
  logic [ID_WIDTH_TOP-1:0] axi_S05_rid_o ;
  logic [SI_MAX_DATA_WIDTH_TOP-1:0] axi_S05_rdata_o ;
  logic [1:0] axi_S05_rresp_o ;
  logic [0:0] axi_S05_rlast_o ;
  logic [0:0] axi_S05_ruser_o ;

  logic [0:0] axi_S06_awvalid_i ;
  logic [ID_WIDTH_TOP-1:0] axi_S06_awid_i ;
  logic [ADDR_WIDTH_TOP-1:0] axi_S06_awaddr_i ;
  logic [7:0] axi_S06_awlen_i ;
  logic [2:0] axi_S06_awsize_i ;
  logic [1:0] axi_S06_awburst_i ;
  logic [0:0] axi_S06_awlock_i ;
  logic [3:0] axi_S06_awcache_i ;
  logic [2:0] axi_S06_awprot_i ;
  logic [3:0] axi_S06_awqos_i ;
  logic [3:0] axi_S06_awregion_i ;
  logic [0:0] axi_S06_awuser_i ;
  logic [0:0] axi_S06_awready_o ;
  logic [0:0] axi_S06_wvalid_i ;
  logic [SI_MAX_DATA_WIDTH_TOP-1:0] axi_S06_wdata_i ;
  logic [(SI_MAX_DATA_WIDTH_TOP/8)-1:0] axi_S06_wstrb_i ;
  logic [0:0] axi_S06_wlast_i ;
  logic [0:0] axi_S06_wuser_i ;
  logic [0:0] axi_S06_wready_o ;
  logic [0:0] axi_S06_bready_i ;
  logic [0:0] axi_S06_bvalid_o ;
  logic [ID_WIDTH_TOP-1:0] axi_S06_bid_o ;
  logic [1:0] axi_S06_bresp_o ;
  logic [0:0] axi_S06_buser_o ;
  logic [0:0] axi_S06_arvalid_i ;
  logic [ID_WIDTH_TOP-1:0] axi_S06_arid_i ;
  logic [ADDR_WIDTH_TOP-1:0] axi_S06_araddr_i ;
  logic [7:0] axi_S06_arlen_i ;
  logic [2:0] axi_S06_arsize_i ;
  logic [1:0] axi_S06_arburst_i ;
  logic [0:0] axi_S06_arlock_i ;
  logic [3:0] axi_S06_arcache_i ;
  logic [2:0] axi_S06_arprot_i ;
  logic [3:0] axi_S06_arqos_i ;
  logic [3:0] axi_S06_arregion_i ;
  logic [0:0] axi_S06_aruser_i ;
  logic [0:0] axi_S06_arready_o ;
  logic [0:0] axi_S06_rready_i ;
  logic [0:0] axi_S06_rvalid_o ;
  logic [ID_WIDTH_TOP-1:0] axi_S06_rid_o ;
  logic [SI_MAX_DATA_WIDTH_TOP-1:0] axi_S06_rdata_o ;
  logic [1:0] axi_S06_rresp_o ;
  logic [0:0] axi_S06_rlast_o ;
  logic [0:0] axi_S06_ruser_o ;

  logic [0:0] axi_S07_awvalid_i ;
  logic [ID_WIDTH_TOP-1:0] axi_S07_awid_i ;
  logic [ADDR_WIDTH_TOP-1:0] axi_S07_awaddr_i ;
  logic [7:0] axi_S07_awlen_i ;
  logic [2:0] axi_S07_awsize_i ;
  logic [1:0] axi_S07_awburst_i ;
  logic [0:0] axi_S07_awlock_i ;
  logic [3:0] axi_S07_awcache_i ;
  logic [2:0] axi_S07_awprot_i ;
  logic [3:0] axi_S07_awqos_i ;
  logic [3:0] axi_S07_awregion_i ;
  logic [0:0] axi_S07_awuser_i ;
  logic [0:0] axi_S07_awready_o ;
  logic [0:0] axi_S07_wvalid_i ;
  logic [SI_MAX_DATA_WIDTH_TOP-1:0] axi_S07_wdata_i ;
  logic [(SI_MAX_DATA_WIDTH_TOP/8)-1:0] axi_S07_wstrb_i ;
  logic [0:0] axi_S07_wlast_i ;
  logic [0:0] axi_S07_wuser_i ;
  logic [0:0] axi_S07_wready_o ;
  logic [0:0] axi_S07_bready_i ;
  logic [0:0] axi_S07_bvalid_o ;
  logic [ID_WIDTH_TOP-1:0] axi_S07_bid_o ;
  logic [1:0] axi_S07_bresp_o ;
  logic [0:0] axi_S07_buser_o ;
  logic [0:0] axi_S07_arvalid_i ;
  logic [ID_WIDTH_TOP-1:0] axi_S07_arid_i ;
  logic [ADDR_WIDTH_TOP-1:0] axi_S07_araddr_i ;
  logic [7:0] axi_S07_arlen_i ;
  logic [2:0] axi_S07_arsize_i ;
  logic [1:0] axi_S07_arburst_i ;
  logic [0:0] axi_S07_arlock_i ;
  logic [3:0] axi_S07_arcache_i ;
  logic [2:0] axi_S07_arprot_i ;
  logic [3:0] axi_S07_arqos_i ;
  logic [3:0] axi_S07_arregion_i ;
  logic [0:0] axi_S07_aruser_i ;
  logic [0:0] axi_S07_arready_o ;
  logic [0:0] axi_S07_rready_i ;
  logic [0:0] axi_S07_rvalid_o ;
  logic [ID_WIDTH_TOP-1:0] axi_S07_rid_o ;
  logic [SI_MAX_DATA_WIDTH_TOP-1:0] axi_S07_rdata_o ;
  logic [1:0] axi_S07_rresp_o ;
  logic [0:0] axi_S07_rlast_o ;
  logic [0:0] axi_S07_ruser_o ;

  logic [0:0] axi_M00_awvalid_o ;
  logic [ID_WIDTH_TOP-1:0] axi_M00_awid_o ;
  logic [ADDR_WIDTH_TOP-1:0] axi_M00_awaddr_o ;
  logic [7:0] axi_M00_awlen_o ;
  logic [2:0] axi_M00_awsize_o ;
  logic [1:0] axi_M00_awburst_o ;
  logic [0:0] axi_M00_awlock_o ;
  logic [3:0] axi_M00_awcache_o ;
  logic [2:0] axi_M00_awprot_o ;
  logic [3:0] axi_M00_awqos_o ;
  logic [3:0] axi_M00_awregion_o ;
  logic [0:0] axi_M00_awuser_o ;
  logic [0:0] axi_M00_awready_i ;
  logic [0:0] axi_M00_wvalid_o ;
  logic [MI_DATA_WIDTH_TOP-1:0] axi_M00_wdata_o ;
  logic [(MI_DATA_WIDTH_TOP/8)-1:0] axi_M00_wstrb_o ;
  logic [0:0] axi_M00_wlast_o ;
  logic [0:0] axi_M00_wuser_o ;
  logic [0:0] axi_M00_wready_i ;
  logic [0:0] axi_M00_bvalid_i ;
  logic [ID_WIDTH_TOP-1:0] axi_M00_bid_i ;
  logic [1:0] axi_M00_bresp_i ;
  logic [0:0] axi_M00_buser_i ;
  logic [0:0] axi_M00_bready_o ;
  logic [0:0] axi_M00_arvalid_o ;
  logic [ID_WIDTH_TOP-1:0] axi_M00_arid_o ;
  logic [ADDR_WIDTH_TOP-1:0] axi_M00_araddr_o ;
  logic [7:0] axi_M00_arlen_o ;
  logic [2:0] axi_M00_arsize_o ;
  logic [1:0] axi_M00_arburst_o ;
  logic [0:0] axi_M00_arlock_o ;
  logic [3:0] axi_M00_arcache_o ;
  logic [2:0] axi_M00_arprot_o ;
  logic [3:0] axi_M00_arqos_o ;
  logic [3:0] axi_M00_arregion_o ;
  logic [0:0] axi_M00_aruser_o ;
  logic [0:0] axi_M00_arready_i ;
  logic [0:0] axi_M00_rvalid_i ;
  logic [ID_WIDTH_TOP-1:0] axi_M00_rid_i ;
  logic [MI_DATA_WIDTH_TOP-1:0] axi_M00_rdata_i ;
  logic [1:0] axi_M00_rresp_i ;
  logic [0:0] axi_M00_rlast_i ;
  logic [0:0] axi_M00_ruser_i ;
  logic [0:0] axi_M00_rready_o ;

  logic [TOTAL_MGR_COUNT_TOP-1:0]                         axi_arready_i;
  logic [TOTAL_MGR_COUNT_TOP-1:0]                         axi_arvalid_o;
  logic [TOTAL_MGR_COUNT_TOP*ADDR_WIDTH_TOP-1:0]          axi_araddr_o ;
  logic [TOTAL_MGR_COUNT_TOP*ID_WIDTH_TOP-1:0]            axi_arid_o   ;
  logic [TOTAL_MGR_COUNT_TOP*AXI_LEN_WIDTH-1:0]           axi_arlen_o  ;
  logic [TOTAL_MGR_COUNT_TOP*2-1:0]                       axi_arburst_o;
  logic [TOTAL_MGR_COUNT_TOP*4-1:0]                       axi_arqos_o  ;
  logic [TOTAL_MGR_COUNT_TOP*3-1:0]                       axi_arsize_o ;

  logic [TOTAL_MGR_COUNT_TOP-1:0]                         axi_rready_o ;
  logic [TOTAL_MGR_COUNT_TOP-1:0]                         axi_rvalid_i ;
  logic [TOTAL_MGR_COUNT_TOP*SI_MAX_DATA_WIDTH_TOP-1:0]   axi_rdata_i  ;
  logic [TOTAL_MGR_COUNT_TOP*2-1:0]                       axi_rresp_i  ;
  logic [TOTAL_MGR_COUNT_TOP*ID_WIDTH_TOP-1:0]            axi_rid_i    ;
  logic [TOTAL_MGR_COUNT_TOP-1:0]                         axi_rlast_i  ;

  logic [TOTAL_MGR_COUNT_TOP-1:0]                         axi_bready_o ;
  logic [TOTAL_MGR_COUNT_TOP-1:0]                         axi_bvalid_i ;
  logic [TOTAL_MGR_COUNT_TOP*2-1:0]                       axi_bresp_i  ;
  logic [TOTAL_MGR_COUNT_TOP*ID_WIDTH_TOP-1:0]            axi_bid_i    ;

  logic [TOTAL_MGR_COUNT_TOP-1:0]                         axi_awvalid_o;
  logic [TOTAL_MGR_COUNT_TOP*ID_WIDTH_TOP-1:0]            axi_awid_o   ;
  logic [TOTAL_MGR_COUNT_TOP*AXI_LEN_WIDTH-1:0]           axi_awlen_o  ;
  logic [TOTAL_MGR_COUNT_TOP*2-1:0]                       axi_awburst_o;
  logic [TOTAL_MGR_COUNT_TOP*ADDR_WIDTH_TOP-1:0]          axi_awaddr_o ;
  logic [TOTAL_MGR_COUNT_TOP*3-1:0]                       axi_awsize_o ;
  logic [TOTAL_MGR_COUNT_TOP*4-1:0]                       axi_awqos_o  ;
  logic [TOTAL_MGR_COUNT_TOP-1:0]                         axi_awready_i;

  logic [TOTAL_MGR_COUNT_TOP-1:0]                         axi_wvalid_o ;
  logic [TOTAL_MGR_COUNT_TOP*SI_MAX_DATA_WIDTH_TOP-1:0]   axi_wdata_o  ;
  logic [TOTAL_MGR_COUNT_TOP*SI_MAX_DATA_WIDTH_TOP/8-1:0] axi_wstrb_o  ;
  logic [TOTAL_MGR_COUNT_TOP-1:0]                         axi_wlast_o  ;
  logic [TOTAL_MGR_COUNT_TOP-1:0]                         axi_wready_i ;

  //-------------------------------------//
  //-- assign (non-process) operations --//
  //-------------------------------------//
  assign mipi_clk    = clk_ext  ;
  //assign out_clk0    = in_clk1;
  assign out_clk1    = pclk_i   ;
  assign fs[2:0]     = 3'b001   ;  // Select 100MHz for pll_refclk_i
  assign cmos_xclr   = rstn_i   ;
  assign gnd_clk     = 1'b0     ;

  assign pll_rst_n_i = rstn_i   ;
  assign rst_n_i     = rstn_i   ;
  assign preset_n_i  = prst_n   ;
  assign sim_o       = SIM[0]   ; // tell tb_top if SIM parameter is set

  generate
    if (DATA_CLK_EN) begin : ASYNC_AXI
      logic aclk_pll_lock;
      assign clk_w   = aclk_i;

      assign arst_w  = rstn_i & aclk_pll_lock;

      pll_aclk_pclk u_aclk_pclk (
          .clki_i (osc_clk_90   ),
          .rstn_i (rstn_i       ),
          .clkop_o(aclk_i        ),
          .clkos_o(pclk_i       ),
          .lock_o (aclk_pll_lock));
    end
    else begin : SYNC_AXI
      assign clk_w   = sclk_o;
      assign arst_w  = rstn_i;
      assign pclk_i  = osc_clk_90;
    end
  endgenerate

  assign areset_n_i   = areset_n;

  always @(posedge pclk_i or negedge rstn_i) begin
    if (!rstn_i) begin
        prst_n    <= 1'b0;
        prst_n_r0 <= 1'b0;
        prst_n_r1 <= 1'b0;
    end
    else begin
        prst_n_r0 <= 1'b1;
        prst_n_r1 <= prst_n_r0;
        prst_n    <= prst_n_r1;
    end
  end

  always @(posedge clk_w or negedge arst_w) begin
    if (!arst_w) begin
        areset_n    <= 1'b0;
        areset_n_r0 <= 1'b0;
        areset_n_r1 <= 1'b0;
    end
    else begin

        areset_n_r0 <= 1'b1        ;
        areset_n_r1 <= areset_n_r0 ;
        areset_n    <= areset_n_r1 ;
    end
  end

  always @(posedge sclk_o or negedge rstn_i) begin
    if (!rstn_i) begin
        sreset_n    <= 1'b0;
        sreset_n_r0 <= 1'b0;
        sreset_n_r1 <= 1'b0;
    end
    else begin

        sreset_n_r0 <= 1'b1        ;
        sreset_n_r1 <= sreset_n_r0 ;
        sreset_n    <= sreset_n_r1 ;
    end
  end

  //--------------------------------------------------------------------
  //--  module instances
  //--------------------------------------------------------------------
  osc0 osc_int_inst (
      .hf_out_en_i  (1'b1      ),
      .hf_clk_out_o (osc_clk_90));

  // for checking that the AXI clock is running
  kitcar #(
      .clk_freq   (112000000))
  kitcar_inst (
      .clk        (clk_w    ),
      .rstn       (areset_n_i),
      .LED_array  (LED_array)
  );

  // for checking that the pclk_i clock is running
  kitcar #(
      .clk_freq   (90000000  ))
  kitcar_inst2 (
      .clk        (pclk_i    ),
      .rstn       (preset_n_i),
      .LED_array  (LED_array2)
  );


  logic [2:0]  gen_in_w;
  logic        perf_tst_en;
  logic        s2p_r1_trn_done;
  logic        s2p_r2_trn_done;
  logic [11:0] apb_paddr_o;

  assign perf_tst_en = SIM ? 1'b0 : 1'b1;
  assign gen_in_w    = {perf_tst_en,s2p_r2_trn_done, irq_o};
  assign apb_paddr_i = apb_paddr_o[APB_ADDR_WIDTH-1:0];

  always @(posedge pclk_i or negedge preset_n_i) begin
    if (!preset_n_i) begin
        s2p_r1_trn_done <= 1'b0;
        s2p_r2_trn_done <= 1'b0;
    end
    else begin
        s2p_r1_trn_done <= init_done_o;
        s2p_r2_trn_done <= s2p_r1_trn_done;
    end
  end

  mc_axi4_traffic_gen #(
      .SIM           (SIM           ),
      .GEN_IN_WIDTH  (3             ),
      .DATA_CLK_EN   (DATA_CLK_EN   ),
      .DDR_CMD_FREQ  (DDR_CMD_FREQ  ),
      .AXI_ADDR_WIDTH(ADDR_WIDTH_TOP),
      .AXI_DATA_WIDTH(SI_MAX_DATA_WIDTH_TOP),
      .AXI_ID_WIDTH  (ID_WIDTH_TOP  ),
      .AXI_LEN_WIDTH (8 ),
      .TOTAL_MGR_COUNT (TOTAL_MGR_COUNT_TOP)
  ) u_tragen (
      .aclk_i       (clk_w        ),
      .areset_n_i   (areset_n_i    ),
      .pclk_i       (pclk_i       ),
      .preset_n_i   (preset_n_i   ),
      .sclk_i       (sclk_o   ),
      .rstn_i       (sreset_n  ),
      .rxd_i        (uart_rxd_i   ),
      .txd_o        (uart_txd_o   ),
      .led_o        (led_o        ),
    .p_rd_error_occur_o(        ),
    .a_rd_timeout_o(            ),
    .a_wr_timeout_o(            ),
      .a_test_num_o  (a_test_num_w),
      .a_rd_error_occur_o(a_rd_error_occur_w),

      .gen_in_i     (gen_in_w     ),
      .apb_psel_o   (apb_psel_i   ),
      .apb_paddr_o  (apb_paddr_o  ),
      .apb_penable_o(apb_penable_i),
      .apb_pwrite_o (apb_pwrite_i ),
      .apb_pwdata_o (apb_pwdata_i ),
      .apb_pready_i (apb_pready_o ),
      .apb_prdata_i (apb_prdata_o ),
      .apb_pslverr_i(apb_pslverr_o),

      .axi_awready_i(axi_awready_i),
      .axi_awvalid_o(axi_awvalid_o),
      .axi_awid_o   (axi_awid_o   ),
      .axi_awaddr_o (axi_awaddr_o ),
      .axi_awlen_o  (axi_awlen_o  ),
      .axi_awburst_o(axi_awburst_o),
      .axi_awqos_o  (axi_awqos_o  ),
      .axi_awsize_o (axi_awsize_o ),

      .axi_wvalid_o (axi_wvalid_o ),
      .axi_wready_i (axi_wready_i ),
      .axi_wdata_o  (axi_wdata_o  ),
      .axi_wstrb_o  (axi_wstrb_o  ),
      .axi_wlast_o  (axi_wlast_o  ),

      .axi_bready_o (axi_bready_o ),
      .axi_bvalid_i (axi_bvalid_i ),
      .axi_bresp_i  (axi_bresp_i  ),
      .axi_bid_i    (axi_bid_i    ),

      .axi_arready_i(axi_arready_i),
      .axi_arvalid_o(axi_arvalid_o),
      .axi_arid_o   (axi_arid_o   ),
      .axi_arlen_o  (axi_arlen_o  ),
      .axi_arburst_o(axi_arburst_o),
      .axi_araddr_o (axi_araddr_o ),
      .axi_arqos_o  (axi_arqos_o  ),
      .axi_arsize_o (axi_arsize_o ),

      .axi_rready_o (axi_rready_o ),
      .axi_rvalid_i (axi_rvalid_i ),
      .axi_rdata_i  (axi_rdata_i  ),
      .axi_rresp_i  (axi_rresp_i  ),
      .axi_rid_i    (axi_rid_i    ),
      .axi_rlast_i  (axi_rlast_i  )
  );

  // ---------------------------------------------------------
  // Map to the MPMC AXI S* Ports from the traffic generators
  // ---------------------------------------------------------
  assign axi_awready_i = {axi_S07_awready_o, axi_S06_awready_o,
                          axi_S05_awready_o, axi_S04_awready_o,
                          axi_S03_awready_o, axi_S02_awready_o,
                          axi_S01_awready_o, axi_S00_awready_o};
  assign axi_wready_i = {axi_S07_wready_o, axi_S06_wready_o,
                        axi_S05_wready_o, axi_S04_wready_o,
                        axi_S03_wready_o, axi_S02_wready_o,
                        axi_S01_wready_o, axi_S00_wready_o};
  assign axi_bvalid_i = {axi_S07_bvalid_o, axi_S06_bvalid_o,
                        axi_S05_bvalid_o, axi_S04_bvalid_o,
                        axi_S03_bvalid_o, axi_S02_bvalid_o,
                        axi_S01_bvalid_o, axi_S00_bvalid_o};
  assign axi_bresp_i = {axi_S07_bresp_o, axi_S06_bresp_o,
                        axi_S05_bresp_o, axi_S04_bresp_o,
                        axi_S03_bresp_o, axi_S02_bresp_o,
                        axi_S01_bresp_o, axi_S00_bresp_o};
  assign axi_bid_i = {axi_S07_bid_o, axi_S06_bid_o,
                      axi_S05_bid_o, axi_S04_bid_o,
                      axi_S03_bid_o, axi_S02_bid_o,
                      axi_S01_bid_o, axi_S00_bid_o};
  assign axi_arready_i = {axi_S07_arready_o, axi_S06_arready_o,
                          axi_S05_arready_o, axi_S04_arready_o,
                          axi_S03_arready_o, axi_S02_arready_o,
                          axi_S01_arready_o, axi_S00_arready_o};
  assign axi_rvalid_i = {axi_S07_rvalid_o, axi_S06_rvalid_o,
                        axi_S05_rvalid_o, axi_S04_rvalid_o,
                        axi_S03_rvalid_o, axi_S02_rvalid_o,
                        axi_S01_rvalid_o, axi_S00_rvalid_o};
  assign axi_rdata_i = {axi_S07_rdata_o, axi_S06_rdata_o,
                        axi_S05_rdata_o, axi_S04_rdata_o,
                        axi_S03_rdata_o, axi_S02_rdata_o,
                        axi_S01_rdata_o, axi_S00_rdata_o};
  assign axi_rresp_i = {axi_S07_rresp_o, axi_S06_rresp_o,
                        axi_S05_rresp_o, axi_S04_rresp_o,
                        axi_S03_rresp_o, axi_S02_rresp_o,
                        axi_S01_rresp_o, axi_S00_rresp_o};
  assign axi_rid_i = {axi_S07_rid_o, axi_S06_rid_o,
                      axi_S05_rid_o, axi_S04_rid_o,
                      axi_S03_rid_o, axi_S02_rid_o,
                      axi_S01_rid_o, axi_S00_rid_o};
  assign axi_rlast_i = {axi_S07_rlast_o, axi_S06_rlast_o,
                        axi_S05_rlast_o, axi_S04_rlast_o,
                        axi_S03_rlast_o, axi_S02_rlast_o,
                        axi_S01_rlast_o, axi_S00_rlast_o};

  always @* begin
    axi_S00_awvalid_i = axi_awvalid_o[0*1 +: 1];
    axi_S00_awid_i = axi_awid_o[0*ID_WIDTH_TOP +: ID_WIDTH_TOP] ;
    axi_S00_awaddr_i = axi_awaddr_o[0*ADDR_WIDTH_TOP +: ADDR_WIDTH_TOP] ;
    axi_S00_awlen_i = axi_awlen_o[0*AXI_LEN_WIDTH +: AXI_LEN_WIDTH] ;
    axi_S00_awsize_i = axi_awsize_o[0*3 +: 3] ;
    axi_S00_awburst_i = axi_awburst_o[0*2 +: 2] ;
    axi_S00_awlock_i = 1'h0 ;
    axi_S00_awcache_i = 4'h0 ;
    axi_S00_awprot_i = 3'h0 ;
    axi_S00_awqos_i = axi_awqos_o[0*4 +: 4] ;
    axi_S00_awregion_i = 4'h0 ;
    axi_S00_awuser_i = 1'h0 ;
    axi_S00_wvalid_i = axi_wvalid_o[0*1 +: 1] ;
    axi_S00_wdata_i = axi_wdata_o[0*SI_MAX_DATA_WIDTH_TOP +: SI_MAX_DATA_WIDTH_TOP] ;
    axi_S00_wstrb_i = axi_wstrb_o[0*SI_MAX_DATA_WIDTH_TOP/8 +: SI_MAX_DATA_WIDTH_TOP/8] ;
    axi_S00_wlast_i = axi_wlast_o[0*1 +: 1] ;
    axi_S00_wuser_i = 1'h0 ;
    axi_S00_bready_i = axi_bready_o[0*1 +: 1] ;
    axi_S00_arvalid_i = axi_arvalid_o[0*1 +: 1] ;
    axi_S00_arid_i = axi_arid_o[0*ID_WIDTH_TOP +: ID_WIDTH_TOP] ;
    axi_S00_araddr_i = axi_araddr_o[0*ADDR_WIDTH_TOP +: ADDR_WIDTH_TOP] ;
    axi_S00_arlen_i = axi_arlen_o[0*AXI_LEN_WIDTH +: AXI_LEN_WIDTH] ;
    axi_S00_arsize_i = axi_arsize_o[0*3 +: 3] ;
    axi_S00_arburst_i = axi_arburst_o[0*2 +: 2] ;
    axi_S00_arlock_i = 1'h0 ;
    axi_S00_arcache_i = 4'h0 ;
    axi_S00_arprot_i = 3'h0 ;
    axi_S00_arqos_i = axi_arqos_o[0*4 +: 4] ;
    axi_S00_arregion_i = 4'h0 ;
    axi_S00_aruser_i = 1'h0 ;
    axi_S00_rready_i = axi_rready_o[0*1 +: 1] ;

    axi_S01_awvalid_i = axi_awvalid_o[1*1 +: 1];
    axi_S01_awid_i = axi_awid_o[1*ID_WIDTH_TOP +: ID_WIDTH_TOP] ;
    axi_S01_awaddr_i = axi_awaddr_o[1*ADDR_WIDTH_TOP +: ADDR_WIDTH_TOP] ;
    axi_S01_awlen_i = axi_awlen_o[1*AXI_LEN_WIDTH +: AXI_LEN_WIDTH] ;
    axi_S01_awsize_i = axi_awsize_o[1*3 +: 3] ;
    axi_S01_awburst_i = axi_awburst_o[1*2 +: 2] ;
    axi_S01_awlock_i = 1'h0 ;
    axi_S01_awcache_i = 4'h0 ;
    axi_S01_awprot_i = 3'h0 ;
    axi_S01_awqos_i = axi_awqos_o[1*4 +: 4] ;
    axi_S01_awregion_i = 4'h0 ;
    axi_S01_awuser_i = 1'h0 ;
    axi_S01_wvalid_i = axi_wvalid_o[1*1 +: 1] ;
    axi_S01_wdata_i = axi_wdata_o[1*SI_MAX_DATA_WIDTH_TOP +: SI_MAX_DATA_WIDTH_TOP] ;
    axi_S01_wstrb_i = axi_wstrb_o[1*SI_MAX_DATA_WIDTH_TOP/8 +: SI_MAX_DATA_WIDTH_TOP/8] ;
    axi_S01_wlast_i = axi_wlast_o[1*1 +: 1] ;
    axi_S01_wuser_i = 1'h0 ;
    axi_S01_bready_i = axi_bready_o[1*1 +: 1] ;
    axi_S01_arvalid_i = axi_arvalid_o[1*1 +: 1] ;
    axi_S01_arid_i = axi_arid_o[1*ID_WIDTH_TOP +: ID_WIDTH_TOP] ;
    axi_S01_araddr_i = axi_araddr_o[1*ADDR_WIDTH_TOP +: ADDR_WIDTH_TOP] ;
    axi_S01_arlen_i = axi_arlen_o[1*AXI_LEN_WIDTH +: AXI_LEN_WIDTH] ;
    axi_S01_arsize_i = axi_arsize_o[1*3 +: 3] ;
    axi_S01_arburst_i = axi_arburst_o[1*2 +: 2] ;
    axi_S01_arlock_i = 1'h0 ;
    axi_S01_arcache_i = 4'h0 ;
    axi_S01_arprot_i = 3'h0 ;
    axi_S01_arqos_i = axi_arqos_o[1*4 +: 4] ;
    axi_S01_arregion_i = 4'h0 ;
    axi_S01_aruser_i = 1'h0 ;
    axi_S01_rready_i = axi_rready_o[1*1 +: 1] ;

    axi_S02_awvalid_i = 1'h0 ;
    axi_S02_awid_i = {ID_WIDTH_TOP{1'b0}} ;
    axi_S02_awaddr_i = {ADDR_WIDTH_TOP{1'b0}} ;
    axi_S02_awlen_i = 8'h0 ;
    axi_S02_awsize_i = 3'h0 ;
    axi_S02_awburst_i = 2'h0 ;
    axi_S02_awlock_i = 1'h0 ;
    axi_S02_awcache_i = 4'h0 ;
    axi_S02_awprot_i = 3'h0 ;
    axi_S02_awqos_i = 4'h0 ;
    axi_S02_awregion_i = 4'h0 ;
    axi_S02_awuser_i = 1'h0 ;
    axi_S02_wvalid_i = 1'h0 ;
    axi_S02_wdata_i = {SI_MAX_DATA_WIDTH_TOP{1'b0}} ;
    axi_S02_wstrb_i = {(SI_MAX_DATA_WIDTH_TOP/8){1'b0}} ;
    axi_S02_wlast_i = 1'h0 ;
    axi_S02_wuser_i = 1'h0 ;
    axi_S02_bready_i = 1'h0 ;
    axi_S02_arvalid_i = 1'h0 ;
    axi_S02_arid_i = {ID_WIDTH_TOP{1'b0}} ;
    axi_S02_araddr_i = {ADDR_WIDTH_TOP{1'b0}} ;
    axi_S02_arlen_i = 8'h0 ;
    axi_S02_arsize_i = 3'h0 ;
    axi_S02_arburst_i = 2'h0 ;
    axi_S02_arlock_i = 1'h0 ;
    axi_S02_arcache_i = 4'h0 ;
    axi_S02_arprot_i = 3'h0 ;
    axi_S02_arqos_i = 4'h0 ;
    axi_S02_arregion_i = 4'h0 ;
    axi_S02_aruser_i = 1'h0 ;
    axi_S02_rready_i = 1'h0 ;

    axi_S03_awvalid_i = 1'h0 ;
    axi_S03_awid_i = {ID_WIDTH_TOP{1'b0}} ;
    axi_S03_awaddr_i = {ADDR_WIDTH_TOP{1'b0}} ;
    axi_S03_awlen_i = 8'h0 ;
    axi_S03_awsize_i = 3'h0 ;
    axi_S03_awburst_i = 2'h0 ;
    axi_S03_awlock_i = 1'h0 ;
    axi_S03_awcache_i = 4'h0 ;
    axi_S03_awprot_i = 3'h0 ;
    axi_S03_awqos_i = 4'h0 ;
    axi_S03_awregion_i = 4'h0 ;
    axi_S03_awuser_i = 1'h0 ;
    axi_S03_wvalid_i = 1'h0 ;
    axi_S03_wdata_i = {SI_MAX_DATA_WIDTH_TOP{1'b0}} ;
    axi_S03_wstrb_i = {(SI_MAX_DATA_WIDTH_TOP/8){1'b0}} ;
    axi_S03_wlast_i = 1'h0 ;
    axi_S03_wuser_i = 1'h0 ;
    axi_S03_bready_i = 1'h0 ;
    axi_S03_arvalid_i = 1'h0 ;
    axi_S03_arid_i = {ID_WIDTH_TOP{1'b0}} ;
    axi_S03_araddr_i = {ADDR_WIDTH_TOP{1'b0}} ;
    axi_S03_arlen_i = 8'h0 ;
    axi_S03_arsize_i = 3'h0 ;
    axi_S03_arburst_i = 2'h0 ;
    axi_S03_arlock_i = 1'h0 ;
    axi_S03_arcache_i = 4'h0 ;
    axi_S03_arprot_i = 3'h0 ;
    axi_S03_arqos_i = 4'h0 ;
    axi_S03_arregion_i = 4'h0 ;
    axi_S03_aruser_i = 1'h0 ;
    axi_S03_rready_i = 1'h0 ;

    axi_S04_awvalid_i = 1'h0 ;
    axi_S04_awid_i = {ID_WIDTH_TOP{1'b0}} ;
    axi_S04_awaddr_i = {ADDR_WIDTH_TOP{1'b0}} ;
    axi_S04_awlen_i = 8'h0 ;
    axi_S04_awsize_i = 3'h0 ;
    axi_S04_awburst_i = 2'h0 ;
    axi_S04_awlock_i = 1'h0 ;
    axi_S04_awcache_i = 4'h0 ;
    axi_S04_awprot_i = 3'h0 ;
    axi_S04_awqos_i = 4'h0 ;
    axi_S04_awregion_i = 4'h0 ;
    axi_S04_awuser_i = 1'h0 ;
    axi_S04_wvalid_i = 1'h0 ;
    axi_S04_wdata_i = {SI_MAX_DATA_WIDTH_TOP{1'b0}} ;
    axi_S04_wstrb_i = {(SI_MAX_DATA_WIDTH_TOP/8){1'b0}} ;
    axi_S04_wlast_i = 1'h0 ;
    axi_S04_wuser_i = 1'h0 ;
    axi_S04_bready_i = 1'h0 ;
    axi_S04_arvalid_i = 1'h0 ;
    axi_S04_arid_i = {ID_WIDTH_TOP{1'b0}} ;
    axi_S04_araddr_i = {ADDR_WIDTH_TOP{1'b0}} ;
    axi_S04_arlen_i = 8'h0 ;
    axi_S04_arsize_i = 3'h0 ;
    axi_S04_arburst_i = 2'h0 ;
    axi_S04_arlock_i = 1'h0 ;
    axi_S04_arcache_i = 4'h0 ;
    axi_S04_arprot_i = 3'h0 ;
    axi_S04_arqos_i = 4'h0 ;
    axi_S04_arregion_i = 4'h0 ;
    axi_S04_aruser_i = 1'h0 ;
    axi_S04_rready_i = 1'h0 ;

    axi_S05_awvalid_i = 1'h0 ;
    axi_S05_awid_i = {ID_WIDTH_TOP{1'b0}} ;
    axi_S05_awaddr_i = {ADDR_WIDTH_TOP{1'b0}} ;
    axi_S05_awlen_i = 8'h0 ;
    axi_S05_awsize_i = 3'h0 ;
    axi_S05_awburst_i = 2'h0 ;
    axi_S05_awlock_i = 1'h0 ;
    axi_S05_awcache_i = 4'h0 ;
    axi_S05_awprot_i = 3'h0 ;
    axi_S05_awqos_i = 4'h0 ;
    axi_S05_awregion_i = 4'h0 ;
    axi_S05_awuser_i = 1'h0 ;
    axi_S05_wvalid_i = 1'h0 ;
    axi_S05_wdata_i = {SI_MAX_DATA_WIDTH_TOP{1'b0}} ;
    axi_S05_wstrb_i = {(SI_MAX_DATA_WIDTH_TOP/8){1'b0}} ;
    axi_S05_wlast_i = 1'h0 ;
    axi_S05_wuser_i = 1'h0 ;
    axi_S05_bready_i = 1'h0 ;
    axi_S05_arvalid_i = 1'h0 ;
    axi_S05_arid_i = {ID_WIDTH_TOP{1'b0}} ;
    axi_S05_araddr_i = {ADDR_WIDTH_TOP{1'b0}} ;
    axi_S05_arlen_i = 8'h0 ;
    axi_S05_arsize_i = 3'h0 ;
    axi_S05_arburst_i = 2'h0 ;
    axi_S05_arlock_i = 1'h0 ;
    axi_S05_arcache_i = 4'h0 ;
    axi_S05_arprot_i = 3'h0 ;
    axi_S05_arqos_i = 4'h0 ;
    axi_S05_arregion_i = 4'h0 ;
    axi_S05_aruser_i = 1'h0 ;
    axi_S05_rready_i = 1'h0 ;

    axi_S06_awvalid_i = 1'h0 ;
    axi_S06_awid_i = {ID_WIDTH_TOP{1'b0}} ;
    axi_S06_awaddr_i = {ADDR_WIDTH_TOP{1'b0}} ;
    axi_S06_awlen_i = 8'h0 ;
    axi_S06_awsize_i = 3'h0 ;
    axi_S06_awburst_i = 2'h0 ;
    axi_S06_awlock_i = 1'h0 ;
    axi_S06_awcache_i = 4'h0 ;
    axi_S06_awprot_i = 3'h0 ;
    axi_S06_awqos_i = 4'h0 ;
    axi_S06_awregion_i = 4'h0 ;
    axi_S06_awuser_i = 1'h0 ;
    axi_S06_wvalid_i = 1'h0 ;
    axi_S06_wdata_i = {SI_MAX_DATA_WIDTH_TOP{1'b0}} ;
    axi_S06_wstrb_i = {(SI_MAX_DATA_WIDTH_TOP/8){1'b0}} ;
    axi_S06_wlast_i = 1'h0 ;
    axi_S06_wuser_i = 1'h0 ;
    axi_S06_bready_i = 1'h0 ;
    axi_S06_arvalid_i = 1'h0 ;
    axi_S06_arid_i = {ID_WIDTH_TOP{1'b0}} ;
    axi_S06_araddr_i = {ADDR_WIDTH_TOP{1'b0}} ;
    axi_S06_arlen_i = 8'h0 ;
    axi_S06_arsize_i = 3'h0 ;
    axi_S06_arburst_i = 2'h0 ;
    axi_S06_arlock_i = 1'h0 ;
    axi_S06_arcache_i = 4'h0 ;
    axi_S06_arprot_i = 3'h0 ;
    axi_S06_arqos_i = 4'h0 ;
    axi_S06_arregion_i = 4'h0 ;
    axi_S06_aruser_i = 1'h0 ;
    axi_S06_rready_i = 1'h0 ;

    axi_S07_awvalid_i = 1'h0 ;
    axi_S07_awid_i = {ID_WIDTH_TOP{1'b0}} ;
    axi_S07_awaddr_i = {ADDR_WIDTH_TOP{1'b0}} ;
    axi_S07_awlen_i = 8'h0 ;
    axi_S07_awsize_i = 3'h0 ;
    axi_S07_awburst_i = 2'h0 ;
    axi_S07_awlock_i = 1'h0 ;
    axi_S07_awcache_i = 4'h0 ;
    axi_S07_awprot_i = 3'h0 ;
    axi_S07_awqos_i = 4'h0 ;
    axi_S07_awregion_i = 4'h0 ;
    axi_S07_awuser_i = 1'h0 ;
    axi_S07_wvalid_i = 1'h0 ;
    axi_S07_wdata_i = {SI_MAX_DATA_WIDTH_TOP{1'b0}} ;
    axi_S07_wstrb_i = {(SI_MAX_DATA_WIDTH_TOP/8){1'b0}} ;
    axi_S07_wlast_i = 1'h0 ;
    axi_S07_wuser_i = 1'h0 ;
    axi_S07_bready_i = 1'h0 ;
    axi_S07_arvalid_i = 1'h0 ;
    axi_S07_arid_i = {ID_WIDTH_TOP{1'b0}} ;
    axi_S07_araddr_i = {ADDR_WIDTH_TOP{1'b0}} ;
    axi_S07_arlen_i = 8'h0 ;
    axi_S07_arsize_i = 3'h0 ;
    axi_S07_arburst_i = 2'h0 ;
    axi_S07_arlock_i = 1'h0 ;
    axi_S07_arcache_i = 4'h0 ;
    axi_S07_arprot_i = 3'h0 ;
    axi_S07_arqos_i = 4'h0 ;
    axi_S07_arregion_i = 4'h0 ;
    axi_S07_aruser_i = 1'h0 ;
    axi_S07_rready_i = 1'h0 ;

    if(TOTAL_MGR_COUNT_TOP>=3) begin
      axi_S02_awvalid_i = axi_awvalid_o[2*1 +: 1];
      axi_S02_awid_i = axi_awid_o[2*ID_WIDTH_TOP +: ID_WIDTH_TOP] ;
      axi_S02_awaddr_i = axi_awaddr_o[2*ADDR_WIDTH_TOP +: ADDR_WIDTH_TOP] ;
      axi_S02_awlen_i = axi_awlen_o[2*AXI_LEN_WIDTH +: AXI_LEN_WIDTH] ;
      axi_S02_awsize_i = axi_awsize_o[2*3 +: 3] ;
      axi_S02_awburst_i = axi_awburst_o[2*2 +: 2] ;
      axi_S02_awqos_i = axi_awqos_o[2*4 +: 4] ;
      axi_S02_wvalid_i = axi_wvalid_o[2*1 +: 1] ;
      axi_S02_wdata_i = axi_wdata_o[2*SI_MAX_DATA_WIDTH_TOP +: SI_MAX_DATA_WIDTH_TOP] ;
      axi_S02_wstrb_i = axi_wstrb_o[2*SI_MAX_DATA_WIDTH_TOP/8 +: SI_MAX_DATA_WIDTH_TOP/8] ;
      axi_S02_wlast_i = axi_wlast_o[2*1 +: 1] ;
      axi_S02_bready_i = axi_bready_o[2*1 +: 1] ;
      axi_S02_arvalid_i = axi_arvalid_o[2*1 +: 1] ;
      axi_S02_arid_i = axi_arid_o[2*ID_WIDTH_TOP +: ID_WIDTH_TOP] ;
      axi_S02_araddr_i = axi_araddr_o[2*ADDR_WIDTH_TOP +: ADDR_WIDTH_TOP] ;
      axi_S02_arlen_i = axi_arlen_o[2*AXI_LEN_WIDTH +: AXI_LEN_WIDTH] ;
      axi_S02_arsize_i = axi_arsize_o[2*3 +: 3] ;
      axi_S02_arburst_i = axi_arburst_o[2*2 +: 2] ;
      axi_S02_arqos_i = axi_arqos_o[2*4 +: 4] ;
      axi_S02_rready_i = axi_rready_o[2*1 +: 1] ;
    end

    if(TOTAL_MGR_COUNT_TOP>=4) begin
      axi_S03_awvalid_i = axi_awvalid_o[3*1 +: 1];
      axi_S03_awid_i = axi_awid_o[3*ID_WIDTH_TOP +: ID_WIDTH_TOP] ;
      axi_S03_awaddr_i = axi_awaddr_o[3*ADDR_WIDTH_TOP +: ADDR_WIDTH_TOP] ;
      axi_S03_awlen_i = axi_awlen_o[3*AXI_LEN_WIDTH +: AXI_LEN_WIDTH] ;
      axi_S03_awsize_i = axi_awsize_o[3*3 +: 3] ;
      axi_S03_awburst_i = axi_awburst_o[3*2 +: 2] ;
      axi_S03_awqos_i = axi_awqos_o[3*4 +: 4] ;
      axi_S03_wvalid_i = axi_wvalid_o[3*1 +: 1] ;
      axi_S03_wdata_i = axi_wdata_o[3*SI_MAX_DATA_WIDTH_TOP +: SI_MAX_DATA_WIDTH_TOP] ;
      axi_S03_wstrb_i = axi_wstrb_o[3*SI_MAX_DATA_WIDTH_TOP/8 +: SI_MAX_DATA_WIDTH_TOP/8] ;
      axi_S03_wlast_i = axi_wlast_o[3*1 +: 1] ;
      axi_S03_bready_i = axi_bready_o[3*1 +: 1] ;
      axi_S03_arvalid_i = axi_arvalid_o[3*1 +: 1] ;
      axi_S03_arid_i = axi_arid_o[3*ID_WIDTH_TOP +: ID_WIDTH_TOP] ;
      axi_S03_araddr_i = axi_araddr_o[3*ADDR_WIDTH_TOP +: ADDR_WIDTH_TOP] ;
      axi_S03_arlen_i = axi_arlen_o[3*AXI_LEN_WIDTH +: AXI_LEN_WIDTH] ;
      axi_S03_arsize_i = axi_arsize_o[3*3 +: 3] ;
      axi_S03_arburst_i = axi_arburst_o[3*2 +: 2] ;
      axi_S03_arqos_i = axi_arqos_o[3*4 +: 4] ;
      axi_S03_rready_i = axi_rready_o[3*1 +: 1] ;
    end

    if(TOTAL_MGR_COUNT_TOP>=5) begin
      axi_S04_awvalid_i = axi_awvalid_o[4*1 +: 1];
      axi_S04_awid_i = axi_awid_o[4*ID_WIDTH_TOP +: ID_WIDTH_TOP] ;
      axi_S04_awaddr_i = axi_awaddr_o[4*ADDR_WIDTH_TOP +: ADDR_WIDTH_TOP] ;
      axi_S04_awlen_i = axi_awlen_o[4*AXI_LEN_WIDTH +: AXI_LEN_WIDTH] ;
      axi_S04_awsize_i = axi_awsize_o[4*3 +: 3] ;
      axi_S04_awburst_i = axi_awburst_o[4*2 +: 2] ;
      axi_S04_awqos_i = axi_awqos_o[4*4 +: 4] ;
      axi_S04_wvalid_i = axi_wvalid_o[4*1 +: 1] ;
      axi_S04_wdata_i = axi_wdata_o[4*SI_MAX_DATA_WIDTH_TOP +: SI_MAX_DATA_WIDTH_TOP] ;
      axi_S04_wstrb_i = axi_wstrb_o[4*SI_MAX_DATA_WIDTH_TOP/8 +: SI_MAX_DATA_WIDTH_TOP/8] ;
      axi_S04_wlast_i = axi_wlast_o[4*1 +: 1] ;
      axi_S04_bready_i = axi_bready_o[4*1 +: 1] ;
      axi_S04_arvalid_i = axi_arvalid_o[4*1 +: 1] ;
      axi_S04_arid_i = axi_arid_o[4*ID_WIDTH_TOP +: ID_WIDTH_TOP] ;
      axi_S04_araddr_i = axi_araddr_o[4*ADDR_WIDTH_TOP +: ADDR_WIDTH_TOP] ;
      axi_S04_arlen_i = axi_arlen_o[4*AXI_LEN_WIDTH +: AXI_LEN_WIDTH] ;
      axi_S04_arsize_i = axi_arsize_o[4*3 +: 3] ;
      axi_S04_arburst_i = axi_arburst_o[4*2 +: 2] ;
      axi_S04_arqos_i = axi_arqos_o[4*4 +: 4] ;
      axi_S04_rready_i = axi_rready_o[4*1 +: 1] ;
    end

    if(TOTAL_MGR_COUNT_TOP>=6) begin
      axi_S05_awvalid_i = axi_awvalid_o[5*1 +: 1];
      axi_S05_awid_i = axi_awid_o[5*ID_WIDTH_TOP +: ID_WIDTH_TOP] ;
      axi_S05_awaddr_i = axi_awaddr_o[5*ADDR_WIDTH_TOP +: ADDR_WIDTH_TOP] ;
      axi_S05_awlen_i = axi_awlen_o[5*AXI_LEN_WIDTH +: AXI_LEN_WIDTH] ;
      axi_S05_awsize_i = axi_awsize_o[5*3 +: 3] ;
      axi_S05_awburst_i = axi_awburst_o[5*2 +: 2] ;
      axi_S05_awqos_i = axi_awqos_o[5*4 +: 4] ;
      axi_S05_wvalid_i = axi_wvalid_o[5*1 +: 1] ;
      axi_S05_wdata_i = axi_wdata_o[5*SI_MAX_DATA_WIDTH_TOP +: SI_MAX_DATA_WIDTH_TOP] ;
      axi_S05_wstrb_i = axi_wstrb_o[5*SI_MAX_DATA_WIDTH_TOP/8 +: SI_MAX_DATA_WIDTH_TOP/8] ;
      axi_S05_wlast_i = axi_wlast_o[5*1 +: 1] ;
      axi_S05_bready_i = axi_bready_o[5*1 +: 1] ;
      axi_S05_arvalid_i = axi_arvalid_o[5*1 +: 1] ;
      axi_S05_arid_i = axi_arid_o[5*ID_WIDTH_TOP +: ID_WIDTH_TOP] ;
      axi_S05_araddr_i = axi_araddr_o[5*ADDR_WIDTH_TOP +: ADDR_WIDTH_TOP] ;
      axi_S05_arlen_i = axi_arlen_o[5*AXI_LEN_WIDTH +: AXI_LEN_WIDTH] ;
      axi_S05_arsize_i = axi_arsize_o[5*3 +: 3] ;
      axi_S05_arburst_i = axi_arburst_o[5*2 +: 2] ;
      axi_S05_arqos_i = axi_arqos_o[5*4 +: 4] ;
      axi_S05_rready_i = axi_rready_o[5*1 +: 1] ;
    end

    if(TOTAL_MGR_COUNT_TOP>=7) begin
      axi_S06_awvalid_i = axi_awvalid_o[6*1 +: 1];
      axi_S06_awid_i = axi_awid_o[6*ID_WIDTH_TOP +: ID_WIDTH_TOP] ;
      axi_S06_awaddr_i = axi_awaddr_o[6*ADDR_WIDTH_TOP +: ADDR_WIDTH_TOP] ;
      axi_S06_awlen_i = axi_awlen_o[6*AXI_LEN_WIDTH +: AXI_LEN_WIDTH] ;
      axi_S06_awsize_i = axi_awsize_o[6*3 +: 3] ;
      axi_S06_awburst_i = axi_awburst_o[6*2 +: 2] ;
      axi_S06_awqos_i = axi_awqos_o[6*4 +: 4] ;
      axi_S06_wvalid_i = axi_wvalid_o[6*1 +: 1] ;
      axi_S06_wdata_i = axi_wdata_o[6*SI_MAX_DATA_WIDTH_TOP +: SI_MAX_DATA_WIDTH_TOP] ;
      axi_S06_wstrb_i = axi_wstrb_o[6*SI_MAX_DATA_WIDTH_TOP/8 +: SI_MAX_DATA_WIDTH_TOP/8] ;
      axi_S06_wlast_i = axi_wlast_o[6*1 +: 1] ;
      axi_S06_bready_i = axi_bready_o[6*1 +: 1] ;
      axi_S06_arvalid_i = axi_arvalid_o[6*1 +: 1] ;
      axi_S06_arid_i = axi_arid_o[6*ID_WIDTH_TOP +: ID_WIDTH_TOP] ;
      axi_S06_araddr_i = axi_araddr_o[6*ADDR_WIDTH_TOP +: ADDR_WIDTH_TOP] ;
      axi_S06_arlen_i = axi_arlen_o[6*AXI_LEN_WIDTH +: AXI_LEN_WIDTH] ;
      axi_S06_arsize_i = axi_arsize_o[6*3 +: 3] ;
      axi_S06_arburst_i = axi_arburst_o[6*2 +: 2] ;
      axi_S06_arqos_i = axi_arqos_o[6*4 +: 4] ;
      axi_S06_rready_i = axi_rready_o[6*1 +: 1] ;
    end

    if(TOTAL_MGR_COUNT_TOP==8) begin
      axi_S07_awvalid_i = axi_awvalid_o[7*1 +: 1];
      axi_S07_awid_i = axi_awid_o[7*ID_WIDTH_TOP +: ID_WIDTH_TOP] ;
      axi_S07_awaddr_i = axi_awaddr_o[7*ADDR_WIDTH_TOP +: ADDR_WIDTH_TOP] ;
      axi_S07_awlen_i = axi_awlen_o[7*AXI_LEN_WIDTH +: AXI_LEN_WIDTH] ;
      axi_S07_awsize_i = axi_awsize_o[7*3 +: 3] ;
      axi_S07_awburst_i = axi_awburst_o[7*2 +: 2] ;
      axi_S07_awqos_i = axi_awqos_o[7*4 +: 4] ;
      axi_S07_wvalid_i = axi_wvalid_o[7*1 +: 1] ;
      axi_S07_wdata_i = axi_wdata_o[7*SI_MAX_DATA_WIDTH_TOP +: SI_MAX_DATA_WIDTH_TOP] ;
      axi_S07_wstrb_i = axi_wstrb_o[7*SI_MAX_DATA_WIDTH_TOP/8 +: SI_MAX_DATA_WIDTH_TOP/8] ;
      axi_S07_wlast_i = axi_wlast_o[7*1 +: 1] ;
      axi_S07_bready_i = axi_bready_o[7*1 +: 1] ;
      axi_S07_arvalid_i = axi_arvalid_o[7*1 +: 1] ;
      axi_S07_arid_i = axi_arid_o[7*ID_WIDTH_TOP +: ID_WIDTH_TOP] ;
      axi_S07_araddr_i = axi_araddr_o[7*ADDR_WIDTH_TOP +: ADDR_WIDTH_TOP] ;
      axi_S07_arlen_i = axi_arlen_o[7*AXI_LEN_WIDTH +: AXI_LEN_WIDTH] ;
      axi_S07_arsize_i = axi_arsize_o[7*3 +: 3] ;
      axi_S07_arburst_i = axi_arburst_o[7*2 +: 2] ;
      axi_S07_arqos_i = axi_arqos_o[7*4 +: 4] ;
      axi_S07_rready_i = axi_rready_o[7*1 +: 1] ;
    end
  end

  // ---------------------------------------------------------
  // Map from the MPMC AXI M* Ports to MC AXI ports
  // ---------------------------------------------------------
  assign axi_arvalid_i = axi_M00_arvalid_o[0];
  assign axi_arid_i = axi_M00_arid_o;
  assign axi_arlen_i = axi_M00_arlen_o;
  assign axi_arburst_i = axi_M00_arburst_o;
  assign axi_araddr_i = axi_M00_araddr_o;
  assign axi_M00_arready_i[0] = axi_arready_o;
  assign axi_arqos_i = axi_M00_arqos_o;
  assign axi_arsize_i = axi_M00_arsize_o;
  assign axi_M00_rresp_i = axi_rresp_o;
  assign axi_M00_rid_i = axi_rid_o;
  assign axi_M00_rdata_i = axi_rdata_o;
  assign axi_M00_rvalid_i[0] = axi_rvalid_o;
  assign axi_M00_rlast_i[0] = axi_rlast_o;
  assign axi_rready_i = axi_M00_rready_o;
  assign axi_bready_i = axi_M00_bready_o[0];
  assign axi_M00_bvalid_i[0] = axi_bvalid_o;
  assign axi_M00_bresp_i = axi_bresp_o;
  assign axi_M00_bid_i = axi_bid_o;
  assign axi_awvalid_i = axi_M00_awvalid_o[0];
  assign axi_awid_i = axi_M00_awid_o;
  assign axi_awlen_i = axi_M00_awlen_o;
  assign axi_awburst_i = axi_M00_awburst_o;
  assign axi_awsize_i = axi_M00_awsize_o;
  assign axi_awaddr_i = axi_M00_awaddr_o;
  assign axi_M00_awready_i[0] = axi_awready_o;
  assign axi_awqos_i = axi_M00_awqos_o;
  assign axi_wvalid_i = axi_M00_wvalid_o[0];
  assign axi_M00_wready_i[0] = axi_wready_o;
  assign axi_wdata_i = axi_M00_wdata_o;
  assign axi_wstrb_i = axi_M00_wstrb_o;
  assign axi_wlast_i = axi_M00_wlast_o[0];

  assign axi_S00_aclk_i = clk_w;
  assign axi_S00_aresetn_i = areset_n_i;
  assign axi_S01_aclk_i = clk_w;
  assign axi_S01_aresetn_i = areset_n_i;
  assign axi_S02_aclk_i = clk_w;
  assign axi_S02_aresetn_i = areset_n_i;
  assign axi_S03_aclk_i = clk_w;
  assign axi_S03_aresetn_i = areset_n_i;
  assign axi_S04_aclk_i = clk_w;
  assign axi_S04_aresetn_i = areset_n_i;
  assign axi_S05_aclk_i = clk_w;
  assign axi_S05_aresetn_i = areset_n_i;
  assign axi_S06_aclk_i = clk_w;
  assign axi_S06_aresetn_i = areset_n_i;
  assign axi_S07_aclk_i = clk_w;
  assign axi_S07_aresetn_i = areset_n_i;
  assign axi_M00_aclk_i = clk_w;
  assign axi_M00_aresetn_i = areset_n_i;

  generate
    if(AXI == 0) begin : BRIDGE
      lpddr4_mc_axi_iface_top #(
        .DDR_WIDTH               (DDR_WIDTH),
        .SCH_NUM_RD_SUPPORT      (SCH_NUM_RD_SUPPORTED),
        .SCH_NUM_WR_SUPPORT      (SCH_NUM_WR_SUPPORTED),
        .INT_ID_WIDTH            (ORDER_ID_WIDTH      ),
        .AXI_ADDR_WIDTH          (AXI_ADDR_WIDTH),
        .AXI_ID_WIDTH            (AXI_ID_WIDTH),
        .AXI_DATA_WIDTH          (AXI_DATA_WIDTH),
        .AXI_CTRL_WIDTH          (AXI_CTRL_WIDTH),
        .AXI_LEN_WIDTH           (AXI_LEN_WIDTH),
        .AXI_STRB_WIDTH          (AXI_STRB_WIDTH),
        .AXI_QOS_WIDTH           (AXI_QOS_WIDTH),
        .BI_RD_DATA_Q_WIDTH      (BI_RD_DATA_Q_WIDTH),
        .BI_RD_DATA_Q_DEPTH      (BI_RD_DATA_Q_DEPTH),
        .DATA_CLK_EN             (DATA_CLK_EN),
        .BI_WR_DATA_FIFO_DEPTH(BI_WR_DATA_FIFO_DEPTH)
      )
      u_axi_if
      (
        .clk_i             (sclk_o        ), // Native I/F is only Sync, No CDC
        .sclk_i            (sclk_o        ),
        .rst_n_i           (areset_n      ), // Sync to sclk_o when DATA_CLK_EN=0
        .srst_n_i          (areset_n      ), // Sync to sclk_o when DATA_CLK_EN=0
        //AXI4 INTERFACE
        .axi_arvalid_i     (axi_arvalid_i ),
        .axi_arid_i        (axi_arid_i    ),
        .axi_arlen_i       (axi_arlen_i   ),
        .axi_arburst_i     (axi_arburst_i ),
        .axi_araddr_i      (axi_araddr_i  ),
        .axi_arready_o     (axi_arready_o ),
        .axi_arqos_i       (axi_arqos_i   ),
        .axi_arsize_i      (axi_arsize_i  ),
        .axi_rresp_o       (axi_rresp_o   ),
        .axi_rdata_o       (axi_rdata_o   ),
        .axi_rid_o         (axi_rid_o     ),
        .axi_rvalid_o      (axi_rvalid_o  ),
        .axi_rlast_o       (axi_rlast_o   ),
        .axi_rready_i      (axi_rready_i  ),
        .axi_awvalid_i     (axi_awvalid_i ),
        .axi_awlen_i       (axi_awlen_i   ),
        .axi_awburst_i     (axi_awburst_i ),
        .axi_awaddr_i      (axi_awaddr_i  ),
        .axi_awready_o     (axi_awready_o ),
        .axi_awqos_i       (axi_awqos_i   ),
        .axi_awsize_i      (axi_awsize_i  ),
        .axi_awid_i        (axi_awid_i    ),
        .axi_wvalid_i      (axi_wvalid_i  ),
        .axi_wready_o      (axi_wready_o  ),
        .axi_wdata_i       (axi_wdata_i   ),
        .axi_wstrb_i       (axi_wstrb_i   ),
        .axi_wlast_i       (axi_wlast_i   ),
        .axi_bready_i      (axi_bready_i  ),
        .axi_bvalid_o      (axi_bvalid_o  ),
        .axi_bresp_o       (axi_bresp_o   ),
        .axi_bid_o         (axi_bid_o     ),

        //NATIVE INTERFACE
        .wr_req_txn_id_o   ({wr_req_id_i,wr_req_order_id_i}),
        .wr_req_addr_o     (wr_req_addr_i ),
        .wr_req_len_o      (wr_req_len_i  ),
        .wr_req_size_o     (wr_req_size_i ),
        .wr_req_valid_o    (wr_req_valid_i),
        .wr_req_ready_i    (wr_req_ready_o),
        .wr_data_o         (wr_data_i     ),
        .wr_byte_en_o      (wr_byte_en_i  ),
        .wr_last_o         (wr_data_last_i),
        .wr_valid_o        (wr_valid_i    ),
        .wr_ready_i        (wr_ready_o    ),
        .rd_req_valid_o    (rd_req_valid_i),
        .rd_req_addr_o     (rd_req_addr_i ),
        .rd_req_len_o      (rd_req_len_i  ),
        .rd_req_size_o     (rd_req_size_i ),
        .rd_req_arid_o     ({rd_req_id_i,rd_req_order_id_i}),
        .rd_req_ready_i    (rd_req_ready_o),
        .rd_rsp_rid_i      ({rd_rsp_id_o,rd_rsp_order_id_o}),
        .rd_rsp_data_i     (rd_rsp_data_o      ),
        .rd_rsp_len_i      (rd_rsp_len_o       ),
        .rd_rsp_size_i     (rd_rsp_size_o      ),
        .rd_rsp_addr_i     (rd_rsp_buff_addr_o ),
        .rd_rsp_valid_i    (rd_rsp_valid_o     ),
        .rd_rsp_ready_o    (rd_rsp_ready_i     )
      );
    end

    if (APB_INTF_EN == 0) begin : INIT_EN
      apb2init #(
        .DDR_TYPE      (DDR_TYPE      ),
        .GEAR_RATIO    (GEAR_RATIO    ),
        .PWR_DOWN_EN   (PWR_DOWN_EN   ),
        .DBI_ENABLE    (DBI_ENABLE    ),
        .ECC_ENABLE    (ECC_ENABLE    ),
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
      assign trn_opr_i = SIM ? 8'h00 : 8'h1F;
    end // if (APB_INTF_EN == 0)
  endgenerate

  `include "dut_inst.v"
  `include "cpnx_mc_inst.v"

  //-------------------------------------//
  //-------- output assignments  --------//
  //-------------------------------------//

  assign LED[11:0]     = {~LED_array2[0],~LED_array[0], led_o[9:0]};
  assign ddr_odt_ca_o = 1'b0;  // unused because we use implicit ODT

  `ifdef DQSDQ_DEBUG_EN
  always @(posedge sclk_o or negedge sreset_n) begin
    if (!sreset_n) begin
      dbg_rddata_en_out <= 1'b0;
      dbg_wddata_en_out <= 1'b0;
    end
    else begin
      dbg_rddata_en_out <= dbg_rddata_en_o;
      dbg_wddata_en_out <= dbg_wddata_en_o;
    end
  end // always_ff
  `endif

  //--------------------------------------------//
  //-------- for debugging with Reveal  --------//
  //--------------------------------------------//

  always @(posedge clk_w or negedge areset_n) begin
    if (!areset_n) begin
        rvl_a_test_num_r   <= {TOTAL_MGR_COUNT_TOP*GEN_OUT_WIDTH{1'b0}};
        a_test_num_r       <= {TOTAL_MGR_COUNT_TOP*GEN_OUT_WIDTH{1'b0}};
        a_rd_error_occur_r <= {TOTAL_MGR_COUNT_TOP{1'b0}};
    end
    else begin
        rvl_a_test_num_r   <= a_test_num_w;
        a_test_num_r       <= a_test_num_w;
        a_rd_error_occur_r <= a_rd_error_occur_w;
    end
  end

  always @(posedge sclk_o or negedge sreset_n) begin
    if (!sreset_n) begin
        s_rd_error_occur_r1    <= {TOTAL_MGR_COUNT_TOP{1'b0}};
        s_rd_error_occur_r2    <= {TOTAL_MGR_COUNT_TOP{1'b0}};
        rvl_s_rd_error_occur_r <= {TOTAL_MGR_COUNT_TOP{1'b0}};
        a2s_test_num_r1        <= {TOTAL_MGR_COUNT_TOP*GEN_OUT_WIDTH{1'b0}};
        a2s_test_num_r2        <= {TOTAL_MGR_COUNT_TOP*GEN_OUT_WIDTH{1'b0}};
        rvl_s_test_num_r       <= {TOTAL_MGR_COUNT_TOP*GEN_OUT_WIDTH{1'b0}};
    end
    else begin
        s_rd_error_occur_r1    <= a_rd_error_occur_r;
        s_rd_error_occur_r2    <= s_rd_error_occur_r1;
        rvl_s_rd_error_occur_r <= s_rd_error_occur_r2;
        a2s_test_num_r1        <= a_test_num_r;
        a2s_test_num_r2        <= a2s_test_num_r1;
        rvl_s_test_num_r       <= a2s_test_num_r2;
    end
  end




  endmodule
`endif

