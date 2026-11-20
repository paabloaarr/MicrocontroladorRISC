module INM_GEN(INM_GEN_IN,INM_GEN_OUT);
input logic [31:0] INM_GEN_IN;
output logic [31:0] INM_GEN_OUT;

always_comb begin
case (INM_GEN_IN[6:0])

7'b0000011: INM_GEN_OUT =	{{20{INM_GEN_IN[31]}},INM_GEN_IN[31:20]}; // LW FORMATO I 
7'b0010011: INM_GEN_OUT =	{{20{INM_GEN_IN[31]}},INM_GEN_IN[31:20]}; // ADDI,SLTI,ANDI,ORI,XORI,SLLI,SRLI,SRAI formato I
7'b0010111:	INM_GEN_OUT =	{INM_GEN_IN[31:12],{12{1'b0}}}; // AUIPC formato U
7'b0110111:	INM_GEN_OUT =	{INM_GEN_IN[31:12],{12{1'b0}}}; // LUI formato U  
7'b0100011:	INM_GEN_OUT =	{{20{INM_GEN_IN[31]}},INM_GEN_IN[31:25],INM_GEN_IN[11:7]}; // SW formato S
7'b1100011:	INM_GEN_OUT =	{{20{INM_GEN_IN[31]}}, INM_GEN_IN[7], INM_GEN_IN[30:25], INM_GEN_IN[11:8], 1'b0 }; // BEQ, BNE formato SB
default : INM_GEN_OUT =	32'b0;
endcase
end
endmodule
