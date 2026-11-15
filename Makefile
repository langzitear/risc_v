.PHONY: sim test wave clean

sim: build/pc/sim.out
	cd build/pc && vvp sim.out

test: sim

build/pc/sim.out: rtl/core/pc.v sim/unit/tb_pc.v
	mkdir -p build/pc
	iverilog -g2012 -Wall -s tb_pc -o $@ $^

wave: sim
	surfer build/pc/wave.vcd

clean:
	rm -rf build
