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
// File                  : lpddr4_mc_toggle_sync.sv
// Title                 :
// Dependencies          :
// Description           :
// =============================================================================

module  lpddr4_mc_toggle_sync (
                           clk_in,
                           rst_n_in,
                           pulse_in, 
                           clk_out,
                           rst_n_out,
                           pulse_out 
                           );

parameter width = 1;
parameter depth = 2;

input              clk_in;
input              rst_n_in;
input              pulse_in;

input              clk_out;
input              rst_n_out;
output logic       pulse_out;


logic  toggle_r    /*synthesis syn_preserve = 1*/;
logic  toggle_rep_r/*synthesis syn_preserve = 1*/;
logic  toggle_nxt;
// easier to constrain when separate
// Note that synthesis tools rename the signal
//logic [2:0] sync_toggle;
logic sync_toggle_r1/*synthesis syn_preserve = 1*/;
logic sync_toggle_r2/*synthesis syn_preserve = 1*/;
logic sync_toggle_r3;

assign toggle_nxt = pulse_in ? ~toggle_rep_r : toggle_rep_r;
always_ff @(posedge clk_in or negedge rst_n_in) begin
  if (~rst_n_in) begin
     toggle_r     <= 1'b0;
	 toggle_rep_r <= 1'b0;
  end
  else begin 
     toggle_r     <= toggle_nxt;
	 toggle_rep_r <= toggle_nxt;
  end
end

always_ff @(posedge clk_out or negedge rst_n_out)
begin
  if (~rst_n_out) 
  begin
//      sync_toggle <= 3'b0;
      sync_toggle_r1 <= 1'b0;
      sync_toggle_r2 <= 1'b0;
      sync_toggle_r3 <= 1'b0;
  end
  else
  begin
      //sync_toggle <= {sync_toggle[1:0],toggle};
	  sync_toggle_r1 <= toggle_r;
	  sync_toggle_r2 <= sync_toggle_r1;
	  sync_toggle_r3 <= sync_toggle_r2;
  end
end

assign pulse_out = sync_toggle_r3 != sync_toggle_r2;

endmodule


