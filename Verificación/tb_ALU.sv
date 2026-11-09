`timescale 1ns/10ps

module tb_ALU ();

logic CLK;
logic [3:0]  OPCODE;
logic [31:0] Data1, Data2, Result;
logic        Zero;

ALU ALU_DUT (.OPCODE(OPCODE), .Data1(Data1), .Data2(Data2), .Zero(Zero), .Result(Result) );

always #10 CLK= ~CLK ; // T=20 ns

initial 
    begin
        //reset
        CLK=0;
        Data1=10;
        Data2=5;
        #10
        @(negedge CLK)
        OPCODE = 0;
        #10
        @(negedge CLK)
        OPCODE = 1;
        #10
        @(negedge CLK)
        OPCODE = 2;
        #10
        @(negedge CLK)
        OPCODE = 3;
        #10
        @(negedge CLK)
        OPCODE = 4;
        #10
        @(negedge CLK)
        OPCODE = 5;
        #10
        @(negedge CLK)
        OPCODE = 6;
        #10
        @(negedge CLK)
        OPCODE = 7;
        #10
        @(negedge CLK)
        OPCODE = 8;
        #10
        @(negedge CLK)
        OPCODE = 9;
        #10
    $stop;
        
    
    end
    
endmodule