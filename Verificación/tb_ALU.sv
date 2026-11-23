`timescale 1ns / 1ps

module tb_ALU ();

    localparam T = 10;

    typedef enum logic [3:0] {
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
        BNE,
        BLT,
        BLTU
    } ALU_OPCODES;

    logic [3:0]  ALU_CONTROL_in;
    logic [31:0] ALU_Data1, ALU_Data2;
    logic        ALU_zero;
    logic [31:0] ALU_result;

    // Señal enumerada para ver el nombre de la operacion en ondas y en el golden model
    ALU_OPCODES opcode_enum;
    assign opcode_enum = ALU_OPCODES'(ALU_CONTROL_in);

    ALU duv (.*);

    initial begin
        ALU_CONTROL_in = 4'b0000;
        ALU_Data1      = 32'd0;
        ALU_Data2      = 32'd0;

        $display("Inicio de la verificacion de la ALU");

        // 1. Recorremos las operaciones con un bucle for (0 a 12 + 13 para probar default)
        for (int i = 0; i <= 13; i++) begin
            ALU_CONTROL_in = i[3:0];

            // A) Test dirigido a casos esquina (corner cases del Bloque I.IV)
            test_dirigido(32'h0000_0000, 32'h0000_0000); // Ceros (activa flag Zero / igualdad en BNE)
            test_dirigido(32'h7FFF_FFFF, 32'h8000_0000); // Max positivo vs Min negativo (SLT/SLTU y BLT/BLTU)
            test_dirigido(32'h8000_0000, 32'h7FFF_FFFF); // Min negativo vs Max positivo (activa Zero en BLT)
            test_dirigido(32'h8000_0000, 32'd4);         // Desplazamiento de signo (SRA vs SRL)
            test_dirigido(32'hFFFF_FFFF, 32'hFFFF_FFFF); // Todo unos (-1)

            // B) Estimulos aleatorios con repeat y $random
            repeat (50) begin
                estimulos_random();
            end
        end

        $display("Fin de la verificacion de la ALU");
        $stop;
    end

    // Task para generar estimulos aleatorios
    task estimulos_random();
        begin
            ALU_Data1 = $random;
            ALU_Data2 = $random;
            #(T);
            test();
        end
    endtask

    // Task para generar casos concretos
    task test_dirigido(input logic [31:0] d1, input logic [31:0] d2);
        begin
            ALU_Data1 = d1;
            ALU_Data2 = d2;
            #(T);
            test();
        end
    endtask

    // Task de comprobacion con golden model y aserciones inmediatas
    task test();
        logic [31:0] res_ideal;
        logic        zero_ideal;
        begin
            case (opcode_enum)
                ADD:     res_ideal = ALU_Data1 + ALU_Data2;
                SLL:     res_ideal = ALU_Data1 << ALU_Data2[4:0];
                SLT:     res_ideal = ($signed(ALU_Data1) < $signed(ALU_Data2)) ? 32'd1 : 32'd0;
                SLTU:    res_ideal = (ALU_Data1 < ALU_Data2) ? 32'd1 : 32'd0;
                XOR:     res_ideal = ALU_Data1 ^ ALU_Data2;
                SRL:     res_ideal = ALU_Data1 >> ALU_Data2[4:0];
                OR:      res_ideal = ALU_Data1 | ALU_Data2;
                AND:     res_ideal = ALU_Data1 & ALU_Data2;
                SUB:     res_ideal = ALU_Data1 - ALU_Data2;
                SRA:     res_ideal = $signed(ALU_Data1) >>> ALU_Data2[4:0];
                BNE:     res_ideal = (ALU_Data1 == ALU_Data2) ? 32'd1 : 32'd0;
                BLT:     res_ideal = ($signed(ALU_Data1) < $signed(ALU_Data2)) ? 32'd0 : 32'd1;
                BLTU:    res_ideal = (ALU_Data1 < ALU_Data2) ? 32'd0 : 32'd1;
                default: res_ideal = 32'b0;
            endcase

            zero_ideal = (res_ideal == 32'b0) ? 1'b1 : 1'b0;

            // Asercion inmediata para validar resultado y flag Zero
            assert (ALU_result == res_ideal && ALU_zero == zero_ideal)
            else $error("NOT OK en %s (%b): D1=%0d, D2=%0d | Obtenido=%0d (Z=%b) | Esperado=%0d (Z=%b)",
                        opcode_enum.name(), ALU_CONTROL_in, $signed(ALU_Data1), $signed(ALU_Data2),
                        $signed(ALU_result), ALU_zero, $signed(res_ideal), zero_ideal);
        end
    endtask

endmodule