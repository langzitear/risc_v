# Verilog 仿真实验

在终端进入此目录后运行：

```sh
make sim
```

看到 `PASS: PC increment and reset` 表示仿真通过。

```sh
make wave
```

使用 Surfer 打开波形。在信号列表中展开 `tb_pc`，添加 `clk`、`reset`、`value`，观察时钟上升沿更新 PC，复位时 PC 归零。

- `rtl/pc.v`：可综合的 PC 模块。
- `sim/tb_pc.v`：产生时钟、复位并自动检查结果的 testbench。
- `build/wave.vcd`：运行后生成的波形。

修改 RTL 后再次运行 `make sim` 即可。下一步可以增加指令 ROM，让 PC 驱动取指。
