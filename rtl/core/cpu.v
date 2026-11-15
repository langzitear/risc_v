`timescale 1ns/1ps

// Interface only: implement the logic yourself.
// Contract: docs/interfaces.md
module cpu (
    input wire clk,
    input wire reset_n,
    output wire [31:0] imem_addr,
    input wire [31:0] imem_rdata,
    output wire dmem_valid,
    output wire [31:0] dmem_addr,
    output wire [31:0] dmem_wdata,
    output wire [3:0] dmem_wstrb,
    input wire [31:0] dmem_rdata,
    output wire fault
);
    // TODO: internal signals, logic and/or module instances.
endmodule
