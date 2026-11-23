module ALU_CONTROL (
	input logic [3:0] ALU_CONTROL_Ins,
	input logic [2:0] ALU_CONTROL_ALUOp,
	output logic [3:0] ALU_CONTROL_Out
);


//mismas inst. que ALU

    typedef enum logic [3:0] {
        // FORMATO R (compartido con I, S, SB y U)
        ADD,
        SLL,
        SLT,
        SLTU,
        XOR,
        SRL,
        OR,
        AND,
        SUB,
        SRA,

        // FORMATO SB (opcodes propios para activar Zero = 1 cuando se cumple el salto)
        BNE,
        BLT,
        BLTU
    } ALU_OPCODES;

ALU_OPCODES opcode_enum;


//ALU_CONTROL_Ins recibe el bit 30 (corresponde al 2o bit de FUNCT7) y los 3 bits 14-12 de FUNCT3 (mirar greencard)

logic funct7;
logic [2:0] funct3;

assign funct7 = ALU_CONTROL_Ins[3];
assign funct3 = ALU_CONTROL_Ins[2:0];
assign ALU_CONTROL_Out = opcode_enum;

always_comb begin
unique case(ALU_CONTROL_ALUOp) //la salida de control decidira el caso
	//FORMATO U, SOLO USA ADD
	3'b000:
	opcode_enum=ADD;
	
	//FORMATO SB
	3'b001:
	begin
		unique case(funct3)
			3'b001: opcode_enum=BNE;
			3'b100: opcode_enum=BLT;
			3'b110: opcode_enum=BLTU;
			default: opcode_enum=ADD; //evita latches, de todas maneras este caso deberia ser imposible
		endcase
	end

	//FORMATO I (IGUAL QUE EL R, SIN SUBI)
	3'b010:
	begin
		unique case(funct3)
		3'b000: opcode_enum=ADD;
		3'b001: opcode_enum=SLL;
		3'b010: opcode_enum=SLT;
		3'b011: opcode_enum=SLTU;
		3'b100: opcode_enum=XOR;
		3'b101: opcode_enum = (!funct7)? SRL : SRA;
		3'b110: opcode_enum=OR;
		3'b111: opcode_enum=AND;
		endcase
	end

	//FORMATO R
	3'b011:
	begin
		unique case(funct3)
		3'b000: opcode_enum = (!funct7)? ADD : SUB;
		3'b001: opcode_enum=SLL;
		3'b010: opcode_enum=SLT;
		3'b011: opcode_enum=SLTU;
		3'b100: opcode_enum=XOR;
		3'b101: opcode_enum = (!funct7)? SRL : SRA;
		3'b110: opcode_enum=OR;
		3'b111: opcode_enum=AND;
		endcase
	end
	
	//FORMATO J
	3'b100:
	opcode_enum=AND; //fuerza resultado a 0
	
	default: opcode_enum=ADD; //evita latches
	
endcase
end

endmodule 