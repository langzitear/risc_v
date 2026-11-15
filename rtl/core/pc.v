`timescale 1ns/1ps

module pc (
    input wire clk,
    input wire reset,
    output reg [31:0] value
);
    always @(posedge clk) begin
        if (reset)
            value <= 32'd0;
        else
            value <= value + 32'd4;
    end
endmodule
