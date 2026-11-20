module ROM #(parameter Rom_R_Adrr_width = 10, parameter ROM_Ins_length=32, parameter txt="datos.txt")
(
	input  logic [Rom_R_Adrr_width-1:0] Rom_R_Adrr,  // 10 bits de dirección para 1024 posiciones
	output logic [ROM_Ins_length-1:0] ROM_Ins   // 32 bits de ancho para la memoria de instrucciones
);

    logic [ROM_Ins_length-1:0] memoria [0:(2**Rom_R_Adrr_width)-1]; //de 0 a 1023 por convencion, de esta manera se lee la memoria en orden y no al reves
	 //1024 direcciones, 32 bits de informacion para cada una
	 
    // Inicialización a partir del fichero de texto
	 
    initial begin
        $readmemh(txt, memoria); //introducir fichero de texto, mh es en hexa, mb es en binario
    end

    assign ROM_Ins = memoria[Rom_R_Adrr]; // LECTURA ASÍNCRONA

endmodule 
