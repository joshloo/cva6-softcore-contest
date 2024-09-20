// =============================================================================
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
// -----------------------------------------------------------------------------
//   Copyright (c) 2022 by Lattice Semiconductor Corporation
//   ALL RIGHTS RESERVED
// -----------------------------------------------------------------------------
//
//   Permission:
//
//      Lattice SG Pte. Ltd. grants permission to use this code
//      pursuant to the terms of the Lattice Reference Design License Agreement.
//
//
//   Disclaimer:
//
//      This VHDL or Verilog source code is intended as a design reference
//      which illustrates how these types of functions can be implemented.
//      It is the user's responsibility to verify their design for
//      consistency and functionality through the use of formal
//      verification methods.  Lattice provides no warranty
//      regarding the use or functionality of this code.
//
// -----------------------------------------------------------------------------
//
//                  Lattice SG Pte. Ltd.
//                  101 Thomson Road, United Square #07-02
//                  Singapore 307591
//
//
//                  TEL: 1-800-Lattice (USA and Canada)
//                       +65-6631-2000 (Singapore)
//                       +1-503-268-8001 (other locations)
//
//                  web: http://www.latticesemi.com/
//                  email: techsupport@latticesemi.com
//
// -----------------------------------------------------------------------------
//
// =============================================================================
//                         FILE DETAILS
// Project               :
// File                  : lscc_axi4_perf_calc.v
// Title                 :
// Dependencies          : 1.
//                       : 2.
// Description           :
// =============================================================================
//                        REVISION HISTORY
// Version               : 1.0.0
// Author(s)             :
// Mod. Date             :
// Changes Made          : Initial release.
// =============================================================================

module lscc_axi4_perf_calc 
#( 
   parameter DATA_CLK_EN    = 0,
   parameter AXI_DATA_WIDTH = 0
 )                            
 (
   input               aclk_i      ,
   input               areset_n_i  ,
   input               sclk_i      ,
   input               rstn_i      ,
   input               wr_start    ,
   input               wr_txn_done ,
   input               rd_txn_done ,
   input               axi_wready_i,  
   input               axi_wvalid_i,  
   input               axi_awvalid_i ,
   input               axi_arvalid_i , 
   input               axi_rvalid_i  , 
   input               axi_rready_o , 

   output logic [31:0] duration_cntr_status_aclk_o ,
   output logic [31:0] duration_cntr_status_sclk_o ,
   output logic [31:0] total_num_wr_rd_o  
 );

////PERFORMANCE CALCULATOR///////
//
/******
1. Calculate the number of bytes based on the strb ready and valid for write and ready and valid for read
2. No partial write so all of them are full size
3. len will not matter because of ready and valid
4. Counter to count the clock cycles when both read
5. When transaction done write to a register with the final bytes and perf count value. CDC not required because the value will be constant .
******/ 
  logic                             axi_wready_r               ;
  logic                             axi_wvalid_r               ;
 // logic  [AXI_DATA_WIDTH/8-1:0]     axi_wstrb_r              ; 
  
  logic                             axi_awvalid_r              ; 
  logic                             axi_arvalid_r              ; 
  
  logic                             axi_rvalid_r               ;
  logic                             axi_rready_r               ;
  
  logic [31:0]                      num_of_writes              ;
  logic [31:0]                      num_of_reads               ;
  logic [31:0]                      duration_cntr_aclk_r            ;
  logic [31:0]                      duration_cntr_sclk_r            ;
  
//  logic                             duration_cntr_en_rd_aclk_r      ;
//  logic                             duration_cntr_en_wr_aclk_r      ; 
//  logic                             duration_cntr_en_aclk_r         ; 
//  logic                             duration_cntr_en_done_aclk      ;

//  logic                             duration_cntr_en_sclk_r     ;
//  logic                             duration_cntr_en_rd_sclk_r  ;
//  logic                             duration_cntr_en_wr_sclk_r  ;
//  logic                             wr_start_sclk               ;        
//  logic                             duration_cntr_en_done_sclk  ;
//  logic                             sclk_cdc_reg_rd_1           ;
//  logic                             sclk_cdc_reg_rd_2           ; 
//  logic                             sclk_cdc_reg_wr_1           ;
//  logic                             sclk_cdc_reg_wr_2           ;
  
  logic a_duration_cntr_en_r   /* synthesis syn_preserve=1 */;
  logic a_duration_cntr_en_reg /* synthesis syn_preserve=1 */;
  logic a_duration_cntr_en_r2  ;
  logic a_duration_cntr_en_w   ;
  logic a_duration_cntr_en_rd_w;
  logic a_duration_cntr_en_wr_w;
  logic a_duration_cntr_en_rd_r;
  logic a_duration_cntr_en_wr_r;
  logic a_duration_cntr_en_done;
  
  logic s_duration_cntr_en_w   ;
  logic s_duration_cntr_ld_1_w ;
  
  logic a2s_duration_cntr_en_r1;
  logic a2s_duration_cntr_en_r2;
  logic a2s_duration_cntr_en_r3;

  // AXI_WRITE   
  always_ff @(posedge aclk_i or negedge areset_n_i) begin
    if(!areset_n_i) begin
      axi_wready_r           <= 'h0;
      axi_wvalid_r           <= 'h0;
     // axi_wr_valid_bytes_r   <= 'h0;
      axi_awvalid_r          <= 'h0;
      num_of_writes           <= 'h0;
    end 
    else begin
      axi_wready_r          <= axi_wready_i  ;
      axi_awvalid_r         <= axi_awvalid_i ;
      axi_wvalid_r          <= axi_wvalid_i  ;
     // axi_wr_valid_bytes_r  <= axi_wr_valid_bytes(axi_wstrb_i);                                                                                                               
      if(wr_start) begin
        num_of_writes <= 'h0;
      end  
      else if(axi_wvalid_r & axi_wready_r) begin
        num_of_writes <= num_of_writes + 1  ;     //axi_wr_valid_bytes_r;
      end 
    end 
  end 
   
  
  // AXI_READ 
  always_ff @(posedge aclk_i or negedge areset_n_i) begin
    if(!areset_n_i) begin
      axi_rready_r  <= 'h0;
      axi_rvalid_r  <= 'h0;
      axi_arvalid_r <= 'h0;
      num_of_reads  <= 'h0;
    end 
    else begin
      axi_arvalid_r <= axi_arvalid_i ;
      axi_rready_r <= axi_rready_o   ;
      axi_rvalid_r <= axi_rvalid_i   ;
      if (wr_start) begin
        num_of_reads <= 'h0;
      end 
      else if(axi_rvalid_r & axi_rready_r) begin
        num_of_reads <= num_of_reads + 1 ; //(AXI_DATA_WIDTH/8);
      end 
    end 
  end 
  

  // PERFORMANCE_COUNTER and TOTAL BYTES CALCULATED
  
  // FIXME :: The done might have a delay so check first and then see the value. 
  assign a_duration_cntr_en_rd_w = (axi_arvalid_r ? 1'b1 : rd_txn_done ? 1'b0 : a_duration_cntr_en_rd_r);
  assign a_duration_cntr_en_wr_w = (axi_awvalid_r ? 1'b1 : wr_txn_done ? 1'b0 : a_duration_cntr_en_wr_r);
  assign a_duration_cntr_en_w    = a_duration_cntr_en_wr_w | a_duration_cntr_en_rd_w;
  
  always_ff @(posedge aclk_i or negedge areset_n_i) begin  
    if(!areset_n_i) begin
      duration_cntr_aclk_r         <= 'h0;
//      duration_cntr_en_rd_aclk_r   <= 'h0;
//      duration_cntr_en_wr_aclk_r   <= 'h0;
//      duration_cntr_en_aclk_r      <= 'h0;
      a_duration_cntr_en_rd_r      <= 'h0;
      a_duration_cntr_en_wr_r      <= 'h0;
      a_duration_cntr_en_reg       <= 'h0;           
      a_duration_cntr_en_r         <= 'h0;
      a_duration_cntr_en_r2        <= 'h0;
//      duration_cntr_status_aclk_o  <= 'h0;
      total_num_wr_rd_o            <= 'h0;
    end 
    else begin
//      duration_cntr_en_aclk_r      <= (duration_cntr_en_rd_aclk_r | duration_cntr_en_wr_aclk_r);
//      duration_cntr_en_rd_aclk_r   <= (axi_arvalid_r ? 1'b1 : rd_txn_done ? 1'b0 : duration_cntr_en_rd_aclk_r);    // FIX_ME :: The done might have a delay so check first and then see the value. 
//      duration_cntr_en_wr_aclk_r   <= (axi_awvalid_r ? 1'b1 : wr_txn_done ? 1'b0 : duration_cntr_en_wr_aclk_r);
      a_duration_cntr_en_rd_r      <= a_duration_cntr_en_rd_w;
      a_duration_cntr_en_wr_r      <= a_duration_cntr_en_wr_w;
      a_duration_cntr_en_reg       <= a_duration_cntr_en_w;  // For CDC to sclk
      a_duration_cntr_en_r         <= a_duration_cntr_en_w;  // For aclk logic
      a_duration_cntr_en_r2        <= a_duration_cntr_en_r;
      if(a_duration_cntr_en_r ) begin
        // Start count with 1 at posedge of a_duration_cntr_en_r
        duration_cntr_aclk_r <= a_duration_cntr_en_r2 ? duration_cntr_aclk_r + 1 : 1;  
      end // hold value when a_duration_cntr_en_r=0
//      else begin
//        duration_cntr_status_aclk_o <= duration_cntr_en_done_aclk ? duration_cntr_aclk_r : wr_start ? 'h0 : duration_cntr_status_aclk_o;     // FIX_ME :: use a pulse to load the final value.
//        duration_cntr_aclk_r        <= wr_start ? 'h0 : duration_cntr_aclk_r;
//      end 
      //total_num_wr_rd_o    <= duration_cntr_en_done_aclk ? (num_of_reads + num_of_writes) : wr_start ? 'h0 : total_num_wr_rd_o ;
      total_num_wr_rd_o      <= a_duration_cntr_en_done ? (num_of_reads + num_of_writes) : wr_start ? 'h0 : total_num_wr_rd_o ;
    end 
  end

//  assign duration_cntr_en_done_aclk  = duration_cntr_en_aclk_r  & ~( duration_cntr_en_rd_aclk_r | duration_cntr_en_wr_aclk_r); 
//  assign duration_cntr_en_done_sclk  = duration_cntr_en_sclk_r  & ~( duration_cntr_en_rd_sclk_r | duration_cntr_en_wr_sclk_r); 
  assign a_duration_cntr_en_done     = a_duration_cntr_en_r  & ~a_duration_cntr_en_w; // Done is the fall edge of the enable
  assign duration_cntr_status_aclk_o = duration_cntr_aclk_r; // assign directly because it will only be captured when the done pass CDC logic

  always_ff @(posedge sclk_i or negedge rstn_i) begin
    if(!rstn_i) begin
      duration_cntr_sclk_r         <= 'h0;
    end 
    else begin
      if (s_duration_cntr_en_w) 
        duration_cntr_sclk_r <= duration_cntr_sclk_r + 1;
      else if (s_duration_cntr_ld_1_w)
        duration_cntr_sclk_r <= 'h1;  
    end 
  end // always_ff
  
  assign duration_cntr_status_sclk_o = duration_cntr_sclk_r;
  
  generate
    if(DATA_CLK_EN == 0) begin : SYNC
      assign s_duration_cntr_en_w   = a_duration_cntr_en_r;
      assign s_duration_cntr_ld_1_w = a_duration_cntr_en_r & ~a_duration_cntr_en_r2;
    end  // SYNC
    else begin : ASYNC
      assign s_duration_cntr_en_w   = a2s_duration_cntr_en_r2;
      assign s_duration_cntr_ld_1_w = a2s_duration_cntr_en_r2 & ~a2s_duration_cntr_en_r3;
      // CDC capture of count enable signal
      always_ff @(posedge sclk_i or negedge rstn_i) begin  
        if(!rstn_i) begin  
          a2s_duration_cntr_en_r1 <= 1'b0;
          a2s_duration_cntr_en_r2 <= 1'b0;
          a2s_duration_cntr_en_r3 <= 1'b0;
        end 
        else begin 
          a2s_duration_cntr_en_r1 <= a_duration_cntr_en_reg;
          a2s_duration_cntr_en_r2 <= a2s_duration_cntr_en_r1;
          a2s_duration_cntr_en_r3 <= a2s_duration_cntr_en_r2;
        end
      end // always_ff
    end  // ASYNC 
  endgenerate 

//  generate
//  if(DATA_CLK_EN == 0) begin :SYNC
//    always_ff @(posedge sclk_i or negedge rstn_i) begin
//      if(!rstn_i) begin
//        duration_cntr_sclk_r         <= 'h0;
//        duration_cntr_en_sclk_r      <= 'h0;
//        duration_cntr_en_rd_sclk_r   <= 'h0;
//        duration_cntr_en_wr_sclk_r   <= 'h0;
//        duration_cntr_status_sclk_o  <= 'h0;
//      end 
//      else begin
//        duration_cntr_en_sclk_r      <= (duration_cntr_en_rd_sclk_r | duration_cntr_en_wr_sclk_r);
//        duration_cntr_en_rd_sclk_r   <= (axi_arvalid_r ? 1'b1 : rd_txn_done ? 1'b0 : duration_cntr_en_rd_sclk_r);    // FIX_ME :: The done might have a delay so check first and then see the value. 
//        duration_cntr_en_wr_sclk_r   <= (axi_awvalid_r ? 1'b1 : wr_txn_done ? 1'b0 : duration_cntr_en_wr_sclk_r);
//        if(duration_cntr_en_rd_sclk_r | duration_cntr_en_wr_sclk_r) begin
//          duration_cntr_sclk_r <= duration_cntr_sclk_r + 1;
//        end 
//        else begin
//          duration_cntr_status_sclk_o <= duration_cntr_en_done_sclk ? duration_cntr_sclk_r : wr_start ? 'h0 : duration_cntr_status_sclk_o;     // FIX_ME :: use a pulse to load the final value.
//          duration_cntr_sclk_r        <= wr_start ? 'h0 : duration_cntr_sclk_r;
//        end       
//      end 
//    end // always_ff
//  end  // SYNC
//  else begin : ASYNC  
//    //CDC for wr_start
//    lpddr4_mc_toggle_sync 
//    u_wr_start_sync (
//                      .clk_in   (aclk_i             ),
//                      .rst_n_in (areset_n_i         ),
//                      .pulse_in (wr_start           ), 
//                      .clk_out  (sclk_i             ),
//                      .rst_n_out(rstn_i             ),
//                      .pulse_out(wr_start_sclk       ) 
//     );
//    always_ff @(posedge sclk_i or negedge rstn_i) begin  
//      if(!rstn_i) begin  
//        duration_cntr_en_sclk_r <= 'h0;
//        duration_cntr_sclk_r    <= 'h0;
//        duration_cntr_status_sclk_o <= 'h0;
//      end 
//      else begin 
//        duration_cntr_en_sclk_r <= (duration_cntr_en_rd_sclk_r | duration_cntr_en_wr_sclk_r);
//        if(duration_cntr_en_rd_sclk_r | duration_cntr_en_wr_sclk_r) begin
//          duration_cntr_sclk_r <= duration_cntr_sclk_r + 1;
//        end
//        else begin 
//      duration_cntr_status_sclk_o <= duration_cntr_en_done_sclk ? duration_cntr_sclk_r : wr_start_sclk ? 'h0 : duration_cntr_status_sclk_o;     // FIX_ME :: use a pulse to load the final value.
//          duration_cntr_sclk_r        <= wr_start_sclk ? 'h0 : duration_cntr_sclk_r;
//    end 
//      end 
//    end 
//  
//    always_ff @(posedge sclk_i or negedge rstn_i) begin
//      if(!rstn_i) begin 
//        duration_cntr_en_rd_sclk_r    <= 'h0;
//    sclk_cdc_reg_rd_1             <= 'h0;
//    sclk_cdc_reg_rd_2             <= 'h0;
//      end 
//      else begin
////    sclk_cdc_reg_rd_1             <= duration_cntr_en_rd_aclk_r;
//    sclk_cdc_reg_rd_2             <= sclk_cdc_reg_rd_1;
//    duration_cntr_en_rd_sclk_r    <= sclk_cdc_reg_rd_2;
//      end 
//    end 
//
//    always_ff @(posedge sclk_i or negedge rstn_i) begin
//      if(!rstn_i) begin 
//        duration_cntr_en_wr_sclk_r    <= 'h0;
//        sclk_cdc_reg_wr_1             <= 'h0;
//        sclk_cdc_reg_wr_2             <= 'h0;
//      end 
//      else begin
////        sclk_cdc_reg_wr_1             <= duration_cntr_en_wr_aclk_r;
//    sclk_cdc_reg_wr_2             <= sclk_cdc_reg_wr_1;
//    duration_cntr_en_wr_sclk_r    <= sclk_cdc_reg_wr_2;
//      end 
//    end
//  
//  end 
//  endgenerate 
  
  
endmodule
