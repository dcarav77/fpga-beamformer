SIM = iverilog
SIM_ARGS = -Wall -g2012 -Irtl

sim-blinky:
	mkdir -p sim
	$(SIM) $(SIM_ARGS) -o sim/blinky_tb.vvp \
		sim/testbenches/blinky_tb.sv \
		rtl/learning/blinky.sv
	vvp sim/blinky_tb.vvp

view-blinky:
	gtkwave sim/blinky_tb.vcd

clean:
	rm -f sim/*.vvp sim/*.vcd
