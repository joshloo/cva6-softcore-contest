    sgdma0 __(.clk( ),
        .rstn( ),
        .axil_clk( ),
        .axil_rstn( ),
        .s_axil_awaddr_i( ),
        .s_axil_awprot_i( ),
        .s_axil_awvalid_i( ),
        .s_axil_awready_o( ),
        .s_axil_wdata_i( ),
        .s_axil_wstrb_i( ),
        .s_axil_wvalid_i( ),
        .s_axil_wready_o( ),
        .s_axil_bresp_o( ),
        .s_axil_bvalid_o( ),
        .s_axil_bready_i( ),
        .s_axil_araddr_i( ),
        .s_axil_arprot_i( ),
        .s_axil_arvalid_i( ),
        .s_axil_arready_o( ),
        .s_axil_rdata_o( ),
        .s_axil_rresp_o( ),
        .s_axil_rvalid_o( ),
        .s_axil_rready_i( ),
        .m_axi_mm2s_arready_i( ),
        .m_axi_mm2s_arid_o( ),
        .m_axi_mm2s_araddr_o( ),
        .m_axi_mm2s_arregion_o( ),
        .m_axi_mm2s_arlen_o( ),
        .m_axi_mm2s_arsize_o( ),
        .m_axi_mm2s_arburst_o( ),
        .m_axi_mm2s_arlock_o( ),
        .m_axi_mm2s_arcache_o( ),
        .m_axi_mm2s_arprot_o( ),
        .m_axi_mm2s_arqos_o( ),
        .m_axi_mm2s_arvalid_o( ),
        .m_axi_mm2s_rready_o( ),
        .m_axi_mm2s_rid_i( ),
        .m_axi_mm2s_rdata_i( ),
        .m_axi_mm2s_rresp_i( ),
        .m_axi_mm2s_rlast_i( ),
        .m_axi_mm2s_rvalid_i( ),
        .m_axi_s2mm_awready_i( ),
        .m_axi_s2mm_awid_o( ),
        .m_axi_s2mm_awaddr_o( ),
        .m_axi_s2mm_awregion_o( ),
        .m_axi_s2mm_awlen_o( ),
        .m_axi_s2mm_awsize_o( ),
        .m_axi_s2mm_awburst_o( ),
        .m_axi_s2mm_awlock_o( ),
        .m_axi_s2mm_awcache_o( ),
        .m_axi_s2mm_awprot_o( ),
        .m_axi_s2mm_awqos_o( ),
        .m_axi_s2mm_awvalid_o( ),
        .m_axi_s2mm_wready_i( ),
        .m_axi_s2mm_wdata_o( ),
        .m_axi_s2mm_wstrb_o( ),
        .m_axi_s2mm_wlast_o( ),
        .m_axi_s2mm_wvalid_o( ),
        .m_axi_s2mm_bready_o( ),
        .m_axi_s2mm_bid_i( ),
        .m_axi_s2mm_bresp_i( ),
        .m_axi_s2mm_bvalid_i( ),
        .m_axi_bd_awready_i( ),
        .m_axi_bd_awid_o( ),
        .m_axi_bd_awaddr_o( ),
        .m_axi_bd_awregion_o( ),
        .m_axi_bd_awlen_o( ),
        .m_axi_bd_awsize_o( ),
        .m_axi_bd_awburst_o( ),
        .m_axi_bd_awlock_o( ),
        .m_axi_bd_awcache_o( ),
        .m_axi_bd_awprot_o( ),
        .m_axi_bd_awqos_o( ),
        .m_axi_bd_awvalid_o( ),
        .m_axi_bd_wready_i( ),
        .m_axi_bd_wdata_o( ),
        .m_axi_bd_wstrb_o( ),
        .m_axi_bd_wlast_o( ),
        .m_axi_bd_wvalid_o( ),
        .m_axi_bd_bready_o( ),
        .m_axi_bd_bid_i( ),
        .m_axi_bd_bresp_i( ),
        .m_axi_bd_bvalid_i( ),
        .m_axi_bd_arready_i( ),
        .m_axi_bd_arid_o( ),
        .m_axi_bd_araddr_o( ),
        .m_axi_bd_arregion_o( ),
        .m_axi_bd_arlen_o( ),
        .m_axi_bd_arsize_o( ),
        .m_axi_bd_arburst_o( ),
        .m_axi_bd_arlock_o( ),
        .m_axi_bd_arcache_o( ),
        .m_axi_bd_arprot_o( ),
        .m_axi_bd_arqos_o( ),
        .m_axi_bd_arvalid_o( ),
        .m_axi_bd_rready_o( ),
        .m_axi_bd_rid_i( ),
        .m_axi_bd_rdata_i( ),
        .m_axi_bd_rresp_i( ),
        .m_axi_bd_rlast_i( ),
        .m_axi_bd_rvalid_i( ),
        .tx_axis_mm2s_tready_i( ),
        .tx_axis_mm2s_tvalid_o( ),
        .tx_axis_mm2s_tdata_o( ),
        .tx_axis_mm2s_tkeep_o( ),
        .tx_axis_mm2s_tlast_o( ),
        .tx_axis_mm2s_tid_o( ),
        .tx_axis_mm2s_tdest_o( ),
        .rx_axis_s2mm_tvalid_i( ),
        .rx_axis_s2mm_tdata_i( ),
        .rx_axis_s2mm_tkeep_i( ),
        .rx_axis_s2mm_tlast_i( ),
        .rx_axis_s2mm_tid_i( ),
        .rx_axis_s2mm_tready_o( ),
        .rx_axis_s2mm_tdest_i( ),
        .s2mm_xfer_cmpl_irq_o( ),
        .mm2s_xfer_cmpl_irq_o( ));
