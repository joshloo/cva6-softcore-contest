component axi_register_slice0 is
    port(
        a_clk_i: in std_logic;
        a_reset_n_i: in std_logic;
        s_axi_awid_i: in std_logic_vector(3 downto 0);
        s_axi_awaddr_i: in std_logic_vector(31 downto 0);
        s_axi_awlen_i: in std_logic_vector(7 downto 0);
        s_axi_awsize_i: in std_logic_vector(2 downto 0);
        s_axi_awburst_i: in std_logic_vector(1 downto 0);
        s_axi_awlock_i: in std_logic_vector(0 to 0);
        s_axi_awcache_i: in std_logic_vector(3 downto 0);
        s_axi_awprot_i: in std_logic_vector(2 downto 0);
        s_axi_awregion_i: in std_logic_vector(3 downto 0);
        s_axi_awqos_i: in std_logic_vector(3 downto 0);
        s_axi_awuser_i: in std_logic_vector(0 to 0);
        s_axi_awvalid_i: in std_logic;
        s_axi_awready_o: out std_logic;
        s_axi_wdata_i: in std_logic_vector(31 downto 0);
        s_axi_wstrb_i: in std_logic_vector(3 downto 0);
        s_axi_wlast_i: in std_logic;
        s_axi_wuser_i: in std_logic_vector(0 to 0);
        s_axi_wvalid_i: in std_logic;
        s_axi_wready_o: out std_logic;
        s_axi_bid_o: out std_logic_vector(3 downto 0);
        s_axi_bresp_o: out std_logic_vector(1 downto 0);
        s_axi_buser_o: out std_logic_vector(0 to 0);
        s_axi_bvalid_o: out std_logic;
        s_axi_bready_i: in std_logic;
        s_axi_arid_i: in std_logic_vector(3 downto 0);
        s_axi_araddr_i: in std_logic_vector(31 downto 0);
        s_axi_arlen_i: in std_logic_vector(7 downto 0);
        s_axi_arsize_i: in std_logic_vector(2 downto 0);
        s_axi_arburst_i: in std_logic_vector(1 downto 0);
        s_axi_arlock_i: in std_logic_vector(0 to 0);
        s_axi_arcache_i: in std_logic_vector(3 downto 0);
        s_axi_arprot_i: in std_logic_vector(2 downto 0);
        s_axi_arregion_i: in std_logic_vector(3 downto 0);
        s_axi_arqos_i: in std_logic_vector(3 downto 0);
        s_axi_aruser_i: in std_logic_vector(0 to 0);
        s_axi_arvalid_i: in std_logic;
        s_axi_arready_o: out std_logic;
        s_axi_rid_o: out std_logic_vector(3 downto 0);
        s_axi_rdata_o: out std_logic_vector(31 downto 0);
        s_axi_rresp_o: out std_logic_vector(1 downto 0);
        s_axi_rlast_o: out std_logic;
        s_axi_ruser_o: out std_logic_vector(0 to 0);
        s_axi_rvalid_o: out std_logic;
        s_axi_rready_i: in std_logic;
        m_axi_awid_o: out std_logic_vector(3 downto 0);
        m_axi_awaddr_o: out std_logic_vector(31 downto 0);
        m_axi_awlen_o: out std_logic_vector(7 downto 0);
        m_axi_awsize_o: out std_logic_vector(2 downto 0);
        m_axi_awburst_o: out std_logic_vector(1 downto 0);
        m_axi_awlock_o: out std_logic_vector(0 to 0);
        m_axi_awcache_o: out std_logic_vector(3 downto 0);
        m_axi_awprot_o: out std_logic_vector(2 downto 0);
        m_axi_awregion_o: out std_logic_vector(3 downto 0);
        m_axi_awqos_o: out std_logic_vector(3 downto 0);
        m_axi_awuser_o: out std_logic_vector(0 to 0);
        m_axi_awvalid_o: out std_logic;
        m_axi_awready_i: in std_logic;
        m_axi_wdata_o: out std_logic_vector(31 downto 0);
        m_axi_wstrb_o: out std_logic_vector(3 downto 0);
        m_axi_wlast_o: out std_logic;
        m_axi_wuser_o: out std_logic_vector(0 to 0);
        m_axi_wvalid_o: out std_logic;
        m_axi_wready_i: in std_logic;
        m_axi_bid_i: in std_logic_vector(3 downto 0);
        m_axi_bresp_i: in std_logic_vector(1 downto 0);
        m_axi_buser_i: in std_logic_vector(0 to 0);
        m_axi_bvalid_i: in std_logic;
        m_axi_bready_o: out std_logic;
        m_axi_arid_o: out std_logic_vector(3 downto 0);
        m_axi_araddr_o: out std_logic_vector(31 downto 0);
        m_axi_arlen_o: out std_logic_vector(7 downto 0);
        m_axi_arsize_o: out std_logic_vector(2 downto 0);
        m_axi_arburst_o: out std_logic_vector(1 downto 0);
        m_axi_arlock_o: out std_logic_vector(0 to 0);
        m_axi_arcache_o: out std_logic_vector(3 downto 0);
        m_axi_arprot_o: out std_logic_vector(2 downto 0);
        m_axi_arregion_o: out std_logic_vector(3 downto 0);
        m_axi_arqos_o: out std_logic_vector(3 downto 0);
        m_axi_aruser_o: out std_logic_vector(0 to 0);
        m_axi_arvalid_o: out std_logic;
        m_axi_arready_i: in std_logic;
        m_axi_rid_i: in std_logic_vector(3 downto 0);
        m_axi_rdata_i: in std_logic_vector(31 downto 0);
        m_axi_rresp_i: in std_logic_vector(1 downto 0);
        m_axi_rlast_i: in std_logic;
        m_axi_ruser_i: in std_logic_vector(0 to 0);
        m_axi_rvalid_i: in std_logic;
        m_axi_rready_o: out std_logic
    );
end component;

__: axi_register_slice0 port map(
    a_clk_i=>,
    a_reset_n_i=>,
    s_axi_awid_i=>,
    s_axi_awaddr_i=>,
    s_axi_awlen_i=>,
    s_axi_awsize_i=>,
    s_axi_awburst_i=>,
    s_axi_awlock_i=>,
    s_axi_awcache_i=>,
    s_axi_awprot_i=>,
    s_axi_awregion_i=>,
    s_axi_awqos_i=>,
    s_axi_awuser_i=>,
    s_axi_awvalid_i=>,
    s_axi_awready_o=>,
    s_axi_wdata_i=>,
    s_axi_wstrb_i=>,
    s_axi_wlast_i=>,
    s_axi_wuser_i=>,
    s_axi_wvalid_i=>,
    s_axi_wready_o=>,
    s_axi_bid_o=>,
    s_axi_bresp_o=>,
    s_axi_buser_o=>,
    s_axi_bvalid_o=>,
    s_axi_bready_i=>,
    s_axi_arid_i=>,
    s_axi_araddr_i=>,
    s_axi_arlen_i=>,
    s_axi_arsize_i=>,
    s_axi_arburst_i=>,
    s_axi_arlock_i=>,
    s_axi_arcache_i=>,
    s_axi_arprot_i=>,
    s_axi_arregion_i=>,
    s_axi_arqos_i=>,
    s_axi_aruser_i=>,
    s_axi_arvalid_i=>,
    s_axi_arready_o=>,
    s_axi_rid_o=>,
    s_axi_rdata_o=>,
    s_axi_rresp_o=>,
    s_axi_rlast_o=>,
    s_axi_ruser_o=>,
    s_axi_rvalid_o=>,
    s_axi_rready_i=>,
    m_axi_awid_o=>,
    m_axi_awaddr_o=>,
    m_axi_awlen_o=>,
    m_axi_awsize_o=>,
    m_axi_awburst_o=>,
    m_axi_awlock_o=>,
    m_axi_awcache_o=>,
    m_axi_awprot_o=>,
    m_axi_awregion_o=>,
    m_axi_awqos_o=>,
    m_axi_awuser_o=>,
    m_axi_awvalid_o=>,
    m_axi_awready_i=>,
    m_axi_wdata_o=>,
    m_axi_wstrb_o=>,
    m_axi_wlast_o=>,
    m_axi_wuser_o=>,
    m_axi_wvalid_o=>,
    m_axi_wready_i=>,
    m_axi_bid_i=>,
    m_axi_bresp_i=>,
    m_axi_buser_i=>,
    m_axi_bvalid_i=>,
    m_axi_bready_o=>,
    m_axi_arid_o=>,
    m_axi_araddr_o=>,
    m_axi_arlen_o=>,
    m_axi_arsize_o=>,
    m_axi_arburst_o=>,
    m_axi_arlock_o=>,
    m_axi_arcache_o=>,
    m_axi_arprot_o=>,
    m_axi_arregion_o=>,
    m_axi_arqos_o=>,
    m_axi_aruser_o=>,
    m_axi_arvalid_o=>,
    m_axi_arready_i=>,
    m_axi_rid_i=>,
    m_axi_rdata_i=>,
    m_axi_rresp_i=>,
    m_axi_rlast_i=>,
    m_axi_ruser_i=>,
    m_axi_rvalid_i=>,
    m_axi_rready_o=>
);
