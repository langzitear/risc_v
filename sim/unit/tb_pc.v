`timescale 1ns/1ps

module tb_pc;
    reg clk = 0;
    reg reset_n = 1;
    wire [31:0] value;
    integer i;

    pc dut (.clk(clk), .reset_n(reset_n), .value(value));
    always #5 clk = ~clk;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_pc);
        // Assert between clock edges: a synchronous implementation must fail.
        #2 reset_n = 0;
        #1;
        if (value !== 32'd0) $fatal(1, "Initial async reset failed");
        @(posedge clk);
        #1;
        if (value !== 32'd0) $fatal(1, "Reset hold failed");
        @(negedge clk);
        #1 reset_n = 1;
        for (i = 1; i <= 5; i = i + 1) begin
            @(posedge clk);
            #1;
            if (value !== i * 4)
                $fatal(1, "PC mismatch: expected %0d, got %0d", i * 4, value);
            $display("PC = %0d", value);
        end
        // PC is nonzero; check reset before the next rising edge.
        #1 reset_n = 0;
        #1;
        if (value !== 32'd0) $fatal(1, "Second async reset failed");
        @(posedge clk);
        #1;
        if (value !== 32'd0) $fatal(1, "Second reset hold failed");
        @(negedge clk);
        #1 reset_n = 1;
        #1;
        if (value !== 32'd0) $fatal(1, "PC changed on reset release");
        @(posedge clk);
        #1;
        if (value !== 32'd4) $fatal(1, "PC did not resume after reset");
        $display("PASS: PC increment and active-low asynchronous reset");
        $finish;
    end

    initial begin
        #1000;
        $fatal(1, "Simulation timed out");
    end
endmodule
