// --------------------------------------------------------------------
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
// --------------------------------------------------------------------
// Copyright (c) 2005 by Lattice Semiconductor Corporation
// --------------------------------------------------------------------
//
//
//                     Lattice Semiconductor Corporation
//                     5555 NE Moore Court
//                     Hillsboro, OR 97214
//                     U.S.A.
//
//                     TEL: 1-800-Lattice  (USA and Canada)
//                          1-408-826-6000 (other locations)
//
//                     web: http://www.latticesemi.com/
//                     email: techsupport@latticesemi.com
//
// --------------------------------------------------------------------
//
// Simulation Library File for Dual Port Block RAM PMI Block
//
// Parameter Definition
//Name			Value						Default
/*
--------------------------------------------------------------------------------
pmi_wr_addr_depth	<integer>					512
pmi_wr_addr_width       <integer>                                       9
pmi_wr_data_width	<integer>					18
pmi_rd_addr_depth	<integer>					512
pmi_rd_addr_width       <integer>                                       9
pmi_rd_data_width	<integer>					18
pmi_regmode		"reg"|"noreg"					"reg"
pmi_gsr			"enable"|"disable"				"enable"
pmi_resetmode		"async"|"sync"					"async"
pmi_init_file		<string>					"none"
pmi_init_file_format	"binary"|"hex"					"binary"
pmi_family		"EC"|"EC2"|"XP"|"SC"|"ECP"|"ECP2"|"XO"		"EC"
--------------------------------------------------------------------------------
WARNING: Do not change the default parameters in this model. Parameter 
redefinition must be done using defparam or in-line (#) paramater 
redefinition in a top level file that instantiates this model.
 
*/
// $Header: ./soft_ip/jedi_launch/tse_mac/testbench/pmi_ram_dp_sim.v 1 2019/12/06 09:04:37 GMT redillor Exp $
`ifndef  PMI_RAM_DP
`define  PMI_RAM_DP


`timescale 1ns/1ps
module pmi_ram_dp_sim
 #(parameter pmi_wr_addr_depth = 512,
   parameter pmi_wr_addr_width = 9,
   parameter pmi_wr_data_width = 18,
   parameter pmi_rd_addr_depth = 512,
   parameter pmi_rd_addr_width = 9,
   parameter pmi_rd_data_width = 18,
   parameter pmi_regmode = "noreg",
   parameter pmi_gsr = "enable",
   parameter pmi_resetmode = "async",
   parameter pmi_init_file = "none",
   parameter pmi_init_file_format = "binary",
   parameter pmi_family = "EC",
   parameter module_type = "pmi_ram_dp")

   (input [(pmi_wr_data_width-1):0] Data,
    input [(pmi_wr_addr_width-1):0] WrAddress,
    input [(pmi_rd_addr_width-1):0] RdAddress,
    input  WrClock,
    input  RdClock,
    input  WrClockEn,
    input  RdClockEn,
    input  WE,
    input  Reset,
    output [(pmi_rd_data_width-1):0]  Q);/*synthesis syn_black_box */

//pragma translate_off
   localparam array_size_wr = pmi_wr_addr_depth * pmi_wr_data_width;
   localparam array_size_rd = pmi_rd_addr_depth * pmi_rd_data_width;

   
   reg [pmi_wr_data_width-1:0] mem [(2**pmi_wr_addr_width)-1:0];
   
     
//Define internal Signals

   reg [(pmi_wr_data_width-1):0]   Data_reg = 0;
   reg [(pmi_wr_addr_width-1):0]   WrAddress_reg = 0;
   reg [(pmi_rd_addr_width-1):0]   RdAddress_reg = 0;
   reg 				   WE_reg = 0;
   
   reg [(pmi_wr_data_width-1):0]   Data_reg_async;
   reg [(pmi_wr_addr_width-1):0]   WrAddress_reg_async;
   reg [(pmi_rd_addr_width-1):0]   RdAddress_reg_async;
   reg 				   WE_reg_async;
   
   reg [(pmi_wr_data_width-1):0]   Data_reg_sync;
   reg [(pmi_wr_addr_width-1):0]   WrAddress_reg_sync;
   reg [(pmi_rd_addr_width-1):0]   RdAddress_reg_sync;
   reg 				   WE_reg_sync;

   reg [(pmi_rd_data_width-1):0]   Q_int = 0;
  
   reg [(pmi_rd_data_width-1):0]   Q_reg;
   reg [(pmi_rd_data_width-1):0]   Q_reg_sync;
   reg [(pmi_rd_data_width-1):0]   Q_reg_async;

  
   integer 				h, l, m, l_plus_m, l_plus_m_div_a;

   reg 					memchg = 0;
   
   reg WrClock_valid = 0;
   reg RdClock_valid = 0;
   reg RdClock_valid_new1;

   reg [pmi_wr_data_width-1:0] dummy_wa, dummy_wa2b;
   reg [pmi_rd_data_width-1:0] dummy_wb;
   
   reg [(pmi_rd_data_width-1):0] QQ;
   reg 				 SRN;

   assign 			 Q = QQ;
      
   //Function to calculate log2 of depth   
 function  integer clogb2 (input integer depth);
    begin
        for(clogb2=0; depth>0;  clogb2=clogb2+1)
             depth=depth>>>1;
    end
 endfunction // clogb2					

   //Error Check
   initial begin
      if(array_size_wr !== array_size_rd) begin
	$display("\nError! Total value of (Address Depth * Data Width) must be the same for Write and Read ports!");
      $stop;
      end
   end

   //Check for Address_width vs Address_depth
initial begin
   if (clogb2(pmi_wr_addr_depth-1) > pmi_wr_addr_width) begin
       $display("\nError! Address depth of Write Port can not exceed (2**pmi_wr_addr_width)!");
       $stop;
   end
   
   if (clogb2(pmi_rd_addr_depth-1) > pmi_rd_addr_width) begin
       $display("\nError! Address depth of Read Port can not exceed (2**pmi_rd_addr_width)!");
       $stop;
   end
end

//Check if Ratio of Write Port/Read Port or Read Port/Write Port Data widths is a power of 2.
//Module Manager supports 1, 2, 4, 8 and 16 only.

initial begin
   if (pmi_wr_data_width > pmi_rd_data_width)
     begin
	  if ((pmi_wr_data_width / pmi_rd_data_width) >16)
	    begin
	       $display("\nError! The ratio of Write and Read Data width values can not be greater than 16!");
	       $stop;
	    end
	  else if ( (pmi_wr_data_width / pmi_rd_data_width !== 2) && (pmi_wr_data_width / pmi_rd_data_width !== 4) && (pmi_wr_data_width / pmi_rd_data_width !== 8) && (pmi_wr_data_width / pmi_rd_data_width !== 16))
	    begin
	     $display("\nError! The ratio of Write Port and Read Port Data widths is: %d !", pmi_wr_data_width / pmi_rd_data_width);
 	     $display("Error! It must be a power of 2!");
	     $stop;
	    end
     end
   else if (pmi_wr_data_width < pmi_rd_data_width)
     begin
	if ((pmi_rd_data_width / pmi_wr_data_width) >16)
	    begin
	       $display("\nError! The ratio of Read and Write Data width values can not be greater than 16!");
	       $stop;
	    end
	  else if ( (pmi_rd_data_width / pmi_wr_data_width !== 2) && (pmi_rd_data_width / pmi_wr_data_width !== 4) && (pmi_rd_data_width / pmi_wr_data_width !== 8) && (pmi_rd_data_width / pmi_wr_data_width !== 16))
	    begin
	     $display("\nError! The ratio of Read Port and Write Port Data widths is: %d !", pmi_rd_data_width / pmi_wr_data_width);
 	     $display("Error! It must be a power of 2!");
	     $stop;
	    end
	end
end // initial begin

//initialize the Memory. 
//X for SC, 0 for other families.
initial begin
   if ((pmi_init_file == "none") && (pmi_family == "SC")) begin
      for (h = 0; h < 2**pmi_wr_addr_width; h = h+1)
      	begin
	   mem[h] = {pmi_wr_data_width{1'bx}};
        end // for (h = 0; h < 2**pmi_wr_addr_width; h = h+1)
      end
       else
       if ((pmi_init_file == "none") && (pmi_family != "SC")) begin
	   for (h = 0; h < 2**pmi_wr_addr_width; h = h+1) 
	   begin
	    mem[h] = {pmi_wr_data_width{1'b0}};
           end // for (h = 0; h < 2**pmi_wr_addr_width; h = h+1)
           end	   
       
       else if ((pmi_init_file_format == "binary") && (pmi_init_file != "none"))
       begin
       $readmemb(pmi_init_file, mem);
       end
       else
       if ((pmi_init_file_format == "hex") && (pmi_init_file != "none")) 
       begin
       $readmemh(pmi_init_file, mem);
       end
end // initial begin
   
   not (SR1, SRN);
   or INST1 (Reset_sig, Reset, SR1);

   always @(SR1, Data, WrAddress, WE)
     begin
	if (SR1 == 1)
	  begin
	     assign Data_reg = 0;
	     assign WrAddress_reg = 0;
	     assign WE_reg = 0;
	  end
	else begin
	   deassign Data_reg;
	   deassign WrAddress_reg;
	   deassign WE_reg;
	end // else: !if(SR1 == 1)
     end //


   always @(posedge WrClock)
     begin
	if (Reset_sig == 1)
	  WrClock_valid <=0;
	else
	  begin
	     if (WrClockEn == 1)
	       begin
	     WrClock_valid <= 1;
	     #0.010 WrClock_valid <= 0;
	       end
	  end
     end
   
   always @(posedge RdClock)
     begin
	if (Reset_sig == 1)
	  RdClock_valid <=0;
	else
	  begin
	     if (RdClockEn == 1)
	       begin
	     RdClock_valid <= 1;
	     #0.010 RdClock_valid <= 0;
	       end
	  end
     end

//Asynchronous Reset   
   always @(posedge WrClock, posedge Reset_sig)
     begin
	if (Reset_sig == 1)
	  begin
	     Data_reg_async <= 0;
	     WrAddress_reg_async <= 0;
	     WE_reg_async <= 0;
	  end
	else
	  begin
	     if (WrClockEn == 1) 
	       begin
		  Data_reg_async <= Data;
		  WrAddress_reg_async <= WrAddress;
		  WE_reg_async <= WE;
	       end
	     
	  end // else: !if(Reset_sig)
     end // always @ (posedge WrClock, posedge Reset)

   always @(posedge RdClock, posedge Reset_sig)
     begin
	if (Reset_sig == 1)
	  begin
	     RdAddress_reg_async <= 0;
	     Q_reg_async <= 0;
	  end
	else
	  begin
	     if (RdClockEn == 1) 
	       begin
		  RdAddress_reg_async <= RdAddress;
		  Q_reg_async <= Q_int;
	       end
	     
	    end // else: !if(Reset)
     end // always @ (posedge RdClockB, posedge Reset)
   
//Synchronous Reset   
   always @(posedge WrClock)
     begin
	if (Reset_sig == 1)
	  begin
	     Data_reg_sync <= 0;
	     WrAddress_reg_sync <= 0;
	     WE_reg_sync <= 0;
	  end
	else
	  begin
	     if (WrClockEn == 1) 
	       begin
		  Data_reg_sync <= Data;
		  WrAddress_reg_sync <= WrAddress;
		  WE_reg_sync <= WE;
		end  
	  end // else: !if(Reset)
     end // always @ (posedge WrClock)

   always @(posedge RdClock)
     begin
	if (Reset_sig == 1)
	  begin
	     RdAddress_reg_sync <= 0;
	     //Q_reg_sync <= 0;
	  end
	else
	  begin
	     if (RdClockEn == 1) 
	       begin
		  RdAddress_reg_sync <= RdAddress;
		  //Q_reg_sync <= Q_int;
	       end
	   end // else: !if(Reset)
     end // always @ (posedge RdClockB)  

//Synchronous Reset for Data Out. ClockEn gets precedence over Reset.
   always @(posedge RdClock)
     begin
	if (RdClockEn == 1)
	  begin
	    if (Reset_sig == 1)
	      Q_reg_sync <= 0;
	    else
	      Q_reg_sync <= Q_int;
	  end
     end
   
//Choice between async/sync resetmode
   
   always @(Data_reg_sync, WrAddress_reg_sync, WE_reg_sync, Data_reg_async, WrAddress_reg_async, WE_reg_async, Q_reg_async, Q_reg_sync) begin
      if (pmi_resetmode == "async")
	begin
	   Data_reg = Data_reg_async;
	   WrAddress_reg = WrAddress_reg_async;
	   WE_reg = WE_reg_async;
	end
      else
	begin
	   Data_reg = Data_reg_sync;
	   WrAddress_reg = WrAddress_reg_sync;
	   WE_reg = WE_reg_sync;
	end // else: !if(pmi_resetmode == "async")
   end 
   
   always @(RdAddress_reg_sync, RdAddress_reg_async, Q_reg_async, Q_reg_sync ) begin
      if (pmi_resetmode == "async")
	begin
	   RdAddress_reg = RdAddress_reg_async;
	   Q_reg = Q_reg_async;
	end
      else
	begin
	   RdAddress_reg = RdAddress_reg_sync;
	   Q_reg = Q_reg_sync;
	end // else: !if(pmi_resetmode == "async")
   end 

//Write Operation

   always @(WE_reg, WrAddress_reg, Data_reg, WrClock_valid)
     begin
	memchg = ~memchg;
	if (WE_reg == 1 && WrClock_valid == 1) 
	  begin
	     mem[WrAddress_reg] = Data_reg;
	  end // if (WrA_reg)
	
     end // 

//Read Operation
   
   always @(posedge Reset, RdClock_valid, RdClock, memchg, mem[RdAddress_reg])
     begin
	if (Reset_sig == 1)
	  Q_int = 0;
	  else if (RdClock_valid == 1)
	    begin
	      if (pmi_wr_data_width == pmi_rd_data_width) 
		 Q_int = mem[RdAddress_reg];
		 
	      else begin // if (pmi_wr_data_width != pmi_rd_data_width)
		  l = RdAddress_reg * pmi_rd_data_width;
 		   for (m = 0; m < pmi_rd_data_width; m = m+1)
		     begin
			l_plus_m = l + m;
			l_plus_m_div_a = l_plus_m / pmi_wr_data_width;
			dummy_wa2b = mem[l_plus_m_div_a];
			dummy_wb[m] = dummy_wa2b[l_plus_m % pmi_wr_data_width];
		     end
		      Q_int = dummy_wb;
	      end   
		
	    end
        end // always @ (posedge WrClock, !WrA_reg, WrAddress_reg, posedge Reset)

   //REGMODE
   always @ (Q_reg, Q_int) 
     begin
      if (pmi_regmode == "reg")
	QQ = Q_reg;
      else
	QQ = Q_int;
     end
//pragma translate_on
 endmodule // pmi_ram_dp

`endif  // PMI_RAM_DP


