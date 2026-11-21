module ALU (
    input  logic [3:0]  OPCODE,
    input  logic [31:0] Data1, Data2,
    output logic        Zero,
    output logic [31:0] Result
);

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

        // FORMATO SB
        BNE
        // BLT,  // Requiere opcode nuevo
        // BLTU  // Requiere opcode nuevo
    } ALU_OPCODES;

    // 1. Creamos una señal del tipo enumerado
    ALU_OPCODES opcode_enum;

    // 2. Hacemos el cast desde la entrada de 4 bits
    assign opcode_enum = ALU_OPCODES'(OPCODE);

    always_comb begin
        unique case (opcode_enum)

        // FORMATO U (reciclan ADD)
            // LUI:     // Recicla ADD. AuipcLui mete 32'd0 en Data1 y ALUSrc mete {imm, 12'b0} (Imm Gen) en Data2.
            // AUIPC:   // Recicla ADD. AuipcLui mete PC en Data1 y ALUSrc mete {imm, 12'b0} (Imm Gen) en Data2.

        // FORMATO UJ
            // JAL:     // No usa la ALU (no requiere opcode). Imm Gen saca imm UJ; Control añade señal al mux del PC (PC + imm) y amplía MemtoReg para guardar PC + 4 en rd (RegWrite = 1).

        // FORMATO SB
            // BEQ:     // Recicla SUB (Zero = 1 si Data1 == Data2). Control activa Branch = 1 y la puerta AND (Branch & Zero) controla el mux del PC.
            BNE:        Result = (Data1 == Data2) ? 32'd1 : 32'd0; // Opcode propio. ALU_CONTROL decodifica funct3 = 001; Zero = 1 si distintos; Branch & Zero controla el mux del PC.
            // BLT:     // Requiere opcode nuevo. ALU_CONTROL decodifica funct3 = 100; Control activa Branch = 1 y Branch & Zero controla el mux del PC.
            // BLTU:    // Requiere opcode nuevo. ALU_CONTROL decodifica funct3 = 110; Control activa Branch = 1 y Branch & Zero controla el mux del PC.
            // BGE:     // Recicla SLT (Zero = 1 si Data1 >= Data2). ALU_CONTROL mapea funct3 = 101 a SLT; Control activa Branch = 1 y RegWrite = 0.
            // BGEU:    // Recicla SLTU (Zero = 1 si Data1 >= Data2 sin signo). ALU_CONTROL mapea funct3 = 111 a SLTU; Control activa Branch = 1 y RegWrite = 0.

        // FORMATO S
            // SW:      // Recicla ADD (rs1 + imm). ALUSrc = 1 mete el inmediato S (Imm Gen) en Data2 y Control activa MemWrite = 1.

        // FORMATO I
            // ADDI..SRAI: // Reciclan FORMATO R. ALU_CONTROL elige la operación y ALUSrc = 1 carga el inmediato I (Imm Gen) en Data2.
            // LW:      // Recicla ADD (rs1 + imm). ALUSrc = 1 mete el inmediato I (Imm Gen); Control activa MemRead = 1, MemtoReg = 1 y RegWrite = 1.
            // JALR:    // Recicla ADD (rs1 + imm). ALU_CONTROL manda ADD y ALUSrc = 1 mete el inmediato I (Imm Gen); el mux del PC se amplía con {Result[31:1], 1'b0} y MemtoReg guarda PC + 4 en rd (RegWrite = 1).

        // FORMATO R
            ADD:        Result = Data1 + Data2;
            SUB:        Result = Data1 - Data2;
            SLL:        Result = Data1 << Data2[4:0];
            SLT:        Result = ($signed(Data1) < $signed(Data2)) ? 32'd1 : 32'd0;
            SLTU:       Result = (Data1 < Data2) ? 32'd1 : 32'd0;
            XOR:        Result = Data1 ^ Data2;
            SRL:        Result = Data1 >> Data2[4:0];
            SRA:        Result = $signed(Data1) >>> Data2[4:0];
            OR:         Result = Data1 | Data2;
            AND:        Result = Data1 & Data2;

            default:    Result = 32'b0;

        endcase
    end

    assign Zero = (Result == 32'b0) ? 1'b1 : 1'b0;

endmodule