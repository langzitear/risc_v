# 单周期 CPU 接口约定

这些接口是第一版的设计契约。`rtl/core/` 新增文件只有端口与 TODO，输出尚未驱动，不能执行指令。
现有 `pc.v` 是保留的入门示例；CPU 使用新的 `pc_reg.v`，不要把自动加 4 的旧 PC 直接接入。
端口声明中的 `output wire` 允许你按实现方式改为 `output reg`，端口名称、位宽和语义保持一致。

## 模块连接

```text
pc_reg.pc → imem_addr → 外部指令 ROM → imem_rdata（instr）
instr → decoder / imm_gen / 寄存器地址
regfile → ALU 输入选择 / branch_unit / store_data
ALU.result → 普通运算写回 / 访存地址 / 跳转目标
load_store_unit ↔ 外部数据 RAM
写回选择 → regfile.rd_data
下一 PC 选择 → pc_reg.next_pc
```

CPU 顶层负责实例化、连线、操作数选择、写回选择、下一 PC 选择和副作用屏蔽。
先做 addi 用到的路径，其余模块之后再接。

## 全局时序

- 32 位地址、32 位数据，小端序；地址单位一律为字节。
- `reset_n` 是低有效异步复位，拉低时 PC 立即归零，无需等待时钟；保持为 0 时禁止寄存器写入和数据存储器请求。
- PC 与寄存器堆在上升沿更新，其余计算和读存储器是组合逻辑；无 ready/valid 握手等待、无流水线。
- 除 PC 外，普通寄存器不要求清零。程序先写后读；x0 的任何读取必须为零，写入无效。
- 组合模块的控制输出必须有默认值，避免锁存器。当前执行发生故障时禁止提交任何副作用。

## CPU 对外接口

| 端口 | 契约 |
| --- | --- |
| imem_addr / imem_rdata | PC 字节地址 / 当前地址组合返回的 32 位指令字 |
| dmem_valid | 有效数据访问请求；无请求时为 0 |
| dmem_addr | 对齐到 4 字节边界的字节地址 |
| dmem_wdata | 已移位到对应字节通道的数据 |
| dmem_wstrb | 每位对应一个写入字节；读请求和无请求时为 0000 |
| dmem_rdata | 对齐地址组合读出的完整 32 位字；由 LSU 提取和扩展 |
| fault | 非法指令、非对齐访存或已采用的跳转目标不满足 4 字节对齐时为 1 |

`fault` 为当前指令的组合状态，不是锁存的异常寄存器；故障时 PC 保持、禁止写回、dmem_valid=0、dmem_wstrb=0，直到复位。
故障只由内部译码/地址/跳转计算产生，不依赖屏蔽后的总线输出，避免组合环路。
外部 RAM 仅在上升沿且 valid=1 时按 wstrb 写入；读没有副作用。
指令 ROM 越界应由 testbench 报错；这个简化总线尚无访问错误返回接口。

## 各模块

### pc_reg

使用 `@(posedge clk or negedge reset_n)`；reset_n=0 时优先归零，否则在上升沿 enable=1 时采纳 next_pc，enable=0 时保持。
CPU 正常执行令 enable=1；fault 时令 enable=0。顺序 PC+4 由 CPU 顶层计算。

### regfile

rs1_addr、rs2_addr 组合读取；上升沿 we=1 且 rd_addr!=0 时写入 rd_data。
同一上升沿前读取旧值，更新后读取新值，无显式旁路；不要依赖普通寄存器的上电值。
地址在 CPU 顶层由 instr[19:15]、instr[24:20]、instr[11:7] 提取。

### imm_gen

按照 imm_sel 从 instr 生成 32 位立即数；B/J 立即数包含低位 0，输出已经是字节偏移，使用时不要再左移。
U 立即数低 12 位填零，其余立即数符号扩展。

### decoder

只负责组合译码和合法性检查；必须检查必要的 funct3/funct7 等字段，不能只看 opcode。
reg_we 表示本指令请求写回，实际写使能由顶层结合 reset_n/fault 屏蔽。
alu_a_pc=0 选择 rs1，=1 选择当前 PC；alu_b_imm=0 选择 rs2，=1 选择 imm。
mem_op 直接使用合法访存指令的 funct3；非法编码设置 illegal。
无访存时 mem_read=mem_write=0；无分支、跳转分别使用 NONE 编码。
未实现的指令设 illegal=1，所有写控制默认关闭。当前阶段 FENCE、SYSTEM 也先报未支持，后续明确实现其语义。

### alu

组合运算；移位量只使用 b[4:0]，SLT/SRA 使用有符号语义。
PASS_B 用于 LUI；跳转时 ALU 可计算 PC+imm 或 rs1+imm。

### branch_unit

组合比较两个寄存器，输出分支是否采用；NONE 时为 0。与 ALU 独立，允许 ALU 同时计算分支目标。

### load_store_unit

组合逻辑；addr 是未对齐的有效字节地址。bus_addr 是其 4 字节对齐地址。
store_data 来自 rs2；根据地址低位将字节/半字数据放到 bus_wdata 对应通道，并产生 bus_wstrb。
从 bus_rdata 的对应通道提取 load_data，按 mem_op 决定符号扩展或零扩展。
字访问要求 addr[1:0]=0，半字要求 addr[0]=0，字节无对齐限制。
misaligned 只在请求访问时有效；无写请求或非对齐时 bus_wstrb=0。
CPU 再结合 fault/reset_n 屏蔽外部请求，LSU 的地址计算不依赖外部 dmem_valid。

## 控制编码（固定）

| 控制 | 编码 |
| --- | --- |
| imm_sel（3 位） | 0=I，1=S，2=B，3=U，4=J |
| alu_op（4 位） | 0=ADD，1=SUB，2=AND，3=OR，4=XOR，5=SLL，6=SRL，7=SRA，8=SLT，9=SLTU，10=PASS_B |
| wb_sel（2 位） | 0=ALU，1=LOAD，2=PC+4 |
| branch_op（3 位） | 0=NONE，1=EQ，2=NE，3=LT，4=GE，5=LTU，6=GEU |
| jump_op（2 位） | 0=NONE，1=JAL，2=JALR |
| mem_op（3 位） | 0=BYTE，1=HALF，2=WORD，4=BYTE_UNSIGNED，5=HALF_UNSIGNED；写仅允许 0/1/2 |

其余编码保留；可自行用 localparam 表达，避免逻辑中散落数字。

## 下一 PC 与写回

正常情况下，顺序执行用 PC+4；采用的分支和 JAL 用 PC+imm；JALR 用 (rs1+imm) 清除 bit 0 后的地址。
RV32I 不支持压缩指令，最终采用的目标地址还必须 4 字节对齐；不采用的条件分支不检查目标对齐。
JAL/JALR 写回当前 PC+4。其他写回由 wb_sel 决定。
reset_n/fault 的屏蔽优先于所有译码写控制。

## 推荐实现顺序

1. regfile：检查双读、写入、x0。
2. alu：先 ADD，再逐个增加操作。
3. imm_gen：先 I 型，再补其他类型。
4. decoder：先仅识别 addi，其他指令 illegal。
5. pc_reg + cpu：连通 addi 数据路径，用 ROM 程序验收。
6. branch_unit、load_store_unit：到分支和访存阶段再实现。

接口空壳只用于起步，不代表功能实现；现有 make test 目前只验收旧 PC 示例。

复位屏蔽条件为 `!reset_n` 或 fault。仿真在远离上升沿时释放复位；将来用于实际硬件时，需要考虑异步复位的同步释放及恢复/移除时间约束。
