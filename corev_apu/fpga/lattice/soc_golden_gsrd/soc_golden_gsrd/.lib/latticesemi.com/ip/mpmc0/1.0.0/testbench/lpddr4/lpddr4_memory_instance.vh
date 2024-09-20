// This instance is only for single rank
//genvar dqs_idx;
generate
  `ifdef LAV_AT
    // LPDDR4 Memory Instances
    if (INTERFACE_TYPE == "LPDDR4") begin : LP4MEM_00
      lpddr4_16 mem_x16_00(
        .CK_t   (ddr_ck_o[0]     ),
        .CK_c   (ddr_ck_c[0]     ),
        .CKE    (ddr_cke_o[0]    ),
        .CS     (ddr_cs_o[0]     ),
        .CA     (ddr_ca_o        ),
        .ODT_CA (ddr_odt_o[0]    ),
        .DQ     (ddr_dq_io[15:0] ),
        .DQS_t  (ddr_dqs_io[1:0] ),
        .DQS_c  (ddr_dqs_c[1:0]  ),
        .DMI    (ddr_dmi_io[1:0] ),
        .RESET_n(ddr_reset_n_o   ),
        .ZQ     (                ) // not connected
      );
    end
    if ((INTERFACE_TYPE == "LPDDR4") && (BUS_WIDTH >= 32)) begin : LP4MEM_01
      lpddr4_16 mem_x16_01(
        .CK_t   (ddr_ck_o[0]     ),
        .CK_c   (ddr_ck_c[0]     ),
        .CKE    (ddr_cke_o[0]    ),
        .CS     (ddr_cs_o[0]     ),
        .CA     (ddr_ca_o        ),
        .ODT_CA (ddr_odt_o[0]    ),
        .DQ     (ddr_dq_io[31:16]),
        .DQS_t  (ddr_dqs_io[3:2] ),
        .DQS_c  (ddr_dqs_c[3:2]  ),
        .DMI    (ddr_dmi_io[3:2] ),
        .RESET_n(ddr_reset_n_o   ),
        .ZQ     (                ) // not connected
      );
    end
    if ((INTERFACE_TYPE == "LPDDR4") && (BUS_WIDTH == 64)) begin : LP4MEM_1x
      lpddr4_16 mem_x16_10(
        .CK_t   (ddr_ck_o[0]     ),
        .CK_c   (ddr_ck_c[0]     ),
        .CKE    (ddr_cke_o[0]    ),
        .CS     (ddr_cs_o[0]     ),
        .CA     (ddr_ca_o        ),
        .ODT_CA (ddr_odt_o[0]    ),
        .DQ     (ddr_dq_io[47:32]),
        .DQS_t  (ddr_dqs_io[5:4] ),
        .DQS_c  (ddr_dqs_c[5:4]  ),
        .DMI    (ddr_dmi_io[5:4] ),
        .RESET_n(ddr_reset_n_o   ),
        .ZQ     (                ) // not connected
      );
      lpddr4_16 mem_x16_11(
        .CK_t   (ddr_ck_o[0]     ),
        .CK_c   (ddr_ck_c[0]     ),
        .CKE    (ddr_cke_o[0]    ),
        .CS     (ddr_cs_o[0]     ),
        .CA     (ddr_ca_o        ),
        .ODT_CA (ddr_odt_o[0]    ),
        .DQ     (ddr_dq_io[63:48]),
        .DQS_t  (ddr_dqs_io[7:6] ),
        .DQS_c  (ddr_dqs_c[7:6]  ),
        .DMI    (ddr_dmi_io[7:6] ),
        .RESET_n(ddr_reset_n_o   ),
        .ZQ     (                ) // not connected
      );
    end
  `else
    // LPDDR4 Memory Instances
    if (DDR_TYPE == 1) begin : LP4MEM_00
      lpddr4_16 mem_x16_00(
        .CK_t   (ddr_ck_o[0]     ),
        .CK_c   (~ddr_ck_o[0]    ),
        .CKE    (ddr_cke_o[0]    ),
        .CS     (ddr_cs_o[0]     ),
        .CA     (ddr_ca_o        ),
        .ODT_CA (ddr_odt_o[0]    ),
        .DQ     (ddr_dq_io[15:0] ),
        .DQS_t  (ddr_dqs_io[1:0] ),
        .DQS_c  (ddr_dqs_c[1:0]  ),
        .DMI    (ddr_dmi_io[1:0] ),
        .RESET_n(ddr_reset_n_o   ),
        .ZQ     (                ) // not connected
      );
    end
    if ((DDR_TYPE == 1) && (BUS_WIDTH >= 32)) begin : LP4MEM_01
      lpddr4_16 mem_x16_01(
        .CK_t   (ddr_ck_o[0]     ),
        .CK_c   (~ddr_ck_o[0]    ),
        .CKE    (ddr_cke_o[0]    ),
        .CS     (ddr_cs_o[0]     ),
        .CA     (ddr_ca_o        ),
        .ODT_CA (ddr_odt_o[0]    ),
        .DQ     (ddr_dq_io[31:16]),
        .DQS_t  (ddr_dqs_io[3:2] ),
        .DQS_c  (ddr_dqs_c[3:2]  ),
        .DMI    (ddr_dmi_io[3:2] ),
        .RESET_n(ddr_reset_n_o   ),
        .ZQ     (                ) // not connected
      );
    end
    if ((DDR_TYPE == 1) && (BUS_WIDTH == 64)) begin : LP4MEM_1x
      lpddr4_16 mem_x16_10(
        .CK_t   (ddr_ck_o[0]     ),
        .CK_c   (~ddr_ck_o[0]    ),
        .CKE    (ddr_cke_o[0]    ),
        .CS     (ddr_cs_o[0]     ),
        .CA     (ddr_ca_o        ),
        .ODT_CA (ddr_odt_o[0]    ),
        .DQ     (ddr_dq_io[47:32]),
        .DQS_t  (ddr_dqs_io[5:4] ),
        .DQS_c  (ddr_dqs_c[5:4]  ),
        .DMI    (ddr_dmi_io[5:4] ),
        .RESET_n(ddr_reset_n_o   ),
        .ZQ     (                ) // not connected
      );
      lpddr4_16 mem_x16_11(
        .CK_t   (ddr_ck_o[0]     ),
        .CK_c   (~ddr_ck_o[0]    ),
        .CKE    (ddr_cke_o[0]    ),
        .CS     (ddr_cs_o[0]     ),
        .CA     (ddr_ca_o        ),
        .ODT_CA (ddr_odt_o[0]    ),
        .DQ     (ddr_dq_io[63:48]),
        .DQS_t  (ddr_dqs_io[7:6] ),
        .DQS_c  (ddr_dqs_c[7:6]  ),
        .DMI    (ddr_dmi_io[7:6] ),
        .RESET_n(ddr_reset_n_o   ),
        .ZQ     (                ) // not connected
      );
    end
  `endif
endgenerate
