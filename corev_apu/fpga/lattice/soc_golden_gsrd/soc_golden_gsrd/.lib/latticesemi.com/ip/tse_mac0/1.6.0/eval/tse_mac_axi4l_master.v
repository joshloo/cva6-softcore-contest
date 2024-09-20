`ifndef TSE_MAC_TX_AXI4L_MASTER_V
`define TSE_MAC_TX_AXI4L_MASTER_V
//0---------------------------------------------------------------------------------------------------
// File Name      : tse_mac_axi4l_master.v
// Project        : TSE_MAC
// Date Created   : 20-07-2022
// Description    : This is HDL file AXI4L master
// Generator      : Test bench Compiler Version 1.1
//0---------------------------------------------------------------------------------------------------

`timescale 1ns/1ps
//`include "tse_mac_defines.v"

module tse_mac_axi4l_master
#(

  //1###################################################################################################
  // Parameter Declaration
  //1###################################################################################################
  parameter SGMII_TSMAC    = 0,
  parameter CLASSIC_TSMAC  = 0,
  parameter GBE_MAC        = 1,
  parameter MIIM_MODULE    = 0,
  parameter RGMII          = 0,
  parameter OFFSET_WIDTH   = 11,
  parameter DATA_WIDTH     = 32

  //1###################################################################################################
  // Local Parameter Declaration
  //1###################################################################################################
  )
// -----------------------------------------------------------------------------
// Input/Output Ports
// -----------------------------------------------------------------------------
(
input   wire       				i_clk,
input                           rst_n_i,
output  reg                     axi_awvalid,
input   wire                    axi_awready,
output  reg [OFFSET_WIDTH-1:0]  axi_awaddr,
output  reg [2:0]               axi_awprot,	//not used
	    
output  reg                     axi_wvalid,	
input   wire                    axi_wready,
output  reg [DATA_WIDTH-1:0]    axi_wdata,
output  reg                     axi_wstrb,	//not used 
		                          
		                          
input   wire                    axi_bvalid,	
output  reg                     axi_bready,
input   wire [1:0]              axi_bresp,	//bresp default 2'b00 (okay)
	    
	    
output  reg                     axi_arvalid,
input   wire                    axi_arready,
output  reg [OFFSET_WIDTH-1:0]  axi_araddr,
output  reg [2:0]               axi_arprot,	//not used
	    
input   wire                    axi_rvalid,
output  reg                     axi_rready,
input   wire [DATA_WIDTH-1:0]   axi_rdata,
input   wire [1:0]              axi_rresp,   //bresp default 2'b00 (okay)
output  reg                     done


);


//localparam  OFFSET_WIDTH = 8;
//localparam  DATA_WIDTH   = 8;
reg [7:0]   axi_rdata_8b;    // Variable forr store the AHBL read data 
  
initial begin
axi_awvalid		= 0;
axi_arvalid		= 0; 
axi_wvalid		= 0; 
axi_rready		= 0;
axi_awaddr		= 8'b00000000 ;
axi_araddr		= 8'b00000000 ; 
axi_wdata		= 8'b00000000 ;
axi_awprot		= 0;
axi_bready		= 0;
axi_arprot		= 0;
done = 0;
end

initial begin

  wait (rst_n_i);
  
  repeat(5) @(posedge i_clk);
  axi4l_write ('h04, 'h05);
  repeat(5) @(posedge i_clk);
  axi4l_write ('h00, 'h0D);
  repeat(5) @(posedge i_clk);
  done = 1;
end
  //1-------------------------------------------------------------------------------------------------
  // axi4l_write :This method is used to perform write transfer 
  //1-------------------------------------------------------------------------------------------------
  //           p_paddr_32b :AXI4L register address 
  //           p_pwdata_32b :AXI4L write data 
  //1-------------------------------------------------------------------------------------------------
task axi4l_write;
    input    [OFFSET_WIDTH-1:0]       p_paddr_bv ;
    input    [DATA_WIDTH-1:0]         p_pwdata_bv;
    begin
      @(posedge i_clk);
	  

		axi_awvalid		<= 1;
		axi_arvalid		<= 0; 
		axi_wvalid		<= 1; 
		axi_rready		<= 0;
		axi_awaddr		<= p_paddr_bv ;
		axi_araddr		<= 8'b00000000 ; 
		axi_wdata		<= p_pwdata_bv ;
		axi_awprot		<= 0;
		axi_bready		<= 0;
		axi_arprot		<= 0;
	
	
	  while (axi_wready == 0) begin
        @ (posedge i_clk);
      end
        
		axi_awvalid		<= 0;
		axi_arvalid		<= 0; 
		axi_wvalid		<= 0; 
		axi_rready		<= 0;
		axi_awaddr		<= p_paddr_bv ;
		axi_araddr		<= 8'b00000000 ; 
		axi_wdata		<= p_pwdata_bv ;
		axi_awprot		<= 0;
		axi_bready		<= 1;
		axi_arprot		<= 0;
	   @ (posedge i_clk);
	   axi_bready		<= 0;
	  repeat(2) @(posedge i_clk);
    end
  endtask


  //1-------------------------------------------------------------------------------------------------
  // axi4l_read :This method is used to perform read transfer 
  //1-------------------------------------------------------------------------------------------------
  //           p_paddr_32b :AXI4L register address 
  //1-------------------------------------------------------------------------------------------------
  task axi4l_read;
    input [DATA_WIDTH-1:0] p_paddr_bv;
    begin
     @ (posedge i_clk);
		axi_awvalid		<= 0;
		axi_arvalid		<= 1; 
		axi_wvalid		<= 0; 
		axi_rready		<= 1;
		axi_awaddr		<= 8'b00000000;
		axi_araddr		<= p_paddr_bv ; 
		axi_wdata		<= 8'b00000000;
		axi_awprot		<= 0;
		axi_bready		<= 0;
		axi_arprot		<= 0;
	
	 while (axi_rvalid == 0) begin
        @ (posedge i_clk);
      end
	    axi_awvalid		<= 0;
		axi_arvalid		<= 0; 
		axi_wvalid		<= 0; 
		axi_rready		<= 0;
		axi_awaddr		<= 8'b00000000;
		axi_araddr		<= p_paddr_bv ; 
		axi_wdata		<= 8'b00000000;
		axi_awprot		<= 0;
		axi_bready		<= 0;
		axi_arprot		<= 0;
    end
  endtask
  
/*  task axi4l_write_add;
    begin
      @(posedge i_clk);
		axi_awvalid		<= 1;
		axi_arvalid		<= 0; 
		axi_wvalid		<= 1; 
		axi_rready		<= 0;
		axi_awaddr		<= 8'h02;
		axi_araddr		<= 8'b00000000 ; 
		axi_wdata		<= 8'h01;
		axi_awprot		<= 0;
		axi_bready		<= 0;
		axi_arprot		<= 0;
	
	
	  while (axi_wready == 0) begin
        @ (posedge i_clk);
      end
	   
	   @ (posedge i_clk);
		axi_awvalid		<= 1;
		axi_arvalid		<= 0; 
		axi_wvalid		<= 1; 
		axi_rready		<= 0;
		axi_awaddr		<= 8'h00;
		axi_araddr		<= 8'b00000000 ; 
		axi_wdata		<= 8'h0D;
		axi_awprot		<= 0;
		axi_bready		<= 0;
		axi_arprot		<= 0;
	  while (axi_wready == 0) begin
        @ (posedge i_clk);
      end
	  axi_bready		<= 1;
	  axi_awvalid		<= 0;
	  axi_wvalid		<= 0;
	  @(posedge i_clk);
	  axi_bready		<= 0;
	  repeat(5) @(posedge i_clk);
	  
	  axi_bready		<= 1;
	  @(posedge i_clk);
	  axi_bready		<= 0;
	   
	  repeat(5) @(posedge i_clk);
    end
	
  endtask 
  */
endmodule
`endif


