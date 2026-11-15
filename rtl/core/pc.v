`timescale 1ns/1ps

module pc (
    input wire clk,
    input wire reset_n,
    output reg [31:0] value
);
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            value <= 32'd0;
        else
            value <= value + 32'd4;
    end
endmodule
