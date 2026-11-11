module BR (
    input  logic        CLK, 			//Reloj
    input  logic        clear,	   //Pone a cero. Activo a nivel bajo.
    input  logic        Reg_Write,  //Habilitación a nivel alto
    input  logic [4:0]  Read_Reg1,  //Elige que registro leer
    input  logic [4:0]  Read_Reg2,  //Elige que registro leer
    input  logic [4:0]  Write_Reg,  //Elige en que registro escribir
    input  logic [31:0] Write_Data, //Dato a escribir
    output logic [31:0] Read_Data1, //Dato a leer
    output logic [31:0] Read_Data2  //Dato a leer
);
//Declaración de los registros
logic [31:0][31:0] registro; //La posición cero debe estar a cero siempre

//Escritura síncrona
always_ff @(posedge CLK)
	if (!clear)
		registro <= '0;
	else if (Reg_Write) begin
		
		if (Write_Reg == 0)
			registro[Write_Reg] <= '0;
		else 
			registro[Write_Reg] <= Write_Data;
	end
		
//Lectura asíncrona
assign Read_Data1 = registro[Read_Reg1];
assign Read_Data2 = registro[Read_Reg2];
endmodule
