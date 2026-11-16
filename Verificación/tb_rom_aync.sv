`timescale 1ns / 1ps

module tb_rom_async;

    // Parámetros iguales a los de tu diseño
    localparam int addr_width = 10;
    localparam int data_width = 32;
	localparam string txt="datos.txt";

    // Señales para conectar al módulo (DUT - Device Under Test)
    logic [addr_width-1:0] addr;
    logic [data_width-1:0] data_out;

    // Instancia de la ROM pasándole el nombre del archivo
    rom_async #(
        .addr_width(addr_width),
        .dataout_length(data_width),
        .txt("datos.txt")
    ) dut (
        .addr(addr),
        .data_out(data_out)
    );

    // Estímulos de prueba
   logic [data_width-1:0] memoria_esperada [0:(2**addr_width)-1];

	initial begin
		 // Cargamos la referencia en el testbench
		 $readmemh(txt, memoria_esperada);

		 // Recorremos todas las direcciones automáticamente
		 for (int i = 0; i < (2**addr_width); i++) begin
			  addr = i;
			  #1; // Esperamos 1 ns a que responda la ROM (deberia responder inst. pero conviene esperar un poco)
			  assert (data_out === memoria_esperada[i])
					else $error("MISMATCH en addr %0d: esperado 0x%h, obtenido 0x%h", 
									i, memoria_esperada[i], data_out);
		 end
		 
		 $display("Verificacion completada sin errores.");
		 $finish;
	end
	 

endmodule 
