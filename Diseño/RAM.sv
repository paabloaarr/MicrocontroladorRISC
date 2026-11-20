module RAM (CLK,RAM_Addr,RAM_W_Data,RAM_R_Data,RAM_memWrite,RAM_memRead);

input CLK;										// Declaración de la señal de reloj
parameter addr_width = 10;						// tamaño de bits que necesitamos para acceder a las 1024 posiciones de memoria
parameter data_width = 32;						// Longitud de datos en bits en CADA UNA DE LAS DIRECCIONES DE MEMORIA
input logic [addr_width-1:0]RAM_Addr;				// La dirección a la que queremos acceder
input logic [data_width-1:0]RAM_W_Data;			// Datos a la entrada de la RAM
output logic [data_width-1:0] RAM_R_Data;			// Salida de datos
input logic RAM_memWrite;							// Declaracion de la variable que habilita la escritura
input logic RAM_memRead;                     // Declaracion de la variable que habilita la lectura

logic [data_width-1:0] memoria [0:2**(addr_width) -1];	// Memoria de 1024 posiciones de memoria y cada una de ellas con 32 bits de longitud

	always_ff @(posedge CLK)
	begin
		if (RAM_memWrite == 1)						// Cuando el Memwrite esta activo, se habilita la escritura
			memoria[RAM_Addr] <= RAM_W_Data;			// Le pasa a la memoria el data in (Síncrono)
	end

always_comb begin									// Lee el valor de la memoria de forma asíncrona,
	if (RAM_memRead == 1)begin 
		RAM_R_Data = memoria[RAM_Addr];
	end else begin
		RAM_R_Data = '0;
	end
end
endmodule

