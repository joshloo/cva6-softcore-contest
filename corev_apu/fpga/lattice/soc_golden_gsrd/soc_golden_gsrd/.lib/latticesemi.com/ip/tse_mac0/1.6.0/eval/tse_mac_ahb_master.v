`ifndef TSE_MAC_TX_AHB_MASTER_V
`define TSE_MAC_TX_AHB_MASTER_V
//0---------------------------------------------------------------------------------------------------
// File Name      : tse_mac_ahb_master.v
// Project        : TSE_MAC IIP
// Date Created   : 14-06-2020
// Description    : This is HDL file AHB master
// Generator      : Test bench Compiler Version 1.1
//0---------------------------------------------------------------------------------------------------

`timescale 1ns/1ps
//`include "tse_mac_defines.v"

module tse_mac_ahb_master #(

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
  ) (

  //1###################################################################################################
  // Input/Output Signal Declaration
  //1###################################################################################################
  input   wire                   i_clk,              // Systam clk
  input   wire                   rst_n_i,  
  input   wire                   i_ahbl_hreadyout,   // AHBL hredayout 
  input   wire[DATA_WIDTH-1:0]   i_ahbl_hrdata,      // AHBL read data 
  output  reg [OFFSET_WIDTH-1:0] o_ahbl_haddr,       // AHBL address 
  output  reg [DATA_WIDTH-1:0]   o_ahbl_hwdata,      // AHBL Write data
  output  reg [1:0]              o_ahbl_htrans,      // AHBL Transaction
  output  reg                    o_ahbl_hwrite,      // AHBL Write
  output  reg [2:0]              o_ahbl_hburst,      // AHBL Burst 
  output  reg                    o_ahbl_hsel,        // AHBL Select
  output  reg [2:0]              o_ahbl_hsize,       // AHBL Size
  output  reg                    o_ahbl_hmastlock,   // AHBL Master lock
  output  reg [3:0]              o_ahbl_hprot,        // AHBL Prot
  output reg                     done
  );


  //localparam  OFFSET_WIDTH = 8;
  //localparam  DATA_WIDTH   = 8;

  //1###################################################################################################
  // Local Parameter Declaration
  //1###################################################################################################
  reg [7:0]   ahbl_hrd_data_8b;    // Variable forr store the AHBL read data 

  //1###################################################################################################
  // Initilize all the variales
  //1###################################################################################################
  initial
  begin
    o_ahbl_haddr       = 0;  
    o_ahbl_hwdata      = 0;  
    o_ahbl_htrans      = 0; 
    o_ahbl_hwrite      = 0; 
    o_ahbl_hburst      = 0; 
    o_ahbl_hsel        = 0; 
    o_ahbl_hsize       = 0; 
    o_ahbl_hmastlock   = 0; 
    o_ahbl_hprot       = 0; 
    ahbl_hrd_data_8b   = 0;
  end
  
  initial begin

  wait (rst_n_i);
  
  repeat(5) @(posedge i_clk);
  
  
  ahb_write ('h04, 'h05);
  repeat(5) @(posedge i_clk);
  ahb_write ('h00, 'h0D);
  repeat(5) @(posedge i_clk);
  
  done = 1;
end

  //1-------------------------------------------------------------------------------------------------
  // ahb_write :This method is used to perform write transfer 
  //1-------------------------------------------------------------------------------------------------
  //           p_paddr_32b :AHB register address 
  //          p_pwdata_32b :AHB write data 
  //1-------------------------------------------------------------------------------------------------
  task ahb_write;
    input    [OFFSET_WIDTH-1:0]       p_paddr_bv ;
    input    [DATA_WIDTH-1:0]         p_pwdata_bv;
    begin
      @ (posedge i_clk);
      o_ahbl_haddr     <= p_paddr_bv; 
      o_ahbl_htrans    <= 2'b10;
      o_ahbl_hwrite    <= 1;
      o_ahbl_hburst    <= 0;
      o_ahbl_hsel      <= 1;
      o_ahbl_hsize     <= 3'b010;
      @ (posedge i_clk);
      o_ahbl_haddr     <= 0; 
      o_ahbl_hwdata    <= p_pwdata_bv; 
      o_ahbl_hwrite    <= 0;
      o_ahbl_htrans    <= 2'b00;
      //3---------------------------------------------------------------------------------------------
      // Transfer is completed 
      //3---------------------------------------------------------------------------------------------
      while (i_ahbl_hreadyout == 0) begin
        @ (posedge i_clk);
      end
      o_ahbl_htrans    <= 2'b00;
      o_ahbl_hwrite    <= 0;
      o_ahbl_hburst    <= 0;
      o_ahbl_hsel      <= 0;
      o_ahbl_hsize     <= 3'b0;
    end
  endtask


  //1-------------------------------------------------------------------------------------------------
  // ahb_read :This method is used to perform read transfer 
  //1-------------------------------------------------------------------------------------------------
  //           p_paddr_32b :AHB register address 
  //1-------------------------------------------------------------------------------------------------
  task ahb_read;
    input [DATA_WIDTH-1:0] p_paddr_bv;
    begin
      if (MIIM_MODULE == 1) begin
        @ (posedge tb_top.mdc_i);
      end else begin
        @ (posedge i_clk);
      end
      o_ahbl_haddr     <= p_paddr_bv; 
      o_ahbl_htrans    <= 2'b10;
      o_ahbl_hwrite    <= 0;
      o_ahbl_hburst    <= 0;
      o_ahbl_hsize     <= 3'b010;
      o_ahbl_hsel      <= 1;
      if (MIIM_MODULE == 1) begin
       @ (posedge tb_top.mdc_i);
      end else begin
        @ (posedge i_clk);
      end

      //3---------------------------------------------------------------------------------------------
      // Transfer is completed 
      //3---------------------------------------------------------------------------------------------
      while (i_ahbl_hreadyout == 0) begin
        //if (MIIM_MODULE == 1) begin
        // @ (posedge tb_top.mdc_i);
        //end else begin
          @ (posedge i_clk);
        //end
      end
      o_ahbl_haddr      <= 0; 
      o_ahbl_htrans     <= 2'b00;
      o_ahbl_hwrite     <= 0;
      o_ahbl_hburst     <= 0;
      o_ahbl_hsel       <= 0;
      ahbl_hrd_data_8b  <= i_ahbl_hrdata;
    end
  endtask
endmodule
`endif
