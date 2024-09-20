component mpmc0 is
    port(
        axi_S01_aclk_i: in std_logic_vector(0 to 0);
        axi_S01_aresetn_i: in std_logic_vector(0 to 0);
        axi_S00_aclk_i: in std_logic_vector(0 to 0);
        axi_S00_aresetn_i: in std_logic_vector(0 to 0);
        axi_S01_awvalid_i: in std_logic_vector(0 to 0);
        axi_S01_awid_i: in std_logic_vector(3 downto 0);
        axi_S01_awaddr_i: in std_logic_vector(31 downto 0);
        axi_S01_awlen_i: in std_logic_vector(7 downto 0);
        axi_S01_awsize_i: in std_logic_vector(2 downto 0);
        axi_S01_awburst_i: in std_logic_vector(1 downto 0);
        axi_S01_awlock_i: in std_logic_vector(0 to 0);
        axi_S01_awcache_i: in std_logic_vector(3 downto 0);
        axi_S01_awprot_i: in std_logic_vector(2 downto 0);
        axi_S01_awqos_i: in std_logic_vector(3 downto 0);
        axi_S01_awregion_i: in std_logic_vector(3 downto 0);
        axi_S01_awuser_i: in std_logic_vector(0 to 0);
        axi_S01_awready_o: out std_logic_vector(0 to 0);
        axi_S01_wvalid_i: in std_logic_vector(0 to 0);
        axi_S01_wdata_i: in std_logic_vector(31 downto 0);
        axi_S01_wstrb_i: in std_logic_vector(3 downto 0);
        axi_S01_wlast_i: in std_logic_vector(0 to 0);
        axi_S01_wuser_i: in std_logic_vector(0 to 0);
        axi_S01_wready_o: out std_logic_vector(0 to 0);
        axi_S01_bready_i: in std_logic_vector(0 to 0);
        axi_S01_bvalid_o: out std_logic_vector(0 to 0);
        axi_S01_bid_o: out std_logic_vector(3 downto 0);
        axi_S01_bresp_o: out std_logic_vector(1 downto 0);
        axi_S01_buser_o: out std_logic_vector(0 to 0);
        axi_S01_arvalid_i: in std_logic_vector(0 to 0);
        axi_S01_arid_i: in std_logic_vector(3 downto 0);
        axi_S01_araddr_i: in std_logic_vector(31 downto 0);
        axi_S01_arlen_i: in std_logic_vector(7 downto 0);
        axi_S01_arsize_i: in std_logic_vector(2 downto 0);
        axi_S01_arburst_i: in std_logic_vector(1 downto 0);
        axi_S01_arlock_i: in std_logic_vector(0 to 0);
        axi_S01_arcache_i: in std_logic_vector(3 downto 0);
        axi_S01_arprot_i: in std_logic_vector(2 downto 0);
        axi_S01_arqos_i: in std_logic_vector(3 downto 0);
        axi_S01_arregion_i: in std_logic_vector(3 downto 0);
        axi_S01_aruser_i: in std_logic_vector(0 to 0);
        axi_S01_arready_o: out std_logic_vector(0 to 0);
        axi_S01_rready_i: in std_logic_vector(0 to 0);
        axi_S01_rvalid_o: out std_logic_vector(0 to 0);
        axi_S01_rid_o: out std_logic_vector(3 downto 0);
        axi_S01_rdata_o: out std_logic_vector(31 downto 0);
        axi_S01_rresp_o: out std_logic_vector(1 downto 0);
        axi_S01_rlast_o: out std_logic_vector(0 to 0);
        axi_S01_ruser_o: out std_logic_vector(0 to 0);
        axi_S00_awvalid_i: in std_logic_vector(0 to 0);
        axi_S00_awid_i: in std_logic_vector(3 downto 0);
        axi_S00_awaddr_i: in std_logic_vector(31 downto 0);
        axi_S00_awlen_i: in std_logic_vector(7 downto 0);
        axi_S00_awsize_i: in std_logic_vector(2 downto 0);
        axi_S00_awburst_i: in std_logic_vector(1 downto 0);
        axi_S00_awlock_i: in std_logic_vector(0 to 0);
        axi_S00_awcache_i: in std_logic_vector(3 downto 0);
        axi_S00_awprot_i: in std_logic_vector(2 downto 0);
        axi_S00_awqos_i: in std_logic_vector(3 downto 0);
        axi_S00_awregion_i: in std_logic_vector(3 downto 0);
        axi_S00_awuser_i: in std_logic_vector(0 to 0);
        axi_S00_awready_o: out std_logic_vector(0 to 0);
        axi_S00_wvalid_i: in std_logic_vector(0 to 0);
        axi_S00_wdata_i: in std_logic_vector(31 downto 0);
        axi_S00_wstrb_i: in std_logic_vector(3 downto 0);
        axi_S00_wlast_i: in std_logic_vector(0 to 0);
        axi_S00_wuser_i: in std_logic_vector(0 to 0);
        axi_S00_wready_o: out std_logic_vector(0 to 0);
        axi_S00_bready_i: in std_logic_vector(0 to 0);
        axi_S00_bvalid_o: out std_logic_vector(0 to 0);
        axi_S00_bid_o: out std_logic_vector(3 downto 0);
        axi_S00_bresp_o: out std_logic_vector(1 downto 0);
        axi_S00_buser_o: out std_logic_vector(0 to 0);
        axi_S00_arvalid_i: in std_logic_vector(0 to 0);
        axi_S00_arid_i: in std_logic_vector(3 downto 0);
        axi_S00_araddr_i: in std_logic_vector(31 downto 0);
        axi_S00_arlen_i: in std_logic_vector(7 downto 0);
        axi_S00_arsize_i: in std_logic_vector(2 downto 0);
        axi_S00_arburst_i: in std_logic_vector(1 downto 0);
        axi_S00_arlock_i: in std_logic_vector(0 to 0);
        axi_S00_arcache_i: in std_logic_vector(3 downto 0);
        axi_S00_arprot_i: in std_logic_vector(2 downto 0);
        axi_S00_arqos_i: in std_logic_vector(3 downto 0);
        axi_S00_arregion_i: in std_logic_vector(3 downto 0);
        axi_S00_aruser_i: in std_logic_vector(0 to 0);
        axi_S00_arready_o: out std_logic_vector(0 to 0);
        axi_S00_rready_i: in std_logic_vector(0 to 0);
        axi_S00_rvalid_o: out std_logic_vector(0 to 0);
        axi_S00_rid_o: out std_logic_vector(3 downto 0);
        axi_S00_rdata_o: out std_logic_vector(31 downto 0);
        axi_S00_rresp_o: out std_logic_vector(1 downto 0);
        axi_S00_rlast_o: out std_logic_vector(0 to 0);
        axi_S00_ruser_o: out std_logic_vector(0 to 0);
        axi_M00_aclk_i: in std_logic_vector(0 to 0);
        axi_M00_aresetn_i: in std_logic_vector(0 to 0);
        axi_M00_awvalid_o: out std_logic_vector(0 to 0);
        axi_M00_awid_o: out std_logic_vector(3 downto 0);
        axi_M00_awaddr_o: out std_logic_vector(31 downto 0);
        axi_M00_awlen_o: out std_logic_vector(7 downto 0);
        axi_M00_awsize_o: out std_logic_vector(2 downto 0);
        axi_M00_awburst_o: out std_logic_vector(1 downto 0);
        axi_M00_awlock_o: out std_logic_vector(0 to 0);
        axi_M00_awcache_o: out std_logic_vector(3 downto 0);
        axi_M00_awprot_o: out std_logic_vector(2 downto 0);
        axi_M00_awqos_o: out std_logic_vector(3 downto 0);
        axi_M00_awregion_o: out std_logic_vector(3 downto 0);
        axi_M00_awuser_o: out std_logic_vector(0 to 0);
        axi_M00_awready_i: in std_logic_vector(0 to 0);
        axi_M00_wvalid_o: out std_logic_vector(0 to 0);
        axi_M00_wdata_o: out std_logic_vector(255 downto 0);
        axi_M00_wstrb_o: out std_logic_vector(31 downto 0);
        axi_M00_wlast_o: out std_logic_vector(0 to 0);
        axi_M00_wuser_o: out std_logic_vector(0 to 0);
        axi_M00_wready_i: in std_logic_vector(0 to 0);
        axi_M00_bvalid_i: in std_logic_vector(0 to 0);
        axi_M00_bid_i: in std_logic_vector(3 downto 0);
        axi_M00_bresp_i: in std_logic_vector(1 downto 0);
        axi_M00_buser_i: in std_logic_vector(0 to 0);
        axi_M00_bready_o: out std_logic_vector(0 to 0);
        axi_M00_arvalid_o: out std_logic_vector(0 to 0);
        axi_M00_arid_o: out std_logic_vector(3 downto 0);
        axi_M00_araddr_o: out std_logic_vector(31 downto 0);
        axi_M00_arlen_o: out std_logic_vector(7 downto 0);
        axi_M00_arsize_o: out std_logic_vector(2 downto 0);
        axi_M00_arburst_o: out std_logic_vector(1 downto 0);
        axi_M00_arlock_o: out std_logic_vector(0 to 0);
        axi_M00_arcache_o: out std_logic_vector(3 downto 0);
        axi_M00_arprot_o: out std_logic_vector(2 downto 0);
        axi_M00_arqos_o: out std_logic_vector(3 downto 0);
        axi_M00_arregion_o: out std_logic_vector(3 downto 0);
        axi_M00_aruser_o: out std_logic_vector(0 to 0);
        axi_M00_arready_i: in std_logic_vector(0 to 0);
        axi_M00_rvalid_i: in std_logic_vector(0 to 0);
        axi_M00_rid_i: in std_logic_vector(3 downto 0);
        axi_M00_rdata_i: in std_logic_vector(255 downto 0);
        axi_M00_rresp_i: in std_logic_vector(1 downto 0);
        axi_M00_rlast_i: in std_logic_vector(0 to 0);
        axi_M00_ruser_i: in std_logic_vector(0 to 0);
        axi_M00_rready_o: out std_logic_vector(0 to 0)
    );
end component;

__: mpmc0 port map(
    axi_S01_aclk_i=>,
    axi_S01_aresetn_i=>,
    axi_S00_aclk_i=>,
    axi_S00_aresetn_i=>,
    axi_S01_awvalid_i=>,
    axi_S01_awid_i=>,
    axi_S01_awaddr_i=>,
    axi_S01_awlen_i=>,
    axi_S01_awsize_i=>,
    axi_S01_awburst_i=>,
    axi_S01_awlock_i=>,
    axi_S01_awcache_i=>,
    axi_S01_awprot_i=>,
    axi_S01_awqos_i=>,
    axi_S01_awregion_i=>,
    axi_S01_awuser_i=>,
    axi_S01_awready_o=>,
    axi_S01_wvalid_i=>,
    axi_S01_wdata_i=>,
    axi_S01_wstrb_i=>,
    axi_S01_wlast_i=>,
    axi_S01_wuser_i=>,
    axi_S01_wready_o=>,
    axi_S01_bready_i=>,
    axi_S01_bvalid_o=>,
    axi_S01_bid_o=>,
    axi_S01_bresp_o=>,
    axi_S01_buser_o=>,
    axi_S01_arvalid_i=>,
    axi_S01_arid_i=>,
    axi_S01_araddr_i=>,
    axi_S01_arlen_i=>,
    axi_S01_arsize_i=>,
    axi_S01_arburst_i=>,
    axi_S01_arlock_i=>,
    axi_S01_arcache_i=>,
    axi_S01_arprot_i=>,
    axi_S01_arqos_i=>,
    axi_S01_arregion_i=>,
    axi_S01_aruser_i=>,
    axi_S01_arready_o=>,
    axi_S01_rready_i=>,
    axi_S01_rvalid_o=>,
    axi_S01_rid_o=>,
    axi_S01_rdata_o=>,
    axi_S01_rresp_o=>,
    axi_S01_rlast_o=>,
    axi_S01_ruser_o=>,
    axi_S00_awvalid_i=>,
    axi_S00_awid_i=>,
    axi_S00_awaddr_i=>,
    axi_S00_awlen_i=>,
    axi_S00_awsize_i=>,
    axi_S00_awburst_i=>,
    axi_S00_awlock_i=>,
    axi_S00_awcache_i=>,
    axi_S00_awprot_i=>,
    axi_S00_awqos_i=>,
    axi_S00_awregion_i=>,
    axi_S00_awuser_i=>,
    axi_S00_awready_o=>,
    axi_S00_wvalid_i=>,
    axi_S00_wdata_i=>,
    axi_S00_wstrb_i=>,
    axi_S00_wlast_i=>,
    axi_S00_wuser_i=>,
    axi_S00_wready_o=>,
    axi_S00_bready_i=>,
    axi_S00_bvalid_o=>,
    axi_S00_bid_o=>,
    axi_S00_bresp_o=>,
    axi_S00_buser_o=>,
    axi_S00_arvalid_i=>,
    axi_S00_arid_i=>,
    axi_S00_araddr_i=>,
    axi_S00_arlen_i=>,
    axi_S00_arsize_i=>,
    axi_S00_arburst_i=>,
    axi_S00_arlock_i=>,
    axi_S00_arcache_i=>,
    axi_S00_arprot_i=>,
    axi_S00_arqos_i=>,
    axi_S00_arregion_i=>,
    axi_S00_aruser_i=>,
    axi_S00_arready_o=>,
    axi_S00_rready_i=>,
    axi_S00_rvalid_o=>,
    axi_S00_rid_o=>,
    axi_S00_rdata_o=>,
    axi_S00_rresp_o=>,
    axi_S00_rlast_o=>,
    axi_S00_ruser_o=>,
    axi_M00_aclk_i=>,
    axi_M00_aresetn_i=>,
    axi_M00_awvalid_o=>,
    axi_M00_awid_o=>,
    axi_M00_awaddr_o=>,
    axi_M00_awlen_o=>,
    axi_M00_awsize_o=>,
    axi_M00_awburst_o=>,
    axi_M00_awlock_o=>,
    axi_M00_awcache_o=>,
    axi_M00_awprot_o=>,
    axi_M00_awqos_o=>,
    axi_M00_awregion_o=>,
    axi_M00_awuser_o=>,
    axi_M00_awready_i=>,
    axi_M00_wvalid_o=>,
    axi_M00_wdata_o=>,
    axi_M00_wstrb_o=>,
    axi_M00_wlast_o=>,
    axi_M00_wuser_o=>,
    axi_M00_wready_i=>,
    axi_M00_bvalid_i=>,
    axi_M00_bid_i=>,
    axi_M00_bresp_i=>,
    axi_M00_buser_i=>,
    axi_M00_bready_o=>,
    axi_M00_arvalid_o=>,
    axi_M00_arid_o=>,
    axi_M00_araddr_o=>,
    axi_M00_arlen_o=>,
    axi_M00_arsize_o=>,
    axi_M00_arburst_o=>,
    axi_M00_arlock_o=>,
    axi_M00_arcache_o=>,
    axi_M00_arprot_o=>,
    axi_M00_arqos_o=>,
    axi_M00_arregion_o=>,
    axi_M00_aruser_o=>,
    axi_M00_arready_i=>,
    axi_M00_rvalid_i=>,
    axi_M00_rid_i=>,
    axi_M00_rdata_i=>,
    axi_M00_rresp_i=>,
    axi_M00_rlast_i=>,
    axi_M00_ruser_i=>,
    axi_M00_rready_o=>
);
