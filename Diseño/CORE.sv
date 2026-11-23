// Hábito seguido (para no liarnos con los nombres de los nodos...) un nodo se llama igual que la señal origen
// Ejemplo : ALU_CONTROL_out (ALU_CONTROL) -> ALU_CONTROL_out (NODO) <- ALU_CONTROL_in (ALU)


// Falta implementar el formato J
module CORE (
	input logic CLK,
	input logic RSTn,
	input logic [31:0] ROM_Ins,
	input logic [31:0] RAM_R_Data,
	input logic [31:0] PC_out,
	
	output logic [31:0] PC_in,
	output logic CONTROL_MemRead,
	output logic CONTROL_MemtoReg,
	output logic CONTROL_MemWrite,
	output logic [31:0] RAM_W_Data,
	output logic [31:0] RAM_Addr
);

// NODOS INTERNOS

// CONTROL
logic CONTROL_Branch;
logic [1:0] CONTROL_ALUOp;	// *** Puede variar si añadimos nuevos formatos... (U,J,B,L,I,R -> 
// COMO LO HACEMOS : 
						//METEMOS TODOS LOS FORMATOS EN CONTROL (no es necesario...)
						// Metemos solo los que la ALU diferencia 
						
		// EN PIPELINED NO SE REUTILIZA CORE.sv POR LO QUE PODEMOS HACERLO LO MÁS AJUSTADO POSIBLE AL TOP DE SINGLE-CYCLE
logic CONTROL_ALUSrc;
logic CONTROL_RegWrite;
logic [1:0] CONTROL_AuipcLui;
//BR
logic [31:0] BR_R_Data1, BR_R_Data2;
//InmGen
logic [31:0] INM_GEN_out;
//ALU
logic ALU_zero;
logic [31:0] ALU_result;
//ALU_CONTROL
logic [3:0] ALU_CONTROL_out;	// !!!!!! MIRAR ANCHO EN ALU_CONTROL.sv !!!!!!

// MUXes
logic [31:0] MUX_2, MUX_3,MUX_4; // MUX_1 === PC_in ...

// Sumadores
logic [31:0] MUX_1_A;
assign MUX_1_A = PC_out + 32'd4;
logic [31:0] MUX_1_B;
assign MUX_1_B = PC_out + INM_GEN_out; // !!!!!!! Revisar si ya vienen asignados los bits en tal caso o hay que ajustar los que cogemos aqui !!!!!



CONTROL	CONTROL	(
	// Inputs
	.CONTROL_Ins(ROM_Ins[6:0]),
	// Outputs
	.CONTROL_Branch (CONTROL_Branch),
	.CONTROL_MemRead (CONTROL_MemRead),
	.CONTROL_MemtoReg (CONTROL_MemtoReg),
	.CONTROL_ALUOp (CONTROL_ALUOp),
	.CONTROL_MemWrite (CONTROL_MemWrite),
	.CONTROL_ALUSrc (CONTROL_ALUSrc),
	.CONTROL_RegWrite (CONTROL_RegWrite),
	.CONTROL_AuipcLui (CONTROL_AuipcLui)	
	);

BR	BR (
	.BR_R_reg1 (ROM_Ins[19:15]),
	.BR_R_reg2 (ROM_Ins[24:20]),
	.BR_W_reg (ROM_Ins[11:7]),
	.BR_W_Data (MUX_4),
	.BR_RegWrite (CONTROL_RegWrite),
	.CLK (CLK) , .RSTn (RSTn),
	.BR_R_Data1 (BR_R_Data1),
	.BR_R_Data2 (BR_R_Data2)
	);
assign RAM_W_Data = BR_R_Data2;

INM_GEN INM_GEN (
	.INM_GEN_Ins (ROM_Ins),
	.INM_GEN_out (INM_GEN_out)
	);

assign MUX_2 = (CONTROL_AuipcLui == 2'b10)? BR_R_Data1 : (CONTROL_AuipcLui == 2'b01)? 32'd0 : PC_out ;

assign MUX_3 = (CONTROL_ALUSrc == 1'b0)? BR_R_Data2 : INM_GEN_out ;

ALU	ALU (
	.ALU_Data1 (MUX_2),
	.ALU_Data2 (MUX_3),
	.ALU_CONTROL_in (ALU_CONTROL_out),
	.ALU_zero (ALU_zero),
	.ALU_result (ALU_result)
	);
assign RAM_Addr = ALU_result;
assign MUX_4 = (CONTROL_MemtoReg == 1)? RAM_R_Data : ALU_result ;

ALU_CONTROL ALU_CONTROL (
	.ALU_CONTROL_Ins ( {ROM_Ins[30],ROM_Ins[14:12]} ),
	.ALU_CONTROL_ALUOp (CONTROL_ALUOp),
	.ALU_CONTROL_out (ALU_CONTROL_out)
	);

assign PC_in = ( (CONTROL_Branch && ALU_zero) == 0)? MUX_1_A : MUX_1_B;

endmodule 
