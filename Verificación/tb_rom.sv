`timescale 1ns / 1ps

module tb_ROM;

    // Parámetros iguales a los de tu diseño
    localparam int Rom_R_Addr_width = 10;
    localparam int ROM_Ins_length = 32;
	localparam string txt="datos.txt";

    // Señales para conectar al módulo (DUT - Device Under Test)
	logic [Rom_R_Addr_width-1:0] Rom_R_Addr;
	logic [ROM_Ins_length-1:0] ROM_Ins;

    // Instancia de la ROM pasándole el nombre del archivo
    ROM #(
		.Rom_R_Addr_width(Rom_R_Addr_width),
		.ROM_Ins_length(ROM_Ins_length),
        .txt("datos.txt")
    ) dut (
		.Rom_R_Addr(Rom_R_Addr),
        .ROM_Ins(ROM_Ins)
    );

    // Estímulos de prueba
	logic [ROM_Ins_length-1:0] memoria_esperada [0:(2**Rom_R_Addr_width)-1];

	initial begin
		 // Cargamos la referencia en el testbench
		 $readmemh(txt, memoria_esperada);

		 // Recorremos todas las direcciones automáticamente
		 for (int i = 0; i < (2**Rom_R_Addr_width); i++) begin
			  addr = i;
			  #1; // Esperamos 1 ns a que responda la ROM (deberia responder inst. pero conviene esperar un poco)
			  assert (ROM_Ins === memoria_esperada[i])
					else $error("MISMATCH en addr %0d: esperado 0x%h, obtenido 0x%h", 
									i, memoria_esperada[i], ROM_Ins);
		 end
		 
		 $display("Verificacion completada sin errores.");
		 $finish;
	end
	 

endmodule 
