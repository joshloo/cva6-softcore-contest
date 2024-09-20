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
// File                  : lpddr4_mc_double_sync.sv
// Title                 :
// Dependencies          :
// Description           :
// =============================================================================

module lpddr4_mc_double_sync (
                            clk_out,
                            rst_n_out,
                            data_in, 
                            data_out 
                          );

parameter width = 1;

input [width-1:0]  data_in;
input              clk_out;
input              rst_n_out;
output [width-1:0] data_out;


logic [width-1:0] data_out;
logic [width-1:0] data_0;

always_ff @(posedge clk_out or negedge rst_n_out)
begin
  if (!rst_n_out) 
  begin
      data_0   <= 'b0;
      data_out <= 'b0;
  end
  else 
  begin
      data_0   <= data_in;
      data_out <= data_0;
  end
end

endmodule



