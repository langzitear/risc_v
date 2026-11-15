`timescale 1ns/1ps

// Interface only: implement the logic yourself.
// Contract: docs/interfaces.md
module decoder (
    input wire [31:0] instr,
    output wire reg_we,
    output wire [2:0] imm_sel,
    output wire alu_a_pc,
    output wire alu_b_imm,
    output wire [3:0] alu_op,
    output wire [1:0] wb_sel,
    output wire mem_read,
    output wire mem_write,
    output wire [2:0] mem_op,
    output wire [2:0] branch_op,
    output wire [1:0] jump_op,
    output wire illegal
);
    // TODO: internal signals, logic and/or module instances.
endmodule
