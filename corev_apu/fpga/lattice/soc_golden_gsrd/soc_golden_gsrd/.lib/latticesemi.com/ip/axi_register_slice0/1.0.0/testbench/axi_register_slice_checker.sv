//========================================================//
//=======================DATA CHECKER=====================//
//========================================================//
`timescale 1ns/1ns
`define valid_first 0				//status
`define ready_first 1
module axi_register_slice_checker #
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
     input         									   a_clk_i,
     input         									   a_reset_n_i,
     input 		                                 	   m_valid,
	 input 		                                 	   m_ready,
	 input		[AXI_ADDR_WIDTH-1:0]			  	   m_data,
	 input 		                                 	   s_valid,
	 input 		                                 	   s_ready,
     input		[AXI_ADDR_WIDTH-1:0]			  	   s_data,
	 input		[4:0]								   channel,	
	  input 		                                   m_valid_a,
	 input 		                                 	   m_ready_a,
	 input		[AXI_ADDR_WIDTH-1:0]			  	   m_data_a,
	 input 		                                 	   s_valid_a,
	 input 		                                 	   s_ready_a,
     input		[AXI_ADDR_WIDTH-1:0]			  	   s_data_a,
	 input		[4:0]								   channel_a,
     input 	                                           status
	);
	
    reg 		 [31:0]manager_data[$];
	reg 		 [31:0]subordinate_data[$];
	reg 		 [31:0]manager_data_a[$];
	reg 		 [31:0]subordinate_data_a[$];
	reg 		  protocol_counter=0;

	bit			  first_bubble_counter=0;    //changed from int to bit for coverage

	
	bit				s_valid_o;
	bit				s_ready_o;
		
	bit				s_valid_os;
	bit				s_ready_os;
	

//=============================================================================//
//=================================PROTOCOL CHECKER============================//
//=============================================================================//
		

	always @(posedge a_clk_i)
	begin
	//====================WRITE ADDRESS CHANNEL=======================//
		if(channel==8'h10)//&&status!=3)
		begin
			//====================FULL WEIGHT====================//
			if(REG_CONFIG_AW==0)
			begin
				if(m_valid==1)
				begin
					@(posedge a_clk_i);
					if(s_valid==0)						
					begin
						if(a_reset_n_i)	
						begin 
							$error("LATENCY ADDITION FAILED");
							$finish;
						end
						else			protocol_counter=0;
					end		
				end
			end
			//====================HALF WEIGHT====================//
			else if(REG_CONFIG_AW==1)
			begin
				if(m_valid==1&&m_ready==1)
				begin
					@(posedge a_clk_i);
					if(s_valid==0)			
					begin
						$error("LATENCY ADDITION FAILED");
						$finish;
					end
					s_valid_o=s_valid;
					s_ready_o=s_ready;
					@(posedge a_clk_i);
					if(m_ready==1)
					begin
						if(s_valid!=~s_valid_o)	//s_ready_o is the value at one clock back
						begin
							$error("BUBBLE CYCLE ADDITION FAILED");
							$finish;
						end
					end
				end
			
			end
			//====================REGISTERED INPUT====================//
			else if(REG_CONFIG_AW==2)
			begin
				if(m_valid==1 && m_ready==1)  //changed m_ready==1fro reset test input
				begin
					@(posedge a_clk_i);
					if(s_valid==0)											
					begin
						if(a_reset_n_i)	
						begin
							$error("LATENCY ADDITION FAILED");
							$finish;
						end
						else			protocol_counter=0;
					end			
				end
			end		
		end
	//=======================WRITE DATA CHANNEL============================//
		else if(channel_a==8'h08)
		begin
			//====================FULL WEIGHT====================//
			if(REG_CONFIG_W==0)
			begin
				if(m_valid_a==1)
				begin
					@(posedge a_clk_i);
					if(s_valid_a==0)	
					begin
						$error("LATENCY ADDITION FAILED");
						$finish;
					end
				end
			end
			//====================HALF WEIGHT====================//
			else if(REG_CONFIG_W==1)
			begin
		//		if(AXI_PROTOCOL!=2)	$error("HALF WEIGHT IS NOT SUPPORTED IN WRITE DATA CHANNEL");
		//		else
				begin
					if(m_valid_a==1&&m_ready_a==1)
					begin
						@(posedge a_clk_i);
						if(s_valid_a==0)			
						begin
							$error("LATENCY ADDITION FAILED");
							$finish;
						end
						s_valid_os=s_valid_a;
						s_ready_os=s_ready_a;
						@(posedge a_clk_i);
						if(m_ready_a==1)
						begin
							if(s_valid_a!=~s_valid_os)	//s_ready_o is the value at one clock back
							begin
								$error("BUBBLE CYCLE ADDITION FAILED");
								$finish;
							end
						end
					end
				end		
			end
			//====================REGISTERED INPUT====================//
			else if(REG_CONFIG_W==2)
			begin
				if(m_valid_a==1)
				begin
					@(posedge a_clk_i);
					if(s_valid_a==0)	
					begin
						$error("LATENCY ADDITION FAILED");	
						$finish;
					end
				end
			end		
		end
	//====================WRITE RESPONSE CHANNEL=======================//
		else if(channel==8'h04)
		begin
			//====================FULL WEIGHT====================//
			if(REG_CONFIG_B==0)
			begin
				if(m_valid==1)
				begin
					@(posedge a_clk_i);
					if(s_valid==0)	
					begin
						$error("LATENCY ADDITION FAILED");	
						$finish;
					end
				end
			end
			//====================HALF WEIGHT====================//
			else if(REG_CONFIG_B==1)
			begin
				if(m_valid==1 && m_ready==1)   //changed
				begin
					@(posedge a_clk_i);
					if(s_valid==0)	
					begin
						$error("LATENCY ADDITION FAILED");
						$finish;
					end
					@(posedge a_clk_i);
					
					if(s_valid==0 && first_bubble_counter==0)	
					begin
						first_bubble_counter=first_bubble_counter+1;
					end
					else if(s_valid==1 && first_bubble_counter>0)	$error("BUBBLE CYCLE ADDITION FAILED");
				end
			end
			//====================REGISTERED INPUT====================//
			else if(REG_CONFIG_B==2)
			begin
				if(m_valid==1)
				begin
					@(posedge a_clk_i);
					if(s_valid==0)	
					begin
						$error("LATENCY ADDITION FAILED");	
						$finish;
					end
				end
			end		
		end
	//====================READ ADDRESS CHANNEL=======================//
		else if(channel==8'h02)//&&status!=3)
		begin
			//====================FULL WEIGHT====================//
			if(REG_CONFIG_AR==0)
			begin
				if(m_valid==1)
				begin
					@(posedge a_clk_i);
					if(s_valid==0)	
					begin
						$error("LATENCY ADDITION FAILED");		
						$finish;
					end
				end
			end
			//====================HALF WEIGHT====================//
			else if(REG_CONFIG_AR==1)
			begin
				if(m_valid==1&&m_ready==1)//&&valid_constant==0)
				begin
					@(posedge a_clk_i);
					if(s_valid==0)			
					begin
						$error("LATENCY ADDITION FAILED");
						$finish;
					end
					s_valid_o=s_valid;
					s_ready_o=s_ready;
					@(posedge a_clk_i);
					if(m_ready==1)
					begin
						if(s_valid!=~s_valid_o)	//s_ready_o is the value at one clock back
						begin
							$error("BUBBLE CYCLE ADDITION FAILED");
							$finish;
						end
					end
				end
			end
			//====================REGISTERED INPUT====================//
			else if(REG_CONFIG_AR==2)
			begin
				if(m_valid==1)
				begin
					@(posedge a_clk_i);
					if(s_valid==0)	
					begin
						$error("LATENCY ADDITION FAILED");		
						$finish;
					end
				end
			end		
		end
	//====================READ DATA CHANNEL=======================//
		else if(channel==8'h01)//&&status!=3)
		begin
			//====================FULL WEIGHT====================//
			if(REG_CONFIG_R==0)
			begin
				if(m_valid==1)
				begin
					@(posedge a_clk_i);
					if(s_valid==0)	
					begin
						$error("LATENCY ADDITION FAILED");
						$finish;
					end
				end
			end
			//====================HALF WEIGHT====================//
			else if(REG_CONFIG_R==1)
			begin
				if(AXI_PROTOCOL!=2)	$error("HALF WEIGHT IS NOT SUPPORTED IN READ DATA CHANNEL");
				else
				begin
					if(m_valid==1&&m_ready==1)
					begin
						@(posedge a_clk_i);
						if(s_valid==0)			
						begin
							$error("LATENCY ADDITION FAILED");
							$finish;
						end
						s_valid_o=s_valid;
						s_ready_o=s_ready;
						@(posedge a_clk_i);
						if(m_ready==1)
						begin
							if(s_valid!=~s_valid_o)	//s_ready_o is the value at one clock back
							begin
								$error("BUBBLE CYCLE ADDITION FAILED");
								$finish;
							end
						end
					end
				
				end
			end
			//====================REGISTERED INPUT====================//
			else if(REG_CONFIG_R==2)
			begin
				if(m_valid==1)
				begin
					@(posedge a_clk_i);
					if(s_valid==0)	
					begin
						$error("LATENCY ADDITION FAILED");	
						$finish;
					end
				end
			end		
		end
	end
//=============================================================================//	
	
//=============================================================================//		
//==================================DATA CHECKER================================//
//=============================================================================//	
	always @(posedge a_clk_i)
	begin
		if(a_reset_n_i)
		begin
			if(channel==8'h04)								//write response
			begin
				if(m_valid==1&& m_ready==1)
				begin
					manager_data.push_back(m_data);
				end
				if(s_valid==1&& s_ready==1&&s_data!==32'hx)
				begin
					subordinate_data.push_back(s_data);
				end
			end
			else
			begin
				first_bubble_counter=0;
				if(m_valid==1&& m_ready==1)
				begin
					manager_data.push_back(m_data);
				end
				if(s_valid==1&& s_ready==1&&s_data!==32'hx && s_data!==0)
				begin
					begin
						subordinate_data.push_back(s_data);
					end
				end
			end	
			if(manager_data.size()>0 && subordinate_data.size()>0)
			begin
				if(manager_data[0]==subordinate_data[0])			
				begin
					//$display("======================================================");
					$display("DATA FROM MANAGER=%h AND SUB-ORDINATE=%h IS MATCHING",manager_data[0],subordinate_data[0]);
					//$display("======================================================");
					manager_data.delete(0);
					subordinate_data.delete(0);
				end
				else							
				begin
					$display("======================================================");
					$display("DATA FROM MANAGER=%h AND SUB-ORDINATE=%h IS MIS-MATCHING",manager_data[0],subordinate_data[0]);
					$display("======================================================");
					$display("================================================================");
					$display("*************************TESTCASE FAILED************************");
					$display("================================================================");
					
					$finish;			
				end
			end
		end
	end
	
	always @(posedge a_clk_i)
	begin
		if(a_reset_n_i)
		begin
			
				//second_bubble_counter=0;
				if(m_valid_a==1&& m_ready_a==1)
				begin
					manager_data_a.push_back(m_data_a);
				end
				if(s_valid_a==1&& s_ready_a==1&&s_data_a!==32'hx && s_data_a!==0)
				begin
					begin
						subordinate_data_a.push_back(s_data_a);
					end
				end
			end	
			if(manager_data_a.size()>0 && subordinate_data_a.size()>0)
			begin
				if(manager_data_a[0]==subordinate_data_a[0])			
				begin
					//$display("======================================================");
					$display("DATA FROM MANAGER=%h AND SUB-ORDINATE=%h IS MATCHING",manager_data_a[0],subordinate_data_a[0]);
					//$display("======================================================");
					manager_data_a.delete(0);
					subordinate_data_a.delete(0);
				end
				else							
				begin
					$display("======================================================");
					$display("DATA FROM MANAGER=%h AND SUB-ORDINATE=%h IS MIS-MATCHING",manager_data_a[0],subordinate_data_a[0]);
					$display("======================================================");
					$display("================================================================");
					$display("*************************TESTCASE FAILED************************");
					$display("================================================================");
					
					$finish;			
				end
			
		end
	end
			
endmodule
