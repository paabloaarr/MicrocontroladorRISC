`timescale 1ns/1ps

module tb_INM_GEN();

logic [31:0] INM_GEN_IN;
logic [31:0] INM_GEN_OUT;


INM_GEN duv(
.INM_GEN_IN(INM_GEN_IN),
.INM_GEN_OUT(INM_GEN_OUT)
);

task comprobar(input logic [31:0]aux,input logic [31:0]INM_Esperado,input string tipo);
INM_GEN_IN = aux;
#1;
assert(INM_GEN_OUT == INM_Esperado)
$display("Formato %s de instruccion correcto",tipo);
else
$display("Formato %s instruccion incorrecto",tipo);

endtask 

initial begin

//Formato I(LW, opcode 0000011), Positivo y Negativo
comprobar(32'h00812083, 32'h00000008, "I (LW +)"); // lw x1, 8(x2)
comprobar(32'hFFC12083, 32'hFFFFFFFC, "I (LW -)"); // lw x1, -4(x2)

//Formato I(ADDI, opcode 0010011),Positivo y Negativo
comprobar(32'h00F10093, 32'h0000000F, "I (ADDI +)"); // addi x1, x2, 15
comprobar(32'hFFF10093, 32'hFFFFFFFF, "I (ADDI -)"); // addi x1, x2, -1

//Formato U (AUIPC, opcode (0010111) y LUI, opcode(0110111))
comprobar(32'h12345097, 32'h12345000, "U (AUIPC)");	// auipc x1, 0x12345
comprobar(32'hABCDE0B7, 32'hABCDE000, "U (LUI)");	// lui x1, 0xABCDE

//Formato S (SW, opcode 0100011)
comprobar(32'h0020A623, 32'h0000000C, "S (SW +)");	// sw x2, 12(x1)
comprobar(32'hFE20AC23, 32'hFFFFFFF8, "S (SW -)");	// sw x2, -8(x1)

//Formato SB (BEQ/BNE, opcode 1100011), Positivo (probando bit 11 en [7]) y Negativo
comprobar(32'h002088E3, 32'h00000810, "SB (BEQ +)");	// beq x1, x2, +2064 (verifica imm[11] = instr[7])
comprobar(32'hFE209EE3, 32'hFFFFFFFC, "SB (BNE -)"); // bne x1, x2, -4

//Formato R / Default (ADD, opcode 0110011), Debe sacar 0
comprobar(32'h002081B3, 32'h00000000, "R (Default)");	// add x3, x1, x2
$stop;
end

endmodule
