`timescale 1ns/1ps

// Interface only: implement the logic yourself.
// Contract: docs/interfaces.md
module load_store_unit (
    input wire mem_read,
    input wire mem_write,
    input wire [2:0] mem_op,
    input wire [31:0] addr,
    input wire [31:0] store_data,
    input wire [31:0] bus_rdata,
    output wire [31:0] bus_addr,
    output wire [31:0] bus_wdata,
    output wire [3:0] bus_wstrb,
    output wire [31:0] load_data,
    output wire misaligned
);
    // TODO: internal signals, logic and/or module instances.
endmodule
