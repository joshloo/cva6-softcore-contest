// =============================================================================
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
// -----------------------------------------------------------------------------
//   Copyright (c) 2024 by Lattice Semiconductor Corporation
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
// File                  : async_reset_sync_deassert.v
// Title                 :
// Dependencies          :
// Description           : Synchronize the reset deassertion to clock while maintaining async assertion.
//                         Ensures that the reset registers are in the same/adjacent slice.
// =============================================================================
//                        REVISION HISTORY
// Version               : 1.0.0.
// Author(s)             :
// Mod. Date             : 
// Changes Made          : Initial release.
// =============================================================================

module async_reset_sync_deassert #(
  parameter ACTIVE_LVL = 0,
  parameter RST_STAGES = 3
)
(
  input  clk_i,
  input  rst_i,
  output rst_o
)/* synthesis GRP = "arst_syncd" */;

reg [RST_STAGES-1:0] rst_regs/* synthesis syn_preserve=1 */;

generate 

  if (ACTIVE_LVL == 0) begin : ACTL
    always@(posedge clk_i or negedge rst_i) begin
      if (!rst_i)
        rst_regs <= {RST_STAGES{1'b0}};
      else
        rst_regs <= {rst_regs[RST_STAGES-2:0], 1'b1};
    end
  end
  else begin : ACTH
    always@(posedge clk_i or posedge rst_i) begin
      if (rst_i)
        rst_regs <= {RST_STAGES{1'b1}};
      else
        rst_regs <= {rst_regs[RST_STAGES-2:0], 1'b0};
    end
  end
  
endgenerate

assign rst_o = rst_regs[RST_STAGES-1];

endmodule