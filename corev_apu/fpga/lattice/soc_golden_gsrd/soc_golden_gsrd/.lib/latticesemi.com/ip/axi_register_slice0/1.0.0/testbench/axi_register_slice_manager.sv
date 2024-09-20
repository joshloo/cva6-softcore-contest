//========================================================//
//=======================AXI MANAGER======================//
//========================================================//

`define signal_stalling	13
`define long_ready 0
`define ready_first 1
`timescale 1ns/1ns
module axi_register_slice_manager #
   (
     parameter AXI_PROTOCOL              = 0,
     parameter AXI_ID_WIDTH              = 4,
     parameter AXI_ADDR_WIDTH            = 32,
     parameter AXI_DATA_WIDTH            = 32,
     parameter AXI_SUPPORTS_USER_SIGNALS = 0,
     parameter AXI_AWUSER_WIDTH          = 1,
     parameter AXI_ARUSER_WIDTH          = 1,
     parameter AXI_WUSER_WIDTH           = 1,
     parameter AXI_RUSER_WIDTH           = 1,
     parameter AXI_BUSER_WIDTH           = 1,
     
     // REG_CONFIG :
     //   0 => FWD_REV   = Both FWD and REV (fully-registered)
     //   1 => LIGHT_WT  = 1-stage pipeline register with bubble cycle, both FWD and REV pipelining
     //   2 => INPUTS    = Subordinate and Manager side inputs are registered.   
     parameter REG_CONFIG_AW             = 0,
     parameter REG_CONFIG_W              = 0,
     parameter REG_CONFIG_B              = 0,
     parameter REG_CONFIG_AR             = 0,
     parameter REG_CONFIG_R              = 0
    )   
	(
	// System Signals
     input         a_clk_i,
     input         a_reset_n_i,
     
     // Subordinate Interface Write Address Ports
     output logic [AXI_ID_WIDTH-1:0]                   m_axi_awid,
     output logic [AXI_ADDR_WIDTH-1:0]                 m_axi_awaddr,
     output logic [((AXI_PROTOCOL == 1) ? 4 : 8)-1:0]  m_axi_awlen,
     output logic [3-1:0]                              m_axi_awsize,
     output logic [2-1:0]                              m_axi_awburst,
     output logic [((AXI_PROTOCOL == 1) ? 2 : 1)-1:0]  m_axi_awlock,
     output logic [4-1:0]                              m_axi_awcache,
     output logic [3-1:0]                              m_axi_awprot,
     output logic [4-1:0]                              m_axi_awregion,
     output logic [4-1:0]                              m_axi_awqos,
     output logic [AXI_AWUSER_WIDTH-1:0]               m_axi_awuser,
     output logic                                      m_axi_awvalid,
     input 		                                 	   m_axi_awready,
    
     // Subordinate Interface Write Data Ports
     output logic [((AXI_PROTOCOL == 1) ? 4 : 1)-1:0]  m_axi_wid,
     output logic [AXI_DATA_WIDTH-1:0]                 m_axi_wdata,
     output logic [AXI_DATA_WIDTH/8-1:0]               m_axi_wstrb,
     output logic                                      m_axi_wlast,
     output logic [AXI_WUSER_WIDTH-1:0]                m_axi_wuser,
     output logic		                               m_axi_wvalid,
     input                              		       m_axi_wready,
     
     // Subordinate Interface Write Response Ports
     output  logic [AXI_ID_WIDTH-1:0]           		m_axi_bid,
     input   logic [2-1:0]                      		m_axi_bresp,
     output  logic [AXI_BUSER_WIDTH-1:0]        		m_axi_buser,
     input 				                        		m_axi_bvalid,
     output logic                        			    m_axi_bready,
     
     // Subordinate Interface Read Address Ports
     output logic  [AXI_ID_WIDTH-1:0]                   m_axi_arid,
     output logic  [AXI_ADDR_WIDTH-1:0]                 m_axi_araddr,
     output logic  [((AXI_PROTOCOL == 1) ? 4 : 8)-1:0]  m_axi_arlen,
     output logic  [3-1:0]                              m_axi_arsize,
     output logic  [2-1:0]                              m_axi_arburst,
     output logic  [((AXI_PROTOCOL == 1) ? 2 : 1)-1:0]  m_axi_arlock,
     output logic  [4-1:0]                              m_axi_arcache,
     output logic  [3-1:0]                              m_axi_arprot,
     output logic  [4-1:0]                              m_axi_arregion,
     output logic  [4-1:0]                              m_axi_arqos,
     output logic  [AXI_ARUSER_WIDTH-1:0]               m_axi_aruser,
     output logic                                       m_axi_arvalid,
     input                                				m_axi_arready,
     
     // Subordinate Interface Read Data Ports
     input  logic  [AXI_ID_WIDTH-1:0]            		m_axi_rid,
     input 	logic  [AXI_DATA_WIDTH-1:0]                 m_axi_rdata,
     output logic [2-1:0]                              	m_axi_rresp,
     input  logic                                     	m_axi_rlast,
     input  logic [AXI_RUSER_WIDTH-1:0]                	m_axi_ruser,
     input								                m_axi_rvalid,
     output logic                                      	m_axi_rready,
     input 												status,
	 input 												status_a,
	 input [4:0]										channel,
	 input [4:0]										channel_a
	);
	localparam STALL   =`signal_stalling;
	
	bit ready_f=0;
	bit ready_k=0;
	bit valid_f=0;
	bit [AXI_DATA_WIDTH-1:0]rdata;
	bit [1:0]rresp;
	bit [2-1:0]bresp;
    reg rd_en_1d;
	int rready_counter=0;
	int bready_counter=0;
    int count; 
	bit rvalid_int;
	bit bvalid_int;
	
	reg internal_m_axi_awvalid=0;
	
    always @(posedge a_clk_i)
	begin
		if(~a_reset_n_i)
		begin
			m_axi_awvalid=0;
			m_axi_awid=0;
			m_axi_awaddr=0;
			m_axi_awlen=0;
			m_axi_awsize=0;
			m_axi_awburst=0;
			m_axi_awlock=0;
			m_axi_awcache=0;
			m_axi_awprot=0;
			m_axi_awregion=0;
			m_axi_awqos=0;
			m_axi_awuser=0;
			m_axi_awvalid=0;
			m_axi_arvalid=0;
			m_axi_arid=0;
			m_axi_araddr=0;
			m_axi_arlen=0;
			m_axi_arsize=0;
			m_axi_arburst=0;
			m_axi_arlock=0;
			m_axi_arcache=0;
			m_axi_arprot=0;
			m_axi_arregion=0;
			m_axi_arqos=0;
			m_axi_aruser=0;
			m_axi_arvalid=0;
			m_axi_wvalid=0;
		end
	end
	
	initial begin  ///used for toggling in light mode
	@(posedge m_axi_bvalid);
	bvalid_int =1;
	end
	initial begin
	@(posedge m_axi_rvalid);
	rvalid_int =1;
	end
	
	task write_addr_ready_before_valid();
	begin
		while(~a_reset_n_i)	
		begin
			m_axi_awvalid=0;	
			m_axi_wvalid=0;	
			m_axi_awaddr=0;
			m_axi_wdata=0;
		end
		@(posedge a_clk_i);
		
		if(AXI_ADDR_WIDTH/8==1)				m_axi_awsize=3'b000;
		else if(AXI_ADDR_WIDTH/8==2)		m_axi_awsize=3'b001;
		else if(AXI_ADDR_WIDTH/8==4)		m_axi_awsize=3'b010;
		else if(AXI_ADDR_WIDTH/8==8)		m_axi_awsize=3'b011;
		else if(AXI_ADDR_WIDTH/8==16)		m_axi_awsize=3'b100;
		else if(AXI_ADDR_WIDTH/8==32)		m_axi_awsize=3'b101;
		else if(AXI_ADDR_WIDTH/8==64)		m_axi_awsize=3'b110;
		else if(AXI_ADDR_WIDTH/8==128)		m_axi_awsize=3'b111;
		m_axi_awlock=$urandom_range(0,2);
		m_axi_awlen=0;
		
		if(AXI_SUPPORTS_USER_SIGNALS==1)	
		begin
			m_axi_awuser=$random();
			$display("USER SIGNAL=%h",m_axi_awuser);
			m_axi_wuser=$random();
			$display("USER SIGNAL=%h",m_axi_wuser);
		end
		else 
		begin
			m_axi_awuser = 0;
			m_axi_wuser = 0;
		end
		$display("TRANSACTION SIZE=%h",m_axi_awsize);
		$display("TRANSACTION ATOMICITY=%h",m_axi_awlock);
		$display("TRANSACTION BURST LENGTH=%h",m_axi_awlen);	
		ready_f = 0;
		count =0;
		//if(REG_CONFIG_AW == 0 || REG_CONFIG_AW ==2)
		begin
		  while (ready_f == 0) 
		  begin
		  	@(posedge a_clk_i);
		  	if (m_axi_awready ==1 )
		  	begin
		  		ready_f = 1;
		  		m_axi_awid=$urandom();
		        m_axi_wid=$urandom();
		  		m_axi_awvalid = 1;
		  		m_axi_wvalid = 1;
		  		m_axi_awaddr = $random();
		  		m_axi_wdata = $random();
		  		m_axi_wstrb = $random();
		  		$display("WRITE ADDRESS=%h",m_axi_awaddr);
		  		$display("WRITE DATA=%h",m_axi_wdata);
				if(m_axi_awlen == count) m_axi_wlast = 1;
				else count = count+1;
		  	end						
	      end	
	   end
	
	end
	endtask
	
/*	always @(posedge a_clk_i)
	begin
		if(channel == 'h10 && m_axi_awready==1)
			m_axi_awaddr = $random();
	end*/

	
	task read_addr_ready_before_valid();
	begin
		while(~a_reset_n_i)	
		begin
			m_axi_arvalid=0;		
			m_axi_araddr=0;
		end
		@(posedge a_clk_i);
		m_axi_arid=$urandom();
		if(AXI_ADDR_WIDTH/8==1)				m_axi_arsize=3'b000;
		else if(AXI_ADDR_WIDTH/8==2)		m_axi_arsize=3'b001;
		else if(AXI_ADDR_WIDTH/8==4)		m_axi_arsize=3'b010;
		else if(AXI_ADDR_WIDTH/8==8)		m_axi_arsize=3'b011;
		else if(AXI_ADDR_WIDTH/8==16)		m_axi_arsize=3'b100;
		else if(AXI_ADDR_WIDTH/8==32)		m_axi_arsize=3'b101;
		else if(AXI_ADDR_WIDTH/8==64)		m_axi_arsize=3'b110;
		else if(AXI_ADDR_WIDTH/8==128)		m_axi_arsize=3'b111;
		m_axi_arlock=$urandom_range(0,2);
		m_axi_arlen=0;
		if(AXI_SUPPORTS_USER_SIGNALS==1)	
		begin
			m_axi_aruser=$random();
			$display("USER SIGNAL=%h",m_axi_aruser);
		end
		else m_axi_aruser =0;
		$display("TRANSACTION SIZE=%h",m_axi_arsize);
		$display("TRANSACTION ATOMICITY=%h",m_axi_arlock);
		$display("TRANSACTION BURST LENGTH=%h",m_axi_arlen);	
		ready_f = 0;
		while (ready_f == 0) 
		begin
			@(posedge a_clk_i);
			if (m_axi_arready ==1) 
			begin
				ready_f = 1;
				m_axi_arvalid = 1;
				m_axi_araddr = $random();
				if(AXI_SUPPORTS_USER_SIGNALS==1)	
				begin
					m_axi_aruser=$random();
					$display("USER SIGNAL=%h",m_axi_aruser);
				end
				$display("READ ADDRESS=%h",m_axi_araddr);
			end						
		end	
	end
	endtask	


	//READ_DATA
	always @(posedge a_clk_i)
	begin
		if(~a_reset_n_i)	
        begin
			m_axi_rready=0;
			
        end
        else
        begin
			if(status==`long_ready&&channel_a==8'h01)
			begin
				 m_axi_rready=(rready_counter<19&&rvalid_int==1)?1:0;
				 rready_counter= (rready_counter==20)?0:rready_counter+1;		//added for ready toggling
			end
			if(status==`ready_first&&channel_a==8'h01)
			begin	
				
					m_axi_rready=(rready_counter<1&&rvalid_int==1)?1:0;
					rready_counter= (rready_counter==2)?0:rready_counter+1;
				
				
			end
	
		end
	end
	
	//WRITE_RESPONSE
	always @(posedge a_clk_i)
	begin
		if(~a_reset_n_i)	
        begin
			m_axi_bready=0;
        end
        else
        begin
			if(status==`long_ready&&channel==8'h04)
			begin
				 m_axi_bready=(bready_counter<19&&bvalid_int==1)?1:0;
				 bready_counter= (bready_counter==20)?0:bready_counter+1;
			end
			if(status==`ready_first&&channel==8'h04)
			begin	
				
				begin
					m_axi_bready=(bready_counter<1&&bvalid_int==1)?1:0;
					bready_counter= (bready_counter==2)?0:bready_counter+1;
			    end
			
			end
	
		end
		if(channel!=8'h04 && status==0)	m_axi_bready=0;
	end
	
	
	
endmodule	
	

