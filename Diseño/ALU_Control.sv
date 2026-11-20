module ALU_CONTROL (
input logic [3:0] ALU_CONTROL_Ins,
input logic [1:0] ALU_CONTROL_ALUOp, 
output logic [3:0] ALU_CONTROL_Out
);


//mismas inst. que ALU 

//FALTAN AÑADIR INSTRUCCIONES EN LA ALU, POR LO TANTO LA LISTA QUEDA CORTA
//ES SIMPLEMENTE AÑADIR LAS INSTRUCCIONES RESTANTES CON SUS RESPECTIVOS CODIGOS 
//PARA QUE SE MANDEN A LA ALU
typedef enum logic [3:0] {
		ADD = 4'b0000,
		SLL = 4'b0001,
		SLT = 4'b0010,
		SLTU = 4'b0011,
		XOR = 4'b0100,
		SRL = 4'b0101,
		OR = 4'b0110,
		AND = 4'b0111,
		SUB = 4'b1000,
		SRA = 4'b1001
} ALU_OPCODES;

ALU_OPCODES opcode_enum;


//ALU_CONTROL_Ins recibe el bit 30 FUNCT7 y los 3 bits 14-12 de FUNCT3 (greencard)

logic funct7;
logic [2:0] funct3;

assign funct7 = ALU_CONTROL_Ins[3];
assign funct3 = ALU_CONTROL_ins[2:0];
assign ALU_CONTROL_Out = op_out;

always_comb begin
	unique case(ALU_CONTROL_ALUOp) //la salida de control decidira el caso
	//FORMATO U
		3'b000: op_out=LUI;

		3'b001: op_out=AUIPC;
					
	//FORMATO J
		3'b010: 
			begin
				unique case(funct3)
					3'b000: op_out=BEQ;
					3'b001: op_out=BNE;
					3'b100: op_out=BLT;
					3'b101: op_out=BGE;
					3'b110: op_out=BLTU;
					3'b111: op_out=BGEU;
				endcase
			end
			
	//FORMATO L
		3'b011: 
			begin
				unique case(funct3)
					3'b000: op_out=LB;
					3'b001: op_out=LH;
					3'b010: op_out=LW;
					3'b100: op_out=LBU;
					3'b101: op_out=LHU;
				endcase
			end
			
		3'b100: 
			begin
				unique case(funct3)
					3'b000: op_out=SB;
					3'b001: op_out=SH;
					3'b010: op_out=SW;
				endcase
			end
			
		//FORMATO I
		3'b101: 
			begin
				unique case(funct3)
					3'b000: op_out=ADD;
					3'b001: op_out=SLL;
					3'b010: op_out=SLT;
					3'b011: op_out=SLTU;
					3'b100: op_out=XOR;
					3'b101: op_out = (!funct7)? SRL : SRA;
					3'b110: op_out=OR;
					3'b111: op_out=AND;
				endcase
			end
			
		//FORMATO R
		3'b110: 
			begin
				unique case(funct3)
					3'b000: op_out = (!funct7)? ADD : SUB;
					3'b001: op_out=SLL;
					3'b010: op_out=SLT;
					3'b011: op_out=SLTU;
					3'b100: op_out=XOR;
					3'b101: op_out = (!funct7)? SRL : SRA;
					3'b110: op_out=OR;
					3'b111: op_out=AND;
				endcase
			end
		endcase
		end

endmodule 