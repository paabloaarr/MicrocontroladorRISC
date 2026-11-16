`timescale 1ns/1ps

module tb_BR;

    // Señales del DUT
    logic        CLK = 0;
    logic        clear;
    logic        Reg_Write;
    logic [4:0]  Read_Reg1, Read_Reg2, Write_Reg;
    logic [31:0] Write_Data;
    logic [31:0] Read_Data1, Read_Data2;

    // Modelo de referencia: lo que DEBERÍA contener el banco
    logic [31:0] modelo [32];
    int errores = 0;

    // Instancia del DUT (conexión por nombre implícita)
    BR dut (.*);

    // Reloj de 10 ns
    always #5 CLK = ~CLK;

    // ---------------------------------------------------------------
    // Tareas auxiliares
    // ---------------------------------------------------------------

    // Reset síncrono activo a nivel bajo durante 2 ciclos
    task automatic reset();
        @(negedge CLK);
        clear = 0;
        foreach (modelo[i]) modelo[i] = '0;
        repeat (2) @(posedge CLK);
        @(negedge CLK);
        clear = 1;
    endtask

    // Escritura: pone los datos en el flanco de bajada y escribe en el de subida
    task automatic escribir(input logic [4:0] dir, input logic [31:0] dato,
                            input logic en = 1);
        @(negedge CLK);
        Write_Reg  = dir;
        Write_Data = dato;
        Reg_Write  = en;
        @(posedge CLK);
        if (en && dir != 0) modelo[dir] = dato;
        @(negedge CLK);
        Reg_Write = 0;
    endtask

    // Lectura por ambos puertos y comparación con el modelo (sin esperar reloj)
    task automatic comprobar(input logic [4:0] r1, input logic [4:0] r2);
        Read_Reg1 = r1;
        Read_Reg2 = r2;
        #1;
        if (Read_Data1 !== modelo[r1]) begin
            $error("Puerto 1: x%0d = %h, esperado %h", r1, Read_Data1, modelo[r1]);
            errores++;
        end
        if (Read_Data2 !== modelo[r2]) begin
            $error("Puerto 2: x%0d = %h, esperado %h", r2, Read_Data2, modelo[r2]);
            errores++;
        end
    endtask

    // ---------------------------------------------------------------
    // Estímulos
    // ---------------------------------------------------------------
    initial begin
        clear      = 1;
        Reg_Write  = 0;
        Read_Reg1  = 0;
        Read_Reg2  = 0;
        Write_Reg  = 0;
        Write_Data = 0;

        // Test 1: tras el reset todo debe valer 0
        $display("[%0t] Test 1: reset", $time);
        reset();
        for (int i = 0; i < 32; i++) comprobar(i, 31 - i);

        // Test 2: escribir x1..x31 y leer por ambos puertos
        $display("[%0t] Test 2: escritura y lectura de todos los registros", $time);
        for (int i = 1; i < 32; i++) escribir(i, $urandom());
        for (int i = 0; i < 32; i++) comprobar(i, (i + 7) % 32);

        // Test 3: escribir en x0 no debe tener efecto
        $display("[%0t] Test 3: escritura en x0", $time);
        escribir(0, 32'hFFFF_FFFF);
        comprobar(0, 0);

        // Test 4: con Reg_Write = 0 no se escribe
        $display("[%0t] Test 4: Reg_Write desactivado", $time);
        escribir(5, 32'hDEAD_BEEF, 0);
        comprobar(5, 5);

        // Test 5: lectura asíncrona (cambia la dirección sin flanco de reloj)
        $display("[%0t] Test 5: lectura asincrona", $time);
        @(posedge CLK);
        #2 comprobar(3, 4);
        #1 comprobar(10, 20);

        // Test 6: leer el mismo registro que se escribe en ese ciclo
        $display("[%0t] Test 6: lectura del registro que se esta escribiendo", $time);
        @(negedge CLK);
        Read_Reg1  = 7;
        Write_Reg  = 7;
        Write_Data = 32'h1234_5678;
        Reg_Write  = 1;
        #1;
        if (Read_Data1 !== modelo[7]) begin
            $error("Antes del flanco deberia leerse el valor antiguo de x7");
            errores++;
        end
        @(posedge CLK);
        modelo[7] = 32'h1234_5678;
        #1;
        if (Read_Data1 !== modelo[7]) begin
            $error("Tras el flanco deberia leerse el valor nuevo de x7");
            errores++;
        end
        @(negedge CLK);
        Reg_Write = 0;

        // Test 7: clear con datos cargados
        $display("[%0t] Test 7: clear con el banco lleno", $time);
        reset();
        for (int i = 0; i < 32; i++) comprobar(i, i);

        // Resultado
        if (errores == 0) $display("=== TODOS LOS TESTS PASADOS ===");
        else              $display("=== %0d ERRORES ===", errores);
        $stop;
    end

endmodule