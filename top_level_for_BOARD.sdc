create_clock -name {clk_system} -period 125MHz [get_ports {i_clk}]
create_clock -name {clk_rx0} -period 125MHz [get_ports {iRX_CLK_0}]
create_clock -name {clk_rx1} -period 125MHz [get_ports {iRX_CLK_1}]
set_clock_groups -exclusive -group {clk_system}
set_clock_groups -exclusive -group {clk_rx0}
set_clock_groups -exclusive -group {clk_rx1}

derive_pll_clocks -create_base_clocks

#create_generate_clock -name pll625 - source [get_ports {i_clk}] -multiply_by 5 [get_pins {plllaltpll_componentlauto_generated|pll_625}]
#set_clock_groups -exclusive -group {i_clk clk_x5}