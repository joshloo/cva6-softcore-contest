`timescale 1ns/1ns
`include "axi_register_slice_manager.sv"
`include "axi_register_slice_subordinate.sv"
module axi_register_slice_tb();
	
	`include "dut_params.v"
//================This is for Regression in Questa===============//
/*
	
	`ifdef AWF_WF_BF_ARF_RF		
		`include "dut_params_AWF_WF_BF_ARF_RF.v"
	`elsif AWF_WF_BF_ARF_RI
		`include "dut_params_AWF_WF_BF_ARF_RI.v"
	`elsif AWF_WF_BF_ARI_RI
	    `include "dut_params_AWF_WF_BF_ARI_RI.v"
	`elsif AWF_WF_BI_ARI_RI
	    `include "dut_params_AWF_WF_BI_ARI_RI.v"
	`elsif AWF_WI_BI_ARI_RI
	    `include "dut_params_AWF_WI_BI_ARI_RI.v"
	`elsif AWL_WF_BL_ARL_RI
	    `include "dut_params_AWL_WF_BL_ARL_RI.v"
	`elsif AWL_WF_BL_ARL_RF
	    `include "dut_params_AWL_WF_BL_ARL_RF.v"
	`elsif AWL_WF_BL_ARF_RI
	    `include "dut_params_AWL_WF_BL_ARF_RI.v"
	`elsif AWL_WF_BI_ARI_RI
	    `include "dut_params_AWL_WF_BI_ARI_RI.v"
	`elsif AWL_WF_BF_ARF_RF
	    `include "dut_params_AWL_WF_BF_ARF_RF.v"
	`elsif AWI_WI_BI_ARI_RI
	    `include "dut_params_AWI_WI_BI_ARI_RI.v"
	`elsif AWI_WI_BI_ARI_RF
	    `include "dut_params_AWI_WI_BI_ARI_RF.v"
	`elsif AWI_WI_BI_ARL_RF
	    `include "dut_params_AWI_WI_BI_ARL_RF.v"
	`elsif AWI_WI_BL_ARL_RF
	    `include "dut_params_AWI_WI_BL_ARL_RF.v"
	`elsif AWI_WF_BL_ARL_RF
	    `include "dut_params_AWI_WF_BL_ARL_RF.v"
	`endif
*/
//====================================================//	
	
	`define LFCPNX
	`define jd5d00
	`define LFCPNX-100
	initial begin
		if(REG_CONFIG_AW==0)		$display("ADDRESS WRITE CHANNEL in FULL WEIGHT MODE");
		else if(REG_CONFIG_AW==1)	$display("ADDRESS WRITE CHANNEL in HALF WEIGHT MODE");
		else if(REG_CONFIG_AW==2)	$display("ADDRESS WRITE CHANNEL in INPUT REGISTER MODE");
		if(REG_CONFIG_W==0)			$display("DATA WRITE CHANNEL in FULL WEIGHT MODE");
		else if(REG_CONFIG_W==1)	$display("DATA WRITE CHANNEL in HALF WEIGHT MODE");
		else if(REG_CONFIG_W==2)	$display("DATA WRITE CHANNEL in INPUT REGISTER MODE");
		if(REG_CONFIG_B==0)			$display("WRITE RESPONSE CHANNEL in FULL WEIGHT MODE");
		else if(REG_CONFIG_B==1)	$display("WRITE RESPONSE CHANNEL in HALF WEIGHT MODE");
		else if(REG_CONFIG_B==2)	$display("WRITE RESPONSE CHANNEL in INPUT REGISTER MODE");
		if(REG_CONFIG_AR==0)		$display("ADDRESS READ CHANNEL in FULL WEIGHT MODE");
		else if(REG_CONFIG_AR==1)	$display("ADDRESS READ CHANNEL in HALF WEIGHT MODE");
		else if(REG_CONFIG_AR==2)	$display("ADDRESS READ CHANNEL in INPUT REGISTER MODE");
		if(REG_CONFIG_R==0)			$display("DATA READ CHANNEL in FULL WEIGHT MODE");
		else if(REG_CONFIG_R==1)	$display("DATA READ CHANNEL in HALF WEIGHT MODE");
		else if(REG_CONFIG_R==2)	$display("DATA READ CHANNEL in INPUT REGISTER MODE");		
	end
	// System Signals
      reg        								a_clk_i =0;
      reg        								a_reset_n_i=0;
	  reg  [31:0]								manager_data[$];
	  reg  [31:0]								subordinate_data[$];
	  reg 		  								protocol_counter=0;
	  int 		  								checker_counter=0;
    
      // Manager Interface Write Address Ports
      wire [AXI_ID_WIDTH-1:0]                    s_axi_awid_i;
      wire [AXI_ADDR_WIDTH-1:0]                  s_axi_awaddr_i;
      wire [((AXI_PROTOCOL == 1) ? 4 : 8)-1:0]   s_axi_awlen_i;
      wire [3-1:0]                               s_axi_awsize_i;
      wire [2-1:0]                               s_axi_awburst_i;
      wire [((AXI_PROTOCOL == 1) ? 2 : 1)-1:0]   s_axi_awlock_i;
      wire [4-1:0]                               s_axi_awcache_i;
      wire [3-1:0]                               s_axi_awprot_i;
      wire [4-1:0]                               s_axi_awregion_i;
      wire [4-1:0]                               s_axi_awqos_i;
      wire [AXI_AWUSER_WIDTH-1:0]                s_axi_awuser_i;
      wire                                       s_axi_awvalid_i;
      reg                                        s_axi_awready_o;
    
      // Manager Interface Write Data Ports
      wire [((AXI_PROTOCOL == 1) ? 4 : 1)-1:0]   s_axi_wid_i;
      wire [AXI_DATA_WIDTH-1:0]                  s_axi_wdata_i;
      wire [AXI_DATA_WIDTH/8-1:0]                s_axi_wstrb_i;
      wire                                       s_axi_wlast_i;
      wire [AXI_WUSER_WIDTH-1:0]                 s_axi_wuser_i;
      wire                                       s_axi_wvalid_i;
      reg                                        s_axi_wready_o;
    
      // Manager Interface Write Response Ports
      wire [AXI_ID_WIDTH-1:0]                   s_axi_bid_o;
      wire [2-1:0]                              s_axi_bresp_o;
      wire [AXI_BUSER_WIDTH-1:0]                s_axi_buser_o;
      wire                                      s_axi_bvalid_o;
      reg                                       s_axi_bready_i;
    
      // Manager Interface Read Address Ports
      wire [AXI_ID_WIDTH-1:0]                    s_axi_arid_i;
      wire [AXI_ADDR_WIDTH-1:0]                  s_axi_araddr_i;
      wire [((AXI_PROTOCOL == 1) ? 4 : 8)-1:0]   s_axi_arlen_i;
      wire [3-1:0]                               s_axi_arsize_i;
      wire [2-1:0]                               s_axi_arburst_i;
      wire [((AXI_PROTOCOL == 1) ? 2 : 1)-1:0]   s_axi_arlock_i;
      wire [4-1:0]                               s_axi_arcache_i;
      wire [3-1:0]                               s_axi_arprot_i;
      wire [4-1:0]                               s_axi_arregion_i;
      wire [4-1:0]                               s_axi_arqos_i;
      wire [AXI_ARUSER_WIDTH-1:0]                s_axi_aruser_i;
      wire                                       s_axi_arvalid_i;
      reg                                        s_axi_arready_o;
    
      // Manager Interface Read Data Ports
      wire [AXI_ID_WIDTH-1:0]                   s_axi_rid_o;
      wire [AXI_DATA_WIDTH-1:0]                 s_axi_rdata_o;
      wire [2-1:0]                              s_axi_rresp_o;
      wire                                      s_axi_rlast_o;
      wire [AXI_RUSER_WIDTH-1:0]                s_axi_ruser_o;
      wire                                      s_axi_rvalid_o;
      reg                                       s_axi_rready_i;
      
      // Subordinate Interface Write Address Port
      wire [AXI_ID_WIDTH-1:0]                   m_axi_awid_o;
      wire [AXI_ADDR_WIDTH-1:0]                 m_axi_awaddr_o;
      wire [((AXI_PROTOCOL == 1) ? 4 : 8)-1:0]  m_axi_awlen_o;
      wire [3-1:0]                              m_axi_awsize_o;
      wire [2-1:0]                              m_axi_awburst_o;
      wire [((AXI_PROTOCOL == 1) ? 2 : 1)-1:0]  m_axi_awlock_o;
      wire [4-1:0]                              m_axi_awcache_o;
      wire [3-1:0]                              m_axi_awprot_o;
      wire [4-1:0]                              m_axi_awregion_o;
      wire [4-1:0]                              m_axi_awqos_o;
      wire [AXI_AWUSER_WIDTH-1:0]               m_axi_awuser_o;
      reg                                      m_axi_awvalid_o;
      reg                                       m_axi_awready_i;
      
      // Subordinate Interface Write Data Ports
      wire [((AXI_PROTOCOL == 1) ? 4 : 1)-1:0]  m_axi_wid_o;
      wire [AXI_DATA_WIDTH-1:0]                 m_axi_wdata_o;
      wire [AXI_DATA_WIDTH/8-1:0]               m_axi_wstrb_o;
      wire                                      m_axi_wlast_o;
      wire [AXI_WUSER_WIDTH-1:0]                m_axi_wuser_o;
      wire                                      m_axi_wvalid_o;
      reg                                       m_axi_wready_i;
      
      // Subordinate Interface Write Response Ports
      wire [AXI_ID_WIDTH-1:0]                    m_axi_bid_i;
      wire [2-1:0]                               m_axi_bresp_i;
      wire [AXI_BUSER_WIDTH-1:0]                 m_axi_buser_i;
      wire                                       m_axi_bvalid_i;
      reg                                       m_axi_bready_o;
      
      // Subordinate Interface Read Address Port
      wire [AXI_ID_WIDTH-1:0]                   m_axi_arid_o;
      wire [AXI_ADDR_WIDTH-1:0]                 m_axi_araddr_o;
      wire [((AXI_PROTOCOL == 1) ? 4 : 8)-1:0]  m_axi_arlen_o;
      wire [3-1:0]                              m_axi_arsize_o;
      wire [2-1:0]                              m_axi_arburst_o;
      wire [((AXI_PROTOCOL == 1) ? 2 : 1)-1:0]  m_axi_arlock_o;
      wire [4-1:0]                              m_axi_arcache_o;
      wire [3-1:0]                              m_axi_arprot_o;
      wire [4-1:0]                              m_axi_arregion_o;
      wire [4-1:0]                              m_axi_arqos_o;
      wire [AXI_ARUSER_WIDTH-1:0]               m_axi_aruser_o;
      wire                                      m_axi_arvalid_o;
      reg                                       m_axi_arready_i;
      
      // Subordinate Interface Read Data Ports
      wire [AXI_ID_WIDTH-1:0]                    m_axi_rid_i;
      wire [AXI_DATA_WIDTH-1:0]                  m_axi_rdata_i;
      wire [2-1:0]                               m_axi_rresp_i;
      wire                                       m_axi_rlast_i;
      wire [AXI_RUSER_WIDTH-1:0]                 m_axi_ruser_i;
      wire                                       m_axi_rvalid_i;
      reg                                      m_axi_rready_o;
	  bit										status;
	  bit										status_a;
   
      //Checker signals
      logic 									 m_valid;
	  logic 									 m_ready;
	  logic		[AXI_ADDR_WIDTH-1:0]			 m_data;
	  logic 									 s_valid;
	  logic 									 s_ready;
	  logic		[AXI_ADDR_WIDTH-1:0]			 s_data;
	  
	  logic 									 m_valid_a;
	  logic 									 m_ready_a;
	  logic		[AXI_ADDR_WIDTH-1:0]			 m_data_a;
	  logic 									 s_valid_a;
	  logic 									 s_ready_a;
	  logic		[AXI_ADDR_WIDTH-1:0]			 s_data_a;
	  
	  logic 	[4:0]     					  		 channel;
	    logic 	[4:0]     					  		 channel_a;
	
	  logic 	[1:0]							 m_resp_data;
	  logic 	[1:0]							 s_resp_data;
	
	  
   `include "dut_inst.v"

	//===============CLOCK LOGIC=============//
	always #5 a_clk_i = ~a_clk_i ;  //// 100 MHz clock
    //======================================//  
    //===============RESET LOGIC==============//
	initial begin
	a_reset_n_i  = 1'b0 ;
	repeat(100) @(posedge a_clk_i);
	a_reset_n_i  = 1'b1 ;  
	end
	//========================================//
	//========================================//
	always @(posedge a_clk_i)
	begin
		if(~a_reset_n_i)
		begin
			m_data=0;
			m_valid=0;
			m_ready=0;
			s_data=0;
			s_valid=0;
			s_ready=0;
			m_resp_data=0;
			s_resp_data=0;
		end
	end

//==========================MANAGER INSTANTIATION=====================// 
axi_register_slice_manager #
	(
	 .AXI_PROTOCOL(AXI_PROTOCOL),
     .AXI_ID_WIDTH(AXI_ID_WIDTH),
     .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
     .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
     .AXI_SUPPORTS_USER_SIGNALS(AXI_SUPPORTS_USER_SIGNALS),
     .AXI_AWUSER_WIDTH(AXI_AWUSER_WIDTH),
     .AXI_ARUSER_WIDTH(AXI_ARUSER_WIDTH),
     .AXI_WUSER_WIDTH(AXI_WUSER_WIDTH),
     .AXI_RUSER_WIDTH(AXI_RUSER_WIDTH),
     .AXI_BUSER_WIDTH(AXI_BUSER_WIDTH),
	 .REG_CONFIG_AW(REG_CONFIG_AW),
     .REG_CONFIG_W(REG_CONFIG_W),
     .REG_CONFIG_B(REG_CONFIG_B),
     .REG_CONFIG_AR(REG_CONFIG_AR),
     .REG_CONFIG_R(REG_CONFIG_R)
	) axi_manager


	(      
	.a_clk_i(a_clk_i),
	.a_reset_n_i(a_reset_n_i),

    
      // Manager Interface Write Address Ports
	.m_axi_awid(s_axi_awid_i),
	.m_axi_awaddr(s_axi_awaddr_i),
    .m_axi_awlen(s_axi_awlen_i),
    .m_axi_awsize(s_axi_awsize_i),
    .m_axi_awburst(s_axi_awburst_i),
    .m_axi_awlock(s_axi_awlock_i),
    .m_axi_awcache(s_axi_awcache_i),
    .m_axi_awprot(s_axi_awprot_i),
    .m_axi_awregion(s_axi_awregion_i),
    .m_axi_awqos(s_axi_awqos_i),
    .m_axi_awuser(s_axi_awuser_i),
    .m_axi_awvalid(s_axi_awvalid_i),
    .m_axi_awready(s_axi_awready_o),
    
      // Manager Interface Write Data Ports
    .m_axi_wid(s_axi_wid_i),
    .m_axi_wdata(s_axi_wdata_i),
    .m_axi_wstrb(s_axi_wstrb_i),
    .m_axi_wlast(s_axi_wlast_i),
    .m_axi_wuser(s_axi_wuser_i),
    .m_axi_wvalid(s_axi_wvalid_i),
    .m_axi_wready(s_axi_wready_o),
    
      // Manager Interface Write Response Ports
    .m_axi_bid(s_axi_bid_o),
    .m_axi_bresp(s_axi_bresp_o),
    .m_axi_buser(s_axi_buser_o),
    .m_axi_bvalid(s_axi_bvalid_o),
    .m_axi_bready(s_axi_bready_i),
    
      // Manager Interface Read Address Ports
    .m_axi_arid(s_axi_arid_i),
    .m_axi_araddr(s_axi_araddr_i),
    .m_axi_arlen(s_axi_arlen_i),
	.m_axi_arsize(s_axi_arsize_i),
    .m_axi_arburst(s_axi_arburst_i),
    .m_axi_arlock(s_axi_arlock_i),
    .m_axi_arcache(s_axi_arcache_i),
    .m_axi_arprot(s_axi_arprot_i),
    .m_axi_arregion(s_axi_arregion_i),
    .m_axi_arqos(s_axi_arqos_i),
    .m_axi_aruser(s_axi_aruser_i),
	.m_axi_arvalid(s_axi_arvalid_i),
    .m_axi_arready(s_axi_arready_o),
    
      // Manager Interface Read Data Ports
    .m_axi_rid(s_axi_rid_o),
    .m_axi_rdata(s_axi_rdata_o),
    .m_axi_rresp(s_axi_rresp_o),
    .m_axi_rlast(s_axi_rlast_o),
    .m_axi_ruser(s_axi_ruser_o),
    .m_axi_rvalid(s_axi_rvalid_o),
    .m_axi_rready(s_axi_rready_i),
	.status(status),
	.channel(channel),
	.channel_a(channel_a)
	);
//================================================================//

//==========================SUBORDINATE INSTANTIATION=====================// 
axi_register_slice_subordinate #
	(
	 .AXI_PROTOCOL(AXI_PROTOCOL),
     .AXI_ID_WIDTH(AXI_ID_WIDTH),
     .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
     .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
     .AXI_SUPPORTS_USER_SIGNALS(AXI_SUPPORTS_USER_SIGNALS),
     .AXI_AWUSER_WIDTH(AXI_AWUSER_WIDTH),
     .AXI_ARUSER_WIDTH(AXI_ARUSER_WIDTH),
     .AXI_WUSER_WIDTH(AXI_WUSER_WIDTH),
     .AXI_RUSER_WIDTH(AXI_RUSER_WIDTH),
     .AXI_BUSER_WIDTH(AXI_BUSER_WIDTH),
	 .REG_CONFIG_AW(REG_CONFIG_AW),
     .REG_CONFIG_W(REG_CONFIG_W),
     .REG_CONFIG_B(REG_CONFIG_B),
     .REG_CONFIG_AR(REG_CONFIG_AR),
     .REG_CONFIG_R(REG_CONFIG_R)
	) axi_subordinate


	(      
	.a_clk_i(a_clk_i),
	.a_reset_n_i(a_reset_n_i),
	.number_of_delays(number_of_delays),
    
      // Manager Interface Write Address Ports
	.s_axi_awid(0),
	.s_axi_awaddr(m_axi_awaddr_o),
    .s_axi_awlen(m_axi_awlen_o),
    .s_axi_awsize(m_axi_awsize_o),
    .s_axi_awburst(m_axi_awburst_o),
    .s_axi_awlock(m_axi_awlock_o),
    .s_axi_awcache(m_axi_awcache_o),
    .s_axi_awprot(m_axi_awprot_o),
    .s_axi_awregion(m_axi_awregion_o),
    .s_axi_awqos(m_axi_awqos_o),
    .s_axi_awuser(m_axi_awuser_o),
    .s_axi_awvalid(m_axi_awvalid_o),
    .s_axi_awready(m_axi_awready_i),
    
      // Manager Interface Write Data Ports
    .s_axi_wid(m_axi_wid_o),
    .s_axi_wdata(m_axi_wdata_o),
    .s_axi_wstrb(m_axi_wstrb_o),
    .s_axi_wlast(m_axi_wlast_o),
    .s_axi_wuser(m_axi_wuser_o),
    .s_axi_wvalid(m_axi_wvalid_o),
    .s_axi_wready(m_axi_wready_i),
    
      // Manager Interface Write Response Ports
    .s_axi_bid(m_axi_bid_i),
    .s_axi_bresp(m_axi_bresp_i),
    .s_axi_buser(m_axi_buser_i),
    .s_axi_bvalid(m_axi_bvalid_i),
    .s_axi_bready(m_axi_bready_o),
    
      // Manager Interface Read Address Ports
    .s_axi_arid(m_axi_arid_o),
    .s_axi_araddr(m_axi_araddr_o),
    .s_axi_arlen(m_axi_arlen_o),
	.s_axi_arsize(m_axi_arsize_o),
    .s_axi_arburst(m_axi_arburst_o),
    .s_axi_arlock(m_axi_arlock_o),
    .s_axi_arcache(m_axi_arcache_o),
    .s_axi_arprot(m_axi_arprot_o),
    .s_axi_arregion(m_axi_arregion_o),
    .s_axi_arqos(m_axi_arqos_o),
    .s_axi_aruser(m_axi_aruser_o),
	.s_axi_arvalid(m_axi_arvalid_o),
    .s_axi_arready(m_axi_arready_i),
    
      // Manager Interface Read Data Ports
    .s_axi_rid(m_axi_rid_i),
    .s_axi_rdata(m_axi_rdata_i),
    .s_axi_rresp(m_axi_rresp_i),
    .s_axi_rlast(m_axi_rlast_i),
    .s_axi_ruser(m_axi_ruser_i),
    .s_axi_rvalid(m_axi_rvalid_i),
    .s_axi_rready(m_axi_rready_o),
	.status(status),
	.channel(channel),
	.channel_a(channel_a)
	);
	
//===================CHECKER INSTANTIATION===============//
axi_register_slice_checker #
	(
	 .AXI_PROTOCOL(AXI_PROTOCOL),
     .AXI_ID_WIDTH(AXI_ID_WIDTH),
     .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
     .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
     .AXI_SUPPORTS_USER_SIGNALS(AXI_SUPPORTS_USER_SIGNALS),
     .AXI_AWUSER_WIDTH(AXI_AWUSER_WIDTH),
     .AXI_ARUSER_WIDTH(AXI_ARUSER_WIDTH),
     .AXI_WUSER_WIDTH(AXI_WUSER_WIDTH),
     .AXI_RUSER_WIDTH(AXI_RUSER_WIDTH),
     .AXI_BUSER_WIDTH(AXI_BUSER_WIDTH),
	 .REG_CONFIG_AW(REG_CONFIG_AW),
     .REG_CONFIG_W(REG_CONFIG_W),
     .REG_CONFIG_B(REG_CONFIG_B),
     .REG_CONFIG_AR(REG_CONFIG_AR),
     .REG_CONFIG_R(REG_CONFIG_R)
	) data_checker
	
	(
	.a_clk_i(a_clk_i),
	.a_reset_n_i(a_reset_n_i),
	.m_valid(m_valid),
	.m_ready(m_ready),
	.m_data(m_data),
	.s_valid(s_valid),
	.s_ready(s_ready),
	.s_data(s_data),
	.m_valid_a(m_valid_a),
	.m_ready_a(m_ready_a),
	.m_data_a(m_data_a),
	.s_valid_a(s_valid_a),
	.s_ready_a(s_ready_a),
	.s_data_a(s_data_a),
	.channel(channel),
	.channel_a(channel_a),
    .status(status)
	
	);


	//=====================TESTCASES==================================//
	initial 
	begin
	    //-----WRITE ADDRESS & WRITE DATA-----//
        begin		
     		status=1;
			channel=8'h10;		//0 is valid first and 1 is ready first
		    channel_a=8'h08;
		
			@(posedge a_clk_i);
			@(posedge a_clk_i);
			@(posedge a_reset_n_i);

			$display("================================================");
			$display("--AXI_REGISTER_SLICE --WRITE ADDRESS-- CHANNEL--");
			$display("--AXI_REGISTER_SLICE --WRITE DATA-- CHANNEL--");
			$display("================================================");
			for(int i=1;i<=10;i++) 
			begin
				force m_valid=s_axi_awvalid_i;
				force m_valid_a=s_axi_wvalid_i;
				force m_ready=s_axi_awready_o;
				force m_ready_a=s_axi_wready_o;
				force m_data=s_axi_awaddr_i;
				force m_data_a=s_axi_wdata_i;
				force s_valid=m_axi_awvalid_o;
				force s_valid_a=m_axi_wvalid_o;
				force s_ready=m_axi_awready_i;
				force s_ready_a=m_axi_wready_i;
				force s_data=m_axi_awaddr_o;
				force s_data_a=m_axi_wdata_o;
				channel=8'h10;
				axi_manager.write_addr_ready_before_valid();
			end
			status=0;
			for(int i=1;i<=40;i++) 
			begin
				force m_valid=s_axi_awvalid_i;
				force m_valid_a=s_axi_wvalid_i;
				force m_ready=s_axi_awready_o;
				force m_ready_a=s_axi_wready_o;
				force m_data=s_axi_awaddr_i;
				force m_data_a=s_axi_wdata_i;
				force s_valid=m_axi_awvalid_o;
				force s_valid_a=m_axi_wvalid_o;
				force s_ready=m_axi_awready_i;
				force s_ready_a=m_axi_wready_i;
				force s_data=m_axi_awaddr_o;
				force s_data_a=m_axi_wdata_o;
				channel=8'h10;
				axi_manager.write_addr_ready_before_valid();
			end
			@(posedge a_clk_i);
			@(posedge a_clk_i);
			@(posedge a_clk_i);
			//@(posedge a_clk_i);
	        force s_axi_awvalid_i=0;
    	    //@(posedge a_clk_i);		  
		    force s_axi_wvalid_i=0;
			@(posedge a_clk_i);
		    #50ns
			$display("===========================================================================");
			$display("DATA FROM MANAGER AND SUB-ORDINATE IS MATCHING FOR *WRITE ADDRESS CHANNEL*");
			$display("1 CLOCK LATENCY IS ADDED SUCCESFULLY");
			$display("===========================================================================");
			$display("===========================================================================");
			$display("DATA FROM MANAGER AND SUB-ORDINATE IS MATCHING FOR *WRITE DATA* CHANNEL*");
			$display("1 CLOCK LATENCY IS ADDED SUCCESFULLY");
			$display("===========================================================================");
		end	
			
			#500ns
			status=1;
			channel=8'h04;
			
			$display("--AXI_REGISTER_SLICE --WRITE RESPONSE-- CHANNEL--");
			$display("==================================================");
			for(int i=1;i<=10;i++) 
			begin
				force m_valid=m_axi_bvalid_i;
				force m_ready=m_axi_bready_o;
				force m_data=m_axi_bresp_i;
				force s_valid=s_axi_bvalid_o;
				force s_ready=s_axi_bready_i;
				force s_data=s_axi_bresp_o;
				channel=8'h04;			
				axi_subordinate.write_resp_ready_before_valid();
			end
			
			status = 0;
			for(int i=1;i<=40;i++) 
			begin
				force m_valid=m_axi_bvalid_i;
				force m_ready=m_axi_bready_o;
				force m_data=m_axi_bresp_i;
				force s_valid=s_axi_bvalid_o;
				force s_ready=s_axi_bready_i;
				force s_data=s_axi_bresp_o;
				channel=8'h04;			
				axi_subordinate.write_resp_ready_before_valid();
			end
			@(posedge a_clk_i);
			@(posedge a_clk_i);
			@(posedge a_clk_i);
			force m_axi_bvalid_i = 0;
			@(posedge a_clk_i);
			#50ns
			$display("================================================================");
			$display("DATA FROM MANAGER AND SUB-ORDINATE IS MATCHING FOR *WRITE RESPONSE CHANNEL*");
			$display("================================================================");
		
		fork
		begin
			#500ns
			status=1;
			channel = 8'h02;
			$display("--AXI_REGISTER_SLICE --READ ADDRESS-- CHANNEL--");
			$display("================================================");
			for(int i=1;i<=10;i++) 
			begin
				force m_valid=s_axi_arvalid_i;
				force m_ready=s_axi_arready_o;
				force m_data=s_axi_araddr_i;
				force s_valid=m_axi_arvalid_o;
				force s_ready=m_axi_arready_i;
				force s_data=m_axi_araddr_o;
				channel=8'h02;			
				axi_manager.read_addr_ready_before_valid();
			end
			
			status = 0;
			for(int i=1;i<=40;i++) 
			begin
				force m_valid=s_axi_arvalid_i;
				force m_ready=s_axi_arready_o;
				force m_data=s_axi_araddr_i;
				force s_valid=m_axi_arvalid_o;
				force s_ready=m_axi_arready_i;
				force s_data=m_axi_araddr_o;
				channel=8'h02;			
				axi_manager.read_addr_ready_before_valid();
			end
			@(posedge a_clk_i);
			@(posedge a_clk_i);
			@(posedge a_clk_i);
	        force s_axi_arvalid_i=0;
    	    @(posedge a_clk_i);
			$display("===========================================================================");
			$display("DATA FROM MANAGER AND SUB-ORDINATE IS MATCHING *READ ADDRESS CHANNEL*");
			$display("===========================================================================");
		end
		begin
			#500ns
			status=1;
			channel_a=8'h01;
		
			$display("--AXI_REGISTER_SLICE --READ DATA-- CHANNEL--");
			$display("================================================");
			for(int i=1;i<=10;i++) 
			begin
				force m_valid_a=m_axi_rvalid_i;
				force m_ready_a=m_axi_rready_o;
				force m_data_a=m_axi_rdata_i;
				force s_valid_a=s_axi_rvalid_o;
				force s_ready_a=s_axi_rready_i;
				force s_data_a=s_axi_rdata_o;
				channel_a=8'h01;	
				axi_subordinate.read_data_ready_before_valid();
			end
			
			status = 0;
			for(int i=1;i<=40;i++) 
			begin
				force m_valid_a=m_axi_rvalid_i;
				force m_ready_a=m_axi_rready_o;
				force m_data_a=m_axi_rdata_i;
				force s_valid_a=s_axi_rvalid_o;
				force s_ready_a=s_axi_rready_i;
				force s_data_a=s_axi_rdata_o;
				channel_a=8'h01;	
				axi_subordinate.read_data_ready_before_valid();
			end
			@(posedge a_clk_i);
			@(posedge a_clk_i);
			@(posedge a_clk_i);
	        force m_axi_rvalid_i=0;
    	    @(posedge a_clk_i);
			$display("===================================================================");
			$display("DATA FROM MANAGER AND SUB-ORDINATE IS MATCHING *READ DATA CHANNEL*");
			$display("===================================================================");
		end
		join
			
					
		
			
			$display("================================================================");
			$display("*************************TESTCASE PASSED************************");
			$display("================================================================");
			$stop;
		end
	
endmodule
