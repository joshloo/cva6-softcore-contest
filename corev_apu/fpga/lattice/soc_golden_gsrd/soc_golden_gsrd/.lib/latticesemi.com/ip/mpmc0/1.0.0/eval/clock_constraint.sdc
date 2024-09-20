# This is a sample constraint on the clocks
# You should constrain the PLL reference clock from the top-level ports
create_clock -name {pll_refclk_i} -period 10 [get_ports pll_refclk_i]


