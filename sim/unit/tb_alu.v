`timescale 1ns / 1ps

module tb_alu;
    reg [31:0] a, b;
    reg [3:0] op;
    wire [31:0] result;
    integer passed = 0;

    alu dut (.a(a), .b(b), .op(op), .result(result));

    task check;
        input [3:0] code;
        input [31:0] lhs, rhs, expected;
        begin
            op = code;
            a = lhs;
            b = rhs;
            #1; // Let the combinational output settle.
            if (result !== expected)
                $fatal(1, "op=%0d a=%08h b=%08h got=%08h expected=%08h",
                       code, lhs, rhs, result, expected);
            passed = passed + 1;
        end
    endtask

    initial begin
        // Encodings are the external contract in docs/interfaces.md.
        check(4'd0, 32'hffff_ffff, 32'd1, 32'd0);             // ADD wraps
        check(4'd1, 32'd0, 32'd1, 32'hffff_ffff);             // SUB wraps
        check(4'd2, 32'h55, 32'h33, 32'h11);                  // AND
        check(4'd3, 32'h55, 32'h33, 32'h77);                  // OR
        check(4'd4, 32'h55, 32'h33, 32'h66);                  // XOR
        check(4'd5, 32'd1, 32'd63, 32'h8000_0000);            // SLL: 63 -> 31
        check(4'd6, 32'h8000_0000, 32'd33, 32'h4000_0000);    // SRL: zero fill
        check(4'd7, 32'h8000_0000, 32'd33, 32'hc000_0000);    // SRA: sign fill
        check(4'd7, 32'h7fff_ffff, 32'd31, 32'd0);             // SRA: positive
        check(4'd8, 32'hffff_ffff, 32'd1, 32'd1);              // SLT: -1 < 1
        check(4'd8, 32'd1, 32'hffff_ffff, 32'd0);
        check(4'd9, 32'hffff_ffff, 32'd1, 32'd0);              // SLTU: max > 1
        check(4'd9, 32'd1, 32'hffff_ffff, 32'd1);
        check(4'd8, 32'd5, 32'd5, 32'd0);                       // Equality
        check(4'd10, 32'd0, 32'hdead_beef, 32'hdead_beef);     // PASS_B
        check(4'd15, 32'd1, 32'd2, 32'd0);                     // Reserved op
        $display("PASS: %0d ALU vectors", passed);
        $finish;
    end
endmodule
