`ifdef LAV_AT
  // =============================================================================
  // >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  // -----------------------------------------------------------------------------
  //   Copyright (c) 2023 by Lattice Semiconductor Corporation
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
  // File                  : lscc_osc.v
  // Title                 :
  // Dependencies          : OSC module
  // Description           :
  // =============================================================================
  //                        REVISION HISTORY
  // Version               : 1.0.0.
  // Author(s)             :
  // Mod. Date             :
  // Changes Made          : Initial release.
  // =============================================================================

  `ifndef lscc_osc
  `define lscc_osc

  module lscc_osc #
  // -----------------------------------------------------------------------------
  // Module Parameters
  // -----------------------------------------------------------------------------
  (
  parameter                USER_CLK_DIVIDEND    =  400,
  parameter                CLK_DIV_DEC          =  1,
  parameter                CLK_DIV              = "1",
  parameter                FAMILY               = "LAV-AT",
  parameter                DEVICE               = "LAV-AT-E70"
  )
  // -----------------------------------------------------------------------------
  // Input/Output Ports
  // -----------------------------------------------------------------------------
  (
  input                    en_i,
  input                    clk_sel_i,

  output                   clk_out_o
  );

  // ---------------------------------------
  // OSC Module Instantiation
  // ---------------------------------------
    OSCE # (
      .CLK_DIV           (CLK_DIV)
    )
    u_OSC (
    //Inputs
      .EN                (en_i),
      .SEL400_N          (clk_sel_i), //1'b0 - 400MHz; 1'b1 - 320MHz
    //Outputs
      .CLKOUT            (clk_out_o)
    );

  endmodule
  //=============================================================================
  // lscc_osc.v
  //=============================================================================
  `endif
`else
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
  // File                  : lscc_osc.v
  // Title                 :
  // Dependencies          : OSC module
  // Description           :
  // =============================================================================
  //                        REVISION HISTORY
  // Version               : 1.0.0.
  // Author(s)             :
  // Mod. Date             :
  // Changes Made          : Initial release.
  // =============================================================================

  `ifndef lscc_osc
  `define lscc_osc

  module lscc_osc #
  // -----------------------------------------------------------------------------
  // Module Parameters
  // -----------------------------------------------------------------------------
  (
  parameter                LF_OUTPUT_EN         = "DISABLED",
  parameter                HF_CLK_DIV_DEC       = 2,
  parameter                HF_CLK_DIV           = "1",
  parameter                HF_OSC_EN            = "ENABLED",
  parameter                HF_CFG_EN            = "ENABLED",
  parameter                SEDCLK_EN            = 0,
  parameter                HF_SED_SEC_DIV_DEC   = 2,
  parameter                HF_SED_SEC_DIV       = "1",
  parameter                FAMILY               = "LIFCL"
  )
  // -----------------------------------------------------------------------------
  // Input/Output Ports
  // -----------------------------------------------------------------------------
  (
  input                    hf_out_en_i,
  input                    sedc_clk_en_i,
  input                    sedc_rst_n_i,

  output                   hf_clk_out_o,
  output                   lf_clk_out_o,
  output                   cfg_clk_o,
  output                   sedc_rst_o
  );

  wire sed_sec_out_w;
  wire cfg_clk_w;

  // ---------------------------------------
  // OSC Module Instantiation
  // ---------------------------------------
  OSCA # (
    .HF_CLK_DIV              (HF_CLK_DIV ),
    .HF_SED_SEC_DIV          (HF_SED_SEC_DIV),
    .HF_OSC_EN               (HF_OSC_EN),
    .LF_OUTPUT_EN            (LF_OUTPUT_EN)
  )
  u_OSC (
  //Inputs
    .HFOUTEN                 (hf_out_en_i),
    .HFSDSCEN                (sedc_clk_en_i),
  //Outputs
    .HFCLKOUT                (hf_clk_out_o),
    .LFCLKOUT                (lf_clk_out_o),
    .HFCLKCFG                (cfg_clk_w),
    .HFSDCOUT                (sed_sec_out_w)
  );

  generate
  if (SEDCLK_EN != 0) begin :u_CFG_CLKRST_CORE
    CONFIG_CLKRST_CORE u_cfg_clkrst_core(
    //Inputs
    .JTAG_LRST_N           (),
    .LMMI_CLK              (),
    .LMMI_LRST_N           (),
    .OSCCLK                (cfg_clk_w),
    .SEDC_CLK              (sed_sec_out_w),
    .SEDC_LRST_N           (sedc_rst_n_i),
    .WDT_LRST_N            (),
    //Outputs
    .HSE_CLK               (),
    .LMMI_CLK_O            (),
    .LMMI_RST              (),
    .SEDC_RST              (sedc_rst_o),
    .CFG_CLK               (cfg_clk_o),
    .SMCLK_RST             (),
    .WDT_CLK               (),
    .WDT_RST               ()
    );
  end

  endgenerate

  endmodule
  //=============================================================================
  // lscc_osc.v
  //=============================================================================
  `endif
`endif