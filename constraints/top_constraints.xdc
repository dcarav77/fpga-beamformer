## Clock 
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 10.000 [get_ports clk]

## Reset button (center button)
set_property PACKAGE_PIN U18 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]

## Output pulse pin (JA1 on PMOD)
set_property PACKAGE_PIN J1 [get_ports pulse_out]
set_property IOSTANDARD LVCMOS33 [get_ports pulse_out]

## Input Echo pin (JA2 on PMOD)
set_property PACKAGE_PIN L2 [get_ports echo_in]
set_property IOSTANDARD LVCMOS33 [get_ports echo_in]

## Configuration Bank
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]