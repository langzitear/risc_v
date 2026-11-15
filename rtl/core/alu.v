`timescale 1ns / 1ps

// Combinational ALU skeleton. TODO branches are not implemented.
// Encoding contract: docs/interfaces.md
module alu (
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire [ 3:0] op,
    output reg  [31:0] result
);
    // Keep these encodings consistent with decoder.
    localparam [3:0] ALU_ADD    = 4'd0;
    localparam [3:0] ALU_SUB    = 4'd1;
    localparam [3:0] ALU_AND    = 4'd2;
    localparam [3:0] ALU_OR     = 4'd3;
    localparam [3:0] ALU_XOR    = 4'd4;
    localparam [3:0] ALU_SLL    = 4'd5;
    localparam [3:0] ALU_SRL    = 4'd6;
    localparam [3:0] ALU_SRA    = 4'd7;
    localparam [3:0] ALU_SLT    = 4'd8;
    localparam [3:0] ALU_SLTU   = 4'd9;
    localparam [3:0] ALU_PASS_B = 4'd10;

    wire [4:0] shamt;
    assign shamt = b[4:0];

    // Pure combinational logic: no clock or reset.
    always @(*) begin
        // Default prevents latches; unimplemented operations return zero.
        result = 32'd0;
        case (op)
            ALU_ADD: begin
                // TODO: addition; keep the low 32 bits.
                result = a + b;
            end
            ALU_SUB: begin
                // TODO: subtraction; keep the low 32 bits.
                result = a - b;
            end
            ALU_AND: begin
                // TODO: bitwise AND (not logical AND).
                result = a & b;

            end
            ALU_OR: begin
                // TODO: bitwise OR (not logical OR).
                result = a | b;
            end
            ALU_XOR: begin
                // TODO: bitwise XOR.
                result = a ^ b;
            end
            ALU_SLL: begin
                // TODO: shift a left by shamt; fill with zeros.
                result = a << shamt;
            end
            ALU_SRL: begin
                // TODO: logical right shift; fill with zeros.
                result = a >> shamt;
            end
            ALU_SRA: begin
                // TODO: arithmetic right shift; extend the sign of a.
                // a must be interpreted as signed for this operation.
                result = $signed(a) >>> shamt;
            end
            ALU_SLT: begin
                // TODO: signed comparison; produce 32'd1 or 32'd0.
                result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;
            end
            ALU_SLTU: begin
                // TODO: unsigned comparison; produce 32'd1 or 32'd0.
                result = (a < b) ? 32'd1 : 32'd0;
            end
            ALU_PASS_B: begin
                // TODO: pass b through, used by LUI.
                result = b;
            end
            default: begin
                // Reserved op: keep default result.
                // Illegal instruction detection belongs to decoder.
                result = 32'd0;
            end
        endcase
    end
endmodule
