component arianelattice is
    port(
        clk_i: in std_logic;
        rst_ni: in std_logic;
        boot_addr_i: in std_logic_vector(31 downto 0);
        hart_id_i: in std_logic_vector(33 downto 0);
        irq_i: in std_logic_vector(1 downto 0);
        ipi_i: in std_logic;
        time_irq_i: in std_logic;
        debug_req_i: in std_logic;
        noc_req_o_aw_valid: out std_logic;
        noc_req_o_w_valid: out std_logic;
        noc_req_o_b_ready: out std_logic;
        noc_req_o_ar_valid: out std_logic;
        noc_req_o_r_ready: out std_logic;
        noc_resp_i_aw_ready: in std_logic;
        noc_resp_i_ar_ready: in std_logic;
        noc_resp_i_w_ready: in std_logic;
        noc_resp_i_b_valid: in std_logic;
        noc_resp_i_r_valid: in std_logic;
        noc_resp_i_b_id: in std_logic_vector(3 downto 0);
        noc_resp_i_b_resp: in std_logic_vector(1 downto 0);
        noc_resp_i_b_user: in std_logic_vector(31 downto 0);
        noc_resp_i_r_id: in std_logic_vector(3 downto 0);
        noc_resp_i_r_data: in std_logic_vector(63 downto 0);
        noc_resp_i_r_resp: in std_logic_vector(1 downto 0);
        noc_resp_i_r_last: in std_logic;
        noc_resp_i_r_user: in std_logic_vector(31 downto 0);
        noc_req_o_aw_id: out std_logic_vector(3 downto 0);
        noc_req_o_aw_addr: out std_logic_vector(63 downto 0);
        noc_req_o_aw_len: out std_logic_vector(7 downto 0);
        noc_req_o_aw_size: out std_logic_vector(2 downto 0);
        noc_req_o_aw_burst: out std_logic_vector(1 downto 0);
        noc_req_o_aw_lock: out std_logic;
        noc_req_o_aw_cache: out std_logic_vector(3 downto 0);
        noc_req_o_aw_prot: out std_logic_vector(2 downto 0);
        noc_req_o_aw_qos: out std_logic_vector(3 downto 0);
        noc_req_o_aw_region: out std_logic_vector(3 downto 0);
        noc_req_o_aw_atop: out std_logic_vector(5 downto 0);
        noc_req_o_aw_user: out std_logic_vector(31 downto 0);
        noc_req_o_w_data: out std_logic_vector(63 downto 0);
        noc_req_o_w_strb: out std_logic_vector(7 downto 0);
        noc_req_o_w_last: out std_logic;
        noc_req_o_w_user: out std_logic_vector(31 downto 0);
        noc_req_o_ar_id: out std_logic_vector(3 downto 0);
        noc_req_o_ar_addr: out std_logic_vector(63 downto 0);
        noc_req_o_ar_len: out std_logic_vector(7 downto 0);
        noc_req_o_ar_size: out std_logic_vector(2 downto 0);
        noc_req_o_ar_burst: out std_logic_vector(1 downto 0);
        noc_req_o_ar_lock: out std_logic;
        noc_req_o_ar_cache: out std_logic_vector(3 downto 0);
        noc_req_o_ar_prot: out std_logic_vector(2 downto 0);
        noc_req_o_ar_qos: out std_logic_vector(3 downto 0);
        noc_req_o_ar_region: out std_logic_vector(3 downto 0);
        noc_req_o_ar_user: out std_logic_vector(31 downto 0);
        rvfi_o_valid: out std_logic;
        rvfi_o_order: out std_logic_vector(63 downto 0);
        rvfi_o_insn: out std_logic_vector(31 downto 0);
        rvfi_o_trap: out std_logic;
        rvfi_o_cause: out std_logic_vector(31 downto 0);
        rvfi_o_halt: out std_logic;
        rvfi_o_intr: out std_logic;
        rvfi_o_mode: out std_logic_vector(1 downto 0);
        rvfi_o_ixl: out std_logic_vector(1 downto 0);
        rvfi_o_rs1_addr: out std_logic_vector(4 downto 0);
        rvfi_o_rs2_addr: out std_logic_vector(4 downto 0);
        rvfi_o_rs1_rdata: out std_logic_vector(31 downto 0);
        rvfi_o_rs2_rdata: out std_logic_vector(31 downto 0);
        rvfi_o_rd_addr: out std_logic_vector(4 downto 0);
        rvfi_o_rd_wdata: out std_logic_vector(31 downto 0);
        rvfi_o_pc_rdata: out std_logic_vector(31 downto 0);
        rvfi_o_pc_wdata: out std_logic_vector(31 downto 0);
        rvfi_o_mem_addr: out std_logic_vector(31 downto 0);
        rvfi_o_mem_paddr: out std_logic_vector(33 downto 0);
        rvfi_o_mem_rmask: out std_logic_vector(3 downto 0);
        rvfi_o_mem_wmask: out std_logic_vector(2 downto 0);
        rvfi_o_mem_rdata: out std_logic_vector(31 downto 0);
        rvfi_o_mem_wdata: out std_logic_vector(31 downto 0)
    );
end component;

__: arianelattice port map(
    clk_i=>,
    rst_ni=>,
    boot_addr_i=>,
    hart_id_i=>,
    irq_i=>,
    ipi_i=>,
    time_irq_i=>,
    debug_req_i=>,
    noc_req_o_aw_valid=>,
    noc_req_o_w_valid=>,
    noc_req_o_b_ready=>,
    noc_req_o_ar_valid=>,
    noc_req_o_r_ready=>,
    noc_resp_i_aw_ready=>,
    noc_resp_i_ar_ready=>,
    noc_resp_i_w_ready=>,
    noc_resp_i_b_valid=>,
    noc_resp_i_r_valid=>,
    noc_resp_i_b_id=>,
    noc_resp_i_b_resp=>,
    noc_resp_i_b_user=>,
    noc_resp_i_r_id=>,
    noc_resp_i_r_data=>,
    noc_resp_i_r_resp=>,
    noc_resp_i_r_last=>,
    noc_resp_i_r_user=>,
    noc_req_o_aw_id=>,
    noc_req_o_aw_addr=>,
    noc_req_o_aw_len=>,
    noc_req_o_aw_size=>,
    noc_req_o_aw_burst=>,
    noc_req_o_aw_lock=>,
    noc_req_o_aw_cache=>,
    noc_req_o_aw_prot=>,
    noc_req_o_aw_qos=>,
    noc_req_o_aw_region=>,
    noc_req_o_aw_atop=>,
    noc_req_o_aw_user=>,
    noc_req_o_w_data=>,
    noc_req_o_w_strb=>,
    noc_req_o_w_last=>,
    noc_req_o_w_user=>,
    noc_req_o_ar_id=>,
    noc_req_o_ar_addr=>,
    noc_req_o_ar_len=>,
    noc_req_o_ar_size=>,
    noc_req_o_ar_burst=>,
    noc_req_o_ar_lock=>,
    noc_req_o_ar_cache=>,
    noc_req_o_ar_prot=>,
    noc_req_o_ar_qos=>,
    noc_req_o_ar_region=>,
    noc_req_o_ar_user=>,
    rvfi_o_valid=>,
    rvfi_o_order=>,
    rvfi_o_insn=>,
    rvfi_o_trap=>,
    rvfi_o_cause=>,
    rvfi_o_halt=>,
    rvfi_o_intr=>,
    rvfi_o_mode=>,
    rvfi_o_ixl=>,
    rvfi_o_rs1_addr=>,
    rvfi_o_rs2_addr=>,
    rvfi_o_rs1_rdata=>,
    rvfi_o_rs2_rdata=>,
    rvfi_o_rd_addr=>,
    rvfi_o_rd_wdata=>,
    rvfi_o_pc_rdata=>,
    rvfi_o_pc_wdata=>,
    rvfi_o_mem_addr=>,
    rvfi_o_mem_paddr=>,
    rvfi_o_mem_rmask=>,
    rvfi_o_mem_wmask=>,
    rvfi_o_mem_rdata=>,
    rvfi_o_mem_wdata=>
);
