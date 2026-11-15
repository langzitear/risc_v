# RISC-V CPU 学习与实现

目标：从可仿真的 PC 开始，逐步实现 RV32I 单周期 CPU，再演进到五级流水线。
当前完成：PC 递增与复位，以及自动检查的仿真。其余阶段见 [学习路线](docs/roadmap.md)。

## 目录

```text
docs/                  学习笔记、设计决策、调试记录
  roadmap.md           阶段目标和验收清单
  architecture.md      当前设计约定与实现范围
  notes/               按主题记录学到的机制
  debug/               记录错误、定位过程和修复
rtl/                   可综合硬件代码
  core/                PC、寄存器堆、ALU、译码器、CPU 顶层
  memory/              后续硬件存储器与接口
sim/                   仿真专用代码
  unit/                单模块 testbench
  system/              CPU 执行完整程序的 testbench
  models/              仿真 ROM、RAM 等模型
programs/              CPU 要执行的程序
  asm/                 汇编源程序
  hex/                 对应的存储器初始化文件
scripts/               后续转换、批量运行等辅助脚本
build/                 仿真产物，不提交 Git
Makefile               统一运行入口
```

## 运行

已安装工具：Icarus Verilog、Surfer、make。

```sh
make sim               # 默认运行 PC 测试
make test              # 运行当前所有测试（目前只有 PC）
make wave              # 运行 PC 测试并打开波形
make clean             # 删除生成文件
```

测试输出 `PASS: PC increment and reset` 表示通过。波形在 `build/pc/wave.vcd`。
Surfer 中展开 `tb_pc`，添加 `clk`、`reset`、`value`。

## 约定

- 模块名使用小写下划线，例如 `regfile.v`；对应测试命名为 `tb_regfile.v`。
- RTL 放硬件实现，testbench 和仿真存储器放 `sim/`。
- 每增加一个模块，同时补充能自动判断通过或失败的测试。
- 每完成一个小里程碑再提交 Git；先运行 `make test`。
- 初期在同一套代码上演进，用 Git 保存阶段历史，避免每一课复制整颗 CPU。
- 开始流水线阶段前，为已验证的单周期版本创建 Git 标签。
- 暂不建立 Cache、总线、操作系统等目录，到需要实现时再添加。

下一步：按路线实现寄存器堆，并编写 `sim/unit/tb_regfile.v`。
