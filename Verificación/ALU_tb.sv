`timescale 1ns/1ps

module ALU_tb;
    logic [3:0]  OPCODE;
    logic [31:0] Data1;
    logic [31:0] Data2;
    logic        Zero;
    logic [31:0] Result;

    int errors = 0;

    ALU dut (
        .OPCODE(OPCODE),
        .Data1(Data1),
        .Data2(Data2),
        .Zero(Zero),
        .Result(Result)
    );

    // Aplica una operación y compara Result y Zero con el valor esperado.
    task automatic check(input logic [3:0] op, input logic [31:0] a, b, expected, input string name);
        OPCODE = op;
        Data1  = a;
        Data2  = b;
        #10;
        if (Result !== expected || Zero !== (expected == 0)) begin
            $display("FALLA %-28s A=%h B=%h -> Result=%h Zero=%b (esperado %h Zero=%b)",
                     name, a, b, Result, Zero, expected, expected == 0);
            errors++;
        end else
            $display("ok    %-28s A=%h B=%h -> %h", name, a, b, Result);
    endtask

    initial begin
        check(4'b0000, 32'h7FFFFFFF, 32'd1,        32'h80000000, "ADD desbordamiento");
        check(4'b0000, 32'd5,        32'hFFFFFFFB, 32'h00000000, "ADD 5 + (-5) -> Zero");
        check(4'b1000, 32'd5,        32'd7,        32'hFFFFFFFE, "SUB 5 - 7");
        check(4'b1000, 32'd5,        32'd5,        32'h00000000, "SUB 5 - 5 -> Zero");
        check(4'b0111, 32'h0000F0F0, 32'h0000FF00, 32'h0000F000, "AND");
        check(4'b0110, 32'h0000F0F0, 32'h0000FF00, 32'h0000FFF0, "OR");
        check(4'b0100, 32'h0000F0F0, 32'h0000FF00, 32'h00000FF0, "XOR");
        check(4'b0001, 32'd1,        32'd4,        32'h00000010, "SLL 1 << 4");
        check(4'b0001, 32'd1,        32'd36,       32'h00000010, "SLL 1 << 36 (usa 36%32=4)");
        check(4'b0101, 32'hF0000000, 32'd4,        32'h0F000000, "SRL");
        check(4'b0101, 32'hF0000000, 32'd36,       32'h0F000000, "SRL >> 36 (usa 4)");
        check(4'b1001, 32'hF0000000, 32'd4,        32'hFF000000, "SRA negativo");
        check(4'b1001, 32'h70000000, 32'd4,        32'h07000000, "SRA positivo");
        check(4'b1001, 32'hFFFFFFF0, 32'd2,        32'hFFFFFFFC, "SRA -16 >>> 2 = -4");
        check(4'b0010, 32'hFFFFFFFF, 32'd1,        32'h00000001, "SLT -1 < 1");
        check(4'b0010, 32'd9,        32'd8,        32'h00000000, "SLT 9 < 8 -> Zero");
        check(4'b0011, 32'hFFFFFFFF, 32'd1,        32'h00000000, "SLTU 0xFFFFFFFF < 1");
        check(4'b0011, 32'd3,        32'd8,        32'h00000001, "SLTU 3 < 8");
        check(4'b1111, 32'd3,        32'd8,        32'h00000000, "Código sin usar -> default");

        if (errors != 0)
            $fatal(1, "Error: %0d casos de prueba han fallado.", errors);

        $display("PASS: todas las operaciones de la ALU son correctas.");
        $finish;
    end
endmodule
