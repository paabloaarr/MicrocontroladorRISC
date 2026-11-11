`timescale 1ns / 1ps

module tb_ALU ();

    localparam T = 10;

    logic [3:0]  OPCODE;
    logic [31:0] Data1, Data2;
    logic        Zero;
    logic [31:0] Result;

    ALU duv (.*);

    initial begin
        OPCODE = 4'b0000;
        Data1  = 32'd0;
        Data2  = 32'd0;
		  
		  $display("Inicio de la verificacion de la ALU");

        // 1. Recorremos las operaciones con un bucle for (0 a 9 + 10 para probar default)
        for (int i = 0; i <= 10; i++) begin
            OPCODE = i[3:0];

            // A) Test dirigido a casos esquina (corner cases del Bloque I.IV)
            test_dirigido(32'h0000_0000, 32'h0000_0000); // Ceros (activa flag Zero)
            test_dirigido(32'h7FFF_FFFF, 32'h8000_0000); // Max positivo vs Min negativo (SLT vs SLTU)
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
            Data1 = $random;
            Data2 = $random;
            #(T);
			   test();
        end
    endtask

    // Task para generar casos concretos
    task test_dirigido(input logic [31:0] d1, input logic [31:0] d2);
        begin
            Data1 = d1;
            Data2 = d2;
            #(T);
            test();
        end
    endtask

    // Task de comprobacion con golden model y aserciones inmediatas
    task test();
        logic [31:0] res_ideal;
        logic        zero_ideal;
        begin
            case (OPCODE)
                4'b0000: res_ideal = Data1 + Data2;
                4'b0001: res_ideal = Data1 << Data2[4:0];
                4'b0010: res_ideal = ($signed(Data1) < $signed(Data2)) ? 32'd1 : 32'd0;
                4'b0011: res_ideal = (Data1 < Data2) ? 32'd1 : 32'd0;
                4'b0100: res_ideal = Data1 ^ Data2;
                4'b0101: res_ideal = Data1 >> Data2[4:0];
                4'b0110: res_ideal = Data1 | Data2;
                4'b0111: res_ideal = Data1 & Data2;
                4'b1000: res_ideal = Data1 - Data2;
                4'b1001: res_ideal = $signed(Data1) >>> Data2[4:0];
                default: res_ideal = 32'b0;
            endcase

            zero_ideal = (res_ideal == 32'b0) ? 1'b1 : 1'b0;

            // Asercion inmediata para validar resultado y flag Zero
            assert (Result == res_ideal && Zero == zero_ideal)
            else $error("NOT OK en OPCODE=%b: D1=%0d, D2=%0d | Obtenido=%0d (Z=%b) | Esperado=%0d (Z=%b)",
                        OPCODE, $signed(Data1), $signed(Data2), $signed(Result), Zero, $signed(res_ideal), zero_ideal);
        end
    endtask

endmodule