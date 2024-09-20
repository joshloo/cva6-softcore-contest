component cpu0 is
    port(
        clk_system_i: in std_logic;
        clk_realtime_i: in std_logic;
        rstn_i: in std_logic;
        system_resetn_o: out std_logic;
        irq7_i: in std_logic_vector(0 to 0);
        irq6_i: in std_logic_vector(0 to 0);
        irq5_i: in std_logic_vector(0 to 0);
        irq4_i: in std_logic_vector(0 to 0);
        irq3_i: in std_logic_vector(0 to 0);
        irq2_i: in std_logic_vector(0 to 0);
        dBusAxi_aw_payload_id: out std_logic_vector(3 downto 0);
        dBusAxi_aw_payload_addr: out std_logic_vector(31 downto 0);
        dBusAxi_aw_payload_len: out std_logic_vector(7 downto 0);
        dBusAxi_aw_payload_size: out std_logic_vector(2 downto 0);
        dBusAxi_aw_payload_burst: out std_logic_vector(1 downto 0);
        dBusAxi_aw_payload_lock: out std_logic;
        dBusAxi_aw_payload_cache: out std_logic_vector(3 downto 0);
        dBusAxi_aw_payload_prot: out std_logic_vector(2 downto 0);
        dBusAxi_aw_payload_qos: out std_logic_vector(3 downto 0);
        dBusAxi_aw_payload_region: out std_logic_vector(3 downto 0);
        dBusAxi_aw_valid: out std_logic;
        dBusAxi_aw_ready: in std_logic;
        dBusAxi_w_payload_data: out std_logic_vector(31 downto 0);
        dBusAxi_w_payload_strb: out std_logic_vector(3 downto 0);
        dBusAxi_w_payload_last: out std_logic;
        dBusAxi_w_valid: out std_logic;
        dBusAxi_w_ready: in std_logic;
        dBusAxi_b_payload_id: in std_logic_vector(3 downto 0);
        dBusAxi_b_payload_resp: in std_logic_vector(1 downto 0);
        dBusAxi_b_valid: in std_logic;
        dBusAxi_b_ready: out std_logic;
        dBusAxi_ar_payload_id: out std_logic_vector(3 downto 0);
        dBusAxi_ar_payload_addr: out std_logic_vector(31 downto 0);
        dBusAxi_ar_payload_len: out std_logic_vector(7 downto 0);
        dBusAxi_ar_payload_size: out std_logic_vector(2 downto 0);
        dBusAxi_ar_payload_burst: out std_logic_vector(1 downto 0);
        dBusAxi_ar_payload_lock: out std_logic;
        dBusAxi_ar_payload_cache: out std_logic_vector(3 downto 0);
        dBusAxi_ar_payload_prot: out std_logic_vector(2 downto 0);
        dBusAxi_ar_payload_qos: out std_logic_vector(3 downto 0);
        dBusAxi_ar_payload_region: out std_logic_vector(3 downto 0);
        dBusAxi_ar_valid: out std_logic;
        dBusAxi_ar_ready: in std_logic;
        dBusAxi_r_payload_id: in std_logic_vector(3 downto 0);
        dBusAxi_r_payload_data: in std_logic_vector(31 downto 0);
        dBusAxi_r_payload_resp: in std_logic_vector(1 downto 0);
        dBusAxi_r_payload_last: in std_logic;
        dBusAxi_r_valid: in std_logic;
        dBusAxi_r_ready: out std_logic;
        iBusAxi_aw_payload_id: out std_logic_vector(3 downto 0);
        iBusAxi_aw_payload_addr: out std_logic_vector(31 downto 0);
        iBusAxi_aw_payload_len: out std_logic_vector(7 downto 0);
        iBusAxi_aw_payload_size: out std_logic_vector(2 downto 0);
        iBusAxi_aw_payload_burst: out std_logic_vector(1 downto 0);
        iBusAxi_aw_payload_lock: out std_logic;
        iBusAxi_aw_payload_cache: out std_logic_vector(3 downto 0);
        iBusAxi_aw_payload_prot: out std_logic_vector(2 downto 0);
        iBusAxi_aw_payload_qos: out std_logic_vector(3 downto 0);
        iBusAxi_aw_payload_region: out std_logic_vector(3 downto 0);
        iBusAxi_aw_valid: out std_logic;
        iBusAxi_aw_ready: in std_logic;
        iBusAxi_w_payload_data: out std_logic_vector(31 downto 0);
        iBusAxi_w_payload_strb: out std_logic_vector(3 downto 0);
        iBusAxi_w_payload_last: out std_logic;
        iBusAxi_w_valid: out std_logic;
        iBusAxi_w_ready: in std_logic;
        iBusAxi_b_payload_id: in std_logic_vector(3 downto 0);
        iBusAxi_b_payload_resp: in std_logic_vector(1 downto 0);
        iBusAxi_b_valid: in std_logic;
        iBusAxi_b_ready: out std_logic;
        iBusAxi_ar_payload_id: out std_logic_vector(3 downto 0);
        iBusAxi_ar_payload_addr: out std_logic_vector(31 downto 0);
        iBusAxi_ar_payload_len: out std_logic_vector(7 downto 0);
        iBusAxi_ar_payload_size: out std_logic_vector(2 downto 0);
        iBusAxi_ar_payload_burst: out std_logic_vector(1 downto 0);
        iBusAxi_ar_payload_lock: out std_logic;
        iBusAxi_ar_payload_cache: out std_logic_vector(3 downto 0);
        iBusAxi_ar_payload_prot: out std_logic_vector(2 downto 0);
        iBusAxi_ar_payload_qos: out std_logic_vector(3 downto 0);
        iBusAxi_ar_payload_region: out std_logic_vector(3 downto 0);
        iBusAxi_ar_valid: out std_logic;
        iBusAxi_ar_ready: in std_logic;
        iBusAxi_r_payload_id: in std_logic_vector(3 downto 0);
        iBusAxi_r_payload_data: in std_logic_vector(31 downto 0);
        iBusAxi_r_payload_resp: in std_logic_vector(1 downto 0);
        iBusAxi_r_payload_last: in std_logic;
        iBusAxi_r_valid: in std_logic;
        iBusAxi_r_ready: out std_logic
    );
end component;

__: cpu0 port map(
    clk_system_i=>,
    clk_realtime_i=>,
    rstn_i=>,
    system_resetn_o=>,
    irq7_i=>,
    irq6_i=>,
    irq5_i=>,
    irq4_i=>,
    irq3_i=>,
    irq2_i=>,
    dBusAxi_aw_payload_id=>,
    dBusAxi_aw_payload_addr=>,
    dBusAxi_aw_payload_len=>,
    dBusAxi_aw_payload_size=>,
    dBusAxi_aw_payload_burst=>,
    dBusAxi_aw_payload_lock=>,
    dBusAxi_aw_payload_cache=>,
    dBusAxi_aw_payload_prot=>,
    dBusAxi_aw_payload_qos=>,
    dBusAxi_aw_payload_region=>,
    dBusAxi_aw_valid=>,
    dBusAxi_aw_ready=>,
    dBusAxi_w_payload_data=>,
    dBusAxi_w_payload_strb=>,
    dBusAxi_w_payload_last=>,
    dBusAxi_w_valid=>,
    dBusAxi_w_ready=>,
    dBusAxi_b_payload_id=>,
    dBusAxi_b_payload_resp=>,
    dBusAxi_b_valid=>,
    dBusAxi_b_ready=>,
    dBusAxi_ar_payload_id=>,
    dBusAxi_ar_payload_addr=>,
    dBusAxi_ar_payload_len=>,
    dBusAxi_ar_payload_size=>,
    dBusAxi_ar_payload_burst=>,
    dBusAxi_ar_payload_lock=>,
    dBusAxi_ar_payload_cache=>,
    dBusAxi_ar_payload_prot=>,
    dBusAxi_ar_payload_qos=>,
    dBusAxi_ar_payload_region=>,
    dBusAxi_ar_valid=>,
    dBusAxi_ar_ready=>,
    dBusAxi_r_payload_id=>,
    dBusAxi_r_payload_data=>,
    dBusAxi_r_payload_resp=>,
    dBusAxi_r_payload_last=>,
    dBusAxi_r_valid=>,
    dBusAxi_r_ready=>,
    iBusAxi_aw_payload_id=>,
    iBusAxi_aw_payload_addr=>,
    iBusAxi_aw_payload_len=>,
    iBusAxi_aw_payload_size=>,
    iBusAxi_aw_payload_burst=>,
    iBusAxi_aw_payload_lock=>,
    iBusAxi_aw_payload_cache=>,
    iBusAxi_aw_payload_prot=>,
    iBusAxi_aw_payload_qos=>,
    iBusAxi_aw_payload_region=>,
    iBusAxi_aw_valid=>,
    iBusAxi_aw_ready=>,
    iBusAxi_w_payload_data=>,
    iBusAxi_w_payload_strb=>,
    iBusAxi_w_payload_last=>,
    iBusAxi_w_valid=>,
    iBusAxi_w_ready=>,
    iBusAxi_b_payload_id=>,
    iBusAxi_b_payload_resp=>,
    iBusAxi_b_valid=>,
    iBusAxi_b_ready=>,
    iBusAxi_ar_payload_id=>,
    iBusAxi_ar_payload_addr=>,
    iBusAxi_ar_payload_len=>,
    iBusAxi_ar_payload_size=>,
    iBusAxi_ar_payload_burst=>,
    iBusAxi_ar_payload_lock=>,
    iBusAxi_ar_payload_cache=>,
    iBusAxi_ar_payload_prot=>,
    iBusAxi_ar_payload_qos=>,
    iBusAxi_ar_payload_region=>,
    iBusAxi_ar_valid=>,
    iBusAxi_ar_ready=>,
    iBusAxi_r_payload_id=>,
    iBusAxi_r_payload_data=>,
    iBusAxi_r_payload_resp=>,
    iBusAxi_r_payload_last=>,
    iBusAxi_r_valid=>,
    iBusAxi_r_ready=>
);
