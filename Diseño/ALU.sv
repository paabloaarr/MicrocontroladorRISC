module ALU (
    input  logic [3:0]  OPCODE,
    input  logic [31:0] Data1, Data2,
    output logic        Zero,
    output logic [31:0] Result
);

    typedef enum logic [3:0] {
         ADD  = 4'b0000,
         SLL  = 4'b0001,
         SLT  = 4'b0010,
         SLTU = 4'b0011,
         XOR  = 4'b0100,
         SRL  = 4'b0101,
         OR   = 4'b0110,
         AND  = 4'b0111,
         SUB  = 4'b1000,
         SRA  = 4'b1001
    } ALU_OPCODES;
	 
	 // 1. Creamos una señal del tipo enumerado
    ALU_OPCODES opcode_enum;

    // 2. Hacemos el cast desde la entrada de 4 bits
    assign opcode_enum = ALU_OPCODES'(OPCODE);
    
    always_comb
    
        unique case (opcode_enum)
            
            ADD: Result = Data1 + Data2;
            SLL: Result = Data1 << Data2[4:0];
            SLT: Result = ($signed(Data1) < $signed(Data2)) ? 1 : 0;
            SLTU: Result = (Data1 < Data2) ? 1 : 0;
            XOR: Result = Data1 ^ Data2;
            SRL: Result = Data1 >> Data2[4:0];
            OR: Result = Data1 | Data2;
            AND: Result = Data1 & Data2;
            SUB: Result = Data1 - Data2;
            SRA: Result = $signed(Data1) >>> Data2[4:0] ;
            default: Result = 32'b0;
            
        endcase
        
    assign Zero = (Result == 32'b0) ? 1'b1 : 1'b0;
    
endmodule



