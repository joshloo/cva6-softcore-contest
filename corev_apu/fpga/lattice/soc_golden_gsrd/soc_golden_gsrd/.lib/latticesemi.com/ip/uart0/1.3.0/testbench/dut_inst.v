    uart0 u_uart0(.rxd_i(rxd_i),
        .txd_o(txd_o),
        .clk_i(clk_i),
        .rst_n_i(rst_n_i),
        .int_o(int_o),
        .apb_penable_i(apb_penable_i),
        .apb_psel_i(apb_psel_i),
        .apb_pwrite_i(apb_pwrite_i),
        .apb_paddr_i(apb_paddr_i),
        .apb_pwdata_i(apb_pwdata_i),
        .apb_pready_o(apb_pready_o),
        .apb_pslverr_o(apb_pslverr_o),
        .apb_prdata_o(apb_prdata_o));
