module CONTROL (
    input  logic [6:0] Instruction,   // opcode
																				
    output logic       Branch,		  // 1 si hay saltos
    output logic       MemRead,		  // 1 si se lee la memoria 
    output logic [1:0] MemtoReg,		  // Dato que se escribe en rd: 00 = ALU, 01 = memoria, 10 = PC + 4
    output logic [2:0] ALUOp,			  // Indica el tipo de formato a ALU control
    output logic       MemWrite,      // 1 si se escribe en memoria
    output logic       ALUSrc,        // 1 si le llega un inmediato a la ALU
    output logic       RegWrite,      // 1 si se escribe en un registro
    output logic [1:0] AuipcLui       // Indica si a la ALU le llega el PC, 0 o un dato del BR
	 );
	 
// Opcodes (tabla de la green card)
localparam logic [6:0]
	OP_R      = 7'b0110011,  // add, sub, sll, slt, sltu, xor, srl, sra, or, and
	OP_I      = 7'b0010011,  // addi, slli, slti, sltiu, xori, srli, srai, ori, andi
	OP_LOAD   = 7'b0000011,  // lb, lh, lw, lbu, lhu
	OP_STORE  = 7'b0100011,  // sb, sh, sw
	OP_BRANCH = 7'b1100011,  // beq, bne, blt, bge, bltu, bgeu
	OP_LUI    = 7'b0110111,
	OP_AUIPC  = 7'b0010111,
	OP_JAL    = 7'b1101111,
	OP_JALR   = 7'b1100111;
	
// Salida para la ALU_Control
localparam logic [2:0]
	ALUOP_ADD    = 3'b000,   // Se usa para cunado hay que sumar sin tener en cuenta los funct: loads, stores, lui, auipc
	ALUOP_BRANCH = 3'b001,
	ALUOP_R      = 3'b010,
	ALUOP_I      = 3'b011,	
	ALUOP_JAL    = 3'b100,
	ALUOP_JALR   = 3'b101;
	
always_comb begin
	// Valores por defecto: no escribe nada 
	Branch   = 1'b0;
	MemRead  = 1'b0;
	MemtoReg = 2'b00;      
	ALUOp    = ALUOP_ADD;
	MemWrite = 1'b0;
	ALUSrc   = 1'b0;      
	RegWrite = 1'b0;
	AuipcLui = 2'b10;      
	
case (Instruction) 							//rd = destino, M[] = memoria de datos, rs = fuente
            OP_R: begin
                RegWrite = 1'b1;
                ALUOp    = ALUOP_R;
            end
            OP_I: begin
                RegWrite = 1'b1;
                ALUSrc   = 1'b1;
                ALUOp    = ALUOP_I;
            end
            OP_LOAD: begin             //rd = M[rs1 + imm]
                RegWrite = 1'b1;
                ALUSrc   = 1'b1;
                MemRead  = 1'b1;
                MemtoReg = 2'b01;
            end
            OP_STORE: begin            // M[rs1 + imm] = rs2
                ALUSrc   = 1'b1;
                MemWrite = 1'b1;
            end
            OP_BRANCH: begin           // compara rs1 con rs2
                Branch   = 1'b1;
                ALUOp    = ALUOP_BRANCH;
            end
            OP_LUI: begin              // rd = 0 + imm
                RegWrite = 1'b1;
                ALUSrc   = 1'b1;
                AuipcLui = 2'b01;
            end
            OP_AUIPC: begin            // rd = PC + imm
                RegWrite = 1'b1;
                ALUSrc   = 1'b1;
                AuipcLui = 2'b00;
            end
				OP_JAL: begin                // rd = PC + 4; PC = PC + imm
					RegWrite = 1'b1;         // escribe en rd
					MemtoReg = 2'b10;        // el dato es PC + 4
					Branch   = 1'b1;         // usa la puerta Branch AND Zero
					AuipcLui = 2'b01;        // entrada A = 0
					ALUOp    = ALUOP_JAL;       // ALU_CONTROL manda AND -> 0 & x = 0 -> Zero = 1
				end
				OP_JALR: begin           // rd = PC + 4; PC = (rs1 + imm) & ~1
                RegWrite = 1'b1;     // escribe en rd
                MemtoReg = 2'b10;    // el dato es PC + 4
                ALUSrc   = 1'b1;     // entrada B = imm (entrada A = rs1 por defecto)
                ALUOp    = ALUOP_JALR;// ALU suma rs1 + imm; el módulo superior lo lleva al PC
            end
            default: ;                 // opcode desconocido: se quedan los valores por defecto
        endcase
    end

endmodule 