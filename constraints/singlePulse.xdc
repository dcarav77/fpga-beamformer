## Clock
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 10.000 [get_ports clk]

## Reset button
set_property PACKAGE_PIN U18 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]

## Trigger button
set_property PACKAGE_PIN T18 [get_ports trigger]
set_property IOSTANDARD LVCMOS33 [get_ports trigger]

## Output pulse pin (example JA1)
set_property PACKAGE_PIN J1 [get_ports pulse_out]
set_property IOSTANDARD LVCMOS33 [get_ports pulse_out]