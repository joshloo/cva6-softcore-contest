`ifndef NOT_RADIANT_ENV
  `define RADIANT_ENV                    // For Radiant ENV ,RADIANT_ENV is defined here
  `define REGRESSION  0                  // For Radiant ENV ,RADIANT_ENV is defined here
`endif
`ifdef RADIANT_ENV
`else
  `ifndef PAR_SGMII_TSMAC
    `define PAR_SGMII_TSMAC        0
  `endif
  `ifndef PAR_CLASSIC_TSMAC
    `define PAR_CLASSIC_TSMAC      1
  `endif
  `ifndef PAR_INTERFACE
    `define PAR_INTERFACE          "AHBL"
  `endif
  `ifndef PAR_GBE_MAC
    `define PAR_GBE_MAC            0
  `endif
  `ifndef PAR_RGMII
    `define PAR_RGMII              0
  `endif
  `ifndef PAR_MIIM_MODULE
    `define PAR_MIIM_MODULE        0
  `endif
   
`endif

