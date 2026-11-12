module RAM(CLK,addr,data_in,data_out,MemWrite);

input CLK;                                                                                // Declaración de la señal de reloj
parameter addr_width = 10;                                              // tamaño de bits que necesitamos para acceder a las 1024 posiciones de memoria
parameter data_width = 32;                                              // Longitud de datos en bits en CADA UNA DE LAS DIRECCIONES DE MEMORIA
input logic [addr_width-1:0]addr;                                 // La dirección a la que queremos acceder
input logic [data_width-1:0]data_in;                              // Datos a la entrada de la RAM
output logic [data_width-1:0] data_out;                     // Salida de datos
input logic MemWrite;                                                         // Declaración de la variable de que habilita la escritura

logic [data_width-1:0] memoria [0:2**(addr_width) -1]; // Memoria de 1024 posiciones de memoria y cada una de ellas con 32 bits de longitud

      always_ff @(posedge CLK)
      begin
            if (MemWrite == 1)                                                            // Cuando el Memwrite esta activo, se habilita la escritura
                  memoria[addr] <= data_in;                                         // Le pasa a la memoria el data in (Síncrono)
      end
      
assign data_out = memoria[addr];                                              // Lee el valor de la memoria de forma asíncrona,

endmodule
