module rom_async #(parameter addr_width = 10, parameter dataout_length=32, parameter txt="datos.txt")
(
    input  logic [addr_width-1:0] addr,  // 10 bits de dirección para 1024 posiciones
    output logic [dataout_length-1:0] data_out   // 32 bits de ancho para la memoria de instrucciones
);

    logic [dataout_length-1:0] memoria [0:(2**addr_width)-1]; //de 0 a 1023 por convencion, de esta manera se lee la memoria en orden y no al reves
	 //1024 direcciones, 32 bits de informacion para cada una
	 
    // Inicialización a partir del fichero de texto
	 
    initial begin
        $readmemh(txt, memoria); //introducir fichero de texto, mh es en hexa, mb es en binario
    end

    assign data_out = memoria[addr]; // LECTURA ASÍNCRONA

endmodule 
