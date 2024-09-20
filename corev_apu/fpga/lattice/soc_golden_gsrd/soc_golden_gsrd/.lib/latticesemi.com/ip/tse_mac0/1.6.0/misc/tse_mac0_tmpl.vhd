component tse_mac0 is
    port(
        int_o: out std_logic;
        ignore_pkt_i: in std_logic;
        reset_n_i: in std_logic;
        mdo_o: out std_logic;
        rx_error_o: out std_logic;
        apb_pready_o: out std_logic;
        axis_rx_tvalid_o: out std_logic;
        rx_fifo_error_o: out std_logic;
        rx_dv_i: in std_logic;
        axis_rx_tready_i: in std_logic;
        tx_discfrm_o: out std_logic;
        tx_sndpausreq_i: in std_logic;
        tx_er_o: out std_logic;
        rx_stat_vector_o: out std_logic_vector(31 downto 0);
        rxd_i: in std_logic_vector(7 downto 0);
        apb_pslverr_o: out std_logic;
        clk_i: in std_logic;
        rxmac_clk_i: in std_logic;
        txmac_clk_i: in std_logic;
        apb_paddr_i: in std_logic_vector(10 downto 0);
        apb_prdata_o: out std_logic_vector(31 downto 0);
        rx_eof_o: out std_logic;
        tx_sndpaustim_i: in std_logic_vector(15 downto 0);
        tx_staten_o: out std_logic;
        rx_staten_o: out std_logic;
        cpu_if_gbit_en_o: out std_logic;
        tx_macread_o: out std_logic;
        mdc_i: in std_logic;
        mdi_i: in std_logic;
        rx_er_i: in std_logic;
        axis_rx_tdata_o: out std_logic_vector(7 downto 0);
        tx_fifoctrl_i: in std_logic;
        tx_en_o: out std_logic;
        axis_rx_tlast_o: out std_logic;
        axis_rx_tkeep_o: out std_logic;
        apb_pwdata_i: in std_logic_vector(31 downto 0);
        axis_tx_tdata_i: in std_logic_vector(7 downto 0);
        axis_tx_tready_o: out std_logic;
        apb_pwrite_i: in std_logic;
        apb_psel_i: in std_logic;
        apb_penable_i: in std_logic;
        tx_statvec_o: out std_logic_vector(31 downto 0);
        mdio_en_o: out std_logic;
        axis_tx_tvalid_i: in std_logic;
        axis_tx_tlast_i: in std_logic;
        axis_tx_tkeep_i: in std_logic;
        txd_o: out std_logic_vector(7 downto 0);
        tx_done_o: out std_logic
    );
end component;

__: tse_mac0 port map(
    int_o=>,
    ignore_pkt_i=>,
    reset_n_i=>,
    mdo_o=>,
    rx_error_o=>,
    apb_pready_o=>,
    axis_rx_tvalid_o=>,
    rx_fifo_error_o=>,
    rx_dv_i=>,
    axis_rx_tready_i=>,
    tx_discfrm_o=>,
    tx_sndpausreq_i=>,
    tx_er_o=>,
    rx_stat_vector_o=>,
    rxd_i=>,
    apb_pslverr_o=>,
    clk_i=>,
    rxmac_clk_i=>,
    txmac_clk_i=>,
    apb_paddr_i=>,
    apb_prdata_o=>,
    rx_eof_o=>,
    tx_sndpaustim_i=>,
    tx_staten_o=>,
    rx_staten_o=>,
    cpu_if_gbit_en_o=>,
    tx_macread_o=>,
    mdc_i=>,
    mdi_i=>,
    rx_er_i=>,
    axis_rx_tdata_o=>,
    tx_fifoctrl_i=>,
    tx_en_o=>,
    axis_rx_tlast_o=>,
    axis_rx_tkeep_o=>,
    apb_pwdata_i=>,
    axis_tx_tdata_i=>,
    axis_tx_tready_o=>,
    apb_pwrite_i=>,
    apb_psel_i=>,
    apb_penable_i=>,
    tx_statvec_o=>,
    mdio_en_o=>,
    axis_tx_tvalid_i=>,
    axis_tx_tlast_i=>,
    axis_tx_tkeep_i=>,
    txd_o=>,
    tx_done_o=>
);
