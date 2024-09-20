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
// File                  : apb2init.v
// Title                 :
// Dependencies          :
// Description           : Evaluation top level design for MC_Avant
// =============================================================================
//                        REVISION HISTORY
// Version               : 1.0.0.
// Author(s)             :
// Mod. Date             : 
// Changes Made          : Initial release.
// =============================================================================

module apb2init #(
  parameter DDR_TYPE       = 0,
  parameter GEAR_RATIO     = 0,
  parameter PWR_DOWN_EN    = 0,
  parameter DBI_ENABLE     = 0,
  parameter ECC_ENABLE     = 0,
  parameter DDR_WIDTH      = 0,
  parameter RANK_WIDTH     = 0, 
  parameter APB_DATA_WIDTH = 0,
  parameter SIM            = 0
)
(
   input                             pclk_i        ,
   input                             preset_n_i    ,
   input                             sclk_i        ,
   input                             p_trn_done_i  ,
   output                            s_init_start_o,
   input                             apb_penable_i , 
   input                             apb_psel_i    , 
   input                             apb_pwrite_i  , 
   input        [9:0]                apb_paddr_i   , 
   input        [APB_DATA_WIDTH-1:0] apb_pwdata_i  , 
   output logic                      apb_pready_o  , 
   output logic [APB_DATA_WIDTH-1:0] apb_prdata_o  ,
   output                            apb_pslverr_o
);

  localparam [3:0] FCR_DDR_W= (DDR_WIDTH == 8) ? 0 : (DDR_WIDTH == 16) ? 1 : (DDR_WIDTH == 32) ? 3 : 7;
  localparam       TRN_DONE_W = 6 + RANK_WIDTH;
    
  logic        p_init_start_r /* synthesis syn_preserve=1 */;   // added syn_preserve to keep the register name
  logic        s_init_start_r1/* synthesis syn_preserve=1 CDC_Register=2 */;  // added syn_preserve to keep the register name
  logic        s_init_start_r2;                            
  logic        apb_setup;
  logic [16:0] feature_control_reg;
  
  initial begin
    s_init_start_r1 = 1'b0;
    s_init_start_r2 = 1'b0;
  end
    
  assign feature_control_reg  = {RANK_WIDTH[1], FCR_DDR_W[3:0], DDR_TYPE[3:0], 4'h0, GEAR_RATIO[3], PWR_DOWN_EN[0], DBI_ENABLE[0], ECC_ENABLE[0]};
  //assign trn_opr_i    = SIM ? 8'h1E : 8'hFF;  // For checking the training when SIM=1
  //assign trn_opr_i    = SIM ? 8'h00 : 8'hFF;  // For skipping the training when SIM=1
  assign apb_setup    = apb_psel_i & ~apb_penable_i;
  
  always_ff @(posedge pclk_i or negedge preset_n_i) begin
    if (!preset_n_i) begin
      p_init_start_r    <= 1'b0;
      apb_pready_o      <= 1'b0;
      apb_prdata_o      <= {APB_DATA_WIDTH{1'b0}};
    end
    else begin
      if (p_init_start_r == 0) begin
        p_init_start_r  <= apb_psel_i & apb_penable_i & apb_pwrite_i & apb_pready_o & (apb_paddr_i[9:0] == 'h204) & (apb_pwdata_i[0] == 2'b1);
      end
      else begin
        p_init_start_r  <= p_trn_done_i ? 1'b0 : 1'b1;
      end
      apb_pready_o <= apb_setup; // Just send ready for each access
      if (apb_psel_i & ~apb_pwrite_i) begin
        if (apb_paddr_i[9:0] == 'h200)       // The eval CPU need to know the settings
          apb_prdata_o    <= {15'h00000, feature_control_reg};
        else if (apb_paddr_i[9:0] == 'h224)  // Training done, data access starts when all training steps done
          apb_prdata_o    <= {{(APB_DATA_WIDTH-TRN_DONE_W){1'b0}}, {TRN_DONE_W{p_trn_done_i}}};
        else
          apb_prdata_o    <= {APB_DATA_WIDTH{1'b0}};
      end
    end
  end  // always_ff
  assign apb_pslverr_o = 1'b0; 
  
  // synchronize the init_start
  always @(posedge sclk_i) begin
    s_init_start_r1 <= p_init_start_r;
    s_init_start_r2 <= s_init_start_r1;
  end
  assign s_init_start_o = s_init_start_r2;
endmodule
