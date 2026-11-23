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

        // FORMATO SB (opcodes propios para activar Zero = 1 cuando se cumple el salto)
        BNE,
        BLT,
        BLTU
    } ALU_OPCODES;

    // 1. Creamos una señal del tipo enumerado
    ALU_OPCODES opcode_enum;

    // 2. Hacemos el cast desde la entrada de 4 bits
    assign opcode_enum = ALU_OPCODES'(OPCODE);

    always_comb begin
        unique case (opcode_enum)

        // FORMATO U
            // LUI:     // Recicla ADD. AuipcLui = 1 mete 32'd0 en Data1 y ALUSrc = 1 mete {imm, 12'b0} (Imm Gen) en Data2; RegWrite = 1.
            // AUIPC:   // Recicla ADD. AuipcLui = 0 mete PC en Data1 y ALUSrc = 1 mete {imm, 12'b0} (Imm Gen) en Data2; RegWrite = 1.

        // FORMATO UJ
            // JAL:     // No usa la ALU (no requiere opcode). Imm Gen saca imm UJ; Control añade señal al mux del PC (PC + imm) y amplía MemtoReg para guardar PC + 4 en rd (RegWrite = 1).

        // FORMATO SB
            // BEQ:     // Recicla SUB (Zero = 1 si Data1 == Data2). ALU_CONTROL decodifica funct3 = 000; Control activa Branch = 1 y Branch & Zero controla el mux del PC.
            BNE:        Result = (Data1 == Data2) ? 32'd1 : 32'd0;                  // Opcode propio. ALU_CONTROL decodifica funct3 = 001; Zero = 1 si Data1 != Data2; Branch & Zero controla el mux del PC.
            BLT:        Result = ($signed(Data1) < $signed(Data2)) ? 32'd0 : 32'd1; // Opcode propio. ALU_CONTROL decodifica funct3 = 100; Zero = 1 si Data1 < Data2 (con signo); Branch & Zero controla el mux del PC.
            BLTU:       Result = (Data1 < Data2) ? 32'd0 : 32'd1;                   // Opcode propio. ALU_CONTROL decodifica funct3 = 110; Zero = 1 si Data1 < Data2 (sin signo); Branch & Zero controla el mux del PC.
            // BGE:     // Recicla SLT (Zero = 1 si Data1 >= Data2 con signo). ALU_CONTROL mapea funct3 = 101 a SLT; Control activa Branch = 1 y RegWrite = 0.
            // BGEU:    // Recicla SLTU (Zero = 1 si Data1 >= Data2 sin signo). ALU_CONTROL mapea funct3 = 111 a SLTU; Control activa Branch = 1 y RegWrite = 0.

        // FORMATO S
            // SW:      // Recicla ADD (rs1 + imm). ALUSrc = 1 mete imm S (Imm Gen) en Data2 y Control activa MemWrite = 1 (funct3 = 010).

        // FORMATO I
            // ADDI:    // Recicla ADD. ALU_CONTROL decodifica funct3 = 000; ALUSrc = 1 carga imm I (Imm Gen) en Data2; RegWrite = 1.
            // SLTI:    // Recicla SLT. ALU_CONTROL decodifica funct3 = 010; ALUSrc = 1 carga imm I (Imm Gen) en Data2; RegWrite = 1.
            // SLTIU:   // Recicla SLTU. ALU_CONTROL decodifica funct3 = 011; ALUSrc = 1 carga imm I (Imm Gen) en Data2; RegWrite = 1.
            // XORI:    // Recicla XOR. ALU_CONTROL decodifica funct3 = 100; ALUSrc = 1 carga imm I (Imm Gen) en Data2; RegWrite = 1.
            // ORI:     // Recicla OR. ALU_CONTROL decodifica funct3 = 110; ALUSrc = 1 carga imm I (Imm Gen) en Data2; RegWrite = 1.
            // ANDI:    // Recicla AND. ALU_CONTROL decodifica funct3 = 111; ALUSrc = 1 carga imm I (Imm Gen) en Data2; RegWrite = 1.
            // SLLI:    // Recicla SLL. ALU_CONTROL decodifica funct3 = 001 y bit 30 = 0; ALUSrc = 1 mete shamt en Data2[4:0]; RegWrite = 1.
            // SRLI:    // Recicla SRL. ALU_CONTROL decodifica funct3 = 101 y bit 30 = 0; ALUSrc = 1 mete shamt en Data2[4:0]; RegWrite = 1.
            // SRAI:    // Recicla SRA. ALU_CONTROL decodifica funct3 = 101 y bit 30 = 1; ALUSrc = 1 mete shamt en Data2[4:0]; RegWrite = 1.
            // LW:      // Recicla ADD (rs1 + imm). ALUSrc = 1 mete imm I (Imm Gen); Control activa MemRead = 1, MemtoReg = 1 y RegWrite = 1 (funct3 = 010).
            // JALR:    // Recicla ADD (rs1 + imm). ALU_CONTROL manda ADD y ALUSrc = 1 mete imm I (Imm Gen); el mux del PC se amplía con {Result[31:1], 1'b0} y MemtoReg guarda PC + 4 en rd (RegWrite = 1).

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