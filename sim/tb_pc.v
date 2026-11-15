`timescale 1ns/1ps

module tb_pc;
    reg clk = 0;
    reg reset = 1;
    wire [31:0] value;
    integer i;

    pc dut (.clk(clk), .reset(reset), .value(value));
    always #5 clk = ~clk;

    initial begin
        $dumpfile("build/wave.vcd");
        $dumpvars(0, tb_pc);
        @(posedge clk);
        #1;
        if (value !== 32'd0) $fatal(1, "Reset failed");
        @(negedge clk);
        reset = 0;
        for (i = 1; i <= 5; i = i + 1) begin
            @(posedge clk);
            #1;
            if (value !== i * 4)
                $fatal(1, "PC mismatch: expected %0d, got %0d", i * 4, value);
            $display("PC = %0d", value);
        end
        @(negedge clk);
        reset = 1;
        @(posedge clk);
        #1;
        if (value !== 32'd0) $fatal(1, "Second reset failed");
        $display("PASS: PC increment and reset");
        $finish;
    end

    initial begin
        #1000;
        $fatal(1, "Simulation timed out");
    end
endmodule
