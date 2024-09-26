// FIXME: Support REGMODE=reg also
module lscc_fifo_fwft #(
  parameter WIDTH = 0
)
(
  input                  clk_i    ,
  input                  rst_i    ,
  input                  rd_en_i  ,
  input                  empty_i  ,
  output                 rd_en_o  ,
  input      [WIDTH-1:0] rd_data_i,
  output     [WIDTH-1:0] rd_data_o,
  output                 empty_o
);
   
  reg    out_valid;
  
  assign rd_en_o    = ~empty_i & (~out_valid | (rd_en_i & out_valid));
  assign empty_o    = !out_valid;
  assign rd_data_o  = rd_data_i ;

  always @(posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
      out_valid  <= 1'b0;
    end
    else begin
      if (rd_en_o)
        out_valid <= 1;
      else if (rd_en_i)
        out_valid <= 0;
    end 
  end
  
endmodule
