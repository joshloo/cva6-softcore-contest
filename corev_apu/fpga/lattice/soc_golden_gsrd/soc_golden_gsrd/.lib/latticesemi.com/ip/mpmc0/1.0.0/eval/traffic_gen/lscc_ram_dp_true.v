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
// Project               : Radiant Software 3.2
// File                  : lscc_ram_dp_true.v
// Title                 :
// Dependencies          :
// Description           : Implements a true Dual Port RAM using EBR.
// =============================================================================
//                        REVISION HISTORY
// Version               : 1.0.0.
// Author(s)             :
// Mod. Date             :
// Changes Made          : Initial release.
// =============================================================================

`ifndef LSCC_RAM_DP_TRUE
`define LSCC_RAM_DP_TRUE

module lscc_ram_dp_true # (
    parameter    FAMILY            = "common",
    parameter    ADDR_DEPTH_A      = 1024,
    parameter    ADDR_WIDTH_A      = clog2(ADDR_DEPTH_A),
    parameter    DATA_WIDTH_A      = 36,
    parameter    ADDR_DEPTH_B      = 1024,
    parameter    ADDR_WIDTH_B      = clog2(ADDR_DEPTH_B),
    parameter    DATA_WIDTH_B      = 36,
    parameter    REGMODE_A         = "reg",
    parameter    REGMODE_B         = "reg",
    parameter    GSR               = "enable",
    parameter    RESETMODE_A       = "sync",
    parameter    RESETMODE_B       = "sync",
    parameter    RESET_RELEASE_A   = "sync",
    parameter    RESET_RELEASE_B   = "sync",
    parameter    INIT_FILE         = "none",
    parameter    INIT_FILE_FORMAT  = "binary",
    parameter    MODULE_TYPE       = "ram_dp_true",
    parameter    INIT_MODE         = "none",
    parameter    BYTE_ENABLE_A     = 0,
    parameter    BYTE_SIZE_A       = 9,
    parameter    BYTE_WIDTH_A      = (BYTE_ENABLE_A == 1) ? roundUP(DATA_WIDTH_A, BYTE_SIZE_A) : 1,
    parameter    BYTE_EN_POL_A     = "active-high",
    parameter    WRITE_MODE_A      = "normal",
    parameter    BYTE_ENABLE_B     = 0,
    parameter    BYTE_SIZE_B       = 9,
    parameter    BYTE_WIDTH_B      = (BYTE_ENABLE_B == 1) ? roundUP(DATA_WIDTH_B, BYTE_SIZE_B) : 1,
    parameter    BYTE_EN_POL_B     = "active-high",
    parameter    WRITE_MODE_B      = "normal",
    parameter    PIPELINES         = 0,
    parameter    ECC_ENABLE        = 0,
    parameter    MEM_ID            = "MEM0",
    parameter    MEM_SIZE          = "36,1024",
    parameter    INIT_VALUE_00     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_01     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_02     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_03     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_04     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_05     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_06     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_07     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_08     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_09     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_0A     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_0B     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_0C     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_0D     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_0E     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_0F     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_10     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_11     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_12     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_13     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_14     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_15     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_16     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_17     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_18     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_19     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_1A     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_1B     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_1C     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_1D     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_1E     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_1F     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_20     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_21     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_22     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_23     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_24     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_25     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_26     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_27     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_28     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_29     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_2A     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_2B     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_2C     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_2D     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_2E     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_2F     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_30     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_31     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_32     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_33     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_34     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_35     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_36     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_37     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_38     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_39     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_3A     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_3B     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_3C     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_3D     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_3E     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_3F     = "0x0000000000000000000000000000000000000000000000000000000000000000"    
)
// -----------------------------------------------------------------------------
// Input/Output Ports
// -----------------------------------------------------------------------------
(
    input  [ADDR_WIDTH_A-1:0]    addr_a_i,
    input  [ADDR_WIDTH_B-1:0]    addr_b_i,
    input  [DATA_WIDTH_A-1:0]    wr_data_a_i,
    input  [DATA_WIDTH_B-1:0]    wr_data_b_i,
    input                        clk_a_i,
    input                        clk_b_i,
    input                        clk_en_a_i,
    input                        clk_en_b_i,
    input                        wr_en_a_i,
    input                        wr_en_b_i,
    input                        rst_a_i,
    input                        rst_b_i,
    input  [BYTE_WIDTH_A-1:0]    ben_a_i,
    input  [BYTE_WIDTH_B-1:0]    ben_b_i,
    
    output [DATA_WIDTH_A-1:0]    rd_data_a_o,
    output [DATA_WIDTH_B-1:0]    rd_data_b_o,

    output                       ecc_one_err_a_o,
    output                       ecc_two_err_a_o,
    output                       ecc_one_err_b_o,
    output                       ecc_two_err_b_o
);

localparam T_FAMILY = (FAMILY == "LFD2NX" || FAMILY == "LFCPNX" || FAMILY == "LFMXO5" || FAMILY =="UT24C" || FAMILY =="UT24CP") ? "LIFCL" : FAMILY;

lscc_ram_dp_true_main # (
    .FAMILY           (T_FAMILY         ),
    .ADDR_DEPTH_A     (ADDR_DEPTH_A     ),
    .ADDR_WIDTH_A     (ADDR_WIDTH_A     ),
    .DATA_WIDTH_A     (DATA_WIDTH_A     ),
    .ADDR_DEPTH_B     (ADDR_DEPTH_B     ),
    .ADDR_WIDTH_B     (ADDR_WIDTH_B     ),
    .DATA_WIDTH_B     (DATA_WIDTH_B     ),
    .REGMODE_A        (REGMODE_A        ),
    .REGMODE_B        (REGMODE_B        ),
    .GSR              (GSR              ),
    .RESETMODE_A      (RESETMODE_A      ),
    .RESETMODE_B      (RESETMODE_B      ),
    .RESET_RELEASE_A  (RESET_RELEASE_A  ),
    .RESET_RELEASE_B  (RESET_RELEASE_B  ),
    .INIT_FILE        (INIT_FILE        ),
    .INIT_FILE_FORMAT (INIT_FILE_FORMAT ),
    .MODULE_TYPE      (MODULE_TYPE      ),
    .INIT_MODE        (INIT_MODE        ),
    .BYTE_ENABLE_A    (BYTE_ENABLE_A    ),
    .BYTE_SIZE_A      (BYTE_SIZE_A      ),
    .BYTE_WIDTH_A     (BYTE_WIDTH_A     ),
    .BYTE_EN_POL_A    (BYTE_EN_POL_A    ),
    .WRITE_MODE_A     (WRITE_MODE_A     ),
    .BYTE_ENABLE_B    (BYTE_ENABLE_B    ),
    .BYTE_SIZE_B      (BYTE_SIZE_B      ),
    .BYTE_WIDTH_B     (BYTE_WIDTH_B     ),
    .BYTE_EN_POL_B    (BYTE_EN_POL_B    ),
    .WRITE_MODE_B     (WRITE_MODE_B     ),
    .PIPELINES        (PIPELINES        ),
    .ECC_ENABLE       (ECC_ENABLE       ),
    .MEM_ID           (MEM_ID           ),
    .MEM_SIZE         (MEM_SIZE         ),
    .INIT_VALUE_00    (INIT_VALUE_00    ),
    .INIT_VALUE_01    (INIT_VALUE_01    ),
    .INIT_VALUE_02    (INIT_VALUE_02    ),
    .INIT_VALUE_03    (INIT_VALUE_03    ),
    .INIT_VALUE_04    (INIT_VALUE_04    ),
    .INIT_VALUE_05    (INIT_VALUE_05    ),
    .INIT_VALUE_06    (INIT_VALUE_06    ),
    .INIT_VALUE_07    (INIT_VALUE_07    ),
    .INIT_VALUE_08    (INIT_VALUE_08    ),
    .INIT_VALUE_09    (INIT_VALUE_09    ),
    .INIT_VALUE_0A    (INIT_VALUE_0A    ),
    .INIT_VALUE_0B    (INIT_VALUE_0B    ),
    .INIT_VALUE_0C    (INIT_VALUE_0C    ),
    .INIT_VALUE_0D    (INIT_VALUE_0D    ),
    .INIT_VALUE_0E    (INIT_VALUE_0E    ),
    .INIT_VALUE_0F    (INIT_VALUE_0F    ),
    .INIT_VALUE_10    (INIT_VALUE_10    ),
    .INIT_VALUE_11    (INIT_VALUE_11    ),
    .INIT_VALUE_12    (INIT_VALUE_12    ),
    .INIT_VALUE_13    (INIT_VALUE_13    ),
    .INIT_VALUE_14    (INIT_VALUE_14    ),
    .INIT_VALUE_15    (INIT_VALUE_15    ),
    .INIT_VALUE_16    (INIT_VALUE_16    ),
    .INIT_VALUE_17    (INIT_VALUE_17    ),
    .INIT_VALUE_18    (INIT_VALUE_18    ),
    .INIT_VALUE_19    (INIT_VALUE_19    ),
    .INIT_VALUE_1A    (INIT_VALUE_1A    ),
    .INIT_VALUE_1B    (INIT_VALUE_1B    ),
    .INIT_VALUE_1C    (INIT_VALUE_1C    ),
    .INIT_VALUE_1D    (INIT_VALUE_1D    ),
    .INIT_VALUE_1E    (INIT_VALUE_1E    ),
    .INIT_VALUE_1F    (INIT_VALUE_1F    ),
    .INIT_VALUE_20    (INIT_VALUE_20    ),
    .INIT_VALUE_21    (INIT_VALUE_21    ),
    .INIT_VALUE_22    (INIT_VALUE_22    ),
    .INIT_VALUE_23    (INIT_VALUE_23    ),
    .INIT_VALUE_24    (INIT_VALUE_24    ),
    .INIT_VALUE_25    (INIT_VALUE_25    ),
    .INIT_VALUE_26    (INIT_VALUE_26    ),
    .INIT_VALUE_27    (INIT_VALUE_27    ),
    .INIT_VALUE_28    (INIT_VALUE_28    ),
    .INIT_VALUE_29    (INIT_VALUE_29    ),
    .INIT_VALUE_2A    (INIT_VALUE_2A    ),
    .INIT_VALUE_2B    (INIT_VALUE_2B    ),
    .INIT_VALUE_2C    (INIT_VALUE_2C    ),
    .INIT_VALUE_2D    (INIT_VALUE_2D    ),
    .INIT_VALUE_2E    (INIT_VALUE_2E    ),
    .INIT_VALUE_2F    (INIT_VALUE_2F    ),
    .INIT_VALUE_30    (INIT_VALUE_30    ),
    .INIT_VALUE_31    (INIT_VALUE_31    ),
    .INIT_VALUE_32    (INIT_VALUE_32    ),
    .INIT_VALUE_33    (INIT_VALUE_33    ),
    .INIT_VALUE_34    (INIT_VALUE_34    ),
    .INIT_VALUE_35    (INIT_VALUE_35    ),
    .INIT_VALUE_36    (INIT_VALUE_36    ),
    .INIT_VALUE_37    (INIT_VALUE_37    ),
    .INIT_VALUE_38    (INIT_VALUE_38    ),
    .INIT_VALUE_39    (INIT_VALUE_39    ),
    .INIT_VALUE_3A    (INIT_VALUE_3A    ),
    .INIT_VALUE_3B    (INIT_VALUE_3B    ),
    .INIT_VALUE_3C    (INIT_VALUE_3C    ),
    .INIT_VALUE_3D    (INIT_VALUE_3D    ),
    .INIT_VALUE_3E    (INIT_VALUE_3E    ),
    .INIT_VALUE_3F    (INIT_VALUE_3F    )  
) mem_main (
    .addr_a_i         (addr_a_i),
    .addr_b_i         (addr_b_i),
    .wr_data_a_i      (wr_data_a_i),
    .wr_data_b_i      (wr_data_b_i),
    .clk_a_i          (clk_a_i),
    .clk_b_i          (clk_b_i),
    .clk_en_a_i       (clk_en_a_i),
    .clk_en_b_i       (clk_en_b_i),
    .wr_en_a_i        (wr_en_a_i),
    .wr_en_b_i        (wr_en_b_i),
    .rst_a_i          (rst_a_i),
    .rst_b_i          (rst_b_i),
    .ben_a_i          (ben_a_i),
    .ben_b_i          (ben_b_i),

    .rd_data_a_o      (rd_data_a_o),
    .rd_data_b_o      (rd_data_b_o),

    .ecc_one_err_a_o  (ecc_one_err_a_o),
    .ecc_two_err_a_o  (ecc_two_err_a_o),
    .ecc_one_err_b_o  (ecc_one_err_b_o),
    .ecc_two_err_b_o  (ecc_two_err_b_o)
);

function [31:0] clog2;
  input [31:0] value;
  reg   [31:0] num;
  begin
    num = value - 1;
    for (clog2=0; num>0; clog2=clog2+1) num = num>>1;
  end
endfunction

function [31:0] roundUP;
    input [31:0] dividend;
    input [31:0] divisor;
    begin
        if(divisor == 1) begin
            roundUP = dividend;
        end
        else if(divisor == dividend) begin
            roundUP = 1;
        end
        else begin
            roundUP = dividend/divisor + (((dividend % divisor) == 0) ? 0 : 1);
        end
    end
endfunction

endmodule
`endif
// =============================================================================
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
// -----------------------------------------------------------------------------
//   Copyright (c) 2017 by Lattice Semiconductor Corporation
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
// Project               : Radiant Software 1.1
// File                  : lscc_ram_dp_true_main.v
// Title                 :
// Dependencies          :
// Description           : Implements a true Dual Port RAM using EBR.
// =============================================================================
//                        REVISION HISTORY
// Version               : 1.0.0.
// Author(s)             :
// Mod. Date             :
// Changes Made          : Initial release.
// =============================================================================

`ifndef LSCC_RAM_DP_TRUE_MAIN
`define LSCC_RAM_DP_TRUE_MAIN

module lscc_ram_dp_true_main # (
    parameter    _FCODE_LIFCL_     = 1,
    parameter    _FCODE_COMMON_    = 0,
    parameter    FAMILY            = "common",
    parameter    FAMILY_CODE       = ( FAMILY == "LIFCL") ? _FCODE_LIFCL_ : _FCODE_COMMON_,
    parameter    ADDR_DEPTH_A      = 1024,
    parameter    ADDR_WIDTH_A      = clog2(ADDR_DEPTH_A),
    parameter    DATA_WIDTH_A      = 36,
    parameter    ADDR_DEPTH_B      = 1024,
    parameter    ADDR_WIDTH_B      = clog2(ADDR_DEPTH_B),
    parameter    DATA_WIDTH_B      = 36,
    parameter    REGMODE_A         = "reg",
    parameter    REGMODE_B         = "reg",
    parameter    GSR               = "enable",
    parameter    RESETMODE_A       = "sync",
    parameter    RESETMODE_B       = "sync",
    parameter    RESET_RELEASE_A   = "sync",
    parameter    RESET_RELEASE_B   = "sync",
    parameter    INIT_FILE         = "none",
    parameter    INIT_FILE_FORMAT  = "binary",
    parameter    MODULE_TYPE       = "ram_dp_true",
    parameter    INIT_MODE         = "none",
    parameter    BYTE_ENABLE_A     = 0,
    parameter    BYTE_SIZE_A       = getByteSize(DATA_WIDTH_A, FAMILY_CODE),
    parameter    BYTE_WIDTH_A      = (BYTE_ENABLE_A == 1) ? roundUP(DATA_WIDTH_A, BYTE_SIZE_A) : 1,
    parameter    BYTE_EN_POL_A     = "active-high",
    parameter    WRITE_MODE_A      = "normal",
    parameter    BYTE_ENABLE_B     = 0,
    parameter    BYTE_SIZE_B       = getByteSize(DATA_WIDTH_B, FAMILY_CODE),
    parameter    BYTE_WIDTH_B      = (BYTE_ENABLE_B == 1) ? roundUP(DATA_WIDTH_B, BYTE_SIZE_B) : 1,
    parameter    BYTE_EN_POL_B     = "active-high",
    parameter    WRITE_MODE_B      = "normal",
    parameter    PIPELINES         = 0,
    parameter    ECC_ENABLE        = 0,
    parameter    MEM_ID            = "MEM0",
    parameter    MEM_SIZE          = "18,1024",
    parameter    INIT_VALUE_00     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_01     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_02     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_03     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_04     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_05     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_06     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_07     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_08     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_09     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_0A     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_0B     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_0C     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_0D     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_0E     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_0F     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_10     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_11     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_12     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_13     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_14     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_15     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_16     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_17     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_18     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_19     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_1A     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_1B     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_1C     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_1D     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_1E     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_1F     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_20     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_21     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_22     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_23     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_24     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_25     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_26     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_27     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_28     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_29     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_2A     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_2B     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_2C     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_2D     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_2E     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_2F     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_30     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_31     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_32     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_33     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_34     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_35     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_36     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_37     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_38     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_39     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_3A     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_3B     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_3C     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_3D     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_3E     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_3F     = "0x0000000000000000000000000000000000000000000000000000000000000000"    
)
// -----------------------------------------------------------------------------
// Input/Output Ports
// -----------------------------------------------------------------------------
(
    input  [ADDR_WIDTH_A-1:0]    addr_a_i,
    input  [ADDR_WIDTH_B-1:0]    addr_b_i,
    input  [DATA_WIDTH_A-1:0]    wr_data_a_i,
    input  [DATA_WIDTH_B-1:0]    wr_data_b_i,
    input                        clk_a_i,
    input                        clk_b_i,
    input                        clk_en_a_i,
    input                        clk_en_b_i,
    input                        wr_en_a_i,
    input                        wr_en_b_i,
    input                        rst_a_i,
    input                        rst_b_i,
    input  [BYTE_WIDTH_A-1:0]    ben_a_i,
    input  [BYTE_WIDTH_B-1:0]    ben_b_i,
    
    output [DATA_WIDTH_A-1:0]    rd_data_a_o,
    output [DATA_WIDTH_B-1:0]    rd_data_b_o,

    output                       ecc_one_err_a_o,
    output                       ecc_two_err_a_o,
    output                       ecc_one_err_b_o,
    output                       ecc_two_err_b_o
);

wire [DATA_WIDTH_A-1:0] mem_out_a_w;
wire [DATA_WIDTH_B-1:0] mem_out_b_w;

lscc_write_through # (
    .FAMILY     (FAMILY    ),
    .DATA_WIDTH (DATA_WIDTH_A),
    .REGMODE    (REGMODE_A   ),
    .WRITE_MODE (WRITE_MODE_A)
) inst_wr_a (
    .clk_i     (clk_a_i),
    .clk_en_i  (clk_en_a_i),
    .wr_en_i   (wr_en_a_i),
    .rst_i     (rst_a_i),
    .wr_data_i (wr_data_a_i),
    .mem_out_i (mem_out_a_w),
    .rd_data_o (rd_data_a_o)
);

lscc_write_through # (
    .FAMILY     (FAMILY    ),
    .DATA_WIDTH (DATA_WIDTH_B),
    .REGMODE    (REGMODE_B   ),
    .WRITE_MODE (WRITE_MODE_B)
) inst_wr_b (
    .clk_i     (clk_b_i),
    .clk_en_i  (clk_en_b_i),
    .wr_en_i   (wr_en_b_i),
    .rst_i     (rst_b_i),
    .wr_data_i (wr_data_b_i),
    .mem_out_i (mem_out_b_w),
    .rd_data_o (rd_data_b_o)
);

localparam T_REG_MODE_A = (WRITE_MODE_A == "write-through") ? "noreg" : REGMODE_A;
localparam T_REG_MODE_B = (WRITE_MODE_B == "write-through") ? "noreg" : REGMODE_B;

lscc_ram_dp_true_inst # (
    .FAMILY            (FAMILY            ),
    .ADDR_DEPTH_A      (ADDR_DEPTH_A      ),
    .ADDR_WIDTH_A      (ADDR_WIDTH_A      ),
    .DATA_WIDTH_A      (DATA_WIDTH_A      ),
    .ADDR_DEPTH_B      (ADDR_DEPTH_B      ),
    .ADDR_WIDTH_B      (ADDR_WIDTH_B      ),
    .DATA_WIDTH_B      (DATA_WIDTH_B      ),
    .REGMODE_A         (T_REG_MODE_A      ),
    .REGMODE_B         (T_REG_MODE_B      ),
    .GSR               (GSR               ),
    .RESETMODE_A       (RESETMODE_A       ),
    .RESETMODE_B       (RESETMODE_B       ),
    .RESET_RELEASE_A   (RESET_RELEASE_A   ),
    .RESET_RELEASE_B   (RESET_RELEASE_B   ),
    .INIT_FILE         (INIT_FILE         ),
    .INIT_FILE_FORMAT  (INIT_FILE_FORMAT  ),
    .MODULE_TYPE       (MODULE_TYPE       ),
    .INIT_MODE         (INIT_MODE         ),
    .BYTE_ENABLE_A     (BYTE_ENABLE_A     ),
    .BYTE_SIZE_A       (BYTE_SIZE_A       ),
    .BYTE_WIDTH_A      (BYTE_WIDTH_A      ),
    .BYTE_EN_POL_A     (BYTE_EN_POL_A     ),
    .BYTE_ENABLE_B     (BYTE_ENABLE_B     ),
    .BYTE_SIZE_B       (BYTE_SIZE_B       ),
    .BYTE_WIDTH_B      (BYTE_WIDTH_B      ),
    .BYTE_EN_POL_B     (BYTE_EN_POL_B     ),
    .PIPELINES         (PIPELINES         ),
    .ECC_ENABLE        (ECC_ENABLE        ),
    .MEM_ID            (MEM_ID            ),
    .MEM_SIZE          (MEM_SIZE          ),
    .INIT_VALUE_00     (INIT_VALUE_00     ),
    .INIT_VALUE_01     (INIT_VALUE_01     ),
    .INIT_VALUE_02     (INIT_VALUE_02     ),
    .INIT_VALUE_03     (INIT_VALUE_03     ),
    .INIT_VALUE_04     (INIT_VALUE_04     ),
    .INIT_VALUE_05     (INIT_VALUE_05     ),
    .INIT_VALUE_06     (INIT_VALUE_06     ),
    .INIT_VALUE_07     (INIT_VALUE_07     ),
    .INIT_VALUE_08     (INIT_VALUE_08     ),
    .INIT_VALUE_09     (INIT_VALUE_09     ),
    .INIT_VALUE_0A     (INIT_VALUE_0A     ),
    .INIT_VALUE_0B     (INIT_VALUE_0B     ),
    .INIT_VALUE_0C     (INIT_VALUE_0C     ),
    .INIT_VALUE_0D     (INIT_VALUE_0D     ),
    .INIT_VALUE_0E     (INIT_VALUE_0E     ),
    .INIT_VALUE_0F     (INIT_VALUE_0F     ),
    .INIT_VALUE_10     (INIT_VALUE_10     ),
    .INIT_VALUE_11     (INIT_VALUE_11     ),
    .INIT_VALUE_12     (INIT_VALUE_12     ),
    .INIT_VALUE_13     (INIT_VALUE_13     ),
    .INIT_VALUE_14     (INIT_VALUE_14     ),
    .INIT_VALUE_15     (INIT_VALUE_15     ),
    .INIT_VALUE_16     (INIT_VALUE_16     ),
    .INIT_VALUE_17     (INIT_VALUE_17     ),
    .INIT_VALUE_18     (INIT_VALUE_18     ),
    .INIT_VALUE_19     (INIT_VALUE_19     ),
    .INIT_VALUE_1A     (INIT_VALUE_1A     ),
    .INIT_VALUE_1B     (INIT_VALUE_1B     ),
    .INIT_VALUE_1C     (INIT_VALUE_1C     ),
    .INIT_VALUE_1D     (INIT_VALUE_1D     ),
    .INIT_VALUE_1E     (INIT_VALUE_1E     ),
    .INIT_VALUE_1F     (INIT_VALUE_1F     ),
    .INIT_VALUE_20     (INIT_VALUE_20     ),
    .INIT_VALUE_21     (INIT_VALUE_21     ),
    .INIT_VALUE_22     (INIT_VALUE_22     ),
    .INIT_VALUE_23     (INIT_VALUE_23     ),
    .INIT_VALUE_24     (INIT_VALUE_24     ),
    .INIT_VALUE_25     (INIT_VALUE_25     ),
    .INIT_VALUE_26     (INIT_VALUE_26     ),
    .INIT_VALUE_27     (INIT_VALUE_27     ),
    .INIT_VALUE_28     (INIT_VALUE_28     ),
    .INIT_VALUE_29     (INIT_VALUE_29     ),
    .INIT_VALUE_2A     (INIT_VALUE_2A     ),
    .INIT_VALUE_2B     (INIT_VALUE_2B     ),
    .INIT_VALUE_2C     (INIT_VALUE_2C     ),
    .INIT_VALUE_2D     (INIT_VALUE_2D     ),
    .INIT_VALUE_2E     (INIT_VALUE_2E     ),
    .INIT_VALUE_2F     (INIT_VALUE_2F     ),
    .INIT_VALUE_30     (INIT_VALUE_30     ),
    .INIT_VALUE_31     (INIT_VALUE_31     ),
    .INIT_VALUE_32     (INIT_VALUE_32     ),
    .INIT_VALUE_33     (INIT_VALUE_33     ),
    .INIT_VALUE_34     (INIT_VALUE_34     ),
    .INIT_VALUE_35     (INIT_VALUE_35     ),
    .INIT_VALUE_36     (INIT_VALUE_36     ),
    .INIT_VALUE_37     (INIT_VALUE_37     ),
    .INIT_VALUE_38     (INIT_VALUE_38     ),
    .INIT_VALUE_39     (INIT_VALUE_39     ),
    .INIT_VALUE_3A     (INIT_VALUE_3A     ),
    .INIT_VALUE_3B     (INIT_VALUE_3B     ),
    .INIT_VALUE_3C     (INIT_VALUE_3C     ),
    .INIT_VALUE_3D     (INIT_VALUE_3D     ),
    .INIT_VALUE_3E     (INIT_VALUE_3E     ),
    .INIT_VALUE_3F     (INIT_VALUE_3F     )
) uinst_0 (
    .addr_a_i          (addr_a_i          ),
    .addr_b_i          (addr_b_i          ),
    .wr_data_a_i       (wr_data_a_i       ),
    .wr_data_b_i       (wr_data_b_i       ),
    .clk_a_i           (clk_a_i           ),
    .clk_b_i           (clk_b_i           ),
    .clk_en_a_i        (clk_en_a_i        ),
    .clk_en_b_i        (clk_en_b_i        ),
    .wr_en_a_i         (wr_en_a_i         ),
    .wr_en_b_i         (wr_en_b_i         ),
    .rst_a_i           (rst_a_i           ),
    .rst_b_i           (rst_b_i           ),
    .ben_a_i           (ben_a_i           ),
    .ben_b_i           (ben_b_i           ),

    .rd_data_a_o       (mem_out_a_w       ),
    .rd_data_b_o       (mem_out_b_w       ),

    .ecc_one_err_a_o   (ecc_one_err_a_o   ),
    .ecc_two_err_a_o   (ecc_two_err_a_o   ),
    .ecc_one_err_b_o   (ecc_one_err_b_o   ),
    .ecc_two_err_b_o   (ecc_two_err_b_o   )
);

//------------------------------------------------------------------------------
// Function Definition
//------------------------------------------------------------------------------

function [31:0] getByteSize;
    input [31:0] data_width;
    input [31:0] dev_code;
    begin
        case(dev_code)
            _FCODE_LIFCL_:
            begin
                if(data_width%9 == 0) getByteSize = 9;
                else getByteSize = 8;
            end
            default: getByteSize = 8;
        endcase
    end
endfunction

function [31:0] roundUP;
    input [31:0] dividend;
    input [31:0] divisor;
    begin
        if(divisor == 1) begin
            roundUP = dividend;
        end
        else if(divisor == dividend) begin
            roundUP = 1;
        end
        else begin
            roundUP = dividend/divisor + (((dividend % divisor) == 0) ? 0 : 1);
        end
    end
endfunction

function [31:0] clog2;
  input [31:0] value;
  reg   [31:0] num;
  begin
    num = value - 1;
    for (clog2=0; num>0; clog2=clog2+1) num = num>>1;
  end
endfunction

endmodule
`endif

`ifndef LSCC_WRITE_THROUGH
`define LSCC_WRITE_THROUGH

module lscc_write_through # (
    parameter FAMILY     = "common",
    parameter DATA_WIDTH = 36,
    parameter REGMODE    = "noreg",
    parameter WRITE_MODE = "normal"
)(
    input clk_i,
    input clk_en_i,
    input wr_en_i,
    input rst_i,
    input [DATA_WIDTH-1:0] wr_data_i,
    input [DATA_WIDTH-1:0] mem_out_i,
    output [DATA_WIDTH-1:0] rd_data_o
);

if(WRITE_MODE == "write-through") begin : WRITE_THROUGH
    reg [DATA_WIDTH-1:0] wr_data_p_r;
    reg wr_en_p_r;
    always @ (posedge clk_i, posedge rst_i) begin
        if(rst_i) begin
            wr_data_p_r <= {DATA_WIDTH{1'b0}};
            wr_en_p_r <= 1'b0;
        end
        else begin
            wr_data_p_r <= wr_data_i;
            wr_en_p_r <= wr_en_i;
        end
    end
    if(REGMODE == "noreg" ) begin : _NoRegMode
        assign rd_data_o = (wr_en_p_r) ? wr_data_p_r : mem_out_i;
    end
    else begin : _RegMode
        reg [DATA_WIDTH-1:0] rd_data_r;
        wire [DATA_WIDTH-1:0] rd_data_nxt_w = (wr_en_p_r) ? wr_data_p_r : mem_out_i;
        assign rd_data_o = rd_data_r;
        
        always @ (posedge clk_i, posedge rst_i) begin
            if(rst_i) begin
                rd_data_r <= {DATA_WIDTH{1'b0}};
            end
            else begin
                rd_data_r <= rd_data_nxt_w;
            end
        end 
    end
end
else begin : NORMAL
    assign rd_data_o = mem_out_i;
end

endmodule
`endif

// =============================================================================
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
// -----------------------------------------------------------------------------
//   Copyright (c) 2017 by Lattice Semiconductor Corporation
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
// Project               : Radiant Software 1.1
// File                  : lscc_ram_dp_true_inst.v
// Title                 :
// Dependencies          :
// Description           : Implements a true Dual Port RAM using EBR.
// =============================================================================
//                        REVISION HISTORY
// Version               : 1.0.0.
// Author(s)             :
// Mod. Date             :
// Changes Made          : Initial release.
// =============================================================================

`ifndef LSCC_RAM_DP_TRUE_INST
`define LSCC_RAM_DP_TRUE_INST

module lscc_ram_dp_true_inst # (
    parameter    _FCODE_LIFCL_     = 1,
    parameter    _FCODE_COMMON_    = 0,
    parameter    FAMILY            = "common",
    parameter    FAMILY_CODE       = ( FAMILY == "LIFCL") ? _FCODE_LIFCL_ : _FCODE_COMMON_,
    parameter    ADDR_DEPTH_A      = 1024,
    parameter    ADDR_WIDTH_A      = clog2(ADDR_DEPTH_A),
    parameter    DATA_WIDTH_A      = 36,
    parameter    ADDR_DEPTH_B      = 1024,
    parameter    ADDR_WIDTH_B      = clog2(ADDR_DEPTH_B),
    parameter    DATA_WIDTH_B      = 36,
    parameter    REGMODE_A         = "reg",
    parameter    REGMODE_B         = "reg",
    parameter    GSR               = "enable",
    parameter    RESETMODE_A       = "sync",
    parameter    RESETMODE_B       = "sync",
    parameter    RESET_RELEASE_A   = "sync",
    parameter    RESET_RELEASE_B   = "sync",
    parameter    INIT_FILE         = "none",
    parameter    INIT_FILE_FORMAT  = "binary",
    parameter    MODULE_TYPE       = "ram_dp_true",
    parameter    INIT_MODE         = "none",
    parameter    BYTE_ENABLE_A     = 0,
    parameter    BYTE_SIZE_A       = getByteSize(DATA_WIDTH_A, FAMILY_CODE),
    parameter    BYTE_WIDTH_A      = (BYTE_ENABLE_A == 1) ? roundUP(DATA_WIDTH_A, BYTE_SIZE_A) : 1,
    parameter    BYTE_EN_POL_A     = "active-high",
    parameter    BYTE_ENABLE_B     = 0,
    parameter    BYTE_SIZE_B       = getByteSize(DATA_WIDTH_B, FAMILY_CODE),
    parameter    BYTE_WIDTH_B      = (BYTE_ENABLE_B == 1) ? roundUP(DATA_WIDTH_B, BYTE_SIZE_B) : 1,
    parameter    BYTE_EN_POL_B     = "active-high",
    parameter    PIPELINES         = 0,
    parameter    ECC_ENABLE        = 0,
    parameter    MEM_ID            = "MEM0",
    parameter    MEM_SIZE          = "18,1024",
    parameter    INIT_VALUE_00     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_01     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_02     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_03     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_04     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_05     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_06     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_07     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_08     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_09     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_0A     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_0B     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_0C     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_0D     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_0E     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_0F     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_10     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_11     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_12     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_13     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_14     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_15     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_16     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_17     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_18     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_19     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_1A     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_1B     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_1C     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_1D     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_1E     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_1F     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_20     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_21     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_22     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_23     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_24     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_25     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_26     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_27     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_28     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_29     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_2A     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_2B     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_2C     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_2D     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_2E     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_2F     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_30     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_31     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_32     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_33     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_34     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_35     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_36     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_37     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_38     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_39     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_3A     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_3B     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_3C     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_3D     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_3E     = "0x0000000000000000000000000000000000000000000000000000000000000000",
    parameter    INIT_VALUE_3F     = "0x0000000000000000000000000000000000000000000000000000000000000000"    
)
// -----------------------------------------------------------------------------
// Input/Output Ports
// -----------------------------------------------------------------------------
(
    input  [ADDR_WIDTH_A-1:0]    addr_a_i,
    input  [ADDR_WIDTH_B-1:0]    addr_b_i,
    input  [DATA_WIDTH_A-1:0]    wr_data_a_i,
    input  [DATA_WIDTH_B-1:0]    wr_data_b_i,
    input                        clk_a_i,
    input                        clk_b_i,
    input                        clk_en_a_i,
    input                        clk_en_b_i,
    input                        wr_en_a_i,
    input                        wr_en_b_i,
    input                        rst_a_i,
    input                        rst_b_i,
    input  [BYTE_WIDTH_A-1:0]    ben_a_i,
    input  [BYTE_WIDTH_B-1:0]    ben_b_i,
    
    output [DATA_WIDTH_A-1:0]    rd_data_a_o,
    output [DATA_WIDTH_B-1:0]    rd_data_b_o,

    output                       ecc_one_err_a_o,
    output                       ecc_two_err_a_o,
    output                       ecc_one_err_b_o,
    output                       ecc_two_err_b_o
);

localparam STRING_LENGTH = 82;

genvar i0, i1, i_0, i_1;
generate
    if(FAMILY == "common") begin : behavioral
        reg [DATA_WIDTH_A-1:0] mem [(2**ADDR_WIDTH_A)-1:0] /* synthesis syn_ramstyle="block_ram" */;

        integer mem_i0;
        initial begin
            if(INIT_MODE == "mem_file" && INIT_FILE != "none") begin
                if(INIT_FILE_FORMAT == "hex") begin 
                    $readmemh(INIT_FILE, mem, 0, ADDR_DEPTH_A-1);
                end
                else begin
                    $readmemb(INIT_FILE, mem, 0, ADDR_DEPTH_A-1);
                end
            end
        end

        reg [DATA_WIDTH_A-1:0] dataout_reg_a_r      = {DATA_WIDTH_A{1'b0}};
        reg [DATA_WIDTH_A-1:0] dataout_reg_buff_a_r = {DATA_WIDTH_A{1'b0}};

        
        assign rd_data_a_o = (REGMODE_A == "reg") ? dataout_reg_a_r : dataout_reg_buff_a_r;
        
        always @ (posedge clk_a_i) begin
            if(clk_en_a_i == 1'b1) begin
                if(wr_en_a_i == 1'b1) begin
                    mem[addr_a_i] <= wr_data_a_i;
                end
                else begin
                    dataout_reg_buff_a_r <= mem[addr_a_i];
                end
            end
        end
        
        if(REGMODE_A == "reg") begin : _reg_a
            if(RESETMODE_A == "sync") begin : _sync_rst_a
                always @ (posedge clk_a_i) begin
                    if(rst_a_i == 1'b1) begin
                        dataout_reg_a_r <= 'h0;
                    end
                    else if(wr_en_a_i == 1'b0) begin 
                        dataout_reg_a_r <= dataout_reg_buff_a_r;
                    end
                end
            end
            else if(RESET_RELEASE_A == "sync") begin : _sync_rel_a
                always @ (posedge clk_a_i, posedge rst_a_i) begin
                    if(rst_a_i == 1'b1) begin 
                        dataout_reg_a_r <= 'h0;
                    end
                    else if(wr_en_a_i == 1'b0) begin 
                        dataout_reg_a_r <= dataout_reg_buff_a_r;
                    end
                end
            end
            else begin : _async_rel_a
                reg [DATA_WIDTH_A-1:0] dataout_reg_a_buffered_r = {DATA_WIDTH_A{1'b0}};
                always @ * begin
                    if(rst_a_i == 1'b1) begin 
                        dataout_reg_a_r = 'h0;
                    end
                    else if(wr_en_a_i == 1'b0) begin 
                        dataout_reg_a_r = dataout_reg_a_buffered_r;
                    end
                end
                always @ (posedge clk_a_i) begin
                    dataout_reg_a_buffered_r <= dataout_reg_buff_a_r;
                end
            end
        end
        
        reg [DATA_WIDTH_B-1:0] dataout_reg_b_r      = {DATA_WIDTH_B{1'b0}};
        reg [DATA_WIDTH_B-1:0] dataout_reg_buff_b_r = {DATA_WIDTH_B{1'b0}};

        
        assign rd_data_b_o = (REGMODE_B == "reg") ? dataout_reg_b_r : dataout_reg_buff_b_r;
        
        always @ (posedge clk_b_i) begin
            if(clk_en_b_i == 1'b1) begin
                if(wr_en_b_i == 1'b1) begin
                    mem[addr_b_i] <= wr_data_b_i;
                end
                else begin
                    dataout_reg_buff_b_r <= mem[addr_b_i];
                end
            end
        end
        
        if(REGMODE_B == "reg") begin : _reg_b
            if(RESETMODE_B == "sync") begin : _sync_rst_b
                always @ (posedge clk_b_i) begin
                    if(rst_b_i == 1'b1) begin
                        dataout_reg_b_r <= 'h0;
                    end
                    else if(wr_en_b_i == 1'b0) begin 
                        dataout_reg_b_r <= dataout_reg_buff_b_r;
                    end
                end
            end
            else if(RESET_RELEASE_B == "sync") begin : _sync_rel_b
                always @ (posedge clk_b_i, posedge rst_b_i) begin
                    if(rst_b_i == 1'b1) begin 
                        dataout_reg_b_r <= 'h0;
                    end
                    else if(wr_en_b_i == 1'b0) begin 
                        dataout_reg_b_r <= dataout_reg_buff_b_r;
                    end
                end
            end
            else begin : _async_rel_b
                reg [DATA_WIDTH_B-1:0] dataout_reg_b_buffered_r = {DATA_WIDTH_B{1'b0}};
                always @ * begin
                    if(rst_b_i == 1'b1) begin 
                        dataout_reg_b_r = 'h0;
                    end
                    else if(wr_en_b_i == 1'b0) begin 
                        dataout_reg_b_r = dataout_reg_b_buffered_r;
                    end
                end
                always @ (posedge clk_b_i) begin
                    dataout_reg_b_buffered_r <= dataout_reg_buff_b_r;
                end
            end
        end
    end
    else begin : prim
        // ---------------------------------------
        // ------ SAME WIDTH Implementation ------
        // ---------------------------------------
        if(ADDR_DEPTH_A == ADDR_DEPTH_B && DATA_WIDTH_A == DATA_WIDTH_B) begin : NON_MIX
            // ---------------------------------------------------
            // ------ Local Parameters for EBR Optimization ------
            // ---------------------------------------------------
            localparam OPT_DATA_WIDTH = getMinimaData(ADDR_DEPTH_A, DATA_WIDTH_A, BYTE_ENABLE_A || BYTE_ENABLE_B, BYTE_SIZE_A, FAMILY_CODE);
            localparam OPT_ADDR_DEPTH = data_to_addr(OPT_DATA_WIDTH, FAMILY_CODE);
            localparam OPT_ADDR_WIDTH = clog2(OPT_ADDR_DEPTH);
            localparam EBR_DATA = roundUP(DATA_WIDTH_A, OPT_DATA_WIDTH);
            localparam EBR_ADDR = roundUP(ADDR_DEPTH_A, OPT_ADDR_DEPTH);
            localparam BWID_A   = (BYTE_ENABLE_A == 0) ? 1 :
                                  (OPT_DATA_WIDTH == 18 || OPT_DATA_WIDTH == 16) ? 2 : 1;
            localparam BWID_B   = (BYTE_ENABLE_B == 0) ? 1 :
                                  (OPT_DATA_WIDTH == 18 || OPT_DATA_WIDTH == 16) ? 2 : 1;

            // ------ PORT A & B Output MUX ------
            wire [DATA_WIDTH_A-1:0] rd_data_raw_a_w [EBR_ADDR-1:0];
            wire [DATA_WIDTH_B-1:0] rd_data_raw_b_w [EBR_ADDR-1:0];

            // ------ PORT A Address Wiring ------
            wire [OPT_ADDR_WIDTH-1:0] addr_a_w;
            if(OPT_ADDR_WIDTH > ADDR_WIDTH_A) begin : port_a_wiring
                assign addr_a_w [ADDR_WIDTH_A-1:0] = addr_a_i;
                assign addr_a_w [OPT_ADDR_WIDTH-1:ADDR_WIDTH_A] = {(OPT_ADDR_WIDTH-ADDR_WIDTH_A){1'b0}};
            end
            else begin
                assign addr_a_w = addr_a_i[OPT_ADDR_WIDTH-1:0];
            end

            // ------ PORT B Address Wiring ------
            wire [OPT_ADDR_WIDTH-1:0] addr_b_w;
            if(OPT_ADDR_WIDTH > ADDR_WIDTH_B) begin : port_b_wiring
                assign addr_b_w [ADDR_WIDTH_B-1:0] = addr_b_i;
                assign addr_b_w [OPT_ADDR_WIDTH-1:ADDR_WIDTH_B] = {(OPT_ADDR_WIDTH-ADDR_WIDTH_B){1'b0}};
            end
            else begin
                assign addr_b_w = addr_b_i[OPT_ADDR_WIDTH-1:0];
            end

            // ------ Address Loop (Same Width) ------
            for(i0 = 0; i0 < EBR_ADDR; i0 = i0 + 1) begin : xADDR

                // ------ PORT A output ports ------
                wire [DATA_WIDTH_A-1:0] raw_out_a_w;
                assign rd_data_raw_a_w[i0] = raw_out_a_w;

                // ------ PORT A Address Control Signal ------
                wire chk_addr_a_w;
                if(EBR_ADDR > 1) begin
                    assign chk_addr_a_w = (addr_a_i[ADDR_WIDTH_A-1:OPT_ADDR_WIDTH] == i0) ? 1'b1 : 1'b0;
                end
                else begin
                    assign chk_addr_a_w = 1'b1;
                end

                // ------ PORT B output ports ------
                wire [DATA_WIDTH_B-1:0] raw_out_b_w;
                assign rd_data_raw_b_w[i0] = raw_out_b_w;
                // ------ PORT B Address Control Signal ------
                wire chk_addr_b_w;
                if(EBR_ADDR > 1) begin 
                    assign chk_addr_b_w = (addr_b_i[ADDR_WIDTH_B-1:OPT_ADDR_WIDTH] == i0) ? 1'b1 : 1'b0;
                end
                else begin
                    assign chk_addr_b_w = 1'b1;
                end

                // ------ Data Loop (Same Width) ------
                for(i1 = 0; i1 < EBR_DATA; i1 = i1 + 1) begin : xDATA

                    localparam ECO_POSX = i1 * OPT_DATA_WIDTH;
                    localparam ECO_POSY = i0 * OPT_ADDR_DEPTH;

                    // ------ PORT A Data Wiring ------
                    wire [OPT_DATA_WIDTH-1:0] in_a_w;
                    wire [OPT_DATA_WIDTH-1:0] out_a_w;

                    if(OPT_DATA_WIDTH*(i1+1) < DATA_WIDTH_A) begin : ASSIGN_A
                        assign in_a_w = wr_data_a_i[OPT_DATA_WIDTH*(i1+1)-1:OPT_DATA_WIDTH*(i1)];
                        assign raw_out_a_w [OPT_DATA_WIDTH*(i1+1)-1:OPT_DATA_WIDTH*(i1)] = out_a_w;
                    end
                    else begin
                        assign in_a_w[DATA_WIDTH_A-(1+OPT_DATA_WIDTH*(i1)):0] = wr_data_a_i[DATA_WIDTH_A-1:OPT_DATA_WIDTH*(i1)];
                        if(OPT_DATA_WIDTH > DATA_WIDTH_A-(OPT_DATA_WIDTH*(i1))) begin
                            assign in_a_w[OPT_DATA_WIDTH-1:DATA_WIDTH_A-(OPT_DATA_WIDTH*(i1))] = {(OPT_DATA_WIDTH-(DATA_WIDTH_A-(OPT_DATA_WIDTH*(i1)))){1'b0}};
                        end
                        assign raw_out_a_w [DATA_WIDTH_A-1:OPT_DATA_WIDTH*(i1)] = out_a_w[DATA_WIDTH_A-(1+OPT_DATA_WIDTH*(i1)):0];
                    end

                    // ------ PORT B Data Wiring ------
                    wire [OPT_DATA_WIDTH-1:0] in_b_w;
                    wire [OPT_DATA_WIDTH-1:0] out_b_w;

                    if(OPT_DATA_WIDTH*(i1+1) < DATA_WIDTH_B) begin : ASSIGN_B
                        assign in_b_w = wr_data_b_i[OPT_DATA_WIDTH*(i1+1)-1:OPT_DATA_WIDTH*(i1)];
                        assign raw_out_b_w [OPT_DATA_WIDTH*(i1+1)-1:OPT_DATA_WIDTH*(i1)] = out_b_w;
                    end
                    else begin
                        assign in_b_w[DATA_WIDTH_B-(1+OPT_DATA_WIDTH*(i1)):0] = wr_data_b_i[DATA_WIDTH_B-1:OPT_DATA_WIDTH*(i1)];
                        if(OPT_DATA_WIDTH > DATA_WIDTH_B-(OPT_DATA_WIDTH*(i1))) begin
                            assign in_b_w[OPT_DATA_WIDTH-1:DATA_WIDTH_B-(OPT_DATA_WIDTH*(i1))] = {(OPT_DATA_WIDTH-(DATA_WIDTH_B-(OPT_DATA_WIDTH*(i1)))){1'b0}};
                        end
                        assign raw_out_b_w [DATA_WIDTH_B-1:OPT_DATA_WIDTH*(i1)] = out_b_w[DATA_WIDTH_B-(1+OPT_DATA_WIDTH*(i1)):0];
                    end

                    wire [BWID_A-1:0] ben_a_w;
                    wire [BWID_B-1:0] ben_b_w;

                    // ------ Byte-Enable Wiring ------
                    if(BWID_A == 2) begin : BEN_MULT_A
                        if(BYTE_ENABLE_A == 1) begin
                            if((i1+1)*BWID_A < BYTE_WIDTH_A) begin : _A
                                assign ben_a_w = ben_a_i[((i1+1)*BWID_A)-1: i1*BWID_A];
                            end
                            else begin
                                assign ben_a_w[BYTE_WIDTH_A-(1+i1*BWID_A):0] = ben_a_i[BYTE_WIDTH_A-1:i1*BWID_A];
                                if((i1+1)*BWID_A > BYTE_WIDTH_A) begin
                                    assign ben_a_w[BWID_A-1:BYTE_WIDTH_A-(i1*BWID_A)] = {(BWID_A - (BYTE_WIDTH_A-(i1*BWID_A))){1'b0}};
                                end
                            end
                        end
                        else begin
                            assign ben_a_w = {BWID_A{1'b1}};
                        end
                    end
                    else begin : BEN_SING_A
                        if(BYTE_ENABLE_A == 1) begin
                            if(OPT_DATA_WIDTH >= 8) begin 
                                assign ben_a_w = ben_a_i[i1];
                            end
                            else begin
                                assign ben_a_w = ben_a_i[i1*OPT_DATA_WIDTH*BYTE_WIDTH_A/DATA_WIDTH_A];
                            end
                        end
                        else begin
                            assign ben_a_w = {BWID_A{1'b1}};
                        end
                    end

                    if(BWID_B == 2) begin : BEN_MULT_B
                        if(BYTE_ENABLE_B == 1) begin
                            if((i1+1)*2 < BYTE_WIDTH_B) begin : _B
                                assign ben_b_w = ben_b_i[((i1+1)*BWID_B)-1: i1*BWID_B];
                            end
                            else begin
                                assign ben_b_w[BYTE_WIDTH_B-(1+i1*BWID_B):0] = ben_b_i[BYTE_WIDTH_B-1:i1*BWID_B];
                                if((i1+1)*BWID_B > BYTE_WIDTH_B) begin
                                    assign ben_b_w[BWID_B-1:BYTE_WIDTH_B-(i1*BWID_B)] = {(BWID_B-(BYTE_WIDTH_B-(i1*BWID_B))){1'b0}};
                                end
                            end
                        end
                        else begin
                            assign ben_b_w = {BWID_B{1'b1}};
                        end
                    end
                    else begin : BEN_SING_B
                        if(BYTE_ENABLE_B == 1) begin
                            if(OPT_DATA_WIDTH >= 8) begin 
                                assign ben_b_w = ben_b_i[i1];
                            end
                            else begin
                                assign ben_b_w = ben_b_i[i1*OPT_DATA_WIDTH*BYTE_WIDTH_B/DATA_WIDTH_B];
                            end
                        end
                        else begin
                            assign ben_b_w = {BWID_B{1'b1}};
                        end
                    end
                    // ------------------------------------
                    // ------ SINGLE MEMORY INSTANCE ------
                    // ------------------------------------
                    if(INIT_MODE == "mem_file") begin : mem_file
                        lscc_ram_dp_true_core # (
                            // ------ COMMON PARAMETERS ------
                            .FAMILY          (FAMILY),
                            .INIT_MODE       (INIT_MODE),
                            .MEM_SIZE        (MEM_SIZE),
                            .MEM_ID          (MEM_ID),
                            .POSx            (ECO_POSX),
                            .POSy            (ECO_POSY),
                        
                            // ------ PORT A PARAMETERS ------
                            .DATA_WIDTH_A   (OPT_DATA_WIDTH),
                            .REGMODE_A      (REGMODE_A),
                            .RESETMODE_A    (RESETMODE_A),
                            .RESET_RELEASE_A(RESET_RELEASE_A),
                            .BYTE_ENABLE_A  (BYTE_ENABLE_A),
                            .BYTE_EN_POL_A  (BYTE_EN_POL_A),
                        
                            // ------ PORT B PARAMETERS ------
                            .DATA_WIDTH_B   (OPT_DATA_WIDTH),
                            .REGMODE_B      (REGMODE_B),
                            .RESETMODE_B    (RESETMODE_B),
                            .RESET_RELEASE_B(RESET_RELEASE_B),
                            .BYTE_ENABLE_B  (BYTE_ENABLE_B),
                            .BYTE_EN_POL_B  (BYTE_EN_POL_B),

                            // ------ INIT PARAMETERS ------
                            .INITVAL_00(INIT_VALUE_00[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8]),
                            .INITVAL_01(INIT_VALUE_01[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8]),
                            .INITVAL_02(INIT_VALUE_02[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8]),
                            .INITVAL_03(INIT_VALUE_03[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8]),
                            .INITVAL_04(INIT_VALUE_04[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8]),
                            .INITVAL_05(INIT_VALUE_05[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8]),
                            .INITVAL_06(INIT_VALUE_06[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8]),
                            .INITVAL_07(INIT_VALUE_07[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8]),
                            .INITVAL_08(INIT_VALUE_08[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8]),
                            .INITVAL_09(INIT_VALUE_09[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8]),
                            .INITVAL_0A(INIT_VALUE_0A[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8]),
                            .INITVAL_0B(INIT_VALUE_0B[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8]),
                            .INITVAL_0C(INIT_VALUE_0C[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8]),
                            .INITVAL_0D(INIT_VALUE_0D[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8]),
                            .INITVAL_0E(INIT_VALUE_0E[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8]),
                            .INITVAL_0F(INIT_VALUE_0F[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8]),
                            .INITVAL_10(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_10[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_11(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_11[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_12(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_12[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_13(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_13[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_14(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_14[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_15(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_15[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_16(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_16[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_17(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_17[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_18(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_18[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_19(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_19[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_1A(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_1A[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_1B(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_1B[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_1C(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_1C[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_1D(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_1D[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_1E(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_1E[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_1F(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_1F[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_20(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_20[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_21(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_21[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_22(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_22[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_23(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_23[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_24(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_24[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_25(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_25[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_26(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_26[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_27(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_27[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_28(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_28[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_29(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_29[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_2A(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_2A[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_2B(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_2B[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_2C(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_2C[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_2D(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_2D[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_2E(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_2E[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_2F(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_2F[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_30(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_30[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_31(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_31[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_32(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_32[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_33(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_33[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_34(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_34[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_35(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_35[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_36(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_36[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_37(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_37[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_38(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_38[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_39(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_39[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_3A(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_3A[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_3B(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_3B[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_3C(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_3C[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_3D(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_3D[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_3E(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_3E[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_3F(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_3F[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00")
                        ) u_dp16k (
                            // ------ PORT A signals ------
                            .clk_a_i    (clk_a_i),
                            .clk_en_a_i (clk_en_a_i),
                            .rst_a_i    (rst_a_i),
                            .wr_en_a_i  (wr_en_a_i & chk_addr_a_w),
                            .ben_a_i    (ben_a_w),
                            .addr_a_i   (addr_a_w),
                            .wr_data_a_i(in_a_w),
                        
                            .rd_data_a_o(out_a_w),
                        
                            // ------ PORT B signals ------
                            .clk_b_i    (clk_b_i),
                            .clk_en_b_i (clk_en_b_i),
                            .rst_b_i    (rst_b_i),
                            .wr_en_b_i  (wr_en_b_i & chk_addr_b_w),
                            .ben_b_i    (ben_b_w),
                            .addr_b_i   (addr_b_w),
                            .wr_data_b_i(in_b_w),
                        
                            .rd_data_b_o(out_b_w)
                        );
                    end
                    else begin : no_mem_file
                        lscc_ram_dp_true_core # (
                            // ------ COMMON PARAMETERS ------
                            .FAMILY          (FAMILY),
                            .INIT_MODE       (INIT_MODE),
                            .MEM_SIZE        (MEM_SIZE),
                            .MEM_ID          (MEM_ID),
                            .POSx            (ECO_POSX),
                            .POSy            (ECO_POSY),
                        
                            // ------ PORT A PARAMETERS ------
                            .DATA_WIDTH_A   (OPT_DATA_WIDTH),
                            .REGMODE_A      (REGMODE_A),
                            .RESETMODE_A    (RESETMODE_A),
                            .RESET_RELEASE_A(RESET_RELEASE_A),
                            .BYTE_ENABLE_A  (BYTE_ENABLE_A),
                            .BYTE_EN_POL_A  (BYTE_EN_POL_A),
                        
                            // ------ PORT B PARAMETERS ------
                            .DATA_WIDTH_B   (OPT_DATA_WIDTH),
                            .REGMODE_B      (REGMODE_B),
                            .RESETMODE_B    (RESETMODE_B),
                            .RESET_RELEASE_B(RESET_RELEASE_B),
                            .BYTE_ENABLE_B  (BYTE_ENABLE_B),
                            .BYTE_EN_POL_B  (BYTE_EN_POL_B)
                        ) u_dp16k (
                            // ------ PORT A signals ------
                            .clk_a_i    (clk_a_i),
                            .clk_en_a_i (clk_en_a_i),
                            .rst_a_i    (rst_a_i),
                            .wr_en_a_i  (wr_en_a_i & chk_addr_a_w),
                            .ben_a_i    (ben_a_w),
                            .addr_a_i   (addr_a_w),
                            .wr_data_a_i(in_a_w),
                        
                            .rd_data_a_o(out_a_w),
                        
                            // ------ PORT B signals ------
                            .clk_b_i    (clk_b_i),
                            .clk_en_b_i (clk_en_b_i),
                            .rst_b_i    (rst_b_i),
                            .wr_en_b_i  (wr_en_b_i & chk_addr_b_w),
                            .ben_b_i    (ben_b_w),
                            .addr_b_i   (addr_b_w),
                            .wr_data_b_i(in_b_w),
                        
                            .rd_data_b_o(out_b_w)
                        );
                    end
                end
            end
            if(EBR_ADDR == 1) begin : ONE_OUT
                assign rd_data_a_o = rd_data_raw_a_w[0];
                assign rd_data_b_o = rd_data_raw_b_w[0];
            end
            else begin : MULT_OUT
                // ------ PORT A output assignment
                reg [DATA_WIDTH_A-1:0] a_out_buff_r;
                reg [ADDR_WIDTH_A-1:0] addr_a_p_r;
                assign rd_data_a_o = a_out_buff_r;
            
                // synthesis translate_off
                initial begin
                    a_out_buff_r = {DATA_WIDTH_A{1'b0}};
                    addr_a_p_r   = {ADDR_WIDTH_A{1'b0}};
                end
                // synthesis translate_on

                always @ (*) begin
                    a_out_buff_r = rd_data_raw_a_w[addr_a_p_r[ADDR_WIDTH_A-1:OPT_ADDR_WIDTH]];
                end
                
                if(REGMODE_A == "noreg") begin
                    if(RESETMODE_A == "sync") begin
                        always @ (posedge clk_a_i) begin
                            if(rst_a_i) begin
                                addr_a_p_r <= {ADDR_WIDTH_A{1'b0}};
                            end
                            else begin
                                addr_a_p_r <= addr_a_i;
                            end
                        end
                    end
                    else begin
                        always @ (posedge clk_a_i, posedge rst_a_i) begin
                            if(rst_a_i) begin
                                addr_a_p_r <= {ADDR_WIDTH_A{1'b0}};
                            end
                            else begin
                                addr_a_p_r <= addr_a_i;
                            end
                        end
                    end
                end
                else begin
                    reg [ADDR_WIDTH_A-1:0] addr_a_p2_r;

                    // synthesis translate_off
                    initial begin
                        addr_a_p2_r  = {ADDR_WIDTH_A{1'b0}};
                    end
                    // synthesis translate_on

                    if(RESETMODE_A == "sync") begin
                        always @ (posedge clk_a_i) begin
                            if(rst_a_i) begin
                                addr_a_p2_r <= {ADDR_WIDTH_A{1'b0}};
                                addr_a_p_r <= {ADDR_WIDTH_A{1'b0}};
                            end
                            else begin
                                addr_a_p2_r <= addr_a_i;
                                addr_a_p_r <= addr_a_p2_r;
                            end
                        end
                    end
                    else begin
                        always @ (posedge clk_a_i, posedge rst_a_i) begin
                            if(rst_a_i) begin
                                addr_a_p2_r <= {ADDR_WIDTH_A{1'b0}};
                                addr_a_p_r <= {ADDR_WIDTH_A{1'b0}};
                            end
                            else begin
                                addr_a_p2_r <= addr_a_i;
                                addr_a_p_r <= addr_a_p2_r;
                            end
                        end
                    end
                end
            
                // ------ PORT B output assignment
                reg [DATA_WIDTH_B-1:0] b_out_buff_r;
                reg [ADDR_WIDTH_B-1:0] addr_b_p_r;
                assign rd_data_b_o = b_out_buff_r;

                // synthesis translate_off
                initial begin
                    b_out_buff_r = {DATA_WIDTH_B{1'b0}};
                    addr_b_p_r   = {ADDR_WIDTH_B{1'b0}};
                end
                // synthesis translate_on
            
                always @ (*) begin
                    b_out_buff_r = rd_data_raw_b_w[addr_b_p_r[ADDR_WIDTH_B-1:OPT_ADDR_WIDTH]];
                end
                
                if(REGMODE_B == "noreg") begin
                    if(RESETMODE_B == "sync") begin
                        always @ (posedge clk_b_i) begin
                            if(rst_b_i) begin
                                addr_b_p_r <= {ADDR_WIDTH_B{1'b0}};
                            end
                            else begin
                                addr_b_p_r <= addr_b_i;
                            end
                        end
                    end
                    else begin
                        always @ (posedge clk_b_i, posedge rst_b_i) begin
                            if(rst_b_i) begin
                                addr_b_p_r <= {ADDR_WIDTH_B{1'b0}};
                            end
                            else begin
                                addr_b_p_r <= addr_b_i;
                            end
                        end
                    end
                end
                else begin
                    reg [ADDR_WIDTH_B-1:0] addr_b_p2_r;
                    // synthesis translate_off
                    initial begin
                        addr_b_p2_r  = {ADDR_WIDTH_B{1'b0}};
                    end
                    // synthesis translate_on
                    if(RESETMODE_B == "sync") begin
                        always @ (posedge clk_b_i) begin
                            if(rst_b_i) begin
                                addr_b_p2_r <= {ADDR_WIDTH_B{1'b0}};
                                addr_b_p_r <= {ADDR_WIDTH_B{1'b0}};
                            end
                            else begin
                                addr_b_p2_r <= addr_b_i;
                                addr_b_p_r <= addr_b_p2_r;
                            end
                        end
                    end
                    else begin
                        always @ (posedge clk_b_i, posedge rst_b_i) begin
                            if(rst_b_i) begin
                                addr_b_p2_r <= {ADDR_WIDTH_B{1'b0}};
                                addr_b_p_r <= {ADDR_WIDTH_B{1'b0}};
                            end
                            else begin
                                addr_b_p2_r <= addr_b_i;
                                addr_b_p_r <= addr_b_p2_r;
                            end
                        end
                    end
                end
            end
        end
        // ---------------------------------------------------------
        // ------ Mixed WIDTH Implementation (no Byte-Enable) ------
        // ---------------------------------------------------------
        else if(BYTE_ENABLE_A == 0 && BYTE_ENABLE_B == 0) begin : MIX_N_BEN
            // ---------------------------------------------------
            // ------ Local Parameters for EBR Optimization ------
            // ---------------------------------------------------
            localparam Q_FACTOR = (DATA_WIDTH_A > DATA_WIDTH_B) ? (DATA_WIDTH_A/DATA_WIDTH_B) : (DATA_WIDTH_B/DATA_WIDTH_A);
            localparam MAX_DATA = (DATA_WIDTH_A > DATA_WIDTH_B) ? DATA_WIDTH_A : DATA_WIDTH_B;
            localparam MAX_PORT = (DATA_WIDTH_A > DATA_WIDTH_B) ? "A" : "B";
            localparam MIN_DEPTH = (MAX_PORT == "A") ? ADDR_DEPTH_A : ADDR_DEPTH_B;
            localparam PROC_MAX_DATA = procData(MAX_DATA, FAMILY_CODE);
            localparam PROC_MIN_DEPTH = (2 ** clog2(MIN_DEPTH));
            localparam PROC_MIN_DATA = PROC_MAX_DATA / Q_FACTOR;
            localparam PROC_MAX_DEPTH = PROC_MIN_DEPTH * Q_FACTOR;

            localparam PORT_A_DATA_USE = (MAX_PORT == "A") ? PROC_MAX_DATA : PROC_MIN_DATA;
            localparam PORT_A_DEPTH_USE = (MAX_PORT == "A") ? PROC_MIN_DEPTH : PROC_MAX_DEPTH;
            localparam PORT_A_DEPTH_WIDTH = clog2(PORT_A_DEPTH_USE);

            localparam PORT_B_DATA_USE = (MAX_PORT == "B") ? PROC_MAX_DATA : PROC_MIN_DATA;
            localparam PORT_B_DEPTH_USE = (MAX_PORT == "B") ? PROC_MIN_DEPTH : PROC_MAX_DEPTH;
            localparam PORT_B_DEPTH_WIDTH = clog2(PORT_B_DEPTH_USE);
 
            localparam A_DWID_IMPL = getCASE1DataImpl(PORT_A_DEPTH_USE, PORT_A_DATA_USE, PORT_B_DEPTH_USE, PORT_B_DATA_USE, 1'b1, 0, FAMILY_CODE);
            localparam A_DEPTH_IMPL = data_to_addr(A_DWID_IMPL, FAMILY_CODE);
            localparam A_AWID_IMPL = clog2(A_DEPTH_IMPL);

            localparam B_DWID_IMPL = getCASE1DataImpl(PORT_A_DEPTH_USE, PORT_A_DATA_USE, PORT_B_DEPTH_USE, PORT_B_DATA_USE, 1'b0, 0, FAMILY_CODE);
            localparam B_DEPTH_IMPL = data_to_addr(B_DWID_IMPL, FAMILY_CODE);
            localparam B_AWID_IMPL = clog2(B_DEPTH_IMPL);

            localparam EBR_ADDR = roundUP(PORT_A_DEPTH_USE, A_DEPTH_IMPL);
            localparam EBR_DATA = roundUP(PORT_A_DATA_USE, A_DWID_IMPL);

            // ------ Port A address truncation ------
            wire [A_AWID_IMPL-1:0] addr_a_w;
            if(A_AWID_IMPL > ADDR_WIDTH_A) begin
                assign addr_a_w[A_AWID_IMPL-1:ADDR_WIDTH_A] = {(A_AWID_IMPL-ADDR_WIDTH_A){1'b0}};
                assign addr_a_w[ADDR_WIDTH_A-1:0] = addr_a_i;
            end
            else begin
                assign addr_a_w[A_AWID_IMPL-1:0] = addr_a_i[A_AWID_IMPL-1:0];
            end

            // ------ Port B address truncation ------
            wire [B_AWID_IMPL-1:0] addr_b_w;
            if(B_AWID_IMPL > ADDR_WIDTH_B) begin
                assign addr_b_w[B_AWID_IMPL-1:ADDR_WIDTH_B] = {(B_AWID_IMPL-ADDR_WIDTH_B){1'b0}};
                assign addr_b_w[ADDR_WIDTH_B-1:0] = addr_b_i;
            end
            else begin
                assign addr_b_w[B_AWID_IMPL-1:0] = addr_b_i[B_AWID_IMPL-1:0];
            end

            // ------ TOP level wiring ports ------
            wire [PORT_A_DATA_USE-1:0] in_a_top_w;
            wire [PORT_B_DATA_USE-1:0] in_b_top_w;

            wire [PORT_A_DATA_USE-1:0] out_a_top_w;
            wire [PORT_B_DATA_USE-1:0] out_b_top_w;

            // ------ EBR level wiring ports ------
            wire [PORT_A_DATA_USE-1:0] in_a_ebr_w;
            wire [PORT_B_DATA_USE-1:0] in_b_ebr_w;

            wire [PORT_A_DATA_USE-1:0] out_a_ebr_w;
            wire [PORT_B_DATA_USE-1:0] out_b_ebr_w;

            // ------ Output Port MUX ------
            wire [PORT_A_DATA_USE-1:0] out_a_ebr_raw_w [EBR_ADDR-1:0];
            wire [PORT_B_DATA_USE-1:0] out_b_ebr_raw_w [EBR_ADDR-1:0];

            // ------------------------------------------------
            // ------ WIRING translation from TOP to EBR ------
            // ------------------------------------------------
            if(PORT_A_DATA_USE > PORT_B_DATA_USE) begin : A_OVR_B
                // ------ PORT B (TOP wrapper to TOP level split) Wiring : (DATA_WIDTH_A > DATA_WIDTH_B) ------
                if(PORT_B_DATA_USE > DATA_WIDTH_B) begin
                    assign in_b_top_w[PORT_B_DATA_USE-1:DATA_WIDTH_B] = {(PORT_B_DATA_USE-DATA_WIDTH_B){1'b0}};
                end
                assign in_b_top_w[DATA_WIDTH_B-1:0] = wr_data_b_i;
                assign rd_data_b_o = out_b_top_w[DATA_WIDTH_B-1:0];

                // ------ PORT A (TOP wrapper to TOP level split) Wiring : (DATA_WIDTH_A > DATA_WIDTH_B) ------
                wire [PORT_B_DATA_USE-1:0] inp_a_buff_seg_w [PORT_A_DATA_USE/PORT_B_DATA_USE-1:0];
                wire [PORT_B_DATA_USE-1:0] out_a_buff_seg_w [PORT_A_DATA_USE/PORT_B_DATA_USE-1:0];

                for(i_0 = 0; i_0 < PORT_A_DATA_USE/PORT_B_DATA_USE; i_0 = i_0 + 1) begin
                    assign inp_a_buff_seg_w[i_0] = wr_data_a_i[DATA_WIDTH_B*(i_0+1)-1:DATA_WIDTH_B*i_0];
                    assign rd_data_a_o[DATA_WIDTH_B*(i_0+1)-1:DATA_WIDTH_B*i_0] = out_a_buff_seg_w[i_0];
                end

                for(i_0 = 0; i_0 < PORT_A_DATA_USE/PORT_B_DATA_USE; i_0 = i_0 + 1) begin
                    assign in_a_top_w[i_0*PORT_B_DATA_USE+PORT_B_DATA_USE-1:i_0*PORT_B_DATA_USE] = inp_a_buff_seg_w[i_0];
                    assign out_a_buff_seg_w[i_0] = out_a_top_w[i_0*PORT_B_DATA_USE+PORT_B_DATA_USE-1:i_0*PORT_B_DATA_USE];
                end

                // ------ PORT B (TOP level to EBR level splt) Wiring : (DATA_WIDTH_A > DATA_WIDTH_B) ------
                assign in_b_ebr_w = in_b_top_w;
                assign out_b_top_w = out_b_ebr_w;

                // ------ PORT A (TOP level to EBR level splt) Wiring : (DATA_WIDTH_A > DATA_WIDTH_B) ------
                wire [B_DWID_IMPL-1:0] in_a_ebr_seg_w [PORT_A_DATA_USE/B_DWID_IMPL-1:0];
                wire [B_DWID_IMPL-1:0] out_a_ebr_seg_w [PORT_A_DATA_USE/B_DWID_IMPL-1:0];

                for(i_0 = 0; i_0 < EBR_DATA; i_0 = i_0 + 1) begin
                    for(i_1 = 0; i_1 < (PORT_A_DATA_USE/(B_DWID_IMPL*EBR_DATA)); i_1 = i_1 + 1) begin
                        assign in_a_ebr_seg_w[(PORT_A_DATA_USE/(B_DWID_IMPL*EBR_DATA))*i_0+i_1] = in_a_top_w[i_0*B_DWID_IMPL+i_1*EBR_DATA*B_DWID_IMPL+B_DWID_IMPL-1:i_0*B_DWID_IMPL+i_1*EBR_DATA*B_DWID_IMPL];
                    end
                end
                for(i_0 = 0; i_0 < PORT_A_DATA_USE/B_DWID_IMPL; i_0 = i_0+1) begin
                    assign in_a_ebr_w[i_0*B_DWID_IMPL+B_DWID_IMPL-1:i_0*B_DWID_IMPL] = in_a_ebr_seg_w[i_0];
                end
                for(i_0 = 0; i_0 < PORT_A_DATA_USE/PORT_B_DATA_USE; i_0 = i_0 + 1) begin
                    for(i_1 = 0; i_1 < EBR_DATA; i_1 = i_1 + 1) begin
                        assign out_a_ebr_seg_w[i_0*EBR_DATA+i_1] = out_a_ebr_w[i_1*A_DWID_IMPL+i_0*B_DWID_IMPL+B_DWID_IMPL-1:i_1*A_DWID_IMPL+i_0*B_DWID_IMPL];
                    end
                end
                for(i_0 = 0; i_0 < PORT_A_DATA_USE/B_DWID_IMPL; i_0 = i_0 + 1) begin
                    assign out_a_top_w[i_0*B_DWID_IMPL+B_DWID_IMPL-1:i_0*B_DWID_IMPL] = out_a_ebr_seg_w[i_0];
                end
            end
            else begin : B_OVR_A
                // ------ PORT A (TOP wrapper to TOP level split) Wiring : (DATA_WIDTH_B > DATA_WIDTH_A) ------
                if(PORT_A_DATA_USE > DATA_WIDTH_A) begin
                    assign in_a_top_w[PORT_A_DATA_USE-1:DATA_WIDTH_A] = {(PORT_A_DATA_USE-DATA_WIDTH_A){1'b0}};
                end
                assign in_a_top_w[DATA_WIDTH_A-1:0] = wr_data_a_i;
                assign rd_data_a_o = out_a_top_w;

               // ------ PORT B (TOP wrapper to TOP level split) Wiring : (DATA_WIDTH_B > DATA_WIDTH_A) ------
                wire [PORT_A_DATA_USE-1:0] inp_b_buff_seg_w [PORT_B_DATA_USE/PORT_A_DATA_USE-1:0];
                wire [PORT_A_DATA_USE-1:0] out_b_buff_seg_w [PORT_B_DATA_USE/PORT_A_DATA_USE-1:0];

                for(i_0 = 0; i_0 < PORT_B_DATA_USE/PORT_A_DATA_USE; i_0 = i_0 + 1) begin
                    assign inp_b_buff_seg_w[i_0] = wr_data_b_i[DATA_WIDTH_A*(i_0+1)-1: DATA_WIDTH_A*i_0];
                    assign rd_data_b_o[DATA_WIDTH_A*(i_0+1)-1:DATA_WIDTH_A*i_0] = out_b_buff_seg_w[i_0];
                end

                for(i_0 = 0; i_0 < PORT_B_DATA_USE/PORT_A_DATA_USE; i_0 = i_0 + 1) begin
                    assign in_b_top_w[i_0*PORT_A_DATA_USE+PORT_A_DATA_USE-1:i_0*PORT_A_DATA_USE] = inp_b_buff_seg_w[i_0];
                    assign out_b_buff_seg_w[i_0] = out_b_top_w[i_0*PORT_A_DATA_USE+PORT_A_DATA_USE-1:i_0*PORT_A_DATA_USE];
                end

                // ------ PORT A (TOP level to EBR level splt) Wiring : (DATA_WIDTH_B > DATA_WIDTH_A) ------
                assign in_a_ebr_w = in_a_top_w;
                assign out_a_top_w = out_a_ebr_w;

                // ------ PORT B (TOP level to EBR level splt) Wiring : (DATA_WIDTH_B > DATA_WIDTH_A) ------
                wire [A_DWID_IMPL-1:0] in_b_ebr_seg_w [PORT_B_DATA_USE/A_DWID_IMPL-1:0];
                wire [A_DWID_IMPL-1:0] out_b_ebr_seg_w [PORT_B_DATA_USE/A_DWID_IMPL-1:0];

                for(i_0 = 0; i_0 < EBR_DATA; i_0 = i_0 + 1) begin
                    for(i_1 = 0; i_1 < (PORT_B_DATA_USE/(A_DWID_IMPL*EBR_DATA)); i_1 = i_1 + 1) begin
                        assign in_b_ebr_seg_w[(PORT_B_DATA_USE/(A_DWID_IMPL*EBR_DATA))*i_0+i_1] = in_b_top_w[i_0*A_DWID_IMPL+i_1*EBR_DATA*A_DWID_IMPL+A_DWID_IMPL-1:i_0*A_DWID_IMPL+i_1*EBR_DATA*A_DWID_IMPL];
                    end
                end

                for(i_0 = 0; i_0 < (PORT_B_DATA_USE/A_DWID_IMPL); i_0 = i_0 + 1) begin
                    assign in_b_ebr_w[i_0*A_DWID_IMPL+A_DWID_IMPL-1:i_0*A_DWID_IMPL] = in_b_ebr_seg_w[i_0];
                end

                for(i_0 = 0; i_0 < (PORT_B_DATA_USE/PORT_A_DATA_USE); i_0 = i_0 + 1) begin
                    for(i_1 = 0; i_1 < EBR_DATA; i_1 = i_1 + 1) begin
                        assign out_b_ebr_seg_w[i_0*EBR_DATA+i_1] = out_b_ebr_w[i_1*B_DWID_IMPL+i_0*A_DWID_IMPL+A_DWID_IMPL-1:i_1*B_DWID_IMPL+i_0*A_DWID_IMPL];
                    end
                end
                for(i_0 = 0; i_0 < (PORT_B_DATA_USE/A_DWID_IMPL); i_0 = i_0 + 1) begin
                    assign out_b_top_w[i_0*A_DWID_IMPL+A_DWID_IMPL-1:i_0*A_DWID_IMPL] = out_b_ebr_seg_w[i_0];
                end
            end

            // ------ Address Loop (Mixed Width no Byte-Enable) ------
            for(i0 = 0; i0 < EBR_ADDR; i0 = i0 + 1) begin : xADDR
                // ------ PORT A output ports ------
                wire [PORT_A_DATA_USE-1:0] raw_out_a_w;
                assign out_a_ebr_raw_w[i0] = raw_out_a_w;

                // ------ PORT A Address Control Signal ------
                wire chk_addr_a_w;
                if(EBR_ADDR > 1) begin
                    assign chk_addr_a_w = (addr_a_i[ADDR_WIDTH_A-1:A_AWID_IMPL] == i0) ? 1'b1 : 1'b0;
                end
                else begin
                    assign chk_addr_a_w = 1'b1;
                end

                // ------ PORT B output ports ------
                wire [PORT_B_DATA_USE-1:0] raw_out_b_w;
                assign out_b_ebr_raw_w[i0] = raw_out_b_w;

                // ------ PORT B Address Control Signal ------
                wire chk_addr_b_w;
                if(EBR_ADDR > 1) begin
                    assign chk_addr_b_w = (addr_b_i[ADDR_WIDTH_B-1:B_AWID_IMPL] == i0) ? 1'b1 : 1'b0;
                end
                else begin
                    assign chk_addr_b_w = 1'b1;
                end

                // ------ Data Loop (Mixed Width no Byte-Enable) ------                
                for(i1 = 0; i1 < EBR_DATA; i1 = i1 + 1) begin : xDATA

                    localparam ECO_POSX = i1 * A_DWID_IMPL;
                    localparam ECO_POSY = i0 * A_DEPTH_IMPL;

                    // ------ PORT A Data Wiring ------
                    wire [A_DWID_IMPL-1:0] in_a_w;
                    wire [A_DWID_IMPL-1:0] out_a_w;

                    if(PORT_A_DATA_USE > A_DWID_IMPL*(i1+1)) begin
                        assign in_a_w = in_a_ebr_w[(A_DWID_IMPL*(i1+1))-1:A_DWID_IMPL*i1];
                        assign raw_out_a_w[(A_DWID_IMPL*(i1+1))-1:A_DWID_IMPL*i1] = out_a_w;
                    end
                    else begin
                        assign in_a_w[PORT_A_DATA_USE-(1+A_DWID_IMPL*i1):0] = in_a_ebr_w[PORT_A_DATA_USE-1:A_DWID_IMPL*i1];
                        if(A_DWID_IMPL > (PORT_A_DATA_USE-(A_DWID_IMPL*i1))) begin
                            assign in_a_w[A_DWID_IMPL-1:(PORT_A_DATA_USE-(A_DWID_IMPL*i1))] = {(A_DWID_IMPL-(PORT_A_DATA_USE-(A_DWID_IMPL*i1))){1'b0}};
                        end
                        assign raw_out_a_w[PORT_A_DATA_USE-1:A_DWID_IMPL*i1] = out_a_w[PORT_A_DATA_USE-(1+A_DWID_IMPL*i1):0];
                    end

                    // ------ PORT B Data Wiring ------
                    wire [B_DWID_IMPL-1:0] in_b_w;
                    wire [B_DWID_IMPL-1:0] out_b_w;

                    if(PORT_B_DATA_USE > B_DWID_IMPL*(i1+1))  begin
                        assign in_b_w = in_b_ebr_w[(B_DWID_IMPL*(i1+1))-1:B_DWID_IMPL*i1];
                        assign raw_out_b_w[(B_DWID_IMPL*(i1+1))-1:B_DWID_IMPL*i1] = out_b_w;
                    end
                    else begin
                        assign in_b_w[PORT_B_DATA_USE-(1+B_DWID_IMPL*i1):0] = in_b_ebr_w[PORT_B_DATA_USE-1:B_DWID_IMPL*i1];
                        if(B_DWID_IMPL > (PORT_B_DATA_USE-(B_DWID_IMPL*i1))) begin
                            assign in_b_w[B_DWID_IMPL-1:(PORT_B_DATA_USE-(B_DWID_IMPL*i1))] = {(B_DWID_IMPL-(PORT_B_DATA_USE-(B_DWID_IMPL*i1))){1'b0}};
                        end
                        assign raw_out_b_w[PORT_B_DATA_USE-1:B_DWID_IMPL*i1] = out_b_w[PORT_B_DATA_USE-(1+B_DWID_IMPL*i1):0];
                    end

                    // ------------------------------------
                    // ------ SINGLE MEMORY INSTANCE ------
                    // ------------------------------------
                    if(INIT_MODE == "mem_file") begin : mem_file 
                        lscc_ram_dp_true_core # (
                            // ------ COMMON PARAMETERS ------
                            .FAMILY          (FAMILY),
                            .INIT_MODE       (INIT_MODE),
                            .MEM_SIZE        (MEM_SIZE),
                            .MEM_ID          (MEM_ID),
                            .POSx            (ECO_POSX),
                            .POSy            (ECO_POSY),
                        
                            // ------ PORT A PARAMETERS ------
                            .DATA_WIDTH_A    (A_DWID_IMPL),
                            .REGMODE_A       (REGMODE_A),
                            .RESETMODE_A     (RESETMODE_A),
                            .RESET_RELEASE_A (RESET_RELEASE_A),
                            .BYTE_ENABLE_A   (0),
                        
                            // ------ PORT B PARAMETERS ------                        
                            .DATA_WIDTH_B    (B_DWID_IMPL),
                            .REGMODE_B       (REGMODE_B),
                            .RESETMODE_B     (RESETMODE_B),
                            .RESET_RELEASE_B (RESET_RELEASE_B),
                            .BYTE_ENABLE_B   (0),

                            // ------ INIT PARAMETERS ------
                            .INITVAL_00(INIT_VALUE_00[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8]),
                            .INITVAL_01(INIT_VALUE_01[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8]),
                            .INITVAL_02(INIT_VALUE_02[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8]),
                            .INITVAL_03(INIT_VALUE_03[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8]),
                            .INITVAL_04(INIT_VALUE_04[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8]),
                            .INITVAL_05(INIT_VALUE_05[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8]),
                            .INITVAL_06(INIT_VALUE_06[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8]),
                            .INITVAL_07(INIT_VALUE_07[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8]),
                            .INITVAL_08(INIT_VALUE_08[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8]),
                            .INITVAL_09(INIT_VALUE_09[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8]),
                            .INITVAL_0A(INIT_VALUE_0A[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8]),
                            .INITVAL_0B(INIT_VALUE_0B[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8]),
                            .INITVAL_0C(INIT_VALUE_0C[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8]),
                            .INITVAL_0D(INIT_VALUE_0D[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8]),
                            .INITVAL_0E(INIT_VALUE_0E[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8]),
                            .INITVAL_0F(INIT_VALUE_0F[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8]),
                            .INITVAL_10(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_10[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_11(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_11[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_12(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_12[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_13(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_13[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_14(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_14[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_15(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_15[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_16(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_16[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_17(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_17[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_18(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_18[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_19(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_19[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_1A(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_1A[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_1B(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_1B[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_1C(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_1C[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_1D(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_1D[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_1E(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_1E[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_1F(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_1F[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_20(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_20[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_21(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_21[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_22(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_22[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_23(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_23[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_24(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_24[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_25(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_25[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_26(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_26[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_27(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_27[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_28(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_28[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_29(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_29[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_2A(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_2A[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_2B(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_2B[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_2C(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_2C[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_2D(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_2D[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_2E(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_2E[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_2F(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_2F[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_30(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_30[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_31(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_31[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_32(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_32[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_33(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_33[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_34(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_34[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_35(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_35[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_36(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_36[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_37(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_37[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_38(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_38[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_39(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_39[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_3A(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_3A[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_3B(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_3B[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_3C(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_3C[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_3D(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_3D[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_3E(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_3E[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_3F(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_3F[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00")
                        ) u_dp16k (
                            // ------ PORT A signals ------
                            .clk_a_i     (clk_a_i),
                            .clk_en_a_i  (clk_en_a_i),
                            .rst_a_i     (rst_a_i),
                            .wr_en_a_i   (wr_en_a_i & chk_addr_a_w),
                            .ben_a_i     (1'b1),
                            .addr_a_i    (addr_a_w),
                            .wr_data_a_i (in_a_w),
                        
                            .rd_data_a_o (out_a_w),
                        
                            // ------ PORT B signals ------
                            .clk_b_i     (clk_b_i),
                            .clk_en_b_i  (clk_en_b_i),
                            .rst_b_i     (rst_b_i),
                            .wr_en_b_i   (wr_en_b_i & chk_addr_b_w),
                            .ben_b_i     (1'b1),
                            .addr_b_i    (addr_b_w),
                            .wr_data_b_i (in_b_w),
                        
                            .rd_data_b_o (out_b_w)
                        );
                    end
                    else begin : no_mem_file
                        lscc_ram_dp_true_core # (
                            // ------ COMMON PARAMETERS ------
                            .FAMILY          (FAMILY),
                            .INIT_MODE       (INIT_MODE),
                            .MEM_SIZE        (MEM_SIZE),
                            .MEM_ID          (MEM_ID),
                            .POSx            (ECO_POSX),
                            .POSy            (ECO_POSY),
                        
                            // ------ PORT A PARAMETERS ------
                            .DATA_WIDTH_A    (A_DWID_IMPL),
                            .REGMODE_A       (REGMODE_A),
                            .RESETMODE_A     (RESETMODE_A),
                            .RESET_RELEASE_A (RESET_RELEASE_A),
                            .BYTE_ENABLE_A   (0),
                        
                            // ------ PORT B PARAMETERS ------                        
                            .DATA_WIDTH_B    (B_DWID_IMPL),
                            .REGMODE_B       (REGMODE_B),
                            .RESETMODE_B     (RESETMODE_B),
                            .RESET_RELEASE_B (RESET_RELEASE_B),
                            .BYTE_ENABLE_B   (0)
                        ) u_dp16k (
                            // ------ PORT A signals ------
                            .clk_a_i     (clk_a_i),
                            .clk_en_a_i  (clk_en_a_i),
                            .rst_a_i     (rst_a_i),
                            .wr_en_a_i   (wr_en_a_i & chk_addr_a_w),
                            .ben_a_i     (1'b1),
                            .addr_a_i    (addr_a_w),
                            .wr_data_a_i (in_a_w),
                        
                            .rd_data_a_o (out_a_w),
                        
                            // ------ PORT B signals ------
                            .clk_b_i     (clk_b_i),
                            .clk_en_b_i  (clk_en_b_i),
                            .rst_b_i     (rst_b_i),
                            .wr_en_b_i   (wr_en_b_i & chk_addr_b_w),
                            .ben_b_i     (1'b1),
                            .addr_b_i    (addr_b_w),
                            .wr_data_b_i (in_b_w),
                        
                            .rd_data_b_o (out_b_w)
                        );
                    end
                end
            end
            if(EBR_ADDR == 1) begin
                assign out_a_ebr_w = out_a_ebr_raw_w[0];
                assign out_b_ebr_w = out_b_ebr_raw_w[0];
            end
            else begin
                // ------ PORT A output assignment ------
                reg [PORT_A_DATA_USE-1:0] a_out_buff_r;
                reg [ADDR_WIDTH_A-1:0] addr_a_p_r;
                assign out_a_ebr_w = a_out_buff_r;

                // synthesis translate_off
                initial begin
                    a_out_buff_r = {PORT_A_DATA_USE{1'b0}};
                    addr_a_p_r   = {ADDR_WIDTH_A{1'b0}};
                end
                // synthesis translate_on
            
                always @ (*) begin
                    a_out_buff_r = out_a_ebr_raw_w[addr_a_p_r[ADDR_WIDTH_A-1:A_AWID_IMPL]];
                end
                
                if(REGMODE_A == "noreg") begin
                    if(RESETMODE_A == "sync") begin
                        always @ (posedge clk_a_i) begin
                            if(rst_a_i) begin
                                addr_a_p_r <= {ADDR_WIDTH_A{1'b0}};
                            end
                            else begin
                                addr_a_p_r <= addr_a_i;
                            end
                        end
                    end
                    else begin
                        always @ (posedge clk_a_i, posedge rst_a_i) begin
                            if(rst_a_i) begin
                                addr_a_p_r <= {ADDR_WIDTH_A{1'b0}};
                            end
                            else begin
                                addr_a_p_r <= addr_a_i;
                            end
                        end
                    end
                end
                else begin
                    reg [ADDR_WIDTH_A-1:0] addr_a_p2_r;

                    // synthesis translate_off
                    initial begin
                        addr_a_p2_r   = {ADDR_WIDTH_A{1'b0}};
                    end
                    // synthesis translate_on

                    if(RESETMODE_A == "sync") begin
                        always @ (posedge clk_a_i) begin
                            if(rst_a_i) begin
                                addr_a_p2_r <= {ADDR_WIDTH_A{1'b0}};
                                addr_a_p_r <= {ADDR_WIDTH_A{1'b0}};
                            end
                            else begin
                                addr_a_p2_r <= addr_a_i;
                                addr_a_p_r <= addr_a_p2_r;
                            end
                        end
                    end
                    else begin
                        always @ (posedge clk_a_i, posedge rst_a_i) begin
                            if(rst_a_i) begin
                                addr_a_p2_r <= {ADDR_WIDTH_A{1'b0}};
                                addr_a_p_r <= {ADDR_WIDTH_A{1'b0}};
                            end
                            else begin
                                addr_a_p2_r <= addr_a_i;
                                addr_a_p_r <= addr_a_p2_r;
                            end
                        end
                    end
                end

                // ------ PORT B output assignment ------
                reg [PORT_B_DATA_USE-1:0] b_out_buff_r;
                reg [ADDR_WIDTH_B-1:0] addr_b_p_r;
                assign out_b_ebr_w = b_out_buff_r;

                // synthesis translate_off
                initial begin
                    b_out_buff_r = {PORT_B_DATA_USE{1'b0}};
                    addr_b_p_r   = {ADDR_WIDTH_B{1'b0}};
                end
                // synthesis translate_on

                always @ (*) begin
                    b_out_buff_r = out_b_ebr_raw_w[addr_b_p_r[ADDR_WIDTH_B-1:B_AWID_IMPL]];
                end

                if(REGMODE_B == "noreg") begin
                    if(RESETMODE_B == "sync") begin
                        always @ (posedge clk_b_i) begin
                            if(rst_b_i) begin
                                addr_b_p_r <= {ADDR_WIDTH_B{1'b0}};
                            end
                            else begin
                                addr_b_p_r <= addr_b_i;
                            end
                        end
                    end
                    else begin
                        always @ (posedge clk_b_i, posedge rst_b_i) begin
                            if(rst_b_i) begin
                                addr_b_p_r <= {ADDR_WIDTH_B{1'b0}};
                            end
                            else begin
                                addr_b_p_r <= addr_b_i;
                            end
                        end
                    end
                end
                else begin
                    reg [ADDR_WIDTH_B-1:0] addr_b_p2_r;

                    // synthesis translate_off
                    initial begin
                        addr_b_p2_r   = {ADDR_WIDTH_B{1'b0}};
                    end
                    // synthesis translate_on

                    if(RESETMODE_B == "sync") begin
                        always @ (posedge clk_b_i) begin
                            if(rst_b_i) begin
                                addr_b_p2_r <= {ADDR_WIDTH_B{1'b0}};
                                addr_b_p_r <= {ADDR_WIDTH_B{1'b0}};
                            end
                            else begin
                                addr_b_p2_r <= addr_b_i;
                                addr_b_p_r <= addr_b_p2_r;
                            end
                        end
                    end
                    else begin
                        always @ (posedge clk_b_i, posedge rst_b_i) begin
                            if(rst_b_i) begin
                                addr_b_p2_r <= {ADDR_WIDTH_B{1'b0}};
                                addr_b_p_r <= {ADDR_WIDTH_B{1'b0}};
                            end
                            else begin
                                addr_b_p2_r <= addr_b_i;
                                addr_b_p_r <= addr_b_p2_r;
                            end
                        end
                    end
                end
            end
        end
        // --------------------------------------------------------
        // ------ Mixed WIDTH Implementation (w/Byte-Enable) ------
        // --------------------------------------------------------
        else begin : MIX_Y_BEN
            // ---------------------------------------------------
            // ------ Local Parameters for EBR Optimization ------
            // ---------------------------------------------------
            localparam A_DWID_IMPL  = getCASE1DataImpl_wBEN(ADDR_DEPTH_A, DATA_WIDTH_A, ADDR_DEPTH_B, DATA_WIDTH_B, 1'b1, 0, FAMILY_CODE);
            localparam A_DEPTH_IMPL = data_to_addr(A_DWID_IMPL, FAMILY_CODE);
            localparam A_AWID_IMPL  = clog2(A_DEPTH_IMPL);
            localparam A_BWID_IMPL  = BYTE_ENABLE_A == 1 ? getImplByteWidth(A_DWID_IMPL, FAMILY_CODE) : 1;

            localparam B_DWID_IMPL  = getCASE1DataImpl_wBEN(ADDR_DEPTH_A, DATA_WIDTH_A, ADDR_DEPTH_B, DATA_WIDTH_B, 1'b0, 0, FAMILY_CODE);
            localparam B_DEPTH_IMPL = data_to_addr(B_DWID_IMPL, FAMILY_CODE);
            localparam B_AWID_IMPL  = clog2(B_DEPTH_IMPL);
            localparam B_BWID_IMPL  = BYTE_ENABLE_B == 1 ? getImplByteWidth(B_DWID_IMPL, FAMILY_CODE) : 1;

            localparam EBR_ADDR     = roundUP(ADDR_DEPTH_A, A_DEPTH_IMPL);
            localparam EBR_DATA     = roundUP(DATA_WIDTH_A, A_DWID_IMPL);

            // ------ Port A address truncation ------
            wire [A_AWID_IMPL-1:0] addr_a_w;
            if(A_AWID_IMPL > ADDR_WIDTH_A) begin
                assign addr_a_w[A_AWID_IMPL-1:ADDR_WIDTH_A] = {(A_AWID_IMPL-ADDR_WIDTH_A){1'b0}};
                assign addr_a_w[ADDR_WIDTH_A-1:0] = addr_a_i;
            end
            else begin
                assign addr_a_w[A_AWID_IMPL-1:0] = addr_a_i[A_AWID_IMPL-1:0];
            end

            // ------ Port B address truncation ------
            wire [B_AWID_IMPL-1:0] addr_b_w;
            if(B_AWID_IMPL > ADDR_WIDTH_B) begin
                assign addr_b_w[B_AWID_IMPL-1:ADDR_WIDTH_B] = {(B_AWID_IMPL-ADDR_WIDTH_B){1'b0}};
                assign addr_b_w[ADDR_WIDTH_B-1:0] = addr_b_i;
            end
            else begin
                assign addr_b_w[B_AWID_IMPL-1:0] = addr_b_i[B_AWID_IMPL-1:0];
            end
            
            // ------ EBR level wiring ports ------
            wire [DATA_WIDTH_A-1:0] in_a_ebr_w;
            wire [DATA_WIDTH_B-1:0] in_b_ebr_w;

            wire [DATA_WIDTH_A-1:0] out_a_ebr_w;
            wire [DATA_WIDTH_B-1:0] out_b_ebr_w;

            wire [BYTE_WIDTH_A-1:0] ben_a_ebr_w;
            wire [BYTE_WIDTH_B-1:0] ben_b_ebr_w;

            // ------ Output Port MUX ------
            wire [DATA_WIDTH_A-1:0] out_a_ebr_raw_w [EBR_ADDR-1:0];
            wire [DATA_WIDTH_B-1:0] out_b_ebr_raw_w [EBR_ADDR-1:0];

            if(DATA_WIDTH_A > DATA_WIDTH_B) begin : A_OVR_B
                // ------ PORT B (TOP to EBR level split) Wiring : (DATA_WIDTH_A > DATA_WIDTH_B) ------
                assign in_b_ebr_w = wr_data_b_i;
                assign rd_data_b_o = out_b_ebr_w;
                assign ben_b_ebr_w = ben_b_i;

                // ------ PORT A (TOP to EBR level split) Wiring : (DATA_WIDTH_A > DATA_WIDTH_B) ------
                wire [B_DWID_IMPL-1:0] in_a_ebr_seg_w  [DATA_WIDTH_A/B_DWID_IMPL-1:0];
                wire [B_BWID_IMPL-1:0] ben_a_ebr_seg_w [DATA_WIDTH_A/B_DWID_IMPL-1:0];
                wire [B_DWID_IMPL-1:0] out_a_ebr_seg_w [DATA_WIDTH_A/B_DWID_IMPL-1:0];

                for(i_0 = 0; i_0 < EBR_DATA; i_0 = i_0 + 1) begin
                    for(i_1 = 0; i_1 < (DATA_WIDTH_A/(B_DWID_IMPL*EBR_DATA)); i_1 = i_1 + 1) begin
                        assign in_a_ebr_seg_w[(DATA_WIDTH_A/(B_DWID_IMPL*EBR_DATA))*i_0+i_1]   = wr_data_a_i[i_0*B_DWID_IMPL+i_1*EBR_DATA*B_DWID_IMPL+B_DWID_IMPL-1:i_0*B_DWID_IMPL+i_1*EBR_DATA*B_DWID_IMPL];
                        assign ben_a_ebr_seg_w [(DATA_WIDTH_A/(B_DWID_IMPL*EBR_DATA))*i_0+i_1] = ben_a_i[i_0*B_BWID_IMPL+i_1*EBR_DATA*B_BWID_IMPL+B_BWID_IMPL-1:i_0*B_BWID_IMPL+i_1*EBR_DATA*B_BWID_IMPL];
                    end
                end
                for(i_0 = 0; i_0 < DATA_WIDTH_A/B_DWID_IMPL; i_0 = i_0 + 1) begin
                    assign in_a_ebr_w[i_0*B_DWID_IMPL+B_DWID_IMPL-1:i_0*B_DWID_IMPL] = in_a_ebr_seg_w[i_0];
                    assign ben_a_ebr_w[i_0*B_BWID_IMPL+B_BWID_IMPL-1:i_0*B_BWID_IMPL] = ben_a_ebr_seg_w[i_0];
                end
                for(i_0 = 0; i_0 < DATA_WIDTH_A/DATA_WIDTH_B; i_0 = i_0 + 1) begin
                    for(i_1 = 0; i_1 < EBR_DATA; i_1 = i_1 + 1) begin
                        assign out_a_ebr_seg_w[i_0*EBR_DATA+i_1] = out_a_ebr_w[i_1*A_DWID_IMPL+i_0*B_DWID_IMPL+B_DWID_IMPL-1:i_1*A_DWID_IMPL+i_0*B_DWID_IMPL];
                    end
                end
                for(i_0 = 0; i_0 < DATA_WIDTH_A/B_DWID_IMPL; i_0 = i_0 + 1) begin
                    assign rd_data_a_o[i_0*B_DWID_IMPL+B_DWID_IMPL-1:i_0*B_DWID_IMPL] = out_a_ebr_seg_w[i_0];
                end
            end
            else begin : B_OVR_A
                // ------ PORT A (TOP to EBR level split) Wiring : (DATA_WIDTH_B > DATA_WIDTH_A) ------
                assign in_a_ebr_w  = wr_data_a_i;
                assign rd_data_a_o = out_a_ebr_w;
                assign ben_a_ebr_w = ben_a_i;

                // ------ PORT B (TOP to EBR level split) Wiring : (DATA_WIDTH_B > DATA_WIDTH_A) ------
                wire [A_DWID_IMPL-1:0] in_b_ebr_seg_w  [DATA_WIDTH_B/A_DWID_IMPL-1:0];
                wire [A_BWID_IMPL-1:0] ben_b_ebr_seg_w [DATA_WIDTH_B/A_DWID_IMPL-1:0];
                wire [A_DWID_IMPL-1:0] out_b_ebr_seg_w [DATA_WIDTH_B/A_DWID_IMPL-1:0];

                for(i_0 = 0; i_0 < EBR_DATA; i_0 = i_0 + 1) begin
                    for(i_1 = 0; i_1 < (DATA_WIDTH_B/(A_DWID_IMPL*EBR_DATA)); i_1 = i_1 + 1) begin
                        assign in_b_ebr_seg_w[(DATA_WIDTH_B/(A_DWID_IMPL*EBR_DATA))*i_0+i_1] = wr_data_b_i[i_0*A_DWID_IMPL+i_1*EBR_DATA*A_DWID_IMPL+A_DWID_IMPL-1:i_0*A_DWID_IMPL+i_1*EBR_DATA*A_DWID_IMPL];
                        assign ben_b_ebr_seg_w[(DATA_WIDTH_B/(A_DWID_IMPL*EBR_DATA))*i_0+i_1] = ben_b_i[i_0*A_BWID_IMPL+i_1*EBR_DATA*A_BWID_IMPL+A_BWID_IMPL-1:i_0*A_BWID_IMPL+i_1*EBR_DATA*A_BWID_IMPL];
                    end
                end

                for(i_0 = 0; i_0 < (DATA_WIDTH_B/A_DWID_IMPL); i_0 = i_0 + 1) begin
                    assign in_b_ebr_w[i_0*A_DWID_IMPL+A_DWID_IMPL-1:i_0*A_DWID_IMPL]  = in_b_ebr_seg_w[i_0];
                    assign ben_b_ebr_w[i_0*A_BWID_IMPL+A_BWID_IMPL-1:i_0*A_BWID_IMPL] = ben_b_ebr_seg_w[i_0];
                end

                for(i_0 = 0; i_0 < (DATA_WIDTH_B/DATA_WIDTH_A); i_0 = i_0 + 1) begin
                    for(i_1 = 0; i_1 < EBR_DATA; i_1 = i_1 + 1) begin
                        assign out_b_ebr_seg_w[i_0*EBR_DATA+i_1] = out_b_ebr_w[i_1*B_DWID_IMPL+i_0*A_DWID_IMPL+A_DWID_IMPL-1:i_1*B_DWID_IMPL+i_0*A_DWID_IMPL];
                    end
                end
                for(i_0 = 0; i_0 < (DATA_WIDTH_B/A_DWID_IMPL); i_0 = i_0 + 1) begin
                    assign rd_data_b_o[i_0*A_DWID_IMPL+A_DWID_IMPL-1:i_0*A_DWID_IMPL] = out_b_ebr_seg_w[i_0];
                end
            end

            // ------ Address Loop (Mixed Width w/ Byte-Enable) ------
            for(i0 = 0; i0 < EBR_ADDR; i0 = i0 + 1) begin : xADDR
                // ------ PORT A output ports ------
                wire [DATA_WIDTH_A-1:0] raw_out_a_w;
                assign out_a_ebr_raw_w[i0] = raw_out_a_w;

                // ------ PORT A Address Control Signal ------
                wire chk_addr_a_w;
                if(EBR_ADDR > 1) begin
                    assign chk_addr_a_w = (addr_a_i[ADDR_WIDTH_A-1:A_AWID_IMPL] == i0) ? 1'b1 : 1'b0;
                end
                else begin
                    assign chk_addr_a_w = 1'b1;
                end

                // ------ PORT B output ports ------
                wire [DATA_WIDTH_B-1:0] raw_out_b_w;
                assign out_b_ebr_raw_w[i0] = raw_out_b_w;

                // ------ PORT B Address Control Signal ------
                wire chk_addr_b_w;
                if(EBR_ADDR > 1) begin
                    assign chk_addr_b_w = (addr_b_i[ADDR_WIDTH_B-1:B_AWID_IMPL] == i0) ? 1'b1 : 1'b0;
                end
                else begin
                    assign chk_addr_b_w = 1'b1;
                end

                // ------ Data Loop (Mixed Width w/ Byte-Enable) ------     
                for(i1 = 0; i1 < EBR_DATA; i1 = i1 + 1) begin : xDATA

                    localparam ECO_POSX = i1 * A_DWID_IMPL;
                    localparam ECO_POSY = i0 * A_DEPTH_IMPL;

                    // ------ PORT A Data Wiring ------
                    wire [A_DWID_IMPL-1:0] in_a_w;
                    wire [A_BWID_IMPL-1:0] ben_a_w;
                    wire [A_DWID_IMPL-1:0] out_a_w;

                    if(A_DWID_IMPL*(i1+1) < DATA_WIDTH_A) begin
                        assign in_a_w = in_a_ebr_w[(A_DWID_IMPL*(i1+1))-1:A_DWID_IMPL*i1];
                        assign raw_out_a_w[(A_DWID_IMPL*(i1+1))-1:A_DWID_IMPL*i1] = out_a_w;
                        assign ben_a_w = (BYTE_ENABLE_A == 1) ? ben_a_ebr_w[(A_BWID_IMPL*(i1+1))-1:A_BWID_IMPL*i1] : {A_BWID_IMPL{1'b1}};
                    end
                    else begin
                        assign in_a_w[DATA_WIDTH_A-(1+A_DWID_IMPL*i1):0] = in_a_ebr_w[DATA_WIDTH_A-1:A_DWID_IMPL*i1];
                        if(A_DWID_IMPL > (DATA_WIDTH_A-(A_DWID_IMPL*i1))) begin
                            assign in_a_w[A_DWID_IMPL-1:(DATA_WIDTH_A-(A_DWID_IMPL*i1))] = {(A_DWID_IMPL-(DATA_WIDTH_A-(A_DWID_IMPL*i1))){1'b0}};
                        end
                        if(BYTE_ENABLE_A == 1) begin
                            assign ben_a_w[BYTE_WIDTH_A-(1+A_BWID_IMPL*i1):0] = ben_a_ebr_w[BYTE_WIDTH_A-1:A_BWID_IMPL*i1];
                            if(A_BWID_IMPL > (BYTE_WIDTH_A-(A_BWID_IMPL*i1))) begin
                                assign ben_a_w[A_BWID_IMPL-1:(BYTE_WIDTH_A-(A_BWID_IMPL*i1))] = {(A_BWID_IMPL-(BYTE_WIDTH_A-(A_BWID_IMPL*i1))){1'b1}};
                            end
                        end
                        else begin
                            assign ben_a_w = {A_BWID_IMPL{1'b1}};
                        end
                        assign raw_out_a_w[DATA_WIDTH_A-1:A_DWID_IMPL*i1] = out_a_w[DATA_WIDTH_A-(1+A_DWID_IMPL*i1):0];
                    end

                    // ------ PORT B Data Wiring ------
                    wire [B_DWID_IMPL-1:0] in_b_w;
                    wire [B_BWID_IMPL-1:0] ben_b_w;
                    wire [B_DWID_IMPL-1:0] out_b_w;

                    if(B_DWID_IMPL*(i1+1) < DATA_WIDTH_B) begin
                        assign in_b_w = in_b_ebr_w[(B_DWID_IMPL*(i1+1))-1:B_DWID_IMPL*i1];
                        assign raw_out_b_w[(B_DWID_IMPL*(i1+1))-1:B_DWID_IMPL*i1] = out_b_w;
                        assign ben_b_w = (BYTE_ENABLE_B == 1) ? ben_b_ebr_w[(B_BWID_IMPL*(i1+1))-1:B_BWID_IMPL*i1] : {B_BWID_IMPL{1'b1}};
                    end
                    else begin
                        assign in_b_w[DATA_WIDTH_B-(1+B_DWID_IMPL*i1):0] = in_b_ebr_w[DATA_WIDTH_B-1:B_DWID_IMPL*i1];
                        if(B_DWID_IMPL > (DATA_WIDTH_B-(B_DWID_IMPL*i1))) begin
                            assign in_b_w[B_DWID_IMPL-1:(DATA_WIDTH_B-(B_DWID_IMPL*i1))] = {(B_DWID_IMPL-(DATA_WIDTH_B-(B_DWID_IMPL*i1))){1'b0}};
                        end
                        if(BYTE_ENABLE_B == 1) begin
                            assign ben_b_w[BYTE_WIDTH_B-(1+B_BWID_IMPL*i1):0] = ben_b_ebr_w[BYTE_WIDTH_B-1:B_BWID_IMPL*i1];
                            if(B_BWID_IMPL > (DATA_WIDTH_B-(B_BWID_IMPL*i1))) begin
                                assign ben_b_w[B_BWID_IMPL-1:(BYTE_WIDTH_B-(B_BWID_IMPL*i1))] = {(B_BWID_IMPL-(BYTE_WIDTH_B-(B_BWID_IMPL*i1))){1'b1}};
                            end
                        end
                        else begin
                            assign ben_b_w = {B_BWID_IMPL{1'b1}};
                        end
                        assign raw_out_b_w[DATA_WIDTH_B-1:B_DWID_IMPL*i1] = out_b_w[DATA_WIDTH_B-(1+B_DWID_IMPL*i1):0];
                    end

                    // ------------------------------------
                    // ------ SINGLE MEMORY INSTANCE ------
                    // ------------------------------------
                    if(INIT_MODE == "mem_file") begin : mem_file
                        lscc_ram_dp_true_core # (
                            // ------ COMMON PARAMETERS ------
                            .FAMILY          (FAMILY),
                            .INIT_MODE       (INIT_MODE),
                            .MEM_SIZE        (MEM_SIZE),
                            .MEM_ID          (MEM_ID),
                            .POSx            (ECO_POSX),
                            .POSy            (ECO_POSY),
                        
                            // ------ PORT A PARAMETERS ------
                            .DATA_WIDTH_A    (A_DWID_IMPL),
                            .REGMODE_A       (REGMODE_A),
                            .RESETMODE_A     (RESETMODE_A),
                            .RESET_RELEASE_A (RESET_RELEASE_A),
                            .BYTE_ENABLE_A   (BYTE_ENABLE_A),
                            .BYTE_EN_POL_A   (BYTE_EN_POL_A),
                        
                            // ------ PORT B PARAMETERS ------                        
                            .DATA_WIDTH_B    (B_DWID_IMPL),
                            .REGMODE_B       (REGMODE_B),
                            .RESETMODE_B     (RESETMODE_B),
                            .RESET_RELEASE_B (RESET_RELEASE_B),
                            .BYTE_ENABLE_B   (BYTE_ENABLE_B),
                            .BYTE_EN_POL_B   (BYTE_EN_POL_B),

                            // ------ INIT PARAMETERS ------
                            .INITVAL_00(INIT_VALUE_00[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8]),
                            .INITVAL_01(INIT_VALUE_01[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8]),
                            .INITVAL_02(INIT_VALUE_02[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8]),
                            .INITVAL_03(INIT_VALUE_03[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8]),
                            .INITVAL_04(INIT_VALUE_04[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8]),
                            .INITVAL_05(INIT_VALUE_05[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8]),
                            .INITVAL_06(INIT_VALUE_06[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8]),
                            .INITVAL_07(INIT_VALUE_07[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8]),
                            .INITVAL_08(INIT_VALUE_08[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8]),
                            .INITVAL_09(INIT_VALUE_09[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8]),
                            .INITVAL_0A(INIT_VALUE_0A[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8]),
                            .INITVAL_0B(INIT_VALUE_0B[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8]),
                            .INITVAL_0C(INIT_VALUE_0C[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8]),
                            .INITVAL_0D(INIT_VALUE_0D[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8]),
                            .INITVAL_0E(INIT_VALUE_0E[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8]),
                            .INITVAL_0F(INIT_VALUE_0F[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8]),
                            .INITVAL_10(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_10[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_11(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_11[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_12(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_12[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_13(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_13[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_14(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_14[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_15(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_15[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_16(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_16[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_17(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_17[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_18(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_18[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_19(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_19[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_1A(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_1A[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_1B(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_1B[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_1C(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_1C[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_1D(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_1D[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_1E(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_1E[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_1F(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_1F[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_20(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_20[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_21(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_21[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_22(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_22[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_23(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_23[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_24(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_24[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_25(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_25[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_26(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_26[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_27(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_27[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_28(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_28[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_29(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_29[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_2A(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_2A[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_2B(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_2B[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_2C(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_2C[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_2D(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_2D[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_2E(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_2E[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_2F(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_2F[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_30(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_30[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_31(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_31[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_32(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_32[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_33(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_33[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_34(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_34[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_35(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_35[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_36(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_36[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_37(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_37[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_38(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_38[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_39(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_39[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_3A(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_3A[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_3B(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_3B[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_3C(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_3C[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_3D(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_3D[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_3E(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_3E[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00"),
                            .INITVAL_3F(checkINIT(FAMILY_CODE) == 1 ? INIT_VALUE_3F[(i0*EBR_DATA+i1+1)*STRING_LENGTH*8-1:(i0*EBR_DATA+i1)*STRING_LENGTH*8] : "0x00")
                        ) u_dp16k (
                            // ------ PORT A signals ------
                            .clk_a_i     (clk_a_i),
                            .clk_en_a_i  (clk_en_a_i),
                            .rst_a_i     (rst_a_i),
                            .wr_en_a_i   (wr_en_a_i & chk_addr_a_w),
                            .ben_a_i     (ben_a_w),
                            .addr_a_i    (addr_a_w),
                            .wr_data_a_i (in_a_w),
                        
                            .rd_data_a_o (out_a_w),
                        
                            // ------ PORT B signals ------
                            .clk_b_i     (clk_b_i),
                            .clk_en_b_i  (clk_en_b_i),
                            .rst_b_i     (rst_b_i),
                            .wr_en_b_i   (wr_en_b_i & chk_addr_b_w),
                            .ben_b_i     (ben_b_w),
                            .addr_b_i    (addr_b_w),
                            .wr_data_b_i (in_b_w),
                        
                            .rd_data_b_o (out_b_w)
                        );
                    end
                    else begin : no_mem_file
                        lscc_ram_dp_true_core # (
                            // ------ COMMON PARAMETERS ------
                            .FAMILY          (FAMILY),
                            .INIT_MODE       (INIT_MODE),
                            .MEM_SIZE        (MEM_SIZE),
                            .MEM_ID          (MEM_ID),
                            .POSx            (ECO_POSX),
                            .POSy            (ECO_POSY),
                        
                            // ------ PORT A PARAMETERS ------
                            .DATA_WIDTH_A    (A_DWID_IMPL),
                            .REGMODE_A       (REGMODE_A),
                            .RESETMODE_A     (RESETMODE_A),
                            .RESET_RELEASE_A (RESET_RELEASE_A),
                            .BYTE_ENABLE_A   (BYTE_ENABLE_A),
                            .BYTE_EN_POL_A   (BYTE_EN_POL_A),
                        
                            // ------ PORT B PARAMETERS ------                        
                            .DATA_WIDTH_B    (B_DWID_IMPL),
                            .REGMODE_B       (REGMODE_B),
                            .RESETMODE_B     (RESETMODE_B),
                            .RESET_RELEASE_B (RESET_RELEASE_B),
                            .BYTE_ENABLE_B   (BYTE_ENABLE_B),
                            .BYTE_EN_POL_B   (BYTE_EN_POL_B)
                        ) u_dp16k (
                            // ------ PORT A signals ------
                            .clk_a_i     (clk_a_i),
                            .clk_en_a_i  (clk_en_a_i),
                            .rst_a_i     (rst_a_i),
                            .wr_en_a_i   (wr_en_a_i & chk_addr_a_w),
                            .ben_a_i     (ben_a_w),
                            .addr_a_i    (addr_a_w),
                            .wr_data_a_i (in_a_w),
                        
                            .rd_data_a_o (out_a_w),
                        
                            // ------ PORT B signals ------
                            .clk_b_i     (clk_b_i),
                            .clk_en_b_i  (clk_en_b_i),
                            .rst_b_i     (rst_b_i),
                            .wr_en_b_i   (wr_en_b_i & chk_addr_b_w),
                            .ben_b_i     (ben_b_w),
                            .addr_b_i    (addr_b_w),
                            .wr_data_b_i (in_b_w),
                        
                            .rd_data_b_o (out_b_w)
                        );
                    end
                end
            end
            if(EBR_ADDR == 1) begin
                assign out_a_ebr_w = out_a_ebr_raw_w[0];
                assign out_b_ebr_w = out_b_ebr_raw_w[0];
            end
            else begin
                // ------ PORT A output assignment ------
                reg [DATA_WIDTH_A-1:0] a_out_buff_r;
                reg [ADDR_WIDTH_A-1:0] addr_a_p_r;
                assign out_a_ebr_w = a_out_buff_r;

                // synthesis translate_off
                initial begin
                    a_out_buff_r = {DATA_WIDTH_A{1'b0}};
                    addr_a_p_r   = {ADDR_WIDTH_A{1'b0}};
                end
                // synthesis translate_on
            
                always @ (*) begin
                    a_out_buff_r = out_a_ebr_raw_w[addr_a_p_r[ADDR_WIDTH_A-1:A_AWID_IMPL]];
                end
                
                if(REGMODE_A == "noreg") begin
                    if(RESETMODE_A == "sync") begin
                        always @ (posedge clk_a_i) begin
                            if(rst_a_i) begin
                                addr_a_p_r <= {ADDR_WIDTH_A{1'b0}};
                            end
                            else begin
                                addr_a_p_r <= addr_a_i;
                            end
                        end
                    end
                    else begin
                        always @ (posedge clk_a_i, posedge rst_a_i) begin
                            if(rst_a_i) begin
                                addr_a_p_r <= {ADDR_WIDTH_A{1'b0}};
                            end
                            else begin
                                addr_a_p_r <= addr_a_i;
                            end
                        end
                    end
                end
                else begin
                    reg [ADDR_WIDTH_A-1:0] addr_a_p2_r   = {ADDR_WIDTH_A{1'b0}};

                    // synthesis translate_off
                    initial begin
                        addr_a_p2_r = {ADDR_WIDTH_A{1'b0}};
                    end
                    // synthesis translate_on

                    if(RESETMODE_A == "sync") begin
                        always @ (posedge clk_a_i) begin
                            if(rst_a_i) begin
                                addr_a_p2_r <= {ADDR_WIDTH_A{1'b0}};
                                addr_a_p_r <= {ADDR_WIDTH_A{1'b0}};
                            end
                            else begin
                                addr_a_p2_r <= addr_a_i;
                                addr_a_p_r <= addr_a_p2_r;
                            end
                        end
                    end
                    else begin
                        always @ (posedge clk_a_i, posedge rst_a_i) begin
                            if(rst_a_i) begin
                                addr_a_p2_r <= {ADDR_WIDTH_A{1'b0}};
                                addr_a_p_r <= {ADDR_WIDTH_A{1'b0}};
                            end
                            else begin
                                addr_a_p2_r <= addr_a_i;
                                addr_a_p_r <= addr_a_p2_r;
                            end
                        end
                    end
                end
            
                // ------ PORT B output assignment ------
                reg [DATA_WIDTH_B-1:0] b_out_buff_r = {DATA_WIDTH_B{1'b0}};
                reg [ADDR_WIDTH_B-1:0] addr_b_p_r   = {ADDR_WIDTH_B{1'b0}};
                assign out_b_ebr_w = b_out_buff_r;

                // synthesis translate_off
                initial begin
                    b_out_buff_r = {DATA_WIDTH_B{1'b0}};
                    addr_b_p_r   = {ADDR_WIDTH_B{1'b0}};
                end
                // synthesis translate_on

                always @ (*) begin
                    b_out_buff_r = out_b_ebr_raw_w[addr_b_p_r[ADDR_WIDTH_B-1:B_AWID_IMPL]];
                end
                
                if(REGMODE_B == "noreg") begin
                    if(RESETMODE_B == "sync") begin
                        always @ (posedge clk_b_i) begin
                            if(rst_b_i) begin
                                addr_b_p_r <= {ADDR_WIDTH_B{1'b0}};
                            end
                            else begin
                                addr_b_p_r <= addr_b_i;
                            end
                        end
                    end
                    else begin
                        always @ (posedge clk_b_i, posedge rst_b_i) begin
                            if(rst_b_i) begin
                                addr_b_p_r <= {ADDR_WIDTH_B{1'b0}};
                            end
                            else begin
                                addr_b_p_r <= addr_b_i;
                            end
                        end
                    end
                end
                else begin
                    reg [ADDR_WIDTH_B-1:0] addr_b_p2_r = {ADDR_WIDTH_B{1'b0}};

                    // synthesis translate_off
                    initial begin
                        addr_b_p2_r = {ADDR_WIDTH_B{1'b0}};
                    end
                    // synthesis translate_on

                    if(RESETMODE_B == "sync") begin
                        always @ (posedge clk_b_i) begin
                            if(rst_b_i) begin
                                addr_b_p2_r <= {ADDR_WIDTH_B{1'b0}};
                                addr_b_p_r <= {ADDR_WIDTH_B{1'b0}};
                            end
                            else begin
                                addr_b_p2_r <= addr_b_i;
                                addr_b_p_r <= addr_b_p2_r;
                            end
                        end
                    end
                    else begin
                        always @ (posedge clk_b_i, posedge rst_b_i) begin
                            if(rst_b_i) begin
                                addr_b_p2_r <= {ADDR_WIDTH_B{1'b0}};
                                addr_b_p_r <= {ADDR_WIDTH_B{1'b0}};
                            end
                            else begin
                                addr_b_p2_r <= addr_b_i;
                                addr_b_p_r <= addr_b_p2_r;
                            end
                        end
                    end
                end
            end
        end
    end
endgenerate

function checkINIT;
    input [31:0] val;
    begin
        checkINIT = 1;
    end
endfunction

function [31:0] getImplByteWidth;
    input [31:0] dwid;
    input [31:0] family_code;
    begin
        case(family_code)
            _FCODE_LIFCL_:
            begin
                case(dwid)
                    18: getImplByteWidth = 2;
                    16: getImplByteWidth = 2;
                    9: getImplByteWidth = 1;
                    default: getImplByteWidth = 1;
                endcase
            end
            default: getImplByteWidth = 1;
        endcase
    end
endfunction

function [31:0] getDatabase;
    input [31:0] base_count;
    input [31:0] index;
    input [31:0] family_code;
    begin
        case(family_code)
            _FCODE_LIFCL_:
            begin
                case(base_count)
                    9: begin
                        case(index)
                            0: getDatabase = 9;
                            default: getDatabase = 18;
                        endcase
                    end
                    8: begin
                        case(index)
                            0: getDatabase = 1;
                            1: getDatabase = 2;
                            2: getDatabase = 4;
                            3: getDatabase = 8;
                            default: getDatabase = 16;
                        endcase
                    end
                    default: getDatabase = 16;
                endcase
            end
            default: getDatabase = base_count;
        endcase
    end
endfunction

function [31:0] getCASE1DataImpl_wBEN;
    input [31:0] addr_a_depth;
    input [31:0] data_a_width;
    input [31:0] addr_b_depth;
    input [31:0] data_b_width;
    input is_taking_port_a;
    input is_taking_total_ebr;
    input [31:0] family_code;
    reg [5:0] num0, num1;
    reg [31:0] divisor, addr_div_prtA, data_div_prtA, addr_div_prtB, data_div_prtB;
    reg [31:0] portA_addr_chk, portA_data_chk, portB_addr_chk, portB_data_chk;
    reg [31:0] EBR_usage, PROD;
    begin
        case(family_code)
            _FCODE_LIFCL_:
            begin
                if(data_a_width > data_b_width) begin
                    if(is_taking_port_a) begin
                        if(data_a_width % 9 == 0) getCASE1DataImpl_wBEN = 18;
                        else getCASE1DataImpl_wBEN = 16;
                    end
                    else begin
                        if(data_a_width % 9 == 0) getCASE1DataImpl_wBEN = 9;
                        else getCASE1DataImpl_wBEN = 8;
                    end
                end
                else begin
                    if(is_taking_port_a) begin
                        if(data_a_width % 9 == 0) getCASE1DataImpl_wBEN = 9;
                        else getCASE1DataImpl_wBEN = 8;
                    end
                    else begin
                        if(data_a_width % 9 == 0) getCASE1DataImpl_wBEN = 18;
                        else getCASE1DataImpl_wBEN = 16;
                    end
                end
            end
            default: getCASE1DataImpl_wBEN = 8;
        endcase
    end
endfunction

function [31:0] getCASE1DataImpl;
    input [31:0] addr_a_depth;
    input [31:0] data_a_width;
    input [31:0] addr_b_depth;
    input [31:0] data_b_width;
    input is_taking_port_a;
    input is_taking_total_ebr;
    input [31:0] family_code;
    reg [5:0] num0, num1;
    reg [31:0] divisor, addr_div_prtA, data_div_prtA, addr_div_prtB, data_div_prtB;
    reg [31:0] portA_addr_chk, portA_data_chk, portB_addr_chk, portB_data_chk;
    reg [31:0] EBR_usage, PROD;
    begin
        divisor = (addr_a_depth > addr_b_depth) ? (addr_a_depth/addr_b_depth) : (addr_b_depth/addr_a_depth);
        EBR_usage = {32{1'b1}};
        getCASE1DataImpl = 0;
        if(family_code == _FCODE_LIFCL_) begin
            if(divisor == 2) begin
                for(num0 = 0; num0 < 2; num0 = num0 + 1) begin
                    data_div_prtA = getDatabase(9, num0, family_code);
                    addr_div_prtA = data_to_addr(data_div_prtA, family_code);
                    portA_addr_chk = roundUP(addr_a_depth, addr_div_prtA);
                    portA_data_chk = roundUP(data_a_width, data_div_prtA);
                    for(num1 = 0; num1 < 2; num1 = num1 + 1) begin
                        data_div_prtB = getDatabase(9, num1, family_code);
                        addr_div_prtB = data_to_addr(data_div_prtB, family_code);
                        portB_addr_chk = roundUP(addr_b_depth, addr_div_prtB);
                        portB_data_chk = roundUP(data_b_width, data_div_prtB);
                        if((portA_addr_chk == portB_addr_chk) && (portA_data_chk == portB_data_chk)) begin
                            if((data_a_width % data_div_prtA == 0) && (data_b_width % data_div_prtB == 0)) begin
                                PROD = portA_addr_chk * portA_data_chk;
                                if(PROD < EBR_usage) begin
                                    EBR_usage = PROD;
                                    if(is_taking_total_ebr == 1'b1) begin
                                        getCASE1DataImpl = EBR_usage;
                                    end
                                    else begin
                                        if(is_taking_port_a == 1'b1) begin
                                            getCASE1DataImpl = data_div_prtA;
                                        end
                                        else begin
                                            getCASE1DataImpl = data_div_prtB;
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        for(num0 = 0; num0 < 5; num0 = num0+1) begin
            data_div_prtA = getDatabase(8, num0, family_code);
            addr_div_prtA = data_to_addr(data_div_prtA, family_code);
            portA_addr_chk = roundUP(addr_a_depth, addr_div_prtA);
            portA_data_chk = roundUP(data_a_width, data_div_prtA);
            for(num1 = 0; num1 < 5; num1 = num1+1) begin
                data_div_prtB = getDatabase(8, num1, family_code);
                addr_div_prtB = data_to_addr(data_div_prtB, family_code);
                portB_addr_chk = roundUP(addr_b_depth, addr_div_prtB);
                portB_data_chk = roundUP(data_b_width, data_div_prtB);
                if((portA_addr_chk == portB_addr_chk) && (portA_data_chk == portB_data_chk)) begin
                    PROD = portA_addr_chk * portA_data_chk;
                    if(PROD < EBR_usage) begin
                        EBR_usage = PROD;
                        if(is_taking_total_ebr == 1'b1) begin
                            getCASE1DataImpl = EBR_usage;
                        end
                        else begin
                            if(is_taking_port_a == 1'b1) begin
                                getCASE1DataImpl = data_div_prtA;
                            end
                            else begin
                                getCASE1DataImpl = data_div_prtB;
                            end
                        end
                    end
                end
            end
        end
    end
endfunction

function [31:0] procData;
    input [31:0] max_data;
    input [31:0] family_code;
    begin
        procData = 1;
        while(procData < max_data) begin
            case(family_code)
                _FCODE_LIFCL_:
                begin
                    if(procData < 8) begin
                        procData = procData*2;
                    end
                    else begin
                        if(procData == 8) begin
                            procData = 9;
                        end
                        else if(procData%9 == 0) begin
                            procData = (procData/9) * 16;
                        end
                        else begin
                            procData = (procData/8) * 9;
                        end
                    end
                end
                default: procData = max_data;
            endcase
        end
    end
endfunction

function [31:0] data_to_addr;
    input[31:0] data_size;
    input [31:0] family_code;
    begin
        case(family_code)
            _FCODE_LIFCL_:
            begin
                case(data_size)
                    18: data_to_addr = 1024;
                    16: data_to_addr = 1024;
                    9: data_to_addr = 2048;
                    8: data_to_addr = 2048;
                    4: data_to_addr = 4096;
                    2: data_to_addr = 8192;
                    default: data_to_addr = 16384;
                endcase
            end
            default: data_to_addr = 1024;
        endcase
    end
endfunction

function [31:0] getMinimaData;
    input [31:0] depth_impl;
    input [31:0] width_impl;
    input is_byte_en;
    input [31:0] byte_size;
    input [31:0] family_code;
    reg [31:0] temp_00, temp_01, temp_02, temp_03, temp_04;
    begin
        case(family_code)
            _FCODE_LIFCL_:
            begin
                temp_00 = EBR_impl(depth_impl, width_impl, 1024, 18);
                temp_01 = EBR_impl(depth_impl, width_impl, 2048, 9);
                temp_02 = EBR_impl(depth_impl, width_impl, 4096, 4);
                temp_03 = EBR_impl(depth_impl, width_impl, 8192, 2);
                temp_04 = EBR_impl(depth_impl, width_impl, 16384, 1);
                if((is_byte_en == 1 && (width_impl%9!=0))) begin
                    temp_00 = EBR_impl(depth_impl, width_impl, 1024, 16);
                    temp_01 = EBR_impl(depth_impl, width_impl, 2048, 8);
                    if(temp_00 < temp_01) begin
                        if(temp_00 < temp_02) begin
                            if(temp_00 < temp_03) begin
                                if(temp_00 < temp_04) getMinimaData = 16;
                                else getMinimaData = 1;
                            end
                            else begin
                                if(temp_03 < temp_04) getMinimaData = 2;
                                else getMinimaData = 1;
                            end
                        end
                        else begin
                            if(temp_02 < temp_03) begin
                                if(temp_02 < temp_04) getMinimaData = 4;
                                else getMinimaData = 1;
                            end
                            else begin
                                if(temp_03 < temp_04) getMinimaData = 2;
                                else getMinimaData = 1;
                            end
                        end
                    end
                    else begin
                        if(temp_01 < temp_02) begin
                            if(temp_01 < temp_03) begin
                                if(temp_01 < temp_04) getMinimaData = 8;
                                else getMinimaData = 1;
                            end
                            else begin
                                if(temp_03 < temp_04) getMinimaData = 2;
                                else getMinimaData = 1;
                            end
                        end
                        else begin
                            if(temp_02 < temp_03) begin
                                if(temp_02 < temp_04) getMinimaData = 4;
                                else getMinimaData = 1;
                            end
                            else begin
                                if(temp_03 < temp_04) getMinimaData = 2;
                                else getMinimaData = 1;
                            end
                        end
                    end              
                end
                else begin
                    if(temp_00 < temp_01) begin
                        if(temp_00 < temp_02) begin
                            if(temp_00 < temp_03) begin
                                if(temp_00 < temp_04) getMinimaData = 18;
                                else getMinimaData = 1;
                            end
                            else begin
                                if(temp_03 < temp_04) getMinimaData = 2;
                                else getMinimaData = 1;
                            end
                        end
                        else begin
                            if(temp_02 < temp_03) begin
                                if(temp_02 < temp_04) getMinimaData = 4;
                                else getMinimaData = 1;
                            end
                            else begin
                                if(temp_03 < temp_04) getMinimaData = 2;
                                else getMinimaData = 1;
                            end
                        end
                    end
                    else begin
                        if(temp_01 < temp_02) begin
                            if(temp_01 < temp_03) begin
                                if(temp_01 < temp_04) getMinimaData = 9;
                                else getMinimaData = 1;
                            end
                            else begin
                                if(temp_03 < temp_04) getMinimaData = 2;
                                else getMinimaData = 1;
                            end
                        end
                        else begin
                            if(temp_02 < temp_03) begin
                                if(temp_02 < temp_04) getMinimaData = 4;
                                else getMinimaData = 1;
                            end
                            else begin
                                if(temp_03 < temp_04) getMinimaData = 2;
                                else getMinimaData = 1;
                            end
                        end
                    end
                end
            end
            default: getMinimaData = 8;
        endcase
    end
endfunction

function [31:0] getByteSize;
    input [31:0] data_width;
    input [31:0] dev_code;
    begin
        case(dev_code)
            _FCODE_LIFCL_:
            begin
                if(data_width%9 == 0) getByteSize = 9;
                else getByteSize = 8;
            end
            default: getByteSize = 8;
        endcase
    end
endfunction

function [31:0] EBR_impl;
    input [31:0] DEPTH_IMPL;
    input [31:0] WIDTH_IMPL;
    input [31:0] ADDR_DEPTH_X;
    input [31:0] DATA_WIDTH_X;
    begin
        EBR_impl = roundUP(DEPTH_IMPL, ADDR_DEPTH_X)*roundUP(WIDTH_IMPL, DATA_WIDTH_X);
    end
endfunction

function [31:0] roundUP;
    input [31:0] dividend;
    input [31:0] divisor;
    begin
        if(divisor == 1) begin
            roundUP = dividend;
        end
        else if(divisor == dividend) begin
            roundUP = 1;
        end
        else begin
            roundUP = dividend/divisor + (((dividend % divisor) == 0) ? 0 : 1);
        end
    end
endfunction

function [31:0] clog2;
  input [31:0] value;
  reg   [31:0] num;
  begin
    num = value - 1;
    for (clog2=0; num>0; clog2=clog2+1) num = num>>1;
  end
endfunction

endmodule
`endif

// =============================================================================
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
// -----------------------------------------------------------------------------
//   Copyright (c) 2017 by Lattice Semiconductor Corporation
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
// Project               : Radiant Software 1.1
// File                  : lscc_ram_dp_true_core.v
// Title                 :
// Dependencies          :
// Description           : Implements a single true dual port EBR primitive.
// =============================================================================
//                        REVISION HISTORY
// Version               : 1.0.0.
// Author(s)             :
// Mod. Date             :
// Changes Made          : Initial release.
// =============================================================================


`ifndef LSCC_RAM_DP_TRUE_CORE
`define LSCC_RAM_DP_TRUE_CORE

module lscc_ram_dp_true_core # (
// ---------------------------
// --------- Family parameters
// ---------------------------
    parameter    _FCODE_LIFCL_   = 1,
    parameter    _FCODE_COMMON_  = 0,
    parameter    FAMILY          = "common",
    parameter    MEM_ID          = "MEM0",
    parameter    MEM_SIZE        = "18,1024",
    parameter    FAMILY_CODE     =  FAMILY == "LIFCL" ? _FCODE_LIFCL_ : _FCODE_COMMON_,
// ---------------------------
// --------- PORT A parameters
// ---------------------------
    parameter    DATA_WIDTH_A    = 18,
    parameter    ADDR_WIDTH_A    = getAddrWidth(DATA_WIDTH_A, FAMILY_CODE),
    parameter    REGMODE_A       = "reg",
    parameter    RESETMODE_A     = "sync",
    parameter    RESET_RELEASE_A = "sync",
    parameter    BYTE_ENABLE_A   = 0,
    parameter    BYTE_SIZE_A     = getByteSize(BYTE_ENABLE_A, FAMILY_CODE, DATA_WIDTH_A),
    parameter    BYTE_WIDTH_A    = roundUP(DATA_WIDTH_A,BYTE_SIZE_A),
    parameter    BYTE_EN_POL_A   = "active-high",
// ---------------------------
// --------- PORT B parameters
// ---------------------------
    parameter    DATA_WIDTH_B    = 18,
    parameter    ADDR_WIDTH_B    = getAddrWidth(DATA_WIDTH_B, FAMILY_CODE),
    parameter    REGMODE_B       = "reg",
    parameter    RESETMODE_B     = "sync",
    parameter    RESET_RELEASE_B = "sync",
    parameter    BYTE_ENABLE_B   = 0,
    parameter    BYTE_SIZE_B     = getByteSize(BYTE_ENABLE_B, FAMILY_CODE, DATA_WIDTH_B),
    parameter    BYTE_WIDTH_B    = roundUP(DATA_WIDTH_B,BYTE_SIZE_B),
    parameter    BYTE_EN_POL_B   = "active-high",
// ---------------------------
// --------- Common parameters
// ---------------------------
    parameter    POSx            = 0,
    parameter    POSy            = 0,
    parameter    STRING_SIZE     = calculateStringSize(POSx,POSy),
    parameter    INIT_MODE       = "none",
    parameter    INITVAL_00      = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000",
    parameter    INITVAL_01      = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000",
    parameter    INITVAL_02      = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000",
    parameter    INITVAL_03      = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000",
    parameter    INITVAL_04      = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000",
    parameter    INITVAL_05      = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000",
    parameter    INITVAL_06      = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000",
    parameter    INITVAL_07      = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000",
    parameter    INITVAL_08      = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000",
    parameter    INITVAL_09      = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000",
    parameter    INITVAL_0A      = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000",
    parameter    INITVAL_0B      = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000",
    parameter    INITVAL_0C      = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000",
    parameter    INITVAL_0D      = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000",
    parameter    INITVAL_0E      = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000",
    parameter    INITVAL_0F      = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000",
    parameter    INITVAL_10      = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000",
    parameter    INITVAL_11      = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000",
    parameter    INITVAL_12      = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000",
    parameter    INITVAL_13      = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000",
    parameter    INITVAL_14      = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000",
    parameter    INITVAL_15      = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000",
    parameter    INITVAL_16      = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000",
    parameter    INITVAL_17      = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000",
    parameter    INITVAL_18      = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000",
    parameter    INITVAL_19      = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000",
    parameter    INITVAL_1A      = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000",
    parameter    INITVAL_1B      = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000",
    parameter    INITVAL_1C      = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000",
    parameter    INITVAL_1D      = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000",
    parameter    INITVAL_1E      = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000",
    parameter    INITVAL_1F      = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000",
    parameter    INITVAL_20      = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000",
    parameter    INITVAL_21      = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000",
    parameter    INITVAL_22      = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000",
    parameter    INITVAL_23      = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000",
    parameter    INITVAL_24      = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000",
    parameter    INITVAL_25      = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000",
    parameter    INITVAL_26      = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000",
    parameter    INITVAL_27      = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000",
    parameter    INITVAL_28      = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000",
    parameter    INITVAL_29      = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000",
    parameter    INITVAL_2A      = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000",
    parameter    INITVAL_2B      = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000",
    parameter    INITVAL_2C      = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000",
    parameter    INITVAL_2D      = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000",
    parameter    INITVAL_2E      = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000",
    parameter    INITVAL_2F      = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000",
    parameter    INITVAL_30      = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000",
    parameter    INITVAL_31      = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000",
    parameter    INITVAL_32      = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000",
    parameter    INITVAL_33      = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000",
    parameter    INITVAL_34      = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000",
    parameter    INITVAL_35      = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000",
    parameter    INITVAL_36      = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000",
    parameter    INITVAL_37      = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000",
    parameter    INITVAL_38      = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000",
    parameter    INITVAL_39      = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000",
    parameter    INITVAL_3A      = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000",
    parameter    INITVAL_3B      = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000",
    parameter    INITVAL_3C      = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000",
    parameter    INITVAL_3D      = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000",
    parameter    INITVAL_3E      = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000",
    parameter    INITVAL_3F      = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000" 
)(
// ---------------------------
// - PORT A input/output ports
// ---------------------------
    
    input                       clk_a_i,
    input                       clk_en_a_i,
    input                       rst_a_i,
    input                       wr_en_a_i,
    input [BYTE_WIDTH_A-1:0]    ben_a_i,
    input [ADDR_WIDTH_A-1:0]    addr_a_i,
    input [DATA_WIDTH_A-1:0]    wr_data_a_i,

    output [DATA_WIDTH_A-1:0]   rd_data_a_o,

// ---------------------------
// - PORT B input/output ports
// ---------------------------
    
    input                       clk_b_i,
    input                       clk_en_b_i,
    input                       rst_b_i,
    input                       wr_en_b_i,
    input [BYTE_WIDTH_B-1:0]    ben_b_i,
    input [ADDR_WIDTH_B-1:0]    addr_b_i,
    input [DATA_WIDTH_B-1:0]    wr_data_b_i,

    output [DATA_WIDTH_B-1:0]   rd_data_b_o
);

// -----------------------------------------------------------------------------
// Local Parameters
// -----------------------------------------------------------------------------
localparam        POS_X0     = POSx % 10;
localparam        POS_X1     = (POSx/10) % 10;
localparam        POS_X2     = (POSx/100) % 10;
localparam        POS_X3     = (POSx/1000) % 10;
localparam        POS_X4     = (POSx/10000) % 10;
localparam        POS_X5     = (POSx/100000) % 10;
localparam        POS_X6     = (POSx/1000000) % 10;
localparam        POS_X7     = (POSx/10000000) % 10;

localparam        POS_Y0     = POSy % 10;
localparam        POS_Y1     = (POSy/10) % 10;
localparam        POS_Y2     = (POSy/100) % 10;
localparam        POS_Y3     = (POSy/1000) % 10; 
localparam        POS_Y4     = (POSy/10000) % 10;
localparam        POS_Y5     = (POSy/100000) % 10;
localparam        POS_Y6     = (POSy/1000000) % 10;
localparam        POS_Y7     = (POSy/10000000) % 10;

localparam [79:0] NUM_STRING = "9876543210";
localparam        BLOCK_POS  = getStringFromPos(POSx, POSy);
localparam        BLOCK_SIZE = DATA_WIDTH_A == 18 ? "[18,1024]" :
                               DATA_WIDTH_A == 16 ? "[16,1024]" :
                               DATA_WIDTH_A == 9 ? "[9,2048]" :
                               DATA_WIDTH_A == 8 ? "[8,2048]" :
                               DATA_WIDTH_A == 4 ? "[4,4096]" :
                               DATA_WIDTH_A == 2 ? "[2,8192]" : "[1,16384]";

generate
    if( FAMILY == "LIFCL") begin : LIFCL
        wire [13:0] addr_a_w;
        wire [17:0] in_a_w;
        wire [17:0] out_a_w;

        wire [13:0] addr_b_w;
        wire [17:0] in_b_w;
        wire [17:0] out_b_w;

        if(DATA_WIDTH_A == 18 || DATA_WIDTH_A == 16) begin
            assign addr_a_w[13:4] = addr_a_i;
            assign addr_a_w[3:2] = 2'b11;
            assign addr_a_w[1:0] = (BYTE_ENABLE_A == 1) ? ben_a_i : 2'b11;
            if(DATA_WIDTH_A == 18) begin
                assign in_a_w = wr_data_a_i;
                assign rd_data_a_o = out_a_w;
            end
            else begin
                assign in_a_w[16:9] = wr_data_a_i[15:8];
                assign in_a_w[7:0] = wr_data_a_i[7:0];
                assign in_a_w[8] = 1'b0;
                assign in_a_w[17] = 1'b0;
                assign rd_data_a_o[15:8] = out_a_w[16:9];
                assign rd_data_a_o[7:0] = out_a_w[7:0];
            end
        end
        else begin
            assign addr_a_w[13:14-ADDR_WIDTH_A] = addr_a_i;
            if(ADDR_WIDTH_A != 14) begin
                assign addr_a_w[14-(ADDR_WIDTH_A+1):0] = {(14-ADDR_WIDTH_A){1'b1}};
            end
            assign in_a_w[17:DATA_WIDTH_A] = {(18-DATA_WIDTH_A){1'b0}};
            assign in_a_w[DATA_WIDTH_A-1:0] = wr_data_a_i;
            assign rd_data_a_o = out_a_w[DATA_WIDTH_A-1:0];
        end

        if(DATA_WIDTH_B == 18 || DATA_WIDTH_B == 16) begin
            assign addr_b_w[13:4] = addr_b_i;
            assign addr_b_w[3:2] = 2'b11;
            assign addr_b_w[1:0] = (BYTE_ENABLE_B == 1) ? ben_b_i : 2'b11;
            if(DATA_WIDTH_B == 18) begin
                assign in_b_w = wr_data_b_i;
                assign rd_data_b_o = out_b_w;
            end
            else begin
                assign in_b_w[16:9] = wr_data_b_i[15:8];
                assign in_b_w[7:0] = wr_data_b_i[7:0];
                assign in_b_w[8] = 1'b0;
                assign in_b_w[17] = 1'b0;
                assign rd_data_b_o[15:8] = out_b_w[16:9];
                assign rd_data_b_o[7:0] = out_b_w[7:0];
            end
        end
        else begin
            assign addr_b_w[13:14-ADDR_WIDTH_B] = addr_b_i;
            if(ADDR_WIDTH_B != 14) begin
                assign addr_b_w[14-(ADDR_WIDTH_B+1):0] = {(14-ADDR_WIDTH_B){1'b1}};
            end
            assign in_b_w[17:DATA_WIDTH_B] = {(18-DATA_WIDTH_B){1'b0}};
            assign in_b_w[DATA_WIDTH_B-1:0] = wr_data_b_i;
            assign rd_data_b_o = out_b_w[DATA_WIDTH_B-1:0];
        end

        wire t_wr_en_a_i = (BYTE_ENABLE_A == 0 || BYTE_WIDTH_A > 1) ? wr_en_a_i : wr_en_a_i & ben_a_i;
        wire t_wr_en_b_i = (BYTE_ENABLE_B == 0 || BYTE_WIDTH_B > 1) ? wr_en_b_i : wr_en_b_i & ben_b_i;

        wire [17:0] DIA  = in_a_w;
        wire [17:0] DIB  = in_b_w;
        wire [13:0] ADA  = addr_a_w;
        wire [13:0] ADB  = addr_b_w;
        wire        CLKA = clk_a_i;
        wire        CLKB = clk_b_i;
        wire        CEA  = clk_en_a_i;
        wire        CEB  = clk_en_b_i;
        wire        WEA  = t_wr_en_a_i;
        wire        WEB  = t_wr_en_b_i;
        wire [2:0]  CSA  = {clk_en_a_i, clk_en_a_i, clk_en_a_i};
        wire [2:0]  CSB  = {clk_en_b_i, clk_en_b_i, clk_en_b_i};
        wire        RSTA = rst_a_i;
        wire        RSTB = rst_b_i;

        localparam    DW_A      = (DATA_WIDTH_A == 18 || DATA_WIDTH_A == 16) ? "X18" :
                                  (DATA_WIDTH_A == 9  || DATA_WIDTH_A == 8) ? "X9" :
                                  (DATA_WIDTH_A == 4) ? "X4" : 
                                  (DATA_WIDTH_A == 2 ? "X2" : "X1");
        localparam    REG_A     = (REGMODE_A == "reg") ? "USED" : "BYPASSED";
        localparam    RST_A     = (RESETMODE_A == "sync") ? "SYNC" : "ASYNC";
        localparam    CSC_A     = "000";
        localparam    RST_REL_A = (RESET_RELEASE_A == "sync") ? "SYNC" : "ASYNC";
        localparam    DW_B      = (DATA_WIDTH_B == 18 || DATA_WIDTH_B == 16) ? "X18" :
                                  (DATA_WIDTH_B == 9  || DATA_WIDTH_B == 8) ? "X9" :
                                  (DATA_WIDTH_B == 4) ? "X4" : 
                                  (DATA_WIDTH_B == 2 ? "X2" : "X1");
        localparam    REG_B     = (REGMODE_B == "reg") ? "USED" : "BYPASSED";
        localparam    RST_B     = (RESETMODE_B == "sync") ? "SYNC" : "ASYNC";
        localparam    CSC_B     = "000";
        localparam    RST_REL_B = (RESET_RELEASE_B == "sync") ? "SYNC" : "ASYNC";

        localparam MEM_TYPE = "EBR";
        localparam T_MEM_SIZE = {"[",MEM_SIZE,"]"};

        (* ECO_MEM_TYPE=MEM_TYPE, ECO_MEM_ID=MEM_ID, ECO_MEM_SIZE=T_MEM_SIZE, ECO_MEM_BLOCK_SIZE=BLOCK_SIZE, ECO_MEM_BLOCK_POS=BLOCK_POS *) DP16K dp16k (
            .DIA (DIA), 
            .DIB (DIB), 
            .ADA (ADA), 
            .ADB (ADB), 
            .CLKA(CLKA), 
            .CLKB(CLKB), 
            .WEA (WEA), 
            .WEB (WEB), 
            .CEA (CEA), 
            .CEB (CEB), 
            .RSTA(RSTA), 
            .RSTB(RSTB),
            .CSA (CSA), 
            .CSB (CSB), 
            .DOA (out_a_w), 
            .DOB (out_b_w)
        );
        defparam dp16k.DATA_WIDTH_A        = DW_A;
        defparam dp16k.DATA_WIDTH_B        = DW_B;
        defparam dp16k.OUTREG_A            = REG_A;
        defparam dp16k.OUTREG_B            = REG_B;
        defparam dp16k.RESETMODE_A         = RST_A;
        defparam dp16k.RESETMODE_B         = RST_B;
        defparam dp16k.CSDECODE_A          = CSC_A;
        defparam dp16k.CSDECODE_B          = CSC_B;
        defparam dp16k.ASYNC_RST_RELEASE_A = RST_REL_A;
        defparam dp16k.ASYNC_RST_RELEASE_B = RST_REL_B;
        defparam dp16k.INIT_DATA           = "DYNAMIC";
        defparam dp16k.INITVAL_00          = (INIT_MODE == "mem_file") ? INITVAL_00 : (INIT_MODE == "all_one") ? "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" : "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        defparam dp16k.INITVAL_01          = (INIT_MODE == "mem_file") ? INITVAL_01 : (INIT_MODE == "all_one") ? "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" : "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        defparam dp16k.INITVAL_02          = (INIT_MODE == "mem_file") ? INITVAL_02 : (INIT_MODE == "all_one") ? "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" : "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        defparam dp16k.INITVAL_03          = (INIT_MODE == "mem_file") ? INITVAL_03 : (INIT_MODE == "all_one") ? "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" : "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        defparam dp16k.INITVAL_04          = (INIT_MODE == "mem_file") ? INITVAL_04 : (INIT_MODE == "all_one") ? "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" : "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        defparam dp16k.INITVAL_05          = (INIT_MODE == "mem_file") ? INITVAL_05 : (INIT_MODE == "all_one") ? "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" : "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        defparam dp16k.INITVAL_06          = (INIT_MODE == "mem_file") ? INITVAL_06 : (INIT_MODE == "all_one") ? "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" : "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        defparam dp16k.INITVAL_07          = (INIT_MODE == "mem_file") ? INITVAL_07 : (INIT_MODE == "all_one") ? "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" : "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        defparam dp16k.INITVAL_08          = (INIT_MODE == "mem_file") ? INITVAL_08 : (INIT_MODE == "all_one") ? "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" : "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        defparam dp16k.INITVAL_09          = (INIT_MODE == "mem_file") ? INITVAL_09 : (INIT_MODE == "all_one") ? "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" : "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        defparam dp16k.INITVAL_0A          = (INIT_MODE == "mem_file") ? INITVAL_0A : (INIT_MODE == "all_one") ? "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" : "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        defparam dp16k.INITVAL_0B          = (INIT_MODE == "mem_file") ? INITVAL_0B : (INIT_MODE == "all_one") ? "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" : "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        defparam dp16k.INITVAL_0C          = (INIT_MODE == "mem_file") ? INITVAL_0C : (INIT_MODE == "all_one") ? "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" : "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        defparam dp16k.INITVAL_0D          = (INIT_MODE == "mem_file") ? INITVAL_0D : (INIT_MODE == "all_one") ? "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" : "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        defparam dp16k.INITVAL_0E          = (INIT_MODE == "mem_file") ? INITVAL_0E : (INIT_MODE == "all_one") ? "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" : "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        defparam dp16k.INITVAL_0F          = (INIT_MODE == "mem_file") ? INITVAL_0F : (INIT_MODE == "all_one") ? "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" : "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        defparam dp16k.INITVAL_10          = (INIT_MODE == "mem_file") ? INITVAL_10 : (INIT_MODE == "all_one") ? "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" : "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        defparam dp16k.INITVAL_11          = (INIT_MODE == "mem_file") ? INITVAL_11 : (INIT_MODE == "all_one") ? "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" : "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        defparam dp16k.INITVAL_12          = (INIT_MODE == "mem_file") ? INITVAL_12 : (INIT_MODE == "all_one") ? "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" : "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        defparam dp16k.INITVAL_13          = (INIT_MODE == "mem_file") ? INITVAL_13 : (INIT_MODE == "all_one") ? "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" : "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        defparam dp16k.INITVAL_14          = (INIT_MODE == "mem_file") ? INITVAL_14 : (INIT_MODE == "all_one") ? "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" : "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        defparam dp16k.INITVAL_15          = (INIT_MODE == "mem_file") ? INITVAL_15 : (INIT_MODE == "all_one") ? "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" : "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        defparam dp16k.INITVAL_16          = (INIT_MODE == "mem_file") ? INITVAL_16 : (INIT_MODE == "all_one") ? "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" : "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        defparam dp16k.INITVAL_17          = (INIT_MODE == "mem_file") ? INITVAL_17 : (INIT_MODE == "all_one") ? "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" : "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        defparam dp16k.INITVAL_18          = (INIT_MODE == "mem_file") ? INITVAL_18 : (INIT_MODE == "all_one") ? "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" : "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        defparam dp16k.INITVAL_19          = (INIT_MODE == "mem_file") ? INITVAL_19 : (INIT_MODE == "all_one") ? "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" : "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        defparam dp16k.INITVAL_1A          = (INIT_MODE == "mem_file") ? INITVAL_1A : (INIT_MODE == "all_one") ? "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" : "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        defparam dp16k.INITVAL_1B          = (INIT_MODE == "mem_file") ? INITVAL_1B : (INIT_MODE == "all_one") ? "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" : "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        defparam dp16k.INITVAL_1C          = (INIT_MODE == "mem_file") ? INITVAL_1C : (INIT_MODE == "all_one") ? "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" : "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        defparam dp16k.INITVAL_1D          = (INIT_MODE == "mem_file") ? INITVAL_1D : (INIT_MODE == "all_one") ? "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" : "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        defparam dp16k.INITVAL_1E          = (INIT_MODE == "mem_file") ? INITVAL_1E : (INIT_MODE == "all_one") ? "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" : "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        defparam dp16k.INITVAL_1F          = (INIT_MODE == "mem_file") ? INITVAL_1F : (INIT_MODE == "all_one") ? "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" : "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        defparam dp16k.INITVAL_20          = (INIT_MODE == "mem_file") ? INITVAL_20 : (INIT_MODE == "all_one") ? "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" : "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        defparam dp16k.INITVAL_21          = (INIT_MODE == "mem_file") ? INITVAL_21 : (INIT_MODE == "all_one") ? "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" : "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        defparam dp16k.INITVAL_22          = (INIT_MODE == "mem_file") ? INITVAL_22 : (INIT_MODE == "all_one") ? "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" : "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        defparam dp16k.INITVAL_23          = (INIT_MODE == "mem_file") ? INITVAL_23 : (INIT_MODE == "all_one") ? "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" : "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        defparam dp16k.INITVAL_24          = (INIT_MODE == "mem_file") ? INITVAL_24 : (INIT_MODE == "all_one") ? "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" : "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        defparam dp16k.INITVAL_25          = (INIT_MODE == "mem_file") ? INITVAL_25 : (INIT_MODE == "all_one") ? "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" : "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        defparam dp16k.INITVAL_26          = (INIT_MODE == "mem_file") ? INITVAL_26 : (INIT_MODE == "all_one") ? "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" : "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        defparam dp16k.INITVAL_27          = (INIT_MODE == "mem_file") ? INITVAL_27 : (INIT_MODE == "all_one") ? "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" : "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        defparam dp16k.INITVAL_28          = (INIT_MODE == "mem_file") ? INITVAL_28 : (INIT_MODE == "all_one") ? "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" : "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        defparam dp16k.INITVAL_29          = (INIT_MODE == "mem_file") ? INITVAL_29 : (INIT_MODE == "all_one") ? "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" : "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        defparam dp16k.INITVAL_2A          = (INIT_MODE == "mem_file") ? INITVAL_2A : (INIT_MODE == "all_one") ? "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" : "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        defparam dp16k.INITVAL_2B          = (INIT_MODE == "mem_file") ? INITVAL_2B : (INIT_MODE == "all_one") ? "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" : "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        defparam dp16k.INITVAL_2C          = (INIT_MODE == "mem_file") ? INITVAL_2C : (INIT_MODE == "all_one") ? "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" : "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        defparam dp16k.INITVAL_2D          = (INIT_MODE == "mem_file") ? INITVAL_2D : (INIT_MODE == "all_one") ? "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" : "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        defparam dp16k.INITVAL_2E          = (INIT_MODE == "mem_file") ? INITVAL_2E : (INIT_MODE == "all_one") ? "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" : "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        defparam dp16k.INITVAL_2F          = (INIT_MODE == "mem_file") ? INITVAL_2F : (INIT_MODE == "all_one") ? "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" : "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        defparam dp16k.INITVAL_30          = (INIT_MODE == "mem_file") ? INITVAL_30 : (INIT_MODE == "all_one") ? "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" : "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        defparam dp16k.INITVAL_31          = (INIT_MODE == "mem_file") ? INITVAL_31 : (INIT_MODE == "all_one") ? "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" : "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        defparam dp16k.INITVAL_32          = (INIT_MODE == "mem_file") ? INITVAL_32 : (INIT_MODE == "all_one") ? "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" : "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        defparam dp16k.INITVAL_33          = (INIT_MODE == "mem_file") ? INITVAL_33 : (INIT_MODE == "all_one") ? "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" : "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        defparam dp16k.INITVAL_34          = (INIT_MODE == "mem_file") ? INITVAL_34 : (INIT_MODE == "all_one") ? "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" : "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        defparam dp16k.INITVAL_35          = (INIT_MODE == "mem_file") ? INITVAL_35 : (INIT_MODE == "all_one") ? "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" : "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        defparam dp16k.INITVAL_36          = (INIT_MODE == "mem_file") ? INITVAL_36 : (INIT_MODE == "all_one") ? "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" : "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        defparam dp16k.INITVAL_37          = (INIT_MODE == "mem_file") ? INITVAL_37 : (INIT_MODE == "all_one") ? "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" : "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        defparam dp16k.INITVAL_38          = (INIT_MODE == "mem_file") ? INITVAL_38 : (INIT_MODE == "all_one") ? "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" : "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        defparam dp16k.INITVAL_39          = (INIT_MODE == "mem_file") ? INITVAL_39 : (INIT_MODE == "all_one") ? "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" : "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        defparam dp16k.INITVAL_3A          = (INIT_MODE == "mem_file") ? INITVAL_3A : (INIT_MODE == "all_one") ? "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" : "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        defparam dp16k.INITVAL_3B          = (INIT_MODE == "mem_file") ? INITVAL_3B : (INIT_MODE == "all_one") ? "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" : "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        defparam dp16k.INITVAL_3C          = (INIT_MODE == "mem_file") ? INITVAL_3C : (INIT_MODE == "all_one") ? "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" : "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        defparam dp16k.INITVAL_3D          = (INIT_MODE == "mem_file") ? INITVAL_3D : (INIT_MODE == "all_one") ? "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" : "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        defparam dp16k.INITVAL_3E          = (INIT_MODE == "mem_file") ? INITVAL_3E : (INIT_MODE == "all_one") ? "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" : "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        defparam dp16k.INITVAL_3F          = (INIT_MODE == "mem_file") ? INITVAL_3F : (INIT_MODE == "all_one") ? "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" : "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000"; 
    end
endgenerate

//------------------------------------------------------------------------------
// Function Definition
//------------------------------------------------------------------------------

function [31:0] calculateStringSize;
    input [31:0] x_calc;
    input [31:0] y_calc;
    reg [31:0] x_func;
    reg [31:0] y_func;
    begin
        if(x_calc >= 10000000) begin
            x_func = 8;
        end
        else if(x_calc >= 1000000) begin
            x_func = 7;
        end
        else if(x_calc >= 100000) begin
            x_func = 6;
        end
        else if(x_calc >= 10000) begin
            x_func = 5;
        end
        else if(x_calc >= 1000) begin
            x_func = 4;
        end
        else if(x_calc >= 100) begin
            x_func = 3;
        end
        else if(x_calc >= 10) begin
            x_func = 2;
        end
        else begin
            x_func = 1;
        end

        if(y_calc >= 10000000) begin
            y_func = 8;
        end
        else if(y_calc >= 1000000) begin
            y_func = 7;
        end
        else if(y_calc >= 100000) begin
            y_func = 6;
        end
        else if(y_calc >= 10000) begin
            y_func = 5;
        end
        else if(y_calc >= 1000) begin
            y_func = 4;
        end
        else if(y_calc >= 100) begin
            y_func = 3;
        end
        else if(y_calc >= 10) begin
            y_func = 2;
        end
        else begin
            y_func = 1;
        end

        calculateStringSize = (3 + x_func + y_func) * 8;
    end
endfunction

function [STRING_SIZE-1:0] getStringFromPos;
    input [31:0] x;
    input [31:0] y;
    begin
        if (y >= 10000000) begin
            if (x >= 10000000) begin
                getStringFromPos = {"[",NUM_STRING[POS_X7*8+7:POS_X7*8],NUM_STRING[POS_X6*8+7:POS_X6*8],NUM_STRING[POS_X5*8+7:POS_X5*8],NUM_STRING[POS_X4*8+7:POS_X4*8],NUM_STRING[POS_X3*8+7:POS_X3*8],NUM_STRING[POS_X2*8+7:POS_X2*8],NUM_STRING[POS_X1*8+7:POS_X1*8],NUM_STRING[POS_X0*8+7:POS_X0*8],",",
                                        NUM_STRING[POS_Y7*8+7:POS_Y7*8],NUM_STRING[POS_Y6*8+7:POS_Y6*8],NUM_STRING[POS_Y5*8+7:POS_Y5*8],NUM_STRING[POS_Y4*8+7:POS_Y4*8],NUM_STRING[POS_Y3*8+7:POS_Y3*8],NUM_STRING[POS_Y2*8+7:POS_Y2*8],NUM_STRING[POS_Y1*8+7:POS_Y1*8],NUM_STRING[POS_Y0*8+7:POS_Y0*8],"]"};
            end
            else if (x >= 1000000) begin
                getStringFromPos = {"[",NUM_STRING[POS_X6*8+7:POS_X6*8],NUM_STRING[POS_X5*8+7:POS_X5*8],NUM_STRING[POS_X4*8+7:POS_X4*8],NUM_STRING[POS_X3*8+7:POS_X3*8],NUM_STRING[POS_X2*8+7:POS_X2*8],NUM_STRING[POS_X1*8+7:POS_X1*8],NUM_STRING[POS_X0*8+7:POS_X0*8],",",
                                        NUM_STRING[POS_Y7*8+7:POS_Y7*8],NUM_STRING[POS_Y6*8+7:POS_Y6*8],NUM_STRING[POS_Y5*8+7:POS_Y5*8],NUM_STRING[POS_Y4*8+7:POS_Y4*8],NUM_STRING[POS_Y3*8+7:POS_Y3*8],NUM_STRING[POS_Y2*8+7:POS_Y2*8],NUM_STRING[POS_Y1*8+7:POS_Y1*8],NUM_STRING[POS_Y0*8+7:POS_Y0*8],"]"};
            end
            else if (x >= 100000) begin
                getStringFromPos = {"[",NUM_STRING[POS_X5*8+7:POS_X5*8],NUM_STRING[POS_X4*8+7:POS_X4*8],NUM_STRING[POS_X3*8+7:POS_X3*8],NUM_STRING[POS_X2*8+7:POS_X2*8],NUM_STRING[POS_X1*8+7:POS_X1*8],NUM_STRING[POS_X0*8+7:POS_X0*8],",",
                                        NUM_STRING[POS_Y7*8+7:POS_Y7*8],NUM_STRING[POS_Y6*8+7:POS_Y6*8],NUM_STRING[POS_Y5*8+7:POS_Y5*8],NUM_STRING[POS_Y4*8+7:POS_Y4*8],NUM_STRING[POS_Y3*8+7:POS_Y3*8],NUM_STRING[POS_Y2*8+7:POS_Y2*8],NUM_STRING[POS_Y1*8+7:POS_Y1*8],NUM_STRING[POS_Y0*8+7:POS_Y0*8],"]"};
            end
            else if (x >= 10000) begin 
                getStringFromPos = {"[",NUM_STRING[POS_X4*8+7:POS_X4*8],NUM_STRING[POS_X3*8+7:POS_X3*8],NUM_STRING[POS_X2*8+7:POS_X2*8],NUM_STRING[POS_X1*8+7:POS_X1*8],NUM_STRING[POS_X0*8+7:POS_X0*8],",",
                                        NUM_STRING[POS_Y7*8+7:POS_Y7*8],NUM_STRING[POS_Y6*8+7:POS_Y6*8],NUM_STRING[POS_Y5*8+7:POS_Y5*8],NUM_STRING[POS_Y4*8+7:POS_Y4*8],NUM_STRING[POS_Y3*8+7:POS_Y3*8],NUM_STRING[POS_Y2*8+7:POS_Y2*8],NUM_STRING[POS_Y1*8+7:POS_Y1*8],NUM_STRING[POS_Y0*8+7:POS_Y0*8],"]"};
            end
            else if (x >= 1000) begin
                getStringFromPos = {"[",NUM_STRING[POS_X3*8+7:POS_X3*8],NUM_STRING[POS_X2*8+7:POS_X2*8],NUM_STRING[POS_X1*8+7:POS_X1*8],NUM_STRING[POS_X0*8+7:POS_X0*8],",",
                                        NUM_STRING[POS_Y7*8+7:POS_Y7*8],NUM_STRING[POS_Y6*8+7:POS_Y6*8],NUM_STRING[POS_Y5*8+7:POS_Y5*8],NUM_STRING[POS_Y4*8+7:POS_Y4*8],NUM_STRING[POS_Y3*8+7:POS_Y3*8],NUM_STRING[POS_Y2*8+7:POS_Y2*8],NUM_STRING[POS_Y1*8+7:POS_Y1*8],NUM_STRING[POS_Y0*8+7:POS_Y0*8],"]"};
            end
            else if (x >= 100) begin
                getStringFromPos = {"[",NUM_STRING[POS_X2*8+7:POS_X2*8],NUM_STRING[POS_X1*8+7:POS_X1*8],NUM_STRING[POS_X0*8+7:POS_X0*8],",",
                                        NUM_STRING[POS_Y7*8+7:POS_Y7*8],NUM_STRING[POS_Y6*8+7:POS_Y6*8],NUM_STRING[POS_Y5*8+7:POS_Y5*8],NUM_STRING[POS_Y4*8+7:POS_Y4*8],NUM_STRING[POS_Y3*8+7:POS_Y3*8],NUM_STRING[POS_Y2*8+7:POS_Y2*8],NUM_STRING[POS_Y1*8+7:POS_Y1*8],NUM_STRING[POS_Y0*8+7:POS_Y0*8],"]"};
            end
            else if (x >= 10) begin
                getStringFromPos = {"[",NUM_STRING[POS_X1*8+7:POS_X1*8],NUM_STRING[POS_X0*8+7:POS_X0*8],",",
                                        NUM_STRING[POS_Y7*8+7:POS_Y7*8],NUM_STRING[POS_Y6*8+7:POS_Y6*8],NUM_STRING[POS_Y5*8+7:POS_Y5*8],NUM_STRING[POS_Y4*8+7:POS_Y4*8],NUM_STRING[POS_Y3*8+7:POS_Y3*8],NUM_STRING[POS_Y2*8+7:POS_Y2*8],NUM_STRING[POS_Y1*8+7:POS_Y1*8],NUM_STRING[POS_Y0*8+7:POS_Y0*8],"]"};
            end
            else begin
                getStringFromPos = {"[",NUM_STRING[POS_X0*8+7:POS_X0*8],",",
                                        NUM_STRING[POS_Y7*8+7:POS_Y7*8],NUM_STRING[POS_Y6*8+7:POS_Y6*8],NUM_STRING[POS_Y5*8+7:POS_Y5*8],NUM_STRING[POS_Y4*8+7:POS_Y4*8],NUM_STRING[POS_Y3*8+7:POS_Y3*8],NUM_STRING[POS_Y2*8+7:POS_Y2*8],NUM_STRING[POS_Y1*8+7:POS_Y1*8],NUM_STRING[POS_Y0*8+7:POS_Y0*8],"]"};
            end
        end
        else if (y >= 1000000) begin
            if (x >= 10000000) begin
                getStringFromPos = {"[",NUM_STRING[POS_X7*8+7:POS_X7*8],NUM_STRING[POS_X6*8+7:POS_X6*8],NUM_STRING[POS_X5*8+7:POS_X5*8],NUM_STRING[POS_X4*8+7:POS_X4*8],NUM_STRING[POS_X3*8+7:POS_X3*8],NUM_STRING[POS_X2*8+7:POS_X2*8],NUM_STRING[POS_X1*8+7:POS_X1*8],NUM_STRING[POS_X0*8+7:POS_X0*8],",",
                                        NUM_STRING[POS_Y6*8+7:POS_Y6*8],NUM_STRING[POS_Y5*8+7:POS_Y5*8],NUM_STRING[POS_Y4*8+7:POS_Y4*8],NUM_STRING[POS_Y3*8+7:POS_Y3*8],NUM_STRING[POS_Y2*8+7:POS_Y2*8],NUM_STRING[POS_Y1*8+7:POS_Y1*8],NUM_STRING[POS_Y0*8+7:POS_Y0*8],"]"};
            end
            else if (x >= 1000000) begin
                getStringFromPos = {"[",NUM_STRING[POS_X6*8+7:POS_X6*8],NUM_STRING[POS_X5*8+7:POS_X5*8],NUM_STRING[POS_X4*8+7:POS_X4*8],NUM_STRING[POS_X3*8+7:POS_X3*8],NUM_STRING[POS_X2*8+7:POS_X2*8],NUM_STRING[POS_X1*8+7:POS_X1*8],NUM_STRING[POS_X0*8+7:POS_X0*8],",",
                                        NUM_STRING[POS_Y6*8+7:POS_Y6*8],NUM_STRING[POS_Y5*8+7:POS_Y5*8],NUM_STRING[POS_Y4*8+7:POS_Y4*8],NUM_STRING[POS_Y3*8+7:POS_Y3*8],NUM_STRING[POS_Y2*8+7:POS_Y2*8],NUM_STRING[POS_Y1*8+7:POS_Y1*8],NUM_STRING[POS_Y0*8+7:POS_Y0*8],"]"};
            end
            else if (x >= 100000) begin
                getStringFromPos = {"[",NUM_STRING[POS_X5*8+7:POS_X5*8],NUM_STRING[POS_X4*8+7:POS_X4*8],NUM_STRING[POS_X3*8+7:POS_X3*8],NUM_STRING[POS_X2*8+7:POS_X2*8],NUM_STRING[POS_X1*8+7:POS_X1*8],NUM_STRING[POS_X0*8+7:POS_X0*8],",",
                                        NUM_STRING[POS_Y6*8+7:POS_Y6*8],NUM_STRING[POS_Y5*8+7:POS_Y5*8],NUM_STRING[POS_Y4*8+7:POS_Y4*8],NUM_STRING[POS_Y3*8+7:POS_Y3*8],NUM_STRING[POS_Y2*8+7:POS_Y2*8],NUM_STRING[POS_Y1*8+7:POS_Y1*8],NUM_STRING[POS_Y0*8+7:POS_Y0*8],"]"};
            end
            else if (x >= 10000) begin 
                getStringFromPos = {"[",NUM_STRING[POS_X4*8+7:POS_X4*8],NUM_STRING[POS_X3*8+7:POS_X3*8],NUM_STRING[POS_X2*8+7:POS_X2*8],NUM_STRING[POS_X1*8+7:POS_X1*8],NUM_STRING[POS_X0*8+7:POS_X0*8],",",
                                        NUM_STRING[POS_Y6*8+7:POS_Y6*8],NUM_STRING[POS_Y5*8+7:POS_Y5*8],NUM_STRING[POS_Y4*8+7:POS_Y4*8],NUM_STRING[POS_Y3*8+7:POS_Y3*8],NUM_STRING[POS_Y2*8+7:POS_Y2*8],NUM_STRING[POS_Y1*8+7:POS_Y1*8],NUM_STRING[POS_Y0*8+7:POS_Y0*8],"]"};
            end
            else if (x >= 1000) begin
                getStringFromPos = {"[",NUM_STRING[POS_X3*8+7:POS_X3*8],NUM_STRING[POS_X2*8+7:POS_X2*8],NUM_STRING[POS_X1*8+7:POS_X1*8],NUM_STRING[POS_X0*8+7:POS_X0*8],",",
                                        NUM_STRING[POS_Y6*8+7:POS_Y6*8],NUM_STRING[POS_Y5*8+7:POS_Y5*8],NUM_STRING[POS_Y4*8+7:POS_Y4*8],NUM_STRING[POS_Y3*8+7:POS_Y3*8],NUM_STRING[POS_Y2*8+7:POS_Y2*8],NUM_STRING[POS_Y1*8+7:POS_Y1*8],NUM_STRING[POS_Y0*8+7:POS_Y0*8],"]"};
            end
            else if (x >= 100) begin
                getStringFromPos = {"[",NUM_STRING[POS_X2*8+7:POS_X2*8],NUM_STRING[POS_X1*8+7:POS_X1*8],NUM_STRING[POS_X0*8+7:POS_X0*8],",",
                                        NUM_STRING[POS_Y6*8+7:POS_Y6*8],NUM_STRING[POS_Y5*8+7:POS_Y5*8],NUM_STRING[POS_Y4*8+7:POS_Y4*8],NUM_STRING[POS_Y3*8+7:POS_Y3*8],NUM_STRING[POS_Y2*8+7:POS_Y2*8],NUM_STRING[POS_Y1*8+7:POS_Y1*8],NUM_STRING[POS_Y0*8+7:POS_Y0*8],"]"};
            end
            else if (x >= 10) begin
                getStringFromPos = {"[",NUM_STRING[POS_X1*8+7:POS_X1*8],NUM_STRING[POS_X0*8+7:POS_X0*8],",",
                                        NUM_STRING[POS_Y6*8+7:POS_Y6*8],NUM_STRING[POS_Y5*8+7:POS_Y5*8],NUM_STRING[POS_Y4*8+7:POS_Y4*8],NUM_STRING[POS_Y3*8+7:POS_Y3*8],NUM_STRING[POS_Y2*8+7:POS_Y2*8],NUM_STRING[POS_Y1*8+7:POS_Y1*8],NUM_STRING[POS_Y0*8+7:POS_Y0*8],"]"};
            end
            else begin
                getStringFromPos = {"[",NUM_STRING[POS_X0*8+7:POS_X0*8],",",
                                        NUM_STRING[POS_Y6*8+7:POS_Y6*8],NUM_STRING[POS_Y5*8+7:POS_Y5*8],NUM_STRING[POS_Y4*8+7:POS_Y4*8],NUM_STRING[POS_Y3*8+7:POS_Y3*8],NUM_STRING[POS_Y2*8+7:POS_Y2*8],NUM_STRING[POS_Y1*8+7:POS_Y1*8],NUM_STRING[POS_Y0*8+7:POS_Y0*8],"]"};
            end
        end
        else if (y >= 100000) begin
            if (x >= 10000000) begin
                getStringFromPos = {"[",NUM_STRING[POS_X7*8+7:POS_X7*8],NUM_STRING[POS_X6*8+7:POS_X6*8],NUM_STRING[POS_X5*8+7:POS_X5*8],NUM_STRING[POS_X4*8+7:POS_X4*8],NUM_STRING[POS_X3*8+7:POS_X3*8],NUM_STRING[POS_X2*8+7:POS_X2*8],NUM_STRING[POS_X1*8+7:POS_X1*8],NUM_STRING[POS_X0*8+7:POS_X0*8],",",
                                        NUM_STRING[POS_Y5*8+7:POS_Y5*8],NUM_STRING[POS_Y4*8+7:POS_Y4*8],NUM_STRING[POS_Y3*8+7:POS_Y3*8],NUM_STRING[POS_Y2*8+7:POS_Y2*8],NUM_STRING[POS_Y1*8+7:POS_Y1*8],NUM_STRING[POS_Y0*8+7:POS_Y0*8],"]"};
            end
            else if (x >= 1000000) begin
                getStringFromPos = {"[",NUM_STRING[POS_X6*8+7:POS_X6*8],NUM_STRING[POS_X5*8+7:POS_X5*8],NUM_STRING[POS_X4*8+7:POS_X4*8],NUM_STRING[POS_X3*8+7:POS_X3*8],NUM_STRING[POS_X2*8+7:POS_X2*8],NUM_STRING[POS_X1*8+7:POS_X1*8],NUM_STRING[POS_X0*8+7:POS_X0*8],",",
                                        NUM_STRING[POS_Y5*8+7:POS_Y5*8],NUM_STRING[POS_Y4*8+7:POS_Y4*8],NUM_STRING[POS_Y3*8+7:POS_Y3*8],NUM_STRING[POS_Y2*8+7:POS_Y2*8],NUM_STRING[POS_Y1*8+7:POS_Y1*8],NUM_STRING[POS_Y0*8+7:POS_Y0*8],"]"};
            end
            else if (x >= 100000) begin
                getStringFromPos = {"[",NUM_STRING[POS_X5*8+7:POS_X5*8],NUM_STRING[POS_X4*8+7:POS_X4*8],NUM_STRING[POS_X3*8+7:POS_X3*8],NUM_STRING[POS_X2*8+7:POS_X2*8],NUM_STRING[POS_X1*8+7:POS_X1*8],NUM_STRING[POS_X0*8+7:POS_X0*8],",",
                                        NUM_STRING[POS_Y5*8+7:POS_Y5*8],NUM_STRING[POS_Y4*8+7:POS_Y4*8],NUM_STRING[POS_Y3*8+7:POS_Y3*8],NUM_STRING[POS_Y2*8+7:POS_Y2*8],NUM_STRING[POS_Y1*8+7:POS_Y1*8],NUM_STRING[POS_Y0*8+7:POS_Y0*8],"]"};
            end
            else if (x >= 10000) begin 
                getStringFromPos = {"[",NUM_STRING[POS_X4*8+7:POS_X4*8],NUM_STRING[POS_X3*8+7:POS_X3*8],NUM_STRING[POS_X2*8+7:POS_X2*8],NUM_STRING[POS_X1*8+7:POS_X1*8],NUM_STRING[POS_X0*8+7:POS_X0*8],",",
                                        NUM_STRING[POS_Y5*8+7:POS_Y5*8],NUM_STRING[POS_Y4*8+7:POS_Y4*8],NUM_STRING[POS_Y3*8+7:POS_Y3*8],NUM_STRING[POS_Y2*8+7:POS_Y2*8],NUM_STRING[POS_Y1*8+7:POS_Y1*8],NUM_STRING[POS_Y0*8+7:POS_Y0*8],"]"};
            end
            else if (x >= 1000) begin
                getStringFromPos = {"[",NUM_STRING[POS_X3*8+7:POS_X3*8],NUM_STRING[POS_X2*8+7:POS_X2*8],NUM_STRING[POS_X1*8+7:POS_X1*8],NUM_STRING[POS_X0*8+7:POS_X0*8],",",
                                        NUM_STRING[POS_Y5*8+7:POS_Y5*8],NUM_STRING[POS_Y4*8+7:POS_Y4*8],NUM_STRING[POS_Y3*8+7:POS_Y3*8],NUM_STRING[POS_Y2*8+7:POS_Y2*8],NUM_STRING[POS_Y1*8+7:POS_Y1*8],NUM_STRING[POS_Y0*8+7:POS_Y0*8],"]"};
            end
            else if (x >= 100) begin
                getStringFromPos = {"[",NUM_STRING[POS_X2*8+7:POS_X2*8],NUM_STRING[POS_X1*8+7:POS_X1*8],NUM_STRING[POS_X0*8+7:POS_X0*8],",",
                                        NUM_STRING[POS_Y5*8+7:POS_Y5*8],NUM_STRING[POS_Y4*8+7:POS_Y4*8],NUM_STRING[POS_Y3*8+7:POS_Y3*8],NUM_STRING[POS_Y2*8+7:POS_Y2*8],NUM_STRING[POS_Y1*8+7:POS_Y1*8],NUM_STRING[POS_Y0*8+7:POS_Y0*8],"]"};
            end
            else if (x >= 10) begin
                getStringFromPos = {"[",NUM_STRING[POS_X1*8+7:POS_X1*8],NUM_STRING[POS_X0*8+7:POS_X0*8],",",
                                        NUM_STRING[POS_Y5*8+7:POS_Y5*8],NUM_STRING[POS_Y4*8+7:POS_Y4*8],NUM_STRING[POS_Y3*8+7:POS_Y3*8],NUM_STRING[POS_Y2*8+7:POS_Y2*8],NUM_STRING[POS_Y1*8+7:POS_Y1*8],NUM_STRING[POS_Y0*8+7:POS_Y0*8],"]"};
            end
            else begin
                getStringFromPos = {"[",NUM_STRING[POS_X0*8+7:POS_X0*8],",",
                                        NUM_STRING[POS_Y5*8+7:POS_Y5*8],NUM_STRING[POS_Y4*8+7:POS_Y4*8],NUM_STRING[POS_Y3*8+7:POS_Y3*8],NUM_STRING[POS_Y2*8+7:POS_Y2*8],NUM_STRING[POS_Y1*8+7:POS_Y1*8],NUM_STRING[POS_Y0*8+7:POS_Y0*8],"]"};
            end
        end
        else if (y >= 10000) begin
            if (x >= 10000000) begin
                getStringFromPos = {"[",NUM_STRING[POS_X7*8+7:POS_X7*8],NUM_STRING[POS_X6*8+7:POS_X6*8],NUM_STRING[POS_X5*8+7:POS_X5*8],NUM_STRING[POS_X4*8+7:POS_X4*8],NUM_STRING[POS_X3*8+7:POS_X3*8],NUM_STRING[POS_X2*8+7:POS_X2*8],NUM_STRING[POS_X1*8+7:POS_X1*8],NUM_STRING[POS_X0*8+7:POS_X0*8],",",
                                        NUM_STRING[POS_Y4*8+7:POS_Y4*8],NUM_STRING[POS_Y3*8+7:POS_Y3*8],NUM_STRING[POS_Y2*8+7:POS_Y2*8],NUM_STRING[POS_Y1*8+7:POS_Y1*8],NUM_STRING[POS_Y0*8+7:POS_Y0*8],"]"};
            end
            else if (x >= 1000000) begin
                getStringFromPos = {"[",NUM_STRING[POS_X6*8+7:POS_X6*8],NUM_STRING[POS_X5*8+7:POS_X5*8],NUM_STRING[POS_X4*8+7:POS_X4*8],NUM_STRING[POS_X3*8+7:POS_X3*8],NUM_STRING[POS_X2*8+7:POS_X2*8],NUM_STRING[POS_X1*8+7:POS_X1*8],NUM_STRING[POS_X0*8+7:POS_X0*8],",",
                                        NUM_STRING[POS_Y4*8+7:POS_Y4*8],NUM_STRING[POS_Y3*8+7:POS_Y3*8],NUM_STRING[POS_Y2*8+7:POS_Y2*8],NUM_STRING[POS_Y1*8+7:POS_Y1*8],NUM_STRING[POS_Y0*8+7:POS_Y0*8],"]"};
            end
            else if (x >= 100000) begin
                getStringFromPos = {"[",NUM_STRING[POS_X5*8+7:POS_X5*8],NUM_STRING[POS_X4*8+7:POS_X4*8],NUM_STRING[POS_X3*8+7:POS_X3*8],NUM_STRING[POS_X2*8+7:POS_X2*8],NUM_STRING[POS_X1*8+7:POS_X1*8],NUM_STRING[POS_X0*8+7:POS_X0*8],",",
                                        NUM_STRING[POS_Y4*8+7:POS_Y4*8],NUM_STRING[POS_Y3*8+7:POS_Y3*8],NUM_STRING[POS_Y2*8+7:POS_Y2*8],NUM_STRING[POS_Y1*8+7:POS_Y1*8],NUM_STRING[POS_Y0*8+7:POS_Y0*8],"]"};
            end
            else if (x >= 10000) begin 
                getStringFromPos = {"[",NUM_STRING[POS_X4*8+7:POS_X4*8],NUM_STRING[POS_X3*8+7:POS_X3*8],NUM_STRING[POS_X2*8+7:POS_X2*8],NUM_STRING[POS_X1*8+7:POS_X1*8],NUM_STRING[POS_X0*8+7:POS_X0*8],",",
                                        NUM_STRING[POS_Y4*8+7:POS_Y4*8],NUM_STRING[POS_Y3*8+7:POS_Y3*8],NUM_STRING[POS_Y2*8+7:POS_Y2*8],NUM_STRING[POS_Y1*8+7:POS_Y1*8],NUM_STRING[POS_Y0*8+7:POS_Y0*8],"]"};
            end
            else if (x >= 1000) begin
                getStringFromPos = {"[",NUM_STRING[POS_X3*8+7:POS_X3*8],NUM_STRING[POS_X2*8+7:POS_X2*8],NUM_STRING[POS_X1*8+7:POS_X1*8],NUM_STRING[POS_X0*8+7:POS_X0*8],",",
                                        NUM_STRING[POS_Y4*8+7:POS_Y4*8],NUM_STRING[POS_Y3*8+7:POS_Y3*8],NUM_STRING[POS_Y2*8+7:POS_Y2*8],NUM_STRING[POS_Y1*8+7:POS_Y1*8],NUM_STRING[POS_Y0*8+7:POS_Y0*8],"]"};
            end
            else if (x >= 100) begin
                getStringFromPos = {"[",NUM_STRING[POS_X2*8+7:POS_X2*8],NUM_STRING[POS_X1*8+7:POS_X1*8],NUM_STRING[POS_X0*8+7:POS_X0*8],",",
                                        NUM_STRING[POS_Y4*8+7:POS_Y4*8],NUM_STRING[POS_Y3*8+7:POS_Y3*8],NUM_STRING[POS_Y2*8+7:POS_Y2*8],NUM_STRING[POS_Y1*8+7:POS_Y1*8],NUM_STRING[POS_Y0*8+7:POS_Y0*8],"]"};
            end
            else if (x >= 10) begin
                getStringFromPos = {"[",NUM_STRING[POS_X1*8+7:POS_X1*8],NUM_STRING[POS_X0*8+7:POS_X0*8],",",
                                        NUM_STRING[POS_Y4*8+7:POS_Y4*8],NUM_STRING[POS_Y3*8+7:POS_Y3*8],NUM_STRING[POS_Y2*8+7:POS_Y2*8],NUM_STRING[POS_Y1*8+7:POS_Y1*8],NUM_STRING[POS_Y0*8+7:POS_Y0*8],"]"};
            end
            else begin
                getStringFromPos = {"[",NUM_STRING[POS_X0*8+7:POS_X0*8],",",
                                        NUM_STRING[POS_Y4*8+7:POS_Y4*8],NUM_STRING[POS_Y3*8+7:POS_Y3*8],NUM_STRING[POS_Y2*8+7:POS_Y2*8],NUM_STRING[POS_Y1*8+7:POS_Y1*8],NUM_STRING[POS_Y0*8+7:POS_Y0*8],"]"};
            end
        end
        else if (y >= 1000) begin
            if (x >= 10000000) begin
                getStringFromPos = {"[",NUM_STRING[POS_X7*8+7:POS_X7*8],NUM_STRING[POS_X6*8+7:POS_X6*8],NUM_STRING[POS_X5*8+7:POS_X5*8],NUM_STRING[POS_X4*8+7:POS_X4*8],NUM_STRING[POS_X3*8+7:POS_X3*8],NUM_STRING[POS_X2*8+7:POS_X2*8],NUM_STRING[POS_X1*8+7:POS_X1*8],NUM_STRING[POS_X0*8+7:POS_X0*8],",",
                                        NUM_STRING[POS_Y3*8+7:POS_Y3*8],NUM_STRING[POS_Y2*8+7:POS_Y2*8],NUM_STRING[POS_Y1*8+7:POS_Y1*8],NUM_STRING[POS_Y0*8+7:POS_Y0*8],"]"};
            end
            else if (x >= 1000000) begin
                getStringFromPos = {"[",NUM_STRING[POS_X6*8+7:POS_X6*8],NUM_STRING[POS_X5*8+7:POS_X5*8],NUM_STRING[POS_X4*8+7:POS_X4*8],NUM_STRING[POS_X3*8+7:POS_X3*8],NUM_STRING[POS_X2*8+7:POS_X2*8],NUM_STRING[POS_X1*8+7:POS_X1*8],NUM_STRING[POS_X0*8+7:POS_X0*8],",",
                                        NUM_STRING[POS_Y3*8+7:POS_Y3*8],NUM_STRING[POS_Y2*8+7:POS_Y2*8],NUM_STRING[POS_Y1*8+7:POS_Y1*8],NUM_STRING[POS_Y0*8+7:POS_Y0*8],"]"};
            end
            else if (x >= 100000) begin
                getStringFromPos = {"[",NUM_STRING[POS_X5*8+7:POS_X5*8],NUM_STRING[POS_X4*8+7:POS_X4*8],NUM_STRING[POS_X3*8+7:POS_X3*8],NUM_STRING[POS_X2*8+7:POS_X2*8],NUM_STRING[POS_X1*8+7:POS_X1*8],NUM_STRING[POS_X0*8+7:POS_X0*8],",",
                                        NUM_STRING[POS_Y3*8+7:POS_Y3*8],NUM_STRING[POS_Y2*8+7:POS_Y2*8],NUM_STRING[POS_Y1*8+7:POS_Y1*8],NUM_STRING[POS_Y0*8+7:POS_Y0*8],"]"};
            end
            else if (x >= 10000) begin 
                getStringFromPos = {"[",NUM_STRING[POS_X4*8+7:POS_X4*8],NUM_STRING[POS_X3*8+7:POS_X3*8],NUM_STRING[POS_X2*8+7:POS_X2*8],NUM_STRING[POS_X1*8+7:POS_X1*8],NUM_STRING[POS_X0*8+7:POS_X0*8],",",
                                        NUM_STRING[POS_Y3*8+7:POS_Y3*8],NUM_STRING[POS_Y2*8+7:POS_Y2*8],NUM_STRING[POS_Y1*8+7:POS_Y1*8],NUM_STRING[POS_Y0*8+7:POS_Y0*8],"]"};
            end
            else if (x >= 1000) begin
                getStringFromPos = {"[",NUM_STRING[POS_X3*8+7:POS_X3*8],NUM_STRING[POS_X2*8+7:POS_X2*8],NUM_STRING[POS_X1*8+7:POS_X1*8],NUM_STRING[POS_X0*8+7:POS_X0*8],",",
                                        NUM_STRING[POS_Y3*8+7:POS_Y3*8],NUM_STRING[POS_Y2*8+7:POS_Y2*8],NUM_STRING[POS_Y1*8+7:POS_Y1*8],NUM_STRING[POS_Y0*8+7:POS_Y0*8],"]"};
            end
            else if (x >= 100) begin
                getStringFromPos = {"[",NUM_STRING[POS_X2*8+7:POS_X2*8],NUM_STRING[POS_X1*8+7:POS_X1*8],NUM_STRING[POS_X0*8+7:POS_X0*8],",",
                                        NUM_STRING[POS_Y3*8+7:POS_Y3*8],NUM_STRING[POS_Y2*8+7:POS_Y2*8],NUM_STRING[POS_Y1*8+7:POS_Y1*8],NUM_STRING[POS_Y0*8+7:POS_Y0*8],"]"};
            end
            else if (x >= 10) begin
                getStringFromPos = {"[",NUM_STRING[POS_X1*8+7:POS_X1*8],NUM_STRING[POS_X0*8+7:POS_X0*8],",",
                                        NUM_STRING[POS_Y3*8+7:POS_Y3*8],NUM_STRING[POS_Y2*8+7:POS_Y2*8],NUM_STRING[POS_Y1*8+7:POS_Y1*8],NUM_STRING[POS_Y0*8+7:POS_Y0*8],"]"};
            end
            else begin
                getStringFromPos = {"[",NUM_STRING[POS_X0*8+7:POS_X0*8],",",
                                        NUM_STRING[POS_Y3*8+7:POS_Y3*8],NUM_STRING[POS_Y2*8+7:POS_Y2*8],NUM_STRING[POS_Y1*8+7:POS_Y1*8],NUM_STRING[POS_Y0*8+7:POS_Y0*8],"]"};
            end
        end
        else if (y >= 100) begin
            if (x >= 10000000) begin
                getStringFromPos = {"[",NUM_STRING[POS_X7*8+7:POS_X7*8],NUM_STRING[POS_X6*8+7:POS_X6*8],NUM_STRING[POS_X5*8+7:POS_X5*8],NUM_STRING[POS_X4*8+7:POS_X4*8],NUM_STRING[POS_X3*8+7:POS_X3*8],NUM_STRING[POS_X2*8+7:POS_X2*8],NUM_STRING[POS_X1*8+7:POS_X1*8],NUM_STRING[POS_X0*8+7:POS_X0*8],",",
                                        NUM_STRING[POS_Y2*8+7:POS_Y2*8],NUM_STRING[POS_Y1*8+7:POS_Y1*8],NUM_STRING[POS_Y0*8+7:POS_Y0*8],"]"};
            end
            else if (x >= 1000000) begin
                getStringFromPos = {"[",NUM_STRING[POS_X6*8+7:POS_X6*8],NUM_STRING[POS_X5*8+7:POS_X5*8],NUM_STRING[POS_X4*8+7:POS_X4*8],NUM_STRING[POS_X3*8+7:POS_X3*8],NUM_STRING[POS_X2*8+7:POS_X2*8],NUM_STRING[POS_X1*8+7:POS_X1*8],NUM_STRING[POS_X0*8+7:POS_X0*8],",",
                                        NUM_STRING[POS_Y2*8+7:POS_Y2*8],NUM_STRING[POS_Y1*8+7:POS_Y1*8],NUM_STRING[POS_Y0*8+7:POS_Y0*8],"]"};
            end
            else if (x >= 100000) begin
                getStringFromPos = {"[",NUM_STRING[POS_X5*8+7:POS_X5*8],NUM_STRING[POS_X4*8+7:POS_X4*8],NUM_STRING[POS_X3*8+7:POS_X3*8],NUM_STRING[POS_X2*8+7:POS_X2*8],NUM_STRING[POS_X1*8+7:POS_X1*8],NUM_STRING[POS_X0*8+7:POS_X0*8],",",
                                        NUM_STRING[POS_Y2*8+7:POS_Y2*8],NUM_STRING[POS_Y1*8+7:POS_Y1*8],NUM_STRING[POS_Y0*8+7:POS_Y0*8],"]"};
            end
            else if (x >= 10000) begin 
                getStringFromPos = {"[",NUM_STRING[POS_X4*8+7:POS_X4*8],NUM_STRING[POS_X3*8+7:POS_X3*8],NUM_STRING[POS_X2*8+7:POS_X2*8],NUM_STRING[POS_X1*8+7:POS_X1*8],NUM_STRING[POS_X0*8+7:POS_X0*8],",",
                                        NUM_STRING[POS_Y2*8+7:POS_Y2*8],NUM_STRING[POS_Y1*8+7:POS_Y1*8],NUM_STRING[POS_Y0*8+7:POS_Y0*8],"]"};
            end
            else if (x >= 1000) begin
                getStringFromPos = {"[",NUM_STRING[POS_X3*8+7:POS_X3*8],NUM_STRING[POS_X2*8+7:POS_X2*8],NUM_STRING[POS_X1*8+7:POS_X1*8],NUM_STRING[POS_X0*8+7:POS_X0*8],",",
                                        NUM_STRING[POS_Y2*8+7:POS_Y2*8],NUM_STRING[POS_Y1*8+7:POS_Y1*8],NUM_STRING[POS_Y0*8+7:POS_Y0*8],"]"};
            end
            else if (x >= 100) begin
                getStringFromPos = {"[",NUM_STRING[POS_X2*8+7:POS_X2*8],NUM_STRING[POS_X1*8+7:POS_X1*8],NUM_STRING[POS_X0*8+7:POS_X0*8],",",
                                        NUM_STRING[POS_Y2*8+7:POS_Y2*8],NUM_STRING[POS_Y1*8+7:POS_Y1*8],NUM_STRING[POS_Y0*8+7:POS_Y0*8],"]"};
            end
            else if (x >= 10) begin
                getStringFromPos = {"[",NUM_STRING[POS_X1*8+7:POS_X1*8],NUM_STRING[POS_X0*8+7:POS_X0*8],",",
                                        NUM_STRING[POS_Y2*8+7:POS_Y2*8],NUM_STRING[POS_Y1*8+7:POS_Y1*8],NUM_STRING[POS_Y0*8+7:POS_Y0*8],"]"};
            end
            else begin
                getStringFromPos = {"[",NUM_STRING[POS_X0*8+7:POS_X0*8],",",
                                        NUM_STRING[POS_Y2*8+7:POS_Y2*8],NUM_STRING[POS_Y1*8+7:POS_Y1*8],NUM_STRING[POS_Y0*8+7:POS_Y0*8],"]"};
            end
        end
        else if (y >= 10) begin
            if (x >= 10000000) begin
                getStringFromPos = {"[",NUM_STRING[POS_X7*8+7:POS_X7*8],NUM_STRING[POS_X6*8+7:POS_X6*8],NUM_STRING[POS_X5*8+7:POS_X5*8],NUM_STRING[POS_X4*8+7:POS_X4*8],NUM_STRING[POS_X3*8+7:POS_X3*8],NUM_STRING[POS_X2*8+7:POS_X2*8],NUM_STRING[POS_X1*8+7:POS_X1*8],NUM_STRING[POS_X0*8+7:POS_X0*8],",",
                                        NUM_STRING[POS_Y1*8+7:POS_Y1*8],NUM_STRING[POS_Y0*8+7:POS_Y0*8],"]"};
            end
            else if (x >= 1000000) begin
                getStringFromPos = {"[",NUM_STRING[POS_X6*8+7:POS_X6*8],NUM_STRING[POS_X5*8+7:POS_X5*8],NUM_STRING[POS_X4*8+7:POS_X4*8],NUM_STRING[POS_X3*8+7:POS_X3*8],NUM_STRING[POS_X2*8+7:POS_X2*8],NUM_STRING[POS_X1*8+7:POS_X1*8],NUM_STRING[POS_X0*8+7:POS_X0*8],",",
                                        NUM_STRING[POS_Y1*8+7:POS_Y1*8],NUM_STRING[POS_Y0*8+7:POS_Y0*8],"]"};
            end
            else if (x >= 100000) begin
                getStringFromPos = {"[",NUM_STRING[POS_X5*8+7:POS_X5*8],NUM_STRING[POS_X4*8+7:POS_X4*8],NUM_STRING[POS_X3*8+7:POS_X3*8],NUM_STRING[POS_X2*8+7:POS_X2*8],NUM_STRING[POS_X1*8+7:POS_X1*8],NUM_STRING[POS_X0*8+7:POS_X0*8],",",
                                        NUM_STRING[POS_Y1*8+7:POS_Y1*8],NUM_STRING[POS_Y0*8+7:POS_Y0*8],"]"};
            end
            else if (x >= 10000) begin 
                getStringFromPos = {"[",NUM_STRING[POS_X4*8+7:POS_X4*8],NUM_STRING[POS_X3*8+7:POS_X3*8],NUM_STRING[POS_X2*8+7:POS_X2*8],NUM_STRING[POS_X1*8+7:POS_X1*8],NUM_STRING[POS_X0*8+7:POS_X0*8],",",
                                        NUM_STRING[POS_Y1*8+7:POS_Y1*8],NUM_STRING[POS_Y0*8+7:POS_Y0*8],"]"};
            end
            else if (x >= 1000) begin
                getStringFromPos = {"[",NUM_STRING[POS_X3*8+7:POS_X3*8],NUM_STRING[POS_X2*8+7:POS_X2*8],NUM_STRING[POS_X1*8+7:POS_X1*8],NUM_STRING[POS_X0*8+7:POS_X0*8],",",
                                        NUM_STRING[POS_Y1*8+7:POS_Y1*8],NUM_STRING[POS_Y0*8+7:POS_Y0*8],"]"};
            end
            else if (x >= 100) begin
                getStringFromPos = {"[",NUM_STRING[POS_X2*8+7:POS_X2*8],NUM_STRING[POS_X1*8+7:POS_X1*8],NUM_STRING[POS_X0*8+7:POS_X0*8],",",
                                        NUM_STRING[POS_Y1*8+7:POS_Y1*8],NUM_STRING[POS_Y0*8+7:POS_Y0*8],"]"};
            end
            else if (x >= 10) begin
                getStringFromPos = {"[",NUM_STRING[POS_X1*8+7:POS_X1*8],NUM_STRING[POS_X0*8+7:POS_X0*8],",",
                                        NUM_STRING[POS_Y1*8+7:POS_Y1*8],NUM_STRING[POS_Y0*8+7:POS_Y0*8],"]"};
            end
            else begin
                getStringFromPos = {"[",NUM_STRING[POS_X0*8+7:POS_X0*8],",",
                                        NUM_STRING[POS_Y1*8+7:POS_Y1*8],NUM_STRING[POS_Y0*8+7:POS_Y0*8],"]"};
            end
        end
        else begin
            if (x >= 10000000) begin
                getStringFromPos = {"[",NUM_STRING[POS_X7*8+7:POS_X7*8],NUM_STRING[POS_X6*8+7:POS_X6*8],NUM_STRING[POS_X5*8+7:POS_X5*8],NUM_STRING[POS_X4*8+7:POS_X4*8],NUM_STRING[POS_X3*8+7:POS_X3*8],NUM_STRING[POS_X2*8+7:POS_X2*8],NUM_STRING[POS_X1*8+7:POS_X1*8],NUM_STRING[POS_X0*8+7:POS_X0*8],",",
                                        NUM_STRING[POS_Y0*8+7:POS_Y0*8],"]"};
            end
            else if (x >= 1000000) begin
                getStringFromPos = {"[",NUM_STRING[POS_X6*8+7:POS_X6*8],NUM_STRING[POS_X5*8+7:POS_X5*8],NUM_STRING[POS_X4*8+7:POS_X4*8],NUM_STRING[POS_X3*8+7:POS_X3*8],NUM_STRING[POS_X2*8+7:POS_X2*8],NUM_STRING[POS_X1*8+7:POS_X1*8],NUM_STRING[POS_X0*8+7:POS_X0*8],",",
                                        NUM_STRING[POS_Y0*8+7:POS_Y0*8],"]"};
            end
            else if (x >= 100000) begin
                getStringFromPos = {"[",NUM_STRING[POS_X5*8+7:POS_X5*8],NUM_STRING[POS_X4*8+7:POS_X4*8],NUM_STRING[POS_X3*8+7:POS_X3*8],NUM_STRING[POS_X2*8+7:POS_X2*8],NUM_STRING[POS_X1*8+7:POS_X1*8],NUM_STRING[POS_X0*8+7:POS_X0*8],",",
                                        NUM_STRING[POS_Y0*8+7:POS_Y0*8],"]"};
            end
            else if (x >= 10000) begin 
                getStringFromPos = {"[",NUM_STRING[POS_X4*8+7:POS_X4*8],NUM_STRING[POS_X3*8+7:POS_X3*8],NUM_STRING[POS_X2*8+7:POS_X2*8],NUM_STRING[POS_X1*8+7:POS_X1*8],NUM_STRING[POS_X0*8+7:POS_X0*8],",",
                                        NUM_STRING[POS_Y0*8+7:POS_Y0*8],"]"};
            end
            else if (x >= 1000) begin
                getStringFromPos = {"[",NUM_STRING[POS_X3*8+7:POS_X3*8],NUM_STRING[POS_X2*8+7:POS_X2*8],NUM_STRING[POS_X1*8+7:POS_X1*8],NUM_STRING[POS_X0*8+7:POS_X0*8],",",
                                        NUM_STRING[POS_Y0*8+7:POS_Y0*8],"]"};
            end
            else if (x >= 100) begin
                getStringFromPos = {"[",NUM_STRING[POS_X2*8+7:POS_X2*8],NUM_STRING[POS_X1*8+7:POS_X1*8],NUM_STRING[POS_X0*8+7:POS_X0*8],",",
                                        NUM_STRING[POS_Y0*8+7:POS_Y0*8],"]"};
            end
            else if (x >= 10) begin
                getStringFromPos = {"[",NUM_STRING[POS_X1*8+7:POS_X1*8],NUM_STRING[POS_X0*8+7:POS_X0*8],",",
                                        NUM_STRING[POS_Y0*8+7:POS_Y0*8],"]"};
            end
            else begin
                getStringFromPos = {"[",NUM_STRING[POS_X0*8+7:POS_X0*8],",",
                                        NUM_STRING[POS_Y0*8+7:POS_Y0*8],"]"};
            end
        end
    end
endfunction

function [31:0] roundUP;
    input [31:0] dividend;
    input [31:0] divisor;
    begin
        if(divisor == 1) begin
            roundUP = dividend;
        end
        else if(divisor == dividend) begin
            roundUP = 1;
        end
        else begin
            roundUP = dividend/divisor + (((dividend % divisor) == 0) ? 0 : 1);
        end
    end
endfunction

function [31:0] getAddrWidth;
    input [31:0] dwid;
    input [31:0] family_code;
    begin
        case(family_code)
            _FCODE_LIFCL_: begin
                case(dwid)
                    18: getAddrWidth = 10;
                    16: getAddrWidth = 10;
                    9:  getAddrWidth = 11;
                    8:  getAddrWidth = 11;
                    4:  getAddrWidth = 12;
                    2:  getAddrWidth = 13;
                    default:  getAddrWidth = 14;
                endcase
            end
            default: getAddrWidth = 8;
		endcase
    end
endfunction

function [9:0] getByteSize;
    input ben;
    input [31:0] family_code;
    input [31:0] dwidth_impl;
    begin
        if(ben == 1) begin
            case(family_code)
                _FCODE_LIFCL_: begin
                    if(dwidth_impl % 9 == 0 ) getByteSize = 9;
                    else getByteSize = 8;
                end
                default: getByteSize = 8;
            endcase
        end
        else begin
            getByteSize = dwidth_impl;
        end
    end
endfunction

endmodule
`endif