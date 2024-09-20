    mc u_mc(.pll_refclk_i(pll_refclk_i),
        .pll_rst_n_i(pll_rst_n_i),
        .areset_n_i(areset_n_i),
        .aclk_i(aclk_i),
        .rst_n_i(rst_n_i),
        .pclk_i(pclk_i),
        .preset_n_i(preset_n_i),
        .pll_lock_o(pll_lock_o),
        .sclk_o(sclk_o),
        .irq_o(irq_o),
        .init_done_o(init_done_o),
        .trn_err_o(trn_err_o),
        .axi_arvalid_i(axi_arvalid_i),
        .axi_arid_i(axi_arid_i),
        .axi_arlen_i(axi_arlen_i),
        .axi_arburst_i(axi_arburst_i),
        .axi_araddr_i(axi_araddr_i),
        .axi_arqos_i(axi_arqos_i),
        .axi_arsize_i(axi_arsize_i),
        .axi_arready_o(axi_arready_o),
        .axi_rdata_o(axi_rdata_o),
        .axi_rresp_o(axi_rresp_o),
        .axi_rid_o(axi_rid_o),
        .axi_rvalid_o(axi_rvalid_o),
        .axi_rlast_o(axi_rlast_o),
        .axi_rready_i(axi_rready_i),
        .axi_awvalid_i(axi_awvalid_i),
        .axi_awid_i(axi_awid_i),
        .axi_awlen_i(axi_awlen_i),
        .axi_awburst_i(axi_awburst_i),
        .axi_awaddr_i(axi_awaddr_i),
        .axi_awqos_i(axi_awqos_i),
        .axi_awsize_i(axi_awsize_i),
        .axi_awready_o(axi_awready_o),
        .axi_wvalid_i(axi_wvalid_i),
        .axi_wdata_i(axi_wdata_i),
        .axi_wstrb_i(axi_wstrb_i),
        .axi_wlast_i(axi_wlast_i),
        .axi_wready_o(axi_wready_o),
        .axi_bvalid_o(axi_bvalid_o),
        .axi_bready_i(axi_bready_i),
        .axi_bresp_o(axi_bresp_o),
        .axi_bid_o(axi_bid_o),
        .apb_penable_i(apb_penable_i),
        .apb_psel_i(apb_psel_i),
        .apb_pwrite_i(apb_pwrite_i),
        .apb_paddr_i(apb_paddr_i),
        .apb_pwdata_i(apb_pwdata_i),
        .apb_pready_o(apb_pready_o),
        .apb_pslverr_o(apb_pslverr_o),
        .apb_prdata_o(apb_prdata_o),
        .ddr_ck_o(ddr_ck_o),
        .ddr_cke_o(ddr_cke_o),
        .ddr_cs_o(ddr_cs_o),
        .ddr_ca_o(ddr_ca_o),
        .ddr_reset_n_o(ddr_reset_n_o),
        .ddr_dq_io(ddr_dq_io),
        .ddr_dqs_io(ddr_dqs_io),
        .ddr_dmi_io(ddr_dmi_io));
