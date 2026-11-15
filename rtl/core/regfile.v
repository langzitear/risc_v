`timescale 1ns/1ps

// Interface only: implement the logic yourself.
// Contract: docs/interfaces.md
module regfile (
    input wire clk,
    input wire we,
    input wire [4:0] rs1_addr,
    input wire [4:0] rs2_addr,
    input wire [4:0] rd_addr,
    input wire [31:0] rd_data,
    output wire [31:0] rs1_data,
    output wire [31:0] rs2_data
);
    // TODO: internal signals, logic and/or module instances.
endmodule
