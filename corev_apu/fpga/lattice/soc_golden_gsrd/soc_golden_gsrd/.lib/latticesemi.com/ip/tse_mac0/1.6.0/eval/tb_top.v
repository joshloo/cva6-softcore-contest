`timescale 1ns/1ps
`include "tb_apb_mst.v"
`include "tb_axis_mst.v"
`include "tb_data_checker.v"
`include "tse_mac_axi4l_master.v"
`include "tse_mac_ahb_master.v"
module tb_top();
`include "dut_params.v"
//--------------------------------------------------------------------------
//--- Local Parameters/Defines ---
//--------------------------------------------------------------------------
localparam CLKPERIOD         = 10;     
localparam CCLKPERIOD        = 10; 
localparam REFPERIOD         = 8;
localparam ADDR_WIDTH        = 32;
//localparam  DATA_WIDTH        = 8;
localparam WADDR_DEPTH       = 512;
localparam RADDR_DEPTH       = 512;
localparam REFCLK_MHZ        = (1/CCLKPERIOD)*1000;
localparam XGMIICLK_MHZ      = (1/REFPERIOD)*1000;
// -----------------------------------------------------------------------------
// Register Declarations
// -----------------------------------------------------------------------------
reg                           obs_valid_Q;
reg [DATA_WIDTH-1:0]          obs_data_Q;
reg                           reset_n;
reg                           sysbus_clk;
reg                           start;
wire                          reg_done;
reg                           mdc;
reg                           refclk;
// -----------------------------------------------------------------------------
// Wire Declarations
// -----------------------------------------------------------------------------
wire                          exp_mstr;
wire                          exp_slv;
wire                          exp_valid;
wire [DATA_WIDTH-1:0]         exp_data;
wire                          obs_mstr;
wire                          obs_slv;
wire                          obs_valid;
wire [DATA_WIDTH-1:0]         obs_data; 
wire [63:0]                   tx_axis_tdata;
wire                          tx_axis_tvalid;
wire                          tx_axis_tlast;
wire [7:0]                    tx_axis_tid;
wire [11:0]                   tx_axis_tdest;
wire [7:0]                    tx_axis_tstrb;
wire [7:0]                    tx_axis_tkeep;
wire                          tx_axis_tuser;
wire                          tx_axis_tready;
wire [63:0]                   axis_rx_tdata;
wire                          axis_rx_tvalid;
wire                          axis_rx_tlast;
wire [7:0]                    axis_rx_tkeep;
wire                          axis_rx_tuser;
wire                          tb_error_w;
wire                          tb_done_w;
wire                          sys_ready;
wire                          gsr_out;
wire                          apb_done;
wire                          an_link_ok;
wire                          ready;

//DUT ports
wire                          clk_i;
wire                          reset_n_i;
wire                          axis_rx_tvalid_o;
wire                          axis_rx_tready_i;
wire [DATA_WIDTH-1:0]         axis_rx_tdata_o;
wire                          axis_rx_tlast_o;
wire                          axis_tx_tvalid_i;
wire                          axis_tx_tready_o;
wire [7:0]                    axis_tx_tdata_i;
wire                          axis_tx_tlast_i;
wire                          txmac_clk_en_i;
wire                          rxmac_clk_en_i;     
wire                          mdc_i;  
wire                          mdi_i;         
wire                          mdo_o;        
wire                          mdio_en_o;     
wire [15:0]                   tx_sndpaustim_i;
wire                          tx_sndpausreq_i;
wire                          tx_fifoctrl_i; 
wire                          ignore_pkt_i;   
wire                          cpu_if_gbit_en_o;
wire                          tx_macread_o;
wire                          tx_discfrm_o;
wire                          tx_staten_o;
wire                          tx_done_o;
wire [30:0]                   tx_statvec_o;
wire                          rx_fifo_error_o; 
wire [31:0]                   rx_stat_vector_o;
wire                          rx_eof_o;  
wire                          rx_error_o;     
wire                          ahbl_hsel_i;
wire                          ahbl_hready_i;
wire [ADDR_WIDTH-1:0]         ahbl_haddr_i;
wire [2:0]                    ahbl_hburst_i;
wire [2:0]                    ahbl_hsize_i;
wire                          ahbl_hmastlock_i;
wire [3:0]                    ahbl_hprot_i;
wire [1:0]                    ahbl_htrans_i;
wire                          ahbl_hwrite_i;
wire [IF_DATA_WIDTH-1:0]      ahbl_hwdata_i;
wire                          ahbl_hreadyout_o;
wire                          ahbl_hresp_o;
wire [IF_DATA_WIDTH-1:0]      ahbl_hrdata_o;
wire                          apb_penable_i;    
wire                          apb_psel_i;        
wire                          apb_pwrite_i;       
wire [ADDR_WIDTH-1:0]         apb_paddr_i;         
wire [IF_DATA_WIDTH-1:0]      apb_pwdata_i;        
wire                          apb_pready_o;        
wire                          apb_pslverr_o;      
wire [IF_DATA_WIDTH-1:0]      apb_prdata_o;       
wire                          axi_awvalid_i;		
wire                          axi_awready_o;
wire [ADDR_WIDTH-1:0]         axi_awaddr_i;
wire [2:0]                    axi_awprot_i;		
wire                          axi_wvalid_i;		
wire                          axi_wready_o;
wire [IF_DATA_WIDTH-1:0]      axi_wdata_i;
wire [(IF_DATA_WIDTH/8)-1:0]  axi_wstrb_i;		
wire                          axi_bvalid_o;		
wire                          axi_bready_i;
wire [1:0]                    axi_bresp_o;		
wire                          axi_arvalid_i;		
wire                          axi_arready_o;
wire [ADDR_WIDTH-1:0]         axi_araddr_i;
wire [2:0]                    axi_arprot_i;		
wire                          axi_rvalid_o;	
wire                          axi_rready_i;
wire [IF_DATA_WIDTH-1:0]      axi_rdata_o;
wire [1:0]                    axi_rresp_o;
wire         			      int_o;               
wire          				  debug_link_timer_short_i;  
wire         				  mr_page_rx_o;            
wire         				  an_link_ok_o;              
wire  [15:0] 				  mr_lp_adv_ability_o;       
wire         				  mr_an_complete_o;          
wire  [15:0] 				  mr_adv_ability_i;
wire          				  mr_an_enable_i;
wire          				  mr_main_reset_i;
wire          				  mr_restart_an_i;
wire          				  force_isolate_i;
wire         				  force_loopback_i;
wire  [1:0] 				  operational_rate_i;
wire          				  force_unidir_i;
wire          				  cdr_refclk_i;              
wire          				  pll_refclk_i;             
wire                          clk_125m_pll_o;            
wire         				  usr_clk_o;                
wire         			      clk_gddr_o;               
wire         				  ser_tx_o;                 
wire          				  ser_rx_i;   
wire          				  clk_125m_pll_i;           
wire         				  clk_625m_pll_i;            
wire         				  clk_625m_90_pll_i;     
wire          				  pll_lock_i;
wire                          epcs_clkin_i;
wire                          sdq_refclkp_q0_i;
wire                          sdq_refclkn_q0_i;
wire                          sdq_refclkp_q1_i;
wire                          sdq_refclkn_q1_i;
wire                          sd0rxp_i;
wire                          sd0rxn_i;
wire                          sd0txp_o;
wire                          sd0txn_o;			
//--------------------------------------------------------------------------
// Assign Statements
//--------------------------------------------------------------------------
assign exp_mstr                 = axis_tx_tvalid_i && axis_tx_tready_o;
assign exp_valid                = exp_mstr ;
assign exp_data                 = exp_mstr ? axis_tx_tdata_i[DATA_WIDTH-1:0] : 32'h0;
assign obs_slv                  = axis_rx_tvalid_o;
assign obs_valid                = obs_slv;
assign obs_data                 = obs_slv ? axis_rx_tdata_o[DATA_WIDTH-1:0] : 32'h0;
assign ready                    = an_link_ok_o;
assign ser_rx_i                 = ser_tx_o; //loopback
assign clk_i                    = sysbus_clk;
assign reset_n_i                = reset_n;
assign mdc_i                    = mdc;
assign pll_refclk_i             = refclk;
assign axis_rx_tready_i         = 1'b1;
assign tx_sndpaustim_i          = 'h0;
assign tx_sndpausreq_i          = 'h0;
assign tx_fifoctrl_i            = 'h0; 
assign ignore_pkt_i             = 'h0;             
assign debug_link_timer_short_i = 1'b1;  
assign mr_adv_ability_i         = 'h0;
assign mr_an_enable_i           = 'h0;
assign mr_main_reset_i          = 'h0;
assign mr_restart_an_i          = 'h0;
assign force_isolate_i          = 'h0;
assign force_loopback_i         = 'h0;
assign operational_rate_i       = 2'b10;
assign force_unidir_i           = 'h0;
assign ahbl_hready_i            = ahbl_hreadyout_o;
assign epcs_clkin_i             = clk_i;
assign sdq_refclkp_q0_i         = refclk;
assign sdq_refclkn_q0_i         = ~refclk;
assign sdq_refclkp_q1_i         = refclk;
assign sdq_refclkn_q1_i         = ~refclk;
assign sd0rxp_i                 = sd0txp_o;
assign sd0rxn_i                 = sd0txn_o;
//--------------------------------------------------------------------------
// Initial statement; Reset sequence
//--------------------------------------------------------------------------
initial begin
  sysbus_clk    = 1;
  reset_n       = 0;
  start         = 0;
  refclk        = 0;
  mdc = 0;
  `N_MSG(          ("************************************************"))
  `N_MSG(          ("Start of Simulation                             "))
  `N_MSG(          ("+-----------------------------------------------"))
  `N_MSG(          ("Testbench Parameters                            "))
  `N_MSG(          ("+-----------------------------------------------"))
  `N_MSG(($sformatf("Device Name             :   %s",FAMILY          )))
  `N_MSG(($sformatf("IP Configuration        :   %s",IP_OPTION       )))
  `N_MSG(($sformatf("Register Interface      :   %s",INTERFACE       )))
  `N_MSG(($sformatf("Register width          :   %d",IF_DATA_WIDTH   )))
  `N_MSG(($sformatf("AXI4-stream data width  :   %d",DATA_WIDTH     )))
  `N_MSG(          ("+-----------------------------------------------"))
  `TIME_DELAY(20,sysbus_clk)
  reset_n  = 1;
  `N_MSG(          ("+-----------------------------------------------"))
  `N_MSG(          ("Wait for PLL to lock and PCS RX ready           "))
  `N_MSG(          ("+-----------------------------------------------"))
  @(&ready)
  `N_MSG(          ("+-----------------------------------------------"))
  `N_MSG(          ("PLL lock asserted                              "))
  `N_MSG(          ("PCS RX is now ready                             "))
  `N_MSG(          ("Driving AXI4-Stream TX random transactions      "))
  `N_MSG(          ("+-----------------------------------------------"))  
  @(&tb_done_w)
  `TIME_DELAY(2000,sysbus_clk)
  `N_MSG(          ("+-----------------------------------------------"))
  `N_MSG(          ("Transaction Done                                "))
  `N_MSG(          ("+-----------------------------------------------"))  
  if (tb_error_w) begin
    `E_MSG(        ("             SIMULATION FAILED                  "))
  end
  else begin
    `N_MSG(        ("             SIMULATION PASSED                  "))
  end   
  `ENDSIM(100,sysbus_clk)
end
//--------------------------------------------------------------------------
// Clock source
//--------------------------------------------------------------------------
always #(CLKPERIOD/2.0000) 
  sysbus_clk = ~sysbus_clk;
always #(CCLKPERIOD/2.0000) 
  mdc = ~mdc;
always #(REFPERIOD/2.0000) 
  refclk = ~refclk;
  
//--------------------------------------------------------------------------
// GSR
//--------------------------------------------------------------------------
GSR_CORE GSR_INST (
  .GSROUT            (gsr_out   ), 
  .GSR_N             (reset_n   ), 
  .CLK               (sysbus_clk)
);

generate
if (INTERFACE == "APB") begin : APB
//--------------------------------------------------------------------------
// APB Driver
//--------------------------------------------------------------------------
tb_apb_mst u_tb_apb_mst (
  .apb_pclk          (clk_i                 ),
  .apb_preset_n      (reset_n & ready       ),
  .apb_prdata        (apb_prdata_o          ),
  .apb_pready        (apb_pready_o          ),
  .apb_pslverr       (1'b0                  ),
  .apb_paddr         (apb_paddr_i           ),
  .apb_penable       (apb_penable_i         ),
  .apb_psel          (apb_psel_i            ),
  .apb_pwdata        (apb_pwdata_i          ),
  .apb_pwrite        (apb_pwrite_i          ),
  .done              (reg_done              )
);
end
else if (INTERFACE=="AXI4L") begin : AXI4L
//==================================================================
// Connect the AXI4L Driver 
//==================================================================
tse_mac_axi4l_master  #(.SGMII_TSMAC(SGMII_TSMAC),.GBE_MAC(GBE_MAC),.MIIM_MODULE(MIIM_MODULE),.CLASSIC_TSMAC(CLASSIC_TSMAC),.RGMII(RGMII))U_axi4l_master      (
  .i_clk              (clk_i				 ),
  .rst_n_i            (reset_n & ready       ),
  .axi_awvalid		  (axi_awvalid_i		 ),
  .axi_awready		  (axi_awready_o		 ),
  .axi_awaddr		  (axi_awaddr_i			 ),
  .axi_awprot		  (axi_awprot_i			 ),
  .axi_wvalid		  (axi_wvalid_i			 ),	
  .axi_wready		  (axi_wready_o			 ),
  .axi_wdata		  (axi_wdata_i			 ),
  .axi_wstrb		  (axi_wstrb_i			 ),
  .axi_bvalid	  	  (axi_bvalid_o			 ),
  .axi_bready	  	  (axi_bready_i			 ),
  .axi_bresp	  	  (axi_bresp_o			 ),
  .axi_arvalid		  (axi_arvalid_i		 ),
  .axi_arready		  (axi_arready_o		 ),
  .axi_araddr		  (axi_araddr_i			 ),
  .axi_arprot		  (axi_arprot_i			 ),
  .axi_rvalid		  (axi_rvalid_o			 ),
  .axi_rready		  (axi_rready_i			 ),
  .axi_rdata		  (axi_rdata_o			 ),
  .axi_rresp		  (axi_rresp_o			 ),
  .done               (reg_done              )  
);
end
else begin : AHBL
//==================================================================
// Connect the AHB Driver 
//==================================================================
tse_mac_ahb_master  #(.SGMII_TSMAC(SGMII_TSMAC),.GBE_MAC(GBE_MAC),.MIIM_MODULE(MIIM_MODULE),.CLASSIC_TSMAC(CLASSIC_TSMAC),.RGMII(RGMII))U_ahb_master        (
  .i_clk              (clk_i                 ),
  .rst_n_i            (reset_n & ready       ),
  .i_ahbl_hreadyout   (ahbl_hreadyout_o      ),                    
  .i_ahbl_hrdata      (ahbl_hrdata_o         ),    
  .o_ahbl_haddr       (ahbl_haddr_i          ),    
  .o_ahbl_hwdata      (ahbl_hwdata_i         ),         
  .o_ahbl_htrans      (ahbl_htrans_i         ),       
  .o_ahbl_hwrite      (ahbl_hwrite_i         ),         
  .o_ahbl_hburst      (ahbl_hburst_i         ),            
  .o_ahbl_hsize       (ahbl_hsize_i          ),           
  .o_ahbl_hprot       (ahbl_hprot_i          ),             
  .o_ahbl_hsel        (ahbl_hsel_i           ),             
  .o_ahbl_hmastlock   (ahbl_hmastlock_i      ),
  .done               (reg_done              )  
);
end
endgenerate


//--------------------------------------------------------------------------
// AXI-4 Stream Driver
//--------------------------------------------------------------------------
tb_axis_mst #(
  .IN_DATA_WIDTH  (8),
  .OUT_DATA_WIDTH (8)
  ) u_tb_axis_mst ( 
  .axis_tvalid_o     (axis_tx_tvalid_i ),
  .axis_tlast_o      (axis_tx_tlast_i  ),
  .axis_tid_o        (tx_axis_tid      ), //not used
  .axis_tdest_o      (tx_axis_tdest    ), //not used
  .axis_tdata_o      (axis_tx_tdata_i  ),
  .axis_tstrb_o      (tx_axis_tstrb    ), //not used
  .axis_tkeep_o      (tx_axis_tkeep    ), //not used
  .axis_tuser_o      (tx_axis_tuser    ), //not used
  .axis_aclk_i       (usr_clk_o        ),
  .axis_arstn_i      (reset_n          ),
  .axis_tready_i     (axis_tx_tready_o ),
  .sys_ready_i       (reg_done & ready ),
  .done              (tb_done_w        )
);
//--------------------------------------------------------------------------
// Data Checker
//--------------------------------------------------------------------------
tb_data_checker #(
  .WADDR_DEPTH       (WADDR_DEPTH       ),
  .WADDR_WIDTH       (clog2(WADDR_DEPTH)),
  .WDATA_WIDTH       (DATA_WIDTH        ),
  .RADDR_DEPTH       (RADDR_DEPTH       ),
  .RADDR_WIDTH       (clog2(RADDR_DEPTH)),
  .RDATA_WIDTH       (DATA_WIDTH        )
) u_tb_data_checker (
  // Outputs
  .error_o           (tb_error_w        ),
  // Inputs                             
  .clk_i             (usr_clk_o         ),
  .rst_n_i           (reset_n & ready   ),
  .direction_i       (1'b1              ),
  .exp_valid_i       (exp_valid         ),
  .exp_data_i        (exp_data          ),
  .obs_valid_i       (obs_valid         ),
  .obs_data_i        (obs_data          ),
  .byte_en_i         (axis_rx_tvalid_o  ),
  .eof_i             (axis_rx_tlast_o   )
);
//--------------------------------------------------------------------------
// DUT - MAC + PHY
//--------------------------------------------------------------------------
`include "dut_inst.v"

always @(posedge sysbus_clk or negedge reset_n) begin
  if (!reset_n) begin
    obs_valid_Q     <= 0;
  end
  else begin
    obs_valid_Q     <= obs_valid;
    obs_data_Q      <= obs_data;
  end
end
	  
//------------------------------------------------------------------------------
// Function Definition
//------------------------------------------------------------------------------
// synopsys translate_off
function [31:0] clog2;
  input [31:0] value;
  reg   [31:0] num;
  begin
    num = value - 1;
    for (clog2 = 0; num > 0; clog2 = clog2 + 1) num = num >> 1;
  end
endfunction
// synopsys translate_on

endmodule