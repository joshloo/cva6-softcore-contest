// =============================================================================
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
// -----------------------------------------------------------------------------
// Copyright (c) 2023 by Lattice Semiconductor Corporation
// ALL RIGHTS RESERVED
// --------------------------------------------------------------------
//
// Permission:
//
// Lattice SG Pte. Ltd. grants permission to use this code
// pursuant to the terms of the Lattice Reference Design License Agreement.
//
//
// Disclaimer:
//
// This VHDL or Verilog source code is intended as a design reference
// which illustrates how these types of functions can be implemented.
// It is the user's responsibility to verify their design for
// consistency and functionality through the use of formal
// verification methods. Lattice provides no warranty
// regarding the use or functionality of this code.
//
// -----------------------------------------------------------------------------
//
//                     Lattice SG Pte. Ltd.
//                     101 Thomson Road, United Square #07-02
//                     Singapore 307591
//
//
//                     TEL: 1-800-Lattice (USA and Canada)
//                     +65-6631-2000 (Singapore)
//                     +1-503-268-8001 (other locations)
//
//                     web: http://www.latticesemi.com/
//                     email: techsupport@latticesemi.com
//
// -----------------------------------------------------------------------------
//
// =============================================================================
// FILE DETAILS
// Project      : <>
// File         : tb_top.v
// Title        : Testbench for Oscillator.
// Dependencies :
// Description  :
// =============================================================================
// REVISION HISTORY
// Version      : 1.0
// Author(s)    :
// Mod. Date    :
// Changes Made : Initial version
// =============================================================================

`ifndef __TB_TOP__
`define __TB_TOP__

`timescale 1ps/1ps

module tb_top();
`include "dut_params.v"
//--------------------------------------------------------------------------
//--- Local Parameters/Defines ---
//--------------------------------------------------------------------------
localparam DEVICE_LFREQ_FLR  = 320;
localparam DEVICE_HFREQ_CEIL = 400;

localparam FREQ_LTRGET_FLR   =  DEVICE_LFREQ_FLR/CLK_DIV_DEC;  //320 
localparam FREQ_HTRGET_FLR   =  DEVICE_LFREQ_FLR/CLK_DIV_DEC;  //320
localparam FREQ_LTRGET_CEIL  =  DEVICE_HFREQ_CEIL/CLK_DIV_DEC; //400
localparam FREQ_HTRGET_CEIL  =  DEVICE_HFREQ_CEIL/CLK_DIV_DEC; //400

localparam FREQ_LTLRNCE_FLR  = (FREQ_LTRGET_FLR)  - (0.1*FREQ_LTRGET_FLR);  //-10% tolerance
localparam FREQ_HTLRNCE_FLR  = (FREQ_HTRGET_FLR)  + (0.1*FREQ_HTRGET_FLR);  //+10% tolerance
localparam FREQ_LTLRNCE_CEIL = (FREQ_LTRGET_CEIL) - (0.1*FREQ_LTRGET_CEIL); //-10% tolerance
localparam FREQ_HTLRNCE_CEIL = (FREQ_HTRGET_CEIL) + (0.1*FREQ_HTRGET_CEIL); //+10% tolerance
// -----------------------------------------------------------------------------
// Register Declarations
// -----------------------------------------------------------------------------
reg         en_i;
reg         clk_sel_i;
reg  [8:0]  exp_clk_freq;
reg  [8:0]  actual_clk_freq_tol;
reg  [9:0]  error_count;

// -----------------------------------------------------------------------------
// Wire Declarations
// -----------------------------------------------------------------------------
wire        clk_out_o;
wire        tb_error;

// -----------------------------------------------------------------------------
// Time/Real Declarations
// -----------------------------------------------------------------------------
time time_prev;
time time_nxt;
time actual_clk_period;

real actual_clk_freq;

//--------------------------------------------------------------------------
// Assign Statements
//--------------------------------------------------------------------------
assign tb_error     = (actual_clk_freq_tol === 9'b0) ? 1'b0 : ((exp_clk_freq === actual_clk_freq_tol) ? 1'b0 : 1'b1);

//--------------------------------------------------------------------------
// Initial statement; Reset sequence
//--------------------------------------------------------------------------
initial begin
   en_i                 = 1'b0;
   clk_sel_i            = 1'b0;
   error_count          = 1'b0;
   actual_clk_freq_tol  = 9'b0;
   exp_clk_freq         = 9'b0;
   
  $display("******************************************************************");
  $display("Start of Simulation                                               ");
  $display("+-----------------------------------------------------------------");
  $display("Testbench Parameters                                              ");
  $display("CLK Divider        :   %0s",CLK_DIV                                );
  $display("+-----------------------------------------------------------------");
  #(100000*CLK_DIV_DEC)  en_i         = 1;

  $display("User Clock Test ENABLED                                           ");
  $display("User Clock Tolerance :   +/- 10 Percent                           ");
  $display("It takes a few clock cycles for clk_out_o to follow the switching.");
  $display("+-----------------------------------------------------------------");
  $display("Start User Clock Test for < %d MHz/CLK Divider>", DEVICE_HFREQ_CEIL);
  $display("+-----------------------------------------------------------------");
  
  $monitor("Expected Frequency(MHz) : %1.1f, Actual Frequency(MHz): %1.1f", exp_clk_freq, actual_clk_freq); 
    
  #(2450000*CLK_DIV_DEC) clk_sel_i   = 1;
  
  $display("+-----------------------------------------------------------------");
  $display("Switching User Clock Test to < %d MHz/CLK Divider>",DEVICE_LFREQ_FLR);
  $display("+-----------------------------------------------------------------");
  $monitor("Expected Frequency(MHz) : %1.1f, Actual Frequency(MHz): %1.1f", exp_clk_freq, actual_clk_freq); 
  
  #(2500000*CLK_DIV_DEC) clk_sel_i  = 0;

  $display("+-----------------------------------------------------------------");
  $display("Switching User Clock Test to < %d MHz/CLK Divider>", DEVICE_HFREQ_CEIL);
  $display("+-----------------------------------------------------------------");
  $monitor("Expected Frequency(MHz) : %1.1f, Actual Frequency(MHz): %1.1f", exp_clk_freq, actual_clk_freq);
  
  #(2500000*CLK_DIV_DEC)
  if (tb_error == 0 && error_count == 0) begin
   $display("+-----------------------------------------------------------------");
   $display("       **************** CLOCK MATCHED ****************            ");
   $display("--------------------- SIMULATION PASSED --------------------------");
   $display("+-----------------------------------------------------------------");
  end
  else begin
   $error("+-----------------------------------------------------------------");
   $error("       ************** CLOCK MISMATCHED **************             ");
   $error("------------------!!! SIMULATION FAILED !!!-----------------------");
   $error("-------------------  No. of Errors = %0d   ------------------------", error_count);
   $error("+-----------------------------------------------------------------");
  end  
  
  $display("End of Simulation                                                 ");
  $display("******************************************************************");
  $finish;
end

// -----------------------------
// ----- clk_out_o Checker -----
// -----------------------------
always @(posedge clk_out_o) begin   
  time_nxt  <= time_prev;  
  time_prev <= $time;
  if (en_i) begin
    if (clk_sel_i) begin
     exp_clk_freq <= (DEVICE_LFREQ_FLR/CLK_DIV_DEC);
    end
    else begin
     exp_clk_freq <= (DEVICE_HFREQ_CEIL/CLK_DIV_DEC);
    end
  end
  else begin
     exp_clk_freq <= 9'b0;
  end
end

// -------------------------------------------------
// ---Calculating Actual Frequency and Tolerance ---
// -------------------------------------------------
always @* begin
  if (clk_out_o) begin
    actual_clk_period = (time_prev - time_nxt);
    actual_clk_freq = 1000000/actual_clk_period;
    if (clk_sel_i) begin
      actual_clk_freq_tol = (actual_clk_freq >= FREQ_LTLRNCE_FLR) && (actual_clk_freq <= FREQ_HTLRNCE_FLR) ? (DEVICE_LFREQ_FLR/CLK_DIV_DEC) : 0;
    end 
    else begin
     actual_clk_freq_tol = (actual_clk_freq >= FREQ_LTLRNCE_CEIL) && (actual_clk_freq <= FREQ_HTLRNCE_CEIL) ? (DEVICE_HFREQ_CEIL/CLK_DIV_DEC) : 0;
    end
  end
end

// -----------------------------
// ------ Error Counter  ------
// -----------------------------
always @ * begin
 if (tb_error) begin
   error_count = error_count + 1;
 end
 else begin
   error_count = error_count;
 end
end

// ----------------------------
// GSR instance
// ----------------------------
GSRA GSR_INST ( .GSR_N(1'b1));
    
`include "dut_inst.v"

endmodule 
`endif