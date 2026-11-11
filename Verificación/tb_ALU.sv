`timescale 1ns/10ps

module tb_ALU ();

logic        CLK;
logic [3:0]  OPCODE;
logic [31:0] Data1, Data2, Result;
logic        Zero;

ALU ALU_DUT (.OPCODE(OPCODE), .Data1(Data1), .Data2(Data2), .Zero(Zero), .Result(Result));

always #10 CLK = ~CLK;

initial
    begin
        CLK = 0;
        OPCODE = 0;
        Data1 = 97;
        Data2 = 53;
        @(negedge CLK)
        OPCODE = 1;
        @(negedge CLK)
        OPCODE = 2;
        @(negedge CLK)
        OPCODE = 3;
        @(negedge CLK)
        OPCODE = 4;
        @(negedge CLK)
        OPCODE = 5;
        @(negedge CLK)
        OPCODE = 6;
        @(negedge CLK)
        OPCODE = 7;
        @(negedge CLK)
        OPCODE = 8;
        @(negedge CLK)
        OPCODE = 9;
        @(negedge CLK)
        $stop;
    end

endmodule