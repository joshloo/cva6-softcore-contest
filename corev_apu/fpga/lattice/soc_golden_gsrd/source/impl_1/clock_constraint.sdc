# Top level Clocks
create_clock -name {osc0_inst_clk_out_o_net} -period 100 [get_pins osc0_inst/lscc_osc_inst/u_OSC.OSCE_inst/CLKOUT]
create_clock -name {pll_refclk_i} -period 10 -waveform {0.000 5.000} [get_ports pll_refclk_i]
create_clock -name {clk_125_in} -period 8 -waveform {0.000 4.000} [get_ports clk_125_in]
create_generated_clock -name {clk_125MHz} -source [get_pins pll0_inst/lscc_pll_inst/gen_ext_outclkdiv.u_pll.PLLC_MODE_inst/CLKI] -divide_by 1 -multiply_by 1 [get_pins pll0_inst/lscc_pll_inst/gen_ext_outclkdiv.u_pll.PLLC_MODE_inst/CLKOP]
