`ifndef TB_TOP_V
`define TB_TOP_V
//0---------------------------------------------------------------------------------------------------
// File Name      : tb_top.v
// Project        : TSE_MAC IIP
// Date Created   : 20-08-2020
// Description    : This is HDL top file 
// Generator      : Test bench Compiler Version 1.1
//0---------------------------------------------------------------------------------------------------

//0###################################################################################################
// Include files 
//0###################################################################################################

`include "tse_mac_defines.v"
`ifdef RADIANT_ENV
  `include "VLO.v"
  //`include "rxmac_clk_pll.v"
  //`include "txmac_clk_pll.v"
  //`include "EHXPLLA.v"
  //`include "EPLLD.v"
  `include "pmi_ram_dp_sim.v"
  `include "lscc_oddrx_soft.v"
  `include "lscc_pkt_mon_gbcl.v"
  `include "lscc_pkt_mon_sgts.v"
  //`include "lscc_lmmi2ahbl_single.v"
  //`include "lscc_lmmi2apb.v"
  
  `include "tse_mac_traffic_gen.v"
  `include "tse_mac_ahb_master.v"
  `include "tse_mac_axi4l_master.v"
  `include "tse_mac_output_monitor.v"
  `include "tse_mac_scoreboard.v"
`else
  `include "tse_mac_rtl_include.vh"
  `include "tse_mac_tb_include.vh"
`endif

module tb_top;

`ifdef RADIANT_ENV
  `include "dut_params.v"
`else
  `include "params.v"
`endif

  // =============================================================================
  // Variable Declarations
  // =============================================================================
  reg                      clk_r;
  integer                  clk_cnt_i;
  reg                      clk_125_r;
  reg                      clk_100_r;
  reg                      clk_50_r;
  reg                      clk_25_r;
  reg                      clk_12_5_r;
  reg                      clk_1_25_r;
  reg                      ds_lmmi_clk_r;       
  wire                     tx_clk_w;
  wire                     rx_clk_w;
  reg                      reset_n_r;
  reg[7:0]                 lmmi_wdata_8b;
  reg                      lmmi_wr_rdn_b;
  reg[7:0]                 lmmi_offset_8b;
  reg                      tx_clk_en_b;
  reg                      rx_clk_en_b;
  reg                      col_b;
  reg                      crs_b;
  reg                      mdc_b;
  reg                      mdi_b;
  wire                     mdio_en_o;
  reg[15:0]                tx_sndpause_16b;
  reg                      tx_sndpausereq_b;
  reg                      tx_fifoctrl_b;
  reg                      ignore_pkt_b;
  reg                      apb_pen_b;
  reg                      apb_psel_b;
  reg                      apb_pwr_b;
  reg[OFFSET_WIDTH-1:0]    apb_paddr_8b;
  reg[IF_DATA_WIDTH-1:0]   apb_pwdata_8b;
  wire[7:0]                lmmi_wdata_i;
  wire[7:0]                lmmi_offset_i;
  wire[15:0]               tx_sndpaustim_i;
  wire[IF_DATA_WIDTH-1:0]  ahbl_hwdata_i;
  wire[OFFSET_WIDTH-1:0]   ahbl_haddr_i;
  wire                     ahbl_hwrite_i;
  wire[OFFSET_WIDTH-1:0]   apb_paddr_i;
  wire[IF_DATA_WIDTH-1:0]  apb_pwdata_i;
  wire[IF_DATA_WIDTH-1:0]  apb_prdata_o;
  wire                     apb_penable_i;
  wire                     apb_psel_i;
  wire                     apb_pwrite_i;
  wire                     lmmi_rdata_valid_o;
  wire[IF_DATA_WIDTH-1:0]  lmmi_rdata_o;
  wire                     lmmi_ready_o;
  wire[30:0]               tx_statvec_o;
  wire[31:0]               rx_stat_vector_o;
  wire[7:0]                rx_dbout_o;
  wire [31:0]              o_tx_edata_idx;
  wire [31:0]              o_tx_edata_size;
  wire [8:0]               ds_lmmi_wdata_i;
  wire [8:0]               ds_lmmi_rdata_o;
  wire [IF_DATA_WIDTH-1:0] ahbl_hrdata_o;    
  wire [1:0]               ahbl_htrans_i;       
  wire [2:0]               ahbl_hburst_i;            
  wire [2:0]               ahbl_hsize_i;            
  wire [3:0]               ahbl_hprot_i;              
  wire                     ahbl_hreadyout_o;   
  wire                     axi_awvalid_i;   //write address channel
  wire                     axi_awready_o;
  wire [OFFSET_WIDTH-1:0]  axi_awaddr_i; 
  wire [2:0]               axi_awprot_i;        //not used
  wire                     axi_wvalid_i;    //write channel
  wire                     axi_wready_o; 
  wire [IF_DATA_WIDTH-1:0] axi_wdata_i;  
  wire                     axi_wstrb_i;	        //not used 
  wire                     axi_bvalid_o;    //write respond channel
  wire                     axi_bready_i; 
  wire [1:0]               axi_bresp_o;	        //bresp default 2'b00 (okay)
  wire                     axi_arvalid_i;   //read address channel
  wire                     axi_arready_o;
  wire [OFFSET_WIDTH-1:0]  axi_araddr_i; 
  wire [2:0]               axi_arprot_i;        //not used
  wire                     axi_rvalid_o;    //read channel
  wire                     axi_rready_i; 
  wire [IF_DATA_WIDTH-1:0] axi_rdata_o;
  wire [1:0]               axi_rresp_o;
  
  wire [7:0]              txd_o;                                 
  wire                    tx_en_o;
  wire                    tx_er_o;
  wire [7:0]              tb_txd_o;                                 
  wire                    tb_tx_en_o;
  wire                    tb_tx_er_o;

  wire [7:0]              txd_pos_o;                                 
  wire [3:0]              txd_neg_o;                                 
  wire [7:0]              rxd_pos_i;                                 
  wire [3:0]              rxd_neg_i;                                 
  wire                    rx_dv_pos_i;
  wire                    rx_er_pos_i;
  wire                    rx_dv_neg_i;
  wire                    rx_er_neg_i;
  wire [7:0]              rxd_i;                                 
  wire                    rx_dv_i;
  wire                    rx_er_i;
  wire  [7:0]             gmii_rxd_i;                                 
  wire                    gmii_rx_dv_i;
  wire                    gmii_rx_er_i;
  wire [31:0]             o_tx_gdata_idx;                             
  wire [31:0]             o_tx_gdata_size;                       
  wire [31:0]             o_rx_gdata_idx;                             
  wire [31:0]             o_rx_gdata_size;                       
  wire [31:0]             o_mdio_gdata_idx;                             
  wire [31:0]             o_mdio_gdata_size;                       
  wire [7:0]              o_tx_data_8b;
  wire                    o_tx_en;
  wire                    o_tx_err;

//Receiver variable declaration
  wire [31:0]             o_rx_edata_idx;
  wire [31:0]             o_rx_edata_size;

//MII/GMII interface output signals
  wire [7:0]              mii_gmii_txd_o;           
  wire                    mii_gmii_tx_en_o;       
  wire                    mii_gmii_tx_er_o;       
//MII/GMII interface input signals
  wire [7:0]              mii_gmii_rxd_i;           
  wire                    mii_gmii_rx_dv_i;     
  wire                    mii_gmii_rx_er_i;  

//RGMII variable declaration
//RGMII interface output signals
  wire [3:0]              rgmii_txd_o;           
  wire                    rgmii_tx_ctl_o;       
//RGMII interface input signals
  wire [3:0]              rgmii_rxd_i;           
  wire                    rgmii_rx_ctl_i;  

//RMII variable declaration
//RMII interface output signals
  wire [1:0]              rmii_txd_o;           
  wire                    rmii_tx_en_o;       
//RMII interface input signals
  wire [1:0]              rmii_rxd_i;           
  wire                    rmii_rx_crs_dv_i;  
  wire                    rmii_rx_er_i;  

// AXI4 Stream Master Interface
  wire                    axis_rx_tvalid_o;
  wire [7:0]              axis_rx_tdata_o;
  wire                    axis_rx_tlast_o;
  reg                     axis_rx_tready_i;

// AXI4 Stream Slave Interface
  wire                    axis_tx_tready_o;
  wire                    axis_tx_tvalid_i;
  wire  [7:0]             axis_tx_tdata_i;
  wire                    axis_tx_tlast_i;

  wire                    rxmac_clk_i;
  reg                     rx_dv;
  reg                     rx_er;
  reg [7:0]               rxd;
  reg [3:0]               txd_10_100;
  reg [7:4]               txd_pos_x;
  reg                     tx_en_d_x;
  reg                     tx_er_d_x;
  reg                     tx_en_10_100;
  reg                     tx_er_10_100;
  reg [7:0]               txd_1g;
  reg                     tx_en_1g;
  reg                     tx_er_1g;
  reg                     pkt_loop_clksel_ri;
  wire                    txmac_clk_c;
  wire                    rxmac_clk;
  wire                    txmac_clk_1g; //
  wire                    rxmac_clk_c;
  wire [3:0]              txd_int;
  wire [7:0]              txd;
  wire                    tx_en;
  wire                    tx_er;
  reg                     rgmii_b;
  wire                    txmac_sample_clk_i; //
  wire                    rxmac_transmit_clk_i; //
// Output signals from the CPU Interface
  wire                    cpu_if_gbit_en_o; //  Gig or 10/100 mode
  reg                     rx_clk_div2;      // rx_clk divided by 2
  reg                     tx_clk_div2;      // tx_clk divided by 2
  reg                     rx_clk_div4;      // rx_clk divided by 4
  reg                     tx_clk_div4;      // tx_clk divided by 4
  reg                     sys_clk ;
  wire                    col_i;            // Collision detect
  wire                    crs_i;            // Carrier Sense
  wire                    reset_n_i;
  reg                     pll_reset;
  reg                     pll_reset_n;
  reg [3:0]               rst_4b;
  reg [7:0]               wdata_8b            ;// Variable for Data 
  wire                    lmmi_req_w          ;// To indicate the LMMI req for AHB
  reg                     lmmi_req_b          ;// To indicate the LMMI req for APB
  //Variable for SGMII easy connect with GMII
  reg [1:0]               sgmii_spd_2b        ;// Varieble to control speed in SGMII easy connect mode (0 - 1G, 1 - 100M, 2 - 10M)
  wire [7:0]              rxd_8b               ;
  wire                    rx_dv_b              ;
  wire                    rx_er_b              ;
  wire                    mdc                  ;// Management data clock

  wire                    tx_sndpausreq_i      ;// Transmit PAUSE frame request
  wire                    clk_i                ;// Input Clock signal 
  wire                    txmac_clk            ;// Transmit MAC clock signal 
  wire                    txmac_clk_i          ;// Transmit MAC Input clock signal
  wire                    ds_lmmi_clk_i        ;// LMMI Input clock signal
  wire                    ahbl_hready_i        ;// AHBL input ready signal
  wire                    txmac_clk_en_i       ;// Transmit input clock enable
  wire                    rxmac_clk_en_i       ;// Receive mac input clock enable
  wire                    mdc_i                ;// Input clock signal for MIIM_MODULE
  wire                    mdi_i                ;// Input signal for the MIIM_MODULE
  wire                    tx_fifoctrl_i        ;// Transmit fifo control signal 
  wire                    ignore_pkt_i         ;// Ingore packet signal
  
  wire                    tx_mii_clk_i         ;//TX Input clock signal for MII Interface(To support RGMII and Classic - 10M/100M speed)
  wire                    rx_mii_clk_i         ;//RX Input clock signal for MII Interface(To support RGMII and Classic - 10M/100M speed)
  
  wire                    rmii_ref_clk_i       ;//clock signal for RMII Interface
  
  
  reg [16383:0]           test_name_s          ; // Use for storing testcase
  integer                 num_tran_ui          ; // Use for storing number of transcations
  integer                 ntran_ui             ; // Use for storing number of transcations
  integer                 user_debug_i         ; // Use for storing debug level passed by user
  reg                     finish_on_error_b    ; // Terminate on error message
  integer                 seed_i               ; // Random seed to control the randomization
  integer                 errs_i               ; // Total number of errors detected
  integer                 trans_i              ; // Total number of transactions
  integer                 timeout_cnt_i        ; // Timeout counter
  integer                 rx_timeout_cnt_i     ; // Timeout counter

  wire                    crc_output_valid;
  wire [8* 4:1]           received_crc;
  wire [8* 4:1]           expected_crc;
  reg [15:0]              err_cnt;

  reg                     rmii_100m_en;
  
  //1###################################################################################################
  // Code to assign the input signals 
  //1###################################################################################################
  assign clk_i             = ((GBE_MAC == 1) || (SGMII_TSMAC == 1) || (cpu_if_gbit_en_o == 1)) ? clk_100_r:clk_r;
  assign tx_clk_w          = RMII? clk_50_r: (((GBE_MAC == 1) || (SGMII_TSMAC == 1) || (cpu_if_gbit_en_o == 1)) ? clk_125_r:clk_25_r);
  assign rx_clk_w          = RMII? clk_50_r: (((GBE_MAC == 1) || (SGMII_TSMAC == 1) || (cpu_if_gbit_en_o == 1)) ? clk_125_r:clk_25_r);
  assign rxmac_clk         = rxmac_clk_c;
  assign txmac_clk         = txmac_clk_c;
  assign rxmac_clk_c       = RMII? (rmii_100m_en? rx_clk_div4: clk_1_25_r): ((cpu_if_gbit_en_o == 1) ? clk_125_r : rx_clk_div2);
  assign txmac_clk_c       = RMII? (rmii_100m_en? tx_clk_div4: clk_1_25_r): ((cpu_if_gbit_en_o == 1) ? clk_125_r : tx_clk_div2);
  assign txmac_clk_i       = (GBE_MAC == 1) || (SGMII_TSMAC == 1) ? tx_clk_w:txmac_clk_c;
  assign rxmac_clk_i       = (GBE_MAC == 1) || (SGMII_TSMAC == 1) ? rx_clk_w:rxmac_clk_c;
  assign tx_mii_clk_i      = clk_25_r;
  assign rx_mii_clk_i      = clk_25_r;
  assign rmii_ref_clk_i    = clk_50_r;
  assign ds_lmmi_clk_i     = ds_lmmi_clk_r;
  assign reset_n_i         = reset_n_r;
  assign ahbl_hready_i     = ahbl_hreadyout_o;
  assign txmac_clk_en_i    = tx_clk_en_b;
  assign rxmac_clk_en_i    = rx_clk_en_b;
  assign mdc_i             = clk_r;
  assign mdi_i             = 1;
  assign col_i             = col_b;
  assign crs_i             = crs_b;
  assign tx_sndpaustim_i   = tx_sndpause_16b;
  assign tx_sndpausreq_i   = tx_sndpausereq_b;
  assign tx_fifoctrl_i     = tx_fifoctrl_b;
  assign ignore_pkt_i      = ignore_pkt_b;
  assign tb_txd_o          = (GBE_MAC == 1) || (SGMII_TSMAC == 1) ? txd_o:txd;
  assign tb_tx_en_o        = (GBE_MAC == 1) || (SGMII_TSMAC == 1) ? tx_en_o:tx_en;
  assign tb_tx_er_o        = (GBE_MAC == 1) || (SGMII_TSMAC == 1) ? tx_er_o:tx_er;
  assign txmac_sample_clk_i   = RMII? tx_clk_w :(((GBE_MAC == 1) || (SGMII_TSMAC == 1) || (cpu_if_gbit_en_o == 1)) ? txmac_clk_i:tx_clk_w);
  assign rxmac_transmit_clk_i = RMII? rx_clk_w :(((GBE_MAC == 1) || (SGMII_TSMAC == 1) || (cpu_if_gbit_en_o == 1)) ? rxmac_clk_i:rx_clk_w);
  generate
    if (CLASSIC_TSMAC == 1) begin
      assign rxd_pos_i     = rxd_8b;
      assign rx_dv_pos_i   = rx_dv_b;
      assign rx_er_pos_i   = rx_er_b;
      assign rxd_neg_i     = rxd_8b[3:0];
      assign rx_dv_neg_i   = rx_dv_b;
      assign rx_er_neg_i   = rx_er_b;
    end
	else if (MII_GMII) begin
	  assign  mii_gmii_rxd_i   = rxd_8b;
	  assign  mii_gmii_rx_dv_i = rx_dv_b;
	  assign  mii_gmii_rx_er_i = rx_er_b;
	end
    else if (GBE_MAC || SGMII_TSMAC) begin
      assign rxd_i         = rxd_8b;
      assign rx_dv_i       = rx_dv_b;
      assign rx_er_i       = rx_er_b;
    end
  endgenerate
  generate
    if (INTERFACE == "LMMI") begin
      assign lmmi_request_i = lmmi_req_b;
      assign lmmi_wdata_i   = lmmi_wdata_8b;
      assign lmmi_offset_i  = lmmi_offset_8b;
      assign lmmi_wr_rdn_i  = lmmi_wr_rdn_b;
    end else if (INTERFACE == "APB") begin
      assign apb_penable_i  = apb_pen_b;
      assign apb_psel_i     = apb_psel_b;
      assign apb_pwrite_i   = apb_pwr_b;
      assign apb_paddr_i    = apb_paddr_8b;
      assign apb_pwdata_i   = apb_pwdata_8b;
    end
  endgenerate


  //1###################################################################################################
  //This block will generate the Divider clock for MII
  //1###################################################################################################
  always @(posedge rx_clk_w)
  begin
    if (pll_reset == 1'b1) begin
      rx_clk_div2 <= 1'b0;
    end else begin
      rx_clk_div2 <= ~rx_clk_div2;
    end
  end 

  always @(posedge tx_clk_w)
  begin
    if (pll_reset_n == 1'b0) begin
      tx_clk_div2 <= 1'b0;
    end else begin
      tx_clk_div2 <= ~tx_clk_div2;
    end 
  end

  //1###################################################################################################
  //This block will generate the Divider clock for RMII
  //1###################################################################################################
  
  initial
  begin
    rx_clk_div4 <= 1'b0;
    tx_clk_div4 <= 1'b0;
  end
  
  always @(posedge rx_clk_div2)
    rx_clk_div4 <= ~rx_clk_div4;

  always @(posedge tx_clk_div2)
    tx_clk_div4 <= ~tx_clk_div4;

  //1###################################################################################################
  // Initilize all the variales
  //1###################################################################################################
  initial
  begin
    clk_r              = 0; 
    clk_cnt_i          = 0;
    clk_125_r          = 0; 
	clk_100_r          = 0;
	clk_50_r           = 0;
    clk_25_r           = 0; 
    clk_12_5_r         = 0; 
    clk_1_25_r         = 1; 
    sys_clk            = 0; 
    reset_n_r          = 0; 
    lmmi_wdata_8b      = 0; 
    lmmi_wr_rdn_b      = 0;
    lmmi_offset_8b     = 0;    
    ds_lmmi_clk_r      = 0;       
    tx_clk_en_b        = 0;            
    rx_clk_en_b        = 0;             
    col_b              = 0;               
    crs_b              = 0;             
    mdc_b              = 0;            
    mdi_b              = 0;              
    tx_sndpause_16b    = 0;                       
    tx_sndpausereq_b   = 0;                     
    tx_fifoctrl_b      = 0;                      
    ignore_pkt_b       = 0;                        
    apb_pen_b          = 0;                      
    apb_psel_b         = 0;                    
    apb_pwr_b          = 0;               
    apb_paddr_8b       = 0;
    apb_pwdata_8b      = 0;
    pkt_loop_clksel_ri = 1'b0;// Packet Loop Clock Select
    rst_4b             = 0;
    wdata_8b           = 0;
    rgmii_b            = 0;
    lmmi_req_b         = 0;
    sgmii_spd_2b       = 0;
	rmii_100m_en       = 1;
  end             

  //1###################################################################################################
  // Initilize master ready signal for TSE-MAC Receiver 
  //1###################################################################################################
  initial
  begin
    axis_rx_tready_i = 1'b0;
    @(posedge reset_n_i);
    repeat (16)
    begin
      @(negedge rxmac_clk_i);
    end
    axis_rx_tready_i = 1'b1;
  end

  //1###################################################################################################
  //GSR inst in existing TB
  //1###################################################################################################
  
  reg CLK_GSR = 0;
  reg USER_GSR = 0;
  // HAM    wire GSROUT;
  
  initial begin
    forever begin
  // HAM        #5;
      #10;
      CLK_GSR = ~CLK_GSR;
    end
  end
  
  GSR GSR_INST (
    .GSR_N(1'b1),
    .CLK(1'b0)
  );

  //1###################################################################################################
  // system reset
  //1###################################################################################################
  initial
  begin
    pll_reset   = 1'b0;
    pll_reset_n = 1'b1;
    #101;
    pll_reset   = 1'b1;
    pll_reset_n = 1'b0;
    #500;
    pll_reset   = 1'b0;
    pll_reset_n = 1'b1;
    #500;
  end

  //1-------------------------------------------------------------------------------------------------
  // System Clock generator 
  //1-------------------------------------------------------------------------------------------------
  always
  begin
    #40;
    clk_r = ~clk_r;
  end
  
  //1-------------------------------------------------------------------------------------------------
  // 1G mode Clock generator 
  //1-------------------------------------------------------------------------------------------------
  always
  begin
    #4;
    clk_125_r = ~clk_125_r;
  end
  
  always
  begin
    #5;
    clk_100_r = ~clk_100_r;
  end
  
  //1-------------------------------------------------------------------------------------------------
  // Ds lmmi Clock generator 
  //1-------------------------------------------------------------------------------------------------
  always
  begin
    #4;
    ds_lmmi_clk_r = ~ds_lmmi_clk_r;
  end
  
  //1-------------------------------------------------------------------------------------------------
  // 100mbps mode Clock generator 
  //1-------------------------------------------------------------------------------------------------
  always
  begin
    #20;
    clk_25_r = ~clk_25_r;
  end
  
  always
  begin
    #40;
    clk_12_5_r = ~clk_12_5_r;
  end
  
  //1-------------------------------------------------------------------------------------------------
  // 10mbps mode Clock generator 
  //1-------------------------------------------------------------------------------------------------
  always
  begin
    #400;
    clk_1_25_r = ~clk_1_25_r;
  end

  always
  begin
    #4;
    sys_clk = ~sys_clk;
  end
  
  //1-------------------------------------------------------------------------------------------------
  // 50MHz Clock generator 
  //1-------------------------------------------------------------------------------------------------
  always
  begin
    #10;
    clk_50_r = ~clk_50_r;
  end

  //1###################################################################################################
  //Assigning the Data to the CLASSIC_TSE_MAC(1G,10,100M) and GMAC
  //1###################################################################################################
  if (CLASSIC_TSMAC == 1)
  begin
    // GMII outputs TXD[3:0] use DDR output cell
    lscc_oddrx_soft U0_DDR_TXD
    (
      .DA     (txd_pos_o[0]),
      .DB     (txd_neg_o[0]),
      .RST    (~reset_n_i),
      .CLK_I  (txmac_clk_c),
      .CLK_IX2(tx_clk_w),
      .Q      (txd_int[0])
    );
  
    lscc_oddrx_soft U1_DDR_TXD
    (
      .DA(txd_pos_o[1]),
      .DB(txd_neg_o[1]),
      .RST(~reset_n_i),
      .CLK_I(txmac_clk_c),
      .CLK_IX2(tx_clk_w),
      .Q(txd_int[1])
    );
  
    lscc_oddrx_soft U2_DDR_TXD
    (
      .DA(txd_pos_o[2]),
      .DB(txd_neg_o[2]),
      .RST(~reset_n_i),
      .CLK_I(txmac_clk_c),
      .CLK_IX2(tx_clk_w),
      .Q(txd_int[2])
    );
  
    lscc_oddrx_soft U3_DDR_TXD
    (
      .DA(txd_pos_o[3]),
      .DB(txd_neg_o[3]),
      .RST(~reset_n_i),
      .CLK_I(txmac_clk_c),
      .CLK_IX2(tx_clk_w),
      .Q(txd_int[3])
    );
  
    always @(posedge tx_clk_w or negedge reset_n_i)
    begin
      if (~reset_n_i)
      begin
        txd_10_100[3:0] <=  4'h0;
      end else
      begin
        txd_10_100[3:0] <=  txd_int;
      end
    end
  
    // GMII outputs TXD[7:4] are first sampled on the positive edge of txmac_clk_c
    // and then transfered to neg edge flip-flops in I/O
    // this is done to sync TXD[7:4] data to TXD[3:0] data out of ODDRXC
    // cells during 1Gbs operation
    always @(posedge txmac_clk_c or negedge reset_n_i)
    begin
      if (~reset_n_i)
      begin
        txd_pos_x[7:4] <=  4'h0;
        tx_en_d_x      <=  1'b0;
        tx_er_d_x      <=  1'b0;
      end else
      begin
        txd_pos_x[7:4] <=  txd_pos_o[7:4];
        tx_en_d_x      <=  tx_en_o;
        tx_er_d_x      <=  tx_er_o;
      end
    end
  
    always @(negedge txmac_clk_c or negedge reset_n_i)
    begin
      if (~reset_n_i)
      begin
        tx_en_10_100    <=  1'b0;
        tx_er_10_100    <=  1'b0;
      end else
      begin
        //txd_10_100      <= txd_pos_x[7:4];
        tx_en_10_100    <=  tx_en_d_x;
        tx_er_10_100    <=  tx_er_d_x;
      end
    end
  
    always @(posedge txmac_clk_c or negedge reset_n_i)
    begin
      if (~reset_n_i) begin
        txd_1g    <=  8'h00;
        tx_en_1g  <=  1'b0;
        tx_er_1g  <=  1'b0;
      end else
      begin
        txd_1g    <=  txd_pos_o;
        tx_en_1g  <=  tx_en_o;
        tx_er_1g  <=  tx_er_o;
      end
    end
  
    assign txd   = cpu_if_gbit_en_o ?   txd_1g : {4'h0,txd_10_100};
    assign tx_en = cpu_if_gbit_en_o ? tx_en_1g : tx_en_10_100;
    assign tx_er = cpu_if_gbit_en_o ? tx_er_1g : tx_er_10_100;
  end else
  begin // GBE_MAC OR SGMII_TSMAC
    always @(posedge txmac_clk_c or negedge reset_n_i)
    begin
      if (~reset_n_i)
      begin
        txd_1g    <=  8'h00;
        tx_en_1g  <=  1'b0;
        tx_er_1g  <=  1'b0;
      end else
      begin
        txd_1g    <=  txd_pos_o;
        tx_en_1g  <=  tx_en_o;
        tx_er_1g  <=  tx_er_o;
      end
    end
  
    assign txd   = txd_1g;
    assign tx_en = tx_en_1g;
    assign tx_er = tx_er_1g;
  end

  //1###################################################################################################
  //Logic to drive the clock enable for transmiter and receiver in SGMII easy
  //connect
  //1###################################################################################################
  generate 
    if (SGMII_TSMAC == 1) begin 
      always @(posedge txmac_clk_i or negedge reset_n_i) begin
        if (!reset_n_i) begin 
          tx_clk_en_b <= 0; 
          rx_clk_en_b <= 0;
          clk_cnt_i   <= 0;
        end else begin 
          if (sgmii_spd_2b == 0) begin //SGMII easy connect in 1G mode 
            clk_cnt_i   <= 0;
            tx_clk_en_b <= 1; 
            rx_clk_en_b <= 1; 
          end else if (sgmii_spd_2b == 1) begin //SGMII easy connect in 100M mode
            if (clk_cnt_i >= 9) begin 
              tx_clk_en_b <= 1; 
              rx_clk_en_b <= 1; 
              clk_cnt_i   <= 0;
            end else begin
              clk_cnt_i   <= clk_cnt_i + 1; 
              tx_clk_en_b <= 0; 
              rx_clk_en_b <= 0; 
            end
          end else if (sgmii_spd_2b == 2) begin //SGMII easy connect in 10M mode
            if (clk_cnt_i >= 99) begin 
              tx_clk_en_b <= 1; 
              rx_clk_en_b <= 1; 
              clk_cnt_i   <= 0;
            end else begin
              clk_cnt_i   <= clk_cnt_i + 1; 
              tx_clk_en_b <= 0; 
              rx_clk_en_b <= 0; 
            end
          end
        end
      end 
    end else begin //GBE MAC or Classic MAC 
      always @(posedge txmac_clk_i or negedge reset_n_i) begin
        if (!reset_n_i) begin 
          tx_clk_en_b <= 0; 
          rx_clk_en_b <= 0;
        end else begin 
          tx_clk_en_b <= 1; 
          rx_clk_en_b <= 1; 
        end
      end
    end
  endgenerate

  //==================================================================
  // Connect the Core instance 
  //==================================================================
 `ifdef RADIANT_ENV
   `include "dut_inst.v"
 `else
  lscc_tse_mac_core #(.MII_GMII(MII_GMII),.SGMII_TSMAC(SGMII_TSMAC),.CLASSIC_TSMAC(CLASSIC_TSMAC),.GBE_MAC(GBE_MAC),.RGMII(RGMII),.DATA_WIDTH(DATA_WIDTH),.OFFSET_WIDTH(OFFSET_WIDTH),.MIIM_MODULE(MIIM_MODULE),.INTERFACE(INTERFACE))u_dut ( 
    // ---Clock and reset signal
    .txmac_clk_i            (txmac_clk_i             ),
    .rxmac_clk_i            (rxmac_clk_i             ),
    .tx_mii_clk_i           (tx_mii_clk_i            ),
    .rx_mii_clk_i           (rx_mii_clk_i            ),
    .clk_i                  (clk_i                   ),
    .reset_n_i              (reset_n_r               ),
    // ---LMMI Write signal
    .lmmi_wdata_i           (lmmi_wdata_i            ),
    // ---LMMI Read signal
    .lmmi_rdata_o           (lmmi_rdata_o            ),
    .lmmi_rdata_valid_o     (lmmi_rdata_valid_o      ),
    // ---LMMI Control signal
    .lmmi_ready_o           (lmmi_ready_o            ),
    .lmmi_wr_rdn_i          (lmmi_wr_rdn_i           ),
    .lmmi_offset_i          (lmmi_offset_i           ),
    .lmmi_request_i         (lmmi_request_i          ),
    // ---Lattice interrupt interface
    .int_o                  (int_o                   ),
    // control signals outputs
    .txmac_clk_en_i         (txmac_clk_en_i          ),// clock enable to the Tx MAC
    .rxmac_clk_en_i         (rxmac_clk_en_i          ),// clock enable to the RX MAC
    .rxd_pos_i              (rxd_pos_i               ),// Receive data
    .rxd_neg_i              (rxd_neg_i               ),// Receive data
    .rx_dv_pos_i            (rx_dv_pos_i             ),// Receive data valid
    .rx_dv_neg_i            (rx_dv_neg_i             ),// Receive data valid
    .rx_er_pos_i            (rx_er_pos_i             ),// Receive data error
    .rx_er_neg_i            (rx_er_neg_i             ),// Receive data error
    .rxd_i                  (rxd_i                   ),// Receive data
    .rx_dv_i                (rx_dv_i                 ),// Receive data valid
    .rx_er_i                (rx_er_i                 ),// Receive data error
    .col_i                  (col_i                   ),// Collision detect
    .crs_i                  (crs_i                   ),// Carrier Sense
    // Input/Output signals from the MII Management Interface
    .mdc_i                  (mdc_i                   ),// Management Data clock
    .mdi_i                  (mdi_i                   ),// Management Data Input
    .mdo_o                  (mdo_o                   ),// Management Data output
    .mdio_en_o              (mdio_en_o               ),// Mgmt Data out enable
    // Input signals to the Tx MAC FIFO Interface
    .tx_sndpaustim_i        (tx_sndpaustim_i         ),// Pause frame parameter
    .tx_sndpausreq_i        (tx_sndpausreq_i         ),// Transmit PAUSE frame
    .tx_fifoctrl_i          (tx_fifoctrl_i           ),// Control frame or Not
    // Input signals to the Rx MAC FIFO Interface
    .ignore_pkt_i           (ignore_pkt_i            ),// Ignore the frame
    // Output signals from the GMII
    .tx_en_o                (tx_en_o                 ),// Transmit Enable
    .tx_er_o                (tx_er_o                 ),// Transmit Error
    .txd_pos_o              (txd_pos_o               ),// Transmit data
    .txd_neg_o              (txd_neg_o               ),// Transmit data
    .txd_o                  (txd_o                   ),// Transmit data
	.mii_gmii_rxd_i         (mii_gmii_rxd_i          ),
    .mii_gmii_rx_dv_i       (mii_gmii_rx_dv_i        ),
    .mii_gmii_rx_er_i       (mii_gmii_rx_er_i        ),
    .mii_gmii_txd_o         (mii_gmii_txd_o          ),
    .mii_gmii_tx_en_o       (mii_gmii_tx_en_o        ),
    .mii_gmii_tx_er_o       (mii_gmii_tx_er_o        ),
    .rgmii_txd_o            (rgmii_txd_o             ),//RGMII Transmitter data 
    .rgmii_tx_ctl_o         (rgmii_tx_ctl_o          ),//RGMII Transmitter control 
    .rgmii_rxd_i            (rgmii_rxd_i             ),//RGMII Receiver data 
    .rgmii_rx_ctl_i         (rgmii_rx_ctl_i          ),//RGMII Receiver data 
    // Output signals from the CPU Interface
    .cpu_if_gbit_en_o       (cpu_if_gbit_en_o        ),//  Gig or 10/100 mode
    // Output signals from the Tx MAC FIFO Interface
    .tx_macread_o           (tx_macread_o            ),
    .tx_discfrm_o           (tx_discfrm_o            ),
    .tx_staten_o            (tx_staten_o             ),
    .tx_done_o              (tx_done_o               ),
    .tx_statvec_o           (tx_statvec_o            ),
    // Output signals from the Rx MAC FIFO Interface
    .rx_fifo_error_o        (rx_fifo_error_o         ),// FIFO full detected    // HAM
    .rx_stat_vector_o       (rx_stat_vector_o        ),// Rx Status Vector
    //.rx_stat_en_o           (rx_stat_en_o            ),// Status Vector Valid
    //.rx_dbout_o             (rx_dbout_o              ),// Data Output to FIFO   // HAM
    .rx_eof_o               (rx_eof_o                ),// Entire frame written  // HAM
    .rx_error_o             (rx_error_o              ),// Erroneous frame       // HAM
    // AXI4 Stream Master Interface
    .axis_rx_tvalid_o       (axis_rx_tvalid_o        ),
    .axis_rx_tready_i       (axis_rx_tready_i        ),
    .axis_rx_tdata_o        (axis_rx_tdata_o         ),
    .axis_rx_tlast_o        (axis_rx_tlast_o         ),
    // AXI4 Stream Slave Interface
    .axis_tx_tvalid_i       (axis_tx_tvalid_i        ),
    .axis_tx_tready_o       (axis_tx_tready_o        ),
    .axis_tx_tdata_i        (axis_tx_tdata_i         ),
    .axis_tx_tlast_i        (axis_tx_tlast_i         ),
    //AHB-Lite Interface
    .ahbl_hsel_i            (ahbl_hsel_i             ),
    .ahbl_hready_i          (ahbl_hready_i           ), 
    .ahbl_haddr_i           (ahbl_haddr_i            ),
    .ahbl_hburst_i          (ahbl_hburst_i           ), 
    .ahbl_hsize_i           (ahbl_hsize_i            ),
    .ahbl_hmastlock_i       (ahbl_hmastlock_i        ),
    .ahbl_hprot_i           (ahbl_hprot_i            ),
    .ahbl_htrans_i          (ahbl_htrans_i           ),
    .ahbl_hwrite_i          (ahbl_hwrite_i           ),
    .ahbl_hwdata_i          (ahbl_hwdata_i           ),
    .ahbl_hreadyout_o       (ahbl_hreadyout_o        ),
    .ahbl_hresp_o           (ahbl_hresp_o            ),
    .ahbl_hrdata_o          (ahbl_hrdata_o           ),
    // APB Interface
    .apb_penable_i          (apb_penable_i           ),// apb enable
    .apb_psel_i             (apb_psel_i              ),// apb slave select
    .apb_pwrite_i           (apb_pwrite_i            ),// apb write 1, read 0
    .apb_paddr_i            (apb_paddr_i             ),// apb address
    .apb_pwdata_i           (apb_pwdata_i            ),// apb write data
    .apb_pready_o           (apb_pready_o            ),// apb ready
    .apb_pslverr_o          (apb_pslverr_o           ),// apb slave error
    .apb_prdata_o           (apb_prdata_o            ), // apb read data
	// AXI4L Interface
	.axi_awvalid_i	 		(axi_awvalid_i			 ),
	.axi_awready_o	  		(axi_awready_o			 ),
	.axi_awaddr_i		 	(axi_awaddr_i			 ),
	.axi_awprot_i		  	(axi_awprot_i			 ),
	.axi_wvalid_i		  	(axi_wvalid_i			 ),	
	.axi_wready_o		  	(axi_wready_o			 ),
	.axi_wdata_i		  	(axi_wdata_i			 ),
	.axi_wstrb		  		(axi_wstrb_i			 ),
	.axi_bvalid_o	  	  	(axi_bvalid_o			 ),
	.axi_bready_i	  	  	(axi_bready_i			 ),
	.axi_bresp_o	  	  	(axi_bresp_o			 ),
	.axi_arvalid_i	  		(axi_arvalid_i			 ),
	.axi_arready_o	  		(axi_arready_o			 ),
	.axi_araddr_i		  	(axi_araddr_i			 ),
	.axi_arprot_i		  	(axi_arprot_i			 ),
	.axi_rvalid_o		  	(axi_rvalid_o			 ),
	.axi_rready_i		  	(axi_rready_i			 ),
	.axi_rdata_o		  	(axi_rdata_o			 ),
	.axi_rresp_o		  	(axi_rresp_o			 )
	);
  `endif

  //==================================================================
  // Connect the TX traffic gen 
  //==================================================================
  tse_mac_traffic_gen #(.MII_GMII(MII_GMII),.SGMII_TSMAC(SGMII_TSMAC),.GBE_MAC(GBE_MAC),.MIIM_MODULE(MIIM_MODULE),.CLASSIC_TSMAC(CLASSIC_TSMAC),.RGMII(RGMII),.RMII(RMII) )U_traffic_gen (
    .i_txmac_clk        (txmac_clk_i              ),  
    .i_ds_lmmi_clk      (ds_lmmi_clk_i            ),
    .i_ds_lmmi_ready    (axis_tx_tready_o             ),
    .o_tx_edata_idx     (o_tx_edata_idx           ),
    .o_tx_edata_size    (o_tx_edata_size          ),
    .o_ds_lmmi_wr_rdn   (axis_tx_tvalid_i             ), 
    .o_ds_lmmi_wdata    ({axis_tx_tlast_i,axis_tx_tdata_i}), 
    .i_rxmac_clk        (rxmac_transmit_clk_i     ),  
    .o_rx_edata_idx     (o_rx_edata_idx           ),
    .o_rx_edata_size    (o_rx_edata_size          ),
    .o_rx_dv_b          (rx_dv_b                  ), 
    .o_rx_er_b          (rx_er_b                  ), 
    .o_rxd_8b           (rxd_8b                   ), 
    .o_rgmii_rx_ctl     (rgmii_rx_ctl_i           ), 
    .o_rgmii_rxd_4b     (rgmii_rxd_i              ),
    .o_rmii_rxd_2b      (rmii_rxd_i               ),
    .o_rmii_rx_crs_dv   (rmii_rx_crs_dv_i         ),
    .o_rmii_rx_er       (rmii_rx_er_i             )
  );
  
  //==================================================================
  // Connect the AHB Master 
  //==================================================================
  tse_mac_ahb_master  #(.SGMII_TSMAC(SGMII_TSMAC),.GBE_MAC(GBE_MAC),.MIIM_MODULE(MIIM_MODULE),.CLASSIC_TSMAC(CLASSIC_TSMAC),.RGMII(RGMII))U_ahb_master        (
                       .i_clk              (clk_i               ),   
                       .i_ahbl_hreadyout   (ahbl_hreadyout_o    ),                    
                       .i_ahbl_hrdata      (ahbl_hrdata_o       ),    
                       .o_ahbl_haddr       (ahbl_haddr_i        ),    
                       .o_ahbl_hwdata      (ahbl_hwdata_i       ),         
                       .o_ahbl_htrans      (ahbl_htrans_i       ),       
                       .o_ahbl_hwrite      (ahbl_hwrite_i       ),         
                       .o_ahbl_hburst      (ahbl_hburst_i       ),            
                       .o_ahbl_hsize       (ahbl_hsize_i        ),           
                       .o_ahbl_hprot       (ahbl_hprot_i        ),             
                       .o_ahbl_hsel        (ahbl_hsel_i         ),             
                       .o_ahbl_hmastlock   (ahbl_hmastlock_i    )              
  );
   
  //==================================================================
  // Connect the AXI4L Master 
  //==================================================================
  tse_mac_axi4l_master  #(.SGMII_TSMAC(SGMII_TSMAC),.GBE_MAC(GBE_MAC),.MIIM_MODULE(MIIM_MODULE),.CLASSIC_TSMAC(CLASSIC_TSMAC),.RGMII(RGMII))U_axi4l_master      (
                      .i_clk              (clk_i				),
					  .axi_awvalid		  (axi_awvalid_i		),
					  .axi_awready		  (axi_awready_o		),
					  .axi_awaddr		  (axi_awaddr_i			),
					  .axi_awprot		  (axi_awprot_i			),
					  .axi_wvalid		  (axi_wvalid_i			),	
					  .axi_wready		  (axi_wready_o			),
					  .axi_wdata		  (axi_wdata_i			),
					  .axi_wstrb		  (axi_wstrb_i			),
					  .axi_bvalid	  	  (axi_bvalid_o			),
					  .axi_bready	  	  (axi_bready_i			),
					  .axi_bresp	  	  (axi_bresp_o			),
					  .axi_arvalid		  (axi_arvalid_i		),
					  .axi_arready		  (axi_arready_o		),
					  .axi_araddr		  (axi_araddr_i			),
					  .axi_arprot		  (axi_arprot_i			),
					  .axi_rvalid		  (axi_rvalid_o			),
					  .axi_rready		  (axi_rready_i			),
					  .axi_rdata		  (axi_rdata_o			),
					  .axi_rresp		  (axi_rresp_o			)          
  );
   
  ////==================================================================
  //// Connect the Output Monitor
  ////==================================================================
  tse_mac_output_monitor #(.MII_GMII(MII_GMII),.SGMII_TSMAC(SGMII_TSMAC),.GBE_MAC(GBE_MAC),.MIIM_MODULE(MIIM_MODULE),.CLASSIC_TSMAC(CLASSIC_TSMAC),.RGMII(RGMII))U_output_monitor (
     .i_tx_mac_clk       (txmac_sample_clk_i  ),                             
     .i_tx_mac_clk_en    (txmac_clk_en_i      ),                             
     .i_tx_en            (tb_tx_en_o          ),                            
     .i_tx_er            (tb_tx_er_o          ),                          
     .i_txd              (tb_txd_o            ),                           
     .i_rgmii_txd        (rgmii_txd_o         ),                          
     .i_rgmii_tx_ctl     (rgmii_tx_ctl_o      ),   
     .i_mii_gmii_txd     (mii_gmii_txd_o      ),	 
     .i_mii_gmii_tx_en   (mii_gmii_tx_en_o    ), 	 
     .i_mii_gmii_tx_er   (mii_gmii_tx_er_o    ),	 
     .o_tx_gdata_idx     (o_tx_gdata_idx      ),                             
     .o_tx_gdata_size    (o_tx_gdata_size     ),                       
     .i_rx_mac_clk       (rxmac_clk_i         ),
     .i_rx_ready         (axis_rx_tready_i    ),
     .i_rx_data_valid    (axis_rx_tvalid_o    ),
     .i_rx_data          (axis_rx_tdata_o     ),
     .o_rx_gdata_idx     (o_rx_gdata_idx      ),
     .o_rx_gdata_size    (o_rx_gdata_size     ),
     .i_mdc              (mdc_i               ),
     .i_mdo              (mdo_o               ),
     .o_mdio_gdata_idx   (o_mdio_gdata_idx    ),                             
     .o_mdio_gdata_size  (o_mdio_gdata_size   ),
     .o_tx_data_8b       (o_tx_data_8b        ),
     .o_tx_en            (o_tx_en             ),
     .o_tx_err           (o_tx_err            )
   );
  //==================================================================
  // Connect the Scoreboard
  //==================================================================
  tse_mac_scoreboard  #(.SGMII_TSMAC(SGMII_TSMAC),.GBE_MAC(GBE_MAC),.MIIM_MODULE(MIIM_MODULE),.CLASSIC_TSMAC(CLASSIC_TSMAC),.RGMII(RGMII))U_scoreboard (
    .i_tx_edata_size    (o_tx_edata_size     ),                           
    .i_tx_gdata_size    (o_tx_gdata_size     ),                         
    .i_rx_edata_size    (o_rx_edata_size     ),                           
    .i_rx_gdata_size    (o_rx_gdata_size     ),                        
    .i_mdio_gdata_size  (o_mdio_gdata_size   )                         
   );


  //1###################################################################################################
  // Initialize all the variables 
  //1###################################################################################################
  initial begin
    finish_on_error_b              = 0;
    errs_i       = 0;
    trans_i      = 0;
    //2-----------------------------------------------------------------------------------------------
    // Plus args is defined 
    //2-----------------------------------------------------------------------------------------------
    if ($test$plusargs("finish") == 1) begin
      finish_on_error_b         = 1;
    end
  end
  
  initial begin
    `ifdef RADIANT_ENV
    `else
      if ($test$plusargs("dump")) begin
        $dumpfile("verilog.vcd.fsdb");
        $dumpvars();
      end
    `endif
  end
  //1###################################################################################################
  // Initialize the testcase 
  //1###################################################################################################
  initial begin
    drive_reset(1,101);
    drive_reset(0,500);
    drive_reset(1,10);
    wait_clocks(100); 
    //2-----------------------------------------------------------------------------------------------
    // call the testcase 
    //2-----------------------------------------------------------------------------------------------
    test_runner();
    //2-----------------------------------------------------------------------------------------------
    // Call post_process 
    //2-----------------------------------------------------------------------------------------------
    repeat (3000) @(posedge clk_r);
    post_process();
    //2-----------------------------------------------------------------------------------------------
    // End simulation 
    //2-----------------------------------------------------------------------------------------------
    repeat (3000) @(posedge clk_r);
    $finish(1);
  end

  
  //1###################################################################################################
  // Start all the testbench threads 
  //1###################################################################################################
  initial begin
    //2-----------------------------------------------------------------------------------------------
    // Start all the threads 
    //2-----------------------------------------------------------------------------------------------
    fork
      //3---------------------------------------------------------------------------------------------
      // Start the transmit collection thread 
      //3---------------------------------------------------------------------------------------------
      begin
        U_output_monitor.collect_rx_frame();
      end
    join
  end

  //1-------------------------------------------------------------------------------------------------
  // gen_rx_data :Task to Generate the data
  //1-------------------------------------------------------------------------------------------------
  //          p_size_16b : Parameter for index
  //1-------------------------------------------------------------------------------------------------
  task gen_rx_data;
    input   [47:0]  p_dst_addr_48b;
    input   [47:0]  p_scr_adr_48b;
    input   [15:0]  p_size_16b;
    begin
      if (CLASSIC_TSMAC || MII_GMII) begin 
        if (wdata_8b[0] == 1) begin 
          while (!cpu_if_gbit_en_o) begin
            @(posedge rxmac_clk_i);
          end
          U_traffic_gen.gen_rx_data(p_dst_addr_48b,p_scr_adr_48b,p_size_16b);
        end else begin 
          U_traffic_gen.gen_rx_data(p_dst_addr_48b,p_scr_adr_48b,p_size_16b);
        end 
      end else if (GBE_MAC || RGMII || RMII) begin
        U_traffic_gen.gen_rx_data(p_dst_addr_48b,p_scr_adr_48b,p_size_16b);
      end else if (SGMII_TSMAC) begin 
        if (sgmii_spd_2b == 0) begin  
          while (!cpu_if_gbit_en_o) begin
            @(posedge txmac_clk_i);
          end
          U_traffic_gen.gen_rx_data(p_dst_addr_48b,p_scr_adr_48b,p_size_16b);
        end else begin 
          U_traffic_gen.gen_rx_data(p_dst_addr_48b,p_scr_adr_48b,p_size_16b);
        end
      end
    end
  endtask 

  //1-------------------------------------------------------------------------------------------------
  // gen_tx_data :Task to Generate the data
  //1-------------------------------------------------------------------------------------------------
  //          p_size_16b : Parameter for index
  //1-------------------------------------------------------------------------------------------------
  task gen_tx_data;
    input   [47:0]  p_dst_addr_48b;
    input   [47:0]  p_scr_adr_48b;
    input   [15:0]  p_size_16b;
    begin
      if (CLASSIC_TSMAC || MII_GMII) begin 
        if (wdata_8b[0] == 1) begin 
          while (!cpu_if_gbit_en_o) begin
            @(posedge txmac_clk_i);
          end
          U_traffic_gen.tx_fifo_data_write(p_dst_addr_48b,p_scr_adr_48b,p_size_16b);
        end else begin 
          U_traffic_gen.tx_fifo_data_write(p_dst_addr_48b,p_scr_adr_48b,p_size_16b);
        end 
      end else if (GBE_MAC || RGMII || RMII) begin
        U_traffic_gen.tx_fifo_data_write(p_dst_addr_48b,p_scr_adr_48b,p_size_16b);
      end else if (SGMII_TSMAC) begin 
        if (sgmii_spd_2b == 0) begin  
          while (!cpu_if_gbit_en_o) begin
            @(posedge txmac_clk_i);
          end
          U_traffic_gen.tx_fifo_data_write(p_dst_addr_48b,p_scr_adr_48b,p_size_16b);
        end else begin 
          U_traffic_gen.tx_fifo_data_write(p_dst_addr_48b,p_scr_adr_48b,p_size_16b);
        end
      end
    end
  endtask 

  //1-------------------------------------------------------------------------------------------------
  // gen_jumbo_frame :Task to Generate the jumbo frmae
  //1-------------------------------------------------------------------------------------------------
  //          p_des_addr_48b     : Parameter for scource address 
  //          p_scr_addr_48b     : Parameter for jumbo type value
  //          p_jum_type_16b     : Parameter for jumbo type value
  //          p_size_16b         : Parameter for index
  //1-------------------------------------------------------------------------------------------------
  task gen_jumbo_frame;
    input   [47:0]  p_des_addr_48b;
    input   [47:0]  p_scr_addr_48b;
    input   [15:0]  p_jum_type_16b;
    input   [15:0]  p_size_16b;
    begin
      U_traffic_gen.gen_tx_jumbo_frame(p_des_addr_48b,p_scr_addr_48b,p_jum_type_16b,p_size_16b);
    end
  endtask

  //1-------------------------------------------------------------------------------------------------
  // gen_ctrl_frame :Task to Generate the control frmae
  //1-------------------------------------------------------------------------------------------------
  //          p_scr_addr_48b     : Parameter for scource address 
  //          p_ctrl_type_16b    : Parameter for control type value
  //          p_pause_opcode_16b : Parameter for pause opcode
  //          p_pause_quanta_16b : Parameter for pause quanta value
  //          p_size_16b         : Parameter for index
  //1-------------------------------------------------------------------------------------------------
  task gen_ctrl_frame;
    input   [47:0]  p_scr_addr_48b;
    input   [15:0]  p_ctrl_type_16b;
    input   [15:0]  p_pause_opcode_16b;
    input   [15:0]  p_pause_quanta_16b;
    input   [15:0]  p_size_16b;
    begin
      U_traffic_gen.gen_tx_ctrl_frame(p_scr_addr_48b,p_ctrl_type_16b,p_pause_opcode_16b,p_pause_quanta_16b,p_size_16b);
    end
  endtask


  //1-------------------------------------------------------------------------------------------------
  // gen_vlan_frame :Task to Generate the vlan frmae
  //1-------------------------------------------------------------------------------------------------
  //          p_vlan_tag_16b  : Parameter for VLAN TAG information 
  //          p_vlan_type_16b : Parameter for VLAN TYPE information 
  //          p_size_16b      : Parameter for index
  //1-------------------------------------------------------------------------------------------------
  task gen_vlan_frame;
    input   [47:0]  p_scr_addr_48b;
    input   [47:0]  p_des_addr_48b;
    input   [15:0]  p_vlan_tag_16b;
    input   [15:0]  p_vlan_type_16b;
    input   [15:0]  p_size_16b;
    begin
      U_traffic_gen.gen_tx_vlan_frame(p_scr_addr_48b,p_des_addr_48b,p_vlan_tag_16b,p_vlan_type_16b,p_size_16b);
    end
  endtask

  //1-------------------------------------------------------------------------------------------------
  // gen_ahb_write :Task to Generate the data for AHB
  //1-------------------------------------------------------------------------------------------------
  //          p_addr_8b : Parameter for index
  //          p_data_8b : Parameter for index
  //1-------------------------------------------------------------------------------------------------
  task gen_ahb_write;
    input   [IF_DATA_WIDTH-1:0]    p_data_bv;
    input   [OFFSET_WIDTH -1:0]    p_addr_bv;
    begin
      U_ahb_master.ahb_write(p_data_bv,p_addr_bv);
    end
  endtask 

  //1-------------------------------------------------------------------------------------------------
  // get_ahb_read :Task to get the data from AHB
  //1-------------------------------------------------------------------------------------------------
  //          p_addr_8b : Parameter for index
  //1-------------------------------------------------------------------------------------------------
  task get_ahb_read;
    input   [OFFSET_WIDTH-1:0]  p_addr_bv;
    begin
      U_ahb_master.ahb_read(p_addr_bv);
    end
  endtask 
  
  //1-------------------------------------------------------------------------------------------------
  // gen_axi4l_write :Task to Generate the data for AXI4L
  //1-------------------------------------------------------------------------------------------------
  //          p_addr_8b : Parameter for index
  //          p_data_8b : Parameter for index
  //1-------------------------------------------------------------------------------------------------
  task gen_axi4l_write;
    input   [OFFSET_WIDTH -1:0]  p_addr_bv;
    input   [IF_DATA_WIDTH-1:0]  p_data_bv;
    begin
      U_axi4l_master.axi4l_write(p_addr_bv,p_data_bv);
    end
  endtask 

/*//development test case
  task gen_axi4l_write_add;
    begin
      U_axi4l_master.axi4l_write_add;
    end
  endtask
*/  
  //1-------------------------------------------------------------------------------------------------
  // get_axi4l_read :Task to get the data from AXI4L
  //1-------------------------------------------------------------------------------------------------
  //          p_addr_8b : Parameter for index
  //1-------------------------------------------------------------------------------------------------
  task gen_axi4l_read;
    input   [OFFSET_WIDTH-1:0]  p_addr_bv;
    begin
      U_axi4l_master.axi4l_read(p_addr_bv);
    end
  endtask 
  
  ////1-------------------------------------------------------------------------------------------------
  //// wait_clocks :Wait for some duration 
  ////1-------------------------------------------------------------------------------------------------
  ////           p_delay_32b :Number of clocks delay 
  ////1-------------------------------------------------------------------------------------------------
  task wait_clocks;
    input    [31:0]                     p_delay_32b                    ;
    begin
      //3---------------------------------------------------------------------------------------------
      // Wait for the delay 
      //3---------------------------------------------------------------------------------------------
      repeat (p_delay_32b) begin
        @ (posedge clk_r);
      end
    end
  endtask
  
  //1-------------------------------------------------------------------------------------------------
  // drive_reset :This method is used for driving reset pin of Timer 
  //1-------------------------------------------------------------------------------------------------
  //             p_value_b :Value to drive on bus 
  //           p_delay_32b :Number of clocks delay 
  //1-------------------------------------------------------------------------------------------------
  task drive_reset;
    input                               p_value_b                      ;
    input    [31:0]                     p_delay_32b                    ;
    begin
      //3---------------------------------------------------------------------------------------------
      // Wait for the delay 
      //3---------------------------------------------------------------------------------------------
      repeat (p_delay_32b) begin
        @ (posedge clk_r);
      end
      $write("INFO :: @%0dns %m() :: Driving reset pin to %0d\n",$time,p_value_b);
      reset_n_r                       <= p_value_b;
    end
  endtask
  

  //generate 
  //  if (INTERFACE == "APB") begin 
      //1-------------------------------------------------------------------------------------------------
      // apb_write :This method is used to perform write transfer 
      //1-------------------------------------------------------------------------------------------------
      //          p_paddr_bv  :APB register address 
      //          p_pwdata_bv :APB write data 
      //1-------------------------------------------------------------------------------------------------
      task apb_write;
        input    [OFFSET_WIDTH-1:0]   p_paddr_bv;
        input    [DATA_WIDTH-1:0]     p_pwdata_bv;
        begin 
          apb_paddr_8b         = p_paddr_bv;
          apb_pwdata_8b        = p_pwdata_bv;
          apb_pwr_b            = 1;
          apb_psel_b           = 1;
          @ (posedge clk_r);
          apb_pen_b            = 1;
          //3---------------------------------------------------------------------------------------------
          // Wait for some delay 
          //3---------------------------------------------------------------------------------------------
          repeat (4) begin
            @ (posedge clk_r);
          end
          while (lmmi_ready_o  == 1'b0) begin
            @(posedge clk_i);
          end
          apb_paddr_8b          = 8'b0;
          apb_pwdata_8b         = 8'b0;
          apb_pen_b             = 0;
          apb_psel_b            = 0;
          apb_pwr_b             = 0;
          @ (posedge clk_r);
          @ (posedge clk_r);
        end
      endtask
      
      //1-------------------------------------------------------------------------------------------------
      // apb_read :This method is used to perform read transfer 
      //1-------------------------------------------------------------------------------------------------
      //            p_paddr_bv :APB register address 
      //1-------------------------------------------------------------------------------------------------
      task apb_read;
        input    [DATA_WIDTH-1:0]   p_paddr_8b;
        begin
          apb_paddr_8b       = p_paddr_8b;
          apb_pwr_b          = 0;
          apb_pen_b          = 1;
          apb_psel_b         = 1;
          //3---------------------------------------------------------------------------------------------
          // Wait for some delay 
          //3---------------------------------------------------------------------------------------------
          repeat (4) begin
            @ (posedge clk_r);
          end
          apb_paddr_8b    = 8'b0;
          apb_pen_b       = 0;
          apb_psel_b      = 0;
        end
      endtask
  //  end else if (INTERFACE == "LMMI") begin 
      //1-------------------------------------------------------------------------------------------------
      // lmmi_write :This method is used to perform write transfer using LMMI
      // interface
      //1-------------------------------------------------------------------------------------------------
      //          p_paddr_bv  :LMMI register address 
      //          p_pwdata_bv :LMMI write data 
      //1-------------------------------------------------------------------------------------------------
      task lmmi_write;
        input    [OFFSET_WIDTH-1:0]   p_paddr_bv;
        input    [DATA_WIDTH-1:0]     p_pwdata_bv;
        begin 
          #1;
          lmmi_req_b     = 1'b1;
          lmmi_wr_rdn_b  = 1'b1;
          lmmi_wdata_8b  = p_pwdata_bv;
          lmmi_offset_8b = p_paddr_bv;
          @(posedge clk_i);
          //3---------------------------------------------------------------------------------------------
          // Wait for some delay 
          //3---------------------------------------------------------------------------------------------
          while (lmmi_ready_o  == 1'b0) begin
            @(posedge clk_i);
          end
          $display("Write to register: Address %d Data %d %t", p_paddr_bv, p_pwdata_bv, $time) ;
          #1;
          lmmi_req_b = 1'b0;
        end
      endtask
      //1-------------------------------------------------------------------------------------------------
      // lmmi_read :This method is used to perform read transfer using LMMI
      // Interface
      //1-------------------------------------------------------------------------------------------------
      //            p_paddr_bv :LMMI register address 
      //1-------------------------------------------------------------------------------------------------
      task lmmi_read;
        input    [DATA_WIDTH-1:0]   p_paddr_bv;
        begin
          lmmi_req_b     = 1'b1;
          lmmi_wr_rdn_b  = 1'b0;
          lmmi_offset_8b = p_paddr_bv;
          @(posedge clk_i);
          while (lmmi_ready_o  == 1'b0) begin
            @(posedge clk_i);
          end
          lmmi_req_b  = 1'b0;
          $display("Read From register: Address %d %t",p_paddr_bv, $time) ;
          #1;
        end 
      endtask
    //end 
  //endgenerate 

 initial begin
      $write("\n");
      $write("+-----------------------------------------------------------------------------+\n");
      $write("| PARAMETER                               | VALUE                             |\n");
      $write("+-----------------------------------------------------------------------------+\n");
      if(INTERFACE == "AHBL") begin
        $write("| INTERFACE                               | AHBL                              |\n");
      end 
	  else if (INTERFACE == "APB")begin
        $write("| INTERFACE                               | APB                               |\n");
      end
	  else if (INTERFACE == "AXI4L")begin
        $write("| INTERFACE                               | AXI4L                             |\n");
      end
      $write("| SGMII_TSMAC                             | %1d                                 |\n",SGMII_TSMAC);
      $write("| STANDARD MII/GMII                       | %1d                                 |\n",MII_GMII);
      $write("| CLASSIC_TSMAC                           | %1d                                 |\n",CLASSIC_TSMAC);
      $write("| GBE_MAC                                 | %1d                                 |\n",GBE_MAC);
      $write("| RGMII                                   | %1d                                 |\n",RGMII);
      $write("| RMII                                    | %1d                                 |\n",RMII);
      $write("| MIIM_MODULE                             | %1d                                 |\n",MIIM_MODULE);
      $write("+-----------------------------------------------------------------------------+\n");
  end

  // pkt_mon_inst
  if (SGMII_TSMAC == 1)
  begin
    //
    lscc_pkt_mon_sgts lscc_pkt_mon_inst(
      .received_crc      (received_crc     ),
      .expected_crc      (expected_crc     ),
      .crc_output_valid  (crc_output_valid ),
      .reset_n           (reset_n_i        ),
      .gbit_en           (1'b1             ),
      .tx_clk_en         (txmac_clk_en_i   ),
      .tx_clk            (txmac_clk_i      ),
      .tx_en             (tx_en_o          ),
      .tx_er             (tx_er_o          ),
      .txd               (txd_o            )
    );
  end else if (CLASSIC_TSMAC == 1)
  begin
    //
    lscc_pkt_mon_gbcl lscc_pkt_mon_inst(
      .received_crc      (received_crc     ),
      .expected_crc      (expected_crc     ),
      .crc_output_valid  (crc_output_valid ),
      .reset_n           (reset_n_i        ),
      .gbit_en           (cpu_if_gbit_en_o ),
      .tx_clk            (tx_clk_w         ),
      .tx_en             (tx_en            ),//tx_en_d_x
      .tx_er             (tx_er            ),
      .txd               (txd              ) // txd_1g
    );
  end else if (RGMII == 1)
  begin
    //
    lscc_pkt_mon_gbcl lscc_pkt_mon_inst(
      .received_crc      (received_crc     ),
      .expected_crc      (expected_crc     ),
      .crc_output_valid  (crc_output_valid ),
      .reset_n           (reset_n_i        ),
      .gbit_en           (cpu_if_gbit_en_o ),
      .tx_clk            (txmac_clk_i      ),
      .tx_en             (o_tx_en          ),
      .tx_er             (o_tx_err         ),
      .txd               (o_tx_data_8b     )
    );
  end else // GBE_MAC == 1
  begin
    lscc_pkt_mon_gbcl lscc_pkt_mon_inst(
      .received_crc      (received_crc     ),
      .expected_crc      (expected_crc     ),
      .crc_output_valid  (crc_output_valid ),
      .reset_n           (reset_n_i        ),
      .gbit_en           (cpu_if_gbit_en_o ),
      .tx_clk            (txmac_clk_i      ),
      .tx_en             (tx_en_o          ),
      .tx_er             (tx_er_o          ),
      .txd               (txd_o            )
    );
  end
  

  ////1###################################################################################################
  //// Include all testcases here 
  ////1###################################################################################################
  `ifndef RADIANT_ENV
     `include "test_list.v"
  `endif
  `ifdef RADIANT_ENV
     //1###########################################################################################################
     //test_basic :This test cases is used to transmit data to the TSE-MAC transmitter for GBE_MAC,CLASSIC_TSMAC
     //and RGMII
     //1###########################################################################################################
     task test_basic;
       integer m_i_i;
       reg[15:0]  data_16b;
       reg[47:0]  des_addr_48b;
       reg[47:0]  scr_addr_48b;
       reg[10:0]   wr_addr_8b;
       reg[31:0]   wr_data_8b;
     
      begin
        for (m_i_i=0;m_i_i < num_tran_ui ; m_i_i = m_i_i + 1) begin
         fork
           begin
             if (INTERFACE == "APB") begin
               //1#########################################################################################
               // DUT Register updation for the Transmitter 
               //1#########################################################################################
                wait_clks(1000);
                scr_addr_48b = 48'hACDE48000080;
                des_addr_48b = 48'hACDE48000080;
                wr_addr_8b = 11'h04;
                wr_data_8b = 32'h01;
                apb_write(wr_addr_8b,wr_data_8b);
                wr_addr_8b = 11'h00;
                wr_data_8b = 32'h1D;
                wdata_8b   = wr_data_8b;
                apb_write(wr_addr_8b,wr_data_8b);
                //1#########################################################################################
                //Receive Frame generation
                //1#########################################################################################
                data_16b = 200;
                gen_tx_data(scr_addr_48b,des_addr_48b,data_16b);
                gen_rx_data(des_addr_48b,scr_addr_48b,data_16b);
			 
			 end else if (INTERFACE == "AXI4L")begin
			  wait_clks(1000); 
                scr_addr_48b = 48'hACDE48000080;
                des_addr_48b = 48'hACDE48000080;
				//gen_axi4l_write_add;
                wr_addr_8b = 11'h04; //prms
                wr_data_8b = 32'h01;
                gen_axi4l_write(wr_addr_8b,wr_data_8b);
                wr_addr_8b = 11'h00;
                wr_data_8b = 32'h1D;
                wdata_8b   = wr_data_8b;
                gen_axi4l_write(wr_addr_8b,wr_data_8b);
                //1#########################################################################################
                //Receive Frame generation
                //1#########################################################################################
                data_16b = 200;
                gen_tx_data(scr_addr_48b,des_addr_48b,data_16b);
                gen_rx_data(des_addr_48b,scr_addr_48b,data_16b);
             end else begin
               //1#########################################################################################
               // DUT Register updation for the Transmitter 
               //1#########################################################################################
                wait_clks(1000); 
                scr_addr_48b = $random();
                des_addr_48b = $random();
                wr_addr_8b = 11'h04;
                wr_data_8b = 32'h01;
                gen_ahb_write(wr_addr_8b,wr_data_8b);
                wr_addr_8b = 11'h00;
                wr_data_8b = 32'h1D;
                wdata_8b   = wr_data_8b;
				gen_ahb_write(wr_addr_8b,wr_data_8b);
               //1#########################################################################################
               //Frame generation
               //1#########################################################################################
                data_16b = $urandom_range(1500,64);
                gen_tx_data(des_addr_48b,scr_addr_48b,data_16b);
                gen_rx_data(des_addr_48b,scr_addr_48b,data_16b);
             end
           end
         join
         wait_done();
         wait_clks(200); 
        end
      end 
     
     endtask

     //1#####################################################################################################
     //test_tse_mac_rx_untagged_data_frame :This test cases is used to transmit data to the TSE-MAC Receiver
     //GBE_MAC,CLASSIC_TSMAC and RGMII
     //1#####################################################################################################
     task test_tse_mac_rx_untagged_data_frame;
       integer m_i_i;
       reg[15:0]  data_16b;
       reg[7:0]   wr_addr_8b;
       reg[7:0]   wr_data_8b;
       reg[47:0]  des_addr_48b;
       reg[47:0]  scr_addr_48b;
     
      begin
        for (m_i_i=0;m_i_i < num_tran_ui ; m_i_i = m_i_i + 1) begin
     
         fork
           //3---------------------------------------------------------------------------------------------
           // First mac transmit frames 
           //3---------------------------------------------------------------------------------------------
           begin
     
            //1#########################################################################################
            //DUT Register Updation for the Receiver 
            //1#########################################################################################
            scr_addr_48b = 48'h005056C00000;
            des_addr_48b = 48'h000012153524;
            wr_addr_8b = 11'h04;
            wr_data_8b = 32'h01;
            gen_ahb_write(wr_addr_8b,wr_data_8b);
     
            wait_clocks(10); 
     
            wr_addr_8b = 11'h00;
            wr_data_8b = 32'h05;
            wdata_8b   = wr_data_8b;
            gen_ahb_write(wr_addr_8b,wr_data_8b);
     
            //1#########################################################################################
            //Frame generation
            //1#########################################################################################
             data_16b = $urandom_range(1500,64);
             gen_rx_data(des_addr_48b,scr_addr_48b,data_16b);
             ntran_ui = ntran_ui + 1;
           end
         join
         wait_done();
         wait_clocks(200);
     
        end
      end 
     
     endtask

     //1##########################################################################################################
     //test_tse_mac_10m_100m_receive_frame_rx_en :This test cases is used to transmit data to the TSE-MAC Receiver
     //for CLASSIC_TSMAC 100M mode
     //1##########################################################################################################
     task test_tse_mac_10m_100m_receive_frame_rx_en;
       integer m_i_i;
       reg[15:0]  data_16b;
       reg[7:0]  wr_addr_8b;
       reg[7:0]  wr_data_8b;
       reg[47:0]  des_addr_48b;
       reg[47:0]  scr_addr_48b;
     
     
      begin
        for (m_i_i=0;m_i_i < num_tran_ui ; m_i_i = m_i_i + 1) begin
     
         fork
           //3---------------------------------------------------------------------------------------------
           // First mac transmit frames 
           //3---------------------------------------------------------------------------------------------
           begin
     
            //1#########################################################################################
            //DUT Register Updation for the Receiver 
            //1#########################################################################################
            scr_addr_48b = 48'h005056C00000;
            des_addr_48b = 48'h000012153524;
			
            wr_addr_8b = 11'h04;
            wr_data_8b = 32'h01;
            gen_ahb_write(wr_addr_8b,wr_data_8b);
			
            wait_clocks(10); 
     
            wr_addr_8b = 11'h00;
            wr_data_8b = 32'h04;//Gbit_en(b0 = 0),RX_EN(b2 = 1)
            gen_ahb_write(wr_addr_8b,wr_data_8b);
     
            //1#########################################################################################
            //Frame generation
            //1#########################################################################################
             data_16b = $urandom_range(1500,64);
             gen_rx_data(des_addr_48b,scr_addr_48b,data_16b);
             ntran_ui = ntran_ui + 1;
           end
         join
         wait_done();
         wait_clocks(200);
     
        end
      end 
     
     endtask

     //1##########################################################################################################
     //test_tse_mac_10m_100m_receive_frame_rx_en :This test cases is used to transmit data to the TSE-MAC  
     //transmitter for CLASSIC_TSMAC 100M mode
     //1##########################################################################################################
     task test_tse_mac_classic_10_100m_untagged_data_frame;
       integer m_i_i;
       reg[15:0]  data_16b;
       reg[7:0]   wr_addr_8b;
       reg[7:0]   wr_data_8b;
       reg[47:0]  des_addr_48b;
       reg[47:0]  scr_addr_48b;
     
      begin
        for (m_i_i=0;m_i_i < num_tran_ui ; m_i_i = m_i_i + 1) begin
     
         fork
           begin
            //1#########################################################################################
            // DUT Register updation for the Transmitter 
            //1#########################################################################################
             wait_clks(1000); 
             scr_addr_48b = 48'hACDE48000080;
             des_addr_48b = 48'hACDE48000080;
             wr_addr_8b = 11'h00;
             wr_data_8b = 32'h08;
             gen_ahb_write(wr_addr_8b,wr_data_8b);
             wr_addr_8b = 11'h04;
             wr_data_8b = 32'h0020;//Half_duplex_en(b5 = 1)
             gen_ahb_write(wr_addr_8b,wr_data_8b);
     
            //1#########################################################################################
            //Frame generation
            //1#########################################################################################
             data_16b = 200;
             gen_tx_data(scr_addr_48b,des_addr_48b,data_16b);
           end
         join
         wait_done();
         wait_clocks(200);
        end
      end 
     endtask

     //1##########################################################################################################
     //test_tse_mac_sgmii_1g_easy_connect_with_gmii :This test cases is used to transmit data to the TSE-MAC  
     //transmitter for SGMII_TSMAC 1G mode
     //1##########################################################################################################
     task test_tse_mac_sgmii_1g_easy_connect_with_gmii;
       integer m_i_i;
       reg[15:0]  data_16b;
       reg[47:0]  des_addr_48b;
       reg[47:0]  scr_addr_48b;
       reg[7:0]   wr_addr_8b;
       reg[7:0]   wr_data_8b;
     
       begin
         for (m_i_i=0;m_i_i < num_tran_ui ; m_i_i = m_i_i + 1) begin
          fork
            begin
             //1#########################################################################################
             // DUT Register updation for the Transmitter 
             //1#########################################################################################
              wait_clks(1000); 
              scr_addr_48b = $random();
              des_addr_48b = $random();
              wr_addr_8b = 11'h04;
              wr_data_8b = 32'h01;
              gen_ahb_write(wr_addr_8b,wr_data_8b);
              wr_addr_8b = 11'h00;
              wr_data_8b = 32'h0D;
              wdata_8b   = wr_data_8b;
              gen_ahb_write(wr_addr_8b,wr_data_8b);
             //1#########################################################################################
             //Frame generation
             //1#########################################################################################
              data_16b = $urandom_range(1500,64);
              gen_tx_data(des_addr_48b,scr_addr_48b,data_16b);
              gen_rx_data(des_addr_48b,scr_addr_48b,data_16b);
            end
          join
          wait_done();
          wait_clocks(50);
         end
       end 
     endtask

     //1##########################################################################################################
     //test_tse_mac_sgmii_1g_easy_connect_with_gmii :This test cases is used to transmit data to the TSE-MAC  
     //transmitter for SGMII_TSMAC 100M mode
     //1##########################################################################################################
     task test_tse_mac_sgmii_100m_easy_connect_with_gmii;
       integer m_i_i;
       reg[15:0]  data_16b;
       reg[47:0]  des_addr_48b;
       reg[47:0]  scr_addr_48b;
       reg[7:0]   wr_addr_8b;
       reg[7:0]   wr_data_8b;
     
       begin
         for (m_i_i=0;m_i_i < num_tran_ui ; m_i_i = m_i_i + 1) begin
     
          fork
            begin
             //1#########################################################################################
             // DUT Register updation for the Transmitter 
             //1#########################################################################################
              wait_clks(1000); 
              scr_addr_48b = 48'h123885378964;
              des_addr_48b = 48'h744329753429;
              wr_addr_8b = 11'h04;
              wr_data_8b = 32'h01;
              gen_ahb_write(wr_addr_8b,wr_data_8b);
              wr_addr_8b = 11'h00;
              wr_data_8b = 32'h0C;
              wdata_8b   = wr_data_8b;
              gen_ahb_write(wr_addr_8b,wr_data_8b);
             //1#########################################################################################
             //Frame generation
             //1#########################################################################################
              sgmii_spd_2b = 1;
              data_16b = $urandom_range(1500,64);
              gen_tx_data(des_addr_48b,scr_addr_48b,data_16b);
              gen_rx_data(des_addr_48b,scr_addr_48b,data_16b);
            end
          join
          wait_done();
          wait_clocks(200);
         end
       end 
     endtask

     //1##########################################################################################################
     //test_tse_mac_sgmii_1g_easy_connect_with_gmii :This test cases is used to transmit data to the TSE-MAC  
     //transmitter for SGMII_TSMAC 10M mode
     //1##########################################################################################################
     task test_tse_mac_sgmii_10m_easy_connect_with_gmii;
       integer m_i_i;
       reg[15:0]  data_16b;
       reg[47:0]  des_addr_48b;
       reg[47:0]  scr_addr_48b;
       reg[7:0]   wr_addr_8b;
       reg[7:0]   wr_data_8b;
     
      begin
        for (m_i_i=0;m_i_i < num_tran_ui ; m_i_i = m_i_i + 1) begin
     
         fork
           begin
            //1#########################################################################################
            // DUT Register updation for the Transmitter 
            //1#########################################################################################
             wait_clks(1000); 
             scr_addr_48b = 48'hACDE48000080;
             des_addr_48b = 48'hACDE48000080;
             wr_addr_8b = 11'h04;
             wr_data_8b = 32'h01;
             gen_ahb_write(wr_addr_8b,wr_data_8b);
             wr_addr_8b = 11'h00;
             wr_data_8b = 32'h0C;
             wdata_8b   = wr_data_8b;
             gen_ahb_write(wr_addr_8b,wr_data_8b);
            //1#########################################################################################
            //Frame generation
            //1#########################################################################################
             sgmii_spd_2b = 2;
             data_16b = $urandom_range(1500,64);
             gen_tx_data(des_addr_48b,scr_addr_48b,data_16b);
             gen_rx_data(des_addr_48b,scr_addr_48b,data_16b);
           end
         join
         wait_done();
         wait_clocks(200);
        end
      end 
     endtask

     //1##########################################################################################################
     //test_tse_mac_1g_management_write_frame:This test cases is used to management write data 
     //1##########################################################################################################
     task test_tse_mac_1g_management_write_frame;
       integer m_i_i;
       //int unsigned num_tran_ui;
       reg[15:0]  data_16b;
       reg[47:0]  des_addr_48b;
       reg[47:0]  scr_addr_48b;
       reg[7:0]   wr_addr_8b;
       reg[7:0]   wr_data_8b;
       begin
        for (m_i_i=0;m_i_i < num_tran_ui ; m_i_i = m_i_i + 1) begin
     
         fork
           begin
            //1#########################################################################################
            // DUT Register updation for the Transmitter 
            //1#########################################################################################
             wr_addr_8b = 11'h024;                    // GMII Management Access Data Register
             wr_data_8b = $urandom_range(31,0);       // GMII_dat
             gen_ahb_write(wr_addr_8b,wr_data_8b);
             wait_clocks(60);
     
             wr_addr_8b       = 11'h020;               // GMII Management Register Access Control Register - bits[7:0]
             wr_data_8b[4:0]  = $urandom_range(31,0);  // Reg_add - b[4:0]
             wr_data_8b[7:5]  = 0;                     // Rsvd b[7:5]
             wr_data_8b[12:8] = 1;                     // Phy_add - bits [12:8]
             wr_data_8b[13]   = 1;                     // RW_phyreg - b[13] = 1(write)
             gen_ahb_write(wr_addr_8b,wr_data_8b); 
     
             wait_clks(10); 
             wr_addr_8b = 11'h00;//Mode Register
             wr_data_8b = 32'h05;//Gbit_en (b0 = 1),Tx_en (b3 = 1)
             gen_ahb_write(wr_addr_8b,wr_data_8b);
     
            //1#########################################################################################
            //Frame generation
            //1#########################################################################################
             scr_addr_48b    = $random;
             des_addr_48b    = $random;
             des_addr_48b[0] = 0;
             data_16b = 200;
             //gen_tx_data(des_addr_48b,scr_addr_48b,data_16b);
           end
         join
         wait_done();
         wait_clocks(200);
        end
      end 
     endtask

     //1##########################################################################################################
     //test_tse_mac_hci_apb:This test cases is used to write and read the register using APB
     //1##########################################################################################################
     task test_tse_mac_hci_apb;
       integer   m_i_i;
       reg[15:0]  data_16b;
       reg[47:0]  des_addr_48b;
       reg[47:0]  scr_addr_48b;
       reg[7:0]  wr_addr_8b;
       reg[7:0]  wr_data_8b;
       begin
        for (m_i_i=0;m_i_i < num_tran_ui ; m_i_i = m_i_i + 1) begin
     
         fork
           begin
            //1#########################################################################################
            // DUT Register updation for the Transmitter 
            //1#########################################################################################
             wait_clks(1000); 
             scr_addr_48b = 48'hACDE48000080;
             des_addr_48b = 48'hACDE48000080;
             wr_addr_8b = 11'h00;
             wr_data_8b = 32'h08;
             apb_write(wr_addr_8b,wr_data_8b);
             wait_clocks(10);
             apb_read(wr_addr_8b);
             apb_write(wr_addr_8b,wr_data_8b);
             //1#########################################################################################
             //Receive Frame generation
             //1#########################################################################################
             data_16b = 200;
             gen_tx_data(scr_addr_48b,des_addr_48b,data_16b);
           end
         join
         wait_done();
         wait_clocks(200);
        end
      end 
     endtask
  `endif

  //1-------------------------------------------------------------------------------------------------
  // post_process :This task does the post processing 
  //1-------------------------------------------------------------------------------------------------
  //             parameter :No parameter 
  //1-------------------------------------------------------------------------------------------------
  task post_process;
    begin
      $write("MSG :: @%0dns %m() :: #####################################################################\n",
        $time);
      $write("MSG :: @%0dns %m() ::               Errors   detected in CHECKER %4d\n",$time,errs_i);
      $write("MSG :: @%0dns %m() ::               Number of Transactions       %4d\n",$time,trans_i);
      $write("MSG :: @%0dns %m() :: #####################################################################\n",
        $time);
      //3---------------------------------------------------------------------------------------------
      // Declare pass of fail based on sim status 
      //3---------------------------------------------------------------------------------------------
      if (errs_i == 0 && trans_i != 0) begin
        $write("MSG :: @%0dns %m() ::                       SIMULATION PASSED\n",$time);
      //3---------------------------------------------------------------------------------------------
      // If sim error is set, then there was simulation error 
      //3---------------------------------------------------------------------------------------------
      end else begin
        $write("MSG :: @%0dns %m() ::                       SIMULATION FAILED\n",$time);
      end
      $write("MSG :: @%0dns %m() :: #####################################################################\n",
        $time);
    end
  endtask
  
  ////1-------------------------------------------------------------------------------------------------
  //// test_runner :This task runs testcase 
  ////1-------------------------------------------------------------------------------------------------
  ////             parameter :No parameter 
  ////1-------------------------------------------------------------------------------------------------
  task test_runner;
    begin
      //3---------------------------------------------------------------------------------------------
      // Check if seed was passed 
      //3---------------------------------------------------------------------------------------------
      if ($value$plusargs("seed=%d", seed_i)) begin
        $write("MSG :: @%0dns %m() :: Setting random seed to user passed %0d\n",$time,seed_i);
      //3---------------------------------------------------------------------------------------------
      // Use seed as 1 
      //3---------------------------------------------------------------------------------------------
      end else begin
        seed_i                         = 1;
        $write("MSG :: @%0dns %m() :: Setting random seed to default %0d\n",$time,seed_i);
      end
      //3---------------------------------------------------------------------------------------------
      // Check if cmds was passed 
      //3---------------------------------------------------------------------------------------------
      if ($value$plusargs("cmds=%d", num_tran_ui)) begin
        //4-------------------------------------------------------------------------------------------
        // Print message only when num_tran_ui is changed 
        //4-------------------------------------------------------------------------------------------
        if (num_tran_ui > 0) begin
          $write("MSG :: @%0dns %m() :: Changing num_tran_ui to %0d\n",$time,num_tran_ui);
        //4-------------------------------------------------------------------------------------------
        // Make sure user did not pass -1 or 0 
        //4-------------------------------------------------------------------------------------------
        end else begin
          num_tran_ui                    = 100;
        end
      end else begin
        num_tran_ui                      = 1;
        $write("MSG :: @%0dns %m() :: Setting num_tran_ui to default %0d\n",$time,num_tran_ui);
      end
      //3---------------------------------------------------------------------------------------------
      // Check if finish was passed 
      //3---------------------------------------------------------------------------------------------
      if ($value$plusargs("finish=%b", finish_on_error_b)) begin
      end

      //3---------------------------------------------------------------------------------------------
      // Check if testcase was passed 
      //3---------------------------------------------------------------------------------------------
      if ($value$plusargs("test=%s", test_name_s)) begin
        `ifdef RADIANT_ENV
           $write("MSG :: @%0dns %m() :: Running testcase %0s\n",$time,test_name_s);
           if (test_name_s == "test_basic") begin
             test_basic();
           end else if (test_name_s == "test_tse_mac_rx_untagged_data_frame") begin
             test_tse_mac_rx_untagged_data_frame();
           end else if (test_name_s == "test_tse_mac_classic_10_100m_untagged_data_frame") begin
             test_tse_mac_classic_10_100m_untagged_data_frame();
           end else if (test_name_s == "test_tse_mac_10m_100m_receive_frame_rx_en") begin
             test_tse_mac_10m_100m_receive_frame_rx_en();
           end else if (test_name_s == "test_tse_mac_sgmii_1g_easy_connect_with_gmii") begin
             test_tse_mac_sgmii_1g_easy_connect_with_gmii();
           end else if (test_name_s == "test_tse_mac_sgmii_100m_easy_connect_with_gmii") begin
             test_tse_mac_sgmii_100m_easy_connect_with_gmii();
           end else if (test_name_s == "test_tse_mac_sgmii_10m_easy_connect_with_gmii") begin
             test_tse_mac_sgmii_10m_easy_connect_with_gmii();
           end else if (test_name_s == "test_tse_mac_1g_management_write_frame") begin
             test_tse_mac_1g_management_write_frame();
           end else if (test_name_s == "test_tse_mac_hci_apb") begin
             test_tse_mac_hci_apb();
           end else begin
             $write("MSG :: @%0dns %m() :: Not a valid testcase name passed with +test option ,so calling basic testcase-test_basic ...................\n",$time);
             test_basic();
           end 
        `else
           test_processor();
        `endif
      end else begin
        $write("MSG :: @%0dns %m() :: No testcase name passed with +test option,so calling basic testcase-test_basic...................\n",
          $time);
          test_basic();
		  
		  if(SGMII_TSMAC == 1) begin
		  $write("MSG :: @%0dns %m() :: SGMII EASY CONNECT MODE, calling SGMII EASY CONNECT test case...................\n",
          $time);
		  $write("MSG :: @%0dns %m() :: calling 100M test case...................\n",
          $time);
		  test_tse_mac_sgmii_100m_easy_connect_with_gmii();
		  end
      end 


    end
  endtask

  `ifdef RADIANT_ENV
  `else
  //1-------------------------------------------------------------------------------------------------
  // test_processor : This task is to execute all the testcases
  //1-------------------------------------------------------------------------------------------------
  task test_processor;
    begin 

      //3---------------------------------------------------------------------------------------------
      // Check if testcase was passed 
      //3---------------------------------------------------------------------------------------------
      if ($value$plusargs("test=%s", test_name_s)) begin
        $write("MSG :: @%0dns %m() :: Running testcase %0s\n",$time,test_name_s);
        //4-------------------------------------------------------------------------------------------
        // Run testcase test_basic 
        //4-------------------------------------------------------------------------------------------
        if (test_name_s == "test_basic") begin
          test_basic();
        //4-------------------------------------------------------------------------------------------
        // Run testcase test_tse_mac_gmac_untagged_data_frame 
        //4-------------------------------------------------------------------------------------------
        end else if (test_name_s == "test_tse_mac_gmac_untagged_data_frame") begin
          test_tse_mac_gmac_untagged_data_frame();
        //4-------------------------------------------------------------------------------------------
        // Run testcase test_tse_mac_classic_1g_untagged_data_frame 
        //4-------------------------------------------------------------------------------------------
        end else if (test_name_s == "test_tse_mac_classic_1g_untagged_data_frame") begin
          test_tse_mac_classic_1g_untagged_data_frame();
        //4-------------------------------------------------------------------------------------------
        // Run testcase test_tse_mac_rx_untagged_data_frame 
        //4-------------------------------------------------------------------------------------------
        end else if (test_name_s == "test_tse_mac_rx_untagged_data_frame") begin
          test_tse_mac_rx_untagged_data_frame();
        //4-------------------------------------------------------------------------------------------
        // Run testcase test_tse_mac_classic_10_100m_untagged_data_frame 
        //4-------------------------------------------------------------------------------------------
        end else if (test_name_s == "test_tse_mac_classic_10_100m_untagged_data_frame") begin
          test_tse_mac_classic_10_100m_untagged_data_frame();
        //4-------------------------------------------------------------------------------------------
        // Run testcase test_tse_mac_10m_100m_receive_frame_rx_en 
        //4-------------------------------------------------------------------------------------------
        end else if (test_name_s == "test_tse_mac_10m_100m_receive_frame_rx_en") begin
          test_tse_mac_10m_100m_receive_frame_rx_en();
        //4-------------------------------------------------------------------------------------------
        // Run testcase test_tse_mac_sgmii_1g_easy_connect_with_gmii
        //4-------------------------------------------------------------------------------------------
        end else if (test_name_s == "test_tse_mac_sgmii_1g_easy_connect_with_gmii") begin
          test_tse_mac_sgmii_1g_easy_connect_with_gmii();
        //4-------------------------------------------------------------------------------------------
        // Run testcase test_tse_mac_sgmii_100m_easy_connect_with_gmii
        //4-------------------------------------------------------------------------------------------
        end else if (test_name_s == "test_tse_mac_sgmii_100m_easy_connect_with_gmii") begin
          test_tse_mac_sgmii_100m_easy_connect_with_gmii();
        //4-------------------------------------------------------------------------------------------
        // Run testcase test_tse_mac_sgmii_10m_easy_connect_with_gmii
        //4-------------------------------------------------------------------------------------------
        end else if (test_name_s == "test_tse_mac_sgmii_10m_easy_connect_with_gmii") begin
          test_tse_mac_sgmii_10m_easy_connect_with_gmii();
        //4-------------------------------------------------------------------------------------------
        // Run testcase test_tse_mac_hci_apb 
        //4-------------------------------------------------------------------------------------------
        end else if (test_name_s == "test_tse_mac_hci_apb") begin
          test_tse_mac_hci_apb();
        //4-------------------------------------------------------------------------------------------
        // Run testcase test_tse_mac_1g_management_write_frame 
        //4-------------------------------------------------------------------------------------------
        end else if (test_name_s == "test_tse_mac_1g_management_write_frame") begin
          test_tse_mac_1g_management_write_frame();
        //4-------------------------------------------------------------------------------------------
        // Run testcase test_tse_mac_1g_management_read_frame 
        //4-------------------------------------------------------------------------------------------
        //end else if (test_name_s == "test_tse_mac_1g_management_read_frame") begin
        //  test_tse_mac_1g_management_read_frame();
        //4-------------------------------------------------------------------------------------------
        // If not valid testcase name is passed, then it is error 
        //4-------------------------------------------------------------------------------------------
        end else begin
          $write("MSG :: @%0dns %m() :: No valid testcase name passed with +test option...................\n",
            $time);
          $finish(1);
        end
      //3---------------------------------------------------------------------------------------------
      // If testcase name is not passed, then it is error 
      //3---------------------------------------------------------------------------------------------
      end else begin
        $write("MSG :: @%0dns %m() :: No testcase name passed with +test option...................\n",
          $time);
        $finish(1);
      end
    end
  endtask
`endif

  //1-------------------------------------------------------------------------------------------------
  // wait_clks :Wait for N clocks 
  //1-------------------------------------------------------------------------------------------------
  //              p_clks_i :Clocks to wait for 
  //1-------------------------------------------------------------------------------------------------
  task wait_clks (
    input  integer    p_clks_i                               
  );
    //2-----------------------------------------------------------------------------------------------
    // Wait for passed clock cycles 
    //2-----------------------------------------------------------------------------------------------
    repeat (p_clks_i) begin
      @ (posedge clk_r);
    end
  endtask

  //1-------------------------------------------------------------------------------------------------
  // wait_done :Wait for the completetion of current transcation 
  //1-------------------------------------------------------------------------------------------------
  //             parameter :No parameter 
  //1-------------------------------------------------------------------------------------------------
  task wait_done (
  );
    //2-----------------------------------------------------------------------------------------------
    // While loop to check if all BFM's are done 
    //2-----------------------------------------------------------------------------------------------
    while (U_traffic_gen.tx_done_b == 0) begin
      @ (posedge clk_r);
      timeout_cnt_i = timeout_cnt_i + 1;
      //3---------------------------------------------------------------------------------------------
      // Check if simulation is running for very long time 
      //3---------------------------------------------------------------------------------------------
      if (timeout_cnt_i >= 50000000) begin
        $write("wait_done () :: wait_done >> Timeout reached, TX 0 STATUS : [%0d]",U_traffic_gen.tx_done_b);
        $finish(1);
      end
    end
  endtask

  //1-------------------------------------------------------------------------------------------------
  // rx_wait_done :Wait for the completetion of current transcation 
  //1-------------------------------------------------------------------------------------------------
  //             parameter :No parameter 
  //1-------------------------------------------------------------------------------------------------
  task rx_wait_done (
  );
    //2-----------------------------------------------------------------------------------------------
    // While loop to check if all BFM's are done 
    //2-----------------------------------------------------------------------------------------------
    while (U_traffic_gen.rx_done_b == 0) begin
      @ (posedge clk_r);
      rx_timeout_cnt_i = rx_timeout_cnt_i + 1;
      //3---------------------------------------------------------------------------------------------
      // Check if simulation is running for very long time 
      //3---------------------------------------------------------------------------------------------
      if (rx_timeout_cnt_i >= 50000000) begin
        $write("rx_wait_done () :: rx_wait_done >> Timeout reached, TX 0 STATUS : [%0d]",U_traffic_gen.rx_done_b);
        $finish(1);
      end
    end
  endtask
  
endmodule
`endif
