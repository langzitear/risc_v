.PHONY: sim wave clean

sim: build/sim.out
	vvp build/sim.out

build/sim.out: rtl/pc.v sim/tb_pc.v
	mkdir -p build
	iverilog -g2012 -Wall -s tb_pc -o $@ $^

wave: sim
	surfer build/wave.vcd

clean:
	rm -rf build
