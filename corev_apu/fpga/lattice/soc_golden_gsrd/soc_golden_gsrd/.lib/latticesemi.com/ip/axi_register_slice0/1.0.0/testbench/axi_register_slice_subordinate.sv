//=======================================================//
//=================AXI SLICE SUBORDINATE=================//
//=======================================================//
`define long_ready	0
`define ready_first	1

`define signal_stalling	13
`timescale 1ns/1ns

module axi_register_slice_subordinate #                             
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
      // Global clock signal
      input a_clk_i, 
      // Global Reset Signal and this Signal is Active LOW      
      input a_reset_n_i,
      input number_of_delays,
//==================WRITE ADDRESS CHANNEL==================//
      input	[AXI_ID_WIDTH-1:0]					 s_axi_awid,
      input [((AXI_PROTOCOL == 1) ? 4 : 8)-1:0]  s_axi_awlen,
      input [3-1:0]                              s_axi_awsize,
      input [2-1:0]                              s_axi_awburst,
      input [((AXI_PROTOCOL == 1) ? 2 : 1)-1:0]  s_axi_awlock,
      input [4-1:0]                              s_axi_awcache,
      input [4-1:0]                              s_axi_awregion,
      input [4-1:0]                              s_axi_awqos,
      input [AXI_AWUSER_WIDTH-1:0]               s_axi_awuser,
      // This signal indicate that master has write address                                                        
      input										 s_axi_awvalid,
      // This signal indicate slave is ready to accept write address      
      output reg 								 s_axi_awready,  
      // write address        
      input [AXI_ADDR_WIDTH-1:0] 				 s_axi_awaddr,
      //This signal indicates the privilege and security level of the transaction,
      // and weather transaction is a data access or an instruction access.
      input [2 : 0] 							 s_axi_awprot=0,
      
//====================WRITE DATA CHANNEL=================//
      input [((AXI_PROTOCOL == 1) ? 4 : 1)-1:0]  s_axi_wid,
      input                                      s_axi_wlast,
      input [AXI_WUSER_WIDTH-1:0]                s_axi_wuser,
      // This signal indicate that master has data which has to write        
      input 									 s_axi_wvalid,
      // slave is ready to accept the write data      
      output reg 								 s_axi_wready, 
      // write data      
      input [AXI_DATA_WIDTH-1:0] 				 s_axi_wdata,
      // There is one write strobe bit for each each byte of data of the write data bus      
      input [(AXI_DATA_WIDTH/8)-1:0] 			 s_axi_wstrb,
      
//==================WRITE RESPONSE CHANNEL================//
      output logic[AXI_ID_WIDTH-1:0]              s_axi_bid,
      output logic [AXI_BUSER_WIDTH-1:0]          s_axi_buser,
      // This signal indicate the status of write transaction by slave
      output reg [1:0]							 s_axi_bresp,
      // This signal indicates that write response is present at slave      
      output reg 								 s_axi_bvalid,
      // Master is ready to accept the write response      
      input 									 s_axi_bready,  
      
      // write data from adapter to register array(slave)
      output reg[AXI_DATA_WIDTH-1:0] 			wr_data_out,
      // write address from adapter to array of 8 register      
      output reg [2:0] 							wr_addr_out,
      // This signal indicates when to write in register array      
      output wire wr_en, 
      
//====================READ ADDRESS CHANNEL=================//
      input [AXI_ID_WIDTH-1:0]                   s_axi_arid,
      input [((AXI_PROTOCOL == 1) ? 4 : 8)-1:0]  s_axi_arlen,
      input [3-1:0]                              s_axi_arsize,
      input [2-1:0]                              s_axi_arburst,
      input [((AXI_PROTOCOL == 1) ? 2 : 1)-1:0]  s_axi_arlock,
      input [4-1:0]                              s_axi_arcache,
      input [4-1:0]                              s_axi_arqos,
	  input [4-1:0]                         	 s_axi_arregion,
      input [AXI_ARUSER_WIDTH-1:0]               s_axi_aruser,
      // This signal indicates master has read address 
      input 									 s_axi_arvalid,
      // This signal indicates slave is ready to accept read address      
      output reg 								 s_axi_arready,
      // read address      
      input [AXI_ADDR_WIDTH-1:0] 				 s_axi_araddr,
      //This signal indicates the privilege and security level of the transaction,
      // and weather transaction is a data access or an instruction access.
      input [2 : 0] s_axi_arprot,
      
//=====================READ DATA CHANNEL====================//
      output logic [AXI_ID_WIDTH-1:0]                    s_axi_rid,
      output logic                                       s_axi_rlast,
      output logic [AXI_RUSER_WIDTH-1:0]                 s_axi_ruser,
      // This signal indicates data is present at read data bus                                                        
      output reg 								  s_axi_rvalid,
      // Master is ready to take the data      
      input 									  s_axi_rready,
      // read data from the adapter to master
      output reg [AXI_DATA_WIDTH-1:0] 			  s_axi_rdata,
      // read response from the slave      
      output reg[1:0] 							  s_axi_rresp,
      
	  input										  status,
	  input [4:0] 								  channel,
	   input [4:0] 								  channel_a
	 
   );
   
   localparam STALL   =`signal_stalling;
   // This signal indicates write address has been latched to slave
	reg wr_addr_done;
   // This signal indicates write data has been latched to slave
	reg wr_data_done;
	reg wr_en_1d;
	reg rd_en_1d;
	bit ready_f=0;
   	bit [2-1:0]bresp;
	int ready_counter=0;
	int awready_counter=0;
	int arready_counter=0;
	int count;
	bit awvalid_int;
	bit arvalid_int;
	bit wvalid_int;
	
	initial begin  ///used for toggling in light mode
	@(posedge s_axi_awvalid);
	awvalid_int =1;
	end
	initial begin
	@(posedge s_axi_wvalid);
	wvalid_int =1;
	end
	initial begin
	@(posedge s_axi_arvalid);
	arvalid_int =1;
	end
	always @(posedge a_clk_i)
	begin
		if(~a_reset_n_i)
		begin
			s_axi_bvalid=0;
			s_axi_rvalid=0;
		end
	end

    always @(posedge a_clk_i)
	begin
		if(~a_reset_n_i)	
        begin
			s_axi_awready=0;
			s_axi_wready=0;
        end
        else
        begin
			if(status==`long_ready&&channel==8'h10)
			begin
				 s_axi_awready=(awready_counter<19&&awvalid_int==1)?1:0;
				 awready_counter= (awready_counter==20)?0:awready_counter+1;
				 s_axi_wready=(ready_counter<19&&wvalid_int==1)?1:0;
				 ready_counter= (ready_counter==20)?0:ready_counter+1;
				 
			end
			if(status==`ready_first&&channel==8'h10)
			begin	
           
				  begin					
				  	s_axi_awready=(awready_counter<1&&awvalid_int==1)?1:0;
				  	awready_counter= (awready_counter==2)?0:awready_counter+1;
				    s_axi_wready=(ready_counter<1&&wvalid_int==1)?1:0;
				  	ready_counter= (ready_counter==2)?0:ready_counter+1;
				  end
				 
			end
	    end
	end

	always @(posedge a_clk_i)
	begin
		if(~a_reset_n_i)	
        begin
			s_axi_arready=0;
        end
        else
        begin
			if(status==`long_ready&&channel==8'h02)
			begin
				s_axi_arready=(arready_counter<19&&arvalid_int==1)?1:0;
				arready_counter= (arready_counter==20)?0:arready_counter+1;
			end
			if(status==`ready_first&&channel==8'h02)
			begin	
				
					s_axi_arready=(arready_counter<1&&arvalid_int==1)?1:0;
					arready_counter= (arready_counter==2)?0:arready_counter+1;
			
			end
		
		end
	end
     
	
	
	
  
   task read_data_ready_before_valid();
	begin
		while(~a_reset_n_i)	
		begin
			s_axi_rvalid=0;		
			s_axi_rdata=0;
		end
		@(posedge a_clk_i);
		s_axi_rid=$urandom();
	
		if(AXI_SUPPORTS_USER_SIGNALS==1)	
		begin
			s_axi_ruser=$random();
			$display("USER SIGNAL=%h",s_axi_ruser);
		end
	
		ready_f = 0;	
		while (ready_f == 0) 
		begin
			@(posedge a_clk_i);
			if (s_axi_rready ==1) 
			begin
				ready_f = 1;
				s_axi_rvalid = 1;
				s_axi_rdata = $random();
				s_axi_rresp = $random();
				if(AXI_SUPPORTS_USER_SIGNALS==1)	
				begin
					s_axi_ruser=$random();
					$display("USER SIGNAL=%h",s_axi_ruser);
				end
				
				else s_axi_ruser = 0;
				$display("READ DATA=%h",s_axi_rdata);
			end						
		end
      		
		
	end
	endtask
	
	
	
	task write_resp_ready_before_valid();
	begin
			while(~a_reset_n_i)	
		begin
			s_axi_bvalid=0;		
			s_axi_bresp=0;
		end
		@(posedge a_clk_i);
		s_axi_bid = $random();
	
		if(AXI_SUPPORTS_USER_SIGNALS==1)	
		begin
			s_axi_buser=$random();
			$display("USER SIGNAL=%h",s_axi_buser);
		end
	
		ready_f = 0;
		while (ready_f == 0) 
		begin
			@(posedge a_clk_i);
			if (s_axi_bready ==1) 
			begin
				ready_f = 1;
				s_axi_bvalid = 1;
				s_axi_bresp = $random();
				if(AXI_SUPPORTS_USER_SIGNALS==1)	
				begin
					s_axi_buser=$random();
					$display("USER SIGNAL=%h",s_axi_buser);
				end
				else s_axi_buser = 0;
				$display("WRITE RESPONSE =%h",s_axi_bresp);
			end						
		
						
		end	
	end
    endtask
	
	


 endmodule 
