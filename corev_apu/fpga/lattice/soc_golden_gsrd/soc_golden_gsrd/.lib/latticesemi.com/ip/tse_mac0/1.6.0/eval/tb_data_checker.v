//==========================================================================
// Module : tb_data_checker - Data Checker
//==========================================================================
`include "defines.v"
`include "tb_mem.v"
module tb_data_checker #
// -----------------------------------------------------------------------------
// Module Parameters
// -----------------------------------------------------------------------------
(
parameter WADDR_DEPTH     = 512,
parameter WADDR_WIDTH     = 6,
parameter WDATA_WIDTH     = 64,
parameter RADDR_DEPTH     = 512,
parameter RADDR_WIDTH     = 6,
parameter RDATA_WIDTH     = 64
)
// -----------------------------------------------------------------------------
// Input/Output Ports
// -----------------------------------------------------------------------------
(
input 		              clk_i,
input 		              rst_n_i,
input                     direction_i,
input 		              exp_valid_i,
input [WDATA_WIDTH-1:0]   exp_data_i,
input 		              obs_valid_i,
input [WDATA_WIDTH-1:0]   obs_data_i,
input                     byte_en_i,
input                     eof_i,
output reg                error_o
);
  
// -----------------------------------------------------------------------------
// Combinatorial/Sequential Registers
// -----------------------------------------------------------------------------  
reg [WADDR_WIDTH-1:0] 	  wr_addr;
reg [RADDR_WIDTH-1:0] 	  rd_addr;

reg                       check;
reg [RDATA_WIDTH-1:0] 	  obs_data_Q;
reg                       obs_valid_Q;
integer                   error_count;
reg                       eof_r;
reg                       byte_en_r;
  
// -----------------------------------------------------------------------------
// Wire Declarations
// -----------------------------------------------------------------------------  
wire [RDATA_WIDTH-1:0] 	  rd_data;
reg                       mismatch;

// -----------------------------------------------------------------------------
// Assign Statements
// -----------------------------------------------------------------------------
//assign                        mismatch = check ? (obs_data_Q != rd_data) : 1'b0;

// Comparison of last packet depends on the byte enable
always @* begin
  case ({eof_r, byte_en_r})
    2'b11        : mismatch = check ? (obs_data_Q       != rd_data      ) : 1'b0;
    default      : mismatch = check ? (obs_data_Q       != rd_data      ) : 1'b0;
  endcase 
end	
// -----------------------------------------------------------------------------
// Sequential Blocks
// -----------------------------------------------------------------------------
always @ (posedge clk_i or negedge rst_n_i) begin
  if (~rst_n_i) begin
    wr_addr     <= {WADDR_WIDTH{1'b0}};
    rd_addr     <= {RADDR_WIDTH{1'b0}};
    check       <= 1'b0;
    obs_data_Q  <= {RDATA_WIDTH{1'b0}};
    obs_valid_Q <= 1'b0;
    error_o     <= 1'b0;
	byte_en_r   <= 'h0;
	eof_r       <= 'h0;
  end
  else begin
    wr_addr     <= exp_valid_i ? wr_addr + 1 : wr_addr;
    rd_addr     <= obs_valid_i ? rd_addr + 1 : rd_addr;
    check       <= obs_valid_i;
    obs_data_Q  <= obs_data_i;
    obs_valid_Q <= obs_valid_i;
    error_o     <= ~error_o ? (mismatch ? 1'b1 : error_o) : error_o;
	
    byte_en_r   <= byte_en_i;
	eof_r       <= eof_i;
  end
end // always @ (posedge clk_i or negedge rst_n_i)

// -----------------------------------------------------------------------------
// Initial Block
// -----------------------------------------------------------------------------
initial begin
  error_count = 0;
  while (1) begin
    @(posedge clk_i)
    if (mismatch) begin
      `E_MSG(("data mismatch detected!"))
      `D_MSG(("%s", $sformatf("exp = 8'h%h, obs = 8'h%h",rd_data,obs_data_Q)))
      error_count = error_count + 1;
    end
	else if (check && !mismatch) begin
	  `D_MSG(("data matched!"))
      `D_MSG(("%s", $sformatf("exp = 8'h%h, obs = 8'h%h",rd_data,obs_data_Q)))
	end
  end
  
end // initial begin
  
// -----------------------------------------------------------------------------
// Submodule Instantiations
// -----------------------------------------------------------------------------
tb_mem #(
  .ADDR_DEPTH         (WADDR_DEPTH),
  .DATA_WIDTH         (WDATA_WIDTH)
) u_tb_mem (
  // Outputs
  .rd_data_o	       (rd_data[RDATA_WIDTH-1:0]   ),
  // Inputs
  .clk_i			   (clk_i                      ),
  .rst_n_i			   (rst_n_i                    ),
  .wr_en_i			   (exp_valid_i                ),
  .wr_data_i		   (exp_data_i[WDATA_WIDTH-1:0]),
  .wr_addr_i		   (wr_addr[WADDR_WIDTH-1:0]   ),
  .rd_en_i			   (obs_valid_i | check        ),
  .rd_addr_i		   (rd_addr[RADDR_WIDTH-1:0]   )
);

//------------------------------------------------------------------------------
// Function Definition
//------------------------------------------------------------------------------
// synopsys translate_off
function [31:0] clog2;
  input [31:0] value;
  reg   [31:0] num;
  begin
    num = value - 1;
    for (clog2 = 0; num > 0; clog2 = clog2 + 1) num = num >> 1;
  end
endfunction
// synopsys translate_on

endmodule
