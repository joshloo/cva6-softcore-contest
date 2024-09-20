component tse_to_rgmii_bridge0 is
    port(
        rst_n_i: in std_logic;
        plllock_i: in std_logic;
        rgmii_rxc_i: in std_logic;
        rgmii_rxctl_i: in std_logic;
        rgmii_rxd_i: in std_logic_vector(3 downto 0);
        rgmii_txc_i: in std_logic;
        rgmii_txctl_o: out std_logic;
        rgmii_txd_o: out std_logic_vector(3 downto 0);
        rxd_o: out std_logic_vector(7 downto 0);
        rx_dv_o: out std_logic;
        rx_er_o: out std_logic;
        txd_i: in std_logic_vector(7 downto 0);
        tx_en_i: in std_logic;
        tx_er_i: in std_logic;
        rgmii_mdio_o: inout std_logic;
        tse_mdio_en_o: in std_logic;
        tse_mdo_o: in std_logic;
        tse_mdi_i_o: out std_logic
    );
end component;

__: tse_to_rgmii_bridge0 port map(
    rst_n_i=>,
    plllock_i=>,
    rgmii_rxc_i=>,
    rgmii_rxctl_i=>,
    rgmii_rxd_i=>,
    rgmii_txc_i=>,
    rgmii_txctl_o=>,
    rgmii_txd_o=>,
    rxd_o=>,
    rx_dv_o=>,
    rx_er_o=>,
    txd_i=>,
    tx_en_i=>,
    tx_er_i=>,
    rgmii_mdio_o=>,
    tse_mdio_en_o=>,
    tse_mdo_o=>,
    tse_mdi_i_o=>
);
