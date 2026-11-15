.PHONY: sim test test-alu wave clean

sim: build/pc/sim.out
	cd build/pc && vvp sim.out

test: sim test-alu

test-alu: build/alu/sim.out
	vvp $<

build/alu/sim.out: rtl/core/alu.v sim/unit/tb_alu.v
	mkdir -p build/alu
	iverilog -g2012 -Wall -s tb_alu -o $@ $^

build/pc/sim.out: rtl/core/pc.v sim/unit/tb_pc.v
	mkdir -p build/pc
	iverilog -g2012 -Wall -s tb_pc -o $@ $^

wave: sim
	surfer build/pc/wave.vcd

clean:
	rm -rf build
