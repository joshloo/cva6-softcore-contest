component pll0 is
    port(
        rstn_i: in std_logic;
        clki_i: in std_logic;
        lock_o: out std_logic;
        clkop_o: out std_logic;
        clkos_o: out std_logic;
        clkos2_o: out std_logic
    );
end component;

__: pll0 port map(
    rstn_i=>,
    clki_i=>,
    lock_o=>,
    clkop_o=>,
    clkos_o=>,
    clkos2_o=>
);
