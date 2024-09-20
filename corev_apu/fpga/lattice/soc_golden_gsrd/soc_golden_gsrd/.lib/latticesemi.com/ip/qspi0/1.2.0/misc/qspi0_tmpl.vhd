component qspi0 is
    port(
        a_clk_i: in std_logic;
        a_reset_n_i: in std_logic;
        int_o: out std_logic;
        qspi_io0: inout std_logic;
        qspi_io1: inout std_logic;
        qspi_io2: inout std_logic;
        qspi_io3: inout std_logic;
        sclk_o: out std_logic;
        ss_n_o: out std_logic_vector(0 to 0);
        axi_awid_i: in std_logic_vector(3 downto 0);
        axi_awaddr_i: in std_logic_vector(31 downto 0);
        axi_awlen_i: in std_logic_vector(7 downto 0);
        axi_awsize_i: in std_logic_vector(2 downto 0);
        axi_awburst_i: in std_logic_vector(1 downto 0);
        axi_awlock_i: in std_logic_vector(0 to 0);
        axi_awcache_i: in std_logic_vector(3 downto 0);
        axi_awprot_i: in std_logic_vector(2 downto 0);
        axi_awvalid_i: in std_logic;
        axi_awready_o: out std_logic;
        axi_wdata_i: in std_logic_vector(31 downto 0);
        axi_wstrb_i: in std_logic_vector(3 downto 0);
        axi_wlast_i: in std_logic;
        axi_wvalid_i: in std_logic;
        axi_wready_o: out std_logic;
        axi_bid_o: out std_logic_vector(3 downto 0);
        axi_bresp_o: out std_logic_vector(1 downto 0);
        axi_bvalid_o: out std_logic;
        axi_bready_i: in std_logic;
        axi_arid_i: in std_logic_vector(3 downto 0);
        axi_araddr_i: in std_logic_vector(31 downto 0);
        axi_arlen_i: in std_logic_vector(7 downto 0);
        axi_arsize_i: in std_logic_vector(2 downto 0);
        axi_arburst_i: in std_logic_vector(1 downto 0);
        axi_arlock_i: in std_logic_vector(0 to 0);
        axi_arcache_i: in std_logic_vector(3 downto 0);
        axi_arprot_i: in std_logic_vector(2 downto 0);
        axi_arvalid_i: in std_logic;
        axi_arready_o: out std_logic;
        axi_rid_o: out std_logic_vector(3 downto 0);
        axi_rdata_o: out std_logic_vector(31 downto 0);
        axi_rresp_o: out std_logic_vector(1 downto 0);
        axi_rlast_o: out std_logic;
        axi_rvalid_o: out std_logic;
        axi_rready_i: in std_logic
    );
end component;

__: qspi0 port map(
    a_clk_i=>,
    a_reset_n_i=>,
    int_o=>,
    qspi_io0=>,
    qspi_io1=>,
    qspi_io2=>,
    qspi_io3=>,
    sclk_o=>,
    ss_n_o=>,
    axi_awid_i=>,
    axi_awaddr_i=>,
    axi_awlen_i=>,
    axi_awsize_i=>,
    axi_awburst_i=>,
    axi_awlock_i=>,
    axi_awcache_i=>,
    axi_awprot_i=>,
    axi_awvalid_i=>,
    axi_awready_o=>,
    axi_wdata_i=>,
    axi_wstrb_i=>,
    axi_wlast_i=>,
    axi_wvalid_i=>,
    axi_wready_o=>,
    axi_bid_o=>,
    axi_bresp_o=>,
    axi_bvalid_o=>,
    axi_bready_i=>,
    axi_arid_i=>,
    axi_araddr_i=>,
    axi_arlen_i=>,
    axi_arsize_i=>,
    axi_arburst_i=>,
    axi_arlock_i=>,
    axi_arcache_i=>,
    axi_arprot_i=>,
    axi_arvalid_i=>,
    axi_arready_o=>,
    axi_rid_o=>,
    axi_rdata_o=>,
    axi_rresp_o=>,
    axi_rlast_o=>,
    axi_rvalid_o=>,
    axi_rready_i=>
);
