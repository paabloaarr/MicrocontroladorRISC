module CONTROL (
    input  logic [6:0] Instruction,   // opcode
																				
    output logic       Branch,		  // 1 si hay saltos
    output logic       MemRead,		  // 1 si se lee la memoria 
    output logic       MemtoReg,		  // 1 si se guarda un dato en un reg
    output logic [1:0] ALUOp,			  // Indica el tipo de formato a ALU control
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
	OP_AUIPC  = 7'b0010111;
	
// Salida para la ALU_Control
localparam logic [1:0]
	ALUOP_ADD    = 2'b00,   // Se usa para cunado hay que sumar sin tener en cuenta los funct: loads, stores, lui, auipc
	ALUOP_BRANCH = 2'b01,
	ALUOP_R      = 2'b10,
	ALUOP_I      = 2'b11;	
	
always_comb begin
	// Valores por defecto: no escribe nada 
	Branch   = 1'b0;
	MemRead  = 1'b0;
	MemtoReg = 1'b0;      
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
                MemtoReg = 1'b1;
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
            default: ;                 // opcode desconocido: se quedan los valores por defecto
        endcase
    end

endmodule 